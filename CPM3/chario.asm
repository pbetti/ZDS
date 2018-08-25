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
;; 20140904	- Code start
;; 20180224	- lowercased
;;---------------------------------------------------------------------

	TITLE	'CHARACTER I/O HANDLER FOR CP/M 3.0'

	.z80

	; define logical values:
	include	common.inc
	include syshw.inc
	include modebaud.inc		; define mode bits and baud eqautes

	; define public labels:
	public	?cinit,?ci,?co,?cist,?cost
	public	@ctbl

	; miscellaneous equates:


	; will start off in common memory for banked or non-banked systems:
	cseg
maxdevice	equ	7

?cinit:
					; c = device
	ld	b,c
	call	vectorio
	dw	?initcrtc
	dw	?inituart0
	dw	?inituart1
	dw	?initlpt
	dw	rret
	dw	rret
	dw	rret
	dw	rret

	; physical code for device input:
?ci:
	call	vectorio
	dw	bbconin
	dw	sconin
	dw	bbu1rx
	dw	nullinput
	dw	nullinput
	dw	nullinput
	dw	nullinput
	dw	nullinput

	; physical code for device input status:
?cist:
	call	vectorio
	dw	bbconst
	dw	sconst
	dw	bbu1st
	dw	nullstatus
	dw	nullstatus
	dw	nullstatus
	dw	nullstatus
	dw	nullstatus

	; physical code for device output:
?co:
	call	vectorio
	dw	bbconout
	dw	sconout
	dw	bbu1tx
	dw	bbprnchr
	dw	rret
	dw	rret
	dw	rret
	dw	rret

?cost:
	call	vectorio
	dw	rettrue
	dw	rettrue
	dw	rettrue
	dw	?lptost
	dw	rettrue
	dw	rettrue
	dw	rettrue
	dw	rettrue

vectorio:
	ld	a,maxdevice
	ld	e,b
vector:
	pop	hl
	ld	d,0
	cp	e
	jr	nc,exist
	ld	e,a			; use null device if a >= maxdevice
exist:	add	hl,de
	add	hl,de
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	jp	(hl)


nullinput:
	ld	a,1ah
rret:
	ret
rettrue:
	or	0ffh
	ret

nullstatus:
	xor	a
	ret

	;;
	;; physical device handler code:
	;;

	; init routines (void: done by sysbios)
?initcrtc:
?inituart0:
?inituart1:
?initlpt:
	ret


?lptost:
	in	a,(crtservdat)
	bit	prntbusybit,a
	jr	nz,lptbusy
	xor	a
	dec	a
	ret
lptbusy:xor	a
	ret


	; character device table

	cseg				;must reside in common memory

@ctbl:
	db	'CRTC  '		; device 0
	db	mb$in$out
	db	baud$none

	db	'UART0 '		; device 1
	db	mb$in$out
	db	baud$none		; baud rate selected by sysbios

	db	'UART1 '		; device 2
	db	mb$in$out
	db	baud$none		; baud rate selected by sysbios

	db	'LPT   '		; device 3
	db	mb$output
	db	baud$none

	db 	0			; table terminator


	end

