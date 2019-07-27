;----------------------------------------------------------------
; 	         This is a module in ASMLIB
;
; This module allows the user to get a Y or a N from the
; console (only) and to return a ZERO flag if it was a Y.
; The character is returned in A.
;
;			Written	    R.C.H.    11/02/84
;			Last Update R.C.H.    11/02/84
;----------------------------------------------------------------
;
;
	name	'getyorn'
	public	getyorn
	extrn	cie,dispatch,caps
;
	maclib	z80
;
getyorn:
	call	cie
	call	caps
	cpi	'Y'
	jrz	gy1
	cpi	'N'
	jrnz	getyorn
;
gy1:
	call	dispatch
	cpi	'Y'
	ret			; set ZERO flag if a Y
	end



