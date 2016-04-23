; PROGRAM:	ZCPR
; VERSION:	3.3
; DERIVATION:	ZCPR30
; AUTHOR:	Jay Sage
; DATE:		May 28, 1987

; ZCPR33 is copyright 1987 by Echelon, Inc.  All rights reserved.  End-user
; distribution and duplication permitted for non-commercial purposes only.
; Any commercial use of ZCPR33, defined as any situation where the duplicator
; recieves revenue by duplicating or distributing ZCPR33 by itself or in
; conjunction with any hardware or software product, is expressly prohibited
; unless authorized in writing by Echelon.
;
; Echelon specifically disclaims any warranties, expressed or implied,
; including but not limited to implied warranties of merchantability and
; fitness for a particular purpose.  In no event will Echelon be liable for
; any loss of profit or any other commercial damage, including but not limited
; to special, incidental, consequential, or other damages.
;
; Echelon can be contacted at:
;      Echelon, Inc.
;      885 N. San Antonio Road
;      Los Altos, California  USA  94022
;      (415) 948-3820


;-----------------------------------------------------------------------------
;
;		   A C K N O W L E D G M E N T S
;
;-----------------------------------------------------------------------------

; Many people have played a role in the development of ZCPR in general and
; ZCPR33 in particular.  It all started when "The CCP Group," including
; Richard Conn, Ron Fowler, Keith Petersen, Frank Wancho, Charlie Strom, and
; Bob Mathias decided that by rewriting the CP/M command processor to take
; advantage of Zilog-specific opcodes they could save enough code to enhance
; some of the features.   Richard Conn then extended that development through
; ZCPR2 to ZCPR3 (3.0).  Just a little over two years ago, I took the first
; step to enhance ZCPR3 by making it get the maximum drive and user values
; from the environment instead of hard coding them in.   This version was
; distributed privately as ZCPR31.  Along the way to what is now ZCPR
; version 3.3 a number of others have made valuable contributions: Steve
; Kitahata, Michael Bate, Bruce Morgen, Roger Warren, Dreas Nielsen, Bob Freed,
; Al Hawley, Howard Goldstein, and many others who have stimulated developments
; by pointing out problems or asking questions.

; I would like particularly to acknowledge two people who have played a very
; significant role in these developments.  One is Al Hawley.  He introduced
; the idea of having the DUOK flag in the environment control how the CPR
; would respond to the DU: form of directory reference.  He also originated
; the idea of using the high bit of the first character of each command name
; to control whether or not it would be wheel restricted.  Finally, he
; contributed the basic structure of the highly efficient, elegant, and more
; general number evaluation routines in the code.

; My biggest debt of gratitude is to Howard Goldstein.  His role in the
; development of ZCPR33 goes back about a year, when he contributed the first
; correct implementation of the minpath feature.  More recently, during the
; period of intense development since Echelon expressed its interest in my
; writing the official 3.3 version, he and I have shared an especially
; enjoyable and fruitful relationship.  Most of the newest ideas have been
; worked out jointly, and Howard has done a great deal to keep my code and
; concepts on track.  He discovered many ways to pare the code down and, more
; importantly, uncovered numerous subtle bugs.  He recoded the SAVE command
; to make it more compact and reliable.
;
;						Jay Sage
;						May 28,1987

;-----------------------------------------------------------------------------
;
;		U S E R    C O N F I G U R A T I O N
;
;-----------------------------------------------------------------------------

; The following MACLIB statements load all the user-selected equates
; which are used to customize ZCPR33 for the user's working environment.
; NOTE -- TRUE & FALSE are defined in Z3BASE.
	MACLIB	COMMON.ASM
	MACLIB	Z3BASE.LIB
	MACLIB	Z33HDR.LIB

; Check that the configuration includes the required facilities

; A ZCPR33 system is assumed to include certain minimal features, including
; an external file control block, external path, shell stack, message buffer,
; external environment descriptor, multiple command line, and external stack.
; If wheel checking is enabled in the Z33HDR.LIB file, then there must be
; an address defined for the wheel byte in the Z3BASE.LIB file.

ERRFLAG	DEFL	EXTFCB EQ 0			; External command FCB
ERRFLAG	DEFL	ERRFLAG OR [ EXPATH EQ 0 ]	; Symbolic path
ERRFLAG	DEFL	ERRFLAG OR [ SHSTK  EQ 0 ]	; Shell stack
ERRFLAG	DEFL	ERRFLAG OR [ Z3MSG  EQ 0 ]	; Message buffer
ERRFLAG	DEFL	ERRFLAG OR [ Z3ENV  EQ 0 ]	; Environment descriptor
ERRFLAG	DEFL	ERRFLAG OR [ Z3CL   EQ 0 ]	; Multiple command line
ERRFLAG	DEFL	ERRFLAG OR [ EXTSTK EQ 0 ]	; External stack
	 IF	WHEEL OR WDU OR WPASS OR WPREFIX OR WHLDIR
ERRFLAG	DEFL	ERRFLAG OR [ Z3WHL  EQ 0 ]	; Wheel byte
	 ENDIF	;wheel or wdu or wpass or wprefix or whldir

	 IF	ERRFLAG

	*** NOT ALL REQUIRED ZCPR3 FACILITIES ARE SUPPORTED ***

	 ELSE	; go ahead with the assembly


;-----------------------------------------------------------------------------
;
;		D E F I N I T I O N S    S E C T I O N
;
;-----------------------------------------------------------------------------


; ----------   Macro definitions

	MACLIB	Z33MAC.LIB		; Library of macros for ZCPR33


; ----------   ASCII definitions

CTRLC	EQU	03H
BELL	EQU	07H
TAB	EQU	09H
; LF	EQU	0AH
; CR	EQU	0DH


; ----------   Operating system addresses

WBOOT	EQU	BASE+0000H	; CP/M warm boot address
UDFLAG	EQU	BASE+0004H	; User number in high nybble, disk in low
; BDOS	EQU	BASE+0005H	; BDOS function call entry point
TFCB	EQU	BASE+005CH	; Default FCB buffer
TFCB2	EQU	TFCB+16		; 2nd FCB
TBUFF	EQU	BASE+0080H	; Default disk I/O buffer
TPA	EQU	BASE+0100H	; Base of TPA
; BIOS	EQU	CCP+0800H+0E00H	; BIOS location


; ----------   Error codes

; ZCPR33 uses the error byte at the beginning of the message buffer as a flag
; to show what kind of error occurred.  Advanced error handlers will be able
; to help the user further by suggesting the possible cause of the error.
; Error code 6 for an ECP error is determined by the code and cannot be
; changed (without increasing code length).

ECDUCHG		EQU	1	; Directory change error -- attempt to change
				; ..logged directory when under control of
				; ..wheel byte and wheel is off

ECBADDIR	EQU	2	; Bad directory specification -- logging of
				; ..user number beyond legal range,
				; ..nonexistent named directory

ECBADPASS	EQU	3	; Bad password -- incorrect password entered


ECBADCMD	EQU	5	; Bad command form -- wildcard or file type
				; ..present in command verb

ECECPERR	EQU	6	; ECP error --  command could not be executed
				; ..by ECP, error handling was forced by a
				; ..transient for its own reasons
				; (DO NOT CHANGE FROM 6)

ECNOCMD		EQU	7	; Command file not found -- command that skips
				; ..ECP could not be executed, GET could not
				; ..find file to load

ECAMBIG		EQU	8	; Ambiguous file specification where not
				; ..allowed (SAVE, GET, REN)

ECBADNUM	EQU	9	; Bad numerical value -- not a number where
				; ..number expected, number out of range

ECNOFILE	EQU	10	; File not found -- REN, TYPE, LIST could not
				; ..find a specified file

ECDISKFULL	EQU	11	; Disk directory or data area full

ECTPAFULL	EQU	12	; TPA overflow error


; ----------   Multiple command line equates

; The multiple command line buffer is located in a protected area in memory so
; that it is not overwritten during warm boots.  It includes some pointers so
; that when ZCPR33 starts it can tell where to start reading the command line.
; BUFSIZ and CHRCNT are not used by ZCPR33 but are provided so that the BDOS
; line input function can be used to read in a command line.

NXTCHR	EQU	Z3CL		; Address where pointer to next command to
				; ..process is kept
BUFSIZ	EQU	Z3CL+2		; Address where size of buffer is kept
CHRCNT	EQU	Z3CL+3		; Address where length of string actually in
				; ..the buffer is kept (not always reliable)
CMDLIN	EQU	Z3CL+4		; Address of beginning of command line buffer
BUFLEN	EQU	Z3CLS		; Length of command line buffer


; ----------   Command file control block

; In ZCPR33 the file control block for commands must be located in protected
; memory.  This not only frees up valuable space in the command processor for
; code but also makes it possible for programs to determine by what name they
; were invoked.

CMDFCB	EQU	EXTFCB


; ----------   External CPR stack

STACK	EQU	EXTSTK+48	; Set top-of-stack address
PWLIN	EQU	EXTSTK		; Place line at bottom of stack


; ----------  Environment

QUIETFL	EQU	Z3ENV+28H	; Quiet flag
MAXDRENV EQU	Z3ENV+2CH	; Maximum drive value
MAXUSRENV EQU	Z3ENV+2DH	; Maximum user value
DUOKFL	EQU	Z3ENV+2EH	; Flag indicating acceptance of DU: form
CRTTXT0	EQU	Z3ENV+33H	; Address of number of lines of text on the
				; ..screen of CRT0


; ----------  Message buffer

ECFLAG		EQU	Z3MSG		; Error return code flag
IFPTRFL		EQU	Z3MSG+1		; Pointer to current IF level
IFSTATFL 	EQU	Z3MSG+2		; Flow control status byte
CMDSTATFL	EQU	Z3MSG+3		; Command status flag
CMDPTR		EQU	Z3MSG+4		; Pointer to currently running command
ZEXINPFL	EQU	Z3MSG+7		; ZEX input status/control flag
ZEXRUNFL	EQU	Z3MSG+8		; ZEX running flag
ERRCMD		EQU	Z3MSG+10H	; Error handling command line
XSUBFLAG	EQU	Z3MSG+2CH	; XSUB input redirection flag
SUBFLAG		EQU	Z3MSG+2DH	; Submit running flag
CURUSR		EQU	Z3MSG+2EH	; Currently logged user
CURDR		EQU	Z3MSG+2FH	; Currently logged drive


;-----------------------------------------------------------------------------
;
;		C O D E    M O D U L E S    S E C T I O N
;
;-----------------------------------------------------------------------------

	PAGE

; ZCPR33-1.Z80

;=============================================================================
;
;    E N T R Y    P O I N T S    A N D    H E A D E R    S T R U C T U R E
;
;=============================================================================

	 IF	NOT REL		; If generating absolute code
	ORG	CCP
	 ENDIF	;not rel


; ENTRY POINTS INTO ZCPR33
;
; For compatibility with CP/M, two entry points are provided here.  In
; standard CP/M if the code is entered from the first entry point, then the
; command in the resident command buffer is executed; if entered from the
; second entry point, the command line is flushed.  With ZCPR33 and its
; multiple command line buffer, these two entry points function identically
; and go to the same address.
;
; We have kept the entry points in their standard locations but have used a
; relative jump for the second entry point and replaced the last byte with the
; version number.  In this way the version number occupies a position that
; would otherwise contain the page number at which the CPR runs.  It will
; always be possible, therefore, to distinguish ZCPR33 and later versions
; from other command processors.  The first jump is kept as an absolute jump
; so that 1) the code will be compatible with Z-COM and Z3-DOT-COM and 2) the
; execution address of a CPR module can always be determined.

ENTRY:
	JP	ZCPR

	JR	ZCPR

VERSION:
	DEFB	33H		; Version ID squeezed in here (offset = 5)

;-----------------------------------------------------------------------------

; Configuration information

OPTIONS:			; (offset = 6)
  OPTFLAG BADDUECP,ROOTONLY,NDRENV,FCPENV,RCPENV,INCLENV,ADUENV,DUENV
  OPTFLAG HIGHUSER,DRVPREFIX,SCANCUR,INCLDIR,INCLDU,DUFIRST,ACCPTDIR,ACCPTDU
  OPTFLAG NO,PWCHECK,PWNOECHO,WDU,WPASS,WPREFIX,FASTECP,SKIPPATH

ATTDIR	DEFL	[ COMATT EQ 80H ] OR [ COMATT EQ 01H ] OR [ NOT ATTCHK ]
ATTSYS	DEFL	[ COMATT EQ 00H ] OR [ COMATT EQ 01H ] OR [ NOT ATTCHK ]
SUBQUIET DEFL	[ SUBNOISE EQ 1 ]
SUBECHO	DEFL	[ SUBNOISE GT 1 ]

  OPTFLAG SHELLIF,ATTSYS,ATTDIR,ATTCHK,SUBECHO,SUBQUIET,SUBCLUE,SUBON

; Byte with information about the alternate colon option.  If the byte is
; zero, the option is not supported.  Otherwise the byte contains the
; prefix character that serves as an alias for a colon prefix.  Offset = 10.

	 IF	ALTCOLON
	DEFB	ALTCHAR
	 ELSE
	DEFB	0
	 ENDIF	;altcolon

; Byte with information about the FASTECP implementation (option bit above
; indicates whether the feature is enabled at all).  If no character appears
; here (zero byte), then only a leading space can be used.  Otherwise, the
; first seven bits contain the character, and the high bit, if set, indicates
; that ONLY this character will be recognized and not a space.  Offset = 11.

	 IF	FASTECP AND ALTSPACE
	 IF	ALTONLY
	DEFB	ECPCHAR + 80H
	 ELSE	;not altonly
	DEFB	ECPCHAR
	 ENDIF	;altonly
	 ELSE	;no alternate character
	DEFB	0
	 ENDIF	;fastecp and altspace

	DEFB	0,0,0,0			; Space reserved for expansion

;-----------------------------------------------------------------------------

; Entry points to file name parsing code.

; Entry point REPARSE.  A call to this point can be used to parse a command
; line tail into the default file control blocks at 5CH and 6CH.  Each time
; the parser is called it leaves the starting address of the second token in
; the PARESPTR address below so that successive calls to the routine reparse
; the command tail one token later.  A program can load its own pointer into
; PARSEPTR as well.  Offset = 16 (10h).

REPARSE:
PARSEPTR EQU	$+1		; Pointer for in-the-code modification
	LD	HL,0
	JP	PARSETAIL

; Entry point SCAN.  A call to this point can be used to parse a single token
; pointed to by HL into the FCB pointed to by DE.  Offset 22 (16h).

SCAN:
	JP	SCANNER

;-----------------------------------------------------------------------------

; BUFFERS
;
; In this area various data items are kept.  First comes the list of commands
; supported by ZCPR33; then comes the name of the extended command processor
; (ECP).  By putting these items here, an 'H' command in the RCP or a utility
; like SHOW.COM can find this information and report it to the user.


; ----------   RESIDENT COMMAND TABLE

; The command table entry is structured as follows:  First there is a byte
; which indicates the number of characters in each command.  Then there is a
; series of entries comprising the name of a command followed by the address
; of the entry point to the code for carrying out that command.  Finally,
; there is a null byte (00h) to mark the end of the table.  Offset = 25 (19h).


CMDTBL:
	DEFB	CMDSIZE		; Length of command names
	CTABLE			; Define table via macro in Z33HDR.LIB
	DEFB	0		; End of table

; ----------  NAME FOR EXTENDED COMMAND PROCESSOR

; The name of the extended command processor is placed here after the command
; table so that utilities like SHOW or an RCP 'H' command can find it.

ECPFCB:
	ECPNAME			; From Z33HDR.LIB


; ----------   FILE TYPE FOR TRANSIENT COMMANDS (usually COM)

; This file type also applies to the extended command processor name.

COMMSG:
	COMTYP			; From Z33HDR.LIB



; ----------   SUBMIT FILE CONTROL BLOCK

	 IF	SUBON		; If submit facility enabled ...

SUBFCB:
	DEFB	SUBDRV-'A'+1	; Explicit drive for submit file
	DEFB	'$$$     '	; File name
	SUBTYP			; From Z33HDR.LIB
	DEFB	0		; Extent number
	DEFB	0		; S1 (user number 0)
SUBFS2:
	DEFS	1		; S2
SUBFRC:
	DEFS	1		; Record count
	DEFS	16		; Disk group map
SUBFCR:
	DEFS	1		; Current record number

	 ENDIF	; subon

; End ZCPR33-1.Z80

	PAGE

; ZCPR33-2.Z80

;=============================================================================
;
;	C O M M A N D    L I N E    P R O C E S S I N G    C O D E
;
;=============================================================================

; MAIN ENTRY POINT TO CPR

; This is the main entry point to the command processor.  On entry the C
; register must contain the value of the user/drive to be used as the current
; directory.

ZCPR:
	LD	SP,STACK	; Reset stack

	 IF	PWNOECHO
	LD	A,0C3H		; Reenable BIOS conout routine
	LD	(BIOS+0CH),A	; ..after a warmboot
	 ENDIF	;pwnoecho

	LD	B,0FH		; Keep nibble mask in B

; If the HIGHUSER option is enabled, we compare the user/drive in the login
; byte in C to the values stored in the message buffer.  If, ignoring bit 4
; of the user number, they match, then we remain in the current area, which
; may be a user area above 15.

	 IF	HIGHUSER

	LD	A,C		; Copy user/drive byte to A
	AND	B		; Isolate drive
	LD	D,A		; ..and move to D
	LD	A,C		; Get full byte back
	SWAP			; Swap nibbles
	AND	B		; Isolate user number
	LD	E,A		; ..and move to E
	LD	HL,(CURUSR)	; Get old curdr/curusr into HL
	SBC	HL,DE		; Subtract new values from old (carry is clear)
	EX	DE,HL		; Switch new values into HL, diff into DE
	LD	A,D		; Combine two parts of difference
	OR	E
	AND	B		; Ignore bit for high user numbers
	JR	Z,ZCPR1		; Skip update if no change in DU
	LD	(CURUSR),HL	; Update values of current drive and user
ZCPR1:

	 ELSE	;not highuser

	LD	A,C		; Copy user/drive byte to A
	AND	B		; Isolate drive
	LD	H,A		; ..and move to H
	LD	A,C		; Get full byte back
	SWAP			; Swap nibbles
	AND	B		; Isolate user number
	LD	L,A		; ..and move to L
	LD	(CURUSR),HL	; ..and save them

	 ENDIF	;highuser

; This block of code is executed when submit processing is enabled.  We log
; into user area 0, where the submit file is kept, and we search the
; designated drive for the file.  The result is kept in SUBFLAG.  This code
; only has to be executed on reentry to the command processor at the main
; entry point.  Commands that do not reboot but simply return to the CPR will
; execute without the disk reset and file search required here.  Ron Fowler
; pointed out a shortcut based on the fact that after a disk reset, the A
; regiser contains a value of 0 if there is no file on drive A with a '$' in
; the file name and 0FFH if there is such a file.  Thus if A = 0, there can
; be no '$$$.SUB' file on drive A.  This trick is, unfortunately, not reliable
; under some versions of ZRDOS.  Therefore, an option has been included to
; use or not use this shortcut.

	 IF	SUBON		; If submit facility enabled ..

	CALL	DEFLTDMA	; Set DMA address to 80H
	LD	A,0		; Log into user area 0
	CALL	SETUSER
	LD	C,0DH		; Reset disk system (returns 0FFH if a $$$.SUB
	CALL	BDOSSAVE	; ..file might exist in user 0)
	LD	DE,SUBFCB	; Point to submit file FCB with explicit drive

	 IF	SUBCLUE
	CALL	NZ,SRCHFST	; Search only if flag says it could exist
	 ELSE	;not subclue
	CALL	SRCHFST		; Search for the file unconditionally
	 ENDIF	;subclue

	LD	(SUBFLAG),A	; Set flag for result (0 = no $$$.SUB)

	 ELSE	;not subon

	LD	C,0DH		; Reset disk system
	CALL	BDOSSAVE

	 ENDIF	; subon

	JR	NEXTCMD		; Go to entry point for processing next command


;-----------------------------------------------------------------------------

; NEW COMMAND LINE ENTRY POINT

; This entry point is used when ZCPR33 finds the command line empty.  A call to
; READBUF gets the next command line from the following possible sources in
; this order:
;	1) a running ZEX script
;	2) the submit file $$$.SUB (if enabled)
;	3) the shell stack
;	4) the user
; If the line comes from the shell stack, then the shell bit in the command
; status flag is set.

RESTART:
	LD	SP,STACK	; Reset stack
	XOR	A
	LD	(CMDSTATFL),A	; Reset ZCPR3 command status flag
	INC	A		; Set ZEX message byte to 1 to
	LD	(ZEXINPFL),A	; ..indicate command prompt
	 IF	SUBON
	LD	(XSUBFLAG),A	; Ditto for XSUB flag
	 ENDIF	;subon
	LD	HL,CMDLIN	; HL --> beginning of command line buffer
	LD	(NXTCHR),HL	; Save as pointer to next character to process
	LD	(HL),0		; Zero out command line (in case of warm boot)
	PUSH	HL		; Save pointer to command line
	CALL	READBUF		; Input command line (ZEX, submit, shell,
				; ..or user)
	POP	HL		; Get back pointer to command line
	LD	A,(HL)		; Check for comment line
	CP	COMMENT		; Begins with comment character?
	JR	Z,RESTART	; If so, go back for another line
				; Otherwise, fall through

;-----------------------------------------------------------------------------

; COMMAND CONTINUATION PROCESSING ENTRY POINT

; This is the entry point for continuing the processing of an existing command
; line.  The current drive and user values as known to the CPR are combined
; and made into the user/drive byte that CP/M keeps at location 0004.  If the
; HIGHUSER option is enabled, the user number for this byte is forced to be
; in the range 0..15.  Next the command status flag is processed.  The error
; and ECP bits in the actual flag are reset, and the original flag is checked
; for an ECP error return (both ECP bit and error bit set).  In that case,
; control is transferred to the error handler.

NEXTCMD:
	LD	HL,(CURUSR)	; Get currently logged drive and user
	LD	A,L		; Work on user number
	 IF	 HIGHUSER
	AND	0FH		; Keep value modulo 16
	 ENDIF	;highuser
	SWAP			; Get user into high nibble
	OR	H		; ..and drive into low nibble
	LD	(UDFLAG),A	; Set user/disk flag in page 0

	LD	A,2		; Turn ZEX input redirection off
	LD	(ZEXINPFL),A
	 IF	SUBON
	LD	(XSUBFLAG),A	; Turn off XSUB input redirection
	 ENDIF	;subon

	LD	HL,CMDSTATFL	; Point to the command status flag (CSF)
	LD	A,(HL)		; Get a copy into register A
	RES	1,(HL)		; Reset the actual error bit
	RES	2,(HL)		; Reset the actual ECP bit
	AND	110B		; Select ECP and error bits in original flag
	CP	110B		; Test for an ECP error
	JP	Z,ERROR		; Process ECP error with error handler

NEXTCMD1:
	LD	SP,STACK	; Reset stack
	CALL	LOGCURRENT	; Return to default directory
	LD	HL,(NXTCHR)	; Point to first character of next command
	PUSH	HL		; Save pointer to next character to process

; We have to capitalize the command line each time because an alias or other
; command line generator may have stuck some new text in.  The code is shorter
; if we simply capitalize the entire command rather than trying to capitalize
; only the one command we are about to execute.

CAPBUF:				; Capitalize the command line
	LD	A,(HL)		; Get character
	CALL	UCASE		; Convert to upper case
	LD	(HL),A		; Put it back
	INC	HL		; Point to next one
	OR	A		; See if end of line (marked with null)
	JR	NZ,CAPBUF	; If not, loop back

	POP	HL		; Restore pointer to next character to process

NEXTCMD3:

; ZCPR33 provides a convenience feature to make it easier to enter a leading
; colon to force the current directory to be scanned and to make the CPR skip
; resident commands.  If ALTCOLON is active, an alternate character can be
; entered as the first character of a command.  The default (and recommended)
; alternative character is the period (it could not have any other meaning
; here).  If FASTECP (see below) is not enabled or if ALTONLY is enabled,
; leading spaces on the command line are skipped before looking for the
; alternate character for the colon

	 IF	[ NOT FASTECP ] OR [ FASTECP AND ALTONLY ]
	CALL	SKSP
	 ENDIF	;[ not fastecp ] or [ fastecp and altonly ]

	 IF	ALTCOLON	; If allowing alias character for leading colon
				; Set B = ':' and C = alias character ('.')
	LD	BC,':' shl 8 + altchar
	LD	A,(HL)		; Get first character in new command line
	CP	C		; If first character is ALTCHAR, treat as ':'
	JR	NZ,NEXTCMD3A	; Branch if not '.'
	LD	(HL),B		; Else replace with colon
NEXTCMD3A:
	 ENDIF	;altcolon


; ZCPR33 supports three new options that can speed up command processing.
; FASTECP allows commands with a leading space to bypass the search for
; resident commands or transient commands (COM files) along the path and go
; directly to the extended command processor.  With SKIPPATH enabled, when
; a command is prefixed by an explicit directory specification (but not a
; lone colon), searching of the path and invocation of the ECP are disabled.
; If the command is not found in the specified directory, the error handler
; is invoked immediately.  Finally, if BADDUECP is enabled, when an attempt
; is made to log into an invalid directory, the command is sent directly to
; the ECP, which can provide special handling.  To implement these three
; features, the first actual character of the command line is saved as a
; flag in FIRSTCHAR.  My apologies for the complexity of these nested
; conditionals.

	 IF	FASTECP OR SKIPPATH OR BADDUECP

		; With FASTECP we store the first actual
		; ..character and then skip over spaces (unless ALTONLY is
		; ..enabled, in which case we skipped spaces above)

	 IF	FASTECP

	 IF	ALTSPACE	; If allowing alias character for leading space
				; Set B = ' ' and C = alias character ('/')
	LD	BC,' ' shl 8 + ecpchar
	LD	A,(HL)		; Get first character in new command line
	CP	C		; If first character is ECPCHAR treat as ' '
	JR	NZ,NEXTCMD3B	; Branch if not '/' (alternate character)
	LD	(HL),B		; Else replace with space
NEXTCMD3B:
	 ENDIF	;altspace

	LD	A,(HL)		; Get first character in command line
	LD	(FIRSTCHAR),A	; Save it in flag
	CALL	SKSP		; Then skip leading spaces
	 ENDIF	;fastecp

		; With SKIPPATH but not FASTECP we store the first
		; ..character of the command (spaces were skipped above)

	 IF	[ NOT FASTECP ] AND SKIPPATH
	LD	(FIRSTCHAR),A	; Store first nonspace character
	 ENDIF	;[ not fastecp ] and skippath

		; With only BADDUECP (and neither SKIPPATH nor FASTECP)
		; ..we store a null in the FIRSTCHAR flag

	 IF	[ NOT FASTECP ] AND [ NOT SKIPPATH ]
	XOR	A
	LD	(FIRSTCHAR),A
	 ENDIF	;[ not fastecp ] and [ not skippath ]

	 ENDIF	;fastecp or skippath or badduecp

; Resume processing of the command line

	OR	A		; Now at end of line?
	JR	Z,RESTART	; If so, get a new command line
	CP	CTRLC		; Flush ^C to prevent error-handler
	JR	Z,RESTART	; ..invocation on warm boots

	CP	CMDSEP		; Is it a command separator?
	JR	NZ,NEXTCMD4	; If not, skip ahead to process the command
	INC	HL		; If it is, skip over it
	JR	NEXTCMD3	; ..and process next command

NEXTCMD4:

; Unless we are now running the external error handler, the following code
; saves the address of the current command in Z3MSG+4 for use by programs
; to determine the command line with which they were invoked.

	LD	A,(CMDSTATFL)	; Get command status flag
	BIT	1,A		; Test for error handler invocation
	JR	NZ,NEXTCMD5	; If so, skip over next instruction
	LD	(CMDPTR),HL

NEXTCMD5:
	CALL	PARSER		; Parse entire command line, then look for
				; ..the command

;=============================================================================

;		C O M M A N D    S E A R C H    C O D E

;=============================================================================

; CODE FOR FINDING AND RUNNING THE COMMAND

; Here is the code for running a command.  Commands are searched for and
; processed in the following order:
;
;	1) flow control package (FCP) commands and IF state testing
;	2) resident command package (RCP)
;	3) command processor (CPR)
;	4) transient (COM file or extended command processor)
;	5) external error handler
;	6) internal error message and processing
;
; Special notes:
;
;    a)	If the current command is a shell command, special handling of flow
; 	control is required.  If SHELLIF is enabled so that flow commands are
;	allowed in shell alias scripts, then we reset the flow state to its
;	initial condition (none) with each shell invocation (and after each
;	command is run, we reset the shell bit in the code after CALLPROG).
;	In this case shells will run regardless of flow state, and residual
;	conditionals from the last running of the shell are flushed.  Each
;	shell input sequence begins afresh.  On the other hand, if SHELLIF is
;	off, flow control commands inside a shell script must be flushed so
;	that they do not interfere with user entered commands.
;    b)	Directory prefixes are ignored for flow commands, since all flow control
;	processing must pass through the FCP (the command must run even when
;	the current flow state is false).
;    c)	If the command is not found in the FCP, then the current flow state is
;	tested.  If it is false, the command is flushed and the code branches
;	back to get the next command.
;    d)	If the command had a directory prefix (a colon alone is sufficient),
;	then steps #2 and #3 are skipped over,and the command is processed
;	immediately as a transient program.
;    e)	In ZCPR33, unlike ZCPR30, RCP commands are scanned before CPR commands.
;	This has been done so that more powerful RCP commands can supercede
;	CPR commands.
;    f)	If the SKIPPATH option is enabled, when an explicit directory is
;	specified with a command (but not just a colon), searching of the path
;	is bypassed.  If the FASTECP option is enabled, commands with leading
;	spaces are sent directly to the ECP for processing.
;    g)	If no external command can be found, ZCPR33 performs extensive error
;	handling.  If the command error occurred while looking for a shell
;	program, then the shell stack is popped.  Otherwise, ZCPR33 tries to
;	invoke an external, user-specified error handling command line.  If
;	none was specified or if the error handler invoked by that command
;	line cannot be found, the internal error message (step #6) is displayed.


;-----------------------------------------------------------------------------

RUNCMD:
	 IF	SHELLIF		; If shells reininitialize flow control...
	LD	A,(CMDSTATFL)	; Get command status flag
	BIT	0,A		; Shell bit set?
	JR	Z,FCPCMD	; If not a shell, process command
	XOR	A		; Otherwise, shell is running, so
	LD	(IFPTRFL),A	; ..reinitialize the IF system and continue
	 ENDIF	;shellif


; ---------- Module <<1>>: Flow Control Processing

; An option is supported here to allow the address of the FCP to be obtained
; from the environment descriptor.  This is logically consistent with the
; pholosopy of the Z-System and is useful when one wants to have a single block
; of FCP/RCP memory that can be allocated dynamically between FCP and RCP
; functions.

FCPCMD:

	 IF	FCP NE 0	; Omit code if FCP not implemented

	 IF	FCPENV		; If getting FCP address from Z3ENV

	LD	E,12H		; Offset in Z3ENV to FCP address
	CALL	PKGOFF		; Set HL to FCP+5
	JR	Z,RUNCMD1	; Skip if no FCP present

	 ELSE	; using fixed FCP address

	LD	HL,FCP+5	; Get address from Z3BASE.LIB

	 ENDIF	;fcpenv


; If flow control processing is not allowed in shell aliases (scripts running
; as shell commands), then we have to make sure that we flush any flow control
; commmands, otherwise the CPR will attempt to execute them as transients,
; with dire consequences.  In the code below we check the shell bit.  If it
; is not set, we proceed normally.  If it is set, we scan for flow commands
; and then jump past the flow testing to RUNFCP2, where the code will flush
; the command if it was a flow command and execute it unconditionally if not.

	 IF	NOT SHELLIF
	LD	A,(CMDSTATFL)	; Get command status flag
	BIT	0,A		; If shell bit not set,
	JR	Z,RUNFCP1	; ..we do normal processing
	CALL	CMDSCAN		; Otherwise, check for flow command
	JR	RUNFCP2		; ..and flush if so using code below
	 ENDIF	;not shellif

RUNFCP1:
	CALL	CMDSCAN		; Scan command table in the module
	JR	Z,CALLPROG	; Run if found (with no leading CRLF)

; This is where we test the current IF state.  If it is false, we skip this
; command.

	CALL	IFTEST		; Check current IF status

RUNFCP2:			; If false, skip this command and go on to next
	 IF	DRVPREFIX	; If DRVPREFIX we can use code below
	JR	Z,JPNEXTCMD	; ..to save a byte
	 ELSE			; Otherwise, we have to do an
	JP	Z,NEXTCMD	; ..absolute jump
	 ENDIF	;drvprefix

	 ENDIF	;fcp ne 0


RUNCMD1:
	 IF	FASTECP OR BADDUECP
	LD	A,(FIRSTCHAR)	; If FIRSTCHAR flag set for ECP invocation,
	CP	' '		; ..then go straight to transient processing
	JR	Z,COM
	 ENDIF	;fastecp or badduecp

COLON	EQU	$+1		; Flag for in-the-code modification
	LD	A,0		; If command had a directory prefix (even just
	OR	A		; ..a colon) then skip over resident commands
	JR	NZ,COMDIR


; ---------- Module <<2>>: RCP Processing

; An option is supported here to allow the address of the RCP to be obtained
; from the environment descriptor.  This is logically consistent with the
; pholosopy of the Z-System and is useful when one wants to have a single block
; of FCP/RCP memory that can be allocated dynamically between FCP and RCP
; functions.

	 IF	RCP NE 0	; Omit code if RCP not implemented

RCPCMD:

	 IF	RCPENV		; If getting address of rcp from Z3ENV

	LD	E,0CH		; Offset in Z3ENV to RCP address
	CALL	PKGOFF		; Set HL to address of RCP+5
	JR	Z,CPRCMD	; Skip if no RCP

	 ELSE	; using fixed RCP address

	LD	HL,RCP+5	; Get address from Z3BASE.LIB

	 ENDIF	; rcpenv

	CALL	CMDSCAN		; Check for command in RCP
	JR	Z,CALLPROGLF	; If so, run it (with leading CRLF)

	 ENDIF	;rcp ne 0


; ---------- Module <<3>>: CPR-Resident Command Processing

CPRCMD:

	LD	HL,CMDTBL	; Point to CPR-resident command table
	CALL	CMDSCAN		; ..and scan for the command
	JR	Z,CALLPROG	; If found, run it (with no leading CRLF)



; ---------- Module <<4>>: Transient Command Processing

COMDIR:				; Test for DU: or DIR: only (directory change)

	 IF	DRVPREFIX

	LD	A,(CMDFCB+1)	; Any command name?
	CP	' '
	JR	NZ,COM		; If so, must be transient or error

		; Entry point for change of directory only

	 IF	WDU		; If controlled by wheel..

	LD	A,(Z3WHL)	; Get wheel byte
	OR	A		; If wheel on, go on ahead
	JR	NZ,COMDIR1

	 IF	BADDUECP
	LD	(COLON),A	; Pretend there is no colon
	LD	A,' '		; Force invocation of ECP
	LD	(FIRSTCHAR),A
	JR	COM
	 ELSE	;not badduecp
	LD	A,ECDUCHG
	JR	Z,ERROR
	 ENDIF	;badduecp

	 ENDIF	; wdu

COMDIR1:
	LD	HL,(TEMPUSR)	; Get temporary drive and user bytes

	 IF	NOT HIGHUSER	; If only users 0..15 can be logged
	LD	A,L		; Get user number and
	CP	16		; ..make sure not above 15
	JR	NC,BADDIRERR	; If out of range, invoke error handling
	 ENDIF	;not highuser

	DEC	H		; Shift drive to range 0..15
	LD	(CURUSR),HL	; Make the temporary DU into the current DU
	CALL	LOGCURRENT	; Log into the new current directory
JPNEXTCMD:
	JP	NEXTCMD		; Resume command line processing

	 ELSE	;not drvprefix

	 IF	BADDUECP
	XOR	A		; Pretend there is no colon
	LD	(COLON),A
	LD	A,' '		; Force invocation of ECP
	LD	(FIRSTCHAR),A
	 ELSE	;not badduecp
	LD	A,ECDUCHG
	JR	Z,ERROR
	 ENDIF	;badduecp

	 ENDIF	;drvprefix


COM:				; Process transient command

	LD	A,(CMDSTATFL)	; Check command status flag to see if
	AND	2		; ..error handler is running
	LD	(ZEXINPFL),A	; Store result in ZEX control flag (2 will turn
				; ..ZEX input redirection off (0 = on)
	 IF	SUBON
	LD	(XSUBFLAG),A	; Turn off XSUB input redirection also
	 ENDIF	;subon

	LD	HL,TPA		; Set default execution/load address
	LD	A,3		; Dynamically load type-3 and above ENVs
	CALL	MLOAD		; Load memory with file specified in cmd line
	LD	A,(CMDSTATFL)	; Check command status flag to see if
	AND	100B		; ..ECP running (and suppress leading CRLF)

; CALLPROG is the entry point for the execution of the loaded program.  At
; alternate entry point CALLPROGLF if the zero flag is set, a CRLF is sent to
; the console before running the program.

CALLPROGLF:
	CALL	Z,CRLF		; Leading new line

CALLPROG:
		; Copy command tail into TBUFF

TAILSV	EQU	$+1		; Pointer for in-the-code modification
	LD	HL,0		; Address of first character of command tail
	LD	DE,TBUFF	; Point to TBUFF
	PUSH	DE		; Save pointer
	LD	BC,7E00H	; C=0 (byte counter) and B=7E (max bytes)
	INC	DE		; Point to first char
TAIL:
	LD	A,(HL)		; Get character from tail
	CALL	TSTEOL		; Check for EOL
	JR	Z,TAIL1		; Jump if we are done
	LD	(DE),A		; Put character into TBUFF
	INC	HL		; Advance pointers
	INC	DE
	INC	C		; Increment character count
	DJNZ	TAIL		; If room for more characters, continue
	CALL	PRINT		; Display overflow message
	DB	BELL		; ..ring bell
	DB	'Ovf','l'+80h	; ..then continue anyway
TAIL1:
	XOR	A		; Store ending zero
	LD	(DE),A
	POP	HL		; Get back pointer to character count byte
	LD	(HL),C		; Store the count

; Run loaded transient program

	CALL	DEFLTDMA	; Set DMA to 0080h standard value

; Perform automatic installation of Z3 programs (unless type-2 environment)

	LD	HL,(EXECADR)	; Get current execution address
	CALL	Z3CHK		; See if file is a Z3 program
	JR	NZ,NOINSTALL	; Branch if not

	CP	2		; If type-2 (internal) environment
	JR	Z,NOINSTALL	; ..do not perform installation

	INC	HL		; Advance to place for ENV address
	LD	(HL),LOW Z3ENV	; Put in low byte of environment address
	INC	HL
	LD	(HL),HIGH Z3ENV	; Put in high byte

NOINSTALL:

; Execution of the program occurs here by calling it as a subroutine

	LD	HL,Z3ENV	; Pass environment address to program in HL
EXECADR	EQU	$+1		; Pointer for in-line code modification
	CALL	0		; Call transient

; Return from execution

	 IF	SHELLIF		; If flow processing allowed in shells...
	LD	HL,CMDSTATFL	; Reset the shell bit in the command status
	RES	0,(HL)		; ..flag so multiple-command shells will work
	 ENDIF	;shellif

				; Continue command processing
	 IF	DRVPREFIX	; If DRVPREFIX we can save a byte by
	JR	JPNEXTCMD	; ..doing a two-step relative jump
	 ELSE			; Otherwise, we just have to do
	JP	NEXTCMD		; ..the absolute jump
	 ENDIF	;drvprefix


; ---------- Module <<5>>: External Error Handler Processing

BADDIRERR:
	LD	A,ECBADDIR	; Error code for bad directory specification

ERROR:

; If we are returning from an external command to process an error, we want
; to leave the error return code as it was set by the transient program.

	LD	HL,CMDSTATFL	; Point to command status flag
	BIT	3,(HL)		; Check transient error flag bit
	JR	NZ,ERROR1	; If set, leave error code as set externally
	LD	(ECFLAG),A	; Otherwise, save error code from A register

ERROR1:
	RES	2,(HL)		; Reset the ECP bit to prevent recursion of
				; ..error handler by programs that don't
				; ..clear the bit
	BIT	0,(HL)		; Was error in attempting to run a shell?
	JR	NZ,ERRSH	; If so, pop shell stack

; The following code is included to avoid a catastrophic infinite loop when
; the external error handler cannot be found.  After one unsuccessful try,
; the internal code is invoked.

	BIT	1,(HL)		; Was an error handler already called?
	JR	NZ,ERRINTRNL	; If so, use internal error handler

; If the current IF state is false, we would like to ignore the error and just
; go on with the next command.  Unfortunately, for some errors (e.g., a bad
; command format such as a command with a wildcard character) the error handler
; is invoked before the pointer in the multiple command line buffer is set up
; to the next command.  In that case, we fall into an infinite loop.  We also
; must not allow the external error handler to run, since it will not run and
; we will again fall into an infinite loop.  The present code is not so bad, of
; course, since even a command in a false part of a command sequence should not
; have a true error in it.  We have already put in code to bypass password
; checking during a false IF state, since a command with a password is not an
; invalid command.

	 IF	FCP NE 0
	CALL	IFTEST		; If we are in a false IF state, external
	JR	Z,ERRINTRNL	; ..handler will not run, so use built-in
	 ENDIF	;fcp ne 0

	SET	1,(HL)		; Set command status flag for error invocation
	LD	HL,ERRCMD	; Point to error handler command line
	LD	A,(HL)		; Check first byte for presence of an
	OR	A		; ..error command line
	JR	Z,ERRINTRNL	; If no error handler, use built-in one
	LD	(NXTCHR),HL	; Else, use error command line as next command
	JP	NEXTCMD1	; Run command without resetting status flag


; ---------- Module <<6>>: Resident Error Handler Code

; If the error is with the invocation of a shell command, we pop the bad shell
; command off the stack to prevent recursion of the error.  We then use the
; the internal error handler to echo the bad shell command.

ERRSH:

	LD	DE,SHSTK	; Point to current entry in shell stack
	LD	HL,SHSTK+SHSIZE	; Point to next entry in stack
	LD	BC,[SHSTKS-1]*SHSIZE	; Bytes to move
	LDIR			; Pop the stack
	XOR	A		; Clear the last entry position
	LD	(DE),A

ERRINTRNL:
	 IF	SUBON
	CALL	SUBKIL		; Terminate active submit file if any
	 ENDIF	;subon

	CALL	CRLF		; New line
	LD	HL,(CMDPTR)	; Point to beginning of bad command
	CALL	PRINTHL		; Echo it to console
	CALL	PRINT		; Print '?'
	DEFB	'?'+80h
	JP	RESTART		; Restart CPR

; End ZCPR33-2.Z80

	PAGE

; ZCPR33-3.Z80

;=============================================================================
;
;	   C O M M A N D    L I N E     P A R S I N G    C O D E
;
;=============================================================================

; This code parses the command line pointed to by HL.  The command verb is
; parsed, placing the requested program name into the command file control
; block.  The drive and user bytes are set.  If an explicit DU or DIR was
; given, the COLON flag is set so that the processor knows about this later
; when the command search path is built.

PARSER:
	LD	DE,CMDFCB	; Point to the command FCB
	PUSH	DE
	CALL	INITFCB		; Initialize the FCB
	POP	DE
	LD	(DUERRFLAG),A	; Store zero (INITFCB ends with A=0) into flag
	CALL	SCANNER		; Parse first token on command line into FCB
	JR	NZ,BADCMD	; Invoke error handler if '?' in command

DUERRFLAG EQU	$+1		; Pointer for in-the-code modification
	LD	A,0		; See if bad DU/DIR specified with command verb
	OR	A

	 IF	BADDUECP
	JR	Z,PARSER1	; If DU/DIR is OK, skip ahead
	LD	A,(CMDSTATFL)	; If ECP already running
	BIT	2,A		; ..skip ahead
	JR	NZ,PARSER1
	LD	A,(CMDFCB+1)	; If not a directory change command
	SUB	' '		; ..invoke error handler
	JR	NZ,BADDIRERR
				; If bad directory change attempt,
	LD	(TMPCOLON),A	; ..pretend there is no colon (A=0)
	LD	A,' '		; ..and force immediate ECP invocation
	LD	(FIRSTCHAR),A	; ..when command is processed
	 ELSE			; If errors not processed by ECP then
	JR	NZ,BADDIRERR	; ..invoke error handler
	 ENDIF	; badduecp

PARSER1:
	LD	DE,CMDFCB+9	; Make sure no explicit file type was given
	LD	A,(DE)		; Get first character of file type
	CP	' '		; Must be blank
BADCMD:
	LD	A,ECBADCMD	; Error code for illegal command form
	JR	NZ,ERROR	; If not, invoke error handler

	PUSH	HL		; Save pointer to next byte of command
	LD	HL,COMMSG	; Place default file type (COM) into FCB
	LD	BC,3
	LDIR
	POP	HL		; Get command line pointer back

; The following block of code is arranged so that the COLON flag is set only
; when an explicit directory specification is detected in the command verb.
; Other parses also change the TMPCOLON flag, but only when passing here does
; the flag get transferred to COLON.

TMPCOLON EQU	$+1		; Pointer for in-the-code modification
	LD	A,0		; ..by SCANNER routine
	LD	(COLON),A	; If explicit DU/DIR, set COLON flag

; Find the end of this command and set up the pointer to the next command.

	PUSH	HL		; Save command line pointer
	DEC	HL		; Adjust for preincrementing below
PARSER2:			; Find end of this command
	INC	HL		; Point to next character
	LD	A,(HL)		; ..and get it
	CALL	TSTEOL		; Test for end of command
	JR	NZ,PARSER2	; Keep looping if not

	LD	(NXTCHR),HL	; Set pointer to next command
	POP	HL		; Get back pointer to current command tail

; This block of code parses two tokens in the command line into the two
; default FCBs at 5Ch and 6Ch.  It also sets a pointer to the command tail
; for later copying into the command tail buffer at 80h.  This code is used
; first when attempting to parse a normal command line and possibly again
; later when the entire user's command is treated as a tail to the extended
; command processor.  The resident JUMP and SAVE commands use it also, and
; the entry point is available at location CCP+9 for use by other programs.

PARSETAIL:
	LD	(TAILSV),HL	; Save pointer to command tail

				; Process first token

	LD	DE,TFCB		; Point to first default FCB
	PUSH	DE		; Save pointer while initializing
	CALL	INITFCB		; Initialize both default FCBs
	POP	DE
	CALL	SKSP		; Skip over spaces in command line
	CALL	NZ,SCANNER	; If not end of line, parse the token
				; ..into first FCB
	LD	(PARSEPTR),HL	; Save pointer to second token for reparsing

				; Process second token

	CALL	SKSP		; Skip over spaces
	RET	Z		; Done if end of line or end of command
	LD	DE,TFCB2	; Point to second default FCB
				; ..and fall through to SCANNER routine

;-----------------------------------------------------------------------------

; This routine processes a command line token pointed to by HL.  It attempts
; to interpret the token according to the form [DU:|DIR:]NAME.TYP and places
; the corresponding values into the FCB pointed to by DE.  On exit, HL points
; to the delimiter encountered at the end of the token.  The Z flag is set if
; a wild card was detected in the token.

SCANNER:
	XOR	A		; Initialize various flags
	LD	(TMPCOLON),A	; Set no colon
	LD	BC,(CURUSR)	; Get current drive and user into BC
	INC	B		; Shift drive range from 0..15 to 1..16
	LD	(TEMPUSR),BC	; Initialize temporary DU

	CALL	SCANFLD8	; Extract possible file name
	CP	':'		; Was terminating character a colon?
	JR	NZ,SCANTYPE	; If not, go on to extract file type
	LD	(TMPCOLON),A	; Otherwise, set colon and process DU/DIR
	INC	HL		; Point to character after colon

; Code for resolving directory specifications (macro RESOLVE is defined in
; Z33MAC.LIB).  RESOLVE returns with a nonzero value and a NZ flag setting
; if the DU/DIR specification cannot be resolved.  There are quite a few
; possibilities here.

		; Case where both forms are accepted

	 IF	ACCPTDIR AND ACCPTDU
	 IF	DUFIRST
	RESOLVE	DU,DIR		; Check DU: form before DIR: form
	 ELSE
	RESOLVE	DIR,DU		; Check DIR: form before DU: form
	 ENDIF	;dufirst
	 ENDIF	;accptdir and accptdu

		; Cases of only one form accepted

	 IF	ACCPTDU AND NOT ACCPTDIR
	RESOLVE	DU,		; Check only DU: form
	 ENDIF	;accptdu and not accptdir

	 IF	ACCPTDIR AND NOT ACCPTDU
	RESOLVE	DIR,		; Check only DIR: form
	 ENDIF	;accptdir and not accptdu

		; Case of neither form accepted

	 IF	NOT ACCPTDIR AND NOT ACCPTDU
	PUSH	HL		; Save pointer to command string
	INC	DE		; Point to first character of name
	LD	A,(DE)		; Get it
	DEC	DE		; Restore the pointer
	SUB	' '		; If no name is there, A=0 and Z flag set
	 ENDIF	;not accptdir and not accptdu

	PUSH	DE		; Save pointer to FCB again
	PUSH	AF		; Save bad directory flag
	LD	A,(TEMPDR)	; Set designated drive
	LD	(DE),A		; ..into FCB
	INC	DE		; Point to file name field
	CALL	IFCB		; Perform partial init (set user code)
	POP	AF		; Get bad directory flag back
	LD	(DUERRFLAG),A	; Save flag in parser code
	JR	Z,SCANNER1	; Branch if valid directory specified
	DEC	DE		; Back up to record count byte
	DEC	DE
	LD	(DE),A		; Store error flag there (NZ if error)
SCANNER1:
	POP	DE		; Get FCB pointer back
	POP	HL		; Restore pointer to command string
	CALL	SCANFLD8	; Scan for file name

; This code processes the file type specification in the token

SCANTYPE:
	LD	A,(HL)		; Get ending character of file name field
	EX	DE,HL		; Switch FCB pointer into HL
	LD	BC,8		; Offset to file type field
	ADD	HL,BC
	EX	DE,HL		; Switch pointers back

	LD	B,3		; Maximum characters in file type
	CP	'.'		; See if file type specified
	JR	NZ,SCANTYPE2	; If not, skip over file type parsing

	INC	HL		; Point to character after '.'
	PUSH	DE		; Save pointer to FCB file type
	CALL	SCANFIELD	; Parse file type into FCB
	POP	DE

SCANTYPE2:
	EX	DE,HL		; Swap pointers again
	LD	BC,5		; Offset from file type to S1 field in FCB
	ADD	HL,BC
	EX	DE,HL		; Swap pointers back
	LD	A,(TEMPUSR)	; Get specified user number
	LD	(DE),A		; ..and store in S1 byte of FCB

SCAN3:				; Skip to space character, character after an
				; ..equal sign, or to end of command
	LD	A,(HL)		; Get next character
	CP	' '+1		; Done if less than space
	JR	C,SCAN4
	CALL	TSTEOL		; Done if end of line or end of command
	JR	Z,SCAN4
	INC	HL		; Skip on to next character
	CP	'='		; If not equal sign
	JR	NZ,SCAN3	; ..keep scanning

SCAN4:				; Set zero flag if '?' in filename.typ

QMCNT	EQU	$+1		; Pointer for in-the-code modification
	LD	A,0		; Number of question marks
	OR	A		; Set zero flag
	RET

; This routine invokes SCANFIELD for a file name field.  It initializes the
; question mark count and preserves the FCB pointer.

SCANFLD8:
	XOR	A		; Initialize question mark count
	LD	(QMCNT),A
	PUSH	DE		; Save pointer to FCB
	LD	B,8		; Scan up to 8 characters
	CALL	SCANFIELD
	POP	DE		; Restore pointer to FCB
	RET

; This routine scans a command-line token pointed to by HL for a field whose
; maximum length is given by the contents of the B register.  The result is
; placed into the FCB buffer pointed to by DE.  The FCB must have had its name
; and type fields initialized before this routine is called.  Wild cards of
; '?' and '*' are expanded.  On exit, HL points to the terminating delimiter.

SCANFIELD:
	CALL	SDELM		; Done if delimiter encountered
	RET	Z
	INC	DE		; Point to next byte in FCB
	CP	'*'		; Is character a wild card?
	JR	NZ,SCANFLD1	; Continue if not

	LD	A,'?'		; Process '*' by filling with '?'s
	LD	(DE),A
	CALL	QCOUNTINC	; Increment count of question marks
	JR	SCANFLD2	; Skip so HL pointer left on '*'

SCANFLD1:			; Not wildcard character '*'
	LD	(DE),A		; Store character in FCB
	INC	HL		; Point to next character in command line
	CP	'?'		; Check for question mark (wild)
	CALL	Z,QCOUNTINC	; Increment question mark count
SCANFLD2:
	DJNZ	SCANFIELD	; Decrement char count until limit reached
SCANFLD3:
	CALL	SDELM		; Skip until delimiter
	RET	Z		; Zero flag set if delimiter found
	INC	HL		; Pt to next char in command line
	JR	SCANFLD3


; Subroutine to increment the count of question mark characters in the
; parsed file name.

QCOUNTINC:
	PUSH	HL
	LD	HL,QMCNT	; Point to count
	INC	(HL)		; Increment it
	POP	HL
	RET

;-----------------------------------------------------------------------------

; Validate the password pointed to by HL.  Prompt user for password entry
; and return zero if it is correct.

	 IF	PWCHECK

PASSCK:
	PUSH	HL		; Save pointer to password
	CALL	PRINT		; Prompt user
	DEFB	CR,LF,'PW?',' '+80h
	LD	HL,PWLIN	; Set up buffer for user input
	LD	BC,90AH		; Set 0ah (BDOS readln function) in C
	LD	(HL),B		; ..and 9 (max character count) in B
	EX	DE,HL		; Switch buffer pointer to DE

	 IF	PWNOECHO
	LD	A,0C9H		; Disable BIOS conout routine to
	LD	(BIOS+0CH),A	; ..suppress password echoing
	CALL	BDOSSAVE	; Get user input
	LD	A,0C3H		; Reenable BIOS conout routine
	LD	(BIOS+0CH),A
	 ELSE	;not pwnoecho
	CALL	BDOSSAVE	; Get user input
	 ENDIF	;pwnoecho

	EX	DE,HL		; Restore pointer to HL
	INC	HL		; Point to count of characters entered
	LD	A,(HL)		; Get character count
	INC	HL		; Point to first character
	PUSH	HL		; Save pointer while marking end of input
	CALL	ADDAH		; Advance HL to just past last character
	LD	(HL),' '	; Place space there
	POP	DE		; Restore pointer to beginning of user input
	POP	HL		; Restore pointer to password from NDR
	LD	B,8		; Maximum characters to compare
PWCK:
	LD	A,(DE)		; Get next user character
	CALL	UCASE		; Capitalize it
	CP	(HL)		; Compare to NDR
	RET	NZ		; No match
	CP	' '		; If last user character matched space in
	RET	Z		; ..NDR, then we have a complete match
	INC	HL		; If not done, point to next characters
	INC	DE
	DJNZ	PWCK		; (flags not affected by DJNZ)
	XOR	A		; Set zero flag and
	RET			; ..return Z to show success

	 ENDIF	; pwcheck

;-----------------------------------------------------------------------------

; This code attempts to interpret the token in the FCB pointed to by register
; pair DE as a DIR (named directory) prefix.  If it is successful, the drive
; and user values are stored in TEMPDR and TEMPUSR, the zero flag is set, and
; a value of zero is returned in register A.
;
; If the named directory is found to be password restricted, then the user is
; asked for the password (unless the directory is the one currently logged or
; the current IF state is false).  If an incorrect password is entered, the
; error handler is generally invoked directly.  The exception to this is when
; the transient program bit is set in the command status flag (this bit would
; be set by a non-CPR program that calls REPARSE).  In this case the default
; directory is returned, the zero flag is reset, and a nonzero value in
; returned in register A to show a bad directory.  In addition, the code in
; SCANNER will set record-count byte in the FCB to a nonzero value so that
; the calling program can detect the error.  [Note: if DU processing is also
; allowed and it follows DIR processing, DUSCAN will also be called.  Unless
; there is a passworded directory with a DU form, this will cause no trouble.]

	 IF	ACCPTDIR

DIRSCAN:

; If the DU form is not allowed, we have to detect a colon-only condition here.
; Otherwise DUSCAN will take care of it.

	INC	DE		; Point to first byte of directory form

	 IF	NOT ACCPTDU
	LD	A,(DE)		; Get first character of directory
	SUB	' '		; If it is a blank space
	RET	Z		; ..we have a successful directory resolution
	 ENDIF	;not accptdu

	EX	DE,HL		; Switch pointer to FCB to HL

	 IF	NDRENV		; If getting NDR address for Z3ENV
	LD	E,15H		; Offset to NDR address
	PUSH	HL		; Preserve pointer to FCB
	CALL	PKGOFF		; Get NDR address from ENV into DE
	POP	HL
	JR	Z,DIRERR	; Branch if no NDR implemented
	 ELSE	; using fixed address of NDR buffer
	LD	DE,Z3NDIR	; Point to first entry in NDR
	 ENDIF	; ndrenv

DIRSCAN1:
	LD	A,(DE)		; Get next character
	OR	A		; Zero if end of NDR
	JR	Z,DIRERR
	INC	DE		; Point to name of directory
	INC	DE
	PUSH	HL		; Save pointer to name we are looking for
	PUSH	DE		; Save pointer to NDR entry
	LD	B,8		; Number of characters to compare

DIRSCAN2:
	LD	A,(DE)
	CP	(HL)
	JR	NZ,DIRSCAN3	; If no match, quit and go on to next DIR
	INC	HL		; Point to next characters to compare
	INC	DE
	DJNZ	DIRSCAN2	; Count down

DIRSCAN3:
	POP	DE		; Restore pointers
	POP	HL
	JR	Z,DIRSCAN4	; Branch if we have good match

	EX	DE,HL		; Advance to next entry in NDR
	LD	BC,16		; 8 bytes for name + 8 bytes for password
	ADD	HL,BC
	EX	DE,HL
	JR	DIRSCAN1	; Continue comparing

; If ACCPTDU is enabled, we can share similar code in DUSCAN and do not need
; the code here.

	 IF	NOT ACCPTDU
DIRERR:				; No match found
	DEC	A
	RET
	 ENDIF	;not accptdu

DIRSCAN4:			; Match found
	EX	DE,HL		; Switch pointer to NDR entry into HL
	PUSH	HL		; ..and save it for later
	DEC	HL		; Point to user corresponding to the DIR
	LD	C,(HL)		; Get user value into C
	DEC	HL		; Point to drive
	LD	B,(HL)		; Get it into B

	 IF	PWCHECK

	LD	HL,(CURUSR)	; Get current drive/user into HL
	INC	H		; Shift drive to range 1..16
	XOR	A		; Clear carry flag
	SBC	HL,BC		; Compare
	POP	HL		; Restore pointer to NDR entry
	JR	Z,SETDU		; If same, accept values without PW checking

; If WPASS is set, then password checking is bypassed when the wheel byte is
; set.

	 IF	WPASS
	LD	A,(Z3WHL)	; Get wheel byte
	OR	A		; If wheel byte set
	JR	NZ,SETDU	; ..skip checking passwords
	 ENDIF	;wpass

; This code is a bit tricky.  We do not want to be asked for passwords for
; named directory references in commands when the current IF state is false.
; So, first we check to see if there is a password on the directory.  If not,
; we proceed to set the temporary DU to the specified directory.  If there is
; a password, we check the current IF state.  If it is false, we do not check
; passwords and pretend there was no password.  However, we leave the current
; directory in effect.  This will work properly in all but one rare
; circumstance.  When the command is an 'OR' command with a reference to a
; passworded named directory (e.g., "OR EXIST SECRET:FN.FT"), the password
; will not be requested and the current directory will be used instead of the
; specified one.

	PUSH	BC		; Save requested drive/user
	LD	BC,8		; Point to password in NDR
	ADD	HL,BC
	LD	A,(HL)		; Get first character of password
	CP	' '		; Is there a password?

	 IF	FCP EQ 0	; If FCP not implemented ...

	CALL	NZ,PASSCK	; Perform password checking if pw present

	 ELSE	;fcp ne 0	; FCP implemented ...

	JR	Z,DIRSCAN5	; If no pw, skip ahead
	CALL	IFTEST		; Otherwise, test current IF state
	POP	BC		; Restore BC in case we return now
	RET	Z		; If false IF in effect, fake success without
				; ..checking password (but TEMPDR/TEMPUSR not
				; ..set)
	PUSH	BC		; Otherwise, save BC again
	CALL	PASSCK		; Perform password checking

	 ENDIF	;fcp eq 0

DIRSCAN5:
	POP	BC		; Restore requested drive/user
	JR	Z,SETDU		; If not bad password, set it up
	LD	A,(CMDSTATFL)	; See if external invocation (disable
	BIT	3,A		; ..error handling if so)
	RET	NZ		; Return NZ to show bad directory
	LD	A,ECBADPASS	; Error code for bad password
	JP	ERROR

	 ELSE	;not pwcheck

	POP	HL		; Clean up stack
	 IF	ACCPTDU		; If we cannot fall through, branch
	JR	SETDU
	 ENDIF	;accptdu

	 ENDIF	;pwcheck

	 IF	NOT ACCPTDU	; If NOT ACCPTDU, we have to supply code here
SETDU:
	LD	(TEMPUSR),BC
	XOR	A		; Set Z to flag success
	RET
	 ENDIF	;not accptdu

	 ENDIF	;accptdir

;-----------------------------------------------------------------------------

; This code attempts to interpret the token in the FCB pointed to by register
; pair DE as a DU (drive/user) prefix.  If it is successful, the drive and
; user values are stored in TEMPDR and TEMPUSR, the zero flag is set, and a
; value of zero is returned in register A.  Otherwise the zero flag is reset
; and a nonzero value is returned in register A.
;
; The ADUENV option allows acceptance of the DU form to be controlled by the
; DUOK flag in the environment descriptor.  An additional feature of this code
; when the ADUENV option is enabled is that a DU value is always accepted,
; even if DUOK is off and even if it is outside the normally allowed range,
; if it corresponds to a named directory with no password.  The currently
; logged directory is unconditionally acceptable (if you got there once, you
; can stay as long as you like without further hassles).

	 IF	ACCPTDU		; Allow DU: form

DIRERR:				; This code may do double duty for DIRSCAN
				; ..above
DUERR:
	XOR	A		; Return NZ to show failure
	DEC	A
	RET

DUSCAN:
	EX	DE,HL		; Switch FCB pointer to HL
	INC	HL		; Point to first byte of file name in FCB

	LD	BC,(CURUSR)	; Preset C to current user, B to current drive
	LD	A,(HL)		; Get possible drive specification
	SUB	'A'		; Otherwise convert to number 0..15
	JR	C,DUSCAN1	; If < 0, leave B as is
	CP	16
	JR	NC,DUSCAN1	; If > 15, leave B as is
	LD	B,A		; Otherwise use value given
	INC	HL		; ..and point to next character

DUSCAN1:
	INC	B		; Shift drive to range 1..16
	LD	A,(HL)		; Get possible user specification
	CP	' '
	JR	Z,DUSCAN2	; If none present, leave C as is
	PUSH	BC		; Save DU values in BC
	CALL	DECIMAL1	; Get specified decimal user number into BC
	POP	HL		; Restore values to HL
	JR	C,DUERR		; Return NZ if invalid decimal conversion
	LD	A,B		; Get high byte of result
	OR	A		; Make sure it is zero
	RET	NZ		; If not, return NZ to show bad user number
	LD	B,H		; DU value is now in BC

; If the specified directory is the currently logged directory, accept it
; even if it is out of range and/or password protected.

DUSCAN2:
	LD	HL,(CURUSR)	; Get current drive/user into HL
	INC	H		; Shift drive to range 1..16
	XOR	A		; Clear carry flag
	SBC	HL,BC		; Compare values
	JR	Z,SETDU

; If the specified DU corresponds to a named directory with no password, or
; if WPASS is enabled so that password checking is not performed when the
; wheel byte is set, then accept it.

	 IF	Z3NDIR NE 0

	CALL	DU2DIR		; See if there is a matching named directory
	JR	Z,DUSCAN3	; If not, skip on

	 IF	PWCHECK		; If passwords are being checked...

	 IF	WPASS
	LD	A,(Z3WHL)	; Get wheel byte
	OR	A		; If wheel byte set, skip checking passwords
	JR	NZ,SETDU	; ..and accept the DU values
	 ENDIF	;wpass

	LD	DE,9		; Advance to password
	ADD	HL,DE
	LD	A,(HL)		; Get first character of password
	CP	' '
	JR	Z,SETDU		; If none, we have a valid DU

	 ELSE	;not pwcheck

	JR	SETDU		; Set the DU

	 ENDIF	;pwcheck

	 ENDIF	;z3ndir ne 0

DUSCAN3:
	 IF	ADUENV		; Check DUOK flag in ENV
	LD	A,(DUOKFL)	; Get flag
	OR	A		; If DU not accepted
	JR	Z,DUERR		; ..skip over the DU scan
	 ENDIF	;aduenv

	 IF	DUENV		; If getting max drive and user from ENV
	LD	HL,(MAXDRENV)	; Get max drive into L and max user into H
	LD	A,L		; Test drive value
	CP	B
	JR	C,DUERR
	LD	A,H		; Test user value
	CP	C
	JR	C,DUERR
	 ELSE			; Using fixed values of max DU
	LD	A,MAXDISK
	CP	B
	JR	C,DUERR
	LD	A,MAXUSR
	CP	C
	JR	C,DUERR
	 ENDIF	;duenv

SETDU:
	LD	(TEMPUSR),BC
	XOR	A		; Set Z to flag success
	RET

	 ENDIF	; accptdu

; End ZCPR33-3.Z80

	PAGE

; ZCPR33-4.Z80

;=============================================================================
;
;	G E N E R A L    S U B R O U T I N E S    S E C T I O N
;
;=============================================================================


;-----------------------------------------------------------------------------
;
;	CHARACTER I/O BDOS ROUTINES
;
;-----------------------------------------------------------------------------

; Get uppercase character from console (with ^S processing).  Registers B,
; D, H, and L are preserved.  The character is returned in A.

CONIN:
	LD	C,1		; BDOS conin function
	CALL	BDOSSAVE
				; Fall through to UCASE

;--------------------

; Convert character in A to upper case.  All registers except A are preserved.

UCASE:
	AND	7FH		; Mask out msb
	CP	61H		; Less than lower-case 'a'?
	RET	C		; If so, return
	CP	7BH		; Greater than lower-case 'z'?
	RET	NC		; If so, return
	AND	5FH		; Otherwise capitalize
	RET

;----------------------------------------

; Output CRLF

CRLF:
	CALL	PRINT
	DB	CR
	DB	LF OR 80H
	RET

;----------------------------------------

; Output character in A to the console.  All registers are preserved.

CONOUT:
	PUSH	DE
	PUSH	BC
	LD	C,2		; BDOS conout function
OUTPUT:				; Entry point for LCOUT below
	LD	E,A
	CALL	BDOSSAVE
	POP	BC
	POP	DE
	RET

;----------------------------------------

; Print the character string immediately following the call to this routine.
; The string terminates with a character whose high bit is set or with a null.
; At entry point PRINTC the string is automatically preceded by a
; carriage-return-linefeed sequence.  All registers are preserved except A.

PRINTC:
	CALL	CRLF		; New line

PRINT:
	EX	(SP),HL		; Get pointer to string
	CALL	PRINTHL		; Print string
	EX	(SP),HL		; Restore HL and set return address
	RET

;----------------------------------------

; Print the character string pointed to by HL.  Terminate on character with
; the high bit set or on a null character.  On return HL points to the byte
; after the last character displayed.  All other registers except A are
; preserved.

PRINTHL:
	LD	A,(HL)		; Get a character
	INC	HL		; Point to next byte
	OR	A		; End of string null?
	RET	Z
	PUSH	AF		; Save flags
	AND	7FH		; Mask out msb
	CALL	CONOUT		; Print character
	POP	AF		; Get flags
	RET	M		; String terminated by msb set
	JR	PRINTHL


;-----------------------------------------------------------------------------
;
;	FILE I/O BDOS ROUTINES
;
;-----------------------------------------------------------------------------

; Read a record from a file to be listed or typed

	 IF	LTON		; Only needed for LIST and TYPE functions

READF:
	LD	DE,TFCB
	JR	READ

	 ENDIF	; lton

;----------------------------------------

; Read a record from the command file named in CMDFCB

READCMD:
	LD	DE,CMDFCB

; Read a record from file whose FCB is pointed to by DE

READ:
	LD	C,14H		; Read-sequential function
				; Fall through to BDOSSAVE

;--------------------

; Call BDOS for read and write operations.  The flags are set appropriately.
; The BC, DE, and HL registers are preserved.

BDOSSAVE:
	PUTREG
	CALL	BDOS
	GETREG
	OR	A		; Set flags
NOTE:				; This return is used for NOTE command, too
	RET


;-----------------------------------------------------------------------------
;
;	MISCELLANEOUS BDOS ROUTINES
;
;-----------------------------------------------------------------------------

; Set DMA address.  At the entry point DEFLTDMA the address is set to the
; default value of 80H.  At the entry point DMASET it is set to the value
; passed in the DE registers.

DEFLTDMA:
	LD	DE,TBUFF
DMASET:
	LD	C,1AH
	JR	BDOSSAVE

;----------------------------------------

; Log in the drive value passed in the A register (A=0).

SETDRIVE:
	LD	E,A
	LD	C,0EH
	JR	BDOSSAVE

;----------------------------------------

; Open a file.  At entry point OPENCMD the file is the one specified in
; CMDFCB, and the current record is set to zero.  At entry point OPEN
; the file whose FCB is pointed to by DE is used.

OPENCMD:
	XOR	A		; Set current record to 0
	LD	(CMDFCB+32),A
	LD	DE,CMDFCB	; Command file control block
				; Fall through to open

OPEN:
	LD	C,0FH		; BDOS open function
				; Fall through to BDOSTEST

;--------------------

; Invoke BDOS for disk functions.  This routine increments the return code in
; register A so that the zero flag is set if there was an error.  Registers
; BC, DE, and HL are preserved.

BDOSTEST:
	CALL	BDOSSAVE
	INC	A		; Set zero flag for error return
	RET

;----------------------------------------

; Close file whose FCB is pointed to by DE.

	 IF	SAVEON OR SUBON
CLOSE:
	LD	C,10H
	JR	BDOSTEST
	 ENDIF	;saveon or subon

;----------------------------------------

; Search for first matching file.  At entry point SRCHFST1 the first default FCB
; is used.  At entry point SRCHFST the FCB pointed to by DE is used.

	 IF	DIRON OR ERAON OR RENON OR SAVEON
SRCHFST1:
	LD	DE,TFCB		; Use first default FCB
	 ENDIF	;diron or eraon or renon or saveon

SRCHFST:
	LD	C,11H
	JR	BDOSTEST

;-----------------------------------------------------------------------------

; Search for next matching file whose FCB is pointed to by DE.

	 IF	DIRON OR ERAON	; Only needed by DIR and ERA functions
SRCHNXT:
	LD	C,12H
	JR	BDOSTEST
	 ENDIF	; diron or eraon

;-----------------------------------------------------------------------------

; Kill any submit file that is executing.

	 IF	SUBON

SUBKIL:
	LD	HL,SUBFLAG	; Check for submit file in execution
	LD	A,(HL)
	OR	A		; 0=no
	RET	Z		; If none executing, return now
				; Kill submit file
	XOR	A
	LD	(HL),A		; Zero submit flag
	CALL	SETUSER		; Log in user 0
	LD	DE,SUBFCB	; Delete submit file
				; ..by falling through to delete routine

	 ENDIF	; subon

;--------------------

; Delete file whose FCB is pointed to by DE.

	 IF	ERAON OR RENON OR SAVEON OR SUBON
DELETE:
	LD	C,13H
	JR	BDOSSAVE
	 ENDIF	;eraon or renon or saveon or subon

;-----------------------------------------------------------------------------

; Get and set user number.  Registers B, D, H, and L are preserved.  Register
; E is also preserved at entry point SETUSER1.

GETUSER:
	LD	A,0FFH		; Get current user number
SETUSER:
	LD	E,A		; User number in E
SETUSER1:
	LD	C,20H		; Get/Set BDOS function
	JR	BDOSSAVE


;-----------------------------------------------------------------------------
;
;	GENERAL UTILITY ROUTINES
;
;-----------------------------------------------------------------------------


; This subroutine checks to see if a program loaded at an address given by HL
; has a Z3ENV header.  If the header is not present, the zero flag is reset.
; If it is present, the zero flag is set, and on return HL points to the
; environment-type byte and A contains that byte.

Z3CHK:
	LD	DE,Z3ENV+3	; Point to 'Z3ENV' string in ENV
	INC	HL		; Advance three bytes to possible program
	INC	HL		; ..header
	INC	HL
	LD	B,5		; Characters to compare
Z3CHK1:				; Check for Z3 ID header
	LD	A,(DE)		; Get character from ENV descriptor
	CP	(HL)		; Compare it to loaded file
	RET	NZ		; Quit now if mismatch
	INC	HL		; If same, advance to next characters
	INC	DE		; ..and continue comparing
	DJNZ	Z3CHK1		; (flags not affected by DJNZ)
	LD	A,(HL)		; Return the environment type in A
	RET			; Return Z if all 5 characters match

;----------------------------------------

; Subroutine to skip over spaces in the buffer pointed to by HL.  On return,
; the zero flag is set if we encountered the end of the line or a command
; separator character.

SKSP:
	LD	A,(HL)		; Get next character
	INC	HL		; Point to the following character
	CP	' '		; Space?
	JR	Z,SKSP		; If so, keep skipping
	DEC	HL		; Back up to non-space
				; ..and fall through

;--------------------

; Subroutine to check if character is the command separator or marks the end
; of the line.

TSTEOL:
	OR	A		; End of command line?
	RET	Z		; Return with zero flag set
	CP	CMDSEP		; Command separator?
	RET			; Return with flag set appropriately

;----------------------------------------

; Initialize complete FCB pointed to by DE

INITFCB:
	XOR	A
	LD	(DE),A		; Set default disk (dn byte is 0)
	INC	DE		; Point to file name field
	CALL	IFCB		; Fill 1st part of FCB
				; Fall through to IFCB to run again

;--------------------

; Initialize part of FCB whose file name field is pointed to by DE on entry.
; The file name and type are set to space characters; the EX, S2, RC, and the
; following CR (current record ) or DN (disk number) fields are set to zero.
; The S1 byte is set to the current user number.  On exit, DE points to the
; byte at offset 17 in the FCB (two bytes past the record count byte).

IFCB:
	LD	B,11		; Store 11 spaces for file name and type
	LD	A,' '
	CALL	FILL
	XOR	A
	LD	(DE),A		; Set extent byte to zero
	INC	DE
	LD	A,(CURUSR)
	LD	(DE),A		; Set S1 byte to current user
	INC	DE
	LD	B,3		; Store 3 zeroes
	XOR	A		; Fall thru to fill

;--------------------

; Fill memory pointed to by DE with character in A for B bytes

FILL:
	LD	(DE),A		; Fill with byte in A
	INC	DE		; Point to next
	DJNZ	FILL
	RET

;----------------------------------------

; Subroutine to display the 'no file' error message for the built-in
; commands DIR, ERA, LIST, TYPE, and/or REN.

	 IF	DIRON OR ERAON

PRNNF:
	CALL	PRINTC		; No file message
	DEFB	'No Fil','e'+80h
	RET
	 ENDIF ; diron or eraon

;----------------------------------------

; Calculate address of command table in package from Z3ENV.  On entry, E
; contains the offset to the address of the package in the environment.  On
; exit, DE points to the beginning of the package and HL points to the fifth
; byte (where the command table starts in the RCP and FCP modules).  The zero
; flag is set on return if the package is not supported.

	 IF	FCPENV OR RCPENV OR NDRENV
PKGOFF:
	LD	HL,Z3ENV	; Point to beginning of ENV descriptor
	LD	D,0		; Make DE have offset
	ADD	HL,DE		; ..and add it
	LD	A,(HL)		; Get low byte of package address
	INC	HL		; Point to high byte
	LD	H,(HL)		; ..and get it
	LD	L,A		; Move full address into HL
	OR	H		; Set zero flag if no package
	LD	DE,5		; Offset to start of table
	EX	DE,HL		; Preserve start address of package in DE
	ADD	HL,DE		; Pointer to 5th byte of package in HL
	RET			; Return with zero flag set appropriately

	 ENDIF	;fcpenv or rcpenv or ndrenv

;----------------------------------------

; This subroutine checks to see if we are in a false IF state.  If that is
; the case, the routine returns with the zero flag set.  If there is not active
; IF state or if it is true, then the zero flag is reset.

	 IF	FCP NE 0	; Omit code if FCP not implemented

IFTEST:
	LD	BC,(IFPTRFL)	; Current IF pointer into C, IF status into B
	LD	A,C		; See if any IF in effect
	OR	A
	JR	Z,IFTEST1	; Branch if no IF state is active
	AND	B		; Mask the current IF status
	RET
IFTEST1:
	DEC	A		; Reset the zero flag
	RET

	 ENDIF	;fcp ne 0

;----------------------------------------

; Print the command prompt with DU and/or DIR (but without any trailing
; character).  This is also the code in which the current drive and user
; will be stored.  The conditional assemblies are somewhat involved because
; of the possibilities of either or both of the DU or DIR forms being omitted
; from the prompt.

PROMPT:
	CALL	CRLF

	 IF	INCLDU		; If drive/user in prompt

	LD	HL,(CURUSR)	; Get current drive/user into HL

; If INCLENV is enabled, the drive and user (DU) will be included in the
; prompt based on the state of the DUOK flag in the environment.  If INCLENV
; is disabled, the DU form will always be included if INCLDU is on.

	 IF	INCLENV
	LD	A,(DUOKFL)	; If ENV disallows DU,
	OR	A		; ..then don't show it in
	JR	Z,PROMPT2	; ..the prompt, either
	 ENDIF	;inclenv

	LD	A,H		; Get current drive
	ADD	A,'A'		; Convert to ascii A-P
	CALL	CONOUT
	LD	A,L		; Get current user

	 IF	SUPRES		; If suppressing user # report for user 0
	OR	A
	JR	Z,PROMPT2
	 ENDIF

	CP	10		; User < 10?
	JR	C,PROMPT1

	 IF	HIGHUSER	; If allowing users 16..31

	LD	C,'0'-1
PROMPT0:
	INC	C
	SUB	10
	JR	NC,PROMPT0
	ADD	A,10
	LD	B,A
	LD	A,C
	CALL	CONOUT
	LD	A,B

	 ELSE	;using only standard user numbers 0..15

	SUB	10		; Subtract 10 from user number
	PUSH	AF		; Save low digit
	CALL	PRINT		; Display a '1' for tens digit
	DEFB	'1' or 80h
	POP	AF

	 ENDIF	;highuser

PROMPT1:
	ADD	A,'0'		; Output 1's digit (convert to ascii)
	CALL	CONOUT
PROMPT2:
	 ENDIF	; incldu

				; Display named directory

	 IF	INCLDIR

	 IF	INCLDU
	LD	B,H		; Copy drive/user from HL to BC
	LD	C,L		; ..(saves a byte)
	 ELSE
	LD	BC,(CURUSR)	; Get current drive and user into BC
	 ENDIF	;incldu

	INC	B		; Switch drive to range 1..16
	CALL	DU2DIR		; See if there is a corresponding DIR form
	RET	Z		; If not, return now

	 IF	INCLDU		; Separate DU and DIR with colon

	 IF	INCLENV
	LD	A,(DUOKFL)	; If not displaying DU, then
	OR	A		; ..don't send separator, either
	LD	A,':'		; Make the separator
	CALL	NZ,CONOUT	; ..and send if permitted
	 ELSE
	CALL	PRINT		; Put in colon separator
	DEFB	':' or 80h
	 ENDIF	;inclenv

	 ENDIF	; incldu

	LD	B,8		; Max of 8 chars in DIR name
PROMPT3:
	INC	HL		; Point to next character in DIR name
	LD	A,(HL)		; ..and get it
	CP	' '		; Done if space
	RET	Z
	CALL	CONOUT		; Print character
	DJNZ	PROMPT3		; Count down

	 ENDIF	; incldir

	RET

;-----------------------------------------------------------------------------

; Subroutine to convert DU value in BC into pointer to a matching entry in
; the NDR.  If there is no match, the routine returns with the zero flag set.
; If a match is found, the zero flag is reset, and the code returns with HL
; pointing to the byte before the directory name.

	 IF	Z3NDIR NE 0

DU2DIR:

	 IF	NDRENV		; If getting NDR address from environment
	LD	E,15H		; Offset to NDR in Z3ENV
	CALL	PKGOFF		; Get address of NDR into DE
	EX	DE,HL		; ..and switch into HL
	RET	Z		; If no NDR, return with zero flag set
	JR	DU2DIR2
	 ELSE
	LD	HL,Z3NDIR-17	; Scan directory for match
	 ENDIF	;ndrenv

DU2DIR1:			; Advance to next entry in NDR
	LD	DE,16+1		; Skip user (1 byte) and name/pw (16 bytes)
	ADD	HL,DE

DU2DIR2:
	LD	A,(HL)		; End of NDR?
	OR	A
	RET	Z		; If so, return with zero flag set

	INC	HL		; Point to user number in NDR entry
	CP	B		; Compare drive values
	JR	NZ,DU2DIR1	; If mismatch, back for another try
	LD	A,(HL)		; Get user number
	SUB	C		; ..and compare
	JR	NZ,DU2DIR1	; If mismatch, back for another try
	DEC	A		; Force NZ to show successful match
	RET

	 ENDIF	;z3ndir ne 0

;-----------------------------------------------------------------------------

; This routine gets the next line of input for the command buffer.  The
; following order of priority is followed:
;	If ZEX is active, the next line is obtained from ZEX
;	If a submit file is running, its last record provides the input
;	If there is a command line on the shell stack, use it
;	Finally, if none of the above, the input is obtained from the user

READBUF:

	LD	A,(ZEXRUNFL)	; Get ZEX-running flag
	OR	A
	JR	NZ,USERINPUT	; If ZEX running, go directly to user input

	 IF	SUBON		; If submit facility is enabled, check for it

	LD	A,(SUBFLAG)	; Test for submit file running
	OR	A
	JR	Z,SHELLINPUT	; If not, go on to possible shell input

	XOR	A		; Log into user 0
	CALL	SETUSER
	CALL	DEFLTDMA	; Initialize DMA pointer
	LD	DE,SUBFCB	; Point to submit file FCB
	CALL	OPEN		; Try to open file
	JR	Z,READBUF1	; Branch if open failed

	LD	HL,SUBFRC	; Point to record count in submit FCB
	LD	A,(HL)		; Get the number of records in file
	DEC	A		; Reduce to number of last record
	LD	(SUBFCR),A	; ..and put into current record field
	CALL	READ		; Attempt to read submit file
	JR	NZ,READBUF1	; Branch if read failed

	DEC	(HL)		; Reduce file record cound
	DEC	HL		; Point to S2 byte of FCB (yes, this is req'd!)
	LD	(HL),A		; Stuff a zero in there (A=0 from call to READ)
	CALL	CLOSE		; Close the submit file one record smaller
	JR	Z,READBUF1	; Branch if close failed

; Now we copy the line read from the file into the multiple command line
; buffer

	LD	DE,CHRCNT	; Point to command length byte in command buffer
	LD	HL,TBUFF	; Point to sector read in from submit file

	 IF	BUFLEN GT 7FH	; If command line buffer is longer than record,
	LD	BC,80H		; ..then copy entire record from $$$.SUB file
	 ELSE	;buflen le 7fh	; Otherwise copy only enough to fill
	LD	BC,BUFLEN+1	; ..the command line buffer
	 ENDIF	;buflen gt 7fh

	LDIR			; Transfer line from submit file to buffer

; We now deal with various options that control the display of commands fed
; to the command processor from a submit file.

	 IF	SUBNOISE GT 0	; If subnoise = 0 we omit all this display code

	 IF	SUBNOISE EQ 1	; If subnoise = 1 we follow the quiet flag
	LD	A,(QUIETFL)
	OR	A
	JR	NZ,READBUF0	; If quiet, skip echoing the command
	 ENDIF	;subnoise eq 1

	CALL	PROMPT		; Print prompt
	CALL	PRINT		; Print submit prompt trailer
	DEFB	SPRMPT OR 80H
	LD	HL,CMDLIN	; Print command line
	CALL	PRINTHL

	 ENDIF	;subnoise gt 0

READBUF0:
	CALL	BREAK		; Check for abort (any char)
	RET	NZ		; If no ^C, return to caller and run

READBUF1:
	CALL	SUBKIL		; Kill submit file and abort
	JP	RESTART		; Restart CPR

	 ENDIF	; subon

SHELLINPUT:
	LD	HL,SHSTK	; Point to shell stack
	LD	A,(HL)		; Check first byte
	CP	' '+1		; See if any entry
	JR	C,USERINPUT	; Get user input if none

	LD	DE,CMDLIN	; Point to first character of command line
	LD	BC,SHSIZE	; Copy shell line into command line buffer
	LDIR			; Do copy
	EX	DE,HL		; HL points to end of line
	LD	A,1		; Set command status flag to show
	LD	(CMDSTATFL),A	; ..that a shell has been invoked
	JR	READBUF3	; Store ending zero and exit

USERINPUT:
	CALL	PROMPT		; Print prompt
	CALL	PRINT		; Print prompt trailer
	DEFB	CPRMPT OR 80H
	LD	C,0AH		; Read command line from user
	LD	DE,BUFSIZ	; Point to buffer size byte of command line
	CALL	BDOS

				; Store null at end of line

	LD	HL,CHRCNT	; Point to character count
	LD	A,(HL)		; ..and get its value
	INC	HL		; Point to first character of command line
	CALL	ADDAH		; Make pointer to byte past end of command line
READBUF3:
	LD	(HL),0		; Store ending zero
	RET

;-----------------------------------------------------------------------------

; Check for any character from the user console.  Return with the character
; in A.  If the character is a control-C, then the zero flag will be set.

	 IF	SUBON OR DIRON OR ERAON OR LTON

BREAK:
	LD	C,0BH		; BDOS console status function
	CALL	BDOSSAVE	; Call BDOS and set flags
	CALL	NZ,CONIN	; Get input character if there is one
	CP	'C'-'@'		; Check for abort
	RET

	 ENDIF	; subon or diron or eraon or lton

;-----------------------------------------------------------------------------

; Add A to HL (HL=HL+A)

ADDAH:
	ADD	A,L
	LD	L,A
	RET	NC
	INC	H
	RET

;-----------------------------------------------------------------------------

; The routine NUMBER evaluates a string in the first FCB as either a decimal
; or, if terminated with the NUMBASE hexadecimal marker, a HEX number.  If the
; conversion is successful, the value is returned as a 16-bit quantity in BC.
; If an invalid character is encountered in the string, the routine returns
; with the carry flag set and HL pointing to the offending character.

	 IF	SAVEON

NUMBER:
	LD	HL,TFCB+8	; Set pointer to end of number string
	LD	BC,8		; Number of characters to scan
	LD	A,NUMBASE	; Scan for HEX identifier
	CPDR			; Do the search
	JR	NZ,DECIMAL	; Branch if HEX identifier not found

	INC	HL		; Point to HEX marker
	LD	(HL),' '	; Replace HEX marker with valid terminator
				; ..and fall through to HEXNUM

	 ENDIF	;saveon

;----------------------------------------

; At this entry point the character string in the first default FCB is
; converted as a hexadecimal number (there must NOT be a HEX marker).

HEXNUM:
	LD	HL,TFCB+1	; Point to string in first FCB

; At this entry point the character string pointed to by HL is converted
; as a hexadecimal number (there must be NO HEX marker at the end).

HEXNUM1:
	LD	DE,16		; HEX radix base
	JR	RADBIN		; Invoke the generalized conversion routine

;----------------------------------------

; This entry point performs decimal conversion of the string in the first
; default FCB.

DECIMAL:
	LD	HL,TFCB+1	; Set pointer to number string

; This entry point performs decimal conversion of the string pointed to
; by HL.

DECIMAL1:
	LD	DE,10		; Decimal radix base
				; Fall through to generalized
				; ..radix conversion routine

; This routine converts the string pointed to by HL using the radix passed in
; DE.  If the conversion is successful, the value is returned in BC.  HL points
; to the character that terminated the number, and A contains that character.
; If an invalid character is encountered, the routine returns with the carry
; flag set, and HL points to the offending character.

RADBIN:
	LD	BC,0		; Initialize result
RADBIN1:
	OR	A		; Make sure carry is reset
	CALL	SDELM		; Test for delimiter (returns Z if delimiter)
	RET	Z		; Return if delimiter encountered

	SUB	'0'		; See if less than '0'
	RET	C		; Return with carry set if so
	CP	10		; See if in range '0'..'9'
	JR	C,RADBIN2	; Branch if it is valid
	CP	'A'-'0'		; Bad character if < 'A'
	RET	C		; ..so we return with carry set
	SUB	7		; Convert to range 10..15
RADBIN2:
	CP	E		; Compare to radix in E
	CCF			; Carry should be set; this will clear it
	RET	C		; If carry now set, we have an error

	INC	HL		; Point to next character
	PUSH	BC		; Push the result we are forming onto the stack
	EX	(SP),HL		; Now HL=result, (sp)=source pointer
	CALL	MPY16		; HLBC = previous$result * radix
	LD	H,0		; Discard high 16 bits and
	LD	L,A		; ..move current digit into HL
	ADD	HL,BC		; Form new result
	LD	C,L		; Move it into BC
	LD	B,H
	POP	HL		; Get string pointer back
	JR	RADBIN1		; Loop until delimiter

;-----------------------------------------------------------------------------

; This routine multiplies the 16-bit values in DE and HL and returns the
; 32-bit result in HLBC (HL has high 16 bits; BC has low 16 bits).  Register
; pair AF is preserved.

MPY16:
	EX	AF,AF'		; Save AF
	LD	A,H		; Transfer factor in HL to A and C
	LD	C,L
	LD	HL,0		; Initialize product
	LD	B,16		; Set bit counter
	RRA			; Shift AC right so first multiplier bit
	RR	C		; ..is in carry flag
MP161:
	JR	NC,MP162 	; If carry not set, skip the addition
	ADD	HL,DE		; Add multiplicand
MP162:
	RR	H		; Rotate HL right, low bit into carry
	RR	L
	RRA			; Continue rotating through AC, with
	RR	C		; ..next multiplier bit moving into carry
	DJNZ	MP161		; Loop through 16 bits

	LD	B,A		; Move A to B so result is in HLBC
	EX	AF,AF'		; Restore original AF registers
	RET

;-----------------------------------------------------------------------------

; This routine checks for a delimiter character pointed to by HL.  It returns
; with the character in A and the zero flag set if it is a delimiter.  All
; registers are preserved except A.

SDELM:
	LD	A,(HL)		; Get the character
	EXX			; Use alternate register set (shorter code)
	LD	HL,DELDAT	; Point to delimiter list
	LD	BC,DELEND-DELDAT; Length of delimiter list
	CPIR			; Scan for match
	EXX			; Restore registers
	RET			; Returns Z if delimiter

DELDAT:				; List of delimiter characters
	DB	' '
	DB	'='
	DB	'_'
	DB	'.'
	DB	':'
	DB	';'
	DB	'<'
	DB	'>'
	DB	','
	DB	0
	 IF	CMDSEP NE ';'
	DB	CMDSEP
	 ENDIF	;cmdsep ne ';'
DELEND:

;-----------------------------------------------------------------------------

; Log into DU contained in FCB pointed to by DE.  Registers DE are preserved;
; all others are changed.  Explicit values for the temporary drive and user
; are extracted from the FCB.  If the record-count byte has an FF in it, that
; is a signal that the directory specification was invalid.  We then invoke
; the error handler.

	 IF	DIRON OR ERAON OR LTON OR RENON OR SAVEON

FCBLOG:
	PUSH	DE		; Save pointer to FCB
	EX	DE,HL
	LD	A,(HL)		; Get drive
	LD	BC,13		; Offset to S1 field
	ADD	HL,BC
	LD	C,(HL)		; Get user into C
	OR	A		; See if drive value was 0
	JR	NZ,FCBLOG1	; If not, branch ahead
	LD	A,(CURDR)	; Otherwise substitute current drive
	INC	A		; ..shifted to range 1..16
FCBLOG1:
	LD	B,A		; Get drive into B
	LD	(TEMPUSR),BC	; Set up temporary DU values
	CALL	LOGTEMP		; ..and log into it
	POP	DE		; Restore pointer to FCB

; Now check to make sure that the directory specification was valid.

	INC	HL		; Advance pointer to record-count byte
	INC	HL
	LD	A,(HL)		; See if it is nonzero
	OR	A
	JP	NZ,BADDIRERR	; If so, invoke error handler

	RET			; Otherwise return

	 ENDIF	;diron or eraon or lton or renon or saveon

;-----------------------------------------------------------------------------

; Log into the temporary directory.  Registers B, H, and L are preserved.

LOGTEMP:
	LD	DE,(TEMPUSR)	; Set D = tempdr, E = tempusr
	CALL	SETUSER1	; Register D is preserved during this call
	LD	A,D		; Move drive into A
	DEC	A		; Adjust for drive range 0..15
	JP	SETDRIVE	; Log in new drive and return

;-----------------------------------------------------------------------------

; This routine scans the command table pointed to by HL for the command name
; stored in the command FCB.  If the command is not found, the routine returns
; with the zero flag reset.  If the command is found, the address vector is
; stored in EXECADR and the zero flag is set.

CMDSCAN:
	LD	B,(HL)		; Get length of each command
	INC	HL		; Point to first command name

SCANNEXT:
	LD	A,(HL)		; Check for end of table
	OR	A
	JR	Z,SCANEND	; Branch if end

	LD	DE,CMDFCB+1	; Point to name of requested command
	PUSH	BC		; Save size of commands in table

	 IF	WHEEL
				; Ignore commands with high bit set in first
				; ..char of command name if wheel is false
	LD	A,(Z3WHL)	; Get the wheel byte
	OR	A
	LD	C,0FFH		; Make a mask that passes all characters
	JR	Z,SCANCMP	; Use this mask if wheel not set

	 ENDIF	; wheel

	LD	C,7FH		; Use mask to block high bit if wheel set
				; ..or not in use

SCANCMP:
	LD	A,(DE)		; Compare against table entry

	XOR	(HL)
	AND	C		; Mask high bit of comparison
	JR	NZ,SCANSKIP	; No match, so skip rest of command name

	INC	DE		; Advance to next characters to compare
	INC	HL
	RES	7,C		; Mask out high bit on characters after first
	DJNZ	SCANCMP		; Count down

	LD	A,(DE)		; See if next character in input command
	CP	' '		; ..is a space
	JR	NZ,SCANBAD	; If not, user command is longer than commands
				; ..in the command table

				; Matching command found

	POP	BC		; Clear stack
	LD	A,(HL)		; Get address from table into HL
	INC	HL
	LD	H,(HL)
	LD	L,A
	LD	(EXECADR),HL	; Set execution address
	XOR	A		; Set zero flag to show that command found
	RET

SCANSKIP:
	INC	HL		; Skip to next command table entry
	DJNZ	SCANSKIP

SCANBAD:
	POP	BC		; Get back size of each command
	INC	HL		; Skip over address vector
	INC	HL
	JR	SCANNEXT	; Try scanning next entry in table

SCANEND:
	XOR	A		; Reset zero flag to show
	DEC	A		; ..that command was not found
	RET

; End ZCPR33-4.Z80

	PAGE

; ZCPR33-5.Z80

;=============================================================================
;
;		R E S I D E N T    C O M M A N D    C O D E
;
;=============================================================================

; Command:	DIR
; Function:	To display a directory of the files on disk
; Forms:
;	DIR <afn>	Displays the DIR-attribute files
;	DIR		Same as DIR *.*
;	DIR <afn> S	Displays the SYS-attribute files
;	DIR /S		Same as DIR *.* S
;	DIR <afn> A	Display both DIR and SYS files
;	DIR /A		Same as DIR *.* A

	 IF	DIRON

DIR:
	LD	DE,TFCB		; Point to target FCB
	PUSH	DE		; ..and save the pointer for later
	INC	DE		; Point to file name
	LD	A,(DE)		; Get first character

	 IF	SLASHFL		; If allowing "DIR /S" and "DIR /A" formats
	CP	'/'		; If name does not start with '/'
	JR	NZ,DIR1		; ..branch and process normally
	INC	DE		; Point to second character
	LD	A,(DE)		; Get option character after slash
	LD	(TFCB2+1),A	; ..and put it into second FCB
	DEC	DE		; Back to first character
	LD	A,' '		; Simulate empty FCB
	 ENDIF	;slashfl

DIR1:
	CP	' '		; If space, make all wild
	JR	NZ,DIR2
	LD	B,11
	LD	A,'?'
	CALL	FILL

DIR2:
	POP	DE		; Restore pointer to FCB
	CALL	FCBLOG		; Log in the specified directory

	 IF	WHLDIR
	LD	A,(Z3WHL)	; Check wheel status
	OR	A		; If not set, then ignore options
	JR	Z,DIR2A
	 ENDIF	;whldir

	LD	A,(TFCB2+1)	; Check for any option letter
	LD	B,1		; Flag for both DIR and SYS files
	CP	ALLCHAR		; See if all (SYS and DIR) option letter
	JR	Z,DIRPR		; Branch if so
	DEC	B		; B = 0 for SYS files only
	CP	SYSCHAR		; See if SYS-only option letter
	JR	Z,DIRPR		; Branch if so
DIR2A:
	LD	B,80H		; Flag for DIR-only selection
				; Drop into DIRPR to print directory

	 ENDIF	; diron

;--------------------

; Directory display routine

; On entry, if attribute checking is required, the B register is
; set as follows:
;	00H for SYS files only
;	80H for DIR files only
;	01H for both

	 IF	DIRON OR ERAON

DIRPR:
	 IF	DIRON		; Attribute checking needed only for DIR
	LD	A,B		; Get flag
	LD	(SYSTST),A	; Set system test flag
	 ENDIF

	LD	E,0		; Set column counter to zero
	PUSH	DE		; Save column counter (E)
	CALL	SRCHFST1	; Search for specified file (first occurrence)
	JR	NZ,DIR3
	CALL	PRNNF		; Print no-file message
	POP	DE		; Restore DE
	XOR	A		; Set Z to show no files found
	RET

; Entry selection loop.  On entering this code, A contains the offset in the
; directory block as returned by the search-first or search-next call.

DIR3:
	 IF	DIRON		; Attribute checking needed only for DIR cmd

	CALL	GETSBIT		; Get and test for type of files
	JR	Z,DIR6

	 ELSE	;not diron

	DEC	A		; Adjust returned value from 1..4 to 0..3
	RRCA			; Multiply by 32 to convert number to
	RRCA			; ..offset into TBUFF
	RRCA
	LD	C,A		; C = offset to entry in TBUFF

	 ENDIF	;diron

	POP	DE		; Restore count of
	LD	A,E		; ..entries displayed
	INC	E		; Increment entry counter
	PUSH	DE		; Save it
	AND	03H		; Output CRLF if 4 entries printed in line
	JR	NZ,DIR4
	CALL	CRLF		; New line
	JR	DIR5
DIR4:
	CALL	PRINT

	 IF	WIDE

	DEFB	'  '		; 2 spaces
	DEFB	FENCE		; Then fence char
	DEFB	' ',' '+80h	; Then 2 more spaces

	 ELSE	;not wide

	DEFB	' '		; Space
	DEFB	FENCE		; Then fence char
	DEFB	' '+80h		; Then space

	 ENDIF	; wide

DIR5:
	LD	A,1
	CALL	DIRPTR		; HL now points to 1st byte of file name
	CALL	PRFN		; Print file name
DIR6:
	CALL	BREAK		; Check for abort
	JR	Z,DIR7
	CALL	SRCHNXT		; Search for next file
	JR	NZ,DIR3		; Continue if file found

DIR7:
	POP	DE		; Restore stack
	DEC	A		; Set NZ flag
	RET

	 ENDIF	; diron or eraon

;-----------------------------------------------------------------------------

	 IF	DIRON OR ATTCHK OR ERAON

; This routine returns a pointer in HL to the directory entry in TBUFF that
; corresponds to the offset specified in registers C (file offset) and C
; (byte offset within entry).

DIRPTR:
	LD	HL,TBUFF
	ADD	A,C		; Add the two offset contributions
	CALL	ADDAH		; Set pointer to desired byte
	LD	A,(HL)		; Get the desired byte
	RET

	 ENDIF	; diron or attchk or eraon

;-----------------------------------------------------------------------------

; Test File in FCB for existence, ask user to delete if so, and abort if he
;  choses not to

	 IF	SAVEON OR RENON

EXTEST:
	LD	DE,TFCB		; Point to FCB
	PUSH	DE		; ..and save it for later
	CALL	FCBLOG		; Log into specified directory
	CALL	SRCHFST1	; Look for specified file
	POP	DE		; Restore pointer
	RET	Z		; OK if not found, so return
	CALL	PRINTC
	 IF	BELLFL
	DEFB	BELL
	 ENDIF	;bellfl
	DEFB	'Erase',' '+80h
	LD	HL,TFCB+1	; Point to file name field
	CALL	PRFN		; Print it
	CALL	PRINT		; Add question mark
	DEFB	'?' or 80h
	CALL	CONIN		; Get user response
	CP	'Y'		; Test for permission to erase file
	JP	NZ,RESTART	; If not, flush the entire command line
	JP	DELETE		; Delete the file

	 ENDIF	; saveon or renon

;-----------------------------------------------------------------------------

; Print file name pointed to by HL

	 IF	DIRON OR RENON OR SAVEON

PRFN:
	LD	B,8		; Display 8 characters in name
	CALL	PRFN1
	CALL	PRINT		; Put in dot
	DEFB	'.' or 80h
	LD	B,3		; Display 3 characters in type
PRFN1:
	LD	A,(HL)		; Get character
	INC	HL		; Point to next
	CALL	CONOUT		; Print character
	DJNZ	PRFN1		; Loop through them all
	RET

	 ENDIF	;diron or renon or saveon

;-----------------------------------------------------------------------------

; This routine returns NZ if the file has the required attributes and Z if
; it does not.  It works by performing the 'exclusive or' of the mask passed
; in register A and the filename attribute obtained by masking out all but
; the highest bit of the character.  For the 'both' case, setting any bit
; in the mask other than bit 7 will guarantee a nonzero result.
;
;	File name: : X 0 0 0  0 0 0 0	(After 80H mask, X=1 if SYS, 0 if DIR)
;
;	SYS-ONLY   : 0 0 0 0  0 0 0 0	(XOR gives 00H if X=0 and 80H if X=1)
;	DIR-ONLY   : 1 0 0 0  0 0 0 0	(XOR gives 80H if X=0 and 00H if X=1)
;	BOTH	   : 0 0 0 0  0 0 0 1	(XOR gives 01H if X=0 and 81H if X=1)

	 IF	DIRON OR ATTCHK

GETSBIT:
	DEC	A		; Adjust to returned value from 1..4 to 0..3
	RRCA			; Multiply by 32 to convert number to
	RRCA			; ..offset into TBUFF
	RRCA
	LD	C,A		; Save offset in TBUFF in C
	LD	A,10		; Add 10 to point to SYS attribute bit
	CALL	DIRPTR		; A = SYS byte
	AND	80H		; Look only at attribute bit
SYSTST	EQU	$+1		; In-the-code variable
	XOR	0		; If SYSTST=0, SYS only; if SYSTST=80H, DIR
				; ..only; if SYSTST=1, both SYS and DIR
	RET			; NZ if OK, Z if not OK

	 ENDIF	;diron or attchk

;-----------------------------------------------------------------------------

; Command:	REN
; Function:	To change the name of an existing file
; Forms:	REN <New UFN>=<Old UFN>
; Notes:	If either file spec is ambiguous, or if the source file does
;		not exist, the error handler will be entered.  If a file with
;		the new name already exists, the user is prompted for deletion
;		and ZEX is turned off during the prompt.

	 IF	RENON

REN:
	LD	HL,TFCB		; Check for ambiguity in first file name
	CALL	AMBCHK
	CALL	FCBLOG		; Login to fcb
	LD	HL,TFCB2	; Check for ambiguity in second file name
	CALL	AMBCHK
	XOR	A		; Use current drive for 2nd file
	LD	(DE),A
	CALL	SRCHFST		; Check for old file's existence
	JR	NZ,REN0A	; Branch if file exists
JPNOFILE:
	LD	A,ECNOFILE	; Set error code for file not found
	JP	ERROR		; ..and invoke error handler
REN0A:
	CALL	EXTEST		; Test for file existence and return if not
	LD	B,12		; Exchange new and old file names
	PUSH	DE		; Save pointer to FCB
	LD	HL,TFCB2	; Point to FCB for old file name
REN0:
	LD	A,(DE)		; Get character of old name
	LD	C,A		; ..into C register
	LD	A,(HL)		; Get character of new name
	LD	(DE),A		; ..into place in old name
	LD	(HL),C		; Put character of old name into new name
	INC	HL		; Advance pointers
	INC	DE
	DJNZ	REN0

; Perform rename function

	POP	DE		; Restore pointer to FCB
	LD	C,17H		; BDOS rename function
	JP	BDOSTEST

	 ENDIF	;renon

;-----------------------------------------------------------------------------

; Command:	ERA
; Function:	Erase files
; Forms:
;	ERA <afn>	Erase specified files and dislay their names
;	ERA <afn> I	Display names of files to be erased and prompt for
;			inspection before erase is performed. (Character 'I'
;			is defined by INSPCH in Z33HDR.LIB; if it is ' ', then
;			any character triggers inspection.)

	 IF	ERAON

ERA:
	 IF	INSPFL AND ERAOK; 'I' flag and verification enabled?
	LD	A,(TFCB2+1)	; Get flag, if any, entered by user
	LD	(ERAFLG),A	; Save it in code below
	 ENDIF	;erav and eraok

	LD	DE,TFCB		; Point to target FCB
	CALL	FCBLOG		; ..and log into the specified directory

	 IF	DIRON OR ATTCHK	; Attribute checking only in these cases
	LD	B,1		; Display all matching files
	 ENDIF	;diron or attchk

	CALL	DIRPR		; Print directory of erased files
	RET	Z		; Abort if no files

	 IF	ERAOK		; Print prompt

	 IF	INSPFL		; Test verify flag

ERAFLG	EQU	$+1		; Address of flag (in-the-code modification)
	LD	A,0
	CP	INSPCH		; Is it an inspect option?

	 IF	INSPCH NE ' '	; If an explicit inspect character is specified
	JR	NZ,ERA2		; ..skip prompt if it is not that character
	 ELSE			; If INSPCH is the space character
	JR	Z,ERA2		; ..then skip prompt only if FCB has a space
	 ENDIF	;inspch ne ' '

	 ENDIF	;inspfl

	CALL	PRINTC
	DEFB	'OK to Erase','?'+80h
	CALL	CONIN		; Get reply
	CP	'Y'		; Yes?
	RET	NZ		; Abort if not

	 ENDIF	; eraok

ERA2:
	LD	DE,TFCB
	JP	DELETE		; Delete files and return

	 ENDIF			; Eraon

;-----------------------------------------------------------------------------

; Command:	LIST
; Function:	Print out specified file on the LST: device
; Forms:	LIST <ufn>	Print file (No Paging)
; Notes:	The flags which apply to TYPE do not take effect with LIST

	 IF	LTON

LIST:
	LD	A,0FFH		; Turn on printer flag
	JR	TYPE0

;-----------------------------------------------------------------------------

; Command:	TYPE
; Function:	Print out specified file on the CON: Device
; Forms:	TYPE <ufn>	Print file with default paging option
;		TYPE <ufn> P	Print file with paging option reversed

TYPE:
	XOR	A		; Turn off printer flag

; Common entry point for LIST and TYPE functions

TYPE0:
	LD	(PRFLG),A	; Set printer/console flag
	LD	A,(TFCB2+1)	; Check for user page toggle ('P') option
	LD	(PGFLG),A	; Save it as a flag in code below
	LD	HL,TFCB		; Point to target file FCB
	CALL	AMBCHK		; Check for ambiguous file spec (vectors to
				; ..error handler if so)
	CALL	FCBLOG		; Log into specified directory
	CALL	OPEN		; Open the file

	 IF	RENON		; If REN on, share code
	JR	Z,JPNOFILE
	 ELSE	;not renon	; Otherwise repeat code here
	LD	A,ECNOFILE
	JP	Z,ERROR
	 ENDIF	;renon

	CALL	CRLF		; New line
	LD	A,(CRTTXT0)	; Set line count using value from the
				; ..environment for CRT0
	INC	A		; One extra the first time through
	LD	(PAGCNT),A
	LD	BC,080H		; Set character position and tab count
				; (B = 0 = tab, C = 080h = char position)

; Main loop for loading next block

TYPE2:
	LD	A,C		; Get character count
	CP	80H		; If not end of disk record
	JR	C,TYPE3		; ..then skip

	CALL	READF		; Read next record of file
	RET	NZ		; Quit if end of file

	LD	C,0		; Reset character count
	LD	HL,TBUFF	; Point to first character

; Main loop for printing characters in TBUFF

TYPE3:
	LD	A,(HL)		; Get next character
	AND	7FH		; Mask out MSB
	CP	1AH		; Check for end of file (^z)
	RET	Z		; Quit if so

; Output character to CON: or LST: device with tabulation

	CP	CR		; If carriage return,
	JR	Z,TYPE4		; ..branch to reset tab count
	CP	LF		; If line feed, then output
	JR	Z,TYPE4A	; ..with no change in tab count
	CP	TAB		; If tab
	JR	Z,TYPE5		; ..expand to spaces

; Output character and increment character count

	CALL	LCOUT		; Output character
	INC	B		; Increment tab count
	JR	TYPE6

; Output CR and reset tab count

TYPE4:
	LD	B,0		; Reset tab counter

; Output LF and leave tab count as is

TYPE4A:
	CALL	LCOUT		; Output <cr> or <lf>
	JR	TYPE6

; Process tab character

TYPE5:
	LD	A,' '		; Space
	CALL	LCOUT
	INC	B		; Increment tab count
	LD	A,B
	AND	7
	JR	NZ,TYPE5	; Loop until column = n * 8 + 7

; Continue processing

TYPE6:
	INC	C		; Increment character count
	INC	HL		; Point to next character
	PUSH	BC
	CALL	BREAK		; Check for user abort
	POP	BC
	RET	Z		; Quit if so
	JR	TYPE2		; Else back for more

;--------------------

; Output character in A to console or list device depending on a flag.
; Registers are preserved.  This code is used only by the LIST and TYPE
; commands.

LCOUT:
	PUSH	AF		; Save character
PRFLG	EQU	$+1		; Pointer for in-the-code modification
	LD	A,0		; ..to determine destination (CON or LST)
	OR	A		; Z=type, NZ=list
	JR	Z,LC1

				; Output to list device

	POP	AF		; Get character back
	PUSH	DE
	PUSH	BC
	LD	C,5		; LISTOUT function
	JP	OUTPUT

				; Output to console with paging

LC1:
	POP	AF		; Get character back
	PUSH	AF		; Save it again for page check
	CALL	CONOUT		; Output to console
	POP	AF		; Get character back again
	CP	LF		; Check for new line (paging)
	RET	NZ		; If not new line, we are done

				; Paging routines

PAGER:
	PUSH	HL
	LD	HL,PAGCNT	; Decrement lines remaining on screen
	DEC	(HL)
	JR	NZ,PAGER1	; Jump if not end of page

				; New page
	LD	A,(CRTTXT0)	; Get full page count from environment
	LD	(HL),A		; Reset count to a full page
PGFLG	EQU	$+1		; Pointer to in-the-code buffer pgflg
	LD	A,0
	CP	PAGECH		; Page default override option wanted?

	 IF	PAGECH NE ' '	; If using explicit character for page toggle

	 IF	PAGEFL		; If paging is default
	JR	Z,PAGER1	; ..PAGECH means no paging
	 ELSE			; If paging not default
	JR	NZ,PAGER1	; ..PAGECH means please paginate
	 ENDIF	;pagefl

	 ELSE			; Any character toggles paging

	 IF	PAGEFL		; If paging is default
	JR	NZ,PAGER1	; ..any character means no paging
	 ELSE			; If paging not default
	JR	Z,PAGER1	; ..any character means please paginate
	 ENDIF	;pagefl

	 ENDIF	;pagech ne ' '

				; End of page
	PUSH	BC
	CALL	BIOS+9		; Wait for user input (BIOS console input)
	POP	BC
	CP	'C'-'@'		; Did user enter control-c?
	JP	Z,NEXTCMD	; If so, terminate this command

PAGER1:
	POP	HL		; Restore HL
	RET

	 ENDIF	; lton

;-----------------------------------------------------------------------------

; Command: SAVE
; Function:  To save the contents of the TPA onto disk as a file
; Forms:
;	SAVE <Number of Pages> <ufn>
;		Save specified number of pages (starting at 100H) from TPA
;		into specified file
;
;	SAVE <Number of Sectors> <ufn> <S>
;		Like SAVE above, but numeric argument specifies
;		number of sectors rather than pages

	 IF	SAVEON

; Entry point for SAVE command

SAVE:
	CALL	NUMBER		; Extract number from command line
	JR	C,BADNUMBER	; Invoke error handler if bad number
	PUSH	BC		; Save the number
	CALL	REPARSE		; Reparse tail after number of sectors/pages
	POP	HL		; Get sector/page count back into HL
	LD	A,(TFCB2+1)	; Check sector flag in second FCB
	CP	SECTCH

	 IF	SECTCH NE ' '	; If using a specific character, then jump
	JR	Z,SAVE0		; ..if it is that character
	 ELSE			; If allowing any character (SECTCH=' ')
	JR	NZ,SAVE0	; ..jump if it is anything other than space
	 ENDIF	;sectch ne ' '

	ADD	HL,HL		; Double page count to get sector count
SAVE0:
	LD	A,1		; Maximum allowed value in H
	CP	H		; Make sure sector count < 512 (64K)
	JR	C,BADNUMBER	; If >511, invoke error handler

	PUSH	HL		; Save sector count
	LD	HL,TFCB
	CALL	AMBCHK		; Check for ambiguous file spec (vectors to
				; ..error handler if so)

	CALL	EXTEST		; Test for existence of file and abort if so
	LD	C,16H		; BDOS make file function
	CALL	BDOSTEST
	JR	Z,SAVE3		; Branch if error in creating file

	POP	BC		; Get sector count into BC
	LD	HL,TPA-80H	; Set pointer to one record before TPA

SAVE1:
	LD	A,B		; Check for BC = 0
	OR	C
	DEC	BC		; Count down on sectors (flags unchanged,
				; ..B=0FFH if all records written successfully)
	JR	Z,SAVE2		; If BC=0, save is done so branch

	PUSH	BC		; Save sector count
	LD	DE,80H		; Advance address by one record
	ADD	HL,DE
	PUSH	HL		; Save address on stack
	EX	DE,HL		; Put address into DE for BDOS call
	CALL	DMASET		; Set DMA address for write
	LD	DE,TFCB		; Write sector
	LD	C,15H		; BDOS write sector function
	CALL	BDOSSAVE
	POP	HL		; Get address back into HL
	POP	BC		; Get sector count back into BC
	JR	Z,SAVE1		; If write successful, go back for more

	LD	B,0		; B=0 if write failed

SAVE2:
	CALL	CLOSE		; Close file even if last write failed
	AND	B		; Combine close return code with
				; ..write success flag
	RET	NZ		; Return if all ok

SAVE3:				; Disk must be full
	LD	A,ECDISKFULL	; Disk full error code
	JR	JPERROR

	 ENDIF	; saveon

;-----------------------------------------------------------------------------

	 IF	LTON OR	SAVEON OR RENON OR GETON

; Check file control block pointed to by HL for any wildcard characters ('?').
; Return to calling program if none found.  Otherwise branch to error handler.
; The routine also treats an empty file name as ambiguous.

AMBCHK:
	PUSH	HL		; Save pointer to FCB
	INC	HL		; Point to first character in file name
	LD	A,(HL)		; See if first character is a space
	CP	' '
	JR	Z,AMBCHK1	; If so, branch to error return

	LD	A,'?'		; Set up for scan for question mark
	LD	BC,11		; Scan 11 characters
	CPIR
	POP	DE		; Restore pointer to FCB in DE
	RET	NZ		; Return if no '?' found
AMBCHK1:
	LD	A,ECAMBIG	; Error code for ambiguous file name
	JR	JPERROR

	 ENDIF	;lton or renon or saveon or geton

	 IF	LTON OR RENON OR SAVEON OR GETON OR JUMPON

BADNUMBER:
	LD	A,ECBADNUM	; Error code for bad number value
JPERROR:			; Local entry point for relative jump
	JP	ERROR		; ..to go to error handler

	 ENDIF	;lton or renon or saveon or geton or jumpon

;-----------------------------------------------------------------------------

; Command:	JUMP
; Function:	To execute a program already loaded into some specified memory
;		address
; Forms:	JUMP <adr> <tail>
;		The address is in hex; the tail will be parsed as usual

	 IF	JUMPON

JUMP:
	CALL	HEXNUM		; Get load address into BC
	JR	C,BADNUMBER	; If bad number, invoke error handling
	PUSH	BC		; ..and save it
	CALL	REPARSE		; Reparse tail after address value
	POP	HL		; Restore execution address to HL
	JR	GETPROGLF	; Perform call via code below

	 ENDIF	;jumpon

;-----------------------------------------------------------------------------

; Command:	GO
; Function:	To Call the program in the TPA without loading
;		loading from disk. Same as JUMP 100H, but much
;		more convenient, especially when used with
;		parameters for programs like STAT. Also can be
;		allowed on remote-access systems with no problems.
;
;Form:		GO <tail>

	 IF	GOON

GO:
	LD	HL,TPA		; Set up TPA as the execution address

	 ENDIF	; goon

	 IF	JUMPON OR GOON	; Common code

GETPROGLF:
	LD	(EXECADR),HL
	XOR	A		; Set zero flag to enable leading CRLF
	JP	CALLPROGLF	; Perform call (with leading CRLF)

	 ENDIF	;jumpon or goon

;-----------------------------------------------------------------------------

; Command:	GET
; Function:	To load the specified file from disk to the specified address
; Forms:	GET <adr> <ufn>
;		Loads the specified file to the specified hexadecimal address
;		Note that the normal file search path is used to find the file.
;		If SCANCUR is off, the file may not be found in the current
;		directory unless a colon is included in the file spec.

	 IF	GETON

GET:

; TMPCOLON was set when the file name was parsed.  We use that as the colon
; flag so that the file will be loaded from a directory just as if it had
; been entered as the command name.

	 IF	DRVPREFIX AND [NOT SCANCUR]
	LD	A,(TMPCOLON)	; Allow GET to load from specified
	LD	(COLON),A	; directory
	 ENDIF	;drvprefix and [not scancur]

	LD	HL,TFCB2	; Copy TFCB2 to CMDFCB for load
	PUSH	HL
	LD	DE,CMDFCB
	LD	BC,14
	LDIR
	POP	HL
	CALL	AMBCHK		; Make sure file is not ambiguous (vectors
				; ..to error handler if so)

; If GET fails to find the specified file along the search path, we do not
; want the ECP to be engaged.  To prevent that, we fool the command processor
; by telling it that the ECP is already engaged.

	LD	HL,CMDSTATFL	; Point to command status flag
	SET	2,(HL)		; Turn on ECP flag to prevent use of ECP
	CALL	HEXNUM		; Get load address into BC
	JR	C,BADNUMBER	; If invalid number, invoke error handler

	 IF	NOT FULLGET
	LD	A,B		; If trying to load into base page
	OR	A		; ..treat as error
	JR	Z,BADNUMBER
	 ENDIF	;not fullget

	LD	H,B		; Move address into HL
	LD	L,C
	LD	A,0FFH		; Disable dynamic loading
				; Fall through to mload

	 ENDIF	; geton

; End ZCPR33-5.Z80

	PAGE

; ZCPR33-6.Z80

;=============================================================================
;
;   P A T H    S E A R C H    A N D    F I L E    L O A D I N G    C O D E
;
;=============================================================================

; This block of code loads a file into memory.  The normal address at which
; loading is to begin is passed to the routine in the HL register.  The name
; of the file to load is passed in the command file control block.
;
; This code supports an advanced option that loads files to a dynamic address
; specified in the header to the file using a new type-3 environment.  In a
; type-3 environment, the execution/load address is stored in the word
; following the environment descriptor address.  A value is passed to MLOAD in
; the A register that controls this dynamic loading mechanism.  The value
; specifies the lowest environment type value for which dynamic loading will
; be performed.  This value will be 3 when MLOAD is called for normal COM file
; execution and will be 0FFH when chained to from the GET command.  In the
; latter case, the user-specified load address must be used.
;
; MLOAD guards against loading a file over the operating system.  It computes
; the lower of the following two addresses: 1) the CPR entry point; 2) the
; bottom of protected memory as indicated by the DOS entry address stored at
; address 0006H.  If the load would exceed this limit, error handling is
; engaged (except for the GET command when FULLGET is enabled).

MLOAD:
	LD	(ENVTYPE),A	; Set up in-the-code modification below
	LD	(EXECADR),HL	; Set up execution/load address
	CALL	DEFLTDMA	; Set DMA address to 80H for file searches


; This code sets the attributes of COM files which are acceptable.  If both
; SYS and DIR type files are acceptable, there is no need to include this code,
; and ATTCHK can be set to false.

	 IF	ATTCHK		; Only if attribute checking enabled
	LD	A,COMATT	; Attributes specified in Z33HDR.LIB
	LD	(SYSTST),A	; Set flag
	 ENDIF	;attchk

;-----------------------------------------------------------------------------

; PATH BUILDING CODE

; In ZCPR33 the minpath feature, optional in ZCPR30, is always used.  To
; minimize the size of the CPR code, however, there is an option to place the
; minpath in an external buffer (outside the CPR).  If the path is short
; enough, the minpath can be placed at the bottom of the system stack.

	LD	DE,PATH		; Point to first element in user's symbolic path
	LD	HL,MPATH	; Point to minpath buffer
	XOR	A
	LD	(HL),A		; Initialize to empty minpath


; If DRVPREFIX is enabled, the CPR will recognize an explicit directory
; reference in a command.  The first element of the path will then be this
; explicit directory.  If no explicit directory was given in the command,
; then no entry is made into the search path.  If the WPREFIX option is
; on, explicit directory prefixes will be recognized only when the wheel
; byte is on.

	 IF	DRVPREFIX	; Pay attention to du:com prefix?

	LD	A,(COLON)	; See if colon was present in command
	OR	A
	JR	Z,MAKEPATH2	; If not, skip ahead

	 IF	WPREFIX
	LD	A,(Z3WHL)	; See if wheel byte is on
	OR	A
	JR	Z,MAKEPATH2	; If not, skip ahead
	 ENDIF	;wprefix

	LD	A,(CMDFCB)	; Get drive from command FCB
	LD	(HL),A		; Put drive into minpath
	INC	HL		; Advance pointer
	LD	A,(CMDFCB+13)	; Get user number from command FCB
	LD	(HL),A		; Put it into minpath
	INC	HL		; Advance pointer to next path element
	XOR	A		; A=0
	LD	(HL),A		; Store ending 0 in mpath
MAKEPATH2:
	 ENDIF	; drvprefix


; If SCANCUR is enabled in Z33HDR.LIB, then we always include the current
; directory automatically, even without a '$$' element in the user's path.
; If WPREFIX is enabled, however, we do not want to allow the current
; directory to be included, but we must make sure that it is included in
; the building of the root path, in case the user's symbolic path is empty.

	 IF	SCANCUR		; Scan current directory at all times?

	LD	BC,(CURUSR)	; C = current user, B = current drive
	INC	B		; Set drive to range 1..16

	 IF	WPREFIX

	LD	A,(Z3WHL)	; See if wheel byte is on
	OR	A
	JR	NZ,ADDPATH	; If it is, add element to path; if not,
				; ..fall through to MAKEPATH3
	 ELSE	;not wprefix

	JR	ADDPATH		; Begin loop of placing entries into mpath

	 ENDIF	;wprefix

	 ELSE	;not scancur

; If SCANCUR is off and ROOTONLY is in effect, we have to make sure that some
; directory values are put into the root path in the case where the user's
; path is completely empty.  To do so, we preset BC for directory A0.

	 IF	ROOTONLY
	LD	BC,0100H	; Setup for drive A (B=1), user 0 (C=0)
	 ENDIF	;rootonly

	 ENDIF	;scancur


; Convert symbolic entries in user's path into absolute DU values in minpath.
; Entries are read one-by-one from the symbolic path.  If the 'current' drive
; or user indicator is present (default symbol is '$'), then the current
; drive or user value is fetched.  Otherwise the explicit binary value from the
; path is used.  After each absolute DU value is formed, the minpath as it
; exists so far is scanned to see if this DU value is already there.  If it is
; not, then the DU value is appended to the path.  Otherwise it is ignored.

MAKEPATH3:
	LD	A,(DE)		; Get next symbolic path entry
	OR	A		; If 0, we are at end of path
	JR	Z,MAKEPATH6

	LD	BC,(CURUSR)	; C = current user, B = current drive
	INC	B		; Set drive to range 1..16
	CP	CURIND		; Check for current drive symbol (default '$')
	JR	Z,MAKEPATH4	; If so, leave current drive in B
	LD	B,A		; Else move specified drive into B
MAKEPATH4:
	INC	DE		; Point to user value in symbolic path
	LD	A,(DE)		; Get user
	INC	DE		; Point to next element in symbolic path
	CP	CURIND		; Check for current user symbol (default '$')
	JR	Z,MAKEPATH5	; If so, leave current drive in C
	LD	C,A		; Else move specified user into C
MAKEPATH5:

; At this point in the code we have a potential path element in BC.  We first
; have to scan the minpath we have so far to see if that element is already
; there.  In that case we ignore it; otherwise we add it to the end of the path.

ADDPATH:
			; Skip path if directory given explicitly

	 IF	SKIPPATH

	 IF	WPREFIX
	LD	A,(Z3WHL)	; See if wheel byte is on
	OR	A
	CALL	NZ,SKIPCHK	; If not, fall through
	 ELSE	;not wprefix
	CALL	SKIPCHK		; See if path should be skipped
	 ENDIF	;wprefix

	JR	NZ,MAKEPATH3	; If so, branch out of ADDPATH

	 ENDIF	;skippath

	LD	HL,MPATH	; Point to beginning of minpath

ADDPATH1:			; Point of reentry
	LD	A,(HL)		; Get drive value
	OR	A		; Check for end of minpath
	JR	Z,ADDPATH2	; If end, jump and add BC to minpath

	INC	HL		; Increment pointer to user
	CP	B		; Check for drive match
	LD	A,(HL)		; Get user from minpath
	INC	HL		; Point to next minpath entry
	JR	NZ,ADDPATH1	; If drive was different, loop back again
	CP	C		; Check for user match
	JR	NZ,ADDPATH1	; If user is different, loop back again
	JR	MAKEPATH3	; Branch if we have a duplicate

; We have a new DU; add it to minpath

ADDPATH2:
	LD	(HL),B		; Store drive
	INC	HL
	LD	(HL),C		; Store user
	INC	HL
	LD	(HL),0		; Store ending 0
	JR	MAKEPATH3	; Continue scanning user's path

; If the ECP facility is set up to use the root directory, then create a
; root path.  BC presently contains the proper DU.

MAKEPATH6:

	 IF	ROOTONLY
	LD	HL,ROOTPTH	; Point to special path to contain root
	LD	(HL),B		; Store disk
	INC	HL
	LD	(HL),C		; Store user
	 ENDIF	;rootonly

;-----------------------------------------------------------------------------

; This is the code for loading the specified file by searching the minpath.

	XOR	A		; Always use current disk specification in the
	LD	(CMDFCB),A	; ..command FCB

MLOAD1:

	LD	HL,MPATH	; Point to beginning of minpath

MLOAD2:

; Either the FASTECP or BADDUECP option may have set FIRSTCHAR to a space
; character as a signal to go directly to extended command processing.  If
; neither option is enabled but SKIPPATH is, then the FIRSTCHAR data is
; stored in the routine below where path skipping is implemented.

	 IF	FASTECP OR BADDUECP

	LD	A,(CMDSTATFL)	; If ECP is running
	BIT	2,A		; ..we branch to look for ECP along path
	JR	NZ,MLOAD2A
FIRSTCHAR EQU	$+1		; Pointer for in-the-code modification
	LD	A,0
	CP	' '		; Was command invoked with leading space?
	JR	Z,ECPRUN	; If so, go directly to ECP code

	 ENDIF	;fastecp or badduecp

MLOAD2A:
	LD	A,(HL)		; Get drive from path
	OR	A		; If end of path, command not found
	JR	NZ,MLOAD3	; If not end of path, skip over ECP code

;-----------------------------------------------------------------------------

; EXTENDED COMMAND PROCESSING

; At this point we have exhausted the search path.  We now engage the
; extended command processor.

ECPRUN:
	 IF	SKIPPATH
	CALL	SKIPCHK		; See if path should be skipped
	JR	NZ,JNZERROR	; If so, invoke error handler
	 ENDIF	;skippath

	LD	HL,CMDSTATFL	; Point to command status flag
	LD	A,(HL)		; ..and get value
	AND	110B		; Isolate ECP and error handler bits
JNZERROR:			; If either is set,
	LD	A,ECNOCMD	; Error code for command not found
	JP	NZ,ERROR	; ..process as an error

	SET	2,(HL)		; Set ECP bit

	LD	HL,ECPFCB	; Copy name of ECP to command FCB
	LD	DE,CMDFCB
	LD	BC,12		; Only 12 bytes required
	LDIR

	LD	HL,(CMDPTR)	; Get pointer to current command line
	CALL	PARSETAIL	; Parse entire command as the command tail

	 IF	ROOTONLY	; Look for ECP in root directory only
	LD	HL,ROOTPTH	; Point to path containing root directory only
	JR	MLOAD2		; Search for command
	 ELSE	; not rootonly
	JR	MLOAD1		; Search the entire minpath for the ECP
	 ENDIF	; rootonly

;-----------------------------------------------------------------------------

MLOAD3:
	LD	B,A		; Drive into B
	INC	HL		; Point to user number
	LD	C,(HL)		; User into C
	LD	(TEMPUSR),BC	; Save the values
	INC	HL		; Point to next entry in path
	CALL	LOGTEMP		; Log in path-specified user/drive

	 IF	ATTCHK		; If allowing execution only of COM files with
				; ..specific attributes

	LD	DE,CMDFCB	; Point to command FCB
	CALL	SRCHFST		; Look for directory entry for file
	JR	Z,MLOAD2A	; Continue path search if file not found
	PUSH	HL		; Save path pointer
	CALL	GETSBIT		; Check system attribute bit
	POP	HL		; Restore path pointer
	JR	Z,MLOAD2A	; Continue if attributes do not match
	CALL	OPENCMD		; Open file for input
	JR	Z,MLOAD2A	; If open failed, back to next path element

	 ELSE	;not attchk

	CALL	OPENCMD		; Open file for input
	JR	Z,MLOAD2A	; If open failed, back to next path element

	 ENDIF	; attchk

	CALL	READCMD		; Read first record into default DMA address
	JR	NZ,MLOAD5	; Branch if zero-length file
	XOR	A		; Set file current record back to zero
	LD	(CMDFCB+20H),A
	LD	HL,80H		; Pointer to start of code
	CALL	Z3CHK
	JR	NZ,MLOAD3A	; If not Z3 file, branch

; The following test is modified by earlier code.  For normal COM file loading,
; a 3 is inserted for the minimum environment type for dynamic load address
; determination.  For the GET command, where the user-specified address should
; be used, a value of 0FFH is put in here so the carry flag will always be set.

ENVTYPE	EQU	$+1		; Pointer for in-the-code modification
	CP	3		; See if no higher than a type-3 environment
	JR	C,MLOAD3A	; If higher than type 3, branch

	INC	HL		; Advance to load address word
	INC	HL
	INC	HL
	LD	A,(HL)		; Get load address into HL
	INC	HL
	LD	H,(HL)
	LD	L,A
	LD	(EXECADR),HL	; Set new execution/load address

MLOAD3A:
	LD	HL,(EXECADR)	; Get initial loading address

; Load the file, making sure neither CPR nor protected memory is overwritten

MLOAD4:
	 IF	FULLGET
	LD	A,(ENVTYPE)	; If ENVTYPE is FF (from GET command)
	INC	A		; ..then skip memory limit checking
	JR	Z,MLOAD4B
	 ENDIF	;fullget

	 IF	REL
	LD	BC,ENTRY	; We have to use a relocatable form to get
	DEC	B		; ..highest page below the CPR
	 ELSE	;not rel
	LD	B,HIGH ENTRY - 1 ; We can use shorter code for absolute form
	 ENDIF	;rel

	LD	A,(0007H)	; Get highest page below
	DEC	A		; ..protected memory
	CP	B		; If A is lower value,
	JR	C,MLOAD4A	; ..branch
	LD	A,B		; Otherwise use lower value in B
MLOAD4A:
	CP	H		; Are we going to overwrite protected memory?
	LD	A,ECTPAFULL	; Get ready with TPA overflow error code
	JP	C,ERROR		; Error if about to overwrite protected memory
MLOAD4B:
	PUSH	HL		; Save this load address
	EX	DE,HL		; Set DMA address
	CALL	DMASET
	CALL	READCMD
	POP	HL		; Get last load address back
	JR	NZ,MLOAD5	; Read error or eof?
	LD	DE,128		; Increment load address by 128
	ADD	HL,DE
	JR	MLOAD4		; Continue loading

; In case a program would like to find out in what directory the command
; processor found the program, temporary DU is stored in bytes 13 (user) and
; 14 (drive) in the command FCB.

MLOAD5:

TEMPUSR	EQU	$+1		; Pointers for in-the-code modification
TEMPDR	EQU	$+2
	LD	HL,0
	LD	(CMDFCB+13),HL

LOGCURRENT:			; Return to original logged directory
	LD	HL,(CURUSR)	; Set L = current user, H = current drive
	LD	A,H
	CALL	SETDRIVE	; Login current drive
	LD	A,L
	JP	SETUSER		; Log in new user and return from MLOAD

;----------------------------------------

; This routine checks to see if building the path or running the ECP should
; be skipped.  If there is a colon in the command (an explicit directory
; given) but it was not a lone colon (indicating desire to skip resident
; commands), then the routine returns with the zero flag reset.

	 IF	SKIPPATH

SKIPCHK:
	LD	A,(COLON)	; Was there a colon in the command?
	OR	A
	RET	Z		; Return with zero flag set if not

	 IF	FASTECP OR BADDUECP
	LD	A,(FIRSTCHAR)	; See if the first character was the colon
	 ELSE
FIRSTCHAR EQU	$+1		; Put data here if other two options are
	LD	A,0		; ..false (in-the-code modification)
	 ENDIF	;fastecp or badduecp

	CP	':'
	RET			; Return: Z if lone colon, NZ otherwise

	 ENDIF	;skippath


; End ZCPR33-6.Z80

	PAGE

;-----------------------------------------------------------------------------
;
;		D A T A    A R E A    D E F I N I T I O N S
;
;-----------------------------------------------------------------------------

; ----------   Page line count buffer

	 IF	LTON		; Needed only if TYPE command included

PAGCNT:
	DEFS	1		; Lines left on page (filled in by code)

	 ENDIF	;lton


; ---------- Minpath/Rootpth buffers

	 IF	EXTMPATH

MPATH	EQU	EXTMPATHADR	; Assign external minpath address

	 ELSE

MPATH:
	 IF	DRVPREFIX
	DEFS	2		; Two bytes for specified DU
	 ENDIF

	 IF	SCANCUR
	DEFS	2		; Two bytes for current DU
	 ENDIF

	DEFS	2 * EXPATHS	; Space for path from path buffer

	DEFS	1		; One byte for ending null

	 ENDIF	; not extmpath


	 IF	ROOTONLY
ROOTPTH:
	DEFS	2		; Special path for root dir only
	DEFB	0		; End of path
	 ENDIF	; rootonly

;-----------------------------------------------------------------------------

; The following will cause an error message to appear if
; the size of ZCPR33 is over 2K bytes.

	 IF	[ $ - ENTRY ] GT 800H
	*** ZCPR33 IS LARGER THAN 2K BYTES ***
	 ENDIF

	 ENDIF	;errflag

	END	; ZCPR33


