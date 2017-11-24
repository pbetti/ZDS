; Copyright (C) 1982, 1983 by Manx Software Systems
; :ts=8
	extrn	.dldp, .dlds, .utod, .dlis, .dswap, .dtst
	extrn	.dng, .dlt, .dge, .dad, .ddv, .dml10
	extrn	flprm
	dseg
chrptr:	ds	2
maxdig:	ds	1
ndig:	ds	2
exp:	ds	2
count:	ds	1
fflag:	ds	1
	cseg
rounding:
;	0.5,
	DB 040H,080H,00H,00H,00H,00H,00H,00H
;	0.05,
	DB 040H,0CH,0CCH,0CCH,0CCH,0CCH,0CCH,0CDH
;	0.005,
	DB 040H,01H,047H,0AEH,014H,07AH,0E1H,048H
;	0.0005,
	DB 03FH,020H,0C4H,09BH,0A5H,0E3H,054H,00H
;	0.00005,
	DB 03FH,03H,046H,0DCH,05DH,063H,088H,066H
;	0.000005,
	DB 03EH,053H,0E2H,0D6H,023H,08DH,0A3H,0CDH
;	0.0000005,
	DB 03EH,08H,063H,07BH,0D0H,05AH,0F6H,0C8H
;	0.00000005,
	DB 03DH,0D6H,0BFH,094H,0D5H,0E5H,07AH,066H
;	0.000000005,
	DB 03DH,015H,079H,08EH,0E2H,030H,08CH,03DH
;	0.0000000005,
	DB 03DH,02H,025H,0C1H,07DH,04H,0DAH,0D3H
;	0.00000000005,
	DB 03CH,036H,0F9H,0BFH,0B3H,0AFH,07BH,080H
;	0.000000000005,
	DB 03CH,05H,07FH,05FH,0F8H,05EH,059H,026H
;	0.0000000000005,
	DB 03BH,08CH,0BCH,0CCH,09H,06FH,050H,09AH
;	0.00000000000005,
	DB 03BH,0EH,012H,0E1H,034H,024H,0BBH,043H
;	0.000000000000005,
	DB 03BH,01H,068H,049H,0B8H,06AH,012H,0BAH
;
;
	public ftoa_
ftoa_:
	push	b
	lxi	h,12
	dad	sp
	mov	e,m
	inx	h
	mov	d,m
	xchg
	shld	chrptr		;buffer for converted data
	lxi	h,16
	dad	sp
	mov	a,m
	sta	fflag		;e/f/g format flag
;
	lxi	h,4
	dad	sp
	call	.dldp		;fetch number to convert
	lxi	h,14
	dad	sp
	mov	a,m		;fetch precision
	sta	maxdig
	inr	a
	mov	l,a
	mvi	h,0
	shld	ndig
;
	lhld	flprm
	mov	a,m
	ora	a
	jp	notneg
	call	.dng
	lhld	chrptr
	mvi	m,'-'
	inx	h
	shld	chrptr
notneg:
	lxi	b,0		;clear integer exponent
	call	.dtst
	jz	numbok
	call	.dlis
	db	041H,0aH,0,0,0,0,0,0
adjust:
	lhld	flprm
	inx	h
	mov	a,m
	cpi	1
	jm	toosml
	jz	tentest
	cpi	2
	jnz	bignum
	inx	h
	inx	h
	mov	a,m
	cpi	27H		;number < 10000, just do divides
	jc	quick

bignum:
	call	inverse
	call	.dlis
	db	40H,19H,99H,99H,99H,99H,99H,9aH
bignlp:
	call	.dml10
	inx	b
	call	.dlt
	jnz	bignlp
	call	inverse
	lhld	flprm
	inx	h
	inx	h
	inx	h
	mov	a,m
	cpi	10
	jc	numbok
	dcx	b
	call	.dml10
	jmp	numbok
	
qcklp:
	lhld	flprm
	inx	h
	mov	a,m
	cpi	1
	jnz	quick
tentest:	
	inx	h
	inx	h
	mov	a,m
	cpi	10
	jc	numbok
quick:
	call	.ddv		;divide by ten till 1 <= number < 10
	inx	b		;count for exponent
	jmp	qcklp
	
sml.lp:
	lhld	flprm
	inx	h
	mov	a,m
	cpi	1
	jp	numbok
toosml:
	call	.dml10		;multiply by ten till 1 <= number < 10
	dcx	b		;count for exponent
	jmp	sml.lp
;
numbok:
	lda	fflag		;check conversion format
	ora	a
	jz	eformat
	cpi	1
	jz	fformat
	lda	maxdig		;if %g then precision is # sig. digits
	mov	l,a
	mvi	h,0
	shld	ndig
	mov	a,b		;select %f if maxdig > exp > -4, else use %e
	ora	a
	jm	chkm4
	mov	a,c
	cmp	l
	jnc	eformat
	mvi	a,1		;exp < maxdig, so use %f
	jmp	setformat
;
chkm4:
	mov	a,c
	cpi	-4
	jc	eformat		;exp < -4, so use %e
fformat:
	lhld	ndig
	dad	b
	shld	ndig
	mvi	a,1
	jmp	setformat
eformat:
	xra	a
setformat:
	sta	fflag
;		now round number according to the number of digits
	lhld	ndig
	dcx	h
	mov	a,h
	ora	a
	jp	L1
	lxi	h,0
	jmp	L5
L1:
	jnz	toomany
	mov	a,l
	cpi	14
	jc	L5
toomany:
	lxi	h,14
L5:
	dad	h		;*2
	dad	h		;*4
	dad	h		;*8
	lxi	d,rounding
	dad	d
	call	.dlds
	call	.dad		;add in rounding counstant
;
	call	.dlis
	db	041H,0aH,0,0,0,0,0,0
	call	.dge		;check for rounding overflow
	jz	rndok
	lxi	h,1
	call	.utod		;and repair if necessary
	inx	b
	lda	fflag
	ora	a
	jz	rndok
	lhld	ndig
	inx	h
	shld	ndig
rndok:
	mov	h,b
	mov	l,c
	shld	exp
	lda	fflag
	ora	a
	jz	unpack
	mov	a,b
	ora	a
	mov	a,c		;move for unpack
	jp	unpack
;				F format and negative exponent
;				put out leading zeros
	lhld	chrptr
	mvi	m,'0'
	inx	h
	mvi	m,'.'
	inx	h
	lda	ndig+1
	ora	a
	jm	under
	mov	a,c
	cma
	jmp	L2
under:
	lda	maxdig
L2:
	ora	a
	jz	zdone
zdiglp:
	mvi	m,'0'
	inx	h
	dcr	a
	jnz	zdiglp
zdone:
	shld	chrptr
	mvi	a,0ffH		;mark decpt already output
;
unpack:			;when we get here A has the position for the
			;decimal point
	mov	c,a			;save decimal point position
	lxi	h,ndig+1		;check if ndigits is <= zero
	mov	a,m
	ora	a
	jm	unpdone		;if so just quit now
	dcx	h
	ora	m
	jz	unpdone		;if so just quit now
	lhld	flprm
	lxi	d,10
	dad	d
	mvi	m,0		;zap guard bytes
	inx	h
	mvi	m,0
	mvi	b,0
unplp:
	mov	a,b
	cpi	15
	mvi	a,'0'
	jnc	zerodigit
	lhld	flprm
	inx	h		;skip sign byte
	mov	a,m
	cpi	1
	mvi	a,'0'
	jnz	zerodigit
	inx	h		;skip exponent
	inx	h		;skip overflow
	add	m
	mvi	m,0		;subtract integer portion (virtual)
zerodigit:
	lhld	chrptr
	mov	m,a
	inx	h
	shld	chrptr
	lxi	h,ndig
	dcr	m
	jz	unpdone
	mov	a,b
	cmp	c
	jnz	mul10
	lhld	chrptr
	mvi	m,'.'
	inx	h
	shld	chrptr
mul10:
	call	.dml10		;multiply by 10 and re-normalize
	inr	b
	jmp	unplp
;
unpdone:
	lda	fflag
	ora	a
	jnz	alldone
;
	lhld	chrptr
	mvi	m,'e'
	inx	h
	mvi	m,'+'
	lda	exp+1
	ora	a
	lda	exp
	jp	posexp
	mvi	m,'-'
	cma
	inr	a
posexp:
	inx	h
	cpi	100
	jc	lt100
	mvi	m,'1'
	inx	h
	sui	100
lt100:
	mvi	b,0
tens:
	cpi	10
	jc	lt10
	inr	b
	sui	10
	jmp	tens
lt10:
	adi	'0'		;ascii of last digit
	mov	e,a		;save last digit
	mvi	a,'0'
	add	b		;compute second digit
	mov	m,a
	inx	h
	mov	m,e
	inx	h
	shld	chrptr
;
alldone:
	lhld	chrptr
	mvi	m,0
	pop	b
	ret
;
inverse:
	call	.dswap
	lxi	h,1
	call	.utod
	jmp	.ddv			;implied return
;
	end
