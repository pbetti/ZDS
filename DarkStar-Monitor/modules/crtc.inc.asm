;
;=======================================================================
;
; Modular Z80 DarkStar (NE Z80) Monitor
;
;=======================================================================
;
; CRTC
; SY6545A-1 and PIOs for video ram access on LX529
; ---------------------------------------------------------------------
;
; 20160626 - Major CRT routines rewrite.
;		- Code cleanup
;		- CRT handling rewrote
;		- Some routine imported/adapted from original
;		  ne eprom 683
;		- Fixed lf/cr bug on scroll

;; 6545 registers initialization vector
crttab:
	db	111		; VR0 Tot h chars -1
	db	80		; VR1 Disp h chars
	db	87		; VR2 HSync pos
	db	$28		; VR3 Sync width
	db	26		; VR4 Tot rows -1
	db	0		; VR5 VAdj
	db	25		; VR6 Disp rows -1
	db	25		; VR7 VSync pos
	db	01001000b	; VR8 00 Non interl,
				;      0 binary addressing,
				;      1 transparent mem,
				;      0 display no delay,
				;      0 cursor no delay
				;      1 pin34 strobe
				;      0 upd in blanking
	db	11		; VR9 Character scan lines
	db	0		; VR10 Curs start (and no blink)
	db	11		; VR11 Curs end
	db	0,0		; VR12/13 Display start
	db	0,0		; VR14/15 Cursor position
	db	0,0		; VR16/17 LPEN position
	db	0,0		; VR18/19 Update position
;;
;; CRTCINI - init buffers,6545,test vram,clear,leave cursor at home
;;
crtcini:
	call	inicrt			; init video hw
	call	clrscr			; clear vram
	call	gioini			; init remaing hardware on the board
	ret

;;
;; INICRT
;
inicrt:
					; initialize PIOs
	ld	a,$8f			; 10-00-1111 mode ctrl word
					; Mode 2 (I/O port A)
	out	(crtram0cnt),a
	out	(crtram1cnt),a
	out	(crtram2cnt),a
	; initialize sy6545
	ld	hl,crttab		; now read from eprom
	ld	b,$00
	ld	a,b
ictlp0:	out    (crt6545adst),a		; 6545 init loop
	ld	a,(hl)
	out	(crt6545data),a
	inc	hl
	inc	b
	ld	a,b
	cp	$14
	jr	nz,ictlp0
	call	vstares			; reset origin, position
	jp	crtprgend		; go on...

;;
;; Reset video start and cursor buffer
;
vstares:
	ld	hl,$0000		; reset buffers:
	ld	(curpbuf),hl		; cursor position
	ld	(vstabuf),hl		; dpy start
	call	sdpysta			; reset start
	call	scrspos			; cursor at home
 	ret
;;
;; Update display start address. Scroll or rotate.
;
scroll:
	push	hl		; save position
	ld	hl,miobyte
	bit	2,(hl)		; scroll disabled ?
	jr	nz,noupdstart	; yes, then no scrolling

	ld	hl,(vstabuf)	; load curently display start
	ld	de,80		; DE = char. for line
	add	hl,de		; point to next line
	res	3,h		;
	ld	(vstabuf),hl	; save curently display start
	call	sdpysta		; set it
	ld	hl,endvid+1-80	; set new video pointer
	call	cescr1		; go to clear to end screen
	pop	hl		; restore position
	ret
;
noupdstart:
	pop	hl		; restore position
	ld	bc,80		; BC = char/row
	call	divide		; HL = Xco
	ret			; and ret

;;
;; GET DISPLAY CURSOR POSITION and return in HL
;
gcrspos:
	ld	a,vr14.curposh
	out	(crt6545adst),a
	in	a,(crt6545data)
	ld	h,a
	ld	a,vr15.curposl
	out	(crt6545adst),a
	in	a,(crt6545data)
	ld	l,a
	jr	crtprgend

;;
;; SET DISPLAY START ADDRESS
;
sdpysta:
	ld	a,vr12.dstarth
	out	(crt6545adst),a
	ld	a,h
	out	(crt6545data),a
	ld	a,vr13.dstartl
	out	(crt6545adst),a
	ld	a,l
	out	(crt6545data),a
	ret

;;
;; Locate cursor @ HL (absolute 0-1919)
;
curloca:
	call	scrtst			; bigger than endvid?
	jr	c,curloc0		; ok go on
	ld	hl,endvid		; place at edge
curloc0:
	ld	(curpbuf),hl		; update buf
	; fall through...
;;
;; Update video pointer
;
updvidp:
	ld	de,(vstabuf)		; load curently display start
	add	hl,de			; compute relative position
					; and count with updtcpur
scrspos:
	ld	a,vr14.curposh
	out	(crt6545adst),a
	ld	a,h
	out	(crt6545data),a
	ld	a,vr15.curposl
	out	(crt6545adst),a
	ld	a,l
	out	(crt6545data),a
updtureg:
	ld	a,vr18.updaddrh
	out	(crt6545adst),a
	ld	a,h
	out	(crt6545data),a
	ld	a,vr19.updaddrl
	out	(crt6545adst),a
	ld	a,l
	out	(crt6545data),a
	jr	crtprgend

;;
;; DBLANK
;; fill video ram (2k) with 0's
;
clrscr:
	ld	hl,$0000
	ld	(ram0buf),hl
	xor	a
	ld	(ram2buf),a
	ld	a,$ef
	ld	(ram3buf),a
	ld	hl,$0000
	call	rstdpy
clrs0:	push	hl
	call	dispgr
	pop	hl
	inc	hl
	ld	a,h
	cp	$08
	jr	nz,clrs0
	ld	a,$ff
	ld	(ram3buf),a		; resets vattr
	call	vstares
	jr	crtprgend

;;
;; RSTDPY - zeroes SY6545 higher register (R12 to R19)
;;
rstdpy:
	ld	b,$08
rdpy1:	ld	a,b
	add	a,$0b
	out	(crt6545adst),a
	xor	a
	out	(crt6545data),a
	djnz	rdpy1

	; fall through...

;;
;; CRTPRGEND
;; resets 6545 register pointer
;
crtprgend:
	ld	a,vr31.dummy
	out	(crt6545adst),a
	ret

;;
;; DISPGR - display in graphic mode (raw output)
;
dispgr:
	in	a,(crt6545adst)
	bit	7,a
	jr	z,dispgr
	ld	hl,ram0buf
	ld	a,(hl)
	out	(crtram0dat),a
	inc	hl
	ld	a,(hl)
	out	(crtram1dat),a
	inc	hl
	ld	a,(hl)
	out	(crtram2dat),a
	ld	a,(ram3buf)
	out	(crtram3port),a
	xor	a
	out	(crt6545data),a
	ret

;;
;; DISPCH - Display in text mode (raw output)
;;
dispch:
	push	af
dgclp0:	in	a,(crt6545adst)
	bit	7,a
	jr	z,dgclp0
	pop	af
	out	(crtram0dat),a
	ld	a,(ram3buf)
	out	(crtram3port),a
	xor	a
	out	(crt6545data),a
	ret
;;
;; Fill screen of chars in C
;
crtfill:
	ld	hl,$0000		; init count
	call	rstdpy			; @ vhome
crtf0:	ld	a,c			;
	call	dispch			; display
	inc	hl			; go on
	ld	a,h
	cp	$08
	jr	nz,crtf0		; screen end?
	call	vstares			; reset origins
	jr	crtprgend

;;
;; BCONOUT print out the char in reg C
;; with full evaluation of control chars
;;
;; register clean: can be used as CP/M BIOS replacement
;;
bconout:
	push	af
	push	bc
	push	de
	push	hl
	; force jump to register restore and exit in stack
	ld	hl,bcexit
	push	hl
	;
	ld	a,c
	ld	hl,miobyte
	bit	7,(hl)			; alternate char processing ?
	ex	de,hl
	jr	nz,conou2		; yes: do alternate
	cp	$20			; no: is less then 0x20 (space) ?
	jr	nc,cojp1		; no: go further

	add	a,a			; yes: is a special char
	ld	h,0
	ld	l,a
	ld	bc,iocvec
	add	hl,bc
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	jp	(hl)			; jump to IOCVEC handler

cojp1:	ex	de,hl
	bit	6,(hl)			; auto ctrl chars ??
	jr	z,cojp2			; no

	cp	$40			; yes: convert
	jr	c,cojp2
	cp	$60
	jr	nc,cojp2
	sub	$40

cojp2:	call	dispch			; display char
	; move cursor right
movrgt:
	ld	hl,(curpbuf)		; get cursor position
	inc	hl			; to next char
eostest:
	call	scrtst			; end of screen ?
	jr	c,cout00		; no
	ld	de,0ffb0h		;
	add	hl,de			;
	call	scroll			; update display start (scrolling)
cout00:
	ld	(curpbuf),hl		; save video pointer
	call	updvidp			; update video pointer
	ret
	; alternate processing....
conou2:
	cp	$20			; is a ctrl char ??
	jr	nc,curadr		; no: will set cursor pos

	add	a,a			; yes
	ld	h,0
	ld	l,a
	ld	bc,iocvec2
	add	hl,bc
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	jp	(hl)			; jump to service routine... (IOCVEC2)
;;
;; cursor addressing service routine
;; address is ESC + (COL # + 32) + (ROW # + 32) + NUL
;
curadr:	ld	hl,tmpbyte		; alredy do column ?
	bit	0,(hl)
	jr	nz,setrow		; yes, do row

	cp	112			; greater then 80 (+32) ?
	ret	nc			; yes: error
	sub	32			; no: adjust to real value
	ld	(appbuf),a		; store column
	set	0,(hl)			; switch row/col flag
	ret

setrow:	res	0,(hl)			; resets col/row flag
	cp	57			; greater than 25 (+32) ?
	ret	nc			; yes: error
	sub	31			; no: adjust to real value + 1 for count
	ld	hl,miobyte		; resets ctrl char flag
	res	7,(hl)			; done reset
	ld	b,a
	ld	hl,$ffb0
	ld	de,$0050

curofs:	add	hl,de			; calc. new offset
	djnz	curofs			; row
	ld	a,(appbuf)
	ld	e,a
	add	hl,de
	jr	cout00			; update position

bcexit:
	pop	hl
	pop	de
	pop	bc
	pop	af
	ret

;;
;; MOVDWN - cursor down one line
;
movdwn:
	ld	hl,(curpbuf)		; current
	ld	de,80			; 80 to add
	add	hl,de			; move down
	jr	eostest
;;
;; Move cursor up
;
movup:
	ld	de,80			; line lenght
movback:
	ld	hl,(curpbuf)		; current
	xor	a			; clear carry
	sbc	hl,de			; HL = video pointer - one line
	jr	nc,movb00		; ret if HL >= start video
	add	hl,de			; restore originally video pointer
movb00:
	ld	(curpbuf),hl		; save video pointer
movb01:
	call	updvidp			; update video pointer
	ret				; ret
;;
;; Move cursor left
;
movlft:
	ld	de,1			; one char
	jr	movback			; do it
;;
;; backspace
;; destructive or not depending on bit 4 miobyte
;
bakspc:
	ld	hl,miobyte
	bit	4,(hl)
	jr	nz,movlft		; equal to movlft
	; destructive
	call	movlft			; go back
	ld	a,' '			; clear
	call	dispch
	ld	hl,(curpbuf)		; reinit hl
	jr	movb01			; ret

;;
;; SCRTST - Verify if we need video scroll
;
scrtst:
	ld	de,endvid+1		; DE = end video + 1
	xor	a			; clear carry
	sbc	hl,de			; subctract and set carry
	add	hl,de			; restore hl
	ret				; and ret

;;
;; Cursor shape/mode handling
;
curblb:
	ld	l,$40           ; (0 10 00000) 1/16 blink scan 0
	jr	cursetmode
curbll:
	ld	l,$4a           ; (0 10 01010) 1/16 blink scan 10
	jr	cursetmode
curbfb:
	ld	l,$60           ; (0 11 00000) 1/32 blink scan 0
	jr	cursetmode
curbfl:
	ld	l,$6a           ; (0 11 01010) 1/32 blink scan 10
	jr	cursetmode
scurof:
	ld	l,$20           ; (0 01 00000) cursor off
	jr	cursetmode
curfxb:
	ld	l,$00           ; (0 00 00000) fixed scan 0
	jr	cursetmode
scuron:
	jr	curset		; cursor on
cursetmode:
	push	hl
	jr	curset1

;;
;; Setup cursor. (user mode)
;;
curset:
	push	hl
	ld	a,(cursshp)
	ld	l,a
curset1:
	ld	a,vr10.crstart
	out	(crt6545adst),a
	ld	a,l
	out	(crt6545data),a
	pop	hl
	jp	crtprgend

;;
;; SNDBEEP - sound beep
sndbeep:
	out	(crtbeepport),a
	ret
;;
;; CHOME - move cursor at col 0
;
chome:
	ld	hl,0
	jp	curloc0

;;
;; clear to end of page
;
clreop:
	call	clreop00
	ld	hl,(curpbuf)	; reinit hl to current
	jp	cout00
clreop00:
	; clear to end of screen
	ld	hl,(curpbuf)	; where to begin
	ld	de,endvid+1	; DE = end video + 1
cescr0:
	xor	a		; clear carry
	ex	de,hl		; compute number of
	sbc	hl,de		; character remaining
	ex	de,hl		; until end
cescr1:
	push	de		; save number of char.
	call	updvidp		; update video pointer
	pop	de		; restore char. number
cescr2:
	ld	a,d		; DE is zero ?
	or	e		;
	ret	z		; yes, then exit
cescr4:
	ld	a,' '
	call	dispch
	dec	de		; dec. char counter
	jr	cescr2		; and count
;
;
;; IOCCR - handle carriage return (0x0d)
;; should position the cursor at col 0
;
ioccr:
	call	cbeglin		; find begin
	jp	cout00		; update
;;
;; set HL to begin of line
cbeglin:
	; cursor beginning of line
	ld	hl,(curpbuf)	; load current
	ld	de,80
	push	bc		; save register
	ld	b,d
	ld	c,e		; bc = char. for line
	call	divide		;
	ld	l,0		;
	ld	d,b		;
	ld	e,c		;
	pop	bc		; restore register
ioccr0:
	ret	z		;
	add	hl,de		;
	dec	a		;
	jr	ioccr0		;
;;
;; CLREOL - clear to end of line
;
clreol:
	call	cbeglin		; call cursor begin of line
	add	hl,de		;
	ex	de,hl		;
	ld	hl,(curpbuf)	; restore video pointer
	push	hl		; save
	call	cescr0		; clear 'DE' char.
	pop	hl		; restore again
	jp	cout00		; update

;;;
scrolloff:
	ex	de,hl
	set	2,(hl)
	ret
scrollon:
	ex	de,hl
	res	2,(hl)
	ret
siocesc:
	ex	de,hl
	set	7,(hl)
	ret
;;
;; RESATTR - reset all attributes
;
resattr:
	ld	a,$ff
	ld	(ram3buf),a
	ret
;;
;; void routine
;
iocnull:
	ret
;;
;; Various routines to manipulate control flags
;;
;
ucasemod:
	ex	de,hl
	set	3,(hl)
	ret
lcasemod:
	ex	de,hl
	res	3,(hl)
	ret
rascfltr:
	ex	de,hl
	res	6,(hl)
	ret
ndbksp:
	ex	de,hl
	set	4,(hl)
	ret
dbksp:
	ex	de,hl
	res	4,(hl)
	ret
blinkoff:
	ld	hl,ram3buf
	set	0,(hl)
	ret
revoff:
	ld	hl,ram3buf
	set	1,(hl)
	ret
underoff:
	ld	hl,ram3buf
	set	2,(hl)
	ret
hlightoff:
	ld	hl,ram3buf
	set	3,(hl)
	ret
redon:
	ld	hl,ram3buf
	set	5,(hl)
	ret
greenon:
	ld	hl,ram3buf
	set	6,(hl)
	ret
blueon:
	ld	hl,ram3buf
	set	7,(hl)
	ret
blinkon:
	ld	hl,ram3buf
	res	0,(hl)
	ret
revon:
	ld	hl,ram3buf
	res	1,(hl)
	ret
underon:
	ld	hl,ram3buf
	res	2,(hl)
	ret
hlighton:
	ld	hl,ram3buf
	res	3,(hl)
	ret
redoff:
	ld	hl,ram3buf
	res	5,(hl)
	ret
greenoff:
	ld	hl,ram3buf
	res	6,(hl)
	ret
blueoff:
	ld	hl,ram3buf
	res	7,(hl)
	ret
riocesc:
	ex	de,hl
	res	7,(hl)
	ret
;
sascfltr:
	ex	de,hl
	set	6,(hl)
	ret
;;
;; Internal division routine
;; divide HL with BC; quoto in A, resto in HL
;
divide:
	xor	a		; clear accumulator and carry flag
hl.gt.0:
	sbc	hl,bc		;
	inc	a		;
	jr	nc,hl.gt.0	;
	dec	a		;
	add	hl,bc		;
	ret

;; This table define the offsets to jump to control routines
;; for primary (non-escaped) mode

iocvec:
	dw	riocesc			; NUL 0x00 (^@)  clear alternate output processing
	dw	ucasemod		; SOH 0x01 (^A)  uppercase mode
	dw	lcasemod		; STX 0x02 (^B)  normal case mode
	dw	iocnull			; ETX 0x00 (^C)  no-op
	dw	scurof			; EOT 0x04 (^D)  cursor off
	dw	scuron			; ENQ 0x05 (^E)  cursor on
	dw	iocnull			; ACK 0x06 (^F)  no-op
	dw	sndbeep			; BEL 0x07 (^G)  beep
	dw	bakspc			; BS  0x08 (^H)  cursor left (destr. and non destr.)
	dw	iocnull			; HT  0x09 (^I)  no-op
	dw	movdwn			; LF  0x0a (^J)  cursor down one line
	dw	chome			; VT  0x0b (^K)  cursor @ column 0
	dw	clrscr			; FF  0x0c (^L)  page down (clear screen)
	dw	ioccr			; CR  0x0d (^M)  provess CR
	dw	clreop			; SO  0x0e (^N)  clear to EOP
	dw	clreol			; SI  0x0f (^O)  clear to EOL
	dw	iocnull			; DLE 0x10 (^P)  no-op
	dw	resattr			; DC1 0x11 (^Q)  reset all attributes
	dw	crtcini			; DC2 0x12 (^R)  hard crt reset and clear
	dw	iocnull			; DC3 0x13 (^S)  no-op
	dw	iocnull			; DC4 0x14 (^T)  no-op
	dw	movup			; NAK 0x15 (^U)  cursor up one line
	dw	scrolloff		; SYN 0x16 (^V)  scroll off
	dw	scrollon		; ETB 0x17 (^W)  scroll on
	dw	movlft			; CAN 0x18 (^X)  cursor left (non destr. only)
	dw	movrgt			; EM  0x19 (^Y)  cursor right
	dw	iocnull			; SUB 0x1a (^Z)  no-op
	dw	siocesc			; ESC 0x1b (^[)  activate alternate output processing
	dw	iocnull			; FS  0x1c (^\)  no-op
	dw	iocnull			; GS  0x1d (^])  no-op
	dw	iocnull			; RS  0x1e (^^)  disabled (no-op)
	dw	iocnull			; US  0x1f (^_)  no-op

;; This table define the offsets to jump to control routines
;; for alternate (escaped) mode

iocvec2:
	dw	riocesc			; NUL 0x00 (^@)  clear alternate output processing
	dw	blinkoff		; SOH 0x01 (^A)  BLINK OFF
	dw	blinkon			; STX 0x02 (^B)  BLINK ON
	dw	underoff		; ETX 0x03 (^C)  UNDER OFF
	dw	underon			; EOT 0x04 (^D)  UNDER ON
	dw	hlightoff		; ENQ 0x05 (^E)  HLIGHT OFF
	dw	hlighton		; ACK 0x06 (^F)  HLIGHT ON
	dw	iocnull			; BEL 0x07 (^G)  no-op
	dw	iocnull			; BS  0x08 (^H)  no-op
	dw	iocnull			; HT  0x09 (^I)  no-op
	dw	iocnull			; LF  0x0a (^J)  no-op
	dw	iocnull			; VT  0x0b (^K)  no-op
	dw	clrscr			; FF  0x0c (^L)  blank screen
	dw	riocesc			; CR  0x0d (^M)  clear alternate output processing
	dw	redon			; SO  0x0e (^N)  set bit 5 RAM3BUF (red)
	dw	redoff			; SI  0x0f (^O)  res bit 5 RAM3BUF (red)
	dw	greenon			; DLE 0x10 (^P)  set bit 6 RAM3BUF (green)
	dw	greenoff		; DC1 0x11 (^Q)  res bit 6 RAM3BUF (green)
	dw	curblb			; DC2 0x12 (^R)  cursor blink slow block
	dw	curbll			; DC3 0x13 (^S)  cursor blink slow line
	dw	iocnull			; DC4 0x14 (^T)  no-op
	dw	iocnull			; NAK 0x15 (^U)  no-op
	dw	iocnull			; SYN 0x16 (^V)  no-op
	dw	sascfltr		; ETB 0x17 (^W)  set ascii filter
	dw	rascfltr		; CAN 0x18 (^X)  reset ascii filter
	dw	ndbksp			; EM  0x19 (^Y)  set non destructive BS
	dw	dbksp			; SUB 0x1a (^Z)  set destructive BS
	dw	revon			; ESC 0x1b (^[)  REVERSE ON
	dw	revoff			; FS  0x1c (^\)  REVERSE OFF
	dw	blueon			; GS  0x1d (^])  set bit 7 RAM3BUF (blue)
	dw	blueoff			; RS  0x1e (^^)  res bit 7 RAM3BUF (blue)
	dw	iocnull			; US  0x1f (^_)  no-op

;-----------------------------------------

