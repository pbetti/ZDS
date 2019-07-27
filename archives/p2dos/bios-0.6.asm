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
PHYLEN	EQU	10		; size of CHS vector
HSTBSZ	EQU	512		; MAX host disk sector size (for us...)
	;
	;*****************************************************
	;*                                                   *
	;*        BDOS constants on entry to write           *
	;*                                                   *
	;*****************************************************
WRALL	EQU	0		;write to allocated
WRDIR	EQU	1		;write to directory
WRUAL	EQU	2		;write to unallocated
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
	JP      SETTRK		; JSETTR   - set track number
	JP      SETSEC		; JSETSE   - set sector number
	JP      SETDMA		; JSETDM   - set dma address
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
	;	fixed data tables for Z80DarkStar floppies A-B),
	;	hard disks (C-N), virtual drives (O-P)
	;
	;	disk parameter header for disk 00
DPBASE:	DEFW	TRANS, 0000
	DEFW	0000,  0000
	DEFW	DIRBF,DPBNDS
	DEFW	CHK00,ALL00
	;	disk parameter header for disk 01
	DEFW	TRANS, 0000
	DEFW	0000,  0000
	DEFW	DIRBF,DPBNDS
	DEFW	CHK01,ALL01
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
	;	sector translate vectors
	;
; TRIBM:	DEFB	1,7,13,19	;sectors 1,2,3,4
; 	DEFB	25,5,11,17	;sectors 5,6,7,8
; 	DEFB	23,3,9,15	;sectors 9,10,11,12
; 	DEFB	21,2,8,14	;sectors 13,14,15,16
; 	DEFB	20,26,6,12	;sectors 17,18,19,20
; 	DEFB	18,24,4,10	;sectors 21,22,23,24
; 	DEFB	16,22		;sectors 25,26
	; sector translation table 128 (skew = 6)
; TR128:	DEFB	1,7,13,19	;sectors 1,2,3,4
; 	DEFB	25,31,5,11	;sectors 5,6,7,8
; 	DEFB	17,23,29,3	;sectors 9,10,11,12
; 	DEFB	9,15,21,27	;sectors 13,14,15,16
; 	DEFB	2,8,14,20	;sectors 17,18,19,20
; 	DEFB	26,32,6,12	;sectors 21,22,23,24
; 	DEFB	18,24,30,4	;sectors 25,26,27,28
; 	DEFB	10,16,22,28	;sectors 29,30,31,32
; 	; native sector translation table (skew = 6)
; TRANS:	DEFB	$01,$07,$0D,$02 	; sectors 1,2,3,4
; 	DEFB	$08,$0E,$03,$09 	; sectors 5,6,7,8
; 	DEFB	$0F,$04,$0A,$10		; sectors 9,10,11,12
; 	DEFB	$05,$0B,$11,$06		; sectors 13,14,15,16
; 	DEFB	$0C			; sector 17
	; sector translation table for 512 bytes/11 sec. track (skew = 4)
TRANS:	DEFB	1,5,9,2 		; sectors 1,2,3,4
	DEFB	6,10,3,7	 	; sectors 5,6,7,8
	DEFB	11,4,8			; sectors 9,10,11
; 	; 256 byte/sec. native sector translation table (skew = 6)
; TRA10:	DEFB	1,7		 	; sector 1,2
; 	DEFB	3,9		 	; sector 3,4
; 	DEFB	5,2		 	; sector 5,6
; 	DEFB	8,4		 	; sector 7,8
; 	DEFB	10,6		 	; sector 9,10
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
; 	DEFB	0			; deblock shift
; 	DEFB	0			; deblock mask
; 	DEFB	0			; 128 byte sectors per block
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
;	DEFB	0			; deblock shift
;	DEFB	0			; deblock mask
;	DEFB	0			; 128 byte sectors per block
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
;	DEFB	0			; deblock shift
;	DEFB	0			; deblock mask
;	DEFB	0			; 128 byte sectors per block
; 	;----------------------------------------------
; 	; Native size ported to 3,5" 80 track double side drive
; 	; (128 * 17 * 80)
; DPBNDS:	DEFW    17			; sectors per track (DAB2)
; 	DEFB    4			; block shift factor
; 	DEFB    15			; block mask
; 	DEFB    0			; null mask
; 	DEFW    164			; disk size-1
; 	DEFW    127			; directory max
; 	DEFB    192			; alloc 0
; 	DEFB    0			; alloc 1
; 	DEFW    32			; medium changable
; 	DEFW    4			; track offset (DAC0)
; 	; non-standard part (Phisical CHS infos)
; 	DEFW	17			; sectors per track
; 	DEFW	128			; sector lenght
; 	DEFB	2			; heads
; 	DEFW	80			; tracks
; 	DEFB	0			; deblock shift
; 	DEFB	0			; deblock mask
; 	DEFB	16			; 128 byte sectors per block
; 	;----------------------------------------------
; 	; Native size ported to 3,5" 80 track double side drive
; 	; (128 * 32 * 160)
; DPB128:	DEFW    32			; sectors per track (DAB2)
; 	DEFB    4			; block shift factor
; 	DEFB    15			; block mask
; 	DEFB    0			; null mask
; 	DEFW    313			; disk size-1
; 	DEFW    127			; directory max
; 	DEFB    192			; alloc 0
; 	DEFB    0			; alloc 1
; 	DEFW    32			; medium changable
; 	DEFW    3			; track offset (DAC0)
; 	; non-standard part (Phisical CHS infos)
; 	DEFW	32			; sectors per track
; 	DEFW	128			; sector lenght
; 	DEFB	2			; heads
; 	DEFW	80			; tracks
; 	DEFB	0			; deblock shift
; 	DEFB	0			; deblock mask
; 	DEFB	16			; 128 byte sectors per block
	;----------------------------------------------
	; Ultimate size 11 * 512 * 160
DPBNDS:	DEFW    44			; sectors per track (DAB2)
	DEFB    4			; block shift factor
	DEFB    15			; block mask
	DEFB    0			; null mask
	DEFW    433			; disk size-1
	DEFW    127			; directory max
	DEFB    192			; alloc 0
	DEFB    0			; alloc 1
	DEFW    32			; medium changable
	DEFW    2			; track offset (DAC0)
	; non-standard part (Phisical CHS infos)
	DEFW	11			; sectors per track
	DEFW	512			; sector lenght
	DEFB	2			; heads
	DEFW	80			; tracks
	DEFB	2			; deblock shift
	DEFB	3			; deblock mask
	DEFB	16			; 128 byte sectors per block
; 	;----------------------------------------------
; 	; Native size ported to 3,5" 80 track double side drive
; 	; (256 * 10 * 80)
; DPBND2:	DEFW    20			; sectors per track (10 -> 256/20 -> 128)
; 	DEFB    4			; block shift factor
; 	DEFB    15			; block mask
; 	DEFB    0			; null mask
; 	DEFW    195			; disk size-1
; 	DEFW    127			; directory max
; 	DEFB    192			; alloc 0
; 	DEFB    0			; alloc 1
; 	DEFW    32			; medium changable
; 	DEFW    3			; track offset (DAC0)
; 	; non-standard part (Phisical CHS infos)
; 	DEFW	10			; sectors per track
; 	DEFW	256			; sector lenght
; 	DEFB	2			; heads
; 	DEFW	80			; tracks
; 	DEFB	1			; deblock shift
; 	DEFB	1			; deblock mask
; 	DEFB	16			; 128 byte sectors per block
	;----------------------------------------------
	;
PHYPRM:	DEFW	0			; sectors per track 	(0)
	DEFW	0			; sector lenght		(2)
	DEFB	0			; heads			(4)
	DEFW	0			; tracks		(5)
	DEFB	0			; deblock shift		(7)
	DEFB	0			; deblock mask		(8)
	DEFB	0			; sectors per block	(9)
PHYSPT:	DEFB	0			; CP/M SPT		(PHYLEN)
					; CP/M SPT must be at PHYLEN !!
PHYDPT:	DEFW	0			; current DPT address	(PHYLEN+1)
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
	XOR	A
	LD	(HSTACT),A		; invalidate deblock buffer
	LD	(UNACNT),A		; clear unalloc count
	LD	(NOPROW),A		; clear pre-read
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
	LD	(HSTACT),A		; invalidate deblock buffer
	LD	(UNACNT),A		; clear unalloc count
	LD	(NOPROW),A		; clear pre-read
	LD	(DSELBF),A		; resets drive command buffer
	LD	IX,PHYPRM		; IX point to current CHS info
	LD	SP, $0080
	LD	A,(BOTDSK)		; re-log boot drive
	LD	C, A			; current drive
	CALL	BSELDSK			; ensure physical selection
	CALL	SELDSK			; ... and logical
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
	CALL	DREADH			; perform i/o
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
	LD	A,$C3			; c3 is a jmp instruction
	LD	($0000),A		; for jmp to wboot
	LD	HL,WBOOTE		; wboot entry point
	LD	($0001),HL		; set address field for jmp at 0
;
	LD	($0005),A		; for jmp to bdos
	LD	HL,BDOS			; bdos entry point
	LD	($0006),HL		; address field of jump at 5 to bdos
;
	LD	BC,$80			; default dma address is 80h
	CALL	JSETDM
;
	LD	A,$C9			; c9 is a ret
	LD	($0038),A		; placed to take care of IM1
;
;	EI				; enable the interrupt system
	LD	A,(CDISK)		; get current disk number
	LD	C,A			; send to the ccp
	JP      CCP			; go to cp/m for further processing

	;
	; RTC  fake handler routine
	;
TIME:
	LD	HL,RTCBUF
	RET

RTCBUF:	DEFB 0,0,0,0,0

	;----------------------------------------------------------------------
	;
	;	i/o drivers for the disk follow
	;
	;----------------------------------------------------------------------
	;
	;       move to the track 00 current drive
	;
HOME:	;CALL	SYNCHS			; deblock sync/invalidate
	LD	A,(HSTWRT)		; check for pending write
	OR	A
	RET	NZ
	LD	(HSTACT),A		; clear host active flag
	LD	A,(SEKDSK)		; UNLESS is a real floppy
	CP	2			; is floppy ?
	RET	NC			; no
HOMFLO:	LD	(FDRVBUF),A		; HW
	CALL	DRVSEL			; drive activation
 	JP	BHOME			; send cmd.
	;
	;       select disk given by register C
	;
SELDSK:
	XOR	A			; use deblock by default
	LD	(HASNOD),A		; ...
	LD	A,C			; disk id on A
	LD	(SEKDSK),A		; set seek disk number
	LD      HL,0           	 	; error return code
	LD	A,C
	CP	16			; must be between 0 and 15
	RET	NC			; no carry if 4,5,...
	CP	2			; is floppy ?
	JP	C,SELFLP		; yes
	CP	14			; is hard disk ?
	JP	C,SELHDD		; yes
	JP	SELVRT			; then is a virtual drive
	;	disk number is in the proper range
	;	compute proper disk parameter header address
SELACT:
	LD	L,A			; L=disk number 0,1,2,3
; 	LD	A,C			; restore real disk id on A
; 	LD	(SEKDSK),A		; set seek disk number
	ADD	HL,HL			; *2
	ADD	HL,HL			; *4
	ADD	HL,HL			; *8
	ADD	HL,HL			; *16 (size of each header)
	ADD	HL,DE			; HL=.dpbase(diskno*16)
	; update PHYPRM vector
	PUSH	HL			;
	PUSH	BC			;
	LD	(PHYDPT),HL		; store DPT addr. for BIOS usage
	LD	DE,10			;
	ADD	HL,DE			; move HL to DPT vector address
	LD	E,(HL)			; load address in DE
	INC	HL
	LD	D,(HL)
	EX	DE,HL			; move DPT address in HL
	LD	A,(HL)			; get CP/M SPT
	LD	(PHYSPT),A		; store at the end of PHYPRM
	LD	DE,PHYOFF		; go on
	ADD	HL,DE			; phy. info in HL
	LD	DE,PHYPRM		; current phy. vector in DE
	LD	BC,PHYLEN		; size in BC
	LDIR				; copy
	LD	A,(PHYPRM+2)		; sec. len. in A
	CP	128			; need deblock ?
	JR	NZ,SELNDB		; yes: not a 128 bytes sector
	LD	A,1
	LD	(HASNOD),A		; disable deblock
	LD	BC,(SEKDSK)
	CALL	BSELDSK			; no: so set immediate
SELNDB:	POP	BC
	POP	HL
	LD	E,0			; read cp/m 2.2 manual...
	RET
SELFLP:	LD	DE,DPBASE		; A,B are real floppies with paramters in
	JP	SELACT			; DPBASE
SELHDD:	RET				; HDD selection invalid for now
SELVRT:	LD	DE,DPBVRT		; virtual drive are a floppy (ibm-3740) + an hdd
	SUB	14			; correct offset
	JP	SELACT			;
	;
	;       track, sector, dma selection
	;
SETTRK:
	;set track given by registers BC
	LD	(SEKTRK),BC		; track to seek
	LD	A,(HASNOD)		; no deblock. ?
	OR	A
	RET	Z
	JP	BSETTRK
;
SETSEC:
	;set sector given by register c
	LD	A,C
	LD	(SEKSEC),A		; sector to seek
	LD	A,(HASNOD)		; no deblock. ?
	OR	A
	RET	Z
	LD	A,C
	LD	(HSTLGS),A		; sector to seek (log.)
	RET
;
SETDMA:
	;set dma address given by BC
	LD	(DMAADR),BC
	LD	A,(HASNOD)		; no deblock. ?
	OR	A
	RET	Z
	JP	BSETDMA
	;       translate the sector given by BC using the
	;       translate table given by DE
	;	(logical untraslated)
SECTRAN:
	LD      H,B			;H = B
	LD      L,C			;HL= BC
	RET				;with value in HL
	;	(physical translated)
PHYSTR:
	PUSH	IX
	LD	IX,(PHYDPT)		; IX = DPT
	LD	L,(IX+0)
	LD	H,(IX+1)		; HL = trans tab
	LD	A,(HSTLGS)
	LD	C,A
	LD	B,0
	ADD     HL,BC			; HL = trans sec offset
	LD      L,(HL)
	LD      H,0			; HL = trans(sector)
	LD	(FSECBUF),HL
	POP	IX
	RET				; with value in HL
	;
	;       perform physical read operation
	;
READHST:
 	CALL	PHYSTR
DREADH:	PUSH	IX
	LD	IX,PHYPRM		; IX point to current CHS info
	LD	A,(FDRVBUF)		; get active drive
	CP	2			; is floppy ?
	JR	C,RDFLO			; yes
	CP	14			; is hard disk ?
	JR	C,RDVRT			; yes (fake call: HDD aren't implemented yet)
	JR	RDVRT			; then is a virtual drive
	;
RDFLO:	CALL	CHKSID			; side select
	CALL	DRVSEL			; activate driver
	CALL	BREAD			; do read
	LD	(ERFLAG),A		; store error status
	POP	IX
	RET
	;
RDVRT:	CALL	VDSKRD			; call par. read
	BIT	0,A			; adjust Z flag for error test
	LD	(ERFLAG),A		; store error status
	POP	IX
	RET
	;
	;       perform a physical write operation
	;
WRITEHST:
 	CALL	PHYSTR
DWRITH:	PUSH	IX
	LD	IX,PHYPRM		; IX point to current CHS info
	LD	A,(FDRVBUF)		; get active drive
	CP	2			; is floppy ?
	JR	C,WRFLO			; yes
	CP	14			; is hard disk ?
	JR	C,WRVRT			; yes (fake call: HDD aren't implemented yet)
	JR	WRVRT			; then is a virtual drive
	;
WRFLO:	CALL	CHKSID			; side select
	CALL	DRVSEL			; activate drive
	CALL	BWRITE			; do write
	LD	(ERFLAG),A		; store error status
	POP	IX
	RET
	;
WRVRT:	CALL	VDSKWR			; call par. write
	BIT	0,A			; adjust Z flag for error test
	LD	(ERFLAG),A		; store error status
	POP	IX
	RET
	;
	;	test for side switch on floppies
	;
CHKSID:	LD	IX,PHYPRM		; CHS infos
	LD	C,0			; side 0 by default
	LD	A,(FTRKBUF)		; get just the 8 bit part because we don't
					; have drivers with more than 255 tracks !!!
	CP	(IX+5)			; compare with physical (8 bit)
	JP	C,SETSID		; track in range (0-39/0-79) ?
	LD	C,1			; no: side one
	SUB	(IX+5)			; real cylinder on side 1
	LD	(FTRKBUF),A		; store for i/o ops
	JP	SETSID			; ... and go to SETSID
;
;*****************************************************
;*                                                   *
;*	The READ entry point takes the place of      *
;*	the previous BIOS defintion for READ.        *
;*                                                   *
;*****************************************************

CBREAD:
	;read the selected CP/M sector
	XOR	A
	LD	(ERFLAG),A		; clear errors
	LD	(UNACNT),A		; and unalloc count
	INC	A
	LD	(IOFLAG),A		; set read operation
	LD	A,(HASNOD)		; no deblock. ?
	OR	A
	JP	NZ,READHST
	LD	A,WRUAL			; clear BDWTYP flag
	LD	(BDWTYP),A
	JP	RWOPER			; to perform the read
;
;*****************************************************
;*                                                   *
;*	The WRITE entry point takes the place of     *
;*	the previous BIOS defintion for WRITE.       *
;*                                                   *
;*****************************************************
WRITE:
;	write the selected CP/M sector
	XOR	A
	LD	(ERFLAG),A		; clear errors
	LD	(IOFLAG),A		; set write operation
	LD	A,(HASNOD)		; no deblock. ?
	OR	A
	JP	NZ,WRITEHST
	LD	A,C			; save write type
	LD	(BDWTYP),A
	CP	WRUAL			; write unallocated?
	JP	NZ,CHKUNA		; no: but check for unalloc
;	write to unallocated, set parameters
	LD	A,(PHYPRM+9)		; next unalloc recs
	LD	(UNACNT),A
	LD	A,(SEKDSK)		; disk to seek
	LD	(UNADSK),A		; unadsk = sekdsk
	LD	HL,(SEKTRK)
	LD	(UNATRK),HL		; unatrk = sectrk
	LD	A,(SEKSEC)
	LD	(UNASEC),A		; unasec = seksec
CHKUNA:	;check for write to unallocated sector
	LD	A,(UNACNT)		; any unalloc remain?
	OR	A
	JP	Z,ALLOC			; skip if not
;	more unallocated records remain
	DEC	A			; unacnt = unacnt-1
	LD	(UNACNT),A
	LD	A,(SEKDSK)		; same disk?
	LD	HL,UNADSK
	CP	(HL)			; sekdsk = unadsk?
	JP	NZ,ALLOC		; skip if not
;	disks are the same
	LD	HL,(UNATRK)
	LD	BC,(SEKTRK)
	CALL	DIFF16			; sektrk = unatrk?
	JP	NZ,ALLOC		; skip if not
;	tracks are the same
	LD	A,(SEKSEC)		; same sector?
	LD	HL,UNASEC
	CP	(HL)			; seksec = unasec?
	JP	NZ,ALLOC		; skip if not
;	match, move to next sector for future ref
	INC	(HL)			; unasec = unasec+1
	LD	A,(PHYSPT)		; CP/M SPT
	LD	B,A
	LD	A,(HL)			; end of track?
	CP	B			; count CP/M sectors
	JR	C,NOOVF			; skip if no overflow;
;	overflow to next track
	LD	(HL),0			; unasec = 0
	LD	HL,(UNATRK)
	INC	HL
	LD	(UNATRK),HL		; unatrk = unatrk+1;
NOOVF:	;match found, mark as unnecessary read
	LD	A,1
	LD	(NOPROW),A		; NOPROW = 1
	JR	RWOPER			; to perform the write;
ALLOC:
	;not an unallocated record, requires pre-read
	XOR	A			; 0 to accum
	LD	(UNACNT),A		; unacnt = 0
	LD	(NOPROW),A		; NOPROW = 0
;
;*****************************************************
;*                                                   *
;*	Common code for READ and WRITE follows       *
;*                                                   *
;*****************************************************
RWOPER:
	;enter here to perform the read/write
	LD	A,(PHYPRM+7)		; load shifts #
	LD	B,A
	LD	A,(SEKSEC)		; compute host sector
RWOSHF:	OR	A			; carry = 0
	RRA				; shift right
	DJNZ	RWOSHF
	LD	(SEKHST),A		; host sector to seek
	LD	HL,HSTACT		; host active flag
	LD	A,(HL)
	LD	(HL),1			; now valid
	OR	A			; was it already?
	JR	Z,HSTRDD		; no: need to load
;	host buffer active, same as seek buffer?
	LD	A,(SEKDSK)
	LD	HL,FDRVBUF		; same disk?
	CP	(HL)			; sekdsk = hstdsk?
	JR	NZ,HSTLOA
;	same disk, same track?
	LD	HL,(FTRKBUF)
	LD	BC,(SEKTRK)
	CALL	DIFF16			; sektrk = hsttrk?
	JR	NZ,HSTLOA
;	same disk, same track: same buffer too ?
	LD	A,(SEKHST)
	LD	HL,HSTLGS		; sekhst = hstsec?
	CP	(HL)
	JR	Z,HSTFUL		; yes: no need to load
HSTLOA:	CALL	SYNPND			; write pending ?
HSTRDD:	LD	A,(NOPROW)		; no pre-read on write ?
	OR	A
	JR	NZ,HSTSYN		; skip pre-read
	CALL	RHSTFI			; fill buffer
	JR	HSTFUL			; normal way...
HSTSYN:
	CALL	SK2HST			; sync SEK => HST
;	hst buffer good
HSTFUL:	XOR	A			; keep NOPROW clean
	LD	(NOPROW),A
	CALL	HSTRSF			; buffer transfer
	LD	A,(BDWTYP)		; writing on dir ?
	CP	WRDIR
	LD	A,(ERFLAG)		; retain error status
	RET	NZ			; normal i/o: stop here
	CALL	SYNPND			; dir. write: always in sync
	LD	A,(ERFLAG)		; re-load error status
	RET				; read done
;
WHSTFI:	LD	A,(MIOBYTE)
	RES	0,A
	JR	HSTFIL
RHSTFI:	LD	A,(MIOBYTE)
	SET	0,A
HSTFIL:
	;may have to fill the host buffer
	LD	(MIOBYTE),A
	LD	A,(MIOBYTE)		; read/write ?
	BIT	0,A
	JR	NZ,HSTFRD		; read
	LD	A,(SEKDSK)		; write
	LD	(HSTTMP),A
	LD	A,(FDRVBUF)
	LD	C,A
	CALL	SELDSK			; ENSURE correct parameters
 	LD	BC,HSTBUF		; set DMA to buffer
 	CALL	BSETDMA
	CALL	WRITEHST		; for disk write
	LD	A,(HSTTMP)
	LD	(SEKDSK),A
	LD	C,A
	CALL	SELDSK
	JR	AFTRIO
HSTFRD:	CALL	SK2HST			; sync SEK => HST
	CALL	READHST
AFTRIO:	XOR	A
	LD	(HSTWRT),A		; clear flag
 	RET
;
SK2HST:
	; update hst seek info's from local (SEKs)
	LD	BC,(SEKTRK)		; set track
	CALL	BSETTRK
	LD	A,(SEKHST)		; set sector
	LD	(HSTLGS),A
	LD	A,(SEKDSK)		; set disk
	LD	C,A
	CALL	BSELDSK
 	LD	BC,HSTBUF		; set DMA to buffer
 	CALL	BSETDMA
	RET
;
	;copy data to or from buffer
HSTRSF:
	LD	A,(PHYPRM+8)		; sec. mask
	LD	B,A
	LD	A,(SEKSEC)		; mask buffer number
	AND	B			; least signif bits
	LD	L,A			; ready to shift
	LD	H,0			; double count
	ADD	HL,HL			; shift left 7
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
;	hl has relative host buffer address
	LD	DE,HSTBUF
	ADD	HL,DE			; hl = host address
	LD	DE,(DMAADR)		; get/put CP/M data
	LD	C,128			; length of move
	LD	B,0			;
	LD	A,(IOFLAG)		; which way?
	OR	A
	JR	NZ,RWMOVE		; skip if read
;	write operation, mark and switch direction
	LD	A,1
	LD	(HSTWRT),A		; hstwrt = 1
	EX	DE,HL			; source/dest swap
RWMOVE:
	LDIR
	RET
;
SYNCHS:
	; sync buffer to disk, invalidate buffer
	XOR	A
	LD	(HSTACT),A		; invalidate buffer
SYNPND:
	LD	A,(HSTWRT)		; write pending ?
	OR	A
	RET	Z			; no
	XOR	A
	LD	(HSTWRT),A		; clear flag
	PUSH	BC			; keep clean bc
	CALL	WHSTFI			; flush buffer
	POP	BC
	RET
;
DIFF16:
	; compare for 16 bits (HL and BC)
	LD	A,C
	CP	L
	RET	NZ
	LD	A,B
	CP	H
	RET

	;
	;	scratch ram area for BIOS/BDOS usage
	;
BEGDAT	EQU	$		; beginning of data area
;*****************************************************
;*                                                   *
;*	Unitialized RAM data areas		     *
;*                                                   *
;*****************************************************
HASNOD: DEFB	0		; signal no debl. usage
HSTACT:	DEFB	0		; (in)validate data in HST buf.
ERFLAG:	DEFB	0		; disk op. errors
HSTWRT:	DEFB	0		; hst write pending
IOFLAG:	DEFB	0		; hst read/write flag
BDWTYP:	DEFB	-1		; BDOS sector write type
NOPROW:	DEFB	0		; no pre-read required
UNACNT: DEFB	0		; unallocated count
;
SEKDSK:	DEFS	1		; seek disk number
SEKTRK:	DEFS	2		; seek track number
SEKSEC:	DEFS	1		; seek sector number
UNADSK:	DEFS	1		; unallocated seek disk number
UNATRK:	DEFS	2		; unallocated seek track number
UNASEC:	DEFS	1		; unallocated seek sector number
HSTLGS:	DEFS	1		; HST logical sector #
HSTTMP:	DEFS	1		; temporary buffer
;
SEKHST:	DEFS	1		; seek shr secshf
DMAADR:	DEFS	2		; last dma address
HSTBUF:	DEFS	HSTBSZ		; host buffer
	;
	; BDOS PART
	;
DIRBF:  DEFS    128		; scratch directory area
ALL02:  DEFS    55		; allocation vector 2
ALL03:  DEFS    55		; allocation vector 3
CHK02:  DEFS    32		; check vector 2
CHK03:  DEFS    32		; check vector 3
ALL00:  DEFS    55		; allocation vector 0
ALL01:  DEFS    55		; allocation vector 1
CHK00:  DEFS    32		; check vector 0
CHK01:  DEFS    32		; check vector 1
;
ENDDAT	EQU	$		; end of data area
DATSIZ	EQU	$ - BEGDAT

	IF	ENDDAT GT $F000
	* BIOS OVERLAP MONITOR ROM !! *
	ENDIF

; symbols...
wsym bios.sym

	END
;