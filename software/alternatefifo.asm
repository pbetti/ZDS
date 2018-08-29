;
;=======================================================================
;
; Z80 DarkStar (NE Z80) Test program
;
;=======================================================================

;-------------------------------------
; Common equates for BIOS/Monitor

include Common.inc.asm
;-------------------------------------
; Symbols from parent sub-pages
include darkstar.equ

;-------------------------------------
	.Z80

	aseg

	org	0100h

;-------------------------------------

main:

	call	cfinit
	call	intrdi
flushu:
	in	a,(uart0+r5lsr)		; read status
	bit	0,a			; data available in rx buffer?
	jr	z,main0			; no, emtpy
	in	a,(uart0+r0rxtx)	; read data
	jr	flushu
main0:
	call	voidisr
	; set new u0 int vector
	; 	call	intrdi
	ld	hl,iu0isr
	ld	(0fff6h),hl
	call	intren
	call	srxrsm

	; start echo loop from fifo
echol:

	call	bbconst
	or	a
	jp	nz,usrkey

; 	in	a,(uart0+r5lsr)		; read status
; 	bit	0,a			; data available in rx buffer?
; 	jr	z,echol			; no, emtpy
;
; 	call	iu0isr

	call	cfcheck
	jr	z,echol

	xor	a
	di
	call	cfget
	ei
	ld	c,'o'
	call	bbconout
	ld	c,a
	call	bbconout


	jr	echol

usrkey:
	call	bbconin
	cp	'\'
	jr	z,byebye
	jr	echol


;-------------------------------------


byebye:
	call	inline
	defb	"Exiting",cr,lf,cr,lf,0
	jp	0

iuastav:	defw	0
uabuff:	defs	36
iuastak	equ	$


cflen	equ	16
cfctl	equ	5
; cfadr	equ	000fh
cfadr	equ	fifspc
cfbuf	equ	cflen+cfctl
cflvl	equ	cfadr
cfgp	equ	cfadr+1
cfpp	equ	cfadr+3
cfsta	equ	cfadr+5
cfend	equ	cfsta+cfbuf
cfmax	equ	cflen


cfinit:
	; clear all
	xor	a
	ld	b,cfbuf
	ld	hl,cfadr
cfini0:
	ld	(hl),a			; actual buffer
	inc	hl
	djnz	cfini0
	; setup pointers
	ld	hl,cfsta
	ld	(cfgp),hl
	ld	(cfpp),hl
	ret

cfcheck:
; 	in	a,(uart0+r5lsr)		; read status
; 	bit	7,a			; fifo overrun?
; 	jr	z,cfchec0		; no, ok
; 	di
; 	call	iu0isr			; try to flush the fifo
; 	ei
cfchec0:
	xor	a
	ld	a,(cflvl)		; buffer length
	or	a			; empty ?
	ret	z			; return Z flag
	cp	cfmax-1			; full ?
	ccf
	ret

;;
;; getbyte - extract char from queue
;;

cfget:
	push	hl
	push	de
	ld	hl,(cfgp)
	ld	a,(hl)			; get next char.
	inc	hl
	ld	de,cfend
	; cp hl,de
	push	hl
	or	a
	sbc	hl,de			; buffer end ?
	pop	hl
	jr	c,cfget0		; no, decrease
	ld	hl,cfsta		; yes, back to start
cfget0:
	ld	(cfgp),hl
	ld	hl,cflvl
	dec	(hl)
	; if enough room unlock host
	ld	d,a			; save output
	ld	a,(cflvl)
	cp	cfmax-(cfmax/4)
	call	nc,srxrsm
	ld	a,d
	pop	de
	pop	hl
	ret

cfput:
	ld	hl,(cfpp)
	ld	(hl),a
	inc	hl
	ld	de,cfend
	; cp hl,de
	push	hl
	or	a
	sbc	hl,de			; buffer end ?
	pop	hl
	jr	c,cfput0		; no
	ld	hl,cfsta		; yes
cfput0:
	ld	(cfpp),hl
	ld	hl,cflvl
	inc	(hl)
	ret


;;
;; Uart 0 receiver
;;
iu0isr:
	ld	(iuastav),sp		; private stack
	ld	sp,iuastak
	push	af			; reg. save
	push	bc
	push	de
	push	hl
	call	srxstp			; lock rx
iuisri:
	call	cfcheck			; chek for room in it
	jr	c,iuisre		; wait for space

	in	a,(uart0+r5lsr)		; read status
	bit	0,a			; data available in rx buffer?
	jr	z,iuisrs		; no, emtpy

	in	a,(uart0+r0rxtx)	; read data
	call	cfput			; insert

	jr	iuisri			; repeat for more data in UART (not local) fifo
iuisrs:
	call	srxrsm
iuisre:
	pop	hl			; reg. restore
	pop	de
	pop	bc
	pop	af
	ld	sp,(iuastav)
	ei
	reti




;----------------------------------------------------------------
; Print the string -> by DE. Return with DE pointing past the
; string end so as to point to the start of the next string.
;----------------------------------------------------------------
;
print:
	ld	a,(de)
	inc	de
	or	a
	ret	z
	cp	'$'			; END ?
	ret	z
	cp	0			; END ?
	ret	z
	call	coe
	jr	print

;;
;; Inline print
;;
inline:
	ex	(sp),hl			; get address of string (ret address)
	push	af
	push	de
	ex	de,hl
inline2:
	call	print
inline3:
	ex	de,hl
	pop	de
	pop	af
	ex	(sp),hl			; load return address after the '$'
	ret				; back to code immediately after string


; output A to console
coe:
	push	bc
	ld	c,a
	call	bbconout
	pop	bc
	ret

;; BINDISP - display E in binary form
bindisp:
	ld	b,$08
bdnxt:	ld	a,e
	rlca
	ld	e,a
	ld	a,$18
	rla
	ld	c,a
	call	bbconout
	djnz	bdnxt
	ret

;-------------------------------------

	org	0300h

fifspc:	ds	40



	end
