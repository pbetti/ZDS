;----------------------------------------------------------------
;       This is a module in the ASMLIB library			-
; The following two routines are extracted from page 144 & 145  -
; of Electronics International February 24 1982.		-
;  The first routine is a 32-by-16 bit division and the second  -
; routine is a 16-16 bit multiply. The 16-16 multiply also has  -
; a very fast 8-by-16 multiply routine. The register set-ups    -
; are as follows,						-
; 								-
; Division:	dividend in hl-de , divisor in bc		-
;		quotient in de , remainder in hl		-
;		overflow indicated by a carry			-
;								-
; Multiplication:						-
; for 16 * 16	multiplicand in bc , multiplier in de		-
;		result in de-hl					-
;
;			Written     	R.C.H.     16/8/83
;			Last Update	R.C.H.	   16/8/83
;----------------------------------------------------------------
;
	name	'divdh'
;
	public	divdh
	maclib	z80
;
divdh:		; 32 bits / 16 bits
	mov	a,l		; check for overflow
	sub	c
	mov	a,h
	sbb	b
	rnc			; bad boy
;
	mov	a,b
	cma			; do a 2's complement on divisor
	mov	b,a
	mov	a,c
	cma
	mov	c,a		; all done
	inx	b		; why why why
	call	loop		; divide highest-order 3 bytes of dividend
; loop divides 3 byte dividend by 2 byte divisor
loop:
	mov	a,d		; load third byte to be divided
	mov	d,e		; save low order dividend / hi order byte q.
	mvi	e,8
loop1:
	dad	h		; shift dividend left.
	jrc	over		; jump if dividend overflowed
	add	a
	jrnc	sub1
	inx	h		; fix up carry condition
sub1:	
	push	h		; save high ord 2 of dividend
	dad	b		; subtract divisor
	jrc	ok		; jump if no borrow
	pop	h		; unsubtract if borrow
	dcr	e		; loop counter
	jrnz	loop1
	mov	e,a		; put quotient into e
	stc
	ret
;
ok:
	inx	sp
	inx	sp		; clean stack up
	inr	a		; put 1 in quotient
	dcr	e		; update loop 1 counter
	jrnz	loop1
	mov	e,a		; same as above
	stc
	ret
;
over:
	adc	a		; finish shift, put 1 in quotient
	jrnc	oversub
	inx	h
oversub:
	dad	b
	dcr	e
	jrnz	loop1
	mov	e,a
	stc
	ret
;
	end

