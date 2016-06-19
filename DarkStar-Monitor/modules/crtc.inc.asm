;
;=======================================================================
;
; Modular Z80 DarkStar (NE Z80) Monitor
;
;=======================================================================
;
; CRTC
; SY6545A-1 and PIOs for video ram access on LX529
; ---------------------------------------------------------------------

;; 6545 initialization string
CRTTAB1:
	DB	111		; VR0 Tot h chars -1
	DB	80		; VR1 Disp h chars	
	DB	87		; VR2 HSync pos
	DB	$28		; VR3 Sync width
	DB	26		; VR4 Tot rows -1
	DB	0		; VR5 VAdj
	DB	25		; VR6 Disp rows -1
	DB	25		; VR7 VSync pos
	DB	01001000b	; VR8 00 Non interl,
				;      0 binary addressing,
				;      1 transparent mem,
				;      0 display no delay,
				;      0 cursor no delay
				;      1 pin34 strobe
				;      0 upd in blanking
	DB	11		; VR9 Character scan lines
	DB	0		; VR10 Curs start (and no blink)
	DB	11		; VR11 Curs end
	DB	0,0		; VR12/13 Display start
	DB	0,0		; VR14/15 Cursor position
	DB	0,0		; VR16/17 LPEN position
	DB	0,0		; VR18/19 Update position
;;
;; CRTCINI - init buffers,6545,test vram,clear,leave cursor at home
;;
CRTCINI:
	CALL	INICRT
	CALL	DBLANK
	CALL	GIOINI			; init remaing hardware on the board
	LD	A,$FF
	LD	(RAM3BUF),A
	LD	HL,$0000
	LD	(CURPBUF),HL
	JR	CRSLOC

;;
;; INICRT
;
INICRT:
					; initialize PIOs
	LD	A,$8F			; 10-00-1111 mode ctrl word
					; Mode 2 (I/O port A)
	OUT	(CRTRAM0CNT),A
	OUT	(CRTRAM1CNT),A
	OUT	(CRTRAM2CNT),A
	CALL	INI6545			; init 6545
	JP	CRTPRGEND		; go on...


;;
;; INI6545 - initialize sy6545
;;
INI6545:
	LD	HL,CRTTAB1	; now read from eprom
	LD	B,$00
	LD	A,B
ICTLP0:	OUT    (CRT6545ADST),A
	LD	A,(HL)
	OUT	(CRT6545DATA),A
	INC	HL
	INC	B
	LD	A,B
	CP	$14
	JR	NZ,ICTLP0
	LD	HL,$0000
	LD	(CURPBUF),HL
	CALL	SDPYSTA
; 	JP	CRSLOC

;	fall through...

;;
;; CRSLOC - init CRT cursor at CURPBUF
;
CRSLOC:
	LD	HL,(CURPBUF)
	CALL	SCRSPOS
	XOR	A
	LD	(COLBUF),A		; save cursor position
	RET


;;
;; GET DISPLAY CURSOR POSITION and return in HL
;
GCRSPOS:
	LD	A,VR14.CURPOSH
	OUT	(CRT6545ADST),A
	IN	A,(CRT6545DATA)
	LD	H,A
	LD	A,VR15.CURPOSL
	OUT	(CRT6545ADST),A
	IN	A,(CRT6545DATA)
	LD	L,A
	INC	HL
	JR	CRTPRGEND

;;
;; SET DISPLAY START ADDRESS
;
SDPYSTA:
	LD	A,VR12.DSTARTH
	OUT	(CRT6545ADST),A
	LD	A,H
	OUT	(CRT6545DATA),A
	LD	A,VR13.DSTARTL
	OUT	(CRT6545ADST),A
	LD	A,L
	OUT	(CRT6545DATA),A
	JR	CRTPRGEND


;;
;; DISMVC display char and move cursor
;
DISMVC:
	CALL	DISPCH
; 	JP	SCRSPOS

	; fall through...
;;
;; SET DISPLAY CURSOR ADDRESS EXTENDED
;;
SCRSPOS:
	LD	A,VR14.CURPOSH
	OUT	(CRT6545ADST),A
	LD	A,H
	OUT	(CRT6545DATA),A
	LD	A,VR15.CURPOSL
	OUT	(CRT6545ADST),A
	LD	A,L
	OUT	(CRT6545DATA),A
SCRSPOS1:
	LD	A,VR18.UPDADDRH
	OUT	(CRT6545ADST),A
	LD	A,H
	OUT	(CRT6545DATA),A
	LD	A,VR19.UPDADDRL
	OUT	(CRT6545ADST),A
	LD	A,L
	OUT	(CRT6545DATA),A
	JR	CRTPRGEND

;;
;; DBLANK
;; fill video ram (2k) with 0's
;
DBLANK:
	LD	HL,$0000
	LD	(RAM0BUF),HL
	XOR	A
	LD	(RAM2BUF),A
;;
;; CRTFILL - Fill video ram with ram buffer chrs
;
CRTFILL:
	LD	A,$EF
	LD	(RAM3BUF),A
	LD	HL,$0000
	LD	(CURPBUF),HL
	CALL	RSTDPY
CFIL1:	PUSH	HL
	CALL	DISPGR
	POP	HL
	INC	HL
	LD	A,H
	CP	$08
	JR	NZ,CFIL1
	JR	RSTDPY

;;
;; RSTDPY - zeroes SY6545 higher register (R12 to R19)
;;
RSTDPY:
	LD	B,$08
RDPY1:	LD	A,B
	ADD	A,$0B
	OUT	(CRT6545ADST),A
	XOR	A
	OUT	(CRT6545DATA),A
	DJNZ	RDPY1
; 	JP	CRTPRGEND

	; fall through...

;;
;; CRTPRGEND
;; resets 6545 register pointer
;
CRTPRGEND:
	LD	A,$1F
	OUT	(CRT6545ADST),A
	RET

;;
;; DISPGR - display in graphic mode (raw output)
;
DISPGR:
	IN	A,(CRT6545ADST)
	BIT	7,A
	JR	Z,DISPGR
	LD	HL,RAM0BUF
	LD	A,(HL)
	OUT	(CRTRAM0DAT),A
	INC	HL
	LD	A,(HL)
	OUT	(CRTRAM1DAT),A
	INC	HL
	LD	A,(HL)
	OUT	(CRTRAM2DAT),A
	LD	A,(RAM3BUF)
	OUT	(CRTRAM3PORT),A
	XOR	A
	OUT	(CRT6545DATA),A
	RET

;;
;; DISPCH - Display in text mode (raw output)
;;
DISPCH:
	PUSH	AF
DGCLP0:	IN	A,(CRT6545ADST)
	BIT	7,A
	JR	Z,DGCLP0
	POP	AF
	OUT	(CRTRAM0DAT),A
	LD	A,(RAM3BUF)
	OUT	(CRTRAM3PORT),A
	XOR	A
	OUT	(CRT6545DATA),A
	RET


;;
;; BCONOUT print out the char in reg C
;; with full evaluation of control chars
;;
;; register clean: can be used as CP/M BIOS replacement
;;
BCONOUT:
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	; force jump to register restore and exit in stack
	LD	HL,BCEXIT
	PUSH	HL
	;
	LD	A,C
	LD	HL,MIOBYTE
	BIT	7,(HL)			; alternate char processing ?
	EX	DE,HL
	JR	NZ,CONOU2		; yes: do alternate
	CP	$20			; no: is less then 0x20 (space) ?
	JR	NC,COJP1		; no: go further
	ADD	A,A			; yes: is a special char
	LD	H,0
	LD	L,A
	LD	BC,IOCVEC
	ADD	HL,BC
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	JP	(HL)			; jump to IOCVEC handler
COJP1:	EX	DE,HL
	BIT	6,(HL)			; auto ctrl chars ??
	JR	Z,COJP2			; no
	CP	$40			; yes: convert
	JR	C,COJP2
	CP	$60
	JR	NC,COJP2
	SUB	$40
COJP2:	CALL	DISPCH			; display char
	; move cursor right
MOVRGT:
	CALL	GCRSPOS			; update cursor position
	CALL	SCRSPOS
	LD	A,(COLBUF)
	INC	A
	CP	$50
	JR	Z,LFEED			; go down if needed
;;
SAVCOLB:
	LD	(COLBUF),A		; save cursor position
	RET
CONOU2:					; alternate processing....
	CP	$20			; is a ctrl char ??
	JR	NC,CURADR		; no: will set cursor pos
	ADD	A,A			; yes
	LD	H,0
	LD	L,A
	LD	BC,IOCVEC2
	ADD	HL,BC
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	JP	(HL)			; jump to service routine... (IOCVEC2)
;; cursor addressing service routine
;; address is ESC + (COL # + 32) + (ROW # + 32) (then need a NUL to terminate...)
CURADR:	LD	HL,TMPBYTE
	BIT	0,(HL)
	JR	NZ,SETROW
	CP	$70			; greater then 80 ?
	RET	NC			; yes: error
	SUB	$20			; no: ok
	LD	(APPBUF),A		; store column
	SET	0,(HL)			; switch row/col flag
	RET
SETROW:	RES	0,(HL)			; resets col/row flag
	CP	$39			; greater than 24 ?
	RET	NC			; yes: error
	SUB	$1F			; no: ok
	LD	HL,MIOBYTE		; resets ctrl char flag
	RES	7,(HL)			; done reset
	LD	B,A
	LD	HL,$FFB0
	LD	DE,$0050
CUROFS:	ADD	HL,DE			; calc. new offset
	DJNZ	CUROFS
	LD	A,(APPBUF)
	LD	(COLBUF),A
	LD	E,A
	ADD	HL,DE
	EX	DE,HL
	LD	HL,(CURPBUF)
	ADD	HL,DE
	JP	SCRSPOS			; update position
BCEXIT:
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET
;;
;; LFEED: down one line, scroll, home, clreol
;
LFEED:
	XOR	A
	LD	(COLBUF),A
LFEED1:	CALL	SCRTST
	RET	C
	LD	HL,MIOBYTE
	BIT	2,(HL)
	LD	DE,$F830
	CALL	GCRSPOS
	DEC	HL
	JR	Z,MDJMP0
	ADD	HL,DE
	JP	SCRSPOS
MDJMP0:	PUSH	HL
	CALL	CLRLIN
	LD	HL,(CURPBUF)
	LD	DE,$0050
	ADD	HL,DE
	LD	DE,$0820
	PUSH	HL
	SBC	HL,DE
	POP	HL
	JR	C,MDJMP1
	RES	3,H
MDJMP1:	LD	(CURPBUF),HL
	CALL	SDPYSTA
	POP	HL
	JR	C,MEJP
	RES	3,H
MEJP:	JP	SCRSPOS

;;
;; SCRTST - Verify if we need video scroll
;
SCRTST:
	LD	DE,(CURPBUF)
	XOR	A
	SBC	HL,DE
	LD	A,H
	CP	$07
	RET	C
	LD	A,L
	CP	$CF
	RET
;;
;; CLRSCR - clear screen (ASCII mode)
;
CLRSCR:
	LD	HL,$0000
	XOR	A
	LD	(COLBUF),A
	CPL
	LD	(RAM3BUF),A
	LD	(CURPBUF),HL
	CALL	SCRSPOS
	CALL	SDPYSTA
	PUSH	HL
CLSNC:	LD	A,$20
	CALL	DISPCH
	INC	HL
	LD	A,H
	CP	$08
	JR	NZ,CLSNC
	POP	HL
	JP	SCRSPOS

CURBLB:
	LD	L,$40           ; (0 10 00000) 1/16 blink scan 0
	JR	CURSETMODE
CURBLL:
	LD	L,$4A           ; (0 10 01010) 1/16 blink scan 10
	JR	CURSETMODE
CURBFB:
	LD	L,$60           ; (0 11 00000) 1/32 blink scan 0
	JR	CURSETMODE
CURBFL:
	LD	L,$6A           ; (0 11 01010) 1/32 blink scan 10
	JR	CURSETMODE
SCUROF:
	LD	L,$20           ; (0 01 00000) cursor off
	JR	CURSETMODE
CURFXB:
	LD	L,$00           ; (0 00 00000) fixed scan 0
	JR	CURSETMODE
SCURON:
; 	LD	L,$0A           ; (0 00 01010) cursor on
	JR	CURSET
CURSETMODE:
	PUSH	HL
	JR	CURSET1

;;
;; Setup cursor. (user mode)
;;
CURSET:
	PUSH	HL
	LD	A,(CURSSHP)
	LD	L,A
CURSET1:
	LD	A,VR10.CRSTART
	OUT	(CRT6545ADST),A
	LD	A,L
	OUT	(CRT6545DATA),A
	POP	HL
	JP	CRTPRGEND

;;
;; IOCNULL (a void routine) from here a list of routines to handle
;; console char output
;
IOCNULL:
	RET				; null entry. start of control routines vector
					; for primary (non-escaped) mode
;
UCASEMOD:
	EX	DE,HL
	SET	3,(HL)
	RET
LCASEMOD:
	EX	DE,HL
	RES	3,(HL)
	RET
;;
;; SNDBEEP - sound beep
SNDBEEP:
	OUT	(CRTBEEPPORT),A
	RET
;;
;; backspace
;;
BAKSPC:
	LD	HL,MIOBYTE
	LD	A,(HL)
	BIT	4,(HL)
	JR	NZ,MOVLFTDND		; set ND
	CALL	MOVLFTND		; destructive
	LD	A,' '
	CALL	DISPCH			; display char
	CALL	MOVRGT
	CALL	MOVLFTND
	RET

;;
;; cursor left, non destructive only
;;
MOVLFTND:
	LD	HL,MIOBYTE
	LD	A,(HL)
MLFTND:	PUSH	AF
	SET	4,(HL)
	CALL	MOVLFTDND
	POP	AF
	LD	(HL),A
	RET

;;
;; cursor left
;;
MOVLFTDND:
	CALL	GCRSPOS
	DEC	HL
	LD	DE,(CURPBUF)
	XOR	A
	SBC	HL,DE
	CP	H
	JR	NZ,MOVLFT1
	CP	L
	RET	Z
MOVLFT1:
	DEC	HL
	ADD	HL,DE
	CALL	SCRSPOS
	PUSH	HL
	LD	A,(COLBUF)
	DEC	A
	CP	$FF
	JR	NZ,MOVLFT2
	LD	A,$4F
MOVLFT2:
	LD	(COLBUF),A
	LD	HL,MIOBYTE
	BIT	4,(HL)
	POP	HL
	RET	NZ
	LD	A,$20
	JP	DISMVC
; 	JP	DISPCH
;;
;; CHOME - move cursor at col 0
;
CHOME:
	LD	HL,COLBUF
	LD	E,(HL)
	XOR	A
	LD	(HL),A
	LD	D,A
	CALL	GCRSPOS
	DEC	HL
	SBC	HL,DE
	CALL	SCRSPOS
	RET

;; IOCCR - handle carriage return (0x0d)
;; should position the cursor at col 0
;
IOCCR:
	EX	DE,HL
	BIT	3,(HL)
	JR	Z,IOCCR1
	CALL	CLREOL
IOCCR1:	JR	CHOME
;;
;; clear to end of page
;;
CLREOP:
	XOR	A
	LD	HL,(CURPBUF)
	LD	DE,$07D0
	ADD	HL,DE
	EX	DE,HL
	CALL	GCRSPOS
	DEC	HL
	EX	DE,HL
	SBC	HL,DE
	PUSH	HL
	POP	BC
CLRJ0:	CALL	CLRLIN1
	EX	DE,HL
	JP	SCRSPOS
;;
;; CLREOL - clear to end of line
;
CLREOL:
	LD	A,(COLBUF)
	LD	B,A
	LD	A,$50
	SUB	B
	LD	B,$00
	LD	C,A
	CALL	GCRSPOS
	DEC	HL
	EX	DE,HL
	JR	CLRJ0
;;
SCROLLOFF:
	EX	DE,HL
	SET	2,(HL)
	RET
SCROLLON:
	EX	DE,HL
	RES	2,(HL)
	RET
SIOCESC:
	EX	DE,HL
	SET	7,(HL)
	RET
;;
;; RESATTR - reset all attributes
;
RESATTR:
	LD	A,$FF
	LD	(RAM3BUF),A
	RET

;;
;; IOCNULL (a void routine) from here a list of routines to handle
;; console char output while in alternate processing (ESC prefixed ctrl chars)
;
MOVUP:
	CALL	GCRSPOS
	LD	DE,$FFAF
	ADD	HL,DE
	EX	DE,HL
	LD	HL,(CURPBUF)
	EX	DE,HL
	XOR	A
	SBC	HL,DE
	CPL
	CP	H
	ADD	HL,DE
	RET	Z
	JP	SCRSPOS
RASCFLTR:
	EX	DE,HL
	RES	6,(HL)
	RET
NDBKSP:
	EX	DE,HL
	SET	4,(HL)
	RET
DBKSP:
	EX	DE,HL
	RES	4,(HL)
	RET
BLINKOFF:
	LD	HL,RAM3BUF
	SET	0,(HL)
	RET
REVOFF:
	LD	HL,RAM3BUF
	SET	1,(HL)
	RET
UNDEROFF:
	LD	HL,RAM3BUF
	SET	2,(HL)
	RET
HLIGHTOFF:
	LD	HL,RAM3BUF
	SET	3,(HL)
	RET
REDON:
	LD	HL,RAM3BUF
	SET	5,(HL)
	RET
GREENON:
	LD	HL,RAM3BUF
	SET	6,(HL)
	RET
BLUEON:
	LD	HL,RAM3BUF
	SET	7,(HL)
	RET
BLINKON:
	LD	HL,RAM3BUF
	RES	0,(HL)
	RET
REVON:
	LD	HL,RAM3BUF
	RES	1,(HL)
	RET
UNDERON:
	LD	HL,RAM3BUF
	RES	2,(HL)
	RET
HLIGHTON:
	LD	HL,RAM3BUF
	RES	3,(HL)
	RET
REDOFF:
	LD	HL,RAM3BUF
	RES	5,(HL)
	RET
GREENOFF:
	LD	HL,RAM3BUF
	RES	6,(HL)
	RET
BLUEOFF:
	LD	HL,RAM3BUF
	RES	7,(HL)
	RET
;;
;; MOVDWN - cursor down one line
;
MOVDWN:
	CALL	GCRSPOS
	DEC	HL
	LD	DE,$0050
	ADD	HL,DE
	CALL	SCRSPOS
	JP	LFEED1
;;
RIOCESC:
	EX	DE,HL
	RES	7,(HL)
	RET
;
SASCFLTR:
	EX	DE,HL
	SET	6,(HL)
	RET

;;
;; CLRLIN - clear current line
;
CLRLIN:
	LD	BC,$0050
CLRLIN1:
	LD	A,(RAM3BUF)
	PUSH	AF
	LD	A,$FF
	LD	(RAM3BUF),A
CLRLP1:	LD	A,$20
	CALL	DISPCH
	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,CLRLP1
	POP	AF
	LD	(RAM3BUF),A
	RET

;; This table define the offsets to jump to control routines
;; for primary (non-escaped) mode

IOCVEC:
	DW	RIOCESC			; NUL 0x00 (^@)  clear alternate output processing
	DW	UCASEMOD		; SOH 0x01 (^A)  uppercase mode
	DW	LCASEMOD		; STX 0x02 (^B)  normal case mode
	DW	IOCNULL			; ETX 0x00 (^C)  no-op
	DW	SCUROF			; EOT 0x04 (^D)  cursor off
	DW	SCURON			; ENQ 0x05 (^E)  cursor on
	DW	CRSLOC			; ACK 0x06 (^F)  locate cursor at CURPBUF
	DW	SNDBEEP			; BEL 0x07 (^G)  beep
	DW	BAKSPC			; BS  0x08 (^H)  cursor left (destr. and non destr.)
	DW	IOCNULL			; HT  0x09 (^I)  no-op
	DW	MOVDWN			; LF  0x0a (^J)  cursor down one line
	DW	CHOME			; VT  0x0b (^K)  cursor @ column 0
	DW	CLRSCR			; FF  0x0c (^L)  page down (clear screen)
	DW	IOCCR			; CR  0x0d (^M)  provess CR
	DW	CLREOP			; SO  0x0e (^N)  clear to EOP
	DW	CLREOL			; SI  0x0f (^O)  clear to EOL
	DW	IOCNULL			; DLE 0x10 (^P)  no-op
	DW	RESATTR			; DC1 0x11 (^Q)  reset all attributes
	DW	CRTCINI			; DC2 0x12 (^R)  hard crt reset and clear
	DW	IOCNULL			; DC3 0x13 (^S)  no-op
	DW	IOCNULL			; DC4 0x14 (^T)  no-op
	DW	MOVUP			; NAK 0x15 (^U)  cursor up one line
	DW	SCROLLOFF		; SYN 0x16 (^V)  scroll off
	DW	SCROLLON		; ETB 0x17 (^W)  scroll on
	DW	MOVLFTND		; CAN 0x18 (^X)  cursor left (non destr. only)
	DW	MOVRGT			; EM  0x19 (^Y)  cursor right
	DW	MOVDWN			; SUB 0x1a (^Z)  cursor down one line
	DW	SIOCESC			; ESC 0x1b (^[)  activate alternate output processing
	DW	IOCNULL			; FS  0x1c (^\)  no-op
	DW	IOCNULL			; GS  0x1d (^])  no-op
	DW	IOCNULL			; RS  0x1e (^^)  disabled (no-op)
	DW	IOCNULL			; US  0x1f (^_)  no-op

;; This table define the offsets to jump to control routines
;; for alternate (escaped) mode

IOCVEC2:
	DW	RIOCESC			; NUL 0x00 (^@)  clear alternate output processing
	DW	BLINKOFF		; SOH 0x01 (^A)  BLINK OFF
	DW	BLINKON			; STX 0x02 (^B)  BLINK ON
	DW	UNDEROFF		; ETX 0x03 (^C)  UNDER OFF
	DW	UNDERON			; EOT 0x04 (^D)  UNDER ON
	DW	HLIGHTOFF		; ENQ 0x05 (^E)  HLIGHT OFF
	DW	HLIGHTON		; ACK 0x06 (^F)  HLIGHT ON
	DW	IOCNULL			; BEL 0x07 (^G)  no-op
	DW	IOCNULL			; BS  0x08 (^H)  no-op
	DW	IOCNULL			; HT  0x09 (^I)  no-op
	DW	IOCNULL			; LF  0x0a (^J)  no-op
	DW	IOCNULL			; VT  0x0b (^K)  no-op
	DW	DBLANK			; FF  0x0c (^L)  blank screen
	DW	RIOCESC			; CR  0x0d (^M)  clear alternate output processing
	DW	REDON			; SO  0x0e (^N)  set bit 5 RAM3BUF (red)
	DW	REDOFF			; SI  0x0f (^O)  res bit 5 RAM3BUF (red)
	DW	GREENON			; DLE 0x10 (^P)  set bit 6 RAM3BUF (green)
	DW	GREENOFF		; DC1 0x11 (^Q)  res bit 6 RAM3BUF (green)
	DW	CURBLB			; DC2 0x12 (^R)  cursor blink slow block
	DW	CURBLL			; DC3 0x13 (^S)  cursor blink slow line
	DW	IOCNULL			; DC4 0x14 (^T)  no-op
	DW	IOCNULL			; NAK 0x15 (^U)  no-op
	DW	IOCNULL			; SYN 0x16 (^V)  no-op
	DW	SASCFLTR		; ETB 0x17 (^W)  set ascii filter
	DW	RASCFLTR		; CAN 0x18 (^X)  reset ascii filter
	DW	NDBKSP			; EM  0x19 (^Y)  set non destructive BS
	DW	DBKSP			; SUB 0x1a (^Z)  set destructive BS
	DW	REVON			; ESC 0x1b (^[)  REVERSE ON
	DW	REVOFF			; FS  0x1c (^\)  REVERSE OFF
	DW	BLUEON			; GS  0x1d (^])  set bit 7 RAM3BUF (blue)
	DW	BLUEOFF			; RS  0x1e (^^)  res bit 7 RAM3BUF (blue)
	DW	IOCNULL			; US  0x1f (^_)  no-op

