;----------------------------------------------------------------
;        This is a module in the ASMLIB library.
;
; This module is responsible for printing SIGNED 2's complement
; numbers. It does this by determining if the number is negative
; and if so prints a leading '-' character else it prints it
; as normally. This module links directly to the PDE module
; from which it uses the print routines, of course. Sample
; output is as below.
;
; Number (hex)	 No LZB	    LZB      BLZB      CLZB (*)
; Positives
;  0010		  0010     10          10       **10
;  0100		  0100	   100        100       *100
;  1000           1000     1000      1000       1000
; Negatives
;  800F		 -0010    -10       -  10      -**10
;  80FF	         -0100    -100      - 100      -*100
;  8FFF		 -1000    -1000     -1000      -1000
;
; As can be seen from the above, it is a little horrible
; with leading zero blanking, but tough luck. Functions
; enabled are.
;
;  pshde	Print signed hex de.
;  psdde	Print signed decimal de.
;
;			Written		R.C.H.        19/9/83
;			Last Update	R.C.H.	      22/10/83
;----------------------------------------------------------------
;
	name	'psgn'
	public	pshde,psdde
	extrn	comp2s,dispatch,pdde,phde
	maclib	z80
;
pshde:
	call	psign			; Print a '-' iff negative
	jmp	phde
;
psdde:
	call	psign
	jmp	pdde
;
; This routine will return if the number is positive else
; it will print a '-' sign then convert the number to positive 
; then return.
;
psign:
	push	psw
	mov	a,d			; Get sign carrying byte
	ani	080h
	ora	a
	jrz	pexit 			; Return if 00 (i.e. positive)
; Here we print the '-' sign
	mvi	a,'-'
	call	dispatch
	push	h
	call	comp2s			; Perform the 2's complement and return
	xchg				; Put result into DE
	pop	h			; Restore HL from the ordeal
pexit:
	pop	psw
	ret
;
	end



