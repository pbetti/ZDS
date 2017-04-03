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

bbjtobnk macro 	bnknum, raddr
	call	bbexec
	defw	raddr
	defb	bnknum
	endm

	; select register form uart.
	; similar to banked, exported macro but used in ISR
crdureg	macro	uregister
	ld	a,b		; B is uart id
	add	a,uregister
	ld	c,a
	in	a,(c)
	endm

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
	public	bbepmngr, bbeidck

	; Resident routines
	public	delay, mmpmap, mmgetp, bbconst
	public	bbconin, bbconout, rldrom

	; Interrupts vector table & mngmt
	public	sintvec, intren, intrdi, fstat
	public	fout, srxstp, srxrsm

;-------------------------------------
; Internal BIOS calls

bbcrtcini:	bbjtobnk 1, crtcini
bbcrtfill:	bbjtobnk 1, crtfill
vconout:	bbjtobnk 1, bconout
vconin:		bbjtobnk 1, bconin
vconst:		bbjtobnk 1, bconst
bbcurset:	bbjtobnk 1, curset
sconout:	bbjtobnk 1, txchar0
sconin:		bbjtobnk 1, rxchar0
sconst:		bbjtobnk 1, ustatus0
bbu0ini:	bbjtobnk 1, iniuart0
bbu1tx:		bbjtobnk 1, txchar1
bbu1rx:		bbjtobnk 1, rxchar1
bbu1st:		bbjtobnk 1, ustatus1
bbu1ini:	bbjtobnk 1, iniuart1
bbinictc:	bbjtobnk 1, inictc
bbresctc:	bbjtobnk 1, resctc

bbpsndblk:	bbjtobnk 2, psndblk
bbuplchr:	bbjtobnk 2, uplchr
bbprcvblk:	bbjtobnk 2, prcvblk
bbrdvdsk:	bbjtobnk 2, vdskrd
bbwrvdsk:	bbjtobnk 2, vdskwr
bbfhome:	bbjtobnk 2, fhome
bbfread:	bbjtobnk 2, fread
bbfwrite:	bbjtobnk 2, fwrite
bbflopio:	bbjtobnk 2, flopio
bbprnchr:	bbjtobnk 2, prnchr
bbsttim:	bbjtobnk 2, sttim
bbrdtime:	bbjtobnk 2, rdtime
bbtrkset:	bbjtobnk 2, trkset
bbsecset:	bbjtobnk 2, secset
bbdmaset:	bbjtobnk 2, dmaset
bbdsksel:	bbjtobnk 2, dsksel
bbcpboot:	bbjtobnk 2, cpmboot
bbvcpmbt:	bbjtobnk 2, vcpmbt
bbsidset:	bbjtobnk 2, sidset
bbfdrvsel:	bbjtobnk 2, fdrvsel
bbdiv16:	bbjtobnk 2, div16
bbmul16:	bbjtobnk 2, mul16
bboffcal:	bbjtobnk 2, offcal
bbhdinit:	bbjtobnk 2, hdinit
bbdriveid:	bbjtobnk 2, driveid
bbhdwr:		bbjtobnk 2, writesector
bbhdrd:		bbjtobnk 2, readsector
bbhdgeo:	bbjtobnk 2, gethdgeo
bbhdboot:	bbjtobnk 2, hdcpm
bbldpart:	bbjtobnk 2, getptable
bbdprmset:	bbjtobnk 2, setdprm

bbepmngr:	bbjtobnk 3, epmanager
bbeidck:	bbjtobnk 3, eidcheck

;;
;; Switch bank and jump
;;

bbexec:
	di				; protect bank switch
	exx				; save registers
	ex	af,af'
	ex	(sp),hl
	pop	de			; remove call to us from stack

	ld	b,bbpag	<< 4		; where we are ?
	ld	c,mmuport
	in	a,(c)
	ld	(bbcbank),a		; save current bank

	ld	e,(hl)			; E low byte of called routine
	inc	hl			; and
	ld	d,(hl)			; hi byte. DE = routine address
	inc	hl
	ld	l,(hl)			; routine bank in L
	ld	a,(hmempag)		; calculate destination bank
	sub	a,l
	out	(c),a			; and switch to it

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
	ret
;
;; FOUT
;; routine to retreve a character from a buffer.
;; enter with IC=.cnt
;; return with C=chr
;
fout:
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
	ld	b,uart0
uisri:	crdureg	r5lsr			; read status
	bit	0,a			; data available in rx buffer?
	jr	z,uisre			; no.
	ld	c,b
	in	c,(c)			; read data
	ld	ix,fifou0		; select our fifo
	call	fstat			; chek for room in it
	jr	c,uisre			; throw away character if queue full
	call	fin			; insert
	jr	uisri			; repeat for more data in UART (not local) fifo
uisre:
	pop	ix			; reg. restore
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
	ld	c, uart0+r5lsr
tx01:
	in	a,(c)			; read status
	bit	5,a			; ready to send?
	jp	z,tx01			; no, retry.
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
; SYCRES:	DEFW	0
uastkb:	defs	10
uastak	equ	$

bbstbase:
	defs	36
bbstack:
syscmlo:
	defs	syscommon + $03ff - syscmlo - 15

sintvec:				; interrupts vector table (8 entries)
	defw	voidisr			; CTC - chan. 0
	defw	sytimr			; CTC - chan. 1 sys timer
	defw	u1isr			; CTC - chan. 2 uart 1
	defw	u0isr			; CTC - chan. 3 uart 0
	defs	16 - 8

; SYSCMHI:
; 	DEFB	0

;
; end of code - this will fill with zeroes to the end of
; the image


if	mzmac
wsym syscommon.sym
endif
;
;
	end
;
