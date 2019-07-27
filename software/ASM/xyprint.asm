;----------------------------------------------------------------
;         This is a module in the ASMLIB library
;
; This module will read a string which follows the return address
; and uses the first 2 bytes as a CURSOR address to print the
; string. This makes it easy to print strings at a screen
; location. 
;
; The second entry point will take the string --> by DE and use the two
; bytes at the start of it for a acreen address.
;
;			Written		R.C.H.      	18/8/83
;			Last Update	R.C.H.		22/10/83
;----------------------------------------------------------------
;
	name	'xyprint'
;
	public	xyinline,xypstring
	extrn	setxy,dispatch
	maclib	z80
;
xyinline:
	xthl			; HL -> string, old hl in stack
	xchg			; now DE --> string
	call	setxy		; set it up
	xchg			; now hl --> string start again
	call	print
	xthl			; hl = original value, stack = return address
	ret
;
;----------------------------------------------------------------
; Print the string --> by DE. Use the two bytes at the start of it
; as a screen address.
;----------------------------------------------------------------
;
xypstring:
	push	h
	call	setxy			; set up screen
	xchg				; now hl --> string start
	call	print
	xchg				; Restore DE --> past end of string
	pop	h
	ret
;
;       ---- Utility to print s atring till a $. ----
; On return HL -> to next byte after the string (code maybe)
print:
	push	psw
	inx	h
	inx	h		; skip over cursor address
print2:
	mov	a,m
	inx	h		; Point to next character
	ora	a		; null is allowed to end a string
	jz	print3
	cpi	'$'		; End of string ?
	jz	print3
	call	dispatch
	jr	print2
print3:
	pop	psw
	ret
;
	end




