; Copyright (C) 1982, 1983, 1984 by Manx Software Systems
; :ts=8
	extrn	lnprm,lntmp,lnsec
;
	public	.llis		;load long immediate secondary
.llis:
	pop	d		;get return addr
	lxi	h,4		;size of long
	dad	d
	push	h		;put back correct return addr
	xchg
			;fall through into .llds
;
	public	.llds		;load long into secondary accum
.llds:
	lxi	d,lnsec
	jmp	lload
;
	public	.llip		;load long immediate primary
.llip:
	pop	d		;get return addr
	lxi	h,4		;size of long
	dad	d
	push	h		;put back correct return addr
	xchg
			;fall through into .lldp
;
	public .lldp		;load long into primary accum
.lldp:
	lxi	d,lnprm
lload:
	mov	a,m
	stax	d
	inx	d
	inx	h
	mov	a,m
	stax	d
	inx	d
	inx	h
	mov	a,m
	stax	d
	inx	d
	inx	h
	mov	a,m
	stax	d
	ret
;
	public .lst		;store long at addr in HL
.lst:
	lxi	d,lnprm
	ldax	d
	mov	m,a
	inx	h
	inx	d
	ldax	d
	mov	m,a
	inx	h
	inx	d
	ldax	d
	mov	m,a
	inx	h
	inx	d
	ldax	d
	mov	m,a
	ret
;
	public .lpsh		;push long onto the stack
.lpsh:				;from the primary accumulator
	pop	d		;get return address
	lxi	h,lnprm+3
	lhld	lnprm+2
	push	h
	lhld	lnprm
	push	h
	xchg
	pchl
;
	public	.lpop		;pop long into secondary accum
.lpop:
	pop	d		;get return address
	pop	h		;bytes 0 and 1
	shld	lnsec
	pop	h
	shld	lnsec+2
	xchg
	pchl
;
	public	.lswap		;exchange primary and secondary
.lswap:
	lhld	lnsec
	xchg
	lhld	lnprm
	shld	lnsec
	xchg
	shld	lnprm
	lhld	lnsec+2
	xchg
	lhld	lnprm+2
	shld	lnsec+2
	xchg
	shld	lnprm+2
	ret
;
	public	.lng		;negate primary
.lng:
	lxi	h,lnprm
negate:
	xra	a
	mvi	d,4
ngloop:
	mvi	a,0
	sbb	m
	mov	m,a
	inx	h
	dcr	d
	jnz	ngloop
	ret
;
	public	.ltst		;test if primary is zero
.ltst:
	lxi	h,lnprm
	mvi	d,4
tstlp:
	mov	a,m
	ora	a
	jnz	true
	inx	h
	dcr	d
	jnz	tstlp
	jmp	false
;
	public	.lcmp		;compare primary and secondary
;
			;return 0 if p == s
p.lt.s:			;return < 0 if p < s
	xra	a
	dcr	a
	pop	b
	ret
;
p.gt.s:			;	> 0 if p > s
	xra	a
	inr	a
	pop	b
	ret
;
.lcmp:
	push	b
	lxi	d,lnprm+3
	lxi	h,lnsec+3
	mov	a,m
	xri	80h
	mov	c,a
	ldax	d
	xri	80h
	cmp	c
	mvi	b,4
	jmp	pswchk

	public	.ulcmp
.ulcmp:
	push	b
	lxi	d,lnprm+3
	lxi	h,lnsec+3
	mvi	b,4
cmploop:
	ldax	d
	cmp	m
pswchk:
	jc	p.lt.s
	jnz	p.gt.s
	dcx	h
	dcx	d
	dcr	b
	jnz	cmploop
			;return 0 if p == s
	xra	a
	pop	b
	ret
;
	public .lad		;add secondary to primary
.lad:
			;DE is used as primary address
			;and HL is used as secondary address
	push	b
	lxi	d,lnprm
	lxi	h,lnsec
	xra	a	;clear carry
	mvi	b,4
adloop:
	ldax	d
	adc	m
	stax	d
	inx	h
	inx	d
	dcr	b
	jnz	adloop
	pop	b
	ret
;
	public	.lsb		;subtract secondary from primary
.lsb:
	push	b
	lxi	d,lnprm
	lxi	h,lnsec
	xra	a	;clear carry
	mvi	b,4
sbloop:
	ldax	d
	sbb	m
	stax	d
	inx	h
	inx	d
	dcr	b
	jnz	sbloop
	pop	b
	ret
;
	public	.lan		;and primary with secondary
.lan:
	push	b
	lxi	d,lnprm
	lxi	h,lnsec
	mvi	b,4
ndloop:
	ldax	d
	ana	m
	stax	d
	inx	h
	inx	d
	dcr	b
	jnz	ndloop
	pop	b
	ret
;
	public	.lor		;or primary with secondary
.lor:
	push	b
	lxi	d,lnprm
	lxi	h,lnsec
	mvi	b,4
orloop:
	ldax	d
	ora	m
	stax	d
	inx	h
	inx	d
	dcr	b
	jnz	orloop
	pop	b
	ret
;
	public	.lxr		;exclusive or primary with secondary
.lxr:
	push	b
	lxi	d,lnprm
	lxi	h,lnsec
	mvi	b,4
xrloop:
	ldax	d
	xra	m
	stax	d
	inx	h
	inx	d
	dcr	b
	jnz	xrloop
	pop	b
	ret
;
	public	.lcm		;complement primary
.lcm:
	lxi	h,lnprm
	mvi	d,4
cmloop:
	mov	a,m
	cma
	mov	m,a
	inx	h
	dcr	d
	jnz	cmloop
	ret
;
	public	.lls		;shift primary left by secondary
.lls:
	lda	lnsec
	ani	03fH		;restrict to 63 bits
	rz
	lhld	lnprm
	xchg
	lhld	lnprm+2		;DE has low word, HL has high word
lsloop:
	dad	h		;shift high word
	xchg
	dad	h		;shift low word
	xchg
	jnc	lsnc
	inr	l		;carry into high word
lsnc:
	dcr	a
	jnz	lsloop
	shld	lnprm+2		;put back high word
	xchg
	shld	lnprm
	ret
;
	public	.lur		;unsigned right shift primary by secondary bits
.lur:
	clc			;propogate 0 bit
	jmp	rs_sub
;
	public	.lrs		;right shift primary by secondary bits
.lrs:
	lda	lnprm+3
	ral		;set carry to MSB
rs_sub:
	push	psw
	lda	lnsec
	ani	03fH		;limit to 63 places
	jz	rsdone
	mov	d,a
rslp1:
	lxi	h,lnprm+3
	mvi	e,4
	pop	psw		;get correct carry setting
	push	psw
rslp2:
	mov	a,m
	rar
	mov	m,a
	dcx	h
	dcr	e
	jnz	rslp2
	dcr	d
	jnz	rslp1
rsdone:
	pop	psw
	ret
;
;
setup:
	lxi	h,3
	dad	d
	mov	c,m
	mov	a,c
	ora	a
	rp
	xchg
	jmp	negate		;force positive
;
	public	.ldv
.ldv:		;long divide	(primary = primary/secondary)
	push	b
	lxi	d,lnprm
	call	setup
	push	b
	lxi	d,lnsec
	call	setup
	mov	a,c
	pop	b		;get primary sign
	xra	c		;merge signs
	push	psw		;save for return
	call	dodivide
	pop	psw
	pop	b
	jm	.lng
	ret
;
	public	.lrm
.lrm:		;long remainder	(primary = primary%secondary)
	push	b
	lxi	d,lnprm
	call	setup
	mov	a,c
	ora	a
	push	psw
	lxi	d,lnsec
	call	setup
	call	dodivide
	lxi	d,lntmp
	lxi	h,lnprm
	mvi	b,4
remsave:
	ldax	d
	mov	m,a
	inx	d
	inx	h
	dcr	b
	jnz	remsave
	pop	psw
	pop	b
	jm	.lng
	ret
;
	public	.lud
.lud:		;unsigned long divide	(primary = primary/secondary)
	push	b
	call	dodivide
	pop	b
	ret
;
	public	.lum
.lum:		;long remainder	(primary = primary%secondary)
	push	b
	call	dodivide
	lxi	d,lntmp
	lxi	h,lnprm
	mvi	b,4
uremsave:
	ldax	d
	mov	m,a
	inx	d
	inx	h
	dcr	b
	jnz	uremsave
	pop	b
	ret
;
;
dodivide:
	mvi	b,4
	lxi	h,lntmp		;clear quotient buffer
	xra	a
quinit:
	mov	m,a
	inx	h
	dcr	b
	jnz	quinit

	mvi	a,32		;initialize loop counter
divloop:
	push	psw
	lxi	h,lnprm
	mvi	b,8
	ora	a		;clear carry
shlp:
	mov	a,m
	adc	a		;shift one bit to the left
	mov	m,a
	inx	h
	dcr	b
	jnz	shlp
	sbb	a
	ani	1
	mov	c,a

	mvi	b,4
	lxi	d,lntmp
	lxi	h,lnsec
	ora	a		;clear carry
sublp:
	ldax	d
	sbb	m
	stax	d
	inx	d
	inx	h
	dcr	b
	jnz	sublp
	mov	a,c
	sbi	0
	jnz	zerobit
onebit:
	lxi	h,lnprm
	inr	m
	pop	psw
	dcr	a
	jnz	divloop
	ret
;
zerobit:
	pop	psw
	dcr	a
	jz	restore
	push	psw
	lxi	h,lnprm
	mvi	b,8
	ora	a		;clear carry
zshlp:
	mov	a,m
	adc	a		;shift one bit to the left
	mov	m,a
	inx	h
	dcr	b
	jnz	zshlp
	sbb	a
	mov	c,a

	mvi	b,4
	lxi	d,lntmp
	lxi	h,lnsec
	ora	a		;clear carry
daddlp:
	ldax	d
	adc	m
	stax	d
	inx	d
	inx	h
	dcr	b
	jnz	daddlp
	mov	a,c
	aci	0
	jnz	zerobit
	jmp	onebit
;
restore:			;fix up remainder if still negative
	mvi	b,4
	lxi	d,lntmp
	lxi	h,lnsec
	ora	a		;clear carry
resloop:
	ldax	d
	adc	m
	stax	d
	inx	d
	inx	h
	dcr	b
	jnz	resloop
	ret
;
;
	public	.lml
.lml:		;long multiply	(primary = primary * secondary)
	push	b
;
	lxi	h,lnprm
	mvi	b,4
	lxi	d,lntmp		;copy multiplier into work area
msav:
	mov	a,m
	stax	d
	mvi	m,0
	inx	h
	inx	d
	dcr	b
	jnz	msav
;
	mvi	a,32		;initialize loop counter
muloop:
	push	psw
	lxi	h,lnprm
	mvi	b,8
	ora	a		;clear carry
mshlp:
	mov	a,m
	adc	a		;shift one bit to the left
	mov	m,a
	inx	h
	dcr	b
	jnz	mshlp
	jnc	mnext

	mvi	b,4
	lxi	d,lnprm
	lxi	h,lnsec
	ora	a		;clear carry
maddlp:
	ldax	d
	adc	m
	stax	d
	inx	d
	inx	h
	dcr	b
	jnz	maddlp
;
mnext:
	pop	psw
	dcr	a
	jnz	muloop
	pop	b
	ret
;
;
	public .leq
.leq:
	call	.lcmp
	jz	true
false:
	lxi	h,0
	xra	a
	ret
;
	public .lne
.lne:
	call	.lcmp
	jz	false
true:
	lxi	h,1
	xra	a
	inr	a
	ret
;
	public .llt
.llt:
	call	.lcmp
	jm	true
	jmp	false
;
	public .lle
.lle:
	call	.lcmp
	jm	true
	jz	true
	jmp	false
;
	public .lge
.lge:
	call	.lcmp
	jm	false
	jmp	true
;
	public .lgt
.lgt:
	call	.lcmp
	jm	false
	jz	false
	jmp	true
;
	public .lul
.lul:
	call	.ulcmp
	jm	true
	jmp	false
;
	public .lue
.lue:
	call	.ulcmp
	jm	true
	jz	true
	jmp	false
;
	public .luf
.luf:
	call	.ulcmp
	jm	false
	jmp	true
;
	public .lug
.lug:
	call	.ulcmp
	jm	false
	jz	false
	jmp	true
;
	public	.utox
.utox:
	shld	lnprm
posconv:
	lxi	h,0
	shld	lnprm+2
	ret
;
	public	.itox
.itox:
	shld	lnprm
	mov	a,h
	ora	a
	jp	posconv
	lxi	h,-1
	shld	lnprm+2
	ret
;
	public	.xtoi
.xtoi:
	lhld	lnprm
	ret
	end
