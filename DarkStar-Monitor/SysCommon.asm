;
;=======================================================================
;
; Modular Z80 DarkStar (NE Z80) Monitor
;
;=======================================================================
;
; Original code:
; Z80 Nuova Elettronica Monitor 390 su eprom 2532 (4k)
;
; Disassembled and reconstructed by
; Piergiorgio Betti <pbetti@lpconsul.net> on 2005 01 26
;
; Latest non modular BIOS is DARKSTAR-MONITOR-0.9.0.asm
; dated 20140531
; - Following addition of MultiF-Board doing complete rewrite of the
;   monitor/BIOS has been started.
;   Major goals:
;   o Modularization: Now monitor can grow up to 256kb instead of 4kb
;     :-)
;   o Specialized images fitted in memory page (4kb) or multiples
;   o Full support for new hardware
;   o I/O rewrite for MODE 2 interrupts
;   Minor goals:
;   o Full code clean-up & reorganization
; ---------------------------------------------------------------------

;-------------------------------------
; Common equates for BIOS/Monitor

include Common.inc.asm
;-------------------------------------
; Symbols from parent sub-pages
include sysbios.equ

;-------------------------------------
; Some macro

bbjbnk_1 macro	raddr
	call	bbexec1
	defw	raddr
endm

bbjbnk_2 macro	raddr
call	bbexec2
defw	raddr
endm

bbjbnk_3 macro	raddr
	call	bbexec3
	defw	raddr
endm

;-------------------------------------

	cseg

	name	'SYSCMN'

syscommon	equ	$		; start of resident BIOS
syscom:

	; safe reload, something goes wrong if we are here

	jp	rldrom

	;----------------
	; Banked routines

	; SYSBIOS1
	public	bbcrtcini, bbcrtfill, vconout, vconin
	public	vconst, bbcurset
	public	bbu0ini, bbu1ini, sconout, sconin
	public	sconst, bbu1rx, bbu1tx, bbu1st

	; SYSBIOS2
	public	bbfwrite, bbflopio, bbfhome, bbfread
	public	bbsidset, bbfdrvsel, bbdprmset

	public	bbwrvdsk, bbuplchr, bbrdvdsk, bbpsndblk
	public	bbprcvblk, bbprnchr

	public	bbtrkset, bbsecset, bbdmaset, bbdsksel
	public	bbcpboot, bbvcpmbt

	public	bbdiv16, bbmul16, bboffcal
	public	bbsttim, bbrdtime

	public	bbhdinit, bbdriveid, bbhdgeo
	public	bbhdrd, bbhdwr, bbhdboot, bbldpart

	; SYSBIOS3
	public	bbeidck, bbepmngr

	; Resident routines
	public	delay, mmpmap, mmgetp, bbconst
	public	bbconin, bbconout, rldrom
	public	dispch, movrgt, eostest, cout00
	public	scrtst, updvidp, scrspos
	public	bbscroll

	; Interrupts vector table & mngmt
	public	sintvec, intren, intrdi, fstat
	public	fout, srxstp, srxrsm

	;::::::::::::::::::::::::::::::::::::::::::::::::::::::
	;:: Please note: bios bank switch is not reentrant!  ::
	;:: You CAN'T call a banked routine resident in your ::
	;:: own bank.                                        ::
	;::::::::::::::::::::::::::::::::::::::::::::::::::::::

;-------------------------------------
; Internal BIOS calls

bbcrtcini:	bbjbnk_1 crtcini
bbcrtfill:	bbjbnk_1 crtfill
vconin:		bbjbnk_1 bconin
vconst:		bbjbnk_1 bconst
bbcurset:	bbjbnk_1 curset
sconout:	bbjbnk_1 txchar0
sconin:		bbjbnk_1 rxchar0
sconst:		bbjbnk_1 ustatus0
bbu0ini:	bbjbnk_1 iniuart0
bbu1tx:		bbjbnk_1 txchar1
bbu1rx:		bbjbnk_1 rxchar1
bbu1st:		bbjbnk_1 ustatus1
bbu1ini:	bbjbnk_1 iniuart1
bbinictc:	bbjbnk_1 inictc
bbresctc:	bbjbnk_1 resctc
bbscroll:	bbjbnk_1 scroll
bbconou2:	bbjbnk_1 vconou2

bbpsndblk:	bbjbnk_2 psndblk
bbuplchr:	bbjbnk_2 uplchr
bbprcvblk:	bbjbnk_2 prcvblk
bbrdvdsk:	bbjbnk_2 vdskrd
bbwrvdsk:	bbjbnk_2 vdskwr
bbfhome:	bbjbnk_2 fhome
bbfread:	bbjbnk_2 fread
bbfwrite:	bbjbnk_2 fwrite
bbflopio:	bbjbnk_2 flopio
bbprnchr:	bbjbnk_2 prnchr
bbsttim:	bbjbnk_2 sttim
bbrdtime:	bbjbnk_2 rdtime
bbtrkset:	bbjbnk_2 trkset
bbsecset:	bbjbnk_2 secset
bbdmaset:	bbjbnk_2 dmaset
bbdsksel:	bbjbnk_2 dsksel
bbcpboot:	bbjbnk_2 cpmboot
bbvcpmbt:	bbjbnk_2 vcpmbt
bbsidset:	bbjbnk_2 sidset
bbfdrvsel:	bbjbnk_2 fdrvsel
bbdiv16:	bbjbnk_2 div16
bbmul16:	bbjbnk_2 mul16
bboffcal:	bbjbnk_2 offcal
bbhdinit:	bbjbnk_2 hdinit
bbdriveid:	bbjbnk_2 driveid
bbhdwr:		bbjbnk_2 writesector
bbhdrd:		bbjbnk_2 readsector
bbhdgeo:	bbjbnk_2 gethdgeo
bbhdboot:	bbjbnk_2 hdcpm
bbldpart:	bbjbnk_2 getptable
bbdprmset:	bbjbnk_2 setdprm

bbepmngr:	bbjbnk_3 epmanager
bbeidck:	bbjbnk_3 eidcheck
; -- new --

;;
;; Switch bank and jump
;;

bbexec3:
	ex	af,af'			; save af
	ld	a,3			; bank 3
	jr	bbexec
bbexec2:
	ex	af,af'			; save af
	ld	a,2			; bank 2
	jr	bbexec
bbexec1:
	ex	af,af'			; save af
	ld	a,1			; bank 1
bbexec:
	di				; protect bank switch
	exx				; save registers
	ex	(sp),hl
	pop	bc			; remove call to us from stack
	ld	d,a			; remember bank

	ld	b,bbpag	<< 4		; where we are ?
	ld	c,mmuport
	in	a,(c)
	ld	(bbcbank),a		; save current bank

	ld	e,(hl)			; E low byte of called routine
	inc	hl			;
	ld	h,(hl)			; H high byte of called routine
	ld	a,(hmempag)		; calculate destination bank
	sub	a,d			; A phisical bank
	ld	d,h			; DE routine address
	out	(c),a			; bank switch

	ld	(bbcstck),sp
	ld	hl,(bbcstck)		; save current stack pointer
	ld	sp,bbstack		; and use local stack for i/o
	push	hl			; push old stack on new
	ld	a,(bbcbank)		; reload old bank
	push	af			; and push on stack

	ei				; ready to run
	ld	hl,bbcalret		; routine return forced to BBCALRET
	push	hl			; so put it on stack
	push	de			; routine address also on stack
	exx				; restore registers as on entry
	ex	af,af'

	ret				; dispatch to banked part of routine

;;
;; arrive here after called routine finished
;;
bbcalret:
	di
	exx
	ex	af,af'
	ld	b,bbpag << 4
	ld	c,mmuport
	pop	af			; old bank
	pop	hl			; old stack
	out	(c),a			; restore bank
	ld	sp,hl			; restore previous stack
	exx				; restore output register
	ex	af,af'
	ei				; reenable interrupts
	ret				; and return...

;;
;; Unused / fake handle
;;
bbvoid:
	ret

;-------------------------------------
; NON-banked common routines follow...

;;
;; Map page into logical space
;;
;; A - physical page (0-ff)
;; B - logical page (0-f)
;; Use C
;;
mmpmap:
	sla	b
	sla	b
	sla	b
	sla	b
	ld	c,mmuport
	out	(c),a
	ret

;;
;; Get physical page address
;;
;; B - logical page (0-f)
;; A - return page number
;; Use C
;;
mmgetp:
	sla	b
	sla	b
	sla	b
	sla	b
	ld	c,mmuport
	in	a,(c)
	ret

;;
;; DELAY
;;
;; This routine generate a delay from 1 to 65535 milliseconds.
;;

mscnt	equ	246

delay:
	push	bc		; 11 c.
	push	af		; 11 c.
dly2:
	ld	c, mscnt	; 7 c.	(assume de = 1 = 1msec.)
dly1:
	dec	c		; 4 c. * MSCNT
	jr	nz, dly1	; 7/12 c. * MSCNT
	dec	de		; 6 c.
	ld	a, d		; 4 c.
	or	e		; 4 c.
	jr	nz, dly2	; 7/12 c.

	pop	af		; 10 c.
	pop	bc		; 10 c.
	ret			; 10.c

;; MSEC evaluation (ret ignored):
;
; 42 + (de) * (7 + 16 * MSCNT - 5 + 26) - 5
;
; 65 + 16 * MSCNT = ClockSpeed   (ClockSpeed is 1920 for Z80 DarkStar)
; (ClockSpeed - 65) / 16 = MSCNT = 116
; 2006/04/09:
; clock speed has been increased to 4MHz so now:
; (ClockSpeed - 65) / 16 = MSCNT = 116
; is
; (4000 - 65) / 16 = 246 = MSCNT
;

; ---------------------------------------------------------------------
; Console redirection

bbconin:
	ld	a,(miobyte)		; conf. location
	bit	5,a
	jp	z,vconin		; video
	jp	sconin			; serial

bbconout:
	ld	a,(miobyte)		; conf. location
	bit	5,a
	jp	z,vconout		; video
	jp	sconout			; serial

bbconst:
	ld	a,(miobyte)		; conf. location
	bit	5,a
	jp	z,vconst		; video
	jp	sconst			; serial

;
; VCONOUT print out the char in reg C
; with full evaluation of control chars
;
; register clean: can be used as CP/M BIOS replacement
;
vconout:
	push	af			; clean register usage
	push	bc
	push	de
	push	hl
					; force jump to register restore and exit in stack
	ld	hl,vbcexit
	push	hl
	;
	ld	b,0			; assume standard ctrl (if it is)
	ld	a,c
	ld	hl,miobyte
	bit	7,(hl)			; alternate char processing active ?
	ex	de,hl
	jr	nz,vc00			; yes, do alternate
	inc	b			; no
	cp	$20			; no: but is less then 0x20 (ctrl) ?
	jr	nc,vc01			; no: go further
vc00:
	call	bbconou2		; yes: do processing
	ret
vc01:
	call	dispch			; display char
					; move cursor right
movrgt:
	ld	hl,(curpbuf)		; get cursor position
	inc	hl			; to next char

eostest:
	call	scrtst			; end of screen ?
	jr	c,cout00		; no
	ld	de,0ffb0h		;
	add	hl,de			;
	call	bbscroll		; update display start (scrolling)

cout00:
	ld	(curpbuf),hl		; save video pointer
	call	updvidp			; update video pointer
	ret

vbcexit:
	pop	hl			; clean exit...
	pop	de
	pop	bc
	pop	af
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
;; SCRTST - Verify if we need video scroll
;
scrtst:
	ld	de,endvid+1		; DE = end video + 1
	xor	a			; clear carry
	sbc	hl,de			; subctract and set carry
	add	hl,de			; restore hl
	ret				; and ret

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
	ld	a,vr31.dummy
	out	(crt6545adst),a
	ret

;************************************************************************
;    FIFO BUFFERS FOR CP/M BIOS
;
; The following code by Glenn Ewing and Bob Richardson
; This code Copyright (c) 1981 MicroPro International Corp.
; made available by permission of the authors
;
;	The fifo input and output routines provide no protection
;	from underflow and overflow.  The calling code must use
;	the fstat routine to ensure that these conditions are
;	avoided.  Also, the calling code must enable and disable
;	interupts as appropriate to ensure proper maintainance of
;	the variables.
;
;; FSTAT
;; routine to determine status (fullness) of a buffer.
;; enter with IX = adr of cnt.
;; return Z-flag set if buffer empty, C-flag set if buffer full.
;; note that buffer capacity is actually size-1.
;
fstat:
	ld	a, (ix + 0)		; get cnt
	push	de
	ld	e, (ix + 2)		; get mask
	and	e			; cnt = cnt mod size
	dec	e			; e = size - 2
	cp	e			; test for full
	pop	de
	inc	a			; clear z leaving cy
	dec	a
	ccf
	ret
;
;; FIN
;; routine to enter a character into a buffer.
;; enter with C=chr, IX=.cnt
fin:
	push	ix
	ld	a, (ix + 0)		; compute: (cnt + nout) mod size
	inc	(ix + 0)		; first update cnt
	add	a, (ix + 1)
	and	(ix + 2)
	push	de
	ld	e, a			; compute base + nin
	ld	d, 0
	inc	ix
	inc	ix
	inc	ix
	add	ix, de
	pop	de
	ld	(ix+0), c		; store character
	pop	ix
	ret
;
;; FOUT
;; routine to retreve a character from a buffer.
;; enter with IC=.cnt
;; return with C=chr
;
fout:
	push	ix
	dec	(ix + 0)		; update cnt
	ld	a, (ix + 1)		; compute: base + nout
	inc	(ix + 1)
	and	(ix + 2)
	push	de
	ld	e, a
	ld	d, 0
	inc	ix
	inc	ix
	inc	ix
	add	ix, de
	pop	de
	ld	c, (ix + 0)		; get chr
	pop	ix
	ret

;************************************************************************

;
;-------------------------------------
; ISRs

;;
;; Interrupts enable / setup
;;
intren:
	di
	im	2
	ld	a,$ff
	ld	i,a
	call	bbinictc
	; will call keyboard ini when available
	ld	hl,tmpbyte
	set	5,(hl)			; flag interrupts on
	ei
	ret

	;;
;; Interrupts disable
;;
intrdi:
	di
	call	bbresctc
	; will call keyboard res when available
	ld	hl,tmpbyte
	res	5,(hl)			; flag interrupts off
	ret

;;
;; System timer
;;
sytimr:
	push	af
	ld	a,(timrcon)
	inc	a
	ld	(timrcon),a
	pop	af

	; fall through
;;
;; Void ISR
;;
voidisr:
	ei
	reti

;;
;; Uart 0 receiver
;;
u0isr:
	ld	(uastav),sp		; private stack
	ld	sp,uastak
	push	af			; reg. save
	push	bc
	push	ix
	call	srxstp			; lock rx
	ld	ix,fifou0		; select our fifo
uisri:
	call	fstat			; chek for room in it
	jr	c,uisre			; full, wait for space

	in	a,(uart0+r5lsr)		; read status
	bit	0,a			; data available in rx buffer?
	jr	z,uisrs			; no, emtpy, exit

	in	a,(uart0+r0rxtx)	; read data
	ld	c,a
	call	fin			; put in local fifo

	jr	uisri			; repeat for more data in UART fifo
uisrs:
	call	srxrsm
uisre:
	pop	ix
	pop	bc
	pop	af
	ld	sp,(uastav)
	ei
	reti


;;
;; Uart 1 receiver
;;
u1isr:
	push	af
	ld	a,(cnfbyte)
	bit	0,a			; check for intr redir on rst8
	jr	z,u1nul			; ignore interrupt
	rst	8			; redirect to user handler
u1nul:
	pop	af
	ei
	reti

;;
;;	Lock RX on UART0
;
srxstp:
	ld	b,xofc
	jr	dostx

;;
;;	Unlock RX on UART0
;
srxrsm:
	ld	b,xonc
dostx:
	ld	a,(cnfbyte)
	bit	1,a			; xon/xoff enabled ?
	ret	z			; no
	jr	tx0


;;
;; mini tx on uart 0
;;
;; B: output char

tx0:
	in	a,(uart0+r5lsr)		; read status
	bit	5,a			; ready to send?
	jp	z,tx0			; no, retry.
	ld	c, uart0+r0rxtx
	out	(c),b
	ret


;---------------------------------------------------------------------

;;
;; Reentry routine for safe jump to sysbios base page
rldrom:
	ld	b,bbpag << 4		; select bios space
	ld	c,mmuport
	ld	a,eepage0		; remount rom and start again
	out	(c),a
	jp	bbpag << 12

;
;-------------------------------------
; Storage
uastav:	defw	0
uastkb:	defs	12
uastak	equ	$

bbstbase:
	defs	36
bbstack:
syscmlo:
	defs	syscommon + $03ff - syscmlo - 15

sintvec:				; interrupts vector table (8 entries)
	vi0:	defw	voidisr			; CTC - chan. 0
	vi1:	defw	sytimr			; CTC - chan. 1 sys timer
	vi2:	defw	u1isr			; CTC - chan. 2 uart 1
	vi3:	defw	u0isr			; CTC - chan. 3 uart 0
	vi4:	defw	voidisr			; unused
	vi5:	defw	voidisr			; unused
	vi6:	defw	voidisr			; unused
	vi7:	defw	voidisr			; unused


if	mzmac
wsym syscommon.sym
endif
;
;
	end
;
