; Copyright (C) 1983 by Manx Software Systems
; :ts=8
BDOS	equ	5
	extrn	.asave,.ARG1,.ARG2,.ARG3
	dseg
oldusr:	db	0
	cseg
	public getusr_
getusr_:
	call	.asave
	mvi	c,32
	mvi	e,255
	call	BDOS		;get current user #
	mov	l,a
	mvi	h,0
	ora	a
	ret
;
	public setusr_
setusr_:
	call	.asave
	mvi	c,32
	mvi	e,255
	call	BDOS
	sta	oldusr
	lda	.ARG1
	cpi	255
	rz
	mvi	c,32
	mov	e,a
	jmp	BDOS	;set new user number
;
	public	rstusr_
rstusr_:
	call	.asave
	mvi	c,32
	lda	oldusr
	mov	e,a
	jmp	BDOS	;restore old user number
	end
