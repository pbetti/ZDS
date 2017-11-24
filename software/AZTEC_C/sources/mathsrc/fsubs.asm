;	Copyright (C) 1982, 1983, 1984 by Manx Software Systems
; :ts=8
	extrn	Sysvec_
	extrn	lnprm
	extrn	puterr_
	dseg
	public	flprm,flsec
flprm:	dw	acc1
flsec:	dw	acc2
	public	flterr_
flterr_: dw	0
retsave:ds	2
YU:	ds	2
VEE:	ds	2
expdiff:ds	1
acc1:	ds	18
acc2:	ds	18
	;work area for divide and multiply routines
lcnt:	ds	1	;iterations left
tmpa:	ds	8	;quotient 
tmpb:	ds	8	;remainder work area
tmpc:	ds	8	;temp for divisor
	cseg
	public	.flds		;load single float into secondary accum
.flds:
	xchg
	lhld	flsec
	jmp	fload
;
	public .fldp		;load single float into primary accum
.fldp:
	xchg
	lhld	flprm
fload:
	push	b
	ldax	d		;get first byte of number
	mov	m,a		;save sign
	inx	h
	ani	7fH		;isolate exponent
	sui	64		;adjust from excess 64 notation
	mov 	m,a		;and save
	inx	h
	mvi	m,0		;extra byte for carry
	mvi	b,3		;copy 3 byte fraction
ldloop:
	inx	h
	inx	d
	ldax	d
	mov	m,a
	dcr	b
	jnz	ldloop

	mvi	b,5		;clear rest to zeros
	xra	a
clloop:
	inx	h
	mov	m,a
	dcr	b
	jnz	clloop
	pop	b
	ret
;
	public .fst		;store single at addr in HL
.fst:
	push	b
	xchg
	lhld	flprm
	mov	a,m		;get sign
	ani	80H		;and isolate
	mov	b,a		;save
	inx	h
	mov	a,m		;get exponent
	adi	64		;put into excess 64 notation
	ani	7fH		;clear sign bit
	ora	b		;merge exponent and sign
	stax	d
	inx	h		;skip overflow byte
	mvi	b,3		;copy 3 bytes of fraction
fstlp:
	inx	d
	inx	h
	mov	a,m
	stax	d
	dcr	b
	jnz	fstlp
	pop	b
	ret
;
	public	.dlis		;load double immediate secondary
.dlis:
	pop	d		;get return addr
	lxi	h,8		;size of double
	dad	d
	push	h		;put back correct return addr
	xchg
			;fall through into .dlds
;
	public	.dlds		;load double float into secondary accum
.dlds:
	xchg
	lhld	flsec
	jmp	dload
;
	public	.dlip		;load double immediate primary
.dlip:
	pop	d		;get return addr
	lxi	h,8		;size of double
	dad	d
	push	h		;put back correct return addr
	xchg
			;fall through into .dldp
;
	public .dldp		;load double float into primary accum
.dldp:
	xchg
	lhld	flprm
dload:
	push	b
	ldax	d		;get first byte of number
	mov	m,a		;save sign
	inx	h
	ani	7fH		;isolate exponent
	sui	64		;adjust from excess 64 notation
	mov 	m,a		;and save
	inx	h
	mvi	m,0		;extra byte for carry
	mvi	b,7		;copy 7 byte fraction
dloop:
	inx	h
	inx	d
	ldax	d
	mov	m,a
	dcr	b
	jnz	dloop

	inx	h
	mvi	m,0		;clear guard byte
	pop	b
	ret
;
	public .dst		;store double at addr in HL
.dst:
	push	b
	push	h		;save address
	call	dornd		;round fraction to 7 bytes
	pop	d		;restore address
	lhld	flprm
	mov	a,m		;get sign
	ani	80H		;and isolate
	mov	b,a		;save
	inx	h
	mov	a,m		;get exponent
	adi	64		;put into excess 64 notation
	ani	7fH		;clear sign bit
	ora	b		;merge exponent and sign
	stax	d
	inx	h		;skip overflow byte
	mvi	b,7		;copy 7 bytes of fraction
dstlp:
	inx	d
	inx	h
	mov	a,m
	stax	d
	dcr	b
	jnz	dstlp
	pop	b
	ret
;
	public .dpsh		;push double float onto the stack
.dpsh:				;from the primary accumulator
	pop	h		;get return address
	shld	retsave		;and save for later
	call	dornd
	lhld	flprm
	lxi	d,9
	dad	d
	mov	d,m		;bytes 6 and 7
	dcx	h
	mov	e,m
	dcx	h
	push	d
	mov	d,m		;bytes 4 and 5
	dcx	h
	mov	e,m
	dcx	h
	push	d
	mov	d,m		;bytes 2 and 3
	dcx	h
	mov	e,m
	dcx	h
	push	d
	mov	d,m		;byte 1
	dcx	h
	dcx	h		;skip over carry byte
	mov	a,m		;get exponent
	adi	64		;and restore to excess 64 notation
	ani	7fH
	mov	e,a
	dcx	h
	mov	a,m
	ani	80H		;isolate sign bit
	ora	e		;combine exponent and sign
	mov	e,a
	push	d
	lhld	retsave
	pchl
;
	public	.dpop		;pop double float into secondary accum
.dpop:
	pop	h		;get return address
	shld	retsave		;and save
	lhld	flsec
	pop	d		;exponent/sign and first fraction
	mov	m,e		;save sign
	inx	h
	mov	a,e
	ani	7fH		;isolate exponent
	sui	64		;adjust for excess 64 notation
	mov	m,a
	inx	h
	mvi	m,0		;extra byte for carry
	inx	h
	mov	m,d
	inx	h
	pop	d		;bytes 2 and 3 of fraction
	mov	m,e
	inx	h
	mov	m,d
	inx	h
	pop	d		;bytes 4 and 5 of fraction
	mov	m,e
	inx	h
	mov	m,d
	inx	h
	pop	d		;bytes 6 and 7 of fraction
	mov	m,e
	inx	h
	mov	m,d
	inx	h
	mvi	m,0		;clear guard byte
	lhld	retsave
	pchl
;
	public	.dswap		;exchange primary and secondary
.dswap:
	lhld	flsec
	xchg
	lhld	flprm
	shld	flsec
	xchg
	shld	flprm
	ret
;
	public	.dng		;negate primary
.dng:
	lhld	flprm
	mov	a,m
	xri	80H		;flip sign
	mov	m,a
	ret
;
	public	.dtst		;test if primary is zero
.dtst:
	lhld	flprm
;	mov	a,m
;	ora	a
;	jnz	true
	inx	h
	mov	a,m
	cpi	-64
	jnz	true
;	inx	h
;	inx	h
;	mov	a,m
;	ora	a
;	jnz	true
	jmp	false
;
	public	.dcmp		;compare primary and secondary
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
.dcmp:
	push	b
	lhld	flprm
	xchg
	lhld	flsec
	ldax	d
	ora	a
	jm	dcneg
;			primary is positive
	xra	m		;check if signs the same
	jm	p.gt.s		;differ then p > s
	jmp	docomp
dcneg:
			;primary is negative
	xra	m		;check if signs the same
	jm	p.lt.s		;differ the p < s
	xchg			;both negative reverse sense of test
docomp:
	inx	h
	inx	d
	ldax	d
	cmp	m		;compare exponents
	jm	p.lt.s		;sign test ok since -64 < exp < 64
	jnz	p.gt.s
	mvi	b,9		;test overflow byte + 8 bytes of fraction
cmploop:
	inx	h
	inx	d
	ldax	d
	cmp	m
	jc	p.lt.s
	jnz	p.gt.s
	dcr	b
	jnz	cmploop
			;return 0 if p == s
	xra	a
	pop	b
	ret
;
	public	.dsb		;subtract secondary from primary
.dsb:
	lhld	flsec
	mov	a,m
	xri	80H		;flip sign of secondary
	mov	m,a
			;fall thru into add routine
;
	public .dad		;add secondary to primary
.dad:
			;DE is used as primary address
			;and HL is used as secondary address
	push	b
			;clear extra bytes at end of accumulators
	lhld	flprm
	lxi	d,11		;leave guard byte alone
	dad	d
	mvi	b,7
	xra	a
clp1:
	mov	m,a
	inx	h
	dcr	b
	jnz	clp1

	lhld	flsec
	lxi	d,11		;leave guard byte alone
	dad	d
	mvi	b,7
clp2:
	mov	m,a
	inx	h
	dcr	b
	jnz	clp2

	lhld	flprm
	xchg
	lhld	flsec
	inx	h
	inx	d
	ldax	d		;primary exponent
	sub	m		;compute difference
	jp	ordok
	xchg			;swap so primary is larger
	cma
	inr	a
ordok:
	dcx	d
	dcx	h
	shld	flsec		;fix primary and secondary
	xchg
	shld	flprm
	cpi	9		;check for exp diff too large
	jnc	normalize
	mov	c,a		;save exponent difference
	push	h
	push	d
	adi	9		;adjust for offset
	mov	e,a
	mvi	d,0
	dad	d		;adjust address for exponent difference
	shld	YU
	pop	d
	lxi	h,9
	dad	d
	shld	VEE
	pop	h
	xchg			;get prm in DE and scnd in HL
	ldax	d		;sign of primary
	xra	m		;check if signs same
	jp	doadd

	ldax	d
	ora	a		;test which one is negative
	jm	UfromV		;jump if primary is negative
			;subtract V from U
	mvi	b,7
	lhld	YU
	xchg
	lhld	VEE
sublpa:			;carry is already cleared
	ldax	d
	sbb	m
	stax	d
	dcx	d
	dcx	h
	dcr	b
	jnz	sublpa
brlpa:
	ldax	d
	sbi	0
	stax	d
	dcx	d
	dcr	c
	jp	brlpa
	xchg			;get destination into HL
	jmp	subchk		;check for negative result
;
UfromV:
			;subtract U from V
	mvi	b,7
	lhld	VEE
	xchg
	lhld	YU
sublpb:			;carry is already cleared
	ldax	d
	sbb	m
	mov	m,a
	dcx	d
	dcx	h
	dcr	b
	jnz	sublpb
brlpb:
	mvi	a,0
	sbb	m
	mov	m,a
	dcx	h
	dcr	c
	jp	brlpb
subchk:			;check for negative result
	inx	h
	mov	a,m	;check carry byte
	ora	a	;test sign
	mvi	a,1
	jp	makpos
	lxi	d,15
	dad	d	;point to end of number
neglp:
	mvi	a,0
	sbb	m
	mov	m,a
	dcx	h
	dcr	e
	jp	neglp
	mvi	a,81H		;make number negative
makpos:
	lhld	flprm
	mov	m,a		;set sign of number
	jmp	normalize
;
doadd:
			;add V to U
	mvi	b,7
	lhld	YU
	xchg
	lhld	VEE
addlp:			;carry is already cleared
	ldax	d
	adc	m
	stax	d
	dcx	d
	dcx	h
	dcr	b
	jnz	addlp
crylp:
	ldax	d
	aci	0
	stax	d
	dcx	d
	dcr	c
	jp	crylp
	jmp	normalize
;
	public	.ddv
.ddv:		;double floating divide	(primary = primary/secondary)
	push	b
	lhld	flprm
	xchg
	lhld	flsec
	ldax	d
	xra	m		;compute sign of result
	stax	d		;and store
	inx	h
	inx	d
	ldax	d		;primary exponent
	sub	m		;eu-ev
	mov	c,a		;save exponent
	push	d
	push	h
	mov	a,m
	cpi	-64
	jnz	d.ok
	pop	h
	pop	h		;throw away
	mvi	a,3		;flag divide by zero error
	sta	flterr_
	jmp	setbig		;set to biggest possible number
d.ok:
	inx	d
	inx	h
	mvi	b,8
cmloop:
	inx	d
	inx	h
	ldax	d
	cmp	m
	jnz	differ
	dcr	b
	jnz	cmloop
			;numbers are the same give 1 as the answer
	pop	h	;throw away
	pop	h	;get destination addr
	inr	c	;adjust exponent
	mov	m,c	;save exponent
	inx	h
	mvi	m,0		;clear extra byte
	inx	h
	mvi	m,1		;set result
	mvi	b,8
	xra	a
	sta	flterr_
	jmp	zclr
;
differ:			;check carry to find out smaller number
	pop	d	;restore divisor address
	pop	h	;restore dividend address
	mov	m,c	;store exponent
	jc	uok
	inr	c	;bump exponent
	mov	m,c
	dcx	h	;and shift dividend right (logically)
uok:
	push	d	;save for later
	lxi	d,9
	dad	d		;compute end address
	mvi	b,8
	lxi	d,tmpb		;copy dividend into work area
remsav:
	mov	a,m
	stax	d
	dcx	h
	inx	d
	dcr	b
	jnz	remsav
	pop	h	;restore divisor addr
	lxi	d,9
	dad	d	;move backwards
	mvi	b,8
	lxi	d,tmpc	;copy divisor into work area
divsav:
	mov	a,m
	stax	d
	dcx	h
	inx	d
	dcr	b
	jnz	divsav
	mvi	b,8
	lxi	h,tmpa		;clear quotient buffer
	xra	a
quinit:
	mov	m,a
	inx	h
	dcr	b
	jnz	quinit

	mvi	a,64
	sta	lcnt		;initialize loop counter
divloop:
	lxi	h,tmpa
	mvi	b,16
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

	mvi	b,8
	lxi	d,tmpb
	lxi	h,tmpc
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
	lxi	h,tmpa
	inr	m
	lxi	h,lcnt
	dcr	m
	jnz	divloop
	jmp	divdone
;
zerobit:
	lxi	h,lcnt
	dcr	m
	jz	divdone
	lxi	h,tmpa
	mvi	b,16
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
	mvi	b,8
	lxi	d,tmpb
	lxi	h,tmpc
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
divdone:
	lhld	flprm
	lxi	d,12
	dad	d
	mvi	m,0
	dcx	h
	mvi	m,0
	lxi	d,tmpa
	mvi	b,8
qusav:
	dcx	h
	ldax	d
	mov	m,a
	inx	d
	dcr	b
	jnz	qusav
	jmp	normalize
;
	public	.dml
.dml:		;double floating multiply	(primary = primary * secondary)
	push	b
	lhld	flprm
	xchg
	lhld	flsec
	ldax	d
	xra	m		;compute sign of result
	stax	d		;and store
	inx	h
	inx	d
	ldax	d		;primary exponent
	cpi	-64
	jz	zresult
	add	m		;eu+ev
	stax	d		;save exponent
	mov	a,m		;check for mult by zero
	cpi	-64
	jz	zresult

	push	d		;save for later
	lxi	d,9
	dad	d		;compute end address
	mvi	b,8
	lxi	d,tmpc		;copy muliplicand into work area
msav1:
	mov	a,m
	stax	d
	dcx	h
	inx	d
	dcr	b
	jnz	msav1
	pop	h	;restore multiplier addr
	lxi	d,9
	dad	d	;move backwards
	mvi	b,8
	lxi	d,tmpb	;copy multiplier into work area
msav2:
	mov	a,m
	stax	d
	dcx	h
	inx	d
	dcr	b
	jnz	msav2
	mvi	b,8
	lxi	h,tmpa		;clear buffer
	xra	a
clrmul:
	mov	m,a
	inx	h
	dcr	b
	jnz	clrmul

	mvi	a,64
	sta	lcnt		;initialize loop counter
muloop:
	lxi	h,tmpa
	mvi	b,16
	ora	a		;clear carry
mshlp:
	mov	a,m
	adc	a		;shift one bit to the left
	mov	m,a
	inx	h
	dcr	b
	jnz	mshlp
	jnc	mnext

	mvi	b,8
	lxi	d,tmpa
	lxi	h,tmpc
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
	mvi	b,8
madclp:
	ldax	d
	aci	0
	stax	d
	jnc	mnext
	inx	d
	dcr	b
	jnz	madclp
;
mnext:
	lxi	h,lcnt
	dcr	m
	jnz	muloop

	lhld	flprm
	lxi	d,12
	dad	d
	lxi	d,tmpb-2
	mvi	b,10
msav:
	ldax	d
	mov	m,a
	inx	d
	dcx	h
	dcr	b
	jnz	msav
	jmp	normalize
;
;
	public .deq
.deq:
	call	.dcmp
	jz	true
false:
	lxi	h,0
	xra	a
	ret
;
	public .dne
.dne:
	call	.dcmp
	jz	false
true:
	lxi	h,1
	xra	a
	inr	a
	ret
;
	public .dlt
.dlt:
	call	.dcmp
	jm	true
	jmp	false
;
	public .dle
.dle:
	call	.dcmp
	jm	true
	jz	true
	jmp	false
;
	public .dge
.dge:
	call	.dcmp
	jm	false
	jmp	true
;
	public .dgt
.dgt:
	call	.dcmp
	jm	false
	jz	false
	jmp	true
;
	public	.utod
.utod:
	push	b
	mov	a,h
	ora	l
	jz	zresult
	xchg
	mvi	b,0
	jmp	posconv
;
	public	.itod
.itod:
	push	b
	mov	a,h
	ora	l
	jz	zresult
	xchg
	mvi	b,0
	mov	a,d
	ora	a
	jp	posconv
	cma
	mov	d,a
	mov	a,e
	cma
	mov	e,a
	inx	d
	mvi	b,80H
posconv:
	lhld	flprm
	mov	m,b		;store sign
	inx	h
	mov	a,d
	ora	a
	jnz	longcvt
	mvi	m,1		;set up exponent
	inx	h
	mvi	m,0		;clear extra byte
	inx	h
	mov	m,e		;move number into accumulator
	mvi	b,7
	xra	a
	jmp	cnvlp
;
longcvt:
	mvi	m,2		;setup exponent
	inx	h
	mvi	m,0		;clear extra byte
	inx	h
	mov	m,d		;move number into accumulator
	inx	h
	mov	m,e
	mvi	b,6
	xra	a
cnvlp:
	inx	h
	mov	m,a
	dcr	b
	jnz	cnvlp
	jmp	goodexit
;
dornd:		; round the number in the primary accumulator
	lhld	flprm
	lxi	d,10		;offset of guard byte
	dad	d
	mov	a,m
	cpi	128
	rc			; < 128 do nothing
	jnz	rndit
	dcx	h		; == 128 make number odd
	mov	a,m
	ori	1
	mov	m,a
	ret
;
rndit:				; > 128 add one to fraction
	push	b
	lxi	b,0800H		;b = 8, and c = 0
	stc			; make loop add 1
rndlp:
	dcx	h
	mov	a,m
	adc	c
	mov	m,a
	dcr	b
	jnz	rndlp
	ora	a		;check for fraction overflow
	jnz	normalize	;re-normalize number if so.
	pop	b
	ret			;return if none
;
normalize:
	lhld	flprm		;get address of accum
	inx	h
	mov	a,m		;fetch exponent

	mov	d,h		;save address for later
	mov	e,l
	inx	h
	mov	c,a
	xra	a
	cmp	m		;check extra byte
	jnz	movrgt		;non-zero move number right

	mvi	b,8		;search up to 8 bytes
nloop:
	inx	h
	cmp	m
	jnz	movleft
	dcr	c		;adjust exponent
	dcr	b		;count times thru
	jnz	nloop
			;zero answer
zresult:
	xra	a
	sta	flterr_
under0:
	lhld	flprm
	mvi	b,10
	mov	m,a
	inx	h
	mvi	m,-64		;so exponent will be zero after store
zclr:
	inx	h
	mov	m,a
	dcr	b
	jnz	zclr
	pop	b
	ret
;
movleft:
	mvi	a,8
	sub	b
	mov	b,a
	jz	chkexp		;no change in counter, no move needed
	dcx	h		;back up to zero
	mov	a,c
	stax	d		;save new exponent
	push	d		;save for rounding
	inx	d
	mvi	a,15
	sub	b		;compute # of bytes to move
	mov	c,a		;save for loop
lmovlp:
	mov	a,m
	stax	d
	inx	d
	inx	h
	dcr	c
	jnz	lmovlp
	xra	a
lclrlp:
	stax	d		;pad with zeros
	inx	d
	dcr	b
	jnz	lclrlp
	pop	d		;restore accum address
;
chkexp:			;check for over/under flow
	ldax	d		;get exponent
	ora	a
	jm	chkunder
	cpi	64
	jc	goodexit
	jmp	overflow
;
chkunder:
	cpi	-63
	jc	underflow
goodexit:
	mvi	a,0
	sta	flterr_
	pop	b
	ret
;
movrgt:			;fraction overflow
	inr	c		;bump exponent
	mov	a,c
	stax	d		;save in accum
	mvi	b,15
	push	d		;save for check at end
	lxi	h,16
	dad	d		;end address for backwards move
	mov	d,h
	mov	e,l
rmovlp:
	dcx	d
	ldax	d
	mov	m,a
	dcx	h
	dcr	b
	jnz	rmovlp
	mvi	m,0		;zap overflow byte back to zero
	pop	d		;restore exponent addr
	jmp	chkexp
;
underflow:
	mvi	a,1
	sta	flterr_
	call	userrtn		;check for user routine to handle errors
	xra	a
	lhld	flprm
	inx	h			;leave sign alone
	mvi	m,-63		;set to smallest non-zero value
	inx	h
	mov	m,a
	inx	h
	mvi	m,1
	mvi	b,8
	jmp	zclr		;clear rest to zero
;
overflow:
	mvi	a,2
	sta	flterr_
setbig:
	call	userrtn		;check for user routine to handle errors
	lhld	flprm
	inx	h		;leave sign alone
	mvi	m,63		;set exponent at max
	inx	h
	mvi	m,0		;clear overflow byte
	mvi	a,0ffH		;and set fraction to max
	mvi	b,7
oclr:
	inx	h
	mov	m,a
	dcr	b
	jnz	oclr
	inx	h
	mvi	m,0
	pop	b
	ret
;
userrtn:		;handle messages
	lhld	Sysvec_	;any routine supplied?
	mov	a,h
	ora	l
	jz	myway
	xchg
	lxi	h,4
	dad	sp
	mov 	c,m
	inx	h
	mov	b,m
	push	b
	lhld	flterr_
	push	h
	xchg
	call	apchl
	pop	h
	pop	h	;clean up arguments
	ret
apchl:
	pchl
;
myway:
	call	pmsg
	db	'Floating point ',0
	lda	flterr_
	cpi	1
	jnz	notund
	call	pmsg
	db	'underflow',0
	jmp	mycontinue
notund:	cpi	2
	jnz	notovr
	call	pmsg
	db	'overflow',0
	jmp	mycontinue
notovr: call	pmsg
	db	'divide by zero',0
mycontinue:
	call	pmsg
	db	' at location 0x',0
	lxi	h,5
	dad	sp
	mov	a,m
	push	h
	push	psw
	call	phex2
	pop	psw
	call	phex
	pop	h
	dcx	h
	mov	a,m
	push	psw
	call	phex2
	pop	psw
	call	phex
	lxi	h,10		;newline
	push	h
	call	puterr_
	pop	h
	ret
;
phex2:
	rar
	rar
	rar
	rar
phex:
	ani	15
	adi	'0'
	cpi	'9'+1
	jc	hexok
	adi	'A'-'0'-10
hexok:
	mov	l,a
	mvi	h,0
	push	h
	call	puterr_
	pop	h
	ret
;
pmsg:
	pop	b		;get address of message
pmloop:
	ldax	b
	inx	b
	ora	a
	jz	pmsgdone
	mov	l,a
	mvi	h,0
	push	h
	call	puterr_
	pop	h
	jmp	pmloop
pmsgdone:
	push	b
	ret
;
	public	.xtod
.xtod:
	push	b
	lhld	flprm
	mvi	m,0		;clear sign
	inx	h
	mvi	m,3		;set up exponent
	lxi	d,4
	dad	d
	mov	e,l
	mov	d,h
	mvi	b,5
	xra	a
xtodclr:
	inx	h
	mov	m,a
	dcr	b
	jnz	xtodclr
;
	mvi	b,4
	lxi	h,lnprm
	lda	lnprm+3
	ora	a
	jp	lngok
;
lngloop:
	mvi	a,0
	sbb	m
	stax	d
	inx	h
	dcx	d
	dcr	b
	jnz	lngloop
	dcx	d		;back up to sign field
	mvi	a,080H		;mark as negative
	stax	d
	jmp	normalize
;
lngok:
	mov	a,m
	stax	d
	inx	h
	dcx	d
	dcr	b
	jnz	lngok
	jmp	normalize
;
	public	.dtox
.dtox:
	push	b
	lxi	h,0
	shld	lnprm
	shld	lnprm+2
	lxi	d,lnprm
;
	lhld	flprm
	mov	c,m		;get sign
	inx	h
	mov	a,m		;get exponent
	ora	a
	jz	goodexit	; |x| < 1.0 so return zero
	jm	goodexit
;
	cpi	5		;check for too big
	jnc	ltoobig
;
	mov	b,a		;save byte count
	inx	h		;skip overflow byte
	add	l
	mov	l,a
	jnc	lxx
	inr	h
lxx:
	mov	a,m
	stax	d
	inx	d
	dcx	h
	dcr	b
	jnz	lxx
;
	mov	a,c		;now check sign
	ora	a
	jp	goodexit
	mvi	b,4
	lxi	h,lnprm
d2xneg:
	mvi	a,0
	sbb	m
	mov	m,a
	inx	h
	dcr	b
	jnz	d2xneg
	jmp	goodexit
;
ltoobig:
	xchg
	mov	a,c
	ora	a
	jm	bigneg
	mvi	m,07fH
	inx	h
	mvi	m,0ffH
	inx	h
	mvi	m,0ffH
	inx	h
	mvi	m,0ffH
	jmp	oflow
bigneg:
	mvi	m,080H
	inx	h
	mvi	m,0
	inx	h
	mvi	m,0
	inx	h
	mvi	m,0
	jmp	oflow
;
;
	public	.dtou
.dtou:
	push	b
	mvi	c,0		;flag as dtou
	jmp	ifix
;
	public	.dtoi
.dtoi:
	push	b
	mvi	c,1		;flag as dtoi
ifix:
	lhld	flprm
	mov	b,m		;get sign
	inx	h
	mov	a,m		;get exponent
	ora	a
	jz	zeroint
	jp	nonzero
zeroint:
	lxi	h,0		; |x| < 1.0 so return zero
	jmp	goodexit
;
nonzero:
	cpi	3		;check for too big
	jnc	toobig
;
	inx	h		;skip overflow byte
	add	l
	mov	l,a
	jnc	xx
	inr	h
xx:	mov	e,m
	dcx	h
	mov	d,m
	xchg
	mov	a,c
	ora	a
	jz	goodexit
	mov	a,b
	ora	a
	jp	goodexit
	mov	a,h
	cma
	mov	h,a
	mov	a,l
	cma
	mov	l,a
	inx	h
	jmp	goodexit
;
toobig:
	mov	a,c
	ora	a
	jnz	bigsigned
	lxi	h,0ffffH		;return largest unsigned #
	jmp	oflow
;
bigsigned:
	mov	a,b
	ora	a
	jm	negover
	lxi	h,7fffH			;return largest positive #
	jmp	oflow
;
negover:
	lxi	h,8000H			;return largest negative #
oflow:
	mvi	a,2
	sta	flterr_
	pop	b
	ret
;
	public	fabs_
fabs_:
	lhld	flprm
	mvi	m,0		;force to positive sign
	ret
;
	public	.dml10
.dml10:
	push	b
	lhld	flprm
	inx	h
	inr	m			;adjust exponent
	lxi	d,9
	dad	d
	xra	a
	mvi	b,8
ml10lp:
	push	b
	mov	e,m
	xchg
	mvi	h,0
	dad	h		;num*2
	mov	b,h
	mov	c,l		;save
	dad	h		;num*4
	dad	h		;num*8
	dad	b		;num*10
	xchg
	add	e
	inx	h
	mov	m,a
	mov	a,d
	aci	0
	dcx	h
	dcx	h
	pop	b
	dcr	b
	jnz	ml10lp
	inx	h
	mov	m,a		;save last byte of result
	ora	a
	jz	normalize
	dcx	h
	dcx	h		;back up to exponent
	mov	a,m		;check to be sure no overflow
	ora	a
	jm	m10ok
	cpi	64
	jnc	overflow
m10ok:
	pop	b
	ret
	end
