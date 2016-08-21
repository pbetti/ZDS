;
;=======================================================================
;
; CP/M 3 Z80 DarkStar (NE Z80) Porting
;
;=======================================================================
;;---------------------------------------------------------------------
;; Version      : 1.0 - 20140904
;; Assemble     : SLR z80asm
;; Revisions:
;; 20140915	- Code start
;;---------------------------------------------------------------------

	TITLE	'MEDIA MODULE FOR CP/M 3.1'

	.Z80

	; define logical values:
	include	common.inc
	include syshw.inc

LDRDBG	EQU	false

	; define public labels:
	PUBLIC	HDVOID, FDDVOID
	PUBLIC	HRDVDSK, HWRVDSK, HDVLOG
	PUBLIC	IDERDDSK, IDEWRDSK, IDELOGIN
	PUBLIC	FDDRD, FDDWR, FDDLOG

	EXTRN	@BIOS$STACK
	IF BANKED
	EXTRN	@CBNK, @DBNK, ?BANK
	ENDIF

HEX16	macro	p1,p2
	if	LDRDBG
	ld	(OLDSTACK),SP
	ld	sp,NEWSTACK
	push	af
	push	bc
	push	de
	push	hl
	ld	a,p1
	call	phex
	ld	a,p2
	call	phex
	ld	c,CR
	call	BBCONOUT
	ld	c,LF
	call	BBCONOUT
	pop	hl
	pop	de
	pop	bc
	pop	af
	ld	sp,(OLDSTACK)
	endif
	endm

HEX8	macro	p1
	if	LDRDBG
	ld	(OLDSTACK),SP
	ld	sp,NEWSTACK
	push	af
	push	bc
	push	de
	push	hl
	ld	a,p1
	call	phex
	ld	c,CR
	call	BBCONOUT
	ld	c,LF
	call	BBCONOUT
	pop	hl
	pop	de
	pop	bc
	pop	af
	ld	sp,(OLDSTACK)
	endif
	endm



	; not all in common segment...
;-------------------------------------------------------
; possibly banked routines (entry points)
;-------------------------------------------------------

	IF BANKED
	DSEG
	ENDIF

FDDVOID:
HDVOID:					; void routine
	RET

	; login floppies
FDDLOG:
	PUSH	HL
	PUSH	DE
	LD	HL,(FLSECS)
	LD	DE,(FLSECS+2)
	JR	HDVLO0
	
	; login virtual hd
HDVLOG:
	PUSH	HL
	PUSH	DE
	LD	HL,(HDSECS)
	LD	DE,(HDSECS+2)
HDVLO0:
	CALL	BBDPRMSET
	POP	DE
	POP	HL
	RET

	; wrapper for virtual hd read routine
HRDVDSK:
	PUSH	IX
	CALL	HDVLOG			; hd params
	JP	DOHRDVD

	; wrapper for virtual hd write routine
HWRVDSK:
	PUSH	IX
	CALL	HDVLOG			; hd params
	JP	DOHWRVD

	; wrapper for ide hd read routine
IDERDDSK:
	PUSH	IY
	JP	DOIDERD

	; wrapper for ide hd write routine
IDEWRDSK:
	PUSH	IY
	JP	DOIDEWR

	; ide login			; DISABLED
IDELOGIN:				; done once at boot
; 	LD	A,'3'
; 	LD	(COPSYS),A		; identify opsys for partitions
;
; 	CALL	BBHDINIT		; IDE init
; 	OR	A
; 	JP	NZ,IDEERR
; 	CALL	BBLDPART
	RET

	; floppy read routine
FDDRD:
	PUSH	IX
	CALL	FDDLOG
	LD	A,(FDRVBUF)		; get active drive
	CP	2			; is hw floppy ?
	JR	C,RDFLO0		; yes
	JP	RDVRT			; no, then is a virtual drive
	;
	; floppy write routine
FDDWR:
	PUSH	IX
	CALL	FDDLOG
	LD	A,(FDRVBUF)		; get active drive
	CP	2			; is floppy ?
	JR	C,WRFLO0		; yes
	JP	WRVRT			; no, then is a virtual drive

RDFLO0:
	CALL	CHKSID			; side select
	CALL	BBFDRVSEL		; activate drive
	JP	RDFLO
WRFLO0:
	CALL	CHKSID			; side select
	CALL	BBFDRVSEL		; activate drive
	JP	WRFLO

	;	test for side switch on floppies
	;
CHKSID:	LD	IX,FLSECS		; CHS infos
	LD	C,0			; side 0 by default
	LD	A,(FTRKBUF)		; get just the 8 bit part because we don't
					; have drivers with more than 255 tracks !!!
	CP	(IX+5)			; compare with physical (8 bit)
	JP	C,BBSIDSET		; track in range (0-39/0-79) ?
	LD	C,1			; no: side one
	SUB	(IX+5)			; real cylinder on side 1
	LD	(FTRKBUF),A		; store for i/o ops
	JP	BBSIDSET		; ... and go to SETSID

FLSECS:	DEFW	11
	DEFW	512
	DEFB	2			; heads
	DEFW	80			; tracks
HDSECS:	DEFW	256
	DEFW	512

;-------------------------------------------------------
; possibly banked routines (re-entry from common seg)
;-------------------------------------------------------
VDRET:
	POP	IX
	RET

	; adjust return value for floppies
FDRET:
	POP	IX
	OR	A
	JR	Z,FDOK
	XOR	A
	INC	A
	RET
FDOK:	XOR	A
	RET

IDERET:
	POP	IY
	OR	A
	RET	Z
	LD	A,1			; correct return value for BDOS
	RET


;-------------------------------------------------------
; resident / non-banked part
;-------------------------------------------------------

	CSEG

	; setup dma bank
DMABNK	macro
	IF BANKED
	CALL	BNKSET			; select bank for disk i/o
	ENDIF
	endm

RSTBNK	macro
	IF BANKED
	CALL	BNKRST			; reselect old bank
	ENDIF
	endm


	IF BANKED
BNKSET:
	LD	A,(@CBNK)
	LD	(BKSAVE),A
	LD	A,(@DBNK)
	CALL	?BANK			; really select bank for disk i/o
	RET

BNKRST:
	PUSH	BC
	LD	B,A			; save return status
	LD	A,(BKSAVE)
	CALL	?BANK			; really reselect old bank
	LD	A,B
	POP	BC
	RET
; 	PUSH	AF
; 	LD	A,(BKSAVE)
; 	CALL	?BANK			; really reselect old bank
; 	POP	AF
; 	RET
	ENDIF

WRFLO:
	DMABNK				; dma bank in place
	CALL	BBFWRITE		; do write
	JR	RDFLO1
	;
RDFLO:
	DMABNK				; dma bank in place
	CALL	BBFREAD			; do read
RDFLO1:
	RSTBNK				; restore bank
	JP	FDRET
	;
WRVRT:
	DMABNK				; dma bank in place
	CALL	BBWRVDSK		; call par. write
	JR	TOVDRET
	;
RDVRT:
	DMABNK				; dma bank in place
	CALL	BBRDVDSK		; call par. read
	JR	TOVDRET
	;
DOHRDVD:
	DMABNK				; dma bank in place
	CALL	BBRDVDSK
	JR	TOVDRET
	
DOHWRVD:
	DMABNK				; dma bank in place
	CALL	BBWRVDSK
TOVDRET:
	RSTBNK
	JP	VDRET

DOIDERD:
	DMABNK				; dma bank in place
	CALL	BBHDRD
	JR	DOIDEW0

DOIDEWR:
	DMABNK				; dma bank in place
	CALL	BBHDWR
DOIDEW0:
	RSTBNK
	JP	IDERET

BKSAVE	DEFB	0			; must stay in common


;-------------------------------------------------------

	IF LDRDBG

PHEX:	PUSH	AF
	PUSH	BC
	PUSH	AF
	RRCA
	RRCA
	RRCA
	RRCA
	CALL	ZCONV
	POP	AF
	CALL	ZCONV
	POP	BC
	POP	AF
	RET
;
ZCONV:	AND	0FH		;HEX to ASCII and print it
	ADD	A,90H
	DAA
	ADC	A,40H
	DAA
	LD	C,A
	CALL	BBCONOUT
	RET
OLDSTACK:
	DEFW	0
	DEFS	40
NEWSTACK:
	DEFW	0

	ENDIF

	END
