; Copyright (C) 1983, 1984 by Manx Software Systems
; :ts=8
	public	.ovbgn, ovexit_
	extrn	ovmain_
	extrn	_Uorg_, _Uend_
	bss	ovstkpt,2
	bss	saveret,2
	bss	bcsave,2
	bss	ixsave,2
	bss	iysave,2
;
.ovbgn:
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
	mov	h,b
	mov	l,c
	shld	bcsave
	xra	a
	adi	3
	jpe	savedone
	db	221
	shld	ixsave
	db	253
	shld	iysave
savedone:
	pop	h
	shld	saveret
	pop	d
	lxi	h,0
	dad	sp
	shld	ovstkpt		;save stack pointer for ovexit
	call	ovmain_
	xchg			;save return value
ovret:
	lhld	saveret		;get return addr
	push	h		;place dummy overlay name ptr on stack
	push	h		;place return addr on stack
	xchg			;restore return value to hl
	ret			;return to caller
;
ovexit_:
	lhld	bcsave
	mov	b,h
	mov	c,l
	xra	a
	adi	3
	jpe	restdone
	db	221
	lhld	ixsave
	db	253
	lhld	iysave
restdone:
	lxi	h,2		;get return value
	dad	sp
	mov	e,m
	inx	h
	mov	d,m
	lhld	ovstkpt		;restore original stack pointer
	sphl
	jmp	ovret
	end	.ovbgn
