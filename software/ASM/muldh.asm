;----------------------------------------------------------------
;        This is a module in the ASMLIB library
;
; The following is the multiplication routine.
; Multiplicand is in bc, multiplier in de , result is in dehl.
;
;			Written     	R.C.H.     16/8/83
;			Last Update	R.C.H.	   16/8/83
;----------------------------------------------------------------
;
	name	'muldh'
;
	public	muldh
	maclib	z80
;
muldh:
	mov	a,e		; load lowest order mult byte.
	push	d		; save high order byte
	call	bmult		; do a 1 byte multiply
	xthl			; save low order products
	push	psw		; save high ord. 1'st product
	mov	a,h		; load high order multiplier byte
	call	bmult		; do second byte multiply
	mov	d,a		; position high order product
	pop	psw
	add	h		; update 3'rd byte of product
	mov	e,a		; put into e
	jrnc	nc1		; skip increment if no carry
	inr	d
nc1:
	mov	h,l		; relocate first product
	mvi	l,0		; clear
	pop	b		; low order 2 bytes of product
	dad	b
	rnc			; done if no carry
	inx	d
	ret
;
;This routine multiplies a * bc --> a-hl
;
bmult:
	lxi	h,0
	lxi	d,7		; d = 0 , e = 7 which is a loop counter
	add	a		; get first multiplier bit
loop2:
	jrnc	zero		; zero skip
	dad	b
	adc	d
zero:
	dad	h
	adc	a
	dcr	e		; decrement loop counter
	jrnz	loop2
	rnc
	dad	b
	adc	d
	ret
	end


