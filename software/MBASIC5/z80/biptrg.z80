
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
	title	biptrg	basic interpreter pointer get routines/whg/pga
	;subttl	dimension & variable searching - ptrget
	extrn	aryta2,arytab,bltu,dimflg,errbs,error,fac,fcerr
	extrn	faclo,getstk,intidx,islet,islet2,omerr,reason,snerr,strend
	extrn	subflg,temp2,temp3,umult,valtyp,vartab,reddy,pophrt,errdd,retvar
	extrn	chrgtr,dcompr,synchr
	extrn	getypr
	extrn	nambuf,namcnt,namtmp
	extrn	optval
	extrn	parm1,prmflg,prmlen,deftbl,nofuns
	public	ptrget,bserr,ptrgt2,dim,noarys
dimcon:	dec	hl		;see if comma ended this variable
	call	chrgtr
	ret	z		;if terminator, good bye
	call	synchr
	defb	44		;must be comma
;
; the "DIM" code sets dimflg and then falls into the variable
; search routine. the variable search routine looks at
; dimflg at three different points:
;
;	1) if an entry is found, dimflg being on indicates
;		a "DOUBLY DIMENSIONED" variable
;	2) when a new entry is being built dimflg'S BEING ON
;		indicates the indices should be used for
;		the size of each indice. otherwise the default
;		of ten is used.
;	3) when the build entry code finishes, only if dimflg is
;		off will indexing be done
;
dim:	ld	bc,dimcon	;place to come back to
	push	bc
	defb	366q		;"ORI" non zero thing
				;must turn the msb on
;
; routine to read the variable name at the current text position
; and put a pointer to its value in [d,e]. [h,l] is updated
; to point to the character after the variable name.
; valtyp is setup. note that evaluating subscripts in
; a variable name can cause recursive calls to ptrget so at
; that point all values must be stored on the stack.
; on return, [a] does not reflect the value of the terminating character
;
ptrget:	xor	a		;make [a]=0
	ld	(dimflg),a	;flag it as such
	ld	c,(hl)		;get first character in [c]
ptrgt2:	call	islet		;check for letter
	jp	c,snerr		;must have a letter
	xor	a
	ld	b,a		;assume no second character
	ld	(namcnt),a	;zero namcnt
	inc	hl		;incrment text pointer
	ld	a,(hl)		;get char
	cp	'.'		;is it a dot?
	jp	c,nosec		;too small for anything reasonable
	jp	z,issec		;"." is valid var char
	cp	'9'+1		;too big for numeric?
	jp	nc,ptrgt3	;yes
	cp	'0'		;in right range?
	jp	nc,issec	;yes, was numeric
ptrgt3:	call	islet2		;set carry if not alphabetic
	jp	c,nosec		;allow alphabetics
issec:	ld	b,a		;it is a number--save in b
	push	bc		;save [b,c]
	ld	b,255		;[b] counts the characters past #2
	ld	de,nambuf-1	;the place to put the characters
vmorch:	or	128		;extra characters must have the high bit on
				;so erase can scan backwards over them
	inc	b		;increase the chacracter count
	ld	(de),a		;and store into the buffer
	inc	de		;and update the buffer pointer
	inc	hl		;increment text pointer
	ld	a,(hl)		;get char
	cp	'9'+1		;too big?
	jp	nc,vmorc1	;yes
	cp	'0'		;in range for digit
	jp	nc,vmorch	;yes, valid char
vmorc1:	call	islet2		;as are alphabetics
	jp	nc,vmorch
	cp	'.'		;dots also ok
	jp	z,vmorch	;so eat it
	ld	a,b		;check for maximum count
	cp	namlen-1	;limited to size of nambuf only
	jp	nc,snerr	;must be bad syntax
	pop	bc		;get back the stored [b,c]
	ld	(namcnt),a	;always set up count of extras
	ld	a,(hl)		;restore terminating char
nosec:
	cp	'%'+1		;not a type indicator
	jp	nc,tabtyp	;then dont check them
	ld	de,havtyp	;save jumps by using return address
	push	de
	ld	d,2		;check for integer
	cp	'%'
	ret	z
	inc	d		;check for string
	cp	'$'
	ret	z
	inc	d		;check for single precision
	cp	'!'
	ret	z
	ld	d,8		;assume its double precision
	cp	'#'		;check the character
	ret	z		;when we match, setup valtyp
	pop	af		;pop off non-used havtyp address
tabtyp:	ld	a,c		;get the starting character
	and	127		;get rid of the user-defined
				;function bit in [c]
	ld	e,a		;build a two byte offset
	ld	d,0
	push	hl		;save the text pointer
	ld	hl,deftbl-'A'	;see what the default is
	add	hl,de
	ld	d,(hl)		;get the type out of the table
	pop	hl		;get back the text pointer
	dec	hl		;no marking character
havtyp:	ld	a,d		;setup valtyp
	ld	(valtyp),a
	call	chrgtr		;read past type marker
	ld	a,(subflg)	;get flag whether to allow arrays
	dec	a		;if subflg=1, "ERASE" has called
	jp	z,ersfin	;ptrget, and special handling must be done
	jp	p,noarys	;no arrays allowed
	ld	a,(hl)		;get char back
	sub	'('		;array perhaps (if subflg set never will match)
	jp	z,isary		;it is!
	sub	'['-')'+1	;see if left bracket
	jp	z,isary		;if so, ok subscript
noarys:	xor	a		;allow parens again
	ld	(subflg),a	;save in flag location
	push	hl		;save the text pointer
	ld	a,(nofuns)	;are functions active?
	or	a
	ld	(prmflg),a	;indicate if parm1 needs searching
	jp	z,snfuns	;no functions so no special search
	ld	hl,(prmlen)	;get the size to search
	ld	de,parm1	;get the base of the search
	add	hl,de		;[h,l]= place to stop searching
	ld	(aryta2),hl	;set up stopping point
	ex	de,hl		;[h,l]=start [d,e]=end
	jp	lopfnd		;start looping
loptop:	ld	a,(de)		;get the valtyp of this simple variable
	ld	l,a		;save so we know how much to skip
	inc	de
	ld	a,(de)		;[a]=first character of this variable
	inc	de		;point to 2nd char of var name
	cp	c		;see if our variable matches
	jp	nz,notit1
	ld	a,(valtyp)	;get type were looking for
	cp	l		;compare with our valtyp
	jp	nz,notit1	;not right kind -- skip it
	ld	a,(de)		;see if second chacracter matches
	cp	b
	jp	z,finptr	;that was it, all done
notit1:	inc	de
nfinpt:	ld	a,(de)		;get length of var name in [a]
snomat:
	;skip over the
	;current variable since we didn'T MATCH
	ld	h,0		;[h,l]=number of bytes to skip
	add	a,l		;add valtype to length of var
	inc	a		;plus one
	ld	l,a		;save in [l] to make offset
	add	hl,de		;add on the pointer
lopfnd:	ex	de,hl		;[d,e]=pointer into simple variables
	ld	a,(aryta2)	;are low bytes different
	cp	e		;test
	jp	nz,loptop	;yes
	ld	a,(aryta2+1)	;are high bytes different
	cp	d		;the same?
	jp	nz,loptop	;no, must be more vars to examine

notfns:	ld	a,(prmflg)	;has parm1 been searched
	or	a
	jp	z,smkvar	;if so, create variable
	xor	a		;flag parm1 as searched
	ld	(prmflg),a
snfuns:	ld	hl,(arytab)	;stopping point is [aryta2]
	ld	(aryta2),hl
	ld	hl,(vartab)	;set up starting point
	jp	lopfnd

; this is exit for varptr and others
varnot:
	ld	d,a		;zero [d,e]
	ld	e,a
	pop	bc		;get rid of pushed [d,e]
	ex	(sp),hl		;put return address back on stack
	ret			;return from ptrget

smkvar:	pop	hl		;[h,l]= text pointer
	ex	(sp),hl		;[h,l]= return address
	push	de		;save current variable table position
	extrn	varret
	ld	de,varret	;are we returning to varptr?
	call	dcompr		;compare
	jp	z,varnot	;yes.
	extrn	comptr,compt2	;return here if not found
	ld	de,comptr
	call	dcompr
	jp	z,varnot
	ld	de,compt2	;2nd one
	call	dcompr
	jp	z,varnot
	ld	de,retvar	;did eval call us?
	call	dcompr		;if so, don'T MAKE A NEW VARIABLE
	pop	de		;restore the position
	jp	z,finzer	;make fac zero (all types) and skip return
	ex	(sp),hl		;put return address back
	push	hl		;put the text pointer back
	push	bc		;save the looks
	ld	a,(valtyp)	;get length of symbol table entry
	ld	b,a		;[b]=valtyp
	ld	a,(namcnt)	;include extra characters in size
	add	a,b
	inc	a		;as well as the extra character count
	ld	c,a		;[b,c]=length of this variable
	push	bc		;save the valtyp on the stack
	ld	b,0		;[b]=0
	inc	bc		;make the length include
				;the looks too
	inc	bc
	inc	bc
				;everything up by
	ld	hl,(strend)	;the current end of storage
	push	hl		;save this #
	add	hl,bc		;add on the amount of space
				;extra now being used
	pop	bc		;pop off high address to move
	push	hl		;save new candidate for strend
	call	bltu		;block transfer and make sure
				;we are not overflowing the
				;stack space
	pop	hl		;[h,l]=new strend
	ld	(strend),hl	;store since was ok
				;there was room, and block transfer
				;was done, so update pointers
	ld	h,b		;get back [h,l] pointing at the end
	ld	l,c		;of the new variable
	ld	(arytab),hl	;update the array table pointer
zeroer:	dec	hl		;[h,l] is returned pointing to the
	ld	(hl),0		;end of the variable so we
	call	dcompr		;zero backwards to [d,e] which
	jp	nz,zeroer	;points to the start of the variable
	pop	de		;[e]=valtyp
	ld	(hl),d		;valtyp is in high order
	inc	hl
	pop	de
	ld	(hl),e		;put description
	inc	hl
	ld	(hl),d		;of this variable
				;into memory
	call	nputsb		;save the extra characters in the name
	ex	de,hl		;pointer at variable into [d,e]
	inc	de		;point at the value
	pop	hl		;restore the text pointer
	ret
finptr:	inc	de		;point at the extra character count
	ld	a,(namcnt)	;see if the extra counts match
	ld	h,a		;save length of new var
	ld	a,(de)		;get length of current var
	cp	h		;are they the same?
	jp	nz,nfinpt	;skip extras and continue search
	or	a		;length zero?
	jp	nz,ntfprt	;no, more chars to look at
	inc	de		;point to value of var
	pop	hl		;restore text pointer
	ret			;all done with this var
ntfprt:	ex	de,hl
	call	matsub		;see if the characters match
	ex	de,hl		;table pointer back into [d,e]
	jp	nz,snomat	;if not, continue search
	pop	hl		;get back the text pointer
	ret
;
; make all types zero and skip return
;
finzer:
	ld	(fac),a		;make singles and doubles zero
	ld	h,a		;make integers zero
	ld	l,a
	ld	(faclo),hl
	call	getypr		;see if its a string
	jp	nz,pophr2	;if not, done
	ld	hl,reddy-1	;make it a null string by
	ld	(faclo),hl	;pointing at a zero
pophr2:	pop	hl		;get the text pointer
	ret			;return from eval


	page
	;subttl	multiple dimension code

;
; format of arrays in core
;
; descriptor
;	low byte = second charcter (200 bit is string flag)
;	high byte = first character
; length of array in core in bytes (does not include descriptor)
; number of dimensions 1 byte
; for each dimension starting with the first a list
; (2 bytes each) of the max indice+1
; the values
;
isary:	push	hl		;save dimflg and valtyp for recursion
	ld	hl,(dimflg)
	ex	(sp),hl		;text pointer back into [h,l]
	ld	d,a		;set # dimensions =0
indlop:	push	de		;save number of dimensions
	push	bc		;save looks
	ld	de,namcnt	;point at the area to save
	ld	a,(de)		;get length
	or	a		;is it zero?
	jp	z,shtnam	;yes, short name
	ex	de,hl		;save the text pointer in [d,e]
	add	a,2		;we want smallest int .ge.(namcnt+1)/2
	rra
	ld	c,a		;see if there is room to save this stuff
	call	getstk
	ld	a,c		;restore count of pushes
lppsnm:	ld	c,(hl)		;get values to push
	inc	hl
	ld	b,(hl)
	inc	hl
	push	bc		;and do the save
	dec	a		;[a] times
	jp	nz,lppsnm
	push	hl		;save the address to store to
	ld	a,(namcnt)	;save the number of bytes for a count
	push	af
	ex	de,hl		;restore the text pointer
	call	intidx		;evaluate indice into [d,e]
	pop	af		;count telling how much to restore
	ld	(namtmp),hl	;save the text pointer
	pop	hl		;the place to restore to
	add	a,2		;calculate byte pops again
	rra
lplnam:	pop	bc
	dec	hl
	ld	(hl),b
	dec	hl
	ld	(hl),c
	dec	a		;loop [a] times poping name back into nambuf
	jp	nz,lplnam
	ld	hl,(namtmp)
	jp	lngnam		;was long one
shtnam:	call	intidx		;evaluate it
	xor	a		;make sure namcnt=0
	ld	(namcnt),a
lngnam:
	ld	a,(optval)	;see what the option base is
	or	a
	jp	z,optb0		;if base 0 do nothing
	ld	a,d		;check for 0 subscript
	or	e		;which is illegal in base 1
	dec	de		;adjust subscript
	jp	z,bserr
optb0:
	pop	bc		;pop off the looks
	pop	af		;[a] = number of dimensions so far
	ex	de,hl		;[d,e]=text pointer
				;[h,l]=indice
	ex	(sp),hl		;put the indice on the stack
				;[h,l]=valtyp & dimflg
	push	hl		;resave valtyp and dimflg
	ex	de,hl		;[h,l]=text pointer
	inc	a		;increment # of dimensions
	ld	d,a		;[d]=number of dimensions
	ld	a,(hl)		;get terminating character
	cp	44		;a comma so more indices follow?
	jp	z,indlop	;if so, read more
	cp	')'		;expected terminator?
	jp	z,dochrt	;do chrget for next one
	cp	']'		;bracket?
	jp	nz,snerr	;no, give error
dochrt:	call	chrgtr
subsok:	ld	(temp2),hl	;save the text pointer
	pop	hl		;[h,l]= valtyp & dimflg
	ld	(dimflg),hl	;save valtyp and dimflg
	ld	e,0		;when [d,e] is poped into psw, we
				;don'T WANT THE ZERO FLAG TO BE SET, SO
				;"ERASE" will have a unique condition
	push	de		;save number of dimensions
	public	ersfin
	defb	21o		;"LXI	D," over the next two bytes
ersfin:	push	hl		;save the text pointer
	push	af		;save a dummy number of dimensions
				;with the zero flag set
;
; at this point [b,c]=looks. the text pointer is in temp2.
; the indices are all on the stack, followed by the number of dimensions.
;
	ld	hl,(arytab)	;[h,l]=place to start the search
	defb	76o		;"MVI A," around the next byte
lopfda:	add	hl,de		;skip over this array since it'S
				;not the one
	ex	de,hl		;[d,e]=current search point
	ld	hl,(strend)	;get the place to stop into [h,l]
	ex	de,hl		;[h,l]=search point
	call	dcompr		;stopping time?
	jp	z,notfdd	;yes, couldn'T FIND THIS ARRAY
	ld	e,(hl)		;get valtyp in [e]
	inc	hl
	ld	a,(hl)		;get first character
	inc	hl
	cp	c		;see if it matches
	jp	nz,nmary1	;not this one
	ld	a,(valtyp)	;get type of var were looking for
	cp	e		;same as this one?
	jp	nz,nmary1	;no, skip this var
	ld	a,(hl)		;get second character
	cp	b		;another match?
	jp	z,cmpnam	;match, check out rest of name
nmary1:	inc	hl		;point to size entry
bnamsz:	ld	e,(hl)		;get var name length in [e]
	inc	e		;add one to get correct length
	ld	d,0		;high byte of zero
	add	hl,de		;add offset
cnomat:
	ld	e,(hl)		;[d,e]=length
	inc	hl		;of the array being looked at
	ld	d,(hl)
	inc	hl
	jp	nz,lopfda	;if no match, skip this one
				;and try again
	ld	a,(dimflg)	;see if called by "DIM"
	or	a		;zero means no
	extrn	dderr
	jp	nz,dderr	;preserve [d,e], and dispatch to
				;"REDIMENSIONED VARIABLE" error
				;if its "DIM" calling ptrget
;
; temp2=the text pointer
; we have located the variable we were looking for
; at this point [h,l] points beyond the size to the number of dimensions
; the indices are on the stack followed by the number of dimensions
;
	pop	af		;[a]=number of dimensions
	ld	b,h		;set [b,c] to point at number of dimensions
	ld	c,l
	jp	z,pophrt	;"ERASE" is done at this point, so return
				;to do the actual erasure
	sub	(hl)		;make sure the number given now and
				;and when the array was set up are the
				;same
	jp	z,getdef	;jump off and read
				;the indices....

bserr:	ld	de,0+errbs	;"SUBSCRIPT OUT OF RANGE"
	jp	error
cmpnam:	inc	hl		;point to length of name
	ld	a,(namcnt)	;see if count matches count in complex table
	cp	(hl)
	jp	nz,bnamsz	;bad name size just skip and set nz cc
	inc	hl		;point one byte after length field
	or	a		;length zero?
	jp	z,cnomat	;then found, exit
	dec	hl		;move back one
	call	matsub		;otherwise try to match characters
	jp	cnomat		;using common subroutine
;
; here when variable is not found in the array table
;
; building an entry:
;
;	put down the descriptor
;	setup numer of dimensions
;	make sure there is room for the new entry
;	remember varptr
;	tally=4 (valtyp for the extended)
;	skip 2 locs for later fill in -- the size
; loop:	get an indice
;	put number +1 down at varptr and increment varptr
;	tally= tally * number+1
;	decrement number-dims
;	jnz	loop
;	call reason with [h,l] reflecting last loc of variable
;	update strend
;	zero backwards
;	make tally include maxdims
;	put down tally
;	if called by dimension, return
;	otherwise index into the variable as if it
;	were found on the initial search
;
notfdd:
	ld	a,(valtyp)	;get valtyp of new var
	ld	(hl),a		;put down the variable type
	inc	hl
	ld	e,a
	ld	d,0		;[d,e]=size of one value (valtyp)
	pop	af		;[a]=number of dimensions
	jp	z,ptrrnz	;called by chain, just return non-zero
	ld	(hl),c		;put down the descriptor
	inc	hl
	ld	(hl),b
	call	nputsb		;store the extra characters in the table
	inc	hl
	ld	c,a		;[c]=number of two byte entries needed
				;to store the size of each dimension
	call	getstk		;get space for dimension entries
	inc	hl		;skip over the size locations
	inc	hl
	ld	(temp3),hl	;save the location to put the size
				;in -- points at the number of dimensions
	ld	(hl),c		;store the number of dimensions
	inc	hl
	ld	a,(dimflg)	;called by dimension?
	rla			;set carry if so
	ld	a,c		;[a]=number of dimensions
loppta:
	jp	c,popdim
	push	af
	ld	a,(optval)	;get the option base
	xor	11		;map 0 to 11 and 1 to 10
	ld	c,a		;[b,c]=default dimension
	ld	b,0
	pop	af
	jp	nc,notdim	;default dimensions to ten
popdim:	pop	bc		;pop off an indice into [b,c]
	inc	bc		;add one to it for the zero entry
notdim:	ld	(hl),c		;put the maximum down
	push	af		;save the number of dimensions and
				;dimflg (carry)
	inc	hl
	ld	(hl),b
	inc	hl
	call	umult		;multiply [b,c]=newmax by curtol=[d,e]
	pop	af		;get the number of dimensions and
				;dimflg (carry) back
	dec	a		;decrement the number of dimensions left
	jp	nz,loppta	;handle the other indices
	push	af		;save dimflg (carry)
	ld	b,d		;[b,c]=size
	ld	c,e
	ex	de,hl		;[d,e]=start of values
	add	hl,de		;[h,l]=end of values
	jp	c,omerr		;out of memory pointer being generated?
	call	reason		;see if there is room for the values
	ld	(strend),hl	;update the end of storage
zerita:	dec	hl		;zero the new array
	ld	(hl),0
	call	dcompr		;back at the beginning?
	jp	nz,zerita	;no, zero more
	inc	bc		;add one to the size to include
				;the byte for the number of dimensions
	ld	d,a		;[d]=zero
	ld	hl,(temp3)	;get a pointer at the number of dimensions
	ld	e,(hl)		;[e]=number of dimensions
	ex	de,hl		;[h,l]=number of dimensions
	add	hl,hl		;[h,l]=number of dimensions times two
	add	hl,bc		;add on the size
				;to get the total number of bytes used
	ex	de,hl		;[d,e]=total size
	dec	hl		;back up to point to location to put
	dec	hl		;the size of the array in bytes in.
	ld	(hl),e		;put down the size
	inc	hl
	ld	(hl),d
	inc	hl
	pop	af		;get back dimflg (carry) and set [a]=0
	jp	c,finnow
;
; at this point [h,l] points beyond the size to the number of dimensions
; strategy:
;	numdim=number of dimensions
;	curtol=0
; inlpnm:get a new indice
;	pop new max into curmax
;	make sure indice is not too big
;	mutliply curtol by curmax
;	add indice to curtol
;	numdim=numdim-1
;	jnz	inlpnm
;	use curtol*4 (valtyp for extended) as offset
;
getdef:	ld	b,a		;[b,c]=curtol=zero
	ld	c,a
	ld	a,(hl)		;[a]=number of dimensions
	inc	hl		;point past the number of dimensions
	defb	26q		;"MVI D," around the next byte
inlpnm:	pop	hl		;[h,l]= pointer into variable entry
	ld	e,(hl)		;[d,e]=maximum for the current indice
	inc	hl
	ld	d,(hl)
	inc	hl
	ex	(sp),hl		;[h,l]=current indice
				;pointer into the variable goes on the stack
	push	af		;save the number of dimensions
	call	dcompr		;see if the current indice is too big
	jp	nc,bserr	;if so "BAD SUBSCRIPT" error
	call	umult		;curtol=curtol*current maximum
	add	hl,de		;add the indice to curtol
	pop	af		;get the number of dimensions in [a]
	dec	a		;see if all the indices have been processed
	ld	b,h		;[b,c]=curtol in case we loop back
	ld	c,l
	jp	nz,inlpnm	;process the rest of the indices
	ld	a,(valtyp)	;see how big the values are
				;and multiply by that size
	ld	b,h		;save the original value for multiplying
	ld	c,l		;by three
	add	hl,hl		;multiply by two at least
	sub	4		;for integers and strings
				;no more multiplying by two
	jp	c,smlval
	add	hl,hl		;now multiplied by four
	jp	z,donmul	;if single all done
	add	hl,hl		;by eight for doubles
smlval:
	or	a		;fix cc'S FOR Z-80
	jp	po,donmul	;for strings
	add	hl,bc		;add in the original
donmul:
	pop	bc		;pop off the address of where the values
				;begin
	add	hl,bc		;add it onto curtol to get the
				;place the value is stored
	ex	de,hl		;return the pointer in [d,e]
finnow:	ld	hl,(temp2)	;reget the text pointer
	ret
ptrrnz:	scf			;return with non-zero in [a]
	sbc	a,a		;and condition codes set
	pop	hl		;restore test pointer
	ret

;
; long variable name subroutines. after the normal 2 character name
; the count of additional characters is stored. following this
; comes the characters in order with the high bit turned on so a backward
; scan is possible
;
	public	iadahl
iadahl:	ld	a,(hl)		;get the character count
	inc	hl
addahl:	push	bc		;add [a] to [h,l]
	ld	b,0
	ld	c,a
	add	hl,bc
	pop	bc		;restore the saved [b,c]
	ret
nputsb:	push	bc		;this routine store the "LONG" name at [h,l]
	push	de
	push	af
	ld	de,namcnt	;point at data to save
	ld	a,(de)		;get the count
	ld	b,a
	inc	b		;[b]= number of bytes to save
slplng:	ld	a,(de)		;fetch store value
	inc	de
	inc	hl		;move up to store name into table
	ld	(hl),a		;do the store
	dec	b		;and repeat [b] times
	jp	nz,slplng	;for the count and data
	pop	af
	pop	de
	pop	bc
	ret

matsub:	push	de		;this routine tries to perform a match
	push	bc
	ld	de,nambuf	;point at count and data
	ld	b,a		;[b]=character count
	inc	hl		;point at the data
	inc	b		;start off loop
slpmat:	dec	b		;matched all characters yet?
	jp	z,ismat2	;if so, its a match
	ld	a,(de)		;get another character
	cp	(hl)		;see if its the same
	inc	hl		;move forward in definition table
	inc	de		;more forward in stored name
	jp	z,slpmat	;if match keep going until end
	ld	a,b		;need to advance by [b]-1 to skip bad chars
	dec	a
	call	nz,addahl	;use the common subroutine. [h,l]=[h,l]+[a]
	xor	a		;set cc'S NON ZERO FOR NO MATCH
	dec	a		;and return [a]=ff
ismat2:	pop	bc		;restore saved registers
	pop	de
	ret

	page
;	end
