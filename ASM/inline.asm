;----------------------------------------------------------------
;         This is a module in the ASMLIB library
;
;
;
; Print the string which follows the call instruction that got
; us to this point. NOTE that a JMP must never be done to
; enter this routine.
;
;
;
;			Written     	R.C.H.     16/8/83
;			Last Update	R.C.H.	   22/10/83
;----------------------------------------------------------------
;
	name	'inline'
;
	public	inline
	extrn	dispatch
	maclib	z80
;
inline:	
	xthl				; get address of string (ret address)
	push	psw
inline2:
	mov	a,m
	inx	h			; point to next character
	cpi	'$'
	jrz	inline3
	call	dispatch
	jr	inline2
inline3:
	pop	psw
	xthl				; load return address after the '$'
	ret				; back to code immediately after string
;
;
;
;
;
;
	end




