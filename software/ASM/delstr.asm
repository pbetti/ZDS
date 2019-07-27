;----------------------------------------------------------------
;          This is a module in the ASMLIB library.
;
; This module will delete a substring from within a string.
; This comes from 'Z-80 Subroutines By Saville and Leventhal'.
;
; On  ENTRY
;    DE -> start of string
;     B =  Number of bytes to delete
;     C = Starting index into the string to start deleting from.
; On EXIT
;    Carry = 1 means an error on input paramteres.
;
;			Written		R.C.H.		1/10/83
;			Last Update	R.C.H.		1/10/83
;----------------------------------------------------------------
;
	name	'delstr'
	public	delstr
	maclib	z80
;
delstr:
	sub	a			; Set A = 0
	sta	delerr			; Save in the flag
	ora	b			; Is B = A = 0 ?
	rz				; Return if no characters to delete
	mov	a,c			; Load starting index
	ora	a			; Test start index
	stc
	rz				; Error if the index is 0
;
; Check if the index is within the string limits, error if not.
	ldax	d			; Get string length
	cmp	c			; Check string size against index
	rc				; Return with error flag
;
; Check if enough characters are available to be deleted. If not then
; delete only to the end of the string.
;
	push	h			; Save this non-participant
	xchg				; Load atring address into HL
	mov	a,c
	add	b			; Add number to delete to index
	jrc	trunc			; Truncate if > 255
	mov	e,a
	dcr	a
	cmp	m			; compare to length
	jrc	cntok			; Jump if enough available
	jrz	trunc			; Truncate but no errors
	mvi	a,0ffh			; Load an error flag
	sta	delerr
;
; Truncate the string, no compacting needed.
;
trunc:
	mov	a,c
	dcr	a
	mov	m,a			; String length = index - 1
	lda	delerr			; Load error flag
	rar
	pop	h			; Restore
	ret
;
; Here when all counts are ok.
; Move characters about deleted characters down.
cntok:
	mov	a,m
	mov	d,a			; Save
	sub	b			; set new length
	mov	m,a			; Load string length
; Calculate number of characters to move.
;
	mov	a,d
	sub	e			; subtract index + number of bytes
	inr	a			; A = characters to move

;
; Calculate source and destination addresses for the move.
;
	push	h
	mvi	b,00
	dad	b			; Now HL = base + index
	xthl				; source = base + index + number
	mvi	d,00
	dad	d			; HL = source above deleted area
	pop	d			; Load destination address
	mov	c,a			; Load the count
;
; Here HL -> start of deleted area
;      DE -> start of characters to move
;      BC =  count
;
	ldir
okexit:
	ora	a			; Clear carry, no errors
	pop	h			; Restore
	ret
;
	dseg
delerr:	db	00			; Error deleting.

	end



