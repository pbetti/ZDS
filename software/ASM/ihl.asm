;----------------------------------------------------------------
;         This is a module in the ASMLIB library
;
; The two entry points in this module read ascii from the KEYBOARD
; and convert to a number into the Hl register pair.
;
; 1) IDHL	Read a DECIMAL number into HL. Note that the result 
;		is HEX still so that it can be used as a counter 
;		ie. 100 input returns HL = 64.
; 2) IHHL	Read a HEX number into HL
;
; Both routines return zero in A if the last character read was a legal
; digit else A will contain the error character.
;
;			Written		R.C.H.         	19/8/83
;			Last Update	R.C.H.		22/10/83
;----------------------------------------------------------------
;
	name	'ihl'
;
	public	idhl,ihhl
	extrn	cbuff,caps		; get a line from console etc
;
	maclib	z80
;
idhl:
	call	get$buf			; load the buffer from console
	lxi	h,0
	lda	bufsiz
	ora	a
	rz				; quit if nothing read
; Now read the buffer, condition, put into HL.
	push	b			; save
	push	d
	mov	b,a			; use as a counter
idhl2:
	call	get$chr			; Get a character
; Convert to a binary value now of 0..9
	sui	'0'			
	jrc	inp$err 		; Error since a non number
	cpi	9 + 1			; Check if greater than 9
	jrnc	inp$err
; Now shift the result to the right by multiplying by 10 then add in this digit
	mov	d,h			; copy HL -> DE
	mov	e,l
	dad	h			; * 2
	dad	h			; * 4
	dad	d			; * 5
	dad	h			; * 10 total now
; Now add in the digit from the buffer
	mov	e,a
	mvi	d,00
	dad	d			; all done now
; Loop on till all characters done
	djnz	idhl2			; do next character from buffer
	jr	inp$end			; all done
;
;
;----------------------------------------------------------------
; Read a HEX number into HL from the keyboard.
;----------------------------------------------------------------
;
ihhl:
	call	get$buf
	lxi	h,00
	lda	bufsiz
	ora	a
	rz				; return if no character read
;
	push	b
	push	d			; save
	mov	b,a
;
ihhl2:
	call	get$chr			; get a character
; Now convert the nibble to a hex digit 0..F
	sui	'0'
	cpi	9 + 1
	jrc	ihhl3			; mask in then
	sui	'A'-'0'-10
	cpi	16
	jrnc	inp$err
;
; Shift the result left 4 bits and MASK in the digit in A
ihhl3:
	dad	h
	dad	h
	dad	h
	dad	h			; shifted right 4 now
	ora	l			; mask in the digit
	mov	l,a			; put back
	djnz	ihhl2			; keep on till all digits done
;
inp$end:
	xra	a			; Zero is a goo exit
inp$end2:
	pop	d
	pop	b
	ret
;
inp$err:	; Here when a non digit is encountered
	lda	buftmp
	jr	inp$end2
;
; Subroutines for shared code etc....
;
get$buf:	; Load the buffer from the screen via CBUFF.
	push	d
	xra	a
	sta	buffer+1		; clear buffer original value
	lxi	d,buffer
	call	cbuff
	pop	d
	lxi	h,buftxt		; point to the start of text
	shld	bufadr			; set up a pointer
	lxi	h,00			; clear the result register
	ret
;
; Get a character from the buffer, capitalize it on the way
;
get$chr:
	push	h
	lhld	bufadr
	mov	a,m			; get the character
	sta	buftmp			; save the character
	inx	h			; point to next character
	shld	bufadr
	pop	h			; restore
; Now capitalize it
	jmp	caps
;
; ================
;
	dseg				; Save in the data segment
;
buftmp	db	00			; A temporary character store
bufadr:	db	00,00
buffer:	db	6			; maximum characters
bufsiz:	db	00			; characters read
buftxt:	db	00,00,00,00,00,00	; text buffer
;
	end

