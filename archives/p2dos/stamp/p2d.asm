; 	TITLE	"CP/M+ (P2DOS) Time for ZSDOS"
;===============================================================;
;  P2D - ZSDOS Driver for P2DOS (CP/M Plus compatible) Stamps	;
;---------------------------------------------------------------;
; Copyright (C) 1988  by Harold F. Bower and Cameron W. Cotrill	;
;---------------------------------------------------------------;
; Portions of this code were derived from code written by	;
;	 H.A.J. Ten Brugge					;
;								;
; FUNCTION:   To convert from DateStamper(tm) "type"  date/time	;
; string  to  the  5-byte date/time  string required for P2DOS.	;
; This code provides the time functions for ZSDOS to operate in	;
; a P2DOS (CP/M Plus compatible) type Date/Time stamping mode.	;
;								;
; Universal Time String	    :	YY MM DD HH MM SS  (all BCD)	;
;								;
; CP/M+ (P2DOS) Time String :	nnnn HH MM SS			;
;    nnnn = binary number of days since start (1 = 1 Jan 1978)	;
;				HH MM SS = time in BCD		;
;								;
; Version:							;
;	1.0 - Initial Release			16 Sep 88	;
;===============================================================;

; VER	EQU	11		; Initial Release

; FALSE	EQU	0
; TRUE	EQU	NOT FALSE

; 	MACLIB	RSXFLAG		; Get the definition of RSX equate flag
				; TRUE=Assemble as RSX, FALSE=Hi-memory module
				;== ALSO VERSION DEPENDENT ADDRESSES
TIMOFF	EQU	0016H		; Time Vector group offset
LSTOFF	EQU	0018H		; Stamp Last Accessed routine addr
CREOFF	EQU	001AH		; Stamp Create Time routine addr
MODOFF	EQU	001CH		; Stamp Modify Time routine addr
GSTOFF	EQU	001EH		; Get Stamp routine addr
SSTOFF	EQU	0020H		; Set Stamp routine addr

; DOSID	EQU	'S'		; ID tag for ZSDOS
; DOSVER	EQU	11H		; ZSDOS version number for this module
; 	PAGE

	ORG	(FCP-ZDSSTSZ)	; We are at the top of the RCP area

	JP	STAMPC		; jump table to make stuffs easy in zsdos...
	JP	STAMPU
	JP	GSTAMP
	JP	PSTAMP

;===============================================================+
; Stamp CREATE/UPDATE Time Field in T&D. (Extracted from PZDOS)	|
; ------------------------					|
;   Read the Real Time Clock via SGSTIM vector in Universal	|
;   format to buffer, convert to CP/M+ (P2DOS) format, and	|
;   move to appropriate field in DIR Buffer.			|
;---------------------------------------------------------------|
; Enter: A = Directory Offset (0, 20H, 40H) of subject file	|
;	BC = Address of WRFCB routine in ZSDOS			|
;	DE = Pointer to DIR Buffer.  (Offset in A)		|
;								|
; Exit : A = 1 if OK, Else A = 0FFH if error.  Flags undefined	|
;								|
; Effects: Current DMA Buffer altered				|
;===============================================================+


STAMPC:	LD	L,0		; Set to Create field in Stamp
	JR	STTIM		; ..and join common code

;.....
STAMPU:	LD	L,4		; Set to Update field in Stamp
STTIM:	CALL	SETREC		; Use DE offset to rec in A.  Save L in E
	LD	C,E		; Move Create/Update offset to C (B=0)
	ADD	HL,BC		; Destination of 4-byte T&D now in HL
	LD	DE,DSTIME	; Set address to read time
	PUSH	HL		; ..save destination addr
	PUSH	DE		; ..and source addr
	LD	C,B		; Set C=0 for Clock Read
	LD	HL,(BDOSB+TIMOFF)	; Clock driver address
	LD	(CACLDR),HL	; set call addr
CACLDR	EQU	$+1		; where to place clock driver address
	CALL	0		; Push
; 	CALL	RWCLK		; Read the clock module
	POP	DE		; Restore source addr
	POP	HL		; ..and destination addr
	DEC	A		; Was the clock read Ok? (1-->0 if Ok)
	JR	NZ,NOTIM0	; ..jump Error exit if Not
	CALL	U2PTIM		; Cv Univ. time at (DE) to CP/M+ time at (HL)
	JR	WRFCB0		; Write FCB, Set return flags and exit

;===============================================================+
; Get File Stamps in Universal Format				|
; ---------------						|
;   Read the Create and Update Stamps and convert to Universal	|
;   format in the proper fields at the specified address.  Null	|
;   the Last Access Time field.					|
;---------------------------------------------------------------|
; Enter: A = Directory Offset (0, 20H, 40H) of subject file	|
;	DE = Pointer to DIR Buffer.  (Offset in A)		|
;	HL = DMA Address to receive 15 byte Stamp frame		|
;								|
; Exit : A = 1 if OK, Else A = 0FFH if error.  Flags undefined	|
;								|
; Effects : DMA Buffer contains the 15-byte frame if successful	|
;===============================================================+

GSTAMP:	CALL	SETREC		; Calculate T&D address (HL saved in DE)
	CALL	P2UTIM		; Convert P-tim at (HL) to U-tim at (DE)
	LD	B,5		; Zero Last Access field for this type
GSLOOP:	LD	(DE),A		; ..by poking a zero..(A=0 from P2UTIM)
	INC	DE
	DJNZ	GSLOOP		; ..in each location
	CALL	P2UTIM		; Convert Modified field (P@HL to U@DE)
	JR	OKRET		; Set OK return status

;===============================================================+
; Put File Stamps in Universal Format				|
; ---------------						|
;   Convert Create and Update Time fields from Universal format	|
;   to CP/M+ (P2DOS) form and insert in DIRectory buffer.  Call	|
;   WRFCB routine to write Directory on exit.			|
;---------------------------------------------------------------|
; Enter: A = Directory Offset (0, 20H, 40H) of subject file	|
;	BC = Address of WRFCB Routine in ZSDOS			|
;	DE = Pointer to DIR Buffer.  (Offset in A)		|
;	HL = DMA Address containing 15 byte Stamp frame		|
;								|
; Exit : A = 1 if OK, Else A = 0FFH if error.  Flags undefined	|
;								|
; Effects : Addressed DIR buffer updated on disk if successful	|
;===============================================================+

PSTAMP:	CALL	SETREC		; Calculate the Stamp area addr for file
				; DE-->DMA buff, HL-->P2DOS Create field
	CALL	U2PTIM		; Convert Create field to destination
	JR	NZ,NOTIM0	; ..error exit if invalid date
	INC	DE		; Advance to Update field
	INC	DE
	INC	DE
	INC	DE
	INC	DE
	CALL	U2PTIM		; Convert Update field to destination
WRFCB0:	JR	NZ,NOTIM0	; ..error exit if invalid date
WRFCB:	CALL	$-$		; Address set on entry
OKRET:	LD	A,1		; Else set OK flags and return
	RET

;.....

NOTIM:	POP	AF		; Clear the stack
NO$TD:	POP	AF
NOTIM0:	OR	0FFH		; ..and set error flags
	RET			; Back to caller

;---------------------------------------------------------------;
; Convert Universal T&D to addrsd buffer in CP/M+ (P2DOS) form.	;
;								;
; Enter: DE = Address of start of Universal T&D string		;
;	 HL = Address of buffer to receive CP/M+ (P2DOS) T&D	;
; Exit :  A = 0, Zero Flag Set (Z), Time string set if Ok..	;
;	  A = FF, Zero Reset (NZ), Time string unchanged on Err	;
;	 DE --> Seconds byte in Universal field (Not moved)	;
;	 HL --> Seconds byte in CP/M+ (P2DOS) field (Not filled);
; Uses : All primary registers.					;
;---------------------------------------------------------------;

U2PTIM:	PUSH	HL		; Save destination address
	LD	A,(DE)		; Get BCD Year
	LD	B,A		; ..to B
	INC	DE		; Advance to Month
	LD	A,(DE)		; Get BCD Month
	OR	B		; Is it Invalid (YY=MM=00)?
	JR	Z,NODATE	; ..jump to error exit if Invalid stamp
	LD	A,B		; Get BCD Year again from B
	CALL	BCDHEX		; Convert year to Binary
	CP	78		; Is it 20th Century?
	JR	NC,YR19		; ..jump if so
	ADD	A,100		; Else move to 21st Century
YR19:	LD	BC,1900		; Set base century
	ADD	A,C		; Add current year to Base
	LD	C,A
	LD	A,00
	ADC	A,B
	LD	B,A
	LD	A,(DE)		; Get BCD Month
	INC	DE
	CALL	BCDHEX		; ..convert to Binary
	LD	H,A
	LD	A,(DE)		; Get Day
	INC	DE		; Point to U-Hours
	PUSH	DE		; ..and save addr on stack
	CALL	BCDHEX		; ..convert Day to Binary
	LD	L,A		; Day to L (binary)

; Check validity of day, month, year.  (CHKDAT..From DATE.ASM)
; Enter:  L = binary day
;	  H = binary month
;        BC = binary year

	LD	A,H		; Month must be..
	DEC	A		; Convert valid Month to 0-11 range
	CP	12		; Is it a valid Month?
	JR	NC,BADDAT	; ..jump error if invalid
	PUSH	HL		; Save year
	LD	E,A
	LD	D,0
	LD	HL,DM		; Set lookup table for months
	ADD	HL,DE
	LD	D,(HL)		; Get days in this month
	POP	HL
	CP	1		; Is this February? (2-1)
	CALL	Z,LEAPYR	; ..check for leap year if so
	JR	NZ,CHKDT0	; ..jump if not
	INC	D		; else make 29 days
CHKDT0:	LD	A,L		; Check for day within range
	DEC	A		; Have day > 0, check for <= max day
	CP	D
	JR	NC,BADDAT	; ..anything else is error

; Calculate 16-bit Binary Date since 1978 in Days
; Entry: BC = Year (1978..2077) (really works til 2157)
;	  H = Month (1..12)
;	  L = Days (1..31)
; Exit : DE = Days	First day (0001H) : Su 01 Jan 1978
;			Last day  (8EADH) :    31 Dec 2077
;		   Real Last day  (FFFFH) : Su 05 Jun 2157

	PUSH	HL		; Save Month (H) and Day (L)
	LD	H,0		; Null out Month leaving just days
	EX	DE,HL		; ..move to DE
	LD	L,C		; Move current Year to HL
	LD	H,B
	LD	BC,1978		; Start with base year in BC
DAYS0:	OR	A
	SBC	HL,BC		; Is this the starting year?
	ADD	HL,BC
	JR	Z,DAYS1		; ..jump if so
	PUSH	HL
	LD	HL,365		; Add days in non-leap year
	ADD	HL,DE		; ..to total days count in DE
	EX	DE,HL		; ...and put new Days total in DE
	POP	HL
	CALL	LEAPYR		; Is this a Leap year?
	INC	BC		; ..(advance to next year)
	JR	NZ,DAYS0	; ..loop if not Leap Year
	INC	DE		; Else add a day
	JR	DAYS0		; ..then loop

; Error routines.  Set destination P2Dos field to all Zeros

NODATE:	INC	DE		; Advance source ptr for same routine
	INC	DE
	DEFB	03EH		; ..fall thru to 2nd POP with LD  A,0D1H

BADDAT:	POP	DE		; Restore Universal string (--> Hrs)
	POP	HL		; Restore Destination Addr for P2DOS Date
	LD	B,4		; Fill Destination field with Nulls
BADDA1:	XOR	A
BLOOP:	LD	(HL),A
	INC	HL
	DJNZ	BLOOP		; ..loop til filled
	INC	DE		; ..Advance to Exit pointer conditions
	INC	DE
	DEC	A		; Set error Flags (A=FF, Zero Clear (NZ))
	RET

; DE=Binary Day total (Year & Day only).  Mo & Da on stack, BC=Current Year

DAYS1:	POP	HL		; Restore Month & Day
	EX	DE,HL		; Binary date to HL, Mo & Day to DE
	PUSH	HL		; ..and save Binary date
	LD	HL,DM		; Address days-of-month table
	LD	E,1
DAYS2:	LD	A,D		; Check for matching month
	CP	E
	JR	Z,DAYS4		; ..exit when match
	LD	A,(HL)		; Get days in this month
	EX	(SP),HL		; Put table on stack, Binary date to HL
	ADD	A,L		; Add this month's days to Cum Binary Date
	LD	L,A
	LD	A,00
	ADC	A,H
	LD	H,A
	LD	A,E		; Check this month
	CP	2		; ..for Feb
	CALL	Z,LEAPYR	; If so, Is it a Leap Year?
	JR	NZ,DAYS3A	; ..jump if Not Leap Year and/or Not Feb
	INC	HL		; Else bump Cum Bin Date by 29 Feb
DAYS3A:	EX	(SP),HL		; Put Cum Bin date to stack, Mo Table to HL
	INC	HL		; Point to next month
	INC	E		; Bump index counter
	JR	DAYS2		; ..and loop

DAYS4:	POP	BC		; Exit here..Put Cum Binary Date to BC
	POP	DE		; Restore Universal string (--> Hrs)
	POP	HL		; ..and Destination addr from stack
	LD	(HL),C		; Put binary date in string
	INC	HL
	LD	(HL),B
SAVEM:	INC	HL
	EX	DE,HL		; Pointers to correct regs
	LDI			; Move BCD Hours..
	LDI			; ..and BCD Minutes
	EX	DE,HL		; Restore regs for exit conditions
	XOR	A		; Set OK flags and return
	RET

;---------------------------------------------------------------;
; Convert CP/M+ (P2DOS) Time to Universal Time string		;
;								;
; Enter: HL = Points to CP/M+ (P2DOS) T&D entry			;
;	 DE = Addr of destination Universal T&D entry		;
; Exit :  A = 0, Zero Flag Set (Z) Dest Date conv if OK, else..	;
;	  A = FF, Zero Clear (NZ) Dest Nulled if Error		;
;	 HL --> Seconds byte of Source P2DOS T&D (Not moved)	;
;	 DE --> Seconds byte of Dest Universal T&D (Not filled)	;
; Uses : All primaty registers.					;
;---------------------------------------------------------------;

P2UTIM:	PUSH	DE		; Save Universal T&D address on stack
	LD	E,(HL)		; Get binary date to DE
	INC	HL
	LD	D,(HL)
	INC	HL
	EX	DE,HL		; Put Binary Day/date in HL, P2Dos ptr in DE
	LD	A,H		; Check for valid entry
	OR	L		; Is date present?
	JR	NZ,P2UTI0	; ..jump if Not Null entry
	POP	HL		; Get Universal T&D Dest addr back
	LD	B,5
	CALL	BADDA1		; ..and null the U-Time field
	EX	DE,HL		; Put ptrs in correct regs
	RET			; ..and return to caller

P2UTI0:	PUSH	DE		; Save P2D Time pointer (--> Min)
	LD	BC,1978		; Beginning year
DMJ0:	LD	DE,365		; Set days in normal year
	CALL	LEAPYR		; ..check for leap year
	JR	NZ,DMJ1		; ..jump if not
	INC	DE
DMJ1:	OR	A		; When # of days left..
	SBC	HL,DE		; ..is less than days in year..
	JR	C,DMJ2		; ..year is in HL, so exit
	JR	Z,DMJ2		; ...or her if last day of Year
	INC	BC		; Bump starting year
	JR	DMJ0		; ..and back for another try

; When get here, binary year is in BC, remaining days in HL

DMJ2:	ADD	HL,DE		; Compensate for above underflow
	LD	A,1		; Start with month # 1 (Jan)
	LD	D,0		; ..prepare for 16-bit math
	PUSH	HL		; Save days remaining
	LD	HL,DM		; ..and address month table
DMJ3:	LD	E,(HL)		; Get days in current Mo to E
	CP	2		; Is it Feb?
	CALL	Z,LEAPYR	; ..Check for leap year if Feb
	JR	NZ,DMJ4		; Jump if not leap year
	INC	E		; ..else compensate
DMJ4:	EX	(SP),HL		; Swap pointer (HL) with Days Remaining (stk)
	OR	A
	SBC	HL,DE		; Subtract days in Month from Remaining days
	JR	C,DMJ5		; ..Exit if we've gone too far
	JR	Z,DMJ5		; ...or just far enough (last day of month)
	EX	(SP),HL
	INC	HL		; Point to next month in table
	INC	A		; ..bump month counter
	JR	DMJ3		; ..and Try again

; Arrive here with Binary year on Stack Top, Relative month in A (Jan = 1),
;   Days in that month in E, and binary year in BC.

DMJ5:	ADD	HL,DE		; Compensate for underflow
	EX	(SP),HL		; ..and put back on stack
	POP	HL		; Restore Day in L
	CALL	BINBCD		; Convert Month (in A) to BCD
	LD	H,B		; ..moving Year to HL
	LD	B,A
	LD	A,L		; Convert Day
	LD	L,C
	CALL	BINBCD		; ..to BCD
	LD	C,A
	LD	DE,100		; Subtract centuries, one by one..
DMJ7A:	OR	A
	SBC	HL,DE
	JR	NC,DMJ7A	; ..until we go too far
	ADD	HL,DE		; Then correct for underflow
	LD	A,L		; Get Years (tens and ones)
	CALL	BINBCD		; ..to BCD

	POP	DE		; Restore P2D Time Pointer (--> Min)
	POP	HL		; Get Universal time string addr
	LD	(HL),A		; Store Years..
	INC	HL
	LD	(HL),B		; ..Months
	INC	HL
	LD	(HL),C		; ..Days
	CALL	SAVEM		; Store Hours and Minutes & Set flags
	EX	DE,HL		; Put U-tim exit addr in DE
	RET			; ..and finish up elsewhere

;.....
; Calculate Leap Year correction (xxxxxx00B for Leap Years)
; Enter: BC = Binary year
; Exit :  Z = 1 (set (Z)) Correction necessary
;	  Z = 0 (clear (NZ)) No correction needed

LEAPYR:	BIT	0,C		; Get lower part of date
	RET	NZ		; ..return if not Leap year
	BIT	1,C		; Test other bit
	RET			; ..and return

;.....
; Convert BCD to HEX
; Enter: A = BCD digit to be converted
; Exit : A = HEX (binary) conversion
;		 All registers preserved

BCDHEX:	OR	A
	RET	Z		; Zero is same
	PUSH	BC		; Save register
	LD	B,0		; Set counter
BCDHX0:	INC	B		; Bump counter
	SUB	1		; Count down BCD..
	DAA
	JR	NZ,BCDHX0	; ..til all gone
	LD	A,B
	POP	BC
	RET

;.....
; Convert byte in A register to two packed BCD digits.

BINBCD:	PUSH	BC		; Affect only A register
	LD	B,0FFH		; Preset counter
BINBCL:	INC	B		; Bump output count
	SUB	10
	JR	NC,BINBCL	; Loop bumping counter til no more 10s
	ADD	A,10		; ..correct for underflow
	LD	C,A		; Save low nybble here for a while
	LD	A,B		; ..and bring hi one here..
	ADD	A,A		; Move it into position
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,C		; Add in Low nybble
	POP	BC		; Restore regs
	RET

;---------------------------------------------------------------+
; Calculate offset within T&D Record if one exists.		;
;								;
; Enter: A = Sector Pointer (0,20H,40H,60H)			;
;	BC = Points to the ZSDOS WRFCB routine			;
;	DE = Points to Directory Sector Buffer			;
; Exit : A = 0, Zero Flag Set (Z), If Ok, else A <> 0, (NZ)	;
;	HL = First byte of Create Date for record if OK		;
; Uses : HL (Entry DE), AF, BC.  Entry HL preserved in DE	;
;---------------------------------------------------------------+

SETREC:	LD	(WRFCB+1),BC	; Save Directory Write Routine address
	EX	DE,HL		; DIR sector to HL for adr calcs
	LD	BC,060H		; Offset to T&D Fields
	ADD	HL,BC
	LD	C,A		; ..Sector pointer to register
	LD	A,(HL)		; Get byte
	SUB	21H		; Is TimeStamping present?
	JP	NZ,NO$TD	; ..quit here if not
	LD	A,C		; Restore Sector pointer from storage
	RRCA			; Shift 2 times
	RRCA
	LD	C,A		; ..save temporarily
	RRCA			; Shift 2 more times
	RRCA
	ADD	A,C		; ..and add in again
	LD	C,A		; Set for offset (C=0,10,20)
	ADD	HL,BC		; Add offset
	INC	HL		; ..and bump to Create Time Start
	XOR	A		; Set good return status
	RET

;===================================================;
;===|		D A T A     A R E A  		|===;
;===================================================;
; Put in CSEG to make single module

;.....
; Days-in-Month table

DM:	DEFB	31,28,31,30,31,30,31,31,30,31,30,31

;.....
; Time/Date String in Universal Format

DSTIME:	DEFB	0,0,0,0,0,0

;******************************************************************
; Clock Driver for ZSDOS
;
; This routine interfaces the ZSDOS Time interface to a physical
; clock driver routine.  The ZSDOS interface is:
;
;	Entry conditions:
;		C  = Read/Write Code (1=Write, 0=Read)
;		DE = Address to Put/Set Time
;
; The Error return code on Clock Set is overwritten during instal-
; lation if a ZSDOS clock driver (with two jumps) is detected, with
; a relative jump to the clock set vector.  This short routine also
; places the time address in the HL registers to be compatible with
; DateStamper clock specifications.
;******************************************************************

; RWCLK:	EX	DE,HL		; Set registers for DS clock interface
; 	LD	A,C
; 	OR	A		; Read (0) or Write (<>0)
; 	JR	Z,CLK		; Read clock if Zero..
;
; ; The following Error Return code is overwritten if ZSDOS clock added
;
; 	XOR	A		; Set error return
; 	DEC	A
; 	RET

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;		C l o c k     D r i v e r
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
; Actual clock driver or vector to external routine added here

; CLK:

; TOP	EQU	$
;
; 	END
