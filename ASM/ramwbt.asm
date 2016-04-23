;----------------------------------------------------------------
;        This is a module in the ASMLIB library.
;
; This is a walking bit ram test that moves the following bytes
; through memory from m(de) to m(hl). After each move the pattern
; is tested.
;
; 000 then test
; 0ff then test
; 0aa then test
; 055 then test
; single bit rotated then test
;
; If memory fails then HL-> memory in error, carry set, A = test value
; that caused the error.
;
;				Written        R.C.H.     22/10/83
;                               Last Update    R.C.H.     24/10/83
;----------------------------------------------------------------
;
	name	'ramwbt'
	public	ramwbt
	maclib	z80
;
;
ramwbt:
	push	d			; save the start of ram to test
	dsbc	d			; now hl = end - start = size to test
	xchg				; de = size to test
	pop	h			; hl -> start now
; Test if size is 00
	mov	a,e
	ora	d			; is d = e = e ??
	rz				; Exit if so.
	mov	b,d
	mov	c,e			; put a copy into bc
;
; Perform the 00 fill and test test.
;
	xra	a			; get a zero
	call	filcmp			; do the test
	rc				; return with error
;
; use a FF next to fill and test memory
;
	mvi	a,0ffh
	call	filcmp
	rc				; return on carry if error
;
; use an AAh next
;
	mvi	a,0aah
	call	filcmp			
	rc
;
; Use a 55 next
;
	mvi	a,055h
	call	filcmp
	rc
;
; Perform the simple walking bit test next. This moves a 1 across a bit field
; and writes/reads it through memory.
;
wlklp:
	mvi	a,80h
wlklp1:
	mov	m,a
	cmp	m			; can we read it back ??
	stc				; set carry in case of error
	rnz				; no match and return an error
	rrc				; shift right by 1 bit then
	cpi	080h
	jrnz	wlklp1			; keep on
	mvi	m,00			; clear this byte then
	inx	h
	dcx	b
	mov	a,b
	ora	c			; is b = c = 0 ??
	jrnz	wlklp
	mvi	m,00			; clear last byte of memory
	ret 				; return all is well
;
; This is the routine that must fill memory with the byte that is in
; A from Hl to HL + BC and then check if memory is ok or not.
; If an error then return the carry flag set.
;
filcmp:
	push	h
	push	b
	mov	e,a			; save test value
	mov	m,a			; write original into memory
	dcx	b			; one less byte
	mov	a,b
	ora	c
	mov	a,e
	jrz	compare			; if 1 byte then compare and exit
;
	mov	d,h
	mov	e,l
	inx	d
	ldir				; fill memory
;
; Here we can test memory to see if it reads the same back
;
compare:
	pop	b
	pop	h
	push	h
	push	b
cmplp:	; Compare loop
	cci				; compare a block of memory
	jrnz	cmper			; jump if not equal
	jpe	cmplp
; here and no errors.
	pop	b
	pop	h
	ora	a
	ret
;
; Here is the error return.
;
cmper:
	pop	b
	pop	d
	stc
	ret
;
;
	end




