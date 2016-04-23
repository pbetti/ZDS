;----------------------------------------------------------------
; 	  This is a module in the ASMLIB library.
;
; This module searches for the first occurrence of a string
; in another string. This is similar to the PL/I-80 INDEX 
; function.
; This module returns the accumulator = 0 if the string is not found or
; the position in the string where the string was found.
; This is a routine from 'Z-80 Subroutines By Saville and Leventhall'
; Modifications have been done to run under RMAC and to fit into
; ASMLIB parameter passing schemes.
; On entry DE -> main string, HL -> smaller string to find in large string.
; On exit A = index position in the larger string or 00 for error.
;
;			Written   	R.C.H.    1/10/83
;			Last Update	R.C.H.		1/10/83
;----------------------------------------------------------------
;
	name	'posstr'
	public	posstr
	maclib	z80
;
posstr:
	xchg				; Fit into ASMLIB param. methods
	push	b			; Save this
	shld	string			; Save address of major string
	xchg
	mov	a,m
	ora	a			; Is substring length = 0 ?
	jrz	notfnd			; Exit with an error then
	inx	h			; Point to first character
	shld	substg			; Save substring address
	sta	sublen			; Save length of substring
	mov	c,a			; C = substring length
	ldax	d			; Get major string address
	ora	a
	jrz	notfnd			; Exit with error if = 0
;
; Number of searches for a match = major length - substring length + 1
;
	sub	c			; Now A = major length - sub. length
	jrc	notfnd			; Exit if major shorter that sub.
	inr	a
	mov	b,a			; Load a counter
	sub	a			; Start at character 0
	sta	index			; Save as the match index 
;
; Here we search till the string is shorter than the substring.
;
slp1:
	lxi	h,index			; Point to the index
	inr	m			; Incerment
	lxi	h,sublen
	mov	c,m			; now C = length of substring
	lhld	string
	inx	h
	shld	string			; Bump string pointer
	lded	substg			; Load address of substring
;
; Here we try for a match
;
cmplp:
	ldax	d			; Load a substring byte
	cmp	m			; Equal to the string byte ?
	jrnz	slp2			; Jump if not the same
	dcr	c			; One less substring character to check
	jrz	found			; If all substring done the a match
	inx	h
	inx	d			; Bump pointers to strings
	jr	cmplp
; Arrive here if a single character match fails.
;
slp2:
	djnz	slp1			; Go and try next major character
;
notfnd:	; Here and there was no matching substring in the major string
	sub	a			; Load a 0 into A
	pop	b
	ret
;
found:
	lda	index
	pop	b
	ret				; Exit with result in A
;
	dseg
string:	db	00,00			; Major string address
substg:	db	00,00			; Substring address
slen:	db	00			; Length of major string
sublen:	db	00			; Substring length
index:	db	00			; Index to the substring.

	end



