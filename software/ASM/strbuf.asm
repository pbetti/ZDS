;----------------------------------------------------------------
; 	    This is a module in the ASMLIB library.
; 
; This module will move a string into a standard console
; buffer. This allows easy character movement. On entry DE ->
; the start of the string (character counter) and HL -> the 
; start of the console buffer.
;
; 			Written		R.C.H.	     1/10/83
;			Last Update	R.C.H.	     1/10/83
;----------------------------------------------------------------
;
	name	'strbuf'
	public	strbuf
	maclib	z80
;
strbuf:
; Here DE -> string (source) , HL -> buffer (dest).
	push	b			; Save 
	xchg
; HL -> string (source), DE -> buffer (dest).
	mov	a,m			; the size
	ora	a			; String size = 0 ??
	jrz	strbufend
	mov	c,a
	mvi	b,00			; Set up the move
	inx	d			; Index past the size byte
	ldir				; Move the data
;
strbufend:
	pop	b
	ret
;
	end


