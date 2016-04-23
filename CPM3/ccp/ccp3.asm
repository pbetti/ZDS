
	.Z80

	TITLE	'CP/M 3 - Console Command Processor - November 1982'
;	version 3.00  Nov 30 1982 - Doug Huskey


;  Copyright (C) 1982
;  Digital Research
;  P.O. Box 579
;  Pacific Grove, CA 93950

;  Revised: John Elliott, 25-5-1998, to include DRI patches and multiple
;          error checking ability:
;
;          If the sequence
;               COMMAND
;               :C1
;               :C2
;
;           was executed under DRI's CCP, and COMMAND returned an error,
;           then C1 would not be executed but C2 would. Under this CCP
;           C2 would not be.
;
;	****************************************************
;	*****  The following equates must be set to 100H ***
;	*****  + the addresses specified in LOADER.PRN   ***
;	*****                                            ***
EQU1		EQU	RSXSTART	;does this adr match loader's?
EQU2		EQU	FIXCHAIN	;does this adr match loader's?
EQU3		EQU	FIXCHAIN1	;does this adr match loader's?
EQU4		EQU	FIXCHAIN2	;does this adr match loader's?
EQU5		EQU	RSX$CHAIN	;does this adr match loader's?
EQU6		EQU	RELOC		;does this adr match loader's?
EQU7		EQU	CALCDEST	;does this adr match loader's?
EQU8		EQU	SCBADDR		;does this adr match loader's?
EQU9		EQU	BANKED		;does this adr match loader's?
EQU10		EQU	RSXEND		;does this adr match loader's?
EQU11		EQU	CCPORG		;does this adr match loader's?
EQU12		EQU	CCPEND		;This should be 0D80h
RSXSTART	EQU	0100H
FIXCHAIN	EQU	01D0H
FIXCHAIN1	EQU	01EBH
FIXCHAIN2	EQU	01F0H
RSX$CHAIN	EQU	0200H
RELOC		EQU	02CAH
CALCDEST	EQU	030FH
SCBADDR		EQU	038DH
BANKED		EQU	038FH
RSXEND		EQU	0394H
CCPORG		EQU	0401H		;[JCE] was 041Ah, but reduced
					;      to incorporate patches
;	****************************************************
;	NOTE: THE ABOVE EQUATES MUST BE CORRECTED IF NECESSARY
;	AND THE JUMP TO START AT THE BEGINNING OF THE LOADER
;	MUST BE SET TO THE ORIGIN ADDRESS BELOW:

	ORG	CCPORG		;LOADER is at 100H to 3??H

;	(BE SURE THAT THIS LEAVES ENOUGH ROOM FOR THE LOADER BIT MAP)


;  Conditional Assembly toggles:

TRUE		EQU	-1
FALSE		EQU	0
NEWDIR		EQU	TRUE
NEWERA		EQU	TRUE		;confirm any ambiguous file name
DAYFILE 	EQU	TRUE
PROMPTS 	EQU	FALSE
FUNC152		EQU	TRUE
MULTI		EQU	TRUE		;multiple command lines
	;also shares code with loader (100-2??h)
;
;************************************************************************
;
;	GLOBAL EQUATES
;
;************************************************************************
;
;
;	CP/M BASE PAGE
;
WSTART	EQU	0		;warm start entry point
DEFDRV	EQU	4		;default user & disk
BDOS	EQU	5		;CP/M BDOS entry point
OSBASE	EQU	BDOS+1		;base of CP/M BDOS
CMDRV	EQU	050H		;command drive
DFCB	EQU	05CH		;1st default fcb
DUFCB	EQU	DFCB-1		;1st default fcb user number
PASS0	EQU	051H		;1st default fcb password addr
LEN0	EQU	053H		;1st default fcb password length
DFCB1	EQU	06CH		;2nd default fcb
DUFCB1	EQU	DFCB1-1		;2nd default fcb user number
PASS1	EQU	054H		;2nd default fcb password addr
LEN1	EQU	056H		;2nd default fcb password length
BUF	EQU	80H		;default buffer
TPA	EQU	100H		;transient program area
	IF	MULTI
COMLEN	EQU	100H-19H	;maximum size of multiple command
	;RSX buffer with 16 byte header &
	;terminating zero
	ELSE
COMLEN	EQU	TPA-BUF
	ENDIF
;
;	BDOS FUNCTIONS
;
VERS	EQU	31H		;BDOS vers 3.1
CINF	EQU	1		;console input
COUTF	EQU	2		;console output
CRAWF	EQU	6		;raw console input
PBUFF	EQU	9		;print buffer to console
RBUFF	EQU	10		;read buffer from console
CSTATF	EQU	11		;console status
RESETF	EQU	13		;disk system reset
SELF	EQU	14		;select drive
OPENF	EQU	15		;open file
CLOSEF	EQU	16		;close file
SEARF	EQU	17		;search first
SEARNF	EQU	18		;search next
DELF	EQU	19		;delete file
READF	EQU	20		;read file
MAKEF	EQU	22		;make file
RENF	EQU	23		;rename file
DMAF	EQU	26		;set DMA address
USERF	EQU	32		;set/get user number
RREADF	EQU	33		;read file
FLUSHF	EQU	48		;flush buffers
SCBF	EQU	49		;set/get SCB value
LOADF	EQU	59		;program load
ALLOCF	EQU	98		;reset allocation vector
TRUNF	EQU	99		;read file
PARSEF	EQU	152		;parse file
;
;	ASCII characters
;
CTRLC 	EQU	'C'-40H
CR 	EQU	'M'-40H
LF 	EQU	'J'-40H
TAB 	EQU	'I'-40H
EOF 	EQU	'Z'-40H
;
;
;	RSX MEMORY MANAGEMENT EQUATES
;
;     	RSX header equates
;
RENTRY		EQU	06H		;RSX contain jump to start
NEXTADD 	EQU	0BH		;address of next RXS in chain
PREVADD		EQU	0CH		;address of previous RSX in chain
WARMFLG 	EQU	0EH		;remove on wboot flag
ENDCHAIN 	EQU	18H		;end of RSX chain flag
;
;	LOADER.RSX equates
;
MODULE	EQU	100H		;module address
;
;	COM file header equates
;
COMSIZE EQU	TPA+1H		;size of the COM file
RSXOFF	EQU	TPA+10H		;offset of the RSX in COM file
RSXLEN	EQU	TPA+12H		;length of the RSX
;
;
;	SYSTEM CONTROL BLOCK OFFSETS
;
PAG$OFF EQU	09CH
;
OLOG		EQU	PAG$OFF-0CH	; removeable media open vector
RLOG		EQU	PAG$OFF-0AH	; removeable media login vector
BDOSBASE 	EQU	PAG$OFF-004H	; real BDOS entry point
HASHL		EQU	PAG$OFF+000H	; system variable
HASH		EQU	PAG$OFF+001H	; hash code
BDOS$VERSION	EQU	PAG$OFF+005H	; BDOS version number
UTIL$FLGS 	EQU	PAG$OFF+006H	; utility flags
DSPL$FLGS 	EQU	PAG$OFF+00AH	; display flags
CLP$FLGS 	EQU	PAG$OFF+00EH	; CLP flags
CLP$DRV 	EQU	PAG$OFF+00FH	; submit file drive
PROG$RET$CODE	EQU	PAG$OFF+010H	; program return code
MULTI$RSX$PG 	EQU	PAG$OFF+012H	; multiple command buffer page
CCPDRV		EQU	PAG$OFF+013H	; ccp default drive
CCPUSR		EQU	PAG$OFF+014H	; ccp default user number
CCPCONBUF 	EQU	PAG$OFF+015H	; ccp console buffer address
CCPFLAG1 	EQU	PAG$OFF+017H	; ccp flags byte 1
CCPFLAG2 	EQU	PAG$OFF+018H	; ccp flags byte 2
CCPFLAG3 	EQU	PAG$OFF+019H	; ccp flags byte 3
CONWIDTH 	EQU	PAG$OFF+01AH	; console width
CONCOLUMN 	EQU	PAG$OFF+01BH	; console column position
CONPAGE 	EQU	PAG$OFF+01CH	; console page length (lines)
CONLINE 	EQU	PAG$OFF+01DH	; current console line number
CONBUFFER 	EQU	PAG$OFF+01EH	; console input buffer address
CONBUFFL 	EQU	PAG$OFF+020H	; console input buffer length
CONIN$RFLG 	EQU	PAG$OFF+022H	; console input redirection flag
CONOUT$RFLG 	EQU	PAG$OFF+024H	; console output redirection flag
AUXIN$RFLG 	EQU	PAG$OFF+026H	; auxillary input redirection flag
AUXOUT$RFLG 	EQU	PAG$OFF+028H	; auxillary output redirection flag
LISTOUT$RFLG 	EQU	PAG$OFF+02AH	; list output redirection flag
PAGE$MODE 	EQU	PAG$OFF+02CH	; page mode flag 0=on, 0ffH=off
PAGE$DEF 	EQU	PAG$OFF+02DH	; page mode default
CTLH$ACT 	EQU	PAG$OFF+02EH	; ctl-h active
RUBOUT$ACT 	EQU	PAG$OFF+02FH	; rubout active (boolean)
TYPE$AHEAD 	EQU	PAG$OFF+030H	; type ahead active
CONTRAN 	EQU	PAG$OFF+031H	; console translation subroutine
CON$MODE 	EQU	PAG$OFF+033H	; console mode (raw/cooked)
TEN$BUFFER 	EQU	PAG$OFF+035H	; 128 byte buffer available
					; to banked BIOS
OUTDELIM 	EQU	PAG$OFF+037H	; output delimiter
LISTCP		EQU	PAG$OFF+038H	; list output flag (ctl-p)
Q$FLAG		EQU	PAG$OFF+039H	; queue flag for type ahead
SCBAD		EQU	PAG$OFF+03AH	; system control block address
DMAAD		EQU	PAG$OFF+03CH	; dma address
SELDSK		EQU	PAG$OFF+03EH	; current disk
INFO		EQU	PAG$OFF+03FH	; BDOS variable "info"
RESEL		EQU	PAG$OFF+041H	; disk reselect flag
RELOG		EQU	PAG$OFF+042H	; relog flag
FX		EQU	PAG$OFF+043H	; function number
USRCODE 	EQU	PAG$OFF+044H	; current user number
DCNT		EQU	PAG$OFF+045H	; directory record number
SEARCHA 	EQU	PAG$OFF+047H	; fcb address for searchn function
SEARCHL 	EQU	PAG$OFF+049H	; scan length for search functions
MULTCNT 	EQU	PAG$OFF+04AH	; multi-sector I/O count
ERRORMODE 	EQU	PAG$OFF+04BH	; BDOS error mode
DRV0		EQU	PAG$OFF+04CH	; search chain - 1st drive
DRV1		EQU	PAG$OFF+04DH	; search chain - 2nd drive
DRV2		EQU	PAG$OFF+04EH	; search chain - 3rd drive
DRV3		EQU	PAG$OFF+04FH	; search chain - 4th drive
TEMPDRV 	EQU	PAG$OFF+050H	; temporary file drive
PATCH$FLAG 	EQU	PAG$OFF+051H	; patch flags
DATE		EQU	PAG$OFF+058H	; date stamp
COM$BASE 	EQU	PAG$OFF+05DH	; common memory base address
ERROR		EQU	PAG$OFF+05FH	; error jump...all BDOS errors
TOP$TPA 	EQU	PAG$OFF+062H	; top of user TPA (address at 6,7)
;
;	CCP FLAG 1 BIT MASKS
;	(used with getflg, setflg and resetflg routines)
;
CHAINFLG 	EQU	080H		; program chain (funct 49)
NOT$CHAINFLG 	EQU	03FH	; mask to reset chain flags
CHAINENV	EQU	040H		; preserve usr/drv for chained prog
COMREDIRECT 	EQU	0B320H		; command line redirection active
MENU		EQU	0B310H		; execute ccp.ovl for menu systems
ECHO		EQU	0B308H		; echo commands in batch mode
USERPARSE 	EQU	0B304H		; parse user numbers in commands
SUBFILE 	EQU	0B301H		; $$$.SUB file found or active
SUBFILEMASK 	EQU	SUBFILE-0B300H
RSX$ONLY$SET 	EQU	02H	; RSX only load (null COM file)
RSX$ONLY$CLR 	EQU	0FDH	; reset RSX only flag
;
;	CCP FLAG 2 BIT MASKS
;	(used with getflg, setflg and resetflg routines)
;
CCP10		EQU	0B4A0H		; CCP function 10 call (2 bits)
CCPSUB		EQU	0B420H		; CCP present (for SUBMIT, PUT, GET)
CCPBDOS 	EQU	0B480H		; CCP present (for BDOS buffer save)
DSKRESET 	EQU	20H		; CCP does disk reset on ^C from prompt
SUBMIT		EQU	0B440H		; input redirection active
SUBMITFLG 	EQU	40H		; input redirection flag value
ORDER		EQU	0B418H		; command order
		;  0 - COM only
		;  1 - COM,SUB
		;  2 - SUB,COM
		;  3 - reserved
DATETIME 	EQU	0B404H		; display date & time of load
DISPLAY 	EQU	0B403H		; display filename & user/drive
FILENAME 	EQU	02H		; display filename loaded
LOCATION 	EQU	01H		; display user & drive loaded from

;
;	CCP FLAG 3 BIT MASKS
;	(used with getflg, setflg and resetflg routines)
;
RSXLOAD 	EQU	1H		; load RSX, don't fix chain
COLDBOOT 	EQU	2H		; try to exec profile.sub
;
;   	CONMODE BIT MASKS
;
CTLC$STAT 	EQU	0CF01H		;conmode CTL-C status

;
;
;************************************************************************
;
;	Console Command Processor - Main Program
;
;************************************************************************
;
;
;
START:
;
	LD	SP,STACK
	LD	HL,CCPRET	;push CCPRET on stack, in case of
	PUSH	HL		; profile error we will go there
	LD	DE,SCBADD
	LD	C,SCBF
	CALL	BDOS
	LD	(SCBADDR),HL	;save SCB address
	LD	L,COM$BASE+1
	LD	A,(HL)		;high byte of commonbase
	LD	(BANKED),A	;save in loader
	LD	L,BDOSBASE+1	;HL addresses real BDOS page
	LD	A,(HL)		;BDOS base in H
	LD	(REALDOS),A	;save it for use in XCOM routine
;
	LD	A,(OSBASE+1)	;is the LOADER in memory?
	SUB	(HL)		;compare link at 6 with real BDOS
	JP	NZ,RESET$ALLOC	;skip move if loader already present
;
;
MOVLDR:
	LD	BC,RSXEND-RSXSTART;length of loader RSX
	CALL	CALCDEST	;calculate destination and (bias+200h)
	LD	H,E		;set to zero
	LD	L,E
;	lxi	h,module-100h	;base of loader RSX (less 100h)
	CALL	RELOC		;relocate loader
	LD	HL,(OSBASE)	;HL = BDOS entry, DE = LOADER base
	LD	L,E		;set L=0
	LD	C,6
	CALL	MOVE		;move the serial number down
	LD	E,NEXTADD
	CALL	FIXCHAIN1
;
;
RESET$ALLOC:
	LD	C,ALLOCF
	CALL	BDOS
;
;
;
;************************************************************************
;
;	INITIALIZE SYSTEM CONTROL BLOCK
;
;************************************************************************
;
;
SCBINIT:
	;
	;	# dir columns, page size & function 9 delimiter
	;
	LD	B,CONWIDTH
	CALL	GETBYTE
	INC	A		;get console width (rel 1)
	RRCA
	RRCA
	RRCA
	RRCA
	AND	0FH		;divide by 16
	LD	DE,DIRCOLS
	LD	(DE),A		;dircols = conwidth/16
	LD	L,CONPAGE
	LD	A,(HL)
	DEC	A		;subtract 1 for space before prompt
	INC	DE
	LD	(DE),A		;pgsize = conpage
	XOR	A
	INC	DE
	LD	(DE),A		;line=0
	LD	A,'$'
	INC	DE
	LD	(DE),A		;pgmode = nopage (>0)
	LD	L,OUTDELIM
	LD	(HL),A		;set function 9 delimiter
	;
	;	multisector count, error mode, console mode
	;		& BDOS version no.
	;
	LD	L,MULTCNT
	LD	(HL),1		;set multisector I/O count = 1
	INC	HL		;.errormode
	XOR	A
	LD	(HL),A		;set return error mode = 0
	LD	L,CON$MODE
	LD	(HL),1		;set ^C status mode
	INC	HL
	LD	(HL),A		;zero 2nd conmode byte
	LD	L,BDOS$VERSION
	LD	(HL),VERS	;set BDOS version no.
	;
	;	disk reset check
	;
	LD	L,CCPFLAG2
	LD	A,(HL)
	AND	DSKRESET	;^C at CCP prompt?
	LD	C,RESETF
	PUSH	HL
	CALL	NZ,BDOS		;perform disk reset if so
	POP	HL
	;
	;	remove temporary RSXs (those with remove flag on)
	;
RSXCK:
	LD	L,CCPFLAG1	;check CCP flag for RSX only load
	LD	A,(HL)
	AND	RSX$ONLY$SET	;bit = 1 if only RSX has been loaded
	PUSH	HL
	CALL	Z,RSX$CHAIN	;don't fix-up RSX chain if so
	POP	HL
	LD	A,(HL)
	AND	RSX$ONLY$CLR	;clear RSX only loader flag
	LD	(HL),A		;replace it
	;
	;	chaining environment
	;
	AND	CHAINENV	;non-zero if we preserve programs
	PUSH	HL		;user & drive for next transient
	;
	;	user number
	;
	LD	L,CCPUSR	; HL = .CCP USER (saved in SCB)
	LD	BC,USERNUM	; BC = .CCP'S DEFAULT USER
	LD	D,H
	LD	E,USRCODE	; DE = .BDOS USER CODE
	LD	A,(DE)
	LD	(BC),A		; usernum = bdos user number
	LD	A,(HL)		; ccp user
	JP	NZ,SCB1		; jump if chaining env preserved
	LD	(BC),A		; usernum = ccp default user
SCB1:	LD	(DE),A		; bdos user = ccp default user
	;
	;	transient program's current disk
	;
	INC	BC		;.CHAINDSK
	LD	E,SELDSK	;.BDOS CURRENT DISK
	LD	A,(DE)
	JP	NZ,SCB2		; jump if chaining env preserved
	LD	A,0FFH
;	cma			; make an invalid disk
SCB2:	LD	(BC),A		; chaindsk = bdos disk (or invalid)
	;
	;	current disk
	;
	DEC	HL		;.CCP's DISK (saved in SCB)
	INC	BC		;.CCP's CURRENT DISK
	LD	A,(HL)
	LD	(BC),A
	LD	(DE),A		; BDOS current disk
	;
	;	$$$.SUB drive
	;
	LD	L,TEMPDRV
	INC	BC		;.SUBFCB
	LD	A,(HL)
	LD	(BC),A		; $$$.SUB drive = temporary drive
	;
	;	check for program chain
	;
	POP	HL		;HL =.ccpflag1
	LD	A,(HL)
	AND	CHAINFLG	;is it a chain function (47)
	JP	Z,CKBOOT	;jump if not
	LD	HL,BUF
CHAIN:	LD	DE,CBUFL
	LD	C,TPA-BUF-1
	LD	A,C
	LD	(DE),A
	INC	DE
	CALL	MOVE		;hl = source, de = dest, c = count
	JP	CCPPARSE
	;
	;	execute profile.sub ?
	;
CKBOOT:	LD	L,CCPFLAG3
	LD	A,(HL)
	AND	COLDBOOT	;is this a cold start
	JP	NZ,CCPCR	;jump if not
	LD	A,(HL)
	OR	COLDBOOT	;set flag for next time
	LD	(HL),A
	LD	(ERRFLG),A	;set to ignore errors
	LD	HL,PROFILE
	JP	CHAIN		;attempt to exec profile.sub
PROFILE:
	DEFB	'PROFILE.S',0
;
;
;
;************************************************************************
;
;	BUILT-IN COMMANDS (and errors) RETURN HERE
;
;************************************************************************
;
;
CCPCR:
	;	enter here on each command or error condition
	CALL	SETCCPFLG
	CALL	CRLF
CCPRET:
	LD	HL,STACK-2	;reset stack in case of error
	LD	SP,HL		;preserve CCPRET on stack
	XOR	A
	LD	(LINE),A
	LD	HL,CCPRET	;return for next builtin
	PUSH	HL
	CALL	SETCCPFLG
	DEC	HL		;.CCPFLAG1
	LD	A,(HL)
	AND	SUBFILEMASK	;check for $$$.SUB submit
	JP	Z,PROMPT
;
;
;
;************************************************************************
;
;	$$$.SUB file processing
;
;************************************************************************
;
;
	LD	DE,CBUFL	;set DMA to command buffer
	CALL	SETBUF
	LD	C,OPENF
	CALL	SUDOS		;open it if flag on
	LD	C,CSTATF	;check for break if successful open
	CALL	Z,SUDOS		;^C typed?
	JP	NZ,SUBCLOSE	;delete $$$.SUB if break or open failed
	LD	HL,SUBRR2
	LD	(HL),A		;zero high random record #
	DEC	HL
	LD	(HL),A		;zero middle random record #
	DEC	HL
	PUSH	HL
	LD	A,(SUBRC)
	DEC	A
	LD	(HL),A		;set to read last record of file
	LD	C,RREADF
	CALL	P,SUDOS
	POP	HL
	DEC	(HL)		;record count (truncate last record)
	LD	C,DELF
	CALL	M,SUDOS
	OR	A		;error on read?
	;
	;
SUBCLOSE:
	PUSH	AF
	LD	C,TRUNF		;truncate file (& close it)
	CALL	SUDOS
	POP	AF		;any errors ?
	JP	Z,CCPPARSE	;parse command if not
	;
	;
SUBKILL:
	LD	BC,SUBFILE
	CALL	RESETFLG	;turn off submit flag
	LD	C,DELF
	CALL	SUDOS		;kill submit
;
;
;
;************************************************************************
;
;	GET NEXT COMMAND
;
;************************************************************************
;
;
	;
	; 	prompt user
	;
PROMPT:
	LD	A,(USERNUM)
	OR	A
	CALL	NZ,PDB		;print user # if non-zero
	CALL	DIRDRV1
;
; [JCE] Allow Named Directory extensions to print their names
;
	LD	DE,RSXPB	;3 bytes
	LD	C,3CH		;2 bytes
	CALL	BDOS		;3 bytes
;
	LD	A,'>'
	CALL	PUTC
	;
	IF	MULTI
	;move ccpconbuf addr to conbuffer addr
	LD	DE,CCPCONBUF*256+CONBUFFER
	CALL	WORDMOV		;process multiple command, unless in submit
	OR	A		;non-zero => multiple commands active
	PUSH	AF		;save A=high byte of ccpconbuf
	LD	BC,CCPBDOS
	CALL	NZ,RESETFLG	;turn off BDOS flag if multiple commands
	ENDIF			;multi
	CALL	RCLN		;get command line from console
	CALL	RESETCCPFLG	;turn off BDOS, SUBMIT & GET ccp flags
	IF	MULTI
	POP	AF		;D=high byte of ccpconbuf
	CALL	NZ,MULTISAVE	;save multiple command buffer
	ENDIF			;multi
;
;
;
;************************************************************************
;
;	PARSE COMMAND
;
;************************************************************************
;
;
CCPPARSE:
	;
	;	reset default page mode
	;	(in case submit terminated)
	;
	CALL	SUBTEST		;non-zero if submit is active
	JP	NZ,GET$PG$MODE	;skip, if so
SET$PG$MODE:
	LD	L,PAGE$DEF
	LD	A,(HL)		;pick up default
	DEC	HL
	LD	(HL),A		;place in mode
GET$PG$MODE:
	LD	L,PAGE$MODE
	LD	A,(HL)
	LD	(PGMODE),A
	;
	;check for multiple commands
	;convert to upper case
	;reset ccp flag, in case entered from a CHAIN (or profile)
	;
	CALL	UC		;convert to upper case, ck if multiple command
	RET	Z		;get another line if null or comment
	;
	;transient or built-in command?
	;
	LD	DE,UFCB		;include user number byte in front of FCB
	CALL	GCMD		;parse command name
	LD	A,(FCB+9)	;file type specified?
	CP	' '
	JP	NZ,CCPDISK2	;execute from disk, if so
	LD	HL,UFCB		;user or drive specified?
	LD	A,(HL)		;user number
	INC	HL
	OR	(HL)		;drive
	INC	HL
	LD	A,(HL)		;get 1st character of filename
	JP	NZ,CCPDISK3	;jump if so
	;
	;BUILT-IN HANDLER
	;
CCPBUILTIN:
	LD	HL,CTBL		;search table of internal commands
	LD	DE,FCB+1
	LD	A,(FCB+3)
	CP	' '+1		;is it shorter that 3 characters?
	CALL	NC,TBLS		;is it a built-in?
	JP	NZ,CCPDISK0	;load from disk if not
	LD	A,(OPTION)	;[ in command line?
	OR	A		;options specified?
	LD	A,B		;built-in index from tbls
	LD	HL,(PARSEP)
	LD	(ERRSAV),HL	;save beginning of command tail
	LD	HL,PTBL		;jump to processor if options not
	JP	Z,TBLJ		;specified
	CP	4
	JP	C,TRYCOM
	LD	HL,FCB+4
	JP	NZ,CCPDISK0	;if DIRS then look for DIR.COM
	LD	(HL),' '
	;
	;LOAD TRANSIENT (file type unspecified)
	;
CCPDISK0:
	LD	BC,ORDER
	CALL	GETFLG		;0=COM   8=COM,SUB  16=SUB,COM
	JP	Z,CCPDISK2	;search for COM file only
	LD	B,8		;=> 2nd choice is SUB
	SUB	B		;now a=0 (COM first) or 8 (SUB first)
	JP	Z,CCPDISK1	;search for COM first then SUB
	LD	B,0		;search for SUB first then COM

CCPDISK1:
	PUSH	BC		;save 2nd type to try
	CALL	SETTYPE		; A = offset of type in type table
	CALL	EXEC		;try to execute, return if unsuccessful
	POP	AF		;try 2nd type
	CALL	SETTYPE
	;
	;LOAD TRANSIENT (file type specified)
	;
CCPDISK2:
	CALL	EXEC
	JP	PERROR		;error if can't find it
	;
	;DRIVE SPECIFIED (check for change drives/users command)
	;
CCPDISK3:
	CP	' '		;check for filename
	JP	NZ,CCPDISK0	;execute from disk if specified
	CALL	EOC		;error if not end of command
	LD	A,(UFCB)	;user specified?
	SUB	1
	JP	C,CCPDRIVE

CCPUSER:
	LD	(USERNUM),A	;CCP's user number
	LD	B,CCPUSR
	CALL	SETBYTE		;save it in SCB
	CALL	SETUSER		;set current user

CCPDRIVE:
	LD	A,(FCB)		;drive specified?
	DEC	A
	RET	M		;return if not
	PUSH	AF
	CALL	SELECT
	POP	AF
	LD	(DISK),A	;CCP's drive
	LD	B,CCPDRV
	JP	SETBYTE		;save it in SCB

;;
;
;************************************************************************
;
;	BUILT-IN COMMANDS
;
;************************************************************************
;
;
;	Table of internal ccp commands
;
;
CTBL:	DEFB	'DIR '
	DEFB	'TYPE '
	DEFB	'ERASE '
	DEFB	'RENAME '
	DEFB	'DIRSYS '
	DEFB	'USER '
	DEFB	0
;
PTBL:	DEFW	DIR
	DEFW	TYPE
	DEFW	ERA
	DEFW	REN
	DEFW	DIRS
	DEFW	USER
;;
;;-----------------------------------------------------------------------
;;
;;	DIR Command
;;
;;	DIR		list directory of current default user/drive
;;	DIR <X>:	list directory of user/drive <X>
;;	DIR <AFN>	list all files on the current default user/drive
;;			with names that match <AFN>
;;	DIR <X>:<AFN>	list all files on user/drive <X> with names that
;;			match <AFN>
;;
;;-----------------------------------------------------------------------
;;
;
	IF	NEWDIR
DIRDRV:
	LD	A,(DFCB)	;get disk number
	ENDIF			;newdir

DIRDRV0:
	DEC	A
	JP	P,DIRDRV2

DIRDRV1:
	LD	A,(DISK)	;get current disk
DIRDRV2:
	ADD	A,'A'
	JP	PFC		;print it (save BC,DE)
;
;
	IF	NEWDIR
DIR:
	LD	C,0		;flag for DIR (normal)
	LD	DE,SYSFILES
	JP	DIRS1
;
;
DIRS:
	LD	C,080H		;flag for DIRS (system)
	LD	DE,DIRFILES

DIRS1:	PUSH	DE
; [JCE] Patch 15
	XOR	A		;Reset "anyfiles" before starting
	LD	(ANYFILES),A	; - it might not have been cleared
	CALL	DIRECT
	POP	DE		;de = .system files message
	JP	Z,NOFILE	;jump if no files found
	LD	A,L		;A = number of columns
	CP	B		;did we print any files?
	CALL	NC,CRLF		;print crlf if so
	LD	HL,ANYFILES
	DEC	(HL)
	INC	(HL)
	RET	Z		;return if no files
	;except those requested
	DEC	(HL)		;set to zero
	JP	PMSGNL		;tell the operator other files exist
;
;
DIRECT:
	PUSH	BC		;save DIR/DIRS flag
	CALL	SBUF80		;set DMA = 80h
	CALL	GFN		;parse file name
	LD	DE,DFCB+1
	LD	A,(DE)
	CP	' '
	LD	B,11
	CALL	Z,SETMATCH	;use "????????.???" if none
	CALL	EOC		;make sure there's nothing else
	CALL	SRCHF		;search for first directory entry
	POP	BC
	RET	Z		;if no files found
DIR0:
	LD	A,(DIRCOLS)	;number of columns for dir
	LD	L,A
	LD	B,A
	INC	B		;set # names to print per line (+1)
DIR1:
	PUSH	HL		;L=#cols, B=curent col, C=dir/dirs
	LD	HL,10		;get byte with SYS bit
	ADD	HL,DE
	LD	A,(HL)
	POP	HL
	AND	80H		;look at SYS bit
	CP	C		;DIR/DIRS flag in C
	JP	Z,DIR2		;display, if modes agree
	LD	A,1		;set anyfiles true
	LD	(ANYFILES),A
	JP	DIR3		;don't print anything
;
;	display the filename
;
DIR2:
	DEC	B
	CALL	Z,DIRLN		;sets no. of columns, puts crlf
	LD	A,B		;number left to print on line
	CP	L		;is current col = number of cols
	CALL	Z,DIRDRV	;display the drive, if so
	LD	A,':'
	CALL	PFC		;print colon
	CALL	LSPACE
	CALL	PFN		;print file name
	CALL	LSPACE		;pad with space
DIR3:
	PUSH	BC		;save current col(B), DIR/DIRS(C)
	PUSH	HL		;save number of columns(L)
	CALL	BREAK		;drop out if keyboard struck
	CALL	SRCHN		;search for another match
	POP	HL
	POP	BC
	JP	NZ,DIR1
DIREX:
	INC	A		;clear zero flag
	RET

	ELSE			;newdir

DIRS:	; display system files only
	LD	A,0D2H		; JNC instruction
	LD	(DIR11),A	; skip on non-system files
;
DIR:	; display non-system files only
	LD	HL,CCPCR
	PUSH	HL		; push return address
	CALL	GFN		;parse file name
	INC	DE
	LD	A,(DE)
	CP	' '
	LD	B,11
	CALL	Z,SETMATCH	;use "????????.???" if none
	CALL	EOC		;make sure there's nothing else
	CALL	FINDONE		;search for first directory entry
	JP	Z,DIR4
	LD	B,5		;set # names to print per line
DIR1:	LD	HL,10		;get byte with SYS bit
	ADD	HL,DE
	LD	A,(HL)
	RLA			;look at SYS bit
DIR11:	JP	C,DIR3		;don't print it if SYS bit set
	LD	A,B
	PUSH	BC
DIR2:	LD	HL,9		;get byte with R/O bit
	ADD	HL,DE
	LD	A,(HL)
	RLA			;look at R/O bit
	LD	A,' '		;print space if not R/O
	JP	NC,DIR21	;jump if not R/O
	LD	A,'*'		;print star if R/O
DIR21:	CALL	PFC		;print character
	CALL	PFN		;print file name
	LD	A,13		;figure out how much padding is needed
	SUB	C
DIR25:	PUSH	AF
	CALL	LSPACE		;pad it out with spaces
	POP	AF
	DEC	A
	JP	NZ,DIR25	;loop if more required
	POP	BC
	DEC	B		;decrement # names left on line
	JP	NZ,DIR3
	CALL	CRLF		;go to new line
	LD	B,5		;set # names to print on new line
DIR3:	PUSH	BC
	CALL	BREAK		;drop out if keyboard struck
	CALL	SRCHN		;search for another match
	POP	BC
	JP	NZ,DIR1

DIR4:	LD	A,0DAH		;JC instruction
	LD	(DIR11),A	;restore normal dir mode (skip system files)
	JP	CCPCR

	ENDIF			;newdir

;;
;;-----------------------------------------------------------------------
;;
;;	TYPE command
;;
;;	TYPE <UFN>	Print the contents of text file <UFN> on
;;			the console.
;;
;;-----------------------------------------------------------------------
;;
TYPE:	LD	HL,CCPCR
	PUSH	HL		;push return address
	CALL	GETFN		;get and parse filename
	LD	A,127		;initialize buffer pointer
	LD	(BUFP),A
	LD	C,OPENF
	CALL	SBDOSF		;open file if a filename was typed
TYPE1:	CALL	BREAK		;exit if keyboard struck
	CALL	GETB		;read byte from file
	RET	NZ		;exit if physical eof or read error
	CP	EOF		;check for eof character
	RET	Z		;exit if so
	CALL	PUTC		;print character on console
	JP	TYPE1		;loop
;
;;-----------------------------------------------------------------------
;;
;;	USER command
;;
;;	USER <NN>	Set the user number
;;
;;-----------------------------------------------------------------------
;;
USER:
	LD	DE,UNMSG	;Enter User #:
	CALL	GETPRM
	CALL	GDN		;convert to binary
	RET	Z		;return if nothing typed
	JP	CCPUSER		;set user number
;
;;-----------------------------------------------------------------------
;;
;;	ERA command
;;
;;	ERA <AFN>	Erase all file on the current user/drive
;;			which match <AFN>.
;;	ERA <X>:<AFN>	Erase all files on user/drive <X> which
;;			match <AFN>.
;;
;;-----------------------------------------------------------------------
;;
ERA:	CALL	GETFN		;get and parse filename
	JP	Z,ERA1
	CALL	CKAFN		;is it ambiguous?
	JP	NZ,ERA1
	LD	DE,ERAMSG
	CALL	PMSG
	LD	HL,(ERRORP)
	LD	C,' '		;stop at exclamation mark or 0
	CALL	PSTRG		;echo command
	LD	DE,CONFIRM
	CALL	GETC
	CALL	CRLF
	LD	A,L		;character in L after CRLF routine
	AND	5FH		;convert to U/C
	CP	'Y'		;Y (yes) typed?
	RET	NZ		;return, if not
	OR	A		;reset zero flag
ERA1:	LD	C,DELF
	JP	SBDOSF

;;-----------------------------------------------------------------------
;;
;;
;;	REN command
;;
;;-----------------------------------------------------------------------
;;
REN:	CALL	GFN		;zero flag set if nothing entered
	PUSH	AF
	LD	HL,16
	ADD	HL,DE
	EX	DE,HL
	PUSH	DE		;DE = .dfcb+16
	PUSH	HL		;HL = .dfcb
	LD	C,16
	CALL	MOVE		;DE = dest, HL = source
	CALL	GFN
	POP	HL		;HL=.dfcb
	POP	DE		;DE=.dfcb+16
	CALL	DRVOK
	LD	C,RENF		;make rename call
	POP	AF		;zero flag set if nothing entered
;
;;-----------------------------------------------------------------------
;;
;;	BUILT-IN COMMAND BDOS CALL & ERROR HANDLERS
;;
;;-----------------------------------------------------------------------
;
SBDOSF:
	PUSH	AF
	CALL	NZ,EOC		;make sure there's nothing else
	POP	AF
	LD	DE,DFCB
	LD	B,0FFH
	LD	H,1		;execute disk command if we don't call
	CALL	NZ,BDOSF	;call if something was entered
	RET	NZ		;return if successful

FERROR:
	DEC	H		;was it an extended error?
	JP	M,NOFILE
	LD	HL,(ERRSAV)
	LD	(PARSEP),HL
TRYCOM:	CALL	EXEC
	CALL	PFN
	LD	DE,REQUIRED
	JP	BUILTIN$ERR
;
;;-----------------------------------------------------------------------
;
;
;	check for drive conflict
;	HL =  FCB
;	DE =  FCB+16
;
DRVOK:	LD	A,(DE)		;get byte from 2nd fcb
	CP	(HL)		;ok if they match
	RET	Z
	OR	A		;ok if 2nd is 0
	RET	Z
	INC	(HL)		;error if the 1st one's not 0
	DEC	(HL)
	JP	NZ,PERROR
	LD	(HL),A		;copy from 2nd to 1st
	RET
;;-----------------------------------------------------------------------
;;
;;	check for ambiguous reference in file name/type
;;
;;	entry:	b  = length of string to check (ckafn0)
;;		de = fcb area to check (ckafn0) - 1
;;	exit:	z  = set if any ? in file reference (ambiguous)
;;		z  = clear if unambiguous file reference
;;
CKAFN:
	LD	B,11		;check entire name and type
CKAFN0:	INC	DE
	LD	A,(DE)
	CP	'?'		;is it an ambiguous file name
	IF	NEWERA
	RET	Z		;return true if any afn
	ELSE	;newera
	RET	NZ		;return true only if *.*
	ENDIF	;newera
	DEC	B
	JP	NZ,CKAFN0
	IF	NEWERA
	DEC	B		;clear zero flag to return false
	ENDIF	;newera
	RET			;remove above DCR to return true
;;
;;-----------------------------------------------------------------------
;;
;;	get parameter (generally used to get a missing one)
;;
GETPRM:
	CALL	SKPS		;see if already there
	RET	NZ		;return if so
GETP0:
	IF	PROMPTS
	PUSH	DE
	LD	DE,ENTER
	CALL	PMSG
	POP	DE
	ENDIF
	CALL	PMSG		;print prompt
	CALL	RCLN		;get response
	JP	UC		;convert to upper case
;
;;
;;-----------------------------------------------------------------------
	IF	NOT NEWDIR
;;
;;	search for first file, print "No File" if none
;;
FINDONE:
	CALL	SRCHF
	RET	NZ		;found
	ENDIF			;not newdir
;;-----------------------------------------------------------------------

NOFILE:
	LD	DE,NOMSG	;tell user no file found
BUILTIN$ERR:
	CALL	PMSGNL
	JP	CCPRET

;
;
;************************************************************************
;
;	EXECUTE DISK RESIDENT COMMAND
;
;************************************************************************
;
;
XFCB:	DEFB	0,'SUBMIT  COM'	;processor fcb
;
;
;	execute submit file  (or any other processor)
;
XSUB:	;DE = .fcb
	LD	A,(DE)
	LD	B,CLP$DRV
	CALL	SETBYTE		;save submit file drive
	LD	HL,XFCB
	LD	C,12
	CALL	MOVE		;copy processor into fcb
	LD	HL,CBUFL	;set parser pointer back to beginning
	LD	(HL),' '
	INC	HL		;move past blank
	LD	(PARSEP),HL
;				 execute SUBMIT.COM
;
;
;	execute disk resident command (return if not found or error)
;
EXEC:
	;try to open and execute fcb
	LD	DE,FCB+9
	LD	HL,TYPTBL
	CALL	TBLS		;search for type in type table
	RET	NZ		;return if no match
	LD	DE,UFCB
	LD	A,(DE)		;check to see if user specified
	OR	A
	RET	NZ		;return if so
	INC	DE
	LD	A,(DE)		;check if drive specified
	LD	C,A
	PUSH	BC		;save type (B) and drive (C)
	LD	C,0		;try only 1 open if drive specified
	OR	A
	JP	NZ,EXEC1	;try to open as specified
	LD	BC,(DRV0-1)*256+4;try upto four opens from drv chain
	LD	A,(DISK)
	INC	A
	LD	H,A		;save default disk in H
	LD	L,1		;allow only 1 match to default disk
EXEC0:	INC	B		;next drive to try in SCB drv chain
	DEC	C		;any more tries?
	LD	A,C
	PUSH	HL
	CALL	P,GETBYTE
	POP	HL
	OR	A
	JP	M,EXEC3
	JP	Z,EXEC01	;jump if drive is 0 (default drive)
	CP	H		;is it the default drive
	JP	NZ,EXEC02	;jump if not
EXEC01:	LD	A,H		;set drive explicitly
	DEC	L		;is it the 2nd reference
	JP	M,EXEC0		;skip, if so
EXEC02:	LD	(DE),A		;put drive in FCB
EXEC1:	PUSH	BC		;save drive offset(B) & count(C)
	PUSH	HL
	CALL	OPENCOM		;on default drive & user
	POP	HL
	POP	BC
	JP	Z,EXEC0		;try next if open unsuccessful
;
;	successful open, now jump to processor
;
EXEC2:
	IF	DAYFILE
	LD	BC,DISPLAY
	CALL	GETFLG
	JP	Z,EXEC21
	LD	A,(DE)
	CALL	DIRDRV0
	LD	A,':'
	CALL	PFC
	PUSH	DE
	CALL	PFN
	POP	DE
	PUSH	DE
	LD	HL,8
	ADD	HL,DE
	LD	A,(HL)
	AND	80H
	LD	DE,USERZERO
	CALL	NZ,PMSG
	CALL	CRLF
	POP	DE
	ENDIF			;dayfile
EXEC21:	POP	AF		;recover saved command type
	LD	HL,XPTBL
;
;	table jump
;
;	entry:	hl = address of table of addresses
;		a  = entry # (0 thru n-1)
;
TBLJ:	ADD	A,A		;adjust for two byte entries
	CALL	ADDHLA		;compute address of entry
	PUSH	DE
	LD	E,(HL)		;fetch entry
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	POP	DE
	JP	(HL)		;jump to it
;
TYPTBL:	DEFB	'COM '
	DEFB	'SUB '
	DEFB	'PRL '
	DEFB	0
;
XPTBL:	DEFW	XCOM
	DEFW	XSUB
	DEFW	XCOM


;
;	unsuccessful attempt to open command file
;
EXEC3:	POP	BC		;recover drive
	LD	A,C
	LD	(DE),A		;replace in fcb
	RET
;
;
SETTYPE:
	;set file type specified from type table
	;a = offset (x2) of desired type (in bytes)
	RRCA
	LD	HL,TYPTBL
	CALL	ADDHLA		;hl = type in type table
	LD	DE,FCB+9
	LD	C,3
	JP	MOVE		;move type into fcb
;
;
;
;	EXECUTE COM FILE
;
XCOM:	;DE = .fcb
	;
	;	set up FCB for loader to use
	;
	LD	HL,TPA
	LD	(FCBRR),HL	;set load address to 100h
	LD	HL,(REALDOS-1)	;put fcb in the loader's stack
	DEC	H		;page below LOADER (or bottom RSX)
	LD	L,0C0H		;offset for FCB in page below the BDOS
	PUSH	HL		;save for LOADER call
	LD	A,(DE)		;get drive from fcb(0)
	LD	(CMDRV),A	;set command drive field in base page
	EX	DE,HL
	LD	C,35
	CALL	MOVE		;now move FCB to the top of the TPA
	;
	;	set up base page
	;
	LD	HL,ERRFLG	;tell parser to ignore errors
	INC	(HL)
XCOM3:	LD	HL,(PARSEP)
	DEC	HL		;backup over delimiter
	LD	DE,BUF+1
	EX	DE,HL
	LD	(PARSEP),HL	;set parser to 81h
	CALL	COPY0		;copy command tail to 81h with
	;terminating 0 (returns A=length)
	LD	(BUF),A		;put command tail length at 80h
XCOM5:	CALL	GFN		;parse off first argument
	LD	(PASS0),HL
	LD	A,B
	LD	(LEN0),A
	LD	DE,DFCB1
	CALL	GFN0		;parse off second argument
	LD	(PASS1),HL
	LD	A,B
	LD	(LEN1),A
XCOM7:	LD	HL,CHAINDSK	;.CHAINDSK
	LD	A,(HL)
	OR	A
	CALL	P,SELECT
	LD	A,(USERNUM)
	CALL	SETUSER		;set default user, returns H=SCB
	ADD	A,A		;shift user to high nibble
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	L,SELDSK
	OR	(HL)		;put disk in low nibble
	LD	(DEFDRV),A	;set location 4
	;
	; 	initialize stack
	;
XCOM8:	POP	DE		;DE = .fcb
	LD	HL,(REALDOS-1)	;base page of BDOS
	XOR	A
	LD	L,A		;top of stack below BDOS
	LD	SP,HL		;change the stack pointer for CCP
	LD	H,A		;push warm start address on stack
	PUSH	HL		;for programs returning to the CCP
	INC	H		;Loader will return to TPA
	PUSH	HL		;after loading a transient program
	;
	;	initialize fcb0(CR), console mode, program return code
	;	& removable media open and login vectors
	;
XCOM9:	LD	(7CH),A		;clear next record to read
	LD	B,CON$MODE
	CALL	SETBYTE		;set to zero (turn off ^C status)
	LD	L,OLOG
	LD	(HL),A		;zero removable open login vector
	INC	HL
	LD	(HL),A
	INC	HL
	LD	(HL),A		;zero removable media login vector
	INC	HL
	LD	(HL),A
	LD	L,CCPFLAG1
	LD	A,(HL)
	AND	CHAINFLG	;chaining?
	JP	NZ,LOADER	;load program without clearing
	LD	L,PROG$RET$CODE	;the program return code
	LD	(HL),A		;A=0
	INC	HL
	LD	(HL),A		;set program return = 0000h
	;
	;	call loader
	;
LOADER:
	LD	A,(HL)		;reset chain flag if set,
	AND	NOT$CHAINFLG	;has no effect if we fell through
	LD	(HL),A
	LD	C,LOADF		;use load RSX to load file
	JP	BDOS		;now load it
;
;
;
;
;************************************************************************
;
;	BDOS FUNCTION INTERFACE - Non FCB functions
;
;************************************************************************
;
;
;
;;-----------------------------------------------------------------------
;;
;;
;;
;;	print character on terminal
;;	pause if screen is full
;;	(BDOS function #2)
;;
;;	entry:	a  = character (putc entry)
;;		e  = character (putc2 entry)
;;

PUTC:	CP	LF		;end of line?
	JP	NZ,PUTC1	;jump if not
	LD	HL,PGSIZE	;.pgsize
	LD	A,(HL)		;check page size
	INC	HL		;.line
	INC	(HL)		;line=line+1
	SUB	(HL)		;line=page?
	JP	NZ,PUTC0
	LD	(HL),A		;reset line=0 if so
	INC	HL		;.pgmode
	LD	A,(HL)		;is page mode off?
	OR	A		;page=0 if so
	LD	DE,MORE
	CALL	Z,GETC		;wait for input if page mode on
	CP	CTRLC
	JP	Z,CCPCR
	LD	E,CR
	CALL	PUTC2		;print a cr
PUTC0:	LD	A,LF		;print the end of line char
PUTC1:	LD	E,A
PUTC2:	LD	C,COUTF
	JP	BDOS

;;
;;-----------------------------------------------------------------------
;;
;;	get character from console
;;	(BDOS function #1)
;;
GETC:	CALL	PMSG
GETC1:	LD	C,CINF
	JP	BDOS
;;
;;-----------------------------------------------------------------------
;;
;;	print message string on terminal
;;	(BDOS function #9)
;;
PMSG:	LD	C,PBUFF
	JP	BDOS
;;
;;-----------------------------------------------------------------------
;;
;;	read line from console
;;	(calls BDOS function #10)
;;
;;	exit:	z  = set if null line
;;
;;	This function uses the buffer "cbuf" (see definition of
;;	function 10 for a description of the buffer).  All input
;;	is converted to upper case after reading and the pointer
;;	"parsep" is set to the begining of the first non-white
;;	character string.
;;
RCLN:	LD	HL,CBUFMX	;get line from terminal
	LD	(HL),COMLEN	;set maximum buffer size
	EX	DE,HL
	LD	C,RBUFF
	CALL	BDOS
	LD	HL,CBUFL	;terminate line with zero byte
	LD	A,(HL)
	INC	HL
	CALL	ADDHLA
	LD	(HL),0		;put zero at the end
	JP	CRLF		;advance to next line
;
;;
;;-----------------------------------------------------------------------
;;
;;	exit routine if keyboard struck
;;	(calls BDOS function #11)
;;
;;	Control is returned to the caller unless the console
;;	keyboard has a character ready, in which case control
;;	is transfer to the main program of the CCP.
;;
BREAK:	CALL	BREAK1
	RET	Z
	JP	CCPCR

BREAK1:	LD	C,CSTATF
	CALL	RW
	RET	Z
	LD	C,CINF
	JP	RW


;;
;;-----------------------------------------------------------------------
;;
;;	set disk buffer address
;;	(BDOS function #26)
;;
;;	entry:	de -> buffer ("setbuf" only)
;;
SBUF80:	LD	DE,BUF
SETBUF:	LD	C,DMAF
	JP	BDOS
;;
;;-----------------------------------------------------------------------
;;
;;	select disk
;;	(BDOS function #14)
;;
;;	entry:	a  = drive
;;
SELECT:
	LD	E,A
	LD	C,SELF
	JP	BDOS
;
;;
;;-----------------------------------------------------------------------
;;
;;	set user number
;;	(BDOS function #32)
;;
;;	entry:	a  = user #
;;	exit:	H  = SCB page
;;
SETUSER:
	LD	B,USRCODE
	JP	SETBYTE
;
;
;
;************************************************************************
;
;	BDOS FUNCTION INTERFACE - Functions with a FCB Parameter
;
;************************************************************************
;
;
;;
;;	open file
;;	(BDOS function #15)
;;
;;	exit:	z  = set if file not found
;;
;;
OPENCOM:;open command file (SUB, COM or PRL)
	LD	BC,OPENF	;b=0 => return error mode of 0
	LD	DE,FCB		;use internal FCB

;;	BDOS CALL ENTRY POINT   (used by built-ins)
;;
;;	entry:	b  = return error mode (must be 0 or 0ffh)
;;		c  = function no.
;;		de = .fcb
;;	exit:	z  = set if error
;;		de = .fcb
;;
BDOSF:	LD	HL,32		;offset to current record
	ADD	HL,DE		;HL = .current record
	LD	(HL),0		;set to zero for read/write
	PUSH	BC		;save function(C) & error mode(B)
	PUSH	DE		;save .fcb
	LD	A,(DE)		;was a disk specified?
	AND	B		;and with 0 or 0ffh
	DEC	A		;if so, select it in case
	CALL	P,SELECT	;of permanent error (if errmode = 0ffh)
	LD	DE,PASSWD
	CALL	SETBUF		;set dma to password
	POP	DE		;restore .fcb
	POP	BC		;restore function(C) & error mode(B)
	PUSH	DE
	LD	HL,(SCBADDR)
	LD	L,ERRORMODE
	LD	(HL),B		;set error mode
	PUSH	HL		;save .errormode
	CALL	BDOS
	POP	DE		;.errormode
	XOR	A
	LD	(DE),A		;reset error mode to 0
	LD	A,(DISK)
	LD	E,SELDSK
	LD	(DE),A		;reset current disk to default
	PUSH	HL		;save bdos return values
	CALL	SBUF80
	POP	HL		;bdos return
	INC	L		;set z flag if error
	POP	DE		;restore .fcb
	RET
;;
;;-----------------------------------------------------------------------
;;
;;	close file
;;	(BDOS function #16)
;;
;;	exit:	z  = set if close error
;;
;;close:	mvi	c,closef
;;		jmp	oc
;;
;;-----------------------------------------------------------------------
;;
;;	delete file
;;
;;	exit:	z  = set if file not found
;;
;;	The match any character "?" may be used without restriction
;;	for this function.  All matched files will be deleted.
;;
;;
;;delete:
;;	mvi	c,delf
;;	jmp	oc
;;
;;-----------------------------------------------------------------------
;;
;;	create file
;;	(BDOS function #22)
;;
;;	exit:	z  = set if create error
;;
;;make:		mvi	c,makef
;;		jmp	oc
;;-----------------------------------------------------------------------
;;
;;	search for first filename match (using "DFCB" and "BUF")
;;	(BDOS function #17)
;;
;;	exit:	z  = set if no match found
;;		z  = clear if match found
;;		de -> directory entry in buffer
;;
SRCHF:	LD	C,SEARF		;set search first function
	JP	SRCH
;;
;;-----------------------------------------------------------------------
;;
;;	search for next filename match (using "DFCB" and "BUF")
;;	(BDOS function #18)
;;
;;	exit:	z  = set if no match found
;;		z  = clear if match found
;;		de -> directory entry in buffer
;;
SRCHN:	LD	C,SEARNF	;set search next function
SRCH:	LD	DE,DFCB		;use default fcb
	CALL	BDOS
	INC	A		;return if not found
	RET	Z
	DEC	A		;restore original return value
	ADD	A,A		;shift to compute buffer pos'n
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	HL,BUF		;add to buffer start address
	CALL	ADDHLA
	EX	DE,HL		;de -> entry in buffer
	XOR	A		;may be needed to clear z flag
	DEC	A		;depending of value of "buf"
	RET
;;
;;-----------------------------------------------------------------------
;;
;;	read file
;;	(BDOS function #20)
;;
;;	entry:	hl = buffer address (readb only)
;;	exit	z  = set if read ok
;;
READ:	XOR	A		;clear getc pointer
	LD	(BUFP),A
	LD	C,READF
	LD	DE,DFCB
RW:	CALL	BDOS
	OR	A
	RET
;
;;
;;-----------------------------------------------------------------------
;;
;;	$$$.SUB interface
;;
;;	entry:	c = bdos function number
;;	exit	z  = set if successful

SUDOS:	LD	DE,SUBFCB
	JP	RW
;
;
;
;************************************************************************
;
;	COMMAND LINE PARSING SUBROUTINES
;
;************************************************************************
;
;------------------------------------------------------------------------
;
;	COMMAND LINE PREPARSER
;	reset function 10 flag
;	set up parser
;	convert to upper case
;
;	All input is converted to upper case and the pointer
;	"parsep" is set to the begining of the first non-blank
;	character string.  If the line begins with a ; or :, it
;	is treated specially:
;
;		;	comment 	the line is ignored
;		:	conditional	the line is ignored if a fatal
;					error occured during the previous
;					command, otherwise the : is
;					ignored
;
;	An exclamation point is used to separate multiple commands on a
;	a line.  Two adjacent exclaimation points translates into a single
;	exclaimation point in the command tail for compatibility.
;------------------------------------------------------------------------
;
;
UC:
	CALL	RESETCCPFLG
	EX	DE,HL		;DE = .SCB
	XOR	A
	LD	(OPTION),A	;zero option flag
	LD	HL,CBUF
	CALL	SKPS1		;skip leading spaces/tabs
	EX	DE,HL
	CP	';'		;HL = .scb
	RET	Z
	CP	'!'
	JP	Z,UC0
	CP	':'
	JP	NZ,UC1
;
;[JCE] this fragment rewritten not to trash the program return code when
;      reading it.
;
	LD	L,PROG$RET$CODE
	LD	A,(HL)		;[JCE]
	INC	A		;[JCE]
	INC	A		;[JCE]
;;;	inr	m
;;;	inr	m		;was ^C typed? (low byte 0FEh)
	JP	Z,UC0		;successful, if so
	INC	HL
	LD	A,(HL)		;[JCE]
	INC	A		;[JCE]
;;;	inr	m		;is high byte 0FFh?
	RET	Z		;skip command, if so
UC0:	INC	DE		;skip over 1st character
UC1:	EX	DE,HL		;HL=.command line
	LD	(PARSEP),HL	;set parse pointer to beginning of line
UC3:	LD	A,(HL)		;convert lower case to upper
	CP	'['
	JP	NZ,UC4
	LD	(OPTION),A	;'[' is the option delimiter => command option
UC4:	CP	'a'
	JP	C,UC5
	CP	'z'+1
	JP	NC,UC5
	SUB	'a'-'A'
	LD	(HL),A
UC5:
	IF	MULTI
	CP	'!'
	CALL	Z,MULTISTART	;HL=.char, A=char
	ENDIF			;multi
	INC	HL		;advance to next character
	OR	A		;loop if not end of line
	JP	NZ,UC3
;
;	skip spaces
;	return with zero flag set if end of line
;
SKPS:	LD	HL,(PARSEP)	;get current position
SKPS1:	LD	(PARSEP),HL	;save position
	LD	(ERRORP),HL	;save position for error message
	LD	A,(HL)
	OR	A		;return if end of command
	RET	Z
	CP	' '
	JP	Z,SKPS2
	CP	TAB		;skip spaces & tabs
	RET	NZ
SKPS2:	INC	HL		;advance past space/tab
	JP	SKPS1		;loop
;
;-----------------------------------------------------------------------
;
;	MULTIPLE COMMANDS PER LINE HANDLER
;
;-----------------------------------------------------------------------
	IF	MULTI

MULTISTART:
	;
	;	A  = current character in command line
	;	HL = address of current character in command line
	;
	;double exclaimation points become one
	LD	E,L
	LD	D,H
	INC	DE
	LD	A,(DE)
	CP	'!'		;double exclaimation points
	PUSH	AF
	PUSH	HL
	CALL	Z,COPY0		;convert to one, if so
	POP	HL
	POP	AF
	RET	Z
	;we have a valid multiple command line
	LD	(HL),0		;terminate command line here
	EX	DE,HL
	;multiple commands not allowed in submits
	;NOTE: submit unravels multiple commands making the
	;following test unnecessary.  However, with GET[system]
	;or CP/M 2.2 SUBMIT multiple commands will be posponed
	;until the entire submit completes...
;	call	subtest		;submit active
;	mvi	a,0
;	rnz			;return with A=0, if so
	;set up the RSX buffer
	LD	HL,(OSBASE)	;get high byte of TPA address
	DEC	H		;subtract 1 page for buffer
	LD	L,ENDCHAIN	;HL = RSX buffer base-1
	LD	(HL),A		;set end of chain flag to 0
	PUSH	HL		;save it
MULTI0:	INC	HL
	INC	DE
	LD	A,(DE)		;get character from cbuf
	LD	(HL),A		;place in RSX
	CP	'!'
	JP	NZ,MULTI1
	LD	(HL),CR		;change exclaimation point to cr
MULTI1:	OR	A
	JP	NZ,MULTI0
	LD	(HL),CR		;end last command with cr
	INC	HL
	LD	(HL),A		;terminate with a zero
	;set up RSX prefix
	LD	L,6		;entry point
	LD	(HL),0C3H	;put a jump instruction there
	INC	HL
	LD	(HL),9		;make it a jump to base+9 (RSX exit)
	INC	HL
	LD	(HL),H
	INC	HL		;HL = RSX exit point
	LD	(HL),0C3H	;put a jump instruction there
	LD	L,WARMFLG	;HL = remove on warm start flag
	LD	(HL),A		;set (0) for RSX to remain resident
	LD	L,A		;set low byte to 0 for fixchain
	EX	DE,HL		;DE = RSX base
	CALL	FIXCHAIN	;add the RSX to the chain
	;save buffer address
	LD	HL,(SCBADDR)
	LD	L,CCPCONBUF	;save buffer address in CCP conbuf field
	POP	DE		;DE = RSX base
	INC	DE
	LD	(HL),E
	INC	HL
	LD	(HL),D
	LD	L,MULTI$RSX$PG
	LD	(HL),D		;save the RSX base
	XOR	A		;zero in a to fall out of uc
	RET
	;
	;
	;	save the BDOS conbuffer address and
	;	terminate RSX if necessary.
	;
MULTISAVE:
	LD	DE,CONBUFFER*256+CCPCONBUF
	CALL	WORDMOV		;first copy conbuffer in case SUBMIT
	OR	A		;and/or GET are active
	LD	DE,CONBUFFL*256+CCPCONBUF
	CALL	Z,WORDMOV	;if conbuff is zero then conbufl has the
	PUSH	HL		;next address
	CALL	BREAK1
	POP	HL		;H = SCB page
	LD	L,CCPCONBUF
	JP	NZ,MULTIEND
	LD	E,(HL)
	INC	HL
	LD	D,(HL)		;DE = next conbuffer address
	INC	(HL)
	DEC	(HL)		;is high byte zero?
	DEC	HL		;HL = .ccpconbuf
	JP	Z,MULTIEND	;remove multicmd RSX if so
	LD	A,(DE)		;check for terminating zero
	OR	A
	RET	NZ		;return if not
	;
	;	we have exhausted all the commands
MULTIEND:
	;	HL = .ccpconbuf
	XOR	A
	LD	(HL),A		;set buffer to zero
	INC	HL
	LD	(HL),A
	LD	L,MULTI$RSX$PG
	LD	H,(HL)
	LD	L,0EH		;HL=RSX remove on warmstart flag
	DEC	(HL)		;set to true for removal
	JP	RSX$CHAIN	;remove the multicmd rsx buffer

	ENDIF			;multi
;;
;************************************************************************
;
;	FILE NAME PARSER
;
;************************************************************************
;
;
;
;	get file name (read in if none present)
;
;
;;	The file-name parser in this CCP implements
;;	a user/drive specification as an extension of the normal
;;	CP/M drive selection feature.  The syntax of the
;;	user/drive specification is given below.  Note that a
;;	colon must follow the user/drive specification.
;;
;;	<a>:	<a> is an alphabetic character A-P specifing one
;;		of the CP/M disk drives.
;;
;;	<n>:	<n> is a decimal number 0-15 specifying one of the
;;		user areas.
;;
;;	<n><a>:	A specification of both user area and drive.
;;
;;	<a><n>:	Synonymous with above.
;;
;;	Note that the user specification cannot be included
;;	in the parameters of transient programs or precede a file
;;	name.  The above syntax is parsed by gcmd (get command).
;;
;; ************************************************************

GETFN:
	IF	PROMPTS
	LD	DE,FNMSG
GETFN0:
	CALL	GETPRM
	ENDIF			;prompts
GFN:	LD	DE,DFCB
GFN0:	CALL	SKPS		;sets zero flag if eol
	PUSH	AF
	CALL	GFN2
	POP	AF
	RET
	;
	;	BDOS FUNCTION 152 INTERFACE
	;
	;entry:	DE = .FCB
	;	HL = .buffer
	;flags/A reg preserved
	;exit:  DE = .FCB
	;
	;
GFN2:	LD	(PARSEP),HL
	LD	(ERRORP),HL
	PUSH	DE		;save .fcb
	LD	DE,PFNCB
	LD	C,PARSEF
	IF	FUNC152
	CALL	BDOS
	ELSE	;func152
	CALL	PARSE
	ENDIF	;func152
	POP	DE		;.fcb
	LD	A,H
	OR	L		;end of command? (HL = 0)
	LD	B,(HL)		;get delimiter
	INC	HL		;move past delimiter
	JP	NZ,GFN3
	LD	HL,ZERO+2	;set HL = .0
GFN3:	LD	A,H
	OR	L		;parse error? (HL = 0ffffh)
	JP	NZ,GFN4
	LD	HL,ZERO+2
	CALL	PERROR
GFN4:	LD	A,B
	CP	'.'
	JP	NZ,GFN6
	DEC	HL
GFN6:	LD	(PARSEP),HL	;update parse pointer
GFNPWD:	LD	C,16
	LD	HL,PFCB
	PUSH	DE
	CALL	MOVE
	LD	DE,PASSWD	;HL = .disk map in pfcb
	LD	C,10
	CALL	MOVE		;copy to passwd
	POP	DE		;HL = .password len
	LD	A,(HL)
ZERO:	LD	HL,0		;must be an "lxi h,0"
	OR	A		;is there a password?
	LD	B,A
	JP	Z,GFN8
	LD	HL,(ERRORP)	;HL = .filename
GFN7:	LD	A,(HL)
	CP	';'
	INC	HL
	JP	NZ,GFN7
GFN8:	RET			;B = len, HL = .password

;
;	PARSE CP/M 3 COMMAND
;	entry:	DE  = .UFCB  (user no. byte in front of FCB)
;		PARSEP = .command line
GCMD:
	PUSH	DE
	XOR	A
	LD	(DE),A		;clear user byte
	INC	DE
	LD	(DE),A		;clear drive byte
	INC	DE
	CALL	SKPS		;skip leading spaces
;
;	Begin by looking for user/drive-spec.  If none if found,
;	fall through to main file-name parsing section.  If one is found
;	then branch to the section that handles them.  If an error occurs
;	in the user/drive spec; treat it as a filename for compatibility
;	with CP/M 2.2.  (e.g. STAT VAL: etc.)
;
	LD	HL,(PARSEP)	;get pointer to current parser position
	POP	DE
	PUSH	DE		;DE = .UFCB
	LD	B,4		;maximum length of user/drive spec
GCMD1:	LD	A,(HL)		;get byte
	CP	':'		;end of user/drive-spec?
	JP	Z,GCMD2		;parse user/drive if so
	OR	A		;end of command?
	JP	Z,GCMD8		;parse filename (Func 152), if so
	CP	9		;[JCE] Patch 12, bug in "P B:" type commands
	JP	Z,GCMD8		;[JCE]
	CP	' '		;[JCE]
	JP	Z,GCMD8		;[JCE]
	DEC	B		;maximum user/drive spec length exceeded?
	INC	HL
	JP	NZ,GCMD1	;loop if not
	;
	;	Parse filename, type and password
	;
GCMD8:
	POP	DE
	XOR	A
	LD	(DE),A		;set user = default
	LD	HL,(PARSEP)
GCMD9:	INC	DE		;past user number byte
	LD	A,(DE)		;A=drive
	PUSH	AF
	CALL	GFN2		;BDOS function 152 interface
	POP	AF
	LD	(DE),A
	RET
	;
	;	Parse the user/drive-spec
	;
GCMD2:
	LD	HL,(PARSEP)	;get pointer to beginning of spec
	LD	A,(HL)		;get character
GCMD3:	CP	'0'		;check for user number
	JP	C,GCMD4		;jump if not numeric
	CP	'9'+1
	JP	NC,GCMD4
	CALL	GDNS		;get the user # (returned in B)
	POP	DE
	PUSH	DE
	LD	A,(DE)		;see if we already have a user #
	OR	A
	JP	NZ,GCMD8	;skip if we do
	LD	A,B		;A = specified user number
	INC	A		;save it as the user-spec
	LD	(DE),A
	JP	GCMD5
GCMD4:	CP	'A'		;check for drive-spec
	JP	C,GCMD8		;skip if not a valid drive character
	CP	'P'+1
	JP	NC,GCMD8
	POP	DE
	PUSH	DE
	INC	DE
	LD	A,(DE)		;see if we already have a drive
	OR	A
	JP	NZ,GCMD8	;skip if so
	LD	A,(HL)
	SUB	'@'		;convert to a drive-spec
	LD	(DE),A
	INC	HL
GCMD5:	LD	A,(HL)		;get next character
	CP	':'		;end of user/drive-spec?
	JP	NZ,GCMD3	;loop if not
	INC	HL
	POP	DE		;.ufcb
	JP	GCMD9		;parse the file name


;
;************************************************************************
;
;		TEMPORARY PARSE CODE
;
;************************************************************************
;
	IF NOT FUNC152
;	version 3.0b  Oct 08 1982 - Doug Huskey
;
;

PASSWORDS EQU	TRUE

PARSE:	; DE->.(.filename,.fcb)
	;
	; filename = [d:]file[.type][;password]
	;
	; fcb assignments
	;
	;   0     => drive, 0 = default, 1 = A, 2 = B, ...
	;   1-8   => file, converted to upper case,
	;            padded with blanks (left justified)
	;   9-11  => type, converted to upper case,
	;	     padded with blanks (left justified)
	;   12-15 => set to zero
	;   16-23 => password, converted to upper case,
	;	     padded with blanks
	;   26    => length of password (0 - 8)
	;
	; Upon return, HL is set to FFFFH if DE locates
	;            an invalid file name;
	; otherwise, HL is set to 0000H if the delimiter
	;            following the file name is a 00H (NULL)
	; 	     or a 0DH (CR);
	; otherwise, HL is set to the address of the delimiter
	;            following the file name.
	;
	EX	DE,HL
	LD	E,(HL)		;get first parameter
	INC	HL
	LD	D,(HL)
	PUSH	DE		;save .filename
	INC	HL
	LD	E,(HL)		;get second parameter
	INC	HL
	LD	D,(HL)
	POP	HL		;DE=.fcb  HL=.filename
	EX	DE,HL
PARSE0:
	PUSH	HL		;save .fcb
	XOR	A
	LD	(HL),A		;clear drive byte
	INC	HL
	LD	BC,20H*256+11
	CALL	PAD		;pad name and type w/ blanks
	LD	BC,4
	CALL	PAD		;EXT, S1, S2, RC = 0
	LD	BC,20H*256+8
	CALL	PAD		;pad password field w/ blanks
	LD	BC,12
	CALL	PAD
	CALL	SKIP
;
;	check for drive
;
	LD	A,(DE)
	CP	':'		;is this a drive?
	DEC	DE
	POP	HL
	PUSH	HL		;HL = .fcb
	JP	NZ,PARSE$NAME
;
;	Parse the drive-spec
;
PARSEDRV:
	LD	A,(DE)		;get character
	AND	5FH		;convert to upper case
	SUB	'A'
	JP	C,PERR1
	CP	16
	JP	NC,PERR1
	INC	DE
	INC	DE		;past the ':'
	INC	A		;set drive relative to 1
	LD	(HL),A		;store the drive in FCB(0)
;
;	Parse the file-name
;
PARSE$NAME:
	INC	HL		;HL = .fcb(1)
	CALL	DELIM
	JP	Z,PARSE$OK
	IF PASSWORDS
	LD	BC,7*256
	ELSE	;passwords
	LD	B,7
	ENDIF	;passwords
PARSE6:	LD	A,(DE)		;get a character
	CP	'.'		;file-type next?
	JP	Z,PARSE$TYPE	;branch to file-type processing
	CP	';'
	JP	Z,PARSEPW
	CALL	GFC		;process one character
	JP	NZ,PARSE6	;loop if not end of name
	JP	PARSE$OK
;
;	Parse the file-type
;
PARSE$TYPE:
	INC	DE		;advance past dot
	POP	HL
	PUSH	HL		;HL =.fcb
	LD	BC,9
	ADD	HL,BC		;HL =.fcb(9)
	IF PASSWORDS
	LD	BC,2*256
	ELSE	;passwords
	LD	B,2
	ENDIF	;passwords
PARSE8:	LD	A,(DE)
	CP	';'
	JP	Z,PARSEPW
	CALL	GFC		;process one character
	JP	NZ,PARSE8	;loop if not end of type
;
PARSE$OK:
	POP	BC
	PUSH	DE
	CALL	SKIP
	CALL	DELIM
	POP	HL
	RET	NZ
	LD	HL,0
	OR	A
	RET	Z
	CP	CR
	RET	Z
	EX	DE,HL
	RET
;
;	handle parser error
;
PERR:
	POP	BC		;throw away return addr
PERR1:
	POP	BC
	LD	HL,0FFFFH
	RET
;
IF	PASSWORDS
;
;	Parse the password
;
PARSEPW:
	INC	DE
	POP	HL
	PUSH	HL
	LD	BC,16
	ADD	HL,BC
	LD	BC,7*256+1
PARSEPW1:
	CALL	GFC
	JP	NZ,PARSEPW1
	LD	A,7
	SUB	B
	POP	HL
	PUSH	HL
	LD	BC,26
	ADD	HL,BC
	LD	(HL),A
	LD	A,(DE)		;delimiter in A
	JP	PARSE$OK
ELSE
;
;	skip over password
;
PARSEPW:
	INC	DE
	CALL	DELIM
	JP	NZ,PARSEPW
	JP	PARSE$OK
ENDIF	;passwords
;
;	get next character of name, type or password
;
GFC:	CALL	DELIM		;check for end of filename
	RET	Z		;return if so
	CP	' '		;check for control characters
	INC	DE
	JP	C,PERR		;error if control characters encountered
	INC	B		;error if too big for field
	DEC	B
	JP	M,PERR
IF	PASSWORDS
	INC	C
	DEC	C
	JP	NZ,GFC1
ENDIF
	CP	'*'		;trap "match rest of field" character
	JP	Z,SETWILD
GFC1:	LD	(HL),A		;put character in fcb
	INC	HL
	DEC	B		;decrement field size counter
	OR	A		;clear zero flag
	RET
;;
SETWILD:
	LD	(HL),'?'	;set match one character
	INC	HL
	DEC	B
	JP	P,SETWILD
	RET
;
;	skip spaces
;
SKIP0:	INC	DE
SKIP:	LD	A,(DE)
	CP	' '		;skip spaces & tabs
	JP	Z,SKIP0
	CP	TAB
	JP	Z,SKIP0
	RET
;
;	check for delimiter
;
;	entry:	A = character
;	exit:	z = set if char is a delimiter
;
DELIMITERS: DEFB	CR,TAB,' .,:;[]=<>|',0

DELIM:	LD	A,(DE)	;get character
	PUSH	HL
	LD	HL,DELIMITERS
DELIM1:	CP	(HL)		;is char in table
	JP	Z,DELIM2
	INC	(HL)
	DEC	(HL)		;end of table? (0)
	INC	HL
	JP	NZ,DELIM1
	OR	A		;reset zero flag
DELIM2:	POP	HL
	RET	Z
	;
	;	not a delimiter, convert to upper case
	;
	CP	'a'
	RET	C
	CP	'z'+1
	JP	NC,DELIM3
	AND	05FH
DELIM3:	AND	07FH
	RET			;return with zero set if so
;
;	pad with blanks
;
PAD:	LD	(HL),B
	INC	HL
	DEC	C
	JP	NZ,PAD
	RET
;
ENDIF
;
;
;************************************************************************
;
;	SUBROUTINES
;
;************************************************************************
;
	IF	MULTI
;
;	copy SCB memory word
;	d = source offset e = destination offset
;
WORDMOV:
	LD	HL,(SCBADDR)
	LD	L,D
	LD	D,H
	LD	C,2
;
	ENDIF			;multi
;
;	copy memory bytes
;	de = destination  hl = source  c = count
;
MOVE:
	LD	A,(HL)
	LD	(DE),A		;move byte to destination
	INC	HL
	INC	DE		;advance pointers
	DEC	C		;loop if non-zero
	JP	NZ,MOVE
	RET
;
;	copy memory bytes with terminating zero
;	hl = destination  de = source
;	returns c=length

COPY0:	LD	C,0
COPY1:	LD	A,(DE)
	LD	(HL),A
	OR	A
	LD	A,C
	RET	Z
	INC	HL
	INC	DE
	INC	BC
	JP	COPY1

;;
;;-----------------------------------------------------------------------
;;
;;	get byte from file
;;
;;	exit:	z  = set if byte gotten
;;		a  = byte read
;;		z  = clear if error or eof
;;		a  = return value of bdos read call
;;
GETB:	XOR	A		;clear accumulator
	LD	HL,BUFP		;advance buffer pointer
	INC	(HL)
	CALL	M,READ		;read sector if buffer empty
	OR	A
	RET	NZ		;return if read error or eof
	LD	A,(BUFP)	;compute pointer into buffer
	LD	HL,BUF
	CALL	ADDHLA
	XOR	A		;set zero flag
	LD	A,(HL)		;get byte
	RET
;;
;;-----------------------------------------------------------------------
;;
;;
;;	system control block flag routines
;;
;;	entry:	c  = bit mask (1 bit on)
;;		b  = scb byte offset
;;
SUBTEST:
	LD	BC,SUBMIT
GETFLG:
;	return flag value
;	exit:	zero flag set if flag reset
;		c  = bit mask
;		hl = flag byte address
;
	LD	HL,(SCBADDR)
	LD	L,B
	LD	A,(HL)
	AND	C		; a = bit
	RET
;
SETCCPFLG:
	LD	BC,CCP10

;
SETFLG:
;	set flag on (bit = 1)
;
	CALL	GETFLG
	LD	A,C
	OR	(HL)
	LD	(HL),A
	RET
;
RESETCCPFLG:
	LD	BC,CCP10
;
RESETFLG:
;	reset flag off (bit = 0)
;
	CALL	GETFLG
	LD	A,C
	CPL
	AND	(HL)
	LD	(HL),A
	RET
;;
;;
;;	SET/GET SCB BYTE
;;
;;	entry:	 A  = byte ("setbyte" only)
;;		 B  = SCB byte offset from page
;;
;;	exit:	 A  = byte ("getbyte" only)
;;
SETBYTE:
	LD	HL,(SCBADDR)
	LD	L,B
	LD	(HL),A
	RET
;
GETBYTE:
	LD	HL,(SCBADDR)
	LD	L,B
	LD	A,(HL)
	RET
;



;;-----------------------------------------------------------------------
;;
;;
;;	print message followed by newline
;;
;;	entry:	de -> message string
;;
PMSGNL:	CALL	PMSG
;
;	print crlf
;
DIRLN:	LD	B,L		;number of columns for DIR
CRLF:	LD	A,CR
	CALL	PFC
	LD	A,LF
	JP	PFC
;;
;;-----------------------------------------------------------------------
;;
;;	print decimal byte
;;
PDB:	SUB	10
	JP	C,PDB2
	LD	E,'0'
PDB1:	INC	E
	SUB	10
	JP	NC,PDB1
	PUSH	AF
	CALL	PUTC2
	POP	AF
PDB2:	ADD	A,10+'0'
	JP	PUTC
;;-----------------------------------------------------------------------
;;
;;
;;	print string terminated by 0 or char in c
;;
PSTRG:	LD	A,(HL)		;get character
	OR	A
	RET	Z
	CP	C
	RET	Z
	CALL	PFC		;print character
	INC	HL		;advance pointer
	JP	PSTRG		;loop
;;
;;-----------------------------------------------------------------------
;;
;;	check for end of command (error if extraneous parameters)
;;
EOC:	CALL	SKPS
	RET	Z
;
;	handle parser error
;
PERROR:
	LD	HL,ERRFLG
	LD	A,(HL)
	OR	A		;ignore error????
	LD	(HL),0		;clear error flag
	RET	NZ		;yes...just return to CCPRET
	LD	HL,(ERRORP)	;get pointer to what we're parsing
	LD	C,' '
	CALL	PSTRG
PERR2:	LD	A,'?'		;print question mark
	CALL	PUTC
	JP	CCPCR
;
;;-----------------------------------------------------------------------
;;
;;
;;	print error message and exit processor
;;
;;	entry:	bc -> error message
;;
;;msgerr:	push	b
;;	call	crlf
;;	pop	d
;;	jmp	pmsgnl
;;
;;-----------------------------------------------------------------------
;;
;;	get decimal number (0 <= N <= 255)
;;
;;	exit:	a  = number
;;
GDN:	CALL	SKPS		;skip initial spaces
	LD	HL,(PARSEP)	;get pointer to current character
	LD	(ERRORP),HL	;save in case of parsing error
	RET	Z		;return if end of command
	LD	A,(HL)		;get it
	CP	'0'		;error if non-numeric
	JP	C,PERROR
	CP	'9'+1
	JP	NC,PERROR
	CALL	GDNS		;convert number
	LD	(PARSEP),HL	;save new position
	OR	1		;clear zero and carry flags
	LD	A,B
	RET
;
GDNS:	LD	B,0
GDNS1:	LD	A,(HL)
	SUB	'0'
	RET	C
	CP	10
	RET	NC
	PUSH	AF
	LD	A,B		;multiply current accumulator by 10
	ADD	A,A
	ADD	A,A
	ADD	A,B
	ADD	A,A
	LD	B,A
	POP	AF
	INC	HL		;advance to next character
	ADD	A,B		;add it in to the current accumulation
	LD	B,A
	CP	16
	JP	C,GDNS1		;loop unless >=16
	JP	PERROR		;error if invalid user number
;;
;;-----------------------------------------------------------------------
;;
;;	print file name
;;
	IF	NEWDIR
PFN:	INC	DE		;point to file name
	LD	H,8		;set # characters to print, clear # printed
	CALL	PFN1		;print name field
	CALL	LSPACE
	LD	H,3		;set # characters to print
PFN1:	LD	A,(DE)		;get character
	AND	7FH
	CALL	PFC		;print it if not
	INC	DE		;advance pointer
	DEC	H		;loop if more to print
	JP	NZ,PFN1
	RET
;
LSPACE:	LD	A,' '
;
PFC:	PUSH	BC
	PUSH	DE
	PUSH	HL
	CALL	PUTC
	POP	HL
	POP	DE
	POP	BC
	RET

	ELSE

PFN:	INC	DE		;point to file name
	LD	BC,8*256	;set # characters to print, clear # printed
	CALL	PFN1		;print name field
	LD	A,(DE)		;see if there's a type
	AND	7FH
	CP	' '
	RET	Z		;return if not
	LD	A,'.'		;print dot
	CALL	PFC
	LD	B,3		;set # characters to print
PFN1:	LD	A,(DE)		;get character
	AND	7FH
	CP	' '		;is it a space?
	CALL	NZ,PFC		;print it if not
	INC	DE		;advance pointer
	DEC	B		;loop if more to print
	JP	NZ,PFN1
	RET
;
LSPACE:	LD	A,' '
;
PFC:	INC	C		;increment # characters printed
	PUSH	BC
	PUSH	DE
	CALL	PUTC
	POP	DE
	POP	BC
	RET
	ENDIF
;;
;;-----------------------------------------------------------------------
;;
;;	add a to hl
;;
ADDHLA:	ADD	A,L
	LD	L,A
	RET	NC
	INC	H
	RET
;;
;;-----------------------------------------------------------------------
;;
;;	set match-any string into fcb
;;
;;	entry:	de -> fcb area
;;		b  = # bytes to set
;;
SETMATCH:
	LD	A,'?'		;set match one character
SETM1:	LD	(DE),A		;fill rest of field with match one
	INC	DE
	DEC	B		;loop if more to fill
	JP	NZ,SETM1
	OR	A
	RET
;;
;;-----------------------------------------------------------------------
;;
;;	table search
;;
;;	Search table of strings separated by spaces and terminated
;;	by 0.  Accept abbreviations, but set string = matched string
;;	on exit so that we don't try to execute abbreviation.
;;
;;	entry:	de -> string to search for
;;		hl -> table of strings to match (terminate table with 0)
;;	exit:	z  = set if match found
;;		a  = entry # (0 thru n-1)
;;		z  = not set if no match found
;;
TBLS:	LD	BC,0FFH		;clear entry & entry length counters
TBLS0:	PUSH	DE		;save match string addr
	PUSH	HL		;save table string addr
TBLS1:	LD	A,(DE)		;compare bytes
	AND	7FH		;kill upper bit (so SYS + R/O match)
	CP	' '+1		;end of search string?
	JP	C,TBLS2		;skip compare, if so
	CP	(HL)
	JP	NZ,TBLS3	;jump if no match
TBLS2:	INC	DE		;advance string pointer
	INC	C		;increment entry length counter
	LD	A,' '
	CP	(HL)
	INC	HL		;advance table pointer
	JP	NZ,TBLS1	;continue with this entry if more
	POP	HL		;HL = matched string in table
	POP	DE		;DE = string address
	CALL	MOVE		; C = length of string in table
	LD	A,B		;return current entry counter value
	RET
;
TBLS3:	LD	A,' '		;advance hl past current string
TBLS4:	CP	(HL)
	INC	HL
	JP	NZ,TBLS4
	POP	DE		;throw away last table address
	POP	DE		;DE = string address
	INC	B		;increment entry counter
	LD	C,0FFH
	LD	A,(HL)		;check for end of table
	SUB	1
	JP	NC,TBLS0	;loop if more entries to test
	RET
;
;************************************************************************
;************************************************************************
;
;************************************************************************
;
;	DATA AREA
;
;************************************************************************
;	;Note uninitialized data placed at the end (DS)
;
;
	IF	PROMPTS
ENTER:	DEFB	'Enter $'
UNMSG:	DEFB	'User #: $'
FNMSG:	DEFB	'File: $'
	ELSE
UNMSG:	DEFB	'Enter User #: $'
	ENDIF
NOMSG:	DEFB	'No File$'
REQUIRED:
	DEFB	' required$'
ERAMSG:
	DEFB	'ERASE $'
CONFIRM:
	DEFB	' (Y/N)? $'
MORE:	DEFB	CR,LF,CR,LF,'Press RETURN to Continue $'
	IF	DAYFILE
USERZERO: DEFB	'  (User 0)$'
	ENDIF
;
;
;
	IF	NEWDIR
ANYFILES: DEFB	0		;flag for SYS or DIR files exist
DIRFILES: DEFB	'NON-'
SYSFILES: DEFB	'SYSTEM FILE(S) EXIST$'
	ENDIF

RSXPB:	DEFB	41H	;Function for Named Directory RSXs
ERRFLG:	DEFB	0		;parse error flag
	IF	MULTI
MULTIBUFL:
	DEFW	0		;multiple commands buffer length
	ENDIF
SCBADD:	DEFB	SCBAD-PAG$OFF,0
	;********** CAUTION FOLLOWING DATA MUST BE IN THIS ORDER *********
PFNCB:	;BDOS func 152 (parse filename)
PARSEP:	DEFW	0		;pointer to current position in command
PFNFCB:	DEFW	PFCB		;.fcb for func 152
USERNUM:;CCP current user
	DEFB	0
CHAINDSK:
	DEFB	0		;transient's current disk
DISK:	DEFB	0		;CCP current disk
SUBFCB:	DEFB	1,'$$$     SUB',0
CCPEND:	;end of file (on disk)
	DEFS	1
SUBMOD:	DEFS	1
SUBRC:	DEFS	1
	DEFS	16
SUBCR:	DEFS	1
SUBRR:	DEFS	2
SUBRR2:	DEFS	1

DIRCOLS:
	DEFS	1		;number of columns for DIR/DIRS
PGSIZE:	DEFS	1		;console page size
LINE:	DEFS	1		;console line #
PGMODE:	DEFS	1		;console page mode
	;*****************************************************************
ERRORP:	DEFS	2		;pointer to beginning of current param.
ERRSAV:	DEFS	2		;pointer to built-in command tail
BUFP:	DEFS	1		;buffer pointer for getb
REALDOS:
	DEFS	1		;base page of BDOS
;
OPTION:	DEFS	1		;'[' in line?
PASSWD:	DEFS	10		;password
UFCB:	DEFS	1		;user number (must procede fcb)
FCB:
	DEFS	1		; drive code
	DEFS	8		; file name
	DEFS	3		; file type
	DEFS	4		; control info
	DEFS	16		; disk map
FCBCR:	DEFS	1		; current record
FCBRR:	DEFS	2		; random record
PFCB:	DEFS	36		; fcb for parsing
;
;
;
;
; 	command line buffer
;
CBUFMX:	DEFS	1
CBUFL:	DEFS	1
CBUF:	DEFS	COMLEN
	DEFS	50H
STACK:
CCPTOP:	;top page of CCP
	END

