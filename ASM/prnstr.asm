;----------------------------------------------------------------
;	    This is a module in the ASMLIB library.
;
; This module prints a string that has the size of it
; stored before the characters, IE a standard PL/I, BASCIC or
; PASCAL string.
;
;			Written		R.C.H.       1/10/83
;			Last Update	R.C.H.	     1/10/83
;----------------------------------------------------------------
;
	name	'prnstr'
	public	prnstr
	extrn	pcount
;
prnstr:
	ldax	d		; DE -> string start
	ora	a
	rz			; Exit if zero length
	push	b
	mov	b,a		; Load a counter
	inx	d		; Point to text
	call	pcount		; Do the job
	pop	b
	ret			; All done
;
	end











