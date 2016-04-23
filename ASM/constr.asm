;----------------------------------------------------------------
;       This is a module in the ASMLIB library.
;
; This module concatenates two strings to produce a second string. 
; The strings are each preceeded by a length byte and less than 256
; bytes long. If the result is > 255 bytes long then only enough
; characters to make up this size in the new string are added.
; This software comes from 'Z-80 Subroutines By Saville and Leventhal'
; Modification has been done to make it run under RMAC and to change
; the parameter passing conventions. DE -> string1, HL -> string 2.
; B = maximum length of the result string allowed.
;
;			Written		R.C.H.	    1/10/83
;			Last Update	R.C.H.	    1/10/83
;----------------------------------------------------------------
;
;
	name	'constr'
	public	constr
	maclib	z80
;
constr:
	xchg				; Into ASMLIB order
;
; Now HL -> string1, DE -> string 2
	shld	s1adr			; Save string 1 address
	push	b			; Save maximum length allowed
	mov	a,m			; Get string 1 length
	sta	s1len			; Save it
	mov	c,a			; load into c
	mvi	b,00			; Clear upper byte
	dad	b			; Now HL -> last char of string 1
	inx	h			; Now points past end
	ldax	d			; Get length of string 2
	sta	s2len			; Save this too
	inx	d			; Now de -> character 1 in string 2
	pop	b			; Restore users max. Length allowed
;
; Now we determine how many characters to concatenate.
	mov	c,a			; Put length of string 2 into C
	lda	s1len			; Get string 1 length
	add	c			; Add together
	jrc	toolng			; Carry and result > 255
	cmp	b			; Compare to maximum length allowed
	jrz	lenok			; Ok if of exact size
	jrc	lenok			; Ok if too small
;
; Here and the concatenated string is longer than the allowed length in
; register b. We indicate a string overflow.
;
toolng:
	mvi	a,0ffh
	sta	strgov			; Save the flag
	lda	s1len			; Get string 1 length back
	mov	c,a			; Load into C
	mov	a,b			; Load max length into A
	sub	c			; take 
	rc				; Return if original is too long
	sta	s2len			; Save as new length of string 2
	mov	a,b			; get maximum again
	sta	s1len			; Save as new length os string 1
	jr	docat			; Do the job now, flags etc set.
;
; Here and the lengths are ok and we can indicate no overflow.
;
lenok:
	sta	s1len			; Save sum of lengths
	sub	a			; Generate a 0
	sta	strgov			; Indicate no overflow
;
; Here we can concatenate strings by moving characters from string 2
; to the end of string 1.
;
docat:
	lda	s2len			; Get the number of characters
	ora	a
	jrz	exit			; Exit if nothing to add
	mov	c,a			; BC = number of characters
	mvi	b,00			
	xchg				; DE = Destination, HL = source
	ldir				; Move the characters in a hurry
exit:
	lda	s1len			; Write new length to string 1
	lhld	s1adr
	mov	m,a			; Save in memory
	lda	strgov			; Load overflow flag
	rar				; Rotate to set flags
	ret
;
	dseg
s1adr:	db	00,00			; Address of string 1
s1len:	db	00			; Length of string 1
s2len:	db	00			; Length of string 2
strgov:	db	00			; Overflow flag.

	end



