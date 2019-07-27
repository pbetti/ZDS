;----------------------------------------------------------------
;      This is a module in the ASMLIB library
;
; Convert the BCD digits -> by DE into a hex digit in HL
;
;			Written     	R.C.H.     16/8/83
;			Last Update	R.C.H.	   16/8/83
;----------------------------------------------------------------
;
	name	'bcdhex'
;
	public	bcdhex
	maclib	z80
;
bcdhex:
	push	b			; save as this is used as a counter
	lxi	h,00			; initialize result accumulator
	mvi	b,3			; 3 bytes = 6 digits
;
bcdhex1:
	ldax	d			; get the 2 digits
	rar
	rar
	rar
	rar				; put top digit into lower
	ani	0fh			; mask off top digit
; Check if it is in range if a bcd digit ?
	cpi	9+1
	jrnc	bcdhex$end		; all done then
;
	call	mult$hl$10		; do hl = hl * 10
	ldax	d			; get the digit again
	ani	0fh			; mask off top 4 bits
	cpi	9+1			; legal
	jrnc	bcdhex$end		; skip iff so
	call	mult$hl$10
	inx	d			; point to next digit
	djnz	bcdhex1			; do all 3 digits
; Restore bc then return, all is done
bcdhex$end:
	pop	b
	ret
;
mult$hl$10:	; Multiply HL by 10 and mask in accumulator
	push	d			; save DE
;
	push	h			; make a copy of HL
	pop	d			; copy result into DE as well as hl
	dad	h			; result = result * 2
	dad	h			;		    4
	dad	d			;		    5
	dad	h			;		   10
	ora	l			; mask in L to A
	mov	l,a			; put back
	pop	d			; restore DE
	ret
;
	end

