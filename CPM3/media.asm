;
;=======================================================================
;
; CP/M 3 Z80 DarkStar (NE Z80) Porting
;
;=======================================================================
;;---------------------------------------------------------------------
;; Version      : 1.0 - 20140904
;; Assemble     : SLR z80asm
;; Revisions:
;; 20140915	- Code start
;; 20180825	- removed debug code
;;		- lowecased
;;---------------------------------------------------------------------

	TITLE	'MEDIA MODULE FOR CP/M 3.1'

	.z80

	; define logical values:
	include	common.inc
	include syshw.inc


	; define public labels:
	public	hdvoid, fddvoid
	public	hrdvdsk, hwrvdsk, hdvlog
	public	iderddsk, idewrdsk, idelogin
	public	fddrd, fddwr, fddlog

	extrn	@bios$stack
	if banked
	extrn	@cbnk, @dbnk, ?bank
	endif



	; not all in common segment...
;-------------------------------------------------------
; possibly banked routines (entry points)
;-------------------------------------------------------

	if banked
	dseg
	endif

fddvoid:
hdvoid:					; void routine
	ret

	; login floppies
fddlog:
	push	hl
	push	de
	ld	hl,(flsecs)
	ld	de,(flsecs+2)
	jr	hdvlo0

	; login virtual hd
hdvlog:
	push	hl
	push	de
	ld	hl,(hdsecs)
	ld	de,(hdsecs+2)
hdvlo0:
	call	bbdprmset
	pop	de
	pop	hl
	ret

	; wrapper for virtual hd read routine
hrdvdsk:
	push	ix
	call	hdvlog			; hd params
	jp	dohrdvd

	; wrapper for virtual hd write routine
hwrvdsk:
	push	ix
	call	hdvlog			; hd params
	jp	dohwrvd

	; wrapper for ide hd read routine
iderddsk:
	push	iy
	jp	doiderd

	; wrapper for ide hd write routine
idewrdsk:
	push	iy
	jp	doidewr

	; ide login			; disabled
idelogin:				; done once at boot
; 	ld	a,'3'
; 	ld	(copsys),a		; identify opsys for partitions
;
; 	call	bbhdinit		; ide init
; 	or	a
; 	jp	nz,ideerr
; 	call	bbldpart
	ret

	; floppy read routine
fddrd:
	push	ix
	call	fddlog
	ld	a,(fdrvbuf)		; get active drive
	cp	2			; is hw floppy ?
	jr	c,rdflo0		; yes
	jp	rdvrt			; no, then is a virtual drive
	;
	; floppy write routine
fddwr:
	push	ix
	call	fddlog
	ld	a,(fdrvbuf)		; get active drive
	cp	2			; is floppy ?
	jr	c,wrflo0		; yes
	jp	wrvrt			; no, then is a virtual drive

rdflo0:
	call	chksid			; side select
	call	bbfdrvsel		; activate drive
	jp	rdflo
wrflo0:
	call	chksid			; side select
	call	bbfdrvsel		; activate drive
	jp	wrflo

	;	test for side switch on floppies
	;
chksid:	ld	ix,flsecs		; chs infos
	ld	c,0			; side 0 by default
	ld	a,(ftrkbuf)		; get just the 8 bit part because we don't
					; have drivers with more than 255 tracks !!!
	cp	(ix+5)			; compare with physical (8 bit)
	jp	c,bbsidset		; track in range (0-39/0-79) ?
	ld	c,1			; no: side one
	sub	(ix+5)			; real cylinder on side 1
	ld	(ftrkbuf),a		; store for i/o ops
	jp	bbsidset		; ... and go to setsid

flsecs:	defw	11
	defw	512
	defb	2			; heads
	defw	80			; tracks
hdsecs:	defw	256
	defw	512

;-------------------------------------------------------
; possibly banked routines (re-entry from common seg)
;-------------------------------------------------------
vdret:
	pop	ix
	ret

	; adjust return value for floppies
fdret:
	pop	ix
	or	a
	jr	z,fdok
	xor	a
	inc	a
	ret
fdok:	xor	a
	ret

ideret:
	pop	iy
	or	a
	ret	z
	ld	a,1			; correct return value for bdos
	ret


;-------------------------------------------------------
; resident / non-banked part
;-------------------------------------------------------

	cseg

	; setup dma bank
dmabnk	macro
	if banked
	call	bnkset			; select bank for disk i/o
	endif
	endm

rstbnk	macro
	if banked
	call	bnkrst			; reselect old bank
	endif
	endm


	if banked
bnkset:
	ld	a,(@cbnk)
	ld	(bksave),a
	ld	a,(@dbnk)
	call	?bank			; really select bank for disk i/o
	ret

bnkrst:
	push	bc
	ld	b,a			; save return status
	ld	a,(bksave)
	call	?bank			; really reselect old bank
	ld	a,b
	pop	bc
	ret
; 	push	af
; 	ld	a,(bksave)
; 	call	?bank			; really reselect old bank
; 	pop	af
; 	ret
	endif

wrflo:
	dmabnk				; dma bank in place
	call	bbfwrite		; do write
	jr	rdflo1
	;
rdflo:
	dmabnk				; dma bank in place
	call	bbfread			; do read
rdflo1:
	rstbnk				; restore bank
	jp	fdret
	;
wrvrt:
	dmabnk				; dma bank in place
	call	bbwrvdsk		; call par. write
	jr	tovdret
	;
rdvrt:
	dmabnk				; dma bank in place
	call	bbrdvdsk		; call par. read
	jr	tovdret
	;
dohrdvd:
	dmabnk				; dma bank in place
	call	bbrdvdsk
	jr	tovdret

dohwrvd:
	dmabnk				; dma bank in place
	call	bbwrvdsk
tovdret:
	rstbnk
	jp	vdret

doiderd:
	dmabnk				; dma bank in place
	call	bbhdrd
	jr	doidew0

doidewr:
	dmabnk				; dma bank in place
	call	bbhdwr
doidew0:
	rstbnk
	jp	ideret

bksave	defb	0			; must stay in common



	END
