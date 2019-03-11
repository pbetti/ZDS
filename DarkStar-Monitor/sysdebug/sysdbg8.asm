;------------------------------------------------------------------------------
;
; include darkstar.equ
;

true	equ	-1
false	equ	0

; The following equate setup an incarnation that will run without CP/M support
; It is hardware dependent (since calls are made directly to the monitor ROM)
; Here it is tailored for my Z80darkStar. Follow the STLONE symbol to find
; were customize the calls...



maxbp	equ	16		;Number	of breakpoints configured
bs	equ	08h		;ASCII 	backspace
tab	equ	09h		;	tab
lf	equ	0ah		;	line feed
formf	equ	0ch		;	form feed
cr	equ	0dh		;	carriage return
esc	equ	1bh		;       escape
ctlx	equ	$7f		;	control	x - delete line
ctlc	equ	'C' and	1fh	;	control	c - warm boot
eof	equ	'Z' and	1fh	;	control	z - logical eof
quote	equ	27h		;	quote
tilde	equ	7eh		;	tilde
del	equ	7fh		;	del

inop	equ	000		;Z80 instructions
ijp	equ	0c3h
irt	equ	0c9h
rst38	equ	0cfh		; uses RST 8
rstvec	equ	08h		;Default (but patchable) breakpoint vector
iobuf	equ	80h		;Disk read buffer for symbol loading
z8eorg	equ	$9000
z8esp	equ	z8eorg - 2
cbank	equ	000ch		; byte: current bank
hmemp	equ	000bh		; byte: highest ram page

;---------------------------------------------------------

	org	z8eorg
; fillbegin:
	ld	(hlreg),hl	;save user hl
	pop	hl		;pop our call from stack
	ld	(spreg),sp	;save user sp
	ld	(pcreg),hl	;save user pc
	ld	(dereg),de	;save user de
	ld	(bcreg),bc	;save user bc
	push	af
	pop	hl		;user accumulator and flag to hl
	ld	(afreg),hl	;save user af
	ld	a,i
	ld	h,a		;save user i reg
	ld	a,r
	ld	l,a		;save user r reg
	ld	(rreg),hl
	ex	af,af'          ;Bank In Prime Regs
	exx
	ld	(hlpreg),hl	;save
	ld	(depreg),de
	ld	(bcpreg),bc
	push	af
	pop	hl
	ld	(afpreg),hl
	ld	(ixreg),ix	;save user ix
	ld	(iyreg),iy	;save user iy

	ld	a,(iniok)	;check for init needed
	or	a
	jp	z,z8e
	xor	a		;already inited
	ld	(iniok),a
	jr	begin


mbannr:	defb	$0c
	defb	cr,lf
	defb	'Z80Darkstar (Z80NE) Monitor Debugger.',cr,lf
	defb	'(c) 2018 Piergiorgio Betti v.6.0.0'
	defb	cr,lf,lf
	defb	0

begin:
	ld	(spreg),sp	;save user sp

	ld	de,mbannr	;Dispense with formalities
	call	print
	ld	de,mbnk
	call	print
	ld	a,(cbank)
	sub	0bbh
	call	outhex
	call	crlf


; Do config based on max length of symbol names

	ld	a,(maxlen)	;Check max symbol length
	inc	a		;Create mask
	cp	15
	ld	b,a		;B - maxlen mask - 15
	ld	a,62		;A - maxlin disassembly line length (62)
	ld	c,68		;C - column to display first byte of memory
				;    window for J command
	ld	d,3		;D - bytes per line of memory window display
	jp	z,nint00	;Z - max symbol length is 14

				;If not 14 - use default values
	ld	b,7		;B - maxlen mask -  7
	ld	a,30		;A - maxlin disassembly line length (30)
	ld	c,56		;C - column to display first byte of memory
	ld	d,7		;    window for J command
nint00:
; 	call	inchar
	ld	(maxlin),a
	ld	a,b
	ld	(maxlen),a
	ld	a,c
	ld	(fwndow),a
	ld	a,d
	ld	(nlmask),a

	ld	a,irt		;Initialize where L80 fears to tread
	ld	(rstvec),a	;Init trap to breakpoint handler
	ld	hl,bphn		;entry point to	breakpoint handler
	ld	(rstvec+1),hl	;Init RST 38h trap location

	ld	hl,z8esp-128
	ld	(bdosad),hl

; 	LD	HL,Z8ESP-512
; 	LD	(SPREG),HL

	jp	z8e            ;Hi-ho, hi-ho to the loader we must go

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


	org	($+255) and 0ff00h

z8e:
	ld	sp,z8esp

z8ecmd:
	ld 	a,ijp
	ld	(rstvec),a
	ld	hl,z8e
	push	hl

	ld	de,prompt	;display prompt (asterisk)
	call	nprint
	ld	hl,jstepf	;full screen debugging in effect?
	ld	a,(hl)
	and	a
	jr	nz,z8e10	;nz - no

	ld	c,10
	call	spaces		;If this was jdbg clear command line residue
	ld	a,$0b		; cursor @ home
	call	ttyo
	ld	a,(prompt)
	call	ttyo

z8e10:
	call	inchar		;Read in command character
; +++ jrs 3.5.6 ++++++++++++++++++
	cp	cr		;+Check for empty command line
	jr	nz,z8e16	;+Something there - process it
	ld	a,(lcmd)	;+Nothing - see if S or J was last command
	cp	'J'		;+Repeat 'J' command?
	jp	z,jdbg00	;+
	ld	hl,1		;+
	cp	'S'		;+Repeat 'S' command?
	jp	z,step40	;+
	ld	a,cr		;+
z8e16:				;+
; ++++++++++++++++++++++++++++++++
	call	ixlt		;Translate to upper case for compare
	ld	(lcmd),a
	cp	'J'		;If command is anything but j then indicate
				;that screen is corrupted.  at next invokation
				;jdbg will know to repaint the screen.
	jr	z,z8e20
	ld	(jstepf),a	;Full screen flag nz - full screen debugging
				;in progress


z8e20:	ld	bc,ncmd		;total number of commands
	ld	hl,cmd		;table of ascii	command	characters
	cpir
	jp	nz,exxx		;command letter not found in table
	ld	hl,jtcmd	;command jump table
	add	hl,bc
	add	hl,bc		;index into table
	ld	e,(hl)		;lo order command processing routine
	inc	hl
	ld	d,(hl)		;upper address
	ld	c,3
	call	spaces		;print spaces regardless
	ex	de,hl		;hl - address of command processing routine
	jp	(hl)

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

bphn:	ld	(hlreg),hl	;save user hl
	pop	hl		;pop breakpoint	pc from	stack
	ld	(spreg),sp	;save user sp
	ld	sp,z8esp	;switch	to our stack
	dec	hl		;point to location of rst instruction
	ld	(pcreg),hl	;save user pc
	ld	(dereg),de	;save user de
	ld	(bcreg),bc	;save user bc
	push	af
	pop	hl		;user accumulator and flag to hl
	ld	(afreg),hl	;save user af
	ld	a,i
	ld	h,a		;save user i reg
	ld	a,r
	ld	l,a		;save user r reg
	ld	(rreg),hl
	ex	af,af'          ;Bank In Prime Regs
	exx
	ld	(hlpreg),hl	;save
	ld	(depreg),de
	ld	(bcpreg),bc
	push	af
	pop	hl
	ld	(afpreg),hl
	ld	(ixreg),ix	;save user ix
	ld	(iyreg),iy	;save user iy
	ld	a,(bps)
	and	a		;check for zero	bp count
	jp	z,bpxxx		;error - no bps	set
	ld	b,a		;b - number of breakpoints
	ld	hl,brktbl	;breakpoint storage table
	xor	a
	ld	c,a		;init breakpoint found flag
bphn10:	ld	e,(hl)
	inc	hl
	ld	d,(hl)		;de - breakpoint address
	inc	hl
	ld	a,(hl)		;saved contents	of breakpoint address
	inc	hl
	ld	(de),a		;replace rst 38	with actual data
	ld	a,(pcregl)	;user pc - lo order
	xor	e
	ld	e,a		;versus	breakpoint address in table
	ld	a,(pcregh)
	xor	d		;check hi order
	or	e
	jr	nz,bphn20	;no match - check next entry in	table
	ld	c,b		;pc found in table set c reg nz
bphn20:	djnz	bphn10		;restore all user data
	ld	hl,sbps		;fetch number of step bps (0-2)
	ld	b,(hl)
	xor	a
	ld	(hl),a		;clear regardless
	or	c		;test bp found flag
	jp	z,bpxxx		;z - bp	not in table
	inc	hl		;point to bp count
	ld	d,(hl)		;d - bp count
	dec	b
	jp	m,bphn30	;m - this was user bp not step or jdbg
	ld	a,(hl)
	sub	b		;subtract number of step bps from bp count
	ld	(hl),a		;restore bp count
	ld	a,(lcmd)	;what command got us here?
	cp	'S'		;step?
	jr	z,bphn90	;step command - check count

				;now we know we have jdbg in progress.  need
				;to check for user specified bp at the same
				;address. if we find one stop trace.
	ld	a,b		;number of step bps to accumulator (1 or 2).

	sub	c		;compare number of step bps with the offset
				;into the bp table where the current bp was
				;found.  since step bps are always at the end
				;of the table we can determine how bp was set.

 	jp	nc,jdbg30	;nc - we are at end of table so more tracing

bphn30:	ld	a,c
	neg
	add	a,d		;create index into pass count table
	add	a,a
	ld	hl,psctbl	;pass count table
	add	a,l
	ld	l,a
	jr	nc,bphn35
	inc	h
bphn35:	ld	e,(hl)
	inc	hl
	ld	d,(hl)		;de - pass count
	ld	a,d
	or	e
	jr	z,bphn50	;no count in effect
	dec	de
	ld	(hl),d
	dec	hl
	ld	(hl),e		;restored updated count
	ld	a,d
	or	e		;did it	just go	zero?
	jr	z,bphn50	;count just expired
	ld	a,b		;pass count not zero - go or jdbg?
	and	a
	jp	p,jdbg30	;if step flag p we had step bps
	ld	hl,(pcreg)
	jp	g100		;continue go command
bphn50:	or	b		;test if we had step bps
	jp	m,bphn60	;this was go - print bp message
	ld	a,'X'
	ld	(lcmd),a	;clear command letter so xreg disassembles
	call	home		;home cursor
	call	xreg
	ld	b,22		;cursor on penultimate line
	ld	c,00
	call	xycp

bphn60:	ld	de,bpmsg	;print *bp*
	call	print		;print message pointed to by de
	ld	hl,(pcreg)
	call	outadr		;display breakpoint address
	ex	de,hl
	call	fadr		;attempt to find label at this address
	ex	de,hl		;de - bp address
	jp	nz,z8e		;nz - no label found
	ld	a,(maxlen)
	dec	a
	ld	c,a		;c - max size of label
	call	printb
	jp	z8e
bphn90:	call	xreg		;display all registers
	ld	hl,(nstep)	;fetch trace count
	dec	hl
	ld	a,l
	or	h
	jp	z,z8e		;count expired - prompt	for command
	call	ttyq		;test for abort	trace
	cp	cr
	jp	z,z8e
	call	crlf		;
	jp	step40		;continue trace


bpxxx:	ld	de,bpemsg
	call	print
	ld	hl,(pcreg)
	call	outadr
	jp	z8e


exxx:	ex	de,hl
	ld	de,emxxx
	call	print
	ex	de,hl
	ret

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

jdbg:
	call	iedtbc		;get command line
	jp	p,jdbg02	;p - have input

jdbg00:
	ld	hl,lastro
	ld	b,(hl)		;row position of arrow on screen
	ld	c,18		;column
	call	xycp
	ld	c,2
	call	spaces
	ld	b,17h
	ld	c,00
	call	xycp
	ld	hl,jstepf
	ld	a,(hl)
	ld	(hl),1
	and	a
	jp	z,jdbg90	;J was last means screen intact - just move
				;arrow, else fall thru and repaint screen.
				;Indicate single step
jdbg01:				;+ eg 3.3.6
	ld	a,10
	jr	jdbg10		;init timer

jdbg02:	ld	a,(hl)		;check first char of input
	cp	'#'		;+ eg 3.3.6
	jr	nz,jdbg2a	;+ Skip if not repaint request
	ld	hl,jstepf	;+
	ld	(hl),1		;+ Signal repaint request
	jr	jdbg01		;+
jdbg2a:				;+
	ex	de,hl		;de - save input buffer	address
	ld	hl,wflag	;wflag tells us	whether	to trace subroutines
				;or walk around	them
	ld	(hl),0ffh	;conditionally assume trace all
	sub	'/'		;slash means don't trace any
	jr	z,jdbg03	;
	add	a,'/'-'*'	;check for star	- no trace of bdos subs
	jr	nz,jdbg05
	inc	a		;set flag one to indicate no trace of subs
				;at address < 100h (bdos calls)
jdbg03:	ld	(hl),a		;set wflag
	xor	a		;if slash or space replace with	null in	inbf
				;so parser will	ignore
	ld	(de),a
jdbg05:	call	iarg		;now evaluate address
	jr	z,jdbg08	;z - no error
	ld	a,(inbfnc)	;check number of characters
	dec	a		;check for just / or just *
	jr	z,jdbg00	;treat as single step
	ld	(jstepf),a	;indicate screen corrupted
	jp	exxx		;error -
jdbg08:	ld	(pcreg),hl	;save address at which to start	tracing
	and	a		;check delimter
	ld	a,10		;no delimeter use default timer value
	jr	z,jdbg10
	call	iarg		;check if user wants non-default timer
	ld	a,10
	jr	nz,jdbg10	;error - use default
	ld	a,l		;a - timer value as entered by user
jdbg10:	ld	(timer),a
	ld	a,formf
	call	ttyo
jdbg15:
	call	rgdisp		;display current user regs
	call	zwnw		;display disassembled window
	ld	a,(wnwsiz)
	and	a		;test if window being displayed
	jr	z,jdbg28
	ld	de,window	;save user specified memory block til next bp
	ld	hl,(wnwtab)	;start of memory window address
	ld	bc,3
jdbg20: ld	a,(fwndow)	;position cursor starting at column
	sub	6
	call	curs
       	call	outadr		;display address of memory window
jdbg25:	ld	a,(fwndow)
	call	curs		;column position on screen of memory window
				;is (rel pos * 3) + (fwndow)
	ld	a,(hl)		;display this byte

	ld	(de),a		;save this byte in window between bps
	call	outhex
	inc	b		;move and display user specifed number
                                ;of bytes (wnwsiz)
	ld	a,(wnwsiz)
	sub	b
	jr	z,jdbg28
	inc	hl
	inc	de
	ld	a,(nlmask)	;check for new line time
	and	b
	jr	nz,jdbg25	;not end of line - display next byte else...
	jr	jdbg20		;...display address first
jdbg28:	ld	a,3		;point to very first instruction
	jp	jdbg75


				;breakpoint handler jumps here for full
				;screen single step
jdbg30:	ld  	c,3
	call	spaces		;remove => from screen
	ld	b,c		;(c=0 after spaces executes)
	ld	hl,regcon	;new contents of registers following bp
	ld	de,regsav	;old prior to bp
jdbg35:	ld	a,(de)		;compare old vs new
	cp	(hl)
	inc	hl
	inc	de
	jr	nz,jdbg40	;different - display new
	ld	a,(de)		;check hi order byte of this reg pair
	cp	(hl)
	jr	z,jdbg45	;z - hi and lo bytes the same so try next reg
jdbg40:
	push	bc		;+save register number
	ld	c,b		;+move it to c while we build line number
	ld	b,0		;+assume first line for now
	ld	a,7		;+regs-per-line mask
	cp	c		;+generate carry if second line
	rl	b		;+shift carry into line number
	and	c		;+generate line-relative register number
	ld	c,a		;+col = reg * 9 + 3 if non-prime
	add	a,a		;+ *2
	add	a,a		;+ *4
	add	a,a		;+ *8
	add	a,c		;+ *9
	bit	2,c		;+is it a prime (alternate) register?
	jr	z,jdbg42	;+skip if not
	add	a,c		;+*10
	sub	3		;+col = reg * 10 if prime
jdbg42:
	add	a,3		;+
	ld	c,a		;+
	call	xycp		;+
	pop	bc		;+ added 29 bytes

	ld	a,(hl)		;display upper byte of reg contents
	call	outhex
	dec	hl		;rewind to pick up lo order byte
	ld	a,(hl)
	inc	hl
	call	outhex		;display lo order
jdbg45:	inc	hl
	inc	de
	inc	b
	ld	a,regsiz/2	;number of reg pairs to display
	sub	b
	jr	nz,jdbg35
	call	rspace
	ld	b,1
	ld	c,36
	call	xycp

	ld	b,0
	call	pswdsp		;now display flag reg mnemonics

	ld	a,(wnwsiz)	;check window size
	and	a
	jr	z,jdbg60	;z - no memory window in effect
	ld	hl,(wnwtab)	;hl - address of start of window
	ld	bc,03
	ld	de,window	;old contents of window stored here
jdbg50:	ld	a,(de)		;compare old vs new
	cp	(hl)
	jr	z,jdbg55	;same - no reason to display
	ld	a,(fwndow)	;col position of byte is (rel pos * 3) + 50
	call	curs
	ld	a,(hl)		;display byte

	ld	(de),a		;we only need to move byte if it changed

	call	outhex
jdbg55:	inc	b		;bump memory window byte count
	ld	a,(wnwsiz)  	;max size
	inc	hl
	inc	de
	sub	b
	jr	nz,jdbg50	;loop until entire window examined

jdbg60:	ld	a,18		;init count of disassembled instructions
	ld	(jlines),a
	ld	de,(zasmfl)	;address of first disassembled instruction
				;on screen
jdbg65:	ld	hl,(pcreg)
	and	a
	sbc	hl,de
	jr	z,jdbg70	;found - pc exists somewhere on screen
	call	zlen00		;compute length	of this	instruction
	ld	b,0
	ex	de,hl		;hl - address on disassembled instruction
	add	hl,bc		;add length to compute address of next inline
				;instruction for display
	ex	de,hl		;de - restore new istruction pointer
	ld	hl,jlines
	dec	(hl)		;dec screen line count
	jr	nz,jdbg65
	ld	hl,(pcreg)	;pc not	on screen - so current pc will be new
				;first pc on screen
	ld	(zasmfl),hl
	ld	bc,0300h	;cursor	row 4 -	col 1
	call	xycp
	call	zwnw		;instruction not on screen so paint a new
				;screen	starting at current pc
	ld	a,3		;disassembled instructions start on line 4
	jr	jdbg75
jdbg70:	ld	a,(jlines)
	neg
	add	a,21		;a - screen row	on which to position cursor
jdbg75:	ld	(lastro),a	;save position of arrow
	ld	b,a		;pass to xycp
	ld	c,18		;pass column
	call	xycp		;position cursor routine
	ld	de,mrrow
	call	print
	ld	a,(lastro)	;xy positioning added after '=>' as
				;some systems have a destructive bs
	ld	c,17		;new cursor loc
	call	xycp		;put it there
	ld	a,(jstepf)
	dec	a		;test if single stepping
	jp	z,jdbg95
	call	ttyq
	ld	hl,timer
	ld	b,(hl)
	jr	z,jdbg80
	cp	'0'
	jr	c,jdbg78
	cp	3ah
	jr	nc,jdbg95
	and	0fh
	ld	(hl),a
	ld	b,a
	jr	jdbg80
jdbg78:	cp	cr		;carriage return ends command
	jr	z,jdbg95

jdbg80:	call	clok

jdbg90:	ld	de,regsav	;move current reg contents to save area
	ld	hl,regcon
	ld	bc,regsiz
	ldir
	jp	step40


				;user requested abort from console
jdbg95: ld	b,22		;position cursor on line 23 for prompt
	ld	c,0
	call	xycp
	xor	a
	ld	(jstepf),a	;indicate we have full screen of data
	jp	z8e		;to z8e command processor



zwnw:				;display disassembly window
	ld	a,18		;number of instructions to disassemble
zwnw05:	ld	hl,(pcreg)
	ld	(zasmfl),hl	;save pc of first line
zwnw10:	ld	(jlines),a
	ld	(zasmpc),hl	;save here as well
	ld	de,zasmbf+96	;disassemble in upper portion of buffer to
				;prevent overlap with big memory windows.
				;otherwise, every time we disassemble a new
				;screen we have to repaint the window.

	call	zasm10		;disassemble first instruction
	ld	a,30		;test line length
	cp	c
	jr	z,zwnw20
	ld	c,42
zwnw20:	call	printb
	call	crlf
	ld	hl,(zasmnx)	;hl - next address to disassemble
	ld	a,(jlines)
	dec	a
	jr	nz,zwnw10
	ld	b,3		;position cursor next to next instruction
				;to execute which is the first one on the
				;screen - line 4  col 20
	ld	c,20
	call	xycp
	ret


				;display regs at top of screen:
rgdisp:	call	home		;home cursor
	call	xreg		;display regs
	call	pswdsp		;display flag reg
	jp	crlf



curs:	push	bc		;This routine has been simplified and shortened
	push	de		;by 19 bytes because it is no longer used for
	push	hl		;register display positioning.  jrs 20/4/87
	ld	d,a
	ld	e,c		;save base row address
;	cp	3		;test if reg or memory window (3 is reg)
;	ld	a,7
;	jr	z,curs00	;z - regs are eight per line (first line)

	ld	a,(nlmask)
curs00:	and	b		;item number mod lnmask is the relative pos of
	ld	c,a		;reg contents or memory data byte
	add	a,a		;
	add	a,c
	ld	c,a		;c - rel pos times three

;	ld	a,d		;if base column address is < 50 then this is
				;reg display
;	sub	3
;	ld	h,a
;	ld	a,c
;	jr	nz,curs20	;nz - not reg display - must be memory
;	add	a,a		;so multiply times three again
;	add	a,c		;times 9 in all for register display

curs20:	add	a,d		;add in base
	ld	c,a		;c - absolute col number
;	xor	a		;test if this is reg or memory window display
;	or	h
;	jr	z,curs30	;z - this is register display
	ld	a,(fwndow)
	cp	68		;14-char symbols in effect?
	jp	z,curs40
curs30:	srl	b
curs40:	ld	a,0fch
	and	b		;now compute row number
	rrca
	rrca
	add	a,e		;base row address
	ld	b,a		;b - absolute row number
	call	xycp		;convert row and column to xy cursor address
	pop	hl
	pop	de
	pop	bc
	ret



clok:
	ld	d,50  		;idle loop - decrement to 0 and reload
	ld	e,00
	dec	b		;user specified the loop counter
	ret	m
clok10:	dec	de
	ld	a,e
	or	d
	jr	nz,clok10
	jr	clok


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

exam:	call	ilin
	jp	nz,exxx
	ex	de,hl
exam00:	call	newlin
	ld	a,(de)		;fetch byte to display regardless
	call	outbyt
	call	rbyte
	jr	nz,exam00 	;nz - don't replace memory contents
	cp	'.'
	jr	nz,exam10
	ld	a,(inbfnc)
	dec	a
	ret	z
exam10:	ld	hl,argbc	;byte count to c
	ld	c,(hl)
	ld	b,0
	ld	(exampt),de
	ld	hl,argbf	;start of evaluated input
	ldir
	ld	a,(trmntr)
	cp	cr
	jr	z,exam00
	ld	de,(exampt)
	jr	exam00

hsym:	ret
usym:	ret


bank:	call	iedtbc		;Solicit input
	jp	p,bank00	;p - input present
	jp	exxx
bank00:	call	iarg		;Read in next arg (starting address)
	jp	nz,exxx		;Invalid starting address
	ex	de,hl		;DE - physycal page
	ld	a,e
	push	af
	or	a		; 0 -> 7
	jr	nz,bank01
	ld	e,8
bank01:
; 	cp	1
; 	jp	c,exxx
	cp	9
	jp	nc,exxx
	ld	b,0f0h
	ld	a,(hmemp)		; calculate destination bank
	sub	a,e			; A phisical bank
	ld	c,20h			; MMU port
	out	(c),a			; bank switch

	ret


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

dump:	call	iedtbc		;Solicit input
	jp	p,dump00	;p - input present
	ld	de,(bsiz)	;No input means	use previous block size
	ld	hl,(blkptr)	;   ...	and address
	jr	dump30
dump00:	call	iarg		;Read in next arg (starting address)
	jp	nz,exxx		;Invalid starting address
	ex	de,hl		;DE - starting address to dump
	call	iarg		;Next arg (block size)
	jr	z,dump15	;Z - no	errors
	ld	hl,000		;Default to block size of 256
	jr	dump20
dump15:	xor	a
	or	h		;Test for block	size or	ending address
	jr	z,dump20	;Less than 256 must be block size
	sbc	hl,de		;Compute size
	jp	c,exxx
dump20:	ld	a,l
	or	h
	jr	nz,dump25
	inc	h
dump25:	ld	(bsiz),hl
	ex	de,hl		;DE - block size   HL -	memory pointer
dump30:	ld	b,16		;Init bytes-per-line count
	call	ttyq
	cp	cr
	ret	z
	call	crlf		;Display current address on new line
	call	outadr
	ld	c,2
	call	spaces		;Hex display starts two	spaces right
dump40:	dec	b		;Decrement column count
	ld	a,(hl)
	inc	hl
	call	othxsp		;Display memory	in hex
	inc	c		;Tally of hex bytes displayed
	dec	de		;Decrement block count
	ld	a,d
	or	e		;Test for end of block
	jr	z,dump50	;Z - end of block
	xor	a
	or	b		;End of	line?
	jr	nz,dump40	;Not end of line - dump	more in	hex
	jr	dump60
dump50:	ld	a,(bsizhi)
	and	a		;Block size greater than 256?
	jr	nz,dump55	;NZ - greater
	ld	a,(bsizlo)
	and	0f0h		;Block size less than 16?
	jr	z,dump60	;Z - less
dump55:	ld	a,(bsizlo)
	and	0fh		;Block size multiple of	16?
	jr	z,dump60	;Multiple of 16
	neg
	add	a,16
	ld	b,a
	add	a,a
	add	a,b
dump60:	add	a,3		;Plus three - begin ASCII display
	ld	b,a		;Pad line until	ASCII display area
dump70:	call	rspace
	djnz	dump70
	sbc	hl,bc		;Rewind	memory point by	like amount
dump80:	ld	a,(hl)		;Start ASCII display
	inc	hl
	call	asci
	dec	c
	jr	nz,dump80
	call	ttyq		;CR aborts command
	cp	cr
	jp	z,z8e
	ld	a,d		;Test for block	size tally expired
	or	e
	jr	nz,dump30
	ld	de,(bsiz)	;Reinit	block size
	call	ttyi		;Query user for	more
	cp	cr
; Next two lines replaced by inverted test - 27 Dec 88 - jrs - V 3.5.1
;	call	z,crlf
;	jr	z,dump30	;not cr	- next block
;----				(Comment on last line is wrong anyway!)
	call	nz,crlf		;Not cr - next block
	jr	nz,dump30
;----
	ld	(blkptr),hl
	ret			;end command

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

rgst:	ld	c,' '		;get edited input
	ld	b,inbfsz
	call	iedt
	ret	m
	ld	a,(trmntr)
	cp	' '
	call	z,bksp
	call	prsr
	or	b		;unbalanced quotes (prime reg?)
	jp	p,rgst00
	and	7fh
	cp	3
	jr	nz,rgst25
	dec	hl
	ld	a,(hl)
	sub	quote
	jr	nz,rgst25
	ld	(hl),a
rgst00:	ld	a,(inbfnc)	;number	of characters in buffer
	cp	4
	jr	nc,rgst25	;error - too many chars
	neg
	add	a,4		;calculate space padding
	ld	c,a
	cp	3		;was it	one?
	jr	nz,rgst10
	ld	a,(de)
	call	ixlt
	cp	'P'
	jr	nz,rgst10
	ld	(inbfnc),a	;any number > 2	indicates 16 bit register
rgst10:	call	spaces
	ld	a,(hl)		;check last char in parse buffer
	sub	quote
	jr	nz,rgst15	;not quote
	ld	(hl),a		;replace with null
rgst15:	call	mreg		;validate register name
	jr	nz,rgst25	;error
	ld	a,(regtrm)	;mreg stored char following reg	name
	and	a
	jr	nz,rgst25	;error - no operators allowed
	ld	a,(inbfnc)	;now check number of chars in buffer
	ld	b,a		;save in b reg for 8 or	16 bit reg test
	dec	a		;test for one -	8 bit reg
	ld	c,3
	jr	z,rgst20
	ld	a,(hl)
	call	outhex		;display byte of reg contents
	dec	hl
	ld	c,1
rgst20:	ld	a,(hl)
	call	othxsp
	call	spaces		;reg c - number	of spaces to print
	ex	de,hl		;de - save reg contents	pointer
rgst22:	call	istr		;query user for	reg value replacement
	ld	a,(inbfnc)	;test number of	chars in input buffer
	dec	a		;
	jp	m,rgst40	;none -	prompt for next	reg name
	call	irsm
	jr	z,rgst30
	ld	a,(inbfnc)
	and	a
	jr	z,rgst22
rgst25:	call	exxx
	jr	rgst40		;accept	new reg	name
rgst30:	ex	de,hl
	ld	(hl),e
	dec	b		;test for 16 bit reg
	jr	z,rgst40	;z - 8 bit reg
	inc	hl
	ld	(hl),d		;save upper byte of user input
rgst40:	call	crlf
	call	space5
	jp	rgst



mreg:	ld	c,23		;number	of reserved operands
	call	oprn00		;check validity	of register name
	ld	a,(de)		;last char examined by operand routine
	call	oprtor
	ret	nz		;error - not null or valid operator
	ld	(regtrm),a	;save terminator character for rgst
	ld	a,c
	cp	17		;valid reg names are less than 17
	jr	c,mreg00	;so far	so good
	sub	23		;last chance - may be pc
	ret	nz		;error - invalid reg name
	ld	a,10		;make pc look like p for mapping
mreg00:	ld	hl,regmap	;ptrs to register contents storage
	add	a,l		;index into table by operand value
	ld	l,a
	jr	nc,mreg05
	inc	h
mreg05:	ld	a,b		;b reg set m by	prsr if	trailing quote
	and	a
	ld	a,0		;assume	no quote - not prime reg
	jp	p,mreg10	;p - correct assumption
	ld	a,8		;bias pointer for prime	reg contents
mreg10:	add	a,(hl)
	ld	c,a		;save mapping byte
	and	7fh		;strip sign
				;so iarg knows 16 bit reg pair
	ld	hl,regcon	;use mapping byte to build pointer
	add	a,l
	ld	l,a
	jr	nc,mreg50
	inc	h
mreg50:	xor	a		;hl - pointer to register contents
	ret


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

qprt:
nprt:
	xor	a
	ld	(parenf),a
  	call	iedtbc		;get port specified by user
	ld	hl,port
	ld	e,(hl)
	jp	m,qprt30	;m - no input means use last port number
	ex	de,hl
        call	iarg		;extract address
	jp	nz,exxx
	ex	de,hl 		;e - new port number
	ld	(hl),e
	ld	a,(parenf)
	cp	'('
	jr	nz,qprt30
	ld	c,2
	call	spaces
qprt00:	ld	c,e
	in	a,(c)
	ld	b,a
	call	outhex
	ld	c,2
	call	spaces
	ld	c,8		;number of bits to display
qprt10:	sla	b		;most significant bit to carry
	ld	a,'0'
	adc	a,0		;carry makes it a 1
	call	ttyo
	dec	c
	jr	nz,qprt10
	ld	c,e
	ld	b,3
	call	ttyq
	cp	cr
	ret	z
	call	clok		;so we don't go faster than the terminal
	ld	e,c
	ld	a,b
	and	a
	ret	p
	ld	b,12
qprt20:	call	bksp
	djnz	qprt20
	jr	qprt00
qprt30:	call	crlf
	ld	a,e
	ld	(port),a
	call	othxsp
	call	rspace
	ld	c,e
	ld	a,(lcmd)
	cp	'N'
	jr	z,qprt50
       	in	a,(c)
	call	outbyt
qprt50:	call	rbyte
	ld	a,(trmntr)
	jr	nz,qprt60
	cp	'.'
	ret	z
	ld	hl,argbc
	ld	b,(hl)
	ld	hl,argbf
	ld	c,e		;port number
	otir
	jr	qprt30
qprt60:	cp	' '
	jr	nz,qprt30
	dec	de
	jr	qprt30

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

break:
	call	iedtbc
	ret	m		;end command - no input
	ld	c,0ffh		;set neg - distinguish ourselves from step
brk10:	ld	a,(bps)		;fetch current bp count
	cp	maxbp		;table full
	jp	nc,exxx		;full -	abort command
	ld	b,a		;save current count
	call	iarg
	jp	nz,exxx
	ex	de,hl		;de - breakpoint address to set
brk30:	ld	hl,brktbl
	xor	a
	or	b		;check for no breakpoints in effect
	jr	z,brk60		;none -	bypass check for duplicate
brk40:	ld	a,e
	cp	(hl)		;check lo order	address	match
	inc	hl
	jr	nz,brk50	;no match - check next
	ld	a,d
	sub	(hl)		;check hi order
	jr	nz,brk50	;no match - check next
	or	c
	ret	p
	ld	hl,bps		;pointer to bp count
	ld	a,(hl)
	sub	b		;create	index into psctbl
	jr	brk70
brk50:	inc	hl
	inc	hl		;bump past contents storage byte
	djnz	brk40
brk60:	ld	(hl),e		;set in	table
	inc	hl
	ld	(hl),d
	ld	hl,bps		;breakpoint count
	ld	a,(hl)		;fetch current count for user as index
	inc	(hl)		;bump bp count
brk70:	ld	de,psctbl	;base of pass count table
	add	a,a		;two byte table
	add	a,e
	ld	e,a
	jr	nc,brk80
	inc	d
brk80:	xor	a
	ld	(de),a		;pre-clear pass	count table entry
	inc	de
	ld	(de),a
	or	c		;test if this was step calling
	ret	p		;i'm positive it was
	ld	a,(delim)	;check delimeter which followed	bp address
	and	a
	ret	z		;end of	line null - terminate command
	cp	','		;check for pass	count delimeter
	jp	nz,brk10	;not comma means treatt	this as	new bp
	call	iarg		;get next arg
	jp	nz,exxx		;nz - evaluation error
	ex	de,hl		;de - pass count as entered by user
	ld	(hl),d		;store pass count in table
	dec	hl
	ld	(hl),e
	and	a		;check delimeter
	jp	nz,brk10	;nz - more arguments follow
	ret			;end of	line null - terminate command


;******************************************************************************
;*
;*	cbreak:	clear breakpoint
;*
;*	breakpoint address storage table (brktbl) is examined and breakpoint
;*	is removed if found. breakpoint	is removed by bubbling up all bp
;*	addresses which	follow,	ditto for pass counts.
;*
;******************************************************************************

cbreak:	call	iedtbc
	ret	m		;no input ends command
	ld	a,(bps)		;fetch breakpoint count
	or	a		;any if	effect
	ret	z		;no
	ld	b,a		;temp save count
	call	iarg		;extract address to clear from input buffer
	ld	de,brktbl	;bp address storage table
	jr	z,cbrk10
	ld	a,(prsbf)
	cp	'*'
	jp	nz,exxx
	ld	a,(inbfnc)
	dec	a
	jp	nz,exxx
	ld	(bps),a
	ret

cbrk10:	ld	a,(de)		;test lo order address for match
	cp	l
	inc	de
	jr	nz,cbrk20	;no match - examine next entry
	ld	a,(de)
	cp	h		;versus	hi order bp address
cbrk20:	inc	de
	inc	de		;bump past contents save location
	jr	z,cbrk30	;zero -	found bp in table
	djnz	cbrk10
	jp	exxx		;error - breakpoint not	found
cbrk30:	ld	h,0ffh		;rewind	to point to bp address
	ld	l,-3
	add	hl,de
	ex	de,hl		;de - ptr to bp	  hl - ptr to next bp
	ld	a,b		;multiply number of bps	remaining in table
				;times three bytes per entry
	add	a,a
	add	a,b
	ld	c,a		;init c	for ldir
	ld	a,b		;save number of	bps remaining
	ld	b,0
	ldir			;bubble	up all remaining entries in table
	ld	c,a		;
	ld	hl,bps		;address of bp count
	ld	a,(hl)		;
	dec	(hl)		;decrement system breakpoint count
	sub	c		;compute relative number of pass count table
				;entry we wish to clear
	add	a,a		;times two bytes per entry
	ld	l,a
	ld	h,b		;cheap clear
	ld	de,psctbl
	add	hl,de		;index into pass count table
	ex	de,hl
	ld	hl,02
	add	hl,de		;de - ptr to pass count	 hl - next in table
	sla	c		;number	of pass	counts to move
	ldir
	ld	a,(delim)	;recheck delimeter
	and	a
	jr	nz,cbreak	;not end of line terminator - clear more
	ret

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

obreak:	ld	a,(bps)		;fetch bp count
	dec	a		;test for no breakpoints
	ret	m		;m - none
	ld	b,a		;save count
obrk00:	ld	hl,brktbl	;base of breakpoint storage table
	ld	e,b		;use current breakpoint	count as index
	ld	d,0		;clear
	add	hl,de		;this is a three byte table
	add	hl,de
	add	hl,de
	ld	e,(hl)		;fetch lo order	bp address
	inc	hl
	ld	d,(hl)		;upper address
	ex	de,hl
	call	outadr		;display address
	ex	de,hl		;hl - breakpoint table
	call	fadr		;check symbol table for	name match
				;   symbol table pointer returned in de
				;   zero flag set if found
	ld	a,(maxlen)
	ld	c,a
	dec	bc		;max number of chars in	a symbol name
	ex	de,hl		;hl - symbol table address if
	call	z,printb	;display name if found in symbol table
	ld	a,b
	add	a,a		;bp number times two
	ld	hl,psctbl	;base of pass count table
	add	a,l
	ld	l,a
	jr	nc,obrk10
	inc	h
obrk10:	ld	e,(hl)		;lo order pass count
	inc	hl
	ld	d,(hl)		;upper byte
	ld	a,d		;test if pass count in effect
	or	e
	jr	z,obrk20	;z - no	pass count for this bp
	inc	c
	call	spaces
	ex	de,hl
	call	outadr		;display pass count in hex
obrk20:	call	crlf
	ld	c,5
	call	spaces
	dec	b		;dec bp	count
	jp	p,obrk00
	ret



kdmp:	call	iedtbc		;let user input address of memory to display
	ret	m		;no input ends command
	call	iarg		;evaluate user arg
	jp	nz,exxx
	ex	de,hl		;de - save memory address
	call	iarg		;now get count
	ld	a,0
	jr	nz,kdmp20	;error during input - display 00 bytes
	or	h
	jp	nz,exxx		;greater than 256 is error
	ld	a,(maxlen)	;max symbol length
	ld	b,2		;assume big names
	cp	15
	ld	a,18		;number of disassembled lines displayed
	jr	z,kdmp00
	ld	b,3		;double number of lines one extra time
kdmp00:	add	a,a		;times two
	djnz	kdmp00
	cp	l
	jr	c,kdmp20	;if number of bytes specified by user is too
				;large then use default
	ld	a,l		;use value specified by user
kdmp20:	ld	(wnwtab),de
	ld	(wnwsiz),a
	ret

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

go:	call	iedtbc		;query user for	execution address

;	ret	m		;- eg 3.3.3 no input - reprompt
	jp	p,g001		;+ Skip if argument supplied, else:
	ld	hl,(pcreg)	;+ Use current PC
	jr	g002		;+
g001:				;+
	call	iarg
	jp	nz,exxx		;error - invalid argument
g002:				;+
	call	crlf
	call	crlf
g100:	ld	(jmplo),hl	;store execution address
	ld	a,ijp
	ld	(sjmp),a	;set jp	instruction
	ld	(jmp2jp),a	;just in case
	ld	a,(bps)		;check breakpoint count
	and	a
	jp	z,g600		;z - no	bps in effect -	no restoration needed
	ld	b,a
	ld	hl,brktbl
	ld	c,0ffh
g300:	ld	e,(hl)
	inc	hl
	ld	d,(hl)		;de - breakpoint address removed from table
	inc	hl		;point to contents save	byte in	table
	ld	a,(de)
	ld	(hl),a
	ld	a,(jmplo)
	cp	e		;check if bp from table	matches	next pc
	jr	nz,g400		;no match - set	breakpoint
	ld	a,(jmphi)
	cp	d		;check hi order	next pc	address
	jr	nz,g400		;no match - set	bp
	ld	c,b		;set flag - current pc matches breakpoint
	jr	g500
g400:	ld	a,rst38		;set rst38 instruction
	ld	(de),a		;save user byte	in brktbl
g500:	inc	hl
	djnz	g300		;examine all entries
	inc	c		;current pc match breakpoint?
	jp	z,g600		;z - no (c reg not 0ffh)
	ld	a,(sbps)	;check number of step breakpoints
	and	a		;tracing?
	jp	nz,g600		;nz - this is trace

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
	ld	hl,execbf
	ld	de,(jmplo)	;de - pointer to next instruction to execute
	ld	(jmplo),hl	;execute buffer
	ld	b,4		;clear execute buffer
g505:	ld	(hl),inop
	inc	hl
	djnz	g505
	call	zlen00		;calculate length
				;if instruction modifies pc then zlen lets us
				;know by setting b reg nz and c contains
				;instruction length

	ld	(jropnd),hl	;if this is a jr instruction we need to save
				;address where we will be jumping


				;default execbf has been initialized:
				;
				;four nops
				;     jp   user program
				;
	ex	de,hl		;hl - ptr to user instruction
	ld	de,execbf
	ld	a,(hl)		;first object byte from	user program
g518:	ld	(hl),rst38	;replace
	push	bc		;b - if nz this is a pc modifying instruction
				;c - number of bytes of object code for this
				;    instruction
g520:	ld	(de),a		;into execute buffer
	inc	de
	inc	hl		;bump user program pointer
	ld	a,(hl)		;next byte of instruction from user program
	dec	c
	jr	nz,g520
	pop	bc
				;the four nops in execbf have now been replaced
				;by from one to four bytes of actual user
				;instruction.  if user instruction was shorter
				;than four bytes the nops remain and are
				;executed until the jump back to the user
				;program at jmp2jp is reached.


	ld	(jmp2),hl	;address of next inline instruction within
				;user code

	ex	de,hl		;de - next inline instruction in user program
	xor	a
	or	b
	jr	z,g600		;z - the instruction in execbf is not a pc
				;modifying instruction

	ld	a,(execbf)	;first byte of instruction
	dec	c		;one byte instruction?
	jr	z,g600
	dec	c
	jr	z,g550		;two byter
	dec	c
	jr	nz,g600		;nz - must be four byter
	ld	b,c		;clear for cpir
	ld	c,z803sl	;test for call instruction
	ld	hl,z803s	;load list of first byte of call instructions
	cpir
	jr	nz,g600		;nz - not call

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

	ld	bc,08		;point to jump instruction which is equivalent
				;to call (call nz = jp nz)
	add	hl,bc
	ld	a,(hl)		;fetch jump object byte
	ld	hl,(spreg)	;push next pc onto user stack
	dec	hl		;decrement user sp
	ld	(hl),d		;de - "return address"
	dec	hl
	ld	(hl),e
	ld	(spreg),hl
	ld	(execbf),a	;store jp op code
	ld	hl,jmp2		;if conditional call and we fall thru
				;we need to go back to address of call
				;in user program + 3
	ld	(hl),e
	inc	hl
	ld	(hl),d
	jr	g600
				;if next instruction to execute is a
				;relative jump we need to replace it with
				;an absolute equivalent.  this is because
				;having relocated the user jr instruction
				;into execbf we will undoubtedly be out of
				;range of the destination.

g550:	ld	c,z802cl	;check if this is relative jump
	ld	hl,z802c
	and	a		;clear carry
	cpir
	jr	nz,g600		;not a jr
	ld	a,c
	ld	bc,z802c
	sbc	hl,bc
	dec	hl
	ld	bc,z803c
	add	hl,bc		;point to equivalent absolute jump
	and	a
	ld	a,(hl)
	ld	hl,execbf
	jr	nz,g555		;nz - not last in list (not djnz)

				;replace djnz with  dec   b
				;		    jp    nz,

	ld	(hl),05		;dec b instruction
	inc	hl
	ld	a,0c2h		;jp nz absolute
g555:	ld	(hl),a
	inc	hl
	ld	bc,(jropnd)	;if this is a conditional jr we need the
				;absolute destination of the jump
	ld	(hl),c
	inc	hl
	ld	(hl),b

g600:	ld	iy,(iyreg)	;restore user iy
	ld	ix,(ixreg)	;restore user ix
	ld	a,(rreg)
	ld	r,a		;restore user r	reg
	ld	a,(ireg)
	ld	i,a		;restore user i	reg
	ld	bc,(bcpreg)	;restore user grade a prime regs
	ld	de,(depreg)
	ld	hl,(afpreg)
	push	hl
	pop	af
	ld	hl,(hlpreg)
	ex	af,af'
	exx
	ld	hl,(afreg)	;restore user accumulator and flag
	push	hl
	pop	af
	ld	bc,(bcreg)	;restore user bc
	ld	de,(dereg)	;restore user de
	ld	hl,(hlreg)	;restore user hl
	ld	sp,(spreg)	;restore user sp
	jp	sjmp

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

step:	ld	a,0ffh
	ld	(wflag),a	;set trace subroutine flag on
	call	iedtbc		;query user for	trace count
	ld	hl,0001
	jp	m,step40	;null input - step count of one
	call	prsr
	jp	nz,exxx
	ld	a,(de)		;first character from parse buffer
	sub	'/'
	ld	(wflag),a	;may be	slash -	no subroutine tracing
	ld	hl,00
	jr	nz,step20
	ld	(de),a
	ld	a,(inbfnc)
	dec	a
	inc	hl
	jr	z,step40
	dec	hl
step20:	call	xval		;evaluate contents of parse buffer
	jp	nz,exxx
	ld	de,(pcreg)
	ld	a,(de)		;first byte of op code at current pc
	cp	0c7h		;test for rst
	jp	z,exxx		;no tracing of rsts
step40:	ld	(nstep),hl	;save step count
	ld	hl,sbps		;set step flag nz - trace in effect
	inc	(hl)
	ld	de,(pcreg)	;fetch current pc
	call	zlen00		;determine number of bytes in instruction
	inc	b		;test where to set breakpoint
	djnz	step50		;nz - set at address in	hl
	ex	de,hl
	add	hl,bc		;z - set at address pc + instruction length
step50:	ld	a,(bps)		;get current number of bps
	ld	b,a		;pass to set bp	routine	in b reg
	ex	de,hl		;de - bp address to set
	call	brk30
	ld	hl,(pcreg)	;resume	execution at next pc
	xor	a
	or	b
	jp	nz,g100		;nz - collision	with user bp
	ex	de,hl
	ld	hl,sbps		;step bp set by	brk30 -	bump count
	inc	(hl)
	ex	de,hl
	jp	g100

;******************************************************************************
;*
;*	asmblr:	z80 assembler
;*
;******************************************************************************

asmblr:
	call	ilin
	jp	nz,exxx
asm000:	call	crlf
	ld	(zasmpc),hl	;save here as well
	call	zasm08		;disassemble first instruction

asm005:
	ld	hl,(asmbpc)
asm010:	call	crlf
	call	outadr		;display current assembly pc
	ld	c,22		;
	call	spaces		;leave room for	object code
	ld	a,3
	ld	hl,objbuf	;zero scratch object code buffer
asm015:	ld	(hl),c
	inc	hl
	dec	a
	jp	p,asm015
	ld	(oprn01),a	;init operand key values to 0ffh
	ld	(oprn02),a
	call	iedtbc		;get user input
	ret	m		;m - no	input ends command
	call	cret
	call	prsr		;parse to obtain label
	ld	a,(hl)		;check last character
	cp	':'
	jr	nz,asm040	;no colon found	- must be op code
	ld	(hl),0		;erase colon
	ld	a,(de)		;fetch first char of label from	parse buffer
	cp	'A'
	jp	c,asmxxl	;error - first character must be alpha
	cp	'z'+1
	jp	nc,asmxxl	;label error
	cp	'a'
	jr	nc,asm030
	cp	'Z'+1
	jp	nc,asmxxl
asm030:	ld	hl,00
	ld	(isympt),hl	;clear pointer
	call	isym		;attempt to insert symbol into symbol table
	jp	nz,asmxxt	;error - symbol	table full
	ld	(isympt),hl	;save pointer to symbol	value in symbol	table
	call	prsr		;extract opcode
	jp	m,asm005	;m - statement contains	label only
asm040:	ld	a,(delim)	;check delimeter
	cp	','		;check for invalid terminator
	jp	z,asmxxo
	ld	c,73		;number	of opcodes in table as index
asm050:	dec	c
	jp	m,asmxxo	;opcode	not found
	ld	b,0
	ld	hl,zopcnm	;table of opcode names
	add	hl,bc
	add	hl,bc		;index times four
	add	hl,bc
	add	hl,bc
	ld	de,prsbf	;start of parse	buffer
	ld	b,4
asm060:	ld	a,(de)		;character from	parse buffer
	and	a		;null?
	jr	nz,asm070
	ld	a,' '		;for comparison	purposes
asm070:	call	ixlt		;force upper case for compare
	cp	(hl)
	jr	nz,asm050	;mismatch - next opcode	name
	inc	de
	inc	hl
	djnz	asm060		;must match all	four
	ld	a,(de)		;null following	opcode?
	and	a
	jp	nz,asmxxo	;error - opcode	more than 4 characaters
	ld	hl,ikey		;relative position in table is key value
	ld	(hl),c		;save opcode key value
	call	prsr		;extract first operand
	jp	m,asm085	;m - none
	call	oprn		;evaluate operand
	jr	nz,asmxxu	;error - bad first operand
	ld	de,oprn01
	call	opnv		;save operand value and	key
	ld	a,(delim)
	cp	','
	jr	nz,asm085	;need comma for	two operands
	call	prsr		;extract second	operand
	jp	m,asmxxs	;error - comma with no second operand
	cp	','
	jp	z,asmxxs	;illegal line termination
	call	oprn		;evaluate operand
	jr	nz,asmxxu	;error - bad second operand
	ld	de,oprn02
	call	opnv		;save second operand value and key
asm085:	xor	a
	ld	c,a
asm090:	ld	hl,zopcpt	;opcode	name pointer table
	ld	b,0
	add	hl,bc		;index into table
	ld	a,(ikey)	;fetch opcode key value
	cp	(hl)		;check for match
	jr	nz,asm095	;
	inc	h		;point to first	operand	table
	ld	de,oprn01	;address of first operand key value
	call	opnm		;check validity
	jr	nz,asm095	;no match - next
	ld	b,a		;save modified key value
	inc	h		;point to second operand table
	ld	de,oprn02	;address of second operand key value
	call	opnm
	jr	z,ibld		;match - attempt final resolution
asm095:	inc	c		;bump index
	jr	nz,asm090	;nz - check more
asmxxu:	ld	a,'U'		;error
	jp	asmxxx




ibld:	ld	hl,objbuf	;object	code temp buffer
	ld	e,a		;save second operand key
	ld	a,(hl)		;check first byte of object buffer
	and	a		;null?
	ld	a,c		;instruction key to accumulator	regardless
	ld	c,e		;save second operand modified key
	jr	z,ibld00	;z - not ix or iy instruction
	inc	hl		;point to byte two of object code
ibld00:	cp	40h
	jr	c,ibld55	;c - 8080 instruction
	cp	0a0h
	jr	nc,ibld10	;nc - not ed instruction
	ld	(hl),0edh	;init byte one of object code
	inc	hl
	cp	80h		;check which ed	instruction we have
	jr	c,ibld55	;c - this is exact object byte
	add	a,20h		;add bias to obtain object byte
	jr	ibld55
ibld10:	cp	0e0h
	jr	nc,ibld20
	add	a,20h		;8080 type - range 0c0h	to 0ffh
	jr	ibld55		;object	byte built
ibld20:	cp	0e8h
	jr	c,ibld50	;8 bit reg-reg arithmetic or logic
	cp	0f7h		;check for halt	disguised as ld (hl),(hl)
	jr	nz,ibld30
	ld	a,76h		;halt object code
	jr	ibld55
ibld30:	cp	0f8h
	jr	nc,ibld50	;8 bit reg-reg load
	ld	d,a		;temp save instruction key value
	ld	a,(objbuf)
	and	a		;check for previously stored first object byte
	ld	a,d
	ld	(hl),0cbh	;init byte regardless
	inc	hl
	jr	z,ibld40	;z - not ix or iy instruction
	inc	hl		;bump object code pointer - this is four byter
ibld40:	add	a,0a8h		;add bias for comparison purposes
	cp	98h
	jr	c,ibld50	;c - shift or rotate instruction
	rrca
	rrca
	and	0c0h		;this is skeleton for bit instuctions
	jr	ibld55
ibld50:	add	a,a		;form skeleton
	add	a,a
	add	a,a
	add	a,80h
ibld55:	ld	(hl),a		;store object byte
	xor	a
	or	c		;second	operand	need more processing?
	ld	de,oprn02
	call	nz,rslv		;resolve second	operand
	jp	nz,asmxxv	;error - invalid operand size
	ld	de,oprn01
	ld	a,b
	and	a		;first operand resolvedX
	call	nz,rslv		;more work to do
	jp	nz,asmxxv	;error - invalid operand size
	ld	a,(ikey)
	sub	67		;org directive?
	jr	nz,ibld60
	ld	d,(hl)
	dec	hl
	ld	e,(hl)
	ex	de,hl
	jp	asm000		;z - org directive
ibld60:	ld	de,objbuf
	jr	c,ibld70	;c - instruction  nc - directive
	ld	b,a		;number	of bytes for defb or defw or ddb
	inc	de		;point past erroneous assembled	opcode
	inc	de
	sub	3		;test for ddb
	jr	c,ibld75	;c - must be defb or defw
	dec	a
	jr	nz,ibld65	;nz - must be ddb
	ld	d,(hl)		;must be equ
	dec	hl
	ld	e,(hl)
	ld	hl,(isympt)	;fetch pointer to entry	in symbol table
	ld	a,h
	or	l
	jp	z,asmxxu	;error - no label on equ statement
	ld	(hl),d
	dec	hl
	ld	(hl),e		;store value of	symbol in symbol table
	ld	c,6
	call	spaces
	ld	a,d
	call	othxsp
	ld	a,e
	call	othxsp
	jp	asm005		;ready for next	input
ibld65:	dec	b		;set count of object bytes to 2
	ld	c,(hl)		;exchange hi and lo order bytes	for ddb
	dec	hl
	ld	a,(hl)
	ld	(hl),c		;new hi order
	inc	hl
	ld	(hl),a		;new hi order replaces old lo order
	jr	ibld75
ibld70:	call	zlen00		;compute length	of instruction in bytes
	ld	b,c		;b - number of bytes of	object code
ibld75:	ld	hl,(asmbpc)
	call	outadr		;re-display current location counter
ibld80:	ld	a,(de)		;move from scratch object buffer
	ld	(hl),a		;into address pointed to by location counter
	inc	hl
	inc	de
	call	othxsp		;display each object code byte
	djnz	ibld80
ibld90:	ld	(asmbpc),hl
	jp	asm005		;next input from user




opnm:	ld	a,(de)		;key value computed by operand routine
	xor	(hl)		;compare with table operand table entry
	ret	z		;true match of operand key values
	xor	(hl)		;restore
	add	a,a		;86 all	no operand key values (0ffh)
	ret	m
	ld	a,(hl)		;fetch table entry
	and	7fh		;sans paren flag for comparison	purposes
	cp	1bh		;check table entry 8 bit - 16 bit - $ rel ?
	jr	c,opnm00	;c - none of the above
	ld	a,(de)		;fetch computed	key
	xor	(hl)		;compare with paren flags
	ret	m		;error - paren mismatch
	ld	a,(de)		;fetch key once	more
	and	7fh		;remove	paren flag
	cp	17h		;computed as 8 bit - 16	bit - $	rel?
	jr	z,opnm40	;so far	so good
	ret			;
opnm00:	cp	19h		;check for 8 bit reg
	jr	nc,opnm20	;8 bit register	match
	cp	18h		;table says must be hl - ix - iy
	ret	nz		;computed key disagrees
	ld	a,(de)		;fetch computed	key
	and	7		;computed as hl	- ix - iy ?
	ret	nz		;no
opnm10:	ld	a,(de)		;fetch computed	key
	xor	(hl)
	ret	m		;error - paren mismatch	on hl -	ix - iy
	jr	opnm40
opnm20:	ld	a,(de)		;fetch computed	key of 8 bit reg
	and	a		;
	jr	nz,opnm30	;nz - not (hl)
	dec	a		;error - 8 bit (hl) missing parens
	ret
opnm30:	cp	8		;test user entered valid 8 bit reg
	jr	c,opnm40	;c - ok
	and	a		;test if no carry caused by paren flag
	ret	p		;error - this is not 8 bit reg with parens
	and	7		;psuedo	8 bit reg: (hl)	(ix) (iy)?
	ret	nz		;no
opnm40:	ld	a,(hl)		;fetch table entry
	and	7fh
	sub	18h		;make values 18	thru 1f	relative zero
	cp	a		;zero means match
	ret

rslv:	dec	a
	jr	z,rslv00	;z - 8 bit reg (bits 0-2 of object byte)
	dec	a
	jr	nz,rslv20	;nz - not 8 bit	reg (bits 3-5 of object	byte)
	dec	a		;make neg to indicate shift left required
rslv00:	ld	c,a
	ld	a,(de)		;fetch computed	operand	key
	and	07		;lo three bits specify reg
	xor	6		;create	true object code bits
	inc	c		;test if bits 0-2 or bits 3-5
	jr	nz,rslv10	;nz - 0	thru 2
	add	a,a
	add	a,a
	add	a,a
rslv10:	or	(hl)		;or with skeleton
	ld	(hl),a		;into scratch object buffer
	cp	a		;set zero - no error
	ret
rslv20:	inc	de		;point to low order of operand value
	ld	c,(hl)		;c - current skeleton  (if needed)
	inc	hl		;bump object code buffer pointer
	dec	a
	jr	nz,rslv30	;nz - not relative jump
	ex	de,hl		;save object code pointer in de
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a		;hl - operand value computed by	xval
	ld	a,b
	ld	bc,(asmbpc)	;current location counter
	inc	bc
	inc	bc
	sbc	hl,bc		;calculate displacement	from current counter
	ex	de,hl		;de - displacement  hl - object	code pointer
	ld	b,a		;restore b reg
	ld	a,e		;lo order displacement
	inc	d		;test hi order
	jr	z,rslv25	;must have been	ff (backward displacement)
	dec	d
	ret	nz		;error - hi order not zero or ff
	cpl			;set sign bit for valid	forward	displacement
rslv25:	xor	80h		;toggle	sign bit
	ret	m		;error - sign bit disagrees with upper byte
	ld	(hl),e		;store displacement object byte
	cp	a		;set zero flag - no errors
	ret
rslv30:	dec	a
	jr	nz,rslv40	;nz - not 8 bit	immediate
	ld	a,36h		;test for reg indirect - (hl),nn
	cp	c
	jr	nz,rslv35
	ld	a,(objbuf)	;test first object byte
	cp	c
	jr	z,rslv35	;z - (hl),nn
	inc	hl		;must be (ix+index),nn	or  (iy+index),nn
rslv35:	ld	a,(de)		;move lo order operand value to	object buffer
	ld	(hl),a
	inc	de
	ld	a,(de)		;test hi order
	and	a		;
	ret	z		;z - must be 0 thru +255
	inc	a		;error if not -1 thru -256
	ret
rslv40:	dec	a
	jr	nz,rslv50	;nz - not 16 bit operand
	ld	a,(de)		;move both bytes of operand to object buffer
	ld	(hl),a
	inc	hl
	inc	de
	ld	a,(de)		;byte two
	ld	(hl),a
	cp	a		;set zero flag - no errors of course
	ret
rslv50:	dec	a		;test restart instruction or bit number
	jr	nz,rslv60	;nz - bit or interrupt mode number
	ld	a,(de)		;check restart value specified
	and	0c7h		;betweed 0 and 38h?
	ret	nz		;error
	ld	a,(de)		;fetch lo order	operand	value
	or	0c7h		;or with instruction skeleton
	dec	hl
	ld	(hl),a		;rewind	object code pointer
	inc	de
	ld	a,(de)		;check hi order	operand	value
	and	a		;error if not zero
	ret
rslv60:	dec	hl		;rewind	object code buffer pointer
	ld	a,(de)
	and	0f8h		;ensure	bit number in range 0 -	7
	ret	nz		;error
	ld	a,(ikey)	;fetch opcode key value
	sub	13h		;is this bit number of interrupt mode number?
	ld	a,(de)		;fetch operand value regardless
	jr	nz,rslv70	;nz - bit number
	ld	(hl),46h
	and	03		;im 0?
	ret	z
	ld	(hl),56h
	dec	a		;im 1?
	ret	z
	ld	(hl),5eh
	dec	a		;error if not im 2
	ret
rslv70:	add	a,a		;shift bit number left three
	add	a,a
	add	a,a
	or	(hl)		;or with skeleton
	ld	(hl),a
	cp	a		;indicate no error
	ret



oprn:	ld	bc,22		;count of reserved operand
oprn00:	ld	de,prsbf	;buffer	contains operand
	ld	a,(hl)		;last character	of operand in parse buffer
	sub	')'
	jr	nz,oprn20	;not paren
	ld	(hl),a		;remove	trailing paren - replace with null
	ld	a,(de)		;check first character of parse	buffer
	sub	'('
	ret	nz		;error - unbalanced parens
	ld	(de),a		;remove	leading	paren -	replace	with null
	inc	de		;point to next character in parse buffer
oprn20:	ld	hl,zopnm	;index into reserved operand name table
	ld	a,c
	add	a,a		;index times two
	add	a,l
	ld	l,a
	jr	nc,oprn25
	inc	h
oprn25:	ld	a,(de)		;from parse buffer
	call	ixlt		;translate to upper case for compare
	cp	(hl)		;versus	table entry
	inc	de
	jr	nz,oprn70	;no match - check next
	ld	a,(de)		;check second character
	call	ixlt		;translate to upper case
	and	a		;if null - this	is one character reg name
	jr	nz,oprn30
	ld	a,' '		;for comparison	purposes
oprn30:	inc	hl		;bump table pointer
	sub	(hl)
	jr	nz,oprn70	;no match - check next
	inc	de		;have match - bump buffer pointer
	or	b		;
	ret	nz		;nz - mreg calling
	ld	a,c		;check index value
	and	07
	jr	nz,oprn80	;not hl	ix iy -	check for residue
	ld	a,(de)
	call	oprtor		;check for expression operator
	jr	nz,oprn85	;no operator but not end of operand
	ld	a,rix or riy	;special ix iy hl processing
	and	c		;test for index	reg
	jr	z,oprn35	;z - must be hl
	and	10h		;transform index into 0ddh or ofdh
	add	a,a
	add	a,0ddh		;a - first byte	of index reg opcode
oprn35:	ld	c,a		;temp save first object	byte
	ld	hl,objbuf
	xor	(hl)
	jr	z,oprn40	;z - first operand matches second
	cp	c
	ret	nz		;illegal ix iy hl combination
	ld	a,(oprn01)
	and	a		;test if index reg was first operand
	jr	nz,oprn40
	dec	a		;error - hl illegal as second
	ret


oprn40:	ld	(hl),c		;init first byte of object code
	ld	a,(prsbf)
	and	a		;check for previously removed parens
	ld	a,c
	ld	c,0
	jr	nz,oprn80	;no parens - no	indexed	displacement
	and	a		;check for ix or iy indexed instruction
	jr	z,oprn80	;z - not index reg instruction

	sbc	hl,hl		;clear hl
	ld	a,(de)		;index reg displacement	processing
	and	a		;test for default displacement
	call	nz,xval		;not zero - evaluate
	jr	nz,oprn85	;nz - displacement in error
	ld	c,00
	ld	a,l
	ld	(objbuf+2),a	;displacement always third byte
	inc	h		;check upper byte of index value
	jr	z,oprn50	;must have been	0ffh
	dec	h
	ret	nz		;error - index not -128	to +127
	cpl
oprn50:	xor	80h		;check sign bit
	ret	m		;bit on	- index	out of range
	cp	a		;no error - set	zero flag
	ret
oprn70:	dec	c		;decrement reserved operand table index
	jp	m,oprn85	;m - not a reserved operand
	dec	de		;rewind	parse buffer pointer
	jp	oprn20		;next table entry
oprn80:	ld	a,(de)		;check for end of parse	buffer
	and	a
	ret	z		;found end of line null
oprn85:	ld	de,prsbf	;rewind	to start of input
	xor	a
	or	b
	ret	nz		;nz - this was mreg calling
	sbc	hl,hl		;clear hl
	call	xval		;evaluate operand
	ld	c,17h		;assume	numeric	operand	found
	ret


xval:	ld	a,(de)		;check first char of parse buffer
	and	a
	jr	nz,xval00
	inc	de		;bump past previously removed paren
xval00:	ld	(mexp),hl	;init expression accumulator
	xor	a
	ld	(base10),a	;clear upper digit decimal accumulator
	sbc	hl,hl		;clear hl
	ld	(fndsym),hl	;clear symbol found flag
	ld	(pass2),hl
xval05:	ld	a,(de)		;char from parse buffer
	call	ixlt		;translate to upper case
	ld	c,a		;save character
	inc	de		;bump parse buffer pointer
	cp	'0'		;check for valid ascii hex digit
	jr	c,xval25
	cp	':'
	jr	c,xval15
	cp	'A'
	jr	c,xval25
	cp	'G'
	jr	nc,xval25
	xor	a		;check number entered flag (b reg sign bit)
	or	b
	jp	m,xval10	;m - this was not first	char
	ld	a,(symflg)	;check if symbol table present in memory
	and	a
xval10:	ld	a,c		;input character back to accumulator
	jp	p,xval25	;p - have symbol table or invalid hex digit
	sub	7
xval15:	sub	'0'		;ascii hex to hex nibble
	add	a,a		;shift left five - hi bit of nibble to carry
	add	a,a
	add	a,a
	add	a,a
	add	a,a
	ld	c,4		;loop count
xval20:	adc	hl,hl		;hl left into carry - rotate carry into	hl
	adc	a,a		;next bit of nibble into carry
	dec	c
	jr	nz,xval20
	ld	(base10),a	;store what was	shifted	left out of hl
	ld	a,80h		;set sign of b - number	entered	flag
	or	b
	ld	b,a
	jr	xval05		;next character

xval25:	call	oprtor		;have expression operator?
	jr	z,xval30
	ld	a,(pass2)
	and	a
	ret	nz
	ld	a,(pass2+1)
	and	a
	jp	z,xval35
	ret

xval30:	xor	a
	or	b		;check number entered flag
	ld	a,c		;restore unmodified input character to a
	jp	nz,xval90	;nz - take care	of previous operator
	and	a		;end of	line null?
	ret	z		;
	ld	b,c		;this operator was first char of parse buffer
	jr	xval05		;extract what follows this leading operator

xval35:	ld	a,c		;recover character
	cp	'#'		;decimal processing?
	jr	nz,xval50	;nz - not decimal
	ld	a,b		;check number entered flag
	xor	80h		;toggle
	ret	m		;error - pound sign with no number
	ld	b,a
	push	bc
	push	de
	ex	de,hl		;save hex number in de
	ld	hl,base10
	ld	a,6
	cp	(hl)		;check ten thousands digit
	jr	c,xval40	;error - obviously greater than	65535
	rrd			;nibble	to accumulator
 	inc	hl
	ld	(hl),d		;store hex number in temp buffer
	inc	hl
	ld	(hl),e		;lo order hex number
	dec	hl		;point back to upper byte
	ld	e,a
	xor	a
	ld	d,a		;de - hex nibble
	call	bcdx		;convert hi order byte
	jr	nz,xval40	;nz - error detected during conversion
	inc	hl		;bump to lo byte to convert
	call	bcdx
	ex	de,hl		;hl - converted	value
xval40:	pop	de
	pop	bc
	jr	z,xval65	;z - no	errors detected
	ret



xval50:	cp	quote		;ascii literal processing
	jr	nz,xval60	;nz - not quote
	ex	de,hl		;
	ld	e,(hl)		;fetch literal from buffer
	inc	hl
	cp	(hl)		;trailing quote	found?
	jr	z,xval55	;found
	ld	d,e		;make literal just fetch hi order of operand
	ld	e,(hl)		;fetch new literal as lo order
	inc	hl
	cp	(hl)		;trailing quote?
	ret	nz		;error - more than two chars between quotes
xval55:	ex	de,hl		;de - parse buffer ptr	 hl - operand
	inc	de		;bump past trailing quote
	jr	xval65


xval60:	dec	de		;point to start	of operand in parse buffer
	ld	(pass2),de
	call	fsym		;search	symbol table
	jp	z,xval62	;symbol	found
	ld	a,(de)
	inc	de
	cp	'$'		;check for pc relative expression
	jp	nz,xval61
	ld	hl,(asmbpc)	;current location value	is expression value
	jr	xval65
				;symbol not found - retry evaluation process
				;with pass2 flag set.  now token must be a
				;valid hex digit or error
xval61:	ld	de,(pass2)
	ld	a,b
	or	80h		;set sign in b - valid digit detected which
				;tells xval this must be hex number
	ld	b,a
	sbc	hl,hl		;clear hex number accumulator
	jp	xval05
xval62:	ld	a,(maxlen)	;point to last byte of sym table entry
	or	l
	ld	l,a
	ld	a,(hl)		;hi order symbol address
	dec	hl
	ld	l,(hl)		;lo order
	ld	h,a
xval65:	ld	a,b		;check number entered flag
	and	a
	ret	m		;error - numbers entered previous to symbol
	xor	80h		;toggle	flag
	ld	b,a
	ld	a,(de)		;check char following symbol name in buffer
	ld	c,a		;make it new current character
	inc	de
	jp	xval30

xval90:	ld	c,a		;temp save operator
	ld	a,80h		;toggle	number entered flag
	xor	b
	ret	m		;return	nz - consecutive operators
	ld	b,c		;new on	deck operator
	cp	'-'		;test last operator
	push	de		;save buffer pointer
	jr	nz,xval95	;nz - addition
	ex	de,hl
	sbc	hl,hl		;clear
	sbc	hl,de		;force current value neg by subtraction from 0
xval95:	ex	de,hl
	ld	hl,(mexp)	;fetch accumulated operand total
	add	hl,de		;add in	current
	pop	de		;restore buffer	pointer
	ld	a,b		;check operator	that got us here
	and	a		;end of	line null?
	jp	nz,xval00	;no -
	ret			;operand processing complete



fsym:
	ld	hl,(bdosad)	;de - buffer   hl - symbol table
fsym00:	ld	a,(maxlen)
	and	l
	ld	c,a
	ld	a,b		;temp save
	ld	b,0
	ex	de,hl		;de - symbol table ptr	hl - parse buffer
	sbc	hl,bc		;rewind	parse buffer to	start of symbol
	ex	de,hl		;de - parse buffer  hl - symbol	table pointer
	ld	b,a		;restore b reg
	ld	a,(maxlen)
	or	l
	ld	l,a
	inc	hl		;next block of symbol table
	ld	a,(hl)		;first character of symbol name
	dec	a
	ret	m		;end of	table
	ld	a,(maxlen)
	dec	a
	ld	c,a		;chars per symbol
fsym10:	ld	a,(de)		;fetch char from buffer
	call	oprtor
	jr	nz,fsym20	;nz - not operator or end of line null
	ld	a,(hl)
	and	a		;null means end	of symbol name in symbol table
	jr	nz,fsym00
	ld	(fndsym),hl	;set symbol found flag nz -
	ret
fsym20:	cp	(hl)
	jr	nz,fsym00
	inc	hl
	inc	de
	dec	c
	jr	nz,fsym10
	ld	(fndsym),hl	;set symbol found flag nz -
fsym30:	ld	a,(de)
	call	oprtor
	ret	z
	inc	de
	jr	fsym30



isym:	call	fsym		;search	for symbol in table
	jr	z,isym00	;z - symbol found
	ld	a,(hl)		;test for empty	slot in	table
	and	a
	ret	nz		;symbol	table full
	ld	(symflg),a	;indicate non-empty symbol table
isym00:	ld	a,(maxlen)	;rewind	point to start of table	entry
	ld	c,a
	cpl
	and	l
	ld	l,a
	ex	de,hl		;de - pointer to start of symbol
	ld	hl,prsbf
	ld	b,0		;move symbol from parse	buffer to table
	dec	c
	ldir
	ld	hl,(asmbpc)	;fetch value of	symbol
	ex	de,hl		;hl - pointer to address storage
	ld	(hl),e		;lo order current location into	table
	inc	hl
	ld	(hl),d		;upper byte
	xor	a
	ret

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

prsr:	xor	a
	ld	(quoflg),a	;clear quote flag
	ld	hl,prsbf	;start of parser scratch buffer
	ld	b,prsbfz	;buffer	size
	ld	c,b
prsr10:	ld	(hl),0		;clear parse buffer to nulls
	inc	hl
	djnz	prsr10
	ld	hl,prsbf	;start of parse	buffer
	ld	de,inbf		;start of input	buffer
	ld	c,inbfl		;max size of input buffer
prsr20:	ld	a,(de)		;from input buffer
	ex	de,hl
	ld	(hl),0		;erase as we pick from input buffer
	ex	de,hl
	dec	c		;decrement buffer size tally
	ret	m		;error -  end of input buffer reached
	inc	de		;bump input buffer pointer
	call	zdlm00		;check for delimeter
	jr	z,prsr20	;delimeter found - continue search
	ld	(parenf),a
	ld	c,nprsbf-prsbf	;parse buffer size
prsr30:	ld	(hl),a
	and	a
	jr	z,prsr60	;end of	line null always ends parse
	cp	quote		;quote?
	jr	nz,prsr50
	ld	(quoflg),a
	ld	a,b		;quote found - toggle flag
	xor	80h
	ld	b,a
prsr50:	dec	c		;decrement buffer size tally
	ret	m		;error - end of	parse buffer reached
	ld	a,(de)		;next char from	input buffer
	ex	de,hl
	ld	(hl),0		;clear as we remove
	ex	de,hl
	inc	de
	inc	b		;bumping character count tests quote flag
	call	p,zdlm		;only look for delimeters if quote flag off
	inc	hl		;bump parse buffer pointer
	jr	nz,prsr30
	dec	hl
prsr60:	ld	de,prsbf	;return	pointing to start of parse buffer
	ld	(delim),a
	ret			;zero flag set - no errors



asmxxl:	ld	a,'L'
	jr	asmxxx
asmxxo:	ld	a,'O'
	jr	asmxxx
asmxxp:	ld	a,'P'
	jr	asmxxx
asmxxs:	ld	a,'S'
	jr	asmxxx
asmxxt:	ld	a,'T'
	jr	asmxxx
asmxxv:	ld	a,'V'

asmxxx:	ld	(asmflg),a
	call	cret
	ld	hl,(asmbpc)
	call	outadr
	ld	de,mxxxx
	call	print
	jp	asm010


zdlm:	cp	','
	ret	z
zdlm00:	and	a
	ret	z
	cp	tab
	ret	z
	cp	' '
	ret

oprtor: cp	'+'
	ret	z
	cp	'-'
	ret	z
	and	a
	ret



opnv:	ex	de,hl		;de - operand value  hl	- operand key storage
	ld	a,(prsbf)	;check first byte of parse buffer
	and	a		;if null - paren was removed
	ld	a,c		;key value to accumulator
	jr	nz,opnv00	;nz - no paren
	or	80h		;found null - set paren	flag
opnv00:	ld	(hl),a		;store key value
	inc	hl
	ld	(hl),e		;lo order operand value
	inc	hl
	ld	(hl),d		;hi order
	ret



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

zlen00:	ld	a,(de)		;fetch first byte of op	code
	cp	0cbh		;test for shift/bit manipulation instruction
	ld	bc,02
	ret	z		;10-4 this is a	cb and length is always	2
	cp	0edh		;test for fast eddie
	jr	nz,zlen15	;
	inc	de		;fetch byte two	of ed instruction
	ld	a,(de)
	dec	de		;restore pointer
	ld	hl,z80ed	;ed four byter table
	ld	c,z80edl	;length
	cpir
	ld	c,4		;assume	ed four	byter
	ret	z		;correct assumption
	ld	c,2		;set length for	return - if not	2 must be 4
	cp	45h		;test for retn
	jr	z,zlen10
	cp	4dh		;test for reti
	ret	nz		;non-pc	modifying two byte ed
zlen10:	ld	a,0c9h		;treat as ordinary return instruction
	jp	zlen80
zlen15:	cp	0ddh		;check for dd and fd index reg instructions
	jr	z,zlen20
	cp	0fdh
	jr	nz,zlen40
zlen20:	inc	de		;fetch byte two	of index reg instruction
	ld	a,(de)
	dec	de		;restore pointer
	cp	0e9h		;check for reg indirect	jump
	jr	nz,zlen30	;
	inc	b		;reg indirect jump - set pc modified flag nz
	ld	a,(de)		;recheck for ix	or iy
	ld	hl,(ixreg)	;assume	ix
	cp	0ddh
	ret	z		;correct assumption
	ld	hl,(iyreg)
	ret
zlen30:	ld	hl,z80fd	;check for dd or fd two	byter
	ld	c,z80fdl
	cpir
	ld	c,2		;assume	two
	ret	z
	ld	hl,z80f4	;not two - try four
	ld	c,z80f4l
	cpir
	ld	c,4		;assume	four
	ret	z		;correct assumption
	dec	c		;must be three
	ret
zlen40:	and	0c7h		;check for 8 bit immediate load
	cp	06
	ld	c,2		;assume	so
	ret	z
	dec	c		;assume	one byte op code
	ld	a,(de)
	cp	3fh
	jr	c,zlen50	;opcodes 0 - 3f	require	further	investigation
	cp	0c0h		;8 bit reg-reg loads and arithmetics do	not
	ret	c
zlen50:	ld	hl,z803		;check for three byter
	ld	c,z803l
	cpir
	jr	nz,zlen60	;nz - not three
	ld	hl,z803s	;established three byter - test conditional
	ld	c,z803cl
	cpir
	ld	c,3		;set length
	ret	nz		;nz - three byte inline	instruction
	ld	hl,z803s
	ld	c,z803sl	;now weed out jumps from calls
	cpir
	ld	c,3
	ld	b,c		;set pc	modified flag -	we have	call or	jump
	ex	de,hl
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)		;de - address from instruction
	ex	de,hl
	dec	de
	dec	de		;restore instruction pointer
	jr	z,zlen55	;z - this is a call
	cp	ijp		;test for unconditional jump
	jr	nz,zlen85
	ret
zlen55:	ld	a,(wflag)	;test for no subroutine	trace flag
	and	a		;zero means no sub tracing
	ld	b,a		;clear for return - if sub trace off
	ret	z		;subroutine trace off -	return with b reg 00
				;so bp is set at next inline instruction
	dec	b
	jr	nz,zlen58
	ld	a,b
	or	h
	ret	z
zlen58:	ld	a,(de)		;recover call object byte
	ld	b,c		;set nz	- pc modifying instruction
	cp	0cdh		;unconditional call??
	jr	nz,zlen85	;zlen85	- set secondary	breakpoint if tracing
	ret

zlen60:	ld	hl,z802
	ld	c,z802l		;test for two byter
	cpir
	jr	nz,zlen70	;not two
	ld	hl,z802c	;test for relative jump
	ld	c,z802cl
	cpir
	ld	c,2		;in any	case length is two
	ret	nz		;nz - not relative jump
	ld	h,b		;clear
	inc	b		;set pc	modified flag nz
	inc	de		;fetch relative	displacement
	ld	a,(de)
	ld	l,a
	add	a,a		;test forward or backward
	jr	nc,zlen65	;p - forward
	dec	h		;set hl	negative
zlen65:	add	hl,de		;compute distance from instruction
	inc	hl		;adjust	for built in bias
	dec	de		;restore pointer
	ld	a,(de)		;fetch first byte of instruction
	cp	18h		;uncondtional jump?
	jr	nz,zlen85	;conditional - set secondary bp	if tracing
	ret
zlen70:	ld	hl,z801		;check for return instruction
	ld	c,z801l
	cpir
	ld	c,1		;length	must be	1 in any case
	ret	nz
	cp	0e9h
	jr	nz,zlen80	;nz - not  jp (hl)
	inc	b		;set pc	modified flag
	ld	hl,(hlreg)	;next pc contained in hlreg
	ret
zlen80:	ld	hl,(spreg)	;return	instructions hide next pc in stack
	ld	b,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,b		;hl - return address removed from stack
	ld	b,c		;set b nz - pc modification flag
	cp	0c9h
	ret	z		;unconditional return
zlen85:	ld	a,(sbps)	;count of special step breakpoints
	and	a		;test for zero
	ret	z		;zero -	monitor	is not tracing
	ld	a,(bps)		;fetch number of bps currently in effect
	ld	b,a		;pass to set breakpoint	routine	in b reg
	ex	de,hl		;de - bp to set
	call	brk30		;set conditional breakpoint
	xor	a
	or	b
	ld	b,0
	ld	de,(pcreg)	;for setting inline bp - condition not m
	ret	nz		;nz - collision	with user bp
	ld	hl,sbps
	inc	(hl)		;bump count of step bps
	ret

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

pswdsp:	ld	de,3
	ld	b,0			;+ eg 3.3.5a
psw00:	ld	hl,pswbit		;table of bit mask for flags
	add	hl,de			;
	add	hl,de			;index times two
	ld	a,e
	neg				;now calculate index into pswmap
	add	a,3
	add	a,a
	ld	c,a
	ld	a,(freg)		;fetch current flag of user
	and	0f7h
	and	(hl)			;unused	bit in flag - ensure it's off
	ld	hl,pswmap
	add	hl,bc			;pointer to mnemonic is	8 bytes	away
	jr	z,psw10			;this is an off	bit (nz	nc p po)
	inc	hl			;on
psw10:	ld	c,(hl)			;fetch index into operand name table
	ld	hl,zopnm
	add	hl,bc			;two bytes per table entry
	add	hl,bc
	ld	c,2			;print both chars of mnemonic name
	call	printb
	call	rspace
	dec	e			;do all	four flag bits
	jp	p,psw00
	call	crlf
	ld	a,(lcmd)

;	cp	'J'			;- eg 3.3.5a
;	ret	z			;-
	cp	'P'			;+ Routine can now be called from
	ret	nz			;+  elsewhere

	call	space5
psw50:	call	iedtbc
	ret	m			;no input
psw55:	call	prsr
	ret	nz			;parse error - end command
	ld	bc,116h			;
	call	oprn20			;check validity	of this	token
	ld	a,c
	ld	bc,pswcnt		;number	of flag	reg mnemonics
	ld	hl,pswmap
	cpir				;check table
	jp	nz,exxx			;error - nmemonic not found
	ld	hl,pswbit		;bit mask table
	add	hl,bc
	ld	a,(hl)			;fetch mask
	ex	de,hl			;
	ld	hl,freg			;de - mask ptr	 hl - user flag	ptr
	and	08			;bit says turn on or off
	ld	a,(de)			;new copy of mask
	jr	nz,psw60		;nz - turn on
	cpl
	and	(hl)			;and with current user flag
	ld	(hl),a			;return	flag reg with bit now off
	jr	psw55			;check for more	input
psw60:	and	0f7h			;turn off on/off flag (bit 4)
	or	(hl)
	ld	(hl),a			;now turn on specified bit
	jr	psw55

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

movb:	call	bcde		;bc - byte count  de - destination  hl - source
	jp	nz,exxx		;input error ends command
	xor	a
	sbc	hl,de
	adc	a,a
	add	hl,de
	add	hl,bc
	dec	hl
	ex		de,hl		;de - address of last byte of source block
	sbc	hl,de
	adc	a,a
	add	hl,de		;hl - original destination address
	ex	de,hl
	cp	3
	jr	nz,movb00	;head to head
	ex	de,hl
	add	hl,bc
	dec	hl
	ex	de,hl
	lddr
	ret
movb00:	inc	hl
	and	a
	sbc	hl,bc
	ldir
	ret

;******************************************************************************
;*
;*	yfil:	fill memory
;*
;*	call bcde to get byte count, starting address, and fill byte
;*
;*	exit:	to z8e for next	command
;*
;******************************************************************************

yfil:	call	bcde		;bc - byte count  de - fill byte  hl - block
	jp	nz,exxx		;input error ends command
	ex	de,hl
yfil00:	ld	hl,argbf
	ld	a,(argbc)
yfil10:	ldi
	inc	b
	djnz	yfil20
	inc	c
	dec	c
	ret	z
yfil20:	dec	a
	jr	nz,yfil10
	jr	yfil00

;
cuser:	ret

;*******************************************************************
;
;	QEVAL - expression evaluator	EG 10 Jan 88
;
;	Uses '?' as command
;
;*******************************************************************
qeval: 	call 	iedtbc		; get input
	ret		m		; none
	call		iarg		; Z8E does all the real work
	jp		nz,exxx		; check for valid arg
	call		crlf
	ld		a,h		; see if 1 byte
	or		a
	jr		nz,qev01	; 2-byte number
	ld		a,l
	call		outhex		; hex byte
	ld		a,l
	cp		7fh		; see if printable
	ret		nc
	cp		' '
	ret		c
	ld		c,3
	call		spaces		; even up with spaces
	ld		a,27h		; quote
	call		ttyo
	ld		a,l		; show char
	call		ttyo
	ld		a,27h
	jp		ttyo
qev01:	jp 	outadr		; output 2-byte result


ifcb:	ret				;(Condensed, improved version - jrs 27 Dec 88)


disisr:	push	af
	ld 	a,irt
	ld	(rstvec),a
	pop	af
	ret

enaisr:	push	af
	ld 	a,ijp
	ld	(rstvec),a
	pop	af
	ret


lldr:	ret
writ:	ret


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

find:	call	iedtbc
	ret	m		;m - no	input
	call	iarg		;extract starting address of search
	jp	nz,exxx		;error
	ex	de,hl		;save starting address of search in de
find00:	call	in00		;extract search	string concatenating multiple
				;arguments
	jp	nz,exxx		;error - output	command	prompt
	xor	a
	ld	(lines),a	;clear crlf flag
	ex	de,hl		;starting address of search - hl
	ld	de,argbf	;argument stored here

	ld	bc,(fndsym)
	ld	a,c
	or	b		;symbol found?
	jp	z,find40	;no

	ex	de,hl		;hl - argument buffer
	ld	b,(hl)		;reverse order of the two bytes for symbols
	inc	hl
	ld	a,(hl)
	ld	(hl),b
	dec	hl
	ld	(hl),a
	ex	de,hl

find40:	ld	bc,(argbc)	;number	of bytes to look for
	call	crlf
find50:	call	srch		;do the	search
	jr	nz,find60	;not found
	call	outadr		;display address where match found
	ld	a,(lines)
	dec	a		;carriage return after 8 addresses displayed
	ld	(lines),a
	and	7
	call	z,crlf
	call	ttyq		;user requesting abort?
	cp	cr
	ret	z		;abort - return	to z8e
find60:	inc	hl		;point to next address at which	to start search
	add	hl,bc		;ensure	we won't hit end of memory by adding
				;in string size
	ret	c		;impending end of memory
	sbc	hl,bc		;restore pointer
	jr	find50

srch:	push	bc
	push	de
	push	hl
srch00:	ld	a,(de)
	cpi
	jp	nz,srch10	;no match
	inc	de
	jp	pe,srch00	;tally not expired - check next
srch10:	pop	hl
	pop	de
	pop	bc
	ret

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

verify:	call	bcde		;get block 2 address and byte count
	jp	nz,exxx
	ex	de,hl
verf00:	ld	a,(de)		;byte from block 1
	xor	(hl)		;versus	byte from block	two
	jr	z,verf10	;match - no display
	call	newlin
	ld	a,(de)
	call	othxsp		;display block 1 data
	call	rspace
	call	outadr		;display block two address
	ld	a,(hl)
	call	outhex		;display results of xor
	call	ttyq		;check input status
	cp	cr
	ret	z
verf10:	inc	hl		;bump block 1 pointer
	inc	de		;bump block 2 pointer
	dec	bc		;dec byte count
	ld	a,b
	or	c
	jr	nz,verf00
	ret

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

xreg:	call	cret
	ld	bc,0		;init reg index
xreg00:	call	xreg05		;display reg name and contents
	inc	c
	ld	a,c
	cp	8
	call	z,crlf
	ld	a,c
	cp	0ch
	ld	b,0
	jr	nz,xreg00
	ld	a,(lcmd)
	cp	'J'		;animated command in effect?
	ret	z		;z - no disassembly required
	ld	hl,(pcreg)
	ld	(zasmpc),hl
;	jp	zasm30		;- eg 3.3.5b
	call	zasm30		;+
	jp	pswdsp		;+

xreg05:	ld	hl,regptr	;map of	reg name pointers
	ld	d,b
	add	hl,bc
	ld	a,(hl)		;extract pointer
	and	7fh		;strip sign for	name indexing
	ld	e,a
	ld	b,(hl)		;save copy of offset - need sign later
	ld	hl,zopnm	;register name table
	add	hl,de
	add	hl,de		;two bytes per entry
	ld	a,(hl)
	call	ttyo		;display character one
	inc	hl
	ld	a,(hl)
	cp	' '		;is second character a space?
	jr	nz,xreg10
	ld	a,'C'		;replace space - this is pc
xreg10:	call	ttyo		;display second	character
	xor	a
	or	b		;now test sign
	jp	p,xreg20	;sign not set -	not prime reg
	ld	a,27h		;display quote
	call	ttyo
xreg20:	ld	a,':'
	call	ttyo
	ld	hl,regmap	;map of	pointers to reg	contents
	add	hl,de
	ld	a,(hl)
	jp	p,xreg30	;p - not prime reg
	add	a,8		;prime contents	8 bytes	past non-prime
xreg30:	and	7fh		;ignore	sign
	ld	e,a
	ld	hl,regcon	;start of register contents storage
	add	hl,de
	ld	d,(hl)		;hi order contents
	dec	hl
	ld	e,(hl)
	ex	de,hl
	call	outadr		;display contents
	ret


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


zasm:
	call	iedtbc

;	ret	m		;- eg 3.3.2
	jp	p,zasm0		;+ Skip if arguments supplied, otherwise ...
	ld	b,0		;+ Signal no file write
	ld	hl,16		;+ Assume 16 lines of code
	ld	(zasmwt),hl	;+
	ld	(zasmct),hl	;+
	jr	zasm06		;+
zasm0:				;+
	call	iarg
	jp	nz,exxx
	ex	de,hl
	call	iarg		;read in block size
	ld	b,a		;save delimeter
	jr	z,zasm00
	ld	hl,1		;change	zero count to one
zasm00:	xor	a
	or	h
	jr	z,zasm05
	sbc	hl,de
	jp	c,exxx		;error - start address greater than end
	add	hl,de
zasm05:	ld	(zasmct),hl	;save as permanent block count
	ld	(zasmwt),hl	;save as working tally
	ex	de,hl		;hl - current instruction pointer
	ld	(zasmpc),hl
zasm06:				;+ eg 3.3.2
	call	crlf
; 	LD	A,B		;check command line delimeter
; 	LD	(DWRITE),A	;save as write to disk flag:
				;z - no write   nz - write
; 	AND	A
; 	CALL	NZ,BLDF		;not end of line - build fcb
; 	JP	NZ,ESNTX
	xor	a

zasm08:	ld	de,zasmbf	;start of disassembly buffer

zasm10:	ld	(zasmio),de	;init pointer

zasm15:	ld	de,(zasmpc)	;fetch address to disassemble
	call	zlen00		;calculate length
	ex	de,hl

				;loop back here for interactive disassembly -
				;user requests format change. c reg:
				;     6 and 7 off: disassemble as code
				;     6       on:  hex defb
				;     7       on:  hex defw or ascii defb

zasm18:	call	outadr		;display instruction address
	ld	de,zmflag
	ld	a,c		;save instruction length and format bits
	ld	(de),a
	and	3fh
	ld	b,a		;b  - length
	ld	c,a		;c  - ditto
zasm20:	ld	a,(hl)
	call	othxsp		;display object	code
	inc	hl
	djnz	zasm20
	ld	a,c		;number	of object bytes
	dec	a
	xor	3
	ld	b,a		;calculate space padding
	add	a,a
	add	a,b
	add	a,2
	ld	b,a
zasm25:	call	rspace
	djnz	zasm25
	ld	(zasmnx),hl	;store address of next instruction
	and	a		;clear carry
	sbc	hl,bc		;point to first	byte in	instruction
zasm30:	ex	de,hl		;de - current instruction pointer
	ld	hl,(zasmio)	;buffer	address	storage
	ld	a,(maxlin)
	ld	b,a		;line length based on max symbol size
zasm35:	ld	(hl),' '	;space out buffer
	inc	hl
	djnz	zasm35
	ld	a,b
	ld	(opnflg),a
	ld	(hl),cr		;append	crlf
	inc	hl
	ld	(hl),lf
	call	fadr		;find address match
	ld	hl,(zasmio)
	jr	nz,zasm40	;nz - no table or not found
	call	xsym
	ld	(hl),':'
	ld	de,(zasmpc)
zasm40:	ld	hl,zmflag	;check interactive disassembly flag
	ld	a,(hl)		;sign bit tells all
	and	a
	jp	p,zasm42	;bit off - not interactive
	ld	b,6dh		;test for defb
	sub	82h
	jr	z,zasm90
	xor	a		;must be defw
	dec	b
	jr	zasm90
zasm42:	ld	a,(de)		;first byte of op code
	ld	hl,op1000	;table of z80 specific opcodes
	ld	c,4
zasm45:	cpir			;check for fd dd ed or cb
	jr	z,zasm55	;z - found
zasm50:	cp	40h
	jr	c,zasm90	;opcode	range 0	- 3f
	ld	b,0e0h		;
	cp	0c0h		;
	jr	nc,zasm90	;opcode	range c0 - ff
	cp	80h
	jr	nc,zasm85	;opcode	range 80 - bf
	ld	b,0f8h		;
	cp	76h		;test for halt instruction
	jr	nz,zasm85	;opcode	range 40 - 7f
	ld	a,0ffh		;set halt instruction key value	to 0f7h
	jr	zasm90
zasm55:	inc	de
	ld	a,(de)		;byte two of multi-byte	instruction
	dec	c		;test for ed instruction
	jr	nz,zasm65	;nz - not an ed
	cp	80h
	jr	nc,zasm60	;opcode	range ed 40 - ed 7f
	cp	40h
	jr	nc,zasm90	;legal
	ld	a,09fh
	jr	zasm90		;map to	question marks
zasm60:	ld	b,0e0h		;set bias
	cp	0c0h		;test for illegal ed
	jr	c,zasm90	;legal
	ld	a,0bfh		;map to	question marks
	jr	zasm90		;opcode	range ed a0 - ed bb


zasm65:	inc	c
	jr	z,zasm80	;z - cb	instruction
	cp	0cbh		;fd or dd - check for cb in byte two
	jr	nz,zasm70
	inc	de		;fetch last byte of fdcb or ddcb
	inc	de
	ld	a,(de)
	rrca
	jr	c,zasm75
	and	3
	cp	3
	jr	nz,zasm75	;error
	ld	a,(de)
	jr	zasm80
zasm70:	ld	a,(zmflag)
	sub	3
	ld	a,(de)
	jr	nz,zasm50
	ld	hl,z80f3
	ld	c,z80f3l
	cpir
	jr	z,zasm50
zasm75:	ld	a,09fh
	jr	zasm90
zasm80:	cp	40h		;test type of cb instruction
	ld	b,0e8h
	jr	c,zasm85	;opcode	range cb 00 - cb 3f (shift)
	rlca
	rlca
	and	03		;hi order bits become index
	ld	b,0f0h
	jr	zasm90		;opcode	range cb 40 - cb ff
zasm85:	rrca
	rrca
	rrca			;bits 3-5 of cb	shift yield key
	and	07h
zasm90:	add	a,b		;add in	bias from b reg
	ld	c,a		;c - instruction key value
	xor	a
	ld	b,a
	ld	hl,zopcpt	;opcode	name pointer table
	add	hl,bc		;index into table
	ld	l,(hl)		;fetch opname index
	ld	h,a
	add	hl,hl
	add	hl,hl		;index times four
	ld	de,zopcnm	;op code name table
	add	hl,de
	ex	de,hl		;de - pointer to opcode	name
	ld	hl,(zasmio)	;buffer	pointer	storage
	ld	a,c
	ld	(zasmkv),a	;opcode key value
	ld	a,(maxlen)
	ld	c,a
	inc	c		;set label length based on max size

	ld	a,(lcmd)	;if xreg use compressed output format
	cp	'X'
	jr	z,zasm92
	cp	'S'		;step needs compressed format
zasm92:	add	hl,bc
	ld	c,4
	ex	de,hl		;de - buffer   hl - opcode name	pointer
	ldir
	inc	bc		;one space after opcode	for compressed format
	jr	z,zasm95
	ld	c,4		;four spaces for true disassembly
zasm95:	ex	de,hl		;hl - buffer pointer
	add	hl,bc		;start of operand field	in buffer
	ld	a,(zasmkv)	;save the instruction key value
	cp	09fh
	jr	nz,zasm99
	ld	de,(zasmpc)
	ld	a,(zmflag)
	ld	b,a
zasm97:	ld	a,(de)
	ld	c,d
	call	zhex
	dec	b
	jp	z,opn020
	ld	(hl),','
	inc	hl
	ld	d,c
	inc	de
	jr	zasm97
zasm99:	ld	de,zopnd1	;table of first	operands
	add	a,e
	ld	e,a		;instant offset
	ld	a,d
	adc	a,b
	ld	d,a
	ld	a,(de)
	inc	a
	jr	z,opn040	;no operands


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

opn:	dec	a		;save operand key value
	jp	p,opn010
	ld	(hl),'('
	inc	hl
opn010:	ex	de,hl		;de - buffer address
	ld	b,a
	add	a,a		;operand key value times two
opn012:	ld	hl,zopnm	;base of operand name/jump table
	add	a,l		;index into table
	ld	l,a
	jr	nc,opn014
	inc	h		;account for carry
opn014:	ld	a,1fh
	and	b
	cp	zopnml		;test if processing required
	jr	c,opn015	;c - operand is	a fixed	literal
	ld	a,(hl)		;fetch processing routine address
	inc	hl
	ld	h,(hl)		;
	ld	l,a		;hl - operand processing routine
	jp	(hl)		;geronimoooooooo
opn015:	ldi			;first byte of operand literal
	inc	bc		;compensate for	ldi
	ex	de,hl		;hl - buffer
	ld	a,(de)
	cp	' '		;test for space	as byte	two of literal
	jr	z,opn020	;ignore	spaces appearing in byte two
	ld	(hl),a
	inc	hl		;bump buffer pointer
opn020:	ld	a,b		;operand key value
	cp	80h		;test for closed paren required
	jr	c,opn030	;c - none required
	ld	(hl),')'
	inc	hl
opn030:	ld	a,(opnflg)	;get flag byte
	xor	0ffh		;toggle operand number
	ld	(opnflg),a	;
	jr	z,opn040	;z - just finished number two
	ld	a,(zasmkv)	;get op code key value
	ld	de,zopnd2	;index into operand2 table
	add	a,e
	ld	e,a
	jr	nc,opn035
	inc	d
opn035:	ld	a,(de)		;get operand2 key value
	inc	a
	jr	z,opn040	;z - no	second operand
	ld	(hl),','	;separate operands with comma in buffer
	inc	hl
	jr	opn
opn040:	ld	hl,(zasmio)	;rewind	buffer pointer
	ld	a,(maxlin)
	ld	c,a
opn041:
	ld	a,(case)
	and	a
	jr	z,opn043	;Upper case requested - no need to convert
				;reg names [ras 19 Sep 85]
opn042:	ld	a,(hl)
	and	a		;if sign bit on then no case conversion
	call	p,ilcs
	and	7fh		;in case we fell thru
	ld	(hl),a
	inc	hl
	dec	c
	jr	nz,opn042
opn043:				;correct jmp from opn041 4-9-85
	ld	a,(maxlin)
	cp	30
	jr	z,opn044
	ld	a,44		;allow 16 comment chars
opn044:
	ld	c,a		;number of chars to print (omit crlf)
	ld	hl,(zasmio)
	ld	a,(lcmd)
	cp	'J'		;j command
	ret	z		;end of the line for full screen animation
	call	printb		;print buffer
	inc	hl		;point past crlf to next 32 byte group
	inc	hl
	ex	de,hl
	ld	a,(lcmd)	;jettison all commands except z
	cp	'X'
	jp	z,crlf
	cp	'A'
	jp	z,crlf
	cp	'S'
	jp	z,crlf
	xor	a
	ld	(zasmf),a
	ld	hl,(zasmct)	;check disassembly count
	dec	hl
	ld	a,h
	or	l		;test for count expired
	jp	nz,opn060	;nz - this is not a count of one so this is not
				;interactive disassebly

	call	ttyi		;check input command letter for interactive
	call	ixlt		;force upper case
	ld	(zasmf),a
	cp	'C'		;code?
	call	z,cret		;if user wants code return cursor to start of
				;line and disassemble again
	jp	z,zasm15
	ld	c,82h		;assume defw
	cp	'D'
	jr	z,opn045	;defw -	082h
	dec	c		;assume ascii defb
	cp	'A'
	jr	z,opn045	;ascii defb - 081h
	cp	'B'
	jr	nz,opn046	;none of the above
	ld	c,0c1h		;hex defb - 0c1h
opn045:	call	cret
	ld	hl,(zasmpc)
	jp	zasm18

				;zasmf - 0 means this is block disassembly
				;      - nz means char entered during
          			;        interactive mode was not c d a or b.

opn046:	cp	';'		;check if user wants to insert comments
	jr	nz,opn060	;nz - user does not want to add comment

	call	ttyo		;echo semicolon
	dec	de
	dec	de		;point to carriage return
	ld	a,' '
	ld	(de),a		;clear crlf from buffer
	inc	de
	ld	(de),a
	inc	de
	call	write		;end of buffer - write if required
	ld	b,29
	ld	a,(maxlin)
	sub	30
	jp	z,opn048
	dec	de
	ld	b,16
	xor	a
opn048:	ld	c,a
	push	bc
	push	de		;save disassembly buffer pointer
	ld	d,a
	call	iedt03
	pop	de
	pop	bc
	ld	a,b		;recover max size of comment
	dec	hl
	ld	b,(hl)		;number actually entered
	sub	b
	ld	c,a		;trailing spaces
	inc	hl
	ex	de,hl		;de - input buffer   hl - disassembly buffer
	ld	(hl),';'
	inc	hl
opn049:	dec	b		;pre-test count
	jp	m,opn050
	ld	a,(de)		;first char of input
	inc	de
	ld	(hl),a		;into disassembly buffer
	inc	hl
	jr	opn049
opn050:	dec	c
	jp	m,opn055
	ld	(hl),' '
	inc	hl
	jr	opn050
opn055:	ld	(hl),cr
	inc	hl
	ld	(hl),lf
	inc	hl
	ex	de,hl
	jp	opn065

opn060:
	ld	a,(maxlin)
	cp	30		;test for 6 chars in label
	jp	z,opn065	;z - buffer point ok
	ld	a,64-46		;bump buffer pointer to next 64 byte chunk
	add	a,e
	ld	e,a
	jp	nc,opn065
	inc	d

opn065:	call	write		;check if write to disk flag in effect

	call	crlf
	ld	(zasmio),de	;save new buffer pointer
	ld	hl,(zasmwt)	;check disassembly count
	xor	a
	or	h		;less than 256?
	jr	z,opn080	;less -	this is	tally
	ld	bc,(zasmnx)	;fetch next disassembly	address
	sbc	hl,bc		;versus	requested end address
	jr	c,opn095	;c - end
	add	hl,bc		;restore next disassembly address
	jr	opn085		;more
opn080:	dec	hl
	ld	a,h
	or	l
	jr	nz,opn085	;nz - more
	ld	hl,(zasmct)	;fetch permanent block size
	ld	a,(zasmf)
	and	a
	call	z,ttyi		;query user - more?
	cp	cr		;return	means end
	jr	z,opn095
	jr	opn090
opn085:
	call	ttyq
	cp	cr
	jr	z,opn095	;nz - terminate	disassembly
opn090:
	ld	(zasmwt),hl	;restore count
	ld	hl,(zasmnx)	;next instruction pointer
	ld	(zasmpc),hl	;make current
	jp	zasm15		;disassemble next instruction

opn095:	ld	a,(dwrite)	;writing to disk?
	and	a
	ret	z
	ld	a,eof		;
	ld	(de),a		;set eof
	ld	de,zasmbf
	ret

write:	push	bc
	push	hl
	ld	hl,nzasm	;address of end of disassembly buffer
	and	a
	sbc	hl,de
	jr	nz,wrt10	;not end of buffer
	ld	de,zasmbf	;need to rewind buffer pointer
; 	LD	A,(DWRITE)	;test write to disk flag
; 	AND	A
; 	CALL	NZ,BDWRIT	;nz - writing to disk
wrt10:	pop	hl
	pop	bc
	ret


opn100:	ld	hl,(zasmpc)
	inc	hl
	ld	a,(hl)		;fetch relative	displacement
	ld	c,a
	inc	c
	add	a,a		;test sign for displacement direction
	ld	b,0
	jr	nc,opn105
	dec	b		;produce zero for forward - ff for back
opn105:	add	hl,bc		;adjust	pc
	ex	de,hl		;de - instruction ptr	hl - buffer
	call	fadr
	call	z,xsym
	jp	z,opn040	;symbol	found
;	ld	(hl),'$'	;- eg 3.3.4a
;	inc	hl		;-
;	ld	a,c		;-
;	inc	a		;-
	ld	b,0
;	cp	82h		;-
;	jp	opn610		;- convert displacement to ascii
	jp	opn316		;+

opn200:	call	zmqf		;check for interactive disassembly
	jr	nc,opn205	;sign off - not interactive
	add	a,a		;shift out bit 6
	ld	a,(hl)
	jr	c,opn215	;on - must be hex defb
	call	zascii		;user wants ascii - check validity
	jr	nz,opn215	;nz - untable to convert to ascii
	jp	opn020
opn205:	call	zndx		;check for ix or iy instruction
	ex	de,hl		;buffer back to de
	jr	nz,opn210	;nz - not ix or	iy
	inc	hl
	inc	hl		;must be  ld (ix+ind),nn
opn210:	inc	hl		;
	ld	a,(hl)		;fetch object byte
	jr	z,opn215	;no conversion of ix and iy displacements
				;to ascii
	ld	a,(zasmkv)	;check for in or out instruction
	cp	0b3h
	jr	z,opn215	;no conversion of port addresses to ascii
	cp	0bbh
	jr	z,opn215
	ld	a,(hl)
	call	zascii
	jp	z,opn020
opn215:	ex	de,hl
	ld	a,(de)
	cp	10		;decimal number?
	jr	nc,opn220	;no - convert to hex
	call	zhex20		;86 the	leading	zero and trailing h
	jp	opn020
opn220:	call	zhex		;do hex	to asii	conversion
	ld	(hl),'H'	;following 8 bit hex byte
	inc	hl
	jp	opn020

opn300:	call	zmqf
	jr	c,opn315	;c - this is defw
	call	zndx
	ex	de,hl		;de - buffer   hl - instruction	pointer
	jr	nz,opn310	;nz - not ix or	iy
	inc	hl
opn310:	inc	hl
opn315:	ld	a,(hl)		;fetch lo order	16 bit operand
	inc	hl
	ld	h,(hl)		;hi order
	ld	l,a
	ex	de,hl		;de - 16 bit operand   hl - buffer
	call	fadr
	call	z,xsym
	jp	z,opn020	;symbol	found
opn316:				;+ eg 3.3.4b
	ld	a,d		;convert hi order to hex
	ld	c,a		;save spare copy
	call	zhex
	ld	a,e
	ld	d,a
	call	zhex10
	xor	a
	or	c
	jr	nz,opn320
	ld	a,d
	cp	10
	jp	c,opn020
opn320:	ld	(hl),'h'
	inc	hl
	jp	opn020

opn400:
	call	zndx
	jr	nz,opn410	;nz - not ix or	iy instruction
	inc	de
	ld	a,(de)
	cp	0cbh		;check for indexed bit instruction
	jr	nz,opn410
	inc	de		;byte of interest is number four
	inc	de
opn410:	ld	a,01		;check low bit of operand key value
	and	b
	ld	a,(de)		;fetch op code
	jr	nz,opn500	;nz - index 01bh
	rra			;register specified in bits 0-5
	rra
	rra
opn500:	and	007		;register specified in bits 0-2
	xor	006		;from the movie	of the same name
	jp	nz,opn010	;nz - not hl or	ix or iy
	ld	a,(zasmpc)
	xor	e		;test if pc was	incremented
	ld	(hl),'('	;set leading paren
	inc	hl
	ld	b,080h		;set sign bit -	closed paren required
	ex	de,hl		;de - buffer
	jp	z,opn012



opn600:
	call	zndx		;determine if ix or iy
	jr	z,opn605	;z - must be ix	of iy
	ld	a,80h
	and	b
	jp	opn010
opn605:
				;+Fix display of IX/IY when upper case is set
	push	af		;+Adapted from patch by George Havach (3.5.7)
	ld	c,0dfh		;+Upper case mask
	ld	a,(case)	;+See if upper or lower case
	or	a		;+
	jr	z,opn606	;+Skip if upper case, otherwise
	ld	c,0ffh		;+ adjust mask
opn606:				;+
	ld	a,'i'		;+First character
	and	c		;+Select case
;	ld	(hl),'i'	;-Set first character
	ld	(hl),a		;+Set first character
	inc	hl
	pop	af		;+Second character
	adc	a,'x'		;Carry determines x or y (from zndx)
	and	c		;+Select case
	ld	(hl),a
	inc	hl
	ld	a,80h		;Test for parens
	and	b
	jp	z,opn030	;z - not indexed instruction
	inc	de
	ld	a,(de)		;fetch second byte of instruction
	cp	0e9h		;test for jp (ix) or jp	(iy)
	jp	z,opn020	;output	closed paren
	inc	de
	ld	a,(de)		;fetch displacement byte
	cp	80h		;test sign
opn610:	ld	(hl),'+'	;assume	forward
	jr	c,opn620	;c - forward
	neg			;force positive
	ld	(hl),'-'
opn620:	inc	hl		;bump buffer pointer
	and	7fh		;strip sign
	call	zhex		;convert to hex
	ld	a,9
	cp	d
	jp	nc,opn020
	ld	(hl),'h'
	inc	hl
	jp	opn020		;output	closed paren




opn700:	ld	hl,(zasmpc)
	ld	a,(hl)		;fetch restart instruction
	ex	de,hl		;de - buffer   hl instruction pointer
	and	38h
	call	zhex		;convert restart number	to ascii
	ld	(hl),'H'
	jp	opn020



opn800:	call	zndx
	jr	nz,opn810	;nz - not ddcb or fdcb instruction
	inc	de
	inc	de
	inc	de		;
	ld	a,(de)		;byte 4	of ix or iy bit	instruction
	jr	opn820
opn810:	cp	10h		;weed out interrupt mode instructions
	ld	a,(de)		;second	byte of	instruction regardless
	jr	nz,opn820	;nz - cb bit instruction
	xor	046h		;
	jr	z,opn830	;z - interrupt mode zero
	sub	8
opn820:	rra
	rra
	rra
	and	07		;leave only bit	number
opn830:	call	zhex20		;convert to ascii
	jp	opn030

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

zndx:	ld	hl,(zasmpc)	;fetch current instruction pointer
	ex	de,hl		;de - instruction pointer   hl - buffer
	ld	a,(de)
;	ADD	A,-0FDH		;iy check
	add	a,$03		;iy check
	ret	z
	sub	0ddh-0fdh	;ix check
	ret	z
	cp	10h		;ed check
	jr	z,zndx00
	cp	0eeh		;cb check
	ld	a,0		;clear
	ret	nz
zndx00:	inc	de		;cb or ed - bump instruction pointer
	cpl
	and	a		;ensure	nz set
	cpl
	ret



zhex:	ld	d,a
	cp	0a0h		;test byte to convert
	jr	c,zhex00	;starts	with decimal digit - 86	the lead zero
	ld	(hl),'0'
	inc	hl
	jr	zhex10
zhex00:	cp	10
	jr	c,zhex20
zhex10:	rrca
	rrca
	rrca
	rrca
	and	0fh
	add	a,90h
	daa
	adc	a,40h
	daa			;a - ascii digit
	ld	(hl),a
	inc	hl
	ld	a,d		;lo nibble conversion
zhex20:	and	0fh
	add	a,90h
	daa
	adc	a,40h
	daa
	ld	(hl),a
	inc	hl
	ret



zmqf:	ld	hl,zmflag	;check interactive disassembly flag
	ld	a,(hl)
	ld	(hl),0		;clear regardless
	ld	hl,(zasmpc)	;fetch current disassembly address
	add	a,a		;check sign - on means interactive
	ret


zascii:	cp	' '
	ret	c
	and	a
	ret	m
	cp	7fh		;rubout?
	jr	z,zasc10
	cp	quote
	jr	nz,zasc20
zasc10:	and	a		;set nz - conversion not done
	ret
zasc20:	ex	de,hl
	ld	(hl),quote	;defb -	quoted character
	inc	hl
; 	OR	80H		;hi bit on - no case conversion for this guy
	ld	(hl),a
	inc	hl
	ld	(hl),quote
	cp	a
	ret



fadr:	push	bc
	push	hl
	ld	hl,(bdosad)	;fetch top of tpa - start of symbol table
	ld	bc,(maxlen)
	add	hl,bc		;point to start of symbol name
	inc	hl
fadr00:	ld	a,(hl)		;first byte of symbol name
	dec	a		;check validity
	jp	m,fadr30	;end of	table
	add	hl,bc
	ld	a,(hl)		;fetch hi order	address	from table
	cp	d
	jp	nz,fadr10
	dec	hl
	ld	a,(hl)
	inc	hl
	cp	e
	jp	z,fadr20
fadr10:	inc	hl
	jp	fadr00
fadr20:	ex	de,hl		;return pointer in de
	ld	a,c
	cpl
	and	e
	ld	e,a
	xor	a
fadr30:	pop	hl
	pop	bc
	ret

xsym:
	ld	a,(maxlen)
	dec	a
	ld	c,a
xsym00:	ld	a,(de)
	and	a
	ret	z
	ld	(hl),a
	inc	hl
	inc	de
	dec	c
	jr	nz,xsym00
	ret

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

bcde:	call	iedtbc
	ret	m		;no input is treated as	error
	call	iarg		;read in starting block	address
	ret	nz
	ex	de,hl
	call	iarg
	ret	nz
	sbc	hl,de		;end - start = byte count - 1
	ret	c
	ld	b,h
	ld	c,l
	inc	bc
	call	in00		;read in destination block address
	ret	nz
	ex	de,hl		;set regs right
	ret


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
crtbase		equ	$80
	; RAM0 for ascii chars & semi6. Combined with RAM1 and RAM2 for graphics
crtram0dat	equ	crtbase		; RAM0 access: PIO0 port A data register
crtram0cnt	equ	crtbase+2	; RAM0 access: PIO0 port A control register
	; Printer port
crtprntdat	equ	crtbase+1	; PRINTER (output): PIO0 port B data register
crtprntcnt	equ	crtbase+3	; PRINTER (output): PIO0 port B control register
					; STROBE is generated by hardware
	; RAM1 for graphics. (pixel index by RAM0+RAM1+RAM2)
crtram1dat	equ	crtbase+4	; RAM1 access: PIO1 port A data register
crtram1cnt	equ	crtbase+6	; RAM1 access: PIO1 port A control register
	; Keyboard port (negated). Bit 7 is for strobe
crtkeybdat	equ	crtbase+5	; KEYBOARD (input): PIO1 port B data register
crtkeybcnt	equ	crtbase+7	; KEYBOARD (input): PIO1 port B control register
keybstrbbit	equ	7		; Strobe bit
	; RAM2 for graphics. (pixel index by RAM0+RAM1+RAM2)
crtram2dat	equ	crtbase+8	; RAM2 access: PIO2 port A data register
crtram2cnt	equ	crtbase+10	; RAM2 access: PIO2 port A control register
	; Service/User port
crtservdat	equ	crtbase+9	; Service (i/o): PIO2 port B data register
crtservcnt	equ	crtbase+11	; Service (i/o): PIO2 port B control register
prntbusybit	equ	0		; Printer BUSY bit		(in)	1
crtwidthbit	equ	1		; Set 40/80 chars per line	(out)	0
pio2bit2	equ	2		; user 1 (input)		(in)	1
pio2bit3	equ	3		; user 2 (input)		(in)	1
pio2bit4	equ	4		; user 3 (input)		(in)	1
clksclk		equ	5		; DS1320 clock line		(out)	0
clkio		equ	6		; DS1320 I/O line		(i/o)	1
clkrst		equ	7		; DS1320 RST line		(out)	0
	; normal set for PIO2 (msb) 01011101 (lsb) that is hex $5D
					; Other bits available to user
	; RAM3 control chars/graphics attributes
crtram3port	equ	crtbase+14	; RAM3 port
crtblinkbit	equ	0		; Blink
crtrevrsbit	equ	1		; Reverse
crtunderbit	equ	2		; Underline
crthilitbit	equ	3		; Highlight
crtmodebit	equ	4		; ASCII/GRAPHIC mode
	; Beeper port
crtbeepport	equ	crtbase+15	; Beeper port
	; 6545 CRT controller ports
crt6545adst	equ	crtbase+12	; Address & Status register
crt6545data	equ	crtbase+13	; Data register

iocbase:
	ret			; null entry. start of control routines vector

movlft:
	call	gcrspos
	dec	hl
	ld	de,(curpbuf)
	xor	a
	sbc	hl,de
	cp	h
	jr	nz,movlft1
	cp	l
	ret	z
movlft1:
	dec	hl
	add	hl,de
	call	scrspos
	push	hl
	ld	a,(colbuf)
	dec	a
	cp	$ff
	jr	nz,movlft2
	ld	a,$4f
movlft2:
	ld	(colbuf),a
	ld	hl,miobyte
	bit	4,(hl)
	pop	hl
	ret	nz
	ld	a,$20
; 	JP	DISMVC
	jp	dispch

movdwn:
	call	gcrspos
	dec	hl
	ld	de,$0050
	add	hl,de
	call	scrspos
	jp	lfeed1

lfeed:
	xor	a
	ld	(colbuf),a
lfeed1:	call	scrtst
	ret	c
	ld	hl,miobyte
	bit	2,(hl)
	ld	de,$f830
	call	gcrspos
	dec	hl
	jr	z,mdjmp0
	add	hl,de
	jp	scrspos
mdjmp0:	push	hl
	call	clrlin
	ld	hl,(curpbuf)
	ld	de,$0050
	add	hl,de
	ld	de,$0820
	push	hl
	sbc	hl,de
	pop	hl
	jr	c,mdjmp1
	res	3,h
mdjmp1:	ld	(curpbuf),hl
	call	sdpysta
	pop	hl
	jr	c,mejp
	res	3,h
mejp:	jp	scrspos

clrscr:
	ld	hl,$0000
	xor	a
	ld	(colbuf),a
	cpl
	ld	(ram3buf),a
	ld	(curpbuf),hl
	call	scrspos
	call	sdpysta
	push	hl
clsnc:	ld	a,$20
	call	dispch
	inc	hl
	ld	a,h
	cp	$08
	jr	nz,clsnc
	pop	hl
	jp	scrspos

ioccr:
	ex	de,hl
	bit	3,(hl)
	jr	z,ioccr1
	call	clreol
ioccr1:	jp	chome

siocesc:
	ex	de,hl
	set	7,(hl)
	ret

dispch:
	push	af
dgclp0:	in	a,(crt6545adst)
	bit	7,a
	jr	z,dgclp0
	pop	af
	out	(crtram0dat),a
	ld	a,(ram3buf)
	out	(crtram3port),a
	xor	a
	out	(crt6545data),a
	ret

gcrspos:
	ld	a,$0e
	out	(crt6545adst),a
	in	a,(crt6545data)
	ld	h,a
	ld	a,$0f
	out	(crt6545adst),a
	in	a,(crt6545data)
	ld	l,a
	inc	hl
	jp	crtprgend

sdpysta:
	ld	a,$0c
	out	(crt6545adst),a
	ld	a,h
	out	(crt6545data),a
	ld	a,$0d
	out	(crt6545adst),a
	ld	a,l
	out	(crt6545data),a
	jp	crtprgend

scrspos:
	ld	a,$0e
	out	(crt6545adst),a
	ld	a,h
	out	(crt6545data),a
	ld	a,$0f
	out	(crt6545adst),a
	ld	a,l
	out	(crt6545data),a
scrspos1:
	ld	a,$12
	out	(crt6545adst),a
	ld	a,h
	out	(crt6545data),a
	ld	a,$13
	out	(crt6545adst),a
	ld	a,l
	out	(crt6545data),a
	jr	crtprgend

scrtst:
	ld	de,(curpbuf)
	xor	a
	sbc	hl,de
	ld	a,h
	cp	$07
	ret	c
	ld	a,l
	cp	$cf
	ret

clrlin:
	ld	bc,$0050
clrlin1:
	ld	a,(ram3buf)
	push	af
	ld	a,$ff
	ld	(ram3buf),a
clrlp1:	ld	a,$20
	call	dispch
	dec	bc
	ld	a,b
	or	c
	jr	nz,clrlp1
	pop	af
	ld	(ram3buf),a
	ret

clreop:
	xor	a
	ld	hl,(curpbuf)
	ld	de,$07d0
	add	hl,de
	ex	de,hl
	call	gcrspos
	dec	hl
	ex	de,hl
	sbc	hl,de
	push	hl
	pop	bc
clrj0:	call	clrlin1
	ex	de,hl
	jp	scrspos

clreol:
	ld	a,(colbuf)
	ld	b,a
	ld	a,$50
	sub	b
	ld	b,$00
	ld	c,a
	call	gcrspos
	dec	hl
	ex	de,hl
	jr	clrj0

chome:
	ld	hl,colbuf
	ld	e,(hl)
	xor	a
	ld	(hl),a
	ld	d,a
	call	gcrspos
	dec	hl
	sbc	hl,de
	call	scrspos
	ret

crtprgend:
	ld	a,$1f
	out	(crt6545adst),a
	ret


iocvec:
	dw	iocbase			; NUL 0x00 (^@)  no-op
	dw	iocbase		; SOH 0x01 (^A)  uppercase mode
	dw	iocbase		; STX 0x02 (^B)  normal case mode
	dw	iocbase			; ETX 0x00 (^C)  no-op
	dw	iocbase			; EOT 0x04 (^D)  cursor off
	dw	iocbase			; ENQ 0x05 (^E)  cursor on
	dw	iocbase			; ACK 0x06 (^F)  locate cursor at CURPBUF
	dw	iocbase			; BEL 0x07 (^G)  beep
	dw	movlft			; BS  0x08 (^H)  cursor left (destr. and non destr.)
	dw	iocbase			; HT  0x09 (^I)  no-op
	dw	movdwn			; LF  0x0a (^J)  cursor down one line
	dw	chome			; VT  0x0b (^K)  cursor @ column 0
	dw	clrscr			; FF  0x0c (^L)  page down (clear screen)
	dw	ioccr			; CR  0x0d (^M)  provess CR
	dw	iocbase			; SO  0x0e (^N)  clear to EOP
	dw	iocbase			; SI  0x0f (^O)  clear to EOL
	dw	iocbase			; DLE 0x10 (^P)  no-op
	dw	iocbase			; DC1 0x11 (^Q)  reset all attributes
	dw	iocbase			; DC2 0x12 (^R)  no-op
	dw	iocbase			; DC3 0x13 (^S)  no-op
	dw	iocbase			; DC4 0x14 (^T)  no-op
	dw	iocbase			; NAK 0x15 (^U)  no-op
	dw	iocbase		; SYN 0x16 (^V) scroll off
	dw	iocbase		; ETB 0x17 (^W) scroll on
	dw	iocbase			; CAN 0x18 (^X) hard crt reset and clear
	dw	iocbase			; EM  0x19 (^Y)  no-op
	dw	iocbase			; SUB 0x1a (^Z)  no-op
	dw	siocesc			; ESC 0x1b (^[) activate alternate output processing
	dw	iocbase			; FS  0x1c (^\) no-op
	dw	iocbase			; GS  0x1d (^]) no-op
	dw	iocbase			; RS  0x1e (^^) disabled (no-op)
	dw	iocbase			; US  0x1f (^_)  no-op

miobyte:defb	0
colbuf:	defb	0
ram3buf:defb	$ff
curpbuf:defw	0
tmpbyte:defb	0
appbuf:	defw	0


zconout:
	push	af
	push	bc
	push	de
	push	hl
	; force jump to register restore and exit in stack
	ld	hl,bcexit
	push	hl
	;
	ld	a,c
	ld	hl,miobyte
	bit	7,(hl)			; alternate char processing ?
	ex	de,hl
	jr	nz,conou2		; yes: do alternate
	cp	$20			; no: is less then 0x20 (space) ?
	jr	nc,cojp1		; no: go further
	add	a,a			; yes: is a special char
	ld	h,0
	ld	l,a
	ld	bc,iocvec
	add	hl,bc
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	jp	(hl)			; jump to IOCVEC handler
cojp1:	ex	de,hl
	bit	6,(hl)			; auto ctrl chars ??
	jr	z,cojp2			; no
	cp	$40			; yes: convert
	jr	c,cojp2
	cp	$60
	jr	nc,cojp2
	sub	$40
cojp2:	call	dispch			; display char
	; move cursor right
movrgt:
	call	gcrspos			; update cursor position
	call	scrspos
	ld	a,(colbuf)
	inc	a
	cp	$50
	jp	z,lfeed			; go down if needed
;;
savcolb:
	ld	(colbuf),a		; save cursor position
	ret
conou2:					; alternate processing....
	cp	$20			; is a ctrl char ??
	jr	nc,curadr		; no: will set cursor pos
	ret				; ignore
;; cursor addressing service routine
;; address is ESC + (COL # + 32) + (ROW # + 32) (then need a NUL to terminate...)
curadr:	ld	hl,tmpbyte
	bit	0,(hl)
	jr	nz,setrow
	cp	$70			; greater then 80 ?
	ret	nc			; yes: error
	sub	$20			; no: ok
	ld	(appbuf),a		; store column
	set	0,(hl)			; switch row/col flag
	ret
setrow:	cp	$39			; greater than 24 ?
	ret	nc			; yes: error
	sub	$1f			; no: ok
	res	0,(hl)			; resets flags
	ld	hl,miobyte
	res	7,(hl)			; done reset
	ld	b,a
	ld	hl,$ffb0
	ld	de,$0050
curofs:	add	hl,de			; calc. new offset
	djnz	curofs
	ld	a,(appbuf)
	ld	(colbuf),a
	ld	e,a
	add	hl,de
	ex	de,hl
	ld	hl,(curpbuf)
	add	hl,de
	jp	scrspos			; update position
bcexit:
	pop	hl
	pop	de
	pop	bc
	pop	af
	ret


zconst:
	in	a,($85)
	cpl
	bit	7,a
	jr	nz,mconsp
	xor	a
	ld	($59),a
	ret
mconsp:	ld	a,$ff
	ret

zconin:
	in	a,(85h)
	cpl
	bit	7,a
	jr	nz,zconin

zconi1:	in	a,(85h)
	cpl
	bit	7,a
	jr	z,zconi1
	and	7fh
	ret

ttyq:
	push	bc
	push	de
	push	hl
	call	zconst
	and	$7f
	pop	hl
	pop	de
	pop	bc
	ret

ttyi:
	push	bc
	push	de
	push	hl
	call	zconin
	pop	hl
	pop	de
	pop	bc
	ret

ttyo:
; 	PUSH	AF
	push	bc
; 	PUSH	DE
; 	PUSH	HL
	ld	c,a
	call	zconout
; 	POP	HL
; 	POP	DE
	pop	bc
; 	POP	AF
	ret

inchar:	call	ttyi
	cp	ctlc
	jr	z,exicpm
	cp	cr
	ret	z
	cp	tab
	ret	z
	cp	lf
	ret	z
	cp	bs
	ret	z
	cp	ctlx
	ret	z
	cp	' '
	jr	nc,ttyo
	push	af
	ld	a,'^'
	call	ttyo
	pop	af
	xor	40h
	call	ttyo
	xor	40h
	ret

exicpm:
	ei			; renable interrupts
; 	CALL	GENAIN		; unlock monitor to enable ints
	jp	$f000

ilcs:	cp	'A'
	ret	c
	cp	'Z'+1
	ret	nc
	or	20h
	ret



ixlt:	cp	'a'
	ret	c
	cp	'z'+1
	ret	nc
	sub	20h
	ret


crlf:	ld	a,cr
	call	ttyo
	ld	a,lf
	jp	ttyo

cret:	ld	a,cr
	jp	ttyo

othxsp:	call	outhex

rspace:	ld	a,' '
	jp	ttyo

space5:	ld	c,5

spaces:	call	rspace
	dec	c
	jr	nz,spaces
	ret



newlin:	call	crlf
	ex	de,hl
	call	outadr
	ex	de,hl
	ret


outadr:	ld	a,h
	call	outhex
	ld	a,l
	call	othxsp
	jr	rspace



outhex:	push	af
	call	binx
	call	ttyo
	pop	af
	call	binx00
	jp	ttyo



binx:	rrca
	rrca
	rrca
	rrca
binx00:	and	0fh
	add	a,90h
	daa
	adc	a,40h
	daa
	ret

ilin:	push	bc
	push	de
	ld	b,inbfsz
	ld	c,0
	call	rtin
	pop	de
	pop	bc
	ret


istr:	push	bc
	push	de
	ld	b,1
	ld	c,' '
	call	iedt
	pop	de
	pop	bc
	ret


				;resume input after reading in one char

irsm:	push	bc
	push	de
	ld	b,inbfsz-1	;max input size less one char already read in
	ld	c,' '		;this is terminator char
	ld	d,1		;preset byte count
	ld	a,d
	ld	(strngf),a	;set nz - this is string function
	ld	hl,inbf+1	;init buffer pointer
	call	iedt05
	xor	a
	ld	(strngf),a	;this is no longer string function
	or	d
	call	p,in00
	pop	de
	pop	bc
	ret



rtin:	call	iedt
	ret	m
in00:	xor	a
	ld	(argbc),a
	ld	hl,argbf
	ld	(argbpt),hl
in10:	call	iarg
	ret	nz
	and	a
	jr	nz,in10
	ret



iarg:	push	bc
	push	de
	call	parg
	ld	a,(delim)
	pop	de
	pop	bc
	ret

parg:	call	prsr		;extract next argument
	ret	nz		;parse error
	ld	a,(quoflg)	;test for ascii	literal
	and	a
	jr	z,parg10	;quote character not found
	xor	a
	or	b		;test for balanced quotes
	ret	m		;error - unbalanced quotes
	ld	a,(de)		;first character of parse buffer
	sub	quote
	jr	nz,parg50	;invalid literal string but may be expression
				;involving a literal
	ld	l,b		;l - character count of	parse buffer
	ld	h,a		;clear
	add	hl,de		;
	dec	hl		;hl - pointer to last char in parse buffer
	ld	a,(hl)		;
	sub	quote		;ensure	literal	string ends with quote
	jr		nz,parg50
	ld	(hl),a		;clear trailing quote
	ld	c,b		;c - character count of	parse buffer
	ld	b,a		;clear
	dec	c		;subtract the quote characters from the	count
	dec	c
	dec	c		;extra dec set error flag nz for '' string
	ret	m		;inform	caller of null string
	inc	c		;c - actual string length
	ld	a,c		;spare copy
	inc	de		;point to second character of parse buffer
	ld	hl,(argbpt)	;caller	wants evaluated	arg stored here
	ex	de,hl
	ldir
	ex	de,hl
	dec	hl
	ld	e,(hl)
	dec	hl
	ld	d,(hl)
	inc	hl
	inc	hl		;point to where to store next arg
	dec	a		;argument length 1?
	jr	nz,parg00
	ld	d,a
parg00:	ld	c,a
	inc	c		;account for increment
	ld	a,(argbc)	;fetch current argument byte counter
	add	a,c
	jr	parg90
parg10:	call	mreg		;check for register specified
	jr	nz,parg50	;nz - invalid register name
	ld	a,c
	add	a,a
	jr	c,parg60	;sign bit reset	- 16 bit register pair
parg50:	ld	hl,00
	ld	b,l
	ld	de,prsbf	;reinit	starting address of parse buffer
	call	xval
	jr	z,parg70
	ret
parg60:	ld	a,(hl)
	dec	hl
	ld	l,(hl)
	ld	h,a
	ld	a,(prsbf)	;check paren flag for indirection
	and	a
	jr	nz,parg65	;nz - parens not removed
	inc	de		;bump past trailing null
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
parg65:	ld	b,80h
	call	xval
	ret	nz
parg70:	ex	de,hl
	ld	hl,(argbpt)
	ld	a,(argbc)
	inc	d
	dec	d
	jr	z,parg80
	ld	(hl),d
	inc	hl
	inc	a
parg80:	ld	(hl),e
	inc	hl
	inc	a
parg90:	ld	(argbc),a
	ld	(argbpt),hl
	ex	de,hl
	xor	a
	ret

outbyt:	ld	b,a		;save spare copy
	call	othxsp		;hex - display
	call	rspace
	ld	a,b		;display byte in ascii
	call	asci		;display ascii equivalent
	ld	c,3
	jp	spaces		;solicit input three spaces right

rbyte:	call	istr
	ld	a,(inbfnc)	;number	of chars in input buffer
	dec	a		;test for input	buffer count of	zero
	inc	de		;assume	zero - examine next
	ret	m		;no input means examine next
	dec	de		;incorrect assumption
	ld	a,(inbf)	;check first char of input buffer
	cp	'.'
	ret	z		;period	ends command
	cp	'='		;new address?
	jr	nz,byte10
	xor	a		;clear equal sign so prsr ignores it
	ld	(inbf),a
	call	irsm		;fetch new address to examine
	jr	nz,byte30	;error
	ld	a,(inbfnc)
	sub	2
	jr	c,byte30	;c - error - equal sign was only char of input
	ex	de,hl		;return new address in de
	scf			;ensure nz set for caller - no replacement data
				;was entered
	sbc	a,a
	ret
byte10:	cp	'^'		;
	jr	nz,byte15	;nz - not up arrow means need more input
	dec	de		;dec current memory pointer
	scf	 		;set nz - no replacement data entered
	sbc	a,a
	ret
byte15:	call	irsm		;resume	input from console
	ret	z		;no errors on input
	ld	a,(inbfnc)	;check number of chars input
	and	a
	jr	z,rbyte		;none - user hit control x or backspaced to
				;beginning of buffer
byte30:	call	exxx
	scf
	sbc	a,a		;set nz - no replacement
	ret

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


iedtbc:	ld	b,inbfsz
	xor	a
	ld	c,a
	ld	(strngf),a
iedt:	xor	a
	ld	d,inbfsz
	ld	hl,inbf
iedt00:	ld	(hl),a
	inc	hl
	dec	d
	jr	nz,iedt00
	ld	(argbc),a	;init number of	arguments tally
	ld	hl,argbf
	ld	(argbpt),hl	;init pointer to start of buffer
iedt03:	ld	hl,inbf		;start of input	buffer
	ld	(quoflg),a
iedt05:	call	inchar		;read char from	console
	ld	(trmntr),a	;assume line terminator until proven otherwise
	cp	cr		;end of	line?
	jp	z,iedt90	;z - end (jr changed to jp:  eg 3.3.8a)
	ld	e,a
	cp	quote
	ld	a,(quoflg)
	jr	nz,iedt10
	xor	quote
	ld	(quoflg),a
	ld	a,quote
	jr	iedt60
iedt10:	and	a		;quote flag on?
	ld	a,e		;recover input character
	jr	z,iedt15	;off - check terminator
	ld	a,(lcmd)
	call	ixlt
	cp	'R'
	ld	a,e
	jr	nz,iedt20
iedt15:	cp	c		;compare with auxiliary terminator
	jr	z,iedt90	;z - end
iedt20:	cp	tab
	jr	nz,iedt35	;nz - not tab check backspace
iedt25:	call	rspace		;space out until char position mod 8 = zero
	ld	(hl),a		;store space in buffer as we expand tab
	inc	hl
	inc	d
	ld	a,7
	and	d
	jr	nz,iedt25
	ld	(hl),0		;set end of line null
	jr	iedt70
iedt35:	ld	e,1		;assume	one backspace required
	cp	bs
	jr	z,iedt40	;z - correct assumption
	cp	ctlx		;erase line?
	jr	nz,iedt60	;nz - process normal input character

	xor	a		;+ eg 3.3.8b
	or	d		;+ See if ^X with empty buffer
	jp	z,z8e		;+ Abandon current command if so

	ld	e,d		;backspace count is number of chars in buffer

	jr	iedt50		;+

iedt40:	xor	a		;test if already at beginning of buffer
	or	d
	jr	z,iedt05	;z - at	beginning so leave cursor as is
iedt50:	call	bksp		;transmit bs - space - bs string
	dec	d		;sub one from input buffer count
	dec	hl		;rewind	buffer pointer on notch
	ld	a,(hl)		;check for control characters
	ld	(hl),0
	cp	quote		;check for backspacing over a quote
	jr	nz,iedt55
	ld	a,(quoflg)	;toggle quote flag so we keep track of balance
				;factor
	xor	quote
	ld	(quoflg),a
	jr	iedt58
iedt55:	cp	' '
	call	c,bksp		;c - control char requires extra bs for caret
iedt58:	dec	e		;dec backspace count
	jr	nz,iedt50	;more backspacing
	ld	a,(strngf)	;string	function flag on?
	and	a
	jr	z,iedt05	;off - get next	input char
	xor	a		;did we	backspace to start of buffer?
	or	d		;test via character count
	jr	nz,iedt05	;not rewound all the way
	ld	(inbfnc),a	;set a zero byte count so caller knows
	dec	d		;something is fishy
	ret
iedt60:	ld	(hl),a		;store char in inbf
	inc	hl		;bump inbf pointer
	ld	(hl),0		;end of line
	inc	d		;bump number of	chars in buffer
iedt70:	ld	a,d		;current size
	sub	b		;versus	max size requested by caller
	jp	c,iedt05	;more room in buffer
iedt90:	ld	hl,inbfnc	;store number of characters received ala
				;bdos function 10
	ld	(hl),d
	inc	hl		;point to first	char in	buffer
	dec	d		;set m flag if length is zero
	ret			;sayonara




bksp:	call	bksp00
	call	rspace
bksp00:	ld	a,bs
	jp	ttyo


asci:	and	7fh		;Convert contents of accumulator to ascii
	cp	del		;	check for del
	jr	z,asci00	;	yes - translate to '.'
	cp	20h		;	check for control character
	jp	nc,ttyo		;	no - output as is
asci00:				;	yes - translate to '.'
;	if	hazeltine
	ld	a,'.'		;Non-printables replaced with dot
;	else
;	ld	a,tilde		;Non-printables replaced with squiggle
;	endif
       	jp	ttyo



bcdx:	call	bcdx00
	ret	nz
bcdx00:	rld
	ex	de,hl
	add	hl,hl
	ld	b,h
	ld	c,l
	add	hl,hl
	add	hl,hl
	add	hl,bc
	ld	c,a
	ld	a,9
	cp	c
	ret	c
	xor	a
	ld	b,a
	add	hl,bc
	ex	de,hl
	adc	a,a
	ret

nprint:	call	crlf
print:	ld	a,(de)
	and	a
	ret	z
	call	ttyo
	inc	de
	jr	print


printb:	ld	a,(hl)
	and	a
	ret	z
	call	ttyo
	inc	hl
	dec	c
	jr	nz,printb
	ret



home:	ld	bc,00


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

xycp:
	push	bc		;Enter with row in b and column in c
	push	de
	push	hl
	inc	b		; ZDS origin 1,1
	ld	hl,mxycp
	ld	a,(row)		;Add in row offset
	add	a,b
	ld	b,a		;Save row character
	ld	a,(column)	;Add column bias
	add	a,c
	ld	c,a
	ld	e,(hl)		;Number of chars in cursor addressing string
xycp00:
	inc	hl
	ld	a,(hl)
	call	ttyo
	dec	e
	jr	nz,xycp00
	ld	a,(rowb4x)
	and	a
	jr	nz,xycp10
	ld	a,b
	ld	b,c
	ld	c,a
xycp10:
	ld	a,b
	call	ttyo
	ld	a,c
	call	ttyo
	pop	hl
	pop	de
	pop	bc
	ret

; 	org	xycp+128		;  the object code

nrel:					;end of	relocatable code


zopnm:
	defb	'HL'
	defb	'A '
	defb	'H '
	defb	'L '
	defb	'D '
	defb	'E '
	defb	'B '
	defb	'C '
six:	defb	'IX'
	defb	'SP'
	defb	'P '
	defb	'R '
	defb	'I '
	defb	'AF'
	defb	'BC'
	defb	'DE'
siy:	defb	'IY'
	defb	'Z '
	defb	'NC'
	defb	'NZ'
	defb	'PE'
	defb	'PO'
	defb	'M '
	defb	'PC'

rix	equ	(six-zopnm)/2		;relative position - ix
riy	equ	(siy-zopnm)/2		;		     iy

zopnml	equ	($-zopnm)/2

zopjtb	equ	 $-nrel			;nrel to jump table bias for loader

zoprjt:
	defw	opn600			;18 - hl/ix/iy test
	defw	opn400			;19 - register specified in bits 0-2
	defw	opn400			;1a - register specified in bits 3-5
	defw	opn100			;1b - relative jump
	defw	opn200			;1c - nn
	defw	opn300			;1d - nnnn
	defw	opn700			;1e - restart
	defw	opn800			;1f - bit number

zasmio:	defw	zasmbf

zopjtl	equ	($-zoprjt)/2		;length	of operand jump	table

jtcmd:
	defw	ifcb			; i
	defw	asmblr			; a
	defw	usym			; u
	defw	nprt			; n
	defw	jdbg			; j
	defw	zasm			; z
	defw	exam			; e
	defw	rgst			; r
	defw	go			; g
	defw	yfil			; y
	defw	movb			; m
	defw	verify			; v
	defw	pswdsp			; p
	defw	break			; b
	defw	cbreak			; c
	defw	find			; f
	defw	hsym			; h
	defw	step			; s
	defw	obreak			; o
	defw	lldr			; l
	defw	dump			; d
	defw	qprt			; q
	defw	xreg			; x
	defw	bank			; k
	defw	kdmp			; w
	defw	cuser			; >
	defw	qeval			; ?
cmd:
	defb	'?>WKXQDLOSHFCB'
	defb	'PVMYGREZJNUAI'
ncmd	equ	$-cmd		;number	of commands

bpemsg:
	defb	'*ERROR*'
bpmsg:
	defb	'*BP* @ '
	defb	0
; PROMPT:
; 	DEFB	'#',' ',bs,0
prompt:
	defb	'#',0

mrrow:	defb	'=','>'		;backspaces taken out
	defb	00

mxxxx:	defb	'??'
mxx:	defb	' ??  '


asmflg:	defb	' '
	defb	0

lcmd:	defb	' '
emxxx:	defb	' ??'
	defb	0

mbnk:	defb	' sysbios cbnk: '
	defb	0


msntx:
	defb	'Syntax Error'
	defb	cr,lf,0

mmemxx:	defb	'Out Of Memory'
	defb	0

mcntu:	defb	' - Continue? '
	defb	0

mireg:
	defb	'IR: '
	defb	0


z80fd:	defb	009h,019h,02bh
	defb	023h,029h,039h,0e1h
	defb	0e3h,0e5h,0e9h,0f9h
z80fdl	equ	$-z80fd

z80f4:	defb	021h,022h,02ah,036h,0cbh
z80f4l	equ	$-z80f4


z801:	defb	0c0h,0e9h,0c9h,0d8h
	defb	0d0h,0c8h,0e8h,0e0h
	defb	0f8h,0f0h
z801l	equ	$-z801


z802:	defb	036h,0c6h,0ceh,0d3h
	defb	0d6h,0dbh,0deh,0e6h
	defb	0eeh,0f6h,0feh
z802c:	defb	018h,038h,030h
	defb	028h,020h,010h
z802l	equ	$-z802
z802cl	equ	$-z802c


z80r:
z803:	defb	001h,011h,021h,022h
	defb	02ah,031h,032h,03ah

z803s:	defb	0cdh
	defb	0dch,0d4h,0cch,0c4h
	defb	0ech,0e4h,0fch,0f4h

z803sl	equ	$-z803s			;number	of call	instructions

z803c:	defb	0c3h
	defb	0dah,0d2h,0cah,0c2h
	defb	0eah,0e2h,0fah,0f2h

z803l	equ	$-z803			;number	of 3 byte instructions
z803cl	equ	$-z803s			;number	of 3 byte pc mod instructions

z80ed:	defb	043h,04bh,053h
	defb	05bh,073h,07bh

z80edl	equ	$-z80ed

z80rl	equ	$-z80r			;number	relocatable z80	instructions

z80f3:
	defb	034h,035h,046h,04eh
	defb	056h,05eh,066h,06eh
	defb	070h,071h,072h,073h
	defb	074h,075h,077h,07eh
	defb	086h,08eh,096h,09eh
	defb	0a6h,0aeh,0b6h,0beh
z80f3l	equ	$-z80f3

;***********************************************************************
;*
;*
;*
;*
;*
;***********************************************************************

; 	org	($+3) and 0fffch
zopcpt:
	defb	022h,01ch,01ch,015h	;nop	ld	ld	inc	00 - 03
	defb	015h,00ch,01ch,031h	;inc	dec	ld	rlca	04 - 07
	defb	010h,000h,01ch,00ch	;ex	add	ld	dec	08 - 0b
	defb	015h,00ch,01ch,036h	;inc	dec	ld	rrca	0c - 0f
	defb	00eh,01ch,01ch,015h	;djnz	ld	ld	inc	10 - 13
	defb	015h,00ch,01ch,02fh	;inc	dec	ld	rla	14 - 17
	defb	01bh,000h,01ch,00ch	;jr	add	ld	dec	18 - 1b
	defb	015h,00ch,01ch,034h	;inc	dec	ld	rra	1c - 1f
	defb	01bh,01ch,01ch,015h	;jr	ld	ld	inc	20 - 23
	defb	015h,00ch,01ch,00bh	;inc	dec	ld	daa	24 - 27
	defb	01bh,000h,01ch,00ch	;jr	add	ld	dec	28 - 2b
	defb	015h,00ch,01ch,00ah	;inc	dec	ld	cpl	2c - 2f
	defb	01bh,01ch,01ch,015h	;jr	ld	ld	inc	30 - 33
	defb	015h,00ch,01ch,03ah	;inc	dec	ld	scf	34 - 37
	defb	01bh,000h,01ch,00ch	;jr	add	ld	dec	38 - 3b
	defb	015h,00ch,01ch,004h	;inc	dec	ld	ccf	3c - 3f


	defb	014h,026h,039h,01ch	;in	out	sbc	ld	ed 40
	defb	021h,02dh,013h,01ch	;neg	retn	im	ld
	defb	014h,026h,001h,01ch	;in	out	adc	ld
	defb	022h,02ch,022h,01ch	;....	reti	...	ld
	defb	014h,026h,039h,01ch	;in	out	sbc	ld
	defb	022h,022h,013h,01ch	;...	...	im	ld
	defb	014h,026h,001h,01ch	;in	out	adc	ld
	defb	022h,022h,013h,01ch	;...	...	im	ld
	defb	014h,026h,039h,022h	;in	out	sbc	...
	defb	022h,022h,002h,037h	;...	...	...	rrd
	defb	014h,026h,001h,022h	;in	out	adc	...
	defb	044h,045h,046h,032h	;defb*	defw*	ddb*	rld
	defb	043h,047h,039h,01ch	;org*	equ*	sbc	ld	ed 70
	defb	022h,022h,022h,022h	;...	...	...	...
	defb	014h,026h,001h,01ch	;in	out	adc	ld
	defb	022h,022h,022h,022h	;...	...	...	...	ed 7f


	defb	01fh,008h,018h,028h	;ldi	cpi	ini	outi
	defb	022h,022h,022h,022h	;...	...	...	...
	defb	01dh,006h,016h,027h	;ldd	cpd	ind	outd
	defb	022h,022h,022h,022h	;...	...	...	...
	defb	020h,009h,019h,025h	;ldir	cpir	inir	otir
	defb	022h,022h,022h,022h	;...	...	...	...
	defb	01eh,007h,017h,024h	;lddr	cpdr	indr	otdr
	defb	022h,022h,022h,044h	;...	....	....	defb*


	defb	02bh,029h,01ah,01ah	;ret	pop	jp	jp	c0 - c3
	defb	003h,02ah,000h,038h	;call	push	add	rst	c4 - c7
	defb	02bh,02bh,01ah,022h	;ret	ret	jp	...	c8 - cb
	defb	003h,003h,001h,038h	;call	call	adc	rst	cc - cf
	defb	02bh,029h,01ah,026h	;ret	pop	jp	out	d0 - d3
	defb	003h,02ah,03eh,038h	;call	push	sub	rst	d4 - d7
	defb	02bh,011h,01ah,014h	;ret	exx	jp	in	d8 - db
	defb	003h,022h,039h,038h	;call	...	sbc	rst	dc - df
	defb	02bh,029h,01ah,010h	;ret	pop	jp	ex	e0 - e3
	defb	003h,02ah,002h,038h	;call	push	and	rst	e4 - e7
	defb	02bh,01ah,01ah,010h	;ret	jp	jp	ex	e8 - eb
	defb	003h,022h,03fh,038h	;call	...	xor	rst	ec - ef
	defb	02bh,029h,01ah,00dh	;ret	pop	jp	di	f0 - f3
	defb	003h,02ah,023h,038h	;call	push	or	rst	f4 - f7
	defb	02bh,01ch,01ah,00fh	;ret	ld	jp	ei	f8 - fb
	defb	003h,022h,005h,038h	;call	...	cp	rst	fc - ff

	defb	000h,001h,03eh,039h	;add	adc	sub	sbc
	defb	002h,03fh,023h,005h	;and	xor	or	cp


	defb	030h,035h,02eh,033h	;rlc	rrc	rl	rr
	defb	03bh,03ch,022h,03dh	;sla	sra	...	srl
	defb	022h,040h,041h,042h	;...	bit	res	set


	defb	022h,022h,022h,012h	;...	...	...	halt


	defb	01ch,01ch,01ch,01ch	;ld	ld	ld	ld
	defb	01ch,01ch,01ch,01ch	;ld	ld	ld	ld


;****************************************************************************
;*
;*			table of first operands
;*
;****************************************************************************

zopnd1:
	defb	0ffh,00eh,08eh,00eh	;00 - 03
	defb	006h,006h,006h,0ffh	;04 - 07
	defb	00dh,018h,001h,00eh	;08 - 0b
	defb	007h,007h,007h,0ffh	;0c - 0f
	defb	01bh,00fh,08fh,00fh	;10 - 13
	defb	004h,004h,004h,0ffh	;14 - 17
	defb	01bh,018h,001h,00fh	;18 - 1b
	defb	005h,005h,005h,0ffh	;1c - 1f
	defb	013h,018h,09dh,018h	;20 - 23
	defb	002h,002h,002h,0ffh	;24 - 27
	defb	011h,018h,018h,018h	;28 - 2b
	defb	003h,003h,003h,0ffh	;2c - 2f
	defb	012h,009h,09dh,009h	;30 - 33
	defb	098h,098h,098h,0ffh	;34 - 37
	defb	007h,018h,001h,009h	;38 - 3b
	defb	001h,001h,001h,0ffh	;3c - 3f

	defb	006h,087h,000h,09dh	;40 - 43
	defb	0ffh,0ffh,01fh,00ch	;44 - 47
	defb	007h,087h,000h,00eh	;48 - 4b
	defb	0ffh,0ffh,0ffh,00bh	;4c - 4f
	defb	004h,087h,000h,09dh	;50 - 53
	defb	0ffh,0ffh,01fh,001h	;54 - 57
	defb	005h,087h,000h,00fh	;58 - 5b
	defb	0ffh,0ffh,01fh,001h	;5c - 5f
	defb	002h,087h,000h,0ffh	;60 - 63
	defb	0ffh,0ffh,0ffh,0ffh	;64 - 67
	defb	003h,087h,000h,0ffh	;68 - 6b
	defb	01ch,01dh,01dh,0ffh	;6c - 6f	defb  defw  ddb
	defb	01dh,01dh,000h,09dh	;70 - 73	org   equ
	defb	0ffh,0ffh,0ffh,0ffh	;74 - 77
	defb	001h,087h,000h,009h	;78 - 7b
	defb	0ffh,0ffh,0ffh,0ffh	;7c - 7f

	defb	0ffh,0ffh,0ffh,0ffh	;a0 - bf
	defb	0ffh,0ffh,0ffh,0ffh	;a4 - a7
	defb	0ffh,0ffh,0ffh,0ffh	;a8 - ab
	defb	0ffh,0ffh,0ffh,0ffh	;ac - af
	defb	0ffh,0ffh,0ffh,0ffh	;b0 - b3
	defb	0ffh,0ffh,0ffh,0ffh	;b4 - b7
	defb	0ffh,0ffh,0ffh,0ffh	;b8 - bb
	defb	0ffh,0ffh,00fh,0ffh	;bc - bf

	defb	013h,00eh,013h,01dh	;c0 - c3
	defb	013h,00eh,001h,01eh	;c4 - c7
	defb	011h,0ffh,011h,0ffh	;c8 - cb
	defb	011h,01dh,001h,01eh	;cc - cf
	defb	012h,00fh,012h,09ch	;d0 - d3
	defb	012h,00fh,01ch,01eh	;d4 - d7
	defb	007h,0ffh,007h,001h	;d8 - db
	defb	007h,0ffh,001h,01eh	;dc - df
	defb	015h,018h,015h,089h	;e0 - e3
	defb	015h,018h,01ch,01eh	;e4 - e7
	defb	014h,098h,014h,00fh	;e8 - eb
	defb	014h,0ffh,01ch,01eh	;ec - ef
	defb	00ah,00dh,00ah,0ffh	;f0 - f3
	defb	00ah,00dh,01ch,01eh	;f4 - f7
	defb	016h,009h,016h,0ffh	;f8 - fb
	defb	016h,0ffh,01ch,01eh	;fc - ff


	defb	001h,001h,019h,001h	;8 bit logic and arithmetic
	defb	019h,019h,019h,019h	;


	defb	019h,019h,019h,019h	;shift and rotate
	defb	019h,019h,019h,019h	;
	defb	0ffh,01fh,01fh,01fh	;bit - res - set

	defb	0ffh,0ffh,0ffh,0ffh	;filler

	defb	01ah,01ah,01ah,01ah	;8 bit load
	defb	01ah,01ah,01ah,01ah	;


;***********************************************************************
;*
;*			table of second	operands
;*
;***********************************************************************


zopnd2:
	defb	0ffh,01dh,001h,0ffh	;00 - 03
	defb	0ffh,0ffh,01ch,0ffh	;04 - 07
	defb	00dh,00eh,08eh,0ffh	;08 - 0b
	defb	0ffh,0ffh,01ch,0ffh	;0c - 0f
	defb	0ffh,01dh,001h,0ffh	;10 - 13
	defb	0ffh,0ffh,01ch,0ffh	;14 - 17
	defb	0ffh,00fh,08fh,0ffh	;18 - 1b
	defb	0ffh,0ffh,01ch,0ffh	;1c - 1f
	defb	01bh,01dh,018h,0ffh	;20 - 23
	defb	0ffh,0ffh,01ch,0ffh	;24 - 27
	defb	01bh,018h,09dh,0ffh	;28 - 2b
	defb	0ffh,0ffh,01ch,0ffh	;2c - 2f
	defb	01bh,01dh,001h,0ffh	;30 - 33
	defb	0ffh,0ffh,01ch,0ffh	;34 - 37
	defb	01bh,009h,09dh,0ffh	;38 - 3b
	defb	0ffh,0ffh,01ch,0ffh	;3c - 3f


	defb	087h,006h,00eh,00eh	;40 - 43
	defb	0ffh,0ffh,0ffh,001h	;44 - 47
	defb	087h,007h,00eh,09dh	;48 - 4b
	defb	0ffh,0ffh,0ffh,001h	;4c - 4f
	defb	087h,004h,00fh,00fh	;50 - 53
	defb	0ffh,0ffh,0ffh,00ch	;54 - 57
	defb	087h,005h,00fh,09dh	;58 - 5b
	defb	0ffh,0ffh,0ffh,00bh	;5c - 5f
	defb	087h,002h,000h,0ffh	;60 - 63
	defb	0ffh,0ffh,0ffh,0ffh	;64 - 67
	defb	087h,003h,000h,0ffh	;68 - 6b
	defb	0ffh,0ffh,0ffh,0ffh	;6c - 6f
	defb	0ffh,0ffh,009h,009h	;70 - 73
	defb	0ffh,0ffh,0ffh,0ffh	;74 - 77
	defb	087h,001h,009h,09dh	;78 - 7b
	defb	0ffh,0ffh,0ffh,0ffh

	defb	0ffh,0ffh,0ffh,0ffh	;a0 - bf
	defb	0ffh,0ffh,0ffh,0ffh	;a4 - a7
	defb	0ffh,0ffh,0ffh,0ffh	;a8 - ab
	defb	0ffh,0ffh,0ffh,0ffh	;ac - af
	defb	0ffh,0ffh,0ffh,0ffh	;b0 - b3
	defb	0ffh,0ffh,0ffh,0ffh	;b4 - b7
	defb	0ffh,0ffh,0ffh,0ffh	;b8 - bb
	defb	0ffh,0ffh,00fh,0ffh	;bc - bf

	defb	0ffh,0ffh,01dh,0ffh	;c0 - c3
	defb	01dh,0ffh,01ch,0ffh	;c4 - c7
	defb	0ffh,0ffh,01dh,0ffh	;c8 - cb
	defb	01dh,0ffh,01ch,0ffh	;cc - cf
	defb	0ffh,0ffh,01dh,001h	;d0 - d3
	defb	01dh,0ffh,0ffh,0ffh	;d4 - d7
	defb	0ffh,0ffh,01dh,09ch	;d8 - db
	defb	01dh,0ffh,01ch,0ffh	;dc - df
	defb	0ffh,0ffh,01dh,018h	;e0 - e3
	defb	01dh,0ffh,0ffh,0ffh	;e4 - e7
	defb	0ffh,0ffh,01dh,000h	;e8 - eb
	defb	01dh,0ffh,0ffh,0ffh	;ec - ef
	defb	0ffh,0ffh,01dh,0ffh	;f0 - f3
	defb	01dh,0ffh,0ffh,0ffh	;f4 - f7
	defb	0ffh,018h,01dh,0ffh	;f8 - fb
	defb	01dh,0ffh,0ffh,0ffh	;fc - ff

	defb	019h,019h,0ffh,019h	;8 bit logic and arithmetic
	defb	0ffh,0ffh,0ffh,0ffh	;

	defb	0ffh,0ffh,0ffh,0ffh	;shift and rotate
	defb	0ffh,0ffh,0ffh,0ffh	;
	defb	0ffh,019h,019h,019h	;bit - res - set

	defb	0ffh,0ffh,0ffh,0ffh

	defb	019h,019h,019h,019h	;8 bit load
	defb	019h,019h,019h,019h


;***********************************************************************
;*
;*			table of op code names
;*
;***********************************************************************


zopcnm:
	defb	'ADD ADC AND CALL'
	defb	'CCF CP  CPD CPDR'
	defb	'CPI CPIRCPL DAA '
	defb	'DEC DI  DJNZEI  '
	defb	'EX  EXX HALTIM  '
	defb	'IN  INC IND INDR'
	defb	'INI INIRJP  JR  '
	defb	'LD  LDD LDDRLDI '
	defb	'LDIRNEG NOP OR  '
	defb	'OTDROTIROUT OUTD'
	defb	'OUTIPOP PUSHRET '
	defb	'RETIRETNRL  RLA '
	defb	'RLC RLCARLD RR  '
	defb	'RRA RRC RRCARRD '
	defb	'RST SBC SCF SLA '
	defb	'SRA SRL SUB XOR '
	defb	'BIT RES SET ORG '
	defb	'DEFBDEFWDDB EQU '




op1000:
	defb	 0fdh,0ddh,0edh,0cbh



pswbit:	defb	10001000b		;minus
	defb	10000000b		;positive
	defb	00001100b		;even parity
	defb	00000100b		;odd parity
	defb	01001000b		;zero
	defb	01000000b		;not zero
	defb	00001001b		;carry
	defb	00000001b		;no carry

pswmap:	defb	18,07,19,17,21,20,10,22
pswcnt	equ	$-pswmap


regmap:
	defb	87h,01h,07h,06h,05h,04h
	defb	03h,02h,95h,93h,91h,18h
	defb	19h,81h,83h,85h,97h

regptr:
	defb	0dh,0eh,0fh,00h
	defb	8dh,8eh,8fh,80h
	defb	0ah,09h,08h,10h

siotbl:	defb	0f5h,0f7h

symflg:	defb	0ffh		;symbol	table flag   00	- table	present
				;		     ff	- no table

bsiz:				;dump block size storage
bsizlo:	defb	0		;     lo order
bsizhi:	defb	1		;     hi order
blkptr:	defw	100h		;dump block address

loadb:	defw    100h		;z8e load bias for lldr command
loadn:	defw	00		;end of load address

asmbpc:				;next pc location for assembly
zasmpc:	defw	100h		;next pc location for disassemble
				;default at load time: start of	tpa
zasmfl:	defw	00		;first disassembled address on jdbg screen

iniok:	defb	0ffh		;need first call init

from:
oprn01:
rlbias:
lines:
exampt:
endw:
zasmnx:	defb	0		;address of next instruction to	disassemble
oprx01:	defb	0
bias:
biaslo:
zasmct:	defb	0		;disassembly count
biashi:
oprn02:	defb	0
oprx02:
zasmwt:	defw	0		;disassembly count - working tally
opnflg:	defb	0		;00 - operand 1   ff - operand 2   zasm
				;and input character storage for interactive
				;disassembly
quoflg:	defb	0
wflag:	defb	0ffh		;trace subroutine flag:	nz - trace subs
				;			 z - no	trace

nstep:
nstepl:	defb	0
nsteph:	defb	0

sbps:	defb	0		;number	of step	breakpoints
bps:	defb	0		;number	of normal breakpoints

zmflag:	defb	0
zasmf:	defb	0
execbf:				;execute buffer	for relocated code
jlines:
parenf:
nument:	defb	0		;number	of digits entered
delim:	defb	0		;argument delimeter character
	defb	0
base10:	defb	0
jmp2jp:	defb	0
jmp2:	defb	0
dwrite:
cflag:	defb	0

ikey:
zasmkv:
sjmp:	defb	0
mexp:
jmplo:	defb	0
strngf:
jmphi:	defb	0
timer:
first:	defb	0
regtrm:	defb	0
trmntr: defb	0
isympt:	defw	0

jropnd:
pass2:	defw	0

fndsym:	defw	0

maxlen:
	defw	14

maxlin:	defw	62

fwndow:	defb	00

nlmask:	defb	00

case:
	defb	0ffh		;flag to indicate case of output
; 	defb	000h		;flag to indicate case of output
				;nz - lower   z - upper

jstepf:	defb	0ffh		;00 -   screen is intact, if user wants j
				;       single step no need to repaint screen,
				;       just move arrow.
				;01   - user wants single-step j command
				;else - j screen corrupted by non-j command

lastro:	defb	03

rowb4x:
	defb	0

mxycp:
    	defb	1,esc

xyrow:	defb	0
xycol:	defb	0

row:
	defb	' '			;bias for most other terminals
column:
	defb	' '

wnwtab:	defw	0
wnwsiz:	defw	0

port:	defw	0

brktbl:	defs	(maxbp+2)*3
psctbl:	defs	maxbp*2

bdosad:	defw	0

regcon:
afreg:
freg:	defb	00
	defb	00
bcreg:	defw	00
dereg:	defw	00
hlreg:	defw	00
afpreg:	defw	00
bcpreg:	defw	00
depreg:	defw	00
hlpreg:	defw	00
pcreg:
pcregl:	defb	00
pcregh:	defb	01
spreg:	defw	00
ixreg:	defw	00
iyreg:	defw	00

regsiz	equ	$-regcon

rreg:	defb	00
ireg:	defb	00


fstart:	defw	0
argbc:	defw	0
argbpt:	defw	argbf

regsav	equ	$		;storage for register contents in between bps
				;while jdbg is in control

window	equ	regsav+regsiz	;memory window save area

argbsz	equ	62

argbf:	defs	argbsz

fcb	equ     argbf+argbsz-36 ;cp/m file control block
fcbnam	equ	fcb+1		;start of file name in fcb
fcbtyp	equ	fcbnam+8	;start of file type in fcb
fcbext	equ	fcbtyp+3	;current extent	number
nfcb	equ	$		;last byte of fcb plus one

gpbsiz	equ	164		;size of general purpose buffer

symbuf:
objbuf:				;object	code buffer
	defs	gpbsiz
inbfsz	equ	gpbsiz/2
inbfmx	equ	objbuf+4	;input buffer -	max byte count storage
inbfnc	equ	inbfmx+1	;	      -	number chars read in
inbf	equ	inbfnc+1	;	      -	starting address
inbfl	equ	inbfsz-1	;	      -	last relative position
ninbf	equ	inbf+inbfl	;	      -	address	of last	char

prsbfz	equ	gpbsiz/2
prsbf	equ	inbf+inbfsz	;parse buffer -	starting address
lprsbf	equ	prsbf+prsbfz-1	;	      -	last char of parse buf
nprsbf	equ	lprsbf+1	;	      -	end address plus one

nzasm	equ	$		;end of disassembly buffer
zasmbf	equ	nzasm-128	;start of disassembly buffer

; filler:
; 	defs	fillbegin + $3000 - filler - 1
; fillend:
; 	defb	0

	end


