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

	CSEG

	; setup dma bank
ADJBNK	macro
	IF BANKED
	CALL	BNKST			; select bank for disk i/o
	ENDIF
	endm

RESBNK	macro
	IF BANKED
	CALL	BNKRS			; reselect old bank
	ENDIF
	endm


	IF BANKED
BNKST:
	LD	A,(@CBNK)
	LD	(BKSAVE),A
	LD	A,(@DBNK)
	CALL	?BANK			; really select bank for disk i/o
	RET

BNKRS:
	PUSH	BC
	LD	B,A			; save return status
	LD	A,(BKSAVE)
	CALL	?BANK			; really reselect old bank
	LD	A,B
	POP	BC
	RET
	ENDIF


	; not all in common segment...
	IF BANKED
	DSEG
	ENDIF
;-------------------------------------------------------

FDDVOID:
HDVOID:					; void routine
	RET

	; login floppies
FDDLOG:
	PUSH	HL
	PUSH	DE
	LD	HL,(FLSECS)
	LD	DE,(FLSECS+2)
	CALL	BBDPRMSET
	POP	DE
	POP	HL
	RET

	; login virtual hd
HDVLOG:
	PUSH	HL
	PUSH	DE
	LD	HL,(HDSECS)
	LD	DE,(HDSECS+2)
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
	JP	RDFLO
WRFLO0:
	CALL	CHKSID			; side select
	JP	WRFLO

	CSEG
;-------------------------------------------------------

RDVRT:
	ADJBNK				; dma bank in place
	CALL	BBRDVDSK		; call par. read
	RESBNK				; restore bank
	JP	VDRET
	;
RDFLO:
	ADJBNK				; dma bank in place
	CALL	BBFDRVSEL		; activate driver
	CALL	BBFREAD			; do read
	RESBNK				; restore bank
	JP	FDRET
	;
WRVRT:
	ADJBNK				; dma bank in place
	CALL	BBWRVDSK		; call par. write
	RESBNK
	JP	VDRET
	;
WRFLO:
	ADJBNK				; dma bank in place
	CALL	BBFDRVSEL		; activate drive
	CALL	BBFWRITE		; do write
	RESBNK				; restore bank
	JP	VDRET
	;
DOHRDVD:
	ADJBNK				; dma bank in place
	CALL	BBRDVDSK
	RESBNK
	JP	VDRET

DOHWRVD:
	ADJBNK				; dma bank in place
	CALL	BBWRVDSK
	RESBNK
	JP	VDRET

DOIDERD:
	ADJBNK				; dma bank in place
	CALL	BBHDRD
	RESBNK
	JP	IDERET

DOIDEWR:
	ADJBNK				; dma bank in place
	CALL	BBHDWR
	RESBNK
	JP	IDERET

BKSAVE	DEFB	0			; must stay in common

	IF BANKED
	DSEG
	ENDIF
;-------------------------------------------------------
VDRET:
	POP	IX
	RET

	; adjust return value for floppies
FDRET:
	POP	IX
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
