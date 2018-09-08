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

; GRAPHOFF:
; 	LD	HL,RAM3BUF
; 	SET	4,(HL)
; 	RET
;
; GRAPHON:
; 	LD	HL,RAM3BUF
; 	RES	4,(HL)
; 	RET

