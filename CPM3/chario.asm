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
	public	?cinit,?ci,?co,?cist,?cost,?lptost
	public	@ctbl

	; miscellaneous equates:


	; will start off in common memory for banked or non-banked systems:
	cseg

?cinit:
	jp	rret

	; physical code for device input:
?ci:
	jp	nullinput

; 	physical code for device input status:
?cist:
	jp	nullstatus

	; physical code for device output:
?co:
	jp	rret

?cost:
	jp	rettrue


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

	db	'LPT   '		; device 2
	db	mb$output
	db	baud$none

	db 	0			; table terminator

	end

