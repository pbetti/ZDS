
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
	title	fiveo 5.0 features -while/wend, call, chain, write /p. allen
	;.sall
	extrn	chrgtr,synchr,dcompr
	extrn	getypr
	extrn	snerr,getstk,ptrget,subflg,temp,crdo
	extrn	vmovfm,frcint
	page
	;subttl	while, wend
	public	while,wend
	extrn	endfor,error,frmevl,$for,$while,wndscn
	extrn	savstk,newstt,nxtlin,curlin,forszc,errwe
;
; this code handles the statements while/wend
; the 8080 stack is used to put an entry on for each active while
; the same way active gosub and for entries are made.
; the format is as follows:
;	$while - the token identifying the entry (1 byte)
;	a text pointer at the character after the wend of the while body (2 bytes)
;	a text pointer at the character after the while of the while body (2 bytes)
;	the line number of the line that the while is on (2 bytes)
;
;	total	7 bytes
;
while:	ld	(endfor),hl	;keep the while text pointer here
	call	wndscn		;scan for the matching wend
				;cause an errwh if no wend to match
	call	chrgtr		;point at charactwer after wend
	ex	de,hl		;[d,e]= position of matching wend
	call	fndwnd		;see if there is a stack entry for this while
	inc	sp		;get rid of the newstt address on the stack
	inc	sp
	jp	nz,wnotol	;if no match no need to truncate the stack
	add	hl,bc		;eliminate everything up to and including
				;the matching while entry
	ld	sp,hl
	ld	(savstk),hl
wnotol:	ld	hl,(curlin)	;make the stack entry
	push	hl
	ld	hl,(endfor)	;get text pointer for while back
	push	hl
	push	de		;save the wend text pointer
	jp	fnwend		;finish using wend code

wend:	jp	nz,snerr	;statement has no arguments
	ex	de,hl		;find matching while entry on stack
	call	fndwnd
	jp	nz,weerr	;must match or else error
	ld	sp,hl		;truncate stack at match point
	ld	(savstk),hl
	ex	de,hl		;save [h,l] pointing into stack entry
	ld	hl,(curlin)	;remember wend line #
	ld	(nxtlin),hl	;in nxtlin
	ex	de,hl
	inc	hl		;index into stack entry to get values
	inc	hl		;skip over text pointer of wend
	ld	e,(hl)		;set [d,e]=text pointer of while
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	a,(hl)		;[h,l]=line number of while
	inc	hl
	ld	h,(hl)
	ld	l,a
	ld	(curlin),hl	;in case of error or continuation fix curlin
	ex	de,hl		;get text pointer of while formula into [h,l]
fnwend:	call	frmevl		;evaluate formula
	extrn	vsign
	push	hl		;save text pointer
	call	vsign		;get if true or false
	pop	hl		;get back while text pointer
	jp	z,flswhl	;go back at wend if false
	ld	bc,0+$while	;complete while entry
	ld	b,c		;need it in the high byte
	push	bc
	inc	sp		;only use one byte
	jp	newstt

flswhl:	ld	hl,(nxtlin)	;setup curlin for wend
	ld	(curlin),hl
	pop	hl		;take off text of wend as new text pointer
	pop	af		;get rid of text pointer of while
	pop	af		;take off line number of while
	jp	newstt
;
; this subroutine searches the stack for an while entry
; whose wend text pointer matches [d,e]. it returns with zero true
; if a match is found and zero false otherwise. for entries
; are skipped over, but gosub entries are not.
;
whlsiz	defl	6
fndwnd:	ld	hl,0+4		;skip over return address and newstt
	add	hl,sp
fndwn2:
	ld	a,(hl)		;get the entry type
	inc	hl
	ld	bc,0+$for
	cp	c		;see if its $for
	jp	nz,fndwn3
	ld	bc,forszc
	add	hl,bc
	jp	fndwn2
fndwn3:	ld	bc,0+$while
	cp	c
	ret	nz
	push	hl
	ld	c,(hl)		;pick up the wend text pointer
	inc	hl
	ld	b,(hl)
	ld	h,b
	ld	l,c
	call	dcompr
	pop	hl
	ld	bc,0+whlsiz
	ret	z		;return if entry matches
	add	hl,bc
	jp	fndwn2

weerr:	ld	de,0+errwe
	jp	error
	page
	;subttl	call statement
	public	calls
; this is the call <simple var>[(<simple var>[,<simple var>]..)]
; stragegy:
;
; 1.) make sure suboutine name is simple var, get value & save it
;
; 2.) allocate space on stack for param adresses
;
; 3.) evaluate params & stuff pointers on stack
;
; 3.) pop off pointers ala calling convention
;
; 4.) call suboutine with return address on stack
maxprm	defl	32		;max # of params to assembly language subroutine
	extrn	tempa
calls:
	ld	a,200o		;flag ptrget not to allow arrays
	ld	(subflg),a
	call	ptrget		;evaluate var pointer
	push	hl		;save text pointer
	ex	de,hl		;var pointer to [h,l]
	call	getypr		;get type of var
	call	vmovfm		;store value in fac
	call	frcint		;evaluate var
	ld	(tempa),hl	;save it
	ld	c,maxprm	;check to see if we have space for max parm block
	call	getstk
	pop	de		;get text pointer off stack
	ld	hl,0-2*maxprm	;get space on stack for parms
	add	hl,sp
	ld	sp,hl		;adjust stack
	ex	de,hl		;put text pointer in [h,l], stack pointer in [d,e]
	ld	c,maxprm	;get # of params again
	dec	hl		;back up text pointer
	call	chrgtr		;get char
	ld	(temp),hl	;save text pointer
	jp	z,callst	;if end of line, go!
	call	synchr
	defb	'('		;eat left paren
getpar:	push	bc		;save count
	push	de		;save pointer into stack
	call	ptrget		;evaluate param address
	ex	(sp),hl		;save text pointer get pointer into stack
	ld	(hl),e		;save var address on stack
	inc	hl
	ld	(hl),d
	inc	hl
	ex	(sp),hl		;save back var pointer, get text pointer
	pop	de
	pop	bc
	ld	a,(hl)		;look at terminator
	cp	54o		;comma?
	jp	nz,endpar	;test
	dec	c		;decrement count of params
	call	chrgtr		;get next char
	jp	getpar		;back for more
endpar:	call	synchr
	defb	')'		;should have left paren
	ld	(temp),hl	;save text pointer
	ld	a,maxprm+1	;calc # of params
	sub	c
	pop	hl		;at least one, get its address in [h,l]
	dec	a		;was it one?
	jp	z,callst	;yes
	pop	de		;next address in [d,e]
	dec	a		;two?
	jp	z,callst	;yes
	pop	bc		;final in [b,c]
	dec	a		;three?
	jp	z,callst	;yes
	push	bc		;save back third parm
	push	hl		;save back first
	ld	hl,0+2		;point to rest of parm list
	add	hl,sp
	ld	b,h		;get into [b,c]
	ld	c,l
	pop	hl		;restore parm three
callst:	push	hl		;save parm three
	ld	hl,callrt	;where subroutines return
	ex	(sp),hl		;put it on stack, get back parm three
	push	hl		;save parm three
	ld	hl,(tempa)	;get subroutine address
	ex	(sp),hl		;save, get back parm three
	ret			;dispatch to subroutine

callrt:	ld	hl,(savstk);restore stack to former state
	ld	sp,hl
	ld	hl,(temp)	;get back text poiner
	jp	newstt		;get next statement
	page
	;subttl	chain
	extrn	txttab,frmevl,$commo,omerr,scrtch,valtyp,$merge,linget
	extrn	$delet
	public	chain,comptr,compt2,common
	extrn	garba2,fretop,move1,newstt,ptrget,strcpy
	extrn	savfre
	extrn	iadahl
	extrn	subflg,temp3,temp9,vartab,arytab,bltuc,chnflg,chnlin,data
	extrn	fndlin,strend,userr,curlin,ersfin,fcerr,noarys,savstk,endbuf
	extrn	del,cmeptr,cmsptr,mrgflg,mdlflg,linker,scnlin,frqint
; this is the code for the chain statement
; the syntax is:
; chain [merge]<file name>[,[<line number>][,all][,delete <range>]]
; the steps required to execute a chain are:
;
; 1.) scan arguments
;
; 2.) scan program for all common statements and
;	mark specified variables.
;
; 3.) squeeze unmarked entries from symbol table.
;
; 4.) copy string literals to string space
;
; 5.) move all simple variables and arrays into the
;	bottom of string space.
;
; 6.) load new program
;
; 7.) move variables back down positioned after program.
;
; 8.) run program
chain:
	xor	a		;assume no merge
	ld	(mrgflg),a
	ld	(mdlflg),a	;also no merge w/ delete option
	ld	a,(hl)		;get current char
	ld	de,0+$merge	;is it merge?
	cp	e		;test
	jp	nz,ntchnm	;no
	ld	(mrgflg),a	;set merge flag
	inc	hl
ntchnm:	dec	hl		;rescan file name
	call	chrgtr
	extrn	prgfli
	call	prgfli		;evaluate file name and open it
	push	hl		;save text pointer
	ld	hl,0		;get zero
	ld	(chnlin),hl	;assume no chain line #
	pop	hl		;restore text pointer
	dec	hl		;back up pointer
	call	chrgtr		;scan char
	jp	z,ntchal	;no line number etc.
	call	synchr
	defb	54o		;must be comma
	cp	54o		;ommit line # (use all for instance)
	jp	z,ntlinf	;yes
	call	frmevl		;evaluate line # formula
	push	hl		;save text poiner
	call	frqint		;force to int in [h,l]
	ld	(chnlin),hl	;save it for later
	pop	hl		;restore text poiner
	dec	hl		;rescan last char
	call	chrgtr
	jp	z,ntchal	;no all i.e. preserve all vars across chain
ntlinf:	call	synchr
	defb	54o		;should be comma here
	ld	de,0+$delet	;test for delete option
	cp	e		;is it?
	jp	z,chmwdl	;yes
	call	synchr
	defb	'A'		;check for "ALL"
	call	synchr
	defb	'L'
	call	synchr
	defb	'L'
	jp	z,dncmda	;goto step 3
	call	synchr
	defb	54o		;force comma to appear
	cp	e		;must be delete
	jp	nz,snerr	;no, give error
	or	a		;flag to goto dncmda
chmwdl:	push	af		;save all flag
	ld	(mdlflg),a	;set merge w/ delete
	call	chrgtr		;get char after comma
	call	scnlin		;scan line range
	extrn	deptr
	push	bc
	call	deptr		;change pointers back to numbers
	pop	bc
	pop	de		;pop max line off stack
	push	bc		;save pointer to start of 1st line
	ld	h,b		;save pointer to start line
	ld	l,c
	ld	(cmsptr),hl
	call	fndlin		;find the last line
	jp	nc,fcerrg	;must have exact match on end of range
	ld	d,h		;[d,e] =  pointer at the start of the line
	ld	e,l		;beyond the last line in the range
	ld	(cmeptr),hl	;save pointer to end line
	pop	hl		;get back pointer to start of range
	call	dcompr		;make sure the start comes before the end
fcerrg:	jp	nc,fcerr	;if not, "Illegal function call"
	pop	af		;flag that says whether to go to dncmda
	jp	nz,dncmda	;"ALL" option was present
ntchal:	ld	hl,(txttab)	;start searching for commons at program start
	dec	hl		;compensate for next instr
clpsc1:	inc	hl		;look at first char of next line
clpscn:	ld	a,(hl)		;get char from program
	inc	hl
	or	(hl)		;are we pointing to program end?
	jp	z,clpfin	;yes
	inc	hl
	ld	e,(hl)		;get line # in [d,e]
	inc	hl
	ld	d,(hl)
	ex	de,hl		;save current line # in curlin for errors
	ld	(curlin),hl
	ex	de,hl
cstscn:	call	chrgtr		;get statment type
aftcom:	or	a
	jp	z,clpsc1	;eol scan next one
	cp	':'		;are we looking at colon
	jp	z,cstscn	;yes, get next statement
	ld	de,0+$commo	;test for common, avoid byte extrnals
	cp	e		;is it a common?
	jp	z,docomm	;yes, handle it
	call	chrgtr		;get first char of statement
	call	data		;skip over statement
	dec	hl		;back up to rescan terminator
	jp	cstscn		;scan next one
docomm:	call	chrgtr		;get thing after common
	jp	z,aftcom	;get next thing
nxtcom:	push	hl		;save text pointer
	ld	a,1		;call ptrget to search for array
	ld	(subflg),a
	call	ptrget		;this subroutine in f3 scans variables
	jp	z,fndaay	;found array
	ld	a,b		;try finding array with common bit set
	or	128
	ld	b,a
	xor	a		;set zero cc
	call	ersfin		;search array table
	ld	a,0		;clear subflg in all cases
	ld	(subflg),a
	jp	nz,ntfn2t	;not found, try simple
	ld	a,(hl)		;get terminator, should be "("
	cp	'('		;test
	jp	nz,scnsmp	;must be simple then
	pop	af		;get rid of saved text pointer
	jp	comady		;already was common, ignore it
ntfn2t:	ld	a,(hl)		;get terminator
	cp	'('		;array specifier?
	jp	z,fcerr		;no such animal, give "Function call" error
scnsmp:	pop	hl		;rescan variable name for start
	call	ptrget		;evaluate as simple
comptr:	ld	a,d		;if var not found, [d,e]=0
	or	e
	jp	nz,comfns	;found it
	ld	a,b		;try to find in common
	or	128		;set common bit
	ld	b,a
	ld	a,(valtyp)	;must have valtyp in [d]
	ld	d,a
	call	noarys		;search symbol table
compt2:	ld	a,d		;found?
	or	e
	jp	z,fcerr		;no, who is this guy?
comfns:	push	hl		;save text pointer
	ld	b,d		;get pointer to var in [b,c]
	ld	c,e
	ld	hl,bckucm	;loop back here
	push	hl
cbakbl:	dec	bc		;point at first char of rest
lpbknc:	ld	a,(bc)		;back up until plus byte
	dec	bc
	or	a
	jp	m,lpbknc
				;now point to 2nd char of var name
	ld	a,(bc)		;set common bit
	or	128
	ld	(bc),a
	ret			;done
fndaay:	ld	(subflg),a	;array found, clear subflg
	ld	a,(hl)		;make sure really array spec
	cp	'('		;really an array?
	jp	nz,scnsmp	;no, scan as simp
	ex	(sp),hl		;save text pointer, get rid of saved text pointer
bakcom:	dec	bc		;point at last char of name extension
	dec	bc
	call	cbakbl		;back up before variable and mark as common
bckucm:	pop	hl		;restore text pointer
	dec	hl		;rescan terminator
	call	chrgtr
	jp	z,aftcom	;end of common statement
	cp	'('		;end of common array spec?
	jp	nz,chkcst	;no, should be comma
comady:	call	chrgtr		;fetch char after paren
	call	synchr
	defb	')'		;right paren should follow
	jp	z,aftcom	;end of common
chkcst:	call	synchr
	defb	54o		;force comma to appear here
	jp	nxtcom		;get next common variable
; step 3 - squeeze..
clpfin:	ld	hl,(arytab)	;end of simple var squeeze
	ex	de,hl		;to [d,e]
	ld	hl,(vartab)	;start of simps
clpslp:	call	dcompr		;are we done?
	jp	z,dncmds	;yes done, with simps
	push	hl		;save where this simp is
	ld	c,(hl)		;get valtyp
	inc	hl
	inc	hl
	ld	a,(hl)		;get common bit
	or	a		;set minus if common
	push	af		;save indicator
	and	177o		;clear common bit
	ld	(hl),a		;save back
	inc	hl
	call	iadahl		;skip over rest of var name
	ld	b,0		;skip valtyp bytes
	add	hl,bc
	pop	af		;get indicator whether to delete
	pop	bc		;pointer to where var started
	jp	m,clpslp
	push	bc		;this is where we will resume scanning vars later
	call	vardls		;delete variable
	ld	hl,(arytab)	;now correct arytab by # of bytes deleted
	add	hl,de		;add negative difference between old and new
	ld	(arytab),hl	;save new arytab
	ex	de,hl		;to [d,e]
	pop	hl		;get current place back in [h,l]
	jp	clpslp
vardls:	ex	de,hl		;point to where var ends
	ld	hl,(strend)	;one beyond last byte to move
dlsvlp:	call	dcompr		;done?
	ld	a,(de)		;grab byte
	ld	(bc),a		;move down
	inc	de		;increment pointers
	inc	bc
	jp	nz,dlsvlp
	ld	a,c		;get difference between old and new
	sub	l		;into [d,e] ([d,e]=[b,c]-[h,l])
	ld	e,a
	ld	a,b
	sbc	a,h
	ld	d,a
	dec	de		;correct # of bytes
	dec	bc		;moved one too far
	ld	h,b		;get new strend [h,l]
	ld	l,c
	ld	(strend),hl	;store it
	ret
dncmds:	ld	hl,(strend)	;limit of array search
	ex	de,hl		;to [d,e]
clpakp:	call	dcompr		;done?
	jp	z,dncmda	;yes
	push	hl		;save pointer to valtyp
	inc	hl		;move down to common bit
	inc	hl
	ld	a,(hl)		;get it
	or	a		;set cc's
	push	af		;save common indicator
	and	177o		;clear common bit
	ld	(hl),a		;save back
	inc	hl		;point to length of array
	call	iadahl		;add length of var name
	ld	c,(hl)		;get length of array in [b,c]
	inc	hl
	ld	b,(hl)
	inc	hl
	add	hl,bc		;[h,l] now points after array
	pop	af		;get back common indicator
	pop	bc		;get pointer to start of array
	jp	m,clpakp	;common, dont delete!
	push	bc		;save so we can resume
	call	vardls		;delete variable
	ex	de,hl		;put strend in [d,e]
	pop	hl		;point to next var
	jp	clpakp		;look at next array
; step 4 - copy literals into string space
; this code is very smilar to the string garbage collect code
dncmda:	ld	hl,(vartab)	;look at simple strings
csvar:	ex	de,hl		;into [d,e]
	ld	hl,(arytab)	;limit of search
	ex	de,hl		;start in [h,l], limit in [d,e]
	call	dcompr		;done?
	jp	z,cayvar	;yes
	ld	a,(hl)		;get valtyp
	inc	hl		;point to length of long var name
	inc	hl
	inc	hl
	push	af		;save valtyp
	call	iadahl		;move past long variable name
	pop	af		;ge back valtyp
	cp	3		;string?
	jp	nz,cskpva	;skip this var, not string
	call	cdvars		;copy this guy into string space if nesc
	xor	a		;cdvars has already incremented [h,l]
cskpva:	ld	e,a
	ld	d,0		;add length of valtyp
	add	hl,de
	jp	csvar
cayva2:	pop	bc		;adjust stack
cayvar:	ex	de,hl		;save where we are
	ld	hl,(strend)	;new limit of search
	ex	de,hl		;in [d,e], limit in [h,l]
	call	dcompr		;done?
	jp	z,dnccls	;yes
	ld	a,(hl)		;get valtyp of array
	inc	hl
	inc	hl
	push	af		;save valtyp
	inc	hl
	call	iadahl		;skip over rest of array name
	ld	c,(hl)		;get length of array
	inc	hl
	ld	b,(hl)		;into [b,c]
	inc	hl
	pop	af		;get back valtyp
	push	hl		;save pointer to array element
	add	hl,bc		;point after array
	cp	3		;string array?
	jp	nz,cayva2	;no, look at next one
	ld	(temp3),hl	;save pointer to end of array
	pop	hl		;get back pointer to array start
	ld	c,(hl)		;pick up number of dims
	ld	b,0		;make double with high zero
	add	hl,bc		;go past dims
	add	hl,bc
	inc	hl		;one more to account for # of dims
caystr:	ex	de,hl		;save current position in [d,e]
	ld	hl,(temp3)	;get end of array
	ex	de,hl
	call	dcompr		;see if at end of array
	jp	z,cayvar	;get next array
	ld	bc,caystr	;do next str in array
	push	bc		;save branch address on stack
cdvars:	xor	a		;get length of array and
	or	(hl)		;set cc's on VALTYP
	inc	hl		;also pick up pointer into [d,e]
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl		;[h,l] points after descriptor
	ret	z		;ignore null strings
	push	hl		;save where we are
	ld	hl,(vartab)	;is string in program text or disk buffers?
	call	dcompr		;compare
	pop	hl		;restore where we are
	ret	c		;no, must be in string space
	push	hl		;save where we are again.
	ld	hl,(txttab)	;is it in buffers?
	call	dcompr		;test
	pop	hl		;restore where we are
	ret	nc		;in buffers, do nothing
	push	hl		;save where we are for nth time
	dec	hl		;point to start of descriptor
	dec	hl
	dec	hl
	push	hl		;save pointer to start
	call	strcpy		;copy string into dsctmp
	pop	hl		;destination in [h,l], source in [d,e]
	ld	b,3		;# of bytes to move
	call	move1		;move em
	pop	hl		;where we are
	ret
; step 5 - move stuff up into string space!
dnccls:	call	garba2		;get rid of unused strings
	ld	hl,(strend)	;load end of vars
	ld	b,h		;into [b,c]
	ld	c,l
	ld	hl,(vartab)	;start of simps into [d,e]
	ex	de,hl
	ld	hl,(arytab)
	ld	a,l		;get length of simps in [h,l]
	sub	e
	ld	l,a
	ld	a,h
	sbc	a,d
	ld	h,a
	ld	(temp9),hl	;save here
	ld	hl,(fretop)	;destination of high byte
	ld	(savfre),hl	;save fretop to restore later
	call	bltuc		;move stuff up
	ld	h,b		;now adjust top of memory below saved vars
	ld	l,c
	dec	hl		;one lower to be sure
	ld	(fretop),hl	;update fretop to reflect new value
	ld	a,(mdlflg)	;merge w/ delete?
	or	a		;test
	jp	z,ntmdlt	;no
	ld	hl,(cmsptr)	;start of lines to delete
	ld	b,h		;into [b,c]
	ld	c,l
	ld	hl,(cmeptr)	;end of lines to delete
	call	del		;delete the lines
	call	linker		;re-link lines just in case
; step 6 - load new program
ntmdlt:	ld	a,1		;set chain flag
	ld	(chnflg),a
	extrn	chnent,maxfil,lstfre,okgetm
	ld	a,(mrgflg)	;mergeing?
	or	a		;set cc'S
	jp	nz,okgetm	;do merge
	ld	a,(maxfil)	;save the number of files
	ld	(lstfre+1),a	;since we make it look like zero
	jp	chnent		;jump to load code
; step 7 - move stuff back down
	public	chnret
chnret:	xor	a		;clear chain, merge flags
	ld	(chnflg),a
	ld	(mrgflg),a
	ld	hl,(vartab)	;get current vartab
	ld	b,h		;into [b,c]
	ld	c,l
	ld	hl,(temp9)	;get length of simps
	add	hl,bc		;add to present vartab to get new arytab
	ld	(arytab),hl
	ld	hl,(fretop)	;where to start moving
	inc	hl		;one higher
	ex	de,hl		;into [d,e]
	ld	hl,(savfre)	;last byte to move
	ld	(fretop),hl	;restore fretop from this
mvbkvr:	call	dcompr		;done?
	ld	a,(de)		;move byte down
	ld	(bc),a
	inc	de		;increment pointers
	inc	bc
	jp	nz,mvbkvr
	dec	bc		;point to last var byte
	ld	h,b		;[h,l]=last var byte
	ld	l,c
	ld	(strend),hl	;this is new end
	ld	hl,(chnlin)	;get chain line #
	ld	a,h		;test for zero
	or	l
	ex	de,hl		;put in [d,e]
	ld	hl,(txttab)	;get prog start in [h,l]
	dec	hl		;point at zero before program
	jp	z,newstt	;line #=0, go...
	call	fndlin		;try to find destination line
	jp	nc,userr	;not there...
	dec	bc		;point to zero on previous line
	ld	h,b		;make text pointer for newstt
	ld	l,c
	jp	newstt		;bye...
common:	jp	data
	page
	;subttl	write
	extrn	finprt
	extrn	fout,strlit,strprt,outdo,faclo
	public	write
write:
	extrn	filget
	ld	c,md.sqo	;setup output file
	call	filget
wrtchr:	dec	hl
	call	chrgtr		;get another character
	jp	z,wrtfin	;done with write
wrtmlp:	call	frmevl		;evaluate formula
	push	hl		;save the text pointer
	call	getypr		;see if we have a string
	jp	z,wrtstr	;we do
	call	fout		;convert to a string
	call	strlit		;literalize string
	ld	hl,(faclo)	;get pointer to string
	inc	hl		;point to address field
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	a,(de)		;is number positive?
	cp	' '		;test
	jp	nz,wrtneg	;no, must be negative
	inc	de
	ld	(hl),d
	dec	hl
	ld	(hl),e
	dec	hl
	dec	(hl)		;adjust length of string
wrtneg:	call	strprt		;print the number
nxtwrv:	pop	hl		;get back text pointer
	dec	hl		;back up pointer
	call	chrgtr		;get next char
	jp	z,wrtfin	;end
	cp	59		;semicolon?
	jp	z,wasemi	;was one
	call	synchr
	defb	54o		;only possib left is comma
	dec	hl		;to compensate for later chrget
wasemi:	call	chrgtr		;fetch next char
	ld	a,54o		;put out comma
	call	outdo
	jp	wrtmlp		;back for more
wrtstr:	ld	a,34		;put out double quote
	call	outdo		;send it
	call	strprt		;print the string
	ld	a,34		;put out another double quote
	call	outdo		;send it
	jp	nxtwrv		;get next value
wrtfin:
	extrn	cmpfbc,crdo,ptrfil
	push	hl		;save text pointer
	ld	hl,(ptrfil)	;see if disk file
	ld	a,h
	or	l
	jp	z,ntrndw	;no
	ld	a,(hl)		;get file mode
	cp	md.rnd		;random?
	jp	nz,ntrndw	;no
	call	cmpfbc		;see how many bytes left
	ld	a,l		;do subtract
	sub	e
	ld	l,a
	ld	a,h
	sbc	a,d
	ld	h,a
crlfsq	defl	2		;number of bytes in cr/lf sequence
	ld	de,0-crlfsq	;subtract bytes in <cr>
	add	hl,de
	jp	nc,ntrndw	;not enough, give error eventually
nxtwsp:	ld	a,' '		;put out spaces
	call	outdo		;send space
	dec	hl		;count down
	ld	a,h		;count down
	or	l
	jp	nz,nxtwsp
ntrndw:	pop	hl		;restore [h,l]
	call	crdo		;do crlf
	jp	finprt
;	end

