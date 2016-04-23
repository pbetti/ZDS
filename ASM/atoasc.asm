;----------------------------------------------------------------
;         This is a module in the ASMLIB library.
;
; Convert A to ascii in HL. H = high byte ascii, L = low byte
;
;			Written     	R.C.H.     16/8/83
;			Last Update	R.C.H.	   16/8/83
;----------------------------------------------------------------
;
	name	'atoasc'
;
	public	atoasc
	extrn	nibasc
;
atoasc:
	push	psw			; save
	rar
	rar
	rar
	rar				; put top nibble into low
	call	nibasc			; convert
	mov	h,a			; save
	pop	psw
	call	nibasc			; convert low nibble
	mov	l,a
	ret				; easy wasn't it
	end

