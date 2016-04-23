;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; This is a library of routines for interfacing to PL/I-80
; which supports some added features due to SME Systems hardware 
; and some other nifty things.
;
; This version contains....
;
; INITRND	Initialize a random number seed
; RAND16	Return a random number +-32k in size
; RANDP16	Return a positive random number 0..32k
; RAND8		Return an 8 bit number +-127
; CLKRD		Read the real time clock on SBC-800 into ram
; CONIN		Return a character from the console
; CONST		Return the console status
;
;    Extended and patchable screen functions.
;
; CLEAR		Erase the screen
; CLEOL		Clear to end of line
; CLEOP		Clear to end of page
; SETXY		Position cursor to X, Y co-ords
; SETREV	Initialize reverse video
; SETUND	Initialize underlined characters
; SETHLF	Initialize half intensity characters
; SETBLK	Initialize blinking characters
; CLRATT	Clear the current attribute
; CURON		Enale the cursor
; CUROFF	Disable the cursor
;
;
; For full documentation on this lot, see SMEPLI DOCUMENTATION which
; contains examples etc. (if you are lucky)
;
;			Written		R.C.H.         26/10/83
;              		Last Update	R.C.H.	       28/11/83
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
	name	'SMEPLI'
	maclib	z80
	public	conin,const,initrnd,randp16,rand16
	public	rand8,clkrd
;
;
bdos	equ	5
;
;----------------------------------------------------------------
;           CONIN - Get a character from the console
; 
; This function returns the first character typed on the keyboard.
; The character is returned as char(1) to PL/I.
;
; This function uses the bdos function 10 to return the character 
; which is not echoed as it is received. This is l;eft to the user.
;----------------------------------------------------------------
;
conin:
	call	cst
	jrz	conin			; wait for a character
; Now do a direct bdos call for the character
conin1:
	mvi	e,0ffh			; get character routine
	mvi	c,06			; direct console i/o
	call	bdos			; character is in A now
	ora	a
	jrz	conin1			; if no character, wait for it
; Now load the character onto PL/I's stack
	pop	h			; drop off return address
	push	psw			; put the character onto it
	inx	sp			; bump stack
	mvi	a,1			; characters on stack = 1
	pchl				; trick return
;
;----------------------------------------------------------------
;     	    CONST - Get the console status. 
;
; If a character is ready then the return is a true flag else
; a false flag is returned. This function uses the bdos function 
; 10 to detect if the character is there.
;----------------------------------------------------------------
;
const:
	call	cst			; get the status 
	ora	a			; zero ?
	rz				; return if so
	mvi	a,0ffh			; clean true value
	ret				; if not then make it positively so
;
; The following code merely uses bdos function 11 to return the console
; status.
;
cst:	
	push	h
	push	b
	push	d
	mvi	c,11			; get console status fumction
	call	bdos
	pop	d
	pop	b
	pop	h
	ora	a			; Set the flag 00 = not ready
	ret
;
;----------------------------------------------------------------
; 		CLKRD - Read the real time clock
;
; This function uses the SBC-800 real time clock to return the 
; time into a piece of memory that may be either bit(8) or bin(7)
; or whatever. I like using a structure laid out with
; fileds called year,month,day,dow,hour,minute,second declared as
; bit(8) or bin(7) where appropriate.
;
; The following equates specify the port addresses of the real time clock
; chip and interface. The clock chip is an OKI 5832 and the interface 
; is an intel 8255.
;
; HACKERS - The following is a particularly nasty piece of code
;            which holds the OKI 5832 clock chip and reads all the 
;            internal registers. If running at 6Mhz then the timing loops
;            for the hold times may need expanding out to suit.
;
;----------------------------------------------------------------
;
;Clock and centronics ports on the sbc-800
;
pp0a	equ	84h			; Port a 0
pp0b	equ	pp0a+1			; Port b 0
pp0c	equ	pp0a+2			; Port c 0
pp0d	equ	pp0a+3			; Control port 0
;
;	I/O lines and part of clock strobe
;
pp1a	equ	80h			; Port a 1
pp1b	equ	pp1a+1			; Port b 1
pp1c	equ	pp1a+2			; Port c 1
pp1d	equ	pp1a+3			; Control port 1
;
;****************************************************************
;*		Read Real Time Clock to memory			*
;*		pointed by DE, and stored as follows		*
;*								*
;*	hl+0 =>	years	1 byte 2 digit bcd			*
;*	  +1 => months  1 byte 2 digit bcd			*
;*	  +2 => days    1 byte 2 digit bcd			*
;*	  +3 => dweek	1 byte 1 digit bcd ** low nibble only ***
;*	  +4 => hours   1 byte 2 digit bcd			*
;*	  +5 => minutes 1 byte 2 digit bcd			*
;*	  +6 => seconds 1 byte 2 digit bcd			*
;*								*
;****************************************************************
;
; Note that the user passes a POINTER to this function which then
; writes the bytes to the address for 7 bytes. Use carefully, it is
; a good routine to corrupt memory if poorly used.
;
clkrd:	; Read clock into memory at DE 
	call	getp2 			; return the address in de
	xchg				; put into hl
;
; Here try to hold the clock chip for 150 us. 
	mvi	a,00001101b		; Hld bit
	out	pp0d			; Set bit
; Now load a counter for a 150 us delay.
	mvi	b,120			; 7 T
;
hld$wait:
	djnz	hld$wait		; 8/10 T
;
	out	pp1d			; this is the read bit load
; Loop to read all registers in one go
	mvi	b,12			; register count
rclk1:
	call	get$reg
	mov	a,b
	cpi	6			; Was it day of week
	jrz	rclk2			; Skip second register if so
	dcr	b			; Next register
	call	get$reg			; read the register
rclk2:	; Jump here after reading day of week
	inx	h			; next byte in ram to rotate into
	dcr	b			; register number
	xra	a
	ora	b			; set the minus flag
	jp	rclk1
; restore the port bits
       	mvi	a,00001100b		; Reset bit 6
	out	pp0d
	out	pp1d   			; Clear hold+read
	ret
;
get$reg:	; Read register in B into memory with an RLD
	mov	a,b
	out	pp0b
	mvi	a,8
rdreg1:	; This loop is needed for a 6 us delay for reading the register
	dcr	a
	jrnz	rdreg1			; another wait of 15 us or better
	in	pp0a
	ani	15			; Get data
	rld				; Saved in memory
	ret
;
;----------------------------------------------------------------
; 		RANDOM NUMBER ROUTINES
;
; These routines intialize/return random numbers. The user must
; feed these routines a string of bytes (5 minimum) which are used as
; a seed. The initialization uses the Z-80 refresh register as a
; jumble function of these bytes.
;
;         This is a module in the ASMLIB Library.
;
; This module generates PSEUDO RANDOM NUMBERS by using a seed array
; and doing adds and shifts on the bytes in the array. 
;
;----------------------------------------------------------------
;
initrnd:	; initialize the random number seed string pointed to
	call	getp2		; get the pointer to the string
	ldax	d		; get the string size
	cpi	5
	rc			; Error if less than 5 elements in the array
	push	d
	push	b
	mov	b,a		; Load counter
	xchg
	inx	h		; Now HL -> first seed byte
	ldar			; Get refresh register value
	dcr	b		; Do one less than the required
initloop:
	add	m
	rrc
	mov	m,a
	inr	m
	mov	a,m
	inx	h
	djnz	initloop
; Restore and exit gracefully
	xchg			; Restore HL
	pop	b
	pop	d		; Restore other registers
	ret
;
; Return an 8 bit random number in A
;
rand8:	
	call	getp2		; get the strings address
rand81:
	ldax	d		; A = number of seeds
	cpi	5		; Check if less than 5 seed values
	rc			; Return with a carry to indicate an error
; Here we load the number of cells into B then decrtement so as to skip
; these which are operated on later.
	push	b
	push	d		; Saver address of seed array
	mov	b,a
	dcr	b
	dcr	b
	inx	d		; DE -> first seed in the array
	xchg			; Put memory pointer into HL
;
;Loop for N-2 times.
loop:	inr	m		;INCREMENT SEED VALUE.
	mov	a,m
	inx	h		;HL POINTS TO NEXT SEED VALUE IN ARRAY.
	add	m
	rrc			;ROTATE RIGHT CIRCULAR ACCUMULATOR.
	mov	m,a
	djnz	loop
;
; Last iteration to compute random byte in register a.
	inx	h 		; HL -> last byte in the array
	add	m
	cma			; complement the accumulator
	rrc			; rotate it right
	mov	m,a
	xra	a		; Clear carry
	mov	a,m		; Re-load value, carry not set.
;
; Restore the registers and return with the value in A
error:	
	xchg			; Restore HL
	pop	d
	pop	b
	ret
;
; Return a 16 bit random number in HL.
;
rand16:
	call	getp2		; get string address
	push	d
	call	rand81
	mov	h,a		; msb byte
	pop	d		; restore string address
	call	rand81
	mov	l,a		; lsb byte
	ret
;
; Return a positive 16 bit random number
;
randp16:
	call	rand16		; get the number
	mov	a,h
	ani	07fh		; Mask off top bit
	mov	h,a		; restore
	mov	a,l		; echo lsb in a
	ret
;
getp1:
	mov	e,m
	inx	h
	mov	d,m
	xchg
	mov	e,m
	ret
;
;
getp2:
	call	getp1
	inx	h
	mov	d,m
	ret
;
;----------------------------------------------------------------
; 		Screen Based Functions.....
;
; These are taken from the ASMLIB source code modules and as such are
; patchable to suit a termial in use by using the SETUP.COM program
; to write the correct terminal driver into the code patch area.
;----------------------------------------------------------------



	end



