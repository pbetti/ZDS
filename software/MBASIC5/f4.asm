
	.z80
; 	aseg

	;subttl	common file for basic interpreter
; 	.sall

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

clmwid	defl	14	;make comma columns fourteen characters
datpsc	defl	128		;number of data bytes in disk sector
linln	defl	80		;terminal line length
lptlen	defl	132
buflen	defl	255		;long lines
namlen	defl	40		;maximum length name -- 3 to 127

numlev	defl	0*20+19+2*5;number of stack levels reserved
	;by an explicit call to getstk

strsiz	defl	4

strsiz	defl	3
numtmp	defl	3		;number of string temporaries

numtmp	defl	10

md.rnd	defl	3	;the mode number for random files
md.sqi	defl	1		;the mode number for sequential input files
	;never written into a file
md.sqo	defl	2		;the mode for sequential output files
	;and program files
cpmwrm	defl	0		;cp/m warm boot addr
cpment	defl	cpmwrm+5	;cp/m bdos call addr
	cseg
trurom	defl	0
	page
	title	mathpk for basic mcs 8080  gates/allen/davidoff
	;subttl	floating point math package configuration

curncy	defl	44o	;use dollar sign as default

	public	rnd,sin,fout,inprt,linprt
	public	zero,float,floatr,move,fadd,fadds,fsub,fmult,fdiv,fin
	extrn	intxt,snerr,bserr,overr,minpls
	public	normal,unpack
	public	pushf,abs,int,qint,sgn,fcomp,signc,pophrt
	public	sqr
	public	movfm,movmf,movfr,movrf,movrm,rneg,inrart,inxhrt
	extrn	cnsget
	public	umult,signs
	public	fpwr,exp,log,cos,tan,atn,fone
	public	pufout
	public	vmovmf,vmovfm,frcint,frcsng,frcdbl,vneg,iadd
	public	isub,imult,icomp,ineg,dadd,dsub,dmult,ddiv,dcomp,vint
	public	vmove,valint,valsng,frcstr,chkstr,makint,isign
	public	dcompd,dnorml,dint
	public	fdivt,consih,conia,vmovfa,vmovaf,getbcd,vsign,vdfacs

	public	imod,idiv

	extrn	fansii,overri,strprn,flgovc
	extrn	ttypos
	extrn	divmsg,ovrmsg
	extrn	caltty
	extrn	fac,faclo,fbuffr,minutk,plustk,error,fcerr
	extrn	chrgtr,outdo,dv0err,strout
	public	sign
	public	sincon,atncon

	extrn	getypr
	extrn	dcompr,synchr
	extrn	tmerr
	extrn	errflg,dfaclo,arg,arglo,valtyp,temp2,temp3



;
;	extrnal locations used by the math-package
;	;the floating accumulator
;ifn	length&2,<
;	block	1		;[temporary least significant byte]
;dfaclo:	block	4>		;[four lowest orders for double precision]
;faclo:	block	3		;[low order of mantissa (lo)]
;				;[middle order of mantissa (mo)]
;				;[high order of mantissa (ho)]
;fac:	block	2		;[exponent]
;				;[temporary complement of sign in msb]
;ifn	length&2,<
;	block	1		;[temporary least significant byte]
;arglo:	block	7		;[location of second argument for double
;arg:	block	1>		; precision]
;fbuffr:	block	^d13		;buffer for fout
;ifn	length&2,<block	^d<35-13>>
;
;
;the floating point format is as follows:
;
;the sign is the first bit of the mantissa
;the mantissa is 24 bits long
;the binary point is to the left of the msb
;number = mantissa * 2 ^ exponent
;the mantissa is positive, with a one assumed to be where the sign bit is
;the sign of the exponent is the first bit of the exponent
;the exponent is stored in excess 200 i.e. with a bias of 200
;so, the exponent is a signed 8-bit number with 200 added to it
;an exponent of zero means the number is zero, the other bytes are ignored
;to keep the same number in the fac while shifting:
;	to shift right,	exp:=exp+1
;	to shift left,	exp:=exp-1
;
;so, in memory the number looks like this:
;	[bits 17-24 of the mantissa]
;	[bits 9-16 of the mantissa]
;	[the sign in bit 7, bits 2-8 of the mantissa are in bits 6-0]
;	[the exponent as a signed number + 200]
;(remember that bit 1 of the mantissa is always a one)
;
;arithmetic routine calling conventions:
;
;for one argument functions:
;	the argument is in the fac, the result is left in the fac
;for two argument operations:
;	the first argument is in b,c,d,e i.e. the "REGISTERS"
;	the second argument is in the fac
;	the result is left in the fac
;
;the "S" entry points to the two argument operations have (hl) pointing to
;the first argument instead of the first argument being in the registers.
;movrm is called to get the argument in the registers.
;the "T" entry points assume the first argument is on the stack.
;popr is used to get the argument in the registers.
;note: the "T" entry points should always be jumped to and never called
;because the return address on the stack will be confused with the number.
;
;on the stack, the two lo'S ARE PUSHED ON FIRST AND THEN THE HO AND SIGN.
;this is done so if a number is stored in memory, it can be pushed on the
;stack with two pushm'S.  THE LOWER BYTE OF EACH PART IS IN THE LOWER
;memory address so when the number is popped into the registers, the higher
;order byte will be in the higher order register of the register pair, i.e.
;the higher order byte will be popped into b, d or h.
;%
	page

	;subttl	floating point addition and subtraction
	;entry to fadd with pointer to arg in (hl)

	public	faddh
faddh:	ld	hl,fhalf	;entry to add 1/2
fadds:	call	movrm		;get argument into the registers
	jp	fadd		;do the addition


	;subtraction	fac:=arg-fac
fsubs:	call	movrm		;entry if pointer to arg is in (hl)
fsub:	call	rneg		;negate second argument
	;fall into fadd


	;addition	fac:=arg+fac
	;alters a,b,c,d,e,h,l
;*****************************************************************
;if intfsw=1 the format of floating point numbers will be:
;reg b:sign and bits 1-7 of exponent,reg c:bit 8 of exponent
;and bits 2-8 of mantissa,reg d:bits 9-16 of mantissa,
;reg e:bits 17-24 of mantissa, and likewise for the fac format
;furthermore, the exponent for intel will be bias 177 octal
;******************************************************************
fadd:	ld	a,b		;check if first argument is zero
	or	a		;get exponent
	ret	z		;it is, result is number in fac
	ld	a,(fac)		;get exponent
	or	a		;see if the number is zero
	jp	z,movfr		;it is, answer is in registers

;we want to get the smaller number in the registers so we can shift it right
;and align the binary points of the two numbers.  then we can just add or
;subtract them (depending on their signs) bytewise.
	sub	b		;check relative sizes
	jp	nc,fadd1	;is fac smaller?
	cpl			;yes, negate shift count
	inc	a
	ex	de,hl		;switch fac and registers, save (de)
	call	pushf		;put fac on stack
	ex	de,hl		;get (de) back where it belongs
	call	movfr		;put registers in the fac
	pop	bc
	pop	de
	;get the old fac in the registers
fadd1:
	cp	31o		;are we within 24 bits?
	ret	nc
	push	af		;save shift count
	call	unpack		;unpack the numbers
	ld	h,a		;save subtraction flag
	pop	af		;get shift count back
	call	shiftr		;shift registers right the right amount

;if the numbers have the same sign, then we add them.  if the signs are
;different, then we have to subtract them.  we have to do this because the
;mantissas are positive.  judging by the exponents, the larger number is in
;the fac, so if we subtract, the sign of the result should be the sign of the
;fac; however, if the exponents are the same, the number in the registers
;could be bigger, so after we subtract them, we have to check if the result
;was negative.  if it was, we negate the number in the registers and
;complement the sign of the fac.  (here the fac is unpacked)
;if we have to add the numbers, the sign of the result is the sign of the
;fac.  so, in either case, when we are all done, the sign of the result
;will be the sign of the fac.
	ld	a,h		;get subtraction flag
	or	a
	ld	hl,faclo	;set pointer to lo'S
	jp	p,fadd3		;subtract if the signs were different
	call	fadda		;add the numbers
	jp	nc,round	;round result if there was no overflow
	;the most it can overflow is one bit
	inc	hl		;there was overflow
	inc	(hl)		;increment exponent
	jp	z,ovfin4
	ld	l,1		;shift result right one, shift carry in
	call	shradd
	jp	round		;round result and we are done
	;here to subtract c,d,e,b from ((hl)+0,1,2),0
fadd3:	xor	a		;subtract numbers, negate underflow byte
	sub	b
	ld	b,a		;save it
	ld	a,(hl)		;subtract low orders
	sbc	a,e
	ld	e,a
	inc	hl		;update pointer to next byte
	ld	a,(hl)		;subtract middle orders
	sbc	a,d
	ld	d,a
	inc	hl		;update pointer to high orders
	ld	a,(hl)		;subtract high orders
	sbc	a,c
	ld	c,a
	;because we want a positive mantissa, check if we have to negate the
	; number
fadflt:	call	c,negr		;entry from floatr, int: negate number if it
	; was negative, fall into normalize


	;normalize c,d,e,b
	;alters a,b,c,d,e,h,l
	;here we shift the mantissa left until the msb is a one.
	;except in 4k, the idea is to shift left by 8 as many times as
	;possible.
normal:
	ld	l,b		;put lowest 2 bytes in (hl)
	ld	h,e
	xor	a		;zero shift count
norm1:	ld	b,a		;save shift count
	ld	a,c		;do we have 1 byte of zeros
	or	a
	jp	nz,norm3	;no, shift one place at a time
	;this loop speeds things up by shifting 8 places at one time
	ld	c,d		;yes, shift over 1 byte
	ld	d,h
	ld	h,l
	ld	l,a		;shift in 8 zeros for the low order
	ld	a,b		;update shift count
	sub	10o
	cp	340o		;did we shift in 4 bytes of zeros?
	jp	nz,norm1	;no, try to shift over 8 more
	;yes, number was zero.  fall into zero


	;zero fac
	;alters a only
	;exits with a=0
	;by our floating point format, the number is zero if the exponent is
	; zero
zero:	xor	a		;zero a
zero0:	ld	(fac),a		;zero the fac'S EXPONENT, ENTRY IF A=0
	ret			;all done


norm2:
	ld	a,h		;check for case of normalizing a small int
	or	l
	or	d
	jp	nz,norm2u	;do usual thing
	ld	a,c		;get byte to shift
norm2f:	dec	b		;decrment shift count
	rla			;shift left
	jp	nc,norm2f	;normalize like sob
	inc	b		;correct shift count
	rra			;we did it one too many times
	ld	c,a		;result to [c]
	jp	norm3a		;all done
norm2u:	dec	b		;decrement shift count
	add	hl,hl		;rotate (hl) left one, shift in a zero
	ld	a,d		;rotate next higher order left one
	rla
	ld	d,a
	ld	a,c		;rotate high order left one
	adc	a,a		;set condition codes
	ld	c,a
norm3:	jp	p,norm2		;we have more normalization to do
norm3a:	ld	a,b		;all normalized, get shift count
	ld	e,h		;put lo'S BACK IN E,B
	ld	b,l
	or	a		;check if we did no shifting
	jp	z,round
	ld	hl,fac		;look at fac'S EXPONENT
	add	a,(hl)		;update exponent
	ld	(hl),a
	jp	nc,zero		;check for underflow
	jp	z,zero		;number is zero, all done
	;fall into round and we are done


	;round result in c,d,e,b and put number in the fac
	;alters a,b,c,d,e,h,l
	;we round c,d,e up or down depending upon the msb of b
round:	ld	a,b		;see if we should round up
roundb:	ld	hl,fac		;entry from fdiv, get pointer to exponent

	;intel floating software flag
	or	a
	call	m,rounda	;do it if necessary
	ld	b,(hl)		;put exponent in b
	;here we pack the ho and sign
	inc	hl		;point to sign
	ld	a,(hl)		;get sign
	and	200o		;get rid of unwanted bits
	xor	c		;pack sign and ho
	ld	c,a		;save it in c
	jp	movfr		;save number in fac




	;subroutne for round:  add one to c,d,e
rounda:	inc	e		;add one to the low order, entry from qint
	ret	nz		;all done if it is not zero
	inc	d		;add one to next higher order
	ret	nz		;all done if no overflow
	inc	c		;add one to the highest order
	ret	nz		;return if no oveflow
	ld	c,200o		;the number overflowed, set new high order
	inc	(hl)		;update exponent
	ret	nz		;return if it did not overflow
	jp	ovfin8		;overflow and continue



	;add (hl)+2,1,0 to c,d,e
	;this code is used by fadd, fout
fadda:	ld	a,(hl)		;get lowest order
	add	a,e		;add in other lowest order
	ld	e,a		;save it
	inc	hl		;update pointer to next byte
	ld	a,(hl)		;add middle orders
	adc	a,d
	ld	d,a
	inc	hl		;update pointer to high order
	ld	a,(hl)		;add high orders
	adc	a,c
	ld	c,a
	ret			;all done


	;negate number in c,d,e,b
	;this code is used by fadd, qint
	;alters a,b,c,d,e,l
negr:	ld	hl,fac+1	;negate fac
	ld	a,(hl)		;get sign
	cpl			;complement it
	ld	(hl),a		;save it again
	xor	a		;zero a
	ld	l,a		;save zero in l
	sub	b		;negate lowest order
	ld	b,a		;save it
	ld	a,l		;get a zero
	sbc	a,e		;negate next highest order
	ld	e,a		;save it
	ld	a,l		;get a zero
	sbc	a,d		;negate next highest order
	ld	d,a		;save it
	ld	a,l		;get zero back
	sbc	a,c		;negate highest order
	ld	c,a		;save it
	ret			;all done


	;shift c,d,e right
	;a = shift count
	;alters a,b,c,d,e,l
	;the idea (except in 4k) is to shift right 8 places as many times as
	; possible
shiftr:	ld	b,0		;zero overflow byte
shftr1:	sub	10o		;can we shift it 8 right?
	jp	c,shftr2	;no, shift it one place at a time
	;this loop speeds things up by shifting 8 places at one time
	ld	b,e		;shift number 1 byte right
	ld	e,d
	ld	d,c
	ld	c,0		;put 0 in ho
	jp	shftr1		;try to shift 8 right again
shftr2:	add	a,11o		;correct shift count
	ld	l,a		;save shift count
;test for case (very common) where shifting small integer right.
;this happens in for loops, etc.
	ld	a,d		;see if three lows are zero.
	or	e
	or	b
	jp	nz,shftr3	;if so, do usual.
	ld	a,c		;get high byte to shift
shftrf:	dec	l		;done shifting?
	ret	z		;yes, done
	rra			;rotate one right
	ld	c,a		;save result
	jp	nc,shftrf	;zap back and do next one if none
	jp	shftc		;continue shifting
shftr3:	xor	a		;clear carry
	dec	l		;are we done shifting?
	ret	z		;return if we are
	ld	a,c		;get ho
shradd:	rra			;entry from fadd, shift it right
	ld	c,a		;save it
shftc:	ld	a,d		;shift next byte right
	rra
	ld	d,a
	ld	a,e		;shift low order right
	rra
	ld	e,a
	ld	a,b		;shift overflow byte right
	rra
	ld	b,a
	jp	shftr3		;see if we are done


	page
	;subttl	natural log function
	;calculation is by:
	; ln(f*2^n)=(n+log2(f))*ln(2)
	;an approximation polynomial is used to calculate log2(f)

	;constants used by log
fone:	defb	000		; 1
	defb	000
	defb	000
	defb	201o
logp:	defb	004		;hart 2524 coefficients
	defb	232o		;4.8114746
	defb	367o
	defb	031o
	defb	203o
	defb	044o		;6.105852
	defb	143o
	defb	103o
	defb	203o
	defb	165o		;-8.86266
	defb	315o
	defb	215o
	defb	204o
	defb	251o		;-2.054667
	defb	177o
	defb	203o
	defb	202o
logq:	defb	004
	defb	000		;1.0
	defb	000
	defb	000
	defb	201o
	defb	342o		;6.427842
	defb	260o
	defb	115o
	defb	203o
	defb	012o		;4.545171
	defb	162o
	defb	021o
	defb	203o
	defb	364o		;.3535534
	defb	004
	defb	065o
	defb	177o

log:	call	sign		;check for a negative or zero argument
	or	a		;set cc'S PROPERLY
	jp	pe,fcerr	;fac .le. 0, blow him out of the water
	;fsign only returns 0,1 or 377 in a
	;the parity will be even if a has 0 or 377

	call	log2		;
	ld	bc,200q*256+061q
	ld	de,162q*256+030q;get ln(2)
	jp	fmult		;complete log calculation
log2:	;use hart 2524 calculation
	call	movrf		;move fac to registers too
	ld	a,200o		;
	ld	(fac),a		;zero the exponent
	xor	b		;remove 200 excess from x
	push	af		;save exponent
	call	pushf		;save the fac (x)
	ld	hl,logp		;point to p constants
	call	poly		;calculate p(x)
	pop	bc		;fetch x
	pop	hl		;pushf would alter de
	call	pushf		;push p(x) on the stack
	ex	de,hl		;get low bytes of x to (de)
	call	movfr		;and move to fac
	ld	hl,logq		;point to q coefficients
	call	poly		;compute q(x)
	pop	bc		;fetch p(x) to registers
	pop	de
	call	fdiv		;calculate p(x)/q(x)
	pop	af		;re-fetch exponent
	call	pushf		;save evaluation
	call	float		;float the exponent
	pop	bc
	pop	de
	;get eval. back
	jp	fadd

	page
;	jmp	fmult		;multiply by ln(2)
	;subttl	floating multiplication and division
	;multiplication		fac:=arg*fac
	;alters a,b,c,d,e,h,l
fmult:	call	sign		;check if fac is zero
	ret	z		;if it is, result is zero
	ld	l,0		;add the two exponents, l is a flag
	call	muldiv		;fix up the exponents
	;save the number in the registers so we can add it fast
	ld	a,c		;get ho
	ld	(fmulta+1),a	;store ho of registers
	ex	de,hl		;store the two lo'S OF THE REGISTERS
	ld	(fmultb+1),hl
	ld	bc,0		;zero the product registers
	ld	d,b
	ld	e,b
	ld	hl,normal
	push	hl		; on the stack
	ld	hl,fmult2	;put fmult2 on the stack twice, so after
	push	hl		; we multiply by the lo byte, we will
	push	hl		; multiply by the mo and ho
	ld	hl,faclo	;get address of lo of fac
fmult2:	ld	a,(hl)		;get byte to multiply by
	inc	hl		;move pointer to next byte
	or	a
	jp	z,fmult3	;are we multiplying by zero?
	push	hl		;save pointer
	ex	de,hl		;get lo'S IN (HL)
	ld	e,10o		;set up a count

;the product will be formed in c,d,e,b. this will be in c,h,l,b part of the
;time in order to use the "DAD" instruction.  at fmult2, we get the next
;byte of the mantissa in the fac to multiply by.  ((hl) points to it)
;(the fmult2 subroutine preserves (hl))  in 8k, if the byte is zero, we just
;shift the product 8 right.  this byte is then shifted right and saved in d
;(h in 4k).  the carry determines if we should add in the second factor
;if we do, we add it to c,h,l.  b is only used to determine which way we
;round.  we then shift c,h,l,b (c,d,e,b) in 4k right one to get ready for the
;next time through the loop.  note that the carry is shifted into the msb of
;c.  e has a count (l in 4k) to determine when we have looked at all the bits
;of d (h in 4k).
fmult4:	rra			;rotate byte right
	ld	d,a		;save it
	ld	a,c		;get ho
	jp	nc,fmult5	;don'T ADD IN NUMBER IF BIT WAS ZERO
	push	de		;save counters
fmultb:	ld	de,0		;get lo'S OF NUMBER TO ADD, THIS IS SET ABOVE
	add	hl,de		;add them in
	pop	de		;get counters back
fmulta:	adc	a,0		;add in ho, this is set up above
fmult5:	rra			;rotate result right one
	ld	c,a
	ld	a,h		;rotate next byte
	rra
	ld	h,a
	ld	a,l		;rotate next lower order
	rra
	ld	l,a
	ld	a,b		;rotate lo
	rra
	ld	b,a
	and	20o		;see if we rotated thru st
	jp	z,fml5b1	;if not don'T WORRY
	ld	a,b		;re fetch lo
	or	40o		;"OR" in sticky
	ld	b,a		;back to lo
fml5b1:
fmlt5b:
	dec	e		;are we done?
	ld	a,d		;get number we are multiplying by
	jp	nz,fmult4	;multiply again if we are not done
	ex	de,hl		;get lo'S IN (DE)
pophrt:	pop	hl		;get pointer to number to multiply by
	ret			;all done
fmult3:	ld	b,e		;multiply by zero: shift everything 8 right
	ld	e,d
	ld	d,c
	ld	c,a		;shift in 8 zeros on the left
	ret			;all done


	;divide fac by 10
	;alters a,b,c,d,e,h,l
div10:	call	pushf		;save number
	ld	hl,ften		;get pointer to the constant '10'
	call	movfm		;move ten into the fac
fdivt:	pop	bc
	pop	de
	;get number back in registers
	;fall into divide and we are done


	;division	fac:=arg/fac
	;alters a,b,c,d,e,h,l
fdiv:	call	sign		;check for division by zero
	jp	z,intdv1	;don'T ALLOW DIVIDE BY ZERO
	ld	l,377o		;subtract the two exponents, l is a flag
	call	muldiv		;fix up the exponents and things
	inc	(hl)
	inc	(hl)
	;here we save the fac in memory so we can subtract it from the number
	;in the registers quickly.
	dec	hl		;point to ho
	ld	a,(hl)		;get ho
	ld	(fdiva+1),a	;save it
	dec	hl		;save middle order
	ld	a,(hl)
	ld	(fdivb+1),a	;put it where nothing will hurt it
	dec	hl		;save lo
	ld	a,(hl)
	ld	(fdivc+1),a

;the numerator will be kept in b,h,l.  the quotient will be formed in c,d,e.
;to get a bit of the quotient, we first save b,h,l on the stack, then
;subtract the denominator that we saved in memory.  the carry indicates
;whether or not b,h,l was bigger than the denominator.  if b,h,l was bigger,
;the next bit of the quotient is a one.  to get the old b,h,l off the stack,
;we pop them into the psw.  if the denominator was bigger, the next bit of
;the quotient is zero, and we get the old b,h,l back by popping it off the
;stack.  we have to keep an extra bit of the quotient in fdivg+1 in case the
;denominator was bigger,  then b,h,l will get shifted left.  if the msb  of
;b was one, it has to be stored somewhere, so we store it in fdivg+1.  then
;the next time through the loop b,h,l will look bigger because it has an
;extra ho bit in fdivg+1. we are done dividing when the msb of c is a one.
;this occurs when we have calculated 24 bits of the quotient.  when we jump
;to round, the 25th bit of the quotient determines whether we round or not.
;it is in the msb of a.  if initially the denominator is bigger than the
;numerator, the first bit of the quotient will be zero.  this means we
;will go through the divide loop 26 times, since it stops on the 25th bit
;after the first non-zero bit of the quotient.  so, this quotient will look
;shifted left one from the quotient of two numbers in which the numerator is
;bigger.  this can only occur on the first time through the loop, so c,d,e
;are all zero.  so, if we finish the loop and c,d,e are all zero, then we
;must decrement the exponent to correct for this.
	ld	b,c		;get number in b,h,l
	ex	de,hl
	xor	a		;zero c,d,e and highest order
	ld	c,a
	ld	d,a
	ld	e,a
	ld	(fdivg+1),a
fdiv1:	push	hl		;save lo'S OF NUMBER
	push	bc		;save ho of number
	ld	a,l		;subtract number that was in fac
fdivc:	sub	0		;subtract lo
	ld	l,a		;save it
	ld	a,h		;subtract middle order
fdivb:	sbc	a,0
	ld	h,a
	ld	a,b		;subtract ho
fdiva:	sbc	a,0
	ld	b,a
fdivg:	ld	a,0		;get highest order
	;we could do this with no code in ram, but
	; it would be much slower.
	sbc	a,0		;subtract the carry from it
	ccf			;set carry to corespond to next quotient bit
	jp	nc,fdiv2	;get old number back if we subtracted too much
	ld	(fdivg+1),a	;update highest order
	pop	af		;the subtraction was good
	pop	af		;get previous number off stack
	scf			;next bit in quotient is a one
	defb	322o		;"JNC" around next 2 bytes
fdiv2:	pop	bc		;we subtracted too much
	pop	hl		;get old number back
	ld	a,c		;are we done?
	inc	a		;set sign flag without affecting carry
	dec	a
	rra			;put carry in msb
	jp	p,div2a		;not ready to round yet
	rla			;bit back to carry
	ld	a,(fdivg+1)	;fetch extra bit
	rra			;both now in a
	and	300o		;clear superfluous bits
	push	af		;save for later
	ld	a,b		;fetch ho of remainder
	or	h		;fetch ho
	or	l		;see if other remainder bits
	;and if so set st
	jp	z,div2aa	;if not ignore
	ld	a,40o		;st bit
div2aa:	pop	hl		;and the rest of remainder
	or	h		;"OR" in rest
	jp	roundb		;use remainder
div2a:
	rla			;we aren'T, GET OLD CARRY BACK
	ld	a,e		;rotate everything left one
	rla			;rotate next bit of quotient in
	ld	e,a
	ld	a,d
	rla
	ld	d,a
	ld	a,c
	rla
	ld	c,a
	add	hl,hl		;rotate a zero into right end of number
	ld	a,b		;the ho byte, finally!
fdiv2a:	rla
	ld	b,a
fdiv2b:	ld	a,(fdivg+1)	;rotate the highest order
	rla
	ld	(fdivg+1),a
	ld	a,c		;add one to exponent if the first subtraction
	or	d		; did not work
	or	e
	jp	nz,fdiv1	;this isn'T THE CASE
	push	hl		;save part of number
	ld	hl,fac		;get pointer to fac
	dec	(hl)		;decrement exponent
	pop	hl		;get number back
	jp	nz,fdiv1	;divide more if no overflow occured
	jp	zero		;underflow!!


	;check special cases and add exponents for fmult, fdiv
	;alters a,b,h,l
muldvs:	ld	a,377o		;entry from ddiv, subtract exponents
	defb	056o		;"MVI	L" around next byte
muldva:	xor	a		;entry from dmult, add exponents
	ld	hl,arg-1	;get pointer to sign and ho of arg
	ld	c,(hl)		;get ho and sign for unpacking
	inc	hl		;increment pointer to exponent
	xor	(hl)		;get exponent
	ld	b,a		;save it in b for below
	ld	l,0		;set flag to add the exponents below
muldiv:	ld	a,b		;is number in registers zero?
	or	a
	jp	z,muldv2	;it is, zero fac and we are done
	ld	a,l		;get add or subtract flag
	ld	hl,fac		;get pointer to exponent
	xor	(hl)		;get exponent
	add	a,b		;add in register exponent
	ld	b,a		;save it
	rra			;check for overflow
	xor	b		;overflow if sign is the same as carry
	ld	a,b		;get sum
	jp	p,muldv1	;we have overflow!!
	add	a,200o		;put exponent in excess 200
	ld	(hl),a		;save it in the fac
	jp	z,pophrt	;we have undeflow!! return.
	call	unpack		;unpack the arguments
	ld	(hl),a		;save the new sign
dcxhrt:	dec	hl		;point to exponent
	ret			;all done, leave ho in a
mldvex:	call	sign		;entry from exp, pick underflow if negative
	cpl			;pick overflow if positive
	pop	hl		;don'T SCREW UP STACK
muldv1:	or	a		;is error overflow or undeflow?
muldv2:	pop	hl		;get old return address off stack



	jp	p,zero
	jp	ovfin2


	;multiply fac by 10
	;alters a,b,c,d,e,h,l
mul10:	call	movrf		;get number in registers
	ld	a,b		;get exponent
	or	a		;result is zero if arg is zero
	ret	z		;it is
	add	a,2		;multiply by 4 by adding 2 to exponent
	jp	c,ovfin3
	ld	b,a		;restore exponent
	call	fadd		;add in original number to get 5 times it
	ld	hl,fac		;add 1 to exponent to multiply number by
	inc	(hl)		; 2 to get 10 times original number
	ret	nz		;all done if no overflow
	jp	ovfin3
	page
	;subttl	sign, sgn, float, neg and abs
	;put sign of fac in a
	;alters a only
	;leaves fac alone
	;note: to take advantage of the rst instructions to save bytes,
	;fsign is defined to be an rst.  "FSIGN" is equivalent to "CALL	SIGN"
	;the first few instructions of sign (the ones before signc) are done
	;in the 8 bytes at the rst location.

	;intel floating software flag

	;fsign is usually an rst
sign:	ld	a,(fac)		;check if the number is zero
	or	a
	ret	z		;it is, a is zero
signc:	ld	a,(fac-1)	;get sign of fac, it is non-zero
	defb	376o		;"CPI" around next byte
fcomps:	cpl			;entry from fcomp, complement sign
icomps:	rla			;entry from icomp, put sign bit in carry
signs:	sbc	a,a		;a=0 if carry was 0, a=377 if carry was 1
	ret	nz		;return if number was negative
inrart:	inc	a		;put one in a if number was positive
	ret			;all done


	;sgn function
	;alters a,b,c,d,e,h,l
	;fall into float


	;float the signed integer in a
	;alters a,b,c,d,e,h,l

	;use microsoft format if not intel
float:	ld	b,210o		;set exponent correctly
	ld	de,0		;zero d,e
				;fall into floatr


	;float the signed number in b,a,d,e
	;alters a,b,c,d,e,h,l
floatr:	ld	hl,fac		;get pointer to fac
	ld	c,a		;put ho in c
	ld	(hl),b		;put exponent in the fac
	ld	b,0		;zero overflow byte
	inc	hl		;point to sign
	ld	(hl),200o	;assume a positive number
	rla			;put sign in carry
	jp	fadflt		;go and float the number


	;fall into neg


;
;	;get the valtyp and set condition codes as follows:
;;condition code		true set	false set
;;sign			int=2		str,sng,dbl
;;zero			str=3		int,sng,dbl
;;odd parity		sng=4		int,str,dbl
;;no carry		dbl=10		int,str,sng
;getype:	lda	valtyp		;get the valtyp
;	cpi	10		;set carry correctly
;	dcr	a		;set the other condition codes correctly
;	dcr	a		; without affecting carry
;	dcr	a
;	ret	*			;all done


	;absolute value of fac
	;alters a,b,c,d,e,h,l
abs:	call	vsign		;get the sign of the fac in a
	ret	p		;if it is positive, we are done


	;negate any type value in the fac
	;alters a,b,c,d,e,h,l
vneg:	call	getypr		;see what kind of number we have
	jp	m,ineg		;we have an integer, negate it that way
	jp	z,tmerr		;blow up on strings
	;fall into neg to negate a sng or dbl


	;negate number in the fac
	;alters a,h,l
	;note: the number must be packed

	;if intfsw=0 do not use intel format
rneg:	ld	hl,fac-1	;get pointer to sign
	ld	a,(hl)		;get sign
	xor	200o		;complement sign bit
	ld	(hl),a		;save it
	ret			;all done


	;sgn function
	;alters a,h,l
sgn:	call	vsign		;get the sign of the fac in a
	;entry to convert a signed number in a to an integer
conia:	ld	l,a		;put it in the lo position
	rla			;extend the sign to the ho
	sbc	a,a
	ld	h,a
	jp	makint		;return the result and set valtyp


	;get the sign of the value in the fac in a
	;alters a,h,l
vsign:	call	getypr		;see what kind of a number we have
	jp	z,tmerr		;blow up on strings
	jp	p,sign		;single and double prec. work the same
	ld	hl,(faclo)	;get the integer argument

	;entry to find the sign of (hl)
	;alters a only
isign:	ld	a,h		;get its sign
	or	l		;check if the number is zero
	ret	z		;it is, we are done
	ld	a,h		;it isn'T, SIGN IS THE SIGN OF H
	jp	icomps		;go set a correctly
	page
	;subttl	floating point movement routines
	;put fac on stack
	;alters d,e
pushf:	ex	de,hl		;save (hl)
	ld	hl,(faclo)	;get lo'S
	ex	(sp),hl		;switch lo'S AND RET ADDR
	push	hl		;put ret addr back on stack
	ld	hl,(fac-1)	;get ho'S
	ex	(sp),hl		;switch ho'S AND RET ADDR
	push	hl		;put ret addr back on stack
	ex	de,hl		;get old (hl) back
	ret			;all done


	;move number from memory [(hl)] to fac
	;alters b,c,d,e,h,l
	;at exit number is in b,c,d,e
	;at exit (hl):=(hl)+4
movfm:	call	movrm		;get number in registers
	;fall into movfr and put it in fac


	;move registers (b,c,d,e) to fac
	;alters d,e
movfr:	ex	de,hl		;get lo'S IN (HL)
	ld	(faclo),hl	;put them where they belong
	ld	h,b		;get ho'S IN (HL)
	ld	l,c
	ld	(fac-1),hl	;put ho'S WHERE THEY BELONG
	ex	de,hl		;get old (hl) back
	ret			;all done


	;move fac to registers (b,c,d,e)
	;alters b,c,d,e,h,l
movrf:	ld	hl,faclo	;get pointer to fac
	;fall into movrm


	;get number in registers (b,c,d,e) from memory [(hl)]
	;alters b,c,d,e,h,l
	;at exit (hl):=(hl)+4
movrm:	ld	e,(hl)		;get lo
	inc	hl		;point to mo
getbcd:	ld	d,(hl)		;get mo, entry for bill
	inc	hl		;point to ho
	ld	c,(hl)		;get ho
	inc	hl		;point to exponent
	ld	b,(hl)		;get exponent
inxhrt:	inc	hl		;inc pointer to beginning of next number
	ret			;all done


	;move number from fac to memory [(hl)]
	;alters a,b,d,e,h,l
movmf:	ld	de,faclo	;get pointer to fac
	;fall into move


	;move number from (de) to (hl)
	;alters a,b,d,e,h,l
	;exits with (de):=(de)+4, (hl):=(hl)+4
move:	ld	b,4		;set counter
	jp	move1		;continue with the move


	;move any type value (as indicated by valtyp) from (de) to (hl)
	;alters a,b,d,e,h,l
movvfm:	ex	de,hl		;entry to switch (de) and (hl)
vmove:	ld	a,(valtyp)	;get the length of the number
	ld	b,a		;save it away
	public	move1
move1:	ld	a,(de)		;get word, entry from vmovmf
	ld	(hl),a		;put it where it belongs
	inc	de		;increment pointers to next word
	inc	hl
	dec	b
	jp	nz,move1
	ret


	;unpack the fac and the registers
	;alters a,c,h,l
	;when the number in the fac is unacked, the assumed one in the
	;mantissa is restored, and the complement of the sign is placed
	;in fac+1

	;intel floating software flag
unpack:	ld	hl,fac-1	;point to ho and sign
	ld	a,(hl)		;get ho and sign
	rlca			;duplicate the sign in carry and the lsb
	scf			;restore the hidden one
	rra			;restore the number in a
	ld	(hl),a		;save ho
	ccf			;get the complement of the sign
	rra			;get it in the sign bit
	inc	hl		;point to temporary sign byte
	inc	hl
	ld	(hl),a		;save complement of sign
	ld	a,c		;get ho and sign of the registers
	rlca			;duplicate the sign in carry and the lsb
	scf			;restore the hidden one
	rra			;restore the ho in a
	ld	c,a		;save the ho
	rra			;get the sign back
	xor	(hl)		;compare sign of fac and sign of registers
	ret			;all done


	;move any type value from memory [(hl)] to fac
	;alters a,b,d,e,h,l
vmovfa:	ld	hl,arglo	;entry from dadd, move arg to fac
vmovfm:	ld	de,movvfm	;get address of location that does
	jp	vmvvfm		; an "XCHG" and falls into move1


	;move any type value from fac to memory [(hl)]
	;alters a,b,d,e,h,l
vmovaf:	ld	hl,arglo	;entry from fin, dmul10, ddiv10
	;move fac to arg
vmovmf:	ld	de,vmove	;get address of move subroutine
vmvvfm:	push	de		;shove it on the stack
vdfacs:	ld	de,faclo	;get first address for int, str, sng
	call	getypr		;get the value type
	ret	c		;go move it if we do not have a dbl
	ld	de,dfaclo	;we do, get lo addr of the dbl number
	ret			;go do the move
	page
	;subttl	compare two numbers
	;compare two single precision numbers
	;a=1 if arg .lt. fac
	;a=0 if arg=fac
	;a=-1 if arg .gt. fac
	;dorel depends upon the fact that fcomp returns with carry on
	; iff a has 377
	;alters a,h,l
fcomp:	ld	a,b		;check if arg is zero
	or	a
	jp	z,sign
	ld	hl,fcomps	;we jump to fcomps when we are done
	push	hl		;put the address on the stack
	call	sign		;check if fac is zero
	ld	a,c		;if it is, result is minus the sign of arg
	ret	z		;it is
	ld	hl,fac-1	;point to sign of fac
	xor	(hl)		;see if the signs are the same
	ld	a,c		;if they are different, result is sign of arg
	ret	m		;they are different
	call	fcomp2		;check the rest of the number
fcompd:	rra			;numbers are different, change sign if
	xor	c		; both numbers are negative
	ret			;go set up a

fcomp2:	inc	hl	;point to exponent
	ld	a,b		;get exponent of arg
	cp	(hl)		;compare the two
	ret	nz		;numbers are different
	dec	hl		;point to ho
	ld	a,c		;get ho of arg
	cp	(hl)		;compare with ho of fac
	ret	nz		;they are different
	dec	hl		;point to mo of fac
	ld	a,d		;get mo of arg
	cp	(hl)		;compare with mo of fac
	ret	nz		;the numbers are different
	dec	hl		;point to lo of fac
	ld	a,e		;get lo of arg
	sub	(hl)		;subtract lo of fac
	ret	nz		;numbers are different
	pop	hl		;numbers are the same, don'T SCREW UP STACK
	pop	hl
	ret			;all done


	;compare two integers
	;a=1 if (de) .lt. (hl)
	;a=0 if (de)=(hl)
	;a=-1 if (de) .gt. (hl)
	;alters a only
icomp:	ld	a,d		;are the signs the same?
	xor	h
	ld	a,h		;if not, answer is the sign of (hl)
	jp	m,icomps	;they are different
	cp	d		;they are the same, compare the ho'S
	jp	nz,signs	;go set up a
	ld	a,l		;compare the lo'S
	sub	e
	jp	nz,signs	;go set up a
	ret			;all done, they are the same


	;compare two double precision numbers
	;a=1 if arg .lt. fac
	;a=0 if arg=fac
	;a=-1 if arg .gt. fac
	;alters a,b,c,d,e,h,l
dcompd:	ld	hl,arglo	;entry with pointer to arg in (de)
	call	vmove		;move the argument into arg
	public	xdcomp
xdcomp:	ld	de,arg		;get pointer to arg
	ld	a,(de)		;see if arg=0
	or	a
	jp	z,sign		;arg=0, go set up a
	ld	hl,fcomps	;push fcomps on stack so we will return to
	push	hl		; to it and set up a
	call	sign		;see if fac=0
	dec	de		;point to sign of argument
	ld	a,(de)		;get sign of arg
	ld	c,a		;save it for later
	ret	z		;fac=0, sign of result is sign of arg
	ld	hl,fac-1	;point to sign of fac
	xor	(hl)		;see if the signs are the same
	ld	a,c		;if they are, get the sign of the numbers
	ret	m		;the signs are different, go set a
	inc	de		;point back to exponent of arg
	inc	hl		;point to exponent of fac
	ld	b,10o		;set up a count
dcomp1:	ld	a,(de)		;get a byte from arg
	sub	(hl)		;compare it with the fac
	jp	nz,fcompd	;they are different, go set up a
	dec	de		;they are the same, examine the next lower
	dec	hl		; order bytes
	dec	b		;are we done?
	jp	nz,dcomp1	;no, compare the next bytes
	pop	bc		;they are the same, get fcomps off stack
	ret			;all done


	;compare two double precision numbers
	;a=1 if arg .gt. fac
	;a=0 if arg=fac
	;a=-1 if arg .lt. fac
	;note:	this is the reverse of icomp, fcomp and xdcomp
	;alters a,b,c,d,e,h,l
dcomp:	call	xdcomp		;compare the two numbers
	jp	nz,fcomps	;negate the answer, make sure the carry comes
	ret			; out correct for docmp
	page
	;subttl	conversion routines between integer, single and double precision
	;force the fac to be an integer
	;alters a,b,c,d,e,h,l
frcint:	call	getypr		;see what we have
	ld	hl,(faclo)	;get faclo+0,1 in case we have an integer
	ret	m		;we have an integer, all done
	jp	z,tmerr		;we have a string, that is a "NO-NO"
	jp	po,frcin2	;go do s.p.
fdbint:	call	vmovaf		;add d.p. .5
	ld	hl,dhalf	;
	call	vmovfm
	call	dadd		;
frdbin:	call	consd
	jp	frcin3
frcin2:	call	faddh
frcin3:	ld	a,(fac-1)	;get sign byte
	or	a		;set condition codes correctly
	push	af
	and	177o		;clear sign
	ld	(fac-1),a	;make fac positive
	ld	a,(fac)		;get exponent
	cp	220o		;see if too large
	jp	nc,overr	;
	call	qint		;convert to integer
	ld	a,(fac)
	or	a
	jp	nz,frciaa
	pop	af		;
	ex	de,hl
	jp	frci3a
frciaa:
	pop	af		;
	ex	de,hl		;move integer to (hl)
	jp	p,frcin4
frci3a:	ld	a,h
	cpl
	ld	h,a		;complement (hl)
	ld	a,l
	cpl
	ld	l,a		;
frcin4:	jp	makint
	ld	hl,overr	;put overr on the stack so we will get error
	push	hl		; if number is too big
	;fall into conis


	;convert single precision number to integer
	;alters a,b,c,d,e,h,l
	public	conis
conis:	ld	a,(fac)		;get the exponent
	cp	220o		;see if it is too big
	jp	nc,conis2	;it is, but it might be -32768
	call	qint		;it isn'T, CONVERT IT TO AN INTEGER
	ex	de,hl		;put it in (hl)
	;entry from iadd
conis1:	pop	de		;get error address off stack

	;put (hl) in faclo, set valtyp to int
	;alters a only
makint:	ld	(faclo),hl	;store the number in faclo
valint:	ld	a,2		;set valtyp to "INTEGER"
conisd:	ld	(valtyp),a	;entry from conds
	ret			;all done

conis2:	ld	bc,220q*256+200q
	ld	de,000q*256+000q;check if number is -32768, entry from fin
	call	fcomp
	ret	nz		;error:  it can'T BE CONVERTED TO AN INTEGER
	ld	h,c		;it is -32768, put it in (hl)

	ld	l,d
	jp	conis1		;store it in the fac and set valtyp


	;force the fac to be a single precision number
	;alters a,b,c,d,e,h,l
frcsng:	call	getypr		;see what kind of number we have
	ret	po		;we already have a sng, all done
	jp	m,consi		;we have an integer, convert it
	jp	z,tmerr		;strings!! -- error!!
	;dbl prec -- fall into consd


	;convert double precision number to a single precison one
	;alters a,b,c,d,e,h,l
	public	consd
consd:	call	movrf		;get the ho'S IN THE REGISTERS
	call	valsng		;set valtyp to "SINGLE PRECISON"
	ld	a,b		;check if the number is zero
	or	a
	ret	z		;if it is, we are done
	call	unpack		;unpack the number
	ld	hl,faclo-1	;get first byte below a sng number
	ld	b,(hl)		;put it in b for round
	jp	round		;round the dbl number up and we are done


	;convert an integer to a single precision number
	;alters a,b,c,d,e,h,l
	public	consi
consi:	ld	hl,(faclo)	;get the integer
consih:	call	valsng		;set valtyp to "SINGLE PRECISION"
	ld	a,h		;set up registers for floatr
	ld	d,l
	ld	e,0
	ld	b,220o
	jp	floatr		;go float the number


	;force the fac to be a double precision number
	;alters a,b,c,d,e,h,l
frcdbl:	call	getypr		;see what kind of number we have
	ret	nc		;we already have a dbl, we are done
	jp	z,tmerr		;give an error if we have a string
	call	m,consi		;convert to sng if we have an int
	;fall into conds and convert to dbl


	;convert a single precision number to a double precision one
	;alters a,h,l
	public	conds
conds:	ld	hl,0		;zero h,l
	ld	(dfaclo),hl	;clear the four lower bytes in the double
	ld	(dfaclo+2),hl	; precision number
valdbl:	ld	a,10o		;set valtyp to "DOUBLE PRECISION"
	defb	001		;"LXI	B" over the next 2 bytes
valsng:	ld	a,4		;set valtyp to "SINGLE PRECISION"
	jp	conisd		;go to it


	;force the fac to be a string
	;alters a only
chkstr:
frcstr:	call	getypr		;see what kind of value we have
	ret	z		;we have a string, everything is ok
	jp	tmerr		;we don'T HAVE A STRING, FALL INTO TMERR

	page
	;subttl	greatest integer function
	;quick greatest integer function
	;leaves int(fac) in c,d,e (signed)
	;assumes fac .lt. 2^23 = 8388608
	;assumes the exponent of fac is in a
	;alters a,b,c,d,e
qint:	ld	b,a		;zero b,c,d,e in case the number is zero
	ld	c,a
	ld	d,a
	ld	e,a
	or	a		;set condition codes
	ret	z		;it is zero, we are done

;the hard case in qint is negative non-integers.  to handle this, if the
;number is negative, we regard the 3-byte mantissa as a 3-byte integer and
;subtarct one.  then all the fractional bits are shifted out by shifting the
;mantissa right.  then, if the number was negative, we add one.  so, if we
;had a negative integer, all the bits to the right of the binary point were
;zero.  so the net effect is we have the original number in c,d,e.  if the
;number was a negative non-integer, there is at least one non-zero bit to the
;right of the binary point.  so the net effect is that we get the absolute
;value of int(fac) in c,d,e.  c,d,e is then negated if the original number was
;negative so the result will be signed.
	push	hl		;save (hl)
	call	movrf		;get number in the registers
	call	unpack		;unpack the number
	xor	(hl)		;get sign of number
	ld	h,a		;don'T LOSE IT
	call	m,qinta		;subtract 1 from lo if number is negative
	ld	a,230o		;see how many we have to shift to change
	sub	b		; number to an integer
	call	shiftr		;shift number to get rid of fractional bits
	ld	a,h		;get sign
	rla			;put sign in carry so it will not be changed
	call	c,rounda	;if number was negative, add one
	ld	b,0		;forget the bits we shifted out
	call	c,negr		;negate number if it was negative because we
				; want a signed mantissa
	pop	hl		;get old (hl) back
	ret			;all done

qinta:	dec	de		;subtract one from c,d,e
	ld	a,d		;we have to subtract one from c if
	and	e		; d and e are both all ones
	inc	a		;see if both were -1
	ret	nz		;they were not, we are done
	public	dcxbrt
dcxbrt:	dec	bc		;this is for bill.  c will never be zero
				; (the msb will always be one) so "DCX	B"
				; and "DCR	C" are functionally equivalent
	ret			;all done
	; this is the fix (x) function. it returns
	; fix(x)=sgn(x)*int(abs(x))
	public	fixer
fixer:	call	getypr		;get valtype of arg
	ret	m		;int, done
	call	sign		;get sign
	jp	p,vint		;if positive, just call regular int code
	call	rneg		;negate it
	call	vint		;get the integer of it
	jp	vneg		;now re-negate it

	;greatest integer function
	;alters a,b,c,d,e,h,l
vint:	call	getypr		;see what type of a number we have
	ret	m		;it is an integer, all done
	jp	nc,dint		;convert the double precision number
	jp	z,tmerr		;blow up on strings
	call	conis		;try to convert the number to an integer
	;if we can'T, WE WILL RETURN HERE TO GIVE A
	; single precision result
int:	ld	hl,fac		;get exponent
	ld	a,(hl)
	cp	230o		;see if number has any fractional bits

	;the only guy who needs this doesn'T CARE
	ld	a,(faclo)	; about the sign
	ret	nc		;it does not
	ld	a,(hl)		;get exponent back
	call	qint		;it does, shift them out
	ld	(hl),230o	;change exponent so it will be correct
	;note:qint unpacked the number!!!!
	; after normalization
	ld	a,e		;get lo
	push	af		;save it
	ld	a,c		;negate number if it is negative
	rla			;put sign in carry
	call	fadflt		;refloat number
	pop	af		;get lo back
	ret			;all done


	;greatest integer function for double precision numbers
	;alters a,b,c,d,e,h,l
dint:	ld	hl,fac		;get pointer to fac
	ld	a,(hl)		;get exponent
	cp	220o		;can we convert it to an integer?
din00:	jp	nz,dint2	;check for -32768
	ld	c,a		;save exponent in c
	dec	hl		;get pointer to sign and ho
	ld	a,(hl)		;get sign and ho
	xor	200o		;check if it is 200
	ld	b,6		;set up a count to check if the rest of
dint1:	dec	hl		; the number is zero, point to next byte
	or	(hl)		;if any bits are non-zero, a will be non-zero
	dec	b		;are we done?
	jp	nz,dint1	;no, check the next lower order byte
	or	a		;is a now zero?
	ld	hl,200o*400o+0	;get -32768 just in case
	jp	nz,din05
	call	makint		;a is zero so we have -32768
	jp	frcdbl		;force back to double
din05:	ld	a,c		;get exponent
	public	dint2
dint2:	or	a		;check for zero value
	ret	z		;***fix 5.11***^1 -- alalow 0 in dint
	cp	270o		;are there any fractional bits?
	ret	nc		;no, the number is already an integer

	public	dintfo
dintfo:	push	af		;entry from fout, carry is zero if we come
				; here from fout
	call	movrf		;get ho'S OF NUMBER IN REGISTERS FOR UNPACKING
	call	unpack		;unpack it
	xor	(hl)		;get its sign back
	dec	hl		;set the exponent to normalize correctly
	ld	(hl),270o
	push	af		;save the sign
	dec	hl
	ld	(hl),c		;get unpacked high byte
	call	m,dinta		;subtract 1 from lo if number is negative
	ld	a,(fac-1)	;fetch new high mantissa byte
	ld	c,a		;and put in c
	ld	hl,fac-1	;point to the ho of the fac
	ld	a,270o		;get how many bits we have to shift out
	sub	b
	call	dshftr		;shift them out!!
	pop	af		;get the sign back
	call	m,drouna	;if number was negative, add one
	xor	a		;put a zero in the extra lo byte so when
	ld	(dfaclo-1),a	; we normalize, we will shift in zeros
	pop	af		;if we were called from fout, don'T NORMALIZE,
	ret	nc		; just return
	jp	dnorml		;re-float the integer

dinta:	ld	hl,dfaclo	;subtract one from fac, get pointer to lo
dinta1:	ld	a,(hl)		;get a byte of fac
	dec	(hl)		;subtract one from it
	or	a		;continue only if the byte used to be zero
	inc	hl		;increment pointer to next byte
	jp	z,dinta1	;continue if necessary
	ret			;all done
	page
	;subttl	integer arithmetic routines
	;integer multiply for multiply dimensioned arrays
	; (de):=(bc)*(de)
	;overflow causes a bs error
	;alters a,b,c,d,e
umult:	push	hl		;save [h,l]
	ld	hl,0		;zero product registers
	ld	a,b		;check if (bc) is zero
	or	c		;if so, just return, (hl) is already zero
	jp	z,mulret	;this is done for speed
	ld	a,20o		;set up a count
umult1:	add	hl,hl		;rotate (hl) left one
	jp	c,bserr		;check for overflow, if so,
	ex	de,hl		; bad subscript (bs) error
	add	hl,hl		;rotate (de) left one
	ex	de,hl
	jp	nc,umult2	;add in (bc) if ho was 1
	add	hl,bc
	jp	c,bserr		;check for overflow
umult2:	dec	a		;see if done
	jp	nz,umult1
mulret:	ex	de,hl		;return the result in [d,e]
	pop	hl		;get back the saved [h,l]
	ret


;
;	integer arithmetic conventions
;
;integer variables are 2 byte, signed numbers
;	the lo byte comes first in memory
;
;calling conventions:
;for one argument functions:
;	the argument is in (hl), the result is left in (hl)
;for two argument operations:
;	the first argument is in (de)
;	the second argument is in (hl)
;	the result is left in the fac and if no overflow, (hl)
;if overflow occurs, the arguments are converted to single precision
;when integers are stored in the fac, they are stored at faclo+0,1
;valtyp(integer)=2
;%


	;integer subtrtaction	(hl):=(de)-(hl)
	;alters a,b,c,d,e,h,l
isub:	ld	a,h		;extend the sign of (hl) to b
	rla			;get sign in carry
	sbc	a,a
	ld	b,a
	call	ineghl		;negate (hl)
	ld	a,c		;get a zero
	sbc	a,b		;negate sign
	jp	iadds		;go add the numbers


	;integer addition	(hl):=(de)+(hl)
	;alters a,b,c,d,e,h,l
iadd:	ld	a,h		;extend the sign of (hl) to b
	rla			;get sign in carry
	sbc	a,a
iadds:	ld	b,a		;save the sign
	push	hl		;save the second argument in case of overflow
	ld	a,d		;extend the sign of (de) to a
	rla			;get sign in carry
	sbc	a,a
	add	hl,de		;add the two lo'S
	adc	a,b		;add the extra ho
	rrca			;if the lsb of a is different from the msb of
	xor	h		; h, then overflow occured
	jp	p,conis1	;no overflow, get old (hl) off stack and we
				; are done, save (hl) in the fac also
	push	bc		;overflow -- save extended sign of (hl)
	ex	de,hl		;get (de) in (hl)
	call	consih		;float it
	pop	af		;get sign of (hl) in a
	pop	hl		;get old (hl) back
	call	pushf		;put first argument on stack
	ex	de,hl		;put second argument in (de) for floatr
	call	inegad		;float it
	jp	faddt		;add the two numbers using single precision


	;integer multiplication		(hl):=(de)*(hl)
	;alters a,b,c,d,e,h,l
imult:	ld	a,h		;check (hl) if is zero, if so
	or	l		; just return.  this is for speed.
	jp	z,makint	;update faclo to be zero and return
	push	hl		;save second argument in case of overflow
	push	de		;save first argument
	call	imuldv		;fix up the signs
	push	bc		;save the sign of the result
	ld	b,h		;copy second argument into (bc)
	ld	c,l
	ld	hl,0		;zero (hl), that is where the product goes
	ld	a,20o		;set up a count
imult1:	add	hl,hl		;rotate product left one
	jp	c,imult5	;check for overlfow
	ex	de,hl		;rotate first argument left one to see if
	add	hl,hl		; we add in (bc) or not
	ex	de,hl
	jp	nc,imult2	;don'T ADD IN ANYTHING
	add	hl,bc		;add in (bc)
	jp	c,imult5	;check for overlfow
imult2:	dec	a		;are we done?
	jp	nz,imult1	;no, do it again
	pop	bc		;we are done, get sign of result
	pop	de		;get original first argument
imldiv:	ld	a,h		;entry from idiv, is result .ge. 32768?
	or	a
	jp	m,imult3	;it is, check for special case of -32768
	pop	de		;result is ok, get second argument off stack
	ld	a,b		;get the sign of result in a
	jp	inega		;negate the result if necessary
imult3:	xor	200o		;is result 32768?
	or	l		;note: if we get here from idiv, the result
	jp	z,imult4	; must be 32768, it cannot be greater
	ex	de,hl		;it is .gt. 32768, we have overflow
	defb	001		;"LXI	B" over next 2 bytes
imult5:	pop	bc		;get sign of result off stack
	pop	hl		;get the original first argument
	call	consih		;float it
	pop	hl		;get the original second argument
	call	pushf		;save floated first arument
	call	consih		;float second argument
fmultt:	pop	bc
	pop	de
	;get first argument off stack, entry from polyx
	jp	fmult		;multiply the arguments using single precision
imult4:	ld	a,b		;is result +32768 or -32768?
	or	a		;get its sign
	pop	bc		;discard original second argument
	jp	m,makint	;the result should be negative, it is ok
	push	de		;it is positive, save remainder for mod
	call	consih		;float -32768
	pop	de		;get mod'S REMAINDER BACK
	jp	rneg		;negate -32768 to get 32768, we are done


	;integer division	(hl):=(de)/(hl)
	;remainder is in (de), quotient in (hl)
	;alters a,b,c,d,e,h,l
idiv:	ld	a,h		;check for division by zero
	or	l
	jp	z,dv0err	;we have division by zero!!
	call	imuldv		;fix up the signs
	push	bc		;save the sign of the result
	ex	de,hl		;get denominator in (hl)
	call	ineghl		;negate it
	ld	b,h		;save negated denominator in (bc)
	ld	c,l
	ld	hl,0		;zero where we do the subtraction
	ld	a,21o		;set up a count
	push	af		;save it
	or	a		;clear carry
	jp	idiv3		;go divide
idiv1:	push	af		;save count
	push	hl		;save (hl) i.e. current numerator
	add	hl,bc		;subtract denominator
	jp	nc,idiv2	;we subtracted too much, get old (hl) back
	pop	af		;the subtraction was good, discard old (hl)
	scf			;next bit in quotient is a one
	defb	076o		;"MVI	A" over next byte
idiv2:	pop	hl		;ignore the subtraction, we couldn'T DO IT
idiv3:	ld	a,e		;shift in the next quotient bit
	rla
	ld	e,a
	ld	a,d		;shift the ho
	rla
	ld	d,a
	ld	a,l		;shift in the next bit of the numerator
	rla
	ld	l,a
	ld	a,h		;do the ho
	rla
	ld	h,a		;save the ho
	pop	af		;get count back
	dec	a		;are we done?
	jp	nz,idiv1	;no, divide again
	ex	de,hl		;get quotient in (hl), remainder in (de)
	pop	bc		;get sign of result
	push	de		;save remainder so stack will be alright
	jp	imldiv		;check for special case of 32768


	;get ready to multiply or divide
	;alters a,b,c,d,e,h,l
imuldv:	ld	a,h		;get sign of result
	xor	d
	ld	b,a		;save it in b
	call	inegh		;negate second argument if necesary
	ex	de,hl		;put (de) in (hl), fall in and negate first
				; argument if necessary


	;negate h,l
	;alters a,c,h,l
inegh:	ld	a,h		;get sign of (hl)
inega:	or	a		;set condition codes
	jp	p,makint	;we don'T HAVE TO NEGATE, IT IS POSITIVE
	;save the result in the fac for when
	; operators return through here
ineghl:	xor	a		;clear a
	ld	c,a		;store a zero (we use this method for isub)
	sub	l		;negate lo
	ld	l,a		;save it
	ld	a,c		;get a zero back
	sbc	a,h		;negate ho
	ld	h,a		;save it
	jp	makint		;all done, save the result in the fac
				; for when operators return through here


	;integer negation
	;alters a,b,c,d,e,h,l
ineg:	ld	hl,(faclo)	;get the integer
	call	ineghl		;negate it
	ld	a,h		;get the high order
	xor	200o		;check for special case of 32768
	or	l
	ret	nz		;it did not occur, everything is fine
	public	ineg2
ineg2:	ex	de,hl		;we have it, float 32768
	call	valsng		;change valtyp to "SINGLE PRECISION"
	xor	a		;get a zero for the high order
inegad:	ld	b,230o		;entry from iadd, set exponent
	jp	floatr		;go float the number


	;mod operator
	;(hl):=(de)-(de)/(hl)*(hl),  (de)=quotient
	;alters a,b,c,d,e,h,l
imod:	push	de		;save (de) for its sign
	call	idiv		;divide and get the remainder
	xor	a		;turnoff the carry and tranfer
	add	a,d		;the remainder*2 which is in [d,e]
	rra			;to [h,l] dividing by two
	ld	h,a
	ld	a,e
	rra
	ld	l,a		; ***whg01*** fix to mod operator
	call	valint		;set valtyp to "INTEGER" in case result of
				; the division was 32768
	pop	af		;get the sign of the remainder back
	jp	inega		;negate the remainder if necessary
	page

	;subttl	double precision arithmetic routines
;
;	double precision arithmetic conventions
;
;double precision numbers are 8 byte quantities
;the last 4 bytes in memory are in the same format as single precision numbers
;the first 4 bytes are 32 more low order bits of precision
;the lowest order byte comes first in memory
;
;calling conventions:
;for one argument functions:
;	the argument is in the fac, the result is left in the fac
;for two argument operations:
;	the first argument is in the fac
;	the second argument is in arg-7,6,5,4,3,2,1,0  (note: arglo=arg-7)
;	the result is left in the fac
;note:	this order is reversed from int and sng
;valtyp(double precision)=10 octal
;%


	;double precision subtraction	fac:=fac-arg
	;alters all registers
dsub:	ld	hl,arg-1	;negate the second argument
	ld	a,(hl)		;get the ho and sign
	xor	200o		;complemnt the sign
	ld	(hl),a		;put it back
	;fall into dadd


	;double precision addition	fac:=fac+arg
	;alters all registers
dadd:	ld	hl,arg		;get  pointer to exponent of first argument
	ld	a,(hl)		;check if it is zero
	or	a
	ret	z		;it is, result is already in fac
	ld	b,a		;save exponent for unpacking
	dec	hl		;point to ho and sign
	ld	c,(hl)		;get ho and sign for unpacking
	ld	de,fac		;get pointer to exponent of second argument
	ld	a,(de)		;get exponent
	or	a		;see if it is zero
	jp	z,vmovfa	;it is, move arg to fac and we are done
	sub	b		;subtract exponents to get shift count
	jp	nc,dadd2	;put the smaller number in fac
	cpl			;negate shift count
	inc	a
	push	af		;save shift count
	ld	c,10o		;switch fac and arg, set up a count
	inc	hl		;point to arg
	push	hl		;save pointer to arg
dadd1:	ld	a,(de)		;get a byte of the fac
	ld	b,(hl)		;get a byte of arg
	ld	(hl),a		;put the fac byte in arg
	ld	a,b		;put the arg byte in a
	ld	(de),a		;put the arg byte in fac
	dec	de		;point to the next lo byte of fac
	dec	hl		;point to the next lo byte of arg
	dec	c		;are we done?
	jp	nz,dadd1	;no, do the next lo byte
	pop	hl		;get the ho back
	ld	b,(hl)		;get the exponent
	dec	hl		;point to the ho and sign
	ld	c,(hl)		;get ho and sign for unpacking
	pop	af		;get the shift count back
dadd2:	cp	71o		;are we within 56 bits?
	ret	nc		;no, all done
	push	af		;save shift count
	call	unpack		;unpack the numbers
	ld	hl,arglo-1	;point to arglo-1
	ld	b,a		;save subtraction flag
	ld	a,0		;
	ld	(hl),a		;clear temporary least sig byte
	ld	(dfaclo-1),a	;clear extra byte
	pop	af		;get shift count
	ld	hl,arg-1	;point to the ho of arg
	call	dshftr		;shift arg right the right number of times
	ld	a,(arglo-1)	;transfer overflow byte
	ld	(dfaclo-1),a	;from arg to fac
	ld	a,b
	or	a		;get subtraction flag
	jp	p,dadd3		;subtract numbers if their signs are different
	call	daddaa		;signs are the same, add the numbers
	jp	nc,dround	;round the result if no carry
	ex	de,hl		;get pointer to fac in (hl)
	inc	(hl)		;add 1 to exponent
	jp	z,ovfin4
	call	dshfrb		;shift number right one, shift in carry
	jp	dround		;round the result
dadd3:
	defb	076o		;"MVI	A", subtract the numbers
	sbc	a,(hl)		;get the subtract instruction in a
	call	dadda		;subtract the numbers
	ld	hl,fac+1	;fix [h,l] to point to sign for dnegr
	call	c,dnegr		;negate the result if it was negative
	;fall into dnorml


	;normalize fac
	;alters a,b,c,d,h,l
dnorml:	xor	a		;clear shift count
dnorm1:	ld	b,a		;save shift count
	ld	a,(fac-1)	;get ho
	or	a		;see if we can shift 8 left
	jp	nz,dnorm5	;we can'T, SEE IF NUMBER IS NORMALIZED
	ld	hl,dfaclo-1	;we can, get pointer to lo
	ld	c,10o		;set up a count
dnorm2:	ld	d,(hl)		;get a byte of fac
	ld	(hl),a		;put in byte from last location, the first
				; time through a is zero
	ld	a,d		;put the current byte in a for next time
	inc	hl		;increment pointer to next higher order
	dec	c		;are we done?
	jp	nz,dnorm2	;no, do the next byte
	ld	a,b		;subtract 8 from shift count
	sub	10o
	cp	300o		;have we shifted all bytes to zero?
	jp	nz,dnorm1	;no, try to shift 8 more
	jp	zero		;yes, the number is zero
dnorm3:	dec	b		;decrement shift count
	ld	hl,dfaclo-1	;get pointer to lo
	call	dshflc		;shift the fac left
	or	a		;see if number is normalized
dnorm5:	jp	p,dnorm3	;shift fac left one if it is not normalized
	ld	a,b		;get the shift count
	or	a		;see if no shifting was done
	jp	z,dround	;none was, proceed to round the number
	ld	hl,fac		;get pointer to exponent
	add	a,(hl)		;update it
	ld	(hl),a		;save updated exponent
	jp	nc,zero		;underflow, the result is zero
	ret	z		;result is already zero, we are done
	;fall into dround and round the result


	;round fac
	;alters a,b,h,l
dround:	ld	a,(dfaclo-1)	;get extra byte to see if we have to round
drounb:	or	a		;entry from ddiv
	call	m,drouna	;round up if necessary
	ld	hl,fac+1	;get pointer to unpacked sign
	ld	a,(hl)		;get sign
	and	200o		;isolate sign bit
	dec	hl		;point to ho
	dec	hl
	xor	(hl)		;pack sign and ho
	ld	(hl),a		;put packed sign and ho in fac
	ret			;we are done



	;subroutine for round: add one to fac
drouna:	ld	hl,dfaclo	;get pointer to lo, entry from dint
	ld	b,7		;set up a count
drona1:	inc	(hl)		;increment a byte
	ret	nz		;return if there was no carry
	inc	hl		;increment pointer to next higher order
	dec	b		;have we incremented all bytes
	jp	nz,drona1	;no, try the next one
	inc	(hl)		;yes, increment the exponent
	jp	z,ovfin4
	dec	hl		;the number overflowed its exponent
	ld	(hl),200o	;put 200 in ho
	ret			;all done


	;add or subtract 2 dbl quantities
	;alters a,c,d,e,h,l
daddd:	ld	de,fbuffr+27	;entry from ddiv
	ld	hl,arglo	;add or subtract fbuffr+^d27 and arg
	jp	dadds		;do the operation

daddaa:	defb	076o		;"MVI	A", entry from dadd, dmult
	adc	a,(hl)		;setup add instruction for loop
dadda:	ld	hl,arglo	;get pointer to arg, entry from dadd
daddfo:	ld	de,dfaclo	;get pointer to fac, entry from fout
dadds:	ld	c,7		;set up a count
dadds1:
	ld	(daddop),a	;store the add or subtract instruction
	xor	a		;clear carry
daddl:	ld	a,(de)		;get a byte from result number
daddop:	adc	a,(hl)		;this is either "ADC	M" or "SBB	M"
	ld	(de),a		;save the changed byte
	inc	de		;increment pointers to next higher order byte
	inc	hl
	dec	c		;are we done?
	jp	nz,daddl	;no, do the next higher order byte
	ret			;all done




	;negate signed number in fac
	;this is used by dadd, dint
	;alters a,b,c,h,l
dnegr:	ld	a,(hl)		;complement sign of fac
	cpl			;use the unpacked sign byte
	ld	(hl),a		;save the new sign
	ld	hl,dfaclo-1	;get pointer to lo
	ld	b,10o		;set up a count
	xor	a		;clear carry and get a zero
	ld	c,a		;save zero in c
dnegr1:	ld	a,c		;get a zero
	sbc	a,(hl)		;negate the byte of fac
	ld	(hl),a		;update fac
	inc	hl		;increment pointer to next higher order byte
	dec	b		;are we done?
	jp	nz,dnegr1	;no, negate the next byte
	ret			;all done


	;shift dbl fac right one
	;a = shift count
	;alters a,c,d,e,h,l
dshftr:	ld	(hl),c		;put the unpacked ho back
	push	hl		;save pointer to what to shift
dshfr1:	sub	10o		;see if we can shift 8 right
	jp	c,dshfr3	;we can'T, CHECK IF WE ARE DONE
	pop	hl		;get pointer back
dshfrm:	push	hl		;entry from dmult, save pointer to ho
	ld	de,10o*400o+0	;shift a zero into the ho, set up a count
dshfr2:	ld	c,(hl)		;save a byte of fac
	ld	(hl),e		;put the last byte in its place
	ld	e,c		;set up e for next time through the loop
	dec	hl		;point to next lower order byte
	dec	d		;are we done?
	jp	nz,dshfr2	;no, do the next byte
	jp	dshfr1		;yes, see if we can shift over 8 more
dshfr3:	add	a,11o		;correct shift count
	ld	d,a		;save shift count in d
dshfr4:	xor	a		;clear carry
	pop	hl		;get pointer to ho
	dec	d		;are we done?
	ret	z		;yes
dshfra:	push	hl		;no, save pointer to lo, entry from dadd, dmult
	ld	e,10o		;set up a count, rotate fac one left
dshfr5:	ld	a,(hl)		;get a byte of the fac
	rra			;rotate it left
	ld	(hl),a		;put the updated byte back
	dec	hl		;decrement pointer to next lower order byte
	dec	e		;are we done?
	jp	nz,dshfr5	;no, rotate the next lower order byte
	jp	dshfr4		;yes, see if we are done shifting

	;entry to dshftr from dadd, dmult
dshfrb:	ld	hl,fac-1	;get pointer to ho of fac
	ld	d,1		;shift right once
	jp	dshfra		;go do it


	;rotate fac left one
	;alters a,c,h,l
dshflc:	ld	c,10o		;set up a count
dshftl:	ld	a,(hl)		;
	rla			;rotate it left one
	ld	(hl),a		;update byte in fac
	inc	hl		;increment pointer to next higher order byte
	dec	c		;are we done?
	jp	nz,dshftl
	ret			;all done


	;double precision multiplication	fac:=fac*arg
	;alters all registers
dmult:	call	sign		;check if we are multiplying by zero
	ret	z		;yes, all done, the fac is zero
	ld	a,(arg)		;must see if arg is zero
	or	a
	jp	z,zero		;return zero

	call	muldva		;add exponents and take care of signs
	call	dmuldv		;zero fac and put fac in fbuffr
	ld	(hl),c		;put unpacked ho in arg
	inc	de		;get pointer to lo of arg
	ld	b,7		;set up a count
dmult2:	ld	a,(de)		;get the byte of arg to multiply by
	inc	de		;increment pointer to next higher byte
	or	a		;check if we are multiplying by zero
	push	de		;save pointer to arg
	jp	z,dmult5	;we are
	ld	c,10o		;set up a count
dmult3:	push	bc		;save counters
	rra			;rotate multiplier right
	ld	b,a		;save it
	call	c,daddaa	;add in old fac if bit of multipier was one
	call	dshfrb		;rotate product right one
	ld	a,b		;get multiplier in a
	pop	bc		;get counters back
	dec	c		;are we done with this byte of arg?
	jp	nz,dmult3	;no, multiply by the next bit of the multiplier
dmult4:	pop	de		;yes, get pointer into arg back
	dec	b		;are we done?
	jp	nz,dmult2	;no, multiply by next higher order by of arg
				;point is to right of understood one
	jp	dnorml		;all done, normalize and round result
dmult5:	ld	hl,fac-1	;get pointer to ho of fac
	call	dshfrm		;shift product right one byte, we are
	jp	dmult4		; multiplyiing by zero

	;constant for div10, ddiv10
tenth:	defb	315o
	defb	314o
	defb	314o
	defb	314o
	defb	314o
	defb	314o
	defb	114o
	defb	175o
dten:	defb	000		; 10d0
	defb	000
	defb	000
	defb	000
ften:	defb	000		; 10.0
	defb	000
	defb	040o
	defb	204o

	;double precision divide fac by 10
	;alters all registers
ddiv10:	;double precision divide fac by 10
	;(fac)=(fac)*3/4*16/15*1/8
	ld	a,(fac)		;must assure ourselves we can do
	cp	101o		;65 exponent decrements w/o
	jp	nc,dd04		;reaching zero
	ld	de,tenth	;point to .1d0
	ld	hl,arglo	;point to arg
	call	vmove
	jp	dmult
dd04:
	ld	a,(fac-1)	;negative no?
	or	a
	jp	p,dd05
	and	177o		;want only pos. nos.
	ld	(fac-1),a
	ld	hl,rneg
	push	hl		;will negate when finished
dd05:
	call	$decf1		;divide fac by 2
	ld	de,dfaclo
	ld	hl,arglo
	call	vmove
	call	$decf1		;divide fac by 2
	call	dadd		;(fac)=(fac)+(arg)
	ld	de,dfaclo
	ld	hl,arglo
	call	vmove		;(arg)=(fac)
	ld	a,15
dd10:	push	af		;save loop counter
	call	$deca4		;(arg)=(arg)/16
	call	$psarg		;push arg on the stack
	call	dadd		;(fac)=(fac)+(arg)
	ld	hl,arg-1
	call	$pparg		;pop arg off the stack
	pop	af		;fetch loop counter
	dec	a
	jp	nz,dd10
	call	$decf1
	call	$decf1
	call	$decf1
	ret
$decf1:	ld	hl,fac
	dec	(hl)		;(fac)=(fac)/2
	ret	nz
	jp	zero		;underflow
$deca4:	;(arg)=(arg)/16
	ld	hl,arg
	ld	a,4
dc4:	dec	(hl)
	ret	z
	dec	a
	jp	nz,dc4
	ret
$psarg:	;push double precision arg on the stack
	pop	de		;get our return address off the stack
	ld	a,4
	ld	hl,arglo
psa10:	ld	c,(hl)		;fetch byte
	inc	hl
	ld	b,(hl)
	inc	hl
	push	bc
	dec	a		;through?
	jp	nz,psa10
	push	de
	ret
$pparg:	;pop arg off the stack
	pop	de		;get our return address off the stack
	ld	a,4
	ld	hl,arg
ppa10:	pop	bc
	ld	(hl),b
	dec	hl
	ld	(hl),c
	dec	hl
	dec	a
	jp	nz,ppa10
	push	de
	ret
	;double precision division	fac:=fac/arg
	;alters all registers
ddiv:	ld	a,(arg)		;check for division by zero
	or	a		;get the exponent of arg
	jp	z,intdv0
	ld	a,(fac)		;if fac=0 then ans is zero
	or	a
	jp	z,zero
	call	muldvs		;subtract exponents and check signs
	inc	(hl)		;muldiv different for truans=0
	inc	(hl)		;must correct for incorrect exp calc
	jp	z,ovfin4
	call	dmuldv		;zero fac and put fac in fbuffr
	ld	hl,fbuffr+34	;get pointer to the extra ho byte we will use
	ld	(hl),c		;zero it
	ld	b,c		;zero flag to see when we start dividing
ddiv1:
	defb	076o		;"MVI	A", subtract arg from fbuffr
	sbc	a,(hl)		;get subtract instruction
	call	daddd		;do the subtraction
	ld	a,(de)		;subtract from extra ho byte
	sbc	a,c		;here c=0
	ccf			;carry=1 if subtraction was good
	jp	c,ddiv2		;was it ok?
	defb	076o		;"MVI	A"  no, add fbuffr back in
	adc	a,(hl)		;get add instruction
	call	daddd		;do the addition
	xor	a		;clear carry
	defb	332o		;"JC" over next two bytes
ddiv2:	ld	(de),a		;store the new highest order byte
	inc	b		;increment flag to show we could divide
	ld	a,(fac-1)	;check if we are done dividing
	inc	a		;set sign flag without affecting carry
	dec	a
	rra			;put carry in msb for dround
	jp	m,drounb	;we are done, we have 57 bits of accuracy
	rla			;get old carry back where it belongs
	ld	hl,dfaclo	;get pointer to lo of fac
	ld	c,7		;set up a count, shift fac left one
	call	dshftl		;shift in the next bit in the quotient
	ld	hl,fbuffr+27	;get pointer to lo in fbuffr
	call	dshflc		;shift dividend one left
	ld	a,b		;is this the first time and was the
	or	a		; subtraction not good? (b will get
	jp	nz,ddiv1	; changed on the first or second subtraction)
	ld	hl,fac		;yes, subtract one from exponent to correct
	dec	(hl)		; scaling
	jp	nz,ddiv1	;continue dividing if no underflow
	jp	zero		;underflow


	;transfer fac to fbuffr for dmult and ddiv
	;alters a,b,c,d,e,h,l
dmuldv:
	ld	a,c		;put unpacked ho back in arg
	ld	(arg-1),a
	dec	hl		;point to ho of fac
	ld	de,fbuffr+33	;point to end of fbuffr
	ld	bc,7*400o+0	;set up a count
				;to fbuffr
dmldv1:	ld	a,(hl)		;get a byte from fac
	ld	(de),a		;put it in fbuffr
	ld	(hl),c		;put a zero in fac
	dec	de		;point to next byte in fbuffr
	dec	hl		;point to next lower order byte in fac
	dec	b		;are we done?
	jp	nz,dmldv1	;no, transfer the next byte
	ret			;all done



	;double precision multiply the fac by 10
	;alters all registers
dmul10:	call	vmovaf		;save the fac in arg
	;vmovaf exits with (de)=fac+1
	ex	de,hl		;get the pointer into the fac in (hl)
	dec	hl		;point to the exponent
	ld	a,(hl)		;get the exponent
	or	a		;is the number zero?
	ret	z		;yes, all done
	add	a,2		;multiply fac by 4 by adding 2 to the exponent
	jp	c,ovfin4
	ld	(hl),a		;save the new exponent
	push	hl		;save pointer to fac
	call	dadd		;add in the original fac to get 5 times  fac
	pop	hl		;get the pointer to fac back
	inc	(hl)		;add one to exponent to get 10 times fac
	ret	nz		;all done if overflow did not occur
	jp	ovfin4
	;multiply fac by 10
	page
	;subttl	floating point input routine
	;alters all registers
	;the number is left in fac
	;at entry, (hl) points to the first character in a text buffer.
	;the first character is also in a.  we pack the digits into the fac
	;as an integer and keep track of where the decimal point is.
	;c is 377 if we have not seen a decimal point, 0 if we have.
	;b is the number of digits after the decimal point.
	;at the end, b and the exponent (in e) are used to determine how many
	;times we multiply or divide by ten to get the correct number.
	public	findbl
findbl:	call	zero		;zero the fac
	call	valdbl		;force to double precision
	defb	366o		;"ORI" over "XRA A" so frcint is not called
fin:
	xor	a		;force call to frcint
	extrn	finovc
	ld	bc,finovc	;when done store overflow flag
	push	bc		;into strovc and go to normal overflow mode
	push	af		;set up once only overflow mode
	ld	a,1
	ld	(flgovc),a
	pop	af
finchr:	ex	de,hl		;save the text pointer in (de)
	ld	bc,377o+0	;clear flags:  b=decimal place count
	;c="." flag
	ld	h,b		;zero (hl)
	ld	l,b
	call	z,makint	;zero fac, set valtyp to "INTEGER"
	ex	de,hl		;get the text pointer back in (hl) and
	; zeros in (de)
	ld	a,(hl)		;restore char from memory
	cp	'&'
	extrn	octcns
	jp	z,octcns
	;restore [a]
	;if we are called by val or input or read, the signs may not be crunched
	cp	'-'		;see if number is negative
	push	af		;save sign
	jp	z,fin1		;ignore minus sign
	cp	'+'		;ignore a leading sign
	jp	z,fin1
	dec	hl		;set character pointer back one
fin1:
	;here to check for a digit, a decimal point, "E" or "D"
finc:	call	chrgtr		;get the next character of the number
	jp	c,findig	;we have a digit
	cp	'.'		;check for a decimal point
	jp	z,findp		;we have one, i guess
	cp	145o		;lower case "E"
	jp	z,finc1
	cp	'E'		;check for a single precision exponent
finc1:
	jp	nz,note		;no
	push	hl		;save text ptr
	call	chrgtr		;get next char
	cp	'L'+40o		;see if lower case "L"
	jp	z,wuzels	;if so possible else
	cp	'L'		;is this really an "ELSE"?
	jp	z,wuzels	;was else
	cp	'Q'+40o		;see if lower case "Q"
	jp	z,wuzels	;if so possible "EQV"
	cp	'Q'		;possible "EQV"
wuzels:	pop	hl		;restore [h,l]
	jp	z,wuz		;it was jump!
	ld	a,(valtyp)	;if double don'T DOWNGRADE TO SINGLE
	cp	10o		;set condition codes
	jp	z,finex1
	ld	a,0		;make a=0 so number is a single
	jp	finex1
wuz:
	ld	a,(hl)		;restore original char
note:
	cp	'%'		;trailing % (rsts-11 compatibility)
	jp	z,finint	;must be integer.
	cp	'#'		;force double precision?
	jp	z,findbf	;yes, force it & finish up.
	cp	'!'		;force single prec.
	jp	z,finsnf
	cp	144o		;lower case "D"
	jp	z,finex1
	cp	'D'		;check for a double precision exponent
	jp	nz,fine		;we don'T HAVE ONE, THE NUMBER IS FINISHED
finex1:	or	a		;double precision number -- turn off zero flag
finex:	call	finfrc		;force the fac to be sng or dbl
	call	chrgtr		;get the first character of the exponent
	call	minpls		;eat sign of exponent
	;here to get the next digit of the exponent
finec:	call	chrgtr		;get the next charater
	jp	c,finedg	;pack the next digit into the exponent
	inc	d		;it was not a digit, put the correct sign on
	jp	nz,fine		; the exponent, it is positive
	xor	a		;the exponent is negative
	sub	e		;negate it
	ld	e,a		;save it again
	;here to finish up the number
fine:	push	hl		;save the text pointer
	ld	a,e		;find out how many times we have to multiply
	sub	b		; or divide by ten
	ld	e,a		;save new exponent in e
	;here to multiply or divide by ten the correct number of times
	;if the number is an int, a is 0 here.
fine2:	call	p,finmul	;multiply if we have to
	call	m,findiv	;divide if we have to
	jp	nz,fine2	;multiply or divide again if we are not done
	;here to put the correct sign on the number
	pop	hl		;get the text pointer
	pop	af		;get the sign
	push	hl		;save the text pointer again
	call	z,vneg		;negate if necessary
fine2c:	pop	hl		;get the text pointer in (hl)
	call	getypr		;we want -32768 to be an int, but until now
	; it would be a sng
	ret	pe		;it is not sng, so it is not -32768
	push	hl		;we have a sng, save text pointer
	ld	hl,pophrt	;get address that pop'S H OFF STACK BECAUSE
	push	hl		; conis2 does funny things with the stack
	call	conis2		;check if we have -32768
	ret			;we don'T, POPHRT IS STILL ON THE STACK SO
	; we can just return

	;here to check if we have seen 2 decimal points and set the decimal
	; point flag
findp:	call	getypr		;set carry if we don'T HAVE A DOUBLE
	inc	c		;set the flag
	jp	nz,fine		;we had 2 decimal points, now we are done
	call	c,finfrc	;this is the first one, convert fac to sng
	; if we don'T ALREADY HAVE A DOUBLE
	jp	finc		;continue looking for digits

finint:	call	chrgtr
	pop	af		;get sign off the stack
	push	hl		;save text pointer
	ld	hl,pophrt	;address pop (hl) and return
	push	hl		;
	ld	hl,frcint	;address to force integer
	push	hl		;will want to force once d.p. done
	push	af		;put sign back on the stack
	jp	fine		;all done
findbf:	or	a		;set non-zero to force double prec
finsnf:	call	finfrc		;force the type
	call	chrgtr		;read after terminator
	jp	fine		;all done

	;force the fac to be sng or dbl
	;if the zero flag is on, then force the fac to be sng
	;if the zero flag is off, force the fac to be dbl
finfrc:	push	hl		;save text pointer
	push	de		;save exponent information
	push	bc		;save decimal point information
	push	af		;save what we want the fac to be
	call	z,frcsng	;convert to sng if we have to
	pop	af		;get type flag back
	call	nz,frcdbl	;convert to dbl if we have to
	pop	bc		;get decimal point information back
	pop	de		;get exponent information back
	pop	hl		;get text pointer back
	ret			;all done

	;this subroutine muliplies by ten once.
	;it is a subroutine because it saves bytes when we check if a is zero
	;alters all registers
finmul:	ret	z		;return if exponent is zero, entry from fout
finmlt:	push	af		;save exponent, entry from fout
	call	getypr		;see what kind of number we have
	push	af		;save the type
	call	po,mul10	;we have a sng, multiply by 10.0
	pop	af		;get the type back
	call	pe,dmul10	;we have a dbl, multiply by 10d0
	pop	af		;get exponent
dcrart:	dec	a		;decrease it
	ret			;all done

	;this subroutine divides by ten once.
	;it is used by fin, fout
	;alters a,b,c
findiv:	push	de		;save d,e
	push	hl		;save h,l
	push	af		;we have to divide -- save count
	call	getypr		;see what kind of number we have
	push	af		;save the type
	call	po,div10	;we have a sng number
	pop	af		;get the type back
	call	pe,ddiv10	;we have a dbl number
	pop	af		;get count back
	pop	hl		;get h,l back
	pop	de		;get d,e back
	inc	a		;update it
	ret

	;here to pack the next digit of the number into the fac
	;we multiply the fac by ten and add in the next digit
findig:
	push	de		;save exponent information
	ld	a,b		;increment decimal place count if we are
	adc	a,c		; past the decimal point
	ld	b,a
	push	bc		;save decimal point information
	push	hl		;save text pointer
	ld	a,(hl)		;get the digit
	sub	'0'		;convert it to ascii
	push	af		;save the digit
	call	getypr		;see what kind of a number we have
	jp	p,findgv	;we do not have an integer
	;here to pack the next digit of an integer
	ld	hl,(faclo)	;we have an integer, get it in (hl)
	ld	de,3277+0	;see if we will overflow
	call	dcompr		;compar returns with carry on if
	jp	nc,findg2	; (hl) .lt. (de), so the number is too big
	ld	d,h		;copy (hl) into (de)
	ld	e,l
	add	hl,hl		;multiply (hl) by 2
	add	hl,hl		;multiply (hl) by 2, (hl) now is 4*(de)
	add	hl,de		;add in old (hl) to get 5*(de)
	add	hl,hl		;multiply by 2 to get ten times the old (hl)
	pop	af		;get the digit
	ld	c,a		;save it so we can use dad, b is already zero
	add	hl,bc		;add in the next digit
	ld	a,h		;check for overflow
	or	a		;overflow occured if the msb is on
	jp	m,findg1	;we have overflow!!
	ld	(faclo),hl	;everything is fine, store the new number
findge:	pop	hl		;all done, get text pointer back
	pop	bc		;get decimal point information back
	pop	de		;get exponent information back
	jp	finc		;get the next character
	;here to handle 32768, 32769
findg1:	ld	a,c		;get the digit
	push	af		;put it back on the stack
	;here to convert the integer digits to single precision digits
findg2:	call	consi		;convert the integer to single precision
	scf			;do not take the following jump
	;here to decide if we have a single or double precision number
findgv:	jp	nc,findgd	;fall through if valtyp was 4 i.e. sng prec
	ld	bc,224q*256+164q
	ld	de,044q*256+000q;get 1000000, do we have 7 digits already?
	call	fcomp		;if so, fac .ge. 1000000
	jp	p,findg3	;we do, convert to double precision
	call	mul10		;multiply the old number by ten
	pop	af		;get the next digit
	call	finlog		;pack it into the fac
	jp	findge		;get flags off stack and we are done
	;here to convert a 7 digit single precision number to double precision
findg3:	call	conds		;convert single to double precision
	;here to pack in the next digit of a double precision number
findgd:	call	dmul10		;multiply the fac by 10
	call	vmovaf		;save the fac in arg
	pop	af		;get the next digit
	call	float		;convert the digit to single precision
	call	conds		;now, convert the digit to double precision
	call	dadd		;add in the digit
	jp	findge		;get the flags off the stack and we are done

	;subroutine for fin, log
finlog:	call	pushf		;save fac on stack
	call	float		;convert a to a floating point number
faddt:	pop	bc
	pop	de
	;get previous number off stack
	jp	fadd		;add it in

	;here we pack in the next digit of the exponent
	;we mutiply the old exponent by ten and add in the next digit
	;note: exponent overflow is not checked for
finedg:	ld	a,e		;exponent digit -- multiply exponent by 10
	cp	12o		;check that the exponent does not overflow
	;if it did, e could get garbage in it.
	jp	nc,finedo	;we already have two digits
	rlca			;first by 4
	rlca
	add	a,e		;add 1 to make 5
	rlca			;now double to get 10
	add	a,(hl)		;add it in
	sub	'0'		;subtract off ascii code, the result is
	; positive on length=2 because of the
	; above check
	ld	e,a		;store exponent
	defb	372o		;"JM" over the next 2 bytes
finedo:	ld	e,127		;an exponent like this will safely cause
	; overflow or underflow
	jp	finec		;continue
ovfin1:	or	a		;clear carry
	jp	ovfint		;go print overflow
ovfin9:	pop	af		;get stack right
ovfin2:	push	hl		;
	ld	hl,fac-1	;point (hl) to sign byte
	call	getypr
	jp	po,ovf2a	;sp proceed as normal
	ld	a,(arg-1)
	jp	ovf2b
ovf2a:
	ld	a,c
ovf2b:
	xor	(hl)		;sign in high bit of (a)
	rla			;sign in carry
	pop	hl		;
	jp	ovfint
ovf2c:	ld	a,(fac+1)	;this entry is used by consd
	jp	ovfi4b		;when d.p. exp too large for s.p.
ovfin5:	pop	af		;need to do 3 pop'S THEN OVERFLOW
ovfin6:	pop	af
ovfin7:	pop	af
ovfin3:	ld	a,(fac-1)
	rla
	jp	ovfint
ovfin8:	pop	af		;do a pop then fall into ovfin4
ovfin4:	ld	a,(fac+1)	;get sign byte
	cpl			;sign was stored complemented
ovfi4b:	rla			;sign to carry
	jp	ovfint
intdv1:	ld	a,c
	jp	intdv2		;
intdv0:	push	hl		;get arg sign byte
	push	de		;
	ld	hl,dfaclo
	ld	de,infm		;all one'S
	call	move
	ld	a,(infm)	;377
	ld	(dfaclo+2),a	;(previously 177)
	call	getypr
	jp	po,indv0a	;not d.p. load arg sign
	ld	a,(fac-1)
	jp	indv0b
indv0a:
	ld	a,(arg-1)
indv0b:	pop	de
	pop	hl
intdv2:	rla			;to carry
	ld	hl,divmsg	;get message address
	ld	(overri),hl	;store so ovfint will pick up
ovfint:	;ansi overflow routine
	push	hl
	push	bc
	push	de
	push	af		;save machine status
	push	af		;again
	extrn	onelin		;
	ld	hl,(onelin)	;trapping errors?
	ld	a,h
	or	l
	jp	nz,ovfprt	;jump print if trapping
	;otherwise +infinity
	ld	a,(flgovc)	;print indicator flag
	or	a		;print if 0,1;set to 2 if 1
	jp	z,ov1a		;go print
	cp	1
	jp	nz,ov1b
	ld	a,2
	ld	(flgovc),a
ov1a:
	ld	hl,(overri)	;address of overflow message
	call	strprn		;print
	ld	(ttypos),a	;set tty position to char 0
	;set tty position to char 0
	ld	a,15o
	call	caltty
	ld	a,12o
	call	caltty		;carriage return,line feed
ov1b:
ovfprt:	pop	af		;get plus,minus indication back
	ld	hl,faclo	;must now put right infinity
	;into the fac
	ld	de,infp
	jp	nc,ovfina
	ld	de,infm		;minus infinity
ovfina:	call	move		;move into fac
	call	getypr
	jp	po,ovfinb	;sp all ok
	ld	hl,dfaclo
	ld	de,infm		;all ones
	call	move
ovfinb:
	ld	hl,(onelin)	;trapping errors?
	ld	a,h
	or	l
	jp	z,noodtp	;jump if not trapping
	ld	hl,(overri)
	ld	de,ovrmsg
	call	dcompr
	ld	hl,ovrmsg
	ld	(overri),hl
	jp	z,overr
	jp	dv0err
noodtp:
	pop	af		;
	ld	hl,ovrmsg	;put "OVRMSG" address in overri
	ld	(overri),hl	;in case this was a div by 0
	pop	de
	pop	bc
	pop	hl		;all restored
	ret			;continue processing
infp:	defb	377o
	defb	377o
	defb	177o
	defb	377o
infm:	defb	377o
	defb	377o
	defb	377o
	defb	377o



	page
	;subttl	floating point output routine
	;entry to linprt
inprt:	push	hl		;save line number
	ld	hl,intxt	;print message
	call	strout
	pop	hl		;fall into linprt


	;print the 2 byte number in h,l
	;alters all registers
linprt:
	ld	bc,stroui
	push	bc
	public	linout
linout:	call	makint		;put the line number in the fac as an integer
	xor	a		;set format to free format
	call	fouini		;set up the sign
	or	(hl)		;turn off the zero flag
	jp	fout2		;convert the number into digits
	extrn	stroui

	;floating output of fac
	;alters all registers
	;the original contents of the fac is lost
;
;	output the value in the fac according to the format specifications
;	in a,b,c
;	all registers are altered
;	the original contents of the fac is lost
;
;	the format is specified in a, b and c as follows:
;	the bits of a mean the following:
;bit 7	0 means free format output, i.e. the other bits of a must be zero,
;	trailing zeros are suppressed, a number is printed in fixed or floating
;	point notation according to its magnitude, the number is left
;	justified in its field, b and c are ignored.
;	1 means fixed format output, i.e. the other bits of a are checked for
;	formatting information, the number is right justified in its field,
;	trailing zeros are not suppressed.  this is used for print using.
;bit 6	1 means group the digits in the integer part of the number into groups
;	of three and separate the groups by commas
;	0 means don'T PRINT THE NUMBER WITH COMMAS
;bit 5	1 means fill the leading spaces in the field with asterisks ("*")
;bit 4	1 means output the number with a floating dollar sign ("$")
;bit 3	1 means print the sign of a positive number as a plus sign ("+")
;	instead of a space
;bit 2	1 means print the sign of the number after the number
;bit 1	unused
;bit 0	1 means print the number in floating point notation i.e. "E NOTATION"
;	if this bit is on, the comma specification (bit 6) is ignored.
;	0 means print the number in fixed point notation.  numbers .ge. 1e16
;	cannot be printed in fixed point notation.
;
;	b and c tell how big the field is:
;b   =	the number of places in the field to the left of the decimal point
;	(b does not include the decimal point)
;c   =	the number of places in the field to the right of the decimal point
;	(c includes the decimal point)
;	b and c do not include the 4 positions for the exponent if bit 0 is on
;	fout assumes b+c .le. 24 (decimal)
;	if the number is too big to fit in the field, a percent sign ("%") is
;	printed and the field is extended to hold the number.
;&


	;entry to print the fac in free format
fout:	xor	a		;set format flags to free formated output
	;entry to print the fac using the format specifications in a, b and c
pufout:	call	fouini		;save the format specification in a and put
	;a space for positive numbers in the buffer
	and	10o		;check if positive numbers get a plus sign
	jp	z,fout1		;they don'T
	ld	(hl),'+'	;they do, put in a plus sign
fout1:	ex	de,hl		;save buffer pointer
	call	vsign		;get the sign of the fac
	ex	de,hl		;put the buffer pointer back in (hl)
	jp	p,fout2		;if we have a negative number, negate it
	ld	(hl),'-'	; and put a minus sign in the buffer
	push	bc		;save the field length specification
	push	hl		;save the buffer pointer
	call	vneg		;negate the number
	pop	hl		;get the buffer pointer back
	pop	bc		;get the field length specifications back
	or	h		;turn off the zero flag, this depends on the
				; fact that fbuffr is never on page 0.
fout2:	inc	hl		;point to where the next character goes
	ld	(hl),'0'	;put a zero in the buffer in case the number
	; is zero (in free format) or to reserve space
	; for a floating dollar sign (fixed format)
	ld	a,(temp3)	;get the format specification
	ld	d,a		;save it for later
	rla			;put the free format or not bit in the carry
	ld	a,(valtyp)	;get the valtyp, vneg could have changed this
				; since -32768 is int and 32768 is sng.
	jp	c,foutfx	;the man wants fixed formated output
	;here to print numbers in free format
	jp	z,foutzr	;if the number is zero, finish it up
	cp	4		;decide what kind of a value we have
	jp	nc,foufrv	;we have a sng or dbl
	;here to print an integer in free format
	ld	bc,0		;set the decimal point count and comma count
	; to zero
	call	foutci		;convert the integer to decimal
	;fall into foutzs and zero suppress the thing


	;zero suppress the digits in fbuffr
	;asterisk fill and zero suppress if necessary
	;set up b and condition codes if we have a trailing sign
foutzs:	ld	hl,fbuffr+1	;get pointer to the sign
	ld	b,(hl)		;save the sign in b
	ld	c,' '		;default fill character to a space
	ld	a,(temp3)	;get format specs to see if we have to
	ld	e,a		; asterisk fill.  save it
	and	40o
	jp	z,fotzs1	;we don'T
	ld	a,b		;we do, see if the sign was a space
	cp	c		;zero flag is set if it was
	ld	c,'*'		;set fill character to an asterisk
	jp	nz,fotzs1	;set the sign to an asterisk if it was a space
	ld	a,e		;get format specs again
	and	4		;see if sign is trailing
	jp	nz,fotzs1	;if so don'T ASTERISK FILL
	ld	b,c		;b has the sign, c the fill character
fotzs1:	ld	(hl),c		;fill in the zero or the sign
	call	chrgtr		;get the next character in the buffer
	;since there are no spaces, "CHRGET" is
	; equivalent to "INX	H"/"MOV	A,M"
	jp	z,fotzs4	;if we see a real zero, it is the end of
	; the number, and we must back up and put
	; in a zero.  chrget sets the zero flag on
	; real zeros or colons, but we won'T SEE
	; any colons in this buffer.
	cp	'E'		;back up and put in a zero if we see
	jp	z,fotzs4	;an "E" or a "D" so we can print 0 in
	cp	'D'		;floating point notation with the c format zero
	jp	z,fotzs4
	cp	'0'		;do we have a zero?
	jp	z,fotzs1	;yes, suppress it
	cp	54o		;54=","  do we have a comma?
	jp	z,fotzs1	;yes, suppress it
	cp	'.'		;are we at the decimal point?
	jp	nz,fotzs2	;no, i guess not
fotzs4:	dec	hl		;yes, back up and put a zero before it
	ld	(hl),'0'
fotzs2:	ld	a,e		;get the format specs to check for a floating
	and	20o		; dollar sign
	jp	z,fotzs3	;we don'T HAVE ONE
	dec	hl		;we have one, back up and put in the dollar
	ld	(hl),curncy	; sign
fotzs3:	ld	a,e		;do we have a trailing sign?
	and	4
	ret	nz		;yes, return; note the non-zero flag is set
	dec	hl		;no, back up one and put the sign back in
	ld	(hl),b		;put in the sign
	ret			;all done


	;here to initially set up the format specs and put in a space for the
	;sign of a positive number
fouini:	ld	(temp3),a	;save the format specification
	ld	hl,fbuffr+1	;get a pointer into fbuffr
	;we start at fbuffr+1 in case the number will
	; overflow its field, then there is room in
	; fbuffr for the percent sign.
	ld	(hl),' '	;put in a space
	ret			;all done


	;here to print a sng or dbl in free format
foufrv:
	;the following code down to foufrf: is added to address the
	;ansi standard of printing numbers in fixed format rather than
	;scientific notation if they can be as accurately rpresented
	;in fixed format

	call	pushf		;save in case needed for 2ed pass
	ex	de,hl		;save buffer pointer in (hl)
	ld	hl,(dfaclo)
	push	hl		;save for d.p.
	ld	hl,(dfaclo+2)	;
	push	hl		;
	ex	de,hl		;buffer pointer back to (hl)
	push	af		;save in case needed for second pass
	xor	a		;(a)=0
	ld	(fansii),a	;initialize fansii flag
	pop	af		;get psw right
	push	af		;save psw
	call	foufrf		;format number
	ld	b,'E'		;will search for scientific notn.
	ld	c,0		;digit counter
fu1:	;get original fbuffer pointer
	push	hl		;save in case we need to look for "D"
	ld	a,(hl)		;fetch up first character
fu2:	cp	b		;scientific notation?
	jp	z,fu4		;if so, jump
	cp	72o		;if carry not set not a digit
	jp	nc,fu2a
	cp	60o		;if carry set not a digit
	jp	c,fu2a
	inc	c		;incremented digits to print
fu2a:	inc	hl		;point to next buffer character
	ld	a,(hl)		;fetch next character
	or	a		;0(binary) at the end of characters
	jp	nz,fu2		;continue search if not at end
	ld	a,'D'		;now to check to see if searched for d
	cp	b
	ld	b,a		;in case not yet searched for
	pop	hl		;now to check for "D"
	ld	c,0		;zero digit count
	jp	nz,fu1		;go search for "D" if not done so
fu3:	pop	af		;pop	original psw
	pop	bc
	pop	de
	;get dfaclo-dfaclo+3
	ex	de,hl		;(de)=buf ptr,(hl)=dfaclo
	ld	(dfaclo),hl	;
	ld	h,b
	ld	l,c
	ld	(dfaclo+2),hl
	ex	de,hl
	pop	bc
	pop	de
	;get orig fac off stack
	ret			;complete
fu4:	;print is in scientific notation , is this best?
	push	bc		;save type,digit count
	ld	b,0		;exponent value (in binary)
	inc	hl		;point to next character of exp.
	ld	a,(hl)		;fetch next character of exponent
fu5:	cp	'+'		;is exponent positive?
	jp	z,fu8		;if so no better printout
	cp	'-'		;must be negative!
	jp	z,fu5a		;must process the digits
	sub	'0'		;subtract out ascii bias
	ld	c,a		;digit to c
	ld	a,b		;fetch old digit
	add	a,a		;*2
	add	a,a		;*4
	add	a,b		;*5
	add	a,a		;*10
	add	a,c		;add in new digit
	ld	b,a		;back out to exponent accumulator
	cp	20o		;16 d.p. digits for microsoft format
	jp	nc,fu8		;if so stop trying
fu5a:	inc	hl		;point to next character
	ld	a,(hl)		;fetch up
	or	a		;binary zero at end
	jp	nz,fu5		;continue if not at end
	ld	h,b		;save exponent
	pop	bc		;fetch type, digit count
	ld	a,b		;determine type
	cp	'E'		;single precision?
	jp	nz,fu7		;no -go process as double precision
	ld	a,c		;digit count
	add	a,h		;add exponent value
	cp	11o
	pop	hl		;pop	old buffer pointer
	jp	nc,fu3		;can'T DO BETTER
fu6:	ld	a,200o		;
	ld	(fansii),a	;
	jp	fu9		;do fixed point printout
fu7:	ld	a,h		;save exponent
	add	a,c		;total digits necessary
	cp	22o		;must produce carry to use fixed point
	pop	hl		;get stack right
	jp	nc,fu3
	jp	fu6		;go  rint in fixed point
fu8:	pop	bc		;
	pop	hl		;get original buffer ptr back
	jp	fu3		;
fu9:	pop	af		;get original psw off stack
	pop	bc
	pop	de
	;get dfaclo-dfaclo+3
	ex	de,hl		;(de)=buffer ptr,(hl)=dfaclo
	ld	(dfaclo),hl	;
	ld	h,b
	ld	l,c
	ld	(dfaclo+2),hl
	ex	de,hl
	pop	bc
	pop	de
	;get original fac back
	call	movfr		;move to fac
	inc	hl		;because when we originally entered
	;foufrv the (hl) pointed to a char.
	;past the sign and the pass through
	;this code leaves (hl) pointing to
	;the sign. (hl) must point past sign!
foufrf:	;
	cp	5		;set cc'S FOR Z80
	push	hl		;save the buffer pointer
	sbc	a,0		;map 4 to 6 and 10 to 20
	rla			;this calculates how many digits we will
	ld	d,a		; print
	inc	d
	call	foutnv		;normalize the fac so all significant digits
	; are in the integer part
	ld	bc,3*400o+0	;b = decimal point count
	;c = comma count
	;set comma count to zero and decimal point
	; count for e notation

	push	af		;save for normal case
	ld	a,(fansii)	;see if forced fixed output
	or	a		;set condition codes correctly
	jp	p,fofv5a	;do normal thing
	pop	af		;
	add	a,d
	jp	foufv6		;fixed output
fofv5a:	pop	af		;normal route
	add	a,d		;see if number should be printed in e notation
	jp	m,fofrs1	;it should, it is .lt. .01
	inc	d		;check if it is too big
	cp	d
	jp	nc,fofrs1	;it is too big, it is .gt. 10^d-1
foufv6:	inc	a		;it is ok for fixed point notation
	ld	b,a		;set decimal point count
	ld	a,2		;set fixed point flag, the exponent is zero
	; if we are using fixed point notation
fofrs1:	sub	2		;e notation: add d-2 to original exponent
	;restore exp if not d.p.
	pop	hl		;get the buffer pointer back
	push	af		;save the exponent for later
	call	foutan		;.01 .le. number .lt. .1?
	ld	(hl),'0'	;yes, put ".0" in buffer
	call	z,inxhrt
	call	foutcv		;convert the number to decimal digits
	;here to suppress the trailing zeros
fofrs2:	dec	hl		;move back to the last character
	ld	a,(hl)		;get it and see if it was zero
	cp	'0'
	jp	z,fofrs2	;it was, continue suppressing
	cp	'.'		;have we suppressed all the fractional digits?
	call	nz,inxhrt	;yes, ignore the decimal point also
	pop	af		;get the exponent back
	jp	z,foutdn	;we are done if we are in fixed point notation
	;fall in and put the exponent in the buffer


	;here to put the exponent and "E" or "D" in the buffer
	;the exponent is in a, the condition codes are assumed to be set
	;correctly.
fofldn:	push	af		;save the exponent
	call	getypr		;set carry for single precision
	ld	a,42o		;[a]="D"/2
	adc	a,a		;multiply by 2 and add carry
	ld	(hl),a		;save it in the buffer
	inc	hl		;increment the buffer pointer
	;put in the sign of the exponent
	pop	af		;get the exponent back
	ld	(hl),'+'	;a plus if positive
	jp	p,fouce1
	ld	(hl),'-'	;a minus if negative
	cpl			;negate exponent
	inc	a
	;calculate the two digit exponent
fouce1:	ld	b,'0'-1		;initialize ten'S DIGIT COUNT
fouce2:	inc	b		;increment digit
	sub	12o		;subtract ten
	jp	nc,fouce2	;do it again if result was positive
	add	a,'0'+12o	;add back in ten and convert to ascii
	;put the exponent in the buffer
	inc	hl
	ld	(hl),b		;put ten'S DIGIT OF EXPONENT IN BUFFER
	inc	hl		;when we jump to here, a is zero
	ld	(hl),a		;put one'S DIGIT IN BUFFER
foutzr:	inc	hl		;increment pointer, here to finish up
	; printing a free format zero
foutdn:	ld	(hl),0		;put a zero at the end of the number
	ex	de,hl		;save the pointer to the end of the number
	; in (de) for ffxflv
	ld	hl,fbuffr+1	;get a pointer to the beginning
	ret			;all done




	;here to print a number in fixed format
foutfx:	inc	hl		;move past the zero for the dollar sign
	push	bc		;save the field length specifications
	cp	4		;check what kind of value we have
	ld	a,d		;get the format specs
	jp	nc,foufxv	;we have a sng or a dbl
	;here to print an integer in fixed format
	rra			;check if we have to print it in floating
	jp	c,ffxifl	; point notation
	;here to print an integer in fixed format-fixed point notation
	ld	bc,6*400o+3+0	;set decimal point count to 6 and
	; comma count to 3
	call	fouicc		;check if we don'T HAVE TO USE THE COMMAS
	pop	de		;get the field lengths
	ld	a,d		;see if we have to print extra spaces because
	sub	5		; the field is too big
	call	p,fotzer	;we do, put in zeros, they will later be
	; converted to spaces or asterisks by foutzs
	call	foutci		;convert the number to decimal digits
fouttd:	ld	a,e		;do we need a decimal point?
	or	a
	call	z,dcxhrt	;we don'T, BACKSPACE OVER IT.
	dec	a		;get how many trailing zeros to print
	call	p,fotzer	;print them
	;if we do have decimal places, fill them up
	; with zeros
	;fall in and finish up the number


	;here to finish up a fixed format number
foutts:	push	hl		;save buffer pointer
	call	foutzs		;zero suppress the number
	pop	hl		;get the buffer pointer back
	jp	z,ffxix1	;check if we have a trailing sign
	ld	(hl),b		;we do, put the sign in the buffer
	inc	hl		;increment the buffer pointer
ffxix1:	ld	(hl),0		;put a zero at the end of the number


	;here to check if a fixed format-fixed point number overflowed its
	;field length
	;d = the b in the format specification
	;this assumes the location of the decimal point is in temp2
	ld	hl,fbuffr	;get a pointer to the beginning
foube1:	inc	hl		;increment pointer to the next character
foube5:	ld	a,(temp2)	;get the location of the decimal point
	;since fbuffr is only 35 (decimal) long, we
	; only have to look at the low order to see
	; if the field is big enough
	sub	l		;figure out how much space we are taking
	sub	d		;is this the right amount of space to take?
	ret	z		;yes, we are done, return from fout
	ld	a,(hl)		;no, we must have too much since we started
	; checking from the beginning of the buffer
	; and the field must be small enough to fit in
	; the buffer.  get the next character in
	; the buffer.
	cp	' '		;if it is a space or an asterisk, we can
	jp	z,foube1	; ignore it and make the field shorter with
	cp	'*'		; no ill effects
	jp	z,foube1
	dec	hl		;move the pointer back one to read the
	; character with chrget
	push	hl		;save the pointer

	;here we see if we can ignore the leading zero before a decimal point.
	;this occurs if we see the following: (in order)
	;	+,-	a sign (either "-" or "+")	[optional]
	;	$	a dollar sign			[optional]
	;	0	a zero				[mandatory]
	;	.	a decimal point			[mandatory]
	;	0-9	another digit			[mandatory]
	;if you see a leading zero, it must be the one before a decimal point
	;or else foutzs would have suppressed it, so we can just "INX	H"
	;over the character following the zero, and not check for the
	;decimal point explicitly.
foube2:	push	af		;put the last character on the stack.  the
	; zero flag is set.  the first time the zero
	; zero flag is not set.
	ld	bc,foube2	;get address we go to if we see a character
	push	bc		; we are looking for
	call	chrgtr		;get the next character
	cp	'-'		;save it and get the next character if it is
	ret	z		; a minus sign, a plus sign or a dollar sign
	cp	'+'
	ret	z
	cp	curncy
	ret	z
	pop	bc		;it isn'T, GET THE ADDRESS OFF THE STACK
	cp	'0'		;is it a zero?
	jp	nz,foube4	;no, we can not get rid of another character
	inc	hl		;skip over the decimal point
	call	chrgtr		;get the next character
	jp	nc,foube4	;it is not a digit, we can'T SHORTEN THE FIELD
	dec	hl		;we can!!!  point to the decimal point
	defb	001		;"LXI	B" over the next 2 bytes
foube3:	dec	hl		;point back one character
	ld	(hl),a		;put the character back

	;if we can get rid of the zero, we put the characters on the stack
	;back into the buffer one position in front of where they originally
	;were.  note that the maximum number of stack levels this uses is
	;three -- one for the last entry flag, one for a possible sign,
	;and one for a possible dollar sign.  we don'T HAVE TO WORRY ABOUT
	;the first character being in the buffer twice because the pointer
	;when fout exits will be pointing to the second occurance.
	pop	af		;get the character off the stack
	jp	z,foube3	;put it back in the buffer if it is not the
	; last one
	pop	bc		;get the buffer pointer off the stack
	jp	foube5		;see if the field is now small enough
	;here if the number is too big for the field
foube4:	pop	af		;get the characters off the stack
	jp	z,foube4	;leave the number in the buffer alone
	pop	hl		;get the pointer to the beginning of the
	; number minus 1
	ld	(hl),'%'	;put in a percent sign to indicate the number
	; was too large for the field
	ret			;all done -- return from fout


	;here to print a sng or dbl in fixed format
foufxv:	push	hl		;save the buffer pointer
	rra			;get fixed or floating notation flag in carry
	jp	c,ffxflv	;print the number in e-notation
	jp	z,ffxsfx	;we have a sng
	;here to print a dbl in fixed format--fixed point notation
	ld	de,ffxdxm	;get pointer to 1d16
	call	dcompd		;we can'T PRINT A NUMBER .GE. 10^16 IN FIXED
	; point notation
	ld	d,20o		;set d = number of digits to print for a dbl
	jp	m,ffxsdc	;if the fac was small enough, go print it
	;here to print in free format with a percent sign a number .ge. 10^16
ffxsdo:	pop	hl		;get the buffer pointer off the stack
	pop	bc		;get the field specification off the stack
	call	fout		;print the number in free format
	dec	hl		;point to in front of the number
	ld	(hl),'%'	;put in the percent sign
	ret			;all done--return from fout

	;here to print a sng in fixed format--fixed point notation
ffxsfx:	ld	bc,266q*256+016q
	ld	de,033q*256+312q;get 1e16, check if the number is too big
	call	fcomp
	jp	p,ffxsdo	;it is, print it in free format with a % sign
	ld	d,6		;d = number of digits to print in a sng

	;here to actually print a sng or dbl in fixed format
ffxsdc:	call	sign		;see if we have zero
	call	nz,foutnv	;if not, normalize the number so all digits to
	; be printed are in the integer part
	pop	hl		;get the buffer pointer
	pop	bc		;get the field length specs
	jp	m,ffxxvs	;do different stuff if exponent is negative
	;here to print a number with no fractional digits
ffxsd2:	push	bc		;save the field length specs again
	ld	e,a		;save the exponent in e
	ld	a,b		;we have to print leading zeros if the field
	sub	d		; has more characters than there are digits
	sub	e		; in the number.
	;if we are using commas, a may be too big.
	;this doesn'T MATTER BECAUSE FOUTTS WILL FIND
	; the correct beginning.  there is room in
	; fbuffr because the maximum value b can be is
	; 24 (decimal) so d+c .le. 16 (decimal)  since
	; fac .lt. 10^16.
	;so we need 8 more bytes for zeros.  4 come
	; since we will not need to print an exponent.
	; fbuffr also contains an extra 4 bytes for
	; this case.
	;(it would take more than 4 bytes to check for
	; this.)
	call	p,fotzer	;foutzs will later suppress them
	call	foutcd		;setup decimal point and comma count
	call	foutcv		;convert the number to decimal digits
	or	e		;put in digits after the number if it
	; is big enough, here a=0
	call	nz,fotzec	;there can be commas in these zeros
	or	e		;make sure we get a decimal point for foutts
	call	nz,fouted
	pop	de		;get the field length specs
	jp	fouttd		;go check the size, zero suppress, etc. and
	; finish the number

	;here to print a sng or dbl that has fractional digits
ffxxvs:	ld	e,a		;save the exponent
	ld	a,c		;divide by ten the right number of times so
	or	a		; the result will be rounded correctly and
	call	nz,dcrart	; have the correct number of significant
	add	a,e		; digits
ffxxs2:	jp	m,ffxxv8	;for later calculations, we want a zero if the
	xor	a		; result was not negative
ffxxv8:	push	bc		;save the field specs
	push	af		;save this number for later
ffxxv2:	call	m,findiv	;this is the divide loop
	jp	m,ffxxv2
	pop	bc		;get the number we saved back in b
	ld	a,e		;we have two cases depending on whether the
	sub	b		; the number has integer digits or not
	pop	bc		;get the filed specs back
	ld	e,a		;save how many decimal places before the
	add	a,d		; the number ends
ffxxs4:	ld	a,b		;get the "B" field spec
	jp	m,ffxxv3
	;here to print numbers with integer digits
	sub	d		;print some leading zeros if the field is
	sub	e		; bigger than the number of digits we will
ffxxs6:	call	p,fotzer	; print
	push	bc		;save field spec
	call	foutcd		;set up decimal point and comma count
	jp	ffxxv6		;convert the digits and do the trimming up

	;here to print a number without integer digits
ffxxv3:	call	fotzer		;put all zeros before the decimal point
	ld	a,c		;save c
	call	foutdp		;put in a decimal point
	ld	c,a		;restore c
	xor	a		;decide how many zeros to print between the
	sub	d		; decimal point and the first digit we will
	sub	e		; print.
	call	fotzer		;print the zeros
	push	bc		;save exponent and the "C" in the field spec
	ld	b,a		;zero the decimal place count
	ld	c,a		;zero the comma count
ffxxv6:	call	foutcv		;convert the number to decimal digits
	pop	bc		;get the field specs back
	or	c		;check if we have to print any zeros after
	; the last digit
	jp	nz,ffxxv7	;check if there were any decimal places at all
	;e can never be 200, (it is negative) so if
	; a=0 here, there is no way we will call fotzer
	ld	hl,(temp2)	;the end of the number is where the dp is
ffxxv7:	add	a,e		;print some more trailing zeros
	dec	a
	call	p,fotzer
	ld	d,b		;get the "B" field spec in d for foutts
	jp	foutts		;finish up the number


	;here to print an integer in fixed format--floating point notation
ffxifl:	push	hl		;save the buffer pointer
	push	de		;save the format specs
	call	consi		;convert the integer to a sng
	pop	de		;get the format specs back
	xor	a		;set flags to print the number as a sng
	;fall into ffxflv


	;here to print a sng or dbl in fixed format-flotating point notation
ffxflv:	jp	z,ffxsfl	;if we have a sng, set the right flags
	ld	e,20o		;we have a dbl, get how many digits we have
	defb	001		;"LXI	B" over the next two bytes
ffxsfl:	ld	e,6		;we have a sng, get how many digits we print
	call	sign		;see if we have zero
ffxs03:	scf			;set carry to determine if we are printing
	;zero. note: this depends on the fact that
	;foutnv exits with carry off
	call	nz,foutnv	;if not, normalize the number so all digits to
	; be printed are in the integer part
	pop	hl		;get the buffer pointer back
	pop	bc		;get the field length specs
	push	af		;save the exponent
	ld	a,c		;calculate how many significant digits we must
	or	a		; print
	push	af		;save the "C" field spec for later
	call	nz,dcrart
	add	a,b
	ld	c,a
	ld	a,d		;get the "A" field spec
	and	4		;see if the sign is a trailing sign
	cp	1		;set carry if a is zero
	sbc	a,a		;set d=0 if we have a trailing sign,
	ld	d,a		; d=377 if we do not
	add	a,c
	ld	c,a		;set c=number of significant digits to print
	sub	e		;if we have less than e, then we must get rid
	push	af		;save comparison # of sig digits and the
	;# of digits we will print
	push	bc		;save the "B" field spec and # of sig digits
ffxlv1:	call	m,findiv	; of some by dividing by ten and rounding
	jp	m,ffxlv1
	pop	bc		;get "B" field spec and # of sig digits back
	pop	af		;get # of trailing zeros to print
	push	bc		;save the "B" field spec and # of sig digits
	push	af		;save # of trailing zeros to print
	jp	m,ffxlv3	;take into account digits that were
	xor	a		;divided off at ffxlv1
ffxlv3:	cpl
	inc	a
	add	a,b		;set the decimal place count
	inc	a
	add	a,d		;take into account if the sign is trailing
	ld	b,a		; or not
	ld	c,0		;set comma count to zero, the comma spec is
	; ignored.
	call	foutcv		;convert the number to decimal digits
	pop	af		;get number trailing zeros to print
	;if the field length is longer than the # of digits
	;we can print
	call	p,fotznc	;the decimal point could come out in here
	call	fouted		;in case d.p. is last on list
	pop	bc		;get # of sig digits and "B" field spac back
	pop	af		;get the "C" field spec back
	jp	nz,ffxlv4	;if non-zero proceed
	call	dcxhrt		;see if d.p. there
	ld	a,(hl)		;fetch to make sure d.p.
	cp	'.'		;if not must be zero
	call	nz,inxhrt	;if not must leave as is
	ld	(temp2),hl	;need d.p. location in temp2
ffxlv4:	; so ignore it.
	pop	af		;get the exponent back
	jp	c,ffxlv2	;exponent=0 if the number is zero
	add	a,e		;scale it correctly
	sub	b
	sub	d
ffxlv2:	push	bc		;save the "B" field spec
	call	fofldn		;put the exponent in the buffer
	ex	de,hl		;get the pointer to the end in (hl)
	; in case we have a trailing sign
	pop	de		;get the "B" field spec in d, put on a
	jp	foutts		; possible trailing sign and we are done


	;normalize the number in the fac so all the digits are in the integer
	;part.  return the base 10 exponent in a
	;d,e are left unaltered
foutnv:	push	de		;save (de)
	xor	a		;zero the exponent
	push	af		;save it
	call	getypr		;get type of number to be printed
	jp	po,foundb	;not double, do normal thing
forbig:	ld	a,(fac)		;get exponent
	cp	221o		;is it .lt.1d5?
	jp	nc,foundb	;no, dont multply
	ld	de,tenten	;multiply by 1d10
	ld	hl,arglo	;move into arg
	call	vmove		;put in arg
	call	dmult		;multiply by it
	pop	af		;get orig exponent off stack
	sub	10		;get proper offset for exponent
	push	af		;save exponent back
	jp	forbig		;force it bigger if possible
foundb:	call	founvc		;is the fac too big or too small?
founv1:	call	getypr		;see what kind of value we have so we
	; can see if the fac is big enough
	jp	pe,founv4	;we have a dbl
	ld	bc,221q*256+103q
	ld	de,117q*256+371q;get 99999.95 to see if the fac is big
	call	fcomp		; enough yet
	jp	founv5		;go do the check
founv4:	ld	de,foutdl	;get pointer to 999,999,999,999,999.5
	call	dcompd		;see if the number is still too small
founv5:	jp	p,founv3	;it isn'T ANY MORE, WE ARE DONE
	pop	af		;it is, multiply by ten
	call	finmlt
	push	af		;save the exponent again
	jp	founv1		;now see if it is big enough
founv2:	pop	af		;the fac is too big, get the exponent
	call	findiv		;divide it by ten
	push	af		;save the exponent again
	call	founvc		;see if the fac is small enough
founv3:	pop	af		;we are done, get the exponent back
	or	a		;clear carry
	pop	de		;get (de) back
	ret			;all done

	;here to see if the fac is small enough yet
founvc:	call	getypr		;see what type number we have
	jp	pe,fonvc1	;we have a dbl
	ld	bc,224q*256+164q
	ld	de,043q*256+370q;get 999999.5 to see if the fac is too big
	call	fcomp
	jp	fonvc2		;go do the check
fonvc1:	ld	de,foutdu	;get pointer to 9,999,999,999,999,999.5
	call	dcompd		;see if the number is too big
fonvc2:	pop	hl		;get the return address off the stack
	jp	p,founv2	;the number is too big, divide it by ten
	jp	(hl)		;it isn'T TOO BIG, JUST RETURN


	;here to put some zeros in the buffer
	;the count is in a, it can be zero, but the zero flag must be set
	;only (hl) and a are altered
	;we exit with a=0
fotzer:	or	a		;this is because ffxxv3 call us with the
	; condition codes not set up
fotzr1:	ret	z		;return if we are done
	dec	a		;we are not done, so decrement the count
	ld	(hl),'0'	;put a zero in the buffer
	inc	hl		;update the buffer pointer
	jp	fotzr1		;go see if we are now done


	;here to put zeros in the buffer with commas or a decimal point in the
	;middle.  the count is in a, it can be zero, but the zero flag must be
	;set.  b the decimal point count and c the comma count are updated
	;a,b,c,h,l are altered
fotznc:	jp	nz,fotzec	;entry after a "CALL FOUTCV"
fotzrc:	ret	z		;return if we are done
	call	fouted		;see if we have to put a comma or a decimal
	; point before this zero
fotzec:	ld	(hl),'0'	;put a zero in the buffer
	inc	hl		;update the buffer pointer
	dec	a		;decrement the zero count
	jp	fotzrc		;go back and see if we are done


	;here to put a possible comma count in c, and zero c if we are not
	;using the comma specification
foutcd:	ld	a,e		;setup decimal point count
	add	a,d
	inc	a
	ld	b,a
	inc	a		;setup comma count
fotcd1:	sub	3		;reduce [a] mod 3
	jp	nc,fotcd1
	add	a,5		;add 3 back in and add 2 more for
	;scaling
foutcc:	ld	c,a		;save a possible comma count
fouicc:	ld	a,(temp3)	;get the format specs
	and	100o		;look at the comma bit
	ret	nz		;we are using commas, just return
	ld	c,a		;we aren'T, ZERO THE COMMA COUNT
	ret			;all done


	;here to put decimal points and commas in their correct places
	;this subroutine should be called before the next digit is put in the
	;buffer.  b=the decimal point count, c=the comma count
	;the counts tell how many more digits have to go in before the comma
	;or decimal point go in.  the comma or decimal point then goes before
	;the last digit in the count.  for example, if the decimal point should
	;come after the first digit, the decimal point count should be 2.
foutan:	;save for later
	dec	b		;
	jp	p,foute1	;process as normal
	ld	(temp2),hl	;save location of decimal point
	ld	(hl),'.'	;put in d.p.
foutd1:	inc	hl		;point to next buffer postion
	ld	(hl),'0'
	inc	b		;
	jp	nz,foutd1
	inc	hl		;point to next available buffer location
	ld	c,b
	ret
fouted:	dec	b		;time for d.p.?
foute1:	;
	jp	nz,foued1	;no, check for the comma
	;entry to put a decimal point in the buffer
foutdp:	ld	(hl),'.'	;yes, put the decimal point in
	ld	(temp2),hl	;save the location of the decimal point
	inc	hl		;increment the buffer pointer
	ld	c,b		;put zero in c so we won"T PRINT ANY COMMAS
	ret			; after the decimal point.  all done
	;here to see if it is time to print a comma
foued1:	dec	c		;is it time?
	ret	nz		;nope, we can return
	ld	(hl),54o	;","=54, yes, put a comma in the buffer
	inc	hl		;increment the buffer pointer
	ld	c,3		;reset the comma count so we will print a
	ret			; comma after three more digits.  all done


	;here to convert a sng or dbl number that has been normalized to
	;decimal digits.  the decimal point count and comma count are in b and
	;c respectively.  (hl) points to where the first digit will go.
	;this exits with a=0.  (de) is left unaltered.
foutcv:	push	de		;save (de)
	call	getypr		;see what kind of a number we have
	jp	po,foutcs	;we have a sng
	;here to convert a double precision number to decimal digits
	push	bc		;save the decimal point and comma counts
	push	hl		;save the buffer pointer
	call	vmovaf		;move the fac into arg
	ld	hl,dhalf	;get pointer to .5d0
	call	vmovfm		;move the constant into the fac
	call	dadd		;add .5 to the original number to round it
	xor	a		;clear the carry
	call	dintfo		;take the integer part of the number
	;the number is not normalized afterwards
	pop	hl		;get the buffer pointer back
	pop	bc		;get the comma and decimal point counts back
	ld	de,fodtbl	;get a pointer to the dbl power of ten table
	ld	a,12o		;convert ten digits, the others will be
	; converted as sng'S AND INT's
	;because we bracketed the number a
	;power of ten less in magnitude and
	;single precision conversion can handle
	;a magnitude of ten larger
	;here to convert the next digit
foucd1:	call	fouted		;see if we have to put in a dp or comma
	push	bc		;save dp and comma information
	push	af		;save digit count
	push	hl		;save buffer pointer
	push	de		;save power of ten pointer
	;here to divide for the next digit
	ld	b,'0'-1		;set up the count for the digit
foucd2:	inc	b		;increment the digit count
	pop	hl		;get the pointer to the power of ten
	push	hl		;save it again
	defb	076o		;"MVI	A", get the instruction to subtract
	sbc	a,(hl)		; the power of ten
	call	daddfo		;go subtract them
	jp	nc,foucd2	;if the number was not less than the power of
	; ten, subtract again
	pop	hl		;we are done subtracting, but we did it once
	; too often, so add back in the power of ten
	;get the pointer to the power of ten
	defb	076o		;"MVI	A", get the instruction to add the
	adc	a,(hl)		; power of ten and the number
	call	daddfo		;add the two numbers
	ex	de,hl		;put the power of ten pointer in (de).  it is
	; updated for the next power of ten
	pop	hl		;get the buffer pointer back
	ld	(hl),b		;put the digit into the buffer
	inc	hl		;increment the buffer pointer
	pop	af		;get the digit count back
	pop	bc		;get the decimal point and comma counts
	dec	a		;have we printed the last digit?
	jp	nz,foucd1	;no, go do the next one
	push	bc		;yes, convert remaining digits using single
	push	hl		; precision, this is faster, move the number
	ld	hl,dfaclo	; that is left into the sng fac
	call	movfm
	jp	foucdc		;go to it!!

	;here to convert a single precision number to decimal digits
foutcs:	push	bc		;save the decimal point and comma counts
	push	hl		;save the buffer pointer
	call	faddh		;round number to nearest integer
	ld	a,1		;make a non-zero, since number is positive
	; and non-zero, round will exit with the ho
	; in a, so the msb will always be zero and
	; adding one will never cause a to be zero
	call	qint		;get integer part in c,d,e
	call	movfr		;save number in fac
foucdc:	pop	hl		;get the buffer pointer back
	pop	bc		;get the decimal point and comma counts back
	xor	a		;clear carry, the carry is our flag to
	; calculate two digits
	ld	de,fostbl	;get pointer to power of ten table
	;here to calculate the next digit of the number
foucs1:	ccf			;complement flag that tells when we are done
	call	fouted		;see if a comma or dp goes before this digit
	push	bc		;save comma and decimal point information
	push	af		;save carry i.e. digit count
	push	hl		;save character pointer
	push	de		;save power of ten pointer
	call	movrf		;get number in c,d,e
	pop	hl		;get power of ten pointer
	ld	b,'0'-1		;b = next digit to be printed
foucs2:	inc	b		;add one to digit
	ld	a,e		;subtract lo
	sub	(hl)
	ld	e,a
	inc	hl		;point to next byte of power of ten
	ld	a,d		;subtract mo
	sbc	a,(hl)
	ld	d,a
	inc	hl
	ld	a,c		;subtract ho
	sbc	a,(hl)
	ld	c,a
	dec	hl		;point to beginning of power of ten
	dec	hl
	jp	nc,foucs2	;subtract again if result was positive
	call	fadda		;it wasn'T, ADD POWER OF TEN BACK IN
	inc	hl		;increment pointer to next power of ten
	call	movfr		;save c,d,e in fac
	ex	de,hl		;get power of ten pointer in (de)
	pop	hl		;get buffer pointer
	ld	(hl),b		;put character in buffer
	inc	hl		;increment buffer pointer
	pop	af		;get digit count (the carry) back
	pop	bc		;get comma and dp information back
	jp	c,foucs1	;calculate next digit if we have not done 2
	inc	de		;we have, increment pointer to correct place
	inc	de		; in the integer power of ten table
	ld	a,4		;get the digit count
	jp	fouci1		;compute the rest of the digits like integers
	;note that the carry is off

	;here to convert an integer into decimal digits
	;this exits with a=0.  (de) is left unaltered.
foutci:	push	de		;save (de)
	ld	de,foitbl	;get pointer to the integer power of ten table
	ld	a,5		;set up a digit count, we have to calculate 5
	; digits because the max pos integer is 32768
	;here to calculate each digit
fouci1:	call	fouted		;see if a comma or dp goes before the digit
	push	bc		;save comma and decimal point information
	push	af		;save digit count
	push	hl		;save buffer pointer
	ex	de,hl		;get the power of ten pointer in (hl)
	ld	c,(hl)		;put the power of ten on the stack
	inc	hl
	ld	b,(hl)
	push	bc
	inc	hl		;increment the pwr of ten ptr to next power
	ex	(sp),hl		;get the power of ten in (hl) and put the
	; pointer on the stack
	ex	de,hl		;put the power of ten in (de)
	ld	hl,(faclo)	;get the integer in (hl)
	ld	b,'0'-1		;set up the digit count, b=digit to be printed
fouci2:	inc	b		;increment the digit count
	ld	a,l		;subtract (de) from (hl)
	sub	e		;subtract the low orders
	ld	l,a		;save the new result
	ld	a,h		;subtract the high orders
	sbc	a,d
	ld	h,a		;save the new high order
	jp	nc,fouci2	;if (hl) was .ge. (de) then subtract again
	add	hl,de		;we are done, but we subtracted (de) once too
	; often, so add it back in
	ld	(faclo),hl	;save in the fac what is left
	pop	de		;get the power of ten pointer back
	pop	hl		;get the buffer pointer back
	ld	(hl),b		;put the new digit in the buffer
	inc	hl		;increment the buffer pointer to next digit
	pop	af		;get the digit count back
	pop	bc		;get the comma and dp information back
	dec	a		;was that the last digit?
	jp	nz,fouci1	;no, go do the next one
	call	fouted		;yes, see if a dp goes after the last digit
	ld	(hl),a		;put a zero at the end of the number, but
	; don'T INCREMENT (HL) SINCE AN EXPONENT OR A
	; trailing sign may be comming
	pop	de		;get (de) back
	ret			;all done, return with a=0


	;constants used by fout
tenten:	defb	0		;10000000000
	defb	0
	defb	0
	defb	0
	defb	371o
	defb	2
	defb	25o
	defb	242o
foutdl:	defb	341o		; 999,999,999,999,999.5
	defb	377o
	defb	237o
	defb	061o
	defb	251o
	defb	137o
	defb	143o
	defb	262o
foutdu:	defb	376o		; 9,999,999,999,999,999.5
	defb	377o
	defb	003
	defb	277o
	defb	311o
	defb	033o
	defb	016o
	defb	266o
dhalf:	defb	000		; .5d0
	defb	000
	defb	000
	defb	000
fhalf:	defb	000		; .5e0
	defb	000
	defb	000
	defb	200o
ffxdxm:	defb	000		; 1d16
	defb	000
	defb	004
	defb	277o
	defb	311o
	defb	033o
	defb	016o
	defb	266o
	;double precision power of ten table
fodtbl:	defb	000		; 1d15
	defb	200o
	defb	306o
	defb	244o
	defb	176o
	defb	215o
	defb	003
	defb	000		; 1d14
	defb	100o
	defb	172o
	defb	020o
	defb	363o
	defb	132o
	defb	000
	defb	000		; 1d13
	defb	240o
	defb	162o
	defb	116o
	defb	030o
	defb	011o
	defb	000
	defb	000		; 1d12
	defb	020o
	defb	245o
	defb	324o
	defb	350o
	defb	000
	defb	000
	defb	000		; 1d11
	defb	350o
	defb	166o
	defb	110o
	defb	027o
	defb	000
	defb	000
	defb	000		; 1d10
	defb	344o
	defb	013o
	defb	124o
	defb	002
	defb	000
	defb	000
	defb	000		; 1d9
	defb	312o
	defb	232o
	defb	073o
	defb	000
	defb	000
	defb	000
	defb	000		; 1d8
	defb	341o
	defb	365o
	defb	005
	defb	000
	defb	000
	defb	000
	defb	200o		; 1d7
	defb	226o
	defb	230o
	defb	000
	defb	000
	defb	000
	defb	000
	defb	100o		; 1d6
	defb	102o
	defb	017o
	defb	000
	defb	000
	defb	000
	defb	000
	;single precision power of ten table
fostbl:	defb	240o		; 1e5
	defb	206o
	defb	001
	defb	020o		; 1e4
	defb	047o
	defb	000
	;integer power of ten table
foitbl:	defb	020o		; 10000
	defb	047o
	defb	350o		; 1000
	defb	003
	defb	144o		; 100
	defb	000
	defb	012o		; 10
	defb	000
	defb	001		; 1
	defb	000
;
; output routines for octal and hex numbers
;
	public	fouto,fouth
fouto:	xor	a		;make a=0, set zero
	ld	b,a		;save in [b]
	defb	302o		;"JNZ" around next two bytes
fouth:	ld	b,1		;set hex flag
	push	bc		;save hex/octal flag
	extrn	frqint
	call	frqint		;get double byte int in [h,l]
	pop	bc		;get back hex/octal flag
	ld	de,fbuffr	;pointer to output buffer in [d,e]
	push	de		;save so we can return it later
	xor	a		;get set to have first digit for octal
	ld	(de),a		;clear digit seen flag
	dec	b		;see if octal
	inc	b		;if so, zero set
	ld	c,6		;six digits for octal
	jp	z,octone	;do first octal digit
	ld	c,4		;four digit for hex

outhlp:	add	hl,hl		;shift left one bit
	adc	a,a		;add in the shifted bit
outolp:	add	hl,hl		;shift left one bit
	adc	a,a
	add	hl,hl
	adc	a,a
octone:	add	hl,hl		;enter here for first octal digit
	adc	a,a
	or	a		;see if we got a zero digit
	jp	nz,makdig	;no, make a digit
	ld	a,c		;get digit counter
	dec	a		;was it going to go to zero (last dig?)
	jp	z,makdig	;if so, force one zero digit
	ld	a,(de)		;have we printed a non-zero digit?
	or	a		;set cc'S
	jp	z,nolead	;no, dont print this leading zero
	xor	a		;get zero
makdig:	add	a,'0'		;make numeric digit
	cp	'9'+1		;is it a big hex digit? (a-f)
	jp	c,nothal	;no, dont add offset
	add	a,'A'-'9'-1	;add offset
nothal:	ld	(de),a		;save digit in fbuffr
	inc	de		;bump pointer
	ld	(de),a		;save here to flag printed sig. dig.
nolead:	xor	a		;make a zero
	dec	c		;all done printing?
	jp	z,finoho	;yes, return
	dec	b		;see if hex or octal
	inc	b		;test
	jp	z,outolp	;was octal
	jp	outhlp		;was hex

finoho:	ld	(de),a		;store final zero
	pop	hl		;get pointer to fbuffr
	ret			;all done.
	page
	;subttl	exponentiation and the square root function
	;all done

	;subroutine for fpwr, atn
pshneg:	ld	hl,rneg		;get the address of neg
	ex	(sp),hl		;switch ret addr and addr of neg
	jp	(hl)		;return, the address of neg is on the stack

	;square root function
	;we use sqr(x)=x^.5
sqr:	call	pushf		;save arg x
	ld	hl,fhalf	;get 1/2
	call	movfm		;sqr(x)=x^.5

	jp	fpwrt		;skip over the next 3 bytes
	;entry from the operator dispatch routines
	public	fpwrq
fpwrq:	call	frcsng		;make sure the fac is a sng
fpwrt:	pop	bc
	pop	de
	;get arg in registers, entry to fpwr if
	; argument is on stack.  fall into fpwr


	;exponentiation    ---    x^y
	;n.b.  0^0=1
	;first we check if y=0, if so, the result is 1.
	;next, we check if x=0, if so, the result is 0.
	;then we check if x is positive, if not, we check that y is a
	;negative integer, and whether it is even or odd.  if y is a negative
	;integer, we negate x.  if not, log will give an fc error when we call
	;it.  if x is negative and y is odd, we push the address of neg on the
	;stack so we will return to it and get a negative result.  to compute
	;the result we use x^y=exp(y*log(x))
fpwr:
	extrn	clrovc
	ld	hl,clrovc	;return to routine to set normal
	push	hl		;overflow mode
	ld	a,1
	ld	(flgovc),a	;set up once only overflow mode
	call	sign		;see if y is zero
	ld	a,b		;see if x is zero
	jp	z,exp		;it is, result is one
	jp	p,posexp	;positive exponent
	or	a		;is it zero to minus power?
	jp	z,intdv2	;give div by zero and continue
posexp:	or	a
	jp	z,zero0		;it is, result is zero
	push	de
	push	bc
	;save x on stack
	ld	a,c		;check the sign of x
	or	177o		;turn the zero flag off
	call	movrf		;get y in the registers
	;end intfsw contittonal
	jp	p,fpwr1		;no problems if x is positive
	push	de
	push	bc
	;save y
	call	int		;see if y is an integer
	pop	bc
	pop	de
	;get y back
	push	af		;save lo of int for even and odd information
	call	fcomp		;see if we have an integer
	pop	hl		;get even-odd information
	ld	a,h		;put even-odd flag in carry
	rra
fpwr1:	pop	hl		;get x back in fac
	ld	(fac-1),hl	;store ho'S
	pop	hl		;get lo'S OFF STACK
	ld	(faclo),hl	;store them in fac
	call	c,pshneg	;negate number at end if y was odd
	call	z,rneg		;negate the negative number
	push	de
	push	bc
	;save y again
	call	log		;compute  exp(y*log(x))
	pop	bc
	pop	de
	;if x was negative and y not an integer then
	call	fmult		; log will blow him out of the water
;	jmp	exp
	page
	;subttl	exponential functon
	;the function exp(x) calculates e^x where e=2.718282
	;	the technique used is to employ a couple
	;	of fundamental identities that allows us to
	;	use the base 2 through the difficult portions of
	;	the calculation:
	;
	;		(1)e^x=2^y  where y=x*log2(e) [log2(e) is
	;						log base 2
	;						of e ]
	;
	;		(2) 2^y=2^[ int(y)+(y-int(y)]
	;		(3) if ny=int(y) then
	;		    2^(ny+y-ny)=[2^ny]*[2^(y-ny)]
	;
	;	now, since 2^ny is easy to compute (an exponent
	;	calculation with mantissa bits of zero) the difficult
	;	portion is to compute 2^(y-ny) where 0.le.(y-ny).lt.1
	;	this is accomplished with a polynomial approximation
	;	to 2^z where 0.le.z.lt.1  . once this is computed we
	;	have to effect the multiply by 2^ny .
exp:	ld	bc,201q*256+070q
	ld	de,252q*256+073q;get log2(e)
	call	fmult		;y=fac*log2(e)
	ld	a,(fac)		;must see if too large
	cp	210o		;abs .gt. 128?
	jp	nc,exp100	;if so overflow
	cp	150o		;if too small answer is 1
	jp	c,exp200
	call	pushf		;save y
	call	int		;determine integer power of 2
	add	a,201o		;integer was returned in a
	;bias is 201 because binary
	;point is to left of understood 1
	pop	bc
	pop	de		;recall y
	jp	z,exp110	;overflow
	push	af		;save exponent
	call	fsub		;fac=y-int(y)
	ld	hl,expbcn	;will use hart 1302 poly. eval now
	call	poly		;compute 2^[y-int(y)]
	pop	bc		;integer power of 2 exponent
	ld	de,0+0
	ld	c,d		;now have floating representation
				;of int(y) in (bcde)
	jp	fmult		;multiply by 2^[y-int(y)] and return
exp100:	call	pushf		;
exp110:
	ld	a,(fac-1)	;if neg. then jump to zero
	or	a
	jp	p,exp115	;overflow if plus
	pop	af		;need stack right
	pop	af
	jp	zero		;go zero the fac
exp115:	jp	ovfin6		;overflow
exp200:	ld	bc,201q*256+000q
	ld	de,000q*256+000q;1.
	call	movfr
	ret
;*************************************************************
;	hart 1302 polynomial coefficients
;*************************************************************
expbcn:	defb	7		;degree + 1
	defb	174o		;.00020745577403-
	defb	210o
	defb	131o
	defb	164o
	defb	340o		;.00127100574569-
	defb	227o
	defb	046o
	defb	167o
	defb	304o		;.00965065093202+
	defb	035o
	defb	036o
	defb	172o
	defb	136o		;.05549656508324+
	defb	120o
	defb	143o
	defb	174o
	defb	032o		;.24022713817633-
	defb	376o
	defb	165o
	defb	176o
	defb	030o		;.69314717213716+
	defb	162o
	defb	061o
	defb	200o
	defb	000		;1.0
	defb	0000
	defb	0000
	defb	201o
	;end intfsw conditional

	page
	;subttl	polynomial evaluator and the random number generator
	;evaluate p(x^2)*x
	;pointer to degree+1 is in (hl)
	;the constants follow the degree
	;constants should be stored in reverse order, fac has x
	;we compute:
	; c0*x+c1*x^3+c2*x^5+c3*x^7+...+c(n)*x^(2*n+1)
polyx:	call	pushf		;save x
	ld	de,fmultt	;put address of fmultt on stack so when we
	push	de		; return we will multiply by x
polyx2:	push	hl		;save constant pointer
	call	movrf		;square x
	call	fmult
	pop	hl		;get constant pointer
	;fall into poly


	;polynomial evaluator
	;pointer to degree+1 is in (hl), it is updated
	;the constants follow the degree
	;constants should be stored in reverse order, fac has x
	;we compute:
	; c0+c1*x+c2*x^2+c3*x^3+...+c(n-1)*x^(n-1)+c(n)*x^n
poly:	call	pushf		;save x
	ld	a,(hl)		;get degree
	inc	hl		;increment pointer to first constant
	call	movfm		;move first constant to fac
	defb	006		;"MVI	B" over next byte
poly1:	pop	af		;get degree
	pop	bc
	pop	de
	;get x
	dec	a		;are we done?
	ret	z		;yes, return
	push	de
	push	bc
	;no, save x
	push	af		;save degree
	push	hl		;save constant pointer
	call	fmult		;evaluate the poly, multiply by x
	pop	hl		;get location of constants
	call	movrm		;get constant
	push	hl		;store location of constants so fadd and fmult
	call	fadd		; will not screw them up, add in constant
	pop	hl		;move constant pointer to next constant
	jp	poly1		;see if done


	;psuedo-random number generator
	;if arg=0, the last random number generated is returned
	;if arg .lt. 0, a new sequence of random numbers is started
	; using the argument
	;to form the next random number in the sequence, we multiply the
	;previous random number by a random constant, and add in another
	;random constant.  then the ho and lo bytes are switched, the
	;exponent is put where it will be shifted in by normal, and the
	;exponent in the fac set to 200 so the result will be less than 1.
	;this is then normalized and saved for the next time.
	;the ho and lo bytes were switched so we have a random chance of
	;getting a number less than or greater than .5
	public	rndcop
rndcop:	defb	122o		;a copy of rndx to copy at run time
	defb	307o
	defb	117o
	defb	200o
	public	rndmon
rndmon:	call	chrgtr
	public	rndmn2
rndmn2:	push	hl		;save text pointer for monadic rnd
	ld	hl,fone		;pretend arg is 1.0
	call	movfm
	call	rnd		;pick up a random value
	pop	hl		;get back the text pointer
	jp	valsng
rnd:	call	sign		;get sign of arg
	ld	hl,rndcnt+1
	jp	m,rndstr	;start new sequence if negative
	ld	hl,rndx		;get last number generated
	call	movfm
	ld	hl,rndcnt+1
	ret	z		;return last number generated if zero
	add	a,(hl)		;get counter into constants
	;and add one
	and	7
	ld	b,0
	ld	(hl),a
	inc	hl
	add	a,a
	add	a,a
	ld	c,a
	add	hl,bc
	call	movrm
	call	fmult
	ld	a,(rndcnt)
	inc	a
	and	3
	ld	b,0
	cp	1
	adc	a,b
	ld	(rndcnt),a
	ld	hl,rndtb2-4
	add	a,a
	add	a,a
	ld	c,a
	add	hl,bc
	call	fadds
rnd1:	call	movrf		;switch ho and lo bytes,
	ld	a,e		;get lo
	ld	e,c		;put ho in lo byte
	xor	117o
	ld	c,a		;put lo in ho byte
	ld	(hl),200o	;make result positive
	dec	hl		;get pointer to exponent
	ld	b,(hl)		;put exponent in overflow position
	ld	(hl),200o	;set exp so result will be between 0 and 1
	ld	hl,rndcnt-1
	inc	(hl)		;increment the pertubation count
	ld	a,(hl)		;see if its time
	sub	253o
	jp	nz,ntptrb
	ld	(hl),a		;zero the counter
	inc	c
	dec	d
	inc	e
ntptrb:	call	normal		;normalize the result
	ld	hl,rndx		;save random number generated for next
	jp	movmf		; time
rndstr:	ld	(hl),a		;zero the counters
	dec	hl
	ld	(hl),a
	dec	hl
	ld	(hl),a
	jp	rnd1

	;storage for rnd
	defb	0
	public	rndcnt
rndcnt:	defb	0
	defb	0
rndtab:	defb	65o
	defb	112o
	defb	312o
	defb	231o
	defb	71o
	defb	34o
	defb	166o
	defb	230o
	defb	42o
	defb	225o
	defb	263o
	defb	230o
	defb	12o
	defb	335o
	defb	107o
	defb	230o
	defb	123o
	defb	321o
	defb	231o
	defb	231o
	defb	012o
	defb	032o
	defb	237o
	defb	230o
	defb	145o
	defb	274o
	defb	315o
	defb	230o
	defb	326o
	defb	167o
	defb	076o
	defb	230o
	public	rndx
rndx:	defb	122o		;last random number generated, between 0 and 1
	defb	307o
	defb	117o
	defb	200o
rndtb2:	defb	150o
	defb	261o
	defb	106o
	defb	150o
	defb	231o
	defb	351o
	defb	222o
	defb	151o
	defb	020o
	defb	321o
	defb	165o
	defb	150o
	page
	;subttl	sine, cosine and tangent functions
	;cosine function
	;idea:  use cos(x)=sin(x+pi/2)
bobtst	defl	0
cos:	ld	hl,pi2		;add pi/2 to fac
	call	fadds
	;end intfsw
	;fall into sin


	;sine function
	;idea: use identities to get fac in quadrants i or iv
	;the fac is divided by 2*pi and the integer part is ignored because
	;sin(x+2*pi)=sin(x).  then the argument can be compared with pi/2 by
	;comparing the result of the division with pi/2/(2*pi)=1/4.
	;identities are then used to get the result in quadrants i or iv.
	;an approximation polynomial is then used to compute sin(x).
sin:
	ld	a,(fac)		;will see if .lt.2^-10
	;and if so sin(x)=x
	cp	167o		;
	ret	c
	;sin by hart #3341
	ld	bc,176q*256+042q
	ld	de,371q*256+203q;will calculate x=fac/(2*pi)
	call	fmult
	call	pushf		;save x
	call	int		;fac=int(x)
	pop	bc
	pop	de
	;fetch x to registers
	call	fsub		;fac=x-int(x)
	ld	bc,177q*256+000q
	ld	de,000q*256+000q;get 1/4
	call	fcomp		;fac=fac-1/4
	jp	m,sin2a
	ld	bc,177q*256+200q
	ld	de,000q*256+000q;-1/4
	call	fadd		;
	ld	bc,200q*256+200q
	ld	de,000q*256+000q;-1/2
	call	fadd		;x=x-1/2
	call	sign
	call	p,rneg		;make sure if quadrants ii,iv
	;we work with 1/4-x
sin2:	ld	bc,177q*256+000q
	ld	de,000q*256+000q;1/4
	call	fadd		;
	call	rneg		;
sin2a:	ld	a,(fac-1)	;must reduce to [0,1/4]
	or	a		;sign in psw
	push	af		;save for possible neg. after calc
	jp	p,sin3
	xor	200o		;
	ld	(fac-1),a	;now in [0,1/4]
sin3:	ld	hl,sincon	;point to hart coefficients
	call	polyx		;do poly eval
	pop	af		;now to do sign
	ret	p		;ok if pos
	ld	a,(fac-1)	;fetch sign byte
	xor	200o		;make neg
	ld	(fac-1),a	;replace sign
	ret
	;end of intfsw cond

	;constants for sin, cos
p1b2pi:	defb	000		;1/(2*pi)
	defb	000
	defb	000
	defb	000
	defb	203o
	defb	371o
	defb	042o
	defb	176o
pi2:	defb	333o		; pi/2
	defb	017o
	defb	111o
	defb	201o
fr4:	defb	000		; 1/4
	defb	000
	defb	000
	defb	177o
sincon:	;hart algorithm 3341 constants
;note that hart constants have been scaled by a power of 2
;this is due to range reduction as a % of 2*pi rather than pi/2
;would need to multiply argument by 4 but instead we factor this
;thru the constants.
	defb	5		;degree
	defb	373o		; .1514851e-3
	defb	327o
	defb	036o
	defb	206o
	defb	145o		; -.4673767e-2
	defb	046o
	defb	231o
	defb	207o
	defb	130o		; .7968968e-1
	defb	064o
	defb	043o
	defb	207o
	defb	341o		; -.6459637
	defb	135o
	defb	245o
	defb	206o
	defb	333o		; 1.570796
	defb	017o
	defb	111o
	defb	203o

	;tangent function
	;tan(x)=sin(x)/cos(x)
tan:	call	pushf		;save arg
	call	sin		;   tan(x)=sin(x)/cos(x)
	pop	bc		;get x off stack
	pop	hl		;pushf smashes (de)
	call	pushf
	ex	de,hl		;get lo'S WHERE THEY BELONG
	call	movfr
	call	cos
	jp	fdivt

	page
	;subttl	arctangent function
	;idea: use identities to get arg between 0 and 1 and then use an
	;approximation polynomial to compute arctan(x)
atn:	call	sign		;see if arg is negative
	call	m,pshneg	;if arg is negative, use:
	call	m,rneg		;   arctan(x)=-arctan(-x)
	ld	a,(fac)		;see if fac .gt. 1
	cp	201o
	jp	c,atn2
	ld	bc,201o*400o+0	;get the constant 1
	ld	d,c
	ld	e,c		;compute reciprocal to use the identity:
	call	fdiv		;  arctan(x)=pi/2-arctan(1/x)
	ld	hl,fsubs	;put fsubs on the stack so we will return
	push	hl		; to it and subtract the reult from pi/2
atn2:	ld	hl,atncon	;evaluate approximation polynomial
	call	polyx
	ld	hl,pi2		;get pointer to pi/2 in case we have to
	ret			; subtract the result from pi/2

	;constants for atn
atncon:	defb	11o		;degree
	defb	112o		; .002866226
	defb	327o
	defb	073o
	defb	170o
	defb	002		; -.01616574
	defb	156o
	defb	204o
	defb	173o
	defb	376o		; .04290961
	defb	301o
	defb	057o
	defb	174o
	defb	164o		; -.07528964
	defb	061o
	defb	232o
	defb	175o
	defb	204o		; .1065626
	defb	075o
	defb	132o
	defb	175o
	defb	310o		; -.142089
	defb	177o
	defb	221o
	defb	176o
	defb	344o		; .1999355
	defb	273o
	defb	114o
	defb	176o
	defb	154o		; -.3333315
	defb	252o
	defb	252o
	defb	177o
	defb	000		; 1.0
	defb	000
	defb	000
	defb	201o

;	end
