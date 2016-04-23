
TITLE 'Write CPMLDR.COM to System Track of IDE CF Memory Card.'
; Author John Monahan	Danville CA.  (10/26/2009)
;
; The CPM3 boot load process is a ONE step process (unlike the Floppy boots). The ROM monitor reads the 
; the total CPMLDR in one gulp (the first 12 (512 byte) sectors from Track 0 of the IDE Hard Disk/CF card).
; This is for a NON-BANKED version of CPM

;	12/25/2009	V1.1	Corrected High/Low byte Sector write routine
;	02/14/2011	V1.2	Removed the multi-sector write approach. Now one sector at a time.
;	02/14/2011	V1.3	Cleaned up I/O to a CPM based Console I/O mode
;	02/15/2011	V1.4	Reset CF cards twice at start for reliability
;	02/16/2011	V1.5	Removed signon notice
;	03/15/2011	V1.6	Single Reset pulse to IDE Board, Corrected first sector for boot
	
TRUE		EQU	-1		; DEFINE LOGICAL VALUES:
FALSE		EQU	NOT TRUE

BELL		EQU	07H
CR		EQU	0DH
ESC		EQU	1BH
LF		EQU	0AH

CPM		EQU	TRUE		; TRUE if CRT output via CPM 
					; FALSE if direct to SD Systems video board hardware
					
					; CP/M calls:-
RDCON		EQU	1		; Input from console
WRCON		EQU	2		; Write to console
PRINT		EQU	9		; CPM BDOS print a character
BDOS		EQU	5


;	PORTS  FOR FOR SD Systems Video Board if CPM I/O is not used (see below)
CIN		EQU	1H		;IN Data SD Systems Video Board
COUT		EQU	1H		;OUT Data SD Systems Video Board
CSTAT		EQU	0H		;Status Port SD Systems Video Board

					
CPM$Loader$Code	EQU	1100H		;<--- Will place the CPMLDR.COM Loader here with ZSID in the HSYSGEN.SUB file
					
					; CPMLDR.COM will ALWAYS be on TRK 0,SEC2,Head 0
SEC$COUNT	EQU	12		; CPMLDR.COM requires (currently) 10, 512 byte sectors
					; Have extra in case of modifications etc
IF CPM	
 DONE	EQU	0H
ELSE
 DONE	EQU	0F000H
ENDIF
;
;Ports for 8255 chip. Change these to specify where the 8255 is addressed,
;and which of the 8255's ports are connected to which IDE signals.
;The first three control which 8255 ports have the control signals,
;upper and lower data bytes.  The last one is for mode setting for the
;8255 to configure its ports, which must correspond to the way that
;the first three lines define which ports are connected.

IDEportA	EQU	030H		;lower 8 bits of IDE interface
IDEportB	EQU	031H		;upper 8 bits of IDE interface
IDEportC	EQU	032H		;control lines for IDE interface
IDEportCtrl	EQU	033H		;8255 configuration port

READcfg8255	EQU	10010010b	;Set 8255 IDEportC out, IDEportA/B input
WRITEcfg8255	EQU	10000000b	;Set all three 8255 ports output

;IDE control lines for use with IDEportC.  Change these 8
;constants to reflect where each signal of the 8255 each of the
;IDE control signals is connected.  All the control signals must
;be on the same port, but these 8 lines let you connect them to
;whichever pins on that port.

IDEa0line	EQU	01H		;direct from 8255 to IDE interface
IDEa1line	EQU	02H		;direct from 8255 to IDE interface
IDEa2line	EQU	04H		;direct from 8255 to IDE interface
IDEcs0line	EQU	08H		;inverter between 8255 and IDE interface
IDEcs1line	EQU	10H		;inverter between 8255 and IDE interface
IDEwrline	EQU	20H		;inverter between 8255 and IDE interface
IDErdline	EQU	40H		;inverter between 8255 and IDE interface
IDErstline	EQU	80H		;inverter between 8255 and IDE interface
;
;Symbolic constants for the IDE Drive registers, which makes the
;code more readable than always specifying the address pins

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
REGastatus	EQU	IDEcs1line + IDEa2line + IDEa1line + IDEa0line

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
	; INCLUDE Z-80 MACRO LIBRARY:
	MACLIB	Z80

;-----------------INITILIZE THE IDE HARD DISK  -----------------------------------------

	ORG	100H

	LXI	SP,STACK
	LXI     D,SIGN$ON		;print a welcome message
	CALL	PSTRING
	CALL	ZCI
	ANI	5FH			;CHANGE TO UPPER CASE ONLY
	CPI	ESC			;ESC = Abort
	JZ	ABORT1
	CPI	'Y'
	JZ	HDLOGIN
ABORT1:	MVI	C,'N'			;Show 'Y'
	CALL	ZCO
	LXI     D,SAY$NO		;Say we are aborting
	CALL	PSTRING
	JMP	DONE

HDLOGIN:
	MVI	C,'Y'			;Show 'Y'
	CALL	ZCO
	LXI     D,SAY$OK		;Say we are writing
	CALL	PSTRING

	CALL	IDEinit			;initialize the board and drive. If there is no drive abort
	JZ	INIT$OK			;Now write multiple sectors
	LXI	D,INIT$FAIL		;Drive initilization failed
	CALL	PSTRING
	JMP	DONE

INIT$OK:				
	LXI	H,0
	SHLD	@TRK
	MVI	A,1
	SHLD	@SEC			;Note the CPMLDR will ALWAYS start on TRK 0, SEC1 (LBA 000001),Head 0
	MVI	A,SEC$COUNT		;Count of sectors to write
	STA	@COUNT$STORE
	LXI	H,CPM$Loader$Code	;Point to CPMLoader
	SHLD	@DMA

NextWSec:
	LHLD	@DMA
	CALL	WRITESECTOR		;<<<< Write one sector
	SHLD	@DMA			;Store DMA address for next sector write
	
	LDA	@ERFLG			;Was there any errors
	ORA	A
	JNZ	SEC$WR$ERROR		;Abort, send error msg
	
	LDA     @COUNT$STORE		;12X512 sectors for CPM
	DCR	A
	STA	@COUNT$STORE
	JZ	WRITESEC$DONE
	
	LHLD	@SEC			;Next sector. Note no need to increment Track!
	INX	H
	SHLD	@SEC	
	
	MVI	C,'.'			;Show progress
	CALL	ZCO
	JMP	NextWSec
	
WRITESEC$DONE:
	LXI	D,CPMLDR$OK
	CALL	PSTRING
	HLT				;Halt CPM may be confused

WRITESECTOR:
	XRA	A
	STA	@ERFLG
	
	CALL	wrlba			;Send to drive the sector we want to write to. 
					;Converting CPM TRK/SEC info to Drive TRK/SEC/Head
					;send before error check so info is updated
	CALL	IDEwaitnotbusy		;make sure drive is ready
	JC	SetErrorFlag

	MVI	D,COMMANDwrite
	MVI	E,REGcommand
	CALL	IDEwr8D			;tell drive to write a sector
	CALL	IDEwaitdrq		;wait unit it wants the data
	JC	SetErrorFlag		;If problem abort

	LHLD    @DMA			;Get DMA address
	MVI	B,0			;256X2 bytes

	MVI	A,WRITEcfg8255
	OUT	IDEportCtrl
	
WRSEC1:	MOV	A,M
	INX	H
	OUT	IDEportA		;LOW byte on A (Was wrong order in earlier versions)
	MOV	A,M
	INX	H
	OUT	IDEportB		;Then HIGH byte on B
	MVI	A,REGdata
	PUSH	PSW
	OUT	IDEportC		;Send write command
	ORI	IDEwrline		;Send WR pulse
	OUT	IDEportC
	POP	PSW
	OUT	IDEportC
	DJNZ	WRSEC1

	MVI	A,READcfg8255		;Set 8255 back to read mode
	OUT	IDEportCtrl
		
CHECK$WRT:
	MVI	E,REGstatus		;Check R/W status when done
	CALL	IDErd8D	
	MOV	A,D
	ANI	01H
	STA	@ERFLG			;Ret Z if All OK
	RZ
	
SetErrorFlag:				;For now just return with error flag set
	XRA	A
	DCR	A
	STA	@ERFLG			;Ret NZ if problem
	RET

SEC$WR$ERROR:
	LXI	D,WRITE$FAIL		;Drive write to disk failed
	CALL	PSTRING
	JMP	DONE
	
	
;      ----- SUPPORT ROUTINES -------------------------------------------

IDEinit:				;Initilze the 8255 and drive then do a hard reset on the drive, 
	MVI	A,READcfg8255		;Config 8255 chip (10010010B), read mode on return
	OUT	IDEportCtrl		;Config 8255 chip, READ mode
				
					;Hard reset the disk drive 
					;For some reason some CF cards need to the RESET line 
					;pulsed very carefully. You may need to play around   
	MVI	A,IDErstline		;with the pulse length. Symptoms are: incorrect data comming
	OUT	IDEportC		;back from a sector read (often due to the wrong sector being read)
					;I have a (negative)pulse of 2.7uSec. (10Mz Z80, two IO wait states).
	MVI	B,20H			;Which seem to work for the 5 different CF cards I have.
ResetDelay:
	DCR	B
	JNZ	ResetDelay		;Delay (reset pulse width)

	XRA	A
	OUT	IDEportC		;No IDE control lines asserted (just bit 7 of port C)
	CALL	DELAY$32
			
	MVI	D,11100000b		;Data for IDE SDH reg (512bytes, LBA mode,single drive,head 0000)
					;For Trk,Sec,head (non LBA) use 10100000
					;Note. Cannot get LBA mode to work with an old Seagate Medalist 6531 drive.
					;have to use teh non-LBA mode. (Common for old hard disks).

	MVI	E,REGshd		;00001110,(0EH) for CS0,A2,A1,  
	CALL	IDEwr8D			;Write byte to select the MASTER device
;
	MVI	B,0FFH			;<<< May need to adjust delay time for hard disks
WaitInit:	
	MVI	E,REGstatus		;Get status after initilization
	CALL	IDErd8D			;Check Status (info in [D])
	MOV	A,D
	ANI	80H
	JZ	DoneInit		;Return if ready bit is zero
	MVI	A,2
	CALL	DELAYX			;Long delay, drive has to get up to speed
	DCR	B
	JNZ	WaitInit
	XRA	A
	DCR	A
	RET				;Ret with NZ flag set if error (probably no drive
DoneInit:
	XRA	A
	RET


wrlba:					;Write the logical block address to the drive's registers
	LDA	@SEC			;Get CPM requested sector
	INR	A			;Disk sectors 1...MAXSEC
	MOV	D,A
	MVI	E,REGsector		;Send info to drive
	CALL	IDEwr8D

	LHLD	@TRK			;We have are in LBA mode so send directly
	MOV	D,L			;Send Low TRK#
	MVI	E,REGcylinderLSB
	CALL	IDEwr8D

	MOV	D,H			;Send High TRK#
	MVI	E,REGcylinderMSB
	CALL	IDEwr8D

	MVI	D,1			;For now, one sector at a time
	MVI	E,REGseccnt
	CALL	IDEwr8D
	RET


IDEwaitnotbusy:				;Drive READY if 01000000
	MVI	B,0FFH
	MVI	C,0FFH			;Delay, must be above 80H for 4MHz Z80. Leave longer for slower drives
MoreWait:
	MVI	E,REGstatus		;wait for RDY bit to be set
	CALL	IDErd8D
	MOV	A,D
	ANI	11000000B
	XRI	01000000B
	JZ	DoneNotbusy	
	DJNZ	MoreWait
	DCR	C
	JNZ	MoreWait
	STC				;Set carry to indicqate an error
	ret
DoneNotBusy:
	ORA	A			;Clear carry it indicate no error
	RET
					;Wait for the drive to be ready to transfer data.
					;Returns the drive's status in Acc

IDEwaitdrq:
	MVI	B,0FFH
	MVI	C,0FFH			;Delay, must be above 80H for 4MHz Z80. Leave longer for slower drives
MoreDRQ:
	MVI	E,REGstatus		;wait for DRQ bit to be set
	CALL	IDErd8D
	MOV	A,D
	ANI	10001000B
	CPI	00001000B
	JZ	DoneDRQ
	DJNZ	MoreDRQ
	DCR	C
	JNZ	MoreDRQ
	STC				;Set carry to indicate error
	RET
DoneDRQ:
	ORA	A			;Clear carry
	RET


DELAYX:	STA	@DELAYStore
	PUSH	B
	LXI	B,0FFFFH	;<<< May need to adjust delay time to allow cold drive to
DELAY2:	LDA	@DELAYStore	;    get up to speed.
DELAY1:	DCR	A
	JNZ	DELAY1
	DCX	B
	MOV	A,C
	ORA	B
	JNZ	DELAY2
	POP	B
	RET


DELAY$32: MVI	A,40			;DELAY ~32 MS (DOES NOT SEEM TO BE CRITICAL)
DELAY3:	MVI	B,0
M0:	DJNZ	M0
	DCR	A
	JNZ	DELAY3 
	RET


;------------------------------------------------------------------
; Low Level 8 bit R/W to the drive controller.  These are the routines that talk
; directly to the drive controller registers, via the 8255 chip.  
; Note the 16 bit I/O to the drive (which is only for SEC Read here) is done directly 
; in the routine MoreRD16 for speed reasons.

IDErd8D:				;READ 8 bits from IDE register in [E], return info in [D]
	MOV	A,E
	OUT	IDEportC		;drive address onto control lines

	ORI	IDErdline		;RD pulse pin (40H)
	OUT	IDEportC		;assert read pin

	IN	IDEportA
	MOV	D,A			;return with data in [D]

	XRA	A
	OUT	IDEportC		;Zero all port C lines
	ret


IDEwr8D:				;WRITE Data in [D] to IDE register in [E]
	MVI	A,WRITEcfg8255		;Set 8255 to write mode
	OUT	IDEportCtrl

	MOV	A,D			;Get data put it in 8255 A port
	OUT	IDEportA

	MOV	A,E			;select IDE register
	OUT	IDEportC

	ORI	IDEwrline		;lower WR line
	OUT	IDEportC
	NOP

	XRA	A			;Deselect all lines including WR line
	OUT	IDEportC

	MVI	A,READcfg8255		;Config 8255 chip, read mode on return
	OUT	IDEportCtrl
	RET
;				
PSTRING:				;Print a string in [DE] up to '$'
 IF CPM
	MVI	C,PRINT
	JMP	BDOS		
 ELSE
	PUSH	B
	PUSH	D
	PUSH	H
	XCHG
PSTRX:	MOV	A,M
	CPI	'$'
	JZ	DONEP
	MOV	C,A
	CALL	ZCO			;Hardware send to consol
	INX	H
	JMP	PSTRX
DONEP:	POP	H
	POP	D
	POP	B
	RET
  ENDIF

PCHAR:
 IF CPM
	MVI	C,WRCON			;Print a single character on CRT
	JMP	BDOS		
 ELSE
	MOV	C,E
	JMP	ZC0
ENDIF

ZCO:					;Write character that is in [C]
	PUSH	PSW	
ZCO1:	IN   	CSTAT			;Show Character
	ANI	04H
	JZ	ZCO1
	MOV	A,C
	OUT	COUT
	POP	PSW
	RET
;
ZCI:					;Return keyboard character in [A]
  IF CPM
	PUSH	B
	PUSH	D
	PUSH	H
	MVI	C,RDCON
	CALL	BDOS
	POP	H
	POP	D
	POP	B
	RET
  ELSE
ZCI1:	IN	CSTAT			;Get Character in [A]
	ANI	02H
	JZ	ZCI1
	IN	COUT
	RET
  ENDIF
;

;
@COUNT$STORE:	DB	12H	;Count of sectors to write
@SEC		DW	0000H	;Current sector being written
@TRK		DW	0000H
@DMA		DW	CPM$Loader$Code
@ERFLG		DB	0H
@DELAYStore	DB	0H

SIGN$ON:	DB	CR,LF,'This program HSYSGEN (V1.6) (03/16/2011) '
		DB	      'will WRITE the CPMLDR.COM file'
		DB	CR,LF,'to an IDE CF Memory Disk. This is for a NON-BANKED '
		DB	      'Version of CPM3.'
		DB	CR,LF,'Will use the IDE LBA sector addressing mode and start at:-'
		DB	CR,LF,'Track 0, Sec 1 (12X512 Byte Sectors total). '
		DB	CR,LF,'Do you wish to continue (Y/N)...$'
SAY$OK:		DB	CR,LF,'Writing data $'
SAY$NO:		DB	CR,LF,'Writing data ABOTRED.$'
INIT$FAIL:	DB	CR,LF,'Initilization of IDE drive failed.$'
CPMLDR$OK:	db	CR,LF,'CPMLDR written OK to the system track.'
		DB	CR,LF,'Hit Reset button to Reboot the system.$'
WRITE$FAIL:	DB	CR,LF,'Drive write of CPMLDR image to IDE Disk (Track 0) failed.$'
;
		DS	20H
STACK		DW	0H		;Stack here
		DB	'<-- End of HPUTLDR Code    '	;For Debugging etc.
	