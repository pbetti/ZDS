
;;
;; MMU test for NEZ80 (Darkstar) MultiF-Board
;;

; will size memory and report


ROMBDRY	EQU	$C0		; EEPROM lower boundary page


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


	LD	DE,MSINIT	; Wait for start
	CALL	PSTRING


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

MSINIT		DB 'Testing memory size...',CR,LF,'$'
;
;-------------------------------------------------------------------------------
	

	END

	
