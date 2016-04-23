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
;;---------------------------------------------------------------------

	TITLE	'CHARACTER I/O HANDLER FOR CP/M 3.0'

	.Z80

	; define logical values:
	include	common.inc
	include syshw.inc
	include modebaud.inc		; define mode bits and baud eqautes

	; define public labels:
	PUBLIC	?CINIT,?CI,?CO,?CIST,?COST
	PUBLIC	@CTBL

	; define external labels and entry points:
	IF	BANKED
	EXTRN	@CBNK
	EXTRN	?BNKSL
	ENDIF


	; MISCELLANEOUS EQUATES:


	; will start off in common memory for banked or non-banked systems:
	CSEG


MAXDEVICE	EQU	7

					; c = device

?CINIT:					; init devices
	LD	B,C
	CALL	VECTORIO
	DW	?INITCRTC
	DW	?INITUART0
	DW	?INITUART1
	DW	?INITLPT
	DW	RRET
	DW	RRET
	DW	RRET
	DW	RRET

					; b = device, c = output char, a = input char
?CI:					; character input
	CALL	VECTORIO
	DW	?CRTCIN
	DW	?UART0IN
	DW	?UART1IN
	DW	NULLINPUT
	DW	NULLINPUT
	DW	NULLINPUT
	DW	NULLINPUT
	DW	NULLINPUT

?CIST:					; character input status
	CALL	VECTORIO
	DW	?CRTCIST
	DW	?UART0IST
	DW	?UART1IST
	DW	NULLSTATUS
	DW	NULLSTATUS
	DW	NULLSTATUS
	DW	NULLSTATUS
	DW	NULLSTATUS

?CO:					; character output
	CALL	VECTORIO
	DW	?CRTCOUT
	DW	?UART0OUT
	DW	?UART1OUT
	DW	?LPTOUT
	DW	RRET
	DW	RRET
	DW	RRET
	DW	RRET

?COST:					; character output status
	CALL	VECTORIO
	DW	RETTRUE
	DW	RETTRUE
	DW	RETTRUE
	DW	?LPTOST
	DW	RETTRUE
	DW	RETTRUE
	DW	RETTRUE
	DW	RETTRUE

VECTORIO:
	LD	A,MAXDEVICE
	LD	E,B
VECTOR:
	POP	HL
	LD	D,0
	CP	E
	JR	NC,EXIST
	LD	E,A			; use null device if a >= maxdevice
EXIST:	ADD	HL,DE
	ADD	HL,DE
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	JP	(HL)


NULLINPUT:
	LD	A,1AH
RRET:
	RET
RETTRUE:
	OR	0FFH
	RET

NULLSTATUS:
	XOR	A
	RET

	;;
	;; physical device handler code:
	;;

	; init routines (void: done by sysbios)
?INITCRTC:
	RET
?INITUART0:
	RET
?INITUART1:
	RET
?INITLPT:
	RET

	; input status routines (jump to sysbios calls)

?CRTCIST:
	JP	BBCONST

?UART0IST:
	JP	SCONST

?UART1IST:
	JP	BBU1ST

	; output status routines

; ?CRTCOST:
; 	OR	0FFH
; 	RET
;
;
; ?UART0OST:
; 	OR	0FFH
; 	RET
;
; ?UART1OST:
; 	OR	0FFH
; 	RET

?LPTOST:
	IN	A,(CRTSERVDAT)
	BIT	PRNTBUSYBIT,A
	JR	NZ,LPTBUSY
	XOR	A
	DEC	A
	RET
LPTBUSY:XOR	A
	RET

	; input routines (jump to sysbios calls)

?CRTCIN:
	JP	BBCONIN

?UART0IN:
	JP	SCONIN

?UART1IN:
	JP	BBU1RX

	; output routines (jump to sysbios calls)

?CRTCOUT:
	JP	BBCONOUT

?UART0OUT:
	JP	SCONOUT

?UART1OUT:
	JP	BBU1TX

?LPTOUT:
	JP	BBPRNCHR

	; character device table

	CSEG				;must reside in common memory

@CTBL:
	DB	'CRTC  '		; device 0
	DB	MB$IN$OUT
	DB	BAUD$NONE

	DB	'UART0 '		; device 1
	DB	MB$IN$OUT
	DB	BAUD$NONE		; baud rate selected by sysbios

	DB	'UART1 '		; device 2
	DB	MB$IN$OUT
	DB	BAUD$NONE		; baud rate selected by sysbios

	DB	'LPT   '		; device 3
	DB	MB$OUTPUT
	DB	BAUD$NONE

	DB 	0			; table terminator

	END

