;----------------------------------------------------------------
;       This is a module in the ASMLIB library
;
; Convert a HEX number to BCD. The BCD number is --> by HL in ram
;
;			Written     	R.C.H.     16/08/83
;			Last Update	R.C.H.	   31/12/83
;----------------------------------------------------------------
;
	name	'hexbcd'
;
	public	hexbcd
	extrn	?binnum
	maclib	z80
;
hexbcd:
	sded	?binnum			; save the number to convert
	push	b
	push	h
; Do the conversion
	mvi	b,3			; 3 bytes to clear
hexbcd1:
	mvi	m,00
	inx	h
	djnz	hexbcd1			; clear 3 bytes
;
	mvi	b,16			; 16 bits to convert
cloop:
	lxi	h,?binnum
	mvi	c,2			; bytes in the binary number
	xra	a			; clear carry
rloop:
	mov	a,m
	ral
	mov	m,a
	inx	h
	dcr	c
	jnz	rloop			; keep rotating till C = 0
;
	pop	h
	push	h			; restore the result address
	mvi	c,3			; 3 byte result = 6 digits
;
bloop:
	mov	a,m
	adc	m
	daa
	mov	m,a			; save
	inx	h
	dcr	c
	jnz	bloop
;
	djnz	cloop			; do for all bits requited.
;
	pop	h
	pop	b			; clear stack
	ret			; trick code here boys
	end





