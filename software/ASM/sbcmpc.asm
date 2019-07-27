;****************************************************************
;*		This is a module in ASMLIB			*
;*								*
;* This is the MPC-6  and SBC-800 console I/O super      	*
;* re-directable I/O driver module for ASMLIB and the MPC-6.	*
;* This module is linked into  ASMLIB  in-place of the  	*
;* original COE, CIE, CST drivers.				*         
;*								*
;* This module supports the following devices and is selected   *
;* by sending the following codes to the console driver COE     *
;* which intercepts the code and directs the output to the 	*
;* following devices.						*
;*								*
;*   Code		--- Device ---				*
;*    F8	SBC-800 standard I/O drivers. Standard default. *
;*    								*
;*    F9	MPC-6 Channel 0					*
;*    FA		      1					*
;*    FB		      2					*
;*    FC		      3					*
;*    FD		      4					*
;*    FE		      5					*
;*								*
;* When the above codes are sent to the COE routine, they are   *
;* intercepted and used to SWITCH all further I/O to the 	*
;* selected device from this point on.				*
;* This is extremely handy for having multiple I/O devices in a *
;* program selected chain.					*
;*								*
;*			Written        R.C.H.      14/11/83	*
;*			Last Update    R.C.H.	   14/12/83	*
;****************************************************************
;
	name	'SBCMPC'
	public	coe,cie,cst,loe,lst,ionum
;
	maclib	z80
;
;
; Equates for SBC-800 I/O addresses and device masks
;
rxmsk	equ	1		; For DART chips this applies
txmsk	equ	4
codat	equ	88h		; Console ports on sbc800
costat	equ	89h
sestat	equ	8bh		; Serial status port on SBC800
serdat	equ	8ah		; Serial data port on SBC800
; 
; Equates for MPC-6 Card.
;
mpcdat	equ	00		; MPC-6 data port
txstat	equ	01		; MPC-6 transmitter status port
rxstat	equ	02		; MPC-6 receiver status port
command	equ	txstat		; MPC-6 command port
reset	equ	03		; MPC-6 reset port
send	equ	010h		; Opcode for sending a byte to MPC
receive	equ	00		; Opcode for receiving a byte from MPC
;
num	equ	04		; 0 = cpmio,2=sbc800io,3=cpmmpc,4=sbcmpc
;
ionum:
	mvi	l,num
	ret
;
;----------------------------------------------------------------
; Get the status of the currently selected I/O device
;
; Channel = 0 then SBC-800
; Channel = 1 to 6 then MPC-6
;----------------------------------------------------------------
;
cst:
	lda	channel
	ora	a			; Channel 00 ?
	jz	const			; Get SBC-800 console status
; Here we get the status of the MPC-6 receiver stored in A.
	dcr	a			; make in the range 0..5
	jr	mpcstat			; Do the job and return to user
;
;----------------------------------------------------------------
;		Read A character
;		----------------
;
; Use the channel number to select either the MPC-6 or the SBC-800 
; Channel allocations as before.
;----------------------------------------------------------------
;
cie:
	lda	channel
	ora	a
	jz	conin
	dcr	a			; make the channel number in range
	jr	mpcread
;
;----------------------------------------------------------------
;		Output a character in A 
;		-----------------------
;
; Test if the character is a channel selector byte 
; Write character in A to MPC-6 or SBC-800, again depending on 
; selected channel number.
; Before writing, we test if it is a channel selector byte as
; defined previously.
;----------------------------------------------------------------
;
coe:
	push	psw			; save the character
	ani	0f8h			;
	cpi	0f8h			; Mask to test top 5 bits
	jrnz	coe2
; Here the byte is a channel selector
	pop	psw			; restore the byte
	ani	07h			; leave only the channel number there
	cpi	07
	rz				; Ignore out of range value
	sta	channel			; Save the number
	ret
;
; Here and it is not a channel selector, but a valid ascii byte < 0f8h
;
coe2:	; Do the channel test and jump
	lda	channel
	ora	a
	jz	conout			; do the job via SBC-800
;
	jr	mpcsend			; send it and return via MPC i/o driver
;
;----------------------------------------------------------------
;                     Get the MPC-6 status
;		      --------------------
;
; Channel number is in the CHANNEL byte
; Return A = 00 = no character there all else = character there
;----------------------------------------------------------------
;
mpcstat:
	push	d
	call	bitset			; Get a channel mask into E
	in	rxstat
rdy:
	ana	e			; the desired channel ??
	pop	d			; restore register
	rz
	mvi	a,0ffh			; load with 0ffh if not
	ret
;
;----------------------------------------------------------------
; 		Read an MPC-6 channel. 
;		----------------------
;
; Channel number is in the CHANNEL byte
;----------------------------------------------------------------
;
mpcread:
	push	d
; Generate a channel mask in E 
	call	bitset
; 
cari0:
	in	txstat
	ani	080h		; we are truly busy, wait, if bit set
	jrnz	cari0
;
; Wait till MPC-6 is ready with data for this channel
	in	rxstat		; channel mask
	ana	e
	jrz	cari0
;
	in	txstat
	ani	080h
	jrnz	cari0
; Mask in the receive byte with the MPC-6 channel number
	lda	channel		; get the channel number
	dcr	a		; make it in range 0..5
	ori	receive		; Mask in the channel selected by the user
	out	command
cari1:
	in	txstat
	ani	080h
	jrz	cari1
	in	MPCDAT
; character is in A and ready for action
	ani	07fh			; mask off parity
;
	pop	d			; restore the register
	ret
;
;----------------------------------------------------------------
; 		Send data to the MPC-6 
;		----------------------
;
; Data at stack TOP
; The channel number is saved in the CHANNEL byte and bitset uses
; this to generate channel mask bytes.
;----------------------------------------------------------------
;
mpcsend:
	pop	psw			; get the character
	push	b			; save all user registers
	push	d
;
	mov	c,a			; save the character for later
	out	mpcdat			; send the character to MPC-6
caro0:
	in	txstat
	ani	080h
	jrnz	caro0
; Get a channel mask into E
;
	call	bitset
; Read status till MPC-6 accepts the character (mask in E)
;
caro1:
	in	txstat
	ana	e
	jrz	caro1
;
; Load the channel number, mask in the send command byte then send to MPC
;
	lda	channel
	dcr	a			; make it in range 0..5
	ori	send			; tell MPC-6 we are sending data to it
	out	command			; send to command port
;
; A little delay for the MPC is done here to make sure it reads the byte
;
delay:
	mvi	a,030h
del1:
	dcr	a
	jrnz	del1
; Restore the users character then his registers.
	mov	a,c			; restore the character
	pop	d
	pop	b
	ret
;
;		----------------
; Set bits to suit a selected MPC-6 channel.
; This is done by reading the channel byte to set a single bit
; in the byte returned in A
;		----------------
;
bitset:
	push	b			; save this
	lda	channel			; get channel number 1..6
	mov	b,a			; load into counter
	xra	a			; clear seed
	stc				; set carry
;
; Rotate the carry up the A register to generate a bit pattern
; for the required channel. Channel 0 -> 01, channel 4 -> 08 etc.
;
bit0:
	ral				; rotate arith left thru carry
	djnz	bit0			; do for all bits
	mov	e,a
	pop	b			; restore register
	ret
;
;****************************************************************
; 	SBC-800 i/o drivers. Used when channel = 00		*
;****************************************************************
;
const:	in	costat			; sbc status port
	ani	rxmsk
	rz
	mvi	a,0ffh
	ret				; exit valid
;
conin:	call	const
	jrz	conin			
	in	codat			; character available
	ani	7fh
	ret
;
conout: in	costat
	ani	txmsk
	jrz	conout
	pop	psw			; restore the character
	out	codat			; data port for SBC400
	ret
;
; The line printer is assumed here to be the SBC-800 second
; serial port.
;
loe:
	push	psw
loe1:
       	in	sestat
	ani	txmsk
	jrz	loe1
	pop	psw
	out	serdat			; data port for SBC400
	ret
;
; Get the serial output status.
;
lst:
      	in	sestat			; sbc status port
	ani	txmsk
	rz
	mvi	a,0ffh
	ret				; exit valid
;
; Data storage is required to save the channel selection byte
; which is selected when the byte is sent to the COE driver
;
	dseg
channel	db	00			; Holds the logged in channel number
	end



