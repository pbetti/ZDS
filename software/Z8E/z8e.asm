;		************************************************
;		*   *** 18E - Z80/HD64180 DEBUG MONITOR ***    *
;		*  (c) Copyright 1984  by Richard A. Surwilo   *
;		*  (c) Copyright 1988  by Damon R. Gibson      *
;		************************************************

	title	*   *** 18E - Z80/HD64180 Debug Monitor ***    *
; 	subttl	(C) 1984, 1985 by R. A. Surwilo, (C) 1988 by D. R. Gibson

;------------------------------------------------------------------------------
;
;  Copyright (C) 1984, 1985   by Richard A. Surwilo.  All rights reserved.
;
;  No part of this publication may be reproduced, transmitted, transcribed,
;  stored in a retrieval system, or translated into any language or computer
;  language in any form or by any means, electronic, mechanical, magnetic,
;  optical, chemical, manual or otherwise, without express prior written
;  permission of:
;
;      Richard  A. Surwilo  330 Calvin Court, Wyckoff, NJ 074816
;
;  Note:
;	    This program is distributed in violation of the restrictions
;	    on reproduction and transmission outlined above.  It would
;	    appear that Rick Surwilo released this program to the public
;	    domain without removing the notice.
;
;------------------------------------------------------------------------------
;
;                       Revision history
;
;  19 Dec 00 hp  v3.6	Added HD64180 support from Damon R. Gibson's
;			18E V1.0, together with the auxiliary terminal
;			support. Set the H64180 variable below to TRUE
;			to generate a 18E debugger or FALSE to generate
;			a standard Z8E.
;
;  27 Dec 88 jrs v3.5	Released 24 Jan 89.  Includes a few patches by
;			George Havach.
;
;		1.	Changed operation of <cr> in some commands to make
;			a more consistent user interface.  (I won't be
;			offended if users want it changed back - jrs.)
;
;		2.	Enhancement to patch 1.5:- altered the search for
;			"MACRO-80" sentinel in .PRN files to allow for a
;			TITLE pseudo-op.
;
;		3.	Shortened and improved the code for the 'I' command.
;
;		4.	Tested and corrected the ANSIXYCP module which I have
;			been supplying since May 1987.  The code has now been
;			incorporated into the main source file and can be
;			activated during assembly by setting "aterm equ true".
;
;		5.	Discarded the '#' command introduced in 3.3.11 as with
;			a minor adjustment the 'L' command with no file name
;			does the same thing.
;
;		6.	If S or J was last command issued then <cr> alone
;			repeats S or J in single-step mode.  Very useful for
;			stepping through a small section of a program.
;
;	(gah)	7.	Adapted a patch by George Havach to correct the display
;			of IX and IY in disassembled instructions when upper
;			case is set.
;
;	(gah)	8.	Made room for patching in 'clear screen' code at
;			MBANNR: for more dignified start-up.
;
;	(gah)	9.	Replaced tilde ("~") with period (".") as a general
;			substitute for non-displayable ASCII characters, for
;			consistency with practically every other screen-dump
;			utility.  [Retained "hazeltine" conditional - jrs]
;
;  12 Dec 88 jrs v3.4	Made patch 3.3.1 object-configurable because some
;			terminals, particularly those which have binary
;			cursor addressing, must use an offset of 80h to stop
;			the BDOS from expanding tabs and for those terminals
;			clearing bit 7 is nasty.
;
;   5 Dec 88 eg  v3.3	Included a number of fixes and features submitted by
;  (installed by jrs)	Eric Gans in January and March 88.
;
;		 1.	Clear bit 7 of characters sent to screen to avoid
;			strange effects on some computers (such as Kaypro
;			which prints graphic characters if bit 7 is on).
;
;		 2.	Allow 'z' command without an address to mean dis-
;			assemble from last instruction for last-specified
;			number of lines.
;
;		 3.	Allow 'g' command without an address to mean the
;			equivalent of 'g  pc'  or  'g  $' (i.e. continue
;			execution from current instruction).
;
;		 4.	Show absolute destination addresses when dis-
;			assembling relative jump instructions (jr and djnz).
;
;		 5.	Display flags along with registers when using the
;			's' and 'x' commands.
;
;		 6.	Allow easy refresh of the 'animated debug' screen
;			after program output has disturbed it.  Use 'j  #'
;			to force refresh.
;
;		 7.	After Z8E's internal disk I/O operations, reset
;			DMA to 80h for the benefit of target programs.
;
;		 8.	Allow cancellation of commands with CAN (ctrl-X)
;			when argument buffer is empty.  For example if you
;			have entered 'd  100' then first ^X erases the '100'
;			and the second cancels the 'd'.
;
;		 9.	Implement '>' command to change user number and so
;			allow loading of files from user areas other than
;			that from which Z8E was initiated.
;
;		10.	Implement '?' command to evaluate and display argument
;			expressions.  Accepts a register name as the first
;			operand.  (reg) allows indirect addressing so that,
;			for example, '?  (hl)' displays value at the memory
;			location whose address is contained in HL.
;
;		11.	Implement '#' command to recall and display the
;			highest address occupied by a program.
;
;   4 Dec 88 jrs v3.2	Expand asterisks in file names when using 'i' command.
;
;  27 Nov 88 jrs v3.1	Bug fix - deleted three spurious instructions from
;			the initialisation code which was added to support
;			breakpoint vectors at addresses other than 38h.
;
;  16 Nov 88 jrs v3.0	Bumped version number to regain sequence with USA.
;			Until now there were two independent streams of
;			development.  (A date prefixed by '-' denotes a
;			version from the "USA" stream).
;
;			Extended Jim Moore's idea of substituting RST 30h
;			(RST 6) for RST 38h (RST 7).  Now the breakpoint
;			vector address can be patched without re-assembling.
;
;  11 Nov 88 jrs v1.5	Added code to distinguish between .PRN files created
;			by Macro-80 and Z80ASM 1.3 so Z8E can load symbols
;			from either type of .PRN file.
;
;- 30 Nov 87 eg  v2.1	FCB and command tail initialisation routine supplied
;			by Eric Gans.  [Does not appear in the current source
;			as it duplicated v1.4 but consumed more code space.]
;
;  15 May 87 jrs v1.4	Implemented "I" command to initialise the command
;			tail at 80h and the default FCB name blocks at 5Ch
;			and 6Ch.
;
;			Renamed I(nput) command to L(oad) to make way for new
;			I(nitialise) command.  Documentation changed 13/6/87.
;
;			Filtered source code to all lower case.  Sometime
;			Between 1.0 And 1.2 The Comments Had Been Modified So
;			That Every Word Started With A Capital Letter And It
;			Really Did Look Quite Silly.
;
;  20 Apr 87 jrs v1.3	Fixed register display in animated debug mode.  Z8E
;			now handles EX AF,AF' and EXX instructions correctly.
;			Duplicates patch of 21 Oct 86 but was developed quite
;			independently and coded very differently.
;
;			Added equates to tailor the source to assemblers
;			other than M80.
;
;- 21 Oct 86 fh  v2.0	Fixed register display in animated debug mode.  Z8E
;  (installed by gmi)	now handles EX AF,AF' and EXX instructions correctly.
;
;  08 Mar 86 jrs v1.2	(No version number change - all mods purely cosmetic)
;			Modified org directives to bypass bug in M80
;			Added jterm conditional for testing
;			Added hazeltine conditional for tilde suppression
;			Changed dates to more universal format
;
;  16 Jan 86 ijb v1.2	Cursor addressing for post '=>' in jdbg75
;			to cover systems that have a destructive bs
;
;-  3 Dec 85 jgm v?.?	Added EQUates for breakpoint address so it could be
;			something other than 38h.
;
;  25 Sep 85 ras v1.1	Fix case bug
;			Fix usym bug
;			Clean up comments
;
;	ras = Richard Surwilo		Stamford, Connecticut
;	ijb = ?
;	jrs = Jon Saxton		Sydney, New South Wales
;	jgm = Jim Moore			Anaheim, California
;	eg  = Eric Gans			Los Angeles, California
;	fh  = Frankie Hogan
;	gbi = Gary Inman		Los Angeles, California
;	gah = George Havach		California
;	hp  = Hector Peraza
;
;------------------------------------------------------------------------------

true	equ	-1
false	equ	0

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; The following EQUates should both be set to FALSE to generate a "standard"
; Z8E.COM for distribution.
;
; The JTERM is mine which I only put in for use while testing to save having
; to configure the object code for my terminal.  (jrs 8 mar 86)
;
; The ATERM is for an ANSI-compatible terminal such as a VT100 in which case
; setting ATERM to TRUE will cause the ANSIXYCP module to be included during
; assembly.  (jrs 28 dec 88)
;
; Setting H64180 to TRUE enables Hitachi HD64180 support. Set it to FALSE
; for a Z80-only version of Z8E.
;
; Setting AUXPRT to TRUE enables auxiliary debug terminal support, FALSE
; uses the main terminal only.

jterm	equ	false		;Should always be false for distribution
aterm	equ	false		;- - - ditto - - -
h64180	equ	false		;true = Hitachi HD64180 support
				;false = Z80 only
auxprt	equ	false		;true = auxiliary debug terminal support
				;false = main terminal only

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; The following equ should normally be set to 0.  It is only required if
; you have a Hazeltine terminal which uses tilde as a command character

hazeltine equ	false

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Configure this source to your favourite assembler by setting one of
; the following equates to true.  If you use an assembler not mentioned
; below then make up a new equate for it.

M80	equ	false		;Microsoft's Macro-80
ASMB	equ	false		;Cromemco's Z80 assembler
SLR	equ	true		;SLR's lightning-fast Z80ASM assembler

; (Note that there is no real distinction between M80 and SLR.  Either
;  assembler may be used with either EQUate set TRUE.)
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; compact	equ	jterm or aterm
;
;      if	compact
; 	if	ASMB
; 	  conmsg	Non-standard version (not for distribution)
; 	else
; 	  .printx	* Non-standard version (not for distribution) *
; 	endif
;      endif

compact	equ	true		;Already patched for ZDS

     if	not ASMB
	.Z80			;so M80 users don't need /z switch
     endif

     if	ASMB
	list	nogen
page	macro			;Equivalence M80's "page" and ASMB's "form"
	form
	endm
     endif

maxbp	equ	16		;Number of breakpoints configured

bs	equ	08h		;ASCII 	backspace
tab	equ	09h		;	tab
lf	equ	0Ah		;	line feed
formf	equ	0Ch		;	form feed
cr	equ	0Dh		;	carriage return
esc	equ	1Bh		;       escape
ctlx	equ	'X' and	1fh	;	control x - delete line
ctlc	equ	'C' and	1fh	;	control c - warm boot
eof	equ	'Z' and	1fh	;	control z - logical eof
quote	equ	27h		;	quote
tilde	equ	7Eh		;	tilde
del	equ	7Fh		;	del

bdos	equ	5
fcb5c	equ	5Ch		;CP/M default FCB

znop	equ	000		;Z80 instructions
zjp	equ	0C3h
rst38	equ	0FFh

iobuf	equ	80h		;Disk read buffer for symbol loading

	page

;******************************************************************************
;*
;*	nint:	  Initialization - relocating loader - symbol loader
;*
;*	Initialization:
;*	- Save system I register
;*	- Determine max symbol length before loading symbol table
;*        permissable values are 6 and 14 which are converted to bit
;*	  masks by bumping by one
;*	- Set CP/M DMA address to 80h
;*	- Check first command line argument for (xx) where xx is the
;*	  number of slots in the symbol table to reserve.
;*	- Move first file name found in command line to local memory
;*	  since it will be loaded last.  At the end of initialization
;*	  (or symbol loading if required) this file name will be loaded
;*	  into the keyboard input buffer and the file will be loaded
;*	  just as if the user had entered the info as a Z8E command.
;*	- Move all subsequent file names in the command line buffer to
;*	  local input buffer (inbf) in low memory, where they can
;*	  be found by the parse routine (prsr).
;*
;*	Relocating loader:
;*	- Move absolute memory image of Z8E to top of TPA
;*	- Adjust all addresses in relocated monitor to reflect new
;*	  execution area.  This is accomplished by repeated calls to
;*	  zlen to calculate instruction lengths.
;*	- All addresses < the absolute value of z8eorg are considered
;*	  to be absolute values and are not modified.
;*	- Relocate all address pointers in command and operand jump
;*	  tables.
;*
;******************************************************************************

      if	M80 or SLR
	aseg
      endif

      if ASMB
	abs
      endif

      if	ASMB
	entry	case, init, maxlen, bdos
	entry	rstVec, coMask, mBannr
	entry	mxystr, mrowb4, mrow, mcol, mttyq, mttyi, mttyo, mxyprg
        if     auxprt
	  entry	axystr, arowb4, arow, acol, attyq, attyi, attyo, axyprg
	endif
      endif

;     if	SLR or M80
;	Use :: at end of label name to generate a global symbol
;	when assembling to a .REL file (i.e. when using M80 or
;	when using Z80ASM with the /M switch).  Doing it this
;	way lets us assemble to a .REL file with either assembler
;	or directly to a .COM file with Z80ASM without changing
;	the source at all.
;     endif

	org	100h

	jp	nint

      if	ASMB
rstVec:
      else
rstVec::
      endif
	defb	38h		;Default (but patchable) breakpoint vector

      if	ASMB
coMask:
      else
coMask::
      endif
	defb	0FFh		;Mask applied to characters before output
				;to screen.  Patch to 0FFh if your terminal
				;needs high-order bit set on occasions.

      if	ASMB
mbannr:
      else
mbannr::
      endif
      if	jTerm
	defb	15h,17h
      else
	defb	0ch		;ZDS "clear screen" code
      endif
	defb	cr,lf
	if	h64180
	  defb	'18E'
	else
	  defb	'Z8E'
	endif
	defb	' V3.6 - 19 Dec 2000'
	defb	cr,lf
	defb	'Copyright (c) 1984, 1985  Richard A. Surwilo'
	defb	cr,lf
	defb	'Z80NE (ZDS) port 2017 by P.Betti'
	defb	cr,lf,lf
	defb	0

nint:
	ld	sp,stack
	ld	a,i		;Save i reg for user
	ld	(ireg),a
	call	init
	ld	de,mbannr	;Dispense with formalities
	call	print

; Patch code for a specific breakpoint routine address.
;
; Adapted from an idea by Jim Moore (3 Dec 85) but made object-patchable
; (jrs 15 Nov 88)

	ld	a,(rstVec)	;Get breakpoint vector address
	ld	l,a
	ld	h,0
	ld	(nint03+1),hl	;Patch the code
	inc	hl		;HL now holds rstVec+1
	ld	(nint71+1),hl	;Patch some more code
	or	0C7h		;Convert vector address into RST xx
	ld	(g400+1),a	;Patch the code
	ld	(g518+1),a

; Patch code for terminal output - jrs 3.4

	ld	a,(coMask)	;Get console output character mask
	ld	(ttyo00+1),a

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
nint00:	ld	(maxlin),a
	ld	a,b
	ld	(maxlen),a
	ld	a,c
	ld	(fwndow),a
	ld	a,d
	ld	(nlmask),a

; Reset CP/M DMA address for those instances in which Z8E is used to debug
; itself.  Otherwise DMA address is left where Z8E stopped loading itself.
; (Last statement no longer true - see patch 3.3.1)

	ld	de,80h
	ld	c,26
	call	bdos

	ld	a,zjp		;Initialize where L80 fears to tread

; The next instruction is PATCHED before it is executed
nint03:	ld	(38h),a		;Init trap to breakpoint handler

	ld	hl,5dh		;Save current contents of default fcb
	ld	a,(hl)
	cp	'('		;Is first char in fcb a paren?
	dec	hl
	jr	nz,nint25	;Not paren - no user symbol table requested
	inc	hl		;Point back to paren
	ld	de,inbf		;Start of input buffer here in low memory
	ld	b,15		;Max chars in fcb following first paren
nint05:	inc	hl		;Bump fcb pointer
	ld	(de),a		;Move char to low memory keyboard input buffer
				;so that prsr thinks this is keyboard input
	inc	de		;Bump input buffer pointer
	ld	a,(hl)
	cp	')'		;Look for trailing paren
	jr	z,nint10
	djnz	nint05		;Examine entire fcb at 5ch looking for paren
	ld	hl,fcb5c	;Trailing paren not found - this must be
				; kookie file name
	jr	nint25		;Ignore

; Call iarg to determine amount of space to allocate in user symbol table.
; This arg must be enclosed in parentheses and must appear after the first
; arg in the command line.  Since opening and closing parens were found
; add a pound sign to make this into default decimal number then call xval
; to evaluate.

nint10:	ex	de,hl		;HL - input buffer pointer
	ld	(hl),'#'	;Add trailing paren before calling iarg
				;who will evaluate argument as if it was
				;entered from keyboard
	inc	hl
	ld	(hl),a		;Restore trailing paren following pound sign
	inc	hl
	ld	(hl),0		;Add end of line null
	call	iarg
	ex	de,hl		;DE - evaluated argument
	ld	hl,fcb5c
	jr	nz,nint25	;Arg error - ignore input
	ld	hl,81h		;Start of command line tail
nint15:	ld	a,(hl)
	ld	(hl),' '	;Replace the text which appeared between
				;the parens and the parens themselves with
				;spaces

	cp	')'		;Closing paren ends search
	jr	z,nint20
	inc	hl		;Point to char following closing paren
	jr	nint15
nint20:	ex	de,hl		;Arg to hl for mult times maxlen bytes per
				;symbol table entry
	add	hl,hl
	add	hl,hl
	add	hl,hl
	ld	a,(maxlen)	;8 or 16 bytes per symbol table entry?
	cp	7
	jp	z,nint22	;z - must be 8
	add	hl,hl
nint22:	ex	de,hl
	ld	(usymbl),de	;Save number of bytes to reserve
	ld	hl,6ch		;since user symbol table arg was present then
				;target file must be in default fcb number 2

nint25:	ld	de,zbuf		;Local buffer
	ld	bc,16
	ldir			;Move FCB contents to local memory
	ld	hl,80h		;Command line buffer address
	ld	a,(hl)
	and	a		;Test for no input
	jr	z,nint55	;No input - clear symbol table
	ld	c,a		;BC - number of chars in command line buffer
	ld	(hl),b		;Clear byte count
	add	hl,bc		;Point to last char in buffer
	inc	hl
	ld	(hl),b		;Set end of line null after last char
	ld	hl,81h
nint30:	ld	a,(hl)		;Look for start of first file name
	and	a		;Found the end of line null?
	jr	z,nint55	;Z - no files to load
	cp	' '		;Leading space?
	jr	nz,nint35	;Not space - found start of file name
	inc	hl
	dec	c		;Decrement command line byte count
	jr	nint30		;Keep looking for start of file name
nint35:	ld	de,znmbuf	;Save name here for later display
	ld	(de),a
	inc	de
nint40:	inc	hl		;Find first trailing space
	ld	a,(hl)
	cp	' '
	jr	z,nint45	;Found space - move remainder of buffer
	ld	(de),a		;Save file name character for display
	inc	de
	and	a		;End of line?
	jr	z,nint55	;z - only one file specified
	dec	c
	jr	nint40
nint45:	ld	a,c		;Check byte count
	cp	inbfsz		;versus size of our local input buffer
	jr	c,nint50	;carry - size is ok
	ld	c,inbfsz	;Only move as much as will fit
nint50:	ld	de,inbf
	ldir			;Move command line to local memory
	xor	a

nint55:	ld	hl,z8eorg	;clear local symbol table to nulls
	ld	b,z8e-z8eorg	;symbol table size
nint60:	ld	(hl),a		;nulls to entire local symbol table
	inc	hl
	djnz	nint60
	ld	hl,(06)		;start of bdos
	ld	l,a		;init stack address to 256 boundary
	ld	bc,nmem		;monitor size
	and	a
	sbc	hl,bc		;hl - starting address of z8e in upper
				;memory
	ld	(z8eb),hl	;monitor bias - for relocation work
	ld	de,(usymbl)
	sbc	hl,de
	ld	(ntpa),hl	;end of tpa - for symbol loading
	ld	a,d		;check for no user symbol table
	or	e
	jr	z,nint75	;no table - no clearing required
nint70:	ld	(hl),0		;fill user symbol table with nulls
	inc	hl
	dec	de
	ld	a,d
	or	e
	jr	nz,nint70
nint75:	ex	de,hl		;hl - start of z8e in hi memory

	ld	hl,bphn-z8eorg	;entry point to breakpoint handler
	add	hl,de

; The next instruction will be PATCHED by the time it is executed.
nint71:	ld	(39h),hl	;Init RST 38h trap location

	ld	hl,z8eorg
	ldir			;z8e now in hi memory - relocate addresses
	ld	hl,(z8eb)	;recover hi memory starting address
	ld	de,z8ecmd-z8eorg
	add	hl,de		;first instruction to relocate
	ex	de,hl
nint80:	call	zlen00		;calculate instruction length
	ld	h,d
	ld	l,e		;de - current instruction   hl - ditto
	ld	b,0
	add	hl,bc
	ex	de,hl		;de - next address to relocate
	ld	a,c		;test length
	sub	3
	jr	c,nint90	;one or two byters are non-relocatable
	ld	c,a
	add	hl,bc		;bump if four byter
	ld	a,(hl)
	ld	hl,z80r		;table of relocatable instructions
	ld	c,z80rl		;size
	cpir
	jr	nz,nint90	;nz - not relocatable
	ex	de,hl
	dec	hl		;point to address byte requiring bias
	ld	a,(hl)
	sub	z8eorg shr 8	;test for absolute address < z8eorg
	jr	c,nint85	;absolute - no relocation needed
	ld	b,a
	ld	a,(z8ebh)	;hi order byte of address bias
	add	a,b		;plus upper byte of operand address
	ld	(hl),a		;set relocated address
nint85:	inc	hl
	ex	de,hl		;de - next address to test
nint90:	ld	bc,nrel-z8eorg	;end of relocatable portion of monitor
	ld	hl,(z8eb)
	add	hl,bc		;hl - absolute end of relocated monitor
	and	a
	sbc	hl,de		;reached end?
	jr	nc,nint80	;nc - more
	ld	de,ncmd+zopjtl	;size - command and operand jump tables
	ld	hl,(z8eb)	;base of relocated monitor
	ld	a,-(high z8eorg); [was:  ld a,-(z8eorg/256)]
	add	a,h		;relocation bias byte to add to ptrs
	ld	d,a		;d - bias to add  e - count of pointers
				;		      requiring relocation
	add	hl,bc		;first point to operand names
	ld	bc,zopjtb	;add length of operand name table
	add	hl,bc		;point to first entry in jump table
nint95:	inc	hl
	ld	a,(hl)		;hi byte jump table entry
	add	a,d		;plus bias
	ld	(hl),a		;replace in table
	inc	hl
	dec	e
	jr	nz,nint95	;nz - more table entries to relocate


;******************************************************************************
;*
;*	ZSYM:	Symbol table build from .SYM and .PRN files
;*
;*	LFCB called to parse the input buffer (inbf) in low memory.
;*	INBF contains the command line tail which bdos passed to us at
;*	80h and which we have since moved to inbf (so that prsr thinks
;*	it's just keyboard input).
;*
;*	All valid file names are opened for input.
;*
;*	If the file name terminates with a comma then we assume the
;*	user is specifying a bias which is to be added to every symbol
;*	loaded from the file.
;*
;*	zsym	general file handiling
;*	.SYM	load L80 .SYM file or load SLR .LST file
;*	.PRN	load M80 .PRN file or load SLR .PRN file
;*
;*	Symbol table always begins on an 8 or 16 byte boundary
;*	depending on the value in maxlen.
;*
;******************************************************************************

zsym:	call	lfcb		;Initialize fcb
	jp	nz,zstx		;nz - error
	ld	de,mldg		;Display loading message
	call	nprint		;Output crlf - then print
	ld	de,prsbf
	call	print		;Display file name
	ld	a,c 		;lfcb returns delimeter in c reg
	ld	(delim),a	;Temp save delimiter so we know if a bias has
				;been specified
	call	crlf
	call	lopn		;Try to open symbol table file
	dec	a		;
	jp	m,zfnf		;m - file not found
	ld	a,(delim)	;Check delimeter
	cp	','
	ld	hl,00
	jr	nz,zsym10	;nz - no comma means no symbol bias
	call	prsr		;Let prsr extract symbol bias
	jp	nz,zoff		;Parse error - use bias of 0000
	ld	(delim),a	;Save delimeter which followed bias
	ld	de,prsbf
	ld	hl,00
	call	xval		;Evaluate bias
	jr	z,zsym10	;z - numeric bias specified

				;User has specified a bias in the form
				; of a symbol name
	ld	hl,(ntpa)	;Check bias specified by symbol name
	ld	a,(maxlen)
	cpl
	ld	e,a
	ld	d,0ffh		;Lower end of TPA by amount equal to
				; the value of maxlen negated to insert
				; jump to bdos
	add	hl,de
	ld	a,(case)	;Check case of symbol table
	and	a
	jp	z,zsym05	;z - symbol names are already in upper case
	ld	de,prsbf	;prsr stored symbol name here
zsym00:	ld	a,(de)
	and	a
	jp	z,zsym05	;z - end of label symbol name
	call	ilcs		;Change each char in symbol name to lower case
	ld	(de),a
	inc	de		;Store converted character
	jp	zsym00
zsym05:	ld	de,prsbf
	call	fsym00		;Search symbol table
	jp	nz,zoff		;nz - not found
	ld	a,(maxlen)
	or	l
	ld	l,a
	ld	a,(hl)		;Fetch hi order address associated
				; with symbol
	dec	hl
	ld	l,(hl)
	ld	h,a		;HL - symbol value
zsym10:	ld	(bias),hl	;Bias to add to each symbol address
	ld	hl,00
	ld	a,(fcbtyp)
	ld	bc,(ntpa)	;Current end of TPA
	cp	'S'		;Is this a .SYM file?
	jp	z,.sym		;.SYM file loaded differently from .PRN
	cp	'L'
	jp	nz,.prn		;If not .LST then must be .PRN
	ld	de,.lst??	;Look for .LST string id string
	ld	(pstrng),de	;Store pointer to string to find
	call	fstrng

				;BC - symbol table pointer

.sym:	ld	a,(maxlen)	;Lower TPA address by 16 or 8
	cpl
	and	c		;for storing next symbol and address
	ld	c,a
	ld	a,(maxlen)
	cpl			;This is negate plus one
	add	a,c
	ld	c,a
	jp	c,.sym00	;Treat carry as complement of subtraction
	dec	b
.sym00:
	ex	de,hl
	ld	hl,stack+8	;Check for monster symbol table ready to eat us
	and	a
	sbc	hl,bc
	jp	nc,zmem		;End symbol load before stack is clobbered
	ex	de,hl
	ld	a,(maxlen)	;Load symbol length mask (7 or 15)
	dec	a		;
	ld	d,a		;D - actual max length of symbols (6 or 14)
	xor	a
.sym10:	ld	(bc),a		;Init symbol table entry to nulls
	inc	bc
	dec	d
	jr	nz,.sym10
	ld	e,d		;Clear DE for hex00
	xor	a
	ld	(star),a	;Clear ** found flag
	ld	a,4		;Convert four bytes of address
	ld	(bytes),a
.sym20:	call	nchr		;Fetch next character in file
	cp	eof
	jp	z,.eof		;End of this symbol file
	cp	'0'
	jr	nc,.sym25	;c -  must be control character or space
				;nc - possible first char of address
	cp	lf
	jp	z,.sym21
	cp	'*'		;** in SLR .SYM file?
	jp	nz,.sym20
	ld	(star),a
	jp	.sym25

.sym21:
	call	nchr		;Fetch char following lf
	cp	cr
	jp	z,.sym22	;z - consecutive crlf's means end of page
	cp	'0'
	jp	nc,.sym25	;nc - symbol address on new line
	cp	eof
	jp  	z,.eof
	cp	'*'		;** ?
	jp	nz,.sym20
	ld	(star),a
	jp	.sym25

.sym22:
	ld	a,(fcbtyp)
	cp	'L'		;z80asm .LST file?
	jp	z,.sym23
	cp	'P'		;Macro 80 V3.4?
	jp	nz,.sym20
.sym23:
	ld	de,.lst??	;Bypass inter-page verbiage
	ld	(pstrng),de
	call	fstrng
	cp	eof
	jp	z,.eof

	call	nchr
	cp	eof
	jp	z,.eof


.sym25:	call	hex00		;Have first char of address - convert
	call	totsym		;Bump total of symbols loaded
	ld	a,(fcbtyp)	;Is this a .SYM file?
	cp	'S'
	call	nz,nchr		;Eat addrress/symbol separator for .LST file
	ld	a,(maxlen)
	dec	a
	ld	(bytes),a	;Init max symbol length counter
.sym30:	call	nchr		;Read symbol name char
	cp	tab
	jp	z,.sym45
	cp	cr
	jp	z,.sym45
	cp	' '
	jp	z,.sym45
	ld	(bc),a
        ld	a,(case)	;Check user requested case
	and	a
	jr	z,.sym35	;z - upper case requested by user
	ld	a,(bc)		;Recover char
	cp	'A'
	jr	c,.sym35	;c - must be number
	cp	'Z'+1
	jp	nc,.sym35
	or	20h
	ld	(bc),a		;Restore symbol name char as lower case
.sym35:	inc	bc
	ld	a,(bytes)
	dec	a
	ld	(bytes),a
	jr	nz,.sym30
.sym40:	call	nchr
	cp	21h
	jp	nc,.sym40
.sym45:	ld	a,(star)	;Check if this was ** in address field
	and	a
	jp	nz,.sym50
	ld	a,(relchr)	;Check for external symbol
	cp	' '
	jp	z,.sym		;Space means absolute
	cp	quote
	jp	z,.sym		;Quote means relocatable
.sym50:	ld	a,(maxlen)
	or	c
	ld	c,a
	inc	bc		;Point BC to next higher symbol block so
				;that rewinding by maxlen bytes will actually
				;overlay this symbol.  This ensures that
				;external symbols are not kept in table.

	jp	.sym


.prn:				;Don't yet know if this .PRN file was
				;generated by M80 or Z80ASM.  To find out
				;I pull a dirty trick.  I force a read
				;and look for a formfeed, up to 80 characters
				;of program title, a HT and "MACRO-80" in the
				;I/O buffer, then I reset the pointer so that
				;the next character read comes from the
				;beginning of the file.  Will probably get
				;confused by a HT in the program title.
				;  jrs 14/11/88, 22/12/88.

	call	nchr		;Force a read.  First byte of file is
				; returned in A, pointer to next byte in HL
	cp	formf		;Test character
	jr	nz,.prnBB	;Exit M80 testing now if not a formfeed
	ld	b,82		;Maximum number of characters to search
	ld	a,tab		;What to look for
	cpir
	jr	nz,.prnBB	;If no tab then not an M80 .PRN file
	ex	de,hl		;Point at strings to be compared
	ld	hl,.m80??
	ld	b,(hl)		;Number of bytes to compare
	inc	hl
.prnAA:
	ld	a,(de)		;Compare bytes
	cp	(hl)
	jp	nz,.prnBB	;Exit loop if different
	inc	hl		; otherwise step the pointers
	inc	de
	djnz	.prnAA		;Loop until difference encountered or
.prnBB:				; all bytes compared.
	ld	hl,iobuf	;Reset buffer pointer
	ld	bc,(ntpa)
	jp	nz,.slr		;If not M80 then do Z80ASM .PRN file load

	; End of dirty trick code

	ld	de,.prn??
	ld	(pstrng),de
	call	fstrng
	cp	eof
	jp	nz,.prn00
.prnCC:
	ld	de,msymnf	;display symbol table not found message
	call	print
	jp	.eof50		;check for more symbol files to load

.prn00:
	ld	bc,(ntpa)	;bc - current end of the tpa
	dec	bc		;this points us into the next lower
				;symbol table block
				;this is first char of symbol table
	xor	a
	or	l		;get next byte from file but without bumping
				;pointer allowing us to reread same char in
				;case it is last character in buffer

	call	z,read		;only do true read if last character was last
				;in buffer
	ld	a,(hl)
	cp	'0'
	jp	c,.pr325	;non-numeric: Macro-80 V3.44

	cp	'9'+1
	jp	c,.pr4		;numeric:     Macro-80 V3.4


; Macro-80 V3.4 dec 1980 symbol table load

.pr325:	ld	a,(maxlen)
	cpl
	and	c		;now rewind within 8 or 16 byte block
				;(depending on maxlen) in order to point
				;to first byte
	ld	c,a

        ex	de,hl		;de - save file buffer pointer
	ld	hl,stack + 16	;check for encroaching symbol table
	sbc	hl,bc		;versus current symbol table address
	jp	nc,zmem		;nc - out of memory
	ex	de,hl		;return file buffer pointer
	ld	a,(maxlen)
	ld	d,a
	dec	d		;d - symbol name length
	xor	a
	ld	e,a
.pr330:	ld	(bc),a		;pre-clear name portion of symbol table to
				;nulls
	inc	bc
	dec	d		;now any name less than maxlen chars in length
	jp	nz,.pr330	;is terminated with a null
	ld	a,(maxlen)
	cpl
	and	c
	ld	c,a
.pr335:	call	nchr		;next char from file buffer
	cp	21h
	jp	nc,.pr351	;nc - this is first character of symbol name
	cp	eof		;end of file?
	jp	z,.eof
	cp	lf		;line feed?
	jp	nz,.pr335
.pr340:	call	nchr		;get character following line feed
	cp	cr
	jp	z,.pr342
	cp	formf		;form feed?
	jp	nz,.pr351
.pr342:	ld	e,3		;symbols resume three lines hence following
				;a form feed character - so count linefeeds
	cp	cr		;did we find cr or a formf?
	jp	nz,.pr345	;nz - formf
	dec	e		;just look for two lf's
.pr345:	call	nchr
	cp	lf
	jp	nz,.pr345	;loop til three found
	dec	e
	jp	nz,.pr345

	xor	a
	or	l		;get next byte from file but without bumping
				;pointer allowing us to reread same char in
				;case it is last character in buffer

	call	z,read		;only do true read if last character was last
				;in buffer
	ld	a,(hl)
	cp	cr		;four crlf's is eof
	jp	z,.eof

.pr350:	call	nchr		;next char from file
	cp	eof
	jp	z,.eof
	cp	tab
	jp	z,.pr355
.pr351:	ld	(bc),a		;move character of symbol name
	ld	a,(case)	;check user requested case
	and	a
	jr	z,.pr352	;z - user wants upper case
	ld	a,(bc)		;get char back from symbol table
	cp	'A'
	jr	c,.pr352	;must be numeric - no case here
	cp	'Z'+1
	jr	nc,.pr352
	add	a,20h
	ld	(bc),a		;replace char with lower case equivalent
.pr352:	inc	bc
	jp	.pr350

.pr355:	ld	a,4
	ld	(bytes),a
.pr357:	call	nchr
	cp	' '
	jp	z,.pr357

	call	hex00		;now read the next four characters from the
				;file and convert them to a hex address -
				;store in symbol table entry


	ld	a,(relchr)	;recover char which followed address

	cp	' '		;this char followed address
	jr	z,.pr370	;microsoft absolute address
	cp	quote		;relocatable address?
	jp	nz,.pr325
				;by not rewinding the symbol table pointer
				;the next symbol will overlay this one.

.pr370:	dec	bc
	call	totsym

	jp	.pr325


; Macro-80 V3.44 symbol loading routine

.pr4:	ld	a,(maxlen)	;lower tpa address by maxlen
	cpl
	and	c		;for storing next symbol and address
	ld	c,a		;bc - next address of symbol table entry
				;     on an 8 or 16 byte boundary
	ex	de,hl
	ld	hl,stack+8	;check for monster symbol table
	and	a
	sbc	hl,bc
	jp	nc,zmem		;end symbol load before stack is clobbered
	ex	de,hl
	ld	a,(maxlen)
	dec	a		;pre-clear symbol table entry with nulls
	ld	d,a
	xor	a
.pr410:	ld	(bc),a		;for length equal to maxlen
	inc	bc
	dec	d
	jr	nz,.pr410
	ld	e,d		;clear de for hex00
	ld	a,4		;convert four bytes of address
	ld	(bytes),a
.pr420:	call	nchr		;fetch next character in file
	cp	eof
	jp	z,.eof
	cp	'0'
	jr	nc,.pr425	;nc - address digit
	cp	lf
	jp	nz,.pr420	;nz - leading space or cr


	call	nchr		;check character following lf
	cp	cr
	jp	z,.eof		;blank line is eof

	cp	formf		;form feed?
	jp	nz,.pr425	;no - first character of next address

	ld	e,3		;must be form feed
.pr421:	call	nchr
	cp	lf		;three lf's follow form feed before symbols
				;resume on next page
	jp	nz,.pr421
	dec	e
	jp	nz,.pr421

	call	nchr
	cp	eof
	jp	z,.eof

.pr425:
	call	hex00		;have first char of address - convert

	call	nchr		;eat address/symbol separator

	ld	a,(maxlen)
	dec	a
	ld	(bytes),a	;max chars to store in symbol table


.pr430:	call	nchr		;read symbol name char
	cp	21h
	jp	c,.pr440	;found separator
	ld	(bc),a
        ld	a,(case)	;check user requested case
	and	a
	jr	z,.pr435	;z - upper case requested by user
	ld	a,(bc)		;recover char
	cp	'A'
	jr	c,.pr435	;c - must be number
	cp	'Z'+1
	jr	nc,.pr435
	or	20h
	ld	(bc),a		;restore symbol name char as lower case
.pr435:	inc	bc		;bump symbol table pointer
	ld	a,(bytes)	;character counter
	dec	a
	ld	(bytes),a
	jp	nz,.pr430	;not max length


.pr438:	call	nchr		;eat chars until next address found
	cp	eof
	jp	z,.eof
	cp	' '		;found symbol/address
	jp	nz,.pr438


.pr440:	ld	a,(maxlen)
	cpl
	and	c
	ld	c,a

	ld	a,(relchr)	;recover char which followed address
	cp	' '		;this char followed address
	jr	z,.pr450	;Microsoft absolute address
	cp	quote		;relocatable address?
	jp	nz,.pr4		;nz - must be  external symbol. We don't
				;actually load them or count them in total.
				;By not rewinding the symbol table pointer
				;the next symbol will overlay this one.

.pr450:	dec	bc
	call	totsym
	jp	.pr4

; SLR Z80ASM symbol table loading routines

.slr:
	ld	de,.slr??	;If this .PRN file really is a Z80ASM
	ld	(pstrng),de	;product then we can use existing code
	call	fstrng		;to load the symbols.
	cp	eof
	jp	nz,.sym
	ld	de,msymnf	;display symbol table not found message
	call	print
	jp	.eof50		;check for more symbol files to load


.eof:				;We always pre-decrement the symbol table
				;pointer in anticipation of storing the next
				;symbol.  Now that we hit the end of a symbol
				;table we must adjust the pointer in
				;preparation for loading the symbols from the
				;next file (if there is one).
        ld	a,(maxlen)
	ld	l,a
	ld	h,0
	inc	l
	add	hl,bc		;point to last loaded symbol
	ld	b,h
	ld	c,l		;bc - spare copy
	cpl
	and	c
	ld	c,a
	ld	(ntpa),bc	;save current end of tpa address
        ld	a,(nsymhi)	;hi order number of symbols loaded (bcd)
	call	hexc		;convert to ascii
	ld	h,a		;returned in a - move to h (other digit in l)
	ld	(mhex),hl	;store in message
	ld	a,(nsymlo)
	call	hexc		;convert lo order
	ld	h,a
	ld	(mhex+2),hl
	ld	de,msym..	;display number of symbols loaded message
	ld	c,9
	call	bdos
	ld	de,mhex		;now look thru ascii number of symbols to
				;strip leading zeros
	ld	b,3
.eof10:	ld	a,(de)
	cp	'0'
	jr	nz,.eof20	;nz - found first non-zero
	inc	de
	djnz	.eof10		;if first three chars zero - fall thru and
				;print the fourth regardless
.eof20: ld      c,09
	call	bdos		;print the number as string ending with $
	call	crlf
	ld	hl,(tsym)	;now add in bcd total for this file to bcd
				;total for all files
	ld	de,(nsym)	;tsym - total for all files
				;nsym - total for this file
	ld	a,h
	add	a,d
	daa
	ld	h,a
	ld	a,l
	adc	a,e
	daa
	ld	l,a
	ld	(tsym),hl
	ld      hl,00		;clear out total for next file
	ld	(nsym),hl
	ld	hl,(z8eb)
	ld	de,symflg-z8eorg
	add	hl,de		;hl - pointer to symbol flag in hi memory
	xor	a
	ld	(hl),a		;zero - symbol table present
	ld	(symflg),a	;also set flag in lo memory where we are
				;currently so that fsym knows theres a symbol
				;table to search thru if the user specified a
				;symbol name bias as part of the command line

.eof50:	ld	a,(delim)	;check command line delimter
	and	a		;test for end of line null
	jp	nz,zsym		;nz - not null means more files




load:	ld	hl,(ntpa)	;current end of memory
	ld	a,(symflg)	;check for symbol table
	and	a
	jr	nz,load00	;nz - no symbol table
	ld	d,a
	ld	a,(maxlen)
	ld	e,a		;de - length of a symbol table block
	inc	e
	sbc	hl,de		;compensate for pre-increment of pointer
load00:	ld	de,(06)		;de - real entry point to bdos
	ld	(06),hl		;point to our origin in hi memory
	ld	(hl),zjp	;init jump to bdos at start of z8e
	inc	hl
	ld	(hl),e
	inc	hl
	ld	(hl),d
	ld	e,0		;de - old start of bdos address in also our
				;ending address
	ld	hl,(z8eb)	;load out starting address in hi memory
	ld	bc,z8e-z8eorg	;fetch the number of bytes between z8e's base
				;address and the entry point of the command
				;processor  - internal symbol table size

	add	hl,bc
	ld	b,h
	ld	c,l		;BC - relocated z8e address
	ex	de,hl		;DE - entry point z8e   HL - old start of bdos
	dec	hl		;HL - last byte in our memory

				;Now we "rom" our entry Point onto the top of
				;the stack so that all commands can return to
				;the command processor via a simple RET.
	ld      (hl),b
	dec	hl
	ld	(hl),c		;z8e (monitor entry point) on stack
	ld	sp,hl		;now set current stack to just below our
				;return address
	ex	de,hl		;hl - relocated address z8e
	inc	hl
	inc	hl		;hl - points to ld  sp,0000 instruction at the
				;start of the command processor. Replace 0000
				;with the address bdos-1
	ld	(hl),e		;set real stack address
	inc	hl
	ld	(hl),d
	ld	hl,(z8eb)	;base of relocated code
	ld	de,fcb-z8eorg	;relative offset from start of monitor
	add	hl,de
	ex	de,hl		;de - fcb address in relocated monitor in hi
				;memory
	ld	hl,zbuf
	ld	bc,16
	ldir			;init fcb with saved file name
	ld	de,mz8eld	;print memory space occupied by z8e
	call	print
	ld	hl,(z8eb)	;display our base address in upper memory
	call	outadr
	ld	a,'-'
	call	ttyo
	call	space1
	call	space1
	ld	hl,(06)		;this points to the new jump to bdos
	inc	hl
	ld	e,(hl)		;de - old start of bdos address
	inc	hl
	ld	d,(hl)
	ex	de,hl
	ld	l,0		;256 byte boundary to bypass cp/m serial no.
	call	outadr

	ld	a,(symflg)	;test for presence of symbol table
	and	a
	jr	nz,load40	;nz - no table
	ld	de,msymld	;display start address of symbol table message
	call	print
	ld	hl,(06)		;vector to bdos is start of symbol table
	call	outadr
	ld	a,'-'
	call	ttyo
	call	space1
	call	space1
	ld	hl,(z8eb)	;start of internal symbol table is end of
				;symbol table built from files
	dec	hl
	call	outadr

	ld	a,(tsymhi)	;total number of symbols from all files (bcd)
	call	hexc		;convert to ascii
	ld	h,a		;move hi order ascii digit to h
	ld	(mhex),hl	;store double ascii digit
	ld	a,(tsymlo)
	call	hexc		;convert lo order
	ld	h,a
	ld	(mhex+2),hl	;save in string
	ld	de,tsym..	;total symbols message
	ld	c,9
	call	bdos
	ld	de,mhex		;address of ascii digits
	ld	b,3		;check for leading zeros
load20:	ld	a,(de)
	cp	'0'
	jr	nz,load30	;nz - found first nz in string
	inc	de
	djnz	load20		;check first three digits then fall thru and
				;print fourth regardless
load30:	ld	c,09
	call	bdos

load40:	ld	hl,(06)
	dec	hl		;hl - address of new tpa
	ld	de,mnvmem	;display address as memory available
	call	print
	call	outadr
	call	crlf
	ld	(hl),0		;now store two zeros at the top of the tpa and
				;set stack pointer to this very same address.
				;this allows users to do a warm boot via ret
				;in the same way as if they had been loaded by
				;cp/m.
	dec	hl
	ld	(hl),0
	ld	bc,(z8eb)	;our relocated address in hi memory
	ex	de,hl		;de - last available location in tpa
	ld	hl,spreg-z8eorg ;address (relative to the start of z8e) where
				;we store the user stack pointer address
	add	hl,bc		;hl - pointer to
	ld	(hl),e		;save user stack in spreg in hi memory
	inc	hl
	ld	(hl),d
	ld	hl,z8e-z8eorg
	ld	a,(zbufnm)	;first char of file name
	cp	' '		;do we have a file to load?
	jr	z,load50	;z - no
	ld	de,mldg		;display loading message and target file name
	call	nprint
	ld	de,znmbuf
	call	print
				;enter the monitor in hi memory at entry
				;point lldr10

	ld	hl,lldr10-z8eorg
	ld	bc,(z8eb)
load50:	add	hl,bc		;hl - actual address of lldr10 in hi memory
	ex	de,hl		;now clear out the buffer at 80h so the user
				;program doesn't mistakenly think that our
				;command line tail is really his.
	ld	hl,iobuf
	ld	(hl),0		;set number of chars zero (80h)
	inc	hl
	ld	b,127		;clear until start of tpa
load60:	ld	(hl),' '
	inc	hl
	djnz	load60
	ex	de,hl		;lldr10 address back to HL
	jp	(hl)		;Hi-ho, hi-ho to the loader we must go



	page

; This routine reads one char from the disk I/O buffer returning it in A.
; Upon entry we check the low order buffer pointer: 0 means we hit the 256
; boundary (end of buffer) and a read is needed.

nchr:	xor	a
	or	l
	call	z,read
	ld	a,(hl)
	inc	hl
	ret

read:	push	bc
	push	de
	ld	de,fcb
	ld	c,20		;sequential file read
	call	bdos
	and	a		;test for error
	ld	hl,iobuf	;assume ok - init i/o buffer address
	pop	de
	pop	bc
	ret	z		;z - no errors
	ld	de,msymnf	;display symbol table not found message
	call	print
	ld	sp,stack	;reinit stack
	jp	.eof50		;check for more symbol files to load


; hexc
; Convert byte in a to two ASCII hex digits.
; return: a - converted hi order digit
;         l - converted lo order digit

hexc:	ld	h,a
	rrca
	rrca
	rrca
	rrca
	call	hexc00
	ld	l,a
	ld	a,h
hexc00:	and	0fh
	add	a,90h
	daa
	adc	a,40h
	daa
	ret


;hex:
; This routine is called by the symbol table building routines,
; .SYM and .PRN and its function is to convert ascii addresses
; into binary.  Since we are reading files in a known format
; we don't init any loop counts; instead, we look for delimeters.


hex:	call	nchr		;get char from disk i/o buffer
hex00:	cp	3ah		;convert ascii to hex
	jp	c,hex10		;c - must be delimeter
	sub	7
hex10:	sub	'0'
	ex	de,hl		;shift hl left four
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,hl
	or	l		;or in this new digit
	ld	l,a
	ex	de,hl
	ld	a,(bytes)
	dec	a
	ld	(bytes),a
	jp	nz,hex
	call	nchr
	cp	'I'		;global?
	call	z,nchr		;z - need to read next to determine absolute
				;    or relocatable

	ld	(relchr),a	;we need to save this character for .PRN files
				;so we can tell whether to add this symbol
				;to the count of symbols loaded.  If this
				;is an external name we skip the add.

	cp	' '		;space means absolute
	jr	z,hex30		;no bias added to absolute symbols
	ld	a,(biaslo)
	add	a,e		;add in bias as specified by user or default
				;as initialized by us (zero)
	ld	e,a
	ld	a,(biashi)
	adc	a,d
	ld	d,a
hex30:	ld	a,(maxlen)	;now point to last byte of symbol table
				;entry, which is where we will store
				;address just computed
	cpl
	and	c
	ld	c,a
	ld	a,(maxlen)
	or	c
	ld	c,a		;never worry about carry - we always start
				;with 256 boundary
        ld	a,d		;store lo order symbol address
	ld	(bc),a
	dec	bc		;point to penultimate byte in block
	ld	a,e		;hi order byte of address into symbol table
	ld	(bc),a
	ld	a,(maxlen)	;mask to rewind symbol table pointer to the
				;start of this block
	cpl
	and	c
	ld	c,a
	ret


totsym:	ld	de,nsymlo	;nsym - bcd running count of the number of
	ld	a,(de)		;       symbols loaded so far
	add	a,1		;bump by one symbol
	daa			;keep bcd format
	ld	(de),a
	ret	nc
	dec	de		;account for carry by bumping hi order byte
	ld	a,(de)
	add	a,1
	daa
	ld	(de),a
	ret


;zstx:
; Possible syntax error was detected as lfcb tried to init the FCB.
; However, we never keep track of how many files appeared in the
; command line we just keep calling lfcb.  Hence, we will always get
; an error return at some point when the input buffer runs out of
; valid input.  We check for real syntax error or end of command
; line by examining the first byte of the parse buffer:  if zero then
; prsr found no valid characters in the input buffer and this is the
; end of input - else, lfcb found real syntax error.


zstx:	ld	a,(prsbf)
	and	a		;real syntax error - or end of input?
	jp	z,load		;z - more files
	ld	de,mldg		;display loading message and symbol name
				;to preserve the syntax used on good loads
	call	nprint
	ld	de,prsbf	;display file name currently in parse buffer so
				;user knows where goof was
	call	print
	call	crlf
	ld	de,msntx	;now display syntax error
	call	print
	jp	.eof50		;check for more files to load


zfnf:	ld	de,mfilnf	;display file not found
	call	print
	jp	.eof50


zmem:	ld	de,mmem??	;display out of memory message
	call	print
	call	crlf
	ld	hl,maxlen
	ld	l,(hl)
	ld	h,00
	add	hl,bc
	ld	(ntpa),hl
	jp	load


zoff:	ld	de,minvof	;display invalid offset using 0000 message
	call	print
	ld	hl,00
	jp	zsym10


fstrng:
	push	bc
	push	de
fstr00:
	ld	de,(pstrng)	;address of canned string pointer
	ld	a,(de)		;length
	ld	b,a
	inc	de
fstr10:	call	nchr		;get char
	cp	eof
	jp	z,fstr20
	ex	de,hl		;DE - buffer ptr  HL - "symbols:" string ptr
	cp	(hl)
	ex	de,hl
	jp	nz,fstr00	;mismatch read more from file
	inc	de
	djnz	fstr10		;check entire string length
fstr20:	pop	de
	pop	bc
	ret

.lst??:	defb	.lstsz		;string length
	defb	'Symbol Table:'
	defb	cr,lf,cr,lf
.lstsz	equ	$ - .lst?? - 1


.prn??:	defb	.prnsz		;string length
	defb	'Symbols:'	;string to search for in M80's .PRN files
				;indicating start of symbol table
	defb	cr,lf
.prnsz	equ	$ - .prn?? - 1

.slr??:	defb	.slrsz
	defb	'Symbols Detected.'
	defb	cr,lf
.slrsz	equ	$ - .slr?? - 1

.m80??:	defb	.m80sz
	defb	'MACRO-80'
.m80sz	equ	$ - .m80?? - 1

tsym:
tsymhi:	defb	0
tsymlo:	defb	0

usymbl:	defw	0

pstrng:	defw	0

relchr:	defb	0

.idprn:	defb	0

star:	defb	0

nsym:
nsymhi:	defb	0
nsymlo:	defb	0
mhex:	defb	'    '
	defb	'$'

msym..:	defb	'Number of Symbols Loaded: $'

tsym..:	defb	cr,lf
	defb	'Total Symbols:   $'

msymnf:	defb	'Symbol Table Not Found'
	defb	cr,lf,0

minvof:	defb	'Invalid Offset - Using 0000'
	defb	cr,lf,0

msymld:	defb	cr,lf
	defb	'Symbol Table:    '
	defb	0

mz8eld:	defb	cr,lf
	if	h64180
	  defb	'18E'
	else
	  defb	'Z8E'
	endif
	defb	' Relocated:   '
	defb	0

mnvmem:	defb	cr,lf
	defb	'Top of Memory:   '
	defb	00

z8eb:	defb	00
z8ebh:	defb	00
ntpa:	defw	00

bytes:	defb	00

zbuf:	defb	00
zbufnm:	defb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
znmbuf:
; 	rept	18
	defw	0,0
	defw	0,0
	defw	0,0
	defw	0,0
	defw	0,0
	defw	0,0
	defw	0,0
	defw	0,0
	defw	0,0
	defw	0,0
	defw	0,0
	defw	0,0
	defw	0,0
	defw	0,0
	defw	0,0
	defw	0,0
	defw	0,0
	defw	0,0
; 	endm
    if	ASMB
init:
    else
init::
    endif
	ret
	defs	255

	page
;******************************************************************************
;*
;*	z8e:	Entry point to monitor
;*
;*		Each command begins with the output of the '*' prompt.
;*		Command character is validated by checking the cmd table.
;*
;*		Relative position of command letter in cmd table also used
;*		as index into command jump table jtcmd.
;*
;*		All commands entered with b = 0.
;*
;******************************************************************************


	org	($+255) and 0ff00h
;was	org	256*(($+255)/256)

z8eorg:
				;Note: first three bytes here become a jump to
	defs	16		;      BDOS after we are loaded
				;
				;This is the internal symbol table

z8e:	and	a		;Any do-nothing instruction with the sign
				;bit set to indicate end of internal symbol
				;table

	defb	31h		;LD SP,nnnn - Load monitor stack pointer
z8esp:	defw	8000h		;Actual address filled in by nint at load
				;time when we figure out where bdos is

z8ecmd:	ld	hl,z8e
	push	hl
	ld	de,prompt	;display prompt (asterisk)
	call	nprint
	ld	hl,jstepf	;full screen debugging in effect?
	ld	a,(hl)
	and	a
	jr	nz,z8e10	;nz - no

	ld	c,10
	call	spaces		;If this was jdbg clear command line residue
	ld	b,10
z8e00:	call	bksp
	djnz	z8e00

z8e10:	call	inchar		;Read in command character

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
	cp	'J'		;If command is anything but J then indicate
				;that screen is corrupted.  At next invokation
				;jdbg will know to repaint the screen.
	jr	z,z8e20
	ld	(jstepf),a	;Full screen flag nz - full screen debugging
				;in progress


z8e20:	ld	bc,ncmd		;total number of commands
	ld	hl,cmd		;table of ascii command characters
	cpir
	jp	nz,e???		;command letter not found in table
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

	page
;******************************************************************************
;*
;*	bphn:	Breakpoint handler - rst38s land here
;*
;*		bphn   - bphn00	  save all user registers
;*		bphn10 - bphn20	  check that user pc matches entry in brktbl.
;*		bphn80		  special single step processing.
;*
;*	Note:	Sbps is both a flag and the count of the number of step bps.
;*		Sbps is set to 1 merely to indicate that the single-stepping
;*		is in effect.  Then the number of step bps is added to one.
;*		Hence, if 1 step bp was set then  sbps = 2 and if 2 step bps
;*		were set (conditional jump, call, ret) sbps = 3.
;*
;******************************************************************************

bphn:	ld	(hlreg),hl	;save user hl
	pop	hl		;pop breakpoint pc from stack
	ld	(spreg),sp	;save user sp
	ld	sp,(z8esp)	;switch to our stack
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
	ex	af,af'		;Bank In Prime Regs
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
	and	a		;check for zero bp count
	jp	z,bp???		;error - no bps set
	ld	b,a		;b - number of breakpoints
	ld	hl,brktbl	;breakpoint storage table
	xor	a
	ld	c,a		;init breakpoint found flag
bphn10:	ld	e,(hl)
	inc	hl
	ld	d,(hl)		;de - breakpoint address
	inc	hl
	ld	a,(hl)		;saved contents of breakpoint address
	inc	hl
	ld	(de),a		;replace rst 38 with actual data
	ld	a,(pcregl)	;user pc - lo order
	xor	e
	ld	e,a		;versus breakpoint address in table
	ld	a,(pcregh)
	xor	d		;check hi order
	or	e
	jr	nz,bphn20	;no match - check next entry in table
	ld	c,b		;pc found in table set c reg nz
bphn20:	djnz	bphn10		;restore all user data
	ld	hl,sbps		;fetch number of step bps (0-2)
	ld	b,(hl)
	xor	a
	ld	(hl),a		;clear regardless
	or	c		;test bp found flag
	jp	z,bp???		;z - bp not in table
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

				;now we know we have jdbg in progress.  Need
				;to check for user specified bp at the same
				;address. If we find one stop trace.
	ld	a,b		;number of step bps to accumulator (1 or 2).

	sub	c		;compare number of step bps with the offset
				;into the bp table where the current bp was
				;found.  Since step bps are always at the end
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
	or	e		;did it just go zero?
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
	jp	z,z8e		;count expired - prompt for command
	call	ttyq		;test for abort trace
	cp	cr
	jp	z,z8e
	call	crlf		;
	jp	step40		;continue trace


bp???:	ld	de,bpemsg
	call	print
	ld	hl,(pcreg)
	call	outadr
	jp	z8e


e???:	ex	de,hl
	ld	de,em???
	call	print
	ex	de,hl
	ret

	 if	auxprt
	page
;****************************************************************************
;*
;*	TERM:	Debug terminal select routine
;*
;*		TERM allows the user to transfer control of the 18E debugger
;*		to either the "main" or the "auxiliary" terminal.
;*
;*		The "main" terminal is accessed by MTTYQ, MTTYI, MTTYO and
;*		MXYPRG and is configured by modifying MXYSTR, MROWB4, MROW
;*		and MCOL.
;*
;*		The "auxiliary" terminal is accessed by ATTYQ, ATTYI, ATTYO
;*		and AXYPRG and is configured by modifying AXYSTR, AROWB4,
;*		AROW and ACOL.
;*
;*		The user types:
;*
;*		    *T   A	to enable the "auxiliary" terminal or:
;*
;*		    *T   M	to enable the "main" terminal.
;*
;*		This mechanism allows for much easier debugging of an
;*		application program which itself performs console I/O.
;*
;*	OUTPUT:	AUXON	set to YES if user selects "auxiliary" terminal;
;*			set to NO if user selects "main" terminal;
;*			unchanged if user types something besides A or M
;*
;****************************************************************************

term:	ld	bc,200h		; Get user's request.
	call	iedt

	cp	CR		; Did user type a CR?
	jr	nz,e???		; If not, error.

	ld	a,(hl)		; Else, get 1st character.
	call	ixlt		; Convert it to upper case.

	cp	'M'		; Does user want to use main terminal?
	jr	nz,term10	; If not, check for auxiliary.

	ld	de,mterm	; Acknowledge control transfer to main.
	call	print
	ld	de,matail
	call	print
	ld	a,no		; Transfer control of 18E to main.
	ld	(auxon),a
	ret			; Done.

term10:	cp	'A'		; Does user want to use auxiliary terminal?
	jr	nz,e???		; If not, error.

	ld	de,axterm	; Acknowledge control transfer to auxiliary.
	call	print
	ld	a,yes		; Transfer control of 18E to auxiliary.
	ld	(auxon),a
	ret			; Done.
	 endif

	page
;******************************************************************************
;*
;*	jdbg:	Animated debugger
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

jdbg00:	ld	hl,lastro
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
	ex	de,hl		;de - save input buffer address
	ld	hl,wflag	;wflag tells us whether to trace subroutines
				;or walk around them
	ld	(hl),0ffh	;conditionally assume trace all
	sub	'/'		;slash means don't trace any
	jr	z,jdbg03	;
	add	a,'/'-'*'	;check for star - no trace of bdos subs
	jr	nz,jdbg05
	inc	a		;set flag one to indicate no trace of subs
				;at address < 100h (bdos calls)
jdbg03:	ld	(hl),a		;set wflag
	xor	a		;if slash or space replace with null in inbf
				;so parser will ignore
	ld	(de),a
jdbg05:	call	iarg		;now evaluate address
	jr	z,jdbg08	;z - no error
	ld	a,(inbfnc)	;check number of characters
	dec	a		;check for just / or just *
	jr	z,jdbg00	;treat as single step
	ld	(jstepf),a	;indicate screen corrupted
	jp	e???		;error -
jdbg08:	ld	(pcreg),hl	;save address at which to start tracing
	and	a		;check delimter
	ld	a,10		;no delimeter use default timer value
	jr	z,jdbg10
	call	iarg		;check if user wants non-default timer
	ld	a,10
	jr	nz,jdbg10	;error - use default
	ld	a,l		;a - timer value as entered by user
jdbg10:	ld	(timer),a
	ld	b,24		;xmit crlf's to clear screen
jdbg15:	call	crlf		;clear screen
	djnz	jdbg15
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
;	ld	a,4		;col position of reg pair is (rel pos * 9) + 3
;	and	b
;	jr	z,jdbg42
;	ld	a,3
;	and	b		;- 9 bytes deleted here
;	inc	a
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

;	add	a,3		;- deleted another 5 bytes here
;	call	curs		;- nett cost = 14 bytes for new code
;				;- but we save 19 bytes in 'curs:' routine

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
	call	space1
	ld	b,1
	ld	c,36
	call	xycp

	ld	b,0
	call	pswDsp		;now display flag reg mnemonics

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
	call	zlen00		;compute length of this instruction
	ld	b,0
	ex	de,hl		;hl - address on disassembled instruction
	add	hl,bc		;add length to compute address of next inline
				;instruction for display
	ex	de,hl		;de - restore new istruction pointer
	ld	hl,jlines
	dec	(hl)		;dec screen line count
	jr	nz,jdbg65
	ld	hl,(pcreg)	;pc not on screen - so current pc will be new
				;first pc on screen
	ld	(zasmfl),hl
	ld	bc,0300h	;cursor row 4 - col 1
	call	xycp
	call	zwnw		;instruction not on screen so paint a new
				;screen starting at current pc
	ld	a,3		;disassembled instructions start on line 4
	jr	jdbg75
jdbg70:	ld	a,(jlines)
	neg
	add	a,21		;a - screen row on which to position cursor
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
	call	pswDsp		;display flag reg
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

	page
;******************************************************************************
;*
;*	exam:	Examine memory and display in hex and ascii.  User is allowed
;*		to modify memory after every byte is displayed. Ilin called
;*		to parse input buffer into a single string of bytes which is
;*		returned in argbuf.  The byte count of the string is returned
;*		in argbc, and this number of bytes is transferred to the
;*		current memory address.
;*
;*		User may optionally scan memory by entering cr.  Command
;*		terminates when a single space is entered.
;*
;*		Enter:	B - 0
;*		       DE - address at which to display first byte
;*
;******************************************************************************

exam:	call	ilin
	jp	nz,e???
	ex	de,hl
exam00:	call	newlin
	ld	a,(de)		;fetch byte to display regardless
	call	outbyt
	call	dbyte
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

	page
;------------------------------------------------------------------------------
;
;	hsym:	Display symbol table
;
;	User may display the symbol table on the console.  If no arg
;	entered on command line then the entire table is dumped start-
;	ing with the first symbol.  If a valid symbol is entered then
;	we will try to find the symbol in the table; if found, the
;	table is dumped starting at that point.  If the symbol is not
;	found the user gets a ? and the command terminates.
;
;	Symbols are displayed in blocks of 32.  After each block the
;	user is given the opportunity of continuing or ending the
;	command:
;
;		cr - Terminate			\  jrs 27 Dec 88
;	    not cr - Display next block		/  v 3.5.1
;
;------------------------------------------------------------------------------

hsym:	call	ilin		;Read in line of data
	ld	hl,z8e		;Assume no symbol entered
	jr	nz,hsym10	;NZ - no input means display entire table
	ld	de,prsbf
	call	fsym		;Attempt to find this symbol name in table
	jp	nz,e???		;Error - symbol not found in symbol table
	ld	a,(maxlen)
	or	l		;Point to next symbol table entry (next block)
	ld	l,a		;HL - ptr to last byte in this entry
	inc	hl		;Now next entry toward hi memory
hsym10:	ld	a,(maxlen)	;Max size of symbol name
	ld	c,a
	dec	c
	inc	a		;Make 8 or 16
	ld	e,a
	xor	a
	ld	d,a		;DE - size of symbol table entry
	sbc	hl,de		;Previous entry toward low memory
	ld	a,(hl)		;Null means this is unused slot is user
				;defined symbol table
	and	a
	jr	z,hsym10
	dec	a		;Neg means this is jp opcode (0c3h) of jump to
				;BDOS
	ret	m
	ld	a,(maxlen)
	srl	a
	srl	a
	xor	2
	and	b		;Check symbols per line count
	call	z,crlf		;crlf every fourth
	dec	b		;Now decrement symbols per line count
	call	printb		;Treat symbol table entry as a buffer and
				;Six chars or until null, whichever is first
	inc	c		;Tack on two spaces
	inc	c
	call	spaces
	ld	a,(maxlen)
	or	l		;Point to last byte in symbol table block
	ld	l,a
	ld	d,(hl)		;Upper byte of symbol address
	dec	hl
	ld	e,(hl)		;Low order
	ex	de,hl
	call	outadr		;HL - symbol address to display
	ld	c,4
	call	spaces		;Next symbol name starts 4 spaces to the right
	ex	de,hl		;HL - symbol table pointer
	ld	a,(maxlen)
	cpl
	and	l		;Rewind to point to byte zero of entry
	ld	l,a
	ld	a,b
	and	31		;Displayed block of 32 symbols?
	jr	nz,hsym10
	call	crlf
	call	ttyi		;Test if user wants abort
	cp	cr
	jr	nz,hsym10	;Not CR - continue (jrs v3.5.1)
	ret			;CR - end command

	page
;*****************************************************************************
;*
;*	usym:   write symbol table to disk
;*
;*****************************************************************************

usym:	call	iedtbc		;get a command line
	ret	m		;no input ends command
	call	bldf		;build fcb
	jp	nz,esntx	;syntax error
	ld	hl,z8e		;start at beginning
	ld	a,(symflg)	;do we even have a symbol table?
	and	a
	ret	nz		;no table - end command
	ld	b,128		;disk write buffer size
	ld	(lines),a	;clear symbols per line counter
	ld	de,symbuf
usym10:	ld	a,(maxlen)
	ld	c,a		;max size of symbol name
	cpl
	and	l		;rewind to byte zero of symbol table entry
	ld	l,a
	ld	a,b		;temp save buffer count
	ld	b,0
	sbc	hl,bc
	dec	hl		;point to 8 or 16 byte boundary
	ld	b,a		;restore buffer count

	ld	a,(hl)		;null means this is unused slot in user
				;defined symbol table
	and	a
	jr	z,usym10
	dec	a		;neg means this is jp opcode (0c3h) of jump to
				;bdos
	jp	p,usym20
	call	pcrlf		;hit end of table - put crlf in buffer
	ld	a,eof
	ld	b,1		;force buffer write
	call	putc		;put eof in file
	jp	closef		;this is a wrap

usym20:	ld	a,(maxlen)
	or	l
	ld	l,a		;point to hi order byte of symbol address
	call	pbin		;put address in buffer
	ld	a,' '
	call	putc		;followed by space just like l80
	ld	a,(maxlen)
	cpl
	and	l		;rewind to byte zero of symbol entry
	ld	l,a

	dec	c		;14 Sep 85   restore maxlen size as count

usym25:	ld	a,(hl)		;fetch char of symbol name
	and	a		;null?
	jr	z,usym40	;name is less than 6 chars long
	call	putc		;put valid symbol name chars in buffer
	dec	c
	jr	z,usym40	;z - just moved last char
	inc	hl
	jr	usym25
usym40:	ld	a,tab		;tab separates name and next address
	call	putc		;insert tab before address field
	ld	a,(lines)
	dec	a
	ld	(lines),a
	and	3		;insert crlf every fourth symbol
	jr	nz,usym10
	call	pcrlf
	jr	usym10



pcrlf:	ld	a,cr
	call	putc
	ld	a,lf
	jr	putc


				;convert two byte binary address to ascii
				;and put into buffer
pbin:	call	pbin00
	dec	hl
pbin00:	ld	a,(hl)
	call	binx
	call	putc
	ld	a,(hl)
	call	binx00


putc:	ld	(de),a		;just like pascal - put char into buffer
	inc	de
	dec	b		;buffer count passed in b
	ret	nz
putc00:	ld	de,symbuf	;hit end of buffer - reinit pointer to start
	call	bwrite		;write current buffer [ras 14 sep 85]
	ld	b,128		;reinit tally
	ret

	page
;------------------------------------------------------------------------------
;
;	dump:  Dump memory in hex and ASCII
;
;	Memory is dumped in hex and ASCII in user-specified block size.
;	If the D command is given without arguments then memory is dumped
;	beginning at the address where we left off as store in blkptr.
;	User is queried after each block is dumped:
;
;		cr - End command			\  v 3.5.1
;	    Not	cr - Dump next consecutive block	/  jrs 27 Dec 88
;
;------------------------------------------------------------------------------

dump:	call	iedtbc		;Solicit input
	jp	p,dump00	;p - input present
	ld	de,(bsiz)	;No input means use previous block size
	ld	hl,(blkptr)	;   ... and address
	jr	dump30
dump00:	call	iarg		;Read in next arg (starting address)
	jp	nz,e???		;Invalid starting address
	ex	de,hl		;DE - starting address to dump
	call	iarg		;Next arg (block size)
	jr	z,dump15	;Z - no errors
	ld	hl,000		;Default to block size of 256
	jr	dump20
dump15:	xor	a
	or	h		;Test for block size or ending address
	jr	z,dump20	;Less than 256 must be block size
	sbc	hl,de		;Compute size
	jp	c,e???
dump20:	ld	a,l
	or	h
	jr	nz,dump25
	inc	h
dump25:	ld	(bsiz),hl
	ex	de,hl		;DE - block size   HL - memory pointer
dump30:	ld	b,16		;Init bytes-per-line count
	call	ttyq
	cp	cr
	ret	z
	call	crlf		;Display current address on new line
	call	outadr
	ld	c,2
	call	spaces		;Hex display starts two spaces right
dump40:	dec	b		;Decrement column count
	ld	a,(hl)
	inc	hl
	call	othxsp		;Display memory in hex
	inc	c		;Tally of hex bytes displayed
	dec	de		;Decrement block count
	ld	a,d
	or	e		;Test for end of block
	jr	z,dump50	;Z - end of block
	xor	a
	or	b		;End of line?
	jr	nz,dump40	;Not end of line - dump more in hex
	jr	dump60
dump50:	ld	a,(bsizhi)
	and	a		;Block size greater than 256?
	jr	nz,dump55	;NZ - greater
	ld	a,(bsizlo)
	and	0f0h		;Block size less than 16?
	jr	z,dump60	;Z - less
dump55:	ld	a,(bsizlo)
	and	0fh		;Block size multiple of 16?
	jr	z,dump60	;Multiple of 16
	neg
	add	a,16
	ld	b,a
	add	a,a
	add	a,b
dump60:	add	a,3		;Plus three - begin ASCII display
	ld	b,a		;Pad line until ASCII display area
dump70:	call	space1
	djnz	dump70
	sbc	hl,bc		;Rewind memory point by like amount
dump80:	ld	a,(hl)		;Start ASCII display
	inc	hl
	call	asci
	dec	c
	jr	nz,dump80
	call	ttyq		;CR aborts command
	cp	cr
	jp	z,z8e
	ld	a,d		;Test for block size tally expired
	or	e
	jr	nz,dump30
	ld	de,(bsiz)	;Reinit block size
	call	ttyi		;Query user for more
	cp	cr
; Next two lines replaced by inverted test - 27 Dec 88 - jrs - V 3.5.1
;	call	z,crlf
;	jr	z,dump30	;not cr - next block
;----				(Comment on last line is wrong anyway!)
	call	nz,crlf		;Not cr - next block
	jr	nz,dump30
;----
	ld	(blkptr),hl
	ret			;end command

	page
;******************************************************************************
;*
;*	rgst:  Display and optionally modify individual registers
;*
;*	call iedt:   read edited input into inbf
;*	call prsr:   parse input
;*	call mreg:   validate register name and map into reg storage
;*	call iarg:   query user for replacement
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
rgst00:	ld	a,(inbfnc)	;number of characters in buffer
	cp	4
	jr	nc,rgst25	;error - too many chars
	neg
	add	a,4		;calculate space padding
	ld	c,a
	cp	3		;was it one?
	jr	nz,rgst10
	ld	a,(de)
	call	ixlt
	cp	'P'
	jr	nz,rgst10
	ld	(inbfnc),a	;any number > 2 indicates 16 bit register
rgst10:	call	spaces
	ld	a,(hl)		;check last char in parse buffer
	sub	quote
	jr	nz,rgst15	;not quote
	ld	(hl),a		;replace with null
rgst15:	call	mreg		;validate register name
	jr	nz,rgst25	;error
	ld	a,(regtrm)	;mreg stored char following reg name
	and	a
	jr	nz,rgst25	;error - no operators allowed
	ld	a,(inbfnc)	;now check number of chars in buffer
	ld	b,a		;save in b reg for 8 or 16 bit reg test
	dec	a		;test for one - 8 bit reg
	ld	c,3
	jr	z,rgst20
	ld	a,(hl)
	call	outhex		;display byte of reg contents
	dec	hl
	ld	c,1
rgst20:	ld	a,(hl)
	call	othxsp
	call	spaces		;reg c - number of spaces to print
	ex	de,hl		;de - save reg contents pointer
rgst22:	call	istr		;query user for reg value replacement
	ld	a,(inbfnc)	;test number of chars in input buffer
	dec	a		;
	jp	m,rgst40	;none - prompt for next reg name
	call	irsm
	jr	z,rgst30
	ld	a,(inbfnc)
	and	a
	jr	z,rgst22
rgst25:	call	e???
	jr	rgst40		;accept new reg name
rgst30:	ex	de,hl
	ld	(hl),e
	dec	b		;test for 16 bit reg
	jr	z,rgst40	;z - 8 bit reg
	inc	hl
	ld	(hl),d		;save upper byte of user input
rgst40:	call	crlf
	call	space5
	jp	rgst



mreg:	ld	c,23		;number of reserved operands
	call	oprn00		;check validity of register name
	ld	a,(de)		;last char examined by operand routine
	call	oprtor
	ret	nz		;error - not null or valid operator
	ld	(regtrm),a	;save terminator character for rgst
	ld	a,c
	cp	17		;valid reg names are less than 17
	jr	c,mreg00	;so far so good
	sub	23		;last chance - may be pc
	ret	nz		;error - invalid reg name
	ld	a,10		;make pc look like p for mapping
mreg00:	ld	hl,regmap	;ptrs to register contents storage
	add	a,l		;index into table by operand value
	ld	l,a
	jr	nc,mreg05
	inc	h
mreg05:	ld	a,b		;b reg set m by prsr if trailing quote
	and	a
	ld	a,0		;assume no quote - not prime reg
	jp	p,mreg10	;p - correct assumption
	ld	a,8		;bias pointer for prime reg contents
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

	page
;******************************************************************************
;*
;*	qprt:	Read and display / write to i/o ports
;*
;*		Contents of ports are displayed and the user is queried
;*		input character effects the current port address:
;*
;*		space -	display next sequential port on same line
;*		lf    -	display next sequential port on new line
;*		cr    -	end command
;*		slash -	display same port on same line
;*		^     -	display previous port on new line
;*
;*		Any other input is treated as a replacement byte and
;*		is output to the current port address.  Any of the
;*		above characters may be used to continue the display.
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
	jp	nz,e???
	ex	de,hl 		;e - new port number
	ld	(hl),e
	ld	a,(parenf)
	cp	'('
	jr	nz,qprt30
	ld	c,2
	call	spaces

; Enter continuous monitor mode

qprt00:	ld	c,e

	if	h64180
	ld	b,0
	endif

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

; Non-continuous monitor mode

qprt30:	call	crlf
	ld	a,e
	ld	(port),a
	call	othxsp		;output port address
	call	space1
	ld	c,e
	ld	a,(lcmd)	;are we running N command?
	cp	'N'
	jr	z,qprt50	;if so, skip port reading

	if	h64180
	ld	b,0
	endif

       	in	a,(c)		;read byte from port

	call	outbyt		;output the byte in hex and ascii
qprt50:	call	dbyte		;get and process argument string
	ld	a,(trmntr)
	jr	nz,qprt60	;if no replacement data, skip port update
	cp	'.'		;else, user wants to exit?
	ret	z		;return if so

	if	h64180
	ld	hl,argbc	;get byte count into d.
	ld	d,(hl)
	ld	hl,argbf	;point hl to byte buffer.
	ld	c,e		;point c to port.
qprt55:	ld	b,0		;clear upper address byte of port.
	outi			;output (hl) to port (bc) and increment hl.
	dec	d		;decrement byte count
	jr	nz,qprt55	;if not done, do next byte.
	else
	ld	hl,argbc
	ld	b,(hl)
	ld	hl,argbf
	ld	c,e		;port number
	otir
	endif

	jr	qprt30
qprt60:	cp	' '
	jr	nz,qprt30
	dec	de
	jr	qprt30

	page
;******************************************************************************
;*
;*	break:	Set breakpoint routine
;*
;*	Breakpoint address storage table (brktbl) is examined and user
;*	specified breakpoint is considered valid unless:
;*
;*		     - table full
;*		     - address already exists in table
;*
;*	Optional pass counts can be specified by the user immediatley following
;*	the breakpoint if they are enclosed in parens.
;*
;*	Entry point brk30:
;*	      Entered from single step command to set breakpoint.  Two table
;*	      slots are permanently available for step breakpoints. STEP
;*	      routine calls with C pos to tell us not to look for more args
;*	      in the input buffer.
;*
;******************************************************************************

break:	call	iedtbc
	ret	m		;end command - no input
	ld	c,0ffh		;set neg - distinguish ourselves from step
brk10:	ld	a,(bps)		;fetch current bp count
	cp	maxbp		;table full
	jp	nc,e???		;full - abort command
	ld	b,a		;save current count
	call	iarg
	jp	nz,e???
	ex	de,hl		;de - breakpoint address to set
brk30:	ld	hl,brktbl
	xor	a
	or	b		;check for no breakpoints in effect
	jr	z,brk60		;none - bypass check for duplicate
brk40:	ld	a,e
	cp	(hl)		;check lo order address match
	inc	hl
	jr	nz,brk50	;no match - check next
	ld	a,d
	sub	(hl)		;check hi order
	jr	nz,brk50	;no match - check next
	or	c
	ret	p
	ld	hl,bps		;pointer to bp count
	ld	a,(hl)
	sub	b		;create index into psctbl
	jr	brk70
brk50:	inc	hl
	inc	hl		;bump past contents storage byte
	djnz	brk40
brk60:	ld	(hl),e		;set in table
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
	ld	(de),a		;pre-clear pass count table entry
	inc	de
	ld	(de),a
	or	c		;test if this was step calling
	ret	p		;i'm positive it was
	ld	a,(delim)	;check delimeter which followed bp address
	and	a
	ret	z		;end of line null - terminate command
	cp	','		;check for pass count delimeter
	jp	nz,brk10	;not comma means treat this as new bp
	call	iarg		;get next arg
	jp	nz,e???		;nz - evaluation error
	ex	de,hl		;de - pass count as entered by user
	ld	(hl),d		;store pass count in table
	dec	hl
	ld	(hl),e
	and	a		;check delimeter
	jp	nz,brk10	;nz - more arguments follow
	ret			;end of line null - terminate command
	page

;******************************************************************************
;*
;*	cbreak:	Clear breakpoint
;*
;*	Breakpoint address storage table (brktbl) is examined and breakpoint
;*	is removed if found. Breakpoint is removed by bubbling up all bp
;*	addresses which follow, ditto for pass counts.
;*
;******************************************************************************

cbreak:	call	iedtbc
	ret	m		;no input ends command
	ld	a,(bps)		;fetch breakpoint count
	or	a		;any if effect
	ret	z		;no
	ld	b,a		;temp save count
	call	iarg		;extract address to clear from input buffer
	ld	de,brktbl	;bp address storage table
	jr	z,cbrk10
	ld	a,(prsbf)
	cp	'*'
	jp	nz,e???
	ld	a,(inbfnc)
	dec	a
	jp	nz,e???
	ld	(bps),a
	ret

cbrk10:	ld	a,(de)		;test lo order address for match
	cp	l
	inc	de
	jr	nz,cbrk20	;no match - examine next entry
	ld	a,(de)
	cp	h		;versus hi order bp address
cbrk20:	inc	de
	inc	de		;bump past contents save location
	jr	z,cbrk30	;zero - found bp in table
	djnz	cbrk10
	jp	e???		;error - breakpoint not found
cbrk30:	ld	h,0ffh		;rewind to point to bp address
	ld	l,-3
	add	hl,de
	ex	de,hl		;de - ptr to bp   hl - ptr to next bp
	ld	a,b		;multiply number of bps remaining in table
				;times three bytes per entry
	add	a,a
	add	a,b
	ld	c,a		;init c for ldir
	ld	a,b		;save number of bps remaining
	ld	b,0
	ldir			;bubble up all remaining entries in table
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
	add	hl,de		;de - ptr to pass count  hl - next in table
	sla	c		;number of pass counts to move
	ldir
	ld	a,(delim)	;recheck delimeter
	and	a
	jr	nz,cbreak	;not end of line terminator - clear more
	ret

	page
;***********************************************************************
;*
;*     obreak:	Output all breakpoints and associated pass counts to
;*		console.  Search symbol table for match, if symbol name
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
	ld	e,b		;use current breakpoint count as index
	ld	d,0		;clear
	add	hl,de		;this is a three byte table
	add	hl,de
	add	hl,de
	ld	e,(hl)		;fetch lo order bp address
	inc	hl
	ld	d,(hl)		;upper address
	ex	de,hl
	call	outadr		;display address
	ex	de,hl		;hl - breakpoint table
	call	fadr		;check symbol table for name match
				;   symbol table pointer returned in de
				;   zero flag set if found
	ld	a,(maxlen)
	ld	c,a
	dec	bc		;max number of chars in a symbol name
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
	jr	z,obrk20	;z - no pass count for this bp
	inc	c
	call	spaces
	ex	de,hl
	call	outadr		;display pass count in hex
obrk20:	call	crlf
	ld	c,5
	call	spaces
	dec	b		;dec bp count
	jp	p,obrk00
	ret



kdmp:	call	iedtbc		;let user input address of memory to display
	ret	m		;no input ends command
	call	iarg		;evaluate user arg
	jp	nz,e???
	ex	de,hl		;de - save memory address
	call	iarg		;now get count
	ld	a,0
	jr	nz,kdmp20	;error during input - display 00 bytes
	or	h
	jp	nz,e???		;greater than 256 is error
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

	page
;**************************************************************************
;*
;*		     Begin/resume execution of user program
;*
;*	Address entered:     execution begins at entered address
;*	No address entered:  execution resumed at specified by saved pc
;*
;*	Breakpoint table examined:
;*	      -	memory contents from each address is removed from user
;*		program and saved in breakpoint table
;*	      -	rst 38 instruction is placed at each breakpoint address
;*		in user program
;*
;*	user registers restored
;*
;***************************************************************************

go:	call	iedtbc		;query user for execution address

;	ret	m		;- eg 3.3.3 no input - reprompt
	jp	p,g001		;+ Skip if argument supplied, else:
	ld	hl,(pcreg)	;+ Use current PC
	jr	g002		;+
g001:				;+
	call	iarg
	jp	nz,e???		;error - invalid argument
g002:				;+
	call	crlf
	call	crlf
g100:	ld	(jmplo),hl	;store execution address
	ld	a,zjp
	ld	(zjmp),a	;set jp instruction
	ld	(jmp2jp),a	;just in case
	ld	a,(bps)		;check breakpoint count
	and	a
	jp	z,g600		;z - no bps in effect - no restoration needed
	ld	b,a
	ld	hl,brktbl
	ld	c,0ffh
g300:	ld	e,(hl)
	inc	hl
	ld	d,(hl)		;de - breakpoint address removed from table
	inc	hl		;point to contents save byte in table
	ld	a,(de)
	ld	(hl),a
	ld	a,(jmplo)
	cp	e		;check if bp from table matches next pc
	jr	nz,g400		;no match - set breakpoint
	ld	a,(jmphi)
	cp	d		;check hi order next pc address
	jr	nz,g400		;no match - set bp
	ld	c,b		;set flag - current pc matches breakpoint
	jr	g500
g400:	ld	a,rst38		;set rst38 instruction
	ld	(de),a		;save user byte in brktbl
g500:	inc	hl
	djnz	g300		;examine all entries
	inc	c		;current pc match breakpoint?
	jp	z,g600		;z - no (c reg not 0ffh)
	ld	a,(sbps)	;check number of step breakpoints
	and	a		;tracing?
	jp	nz,g600		;nz - this is trace

				;PC points to address in breakpoint table
				;next instruction will not be executed where
				;it resides.  It will be moved to our internal
				;buffer (execbf) and executed there. Then we
				;set an rst38 at actual location in user
				;program.  This allows us to debug loops in
				;which only one bp is set.  Otherwise we would
				;not be able to set a bp at the address where
				;the PC points and debugging loops would be
				;impossible.
	ld	hl,execbf
	ld	de,(jmplo)	;de - pointer to next instruction to execute
	ld	(jmplo),hl	;execute buffer
	ld	b,4		;clear execute buffer
g505:	ld	(hl),znop
	inc	hl
	djnz	g505
	call	zlen00		;calculate length
				;if instruction modifies PC then zlen lets us
				;know by setting B reg nz and C contains
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
	ld	a,(hl)		;first object byte from user program
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
				;instruction.  If user instruction was shorter
				;than four bytes the nops remain and are
				;executed until the jump back to the user
				;program at jmp2jp is reached.


	ld	(jmp2),hl	;address of next inline instruction within
				;user code

	ex	de,hl		;de - next inline instruction in user program
	xor	a
	or	b
	jr	z,g600		;z - the instruction in execbf is not a PC
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
				;the Z80 will store the address pc+3 on the
				;stack.  In this case we do not want the
				;address execbf+3 on the stack.  We want the
				;address of the actual location of the user
				;instruction+3 on the stack.  We must do this
				;by simulating a call instruction. We use the
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
				;an absolute equivalent.  This is because
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
	ld	r,a		;restore user r reg
	ld	a,(ireg)
	ld	i,a		;restore user i reg
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
	jp	zjmp

	page
;******************************************************************************
;*
;*	step:  Single step (trace) routine
;*
;*	Call zlen to determine where to set breakpoint.
;*
;*		pass:	   de -	current PC address
;*
;*		returned:  b:  z - next instruction will not modify PC.
;*				   Set bp at address specified by PC+length.
;*
;*			   b: nz - next instruction will modify PC (jumps,
;*				   calls, and returns) thus set bp at address
;*				   returned in HL.
;*
;*			   c:	 - number of bytes in current instruction.
;*
;*		Zlen handles secondary breakpoint to set for all conditional
;*		call, return, and jump instructions.
;*
;*	Call brk00 to set breakpoint.
;*
;*		pass:	   b - current number of breakpoints.
;*			  hl - address at which to set breakpoint.
;*
;*	entry point step:    entered by user via (s)ingle step command.
;*	entry point step40:  entered by breakpoint handler - step count nz
;*
;*	exit:	to go routine to resume execution.
;*
;******************************************************************************

step:	ld	a,0ffh
	ld	(wflag),a	;set trace subroutine flag on
	call	iedtbc		;query user for trace count
	ld	hl,0001
	jp	m,step40	;null input - step count of one
	call	prsr
	jp	nz,e???
	ld	a,(de)		;first character from parse buffer
	sub	'/'
	ld	(wflag),a	;may be slash - no subroutine tracing
	ld	hl,00
	jr	nz,step20
	ld	(de),a
	ld	a,(inbfnc)
	dec	a
	inc	hl
	jr	z,step40
	dec	hl
step20:	call	xval		;evaluate contents of parse buffer
	jp	nz,e???
	ld	de,(pcreg)
	ld	a,(de)		;first byte of op code at current pc
	cp	0c7h		;test for rst
	jp	z,e???		;no tracing of rsts
step40:	ld	(nstep),hl	;save step count
	ld	hl,sbps		;set step flag nz - trace in effect
	inc	(hl)
	ld	de,(pcreg)	;fetch current pc
	call	zlen00		;determine number of bytes in instruction
	inc	b		;test where to set breakpoint
	djnz	step50		;nz - set at address in hl
	ex	de,hl
	add	hl,bc		;z - set at address pc + instruction length
step50:	ld	a,(bps)		;get current number of bps
	ld	b,a		;pass to set bp routine in b reg
	ex	de,hl		;de - bp address to set
	call	brk30
	ld	hl,(pcreg)	;resume execution at next pc
	xor	a
	or	b
	jp	nz,g100		;nz - collision with user bp
	ex	de,hl
	ld	hl,sbps		;step bp set by brk30 - bump count
	inc	(hl)
	ex	de,hl
	jp	g100

	page
;******************************************************************************
;*
;*	asmblr:	z80 assembler
;*
;******************************************************************************

asmblr:
	call	ilin
	jp	nz,e???
asm000:	call	crlf
	ld	(zasmpc),hl	;save here as well
	call	zasm08		;disassemble first instruction

asm005:
	ld	hl,(asmbpc)
asm010:	call	crlf
	call	outadr		;display current assembly pc
	ld	c,22		;
	call	spaces		;leave room for object code
	ld	a,3
	ld	hl,objbuf	;zero scratch object code buffer
asm015:	ld	(hl),c
	inc	hl
	dec	a
	jp	p,asm015
	ld	(oprn01),a	;init operand key values to 0ffh
	ld	(oprn02),a
	call	iedtbc		;get user input
	ret	m		;m - no input ends command
	call	cret
	call	prsr		;parse to obtain label
	ld	a,(hl)		;check last character
	cp	':'
	jr	nz,asm040	;no colon found - must be op code
	ld	(hl),0		;erase colon
	ld	a,(de)		;fetch first char of label from parse buffer
	cp	'A'
	jp	c,asm??l	;error - first character must be alpha
	cp	'z'+1
	jp	nc,asm??l	;label error
	cp	'a'
	jr	nc,asm030
	cp	'Z'+1
	jp	nc,asm??l
asm030:	ld	hl,00
	ld	(isympt),hl	;clear pointer
	call	isym		;attempt to insert symbol into symbol table
	jp	nz,asm??t	;error - symbol table full
	ld	(isympt),hl	;save pointer to symbol value in symbol table
	call	prsr		;extract opcode
	jp	m,asm005	;m - statement contains label only
asm040:	ld	a,(delim)	;check delimeter
	cp	','		;check for invalid terminator
	jp	z,asm??o

	if	h64180
	ld	c,83		;number of HD64180 opcode names as index
	else
	ld	c,73		;number of Z80 opcodes in table as index
	endif

asm050:	dec	c
	jp	m,asm??o	;opcode not found
	ld	b,0
	ld	hl,zopcnm	;table of opcode names
	add	hl,bc
	add	hl,bc		;index times four
	add	hl,bc
	add	hl,bc
	ld	de,prsbf	;start of parse buffer
	ld	b,4
asm060:	ld	a,(de)		;character from parse buffer
	and	a		;null?
	jr	nz,asm070
	ld	a,' '		;for comparison purposes
asm070:	call	ixlt		;force upper case for compare
	cp	(hl)
	jr	nz,asm050	;mismatch - next opcode name
	inc	de
	inc	hl
	djnz	asm060		;must match all four
	ld	a,(de)		;null following opcode?
	and	a
	jp	nz,asm??o	;error - opcode more than 4 characaters
	ld	hl,ikey		;relative position in table is key value
	ld	(hl),c		;save opcode key value
	call	prsr		;extract first operand
	jp	m,asm085	;m - none
	call	oprn		;evaluate operand
	jr	nz,asm??u	;error - bad first operand
	ld	de,oprn01
	call	opnv		;save operand value and key
	ld	a,(delim)
	cp	','
	jr	nz,asm085	;need comma for two operands
	call	prsr		;extract second operand
	jp	m,asm??s	;error - comma with no second operand
	cp	','
	jp	z,asm??s	;illegal line termination
	call	oprn		;evaluate operand
	jr	nz,asm??u	;error - bad second operand
	ld	de,oprn02
	call	opnv		;save second operand value and key
asm085:	xor	a
	ld	c,a
asm090:	ld	hl,zopcpt	;opcode name pointer table
	ld	b,0
	add	hl,bc		;index into table
	ld	a,(ikey)	;fetch opcode key value
	cp	(hl)		;check for match
	jr	nz,asm095	;
	inc	h		;point to first operand table
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
asm??u:	ld	a,'U'		;error
	jp	asm???


ibld:	ld	hl,objbuf	;object code temp buffer
	ld	e,a		;save second operand key
	ld	a,(hl)		;check first byte of object buffer
	and	a		;null?
	ld	a,c		;instruction key to accumulator regardless
	ld	c,e		;save second operand modified key
	jr	z,ibld00	;z - not ix or iy instruction
	inc	hl		;point to byte two of object code
ibld00:	cp	40h
	jr	c,ibld55	;c - 8080 instruction
	cp	0a0h
	jr	nc,ibld10	;nc - not ed instruction
	ld	(hl),0edh	;init byte one of object code
	inc	hl

	if	h64180
	call	aed180		;do HD64180 encode of ED 00 to ED BB opcodes.
	jr	ibld55
	else
	cp	80h		;check which ED instruction we have
	jr	c,ibld55	;c - this is exact object byte
	add	a,20h		;add bias to obtain object byte
	jr	ibld55
	endif

ibld10:	cp	0e0h
	jr	nc,ibld20
	add	a,20h		;8080 type - range 0c0h to 0ffh
	jr	ibld55		;object byte built
ibld20:	cp	0e8h
	jr	c,ibld50	;8 bit reg-reg arithmetic or logic
	cp	0f7h		;check for halt disguised as ld (hl),(hl)
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
	or	c		;second operand need more processing?
	ld	de,oprn02
	call	nz,rslv		;resolve second operand
	jp	nz,asm??v	;error - invalid operand size
	ld	de,oprn01
	ld	a,b
	and	a		;first operand resolved?
	call	nz,rslv		;more work to do
	jp	nz,asm??v	;error - invalid operand size
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

	if	h64180
	cp	5		;is ikey remnant > # of directives?
	jr	nc,ibld70	;if so, handle HD64180 instruction.
	endif

	ld	b,a		;number of bytes for defb or defw or ddb
	inc	de		;point past erroneous assembled opcode
	inc	de
	sub	3		;test for ddb
	jr	c,ibld75	;c - must be defb or defw
	dec	a
	jr	nz,ibld65	;nz - must be ddb
	ld	d,(hl)		;must be equ
	dec	hl
	ld	e,(hl)
	ld	hl,(isympt)	;fetch pointer to entry in symbol table
	ld	a,h
	or	l
	jp	z,asm??u	;error - no label on equ statement
	ld	(hl),d
	dec	hl
	ld	(hl),e		;store value of symbol in symbol table
	ld	c,6
	call	spaces
	ld	a,d
	call	othxsp
	ld	a,e
	call	othxsp
	jp	asm005		;ready for next input
ibld65:	dec	b		;set count of object bytes to 2
	ld	c,(hl)		;exchange hi and lo order bytes for ddb
	dec	hl
	ld	a,(hl)
	ld	(hl),c		;new hi order
	inc	hl
	ld	(hl),a		;new hi order replaces old lo order
	jr	ibld75
ibld70:	call	zlen00		;compute length of instruction in bytes
	ld	b,c		;b - number of bytes of object code
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
	add	a,a		;86 all no operand key values (0ffh)
	ret	m
	ld	a,(hl)		;fetch table entry
	and	7fh		;sans paren flag for comparison purposes
	cp	1bh		;check table entry 8 bit - 16 bit - $ rel ?
	jr	c,opnm00	;c - none of the above
	ld	a,(de)		;fetch computed key
	xor	(hl)		;compare with paren flags
	ret	m		;error - paren mismatch
	ld	a,(de)		;fetch key once more
	and	7fh		;remove paren flag
	cp	17h		;computed as 8 bit - 16 bit - $ rel?
	jr	z,opnm40	;so far so good
	ret			;
opnm00:	cp	19h		;check for 8 bit reg
	jr	nc,opnm20	;8 bit register match
	cp	18h		;table says must be hl - ix - iy
	ret	nz		;computed key disagrees
	ld	a,(de)		;fetch computed key
	and	7		;computed as hl - ix - iy ?
	ret	nz		;no
opnm10:	ld	a,(de)		;fetch computed key
	xor	(hl)
	ret	m		;error - paren mismatch on hl - ix - iy
	jr	opnm40
opnm20:	ld	a,(de)		;fetch computed key of 8 bit reg
	and	a		;
	jr	nz,opnm30	;nz - not (hl)
	dec	a		;error - 8 bit (hl) missing parens
	ret
opnm30:	cp	8		;test user entered valid 8 bit reg
	jr	c,opnm40	;c - ok
	and	a		;test if no carry caused by paren flag
	ret	p		;error - this is not 8 bit reg with parens
	and	7		;psuedo 8 bit reg: (hl) (ix) (iy)?
	ret	nz		;no
opnm40:	ld	a,(hl)		;fetch table entry
	and	7fh
	sub	18h		;make values 18 thru 1f relative zero
	cp	a		;zero means match
	ret

rslv:	dec	a
	jr	z,rslv00	;z - 8 bit reg (bits 0-2 of object byte)
	dec	a
	jr	nz,rslv20	;nz - not 8 bit reg (bits 3-5 of object byte)
	dec	a		;make neg to indicate shift left required
rslv00:	ld	c,a
	ld	a,(de)		;fetch computed operand key
	and	07		;lo three bits specify reg
	xor	6		;create true object code bits
	inc	c		;test if bits 0-2 or bits 3-5
	jr	nz,rslv10	;nz - 0 thru 2
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
	ld	l,a		;hl - operand value computed by xval
	ld	a,b
	ld	bc,(asmbpc)	;current location counter
	inc	bc
	inc	bc
	sbc	hl,bc		;calculate displacement from current counter
	ex	de,hl		;de - displacement  hl - object code pointer
	ld	b,a		;restore b reg
	ld	a,e		;lo order displacement
	inc	d		;test hi order
	jr	z,rslv25	;must have been ff (backward displacement)
	dec	d
	ret	nz		;error - hi order not zero or ff
	cpl			;set sign bit for valid forward displacement
rslv25:	xor	80h		;toggle sign bit
	ret	m		;error - sign bit disagrees with upper byte
	ld	(hl),e		;store displacement object byte
	cp	a		;set zero flag - no errors
	ret
rslv30:	dec	a
	jr	nz,rslv40	;nz - not 8 bit immediate
	ld	a,36h		;test for reg indirect - (hl),nn
	cp	c
	jr	nz,rslv35
	ld	a,(objbuf)	;test first object byte
	cp	c
	jr	z,rslv35	;z - (hl),nn
	inc	hl		;must be (ix+index),nn  or  (iy+index),nn
rslv35:	ld	a,(de)		;move lo order operand value to object buffer
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
	ld	a,(de)		;fetch lo order operand value
	or	0c7h		;or with instruction skeleton
	dec	hl
	ld	(hl),a		;rewind object code pointer
	inc	de
	ld	a,(de)		;check hi order operand value
	and	a		;error if not zero
	ret
rslv60:	dec	hl		;rewind object code buffer pointer
	ld	a,(de)
	and	0f8h		;ensure bit number in range 0 - 7
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
oprn00:	ld	de,prsbf	;buffer contains operand
	ld	a,(hl)		;last character of operand in parse buffer
	sub	')'
	jr	nz,oprn20	;not paren
	ld	(hl),a		;remove trailing paren - replace with null
	ld	a,(de)		;check first character of parse buffer
	sub	'('
	ret	nz		;error - unbalanced parens
	ld	(de),a		;remove leading paren - replace with null
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
	cp	(hl)		;versus table entry
	inc	de
	jr	nz,oprn70	;no match - check next
	ld	a,(de)		;check second character
	call	ixlt		;translate to upper case
	and	a		;if null - this is one character reg name
	jr	nz,oprn30
	ld	a,' '		;for comparison purposes
oprn30:	inc	hl		;bump table pointer
	sub	(hl)
	jr	nz,oprn70	;no match - check next
	inc	de		;have match - bump buffer pointer
	or	b		;
	ret	nz		;nz - mreg calling
	ld	a,c		;check index value
	and	07
	jr	nz,oprn80	;not hl ix iy - check for residue
	ld	a,(de)
	call	oprtor		;check for expression operator
	jr	nz,oprn85	;no operator but not end of operand
	ld	a,ix.. or iy..	;special ix iy hl processing
	and	c		;test for index reg
	jr	z,oprn35	;z - must be hl
	and	10h		;transform index into 0ddh or 0fdh
	add	a,a
	add	a,0ddh		;a - first byte of index reg opcode
oprn35:	ld	c,a		;temp save first object byte
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
	jr	nz,oprn80	;no parens - no indexed displacement
	and	a		;check for ix or iy indexed instruction
	jr	z,oprn80	;z - not index reg instruction

	sbc	hl,hl		;clear hl
	ld	a,(de)		;index reg displacement processing
	and	a		;test for default displacement
	call	nz,xval		;not zero - evaluate
	jr	nz,oprn85	;nz - displacement in error
	ld	c,00
	ld	a,l
	ld	(objbuf+2),a	;displacement always third byte
	inc	h		;check upper byte of index value
	jr	z,oprn50	;must have been 0ffh
	dec	h
	ret	nz		;error - index not -128 to +127
	cpl
oprn50:	xor	80h		;check sign bit
	ret	m		;bit on - index out of range
	cp	a		;no error - set zero flag
	ret
oprn70:	dec	c		;decrement reserved operand table index
	jp	m,oprn85	;m - not a reserved operand
	dec	de		;rewind parse buffer pointer
	jp	oprn20		;next table entry
oprn80:	ld	a,(de)		;check for end of parse buffer
	and	a
	ret	z		;found end of line null
oprn85:	ld	de,prsbf	;rewind to start of input
	xor	a
	or	b
	ret	nz		;nz - this was mreg calling
	sbc	hl,hl		;clear hl
	call	xval		;evaluate operand
	ld	c,17h		;assume numeric operand found
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
	jp	m,xval10	;m - this was not first char
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
xval20:	adc	hl,hl		;hl left into carry - rotate carry into hl
	adc	a,a		;next bit of nibble into carry
	dec	c
	jr	nz,xval20
	ld	(base10),a	;store what was shifted left out of hl
	ld	a,80h		;set sign of b - number entered flag
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
	jp	nz,xval90	;nz - take care of previous operator
	and	a		;end of line null?
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
	jr	c,xval40	;error - obviously greater than 65535
	rrd			;nibble to accumulator
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
	ex	de,hl		;hl - converted value
xval40:	pop	de
	pop	bc
	jr	z,xval65	;z - no errors detected
	ret



xval50:	cp	quote		;ascii literal processing
	jr	nz,xval60	;nz - not quote
	ex	de,hl		;
	ld	e,(hl)		;fetch literal from buffer
	inc	hl
	cp	(hl)		;trailing quote found?
	jr	z,xval55	;found
	ld	d,e		;make literal just fetch hi order of operand
	ld	e,(hl)		;fetch new literal as lo order
	inc	hl
	cp	(hl)		;trailing quote?
	ret	nz		;error - more than two chars between quotes
xval55:	ex	de,hl		;de - parse buffer ptr   hl - operand
	inc	de		;bump past trailing quote
	jr	xval65


xval60:	dec	de		;point to start of operand in parse buffer
	ld	(pass2),de
	call	fsym		;search symbol table
	jp	z,xval62	;symbol found
	ld	a,(de)
	inc	de
	cp	'$'		;check for pc relative expression
	jp	nz,xval61
	ld	hl,(asmbpc)	;current location value is expression value
	jr	xval65
				;symbol not found - retry evaluation process
				;with pass2 flag set.  Now token must be a
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
	xor	80h		;toggle flag
	ld	b,a
	ld	a,(de)		;check char following symbol name in buffer
	ld	c,a		;make it new current character
	inc	de
	jp	xval30





xval90:	ld	c,a		;temp save operator
	ld	a,80h		;toggle number entered flag
	xor	b
	ret	m		;return nz - consecutive operators
	ld	b,c		;new on deck operator
	cp	'-'		;test last operator
	push	de		;save buffer pointer
	jr	nz,xval95	;nz - addition
	ex	de,hl
	sbc	hl,hl		;clear
	sbc	hl,de		;force current value neg by subtraction from 0
xval95:	ex	de,hl
	ld	hl,(mexp)	;fetch accumulated operand total
	add	hl,de		;add in current
	pop	de		;restore buffer pointer
	ld	a,b		;check operator that got us here
	and	a		;end of line null?
	jp	nz,xval00	;no -
	ret			;operand processing complete



fsym:
	ld	hl,(06)		;de - buffer   hl - symbol table
fsym00:	ld	a,(maxlen)
	and	l
	ld	c,a
	ld	a,b		;temp save
	ld	b,0
	ex	de,hl		;de - symbol table ptr  hl - parse buffer
	sbc	hl,bc		;rewind parse buffer to start of symbol
	ex	de,hl		;de - parse buffer  hl - symbol table pointer
	ld	b,a		;restore b reg
	ld	a,(maxlen)
	or	l
	ld	l,a
	inc	hl		;next block of symbol table
	ld	a,(hl)		;first character of symbol name
	dec	a
	ret	m		;end of table
	ld	a,(maxlen)
	dec	a
	ld	c,a		;chars per symbol
fsym10:	ld	a,(de)		;fetch char from buffer
	call	oprtor
	jr	nz,fsym20	;nz - not operator or end of line null
	ld	a,(hl)
	and	a		;null means end of symbol name in symbol table
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



isym:	call	fsym		;search for symbol in table
	jr	z,isym00	;z - symbol found
	ld	a,(hl)		;test for empty slot in table
	and	a
	ret	nz		;symbol table full
	ld	(symflg),a	;indicate non-empty symbol table
isym00:	ld	a,(maxlen)	;rewind point to start of table entry
	ld	c,a
	cpl
	and	l
	ld	l,a
	ex	de,hl		;de - pointer to start of symbol
	ld	hl,prsbf
	ld	b,0		;move symbol from parse buffer to table
	dec	c
	ldir
	ld	hl,(asmbpc)	;fetch value of symbol
	ex	de,hl		;hl - pointer to address storage
	ld	(hl),e		;lo order current location into table
	inc	hl
	ld	(hl),d		;upper byte
	xor	a
	ret

	page
;******************************************************************************
;*
;*	prsr:	Command line parse routine
;*
;*	Prsr will extract one argument from the input buffer (inbf) and
;*	write it into the parse buffer (prsbf). An argument is treated
;*	as starting with the first non-delimeter character encountered
;*	in the input buffer and ends with the next delimeter found.
;*	All intervening characters between the two delimeters are
;*	treated as the argument and are moved to prsbf.
;*
;*	As each character is extracted from inbf a zero is written back
;*	to replace it.  Thus a program which needs to extract multiple args
;*	need not save pointers in between calls since prsr is trained
;*	to strip leading delimeters while looking for the start of an
;*	argument:
;*
;*	     delimeters: null, space, comma
;*
;*	exit:	    de - starting address of parse buffer
;*		     b - sign bit: set if unbalanced parens, else sign reset
;*			 bits 6-0: number of chars in the parse buffer
;*		     a - actual delimter char which caused to terminate
;*		     f - zero flag set if no error
;*		quoflg - set equal to ascii quote if at least one quote found
;*
;*	error exit:  f - zero flag reset
;*
;******************************************************************************

prsr:	xor	a
	ld	(quoflg),a	;clear quote flag
	ld	hl,prsbf	;start of parser scratch buffer
	ld	b,prsbfz	;buffer size
	ld	c,b
prsr10:	ld	(hl),0		;clear parse buffer to nulls
	inc	hl
	djnz	prsr10
	ld	hl,prsbf	;start of parse buffer
	ld	de,inbf		;start of input buffer
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
	jr	z,prsr60	;end of line null always ends parse
	cp	quote		;quote?
	jr	nz,prsr50
	ld	(quoflg),a
	ld	a,b		;quote found - toggle flag
	xor	80h
	ld	b,a
prsr50:	dec	c		;decrement buffer size tally
	ret	m		;error - end of parse buffer reached
	ld	a,(de)		;next char from input buffer
	ex	de,hl
	ld	(hl),0		;clear as we remove
	ex	de,hl
	inc	de
	inc	b		;bumping character count tests quote flag
	call	p,zdlm		;only look for delimeters if quote flag off
	inc	hl		;bump parse buffer pointer
	jr	nz,prsr30
	dec	hl
prsr60:	ld	de,prsbf	;return pointing to start of parse buffer
	ld	(delim),a
	ret			;zero flag set - no errors



asm??l:	ld	a,'L'
	jr	asm???
asm??o:	ld	a,'O'
	jr	asm???
asm??p:	ld	a,'P'
	jr	asm???
asm??s:	ld	a,'S'
	jr	asm???
asm??t:	ld	a,'T'
	jr	asm???
asm??v:	ld	a,'V'

asm???:	ld	(asmflg),a
	call	cret
	ld	hl,(asmbpc)
	call	outadr
	ld	de,m????
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



opnv:	ex	de,hl		;de - operand value  hl - operand key storage
	ld	a,(prsbf)	;check first byte of parse buffer
	and	a		;if null - paren was removed
	ld	a,c		;key value to accumulator
	jr	nz,opnv00	;nz - no paren
	or	80h		;found null - set paren flag
opnv00:	ld	(hl),a		;store key value
	inc	hl
	ld	(hl),e		;lo order operand value
	inc	hl
	ld	(hl),d		;hi order
	ret


	page
;******************************************************************************
;*
;*	zlen:  Determine the number of bytes in a z80 instruction
;*
;*
;*	Entry point zlen00: used to return instruction length.
;*
;*			    de:	 address of instruction
;*
;*	Return:	 b:  z - inline instruction (next pc will be pc plus length)
;*		    nz - pc modifying instruction such as call, jump, or ret
;*			 (see hl below)
;*		 c:	 number of bytes in this instruction.
;*		de:	 preserved
;*		hl:	 next pc following the execution of the instruction
;*			 pointed to by de.
;*
;******************************************************************************

zlen00:	ld	a,(de)		;fetch first byte of op code
	cp	0cbh		;test for shift/bit manipulation instruction
	ld	bc,02
	ret	z		;10-4 this is a CB and length is always 2
	cp	0edh		;test for fast eddie
	jr	nz,zlen15	;
	inc	de		;fetch byte two of ED instruction
	ld	a,(de)
	dec	de		;restore pointer

	if	h64180
	ld	hl,z8ed3	;ED three byter table
	ld	c,z8ed3l	;length
	cpir
	ld	c,3		;assume ED three byter
	ret	z		;correct assumption
	endif

	ld	hl,z80ed	;ED four byter table
	ld	c,z80edl	;length
	cpir
	ld	c,4		;assume ED four byter
	ret	z		;correct assumption

	ld	c,2		;set length for return - if not 2 must be 4
	cp	45h		;test for retn
	jr	z,zlen10
	cp	4dh		;test for reti
	ret	nz		;non-pc modifying two byte ED
zlen10:	ld	a,0c9h		;treat as ordinary return instruction
	jp	zlen80
zlen15:	cp	0ddh		;check for DD and FD index reg instructions
	jr	z,zlen20
	cp	0fdh
	jr	nz,zlen40
zlen20:	inc	de		;fetch byte two of index reg instruction
	ld	a,(de)
	dec	de		;restore pointer
	cp	0e9h		;check for reg indirect jump
	jr	nz,zlen30	;
	inc	b		;reg indirect jump - set pc modified flag nz
	ld	a,(de)		;recheck for ix or iy
	ld	hl,(ixreg)	;assume ix
	cp	0ddh
	ret	z		;correct assumption
	ld	hl,(iyreg)
	ret
zlen30:	ld	hl,z80fd	;check for DD or FD two byter
	ld	c,z80fdl
	cpir
	ld	c,2		;assume two
	ret	z
	ld	hl,z80f4	;not two - try four
	ld	c,z80f4l
	cpir
	ld	c,4		;assume four
	ret	z		;correct assumption
	dec	c		;must be three
	ret
zlen40:	and	0c7h		;check for 8 bit immediate load
	cp	06
	ld	c,2		;assume so
	ret	z
	dec	c		;assume one byte op code
	ld	a,(de)
	cp	3fh
	jr	c,zlen50	;opcodes 0 - 3f require further investigation
	cp	0c0h		;8 bit reg-reg loads and arithmetics do not
	ret	c
zlen50:	ld	hl,z803		;check for three byter
	ld	c,z803l
	cpir
	jr	nz,zlen60	;nz - not three
	ld	hl,z803s	;established three byter - test conditional
	ld	c,z803cl
	cpir
	ld	c,3		;set length
	ret	nz		;nz - three byte inline instruction
	ld	hl,z803s
	ld	c,z803sl	;now weed out jumps from calls
	cpir
	ld	c,3
	ld	b,c		;set pc modified flag - we have call or jump
	ex	de,hl
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)		;de - address from instruction
	ex	de,hl
	dec	de
	dec	de		;restore instruction pointer
	jr	z,zlen55	;z - this is a call
	cp	zjp		;test for unconditional jump
	jr	nz,zlen85
	ret
zlen55:	ld	a,(wflag)	;test for no subroutine trace flag
	and	a		;zero means no sub tracing
	ld	b,a		;clear for return - if sub trace off
	ret	z		;subroutine trace off - return with b reg 00
				;so bp is set at next inline instruction
	dec	b
	jr	nz,zlen58
	ld	a,b
	or	h
	ret	z
zlen58:	ld	a,(de)		;recover call object byte
	ld	b,c		;set nz - pc modifying instruction
	cp	0cdh		;unconditional call??
	jr	nz,zlen85	;zlen85 - set secondary breakpoint if tracing
	ret

zlen60:	ld	hl,z802
	ld	c,z802l		;test for two byter
	cpir
	jr	nz,zlen70	;not two
	ld	hl,z802c	;test for relative jump
	ld	c,z802cl
	cpir
	ld	c,2		;in any case length is two
	ret	nz		;nz - not relative jump
	ld	h,b		;clear
	inc	b		;set pc modified flag nz
	inc	de		;fetch relative displacement
	ld	a,(de)
	ld	l,a
	add	a,a		;test forward or backward
	jr	nc,zlen65	;p - forward
	dec	h		;set hl negative
zlen65:	add	hl,de		;compute distance from instruction
	inc	hl		;adjust for built in bias
	dec	de		;restore pointer
	ld	a,(de)		;fetch first byte of instruction
	cp	18h		;uncondtional jump?
	jr	nz,zlen85	;conditional - set secondary bp if tracing
	ret
zlen70:	ld	hl,z801		;check for return instruction
	ld	c,z801l
	cpir
	ld	c,1		;length must be 1 in any case
	ret	nz
	cp	0e9h
	jr	nz,zlen80	;nz - not  jp (hl)
	inc	b		;set pc modified flag
	ld	hl,(hlreg)	;next pc contained in hlreg
	ret
zlen80:	ld	hl,(spreg)	;return instructions hide next pc in stack
	ld	b,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,b		;hl - return address removed from stack
	ld	b,c		;set b nz - pc modification flag
	cp	0c9h
	ret	z		;unconditional return
zlen85:	ld	a,(sbps)	;count of special step breakpoints
	and	a		;test for zero
	ret	z		;zero - monitor is not tracing
	ld	a,(bps)		;fetch number of bps currently in effect
	ld	b,a		;pass to set breakpoint routine in b reg
	ex	de,hl		;de - bp to set
	call	brk30		;set conditional breakpoint
	xor	a
	or	b
	ld	b,0
	ld	de,(pcreg)	;for setting inline bp - condition not m
	ret	nz		;nz - collision with user bp
	ld	hl,sbps
	inc	(hl)		;bump count of step bps
	ret

	page
;******************************************************************************
;*
;*	pswDsp:	Display current state of flag register
;*
;*	pswbit:	Table of bit masks with which to test f reg.
;*		Two byte entry per bit (sign, zero, carry, parity).
;*
;*	pswmap - table of offsets into operand name table featuring a
;*		 two byte entry for each flag bit.
;*		 bit 4 (unused by z80) from pswbit entry is on/off flag
;*		 lo bytes are the off states (p nz nc po).
;*		 hi bytes are the on states  (m  z  c pe).
;*
;*	- current state of flag register is displayed
;*	- user queried for changes
;*	- input is parsed and tested for valid flag reg mnemonics
;*	- if valid mnemonic found flag bit is set or reset accordingly
;*
;*	exit:	to z8e for next command
;*
;******************************************************************************

pswDsp:	ld	de,3
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
	and	(hl)			;unused bit in flag - ensure it's off
	ld	hl,pswmap
	add	hl,bc			;pointer to mnemonic is 8 bytes away
	jr	z,psw10			;this is an off bit (nz nc p po)
	inc	hl			;on
psw10:	ld	c,(hl)			;fetch index into operand name table
	ld	hl,zopnm
	add	hl,bc			;two bytes per table entry
	add	hl,bc
	ld	c,2			;print both chars of mnemonic name
	call	printb
	call	space1
	dec	e			;do all four flag bits
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
	call	oprn20			;check validity of this token
	ld	a,c
	ld	bc,pswcnt		;number of flag reg mnemonics
	ld	hl,pswmap
	cpir				;check table
	jp	nz,e???			;error - nmemonic not found
	ld	hl,pswbit		;bit mask table
	add	hl,bc
	ld	a,(hl)			;fetch mask
	ex	de,hl			;
	ld	hl,freg			;de - mask ptr   hl - user flag ptr
	and	08			;bit says turn on or off
	ld	a,(de)			;new copy of mask
	jr	nz,psw60		;nz - turn on
	cpl
	and	(hl)			;and with current user flag
	ld	(hl),a			;return flag reg with bit now off
	jr	psw55			;check for more input
psw60:	and	0f7h			;turn off on/off flag (bit 4)
	or	(hl)
	ld	(hl),a			;now turn on specified bit
	jr	psw55

	page
;******************************************************************************
;*
;*	movb:	Move memory
;*
;*	call bcde to fetch destination block address and byte count
;*	call prsr
;*	check for head to head or tail to tail move
;*
;*	exit: to z8e for next command
;*
;******************************************************************************

movb:	call	bcde		;bc - byte count  de - destination  hl - source
	jp	nz,e???		;input error ends command
	xor	a
	sbc	hl,de
	adc	a,a
	add	hl,de
	add	hl,bc
	dec	hl
	ex   	de,hl		;de - address of last byte of source block
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

	page
;******************************************************************************
;*
;*	yfil:	Fill memory
;*
;*	call bcde to get byte count, starting address, and fill byte
;*
;*	exit:	to z8e for next command
;*
;******************************************************************************

yfil:	call	bcde		;bc - byte count  de - fill byte  hl - block
	jp	nz,e???		;input error ends command
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

	page
;*********************************************************************
;
;	CUSER	Change user routine	EG	5 Jan 88
;
;	10 Jan 88	Added check for bad args
;
;	Uses '>' as command
;
;*********************************************************************

cuser:	call 	iedtbc
	ret 	m
	call 	iarg		; gets user in HL as a hex no
	jp 	nz,e???		; don't allow bad (would go to user 0)
	ld 	a,h
	or 	a
	jp 	nz,e???		; 2 - byte user number?
	ld 	a,l
	cp 	10h
	jr 	c,cusok		; you can enter user in hex or decimal with '#'
	sub 	6		; else convert to decimal
	cp 	10h		; see if still too big
	jp	nc,e???
cusok:	ld 	c,32
	ld 	e,a
	jp 	bdos		; change user

;*******************************************************************
;
;	QEVAL - expression evaluator	EG 10 Jan 88
;
;	Uses '?' as command
;
;*******************************************************************
qeval: 	call 	iedtbc		; get input
	ret 	m		; none
	call 	iarg		; Z8E does all the real work
	jp 	nz,e???		; check for valid arg
	call 	crlf
	ld 	a,h		; see if 1 byte
	or 	a
	jr 	nz,qev01	; 2-byte number
	ld 	a,l
	call 	outhex		; hex byte
	ld 	a,l
	cp 	7fh		; see if printable
	ret 	nc
	cp 	' '
	ret 	c
	ld 	c,3
	call 	spaces		; even up with spaces
	ld 	a,27h		; quote
	call 	ttyo
	ld 	a,l		; show char
	call 	ttyo
	ld 	a,27h
	jp 	ttyo
qev01:	jp 	outadr		; output 2-byte result

;***********************************************************
;
;	GADR - Get program addr data	EG 20 Feb 88
;
;	Uses '#' as command
;
;	Deleted 5/Jan/89 by jrs - unnecessary as L command
;	with no file name (now) does the same thing.
;
;************************************************************
;gadr:	ld 	hl,(loadn)
;	ld 	c,10		; out-of-memory flag
;	jp 	lbin22

	page
;------------------------------------------------------------------------------
;
;	Initialise default FCB fields and command line	(16 may 87  jrs)
;
;	Calls iedtbc to get command tail
;	      lfcb   twice to extract file names
;
;	exit:	FCB name fields at 5Ch and 6Ch initialised
;		Command tail set up at 80h
;
;------------------------------------------------------------------------------

ifcb:				;(Condensed, improved version - jrs 27 Dec 88)

	call	iedtbc		;Get command tail
	dec	hl		;Point at input buffer length
	push	hl		;Save input buffer pointer
	ld	hl,fcb5c	;Zero out the default FCB
	ld	b,32
ifcb00:	ld	(hl),0
	inc	hl
	djnz	ifcb00
	ld	l,fcb5c+1	;Blank out the two file names
	call	iblank
	ld	l,fcb5c+17
	call	iblank
	pop	hl		;Get input buffer pointer
	ld	de,80h		;Destination is command line buffer
	ld	b,(hl)		;Get input buffer length
	ld	a,b		;Load length ready to put in command buffer
	inc	b		;Account for the length byte itself
ifcb02:
	ld	(de),a		;Store character in command buffer
	inc	de		;Increment pointers
	inc	hl
	ld	a,(hl)		;Load character from input buffer
	call	ixlt		;Translate to upper case
	djnz	ifcb02		;Loop until all copied
	xor	a		;Terminate the command buffer properly
	ld	(de),a
	call	lfcb		;Get a file name (if any)
	jr	nz,ifcb12	;Skip if error
	ld	de,fcb5c	;Copy FCB to default FCB at 5ch
	ld	hl,fcb
	ld	bc,12		;(only move 12 bytes)
	ldir
ifcb12:
	call	lfcb		;Do second file name (if any)
	ret	nz		;Exit now if error
	ld	hl,fcb		;Copy file name part of FCB to
	ld	de,fcb5c+16	; second segment of default FCB
	ld	bc,12
	ldir
	ret

iblank:				;Blank out 11 bytes at HL
	ld	b,11
ibl00:	ld	(hl),' '
	inc	hl
	djnz	ibl00
	ret


; I originally intended that the following code should be used to expand
; asterisks in file names but I never invoked it anywhere!  Eventually
; someone complained and I corrected the omission by adding some code to
; the LFCB routine.  When I (re)discovered this code I noticed that it was
; longer than the code added to LFCB so I commented it out.  I am leaving
; it here because LFCB was never intended to handle ambiguous file names.
; I don't think there is a problem but should there turn out to be some
; sort of wierd conflict then it should be easy to activate this little
; routine.	jrs 27 Dec 88
;
;iwild:				;Expand asterisks in file names
;	ld	bc,8		;Enter with HL pointing at FCB+1
;	call	iexp		; i.e. first byte of file name.
;	ld	bc,3
;;	call	iexp
;;	ret
;iexp:
;	ld	a,'*'
;	cpir
;	ret	nz
;	inc	bc
;	dec	hl
;iexp10:
;	ld	(hl),'?'
;	inc	hl
;	dec	c
;	ret	z
;	jr	iexp10

	page
;******************************************************************************
;*
;*	lldr:	Load file
;*	User may supply optional load bias if file name ends with comma.
;*
;*	lfcb:	Parse input buffer (inbf) and init FCB
;*
;*		Return:	z  - FCB initialized
;*			nz - syntax error
;*
;*	lopn:	Attempt to open file
;*
;*		Return:	nz - file opened
;*			 z - file not found
;*
;*	lmem:	Test if sufficient memory available for loading
;*
;*		Return: nc - out of memory
;*
;*	lbin: Loader
;*
;*		Eof found:     end command
;*		Out of memory: query user whether to continue
;*
;******************************************************************************

lldr:	call	iedtbc		;Get file name
	jp 	p,lldr00     	;P - have input in inbf
	ld	hl,(loadn)
	ld	a,l
	or	h
	jp	z,e???
;	ld	c,a		;-
	ld	c,10		;+ 3.5.5 jrs 5/jan/89
	jp	lbin22
lldr00:	call	crlf
	call	lfcb		;Init FCB with name and drive
	jp	nz,esntx	;nz - syntax error
	ld	de,mldg		;Display loading string
	call	nprint
	ld	de,prsbf
	ld	a,(de)		;A - first char of file name
	ld	b,a
	call	print
	ld	a,','
	cp	c		;C - terminator following file name (from lfcb)
	ld	hl,100h		;Assume no bias
	jr	nz,lldr05	;NZ - no comma means no load bias
	call	iarg		;Check for load bias
	jp	nz,esntx	;Error - bad argument
	call	imem		;Check available memory
	jp	nc,emem??	;Out of memory
lldr05:	ld	(loadb),hl	;Save load bias
	ld	a,'.'		;Test if file name is period
	sub	b
	jr	z,lbin		;File name is period - no open needed
lldr10:	call	lopn		;Attempt to open file - entry from nint
	jp	z,efilnf	;Z - file not found


lbin:
	ld	hl,(loadb)	;Fetch starting load address
lbin00:	push	hl
	ex	de,hl
	ld	c,26		;Set CP/M DMA address
	call	bdos
	ld	de,fcb
	ld	c,20		;CP/M sequential file read
	call	bdos
	pop	de		;Recover DMA address
	ld	hl,80h
	add	hl,de		;Compute next DMA address
	ld	(cflag),a	;Save EOF indicator as continuation flag
	ld	c,a
	and	a
	jr	nz,lbin20	;NZ - end of file
	call	imem		;Test if memory available to load next sector
	jr	c,lbin00	;C - not out of memory
lbin20:	ex	de,hl
	dec	hl
	ld      (loadn),hl	;End of load address
lbin22: ld	de,mlodm	;Print loaded message
	call	nprint
	ex	de,hl		;DE - ending address of load
	ld	hl,(loadb)
	call	outadr		;Display starting address of load
	ex	de,hl
	call	outadr		;Display ending address
	and	a
	sbc	hl,de
	inc	h
	ld	de,mlodpg
	call	nprint		;Display pages string
	ld	l,a		;zero L reg
	ld	a,h		;Hi byte of ending address is number of pages
	cp	100
	jr	c,lbin30	;Less than 100
	ld	l,'2'
	sub	200
	jr	nc,lbin25	;Greater than 200
	dec	l		;change to ASCII 1
	add	a,100		;Restore actual page count less 100
lbin25:	ld	h,a		;Save page count
	ld	a,l
	call	ttyo
lbin30:	ld	d,2fh
	ld	a,h
lbin35:	inc	d		;Tens and units decimal conversion loop
	sub	10
	jr	nc,lbin35
	add	a,10		;Restore remainder
	ld	e,a		;Temp save while we print tens
	ld	a,d
	inc	l
	dec	l		;Test L reg
	jr	nz,lbin40	;NZ - ASCII 1 or 2 in L
	cp	'0'		;Suppress leading zero - less than 10 pages
lbin40:	call	nz,ttyo		;Print tens digit
	ld	a,e
	or	'0'
	call	ttyo		;Print units
	call	crlf
;	xor	a		;- eg 3.3.7a Test eof flag
;	or	c		;-
	ld	a,c		;+ Test EOF flag
	cp	10		;+ Was it set by GADR (see 3.3.11)
	jp	z,z8e		;+ Exit if so
	or	a		;+
;	jp	nz,z8e		;- nz - true eof means file loading complete
	jr	nz,z8ej		;+
	ld	de,mmem??	;Print "out of memory" message
	call	print
	ld	de,mcntu
	call	print		;Print continue? prompt
	call	inchar
	call	ixlt		;Make sure its upper case
	cp	'Y'
	call	crlf
	jp	z,lbin		;User wants more loading
z8ej:				;+
	ld	c,26		;+ "Set DMA" function
	ld	de,80h		;+ Restore default DMA for user program
	call	bdos		;+
	jp	z8e		;Next command


lfcb:	call	prsr		;parse input buffer to extract file name
	ld	d,a		;save char which terminated file name
	ld	a,14
	cp	b		;over 14 chars is ng file name
	ret	c
	ld	c,b		;b and c - byte count of file name
	djnz	lfcb00		;test for only one char in name
	ld	a,(prsbf)	;only one - is it period?
	sub	'.'
	jr	nz,lfcb00
	ld	c,d		;return terminator
	ld	a,(cflag)	;continuation allowed?
	and	a		;let lldr decide
	ret
lfcb00:	ld	b,0
	ld	a,':'		;check for drive specifier in input
	cpdr
	ld	b,c		;b - number of chars preceding colon
	ld	c,d		;return terminator in c
	ld	de,fcb
	ld	a,0
	jr	nz,lfcb10	;nz - no colon
	dec	b
	ret	nz		;syntax error - more than one char
	ld	a,(hl)		;fetch drive specifier
	call	ixlt
	ld	(hl),a		;back to parse buffer as upper case
	sub	40h		;make name into number
	inc	hl
lfcb10:
       	ld	(de),a		;store drive number in fcb
	ld	a,' '
	ld	b,11		;clear file name in fcb to spaces
lfcb20:	inc	de
	ld	(de),a
	djnz	lfcb20
	ld	b,8		;max chars allowed in file name
	ld	de,fcbnam
lfcb30:	call	lfcb90
	ret	m		;error - too many chars in file name
	ld	b,3		;max chars allowed in file type
	ld	de,fcbtyp
	and	a
	ret	z		;z - no file type after all



lfcb90:	inc	hl		;Bump buffer pointer
	ld	a,(hl)
	and	a		;Test for null at end of file name
	ret	z		;Null found - nothing more to parse
	call	ixlt
	ld	(hl),a		;Translate parse buffer to upper case
	cp	'.'
	ret	z		;Period found - move file type into FCB

; --- Added 4 Dec 88 --- jrs
	cp	'*'		;Expandable wildcard?
	jr	z,lfcb95
; --- end of added code ---
	dec	b		;Dec max chars allowed
	ret	m		;Error if name or extension is too long
				; or a character follows an asterisk
	ld	(de),a		;Upper case only into FCB
	inc	de
	jr	lfcb90
; --- Added 4 Dec 88 --- jrs
lfcb95:
	ld	a,'?'
lfcb96:
	ld	(de),a
	inc	de
	djnz	lfcb96
	jr	lfcb90
; --- end of added code ---
lopn:
	ld	hl,fcbnam	;test for file name present
	ld	a,(hl)
	cp	' '
	ret	z		;space found means not file
;;	dec	hl
;;	ld	a,(hl)		;drive specifier
;;	and	a		;test for default drive
;	jr	z,lopn00	;z - default means no selection required
;	dec	a		;select drive
;	ld	e,a
;	ld	c,14
;	call	bdos
lopn00:	ld	de,fcb
	ld	b,nfcb-fcbext
	ld	hl,fcbext	;clear remainder of fcb
lopn10:	ld	(hl),0
	inc	hl
	djnz	lopn10
	ld	c,15
	call	bdos		;tell bdos to open file
	inc	a		;test open return code
	ret			;nz - open ok

imem:	ex	de,hl		;de - next load address
	ld	a,d
	ld	hl,07		;ptr to prt to start of z8e
	cp	(hl)
	ex	de,hl
	ret	c		;c - not out of memory
	ex	de,hl
	ret			;de - last address loaded plus one

esntx:	ld	de,msntx	;print syntax error
	jr	eprint

emem??:	ld	de,mmem??	;print out of memory
	call	nprint
	jr	eprint

efilnf:	ld	de,mfilnf	;print file not found

eprint:	call	nprint
	jp	z8e

	page
;*****************************************************************************
;*
;*            write memory segment to disk command
;*
;*****************************************************************************

writ:	call	iedtbc		;fetch line of input
	ret	m		;no input -
	call	bldf		;build fcb with first arg in buffer
	jr	nz,esntx	;oops - syntax error
	ld	a,(delim)	;check char that terminated file name
	and	a
	jr	nz,writ10	;nz - not null means user entered addresses

	ld	de,(loadb)	;use default begin and end address of the last
	ld	hl,(loadn)	;file loaded
	jr	writ30
writ10:	call	iarg		;get address
	jp	nz,e???		;invalid address
	ex	de,hl
	cp	' '		;space terminator
	jp	nz,e???		;anything but is error
writ20:	call	iarg		;get end address
	jp	nz,e???
writ30:	ld	(endw),hl	;save address of where to end writing
	ex	de,hl
	ld	c,3
	call	spaces
	call	outadr
	ex	de,hl
	ld	c,6
	call	spaces
writ40:	call	bwrite
	ld	hl,127
	add	hl,de
	ld	b,6
writ50:	call	bksp
	djnz	writ50
	call	outadr
	inc	hl
	ex	de,hl
	ld	hl,(endw)
	sbc	hl,de
	jr	nc,writ40
	jp	closef



;******************************************************************************
;*
;*	find:	Locate string in memory
;*
;*		call iarg - get starting address of seach
;*
;*		call in00 - get match data concatenating multiple arguments
;*			    into a single string
;*
;*		Addresses at which matches found displayed 8 per line.
;*		Search continues until end of memory reached.
;*		User may cancel search at any time by hitting any key.
;*
;*		exit: to z8e for next command
;*
;******************************************************************************

find:	call	iedtbc
	ret	m		;m - no input
	call	iarg		;extract starting address of search
	jp	nz,e???		;error
	ex	de,hl		;save starting address of search in de
find00:	call	in00		;extract search string concatenating multiple
				;arguments
	jp	nz,e???		;error - output command prompt
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

find40:	ld	bc,(argbc)	;number of bytes to look for
	call	crlf
find50:	call	srch		;do the search
	jr	nz,find60	;not found
	call	outadr		;display address where match found
	ld	a,(lines)
	dec	a		;carriage return after 8 addresses displayed
	ld	(lines),a
	and	7
	call	z,crlf
	call	ttyq		;user requesting abort?
	cp	cr
	ret	z		;abort - return to z8e
find60:	inc	hl		;point to next address at which to start search
	add	hl,bc		;ensure we won't hit end of memory by adding
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

	page
;******************************************************************************
;*
;*	verify:	Verify two blocks of data are identical
;*
;*		enter: de - starting address of block 1
;*
;*		call bcde to get address of block 2 and byte count
;*
;*		mismatch:   block 1 address and byte are displayed
;*			    block 2 address and byte are displayed
;*			    console intrrogated - any input terminates verify
;*
;*		exit:	to z8e for next command
;*
;******************************************************************************

verify:	call	bcde		;get block 2 address and byte count
	jp	nz,e???
	ex	de,hl
verf00:	ld	a,(de)		;byte from block 1
	xor	(hl)		;versus byte from block two
	jr	z,verf10	;match - no display
	call	newlin
	ld	a,(de)
	call	othxsp		;display block 1 data
	call	space1
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

	page
;******************************************************************************
;*
;*	xreg:	Display machine state
;*
;*		regptr:	Table contains offsets to names in operand name table.
;*			Sign bit set indicates prime register.
;*
;*		regmap:	Table contains offsets to reg contents table (regcon)
;*			Sign bit ignored (used by rgst command).
;*
;*		regcon:	Table of register contents.
;*
;*		exit:	Make current pc current disassembly location counter.
;*			Set bit 6 of disassembly flag byte (zasmfb)
;*			Jump to zasm30 to disassemble current instruction.
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
	jp	pswDsp		;+

xreg05:	ld	hl,regptr	;map of reg name pointers
	ld	d,b
	add	hl,bc
	ld	a,(hl)		;extract pointer
	and	7fh		;strip sign for name indexing
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
xreg10:	call	ttyo		;display second character
	xor	a
	or	b		;now test sign
	jp	p,xreg20	;sign not set - not prime reg
	ld	a,27h		;display quote
	call	ttyo
xreg20:	ld	a,':'
	call	ttyo
	ld	hl,regmap	;map of pointers to reg contents
	add	hl,de
	ld	a,(hl)
	jp	p,xreg30	;p - not prime reg
	add	a,8		;prime contents 8 bytes past non-prime
xreg30:	and	7fh		;ignore sign
	ld	e,a
	ld	hl,regcon	;start of register contents storage
	add	hl,de
	ld	d,(hl)		;hi order contents
	dec	hl
	ld	e,(hl)
	ex	de,hl
	call	outadr		;display contents
	ret

	page
;******************************************************************************
;*
;*	zasm
;*
;*	The disassembler is divided into two routines:
;*
;*	zasm - computes the instruction key value and finds the opcode nmemonic
;*	opn  - uses the key value to determine the number of operands and
;*	       displays the operands.
;*
;*	entered: de - starting address to disassemble
;*
;*		Zasm maps the 695 z80 instrucions into 256 key values.
;*              the instruction key value becomes the index into the
;*              opcode name pointer table (zopcnm), the first operand table
;*		(zopnd1), and the second operand table (zopnd2).
;*
;*		Disassembly is done in user specified block sizes if the
;*		disassembly count evaluates to a number between 1 and 255. If
;*		the count is greater than 255 the block is disassembled and the
;*		the command terminates.
;*
;*
;*		zasm15 - start of the disassembly loop
;*		zasmpc - address of the instruction being disassembled
;*		zasmfb - disassembly flag byte
;*		zmflag - flag indicating directive processing (defb and defw)
;*
;*			    bit 6 - xreg calling
;*			    bit 5 - asmblr calling
;*			    bit 0 - write to disk flag
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
	jp	nz,e???
	ex	de,hl
	call	iarg		;read in block size
	ld	b,a		;save delimeter
	jr	z,zasm00
	ld	hl,1		;change zero count to one
zasm00:	xor	a
	or	h
	jr	z,zasm05
	sbc	hl,de
	jp	c,e???		;error - start address greater than end
	add	hl,de
zasm05:	ld	(zasmct),hl	;save as permanent block count
	ld	(zasmwt),hl	;save as working tally
	ex	de,hl		;hl - current instruction pointer
	ld	(zasmpc),hl
zasm06:				;+ eg 3.3.2
	call	crlf
	ld	a,b		;check command line delimeter
	ld	(dwrite),a	;save as write to disk flag:
				;z - no write   nz - write
	and	a
	call	nz,bldf		;not end of line - build fcb
	jp	nz,esntx

zasm08:	ld	de,zasmbf	;start of disassembly buffer

zasm10:	ld	(zasmio),de	;init pointer

zasm15:	ld	de,(zasmpc)	;fetch address to disassemble
	call	zlen00		;calculate length
	ex	de,hl

				;loop back here for interactive disassembly -
				;user requests format change. C reg:
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
	call	othxsp		;display object code
	inc	hl
	djnz	zasm20
	ld	a,c		;number of object bytes
	dec	a
	xor	3
	ld	b,a		;calculate space padding
	add	a,a
	add	a,b
	add	a,2
	ld	b,a
zasm25:	call	space1
	djnz	zasm25
	ld	(zasmnx),hl	;store address of next instruction
	and	a		;clear carry
	sbc	hl,bc		;point to first byte in instruction
zasm30:	ex	de,hl		;de - current instruction pointer
	ld	hl,(zasmio)	;buffer address storage
	ld	a,(maxlin)
	ld	b,a		;line length based on max symbol size
zasm35:	ld	(hl),' '	;space out buffer
	inc	hl
	djnz	zasm35
	ld	a,b
	ld	(opnflg),a
	ld	(hl),cr		;append crlf
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

; Test for defw

	if	h64180
	ld	b,66H
	else
	ld	b,6DH
	endif

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
	jr	c,zasm90	;opcode range 0 - 3f
	ld	b,0e0h		;
	cp	0c0h		;
	jr	nc,zasm90	;opcode range c0 - ff
	cp	80h
	jr	nc,zasm85	;opcode range 80 - bf
	ld	b,0f8h		;
	cp	76h		;test for halt instruction
	jr	nz,zasm85	;opcode range 40 - 7f
	ld	a,0ffh		;set halt instruction key value to 0f7h
	jr	zasm90
zasm55:	inc	de
	ld	a,(de)		;byte two of multi-byte instruction
	dec	c		;test for ED instruction
	jr	nz,zasm65	;nz - not an ED

	if	h64180

	call	zed180		;Do HD64180 decode of ED 00 to ED FF opcode.
	jr	zasm90		;Go build instruction key.

	else

	cp	80h
	jr	nc,zasm60	;opcode range ed 40 - ed 7f
	cp	40h
	jr	nc,zasm90	;legal
	ld	a,09fh
	jr	zasm90		;map to question marks
zasm60:	ld	b,0e0h		;set bias
	cp	0c0h		;test for illegal ed
	jr	c,zasm90	;legal
	ld	a,0bfh		;map to question marks
	jr	zasm90		;opcode range ed a0 - ed bb

	endif

zasm65:	inc	c
	jr	z,zasm80	;z - cb instruction
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
	jr	c,zasm85	;opcode range cb 00 - cb 3f (shift)
	rlca
	rlca
	and	03		;hi order bits become index
	ld	b,0f0h
	jr	zasm90		;opcode range cb 40 - cb ff
zasm85:	rrca
	rrca
	rrca			;bits 3-5 of cb shift yield key
	and	07h
zasm90:	add	a,b		;add in bias from b reg
	ld	c,a		;c - instruction key value
	xor	a
	ld	b,a
	ld	hl,zopcpt	;opcode name pointer table
	add	hl,bc		;index into table
	ld	l,(hl)		;fetch opname index
	ld	h,a
	add	hl,hl
	add	hl,hl		;index times four
	ld	de,zopcnm	;op code name table
	add	hl,de
	ex	de,hl		;de - pointer to opcode name
	ld	hl,(zasmio)	;buffer pointer storage
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
	ex	de,hl		;de - buffer   hl - opcode name pointer
	ldir
	inc	bc		;one space after opcode for compressed format
	jr	z,zasm95
	ld	c,4		;four spaces for true disassembly
zasm95:	ex	de,hl		;hl - buffer pointer
	add	hl,bc		;start of operand field in buffer
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
zasm99:	ld	de,zopnd1	;table of first operands
	add	a,e
	ld	e,a		;instant offset
	ld	a,d
	adc	a,b
	ld	d,a
	ld	a,(de)
	inc	a
	jr	z,opn040	;no operands

	page
;******************************************************************************
;*
;*                          - operand processing -
;*
;*	enter:	b - zero (process first operand)
;*		c - instruction key value
;*
;*   instruction key value is used to fetch operand key value:
;*
;*	operand key value is in the range 0 - 1fh
;*	operand key value interpretted as follows:
;*
;*      0 - 17h  use as index to fetch literal from operand
;*		 name table (sign bit set - parens required)
;*
;*     18 - 1fh  operand requires processing - use as index
;*	         into operand jump table which is located
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
;*     opn200	   19h	 register specified in instruction
;*     opn300	   1ah	 convert 16 bit operand to hex
;*     opn400	   1ch	 convert 8 bit operand to hex
;*     opn600	   1dh	 hl/ix/iy instruction
;*     opn700	   1eh	 mask rst operand from bit 3-5 of rst instruction
;*     opn800	   1fh	 bit number is specified in bits 3-5 of opcode
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
	jr	c,opn015	;c - operand is a fixed literal
	ld	a,(hl)		;fetch processing routine address
	inc	hl
	ld	h,(hl)		;
	ld	l,a		;hl - operand processing routine
	jp	(hl)		;geronimoooooooo
opn015:	ldi			;first byte of operand literal
	inc	bc		;compensate for ldi
	ex	de,hl		;hl - buffer
	ld	a,(de)
	cp	' '		;test for space as byte two of literal
	jr	z,opn020	;ignore spaces appearing in byte two
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
	jr	z,opn040	;z - no second operand
	ld	(hl),','	;separate operands with comma in buffer
	inc	hl
	jr	opn
opn040:	ld	hl,(zasmio)	;rewind buffer pointer
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
	and	7Fh		;in case we fell thru
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
	jr	z,opn045	;defw - 082h
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
	jr	z,opn080	;less - this is tally
	ld	bc,(zasmnx)	;fetch next disassembly address
	sbc	hl,bc		;versus requested end address
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
	cp	cr		;return means end
	jr	z,opn095
	jr	opn090
opn085:
	call	ttyq
	cp	cr
	jr	z,opn095	;nz - terminate disassembly
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
	call	write



closef:	ld	de,fcb		;close file
	ld	c,16
	jp	bdos

	if	h64180

;****************************************************************************
;*
;*	ZED180	ED opcode mapper for HD64180 debugger
;*
;*	Input:	A	2nd opcode of ED instruction to be mapped
;*		B	zero
;*		EDBAD	Table of illegal 2nd opcodes in the range 40H to 7FH
;*		EDBIAS	Table of biases for 2nd opcodes smaller than 40H
;*
;*	Output:	A	Unchanged
;*		B	Bias which will should be added to A to create
;*			instruction key for opcode
;*
;*	Description:
;*		This routine causes all ED opcodes to be mapped into
;*		instruction keys 40H to 9FH.
;*
;*		All Z80 opcodes are mapped as they were in the "Z80 only"
;*		release.
;*
;*		The defb and defw pseudo-ops were moved from 6CH and 6DH
;*		to 65H and 66H respectively because of a conflict with
;*		the HD64180-specific MLT HL instruction.
;*
;*		The HD64180-specific OTIM, OTIMR, OTDM and OTDMR instructions
;*		are mapped with a bias of 1 to avoid conflicting with the
;*		OUTI, OTIR, OUTD and OTDR instructions respectively.
;*
;*		The HD64180-specific TST m, TSTIO m, SLP, MLT BC, MLT DE,
;*		MLT HL and MLT SP instructions are mapped with a bias of 0
;*		just as all the other ED opcodes in the 40H to 7FH range.
;*
;*		The 22 HD64180-specific ED instructions less than 40H are
;*		mapped into the remaining "holes" via the EDBIAS lookup
;*		table.
;*
;*		ALL illegal ED opcodes will be mapped into 9FH which will
;*		cause a defb to be used.
;*
;****************************************************************************

zed180:	cp	0c0h		;Opcode range ED 00 to ED BF?
	jr	c,zed10		;If so, keep checking.
zed05:	ld	a,9fh		;Else, illegal, map to question marks.
	ret			;Go build instruction key.

zed10:	cp	0a0h		;Opcode range ED 00 to ED 9F?
	jr	c,zed15		;If so, keep checking.
	bit	2,a		;Else, is bit 2 on?
	jr	nz,zed05	;If so, illegal opcode.
	ld	b,0e0h		;Else, bias is e0h.
	ret			;Go build instruction key.

zed15:	cp	83h		;OTIM?
	jr	z,zed20
	cp	8bh		;OTDM?
	jr	z,zed20
	cp	93h		;OTIMR?
	jr	z,zed20
	cp	9bh		;OTDMR?
	jr	nz,zed25
zed20:	inc	b		;Bias is 1.
	ret			;Go build instruction key.

zed25:	cp	80h		;Opcode range ED 00 to ED 7F?
	jr	nc,zed05	;If not, illegal opcode.

	cp	40h		;Opcode range ED 00 to ED 3F?
	jr	c,zed30		;If so, look up bias in EDBIAS.
	ld	hl,edbad	;Point HL to illegal ED opcodes in 40h to 7fh.
	ld	c,edbadl
	cpir			;Illegal?
	jr	z,zed05		;If so, map to question marks.
	ret			;Else, go build instruction key.

zed30:	ld	hl,edbias	;Else, point HL to ED biases for opcodes < 3fh.
	ld	c,a
	add	hl,bc		;Point HL to bias for this ED opcode.
	ld	b,(hl)		;Get it into B.
	ret			;Go build instruction key.


;****************************************************************************
;*
;*	AED180	ED opcode unmapper for HD64180 debugger
;*
;*	Input:	A	Instruction key for ED XX opcode (40H to 9FH)
;*		EDBIAS	Table of biases for 2nd opcodes smaller than 40H
;*
;*	Output:	A	Unmapped 2nd opcode of ED instruction
;*
;*	Description:
;*		This routine encodes instruction key values in the range 40H
;*		to 9FH into 2nd opcodes for ED instructions.
;*
;*		All Z80 opcodes are mapped as they were in the "Z80 only"
;*		release.
;*
;*		The defb and defw pseudo-ops were moved from 6CH and 6DH
;*		to 65H and 66H respectively because of a conflict with
;*		the HD64180-specific MLT HL instruction.
;*
;*		The HD64180-specific OTIM, OTIMR, OTDM and OTDMR instructions
;*		are mapped with a bias of 1 to avoid conflicting with the
;*		OUTI, OTIR, OUTD and OTDR instructions respectively.
;*
;*		The HD64180-specific TST m, TSTIO m, SLP, MLT BC, MLT DE,
;*		MLT HL and MLT SP instructions are mapped with a bias of 0
;*		just as all the other ED opcodes in the 40H to 7FH range.
;*
;*		The 22 HD64180-specific ED instructions less than 40H are
;*		mapped into the remaining "holes" via the EDBIAS lookup
;*		table.
;*
;****************************************************************************

aed180:	push	hl		;Save registers.
	push	de
	push	bc

	ld	d,a		;Save instruction key.

	ld	bc,40h
aed05:	dec	c		;Decrement EDBIAS index.
	jp	m,aed10		;If negative, opcode not 00h to 3fh.
	ld	hl,edbias	;Point HL to ED biases for opcodes < 3fh.
	add	hl,bc		;Point HL to bias value for opcode in C.
	ld	a,(hl)		;Get bias.
	add	a,c		;Add opcode.
	cp	d		;Does it match instruction key?
	jr	nz,aed05	;If not, check next bias.
	ld	a,c		;Else, set A to opcode value.
	jr	aed30		;Done.

aed10:	ld	a,d		;Restore instruction key.
	cp	80h		;Is it less than 80h?
	jr	c,aed30		;If so, instruction key = opcode, done.

	cp	84h		;OTIM?
	jr	z,aed20
	cp	8ch		;OTDM?
	jr	z,aed20
	cp	94h		;OTIMR?
	jr	z,aed20
	cp	9ch		;OTDMR?
	jr	nz,aed25
aed20:	dec	a		;Remove bias of 1.
	jr	aed30		;Done.

aed25:	add	a,20h		;Remove bias of 0e0h.

aed30:	pop	bc		;Restore registers.
	pop	de
	pop	hl
	ret

	endif


write:	push	bc
	push	hl
	ld	hl,nzasm	;address of end of disassembly buffer
	and	a
	sbc	hl,de
	jr	nz,wrt10	;not end of buffer
	ld	de,zasmbf	;need to rewind buffer pointer
	ld	a,(dwrite)	;test write to disk flag
	and	a
	call	nz,bwrite	;nz - writing to disk
wrt10:	pop	hl
	pop	bc
	ret



bwrite:	push	bc		;bdos write routine
	push	de
	push	hl
	ld	c,26		;set dma address
	call	bdos
	ld	de,fcb
	ld	c,21
	call	bdos		;write buffer
				;+ eg 3.3.7b
	ld	c,26		;+ "Set DMA" function
	ld	de,80h		;+ Restore default DMA for user program
	call	bdos		;+
	pop	hl
	pop	de
	pop	bc
	ret



bldf:	call	lfcb		;initialize fcb
	ret	nz		;error - invalid file name
	call	lopn
	jr	z,bldf00	;no file - create one
	ld	de,fcb
	ld	c,19		;file exists - delete it
	call	bdos
bldf00:	ld	de,fcb		;create new file
	ld	c,22
	call	bdos		;if no file create one
	xor	a
	ret

	page

opn100:	ld	hl,(zasmpc)
	inc	hl
	ld	a,(hl)		;fetch relative displacement
	ld	c,a
	inc	c
	add	a,a		;test sign for displacement direction
	ld	b,0
	jr	nc,opn105
	dec	b		;produce zero for forward - ff for back
opn105:	add	hl,bc		;adjust pc
	ex	de,hl		;de - instruction ptr   hl - buffer
	call	fadr
	call	z,xsym
	jp	z,opn040	;symbol found
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
	jr	nz,opn210	;nz - not ix or iy
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
	call	zhex20		;86 the leading zero and trailing h
	jp	opn020
opn220:	call	zhex		;do hex to ascii conversion
	ld	(hl),'H'	;following 8 bit hex byte
	inc	hl
	jp	opn020

opn300:	call	zmqf
	jr	c,opn315	;c - this is defw
	call	zndx
	ex	de,hl		;de - buffer   hl - instruction pointer
	jr	nz,opn310	;nz - not ix or iy
	inc	hl
opn310:	inc	hl
opn315:	ld	a,(hl)		;fetch lo order 16 bit operand
	inc	hl
	ld	h,(hl)		;hi order
	ld	l,a
	ex	de,hl		;de - 16 bit operand   hl - buffer
	call	fadr
	call	z,xsym
	jp	z,opn020	;symbol found
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
	jr	nz,opn410	;nz - not ix or iy instruction
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
	xor	006		;from the movie of the same name
	jp	nz,opn010	;nz - not hl or ix or iy
	ld	a,(zasmpc)
	xor	e		;test if pc was incremented
	ld	(hl),'('	;set leading paren
	inc	hl
	ld	b,080h		;set sign bit - closed paren required
	ex	de,hl		;de - buffer
	jp	z,opn012



opn600:
	call	zndx		;determine if ix or iy
	jr	z,opn605	;z - must be ix of iy
	ld	a,80h
	and	b
	jp	opn010
opn605:
				;+Fix display of IX/IY when upper case is set
	push	af		;+Adapted from patch by George Havach (3.5.7)
	ld	c,0DFh		;+Upper case mask
	ld	a,(case)	;+See if upper or lower case
	or	a		;+
	jr	z,opn606	;+Skip if upper case, otherwise
	ld	c,0FFh		;+ adjust mask
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
	cp	0e9h		;test for jp (ix) or jp (iy)
	jp	z,opn020	;output closed paren
	inc	de
	ld	a,(de)		;fetch displacement byte
	cp	80h		;test sign
opn610:	ld	(hl),'+'	;assume forward
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
	jp	opn020		;output closed paren




opn700:	ld	hl,(zasmpc)
	ld	a,(hl)		;fetch restart instruction
	ex	de,hl		;de - buffer   hl instruction pointer
	and	38h
	call	zhex		;convert restart number to ascii
	ld	(hl),'H'
	jp	opn020



opn800:	call	zndx
	jr	nz,opn810	;nz - not ddcb or fdcb instruction
	inc	de
	inc	de
	inc	de		;
	ld	a,(de)		;byte 4 of ix or iy bit instruction
	jr	opn820
opn810:	cp	10h		;weed out interrupt mode instructions
	ld	a,(de)		;second byte of instruction regardless
	jr	nz,opn820	;nz - cb bit instruction
	xor	046h		;
	jr	z,opn830	;z - interrupt mode zero
	sub	8
opn820:	rra
	rra
	rra
	and	07		;leave only bit number
opn830:	call	zhex20		;convert to ascii
	jp	opn030

	page
;******************************************************************************
;*
;*		     Disassembler utility subroutines
;*
;*	zndx:	  Determines if FD DD ED or CB instruction
;*		  Caller uses returned values on an individual basis
;*
;*		   z  -	DD FD
;*		  nz  -	neither of the above
;*		  current instruction pointer bumped if CB or ED instruction
;*
;*	zhex:	  Convert to byte in the accumulator to ascii with leading zero
;*		  store in buffer
;*		  d - reg destroyed
;*
;*	zhex10:	  no leading zero permitted
;*	zhex20:	  convert lo order nibble only
;*
;******************************************************************************

zndx:	ld	hl,(zasmpc)	;fetch current instruction pointer
	ex	de,hl		;de - instruction pointer   hl - buffer
	ld	a,(de)
; 	add	a,-0fdh		;iy check
	add	a,03h		;iy check
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
	and	a		;ensure nz set
	cpl
	ret



zhex:	ld	d,a
	cp	0a0h		;test byte to convert
	jr	c,zhex00	;starts with decimal digit - 86 the lead zero
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
	ld	(hl),quote	;defb - quoted character
	inc	hl
	or	80h		;hi bit on - no case conversion for this guy
	ld	(hl),a
	inc	hl
	ld	(hl),quote
	cp	a
	ret



fadr:	push	bc
	push	hl
	ld	hl,(06)		;fetch top of tpa - start of symbol table
	ld	bc,(maxlen)
	add	hl,bc		;point to start of symbol name
	inc	hl
fadr00:	ld	a,(hl)		;first byte of symbol name
	dec	a		;check validity
	jp	m,fadr30	;end of table
	add	hl,bc
	ld	a,(hl)		;fetch hi order address from table
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

	page
;******************************************************************************
;*
;*	bcde:  query user for 3 arguments: source address
;*					   destination address
;*					   byte count
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
;*			  - destination address < source
;*
;******************************************************************************

bcde:	call	iedtbc
	ret	m		;no input is treated as error
	call	iarg		;read in starting block address
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

	page
;****************************************************************************
;*
;*	CONSOLE I/O PRIMITIVES
;*
;*	"logical" i/o primitives:
;*
;*		ttyq  - console status
;*		ttyi  - keyboard Input
;*		ttyo  - console Output
;*		xycp  - cursor positioner
;*
;*	"physical" i/o primitives:
;*
;*		mttyq  - main console status
;*		mttyi  - main keyboard Input
;*		mttyo  - main console Output
;*		mxyprg - main cursor positioner
;*
;*		attyq  - auxiliary console status
;*		attyi  - auxiliary keyboard Input
;*		attyo  - auxiliary console Output
;*		axyprg - auxiliary cursor positioner
;*
;****************************************************************************

; Logical console status routine

ttyq:	push	bc
	push	de
	push	hl
	ld	hl,tqret
	push	hl

    if	auxprt
	ld	a,(auxon)
	or	a
	jr	z,mttyq

; Auxiliary physical console status routine
; (Default is SB180's serial port 0)

    if	ASMB
attyq:
    else
attyq::
    endif
	xor	a
	ld	b,a
	in	a,(4)
	and	80h
	jr	nz,attyi
	ret
     if not compact
	org	attyq+32
     endif
    endif

; Main physical console status routine
; (Default is CP/M console device)

    if	ASMB
mttyq:
    else
mttyq::
    endif
	ld	c,11
	call	bdos
	and	a
	ld	c,6
	ld	e,0FFH
	call	nz,bdos
	and	7FH
	ret
    if not compact
	org	mttyq+32
    endif

; Logical keyboard input routine

ttyi:	push	bc
	push	de
	push	hl
	ld	hl,tiret
	push	hl

    if	auxprt
	ld	a,(auxon)
	or	a
	jr	z,mttyi

; Auxiliary physical keyboard input routine
; (Default is CP/M reader input device)

    if ASMB
attyi:
    else
attyi::
    endif
	ld	c,3
	call	bdos
	and	7FH
	jr	z,attyi
	ret
     if not compact
	org	attyi+32
     endif
    endif

; Main physical keyboard input routine
; (Default is CP/M console device)

    if	ASMB
mttyi:
    else
mttyi::
    endif
	ld	c,6
	ld	e,0FFH
	call	bdos
	and	7FH
	jr	z,mttyi
	ret
    if not compact
	org	mttyi+32
    endif

; Logical console output routine

ttyo:	push	bc
	push	de
	push	hl
	push	af
	ld	hl,toret
	push	hl

ttyo00:
	and	7Fh		;+ eg 3.3.1 (but this instruction will be
				;            patched during initialisation
				;            according to value stored at
				;            coMask: [3.4])

    if	auxprt
	ld	e,a
	ld	a,(auxon)
	or	a
	ld	a,e
	jr	z,mttyo

; Auxiliary physical console output routine
; (Default is CP/M punch output device)

    if	ASMB
attyo:
    else
attyo::
    endif
	ld	c,4
	ld	e,a
	call	bdos
	ret
     if not compact
	org	attyo+32
     endif
    endif

; Main physical console output routine
; (Default is CP/M console device)

    if	ASMB
mttyo:
    else
mttyo::
    endif
	ld	e,a
	if	jterm		;My terminal uses tab as cursor position
	ld	c,6		;lead-in and I don't want the bdos to expand
	else			;the tab to a string of spaces.
	ld	c,2
	endif
	call	bdos
	ret
    if not compact
	org	mttyo+32
    endif

; Home cursor routine

home:	ld	bc,00

; Logical cursor position routine

xycp:	push	bc
	push	de
	push	hl
	ld	hl,xyret
	push	hl

    if	auxprt
	ld	a,(auxon)
	or	a
	jp	z,mxyprg

; Auxiliary physical cursor position routine
; (Uses AXYSTR, AROWB4, AROW and ACOL for configuration)

    if	ASMB
axyprg:
    else
axyprg::
    endif
	ld	hl,axystr
	ld	a,(arow)	;Add in row offset
	add	a,b
	ld	b,a		;Save row Character
	ld	a,(acol)	;Add column bias
	add	a,c
	ld	c,a
	ld	e,(hl)		;Number of Chars in cursor Addressing string
axypr0:
	inc	hl
	ld	a,(hl)
	call	ttyo
	dec	e
	jr	nz,axypr0
	ld	a,(arowb4)
	and	a
	jr	nz,axypr1
	ld	a,b
	ld	b,c
	ld	c,a
axypr1:
	ld	a,b
	call	ttyo
	ld	a,c
	call	ttyo
	ret
     if not compact
	org	axyprg+128
     endif
    endif

; Main physical cursor position routine
; (Uses MXYSTR, MROWB4, MROW and MCOL for configuration)
;
; Two versions are supplied and either can be selected during
; assembly according to the setting of ATERM.
;
;	aterm	equ	TRUE		Selects ANSI screen driver
;	aterm	equ	FALSE		Selects default screen driver
;
; In either  case, this routine is invoked with the row in B and
; the column in C.

    if	ASMB
mxyprg:
    else
mxyprg::
    endif

    if aterm

;	ANSI screen driver - jrs - 27 May 87
;	Tested and corrected 29 Dec 88 - jrs

	inc	b		;Add 1 to row and column
	inc	c
	push	bc

	ld	a,1Bh		;Send ESC
	call	ttyo
	ld	a,'['		;Send [
	call	ttyo
	pop	bc		;Send row (Y) coordinate
	push	bc
	ld	a,b
	call	xycp00
	ld	a,';'		;Send ;
	call	ttyo
	pop	bc		;Send column (X) coordinate
	ld	a,c
	call	xycp00
	ld	a,'H'		;Send H
	call	ttyo

	ret

xycp00:
	ex	af,af'
	xor	a
	ex	af,af'
xycp10:
	ex	af,af'
	inc	a
	ex	af,af'
	sub	10
	jr	nc,xycp10
	ex	af,af'
	dec	a
	jr	z,xycp20
	add	a,'0'
	call	ttyo
xycp20:
	ex	af,af'
	add	a,'0'+10
	call	ttyo
	ret

    else

;	Default screen driver - ras
	inc	b		; ZDS origin 1,1
; 	inc	c
	ld	hl,mxystr
	ld	a,(mrow)	;Add in row offset
	add	a,b
	ld	b,a		;Save row character
	ld	a,(mcol)	;Add column bias
	add	a,c
	ld	c,a
	ld	e,(hl)		;Number of chars in cursor addressing string
mxypr0:
	inc	hl
	ld	a,(hl)
	call	ttyo
	dec	e
	jr	nz,mxypr0
	ld	a,(mrowb4)
	and	a
	jr	nz,mxypr1
	ld	a,b
	ld	b,c
	ld	c,a
mxypr1:
	ld	a,b
	call	ttyo
	ld	a,c
	call	ttyo
; 	ld	a,0DH		;ZDS lead out
; 	call	ttyo
	ret
     if not compact		;..then leave room for patching
	org	mxyprg+128	;  the object code
     endif

    endif

;	Return routines for ttyo, ttyi, ttyq and xycp
toret:	pop	af
tiret:
tqret:
xyret:	pop	hl
	pop	de
	pop	bc
	ret


;****************************************************************************
;*
;*	CONSOLE I/O UTILITIES
;*
;*	Console Input utilities:
;*
;*		inchar - Input Character processing
;*			 control Characters echoed with ^
;*
;*	Console Output utilities:
;*
;*		crlf   - Output carriage return/line feed
;*		cret   - Output carriage return only
;*		space1  - Output space
;*		spaces - Output Number of spaces in C
;*		outhex - Output hex Byte in a
;*		othxsp - Output hex Byte in a followed by space
;*		outadr - Output 16 bit hex value in hl followed
;*		           by space - hl preserved
;*		print  - Output string - Address in de
;*			   string terminated by null
;*		printb - Output string - Address in hl
;*			   Byte count in c; End at First null
;*
;****************************************************************************

inchar:	call	ttyi
	cp	ctlc
	jp	z,00
	cp	cr
	ret	z
	cp	tab
	ret	z
	cp	lf
	ret	z
	cp	bs
	ret	z
	cp	del
	ret	z
	cp	ctlx
	ret	z
	cp	' '
	jp	nc,ttyo
	push	af
	ld	a,'^'
	call	ttyo
	pop	af
	xor	40h
	call	ttyo
	xor	40h
	ret


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

	page
crlf:	ld	a,lf
	call	ttyo
cret:	ld	a,cr
	jp	ttyo

othxsp:	call	outhex

space1:	ld	a,' '
	jp	ttyo

space5:	ld	c,5

spaces:	call	space1
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
	jr	space1



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
	page
ilin:	push	bc
	push	de
	ld	b,inbfsz
	ld	c,0
	call	din
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



din:	call	iedt
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
	page
parg:	call	prsr		;extract next argument
	ret	nz		;parse error
	ld	a,(quoflg)	;test for ascii literal
	and	a
	jr	z,parg10	;quote character not found
	xor	a
	or	b		;test for balanced quotes
	ret	m		;error - unbalanced quotes
	ld	a,(de)		;first character of parse buffer
	sub	quote
	jr	nz,parg50	;invalid literal string but may be expression
				;involving a literal
	ld	l,b		;l - character count of parse buffer
	ld	h,a		;clear
	add	hl,de		;
	dec	hl		;hl - pointer to last char in parse buffer
	ld	a,(hl)		;
	sub	quote		;ensure literal string ends with quote
	jr 	nz,parg50
	ld	(hl),a		;clear trailing quote
	ld	c,b		;c - character count of parse buffer
	ld	b,a		;clear
	dec	c		;subtract the quote characters from the count
	dec	c
	dec	c		;extra dec set error flag nz for '' string
	ret	m		;inform caller of null string
	inc	c		;c - actual string length
	ld	a,c		;spare copy
	inc	de		;point to second character of parse buffer
	ld	hl,(argbpt)	;caller wants evaluated arg stored here
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
	jr	c,parg60	;sign bit reset - 16 bit register pair
parg50:	ld	hl,00
	ld	b,l
	ld	de,prsbf	;reinit starting address of parse buffer
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
	page
outbyt:	ld	b,a		;save spare copy
	call	othxsp		;hex - display
	call	space1
	ld	a,b		;display byte in ascii
	call	asci		;display ascii equivalent
	ld	c,3
	jp	spaces		;solicit input three spaces right

dbyte:	call	istr
	ld	a,(inbfnc)	;number of chars in input buffer
	dec	a		;test for input buffer count of zero
	inc	de		;assume zero - examine next
	ret	m		;no input means examine next
	dec	de		;incorrect assumption
	ld	a,(inbf)	;check first char of input buffer
	cp	'.'
	ret	z		;period ends command
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
byte15:	call	irsm		;resume input from console
	ret	z		;no errors on input
	ld	a,(inbfnc)	;check number of chars input
	and	a
	jr	z,dbyte		;none - user hit control x or backspaced to
				;beginning of buffer
byte30:	call	e???
	scf
	sbc	a,a		;set nz - no replacement
	ret

	page
;******************************************************************************
;*
;*	BDOS function 10 replacement to make romming this program easier since
;*	only two console i/o routines (ttyi and ttyo) are required. This
;*	routine supports backspace, line delete, and tab expansion.
;*
;*	All input stored in input buffer inbf.
;*
;*
;*	iedtbc:	Solicit console for new input and initialize b and c registers
;*		for max size and input and no special line terminator.
;*
;*
;*	iedt:	Solicit console for new input using non-default byte count for
;*		buffer or non-standard terminator.
;*
;*		called:	 b - max number of characters to receive
;*			 c - special terminator other than carriage return
;*
;*
;*	iedt00:	Resume input - used by routines which call iedt with a buffer
;*		count of 1 to check for special character as the first char
;*		received (such as exam looking for period).
;*
;*		called:	 b - max number of characters to receive
;*			 c - special terminator other than carriage return
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
	ld	(argbc),a	;init number of arguments tally
	ld	hl,argbf
	ld	(argbpt),hl	;init pointer to start of buffer
iedt03:	ld	hl,inbf		;start of input buffer
	ld	(quoflg),a
iedt05:	call	inchar		;read char from console
	ld	(trmntr),a	;assume line terminator until proven otherwise
	cp	cr		;end of line?
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
iedt25:	call	space1		;space out until char position mod 8 = zero
	ld	(hl),a		;store space in buffer as we expand tab
	inc	hl
	inc	d
	ld	a,7
	and	d
	jr	nz,iedt25
	ld	(hl),0		;set end of line null
	jr	iedt70
iedt35:	ld	e,1		;assume one backspace required
	cp	bs
	jr	z,iedt40	;z - correct assumption
	cp	del
	jr	z,iedt40
	cp	ctlx		;erase line?
	jr	nz,iedt60	;nz - process normal input character

	xor	a		;+ eg 3.3.8b
	or	d		;+ See if ^X with empty buffer
	jp	z,z8e		;+ Abandon current command if so

	ld	e,d		;backspace count is number of chars in buffer

	jr	iedt50		;+

iedt40:	xor	a		;test if already at beginning of buffer
	or	d
	jr	z,iedt05	;z - at beginning so leave cursor as is
iedt50:	call	bksp		;transmit bs - space - bs string
	dec	d		;sub one from input buffer count
	dec	hl		;rewind buffer pointer on notch
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
	ld	a,(strngf)	;string function flag on?
	and	a
	jr	z,iedt05	;off - get next input char
	xor	a		;did we backspace to start of buffer?
	or	d		;test via character count
	jp	nz,iedt05	;not rewound all the way
	ld	(inbfnc),a	;set a zero byte count so caller knows
	dec	d		;something is fishy
	ret
iedt60:	ld	(hl),a		;store char in inbf
	inc	hl		;bump inbf pointer
	ld	(hl),0		;end of line
	inc	d		;bump number of chars in buffer
iedt70:	ld	a,d		;current size
	sub	b		;versus max size requested by caller
	jp	c,iedt05	;more room in buffer
iedt90:	ld	hl,inbfnc	;store number of characters received ala
				;bdos function 10
	ld	(hl),d
	inc	hl		;point to first char in buffer
	dec	d		;set m flag if length is zero
	ret			;sayonara



bksp:	call	bksp00
	call	space1
bksp00:	ld	a,bs
	jp	ttyo



asci:	and	7fh		;Convert contents of accumulator to ascii
	if	hazeltine	;Hazeltine terminal?
	cp	tilde		;	check for tilde or del
	jr	nc,asci00	;	yes - translate to '.'
	else			;Non-hazeltine terminal
	cp	del		;	check for del
	jr	z,asci00	;	yes - translate to '.'
	endif			;Any terminal - other characters
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




nrel:					;end of relocatable code
	page

zopnm:
	defb	'HL'
	defb	'A '
	defb	'H '
	defb	'L '
	defb	'D '
	defb	'E '
	defb	'B '
	defb	'C '
ix.:	defb	'IX'
	defb	'SP'
	defb	'P '
	defb	'R '
	defb	'I '
	defb	'AF'
	defb	'BC'
	defb	'DE'
iy.:	defb	'IY'
	defb	'Z '
	defb	'NC'
	defb	'NZ'
	defb	'PE'
	defb	'PO'
	defb	'M '
	defb	'PC'

ix..	equ	(ix.-zopnm)/2		;relative position - ix
iy..	equ	(iy.-zopnm)/2		;		     iy

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

zopjtl	equ	($-zoprjt)/2		;length of operand jump table

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
	defw	pswDsp			; p
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
	defw	kdmp			; k
	defw	writ			; w
	defw	cuser			; >
	defw	qeval			; ?
;	defw	gadr			; #
	if	auxprt
	defw	term			; t
	endif
cmd:
	if	auxprt
	defb	'T'
	endif
;	defb	'#?>WKXQDLOSHFCB'
	defb	'?>WKXQDLOSHFCB'
	defb	'PVMYGREZJNUAI'
ncmd	equ	$-cmd		;number of commands


;*****************************
;*	Message Strings      *
;*****************************

bpemsg:
	defb	'*ERROR*'
bpmsg:
	defb	'*BP* @ '
	defb	0
prompt:
	defb	'*',' ',bs,0

mrrow:	defb	'=','>'		;backspaces taken out
	defb	00

m????:	defb	'??'
m??:	defb	' ??  '


asmflg:	defb	' '
	defb	0

lcmd:	defb	' '
em???:	defb	' ??'
	defb	0

mldg:
	defb	'Loading: '
	defb	0

mfilnf:
	defb	'File not Found'
	defb	cr,lf,00

mlodm:
	defb	'Loaded:  '
	defb	0
mlodpg:

	defb	'Pages:   '
	defb	0

msntx:
	defb	'Syntax Error'
	defb	cr,lf,0

mmem??:	defb	'Out of Memory'
	defb	0

mcntu:	defb	' - Continue? '
	defb	0

mireg:
	defb	'IR: '
	defb	0
	page

	if	auxprt
mterm:	defb	'  Main'
	defb	0

axterm:	defb	'  Auxiliary'
matail:	defb	' terminal enabled...'
	defb	0
	endif


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

z803sl	equ	$-z803s			;number of call instructions

z803c:	defb	0c3h
	defb	0dah,0d2h,0cah,0c2h
	defb	0eah,0e2h,0fah,0f2h

z803l	equ	$-z803			;number of 3 byte instructions
z803cl	equ	$-z803s			;number of 3 byte pc mod instructions

z80ed:	defb	043h,04bh,053h
	defb	05bh,073h,07bh

z80edl	equ	$-z80ed			;number of 4 byte ED instructions

z80rl	equ	$-z80r			;number of relocatable z80 instructions

	if	h64180

z8ed3:	defb	000h,008h,010h,018h
	defb	020h,028h,038h,001h
	defb	009h,011h,019h,021h
	defb	029h,039h,064h,074h

z8ed3l	equ	$-z8ed3			;number of 3 byte ED instructions

edbias:	defb	04Eh,053h,09Dh,09Ch	;ED 00 to 03
	defb	051h,09Ah,099h,098h	;ED 04 to 07
	defb	055h,05Ah,095h,094h	;ED 08 to 0B
	defb	05Fh,092h,091h,090h	;ED 0C to 0F
	defb	05Dh,064h,08Dh,08Ch	;ED 10 to 13
	defb	063h,08Ah,089h,088h	;ED 14 to 17
	defb	065h,065h,085h,084h	;ED 18 to 1B
	defb	063h,082h,081h,080h	;ED 1C to 1F
	defb	065h,065h,07Dh,07Ch	;ED 20 to 23
	defb	063h,07Ah,079h,078h	;ED 24 to 27
	defb	065h,065h,075h,074h	;ED 28 to 2B
	defb	063h,072h,071h,070h	;ED 2C to 2F
	defb	06Fh,06Eh,06Dh,06Ch	;ED 30 to 33
	defb	061h,06Ah,069h,068h	;ED 34 to 37
	defb	05Eh,05Eh,065h,064h	;ED 38 to 3B
	defb	061h,062h,061h,060h	;ED 3C to 3F

edbad:	defb	04Eh,054h,055h,05Dh
	defb	065h,066h,06Dh,06Eh
	defb	070h,071h,075h,077h
	defb	07Dh,07Eh,07Fh

edbadl	equ	$-edbad			;# of illegal ED opcodes in 40h to 7Fh

	endif

z80f3:
	defb	034h,035h,046h,04eh
	defb	056h,05eh,066h,06eh
	defb	070h,071h,072h,073h
	defb	074h,075h,077h,07eh
	defb	086h,08eh,096h,09eh
	defb	0a6h,0aeh,0b6h,0beh

z80f3l	equ	$-z80f3

	org	($+3) and 0fffch

	if	h64180

	page
;***********************************************************************
;*
;*	Table of opcodes for HD64180 support
;*
;***********************************************************************

zopcpt:
	defb	022H,01CH,01CH,015H	;NOP	LD	LD	INC	00 - 03
	defb	015H,00CH,01CH,031H	;INC	DEC	LD	RLCA	04 - 07
	defb	010H,000H,01CH,00CH	;EX	ADD	LD	DEC	08 - 0B
	defb	015H,00CH,01CH,036H	;INC	DEC	LD	RRCA	0C - 0F
	defb	00EH,01CH,01CH,015H	;DJNZ	LD	LD	INC	10 - 13
	defb	015H,00CH,01CH,02FH	;INC	DEC	LD	RLA	14 - 17
	defb	01BH,000H,01CH,00CH	;JR	ADD	LD	DEC	18 - 1B
	defb	015H,00CH,01CH,034H	;INC	DEC	LD	RRA	1C - 1F
	defb	01BH,01CH,01CH,015H	;JR	LD	LD	INC	20 - 23
	defb	015H,00CH,01CH,00BH	;INC	DEC	LD	DAA	24 - 27
	defb	01BH,000H,01CH,00CH	;JR	ADD	LD	DEC	28 - 2B
	defb	015H,00CH,01CH,00AH	;INC	DEC	LD	CPL	2C - 2F
	defb	01BH,01CH,01CH,015H	;JR	LD	LD	INC	30 - 33
	defb	015H,00CH,01CH,03AH	;INC	DEC	LD	SCF	34 - 37
	defb	01BH,000H,01CH,00CH	;JR	ADD	LD	DEC	38 - 3B
	defb	015H,00CH,01CH,004H	;INC	DEC	LD	CCF	3C - 3F


	defb	014H,026H,039H,01CH	;IN	OUT	SBC	LD	ED 40
	defb	021H,02DH,013H,01CH	;NEG	RETN	IM	LD
	defb	014H,026H,001H,01CH	;IN	OUT	ADC	LD
	defb	04DH,02CH,048H,01CH	;MLT	RETI	IN0	LD
	defb	014H,026H,039H,01CH	;IN	OUT	SBC	LD
	defb	049H,04AH,013H,01CH	;OUT0	TST	IM	LD
	defb	014H,026H,001H,01CH	;IN	OUT	ADC	LD
	defb	04DH,048H,013H,01CH	;MLT	IN0	IM	LD
	defb	014H,026H,039H,049H	;IN	OUT	SBC	OUT0
	defb	04AH,044H,045H,037H	;TST	defb*	defw*	RRD
	defb	014H,026H,001H,04AH	;IN	OUT	ADC	TST
	defb	04DH,048H,046H,032H	;MLT	IN0	DDB*	RLD
	defb	043H,047H,039H,01CH	;ORG*	equ*	SBC	LD	ED 70
	defb	04BH,049H,04CH,04AH	;TSTIO	OUT0	SLP	TST
	defb	014H,026H,001H,01CH	;IN	OUT	ADC	LD
	defb	04DH,048H,049H,04AH	;MLT	IN0	OUT0	TST	ED 7F


	defb	01FH,008H,018H,028H	;LDI	CPI	INI	OUTI
	defb	04EH,048H,049H,04AH	;OTIM	IN0	OUT0	TST
	defb	01DH,006H,016H,027H	;LDD	CPD	IND	OUTD
	defb	04FH,048H,049H,04AH	;OTDM	IN0	OUT0	TST
	defb	020H,009H,019H,025H	;LDIR	CPIR	INIR	OTIR
	defb	050H,04AH,048H,049H	;OTIMR	TST	IN0	OUT0
	defb	01EH,007H,017H,024H	;LDDR	CPDR	INDR	OTDR
	defb	051H,04AH,022H,044H	;OTDMR	TST	....	defb*


	defb	02BH,029H,01AH,01AH	;RET	POP	JP	JP	C0 - C3
	defb	003H,02AH,000H,038H	;CALL	PUSH	ADD	RST	C4 - C7
	defb	02BH,02BH,01AH,022H	;RET	RET	JP	...	C8 - CB
	defb	003H,003H,001H,038H	;CALL	CALL	ADC	RST	CC - CF
	defb	02BH,029H,01AH,026H	;RET	POP	JP	OUT	D0 - D3
	defb	003H,02AH,03EH,038H	;CALL	PUSH	SUB	RST	D4 - D7
	defb	02BH,011H,01AH,014H	;RET	EXX	JP	IN	D8 - DB
	defb	003H,022H,039H,038H	;CALL	...	SBC	RST	DC - DF
	defb	02BH,029H,01AH,010H	;RET	POP	JP	EX	E0 - E3
	defb	003H,02AH,002H,038H	;CALL	PUSH	AND	RST	E4 - E7
	defb	02BH,01AH,01AH,010H	;RET	JP	JP	EX	E8 - EB
	defb	003H,022H,03FH,038H	;CALL	...	XOR	RST	EC - EF
	defb	02BH,029H,01AH,00DH	;RET	POP	JP	DI	F0 - F3
	defb	003H,02AH,023H,038H	;CALL	PUSH	OR	RST	F4 - F7
	defb	02BH,01CH,01AH,00FH	;RET	LD	JP	EI	F8 - FB
	defb	003H,022H,005H,038H	;CALL	...	CP	RST	FC - FF

	defb	000H,001H,03EH,039H	;ADD	ADC	SUB	SBC
	defb	002H,03FH,023H,005H	;AND	XOR	OR	CP


	defb	030H,035H,02EH,033H	;RLC	RRC	RL	RR
	defb	03BH,03CH,022H,03DH	;SLA	SRA	...	SRL
	defb	022H,040H,041H,042H	;...	BIT	RES	SET


	defb	022H,022H,022H,012H	;...	...	...	HALT


	defb	01CH,01CH,01CH,01CH	;LD	LD	LD	LD
	defb	01CH,01CH,01CH,01CH	;LD	LD	LD	LD

	page
;****************************************************************************
;*
;*	Table of first operands for HD64180 support
;*
;****************************************************************************

zopnd1:
	defb	0FFH,00EH,08EH,00EH	;00 - 03
	defb	006H,006H,006H,0FFH	;04 - 07
	defb	00DH,018H,001H,00EH	;08 - 0B
	defb	007H,007H,007H,0FFH	;0C - 0F
	defb	01BH,00FH,08FH,00FH	;10 - 13
	defb	004H,004H,004H,0FFH	;14 - 17
	defb	01BH,018H,001H,00FH	;18 - 1B
	defb	005H,005H,005H,0FFH	;1C - 1F
	defb	013H,018H,09DH,018H	;20 - 23
	defb	002H,002H,002H,0FFH	;24 - 27
	defb	011H,018H,018H,018H	;28 - 2B
	defb	003H,003H,003H,0FFH	;2C - 2F
	defb	012H,009H,09DH,009H	;30 - 33
	defb	098H,098H,098H,0FFH	;34 - 37
	defb	007H,018H,001H,009H	;38 - 3B
	defb	001H,001H,001H,0FFH	;3C - 3F

	defb	006H,087H,000H,09DH	;40 - 43
	defb	0FFH,0FFH,01FH,00CH	;44 - 47
	defb	007H,087H,000H,00EH	;48 - 4B
	defb	00EH,0FFH,006H,00BH	;4C - 4F
	defb	004H,087H,000H,09DH	;50 - 53
	defb	09CH,006H,01FH,001H	;54 - 57
	defb	005H,087H,000H,00FH	;58 - 5B
	defb	00FH,007H,01FH,001H	;5C - 5F
	defb	002H,087H,000H,09CH	;60 - 63
	defb	01CH,01CH,01DH,0FFH	;64 - 67	      defb  defw
	defb	003H,087H,000H,007H	;68 - 6B
	defb	000H,004H,01DH,0FFH	;6C - 6F		    DDB
	defb	01DH,01DH,000H,09DH	;70 - 73	ORG   equ
	defb	01CH,09CH,0FFH,004H	;74 - 77
	defb	001H,087H,000H,009H	;78 - 7B
	defb	009H,005H,09CH,005H	;7C - 7F

	defb	0FFH,0FFH,0FFH,0FFH	;A0 - A3
	defb	0FFH,002H,09CH,002H	;A4 - A7
	defb	0FFH,0FFH,0FFH,0FFH	;A8 - AB
	defb	0FFH,003H,09CH,003H	;AC - AF
	defb	0FFH,0FFH,0FFH,0FFH	;B0 - B3
	defb	0FFH,080H,001H,09CH	;B4 - B7
	defb	0FFH,0FFH,0FFH,0FFH	;B8 - BB
	defb	0FFH,001H,0FFH,0FFH	;BC - BF

	defb	013H,00EH,013H,01DH	;C0 - C3
	defb	013H,00EH,001H,01EH	;C4 - C7
	defb	011H,0FFH,011H,0FFH	;C8 - CB
	defb	011H,01DH,001H,01EH	;CC - CF
	defb	012H,00FH,012H,09CH	;D0 - D3
	defb	012H,00FH,01CH,01EH	;D4 - D7
	defb	007H,0FFH,007H,001H	;D8 - DB
	defb	007H,0FFH,001H,01EH	;DC - DF
	defb	015H,018H,015H,089H	;E0 - E3
	defb	015H,018H,01CH,01EH	;E4 - E7
	defb	014H,098H,014H,00FH	;E8 - EB
	defb	014H,0FFH,01CH,01EH	;EC - EF
	defb	00AH,00DH,00AH,0FFH	;F0 - F3
	defb	00AH,00DH,01CH,01EH	;F4 - F7
	defb	016H,009H,016H,0FFH	;F8 - FB
	defb	016H,0FFH,01CH,01EH	;FC - FF


	defb	001H,001H,019H,001H	;8 bit logic and arithmetic
	defb	019H,019H,019H,019H	;


	defb	019H,019H,019H,019H	;Shift and rotate
	defb	019H,019H,019H,019H	;
	defb	0FFH,01FH,01FH,01FH	;Bit - res - set

	defb	0FFH,0FFH,0FFH,0FFH	;Filler

	defb	01AH,01AH,01AH,01AH	;8 bit load
	defb	01AH,01AH,01AH,01AH	;

	page
;***********************************************************************
;*
;*	Table of second operands for HD64180 support
;*
;***********************************************************************

zopnd2:
	defb	0FFH,01DH,001H,0FFH	;00 - 03
	defb	0FFH,0FFH,01CH,0FFH	;04 - 07
	defb	00DH,00EH,08EH,0FFH	;08 - 0B
	defb	0FFH,0FFH,01CH,0FFH	;0C - 0F
	defb	0FFH,01DH,001H,0FFH	;10 - 13
	defb	0FFH,0FFH,01CH,0FFH	;14 - 17
	defb	0FFH,00FH,08FH,0FFH	;18 - 1B
	defb	0FFH,0FFH,01CH,0FFH	;1C - 1F
	defb	01BH,01DH,018H,0FFH	;20 - 23
	defb	0FFH,0FFH,01CH,0FFH	;24 - 27
	defb	01BH,018H,09DH,0FFH	;28 - 2B
	defb	0FFH,0FFH,01CH,0FFH	;2C - 2F
	defb	01BH,01DH,001H,0FFH	;30 - 33
	defb	0FFH,0FFH,01CH,0FFH	;34 - 37
	defb	01BH,009H,09DH,0FFH	;38 - 3B
	defb	0FFH,0FFH,01CH,0FFH	;3C - 3F


	defb	087H,006H,00EH,00EH	;40 - 43
	defb	0FFH,0FFH,0FFH,001H	;44 - 47
	defb	087H,007H,00EH,09DH	;48 - 4B
	defb	0FFH,0FFH,09CH,001H	;4C - 4F
	defb	087H,004H,00FH,00FH	;50 - 53
	defb	006H,0FFH,0FFH,00CH	;54 - 57
	defb	087H,005H,00FH,09DH	;58 - 5B
	defb	0FFH,09CH,0FFH,00BH	;5C - 5F
	defb	087H,002H,000H,007H	;60 - 63
	defb	0FFH,0FFH,0FFH,0FFH	;64 - 67
	defb	087H,003H,000H,0FFH	;68 - 6B
	defb	0FFH,09CH,0FFH,0FFH	;6C - 6F
	defb	0FFH,0FFH,009H,009H	;70 - 73
	defb	0FFH,004H,0FFH,0FFH	;74 - 77
	defb	087H,001H,009H,09DH	;78 - 7B
	defb	0FFH,09CH,005H,0FFH	;7C - 7F

	defb	0FFH,0FFH,0FFH,0FFH	;A0 - BF
	defb	0FFH,09CH,002H,0FFH	;A4 - A7
	defb	0FFH,0FFH,0FFH,0FFH	;A8 - AB
	defb	0FFH,09CH,003H,0FFH	;AC - AF
	defb	0FFH,0FFH,0FFH,0FFH	;B0 - B3
	defb	0FFH,0FFH,09CH,001H	;B4 - B7
	defb	0FFH,0FFH,0FFH,0FFH	;B8 - BB
	defb	0FFH,0FFH,00FH,0FFH	;BC - BF

	defb	0FFH,0FFH,01DH,0FFH	;C0 - C3
	defb	01DH,0FFH,01CH,0FFH	;C4 - C7
	defb	0FFH,0FFH,01DH,0FFH	;C8 - CB
	defb	01DH,0FFH,01CH,0FFH	;CC - CF
	defb	0FFH,0FFH,01DH,001H	;D0 - D3
	defb	01DH,0FFH,0FFH,0FFH	;D4 - D7
	defb	0FFH,0FFH,01DH,09CH	;D8 - DB
	defb	01DH,0FFH,01CH,0FFH	;DC - DF
	defb	0FFH,0FFH,01DH,018H	;E0 - E3
	defb	01DH,0FFH,0FFH,0FFH	;E4 - E7
	defb	0FFH,0FFH,01DH,000H	;E8 - EB
	defb	01DH,0FFH,0FFH,0FFH	;EC - EF
	defb	0FFH,0FFH,01DH,0FFH	;F0 - F3
	defb	01DH,0FFH,0FFH,0FFH	;F4 - F7
	defb	0FFH,018H,01DH,0FFH	;F8 - FB
	defb	01DH,0FFH,0FFH,0FFH	;FC - FF

	defb	019H,019H,0FFH,019H	;8 bit logic and arithmetic
	defb	0FFH,0FFH,0FFH,0FFH	;

	defb	0FFH,0FFH,0FFH,0FFH	;Shift and rotate
	defb	0FFH,0FFH,0FFH,0FFH	;
	defb	0FFH,019H,019H,019H	;Bit - res - set

	defb	0FFH,0FFH,0FFH,0FFH

	defb	019H,019H,019H,019H	;8 bit load
	defb	019H,019H,019H,019H

	else

;***********************************************************************
;*
;*	Table of opcodes for Z80 support only
;*
;***********************************************************************

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

	page
;****************************************************************************
;*
;*	Table of first operands for Z80 support only
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
;??18E	defb	0ffh,0ffh,0ffh,0ffh	;bc - bf

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

	page
;***********************************************************************
;*
;*	Table of second operands for Z80 support only
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

	endif

	page

;***********************************************************************
;*
;*			Table of opcode names
;*
;*	Supports 67 Z80 Mnemonics, 5 Pseudo-ops and 10 HD64180 Mnemonics
;*
;*	Three of Hitachi's HD64180 Mnemonics are 5 characters long
;*	(only the Japanese know why) but it was decided to implement
;*	them as 4 characters for 18E as follows:
;*
;*			 HITACHI |   18E
;*			---------+--------
;*			 TSTIO   |   TSIO
;*			 OTIMR   |   OIMR
;*			 OTDMR   |   ODMR
;*
;*	The management sincerely hopes that this little exercise in
;*	poetic license will not inconvenience anyone in the least!!
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

	if	h64180
	defb	'IN0 OUT0TST TSIO'
	defb	'SLP MLT OTIMOTDM'
	defb	'OIMRODMR'
	endif


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

symflg:	defb	0ffh		;symbol table flag   00 - table present
				;		     ff - no table

bsiz:				;dump block size storage
bsizlo:	defb	0		;     lo order
bsizhi:	defb	1		;     hi order
blkptr:	defw	100h		;dump block address

loadb:	defw    100h		;z8e load bias for lldr command
loadn:	defw	00		;end of load address

asmbpc:				;next pc location for assembly
zasmpc:	defw	100h		;next pc location for disassemble
				;default at load time: start of tpa
zasmfl:	defw	00		;first disassembled address on jdbg screen


from:
oprn01:
rlbias:
lines:
exampt:
endw:
zasmnx:	defb	0		;address of next instruction to disassemble
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
wflag:	defb	0ffh		;trace subroutine flag: nz - trace subs
				;			 z - no trace

nstep:
nstepl:	defb	0
nsteph:	defb	0

sbps:	defb	0		;number of step breakpoints
bps:	defb	0		;number of normal breakpoints

zmflag:	defb	0
zasmf:	defb	0
execbf:				;execute buffer for relocated code
jlines:
parenf:
nument:	defb	0		;number of digits entered
delim:	defb	0		;argument delimeter character
	defb	0
base10:	defb	0
jmp2jp:	defb	0
jmp2:	defb	0
dwrite:
cflag:	defb	0

ikey:
zasmkv:
zjmp:	defb	0
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

    if	ASMB
maxlen:
    else
maxlen::
    endif
	defw	14

maxlin:	defw	62

fwndow:	defb	00

nlmask:	defb	00

    if	ASMB
case:
    else
case::
    endif
	defb	0ffh		;flag to indicate case of output
				;nz - lower   z - upper

jstepf:	defb	0ffh		;00 -   screen is intact, if user wants J
				;       single step no need to repaint screen,
				;       just move arrow.
				;01   - user wants single-step J command
				;else - J screen corrupted by non-J command

lastro:	defb	03


;************************************************************************
;*	Configuration bytes for user's main terminal                    *
;*	(Default is for Wyse, Televideo, Soroc... terminals)            *
;************************************************************************

; Row before column flag

    if	ASMB
mrowb4:
    else
mrowb4::
    endif
    if jterm
	defb	0		;my terminal uses xy addressing
    else
        defb    0		;ZDS col,row
    endif

; Row offset value

    if	ASMB
mrow:
    else
mrow::
    endif
    if jterm				;my terminal uses no bias for
	defb	0			;cursor coordinates
    else
	defb	' '			;bias for most other terminals
    endif

; Col offset value

    if	ASMB
mcol:
    else
mcol::
    endif
    if jterm				;see above
	defb	0
    else
	defb	' '
    endif

; Cursor control string

    if	ASMB
mxystr:
    else
mxystr::
    endif
    if jterm
	defb	1,9		;jrs special (Datapoint 8227)
    else
    if aterm
    	defb	4,ESC,'[2J'
    else
	defb	1,1bh,0		;NeZ80 ZDS
	defb	0,0,0,0,0,0,0,0
    endif
    endif


	if	auxprt
;************************************************************************
;*	Configuration bytes for user's auxiliary terminal		*
;*	(Default is for DEC VT52)					*
;************************************************************************

; Row before Column flag

    if	ASMB
arowb4:
    else
arowb4::
    endif
	defb	1

; Row offset value

    if	ASMB
arow:
    else
arow::
    endif
	defb	' '

; Col offset value

    if	ASMB
acol:
    else
acol::
    endif
	defb	' '

; Cursor control string

    if	ASMB
axystr:
    else
axystr::
    endif
	defb	2,1bh,'Y'
	defb	0,0,0,0,0,0,0,0

auxon:	defb	false		;false = main terminal enabled (default)
				;true = auxiliary terminal enabled (T command)

	endif


wnwtab:	defw	0
wnwsiz:	defw	0

port:	defw	0

brktbl:	defs	(maxbp+2)*3
psctbl:	defs	maxbp*2


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
fcbext	equ	fcbtyp+3	;current extent number
nfcb	equ	$		;last byte of fcb plus one

gpbsiz	equ	164		;size of general purpose buffer

symbuf:
objbuf:				;object code buffer
; 	rept	gpbsiz
	defs	gpbsiz
; 	endm
inbfsz	equ	gpbsiz/2
inbfmx	equ	objbuf+4	;input buffer - max byte count storage
inbfnc	equ	inbfmx+1	;	      - number chars read in
inbf	equ	inbfnc+1	;	      - starting address
inbfl	equ	inbfsz-1	;	      - last relative position
ninbf	equ	inbf+inbfl	;	      - address of last char

prsbfz	equ	gpbsiz/2
prsbf	equ	inbf+inbfsz	;parse buffer - starting address
lprsbf	equ	prsbf+prsbfz-1	;	      - last char of parse buf
nprsbf	equ	lprsbf+1	;	      - end address plus one

nzasm	equ	$		;end of disassembly buffer
zasmbf	equ	nzasm-128	;start of disassembly buffer

	defs	40
stack:
nmem	equ	((($+255) and 0ff00h)-z8eorg) and 0ff00h
;	was	(256*(($+255)/256)-z8eorg) and 0ff00h

	if M80
	.list			;enable printer output for symbol table
	endif

	end

