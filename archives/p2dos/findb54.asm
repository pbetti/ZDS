
	.Z80
	ASEG

;		    FINDBAD.ASM ver. 5.4
;		     (revised 05/21/81)
;
;	     NON-DESTRUCTIVE DISK TEST PROGRAM
;
;FINDBAD will find all bad blocks on a disk and build a file
;named [UNUSED].BAD to allocate them, thus "locking out" the
;bad blocks so CP/M will not use them.
;
;Originally written by Gene Cotton,  published in "Interface
;Age", September 1980 issue, page 80.
;
;See notes below concerning 'TEST' conditional assembly option,
;SYSTST and BADUSR directives.
;
;********************************************************
;*							*
;*			  NOTE				*
;*							*
;*   This program has been re-written to allow it to	*
;* work  with (hopefully)  all CP/M 2.x systems, and	*
;* most 1.4 CP/M systems. It has been tested on sev-	*
;* eral different disk systems, including Northstar,	*
;* Micropolis, DJ2D, and  Keith  Petersen's 10 MByte    *
;* hard disk system.  I have tested it personally on	*
;* my "modified" Northstar, under several  different	*
;* formats (including >16K per extent), and have ob-	*
;* no difficulties.					*
;*  If you have have difficulties getting this	pro-	*
;* gram  to run, AND if you  are using CP/M 2.x, AND	*
;* if  you  know  your CBIOS  to be  bug-free, leave	*
;* me a message on the CBBS mentioned below ... I am	*
;* interested in making this program  as "universal"	*
;* as possible. 					*
;*  I can't help with any version of CP/M 1.4, other    *
;* than  "standard" versions  (whatever that means),	*
;* because there are just too many heavily  modified	*
;* versions available.					*
;*  One  possible  problem you may  find is with the	*
;* system tracks of your diskettes...if they are  of	*
;* a  different density  than the data	tracks, then	*
;* see the note regarding the "SYSTST" equate.		*
;*							*
;*				Ron Fowler		*
;*				Westland, Mich		*
;*				7 April, 1981		*
;*							*
;********************************************************
;
;SYSTST and BADUSR options:
;  Many double-density disk systems have single-density system
;tracks.  If this is true with your system, you can change the
;program to skip the system tracks,  without re-assembling it.
;To do this, set the byte at 103H to a 0 if you don't want the
;system  tracks tested,  otherwise leave it 1.   This is  also
;necessary if you have a "blocked" disk system;  that is, when
;the same physical disk is seperated into logical disks by use
;of the SYSTRK word in the disk parameter block.
;   If you are a CP/M 2.x user, you may assign the user number
;where  [UNUSED.BAD] will be created by changing the  byte  at
;104H  to  the  desired user number.   If you want it  in  the
;default user,  then leave it 0FFH.  CP/M 1.4 users can ignore
;this byte altogether.
;
;Note that these changes can be done with DDT as follows:
;
;		A>DDT FINDBAD.COM
;		-S103
;		103 01 0	;DON'T TEST SYSTEM TRACKS
;		104 FF F	;PUT [UNUSED.BAD] IN USER 15
;		105 31 .	;DONE WITH CHANGES
;		-^C
;		A>SAVE XX FINDBAD.COM
;
;----------------------------------------------------------------
;NOTE: If you want to  update this program, make sure you have
;the latest version first.  After adding your changes, please
;modem a copy of the new file to "TECHNICAL CBBS" in Dearborn,
;Michigan - phone 313-846-6127 (110, 300, 450 or 600 baud).
;Use the filename FINDBAD.NEW.	 (KBP)
;
;Modifications/updates: (in reverse order to minimize reading time)
;
;05/21/81 Corrected error in description of how to set SYSTST
;	  byte at 103h.  Added CRLF to block error message. (KBP)
;
;05/19/81 Corrected omission in DOLOG routine so that BADUSR
;	  will work correctly. Thanks to Art Larky. (CHS)
;
;04/10/81 Changed extent DB from -1 to 0FFH so program can be
;	  assembled by ASM.  Added BADUSR info to instructions
;	  for altering with DDT.  (KBP)
;
;04/09/81 Changed sign-on message, added control-c abort test,
;	  added '*' to console once each track	(RGF)
;
;04/07/81 Re-wrote to add the following features:
;		1) "Universal" operation
;		2) DDT-changeable "SYSTRK" boolean (see above)
;		3) Report to console when bad blocks are detected
;		4) Changed the method of printing the number of
;		   bad blocks found (at end of run)...the old
;		   method used too much code, and was too cum-
;		   bersome.
;		5) Made several cosmetic changes
;
;			Ron Fowler
;			Westland, Mich
;
;03/23/81 Set equates to standard drive and not double-sided. (KBP)
;
;03/01/81 Corrected error for a Horizon with double sided drive.
;	  This uses 32k extents, which code did not take into account.
;	  (Bob Clyne)
;
;02/05/81 Merged 2/2/81 and 1/24/81 changes, which were done
;	  independently by Clyne and Mack.  (KBP)
;
;02/02/81 Added equates for North Star Horizon - 5.25" drives,
;	  double density, single and double sided. (Bob Clyne)
;
;01/24/81 Added equates for Jade DD disk controller
;	  (Pete H. Mack)
;
;01/19/81 Added equates for Icom Microfloppy 5.25" drives.
;	  (Eddie Currie)
;
;01/05/81 Added equates for Heath H-17 5.25" drives.
;	  (Ben Goldfarb)
;
;12/08/80 Added equates for National Multiplex D3S/D4S
;	  double-density board in various formats.
;	  (David Fiedler)
;
;09/22/80 Added equates for Morrow Disk Jockey 2D/SS, 256,
;	  512 and 1024-byte sector options.  Fix 'S2' update
;	  flag for larger max number of extents. Cleaned up
;	  file. (Ben Bronson and KBP)
;
;09/14/80 Corrected DGROUP equate for MMDBL. Added new routine
;	  to correct for IMDOS group allocation.  Corrected
;	  error in instructions for using TEST routine.
;	  (CHS) (AJ) (KBP) - (a group effort)
;
;09/08/80 Fixed several errors in Al Jewer's mods.  Changed
;	  return to CP/M to warm boot so bitmap in memory will
;	  be properly updated. Added conditional assembly for
;	  testing program. (KBP)
;
;09/02/80 Added IMDOS double-density equates & modified for
;	  more then 256 blocks per disk. (Al Jewer)
;
;09/01/80 Changed equates so that parameters are automatically
;	  set for each disk system conditional assembly (KBP)
;
;08/31/80 Add conditional assembly for Digital Microsystems FDC3
;	  controller board in double-density format and fix to
;	  do 256 blocks in one register. (Thomas V. Churbuck)
;
;08/31/80 Correct MAXB equate - MAXB must include the directory
;	  blocks as well as the data blocks.  Fix to make sure
;	  any [UNUSED].BAD file is erased before data area is
;	  checked. (KBP)
;
;08/30/80 Added conditional assembly for Micromation
;	  double-density format. (Charles H. Strom)
;
;08/27/80 Fix missing conditional assembly in FINDB routine.
;	  Put version number in sign-on message. (KBP)
;
;08/26/80 Modified by Keith Petersen, W8SDZ, to:
;	  (1) Add conditional assembly for 1k/2k groups
;	  (2) Add conditional assembly for standard drives
;	      and Micropolis MOD II
;	  (3) Make compatible with CP/M-2.x
;	  (4) Remove unneeded code to check for drive name
;	      (CP/M does it for you and returns it in the FCB)
;	  (5) Changed to open additional extents as needed for
;	      overflow, instead of additional files
;	  (6) Add conditional assembly for system tracks check
;	      (some double-density disks have single-density
;	      system tracks which cannot be read by this program)
;	  (7) Increased stack area (some systems use more than
;	      others).
;
;08/06/80 Added comments and crunched some code.
;	  KELLY SMITH.	805-527-9321 (Modem, 300 Baud)
;			805-527-0518 (Verbal)
;
;
;			Using the Program
;
; Before  using this program to "reclaim" a diskette,  it  is
;recommended that the diskette be reformatted. If this is not
;possible,  at least assure yourself that any existing	files
;on the diskette  do not contain unreadable  sectors.  If you
;have changed disks since the last warm-boot, you  must warm-
;boot again before running this program.
;
; To  use the program,	insert	both the disk containing  the
;program  FINDBAD.COM and the diskette to be checked into the
;disk drives. It is possible that the diskette containing the
;program is the one to be checked. Assume that the program is
;on drive "A" and the suspected bad disk is on drive "B".  In
;response to the CP/M prompt "A>",  type in FINDBAD B:.  This
;will  load the file FINDBAD.COM from drive "A" and test  the
;diskette  on  drive "B" for  unreadable  sectors.  The  only
;allowable  parameter  after  the  program name  is  a	drive
;specification	(of the form " N:") for up to four (A  to  D)
;disk drives.  If no drive is specified, the currently logged
;in drive is assumed to contain the diskette to check.
;
; The  program first checks the CP/M System tracks (0 and 1),
;and  any  errors here prohibit the disk from being  used  on
;drive	"A",  since all "warm  boots" occur using the  system
;tracks from the "A" drive.
;
; The  program next checks the first two data blocks  (groups
;to some of us) containing the directory of the diskette.  If
;errors  occur	here,  the  program  terminates  and  control
;returns  to  CP/M  (no other data blocks are  checked	since
;errors in the directory render the disk useless).
;
; Finally,  all  the remaining data blocks are	checked.  Any
;sectors  which  are  unreadable cause the data  block	which
;contains them to be stored temporarily as a "bad block".  At
;the end of this phase,  the message "XX bad blocks found" is
;displayed (where XX is replaced by the number of bad blocks,
;or "No" if no read errors occur).  If bad blocks occur,  the
;filname [UNUSED].BAD is created, the list of "bad blocks" is
;placed  in  the allocation map of the	directory  entry  for
;[UNUSED].BAD,	and the file is closed.  Note,	that when the
;number of "bad blocks" exceeds 16,  the  program  will  open
;additional  extents  as  required  to	hold the overflow.  I
;suggest that if the diskette has more than  32 "bad blocks",
;perhaps it should be sent to the "big disk drive in the sky"
;for the rest it deserves.
;
; The  nifty part of all this is that if any "bad blocks"  do
;occur, they are allocated to [UNUSED].BAD and no longer will
;be available to CP/M for future allocation...bad sectors are
;logically locked out on the diskette!
;
;
;	       Using the TEST conditional assembly
;
;A  conditional  assembly has been added to allow  testing  this
;program  to  make sure it is reading all sectors on  your  disk
;that  are accessible to CP/M.	The program reads the disk on  a
;block by block basis, so it is necessary to first determine the
;number of blocks present.  To start, we must know the number of
;sectors/block (8 sectors/block for standard IBM single  density
;format).  If  this  value  is	not  known,  it  can  easily  be
;determined  by saving one page in a test file and interrogating
;using the STAT command:
;
;	A>SAVE 1 TEST.SIZ
;	A>STAT TEST.SIZ
;
;For standard single-density STAT will report this file as being
;1k.  The file size reported (in bytes) is the size of a  block.
;This  value  divided  by 128 bytes/sector  (the  standard  CP/M
;sector  size)	will  give sectors/block.  For	our  IBM  single
;density example, we have:
;
;  (1024 bytes/block) / (128 bytes/sector) = 8 sectors/block.
;
;We  can now calculate blocks/track (assuming we know the number
;sectors/track). In our example:
;
;  (26 sectors/track) / (8 sectors/block) = 3.25 blocks/track
;
;Now  armed with the total number of data tracks (75 in our  IBM
;single density example), we get total blocks accessible:
;
;  75 (tracks/disk) x (3.25 blocks/track) = 243.75 blocks/disk
;
;CP/M cannot access a fractional block, so we round down (to 243
;blocks  in  our  example).  Now  multiplying  total  blocks  by
;sectors/block	results in total sectors as should  be	reported
;when TEST is set TRUE and a good disk is read. For our example,
;this value is 1944 sectors.
;
;Finally,  note that if SYSTST is set to 0,  the sectors present
;on  the  first  two tracks must be added in  as  well.  In  the
;previous  example,  this  results in  1944 + 52 = 1996  sectors
;reported by the TEST conditional.
;
;Run the program on a KNOWN-GOOD disk.	It should report that it
;has read  the	correct number of sectors.  The test conditional
;assembly should then be set FALSE and the program re-assembled.
;The test routines  cannot be left in  because this program does
;not read all the sectors in a block that is found to be bad and
;thus will report an inaccurate number of sectors read.
;
;
;Define TRUE and FALSE
;
FALSE	EQU	0
TRUE	EQU	NOT FALSE
;
;******************************************************************
;
;Conditional assembly switch for testing this program
;(for initial testing phase only - see remarks above)
;
TEST	EQU	FALSE		;TRUE FOR TESTING ONLY
;
;******************************************************************
;
;System equates
;
BASE	EQU	0		;STANDARD CP/M BASE ADDRESS (4200H FOR ALTCPM)
BDOS	EQU	BASE+5		;CP/M WARM BOOT ENTRY
FCB	EQU	BASE+5CH	;CP/M DEFAULT FCB LOCATION
;
;Define ASCII characters used
;
CR	EQU	0DH		;CARRIAGE RETURN CHARACTER
LF	EQU	0AH		;LINE FEED CHARACTER
TAB	EQU	09H		;TAB CHARACTER
;
DPBOFF	EQU	3AH		;CP/M 1.4 OFFSET TO DPB WITHIN BDOS
TRNOFF	EQU	15		;CP/M 1.4 OFFSET TO SECTOR XLATE ROUTINE
;
;
	ORG	BASE+100H
;
	JP	START		;JMP AROUND OPTION BYTES
;
;If you want the system tracks tested, then
;put a 1 here, otherwise 0.
;
SYSTST:	DEFB	1		;0 IF NO SYS TRACKS, OTHERWISE 1
;
;If you are a CP/M 2.x user, change this byte
;to the user number you want [UNUSED].BAD to
;reside in.  If you want it in the default
;user, then leave it 0FFH.  CP/M 1.4 users
;can ignore this byte altogether.
;
BADUSR:	DEFB	0FFH		;USER # WHERE [UNUSED.BAD] GOES
	;0FFH = DEFAULT USER
;
START:	LD	SP,NEWSTK	;MAKE NEW STACK
	CALL	START2		;GO PRINT SIGNON
	DEFB	CR,LF,'FINDBAD - ver 5.4'
	DEFB	CR,LF,'Bad sector lockout '
	DEFB	'program',CR,LF
	DEFB	'Universal version',CR,LF
	DEFB	CR,LF,'Type CTL-C to abort',CR,LF,'$'
;
START2:	POP	DE		;GET MSG ADRS
	LD	C,9		;BDOS PRINT BUFFER FUNCTION
	CALL	BDOS		;PRINT SIGN-ON MSG
	CALL	SETUP		;SET BIOS ENTRY, AND CHECK DRIVE
	CALL	ZMEM		;ZERO ALL AVAILABLE MEMORY
	CALL	FINDB		;ESTABLISH ALL BAD BLOCKS
	JP	Z,NOBAD		;SAY NO BAD BLOCKS, IF SO
	CALL	SETDM		;FIX DM BYTES IN FCB
;
NOBAD:	CALL	CRLF
	LD	A,TAB
	CALL	TYPE
	LD	DE,NOMSG	;POINT FIRST TO 'NO'
	LD	HL,(BADBKS)	;PICK UP # BAD BLOCKS
	LD	A,H		;CHECK FOR ZERO
	OR	L
	JP	Z,PMSG1		;JUMP IF NONE
	CALL	DECOUT		;OOPS..HAD SOME BAD ONES, REPORT
	JP	PMSG2
;
PMSG1:	LD	C,9		;BDOS PRINT BUFFER FUNCTION
	CALL	BDOS
;
PMSG2:	LD	DE,ENDMSG	;REST OF EXIT MESSAGE
;
PMSG:	LD	C,9
	CALL	BDOS
;
	IF	TEST
	LD	A,TAB		;GET A TAB
	CALL	TYPE		;PRINT IT
	LD	HL,(SECCNT)	;GET NUMBER OF SECTORS READ
	CALL	DECOUT		;PRINT IT
	LD	DE,SECMSG	;POINT TO MESSAGE
	LD	C,9		;BDOS PRINT BUFFER FUNCTION
	CALL	BDOS		;PRINT IT
	ENDIF			;TEST
;
	JP	BASE		;EXIT TO CP/M WARM BOOT
;
;Get actual address of BIOS routines
;
SETUP:	LD	HL,(BASE+1)	;GET BASE ADDRESS OF BIOS VECTORS
;
;WARNING...Program modification takes place here...do not change.
;
	LD	DE,24		;OFFSET TO "SETDSK"
	ADD	HL,DE
	LD	(SETDSK+1),HL	;FIX OUR CALL ADDRESS
	LD	DE,3		;OFFSET TO "SETTRK"
	ADD	HL,DE
	LD	(SETTRK+1),HL	;FIX OUR CALL ADDRESS
	LD	DE,3		;OFFSET TO "SETSEC"
	ADD	HL,DE
	LD	(SETSEC+1),HL	;FIX OUR CALL ADDRESS
	LD	DE,6		;OFFSET TO "DREAD"
	ADD	HL,DE
	LD	(DREAD+1),HL	;FIX OUR CALL ADDRESS
	LD	DE,9		;OFFSET TO CP/M 2.x SECTRAN
	ADD	HL,DE
	LD	(SECTRN+1),HL	;FIX OUR CALL ADDRESS
	LD	C,12		;GET VERSION FUNCTION
	CALL	BDOS
	LD	A,H		;SAVE AS FLAG
	OR	L
	LD	(VER2FL),A
	JP	NZ,GDRIV	;SKIP 1.4 STUFF IF IS 2.x
	LD	DE,TRNOFF	;CP/M 1.4 OFFSET TO SECTRAN
	LD	HL,(BDOS+1)	;SET UP JUMP TO 1.4 SECTRAN
	LD	L,0
	ADD	HL,DE
	LD	(SECTRN+1),HL
;
;Check for drive specification
;
GDRIV:	LD	A,(FCB)		;GET DRIVE NAME
	LD	C,A
	OR	A		;ZERO?
	JP	NZ,GD2		;IF NOT,THEN GO SPECIFY DRIVE
	LD	C,25		;GET LOGGED-IN DRIVE
	CALL	BDOS
	INC	A		;MAKE 1-RELATIVE
	LD	C,A
;
GD2:	LD	A,(VER2FL)	;IF CP/M VERSION 2.x
	OR	A
	JP	NZ,GD3		;  SELDSK WILL RETURN SEL ERR
;
;Is CP/M 1.4, which doesn't return a select
;error, so we have to do it here
;
	LD	A,C
	CP	4+1		;CHECK FOR HIGHEST DRIVE NUMBER
	JP	NC,SELERR	;SELECT ERROR
;
GD3:	DEC	C		;BACK OFF FOR CP/M
	PUSH	BC		;SAVE DISK SELECTION
	LD	E,C		;ALIGN FOR BDOS
	LD	C,14		;SELECT DISK FUNCTION
	CALL	BDOS
	POP	BC		;GET BACK DISK NUMBER
;
;EXPLANATION: WHY WE DO THE SAME THING TWICE
;
;	You might notice that we are
;	doing the disk selection twice,
;	once by a BDOS call and once by
;	direct BIOS call. The reason for this:
;
;	The BIOS call is necessary in order to
;	get the necessary pointer back from CP/M
;	(2.x) to find the sector translate table.
;	The BDOS call is necessary to keep CP/M
;	in step with the  BIOS...we may later
;	have to create a [UNUSED].BAD file, and
;	CP/M must know which drive we are using.
;			     (RGF)
;
SETDSK:	CALL	$-$		;DIRECT BIOS VEC FILLED IN AT INIT
	LD	A,(VER2FL)
	OR	A
	JP	Z,DOLOG		;JUMP IF CP/M 1.4
	LD	A,H
	OR	L		;CHECK FOR 2.x
	JP	Z,SELERR	;JUMP IF SELECT ERROR
	LD	E,(HL)		;GET SECTOR TABLE PNTR
	INC	HL
	LD	D,(HL)
	INC	HL
	EX	DE,HL
	LD	(SECTBL),HL	;STORE IT AWAY
	LD	HL,8		;OFFSET TO DPB POINTER
	ADD	HL,DE
	LD	A,(HL)		;PICK UP DPB POINTER
	INC	HL		;  TO USE
	LD	H,(HL)		;  AS PARAMETER
	LD	L,A		;  TO LOGIT
;
DOLOG:	CALL	LOGIT		;LOG IN DRIVE, GET DISK PARMS
	CALL	GETDIR		;CALCULATE DIRECTORY INFORMATION
;
;Now set the required user number
;
	LD	A,(VER2FL)
	OR	A
	RET	Z		;NO USERS IN CP/M 1.4
	LD	A,(BADUSR)	;GET THE USER NUMBER
	CP	0FFH		;IF IT IS 0FFH, THEN RETURN
	RET	Z
	LD	E,A		;BDOS CALL NEEDS USER # IN E
	LD	C,32		;GET/SET USER CODE
	CALL	BDOS
	RET
;
;Look for bad blocks
;
FINDB:	LD	A,(SYSTST)
	OR	A
	JP	Z,DODIR		;JUMP IF NO SYS TRACKS TO BE TESTED
	CALL	CHKSYS		;CHECK FOR BAD BLOCKS ON TRACK 0 AND 1
;
DODIR:	CALL	CHKDIR		;CHECK FOR BAD BLOCKS IN DIRECTORY
	CALL	TELL1
	DEFB	CR,LF,'Testing data area...',CR,LF,'$'
;
TELL1:	POP	DE
	LD	C,9		;BDOS PRINT STRING FUNCTION
	CALL	BDOS
	CALL	ERAB		;ERASE ANY [UNUSED].BAD FILE
	LD	HL,(DIRBKS)	;START AT FIRST DATA BLOCK
	LD	B,H		;PUT INTO BC
	LD	C,L
;
FINDBA:	CALL	READB		;READ THE BLOCK
	CALL	NZ,SETBD	;IF BAD, ADD BLOCK TO LIST
	INC	BC		;BUMP TO NEXT BLOCK
	LD	HL,(DSM)
	LD	D,B		;SET UP FOR (MAXGRP - CURGRP)
	LD	E,C
	CALL	SUBDE		;DO SUBTRACT: (MAXGRP - CURGRP)
	JP	NC,FINDBA	;UNTIL CURGRP>MAXGRP
	CALL	CRLF
	LD	HL,(DMCNT)	;GET NUMBER OF BAD SECTORS
	LD	A,H
	OR	L		;SET ZERO FLAG, IF NO BAD BLOCKS
	RET			;RETURN FROM "FINDB"
;
;Check system tracks, notify user if bad, but continue
;
CHKSYS:	CALL	CHSY1		;PRINT MESSAGE
	DEFB	CR,LF,'Testing system tracks...',CR,LF,'$'
;
CHSY1:	POP	DE
	LD	C,9		;PRINT STRING FUNCTION
	CALL	BDOS
	LD	HL,0		;SET TRACK 0, SECTOR 1
	LD	(TRACK),HL
	INC	HL
	LD	(SECTOR),HL
;
CHKSY1:	CALL	READS		;READ A SECTOR
	JP	NZ,SYSERR	;NOTIFY, IF BAD BLOCKS HERE
	LD	HL,(SYSTRK)	;SET UP (TRACK-SYSTRK)
	EX	DE,HL
	LD	HL,(TRACK)
	CALL	SUBDE		;DO THE SUBTRACT
	JP	C,CHKSY1	;LOOP WHILE TRACK < SYSTRK
	RET			;RETURN FROM "CHKSYS"
;
SYSERR:	LD	DE,ERMSG5	;SAY NO GO, AND BAIL OUT
	LD	C,9		;BDOS PRINT BUFFER FUNCTION
	CALL	BDOS
	RET			;RETURN FROM "SYSERR"
;
;Check for bad blocks in directory area
;
CHKDIR:	CALL	CHKD1
	DEFB	CR,LF,'Testing directory area...',CR,LF,'$'
;
CHKD1:	POP	DE
	LD	C,9		;BDOS PRINT STRING FUNCTION
	CALL	BDOS
	LD	BC,0		;START AT BLOCK 0
;
CHKDI1:	CALL	READB		;READ A BLOCK
	JP	NZ,ERROR6	;IF BAD, INDICATE ERROR IN DIRECTORY AREA
	INC	BC		;BUMP FOR NEXT BLOCK
	LD	HL,(DIRBKS)	;SET UP (CURGRP - DIRBKS)
	DEC	HL		;MAKE 0-RELATIVE
	LD	D,B
	LD	E,C
	CALL	SUBDE		;DO THE SUBTRACT
	JP	NC,CHKDI1	;LOOP UNTIL CURGRP > DIRGRP
	RET			;RETURN FROM "CHKDIR"
;
;Read all sectors in block, and return zero flag set if none bad
;
READB:	CALL	CNVRTB		;CONVERT TO TRACK/SECTOR IN H&L REGS.
	LD	A,(BLM)
	INC	A		;NUMBER OF SECTORS/BLOCK
	LD	D,A		;  IN D REG
;
READBA:	PUSH	DE
	CALL	READS		;READ SKEWED SECTOR
	POP	DE
	RET	NZ		;ERROR IF NOT ZERO...
	DEC	D		;DEBUMP SECTOR/BLOCK
	JP	NZ,READBA	;DO NEXT, IF NOT FINISHED
	RET			;RETURN FROM "READBA"
;
;Convert block number to track and skewed sector number
;
CNVRTB:	PUSH	BC		;SAVE CURRENT GROUP
	LD	H,B		;NEED IT IN HL
	LD	L,C		; FOR EASY SHIFTING
	LD	A,(BSH)		;DPB VALUE THAT TELLS HOW TO
;
SHIFT:	ADD	HL,HL		;  SHIFT GROUP NUMBER TO GET
	DEC	A		;  DISK-DATA-AREA RELATIVE
	JP	NZ,SHIFT	;  SECTOR NUMBER
	EX	DE,HL		;REL SECTOR # INTO DE
	LD	HL,(SPT)	;SECTORS PER TRACK FROM DPB
	CALL	RNEG		;FASTER TO DAD THAN CALL SUBDE
	EX	DE,HL
	LD	BC,0		;INITIALIZE QUOTIENT
;
;Divide by number of sectors
;	quotient = track
;	     mod = sector
;
DIVLP:	INC	BC		;DIRTY DIVISION
	ADD	HL,DE
	JP	C,DIVLP
	DEC	BC		;FIXUP LAST
	EX	DE,HL
	LD	HL,(SPT)
	ADD	HL,DE
	INC	HL
	LD	(SECTOR),HL	;NOW HAVE LOGICAL SECTOR
	LD	HL,(SYSTRK)	;BUT BEFORE WE HAVE TRACK #,
	ADD	HL,BC		;  WE HAVE TO ADD SYS TRACK OFFSET
	LD	(TRACK),HL
	POP	BC		;THIS WAS OUR GROUP NUMBER
	RET
;
;READS reads a logical sector (if it can)
;and returns zero flag set if no error.
;
READS:	PUSH	BC		;SAVE THE GROUP NUMBER
	CALL	LTOP		;CONVERT LOGICAL TO PHYSICAL
	LD	A,(VER2FL)	;NOW CHECK VERSION
	OR	A
	JP	Z,NOTCP2	;SKIP THIS STUFF IF CP/M 1.4
	LD	HL,(PHYSEC)	;GET PHYSICAL SECTOR
	LD	B,H		;INTO BC
	LD	C,L
;
SETSEC:	CALL	$-$		;ADDRS FILLED IN AT INIT
;
;QUICK NOTE OF EXPLANATION: This code appears
;as if we skipped the SETSEC routine for 1.4
;CP/M users.  That's not true; in CP/M 1.4, the
;call within the LTOP routine to SECTRAN  ac-
;tually does the set sector, so no need to do
;it twice.      (RGF)
;
NOTCP2:	LD	HL,(TRACK)	;NOW SET THE TRACK
	LD	B,H		;CP/M WANTS IT IN BC
	LD	C,L
;
SETTRK:	CALL	$-$		;ADDRS FILLED IN AT INIT
;
;Now do the sector read
;
DREAD:	CALL	$-$		;ADDRS FILLED IN AT INIT
	OR	A		;SET FLAGS
	PUSH	AF		;SAVE ERROR FLAG
;
	IF	TEST
	LD	HL,(SECCNT)	;GET SECTOR COUNT
	INC	HL		;ADD ONE
	LD	(SECCNT),HL	;SAVE NEW COUNT
	ENDIF			;TEST
;
	LD	HL,(SECTOR)	;GET LOGICAL SECTOR #
	INC	HL		;WE WANT TO INCREMENT TO NEXT
	EX	DE,HL		;BUT FIRST...CHECK OVERFLOW
	LD	HL,(SPT)	;  BY DOING (SECPERTRK-SECTOR)
	CALL	SUBDE		;DO THE SUBTRACTION
	EX	DE,HL
	JP	NC,NOOVF	;JUMP IF NOT SECTOR>SECPERTRK
;
;Sector overflow...bump track number, reset sector
;
	LD	HL,(TRACK)
	INC	HL
	LD	(TRACK),HL
	LD	A,'*'		;TELL CONSOLE ANOTHER TRACK DONE
	CALL	TYPE
	CALL	STOP		;SEE IF CONSOLE WANTS TO QUIT
	LD	HL,1		;NEW SECTOR NUMBER ON NEXT TRACK
;
NOOVF:	LD	(SECTOR),HL	;PUT SECTOR AWAY
	POP	AF		;GET BACK ERROR FLAGS
	POP	BC		;RESTORE GROUP NUMBER
	RET
;
;Convert logical sector # to physical
;
LTOP:	LD	HL,(SECTBL)	;SET UP PARAMETERS
	EX	DE,HL		;  FOR CALL TO SECTRAN
	LD	HL,(SECTOR)
	LD	B,H
	LD	C,L
	DEC	BC		;ALWAYS CALL SECTRAN W/ZERO-REL SEC #
;
SECT1:	CALL	SECTRN		;DO THE SECTOR TRANSLATION
	LD	A,(SPT+1)	;CHECK IF BIG TRACKS
	OR	A		;SET FLAGS (TRACKS > 256 SECTORS)
	JP	NZ,LTOP1	;NO SO SKIP
	LD	H,A		;ZERO OUT UPPER 8 BITS
;
LTOP1:	LD	(PHYSEC),HL	;PUT AWAY PHYSICAL SECTOR
	RET
;
;Sector translation vector
;
SECTRN:	JP	$-$		;FILLED IN AT INIT
;
;Put bad block in bad block list
;
SETBD:	PUSH	BC
	CALL	SETBD1
	DEFB	CR,LF,'Bad block: $'
;
SETBD1:	POP	DE		;RETRIEVE ARG
	LD	C,9		;PRINT STRING
	CALL	BDOS
	POP	BC		;GET BACK BLOCK NUMBER
	LD	A,B
	CALL	HEXO		;PRINT IN HEX
	LD	A,C
	CALL	HEXO
	CALL	CRLF
	LD	HL,(DMCNT)	;GET NUMBER OF SECTORS
	LD	A,(BLM)		;GET BLOCK SHIFT VALUE
	INC	A		;MAKES SECTOR/GROUP VALUE
	LD	E,A		;WE WANT 16 BITS
	LD	D,0
	ADD	HL,DE		;BUMP BY NUMBER IN THIS BLOCK
	LD	(DMCNT),HL	;UPDATE NUMBER OF SECTORS
	LD	HL,(BADBKS)	;INCREMENT NUMBER OF BAD BLOCKS
	INC	HL
	LD	(BADBKS),HL
	LD	HL,(DMPTR)	;GET POINTER INTO DM
	LD	(HL),C		;...AND PUT BAD BLOCK NUMBER
	INC	HL		;BUMP TO NEXT AVAILABLE EXTENT
	LD	A,(DSM+1)	;CHECK IF 8 OR 16 BIT BLOCK SIZE
	OR	A
	JP	Z,SMGRP		;JUMP IF 8 BIT BLOCKS
	LD	(HL),B		;ELSE STORE HI BYTE OF BLOCK #
	INC	HL		;AND BUMP POINTER
;
SMGRP:	LD	(DMPTR),HL	;SAVE DM POINTER, FOR NEXT TIME THROUGH HERE
	RET			;RETURN FROM "SETBD"
;
;Eliminate any previous [UNUSED].BAD entries
;
ERAB:	LD	DE,BFCB		;POINT TO BAD FCB
	LD	C,19		;BDOS DELETE FILE FUNCTION
	CALL	BDOS
	RET
;
;Create [UNUSED].BAD file entry
;
OPENB:	LD	DE,BFCB		;POINT TO BAD FCB
	LD	C,22		;BDOS MAKE FILE FUNCTION
	CALL	BDOS
	CP	0FFH		;CHECK FOR OPEN ERROR
	RET	NZ		;RETURN FROM "OPENB", IF NO ERROR
	JP	ERROR7		;BAIL OUT...CAN'T CREATE [UNUSED].BAD
;
CLOSEB:	XOR	A
	LD	A,(BFCB+14)	;GET CP/M 2.x 'S2' BYTE
	AND	1FH		;ZERO UPDATE FLAGS
	LD	(BFCB+14),A	;RESTORE IT TO OUR FCB (WON'T HURT 1.4)
	LD	DE,BFCB		;FCB FOR [UNUSED].BAD
	LD	C,16		;BDOS CLOSE FILE FUNCTION
	CALL	BDOS
	RET			;RETURN FROM "CLOSEB"
;
;Move bad area DM to BFCB
;
SETDM:	LD	HL,DM		;GET DM
	LD	(DMPTR),HL	;SAVE AS NEW POINTER
	LD	A,(EXM)		;GET THE EXTENT SHIFT FACTOR
	LD	C,0		;INIT BIT COUNT
	CALL	COLECT		;GET SHIFT VALUE
	LD	HL,128		;STARTING EXTENT SIZE
	LD	A,C		;FIRST SEE IF ANY SHIFTS TO DO
	OR	A
	JP	Z,NOSHFT	;JUMP IF NONE
;
ESHFT:	ADD	HL,HL		;SHIFT
	DEC	A		;BUMP
	JP	NZ,ESHFT	;LOOP
;
NOSHFT:	PUSH	HL		;SAVE THIS, IT IS RECORDS PER EXTENT
	LD	A,(BSH)		;GET BLOCK SHIFT
	LD	B,A
;
BSHFT:	CALL	ROTRHL		;SHIFT RIGHT
	DEC	B
	JP	NZ,BSHFT	;TO GET BLOCKS PER EXTENT
	LD	A,L		;IT'S IN L (CAN'T BE >16)
	LD	(BLKEXT),A	;SETDME WILL NEED THIS LATER
	POP	HL		;GET BACK REC/EXT
;
SET1:	EX	DE,HL		;NOW HAVE REC/EXTENT IN DE
	LD	HL,(DMCNT)	;COUNT OF BAD SECTORS
;
SETDMO:	PUSH	HL		;SET FLAGS ON (DMCNT-BADCNT)
	CALL	SUBDE		;HAVE TO SUBTRACT FIRST
	LD	B,H		;SAVE RESULT IN BC
	LD	C,L
	POP	HL		;THIS POP MAKES IT COMPARE ONLY
	JP	C,SETDME	;JUMP IF LESS THAN 1 EXTENT WORTH
	LD	A,B
	OR	C		;TEST IF SUBTRACT WAS 0
	JP	Z,EVENEX	;EXTENT IS EXACTLY FILLED (SPL CASE)
	LD	H,B		;RESTORE RESULT TO HL
	LD	L,C
	PUSH	HL		;SAVE TOTAL
	PUSH	DE		;AND SECTORS/EXTENT
	EX	DE,HL
	CALL	SETDME		;PUT AWAY ONE EXTENT
	EX	DE,HL
	LD	(DMPTR),HL	;PUT BACK NEW DM POINTER
	POP	DE		;GET BACK SECTORS/EXTENT
	POP	HL		;AND COUNT OF BAD SECTORS
	JP	SETDMO		;AND LOOP
;
;Handle the special case of a file that ends on an extent
;boundary.  CP/M requires that such a file have a succeeding
;empty extent in order for the BDOS to properly access the file.
;
EVENEX:	EX	DE,HL		;FIRST SET EXTENT W/BAD BLOCKS
	CALL	SETDME
	EX	DE,HL
	LD	(DMPTR),HL
	LD	HL,0		;NOW SET ONE WITH NO DATA BLOCKS
;
;Fill in an extent's worth of bad sectors/block numbers.
;Also fill in the extent number in the FCB.
;
SETDME:	PUSH	HL		;SAVE RECORD COUNT
	LD	A,(EXTNUM)	;UPDATE EXTENT BYTE
	INC	A
	LD	(EXTNUM),A	;SAVE FOR LATER
	LD	(BFCB+12),A	; AND PUT IN FCB
	CALL	OPENB		;OPEN THIS EXTENT
	POP	HL		;RETRIEVE REC COUNT
;
;Divide record count by 128 to get the number
;of logical extents to put in the EX field
;
	LD	B,0		;INIT QUOTIENT
	LD	DE,-128		;-DIVISOR
	LD	A,H		;TEST FOR SPL CASE
	OR	L		;  OF NO RECORDS
	JP	Z,SKIP
;
DIVLOP:	ADD	HL,DE		;SUBTRACT
	INC	B		;BUMP QUOTIENT
	JP	C,DIVLOP
	LD	DE,128		;FIX UP OVERSHOOT
	ADD	HL,DE
	DEC	B
	LD	A,H		;TEST FOR WRAPAROUND
	OR	L
	JP	NZ,SKIP
	LD	L,80H		;RECORD LENGTH
	DEC	B
;
SKIP:	LD	A,(EXTNUM)	;NOW FIX UP EXTENT NUM
	ADD	A,B
	LD	(EXTNUM),A
	LD	(BFCB+12),A
	LD	A,L		;MOD IS RECORD COUNT
	LD	(BFCB+15),A	;THAT GOES IN RC BYTE
;
MOVDM:	LD	A,(BLKEXT)	;GET BLOCKS PER EXTENT
	LD	B,A		;INTO B
;
SETD1:	LD	HL,(DMPTR)	;POINT TO BAD ALLOCATION MAP
	EX	DE,HL
	LD	HL,BFCB+16	;DISK ALLOC MAP IN FCB
;
SETDML:	LD	A,(DE)
	LD	(HL),A
	INC	HL
	INC	DE
;
;Now see if 16 bit groups...if so,
;we have to move another byte
;
	LD	A,(DSM+1)	;THIS TELLS US
	OR	A
	JP	Z,BUMP1		;IF ZERO, THEN NOT
	LD	A,(DE)		;IS 16 BITS, SO DO ANOTHER
	LD	(HL),A
	INC	HL
	INC	DE
;
BUMP1:	DEC	B		;COUNT DOWN
	JP	NZ,SETDML
	PUSH	DE
	CALL	CLOSEB		;CLOSE THIS EXTENT
	POP	DE
	RET
;
;Error messages
;
SELERR:	LD	DE,SELEMS	;SAY NO GO, AND BAIL OUT
	JP	PMSG
;
SELEMS:	DEFB	CR,LF,'Drive specifier out of range$'
;
ERMSG5:	DEFB	CR,LF,'+++ Warning...System tracks'
	DEFB	' bad +++',CR,LF,CR,LF,'$'
;
ERROR6:	LD	DE,ERMSG6	;OOPS...CLOBBERED DIRECTORY
	JP	PMSG
;
ERMSG6:	DEFB	CR,LF,'Bad directory area, try reformatting$'
;
ERROR7:	LD	DE,ERMSG7	;SAY NO GO, AND BAIL OUT
	JP	PMSG
;
ERMSG7:	DEFB	CR,LF,'Can''t create [UNUSED].BAD$'
;
;
;==== SUBROUTINES ====
;
;Decimal output routine
;
DECOUT:	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	BC,-10
	LD	DE,-1
;
DECOU2:	ADD	HL,BC
	INC	DE
	JP	C,DECOU2
	LD	BC,10
	ADD	HL,BC
	EX	DE,HL
	LD	A,H
	OR	L
	CALL	NZ,DECOUT
	LD	A,E
	ADD	A,'0'
	CALL	TYPE
	POP	HL
	POP	DE
	POP	BC
	RET
;
;Carriage-return/line-feed to console
;
CRLF:	LD	A,CR
	CALL	TYPE
	LD	A,LF		;FALL INTO 'TYPE'
;
TYPE:	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	E,A		;CHARACTER TO E FOR CP/M
	LD	C,2		;PRINT CONSOLE FUNCTION
	CALL	BDOS		;PRINT CHARACTER
	POP	HL
	POP	DE
	POP	BC
	RET
;
;Subroutine to test console for control-c abort
;
STOP:	LD	HL,(1)		;FIND BIOS IN MEMORY
	LD	L,6		;OFFSET TO CONSOLE STATUS
	CALL	GOHL		;THANKS TO BRUCE RATOFF FOR THIS TRICK
	OR	A		;TEST FLAGS ON ZERO
	RET	Z		;RETURN IF NO CHAR
	LD	HL,(1)		;NOW FIND CONSOLE INPUT
	LD	L,9		;OFFSET FOR CONIN
	CALL	GOHL
	CP	'C'-40H		;IS IT CONTROL-C?
	RET	NZ		;RETURN IF NOT
	LD	DE,ABORTM	;EXIT WITH MESSAGE
	LD	C,9		;PRINT MESSAGE FUNCTION
	CALL	BDOS		;SAY GOODBYE
	JP	0		;THEN LEAVE
;
ABORTM:	DEFB	CR,LF
	DEFB	'Test aborted by control-C'
	DEFB	CR,LF,'$'
;
;A thing to allow a call to @HL
;
GOHL:	JP	(HL)
;
;Zero all of memory to hold DM values
;
ZMEM:	LD	HL,(BDOS+1)	;GET TOP-OF-MEM POINTER
	LD	DE,DM		;STARTING POINT
	CALL	SUBDE		;GET NUMBER OF BYTES
	LD	B,H
	LD	C,L
	EX	DE,HL		;BEGIN IN HL, COUNT IN BC
;
ZLOOP:	LD	(HL),0		;ZERO A BYTE
	INC	HL		;POINT PAST
	DEC	BC		;COUNT DOWN
	LD	A,B
	OR	C
	JP	NZ,ZLOOP
	RET
;
;Subtract DE from HL
;
SUBDE:	LD	A,L
	SUB	E
	LD	L,A
	LD	A,H
	SBC	A,D
	LD	H,A
	RET
;
;Negate HL
;
RNEG:	LD	A,L
	CPL
	LD	L,A
	LD	A,H
	CPL
	LD	H,A
	INC	HL
	RET
;
;Move from (HL) to (DE)
;Count in BC
;
MOVE:	LD	A,(HL)
	LD	(DE),A
	INC	HL
	INC	DE
	DEC	B
	JP	NZ,MOVE
	RET
;
;Print byte in accumulator in hex
;
HEXO:	PUSH	AF		;SAVE FOR SECOND HALF
	RRCA			;MOVE INTO POSITION
	RRCA
	RRCA
	RRCA
	CALL	NYBBLE		;PRINT MS NYBBLE
	POP	AF
;
NYBBLE:	AND	0FH		;LO NYBBLE ONLY
	ADD	A,90H
	DAA
	ADC	A,40H
	DAA
	JP	TYPE		;PRINT IN HEX
;
;Subroutine to determine the number
;of groups reserved for the directory
;
GETDIR:	LD	C,0		;INIT BIT COUNT
	LD	A,(AL0)		;READ DIR GRP BITS
	CALL	COLECT		;COLLECT COUNT OF DIR GRPS..
	LD	A,(AL1)		;..IN REGISTER C
	CALL	COLECT
	LD	L,C
	LD	H,0		;BC NOW HAS A DEFAULT START GRP #
	LD	(DIRBKS),HL	;SAVE FOR LATER
	RET
;
;Collect the number of '1' bits in A as a count in C
;
COLECT:	LD	B,8
;
COLOP:	RLA
	JP	NC,COSKIP
	INC	C
;
COSKIP:	DEC	B
	JP	NZ,COLOP
	RET
;
;Shift HL right one place
;
ROTRHL:	OR	A		;CLEAR CARRY
	LD	A,H		;GET HI BYTE
	RRA			;SHIFT RIGHT
	LD	H,A		;PUT BACK
	LD	A,L		;GET LO
	RRA			;SHIFT WITH CARRY
	LD	L,A		;PUT BACK
	RET
;
;Routine to fill in disk parameters
;
LOGIT:	LD	A,(VER2FL)
	OR	A		;IF NOT CP/M 2.x THEN
	JP	Z,LOG14		;	DO IT AS 1.4
	LD	DE,DPB		;   THEN MOVE TO LOCAL
	LD	B,DPBLEN	;  WORKSPACE
	CALL	MOVE
	RET
;
LOG14:	LD	HL,(BDOS+1)	;FIRST FIND 1.4 BDOS
	LD	L,0
	LD	DE,DPBOFF	;THEN OFFSET TO 1.4'S DPB
	ADD	HL,DE
	LD	D,0		;SO 8 BIT PARMS WILL BE 16
	LD	E,(HL)		;NOW MOVE PARMS
	INC	HL		; DOWN FROM BDOS DISK PARM BLOCK
	EX	DE,HL		; TO OURS
	LD	(SPT),HL
	EX	DE,HL
	LD	E,(HL)
	INC	HL
	EX	DE,HL
	LD	(DRM),HL
	EX	DE,HL
	LD	A,(HL)
	INC	HL
	LD	(BSH),A
	LD	A,(HL)
	INC	HL
	LD	(BLM),A
	LD	E,(HL)
	INC	HL
	EX	DE,HL
	LD	(DSM),HL
	EX	DE,HL
	LD	E,(HL)
	INC	HL
	EX	DE,HL
	LD	(AL0),HL
	EX	DE,HL
	LD	E,(HL)
	EX	DE,HL
	LD	(SYSTRK),HL
	RET
;
;--------------------------------------------------
;The disk parameter block
;is moved here from CP/M
;
DPB	EQU	$		;DISK PARAMETER BLOCK (COPY)
;
SPT:	DEFS	2		;SECTORS PER TRACK
BSH:	DEFS	1		;BLOCK SHIFT
BLM:	DEFS	1		;BLOCK MASK
EXM:	DEFS	1		;EXTENT MASK
DSM:	DEFS	2		;MAXIMUM BLOCK NUMBER
DRM:	DEFS	2		;MAXIMUM DIRECTORY BLOCK NUMBER
AL0:	DEFS	1		;DIRECTORY ALLOCATION VECTOR
AL1:	DEFS	1		;DIRECTORY ALLOCATION VECTOR
CKS:	DEFS	2		;CHECKED DIRECTORY ENTRIES
SYSTRK:	DEFS	2		;SYSTEM TRACKS
;
;End of disk parameter block
;
DPBLEN	EQU	$-DPB		;LENGTH OF DISK PARM BLOCK
;
;--------------------------------------------------
BLKEXT:	DEFB	0		;BLOCKS PER EXTENT
DIRBKS:	DEFW	0		;CALCULATED # OF DIR BLOCKS
VER2FL:	DEFB	0		;VERSION 2.X FLAG
;
BFCB:	DEFB	0,'[UNUSED]BAD',0,0,0,0
FCBDM:	DEFS	17
;
NOMSG:	DEFB	'No$'
ENDMSG:	DEFB	' bad blocks found',CR,LF,'$'
;
BADBKS:	DEFW	0		;COUNT OF BAD BLOCKS
SECTOR:	DEFW	0		;CURRENT SECTOR NUMBER
TRACK:	DEFW	0		;CURRENT TRACK NUMBER
PHYSEC:	DEFW	0		;CURRENT PHYSICAL SECTOR NUMBER
SECTBL:	DEFW	0		;SECTOR SKEW TABLE POINTER
;
EXTNUM:	DEFB	0FFH		;USED FOR UPDATING EXTENT NUMBER
DMCNT:	DEFW	0		;NUMBER OF BAD SECTORS
DMPTR:	DEFW	DM		;POINTER TO NEXT BLOCK ID
;
SECMSG:	DEFB	' total sectors read',CR,LF,'$'
;
SECCNT:	DEFW	0		;NUMBER OF SECTORS READ
;
	DEFS	64		;ROOM FOR 32 LEVEL STACK
NEWSTK	EQU	$		;OUR STACK
DM	EQU	$		;BAD BLOCK ALLOCATION MAP
;
	END
