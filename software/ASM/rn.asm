;----------------------------------------------------------------
; This program tests the random number generator.
; Two tests are performed.
;
; The first test is on 8 bit numbers and uses the 8 bit output to
; increment elements in a 256 array table of 16 bit words. Each time
; a number occurs, the number is incremented. This then gives a diaplay
; of the number of occurrences that each number occurs.
;
; The second test uses a 16 bit random number divided by 256 to
; increment a 256 element table. This allows the user to see how
; many times a number occurs within a RANGE of numbers. 
;
;			Written		R.C.H.        30/11/83
;			Last Update	R.C.H.	      05/01/84
;----------------------------------------------------------------
;
	extrn	prolog,nibasc,pdacc,lzb,dispatch,inline
	extrn	quit,coe,cie,caps,loe,listout,consout,crlf,blzb
	extrn	pdde,randinit,rand8,rand16,pmenu,flushloe,cleol,cleop
	extrn	cst,clear,bell,cursor,curoff,curon,xyinline
;
	maclib	z80
;
	call	prolog
	call	blzb
start:
	call	clear
	lxi	d,disp
	call	pmenu
start1:
	call	cie
	call	caps
	cpi	'1'
	jz	test$08
	cpi	'2'
	jz	test$16
	cpi	'Q'
	jz	quit
	jrnz	start
;
;----------------------------------------------------------------
; 16 bit random number test. This must ....
; clear table of 256 elements
; do while console input not = Q or E
;    get a random number
;    increment table element
;    if modulus(1000) tests then display on screen
;    if console input = 'P' then send to printer
;  if console input = 'E' then restart the test
;  if console input = 'Q' then goto quit = CP/M
;----------------------------------------------------------------
;
test$16:
	call	clear
	call	clear$table
	lxi	d,seed
	call	randinit
;
	lxi	h,0
	shld	counts			; clear the loop counter
	xra	a
	sta	conchr
;
mmenu16:	; display main menu for 16 bit test
	call	clear
	lxi	d,menu
	call	pmenu
get16:	; Get an option
	call	cie
	call	caps
	sta	conchr
; Decode the option asked for.
chk$chr$16:
	lda	conchr			; get any console characters
	ora	a
	jz	get16			; re-start the loop
chk$chr$17:
; Check the character
	cpi	'Q'
	jz	quit
	cpi	'E'
	jz	start
	cpi	'W'
	jz	wait$16
	cpi	'P'
	jz	print$16
	cpi	'R'
	jz	test$16
	cpi	'?'				; menu required again ?
	jz	mmenu16
	cpi	'B'
	jz	do15				; do the test now
	cpi	'D'				; display ?
	jz	disp16
; Ell else is a miss-hit of the keyboard
	call	bell
; clear the byte then return to main loop
	xra	a
	sta	conchr
; Here we call the action loop which performs the iterations. This continues 
;till a key is pressed after which we jump up to the checking routine.
do15:
	xra	a
	sta	conchr
	mvi	d,30			; X = 30
	mvi	e,23			; y = 23, bottom line
	call	cursor
	call	cleol			; clear to end of line
	call	inline
	db	'Thousands of iterations = $'
do16:
	call	t$16$4			; call the routine
; Display the number of iterations
	mvi	d,58
	mvi	e,23
	call	cursor			; position for number display
	lhld	counts
	xchg
	call	pdde			; print as a decimal
; Check console status
	lda	conchr			; key pressed ?
	ora	a
	jrz	do16
	jmp	chk$chr$17
;
disp16:
	xra	a
	sta	conchr			; clear console flag
	call	clear
	call	display
	call	inline
	db	'  Waiting $'
	call	cie			; wait for a key press
	call	caps
	cpi	'C'
	jz	do15			; restart with display full
	jmp	mmenu16
;
print$16:
; Here we print the display
	call	listout
	call	crlf				; a little space
	call	display
	call	crlf
	call	flushloe			; flush the output
	call	consout
	jmp	mmenu16			; got and display the menu
;
wait$16:
	call	cie
	call	caps
	sta	conchr
	jmp	chk$chr$16 
;
;----------------------------------------------------------------
; Do 1000 iterations of incrementing the table.
;----------------------------------------------------------------
;
t$16$4:
;
	mvi	b,4			; Minor loop counter
t$16$250:
	push	b			; Save a major loop counter
	mvi	b,250			; Numbers
	call	chk$con
;
load$loop:
	lxi	d,seed			; point to the seed
	call	rand16			; Get a 16 bit number into hl
	mov	e,h			; put high byte into low byte
	mvi	d,00			; clear high byte
	lxi	h,table			; point to base of table
	dad	d
	dad	d			; index into a 16 bit item in the table
; increment the table item
	mov	d,m
	inx	h
	mov	e,m			; get original table value
	inx	d			; Increment the count value
	mov	m,e			; write back
	dcx	h
	mov	m,d
	djnz	load$loop		; End of the 250 loop
;
	pop	b
	djnz	t$16$250		; do the 250 loop 4 times
;
; After the loops, increment the number of loops.
	lhld	counts
	inx	h
	shld	counts			; bump the number of 1000 count loops
	ret
;
;----------------------------------------------------------------
; ---- Do a very similar function for the 8 bit version ----
;----------------------------------------------------------------
;
test$08:
	call	clear
	lxi	d,menu
	call	pmenu
	call	cie
;
	call	clear
	lxi	d,seed
	call	randinit		; set up generator
; Set up the table
	call	clear$table		; clear all of it to 00
	lxi	h,0
	shld	counts			; clear the loop counter
;
	xra	a
	sta	conchr
;
; Do 1000 iterations of incrementing the table.
;
t$08$4:
;
	mvi	b,4			; Minor loop counter
t$08$250:
	push	b			; Save a major loop counter
	mvi	b,250			; Numbers
;
load$loop$08:
	call	chk$con
	lxi	d,seed			; point to the seed
	call	rand8			; Get a 16 bit number into hl
	mov	e,a
	mvi	d,00
	lxi	h,table			; point to base of table
	dad	d
	dad	d			; index into a 16 bit item in the table
; increment the table item
	mov	d,m
	inx	h
	mov	e,m			; get original table value
	inx	d			; Increment the count value
	mov	m,e			; write back
	dcx	h
	mov	m,d
	djnz	load$loop$08		; End of the 250 loop
;
	pop	b
	djnz	t$08$250		; do the 250 loop 4 times
;
; After the loops, we ned to display the values on the screen
; or on the printer as desired.
	lhld	counts
	inx	h
	shld	counts			; bump number of 1000 counts
;
	call	display			; show table as we go, every 1000
chk$chr$08:
	lda	conchr
	ora	a
	jz	t$08$4
; Check the character
	cpi	'Q'
	jz	quit
	cpi	'E'
	jz	start
	cpi	'W'
	jz	wait$08
	cpi	'P'
	jz	print$08
	cpi	'R'
	jz	test$08
	cpi	'?'				; menu required again ?
	jz	menu$08
; All else is a miss-hit of the keyboard
	call	bell
	xra	a
	sta	conchr
	jmp	t$08$4
;
;
print$08:
; Here we print the display
	call	listout
	call	crlf				; a little space
	call	display
	call	crlf
	call	flushloe			; flush the output
	call	consout
	xra	a
	sta	conchr
	jmp	t$08$4				; do next iteration then
;
wait$08:
	call	cie				; get a character
	call	caps
	sta	conchr				; save it
	jmp	chk$chr$08 			; better check the character
;
menu$08:
	call	clear
	lxi	d,menu
	call	pmenu
	call	cie
	call	caps
	sta	conchr
	jmp	chk$chr$08
;
;
;----------------------------------------------------------------
; Display a screen of information which is a display of all the 
; boxes of the incremented counts.
;----------------------------------------------------------------
;
display:
	call	chk$con
	xra	a
	sta	pocket
	lxi	d,01100h			; column 17, line 0
	call	cursor
	call	inline
	db	'Thousands of Iterations = $'
	lhld	counts
	xchg					; load counts into de
	call	chk$con
	call	pdde				; print as a decimal
	call	chk$con
	call	crlf
; Now the data for the rest of the screen
	lxi	h,table				; start of table
	mvi	b,21				; 21 lines
	mvi	c,12				; elements to do in each line
;
disp$loop:
	call	chk$con
	call	do$line
	djnz	disp$loop
	mvi	c,4
	call	do$line
	ret
;
; Diosplay (C) decimal 16 bit digits across the screen
;
do$line:
	push	b
	push	d
	mov	b,c				; elements to be done
; Display the pocket number
	call	crlf
	call	chk$con
	lda	pocket
	call	pdacc				; print the number
	call	chk$con
	call	inline
	db	' > $'
; Update the number then store back into memory
	lda	pocket
	add	c				; add the number of pockets 
	sta	pocket
;
dol$loop:
	call	chk$con
	mov	d,m
	inx	h
	mov	e,m
	inx	h				; loaded 16 bits and updated
	call	pdde
	call	chk$con
	mvi	a,' '
	call	dispatch
	djnz	dol$loop
; restore and return
	pop	d
	pop	b
	ret
;
;
; Initialize the random number counter table to 00
;
clear$table:
	lxi	h,table
	mvi	m,00
	lxi	d,table + 1		; Destination
	lxi	b,511			; elements
	ldir				; clear the table
	ret
;
; Check the console for a character
;
chk$con:
	call	cst
	rz
	call	cie
	call	caps
	sta	conchr
	ret
;
;----------------------------------------------------------------
;
disp:
	db	21,04,'Random Number Generator test$'
	db	21,05,'----------------------------$'
	db	21,07,'      Options are$'
	db	21,08,'1) 8 Bit random number test$'
	db	21,09,'2) 16 Bit random number test$'
	db	21,10,'Q) Quit to CP/M$'
	db	21,11,'?$'
	db	0ffh
;
menu:
	db	21,04,'Random Number Generator test$'
	db	21,05,'----------------------------$'
	db	25,07,'Test options available are$'
	db	21,09,'P = Send results to printer$'
	db	21,10,'R = Restart the current test$'
	db	21,11,'E = End the current test$'
	db	21,12,'W = Wait for a key press$'
	db	21,13,'B = Begin test iterations$'
	db	21,14,'D = Display results$'
	db	21,15,'? = Display this menu$'
	db	21,16,'Q = Quit to CP/M$'
	db	30,23,'Press a key to start$'
	db	0ffh
;
counts	db	00,00
pocket	db	00,00
conchr	db	00			; console character
;
;
seed:	db	7,143,7,8,11,98,179,90
;
table	ds	511
	db	00
;
;
	end
;

