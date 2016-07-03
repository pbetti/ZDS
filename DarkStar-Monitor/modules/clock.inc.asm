;
;=======================================================================
;
; Modular Z80 DarkStar (NE Z80) Monitor
;
;=======================================================================
;
; RT Clock DS1302
; ---------------------------------------------------------------------

;;
;; RTCWMOD
;; - set DS1302 I/O line as output

rtcwmod:
	ld	a,$cf			; 11-00-1111 mode ctrl word
					; Mode 3 (bit mode port B)
	out	(crtservcnt),a		; load mode 3 ctrl word
	ld	a,00011101b		; bit mask 00011101
					;           |------- b6 out  (ds1320 i/o line)
	out	(crtservcnt),a		; send to PIO2
	ret

;;
;; RTCWMOD
;; - set DS1302 I/O line as output

rtcrmod:
	ld	a,$cf			; 11-00-1111 mode ctrl word
					; Mode 3 (bit mode port B)
	out	(crtservcnt),a		; load mode 3 ctrl word
	ld	a,01011101b		; bit mask 01011101
					;           |------- b6 in  (ds1320 i/o line)
	out	(crtservcnt),a		; send to PIO2
	ret

clupsclk:
	in	a,(crtservdat)		; read data port PIO2
	set	clksclk,a
	out	(crtservdat),a		; send to PIO2
	ret

cllosclk:
	in	a,(crtservdat)		; read data port PIO2
	res	clksclk,a
	out	(crtservdat),a		; send to PIO2
	ret

cluprst:
	in	a,(crtservdat)		; read data port PIO2
	set	clkrst,a
	out	(crtservdat),a		; send to PIO2
	ret

cllorst:
	in	a,(crtservdat)		; read data port PIO2
	res	clkrst,a
	out	(crtservdat),a		; send to PIO2
	ret

;-------------------------------------------------------------------------
; Dallas DS-1302 Clock Interface
;
;  Read the Clock to a buffer area in Memory.  Seven bytes are read
; in burst mode from the clock chip, one bit at a time. The Clock is accessed
; serially (LSB first) one byte at a time with a command byte being written to
; begin the Read/Write.  Burst Mode is used with a 0BFH byte for Reading,
; 0BEH for Writing as the Command.  Clock Setting clears the Write Protect
; bit before setting, and resets the chip to Read-Only when finished.
;  The Entire Date/Time String is eight bytes read as:
;
;	Sec   Min   Hour   Day   Mon   DOW   Year   WProt
;                  (12/24)                          (MSB)
;
; In this implementation, the 12/24 hour bit is always set to 24-hour
; mode by clearing the MSB.

rdtime:	call	copen			; Set Clock to Read, returning BC->DRA Port
	ld	d,7			; 7 Bytes to Read

; Command the DS-1302 for Burst Read of Clock

	ld	a,$bf			; Load the Burst Clock Read Command
	call	wr1302			; and Send it

; Read the Clock Data.

rddsre:	push	hl			; Save Ptr
	ld	e,8			; Gather 8 bit for a byte
rdtim1:	call	cllosclk		; Clock LO
	nop				; (settle)
	in	a,(crtservdat)		; Read Bit to LSB
	rlca				; shift left to
	rlca				; move bit 6 to carry
	rr	l			; to MSB of L
	call	clupsclk		; Clock HI
	dec	e			; Byte Done?
	jr	nz,rdtim1		; ..jump if Not
	ld	e,l			; Else Get Byte
	pop	hl			; Restore Ptr to Dest
	ld	(hl),e			; Save value in output string
	inc	hl			; back down to previous byte in output
	dec	d			; decrement counter
	jr	nz,rddsre		; ..get another byte if not done
	call	cclose			; Else Deselect Clock
	ld	a,$01			; Set Good Exit
	ret

;.....
; Activate the Clock chip and set Date/Time from the parsed string

sttim:	call	copen			; Open the Clock
	ld	a,10001110b		; select write to control register (8E)
	call	wr1302
	ld	a,0			; Write-Protect Off
	call	wr1302
	call	cclosw
	call	copen
	ld	a,10111110b		; Burst Write (BE)
	ld	b,8			; 8 bytes
	call	wr1302
stti0:	ld	a,(hl)
	call	wr1302
	inc	hl
	djnz	stti0
	call	cclosw
	ret

;;
;; Activate trickle charger
;;
; STTCK:	CALL	COPEN			; Open the Clock
; 	LD	A,10010000B		; select write to trickle charger reg.
; 	CALL	WR1302
; 	LD	A,10100101B		; prog as 1 diode + 2kohm res. (2.2mA)
; 	CALL	WR1302
; 	CALL	CCLOSW
; 	RET

;.....
; Set up DS-1302 interface
; Entry: None
; Uses : AF

copen:	call	rtcrmod		; Data Line to Input
	call	cllosclk	; Clk LO to Start
	call	cluprst		; Clear Reset to HI
	ret

;.....
; Write the Byte in A to the clock (used for Command)
; Exit : None
; Uses : AF,E

wr1302:	push	hl			; Save Regs
	ld	l,a			; Store byte
	ld	e,8			; set bit count
	call	rtcwmod			; data line to output
wr130l:	call	cllosclk
	rrc	l			; Data Byte LSB to Carry
	jr	nc,wr13b0		; is zero ?
	in	a,(crtservdat)		; no set to 1
	set	clkio,a
	out	(crtservdat),a
	jr	wr13nx			; next
wr13b0:	in	a,(crtservdat)		; yes set to 0
	res	clkio,a
	out	(crtservdat),a
wr13nx:	call	clupsclk
	dec	e			; Eight Bits Sent?
	jr	nz,wr130l		; ..loop if Not
	;
	call	rtcrmod			; Set Port to Data IN
	pop	hl			;  Restore Regs
	ret

;.....
; Deselect the Clock for Exit
; Uses : AF

cclosw:	call	rtcrmod
cclose:	call	clupsclk		; HI CLK
	call	cllorst			; LOW RST
	ret

