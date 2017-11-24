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
;; 20140905	- Code start
;;---------------------------------------------------------------------

	TITLE	'TIME MODULE FOR THE MODULAR CP/M 3 BIOS'

	.Z80

	; define logical values:
	include	common.inc
; 	include syshw.inc

	PUBLIC	ZDSTIME

	EXTRN	@DATE,@HOUR,@MIN,@SEC
	EXTRN	@BIOS$STACK ;,?PMSG

	IF	BANKED
	EXTRN	?BANK
	EXTRN	@CBNK
	ENDIF


	CSEG				; time must be done from resident memory

ZDSTIME:
	PUSH	HL
	PUSH	DE

	LD	(SPSAVE),SP
	LD	SP,@BIOS$STACK		; switch to a local stack

	IF	BANKED
	LD	A,(@CBNK)
	PUSH	AF			; save current bank number
	LD	A,0
	CALL	?BANK
	ENDIF

	CALL	DOTIME

	IF	BANKED
	POP	AF
	CALL	?BANK			; restore caller's bank
	ENDIF

	LD	SP,(SPSAVE)
	POP	DE
	POP	HL
	RET

SPSAVE: DW	0

	; ZDS Clock support. Hardware details behind SYSBIOS

	IF	BANKED
	DSEG				; FOLLOWING GOES TO BANKED MEMORY
	ENDIF

DOTIME:
	LD	A,C			; set time ?
	OR	A
        JP	NZ,SETTIME

	LD	HL,TIMSTR		; point to the destination time string
	DI
	CALL	BBRDTIME		; read clock
	EI
	CALL	CDAYS			; compute number of days
	EX	DE,HL
	LD	HL,@DATE
	LD	(HL),E			; store date
	INC	HL
	LD	(HL),D
	INC	HL
	LD	DE,TIMSTR+2		; store time
	LD	A,(DE)			; get hours
	CALL	CVHOUR			; convert to 24-hours format as necessary
	LD	(HL),A			; hours
	DEC	DE
	INC	HL
	LD	A,(DE)
	LD	(HL),A			; minutes
	DEC	DE
	INC	HL
	LD	A,(DE)
	LD	(HL),A			; seconds
	RET

SETTIME:
	LD	HL,@DATE		; hl now points to tod buffer
	LD	E,(HL)			; first word is the date
	INC	HL			; (number of days since 1/1/78)
	LD	D,(HL)
	INC	HL
	PUSH	HL
	EX	DE,HL
	CALL	GETDATE			; convert date to DS1302 format
	POP	HL
	LD	DE,TIMSTR+2
	LD	A,(HL)			; hours
	LD	(DE),A
	INC	HL
	DEC	DE
	LD	A,(HL)			; minutes
	LD	(DE),A
	INC	HL
	DEC	DE
	LD	A,(HL)			; seconds
	LD	(DE),A
	EX	DE,HL			; hl = timstr
	DI
	CALL	BBSTTIM			; activate and set the clock
	EI
	RET


; compute number of days since 1/1/78.
; the algorithm was taken from the mp/m tod program.
; entry: timstr containing date in DS1302 format (bcd)
; exit:  hl = number of days

CDAYS:	LD	A,(TIMSTR+4)		; fetch month
	CALL	BCD2BIN
	DEC	A			; month = 0...11
	ADD	A,A
	LD	E,A
	LD	D,0
	LD	HL,MDAYS
	ADD	HL,DE
	LD	C,(HL)
	INC	HL
	LD	B,(HL)			; onth_days[month]
	LD	A,(TIMSTR+6)		; fetch year
	CALL	BCD2BIN
	SUB	78			; 1978
	JR	NC,CD1
	ADD	A,100			; if year was < 78, consider it as >= 2000
CD1:	LD	DE,365
	LD	L,A
	LD	H,D
	CALL	MLTHL
	LD	H,L
	LD	L,0
	LD	D,A
	CALL	MLTDE
	ADD	HL,DE			; hl = a * 365
	ADD	HL,BC			; + month_days[month]
	LD	A,(TIMSTR+3)		; fetch day
	CALL	BCD2BIN
	LD	C,A			; day = 1...29,30, or 31
	LD	B,0
	ADD	HL,BC			; + day
	PUSH	HL
	LD	HL,78			; 1978
	LD	DE,0
	CALL	LEAPDAYS
	EX	DE,HL
	POP	HL
	OR	A
	SBC	HL,DE			; - leap_days(78, 0)
	PUSH	HL
	LD	A,(TIMSTR+6)		; year
	CALL	BCD2BIN
	CP	78
	JR	NC,CD2
	ADD	A,100
CD2:	LD	L,A
	LD	H,0
	LD	A,(TIMSTR+4)		; month
	CALL	BCD2BIN
	DEC	A			; month = 0...11
	LD	E,A
	LD	D,0
	CALL	LEAPDAYS
	POP	DE
	ADD	HL,DE			; + leap_days(year, month)
	RET

LEAPDAYS:
	LD	H,0			; just in case... (h should be already 0)
	LD	A,L
	RRCA
	RRCA
	AND	3FH
	LD	L,A			; hl = year / 4
	AND	3
	RET	NZ
	PUSH	HL
	LD	HL,MDAYS
	ADD	HL,DE
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)			; month_days[month]
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
; convert 2-digit bcd value to 8-bit binary.
; entry: a = bcd value
; exit:  a = binary value

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
; convert DS1302 hour byte from 12-hour format to 24.
; entry: a = hour in DS1302 12-hour or 24-hour format
; exit:  a = hour in 24-hour bcd format (00..23)

CVHOUR:	BIT	7,A			; check 12/24-hours bit
	RET	Z			; return if already in 24-hour format
	AND	7Fh
	BIT	5,A			; check am/pm bit
	RET	Z			; return if am
	AND	1Fh
	ADD	A,12h			; correct if pm
	CP	24h			; hour >= 24?
	RET	C			; return if not
	SUB	24h			; otherwise correct.
	RET

;.....
; compute day of week from number of days in rem_days
; entry: hl = rem_days
; exit:  a = dow (0 = sunday)

CDOW:	PUSH	HL
	DEC	HL
	LD	E,7
	CALL	MYDIV16			; day of week = (rem_days - 1) mod 7
	POP	HL
	RET

;.....
; divide 16-bit number in hl by 8-bit number in e.
; returns 16-bit quotient in hl, 8-bit remainder in a.

MYDIV16:
	LD	B,16+1
	XOR	A
MYDIV:	ADC	A,A
	SBC	A,E
	JR	NC,MYDIV0
	ADD	A,E
MYDIV0:	CCF
	ADC	HL,HL
	DJNZ	MYDIV
	RET

;.....
; compute year from number of days in rem_days
; entry: hl = rem_days
; exit:  bc = year

CYEAR:	LD	BC,78			; base year
CY1:	LD	DE,365			; year length
	LD	A,C
	AND	3			; leap year?
	JR	NZ,CY2
	INC	DE			; year length = 366
CY2:	PUSH	HL
	DEC	DE
	OR	A
	SBC	HL,DE			; rem_days - year_length
	JR	C,CY3			; return if <= 0
	POP	AF
	DEC	HL
	INC	BC			; year++
	JR	CY1
CY3:	POP	HL
	RET

;.....
; compute month
; entry: hl = rem_days, c = leap_bias
; exit:  de = month, c = leap_bias

CMONTH:	PUSH	HL
	LD	DE,11			; e = month, d = 0
	LD	B,D			; b = 0
CM1:	LD	A,E
	CP	2			; if month < 2 (jan or feb)
	JR	NC,CM2
	LD	C,0			; ..leap_bias = 0
CM2:	LD	HL,MDAYS
	ADD	HL,DE
	ADD	HL,DE
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A			; hl = month_days[month]
	ADD	HL,BC			; month_days[month] + leap_bias
	EX	DE,HL
	EX	(SP),HL			; hl = word value
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
;;	mul16 - 16x16 bit multiplication
;;
;; 	in  de = multiplicand
;;	    bc = multiplier
;;	out de = result
MUL16:	LD	A,C			; A = low mpler
	LD	C,B			; C = high mpler
	LD	B,16			; counter
	LD	HL,0
ML1601:	SRL	C			; right shift mpr high
	RRA				; rot. right mpr low
	JR	NC,ML1602		; test carry
	ADD	HL,DE			; add mpd to result
ML1602:	EX	DE,HL
	ADD	HL,HL			; double shift mpd
	EX	DE,HL
	DJNZ	ML1601
	RET

;.....
; convert mp/m time-of-day value to DS1302 format.
; entry: hl = tod (number of days since 1/1/78)
; exit:  timstr buffer updated accordingly.

GETDATE:
	CALL	CDOW			; compute day of week
	INC	A			; base 1
	LD	(TIMSTR+5),A
	POP	HL
	CALL	CYEAR			; compute year, returns rem_days remainder
	LD	A,C
	CP	100			; above year 2000?
	JR	C,GD0
	SUB	100			; correct if yes
GD0:	CALL	BIN2BCD			; convert to bcd
	LD	(TIMSTR+6),A
	LD	E,0			; leap_bias = 0
	LD	A,C
	AND	3			; (year & 3) == 0 ?
	JR	NZ,GD1
	LD	A,L
	SUB	59+1			; ..and (rem_days > 59) ?
	LD	A,H
	SBC	A,0
	JR	C,GD1
	INC	E			; ..then leap_bias = 1;
GD1:	LD	C,E
	CALL	CMONTH			; compute month
	PUSH	DE
	PUSH	HL
	LD	HL,MDAYS
	ADD	HL,DE
	ADD	HL,DE
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A			; hl = month_days[month]
	LD	B,0
	ADD	HL,BC			; + leap_bias;
	EX	DE,HL
	POP	HL
	OR	A
	SBC	HL,DE			; day = rem_days - hl;
	LD	A,L
	CALL	BIN2BCD
	LD	(TIMSTR+3),A
	POP	DE
	INC	DE			; month++
	LD	A,E
	CALL	BIN2BCD
	LD	(TIMSTR+4),A
	RET

;.....
; convert 8-bit binary value to 2-digit bcd.
; entry: a = binary value
; exit:  a = bcd value

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


MDAYS:
;		jan feb mar apr may jun jul aug sep oct nov dec
	DW	000,031,059,090,120,151,181,212,243,273,304,334

TIMSTR:
	DB	0,0,0,0,0,0,0,0		; string for reading/setting date/time


	END
