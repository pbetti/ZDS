	TITLE	"INITDIR - Initialize disk directory for P2DOS Stamps"
;===========================================================================;
; I N I T D I R								    ;
;---------------------------------------------------------------------------;
; Copyright (C) 1988  by Harold F. Bower				    ;
;---------------------------------------------------------------------------;
; Derived from 2 Oct 86 Disassembly of INITDIR.COM provided with P2DOS	    ;
;									    ;
; Revision:								    ;
;  1.2 - 11 Apr 93 - Modified Header for ZCNFG24 configurability.	HFB ;
;  1.1 -  7 Mar 89 - Added "Quiet" mode with ZCNFG configurability.	HFB ;
;  1.0 - 16 Sep 88 - Release Version					HFB ;
;===========================================================================;

	include darkstar.equ

VERS	EQU	12		; Current version
DATE	  MACRO
	DEFB	'  12 Apr 93'
	  ENDM

BASE	EQU	0000H		; Base address of CP/M system
BDOS	EQU	0005H		; Bdos Call entry point
FCB	EQU	005CH		; Default CP/M File Control Block
BUFF	EQU	0080H		; Default CP/M buffer location

SECSIZ	EQU	128		; Logical sector size
IDLEN	EQU	32		; Length of Directory entry

BELL	EQU	07H
BS	EQU	08H
TAB	EQU	09H
LF	EQU	0AH
CR	EQU	0DH

	.Z80
	CSEG

ENTER:	JP	START		; Jump to execution

	DEFB	'Z3ENV'		; Dummy header, not used
	DEFB	1
Z3EADR:	DEFW	0001H
	DEFW	ENTER		; ..filler to Name field

	DEFB	'INITDIR ',0	; Program name for ZCNFG
				; Configuration file is INITDIR.CFG

QUIET:	DEFB	0FFH		; 0=Verbose, FF=Quiet

START:	LD	(STACK),SP	; Save SP and set new stack
	LD	SP,STACK
	LD	DE,PROMPT	; Print opening banner
	CALL	WRTLIN
	LD	C,25		; Get current logged drive
	CALL	BDOS
	LD	(DEFDRV),A	; Save entry drive
	LD	HL,BUFF		; See if anything was entered
	LD	B,(HL)		; Get char count to B
	INC	B		; ..Precompensate for following dec
LOOP1:	DEC	B		; Are we out of chars in input?
	JR	Z,INTACT	; ..jump to interactive if so
	INC	HL		; Advance to first char in args
	LD	A,(HL)
	CP	'/'		; Do we have Help request?
	JP	Z,HELP		; ..jump if so
	CP	' '		; Is it a Space?
	JR	Z,LOOP1		; ..jump to check next char if so
	CP	TAB		; Is it a Tab char?
	JR	Z,LOOP1		; ..jump to check next char if so

	LD	(EXPERT),A	; We have a character, save as flag
	CP	'A'		; Check for legal drive
	JR	C,NGVCT		; ..Go error if Bad drive
	CP	'P'+1
	JR	C,OKDRV		; We have a valid drive letter, proceed
NGVCT:
	JP	NOGOOD		; ..else go to bad drive error exit

INTACL:	LD	SP,STACK	; Reset the stack for next pass
	LD	DE,MESG1	; See if another drive is desired
	CALL	WRTLIN
	LD	DE,DPROM1	; Print the Y/N part of prompt
	CALL	WRTLIN
	CALL	GETCH		; Get user response
	CP	'Y'		; Is it a "Y"?
	JP	NZ,EXIT0	; ..jump to exit if Not
			;..else fall thru to do again..
	CALL	RSELEC		; Begin by resynchronizing drives
	CALL	CRLF		; ..and clearing some space

INTACT:	XOR	A		; Show that we are in Interactive mode
	LD	(EXPERT),A	; ..by clearing flag
	LD	HL,DRVNUM	; Clear variables for next pass
	LD	B,STACK-DRVNUM	; ..for this many bytes
CLRL:	LD	(HL),A
	INC	HL
	DJNZ	CLRL		; ..loop thru til done
GETDRV:	LD	DE,MESG0	; Ask user for drive letter
	CALL	WRTLIN
	CALL	GETCH		; ..and get letter in Uppercase
	CP	'A'		; Check for legal drive letter
	JR	C,NODRV		; ..jump if < A
	CP	'P'+1
	JR	C,OKDRV		; ..jump if Not > P
NODRV:	LD	DE,MESG2	; Else Beep and erase the entry
	CALL	WRTLIN
	JR	GETDRV		; ..and loop til valid

OKDRV:	LD	(DRVNUM),A	; Save drive letter
	LD	A,(QUIET)	; Proceed w/o Confirmation prompt?
	OR	A
	JR	NZ,OKDRV0	; ..jump if so
	LD	DE,DPROMP	; Ask user to confirm drive
	CALL	WRTLIN
	LD	A,(DRVNUM)	; ..followed by the drive
	LD	E,A
	LD	C,2
	CALL	BDOS
	LD	DE,DPROM0	; Then print the end of the prompt
	CALL	GETACT		; ..and get user response

OKDRV0:	LD	A,(DRVNUM)	; Get the drive letter
	SUB	'A'		; ..and make binary
	PUSH	AF		; Save drive for later
	LD	E,A
	CALL	LOGDOS		; Log onto the requested drive
	LD	E,0
	LD	C,32		; Log into User 0
	CALL	BDOS
	LD	HL,TDFCB	; Initialize the FCB in case re-executing
	XOR	A		; Use Null value
	LD	(HL),A		; Set to current drive
	LD	DE,12		; Offset to EX
	ADD	HL,DE
	LD	B,24		; Need 24 nulls here
INITL:	LD	(HL),A
	INC	HL
	DJNZ	INITL		; ..loop til all done
	LD	DE,TDFCB
	LD	C,17		; Is there a !!!TIME&.DAT file?
	CALL	BDOS
	INC	A		; Was it found?
	LD	DE,EXMSG	; We found a time file, prompt for activity
	CALL	NZ,GETACT	; ..go here if found and abort if not "Y"

	POP	AF		; Get the drive back, and continue
	LD	C,A
	CALL	BSELDK		; Select the drive
	LD	A,H		; DPH address returned in HL
	OR	L
	JP	Z,NOGOOD	; ..exit if can't log on
	LD	E,(HL)		; Get skew table address in DE
	INC	HL
	LD	D,(HL)
	LD	(SKWTBL),DE	; ..and save
	LD	DE,9
	ADD	HL,DE		; Offset to DPB address
	LD	E,(HL)		; ..and get it
	INC	HL
	LD	D,(HL)
	PUSH	DE
	POP	IX		; IX now points to DPB
	LD	HL,RAMBUF
	LD	D,(IX+08H)	; DIRMAX-1 to DE
	LD	E,(IX+07H)
	INC	DE		; make = DIRMAX
	LD	(DIRMAX),DE	; ..and save
	SRL	D		; Find # logical sctrs in directory
	RR	E
	SRL	D
	RR	E
	LD	(NDIRSC),DE	; ..and save
	LD	BC,0

; Enter: BC = Logical sector number
;	 DE = Number of directory sectors
;	 HL = Buffer address

	LD	A,(QUIET)	; Do it quietly?
	OR	A
	JR	NZ,LODDIR	; ..jump if so
	PUSH	HL		; Save the registers
	PUSH	DE
	PUSH	BC
	LD	DE,TMSG1	; Tell the user we are Reading
	CALL	WRTLIN
	POP	BC
	POP	DE
	POP	HL

LODDIR:	CALL	RDBLOK		; Read a block of data
	PUSH	DE
	LD	DE,SECSIZ
	ADD	HL,DE		; Increment DMA address
	POP	DE
	INC	BC		; Increment logical sector #
	EX	DE,HL
	OR	A
	SBC	HL,BC		; See if we have read all
	ADD	HL,BC
	EX	DE,HL
	JR	NZ,LODDIR	; ..loop until all directory read
	LD	A,(RAMBUF+96)
	CP	'!'		; Check for Time/Date marker
	JR	NZ,INITIL	; ..jump if not set
	LD	DE,ALREDY
	JP	ABORT		; ..else exit with error message

INITIL:	LD	HL,RAMBUF	; Count valid filenames in directory
	LD	DE,(DIRMAX)
	LD	BC,0		; Start with count = 0
CNTLOP:	LD	A,(HL)
	CP	0E5H		; If not deleted file..
	JR	Z,NOCNT
	CP	'!'		; ..or time/date file..
	JR	Z,NOCNT
	INC	BC		; ..bump count
NOCNT:	LD	A,L
	ADD	A,IDLEN		; Increment to next entry
	LD	L,A
	JR	NC,LL0
	INC	H
LL0:	DEC	DE		; Decrement file count
	LD	A,D
	OR	E
	JR	NZ,CNTLOP	; Loop if more to go

; Entries * 4/3 = required space.  Check for adequate space

	SLA	C		; # Files * 4
	RL	B
	SLA	C
	RL	B
	LD	DE,0
LL1:	DEC	BC		; Divide by 3
	DEC	BC
	DEC	BC
	INC	DE		; (count in DE)
	BIT	7,B		; ..quit when < 0
	JR	Z,LL1
	LD	HL,(DIRMAX)
	EX	DE,HL
	OR	A
	SBC	HL,DE		; Check DIRMAX > required
	LD	DE,NOSPAC
	JP	NC,ABORT	; ..jump if Not Ok

; Initialize Date/Time buffer with date in format:
;	0       8      10      18      20H
;	|       |       |       |       |
;	!nnHMnnHM00nnHMnnHM00nnHMnnHM000

	LD	HL,DBUFFR	; Set initial Date/Time field
	LD	(HL),'!'	; Date/Time flag
	INC	HL
	LD	B,3		; Repeat 3 times
LL2:	PUSH	BC
	EX	DE,HL
	LD	HL,DATTIM
	LD	BC,4		; Move Create date
	LDIR
	LD	HL,DATTIM
	LD	BC,4		; ..and modified date
	LDIR
	EX	DE,HL
	LD	(HL),0		; ..followed by 2 nulls
	INC	HL
	LD	(HL),0
	INC	HL
	POP	BC
	DJNZ	LL2
	LD	(HL),0		; End with final null

; Move valid directory entries to default buffer and write
; them to disk 3 at a time with time & date added.

	LD	A,(QUIET)	; Do it quietly?
	OR	A
	JR	NZ,WRT0		; ..jump if so

	LD	DE,TMSG2	; Tell the User we are writing
	CALL	WRTLIN

WRT0:	LD	HL,RAMBUF
	LD	DE,0
	LD	(SCWRTN),DE
	LD	DE,(DIRMAX)
	LD	C,3
WRTNAM:	LD	A,(HL)
	CP	0E5H
	JR	Z,NOCNT1
	CP	'!'
	JR	Z,NOCNT1
	PUSH	DE
	LD	A,C		; Start with count/index
	ADD	A,A		; ..shifted * 32
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	NEG			; Invert order
	ADD	A,0E0H		; ..compensate
	LD	E,A
	LD	D,0		; Now have addr in default buffer
	CALL	MOVE32
	DEC	C
	JR	NZ,WRTNA0	; Loop if more
	LD	DE,BUFF+96	; When 3 moved..
	PUSH	HL
	LD	HL,DBUFFR	; ..put date & time in last slot
	CALL	MOVE32
	CALL	WRBLOK		; ..and write the sector
	LD	C,3		; Set up for 3 more
	POP	HL		; ..restoring regs..
WRTNA0:	POP	DE
	JR	WRTNA1		; ..and re-enter loop

NOCNT1:	PUSH	DE
	LD	DE,IDLEN
	ADD	HL,DE		; Increment by 32 for next entry
	POP	DE
WRTNA1:	DEC	DE		; Count down number of entries
	LD	A,D
	OR	E
	JR	NZ,WRTNAM	; Loop til done with whole dir
	LD	A,C		; See if final sector written
	CP	3
	JR	Z,L0316		; Jump if just finished write
	LD	DE,BUFF+96
	PUSH	HL
	LD	HL,DBUFFR	; ..else move time & date
	CALL	MOVE32
	POP	HL
	LD	A,C		; Calculate next entry position
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	NEG
	ADD	A,0E0H
	LD	L,A
	LD	H,0
	LD	DE,BUFF+96	; ..set ending position
LL3:	OR	A
	SBC	HL,DE
	ADD	HL,DE
	JR	Z,L0313
	LD	(HL),0E5H	; ..and fill unused w/delete marks
	INC	HL
	JR	LL3

L0313:	CALL	WRBLOK		; Write partial directory sector
L0316:	LD	HL,(SCWRTN)
	LD	DE,(NDIRSC)
	OR	A
	SBC	HL,DE
	ADD	HL,DE
;1.2	JP	Z,EXIT		; ..quit when done
	JR	Z,WRLAST	;1.2 ..jump to clear buffer and exit when done
	LD	HL,BUFF
	LD	B,96
L0328:	LD	(HL),0E5H
	INC	HL
	DJNZ	L0328
	EX	DE,HL
	LD	HL,DBUFFR
	LD	BC,IDLEN
	LDIR			; Move 32 bytes
	CALL	WRBLOK
	JR	L0316

WRLAST:	LD	BC,0001		;1.2 Force Directory write of current Sector
	CALL	BWRIT		;1.2 .write it!
	JP	EXIT		;1.2 ..and Quit

NOGOOD:	LD	DE,BADDRV
	CALL	WRTLIN		; Print Bad drive error
HELP0:	LD	DE,HLPMSG
	JP	ABORT		; Print Help message, relog drive and quit

HELP:	OR	0FFH		; If help request, show we're not interactive
	LD	(EXPERT),A
	JR	HELP0		; ..and jump back to common code

RDBLOK:	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	HL,0
	LD	D,(IX+01H)	; Get Sectors/Track
	LD	E,(IX+00H)
	LD	A,16+1
L044A:	OR	A
	SBC	HL,DE
	CCF
	JR	C,L0452
	ADD	HL,DE
	OR	A
L0452:	RL	C		; Shift carry bits in to BC
	RL	B
	DEC	A
	JR	Z,L045F		; ..exit when thru
	RL	L		; Shift HL left
	RL	H
	JR	L044A

L045F:	PUSH	HL
	LD	H,(IX+0EH)	; Get track offset
	LD	L,(IX+0DH)
	ADD	HL,BC
	LD	B,H		; Move current track to BC
	LD	C,L
	CALL	BSTTRK		; ..and set controller
	POP	BC		; Restore logical sector
	LD	DE,(SKWTBL)
	CALL	BSKEW		; ..and get physical sector
	LD	B,H
	LD	C,L
	CALL	BSTSEC		; Set the sector
	POP	BC
	PUSH	BC
	CALL	BSTDMA		; Set transfer address
	CALL	BREAD		; ..and read a sector
	OR	A
	JR	NZ,LODBAD	; Jump error if Error
	POP	HL
	POP	DE
	POP	BC
	RET

LODBAD:	LD	DE,RDERR
	JR	ABORT

WRBLOK:	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	HL,0
	LD	BC,(SCWRTN)
	LD	D,(IX+01H)	; Get Sectors/Track to DE
	LD	E,(IX+00H)
	LD	A,17
L04BF:	OR	A
	SBC	HL,DE
	CCF
	JR	C,L04C7
	ADD	HL,DE
	OR	A
L04C7:	RL	C
	RL	B
	DEC	A
	JR	Z,L04D4
	RL	L
	RL	H
	JR	L04BF

L04D4:	PUSH	HL
	LD	H,(IX+0EH)	; Get track offset
	LD	L,(IX+0DH)
	ADD	HL,BC
	LD	B,H
	LD	C,L
	CALL	BSTTRK
	POP	BC
	LD	DE,(SKWTBL)
	CALL	BSKEW
	LD	B,H
	LD	C,L
	CALL	BSTSEC
	LD	BC,BUFF
	CALL	BSTDMA
;1.2	LD	BC,0001		; Force a Directory Write
	LD	BC,0000		; No forced writes
	CALL	BWRIT
	OR	A
	JR	Z,L0523
	LD	DE,WRTERR
	JR	ABORT

L0523:	LD	BC,(SCWRTN)
	INC	BC
	LD	(SCWRTN),BC
	POP	HL
	POP	DE
	POP	BC
	RET

RSELEC:	LD	A,(DEFDRV)	; Get entry drive from storage
	LD	C,A		; ..set regs
	LD	B,0
	PUSH	BC		; Save drive vector
	LD	DE,0001H	; ..to login drive
	CALL	BSELDK		; Do it via BIOS to sync
	POP	DE		; Restore drive vector for Dos Call
LOGDOS:	LD	C,14		; ..and relog DOS
	JP	BDOS

;.....
; Abort to DOS.  Print message, resync and return gracefully
; ENTER: DE Points to error message

ABORT:	PUSH	DE		; Save error address
	CALL	RSELEC		; Re-Sync BIOS and BDOS
	POP	DE
	CALL	WRTLIN
EXIT:	LD	A,(EXPERT)	; Get the Mode Flag
	OR	A		; Are we Interactive?
	JP	Z,INTACL	; ..jump if so
EXIT0:	LD	SP,(STACK)	; Restore stack pointer
	RET			; ..and return

;.....
; Write a Carriage Return/Line Feed combination to Console

CRLF:	LD	DE,CRLFM	; Point to CRLF string
			;..and fall thru to write line
;.....
; Print message addressed in DE

WRTLIN:	LD	C,9		; Print error message
	JP	BDOS

;.....
; Print message addressed in DE, and get character from operator
; Return with Zero Set (Z) if "Y" or "y", else abort

GETACT:	CALL	WRTLIN
	LD	DE,DPROM1	; Print "Y/N" part of prompt
	CALL	WRTLIN
	CALL	GETCH		; Get console char in uppercase
	CP	'Y'
	RET	Z		; ..or "Y"
	CALL	RSELEC		; User entered No response, so reselect
	JR	EXIT		; ..and quit

;.....
; Get char from Console in Uppercase via DOS call

GETCH:	LD	C,1		; Get console char command
	CALL	BDOS
	CP	3		; Is it a Control-C?
	JR	Z,EXIT0		; ..Quit here if so
	CP	'a'		; Is it less than "a"?
	RET	C		; ..return if so
	CP	'z'+1		; Is it Greater than "z"?
	RET	NC		; ..return if so
	AND	5FH		; Else make uppercase
	RET

;.....
; Move 32 bytes from memory addressed by HL to that addressed by DE

MOVE32:	LD	B,32
MOV32A:	LD	A,(HL)
	LD	(DE),A
	INC	HL
	INC	DE
	DJNZ	MOV32A
	RET

;-----------------------------------------------
;	BIOS Vectors and interface
;-----------------------------------------------

; BSELDK:	PUSH	BC
; 	LD	BC,18H
; 	JR	GOBIOS
;
; BSTTRK:	PUSH	BC
; 	LD	BC,1BH
; 	JR	GOBIOS
;
; BSTSEC:	PUSH	BC
; 	LD	BC,1EH
; 	JR	GOBIOS
;
; BSTDMA:	PUSH	BC
; 	LD	BC,21H
; 	JR	GOBIOS
;
; BREAD:	PUSH	BC
; 	LD	BC,24H
; 	JR	GOBIOS
;
; BWRIT:	PUSH	BC
; 	LD	BC,27H
; 	JR	GOBIOS
;
; BSKEW:	PUSH	BC
; 	LD	BC,2DH
; 	JR	GOBIOS
;
; GOBIOS:	EX	(SP),HL
; 	PUSH	HL
; 	LD	HL,(BASE+1)
; 	ADD	HL,BC
; 	POP	BC
; 	EX	(SP),HL
; 	RET

BIOSCB:
BCFFUN:	DEFB	0
BCFA:	DEFB	0
BCFBC:	DEFW	0
BCFDE:	DEFW	0
BCFHL:	DEFW	0
BXFUN	EQU	0
BXA	EQU	1
BXBCC	EQU	2
BXBCB	EQU	3
BXDEE	EQU	4
BXDED	EQU	5
BXHLL	EQU	6
BXHLH	EQU	7

BSELDK:
	PUSH	IX
	LD	IX,BIOSCB
	LD	(IX+BXFUN),9
	LD	(IX+BXBCC),C
	LD	(IX+BXBCB),B
	PUSH	DE
	LD	E,0		; force login
	LD	(IX+BXDEE),E
	LD	(IX+BXDED),D
	POP	DE
	CALL	GOBIOS
	LD	L,(IX+BXHLL)
	LD	H,(IX+BXHLH)
	POP	IX
	RET

BSTTRK:
	PUSH	IX
	LD	IX,BIOSCB
	LD	(IX+BXFUN),10
	LD	(IX+BXBCC),C
	LD	(IX+BXBCB),B
	CALL	GOBIOS
	POP	IX
	RET

BSTSEC:
	PUSH	IX
	LD	IX,BIOSCB
	LD	(IX+BXFUN),11
	LD	(IX+BXBCC),C
	LD	(IX+BXBCB),B
	CALL	GOBIOS
	POP	IX
	RET

BSTDMA:
	PUSH	IX
	LD	IX,BIOSCB
	LD	(IX+BXFUN),12
	LD	(IX+BXBCC),C
	LD	(IX+BXBCB),B
	CALL	GOBIOS
	POP	IX
	RET

BREAD:
	PUSH	IX
	LD	IX,BIOSCB
	LD	(IX+BXFUN),13
	CALL	GOBIOS
	LD	A,(IX+BXA)
	POP	IX
	RET

BWRIT:
	PUSH	IX
	LD	IX,BIOSCB
	LD	(IX+BXFUN),14
	CALL	GOBIOS
	LD	A,(IX+BXA)
	POP	IX
	RET

BSKEW:
	PUSH	IX
	LD	IX,BIOSCB
	LD	(IX+BXFUN),16
	LD	(IX+BXBCC),C
	LD	(IX+BXBCB),B
	LD	(IX+BXDEE),E
	LD	(IX+BXDED),D
	CALL	GOBIOS
	LD	L,(IX+BXHLL)
	LD	H,(IX+BXHLH)
	POP	IX
	RET

GOBIOS:
	PUSH	DE
	PUSH	BC
	LD	C,32		; direct BIOS call
	LD	DE,BIOSCB
	CALL	BDOS
	POP	BC
	POP	DE
	RET

;.....
;  System messages

BADDRV:	DEFB	CR,LF,LF,BELL,'Illegal drive name$'

ALREDY:	DEFB	CR,LF,BELL,'Directory already initialized$'

NOSPAC:	DEFB	CR,LF,BELL,'Not enough directory space on disk$'

PROMPT:	DEFB	CR,LF,'INITDIR  Ver ',VERS/10+'0','.',VERS MOD 10 + '0'
	DATE
	DEFB	CR,LF,'Custom version for Z80 Darkstar (NEZ80) by P. Betti 20141017'
	DEFB	CR,LF,LF
	DEFB	'   Initializing a Disk for P2DOS Date/Time Stamps which'
	DEFB	' already ',CR,LF
	DEFB	'   contains files marked with DateStamper Stamps may '
	DEFB	'invalidate',CR,LF
	DEFB	'   the existing DateStamper Times and Dates!',CR,LF,'$'

DPROMP:	DEFB	CR,LF,'     Confirm Initialize Drive $'
DPROM0:	DEFB	': $'
DPROM1:	DEFB	'(Y/[N]) : $'

MESG0:	DEFB	CR,LF,LF,'Initialize which Disk for P2DOS Date/Time Stamps? : $'
MESG1:	DEFB	CR,LF,LF,'Initialize another Disk? $'
MESG2:	DEFB	BELL,BS,' ',BS,'$'

RDERR:	DEFB	CR,LF,BELL,'Directory read error$'

WRTERR:	DEFB	CR,LF,BELL,'Directory write error$'

HLPMSG:	DEFB	CR,LF
	DEFB	'Usage: Prepare disk for CP/M-3 (P2DOS) style date/time'
	DEFB	' stamping',CR,LF,LF
	DEFB	'Syntax:',CR,LF
	DEFB	'	INITDIR		- Enter Interactive Mode',CR,LF
	DEFB	'	INITDIR d:	- Initialize drive "d"',CR,LF
	DEFB	'	INITDIR //	- Display this message',CR,LF,LF
	DEFB	'Note: ZCNFG may be used to configure a flag to suppress',CR,LF
	DEFB	'      drive confirmation prompt and status messages',CR,LF,'$'

CRLFM:	DEFB	CR,LF,'$'

EXMSG:	DEFB	BELL,CR,LF,'--> DateStamper !!!TIME&.DAT File Found <--',CR,LF
	DEFB	'	Proceed anyway $'

TMSG1:	DEFB	CR,LF,'...Reading Directory Entries...$'
TMSG2:	DEFB	CR,LF,'...Writing Initialized Directory...$'

DBG1:	DEFB	CR,LF,'p1$'
DBG2:	DEFB	CR,LF,'p2$'
DBG3:	DEFB	CR,LF,'p3$'
DBG4:	DEFB	CR,LF,'p4$'
DBG5:	DEFB	CR,LF,'p5$'

;---------------------------------------------------------
;		D A T A       A R E A
;---------------------------------------------------------

DATTIM:	DEFB	0,0,0,0,0	; Initial date value
TDFCB:	DEFB	0,'!!!TIME&DAT',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DEFB	0,0,0,0

EXPERT:	DEFS	1		; Expert Flag (0=Expert, <>0=Interactive)
DEFDRV:	DEFS	1		; Drive logged by Dos on Entry
DRVNUM:	DEFS	1		; Storage for drive letter
DIRMAX:	DEFS	2		; Number of directory entries on disk
NDIRSC:	DEFS	2		; Number of directory sectors
SCWRTN:	DEFS	2		; Number of sectors read/written
SKWTBL:	DEFS	2		; Address of skew table
DBUFFR:	DEFS	IDLEN		; 32-byte directory date/time buffer
	DEFS	80		; Room for stack
STACK:	DEFS	2		; Location to save entry stack pointer
RAMBUF:				; Buffer starts here, goes up

	END
