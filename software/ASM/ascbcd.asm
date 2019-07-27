;----------------------------------------------------------------
;         This is a module in the ASMLIB library. 
;
; Convert the ascii characters -> by DE into a BCD number in HL.
; On exit DE -> the byte that caused the end of the conversion and 
; A also contains the byte. This routine is extremely useful for
; converting numbers in console buffers into numbers in HL.
; Note that if the first character that is read is a minus sign
; then the accumulator will return the minus character else it
; will return a zero flag to indicate that the number is positive.
;
;			Written		R.C.H.		16/9/83
;			Last Update	R.C.H.		16/9/83
;----------------------------------------------------------------
;
	name	'ascbcd'
;
	public	ascbcd
	extrn	caps
	maclib	z80
;
minus	equ	'-'
;
ascbcd:
	xra	a
	sta	fneg			; Initialize the sign
	sta	chr			; Save in the last character
	lxi	h,00			; Clear result to initialize
ascbcd2:	; loop here to read memory characters.
	ldax	d			; Get a character
	cpi	' '			; Spacer ??
	jrz	ascbcd4			; Ignore it then.
	cpi	'-'			; Negative number ??
	jrz	do$neg			; Handle it
	call	caps			; Make upper case
	sta	chr			; Save it. This is a flag too.
	sui	'0'
	cpi	10			; Convert to a BCD single digit.
	jrc	ascbcd3			; Note that A..F is illegal since BCD.
	sui	'A' - '0' - 10
	cpi	10			; Check if in range 0..9
	jrnc	bcd$fin			; Load the neg flag and return
;
ascbcd3:	; Here we multiply the result by 10 then mask in the digit
	push	b
	mov	b,h
	mov	c,l			; Take a copy of the original
	dad	h			; * 2
	dad	h			; * 4
	dad	b			; * 5 ( added the original)
	dad	h			; * 10 total
	pop	b			; Restore
	ora	l			; Mask in the NEW digit
	mov	l,a			; Put into result
ascbcd4:	; Bump pointer and continue
	inx	d			; Point to next character
	jr	ascbcd2
;
; 		---- Handle the negative number ----
; Note that the minus sign must be the first non blank character read
; If a character has been read that is not a blank then we return 
; to the user after checking the neg byte which will be set if a previous
; negative sign was read.
;
do$neg:
	lda	chr			; CHAR <> 0 until <> ' ' read.
	ora	a			; Has a character been read ?
	jrnz	bcd$fin			; Finish
	mvi	a,'-'
	sta	fneg			; Save the negative flag.
	sta	chr			; Save in the last character byte
	jr	ascbcd4			; Continue on.
;
;		---- End of the conversion ----
; This is the end of the program. Here the NEG byte is read into the 
; accumulator and orr'ed to itself to return a 00 = positive else
; <> 0 for a negative number. Note the DE -> terminating character.
;
bcd$fin:
	lda	fneg			; Get the flag
	ora	a			; Or to itself
	ret
;
	dseg
fneg	db	00			; This is the negative flag
chr	db	00			; Last character read.
;
;
	end


