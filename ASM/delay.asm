;----------------------------------------------------------------
; This is a module in the ASMLIB library.
;
;       Delay for the number of milliseconds in DE
;
;			Written     	R.C.H.     16/8/83
;			Last Update	R.C.H.	   22/10/83
;----------------------------------------------------------------
;
	name	'delay'
;
	public	delay
	maclib	z80
;
delay:
	push	psw
	push	d			; save it
delay2:
	call	delay3
	dcx	d			; one less millisecond less overhead
	mov	a,d
	ora	e
	jrnz	delay2			; keep on till DE = 0
	pop	d			; restore users initial value
	pop	psw
	ret				; back to user
;
delay3:	; delay 1 millisecond less the overhead involved in the above code.
;
; This routine must delay 3957 t-states
;
	push	b			; 11
	mvi	b,230			;  7
delay4:	; This loop does (4 + 13) * 230 - 5 = 3905 t
	nop				; 4
	djnz	delay4			; 13
; Fudge 14 machine cycles
	in	0			; 10
	nop				;  4
	pop	b			; 10
	ret				; 10
;
	end
