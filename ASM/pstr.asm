;----------------------------------------------------------------
;        This is a module in the ASMLIB library
;
; Print a string of chracters B long. The character is in the 
; accumulator and is printed across the line. This makes doing 
; borders or boxes quite easy.
;
;			Written     	R.C.H.     16/8/83
;			Last Update	R.C.H.	   22/10/83
;----------------------------------------------------------------
;
	name	'pstr'
;
	public	pstr
	extrn	dispatch
	maclib	z80
;
pstr:
	push	psw
pstr2:
	call	dispatch		; print the character
	djnz	pstr2			; do till done
	pop	psw
	ret
;
	end
