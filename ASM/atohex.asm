;----------------------------------------------------------------
;         This is a module in the ASMLIB library
;
; Convert the accumulator character into a hex digit
;
;			Written     	R.C.H.     16/8/83
;			Last Update	R.C.H.	   16/8/83
;----------------------------------------------------------------
;
	name	'atohex'
;
	public	atohex
	extrn	caps
;
atohex:
	call	caps			; make upper case
	sui	'0'
	cpi	10			; check range
	rc				; return since it is 0..9
	sui	'A' - '0' - 10		; make into hex digit then
	ret				; all easy tooooooo
;
