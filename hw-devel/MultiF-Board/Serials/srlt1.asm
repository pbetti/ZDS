
;;
;; Serial ports test for NEZ80 (Darkstar) MultiF-Board
;;


SRL1BASE	EQU	$C0
SRL2BASE	EQU	$C8

; UART 16C550 1

; UART0:		EQU	SRL1BASE+0	; DATA IN/OUT
; UART1:		EQU	SRL1BASE+1	; CHECK RX
; UART2:		EQU	SRL1BASE+2	; INTERRUPTS
; UART3:		EQU	SRL1BASE+3	; LINE CONTROL
; UART4:		EQU	SRL1BASE+4	; MODEM CONTROL
; UART5:		EQU	SRL1BASE+5	; LINE STATUS
; UART6:		EQU	SRL1BASE+6	; MODEM STATUS
; UART7:		EQU	SRL1BASE+7	; SCRATCH REG.

; UART 16C550 2

UART0		EQU	SRL2BASE+0	; DATA IN/OUT
UART1		EQU	SRL2BASE+1	; CHECK RX
UART2		EQU	SRL2BASE+2	; INTERRUPTS
UART3		EQU	SRL2BASE+3	; LINE CONTROL
UART4		EQU	SRL2BASE+4	; MODEM CONTROL
UART5		EQU	SRL2BASE+5	; LINE STATUS
UART6		EQU	SRL2BASE+6	; MODEM STATUS
UART7		EQU	SRL2BASE+7	; SCRATCH REG.



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

; initialize UART related functions and variables

	LD	A,0
	LD	(SER_ON),A	; Initialize "Serial On" flag
				; assume it is off until UART
				; is autodetected
	LD	A,1
	LD	(UART_FAIL),A	; Initialize "UART FAIL" flag
				; assume it has failed until UART
				; is autodetected as working

	LD	DE,MSINIT
	CALL	PSTRING
	
; 	LD	A,$01		; specify baud rate 1200 bps (1200,8,None,1)
	LD	A,$04		; specify baud rate 9600 bps (9600,8,None,1)
	LD	(SER_BAUD),A	; 
	CALL	INIT_UART	; WITH NO FLOW CONTROL on terminal!!

	LD	A,(UART_FAIL)
	OR	A
	JR	Z,PNT1

	LD	DE,MSINITNOK
	CALL	PSTRING
	JP	QUIT

PNT1:
	LD	DE,MSINITOK
	CALL	PSTRING

PNT2:
	LD	B,'@'
PNT2A:
	CALL	ZCSTS
	OR	A
	JP	NZ,QUIT

	INC	B
	LD	A,B
	CALL	TOUT
	PUSH	BC
	PUSH	AF
	LD	C,B
	CALL	ZCO
	LD	C,CR
	CALL	ZCO
	POP	AF
	POP	BC
	CP	'Z'
	JR	NZ,PNT2A
	LD	B,'@'
	JR	PNT2A
	
	JP	QUIT


;-------------------------------------------------------------
;
;
;
TOUT:
;TX_SER_CHAR:
;	PUSH	AF
;	LD	A,(SER_ON)		; IF COM IS OFF
;	CP	0			; 
;	JP	Z,TX_END_CHAR
;	CALL	TX_BUSY			; WAIT FOR UART TO GET READY

TX_BUSY:
	PUSH   AF
TX_BUSYLP:
	IN	A,(UART5)		; READ Line Status Register
	BIT	5,A			; TEST IF UART IS READY TO SEND
	JP	Z,TX_BUSYLP		; IF NOT REPEAT
	POP	AF
	OUT	(UART0),A		; THEN WRITE THE CHAR TO UART
TX_END_CHAR:
	RET			;DONE


TIN:
;RX_SER_CHAR:
;	PUSH	AF
;	LD	A,(SER_ON)		; IF COM IS OFF
;	CP	0			; 
;	JP	Z,RX_END_CHAR
;	CALL	RX_BUSY			; WAIT FOR UART TO GET READY

;RX_BUSY:
;	PUSH	AF
RX_BUSYLP:
	IN	A,(UART5)		; READ Line Status Register
	BIT	0,A			; TEST IF DATA IN RECEIVE BUFFER
	JP	Z,RX_BUSYLP		; LOOP UNTIL DATA IS READY
	IN	A,(UART0)		; THEN READ THE CHAR FROM THE UART
;	LD	B,A			; put received data character in B
					; register and pass back to user
RX_END_CHAR:
	RET

;*******************************************************
;*	MESSAGE PRINT ROUTINE
;*******************************************************

TMSG:
;TX_SER:
;	PUSH	AF
;	LD	A,(SER_ON)		; IF COM IS OFF
;	CP	0			; 
;	JP	Z,TX_END
TX_SERLP:
	LD	A,(HL)			; GET CHARACTER TO A
	CP	'$'			; TEST FOR END BYTE
	JP	Z,TX_END		; JUMP IF END BYTE IS FOUND
;	CALL	TX_BUSY			; WAIT FOR UART TO GET READY

;TX_BUSY:
	PUSH   AF
TX_BUSYLP_MSG:
	IN	A,(UART5)		; READ Line Status Register
	BIT	5,A			; TEST IF UART IS READY TO SEND
	JP	Z,TX_BUSYLP_MSG		; IF NOT REPEAT
	POP	AF
	OUT	(UART0),A		; THEN WRITE THE CHAR TO UART
	INC	HL			; INC POINTER, TO NEXT CHAR
	JP	TX_SERLP		; TRANSMIT LOOP
TX_END:
	RET

	;******************************************************************
;*	INIT_UART
;*	Function	: Init serial port  8250, 16C450, OR 16C550
;*			9600 Baud, 8 bit, 1 stopbit, 0 parity
;*	Output		: none
;*	call		: PAUSE
;*	tested		: 2 Feb 2007
;******************************************************************

INIT_UART:
	LD	A,$AA
	OUT	(UART7),A
	IN	A,(UART7)
	CP	$AA	; TEST IF YOU COULD STORE AA
	JP	NZ,INITUART_FAIL	; IF NOT, THE UART CAN'T BE FOUND
	LD	A,$55
	OUT	(UART7),A		; 
	IN	A,(UART7)
	CP	$55			; 
	JP	NZ,INITUART_FAIL
	LD	A,$01
	LD	(SER_ON),A
	JP	UART_OK

INITUART_FAIL:				; Handle if initialize UART fails
	LD	A,1
	LD	(UART_FAIL),A
	HALT


UART_OK:
	LD	A,0
	LD	(UART_FAIL),A		; UART OK FOUND
	LD	A,(SER_BAUD)
	CP	1
	JP	Z,UART1200
	CP	2
	JP	Z,UART2400
	CP	3
	JP	Z,UART4800
	CP	4
	JP	Z,UART9600
	CP	5
	JP	Z,UART19K2
	CP	6
	JP	Z,UART38K4
	CP	7
	JP	Z,UART57K6
	CP	8
	JP	Z,UART115K2
					; IF NOTHING IS DEFINED 1200 WILL BE USED..


UART1200:
	LD	A,80H
	OUT	(UART3),A		; SET DLAB FLAG
	LD	A,96			;  = 1,843,200 / ( 16 x 1200 )
	OUT	(UART0),A		;
	LD	A,00H
	OUT	(UART1),A		;
	LD	A,03H
	OUT	(UART3),A		; Set 8 bit data, 1 stopbit

;	LD	A,03H
;	OUT	(UART4),A		; Force DTR and RTS

	JP	INITRET			; 0 parity, reset DLAP FLAG
UART2400:
	LD	A,80H
	OUT	(UART3),A		; SET DLAB FLAG
	LD	A,48			; = 1,843,200 / ( 16 x 2400 )
	OUT	(UART0),A		;
	LD	A,00H
	OUT	(UART1),A		;
	LD	A,03H
	OUT	(UART3),A		; Set 8 bit data, 1 stopbit
	JP	INITRET			; 0 parity, reset DLAP FLAG
UART4800:
	LD	A,80H
	OUT	(UART3),A		; SET DLAB FLAG
	LD	A,24			; = 1,843,200 / ( 16 x 4800 )
	OUT	(UART0),A		;
	LD	A,00H
	OUT	(UART1),A		;
	LD	A,03H
	OUT	(UART3),A		; Set 8 bit data, 1 stopbit
	JP	INITRET			; 0 parity, reset DLAP FLAG
UART9600:	
	LD	A,80H
	OUT	(UART3),A		; SET DLAB FLAG
	LD	A,12			; = 1,843,200 / ( 16 x 9600 )
	OUT	(UART0),A		; Set BAUD rate til 9600
	LD	A,00H
	OUT	(UART1),A		; Set BAUD rate til 9600
	LD	A,03H
	OUT	(UART3),A		; Set 8 bit data, 1 stopbit
	JP	INITRET			; 0 parity, reset DLAP FLAG
UART19K2:	LD	A,80H
	OUT	(UART3),A		; SET DLAB FLAG
	LD	A,06			; = 1,843,200 / ( 16 x 19,200 )
	OUT	(UART0),A		;
	LD	A,0
	OUT	(UART1),A		;
	LD	A,3
	OUT	(UART3),A		; Set 8 bit data, 1 stopbit
	JP	INITRET			; 0 parity, reset DLAP FLAG
UART38K4:	LD	A,80H
	OUT	(UART3),A		; SET DLAB FLAG
	LD	A,03
	OUT	(UART0),A		; = 1,843,200 / ( 16 x 38,400 )
	LD	A,00H
	OUT	(UART1),A		;
	LD	A,03H
	OUT	(UART3),A		; Set 8 bit data, 1 stopbit
	JP	INITRET			; 0 parity, reset DLAP FLAG
UART57K6:	LD	A,80H
	OUT	(UART3),A		; SET DLAB FLAG
	LD	A,02
	OUT	(UART0),A		; = 1,843,200 / ( 16 x 57,600 )
	LD	A,00H
	OUT	(UART1),A		;
	LD	A,03H
	OUT	(UART3),A		; Set 8 bit data, 1 stopbit
	JP	INITRET			; 0 parity, reset DLAP FLAG
UART115K2:	LD	A,80H
	OUT	(UART3),A		; SET DLAB FLAG
	LD	A,01
	OUT	(UART0),A		; = 1,843,200 / ( 16 x 115,200 )
	LD	A,00H
	OUT	(UART1),A		;
	LD	A,03H
	OUT	(UART3),A		; Set 8 bit data, 1 stopbit
					; 0 parity, reset DLAP FLAG
INITRET:
	RET


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

MSINIT		DB 'Initalising UART...',CR,LF,'$'
MSINITOK	DB 'Ok.',CR,LF,'$'
MSINITNOK	DB 'Failure',CR,LF,'$'
; MSINIT		DB 'Initalising UART...',CR,LF,'$'
; MSINIT		DB 'Initalising UART...',CR,LF,'$'
; MSINIT		DB 'Initalising UART...',CR,LF,'$'
;
;-------------------------------------------------------------------------------
	
SER_ON:		DS	1	; serial on/off
UART_FAIL:	DS	1	; UART has failed detection flag
SER_BAUD:	DS	1	; specify desired UART com rate in bps

	END

	