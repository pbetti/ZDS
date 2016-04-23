;----------------------------------------------------------------
;         This is a module in the ASMLIB library
;
; 	Square Root Algorithm Uses Newton Iteration Method	 
; 	Based on a 10 loop pass for full 16 bit accuracy	 
; 	Formula based on is Newguess=(x/oldguess+oldguess)/2	 
; 								 
; 	Takes an Unsigned 16 Bit integer input			 
; 	produces a 16 bit result 				 
; 								 
; 		Written By Steve Sparrow			 
; 	Copyright (c) 1980, SME Systems Melbourne		 
; 								 
; 	Enter with DE = Number to Take Square Root of		 
; 	Exit with  HL = Result					 
; 								 
; 								 
; Modification  				Who	Date
; ------------                                  ---------------
; Modified for Z80			        S.S.    23/8/83
; To suit the ASMLIB library and rmac.		R.C.H.  27/8/83
; 								 
;----------------------------------------------------------------
;
	name	'sqrt'
	public	sqrt
	maclib	z80
;
sqrt:	xchg				; load value into DE from HL
	mvi	a,10			; perform 10 iterations
	lxi	d,1			; smallest guess initially
sqr1:	push	psw			; save iteration count
	push	h			; save x
	push	d			; save guess1
	call	div16			; hl = x / guess
	pop	d
	dad	d			; hl = x / guess + guess
	ora	a
	mov	a,h
	rar
	mov	h,a			; shift result right (hl/2)
	mov	a,l
	rar
	mov	l,a			; hl = x / guess + guess
	xchg				; de gets new guess
	pop	h			; restore x
	pop	psw			; get iteration counter
	dcr	a
	jnz	sqr1			; loop if not done
	mov	a,e			; e has low result
	xchg				; result in hl, remainder in de
	ret
;
;****************************************************************
;*	16 By 16 Bit Unsigned Divide routine By S Sparrow	*
;*	HL=Dividend  DE=Divisor					*
;*	Uses the Non Restoring Method during calculation	*
;*	exit with h = quotient l = remainder 			*
;****************************************************************
;
div16:	mov	a,h
	mov	c,l			; a and c gets dividend
	mvi	b,16			; 16 bit counter
	lxi	h,0
;
div16a:	ralr	c			; left shift reg c
	ral				; shift in carry
	dadc	h			; left shift 
	dsbc	d			; trial subtraction
	jrnc	div16b			; skip if no carry
	dad	d			; restore accum
div16b:	cmc				; calculate result bit
	djnz	div16a			; loop for 16 bits
	ralr	c			; shift result left
	ral
	mov	h,a			; copy result to hl
	mov	l,c
	ret
;
	end
;
