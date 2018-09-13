;	NAME	'Dallas DS-1302 Clock Set/Read Utility'

; Original copyright follows
;=======================================================================;
;									;
;  Written by Harold F Bower <HalBower@msn.com>, and contributed to	;
;  the P112 software pool.						;
;                                                                       ;
;  Modified by Hector Peraza to allow setting MP/M system clock from	;
;  CMOS clock, and to allow both mm/dd/yy and dd.mm.yy date formats.	;
;  The program now also sets the DOW properly, instead of forcing it	;
;  to 1.								;
;									;
;  This program is free software; you can redistribute it and/or	;
;  modify it under the terms of the GNU General Public License		;
;  as published by the Free Software Foundation; either version 2	;
;  of the License, or (at your option) any later version.		;
;									;
;  This program is distributed in the hope that it will be useful,	;
;  but WITHOUT ANY WARRANTY; without even the implied warranty of	;
;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the	;
;  GNU General Public License for more details.				;
;									;
;  You should have received a copy of the GNU General Public License	;
;  along with this program; if not, write to the Free Software		;
;  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.		;
;									;
;=======================================================================;

; link to DarkStar Monitor symbols...
include darkstar.equ
include syshw.inc



CR	EQU	0DH
LF	EQU	0AH
CMDLN	EQU	$0080		;
BDOS	EQU	$0005

	ORG TPA

BEGIN:	LD	(STACK),SP
	LD	SP,STACK
	LD	HL,EXIT
	PUSH	HL		; Push Exit address on stack
	LD	A,(CMDLN)	; Parse command line
	OR	A		; Check for empty console buffer
	JP	Z,RTCREAD	; empty: jump to read
	LD	HL,CMDLN+1	; go on...
	CALL	SKIP		; Skip leading spaces
	OR	A		; Anything entered?
	JP	Z,RTCREAD	; ..jump to read and display if Not
	CP	'/'		; Option Entered?
	JP	NZ,SETIT	; ..jump if Not to Parse and Set
	INC	HL
	LD	A,(HL)
	CP	'R'		; Set system time from CMOS clock?
	JP	Z,SETTOD	; ..jump if yes
	CP	'W'		; Set CMOS clock from system time?
	JP	Z,SETRTC	; ..jump if yes, otherwise display help
	CALL	PRHELP		; Else "Call" to transfer String Addr
	DB	CR,LF,'DS-1302 Clock Utility for Z80 DarkStar',CR,LF,LF
	DB	'Syntax:',CR,LF,LF
	DB	'  CLOCK //                 '
	DB		'--> shows this help',CR,LF
	DB	'  CLOCK                    '
	DB		'--> displays the CMOS date and time',CR,LF
	DB	'  CLOCK dd.mm.yy hh:mm     '
	DB		'--> sets the date and time (EU format)',CR,LF
	DB	'  CLOCK mm/dd/yy hh:mm     '
	DB		'--> sets the date and time (US format)',CR,LF
	DB	'  CLOCK /R                 '
	DB		'--> sets the system time from the CMOS clock',CR,LF
	DB	'  CLOCK /W                 '
	DB		'--> sets the CMOS clock from the system time',CR,LF
	DB	'  CLOCK /W dd.mm.yy hh:mm  '
	DB		'--> sets both the CMOS clock and system time (EU)',CR,LF
	DB	'  CLOCK /W mm/dd/yy hh:mm  '
	DB		'--> sets both the CMOS clock and system time (US)',CR,LF
	DB	'$'
PRHELP:	POP	DE		; String Addr to DE
	LD	C,9
	CALL	BDOS		;  print
	DB	'$'
EXIT:	LD	SP,(STACK)	;   restore Stack Pointer
	RET			;    and back to OS

;-----------------------------------------------------------------------
; Parse the Command Line into the Clock Buffer, activate and Set the Clock.

SETIT:	CALL	SKIP
	CALL	GETBCD		; get bcd month or day
	JR	C,BADDAT	; ..ERR if Invalid
	LD	(TIMSTR+4),A
	LD	A,(HL)
	CP	'.'		; valid separator?
	JR	Z,VALID
	CP	'/'		; valid separator?
	JR	NZ,BADDAT	; ..err if not
VALID:	LD	B,A		; keep separator in b
	INC	HL
	CALL	GETBCD		; get bcd day
	JR	C,BADDAT	; ..err if invalid
	LD	(TIMSTR+3),A
	LD	A,(HL)
	CP	B		; separator must be the same
	JR	NZ,BADDAT
	INC	HL
	CALL	GETBCD		; get bcd year
	JR	C,BADDAT	; ..err if Invalid
	LD	(TIMSTR+6),A
	LD	A,B
	CP	'.'		; DD.MM.YY format?
	JR	NZ,SET1
	LD	A,(TIMSTR+3)	; ..swap Day and Month if yes
	LD	B,A
	LD	A,(TIMSTR+4)
	LD	(TIMSTR+3),A
	LD	A,B
	LD	(TIMSTR+4),A
SET1:	CALL	SKIP		; Point to Time String
	CALL	GETBCD		; get bcd Hours
	JR	C,BADDAT	; ..ERR if Invalid
	LD	(TIMSTR+2),A
	LD	A,(HL)
	CP	':'
	JR	NZ,BADTIM
	INC	HL
	CALL	GETBCD		; get bcd minutes
	JR	C,BADTIM	; ..Err if Invalid
	LD	(TIMSTR+1),A
	XOR	A
	LD	(TIMSTR),A
	CALL	CDAYS		; Compute DOW
	CALL	CDOW		; ..from number of days since 1/1/78
	INC	A		; base 1
	LD	(TIMSTR+5),A
	LD	HL,TIMSTR
	DI
	CALL	BBWRTIME	;  Activate and Set the Clock
	EI
	RET			; ..and Quit

BADDAT:	CALL	BADDA0
	DB	7,CR,LF,'+++ Invalid Date specification',CR,LF,'$'
BADTIM:	CALL	BADDA0
	DB	7,CR,LF,'+++ Invalid Time specification',CR,LF,'$'
BADDA0:	POP	DE
	LD	C,9
	CALL	BDOS
	JP	EXIT

;.....
; Skip spaces in the Command Line
SKIP:	LD	A,(HL)
	CP	' '
	RET	NZ
	INC	HL
	JR	SKIP

;----------------------------------------------------------------------
; Read the Clock and Display Results

RTCREAD:
	LD	HL,TIMSTR	; point to the destination time string
	DI
	CALL	BBRDTIME		;  read
	EI
	CALL	RTCREAD0
	DB	CR,LF,'Clock reports: $'
RTCREAD0:
	POP	DE
	LD	C,9
	CALL	BDOS
	CALL	DTIME		; Display Date and Time
	RET			; ..and quit

;.....
; Display Date and Time

DTIME:	LD	HL,TIMSTR+5
	LD	A,(HL)		; Fetch DOW
	OR	A		;  Ensure is Valid
	JR	Z,DTIME0
	CP	8
	JR	NC,DTIME0
	DEC	A
	ADD	A,A
	ADD	A,A
	LD	E,A
	LD	D,0
	PUSH	HL
	LD	HL,DOWSTR
	ADD	HL,DE
	EX	DE,HL
	LD	C,9
	CALL	BDOS		;   Print
	LD	A,' '
	CALL	COUT
	POP	HL
DTIME0:	DEC	HL
	LD	A,(HL)		; Fetch Month
	CALL	PR2HEX		;  Print
	LD	A,'/'
	CALL	COUT
	DEC	HL
	LD	A,(HL)		; Fetch Day
	CALL	PR2HEX		;  Print
	LD	A,'/'
	CALL	COUT
	INC	HL
	INC	HL
	INC	HL
	LD	A,(HL)		; Fetch Year
	CALL	PR2HEX		;  Print
	CALL	DTIME1
	DB	' $'
DTIME1:	POP	DE
	LD	C,9
	CALL	BDOS
	LD	HL,TIMSTR+2
	LD	A,(HL)		; Fetch Hours
	CALL	CVHOUR		;  Convert to 24-hours format as necessary
	CALL	PR2HEX		;   Print
	LD	A,':'
	CALL	COUT
	DEC	HL
	LD	A,(HL)		; Fetch Minutes
	CALL	PR2HEX		;  Print
	LD	A,':'
	CALL	COUT
	DEC	HL
	LD	A,(HL)		; Fetch Seconds
	CALL	PR2HEX		;  Print
	CALL	DTIME2
	DB	CR,LF,'$'
DTIME2:	POP	DE
	LD	C,9
	CALL	BDOS
	RET

DOWSTR:	DB	'Sun$Mon$Tue$Wed$Thu$Fri$Sat$'

;----------------------------------------------------------------------
; Read CMOS clock and set MP/M time-of-day

SETTOD:	LD	HL,TIMSTR	; Point to the Destination Time String
	CALL	BBRDTIME	;  Read
	CALL	ST0
	DB	CR,LF,'Setting system time from CMOS clock: $'
ST0:	POP	DE
	LD	C,9
	CALL	BDOS
	CALL	DTIME		; Display Date and Time
STTOD:	LD	C,154
	CALL	BDOS		; Get system data page
	LD	L,$FC		; Offset to TOD structure address
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	PUSH	DE		; Save pointer to MP/M TOD buffer
	CALL	CDays		; Compute Number of days
	POP	DE		; Restore MP/M TOD address
	EX	DE,HL
	DI			; Disable interrupts
	LD	(HL),E		; Store Date
	INC	HL
	LD	(HL),D
	INC	HL
	LD	DE,TIMSTR+2	; Store Time
	LD	A,(DE)		; Get Hours
	CALL	CVHOUR		; Convert to 24-hours format as necessary
	LD	(HL),A		;  Hours
	DEC	DE
	INC	HL
	LD	A,(DE)
	LD	(HL),A		;   Minutes
	DEC	DE
	INC	HL
	LD	A,(DE)
	LD	(HL),A		;    Seconds
	EI			; Enable interrupts
	RET			; .. and quit

MLTHL:
	PUSH	AF
	PUSH	BC
	PUSH	DE
	LD	E,L
	LD	D,0
	LD	C,H
	LD	B,0
	CALL	MUL16
	POP	DE
	POP	BC
	POP	AF
	RET

MLTDE:
	PUSH	AF
	PUSH	BC
	PUSH	HL
	LD	A,D
	LD	D,0
	LD	C,A
	LD	B,0
	CALL	MUL16
	EX	DE,HL
	POP	HL
	POP	BC
	POP	AF
	RET

;
;;	MUL16 - 16x16 bit multiplication
;;
;; 	in  DE = multiplicand
;;	    BC = multiplier
;;	out DE = result
MUL16:	LD	A,C		; A = low mpler
	LD	C,B		; C = high mpler
	LD	B,16		; counter
	LD	HL,0
ML1601:	SRL	C		; right shift mpr high
	RRA			; rot. right mpr low
	JR	NC,ML1602	; test carry
	ADD	HL,DE		; add mpd to result
ML1602:	EX	DE,HL
	ADD	HL,HL		; double shift mpd
	EX	DE,HL
	DJNZ	ML1601
	RET

; Compute number of days since 1/1/78.
; The algorithm was taken from the MP/M TOD program.
; Entry: TIMSTR containing Date in DS1202 format (BCD)
; Exit:  HL = number of days

CDAYS:	LD	A,(TIMSTR+4)	; FETCH MONTH
	CALL	BCD2BIN
	DEC	A		; MONTH = 0...11
	ADD	A,A
	LD	E,A
	LD	D,0
	LD	HL,MDAYS
	ADD	HL,DE
	LD	C,(HL)
	INC	HL
	LD	B,(HL)		; MONTH_DAYS[MONTH]
	LD	A,(TIMSTR+6)	; FETCH YEAR
	CALL	BCD2BIN
	SUB	78		; 1978
	JR	NC,CD1
	ADD	A,100		; IF YEAR WAS < 78, CONSIDER IT AS >= 2000
CD1:	LD	DE,365
	LD	L,A
	LD	H,D
	CALL	MLTHL
	LD	H,L
	LD	L,0
	LD	D,A
	CALL	MLTDE
	ADD	HL,DE		; HL = A * 365
	ADD	HL,BC		; + MONTH_DAYS[MONTH]
	LD	A,(TIMSTR+3)	; FETCH DAY
	CALL	BCD2BIN
	LD	C,A		; DAY = 1...29,30, OR 31
	LD	B,0
	ADD	HL,BC		; + DAY
	PUSH	HL
	LD	HL,78		; 1978
	LD	DE,0
	CALL	LEAPDAYS
	EX	DE,HL
	POP	HL
	OR	A
	SBC	HL,DE		; - LEAP_DAYS(78, 0)
	PUSH	HL
	LD	A,(TIMSTR+6)	; YEAR
	CALL	BCD2BIN
	CP	78
	JR	NC,CD2
	ADD	A,100
CD2:	LD	L,A
	LD	H,0
	LD	A,(TIMSTR+4)	; MONTH
	CALL	BCD2BIN
	DEC	A		; MONTH = 0...11
	LD	E,A
	LD	D,0
	CALL	LEAPDAYS
	POP	DE
	ADD	HL,DE		; + LEAP_DAYS(YEAR, MONTH)
	RET

LEAPDAYS:
	LD	H,0		; JUST IN CASE... (H SHOULD BE ALREADY 0)
	LD	A,L
	RRCA
	RRCA
	AND	3FH
	LD	L,A		; HL = YEAR / 4
	AND	3
	RET	NZ
	PUSH	HL
	LD	HL,MDAYS
	ADD	HL,DE
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)		; MONTH_DAYS[MONTH]
	POP	HL
	LD	A,D
	OR	A
	RET	NZ
	LD	A,59
	CP	D
	RET	NC
	DEC	HL
	RET

;.....
; CONVERT 2-DIGIT BCD VALUE TO 8-BIT BINARY.
; ENTRY: A = BCD VALUE
; EXIT:  A = BINARY VALUE

BCD2BIN:
	PUSH	DE
	LD	D,A
	AND	0F0H
	LD	E,A
	LD	A,D
	AND	0FH
	SRL	E
	ADD	A,E
	SRL	E
	SRL	E
	ADD	A,E
	POP	DE
	RET

;.....
; CONVERT 8-BIT BINARY VALUE TO 2-DIGIT BCD.
; ENTRY: A = BINARY VALUE
; EXIT:  A = BCD VALUE

BIN2BCD:
	PUSH	BC
	LD	B,10
	LD	C,-1
AD1:	INC	C
	SUB	B
	JR	NC,AD1
	ADD	A,B
	SLA	C
	SLA	C
	SLA	C
	SLA	C
	OR	C
	POP	BC
	RET

;----------------------------------------------------------------------
; Read MP/M time-of-day and set CMOS clock

SETRTC:	INC	HL		; SKIP OVER OPTION CHARACTER
	CALL	SKIP		; CHECK COMMAND LINE TAIL
	OR	A		;  FOR A POSSIBLE DATE/TIME SPEC
	JR	Z,SR1

; Parse command line and set both MP/M and CMOS clock

	CALL	SETIT		; PARSE COMMAND AND SET CMOS CLOCK
	CALL	STTOD		; SET MP/M TIME
	RET			; ..AND QUIT

; Read MP/M time and set CMOS clock

SR1:	CALL	SR0
	DB	CR,LF,'Setting CMOS clock from system time: $'
SR0:	POP	DE
	LD	C,9
	CALL	BDOS
	LD	C,154
	CALL	BDOS		; Get system data page
	LD	L,$FC		; Offset to TOD structure
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A		; HL now points to MP/M TOD buffer
	LD	E,(HL)		; First word is the date
	INC	HL		;  (number of days since 1/1/78)
	LD	D,(HL)
	INC	HL
	PUSH	HL
	EX	DE,HL
	CALL	GETDATE		; Convert Date to DS1202 format
	POP	HL
	LD	DE,TIMSTR+2	; Store Time
	LD	A,(HL)		;  Hours
	LD	(DE),A
	INC	HL
	DEC	DE
	LD	A,(HL)		;     Minutes
	LD	(DE),A
	INC	HL
	DEC	DE
	LD	A,(HL)		;      Seconds
	LD	(DE),A
	EX	DE,HL		; HL = TIMSTR
	CALL	BBWRTIME	; Activate and Set the Clock
	CALL	DTIME		; Display Time
	RET			; ..and Quit

;.....
; Convert MP/M Time-Of-Day value to DS1202 format.
; Entry: HL = TOD (number of days since 1/1/78)
; Exit:  TIMSTR buffer updated accordingly.

GETDATE:
	CALL	CDOW		; COMPUTE DAY OF WEEK
	INC	A		; BASE 1
	LD	(TIMSTR+5),A
	POP	HL
	CALL	CYEAR		; COMPUTE YEAR, RETURNS REM_DAYS REMAINDER
	LD	A,C
	CP	100		; ABOVE YEAR 2000?
	JR	C,GD0
	SUB	100		; CORRECT IF YES
GD0:	CALL	BIN2BCD		; CONVERT TO BCD
	LD	(TIMSTR+6),A
	LD	E,0		; LEAP_BIAS = 0
	LD	A,C
	AND	3		; (YEAR & 3) == 0 ?
	JR	NZ,GD1
	LD	A,L
	SUB	59+1		; ..AND (REM_DAYS > 59) ?
	LD	A,H
	SBC	A,0
	JR	C,GD1
	INC	E		; ..THEN LEAP_BIAS = 1;
GD1:	LD	C,E
	CALL	CMONTH		; COMPUTE MONTH
	PUSH	DE
	PUSH	HL
	LD	HL,MDAYS
	ADD	HL,DE
	ADD	HL,DE
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A		; HL = MONTH_DAYS[MONTH]
	LD	B,0
	ADD	HL,BC		;      + LEAP_BIAS;
	EX	DE,HL
	POP	HL
	OR	A
	SBC	HL,DE		; DAY = REM_DAYS - HL;
	LD	A,L
	CALL	BIN2BCD
	LD	(TIMSTR+3),A
	POP	DE
	INC	DE		; MONTH++
	LD	A,E
	CALL	BIN2BCD
	LD	(TIMSTR+4),A
	RET

;.....
; Convert DS1202 Hour byte from 12-hour format to 24.
; Entry: A = Hour in DS1202 12-hour or 24-hour format
; Exit:  A = Hour in 24-hour BCD format (00..23)

CVHOUR:	BIT	7,A		; Check 12/24-hours bit
	RET	Z		; Return if already in 24-hour format
	AND	7Fh
	BIT	5,A		; Check AM/PM bit
	RET	Z		; Return if AM
	AND	1Fh
	ADD	A,12h		; Correct if PM
	CP	24h		; Hour >= 24?
	RET	C		; Return if Not
	SUB	24h		; Otherwise correct.
	RET

;.....
; Compute Day of Week from number of days in rem_days
; Entry: HL = rem_days
; Exit:  A = DOW (0 = Sunday)

CDOW:	PUSH	HL
	DEC	HL
	LD	E,7
	CALL	MYDIV16		; DAY OF WEEK = (REM_DAYS - 1) MOD 7
	POP	HL
	RET

;.....
; Compute year from number of days in rem_days
; Entry: HL = rem_days
; Exit:  BC = year

CYEAR:	LD	BC,78		; BASE YEAR
CY1:	LD	DE,365		; YEAR LENGTH
	LD	A,C
	AND	3		; LEAP YEAR?
	JR	NZ,CY2
	INC	DE		; YEAR LENGTH = 366
CY2:	PUSH	HL
	DEC	DE
	OR	A
	SBC	HL,DE		; REM_DAYS - YEAR_LENGTH
	JR	C,CY3		; RETURN IF <= 0
	POP	AF
	DEC	HL
	INC	BC		; YEAR++
	JR	CY1
CY3:	POP	HL
	RET

;.....
; Compute month
; Entry: HL = rem_days, C = leap_bias
; Exit:  DE = month, C = leap_bias

CMONTH:	PUSH	HL
	LD	DE,11		; E = MONTH, D = 0
	LD	B,D		; B = 0
CM1:	LD	A,E
	CP	2		; IF MONTH < 2 (JAN OR FEB)
	JR	NC,CM2
	LD	C,0		; ..LEAP_BIAS = 0
CM2:	LD	HL,MDAYS
	ADD	HL,DE
	ADD	HL,DE
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A		; HL = MONTH_DAYS[MONTH]
	ADD	HL,BC		; MONTH_DAYS[MONTH] + LEAP_BIAS
	EX	DE,HL
	EX	(SP),HL		; HL = WORD VALUE
	LD	A,E
	SUB	L
	LD	A,D
	SBC	A,H
	EX	(SP),HL
	EX	DE,HL
	JR	C,CM3
	DEC	E
	JP	P,CM1
CM3:	POP	HL
	RET

MDAYS:
;		jan feb mar apr may jun jul aug sep oct nov dec
	DW	000,031,059,090,120,151,181,212,243,273,304,334

;.....
; Divide 16-bit number in HL by 8-bit number in E.
; Returns 16-bit quotient in HL, 8-bit remainder in A.

MYDIV16:
	LD	B,16+1		; 17 TIMES THRU LOOP
	XOR	A		; CLEAR REMAINDER AND CARRY
MYDIV:	ADC	A,A		; SHIFT ACCUM LEFT + CARRY
	SBC	A,E		;  SUBTRACT DIVISOR
	JR	NC,MYDIV0	; ..JUMP IF IT WORKED
	ADD	A,E		; ELSE RESTORE ACCUM AND CARRY
MYDIV0:	CCF			; FLIP CARRY BIT
	ADC	HL,HL		;  SHIFT AND CARRY INTO DIVIDEND/QUOTIENT
	DJNZ	MYDIV		;   ..LOOP UNTIL DONE
	RET

;----------------------------------------------------------------------
; Attempt to convert two bytes addressed by HL to a Packed BCD Byte
; Carry Set if Invalid

GETBCD:	CALL	CKDIG
	RET	C		; RETURN IF INVALID
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	C,A
	CALL	CKDIG
	RET	C
	OR	C
	RET

CKDIG:	LD	A,(HL)
	INC	HL
	SUB	'0'
	RET	C
	CP	9+1
	CCF
	RET

;.....
PR2HEX:	PUSH	AF
	RRCA
	RRCA
	RRCA
	RRCA
	CALL	PRHEX
	POP	AF
PRHEX:	AND	0FH
	ADD	A,90H
	DAA
	ADC	A,40H
	DAA
COUT:	LD	E,A
	LD	C,2
	PUSH	HL
	CALL	BDOS
	POP	HL
	RET


TIMSTR:	DS	8			; String for Reading/Setting Date/Time
	DS	64			; Stack Space
STACK:	DS	2

