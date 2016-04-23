;----------------------------------------------------------------
;         This is a module in the ASMLIB library
;
;     Capitalize a standard CP/M console buffer => by DE.
;
;			Written     	R.C.H.     16/8/83
;			Last Update	R.C.H.	   22/10/83
;----------------------------------------------------------------
;
	name	'capsbuf'
;
	public	capsbuf
	extrn	caps
	maclib	z80
;
capsbuf:
	push	psw
	push	d			; save buffer address
	push	b			; save from the counter
	inx	d			; now DE -> character in the buffer
	ldax	d			; get it
	ora	a
	jrz	capsend			; return if no characters there
	mov	b,a			; load counter
; loop here for all the characters in the buffer
caploop:
	inx	d			; point to next character in the buffer
	ldax	d			; fetch
	call	caps			; make upper case
	djnz	caploop
capsend:
	pop	b
	pop	d
	pop	psw
	ret
;
	end

