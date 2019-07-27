;----------------------------------------------------------------
;        This is a module in the ASMLIB library
;
; Print the string -> by DE terminated with a $ or a null.
;
;			Written     	R.C.H.     16/8/83
;			Last Update	R.C.H.	   20/11/83
;----------------------------------------------------------------
;
	name	'pstring'
;
	public	pstring
	extrn	dispatch
	maclib	z80
;
pstring:
	push	psw
	push	d
pstring2:
	ldax	d			; get the character
	inx	d			; always point to next character
	ora	a
	jrz	pstring3		; return if a null (00 hex)
	cpi	'$'			; end of string ??
	jrz	pstring3
	call	dispatch		; print it
	jr	pstring2
pstring3:
	pop	d
	pop	psw
	ret
;
	end

