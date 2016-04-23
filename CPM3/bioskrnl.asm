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
;; 20140904	- Code start
;;---------------------------------------------------------------------

TITLE	'ROOT MODULE OF RELOCATABLE BIOS FOR CP/M 3.1'


	.Z80

	; define logical values:
	include	common.inc
	include syshw.inc

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
; 	ld	a,(wkp)
; 	or	a
; 	call	nz,bbconin
; 	call	bbconin
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

;		  Copyright (C), 1982
;		 Digital Research, Inc
;		     P.O. Box 579
;		Pacific Grove, CA  93950

;   This is the invariant portion of the modular BIOS and is
;	distributed as source for informational purposes only.
;	All desired modifications should be performed by
;	adding or changing externally defined modules.
;	This allows producing "standard" I/O modules that
;	can be combined to support a particular system
;	configuration.
;
;   Modified for faster character I/O by Udo Munk

BELL	EQU	7
CTLQ	EQU	'Q'-'@'
CTLS	EQU	'S'-'@'

CCP	EQU	0100H				; Console Command Processor gets loaded
						; into the TPA

	CSEG					; GENCPM puts CSEG stuff in common memory

	; variables in system data page

	EXTRN	@COVEC,@CIVEC,@AOVEC		; I/O redirection vectors
	EXTRN	@AIVEC,@LOVEC
	EXTRN	@MXTPA				; addr of system entry point
	EXTRN	@BNKBF				; 128 byte scratch buffer

	; initialization

	EXTRN	?INIT				; general initialization
	EXTRN	?LDCCP,?RLCCP			; load & reload CCP for BOOT & WBOOT

	; user defined character I/O routines

	EXTRN	?CI,?CO,?CIST,?COST		; each take device in <B>
	EXTRN	?CINIT				; (re)initialize device in <C>
	EXTRN	@CTBL				; physical character device table

	; disk communication data items

	EXTRN	@DTBL				; table Of pointers to XDPHs
	PUBLIC	@ADRV,@RDRV,@TRK,@SECT		; parameters for disk I/O
	PUBLIC	@DMA,@DBNK,@CNT			;    ''       ''   ''  ''

	; memory control

	PUBLIC	@CBNK				; current bank
	EXTRN	?XMOVE,?MOVE			; select move bank, and block move
	EXTRN	?BANK				; select CPU bank

	; clock support

	EXTRN	ZDSTIME				; signal time operation

	; general utility routines

	PUBLIC	?PMSG,?PDEC			; print message, print number from 0 to 65535
	PUBLIC	?PDERR				; print BIOS disk error message header

	include	modebaud.inc			; define mode bits

	; External names for BIOS entry points

	PUBLIC	?BOOT,?WBOOT,?CONST,?CONIN,?CONO,?LIST,?AUXO,?AUXI
	PUBLIC	?HOME,?SLDSK,?STTRK,?STSEC,?STDMA,?READ,?WRITE
	PUBLIC	?LISTS,?SCTRN
	PUBLIC	?CONOS,?AUXIS,?AUXOS,?DVTBL,?DEVIN,?DRTBL
	PUBLIC	?MLTIO,?FLUSH,?MOV,?TIM,?BNKSL,?STBNK,?XMOV

	PUBLIC	@BIOS$STACK

	; BIOS Jump vector.

	; All BIOS routines are invoked by calling these
	; entry points.

?BOOT:	JP	BOOT			; initial entry on cold start
?WBOOT:	JP	WBOOT			; reentry on program exit, warm start

?CONST:	JP	CONST			; return console input status
?CONIN:	JP	CONIN			; return console input character
?CONO:	JP	CONOUT			; send console output character
?LIST:	JP	BLIST			; send list output character
?AUXO:	JP	AUXOUT			; send auxiliary output character
?AUXI:	JP	AUXIN			; return auxiliary input character

?HOME:	JP	HOME			; set disks to logical home
?SLDSK:	JP	SELDSK			; select disk drive, return disk parameter info
?STTRK:	JP	SETTRK			; set disk track
?STSEC:	JP	SETSEC			; set disk sector
?STDMA:	JP	SETDMA			; set disk I/O memory address
?READ:	JP	READ			; read physical block(s)
?WRITE:	JP	WRITE			; write physical block(s)

?LISTS:	JP	LISTST			; return list device status
?SCTRN:	JP	SECTRN			; translate logical to physical sector

?CONOS:	JP	CONOST			; return console output status
?AUXIS:	JP	AUXIST			; return aux input status
?AUXOS:	JP	AUXOST			; return aux output status
?DVTBL:	JP	DEVTBL			; return address of device def table
?DEVIN:	JP	?CINIT			; change baud rate of device

?DRTBL:	JP	GETDRV			; return address of disk drive  table
?MLTIO:	JP	MULTIO			; set multiple record count for disk I/O
?FLUSH:	JP	FLUSH			; flush BIOS maintained disk caching

?MOV:	JP	?MOVE			; block move memory to memory
?TIM:	JP	ZDSTIME			; Signal Time and Date operation
?BNKSL:	JP	BNKSEL			; select bank for code execution and default DMA
?STBNK:	JP	SETBNK			; select different bank for disk I/O DMA operation
?XMOV:	JP	?XMOVE			; set source and destination banks for one operation

	JP	0			; reserved for future expansion
	JP	0			; reserved for future expansion
	JP	0			; reserved for future expansion


	; BOOT
	;	Initial entry point for system startup.
	IF BANKED
	DSEG				; this part can be banked
	ENDIF

BOOT: ftrace "boot"
; 	JP	$A000
	LD	B,BBPAG << 4		; ensure that sysbios base page ($BB)
	LD	C,MMUPORT		; is in place
	LD	A,(HMEMPAG)
	SUB	4
	OUT	(C),A

	LD	SP,@BIOS$STACK
	LD	C,15			; initialize all 16 character devices
C$INIT$LOOP:
	PUSH	BC
	CALL	?CINIT
	POP	BC
	DEC	C
	JP	P,C$INIT$LOOP

	CALL	?INIT			; perform any additional system initialization

	LD	BC,16*256+0
	LD	HL,@DTBL		; init all 16 logical disk drives
D$INIT$LOOP:
	PUSH	BC			; save remaining count and abs drive
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL			; grab @drv entry
	LD	A,E
	OR	D
	JR	Z,D$INIT$NEXT		; if null, no drive
	PUSH	HL			; save @drv pointer
	EX	DE,HL			; XDPH address in <HL>
	DEC	HL
	DEC	HL
	LD	A,(HL)
	LD	(@RDRV),A		; get relative drive code
	LD	A,C
	LD	(@ADRV),A		; get absolute drive code
	DEC	HL			; point to init pointer
	LD	D,(HL)
	DEC	HL
	LD	E,(HL)			; get init pointer
	EX	DE,HL
	CALL	IPCHL			; call init routine
	POP	HL			; recover @drv pointer
D$INIT$NEXT:
	POP	BC			; recover counter and drive #
	INC	C
	DEC	B
	JR	NZ,D$INIT$LOOP		; and loop for each drive

	JP	BOOT$1

	CSEG				; following in resident memory

BOOT$1:
	CALL	SETJUMPS
	CALL	?LDCCP			; fetch CCP for first time
	JP	CCP


	; WBOOT
	;	Entry for system restarts.

WBOOT:	ftrace "WBOOT"
	LD	SP,@BIOS$STACK
	CALL	SETJUMPS		; initialize page zero
	CALL	?RLCCP			; reload CCP
	JP	CCP			; then reset jmp vectors and exit to ccp

SETJUMPS:

    IF BANKED
	LD	A,0
	CALL	?BNKSL
	CALL	DOSETJMPS
	LD	A,1
	CALL	?BNKSL
    ENDIF

DOSETJMPS:
	LD	A,0C3H			; jp opcode
	LD	(0),A
	LD	(5),A			; set up jumps in page zero
	LD	HL,?WBOOT
	LD	(1),HL			; bios warm start entry
	LD	HL,(@MXTPA)
	LD	(6),HL			; bdos system call entry
	RET

	DS	64
@BIOS$STACK 	EQU	$


	; DEVTBL
	;	Return address of character device table

DEVTBL:
	LD	HL,@CTBL
	RET


	; GETDRV
	;	Return address of drive table

GETDRV:
	LD	HL,@DTBL
	RET

	; CONOUT
	;	Console Output. Send character in <C>
	;	to all selected devices

CONOUT:
	LD	HL,(@COVEC)		; fetch console output bit vector
	JR	OUT$SCAN


	; AUXOUT
	;	Auxiliary Output. Send character in <C>
	;	to all selected devices

AUXOUT:	ftrace "AUXOUT"
	LD	HL,(@AOVEC)		; fetch aux output bit vector
	JR	OUT$SCAN


	; BLIST
	;	List Output. Send character in <C>
	;	to all selected devices.

BLIST:	ftrace "BLIST"
	LD	HL,(@LOVEC)		; fetch list output bit vector

OUT$SCAN:
	LD	B,0			; start with device 0
CO$NEXT:
	ADD	HL,HL			; shift out next bit
	JR	NC,NOT$OUT$DEVICE
	PUSH	HL			; save the vector
; 	PUSH	BC			; save the count and character
;NO$OUT$READY:
;	CALL	COSTER
;	OR	A
;	JR	NZ,NO$OUT$READY
; 	POP	BC
	PUSH	BC			; restore and resave the character and device
	CALL	?CO			; if device selected, print it
	POP	BC			; recover count and character
	POP	HL			; recover the rest of the vector
NOT$OUT$DEVICE:
	INC	B			; next device number
	LD	A,H
	OR	L			; see if any devices left
	JR	NZ,CO$NEXT		; and go find them...
	RET


	; CONOST
	;	Console Output Status. Return true if
	;	all selected console output devices
	;	are ready.

CONOST:
	LD	HL,(@COVEC)		; get console output bit vector
	JR	OST$SCAN


	; AUXOST
	;	Auxiliary Output Status. Return true if
	;	all selected auxiliary output devices
	;	are ready.

AUXOST:	ftrace "AUXOST"
	LD	HL,(@AOVEC)		; get aux output bit vector
	JR	OST$SCAN


	; LISTST
	;	List Output Status. Return true if
	;	all selected list output devices
	;	are ready.

LISTST:	ftrace "LISTST"
	LD	HL,(@LOVEC)		; get list output bit vector

OST$SCAN:
	LD	B,0			; start with device 0
COS$NEXT:
	ADD	HL,HL			; check next bit
	PUSH	HL			; save the vector
	PUSH	BC			; save the count
	LD	A,0FFH			; assume device ready
	CALL	C,COSTER		; check status for this device
	POP	BC			; recover count
	POP	HL			; recover bit vector
	OR	A			; see if device ready
	RET	Z			; if any not ready, return false
	INC	B			; drop device number
	LD	A,H
	OR	L			; see if any more selected devices
	JR	NZ,COS$NEXT
	OR	0FFH			; all selected were ready, return true
	RET

COSTER:		; check for output device ready, including optional
		;xon/xoff support
	LD	L,B
	LD	H,0			; make device code 16 bits
	PUSH	HL			; save it in stack
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL			; create offset into device characteristics tbl
	LD	DE,@CTBL+6
	ADD	HL,DE			; make address of mode byte
	LD	A,(HL)
	AND	MB$XON$XOFF
	POP	HL			; recover console number in <HL>
	JP	Z,?COST			; not a xon device, go get output status direct
	LD	DE,XOFFLIST
	ADD	HL,DE			; make pointer to proper xon/xoff flag
	CALL	CIST1			; see if this keyboard has character
	LD	A,(HL)
	CALL	NZ,CI1			; get flag or read key if any
	CP	CTLQ
	JR	NZ,NOT$Q		; if its a ctl-Q,
	LD	A,0FFH			; set the flag ready
NOT$Q:
	CP	CTLS
	JR	NZ,NOT$S		; if its a ctl-S,
	LD	A,00H			; clear the flag
NOT$S:
	LD	(HL),A			; save the flag
	CALL	COST1			; get the actual output status,
	AND	(HL)			; and mask with ctl-Q/ctl-S flag
	RET				; return this as the status

CIST1:		; get input status with <BC> and <HL> saved
	PUSH	BC
	PUSH	HL
	CALL	?CIST
	POP	HL
	POP	BC
	OR	A
	RET

COST1:		; get output status, saving <BC> & <HL>
	PUSH	BC
	PUSH	HL
	CALL	?COST
	POP	HL
	POP	BC
	OR	A
	RET

CI1:		; get input, saving <BC> & <HL>
	PUSH	BC
	PUSH	HL
	CALL	?CI
	POP	HL
	POP	BC
	RET


	; CONST
	;	Console Input Status. Return true if
	;	any selected console input device
	;	has an available character.

CONST:
	LD	HL,(@CIVEC)		; get console input bit vector
	JR	IST$SCAN


	; AUXIST
	;	Auxiliary Input Status. Return true if
	;	any selected auxiliary input device
	;	has an available character.

AUXIST:	ftrace "AUXIST"
	LD	HL,(@AIVEC)		; get aux input bit vector

IST$SCAN:
	LD	B,0			; start with device 0
CIS$NEXT:
	ADD	HL,HL			; check next bit
	LD	A,0			; assume device not ready
	CALL	C,CIST1			; check status for this device
	OR	A
	RET	NZ			; if any ready, return true
	INC	B			; next device number
	LD	A,H
	OR	L			; see if any more selected devices
	JR	NZ,CIS$NEXT
	XOR	A			; all selected were not ready, return false
	RET


	; CONIN
	;	Console Input. Return character from first
	;		ready console input device.

CONIN:
	LD	HL,(@CIVEC)
	JR	IN$SCAN


	; AUXIN
	;	Auxiliary Input. Return character from first
	;	ready auxiliary input device.

AUXIN:	ftrace "AUXIN"
	LD	HL,(@AIVEC)

IN$SCAN:
	PUSH	HL			; save bit vector
	LD	B,0
CI$NEXT:
	ADD	HL,HL			; shift out next bit
	LD	A,0			; insure zero a (nonexistant device not ready).
	CALL	C,CIST1			; see if the device has a character
	OR	A
	JR	NZ,CI$RDY		; this device has a character
	INC	B			; else, next device
	LD	A,H
	OR	L			; see if any more devices
	JR	NZ,CI$NEXT		; go look at them
	POP	HL			; recover bit vector
	JR	IN$SCAN			; loop til we find a character
CI$RDY:
	POP	HL			; discard extra stack
	JP	?CI


	; Utility Subroutines

IPCHL:	ftrace "IPCHL"		; vectored CALL point
	hex16	h,l
	JP	(HL)

?PMSG:		; print message @<HL> up to a null
		; saves <BC> & <DE>
	PUSH	BC
	PUSH	DE
PMSG$LOOP:
	LD	A,(HL)
	OR	A
	JR	Z,PMSG$EXIT
	LD	C,A
	PUSH	HL
	CALL	?CONO
	POP	HL
	INC	HL
	JR	PMSG$LOOP
PMSG$EXIT:
	POP	DE
	POP	BC
	RET


?PDEC0:		; print binary number 0-65535 from <HL>, with leading zeros
	LD	B,1
	JR	PDEC1

?PDEC:		; print binary number 0-65535 from <HL>, no leading zeros

	LD	B,0
PDEC1:	LD	DE,-10000
	CALL	SBCNT
	LD	DE,-1000
	CALL	SBCNT
	LD	DE,-100
	CALL	SBCNT
	LD	DE,-10
	CALL	SBCNT
	LD	A,L
	ADD	A,'0'
	LD	C,A
	JP	?CONO

SBCNT:	LD	C,'0'-1
SB1:	INC	C
	ADD	HL,DE
	JR	C,SB1
	SBC	HL,DE
	LD	A,B
	OR	A
	JR	NZ,SB2
	LD	A,C
	CP	'0'
	RET	Z
	LD	B,1
SB2:	PUSH	HL
	PUSH	BC
	CALL	?CONO
	POP	BC
	POP	HL
	RET

?PDERR:
	LD	HL,DRIVE$MSG
	CALL	?PMSG			; error header
	LD	A,(@ADRV)
	ADD	A,'A'
	LD	C,A
	CALL	?CONO			; drive code
	LD	HL,TRACK$MSG
	CALL	?PMSG			; track header
	LD	HL,(@TRK)
	CALL	?PDEC0			; track number
	LD	HL,SECTOR$MSG
	CALL	?PMSG			; sector header
	LD	HL,(@SECT)
	CALL	?PDEC0			; sector number
	RET


	; BNKSEL
	;	Bank Select. Select CPU bank for further execution.

BNKSEL:;	ftrace "BNKSEL"
	LD	(@CBNK),A		; remember current bank
	JP	?BANK			; and go exit through users
					; physical bank select routine

XOFFLIST:
	DB 	-1,-1,-1,-1,-1,-1,-1,-1	; ctl-s clears to zero
	DB	-1,-1,-1,-1,-1,-1,-1,-1

	IF BANKED
	DSEG	; following resides in banked memory
        ENDIF

	; Disk I/O interface routines


	; SELDSK
	;	Select Disk Drive. Drive code in <C>.
	;	Invoke login procedure for drive
	;	if this is first select. Return
	;	address of disk parameter header
	;	in <HL>

SELDSK:	ftrace "SELDSK"
	hex8	c
	CALL	BBDSKSEL
	LD	A,C
	LD	(@ADRV),A		; save drive select code
	LD	L,C
	LD	H,0
	ADD	HL,HL			; create index from drive code
	LD	BC,@DTBL
	ADD	HL,BC			; get pointer to dispatch table
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A			; point at disk descriptor
	OR	H
	RET	Z			; if no entry in table, no disk
	LD	A,E
	AND	1
	JR	NZ,NOT$FIRST$SELECT	; examine login bit
	PUSH	HL
	EX	DE,HL			; put pointer in stack & <DE>
	LD	HL,-2
	ADD	HL,DE
	LD	A,(HL)
	LD	(@RDRV),A		; get relative drive
	LD	HL,-6
	ADD	HL,DE			; find LOGIN addr
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A			; get address of LOGIN routine
	CALL	IPCHL			; call LOGIN
	POP	HL			; recover DPH pointer
NOT$FIRST$SELECT:
	RET


	; HOME
	;	Home selected drive. Treated as SETTRK(0).

HOME:
	LD	BC,0			; same as set track zero


	; SETTRK
	;	Set Track. Saves track address from <BC>
	;	in @TRK for further operations.

SETTRK:	ftrace "SETTRK"
	LD	(@TRK),BC
	CALL	BBTRKSET
	hex16	b,c
; 	call	tdrv
	RET


	; SETSEC
	;	Set Sector. Saves sector number from <BC>
	;	in @sect for further operations.

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

SECADJ:	INC	BC
SECIN:	LD	(@SECT),BC
	hex16	b,c
	CALL	BBSECSET
	RET


	; SETDMA
	;	Set Disk Memory Address. Saves DMA address
	;	from <BC> in @DMA and sets @DBNK to @CBNK
	;	so that further disk operations take place
	;	in current bank.

SETDMA:	ftrace "SETDMA"
	LD	(@DMA),BC
	CALL	BBDMASET
	hex16	b,c
	LD	A,(@CBNK)		; default DMA bank is current bank
					; fall through to set DMA bank


	; SETBNK
	;	Set Disk Memory Bank. Saves bank number
	;	in @DBNK for future disk data
	;	transfers.

SETBNK:	ftrace "SETBNK"
	hex8	a
	LD	(@DBNK),A
	RET


	; SECTRN
	;	Sector Translate. Indexes skew table in <DE>
	;	with sector in <BC>. Returns physical sector
	;	in <HL>. If no skew table (<DE>=0) then
	;	returns physical=logical.

SECTRN:	ftrace "SECTRN"
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


	; READ
	;	Read physical record from currently selected drive.
	;	Finds address of proper read routine from
	;	extended disk parameter header (XDPH).

READ:	ftrace "READ"
	LD	HL,(@ADRV)
	LD	H,0
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
	JR	RW$COMMON		; use common code


	; WRITE
	;	Write physical sector from currently selected drive.
	;	Finds address of proper write routine from
	;	extended disk parameter header (XDPH).

WRITE:	ftrace "WRITE"
	LD	HL,(@ADRV)
	LD	H,0
	ADD	HL,HL			; get drive code and double it
	LD	DE,@DTBl
	ADD	HL,DE			; make address of table entry
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A			; fetch table entry
	PUSH	HL			; save address of table
	LD	DE,-10
	ADD	HL,DE			; point to write routine address

RW$COMMON:
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A			; get address of routine
	POP	DE			; recover address of table
	DEC	DE
	DEC	DE			; point to relative drive
	LD	A,(DE)
	LD	(@RDRV),A		; get relative drive code and post it
	INC	DE
	INC	DE			; point to DPH again
	hex16	h,l
	JP	(HL)			; leap to driver


	; MULTIO
	;	Set multiple sector count. Saves passed count in
	;	@CNT

MULTIO:	ftrace "MULTIO"
	LD	(@CNT),A
	RET


	; FLUSH
	;	BIOS deblocking buffer flush. Not implemented.

FLUSH:
	XOR	A
	RET				; return with no error

	; error message components

DRIVE$MSG:	DB	CR,LF,BELL,'BIOS Error on ',0
TRACK$MSG:	DB	': T-',0
SECTOR$MSG:	DB	', S-',0

	; disk communication data items

	CSEG	; in common memory

@ADRV:	DS	1		; currently selected disk drive
@RDRV:	DS	1		; controller relative disk drive
@TRK:	DS	2		; current track number
@SECT:	DS	2		; current sector number
@DMA:	DS	2		; current DMA address
@CNT:	DB	0		; record count for multisector transfer
@DBNK:	DB	0		; bank for DMA operations

	CSEG	; common memory

@CBNK:	DB	0		; bank for processor operations

	IF LDRDBG

; Print a string in [HL] up to '$'
PSTRING:
	LD	A,(HL)
	CP	'$'
	RET	Z
	LD	C,A
	CALL	BBCONOUT
	INC	HL
	JP	PSTRING

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

WKP:	DEFB	0

HEXDUMP:			;print a hexdump of the data in the 512 byte buffer (@DMA)
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL

	LD	HL,$FD00
	PUSH	HL
	LD	DE,32
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
	DB	$0D,$8A

ZCO:	PUSH	AF	;Write character that is in [C]
	CALL	BBCONOUT
	POP	AF
	RET
DMASAVE		DW	0
DMPPAUSE	DB	0
WPAUSEMSG	DB	"-- more --",CR,LF,'$'
OLDSTACK:
	DEFW	0
	DEFS	40
NEWSTACK:
	DEFW	0

	ENDIF

	END

