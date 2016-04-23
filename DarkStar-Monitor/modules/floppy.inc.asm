;
;=======================================================================
;
; Modular Z80 DarkStar (NE Z80) Monitor
;
;=======================================================================
;
; Floppy I/O
; ---------------------------------------------------------------------
; ---------------------------------------------------------------------
; Revisions:
; 20150714 - Changed to have timeouts on floppy operations that could
;            produce system locks. (I.e. in absence of floppy in drive)
; ---------------------------------------------------------------------

;;
;; FDC delay
;
FDCDLY:
	EX	(SP),HL
	EX	(SP),HL
	EX	(SP),HL
	EX	(SP),HL
	RET

;;
;; waitfd - get 1771 status and copy on buffer
;
WAITFD:
	; wait until fdd busy is reset
	CALL	FDCDLY			; wait aproax 56 micros
	LD	B,5			; set soft timer
FWAIT00:
	LD	DE,0			; for ~ five seconds
FWAIT01:
	IN	A,(FDCCMDSTATR)		; input to fdd status
	BIT	0,A			; test busy bit
	JR	Z,FWAIT02		; jump if no command is in progress
	DEC	DE			;
	LD	A,D			; timer down
	OR	E			;
	JR	NZ,FWAIT01		;
	DEC	B			;
	JR	NZ,FWAIT00		; time out
FTIMEOUT:
	LD	A,FDCRESET		; reset fdd controller
	OUT	(FDCCMDSTATR),A		; exec. command
	XOR	A
	OUT	(FDCDRVRCNT),A
	INC	A			; set time-out bit error
	RET				; and ret
FWAIT02:
; 	XOR	A
	RET				; normal return
;
GCURTRK:
	LD	HL,FSEKBUF
	LD	A,(FDRVBUF)
	ADD	A,L
	LD	L,A
	RET
;;
;; FHOME - move head to trak 0 (cp/m home like)
;;
FHOME:
	PUSH	BC			; save register
	PUSH	DE
	LD	A,FDCRESTC		; fdd restore command
	OUT	(FDCCMDSTATR),A		; exec. command
	CALL	WAITFD			; wait until end command
	LD	C,A			; save status
	CALL	GCURTRK			; proceed
	IN	A,(FDCTRAKREG)
	LD	(HL),A
	LD	A,C			; restore status
	AND	00011001b		; set Z flag
	POP	DE
	POP	BC			; restore register
	RET

;;
;; FSEEK - seek to specific track/sector
;
FSEEK:
	PUSH	BC
	PUSH	DE
	LD	B,3			; retrys number
	CALL	GCURTRK
	LD	A,(HL)
	OUT	(FDCTRAKREG),A
FRETR1:	LD	A,(FSECBUF)
	OUT	(FDCSECTREG),A
	LD	A,(FTRKBUF)
	OUT	(FDCDATAREG),A
	LD	A,FDCSEEKC		; seek cmd
	OUT	(FDCCMDSTATR),A		; exec. command
	LD	C,B			; save retry count
	CALL	WAITFD
	LD	B,C			; restore retry count
	AND	00011001b
	JR	Z,FSKEND
	CALL	FHOME
	JR	NZ,FSKEND
	DJNZ	FRETR1
FSKEND:	IN	A,(FDCTRAKREG)
	LD	(HL),A
FTERR:	POP	DE
	POP	BC
	RET
;;
;; FREAD - read a sector
;
FREAD:
	LD	A,(MIOBYTE)
	SET	0,A
	JR	FLOPIO
;;
;; FWRITE - write a sector
;
FWRITE:
	LD	A,(MIOBYTE)
	RES	0,A
;;
;; FLOPIO - read or write a sector depending on MIOBYTE
;
FLOPIO:
	PUSH	DE
	LD	IX,CSPTR
	LD	(MIOBYTE),A
FRWLP:	CALL	FSEEK
	JR	NZ,FSHTM
	LD	B,$0A			; 10 retries
FRWNXT:	DI				; not interruptible
	LD	HL,(FRDPBUF)
	LD	E,(IX+2)		; need to know buffer size on write
	LD	D,(IX+3)
	LD	A,(MIOBYTE)
	BIT	0,A
	JR	Z,FRWWRO
	LD	A,FDCREADC		; read command
	OUT	(FDCCMDSTATR),A		; exec. command
	CALL	FDCDLY
	JR	FRRDY
FRBSY:	RRCA
	JR	NC,FWEND
FRRDY:	IN	A,(FDCCMDSTATR)
	BIT	1,A			; sec found
	JR	Z,FRBSY
	IN	A,(FDCDATAREG)
	LD	(HL),A
	INC	HL
	JR	FRRDY
FRWWRO:	LD	A,FDCWRITC
	OUT	(FDCCMDSTATR),A		; exec. command
	CALL	FDCDLY
	JR	FWRDY
FRWBSY:	RRCA
	JR	NC,FWEND
FWRDY:	IN	A,(FDCCMDSTATR)
	BIT	1,A
	JR	Z,FRWBSY
	LD	A,(HL)
	OUT	(FDCDATAREG),A
	INC	HL
	DEC	DE		; 6 c.
	LD	A,D		; 4 c.
	OR	E		; 4 c.
	JR	NZ,FWRDY	; 7/12 c.
FWEND:	EI				; end of critical operations
	LD	C,B			; save retry count
	CALL	WAITFD
	LD	B,C			; restore retry count
	AND	01011100b		; mask wrt-prtc,rnf,crc,lst-dat error
	JR	Z,FSHTM
	DJNZ	FRWNXT
	LD	A,(TMPBYTE)
	BIT	6,A
	JR	NZ,FSHTM
	SET	6,A
	LD	(TMPBYTE),A
	CALL	FHOME
	JR	NZ,FSHTM
	JR	FRWLP
FSHTM:
	PUSH	AF
	XOR	A
	OUT	(FDCDRVRCNT),A
	POP	AF
	POP	DE
	RET

;;
;; SIDSET - set current side bit on DSELBF
;;          selected side on C
;;
SIDSET:	LD	HL,DSELBF		; loads drive interf. buffer
	LD	A,C			; which side ?
	CP	0			;
	JR	NZ,SIDONE		; side 1
	RES	5,(HL)			; side 0
	RET				;
SIDONE:	SET	5,(HL)			;
	RET

