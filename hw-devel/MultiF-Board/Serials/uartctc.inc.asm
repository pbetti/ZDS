;
;=======================================================================
;
; Modular Z80 DarkStar (NE Z80) Monitor
;
;=======================================================================
;
; UARTS AND CTC management
; ---------------------------------------------------------------------


ANSIDRV	EQU	FALSE			; set TRUE to enable ANSI console driver

;------- UARTS Section ---------


WRUREG0	macro	uregister
	LD	A,UART0
	ADD	A,uregister
	LD	C,A
	OUT	(C),B
	endm

RDUREG0	macro	uregister
	LD	A,UART0
	ADD	A,uregister
	LD	C,A
	IN	A,(C)
	endm

WRUREG1	macro	uregister
	LD	A,UART1
	ADD	A,uregister
	LD	C,A
	OUT	(C),B
	endm

RDUREG1	macro	uregister
	LD	A,UART1
	ADD	A,uregister
	LD	C,A
	IN	A,(C)
	endm

WRUREG	macro	uregister
	LD	A,(SUART)
	ADD	A,uregister
	LD	C,A
	OUT	(C),B
	endm

RDUREG	macro	uregister
	LD	A,(SUART)
	ADD	A,uregister
	LD	C,A
	IN	A,(C)
	endm

DESEQ	macro	p1,p2
	LD	DE,[p1 << 8] + p2
	endm

; 	EXTERN	FSTAT, FOUT

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

INIUART0:
	LD	A,UART0
	LD	(SUART),A
	CALL	DOINIUART
	RET

INIUART1:
	LD	A,UART1
	LD	(SUART),A
	CALL	DOINIUART
	RET

DOINIUART:
	PUSH	BC
	LD	B,$AA
	WRUREG	R7SPR
	RDUREG	R7SPR
	CP	$AA			; test if you could store aa
	JP	NZ,INIUNOK		; if not, the uart can't be found

	LD	B,$55
	WRUREG	R7SPR
	RDUREG	R7SPR
	CP	$55			; or is defective
	JP	NZ,INIUNOK

	LD      B, $80
	WRUREG	R3LCR			; enable baud rate divisor registers
	LD	A,(SUART)		; initialize baud rate.
	CP	UART0			; which uart ?
	JR	NZ,INIU1
	LD	A,(UART0BR)		; uart 0
	LD	B,A
	JR	INIU2
INIU1:	LD	A,(UART1BR)		; uart 1
	LD	B,A
INIU2:	WRUREG	R0BRDL			; write lsb divisor register
	LD	B,$0
	WRUREG	R1BRDM			; write msb divisor register (alwyas 0 for us)

	LD	B,00000011B		; setup 8 bit, 1 stop, no parity
					; 7 6 5 4 3 2 1 0
					;             +------ 11 = 8 bit word length
					;           +-------- 0 = 1 stop bit
					;         +---------- 0 = no parity
					;       +------------ 0 = odd parity (n/a)
					;     +-------------- 0 = parity disabled (n/a)
					;   +---------------- 0 = turn break off
					; +------------------ 0 = disable divisor registers
	WRUREG	R3LCR
	LD	B,00000111B		; 7 6 5 4 3 2 1 0
					;               +---- 1 = enable FIFO and clear XMIT and RCVR FIFO queues
					;             +------ 1 = clear RCVR FIFO
					;           +-------- 1 = clear XMIT FIFO
					;         +---------- 0 = RXRDY & TXRDY pins mode 0
					;        +-------------- reserved (zero)
					; +------------------ trigger level for FIFO interrupt
					;	Bits      RCVR FIFO
					;	 76     Trigger Level
					;	 00        1 byte         <-- actually
					;	 01        4 bytes
					;	 10        8 bytes
					;	 11       14 bytes
	WRUREG	R2FCR
	LD	B,00000001B	        ; 7 6 5 4 3 2 1 0
					;               +---- 1 = enable data available interrupt (and 16550 Timeout)
					;             +------ 0 = disable Transmit Holding Register empty (THRE) interrupt
					;           +-------- 0 = disable Receiver lines status interrupt
					;         +---------- 0 = disable modem-status-change interrupt
					; +------------------ reserved (zero)
	WRUREG	R1IER
	POP	BC
	XOR	A			; init ok
	RET
INIUNOK:POP	BC
	LD	A,$FF
	RET


;;
;; Sends a char over serial line 0
;;
;; C: output char

	IF NOT ANSIDRV
TXCHAR0:
	ELSE
DOTXCHAR:
	ENDIF
	LD	A,C
	PUSH	BC
	PUSH	AF
TXBUSY0:
	RDUREG0	R5LSR			; read status
	BIT	5,A			; ready to send?
	JP	Z,TXBUSY0		; no, retry.
	POP	AF
	LD	B,A
	WRUREG0	R0RXTX
	POP	BC
	RET

;;
;; Sends a char over serial line 1
;;
;; C: output char

TXCHAR1:
	LD	A,C
	PUSH	BC
	PUSH	AF
TXBUSY1:
	RDUREG1	R5LSR			; read status
	BIT	5,A			; ready to send?
	JP	Z,TXBUSY1		; no, retry.
	POP	AF
	LD	B,A
	WRUREG1	R0RXTX
	POP	BC
	RET



;;
;; Receive a char from serial line 1
;;
;; A: return input char

RXCHAR1:
	PUSH	BC
RXBUSY1:
	RDUREG1	R5LSR			; read status
	BIT	0,A			; data available in rx buffer?
	JR	Z,RXBUSY1		; loop until data is ready
	RDUREG1	R0RXTX
	POP	BC
	RET

;;
;; Receive a char from serial line 0
;;
;; A: return input char

RXCHAR0:
	PUSH	BC
	PUSH	IX
	PUSH	DE
	PUSH	HL
	LD	IX,TMPBYTE

	IF	ANSIDRV
	LD	DE,(ALINKS)
	BIT	3,(IX)			; two byte seq pending
	JP	NZ,RXEXSB
	ENDIF

ESCNX:	LD	A,(IX)
	BIT	5,A			; test system interrupt status
	JR	NZ,RXCHAFIF		; enabled, uses queue
RXBUSY0:
	RDUREG0	R5LSR			; read status
	BIT	0,A			; data available in rx buffer?
	JR	Z,RXBUSY0		; loop until data is ready
	RDUREG0	R0RXTX
	JR	RXCHE
RXCHAFIF:
	LD	IX,FIFOU0
RXCHAFLP:
	CALL	FSTAT			; queue status
	JR	Z,RXCHAFLP		; loop until char is ready
	DI
	CALL	FOUT			; get a character from the queue
	EI
	LD	A,C 			; and put it in correct register
RXCHE:	LD	HL,MIOBYTE
	BIT	3,(HL)			; yes: transform to uppercase ?
	JR	Z,RXCHE1		; no
	CP	'a'			; yes: is less then 'a' ?
	JP	M,RXCHE1		; yes: return, already ok
	CP	'{'			; no: then is greater than 'z' ?
	JP	P,RXCHE1		; yes: do nothing
	RES	5,A			; no: convert uppercase...
RXCHE1:
	IF 	NOT ANSIDRV
	POP	HL
	POP	DE
	POP	IX
	POP	BC
	RET
	ELSE
	LD	IX,TMPBYTE		; point to flag byte
	BIT	4,(IX)			; driver disabled ?
	JP	NZ,RXEXIMM		; yes exit
	BIT	2,(IX)			; in sequence job?
	JR	NZ,PRCSQ		; yes
	BIT	1,(IX)			; in CSI job?
	JR	NZ,WTCSI		; yes
	CP	ESC			; ESC ?
	JP	NZ,RXEXIMM		; no exit
	;
	SET	1,(IX)			; activate ANSI keys processing
	; may be that user pressed ESC and this is not a sequence...
	LD	DE,2			; wait 2 ms, trying to see if this is a user
	CALL	DELAY			; operation with the ESC key.
	BIT	5,(IX)			; now we see if other chars are already availables
	JR	NZ,RXESCFIF		; int enabled, test uses queue
	RDUREG0	R5LSR			; read status
	BIT	0,A			; data available in rx buffer?
	JR	Z,RXEXESC		; no, user pressed ESC
	JP	ESCNX			; yes, go on
RXESCFIF:
	PUSH	IX
	LD	IX,FIFOU0
	CALL	FSTAT			; data available in queue?
	POP	IX
	JR	Z,RXEXESC		; no, user pressed ESC
	JP	ESCNX			; yes, we have something to work on
	;
WTCSI:	RES	1,(IX)			; in CSI reset flags
	CP	'['			; is a CSI: ESC+[ ?
	JR	Z,GOCSI			; yes
	CP	'O'			; is a CSI: ESC+O ? (used by F1 ... F4)
	JR	NZ,RXEXIMM		; WRONG sequence
GOCSI:	;
	SET	2,(IX)			; CSI ok
	JP	ESCNX			; wait for next chars
PRCSQ:	;
	LD	HL,ASQBUF		; setup string
	LD	B,(HL)
	INC	B
	LD	(HL),B
POSBF:	INC	HL
	DJNZ	POSBF			; position in buffer
	LD	(HL),A			; write
	INC	HL
	LD	(HL),0			; terminate
	LD	DE,ASQBUF+1		; init search
	LD	HL,ANSIKEYS
	LD	BC,NAKEYS
	CALL	TLOOK			; perform it
	JR	NZ,RXEXIMM		; unknown seq
	;				; found in table, but we need
	LD	DE,(ALINKS)		; to test for a partial match
	OR	A			; diff from string head
	SBC	HL,DE
	DEC	L
	DEC	L
	DEC	L			; include head
	LD	A,(ALNGHT)		; check for len
	SUB	L
	JP	NZ,ESCNX		; partial match, wait for more
	LD	A,(DE)			; got it!
	CP	ESC			; if ESC is a two byte seq
	JR	NZ,RXEXSB		; exit for single byte code
	SET	3,(IX)			; flag a two byte retcode
	JR	RXEXIMM
RXEXSB:	RES	3,(IX)			; clear two-byters flag
	XOR	A
	LD	(ASQBUF),A
	INC	DE
	LD	A,(DE)			; return code
	JR	RXEXIMM
RXEX0:
	POP	AF
	JR	RXEXIMM
RXEXESC:
	LD	A,ESC
RXEXIMM:
	RES	2,(IX)
	POP	HL
	POP	DE
RXEXNP:	POP	IX
	POP	BC
	RET

;;
;; Any lenght string compare
;;
;; DE, HL < strings addresses
;; BC < max lenght
;; > Z = 1 found
CPSTR:	LD	A,(DE)			; get char from str1
	INC	DE			; index next and compare
	CPI
	RET	NZ			; no match
	RET	PO			; end of string
	JR	CPSTR

;;
;; string table lookup
;;
;; DE < test string, HL < table, BC < # strings in table
;; > Z = 1 match, HL > in string match + 1
TSTLP:	PUSH	DE			; saves
	PUSH	BC
	LD	(ALINKS),HL		; current string start (incl. head)
	INC	HL
	INC	HL			; skip linked address
	LD	B,0
	LD	C,(HL)			; current string length
	LD	A,C
	LD	(ALNGHT),A		; current string len
	INC	HL
	LD	A,(ASQBUF)
	LD	C,A			; test string len
	CALL	CPSTR			; do compare
	JR	Z,MATCH			; exit if found
	LD	HL,(ALINKS)
	LD	A,(ALNGHT)		; reload current string len
	ADD	A,3
	LD	C,A
	ADD	HL,BC			; add length, address next
	POP	BC			; restore count
	POP	DE			; restore test string
	DEC	BC			; update string count
	;
TLOOK:	LD	A,B			; table search entry point
	OR	C			; check count = 0
	JR	NZ,TSTLP		; search next if not
	INC	A			; not found z = 0
	RET
MATCH:	POP	BC
	POP	DE			; clear stack
	RET				; found !


ASQBUF:	DEFB	0
ASQSTR:	DEFS	4
ALINKS:	DEFW	0
ALNGHT:	DEFB	0

	ENDIF


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

USTATUS0:
	LD	A,(TMPBYTE)
	BIT	5,A			; test system interrupt status
	JR	NZ,USTAFIF		; enabled, uses queue
	PUSH	BC
	RDUREG0	R5LSR			; read status
	BIT	0,A			; data available in rx buffer?
	POP	BC
	JR	NZ,USTAT0
	XOR	A
	RET
USTAFIF:
	PUSH	IX
	LD	IX,FIFOU0
USTAF1:	CALL	FSTAT			; check on the status of the queue
	POP	IX
	JR	NZ,USTAT0		; return if z-flag set
	XOR	A
	RET
USTAT0:	LD	A,$FF
	RET

;; Test UART 1 status
;;
;; Returned value:
;; A =  0: No character in queue
;; A = FF: A character is available

USTATUS1:
	PUSH	BC
	RDUREG1	R5LSR			; read status
	BIT	0,A			; data available in rx buffer?
	POP	BC
	JR	NZ,USTAT1
	XOR	A
	RET
USTAT1:	LD	A,$FF
	RET


	IF ANSIDRV			; ANSI driver for serial console
;;
;; TXCHAR print out the char in reg C
;; with full evaluation of kegacy escape sequences
;; translated into ANSI equivalents for serial console
;;
;; register clean: can be used as CP/M BIOS replacement
;;
TXCHAR0:
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	; force jump to register restore and exit in stack
	LD	HL,TXCEXIT
	PUSH	HL
	;
	LD	A,C
	LD	HL,TMPBYTE
	BIT	4,(HL)			; plain serial i/o ?
	JR	NZ,TXJP3		; yes. transmit as-is
	LD	HL,MIOBYTE
	BIT	7,(HL)			; alternate char processing ?
	EX	DE,HL
	JR	NZ,TXCOU2		; yes: do alternate
	CP	$20			; no: is less then 0x20 (space) ?
	JR	NC,TXJP1		; no: go further
	ADD	A,A			; yes: is a special char
	LD	H,0
	LD	L,A
	LD	BC,TXVEC1
	ADD	HL,BC
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	JP	(HL)			; jump to TXVEC1 handler
TXJP1:	EX	DE,HL
	BIT	6,(HL)			; auto ctrl chars ??
	JR	Z,TXJP2			; no
	CP	$40			; yes: convert
	JR	C,TXJP2
	CP	$60
	JR	NC,TXJP2
	SUB	$40
	JR	TXJP3
TXJP2:	CP	$C0			; is semigraphic ?
	JR	C,TXJP3			; no
	SUB	$C0			; to table offset
	LD	H,0
	LD	L,A
	LD	BC,EQCP437
	ADD	HL,BC
	LD	C,(HL)
TXJP3:	CALL	DOTXCHAR		; display char
	RET
TXCOU2:					; alternate processing....
	CP	$20			; is a ctrl char ??
	JR	NC,ACRADR		; no: will set cursor pos
	ADD	A,A			; yes
	LD	H,0
	LD	L,A
	LD	BC,TXVEC2
	ADD	HL,BC
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	JP	(HL)			; jump to service routine... (TXVEC2)
;; cursor addressing service routine
;; address is ESC + (COL # + 32) + (ROW # + 32) (then need a NUL to terminate...)
;; will be: CSI (ESC,[) + row + ';' + col + 'H'
ACRADR:	LD	HL,TMPBYTE
	BIT	0,(HL)
	JR	NZ,ROWSET
	CP	$70			; greater then 80 ?
	RET	NC			; yes: error
	SUB	$1F			; no: ok
	LD	(APPBUF),A		; store column
	SET	0,(HL)			; switch row/col flag
	RET
ROWSET:	CP	$39			; greater than 24 ?
	RET	NC			; yes: error
	SUB	$1F			; no: ok
	RES	0,(HL)			; resets flags
	LD	HL,MIOBYTE
	RES	7,(HL)			; done reset
	LD	D,A			; load row
	LD	E,';'
	CALL	SEQEMIT			; and send
	LD	A,(APPBUF)		; load column
	LD	D,A
	LD	E,'H'
	CALL	SEQPAR			; and send
	POP	HL			; clean stack
TXCEXIT:
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET

CSIEMIT:
	LD	B,2
	LD	HL,CSI
CSICH:	LD	C,(HL)
	CALL	DOTXCHAR
	INC	HL
	DJNZ	CSICH
	RET

SEQEMIT:
	CALL	CSIEMIT			; send CSI
SEQPAR:	LD	A,D			; sequence parameter in D
	CP	$FF			; null, skip it
	JR	Z,SEQCMD
	OR	A			; zero ?
	JR	Z,SEQZER
	LD	B,A			; convert to BCD
	XOR	A
SQDAA:	INC	A
	DAA
	DJNZ	SQDAA
	LD	D,A
	AND	$F0			; hi nibble
	SRL	A
	SRL	A
	SRL	A
	SRL	A
	ADD	A,'0'
	CALL	SEQCHR			; send over
	LD	A,D			; reload parameter
	AND	$0F			; lo nibble
SEQZER:	ADD	A,'0'
	CALL	SEQCHR
SEQCMD:	LD	A,E			; sequence command in E
	CP	$FF			; null, skip it
	JR	Z,SEQEND
	JR	SEQCHR			; ...and send this too
SEQEND:	RET

SEQCHR:	LD	C,A			; send
	CALL	DOTXCHAR
	RET

CSI:	DEFB	ESC,'['


;; This table define the offsets to jump to translation routines
;; for primary (non-escaped) mode

TXVEC1:
	DW	RIOCESC			; NUL 0x00 (^@)  clear alternate output processing
	DW	UCASEMOD		; SOH 0x01 (^A)  uppercase mode
	DW	LCASEMOD		; STX 0x02 (^B)  normal case mode
	DW	TXNULL			; ETX 0x00 (^C)  no-op
	DW	ACUROF			; EOT 0x04 (^D)  cursor off
	DW	ACURON			; ENQ 0x05 (^E)  cursor on
	DW	TXNULL			; ACK 0x06 (^F)  locate cursor at CURPBUF
	DW	TXBEL			; BEL 0x07 (^G)  beep
	DW	AMVLFT			; BS  0x08 (^H)  cursor left (destr. and non destr.)
	DW	TXNULL			; HT  0x09 (^I)  no-op
	DW	TXLF			; LF  0x0a (^J)  cursor down one line
	DW	ACHOME			; VT  0x0b (^K)  cursor @ column 0
	DW	ACLS			; FF  0x0c (^L)  page down (clear screen)
	DW	TXCR			; CR  0x0d (^M)  provess CR
	DW	ACLEOP			; SO  0x0e (^N)  clear to EOP
	DW	ACLEOL			; SI  0x0f (^O)  clear to EOL
	DW	TXNULL			; DLE 0x10 (^P)  no-op
	DW	ARESATR			; DC1 0x11 (^Q)  reset all attributes
	DW	TXNULL			; DC2 0x12 (^R)  hard crt reset and clear
	DW	TXNULL			; DC3 0x13 (^S)  no-op
	DW	TXNULL			; DC4 0x14 (^T)  no-op
	DW	AMVUP			; NAK 0x15 (^U)  cursor up one line
	DW	TXNULL			; SYN 0x16 (^V)  scroll off
	DW	TXNULL			; ETB 0x17 (^W)  scroll on
	DW	AMVLFTND		; CAN 0x18 (^X)  cursor left (non destr. only)
	DW	AMVRGT			; EM  0x19 (^Y)  cursor right
	DW	AMVDWN			; SUB 0x1a (^Z)  cursor down one line
	DW	SIOCESC			; ESC 0x1b (^[)  activate alternate output processing
	DW	TXNULL			; FS  0x1c (^\)  no-op
	DW	TXNULL			; GS  0x1d (^])  no-op
	DW	TXNULL			; RS  0x1e (^^)  disabled (no-op)
	DW	TXNULL			; US  0x1f (^_)  no-op

;; This table define the offsets to jump to translation routines
;; for alternate (escaped) mode

TXVEC2:
	DW	RIOCESC			; NUL 0x00 (^@)  clear alternate output processing
	DW	ABLNKOF			; SOH 0x01 (^A)  BLINK OFF
	DW	ABLNKON			; STX 0x02 (^B)  BLINK ON
	DW	AUNDROF			; ETX 0x03 (^C)  UNDER OFF
	DW	AUNDRON			; EOT 0x04 (^D)  UNDER ON
	DW	AHLITOF			; ENQ 0x05 (^E)  HLIGHT OFF
	DW	AHLITON			; ACK 0x06 (^F)  HLIGHT ON
	DW	TXNULL			; BEL 0x07 (^G)  no-op
	DW	TXNULL			; BS  0x08 (^H)  no-op
	DW	TXNULL			; HT  0x09 (^I)  no-op
	DW	TXNULL			; LF  0x0a (^J)  no-op
	DW	TXNULL			; VT  0x0b (^K)  no-op
	DW	ACLS			; FF  0x0c (^L)  blank screen
	DW	RIOCESC			; CR  0x0d (^M)  clear alternate output processing
	DW	AREDON			; SO  0x0e (^N)  set bit 5 RAM3BUF (red)
	DW	AWHTON			; SI  0x0f (^O)  res bit 5 RAM3BUF (red)
	DW	AGRNON			; DLE 0x10 (^P)  set bit 6 RAM3BUF (green)
	DW	AWHTON			; DC1 0x11 (^Q)  res bit 6 RAM3BUF (green)
	DW	TXNULL			; DC2 0x12 (^R)  cursor blink slow block
	DW	TXNULL			; DC3 0x13 (^S)  cursor blink slow line
	DW	TXNULL			; DC4 0x14 (^T)  no-op
	DW	TXNULL			; NAK 0x15 (^U)  no-op
	DW	TXNULL			; SYN 0x16 (^V)  no-op
	DW	SASCFLTR		; ETB 0x17 (^W)  set ascii filter
	DW	RASCFLTR		; CAN 0x18 (^X)  reset ascii filter
	DW	NDBKSP			; EM  0x19 (^Y)  set non destructive BS
	DW	DBKSP			; SUB 0x1a (^Z)  set destructive BS
	DW	AREVSON			; ESC 0x1b (^[)  REVERSE ON
	DW	AREVSOF			; FS  0x1c (^\)  REVERSE OFF
	DW	ABLUON			; GS  0x1d (^])  set bit 7 RAM3BUF (blue)
	DW	AWHTON			; RS  0x1e (^^)  res bit 7 RAM3BUF (blue)
	DW	TXNULL			; US  0x1f (^_)  no-op

;;
;; ANSI ESCapes specific routines
;;
;; no comments on code below but it should be quite intuitive

TXNULL:
	RET

TXCR:
	LD	C,CR
	JP	DOTXCHAR

TXLF:
	LD	C,LF
	JP	DOTXCHAR

TXBKSP:
	LD	C,$08
	JP	DOTXCHAR

TXBEL:
	LD	C,$07
	JP	DOTXCHAR

AMVLFT:
	LD	HL,MIOBYTE
	BIT	4,(HL)
	JR	NZ,AMVLFTND
	JR	TXBKSP

ACUROF:					; CSI ?25l
	DESEQ	$FF,'?'
	CALL	SEQEMIT
	DESEQ	25,'l'
	CALL	SEQPAR
	RET

ACURON:					; CSI ?25h
	DESEQ	$FF,'?'
	CALL	SEQEMIT
	DESEQ	25,'h'
	CALL	SEQPAR
	RET

AMVLFTND:
	DESEQ	$FF,'D'			; CSI n D
	JR	DOSND1

AMVDWN:
	DESEQ	$FF,'B'			; CSI n B
	JR	DOSND1

AMVUP:
	DESEQ	$FF,'A'			; CSI n A
	JR	DOSND1

AMVRGT:
	DESEQ	$FF,'C'			; CSI n C
	JR	DOSND1

ACHOME:					; CSI 0 G
	DESEQ	0,'G'
	JR	DOSND1

ACLS:					; CSI 2 J
	DESEQ	2,'J'
	CALL	SEQEMIT
	DESEQ	$FF,'H'
	JR	DOSND1

ACLEOP:					; CSI 0 J
	DESEQ	0,'J'
	JR	DOSND1

ACLEOL:					; CSI 0 K
	DESEQ	0,'K'
	JR	DOSND1

ARESATR:				; CSI 0 m
	DESEQ	0,'m'
	JR	DOSND1

ABLNKOF:				; CSI 25 m
	DESEQ	25,'m'
	JR	DOSND1

ABLNKON:				; CSI 5 m
	DESEQ	5,'m'
	JR	DOSND1

AREVSOF:				; CSI 27 m
	DESEQ	27,'m'
	JR	DOSND1

AREVSON:				; CSI 7 m
	DESEQ	7,'m'
	JR	DOSND1


AUNDROF:				; CSI 24 m
	DESEQ	24,'m'
	JR	DOSND1

AUNDRON:				; CSI 4 m
	DESEQ	4,'m'
	JR	DOSND1

AHLITOF:				; CSI 22 m
	DESEQ	22,'m'
	JR	DOSND1

AHLITON:				; CSI 1 m
	DESEQ	1,'m'
	JR	DOSND1

AREDON:					; CSI 31 m
	DESEQ	31,'m'
	JR	DOSND1

AGRNON:					; CSI 32 m
	DESEQ	32,'m'
	JR	DOSND1

ABLUON:					; CSI 34 m
	DESEQ	34,'m'
	JR	DOSND1

AWHTON:					; CSI 37 m
	DESEQ	37,'m'
	JR	DOSND1

DOSND1:	CALL	SEQEMIT
	RET

; keyboard translation table

NAKEYS	EQU	22

		; sequences emitted upon reception of valid
		; keyboard input and valid sequences expected
ANSIKEYS:	; on keyboard input
	DEFB	$00,$7F		; DEL
	DEFB	2,"3~"
	DEFB	$00,$16		; INS
	DEFB	2,"2~"
	DEFB	$00,$1D		; HOME
	DEFB	1,"H"
	DEFB	$00,$14		; END
	DEFB	1,"F"
	DEFB	$00,$13		; PGUP
	DEFB	2,"5~"
	DEFB	$00,$07		; PGDN
	DEFB	2,"6~"
	DEFB	$00,$15		; UP
	DEFB	1,"A"
	DEFB	$00,$1A		; DOWN
	DEFB	1,"B"
	DEFB	$00,$18		; LEFT
	DEFB	1,"D"
	DEFB	$00,$19		; RIGHT
	DEFB	1,"C"
	DEFB	$1B,'A'		; F1 ...
	DEFB	1,"P"
	DEFB	$1B,'B'
	DEFB	1,"Q"
	DEFB	$1B,'C'
	DEFB	1,"R"
	DEFB	$1B,'D'
	DEFB	1,"S"
	DEFB	$1B,'E'
	DEFB	3,"15~"
	DEFB	$1B,'F'
	DEFB	3,"17~"
	DEFB	$1B,'G'
	DEFB	3,"18~"
	DEFB	$1B,'H'
	DEFB	3,"19~"
	DEFB	$1B,'I'
	DEFB	3,"20~"
	DEFB	$1B,'J'
	DEFB	3,"21~"
	DEFB	$1B,'K'
	DEFB	3,"23~"
	DEFB	$1B,'L'		; ... F12
	DEFB	3,"24~"

	; This table definex (possible) equivalence from NEZ80 character ROMs
	; and Code Page 437.
	; Note that final rendering on remote is really dependent from ITS font usage
	; 1) we consider only chars from $C0 to $FF
	; 2) no equivalents from $81 to $BF

EQCP437:
	DEFB	179,196,197,195,180,194,193,192,217,218,191,186,205,206,204,185
	DEFB	203,202,200,188,201,187,198,181,210,208,214,183,211,189,213,184
	DEFB	212,190,199,182,209,207,215,216,025,026,006,003,004,005,156,157
	DEFB	178,176,224,225,046,235,231,046,239,046,046,237,228,046,234,227


	ENDIF

;------- CTC Section ---------

; NOTE: system interrupts are not enabled here. Look at resident portion
;       of the BIOS

;;
;; initialize Z80CTC
;;

INICTC:
	; First resets all four channels
	CALL	RESCTC

	; CTC interrupt vector
	LD	A,$F0			; vec is at FFF0
	OUT	(CTCCHAN0),A

	; Channel 3 - UART 0 interrupt handler
	LD	A,11010111B		; 7 6 5 4 3 2 1 0
					;               +---- 1 = command flag
					;             +------ 1 = channel reset
					;           +-------- 1 = time constant follow
					;         +---------- 0 = n/a in counter mode
					;       +------------ 1 = rise edge clock
					;     +-------------- 0 = n/a in counter mode
					;   +---------------- 1 = select counter mode
					; +------------------ 1 = enable interrupts
	OUT	(CTCCHAN3),A
	LD	A,1			; time constant set to 1. At first interrupt request
					; form the UART will route it to the CPU
	OUT	(CTCCHAN3),A

	; Channel 2 - UART 1 interrupt handler
	LD	A,11010111B		; 7 6 5 4 3 2 1 0
					;               +---- 1 = command flag
					;             +------ 1 = channel reset
					;           +-------- 1 = time constant follow
					;         +---------- 0 = n/a in counter mode
					;       +------------ 1 = rise edge clock
					;     +-------------- 0 = n/a in counter mode
					;   +---------------- 1 = select counter mode
					; +------------------ 1 = enable interrupts
	OUT	(CTCCHAN2),A
	LD	A,1			; time constant set to 1. At first interrupt request
					; form the UART will route it to the CPU
	OUT	(CTCCHAN2),A

	; Channel 1 - lo speed system timer
	LD	A,11010111B		; 7 6 5 4 3 2 1 0
					;               +---- 1 = command flag
					;             +------ 1 = channel reset
					;           +-------- 1 = time constant follow
					;         +---------- 0 = n/a in counter mode
					;       +------------ 1 = rise edge clock
					;     +-------------- 0 = n/a in counter mode
					;   +---------------- 1 = select counter mode
					; +------------------ 1 = enable interrupts
	OUT	(CTCCHAN1),A
	LD	A,(CTC1TC)		; time constant for system timer (from 100 to 2 Hz)
	OUT	(CTCCHAN1),A

	; Channel 0 - hi speed timer/prescaler (feed channel 1)
	LD	A,00100111B		; 7 6 5 4 3 2 1 0
					;               +---- 1 = command flag
					;             +------ 1 = channel reset
					;           +-------- 1 = time constant follow
					;         +---------- 0 = start immediate
					;       +------------ 0 = no trigger
					;     +-------------- 1 = prescale 256
					;   +---------------- 0 = select timer mode
					; +------------------ 0 = disable interrupts
	OUT	(CTCCHAN0),A
	LD	A,(CTC0TC)			; time constant set to 32. 4Mhz / 256 / 32 = 488.28Hz
	OUT	(CTCCHAN0),A

	RET				; all done

;;
;;
;;
CTCUNLCK:
	RETI

;;
;; Resets CTC
;;
RESCTC:
	CALL	CTCUNLCK
	LD	A,00000011B		; 7 6 5 4 3 2 1 0
					;               +---- 1 = command flag
					;             +------ 1 = channel reset
					; +------------------ 0 = n/a
	OUT	(CTCCHAN0),A
	OUT	(CTCCHAN1),A
	OUT	(CTCCHAN2),A
	OUT	(CTCCHAN3),A
	RET
; -----------

SUART:	DEFB	0

; -----------
