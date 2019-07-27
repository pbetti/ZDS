
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
	title	bistrs	basic interpreter string  routines/whg/pga etc.
	extrn	movrm
	extrn	arytab,bltuc,conint,crfin,dsctmp,errls,error,errso,errst
	extrn	eval,faclo,fcerr,fout,fretop,frmeql,frmevl,frmprn
	extrn	getbyt,memsiz,outdo,pophrt,ptrget,signs,snerr
	extrn	strend,temppt,tempst,tstop,valtyp,vartab,sngflt,temp8
	extrn	givdbl,fin,aryta2,chkstr
	public	lhsmid
	extrn	aryta2,findbl,getbcd,prmprv,temp9,vmove
	extrn	getypr
	extrn	chrgtr,dcompr,synchr
	extrn	iadahl
	public	chr$,strprt,stroui,len,frestr,strcmp,val,asc,asc2,strlti
	public	strout,fretms,fretmp,right$,left$,garba2,str$
	public	fre,strlit,strcpy,cat,strlt3,mid$
	public	strini,strin1,strad1,putdei
;
; the following routine compares two strings
; one with desc in [d,e] other with desc. in [faclo, faclo+1]
; a=0 if strings equal
; a=377 if b,c,d,e .gt. faclo
; a=1 if b,c,d,e .lt. faclo
;
strcmp:	call	frestr		;free up the fac string, and get the
				;pointer to the fac descriptor in [h,l]
	ld	a,(hl)		;save the length of the fac string in [a]
	inc	hl
	ld	c,(hl)		;save the pointer at the fac string
				;data in [b,c]
	inc	hl
	ld	b,(hl)
	pop	de		;get the stack string pointer
	push	bc		;save the pointer at the fac string data
	push	af		;save the fac string length
	call	fretmp		;free up the stack string and return
				;the pointer to the stack string descriptor
				;in [h,l]
	pop	de		;[d]=length of fac string
	ld	e,(hl)		;[e]=length of stack string
	inc	hl
	ld	c,(hl)		;[b,c]=pointer at stack string
	inc	hl
	ld	b,(hl)
	pop	hl		;get back 2nd character pointer
csloop:	ld	a,e		;both strings ended
	or	d		;test by or'ING THE LENGTHS TOGETHER
	ret	z		;if so, return with a zero
	ld	a,d		;get faclo string length
	sub	1		;set carry and make [a]=255 if [d]=0
	ret	c		;return if that string ended
	xor	a		;must not have been zero, test case
	cp	e		;of b,c,d,e string having ended first
	inc	a		;return with a=1
	ret	nc		;test the condition
;here when neither string ended
	dec	d		;decrement both character counts
	dec	e
	ld	a,(bc)		;get character from b,c,d,e string
	inc	bc
	cp	(hl)		;compare with faclo string
	inc	hl		;bump pointers (inx doesnt clobber cc'S)
	jp	z,csloop	;if both the same, must be more to strings
	ccf			;here when strings differ
	jp	signs		;set [a] according to carry
				;subttl	string functions
	extrn	fouto,fouth
	public	stro$,strh$
; the stro$ function takes a number and gives
; a string with the characters the number would give if
; output in octal
;
stro$:	call	fouto		;put octal number in fbuffr
	jp	str$1		;jump into str$ code

; strh$ same as stro$ except uses hex instead of octal
strh$:	call	fouth		;put hex number in fbuffr
	jp	str$1		;jump into str$ code
;
; the str$ function takes a number and gives
; a string with the characters the output of the number
; would have given
;
str$:
	;is a numeric
	call	fout		;do its output
str$1:	call	strlit		;scan it and turn it into a string
	call	frefac		;free up the temp
	ld	bc,finbck
	push	bc		;set up answer in new temp
;
; strcpy creates a copy of the string
; whose descriptor is pointed to by [h,l].
; on return [d,e] points to dsctmp
; which has the string info (length,where copied to)
;
strcpy:	ld	a,(hl)		;get length
	inc	hl		;move up to the pointer
	push	hl		;get pointer to pointer of arg
	call	getspa		;get the space
	pop	hl		;find out where string to copy
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	call	strad2		;setup dsctmp
	push	hl		;save pointer to dsctmp
	ld	l,a		;get character count into [l]
	call	movstr		;move the chars in
	pop	de		;restore pointer to dsctmp
	ret			;return

strin1:	ld	a,1		;make one char string (chr$, inkey$)
strini:	call	getspa		;get some string space ([a] chars)
strad2:	ld	hl,dsctmp	;get desc. temp
strad1:	push	hl		;save desc. pointer
	ld	(hl),a		;save character count
putdei:	inc	hl		;store [d,e]=pointer to free space
	ld	(hl),e
	inc	hl
	ld	(hl),d
	pop	hl		;and restore [h,l] as the descriptor pointer
	ret
;
; strlt2 takes the string literal whose first character
; is pointed by [h,l]+1 and builds a descriptor for it.
; the descriptor is initially built in dsctmp, but putnew
; transfers it into a temporary and leaves a pointer
; at the temporary in faclo. the characters other than
; zero that terminate the string should be set up in [b]
; and [d]. it the terminator is a quote, the quote is skipped
; over. leading quotes should be skipped before call. on return
; the character after the string literal is pointed to
; by [h,l] and is in [a], but the condition codes are
; not set up.
;
	public	strlt2
strlit:	dec	hl
strlti:	ld	b,34		;assume str ends on quote
strlt3:	ld	d,b
strlt2:	push	hl		;save pointer to start of literal
	ld	c,255		;initialize character count
strget:	inc	hl
	ld	a,(hl)		;get char
	inc	c		;bump character count
	or	a		;if 0, (end of line) done
	jp	z,strfin	;test
	cp	d
	jp	z,strfin
	cp	b		;closing quote
	jp	nz,strget	;no, go back for more
strfin:	cp	34		;if quote terminates the string
	call	z,chrgtr	;skip over the quote
	push	hl		;save pointer at end of string
	ld	a,b		;were we scanning an unquoted string?
	cp	44
	jp	nz,nttrls	;if not, don'T SUPPRESS TRAILING SPACES
	inc	c		;fix [c] which is the character count
lptrls:	dec	c		;decrement until we find a non-space character
	jp	z,nttrls	;don'T GO PAST START (ALL SPACES)
	dec	hl		;look at previous character
	ld	a,(hl)
	cp	' '
	jp	z,lptrls	;if so continue looking
nttrls:	pop	hl
	ex	(sp),hl
	inc	hl
	ex	de,hl		;get pointer to temp
	ld	a,c		;get character count in a
	call	strad2		;save str info
;
; some string function is returning a result in dsctmp
; we want to setup a temp descriptor with dcstmp in it
; put a pointer to the descriptor in faclo and flag the
; result as type string
;
	public	putnew
putnew:	ld	de,dsctmp	;[d,e] point at result descriptor
	public	puttmp
	defb	76q		;skip the next byte ("MVI AL,")
puttmp:	push	de		;save a pointer to the start of the string
	ld	hl,(temppt)	;[h,l]=pointer to first free temp
	ld	(faclo),hl	;pointer at where result descriptor will be
	ld	a,3
	ld	(valtyp),a	;flag this as a string
	call	vmove		;and move the value into a temporary
	ld	de,dsctmp+3	;if the call is to puttmp, [d,e]
				;will not equal dsctmp +3
	call	dcompr		;dsctmp is just beyond the temps
				;and if temppt points at it there
				;are no free temps
	ld	(temppt),hl	;save new temporary pointer
	pop	hl		;get the text pointer
	ld	a,(hl)		;get current character into [a]
	ret	nz
	ld	de,0+errst	;"STRING TEMPORARY" error
	jp	error		;go tell him
;
; print the string pointed to by [h,l] which ends with a zero
; if the string is below dsctmp it will be copied into string space
;
stroui:	inc	hl		;point at next character
strout:	call	strlit		;get a string literal
;
; print the string whose descriptor is pointed to by faclo.
;
strprt:	call	frefac		;return temp pointer by faclo
	call	getbcd		;[d]=length [b,c]=pointer at data
	inc	d		;increment and decrement early
				;to check for null string
strpr2:	dec	d		;decrement the length
	ret	z		;all done
	ld	a,(bc)		;get character to print
	call	outdo
	cp	13
	call	z,crfin
	inc	bc		;point to the next character
	jp	strpr2		;and print it...
	page
				;subttl	string garbage collection - getspa, garbag
;
; getspa - get space for character string
; may force garbage collection.
;
; # of chars (bytes) in [a]
; returns with pointer in [d,e] otherwise if cant get space
; blows off to "OUT OF STRING SPACE" type error.
;
	public	getspa
getspa:	or	a		;must be non zero. signal no garbag yet
	defb	16q		;"MVI C" around the next byte
trygi2:	pop	af		;in case collected what was length?
	push	af		;save it back
	ld	hl,(strend)
	ex	de,hl		;in [d,e]
	ld	hl,(fretop)	;get top of free space in [h,l]
	cpl			;-# of chars
	ld	c,a		;in [b,c]
	ld	b,255
	add	hl,bc		;subtract from top of free
	inc	hl
	call	dcompr		;compare the two
	jp	c,garbag	;not enough room for string, offal time
	ld	(fretop),hl	;save new bottom of memory
	inc	hl		;move back to point to string
	ex	de,hl		;return with pointer in [d,e]
	public	ppswrt
ppswrt:	pop	af		;get character count
	ret			;return from getspa

garbag:	pop	af		;have we collected before?
	ld	de,0+errso	;get ready for out of string space error
	jp	z,error		;go tell user he lost
	cp	a		;set zero flag to say weve garbaged
	push	af		;save flag back on stack
	ld	bc,trygi2	;place for garbag to return to.
	push	bc		;save on stack
garba2:	ld	hl,(memsiz)	;start from top down
fndvar:	ld	(fretop),hl	;like so
	ld	hl,0		;get double zero
	push	hl		;say didnt see vars this pass
	ld	hl,(strend)	;force dvars to ignore strings
				;in the program text (literals, data)
	push	hl		;force find high address
	ld	hl,tempst	;get start of string temps
tvar:	ex	de,hl		;save in [d,e]
	ld	hl,(temppt)	;see if done
	ex	de,hl		;flip
	call	dcompr		;test
				;cannot run in ram since it stores to mess up basic
	ld	bc,tvar		;force jump to tvar
	jp	nz,dvar2	;do temp var garbage collect

	ld	hl,prmprv	;setup iteration for parameter blocks
	ld	(temp9),hl
	ld	hl,(arytab)	;get stopping point in [h,l]
	ld	(aryta2),hl	;store in stop location
	ld	hl,(vartab)	;get starting point in [h,l]

svar:	ex	de,hl
	ld	hl,(aryta2)	;get stopping location
	ex	de,hl
	call	dcompr		;see if at end of simps
	jp	z,aryvar
	ld	a,(hl)		;get valtyp
	inc	hl		;bump pointer twice
	inc	hl		;
	inc	hl		;point at the value
	push	af		;save valtyp
	call	iadahl		;and skip over extra characters and count
	pop	af
	cp	3		;see if its a string
	jp	nz,skpvar	;if not, just skip around it
	call	dvars		;collect it
	xor	a		;and don'T SKIP ANYTHING MORE
skpvar:	ld	e,a
	ld	d,0		;[d,e]=amount to skip
	add	hl,de
	jp	svar		;get next one
aryvar:	ld	hl,(temp9)	;get link in parameter block chain
	ld	a,(hl)		;go back one level
	inc	hl
	ld	h,(hl)
	ld	l,a
	or	h		;was that the end?
	ex	de,hl		;setup to start arrays
	ld	hl,(arytab)
	jp	z,aryva4	;otherwise garbage collect arrays
	ex	de,hl
	ld	(temp9),hl	;setup next link in chain for iteration
	inc	hl		;skip chain pointer
	inc	hl
	ld	e,(hl)		;pick up the length
	inc	hl
	ld	d,(hl)
	inc	hl
	ex	de,hl		;set [d,e]= actual end address by
	add	hl,de		;adding base to length
	ld	(aryta2),hl	;set up stop location
	ex	de,hl
	jp	svar

aryva2:	pop	bc		;get rid of stack garbage
aryva4:	ex	de,hl		;save aryvar in [d,e]
	ld	hl,(strend)	;get end of arrays
	ex	de,hl		;flip back
	call	dcompr		;see if done with arrays
	jp	z,grbpas	;yes, see if done collecting
	ld	a,(hl)		;get the value type into [a]
	inc	hl
	push	af		;save the valtyp
	inc	hl		;skip the name characters
	inc	hl
	call	iadahl		;skip the extra characters
	ld	c,(hl)		;pick up the length
	inc	hl
	ld	b,(hl)
	inc	hl
	pop	af		;restore the valtyp
	push	hl		;save pointer to dims
	add	hl,bc		;add to current pointer position
	cp	3		;see if its a string
	jp	nz,aryva2	;if not just skip it
	ld	(temp8),hl	;save end of array
	pop	hl		;get back current position
	ld	c,(hl)		;pick up number of dims
	ld	b,0		;make double with high zero
	add	hl,bc		;go past dims
	add	hl,bc		;by adding on twice #dims (2 byte guys)
	inc	hl		;one more to account for #dims.
arystr:	ex	de,hl		;save current posit in [d,e]
	ld	hl,(temp8)	;get end of array
	ex	de,hl		;fix [h,l] back to current
	call	dcompr		;see if at end of array
	jp	z,aryva4	;end of array, try next array
	ld	bc,arystr	;addr of where to return to
dvar2:	push	bc		;goes on stack
dvar:
dvars:	xor	a
	or	(hl)		;see if its the null string
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl		;[d,e]=pointer at the value
	ret	z		;null string, return
	ld	b,h		;move [h,l] to [b,c]
	ld	c,l
	ld	hl,(fretop)	;get pointer to top of string free space
	call	dcompr		;is this strings pointer .lt. fretop
	ld	h,b		;move [b,c] back to [h,l]
	ld	l,c
	ret	c		;if not, no need to mess with it furthur
	pop	hl		;get return address off stack
	ex	(sp),hl		;get max seen so far & save return address
	call	dcompr		;lets see
	ex	(sp),hl		;save max seen & get return address off stack
	push	hl		;save return address back
	ld	h,b		;move [b,c] back to [h,l]
	ld	l,c
	ret	nc		;if not, lets look at next var
	pop	bc		;get return addr off stack
	pop	af		;pop off max seen
	pop	af		;and variable pointer
	push	hl		;save new variable pointer
	push	de		;and new max pointer
	push	bc		;save return address back
	ret			;and return
;
; here when made one complete pass thru string vars
;
grbpas:	pop	de		;pop off max pointer
	pop	hl		;and get variable pointer
	ld	a,l		;get low in
	or	h		;see if zero pointer
	ret	z		;if end of collection,
				;then maybe return to getspa
	dec	hl		;currently just past the descriptor
	ld	b,(hl)		;[b]=high byte of data pointer
	dec	hl
	ld	c,(hl)		;[b,c]=pointer at string data
	push	hl		;save this location so the pointer
				;can be updated after the string is
				;moved
	dec	hl
	ld	l,(hl)		;[l]=string length
	ld	h,0		;[h,l] get character count
	add	hl,bc		;[h,l]=pointer beyond string
	ld	d,b
	ld	e,c		;[d,e]=original pointer
	dec	hl		;don'T MOVE ONE BEYOND STRING
	ld	b,h		;get top of string in [b,c]
	ld	c,l
	ld	hl,(fretop)	;get top of free space
	call	bltuc		;move string
	pop	hl		;get back pointer to desc.
	ld	(hl),c		;save fixed addr
	inc	hl		;move pointer
	ld	(hl),b		;high part
	ld	l,c
	ld	h,b		;[h,l]=new pointer
	dec	hl		;fix up fretop
	jp	fndvar		;and try to find high again

	page
	;subttl	string concatenation
;
; the following routine concatenates two strings
; the faclo contains the first one at this point,
; [h,l] points beyond the + sign after it
;
cat:	push	bc		;put old precedence back on
	push	hl		;save text pointer
	ld	hl,(faclo)	;get pointer to string desc.
	ex	(sp),hl		;save on stack & get text pointer back
	call	eval		;evaluate rest of formula
	ex	(sp),hl		;save text pointer, get back desc.
	call	chkstr
	ld	a,(hl)
	push	hl		;save desc. pointer.
	ld	hl,(faclo)	;get pointer to 2nd desc.
	push	hl		;save it
	add	a,(hl)		;add two lengths together
	ld	de,0+errls	;see if result .lt. 256
	jp	c,error		;error "LONG STRING"
	call	strini		;get initial string
	pop	de		;get 2nd desc.
	call	fretmp
	ex	(sp),hl		;save pointer to it
	call	fretm2		;free up 1st temp
	push	hl		;save desc. pointer (first)
incstr	defl	2

incstr	defl	1
	ld	hl,(dsctmp+incstr);get pointer to first
	ex	de,hl		;in [d,e]
	call	movins		;move in the first string
	call	movins		;and the second
	ld	hl,tstop	;cat reenters formula evaluation at tstop
	ex	(sp),hl
	push	hl		;text pointer off first
	jp	putnew		;then return address of tstop


movins:	pop	hl		;get return addr
	ex	(sp),hl		;put back, but get desc.
	ld	a,(hl)		;[a]=string length
	inc	hl
	ld	c,(hl)		;[b,c]=pointer at string data
	inc	hl
	ld	b,(hl)
	ld	l,a		;[l]=string length
movstr:	inc	l
movlp:	dec	l		;set cc'S
	ret	z		;0, no byte to move
	ld	a,(bc)		;get char
	ld	(de),a		;save it
	inc	bc		;move pointers
	inc	de
	jp	movlp		;keep doing it
	page
	;subttl	free up string temporary - frestr, frefac, fretmp, fretms
;
; fretmp is passed a pointer to a string descriptor in [d,e]
; this value is returned in [h,l]. all the other registers are modified.
; a check to is made to see if the string descriptor [d,e] points
; to is the last temporary descriptor allocated by putnew.
; if so, the temporary is freed up by the updating of temppt.
; if a temporary is freed up, a further check is made to see if the
; string data that that string temporary pointed to is the
; the lowest part of string space in use.
; if so, fretmp is updated to reflect the fact that that space is no
; longer in use.
;
	public	frefac
frestr:	call	chkstr		;make sure its a string
frefac:	ld	hl,(faclo)
	public	fretm2
fretm2:	ex	de,hl		;free up the temp in the faclo
fretmp:	call	fretms		;free up the temporary
	ex	de,hl		;put the string pointer into [h,l]
	ret	nz
	push	de		;save [d,e] to return in [h,l]
	ld	d,b		;[d,e]=pointer at string
	ld	e,c
	dec	de		;subtract one
	ld	c,(hl)		;[c]=length of the string freed up
	ld	hl,(fretop)	;see if its the first
				;one in string space
	call	dcompr
	jp	nz,notlst	;no so don'T ADD
	ld	b,a		;make [b]=0
	add	hl,bc		;add
	ld	(fretop),hl	;and update fretop
notlst:	pop	hl		;get pointer at current descriptor
	ret
fretms:	ld	hl,(temppt)	;get temp pointer
	dec	hl		;look at what is in the last temp
	ld	b,(hl)		;[b,c]=pointer at string
	dec	hl		;decrement temppt by strsiz
	ld	c,(hl)
	dec	hl
	call	dcompr		;see if [d,e] point at the last
	ret	nz		;return now if now freeing done
	ld	(temppt),hl	;update the temp pointer since
				;its been decremented by 4
	ret
	page
	;subttl	string functions - len, asc, chr$
;
; the function len($) returns the length of the
; string passed as an argument
;
len:	ld	bc,sngflt	;call sngflt when done
	push	bc		;like so
len1:	call	frestr		;free up temp pointed to by faclo
	xor	a		;force numeric flag
	ld	d,a		;set high of [d,e] to zero for val
	ld	a,(hl)
	or	a		;set condition codes on length
	ret			;return
;
; the following is the asc($) function. it returns an integer
; which is the decimal ascii equivalent
;
asc:
	ld	bc,sngflt	;where to go when done
	push	bc		;save return addr on stack
asc2:	call	len1		;set up original str
	jp	z,fcerr		;null str, bad arg.
	inc	hl		;bump pointer
	ld	e,(hl)		;[d,e]=pointer at string data
	inc	hl
	ld	d,(hl)
	ld	a,(de)		;[a]=first character
	ret
;
; chr$(#) creates a string which contains as its only
; character the ascii equivalent of the integer arg (#)
; which must be .le. 255.
;
chr$:	call	strin1		;get string in dsctmp
	call	conint		;get integer in range
incstr	defl	2

incstr	defl	1
	public	setstr,finbck
setstr:	ld	hl,(dsctmp+incstr);get addr of str
	ld	(hl),e		;save ascii byte
finbck:	pop	bc		;return to higher level &
				;skip the chknum call.
	jp	putnew		;go call putnew

	public	strng$
strng$:	call	chrgtr		;get next char following "STRING$"
	call	synchr
	defb	'('		;make sure left paren
	call	getbyt		;evaluate first arg (length)
	push	de		;save it
	call	synchr
	defb	54o		;comma
	call	frmevl		;get formula arg 2
	call	synchr
	defb	')'		;expect right paren
	ex	(sp),hl		;save text pointer on stack, get rep factor
	push	hl		;save back rep factor
	call	getypr		;get type of arg
	jp	z,strstr	;was a string
	call	conint		;get ascii value of char
	jp	calspa		;now call space code
strstr:	call	asc2		;get value of char in [a]
calspa:	pop	de		;get rep factor in [e]
	call	space2		;into space code, put dummy entry
				;on stack popped off by finbck
	public	space$
space$:	call	conint		;get number of chars in [e]
	ld	a,32		;get space char
space2:	push	af		;save char
	ld	a,e		;get number of chars in [a]
	call	strini		;get a string that long
	ld	b,a		;count of chars back in [b]
	pop	af		;get back char to put in string
	inc	b		;test for null string
	dec	b
	jp	z,finbck	;yes, all done
	ld	hl,(dsctmp+incstr);get desc. pointer
splp$:	ld	(hl),a		;save char
	inc	hl		;bump ptr
	;decr count
	dec	b
	jp	nz,splp$	;keep storing char
	jp	finbck		;put temp desc when done
	page
	;subttl	string functions - left$, right$, mid$
;
; the following is the left$($,#) function.
; it takes the leftmost # chars of the str.
; if # is .gt. than the len of the str, it returns the whole str.
;
left$:	call	pream		;test the parameters
	xor	a		;left never changes string pointer
left3:	ex	(sp),hl		;save text pointer
	ld	c,a		;offset now in [c]
	defb	76q		;skip the next byte with "MVI A,"
;
; this is print usings entry point into left$
;
	public	leftus
leftus:	push	hl		;this is a dummy push to offset
	;the extra pop in putnew
left2:	push	hl		;save desc. for  fretmp
	ld	a,(hl)		;get string length
	cp	b		;entire string wanted?
	jp	c,allstr	;if #chars asked for.ge.length,yes
	ld	a,b		;get truncated length of string
	defb	21q		;skip over mvi using "LXI D,"
allstr:	ld	c,0		;make offset zero
	push	bc		;save offset on stack
	call	getspa		;get space for new string
	pop	bc		;get back offset
	pop	hl		;get back desc pointer.
	push	hl		;but keep on stack
	inc	hl		;move to string pointer field
	ld	b,(hl)		;get pointer low
	inc	hl		;
	ld	h,(hl)		;pointer high
	ld	l,b		;get low in  l
	ld	b,0		;get ready to add offset to pointer
	add	hl,bc		;add  it
	ld	b,h		;get offset pointer in [b,c]
	ld	c,l
	call	strad2		;save info in dsctmp
	ld	l,a		;get#  of chars to  move in l
	call	movstr		;move them in
	pop	de		;get back desc. pointer
	call	fretmp		;free it up.
	jp	putnew		;put temp in temp list

right$:	call	pream		;check arg
	pop	de		;get desc. pointer
	push	de		;save back for left
	ld	a,(de)		;get present len of str
	sub	b		;subtract 2nd parm
	jp	left3		;continue with left code
;
; mid ($,#) returns str with chars from # position
; onward. if # is gt len($) then return null string.
; mid ($,#,#) returns str with chars from # position
; for #2 chars. if #2 goes past end of string, return
; as much as possible.
;
mid$:	ex	de,hl		;put the text pointer in [h,l]
	ld	a,(hl)		;get the first character
	call	pream2		;get offset off stack and make
	inc	b
	dec	b		;see if equal to zero
	jp	z,fcerr		;it must not be 0
				;sure does not = 0.
	push	bc		;put offset on to the stack
	call	midrst		;duplicate of code conditioned out
	;below
	pop	af		;get offset back in a
	ex	(sp),hl		;save text pointer, get desc.
	ld	bc,left2	;where to return to.
	push	bc		;goes on stack
	dec	a		;sub one from offset
	cp	(hl)		;pointer past end of str?
	ld	b,0		;assume null length str
	ret	nc		;yes, just use null str
	ld	c,a		;save offset of character pointer
	ld	a,(hl)		;get present len of str
	sub	c		;subtract index (2nd arg)
	cp	e		;is it truncation
	ld	b,a		;get calced length in b
	ret	c		;if not use partial str
	ld	b,e		;use truncated length
	ret			;return to left2
;
; the val function takes a string and turn it into
; a number by interpreting the ascii digits. etc..
; except for the problem that a terminator must be supplied
; by replacing the character beyond the string, val
; is merely a call to floating input (fin).
;
val:	call	len1		;do setup, set result=real
	jp	z,sngflt	;make sure type set up ok in extended
	ld	e,a		;get length of str
	inc	hl		;to handle the fact the if
	ld	a,(hl)
	inc	hl
	ld	h,(hl)		;two strings "1" and "2"
	ld	l,a		;are stored next to each other
	push	hl		;and fin is called pointing to
	add	hl,de		;the first twelve will be returned
	ld	b,(hl)		;the idea is to store 0 in the
	ld	(hl),d		;string beyond the one val
	ex	(sp),hl		;is being called on
	push	bc		;the first character of the next string
	dec	hl		;***call chrget to make sure
	call	chrgtr		;val(" -3")=-3
	call	findbl		;in extended, get all the precision we can
	pop	bc		;get the modified character of the next
	;string into [b]
	pop	hl		;get the pointer to the modified character
	ld	(hl),b		;restore the character
				;if string is highest in string space
				;we are modifying [memsiz] and
				;this is why [memsiz] can'T BE USED TO STORE
				;string data because what if the
				;user took val off that high string
	ret
;used by right$ and left$ for parameter checking and setup
pream:	ex	de,hl		;put the text pointer in [h,l]
	call	synchr
	defb	')'		;param list should end
;used by mid$ for parameter checking and setup
pream2:	pop	bc		;get return addr off stack
	pop	de		;get length of arg off stack
	push	bc		;save return addr back on
	ld	b,e		;save init length
	ret

	page
	;subttl	string functions - instr

; this is the instr fucntion. it takes one of two
; forms: instr(i%,s1$,s2$) or instr(s1$,s2$)
; in the first form the string s1$ is searched for the
; character s2$ starting at character position i%.
; the second form is identical, except that the search
; starts at position 1. instr returns the character
; position of the first occurance of s2$ in s1$.
; if s1$ is null, 0 is returned. if s2$ is null, then
; i% is returned, unless i% .gt. len(s1$) in which
; case 0 is returned.

	public	instr
instr:	call	chrgtr		;eat first char
	call	frmprn		;evaluate first arg
	call	getypr		;set zero if arg a string.
	ld	a,1		;if so, assume, search starts at first char
	push	af		;save offset in case string
	jp	z,wuzstr	;was a string
	pop	af		;get rid of saved offset
	call	conint		;force arg1 (i%) to be integer
	or	a		;dont allow zero offset
	jp	z,fcerr		;kill him.
	push	af		;save for later
	call	synchr
	defb	44		;eat the comma
	call	frmevl		;eat first string arg
	call	chkstr		;blow up if not string
wuzstr:	call	synchr
	defb	44		;eat comma after arg
	push	hl		;save the text pointer
	ld	hl,(faclo)	;get descriptor pointer
	ex	(sp),hl		;put on stack & get back text pnt.
	call	frmevl		;get last arg
	call	synchr
	defb	')'		;eat right paren
	push	hl		;save text pointer
	call	frestr		;free up temp & check string
	ex	de,hl		;save 2nd desc. pointer in [d,e]
	pop	bc		;get text pointer in b
	pop	hl		;desc. pointer for s1$
	pop	af		;offset
	push	bc		;put text pointer on bottom
	ld	bc,pophrt	;put address of pop h, ret on
	push	bc		;push it
	ld	bc,sngflt	;now address of [a] returner
	push	bc		;onto stack
	push	af		;save offset back
	push	de		;save desc. of s2
	call	fretm2		;free up s1 desc.
	pop	de		;restore desc. s2
	pop	af		;get back offset
	ld	b,a		;save unmodified offset
	dec	a		;make offset ok
	ld	c,a		;save in c
	cp	(hl)		;is it beyond length of s1?
	ld	a,0		;if so, return zero. (error)
	ret	nc
	ld	a,(de)		;get length of s2$
	or	a		;null??
	ld	a,b		;get offset back
	ret	z		;all if s2 null, return offset
	ld	a,(hl)		;get length of s1$
	inc	hl		;bump pointer
	ld	b,(hl)		;get 1st byte of address
	inc	hl		;bump pointer
	ld	h,(hl)		;get 2nd byte
	ld	l,b		;get 1st byte set up
	ld	b,0		;get ready for dad
	add	hl,bc		;now indexing into string
	sub	c		;make length of string s1$ right
	ld	b,a		;save length of 1st string in [b]
	push	bc		;save counter, offset
	push	de		;put 2nd desc (s2$) on stack
	ex	(sp),hl		;get 2nd desc. pointer
	ld	c,(hl)		;set up length
	inc	hl		;bump pointer
	ld	e,(hl)		;get first byte of address
	inc	hl		;bump pointer again
	ld	d,(hl)		;get 2nd byte
	pop	hl		;restore pointer for 1st string

chk1:	push	hl		;save position in search string
	push	de		;save start of substring
	push	bc		;save where we started search
chk:	ld	a,(de)		;get char from substring
	cp	(hl)		; = char pointer to by [h,l]
	jp	nz,ohwell	;no
	inc	de		;bump compare pointer
	dec	c		;end of search string?
	jp	z,gotstr	;we found it!
	inc	hl		;bump pointer into string being searched
				;decrement length of search string
	dec	b
	jp	nz,chk		;end of string, you lose
retzer:	pop	de		;get rid of pointers
	pop	de		;get rid of garb
	pop	bc		;like so
retzr1:	pop	de
	xor	a		;go to sngflt.
	ret			;return

gotstr:	pop	hl
	pop	de		;get rid of garb
	pop	de		;get rid of excess stack
	pop	bc		;get counter, offset
	ld	a,b		;get original source counter
	sub	h		;subtract final counter
	add	a,c		;add original offset (n1%)
	inc	a		;make offset of zero = posit 1
	ret			;done


ohwell:	pop	bc
	pop	de		;point to start of substring
	pop	hl		;get back where we started to compare
	inc	hl		;and point to next char
				;decr. # char left in source string
	dec	b
	jp	nz,chk1		;try searching some more
	jp	retzr1		;end of string, return 0

	page
	;subttl	string functions - left hand side mid$
lhsmid:	call	synchr
	defb	'('		;must have (
	call	ptrget		;get a string var
	call	chkstr		;make sure it was a string
	push	hl		;save text pointer
	push	de		;save desc. pointer
	ex	de,hl		;put desc. pointer in [h,l]
	inc	hl		;move to address field
	ld	e,(hl)		;get address of lhs in [d,e]
	inc	hl		;bump desc. pointer
	ld	d,(hl)		;pick up high byte of address
	ld	hl,(strend)	;see if lhs string is in string space
	call	dcompr		;by comparing it with stktop
	jp	c,ncpmid	;if already in string space
				;dont copy.

				;9/23/79 allow mid$ on field strings
	extrn	txttab
	ld	hl,(txttab)
	call	dcompr		;is this a fielded string?
	jp	nc,ncpmid	;yes, don't copy!!
	pop	hl		;get back desc. pointer
	push	hl		;save back on stack
	call	strcpy		;copy the string literal into string space
	pop	hl		;get back desc. pointer
	push	hl		;back on stack again
	call	vmove		;move new desc. into old slot.
ncpmid:	pop	hl		;get desc. pointer
	ex	(sp),hl		;get text pointer to [h,l] desc. to stack
	call	synchr
	defb	54o		;must have comma
	call	getbyt		;get arg#2 (offset into string)
	or	a		;make sure not zero
	jp	z,fcerr		;blow him up if zero
	push	af		;save arg#2 on stack
	ld	a,(hl)		;restore current char
	call	midrst		;use mid$ code to evaluate posible third arg.
	push	de		;save third arg ([e]) on stack
	;must have = sign
	call	frmeql		;evaluate rhs of thing.
	push	hl		;save text pointer.
	call	frestr		;free up temp rhs if any.
	ex	de,hl		;put rhs desc. pointer in [d,e]
	pop	hl		;text pointer to [h,l]
	pop	bc		;arg #3 to c.
	pop	af		;arg #2 to a.
	ld	b,a		;and [b]
	ex	(sp),hl		;get lhs desc. pointer to [h,l]
				;text pointer to stack
	push	hl		;save text pointer
	ld	hl,pophrt	;get addr to return to
	ex	(sp),hl		;save on stack & get back txt ptr.
	ld	a,c		;get arg #3
	or	a		;set cc'S
	ret	z		;if zero, do nothing
	ld	a,(hl)		;get length of lhs
	sub	b		;see how many chars in emainder of string
	jp	c,fcerr		;cant assign past len(lhs)!
	inc	a		;make proper count
	cp	c		;see if # of chars is .gt. third arg
	jp	c,biglen	;if so, dont truncate
	ld	a,c		;truncate by using 3rd arg.
biglen:	ld	c,b		;get offset of string in [c]
	dec	c		;make proper offset
	ld	b,0		;set up [b,c] for later dad b.
	push	de		;save [d,e]
	inc	hl		;pointer to address field.
	ld	e,(hl)		;get low byte in [e]
	inc	hl		;bump pointer
	ld	h,(hl)		;get high byte in [h]
	ld	l,e		;now copy low byte back to [l]
	add	hl,bc		;add offset
	ld	b,a		;set count of lhs in [b]
	pop	de		;restore [d,e]
	ex	de,hl		;move rhs. desc. pointer to [h,l]
	ld	c,(hl)		;get len(rhs) in [c]
	inc	hl		;move pointer
	ld	a,(hl)		;get low byte of address in [a]
	inc	hl		;bump pointer.
	ld	h,(hl)		;get high byte of address in [h]
	ld	l,a		;copy low byte to [l]
	ex	de,hl		;address of rhs now in [d,e]
	ld	a,c		;is rhs null?
	or	a		;test
	ret	z		;then all done.
; now all set up for assignment.
; [h,l] = lhs pointer
; [d,e] = rhs pointer
; c = len(rhs)
; b = len(lhs)

mid$lp:	ld	a,(de)		;get byte from rhs.
	ld	(hl),a		;store in lhs
	inc	de		;bump rhs pointer
	inc	hl		;bump lhs pointer.
	dec	c		;bump down count of rhs.
	ret	z		;if zero, all done.
				;if lhs ended, also done.
	dec	b
	jp	nz,mid$lp	;if not done, more copying.
	ret			;back to newstt

midrst:	ld	e,255		;if two arg guy, truncate.
	cp	')'
	jp	z,mid2		;[e] says use all chars
				;if one argument this is correct
	call	synchr
	defb	44		;comma? must delineate 3rd arg.
	call	getbyt		;get argument  in  [e]
mid2:	call	synchr
	defb	')'		;must be followed by )
	ret			;all done.

	;subttl	fre  function and integer to floating  routines
fre:
	call	getypr
	jp	nz,clcdif
	call	frefac		;free up argument and setup
				;to give free string space
	call	garba2		;do garbage collection
clcdif:	ld	hl,(strend)
	ex	de,hl
	ld	hl,(fretop)	;top of free area
	jp	givdbl		;return [h,l]-[d,e]
;	end

