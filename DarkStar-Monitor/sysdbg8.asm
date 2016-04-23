;------------------------------------------------------------------------------
;
; include darkstar.equ
;

TRUE	EQU	-1
FALSE	EQU	0

; The following equate setup an incarnation that will run without CP/M support
; It is hardware dependent (since calls are made directly to the monitor ROM)
; Here it is tailored for my Z80darkStar. Follow the STLONE symbol to find
; were customize the calls...



MAXBP	EQU	16		;Number	of breakpoints configured
BS	EQU	08H		;ASCII 	backspace
TAB	EQU	09H		;	tab
LF	EQU	0AH		;	line feed
FORMF	EQU	0CH		;	form feed
CR	EQU	0DH		;	carriage return
ESC	EQU	1BH		;       escape
; CTLX	EQU	'X' and	1fh	;	control	x - delete line
CTLX	EQU	$7F		;	control	x - delete line
CTLC	EQU	'C' and	1fh	;	control	c - warm boot
EOF	EQU	'Z' and	1fh	;	control	z - logical eof
QUOTE	EQU	27H		;	quote
TILDE	EQU	7EH		;	tilde
DEL	EQU	7FH		;	del

INOP	EQU	000		;Z80 instructions
IJP	EQU	0C3H
IRT	EQU	0C9H
RST38	EQU	0CFH		; uses RST 8
; RST38	EQU	0FFH		; uses RST 38
RSTVEC	EQU	08H	;Default (but patchable) breakpoint vector
; RSTVEC	EQU	38H		;Default (but patchable) breakpoint vector
IOBUF	EQU	80H		;Disk read buffer for symbol loading
Z8EORG	EQU	$A000
Z8ESP	EQU	Z8EORG - 2
;---------------------------------------------------------

	ORG	Z8EORG
FILLBEGIN:
	JP	BEGIN

MBANNR:	DEFB	$0C
	DEFB	CR,LF
	DEFB	'Z80DARKSTAR (Z80NE) MONITOR DEBUGGER.',CR,LF
	DEFB	'Copyright (c) 2006-2014 Piergiorgio Betti <pbetti@lpconsul.net>'
	DEFB	CR,LF,LF
	DEFB	0

BEGIN:
	LD	(SPREG),SP	;save user sp

	LD	DE,MBANNR	;Dispense with formalities
	CALL	PRINT

; Do config based on max length of symbol names

	LD	A,(MAXLEN)	;Check max symbol length
	INC	A		;Create mask
	CP	15
	LD	B,A		;B - maxlen mask - 15
	LD	A,62		;A - maxlin disassembly line length (62)
	LD	C,68		;C - column to display first byte of memory
				;    window for J command
	LD	D,3		;D - bytes per line of memory window display
	JP	Z,NINT00	;Z - max symbol length is 14

				;If not 14 - use default values
	LD	B,7		;B - maxlen mask -  7
	LD	A,30		;A - maxlin disassembly line length (30)
	LD	C,56		;C - column to display first byte of memory
	LD	D,7		;    window for J command
NINT00:
; 	call	inchar
	LD	(MAXLIN),A
	LD	A,B
	LD	(MAXLEN),A
	LD	A,C
	LD	(FWNDOW),A
	LD	A,D
	LD	(NLMASK),A

	LD	A,IRT		;Initialize where L80 fears to tread
	LD	(RSTVEC),A	;Init trap to breakpoint handler
	LD	HL,BPHN		;entry point to	breakpoint handler
	LD	(RSTVEC+1),HL	;Init RST 38h trap location

	LD	HL,Z8ESP-128
	LD	(BDOSAD),HL

; 	LD	HL,Z8ESP-512
; 	LD	(SPREG),HL

	JP	Z8E            ;Hi-ho, hi-ho to the loader we must go

;******************************************************************************
;*
;*	z8e:	Entry point to monitor
;*
;*		Each command begins with the output of the '*' prompt.
;*		Command	character is validated by checking the cmd table,
;*
;*		Relative position of command letter in cmd table also used
;*		as index into command jump table jtcmd.
;*
;*		All commands entered with b = 0.
;*
;******************************************************************************


	ORG	($+255) AND 0FF00H

Z8E:
	LD	SP,Z8ESP

Z8ECMD:
; 	DI			; lock interrupts and enable local RST38
; 	LD	A,(INTRDI)	; check for syscommon presence
; 	CP	$F3		; SHOULD be...
; 	JR	NZ,NOSYSBIOS
; 	CALL	INTRDI		; global ints disable
; NOSYSBIOS:
	LD 	A,IJP
	LD	(RSTVEC),A
	LD	HL,Z8E
	PUSH	HL

	LD	DE,PROMPT	;display prompt (asterisk)
	CALL	NPRINT
	LD	HL,JSTEPF	;full screen debugging in effect?
	LD	A,(HL)
	AND	A
	JR	NZ,Z8E10	;nz - no

	LD	C,10
	CALL	SPACES		;If this was jdbg clear command line residue
	LD	A,$0B		; cursor @ home
	CALL	TTYO
	LD	A,(PROMPT)
	CALL	TTYO

Z8E10:
	CALL	INCHAR		;Read in command character
; +++ jrs 3.5.6 ++++++++++++++++++
	CP	CR		;+Check for empty command line
	JR	NZ,Z8E16	;+Something there - process it
	LD	A,(LCMD)	;+Nothing - see if S or J was last command
	CP	'J'		;+Repeat 'J' command?
	JP	Z,JDBG00	;+
	LD	HL,1		;+
	CP	'S'		;+Repeat 'S' command?
	JP	Z,STEP40	;+
	LD	A,CR		;+
Z8E16:				;+
; ++++++++++++++++++++++++++++++++
	CALL	IXLT		;Translate to upper case for compare
	LD	(LCMD),A
	CP	'J'		;If command is anything but j then indicate
				;that screen is corrupted.  at next invokation
				;jdbg will know to repaint the screen.
	JR	Z,Z8E20
	LD	(JSTEPF),A	;Full screen flag nz - full screen debugging
				;in progress


Z8E20:	LD	BC,NCMD		;total number of commands
	LD	HL,CMD		;table of ascii	command	characters
	CPIR
	JP	NZ,EXXX		;command letter not found in table
	LD	HL,JTCMD	;command jump table
	ADD	HL,BC
	ADD	HL,BC		;index into table
	LD	E,(HL)		;lo order command processing routine
	INC	HL
	LD	D,(HL)		;upper address
	LD	C,3
	CALL	SPACES		;print spaces regardless
	EX	DE,HL		;hl - address of command processing routine
	JP	(HL)

;******************************************************************************
;*
;*	bphn:	breakpoint handler - rst38s land here
;*
;*		bphn   - bphn00	  save all user	registers
;*		bphn10 - bphn20	  check	that user pc matches entry in brktbl.
;*		bphn80		  special single step processing.
;*
;*	note:	sbps is	both a flag and	the count of the number	of step	bps.
;*		sbps is	set to 1 merely	to indicate that the single-stepping
;*		is in effect.  then the	number of step bps is added to one.
;*		hence, if 1 step bp was	set then  sbps = 2 and if 2 step bps
;*		were set (conditional jump, call, ret) sbps = 3.
;*
;******************************************************************************

BPHN:	LD	(HLREG),HL	;save user hl
	POP	HL		;pop breakpoint	pc from	stack
	LD	(SPREG),SP	;save user sp
	LD	SP,Z8ESP	;switch	to our stack
	DEC	HL		;point to location of rst instruction
	LD	(PCREG),HL	;save user pc
	LD	(DEREG),DE	;save user de
	LD	(BCREG),BC	;save user bc
	PUSH	AF
	POP	HL		;user accumulator and flag to hl
	LD	(AFREG),HL	;save user af
	LD	A,I
	LD	H,A		;save user i reg
	LD	A,R
	LD	L,A		;save user r reg
	LD	(RREG),HL
	EX	AF,AF'          ;Bank In Prime Regs
	EXX
	LD	(HLPREG),HL	;save
	LD	(DEPREG),DE
	LD	(BCPREG),BC
	PUSH	AF
	POP	HL
	LD	(AFPREG),HL
	LD	(IXREG),IX	;save user ix
	LD	(IYREG),IY	;save user iy
	LD	A,(BPS)
	AND	A		;check for zero	bp count
	JP	Z,BPXXX		;error - no bps	set
	LD	B,A		;b - number of breakpoints
	LD	HL,BRKTBL	;breakpoint storage table
	XOR	A
	LD	C,A		;init breakpoint found flag
BPHN10:	LD	E,(HL)
	INC	HL
	LD	D,(HL)		;de - breakpoint address
	INC	HL
	LD	A,(HL)		;saved contents	of breakpoint address
	INC	HL
	LD	(DE),A		;replace rst 38	with actual data
	LD	A,(PCREGL)	;user pc - lo order
	XOR	E
	LD	E,A		;versus	breakpoint address in table
	LD	A,(PCREGH)
	XOR	D		;check hi order
	OR	E
	JR	NZ,BPHN20	;no match - check next entry in	table
	LD	C,B		;pc found in table set c reg nz
BPHN20:	DJNZ	BPHN10		;restore all user data
	LD	HL,SBPS		;fetch number of step bps (0-2)
	LD	B,(HL)
	XOR	A
	LD	(HL),A		;clear regardless
	OR	C		;test bp found flag
	JP	Z,BPXXX		;z - bp	not in table
	INC	HL		;point to bp count
	LD	D,(HL)		;d - bp count
	DEC	B
	JP	M,BPHN30	;m - this was user bp not step or jdbg
	LD	A,(HL)
	SUB	B		;subtract number of step bps from bp count
	LD	(HL),A		;restore bp count
	LD	A,(LCMD)	;what command got us here?
	CP	'S'		;step?
	JR	Z,BPHN90	;step command - check count

				;now we know we have jdbg in progress.  need
				;to check for user specified bp at the same
				;address. if we find one stop trace.
	LD	A,B		;number of step bps to accumulator (1 or 2).

	SUB	C		;compare number of step bps with the offset
				;into the bp table where the current bp was
				;found.  since step bps are always at the end
				;of the table we can determine how bp was set.

 	JP	NC,JDBG30	;nc - we are at end of table so more tracing

BPHN30:	LD	A,C
	NEG
	ADD	A,D		;create index into pass count table
	ADD	A,A
	LD	HL,PSCTBL	;pass count table
	ADD	A,L
	LD	L,A
	JR	NC,BPHN35
	INC	H
BPHN35:	LD	E,(HL)
	INC	HL
	LD	D,(HL)		;de - pass count
	LD	A,D
	OR	E
	JR	Z,BPHN50	;no count in effect
	DEC	DE
	LD	(HL),D
	DEC	HL
	LD	(HL),E		;restored updated count
	LD	A,D
	OR	E		;did it	just go	zero?
	JR	Z,BPHN50	;count just expired
	LD	A,B		;pass count not zero - go or jdbg?
	AND	A
	JP	P,JDBG30	;if step flag p we had step bps
	LD	HL,(PCREG)
	JP	G100		;continue go command
BPHN50:	OR	B		;test if we had step bps
	JP	M,BPHN60	;this was go - print bp message
	LD	A,'X'
	LD	(LCMD),A	;clear command letter so xreg disassembles
	CALL	HOME		;home cursor
	CALL	XREG
	LD	B,22		;cursor on penultimate line
	LD	C,00
	CALL	XYCP

BPHN60:	LD	DE,BPMSG	;print *bp*
	CALL	PRINT		;print message pointed to by de
	LD	HL,(PCREG)
	CALL	OUTADR		;display breakpoint address
	EX	DE,HL
	CALL	FADR		;attempt to find label at this address
	EX	DE,HL		;de - bp address
	JP	NZ,Z8E		;nz - no label found
	LD	A,(MAXLEN)
	DEC	A
	LD	C,A		;c - max size of label
	CALL	PRINTB
	JP	Z8E
BPHN90:	CALL	XREG		;display all registers
	LD	HL,(NSTEP)	;fetch trace count
	DEC	HL
	LD	A,L
	OR	H
	JP	Z,Z8E		;count expired - prompt	for command
	CALL	TTYQ		;test for abort	trace
	CP	CR
	JP	Z,Z8E
	CALL	CRLF		;
	JP	STEP40		;continue trace


BPXXX:	LD	DE,BPEMSG
	CALL	PRINT
	LD	HL,(PCREG)
	CALL	OUTADR
	JP	Z8E


EXXX:	EX	DE,HL
	LD	DE,EMXXX
	CALL	PRINT
	EX	DE,HL
	RET

;******************************************************************************
;*
;*	jdbg:	animated debugger
;*
;*	Jdbg allows the user to watch the Z80 CPU actually execute the
;*	code.  Jdbg displays 18 disassembled instructions on the screen
;*	as well as a user defined memory block referred to in the
;*	comments as a window.
;*
;*	Entry point jdbg:
;*
;*	Jdbg processes user input as a prelude to the actual animation
;*	of the code.  The user enters the starting address to animate
;*	optionally preceded by a subroutine qualifier.  The subroutine
;*	qualifier may be either a "*" which instructs Z8E not to trace
;*	any subroutines which are located below 100h (ie. bdos calls),
;*	or it may be a "/" which means no tracing of any subroutines.
;*	Jdbg will also paint the original screen with the register
;*	contents as well as the memory window.  The contents of the
;*	memory window are also moved into argbuf so that we can compare
;*	the 'old' contents with the 'new' contents once a the first bp
;*	is reached.
;*
;*	Entry point jdbg30:
;*
;* 	Entered here via bphn who determines that animation is in
;*	effect.  In order to cut down on superfluous cursor move-
;*	ment on the screen we compare the old register and memory
;*	window contents with the new contents following the latest
;*	bp.  We only output the changes.  Next we determine if the
;*	current pc exists in disassembled form somewhere on the
;*	screen; if not, we display 18 new disassembled instructions
;*	with the current pc as line one.
;*
;*	Exit jdbg95:
;*
;*	Save current register contents and jump to step40 for next
;*	single step.
;*
;******************************************************************************

JDBG:
	CALL	IEDTBC		;get command line
	JP	P,JDBG02	;p - have input

JDBG00:
	LD	HL,LASTRO
	LD	B,(HL)		;row position of arrow on screen
	LD	C,18		;column
	CALL	XYCP
	LD	C,2
	CALL	SPACES
	LD	B,17H
	LD	C,00
	CALL	XYCP
	LD	HL,JSTEPF
	LD	A,(HL)
	LD	(HL),1
	AND	A
	JP	Z,JDBG90	;J was last means screen intact - just move
				;arrow, else fall thru and repaint screen.
				;Indicate single step
JDBG01:				;+ eg 3.3.6
	LD	A,10
	JR	JDBG10		;init timer

JDBG02:	LD	A,(HL)		;check first char of input
	CP	'#'		;+ eg 3.3.6
	JR	NZ,JDBG2A	;+ Skip if not repaint request
	LD	HL,JSTEPF	;+
	LD	(HL),1		;+ Signal repaint request
	JR	JDBG01		;+
JDBG2A:				;+
	EX	DE,HL		;de - save input buffer	address
	LD	HL,WFLAG	;wflag tells us	whether	to trace subroutines
				;or walk around	them
	LD	(HL),0FFH	;conditionally assume trace all
	SUB	'/'		;slash means don't trace any
	JR	Z,JDBG03	;
	ADD	A,'/'-'*'	;check for star	- no trace of bdos subs
	JR	NZ,JDBG05
	INC	A		;set flag one to indicate no trace of subs
				;at address < 100h (bdos calls)
JDBG03:	LD	(HL),A		;set wflag
	XOR	A		;if slash or space replace with	null in	inbf
				;so parser will	ignore
	LD	(DE),A
JDBG05:	CALL	IARG		;now evaluate address
	JR	Z,JDBG08	;z - no error
	LD	A,(INBFNC)	;check number of characters
	DEC	A		;check for just / or just *
	JR	Z,JDBG00	;treat as single step
	LD	(JSTEPF),A	;indicate screen corrupted
	JP	EXXX		;error -
JDBG08:	LD	(PCREG),HL	;save address at which to start	tracing
	AND	A		;check delimter
	LD	A,10		;no delimeter use default timer value
	JR	Z,JDBG10
	CALL	IARG		;check if user wants non-default timer
	LD	A,10
	JR	NZ,JDBG10	;error - use default
	LD	A,L		;a - timer value as entered by user
JDBG10:	LD	(TIMER),A
	LD	A,FORMF
	CALL	TTYO
; 	LD	B,24		;xmit crlf's to clear screen
JDBG15:	;CALL	CRLF		;clear screen
; 	DJNZ	JDBG15
	CALL	RGDISP		;display current user regs
	CALL	ZWNW		;display disassembled window
	LD	A,(WNWSIZ)
	AND	A		;test if window being displayed
	JR	Z,JDBG28
	LD	DE,WINDOW	;save user specified memory block til next bp
	LD	HL,(WNWTAB)	;start of memory window address
	LD	BC,3
JDBG20: LD	A,(FWNDOW)	;position cursor starting at column
	SUB	6
	CALL	CURS
       	CALL	OUTADR		;display address of memory window
JDBG25:	LD	A,(FWNDOW)
	CALL	CURS		;column position on screen of memory window
				;is (rel pos * 3) + (fwndow)
	LD	A,(HL)		;display this byte

	LD	(DE),A		;save this byte in window between bps
	CALL	OUTHEX
	INC	B		;move and display user specifed number
                                ;of bytes (wnwsiz)
	LD	A,(WNWSIZ)
	SUB	B
	JR	Z,JDBG28
	INC	HL
	INC	DE
	LD	A,(NLMASK)	;check for new line time
	AND	B
	JR	NZ,JDBG25	;not end of line - display next byte else...
	JR	JDBG20		;...display address first
JDBG28:	LD	A,3		;point to very first instruction
	JP	JDBG75


				;breakpoint handler jumps here for full
				;screen single step
JDBG30:	LD  	C,3
	CALL	SPACES		;remove => from screen
	LD	B,C		;(c=0 after spaces executes)
	LD	HL,REGCON	;new contents of registers following bp
	LD	DE,REGSAV	;old prior to bp
JDBG35:	LD	A,(DE)		;compare old vs new
	CP	(HL)
	INC	HL
	INC	DE
	JR	NZ,JDBG40	;different - display new
	LD	A,(DE)		;check hi order byte of this reg pair
	CP	(HL)
	JR	Z,JDBG45	;z - hi and lo bytes the same so try next reg
JDBG40:
;	ld	a,4		;col position of reg pair is (rel pos * 9) + 3
;	and	b
;	jr	z,jdbg42
;	ld	a,3
;	and	b		;- 9 bytes deleted here
;	inc	a
	PUSH	BC		;+save register number
	LD	C,B		;+move it to c while we build line number
	LD	B,0		;+assume first line for now
	LD	A,7		;+regs-per-line mask
	CP	C		;+generate carry if second line
	RL	B		;+shift carry into line number
	AND	C		;+generate line-relative register number
	LD	C,A		;+col = reg * 9 + 3 if non-prime
	ADD	A,A		;+ *2
	ADD	A,A		;+ *4
	ADD	A,A		;+ *8
	ADD	A,C		;+ *9
	BIT	2,C		;+is it a prime (alternate) register?
	JR	Z,JDBG42	;+skip if not
	ADD	A,C		;+*10
	SUB	3		;+col = reg * 10 if prime
JDBG42:
	ADD	A,3		;+
	LD	C,A		;+
	CALL	XYCP		;+
	POP	BC		;+ added 29 bytes

;	add	a,3		;- deleted another 5 bytes here
;	call	curs		;- nett cost = 14 bytes for new code
;				;- but we save 19 bytes in 'curs:' routine

	LD	A,(HL)		;display upper byte of reg contents
	CALL	OUTHEX
	DEC	HL		;rewind to pick up lo order byte
	LD	A,(HL)
	INC	HL
	CALL	OUTHEX		;display lo order
JDBG45:	INC	HL
	INC	DE
	INC	B
	LD	A,REGSIZ/2	;number of reg pairs to display
	SUB	B
	JR	NZ,JDBG35
	CALL	RSPACE
	LD	B,1
	LD	C,36
	CALL	XYCP

	LD	B,0
	CALL	PSWDSP		;now display flag reg mnemonics

	LD	A,(WNWSIZ)	;check window size
	AND	A
	JR	Z,JDBG60	;z - no memory window in effect
	LD	HL,(WNWTAB)	;hl - address of start of window
	LD	BC,03
	LD	DE,WINDOW	;old contents of window stored here
JDBG50:	LD	A,(DE)		;compare old vs new
	CP	(HL)
	JR	Z,JDBG55	;same - no reason to display
	LD	A,(FWNDOW)	;col position of byte is (rel pos * 3) + 50
	CALL	CURS
	LD	A,(HL)		;display byte

	LD	(DE),A		;we only need to move byte if it changed

	CALL	OUTHEX
JDBG55:	INC	B		;bump memory window byte count
	LD	A,(WNWSIZ)  	;max size
	INC	HL
	INC	DE
	SUB	B
	JR	NZ,JDBG50	;loop until entire window examined

JDBG60:	LD	A,18		;init count of disassembled instructions
	LD	(JLINES),A
	LD	DE,(ZASMFL)	;address of first disassembled instruction
				;on screen
JDBG65:	LD	HL,(PCREG)
	AND	A
	SBC	HL,DE
	JR	Z,JDBG70	;found - pc exists somewhere on screen
	CALL	ZLEN00		;compute length	of this	instruction
	LD	B,0
	EX	DE,HL		;hl - address on disassembled instruction
	ADD	HL,BC		;add length to compute address of next inline
				;instruction for display
	EX	DE,HL		;de - restore new istruction pointer
	LD	HL,JLINES
	DEC	(HL)		;dec screen line count
	JR	NZ,JDBG65
	LD	HL,(PCREG)	;pc not	on screen - so current pc will be new
				;first pc on screen
	LD	(ZASMFL),HL
	LD	BC,0300H	;cursor	row 4 -	col 1
	CALL	XYCP
	CALL	ZWNW		;instruction not on screen so paint a new
				;screen	starting at current pc
	LD	A,3		;disassembled instructions start on line 4
	JR	JDBG75
JDBG70:	LD	A,(JLINES)
	NEG
	ADD	A,21		;a - screen row	on which to position cursor
JDBG75:	LD	(LASTRO),A	;save position of arrow
	LD	B,A		;pass to xycp
	LD	C,18		;pass column
	CALL	XYCP		;position cursor routine
	LD	DE,MRROW
	CALL	PRINT
	LD	A,(LASTRO)	;xy positioning added after '=>' as
				;some systems have a destructive bs
	LD	C,17		;new cursor loc
	CALL	XYCP		;put it there
	LD	A,(JSTEPF)
	DEC	A		;test if single stepping
	JP	Z,JDBG95
	CALL	TTYQ
	LD	HL,TIMER
	LD	B,(HL)
	JR	Z,JDBG80
	CP	'0'
	JR	C,JDBG78
	CP	3AH
	JR	NC,JDBG95
	AND	0FH
	LD	(HL),A
	LD	B,A
	JR	JDBG80
JDBG78:	CP	CR		;carriage return ends command
	JR	Z,JDBG95

JDBG80:	CALL	CLOK

JDBG90:	LD	DE,REGSAV	;move current reg contents to save area
	LD	HL,REGCON
	LD	BC,REGSIZ
	LDIR
	JP	STEP40


				;user requested abort from console
JDBG95: LD	B,22		;position cursor on line 23 for prompt
	LD	C,0
	CALL	XYCP
	XOR	A
	LD	(JSTEPF),A	;indicate we have full screen of data
	JP	Z8E		;to z8e command processor



ZWNW:				;display disassembly window
	LD	A,18		;number of instructions to disassemble
ZWNW05:	LD	HL,(PCREG)
	LD	(ZASMFL),HL	;save pc of first line
ZWNW10:	LD	(JLINES),A
	LD	(ZASMPC),HL	;save here as well
	LD	DE,ZASMBF+96	;disassemble in upper portion of buffer to
				;prevent overlap with big memory windows.
				;otherwise, every time we disassemble a new
				;screen we have to repaint the window.

	CALL	ZASM10		;disassemble first instruction
	LD	A,30		;test line length
	CP	C
	JR	Z,ZWNW20
	LD	C,42
ZWNW20:	CALL	PRINTB
	CALL	CRLF
	LD	HL,(ZASMNX)	;hl - next address to disassemble
	LD	A,(JLINES)
	DEC	A
	JR	NZ,ZWNW10
	LD	B,3		;position cursor next to next instruction
				;to execute which is the first one on the
				;screen - line 4  col 20
	LD	C,20
	CALL	XYCP
	RET


				;display regs at top of screen:
RGDISP:	CALL	HOME		;home cursor
	CALL	XREG		;display regs
	CALL	PSWDSP		;display flag reg
	JP	CRLF



CURS:	PUSH	BC		;This routine has been simplified and shortened
	PUSH	DE		;by 19 bytes because it is no longer used for
	PUSH	HL		;register display positioning.  jrs 20/4/87
	LD	D,A
	LD	E,C		;save base row address
;	cp	3		;test if reg or memory window (3 is reg)
;	ld	a,7
;	jr	z,curs00	;z - regs are eight per line (first line)

	LD	A,(NLMASK)
CURS00:	AND	B		;item number mod lnmask is the relative pos of
	LD	C,A		;reg contents or memory data byte
	ADD	A,A		;
	ADD	A,C
	LD	C,A		;c - rel pos times three

;	ld	a,d		;if base column address is < 50 then this is
				;reg display
;	sub	3
;	ld	h,a
;	ld	a,c
;	jr	nz,curs20	;nz - not reg display - must be memory
;	add	a,a		;so multiply times three again
;	add	a,c		;times 9 in all for register display

CURS20:	ADD	A,D		;add in base
	LD	C,A		;c - absolute col number
;	xor	a		;test if this is reg or memory window display
;	or	h
;	jr	z,curs30	;z - this is register display
	LD	A,(FWNDOW)
	CP	68		;14-char symbols in effect?
	JP	Z,CURS40
CURS30:	SRL	B
CURS40:	LD	A,0FCH
	AND	B		;now compute row number
	RRCA
	RRCA
	ADD	A,E		;base row address
	LD	B,A		;b - absolute row number
	CALL	XYCP		;convert row and column to xy cursor address
	POP	HL
	POP	DE
	POP	BC
	RET



CLOK:
	LD	D,50  		;idle loop - decrement to 0 and reload
	LD	E,00
	DEC	B		;user specified the loop counter
	RET	M
CLOK10:	DEC	DE
	LD	A,E
	OR	D
	JR	NZ,CLOK10
	JR	CLOK


;******************************************************************************
;*
;*	exam:	examine	memory and display in hex and ascii.  user is allowed
;*		to modify memory after every byte is displayed.	ilin called
;*		to parse input buffer into a single string of bytes which is
;*		returned in argbuf.  the byte count of the string is returned
;*		in argbc, and this number of bytes is transferred to the
;*		current	memory address.
;*
;*		user may optionally scan memory	by entering cr.	 command
;*		terminates when	a single space is entered.
;*
;*		enter:	b - 0
;*		       de - address at which to	display	first byte
;*
;******************************************************************************

EXAM:	CALL	ILIN
	JP	NZ,EXXX
	EX	DE,HL
EXAM00:	CALL	NEWLIN
	LD	A,(DE)		;fetch byte to display regardless
	CALL	OUTBYT
	CALL	RBYTE
	JR	NZ,EXAM00 	;nz - don't replace memory contents
	CP	'.'
	JR	NZ,EXAM10
	LD	A,(INBFNC)
	DEC	A
	RET	Z
EXAM10:	LD	HL,ARGBC	;byte count to c
	LD	C,(HL)
	LD	B,0
	LD	(EXAMPT),DE
	LD	HL,ARGBF	;start of evaluated input
	LDIR
	LD	A,(TRMNTR)
	CP	CR
	JR	Z,EXAM00
	LD	DE,(EXAMPT)
	JR	EXAM00

HSYM:	RET
USYM:	RET


BANK:	CALL	IEDTBC		;Solicit input
	JP	P,BANK00	;p - input present
	JP	EXXX
BANK00:	CALL	IARG		;Read in next arg (starting address)
	JP	NZ,EXXX		;Invalid starting address
	EX	DE,HL		;DE - physycal page
	CALL	IARG		;Next arg
	JR	Z,BANK15	;Z - no	errors
	JP	EXXX
BANK15:	LD	B,L		; logical page
	LD	A,$10
	CP	B
	JP	C,EXXX		; invalid logical
	SLA	B
	SLA	B
	SLA	B
	SLA	B
	LD	C,$20		; MMU port
	OUT	(C),E
	RET


;------------------------------------------------------------------------------
;
;	dump:  Dump memory in hex and ASCII
;
;	Memory is dumped in hex	and ASCII in user-specified block size.
;	If the D command is given without arguments then memory	is dumped
;	beginning at the address where we left off as store in blkptr.
;	User is	queried	after each block is dumped:
;
;		cr - End command			\  v 3.5.1
;	    Not	cr - Dump next consecutive block	/  jrs 27 Dec 88
;
;------------------------------------------------------------------------------

DUMP:	CALL	IEDTBC		;Solicit input
	JP	P,DUMP00	;p - input present
	LD	DE,(BSIZ)	;No input means	use previous block size
	LD	HL,(BLKPTR)	;   ...	and address
	JR	DUMP30
DUMP00:	CALL	IARG		;Read in next arg (starting address)
	JP	NZ,EXXX		;Invalid starting address
	EX	DE,HL		;DE - starting address to dump
	CALL	IARG		;Next arg (block size)
	JR	Z,DUMP15	;Z - no	errors
	LD	HL,000		;Default to block size of 256
	JR	DUMP20
DUMP15:	XOR	A
	OR	H		;Test for block	size or	ending address
	JR	Z,DUMP20	;Less than 256 must be block size
	SBC	HL,DE		;Compute size
	JP	C,EXXX
DUMP20:	LD	A,L
	OR	H
	JR	NZ,DUMP25
	INC	H
DUMP25:	LD	(BSIZ),HL
	EX	DE,HL		;DE - block size   HL -	memory pointer
DUMP30:	LD	B,16		;Init bytes-per-line count
	CALL	TTYQ
	CP	CR
	RET	Z
	CALL	CRLF		;Display current address on new line
	CALL	OUTADR
	LD	C,2
	CALL	SPACES		;Hex display starts two	spaces right
DUMP40:	DEC	B		;Decrement column count
	LD	A,(HL)
	INC	HL
	CALL	OTHXSP		;Display memory	in hex
	INC	C		;Tally of hex bytes displayed
	DEC	DE		;Decrement block count
	LD	A,D
	OR	E		;Test for end of block
	JR	Z,DUMP50	;Z - end of block
	XOR	A
	OR	B		;End of	line?
	JR	NZ,DUMP40	;Not end of line - dump	more in	hex
	JR	DUMP60
DUMP50:	LD	A,(BSIZHI)
	AND	A		;Block size greater than 256?
	JR	NZ,DUMP55	;NZ - greater
	LD	A,(BSIZLO)
	AND	0F0H		;Block size less than 16?
	JR	Z,DUMP60	;Z - less
DUMP55:	LD	A,(BSIZLO)
	AND	0FH		;Block size multiple of	16?
	JR	Z,DUMP60	;Multiple of 16
	NEG
	ADD	A,16
	LD	B,A
	ADD	A,A
	ADD	A,B
DUMP60:	ADD	A,3		;Plus three - begin ASCII display
	LD	B,A		;Pad line until	ASCII display area
DUMP70:	CALL	RSPACE
	DJNZ	DUMP70
	SBC	HL,BC		;Rewind	memory point by	like amount
DUMP80:	LD	A,(HL)		;Start ASCII display
	INC	HL
	CALL	ASCI
	DEC	C
	JR	NZ,DUMP80
	CALL	TTYQ		;CR aborts command
	CP	CR
	JP	Z,Z8E
	LD	A,D		;Test for block	size tally expired
	OR	E
	JR	NZ,DUMP30
	LD	DE,(BSIZ)	;Reinit	block size
	CALL	TTYI		;Query user for	more
	CP	CR
; Next two lines replaced by inverted test - 27 Dec 88 - jrs - V 3.5.1
;	call	z,crlf
;	jr	z,dump30	;not cr	- next block
;----				(Comment on last line is wrong anyway!)
	CALL	NZ,CRLF		;Not cr - next block
	JR	NZ,DUMP30
;----
	LD	(BLKPTR),HL
	RET			;end command

;******************************************************************************
;*
;*	rgst:  display and optionally modify individual	registers
;*
;*	call iedt:   read edited input into inbf
;*	call prsr:   parse input
;*	call mreg:   validate register name and	map into reg storage
;*	call iarg:   query user	for replacement
;*
;******************************************************************************

RGST:	LD	C,' '		;get edited input
	LD	B,INBFSZ
	CALL	IEDT
	RET	M
	LD	A,(TRMNTR)
	CP	' '
	CALL	Z,BKSP
	CALL	PRSR
	OR	B		;unbalanced quotes (prime reg?)
	JP	P,RGST00
	AND	7FH
	CP	3
	JR	NZ,RGST25
	DEC	HL
	LD	A,(HL)
	SUB	QUOTE
	JR	NZ,RGST25
	LD	(HL),A
RGST00:	LD	A,(INBFNC)	;number	of characters in buffer
	CP	4
	JR	NC,RGST25	;error - too many chars
	NEG
	ADD	A,4		;calculate space padding
	LD	C,A
	CP	3		;was it	one?
	JR	NZ,RGST10
	LD	A,(DE)
	CALL	IXLT
	CP	'P'
	JR	NZ,RGST10
	LD	(INBFNC),A	;any number > 2	indicates 16 bit register
RGST10:	CALL	SPACES
	LD	A,(HL)		;check last char in parse buffer
	SUB	QUOTE
	JR	NZ,RGST15	;not quote
	LD	(HL),A		;replace with null
RGST15:	CALL	MREG		;validate register name
	JR	NZ,RGST25	;error
	LD	A,(REGTRM)	;mreg stored char following reg	name
	AND	A
	JR	NZ,RGST25	;error - no operators allowed
	LD	A,(INBFNC)	;now check number of chars in buffer
	LD	B,A		;save in b reg for 8 or	16 bit reg test
	DEC	A		;test for one -	8 bit reg
	LD	C,3
	JR	Z,RGST20
	LD	A,(HL)
	CALL	OUTHEX		;display byte of reg contents
	DEC	HL
	LD	C,1
RGST20:	LD	A,(HL)
	CALL	OTHXSP
	CALL	SPACES		;reg c - number	of spaces to print
	EX	DE,HL		;de - save reg contents	pointer
RGST22:	CALL	ISTR		;query user for	reg value replacement
	LD	A,(INBFNC)	;test number of	chars in input buffer
	DEC	A		;
	JP	M,RGST40	;none -	prompt for next	reg name
	CALL	IRSM
	JR	Z,RGST30
	LD	A,(INBFNC)
	AND	A
	JR	Z,RGST22
RGST25:	CALL	EXXX
	JR	RGST40		;accept	new reg	name
RGST30:	EX	DE,HL
	LD	(HL),E
	DEC	B		;test for 16 bit reg
	JR	Z,RGST40	;z - 8 bit reg
	INC	HL
	LD	(HL),D		;save upper byte of user input
RGST40:	CALL	CRLF
	CALL	SPACE5
	JP	RGST



MREG:	LD	C,23		;number	of reserved operands
	CALL	OPRN00		;check validity	of register name
	LD	A,(DE)		;last char examined by operand routine
	CALL	OPRTOR
	RET	NZ		;error - not null or valid operator
	LD	(REGTRM),A	;save terminator character for rgst
	LD	A,C
	CP	17		;valid reg names are less than 17
	JR	C,MREG00	;so far	so good
	SUB	23		;last chance - may be pc
	RET	NZ		;error - invalid reg name
	LD	A,10		;make pc look like p for mapping
MREG00:	LD	HL,REGMAP	;ptrs to register contents storage
	ADD	A,L		;index into table by operand value
	LD	L,A
	JR	NC,MREG05
	INC	H
MREG05:	LD	A,B		;b reg set m by	prsr if	trailing quote
	AND	A
	LD	A,0		;assume	no quote - not prime reg
	JP	P,MREG10	;p - correct assumption
	LD	A,8		;bias pointer for prime	reg contents
MREG10:	ADD	A,(HL)
	LD	C,A		;save mapping byte
	AND	7FH		;strip sign
				;so iarg knows 16 bit reg pair
	LD	HL,REGCON	;use mapping byte to build pointer
	ADD	A,L
	LD	L,A
	JR	NC,MREG50
	INC	H
MREG50:	XOR	A		;hl - pointer to register contents
	RET


;******************************************************************************
;*
;*	qprt:	read and display / write to i/o	ports
;*
;*		contents of ports are displayed	and the	user is	queried
;*		input character	effects	the current port address:
;*
;*		space -	display	next sequential	port on	same line
;*		lf    -	display	next sequential	port on	new line
;*		cr    -	end command
;*		slash -	display	same port on same line
;*		^     -	display	previous port on new line
;*
;*		any other input	is treated as a	replacement byte and
;*		is output to the current port address.	any of the
;*		above characters may be	used to	continue the display.
;*
;*		enter: e  - port at which to begin display
;*
;******************************************************************************

QPRT:
NPRT:
	XOR	A
	LD	(PARENF),A
  	CALL	IEDTBC		;get port specified by user
	LD	HL,PORT
	LD	E,(HL)
	JP	M,QPRT30	;m - no input means use last port number
	EX	DE,HL
        CALL	IARG		;extract address
	JP	NZ,EXXX
	EX	DE,HL 		;e - new port number
	LD	(HL),E
	LD	A,(PARENF)
	CP	'('
	JR	NZ,QPRT30
	LD	C,2
	CALL	SPACES
QPRT00:	LD	C,E
	IN	A,(C)
	LD	B,A
	CALL	OUTHEX
	LD	C,2
	CALL	SPACES
	LD	C,8		;number of bits to display
QPRT10:	SLA	B		;most significant bit to carry
	LD	A,'0'
	ADC	A,0		;carry makes it a 1
	CALL	TTYO
	DEC	C
	JR	NZ,QPRT10
	LD	C,E
	LD	B,3
	CALL	TTYQ
	CP	CR
	RET	Z
	CALL	CLOK		;so we don't go faster than the terminal
	LD	E,C
	LD	A,B
	AND	A
	RET	P
	LD	B,12
QPRT20:	CALL	BKSP
	DJNZ	QPRT20
	JR	QPRT00
QPRT30:	CALL	CRLF
	LD	A,E
	LD	(PORT),A
	CALL	OTHXSP
	CALL	RSPACE
	LD	C,E
	LD	A,(LCMD)
	CP	'N'
	JR	Z,QPRT50
       	IN	A,(C)
	CALL	OUTBYT
QPRT50:	CALL	RBYTE
	LD	A,(TRMNTR)
	JR	NZ,QPRT60
	CP	'.'
	RET	Z
	LD	HL,ARGBC
	LD	B,(HL)
	LD	HL,ARGBF
	LD	C,E		;port number
	OTIR
	JR	QPRT30
QPRT60:	CP	' '
	JR	NZ,QPRT30
	DEC	DE
	JR	QPRT30

;******************************************************************************
;*
;*	break:	set breakpoint routine
;*
;*	breakpoint address storage table (brktbl) is examined and user
;*	specified breakpoint is	considered valid unless:
;*
;*		     - table full
;*		     - address already exists in table
;*
;*	optional pass counts can be specified by the user immediatley following
;*	the breakpoint if they are enclosed in parens.
;*
;*	entry point brk30:
;*	      entered from single step command to set breakpoint.  two table
;*	      slots are	permanently available for step breakpoints. step
;*	      routine calls with c pos to tell us not to look for more args
;*	      in the input buffer.
;*
;******************************************************************************

BREAK:
	CALL	IEDTBC
	RET	M		;end command - no input
	LD	C,0FFH		;set neg - distinguish ourselves from step
BRK10:	LD	A,(BPS)		;fetch current bp count
	CP	MAXBP		;table full
	JP	NC,EXXX		;full -	abort command
	LD	B,A		;save current count
	CALL	IARG
	JP	NZ,EXXX
	EX	DE,HL		;de - breakpoint address to set
BRK30:	LD	HL,BRKTBL
	XOR	A
	OR	B		;check for no breakpoints in effect
	JR	Z,BRK60		;none -	bypass check for duplicate
BRK40:	LD	A,E
	CP	(HL)		;check lo order	address	match
	INC	HL
	JR	NZ,BRK50	;no match - check next
	LD	A,D
	SUB	(HL)		;check hi order
	JR	NZ,BRK50	;no match - check next
	OR	C
	RET	P
	LD	HL,BPS		;pointer to bp count
	LD	A,(HL)
	SUB	B		;create	index into psctbl
	JR	BRK70
BRK50:	INC	HL
	INC	HL		;bump past contents storage byte
	DJNZ	BRK40
BRK60:	LD	(HL),E		;set in	table
	INC	HL
	LD	(HL),D
	LD	HL,BPS		;breakpoint count
	LD	A,(HL)		;fetch current count for user as index
	INC	(HL)		;bump bp count
BRK70:	LD	DE,PSCTBL	;base of pass count table
	ADD	A,A		;two byte table
	ADD	A,E
	LD	E,A
	JR	NC,BRK80
	INC	D
BRK80:	XOR	A
	LD	(DE),A		;pre-clear pass	count table entry
	INC	DE
	LD	(DE),A
	OR	C		;test if this was step calling
	RET	P		;i'm positive it was
	LD	A,(DELIM)	;check delimeter which followed	bp address
	AND	A
	RET	Z		;end of	line null - terminate command
	CP	','		;check for pass	count delimeter
	JP	NZ,BRK10	;not comma means treatt	this as	new bp
	CALL	IARG		;get next arg
	JP	NZ,EXXX		;nz - evaluation error
	EX	DE,HL		;de - pass count as entered by user
	LD	(HL),D		;store pass count in table
	DEC	HL
	LD	(HL),E
	AND	A		;check delimeter
	JP	NZ,BRK10	;nz - more arguments follow
	RET			;end of	line null - terminate command


;******************************************************************************
;*
;*	cbreak:	clear breakpoint
;*
;*	breakpoint address storage table (brktbl) is examined and breakpoint
;*	is removed if found. breakpoint	is removed by bubbling up all bp
;*	addresses which	follow,	ditto for pass counts.
;*
;******************************************************************************

CBREAK:	CALL	IEDTBC
	RET	M		;no input ends command
	LD	A,(BPS)		;fetch breakpoint count
	OR	A		;any if	effect
	RET	Z		;no
	LD	B,A		;temp save count
	CALL	IARG		;extract address to clear from input buffer
	LD	DE,BRKTBL	;bp address storage table
	JR	Z,CBRK10
	LD	A,(PRSBF)
	CP	'*'
	JP	NZ,EXXX
	LD	A,(INBFNC)
	DEC	A
	JP	NZ,EXXX
	LD	(BPS),A
	RET

CBRK10:	LD	A,(DE)		;test lo order address for match
	CP	L
	INC	DE
	JR	NZ,CBRK20	;no match - examine next entry
	LD	A,(DE)
	CP	H		;versus	hi order bp address
CBRK20:	INC	DE
	INC	DE		;bump past contents save location
	JR	Z,CBRK30	;zero -	found bp in table
	DJNZ	CBRK10
	JP	EXXX		;error - breakpoint not	found
CBRK30:	LD	H,0FFH		;rewind	to point to bp address
	LD	L,-3
	ADD	HL,DE
	EX	DE,HL		;de - ptr to bp	  hl - ptr to next bp
	LD	A,B		;multiply number of bps	remaining in table
				;times three bytes per entry
	ADD	A,A
	ADD	A,B
	LD	C,A		;init c	for ldir
	LD	A,B		;save number of	bps remaining
	LD	B,0
	LDIR			;bubble	up all remaining entries in table
	LD	C,A		;
	LD	HL,BPS		;address of bp count
	LD	A,(HL)		;
	DEC	(HL)		;decrement system breakpoint count
	SUB	C		;compute relative number of pass count table
				;entry we wish to clear
	ADD	A,A		;times two bytes per entry
	LD	L,A
	LD	H,B		;cheap clear
	LD	DE,PSCTBL
	ADD	HL,DE		;index into pass count table
	EX	DE,HL
	LD	HL,02
	ADD	HL,DE		;de - ptr to pass count	 hl - next in table
	SLA	C		;number	of pass	counts to move
	LDIR
	LD	A,(DELIM)	;recheck delimeter
	AND	A
	JR	NZ,CBREAK	;not end of line terminator - clear more
	RET

;***********************************************************************
;*
;*     obreak:	output all breakpoints and associated pass counts to
;*		console.  search symbol	table for match, if symbol name
;*		found display it along with address.
;*
;*     wbreak:	wipe out (clear) all breakpoints currently in effect
;*
;*		entered:  b - zero
;*
;***********************************************************************

OBREAK:	LD	A,(BPS)		;fetch bp count
	DEC	A		;test for no breakpoints
	RET	M		;m - none
	LD	B,A		;save count
OBRK00:	LD	HL,BRKTBL	;base of breakpoint storage table
	LD	E,B		;use current breakpoint	count as index
	LD	D,0		;clear
	ADD	HL,DE		;this is a three byte table
	ADD	HL,DE
	ADD	HL,DE
	LD	E,(HL)		;fetch lo order	bp address
	INC	HL
	LD	D,(HL)		;upper address
	EX	DE,HL
	CALL	OUTADR		;display address
	EX	DE,HL		;hl - breakpoint table
	CALL	FADR		;check symbol table for	name match
				;   symbol table pointer returned in de
				;   zero flag set if found
	LD	A,(MAXLEN)
	LD	C,A
	DEC	BC		;max number of chars in	a symbol name
	EX	DE,HL		;hl - symbol table address if
	CALL	Z,PRINTB	;display name if found in symbol table
	LD	A,B
	ADD	A,A		;bp number times two
	LD	HL,PSCTBL	;base of pass count table
	ADD	A,L
	LD	L,A
	JR	NC,OBRK10
	INC	H
OBRK10:	LD	E,(HL)		;lo order pass count
	INC	HL
	LD	D,(HL)		;upper byte
	LD	A,D		;test if pass count in effect
	OR	E
	JR	Z,OBRK20	;z - no	pass count for this bp
	INC	C
	CALL	SPACES
	EX	DE,HL
	CALL	OUTADR		;display pass count in hex
OBRK20:	CALL	CRLF
	LD	C,5
	CALL	SPACES
	DEC	B		;dec bp	count
	JP	P,OBRK00
	RET



KDMP:	CALL	IEDTBC		;let user input address of memory to display
	RET	M		;no input ends command
	CALL	IARG		;evaluate user arg
	JP	NZ,EXXX
	EX	DE,HL		;de - save memory address
	CALL	IARG		;now get count
	LD	A,0
	JR	NZ,KDMP20	;error during input - display 00 bytes
	OR	H
	JP	NZ,EXXX		;greater than 256 is error
	LD	A,(MAXLEN)	;max symbol length
	LD	B,2		;assume big names
	CP	15
	LD	A,18		;number of disassembled lines displayed
	JR	Z,KDMP00
	LD	B,3		;double number of lines one extra time
KDMP00:	ADD	A,A		;times two
	DJNZ	KDMP00
	CP	L
	JR	C,KDMP20	;if number of bytes specified by user is too
				;large then use default
	LD	A,L		;use value specified by user
KDMP20:	LD	(WNWTAB),DE
	LD	(WNWSIZ),A
	RET

;**************************************************************************
;*
;*		     begin/resume execution of user program
;*
;*	address	entered:     execution begins at entered address
;*	no address entered:  execution resumed at specified by saved pc
;*
;*	breakpoint table examined:
;*	      -	memory contents	from each address is removed from user
;*		program	and saved in breakpoint	table
;*	      -	rst 38 instruction is placed at	each breakpoint	address
;*		in user	program
;*
;*	user registers restored
;*
;***************************************************************************

GO:	CALL	IEDTBC		;query user for	execution address

;	ret	m		;- eg 3.3.3 no input - reprompt
	JP	P,G001		;+ Skip if argument supplied, else:
	LD	HL,(PCREG)	;+ Use current PC
	JR	G002		;+
G001:				;+
	CALL	IARG
	JP	NZ,EXXX		;error - invalid argument
G002:				;+
	CALL	CRLF
	CALL	CRLF
G100:	LD	(JMPLO),HL	;store execution address
	LD	A,IJP
	LD	(SJMP),A	;set jp	instruction
	LD	(JMP2JP),A	;just in case
	LD	A,(BPS)		;check breakpoint count
	AND	A
	JP	Z,G600		;z - no	bps in effect -	no restoration needed
	LD	B,A
	LD	HL,BRKTBL
	LD	C,0FFH
G300:	LD	E,(HL)
	INC	HL
	LD	D,(HL)		;de - breakpoint address removed from table
	INC	HL		;point to contents save	byte in	table
	LD	A,(DE)
	LD	(HL),A
	LD	A,(JMPLO)
	CP	E		;check if bp from table	matches	next pc
	JR	NZ,G400		;no match - set	breakpoint
	LD	A,(JMPHI)
	CP	D		;check hi order	next pc	address
	JR	NZ,G400		;no match - set	bp
	LD	C,B		;set flag - current pc matches breakpoint
	JR	G500
G400:	LD	A,RST38		;set rst38 instruction
	LD	(DE),A		;save user byte	in brktbl
G500:	INC	HL
	DJNZ	G300		;examine all entries
	INC	C		;current pc match breakpoint?
	JP	Z,G600		;z - no (c reg not 0ffh)
	LD	A,(SBPS)	;check number of step breakpoints
	AND	A		;tracing?
	JP	NZ,G600		;nz - this is trace

				;pc points to address in breakpoint table
				;next instruction will not be executed where
				;it resides.  it will be moved to our internal
				;buffer (execbf) and executed there. then we
				;set an rst38 at actual location in user
				;program.  this allows us to debug loops in
				;which only one bp is set.  otherwise we would
				;not be able to set a bp at the address where
				;the pc points and debugging loops would be
				;impossible.
	LD	HL,EXECBF
	LD	DE,(JMPLO)	;de - pointer to next instruction to execute
	LD	(JMPLO),HL	;execute buffer
	LD	B,4		;clear execute buffer
G505:	LD	(HL),INOP
	INC	HL
	DJNZ	G505
	CALL	ZLEN00		;calculate length
				;if instruction modifies pc then zlen lets us
				;know by setting b reg nz and c contains
				;instruction length

	LD	(JROPND),HL	;if this is a jr instruction we need to save
				;address where we will be jumping


				;default execbf has been initialized:
				;
				;four nops
				;     jp   user program
				;
	EX	DE,HL		;hl - ptr to user instruction
	LD	DE,EXECBF
	LD	A,(HL)		;first object byte from	user program
G518:	LD	(HL),RST38	;replace
	PUSH	BC		;b - if nz this is a pc modifying instruction
				;c - number of bytes of object code for this
				;    instruction
G520:	LD	(DE),A		;into execute buffer
	INC	DE
	INC	HL		;bump user program pointer
	LD	A,(HL)		;next byte of instruction from user program
	DEC	C
	JR	NZ,G520
	POP	BC
				;the four nops in execbf have now been replaced
				;by from one to four bytes of actual user
				;instruction.  if user instruction was shorter
				;than four bytes the nops remain and are
				;executed until the jump back to the user
				;program at jmp2jp is reached.


	LD	(JMP2),HL	;address of next inline instruction within
				;user code

	EX	DE,HL		;de - next inline instruction in user program
	XOR	A
	OR	B
	JR	Z,G600		;z - the instruction in execbf is not a pc
				;modifying instruction

	LD	A,(EXECBF)	;first byte of instruction
	DEC	C		;one byte instruction?
	JR	Z,G600
	DEC	C
	JR	Z,G550		;two byter
	DEC	C
	JR	NZ,G600		;nz - must be four byter
	LD	B,C		;clear for cpir
	LD	C,Z803SL	;test for call instruction
	LD	HL,Z803S	;load list of first byte of call instructions
	CPIR
	JR	NZ,G600		;nz - not call

				;moving call instructions and executing them
				;locally requires special processing because
				;the z80 will store the address pc+3 on the
				;stack.  in this case we do not want the
				;address  execbf+3 on the stack.  we want the
				;address of the actual location of the user
				;instruction+3 on the stack.  we must do this
				;by simulating a call instruction. we use the
				;jp instruction which is equivalent to the
				;call and we also push a computed return
				;address on to the user stack pointed to by
				;spreg.

	LD	BC,08		;point to jump instruction which is equivalent
				;to call (call nz = jp nz)
	ADD	HL,BC
	LD	A,(HL)		;fetch jump object byte
	LD	HL,(SPREG)	;push next pc onto user stack
	DEC	HL		;decrement user sp
	LD	(HL),D		;de - "return address"
	DEC	HL
	LD	(HL),E
	LD	(SPREG),HL
	LD	(EXECBF),A	;store jp op code
	LD	HL,JMP2		;if conditional call and we fall thru
				;we need to go back to address of call
				;in user program + 3
	LD	(HL),E
	INC	HL
	LD	(HL),D
	JR	G600
				;if next instruction to execute is a
				;relative jump we need to replace it with
				;an absolute equivalent.  this is because
				;having relocated the user jr instruction
				;into execbf we will undoubtedly be out of
				;range of the destination.

G550:	LD	C,Z802CL	;check if this is relative jump
	LD	HL,Z802C
	AND	A		;clear carry
	CPIR
	JR	NZ,G600		;not a jr
	LD	A,C
	LD	BC,Z802C
	SBC	HL,BC
	DEC	HL
	LD	BC,Z803C
	ADD	HL,BC		;point to equivalent absolute jump
	AND	A
	LD	A,(HL)
	LD	HL,EXECBF
	JR	NZ,G555		;nz - not last in list (not djnz)

				;replace djnz with  dec   b
				;		    jp    nz,

	LD	(HL),05		;dec b instruction
	INC	HL
	LD	A,0C2H		;jp nz absolute
G555:	LD	(HL),A
	INC	HL
	LD	BC,(JROPND)	;if this is a conditional jr we need the
				;absolute destination of the jump
	LD	(HL),C
	INC	HL
	LD	(HL),B

G600:	LD	IY,(IYREG)	;restore user iy
	LD	IX,(IXREG)	;restore user ix
	LD	A,(RREG)
	LD	R,A		;restore user r	reg
	LD	A,(IREG)
	LD	I,A		;restore user i	reg
	LD	BC,(BCPREG)	;restore user grade a prime regs
	LD	DE,(DEPREG)
	LD	HL,(AFPREG)
	PUSH	HL
	POP	AF
	LD	HL,(HLPREG)
	EX	AF,AF'
	EXX
	LD	HL,(AFREG)	;restore user accumulator and flag
	PUSH	HL
	POP	AF
	LD	BC,(BCREG)	;restore user bc
	LD	DE,(DEREG)	;restore user de
	LD	HL,(HLREG)	;restore user hl
	LD	SP,(SPREG)	;restore user sp
	JP	SJMP

;******************************************************************************
;*
;*	step:  Single step (trace) routine
;*
;*	Call zlen to determine where to	set breakpoint.
;*
;*		pass:	   de -	current	pc address
;*
;*		returned:  b:  z - next	instruction will not modify pc.
;*				   set bp at address specified by pc+length.
;*
;*			   b: nz - next	instruction will modify	pc (jumps,
;*				   calls, and returns) thus set	bp at address
;*				   returned in hl.
;*
;*			   c:	 - number of bytes in current instruction.
;*
;*		zlen handles secondary breakpoint to set for all conditional
;*		call, return, and jump instructions.
;*
;*	Call brk00 to set breakpoint.
;*
;*		pass:	   b - current number of breakpoints.
;*			  hl - address at which	to set breakpoint.
;*
;*	entry point step:    entered by	user via (s)ingle step command.
;*	entry point step40:  entered by	breakpoint handler - step count	nz
;*
;*	exit:	to go routine to resume	execution.
;*
;******************************************************************************

STEP:	LD	A,0FFH
	LD	(WFLAG),A	;set trace subroutine flag on
	CALL	IEDTBC		;query user for	trace count
	LD	HL,0001
	JP	M,STEP40	;null input - step count of one
	CALL	PRSR
	JP	NZ,EXXX
	LD	A,(DE)		;first character from parse buffer
	SUB	'/'
	LD	(WFLAG),A	;may be	slash -	no subroutine tracing
	LD	HL,00
	JR	NZ,STEP20
	LD	(DE),A
	LD	A,(INBFNC)
	DEC	A
	INC	HL
	JR	Z,STEP40
	DEC	HL
STEP20:	CALL	XVAL		;evaluate contents of parse buffer
	JP	NZ,EXXX
	LD	DE,(PCREG)
	LD	A,(DE)		;first byte of op code at current pc
	CP	0C7H		;test for rst
	JP	Z,EXXX		;no tracing of rsts
STEP40:	LD	(NSTEP),HL	;save step count
	LD	HL,SBPS		;set step flag nz - trace in effect
	INC	(HL)
	LD	DE,(PCREG)	;fetch current pc
	CALL	ZLEN00		;determine number of bytes in instruction
	INC	B		;test where to set breakpoint
	DJNZ	STEP50		;nz - set at address in	hl
	EX	DE,HL
	ADD	HL,BC		;z - set at address pc + instruction length
STEP50:	LD	A,(BPS)		;get current number of bps
	LD	B,A		;pass to set bp	routine	in b reg
	EX	DE,HL		;de - bp address to set
	CALL	BRK30
	LD	HL,(PCREG)	;resume	execution at next pc
	XOR	A
	OR	B
	JP	NZ,G100		;nz - collision	with user bp
	EX	DE,HL
	LD	HL,SBPS		;step bp set by	brk30 -	bump count
	INC	(HL)
	EX	DE,HL
	JP	G100

;******************************************************************************
;*
;*	asmblr:	z80 assembler
;*
;******************************************************************************

ASMBLR:
	CALL	ILIN
	JP	NZ,EXXX
ASM000:	CALL	CRLF
	LD	(ZASMPC),HL	;save here as well
	CALL	ZASM08		;disassemble first instruction

ASM005:
	LD	HL,(ASMBPC)
ASM010:	CALL	CRLF
	CALL	OUTADR		;display current assembly pc
	LD	C,22		;
	CALL	SPACES		;leave room for	object code
	LD	A,3
	LD	HL,OBJBUF	;zero scratch object code buffer
ASM015:	LD	(HL),C
	INC	HL
	DEC	A
	JP	P,ASM015
	LD	(OPRN01),A	;init operand key values to 0ffh
	LD	(OPRN02),A
	CALL	IEDTBC		;get user input
	RET	M		;m - no	input ends command
	CALL	CRET
	CALL	PRSR		;parse to obtain label
	LD	A,(HL)		;check last character
	CP	':'
	JR	NZ,ASM040	;no colon found	- must be op code
	LD	(HL),0		;erase colon
	LD	A,(DE)		;fetch first char of label from	parse buffer
	CP	'A'
	JP	C,ASMXXL	;error - first character must be alpha
	CP	'z'+1
	JP	NC,ASMXXL	;label error
	CP	'a'
	JR	NC,ASM030
	CP	'Z'+1
	JP	NC,ASMXXL
ASM030:	LD	HL,00
	LD	(ISYMPT),HL	;clear pointer
	CALL	ISYM		;attempt to insert symbol into symbol table
	JP	NZ,ASMXXT	;error - symbol	table full
	LD	(ISYMPT),HL	;save pointer to symbol	value in symbol	table
	CALL	PRSR		;extract opcode
	JP	M,ASM005	;m - statement contains	label only
ASM040:	LD	A,(DELIM)	;check delimeter
	CP	','		;check for invalid terminator
	JP	Z,ASMXXO
	LD	C,73		;number	of opcodes in table as index
ASM050:	DEC	C
	JP	M,ASMXXO	;opcode	not found
	LD	B,0
	LD	HL,ZOPCNM	;table of opcode names
	ADD	HL,BC
	ADD	HL,BC		;index times four
	ADD	HL,BC
	ADD	HL,BC
	LD	DE,PRSBF	;start of parse	buffer
	LD	B,4
ASM060:	LD	A,(DE)		;character from	parse buffer
	AND	A		;null?
	JR	NZ,ASM070
	LD	A,' '		;for comparison	purposes
ASM070:	CALL	IXLT		;force upper case for compare
	CP	(HL)
	JR	NZ,ASM050	;mismatch - next opcode	name
	INC	DE
	INC	HL
	DJNZ	ASM060		;must match all	four
	LD	A,(DE)		;null following	opcode?
	AND	A
	JP	NZ,ASMXXO	;error - opcode	more than 4 characaters
	LD	HL,IKEY		;relative position in table is key value
	LD	(HL),C		;save opcode key value
	CALL	PRSR		;extract first operand
	JP	M,ASM085	;m - none
	CALL	OPRN		;evaluate operand
	JR	NZ,ASMXXU	;error - bad first operand
	LD	DE,OPRN01
	CALL	OPNV		;save operand value and	key
	LD	A,(DELIM)
	CP	','
	JR	NZ,ASM085	;need comma for	two operands
	CALL	PRSR		;extract second	operand
	JP	M,ASMXXS	;error - comma with no second operand
	CP	','
	JP	Z,ASMXXS	;illegal line termination
	CALL	OPRN		;evaluate operand
	JR	NZ,ASMXXU	;error - bad second operand
	LD	DE,OPRN02
	CALL	OPNV		;save second operand value and key
ASM085:	XOR	A
	LD	C,A
ASM090:	LD	HL,ZOPCPT	;opcode	name pointer table
	LD	B,0
	ADD	HL,BC		;index into table
	LD	A,(IKEY)	;fetch opcode key value
	CP	(HL)		;check for match
	JR	NZ,ASM095	;
	INC	H		;point to first	operand	table
	LD	DE,OPRN01	;address of first operand key value
	CALL	OPNM		;check validity
	JR	NZ,ASM095	;no match - next
	LD	B,A		;save modified key value
	INC	H		;point to second operand table
	LD	DE,OPRN02	;address of second operand key value
	CALL	OPNM
	JR	Z,IBLD		;match - attempt final resolution
ASM095:	INC	C		;bump index
	JR	NZ,ASM090	;nz - check more
ASMXXU:	LD	A,'U'		;error
	JP	ASMXXX




IBLD:	LD	HL,OBJBUF	;object	code temp buffer
	LD	E,A		;save second operand key
	LD	A,(HL)		;check first byte of object buffer
	AND	A		;null?
	LD	A,C		;instruction key to accumulator	regardless
	LD	C,E		;save second operand modified key
	JR	Z,IBLD00	;z - not ix or iy instruction
	INC	HL		;point to byte two of object code
IBLD00:	CP	40H
	JR	C,IBLD55	;c - 8080 instruction
	CP	0A0H
	JR	NC,IBLD10	;nc - not ed instruction
	LD	(HL),0EDH	;init byte one of object code
	INC	HL
	CP	80H		;check which ed	instruction we have
	JR	C,IBLD55	;c - this is exact object byte
	ADD	A,20H		;add bias to obtain object byte
	JR	IBLD55
IBLD10:	CP	0E0H
	JR	NC,IBLD20
	ADD	A,20H		;8080 type - range 0c0h	to 0ffh
	JR	IBLD55		;object	byte built
IBLD20:	CP	0E8H
	JR	C,IBLD50	;8 bit reg-reg arithmetic or logic
	CP	0F7H		;check for halt	disguised as ld (hl),(hl)
	JR	NZ,IBLD30
	LD	A,76H		;halt object code
	JR	IBLD55
IBLD30:	CP	0F8H
	JR	NC,IBLD50	;8 bit reg-reg load
	LD	D,A		;temp save instruction key value
	LD	A,(OBJBUF)
	AND	A		;check for previously stored first object byte
	LD	A,D
	LD	(HL),0CBH	;init byte regardless
	INC	HL
	JR	Z,IBLD40	;z - not ix or iy instruction
	INC	HL		;bump object code pointer - this is four byter
IBLD40:	ADD	A,0A8H		;add bias for comparison purposes
	CP	98H
	JR	C,IBLD50	;c - shift or rotate instruction
	RRCA
	RRCA
	AND	0C0H		;this is skeleton for bit instuctions
	JR	IBLD55
IBLD50:	ADD	A,A		;form skeleton
	ADD	A,A
	ADD	A,A
	ADD	A,80H
IBLD55:	LD	(HL),A		;store object byte
	XOR	A
	OR	C		;second	operand	need more processing?
	LD	DE,OPRN02
	CALL	NZ,RSLV		;resolve second	operand
	JP	NZ,ASMXXV	;error - invalid operand size
	LD	DE,OPRN01
	LD	A,B
	AND	A		;first operand resolvedX
	CALL	NZ,RSLV		;more work to do
	JP	NZ,ASMXXV	;error - invalid operand size
	LD	A,(IKEY)
	SUB	67		;org directive?
	JR	NZ,IBLD60
	LD	D,(HL)
	DEC	HL
	LD	E,(HL)
	EX	DE,HL
	JP	ASM000		;z - org directive
IBLD60:	LD	DE,OBJBUF
	JR	C,IBLD70	;c - instruction  nc - directive
	LD	B,A		;number	of bytes for defb or defw or ddb
	INC	DE		;point past erroneous assembled	opcode
	INC	DE
	SUB	3		;test for ddb
	JR	C,IBLD75	;c - must be defb or defw
	DEC	A
	JR	NZ,IBLD65	;nz - must be ddb
	LD	D,(HL)		;must be equ
	DEC	HL
	LD	E,(HL)
	LD	HL,(ISYMPT)	;fetch pointer to entry	in symbol table
	LD	A,H
	OR	L
	JP	Z,ASMXXU	;error - no label on equ statement
	LD	(HL),D
	DEC	HL
	LD	(HL),E		;store value of	symbol in symbol table
	LD	C,6
	CALL	SPACES
	LD	A,D
	CALL	OTHXSP
	LD	A,E
	CALL	OTHXSP
	JP	ASM005		;ready for next	input
IBLD65:	DEC	B		;set count of object bytes to 2
	LD	C,(HL)		;exchange hi and lo order bytes	for ddb
	DEC	HL
	LD	A,(HL)
	LD	(HL),C		;new hi order
	INC	HL
	LD	(HL),A		;new hi order replaces old lo order
	JR	IBLD75
IBLD70:	CALL	ZLEN00		;compute length	of instruction in bytes
	LD	B,C		;b - number of bytes of	object code
IBLD75:	LD	HL,(ASMBPC)
	CALL	OUTADR		;re-display current location counter
IBLD80:	LD	A,(DE)		;move from scratch object buffer
	LD	(HL),A		;into address pointed to by location counter
	INC	HL
	INC	DE
	CALL	OTHXSP		;display each object code byte
	DJNZ	IBLD80
IBLD90:	LD	(ASMBPC),HL
	JP	ASM005		;next input from user




OPNM:	LD	A,(DE)		;key value computed by operand routine
	XOR	(HL)		;compare with table operand table entry
	RET	Z		;true match of operand key values
	XOR	(HL)		;restore
	ADD	A,A		;86 all	no operand key values (0ffh)
	RET	M
	LD	A,(HL)		;fetch table entry
	AND	7FH		;sans paren flag for comparison	purposes
	CP	1BH		;check table entry 8 bit - 16 bit - $ rel ?
	JR	C,OPNM00	;c - none of the above
	LD	A,(DE)		;fetch computed	key
	XOR	(HL)		;compare with paren flags
	RET	M		;error - paren mismatch
	LD	A,(DE)		;fetch key once	more
	AND	7FH		;remove	paren flag
	CP	17H		;computed as 8 bit - 16	bit - $	rel?
	JR	Z,OPNM40	;so far	so good
	RET			;
OPNM00:	CP	19H		;check for 8 bit reg
	JR	NC,OPNM20	;8 bit register	match
	CP	18H		;table says must be hl - ix - iy
	RET	NZ		;computed key disagrees
	LD	A,(DE)		;fetch computed	key
	AND	7		;computed as hl	- ix - iy ?
	RET	NZ		;no
OPNM10:	LD	A,(DE)		;fetch computed	key
	XOR	(HL)
	RET	M		;error - paren mismatch	on hl -	ix - iy
	JR	OPNM40
OPNM20:	LD	A,(DE)		;fetch computed	key of 8 bit reg
	AND	A		;
	JR	NZ,OPNM30	;nz - not (hl)
	DEC	A		;error - 8 bit (hl) missing parens
	RET
OPNM30:	CP	8		;test user entered valid 8 bit reg
	JR	C,OPNM40	;c - ok
	AND	A		;test if no carry caused by paren flag
	RET	P		;error - this is not 8 bit reg with parens
	AND	7		;psuedo	8 bit reg: (hl)	(ix) (iy)?
	RET	NZ		;no
OPNM40:	LD	A,(HL)		;fetch table entry
	AND	7FH
	SUB	18H		;make values 18	thru 1f	relative zero
	CP	A		;zero means match
	RET

RSLV:	DEC	A
	JR	Z,RSLV00	;z - 8 bit reg (bits 0-2 of object byte)
	DEC	A
	JR	NZ,RSLV20	;nz - not 8 bit	reg (bits 3-5 of object	byte)
	DEC	A		;make neg to indicate shift left required
RSLV00:	LD	C,A
	LD	A,(DE)		;fetch computed	operand	key
	AND	07		;lo three bits specify reg
	XOR	6		;create	true object code bits
	INC	C		;test if bits 0-2 or bits 3-5
	JR	NZ,RSLV10	;nz - 0	thru 2
	ADD	A,A
	ADD	A,A
	ADD	A,A
RSLV10:	OR	(HL)		;or with skeleton
	LD	(HL),A		;into scratch object buffer
	CP	A		;set zero - no error
	RET
RSLV20:	INC	DE		;point to low order of operand value
	LD	C,(HL)		;c - current skeleton  (if needed)
	INC	HL		;bump object code buffer pointer
	DEC	A
	JR	NZ,RSLV30	;nz - not relative jump
	EX	DE,HL		;save object code pointer in de
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A		;hl - operand value computed by	xval
	LD	A,B
	LD	BC,(ASMBPC)	;current location counter
	INC	BC
	INC	BC
	SBC	HL,BC		;calculate displacement	from current counter
	EX	DE,HL		;de - displacement  hl - object	code pointer
	LD	B,A		;restore b reg
	LD	A,E		;lo order displacement
	INC	D		;test hi order
	JR	Z,RSLV25	;must have been	ff (backward displacement)
	DEC	D
	RET	NZ		;error - hi order not zero or ff
	CPL			;set sign bit for valid	forward	displacement
RSLV25:	XOR	80H		;toggle	sign bit
	RET	M		;error - sign bit disagrees with upper byte
	LD	(HL),E		;store displacement object byte
	CP	A		;set zero flag - no errors
	RET
RSLV30:	DEC	A
	JR	NZ,RSLV40	;nz - not 8 bit	immediate
	LD	A,36H		;test for reg indirect - (hl),nn
	CP	C
	JR	NZ,RSLV35
	LD	A,(OBJBUF)	;test first object byte
	CP	C
	JR	Z,RSLV35	;z - (hl),nn
	INC	HL		;must be (ix+index),nn	or  (iy+index),nn
RSLV35:	LD	A,(DE)		;move lo order operand value to	object buffer
	LD	(HL),A
	INC	DE
	LD	A,(DE)		;test hi order
	AND	A		;
	RET	Z		;z - must be 0 thru +255
	INC	A		;error if not -1 thru -256
	RET
RSLV40:	DEC	A
	JR	NZ,RSLV50	;nz - not 16 bit operand
	LD	A,(DE)		;move both bytes of operand to object buffer
	LD	(HL),A
	INC	HL
	INC	DE
	LD	A,(DE)		;byte two
	LD	(HL),A
	CP	A		;set zero flag - no errors of course
	RET
RSLV50:	DEC	A		;test restart instruction or bit number
	JR	NZ,RSLV60	;nz - bit or interrupt mode number
	LD	A,(DE)		;check restart value specified
	AND	0C7H		;betweed 0 and 38h?
	RET	NZ		;error
	LD	A,(DE)		;fetch lo order	operand	value
	OR	0C7H		;or with instruction skeleton
	DEC	HL
	LD	(HL),A		;rewind	object code pointer
	INC	DE
	LD	A,(DE)		;check hi order	operand	value
	AND	A		;error if not zero
	RET
RSLV60:	DEC	HL		;rewind	object code buffer pointer
	LD	A,(DE)
	AND	0F8H		;ensure	bit number in range 0 -	7
	RET	NZ		;error
	LD	A,(IKEY)	;fetch opcode key value
	SUB	13H		;is this bit number of interrupt mode number?
	LD	A,(DE)		;fetch operand value regardless
	JR	NZ,RSLV70	;nz - bit number
	LD	(HL),46H
	AND	03		;im 0?
	RET	Z
	LD	(HL),56H
	DEC	A		;im 1?
	RET	Z
	LD	(HL),5EH
	DEC	A		;error if not im 2
	RET
RSLV70:	ADD	A,A		;shift bit number left three
	ADD	A,A
	ADD	A,A
	OR	(HL)		;or with skeleton
	LD	(HL),A
	CP	A		;indicate no error
	RET



OPRN:	LD	BC,22		;count of reserved operand
OPRN00:	LD	DE,PRSBF	;buffer	contains operand
	LD	A,(HL)		;last character	of operand in parse buffer
	SUB	')'
	JR	NZ,OPRN20	;not paren
	LD	(HL),A		;remove	trailing paren - replace with null
	LD	A,(DE)		;check first character of parse	buffer
	SUB	'('
	RET	NZ		;error - unbalanced parens
	LD	(DE),A		;remove	leading	paren -	replace	with null
	INC	DE		;point to next character in parse buffer
OPRN20:	LD	HL,ZOPNM	;index into reserved operand name table
	LD	A,C
	ADD	A,A		;index times two
	ADD	A,L
	LD	L,A
	JR	NC,OPRN25
	INC	H
OPRN25:	LD	A,(DE)		;from parse buffer
	CALL	IXLT		;translate to upper case for compare
	CP	(HL)		;versus	table entry
	INC	DE
	JR	NZ,OPRN70	;no match - check next
	LD	A,(DE)		;check second character
	CALL	IXLT		;translate to upper case
	AND	A		;if null - this	is one character reg name
	JR	NZ,OPRN30
	LD	A,' '		;for comparison	purposes
OPRN30:	INC	HL		;bump table pointer
	SUB	(HL)
	JR	NZ,OPRN70	;no match - check next
	INC	DE		;have match - bump buffer pointer
	OR	B		;
	RET	NZ		;nz - mreg calling
	LD	A,C		;check index value
	AND	07
	JR	NZ,OPRN80	;not hl	ix iy -	check for residue
	LD	A,(DE)
	CALL	OPRTOR		;check for expression operator
	JR	NZ,OPRN85	;no operator but not end of operand
	LD	A,RIX OR RIY	;special ix iy hl processing
	AND	C		;test for index	reg
	JR	Z,OPRN35	;z - must be hl
	AND	10H		;transform index into 0ddh or ofdh
	ADD	A,A
	ADD	A,0DDH		;a - first byte	of index reg opcode
OPRN35:	LD	C,A		;temp save first object	byte
	LD	HL,OBJBUF
	XOR	(HL)
	JR	Z,OPRN40	;z - first operand matches second
	CP	C
	RET	NZ		;illegal ix iy hl combination
	LD	A,(OPRN01)
	AND	A		;test if index reg was first operand
	JR	NZ,OPRN40
	DEC	A		;error - hl illegal as second
	RET


OPRN40:	LD	(HL),C		;init first byte of object code
	LD	A,(PRSBF)
	AND	A		;check for previously removed parens
	LD	A,C
	LD	C,0
	JR	NZ,OPRN80	;no parens - no	indexed	displacement
	AND	A		;check for ix or iy indexed instruction
	JR	Z,OPRN80	;z - not index reg instruction

	SBC	HL,HL		;clear hl
	LD	A,(DE)		;index reg displacement	processing
	AND	A		;test for default displacement
	CALL	NZ,XVAL		;not zero - evaluate
	JR	NZ,OPRN85	;nz - displacement in error
	LD	C,00
	LD	A,L
	LD	(OBJBUF+2),A	;displacement always third byte
	INC	H		;check upper byte of index value
	JR	Z,OPRN50	;must have been	0ffh
	DEC	H
	RET	NZ		;error - index not -128	to +127
	CPL
OPRN50:	XOR	80H		;check sign bit
	RET	M		;bit on	- index	out of range
	CP	A		;no error - set	zero flag
	RET
OPRN70:	DEC	C		;decrement reserved operand table index
	JP	M,OPRN85	;m - not a reserved operand
	DEC	DE		;rewind	parse buffer pointer
	JP	OPRN20		;next table entry
OPRN80:	LD	A,(DE)		;check for end of parse	buffer
	AND	A
	RET	Z		;found end of line null
OPRN85:	LD	DE,PRSBF	;rewind	to start of input
	XOR	A
	OR	B
	RET	NZ		;nz - this was mreg calling
	SBC	HL,HL		;clear hl
	CALL	XVAL		;evaluate operand
	LD	C,17H		;assume	numeric	operand	found
	RET


XVAL:	LD	A,(DE)		;check first char of parse buffer
	AND	A
	JR	NZ,XVAL00
	INC	DE		;bump past previously removed paren
XVAL00:	LD	(MEXP),HL	;init expression accumulator
	XOR	A
	LD	(BASE10),A	;clear upper digit decimal accumulator
	SBC	HL,HL		;clear hl
	LD	(FNDSYM),HL	;clear symbol found flag
	LD	(PASS2),HL
XVAL05:	LD	A,(DE)		;char from parse buffer
	CALL	IXLT		;translate to upper case
	LD	C,A		;save character
	INC	DE		;bump parse buffer pointer
	CP	'0'		;check for valid ascii hex digit
	JR	C,XVAL25
	CP	':'
	JR	C,XVAL15
	CP	'A'
	JR	C,XVAL25
	CP	'G'
	JR	NC,XVAL25
	XOR	A		;check number entered flag (b reg sign bit)
	OR	B
	JP	M,XVAL10	;m - this was not first	char
	LD	A,(SYMFLG)	;check if symbol table present in memory
	AND	A
XVAL10:	LD	A,C		;input character back to accumulator
	JP	P,XVAL25	;p - have symbol table or invalid hex digit
	SUB	7
XVAL15:	SUB	'0'		;ascii hex to hex nibble
	ADD	A,A		;shift left five - hi bit of nibble to carry
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	C,4		;loop count
XVAL20:	ADC	HL,HL		;hl left into carry - rotate carry into	hl
	ADC	A,A		;next bit of nibble into carry
	DEC	C
	JR	NZ,XVAL20
	LD	(BASE10),A	;store what was	shifted	left out of hl
	LD	A,80H		;set sign of b - number	entered	flag
	OR	B
	LD	B,A
	JR	XVAL05		;next character

XVAL25:	CALL	OPRTOR		;have expression operator?
	JR	Z,XVAL30
	LD	A,(PASS2)
	AND	A
	RET	NZ
	LD	A,(PASS2+1)
	AND	A
	JP	Z,XVAL35
	RET

XVAL30:	XOR	A
	OR	B		;check number entered flag
	LD	A,C		;restore unmodified input character to a
	JP	NZ,XVAL90	;nz - take care	of previous operator
	AND	A		;end of	line null?
	RET	Z		;
	LD	B,C		;this operator was first char of parse buffer
	JR	XVAL05		;extract what follows this leading operator

XVAL35:	LD	A,C		;recover character
	CP	'#'		;decimal processing?
	JR	NZ,XVAL50	;nz - not decimal
	LD	A,B		;check number entered flag
	XOR	80H		;toggle
	RET	M		;error - pound sign with no number
	LD	B,A
	PUSH	BC
	PUSH	DE
	EX	DE,HL		;save hex number in de
	LD	HL,BASE10
	LD	A,6
	CP	(HL)		;check ten thousands digit
	JR	C,XVAL40	;error - obviously greater than	65535
	RRD			;nibble	to accumulator
 	INC	HL
	LD	(HL),D		;store hex number in temp buffer
	INC	HL
	LD	(HL),E		;lo order hex number
	DEC	HL		;point back to upper byte
	LD	E,A
	XOR	A
	LD	D,A		;de - hex nibble
	CALL	BCDX		;convert hi order byte
	JR	NZ,XVAL40	;nz - error detected during conversion
	INC	HL		;bump to lo byte to convert
	CALL	BCDX
	EX	DE,HL		;hl - converted	value
XVAL40:	POP	DE
	POP	BC
	JR	Z,XVAL65	;z - no	errors detected
	RET



XVAL50:	CP	QUOTE		;ascii literal processing
	JR	NZ,XVAL60	;nz - not quote
	EX	DE,HL		;
	LD	E,(HL)		;fetch literal from buffer
	INC	HL
	CP	(HL)		;trailing quote	found?
	JR	Z,XVAL55	;found
	LD	D,E		;make literal just fetch hi order of operand
	LD	E,(HL)		;fetch new literal as lo order
	INC	HL
	CP	(HL)		;trailing quote?
	RET	NZ		;error - more than two chars between quotes
XVAL55:	EX	DE,HL		;de - parse buffer ptr	 hl - operand
	INC	DE		;bump past trailing quote
	JR	XVAL65


XVAL60:	DEC	DE		;point to start	of operand in parse buffer
	LD	(PASS2),DE
	CALL	FSYM		;search	symbol table
	JP	Z,XVAL62	;symbol	found
	LD	A,(DE)
	INC	DE
	CP	'$'		;check for pc relative expression
	JP	NZ,XVAL61
	LD	HL,(ASMBPC)	;current location value	is expression value
	JR	XVAL65
				;symbol not found - retry evaluation process
				;with pass2 flag set.  now token must be a
				;valid hex digit or error
XVAL61:	LD	DE,(PASS2)
	LD	A,B
	OR	80H		;set sign in b - valid digit detected which
				;tells xval this must be hex number
	LD	B,A
	SBC	HL,HL		;clear hex number accumulator
	JP	XVAL05
XVAL62:	LD	A,(MAXLEN)	;point to last byte of sym table entry
	OR	L
	LD	L,A
	LD	A,(HL)		;hi order symbol address
	DEC	HL
	LD	L,(HL)		;lo order
	LD	H,A
XVAL65:	LD	A,B		;check number entered flag
	AND	A
	RET	M		;error - numbers entered previous to symbol
	XOR	80H		;toggle	flag
	LD	B,A
	LD	A,(DE)		;check char following symbol name in buffer
	LD	C,A		;make it new current character
	INC	DE
	JP	XVAL30

XVAL90:	LD	C,A		;temp save operator
	LD	A,80H		;toggle	number entered flag
	XOR	B
	RET	M		;return	nz - consecutive operators
	LD	B,C		;new on	deck operator
	CP	'-'		;test last operator
	PUSH	DE		;save buffer pointer
	JR	NZ,XVAL95	;nz - addition
	EX	DE,HL
	SBC	HL,HL		;clear
	SBC	HL,DE		;force current value neg by subtraction from 0
XVAL95:	EX	DE,HL
	LD	HL,(MEXP)	;fetch accumulated operand total
	ADD	HL,DE		;add in	current
	POP	DE		;restore buffer	pointer
	LD	A,B		;check operator	that got us here
	AND	A		;end of	line null?
	JP	NZ,XVAL00	;no -
	RET			;operand processing complete



FSYM:
	LD	HL,(BDOSAD)	;de - buffer   hl - symbol table
FSYM00:	LD	A,(MAXLEN)
	AND	L
	LD	C,A
	LD	A,B		;temp save
	LD	B,0
	EX	DE,HL		;de - symbol table ptr	hl - parse buffer
	SBC	HL,BC		;rewind	parse buffer to	start of symbol
	EX	DE,HL		;de - parse buffer  hl - symbol	table pointer
	LD	B,A		;restore b reg
	LD	A,(MAXLEN)
	OR	L
	LD	L,A
	INC	HL		;next block of symbol table
	LD	A,(HL)		;first character of symbol name
	DEC	A
	RET	M		;end of	table
	LD	A,(MAXLEN)
	DEC	A
	LD	C,A		;chars per symbol
FSYM10:	LD	A,(DE)		;fetch char from buffer
	CALL	OPRTOR
	JR	NZ,FSYM20	;nz - not operator or end of line null
	LD	A,(HL)
	AND	A		;null means end	of symbol name in symbol table
	JR	NZ,FSYM00
	LD	(FNDSYM),HL	;set symbol found flag nz -
	RET
FSYM20:	CP	(HL)
	JR	NZ,FSYM00
	INC	HL
	INC	DE
	DEC	C
	JR	NZ,FSYM10
	LD	(FNDSYM),HL	;set symbol found flag nz -
FSYM30:	LD	A,(DE)
	CALL	OPRTOR
	RET	Z
	INC	DE
	JR	FSYM30



ISYM:	CALL	FSYM		;search	for symbol in table
	JR	Z,ISYM00	;z - symbol found
	LD	A,(HL)		;test for empty	slot in	table
	AND	A
	RET	NZ		;symbol	table full
	LD	(SYMFLG),A	;indicate non-empty symbol table
ISYM00:	LD	A,(MAXLEN)	;rewind	point to start of table	entry
	LD	C,A
	CPL
	AND	L
	LD	L,A
	EX	DE,HL		;de - pointer to start of symbol
	LD	HL,PRSBF
	LD	B,0		;move symbol from parse	buffer to table
	DEC	C
	LDIR
	LD	HL,(ASMBPC)	;fetch value of	symbol
	EX	DE,HL		;hl - pointer to address storage
	LD	(HL),E		;lo order current location into	table
	INC	HL
	LD	(HL),D		;upper byte
	XOR	A
	RET

;******************************************************************************
;*
;*	prsr:	command	line parse routine
;*
;*	prsr will extract one argument from the	input buffer (inbf) and
;*	write it into the parse	buffer (prsbf).	an argument is treated
;*	as starting with the first non-delimeter character encountered
;*	in the input buffer and ends with the next delimeter found.
;*	all intervening	characters between the two delimeters are
;*	treated	as the argument	and are	moved to prsbf.
;*
;*	as each character is extracted from inbf a zero is written back
;*	to replace it.  thus a program which needs to extract multiple args
;*	need not save pointers in between calls	since prsr is trained
;*	to strip leading delimeters while looking for the start	of an
;*	argument:
;*
;*	     delimeters: null, space, comma
;*
;*	exit:	    de - starting address of parse buffer
;*		     b - sign bit: set if unbalanced parens, else sign reset
;*			 bits 6-0: number of chars in the parse	buffer
;*		     a - actual	delimter char which caused to terminate
;*		     f - zero flag set if no error
;*		quoflg - set equal to ascii quote if at	leeat one quote	found
;*
;*	error exit:  f - zero flag reset
;*
;******************************************************************************

PRSR:	XOR	A
	LD	(QUOFLG),A	;clear quote flag
	LD	HL,PRSBF	;start of parser scratch buffer
	LD	B,PRSBFZ	;buffer	size
	LD	C,B
PRSR10:	LD	(HL),0		;clear parse buffer to nulls
	INC	HL
	DJNZ	PRSR10
	LD	HL,PRSBF	;start of parse	buffer
	LD	DE,INBF		;start of input	buffer
	LD	C,INBFL		;max size of input buffer
PRSR20:	LD	A,(DE)		;from input buffer
	EX	DE,HL
	LD	(HL),0		;erase as we pick from input buffer
	EX	DE,HL
	DEC	C		;decrement buffer size tally
	RET	M		;error -  end of input buffer reached
	INC	DE		;bump input buffer pointer
	CALL	ZDLM00		;check for delimeter
	JR	Z,PRSR20	;delimeter found - continue search
	LD	(PARENF),A
	LD	C,NPRSBF-PRSBF	;parse buffer size
PRSR30:	LD	(HL),A
	AND	A
	JR	Z,PRSR60	;end of	line null always ends parse
	CP	QUOTE		;quote?
	JR	NZ,PRSR50
	LD	(QUOFLG),A
	LD	A,B		;quote found - toggle flag
	XOR	80H
	LD	B,A
PRSR50:	DEC	C		;decrement buffer size tally
	RET	M		;error - end of	parse buffer reached
	LD	A,(DE)		;next char from	input buffer
	EX	DE,HL
	LD	(HL),0		;clear as we remove
	EX	DE,HL
	INC	DE
	INC	B		;bumping character count tests quote flag
	CALL	P,ZDLM		;only look for delimeters if quote flag off
	INC	HL		;bump parse buffer pointer
	JR	NZ,PRSR30
	DEC	HL
PRSR60:	LD	DE,PRSBF	;return	pointing to start of parse buffer
	LD	(DELIM),A
	RET			;zero flag set - no errors



ASMXXL:	LD	A,'L'
	JR	ASMXXX
ASMXXO:	LD	A,'O'
	JR	ASMXXX
ASMXXP:	LD	A,'P'
	JR	ASMXXX
ASMXXS:	LD	A,'S'
	JR	ASMXXX
ASMXXT:	LD	A,'T'
	JR	ASMXXX
ASMXXV:	LD	A,'V'

ASMXXX:	LD	(ASMFLG),A
	CALL	CRET
	LD	HL,(ASMBPC)
	CALL	OUTADR
	LD	DE,MXXXX
	CALL	PRINT
	JP	ASM010


ZDLM:	CP	','
	RET	Z
ZDLM00:	AND	A
	RET	Z
	CP	TAB
	RET	Z
	CP	' '
	RET

OPRTOR: CP	'+'
	RET	Z
	CP	'-'
	RET	Z
	AND	A
	RET



OPNV:	EX	DE,HL		;de - operand value  hl	- operand key storage
	LD	A,(PRSBF)	;check first byte of parse buffer
	AND	A		;if null - paren was removed
	LD	A,C		;key value to accumulator
	JR	NZ,OPNV00	;nz - no paren
	OR	80H		;found null - set paren	flag
OPNV00:	LD	(HL),A		;store key value
	INC	HL
	LD	(HL),E		;lo order operand value
	INC	HL
	LD	(HL),D		;hi order
	RET



;******************************************************************************
;*
;*	zlen:  determine the number of bytes in	a z80 instruction
;*
;*
;*	entry point zlen00: used to return instruction length.
;*
;*			    de:	 address of instruction
;*
;*	return:	 b:  z - inline	instruction (next pc will be pc	plus length)
;*		    nz - pc modifying instruction such as call,	 jump, or ret
;*			 (see hl below)
;*		 c:	 number	of bytes in this instruction.
;*		de:	 preserved
;*		hl:	 next pc following the execution of the	instruction
;*			 pointed to by de.
;*
;******************************************************************************

ZLEN00:	LD	A,(DE)		;fetch first byte of op	code
	CP	0CBH		;test for shift/bit manipulation instruction
	LD	BC,02
	RET	Z		;10-4 this is a	cb and length is always	2
	CP	0EDH		;test for fast eddie
	JR	NZ,ZLEN15	;
	INC	DE		;fetch byte two	of ed instruction
	LD	A,(DE)
	DEC	DE		;restore pointer
	LD	HL,Z80ED	;ed four byter table
	LD	C,Z80EDL	;length
	CPIR
	LD	C,4		;assume	ed four	byter
	RET	Z		;correct assumption
	LD	C,2		;set length for	return - if not	2 must be 4
	CP	45H		;test for retn
	JR	Z,ZLEN10
	CP	4DH		;test for reti
	RET	NZ		;non-pc	modifying two byte ed
ZLEN10:	LD	A,0C9H		;treat as ordinary return instruction
	JP	ZLEN80
ZLEN15:	CP	0DDH		;check for dd and fd index reg instructions
	JR	Z,ZLEN20
	CP	0FDH
	JR	NZ,ZLEN40
ZLEN20:	INC	DE		;fetch byte two	of index reg instruction
	LD	A,(DE)
	DEC	DE		;restore pointer
	CP	0E9H		;check for reg indirect	jump
	JR	NZ,ZLEN30	;
	INC	B		;reg indirect jump - set pc modified flag nz
	LD	A,(DE)		;recheck for ix	or iy
	LD	HL,(IXREG)	;assume	ix
	CP	0DDH
	RET	Z		;correct assumption
	LD	HL,(IYREG)
	RET
ZLEN30:	LD	HL,Z80FD	;check for dd or fd two	byter
	LD	C,Z80FDL
	CPIR
	LD	C,2		;assume	two
	RET	Z
	LD	HL,Z80F4	;not two - try four
	LD	C,Z80F4L
	CPIR
	LD	C,4		;assume	four
	RET	Z		;correct assumption
	DEC	C		;must be three
	RET
ZLEN40:	AND	0C7H		;check for 8 bit immediate load
	CP	06
	LD	C,2		;assume	so
	RET	Z
	DEC	C		;assume	one byte op code
	LD	A,(DE)
	CP	3FH
	JR	C,ZLEN50	;opcodes 0 - 3f	require	further	investigation
	CP	0C0H		;8 bit reg-reg loads and arithmetics do	not
	RET	C
ZLEN50:	LD	HL,Z803		;check for three byter
	LD	C,Z803L
	CPIR
	JR	NZ,ZLEN60	;nz - not three
	LD	HL,Z803S	;established three byter - test conditional
	LD	C,Z803CL
	CPIR
	LD	C,3		;set length
	RET	NZ		;nz - three byte inline	instruction
	LD	HL,Z803S
	LD	C,Z803SL	;now weed out jumps from calls
	CPIR
	LD	C,3
	LD	B,C		;set pc	modified flag -	we have	call or	jump
	EX	DE,HL
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)		;de - address from instruction
	EX	DE,HL
	DEC	DE
	DEC	DE		;restore instruction pointer
	JR	Z,ZLEN55	;z - this is a call
	CP	IJP		;test for unconditional jump
	JR	NZ,ZLEN85
	RET
ZLEN55:	LD	A,(WFLAG)	;test for no subroutine	trace flag
	AND	A		;zero means no sub tracing
	LD	B,A		;clear for return - if sub trace off
	RET	Z		;subroutine trace off -	return with b reg 00
				;so bp is set at next inline instruction
	DEC	B
	JR	NZ,ZLEN58
	LD	A,B
	OR	H
	RET	Z
ZLEN58:	LD	A,(DE)		;recover call object byte
	LD	B,C		;set nz	- pc modifying instruction
	CP	0CDH		;unconditional call??
	JR	NZ,ZLEN85	;zlen85	- set secondary	breakpoint if tracing
	RET

ZLEN60:	LD	HL,Z802
	LD	C,Z802L		;test for two byter
	CPIR
	JR	NZ,ZLEN70	;not two
	LD	HL,Z802C	;test for relative jump
	LD	C,Z802CL
	CPIR
	LD	C,2		;in any	case length is two
	RET	NZ		;nz - not relative jump
	LD	H,B		;clear
	INC	B		;set pc	modified flag nz
	INC	DE		;fetch relative	displacement
	LD	A,(DE)
	LD	L,A
	ADD	A,A		;test forward or backward
	JR	NC,ZLEN65	;p - forward
	DEC	H		;set hl	negative
ZLEN65:	ADD	HL,DE		;compute distance from instruction
	INC	HL		;adjust	for built in bias
	DEC	DE		;restore pointer
	LD	A,(DE)		;fetch first byte of instruction
	CP	18H		;uncondtional jump?
	JR	NZ,ZLEN85	;conditional - set secondary bp	if tracing
	RET
ZLEN70:	LD	HL,Z801		;check for return instruction
	LD	C,Z801L
	CPIR
	LD	C,1		;length	must be	1 in any case
	RET	NZ
	CP	0E9H
	JR	NZ,ZLEN80	;nz - not  jp (hl)
	INC	B		;set pc	modified flag
	LD	HL,(HLREG)	;next pc contained in hlreg
	RET
ZLEN80:	LD	HL,(SPREG)	;return	instructions hide next pc in stack
	LD	B,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,B		;hl - return address removed from stack
	LD	B,C		;set b nz - pc modification flag
	CP	0C9H
	RET	Z		;unconditional return
ZLEN85:	LD	A,(SBPS)	;count of special step breakpoints
	AND	A		;test for zero
	RET	Z		;zero -	monitor	is not tracing
	LD	A,(BPS)		;fetch number of bps currently in effect
	LD	B,A		;pass to set breakpoint	routine	in b reg
	EX	DE,HL		;de - bp to set
	CALL	BRK30		;set conditional breakpoint
	XOR	A
	OR	B
	LD	B,0
	LD	DE,(PCREG)	;for setting inline bp - condition not m
	RET	NZ		;nz - collision	with user bp
	LD	HL,SBPS
	INC	(HL)		;bump count of step bps
	RET

;******************************************************************************
;*
;*	pswDsp:	display	current	state of flag register
;*
;*	pswbit:	table of bit masks with	which to test f	reg.
;*		two byte entry per bit (sign, zero, carry, parity).
;*
;*	pswmap - table of offsets into operand name table featuring a
;*		 two byte entry	for each flag bit.
;*		 bit 4 (unused by z80) from pswbit entry is on/off flag
;*		 lo bytes are the off states (p	nz nc po).
;*		 hi bytes are the on states  (m	 z  c pe).
;*
;*	- current state	of flag	register is displayed
;*	- user queried for changes
;*	- input	is parsed and tested for valid flag reg	mnemonics
;*	- if valid mnemonic found flag bit is set or reset accordingly
;*
;*	exit:	to z8e for next	command
;*
;******************************************************************************

PSWDSP:	LD	DE,3
	LD	B,0			;+ eg 3.3.5a
PSW00:	LD	HL,PSWBIT		;table of bit mask for flags
	ADD	HL,DE			;
	ADD	HL,DE			;index times two
	LD	A,E
	NEG				;now calculate index into pswmap
	ADD	A,3
	ADD	A,A
	LD	C,A
	LD	A,(FREG)		;fetch current flag of user
	AND	0F7H
	AND	(HL)			;unused	bit in flag - ensure it's off
	LD	HL,PSWMAP
	ADD	HL,BC			;pointer to mnemonic is	8 bytes	away
	JR	Z,PSW10			;this is an off	bit (nz	nc p po)
	INC	HL			;on
PSW10:	LD	C,(HL)			;fetch index into operand name table
	LD	HL,ZOPNM
	ADD	HL,BC			;two bytes per table entry
	ADD	HL,BC
	LD	C,2			;print both chars of mnemonic name
	CALL	PRINTB
	CALL	RSPACE
	DEC	E			;do all	four flag bits
	JP	P,PSW00
	CALL	CRLF
	LD	A,(LCMD)

;	cp	'J'			;- eg 3.3.5a
;	ret	z			;-
	CP	'P'			;+ Routine can now be called from
	RET	NZ			;+  elsewhere

	CALL	SPACE5
PSW50:	CALL	IEDTBC
	RET	M			;no input
PSW55:	CALL	PRSR
	RET	NZ			;parse error - end command
	LD	BC,116H			;
	CALL	OPRN20			;check validity	of this	token
	LD	A,C
	LD	BC,PSWCNT		;number	of flag	reg mnemonics
	LD	HL,PSWMAP
	CPIR				;check table
	JP	NZ,EXXX			;error - nmemonic not found
	LD	HL,PSWBIT		;bit mask table
	ADD	HL,BC
	LD	A,(HL)			;fetch mask
	EX	DE,HL			;
	LD	HL,FREG			;de - mask ptr	 hl - user flag	ptr
	AND	08			;bit says turn on or off
	LD	A,(DE)			;new copy of mask
	JR	NZ,PSW60		;nz - turn on
	CPL
	AND	(HL)			;and with current user flag
	LD	(HL),A			;return	flag reg with bit now off
	JR	PSW55			;check for more	input
PSW60:	AND	0F7H			;turn off on/off flag (bit 4)
	OR	(HL)
	LD	(HL),A			;now turn on specified bit
	JR	PSW55

;******************************************************************************
;*
;*	movb:	move memory
;*
;*	call bcde to fetch destination block address and byte count
;*	call prsr
;*	check for head to head or tail to tail move
;*
;*	exit: to z8e for next command
;*
;******************************************************************************

MOVB:	CALL	BCDE		;bc - byte count  de - destination  hl - source
	JP	NZ,EXXX		;input error ends command
	XOR	A
	SBC	HL,DE
	ADC	A,A
	ADD	HL,DE
	ADD	HL,BC
	DEC	HL
	EX		DE,HL		;de - address of last byte of source block
	SBC	HL,DE
	ADC	A,A
	ADD	HL,DE		;hl - original destination address
	EX	DE,HL
	CP	3
	JR	NZ,MOVB00	;head to head
	EX	DE,HL
	ADD	HL,BC
	DEC	HL
	EX	DE,HL
	LDDR
	RET
MOVB00:	INC	HL
	AND	A
	SBC	HL,BC
	LDIR
	RET

;******************************************************************************
;*
;*	yfil:	fill memory
;*
;*	call bcde to get byte count, starting address, and fill byte
;*
;*	exit:	to z8e for next	command
;*
;******************************************************************************

YFIL:	CALL	BCDE		;bc - byte count  de - fill byte  hl - block
	JP	NZ,EXXX		;input error ends command
	EX	DE,HL
YFIL00:	LD	HL,ARGBF
	LD	A,(ARGBC)
YFIL10:	LDI
	INC	B
	DJNZ	YFIL20
	INC	C
	DEC	C
	RET	Z
YFIL20:	DEC	A
	JR	NZ,YFIL10
	JR	YFIL00

;
CUSER:	RET

;*******************************************************************
;
;	QEVAL - expression evaluator	EG 10 Jan 88
;
;	Uses '?' as command
;
;*******************************************************************
QEVAL: 	CALL 	IEDTBC		; get input
	RET		M		; none
	CALL		IARG		; Z8E does all the real work
	JP		NZ,EXXX		; check for valid arg
	CALL		CRLF
	LD		A,H		; see if 1 byte
	OR		A
	JR		NZ,QEV01	; 2-byte number
	LD		A,L
	CALL		OUTHEX		; hex byte
	LD		A,L
	CP		7FH		; see if printable
	RET		NC
	CP		' '
	RET		C
	LD		C,3
	CALL		SPACES		; even up with spaces
	LD		A,27H		; quote
	CALL		TTYO
	LD		A,L		; show char
	CALL		TTYO
	LD		A,27H
	JP		TTYO
QEV01:	JP 	OUTADR		; output 2-byte result


IFCB:	RET				;(Condensed, improved version - jrs 27 Dec 88)


DISISR:	PUSH	AF
	LD 	A,IRT
	LD	(RSTVEC),A
	POP	AF
	RET

ENAISR:	PUSH	AF
	LD 	A,IJP
	LD	(RSTVEC),A
	POP	AF
	RET


LLDR:	RET
WRIT:	RET


;******************************************************************************
;*
;*	find:	locate string in memory
;*
;*		call iarg - get	starting address of seach
;*
;*		call in00 - get	match data concatenating multiple arguments
;*			    into a single string
;*
;*		addresses at which matches found displayed 8 per line.
;*		search continues until end of memory reached
;*		user may cancel	search at any time by hitting any key.
;*
;*		exit: to z8e for next command
;*
;******************************************************************************

FIND:	CALL	IEDTBC
	RET	M		;m - no	input
	CALL	IARG		;extract starting address of search
	JP	NZ,EXXX		;error
	EX	DE,HL		;save starting address of search in de
FIND00:	CALL	IN00		;extract search	string concatenating multiple
				;arguments
	JP	NZ,EXXX		;error - output	command	prompt
	XOR	A
	LD	(LINES),A	;clear crlf flag
	EX	DE,HL		;starting address of search - hl
	LD	DE,ARGBF	;argument stored here

	LD	BC,(FNDSYM)
	LD	A,C
	OR	B		;symbol found?
	JP	Z,FIND40	;no

	EX	DE,HL		;hl - argument buffer
	LD	B,(HL)		;reverse order of the two bytes for symbols
	INC	HL
	LD	A,(HL)
	LD	(HL),B
	DEC	HL
	LD	(HL),A
	EX	DE,HL

FIND40:	LD	BC,(ARGBC)	;number	of bytes to look for
	CALL	CRLF
FIND50:	CALL	SRCH		;do the	search
	JR	NZ,FIND60	;not found
	CALL	OUTADR		;display address where match found
	LD	A,(LINES)
	DEC	A		;carriage return after 8 addresses displayed
	LD	(LINES),A
	AND	7
	CALL	Z,CRLF
	CALL	TTYQ		;user requesting abort?
	CP	CR
	RET	Z		;abort - return	to z8e
FIND60:	INC	HL		;point to next address at which	to start search
	ADD	HL,BC		;ensure	we won't hit end of memory by adding
				;in string size
	RET	C		;impending end of memory
	SBC	HL,BC		;restore pointer
	JR	FIND50

SRCH:	PUSH	BC
	PUSH	DE
	PUSH	HL
SRCH00:	LD	A,(DE)
	CPI
	JP	NZ,SRCH10	;no match
	INC	DE
	JP	PE,SRCH00	;tally not expired - check next
SRCH10:	POP	HL
	POP	DE
	POP	BC
	RET

;******************************************************************************
;*
;*	verify:	verify two blocks of data are identical
;*
;*		enter: de - starting address of	block 1
;*
;*		call bcde to get address of block 2 and	byte count
;*
;*		mismatch:   block 1 address and	byte are displayed
;*			    block 2 address and	byte are displayed
;*			    console intrrogated	- any input terminates verify
;*
;*		exit:	to z8e for next	command
;*
;******************************************************************************

VERIFY:	CALL	BCDE		;get block 2 address and byte count
	JP	NZ,EXXX
	EX	DE,HL
VERF00:	LD	A,(DE)		;byte from block 1
	XOR	(HL)		;versus	byte from block	two
	JR	Z,VERF10	;match - no display
	CALL	NEWLIN
	LD	A,(DE)
	CALL	OTHXSP		;display block 1 data
	CALL	RSPACE
	CALL	OUTADR		;display block two address
	LD	A,(HL)
	CALL	OUTHEX		;display results of xor
	CALL	TTYQ		;check input status
	CP	CR
	RET	Z
VERF10:	INC	HL		;bump block 1 pointer
	INC	DE		;bump block 2 pointer
	DEC	BC		;dec byte count
	LD	A,B
	OR	C
	JR	NZ,VERF00
	RET

;******************************************************************************
;*
;*	xreg:	display	machine	state
;*
;*		regptr:	table contains offsets to names	in operand name	table.
;*			sign bit set indicates prime register.
;*
;*		regmap:	table contains offsets to reg contents table (regcon)
;*			sign bit ignored (used by rgst command).
;*
;*		regcon:	table of register contents.
;*
;*		exit:	make current pc	current	disassembly location counter.
;*			set bit	6 of disassembly flag byte (zasmfb)
;*			jump to	zasm30 to disassemble current instruction.
;*
;******************************************************************************

XREG:	CALL	CRET
	LD	BC,0		;init reg index
XREG00:	CALL	XREG05		;display reg name and contents
	INC	C
	LD	A,C
	CP	8
	CALL	Z,CRLF
	LD	A,C
	CP	0CH
	LD	B,0
	JR	NZ,XREG00
	LD	A,(LCMD)
	CP	'J'		;animated command in effect?
	RET	Z		;z - no disassembly required
	LD	HL,(PCREG)
	LD	(ZASMPC),HL
;	jp	zasm30		;- eg 3.3.5b
	CALL	ZASM30		;+
	JP	PSWDSP		;+

XREG05:	LD	HL,REGPTR	;map of	reg name pointers
	LD	D,B
	ADD	HL,BC
	LD	A,(HL)		;extract pointer
	AND	7FH		;strip sign for	name indexing
	LD	E,A
	LD	B,(HL)		;save copy of offset - need sign later
	LD	HL,ZOPNM	;register name table
	ADD	HL,DE
	ADD	HL,DE		;two bytes per entry
	LD	A,(HL)
	CALL	TTYO		;display character one
	INC	HL
	LD	A,(HL)
	CP	' '		;is second character a space?
	JR	NZ,XREG10
	LD	A,'C'		;replace space - this is pc
XREG10:	CALL	TTYO		;display second	character
	XOR	A
	OR	B		;now test sign
	JP	P,XREG20	;sign not set -	not prime reg
	LD	A,27H		;display quote
	CALL	TTYO
XREG20:	LD	A,':'
	CALL	TTYO
	LD	HL,REGMAP	;map of	pointers to reg	contents
	ADD	HL,DE
	LD	A,(HL)
	JP	P,XREG30	;p - not prime reg
	ADD	A,8		;prime contents	8 bytes	past non-prime
XREG30:	AND	7FH		;ignore	sign
	LD	E,A
	LD	HL,REGCON	;start of register contents storage
	ADD	HL,DE
	LD	D,(HL)		;hi order contents
	DEC	HL
	LD	E,(HL)
	EX	DE,HL
	CALL	OUTADR		;display contents
	RET


;******************************************************************************
;*
;*	zasm
;*
;*	the disassembler is divided into two routines:
;*
;*	zasm - computes	the instruction	key value and finds the	opcode nmemonic
;*	opn  - uses the	key value to determine the number of operands and
;*	       displays	the operands.
;*
;*	entered: de - starting address to disassemble
;*
;*		zasm maps the 695 z80 instrucions into 256 key values.
;*              the instruction key value becomes the index into the
;*              opcode name pointer table (zopcnm), the first operand table
;*		(zopnd1), and the second operand table (zopnd2).
;*
;*		disassembly is done in user specified block sizes if the
;*		disassembly count evaluates to a number	between	1 and 255. if
;*		the count is greater than 255 the block	is disassembled	and the
;*		the command terminates.
;*
;*
;*		zasm15 - start of the disassembly loop
;*		zasmpc - address of the	instruction being disassembled
;*		zasmfb - disassembly flag byte
;*		zmflag - flag indicating directive processing (defb and	defw)
;*
;*			    bit	6 - xreg calling
;*			    bit	5 - asmblr calling
;*			    bit	0 - write to disk flag
;*
;*
;*
;******************************************************************************


ZASM:
	CALL	IEDTBC

;	ret	m		;- eg 3.3.2
	JP	P,ZASM0		;+ Skip if arguments supplied, otherwise ...
	LD	B,0		;+ Signal no file write
	LD	HL,16		;+ Assume 16 lines of code
	LD	(ZASMWT),HL	;+
	LD	(ZASMCT),HL	;+
	JR	ZASM06		;+
ZASM0:				;+
	CALL	IARG
	JP	NZ,EXXX
	EX	DE,HL
	CALL	IARG		;read in block size
	LD	B,A		;save delimeter
	JR	Z,ZASM00
	LD	HL,1		;change	zero count to one
ZASM00:	XOR	A
	OR	H
	JR	Z,ZASM05
	SBC	HL,DE
	JP	C,EXXX		;error - start address greater than end
	ADD	HL,DE
ZASM05:	LD	(ZASMCT),HL	;save as permanent block count
	LD	(ZASMWT),HL	;save as working tally
	EX	DE,HL		;hl - current instruction pointer
	LD	(ZASMPC),HL
ZASM06:				;+ eg 3.3.2
	CALL	CRLF
; 	LD	A,B		;check command line delimeter
; 	LD	(DWRITE),A	;save as write to disk flag:
				;z - no write   nz - write
; 	AND	A
; 	CALL	NZ,BLDF		;not end of line - build fcb
; 	JP	NZ,ESNTX
	XOR	A

ZASM08:	LD	DE,ZASMBF	;start of disassembly buffer

ZASM10:	LD	(ZASMIO),DE	;init pointer

ZASM15:	LD	DE,(ZASMPC)	;fetch address to disassemble
	CALL	ZLEN00		;calculate length
	EX	DE,HL

				;loop back here for interactive disassembly -
				;user requests format change. c reg:
				;     6 and 7 off: disassemble as code
				;     6       on:  hex defb
				;     7       on:  hex defw or ascii defb

ZASM18:	CALL	OUTADR		;display instruction address
	LD	DE,ZMFLAG
	LD	A,C		;save instruction length and format bits
	LD	(DE),A
	AND	3FH
	LD	B,A		;b  - length
	LD	C,A		;c  - ditto
ZASM20:	LD	A,(HL)
	CALL	OTHXSP		;display object	code
	INC	HL
	DJNZ	ZASM20
	LD	A,C		;number	of object bytes
	DEC	A
	XOR	3
	LD	B,A		;calculate space padding
	ADD	A,A
	ADD	A,B
	ADD	A,2
	LD	B,A
ZASM25:	CALL	RSPACE
	DJNZ	ZASM25
	LD	(ZASMNX),HL	;store address of next instruction
	AND	A		;clear carry
	SBC	HL,BC		;point to first	byte in	instruction
ZASM30:	EX	DE,HL		;de - current instruction pointer
	LD	HL,(ZASMIO)	;buffer	address	storage
	LD	A,(MAXLIN)
	LD	B,A		;line length based on max symbol size
ZASM35:	LD	(HL),' '	;space out buffer
	INC	HL
	DJNZ	ZASM35
	LD	A,B
	LD	(OPNFLG),A
	LD	(HL),CR		;append	crlf
	INC	HL
	LD	(HL),LF
	CALL	FADR		;find address match
	LD	HL,(ZASMIO)
	JR	NZ,ZASM40	;nz - no table or not found
	CALL	XSYM
	LD	(HL),':'
	LD	DE,(ZASMPC)
ZASM40:	LD	HL,ZMFLAG	;check interactive disassembly flag
	LD	A,(HL)		;sign bit tells all
	AND	A
	JP	P,ZASM42	;bit off - not interactive
	LD	B,6DH		;test for defb
	SUB	82H
	JR	Z,ZASM90
	XOR	A		;must be defw
	DEC	B
	JR	ZASM90
ZASM42:	LD	A,(DE)		;first byte of op code
	LD	HL,OP1000	;table of z80 specific opcodes
	LD	C,4
ZASM45:	CPIR			;check for fd dd ed or cb
	JR	Z,ZASM55	;z - found
ZASM50:	CP	40H
	JR	C,ZASM90	;opcode	range 0	- 3f
	LD	B,0E0H		;
	CP	0C0H		;
	JR	NC,ZASM90	;opcode	range c0 - ff
	CP	80H
	JR	NC,ZASM85	;opcode	range 80 - bf
	LD	B,0F8H		;
	CP	76H		;test for halt instruction
	JR	NZ,ZASM85	;opcode	range 40 - 7f
	LD	A,0FFH		;set halt instruction key value	to 0f7h
	JR	ZASM90
ZASM55:	INC	DE
	LD	A,(DE)		;byte two of multi-byte	instruction
	DEC	C		;test for ed instruction
	JR	NZ,ZASM65	;nz - not an ed
	CP	80H
	JR	NC,ZASM60	;opcode	range ed 40 - ed 7f
	CP	40H
	JR	NC,ZASM90	;legal
	LD	A,09FH
	JR	ZASM90		;map to	question marks
ZASM60:	LD	B,0E0H		;set bias
	CP	0C0H		;test for illegal ed
	JR	C,ZASM90	;legal
	LD	A,0BFH		;map to	question marks
	JR	ZASM90		;opcode	range ed a0 - ed bb


ZASM65:	INC	C
	JR	Z,ZASM80	;z - cb	instruction
	CP	0CBH		;fd or dd - check for cb in byte two
	JR	NZ,ZASM70
	INC	DE		;fetch last byte of fdcb or ddcb
	INC	DE
	LD	A,(DE)
	RRCA
	JR	C,ZASM75
	AND	3
	CP	3
	JR	NZ,ZASM75	;error
	LD	A,(DE)
	JR	ZASM80
ZASM70:	LD	A,(ZMFLAG)
	SUB	3
	LD	A,(DE)
	JR	NZ,ZASM50
	LD	HL,Z80F3
	LD	C,Z80F3L
	CPIR
	JR	Z,ZASM50
ZASM75:	LD	A,09FH
	JR	ZASM90
ZASM80:	CP	40H		;test type of cb instruction
	LD	B,0E8H
	JR	C,ZASM85	;opcode	range cb 00 - cb 3f (shift)
	RLCA
	RLCA
	AND	03		;hi order bits become index
	LD	B,0F0H
	JR	ZASM90		;opcode	range cb 40 - cb ff
ZASM85:	RRCA
	RRCA
	RRCA			;bits 3-5 of cb	shift yield key
	AND	07H
ZASM90:	ADD	A,B		;add in	bias from b reg
	LD	C,A		;c - instruction key value
	XOR	A
	LD	B,A
	LD	HL,ZOPCPT	;opcode	name pointer table
	ADD	HL,BC		;index into table
	LD	L,(HL)		;fetch opname index
	LD	H,A
	ADD	HL,HL
	ADD	HL,HL		;index times four
	LD	DE,ZOPCNM	;op code name table
	ADD	HL,DE
	EX	DE,HL		;de - pointer to opcode	name
	LD	HL,(ZASMIO)	;buffer	pointer	storage
	LD	A,C
	LD	(ZASMKV),A	;opcode key value
	LD	A,(MAXLEN)
	LD	C,A
	INC	C		;set label length based on max size

	LD	A,(LCMD)	;if xreg use compressed output format
	CP	'X'
	JR	Z,ZASM92
	CP	'S'		;step needs compressed format
ZASM92:	ADD	HL,BC
	LD	C,4
	EX	DE,HL		;de - buffer   hl - opcode name	pointer
	LDIR
	INC	BC		;one space after opcode	for compressed format
	JR	Z,ZASM95
	LD	C,4		;four spaces for true disassembly
ZASM95:	EX	DE,HL		;hl - buffer pointer
	ADD	HL,BC		;start of operand field	in buffer
	LD	A,(ZASMKV)	;save the instruction key value
	CP	09FH
	JR	NZ,ZASM99
	LD	DE,(ZASMPC)
	LD	A,(ZMFLAG)
	LD	B,A
ZASM97:	LD	A,(DE)
	LD	C,D
	CALL	ZHEX
	DEC	B
	JP	Z,OPN020
	LD	(HL),','
	INC	HL
	LD	D,C
	INC	DE
	JR	ZASM97
ZASM99:	LD	DE,ZOPND1	;table of first	operands
	ADD	A,E
	LD	E,A		;instant offset
	LD	A,D
	ADC	A,B
	LD	D,A
	LD	A,(DE)
	INC	A
	JR	Z,OPN040	;no operands


;******************************************************************************
;*
;*                          - operand processing -
;*
;*	enter:	b - zero (process first	operand)
;*		c - instruction	key value
;*
;*   instruction key value is used to fetch operand key value:
;*
;*	operand	key value is in	the range 0 - 1fh
;*	operand key value interpretted as follows:
;*
;*      0 - 17h  use as index to fetch literal from operand
;*		 name table (sign bit set - parens required)
;*
;*     18 - 1fh  operand requires processing - use as index
;*	         into oprerand jump table which is located
;*	         immediately after name table
;*
;*	   0ffh  no operand
;*
;*   operand key value jump table routines: (buffer address in de)
;*
;*
;*   entry point   key         action
;*
;*     opn100	   18h	 relative jump
;*     opn200	   19h	 convert 8 bit operand to hex
;*     opn300	   1ah	 convert 16 bit	operand	to hex
;*     opn400	   1ch	 register specified in instruction
;*     opn600	   1dh	 hl/ix/iy instruction
;*     opn700	   1eh	 mask rst operand from bit 3-5 of rst instruction
;*     opn800	   1fh	 bit number is specified in bits 3-5 of	op code
;*
;*    exit: to zasm15 to continue block disassembly
;*
;******************************************************************************

OPN:	DEC	A		;save operand key value
	JP	P,OPN010
	LD	(HL),'('
	INC	HL
OPN010:	EX	DE,HL		;de - buffer address
	LD	B,A
	ADD	A,A		;operand key value times two
OPN012:	LD	HL,ZOPNM	;base of operand name/jump table
	ADD	A,L		;index into table
	LD	L,A
	JR	NC,OPN014
	INC	H		;account for carry
OPN014:	LD	A,1FH
	AND	B
	CP	ZOPNML		;test if processing required
	JR	C,OPN015	;c - operand is	a fixed	literal
	LD	A,(HL)		;fetch processing routine address
	INC	HL
	LD	H,(HL)		;
	LD	L,A		;hl - operand processing routine
	JP	(HL)		;geronimoooooooo
OPN015:	LDI			;first byte of operand literal
	INC	BC		;compensate for	ldi
	EX	DE,HL		;hl - buffer
	LD	A,(DE)
	CP	' '		;test for space	as byte	two of literal
	JR	Z,OPN020	;ignore	spaces appearing in byte two
	LD	(HL),A
	INC	HL		;bump buffer pointer
OPN020:	LD	A,B		;operand key value
	CP	80H		;test for closed paren required
	JR	C,OPN030	;c - none required
	LD	(HL),')'
	INC	HL
OPN030:	LD	A,(OPNFLG)	;get flag byte
	XOR	0FFH		;toggle operand number
	LD	(OPNFLG),A	;
	JR	Z,OPN040	;z - just finished number two
	LD	A,(ZASMKV)	;get op code key value
	LD	DE,ZOPND2	;index into operand2 table
	ADD	A,E
	LD	E,A
	JR	NC,OPN035
	INC	D
OPN035:	LD	A,(DE)		;get operand2 key value
	INC	A
	JR	Z,OPN040	;z - no	second operand
	LD	(HL),','	;separate operands with comma in buffer
	INC	HL
	JR	OPN
OPN040:	LD	HL,(ZASMIO)	;rewind	buffer pointer
	LD	A,(MAXLIN)
	LD	C,A
OPN041:
	LD	A,(CASE)
	AND	A
	JR	Z,OPN043	;Upper case requested - no need to convert
				;reg names [ras 19 Sep 85]
OPN042:	LD	A,(HL)
	AND	A		;if sign bit on then no case conversion
	CALL	P,ILCS
	AND	7FH		;in case we fell thru
	LD	(HL),A
	INC	HL
	DEC	C
	JR	NZ,OPN042
OPN043:				;correct jmp from opn041 4-9-85
	LD	A,(MAXLIN)
	CP	30
	JR	Z,OPN044
	LD	A,44		;allow 16 comment chars
OPN044:
	LD	C,A		;number of chars to print (omit crlf)
	LD	HL,(ZASMIO)
	LD	A,(LCMD)
	CP	'J'		;j command
	RET	Z		;end of the line for full screen animation
	CALL	PRINTB		;print buffer
	INC	HL		;point past crlf to next 32 byte group
	INC	HL
	EX	DE,HL
	LD	A,(LCMD)	;jettison all commands except z
	CP	'X'
	JP	Z,CRLF
	CP	'A'
	JP	Z,CRLF
	CP	'S'
	JP	Z,CRLF
	XOR	A
	LD	(ZASMF),A
	LD	HL,(ZASMCT)	;check disassembly count
	DEC	HL
	LD	A,H
	OR	L		;test for count expired
	JP	NZ,OPN060	;nz - this is not a count of one so this is not
				;interactive disassebly

	CALL	TTYI		;check input command letter for interactive
	CALL	IXLT		;force upper case
	LD	(ZASMF),A
	CP	'C'		;code?
	CALL	Z,CRET		;if user wants code return cursor to start of
				;line and disassemble again
	JP	Z,ZASM15
	LD	C,82H		;assume defw
	CP	'D'
	JR	Z,OPN045	;defw -	082h
	DEC	C		;assume ascii defb
	CP	'A'
	JR	Z,OPN045	;ascii defb - 081h
	CP	'B'
	JR	NZ,OPN046	;none of the above
	LD	C,0C1H		;hex defb - 0c1h
OPN045:	CALL	CRET
	LD	HL,(ZASMPC)
	JP	ZASM18

				;zasmf - 0 means this is block disassembly
				;      - nz means char entered during
          			;        interactive mode was not c d a or b.

OPN046:	CP	';'		;check if user wants to insert comments
	JR	NZ,OPN060	;nz - user does not want to add comment

	CALL	TTYO		;echo semicolon
	DEC	DE
	DEC	DE		;point to carriage return
	LD	A,' '
	LD	(DE),A		;clear crlf from buffer
	INC	DE
	LD	(DE),A
	INC	DE
	CALL	WRITE		;end of buffer - write if required
	LD	B,29
	LD	A,(MAXLIN)
	SUB	30
	JP	Z,OPN048
	DEC	DE
	LD	B,16
	XOR	A
OPN048:	LD	C,A
	PUSH	BC
	PUSH	DE		;save disassembly buffer pointer
	LD	D,A
	CALL	IEDT03
	POP	DE
	POP	BC
	LD	A,B		;recover max size of comment
	DEC	HL
	LD	B,(HL)		;number actually entered
	SUB	B
	LD	C,A		;trailing spaces
	INC	HL
	EX	DE,HL		;de - input buffer   hl - disassembly buffer
	LD	(HL),';'
	INC	HL
OPN049:	DEC	B		;pre-test count
	JP	M,OPN050
	LD	A,(DE)		;first char of input
	INC	DE
	LD	(HL),A		;into disassembly buffer
	INC	HL
	JR	OPN049
OPN050:	DEC	C
	JP	M,OPN055
	LD	(HL),' '
	INC	HL
	JR	OPN050
OPN055:	LD	(HL),CR
	INC	HL
	LD	(HL),LF
	INC	HL
	EX	DE,HL
	JP	OPN065

OPN060:
	LD	A,(MAXLIN)
	CP	30		;test for 6 chars in label
	JP	Z,OPN065	;z - buffer point ok
	LD	A,64-46		;bump buffer pointer to next 64 byte chunk
	ADD	A,E
	LD	E,A
	JP	NC,OPN065
	INC	D

OPN065:	CALL	WRITE		;check if write to disk flag in effect

	CALL	CRLF
	LD	(ZASMIO),DE	;save new buffer pointer
	LD	HL,(ZASMWT)	;check disassembly count
	XOR	A
	OR	H		;less than 256?
	JR	Z,OPN080	;less -	this is	tally
	LD	BC,(ZASMNX)	;fetch next disassembly	address
	SBC	HL,BC		;versus	requested end address
	JR	C,OPN095	;c - end
	ADD	HL,BC		;restore next disassembly address
	JR	OPN085		;more
OPN080:	DEC	HL
	LD	A,H
	OR	L
	JR	NZ,OPN085	;nz - more
	LD	HL,(ZASMCT)	;fetch permanent block size
	LD	A,(ZASMF)
	AND	A
	CALL	Z,TTYI		;query user - more?
	CP	CR		;return	means end
	JR	Z,OPN095
	JR	OPN090
OPN085:
	CALL	TTYQ
	CP	CR
	JR	Z,OPN095	;nz - terminate	disassembly
OPN090:
	LD	(ZASMWT),HL	;restore count
	LD	HL,(ZASMNX)	;next instruction pointer
	LD	(ZASMPC),HL	;make current
	JP	ZASM15		;disassemble next instruction

OPN095:	LD	A,(DWRITE)	;writing to disk?
	AND	A
	RET	Z
	LD	A,EOF		;
	LD	(DE),A		;set eof
	LD	DE,ZASMBF
	RET

WRITE:	PUSH	BC
	PUSH	HL
	LD	HL,NZASM	;address of end of disassembly buffer
	AND	A
	SBC	HL,DE
	JR	NZ,WRT10	;not end of buffer
	LD	DE,ZASMBF	;need to rewind buffer pointer
; 	LD	A,(DWRITE)	;test write to disk flag
; 	AND	A
; 	CALL	NZ,BDWRIT	;nz - writing to disk
WRT10:	POP	HL
	POP	BC
	RET


OPN100:	LD	HL,(ZASMPC)
	INC	HL
	LD	A,(HL)		;fetch relative	displacement
	LD	C,A
	INC	C
	ADD	A,A		;test sign for displacement direction
	LD	B,0
	JR	NC,OPN105
	DEC	B		;produce zero for forward - ff for back
OPN105:	ADD	HL,BC		;adjust	pc
	EX	DE,HL		;de - instruction ptr	hl - buffer
	CALL	FADR
	CALL	Z,XSYM
	JP	Z,OPN040	;symbol	found
;	ld	(hl),'$'	;- eg 3.3.4a
;	inc	hl		;-
;	ld	a,c		;-
;	inc	a		;-
	LD	B,0
;	cp	82h		;-
;	jp	opn610		;- convert displacement to ascii
	JP	OPN316		;+

OPN200:	CALL	ZMQF		;check for interactive disassembly
	JR	NC,OPN205	;sign off - not interactive
	ADD	A,A		;shift out bit 6
	LD	A,(HL)
	JR	C,OPN215	;on - must be hex defb
	CALL	ZASCII		;user wants ascii - check validity
	JR	NZ,OPN215	;nz - untable to convert to ascii
	JP	OPN020
OPN205:	CALL	ZNDX		;check for ix or iy instruction
	EX	DE,HL		;buffer back to de
	JR	NZ,OPN210	;nz - not ix or	iy
	INC	HL
	INC	HL		;must be  ld (ix+ind),nn
OPN210:	INC	HL		;
	LD	A,(HL)		;fetch object byte
	JR	Z,OPN215	;no conversion of ix and iy displacements
				;to ascii
	LD	A,(ZASMKV)	;check for in or out instruction
	CP	0B3H
	JR	Z,OPN215	;no conversion of port addresses to ascii
	CP	0BBH
	JR	Z,OPN215
	LD	A,(HL)
	CALL	ZASCII
	JP	Z,OPN020
OPN215:	EX	DE,HL
	LD	A,(DE)
	CP	10		;decimal number?
	JR	NC,OPN220	;no - convert to hex
	CALL	ZHEX20		;86 the	leading	zero and trailing h
	JP	OPN020
OPN220:	CALL	ZHEX		;do hex	to asii	conversion
	LD	(HL),'H'	;following 8 bit hex byte
	INC	HL
	JP	OPN020

OPN300:	CALL	ZMQF
	JR	C,OPN315	;c - this is defw
	CALL	ZNDX
	EX	DE,HL		;de - buffer   hl - instruction	pointer
	JR	NZ,OPN310	;nz - not ix or	iy
	INC	HL
OPN310:	INC	HL
OPN315:	LD	A,(HL)		;fetch lo order	16 bit operand
	INC	HL
	LD	H,(HL)		;hi order
	LD	L,A
	EX	DE,HL		;de - 16 bit operand   hl - buffer
	CALL	FADR
	CALL	Z,XSYM
	JP	Z,OPN020	;symbol	found
OPN316:				;+ eg 3.3.4b
	LD	A,D		;convert hi order to hex
	LD	C,A		;save spare copy
	CALL	ZHEX
	LD	A,E
	LD	D,A
	CALL	ZHEX10
	XOR	A
	OR	C
	JR	NZ,OPN320
	LD	A,D
	CP	10
	JP	C,OPN020
OPN320:	LD	(HL),'h'
	INC	HL
	JP	OPN020

OPN400:
	CALL	ZNDX
	JR	NZ,OPN410	;nz - not ix or	iy instruction
	INC	DE
	LD	A,(DE)
	CP	0CBH		;check for indexed bit instruction
	JR	NZ,OPN410
	INC	DE		;byte of interest is number four
	INC	DE
OPN410:	LD	A,01		;check low bit of operand key value
	AND	B
	LD	A,(DE)		;fetch op code
	JR	NZ,OPN500	;nz - index 01bh
	RRA			;register specified in bits 0-5
	RRA
	RRA
OPN500:	AND	007		;register specified in bits 0-2
	XOR	006		;from the movie	of the same name
	JP	NZ,OPN010	;nz - not hl or	ix or iy
	LD	A,(ZASMPC)
	XOR	E		;test if pc was	incremented
	LD	(HL),'('	;set leading paren
	INC	HL
	LD	B,080H		;set sign bit -	closed paren required
	EX	DE,HL		;de - buffer
	JP	Z,OPN012



OPN600:
	CALL	ZNDX		;determine if ix or iy
	JR	Z,OPN605	;z - must be ix	of iy
	LD	A,80H
	AND	B
	JP	OPN010
OPN605:
				;+Fix display of IX/IY when upper case is set
	PUSH	AF		;+Adapted from patch by George Havach (3.5.7)
	LD	C,0DFH		;+Upper case mask
	LD	A,(CASE)	;+See if upper or lower case
	OR	A		;+
	JR	Z,OPN606	;+Skip if upper case, otherwise
	LD	C,0FFH		;+ adjust mask
OPN606:				;+
	LD	A,'i'		;+First character
	AND	C		;+Select case
;	ld	(hl),'i'	;-Set first character
	LD	(HL),A		;+Set first character
	INC	HL
	POP	AF		;+Second character
	ADC	A,'x'		;Carry determines x or y (from zndx)
	AND	C		;+Select case
	LD	(HL),A
	INC	HL
	LD	A,80H		;Test for parens
	AND	B
	JP	Z,OPN030	;z - not indexed instruction
	INC	DE
	LD	A,(DE)		;fetch second byte of instruction
	CP	0E9H		;test for jp (ix) or jp	(iy)
	JP	Z,OPN020	;output	closed paren
	INC	DE
	LD	A,(DE)		;fetch displacement byte
	CP	80H		;test sign
OPN610:	LD	(HL),'+'	;assume	forward
	JR	C,OPN620	;c - forward
	NEG			;force positive
	LD	(HL),'-'
OPN620:	INC	HL		;bump buffer pointer
	AND	7FH		;strip sign
	CALL	ZHEX		;convert to hex
	LD	A,9
	CP	D
	JP	NC,OPN020
	LD	(HL),'h'
	INC	HL
	JP	OPN020		;output	closed paren




OPN700:	LD	HL,(ZASMPC)
	LD	A,(HL)		;fetch restart instruction
	EX	DE,HL		;de - buffer   hl instruction pointer
	AND	38H
	CALL	ZHEX		;convert restart number	to ascii
	LD	(HL),'H'
	JP	OPN020



OPN800:	CALL	ZNDX
	JR	NZ,OPN810	;nz - not ddcb or fdcb instruction
	INC	DE
	INC	DE
	INC	DE		;
	LD	A,(DE)		;byte 4	of ix or iy bit	instruction
	JR	OPN820
OPN810:	CP	10H		;weed out interrupt mode instructions
	LD	A,(DE)		;second	byte of	instruction regardless
	JR	NZ,OPN820	;nz - cb bit instruction
	XOR	046H		;
	JR	Z,OPN830	;z - interrupt mode zero
	SUB	8
OPN820:	RRA
	RRA
	RRA
	AND	07		;leave only bit	number
OPN830:	CALL	ZHEX20		;convert to ascii
	JP	OPN030

;******************************************************************************
;*
;*		     disassembler utility subroutines
;*
;*	zndx:	  determines if	fd dd ed or cb instruction
;*		  caller uses returned values on an individual basis
;*
;*		   z  -	dd fd
;*		  nz  -	neither	of the above
;*		  current instruction pointer bumped if	cb or ed instruction
;*
;*	zhex:	  convert to byte in the accumulator to ascii with leading zero
;*		  store	in buffer
;*		  d - reg destroyed
;*
;*	zhex10:	  no leading zero permitted
;*	zhex20:	  convert lo order nibble only
;*
;******************************************************************************

ZNDX:	LD	HL,(ZASMPC)	;fetch current instruction pointer
	EX	DE,HL		;de - instruction pointer   hl - buffer
	LD	A,(DE)
;	ADD	A,-0FDH		;iy check
	ADD	A,$03		;iy check
	RET	Z
	SUB	0DDH-0FDH	;ix check
	RET	Z
	CP	10H		;ed check
	JR	Z,ZNDX00
	CP	0EEH		;cb check
	LD	A,0		;clear
	RET	NZ
ZNDX00:	INC	DE		;cb or ed - bump instruction pointer
	CPL
	AND	A		;ensure	nz set
	CPL
	RET



ZHEX:	LD	D,A
	CP	0A0H		;test byte to convert
	JR	C,ZHEX00	;starts	with decimal digit - 86	the lead zero
	LD	(HL),'0'
	INC	HL
	JR	ZHEX10
ZHEX00:	CP	10
	JR	C,ZHEX20
ZHEX10:	RRCA
	RRCA
	RRCA
	RRCA
	AND	0FH
	ADD	A,90H
	DAA
	ADC	A,40H
	DAA			;a - ascii digit
	LD	(HL),A
	INC	HL
	LD	A,D		;lo nibble conversion
ZHEX20:	AND	0FH
	ADD	A,90H
	DAA
	ADC	A,40H
	DAA
	LD	(HL),A
	INC	HL
	RET



ZMQF:	LD	HL,ZMFLAG	;check interactive disassembly flag
	LD	A,(HL)
	LD	(HL),0		;clear regardless
	LD	HL,(ZASMPC)	;fetch current disassembly address
	ADD	A,A		;check sign - on means interactive
	RET


ZASCII:	CP	' '
	RET	C
	AND	A
	RET	M
	CP	7FH		;rubout?
	JR	Z,ZASC10
	CP	QUOTE
	JR	NZ,ZASC20
ZASC10:	AND	A		;set nz - conversion not done
	RET
ZASC20:	EX	DE,HL
	LD	(HL),QUOTE	;defb -	quoted character
	INC	HL
; 	OR	80H		;hi bit on - no case conversion for this guy
	LD	(HL),A
	INC	HL
	LD	(HL),QUOTE
	CP	A
	RET



FADR:	PUSH	BC
	PUSH	HL
	LD	HL,(BDOSAD)	;fetch top of tpa - start of symbol table
	LD	BC,(MAXLEN)
	ADD	HL,BC		;point to start of symbol name
	INC	HL
FADR00:	LD	A,(HL)		;first byte of symbol name
	DEC	A		;check validity
	JP	M,FADR30	;end of	table
	ADD	HL,BC
	LD	A,(HL)		;fetch hi order	address	from table
	CP	D
	JP	NZ,FADR10
	DEC	HL
	LD	A,(HL)
	INC	HL
	CP	E
	JP	Z,FADR20
FADR10:	INC	HL
	JP	FADR00
FADR20:	EX	DE,HL		;return pointer in de
	LD	A,C
	CPL
	AND	E
	LD	E,A
	XOR	A
FADR30:	POP	HL
	POP	BC
	RET

XSYM:
	LD	A,(MAXLEN)
	DEC	A
	LD	C,A
XSYM00:	LD	A,(DE)
	AND	A
	RET	Z
	LD	(HL),A
	INC	HL
	INC	DE
	DEC	C
	JR	NZ,XSYM00
	RET

;******************************************************************************
;*
;*	bcde:  query user for 3	arguments: source address
;*					   destination address
;*					   byte	count
;*
;*	       used by move, verify, and yfil routines
;*
;*	       return: bc - byte count
;*		       de - destination
;*		       hl - source pointer
;*			z - no errors
;*
;*		       nz - no input entered
;*			  - untable to evaluate argument
;*			  - destination	address	< source
;*
;******************************************************************************

BCDE:	CALL	IEDTBC
	RET	M		;no input is treated as	error
	CALL	IARG		;read in starting block	address
	RET	NZ
	EX	DE,HL
	CALL	IARG
	RET	NZ
	SBC	HL,DE		;end - start = byte count - 1
	RET	C
	LD	B,H
	LD	C,L
	INC	BC
	CALL	IN00		;read in destination block address
	RET	NZ
	EX	DE,HL		;set regs right
	RET


;******************************************************************************
;*
;*			   console i/o routines
;*
;*   "physical"	i/o routines: ttyi - keyboard input
;*			      ttyo - console output
;*			      ttyq - console status
;*
;*   logical input routines:  inchar - input character processing
;*				       control characters echoed with ^
;*
;*   logical output routines: crlf   - output carriage return/line feed
;*			      cret   - output carriage return only
;*			     space   - output space
;*			    spaces   - output number of	spaces in passed in c
;*			    outhex   - output hex byte in a
;*			    othxsp   - output hex byte in a followed by	space
;*			    outadr   - output 16 bit hex value in hl followed
;*				       by space	- hl preserved
;*			     print   - output string - address in de
;*				       string terminated by null
;*			    printb   - output string - address in hl
;*						       byte count in c
;*						       end at first null
;*
;******************************************************************************
; ---------------------------------------------------------------------
; LX529 VIDEO BOARD:
; ---------------------------------------------------------------------
CRTBASE		EQU	$80
	; RAM0 for ascii chars & semi6. Combined with RAM1 and RAM2 for graphics
CRTRAM0DAT	EQU	CRTBASE		; RAM0 access: PIO0 port A data register
CRTRAM0CNT	EQU	CRTBASE+2	; RAM0 access: PIO0 port A control register
	; Printer port
CRTPRNTDAT	EQU	CRTBASE+1	; PRINTER (output): PIO0 port B data register
CRTPRNTCNT	EQU	CRTBASE+3	; PRINTER (output): PIO0 port B control register
					; STROBE is generated by hardware
	; RAM1 for graphics. (pixel index by RAM0+RAM1+RAM2)
CRTRAM1DAT	EQU	CRTBASE+4	; RAM1 access: PIO1 port A data register
CRTRAM1CNT	EQU	CRTBASE+6	; RAM1 access: PIO1 port A control register
	; Keyboard port (negated). Bit 7 is for strobe
CRTKEYBDAT	EQU	CRTBASE+5	; KEYBOARD (input): PIO1 port B data register
CRTKEYBCNT	EQU	CRTBASE+7	; KEYBOARD (input): PIO1 port B control register
KEYBSTRBBIT	EQU	7		; Strobe bit
	; RAM2 for graphics. (pixel index by RAM0+RAM1+RAM2)
CRTRAM2DAT	EQU	CRTBASE+8	; RAM2 access: PIO2 port A data register
CRTRAM2CNT	EQU	CRTBASE+10	; RAM2 access: PIO2 port A control register
	; Service/User port
CRTSERVDAT	EQU	CRTBASE+9	; Service (i/o): PIO2 port B data register
CRTSERVCNT	EQU	CRTBASE+11	; Service (i/o): PIO2 port B control register
PRNTBUSYBIT	EQU	0		; Printer BUSY bit		(in)	1
CRTWIDTHBIT	EQU	1		; Set 40/80 chars per line	(out)	0
PIO2BIT2	EQU	2		; user 1 (input)		(in)	1
PIO2BIT3	EQU	3		; user 2 (input)		(in)	1
PIO2BIT4	EQU	4		; user 3 (input)		(in)	1
CLKSCLK		EQU	5		; DS1320 clock line		(out)	0
CLKIO		EQU	6		; DS1320 I/O line		(i/o)	1
CLKRST		EQU	7		; DS1320 RST line		(out)	0
	; normal set for PIO2 (msb) 01011101 (lsb) that is hex $5D
					; Other bits available to user
	; RAM3 control chars/graphics attributes
CRTRAM3PORT	EQU	CRTBASE+14	; RAM3 port
CRTBLINKBIT	EQU	0		; Blink
CRTREVRSBIT	EQU	1		; Reverse
CRTUNDERBIT	EQU	2		; Underline
CRTHILITBIT	EQU	3		; Highlight
CRTMODEBIT	EQU	4		; ASCII/GRAPHIC mode
	; Beeper port
CRTBEEPPORT	EQU	CRTBASE+15	; Beeper port
	; 6545 CRT controller ports
CRT6545ADST	EQU	CRTBASE+12	; Address & Status register
CRT6545DATA	EQU	CRTBASE+13	; Data register

IOCBASE:
	RET			; null entry. start of control routines vector

MOVLFT:
	CALL	GCRSPOS
	DEC	HL
	LD	DE,(CURPBUF)
	XOR	A
	SBC	HL,DE
	CP	H
	JR	NZ,MOVLFT1
	CP	L
	RET	Z
MOVLFT1:
	DEC	HL
	ADD	HL,DE
	CALL	SCRSPOS
	PUSH	HL
	LD	A,(COLBUF)
	DEC	A
	CP	$FF
	JR	NZ,MOVLFT2
	LD	A,$4F
MOVLFT2:
	LD	(COLBUF),A
	LD	HL,MIOBYTE
	BIT	4,(HL)
	POP	HL
	RET	NZ
	LD	A,$20
; 	JP	DISMVC
	JP	DISPCH

MOVDWN:
	CALL	GCRSPOS
	DEC	HL
	LD	DE,$0050
	ADD	HL,DE
	CALL	SCRSPOS
	JP	LFEED1

LFEED:
	XOR	A
	LD	(COLBUF),A
LFEED1:	CALL	SCRTST
	RET	C
	LD	HL,MIOBYTE
	BIT	2,(HL)
	LD	DE,$F830
	CALL	GCRSPOS
	DEC	HL
	JR	Z,MDJMP0
	ADD	HL,DE
	JP	SCRSPOS
MDJMP0:	PUSH	HL
	CALL	CLRLIN
	LD	HL,(CURPBUF)
	LD	DE,$0050
	ADD	HL,DE
	LD	DE,$0820
	PUSH	HL
	SBC	HL,DE
	POP	HL
	JR	C,MDJMP1
	RES	3,H
MDJMP1:	LD	(CURPBUF),HL
	CALL	SDPYSTA
	POP	HL
	JR	C,MEJP
	RES	3,H
MEJP:	JP	SCRSPOS

CLRSCR:
	LD	HL,$0000
	XOR	A
	LD	(COLBUF),A
	CPL
	LD	(RAM3BUF),A
	LD	(CURPBUF),HL
	CALL	SCRSPOS
	CALL	SDPYSTA
	PUSH	HL
CLSNC:	LD	A,$20
	CALL	DISPCH
	INC	HL
	LD	A,H
	CP	$08
	JR	NZ,CLSNC
	POP	HL
	JP	SCRSPOS

IOCCR:
	EX	DE,HL
	BIT	3,(HL)
	JR	Z,IOCCR1
	CALL	CLREOL
IOCCR1:	JP	CHOME

SIOCESC:
	EX	DE,HL
	SET	7,(HL)
	RET

DISPCH:
	PUSH	AF
DGCLP0:	IN	A,(CRT6545ADST)
	BIT	7,A
	JR	Z,DGCLP0
	POP	AF
	OUT	(CRTRAM0DAT),A
	LD	A,(RAM3BUF)
	OUT	(CRTRAM3PORT),A
	XOR	A
	OUT	(CRT6545DATA),A
	RET

GCRSPOS:
	LD	A,$0E
	OUT	(CRT6545ADST),A
	IN	A,(CRT6545DATA)
	LD	H,A
	LD	A,$0F
	OUT	(CRT6545ADST),A
	IN	A,(CRT6545DATA)
	LD	L,A
	INC	HL
	JP	CRTPRGEND

SDPYSTA:
	LD	A,$0C
	OUT	(CRT6545ADST),A
	LD	A,H
	OUT	(CRT6545DATA),A
	LD	A,$0D
	OUT	(CRT6545ADST),A
	LD	A,L
	OUT	(CRT6545DATA),A
	JP	CRTPRGEND

SCRSPOS:
	LD	A,$0E
	OUT	(CRT6545ADST),A
	LD	A,H
	OUT	(CRT6545DATA),A
	LD	A,$0F
	OUT	(CRT6545ADST),A
	LD	A,L
	OUT	(CRT6545DATA),A
SCRSPOS1:
	LD	A,$12
	OUT	(CRT6545ADST),A
	LD	A,H
	OUT	(CRT6545DATA),A
	LD	A,$13
	OUT	(CRT6545ADST),A
	LD	A,L
	OUT	(CRT6545DATA),A
	JR	CRTPRGEND

SCRTST:
	LD	DE,(CURPBUF)
	XOR	A
	SBC	HL,DE
	LD	A,H
	CP	$07
	RET	C
	LD	A,L
	CP	$CF
	RET

CLRLIN:
	LD	BC,$0050
CLRLIN1:
	LD	A,(RAM3BUF)
	PUSH	AF
	LD	A,$FF
	LD	(RAM3BUF),A
CLRLP1:	LD	A,$20
	CALL	DISPCH
	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,CLRLP1
	POP	AF
	LD	(RAM3BUF),A
	RET

CLREOP:
	XOR	A
	LD	HL,(CURPBUF)
	LD	DE,$07D0
	ADD	HL,DE
	EX	DE,HL
	CALL	GCRSPOS
	DEC	HL
	EX	DE,HL
	SBC	HL,DE
	PUSH	HL
	POP	BC
CLRJ0:	CALL	CLRLIN1
	EX	DE,HL
	JP	SCRSPOS

CLREOL:
	LD	A,(COLBUF)
	LD	B,A
	LD	A,$50
	SUB	B
	LD	B,$00
	LD	C,A
	CALL	GCRSPOS
	DEC	HL
	EX	DE,HL
	JR	CLRJ0

CHOME:
	LD	HL,COLBUF
	LD	E,(HL)
	XOR	A
	LD	(HL),A
	LD	D,A
	CALL	GCRSPOS
	DEC	HL
	SBC	HL,DE
	CALL	SCRSPOS
	RET

CRTPRGEND:
	LD	A,$1F
	OUT	(CRT6545ADST),A
	RET


IOCVEC:
	DW	IOCBASE			; NUL 0x00 (^@)  no-op
	DW	IOCBASE		; SOH 0x01 (^A)  uppercase mode
	DW	IOCBASE		; STX 0x02 (^B)  normal case mode
	DW	IOCBASE			; ETX 0x00 (^C)  no-op
	DW	IOCBASE			; EOT 0x04 (^D)  cursor off
	DW	IOCBASE			; ENQ 0x05 (^E)  cursor on
	DW	IOCBASE			; ACK 0x06 (^F)  locate cursor at CURPBUF
	DW	IOCBASE			; BEL 0x07 (^G)  beep
	DW	MOVLFT			; BS  0x08 (^H)  cursor left (destr. and non destr.)
	DW	IOCBASE			; HT  0x09 (^I)  no-op
	DW	MOVDWN			; LF  0x0a (^J)  cursor down one line
	DW	CHOME			; VT  0x0b (^K)  cursor @ column 0
	DW	CLRSCR			; FF  0x0c (^L)  page down (clear screen)
	DW	IOCCR			; CR  0x0d (^M)  provess CR
	DW	IOCBASE			; SO  0x0e (^N)  clear to EOP
	DW	IOCBASE			; SI  0x0f (^O)  clear to EOL
	DW	IOCBASE			; DLE 0x10 (^P)  no-op
	DW	IOCBASE			; DC1 0x11 (^Q)  reset all attributes
	DW	IOCBASE			; DC2 0x12 (^R)  no-op
	DW	IOCBASE			; DC3 0x13 (^S)  no-op
	DW	IOCBASE			; DC4 0x14 (^T)  no-op
	DW	IOCBASE			; NAK 0x15 (^U)  no-op
	DW	IOCBASE		; SYN 0x16 (^V) scroll off
	DW	IOCBASE		; ETB 0x17 (^W) scroll on
	DW	IOCBASE			; CAN 0x18 (^X) hard crt reset and clear
	DW	IOCBASE			; EM  0x19 (^Y)  no-op
	DW	IOCBASE			; SUB 0x1a (^Z)  no-op
	DW	SIOCESC			; ESC 0x1b (^[) activate alternate output processing
	DW	IOCBASE			; FS  0x1c (^\) no-op
	DW	IOCBASE			; GS  0x1d (^]) no-op
	DW	IOCBASE			; RS  0x1e (^^) disabled (no-op)
	DW	IOCBASE			; US  0x1f (^_)  no-op

MIOBYTE:DEFB	0
COLBUF:	DEFB	0
RAM3BUF:DEFB	$FF
CURPBUF:DEFW	0
TMPBYTE:DEFB	0
APPBUF:	DEFW	0


ZCONOUT:
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	; force jump to register restore and exit in stack
	LD	HL,BCEXIT
	PUSH	HL
	;
	LD	A,C
	LD	HL,MIOBYTE
	BIT	7,(HL)			; alternate char processing ?
	EX	DE,HL
	JR	NZ,CONOU2		; yes: do alternate
	CP	$20			; no: is less then 0x20 (space) ?
	JR	NC,COJP1		; no: go further
	ADD	A,A			; yes: is a special char
	LD	H,0
	LD	L,A
	LD	BC,IOCVEC
	ADD	HL,BC
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	JP	(HL)			; jump to IOCVEC handler
COJP1:	EX	DE,HL
	BIT	6,(HL)			; auto ctrl chars ??
	JR	Z,COJP2			; no
	CP	$40			; yes: convert
	JR	C,COJP2
	CP	$60
	JR	NC,COJP2
	SUB	$40
COJP2:	CALL	DISPCH			; display char
	; move cursor right
MOVRGT:
	CALL	GCRSPOS			; update cursor position
	CALL	SCRSPOS
	LD	A,(COLBUF)
	INC	A
	CP	$50
	JP	Z,LFEED			; go down if needed
;;
SAVCOLB:
	LD	(COLBUF),A		; save cursor position
	RET
CONOU2:					; alternate processing....
	CP	$20			; is a ctrl char ??
	JR	NC,CURADR		; no: will set cursor pos
	RET				; ignore
;; cursor addressing service routine
;; address is ESC + (COL # + 32) + (ROW # + 32) (then need a NUL to terminate...)
CURADR:	LD	HL,TMPBYTE
	BIT	0,(HL)
	JR	NZ,SETROW
	CP	$70			; greater then 80 ?
	RET	NC			; yes: error
	SUB	$20			; no: ok
	LD	(APPBUF),A		; store column
	SET	0,(HL)			; switch row/col flag
	RET
SETROW:	CP	$39			; greater than 24 ?
	RET	NC			; yes: error
	SUB	$1F			; no: ok
	RES	0,(HL)			; resets flags
	LD	HL,MIOBYTE
	RES	7,(HL)			; done reset
	LD	B,A
	LD	HL,$FFB0
	LD	DE,$0050
CUROFS:	ADD	HL,DE			; calc. new offset
	DJNZ	CUROFS
	LD	A,(APPBUF)
	LD	(COLBUF),A
	LD	E,A
	ADD	HL,DE
	EX	DE,HL
	LD	HL,(CURPBUF)
	ADD	HL,DE
	JP	SCRSPOS			; update position
BCEXIT:
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET


ZCONST:
	IN	A,($85)
	CPL
	BIT	7,A
	JR	NZ,MCONSP
	XOR	A
	LD	($59),A
	RET
MCONSP:	LD	A,$FF
	RET

ZCONIN:
	IN	A,(85H)
	CPL
	BIT	7,A
	JR	NZ,ZCONIN

ZCONI1:	IN	A,(85H)
	CPL
	BIT	7,A
	JR	Z,ZCONI1
	AND	7FH
	RET

TTYQ:
	PUSH	BC
	PUSH	DE
	PUSH	HL
	CALL	ZCONST
	AND	$7F
	POP	HL
	POP	DE
	POP	BC
	RET

TTYI:
	PUSH	BC
	PUSH	DE
	PUSH	HL
	CALL	ZCONIN
	POP	HL
	POP	DE
	POP	BC
	RET

TTYO:
; 	PUSH	AF
	PUSH	BC
; 	PUSH	DE
; 	PUSH	HL
	LD	C,A
	CALL	ZCONOUT
; 	POP	HL
; 	POP	DE
	POP	BC
; 	POP	AF
	RET

INCHAR:	CALL	TTYI
	CP	CTLC
	JR	Z,EXICPM
	CP	CR
	RET	Z
	CP	TAB
	RET	Z
	CP	LF
	RET	Z
	CP	BS
	RET	Z
	CP	CTLX
	RET	Z
	CP	' '
	JR	NC,TTYO
	PUSH	AF
	LD	A,'^'
	CALL	TTYO
	POP	AF
	XOR	40H
	CALL	TTYO
	XOR	40H
	RET

EXICPM:
	EI			; renable interrupts
; 	CALL	GENAIN		; unlock monitor to enable ints
	JP	$F000

ILCS:	CP	'A'
	RET	C
	CP	'Z'+1
	RET	NC
	OR	20H
	RET



IXLT:	CP	'a'
	RET	C
	CP	'z'+1
	RET	NC
	SUB	20H
	RET


CRLF:	LD	A,CR
	CALL	TTYO
	LD	A,LF
	JP	TTYO

CRET:	LD	A,CR
	JP	TTYO

OTHXSP:	CALL	OUTHEX

RSPACE:	LD	A,' '
	JP	TTYO

SPACE5:	LD	C,5

SPACES:	CALL	RSPACE
	DEC	C
	JR	NZ,SPACES
	RET



NEWLIN:	CALL	CRLF
	EX	DE,HL
	CALL	OUTADR
	EX	DE,HL
	RET


OUTADR:	LD	A,H
	CALL	OUTHEX
	LD	A,L
	CALL	OTHXSP
	JR	RSPACE



OUTHEX:	PUSH	AF
	CALL	BINX
	CALL	TTYO
	POP	AF
	CALL	BINX00
	JP	TTYO



BINX:	RRCA
	RRCA
	RRCA
	RRCA
BINX00:	AND	0FH
	ADD	A,90H
	DAA
	ADC	A,40H
	DAA
	RET

ILIN:	PUSH	BC
	PUSH	DE
	LD	B,INBFSZ
	LD	C,0
	CALL	RTIN
	POP	DE
	POP	BC
	RET


ISTR:	PUSH	BC
	PUSH	DE
	LD	B,1
	LD	C,' '
	CALL	IEDT
	POP	DE
	POP	BC
	RET


				;resume input after reading in one char

IRSM:	PUSH	BC
	PUSH	DE
	LD	B,INBFSZ-1	;max input size less one char already read in
	LD	C,' '		;this is terminator char
	LD	D,1		;preset byte count
	LD	A,D
	LD	(STRNGF),A	;set nz - this is string function
	LD	HL,INBF+1	;init buffer pointer
	CALL	IEDT05
	XOR	A
	LD	(STRNGF),A	;this is no longer string function
	OR	D
	CALL	P,IN00
	POP	DE
	POP	BC
	RET



RTIN:	CALL	IEDT
	RET	M
IN00:	XOR	A
	LD	(ARGBC),A
	LD	HL,ARGBF
	LD	(ARGBPT),HL
IN10:	CALL	IARG
	RET	NZ
	AND	A
	JR	NZ,IN10
	RET



IARG:	PUSH	BC
	PUSH	DE
	CALL	PARG
	LD	A,(DELIM)
	POP	DE
	POP	BC
	RET

PARG:	CALL	PRSR		;extract next argument
	RET	NZ		;parse error
	LD	A,(QUOFLG)	;test for ascii	literal
	AND	A
	JR	Z,PARG10	;quote character not found
	XOR	A
	OR	B		;test for balanced quotes
	RET	M		;error - unbalanced quotes
	LD	A,(DE)		;first character of parse buffer
	SUB	QUOTE
	JR	NZ,PARG50	;invalid literal string but may be expression
				;involving a literal
	LD	L,B		;l - character count of	parse buffer
	LD	H,A		;clear
	ADD	HL,DE		;
	DEC	HL		;hl - pointer to last char in parse buffer
	LD	A,(HL)		;
	SUB	QUOTE		;ensure	literal	string ends with quote
	JR		NZ,PARG50
	LD	(HL),A		;clear trailing quote
	LD	C,B		;c - character count of	parse buffer
	LD	B,A		;clear
	DEC	C		;subtract the quote characters from the	count
	DEC	C
	DEC	C		;extra dec set error flag nz for '' string
	RET	M		;inform	caller of null string
	INC	C		;c - actual string length
	LD	A,C		;spare copy
	INC	DE		;point to second character of parse buffer
	LD	HL,(ARGBPT)	;caller	wants evaluated	arg stored here
	EX	DE,HL
	LDIR
	EX	DE,HL
	DEC	HL
	LD	E,(HL)
	DEC	HL
	LD	D,(HL)
	INC	HL
	INC	HL		;point to where to store next arg
	DEC	A		;argument length 1?
	JR	NZ,PARG00
	LD	D,A
PARG00:	LD	C,A
	INC	C		;account for increment
	LD	A,(ARGBC)	;fetch current argument byte counter
	ADD	A,C
	JR	PARG90
PARG10:	CALL	MREG		;check for register specified
	JR	NZ,PARG50	;nz - invalid register name
	LD	A,C
	ADD	A,A
	JR	C,PARG60	;sign bit reset	- 16 bit register pair
PARG50:	LD	HL,00
	LD	B,L
	LD	DE,PRSBF	;reinit	starting address of parse buffer
	CALL	XVAL
	JR	Z,PARG70
	RET
PARG60:	LD	A,(HL)
	DEC	HL
	LD	L,(HL)
	LD	H,A
	LD	A,(PRSBF)	;check paren flag for indirection
	AND	A
	JR	NZ,PARG65	;nz - parens not removed
	INC	DE		;bump past trailing null
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
PARG65:	LD	B,80H
	CALL	XVAL
	RET	NZ
PARG70:	EX	DE,HL
	LD	HL,(ARGBPT)
	LD	A,(ARGBC)
	INC	D
	DEC	D
	JR	Z,PARG80
	LD	(HL),D
	INC	HL
	INC	A
PARG80:	LD	(HL),E
	INC	HL
	INC	A
PARG90:	LD	(ARGBC),A
	LD	(ARGBPT),HL
	EX	DE,HL
	XOR	A
	RET

OUTBYT:	LD	B,A		;save spare copy
	CALL	OTHXSP		;hex - display
	CALL	RSPACE
	LD	A,B		;display byte in ascii
	CALL	ASCI		;display ascii equivalent
	LD	C,3
	JP	SPACES		;solicit input three spaces right

RBYTE:	CALL	ISTR
	LD	A,(INBFNC)	;number	of chars in input buffer
	DEC	A		;test for input	buffer count of	zero
	INC	DE		;assume	zero - examine next
	RET	M		;no input means examine next
	DEC	DE		;incorrect assumption
	LD	A,(INBF)	;check first char of input buffer
	CP	'.'
	RET	Z		;period	ends command
	CP	'='		;new address?
	JR	NZ,BYTE10
	XOR	A		;clear equal sign so prsr ignores it
	LD	(INBF),A
	CALL	IRSM		;fetch new address to examine
	JR	NZ,BYTE30	;error
	LD	A,(INBFNC)
	SUB	2
	JR	C,BYTE30	;c - error - equal sign was only char of input
	EX	DE,HL		;return new address in de
	SCF			;ensure nz set for caller - no replacement data
				;was entered
	SBC	A,A
	RET
BYTE10:	CP	'^'		;
	JR	NZ,BYTE15	;nz - not up arrow means need more input
	DEC	DE		;dec current memory pointer
	SCF	 		;set nz - no replacement data entered
	SBC	A,A
	RET
BYTE15:	CALL	IRSM		;resume	input from console
	RET	Z		;no errors on input
	LD	A,(INBFNC)	;check number of chars input
	AND	A
	JR	Z,RBYTE		;none - user hit control x or backspaced to
				;beginning of buffer
BYTE30:	CALL	EXXX
	SCF
	SBC	A,A		;set nz - no replacement
	RET

;******************************************************************************
;*
;*	bdos function 10 replacement to	make romming this program easier since
;*	only two console i/o routines (ttyi and	ttyo) are required. this
;*	routine	supports backspace, line delete, and tab expansion.
;*
;*	all input stored in input buffer inbf.
;*
;*
;*	iedtbc:	solicit	console	for new	input and initialize b and c registers
;*		for max	size and input and no special line terminator.
;*
;*
;*	iedt:	solicit	console	for new	input using non-default	byte count for
;*		buffer or non-standard terminator.
;*
;*		called:	 b - max number	of characters to receive
;*			 c - special terminator	other than carriage return
;*
;*
;*	iedt00:	resume input - used by routines	which call iedt	with a buffer
;*		count of 1 to check for	special	character as the first char
;*		received (such as exam looking for period).
;*
;*		called:	 b - max number	of characters to receive
;*			 c - special terminator	other than carriage return
;*
;******************************************************************************


IEDTBC:	LD	B,INBFSZ
	XOR	A
	LD	C,A
	LD	(STRNGF),A
IEDT:	XOR	A
	LD	D,INBFSZ
	LD	HL,INBF
IEDT00:	LD	(HL),A
	INC	HL
	DEC	D
	JR	NZ,IEDT00
	LD	(ARGBC),A	;init number of	arguments tally
	LD	HL,ARGBF
	LD	(ARGBPT),HL	;init pointer to start of buffer
IEDT03:	LD	HL,INBF		;start of input	buffer
	LD	(QUOFLG),A
IEDT05:	CALL	INCHAR		;read char from	console
	LD	(TRMNTR),A	;assume line terminator until proven otherwise
	CP	CR		;end of	line?
	JP	Z,IEDT90	;z - end (jr changed to jp:  eg 3.3.8a)
	LD	E,A
	CP	QUOTE
	LD	A,(QUOFLG)
	JR	NZ,IEDT10
	XOR	QUOTE
	LD	(QUOFLG),A
	LD	A,QUOTE
	JR	IEDT60
IEDT10:	AND	A		;quote flag on?
	LD	A,E		;recover input character
	JR	Z,IEDT15	;off - check terminator
	LD	A,(LCMD)
	CALL	IXLT
	CP	'R'
	LD	A,E
	JR	NZ,IEDT20
IEDT15:	CP	C		;compare with auxiliary terminator
	JR	Z,IEDT90	;z - end
IEDT20:	CP	TAB
	JR	NZ,IEDT35	;nz - not tab check backspace
IEDT25:	CALL	RSPACE		;space out until char position mod 8 = zero
	LD	(HL),A		;store space in buffer as we expand tab
	INC	HL
	INC	D
	LD	A,7
	AND	D
	JR	NZ,IEDT25
	LD	(HL),0		;set end of line null
	JR	IEDT70
IEDT35:	LD	E,1		;assume	one backspace required
	CP	BS
	JR	Z,IEDT40	;z - correct assumption
	CP	CTLX		;erase line?
	JR	NZ,IEDT60	;nz - process normal input character

	XOR	A		;+ eg 3.3.8b
	OR	D		;+ See if ^X with empty buffer
	JP	Z,Z8E		;+ Abandon current command if so

	LD	E,D		;backspace count is number of chars in buffer

	JR	IEDT50		;+

IEDT40:	XOR	A		;test if already at beginning of buffer
	OR	D
	JR	Z,IEDT05	;z - at	beginning so leave cursor as is
IEDT50:	CALL	BKSP		;transmit bs - space - bs string
	DEC	D		;sub one from input buffer count
	DEC	HL		;rewind	buffer pointer on notch
	LD	A,(HL)		;check for control characters
	LD	(HL),0
	CP	QUOTE		;check for backspacing over a quote
	JR	NZ,IEDT55
	LD	A,(QUOFLG)	;toggle quote flag so we keep track of balance
				;factor
	XOR	QUOTE
	LD	(QUOFLG),A
	JR	IEDT58
IEDT55:	CP	' '
	CALL	C,BKSP		;c - control char requires extra bs for caret
IEDT58:	DEC	E		;dec backspace count
	JR	NZ,IEDT50	;more backspacing
	LD	A,(STRNGF)	;string	function flag on?
	AND	A
	JR	Z,IEDT05	;off - get next	input char
	XOR	A		;did we	backspace to start of buffer?
	OR	D		;test via character count
	JR	NZ,IEDT05	;not rewound all the way
	LD	(INBFNC),A	;set a zero byte count so caller knows
	DEC	D		;something is fishy
	RET
IEDT60:	LD	(HL),A		;store char in inbf
	INC	HL		;bump inbf pointer
	LD	(HL),0		;end of line
	INC	D		;bump number of	chars in buffer
IEDT70:	LD	A,D		;current size
	SUB	B		;versus	max size requested by caller
	JP	C,IEDT05	;more room in buffer
IEDT90:	LD	HL,INBFNC	;store number of characters received ala
				;bdos function 10
	LD	(HL),D
	INC	HL		;point to first	char in	buffer
	DEC	D		;set m flag if length is zero
	RET			;sayonara




BKSP:	CALL	BKSP00
	CALL	RSPACE
BKSP00:	LD	A,BS
	JP	TTYO


ASCI:	AND	7FH		;Convert contents of accumulator to ascii
	CP	DEL		;	check for del
	JR	Z,ASCI00	;	yes - translate to '.'
	CP	20H		;	check for control character
	JP	NC,TTYO		;	no - output as is
ASCI00:				;	yes - translate to '.'
;	if	hazeltine
	LD	A,'.'		;Non-printables replaced with dot
;	else
;	ld	a,tilde		;Non-printables replaced with squiggle
;	endif
       	JP	TTYO



BCDX:	CALL	BCDX00
	RET	NZ
BCDX00:	RLD
	EX	DE,HL
	ADD	HL,HL
	LD	B,H
	LD	C,L
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,BC
	LD	C,A
	LD	A,9
	CP	C
	RET	C
	XOR	A
	LD	B,A
	ADD	HL,BC
	EX	DE,HL
	ADC	A,A
	RET

NPRINT:	CALL	CRLF
PRINT:	LD	A,(DE)
	AND	A
	RET	Z
	CALL	TTYO
	INC	DE
	JR	PRINT


PRINTB:	LD	A,(HL)
	AND	A
	RET	Z
	CALL	TTYO
	INC	HL
	DEC	C
	JR	NZ,PRINTB
	RET



HOME:	LD	BC,00


;----------------------------------------------------------------------------
;
;	xycp:	Cursor-positioning routine.
;
;	Two versions are supplied and either can be selected during
;	assembly according to the setting of ATERM.
;
;	aterm	equ	TRUE		Selects ANSI screen driver
;	aterm	equ	FALSE		Selects default screen driver
;
;	In either  case, this routine is invoked with the row in B and
;	the column in C.
;
;----------------------------------------------------------------------------

XYCP:
	PUSH	BC		;Enter with row in b and column in c
	PUSH	DE
	PUSH	HL
	LD	HL,MXYCP
	LD	A,(ROW)		;Add in row offset
	ADD	A,B
	LD	B,A		;Save row character
	LD	A,(COLUMN)	;Add column bias
	ADD	A,C
	LD	C,A
	LD	E,(HL)		;Number of chars in cursor addressing string
XYCP00:
	INC	HL
	LD	A,(HL)
	CALL	TTYO
	DEC	E
	JR	NZ,XYCP00
	LD	A,(ROWB4X)
	AND	A
	JR	NZ,XYCP10
	LD	A,B
	LD	B,C
	LD	C,A
XYCP10:
	LD	A,B
	CALL	TTYO
	LD	A,C
	CALL	TTYO
	POP	HL
	POP	DE
	POP	BC
	RET

	ORG	XYCP+128		;  the object code

NREL:					;end of	relocatable code


ZOPNM:
	DEFB	'HL'
	DEFB	'A '
	DEFB	'H '
	DEFB	'L '
	DEFB	'D '
	DEFB	'E '
	DEFB	'B '
	DEFB	'C '
SIX:	DEFB	'IX'
	DEFB	'SP'
	DEFB	'P '
	DEFB	'R '
	DEFB	'I '
	DEFB	'AF'
	DEFB	'BC'
	DEFB	'DE'
SIY:	DEFB	'IY'
	DEFB	'Z '
	DEFB	'NC'
	DEFB	'NZ'
	DEFB	'PE'
	DEFB	'PO'
	DEFB	'M '
	DEFB	'PC'

RIX	EQU	(SIX-ZOPNM)/2		;relative position - ix
RIY	EQU	(SIY-ZOPNM)/2		;		     iy

ZOPNML	EQU	($-ZOPNM)/2

ZOPJTB	EQU	 $-NREL			;nrel to jump table bias for loader

ZOPRJT:
	DEFW	OPN600			;18 - hl/ix/iy test
	DEFW	OPN400			;19 - register specified in bits 0-2
	DEFW	OPN400			;1a - register specified in bits 3-5
	DEFW	OPN100			;1b - relative jump
	DEFW	OPN200			;1c - nn
	DEFW	OPN300			;1d - nnnn
	DEFW	OPN700			;1e - restart
	DEFW	OPN800			;1f - bit number

ZASMIO:	DEFW	ZASMBF

ZOPJTL	EQU	($-ZOPRJT)/2		;length	of operand jump	table

JTCMD:
	DEFW	IFCB			; i
	DEFW	ASMBLR			; a
	DEFW	USYM			; u
	DEFW	NPRT			; n
	DEFW	JDBG			; j
	DEFW	ZASM			; z
	DEFW	EXAM			; e
	DEFW	RGST			; r
	DEFW	GO			; g
	DEFW	YFIL			; y
	DEFW	MOVB			; m
	DEFW	VERIFY			; v
	DEFW	PSWDSP			; p
	DEFW	BREAK			; b
	DEFW	CBREAK			; c
	DEFW	FIND			; f
	DEFW	HSYM			; h
	DEFW	STEP			; s
	DEFW	OBREAK			; o
	DEFW	LLDR			; l
	DEFW	DUMP			; d
	DEFW	QPRT			; q
	DEFW	XREG			; x
	DEFW	BANK			; k
	DEFW	KDMP			; w
	DEFW	CUSER			; >
	DEFW	QEVAL			; ?
;	defw	gadr			; #
CMD:
;	defb	'#?>WKXQDLOSHFCB'
	DEFB	'?>WKXQDLOSHFCB'
	DEFB	'PVMYGREZJNUAI'
NCMD	EQU	$-CMD		;number	of commands

BPEMSG:
	DEFB	'*ERROR*'
BPMSG:
	DEFB	'*BP* @ '
	DEFB	0
; PROMPT:
; 	DEFB	'#',' ',bs,0
PROMPT:
	DEFB	'#',0

MRROW:	DEFB	'=','>'		;backspaces taken out
	DEFB	00

MXXXX:	DEFB	'??'
MXX:	DEFB	' ??  '


ASMFLG:	DEFB	' '
	DEFB	0

LCMD:	DEFB	' '
EMXXX:	DEFB	' ??'
	DEFB	0

MLDG:
	DEFB	'Loading: '
	DEFB	0

MFILNF:
	DEFB	'File Not Found'
	DEFB	CR,LF,00


MLODM:
	DEFB	'Loaded:  '
	DEFB	0
MLODPG:

	DEFB	'Pages:   '
	DEFB	0

MSNTX:
	DEFB	'Syntax Error'
	DEFB	CR,LF,0

MMEMXX:	DEFB	'Out Of Memory'
	DEFB	0

MCNTU:	DEFB	' - Continue? '
	DEFB	0

MIREG:
	DEFB	'IR: '
	DEFB	0


Z80FD:	DEFB	009H,019H,02BH
	DEFB	023H,029H,039H,0E1H
	DEFB	0E3H,0E5H,0E9H,0F9H
Z80FDL	EQU	$-Z80FD

Z80F4:	DEFB	021H,022H,02AH,036H,0CBH
Z80F4L	EQU	$-Z80F4


Z801:	DEFB	0C0H,0E9H,0C9H,0D8H
	DEFB	0D0H,0C8H,0E8H,0E0H
	DEFB	0F8H,0F0H
Z801L	EQU	$-Z801


Z802:	DEFB	036H,0C6H,0CEH,0D3H
	DEFB	0D6H,0DBH,0DEH,0E6H
	DEFB	0EEH,0F6H,0FEH
Z802C:	DEFB	018H,038H,030H
	DEFB	028H,020H,010H
Z802L	EQU	$-Z802
Z802CL	EQU	$-Z802C


Z80R:
Z803:	DEFB	001H,011H,021H,022H
	DEFB	02AH,031H,032H,03AH

Z803S:	DEFB	0CDH
	DEFB	0DCH,0D4H,0CCH,0C4H
	DEFB	0ECH,0E4H,0FCH,0F4H

Z803SL	EQU	$-Z803S			;number	of call	instructions

Z803C:	DEFB	0C3H
	DEFB	0DAH,0D2H,0CAH,0C2H
	DEFB	0EAH,0E2H,0FAH,0F2H

Z803L	EQU	$-Z803			;number	of 3 byte instructions
Z803CL	EQU	$-Z803S			;number	of 3 byte pc mod instructions

Z80ED:	DEFB	043H,04BH,053H
	DEFB	05BH,073H,07BH

Z80EDL	EQU	$-Z80ED

Z80RL	EQU	$-Z80R			;number	relocatable z80	instructions

Z80F3:
	DEFB	034H,035H,046H,04EH
	DEFB	056H,05EH,066H,06EH
	DEFB	070H,071H,072H,073H
	DEFB	074H,075H,077H,07EH
	DEFB	086H,08EH,096H,09EH
	DEFB	0A6H,0AEH,0B6H,0BEH
Z80F3L	EQU	$-Z80F3

;***********************************************************************
;*
;*
;*
;*
;*
;***********************************************************************

	ORG	($+3) AND 0FFFCH
ZOPCPT:
	DEFB	022H,01CH,01CH,015H	;nop	ld	ld	inc	00 - 03
	DEFB	015H,00CH,01CH,031H	;inc	dec	ld	rlca	04 - 07
	DEFB	010H,000H,01CH,00CH	;ex	add	ld	dec	08 - 0b
	DEFB	015H,00CH,01CH,036H	;inc	dec	ld	rrca	0c - 0f
	DEFB	00EH,01CH,01CH,015H	;djnz	ld	ld	inc	10 - 13
	DEFB	015H,00CH,01CH,02FH	;inc	dec	ld	rla	14 - 17
	DEFB	01BH,000H,01CH,00CH	;jr	add	ld	dec	18 - 1b
	DEFB	015H,00CH,01CH,034H	;inc	dec	ld	rra	1c - 1f
	DEFB	01BH,01CH,01CH,015H	;jr	ld	ld	inc	20 - 23
	DEFB	015H,00CH,01CH,00BH	;inc	dec	ld	daa	24 - 27
	DEFB	01BH,000H,01CH,00CH	;jr	add	ld	dec	28 - 2b
	DEFB	015H,00CH,01CH,00AH	;inc	dec	ld	cpl	2c - 2f
	DEFB	01BH,01CH,01CH,015H	;jr	ld	ld	inc	30 - 33
	DEFB	015H,00CH,01CH,03AH	;inc	dec	ld	scf	34 - 37
	DEFB	01BH,000H,01CH,00CH	;jr	add	ld	dec	38 - 3b
	DEFB	015H,00CH,01CH,004H	;inc	dec	ld	ccf	3c - 3f


	DEFB	014H,026H,039H,01CH	;in	out	sbc	ld	ed 40
	DEFB	021H,02DH,013H,01CH	;neg	retn	im	ld
	DEFB	014H,026H,001H,01CH	;in	out	adc	ld
	DEFB	022H,02CH,022H,01CH	;....	reti	...	ld
	DEFB	014H,026H,039H,01CH	;in	out	sbc	ld
	DEFB	022H,022H,013H,01CH	;...	...	im	ld
	DEFB	014H,026H,001H,01CH	;in	out	adc	ld
	DEFB	022H,022H,013H,01CH	;...	...	im	ld
	DEFB	014H,026H,039H,022H	;in	out	sbc	...
	DEFB	022H,022H,002H,037H	;...	...	...	rrd
	DEFB	014H,026H,001H,022H	;in	out	adc	...
	DEFB	044H,045H,046H,032H	;defb*	defw*	ddb*	rld
	DEFB	043H,047H,039H,01CH	;org*	equ*	sbc	ld	ed 70
	DEFB	022H,022H,022H,022H	;...	...	...	...
	DEFB	014H,026H,001H,01CH	;in	out	adc	ld
	DEFB	022H,022H,022H,022H	;...	...	...	...	ed 7f


	DEFB	01FH,008H,018H,028H	;ldi	cpi	ini	outi
	DEFB	022H,022H,022H,022H	;...	...	...	...
	DEFB	01DH,006H,016H,027H	;ldd	cpd	ind	outd
	DEFB	022H,022H,022H,022H	;...	...	...	...
	DEFB	020H,009H,019H,025H	;ldir	cpir	inir	otir
	DEFB	022H,022H,022H,022H	;...	...	...	...
	DEFB	01EH,007H,017H,024H	;lddr	cpdr	indr	otdr
	DEFB	022H,022H,022H,044H	;...	....	....	defb*


	DEFB	02BH,029H,01AH,01AH	;ret	pop	jp	jp	c0 - c3
	DEFB	003H,02AH,000H,038H	;call	push	add	rst	c4 - c7
	DEFB	02BH,02BH,01AH,022H	;ret	ret	jp	...	c8 - cb
	DEFB	003H,003H,001H,038H	;call	call	adc	rst	cc - cf
	DEFB	02BH,029H,01AH,026H	;ret	pop	jp	out	d0 - d3
	DEFB	003H,02AH,03EH,038H	;call	push	sub	rst	d4 - d7
	DEFB	02BH,011H,01AH,014H	;ret	exx	jp	in	d8 - db
	DEFB	003H,022H,039H,038H	;call	...	sbc	rst	dc - df
	DEFB	02BH,029H,01AH,010H	;ret	pop	jp	ex	e0 - e3
	DEFB	003H,02AH,002H,038H	;call	push	and	rst	e4 - e7
	DEFB	02BH,01AH,01AH,010H	;ret	jp	jp	ex	e8 - eb
	DEFB	003H,022H,03FH,038H	;call	...	xor	rst	ec - ef
	DEFB	02BH,029H,01AH,00DH	;ret	pop	jp	di	f0 - f3
	DEFB	003H,02AH,023H,038H	;call	push	or	rst	f4 - f7
	DEFB	02BH,01CH,01AH,00FH	;ret	ld	jp	ei	f8 - fb
	DEFB	003H,022H,005H,038H	;call	...	cp	rst	fc - ff

	DEFB	000H,001H,03EH,039H	;add	adc	sub	sbc
	DEFB	002H,03FH,023H,005H	;and	xor	or	cp


	DEFB	030H,035H,02EH,033H	;rlc	rrc	rl	rr
	DEFB	03BH,03CH,022H,03DH	;sla	sra	...	srl
	DEFB	022H,040H,041H,042H	;...	bit	res	set


	DEFB	022H,022H,022H,012H	;...	...	...	halt


	DEFB	01CH,01CH,01CH,01CH	;ld	ld	ld	ld
	DEFB	01CH,01CH,01CH,01CH	;ld	ld	ld	ld


;****************************************************************************
;*
;*			table of first operands
;*
;****************************************************************************

ZOPND1:
	DEFB	0FFH,00EH,08EH,00EH	;00 - 03
	DEFB	006H,006H,006H,0FFH	;04 - 07
	DEFB	00DH,018H,001H,00EH	;08 - 0b
	DEFB	007H,007H,007H,0FFH	;0c - 0f
	DEFB	01BH,00FH,08FH,00FH	;10 - 13
	DEFB	004H,004H,004H,0FFH	;14 - 17
	DEFB	01BH,018H,001H,00FH	;18 - 1b
	DEFB	005H,005H,005H,0FFH	;1c - 1f
	DEFB	013H,018H,09DH,018H	;20 - 23
	DEFB	002H,002H,002H,0FFH	;24 - 27
	DEFB	011H,018H,018H,018H	;28 - 2b
	DEFB	003H,003H,003H,0FFH	;2c - 2f
	DEFB	012H,009H,09DH,009H	;30 - 33
	DEFB	098H,098H,098H,0FFH	;34 - 37
	DEFB	007H,018H,001H,009H	;38 - 3b
	DEFB	001H,001H,001H,0FFH	;3c - 3f

	DEFB	006H,087H,000H,09DH	;40 - 43
	DEFB	0FFH,0FFH,01FH,00CH	;44 - 47
	DEFB	007H,087H,000H,00EH	;48 - 4b
	DEFB	0FFH,0FFH,0FFH,00BH	;4c - 4f
	DEFB	004H,087H,000H,09DH	;50 - 53
	DEFB	0FFH,0FFH,01FH,001H	;54 - 57
	DEFB	005H,087H,000H,00FH	;58 - 5b
	DEFB	0FFH,0FFH,01FH,001H	;5c - 5f
	DEFB	002H,087H,000H,0FFH	;60 - 63
	DEFB	0FFH,0FFH,0FFH,0FFH	;64 - 67
	DEFB	003H,087H,000H,0FFH	;68 - 6b
	DEFB	01CH,01DH,01DH,0FFH	;6c - 6f	defb  defw  ddb
	DEFB	01DH,01DH,000H,09DH	;70 - 73	org   equ
	DEFB	0FFH,0FFH,0FFH,0FFH	;74 - 77
	DEFB	001H,087H,000H,009H	;78 - 7b
	DEFB	0FFH,0FFH,0FFH,0FFH	;7c - 7f

	DEFB	0FFH,0FFH,0FFH,0FFH	;a0 - bf
	DEFB	0FFH,0FFH,0FFH,0FFH	;a4 - a7
	DEFB	0FFH,0FFH,0FFH,0FFH	;a8 - ab
	DEFB	0FFH,0FFH,0FFH,0FFH	;ac - af
	DEFB	0FFH,0FFH,0FFH,0FFH	;b0 - b3
	DEFB	0FFH,0FFH,0FFH,0FFH	;b4 - b7
	DEFB	0FFH,0FFH,0FFH,0FFH	;b8 - bb
	DEFB	0FFH,0FFH,00FH,0FFH	;bc - bf

	DEFB	013H,00EH,013H,01DH	;c0 - c3
	DEFB	013H,00EH,001H,01EH	;c4 - c7
	DEFB	011H,0FFH,011H,0FFH	;c8 - cb
	DEFB	011H,01DH,001H,01EH	;cc - cf
	DEFB	012H,00FH,012H,09CH	;d0 - d3
	DEFB	012H,00FH,01CH,01EH	;d4 - d7
	DEFB	007H,0FFH,007H,001H	;d8 - db
	DEFB	007H,0FFH,001H,01EH	;dc - df
	DEFB	015H,018H,015H,089H	;e0 - e3
	DEFB	015H,018H,01CH,01EH	;e4 - e7
	DEFB	014H,098H,014H,00FH	;e8 - eb
	DEFB	014H,0FFH,01CH,01EH	;ec - ef
	DEFB	00AH,00DH,00AH,0FFH	;f0 - f3
	DEFB	00AH,00DH,01CH,01EH	;f4 - f7
	DEFB	016H,009H,016H,0FFH	;f8 - fb
	DEFB	016H,0FFH,01CH,01EH	;fc - ff


	DEFB	001H,001H,019H,001H	;8 bit logic and arithmetic
	DEFB	019H,019H,019H,019H	;


	DEFB	019H,019H,019H,019H	;shift and rotate
	DEFB	019H,019H,019H,019H	;
	DEFB	0FFH,01FH,01FH,01FH	;bit - res - set

	DEFB	0FFH,0FFH,0FFH,0FFH	;filler

	DEFB	01AH,01AH,01AH,01AH	;8 bit load
	DEFB	01AH,01AH,01AH,01AH	;


;***********************************************************************
;*
;*			table of second	operands
;*
;***********************************************************************


ZOPND2:
	DEFB	0FFH,01DH,001H,0FFH	;00 - 03
	DEFB	0FFH,0FFH,01CH,0FFH	;04 - 07
	DEFB	00DH,00EH,08EH,0FFH	;08 - 0b
	DEFB	0FFH,0FFH,01CH,0FFH	;0c - 0f
	DEFB	0FFH,01DH,001H,0FFH	;10 - 13
	DEFB	0FFH,0FFH,01CH,0FFH	;14 - 17
	DEFB	0FFH,00FH,08FH,0FFH	;18 - 1b
	DEFB	0FFH,0FFH,01CH,0FFH	;1c - 1f
	DEFB	01BH,01DH,018H,0FFH	;20 - 23
	DEFB	0FFH,0FFH,01CH,0FFH	;24 - 27
	DEFB	01BH,018H,09DH,0FFH	;28 - 2b
	DEFB	0FFH,0FFH,01CH,0FFH	;2c - 2f
	DEFB	01BH,01DH,001H,0FFH	;30 - 33
	DEFB	0FFH,0FFH,01CH,0FFH	;34 - 37
	DEFB	01BH,009H,09DH,0FFH	;38 - 3b
	DEFB	0FFH,0FFH,01CH,0FFH	;3c - 3f


	DEFB	087H,006H,00EH,00EH	;40 - 43
	DEFB	0FFH,0FFH,0FFH,001H	;44 - 47
	DEFB	087H,007H,00EH,09DH	;48 - 4b
	DEFB	0FFH,0FFH,0FFH,001H	;4c - 4f
	DEFB	087H,004H,00FH,00FH	;50 - 53
	DEFB	0FFH,0FFH,0FFH,00CH	;54 - 57
	DEFB	087H,005H,00FH,09DH	;58 - 5b
	DEFB	0FFH,0FFH,0FFH,00BH	;5c - 5f
	DEFB	087H,002H,000H,0FFH	;60 - 63
	DEFB	0FFH,0FFH,0FFH,0FFH	;64 - 67
	DEFB	087H,003H,000H,0FFH	;68 - 6b
	DEFB	0FFH,0FFH,0FFH,0FFH	;6c - 6f
	DEFB	0FFH,0FFH,009H,009H	;70 - 73
	DEFB	0FFH,0FFH,0FFH,0FFH	;74 - 77
	DEFB	087H,001H,009H,09DH	;78 - 7b
	DEFB	0FFH,0FFH,0FFH,0FFH

	DEFB	0FFH,0FFH,0FFH,0FFH	;a0 - bf
	DEFB	0FFH,0FFH,0FFH,0FFH	;a4 - a7
	DEFB	0FFH,0FFH,0FFH,0FFH	;a8 - ab
	DEFB	0FFH,0FFH,0FFH,0FFH	;ac - af
	DEFB	0FFH,0FFH,0FFH,0FFH	;b0 - b3
	DEFB	0FFH,0FFH,0FFH,0FFH	;b4 - b7
	DEFB	0FFH,0FFH,0FFH,0FFH	;b8 - bb
	DEFB	0FFH,0FFH,00FH,0FFH	;bc - bf

	DEFB	0FFH,0FFH,01DH,0FFH	;c0 - c3
	DEFB	01DH,0FFH,01CH,0FFH	;c4 - c7
	DEFB	0FFH,0FFH,01DH,0FFH	;c8 - cb
	DEFB	01DH,0FFH,01CH,0FFH	;cc - cf
	DEFB	0FFH,0FFH,01DH,001H	;d0 - d3
	DEFB	01DH,0FFH,0FFH,0FFH	;d4 - d7
	DEFB	0FFH,0FFH,01DH,09CH	;d8 - db
	DEFB	01DH,0FFH,01CH,0FFH	;dc - df
	DEFB	0FFH,0FFH,01DH,018H	;e0 - e3
	DEFB	01DH,0FFH,0FFH,0FFH	;e4 - e7
	DEFB	0FFH,0FFH,01DH,000H	;e8 - eb
	DEFB	01DH,0FFH,0FFH,0FFH	;ec - ef
	DEFB	0FFH,0FFH,01DH,0FFH	;f0 - f3
	DEFB	01DH,0FFH,0FFH,0FFH	;f4 - f7
	DEFB	0FFH,018H,01DH,0FFH	;f8 - fb
	DEFB	01DH,0FFH,0FFH,0FFH	;fc - ff

	DEFB	019H,019H,0FFH,019H	;8 bit logic and arithmetic
	DEFB	0FFH,0FFH,0FFH,0FFH	;

	DEFB	0FFH,0FFH,0FFH,0FFH	;shift and rotate
	DEFB	0FFH,0FFH,0FFH,0FFH	;
	DEFB	0FFH,019H,019H,019H	;bit - res - set

	DEFB	0FFH,0FFH,0FFH,0FFH

	DEFB	019H,019H,019H,019H	;8 bit load
	DEFB	019H,019H,019H,019H


;***********************************************************************
;*
;*			table of op code names
;*
;***********************************************************************


ZOPCNM:
	DEFB	'ADD ADC AND CALL'
	DEFB	'CCF CP  CPD CPDR'
	DEFB	'CPI CPIRCPL DAA '
	DEFB	'DEC DI  DJNZEI  '
	DEFB	'EX  EXX HALTIM  '
	DEFB	'IN  INC IND INDR'
	DEFB	'INI INIRJP  JR  '
	DEFB	'LD  LDD LDDRLDI '
	DEFB	'LDIRNEG NOP OR  '
	DEFB	'OTDROTIROUT OUTD'
	DEFB	'OUTIPOP PUSHRET '
	DEFB	'RETIRETNRL  RLA '
	DEFB	'RLC RLCARLD RR  '
	DEFB	'RRA RRC RRCARRD '
	DEFB	'RST SBC SCF SLA '
	DEFB	'SRA SRL SUB XOR '
	DEFB	'BIT RES SET ORG '
	DEFB	'DEFBDEFWDDB EQU '




OP1000:
	DEFB	 0FDH,0DDH,0EDH,0CBH



PSWBIT:	DEFB	10001000B		;minus
	DEFB	10000000B		;positive
	DEFB	00001100B		;even parity
	DEFB	00000100B		;odd parity
	DEFB	01001000B		;zero
	DEFB	01000000B		;not zero
	DEFB	00001001B		;carry
	DEFB	00000001B		;no carry

PSWMAP:	DEFB	18,07,19,17,21,20,10,22
PSWCNT	EQU	$-PSWMAP


REGMAP:
	DEFB	87H,01H,07H,06H,05H,04H
	DEFB	03H,02H,95H,93H,91H,18H
	DEFB	19H,81H,83H,85H,97H

REGPTR:
	DEFB	0DH,0EH,0FH,00H
	DEFB	8DH,8EH,8FH,80H
	DEFB	0AH,09H,08H,10H

SIOTBL:	DEFB	0F5H,0F7H

SYMFLG:	DEFB	0FFH		;symbol	table flag   00	- table	present
				;		     ff	- no table

BSIZ:				;dump block size storage
BSIZLO:	DEFB	0		;     lo order
BSIZHI:	DEFB	1		;     hi order
BLKPTR:	DEFW	100H		;dump block address

LOADB:	DEFW    100H		;z8e load bias for lldr command
LOADN:	DEFW	00		;end of load address

ASMBPC:				;next pc location for assembly
ZASMPC:	DEFW	100H		;next pc location for disassemble
				;default at load time: start of	tpa
ZASMFL:	DEFW	00		;first disassembled address on jdbg screen


FROM:
OPRN01:
RLBIAS:
LINES:
EXAMPT:
ENDW:
ZASMNX:	DEFB	0		;address of next instruction to	disassemble
OPRX01:	DEFB	0
BIAS:
BIASLO:
ZASMCT:	DEFB	0		;disassembly count
BIASHI:
OPRN02:	DEFB	0
OPRX02:
ZASMWT:	DEFW	0		;disassembly count - working tally
OPNFLG:	DEFB	0		;00 - operand 1   ff - operand 2   zasm
				;and input character storage for interactive
				;disassembly
QUOFLG:	DEFB	0
WFLAG:	DEFB	0FFH		;trace subroutine flag:	nz - trace subs
				;			 z - no	trace

NSTEP:
NSTEPL:	DEFB	0
NSTEPH:	DEFB	0

SBPS:	DEFB	0		;number	of step	breakpoints
BPS:	DEFB	0		;number	of normal breakpoints

ZMFLAG:	DEFB	0
ZASMF:	DEFB	0
EXECBF:				;execute buffer	for relocated code
JLINES:
PARENF:
NUMENT:	DEFB	0		;number	of digits entered
DELIM:	DEFB	0		;argument delimeter character
	DEFB	0
BASE10:	DEFB	0
JMP2JP:	DEFB	0
JMP2:	DEFB	0
DWRITE:
CFLAG:	DEFB	0

IKEY:
ZASMKV:
SJMP:	DEFB	0
MEXP:
JMPLO:	DEFB	0
STRNGF:
JMPHI:	DEFB	0
TIMER:
FIRST:	DEFB	0
REGTRM:	DEFB	0
TRMNTR: DEFB	0
ISYMPT:	DEFW	0

JROPND:
PASS2:	DEFW	0

FNDSYM:	DEFW	0

MAXLEN:
	DEFW	14

MAXLIN:	DEFW	62

FWNDOW:	DEFB	00

NLMASK:	DEFB	00

CASE:
	DEFB	000H		;flag to indicate case of output
	DEFB	0FFH		;flag to indicate case of output
				;nz - lower   z - upper

JSTEPF:	DEFB	0FFH		;00 -   screen is intact, if user wants j
				;       single step no need to repaint screen,
				;       just move arrow.
				;01   - user wants single-step j command
				;else - j screen corrupted by non-j command

LASTRO:	DEFB	03

ROWB4X:
	DEFB	0

MXYCP:
    	DEFB	1,ESC

XYROW:	DEFB	0
XYCOL:	DEFB	0

ROW:
	DEFB	' '			;bias for most other terminals
COLUMN:
	DEFB	' '

WNWTAB:	DEFW	0
WNWSIZ:	DEFW	0

PORT:	DEFW	0

BRKTBL:	DEFS	(MAXBP+2)*3
PSCTBL:	DEFS	MAXBP*2

BDOSAD:	DEFW	0

REGCON:
AFREG:
FREG:	DEFB	00
	DEFB	00
BCREG:	DEFW	00
DEREG:	DEFW	00
HLREG:	DEFW	00
AFPREG:	DEFW	00
BCPREG:	DEFW	00
DEPREG:	DEFW	00
HLPREG:	DEFW	00
PCREG:
PCREGL:	DEFB	00
PCREGH:	DEFB	01
SPREG:	DEFW	00
IXREG:	DEFW	00
IYREG:	DEFW	00

REGSIZ	EQU	$-REGCON

RREG:	DEFB	00
IREG:	DEFB	00


FSTART:	DEFW	0
ARGBC:	DEFW	0
ARGBPT:	DEFW	ARGBF

REGSAV	EQU	$		;storage for register contents in between bps
				;while jdbg is in control

WINDOW	EQU	REGSAV+REGSIZ	;memory window save area

ARGBSZ	EQU	62

ARGBF:	DEFS	ARGBSZ

FCB	EQU     ARGBF+ARGBSZ-36 ;cp/m file control block
FCBNAM	EQU	FCB+1		;start of file name in fcb
FCBTYP	EQU	FCBNAM+8	;start of file type in fcb
FCBEXT	EQU	FCBTYP+3	;current extent	number
NFCB	EQU	$		;last byte of fcb plus one

GPBSIZ	EQU	164		;size of general purpose buffer

SYMBUF:
OBJBUF:				;object	code buffer
	DEFS	GPBSIZ
INBFSZ	EQU	GPBSIZ/2
INBFMX	EQU	OBJBUF+4	;input buffer -	max byte count storage
INBFNC	EQU	INBFMX+1	;	      -	number chars read in
INBF	EQU	INBFNC+1	;	      -	starting address
INBFL	EQU	INBFSZ-1	;	      -	last relative position
NINBF	EQU	INBF+INBFL	;	      -	address	of last	char

PRSBFZ	EQU	GPBSIZ/2
PRSBF	EQU	INBF+INBFSZ	;parse buffer -	starting address
LPRSBF	EQU	PRSBF+PRSBFZ-1	;	      -	last char of parse buf
NPRSBF	EQU	LPRSBF+1	;	      -	end address plus one

NZASM	EQU	$		;end of disassembly buffer
ZASMBF	EQU	NZASM-128	;start of disassembly buffer

FILLER:
	DEFS	FILLBEGIN + $3000 - FILLER - 1
FILLEND:
	DEFB	0

	END
