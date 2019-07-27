;----------------------------------------------------------------
;        This is a module in the ASMLIB library
; 		Compare HL to DE.
; Return zero if equal, carry if DE > HL
;
;			Written     	R.C.H.     16/8/83
;			Last Update	R.C.H.	   04/04/84
;----------------------------------------------------------------
;
	name	'comdh'
;
	public	comdh
	maclib	z80
;
comdh:
	push	b
	mov	b,a			; save accumulator
	mov	a,h
	cmp	d			; generate a carry if D > H
	jrc	dbigh			; d > h
	mov	a,l
	cmp	e			; A carry may be made here too
dbigh:
	mov	a,b			; restore old accumulator
	pop	b			; restore
	ret
;
	end

