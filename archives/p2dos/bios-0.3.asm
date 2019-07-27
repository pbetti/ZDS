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
	;*****************************************************
	;*                                                   *
	;*         CP/M to host disk constants               *
	;*                                                   *
	;*****************************************************
BLKSIZ	EQU	2048		; CP/M allocation size
MHSTSIZ	EQU	512		; MAX host disk sector size
	;
	; following equ's should be parametric...
	;
HSTSIZ	EQU	256		; host disk sector size
HSTSPT	EQU	10		; host disk sectors/trk
HSTBLK	EQU	HSTSIZ/128	; CP/M sects/host buff
CPMSPT	EQU	HSTBLK * HSTSPT	; CP/M sectors/track
SECMSK	EQU	HSTBLK-1	; sector mask
SECSHF	EQU	1		; log2(hstblk)
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
; 	JP      JSETTR		; JSETTR   - set track number
; 	JP      JSETSE		; JSETSE   - set sector number
; 	JP      JSETDM		; JSETDM   - set dma address
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
	DEFW	TRA10, 0000
	DEFW	0000,  0000
	DEFW	DIRBF,DPBND2
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
DPBVRT:	DEFW	TRA10, 0000
	DEFW	0000,  0000
	DEFW	DIRBF,DPBND2
	DEFW	CHK02,ALL02
	;	disk parameter header for disk 01
	DEFW	TRA10, 0000
	DEFW	0000,  0000
	DEFW	DIRBF,DPBND2
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
	; 256 byte/sec. native sector translation table (skew = 6)
	; note that doubleness is for deblocking
TRA10:	DEFB	1,7		 	; sector 1,2
	DEFB	3,9		 	; sector 3,4
	DEFB	5,2		 	; sector 5,6
	DEFB	8,4		 	; sector 7,8
	DEFB	10,6		 	; sector 9,10
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
	DEFB    192			; alloc 0
	DEFB    0			; alloc 1
	DEFW    32			; medium changable
	DEFW    4			; track offset (DAC0)
	; non-standard part (Phisical CHS infos)
	DEFW	17			; sectors per track
	DEFW	128			; sector lenght
	DEFB	2			; heads
	DEFW	80			; tracks
	;----------------------------------------------
	; Native size ported to 3,5" 80 track double side drive
	; (256 * 10 * 80)
DPBND2:	DEFW    20			; sectors per track (10 -> 256/20 -> 128)
	DEFB    4			; block shift factor
	DEFB    15			; block mask
	DEFB    0			; null mask
	DEFW    195			; disk size-1
	DEFW    127			; directory max
	DEFB    192			; alloc 0
	DEFB    0			; alloc 1
	DEFW    32			; medium changable
	DEFW    3			; track offset (DAC0)
	; non-standard part (Phisical CHS infos)
	DEFW	10			; sectors per track
	DEFW	256			; sector lenght
	DEFB	2			; heads
	DEFW	80			; tracks
	;----------------------------------------------
	;
PHYPRM:	DEFW	0			; sectors per track 	(0)
	DEFW	0			; sector lenght		(2)
	DEFB	0			; heads			(4)
	DEFW	0			; tracks		(5)
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
	LD	A,(BOTDSK)		; check boot drive
	CP	$FF			; if $FF we are at first bootstrap
	JR	NZ,BOTOK		; boot drive already registered
	LD	A,(CDISK)		; otherwise CDISK is real boot drive
	LD	(BOTDSK),A		; register drive
BOTOK:	LD	(CDISK),A		; re-log boot drive
	XOR	A
	LD	(DSELBF),A		; resets drive command buffer
	LD	(HSTACT),A		; invalidate deblock buffer
	LD	(UNACNT),A		;clear unalloc count
	JR	GOCPM			; initialize and go to cp/m
	;
	;       simplest case is to read the disk until all sectors loaded
	;
WBOOT:	DI				; stop interrupts
	XOR	A
	LD	(HSTACT),A		; invalidate deblock buffer
	LD	(UNACNT),A		;clear unalloc count
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
HOME:	LD	A,(HSTWRT)	;check for pending write
	OR	A
	JP	NZ,HOMED
	LD	(HSTACT),A	;clear host active flag
HOMED:	LD	A,(FDRVBUF)
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
	XOR	A			; use deblock by default
	LD	(HASNOD),A		; ...
	LD      HL,0           	 	; error return code
	LD	A,C
	CP	16			; must be between 0 and 15
	RET	NC			; no carry if 4,5,...
	CP	2			; is floppy ?
	JP	M,SELFLP		; yes
	CP	14			; is hard disk ?
	JP	M,SELHDD		; yes
	JR	SELVRT			; then is a virtual drive
	;	disk number is in the proper range
	;	compute proper disk parameter header address
SELACT:
	LD	L,A			; L=disk number 0,1,2,3
	CALL	BSELDSK
	LD	(SEKDSK),A		; seek disk number
	ADD	HL,HL			; *2
	ADD	HL,HL			; *4
	ADD	HL,HL			; *8
	ADD	HL,HL			; *16 (size of each header)
;	LD	DE,DPBASE
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
SELVRT: ;LD	A,1			; don't use deblock
	;LD	(HASNOD),A		;
	;LD	A,C			; reload drive num on A
	LD	DE,DPBVRT		; virtual drive are a floppy (ibm-3740) + an hdd
	SUB	14			; correct offset
	JR	SELACT			;
	;
	;       track, sector, dma selection
	;
SETTRK:
	;set track given by registers BC
	LD	(SEKTRK),BC		; track to seek
	LD	A,(HASNOD)		; no deblock. ?
	OR	A
	JP	NZ,BSETTRK
	RET
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
;;
SETDMA:
	;set dma address given by BC
	LD	(DMAADR),BC
	LD	A,(HASNOD)		; no deblock. ?
	OR	A
	RET	Z
	JP	BSETDMA
	;       translate the sector given by BC using the
	;       translate table given by DE
	;
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
	; !!! JUST FOR DEBUG ----------------------------------
SHRIO:	;RET
	PUSH	HL
	PUSH	BC
	LD	C,A
	CALL	BCONOUT
	LD	C,':'
	CALL	BCONOUT
	LD	C,'R'
	CALL	BCONOUT
	LD	C,':'
	CALL	BCONOUT
	LD	HL,(FSECBUF)
	LD	A,L
	CALL	H2AJ1
	LD	C,','
	CALL	BCONOUT
	LD	HL,(FTRKBUF)
	LD	A,L
	CALL	H2AJ1
	LD	C,','
	CALL	BCONOUT
	LD	HL,(FRDPBUF)
	CALL	H2AEN1
	CALL	OUTCRLF
;  	call	bconin
	POP	BC
	POP	HL
	RET
SHBIO:	;RET
	PUSH	HL
	PUSH	BC
	LD	C,A
	CALL	BCONOUT
	LD	C,':'
	CALL	BCONOUT
	LD	C,'B'
	CALL	BCONOUT
	LD	C,':'
	CALL	BCONOUT
	LD	HL,(SEKSEC)
	LD	A,L
	CALL	H2AJ1
	LD	C,','
	CALL	BCONOUT
	LD	HL,(SEKTRK)
	LD	A,L
	CALL	H2AJ1
	LD	C,','
	CALL	BCONOUT
	LD	HL,(DMAADR)
	CALL	H2AEN1
	CALL	OUTCRLF
; 	CALL	bconin
	POP	BC
	POP	HL
	RET

	; !!! JUST FOR DEBUG [END]----------------------------------
	;
	;       perform physical read operation
	;
READHST:
	;; DEBUG
	LD	A,(FDRVBUF)
	CP	15
	JR	NZ,RRD1
	LD	A,'R'
	CALL	SHRIO
	;; DEBUG
	;hstdsk = host disk #, hsttrk = host track #,
	;hstsec = host sect #. read "hstsiz" bytes
	;into hstbuf and return error flag in erflag.
RRD1: 	CALL	PHYSTR
DREADH:	PUSH	IX
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
	LD	(ERFLAG),A
	POP	IX
	RET
	;
RDVRT:	CALL	VDSKRD			; call par. read
	LD	(ERFLAG),A
	POP	IX
	BIT	0,A			; adjust Z flag for error test
	RET
	;
	;       perform a physical write operation
	;
WRITEHST:
	;; DEBUG
	LD	A,'W'
	CALL	SHRIO
	;; DEBUG
 	CALL	PHYSTR
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
	LD	(ERFLAG),A
	POP	IX
	RET
	;
WRVRT:	CALL	VDSKWR			; call par. write
	LD	(ERFLAG),A
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
;*****************************************************
;*                                                   *
;*	The READ entry point takes the place of      *
;*	the previous BIOS defintion for READ.        *
;*                                                   *
;*****************************************************
CBREAD:
	;; DEBUG
	LD	A,(FDRVBUF)
	CP	15
	JR	NZ,RD1
	LD	A,'R'
	CALL	SHBIO
	;; DEBUG
	;read the selected CP/M sector
RD1:	LD	A,(HASNOD)		; no deblock. ?
	OR	A
	JP	NZ,READHST
	XOR	A
	LD	(UNACNT),A
	LD	A,1
	LD	(READOP),A	;read operation
	LD	(RSFLAG),A	;must read data
	LD	A,WRUAL
	LD	(WRTYPE),A	;treat as unalloc
	JP	RWOPER		;to perform the read
;
;*****************************************************
;*                                                   *
;*	The WRITE entry point takes the place of     *
;*	the previous BIOS defintion for WRITE.       *
;*                                                   *
;*****************************************************
WRITE:
	;; DEBUG
	LD	A,'W'
	CALL	SHBIO
	;; DEBUG
	;write the selected CP/M sector
	LD	A,(HASNOD)		; no deblock. ?
	OR	A
	JP	NZ,WRITEHST
	XOR	A		;0 to accumulator
	LD	(READOP),A	;not a read operation
	LD	A,C		;write type in c
	LD	(WRTYPE),A
	CP	WRUAL		;write unallocated?
	JR	NZ,CHKUNA	;check for unalloc
;
;	write to unallocated, set parameters
	LD	A,BLKSIZ/128	;next unalloc recs
	LD	(UNACNT),A
	LD	A,(SEKDSK)	;disk to seek
	LD	(UNADSK),A	;unadsk = sekdsk
	LD	HL,(SEKTRK)
	LD	(UNATRK),HL	;unatrk = sectrk
	LD	A,(SEKSEC)
	LD	(UNASEC),A	;unasec = seksec
;
CHKUNA:
	;check for write to unallocated sector
	LD	A,(UNACNT)	;any unalloc remain?
	OR	A
	JR	Z,ALLOC		;skip if not
;
;	more unallocated records remain
	DEC	A		;unacnt = unacnt-1
	LD	(UNACNT),A
	LD	A,(SEKDSK)	;same disk?
	LD	HL,UNADSK
	CP	(HL)		;sekdsk = unadsk?
	JR	NZ,ALLOC	;skip if not
;
;	disks are the same
	LD	HL,UNATRK
	CALL	SEKTRKCMP	;sektrk = unatrk?
	JR	NZ,ALLOC	;skip if not
;
;	tracks are the same
	LD	A,(SEKSEC)	;same sector?
	LD	HL,UNASEC
	CP	(HL)		;seksec = unasec?
	JR	NZ,ALLOC	;skip if not
;
;	match, move to next sector for future ref
	INC	(HL)		;unasec = unasec+1
	LD	A,(HL)		;end of track?
	CP	CPMSPT		;count CP/M sectors
	JP	C,NOOVF		;skip if no overflow
;
;	overflow to next track
	LD	(HL),0		;unasec = 0
	LD	HL,(UNATRK)
	INC	HL
	LD	(UNATRK),HL	;unatrk = unatrk+1
;
NOOVF:
	;match found, mark as unnecessary read
	XOR	A		;0 to accumulator
	LD	(RSFLAG),A	;rsflag = 0
	JR	RWOPER		;to perform the write
;
ALLOC:
	;not an unallocated record, requires pre-read
	XOR	A		;0 to accum
	LD	(UNACNT),A	;unacnt = 0
	INC	A		;1 to accum
	LD	(RSFLAG),A	;rsflag = 1
;
;*****************************************************
;*                                                   *
;*	Common code for READ and WRITE follows       *
;*                                                   *
;*****************************************************
RWOPER:
	;enter here to perform the read/write
	XOR	A		;zero to accum
	LD	(ERFLAG),A	;no errors (yet)
	LD	A,(SEKSEC)	;compute host sector
	; SECSHF = 1 .....
;	REPT	SECSHF
	OR	A		;carry = 0
	RRA			;shift right
;	ENDM			; also can RRA ... RRA, AND $3F
	LD	(SEKHST),A	;host sector to seek
;
;	active host sector?
	LD	HL,HSTACT	;host active flag
	LD	A,(HL)
	LD	(HL),1		;always becomes 1
	OR	A		;was it already?
	JR	Z,FILHST	;fill host if not
;
;	host buffer active, same as seek buffer?
	LD	A,(SEKDSK)
	LD	HL,HSTDSK	;same disk?
	CP	(HL)		;sekdsk = hstdsk?
	JR	NZ,NOMATCH
;
;	same disk, same track?
	LD	HL,HSTTRK
	CALL	SEKTRKCMP	;sektrk = hsttrk?
	JR	NZ,NOMATCH
;
;	same disk, same track, same buffer?
	LD	A,(SEKHST)
	LD	HL,HSTLGS	;sekhst = hstsec?
	CP	(HL)
	JR	Z,MATCH		;skip if match
;
NOMATCH:
	;proper disk, but not correct sector
	LD	A,(HSTWRT)	;host written?
	OR	A
	CALL	NZ,WRITEHST	;clear host buff
;
FILHST:
	;may have to fill the host buffer
	LD	BC,(SEKTRK)
	CALL	BSETTRK
	LD	(HSTTRK),BC
	LD	B,0
	LD	A,(SEKDSK)
	LD	C,A
	CALL	BSELDSK
 	LD	(HSTDSK),A
	LD	A,(SEKHST)
	LD	C,A
	INC	C
; 	CALL	BSETSEC
 	LD	(HSTLGS),A
 	LD	BC,HSTBUF
 	CALL	BSETDMA
	LD	A,(RSFLAG)	;need to read?
	OR	A
	CALL	NZ,READHST	;yes, if 1
	XOR	A		;0 to accum
	LD	(HSTWRT),A	;no pending write
;
MATCH:
	;copy data to or from buffer
	LD	A,(SEKSEC)	;mask buffer number
	AND	SECMSK		;least signif bits
	LD	L,A		;ready to shift
	LD	H,0		;double count
	ADD	HL,HL		;shift left 7
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
;	hl has relative host buffer address
	LD	DE,HSTBUF
	ADD	HL,DE		;hl = host address
	EX	DE,HL		;now in DE
	LD	HL,(DMAADR)	;get/put CP/M data
	LD	C,128		;length of move
	LD	B,0		;
	LD	A,(READOP)	;which way?
	OR	A
	JR	NZ,RWMOVE	;skip if read
;
;	write operation, mark and switch direction
	LD	A,1
	LD	(HSTWRT),A	;hstwrt = 1
	EX	DE,HL		;source/dest swap
;
RWMOVE:
	;C initially 128, DE is source, HL is dest
; 	LD	A,(DE)		;source character
; 	INC	DE
; 	LD	(HL),A		;to dest
; 	INC	HL
; 	DEC	C		;loop 128 times
; 	JP	NZ,RWMOVE
	EX	DE,HL		; HL=src,DE=dst
	LDIR
;
;	data has been moved to/from host buffer
	LD	A,(WRTYPE)	;write type
	CP	WRDIR		;to directory?
	LD	A,(ERFLAG)	;in case of errors
	RET	NZ		;no further processing
;
;	clear host buffer for directory write
	OR	A		;errors?
	RET	NZ		;skip if so
	XOR	A		;0 to accum
	LD	(HSTWRT),A	;buffer written
	CALL	WRITEHST
	LD	A,(ERFLAG)
	RET
;
;*****************************************************
;*                                                   *
;*	Utility subroutine for 16-bit compare        *
;*                                                   *
;*****************************************************
SEKTRKCMP:
	;HL = .unatrk or .hsttrk, compare with sektrk
	EX	DE,HL
	LD	HL,SEKTRK
	LD	A,(DE)		;low byte compare
	CP	(HL)		;same?
	RET	NZ		;return if not
;	low bytes equal, test high 1s
	INC	DE
	INC	HL
	LD	A,(DE)
	CP	(HL)		;sets flags
	RET
;
	;
	;	scratch ram area for BIOS/BDOS usage
	;
BEGDAT	EQU	$		; beginning of data area
;*****************************************************
;*                                                   *
;*	Unitialized RAM data areas		     *
;*                                                   *
;*****************************************************
HASNOD: DEFB	0		;signal no debl. usage
;
SEKDSK:	DEFS	1		;seek disk number
SEKTRK:	DEFS	2		;seek track number
SEKSEC:	DEFS	1		;seek sector number
;
HSTDSK:	DEFS	1		;host disk number
HSTTRK:	DEFS	2		;host track number
HSTSEC:	DEFS	1		;host sector number
HSTLGS:	DEFS	1		; HST logical sector #
;
SEKHST:	DEFS	1		;seek shr secshf
HSTACT:	DEFS	1		;host active flag
HSTWRT:	DEFS	1		;host written flag
;
UNACNT:	DEFS	1		;unalloc rec cnt
UNADSK:	DEFS	1		;last unalloc disk
UNATRK:	DEFS	2		;last unalloc track
UNASEC:	DEFS	1		;last unalloc sector
;
ERFLAG:	DEFS	1		;error reporting
RSFLAG:	DEFS	1		;read sector flag
READOP:	DEFS	1		;1 if read operation
WRTYPE:	DEFS	1		;write operation type
DMAADR:	DEFS	2		;last dma address
HSTBUF:	DEFS	MHSTSIZ		;host buffer
	;
	; BDOS PART
	;
DIRBF:  DEFS    128		; scratch directory area
ALL00:  DEFS    26		; allocation vector 0
ALL01:  DEFS    26		; allocation vector 1
ALL02:  DEFS    26		; allocation vector 2
ALL03:  DEFS    26		; allocation vector 3
CHK00:  DEFS    32		; check vector 0
CHK01:  DEFS    32		; check vector 1
CHK02:  DEFS    32		; check vector 2
CHK03:  DEFS    32		; check vector 3
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