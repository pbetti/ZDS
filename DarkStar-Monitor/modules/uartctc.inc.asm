;
;=======================================================================
;
; Modular Z80 DarkStar (NE Z80) Monitor
;
;=======================================================================
;
; UARTS AND CTC management
; ---------------------------------------------------------------------


ansidrv	equ	true			; set TRUE to enable ANSI console driver

;------- UARTS Section ---------


wrureg0	macro	uregister
	out	(uart0+uregister),a
	endm

rdureg0	macro	uregister
	in	a,(uart0+uregister)
	endm

wrureg1	macro	uregister
	out	(uart1+uregister),a
	endm

rdureg1	macro	uregister
	in	a,(uart1+uregister)
	endm

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

deseq	macro	p1,p2
	ld	de,[p1 << 8] + p2
	endm

	extern	fstat, fout, srxrsm

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
;; Sends a char over serial line 0
;;
;; C: output char

	if not ansidrv
txchar0:
	else
dotxchar:
	endif
	ld	a,c
	push	bc
	push	af
txbusy0:
	rdureg0	r5lsr			; read status
	bit	5,a			; ready to send?
	jp	z,txbusy0		; no, retry.
	pop	af
	ld	b,a
	wrureg0	r0rxtx
	pop	bc
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
;; Receive a char from serial line 0
;;
;; A: return input char

rxchar0:
	push	bc
	push	ix
	push	de
	push	hl
	ld	ix,tmpbyte

	if	ansidrv
	ld	de,(alinks)
	bit	3,(ix)			; two byte seq pending
	jp	nz,rxexsb
	endif

escnx:	bit	5,(ix)			; test system interrupt status
	jr	nz,rxchafif		; enabled, uses queue
rxbusy0:
	rdureg0	r5lsr			; read status
	bit	0,a			; data available in rx buffer?
	jr	z,rxbusy0		; loop until data is ready
	rdureg0	r0rxtx
	jr	rxche
rxchafif:
	ld	ix,fifou0
	call	fstat			; queue status
	call	z,srxrsm		; if empty ensure rx is unlocked
rxchaflp:
	call	fstat			; queue status
	jr	z,rxchaflp		; loop until char is ready
	di
	call	fout			; get a character from the queue
	ei
	ld	a,c 			; and put it in correct register
rxche:	ld	hl,miobyte
	bit	3,(hl)			; yes: transform to uppercase ?
	jr	z,rxche1		; no
	cp	'a'			; yes: is less then 'a' ?
	jp	m,rxche1		; yes: return, already ok
	cp	'{'			; no: then is greater than 'z' ?
	jp	p,rxche1		; yes: do nothing
	res	5,a			; no: convert uppercase...
rxche1:
	if 	not ansidrv
	ld	a,(tmpbyte)
	bit	5,a			; test system interrupt status
	jr	z,rxche1a		; disabled don't check queue
	call	fstat			; queue status
	call	z,srxrsm		; if empty unlock rx
rxche1a:
	pop	hl
	pop	de
	pop	ix
	pop	bc
	ret
	else
	ld	ix,tmpbyte		; point to flag byte
	bit	4,(ix)			; driver disabled ?
	jp	nz,rxeximm		; yes exit
	bit	2,(ix)			; in sequence job?
	jr	nz,prcsq		; yes
	bit	1,(ix)			; in CSI job?
	jr	nz,wtcsi		; yes
	cp	esc			; ESC ?
	jp	nz,rxeximm		; no exit
	;
	set	1,(ix)			; activate ANSI keys processing
	; may be that user pressed ESC and this is not a sequence...
	ld	de,2			; wait 2 ms, trying to see if this is a user
	call	delay			; operation with the ESC key.
	bit	5,(ix)			; now we see if other chars are already availables
	jr	nz,rxescfif		; int enabled, test uses queue
	rdureg0	r5lsr			; read status
	bit	0,a			; data available in rx buffer?
	jr	z,rxexesc		; no, user pressed ESC
	jp	escnx			; yes, go on
rxescfif:
	push	ix
	ld	ix,fifou0
	call	fstat			; data available in queue?
	pop	ix
	jr	z,rxexesc		; no, user pressed ESC
	jp	escnx			; yes, we have something to work on
	;
wtcsi:	res	1,(ix)			; in CSI reset flags
	cp	'['			; is a CSI: ESC+[ ?
	jr	z,gocsi			; yes
	cp	'O'			; is a CSI: ESC+O ? (used by F1 ... F4)
	jr	nz,rxeximm		; WRONG sequence
gocsi:	;
	set	2,(ix)			; CSI ok
	jp	escnx			; wait for next chars
prcsq:	;
	ld	hl,asqbuf		; setup string
	ld	b,(hl)
	inc	b
	ld	(hl),b
posbf:	inc	hl
	djnz	posbf			; position in buffer
	ld	(hl),a			; write
	inc	hl
	ld	(hl),0			; terminate
	ld	de,asqbuf+1		; init search
	ld	hl,ansikeys
	ld	bc,nakeys
	call	tlook			; perform it
	jr	nz,rxeximm		; unknown seq
	;				; found in table, but we need
	ld	de,(alinks)		; to test for a partial match
	or	a			; diff from string head
	sbc	hl,de
	dec	l
	dec	l
	dec	l			; include head
	ld	a,(alnght)		; check for len
	sub	l
	jp	nz,escnx		; partial match, wait for more
	ld	a,(de)			; got it!
	cp	esc			; if ESC is a two byte seq
	jr	nz,rxexsb		; exit for single byte code
	set	3,(ix)			; flag a two byte retcode
	jr	rxeximm
rxexsb:	res	3,(ix)			; clear two-byters flag
	xor	a
	ld	(asqbuf),a
	inc	de
	ld	a,(de)			; return code
	jr	rxeximm
rxex0:
	pop	af
	jr	rxeximm
rxexesc:
	ld	a,esc
rxeximm:
	res	2,(ix)
	ld	ix,fifou0
	ld	d,a			; save A
	call	fstat			; queue status
	call	z,srxrsm		; if empty unlock rx
	ld	a,d			; restore char
	pop	hl
	pop	de
	pop	ix
	pop	bc
	ret

;;
;; Any lenght string compare
;;
;; DE, HL < strings addresses
;; BC < max lenght
;; > Z = 1 found
cpstr:	ld	a,(de)			; get char from str1
	inc	de			; index next and compare
	cpi
	ret	nz			; no match
	ret	po			; end of string
	jr	cpstr

;;
;; string table lookup
;;
;; DE < test string, HL < table, BC < # strings in table
;; > Z = 1 match, HL > in string match + 1
tstlp:	push	de			; saves
	push	bc
	ld	(alinks),hl		; current string start (incl. head)
	inc	hl
	inc	hl			; skip linked address
	ld	b,0
	ld	c,(hl)			; current string length
	ld	a,c
	ld	(alnght),a		; current string len
	inc	hl
	ld	a,(asqbuf)
	ld	c,a			; test string len
	call	cpstr			; do compare
	jr	z,match			; exit if found
	ld	hl,(alinks)
	ld	a,(alnght)		; reload current string len
	add	a,3
	ld	c,a
	add	hl,bc			; add length, address next
	pop	bc			; restore count
	pop	de			; restore test string
	dec	bc			; update string count
	;
tlook:	ld	a,b			; table search entry point
	or	c			; check count = 0
	jr	nz,tstlp		; search next if not
	inc	a			; not found z = 0
	ret
match:	pop	bc
	pop	de			; clear stack
	ret				; found !


asqbuf:	defb	0
asqstr:	defs	4
alinks:	defw	0
alnght:	defb	0

	endif


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


	if ansidrv			; ANSI driver for serial console
;;
;; TXCHAR print out the char in reg C
;; with full evaluation of kegacy escape sequences
;; translated into ANSI equivalents for serial console
;;
;; register clean: can be used as CP/M BIOS replacement
;;
txchar0:
	push	af
	push	bc
	push	de
	push	hl
	; force jump to register restore and exit in stack
	ld	hl,txcexit
	push	hl
	;
	ld	a,c
	ld	hl,tmpbyte
	bit	4,(hl)			; plain serial i/o ?
	jr	nz,txjp3		; yes. transmit as-is
	ld	hl,miobyte
	bit	7,(hl)			; alternate char processing ?
	ex	de,hl
	jr	nz,txcou2		; yes: do alternate
	cp	$20			; no: is less then 0x20 (space) ?
	jr	nc,txjp1		; no: go further
	add	a,a			; yes: is a special char
	ld	h,0
	ld	l,a
	ld	bc,txvec1
	add	hl,bc
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	jp	(hl)			; jump to TXVEC1 handler
txjp1:	ex	de,hl
	bit	6,(hl)			; auto ctrl chars ??
	jr	z,txjp2			; no
	cp	$40			; yes: convert
	jr	c,txjp2
	cp	$60
	jr	nc,txjp2
	sub	$40
	jr	txjp3
txjp2:	cp	$c0			; is semigraphic ?
	jr	c,txjp3			; no
	sub	$c0			; to table offset
	ld	h,0
	ld	l,a
	ld	bc,eqcp437
	add	hl,bc
	ld	c,(hl)
txjp3:	call	dotxchar		; display char
	ret
txcou2:					; alternate processing....
	cp	$20			; is a ctrl char ??
	jr	nc,acradr		; no: will set cursor pos
	add	a,a			; yes
	ld	h,0
	ld	l,a
	ld	bc,txvec2
	add	hl,bc
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	jp	(hl)			; jump to service routine... (TXVEC2)
;; cursor addressing service routine
;; address is ESC + (COL # + 32) + (ROW # + 32) (then need a NUL to terminate...)
;; will be: CSI (ESC,[) + row + ';' + col + 'H'
acradr:	ld	hl,tmpbyte
	bit	0,(hl)
	jr	nz,rowset
	cp	$70			; greater then 80 ?
	ret	nc			; yes: error
	sub	$1f			; no: ok
	ld	(appbuf),a		; store column
	set	0,(hl)			; switch row/col flag
	ret
rowset:	cp	$39			; greater than 24 ?
	ret	nc			; yes: error
	sub	$1f			; no: ok
	res	0,(hl)			; resets flags
	ld	hl,miobyte
	res	7,(hl)			; done reset
	ld	d,a			; load row
	ld	e,';'
	call	seqemit			; and send
	ld	a,(appbuf)		; load column
	ld	d,a
	ld	e,'H'
	call	seqpar			; and send
	pop	hl			; clean stack
txcexit:
	pop	hl
	pop	de
	pop	bc
	pop	af
	ret

csiemit:
	ld	b,2
	ld	hl,csi
csich:	ld	c,(hl)
	call	dotxchar
	inc	hl
	djnz	csich
	ret

seqemit:
	call	csiemit			; send CSI
seqpar:	ld	a,d			; sequence parameter in D
	cp	$ff			; null, skip it
	jr	z,seqcmd
	or	a			; zero ?
	jr	z,seqzer
	ld	b,a			; convert to BCD
	xor	a
sqdaa:	inc	a
	daa
	djnz	sqdaa
	ld	d,a
	and	$f0			; hi nibble
	srl	a
	srl	a
	srl	a
	srl	a
	add	a,'0'
	call	seqchr			; send over
	ld	a,d			; reload parameter
	and	$0f			; lo nibble
seqzer:	add	a,'0'
	call	seqchr
seqcmd:	ld	a,e			; sequence command in E
	cp	$ff			; null, skip it
	jr	z,seqend
	jr	seqchr			; ...and send this too
seqend:	ret

seqchr:	ld	c,a			; send
	call	dotxchar
	ret

csi:	defb	esc,'['


;; This table define the offsets to jump to translation routines
;; for primary (non-escaped) mode

txvec1:
	dw	riocesc			; NUL 0x00 (^@)  clear alternate output processing
	dw	ucasemod		; SOH 0x01 (^A)  uppercase mode
	dw	lcasemod		; STX 0x02 (^B)  normal case mode
	dw	txnull			; ETX 0x00 (^C)  no-op
	dw	acurof			; EOT 0x04 (^D)  cursor off
	dw	acuron			; ENQ 0x05 (^E)  cursor on
	dw	txnull			; ACK 0x06 (^F)  locate cursor at CURPBUF
	dw	txbel			; BEL 0x07 (^G)  beep
	dw	amvlft			; BS  0x08 (^H)  cursor left (destr. and non destr.)
	dw	txnull			; HT  0x09 (^I)  no-op
	dw	txlf			; LF  0x0a (^J)  cursor down one line
	dw	achome			; VT  0x0b (^K)  cursor @ column 0
	dw	acls			; FF  0x0c (^L)  page down (clear screen)
	dw	txcr			; CR  0x0d (^M)  provess CR
	dw	acleop			; SO  0x0e (^N)  clear to EOP
	dw	acleol			; SI  0x0f (^O)  clear to EOL
	dw	txnull			; DLE 0x10 (^P)  no-op
	dw	aresatr			; DC1 0x11 (^Q)  reset all attributes
	dw	txnull			; DC2 0x12 (^R)  hard crt reset and clear
	dw	txnull			; DC3 0x13 (^S)  no-op
	dw	txnull			; DC4 0x14 (^T)  no-op
	dw	amvup			; NAK 0x15 (^U)  cursor up one line
	dw	txnull			; SYN 0x16 (^V)  scroll off
	dw	txnull			; ETB 0x17 (^W)  scroll on
	dw	amvlftnd		; CAN 0x18 (^X)  cursor left (non destr. only)
	dw	amvrgt			; EM  0x19 (^Y)  cursor right
	dw	amvdwn			; SUB 0x1a (^Z)  cursor down one line
	dw	siocesc			; ESC 0x1b (^[)  activate alternate output processing
	dw	txnull			; FS  0x1c (^\)  no-op
	dw	txnull			; GS  0x1d (^])  no-op
	dw	txnull			; RS  0x1e (^^)  disabled (no-op)
	dw	txnull			; US  0x1f (^_)  no-op

;; This table define the offsets to jump to translation routines
;; for alternate (escaped) mode

txvec2:
	dw	riocesc			; NUL 0x00 (^@)  clear alternate output processing
	dw	ablnkof			; SOH 0x01 (^A)  BLINK OFF
	dw	ablnkon			; STX 0x02 (^B)  BLINK ON
	dw	aundrof			; ETX 0x03 (^C)  UNDER OFF
	dw	aundron			; EOT 0x04 (^D)  UNDER ON
	dw	ahlitof			; ENQ 0x05 (^E)  HLIGHT OFF
	dw	ahliton			; ACK 0x06 (^F)  HLIGHT ON
	dw	txnull			; BEL 0x07 (^G)  no-op
	dw	txnull			; BS  0x08 (^H)  no-op
	dw	txnull			; HT  0x09 (^I)  no-op
	dw	txnull			; LF  0x0a (^J)  no-op
	dw	txnull			; VT  0x0b (^K)  no-op
	dw	acls			; FF  0x0c (^L)  blank screen
	dw	riocesc			; CR  0x0d (^M)  clear alternate output processing
	dw	aredon			; SO  0x0e (^N)  set bit 5 RAM3BUF (red)
	dw	awhton			; SI  0x0f (^O)  res bit 5 RAM3BUF (red)
	dw	agrnon			; DLE 0x10 (^P)  set bit 6 RAM3BUF (green)
	dw	awhton			; DC1 0x11 (^Q)  res bit 6 RAM3BUF (green)
	dw	txnull			; DC2 0x12 (^R)  cursor blink slow block
	dw	txnull			; DC3 0x13 (^S)  cursor blink slow line
	dw	txnull			; DC4 0x14 (^T)  no-op
	dw	txnull			; NAK 0x15 (^U)  no-op
	dw	txnull			; SYN 0x16 (^V)  no-op
	dw	sascfltr		; ETB 0x17 (^W)  set ascii filter
	dw	rascfltr		; CAN 0x18 (^X)  reset ascii filter
	dw	ndbksp			; EM  0x19 (^Y)  set non destructive BS
	dw	dbksp			; SUB 0x1a (^Z)  set destructive BS
	dw	arevson			; ESC 0x1b (^[)  REVERSE ON
	dw	arevsof			; FS  0x1c (^\)  REVERSE OFF
	dw	abluon			; GS  0x1d (^])  set bit 7 RAM3BUF (blue)
	dw	awhton			; RS  0x1e (^^)  res bit 7 RAM3BUF (blue)
	dw	txnull			; US  0x1f (^_)  no-op

;;
;; ANSI ESCapes specific routines
;;
;; no comments on code below but it should be quite intuitive

txnull:
	ret

txcr:
	ld	c,cr
	jp	dotxchar

txlf:
	ld	c,lf
	jp	dotxchar

txbksp:
	ld	c,$08
	jp	dotxchar

txbel:
	ld	c,$07
	jp	dotxchar

amvlft:
	ld	hl,miobyte
	bit	4,(hl)
	jr	nz,amvlftnd
	jr	txbksp

acurof:					; CSI ?25l
	deseq	$ff,'?'
	call	seqemit
	deseq	25,'l'
	call	seqpar
	ret

acuron:					; CSI ?25h
	deseq	$ff,'?'
	call	seqemit
	deseq	25,'h'
	call	seqpar
	ret

amvlftnd:
	deseq	$ff,'D'			; CSI n D
	jr	dosnd1

amvdwn:
	deseq	$ff,'B'			; CSI n B
	jr	dosnd1

amvup:
	deseq	$ff,'A'			; CSI n A
	jr	dosnd1

amvrgt:
	deseq	$ff,'C'			; CSI n C
	jr	dosnd1

achome:					; CSI 0 G
	deseq	0,'G'
	jr	dosnd1

acls:					; CSI 2 J
	deseq	2,'J'
	call	seqemit
	deseq	$ff,'H'
	jr	dosnd1

acleop:					; CSI 0 J
	deseq	0,'J'
	jr	dosnd1

acleol:					; CSI 0 K
	deseq	0,'K'
	jr	dosnd1

aresatr:				; CSI 0 m
	deseq	0,'m'
	jr	dosnd1

ablnkof:				; CSI 25 m
	deseq	25,'m'
	jr	dosnd1

ablnkon:				; CSI 5 m
	deseq	5,'m'
	jr	dosnd1

arevsof:				; CSI 27 m
	deseq	27,'m'
	jr	dosnd1

arevson:				; CSI 7 m
	deseq	7,'m'
	jr	dosnd1


aundrof:				; CSI 24 m
	deseq	24,'m'
	jr	dosnd1

aundron:				; CSI 4 m
	deseq	4,'m'
	jr	dosnd1

ahlitof:				; CSI 22 m
	deseq	22,'m'
	jr	dosnd1

ahliton:				; CSI 1 m
	deseq	1,'m'
	jr	dosnd1

aredon:					; CSI 31 m
	deseq	31,'m'
	jr	dosnd1

agrnon:					; CSI 32 m
	deseq	32,'m'
	jr	dosnd1

abluon:					; CSI 34 m
	deseq	34,'m'
	jr	dosnd1

awhton:					; CSI 37 m
	deseq	37,'m'
	jr	dosnd1

dosnd1:	call	seqemit
	ret

; keyboard translation table

nakeys	equ	22

		; sequences emitted upon reception of valid
		; keyboard input and valid sequences expected
ansikeys:	; on keyboard input
	defb	$00,$7f		; DEL
	defb	2,"3~"
	defb	$00,$16		; INS
	defb	2,"2~"
	defb	$00,$1d		; HOME
	defb	1,"H"
	defb	$00,$14		; END
	defb	1,"F"
	defb	$00,$13		; PGUP
	defb	2,"5~"
	defb	$00,$07		; PGDN
	defb	2,"6~"
	defb	$00,$15		; UP
	defb	1,"A"
	defb	$00,$1a		; DOWN
	defb	1,"B"
	defb	$00,$18		; LEFT
	defb	1,"D"
	defb	$00,$19		; RIGHT
	defb	1,"C"
	defb	$1b,'A'		; F1 ...
	defb	1,"P"
	defb	$1b,'B'
	defb	1,"Q"
	defb	$1b,'C'
	defb	1,"R"
	defb	$1b,'D'
	defb	1,"S"
	defb	$1b,'E'
	defb	3,"15~"
	defb	$1b,'F'
	defb	3,"17~"
	defb	$1b,'G'
	defb	3,"18~"
	defb	$1b,'H'
	defb	3,"19~"
	defb	$1b,'I'
	defb	3,"20~"
	defb	$1b,'J'
	defb	3,"21~"
	defb	$1b,'K'
	defb	3,"23~"
	defb	$1b,'L'		; ... F12
	defb	3,"24~"

	; This table definex (possible) equivalence from NEZ80 character ROMs
	; and Code Page 437.
	; Note that final rendering on remote is really dependent from ITS font usage
	; 1) we consider only chars from $C0 to $FF
	; 2) no equivalents from $81 to $BF

eqcp437:
	defb	179,196,197,195,180,194,193,192,217,218,191,186,205,206,204,185
	defb	203,202,200,188,201,187,198,181,210,208,214,183,211,189,213,184
	defb	212,190,199,182,209,207,215,216,025,026,006,003,004,005,156,157
	defb	178,176,224,225,046,235,231,046,239,046,046,237,228,046,234,227


	endif

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
					; form the UART will route it to the CPU
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
	call	ctcunlck
	ld	a,00000011b		; 7 6 5 4 3 2 1 0
					;               +---- 1 = command flag
					;             +------ 1 = channel reset
					; +------------------ 0 = n/a
	out	(ctcchan0),a
	out	(ctcchan1),a
	out	(ctcchan2),a
	out	(ctcchan3),a
	ret
; -----------

suart:	defb	0

; -----------

