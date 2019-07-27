
;;
;; Serial ports test for NEZ80 (Darkstar) MultiF-Board
;;

	include datkstar.equ

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

	END

