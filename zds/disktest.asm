;
; disk test
;

rsym bios.sym

;DSELBF	EQU	$004E
;CR	EQU	$0D
;--------------------
	org $0100


START:	JP	RECOVER

SCRTCH:	DEFS	128			; local stack area
SPAREA	EQU	$

	; include routines to print ascii values
include ../ASM/bit2040.asm

;START:	jp	STEP4
;
NDRIVE	EQU	1
SECSIZ	EQU	512
SECNUM	EQU	11
NTRACK	EQU	160

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


STMSG1:	defb	" Trk.: ",0
STMSG2:	defb	" Sec.: ",0
STMOK:	defb	" OK -> ",0
STMNOK:	defb	"NOK -> ",0
SGON:	DEFB	$0C,CR,LF,CR,LF,"Z80 DARKSTAR",CR,LF,0
	DEFB	"DESTRUCTIVE DISK TEST",CR,LF,0
MCRLF:	DEFB	CR,LF,0
MDCHO:	DEFB	"Select drive (A/B): ",$00
;
;       begin the load operation
;
RECOVER:
	LD	SP,SPAREA		; init stack
	LD	HL,SGON
	CALL	ZSDSP
; 	CALL	TTYI
; 	CP	CTLC
; 	JP	Z,EXIT

DRVID:	LD	HL,MDCHO		; ask for drive id
	CALL	ZSDSP			;
	CALL	GCHR			;
	CP	$03			; CTRL+C ?
	JP	Z,EXIT			; exit
	CP	'A'			; is A or B ?
	JP	M,DRVID			;
	CP	'C'			;
	JP	P,DRVID			; no
	SUB	'A'			; makes number
	LD	(RDSK),A
	LD	HL,MCRLF
	CALL	ZSDSP

	LD	DE,SECSIZ
	LD	HL,BUFDMA
	LD	B,0
PRDMA:	LD	(HL),B
	INC	B
	INC	HL
	DEC	DE
	LD	A,D
	OR	E
	JR	NZ,PRDMA

	LD	HL,0
	LD	(RTRK),HL
	INC	HL
	LD	(RSEC),HL
STEP1:
	CALL	TTYQ
	CP	CTLC
	JP	Z,EXIT

	LD	BC,BUFDMA
	CALL	SETSEK
	CALL	WRITEHST

	LD	BC,RDMA
	CALL	SETSEK
	CALL	READHST

	LD	HL,BUFDMA
	LD	DE,RDMA
	LD	BC,SECSIZ
CTBUF:	LD	A,(DE)
	CPI
	JR	NZ,CTNOK
	INC	DE
	LD	A,B
	OR	C
	JR	NZ,CTBUF
	LD	HL,STMOK
	CALL	AVMSG
	JR	STEP2
CTNOK:
	LD	HL,STMNOK
	CALL	AVMSG
	LD	C,LF
	CALL	TTYO

STEP2:
	LD	HL,RSEC
	INC	(HL)
	LD	A,(RSEC)
	CP	SECNUM+1	; EOT ?
	JR	Z, STEP3	; NXT TRK
	JR	STEP1		; NXT SEC
STEP3:
	LD	HL,RTRK
	INC	(HL)
	LD	A,(RTRK)
	CP	NTRACK
	JR	Z,RECOVEND
	LD	A,1
	LD	(RSEC),A	; LOOP
	JP	STEP1
RECOVEND:
	JP	EXIT

SETSEK:
; 	LD	BC,BUFDMA		; set DMA to buffer
	CALL	BSETDMA
	LD	A,(RDSK)		; set disk
	LD	C,A
	CALL	BSELDSK			; ... hw
	CALL	SELDSK			; ... logical
	LD	BC,(RTRK)		; set track
	CALL	BSETTRK
	LD	A,(RSEC)		; set sector
	DEC	A
	LD	(HSTLGS),A
	RET

AVMSG:
	CALL	ZSDSP			;
	LD	HL,STMSG1		; inform user about progress
	CALL	ZSDSP			;
	LD	A,(RTRK)		; track
	LD	C,A			;
	CALL	BIN2A8			;
	LD	HL,OVAL16		;
	CALL	ZSDSP			;
	LD	HL,STMSG2		;
	CALL	ZSDSP			;
	LD	A,(RSEC)		; side
	LD	C,A			;
	CALL	BIN2A8			;
	LD	HL,OVAL16		;
	CALL	ZSDSP			;
	LD	C,' '
	CALL	TTYO
	LD	C,CR			;
	CALL	TTYO			; at beginning of line
	RET

MTRM:	DEFB	"TERMINATED...",CR,LF,0
EXIT:
	LD	HL,MTRM
	CALL	ZSDSP
	JP	$0000

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

BUFDMA:	DEFS	512
RDSK:	DEFB	NDRIVE
RSEC:	defw	1
RTRK:	defw	0
RDMA:	DEFS	SECSIZ



	END
