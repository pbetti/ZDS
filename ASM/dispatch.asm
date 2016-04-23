;----------------------------------------------------------------
;	     This is a module in the ASMLIB library.
;
; Dispatch characters to one or both of COE LOE device drivers.
; This section works by using the dispatching byte that is loaded
; by the consout/listout/echolst routines. This allows some
; quite nice features and the table of addresses that is used allows
; the user to add drivers at will.
;
; This module also allows the user to select an external set of i/o
; drivers which are to be user for all further console I/O until any of
; consout/echolst/lstout the routines is called. This is called the USERIO 
; and it expects DE -> address table pointing to the console input, output
; and status routines respectively in that order. They must also
; preserve any registers.
;
;			Written     	R.C.H.     16/08/83
;			Last Update	R.C.H.	   11/02/84
;
; Added userio etc code for more re-direction		     R.C.H.  21/9/83
; Aded flushloe code to flush line printer buffer	     R.C.H.  17/10/83
; Shifted device drivers to external I/O module              R.C.H.  22/10/83
; Added X-on / X-off to dispatch			     R.C.H.  30/11/83
; Added ? to destbyte extrn name			     R.C.H.  31/12/83
; Added X-on / X-off equate				     R.C.H.  11/02/84
;----------------------------------------------------------------
;
	name	'dispatch'
;
	public	dispatch,userio,flushloe
	extrn	coe,loe,cie,cst
	extrn	?destbyte
	maclib	z80
;
true	equ	0ffffh
false	equ	not true
;
xon	equ	false			; if true then handshaking is done
;
; DESTBYTE is used to send characters to output devices. The current
; assignments are
; 00	Standard console output
; 01    Standard printer output
; 02	Printer and console (echolst) output.
; 03    User output via custom driver
; At present the output devices are not table driven since there are
; not enough of them. In the future then maybe.
;
dispatch:
	push	psw			; Save the character
	lda	?destbyte		; Get the destination device
	ora	a
	jrz	docoe
	cpi	1
	jrz	doloe
	cpi	3
	jrz	usr$conout		; Send to users output routine
; Echo list output driver
	pop	psw			; Restore character
	call	coe			; Send to screen
	jmp	loe			; Send to printer
;
docoe:	; Do console output.
	pop	psw			; Restore
;
; If handshaking is required then we do X-on / X-off 'ing
	if	xon
	call	coe			; Send the character
	push	psw			; Preserve the character
	call	cst			; X-off ??
	jrz	docoe1
	call	cie
	cpi	19			; control S ??
	jrnz	docoe1
docoe$wait:
	call	cie
	cpi	17			; control Q ??
	jrnz	docoe$wait
;
docoe1:
	pop	psw
	ret				; return to the user
; If no handshaking then just send the character and return
	else
	jmp	coe
	endif
;
doloe:
	pop	psw
	jmp	loe			; Same as above.
;
;----------------------------------------------------------------
; This routine allows the user to patch a set of custom I/O driver
; routines for all console I/O. This allows the user to programatically
; alter program I/O.
; This is done by setting the DESTBYTE to 3 which indicates USERIO
; and by saving the addresses of the rouines in dseg memory.
;----------------------------------------------------------------
;
userio:
	push	psw
	push	h
	push	b			; Save a byte count
	mvi	a,3			; Indicate user i/o
	sta	?destbyte
	xchg				; HL -> address table
	lxi	d,usrcie		; Point to first byte of dest'n
	lxi	b,6			; Shift only 6 bytes
	ldir				; Move the table
	pop	b
	pop	h
	pop	psw			; Restore all registers.
	ret
;
;----------------------------------------------------------------
; Goto the users console input routine. This only has to 
; read a console character into the accumulator and return 
; with it.
;----------------------------------------------------------------
;
usr$conin:
	pop	psw			; Restore the users character
	push	h			; Save register
	lhld	usrcie			; get the address
	xthl
	ret
;
;----------------------------------------------------------------
; User the USRCOE routine to send a character to the output device.
;----------------------------------------------------------------
;
usr$conout:
	pop	psw			; Restore ascii character
	push	h			; Save from predators
	lhld	usrcoe			; Load address of the routine
; The next two instructions put the address of the users I/O output
; routine onto the stack, restore the HL register then goto the routine.
;
	xthl				; Restore HL. Load address
	ret				; All done.
;
;----------------------------------------------------------------
; 	Goto the users Console status routine.
;----------------------------------------------------------------
;
usr$constat:
	push	h
	lhld	usrcst			; Get the address
	xthl
	ret				; Goto it without waiting.
;
;----------------------------------------------------------------
; This routine flushes the printer buffer (if it has one) by sending a 
; backspace then a space so the the printer sends all its contents
; to paper before printing the backspace/space.
;----------------------------------------------------------------
;
flushloe:
	push	psw			; save this only all else auto
	mvi	a,08			; do a backspace
	call	loe
	mvi	a,' '			; space
	call	loe
	pop	psw
	ret
;
	dseg
usrcie	db	00,00			; Filled in by userio
usrcoe	db	00,00
usrcst	db	00,00
;
	end

