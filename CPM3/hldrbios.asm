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
;; 20140905	- Code start
;;---------------------------------------------------------------------


	TITLE	'CPMLDR BIOS FOR CP/M 3.1'

	.Z80

	; define logical values:
	include	common.inc
	include syshw.inc


;---------------------------------------- DBUG

LDRDBG	EQU	false

FTRACE	macro	p1
	if ldrdbg
	ld	(OLDSTACK),SP
	ld	sp,NEWSTACK
	push	af
	push	bc
	push	de
	push	hl
	call	inline
	defb	p1,cr,lf,'$'
	call	bbconin
	pop	hl
	pop	de
	pop	bc
	pop	af
	ld	sp,(OLDSTACK)
	endif
	endm

HEX16	macro	p1,p2
	if ldrdbg
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
	if ldrdbg
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

;---------------------------------------- DBUG


dph 	macro 	?trans,?dpb,?csize,?asize
	local ?csv,?alv
	dw	?trans			; translate table address
	db	0,0,0,0,0,0,0,0,0	; BDOS Scratch area
	db	0			; media flag
	dw	?dpb			; disk parameter block
	dw	csv			; checksum vector
	dw	alv			; allocation vector
	dw	dirbcb			; directory buffer control block
	dw	databcb			; data buffer control block
	dw	0ffffh			; no hashing
	db	0			; hash bank
	endm

	; Standard entry points

	JP	BOOT
	JP	WBOOT
	JP	CONST
	JP	CONIN
	JP	CONOUT
	JP	BLIST
	JP	AUXOUT
	JP	AUXIN
	JP	HOME
	JP	SELDSK
	JP	SETTRK
	JP	SETSEC
	JP	SETDMA
	JP	READ
	JP	WRITE
	JP	LISTST
	JP	SECTRN
	JP	CONOST
	JP	AUXIST
	JP	AUXOST
	JP	DEVTBL
	JP	?CINIT
	JP	GETDRV
	JP	MULTIO
	JP	FLUSH
	JP	?MOVE
	JP	?TIME
	JP	BNKSEL
	JP	SETBNK
	JP	?XMOVE
	JP	0
	JP	0
	JP	0


; 	; extended disk parameter header for drive 0:
	DEFW	FDDWR			; floppy disk write routine
	DEFW	FDDRD			; floppy disk read routine
	DEFW	VOID			; floppy disk login procedure
	DEFW	VOID			; floppy disk drive initialization routine (void)
	DEFB	0			; relative drive 0 on this controller
	DEFB	0			; media type

DPH0:	DPH	TRANS,FDPB,0,0

	; extended disk parameter header for drive 2:
	DEFW	IDEWRDSK		; hard disk write routine
	DEFW	IDERDDSK		; hard disk read routine
	DEFW	VOID			; hard disk login procedure
	DEFW	VOID			; hard disk drive initialization routine (void)
	DEFB	0			; relative drive 0 on this controller
	DEFB	0			; media type

DPH2:	DPH	0,HD8M,0,0

; 	; extended disk parameter header for drive 14:
	DEFW	FDDWR			; virt floppy disk write routine
	DEFW	FDDRD			; virt floppy disk read routine
	DEFW	VOID			; virt floppy disk login procedure
	DEFW	VOID			; virt floppy disk drive initialization routine (void)
	DEFB	0			; relative drive 0 on this controller
	DEFB	0			; media type

DPH14:	DPH	TRANS,FDPB,0,0

; extended disk parameter header for drive 15:
	DEFW	HWRVDSK			; virt hard disk write routine
	DEFW	HRDVDSK			; virt hard disk read routine
	DEFW	VOID			; virt hard disk login procedure
	DEFW	VOID			; virt hard disk drive initialization routine (void)
	DEFB	0			; relative drive 0 on this controller
	DEFB	0			; media type

DPH15:	DPH	0,HD8M,0,0

	; Floppy drive 0

FDPB:
	DEFW	44			; SPT
	DEFB	4,15			; BSH, BLM  --> 2048 BYTES BLOCK
	DEFB	0			; EXM
	DEFW	433			; DSM
	DEFW	255			; DRM
	DEFB	11110000B		; alloc 0
	DEFB	00000000B		; alloc 1
	;
	DEFW	64			; CKS
	;
	DEFW	2			; OFF
	DEFB	2,3			; PSH, PHM  --> 512 BYTES PHYSICAL SECTOR

	; IDE partition 1 is 512x256x64 LBA or 8.388.608 bytes
	; DPB	512,256,64,2048,1024,1,8000H

HD8M:
	DEFW	1024			; SPT
	DEFB	4,15			; BSH, BLM  --> 2048 BYTES BLOCK
	DEFB	0			; EXM
	DEFW	4031			; DSM
	DEFW	1023			; DRM
	DEFB	0FFH,0FFH		; AL0, AL1
	;
	DEFW	8000H			; CKS
	;
	DEFW	1			; OFF
	DEFB	2,3			; PSH, PHM  --> 512 BYTES PHYSICAL SECTOR

	; sector translation table for 512 bytes/11 sec. track (skew = 4)
TRANS:	DEFB	1,5,9,2 		; sectors 1,2,3,4
	DEFB	6,10,3,7	 	; sectors 5,6,7,8
	DEFB	11,4,8			; sectors 9,10,11

@DTBL:	DEFW	DPH0	; A:
	DEFW	DPH0	; B:
	DEFW	DPH2	; C:
	DEFW	DPH2	; D:
	DEFW	DPH2	; E:
	DEFW	DPH2	; F:
	DEFW	DPH2	; G:
	DEFW	DPH2	; H:
	DEFW	DPH2	; I:
	DEFW	DPH2	; J:
	DEFW	DPH2	; K:
	DEFW	DPH2	; L:
	DEFW	DPH2	; M:
	DEFW	DPH2	; N:
	DEFW	DPH14	; O:
	DEFW	DPH15	; P:


CONST:
LISTST:
AUXIST:
AUXOST:
FLUSH:
BLIST:
AUXOUT:
DEVTBL:
?CINIT:
MULTIO:
?TIME:
BNKSEL:
SETBNK:
?XMOVE:
DCBINIT:
WRITE:
WBOOT:
	XOR	A			; routine has no function in loader bios:
	RET				; return a false status


CONIN:
AUXIN:
	LD	A,'Z'-40H		; routine has no function in loader bios:
	RET

CONOUT:					; routine outputs a character in [c] to the console:
	JP	BBCONOUT

CONOST:					; return console output status:
	JP	BBCONST

?MOVE:
	hex16	d,e
	hex16	h,l
	hex16	b,c
	FTRACE "?MOVE"
	EX	DE,HL
	LDIR
	EX	DE,HL
	RET

SELDSK:	FTRACE "SELDSK"
	LD	A,(CDISK)
	LD	C,A
	LD	B,0
	hex8	c
	CALL	BBDSKSEL
	LD	L,A
	LD	H,0
	ADD	HL,HL			; create index from drive code
	LD	BC,@DTBL
	ADD	HL,BC			; get pointer to dispatch table
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A			; point at disk descriptor
	RET

HOME:	FTRACE "HOME"
	LD	BC,0			; home selected drive -- treat as settrk(0):

SETTRK:
	FTRACE "SETTRK"
	LD	(@TRK),BC
	hex16	b,c
	CALL	BBTRKSET
	RET

SETSEC:
	FTRACE "SETSEC"
	LD	A,(FDRVBUF)		; select...
	CP	2			; is floppy ?
	JP	M,SECIN			; yes
	CP	14			; is IDE ?
	JP	M,SECIN			; yes
	CP	15			; virtual hd ?
	JR	Z,SECADJ		; yes (P:)
	JR	SECIN			; no, virtual floppy (O:)

SECADJ:	INC	BC			; virtual drive
SECIN:	LD	(@SECT),BC
	CALL	BBSECSET
	hex16	b,c
	RET

SETDMA:
	FTRACE "SETDMA"
	LD	(@DMA),BC
	CALL	BBDMASET
	hex16	b,c
	RET


SECTRN:	ftrace "SECTRN"
	hex16	b,c
	LD	L,C
	LD	H,B
	LD	A,D
	OR	E
	RET	Z
	EX	DE,HL
	ADD	HL,BC
	LD	L,(HL)
	LD	H,0
	RET

GETDRV:
	LD	HL,@DTBL		; return address of disk drive table:
	RET

;--------------------------------------------------------------------------
;                                  BOOT
;                   ROUTINE DOES COLD BOOT INITIALIZATION:
;--------------------------------------------------------------------------


BOOT:	FTRACE "BOOT"

; 	JP	$A000
	LD	A,'3'
	LD	(COPSYS),A		; ostype for sysbios

	CALL	BBHDINIT		; IDE init
	OR	A
	JR	NZ,IDEERR
	CALL	BBLDPART
	RET				; ret Z if no problem


IDEERR:	LD	HL,MFAIL		; initialization of IDE Drive failed
	CALL	PSTRING
	CALL	BBCONIN
	JP	$FC00			; re-init system monitor

;------------------------------------------------------------------------------
;	   read a sector at @trk, @sec to address at @dma, from cdisk
;------------------------------------------------------------------------------

DREAD:	FTRACE "READ"
	LD	HL,(FDRVBUF)
	LD	H,0
	hex8	l
	ADD	HL,HL			; get drive code and double it
	LD	DE,@DTBL
	ADD	HL,DE			; make address of table entry
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A 			; fetch table entry
	PUSH	HL			; save address of table
	LD	DE,-8
	ADD	HL,DE			; point to read routine address
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A			; get address of routine
	POP	DE			; recover address of table
	DEC	DE
	DEC	DE			; point to relative drive
	LD	A,(DE)
	INC	DE
	INC	DE			; point to DPH again
	HEX16	H,L
	JP	(HL)			; leap to driver

READ:
	CALL	DREAD
	IF LDRDBG
	CALL	HEXDUMP
	CALL	OUTCRLF
	ENDIF
	XOR	A
; 	RET

VOID:					; void routine
	RET

	; wrapper for virtual hd read routine
HRDVDSK:
	PUSH	IX
	PUSH	IY
	LD	HL,(HDSECS)
	LD	DE,(HDSECS+2)
	CALL	BBDPRMSET
	CALL	BBRDVDSK
	POP	IY
	POP	IX

	; wrapper for virtual hd write routine
HWRVDSK:
	RET

	; wrapper for ide hd read routine
IDERDDSK:
	PUSH	IY
	CALL	BBHDRD
	POP	IY
	OR	A
	RET	Z
	LD	A,1			; correct return value for BDOS
; 	RET

	; wrapper for ide hd write routine
IDEWRDSK:
	RET

	; floppy read routine
FDDRD:
	PUSH	IX
	LD	HL,(FLSECS)
	LD	DE,(FLSECS+2)
	CALL	BBDPRMSET
	LD	A,(FDRVBUF)		; get active drive
	CP	2			; is hw floppy ?
	JR	C,RDFLO			; yes
	JR	RDVRT			; no, then is a virtual drive
	;
RDFLO:	CALL	CHKSID			; side select
	CALL	BBFDRVSEL		; activate driver
	CALL	BBFREAD			; do read
	POP	IX
	JR	FLRET
	;
RDVRT:	CALL	BBRDVDSK		; call par. read
	BIT	0,A			; adjust Z flag for error test
	POP	IX
	JR	FLRET

	; floppy write routine
FDDWR:
	JR	FLOK

	; adjust return value for floppies
FLRET:	JR	Z,FLOK
	XOR	A
	INC	A
	RET
FLOK:	XOR	A
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

; Print a string in [HL] up to '$'
PSTRING:
	LD	A,(HL)
	CP	'$'
	RET	Z
	LD	C,A
	CALL	BBCONOUT
	INC	HL
	JP	PSTRING

;---------------------------------------- DBUG
	IF LDRDBG
;;
;; Inline print
;;
INLINE:
	EX	(SP),HL			; get address of string (ret address)
	CALL	PSTRING
	EX	(SP),HL			; load return address after the '$'
	RET				; back to code immediately after string

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
HEXDUMP:			;print a hexdump of the data in the 512 byte buffer (@DMA)
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL

	LD	HL,(@DMA)
	PUSH	HL
	LD	DE,128
	ADD	HL,DE
	LD	E,L
	LD	D,H
	POP	HL
	CALL	MEMDUMP

	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET

MEMDUMP:
	EXX
	LD	B,255	; row counter, for the sake of simplicity
	EXX
	LD	(DMASAVE),HL
MDP6:
	PUSH	HL
	LD	HL,(DMASAVE)
	LD	C,L
	LD	B,H
	POP	HL
	PUSH	HL
	SBC	HL,BC
; 	CALL	HL2ASCB
; 	CALL	SPACER
	CALL	OUTCRLF
	POP	HL
	LD	A,L
; 	CALL	DMPALIB
	PUSH	HL
MDP2:	LD	A,(HL)
	CALL	H2AJ1
	CALL	CHKEOR
	JR	C,MDP1
	CALL	SPACER
	LD	A,L
	AND	$0F
	JR	NZ,MDP2
MDP7:	POP	HL
	LD	A,L
	AND	$0F
; 	CALL	DMPALIA
MDP5:	LD	A,(HL)
	LD	C,A
	CP	$20
	JR	C,MDP3
	JR	MDP4
MDP3:	LD	C,$2E
MDP4:	CALL	ZCO
	CALL	CHKBRK
	LD	A,L
	AND	$0F
	JR	NZ,MDP5
	JR	MDP6
MDP1:	SUB	E
; 	CALL	DMPALIB
	call	spacer
	JR	MDP7

;;
CBKEND:	POP	DE
	RET

CHKBRK:
	CALL	CHKEOR			; was 00F949 CD 3C F9
	JR	C,CBKEND
	CALL	ZCSTS
	OR	A
	RET	Z
	CALL	COIUPC
	CP	$13
	JR	NZ,CBKEND
; 	JP	COIUPC
;;
;;
;; COIUPC- convert reg A uppercase
COIUPC:
	CALL	ZCI
	CP	$60
	JP	M,COIRE
	CP	$7B
	JP	P,COIRE
	RES	5,A
COIRE:	RET

;;
WPAUSE:
	LD	DE,WPAUSEMSG
	CALL	PSTRING
	CALL	ZCI
	RET
;;
;; DMPALIB - beginning align (spacing) for a memdump
DMPALIB:
	AND	$0F
	LD	B,A
	ADD	A,A
	ADD	A,B
;;
;; DMPALIB - ascii align (spacing) for a memdump
DMPALIA:
	LD	B,A
	INC	B
ALIBN:	CALL	SPACER
	DJNZ	ALIBN
	RET
ZCI:	;Return keyboard character in [A]
	PUSH	BC
	PUSH	DE
	PUSH	HL
	CALL	BBCONIN
	PUSH	AF
	LD	C,A
	CALL	BBCONOUT
	POP	AF
	POP	HL
	POP	DE
	POP	BC
	RET

;; inc HL and do a 16 bit compare between HL and DE
CHKEOR:
	INC	HL
	LD	A,H
	OR	L
	SCF
	RET	Z
	LD	A,E
	SUB	L
	LD	A,D
	SBC	A,H
	RET

ZCSTS:
	PUSH	BC
	PUSH	DE
	PUSH	HL
	CALL	BBCONST
	POP	HL
	POP	DE
	POP	BC
	CP	1
	RET

HL2ASC:

H2AEN1:	LD	A,H
	CALL	H2AJ1
	LD	A,L
H2AJ1:	PUSH	AF
	RRCA
	RRCA
	RRCA
	RRCA
	CALL	H2AJ2
	POP	AF
H2AJ2:	CALL	NIB2ASC
	CALL	BBCONOUT
	RET

H2AJ3:	CALL	H2AJ1           ; entry point to display HEX and a "-"
MPROMPT:
	LD	C,$2D
	CALL	BBCONOUT
	RET

;;
;; HL2ASCB - convert & display HL 2 ascii leave a blank after
HL2ASCB:
	CALL	HL2ASC           ; was 00FA63 CD 46 FA
SPACER:	LD	C,$20
	CALL	BBCONOUT
	RET

NIB2ASC:
	AND	$0F             ; was 00FDE0 E6 0F
	ADD	A,$90
	DAA
	ADC	A,$40
	DAA
	LD	C,A
	RET

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


;; OUTCRLF - CR/LF through OUTSTR
;

OUTCRLF:
	PUSH	HL			; was 00FAB0 E5
OCRLF1:	LD	HL,CRLFTAB
	CALL	OUTSTR
	POP	HL
	RET

CRLFTAB:
	DEFB	$0D,$8A

ZCO:	PUSH	AF	;Write character that is in [C]
	CALL	BBCONOUT
	POP	AF
	RET
DMASAVE		DEFW	0
DMPPAUSE	DEFB	0
WPAUSEMSG	DEFB	"-- more --",CR,LF,'$'

OLDSTACK:
	DEFW	0
	DEFS	40
NEWSTACK:
	DEFW	0

	ENDIF
;---------------------------------------- DBUG
;-----------------------------------------------------------------------

MFAIL:
	DEFB	CR,LF,"Initilization of IDE Drive Failed.",CR,LF
	DEFB	"Press a key to continue.",CR,LF,'$'

@TRK:	DEFS	2			; 2 bytes for next track to read or write
@DMA:	DEFS	2			; 2 bytes for next dma address
@SECT:	DEFS	2			; 2 bytes for sector
FLSECS:	DEFW	11
	DEFW	512
	DEFB	2			; heads
	DEFW	80			; tracks
HDSECS:	DEFW	256
	DEFW	512




	; directory buffer control block:
DIRBCB:
	DEFB	0FFH			; drive 0
	DEFS	3
	DEFS	1
	DEFS	1
	DEFS	2
	DEFS	2
	DEFW	DIRBUF			; pointer to directory buffer

	; data buffer control block:
DATABCB:
	DEFB	0FFH			; drive 0
	DEFS	3
	DEFS	1
	DEFS	1
	DEFS	2
	DEFS	2
	DEFW	DATABUF			; pointer to data buffer

	; directory buffer
DIRBUF:	DEFS	512

	; DATA BUFFER:
DATABUF:DEFS	512

	; drive allocation vector:
ALV:	DEFS	1000			; space for double bit allocation vectors

CSV:					; no checksum vector required for a hdisk
	DEFS	(1023/4)+1

	END

