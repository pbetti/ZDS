;Copyright (C) 1983 by Manx Software Systems
; :ts=8
	public movmem_		;movmem(src,dst,len)
movmem_:
	push	b
	lxi	h,9
	dad	sp
	mov	b,m			;BC=len
	dcx	h
	mov	c,m
	dcx	h
	mov	d,m			;DE=dst
	dcx	h
	mov	e,m
	dcx	h
	mov	a,m
	dcx	h
	mov	l,m			;HL=src
	mov	h,a
	cmp	d
	jc	movedown
	jnz	moveup
	mov	a,l
	cmp	e
	jc	movedown
	jz	done
moveup:				;src > dst
	dad	b
	xchg
	dad	b
	xra	a
	adi	3		;test if z80
	jpe	uploop		;not z80 use loop to move data
	xchg
	dcx	d
	dcx	h
	db	237,184		;lddr
	pop	b
	ret
;
uploop:			;HL=dst, DE=src
	dcx	d
	dcx	h
	ldax	d
	mov	m,a
	dcx	b
	mov	a,b
	ora	c
	jnz	uploop
	pop	b
	ret
;
movedown:			;src < dst
	xra	a
	adi	3		;test if z80
	jpe	downloop	;not z80 use loop to move data
	db	237,176		;ldir
	pop	b
	ret
;
downloop:
	mov	a,m
	stax	d
	inx	d
	inx	h
	dcx	b
	mov	a,b
	ora	c
	jnz	downloop
done:
	pop	b
	ret
	end
