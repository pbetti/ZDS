
;
; Test Program to intreact with the CPM3 type BIOS for my IDE intreface board
;	Author John Monahan		www.S100Computers.com
;==============================================================================
;	CPM3 BIOS for IDE Controller board using LBA Mode sector addressing
;
	; INCLUDE Z-80 MACRO LIBRARY:
; 	MACLIB	Z80

;------------------------------------------------------------------
; Hardware Configuration
;	10/16/2009	V1.0	Initial version, just Disk ID routine checked out OK.
;	10/16/2009	V1.1	Sector R/W started. Problems with sec 0 & 1. 
;	10/16/2009	V1.2	Added sequential sector reads 
;	10/17/2009	V1.3	Reformed interface to recognize CPM style TRK#/Sec#
;	10/17/2009	V1.4	Utilize all 15 heads instead of 8 (16bit /8 divide)
;	10/19/2009	V1.5	Use HEADS equate, remove delay routine
;	10/23/2009	V1.6	Byte order (big endian/little endian) converted to Intel
;				format of low byte then high byte of sector data. This was 
;				necessary to be compatable with every other IDE drive out there.
;
;

;Ports for 8255 chip. Change these to specify where the 8255 is addressed,
;and which of the 8255's ports are connected to which IDE signals.
;The first three control which 8255 ports have the control signals,
;upper and lower data bytes.  The last one is for mode setting for the
;8255 to configure its ports, which must correspond to the way that
;the first three lines define which ports are connected.

IDEPORTA	EQU	0E0H		;lower 8 bits of IDE interface
IDEPORTB	EQU	0E1H		;upper 8 bits of IDE interface
IDEPORTC	EQU	0E2H		;control lines for IDE interface
IDEPORTCTRL	EQU	0E3H		;8255 configuration port

READCFG8255	EQU	10010010B	;Set 8255 IDEportC out, IDEportA/B input
WRITECFG8255	EQU	10000000B	;Set all three 8255 ports output

;IDE control lines for use with IDEportC.  Change these 8
;constants to reflect where each signal of the 8255 each of the
;IDE control signals is connected.  All the control signals must
;be on the same port, but these 8 lines let you connect them to
;whichever pins on that port.

IDEA0LINE	EQU	01H		;direct from 8255 to IDE interface
IDEA1LINE	EQU	02H		;direct from 8255 to IDE interface
IDEA2LINE	EQU	04H		;direct from 8255 to IDE interface
IDECS0LINE	EQU	08H		;inverter between 8255 and IDE interface
IDECS1LINE	EQU	10H		;inverter between 8255 and IDE interface
IDEWRLINE	EQU	20H		;inverter between 8255 and IDE interface
IDERDLINE	EQU	40H		;inverter between 8255 and IDE interface
IDERSTLINE	EQU	80H		;inverter between 8255 and IDE interface
;
;Symbolic constants for the IDE Drive registers, which makes the
;code more readable than always specifying the address pins

REGDATA		EQU	IDECS0LINE
REGERR		EQU	IDECS0LINE + IDEA0LINE
REGSECCNT	EQU	IDECS0LINE + IDEA1LINE
REGSECTOR	EQU	IDECS0LINE + IDEA1LINE + IDEA0LINE
REGCYLINDERLSB	EQU	IDECS0LINE + IDEA2LINE
REGCYLINDERMSB	EQU	IDECS0LINE + IDEA2LINE + IDEA0LINE
REGSHD		EQU	IDECS0LINE + IDEA2LINE + IDEA1LINE		;(0EH)
REGCOMMAND	EQU	IDECS0LINE + IDEA2LINE + IDEA1LINE + IDEA0LINE	;(0FH)
REGSTATUS	EQU	IDECS0LINE + IDEA2LINE + IDEA1LINE + IDEA0LINE
REGCONTROL	EQU	IDECS1LINE + IDEA2LINE + IDEA1LINE
REGASTATUS	EQU	IDECS1LINE + IDEA2LINE + IDEA1LINE + IDEA0LINE

;IDE Command Constants.  These should never change.

COMMANDRECAL	EQU	10H
COMMANDREAD	EQU	20H
COMMANDWRITE	EQU	30H
COMMANDINIT	EQU	91H
COMMANDID	EQU	0ECH
COMMANDSPINDOWN	EQU	0E0H
COMMANDSPINUP	EQU	0E1H
;
;
; IDE Status Register:
;  bit 7: Busy	1=busy, 0=not busy
;  bit 6: Ready 1=ready for command, 0=not ready yet
;  bit 5: DF	1=fault occured insIDE drive
;  bit 4: DSC	1=seek complete
;  bit 3: DRQ	1=data request ready, 0=not ready to xfer yet
;  bit 2: CORR	1=correctable error occured
;  bit 1: IDX	vendor specific
;  bit 0: ERR	1=error occured
;
;
CR		EQU	0DH
LF		EQU	0AH
ESC		EQU	1BH
CLEAR		EQU	1CH		;SD Systems Video Board, Clear to EOL. (Use 80 spaces if EOL not available
					;on other video cards)
;	
MAXSEC		EQU	3DH		;Sectors per track for CF my Memory drive, Kingston CF 8G. (CPM format, 0-3CH)
					;translates to LBA format of 1 to 3D sectors, for a total of 61 sectors/track.
					;This CF card actully has 3F sectors/track. Will use 3D for my CPM3 system because
					;my Seagate drive has 3D sectors/track. Don't want different CPM3.SYS files around
;					;so this program will also work with a Seagate 6531 IDE drive

RDCON		EQU	1		;For CP/M I/O
WRCON		EQU	2
PRINT		EQU	9
CONST		EQU	11		;CONSOLE STAT
BDOS		EQU	5
OFSCOR		EQU	-2

TRUE		EQU	-1
FALSE		EQU	0

CPM		EQU	TRUE		; TRUE if output via CPM, FALSE if direct to hardware
DEBUG		EQU	TRUE
CPMTRASL	EQU	TRUE		;Translate Trk,Sec,Head to CPM TRACK# & SEC#

	IF	CPM
ABORT	EQU	0H
	ELSE	
ABORT	EQU	0F000H
	ENDIF	
;
;
	ORG	100H
;
BEGIN:
	LD	SP,STACK
	LD	DE,SIGNON	;print a welcome message
	CALL	PSTRING
	
	CALL	IDEINIT		;initialize the board and drive. If there is no drive abort
	JP	Z,INITOK
	LD	DE,INITERROR
	CALL	PSTRING
	CALL	SHOWERRORS
	JP	ABORT
	

INITOK:
	CALL	DRIVEID		;get the drive id info. If there is no drive abort
	JP	Z,INITOK1
	LD	DE,IDERROR
	CALL	PSTRING
	CALL	SHOWERRORS
	JP	ABORT

INITOK1:
	LD	DE, MSGMDL	;print the drive's model number
	CALL	PSTRING
	LD	HL,IDBUFFER + 54 + OFSCOR
	LD	B,20		;character count in words
	CALL	PRINTNAME	;Print [HL], [B] X 2 characters
	CALL	ZCRLF
				; print the drive's serial number
	LD	DE, MSGSN
	CALL	PSTRING
	LD	HL,IDBUFFER + 20 + OFSCOR
	LD	B, 10		;Character count in words
	CALL	PRINTNAME
	CALL	ZCRLF
				;Print the drive's firmware revision string
	LD	DE, MSGREV
	CALL	PSTRING
	LD	HL,IDBUFFER + 46 + OFSCOR
	LD	B, 4
	CALL	PRINTNAME	;Character count in words
	CALL	ZCRLF
				;print the drive's cylinder, head, and sector specs
	LD	DE, MSGCY
	CALL	PSTRING
	LD	HL,IDBUFFER + 2 + OFSCOR
	CALL	PRINTPARM
	LD	DE,MSGHD
	CALL	PSTRING
	LD	HL,IDBUFFER + 6 + OFSCOR
	CALL	PRINTPARM
	LD	DE, MSGSC
	CALL	PSTRING
	LD	HL,IDBUFFER + 12 + OFSCOR
	CALL	PRINTPARM
	CALL	ZCRLF
				;Default position will be first block 
	LD	HL,0
	LD	(@SEC),HL	;Default to Track 0, Sec 0
	LD	(@TRK),HL
	LD	HL,BUFFER	;Set DMA address to buffer
	LD	(@DMA),HL

MAINLOOP: 			;A 1 line prompt
	CALL	ZCRLF	
	CALL	DISPLAYPOSITION	;Display current Track,sector,head#
	CALL	ZCRLF

	LD	DE,CMDSTRING	;List command options
	CALL	PSTRING
	CALL	ZCI
	CP	ESC		;Abort if ESC
	JP	Z,ABORT
	CALL	UPPER
	CALL	ZCRLF

MAIN1:	CP	'R'		;read a sector @ LBA to buffer
	JP	NZ,MAIN2

	CALL	READSECTOR

	JP	Z,MAIN1B	;Z means the sector read was OK
	CALL	ZCRLF
	JP	MAINLOOP
MAIN1B:	LD	DE, MSGRD	;Sector read OK
	CALL	PSTRING
	JP	MAINLOOP

MAIN2:	CP	'W'		;write a sector @ LBA buffer
	JP	NZ,MAIN3		
	LD	DE,MSGSURE	;Are you sure?
	CALL	PSTRING
	CALL	ZCI
	CALL	UPPER
	CP	'Y'
	JP	NZ,MAIN2C
	CALL	ZCRLF
	
	LD	HL,$3000
	LD	(@DMA),HL

	CALL	WRITESECTOR

	LD	HL,BUFFER
	LD	(@DMA),HL

	JP	Z,MAIN2B	;Z means the sector write was OK
	CALL	ZCRLF
	JP	MAINLOOP
MAIN2B:	LD	DE, MSGWR	;Sector written OK
	CALL	PSTRING
MAIN2C:	JP	MAINLOOP

MAIN3:	CP	'L'		;set the logical block address
	JP	NZ,MAIN4		
	LD	DE,GETLBA	
	CALL	PSTRING
	CALL	GHEX32LBA	;Get new CPM style Track & Sector number and put them in RAM at at @SEC & @TRK 
	JP	C,MAIN3B	;Ret C set if abort/error
;	CALL	XLATE		;Convert to actual hardware track,sec,head
MAIN3B:	CALL	ZCRLF
	JP	MAINLOOP

MAIN4:	CP	'U'		;cause the drive to spin up
	JP	NZ,MAIN5		
	CALL	SPINUP
	JP	MAINLOOP

MAIN5:	CP	'D'		;cause the drive to spin down
	JP	NZ,MAIN6			
	CALL	SPINDOWN
	JP	MAINLOOP

MAIN6:	CP	'Q'		;quit
	JP	NZ,MAIN7		
	JP	0

MAIN7:	CP	'H'
	JP	NZ,MAIN8
	CALL	HEXDUMP
	JP	MAINLOOP	;Display what is in buffer

MAIN8:	CP	'S'
	JP	NZ,MAIN9
	CALL	SEQUENTIALREADS
	JP	MAINLOOP

MAIN9:	CP	'F'	;	Format (Fill sectors with E5's for CPM directory empty)
	JP	NZ,MAIN10
	LD	DE,FORMATMSG
	CALL	PSTRING
	LD	DE,MSGSURE	;Are you sure?
	CALL	PSTRING
	CALL	ZCI
	CALL	UPPER
	CP	'Y'
	JP	NZ,MAINLOOP
;
	LD	HL,BUFFER	;fill buffer with 0E5's (512 of them)
	LD	B,0
FILL0:	LD	A,0E5H		;<-- Sector fill character (0E5's for CPM)
	LD	(HL),A
	INC	HL
	LD	(HL),A
	INC	HL
	DJNZ	FILL0
	CALL	ZCRLF

MAIN10:	CP	'I'
	JP	NZ,MAINLOOP
	CALL	IHEXDUMP
	JP	MAINLOOP	;Display what is in buffer
;
NEXTFORMAT:
	LD	HL,BUFFER
	LD	(@DMA),HL
	CALL	WRITESECTOR	;Will return error if there was one
	JP	Z,MAIN9B	;Z means the sector write was OK
	CALL	ZCRLF
	JP	MAINLOOP
MAIN9B:	CALL	ZEOL		;Clear line cursor is on
	CALL	DISPLAYPOSITION	;Display actual current Track,sector,head#
	CALL	ZCSTS		;Any keyboard character will stop display
	CP	01H		;CPM Says something there
	JP	NZ,WRNEXTSEC1
	CALL	ZCI		;Flush character
	LD	DE,CONTINUEMSG
	CALL	PSTRING
	CALL	ZCI
	CP	ESC
	JP	Z,MAINLOOP
	CALL	ZCRLF
WRNEXTSEC1:
	LD	HL,(@SEC)
	INC	HL
	LD	(@SEC),HL	;0 to MAXSEC CPM Sectors
	LD	A,L
	CP	MAXSEC
	JP	NZ,NEXTFORMAT

	LD	HL,0		;Back to CPM sector 0
	LD	(@SEC),HL
	LD	HL,(@TRK)	;Bump to next track
	INC	HL
	LD	(@TRK),HL
	JP	NEXTFORMAT	;Note will go to last sec on disk unless stopped
				;Will actully hang if we get to end of disk!
;
	;Do the IDEntify drive command, and return with the buffer
	;filled with info about the drive
	
DRIVEID:
	CALL	IDEWAITNOTBUSY
	RET	C		;If Busy return NZ
	LD	D,COMMANDID
	LD	E,REGCOMMAND
	CALL	IDEWR8D		;issue the command
	LD	B,4
	CALL	VARDELAY
	CALL	IDEWAITDRQONLY	;Wait for DRQ=1
	JP	C,SHOWERRORS
	
	LD	B,0		;256 words
	LD	HL,IDBUFFER	;Store data here
	CALL	MORERD16	;Get 256 words of data from REGdata port to [HL]
	RET	
;
VARDELAY: 
	LD	A,2
	CALL	DELAYX		;Long delay, drive has to get up to speed
	DJNZ	VARDELAY
	RET	

;
SPINUP:
	LD	D,COMMANDSPINUP
SPUP2:	LD	E,REGCOMMAND
	CALL	IDEWR8D
	CALL	IDEWAITNOTBUSY
	JP	C,SHOWERRORS
	OR	A		;Clear carry
	RET	


	;Tell the drive to spin down
SPINDOWN:
	CALL	IDEWAITNOTBUSY
	JP	C,SHOWERRORS
	LD	D,COMMANDSPINDOWN
	JP	SPUP2

SEQUENTIALREADS: 
	CALL	IDEWAITNOTBUSY	;sequentially read sectors one at a time from current position
	JP	C,SHOWERRORS
;
	CALL	ZCRLF
NEXTSEC:
	CALL	READSECTOR	;If there are errors they will show up in READSECTOR
	JP	Z,SEQOK
	LD	DE,CONTINUEMSG
	CALL	PSTRING
	CALL	ZCI
	CP	ESC		;Abort if ESC
	RET	Z
SEQOK:
	CALL	ZEOL		;Clear line cursor is on
	CALL	DISPLAYPOSITION	;Display current Track,sector,head#
	CALL	ZCSTS		;Any keyboard character will stop display
	CP	01H		;CPM Says something there
	JP	NZ,NEXTSEC1
	CALL	ZCI		;Flush character
	LD	DE,CONTINUEMSG
	CALL	PSTRING
	CALL	ZCI
	CP	ESC
	RET	Z
	CALL	ZCRLF
NEXTSEC1:
	LD	HL,(@SEC)
	INC	HL
	LD	(@SEC),HL	
	LD	A,L		;0 to 62 CPM Sectors
	CP	MAXSEC-1
	JP	NZ,NEXTSEC

	LD	HL,0		;Back to CPM sector 0
	LD	(@SEC),HL
	LD	HL,(@TRK)	;Bump to next track
	INC	HL
	LD	(@TRK),HL
	JP	NEXTSEC		;Note will go to last sec on disk unless stopped
;
;
;---------------- Support Routines -------------------------------------------
;
DISPLAYPOSITION: 		;Display current track,sector & head position
	LD	DE,MSGCPMTRK	;Display in LBA format
	CALL	PSTRING		;---- CPM FORMAT ----
	LD	A,(@TRK+1)	;High TRK byte
	CALL	PHEX
	LD	A,(@TRK)	;Low TRK byte
	CALL	PHEX	
	LD	DE,MSGCPMSEC
	CALL	PSTRING		;SEC = (16 bits)
	LD	A,(@SEC+1)	;High Sec
	CALL	PHEX
	LD	A,(@SEC)	;Low sec
	CALL	PHEX
	;---- LBA FORMAT ----
	LD	DE, MSGLBA
	CALL	PSTRING		;(LBA = 00 (<-- Old "Heads" = 0 for these drives).
	LD	A,(@DRIVE$TRK+1);High "cylinder" byte
	CALL	PHEX
	LD	A,(@DRIVE$TRK)	;Low "cylinder" byte
	CALL	PHEX	
	LD	A,(@DRIVE$SEC)
	CALL	PHEX
	LD	DE, MSGBRACKET	;)$
	CALL	PSTRING		
	RET	

;
PRINTNAME: 			;Send text up to [B]	
	INC	HL		;Text is low byte high byte format
	LD	C,(HL)
	CALL	ZCO	
	DEC	HL
	LD	C,(HL)
	CALL	ZCO
	INC	HL
	INC	HL
	DJNZ	PRINTNAME
	RET	
;
ZCRLF:
	PUSH	AF
	LD	C,CR
	CALL	ZCO
	LD	C,LF
	CALL	ZCO
	POP	AF
	RET	
;
ZEOL:				;CR and clear current line
	LD	C,CR
	CALL	ZCO
	LD	C,CLEAR		;Note hardware dependent, (Use 80 spaces if necessary)
	CALL	ZCO
	RET	

ZCSTS:
	IF	CPM
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
	ELSE	
	IN	A,(0H)		;Get Character in [A]
	AND	02H
	RET	Z
	LD	A,01H
	OR	A
	RET	
	ENDIF	
	
; 
ZCO:				;Write character that is in [C]
	IF	CPM
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
	ELSE	
	PUSH	AF	
ZCO1:	IN	A,(0H)		;Show Character
	AND	04H
	JP	Z,ZCO1
	LD	A,C
	OUT	(1H),A
	POP	AF
	RET	
	ENDIF	

ZCI:				;Return keyboard character in [A]
	IF	CPM
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	C,RDCON
	CALL	BDOS
	POP	HL
	POP	DE
	POP	BC
	RET	
	ELSE	
ZCI1:	IN	A,(0H)		;Get Character in [A]
	AND	02H
	JP	Z,ZCI1
	IN	A,(01H)
	RET	
	ENDIF	
;
;
;				;Print a string in [DE] up to '$'
PSTRING:
	IF	CPM
	LD	C,PRINT
	JP	BDOS		;PRINT MESSAGE, 
	ELSE	
	PUSH	BC
	PUSH	DE
	PUSH	HL
	EX	DE,HL
PSTRX:	LD	A,(HL)
	CP	'$'
	JP	Z,DONEP
	LD	C,A
	CALL	ZCO
	INC	HL
	JP	PSTRX
DONEP:	POP	HL
	POP	DE
	POP	BC
	RET	
	ENDIF	
;
;
SHOWST:	
	RET
	PUSH	AF
	EXX
	LD	HL,STABUF
	CP	(HL)
	EXX
	JR	Z,SHOWST1
	LD	(STABUF),A
	LD	DE,MSTATUS
	CALL	PSTRING
	CALL	ZBITS
	CALL	ZCRLF
SHOWST1:	
	POP	AF
	RET	

STABUF:	DS	1	
;
;
SHOWERRORS:
	IF	NOT DEBUG
	OR	A		;Set NZ flag
	SCF			;Set Carry Flag
	RET	
	ELSE	
	CALL	ZCRLF
	LD	E,REGSTATUS	;Get status in status register
	CALL	IDERD8D
	LD	A,D
	BIT	0,A		
	JP	NZ,MOREERROR	;Go to  REGerr register for more info
;				;All OK if 01000000
	PUSH	AF		;save for return below
	BIT	7,A		
	JP	Z,NOT7
	LD	DE,DRIVEBUSY	;Drive Busy (bit 7) stuck high.   Status = 
	CALL	PSTRING
	JP	DONEERR
NOT7:	BIT	6,A		
	JP	NZ,NOT6
	LD	DE,DRIVENOTREADY;Drive Not Ready (bit 6) stuck low.  Status = 
	CALL	PSTRING
	JP	DONEERR
NOT6:	BIT	5,A		
	JP	NZ,NOT5
	LD	DE,DRIVEWRFAULT;Drive write fault.    Status =
	CALL	PSTRING
	JP	DONEERR
NOT5:	LD	DE,UNKNOWNERROR
	CALL	PSTRING
	JP	DONEERR
;
MOREERROR: 			;Get here if bit 0 of the status register indicated a problem
	LD	E,REGERR	;Get error code in REGerr
	CALL	IDERD8D
	LD	A,D
	PUSH	AF

	BIT	4,A		;Sector Not Found
	JP	Z,NOTE4
	LD	DE,SECNOTFOUND
	CALL	PSTRING
	JP	DONEERR
;
NOTE4:	BIT	7,A		;Bad Block
	JP	Z,NOTE7
	LD	DE,BADBLOCK
	CALL	PSTRING
	JP	DONEERR
NOTE7:	BIT	6,A		;Uncorrectable error
	JP	Z,NOTE6
	LD	DE,UNRECOVERERR
	CALL	PSTRING
	JP	DONEERR
NOTE6:	BIT	2,A		;Invalid command
	JP	Z,NOTE2
	LD	DE,INVALIDCMD
	CALL	PSTRING
	JP	DONEERR
NOTE2:	BIT	1,A		;Track 0 not found
	JP	Z,NOTE1
	LD	DE,TRK0ERR
	CALL	PSTRING
	JP	DONEERR
NOTE1:	LD	DE,UNKNOWNERROR1
	CALL	PSTRING
	JP	DONEERR
;
DONEERR:POP	AF
	PUSH	AF
	CALL	ZBITS
	CALL	ZCRLF
	POP	AF
	OR	A		;Set Z flag
	SCF			;Set Carry flag
	RET	
	ENDIF	

;
;------------------------------------------------------------------
; Print a 16 bit number, located @ [HL]
;
PRINTPARM:
	PUSH	HL
	POP	DE
	LD	B,(HL)
	INC	HL
	LD	A,(HL)
	LD	C,A
	CALL	PHEX
	LD	C,B
	CALL	PHEX
	LD	C,' '
	CALL	ZCO
	LD	C,'('
	CALL	ZCO
	PUSH	DE
	POP	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	CALL	BN2A16
	CALL	PSTRING
	LD	C,')'
	CALL	ZCO
	RET	
;
; Print an 8 bit number, located in [A]

PHEX:	PUSH	AF
	PUSH	BC
	PUSH	AF
	RRCA	
	RRCA	
	RRCA	
	RRCA	
	CALL	ZCONV
	POP	AF
	CALL	ZCONV
	POP	BC
	POP	AF
	RET	
;
ZCONV:	AND	0FH		;HEX to ASCII and print it
	ADD	A,90H
	DAA	
	ADC	A,40H
	DAA	
	LD	C,A
	CALL	ZCO
	RET	
;;
;DISPLAY BIT PATTERN IN [A]
;
ZBITS:	PUSH	AF
	PUSH	BC
	PUSH	DE
	LD	E,A		
	LD	B,8
BQ2:	DEFB	0CBH,23H	;SLA A	
	LD	A,18H
	ADC	A,A
	LD	C,A
	CALL	ZCO
	DJNZ	BQ2
	POP	DE
	POP	BC
	POP	AF
	RET	


	;Get numbers for LBA (in the form of CPM style Track# & Sector#)
GHEX32LBA:
	LD	DE,ENTERSECL	;Enter sector number, low
	CALL	PSTRING
	CALL	GETHEX		;get 2 HEX digits
	RET	C
	LD	(@SEC),A	;Note: no check data is < MAXSEC
	CALL	ZCRLF

	LD	DE,ENTERTRKH	;Enter high byte track number
	CALL	PSTRING
	CALL	GETHEX		;get 2 HEX digits
	RET	C
	LD	(@TRK+1),A
	CALL	ZCRLF

	LD	DE,ENTERTRKL	;Enter low byte track number
	CALL	PSTRING
	CALL	GETHEX		;get 2 more HEX digits
	RET	C
	LD	(@TRK),A
	CALL	ZCRLF
	XOR	A
	OR	A		;To return NC
	RET	
;
;
GETHEX:
	CALL	GETCMD		;Get a character from keyboard & ECHO
	CP	ESC
	JP	Z,HEXABORT
	CP	'/'		;check 0-9, A-F
	JP	C,HEXABORT
	CP	'F'+1
	JP	NC,HEXABORT
	CALL	ASBIN		;Convert to binary
	RLCA			;Shift to high nibble
	RLCA	
	RLCA	
	RLCA	
	LD	B,A		;Store it
	CALL	GETCMD		;Get 2nd character from keyboard & ECHO
	CP	ESC
	JP	Z,HEXABORT
	CP	'/'		;check 0-9, A-F
	JP	C,HEXABORT
	CP	'F'+1
	JP	NC,HEXABORT
	CALL	ASBIN		;Convert to binary
	OR	B		;add in the first digit
	OR	A		;To return NC
	RET	
HEXABORT:
	SCF			;Set Carry flag 
	RET	
;
;
GETCMD:	CALL	ZCI		;GET A CHARACTER, convert to UC, ECHO it
	CALL	UPPER
	CP	ESC
	RET	Z		;Don't echo an ESC
	IF	NOT CPM
	PUSH	AF		;Save it
	PUSH	BC
	LD	C,A
	CALL	ZCO		;Echo it
	POP	BC
	POP	AF		;get it back
	ENDIF	
	RET	
;
;				;Convert LC to UC
UPPER:	CP	'a'		;must be >= lowercase a
	RET	C		; else go back...
	CP	'z'+1		;must be <= lowercase z
	RET	NC		; else go back...
	SUB	'a'-'A'		;subtract lowercase bias
	RET	
;
	;ASCII TO BINARY CONVERSION ROUTINE
ASBIN:	SUB	30H 
	CP	0AH 
	RET	M
	SUB	07H 
	RET	
;
;
;
HEXDUMP:			;print a hexdump of the data in the 512 byte buffer (@DMA)
	LD	HL,BUFFER
	LD	DE,BUFFER+511
	JP	MEMDUMP
	
IHEXDUMP:			;print a hexdump of the data in the 512 byte buffer (@DMA)
	LD	HL,IDBUFFER
	LD	DE,IDBUFFER+511
	JP	MEMDUMP
	
;;
;; Routines for binary to decimal conversion
;;
;; (C) Piergiorgio Betti <pbetti@lpconsul.net> - 2006
;;
;; The active part is taken from:
;; David Barrow - Assembler routines for the Z80
;; CENTURY COMMUNICATIONS LTD - ISBN 0 7126 0506 1
;;


;;
;; BIN2A8 - Convert an 8 bit value to ASCII
;;
;; INPUT	C = Value to be converted
;; OUTPUT	DE = Converted string address
;
BIN2A8: PUSH	HL
	PUSH	AF
	LD	B,0
	LD	(IVAL16),BC
	LD	HL,IVAL16
	LD	DE,OVAL16
	LD	A,1			; one byte conversion
	CALL	LNGIBD
	LD	DE,OVAL16
	POP	AF
	POP	HL
	RET
	;
;;
;; BN2A16 - Convert a 16 bit value to ASCII
;;
;; INPUT	BC = Value to be converted
;; OUTPUT	DE = Converted string address
;
BN2A16: PUSH	HL
	PUSH	AF
	LD	(IVAL16),BC
	LD	HL,IVAL16
	LD	DE,OVAL16
	LD	A,2			; two byte conversion
	CALL	LNGIBD
	LD	DE,OVAL16
	POP	AF
	POP	HL
	RET
	;
;; Generic storage

IVAL16:	DEFS	2
OVAL16:	DEFS	6

;;
;;
;; LNGIBD - Convert long integer of given precision to ASCII
;;
;; INPUT	HL addresses the first byte of the binary value
;;		which must be stored with the low order byte in
;;		lowest memory.
;;		DE addresses the first byte of the destination
;;		area which must be larger enough to accept the
;;		decimal result (2.42 * binary lenght + 1).
;;		A = binary byte lenght (1 to 255)

;;
CVBASE	EQU	10		; CONVERSION BASE
VPTR	EQU	HILO		; STORAGE AREA EQU


HILO:	DEFS	2		; STORAGE AREA

LNGIBD:	LD	C,A
	LD	B,0
	DEC	HL
	LD	(VPTR),HL
	LD	A,-1
	LD	(DE),A
	ADD	HL,BC
	;
NXTMSB:	LD	A,(HL)
	OR	A
	JP	NZ,MSBFND
	DEC	HL
	DEC	C
	JP	NZ,NXTMSB
	;
	EX	DE,HL
	LD	(HL),'0'
	INC	HL
	LD	(HL),'$'
	RET
	;
MSBFND:	LD	B,A
	LD	A,$80
	;
NXTMSK:	CP	B
	JP	C,MSKFND
	JP	Z,MSKFND
	RRCA
	JP	NXTMSK
	;
MSKFND:	LD	B,A
	PUSH	BC
	LD	HL,(VPTR)
	LD	B,0
	ADD	HL,BC
	AND	(HL)
	ADD	A,$FF
	LD	L,E
	LD	H,D
	;
NXTOPV:	LD	A,(HL)
	INC	A
	JP	Z,OPVDON
	DEC	A
	ADC	A,A
	;
	CP	CVBASE
	JP	C,NOCOUL
	SUB	CVBASE
NOCOUL:	CCF
	;
	LD	(HL),A
	INC	HL
	JP	NXTOPV
	;
OPVDON:	JP	NC,EXTDON
	LD	(HL),1
	INC	HL
	LD	(HL),-1
	;
EXTDON:	POP	BC
	LD	A,B
	RRCA
	JP	NC,MSKFND
	DEC	C
	JP	NZ,MSKFND
	;
	; REVERSE DIGIT ORDER. ADD ASCII DIGITS HI-NIBBLES
	LD	(HL),'$'
	;
NXTCNV:	DEC	HL
	LD	A,L
	SUB	E
	LD	A,H
	SBC	A,D
	RET	C
	;
	LD	A,(DE)
	OR	$30
	LD	B,A
	LD	A,(HL)
	OR	$30
	LD	(HL),B
	LD	(DE),A
	;
	INC	DE
	JP	NXTCNV

;;
;; MEMDUMP - prompt user and dump memory area
;
MEMDUMP:
MDP6:	
	PUSH	HL
	LD	BC,BUFFER
	SBC	HL,BC
	CALL	HL2ASCB
	POP	HL
	LD	A,L
	CALL	DMPALIB
	PUSH	HL
MDP2:	LD	A,(HL)
	CALL	H2AJ1
	CALL	CHKEOR
	JR	C,MDP1
	CALL	SPACER
	LD	A,L
	AND	$0F
	JR	NZ,MDP2
MDP7:	POP	HL
	LD	A,L
	AND	$0F
	CALL	DMPALIA
MDP5:	LD	A,(HL)
	LD	C,A
	CP	$20
	JR	C,MDP3
	JR	MDP4
MDP3:	LD	C,$2E
MDP4:	CALL	ZCO
	CALL	CHKBRK
	LD	A,L
	AND	$0F
	JR	NZ,MDP5
	JR	MDP6
MDP1:	SUB	E
	CALL	DMPALIB
	JR	MDP7

;;
CBKEND:	POP	DE
	RET
CHKBRK:
	CALL	CHKEOR
	JR	C,CBKEND
	CALL	ZCSTS
	OR	A
	RET	Z
	CALL	COIUPC
	CP	$13
	JR	NZ,CBKEND
; 	JP	COIUPC
;;
;;
;; COIUPC- convert reg A uppercase
COIUPC:
	CALL	ZCI 
	CP	$60
	JP	M,COIRE
	CP	$7B
	JP	P,COIRE
	RES	5,A
COIRE:	RET
;;
;; DMPALIB - beginning align (spacing) for a memdump
DMPALIB:
	AND	$0F
	LD	B,A
	ADD	A,A
	ADD	A,B
;;
;; DMPALIB - ascii align (spacing) for a memdump
DMPALIA:
	LD	B,A 
	INC	B
ALIBN:	CALL	SPACER
	DJNZ	ALIBN
	RET
;;
;; HL2ASC - convert & display HL 2 ascii
HL2ASC:
	CALL	ZCRLF
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
	CALL	ZCO
	RET
; H2AJ3:	CALL	H2AJ1           ; entry point to display HEX and a "-"
HL2ASCB:
	CALL	HL2ASC
SPACER:	LD	C,$20
	CALL	ZCO
	RET
;;
;; NIB2ASC convert lower nibble in reg A to ascii in reg C
;
NIB2ASC:
	AND	$0F
	ADD	A,$90
	DAA
	ADC	A,$40
	DAA
	LD	C,A
	RET
;;
;; inc HL and do a 16 bit compare between HL and DE
CHKEOR:
	INC	HL
	LD	A,H
	OR	L
	SCF
	RET	Z
	LD	A,E
	SUB	L
	LD	A,D
	SBC	A,H
	RET

;-----------------------------------------------
	
;
;
SIGNON:	DEFB	'IDE Disk Drive Test Program (V1.6) (Using CPM3 BIOS Routines)',CR,LF
		DEFB	'CPM Track,Sectors --> LBA mode',LF,CR,'$'
INITERROR:	DEFB	'Initilizing Drive Error.',CR,LF,'$'
IDERROR:	DEFB	'Error obtaining Drive ID.',CR,LF,'$'
INITDROK:	DEFB	'Drive Initilized OK.',CR,LF,LF,'$'
MSGMDL:		DEFB	'Model: $'
MSGSN:		DEFB	'S/N:   $'
MSGREV:		DEFB	'Rev:   $'
MSGCY:		DEFB	'Cylinders: $'
MSGHD:		DEFB	', Heads: $'
MSGSC:		DEFB	', Sectors: $'
MSGCPMTRK:	DEFB	'CPM TRK = $'
MSGCPMSEC:	DEFB	' CPM SEC = $'
MSGLBA:		DEFB	'  (LBA = 00$'
MSGBRACKET:	DEFB	')$'


CMDSTRING:	DEFB	'Enter Command:- ',CR,LF
		DEFB	'(R)ead   (W)rite   (L)BA   (U)p   (D)own   (H)exdump',CR,LF
		DEFB	'(S)equental Sec Read (F)ormat sectors (I)d dump (Q)uit $'
MSGSURE:	DEFB	CR,LF,'Warning: this will change data on the drive, '
		DEFB	'are you sure? (Y/N)...$'
MSGRD:		DEFB	'Sector Read OK',CR,LF,'$'
MSGWR:		DEFB	'Sector Write OK',CR,LF,'$'
GETLBA:		DEFB	'Enter CPM style TRK & SEC values (in hex).',CR,LF,'$'
SECRWERROR:	DEFB	'Drive Error, Status Register = $'
ERRREGDATA:	DEFB	'Drive Error, Error Register = $'
ENTERSECL:	DEFB	'Starting sector number,(xxH) = $'
ENTERTRKL:	DEFB	'Track number (LOW byte, xxH) = $'
ENTERTRKH:	DEFB	'Track number (HIGH byte, xxH) = $'
ENTERHEAD:	DEFB	'Head number (01-0f) = $'
ENTERCOUNT:	DEFB	'Number of sectors to R/W = $'
DRIVEBUSY:	DEFB	'Drive Busy (bit 7) stuck high.   Status = $'
DRIVENOTREADY:	DEFB	'Drive Ready (bit 6) stuck low.  Status = $'
DRIVEWRFAULT:	DEFB	'Drive write fault.    Status = $'
UNKNOWNERROR:	DEFB	'Unknown error in status register.   Status = $'
BADBLOCK:	DEFB	'Bad Sector ID.    Error Register = $'
UNRECOVERERR:	DEFB	'Uncorrectable data error.  Error Register = $'
READIDERROR:	DEFB	'Error setting up to read Drive ID',CR,LF,'$'
SECNOTFOUND:	DEFB	'Sector not found. Error Register = $'
INVALIDCMD:	DEFB	'Invalid Command. Error Register = $'
TRK0ERR:	DEFB	'Track Zero not found. Error Register = $'
UNKNOWNERROR1:	DEFB	'Unknown Error. Error Register = $'
CONTINUEMSG:	DEFB	CR,LF,'To Abort enter ESC. Any other key to continue. $'
FORMATMSG:	DEFB	'Fill sectors with 0H (e.g for CPM directory sectors).$'
MSTATUS:	DEFB	'Status = $'
;
;
;
;================================================================================================
;===========  IDE Drive BIOS Routines written in a format that can be used with CPM3  ===========
;================================================================================================

IDEINIT:;Initilze the 8255 and drive then do a hard reset on the drive, 
	LD	A,READCFG8255	;10010010b
	OUT	(IDEPORTCTRL),A	;Config 8255 chip, READ mode

	LD	A,IDERSTLINE
	OUT	(IDEPORTC),A	;Hard reset the disk drive

	LD	B,0F0H		;<<<<< fine tune later
RESETDELAY:
	DJNZ	RESETDELAY	;Delay (reset pulse width)
	XOR	A
	OUT	(IDEPORTC),A	;No IDE control lines asserted
	
	LD	D,11100000B	;Data for IDE SDH reg (512bytes, LBA mode,single drive,head 0000)
				;For Trk,Sec,head (non LBA) use 10100000
				;Note. Cannot get LBA mode to work with an old Seagate Medalist 6531 drive.
				;have to use the non-LBA mode. (Common for old hard disks).

	LD	E,REGSHD	;00001110,(0EH) for CS0,A2,A1,  
	CALL	IDEWR8D		;Write byte to select the MASTER device
;
	LD	B,0FFH		;<<< May need to adjust delay time
WAITINIT: 
	LD	E,REGSTATUS	;Get status after initilization
	CALL	IDERD8D		;Check Status (info in [D])
	PUSH	DE
	LD	A,D
	CALL	SHOWST
	POP	DE
	BIT	7,D
	JP	Z,DONEINIT	;Return if ready bit is zero
	LD	A,2
	CALL	DELAYX		;Long delay, drive has to get up to speed
	DJNZ	WAITINIT
	CALL	SHOWERRORS	;Ret with NZ flag set if error (probably no drive)
	RET	
DONEINIT:
	XOR	A
	RET	
;	
DELAYX:	LD	(DELAYSTORE),A
	PUSH	BC
	LD	BC,0FFFFH	;<<< May need to adjust delay time to allow cold drive to
DELAY2:	LD	A,(DELAYSTORE)	;    get up to speed.
DELAY1:	DEC	A
	JP	NZ,DELAY1
	DEC	BC
	LD	A,C
	OR	B
	JP	NZ,DELAY2
	POP	BC
	RET	
;	
;	
;
	;Read a sector, specified by the 4 bytes in LBA
	;Z on success, NZ call error routine if problem
READSECTOR:
	CALL	WRLBA		;Tell which sector we want to read from.
				;Note: Translate first in case of an error otherewise we 
				;will get stuck on bad sector 
	CALL	IDEWAITNOTBUSY	;make sure drive is ready
	JP	C,SHOWERRORS	;Returned with NZ set if error

	LD	D,COMMANDREAD
	LD	E,REGCOMMAND
	CALL	IDEWR8D		;Send sec read command to drive.
	CALL	IDEWAITDRQ	;wait until it's got the data
	JP	C,SHOWERRORS
;		
	LD	HL,(@DMA)	;DMA address
	LD	B,0		;Read 512 bytes to [HL] (256X2 bytes)
MORERD16:
	LD	A,REGDATA	;REG register address
	OUT	(IDEPORTC),A	

	OR	IDERDLINE	;08H+40H, Pulse RD line
	OUT	(IDEPORTC),A	

	IN	A,(IDEPORTA)	;Read the lower byte first (Note early versions had high byte then low byte
	LD	(HL),A		;this made sector data incompatible with other controllers).
	INC	HL
	IN	A,(IDEPORTB)	;THEN read the upper byte
	LD	(HL),A
	INC	HL
	
	LD	A,REGDATA	;Deassert RD line
	OUT	(IDEPORTC),A
	DJNZ	MORERD16

	LD	E,REGSTATUS
	CALL	IDERD8D
	LD	A,D
	BIT	0,A
	CALL	NZ,SHOWERRORS	;If error display status
	RET	

	;Write a sector, specified by the 3 bytes in LBA (@ IX+0)",
	;Z on success, NZ to error routine if problem
WRITESECTOR:
	CALL	WRLBA		;Tell which sector we want to read from.
				;Note: Translate first in case of an error otherewise we 
				;will get stuck on bad sector 
	CALL	IDEWAITNOTBUSY	;make sure drive is ready
	JP	C,SHOWERRORS

	LD	D,COMMANDWRITE
	LD	E,REGCOMMAND
	CALL	IDEWR8D		;tell drive to write a sector
	CALL	IDEWAITDRQ	;wait unit it wants the data
	JP	C,SHOWERRORS
;
	LD	HL,(@DMA)
	LD	B,0		;256X2 bytes

	LD	A,WRITECFG8255
	OUT	(IDEPORTCTRL),A
WRSEC1:	LD	A,(HL)
	INC	HL
	OUT	(IDEPORTA),A	;Write the lower byte first (Note early versions had byte then low byte
	LD	A,(HL)		;this made sector data incompatible with other controllers).
	INC	HL
	OUT	(IDEPORTB),A	;THEN High byte on B
	LD	A,REGDATA
	PUSH	AF
	OUT	(IDEPORTC),A	;Send write command
	OR	IDEWRLINE	;Send WR pulse
	OUT	(IDEPORTC),A
	POP	AF
	OUT	(IDEPORTC),A
	DJNZ	WRSEC1
	
	LD	A,READCFG8255	;Set 8255 back to read mode
	OUT	(IDEPORTCTRL),A	

	LD	E,REGSTATUS
	CALL	IDERD8D
	LD	A,D
	BIT	0,A
	CALL	NZ,SHOWERRORS	;If error display status
	RET	
;
	;Write the logical block address to the drive's registers
	;Note we do not need to set the upper nibble of the LBA
	;It will always be 0 for these small drives
;				
WRLBA:	
	LD	A,(@SEC)	;LBA mode Low sectors go directly 
	INC	A		;Sectors are numbered 1 -- MAXSEC (even in LBA mode)
	LD	(@DRIVE$SEC),A	;For Diagnostic Diaplay Only
	LD	D,A
	LD	E,REGSECTOR	;Send info to drive
	CALL	IDEWR8D
				;Note: For drive we will have 0 - MAXSEC sectors only
	LD	HL,(@TRK)		
	LD	A,L
	LD	(@DRIVE$TRK),A
	LD	D,L		;Send Low TRK#
	LD	E,REGCYLINDERLSB
	CALL	IDEWR8D

	LD	A,H
	LD	(@DRIVE$TRK+1),A
	LD	D,H		;Send High TRK#
	LD	E,REGCYLINDERMSB
	CALL	IDEWR8D

	LD	D,1		;For now, one sector at a time
	LD	E,REGSECCNT
	CALL	IDEWR8D
	RET	
;
;
IDEWAITNOTBUSY: 		;ie Drive READY if 01000000
	LD	B,0FFH
	LD	A,0FFH		;Delay, must be above 80H for 4MHz Z80. Leave longer for slower dr
	LD	(DELAYSTORE),A

MOREWAIT:
	LD	E,REGSTATUS	;wait for RDY bit to be set
	CALL	IDERD8D
	LD	A,D
	CALL 	SHOWST
	AND	11000000B
	XOR	01000000B
	JP	Z,DONENOTBUSY	
	DJNZ	MOREWAIT
	LD	A,(DELAYSTORE)	;Check timeout delay
	DEC	A
	LD	(DELAYSTORE),A
	JP	NZ,MOREWAIT
	SCF			;Set carry to indicqate an error
	RET	
DONENOTBUSY:
	OR	A		;Clear carry it indicate no error
	RET	

	;Wait for the drive to be ready to transfer data. (DRQ=1,BUSY=0)
	;Returns the drive's status in Acc
IDEWAITDRQ:
	LD	B,0FFH
	LD	A,0FFH		;Delay, must be above 80H for 4MHz Z80. Leave longer for slower drives
	LD	(DELAYSTORE),A

MOREDRQ:
	LD	E,REGSTATUS	;wait for DRQ bit to be set
	CALL	IDERD8D
	LD	A,D
	CALL 	SHOWST
	AND	10001000B
	CP	00001000B
	JP	Z,DONEDRQ
	DJNZ	MOREDRQ
	LD	A,(DELAYSTORE)	;Check timeout delay
	DEC	A
	LD	(DELAYSTORE),A
	JP	NZ,MOREDRQ
	SCF			;Set carry to indicate error
	RET	
DONEDRQ:
	OR	A		;Clear carry
	RET	
;
	;Wait for the drive to be ready to transfer data. (DRQ=1)
	;Returns the drive's status in Acc
IDEWAITDRQONLY:
	LD	B,0FFH
	LD	A,0FFH		;Delay, must be above 80H for 4MHz Z80. Leave longer for slower drives
	LD	(DELAYSTORE),A

MOREDRQONLY:
	LD	E,REGSTATUS	;wait for DRQ bit to be set
	CALL	IDERD8D
	LD	A,D
	CALL 	SHOWST
	AND	00001000B
	CP	00001000B
	JP	Z,DONEDRQONLY
	DJNZ	MOREDRQ
	LD	A,(DELAYSTORE)	;Check timeout delay
	DEC	A
	LD	(DELAYSTORE),A
	JP	NZ,MOREDRQONLY
	SCF			;Set carry to indicate error
	RET	
DONEDRQONLY:
	OR	A		;Clear carry
	RET	
;
;------------------------------------------------------------------
; Low Level 8 bit R/W to the drive controller.  These are the routines that talk
; directly to the drive controller registers, via the 8255 chip.  
; Note the 16 bit I/O to the drive (which is only for SEC R/W) is done directly
; ; in the routines READSECTOR & WRITESECTOR for speed reasons.
;
IDERD8D:;READ 8 bits from IDE register in [E], return info in [D]
	LD	A,E
	OUT	(IDEPORTC),A	;drive address onto control lines

	OR	IDERDLINE	;RD pulse pin (40H)
	OUT	(IDEPORTC),A	;assert read pin

	IN	A,(IDEPORTA)
	LD	D,A		;return with data in [D]

	XOR	A
	OUT	(IDEPORTC),A	;Zero all port C lines
	RET	
;
;
IDEWR8D:;WRITE Data in [D] to IDE register in [E]
	LD	A,WRITECFG8255	;Set 8255 to write mode
	OUT	(IDEPORTCTRL),A

	LD	A,D		;Get data put it in 8255 A port
	OUT	(IDEPORTA),A

	LD	A,E		;select IDE register
	OUT	(IDEPORTC),A

	OR	IDEWRLINE	;lower WR line
	OUT	(IDEPORTC),A
	NOP	

	XOR	A		;Deselect all lines including WR line
	OUT	(IDEPORTC),A

	LD	A,READCFG8255	;Config 8255 chip, read mode on return
	OUT	(IDEPORTCTRL),A
	RET	
;
;
;
; -------------------------- RAM usage ----------------------------------------
@DMA:		DEFW	BUFFER
@DRIVE$SEC:	DEFB	0H
@DRIVE$TRK:	DEFW	0H
;
@SEC:		DEFW	0H
@TRK:		DEFW	0H
;
DELAYSTORE:	DEFB	0H
;
		DEFS	40H
STACK:		DEFW	0H

	ORG	1000H		;Buffer for Drive ID
IDBUFFER:	DEFS	512

	ORG	2000H		;Buffer for sector data
;
				;a 512 byte buffer 
BUFFER:		DEFB	'<--Start buffer area'	
		DEFS	476
		DEFB	'End of buffer-->'
;
;
;END

