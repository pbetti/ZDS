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

;.....
; Set up DS-1302 interface
; Entry: None
; Uses : AF

copen:	call	rtcrmod		; Data Line to Input
	call	cllosclk	; Clk LO to Start
	call	cluprst		; Clear Reset to HI
	ret

;.....
; Write the Byte in A to the chip (used for Command)
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

rdtime:
	call	copen			; Set Clock to Read, returning BC->DRA Port
	ld	d,7			; 7 Bytes to Read

; Command the DS-1302 for Burst Read of Clock

	ld	a,10111111b		; Load the Burst Clock Read Command
	call	wr1302			; and Send it

; Read the Clock Data.

rddsre:
	push	hl			; Save Ptr
	ld	e,8			; Gather 8 bit for a byte
rdtim1:
	call	cllosclk		; Clock LO
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

wrtime:
	call	copen			; Open the Clock
	ld	a,10001110b		; select write to control register (8E)
	call	wr1302
	ld	a,0			; Write-Protect Off
	call	wr1302
	call	cclosw
	call	copen
	ld	a,10111110b		; Burst Write (BE)
	ld	b,8			; 8 bytes
	call	wr1302
stti0:
	ld	a,(hl)
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

;-------------------------------------------------------------------------
; Dallas DS-1302 RAM Interface
;
;  Read the RAM to a buffer area in local memory.  31 bytes are read or
;  written

;;
;; read from DS1302 to buffer
;;

rdram:	call	copen			; Set Clock to Read, returning BC->DRA Port
	ld	d,31			; 31 Bytes to Read

; Command the DS-1302 for RAM Burst Read

	ld	a,11111111b		; Load the Burst Read Command
	call	wr1302			; and Send it
	ld	hl,dsramb		; init ptr

; Read the RAM.

rdram0:
	push	hl			; Save Ptr
	ld	e,8			; Gather 8 bit for a byte
rdram1:
	call	cllosclk		; Clock LO
	nop				; (settle)
	in	a,(crtservdat)		; Read Bit to LSB
	rlca				; shift left to
	rlca				; move bit 6 to carry
	rr	l			; to MSB of L
	call	clupsclk		; Clock HI
	dec	e			; Byte Done?
	jr	nz,rdram1		; ..jump if Not
	ld	e,l			; Else Get Byte
	pop	hl			; Restore Ptr to Dest
	ld	(hl),e			; Save value in output string
	inc	hl			; back down to previous byte in output
	dec	d			; decrement counter
	jr	nz,rdram0		; ..get another byte if not done
	call	cclose			; Else Deselect Clock
	ld	a,$01			; Set Good Exit
	ret

;;
;; write from buffer to DS1302
;;

wrram:
	ld	hl,dsramb
	call	copen			; Open the chip
	ld	a,10001110b		; select write to control register (8E)
	call	wr1302
	ld	a,0			; Write-Protect Off
	call	wr1302
	call	cclosw
	call	copen
	ld	a,11111110b		; Burst Write (FE)
	ld	b,31			; 31 bytes
	call	wr1302
wrram0:	ld	a,(hl)
	call	wr1302
	inc	hl
	djnz	wrram0
	call	cclosw
	ret

;;
;; bios write interface
;;
;; D = data, E = index (0-31)
;;
setdsr:
	push	hl
	push	af
	push	bc
	ld	a,e			; check range
	cp	31
	ret	nc			; over
	ld	a,d
	ld	hl,dsramb		; point to ram
	ld	d,0
	add	hl,de
	ld	(hl),a			; write
	call	wrram			; on chip
	pop	bc
	pop	af
	pop	hl
	ret

;;
;; bios read interface
;;
;; D = data (output), E = index (0-31)
;;
getdsr:
	push	hl
	push	af
	push	bc
	push	de
	call	rdram			; from chip
	pop	de
	ld	a,e			; check range
	cp	31
	ret	nc			; over
	ld	hl,dsramb		; point to ram
	ld	d,0
	add	hl,de
	ld	d,(hl)			; read
	pop	bc
	pop	af
	pop	hl
	ret

;----------------------------
dsramb:	ds	31

; --- EOF ---
