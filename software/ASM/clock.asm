;----------------------------------------------------------------
;        This is a module in the ASMLIB library			*
;								*
; This module is used to read and write to the sbc-800  clock.  *
;								*
; The two entry points of this module are called indetically    *
; by passing a pointer to the required data areas to be read    *
; into or written to the clock from. 				*
;								*
; The read function reads the time into m-->DE while the write  *
; function wrtites m-->DE into the clock chip.			*
;								*
;		Written		R.C.H.	14/8/82			*
;		Last Update	R.C.H.	19/9/83			*
;
; Added new clock read software for holding for 150us.	R.C.H.  21/9/83
;****************************************************************
;
	name	'clock'
;
	public	clkrd,clkwr
	maclib	z80
;
; The following equates specify the port addresses of the real time clock
; chip and interface. The clock chip is an OKI 5832 and the interface 
; is an intel 8255.
;
;	Clock and centronics ports on the sbc-800
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
clkrd:	; Read clock into memory at DE or to screen
	push	psw
	push	h			; Save users register
	push	b
	xchg				; Load address into HL
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
	pop	b
      	pop	h			; Restore last location
	pop	psw
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
;****************************************************************
;*		Write to Clock, takes a bcd string		*
;*	pointed to by the DE registers, and updates the clock	*
;*								*
;*	Format of string is :=					*
;*								*
;*	hl+0	=>	1 byte 2 bcd digits year		*
;*	  +1	=>	1 byte 2 bcd digits month		*
;*	  +2    => *	1 byte 2 bcd digits date		*
;*	  +3	=>	1 byte 1 bcd digit weekday (low nibble) *
;*	  +4	=> **   1 byte 2 bcd digits hours		*
;*	  +5	=>	1 byte 2 bcd digits minutes		*
;*	  +6	=>	1 byte 2 bcd digits seconds		*
;*								*
;*	* note1 = bit 6 = 1 for 29 days in month 2		*
;*			  0 for 28 days in month 2		*
;*								*
;*     ** note2 = bit 7 = 1 for 24 hour format			*
;*			  0 for 12 hour format			*
;*								*
;*		  bit 6 = 1 for pm				*
;*			  0 for am				*
;*								*
;****************************************************************
;
clkwr:
	push	psw
	push	h
	push	b
;
	xchg				; DE --> time string
;
	mvi	b,12			; Register count
	mvi	a,80h			; Set port 0 for write
	out	pp0d
wrclk0:
	rld				; Get upper bcd digit by rotation
	ani	15			; Mask off upper
	out	pp0a  			; Send data
	mov	a,b
	out	pp0b  			; Send address
	mvi	a,00001101b		; Hold bit
	out	pp0d
	mvi	a,15
wrclk1:
	dcr	a
	jrnz	wrclk1			; Hold setup time
	call	wrstrb			; Strobe write line
	mov	a,b
	cpi	6
	jrz	wrclk2
	dcr	b
	rld				; Lower digit
	out	pp0a  			; Send data
	mov	a,b
	out	pp0b  			; Send reg address
	call	wrstrb			; Strobe write pulse
wrclk2:
	inx	h
	mov	a,b
	ora	a			; Test for zero already
	jrnz	wrclk3			; Skip if not endstrobes
; Re-initialize the clock ports then.
	push	psw
	mvi	a,10110100b		; Centronics port init
	out	pp0d			; Set up command
	mvi	a,5
	out	pp0d			; Set pc2 for strobe acknowledge
	pop	psw
;
wrclk3:
	dcr	b
	jr	wrclk0			; B=count-1, loop till zero
;
wrstrb:
	mvi	a,00001111b		; Send write pulse now
	out	pp1d  			; Send write
	dcr	a
	out	pp1d  			; Clear write strobe
	pop	b
	pop	h
	pop	psw
	ret
;
	end


