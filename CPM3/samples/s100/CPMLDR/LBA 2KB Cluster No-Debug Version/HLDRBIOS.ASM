;********************************************************************************************
; CP/M 3.0 LOADER BIOS FOR THE S100Computers (or ITHACA INTERSYSTEMS SYSTEM)Z80 BOARDS
; AND THE S100Computers S100 IDE Board 
;
;	WRITTEN BY 		JOHN MONAHAN  10/22/2009
;
; The only relevence to the Z80 board has to do with the fact that
; this CPU board has two ports that allow a window in the 64K RAM space to be re-mapped
; to anywhere within a 24 bit address space. This allows convinient bank switching
; for CPM3 in a CPM3 Banked system. In a non-banked CPM3 system any Z80 CPU card can be used.
;
;	12/24/09	V1.1		Correct High/Low byte sector read
;	02/13/2011	V1.1		Removed dependenct on PROM for string writes
;	02/23/2011	V1.2		Combined Banked & Non-Banked versions
;	03/15/2011	V1.3		Single pulse to reset IDE Board
;
;********************************************************************************************


TRUE		EQU	-1		; DEFINE LOGICAL VALUES:
FALSE		EQU	NOT TRUE

					;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
BANKED		EQU	FALSE		;<--- NOTE THIS ASSUMES WE WILL BE USING A NON-BANKED CPM3 
					;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
					
BELL		EQU	07H
CR		EQU	0DH
LF		EQU	0AH

;   CPU BOARD PORT TO SWITCH IN MEMORY BANKS (ALSO BIT 0 OF D3 FOR PROM)

MPURR0		EQU	0D2H
MPURR1		EQU	0D3H

;   SD Systems Video board Keyboard port

CRTSTAT		EQU	0H			;For status and error reporting only
CRTOUT		EQU	1H

;--------------------------------------------------------------------------
;Ports for 8255 chip. Change these to specify where the 8255 is addressed,
;and which of the 8255's ports are connected to which IDE signals.
;The first three control which 8255 ports have the control signals,
;upper and lower data bytes.  The last one is for mode setting for the
;8255 to configure its ports, which must correspond to the way that
;the first three lines define which ports are connected.
;--------------------------------------------------------------------------

IDEportA	EQU	030H		;lower 8 bits of IDE interface
IDEportB	EQU	031H		;upper 8 bits of IDE interface
IDEportC	EQU	032H		;control lines for IDE interface
IDEportCtrl	EQU	033H		;8255 configuration port

READcfg8255	EQU	10010010b	;Set 8255 IDEportC out, IDEportA/B input
WRITEcfg8255	EQU	10000000b	;Set all three 8255 ports output

;---------------------------------------------------------------
;IDE control lines for use with IDEportC.  Change these 8
;constants to reflect where each signal of the 8255 each of the
;IDE control signals is connected.  All the control signals must
;be on the same port, but these 8 lines let you connect them to
;whichever pins on that port.
;---------------------------------------------------------------

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

	MACLIB CPM3
	MACLIB	Z80

;--------------------------------------------------------------------------
;	                    CODE BEGINS HERE:
;--------------------------------------------------------------------------	

		JMP	BOOT		;<----- INITIAL ENTRY ON COLD START
		JMP	WBOOT		;REENTRY ON PROGRAM EXIT, WARM START
		JMP	CONST		;RETURN CONSOLE INPUT STATUS
		JMP	CONIN		;RETURN CONSOLE INPUT CHARACTER
		JMP	CONOUT		;<------------ SEND CONSOLE OUTPUT CHARACTER
		JMP	LIST		;SEND LIST OUTPUT CHARACTER
		JMP	AUXOUT		;SEND AUXILLIARY OUTPUT CHARACTER
		JMP	AUXIN		;RETURN AUXILLIARY INPUT CHARACTER
		JMP	HOME		;SET DISKS TO LOGICAL HOME
		JMP	SELDSK		;SELECT DISK DRIVE RETURN DISK PARAMETER INFO
		JMP	SETTRK		;SET DISK TRACK
		JMP	SETSEC		;SET DISK SECTOR
		JMP	SETDMA		;SET DISK I/O MEMORY ADDRESS
		JMP	READ		;<----------- READ PHYSICAL BLOCK(S)
		JMP	WRITE		;WRITE PHYSICAL BLOCK(S)
		JMP	LISTST		;RETURN LIST DEVICE STATUS
		JMP	SECTRN		;TRANSLATE LOGICAL TO PHYSICAL SECTOR
		JMP	CONOST		;RETURN CONSOLE OUTPUT STATUS
		JMP	AUXIST		;RETURN AUXILLIARY INPUT STATUS
		JMP	AUXOST		;RETURN AUXILLIARY OUTPUT STATUS
		JMP	DEVTBL		;RETURN ADDRESS OF DEVICE DEFINITION TABLE
		JMP	?CINIT		;CHANGE BAUD RATE OF DEVICE
		JMP	GETDRV		;RETURN ADDRESS OF DISK DRIVE TABLE
		JMP	MULTIO		;SET MULTIPLE RECORD COUNT FOR DISK I/O
		JMP	FLUSH		;FLUSH BIOS MAINTAINED DISK CACHING
		JMP	?MOVE		;BLOCK MOVE MEMORY TO MEMORY
		JMP	?TIME		;SIGNAL TIME AND DATE OPERATION
		JMP	BNKSEL		;SEL BANK FOR CODE EXECUTION AND DEFAULT DMA
		JMP	SETBNK		;SELECT DIFFERENT BANK FOR DISK I/O DMA OPS.
		JMP	?XMOVE		;SET SOURCE AND DEST. BANKS FOR ONE OPERATION
		JMP	0		;RESERVED FOR FUTURE EXPANSION
		JMP	0		;     DITTO
		JMP	0		;     DITTO


CONST:		RET			; ROUTINE HAS NO FUNCTION IN LOADER BIOS:

LISTST:		RET			; ROUTINE HAS NO FUNCTION IN LOADER BIOS:

AUXIST:		RET			; ROUTINE HAS NO FUNCTION IN LOADER BIOS:

AUXOST:		RET			; ROUTINE HAS NO FUNCTION IN LOADER BIOS:

FLUSH:		XRA	A		; ROUTINE HAS NO FUNCTION IN LOADER BIOS:
		RET			; RETURN A FALSE STATUS

LIST:		RET			; ROUTINE HAS NO FUNCTION IN LOADER BIOS:

AUXOUT:		RET			; ROUTINE HAS NO FUNCTION IN LOADER BIOS:

DEVTBL:		RET			; ROUTINE HAS NO FUNCTION IN LOADER BIOS:

?CINIT:		RET			; ROUTINE HAS NO FUNCTION IN LOADER BIOS:

MULTIO:		RET			; ROUTINE HAS NO FUNCTION IN LOADER BIOS:

?TIME:		RET			; ROUTINE HAS NO FUNCTION IN LOADER BIOS:

BNKSEL:		RET			; ROUTINE HAS NO FUNCTION IN LOADER BIOS:

SETBNK:		RET			; ROUTINE HAS NO FUNCTION IN LOADER BIOS:

?XMOVE:		RET			; ROUTINE HAS NO FUNCTION IN LOADER BIOS:

CONIN:		MVI   A,'Z'-40H		; ROUTINE HAS NO FUNCTION IN LOADER BIOS:
		RET

AUXIN:		MVI   A,'Z'-40H		; ROUTINE HAS NO FUNCTION IN LOADER BIOS:
		RET

CONOUT:		CALL	CONOST		; ROUTINE OUTPUTS A CHARACTER IN [C] TO THE CONSOLE:
		JRZ	CONOUT
		MOV	A,C
		CPI	0		; SD BOARD VIDEO DOES NOT LIKE NULLS
		RZ
		OUT	CRTOUT
		RET	

CONOST:		IN	CRTSTAT		; RETURN CONSOLE OUTPUT STATUS:
		ANI	04H
		RZ			; 0 IF NOT READY
		XRA	A
		DCR	A
		RET

?MOVE:		XCHG
		LDIR
		XCHG
		RET

SELDSK:		LXI	H,DPH0		; RETURN DPH ADDRESS FOR DRIVE A:
		RET

HOME:		LXI	B,0		; HOME SELECTED DRIVE -- TREAT AS SETTRK(0):

SETTRK:		SBCD	@TRK		; ROUTINE SETS TRACK TO ACCESS ON NEXT READ
		RET
	
SETSEC:		SBCD	@SECT		; ROUTINE SETS SECTOR TO ACCESS ON NEXT READ
		RET

SETDMA:		SBCD	@DMA		; ROUTINE SETS DISK MEMORY ADDRESS FOR READ
		RET

SECTRN:		MOV	L,C		; NO TRANSLATION FOR HDISK
		MOV	H,B
		RET

GETDRV:		LXI	H,@DTBL		; RETURN ADDRESS OF DISK DRIVE TABLE:
		RET

DCBINIT:	RET			; ROUTINE HAS NO FUNCTION IN LOADER BIOS:

WRITE:		XRA	A		; RETURN GOOD RESULT CODE
		RET


WBOOT:		RET			; WARM BOOT IS NOT USED IN LOADER BIOS

;--------------------------------------------------------------------------
;                                  BOOT
;                   ROUTINE DOES COLD BOOT INITIALIZATION:
;--------------------------------------------------------------------------


BOOT:
		IF	BANKED
	
;=========================================================================================	
; LETS RELOCATE OUR MEMORY IMAGE UP TO THE 10000H-17FFFH MEMORY
; REGION FOR EXECUTION -- CP/M 3.0 BANK 0 WILL BE THAT EXTENDED
; ADDRESS REGION AND THE TPA WILL BE PART OF THE NORMAL LOWER 64K
;=========================================================================================
	
		MVI	A,11H		;<--- Map to (0001xxx1) + BIT 0 IS FOR EPROM DISABLE 
		OUT	MPURR1		;THIS RELOCATES THE UPPER WINDOW TO 10000H-13FFFH
		LXI	B,2000H		;WE WILL MOVE 8K BYTES, (should be more than enough)
		LXI	H,0		;STARTING FROM 0000H
		LXI	D,4000H		;UP TO 3FFFH TO 10000H
		LDIR			;Z-80 BLOCK MOVE
		MVI	A,11H		;Back to the 10000H RAM area
		OUT	MPURR0		;SWITCH OURSELVES IN TO THAT WINDOW
		ADI	4		;AND MAKE THE UPPER WINDOW CONTIGUOUS
		OUT	MPURR1		;THE Z80 ADDRESS LINES ARE NOW, (Unknown to the Z80), 
					;reading (0-7FFFH) to 10000H-17FFFH. Addresses 8000H-FFFFH are unchanged
					;At this point we are in the > 64K window (unknown to the Z80).
;===========================================================================================

		ENDIF
					
		CALL	HDLOGIN		;Bring IDE Drive up to speed
		RZ			;<<<< Ret Z if no problem
	
					;Turn off memory bank selection
RESERR:		LXI	H,IDE$FAIL	;Initilization of IDE Drive failed
		CALL	SPECIAL$PMSG	;Note we cannot use the normal @PMSG BIOS call. It appears not to be valid yet 
		HLT			;Cannot recover easily, banks may be screwed up, just HALT

HDLOGIN:				;Initilize the 8255 and drive then do a hard reset on the drive, 
		MVI	A,READcfg8255	;Config 8255 chip (10010010B), read mode on return
		OUT	IDEportCtrl	;Config 8255 chip, READ mode
				
					;Hard reset the disk drive 
					;For some reason some CF cards need to the RESET line 
					;pulsed very carefully. You may need to play around   
		MVI	A,IDErstline	;with the pulse length. Symptoms are: incorrect data comming
		OUT	IDEportC	;back from a sector read (often due to the wrong sector being read)
					;I have a (negative)pulse of 2.7uSec. (10Mz Z80, two IO wait states).
		MVI	B,20H		;Which seem to work for the 5 different CF cards I have.
ResetDelay:
		DCR	B
		JNZ	ResetDelay	;Delay (reset pulse width)

		XRA	A
		OUT	IDEportC	;No IDE control lines asserted (just bit 7 of port C)
		CALL	DELAY$32
			
		MVI	D,11100000b	;Data for IDE SDH reg (512bytes, LBA mode,single drive,head 0000)
					;For Trk,Sec,head (non LBA) use 10100000
					;Note. Cannot get LBA mode to work with an old Seagate Medalist 6531 drive.
					;have to use teh non-LBA mode. (Common for old hard disks).

		MVI	E,REGshd	;00001110,(0EH) for CS0,A2,A1,  
		CALL	IDEwr8D		;Write byte to select the MASTER device;
		MVI	B,0FFH		;<<< May need to adjust delay time
WaitInit:	
		MVI	E,REGstatus	;Get status after initilization
		CALL	IDErd8D		;Check Status (info in [D])
		BIT	7,D
		RZ			;Return if ready bit is zero
					;Delay to allow drive to get up to speed
		PUSH	B		;(the 0FFH above)
		LXI	B,0FFFFH	
DELAY2:		MVI	D,2		;May need to adjust delay time to allow cold drive to
DELAY1:		DCR	D		;to speed
		JNZ	DELAY1
		DCX	B
		MOV	A,C
		ORA	B
		JNZ	DELAY2
		POP	B
		DJNZ	WaitInit
		XRA	A		;Flag error on return
		DCR	A
		RET

;--------------------------------------------------------------------------------
;	   IDE HARD DISK READ A SECTOR AT @TRK, @SEC TO Address at @DMA
;--------------------------------------------------------------------------------

READ:		SSPD	OLDSTACK	;At bottom of this smodule
		LXI	SP,NEWSTACK
		XRA	A
		STA	ERFLG	     	;CLEAR THE ERROR FLAG

		CALL	wrlba		;Send to drive the sector we want to read. Converting
					;CPM TRK/SEC info to Drive LBA address
					;Send before error check so info is updated
		CALL	IDEwaitnotbusy	;make sure drive is ready
		JC	SetErrorFlag	;Returned with NZ set if error

		MVI	D,COMMANDread
		MVI	E,REGcommand
		CALL	IDEwr8D		;Send sector write command to drive.
		CALL	IDEwaitdrq	;Wait until it's got the data
		JC	SetErrorFlag	;If problem abort
		
		LHLD  	@DMA		;DMA address
		MVI	B,0		;256X2 = 512 bytes
MoreRD16:
		MVI	A,REGdata	;REG regsiter address
		OUT	IDEportC	

		ORI	IDErdline	;08H+40H, Pulse RD line
		OUT	IDEportC	

		IN	IDEportA	;read the LOWER byte
		MOV	M,A
		INX	H
		IN	IDEportB	;THEN read the UPPER byte
		MOV	M,A
		INX	H
	
		MVI	A,REGdata	;Deassert RD line
		OUT	IDEportC

		DJNZ	MoreRD16

		MVI	E,REGstatus	;Check R/W status when done
		CALL	IDErd8D
		MOV	A,D
		ANI	01H
		STA	ERFLG		;Ret Z if All OK
		JNZ	SetErrorFlag
		LSPD	OLDSTACK	;<<< Critial this is here. Spent 2 hours 
		RET			;    debugging, to find this out!

SetErrorFlag:				;For now just return with error flag set
		XRA	A
		DCR	A
		STA	ERFLG		;Ret NZ if problem
		LSPD	OLDSTACK
		RET

;=============================================================================
;                              SUPPORT ROUTINES
;=============================================================================

wrlba:					
		LHLD	@TRK		;Get CPM requested Track Hi&Lo
		MVI	H,00H		;zero high track byte
		MOV	A,L		;load low track byte to accumulator
		CPI	00H		;check for 0 track and skip track loop
		JZ	lbasec
		MVI	B,06H		;load counter to shift low track value 6 places to left i.e X 64
lbatrk:
		DAD	H		;Add HL to itself 6 times to multiply by 64
		DJNZ	lbatrk		;loop around 6 times i.e x 64

lbasec:
		LDA	@SECT		;Get CPM requested sector
		ADD	L		;Add value in L to sector info in A
		JNC	lbaoff		;If no carry jump to lba offset correction
		INR	H		;carry one over to H
lbaoff:
		MOV	L,A		;copy accumulator to L
		DCX	H		;decrement 1 from the HL register pair
					;HL should now contain correct LBA value

	
		MVI	D,0		;Send 0 for upper cyl value
		MVI	E,REGcylinderMSB
		CALL	IDEwr8D		;Send info to drive

		MOV	D,H		;load lba high byte to D from H
		MVI	E,REGcylinderLSB
		CALL	IDEwr8D		;Send info to drive

		MOV	D,L		;load lba low byte to D from L
		MVI	E,REGsector
		CALL	IDEwr8D		;Send info to drive
	
		MVI	D,1		;For now, one sector at a time
		MVI	E,REGseccnt
		CALL	IDEwr8D

		RET


;================================================================================

IDEwaitnotbusy:				;Drive READY if 01000000
		MVI	B,0FFH
		MVI	C,0FFH		;Delay, must be above 80H for 4MHz Z80. Leave longer for slower drives
MoreWait:
		MVI	E,REGstatus	;wait for RDY bit to be set
		CALL	IDErd8D
		MOV	A,D
		ANI	11000000B
		XRI	01000000B
		JZ	DoneNotbusy	
		DJNZ	MoreWait
		DCR	C
		JNZ	MoreWait
		STC			;Set carry to indicqate an error
		RET
DoneNotBusy:
		ORA	A		;Clear carry it indicate no error
		RET
					;Wait for the drive to be ready to transfer data.
					;Returns the drive's status in Acc
IDEwaitdrq:
		MVI	B,0FFH
		MVI	C,0FFH		;Delay, must be above 80H for 4MHz Z80. Leave longer for slower drives
MoreDRQ:
		MVI	E,REGstatus	;wait for DRQ bit to be set
		CALL	IDErd8D
		MOV	A,D
		ANI	10001000B
		CPI	00001000B
		JZ	DoneDRQ
		DJNZ	MoreDRQ
		DCR	C
		JNZ	MoreDRQ
		STC			;Set carry to indicate error
		RET
DoneDRQ:
		ORA	A		;Clear carry
		RET

DELAY$32:	MVI	A,40		;DELAY ~32 MS (DOES NOT SEEM TO BE CRITICAL)
DELAY3:		MVI	B,0
M0:		DJNZ	M0
		DCR	A
		JNZ	DELAY3 
		RET

SPECIAL$PMSG:				;Cannot use @PMSG in LOADERBIOS
		MOV	A,M
		INX	H
		CPI	'$'
		RZ	
		MOV	C,A
		CALL	CONOUT		;Hardware send to consol
		JMP	SPECIAL$PMSG


;-------------------------------------------------------------------------------
; Low Level 8 bit R/W to the drive controller.  These are the routines that talk
; directly to the drive controller registers, via the 8255 chip.  
; Note the 16 bit I/O to the drive (which is only for SEC R/W) is done directly 
; in the routines READ for speed reasons.
;-------------------------------------------------------------------------------

IDErd8D:				;READ 8 bits from IDE register in [E], return info in [D]
		MOV	A,E
		OUT	IDEportC	;drive address onto control lines

		ORI	IDErdline	;RD pulse pin (40H)
		OUT	IDEportC	;assert read pin

		IN	IDEportA
		MOV	D,A		;return with data in [D]

		MOV	A,E		;<---Ken Robbins suggestion
		OUT	IDEportC	;deassert RD pin first

		XRA	A
		OUT	IDEportC	;Zero all port C lines
		ret


IDEwr8D:				;WRITE Data in [D] to IDE register in [E]
		MVI	A,WRITEcfg8255	;Set 8255 to write mode
		OUT	IDEportCtrl

		MOV	A,D		;Get data put it in 8255 A port
		OUT	IDEportA

		MOV	A,E		;select IDE register
		OUT	IDEportC

		ORI	IDEwrline	;lower WR line
		OUT	IDEportC

		MOV	A,E		;<---Ken Robbins suggestion
		OUT	IDEportC	;deassert WR pin first

		XRA	A		;Deselect all lines including WR line
		OUT	IDEportC

		MVI	A,READcfg8255	;Config 8255 chip, read mode on return
		OUT	IDEportCtrl
		RET

PMSG:		MOV	A,M		;Print string in [HL] up to'$'
		CPI	'$'
		RZ
		MOV	C,A
		CALL	CONOUT
		JP	PMSG
	

;-----------------------------------------------------------------------

IDE$FAIL:	DB	BELL,CR,LF,'Initilization of IDE Drive Failed. Will HALT the Z80 CPU!$'

@TRK:		DS	2		;2 BYTES FOR NEXT TRACK TO READ OR WRITE
@DMA:		DS	2		;2 BYTES FOR NEXT DMA ADDRESS
@SECT		DS	2		;2 BYTES FOR SECTOR
ERFLG		DB	0H		;Error Flag.

;--------------------------------------------------------
; BUILD CPM3 DPH'S ETC USING MACROS FOR HDISK AND BY HAND
;--------------------------------------------------------
	
	; DISK DRIVE TABLE:
@DTBL:	DW	DPH0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

	; DRIVE A DISK PARAMETER HEADER:
	DW	WRITE			;DCB-II WRITE ROUTINE
	DW	READ			;DCB-II READ ROUTINE
	DW	SELDSK			;DCB-II LOGIN PROCEDURE
	DW	DCBINIT			;DCB-II DRIVE INITIALIZATION ROUTINE
	DB	0			;RELATIVE DRIVE 0 ON THIS CONTROLLER
	DB	0			;MEDIA TYPE ALWAYS KNOWN FOR HARD DISK
DPH0:	DW	0			;TRANSLATION VECTOR
	DB	0,0,0,0,0,0,0,0,0
	DB	0			;MEDIA FLAG
	DW	HD$DPB			;ADDRESS OF DISK PARAMETER BLOCK
	DW	CSV			;CHECKSUM VECTOR
	DW	ALV			;ALLOCATION VECTOR
	DW	DIRBCB			;DIRECTORY BUFFER CONTROL BLOCK
	DW	DATABCB			;DATA BUFFER CONTROL BLOCK
	DW	0FFFFH			;NO HASHING
	DB	0			;HASH BANK

	; IDE HARD DISK PARAMETER BLOCK:
HD$DPB:	 DPB	512,64,256,2048,1024,1,8000H


	; DIRECTORY BUFFER CONTROL BLOCK:
DIRBCB:
	DB	0FFH			;DRIVE 0
	DS	3
	DS	1
	DS	1
	DS	2
	DS	2
	DW	DIRBUF			;POINTER TO DIRECTORY BUFFER

	; DATA BUFFER CONTROL BLOCK:
DATABCB:
	DB	0FFH			;DRIVE 0
	DS	3
	DS	1
	DS	1
	DS	2
	DS	2
	DW	DATABUF			;POINTER TO DATA BUFFER


	; DIRECTORY BUFFER
DIRBUF:	DS	512			;1 PHYSICAL SECTOR

	; DATA BUFFER:
DATABUF:DS	512			;1 PHYSICAL SECTOR

OLDSTACK:DW	0
	 DS	40
NEWSTACK:DW	0
	
	; DRIVE ALLOCATION VECTOR:
ALV:	 DS	1000			;SPACE FOR DOUBLE BIT ALLOCATION VECTORS
CSV:					;NO CHECKSUM VECTOR REQUIRED FOR A HDISK
	DB	'<-- END OF LDRBIOS  '	;For debugging
;
	END
