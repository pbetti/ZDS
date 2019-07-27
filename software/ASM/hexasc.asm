;----------------------------------------------------------------
;        This is a module in the ASMLIB library
; Convert a HEX number in DE into 4 ASCII bytes --> by HL
;
;			Written     	R.C.H.     16/8/83
;			Last Update	R.C.H.	   16/8/83
;----------------------------------------------------------------
;
	name	'hexasc'
;
	public	hexasc
	extrn	atoasc
	maclib	z80
;
hexasc:
	push	b			; save
	mvi	b,2
hexasc2:
	push	d			; save
	mov	a,d
	xchg				; DE -> memory destination
	call	atoasc
	xchg				; now HL -> memory, DE = ascii bytes
	mov	m,d
	inx	h
	mov	m,e			; all done
	inx	h
	pop	d			; restore original conversion btyes
	mov	d,e			; get it ready
	djnz	hexasc2
; all done
	pop	b
	ret

	end


