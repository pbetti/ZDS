;----------------------------------------------------------------
;        This is a module in the ASMLIB library
;
;      Print the accumulator as a pair of HEX digits.
; This routine uses the convert nibble routine (later) then uses
; the LZB information flag to decode how to print the bytes.
;
;			Written     	R.C.H.     16/8/83
;			Last Update	R.C.H.	   31/12/83
;----------------------------------------------------------------
;
	name	'pacc'
;
	public	phacc,pdacc,nibasc
	public	?phacc2,?pdacc2,?clrblank
	extrn	?result,hexbcd,dispatch,?lzprint,?blank
;
phacc:
	call	?clrblank
?phacc2:
	push	psw			; save
	rar
	rar
	rar
	rar				; load right libble into low byte
	call	nibasc			; convert to ascii in A
	call	?lzprint
	pop	psw			; restore character to be printed
	ani	0fh
	call	nibasc
	jmp	dispatch		; print regardless of LZB as last digit
;
;----------------------------------------------------------------
;     Print the accumulator as three decimal digits.
;----------------------------------------------------------------
;
pdacc:
	call	?clrblank
	push	h
	push	d			; save
	mov	e,a			; load digit
	mvi	d,0			; clear upper digit
	lxi	h,?result		; point to buffer for bcd result
	call	hexbcd			; do the conversion from hex to bcd
; Now print the correct 3 digits in the 10 digit buffer
	lda	?result+1		; this gets top digit
	call	nibasc			; convert lower nibble in acc to ascii
	call	?lzprint
?pdacc2:	; Jump here to print two bytes at result in correct bcd order
	lda	?result+0		; get the two lower bytes
	call	?phacc2			; send it via Print Hex Digits
	pop	d			; restore bytes
	pop	h
	ret
;
;----------------------------------------------------------------
; Clear the byte called blank to 00. This indicates a new number
; in progress. This is used by many of the number printing routines.
;----------------------------------------------------------------
;
?clrblank:
	push	psw
	xra	a
	sta	?blank
	pop	psw
	ret
;
;----------------------------------------------------------------
; Convert the low nibble in A to ascii also in A
;----------------------------------------------------------------
;
nibasc:
	ani	0fh			; mask of any possible top bits
	adi	090h			; add offset
	daa
	aci	040h			; add again to make ascii
	daa				; final adjust.
	ret
;
	end

