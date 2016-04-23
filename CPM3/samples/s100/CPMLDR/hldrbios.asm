
	.Z80
	ASEG

;******************************************************************************
; CP/M 3.0 LOADER BIOS FOR THE S100Computers (or ITHACA INTERSYSTEMS SYSTEM)Z80
; AND THE S100Computers S100 IDE Board 
;
;	WRITTEN BY 		JOHN MONAHAN  10/22/2009
;
; The only relevence to the Z80 board has to do with the fact that
; this CPU board has two ports that allow a window in the 64K RAM space to be r
; to anywhere within a 24 bit address space. This allows convinient bank switch
; for CPM3 in a CPM3 Banked system. In a non-banked CPM3 system any Z80 CPU car
;
;	12/24/09	V1.1		Correct High/Low byte sector read
;	02/13/2011	V1.1		Removed dependenct on PROM for string writes
;	02/23/2011	V1.2		Combined Banked & Non-Banked versions
;	03/15/2011	V1.3		Single pulse to reset IDE Board
;
;******************************************************************************


TRUE	EQU	-1	; DEFINE LOGICAL VALUES:
FALSE	EQU	NOT TRUE

	;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
BANKED	EQU	FALSE		;<--- NOTE THIS ASSUMES WE WILL BE USING A NON-BANKED CPM3 
	;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	
BELL	EQU	07H
CR	EQU	0DH
LF	EQU	0AH

;   CPU BOARD PORT TO SWITCH IN MEMORY BANKS (ALSO BIT 0 OF D3 FOR PROM)

MPURR0	EQU	0D2H
MPURR1	EQU	0D3H

;   SD Systems Video board Keyboard port

CRTSTAT EQU	0H		;For status and error reporting only
CRTOUT	EQU	1H

;--------------------------------------------------------------------------
;Ports for 8255 chip. Change these to specify where the 8255 is addressed,
;and which of the 8255's ports are connected to which IDE signals.
;The first three control which 8255 ports have the control signals,
;upper and lower data bytes.  The last one is for mode setting for the
;8255 to configure its ports, which must correspond to the way that
;the first three lines define which ports are connected.
;--------------------------------------------------------------------------

IDEPORTA EQU	030H		;lower 8 bits of IDE interface
IDEPORTB EQU	031H		;upper 8 bits of IDE interface
IDEPORTC EQU	032H		;control lines for IDE interface
IDEPORTCTRL EQU	033H		;8255 configuration port

READCFG8255 EQU	10010010B;Set 8255 IDEportC out, IDEportA/B input
WRITECFG8255 EQU	10000000B;Set all three 8255 ports output

;---------------------------------------------------------------
;IDE control lines for use with IDEportC.  Change these 8
;constants to reflect where each signal of the 8255 each of the
;IDE control signals is connected.  All the control signals must
;be on the same port, but these 8 lines let you connect them to
;whichever pins on that port.
;---------------------------------------------------------------

IDEA0LINE EQU	01H		;direct from 8255 to IDE interface
IDEA1LINE EQU	02H		;direct from 8255 to IDE interface
IDEA2LINE EQU	04H		;direct from 8255 to IDE interface
IDECS0LINE EQU	08H		;inverter between 8255 and IDE interface
IDECS1LINE EQU	10H		;inverter between 8255 and IDE interface
IDEWRLINE EQU	20H		;inverter between 8255 and IDE interface
IDERDLINE EQU	40H		;inverter between 8255 and IDE interface
IDERSTLINE EQU	80H		;inverter between 8255 and IDE interface
;
;Symbolic constants for the IDE Drive registers, which makes the
;code more readable than always specifying the address pins

REGDATA EQU	IDECS0LINE
REGERR	EQU	IDECS0LINE + IDEA0LINE
REGSECCNT EQU	IDECS0LINE + IDEA1LINE
REGSECTOR EQU	IDECS0LINE + IDEA1LINE + IDEA0LINE
REGCYLINDERLSB EQU	IDECS0LINE + IDEA2LINE
REGCYLINDERMSB EQU	IDECS0LINE + IDEA2LINE + IDEA0LINE
REGSHD	EQU	IDECS0LINE + IDEA2LINE + IDEA1LINE;(0EH)
REGCOMMAND EQU	IDECS0LINE + IDEA2LINE + IDEA1LINE + IDEA0LINE;(0FH)
REGSTATUS EQU	IDECS0LINE + IDEA2LINE + IDEA1LINE + IDEA0LINE
REGCONTROL EQU	IDECS1LINE + IDEA2LINE + IDEA1LINE
REGASTATUS EQU	IDECS1LINE + IDEA2LINE + IDEA1LINE + IDEA0LINE

;IDE Command Constants.  These should never change.

COMMANDRECAL EQU	10H
COMMANDREAD EQU	20H
COMMANDWRITE EQU	30H
COMMANDINIT EQU	91H
COMMANDID EQU	0ECH
COMMANDSPINDOWN EQU	0E0H
COMMANDSPINUP EQU	0E1H


; IDE Status Register:
;  bit 7: Busy	1=busy, 0=not busy
;  bit 6: Ready 1=ready for command, 0=not ready yet
;  bit 5: DF	1=fault occured insIDE drive
;  bit 4: DSC	1=seek complete
;  bit 3: DRQ	1=data request ready, 0=not ready to xfer yet
;  bit 2: CORR	1=correctable error occured
;  bit 1: IDX	vendor specific
;  bit 0: ERR	1=error occured


; INCLUDE CP/M 3.0 MACRO LIBRARY:

	MACLI	B CPM3
	MACLI	B	Z80

;--------------------------------------------------------------------------
;	                    CODE BEGINS HERE:
;--------------------------------------------------------------------------	

	JP	BOOT		;<----- INITIAL ENTRY ON COLD START
	JP	WBOOT		;REENTRY ON PROGRAM EXIT, WARM START
	JP	CONST		;RETURN CONSOLE INPUT STATUS
	JP	CONIN		;RETURN CONSOLE INPUT CHARACTER
	JP	CONOUT		;<------------ SEND CONSOLE OUTPUT CHARACTER
	JP	LIST		;SEND LIST OUTPUT CHARACTER
	JP	AUXOUT		;SEND AUXILLIARY OUTPUT CHARACTER
	JP	AUXIN		;RETURN AUXILLIARY INPUT CHARACTER
	JP	HOME		;SET DISKS TO LOGICAL HOME
	JP	SELDSK		;SELECT DISK DRIVE RETURN DISK PARAMETER INFO
	JP	SETTRK		;SET DISK TRACK
	JP	SETSEC		;SET DISK SECTOR
	JP	SETDMA		;SET DISK I/O MEMORY ADDRESS
	JP	READ		;<----------- READ PHYSICAL BLOCK(S)
	JP	WRITE		;WRITE PHYSICAL BLOCK(S)
	JP	LISTST		;RETURN LIST DEVICE STATUS
	JP	SECTRN		;TRANSLATE LOGICAL TO PHYSICAL SECTOR
	JP	CONOST		;RETURN CONSOLE OUTPUT STATUS
	JP	AUXIST		;RETURN AUXILLIARY INPUT STATUS
	JP	AUXOST		;RETURN AUXILLIARY OUTPUT STATUS
	JP	DEVTBL		;RETURN ADDRESS OF DEVICE DEFINITION TABLE
	JP	?CINIT		;CHANGE BAUD RATE OF DEVICE
	JP	GETDRV		;RETURN ADDRESS OF DISK DRIVE TABLE
	JP	MULTIO		;SET MULTIPLE RECORD COUNT FOR DISK I/O
	JP	FLUSH		;FLUSH BIOS MAINTAINED DISK CACHING
	JP	?MOVE		;BLOCK MOVE MEMORY TO MEMORY
	JP	?TIME		;SIGNAL TIME AND DATE OPERATION
	JP	BNKSEL		;SEL BANK FOR CODE EXECUTION AND DEFAULT DMA
	JP	SETBNK		;SELECT DIFFERENT BANK FOR DISK I/O DMA OPS.
	JP	?XMOVE		;SET SOURCE AND DEST. BANKS FOR ONE OPERATION
	JP	0		;RESERVED FOR FUTURE EXPANSION
	JP	0		;     DITTO
	JP	0		;     DITTO


CONST:	RET		; ROUTINE HAS NO FUNCTION IN LOADER BIOS:

LISTST:	RET		; ROUTINE HAS NO FUNCTION IN LOADER BIOS:

AUXIST:	RET		; ROUTINE HAS NO FUNCTION IN LOADER BIOS:

AUXOST:	RET		; ROUTINE HAS NO FUNCTION IN LOADER BIOS:

FLUSH:	XOR	A	; ROUTINE HAS NO FUNCTION IN LOADER BIOS:
	RET			; RETURN A FALSE STATUS

LIST:	RET			; ROUTINE HAS NO FUNCTION IN LOADER BIOS:

AUXOUT:	RET		; ROUTINE HAS NO FUNCTION IN LOADER BIOS:

DEVTBL:	RET		; ROUTINE HAS NO FUNCTION IN LOADER BIOS:

?CINIT:	RET		; ROUTINE HAS NO FUNCTION IN LOADER BIOS:

MULTIO:	RET		; ROUTINE HAS NO FUNCTION IN LOADER BIOS:

?TIME:	RET		; ROUTINE HAS NO FUNCTION IN LOADER BIOS:

BNKSEL:	RET		; ROUTINE HAS NO FUNCTION IN LOADER BIOS:

SETBNK:	RET		; ROUTINE HAS NO FUNCTION IN LOADER BIOS:

?XMOVE:	RET		; ROUTINE HAS NO FUNCTION IN LOADER BIOS:

CONIN:	LD	A,'Z'-40H; ROUTINE HAS NO FUNCTION IN LOADER BIOS:
	RET	

AUXIN:	LD	A,'Z'-40H; ROUTINE HAS NO FUNCTION IN LOADER BIOS:
	RET	

CONOUT:	CALL	CONOST	; ROUTINE OUTPUTS A CHARACTER IN [C] TO THE CONSOLE:
	JRZ	CONOUT
	LD	A,C
	CP	0		; SD BOARD VIDEO DOES NOT LIKE NULLS
	RET	Z
	OUT	(CRTOUT),A
	RET	

CONOST:	IN	A,(CRTSTAT); RETURN CONSOLE OUTPUT STATUS:
	AND	04H
	RET	Z		; 0 IF NOT READY
	XOR	A
	DEC	A
	RET	

?MOVE:	EX	DE,HL
	LDIR	
	EX	DE,HL
	RET	

SELDSK:	LD	HL,DPH0	; RETURN DPH ADDRESS FOR DRIVE A:
	RET	

HOME:	LD	BC,0		; HOME SELECTED DRIVE -- TREAT AS SETTRK(0):

SETTRK:	SBCD	@TRK	; ROUTINE SETS TRACK TO ACCESS ON NEXT READ
	RET	
	
SETSEC:	SBCD	@SECT		; ROUTINE SETS SECTOR TO ACCESS ON NEXT READ
	RET	

SETDMA:	SBCD	@DMA	; ROUTINE SETS DISK MEMORY ADDRESS FOR READ
	RET	

SECTRN:	LD	L,C	; NO TRANSLATION FOR HDISK
	LD	H,B
	RET	

GETDRV:	LD	HL,@DTBL; RETURN ADDRESS OF DISK DRIVE TABLE:
	RET	

DCBINIT:RET			; ROUTINE HAS NO FUNCTION IN LOADER BIOS:

WRITE:	XOR	A	; RETURN GOOD RESULT CODE
	RET	


WBOOT:	RET		; WARM BOOT IS NOT USED IN LOADER BIOS

;--------------------------------------------------------------------------
;                                  BOOT
;                   ROUTINE DOES COLD BOOT INITIALIZATION:
;--------------------------------------------------------------------------


BOOT:
	IF	BANKED
	
;==============================================================================
; LETS RELOCATE OUR MEMORY IMAGE UP TO THE 10000H-17FFFH MEMORY
; REGION FOR EXECUTION -- CP/M 3.0 BANK 0 WILL BE THAT EXTENDED
; ADDRESS REGION AND THE TPA WILL BE PART OF THE NORMAL LOWER 64K
;==============================================================================
	
	LD	A,11H		;<--- Map to (0001xxx1) + BIT 0 IS FOR EPROM DISABLE 
	OUT	(MPURR1),A	;THIS RELOCATES THE UPPER WINDOW TO 10000H-13FFFH
	LD	BC,2000H	;WE WILL MOVE 8K BYTES, (should be more than enough)
	LD	HL,0		;STARTING FROM 0000H
	LD	DE,4000H	;UP TO 3FFFH TO 10000H
	LDIR			;Z-80 BLOCK MOVE
	LD	A,11H		;Back to the 10000H RAM area
	OUT	(MPURR0),A	;SWITCH OURSELVES IN TO THAT WINDOW
	ADD	A,4		;AND MAKE THE UPPER WINDOW CONTIGUOUS
	OUT	(MPURR1),A	;THE Z80 ADDRESS LINES ARE NOW, (Unknown to the Z80), 
	;reading (0-7FFFH) to 10000H-17FFFH. Addresses 8000H-FFFFH are unchanged
	;At this point we are in the > 64K window (unknown to the Z80).
;==============================================================================

	ENDIF	
	
	CALL	HDLOGIN		;Bring IDE Drive up to speed
	RET	Z		;<<<< Ret Z if no problem
	
	;Turn off memory bank selection
RESERR:	LD	HL,IDE$FAIL	;Initilization of IDE Drive failed
	CALL	SPECIAL$PMSG	;Note we cannot use the normal @PMSG BIOS call. It appears 
	HALT			;Cannot recover easily, banks may be screwed up, just HALT

HDLOGIN:;Initilize the 8255 and drive then do a hard reset on the drive, 
	LD	A,READCFG8255	;Config 8255 chip (10010010B), read mode on return
	OUT	(IDEPORTCTRL),A	;Config 8255 chip, READ mode
	
	;Hard reset the disk drive 
	;For some reason some CF cards need to the RESET line 
	;pulsed very carefully. You may need to play around   
	LD	A,IDERSTLINE	;with the pulse length. Symptoms are: incorrect data comming
	OUT	(IDEPORTC),A	;back from a sector read (often due to the wrong sector being re
	;I have a (negative)pulse of 2.7uSec. (10Mz Z80, two IO wait states).
	LD	B,20H		;Which seem to work for the 5 different CF cards I have.
RESETDELAY:
	DEC	B
	JP	NZ,RESETDELAY	;Delay (reset pulse width)

	XOR	A
	OUT	(IDEPORTC),A	;No IDE control lines asserted (just bit 7 of port C)
	CALL	DELAY$32
	
	LD	D,11100000B	;Data for IDE SDH reg (512bytes, LBA mode,single drive,head 0
	;For Trk,Sec,head (non LBA) use 10100000
	;Note. Cannot get LBA mode to work with an old Seagate Medalist 6531 drive
	;have to use teh non-LBA mode. (Common for old hard disks).

	LD	E,REGSHD	;00001110,(0EH) for CS0,A2,A1,  
	CALL	IDEWR8D		;Write byte to select the MASTER device;
	LD	B,0FFH		;<<< May need to adjust delay time
WAITINIT: 
	LD	E,REGSTATUS	;Get status after initilization
	CALL	IDERD8D		;Check Status (info in [D])
	BIT	7,D
	RET	Z		;Return if ready bit is zero
	;Delay to allow drive to get up to speed
	PUSH	BC		;(the 0FFH above)
	LD	BC,0FFFFH	
DELAY2:	LD	D,2		;May need to adjust delay time to allow cold drive to
DELAY1:	DEC	D		;to speed
	JP	NZ,DELAY1
	DEC	BC
	LD	A,C
	OR	B
	JP	NZ,DELAY2
	POP	BC
	DJNZ	WAITINIT
	XOR	A		;Flag error on return
	DEC	A
	RET	

;------------------------------------------------------------------------------
;	   IDE HARD DISK READ A SECTOR AT @TRK, @SEC TO Address at @DMA
;------------------------------------------------------------------------------

READ:	SSPD	OLDSTACK	;At bottom of this smodule
	LD	SP,NEWSTACK
	XOR	A
	LD	(ERFLG),A	;CLEAR THE ERROR FLAG

	CALL	WRLBA		;Send to drive the sector we want to read. Converting
	;CPM TRK/SEC info to Drive LBA address
	;Send before error check so info is updated
	CALL	IDEWAITNOTBUSY	;make sure drive is ready
	JP	C,SETERRORFLAG	;Returned with NZ set if error

	LD	D,COMMANDREAD
	LD	E,REGCOMMAND
	CALL	IDEWR8D		;Send sector write command to drive.
	CALL	IDEWAITDRQ	;Wait until it's got the data
	JP	C,SETERRORFLAG	;If problem abort
	
	LD	HL,(@DMA)	;DMA address
	LD	B,0		;256X2 = 512 bytes
MORERD16:
	LD	A,REGDATA	;REG regsiter address
	OUT	(IDEPORTC),A	

	OR	IDERDLINE	;08H+40H, Pulse RD line
	OUT	(IDEPORTC),A	

	IN	A,(IDEPORTA)	;read the LOWER byte
	LD	(HL),A
	INC	HL
	IN	A,(IDEPORTB)	;THEN read the UPPER byte
	LD	(HL),A
	INC	HL
	
	LD	A,REGDATA	;Deassert RD line
	OUT	(IDEPORTC),A

	DJNZ	MORERD16

	LD	E,REGSTATUS	;Check R/W status when done
	CALL	IDERD8D
	LD	A,D
	AND	01H
	LD	(ERFLG),A	;Ret Z if All OK
	JP	NZ,SETERRORFLAG
	LSPD	OLDSTACK	;<<< Critial this is here. Spent 2 hours 
	RET			;    debugging, to find this out!

SETERRORFLAG: ;For now just return with error flag set
	XOR	A
	DEC	A
	LD	(ERFLG),A	;Ret NZ if problem
	LSPD	OLDSTACK
	RET	

;=============================================================================
;                              SUPPORT ROUTINES
;=============================================================================

WRLBA:	
	LD	HL,(@TRK)	;Get CPM requested Track Hi&Lo
	LD	H,00H		;zero high track byte
	LD	A,L		;load low track byte to accumulator
	CP	00H		;check for 0 track and skip track loop
	JP	Z,LBASEC
	LD	B,06H		;load counter to shift low track value 6 places to left i.e X 64
LBATRK:
	ADD	HL,HL		;Add HL to itself 6 times to multiply by 64
	DJNZ	LBATRK		;loop around 6 times i.e x 64

LBASEC:
	LD	A,(@SECT)	;Get CPM requested sector
	ADD	A,L		;Add value in L to sector info in A
	JP	NC,LBAOFF	;If no carry jump to lba offset correction
	INC	H		;carry one over to H
LBAOFF:
	LD	L,A		;copy accumulator to L
	DEC	HL		;decrement 1 from the HL register pair
	;HL should now contain correct LBA value

;---------
	LD	DE, MSGLBA
	CALL	PSTRING		;(LBA = 00 (<-- Old "Heads" = 0 for these drives).
;---------		
	LD	D,0		;Send 0 for upper cyl value
	LD	E,REGCYLINDERMSB
	CALL	IDEWR8D		;Send info to drive
;---------
	LD	A,D		;print upper "cylinder" byte
	CALL	PHEX
;---------

	LD	D,H		;load lba high byte to D from H
	LD	E,REGCYLINDERLSB
	CALL	IDEWR8D		;Send info to drive
;---------
	LD	A,D		;print high LBA byte
	CALL	PHEX
;---------

	LD	D,L		;load lba low byte to D from L
	LD	E,REGSECTOR
	CALL	IDEWR8D		;Send info to drive

;---------
	LD	A,D		;print low LBA byte
	CALL	PHEX
	LD	DE, MSGBRACKET	;)$ and closing bracket
	CALL	PSTRING	
;---------	
	
	LD	D,1		;For now, one sector at a time
	LD	E,REGSECCNT
	CALL	IDEWR8D

	RET	
;==============================================================================
;==============================================================================


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



ZCO:	PUSH	AF	;Write character that is in [C]
ZCO1:	IN	A,(0H)		;Show Character
	AND	04H
	JP	Z,ZCO1
	LD	A,C
	OUT	(1H),A
	POP	AF
	RET	



; Print a string in [DE] up to '$'
PSTRING:
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


;==============================================================================
;==============================================================================

IDEWAITNOTBUSY: ;Drive READY if 01000000
	LD	B,0FFH
	LD	C,0FFH		;Delay, must be above 80H for 4MHz Z80. Leave longer for slower d
MOREWAIT:
	LD	E,REGSTATUS	;wait for RDY bit to be set
	CALL	IDERD8D
	LD	A,D
	AND	11000000B
	XOR	01000000B
	JP	Z,DONENOTBUSY	
	DJNZ	MOREWAIT
	DEC	C
	JP	NZ,MOREWAIT
	SCF			;Set carry to indicqate an error
	RET	
DONENOTBUSY:
	OR	A		;Clear carry it indicate no error
	RET	
	;Wait for the drive to be ready to transfer data.
	;Returns the drive's status in Acc
IDEWAITDRQ:
	LD	B,0FFH
	LD	C,0FFH		;Delay, must be above 80H for 4MHz Z80. Leave longer for slower d
MOREDRQ:
	LD	E,REGSTATUS	;wait for DRQ bit to be set
	CALL	IDERD8D
	LD	A,D
	AND	10001000B
	CP	00001000B
	JP	Z,DONEDRQ
	DJNZ	MOREDRQ
	DEC	C
	JP	NZ,MOREDRQ
	SCF			;Set carry to indicate error
	RET	
DONEDRQ:
	OR	A		;Clear carry
	RET	

DELAY$32: LD	A,40		;DELAY ~32 MS (DOES NOT SEEM TO BE CRITICAL)
DELAY3:	LD	B,0
M0:	DJNZ	M0
	DEC	A
	JP	NZ,DELAY3 
	RET	

SPECIAL$PMSG: ;Cannot use @PMSG in LOADERBIOS
	LD	A,(HL)
	INC	HL
	CP	'$'
	RET	Z
	LD	C,A
	CALL	CONOUT		;Hardware send to consol
	JP	SPECIAL$PMSG


;------------------------------------------------------------------------------
; Low Level 8 bit R/W to the drive controller.  These are the routines that tal
; directly to the drive controller registers, via the 8255 chip.  
; Note the 16 bit I/O to the drive (which is only for SEC R/W) is done directly
; in the routines READ for speed reasons.
;------------------------------------------------------------------------------

IDERD8D:;READ 8 bits from IDE register in [E], return info in [D]
	LD	A,E
	OUT	(IDEPORTC),A	;drive address onto control lines

	OR	IDERDLINE	;RD pulse pin (40H)
	OUT	(IDEPORTC),A	;assert read pin

	IN	A,(IDEPORTA)
	LD	D,A		;return with data in [D]

	LD	A,E		;<---Ken Robbins suggestion
	OUT	(IDEPORTC),A	;deassert RD pin first

	XOR	A
	OUT	(IDEPORTC),A	;Zero all port C lines
	RET	


IDEWR8D:;WRITE Data in [D] to IDE register in [E]
	LD	A,WRITECFG8255	;Set 8255 to write mode
	OUT	(IDEPORTCTRL),A

	LD	A,D		;Get data put it in 8255 A port
	OUT	(IDEPORTA),A

	LD	A,E		;select IDE register
	OUT	(IDEPORTC),A

	OR	IDEWRLINE	;lower WR line
	OUT	(IDEPORTC),A

	LD	A,E		;<---Ken Robbins suggestion
	OUT	(IDEPORTC),A	;deassert WR pin first

	XOR	A		;Deselect all lines including WR line
	OUT	(IDEPORTC),A

	LD	A,READCFG8255	;Config 8255 chip, read mode on return
	OUT	(IDEPORTCTRL),A
	RET	

PMSG:	LD	A,(HL)		;Print string in [HL] up to'$'
	CP	'$'
	RET	Z
	LD	C,A
	CALL	CONOUT
	JP	P,PMSG
	

;-----------------------------------------------------------------------

IDE$FAIL: DEFB	BELL,CR,LF,'Initilization of IDE Drive Failed. Will HALT the Z80 C
MSGLBA:	DEFB	'  (LBA = 00$'
MSGBRACKET: DEFB	')$'

@TRK:	DEFS	2		;2 BYTES FOR NEXT TRACK TO READ OR WRITE
@DMA:	DEFS	2		;2 BYTES FOR NEXT DMA ADDRESS
@SECT:	DEFS	2		;2 BYTES FOR SECTOR
ERFLG:	DEFB	0H		;Error Flag.

;--------------------------------------------------------
; BUILD CPM3 DPH'S ETC USING MACROS FOR HDISK AND BY HAND
;--------------------------------------------------------
	
	; DISK DRIVE TABLE:
@DTBL:	DEFW	DPH0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

	; DRIVE A DISK PARAMETER HEADER:
	DEFW	WRITE		;DCB-II WRITE ROUTINE
	DEFW	READ		;DCB-II READ ROUTINE
	DEFW	SELDSK		;DCB-II LOGIN PROCEDURE
	DEFW	DCBINIT		;DCB-II DRIVE INITIALIZATION ROUTINE
	DEFB	0		;RELATIVE DRIVE 0 ON THIS CONTROLLER
	DEFB	0		;MEDIA TYPE ALWAYS KNOWN FOR HARD DISK
DPH0:	DEFW	0		;TRANSLATION VECTOR
	DEFB	0,0,0,0,0,0,0,0,0
	DEFB	0		;MEDIA FLAG
	DEFW	HD$DPB		;ADDRESS OF DISK PARAMETER BLOCK
	DEFW	CSV		;CHECKSUM VECTOR
	DEFW	ALV		;ALLOCATION VECTOR
	DEFW	DIRBCB		;DIRECTORY BUFFER CONTROL BLOCK
	DEFW	DATABCB		;DATA BUFFER CONTROL BLOCK
	DEFW	0FFFFH		;NO HASHING
	DEFB	0		;HASH BANK

	; IDE HARD DISK PARAMETER BLOCK:
HD$DPB:	DPB	512,64,256,2048,1024,1,8000H


	; DIRECTORY BUFFER CONTROL BLOCK:
DIRBCB:
	DEFB	0FFH		;DRIVE 0
	DEFS	3
	DEFS	1
	DEFS	1
	DEFS	2
	DEFS	2
	DEFW	DIRBUF		;POINTER TO DIRECTORY BUFFER

	; DATA BUFFER CONTROL BLOCK:
DATABCB:
	DEFB	0FFH		;DRIVE 0
	DEFS	3
	DEFS	1
	DEFS	1
	DEFS	2
	DEFS	2
	DEFW	DATABUF		;POINTER TO DATA BUFFER


	; DIRECTORY BUFFER
DIRBUF:	DEFS	512		;1 PHYSICAL SECTOR

	; DATA BUFFER:
DATABUF:DEFS	512		;1 PHYSICAL SECTOR

OLDSTACK: DEFW	0
	DEFS	40
NEWSTACK: DEFW	0
	
	; DRIVE ALLOCATION VECTOR:
ALV:	DEFS	1000		;SPACE FOR DOUBLE BIT ALLOCATION VECTORS
CSV:	;NO CHECKSUM VECTOR REQUIRED FOR A HDISK
	DEFB	'<-- END OF LDRBIOS  ';For debugging
;
	END	
