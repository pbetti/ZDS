
;
; Test Program to intreact with IDE
;==============================================================================
;


IDEportA	EQU	0E0H		;lower 8 bits of IDE interface
IDEportB	EQU	0E1H		;upper 8 bits of IDE interface
IDEportC	EQU	0E2H		;control lines for IDE interface
IDEportCtrl	EQU	0E3H		;8255 configuration port

READcfg8255	EQU	10010010b	;Set 8255 IDEportC to output, IDEportA/B input
WRITEcfg8255	EQU	10000000b	;Set all three 8255 ports to output mode

;IDE control lines for use with IDEportC.  

IDEa0line	EQU	01H	;direct from 8255 to IDE interface
IDEa1line	EQU	02H	;direct from 8255 to IDE interface
IDEa2line	EQU	04H	;direct from 8255 to IDE interface
IDEcs0line	EQU	08H	;inverter between 8255 and IDE interface
IDEcs1line	EQU	10H	;inverter between 8255 and IDE interface
IDEwrline	EQU	20H	;inverter between 8255 and IDE interface
IDErdline	EQU	40H	;inverter between 8255 and IDE interface
IDErstline	EQU	80H	;inverter between 8255 and IDE interface
;
;Symbolic constants for the IDE Drive registers, which makes the
;code more readable than always specifying the address bits

REGdata		EQU	IDEcs0line
REGerr		EQU	IDEcs0line + IDEa0line
REGseccnt	EQU	IDEcs0line + IDEa1line
REGsector	EQU	IDEcs0line + IDEa1line + IDEa0line
REGcylinderLSB	EQU	IDEcs0line + IDEa2line
REGcylinderMSB	EQU	IDEcs0line + IDEa2line + IDEa0line
REGshd		EQU	IDEcs0line + IDEa2line + IDEa1line		;(0EH)
REGcommand	EQU	IDEcs0line + IDEa2line + IDEa1line + IDEa0line	;(0FH)
REGstatus	EQU	IDEcs0line + IDEa2line + IDEa1line + IDEa0line
REGcontrol	EQU	IDEcs1line + IDEa2line + IDEa1line
REGastatus	EQU	IDEcs1line + IDEa2line + IDEa1line

;IDE Command Constants.  These should never change.

COMMANDrecal	EQU	10H
COMMANDread	EQU	20H
COMMANDwrite	EQU	30H
COMMANDinit	EQU	91H
COMMANDid	EQU	0ECH
COMMANDspindown	EQU	0E0H
COMMANDspinup	EQU	0E1H
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
				;Equates for display on SD Systems Video Board (Used In CPM Debugging mode only)
SCROLL	EQU	01H		;Set scrool direction UP.
LF	EQU	0AH
CR	EQU	0DH
BS	EQU	08H		;Back space (required for sector display)
BELL	EQU	07H
; SPACE	EQU	20H
TAB	EQU	09H		;TAB ACROSS (8 SPACES FOR SD-BOARD)
ESC	EQU	1BH
CLEAR	EQU	1CH		;SD Systems Video Board, Clear to EOL. (Use 80 spaces if EOL not available
				;on other video cards)
;
SEC$SIZE EQU	512		;Assume sector size as 512. (Not tested for other sizes)
MAXSEC	EQU	3FH		;Sectors per track for CF my Memory drive, Kingston CF 8G. (For CPM format, 0-3CH)
				;This translates to LBA format of 1 to 3D sectors, for a total of 61 sectors/track.
				;This CF card actully has 3F sectors/track. Will use 3D for my CPM3 system because
				;my Seagate drive has 3D sectors/track. Don't want different CPM3.SYS files around
				;so this program as is will also work with a Seagate 6531 IDE drive
MAXTRK	EQU	0FFH		;CPM3 allows up to 8MG so 0-256 "tracks"


RDCON	EQU	1		;For CP/M I/O
WRCON	EQU	2
PRINT	EQU	9
CONST	EQU	11		;CONSOLE STAT
BDOS	EQU	5

FALSE	EQU	0
TRUE	EQU	-1

CPM		EQU	TRUE	; TRUE if output via CPM, FALSE if direct to hardware
DEBUG		EQU	TRUE
CPM$TRANSLATE	EQU	TRUE	;Translate Trk,Sec,Head to CPM TRACK# & SEC# on display

  IF	CPM
ABORT	EQU	0H
  ELSE
ABORT	EQU	0F000H
  ENDIF
;
	ORG	100H
;
BEGIN:
	LD	SP,STACK
	LD	DE,SIGNON	;print a welcome message
	CALL	PSTRING
	JP	TIDEBEGIN
	
	ORG	200H		;Put Menu table on a 100H boundry for easy debugging etc.

	;COMMAND BRANCH TABLE
TBL:	DEFW	ERROR		; "A"  
	DEFW	BACKUP		; "B"   
	DEFW	IDEPUT		; "C"
	DEFW	DISPLAY		; "D"  Sector contents display:- ON/OFF
	DEFW	WRREG		; "E"  
	DEFW	FORMAT		; "F"  Format current disk
	DEFW	RESTORE		; "G"  Restore backup
	DEFW	HRESET		; "H"  
	DEFW	IDDUMP		; "I"  
	DEFW	RDREG		; "J"  
	DEFW	ERROR		; "K"  
	DEFW	SET$LBA		; "L"  Set LBA value (Set Track,sector)  
	DEFW	ERROR		; "M"  
	DEFW	POWER$DOWN	; "N"  Power down hard disk command
	DEFW	ERROR		; "O"  
	DEFW	PORTSTAT	; "P"  
	DEFW	ERROR		; "Q"  
	DEFW	READMODEC	; "R"  Read sector to data buffer
	DEFW	IDESTAT		; "S"  Sequental sec read and display contents
	DEFW	DRESET		; "T"  
	DEFW	POWER$UP	; "U"  Power up hard disk command
	DEFW	N$RD$SEC	; "V"  Read N sectors
	DEFW	WRITEMODEC	; "W"  Write data buffer to current sector
	DEFW	N$WR$SEC	; "X"  Write N sectors
	DEFW	ERROR		; "Y"  
	DEFW	STATDBG		; "Z"  
	
TIDEBEGIN: 
	LD	A,$FF
	LD	(DBGSTAT),A
	
MAINLOOP: ;A 1 line prompt
	LD	DE,MNUSTRING	;List command options (Turn display option to on)
	CALL	PSTRING
	
	LD	DE,PROMPT	;'>'
	CALL	PSTRING
	
	CALL	GETCMD		;Simple character Input (Note, no fancy checking)
	CP	ESC		;Abort if ESC
	JP	Z,ABORT
	CALL	UPPER
	CALL	ZCRLF
	
	SBC	A,'@'		;Adjust to 0,1AH
	
	ADD	A,A		;X2
	LD	HL,TBL		;Get menu selection
	ADD	A,L
	LD	L,A
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A		;Jump to table pointer
	JP	(HL)		;JMP (HL)

	
; 	
IDEPUT:
	CALL	WRITEMODE
	LD	DE,MPORT
	CALL	PSTRING
	CALL	GETHEX		;get 2 HEX digits
	LD	H,A	
	CALL	ZCRLF

	LD	DE,MOBYTE
	CALL	PSTRING
	CALL	GETHEX		;get 2 HEX digits
	LD	C,H
	OUT	(C),A
	CALL	ZCRLF
	JP	MAINLOOP
	
	
READMODEC:		
	CALL	READMODE
	JP	MAINLOOP

WRITEMODEC:		
	CALL	WRITEMODE
	JP	MAINLOOP
	
	
IDESTAT:
	LD	DE,MREGSTA
	CALL	PSTRING
	CALL	SHOWSTAT
	CALL	ZCRLF
	JP	MAINLOOP
	
PORTSTAT:
	LD	DE,MPRTSTA
	CALL	PSTRING

	IN	A,(IDEPORTA)
	CALL	ZBITS
	LD	C,' '
	CALL	ZCO

	IN	A,(IDEPORTB)
	CALL	ZBITS
	LD	C,' '
	CALL	ZCO

	IN	A,(IDEPORTC)
	CALL	ZBITS
	LD	C,' '
	CALL	ZCO

	IN	A,(IDEPORTCTRL)
	CALL	ZBITS
	LD	C,' '
	CALL	ZCO

	CALL	ZCRLF
	JP	MAINLOOP

HRESET:
	CALL	READMODE
	LD	A,IDERSTLINE
	OUT	(IDEPORTC),A	;Hard reset the disk drive

	LD	B,0FFH		;<<<<< fine tune later
HRESTDLY:
	DEC	B
	JP	NZ,HRESTDLY	;Delay (reset pulse width)
	XOR	A
	OUT	(IDEPORTC),A	;No IDE control lines asserted
	JP	MAINLOOP

RDREG:
	LD	DE,MREGRD
	CALL	PSTRING
	CALL	GETHEX		;get 2 HEX digits
	LD	H,A	
	CALL	ZCRLF
	LD	E,H
	CALL	IDERD8D
	LD	A,D
	PUSH	AF
	LD	DE,MREGSTA
	CALL	PSTRING
	POP	AF
	CALL	ZBITS
	CALL	ZCRLF
	JP	MAINLOOP
	
WRREG:
	LD	DE,MREGWR
	CALL	PSTRING
	CALL	GETHEX		;get 2 HEX digits
	EX	AF,AF'
	CALL	ZCRLF

	LD	DE,MOBYTE
	CALL	PSTRING
	CALL	GETHEX		;get 2 HEX digits
	LD	D,A
	EX	AF,AF'
	LD	E,A
	CALL	IDEWR8D		;Write byte to select the MASTER device
	JP	MAINLOOP
	

READMODE:	
	LD	A,READCFG8255	;10010010b
	OUT	(IDEPORTCTRL),A	;Config 8255 chip, READ mode
	RET
	
WRITEMODE:
	LD	A,WRITECFG8255	;Set 8255 to write mode
	OUT	(IDEPORTCTRL),A
	RET

	
;;
;; --------- OLD CODE
;;


	LD	A,$FF
	LD	(DBGSTAT),A
	CALL	SHOWPRE
	
	CALL	IDEINIT		;initialize the board and drive. If there is no drive abort
	JP	Z,INIT$OK	;Setup for main menu commands

	CALL	SHOWPOST
	XOR	A
	LD	(DBGSTAT),A
	
	LD	DE,INIT$ERROR
	CALL	PSTRING
	CALL	SHOWERRORS
	JP	ABORT

INIT$OK:
	CALL	DRIVEID		;Get the drive ID info. If there is no drive, abort
	JP	Z,INIT$OK1
	
	LD	DE,ID$ERROR
	CALL	PSTRING
	CALL	SHOWERRORS
	JP	ABORT

INIT$OK1: ;print the drive's model number
	LD	DE, MSGMDL	
	CALL	PSTRING
	LD	HL,IDBUFFER + 54
	LD	B,10		;character count in words
	CALL	PRINTNAME	;Print [HL], [B] X 2 characters
	CALL	ZCRLF
	; print the drive's serial number
	LD	DE, MSGSN
	CALL	PSTRING
	LD	HL,IDBUFFER + 20
	LD	B, 5		;Character count in words
	CALL	PRINTNAME
	CALL	ZCRLF
	;Print the drive's firmware revision string
	LD	DE, MSGREV
	CALL	PSTRING
	LD	HL,IDBUFFER + 46
	LD	B, 2
	CALL	PRINTNAME	;Character count in words
	CALL	ZCRLF
	;print the drive's cylinder, head, and sector specs
	LD	DE, MSGCY
	CALL	PSTRING
	LD	HL,IDBUFFER + 2
	CALL	PRINTPARM
	LD	DE,MSGHD
	CALL	PSTRING
	LD	HL,IDBUFFER + 6
	CALL	PRINTPARM
	LD	DE, MSGSC
	CALL	PSTRING
	LD	HL,IDBUFFER + 12
	CALL	PRINTPARM
	CALL	ZCRLF
	;Default position will be first block 
	LD	HL,0
	LD	(@SEC),HL	;Default to Track 0, Sec 0
	LD	(@TRK),HL
	LD	HL,BUFFER	;Set DMA address to buffer
	LD	(@DMA),HL


; MAINLOOP: ;A 1 line prompt
	LD	A,(@DISPLAYFLAG);Do we have detail sector data display flag on or off
	OR	A		;NZ = on (Initially 0FFH so detailed sector display on)
	JP	NZ,DISPLAY1
; 	LD	DE,CMD$STRING1	;List command options (Turn display option to on)
	JP	P,DISPLAY2
DISPLAY1:
; 	LD	DE,CMD$STRING2	;List command options (Turn display option to off)
DISPLAY2:
	CALL	PSTRING
	
	CALL	WRLBA		;Update LBA on drive
	CALL	DISPLAYPOSITION	;Display current Track,sector,head#
	
	LD	DE,PROMPT	;'>'
	CALL	PSTRING
	
	CALL	GETCMD		;Simple character Input (Note, no fancy checking)
	CP	ESC		;Abort if ESC
	JP	Z,ABORT
	CALL	UPPER
	CALL	ZCRLF
	
; 	ORG	1000H
	
	SBC	A,'@'		;Adjust to 0,1AH
	
	ADD	A,A		;X2
	LD	HL,TBL		;Get menu selection
	ADD	A,L
	LD	L,A
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A		;Jump to table pointer
	JP	(HL)		;JMP (HL)
	
	

READ$SEC: ;Read Sector @ LBA to the RAM buffer
	LD	HL,BUFFER	;Point to buffer
	LD	(@DMA),HL

	CALL	READSECTOR

	JP	Z,MAIN1B	;Z means the sector read was OK
	CALL	ZCRLF
	JP	MAINLOOP
MAIN1B:	LD	DE, MSGRD	;Sector read OK
	CALL	PSTRING

	LD	A,(@DISPLAYFLAG);Do we have detail sector data display flag on or off
	OR	A		;NZ = on 
	JP	Z,MAINLOOP
	LD	A,1
	LD	(DMPPAUSE),A
	LD	HL,BUFFER	;Point to buffer. Show sector data flag is on
	LD	(@DMA),HL
	CALL	HEXDUMP		;Show sector data
	JP	MAINLOOP

WRITE$SEC: ;Write data in RAM buffer to sector @ LBA
	LD	DE,MSGSURE	;Are you sure?
	CALL	PSTRING
	CALL	ZCI
	CALL	UPPER
	CP	'Y'
	JP	NZ,MAIN2C
	CALL	ZCRLF

	LD	HL,BUFFER	;Point to buffer
	LD	(@DMA),HL

	CALL	WRITESECTOR

	JP	Z,MAIN2B	;Z means the sector write was OK
	CALL	ZCRLF
	JP	MAINLOOP
MAIN2B:	LD	DE, MSGWR	;Sector written OK
	CALL	PSTRING
MAIN2C:	JP	MAINLOOP


SET$LBA:;Set the logical block address
	LD	DE,GET$LBA	
	CALL	PSTRING
	CALL	GHEX32LBA	;Get new CPM style Track & Sector number and put them in RAM at
	JP	C,MAIN3B	;Ret C set if abort/error
	CALL	WRLBA		;Update LBA on drive
MAIN3B:	CALL	ZCRLF
	JP	MAINLOOP

POWER$UP: ;Set the drive to spin up (for hard disk connections)
	CALL	SPINUP
	JP	MAINLOOP

POWER$DOWN: ;Set the drive to spin down (for hard disk connections)
	CALL	SPINDOWN
	JP	MAINLOOP

DISPLAY:;Do we have detail sector data display flag on or off
	LD	A,(@DISPLAYFLAG)	
	CPL			;flip it
	LD	(@DISPLAYFLAG),A
	JP	MAINLOOP	;Update display and back to next menu command

STATDBG:
	LD	A,(DBGSTAT)	
	CPL			;flip it
	LD	(DBGSTAT),A
	JP	MAINLOOP	;Update display and back to next menu command
	
	
SEQ$RD:	;Do sequential reads
	CALL	SEQUENTIALREADS
	JP	MAINLOOP

N$RD$SEC: ;Read N sectors >>>> NOTE no check is made to not overwrite 
	LD	DE,READN$MSG	;CPM etc. in high RAM
	CALL	PSTRING
	CALL	GETHEX
	JP	C,MAINLOOP	;Abort if ESC (C flag set)
	LD	(SECCOUNT),A	;store sector count
	
	LD	HL,BUFFER	;Point to buffer
	LD	(@DMA),HL
NEXTRSEC: 
	LD	DE,READINGN$MSG
	CALL	PSTRING
	CALL	WRLBA		;Update LBA on drive
	CALL	DISPLAYPOSITION	;Display current Track,sector,head#
	
	LD	HL,(@DMA)
	CALL	READSECTOR
	LD	(@DMA),HL

	LD	A,(SECCOUNT)
	DEC	A
	LD	(SECCOUNT),A
	JP	Z,MAINLOOP
	
	LD	HL,(@SEC)
	INC	HL
	LD	(@SEC),HL	
	LD	A,L		;0 to 62 CPM Sectors
	CP	MAXSEC-1
	JP	NZ,NEXTRSEC

	LD	HL,0		;Back to CPM sector 0
	LD	(@SEC),HL
	LD	HL,(@TRK)	;Bump to next track
	INC	HL
	LD	(@TRK),HL
	LD	A,L		;0-FFH tracks (only)
	JP	NZ,NEXTRSEC
	
	LD	DE,ATEND	;Tell us we are at end of disk
	CALL	PSTRING
	JP	MAINLOOP

N$WR$SEC: ;Write N sectors 
	LD	DE,MSGSURE	;Are you sure?
	CALL	PSTRING
	CALL	ZCI
	CALL	UPPER
	CP	'Y'
	JP	NZ,MAIN2C

	LD	DE,WRITEN$MSG
	CALL	PSTRING
	CALL	GETHEX
	JP	C,MAINLOOP	;Abort if ESC (C flag set)
	LD	(SECCOUNT),A	;store sector count
	
	LD	HL,BUFFER	;Point to buffer
	LD	(@DMA),HL
NEXTWSEC: 
	LD	DE,WRITINGN$MSG
	CALL	PSTRING
	CALL	WRLBA		;Update LBA on drive
	CALL	DISPLAYPOSITION	;Display current Track,sector,head#
	
	LD	HL,(@DMA)
	CALL	WRITESECTOR
	LD	(@DMA),HL

	LD	A,(SECCOUNT)
	DEC	A
	LD	(SECCOUNT),A
	JP	Z,MAINLOOP
	
	LD	HL,(@SEC)
	INC	HL
	LD	(@SEC),HL	
	LD	A,L		;0 to 62 CPM Sectors
	CP	MAXSEC-1
	JP	NZ,NEXTWSEC

	LD	HL,0		;Back to CPM sector 0
	LD	(@SEC),HL
	LD	HL,(@TRK)	;Bump to next track
	INC	HL
	LD	(@TRK),HL
	LD	A,L		;0-FFH tracks (only)
	JP	NZ,NEXTWSEC
	
	LD	DE,ATEND	;Tell us we are at end of disk
	CALL	PSTRING
	JP	MAINLOOP


FORMAT:	;Format (Fill sectors with E5's for CPM directory empty)
	LD	DE,FORMAT$MSG
	CALL	PSTRING
	LD	DE,MSGSURE	;Are you sure?
	CALL	PSTRING
	CALL	ZCI
	CALL	UPPER
	CP	'Y'
	JP	NZ,MAINLOOP
	LD	HL,BUFFER	;Fill buffer with 0E5's (512 of them)
	LD	B,0
FILL0:	LD	A,0E5H		;<-- Sector fill character (0E5's for CPM)
	LD	(HL),A
	INC	HL
	LD	(HL),A
	INC	HL
	DJNZ	FILL0
	CALL	ZCRLF
;
NEXT$FORMAT:
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
	LD	DE,CONTINUE$MSG
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
	JP	NZ,NEXT$FORMAT

	LD	HL,0		;Back to CPM sector 0
	LD	(@SEC),HL
	LD	HL,(@TRK)	;Bump to next track
	INC	HL
	LD	(@TRK),HL
	LD	A,L		;0-FFH tracks (only)
	CP	MAXTRK
	JP	NZ,NEXT$FORMAT	

	LD	DE,FORMATDONE	;Tell us we are all done.
	CALL	PSTRING
	JP	MAINLOOP
	
	
BACKUP:	;Backup the CPM partition to another area on the SAME CF-card/disk
	LD	DE,COPYMSG
	CALL	PSTRING
	CALL	ZCI
	CALL	UPPER
	CP	'Y'
	JP	NZ,MAINLOOP
	
	LD	HL,0		;Start with CPM sector 0
	LD	(@SEC),HL
	LD	(@SEC1),HL
	LD	(@SEC2),HL	;and on second partition
	LD	(@TRK),HL	;and track 0
	LD	(@TRK1),HL
	LD	HL,MAXTRK+0200H+1;<<<<< VIP This assumes CPM3 is on tracks 0-MAXTRK. (0-FF
	LD	(@TRK2),HL	;It skips an area to be safe. However if you have other stuff on 
	;CF card at that location (eg DOS partition) change this value
	CALL	ZCRLF
	CALL	ZCRLF
	
NEXTCOPY1: 
	CALL	ZEOL		;Clear line cursor is on
	LD	DE,RBACKUP$MSG	;for each track update display
	CALL	PSTRING
	LD	A,(@TRK1+1)	;High TRK byte
	CALL	PHEX
	LD	A,(@TRK1)	;Low TRK byte
	CALL	PHEX
	LD	DE,WBACKUP$MSG
	CALL	PSTRING
	LD	A,(@TRK2+1)	;High TRK byte
	CALL	PHEX
	LD	A,(@TRK2)	;Low TRK byte
	CALL	PHEX
	LD	DE,H$MSG
	CALL	PSTRING

NEXTCOPY: 
	LD	A,(@SEC1)
	LD	(@SEC),A
	LD	HL,(@TRK1)
	LD	(@TRK),HL
	CALL	WRLBA		;Update LBA on "1st" drive

	LD	HL,BUFFER	;Point to buffer
	LD	(@DMA),HL
	CALL	READSECTOR	;Get sector data to buffer
	
	LD	A,(@SEC2)
	LD	(@SEC),A
	LD	HL,(@TRK2)
	LD	(@TRK),HL
	CALL	WRLBA		;Update LBA on "2nd" drive
	
	LD	HL,BUFFER	;Point to buffer
	LD	(@DMA),HL
	CALL	WRITESECTOR	;Write buffer data to sector
	
	CALL	ZCSTS		;Any keyboard character will stop display
	CP	01H		;CPM Says something there
	JP	NZ,BKNEXTSEC1
	CALL	ZCI		;Flush character
	LD	DE,CONTINUE$MSG
	CALL	PSTRING
	CALL	ZCI
	CP	ESC
	JP	Z,MAINLOOP

BKNEXTSEC1:
	LD	HL,(@SEC)
	INC	HL
	LD	(@SEC1),HL
	LD	(@SEC2),HL	
	LD	A,L		;0 to 62 CPM Sectors
	CP	MAXSEC-1
	JP	NZ,NEXTCOPY

	LD	HL,0		;Back to CPM sector 0
	LD	(@SEC1),HL
	LD	(@SEC2),HL
	
	LD	HL,(@TRK1)	;Bump to next track
	INC	HL
	LD	(@TRK1),HL
	
	LD	HL,(@TRK2)	;Bump to next track
	INC	HL
	LD	(@TRK2),HL
	
	LD	HL,(@TRK1)	;Check if we are done
	LD	A,L		;0-FFH tracks (only)
	CP	MAXTRK
	JP	NZ,NEXTCOPY1
	
	LD	DE,BACKUPDONE	;Tell us we are all done.
	CALL	PSTRING
	JP	MAINLOOP
	


RESTORE:;Restore disk from backup partition
	LD	DE,RESTOREMSG
	CALL	PSTRING
	CALL	ZCI
	CALL	UPPER
	CP	'Y'
	JP	NZ,MAINLOOP
	
	LD	HL,0		;Start with CPM sector 0
	LD	(@SEC),HL
	LD	(@SEC1),HL
	LD	(@SEC2),HL	;and on second partition
	LD	(@TRK),HL	;and track 0
	LD	(@TRK1),HL
	LD	HL,MAXTRK+0200H+1;<<<<< VIP This assumes CPM3 is on tracks 0-MAXTRK. (0-FF
	LD	(@TRK2),HL	;It skips an area to be safe. However if you have other stuff on 
	;CF card at that location (eg DOS partition) change this value
	CALL	ZCRLF
	CALL	ZCRLF
	
NEXTRESTORE1: 
	CALL	ZEOL		;Clear line cursor is on
	LD	DE,RBACKUP$MSG	;for each track update display
	CALL	PSTRING
	LD	A,(@TRK2+1)	;High TRK byte
	CALL	PHEX
	LD	A,(@TRK2)	;Low TRK byte
	CALL	PHEX
	LD	DE,WBACKUP$MSG
	CALL	PSTRING
	LD	A,(@TRK1+1)	;High TRK byte
	CALL	PHEX
	LD	A,(@TRK1)	;Low TRK byte
	CALL	PHEX
	LD	DE,H$MSG
	CALL	PSTRING

NEXTRESTORE: 
	LD	A,(@SEC2)	;Point to backup partition
	LD	(@SEC),A
	LD	HL,(@TRK2)
	LD	(@TRK),HL
	CALL	WRLBA		;Update LBA on "1st" drive

	LD	HL,BUFFER	;Point to buffer
	LD	(@DMA),HL
	CALL	READSECTOR	;Get sector data to buffer
	
	LD	A,(@SEC1)
	LD	(@SEC),A
	LD	HL,(@TRK1)
	LD	(@TRK),HL
	CALL	WRLBA		;Update LBA on "2nd" drive
	
	LD	HL,BUFFER	;Point to buffer
	LD	(@DMA),HL
	CALL	WRITESECTOR	;Write buffer data to sector
	
	CALL	ZCSTS		;Any keyboard character will stop display
	CP	01H		;CPM Says something there
	JP	NZ,RESNEXTSEC1
	CALL	ZCI		;Flush character
	LD	DE,CONTINUE$MSG
	CALL	PSTRING
	CALL	ZCI
	CP	ESC
	JP	Z,MAINLOOP

RESNEXTSEC1:
	LD	HL,(@SEC)
	INC	HL
	LD	(@SEC1),HL
	LD	(@SEC2),HL	
	LD	A,L		;0 to 62 CPM Sectors
	CP	MAXSEC-1
	JP	NZ,NEXTRESTORE

	LD	HL,0		;Back to CPM sector 0
	LD	(@SEC1),HL
	LD	(@SEC2),HL
	
	LD	HL,(@TRK1)	;Bump to next track
	INC	HL
	LD	(@TRK1),HL
	
	LD	HL,(@TRK2)	;Bump to next track
	INC	HL
	LD	(@TRK2),HL
	
	LD	HL,(@TRK2)	;Check if we are done
	LD	A,L		;0-FFH tracks (only)
	CP	MAXTRK
	JP	NZ,NEXTRESTORE1
	
	LD	DE,RESTOREDONE	;Tell us we are all done.
	CALL	PSTRING
	JP	MAINLOOP
	

ERROR:	LD	DE, MSGERR;CMD error msg
	CALL	PSTRING
	JP	MAINLOOP
	
IDDUMP:	
	LD	A,1
	LD	(DMPPAUSE),A

	CALL	IHEXDUMP
	JP	MAINLOOP	;Display what is in buffer

DRESET: 
	CALL	IDEINIT		;initialize the board and drive. If there is no drive abort
	JP	Z,INIT$OK	;Setup for main menu commands
	CALL	SHOWPOST
	
	LD	DE,INIT$ERROR
	CALL	PSTRING
	CALL	SHOWERRORS
	JP	MAINLOOP
	

;---------------- Support Routines -------------------------------------------
	
DRIVEID:CALL	IDEWAITNOTBUSY	;Do the IDEntify drive command, and return with the
	;filled with info about the drive
	RET	C		;If Busy return NZ
	CALL	SHOWPRE
	LD	D,COMMANDID
	LD	E,REGCOMMAND
	CALL	IDEWR8D		;issue the command
; 	CALL	SHOWPOST

	LD	B,0FFH		;<<<<< fine tune later
DIDDELAY:
	DEC	B
	JP	NZ,DIDDELAY	;Delay (reset pulse width)

	CALL	IDEWAITDRQ	;Wait for Busy=0, DRQ=1
	JP	C,SHOWERRORS

	LD	B,0		;256 words
	LD	HL,IDBUFFER	;Store data here
	CALL	MORERD16	;Get 256 words of data from REGdata port to [HL]
	RET	

SPINUP:
	LD	D,COMMANDSPINUP
SPUP2:	LD	E,REGCOMMAND
	CALL	IDEWR8D
	CALL	IDEWAITNOTBUSY
	JP	C,SHOWERRORS
	OR	A		;Clear carry
	RET	


	
SPINDOWN: ;Tell the drive to spin down
	CALL	IDEWAITNOTBUSY
	JP	C,SHOWERRORS
	LD	D,COMMANDSPINDOWN
	JP	SPUP2

SEQUENTIALREADS: 
	CALL	IDEWAITNOTBUSY	;sequentially read sectors one at a time from current posi
	JP	C,SHOWERRORS
	CALL	ZCRLF
NEXTSEC:
	LD	HL,BUFFER	;Point to buffer
	LD	(@DMA),HL

	CALL	READSECTOR	;If there are errors they will show up in READSECTOR
	JP	Z,SEQOK
	LD	DE,CONTINUE$MSG
	CALL	PSTRING
	CALL	ZCI
	CP	ESC		;Abort if ESC
	RET	Z
	
SEQOK:	CALL	ZEOL		;Clear line cursor is on
	CALL	DISPLAYPOSITION	;Display current Track,sector,head#

	LD	HL,BUFFER	;Point to buffer
	LD	(@DMA),HL
	XOR	A
	LD	(DMPPAUSE),A

	LD	A,(@DISPLAYFLAG);Do we have detail sector data display flag on or off
	OR	A		;NZ = on 
	CALL	NZ,HEXDUMP
	CALL	ZCRLF
	CALL	ZCRLF
	CALL	ZCRLF

	CALL	ZCSTS		;Any keyboard character will stop display
	CP	01H		;CPM Says something there
	JP	NZ,NEXTSEC1
	CALL	ZCI		;Flush character
	LD	DE,CONTINUE$MSG
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
;
DISPLAYPOSITION: ;Display current track,sector & head position
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
PRINTNAME: ;Send text up to [B]	
	INC	HL		;Text is low byte high byte format
	LD	C,(HL)
	CALL	ZCO	
	DEC	HL
	LD	C,(HL)
	CALL	ZCO
	INC	HL
	INC	HL
	DEC	B
	JP	NZ,PRINTNAME
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
ZEOL:	;CR and clear current line
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
ZCO:	;Write character that is in [C]
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

ZCI:	;Return keyboard character in [A]
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
;	;Print a string in [DE] up to '$'
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
	AND	1H
	JP	NZ,MOREERROR	;Go to  REGerr register for more info
;				;All OK if 01000000
	PUSH	AF		;save for return below
	AND	80H
	JP	Z,NOT7
	LD	DE,DRIVE$BUSY	;Drive Busy (bit 7) stuck high.   Status = 
	CALL	PSTRING
	JP	DONEERR
NOT7:	AND	40H
	JP	NZ,NOT6
	LD	DE,DRIVE$NOT$READY;Drive Not Ready (bit 6) stuck low.  Status = 
	CALL	PSTRING
	JP	DONEERR
NOT6:	AND	20H
	JP	NZ,NOT5
	LD	DE,DRIVE$WR$FAULT;Drive write fault.    Status =
	CALL	PSTRING
	JP	DONEERR
NOT5:	LD	DE,UNKNOWN$ERROR
	CALL	PSTRING
	JP	DONEERR
;
MOREERROR: ;Get here if bit 0 of the status register indicated a problem
	LD	E,REGERR	;Get error code in REGerr
	CALL	IDERD8D
	LD	A,D
	PUSH	AF

	AND	10H
	JP	Z,NOTE4
	LD	DE,SEC$NOT$FOUND
	CALL	PSTRING
	JP	DONEERR
;
NOTE4:	AND	80H
	JP	Z,NOTE7
	LD	DE,BAD$BLOCK
	CALL	PSTRING
	JP	DONEERR
NOTE7:	AND	40H
	JP	Z,NOTE6
	LD	DE,UNRECOVER$ERR
	CALL	PSTRING
	JP	DONEERR
NOTE6:	AND	4H
	JP	Z,NOTE2
	LD	DE,INVALID$CMD
	CALL	PSTRING
	JP	DONEERR
NOTE2:	AND	2H
	JP	Z,NOTE1
	LD	DE,TRK0$ERR
	CALL	PSTRING
	JP	DONEERR
NOTE1:	LD	DE,UNKNOWN$ERROR1
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
SHOWPRE:
	PUSH	DE
	PUSH	AF
	LD	A,(DBGSTAT)
	OR	A
	JR	Z,SHOWPREX
	LD	DE,DBGSTMPRE
	CALL	PSTRING
	CALL	SHOWSTAT
SHOWPREX:
	POP	AF
	POP	DE
	RET	
;
SHOWPOST:
	PUSH	DE
	PUSH	AF
	LD	A,(DBGSTAT)
	OR	A
	JR	Z,SHOWPOSTX
	LD	DE,DBGSTMPST
	CALL	PSTRING
	CALL	SHOWSTAT
	CALL	ZCRLF
SHOWPOSTX:
	POP	AF
	POP	DE
	RET	

;
SHOWSTAT:
	LD	A,(DBGSTAT)
	LD	D,A
	XOR	A
	LD	(DBGSTAT),A
	EXX
	LD	E,REGSTATUS	;Get status in status register
	CALL	IDERD8D
	LD	A,D
	CALL	ZBITS
	EXX
	LD	A,D
	LD	(DBGSTAT),A
	RET	

;
;------------------------------------------------------------------
; Print a 16 bit number in RAM located @ [HL] (Note Special Low Byte First)
;
PRINTPARM:
	PUSH	HL
	POP	DE
	LD	B,(HL)
	INC	HL
	LD	C,(HL)
	LD	A,C
	CALL	PHEX
	LD	A,B
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

;DISPLAY BIT PATTERN IN [A]
;
ZBITS:	PUSH	AF
	PUSH	BC
	PUSH	DE
	LD	E,A		
	LD	B,8
BQ2:	SLA	E		;Z80 Op code for SLA A,E
	LD	A,18H
	ADC	A,A
	LD	C,A
	CALL	ZCO
	DJNZ	BQ2
	POP	DE
	POP	BC
	POP	AF
	RET	

	;get CPM style Track# & Sector# data and convert to LBA format
GHEX32LBA:
	LD	DE,ENTER$SECL	;Enter sector number
	CALL	PSTRING
	CALL	GETHEX		;get 2 HEX digits
	RET	C
	LD	(@SEC),A	;Note: no check data is < MAXSEC, sectors start 0,1,2,3....
	CALL	ZCRLF

	LD	DE,ENTER$TRKH	;Enter high byte track number
	CALL	PSTRING
	CALL	GETHEX		;get 2 HEX digits
	RET	C
	LD	(@TRK+1),A
	CALL	ZCRLF

	LD	DE,ENTER$TRKL	;Enter low byte track number
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

	
	
HEXDUMP:			;print a hexdump of the data in the 512 byte buffer (@DMA)
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL

; 	LD	HL,BUFFER
	PUSH	HL
	LD	DE,511
	ADD	HL,DE
	LD	E,L
	LD	D,H
	POP	HL
	CALL	MEMDUMP
	
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET
	
IHEXDUMP:			;print a hexdump of the data in the 512 byte buffer (@DMA)
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL

	LD	HL,IDBUFFER
	LD	DE,IDBUFFER+511
	CALL	MEMDUMP
	
	
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET
;
;
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
	EXX
	LD	B,255	; row counter, for the sake of simplicity
	EXX
MDP6:	
	PUSH	HL
	LD	C,L
	LD	B,H
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
	LD	A,(DMPPAUSE)
	OR	A
	JR	Z,CHKBRK1
	EXX
	DEC	B
	CALL	Z,WPAUSE
	EXX
	RET
CHKBRK1:
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
WPAUSE:
	LD	DE,WPAUSEMSG
	CALL	PSTRING
	CALL	ZCI
	RET
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
;
;==============================================================================
;
;      IDE Drive BIOS Routines written in a format that can be used directly wi
;
;==============================================================================
;
IDEINIT:;Initilze the 8255 and drive then do a hard reset on the drive, 
	LD	A,READCFG8255	;10010010b
	OUT	(IDEPORTCTRL),A	;Config 8255 chip, READ mode

	LD	A,IDERSTLINE
	OUT	(IDEPORTC),A	;Hard reset the disk drive

	LD	B,0FFH		;<<<<< fine tune later
RESETDELAY:
	DEC	B
	JP	NZ,RESETDELAY	;Delay (reset pulse width)
	XOR	A
	OUT	(IDEPORTC),A	;No IDE control lines asserted
	CALL	SHOWPOST
	
	LD	D,11100000B	;Data for IDE SDH reg (512bytes, LBA mode,single drive,head 00
	;For Trk,Sec,head (non LBA) use 10100000
	;Note. Cannot get LBA mode to work with an old Seagate Medalist 6531 drive.
	;have to use teh non-LBA mode. (Common for old hard disks).

	LD	E,REGSHD	;00001110,(0EH) for CS0,A2,A1,  
	CALL	IDEWR8D		;Write byte to select the MASTER device
;
; 	LD	B,0FFH		;<<<<< fine tune later
; INITDELAY:
; 	DEC	B
; 	JP	NZ,INITDELAY	;Delay (reset pulse width)
	
	LD	B,0FFH		;<<< May need to adjust delay time
WAITINIT: 
	LD	E,REGSTATUS	;Get status after initilization
	CALL	IDERD8D		;Check Status (info in [D])
	LD	A,D
	AND	80H
	JP	Z,DONEINIT	;Return if ready bit is zero
	LD	A,2
	CALL	DELAYX		;Long delay, drive has to get up to speed
	DEC	B
	JP	NZ,WAITINIT
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

	IN	A,(IDEPORTA)	;Read the lower byte first (Note early versions had high byte then
	LD	(HL),A		;this made sector data incompatable with other controllers).
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
	AND	1H
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
	OUT	(IDEPORTA),A	;Write the lower byte first (Note early versions had high byte th
	LD	A,(HL)		;this made sector data incompatable with other controllers).
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
	AND	1H
	CALL	NZ,SHOWERRORS	;If error display status
	RET	
;
;
;				
WRLBA:	;Write the logical block address to the drive's registers
	;Note we do not need to set the upper nibble of the LBA
	;It will always be 0 for these small drives
	LD	A,(@SEC)	;LBA mode Low sectors go directly 
	INC	A		;Sectors are numbered 1 -- MAXSEC (even in LBA mode)
	LD	(@DRIVE$SEC),A	;For Diagnostic Diaplay Only
	LD	D,A
	LD	E,REGSECTOR	;Send info to drive
	CALL	IDEWR8D		;Note: For drive we will have 0 - MAXSEC sectors only
	
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
IDEWAITNOTBUSY: ;ie Drive READY if 01000000
	LD	B,0FFH
	LD	A,0FFH		;Delay, must be above 80H for 4MHz Z80. Leave longer for slower drives
	LD	(DELAYSTORE),A

MOREWAIT:
	LD	E,REGSTATUS	;wait for RDY bit to be set
	CALL	IDERD8D
	LD	A,D
	AND	11000000B
	XOR	01000000B
	JP	Z,DONENOTBUSY
	DEC	B	
	JP	NZ,MOREWAIT
	LD	A,(DELAYSTORE)	;Check timeout delay
	DEC	A
	LD	(DELAYSTORE),A
	JP	NZ,MOREWAIT
	SCF			;Set carry to indicate an error
	RET	
DONENOTBUSY:
	OR	A		;Clear carry it indicate no error
	RET	

	;Wait for the drive to be ready to transfer data.
	;Returns the drive's status in Acc
IDEWAITDRQ:
	LD	B,0FFH
	LD	A,0FFH		;Delay, must be above 80H for 4MHz Z80. Leave longer for slower drives
	LD	(DELAYSTORE),A

MOREDRQ:
	LD	E,REGSTATUS	;wait for DRQ bit to be set
	CALL	IDERD8D
	LD	A,D
	AND	10001000B
	CP	00001000B
	JP	Z,DONEDRQ
	DEC	B
	JP	NZ,MOREDRQ
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
;
;------------------------------------------------------------------
; Low Level 8 bit R/W to the drive controller.  These are the routines that tal
; directly to the drive controller registers, via the 8255 chip.  
; Note the 16 bit I/O to the drive (which is only for SEC R/W) is done directly
; in the routines READSECTOR & WRITESECTOR for speed reasons.
;
IDERD8D:;READ 8 bits from IDE register in [E], return info in [D]
; 	CALL	SHOWPRE
	LD	A,E
	OUT	(IDEPORTC),A	;drive address onto control lines

	OR	IDERDLINE	;RD pulse pin (40H)
	OUT	(IDEPORTC),A	;assert read pin

	IN	A,(IDEPORTA)
	LD	D,A		;return with data in [D]

	XOR	A
	OUT	(IDEPORTC),A	;Zero all port C lines
; 	CALL	SHOWPOST
	RET	
;
;
IDEWR8D:;WRITE Data in [D] to IDE register in [E]
; 	CALL	SHOWPRE
	LD	A,WRITECFG8255	;Set 8255 to write mode
	OUT	(IDEPORTCTRL),A

	XOR	A		;Zero 8255 B port
	OUT	(IDEPORTB),A

	LD	A,D		;Get data put it in 8255 A port
	OUT	(IDEPORTA),A

	LD	A,E		;select IDE register
	OUT	(IDEPORTC),A

	NOP

	OR	IDEWRLINE	;lower WR line
	OUT	(IDEPORTC),A

	NOP

	;XOR	A		;Deselect all lines including WR line
	;OUT	(IDEPORTC),A
	LD	A,E		;select IDE register
	OUT	(IDEPORTC),A
	NOP

	LD	A,READCFG8255	;Config 8255 chip, read mode on return
	OUT	(IDEPORTCTRL),A
; 	CALL	SHOWPOST
	RET	
;
; -------------------------------------------------------------------------------------------------
;
SIGNON:	DB	CR,LF,'IDE Disk Drive Test Program',CR,LF,'$'
INIT$ERROR:	DB	'Initilizing Drive Error.',CR,LF,'$'
ID$ERROR:	DB	'Error obtaining Drive ID.',CR,LF,'$'
INIT$DR$OK:	DB	'Drive Initilized OK.',CR,LF,LF,'$'
msgmdl:		DB	'Model: $'
msgsn:		DB	'S/N:   $'
msgrev:		DB	'Rev:   $'
msgcy:		DB	'Cylinders: $'
msghd:		DB	', Heads: $'
msgsc:		DB	', Sectors: $'
msgCPMTRK:	DB	'CPM TRK = $'
msgCPMSEC:	DB	' CPM SEC = $'
msgLBA:		DB	'  (LBA = 00$'
MSGBracket	DB	')$'


MNUSTRING 	DB	CR,LF,LF,'                 MAIN MENU',CR,LF
		DB	'(R) Read mode      (W) Write Mode     (E) Write Reg.',CR,LF
		DB	'(P) Port Status    (S) Disk Status    (J) Read Reg',CR,LF
		DB	'(B) Bit Set        (C) send Byte      (H) Hard Reset',CR,LF
		DB	'(ESC) Quit',CR,LF,LF,'$'
Prompt:		DB	'Cmd > $'
msgsure:	DB	CR,LF,'Warning: this will change data on the drive, '
		DB	'are you sure? (Y/N)...$'
msgrd:		DB	CR,LF,'Sector Read OK',CR,LF,'$'
msgwr:		DB	CR,LF,'Sector Write OK',CR,LF,'$'
GET$LBA:	DB	'Enter CPM style TRK & SEC values (in hex).',CR,LF,'$'
SEC$RW$ERROR	DB	'Drive Error, Status Register = $'
ERR$REG$DATA	DB	'Drive Error, Error Register = $'
ENTER$SECL	DB	'Starting sector number,(xxH) = $'
ENTER$TRKL	DB	'Track number (LOW byte, xxH) = $'
ENTER$TRKH	DB	'Track number (HIGH byte, xxH) = $'
ENTER$HEAD	DB	'Head number (01-0f) = $'
ENTER$COUNT	DB	'Number of sectors to R/W = $'
DRIVE$BUSY	DB	'Drive Busy (bit 7) stuck high.   Status = $'
DRIVE$NOT$READY	DB	'Drive Ready (bit 6) stuck low.  Status = $'
DRIVE$WR$FAULT	DB	'Drive write fault.    Status = $'
UNKNOWN$ERROR	DB	'Unknown error in status register.   Status = $'
BAD$BLOCK	DB	'Bad Sector ID.    Error Register = $'
UNRECOVER$ERR	DB	'Uncorrectable data error.  Error Register = $'
READ$ID$ERROR	DB	'Error setting up to read Drive ID',CR,LF,'$'
SEC$NOT$FOUND	DB	'Sector not found. Error Register = $'
INVALID$CMD	DB	'Invalid Command. Error Register = $'
TRK0$ERR	DB	'Track Zero not found. Error Register = $'
UNKNOWN$ERROR1	DB	'Unknown Error. Error Register = $'
CONTINUE$MSG	DB	CR,LF,'To Abort enter ESC. Any other key to continue. $'
FORMAT$MSG	DB	'Fill sectors with 0H (e.g for CPM directory sectors).$'
ReadN$MSG	DB	CR,LF,'Read multiple sectors from current disk/CF card to RAM buffer.'
		DB	CR,LF,'How many 512 byte sectores (xx HEX):$'
WriteN$MSG	DB	CR,LF,'Write multiple sectors RAM buffer current disk/CF card.'
		DB	CR,LF,'How many 512 byte sectores (xx HEX):$'
ReadingN$MSG	DB	CR,LF,'Reading Sector at:- $'
WritingN$MSG	DB	CR,LF,'Writing Sector at:- $'
msgErr		DB	CR,LF,'Sorry, that was not a valid menu option!$'
FormatDone	DB	CR,LF,'Disk Format Complete.',CR,LF,'$'
backupDone	DB	CR,LF,'Disk partition copy complete.',CR,LF,'$'
CopyMsg		DB	CR,LF,'Copy disk partition to a second area on disk (CF card).'
		DB	CR,LF,'>>> This assumes that tracks greater than MAXTRK '
		DB	'(for CPM, 0FFH) are unused <<<'
		DB	CR,LF,'>>> on this disk. Be sure you have nothing in this '
		DB	'"Backup partition area". <<<'
		DB	CR,LF,BELL,'Warning: This will change data in the partition area, '
		DB	'are you sure? (Y/N)...$ '
AtEnd		DB	CR,LF,'At end of disk partition!',CR,LF,'$'
RBackup$MSG	DB	'Reading track: $'
WBackup$MSG	DB	'H. Writing track: $'
H$Msg		DB	'H$'
RestoreMsg	DB	CR,LF,'Restore disk with data from backup partition on disk (CF card).'
		DB	CR,LF,BELL,'Warning: This will change data on disk, '
		DB	'are you sure? (Y/N)...$ '
RestoreDone	DB	CR,LF,'Restore of disk data from backup partition complete.',CR,LF,'$'
WPAUSEMSG	DB	CR,LF,'-- More -- $'
DBGSTMPRE	DB	'Pre status: $'
DBGSTMPST	DB	'  Post status: $'
MREGSTA		DB	'Reg. status: $'
MPRTSTA		DB	'Port status: $'
MPORT		DB	'Port number: $'
MOBYTE		DB	'Out Byte: $'
MREGRD		DB	'RD Reg. ID: $'
MREGWR		DB	'WR Reg. ID: $'
; -------------------------- RAM usage ----------------------------------------
RAMAREA		DB	'           RAM STORE AREA -------->'		;useful for debugging
@DMA		DW	buffer
@DRIVE$SEC	DB	0H
@DRIVE$TRK	DW	0H
@DisplayFlag	DB	0FFH		;Display of sector data initially ON
;
@SEC		DW	0H
@TRK		DW	0H
@SEC1		DW	0H		;For disk partition copy
@TRK1		DW	0H
@SEC2		DW	0H
@TRK2		DW	0H
StartLineHex	DW	0H
StartLineASCII	DW	0H
ByteCount	DW	0H
SecCount	DW	0H
;
DMPPAUSE	DB	0H
DBGSTAT		DB	0H
;
DELAYStore	DB	0H
;
		DS	40H
STACK		DW	0H
	ORG	$3000
;
IDbuffer	DS	512
;
buffer		DB	76H					;put a Z80 HALT instruction here in case we 
								;jump to a sector in error
		DB	'<--Start buffer area'			;a 512 byte buffer 
		DS	476
		DB	'End of buffer-->'
;
;END

