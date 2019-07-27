;----------------------------------------------------------------
;         This is a module in the ASMLIB library. 
;
; Convert the ascii characters -> by DE into a pair of hex digits 
; into HL.
;			Written		R.C.H.		16/8/83
;			Last Update	R.C.H.		16/8/83
;----------------------------------------------------------------
;
	name	'aschex'
;
	public	aschex
	extrn	caps
	maclib	z80
;
aschex:
	lxi	h,00			; clear to initialize
aschex2:	; loop here to read memory characters and make them into hex's
	ldax	d			; Get a character
	inx	d			; Point to next character
	call	caps			; Make upper case
	sui	'0'
	cpi	10
	jrc	aschex3
	sui	'A' - '0' - 10
	cpi	16			; Check if NON LEGAL character
	rnc
aschex3:	; Mask in the digit
	dad	h
	dad	h
	dad	h
	dad	h			; move right 4 places
	ora	l			; mask in
	mov	l,a			; re-load
	jr	aschex2
	end


