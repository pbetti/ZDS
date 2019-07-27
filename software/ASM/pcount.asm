;----------------------------------------------------------------
;        This is a module in the ASMLIB library
;
; 		Print a string for (b) bytes
;
;			Written     	R.C.H.     16/8/83
;			Last Update	R.C.H.	   22/10/83
;----------------------------------------------------------------
;
	name	'pcount'
;
	public	pcount
	extrn	dispatch
	maclib	z80
;
pcount:
	push	psw
	mov	a,b
	ora	a
	jrz	pcount3
	push	b
	push	d
pcount2:
	ldax	d			; fetch ascii character
	call	dispatch		; print it
	inx	d			; increment memory reference
	djnz	pcount2			; decrement counter
;
	pop	d
	pop	b
pcount3:
	pop	psw

;
	ret

	end

