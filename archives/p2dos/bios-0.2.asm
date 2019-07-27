;       CBIOS for Z80-DarkStar
;
; 2006/01/12 	archived version 0.1 and started a new version
;		with some new feature. I'm also doing a merge of some
;		code from the original NE BIOS after it's recover
;		and disassembly.
;
;
; link to DarkStar Monitor symbols...
rsym darkstar.sym
;
;
; VERS	EQU     22      	; VERSION 2.2 (CP/M related)
; ;
; MSIZE	EQU     60              ; CP/M VERSION MEMORY SIZE IN KILOBYTES
; 	;
; 	;       "BIAS" IS ADDRESS OFFSET FROM 3400H FOR MEMORY SYSTEMS
; 	;       THAN 16K (REFERRED TO AS"B" THROUGHOUT THE TEXT)
; 	;
; BIAS	EQU     (MSIZE-20)*1024
; CCP	EQU     3400H+BIAS      ; BASE OF CCP
; BDOS	EQU     CCP+806H        ; BASE OF BDOS
; BDOSB	EQU	CCP+$0800	; BDOS base offset
; BIOS	EQU     CCP+1600H       ; BASE OF BIOS
	;
	; load common symbols
	;
include common.asm
	;
	;	The useful part
	;
BIOSIZ	EQU	BEGDAT-BIOS	; BIOS size (text only)
	;
	; 	CDISK and IOBYTE are already defined into the monitor
	;
;CDISK   EQU     0004H		; CURRENT DISK NUMBER 0=A,... 15=P
;IOBYTE  EQU     0003H		; INTEL I/O BYTE
IOBVAL	EQU	$95		; and its default value
	;
	; 	for disk io...
	;
PHYOFF	EQU     15		; Offset to CHS informations in DPT
PHYLEN	EQU	7		; size of CHS vector
	;
	;
	ORG     BIOS            ; ORIGIN OF THIS PROGRAM
NSECTS	EQU     ($-CCP)/128     ; WARM START SECTOR COUNT (at least for 128 byte sectors....)
CPMSIZ	EQU	BEGDAT-CCP+128	; include BIOS in reload count... see WBOOT
BIOHBY	EQU	($ >> 8) & $FF
	;
	;	jump vector for individual subroutines
	;

	JP      CBBOOT		; BOOT     - cold start
WBOOTE: JP      WBOOT		; WBOOT    - warm start
	JP      MCONST		; CONST    - console status
	JP      MCONIN		; CONIN    - console character in
	JP      MCONOUT		; CONOUT   - console character out
	JP      MCBLIST		; LIST     - list character out
	JP      MPUNCH		; PUNCH    - punch character out
	JP      MREADER		; READER   - reader character out
	JP      HOME		; HOME     - move head to home position
	JP      SELDSK		; SELDSK   - select disk
	JP      JSETTR		; JSETTR   - set track number
	JP      JSETSE		; JSETSE   - set sector number
	JP      JSETDM		; JSETDM   - set dma address
	JP      CBREAD		; READ     - read disk
	JP      WRITE		; WRITE    - write disk
	JP      MLISTST		; LISTST   - return list status
	JP      SECTRAN		; SECTRAN  - sector translate
	JP	TIME		; TIME     - get/set time
	;
BOTDSK:	DEFB	$FF			; store id of boot drive
	;				; N.B. placed here to be easily accessible
	;				; by the BDOS
	;
	;	fixed data tables for four-drive standard
	;	IBM-compatible 8" disks
	;
	;	disk parameter header for disk 00
DPBASE:	DEFW	TRANS,0000
	DEFW	0000,  0000
	DEFW	DIRBF,DPBNDS
	DEFW	CHK00,ALL00
	;	disk parameter header for disk 01
	DEFW	TRANS,0000
	DEFW	0000,  0000
	DEFW	DIRBF,DPBNDS
	DEFW	CHK01,ALL01
	;
; DPBVRT:	DEFW	TRNIBM,0000
; 	DEFW	0000,  0000
; 	DEFW	DIRBF,DPBIBM
; 	DEFW	CHK02,ALL02
; 	;	disk parameter header for disk 01
; 	DEFW	TRNIBM,0000
; 	DEFW	0000,  0000
; 	DEFW	DIRBF,DPBIBM
; 	DEFW	CHK03,ALL03
	;
	; version for ZDSnative
	;
DPBVRT:	DEFW	TRANS, 0000
	DEFW	0000,  0000
	DEFW	DIRBF,DPBNDS
	DEFW	CHK02,ALL02
	;	disk parameter header for disk 01
	DEFW	TRANS, 0000
	DEFW	0000,  0000
	DEFW	DIRBF,DPBNDS
	DEFW	CHK03,ALL03
	;
	;	sector translate vector
	;
; TRNIBM:	DEFB	1,7,13,19	;sectors 1,2,3,4
; 	DEFB	25,5,11,17	;sectors 5,6,7,8
; 	DEFB	23,3,9,15	;sectors 9,10,11,12
; 	DEFB	21,2,8,14	;sectors 13,14,15,16
; 	DEFB	20,26,6,12	;sectors 17,18,19,20
; 	DEFB	18,24,4,10	;sectors 21,22,23,24
; 	DEFB	16,22		;sectors 25,26
	;
; TRANSHD:
; 	DEFB	1,2,3,4,5,6,7,8
; 	DEFB	9,10,11,12,13,14,15,16
; 	DEFB	17,18,19,20,21,22,23,24
; 	DEFB	25,26,27,28,29,30,31,32
	; native sector translation table (skew = 6)
TRANS:	DEFB	$01,$07,$0D,$02 	; sectors 1,2,3,4
	DEFB	$08,$0E,$03,$09 	; sectors 5,6,7,8
	DEFB	$0F,$04,$0A,$10		; sectors 9,10,11,12
	DEFB	$05,$0B,$11,$06		; sectors 13,14,15,16
	DEFB	$0C			; sector 17
; 	DEFB	$12			; sector 18 ????? 8-?
	;
	;       disk parameter block, common to all disks
	;
; DPBIBM:	DEFW    26			;sectors per track
; 	DEFB    3			;block shift factor
; 	DEFB    7			;block mask
; 	DEFB    0			;null mask
; 	DEFW    242			;disk size-1
; 	DEFW    63			;directory max
; 	DEFB    192			;alloc 0
; 	DEFB    0			;alloc 1
; 	DEFW    16			;medium not changable
; 	DEFW    2			;track offset
; 	; non-standard part (Phisical CHS infos)
; 	DEFW	26			; sectors per track
; 	DEFW	128			; sector lenght
; 	DEFB	2			; heads
; 	DEFW	77			; tracks
	;----------------------------------------------
; DPBLKHD:
; 	DEFW    32			;sectors per track
; 	DEFB    4			;block shift factor (bsh) (popcount(block size-1)-7)
; 	DEFB    15			;block mask (blm) (block size/128-1)
; 	DEFB    0			;null mask (exm)
; 	DEFW    2047			;disk size-1 (DEFSm)
; 	DEFW    255			;directory max (drm)
; 	DEFB    240			;alloc 0 (al01 high)
; 	DEFB    0			;alloc 1 (al01 low)
; 	DEFW    0			;because medium not changable with z80sim!
; 	DEFW    0			;track offset
; 	; non-standard part (Phisical CHS infos)
; 	DEFW	0			; sectors per track
; 	DEFW	0			; sector lenght
; 	DEFB	0			; heads
; 	DEFW	0			; tracks
	;----------------------------------------------
	; Native size (128 * 17 * 40) disk format DPB (but double side)
; DPBNSS:	DEFW    17			; sectors per track (DAC1)
; 	DEFB    3			; block shift factor
; 	DEFB    7			; block mask
; 	DEFB    0			; null mask
; 	DEFW    160			; disk size-1
; 	DEFW    63			; directory max
; 	DEFB    192			; alloc 0
; 	DEFB    0			; alloc 1
; 	DEFW    16			; medium changable
; 	DEFW    4			; track offset (DACF)
; 	; non-standard part (Phisical CHS infos)
; 	DEFW	17			; sectors per track
; 	DEFW	128			; sector lenght
; 	DEFB	2			; heads
; 	DEFW	40			; tracks
	;----------------------------------------------
	; Native size ported to 3,5" 80 track double side drive
	; (128 * 17 * 80)
DPBNDS:	DEFW    17			; sectors per track (DAB2)
	DEFB    4			; block shift factor
	DEFB    15			; block mask
	DEFB    0			; null mask
	DEFW    164			; disk size-1
	DEFW    127			; directory max
	DEFB    240			; alloc 0
	DEFB    0			; alloc 1
	DEFW    32			; medium changable
	DEFW    4			; track offset (DAC0)
	; non-standard part (Phisical CHS infos)
	DEFW	17			; sectors per track
	DEFW	128			; sector lenght
	DEFB	2			; heads
	DEFW	80			; tracks
	;----------------------------------------------
	;
PHYPRM:	DEFW	0			; sectors per track 	(0)
	DEFW	0			; sector lenght		(2)
	DEFB	0			; heads			(4)
	DEFW	0			; tracks		(5)
	;
SIGNON:	DEFB	CR,LF,LF
	DEFB	'Z80DarkStar '
	DEFB	'60'			;MEMORY SIZE FILLED BY RELOCATOR (one day...)
	DEFB	'k CP/M vers '
	DEFB	VERS/10+'0','.',VERS MOD 10+'0',CR,LF
	DEFB	'(c) 2006 P. Betti <pbetti@lpconsul.net>'
	DEFB	CR,LF+$80
BFAILMSG:
	DEFB	CR,LF,"CP/M BOOT FAILURE !",CR,LF+$80
	;
	;	end of fixed tables
	;
	;	individual subroutines to perform each function
	;       simplest case is to just perform parameter initialization
	;
CBBOOT:
	LD      SP,$80			; use space below buffer for stack
        LD      A,IOBVAL		; init i/o byte
	LD	(IOBYTE),A		; clear the iobyte
	LD	HL, SIGNON		; print signon message
	CALL	CONSTR
	; current drive is already logged by the monitor
	LD	A,(BOTDSK)		; check boot drive
	CP	$FF			; if $FF we are at first bootstrap
	JR	NZ,BOTOK		; boot drive already registered
	LD	A,(CDISK)		; otherwise CDISK is real boot drive
	LD	(BOTDSK),A		; register drive
BOTOK:	LD	(CDISK),A		; re-log boot drive
	XOR	A
	LD	(DSELBF),A		; resets drive command buffer
	JR	GOCPM			; initialize and go to cp/m
	;
	;       simplest case is to read the disk until all sectors loaded
	;
WBOOT:	DI				; stop interrupts
	XOR	A
	LD	(DSELBF),A		; resets drive command buffer
	LD	IX,PHYPRM		; IX point to current CHS info
	LD	SP, $0080
	LD	A,(BOTDSK)		; re-log boot drive
	LD	C, A			; current drive
	CALL	SELDSK
	;
	LD	E,(IX+2)		; sec. size in DE
	LD	D,(IX+3)
	LD	BC,CPMSIZ		; CP/M size in BC
	CALL	DIV16			; div cpmsize/secsize
	LD	D,C			; # SECTORS in D
	INC	D			; pad
	;
	LD	BC, 0			; START TRACK
	CALL	BSETTRK
	CALL	SETSID			; side 0 select
	LD      E,2			; START SECTOR
	LD	HL,CCP			; HL = base offset
	;       load the next sector
LSECT:	CALL	OFFCAL
	LD	A,(FRDPBUF+1)		; high order byte of dma in A
	CP	BIOHBY			; since read is out-of-order we discard
	JP	P,CONT			; sectors overwriting BIOS area
	PUSH	HL
	CALL	CBREAD			; perform i/o
	POP	HL
	JR	NZ, BOOTFAIL
	;
CONT:	DEC     D			; sects=sects-1
	JR      Z,GOCPM			; Jump to CCP at the end
	;       more sectors to load
NEXTOP:
	INC     E			; sector = sector + 1
	LD      A,E
	DEC	A
	CP      (IX+0)			; last sector of track ?
	JR      C,LSECT			; no, go read another
	;
	;       end of track, increment to next track
	;
	LD	BC,(FTRKBUF)		; track = track + 1
	INC	BC
	LD	(FTRKBUF),BC
	LD      E,1			; sector = 1
	JR      LSECT			; for another group
BOOTFAIL:
	LD	HL, BFAILMSG
	CALL	CONSTR
	JR	WBOOT
	;	end of load operation, set parameters and go to cp/m
GOCPM:
	LD	A,$C3			;c3 is a jmp instruction
	LD	($0000),A		;for jmp to wboot
	LD	HL,WBOOTE		;wboot entry point
	LD	($0001),HL		;set address field for jmp at 0
;
	LD	($0005),A		;for jmp to bdos
	LD	HL,BDOS			;bdos entry point
	LD	($0006),HL		;address field of jump at 5 to bdos
;
	LD	BC,$80			;default dma address is 80h
	CALL	JSETDM
;
	LD	A,$C9			; c9 is a ret
	LD	($0038),A		; placed to take care of IM1
;
;	EI				;enable the interrupt system
	LD	A,(CDISK)		;get current disk number
	LD	C,A			;send to the ccp
	JP      CCP			;go to cp/m for further processing

	;	i/o drivers for the disk follow
	;
	;       move to the track 00 position of current drive
	;	translate this call into a JSETTR call with parameter 00
	;
HOME:	LD	A,(FDRVBUF)
	CP	2			; is floppy ?
	JP	M,HOMFLO		; yes
	LD      BC,0			; ELSE select track 0
	JP      JSETTR			; we will move to 00 on first read/write
HOMFLO:	CALL	DRVSEL			; drive activation
	JP	JHOME			; send cmd.
	;
	;       select disk given by register C
	;
SELDSK:
	LD      HL,0           	 	;error return code
	LD	A,C
	CP	16			;must be between 0 and 15
	RET	NC			;no carry if 4,5,...
	CP	2			; is floppy ?
	JP	M,SELFLP		; yes
	CP	14			; is hard disk ?
	JP	M,SELHDD		; yes
	JR	SELVRT			; then is a virtual drive
	;	disk number is in the proper range
	;	compute proper disk parameter header address
SELACT:
	LD	L,A			;L=disk number 0,1,2,3
	CALL	BSELDSK
	ADD	HL,HL			;*2
	ADD	HL,HL			;*4
	ADD	HL,HL			;*8
	ADD	HL,HL			;*16 (size of each header)
;	LD	DE,DPBASE
	ADD	HL,DE			;HL=.dpbase(diskno*16)
	; update PHYPRM vector
	PUSH	HL			;
	PUSH	BC			;
	LD	DE,10			;
	ADD	HL,DE			; move HL to DPT vector address
	LD	E,(HL)			; load address in DE
	INC	HL
	LD	D,(HL)
	EX	DE,HL			; move address in HL
	LD	DE,PHYOFF
	ADD	HL,DE			; phy. info in HL
	LD	DE,PHYPRM		; current phy. vector in DE
	LD	BC,PHYLEN		; size in BC
	LDIR				; copy
	POP	BC
	POP	HL
	LD	E,0			; read cp/m 2.2 manual...
	RET
SELFLP:	LD	DE,DPBASE		; A,B are real floppies with paramters in
	JR	SELACT			; DPBASE
SELHDD:	RET				; HDD selection invalid for now
SELVRT:	LD	DE,DPBVRT		; virtual drive are a floppy (ibm-3740) + an hdd
	SUB	14			; correct offset
	JR	SELACT			;
	;
	;       set track given by register bc
	;
; JSETTR: JP	JSETTR
	;
	;       set sector given by register c
	;
; JSETSE: JP	JSETSE
	;
	;       translate the sector given by BC using the
	;       translate table given by DE
	;
SECTRAN:
	EX      DE,HL			;HL=.trans
	ADD     HL,BC			;HL=.trans(sector)
	LD      L,(HL)			;L = trans(sector)
	LD      H,0			;HL= trans(sector)
	RET				;with value in HL

TIME:
	LD	HL,RTCBUF
	RET

RTCBUF:	DEFB 0,0,0,0,0
	;
	;       set dma address given by registers b and c
	;
; JSETDM: JP	JSETDM
	;
	;       perform read operation
	;
CBREAD:
	PUSH	IX
	LD	IX,PHYPRM		; IX point to current CHS info
	LD	A,(FDRVBUF)		; get active drive
	CP	2			; is floppy ?
	JP	M,RDFLO			; yes
	CP	14			; is hard disk ?
	JP	M,RDVRT			; yes (fake call: HDD aren't implemented yet)
	JR	RDVRT			; then is a virtual drive
	;
RDFLO:	CALL	CHKSID			; side select
	CALL	DRVSEL			; activate driver
	CALL	JREAD			; do read
	POP	IX
	RET
	;
RDVRT:	CALL	VDSKRD			; call par. read
	POP	IX
	BIT	0,A			; adjust Z flag for error test
	RET
	;
	;       perform a write operation
	;
WRITE:
	PUSH	IX
	LD	IX,PHYPRM		; IX point to current CHS info
	LD	A,(FDRVBUF)		; get active drive
	CP	2			; is floppy ?
	JP	M,WRFLO			; yes
	CP	14			; is hard disk ?
	JP	M,WRVRT			; yes (fake call: HDD aren't implemented yet)
	JP	WRVRT			; then is a virtual drive
	;
WRFLO:	CALL	CHKSID			; side select
	CALL	DRVSEL			; activate drive
	CALL	JWRITE			; do write
	POP	IX
	RET
	;
WRVRT:	CALL	VDSKWR			; call par. write
	POP	IX
	BIT	0,A			; adjust Z flag for error test
	RET
	;
	;	test for side switch on floppies
	;
CHKSID:	LD	IX,PHYPRM		; CHS infos
	LD	C,0			; side 0 by default
	LD	A,(FTRKBUF)		; get just the 8 bit part because we don't
					; have drivers with more than 255 tracks !!!
	CP	(IX+5)			; compare with physical (8 bit)
	JP	M,SETSID		; track in range (0-39/0-79) ?
	LD	C,1			; no: side one
	SUB	(IX+5)			; real cylinder on side 1
	LD	(FTRKBUF),A		; store for i/o ops
	JP	SETSID			; ... and go to SETSID
	;
	;	scratch ram area for BDOS use
	;
BEGDAT	EQU	$		; beginning of data area
;
DIRBF:  DEFS    128		; scratch directory area
ALL00:  DEFS    22		; allocation vector 0
ALL01:  DEFS    22		; allocation vector 1
ALL02:  DEFS    31		; allocation vector 2
ALL03:  DEFS    31		; allocation vector 3
CHK00:  DEFS    32		; check vector 0
CHK01:  DEFS    32		; check vector 1
CHK02:  DEFS    16		; check vector 2
CHK03:  DEFS    16		; check vector 3
;
ENDDAT	EQU	$		; end of data area
DATSIZ	EQU	$ - BEGDAT

; symbols...
wsym bios.sym

	END
;