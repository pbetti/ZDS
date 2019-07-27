;
; read after write on
;

rsym bios.sym

	org $0100


START:	JP	BEGIN

BS	EQU	08H		;ASCII 	backspace
TAB	EQU	09H		;	tab
LF	EQU	0AH		;	line feed
FORMF	EQU	0CH		;	form feed
CR	EQU	0DH		;	carriage return
ESC	EQU	1BH		;       escape
CTLX	EQU	'X' and	1fh	;	control	x - delete line
CTLC	EQU	'C' and	1fh	;	control	c - warm boot
EOF	EQU	'Z' and	1fh	;	control	z - logical eof
QUOTE	EQU	27H		;	quote
TILDE	EQU	7EH		;	tilde
DEL	EQU	7FH		;	del

BDOSA	EQU	5
CTLC	EQU	'C' and	1fh	;	control	c - warm boot

MSG1:	DEFB	"Read After Write is OFF.",CR,LF,$00
;
;       begin the load operation
;
BEGIN:
	LD	A,(TMPBYTE)
	RES	7,A
	LD	(TMPBYTE),A

	LD	HL,MSG1
	CALL	ZSDSP

EXIT:
	RET
;	JP	$0000

GCHR:
	CALL	TTYI			; take from console
	AND	$7F			;
	CP	$60			;
	JP	M,GCDSP			; verify alpha
	CP	$7B			;
	JP	P,GCDSP			;
	RES	5,A			; convert to uppercase
GCDSP:	PUSH	BC			;
	LD	C,A			;
	CALL	TTYO			;
	LD	A,C			;
	POP	BC			;
	RET				;


ZSDSP:	LD	A,(HL)			; pick char pointed by HL
	OR	A			; is the terminating NUL ?
	RET	Z			; yes
	PUSH	HL			; no
	LD	C,A			;
	CALL	TTYO			; display it
	POP	HL			;
	INC	HL			;
	JP	ZSDSP			;

TTYO:
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	E,C
	LD	C,2
	CALL 	BDOSA
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET

TTYI:
	PUSH	BC
	PUSH	DE
	PUSH	HL
TTYI00:	LD	C,6
	LD	E,0FFH
	CALL 	BDOSA
	AND	7FH
	JR	Z,TTYI00
	POP	HL
	POP	DE
	POP	BC
	RET
TTYQ:
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	C,11
	CALL	BDOSA
	AND	A
	LD	C,6
	LD	E,0FFH
	CALL	NZ,BDOS
	POP	HL
	POP	DE
	POP	BC
	AND	7FH
	RET

ENDTXT	EQU	$
	END
