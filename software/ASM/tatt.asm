;----------------------------------------------------------------
; This is a test program which uses all the attributes and all
; the functions available in the ASMLIB library. This allows the
; user to quickly try out a terminal definition fully before 
; integrating it into the rest of his programs.
;
; This program will
; Erase screen, display terminal id and a menu to...
; 1) Test cursor positioning and enable / disable
; 2) Test all the video attributes
; 3) Test erase to end of line and erase to end of screen screen
; 4) Offer to do any or all tests again.
;
;			Written      R.C.H.        30/11/83
;			Last Update  R.C.H.        04/01/84
;----------------------------------------------------------------
;
;
	extrn	prolog,coe,dispatch,inline,quit,setatt,tname,cst
	extrn	clear,crlf,cie,caps,bell,cleol,cleop,pcount,idhl
	extrn	pstr,setxy,delay,xyinline,pmenu,cursor,curon,curoff
;
left	equ	01			; Used by cursor positioning
up	equ	02			; for direction sensing
right	equ	03
down	equ	04
;
	maclib	z80
;
	call	prolog
start:
	call	clear
	call	xyinline		; position the cursor
	db	21,04,'Terminal Test Program$'
	call	xyinline
	db	18,05,'Current terminal is $'
;
	call	tname
	xchg
	mvi	b,6
	call	pcount
	lxi	d,menu
	call	pmenu
;
start1:
	call	cie
	call	caps
	cpi	03			; control c exit now
	jz	quit			; abort, quick
	cpi	'1'
	jz	test$att		; test video attributes
	cpi	'2'
	jz	test$cursor
	cpi	'3'
	jz	test$erase
	cpi	'4'
	jz	logon
	cpi	'Q'
	jz	exit
	jmp	start
;
exit:
	mvi	a,0f8h
	call	coe
	jmp	quit
;
logon:
	call	inline
	db	0dh,0ah,0ah,'What Channel ? $'
	call	idhl
	mov	a,l			; get low byte
	ori	0f8h			; mask in selector byte offset
	call	coe			; Log onto an MPC-6 channel
	jmp	start			; Display menu etc
;
finish:
	call	xyinline
	db	0,23,'Press a key to continue :$'
	call	cie
	cpi	03
	jz	quit			; control c to exit now
	jmp	start
;
;----------------------------------------------------------------
; Test a terminals video attributes by positioning the cursor
; against the left hand edge and printing string in reverse
; video. If the attribute gobbles a screen position then the string
; will be positioned one space away from the right hand edge.
;----------------------------------------------------------------
;
test$att:
	call	clear			; erase the screen
	lxi	d,02			; x = 0, y = line 2
	call	cursor			; position it
; half intensity
	mvi	a,1
	call	setatt
	call	inline
	db	'This is printed in 1/2 intensity$'
	xra	a
	call	setatt
; Blinking characters
	lxi	d,05			; x = 0 y = 5
	call	cursor			; position the cursor
	mvi	a,2
	call	setatt
	call	inline
	db	'This is printed as blinking characters$'
	xra	a
	call	setatt
; Reverse video
	lxi	d,7			; x = 0 y = 7
	call	cursor
	mvi	a,3
	call	setatt
	call	inline
	db	'This is printed as reverse characters$'
	xra	a
	call	setatt
; Underlined code
	lxi	d,9
	call	cursor
	mvi	a,4
	call	setatt
	call	inline
	db	'This is printed as underlined characters$'
	xra	a
	call	setatt
	jmp	finish			; return to the program start again
;
;----------------------------------------------------------------
; The following tests the screen clear functions, clear to end 
; of line and clear to end of page.
;----------------------------------------------------------------
;
test$erase:
	call	clear			; erase the screen
	mvi	b,23			; do all lines
;
; Fill the screen by sending 24 full lines of 'X' characters
;
fill1:
	push	b
	mvi	b,79
fill2:
	mvi	a,'X'
	call	coe
	call	xonof
	djnz	fill2
;
	call	crlf
	call	xonof
	pop	b
	djnz	fill1
;
	call	xyinline
	db	5,3,'Erase to end of line$'
	call	cleol
	lxi	d,1000
	call	delay
;
	call	xyinline
	db	5,7,'Erase to end of page$'
	call	cleop
	lxi	d,1000
	call	delay			; wait a second

	jmp	finish
;
;----------------------------------------------------------------
; This section tests the cursor positioning by displaying a pattern
; on the screen. This is all done with cursor positioning and 
; looks just ok. If the cursor positioning is a bit off then there
; is a horrible mess on the screen.
;----------------------------------------------------------------
;
test$cursor:
	call	clear
	call	curoff				; disable the cursor
	lxi	d,02800h			; x = 40, y = 0
	mvi	b,23				; do all lines
tc1:
	call	cursor				; set up
	inr	e				; go down the screen
	mvi	a,'|'
	call	coe				; display
	call	xonof			; do a little handshaking
	djnz	tc1
;
	lxi	d,12				; x = 0, y = 12
	mvi	b,79				; do all columns
;
tc2:
	call	cursor
	inr	d				; go right across the screen
	mvi	a,'-'
	call	coe
	call	xonof			; do a little handshaking
	djnz	tc2
;
; Put an X in the middle now
	lxi	d,280Ch				; x = 40, y = 12
	call	cursor
	mvi	a,'+'
	call	coe
	call	xonof			; do a little handshaking
; now do a spiral around the center of the screen
; DE -> center of the ecreen still at this point
; Use A as the spiral side length
; Use B as the counter of spiral sides. 24 = a full page
; Use C as the spiral direction (l,r,u,d) 
;    
	mvi	c,1			; side size
	mvi	b,23			; do a whole page
	mvi	a,left			; direction to draw
;
spiral$loop:
	call	draw$side		; draw a side
	inr	a			; next direction
	inr	c			; increment side size counter
	cpi	5			; no more sides ??
	jrnz	spiral$loop1
	mvi	a,left			; at the start again
spiral$loop1:
	djnz	spiral$loop
	jmp	finish			; all done
;
;---- Draw a side of the spiral according to direction and length
;
draw$side:
	push	psw
	push	b
	mov	b,c			; load the side size counter
; Decide which way we are going
	cpi	left			
	jrz	go$left
	cpi	right
	jrz	go$right
	cpi	up
	jrz	go$up
	jr	go$down
;
; Go up the screen. Decrement the Y screen address (E) only
go$up:
;
go$up1:
	dcr	e
	call	cursor			; go up by bumping the y address
	mvi	a,'I'
	call	coe
	call	xonof			; do a little handshaking
	djnz	go$up1
	jr	draw$side$end
;
; Go left by decrementing the X direction
go$left:
	mov	a,b
	add	a
	mov	b,a			; double it
go$left1:
	dcr	d
	call	cursor
	mvi	a,'='
	call	coe
	call	xonof			; do a little handshaking
	djnz	go$left1
	jr	draw$side$end
;
; go right across the screen by incrementing the x value
go$right:
	mov	a,b
	add	a
	mov	b,a
go$right1:
	inr	d
	call	cursor
	mvi	a,'='
	call	coe
	djnz	go$right1
	jr	draw$side$end
;
; Go down the screen by incrementing the y address
go$down:
;
go$down1:
	inr	e
	call	cursor
	mvi	a,'I'
	call	coe
	call	xonof			; do a little handshaking
	djnz	go$down1
;
; Restore registers and return to master loop
draw$side$end:
	pop	b
	pop	psw
	ret
;
;----====````====----
;
xonof:
	call	cst
	rz
	call	cie
	cpi	19 			; Control s ??
	rnz
;
xwait:
	call	cie
	cpi	17			; Control Q ??
	rz
	call	bell
	jr	xwait
;
;----------------------------------------------------------------
;
menu:
	db	22,08,'Test Options are$'
	db	17,10,'1) Test Video Attributes$'
	db	17,11,'2) Test Cursor positioning$'
	db	17,12,'3) Test screen erase functions$'
	db	17,13,'4) Log Onto an MPC-6 channel$'
	db	17,14,'Q) Quit to CP/M$'
	db	12,16,'--->?$'
	db	0ffh
;
	end
 