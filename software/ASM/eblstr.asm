;----------------------------------------------------------------
;          This is a module in the ASMLIB library
;
; This module eliminates blanks from both the start and the 
; finish of strings. This is handy for free format scanners
; which may return a series of blanks on a string.
;
; Entry points are.
;
; ELBSTR   -- Eliminate leading blanks from a string. DE -> string
; ETBSTR   -- Eliminate trailing blanks, DE -> string.
;
;			Written      R.C.H.      1/11/83
;			Last Update  R.C.H.      1/11/83
;----------------------------------------------------------------
;
;
	name	'eblstr'
	public	elbstr,etbstr
	extrn	delstr
	maclib	z80
;
; Eliminate leading blanks by counting them and then shifting the 
; the string back to cover them then adjust the string size.
;
elbstr:
	ldax	d
	ora	a
	rz			; exit if zero sized string
	sded	str$adr		; save its address
	mov	b,a		; save size as a counter
	mov	c,a		; save a copy
elb$loop:
	inx	d
	ldax	d		; get a character from the string
	cpi	' '		; is it a blank ?
	jrnz	elb$nob
	djnz	elb$loop
; Here and all characters in the string are blanks
	xra	a
	lded	str$adr
	stax	d
	ret
;
; Here and there was a character found that was not a blank in the string
; so we can now shift the string back and reset the string length
;
elb$nob:
	mov	a,c		; get the original length
	sub	c		; subtract the current count
	jrz	elb$end
;
	mvi	c,01		; start at character 1
	mov	b,a		; 2 = characters to delete
	call	delstr		; delete the characters
;
elb$end:
	lded	str$adr
	ret
;
; This routine eliminates trailing characters from a string by
; finding how many characters there are in the string then adjusting
; till no blanks are present at the end.
;
etbstr:
	ldax	d
	ora	a
	rz
	push	h
	push	d		; save start address
	mov	l,a		; load character count
	mvi	h,00		; clear top
	dad	d		; now hl -> last character
	mov	b,a		; load a counter
etb$loop:
	mov	a,m
	cpi	' '
	jrnz	etb$end
	dcx	h
	djnz	etb$loop
;
etb$end:
	pop	h		; get start address into hl
	mov	m,b		; save string length
	xchg			; load string address into de
	pop	h		; restore original hl
	ret
;
	dseg
str$adr	db	00
	end



