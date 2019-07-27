
	.z80
	;aseg

	;subttl	common file for basic interpreter
	;.sall

conto	defl	15		;character to supress output (usually control-o)
dbltrn	defl	0		;for double precision transcendentals
	if	0

	.PRINTX	/EXTENDED/


	.PRINTX	/LPT/

	.PRINTX	/CPM DISK/


	.PRINTX	/Z80/

	.PRINTX	/FAST/

	.PRINTX	/5.0 FEATURES/

	.PRINTX	/ANSI COMPATIBLE/
	endif

clmwid	defl	14		;make comma columns fourteen characters
datpsc	defl	128		;number of data bytes in disk sector
linln	defl	80		;terminal line length
lptlen	defl	132
buflen	defl	255		;long lines
namlen	defl	40		;maximum length name -- 3 to 127

numlev	defl	0*20+19+2*5	;number of stack levels reserved
				;by an explicit call to getstk

strsiz	defl	4

strsiz	defl	3
numtmp	defl	3		;number of string temporaries

numtmp	defl	10

md.rnd	defl	3		;the mode number for random files
md.sqi	defl	1		;the mode number for sequential input files
				;never written into a file
md.sqo	defl	2		;the mode for sequential output files
				;and program files
cpmwrm	defl	0		;cp/m warm boot addr
cpment	defl	cpmwrm+5	;cp/m bdos call addr
	cseg
trurom	defl	0
	page
	title	biprtu	basic interpreter print using driver/whg
	;subttl	print using driver
;
; come here after the "USING" clause in a print statement
; is recognized. the idea is to scan the using string until
; the value list is exhausted, finding string and numeric
; fields to print values out of the list in,
; and just outputing any characters that aren'T PART OF
; a print field.
;
	extrn	chrgtr,synchr
	extrn	chkstr,crdo,faclo,fcerr,fretm2,frmchk,frmevl
	extrn	outdo,pufout,snerr,strout,strprt,usflg
	extrn	leftus
	public	prinus
cstrng	defl	134o
curncy	defl	44o		;use dollar sign as default

prinus:	call	frmchk		;evaluate the "USING" string
	call	chkstr		;make sure it is a string
	call	synchr
	defb	73o		;must be delimited by a semi-colon
	ex	de,hl		;[d,e]=text pointer
	ld	hl,(faclo)	;get pointer to "USING" string descriptor
	jp	inius		;dont pop off or look at usflg
reusst:	ld	a,(usflg)	;did we print out a value last scan?
	or	a		;set cc'S
	jp	z,fcerr3	;no, give error
	pop	de		;[d,e]=pointer to "USING" string descriptor
	ex	de,hl		;[d,e]=text pointer
inius:	push	hl		;save the pointer to "USING" string descriptor
	xor	a		;initially indicate there are more
				;values in the value list
	ld	(usflg),a	;reset the flag that says values printed
	cp	d		;turn the zero flag off
				;to indicate the value list hasn'T ENDED
	push	af		;save flag indicating whether the value
				;list has ended
	push	de		;save the text pointer into the value list
	ld	b,(hl)		;[b]=length of the "USING" string
	or	b		;see if its zero
fcerr3:	jp	z,fcerr		;if so, "ILLEGAL FUNCTION CALL"
	inc	hl		;[h,l]=pointer at the "USING" string'S
	ld	c,(hl)		;data
	inc	hl
	ld	h,(hl)
	ld	l,c
	jp	prcchr		;go into the loop to scan
				;the "USING" string
bgstrf:	ld	e,b		;save the "USING" string character count
	push	hl		;save the pointer into the "USING" string
	ld	c,2		;the \\ string field has 2 plus
				;number of enclosed spaces width
lpstrf:	ld	a,(hl)		;get the next character
	inc	hl		;advance the pointer at the "USING" string
				;data
	cp	cstrng		;the field terminator?
	jp	z,isstrf	;go evaluate a string and print
	cp	' '		;a field extender?
	jp	nz,nostrf	;if not, its not a string field
	inc	c		;increment the field width
				;see if there are more characters
	dec	b
	jp	nz,lpstrf	;keep scanning for the field terminator
;
; since  string field wasn'T FOUND, THE "USING" STRING
; character count and the pointer into it'S DATA MUST
; be restored and the "\" printed
;
nostrf:	pop	hl		;restore the pointer into "USING" string'S DATA
	ld	b,e		;restore the "USING" string character count
	ld	a,cstrng	;restore the character
;
; here to print the character in [a] since it wasn'T PART OF ANY FIELD
;
newuch:	call	plsprt		;if a "+" came before this character
				;make sure it gets printed
	call	outdo		;print the character that wasn'T
				;part of a field
prcchr:	xor	a		;set [d,e]=0 so if we dispatch
	ld	e,a		;some flags are already zeroed
	ld	d,a		;don'T PRINT "+" TWICE
plsfin:	call	plsprt		;allow for multiple pluses
				;in a row
	ld	d,a		;set "+" flag
	ld	a,(hl)		;get a new character
	inc	hl
	cp	'!'		;check for a single character
	jp	z,smstrf	;string field
	cp	'#'		;check for the start of a numeric field
	jp	z,numnum	;go scan it
	cp	'&'		;see if its a variable length string field
	jp	z,varstr	;go print entire string
	dec	b		;all the other possibilities
				;require at least 2 characters
	jp	z,reusin	;if the value list is not exhausted
				;go reuse "USING" string
	cp	'+'		;a leading "+" ?
	ld	a,8		;setup [d] with the plus-flag on in
	jp	z,plsfin	;case a numeric field starts
	dec	hl		;pointer has already been incremented
	ld	a,(hl)		;get back the current character
	inc	hl		;reincrement the pointer
	cp	'.'		;numeric field with trailing digits
	jp	z,dotnum	;if so go scan with [e]=
				;number of digits before the "."=0
	cp	'_'		;check for literal character declaration
	jp	z,litchr
	cp	cstrng		;check for a big string field starter
	jp	z,bgstrf	;go see if it really is a string field
	cp	(hl)		;see if the next character matches the
				;current one
	jp	nz,newuch	;if not, can'T HAVE $$ OR ** SO ALL THE
				;possibilities are exhausted
	cp	curncy		;is it $$ ?
	jp	z,dolrnm	;go set up the flag bit
	cp	'*'		;is it ** ?
	jp	nz,newuch	;if not, its not part
				;of a field since all the possibilities
				;have been tried
	ld	a,b		;see if the "USING" string is long
	inc	hl		;check for $
	cp	2		;enough for the special case of
	jp	c,notspc	; **$
	ld	a,(hl)
	cp	curncy		;is the next character $ ?
notspc:	ld	a,32		;set the asterisk bit
	jp	nz,spcnum	;if it not the special case, don'T
				;set the dollar sign flag
	dec	b		;decrement the "USING" string character count
				;to take the $ into consideration
	inc	e		;increment the field width for the
				;floating dollar sign
	defb	376q		;"CPI" over the next byte
				;mvi si,  in 8086
dolrnm:	xor	a		;clear [a]
	add	a,16		;set bit for floating dollar sign flag
	inc	hl		;point beyond the special characters
spcnum:	inc	e		;since two characters specify
				;the field size, initialize [e]=1
	add	a,d		;put new flag bits in [a]
	ld	d,a		;into [d]. the plus flag may have
				;already been set
numnum:	inc	e		;increment the number of digits before
				;the decimal point
	ld	c,0		;set the number of digits after
				;the decimal point = 0
	dec	b		;see if there are more characters
	jp	z,endnus	;if not, we are done scanning this
				;numeric field
	ld	a,(hl)		;get the new character
	inc	hl		;advance the pointer at the "USING" string data
	cp	'.'		;do we have trailing digits?
	jp	z,aftdot	;if so, use special scan loop
	cp	'#'		;more leading digits ?
	jp	z,numnum	;increment the count and keep scanning
	cp	54o		;does he want a comma
				;every three digits?
	jp	nz,finnum	;no more leading digits, check for ^^^
	ld	a,d		;turn on the comma bit
	or	64
	ld	d,a
	jp	numnum		;go scan some more
;
; here when a "." is seen in the "USING" string
; it starts a numeric field if and only if
; it is followed by a "#"
;
dotnum:	ld	a,(hl)		;get the character that follows
	cp	'#'		;is this a numeric field?
	ld	a,'.'		;if not, go back and print "."
	jp	nz,newuch
	ld	c,1		;initialize the number of
				;digits after the decimal point
	inc	hl
aftdot:	inc	c		;increment the number of digits
				;after the decimal point
	dec	b		;see if the "USING" string has more
	jp	z,endnus	;characters, and if not, stop scanning
	ld	a,(hl)		;get the next character
	inc	hl
	cp	'#'		;more digits after the decimal point?
	jp	z,aftdot	;if so, increment the count and keep
				;scanning
;
; check for the "^^^^" that indicates scientific notation
;
finnum:	push	de		;save [d]=flags and [e]=leading digits
	ld	de,notsci	;place to go if its not scientific
	push	de		;notation
	ld	d,h		;remember [h,l] in case
	ld	e,l		;its not scientific notation
	cp	'^'		;is the first character "^" ?
	ret	nz
	cp	(hl)		;is the second character "^" ?
	ret	nz
	inc	hl
	cp	(hl)		;is the third character "^" ?
	ret	nz
	inc	hl
	cp	(hl)		;is the fourth character "^" ?
	ret	nz
	inc	hl
	ld	a,b		;were there enough characters for "^^^^"
	sub	4		;it takes four
	ret	c
	pop	de		;pop off the notsci return address
	pop	de		;get back [d]=flags [e]=leading digits
	ld	b,a		;make [b]=new character count
	inc	d		;turn on the scientific notation flag
	inc	hl
	defb	312o		;skip the next two bytes with "JZ"
notsci:	ex	de,hl		;restore the old [h,l]
	pop	de		;get back [d]=flags [e]=leading digits
endnus:	ld	a,d		;if the leading plus flag is on
	dec	hl
	inc	e		;include leading "+" in number of digits
	and	8		;don'T CHECK FOR A TRAILING SIGN
	jp	nz,endnum	;all done with the field if so
				;if there is a leading plus
	dec	e		;no leading plus so don'T INCREMENT THE
				;number of digits before the decimal point
	ld	a,b
	or	a		;see if there are more characters
	jp	z,endnum	;if not, stop scanning
	ld	a,(hl)		;get the current character
	sub	'-'		;trail minus?
	jp	z,sgntrl	;set the trailing sign flag
	cp	'+'-'-'		;a trailing plus?
	jp	nz,endnum	;if not, we are done scanning
	ld	a,8		;turn on the positive="+" flag
sgntrl:	add	a,4		;turn on the trailing sign flag
	add	a,d		;include with old flags
	ld	d,a
	dec	b		;decrement the "USING" string character
				;count to account for the trailing sign
endnum:	pop	hl		;[h,l]=the old text pointer
	pop	af		;pop off flag that says whether there
				;are more values in the value list
	jp	z,fldfin	;if not, we are done with the "PRINT"
	push	bc		;save [b]=# of characters remaining in
				;"USING" string and [c]=trailing digits
	push	de		;save [d]=flags and [e]=leading digits
	call	frmevl		;read a value from the value list
	pop	de		;[d]=flags & [e]=# of leading digits
	pop	bc		;[b]=# character left in "USING" string
				;[c]=number of trailing digits
	push	bc		;save [b] for entering scan again
	push	hl		;save the text pointer
	ld	b,e		;[b]=# of leading digits
	ld	a,b		;make sure the total number of digits
	add	a,c		;does not exceed twenty-four
	cp	25
	jp	nc,fcerr	;if so, "ILLEGAL FUNCTION CALL"
	ld	a,d		;[a]=flag bits
	or	128		;turn on the "USING" bit
	call	pufout		;print the value
	call	strout		;actually print it
fnstrf:	pop	hl		;get back the text pointer
	dec	hl		;see what the terminator was
	call	chrgtr
	scf			;set flag that crlf is desired
	jp	z,crdnus	;if it was a end-of-statement
				;flag that the value list ended
				;and that  crlf should be printed
	ld	(usflg),a	;flag that value has been printed.
				;doesnt matter if zero set, [a]
				;must be non-zero otherwise
	cp	73o		;a semi-colon?
	jp	z,semusn	;a legal delimiter
	cp	54o		;a comma ?
	jp	nz,snerr	;the delimeter was illegal
semusn:	call	chrgtr		;is there another value?
crdnus:	pop	bc		;[b]=characters remaining in "USING" string
	ex	de,hl		;[d,e]=text pointer
	pop	hl		;[h,l]=point at the "USING" string
	push	hl		;descriptor. resave it.
	push	af		;save the flag that indicates
				;whether or not the value list terminated
	push	de		;save the text pointer
;
; since frmevl may have forced garbage collection
; we have to use the number of characters already scanned
; as an offset to the pointer to the "USING" string'S DATA
; to get a new pointer to the rest of the characters to
; be scanned
;
	ld	a,(hl)		;get the "USING" string'S LENGTH
	sub	b		;subtract the number of characters
				;already scanned
	inc	hl		;[h,l]=pointer at
	ld	c,(hl)		;the "USING" string'S
	inc	hl		;string data
	ld	h,(hl)
	ld	l,c
	ld	d,0		;setup [d,e] as a double byte offset
	ld	e,a
	add	hl,de		;add on the offset to get
				;the new pointer
chkusi:	ld	a,b		;[a]=the number of characters left to scan
	or	a		;see if there are any left
	jp	nz,prcchr	;if so, keep scanning
	jp	finusi		;see if there are more values
reusin:	call	plsprt		;print a "+" if necessary
	call	outdo		;print the final character
finusi:	pop	hl		;pop off the text pointer
	pop	af		;pop off the indicator of whether or not
				;the value list has ended
	jp	nz,reusst	;if not, reuse the "USING" string
fldfin:	call	c,crdo		;if not comma or semi-colon
				;ended the value list
				;print a crlf
	ex	(sp),hl		;save the text pointer
				;[h,l]=point at the "USING" string'S
				;descriptor
	call	fretm2		;finally free it up
	pop	hl		;get back the text pointer
	extrn	finprt
	jp	finprt		;zero [ptrfil]
;
; here to handle a literal character in the using string preceded
; by "_"
;
litchr:	call	plsprt		;print previous "+" if any
	dec	b		;decrement count for actual character
	ld	a,(hl)		;fetch literal character
	inc	hl
	call	outdo		;output literal character
	jp	chkusi		;go see if using string ended
;
; here to handle variable length string field specified with "&"
;
varstr:	ld	c,255		;set length to maximum possible
	jp	isstr1
;
; here when the "!" indicating a single character
; string field has been scanned
;
smstrf:	ld	c,1		;set the field width to 1
	defb	76q		;skip next byte with a "MVI A,"
isstrf:	pop	af		;get rid of the [h,l] that was being
				;saved in case this wasn'T A STRING FIELD
isstr1:	dec	b		;decrement the "USING" string character count
	call	plsprt		;print a "+" if one came before the field
	pop	hl		;take off the text pointer
	pop	af		;take of the flag which says
				;whether there are more values in the
				;value list
	jp	z,fldfin	;if there are no more values
				;then we are done
	push	bc		;save [b]=number of characters yet to
				;be scanned in "USING" string
	call	frmevl		;read a value
	call	chkstr		;make sure its a string
	pop	bc		;[c]=field width
	push	bc		;resave [b]
	push	hl		;save the text pointer
	ld	hl,(faclo)	;get a pointer to the descriptor
	ld	b,c		;[b]=field width
	ld	c,0		;set up for "LEFT$"
	push	bc		;save the field width for space padding
	call	leftus		;truncate the string to [b] characters
	call	strprt		;print the string
	ld	hl,(faclo)	;see if it needs to be padded
	pop	af		;[a]=field width
	inc	a		;if field length is 255 must be "&" so
	jp	z,fnstrf	;dont print any trailing spaces
	dec	a
	sub	(hl)		;[a]=amount of padding needed
	ld	b,a
	ld	a,' '		;setup the print character
	inc	b		;dummy increment of number of spaces
uprtsp:	dec	b		;see if more spaces
	jp	z,fnstrf	;no, go see if the value list ended and
				;resume scanning
	call	outdo		;print a space
	jp	uprtsp		;and loop printing them
;
; when a "+" is detected in the "USING" string
; if a numeric field follows a bit in [d] should
; be set, otherwise "+" should be printed.
; since deciding whether a numeric field follows is very
; difficult, the bit is always set in [d].
; at the point it is decided a character is not part
; of a numeric field, this routine is called to see
; if the bit in [d] is set, which means
; a plus preceded the character and should be
; printed.
;
plsprt:	push	af		;save the current character
	ld	a,d		;check the plus bit
	or	a		;since it is the only thing that could
				;be turned on
	ld	a,'+'		;setup to print the plus
	call	nz,outdo	;print it if the bit was set
	pop	af		;get back the current character
	ret
;	end
