
	.Z80
	ASEG

include darkstar.equ
include Common.inc.asm



TRUE		EQU	-1	; DEFINE LOGICAL VALUES:
FALSE		EQU	NOT TRUE


BELL		EQU	07H
CR		EQU	0DH
LF		EQU	0AH
HRETRIES	EQU	5



	org	$100

BEGIN:

	NOP
	NOP

	ld	a,'C'-'A'
	ld 	(CDISK),a

	NOP
	NOP



	CALL	HDINIT
	CALL	GETPTABLE
; 	CALL	HDCPM

	ld	c,'C'-'A'
	call	BBDSKSEL
	LD	HL,0
	LD	C,0
	ld	a,'3'
	ld	(COPSYS),a

CALR:
	LD	A,(AUTO)
	OR	A
	JR	Z,WKEY
	PUSH	BC
	PUSH	HL
	CALL	BBCONST
	JR	NZ,NOKEY
	XOR	A
	LD	(AUTO),A
NOKEY:	POP	HL
	POP	BC


WKEY:	PUSH	BC
	PUSH	HL
	CALL	BBCONIN
	POP	HL
	POP	BC

	CP	$7F
	JP	Z,$F000
	CP	'+'
	JR	NZ,DODEC
	LD	DE,$100
	ADD	HL,DE
	DEC	C
DODEC:	CP	'-'
	JR	NZ,BACK
	LD	DE,$100
	OR	A
	SBC	HL,DE
	DEC	C
BACK:	CP	'*'
	JR	NZ,HALF
	DEC	C
	DEC	C
HALF:	CP	'/'
	JR	NZ,SAUT
	LD	DE,$10
	OR	A
	SBC	HL,DE
	DEC	C
SAUT:	CP	'0'
	JR	NZ,CONT
	LD	A,$FF
	LD	(AUTO),A

CONT:
	PUSH	HL
	PUSH	BC
	CALL	HL2ASCB
	POP	BC
	POP	HL

	PUSH	HL
	PUSH	BC
	LD	A,C
	CALL	H2AJ1
	CALL	SPACER
	POP	BC
	POP	HL

	push	bc
	ld	c,l
	ld	b,h
	call	BBTRKSET
	ld	bc,DMASP
	call	BBDMASET
	pop	bc
	ld	b,0
	call	BBSECSET


	PUSH	HL
	PUSH	BC
; 	CALL	BBHDRD
	CALL	READSECTOR
	jp	nz,0
	call	HEXDUMP
	call	zcrlf
	POP	BC
	POP	HL
	LD	A,C
	INC	A
	CP	255
	LD	C,A
	JP	C,CALR
	LD	C,0
	INC	HL
	JP	CALR

HDCPM:
	LD	A,(CDISK)		; get logged drive
	LD	C,A
	CALL	DSKSEL
	LD	BC,BLDOFFS		; read in loader @ BLDOFFS
	CALL	DMASET
	LD	BC,$00
	CALL	TRKSET
	LD	BC,$01
	CALL	SECSET
	CALL	READSECTOR
	LD	D,0			; error type (no volume)
	RET	NZ
	LD	DE,(HDBSIG)		; check for a valid bootloader
	LD	HL,(BLDOFFS)
	OR	A
	SBC	HL,DE
	LD	D,1			; error type (no bootloader)
	RET	NZ			; no bootlader found
	JP	BLDOFFS+2		; jump to the loader if all ok
	RET

HDBSIG:	DEFB	$55,$AA

;

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
	CALL	ZCO
	RET



ZCO:	PUSH	AF	;Write character that is in [C]
	CALL	BBCONOUT
	POP	AF
	RET



; Print a string in [DE] up to '$'
PSTRING:
	PUSH	BC
	PUSH	DE
	PUSH	HL
	EX	DE,HL
PSTRX:	LD	A,(HL)
	CP	'$'
	JP	Z,DONEP
	LD	C,A
	CALL	ZCO
	INC	HL
	JP	PSTRX
DONEP:	POP	HL
	POP	DE
	POP	BC
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
	DB	$0D,$8A

ZCRLF:
	PUSH	AF
	LD	C,CR
	CALL	ZCO
	LD	C,LF
	CALL	ZCO
	POP	AF
	RET

ZBITS:	PUSH	AF
	PUSH	BC
	PUSH	DE
	LD	E,A
	LD	B,8
BQ2:	SLA	E		;Z80 Op code for SLA A,E
	LD	A,18H
	ADC	A,A
	LD	C,A
	CALL	ZCO
	DJNZ	BQ2
	POP	DE
	POP	BC
	POP	AF
	RET

HEXDUMP:			;print a hexdump of the data in the 512 byte buffer (@DMA)
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL

	LD	HL,DMASP
	PUSH	HL
	LD	DE,7
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
	CALL	SPACER
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

AUTO:		DB	0
DMASAVE		DW	0
DMPPAUSE	DB	0
WPAUSEMSG	DB	"-- more --",CR,LF,'$'
;------------------------------------------------------------------------


;
;=======================================================================
;
; Modular Z80 DarkStar (NE Z80) Monitor
;
;=======================================================================
;
; IDE Interface on Multif-Board (8255)
; ---------------------------------------------------------------------

;
;
; IDE Status Register:
;  bit 7: Busy	1=busy, 0=not busy
;  bit 6: Ready 1=ready for command, 0=not ready yet
;  bit 5: DF	1=fault occured insIDE drive
;  bit 4: DSC	1=seek complete
;  bit 3: DRQ	1=data request ready, 0=not ready to xfer yet
;  bit 2: CORR	1=correctable error occured
;  bit 1: IDX	vendor specific
;  bit 0: ERR	1=error occured
;

IDBUFR		EQU	TRNPAG << 12
HRETRIES	EQU	5
SIGNSIZE	EQU	8
ENTRYSIZE	EQU	8
PTBLSIZE	EQU	15

	; TODO: All routines here are written for a single drive system,
	;       had to be revised...

PARRCRD	macro				; partition table record format
	DEFB	0			; active
	DEFB	0			; letter
	DEFB	0			; type
	DEFW	0			; start
	DEFW	0			; end
	DEFB	0			; reserved
	endm

	; Local storage for disks geometry
DSK0CYLS:	DEFW	0		; For IDE disk 0 or master
DSK0HEADS:	DEFW	0
DSK0SECTORS:	DEFW	0
PTSTART:	DEFW	0
PTEND:		DEFW	0
IDTSAV:		DEFB	0		; page # save
INRETRY:	DEFB	0		; retry on r/w errors
	; This are partition management
HDLOG:		DEFB	$FF		; logged drive
TBLOADED:	DEFB	0		; flag partition loaded
PARTBL:					; local, simplified, copy of the partition table
		PARRCRD			; entry 0 ...
		PARRCRD
		PARRCRD
		PARRCRD
		PARRCRD
		PARRCRD
		PARRCRD
		PARRCRD
		PARRCRD
		PARRCRD
		PARRCRD
		PARRCRD
		PARRCRD
		PARRCRD
		PARRCRD
		PARRCRD			; ... entry 16
SIGNSTRING:	DEFB	"AUAUUAUA"	; signature string


;;
;; Initialize interface
;;
HDINIT:
	LD	A,READCFG8255		; 10010010b
	OUT	(IDEPORTCTRL),A		; config 8255 chip, READ mode

	LD	A,IDERSTLINE
	OUT	(IDEPORTC),A		; hard reset the disk drive

	LD	B,$20			; tunable
HDRESDLY:
	DEC	B
	JR	NZ,HDRESDLY		; delay (reset pulse width)

	XOR	A
	OUT	(IDEPORTC),A		; no IDE control lines asserted
	LD	DE,32
	CALL	DELAY			; pause 32 ms.

	LD	D,11100000B		; data for IDE SDH reg (512 bytes, LBA mode, single drive, head 0)
	LD	E,REGSHD
	CALL	IDEWR8D

	LD	B,$FF			; tunable
HDWAITINI:
	LD	E,REGSTATUS		; get status after initilization
	CALL	IDERD8D			; check status
	BIT	7,D
	JP	Z,DONEINIT		; return if ready bit is zero

	;Delay to allow drive to get up to speed
	PUSH	BC			; (the 0FFH above)
	LD	BC,$FFFF
DELAY2:	LD	D,2			; may need to adjust delay time to allow cold drive to
DELAY1:	DEC	D			; to speed
	JP	NZ,DELAY1
	DEC	BC
	LD	A,C
	OR	B
	JP	NZ,DELAY2
	POP	BC
	DJNZ	HDWAITINI
	XOR	A			; flag error on return
	DEC	A
	RET
DONEINIT:
	RET


;;
;; Get drive identification block
;;
DRIVEID:
	; Mount transient page used for id buffer
	LD	B, TRNPAG
	CALL	MMGETP
	LD	(IDTSAV), A		; save current
	;
	LD	A,(HMEMPAG)		; bios scratch page (phy)
	LD	B,TRNPAG		; transient page
	CALL	MMPMAP			; mount it
	;
	CALL	IDEWAITNOTBUSY
	JR	C,IDRNOK

	LD	D,CMDID
	LD	E,REGCOMMAND
	CALL	IDEWR8D			; issue the command

	CALL	IDEWAITDRQ		; wait for Busy=0, DRQ=1
	JR	C,IDRNOK

	LD	B,0
	LD	HL,IDBUFR		; store data here
	CALL	MORERD16
	;;
	;; workaround for first word lossy drivers
	;;
	LD	A,(IDBUFR+18)
	CP	' '
	JR	NZ,IDRTRN
	; first word loss...
	LD	B,3			; # of retrys
IDRETRY:
	PUSH	BC
	CALL	IDEWAITNOTBUSY
	JR	C,IDRNOK

	LD	D,CMDID
	LD	E,REGCOMMAND
	CALL	IDEWR8D

	CALL	IDEWAITDRQ		; Wait for Busy=0, DRQ=1
	JR	C,IDRNOK

	LD	B,0
	LD	HL,IDBUFR		; store data here
	CALL	MORERD16I		; get words, try to recover 1st word already
					; on ide bus
	POP	BC
	LD	A,(IDBUFR+18)
	CP	' '
	JR	NZ,IDRTRN
	DJNZ	IDRETRY
IDRNOK:
	CALL	RSIDBUF
	XOR	A
	DEC	A
	RET				; * sigh * :-(
IDRTRN:
	; prior to return we save disk params locally
	CALL	SAVEGEO
	CALL	RSIDBUF
	XOR	A			; reset z flag
	RET

;;
;; restore scratch
;;
RSIDBUF:
	LD	A,(IDTSAV)		; old
	LD	B,TRNPAG		; transient page
	CALL	MMPMAP			; mount it
	RET

;;
;; Save disk geometry
;;
SAVEGEO:
	; TODO: should work also for slave
	LD	HL,IDBUFR + 2		; cyls
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	LD	(DSK0CYLS), BC
	LD	HL,IDBUFR + 6		; heads
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	LD	(DSK0HEADS), BC
	LD	HL,IDBUFR + 12		; sectors
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	LD	(DSK0SECTORS), BC
	RET

;;
;; Return disk geometry
;;
;; IX < cylinders, IY < heads, HL < sectors
GETHDGEO:
	LD	IX,(DSK0CYLS)
	LD	IY,(DSK0HEADS)
	LD	HL,(DSK0SECTORS)
	RET

;;
;; Get partition table
;;
GETPTABLE:
	LD	HL,TMPBYTE		; enable unpartitioned addressing
	SET	7,(HL)
	LD	BC,(DSK0SECTORS)	; verify we know disk geometry
	LD	A,C
	OR	B
	JR	NZ,GETOT00
	CALL	DRIVEID			; no: load it
	JR	NZ,GETPERR		; damn !
GETOT00:
	; mount transient page used for operations
	LD	B, TRNPAG
	CALL	MMGETP
	LD	(IDTSAV), A		; save current
	;
	LD	A,(HMEMPAG)		; bios scratch page (phy)
	LD	B,TRNPAG		; transient page
	CALL	MMPMAP			; mount it
	; read table
	LD	BC,0			; track 0
	CALL	TRKSET
	LD	BC,1			; sector 1
	CALL	SECSET
	LD	BC,IDBUFR		; DMA @ temp page
	CALL	DMASET
	CALL	READSECTOR
	JR	NZ,GETPERR		; :-(
	; check signature for valid table
	LD	DE,SIGNSTRING
	LD	HL,IDBUFR
	LD	BC,SIGNSIZE
GETOT01:
	LD	A,(DE)			; do compare
	INC	DE
	CPI
	JR	NZ,GETPERR		; invalid table
	JP	PO,GETOT02
	JR	GETOT01
GETOT02:
	; copy table in, only active entries are copied
	EXX
	LD	B,PTBLSIZE		; count on table entries
	EXX
	LD	HL,IDBUFR+SIGNSIZE-ENTRYSIZE
	LD	DE,PARTBL
GETOT04:
	LD	B,ENTRYSIZE
GETOT07:
	INC	HL
	DJNZ	GETOT07
GETOT05:
	LD	BC,ENTRYSIZE
	LD	A,(HL)
	CP	'Y'			; is active ?
	JR	NZ,GETOT03
	LDIR
	EXX
	DEC	B
	EXX
	JR	NZ,GETOT05
	JR	GETOT06
GETOT03:
	EXX
	DEC	B
	EXX
	JR	NZ,GETOT04
GETOT06:
	XOR	A
	PUSH	AF
	JR	GETPEXI
GETPERR:				; failure
	XOR	A
	DEC	A
	PUSH	AF
GETPEXI:
	; prior to return we save disk params locally
	CALL	RSIDBUF
	LD	HL,TMPBYTE		; disable unpartitioned addressing
	RES	7,(HL)
	POP	AF
	RET

;;
;; Read sector (512 bytes) from IDE
;;
READSECTOR:
	CALL	WRLBA			; tell which sector we want to read from.
	RET	NZ			; LBA error
	CALL	IDEWAITNOTBUSY
	JP	C,RDSNOK		; status error

	LD	D,CMDREAD
	LD	E,REGCOMMAND
	CALL	IDEWR8D			; send sec read command to drive.
	CALL	IDEWAITDRQ		; wait until it's got the data
	JP	C,RDSNOK		; read/status error
;
	LD	HL,(FRDPBUF)		; DMA address
	LD	B,0			; read 512 bytes to [HL] (256X2 bytes)
MORERD16:
	LD	A,REGDATA		; REG register address
	OUT	(IDEPORTC),A

	OR	IDERDLINE		; pulse RD line
	OUT	(IDEPORTC),A
MORERD16I:
	IN	A,(IDEPORTA)		; read lower byte
	LD	(HL),A
	INC	HL
	IN	A,(IDEPORTB)		; read upper byte
	LD	(HL),A
	INC	HL

	LD	A,REGDATA		; deassert RD line
	OUT	(IDEPORTC),A
	DJNZ	MORERD16

	LD	E,REGSTATUS
	CALL	IDERD8D
	LD	A,D
	AND	$01
	JR	NZ,RDSNOK
RDSOK:
	XOR	A			; ok
	LD	(INRETRY),A		; clean, in case...
	RET
RDSNOK:
	LD	A,(INRETRY)		; in a retry loop ?
	OR	A
	LD	HL,READSECTOR		; where to come back
	JR	NZ,IORETR		; handle retry
	LD	A,HRETRIES+1		; no. start it
; 	JR	IORETR

	; ... fall through

	; retry handle, common for both read and write
IORETR:	DEC	A
	LD	(INRETRY),A		; update count
	JR	Z,UNRECOV		; unrecoverable error!
	CALL	HDINIT			; reset drive
	JP	(HL)			; redo
UNRECOV:
	DEC	A
	RET				; error

;;
;; Write a sector, specified by the 3 bytes in LBA
;;
WRITESECTOR:
	CALL	WRLBA			; set LBA sector
	RET	NZ			; LBA error
	CALL	IDEWAITNOTBUSY		; make sure drive is ready
	JP	C,WRSNOK

	LD	D,CMDWRITE
	LD	E,REGCOMMAND
	CALL	IDEWR8D			; tell drive to write a sector
	CALL	IDEWAITDRQ		; wait unit it wants the data
	JP	C,WRSNOK
;
	LD	HL,(FRDPBUF)
	LD	B,0			; 256X2 bytes

	LD	A,WRITECFG8255
	OUT	(IDEPORTCTRL),A
WRSEC1:	LD	A,(HL)
	INC	HL
	OUT	(IDEPORTA),A		; write the lower byte
	LD	A,(HL)
	INC	HL
	OUT	(IDEPORTB),A		; write upper byte
	LD	A,REGDATA
	PUSH	AF
	OUT	(IDEPORTC),A		; send write command
	OR	IDEWRLINE		; send WR pulse
	OUT	(IDEPORTC),A
	POP	AF
	OUT	(IDEPORTC),A
	DJNZ	WRSEC1

	LD	A,READCFG8255		; set 8255 back to read mode
	OUT	(IDEPORTCTRL),A

	LD	E,REGSTATUS
	CALL	IDERD8D
	LD	A,D
	AND	$01
	JR	NZ,WRSNOK
WRSOK:
	XOR	A			; ok
	RET
WRSNOK:
	LD	A,(INRETRY)		; in a retry loop ?
	OR	A
	LD	HL,WRITESECTOR		; where to come back
	JR	NZ,IORETR		; handle retry
	LD	A,HRETRIES+1		; no. start it
	JR	IORETR

;;
;; calculate partition offset and validate requested track
;;
TRKOFF:
	LD	A,(HDLOG)		; check for disk change
	LD	B,A
	LD	A,(FDRVBUF)
	CP	B
	JR	Z,NODCHG		; unchanged
	;
	LD	B,PTBLSIZE		; changed, search in table
	LD	E,ENTRYSIZE
	LD	D,0
	INC	B
	ADD	A,'A'			; transform in letter
	LD	C,A			; save on C
	LD	IY,PARTBL-ENTRYSIZE	; point to table, back one slot
TONEXT:	ADD	IY,DE			; point to next
	DEC	B
	JR	Z,TOFERR		; not found !
	CP	(IY+1)			; compare
	JR	NZ,TONEXT
	LD	A,(COPSYS)		; verify type
	OR	A
	JR	Z,NOTPCK		; unspecified
	CP	(IY+2)
	JR	Z,NOTPCK		; ok, go on
	LD	A,C			; restore drive letter
	JR	TONEXT			; try again
NOTPCK: ;
	LD	L,(IY+3)		; found, save data
	LD	H,(IY+4)		; start cyl
	LD	(PTSTART),HL
	LD	L,(IY+5)
	LD	H,(IY+6)		; end cyl
	LD	(PTEND),HL
NODCHG:	; add offset, check partition boundaries
	LD	HL,(FTRKBUF)
	LD	DE,(PTSTART)
	ADD	HL,DE			; in partition offset. simple!
	LD	C,L
	LD	B,H			; move on BC
	LD	DE,(PTEND)		; address larger than partition ?
	OR	A
	SBC	HL,DE
	JR	NC,TOFERR		; ouch!
	XOR	A
	RET
TOFERR:	XOR	A
	DEC	A
	POP	HL			; do not reenter in WRLBA
	RET


;;
;; Setup LBA sector on IDE drive
;;
WRLBA:
	LD	BC,(FTRKBUF)		; load requested track
	LD	HL,TMPBYTE		; check for free/non free addressing
	BIT	7,(HL)
	CALL	Z,TRKOFF

	LD	D,B			; send high TRK#
	LD	E,REGCYLMSB
	CALL	IDEWR8D

	LD	D,C			; send low TRK#
	LD	E,REGCYLLSB
	CALL	IDEWR8D

	LD	A,(FSECBUF)		; get requested sector
	LD	D,A
	LD	E,REGSECTOR
	CALL	IDEWR8D

	LD	D,1			; one sector at a time (for now ?)
	LD	E,REGSECCNT
	CALL	IDEWR8D

	XOR	A			; reset flags
	RET


;;
;; wait for drive to clear busy flag
;;
IDEWAITNOTBUSY:				; drive ready if 01000000
	LD	B,$FF
	LD	C,$FF			; delay, must be above 80H for 4MHz Z80
MOREWAIT:
	LD	E,REGSTATUS		; wait for RDY bit to be set
	CALL	IDERD8D
	LD	A,D
	AND	11000000B
	XOR	01000000B
	JP	Z,DONENOTBUSY
	DJNZ	MOREWAIT
	DEC	C
	JP	NZ,MOREWAIT
	SCF				; set carry to indicate an error
	RET
DONENOTBUSY:
	OR	A			; clear carry it indicate no error
	RET

;;
;; wait for drive to set data ready flag
;;
IDEWAITDRQ:
	LD	B,$FF
	LD	C,$FF
MOREDRQ:
	LD	E,REGSTATUS		; wait for DRQ bit to be set
	CALL	IDERD8D
	LD	A,D
	AND	10001000B
	CP	00001000B
	JP	Z,DONEDRQ
	DJNZ	MOREDRQ
	DEC	C
	JP	NZ,MOREDRQ
	SCF				; set carry to indicate error
	RET
DONEDRQ:
	OR	A			; clear carry
	RET


;------------------------------------------------------------------
; Low Level 8 bit R/W to the drive controller. These are the routines
; that talk directly to the drive controller registers, via the
; 8255 chip.
; Note the 16 bit I/O to the drive (which is only for SEC R/W) is done
; directly in the routines READSECTOR & WRITESECTOR for speed reasons.
;

;;
;; Read 8 bits from IDE register in [E], return info in [D]
;;
IDERD8D:
	LD	A,E
	OUT	(IDEPORTC),A		; drive address onto control lines

	OR	IDERDLINE		; RD pulse pin (40H)
	OUT	(IDEPORTC),A		; assert read pin

	IN	A,(IDEPORTA)
	LD	D,A			; return with data in [D]

	LD	A,E			; clear WR line
	OUT	(IDEPORTC),A

	XOR	A
	OUT	(IDEPORTC),A		; zero all port C lines
	RET

;;
;; Write Data in [D] to IDE register in [E]
;;
IDEWR8D:
	LD	A,WRITECFG8255		; set 8255 to write mode
	OUT	(IDEPORTCTRL),A

	LD	A,D			; get data put it in 8255 A port
	OUT	(IDEPORTA),A

	LD	A,E			; select IDE register
	OUT	(IDEPORTC),A

	OR	IDEWRLINE		; lower WR line
	OUT	(IDEPORTC),A
	NOP

	LD	A,E			; clear WR line
	OUT	(IDEPORTC),A
	NOP

	LD	A,READCFG8255		; config 8255 chip, read mode on return
	OUT	(IDEPORTCTRL),A
	RET

;------------------------------------------------------------------------


TRKSET:
	LD	(FTRKBUF),BC
	RET
SECSET:
	LD	(FSECBUF),BC
	RET
DMASET:
	LD	(FRDPBUF),BC
	RET

DSKSEL:
	LD	A,C
	LD	(FDRVBUF),A
	RET

DMASP:
	;
	END

