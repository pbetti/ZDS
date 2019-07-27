;----------------------------------------------------------------
;        This is a module in the ASMLIB library
;
; This module prints DE as either 4 hex digits or as 5 deciaml 
; digits.  Leading Zero blanking is done externally.
;
;			Written     	R.C.H.     16/8/83
;			Last Update	R.C.H.	   31/12/83
;----------------------------------------------------------------
;
	name	'pde'
	public	phde,pdde
	extrn	phacc,?phacc2,?clrblank,?result,hexbcd
	extrn	?lzprint,nibasc,?pdacc2
;
phde:
	call	?clrblank		; Clear lzb blanking byte
	mov	a,d			; do upper 2 digits
	push	psw
	rar
	rar
	rar
	rar				; Put right nibble into low nibble
	call	nibasc			; Convert to ascii
	call	?lzprint		; Standard leading zero print it
	pop	psw
	ani	0fh			; Mask off top nibble
	call	nibasc
	call	?lzprint		; Leading zero print this digit too
;
; Now we can use standard printing to do the lower digits
	mov	a,e			; lower 2 bytes
	jmp	?phacc2			; do it too, all done
;
;----------------------------------------------------------------
;             Print DE as 5 decimal digits
;----------------------------------------------------------------
;
pdde:
	call	?clrblank
	push	h
	push	d
	lxi	h,?result
	call	hexbcd			; convert to ascii in internal buffer
; Now print the 5 digit number
	lda	?result+2		; get the MSDigit
	call	nibasc			; convert lower nibble
	call	?lzprint		; print it
; Now do the other 4 digits
	lda	?result+1
	push	psw
	rrc
	rrc
	rrc
	rrc
	call	nibasc
	call	?lzprint
	pop	psw
	call	nibasc
	call	?lzprint
; Low two
	jmp	?pdacc2
	end




