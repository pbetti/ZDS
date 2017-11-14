; Copyright (C) 1983 by Manx Software Systems
; :ts=8
	extrn	.dml10, .utod, .dswap, .dad
	extrn	.dlis, .ddv, .dng
	dseg
msign:	ds	1
esign:	ds	1
dpflg:	ds	1
dexp:	ds	2
	cseg
	public	atof_
atof_:
	push	b
	xra	a
	sta	msign		;clear mantissa sign
	sta	esign		;clear exponent sign
	sta	dpflg		;have not seen decimal point yet
	lxi	h,0
	shld	dexp		;clear exponent to zero
	call	.utod		;clear floating point accumulator
;
	lxi	h,4
	dad	sp
	mov	c,m		;get address of string to convert
	inx	h
	mov	b,m
skipbl:
	ldax	b
	cpi	' '
	jz	blank
	cpi	9
	jnz	notblank
blank:
	inx	b
	jmp	skipbl
notblank:
	cpi	'-'
	jnz	notneg		;not minus sign
	sta	msign		;set negative for later
	jmp	skpsign
notneg:
	cpi	'+'		;check for plus sign
	jnz	getnumb
skpsign:
	inx	b		;skip over sign character
getnumb:
	ldax	b
	cpi	'0'
	jc	notdigit
	cpi	'9'+1
	jnc	notdigit
	push	psw
	call	.dml10
	call	.dswap
	pop	psw
	sui	'0'
	mov	l,a
	mvi	h,0
	call	.utod
	call	.dad
	lda	dpflg
	ora	a
	jz	skpsign
	lhld	dexp
	dcx	h
	shld	dexp
	jmp	skpsign
notdigit:
	cpi	'.'
	jnz	nomore
	lxi	h,dpflg
	mvi	m,1		;set dec. pt. seen
	jmp	skpsign
;
nomore:
	lxi	h,0		;clear exponent
	ori	20H		;force to lower case
	cpi	'e'
	jnz	scaleit
	inx	b
	ldax	b
	cpi	'-'
	jnz	exppos
	sta	esign		;set exponent negative
	jmp	nxtchr
exppos:
	cpi	'+'
	jnz	getexp
nxtchr:
	inx	b
getexp:
	ldax	b
	cpi	'0'
	jc	expdone
	cpi	'9'+1
	jnc	expdone
	sui	'0'
	dad	h	; exp *= 2
	mov	d,h
	mov	e,l
	dad	h	;exp *= 4
	dad	h	;exp *= 8
	dad	d	;exp *= 10
	mov	e,a
	mvi	d,0
	dad	d	;exp = exp*10 + char - '0'
	jmp	nxtchr
;
expdone:
	lda	esign		;check sign of exponent
	ora	a
	jz	addexp
	mov	a,h		;negate if sign was minus
	cma
	mov	h,a
	mov	a,l
	cma
	mov	l,a
	inx	h
addexp:
	xchg
	lhld	dexp		;get digit count
	dad	d		;add in exponent value
	shld	dexp		;save for scaling later
;
scaleit:		;scale number to correct value
	lhld	dexp
	mov	a,h
	ora	a
	jp	movup
			;negative exponent
	cpi	0ffH	;test if exponent too large
	jnz	rngerr
	mov	a,l
	cma
	inr	a
	mov	c,a	;save for loop later
	cpi	166
	jnc	rngerr
	cpi	150
	jc	sizeok
	call	.dlis		;divide by 1e16 since smallest will overflow
	db	47H,23H,86H,0f2H,6fH,0c1H,0,0
	call	.ddv
	mov	a,c	;get exponent value back
	sui	16
	mov	c,a
sizeok:
	call	.dswap
	lxi	h,1
	call	.utod
sclp1:
	call	.dml10		;compute number to divide by
	dcr	c
	jnz	sclp1
	call	.dswap		;get everybody back in place
	call	.ddv		;move into range
	jmp	dosign
;
movup:				;positive exponent scale number up
	jnz	rngerr
	mov	a,l		;get loop count
	ora	a
	jz	dosign
	mov	c,a
sclp2:
	call	.dml10
	dcr	c
	jnz	sclp2
;
dosign:
	lda	msign		;check sign of number
	ora	a
	jz	return
	call	.dng		;negate accumulator
return:
	pop	b
	ret
;
rngerr:
	pop	b
	ret
	end
