; Copyright (C) 1983 by Manx Software Systems
; :ts=8
	public	.ovbgn
	extrn	main_
	extrn	_Uorg_, _Uend_
	bss	saveret,2
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
	pop	h
	shld	saveret
	call	main_
	lhld	saveret		;get return addr
	pchl			;return to caller
	end	.ovbgn
