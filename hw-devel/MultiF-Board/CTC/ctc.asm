
;;
;; CTC test for NEZ80 (Darkstar) MultiF-Board
;;


CTCBASE		EQU	$E8

CTCCHAN0	EQU	CTCBASE+0	; Channel 1 - Free
CTCCHAN1	EQU	CTCBASE+1	; Channel 2 - Free
CTCCHAN2	EQU	CTCBASE+2	; Channel 3 - UART 1 Interrupt
CTCCHAN3	EQU	CTCBASE+3	; Channel 4 - UART 0 Interrupt



LF	EQU	0AH
CR	EQU	0DH
BS	EQU	08H		;Back space (required for sector display)
BELL	EQU	07H
TAB	EQU	09H		;TAB ACROSS (8 SPACES FOR SD-BOARD)
ESC	EQU	1BH
CLEAR	EQU	1CH		;SD Systems Video Board, Clear to EOL. (Use 80 spaces if EOL not available
				;on other video cards)
RDCON	EQU	1		;For CP/M I/O
WRCON	EQU	2
PRINT	EQU	9
CONST	EQU	11		;CONSOLE STAT
BDOS	EQU	5

FALSE	EQU	0
TRUE	EQU	-1

QUIT	EQU	0

	ORG	$100

INITIALIZE:

; initialize CTC Chan 0 as timer and test interrupts

	DI
	IM	2

	LD	A,$10		; Vector table base MSB ($1000)
	LD	I,A

	LD	A,00000011b
	OUT	(CTCCHAN0),A

	LD	A,10100111b	; Command word
	OUT	(CTCCHAN0),A

	LD	A,$FF		; 4M / 256 / 256 = 122 ticks per sec.
	OUT	(CTCCHAN0),A

	LD	A,$00		; CTC handler locations in int. vector
	OUT	(CTCCHAN0),A

	LD	DE,MSINIT	; Wait for start
	CALL	PSTRING
	CALL	ZCI

	EI			; let things run

ENDLOOP:
	JP	ENDLOOP
	CALL	ZCSTS
	CP	$01
	JR	NZ,ENDLOOP
	DI
	JP	QUIT

IHANDLCH0:
	LD	DE,MSICH0
	JR	DONEINT
IHANDLCH1:
	LD	DE,MSICH1
	JR	DONEINT
IHANDLCH2:
	LD	DE,MSICH2
	JR	DONEINT
IHANDLCH3:
	LD	DE,MSICH3
	JR	DONEINT
DONEINT:
	CALL	PSTRING
	EI
	RETI


ZCSTS:
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	C,CONST
	CALL	BDOS		;Returns with 1 in [A] if character at keyboard
	POP	HL
	POP	DE
	POP	BC
	CP	1
	RET

;
ZCO:	;Write character that is in [C]
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	E,C
	LD	C,WRCON
	CALL	BDOS
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET

ZCI:	;Return keyboard character in [A]
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	C,RDCON
	CALL	BDOS
	POP	HL
	POP	DE
	POP	BC
	RET
;
;
;	;Print a string in [DE] up to '$'
PSTRING:
	LD	C,PRINT
	JP	BDOS		;PRINT MESSAGE,

;
;-------------------------------------------------------------------------------

MSINIT		DB 'CTC initalized, a key to go...',CR,LF,'$'
MSICH0		DB 'Channel 0 interrupt!',CR,LF,'$'
MSICH1		DB 'Channel 1 interrupt!',CR,LF,'$'
MSICH2		DB 'Channel 2 interrupt!',CR,LF,'$'
MSICH3		DB 'Channel 3 interrupt!',CR,LF,'$'
;
;-------------------------------------------------------------------------------


	ORG	$1000
INTVEC:
THNDLCH0:	DW	IHANDLCH0
THNDLCH1:	DW	IHANDLCH1
THNDLCH2:	DW	IHANDLCH2
THNDLCH3:	DW	IHANDLCH3
TVECFILL:	DS	247
TVECEND:	DB	0


;-------------------------------------------------------------------------------


	END


