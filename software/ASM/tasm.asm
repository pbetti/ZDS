;----------------------------------------------------------------
; This is a test of the asmlib library.
;
;		Written    R.C.H.    15/8/83
;----------------------------------------------------------------
;
	extrn	prolog,quit,dispatch,atodin,version
	extrn	phacc,crlf,pdde,phde,cursor,clear
	extrn	pdacc,pstr,inline,xyinline,xypstring,pmenu
	extrn	nolzb,lzb,blzb,clzb,delay
	extrn	cst,cie,formin
;
	maclib	z80
;
	call	prolog
	call	lzb
	call	clear
;
	call	xyinline
	db	10,10,'   ASMLIB Test Program$'
	call	xyinline
	db	10,12,'ASMLIB  Version Number $'
	call	version
	mov	a,h
	call	pdacc
	call	xyinline
	db	10,13,'ASMLIB Revision Number $'
	mov	a,l
	call	phacc
; Do a 5 second delay then continue
	lxi	d,5000
	call	delay
;
	call	clear
	call	crlf
	call	xyinline
	db	0,4,'This is a test of the ASMLIB library and its functions$'
	call	crlf
	mvi	a,'-'
	mvi	b,54			; underline exactly
	call	pstr
	call	inline
	db	0dh,0ah,0ah,0ah,'Testing Leading Zero Blanking Modes$'
;
; Test the leading zero blanking, done with 4 displays on the dame set of lines
;
	mvi	a,10
	sta	y			; Always use line 10 to start
	xra	a
	sta	x			; Use this for x value too
;
; Do without leading zero blanking
	call	set$xy
	call	inline
	db	'NO LZB$'
	call	send$args
;
	call	lzb
	call	set$xy			; new cursor positioning
	call	inline
	db	'LZB$'
	call	send$args
; Blank filled LZB
	call	set$xy
	call	inline
	db	'BLZB$'
	call	blzb
	call	send$args
; Character filled LZB
	call	set$xy
	call	inline
	db	'CLZB (*)$'
	mvi	a,'*'
	call	clzb
	call	send$args
; Now do next part of the test. Delay for 10 seconds then jump ask 
; for a key press.
	lxi	d,continue
	call	xypstring
	call	cie
	cpi	01bh
	jz	quit
;
	call	clear
	call	inline
	db	0dh,0ah,'Accumulator printing as hex and decimal$'
	call	crlf
	mvi	b,39
	mvi	a,'-'
	call	pstr
;
	lxi	d,1409h
	call	cursor			; set up cursor
	call	inline
	db	'Decimal   Hex$'
	call	nolzb
	xra	a
;
acc$loop:
	push	psw			; save value
; Set cursor to display line
	mvi	a,11
	sta	y
	mvi	a,10
	sta	x
	call	set$xy
	pop	psw
	push	psw
	call	pdacc			; print as decimal
	call	set$xy			; bump col by 10 and set
	pop	psw
	push	psw
	call	phacc
	lxi	d,10			; do a little wait
	call	delay
	pop	psw
	inr	a
	jnz	acc$loop
; Do we want to end ?
	lxi	d,continue
	call	xypstring
	call	cie
	cpi	01bh
	jz	quit
;
; Do the menu display function and return
	call	clear
	lxi	d,menu1
	call	pmenu
;
	lxi	d,continue
	call	xypstring
	call	cie			; wait for a key
	cpi	01bh			; escape ?
	jz	quit
; If not escape then do the formatted input test
	call	clear
	lxi	d,menu2
	call	formin			; read the data
;
	lxi	d,continue		; wait for a key press
	call	xypstring		; print it
	call	cie			; wait for it
	call	clear			; clear screen
; Now display all the analogue channels 0..31
;
	call	inline
	db	0dh,0ah,'Analogue channel reading',0dh,0ah,'$'
	mvi	a,'-'
	mvi	b,24
	call	pstr
;
atod$again:
	mvi	b,32			; loop counter
	call	xyinline
	db	1,10,'0  > $'
	lxi	d,00			; start at channel 0
;
atodloop:
	call	cst			; get status
	ora	a
	jrnz	back1
;
	call	atodin			; get analogue channel # in DE
	mov	a,h			; test out of time return value
	cpi	0ffh
	jrz	atod$error
	mov	a,l			; only 8 bits
	call	phacc			; display it
; See if next line needed
	mov	a,e			; check channel number
	cpi	15			; end of line ?
	jrnz	noteol
	call	xyinline
	db	1,11,'16 > $'
	jr	nxtatod
noteol:
	mvi	a,' '
	call	dispatch
nxtatod:
	inx	d
	djnz	atodloop
	jr	atod$again		; do again
;
back1:
	call	cie
	call	xyinline
	db	1,23,'Press a key to quit $'
;
	call	cie
	jmp 	quit
;
atod$error:
	call	inline
	db	'A to D card non-functional$'
	jmp	back1
;
send$args:
	call	set$pos			; Set the cursor and bump line #
	lxi	d,1 
	call	pdde
	call	set$pos
	lxi	d,10
	call	pdde
	call	set$pos
	lxi	d,0100 
	call	pdde
	call	set$pos
	lxi	d,01000
	call	pdde
	call	set$pos
	lxi	d,10000
	call	pdde
	ret
;
set$xy:	; Set the cursor to the X and Y saved values and bump the X value by 10
;
	mvi	a,10
	sta	y		; always start at line 10
	mov	e,a
	lda	x
	adi	10
	sta	x
	mov	d,a
	jmp	cursor			; set up screen
;
set$pos	; Set the X and Y values then bump the Y value by 1
	lda	x
	mov	d,a
	lda	y
	inr	a
	sta	y
	mov	e,a
	jmp	cursor
;
x	db	00
y	db	00
;
;
continue:
	db	1,23,'Press a key to continue $'
;
menu1:
	db	11,1,'This screen was printed by the PMENU function.$'
	db	4,3,'All the strings on it have been put in a table with$'
	db	4,5,'preceeding cursor addresses for PMENU to use$'
	db	4,7,'This makes printing to odd addresses quite easy and the$'
	db	4,9,'code overhead is very small. Why not try it !$'
	db	0ffh
;
; The below menu is used for the formin function
;
menu2:
	db	1,1,'Name     $'
	dw	data$name
	db	1,3,'Age      $'
	dw	data$age
	db	1,5,'Weight   $'
	dw	data$weight
	db	16,5,'Kgs$'
	db	00,00			; No console buffer for this one
	db	0ffh
;
data$name:
	db	20,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
data$age:
	db	2,0,0,0
data$weight:
	db	4,0,0,0,0,0
;
	end


