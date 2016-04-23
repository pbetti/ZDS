;----------------------------------------------------------------
;	    This is a module in the ASMLIB library.
;
; 		Capitalize the accumulator.
;
;			Written     	R.C.H.     16/8/83
;			Last Update	R.C.H.	   16/8/83
;----------------------------------------------------------------
;
	name	'caps'
;
	public	caps
;
caps:
	cpi	'a'
	rc
	cpi	'z' + 1
	rnc
	ani	05fh
	ret
	end

