;Copyright (C) 1983 by Manx Software Systems
; :ts=8
;
;	stksize should be set according to your program's needs
;
stksize	equ	1024
	bss	stack,stksize

	extrn	main_
	extrn	_Corg_, _Cend_
	extrn	_Dorg_, _Dend_
	extrn	_Uorg_, _Uend_
;	
;	The 3 "bss" statements below must remain in EXACTLY the same order,
;	with no intervening statements!
;
	public	lnprm, lntmp, lnsec
	bss	lnprm,4
	bss	lntmp,4
	bss	lnsec,4
;
	global	errno_,2
	dseg
	public	Sysvec_
Sysvec_:	dw	0
	dw	0
	dw	0
	dw	0
	public	$MEMRY
$MEMRY:	dw	0ffffh
	cseg
	public	.begin
.begin:
	di
	lxi	sp,stack+stksize
;
;	The loop below moves the initialized data from ROM to RAM.
;	If your program has no initialized data, or the initialized
;	data isn't modified, then delete this loop.
;
	lxi	h,_Cend_
	lxi	d,_Dorg_
	lxi	b,_Dend_-_Dorg_
	mov	a,h
	cmp	d
	jnz	movedata
	mov	a,l
	cmp	e
	jz	movedone
movedata:
;	If your processor is a Z80, then remove the comment from the
;	next line and comment out the next 8 lines.
;	db	237,176		;ldir
	mov	a,m
	stax	d
	inx	h
	inx	d
	dcx	b
	mov	a,c
	ora	b
	jnz	movedata
movedone:
;
	lxi	h,_Uorg_
	lxi	b,_Uend_-_Uorg_
	mvi	e,0
clrbss:
	mov	m,e
	inx	h
	dcx	b
	mov	a,c
	ora	b
	jnz	clrbss
;
	ei
				;no argc,argv in ROM system
	jmp	main_		;main shouldn't return in ROM based system
	end	.begin
