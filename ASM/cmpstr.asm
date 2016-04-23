;----------------------------------------------------------------
; 	This is a module in the ASMLIB library.
;
; This module will compare two strings and return flags to indicate
; equality or size difference. This routine was taken from the book
; Z-80 Subroutines By Saville and Leventhal. Modifications have been
; done for TDL opcodes and to change parameter passing so that 
; string 1 is pointed to by DE and string 2 by HL.
; A string is up to 255 bytes long and is preceded by its length.
;
; Returned flage are.		Carry	Zero
;   string 1 = string 2   	  0       1
;   string 1 > string 2		  0       0
;   string 1 < string 2           1       0
;
; 			Written		R.C.H.	     1/10/83
;			Last Update	R.C.H.	     1/10/83
;----------------------------------------------------------------
;
	name	'cmpstr'
	public	cmpstr
	maclib	z80
;
cmpstr:
	push	b			; Save
	xchg				; Put into order
	mov	a,m			; Length string 1
	sta	lens1
	ldax	d			; Length string 2
	sta	lens2
	cmp	m			; compare lengths
	jrc	begcmp			; jump if string 1 is shorter
	mov	a,m			; string 1 is shorter
;
begcmp:
	ora	a			; Test if shorter length is zero
	jrz	cmplen			; Compare lengths then
	mov	b,a			; Load a counter
	xchg				; swap string pointers
cmplp:	; Loop here to check characters
	inx	h
	inx	d			; Bump character pointers
	ldax	d
	cmp	m			; Compare string bytes
	jrnz	strend
	djnz	cmplp			; Keep on till all characters done
; Here, all characters are equal so we test the lengths and use this for the
; flags.
cmplen:	; Compare lengths of the strings
	lda	lens1
	lxi	h,lens2			; Point to second length
	cmp	m			; Do the compare
strend:
	pop	b			; Restore
	ret
;
	dseg
lens1:	db	00
lens2:	db	00
	
	end



