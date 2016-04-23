;----------------------------------------------------------------
;         This is a module in the ASMLIB library.
;This module contains....
; 1) BELL	Rings the console bell
; 2) CLEAR	Clear the screen
; 3) CRLF	Send a crlf pair to the screen
; 4) CURSOR	Position the cursor to D = X, E = Y
; 5) SETXY   	Position cursor. DE -> to 2 bytes, X and Y.
; 6) CLEOL	Clear to end of line. Leave cursor alone.
; 7) CLEOP	Clear to end of page. Leave cursor alone.
;
; Note that all functions are table driven except for bell and crlf.
; The table has an ID string of 00 1a 1a 02 which is patched by
; application programs for different terminals.
;
;			Written     	R.C.H.     16/8/83
;			Last Update	R.C.H.	   30/11/83
;----------------------------------------------------------------
;
	name	'screen'
;
	public	bell,clear,crlf,cursor,setxy,cleop,cleol
	public	curon,curoff
	extrn	dispatch
	maclib	z80
;
;----------------------------------------------------------------
; 		Ring the console bell.
;----------------------------------------------------------------
;
bell:
	push	psw
	mvi	a,07
bell2:
	call	dispatch		; to console
	pop	psw
	ret
;
;----------------------------------------------------------------
;             Send a CR LF pair to the screen
;----------------------------------------------------------------
;
crlf:
	push	psw
	mvi	a,0dh
	call	dispatch
	mvi	a,0ah
	jr	bell2
;
;----------------------------------------------------------------
; 			Clear the screen
;----------------------------------------------------------------
;
clear:
	push	b
	push	h			; save
	push	psw
	lxi	h,cpfn			; clear page function
	jr	do$fn			; send the function and return
;
;----------------------------------------------------------------
; Clear the screen till the end of the line. This is highly
; terminal dependant and is table driven to suit.
;----------------------------------------------------------------
;
cleol:
	push	b
	push	h			; save
	push	psw
	lxi	h,clfn			; clear page function
	jr	do$fn			; send the function and return
;
;----------------------------------------------------------------
; Clear to the end of the page. Same comments as the above fn.
;----------------------------------------------------------------
;
cleop:
	push	b
	push	h			; save
	push	psw
	lxi	h,epfn			; clear page function
	jr	do$fn			; end of job
;
;
; This routine uses HL to send the fnction to the
; screen.
;
send$fn:
	mov	a,m			; test if this is not supported
	ora	a
	rz				; not supported if no bytes to send
	mov	b,a			; load a counter
send$fn2:
	inx	h			; get next byte
	mov	a,m
	call	dispatch
	djnz	send$fn2
	ret
;
; Send the function pointed to by HL to the terminal then exit
;
do$fn
	call	send$fn			; send it.
; Fall through to the exit routine
end$fn:
	pop	psw
	pop	h
	pop	b
	ret
;
;----------------------------------------------------------------
; Enable the cursor.
;----------------------------------------------------------------
;
curon:
	push	b
	push	h
	push	psw
	lxi	h,ecfn		; enable cursor function
	jr	do$fn
;
;----------------------------------------------------------------
; Disable the cursor
;----------------------------------------------------------------
;
curoff:
	push	b
	push	h
	push	psw
	lxi	h,dcfn
	jr	do$fn
;
;----------------------------------------------------------------
; Position the cursor to the value in DE. D = X, E = Y.
; This is a highly painful routine which must use a table to send the
; correct codes to suit the terminal in use. This naturally must
; do the correct lead ins, correct offset, correct row/column sequence
; so there is a bit of code. Sorry.
;----------------------------------------------------------------
;
cursor:
	push	b
	push	h
	push	psw			; save registers
	push	d			; save the original
; Send the lead in string
	lxi	h,xyfn			; XY addressing lead in string
	call	send$fn
; Now we must add the offsets to be applied to the X and Y values
	lda	xoff
	add	e			; Y value
	mov	e,a			; save it
;
	lda	yoff
	add	d			; X value
	mov	d,a			; save it also
; Now decode the row or column sent first decision
	lda	rowcol			; 00 = row first
	ora	a
	jrz	row$first
; Here and we are sending the column first (X value first)
	mov	a,d			; X value
	call	dispatch
	mov	a,e			; Y next
	jr	row$first2
; Here and we send the row first for cursor addressing
row$first:
	mov	a,e			; Y value
	call	dispatch
	mov	a,d			; X value next
row$first2:
	call	dispatch
	pop	d			; restore original cursor address
	jr	end$fn			; restore registers and return
;
;----------------------------------------------------------------
; Set the cursor up according to two bytes in ram which contain
; the X and Y addresses in them. The bytes --> by DE.
;----------------------------------------------------------------
;
setxy:
	push	d			; save 
	push	h
	xchg				; HL --> bytes
	mov	d,m			; load X value
	inx	h
	mov	e,m
	call	cursor			; Set it up
	pop	h			; restore all now
	pop	d
	ret
;
;****************************************************************
; This is the function table which is used for all hardware
; dependant code. This table is patched by application programs
; which find the 00 1a 1a 02 and patch it for different terminals
; Each entry is 5 bytes long. Cursor addressing takes two entries
;****************************************************************
;
id:
	db	0ffh,01ah,0ffh,01ah,02	; 5 byte i.d. code
;
xyfn:	db	02,01bh,'=',00,00	; xy addressing
; The next 5 bytes are the cursor flags and offsets
rowcol:	db	00			; 00 means row first
xoff:	db	32			; X offset
yoff:	db	32			; Y offset
filler	db	00,00			; to make the 5
;
cpfn	db	02,01bh,'*',00,00	; erase whole page
clfn	db	02,01bh,'T',00,00	; erase to end of line
epfn	db	02,01bh,'Y',00,00	; erase to end of page
ecfn	db	00,00,00,00,00		; enable cursor function
dcfn	db	00,00,00,00,00		; disable cursor function
;
	end


