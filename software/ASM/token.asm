;----------------------------------------------------------------
; 	    This is a module in the ASMLIB library.
;
; This is the token processing module. It is responsible for
; all the token processing and contains the following code
;
; 1) DEFDEL	Define Token delimeters
; 2) GETTOK	Get a token from a string
; 3) TABSRC	Search a table for a token
;
;			Written		R.C.H.        22/10/83
;			Last Update	R.C.H.        01/11/83
;----------------------------------------------------------------
;
	name	'token'
	extrn	cmpstr,delstr
	public	gettok,defdel,tabsrc
	maclib	z80
;
;
defdel:
	sded	delims			; Save the address of the delimeters
	push	b
	ldax	d			; get size of the string
	ora	a			; return a zero if size = 0
	pop	b
	ret
;
; This is a major routine which must use the delimeter string to define
; where a token will end. If no delimeter then the token ends on a string
; boundary. If no delimeters then return a carry set to indicate an error.
; On entry DE -> string to extract a token from
;          HL -> Destination for the token
;           B -> maximum allowable length for a token.
;
; On exit carry set means error.
;   if destination count too small then carry returned
;   When a token is returned the delimeter that caused the return is
;    appended to the end of the string. This is always done.
;
; This module has been written with the aid of a pseudo code sketch.
;
;  start:
;       get size of input string
;	    if zero then return
;       get length of delimeter string
;           if zero then return
;  main loop:
;	get a character 
;	load into destination string
;       check if a delimeter
;           if so thgen return no zer or carry
;       check if destination full
;           if so then return a carry
;       check if source empty.
;           if so then return a zero
;        goto main loop.
;
;
gettok:
	ldax	d
	ora	a			; is source string zero length ?
	rz				; exit with zero for end of job
	shld	dst$adr			; save destination string address
	sded	src$adr			; save source string address
	mov	c,a			; save the original length
	sbcd	siz$str			; save original size setups
;
main1:	; main loop. DE -> source, HL -> dest, B = dest size, C = source size
	inx	d			; point ot a character in the source
	inx	h			; point to next character in the dest
	ldax	d			; get a character
	mov	m,a			; save it
	dcr	c			; decrement the source size
	dcr	b			; decrement the dest size
; Check if the character was a delimeter.
	call	chk$delim		; check. return zero true if so
	jrz	delim$end		; delimetered end return
; Check if the source is empty. This is a valid return
	mov	a,c
	ora	a
	jrz	delim$end		; this is a delimetered end, cr did it
; check if the dest is full
	mov	a,b
	ora	a
	jrz	end$dest		; set carry to indicate the error
; All else means that we get another character
	jmp	main1			; keep on going
;
; Here and the destination went full prematurely so we signal the error
; and exit without saving any string lengths etc.
;
end$dest:	; end of destination buffer, signal an error
	stc				; set the carry flag
	lhld	dst$adr
	lded	src$adr
	ret
;
; Here and the string was properly delimetered by either the source string end
; or there was a match with a token delimeter character. When this happens we 
; must change the string sizes in both the source and dest strings
;
delim$end:
	lded	siz$str			; get original sizes into DE
	mov	a,e			; get original source string size
	sub	c			; take decremented size
	lhld	dst$adr			; get start address of dest string
	mov	m,a			; save size of the destination string
; 
	mov	b,a			; save a copy for the delete
	mvi	c,1 			; start at character 1
 	lded	src$adr			; start of source string
	call	delstr			; delete the substring
	ret
;
; This routine returns a zero if the character in A matches a delimeter
; character in the delimeter string.
;
chk$delim:
	push	h			; save
	push	b			; save maximum string length bytes
	lhld	delims			; get delimeter string address
	mov	b,m			; get string size
chk$loop:				; loop here checking bytes
	inx	h			; point to next delimeter
	cmp	m
	jrz	chk$match		; matches a delimeter 
	djnz	chk$loop		; loop on
	mvi	a,0ffh			; ensure zero flag off
;
; If the following is jumped then the zero flag is not turned off
; and we return saying that there was a match therefore
;
	ora	a
chk$match:				; jump here if a match, zero maintained
	pop	b
	pop	h			; restore all
	ret
;
;----------------------------------------------------------------
;     This routine must search a table of strings for a match with the
; input string. If it matches then a return is done with the carry
; off , zero off and A= index into the table where the match happened.
;     If there was no match then return with a zero in a and a zero flag.
;
; No entry DE -> string
;          HL -> table end of table has a string size of 00.
;
; Note that the routine assumes the table is in alpha order.
; This routine uses the external referenced compare routine
; 
;----------------------------------------------------------------
;
tabsrc:
	ldax	d			; get source string length
	ora	a
	rz				; return if a zero 
	mvi	c,01			; count strings checked.
	shld	dst$adr			; save table address
	sded	src$adr			; save string address
; Now we can check the strings.
; DE -> the source string
; HL -> table string
tab$loop:
	push	b
	call	cmpstr			; compare them
	pop	b
 	mov	a,c
	rz				; exit with a = number checked if =
; If no carry then the table string > source string so error exit
	jrc	err$exit
; Else we must index to the next string in the table
	lhld	dst$adr			; get start of the string
	mov	e,m
	mvi	d,00			; make an index
	dad	d			; point to next string
	inx	h			; make up for counter byte
	mov	a,m			; is table length = 0
	ora	a
	rz	
	shld	dst$adr			; save it
	lded	src$adr			; get address of string again
	inr	c
	jr	tab$loop
;
;
err$exit:
	xra	a			; indicate a not found string
	stc
	ret
;
	dseg
delims:	db	00,00		; initialize to zero for checking
src$adr	db	00,00		; source string address
dst$adr	db	00,00		; destination string address
siz$str	db	00,00		; original string setup sizes
	end



