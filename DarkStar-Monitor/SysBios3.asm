;
;=======================================================================
;
; Modular Z80 DarkStar (NE Z80) Monitor
;
;=======================================================================
;
;-----------------------------------------------------------------------

; Common equates for BIOS/Monitor

include Common.inc.asm

	extern	delay, mmpmap, mmgetp
	extern	bbconin, bbconout, rldrom
	extern	inline, print
	extern	bbsysint

	dseg

	name	'SYS3BI'

sysbios3	equ	$		; start of non resident BIOS

	; safe reload, something goes wrong if we are here

	jp	rldrom

sysbid3:
	defb	'SYSBIOS3'

srvtab:
	defw	logo		; (0) See called service for description...

srvtbe	equ	$
srvtlen	equ	(srvtbe-srvtab)/2

;;
;; This bank reserved for internal sysbios services
;;
;; sysinit is the service dispatcher
;; C = service id
;; Other register depend on call
;;

sysint:
	ld	(s3stsav),sp		; switch to our stack
	ld	sp,s3stk
	ld	hl,sysiret		; returns will be to stack restore
	push	hl

	push	af
	ld	a,c
	sub	$1			; check called id
	jr	c,calerr		; minor 0
	cp	srvtlen
	jr	nc,calerr		; greater than jump table
	push	de
	add	a,a
	ld	e,a
	ld	d,$00
	ld	hl,srvtab
	add	hl,de
	pop	de
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	pop	af
	jp	(hl)

sysiret:				; global exit
	ld	sp,(s3stsav)
	ret
	;
calerr:
	pop	af
	call	inline
	defb	"sysbio3: invalid call.",cr,lf,0
	ret

;;
;;	Print out logo
;;
logo:
	ld	hl,logotxt
	call	print
	ret
;-------------------------------------
; Needed modules

;-------------------------------------
; Storage
s3stkbf:
	ds	36			; stack buffer for
s3stk	equ	$			; srstk
s3stsav:
	dw	0			; old stack ptr

;-------------------------------------
; Routine data

logotxt:
; 	defb	$1b,$1b,$0d
	defb	cr,lf
	defb	$20,$1b,$1b,$0d,$d4,$cc,$d5,$d4,$d0,$d5,$d4,$cc,$d5,$20,$20,$d4,$d5,$d4,$d4,$cc,$d5,$d4,$cc,$d5,$d4,$cc,$d5,$d4,$cc,$d5,$1b,$1c,$0d,$20,cr,lf
	defb	$20,$1b,$1b,$0d,$d4,$cc,$d3,$20,$cb,$cb,$d2,$cc,$d5,$20,$20,$cb,$cb,$cb,$cb,$cf,$20,$d4,$cc,$d3,$ce,$cc,$cf,$cb,$20,$cb,$1b,$1c,$0d,$20,cr,lf
	defb	$20,$1b,$1b,$0d,$d2,$cc,$cc,$cc,$d1,$d3,$d2,$cc,$d3,$20,$20,$d3,$d2,$d3,$d2,$cc,$d3,$d2,$cc,$d3,$d2,$cc,$d3,$d2,$cc,$d3,$1b,$1c,$0d,$20,cr,lf
	defb	$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1,cr,lf
	defb	cr,lf

; 	defb	$1b,$1c,$0d
	defb	0


;-------------------------------------
sysb3lo:
	defs	sysbios3 + $0bff - sysb3lo
sysb3hi:
	defb	$00
;;
;; end of code - this will fill with zeroes to the end of
;; the image

;-------------------------------------

if	mzmac
wsym sysbios3.sym
endif
;
;
	end
;
