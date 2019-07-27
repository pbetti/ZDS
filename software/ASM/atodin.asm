;----------------------------------------------------------------
;          This is a module in the ASMLIB library
;
; This module uses registart DE as the channel on an analogue to
; digital converter to be read. The value is loaded onto HL and an FF
; is returned if an error / timeout has occurred.
;
; NOTE that this module suits an ADC-32 by SME Systems located at
; port 040h. Channels greater than 32 return FF in register HL.
; A successful channel read returns the zero flag true so that a
; jump non-zero should go to an error handler.
;
;			Written		R.C.H.		25/8/83
;			Last update	R.C.H.		22/10/83
;----------------------------------------------------------------
;
	name	'atodin'
	public	atodin
;
	maclib	z80
;
atod0	equ	040h
atod1	equ	041h
;
atodin:
	; Check if an illegal channel number
	push	psw
	mov	a,d
	ora	a
	jrz	not$d			; error if d > 0 since only 32 channels
ana$err:	; return an error to the user
	lxi	h,0ffffh
	pop	psw
	ret				; return the error
;
not$d:	; Check if E <= 31
	mov	a,e
	cpi	32
	jrnc	ana$err			; error if >= 32
;
; Get the analogue channel into the accumulator
;
	mov	a,e			; Get the channel number
	out	atod0
	call	delay			; A little delay for safety sake
; Now  pulse the start of conversion pin
	ori	80h
	out	atod0
	call	delay
	ani	07fh			; Mask off top bit
	out	atod0
;
	lxi	h,8000h
getac1:
	in	atod1
	ani	080h
	jrnz	get$data		; if 1 then get the data
; If here then we must decrement the HL register to trap a dead board
	dcx	h
	mov	a,l
	ora	h			; is h = l = 0 ??
	jrnz	getac1			; if not then try again
	jr	ana$err			; else we return a converter error
;
get$data:
	in	atod0
	mov	l,a			; Save value into c
	xra	a
	mov	h,a			; clear top byte
	pop	psw
	ret
;
; Do a little delay to as to wait for the cmos a to d chip.
delay:
	push	psw
	mvi	a,020h			; Delay countdown value
delay1:
	dcr	a
	jnz	delay1
	pop	psw			; Restore the accumulator
	ret
;
	end


