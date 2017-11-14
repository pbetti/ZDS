; Copyright (C) 1982, 1983, 1984 by Manx Software Systems
; :ts=8
	extrn	flprm
	extrn	.dldp, .utod
	public	frexp_, ldexp_, modf_
;
frexp_:		;return mantissa and exponent
	push	b
	lxi	h,4
	dad	sp
	call	calcexp		;calculate power of two exponent
	jnz	retexp
	lxi	b,0
retexp:
	lxi	h,12		;address second argument
	dad	sp
	mov	e,m
	inx	h
	mov	d,m
	xchg
	mov	m,c		;return base 2 exponent
	inx	h
	mov	m,b
popret:
	pop	b
	ret
;
ldexp_:		;load new exponent value (actualy add to exponent)
	push	b
	lxi	h,4
	dad	sp
	call	calcexp
	jz	popret		;do nothing if number is zero or unnormalized
	lxi	h,12		;fetch number to add to exponent
	dad	sp
	mov	e,m
	inx	h
	mov	d,m
	xchg
	dad	b		;add exponents
	mov	a,h
	ora	a		;check sign of exponent
	jp	posexp
	cma			;make positive for div and modulo below
	mov	h,a
	mov	a,l
	cma
	mov	l,a
	inx	h
	mov	a,l
	ani	7
	mov	c,a		;save amount to shift
	call	rsexp		;make power of 256
	mov	a,l
	cma
	inr	a		;fix sign back
	mov	l,a
	jmp	ldrs
posexp:
	ora	l		;check if zero
	jz	popret		;no adjustment needed
	mov	c,l		;save to compute left shift
	call	rsexp		;make power of 256
	mov	a,c
	ani	7
	jz	ldrsx
	inr	l		;bump exponent to make right shift
	cma
	adi	9		;compensate for +1 (c = -(x-8))
ldrsx:
	mov	c,a		;save for loop below
ldrs:
	xchg
	lhld	flprm
	inx	h
	mov	m,e		;save exponent
rsloop:
	dcr	c
	jm	popret
	lhld	flprm
	inx	h
	inx	h
	mvi	b,7
	ora	a		;clear carry
rslp:
	inx	h
	mov	a,m
	rar
	mov	m,a
	dcr	b
	jnz	rslp
	jmp	rsloop
;
rsexp:
	ora	a
	mvi	b,3
rselp:
	mov	a,h
	rar
	mov	h,a
	mov	a,l
	rar
	mov	l,a
	dcr	b
	jnz	rselp
	ret
;
calcexp:
	call	.dldp		;load into floating accumulator
	lhld	flprm
	inx	h
	mov	a,m		;get exponent value
	cpi	-64
	rz
	mvi	m,0		;make exponent zero for return
	mov	l,a		;get low byte of exponent
	rlc			;sign extend value
	sbb	a
	mov	h,a		;save high byte of exponent
	dad	h
	dad	h
	dad	h		; exp*8 to make power of two
	mov	b,h		; bc = exponent
	mov	c,l
	lhld	flprm
	inx	h
	inx	h
	inx	h		;hl = first byte of mantissa
	mov	a,m
	ora	a
	rz			;unnormalized number?  give up
lshft:
	mov	a,m
	ani	80H			;test high bit of mantissa
	rnz			;mantissa >= 0.5 ? yes return
			;otherwise, shift number to the left one place
	dcx	b		;and adjust exponent
	lxi	d,7
	dad	d		;address of end of fraction
lsloop:
	dcx	h
	mov	a,m
	ral
	mov	m,a
	dcr	e
	jnz	lsloop
	jmp	lshft
;
modf_:			;split into integral and fraction parts
	push	b
	lxi	h,12		;pick up address to store integral part
	dad	sp
	mov	c,m
	inx	h
	mov	b,m
	mov	l,c
	mov	h,b
	mvi	e,8		;clear out integer
	xra	a
mdclr:
	mov	m,a
	inx	h
	dcr	e
	jnz	mdclr
;
	lxi	h,4
	dad	sp
	call	.dldp
	lhld	flprm
	inx	h
	mov	a,m
	ora	a
	jm	popret
	jz	popret
	adi	64
	ani	7fH
	mov	e,a
	dcx	h
	mov	a,m		;get sign of number
	ani	80H		;isolate
	ora	e		;combine with exponent
	stax	b		;store away
	inx	b
	inx	h
	mov	a,m		;refetch exponent
	inx	h		;skip over exponent
	inx	h		;skip over overflow byte
	cpi	7
	jc	expok		;limit move loop to 7 bytes
	mvi	a,7
expok:
	mov	e,a		;save count for loop
	cma
	adi	8		; 7 - loop count
	mov	d,a		;save # bytes in fraction
intmov:			;copy integer part into given area
	mov	a,m
	stax	b
	inx	h
	inx	b
	dcr	e
	jnz	intmov
;
fnorm:			;note: E is zero at start of this loop
	dcr	d
	jm	zfrac		;fraction is zero
	mov	a,m		;look for non-zero byte
	inx	h
	dcr	e		;count for exponent of fraction
	ora	a
	jz	fnorm
;
	dcx	h		;back up to good byte
	inr	e		;fix exponent
	mov	b,h		;save position in accumulator
	mov	c,l
	lhld	flprm
	inx	h
	mov	m,e		;store exponent
	inx	h		;skip overflow byte
	mvi	e,7		;count of # that must be cleared
frcmov:
	inx	h
	ldax	b
	mov	m,a
	inx	b
	dcr	e
	dcr	d
	jp	frcmov
	xra	a
frcclr:			;clear out rest of register
	inx	h
	mov	m,a
	dcr	e
	jnz	frcclr
	pop	b
	ret
zfrac:				;fraction is zero
	lxi	h,0
	call	.utod
	pop	b
	ret
