
	.z80
	;aseg

	;subttl	common file for basic interpreter
	;.sall

conto	defl	15		;character to supress output (usually control-o)
dbltrn	defl	0		;for double precision transcendentals
	if	0

	.PRINTX	/EXTENDED/


	.PRINTX	/LPT/

	.PRINTX	/CPM DISK/


	.PRINTX	/Z80/

	.PRINTX	/FAST/

	.PRINTX	/5.0 FEATURES/

	.PRINTX	/ANSI COMPATIBLE/
	endif

clmwid	defl	14		;make comma columns fourteen characters
datpsc	defl	128		;number of data bytes in disk sector
linln	defl	80		;terminal line length
lptlen	defl	132
buflen	defl	255		;long lines
namlen	defl	40		;maximum length name -- 3 to 127

numlev	defl	0*20+19+2*5	;number of stack levels reserved
				;by an explicit call to getstk

strsiz	defl	4

strsiz	defl	3
numtmp	defl	3		;number of string temporaries

numtmp	defl	10

md.rnd	defl	3		;the mode number for random files
md.sqi	defl	1		;the mode number for sequential input files
				;never written into a file
md.sqo	defl	2		;the mode for sequential output files
				;and program files
cpmwrm	defl	0		;cp/m warm boot addr
cpment	defl	cpmwrm+5	;cp/m bdos call addr
	cseg
trurom	defl	0
	page
	title	bimisc	basic interpreter miscellaneous routines/whg/pga etc.
	extrn	arytab,brktxt,crdo,crdonz,curlin,datptr,error,fadds
	extrn	fcerr,fcomp,fndfor,fndlin,fretop,frmevl,inchri,inlin,linget
	extrn	memsiz,movfm,movmf,movrm,newstt,oldlin,oldtxt,overr,ptrget
	extrn	snerr,strend,subflg,outdo,savtxt,chrcon

	extrn	topmem
	extrn	temp,temppt,tempst,tmerr,txttab,userr,valtyp,vartab
	extrn	errcn,errfin,errom,getbyt,stprdy,nferr,intid2,nxtcon
	public	synchr,dcompr
	extrn	chrgtr
	extrn	getypr
	extrn	vmove,prmlen,prmln2,deftbl,frqint,funact,iadd,icomp,nofuns,prmstk
	extrn	optflg,optval
	public	stoprg
	public	ton,toff
	extrn	oneflg,onelin,trcflg,savstk
	extrn	nxtflg
	public	clearc,scrath,stop,islet,islet2,stkini,getstk,scrtch
	public	stpend,bltu,cont,bltuc,ends,gtmprt,runc,stpend,endcon,restor
	public	stop,resfin,stkerr,reason,omerr
	public	next
;
; this is the block transfer routine
; it makes space by shoving everything forward
;
; [h,l] = destination of high address
; [d,e] = low address to be transferred
; [b,c] = high address to be transferred
;
; a check is made to make sure a reasonable amount
; of space remains between the top of the stack and
; the highest location transferred into
;
; on exit [h,l]=[d,e]=low [b,c]=location low was moved into
;
bltu:	call	reason		;check destination to make
				;sure the stack won'T BE OVERRUN
bltuc:	push	bc		;exchange [b,c] and [h,l]
	ex	(sp),hl
	pop	bc
bltlop:	call	dcompr		;see if we are done
	ld	a,(hl)		;get the word to transfer
	ld	(bc),a		;transfer it
	ret	z
	dec	bc
	dec	hl		;backup for next guy
	jp	bltlop
;
; this routine is used to make sure a certain number
; of locations remain available for the
; stack. the call is :
;	mvi	c,number of 2 byte entries necessary
;	call	getstk
;
; this routine must be called by any routine which puts
; an arbitrary amount of stuff on the stack
; (i.e. any recursive routine like frmevl)
; it is also called by routines such as "GOSUB" and "FOR"
; which make permanent entries on the stack
; routines which merely use and free up the guaranteed
; numlev stack locations need not call this
;
getstk:	push	hl		;save [h,l]
	ld	hl,(memsiz)
	ld	b,0
	add	hl,bc
	add	hl,bc		;see if we can have this many
;
; [h,l]= some address
; [h,l] is examined to make sure at least numlev
; locations remain between it and the top of the stack
;
cons1	defl	256-(2*numlev)
	ld	a,cons1		;set [h,l]=-[h,l]-2*numlev
	sub	l
	ld	l,a
	ld	a,255
	sbc	a,h
	jp	c,omerr		;in case [h,l] was too big(mbm 3/18**)
	ld	h,a		;now see if [sp] is larger
	add	hl,sp		;if so, carry will be set
	pop	hl		;get back original [h,l]
	ret	c		;was ok?
omerr:

	;for space reasons leave this code out

	;only important in versions where
	;stack context survives other errors
	ld	hl,(topmem)
	dec	hl		;up some memory space
	dec	hl		;make sure the fndfor stopper is saved
	ld	(savstk),hl	;place stack is restored from
omerrr:	ld	de,0+errom	;"OUT OF MEMORY"
	jp	error
	extrn	garba2
reason:	call	really		;enough space between string & stack
	ret	nc		;yes
	push	bc		;save all regs
	push	de
	push	hl
	call	garba2		;do a garbage collection
	pop	hl		;restore all regs
	pop	de
	pop	bc
	call	really		;enough space this time?
	ret	nc		;yes
	jp	omerrr		;no, give "OUT OF MEMORY BUT DONT TOUCH STACK
really:	push	de		;save [d,e]
	ex	de,hl		;save [h,l] in [d,e]
	ld	hl,(fretop)	;get where strings are
	call	dcompr		;is top of vars less than strings?
	ex	de,hl		;back to [d,e]
	pop	de		;restore [d,e]
	ret			;done
	page
	;subttl	nodsks, scratch (new), runc, clearc, stkini, qinlin
	public	nodsks
	extrn	filptr,maxfil
; the code below sets the file mode to 0 (closed) for all fcb'S
nodsks:	ld	a,(maxfil)	;get largest file #
	ld	b,a		;into b for counter
	ld	hl,filptr	;point to table of file data blocks
	xor	a		;make a zero to mark files as closed
	inc	b
lopnto:	ld	e,(hl)		;get pointer to file data block in [d,e]
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	(de),a		;mark file as closed (mode zero)
	dec	b
	jp	nz,lopnto	;loop until done
	extrn	clsall
	call	clsall
	xor	a
	;dont wipe out init message on screen(new does clear screen)
;
; the "NEW" command clears the program text as well
; as variable space
;
scrath:	ret	nz		;make sure there is a terminator
scrtch:
	ld	hl,(txttab)	;get pointer to start of text
	call	toff		;turn off trace. set [a]=0.
	extrn	proflg
	ld	(proflg),a	;no longer a protected file
	extrn	autflg
	ld	(autflg),a	;clear auto mode
	extrn	ptrflg
	ld	(ptrflg),a	;say no pointers exist
	ld	(hl),a		;save at end off text
	inc	hl		;bump pointer
	ld	(hl),a		;save zero
	inc	hl		;bump pointer
	ld	(vartab),hl	;new start of variables
runc:
	ld	hl,(txttab)	;point at the start of text
	dec	hl
;
; clearc is a subroutine which initializes the variable and
; array space by reseting arytab [the end of simple variable space]
; and strend [the end of array storage]. it falls into stkini
; which resets the stack. [h,l] is preserved.
;
clearc:	ld	(temp),hl	;save [h,l] in temp
	extrn	mrgflg
	ld	a,(mrgflg)	;doing a chain merge?
	or	a		;test
	jp	nz,levdtb	;leave default table alone
	xor	a
	ld	(optflg),a	;indicate no "OPTION" has been seen
	ld	(optval),a	;default to "OPTION BASE 0"
	ld	b,26		;initialize the default valtype table
	ld	hl,deftbl	;point at the first entry
lopdft:	ld	(hl),4		;loop 26 times storing a default valtyp
	inc	hl		;for single precision
				;count off the letters
	dec	b
	jp	nz,lopdft	;loop back, and setup the rest of the table
levdtb:
	extrn	rndcop,rndx,move
	extrn	rndcnt
	ld	de,rndcop	;reset the random number generator
	ld	hl,rndx		;seed in rndx
	call	move
	ld	hl,rndcnt-1	;and zero count registers
	xor	a
	ld	(hl),a
	inc	hl
	ld	(hl),a
	inc	hl
	ld	(hl),a
	xor	a
	ld	(oneflg),a	;reset on error flag for runs
	ld	l,a		;reset error line number
	ld	h,a		;by setting onelin=0.
	ld	(onelin),hl
	ld	(oldtxt),hl	;make continuing impossible
	ld	hl,(memsiz)
	extrn	chnflg
	ld	a,(chnflg)	;are we chaining?
	or	a		;test
	jp	nz,godfre	;fretop is good, leave it alone
	ld	(fretop),hl	;free up string space
godfre:	xor	a		;make sure [a] is zero, cc'S SET
	call	restor		;restore data
	ld	hl,(vartab)	;get start of variable space
	ld	(arytab),hl	;save in start of array space
	ld	(strend),hl	;and end of variable storage
	extrn	clsall
	ld	a,(mrgflg)	;doing chain merge?
	or	a
	call	z,clsall	;if so, dont close files...
;
; stkini resets the stack pointer eliminating
; gosub & for context.  string temporaries are freed
; up, subflg is reset, continuing is disallowed,
; and a dummy entry is put on the stack. this is so
; fndfor will always find a non-"FOR" entry at the bottom
; of the stack. [a]=0 and [d,e] is preserved.
;
stkini:	pop	bc		;get return address here
	ld	hl,(topmem)
	dec	hl		;take into account fndfor stopper
	dec	hl
	ld	(savstk),hl	;make sure savstk ok just in case.
	inc	hl		;increment back for sphl
	inc	hl
stkerr:	ld	sp,hl		;initialize stack
	ld	hl,tempst
	ld	(temppt),hl	;initialize string temporaries
	extrn	clrovc
	call	clrovc		;back to normal overflow print mode
	extrn	finlpt
	call	finlpt
	extrn	finprt
	call	finprt		;clear ptrfil, other i/o flags
	xor	a		;zero out a
	ld	h,a		;zero out h
	ld	l,a		;zero out l
	ld	(prmlen),hl	;flag no active parameters
	ld	(nofuns),a	;indicate no user functions active
	ld	(prmln2),hl	;no parameters being built
	ld	(funact),hl	;set number of functions active to 0
	ld	(prmstk),hl	;and no parameter blocks on the stack
	ld	(subflg),a	;allow subscripts
	push	hl		;put zero (non $for,$gosub)
				;on the stack
	push	bc		;put return address back on
gtmprt:	ld	hl,(temp)	;get saved [h,l]
	ret

	page
	;subttl	dcompr, synchr - replacements for compar & synchk in rstles version
	public	synchr
dcompr:	ld	a,h		;replacement for "COMPAR" rst
	sub	d
	ret	nz
	ld	a,l
	sub	e
	ret

synchr:	ld	a,(hl)		;replacement for "SYNCHK" rst
	ex	(sp),hl
	cp	(hl)
	jp	nz,synerr
	inc	hl
	ex	(sp),hl
	inc	hl		;look at next char
	ld	a,(hl)		;get it
	cp	':'		;is it end of statment or bigger
	ret	nc
syncon:	jp	chrcon		;rest of chrget
synerr:	jp	snerr
	;subttl	restore, stop, end

restor:	ex	de,hl		;save [h,l] in [d,e]
	ld	hl,(txttab)
	jp	z,bgnrst	;restore data pointer to beginning of program
	ex	de,hl		;text pointer back to [h,l]
	call	linget		;get the following line number
	push	hl		;save text pointer
	call	fndlin		;find the line number
	ld	h,b		;get pointer to line in [h,l]
	ld	l,c
	pop	de		;text pointer back to [d,e]
	jp	nc,userr	;should have found line
bgnrst:
	dec	hl		;initialize datptr to [txttab]-1
resfin:	ld	(datptr),hl	;read finishes come to resfin
	ex	de,hl		;get the text pointer back
	ret
stop:	ret	nz		;return if not control-c and make
				;sure "STOP" statements have a terminator
stoprg:
	inc	a
	jp	constp
				;to type the break message
ends:	ret	nz		;make sure "END" statements have a terminator
	push	af		;preserve condition codes over call to clsall
	call	z,clsall
	pop	af		;restore condition codes
constp:	ld	(savtxt),hl	;save for "CONTINUE"
	ld	hl,tempst	;reset string temp pointer
	ld	(temppt),hl	;save in case ^c print using
	defb	41q		;"LXI H," over next two
stpend:	or	377o		;set non-zero to force printing of break message
	pop	bc		;pop off newstt address
endcon:	ld	hl,(curlin)	;save curlin
	push	hl		;save line to print
	push	af		;save the message flag
				;zero means don'T PRINT "BREAK"
	ld	a,l
	and	h		;see if it was direct
	inc	a
	jp	z,diris		;if not set up for continue
	ld	(oldlin),hl	;save old line #
	ld	hl,(savtxt)	;get pointer to start of statement
	ld	(oldtxt),hl	;save it
diris:
	extrn	cntofl
	xor	a
	ld	(cntofl),a	;force output
	call	finlpt
	call	crdonz		;print cr if ttypos .ne. 0
	pop	af		;get back ^c flag
	ld	hl,brktxt	;"BREAK"
	jp	nz,errfin	;call strout and fall into ready
	jp	stprdy		;pop off line number & fall into ready
	page
	;subttl	ctrlpt, ddt, cont, null, tron, troff
	public	ctrlpt,ctropt
ctropt:	ld	a,conto		;print an ^o.
ctrlpt:	push	af		;save current char
	sub	3		;control-c?
	jp	nz,ntctct	;no
	extrn	prtflg
	ld	(prtflg),a	;display ^c only(not on lpt)
	ld	(cntofl),a	;reset ^o flag
ntctct:
	ld	a,'^'		;print up-arrow.
	call	outdo		;send it
	pop	af		;get back control char.
	add	a,100o		;make printable
	call	outdo		;send it
	jp	crdo		;and then send crlf.
cont:	ld	hl,(oldtxt)	;a stored text pointer of
				;zero is setup by stkini
				;and indicates there is nothing
				;to continue
	ld	a,h		;"STOP","END",typing crlf
	or	l		;to "INPUT" and ^c setup oldtxt
reserr:	ld	de,0+errcn	;"CAN'T CONTINUE"
	jp	z,error
	ex	de,hl		;save [h,l]
	ld	hl,(oldlin)
	ld	(curlin),hl	;set up old line # as current line #
	ex	de,hl		;restore [h,l]
	ret
	extrn	nulcnt
	public	null
null:	call	getbyt
	ret	nz		;make sure there is a terminator
	inc	a		;code at crdo expects at least 1
	ld	(nulcnt),a	;change number of nulls
	ret
ton:	defb	76q		;"MVI A," non-zero quantity
toff:	xor	a		;make [a]=0 for no trace
	ld	(trcflg),a	;update the trace flag
	ret
	page
	;subttl	swap, erase
	extrn	swptmp
	public	swap
swap:	call	ptrget		;[d,e]=pointer at value #1
	push	de		;save the pointer at value #1
	push	hl		;save the text pointer
	ld	hl,swptmp	;temporary store location
	call	vmove		;swptmp=value #1
	ld	hl,(arytab)	;get arytab so change can be noted
	ex	(sp),hl		;get the text pointer back
				;and save current [arytab]
	call	getypr
	push	af		;save the type of value #1
	call	synchr
	defb	44		;make sure the variables are
				;delimited by a comma
	call	ptrget		;[d,e]=pointer at value #2
	pop	bc		;[b]=type of value #1
	call	getypr		;[a]=type of value #2
	cp	b		;make sure they are the same
	jp	nz,tmerr	;if not, "TYPE MISMATCH" error
	ex	(sp),hl		;[h,l]=old [arytab] save the text pointer
	ex	de,hl		;[d,e]=old [arytab]
	push	hl		;save the pointer at value #2
	ld	hl,(arytab)	;get new [arytab]
	call	dcompr
	jp	nz,fcerr	;if its changed, error
	pop	de		;[d,e]=pointer at value #2
	pop	hl		;[h,l]=text pointer
	ex	(sp),hl		;save the text pointer on the stack
				;[h,l]=pointer at value #1
	push	de		;save the pointer at value #2
	call	vmove		;transfer value #2 into value #1'S OLD
				;position
	pop	hl		;[h,l]=pointer at value #2
	ld	de,swptmp	;location of value #1
	call	vmove		;transfer swptmp=value #1 into value #2'S
				;old position
	pop	hl		;get the text pointer back
	ret
	public	erase
erase:
	ld	a,1
	ld	(subflg),a	;that this is "ERASE" calling ptrget
	call	ptrget		;go find out where to erase
	jp	nz,fcerr	;ptrget did not find variable!
	push	hl		;save the text pointer
	ld	(subflg),a	;zero out subflg to reset "ERASE" flag
	ld	h,b		;[b,c]=start of array to erase
	ld	l,c
	dec	bc		;back up to the front
	dec	bc		;no value type without length=2
	dec	bc		;back up one more
lpbknm:	ld	a,(bc)		;get a character. only the count has high bit=0
	dec	bc		;so loop until we skip over the count
	or	a		;skip all the extra characters
	jp	m,lpbknm
	dec	bc
	dec	bc
	add	hl,de		;[h,l]=the end of this array entry
	ex	de,hl		;[d,e]=end of this array
	ld	hl,(strend)	;[h,l]=last location to move up
erslop:	call	dcompr		;see if the last location is going to be moved
	ld	a,(de)		;do the move
	ld	(bc),a
	inc	de		;update the pointers
	inc	bc
	jp	nz,erslop	;move the rest
	dec	bc
	ld	h,b		;setup the new storage end pointer
	ld	l,c
	ld	(strend),hl
	pop	hl		;get back the text pointer
	ld	a,(hl)		;see if more erasures needed
	cp	54o		;additional variables delimited by comma
	ret	nz		;all done if not
	call	chrgtr
	jp	erase
casdon:
	public	popaht
popaht:	pop	af
	pop	hl		;get the text pointer
	ret
	page
;
;test for a letter / carry on=not a letter
;		     carry off=a letter
;
islet:	ld	a,(hl)
islet2:	cp	'A'
	ret	c		;if less than "A", return early
	cp	91		;91="Z"+1
	ccf
	ret
	;subttl	clear
;
; this code is for the "CLEAR" command with an argument
; to change the amount of string space allocated.
; if no formula is given the amount of string space
; remains unchanged.
;
	public	clear
clear:	jp	z,clearc	;if no formula just clear
	cp	54o		;allow no string space
	jp	z,cskpcm
	call	intid2		;get an integer into [d,e]
	dec	hl
	call	chrgtr		;see if its the end
	jp	z,clearc
cskpcm:	call	synchr
	defb	54o
	jp	z,clearc
	ex	de,hl
	ld	hl,(topmem)	;get highest address
	ex	de,hl
	cp	54o
	jp	z,clears	;should finish there
	call	frmevl		;evaluate formula
	push	hl		;save text pointer
	call	frqint		;convert to integer in [h,l]
	ld	a,h
	or	l		;memory size =0?
	jp	z,fcerr		;yes, error
	ex	de,hl		;value to [d,e]
	pop	hl		;restore text pointer
clears:	dec	hl		;back up
	call	chrgtr		;get char
	push	de		;save new high mem
	jp	z,cdfstk	;use same stack size
	call	synchr
	defb	54o
	jp	z,cdfstk
	call	intid2
	dec	hl
	call	chrgtr
	jp	nz,snerr
cleart:	ex	(sp),hl		;save text pointer
	push	hl		;save candidate for topmem
	ld	hl,0+(2*numlev)+20;check stack size is reasonable
	call	dcompr
	jp	nc,omerr
	pop	hl
	call	subde		;subtract [h,l]-[d,e] into [d,e]
	jp	c,omerr		;wanted more than total!
	push	hl		;save memsiz
	ld	hl,(vartab)	;top location in use
	ld	bc,0+20		;leave breathing room
	add	hl,bc
	call	dcompr		;room?
	jp	nc,omerr	;no, don'T EVEN CLEAR
	ex	de,hl		;new stack location [h,l]
	ld	(memsiz),hl	;set up new stack location
	pop	hl		;get back memsiz
	ld	(topmem),hl	;set it up, must be ok
	pop	hl		;regain the text pointer
	jp	clearc		;go clear
cdfstk:	push	hl		;save text pointer
	ld	hl,(topmem)	;figure out current stack size so
	ex	de,hl		;it is saved
	ld	hl,(memsiz)
	ld	a,e
	sub	l
	ld	e,a
	ld	a,d
	sbc	a,h
	ld	d,a
	pop	hl
	jp	cleart

subde:	ld	a,l
	sub	e
	ld	e,a
	ld	a,h
	sbc	a,d
	ld	d,a
	ret
	page
	;subttl	next code
;
; a "FOR" entry on the stack has the following format:
;
; low address
;	token ($for in high byte)  1 bytes
;	a pointer to the loop variable  2 bytes
;	under ansi & length=2, two bytes giving text pointer of matching "NEXT"
;	a byte reflecting the sign of the increment 1 byte
;	under length=2, a byte minus for integer and positive for floating "FOR"s
;	the step 4 bytes
;	the upper value 4 bytes
;	the line # of the "FOR" statement 2 bytes
;	a text pointer into the "FOR" statement 2 bytes
; high address
;
; total 16-19 bytes
;
	public	next
next:
	push	af		;save the character codes
	defb	366q		;set [a] non-zero
	public	nexts
nexts:	xor	a		;flag that "FOR" is using "NEXT"
	ld	(nxtflg),a
	pop	af		;get back the character code
	ld	de,0		;for the "NEXT"
				;statement without any args
				;we call fndfor with [d,e]=0
nextc:
	extrn	nxttxt
	ld	(nxttxt),hl	;save starting text pointer
	call	nz,ptrget	;get a pointer to the
				;loop variable into [d,e]
	ld	(temp),hl	;put the text pointer
				;in a temp location
				;in case the loop terminates
	call	fndfor		;try to find a for entry
				;on the stack whose variable name
				;matches this ones
	jp	nz,nferr	;"NEXT WITHOUT FOR"
	ld	sp,hl		;setup stack pointer by chopping
				;at this point
	push	de		;put the variable ptr back on
	ld	e,(hl)		;pick up the correct "NEXT" text pointer
	inc	hl
	ld	d,(hl)
	inc	hl
	push	hl		;save the pointer into the stack entry
	ld	hl,(nxttxt)	;[h,l]=text pointer at the start of this "NEXT"
	call	dcompr
	jp	nz,nferr	;if no match, "NEXT WITHOUT FOR"
	pop	hl
	pop	de		;get back the variable pointer
	push	de
	ld	a,(hl)		;step onto the stack
	push	af
	inc	hl
	push	de		;put the pointer to the loop
				;variable onto the stack
	ld	a,(hl)		;get flag whether this is an integer "FOR"
	inc	hl		;advance the "FOR" entry pointer
	or	a		;set the minus flag if it'S AN INTEGER "FOR"
	jp	m,intnxt	;handle integers seperately
	call	movfm		;step value into the fac
	ex	(sp),hl		;put the pointer into the
				;for entry onto the stack
	push	hl		;put the pointer to the loop
				;variable back onto the stack
	ld	a,(nxtflg)	;is "FOR" using "NEXT"
	or	a
	jp	nz,nxtdo	;no, continue "NEXT"
	extrn	fvalsv
	ld	hl,fvalsv	;fetch the initial value into the fac
	call	movfm
	xor	a		;continue the "NEXT" with initial value
nxtdo:	call	nz,fadds
	pop	hl		;pop off the pointer to
	;the loop variable
	call	movmf		;mov fac into loop variable
	pop	hl		;get the entry pointer
	call	movrm		;get the final into the registers
	push	hl		;save the entry pointer
	call	fcomp		;compare the numbers returning 377 if fac is
				;less than the registers,
				;0 if equal, otherwise 1
	jp	finnxt		;skip over integer code
intnxt:	inc	hl		;skip the four dummy bytes
	inc	hl
	inc	hl
	inc	hl
	ld	c,(hl)		;[b,c]= the step
	inc	hl
	ld	b,(hl)
	inc	hl
	ex	(sp),hl		;save the entry pointer on the stack
				;and set [h,l]=pointer to the loop variable
	ld	e,(hl)		;[d,e]=loop variable value
	inc	hl
	ld	d,(hl)
	push	hl		;save the pointer at the loop variable value
	ld	l,c
	ld	h,b		;setup to add [d,e] to [h,l]
	ld	a,(nxtflg)	;see if "FOR" is using "NEXT"
	or	a
	jp	nz,inxtdo	;no, just continue next
	ld	hl,(fvalsv)	;get the initial value
	jp	iforin		;continue first iteration check
inxtdo:	call	iadd		;add the step to the loop variable
	ld	a,(valtyp)	;see if there was overflow
	cp	4		;turned to single-precision?
	jp	z,overr		;indice got too large
iforin:	ex	de,hl		;[d,e]=new loop variable value
	pop	hl		;get the pointer at the loop variable
	ld	(hl),d		;store the new value
	dec	hl
	ld	(hl),e
	pop	hl		;get back the pointer into the "FOR" entry
	push	de		;save the value of the loop variable
	ld	e,(hl)		;[d,e]=final value
	inc	hl
	ld	d,(hl)
	inc	hl
	ex	(sp),hl		;save the entry pointer again
				;get the value of the loop variable into [h,l]
	call	icomp		;do the compare
finnxt:
	pop	hl		;pop off the "FOR" entry pointer which is now
				;pointing past the final value
	pop	bc		;get the sign of the increment
	sub	b		;subtract the increments sign from that
				;of (current value-final value)
	call	movrm		;get line # of "FOR" into [d,e]
				;get text pointer of "FOR" into [b,c]
	jp	z,loopdn	;if sign(final-current)+sign(step)=0
				;then the loop is finished
	ex	de,hl
	ld	(curlin),hl	;store the line #
	ld	l,c		;setup the text pointer
	ld	h,b
	jp	nxtcon

loopdn:	ld	sp,hl		;eliminate the for entry
				;since [h,l] moved all
				;the way down the entry
	ld	(savstk),hl	;update saved stack
	ld	hl,(temp)	;restore the text pointer
	ld	a,(hl)		;is there a comma at the end
	cp	','		;if so look at another
	jp	nz,newstt	;variable name to "NEXT"
	call	chrgtr		;read first charcter
	call	nextc		;do next, but don'T ALLOW
				;blank variable name [d,e]=stk ptr
				;and will never match any varptr
				;use call to put dummy "NEWSTT" entry on
	page
				;end i8086 conditonal
;	end

