;----------------------------------------------------------------
; 	    This is a module in the ASMLIB library
;
; This module will insert a string into another string.
; This is from 'Z-80 Subroutines By Saville and Leventhal'
;
; On entry
;    DE -> String to insert into
;    HL -> string to insert
;     B = Maximum length of the result string
;     C = index into string to insert into.
;
;On Exit
;   Carry = 1 indicates start index = 0 or length of the substring is 0
;   if the result string is > 255 then then the carry is set and only enough
;   characters are moved.
;
;				Written		R.C.H.    1/10/83
;				Last Update	R.C.H.    9/10/83
;----------------------------------------------------------------
;
	name	'insstr'
	public	insstr
	maclib	z80
;
insstr:
	sub	a
	sta	inserr			; Clear error flag
	xchg				; reset pointers for asmlib
	ldax	d			; Get substring length
	ora	a
	rz
;
; If starting index = 0 then error exit
	mov	a,c
	ora	a
	stc
	rz				; Return a carry if index = 0
;
; Check if the insertion will make the string too long
;
	ldax	d
	add	m			; Add string to substring
	jrc	trunc			; Truncate if > 255
	cmp	b			; Compare to string max length
	ldax	d
	jrc	idxlen			; Jump if total < max length
	jrz	idxlen			; Jump if total = max len
;
; Here the substring does not fit so truncate it. Set the error flag
; to indicate this. 
;
trunc:
	mvi	a,0ffh
	sta	inserr			; Save insert error flag
	mov	a,b
	sub	m			; 
	rc				; Return if string too long
	stc
	rz				; Or if no room for substring
;
; Check if the index is within limits.
;
idxlen:
	mov	b,a			; Get length of substring
	mov	a,m			; Get string length
	cmp	c			; Compare to index
	jrnc	lenok			; Jump if index inside string
;
; Here and the index is not within the string so we concatenate
; the two strings together.
;
	mov	c,a
	add	b			; Add length of string
	mov	m,a			; Set new string length
;
	xchg
	mov	a,c
	inr	a
	add	e
	mov	e,a
	jrnc	idxl1
	inr	d
idxl1:
	mvi	a,0ffh			; Indicate insertion error
	sta	inserr
	jr	mvesub			; Move the string
;
; Here and we must make room for the substring to be inserted into
; the string.
;
lenok:
	push	b
	push	d
	mov	e,a
	mvi	d,0
	add	b
	mov	m,a			; Store new string length
; Calculate number of characters to move
	mov	a,e
	sub	c
	inr	a			; Number to move
	dad	d			; HL -> last characters in string
	mov	e,l
	mov	d,h			; Copy
; Generate destination address
	mov	c,b			; Length of substring
	mvi	b,0
	dad	b
	xchg				; Now HL = start, DE = dest
	mov	c,a
	lddr				; Open the substring
	xchg
	inx	d			; De is new destination address
	pop	h
	pop	b
;
; Here we can move the substring into the string, there is room for it.
;
mvesub:
	inx	h
	mov	c,b
	mvi	b,00			; Clear top of counter
	ldir				; Do the move
	lda	inserr			; Load the insert error flag
	rar
	ret
;
	dseg
inserr:	db	00			; Insert error flag
	end



