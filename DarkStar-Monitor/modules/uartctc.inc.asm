;
;=======================================================================
;
; Modular Z80 DarkStar (NE Z80) Monitor
;
;=======================================================================
;
; UARTS AND CTC management
; ---------------------------------------------------------------------


;------- UARTS Section ---------

wrureg	macro	uregister
	ld	a,(suart)
	add	a,uregister
	ld	c,a
	out	(c),b
	endm

rdureg	macro	uregister
	ld	a,(suart)
	add	a,uregister
	ld	c,a
	in	a,(c)
	endm

; ;;
; ;; Select UART for following operations
; ;;
; ;; A = Selected chip
; ;;
;
; SELUART:
; 	LD	(UARTSEL),A
; 	RET

;;
;; Select UART for following operations
;;
;; A = Selected chip
;;

iniuart0:
	ld	a,uart0
	ld	(suart),a
	call	doiniuart
	ret

iniuart1:
	ld	a,uart1
	ld	(suart),a
	call	doiniuart
	ret

doiniuart:
	push	bc
	ld	b,$aa
	wrureg	r7spr
	rdureg	r7spr
	cp	$aa			; test if you could store aa
	jp	nz,iniunok		; if not, the uart can't be found

	ld	b,$55
	wrureg	r7spr
	rdureg	r7spr
	cp	$55			; or is defective
	jp	nz,iniunok

	ld      b, $80
	wrureg	r3lcr			; enable baud rate divisor registers
	ld	a,(suart)		; initialize baud rate.
	cp	uart0			; which uart ?
	jr	nz,iniu1
	ld	a,(uart0br)		; uart 0
	ld	b,a
	jr	iniu2
iniu1:	ld	a,(uart1br)		; uart 1
	ld	b,a
iniu2:	wrureg	r0brdl			; write lsb divisor register
	ld	b,$0
	wrureg	r1brdm			; write msb divisor register (alwyas 0 for us)

	ld	b,00000011b		; setup 8 bit, 1 stop, no parity
					; 7 6 5 4 3 2 1 0
					;             +------ 11 = 8 bit word length
					;           +-------- 0 = 1 stop bit
					;         +---------- 0 = no parity
					;       +------------ 0 = odd parity (n/a)
					;     +-------------- 0 = parity disabled (n/a)
					;   +---------------- 0 = turn break off
					; +------------------ 0 = disable divisor registers
	wrureg	r3lcr
	ld	b,10000111b		; 7 6 5 4 3 2 1 0
					;               +---- 1 = enable FIFO and clear XMIT and RCVR FIFO queues
					;             +------ 1 = clear RCVR FIFO
					;           +-------- 1 = clear XMIT FIFO
					;         +---------- 0 = RXRDY & TXRDY pins mode 0
					;        +-------------- reserved (zero)
					; +------------------ trigger level for FIFO interrupt
					;	Bits      RCVR FIFO
					;	 76     Trigger Level
					;	 00        1 byte
					;	 01        4 bytes
					;	 10        8 bytes         <-- actually
					;	 11       14 bytes
	wrureg	r2fcr
	ld	b,00000001b	        ; 7 6 5 4 3 2 1 0
					;               +---- 1 = enable data available interrupt (and 16550 Timeout)
					;             +------ 0 = disable Transmit Holding Register empty (THRE) interrupt
					;           +-------- 0 = disable Receiver lines status interrupt
					;         +---------- 0 = disable modem-status-change interrupt
					; +------------------ reserved (zero)
	wrureg	r1ier
	pop	bc
	xor	a			; init ok
	ret
iniunok:pop	bc
	ld	a,$ff
	ret

;;
;; Sends a char over serial line 1
;;
;; C: output char

txchar1:
	ld	a,c
	push	bc
	push	af
txbusy1:
	rdureg1	r5lsr			; read status
	bit	5,a			; ready to send?
	jp	z,txbusy1		; no, retry.
	pop	af
	ld	b,a
	wrureg1	r0rxtx
	pop	bc
	ret



;;
;; Receive a char from serial line 1
;;
;; A: return input char

rxchar1:
	push	bc
rxbusy1:
	rdureg1	r5lsr			; read status
	bit	0,a			; data available in rx buffer?
	jr	z,rxbusy1		; loop until data is ready
	rdureg1	r0rxtx
	pop	bc
	ret


;;
;; Test UART status
;;
;; Returned flags:
;; RX status -> carry flag, TX status -> Z flag
;; C = 1: A character is available in the buffer.
;; Z = 1: A character can be sent.

; USTATUS:
; 	PUSH	BC
; 	RDUREG	R5LSR			; read status
; 	RRCA                            ; rotate RX status into carry
; 	BIT     4, A                    ; check TX status (after rot!)
; 	POP	BC
; 	RET

;;
;; Test UART 0 status
;;
;; The code above is clearly better, BUT not suitable for BDOS
;; return codes...
;;
;; Returned value:
;; A =  0: No character in queue
;; A = FF: A character is available

ustatus0:
	ld	a,(tmpbyte)
	bit	5,a			; test system interrupt status
	jr	nz,ustafif		; enabled, uses queue
	push	bc
	rdureg0	r5lsr			; read status
	bit	0,a			; data available in rx buffer?
	pop	bc
	jr	nz,ustat0
	xor	a
	ret
ustafif:
	push	ix
	ld	ix,fifou0
ustaf1:	call	fstat			; check on the status of the queue
	pop	ix
	jr	nz,ustat0		; return if z-flag set
	xor	a
	ret
ustat0:	ld	a,$ff
	ret

;; Test UART 1 status
;;
;; Returned value:
;; A =  0: No character in queue
;; A = FF: A character is available

ustatus1:
	push	bc
	rdureg1	r5lsr			; read status
	bit	0,a			; data available in rx buffer?
	pop	bc
	jr	nz,ustat1
	xor	a
	ret
ustat1:	ld	a,$ff
	ret



;------- CTC Section ---------

; NOTE: system interrupts are not enabled here. Look at resident portion
;       of the BIOS

;;
;; initialize Z80CTC
;;

inictc:
	; First resets all four channels
	call	resctc

	; CTC interrupt vector
	ld	a,$f0			; vec is at FFF0
	out	(ctcchan0),a

	; Channel 3 - UART 0 interrupt handler
	ld	a,11010111b		; 7 6 5 4 3 2 1 0
					;               +---- 1 = command flag
					;             +------ 1 = channel reset
					;           +-------- 1 = time constant follow
					;         +---------- 0 = n/a in counter mode
					;       +------------ 1 = rise edge clock
					;     +-------------- 0 = n/a in counter mode
					;   +---------------- 1 = select counter mode
					; +------------------ 1 = enable interrupts
	out	(ctcchan3),a
	ld	a,1			; time constant set to 1. At first interrupt request
					; from the UART will route it to the CPU
	out	(ctcchan3),a

	; Channel 2 - UART 1 interrupt handler
	ld	a,11010111b		; 7 6 5 4 3 2 1 0
					;               +---- 1 = command flag
					;             +------ 1 = channel reset
					;           +-------- 1 = time constant follow
					;         +---------- 0 = n/a in counter mode
					;       +------------ 1 = rise edge clock
					;     +-------------- 0 = n/a in counter mode
					;   +---------------- 1 = select counter mode
					; +------------------ 1 = enable interrupts
	out	(ctcchan2),a
	ld	a,1			; time constant set to 1. At first interrupt request
					; form the UART will route it to the CPU
	out	(ctcchan2),a

	; Channel 1 - lo speed system timer
	ld	a,11010111b		; 7 6 5 4 3 2 1 0
					;               +---- 1 = command flag
					;             +------ 1 = channel reset
					;           +-------- 1 = time constant follow
					;         +---------- 0 = n/a in counter mode
					;       +------------ 1 = rise edge clock
					;     +-------------- 0 = n/a in counter mode
					;   +---------------- 1 = select counter mode
					; +------------------ 1 = enable interrupts
	out	(ctcchan1),a
	ld	a,(ctc1tc)		; time constant for system timer (from 100 to 2 Hz)
	out	(ctcchan1),a

	; Channel 0 - hi speed timer/prescaler (feed channel 1)
	ld	a,00100111b		; 7 6 5 4 3 2 1 0
					;               +---- 1 = command flag
					;             +------ 1 = channel reset
					;           +-------- 1 = time constant follow
					;         +---------- 0 = start immediate
					;       +------------ 0 = no trigger
					;     +-------------- 1 = prescale 256
					;   +---------------- 0 = select timer mode
					; +------------------ 0 = disable interrupts
	out	(ctcchan0),a
	ld	a,(ctc0tc)			; time constant set to 32. 4Mhz / 256 / 32 = 488.28Hz
	out	(ctcchan0),a

	ret				; all done

;;
;;
;;
ctcunlck:
	reti

;;
;; Resets CTC
;;
resctc:
	ld	a,00000011b		; 7 6 5 4 3 2 1 0
					;               +---- 1 = command flag
					;             +------ 1 = channel reset
					; +------------------ 0 = n/a
	out	(ctcchan0),a
	out	(ctcchan1),a
	out	(ctcchan2),a
	out	(ctcchan3),a
	call	ctcunlck
	ret
; -----------

suart:	defb	0

; -----------

