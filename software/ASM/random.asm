;----------------------------------------------------------------
;         This is a module in the ASMLIB Library.
;
; This module generates PSEUDO RANDOM NUMBERS by using a seed array
; and doing adds and shifts on the bytes in the array. The returned
; value from the function is in the accumulator.
;
; The entry points are as follows.
;
; 
;
; randinit
; rand8
; rand16
; randp16
;
;			Written		R.C.H.         12/10/83
;			Last Update     R.C.H.         13/10/83
;----------------------------------------------------------------
;
	name	'random'
	public	rand8,rand16,randp16,randinit
	maclib	z80
;
randinit:
	ldax	d
	cpi	5
	rc			; Error if less than 5 elements in the array
	push	d
	push	b
	mov	b,a		; Load counter
	xchg
	inx	h		; Now HL -> first seed byte
	ldar			; Get refresh register value
	dcr	b		; Do one less than the required
initloop:
	add	m
	rrc
	mov	m,a
	inr	m
	mov	a,m
	inx	h
	djnz	initloop
; Restore and exit gracefully
	xchg			; Restore HL
	pop	b
	pop	d		; Restore other registers
	ret
;
; Return an 8 bit random number in A
;
rand8:	
	ldax	d		; A = number of seeds
	cpi	5		; Check if less than 5 seed values
	rc			; Return with a carry to indicate an error
; Here we load the number of cells into B then decrtement so as to skip
; these which are operated on later.
	push	b
	push	d		; Saver address of seed array
	mov	b,a
	dcr	b
	dcr	b
	inx	d		; DE -> first seed in the array
	xchg			; Put memory pointer into HL
;
;Loop for N-2 times.
loop:	inr	m		;INCREMENT SEED VALUE.
	mov	a,m
	inx	h		;HL POINTS TO NEXT SEED VALUE IN ARRAY.
	add	m
	rrc			;ROTATE RIGHT CIRCULAR ACCUMULATOR.
	mov	m,a
	djnz	loop
;
; Last iteration to compute random byte in register a.
	inx	h 		; HL -> last byte in the array
	add	m
	cma			; complement the accumulator
	rrc			; rotate it right
	mov	m,a
	xra	a		; Clear carry
	mov	a,m		; Re-load value, carry not set.
;
; Restore the registers and return with the value in A
ERROR:	
	xchg			; Restore HL
	pop	d
	pop	b
	ret
;
; Return a 16 bit random number in HL.
;
rand16:
	call	rand8
	mov	h,a		; msb byte
	call	rand8
	mov	l,a		; lsb byte
	ret
;
; Return a positive 16 bit random number
;
randp16:
	call	rand16
	mov	a,h
	ani	07fh		; Mask off top bit
	mov	h,a		; restore
	mov	a,l		; echo lsb in a
	ret
;
	end



