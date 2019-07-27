
include darkstar.equ

	.Z80
	ASEG


	ORG	$100

BEGIN:	NOP
	NOP
	LD	HL,0
	LD	C,0

CALR:	PUSH	HL
	PUSH	BC
	CALL	HL2ASCB
	POP	BC
	POP	HL

	PUSH	HL
	PUSH	BC
	LD	A,C
	CALL	H2AJ1
	CALL	SPACER
	POP	BC
	POP	HL

	PUSH	HL
	PUSH	BC
	CALL	WRLBA
	POP	BC
	POP	HL
	LD	A,C
	INC	A
	CP	64
	LD	C,A
	JR	C,CALR
	LD	C,0
	INC	HL
	JR	CALR

WRLBA:
; 	LD	HL,(@TRK)	;Get CPM requested Track Hi&Lo
	LD	H,00H		;zero high track byte
	LD	A,L		;load low track byte to accumulator
	CP	00H		;check for 0 track and skip track loop
	JP	Z,LBASEC
	LD	B,06H		;load counter to shift low track value 6 places to left i.e X 64
LBATRK:
	ADD	HL,HL		;Add HL to itself 6 times to multiply by 64
	DJNZ	LBATRK		;loop around 6 times i.e x 64

LBASEC:
; 	LD	A,(@SECT)	;Get CPM requested sector
	LD	A,C		;Get CPM requested sector
	ADD	A,L		;Add value in L to sector info in A
	JP	NC,LBAOFF	;If no carry jump to lba offset correction
	INC	H		;carry one over to H
LBAOFF:
	LD	L,A		;copy accumulator to L
	DEC	HL		;decrement 1 from the HL register pair
	;HL should now contain correct LBA value

	CALL	HL2ASCB
	CALL	OUTCRLF
	CALL	BBCONIN

; 	LD	D,0		;Send 0 for upper cyl value
; 	LD	E,REGCYLINDERMSB
; 	CALL	IDEWR8D		;Send info to drive
;
; 	LD	D,H		;load lba high byte to D from H
; 	LD	E,REGCYLINDERLSB
; 	CALL	IDEWR8D		;Send info to drive
;
; 	LD	D,L		;load lba low byte to D from L
; 	LD	E,REGSECTOR
; 	CALL	IDEWR8D		;Send info to drive
; 	LD	D,1		;For now, one sector at a time
; 	LD	E,REGSECCNT
; 	CALL	IDEWR8D

	RET
;==============================================================================
HL2ASC:

H2AEN1:	LD	A,H
	CALL	H2AJ1
	LD	A,L
H2AJ1:	PUSH	AF
	RRCA
	RRCA
	RRCA
	RRCA
	CALL	H2AJ2
	POP	AF
H2AJ2:	CALL	NIB2ASC
	CALL	BBCONOUT
	RET

H2AJ3:	CALL	H2AJ1           ; entry point to display HEX and a "-"
MPROMPT:
	LD	C,$2D
	CALL	BBCONOUT
	RET



;;
;; HL2ASCB - convert & display HL 2 ascii leave a blank after
HL2ASCB:
	CALL	HL2ASC           ; was 00FA63 CD 46 FA
SPACER:	LD	C,$20
	CALL	BBCONOUT
	RET

NIB2ASC:
	AND	$0F             ; was 00FDE0 E6 0F
	ADD	A,$90
	DAA
	ADC	A,$40
	DAA
	LD	C,A
	RET

OUTSTR:
	PUSH	BC
OSLP0:	LD	C,(HL)
	LD	B,C
	RES	7,C
	CALL	BBCONOUT
	INC	HL
	LD	A,B
	RLCA
	JR	NC,OSLP0
	POP	BC
	RET


;; OUTCRLF - CR/LF through OUTSTR
;

OUTCRLF:
	PUSH	HL			; was 00FAB0 E5
OCRLF1:	LD	HL,CRLFTAB
	CALL	OUTSTR
	POP	HL
	RET

CRLFTAB:
	DB	$0D,$8A
