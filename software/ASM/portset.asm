;----------------------------------------------------------------
;        This is a module in the ASMLIB library.
;
; This module simply takes the pointer in DE as the start of a data
; table of bytes to be sent to a peripheral I/O device (chip). This
; code was taken from the CP/M manual for initializing a SIO chip.
; The table is expected to be in the following format...
;
; TABLE:
;	db	n			; number of elements / lines /ports
;	db	num$bytes,port$number,b1,b2,....,bx
;       "	"	"	"	"	"
;       db	num$bytesn,port$numbern,b1,b2,....,bx
;	db	00			; no bytes = end.
;
;		Written		R.C.H.		25/8/83
;		Last Update	R.C.H.		22/10/83
;----------------------------------------------------------------
;
	name  	'portset'
	public	portset
	maclib	z80
;
portset:
	push	psw
	push	b
	push	d		; Save DE
	xchg
stream$out:
	mov	a,m
	ora	a
	jrz	portend		; return if no table
	mov	b,a		; load the number of bytes to send.
	inx	h
	mov	c,m		; load the port number into C
	inx	h		; point to data for this port now
	outir
	jr	stream$out
;
portend:
	xchg			; Restore HL
	pop	d
	pop	b
	pop	psw
	ret
;
	end



