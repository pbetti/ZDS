;----------------------------------------------------------------
;        This is a module in the ASMLIB library
; This module has been written for range checking the accumulator 
; either a value in DE or against a table. This is useful for checking
; values against legal limits. 
;
; CHKRNG	Will check if D <= A >= E. If this fails then
;		the routine returns a NON-ZERO flag. Else 
;		it returns a zero flag.
;
; CHKTBL	Does the same check but uses DE as a pointer to
;		a table of ranges and addresses. Byte 1 in the table is
;		the high value and byte 2 the low value. If A FAILS to 
;		equal or fit b/n these values then the following 
;		address is jmp'd to. An example follows.
;
; Table	db	high1,low1,address1
;	db	high2,low2,address2
;       "	"  "  "  "  "  "  "
;	db	lown,highn,addressn
;
; 	lxi	d,table			; Check against the first element
;	call	chktbl			; check the table
;	; Here is returned to if the value in A is between elemnts of the table
;	; on exit DE--> next table element if we passed, else goto the address.
;	
;			Written		R.C.H.	      	18/8/82
;			Last Update	R.C.H.		18/8/83
;----------------------------------------------------------------
;
	name	'chkrng'
;
	public	chkrng,chktbl
	maclib	z80
;
chkrng:	; See if D <= A <= E
	sta	temp				; Save the value
	cmp	d
	jrz	chkrng15
	jrnc	rng$fail			; NO CARRY = A is too big
chkrng15:
	cmp	e
	jrc	rng$fail
	xra	a				; Load ZERO indicator flag
chkrng2:	; Restore the accumulator and return
	lda	temp	
	ret
;
rng$fail:	; Load a non zero flag and return
	mvi	a,0ffh
	ora	a				; ensure ZERO is OFF-A-MUNDO
	jr	chkrng2				; Re-load accumulator and exit
;
;
chktbl:	; Check a table against the value in A
	push	h
	xchg				; HL --> table
	mov	d,m			; high value
	inx	h
	mov	e,m			; low value
	inx	h			; now we point to address field
	call	chkrng			; check the range now
	jrnz	goto$address		; WE FAIL if NON ZERO
	inx	h
	inx	h			; point to next table element now
	xchg				; put into de again
	pop	h
	ret
;
; Here is jumped to if the accumulator does not fit between the values
; in the table. This routine must load the table address and jump to it.
;
goto$address:
	mov	e,m			; low address stored first
	inx	h
	mov	d,m			; high address
	inx	h			; point to next table element for later
	xchg				; now DE = table addr, HL = address
	xthl				; HL = original , top = address
	lda	temp
	ret			; goto the address
;
	dseg				; data segment
temp	db	00			; save the accumulator temporarily

	end


