;----------------------------------------------------------------
;	     This is a module in the ASMLIB library.
;
; 		        SBC-800 I/O Drivers
;
; This is the I/O driver module of ASMLIB and has ALL the I/O routines
; for the system (EXCEPT from line input). Note that the routines do no 
; initialization which is assumed to have been done already.
;
; COE	Send accumulator to console.
; CIE   Get console into accumulator. No echo.
; CST   Get console status, 00 = no character there.
; LOE   Send accumulator to list device.
; LST   Get list device output status.
; IONUM	Get the identification number of this i/o driver
;
;			Written     	R.C.H.     22/10/83
;			Last Update	R.C.H.	   14/12/83
;
;----------------------------------------------------------------
	name	'SBC800IO'
;
	public	coe,cie,cst,loe,lst,ionum
;
	maclib	z80
;
num	equ	02			; 01 = cpmio, 02 = sbc800io
;
; In an SBC-800 the Serial I/O is done via a Dart. This module does
; all the I/O through this of course. This driver also has X-on / Xoff
; handshaking if equate is set. If serial = true then the LOE type
; of ASMLIB functions go through the second serial port and if false
; then they go via the parallel port (8255) of SBC-800.
;
true	equ	0ffffh
false	equ	not true
xon	equ	true		; enables X-on Xoff on console
serial	equ	true		; enables serial printer driver
data0	equ	088h
stat0	equ	data0 + 1
data1	equ	data0 + 2
stat1	equ	data0 + 3
;
rxrdy	equ	01		; receiver got a character bit
txrdy	equ	04		; transmitter empty bit
;
; The following are the parallel printer port equates.
;
pp0a	equ	084h		; Busy / status port
pp0b	equ	pp0a + 1	; data port
pp0c	equ	pp0a + 2	; Ack line on this port
pp0d	equ	pp0a + 3	; strobe line here
;
;
ionum:
	mvi	l,num
	ret
;
;----------------------------------------------------------------
;     Print the character in the accumulator to the screen       *
;----------------------------------------------------------------
;
coe:
	push	psw
	push	psw			; Preserve the character
coe1:
	in	stat0			; is there transmitter empty
	ani	txrdy
	jrz	coe1			; wait for it
	pop	psw			; get the byte
	out	data0			; send it
;
; Here we may need X-on / X-off if the equate is set.
;
	if	xon
	call	cst			; character come back ??
	jrz	coefin			; exit if not then
; Else get the character
	call	cie			; get it
	cpi	019			; is it X-off ?
	jrnz	coefin
coe2:	; Wait for an X-on
	call	cie
	cpi	017			; X-on ?
	jrnz	coe2
	endif
coefin:
	pop	psw			; Restore the character
	ret
;
;----------------------------------------------------------------
;     Send the accumulator character to the list device
;----------------------------------------------------------------
;
loe:
	push	psw
loe1:				; loop point till Xmitter empty
	call	lst
	jrz	loe1			; Wait till transmitter empty
	pop	psw			; restore data
;
	if	serial			; It is a serial output device
	out	data1			; send to dart now
;
	else				; It is a parallel printer
	out	pp0b			; send to data port
	push	psw
ppout1:
	mvi	a,0fh
	out	pp0d			; Set strobe low
	dcr	a			; Turn lsb off
	out	pp0d			; Send strobe low
ppout2:
	in	pp0c			; Test Ack Line
	ani	1
	jrz	ppout2			; Wait till asserted
	pop	psw			; Restore character through all
	endif
;
	ret
;
;----------------------------------------------------------------
;           Get a character from the console
;----------------------------------------------------------------
;
cie:
	call	cst			; get status till <> 0
	jrz	cie			; the character is in A
	in 	data0			; send to serial channel 0
	ani	07fh			; mask off parity
	ret
;
;----------------------------------------------------------------
; Get the console status. 00 = no character all else = read.
;----------------------------------------------------------------
;
cst:	; Use dos function 11
	in	stat0
	ani	rxrdy			; is there a character there
	rz				; retunr if no character
	mvi	a,0ffh
	ret
;
;----------------------------------------------------------------
; Get the list output status. If = 00 then no character may be
; sent to the device.
;----------------------------------------------------------------
;
lst:
	if	serial			; Read the darts status
	in	stat1
	ani	txrdy			; transmitter ready mask
	rz
	mvi	a,0ffh			; character is there if here
	ret				; return the device as ready
;
	else				; Else it is the centronic printer
	in	pp0a			; Test Busy bit
	ani	080h
	cma				; Complement
	ora	a
	rz
	mvi	a,0ffh			; Return with a not busy byte
	ret
	endif
;
	end




