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
; 20180814 - Standard char output routine (bconoout) moved to common
;		seg for performance reason
; 20180910 - Renamed to console io, and merged hi level uart 0 routines
;
;......................................................................


	extern	movrgt, eostest, cout00
	extern	scrtst, updvidp, scrspos, dispch
	extern	fstat, fout, srxrsm
	extern	inline, print, vconout, tx0

ansidrv	equ	true			; set TRUE to enable ANSI console driver


wrureg0	macro	uregister
	out	(uart0+uregister),a
	endm

rdureg0	macro	uregister
	in	a,(uart0+uregister)
	endm

wrureg1	macro	uregister
	out	(uart1+uregister),a
	endm

rdureg1	macro	uregister
	in	a,(uart1+uregister)
	endm

deseq	macro	p1,p2
	ld	de,[p1 << 8] + p2
	endm

;----------------------------------------------------------------------------------------
;
; CRT Controller section. Console io and low level harware management
; routines can't be separated...
;


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
	ld	hl,crttab		; now read from table
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
;; GET DISPLAY CURSOR POSITION and return in HL
;
getcpos:
	; we must coop. with serial console output...
	ld	a,(miobyte)		; conf. location
	bit	5,a
	jp	nz,gcrs1		; for serial console
	ld	de,(curpbuf)		; absolute pos.
	; find row
	ld	hl,$0000		; init loop
	ld	bc,$0050
	xor	a
	dec	a
gcrs0:
	inc	a			; a = row
	add	hl,bc
	or	a			; cp hl,de
	sbc	hl,de			;
	add	hl,de			; -------
	jr	c,gcrs0
	; find col
	sbc	hl,bc			; @ 0
	ld	c,a			; move row
	ld	a,e
	sub	l			; a = col
	ld	h,c			; in hl row,col
	ld	l,a
	ret
gcrs1:
	xor	a
	ld	(asqbuf),a

	ld	a,'R'			; query cursor (answer) term.
	ld	(aqterm),a
	ld	d,6			; query cursor position
	ld	e,'n'
	call	seqemit			; and send

	call	getans			; wait for answer

	ld	de,asqstr		; convert from string
	ld	hl,0
	ld	c,8			; max in buffer
gcrsl:
	ld	a,(de)
	inc	de
	cp	';'			; row found ?
	jr	nz,gcrs2
	ld	b,l			; b = row (temp)
	ld	hl,0			; reset hl
	jr	gcrsl			; continue, skip ';'
gcrs2:
	or	a
	jr	nz,gcrs3
	ld	h,b			; hl = row col
	ld	a,l
	or	a
	ret	z
	dec	l
	dec	h
	ret
gcrs3:
	push	de
	sub	'0'
	ld	d,h			; copy HL -> DE
	ld	e,l
	add	hl,hl			; * 2
	add	hl,hl			; * 4
	add	hl,de			; * 5
	add	hl,hl			; * 10 total now
	ld	e,a			; Now add in the digit from the buffer
	ld	d,0
	add	hl,de
	pop	de
	dec	c
	jr	z,gcrse
	jr	gcrsl
gcrse:
	ld	hl,0
	ret

;;
;; Locate cursor @ HL
;
setcpos:
	push	af
	push	bc
	push	de
	; we must coop. to serial console output...
	ld	a,(miobyte)		; conf. location
	bit	5,a
	jp	nz,scrs1		; for serial console
	ld	b,h
	ld	c,l
	ld	hl,$ffb0
	ld	de,$0050
	inc	b
scrs0:
	add	hl,de			; calc row
	djnz	scrs0
	ld	e,c
	add	hl,de			; add col = abs. position
	ld	(curpbuf),hl		; update buf
	call	updvidp
	jr	scrse
scrs1:
	ld	c,esc
	call	txchar0

	ld	a,l
	add	a,32
	ld	c,a
	call	txchar0
;
	ld	a,h
	add	a,32
	ld	c,a
	call	txchar0

	ld	c,0
	call	txchar0
scrse:
	pop	de
	pop	bc
	pop	af
	ret

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



;
; Special control chars and seqences processing
;
vconou2:
	push	af
	xor	a
	cp	b			; b=0 means standard control chr
	ld	bc, iocvec		; point to standard jump vector
	jr	nz,conoalt

	pop	af			; b=1 means ESC prefixed control chr
	cp	$20			; is really a ctrl char ??
	jr	nc,curadr		; no: will so will set cursor pos
	ld	bc,iocvec2		; point to alternate jump vector
	jr	vconjmp
conoalt:
	pop	af
vconjmp:
	; special
	add	a,a
	ld	h,0
	ld	l,a
	add	hl,bc
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	jp	(hl)			; jump to service routine...

;
; cursor addressing service routine
; address is ESC + (COL # + 32) + (ROW # + 32) + NUL

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
	jp	cout00			; update position

;;
;; MOVDWN - cursor down one line
;
movdwn:
	ld	hl,(curpbuf)		; current
	ld	de,80			; 80 to add
	add	hl,de			; move down
	call	scrtst			; end of screen ?
	jp	c,cout00		; no
	ld	de,0ffb0h		;
	add	hl,de			;
	call	scroll			; update display start (scrolling)
	jp	cout00
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
;; CHOME - move cursor at 0,0
;
chome:
	ld	hl,0
	jp	cout00

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
	push	af
	call	sndbeep
	pop	af
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

;;
;; Draw a box
;;
;; HL = top left row/col, BC = # rows/cols E = single/double 0/1
;;
dbox:
	push	ix
	dec	e
	jr	z,dboxd
	ld	ix,sboxt
	jr	dbodr
dboxd:
	ld	ix,dboxt
dbodr:
	ld	d,b
	ld	e,c
	; top
	push	hl
	call	setcpos
	pop	hl
	ld	c,(ix+0)		; top left
	call	safpcr
	ld	c,(ix+4)		; h line
	ld	b,e
	call	srpch
	ld	c,(ix+1)		; top right
	call	safpcr
	; body
dboxb1:
	inc	h
	push	hl
	call	setcpos
	pop	hl
	ld	c,(ix+5)		; body left
	call	safpcr
	ld	c,' '			; blank
	ld	b,e
	call	srpch
	ld	c,(ix+5)		; body right
	call	safpcr
	dec	d
	jr	nz,dboxb1
dboend:
	; bottom
	inc	h
	call	setcpos
	ld	c,(ix+2)		; top left
	call	safpcr
	ld	c,(ix+4)		; h line
	ld	b,e
dbox2:
	call	srpch
	ld	c,(ix+3)		; top right
	call	safpcr
	pop	ix
	ret

;	     0tl, 1tr, 2bl, 3br,  4hl, 5vl
sboxt:
	defb 0c9h,0cah,0c7h,0c8h,0c1h,0c0h
dboxt:
	defb 0d4h,0d5h,0d2h,0d3h,0cch,0cbh

safpcr:
	ld	a,(miobyte)		; conf. location
	bit	5,a
	jp	z,vconout		; video
	jp	txchar0			; serial
	ret
srpch:
	call	safpcr
	djnz	srpch
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
	dw	chome			; VT  0x0b (^K)  cursor @ 0,0
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
	dw	iocnull			; RS  0x1e (^^)  no-op
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
	dw	sascfltr		; ETB 0x17 (^W)  set bit 6 miobyte
	dw	rascfltr		; CAN 0x18 (^X)  reset bit 6 miobyte
	dw	ndbksp			; EM  0x19 (^Y)  set non destructive BS
	dw	dbksp			; SUB 0x1a (^Z)  set destructive BS
	dw	revon			; ESC 0x1b (^[)  REVERSE ON
	dw	revoff			; FS  0x1c (^\)  REVERSE OFF
	dw	blueon			; GS  0x1d (^])  set bit 7 RAM3BUF (blue)
	dw	blueoff			; RS  0x1e (^^)  res bit 7 RAM3BUF (blue)
	dw	iocnull			; US  0x1f (^_)  no-op

;----------------------------------------------------------------------------------------
;
; UART 0 or serial console i/o routines
;

;;
;; Sends a char over serial line 0
;;
;; C: output char

	if not ansidrv
txchar0:
	else
dotxchar:
	endif
	ld	a,c
	push	bc
	push	af
txbusy0:
	rdureg0	r5lsr			; read status
	bit	5,a			; ready to send?
	jp	z,txbusy0		; no, retry.
	pop	af
	ld	b,a
	wrureg0	r0rxtx
	pop	bc
	ret

;;
;; Receive a char from serial line 0
;;
;; A: return input char

rxchar0:
	push	bc
	push	ix
	push	de
	push	hl
	ld	ix,tmpbyte

	if	ansidrv
	ld	de,(alinks)
	bit	3,(ix)			; two byte seq pending
	jp	nz,rxexsb
	endif

escnx:	bit	5,(ix)			; test system interrupt status
	jr	nz,rxchafif		; enabled, uses queue
rxbusy0:
	rdureg0	r5lsr			; read status
	bit	0,a			; data available in rx buffer?
	jr	z,rxbusy0		; loop until data is ready
	rdureg0	r0rxtx
	jr	rxche
rxchafif:
	ld	ix,fifou0
	call	fstat			; queue status
	call	z,srxrsm		; if empty ensure rx is unlocked
rxchaflp:
	call	fstat			; queue status
	jr	z,rxchaflp		; loop until char is ready
	di
	call	fout			; get a character from the queue
	ei
	ld	a,c 			; and put it in correct register
rxche:	ld	hl,miobyte
	bit	3,(hl)			; yes: transform to uppercase ?
	jr	z,rxche1		; no
	cp	'a'			; yes: is less then 'a' ?
	jp	m,rxche1		; yes: return, already ok
	cp	'{'			; no: then is greater than 'z' ?
	jp	p,rxche1		; yes: do nothing
	res	5,a			; no: convert uppercase...
rxche1:
	if 	not ansidrv
	ld	a,(tmpbyte)
	bit	5,a			; test system interrupt status
	jr	z,rxche1a		; disabled don't check queue
	call	fstat			; queue status
	call	z,srxrsm		; if empty unlock rx
rxche1a:
	pop	hl
	pop	de
	pop	ix
	pop	bc
	ret
	else
	ld	ix,tmpbyte		; point to flag byte
	bit	4,(ix)			; driver disabled ?
	jp	nz,rxeximm		; yes exit
	bit	2,(ix)			; in sequence job?
	jr	nz,prcsq		; yes
	bit	1,(ix)			; in CSI job?
	jr	nz,wtcsi		; yes
	cp	esc			; ESC ?
	jp	nz,rxeximm		; no exit
	;
	set	1,(ix)			; activate ANSI keys processing
	; may be that user pressed ESC and this is not a sequence...
	ld	de,2			; wait 2 ms, trying to see if this is a user
	call	delay			; operation with the ESC key.
	bit	5,(ix)			; now we see if other chars are already availables
	jr	nz,rxescfif		; int enabled, test uses queue
	rdureg0	r5lsr			; read status
	bit	0,a			; data available in rx buffer?
	jp	z,rxexesc		; no, user pressed ESC
	jp	escnx			; yes, go on
rxescfif:
	push	ix
	ld	ix,fifou0
	call	fstat			; data available in queue?
	pop	ix
	jr	z,rxexesc		; no, user pressed ESC
	jp	escnx			; yes, we have something to work on
	;
wtcsi:	res	1,(ix)			; in CSI reset flags
	cp	'['			; is a CSI: ESC+[ ?
	jr	z,gocsi			; yes
	cp	'O'			; is a CSI: ESC+O ? (used by F1 ... F4)
	jr	nz,rxeximm		; WRONG sequence
gocsi:	;
	set	2,(ix)			; CSI ok
	jp	escnx			; wait for next chars
prcsq:	;
	ld	hl,asqbuf		; setup string
	ld	b,(hl)
	inc	b
	ld	(hl),b
	ld	c,b			; save len on c
posbf:	inc	hl
	djnz	posbf			; position in buffer
	ld	(hl),a			; write
	inc	hl
	ld	(hl),0			; terminate
	ld	a,c			; check buffer capacity
	cp	8			; 8 char max
	jr	nc,rxeximm		; error
stsrch:
	ld	de,asqbuf+1		; init search
	ld	hl,ansikeys
	ld	bc,nakeys
	call	tlook			; perform it
	jr	nz,rxeximm		; unknown seq
	;				; found in table, but we need
	ld	de,(alinks)		; to test for a partial match
	or	a			; diff from string head
	sbc	hl,de
	dec	l
	dec	l
	dec	l			; include head
	ld	a,(alnght)		; check for len
	sub	l
	jp	nz,escnx		; partial match, wait for more
	ld	a,(de)			; got it!
	cp	esc			; if ESC is a two byte seq
	jr	nz,rxexsb		; exit for single byte code
	set	3,(ix)			; flag a two byte retcode
	jr	rxeximm
rxexsb:	res	3,(ix)			; clear two-byters flag
	xor	a
	ld	(asqbuf),a
	inc	de
	ld	a,(de)			; return code
	jr	rxeximm
rxex0:
	pop	af
	jr	rxeximm
rxexesc:
	ld	a,esc
rxeximm:
	res	2,(ix)
	ld	ix,fifou0
	ld	d,a			; save A
	call	fstat			; queue status
	call	z,srxrsm		; if empty unlock rx
	ld	a,d			; restore char
	pop	hl
	pop	de
	pop	ix
	pop	bc
	ret



;;
;; Any lenght string compare
;;
;; DE, HL < strings addresses
;; BC < max lenght
;; > Z = 1 found
cpstr:	ld	a,(de)			; get char from str1
	inc	de			; index next and compare
	cpi
	ret	nz			; no match
	ret	po			; end of string
	jr	cpstr

;;
;; string table lookup
;;
;; DE < test string, HL < table, BC < # strings in table
;; > Z = 1 match, HL > in string match + 1
tstlp:	push	de			; saves
	push	bc
	ld	(alinks),hl		; current string start (incl. head)
	inc	hl
	inc	hl			; skip linked address
	ld	b,0
	ld	c,(hl)			; current string length
	ld	a,c
	ld	(alnght),a		; current string len
	inc	hl
	ld	a,(asqbuf)
	ld	c,a			; test string len
	call	cpstr			; do compare
	jr	z,match			; exit if found
	ld	hl,(alinks)
	ld	a,(alnght)		; reload current string len
	add	a,3
	ld	c,a
	add	hl,bc			; add length, address next
	pop	bc			; restore count
	pop	de			; restore test string
	dec	bc			; update string count
	;
tlook:	ld	a,b			; table search entry point
	or	c			; check count = 0
	jr	nz,tstlp		; search next if not
	inc	a			; not found z = 0
	ret
match:	pop	bc
	pop	de			; clear stack
	ret				; found !



	endif

asqbuf:	defb	0
asqstr:	defs	9
alinks:	defw	0
alnght:	defb	0
aqterm:	defb	0

;;
;; Intercept "query device" answers
;;
getans:
	push	ix
getann:
	ld	ix,tmpbyte
	bit	5,(ix)			; test system interrupt status
	jr	nz,getafi		; enabled, uses queue
getan0:
	rdureg0	r5lsr			; read status
	bit	0,a			; data available in rx buffer?
	jr	z,getan0		; loop until data is ready
	rdureg0	r0rxtx
	jr	getan1
getafi:
	ld	ix,fifou0
	call	fstat			; queue status
	call	z,srxrsm		; if empty ensure rx is unlocked
getafil:
	call	fstat			; queue status
	jr	z,getafil		; loop until char is ready
	di
	call	fout			; get a character from the queue
	ei
	ld	a,c 			; and put it in correct register
	cp	esc
	jr	z,getann
	cp	'['
	jr	z,getann

getan1:
	ld	hl,asqbuf		; setup string
	ld	b,(hl)
	inc	b
	ld	(hl),b
	ld	c,b			; save len on c
getan2:
	inc	hl
	djnz	getan2			; position in buffer

	ld	(hl),a			; write
	inc	hl
	ld	(hl),0			; terminate

	ld	a,c			; check buffer capacity
	cp	8			; 8 char max
	jr	nc,getax		; error

	ld	a,(aqterm)		; in query
	dec	hl
	cp	(hl)			; last chr rec.
	jp	nz,getann		; stay here until query term

	xor	a
	ld	(hl),a
getax:
	xor	a
	ld	(asqbuf),a
	ld	ix,fifou0
	call	fstat			; queue status
	call	z,srxrsm		; if empty unlock rx

	pop	ix
	ret

	if ansidrv			; ANSI driver for serial console
;;
;; TXCHAR print out the char in reg C
;; with full evaluation of legacy escape sequences
;; translated into ANSI equivalents for serial console
;;
;; register clean: can be used as CP/M BIOS replacement
;;
txchar0:
	push	af
	push	bc
	push	de
	push	hl
	; force jump to register restore and exit in stack
	ld	hl,txcexit
	push	hl
	;
	ld	a,c
	ld	hl,tmpbyte
	bit	4,(hl)			; plain serial i/o ?
	jr	nz,txjp3		; yes. transmit as-is
	ld	hl,miobyte
	bit	7,(hl)			; alternate char processing ?
	ex	de,hl
	jr	nz,txcou2		; yes: do alternate
	cp	$20			; no: is less then 0x20 (space) ?
	jr	nc,txjp1		; no: go further
	add	a,a			; yes: is a special char
	ld	h,0
	ld	l,a
	ld	bc,txvec1
	add	hl,bc
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	jp	(hl)			; jump to TXVEC1 handler
txjp1:	ex	de,hl
	bit	6,(hl)			; auto ctrl chars ??
	jr	z,txjp2			; no
	cp	$40			; yes: convert
	jr	c,txjp2
	cp	$60
	jr	nc,txjp2
	sub	$40
	jr	txjp3
txjp2:	cp	$c0			; is semigraphic ?
	jr	c,txjp3			; no
	sub	$c0			; to table offset
	ld	h,0
	ld	l,a
	ld	bc,eqcp437
	add	hl,bc
	ld	c,(hl)
txjp3:	call	dotxchar		; display char
	ret
txcou2:					; alternate processing....
	cp	$20			; is a ctrl char ??
	jr	nc,acradr		; no: will set cursor pos
	add	a,a			; yes
	ld	h,0
	ld	l,a
	ld	bc,txvec2
	add	hl,bc
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	jp	(hl)			; jump to service routine... (TXVEC2)
;; cursor addressing service routine
;; address is ESC + (COL # + 32) + (ROW # + 32) (then need a NUL to terminate...)
;; will be: CSI (ESC,[) + row + ';' + col + 'H'
acradr:	ld	hl,tmpbyte
	bit	0,(hl)
	jr	nz,rowset
	cp	$70			; greater then 80 ?
	ret	nc			; yes: error
	sub	$1f			; no: ok
	ld	(appbuf),a		; store column
	set	0,(hl)			; switch row/col flag
	ret
rowset:	cp	$39			; greater than 24 ?
	ret	nc			; yes: error
	sub	$1f			; no: ok
	res	0,(hl)			; resets flags
	ld	hl,miobyte
	res	7,(hl)			; done reset
	ld	d,a			; load row
	ld	e,';'
	call	seqemit			; and send
	ld	a,(appbuf)		; load column
	ld	d,a
	ld	e,'H'
	call	seqpar			; and send
	pop	hl			; clean stack
txcexit:
	pop	hl
	pop	de
	pop	bc
	pop	af
	ret

csiemit:
	ld	b,2
	ld	hl,csi
csich:	ld	c,(hl)
	call	dotxchar
	inc	hl
	djnz	csich
	ret

seqemit:
	call	csiemit			; send CSI
seqpar:	ld	a,d			; sequence parameter in D
	cp	$ff			; null, skip it
	jr	z,seqcmd
	or	a			; zero ?
	jr	z,seqzer
	ld	b,a			; convert to BCD
	xor	a
sqdaa:	inc	a
	daa
	djnz	sqdaa
	ld	d,a
	and	$f0			; hi nibble
	srl	a
	srl	a
	srl	a
	srl	a
	add	a,'0'
	call	seqchr			; send over
	ld	a,d			; reload parameter
	and	$0f			; lo nibble
seqzer:	add	a,'0'
	call	seqchr
seqcmd:	ld	a,e			; sequence command in E
	cp	$ff			; null, skip it
	jr	z,seqend
	jr	seqchr			; ...and send this too
seqend:	ret

seqchr:	ld	c,a			; send
	call	dotxchar
	ret

csi:	defb	esc,'['


;; This table define the offsets to jump to translation routines
;; for primary (non-escaped) mode

txvec1:
	dw	riocesc			; NUL 0x00 (^@)  clear alternate output processing
	dw	ucasemod		; SOH 0x01 (^A)  uppercase mode
	dw	lcasemod		; STX 0x02 (^B)  normal case mode
	dw	txnull			; ETX 0x00 (^C)  no-op
	dw	acurof			; EOT 0x04 (^D)  cursor off
	dw	acuron			; ENQ 0x05 (^E)  cursor on
	dw	txnull			; ACK 0x06 (^F)  locate cursor at CURPBUF
	dw	txbel			; BEL 0x07 (^G)  beep
	dw	amvlft			; BS  0x08 (^H)  cursor left (destr. and non destr.)
	dw	txnull			; HT  0x09 (^I)  no-op
	dw	txlf			; LF  0x0a (^J)  cursor down one line
	dw	achome			; VT  0x0b (^K)  cursor @ column 0
	dw	acls			; FF  0x0c (^L)  page down (clear screen)
	dw	txcr			; CR  0x0d (^M)  provess CR
	dw	acleop			; SO  0x0e (^N)  clear to EOP
	dw	acleol			; SI  0x0f (^O)  clear to EOL
	dw	txnull			; DLE 0x10 (^P)  no-op
	dw	aresatr			; DC1 0x11 (^Q)  reset all attributes
	dw	txnull			; DC2 0x12 (^R)  hard crt reset and clear
	dw	txnull			; DC3 0x13 (^S)  no-op
	dw	txnull			; DC4 0x14 (^T)  no-op
	dw	amvup			; NAK 0x15 (^U)  cursor up one line
	dw	txnull			; SYN 0x16 (^V)  scroll off
	dw	txnull			; ETB 0x17 (^W)  scroll on
	dw	amvlftnd		; CAN 0x18 (^X)  cursor left (non destr. only)
	dw	amvrgt			; EM  0x19 (^Y)  cursor right
	dw	amvdwn			; SUB 0x1a (^Z)  cursor down one line
	dw	siocesc			; ESC 0x1b (^[)  activate alternate output processing
	dw	txnull			; FS  0x1c (^\)  no-op
	dw	txnull			; GS  0x1d (^])  no-op
	dw	txnull			; RS  0x1e (^^)  disabled (no-op)
	dw	txnull			; US  0x1f (^_)  no-op

;; This table define the offsets to jump to translation routines
;; for alternate (escaped) mode

txvec2:
	dw	riocesc			; NUL 0x00 (^@)  clear alternate output processing
	dw	ablnkof			; SOH 0x01 (^A)  BLINK OFF
	dw	ablnkon			; STX 0x02 (^B)  BLINK ON
	dw	aundrof			; ETX 0x03 (^C)  UNDER OFF
	dw	aundron			; EOT 0x04 (^D)  UNDER ON
	dw	ahlitof			; ENQ 0x05 (^E)  HLIGHT OFF
	dw	ahliton			; ACK 0x06 (^F)  HLIGHT ON
	dw	txnull			; BEL 0x07 (^G)  no-op
	dw	txnull			; BS  0x08 (^H)  no-op
	dw	txnull			; HT  0x09 (^I)  no-op
	dw	txnull			; LF  0x0a (^J)  no-op
	dw	txnull			; VT  0x0b (^K)  no-op
	dw	acls			; FF  0x0c (^L)  blank screen
	dw	riocesc			; CR  0x0d (^M)  clear alternate output processing
	dw	aredon			; SO  0x0e (^N)  set bit 5 RAM3BUF (red)
	dw	awhton			; SI  0x0f (^O)  res bit 5 RAM3BUF (red)
	dw	agrnon			; DLE 0x10 (^P)  set bit 6 RAM3BUF (green)
	dw	awhton			; DC1 0x11 (^Q)  res bit 6 RAM3BUF (green)
	dw	txnull			; DC2 0x12 (^R)  cursor blink slow block
	dw	txnull			; DC3 0x13 (^S)  cursor blink slow line
	dw	txnull			; DC4 0x14 (^T)  no-op
	dw	txnull			; NAK 0x15 (^U)  no-op
	dw	txnull			; SYN 0x16 (^V)  no-op
	dw	sascfltr		; ETB 0x17 (^W)  set ascii filter
	dw	rascfltr		; CAN 0x18 (^X)  reset ascii filter
	dw	ndbksp			; EM  0x19 (^Y)  set non destructive BS
	dw	dbksp			; SUB 0x1a (^Z)  set destructive BS
	dw	arevson			; ESC 0x1b (^[)  REVERSE ON
	dw	arevsof			; FS  0x1c (^\)  REVERSE OFF
	dw	abluon			; GS  0x1d (^])  set bit 7 RAM3BUF (blue)
	dw	awhton			; RS  0x1e (^^)  res bit 7 RAM3BUF (blue)
	dw	txnull			; US  0x1f (^_)  no-op

;;
;; ANSI ESCapes specific routines
;;
;; no comments on code below but it should be quite intuitive

txnull:
	ret

txcr:
	ld	c,cr
	jp	dotxchar

txlf:
	ld	c,lf
	jp	dotxchar

txbksp:
	ld	c,$08
	jp	dotxchar

txbel:
	ld	c,$07
	jp	dotxchar

amvlft:
	ld	hl,miobyte
	bit	4,(hl)
	jr	nz,amvlftnd
	jr	txbksp

acurof:					; CSI ?25l
	deseq	$ff,'?'
	call	seqemit
	deseq	25,'l'
	call	seqpar
	ret

acuron:					; CSI ?25h
	deseq	$ff,'?'
	call	seqemit
	deseq	25,'h'
	call	seqpar
	ret

amvlftnd:
	deseq	$ff,'D'			; CSI n D
	jr	dosnd1

amvdwn:
	deseq	$ff,'B'			; CSI n B
	jr	dosnd1

amvup:
	deseq	$ff,'A'			; CSI n A
	jr	dosnd1

amvrgt:
	deseq	$ff,'C'			; CSI n C
	jr	dosnd1

achome:					; CSI 0 G
	deseq	0,'G'
	jr	dosnd1

acls:					; CSI 2 J
	deseq	2,'J'
	call	seqemit
	deseq	$ff,'H'
	jr	dosnd1

acleop:					; CSI 0 J
	deseq	0,'J'
	jr	dosnd1

acleol:					; CSI 0 K
	deseq	0,'K'
	jr	dosnd1

aresatr:				; CSI 0 m
	deseq	0,'m'
	jr	dosnd1

ablnkof:				; CSI 25 m
	deseq	25,'m'
	jr	dosnd1

ablnkon:				; CSI 5 m
	deseq	5,'m'
	jr	dosnd1

arevsof:				; CSI 27 m
	deseq	27,'m'
	jr	dosnd1

arevson:				; CSI 7 m
	deseq	7,'m'
	jr	dosnd1


aundrof:				; CSI 24 m
	deseq	24,'m'
	jr	dosnd1

aundron:				; CSI 4 m
	deseq	4,'m'
	jr	dosnd1

ahlitof:				; CSI 22 m
	deseq	22,'m'
	jr	dosnd1

ahliton:				; CSI 1 m
	deseq	1,'m'
	jr	dosnd1

aredon:					; CSI 31 m
	deseq	31,'m'
	jr	dosnd1

agrnon:					; CSI 32 m
	deseq	32,'m'
	jr	dosnd1

abluon:					; CSI 34 m
	deseq	34,'m'
	jr	dosnd1

awhton:					; CSI 37 m
	deseq	37,'m'
	jr	dosnd1

dosnd1:	call	seqemit
	ret

; keyboard translation table

nakeys	equ	22

		; sequences emitted upon reception of valid
		; keyboard input and valid sequences expected
ansikeys:	; on keyboard input
	defb	$00,$7f		; DEL
	defb	2,"3~"
	defb	$00,$16		; INS
	defb	2,"2~"
	defb	$00,$1d		; HOME
	defb	1,"H"
	defb	$00,$14		; END
	defb	1,"F"
	defb	$00,$13		; PGUP
	defb	2,"5~"
	defb	$00,$07		; PGDN
	defb	2,"6~"
	defb	$00,$15		; UP
	defb	1,"A"
	defb	$00,$1a		; DOWN
	defb	1,"B"
	defb	$00,$18		; LEFT
	defb	1,"D"
	defb	$00,$19		; RIGHT
	defb	1,"C"
	defb	$1b,'A'		; F1 ...
	defb	1,"P"
	defb	$1b,'B'
	defb	1,"Q"
	defb	$1b,'C'
	defb	1,"R"
	defb	$1b,'D'
	defb	1,"S"
	defb	$1b,'E'
	defb	3,"15~"
	defb	$1b,'F'
	defb	3,"17~"
	defb	$1b,'G'
	defb	3,"18~"
	defb	$1b,'H'
	defb	3,"19~"
	defb	$1b,'I'
	defb	3,"20~"
	defb	$1b,'J'
	defb	3,"21~"
	defb	$1b,'K'
	defb	3,"23~"
	defb	$1b,'L'		; ... F12
	defb	3,"24~"

	; This table define (possible) equivalence from NEZ80 character ROMs
	; and Code Page 437.
	; Note that final rendering on remote is really dependent from IT'S font usage
	; 1) we consider only chars from $C0 to $FF
	; 2) no equivalents from $81 to $BF

eqcp437:
	defb	179,196,197,195,180,194,193,192,217,218,191,186,205,206,204,185
	defb	203,202,200,188,201,187,198,181,210,208,214,183,211,189,213,184
	defb	212,190,199,182,209,207,215,216,025,026,006,003,004,005,156,157
	defb	178,176,224,225,046,235,231,046,239,046,046,237,228,046,234,227


	endif


;----- EOF -----





