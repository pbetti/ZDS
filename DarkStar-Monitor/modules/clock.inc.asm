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

RTCWMOD:
	LD	A,$CF			; 11-00-1111 mode ctrl word
					; Mode 3 (bit mode port B)
	OUT	(CRTSERVCNT),A		; load mode 3 ctrl word
	LD	A,00011101B		; bit mask 00011101
					;           |------- b6 out  (ds1320 i/o line)
	OUT	(CRTSERVCNT),A		; send to PIO2
	RET

;;
;; RTCWMOD
;; - set DS1302 I/O line as output

RTCRMOD:
	LD	A,$CF			; 11-00-1111 mode ctrl word
					; Mode 3 (bit mode port B)
	OUT	(CRTSERVCNT),A		; load mode 3 ctrl word
	LD	A,01011101B		; bit mask 01011101
					;           |------- b6 in  (ds1320 i/o line)
	OUT	(CRTSERVCNT),A		; send to PIO2
	RET

CLUPSCLK:
	IN	A,(CRTSERVDAT)		; read data port PIO2
	SET	CLKSCLK,A
	OUT	(CRTSERVDAT),A		; send to PIO2
	RET

CLLOSCLK:
	IN	A,(CRTSERVDAT)		; read data port PIO2
	RES	CLKSCLK,A
	OUT	(CRTSERVDAT),A		; send to PIO2
	RET

CLUPRST:
	IN	A,(CRTSERVDAT)		; read data port PIO2
	SET	CLKRST,A
	OUT	(CRTSERVDAT),A		; send to PIO2
	RET

CLLORST:
	IN	A,(CRTSERVDAT)		; read data port PIO2
	RES	CLKRST,A
	OUT	(CRTSERVDAT),A		; send to PIO2
	RET

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

RDTIME:	CALL	COPEN			; Set Clock to Read, returning BC->DRA Port
	LD	D,7			; 7 Bytes to Read

; Command the DS-1302 for Burst Read of Clock

	LD	A,$BF			; Load the Burst Clock Read Command
	CALL	WR1302			; and Send it

; Read the Clock Data.

RDDSRE:	PUSH	HL			; Save Ptr
	LD	E,8			; Gather 8 bit for a byte
RDTIM1:	CALL	CLLOSCLK		; Clock LO
	NOP				; (settle)
	IN	A,(CRTSERVDAT)		; Read Bit to LSB
	RLCA				; shift left to
	RLCA				; move bit 6 to carry
	RR	L			; to MSB of L
	CALL	CLUPSCLK		; Clock HI
	DEC	E			; Byte Done?
	JR	NZ,RDTIM1		; ..jump if Not
	LD	E,L			; Else Get Byte
	POP	HL			; Restore Ptr to Dest
	LD	(HL),E			; Save value in output string
	INC	HL			; back down to previous byte in output
	DEC	D			; decrement counter
	JR	NZ,RDDSRE		; ..get another byte if not done
	CALL	CCLOSE			; Else Deselect Clock
	LD	A,$01			; Set Good Exit
	RET

;.....
; Activate the Clock chip and set Date/Time from the parsed string

STTIM:	CALL	COPEN			; Open the Clock
	LD	A,10001110B		; select write to control register (8E)
	CALL	WR1302
	LD	A,0			; Write-Protect Off
	CALL	WR1302
	CALL	CCLOSW
	CALL	COPEN
	LD	A,10111110B		; Burst Write (BE)
	LD	B,8			; 8 bytes
	CALL	WR1302
STTI0:	LD	A,(HL)
	CALL	WR1302
	INC	HL
	DJNZ	STTI0
	CALL	CCLOSW
	RET

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

COPEN:	CALL	RTCRMOD		; Data Line to Input
	CALL	CLLOSCLK	; Clk LO to Start
	CALL	CLUPRST		; Clear Reset to HI
	RET

;.....
; Write the Byte in A to the clock (used for Command)
; Exit : None
; Uses : AF,E

WR1302:	PUSH	HL			; Save Regs
	LD	L,A			; Store byte
	LD	E,8			; set bit count
	CALL	RTCWMOD			; data line to output
WR130L:	CALL	CLLOSCLK
	RRC	L			; Data Byte LSB to Carry
	JR	NC,WR13B0		; is zero ?
	IN	A,(CRTSERVDAT)		; no set to 1
	SET	CLKIO,A
	OUT	(CRTSERVDAT),A
	JR	WR13NX			; next
WR13B0:	IN	A,(CRTSERVDAT)		; yes set to 0
	RES	CLKIO,A
	OUT	(CRTSERVDAT),A
WR13NX:	CALL	CLUPSCLK
	DEC	E			; Eight Bits Sent?
	JR	NZ,WR130L		; ..loop if Not
	;
	CALL	RTCRMOD			; Set Port to Data IN
	POP	HL			;  Restore Regs
	RET

;.....
; Deselect the Clock for Exit
; Uses : AF

CCLOSW:	CALL	RTCRMOD
CCLOSE:	CALL	CLUPSCLK		; HI CLK
	CALL	CLLORST			; LOW RST
	RET

