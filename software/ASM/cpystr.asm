;----------------------------------------------------------------
; 	  This is a module in the ASMLIB library.
;
; This module will copy a substring from within another string. This
; is similar to the PL/I-80 SUBSTR function. 
; On entry DE -> original string. HL -> new string, B = bytes to copy.
;   C = index to start of bytes, A = maximum length of the substring.
; On exit, if the carry is set, this indicates that an illegal length
; was used which would exceed the length of the substring or major string.
; This software comes from the 'Z-80 Subroutines By Saville and Leventhal'
; and is modified to suit RMAC and ASMLIB parameter conventions.
;
;				Written		R.C.H.     1/10/83
;				Last Update	R.C.H.	   1/10/83
;----------------------------------------------------------------
;
	name	'cpystr'
	public	cpystr
	maclib	z80
;
cpystr:
	xchg				; Load suitable for ASMLIB
	sta	maxlen			; Substring maximum
	sub	a			; Clear a
	stax	d			; Make destination string length = 0
	sta	cpyerr			; Clear copy error flag
	ora	b			; Test number of bytes to copy
	rz				; Exit no character, Carry = 0
;
; Check if maximum length is 0
	lda	maxlen
	ora	a
	jrz	erexit
;
; If starting index is 0 then error exit also
	mov	a,c			; Get starting index
	ora	a
	jrz	erexit			; Error exit if index = 0
;
; If start index > length of string the error exit also
	mov	a,m			; Get major string length
	cmp	c			; Check against index
	rc				; Exit with a carry for error
;
; Check if the copy area will fit the source string else copy only to the
; end of the string.
;
	mov	a,c
	add	b			; Add copy length to index
	jrc	recalc			; jump if sum > 255 (over full)
	dcr	a
	cmp	m
	jrc	cnt1ok			; jump if more than enough to copy
	jrz	cnt1ok			; Jump if exactly enough
;
; Caller asked for too many characters, return everything between the index
; and the end of the source string:
;
recalc:
	mvi	a,0ffh
	sta	cpyerr			; Save an error flag
	mov	a,m			; Load count length
	sub	c
	inr	a
	mov	b,a			; Load as the number of bytes
;
; Check if count is less than or equal to the maximum length of
; the destination string. If not then make the length of the destination
; string into the byte counter.
;
cnt1ok:
	lda	maxlen			; Get maximum length
	cmp	b			; Compare to bytes to copy
	jrnc	cnt2ok			; This is ok then too
	mov	b,a			; Else re-load the counter
	mvi	a,0ffh
	sta	cpyerr			; Flag an error again.
cnt2ok:
	mov	a,b
	ora	a			; Is the number of bytes to move = 0
	jrz	erexit			; ERROR Exit if so
	mvi	b,00			; Else start at the index position
	dad	b			; Index to the index pos'n.
	stax	d			; Set length of destination string
	mov	c,a			; Load as a 16 bit counter
	inx	d
; 
; Here HL -> source string start + index
;      DE -> destination string start of characters.
;      BC = Number of bytes to be moved.
;
	ldir				; Move it all
	lda	cpyerr			; Get the copy error flag
okexit:
	ora	a
	ret
;
erexit:
	stc				; Set the carry flag
	ret
;
	dseg
maxlen:	db	00			; Maximum length of dest string
cpyerr:	db	00			; Error flag
;
	end



