;
;=======================================================================
;
; Modular Z80 DarkStar (NE Z80) Monitor
;
;=======================================================================
;
; CRTC
; SY6545A-1 utils lib.
; Routines for additional 6545 (lx529) functionalities
; ---------------------------------------------------------------------

;;
;;
;; OUTSTR print a string using BBCONOUT
OUTSTR:
	PUSH	BC
OSLP0:	LD	C,(HL)
	LD	B,C
	RES	7,C
	CALL	BBCONOUT
	INC	HL
	LD	A,B
	RLCA
	JR	NC,OSLP0
	POP	BC
	RET


;;
;; DLIGHT
;; fill video ram (2k) with ff's
;
; DLIGHT:
; 	LD	HL,$FFFF        ; was 00FC16 21 FF FF
; 	LD	(RAM0BUF),HL
; 	LD	A,$FF
; 	LD	(RAM2BUF),A
; 	CALL	BBCRTFILL
; 	RET


;;
;; OUTCRLF - CR/LF through OUTSTR
;

OUTCRLF:
	PUSH	HL			; was 00FAB0 E5
OCRLF1:	LD	HL,CRLFTAB
	CALL	OUTSTR
	POP	HL
	RET

; ;;
; ;; CLRSCRGR - Clear screen graphic mode
; ;
; CLRSCRGR:
; 	CALL	SCUROF			; was 00F0E7 CD 7E F0
; 	LD	HL,$0020
; 	LD	(RAM0BUF),HL
; 	LD	HL,$FF00
; 	LD	(RAM2BUF),HL
; 	CALL	RSTDPY
; 	LD	HL,$0000
; CSGLP0:	LD	A,(RAM0BUF)
; 	CALL	DISPCH
; 	INC	HL
; 	LD	A,H
; 	CP	$07
; 	JR	NZ,CSGLP0
; 	LD	A,L
; 	CP	$80
; 	JR	NZ,CSGLP0
; 	CALL	RSTDPY
; 	JP	SCURON

; ;;
; ;; OUTGRBUF - set graphic mode, display RAM[012]BUF and revert to ascii
; ;;
; OUTGRBUF:
; 	CALL	GCRSPOS           ; was 00FF59 CD B0 F7
; 	DEC	HL
; 	LD	A,(RAM3BUF)
; 	PUSH	AF
; 	PUSH	HL
; 	RES	4,A
; 	LD	(RAM3BUF),A
; 	CALL	DISPGR
; 	POP	HL
; 	POP	AF
; 	LD	(RAM3BUF),A
; 	JP	SCRSPOS

; ;;
; ;; GETLPEN - manage light-pen operations
; ;;
; GETLPEN:
; 	PUSH	AF
; 	PUSH	DE
; 	IN	A,(CRT6545ADST)
; 	BIT	6,A			; got LPEN strobe ?
; 	RET	Z			; no
; 	LD	A,$10			; yes...
; 	OUT	(CRT6545ADST),A		; get LPEN position
; 	IN	A,(CRT6545DATA)
; 	LD	H,A
; 	LD	A,$11
; 	OUT	(CRT6545ADST),A
; 	IN	A,(CRT6545DATA)
; 	LD	L,A			; ...in HL
; 	CALL	SCRSPOS			; move cursor to LPEN pos
; 	EX	DE,HL
; 	LD	HL,(CURPBUF)
; 	EX	DE,HL
; 	XOR	A
; 	SBC	HL,DE
; 	LD	DE,$0050
; CIJP4:	XOR	A
; 	SBC	HL,DE
; 	JR	NC,CIJP4
; 	ADD	HL,DE
; 	LD	A,L
; 	LD	(COLBUF),A		;
; 	POP	DE
; 	POP	AF
; 	JP	CILOP			; re-enter normal char processing

; ;;
; ;; SGRMODE - set graphic mode on
; ;
; SGRMODE:
; 	IN	A,(CRT6545ADST)		; was 00FF40 DB 8C
; 	BIT	7,A
; 	JR	Z,SGRMODE
; 	IN	A,(CRTRAM3PORT)
; 	SET	4,A
; 	LD	(RAM3BUF),A
; 	IN	A,(CRTRAM0DAT)
; ; 	POP	HL
; ; 	POP	HL
; 	RET

; GRAPHOFF:
; 	LD	HL,RAM3BUF
; 	SET	4,(HL)
; 	RET
;
; GRAPHON:
; 	LD	HL,RAM3BUF
; 	RES	4,(HL)
; 	RET

CRLFTAB:
	DB	$0D,$8A
