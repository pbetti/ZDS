
;;
;; Serial ports test for NEZ80 (Darkstar) MultiF-Board
;;

	include darkstar.equ
	include Common.inc.asm

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

	LD	A,U0DEFSPEED		; uart 0 init
	LD	(UART0BR),A
	CALL	INIUART0
	LD	A,UART38K4		; uart 1 init
	LD	(UART1BR),A
	CALL	INIUART1

	LD	C,'@'
TRASM:	CALL	TXCHAR0
	CALL	TXCHAR1
	CALL	BBCONOUT
	INC	C
	LD	A,C
	CP	'z'
	JR	NZ,TRASM
	LD	C,'@'
	JR	TRASM

; RECE:	CALL	RXCHAR1
; 	CP	3
; 	JP	Z,0
; 	LD	C,A
; 	CALL	BBCONOUT
; 	JR	RECE



;-------------------------------------------------------------------------------

MSINIT		DB 'Initalising UART...',CR,LF,'$'
MSINITOK	DB 'Ok.',CR,LF,'$'
MSINITNOK	DB 'Failure',CR,LF,'$'
;
;-------------------------------------------------------------------------------

SER_ON:		DS	1	; serial on/off
UART_FAIL:	DS	1	; UART has failed detection flag
SER_BAUD:	DS	1	; specify desired UART com rate in bps

	include uartctc.inc.asm
	include crtc.inc.asm
	include genio.inc.asm

	END

