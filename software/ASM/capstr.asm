;----------------------------------------------------------------
; 	    This is a module in the ASMLIB library.
;
; This routine will capitalize the standard string pointed to by DE
; using the CAPS external routine.
;
;			Written        	R.C.H.      1/10/83
;			Last Update	R.C.H.	    1/10/83
;----------------------------------------------------------------
;
	name	'capstr'
	public	capstr
	extrn	caps
	maclib	z80
;
capstr:
	ldax	d			; Get length
	ora	a
	rz				; Exit if string empty
	mov	b,a			; Load as a counter
caploop:
	inx	d
	ldax	d			; Get a character
	call	caps
	stax	d			; Send back the capitalized character
	djnz	caploop			; Keep on for all string
;
	ret

	end


