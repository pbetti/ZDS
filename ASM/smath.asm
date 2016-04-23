;----------------------------------------------------------------
;         This is a module in the ASMLIB library.
;
; This module is responsible for signed arithmetic. A signed
; number is represented in 16 bits as 2's complement so that
; numbers of up to +/- 32k are possible. Supported operations
; are....
;
; sgnadd	HL = DE + HL	Signed add.
; sgnsub	HL = DE - HL	Signed subtract.
; comp2s	HL = 2'complement of DE
;
;			Written		R.C.H.		19/9/83
;			Last Update	R.C.H.		19/9/83
;----------------------------------------------------------------
;
	name	'sgnmath'
	public	sgnadd,sgnsub,comp2s
	maclib	z80
;
sgnadd:
	dad	d			; HL = HL + DE
	ret
;
; Subtraction is the SAME as adding the twos complement so we simply take
; the twos complement of HL then jump to the adder.
;
sgnsub:
	push	d
	xchg				; Put HL into DE
	call	comp2s			; HL becomes 2' DE
	pop	d			; Restore original DE
	jr	sgnadd
;
; The twos complement is performed by complementing all the bits in the
; input number in DE then adding 1.
;
comp2s:
	push	psw
	mov	a,d
	cma				; Complement
	mov	h,a			; Copy to result
	mov	a,e
	cma
	mov	l,a			; Copy low vlue to result
	inx	h			; Bump to make 2's complement
	pop	psw			; Restore the only affected register
	ret

	end


