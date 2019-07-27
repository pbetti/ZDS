;----------------------------------------------------------------
; 	    This is a module in the ASMLIB library.
; 
; This module will move a standard console buffer into a 
; standard string. This also moves the size byte.
; This allows easy character movement. On entry DE ->
; start of the console buffer and HL -> the character string.
;
; 			Written		R.C.H.	     1/10/83
;			Last Update	R.C.H.	     1/10/83
;----------------------------------------------------------------
;
	name	'bufstr'
	public	bufstr
	maclib	z80
;
bufstr:
; Here DE -> buffer (source) , HL -> string (dest).
	push	b			; Save 
	xchg
; HL -> buffer (source), DE -> string (dest).
	inx	h			; Index past the buffer size byte
	mov	a,m			; Get the the size byte
	ora	a			; String size = 0 ??
	jrz	bufstrend
	mov	c,a			; Load the size.
	mvi	b,00			; Set up the move
	ldir				; Move the data
;
bufstrend:
	pop	b
	ret
;
	end


