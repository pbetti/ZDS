;;----------------------------------------------------------------------------
;;       CBIOS for Z80-DarkStar
;;
;; (c) 2006 Piergiorgio Betti <pbetti@lpconsul.net>
;;
;; 2006/01/12 	archived version 0.1 and started a new version
;;		with some new feature. I'm also doing a merge of some
;;		code from the original NE BIOS after it's recover
;;		and disassembly.
;; 2006/05/05	Missed comments 'til now, but started version 0.7.
;;		Some check still needed by deblock routines.
;;		First cleanup of the code.
;;		Inserted conditional assembly directives.
;; 20060610	First customization to support ZCPR3
;;		:-)
;; 20060620	v1.1 - Inserted a workaround (read-after-write check)
;;		against still persisting floppy write problems. (I hope...)
;; 20080125	Enabling interrupt handling
;; 20080208	v1.3 - Inserted RTC clock driver - The BIOS area is almost
;;		full........
;;----------------------------------------------------------------------------
;
; link to DarkStar Monitor symbols...
rsym darkstar.sym
;
CBREV	EQU	13		; CBIOS version number
	;
	; load common symbols
	;
include common.asm
include z3base.lib
	;
	;	The useful part
	;
BIOSIZ	EQU	BEGDAT-BIOS	; BIOS size (text only)
	;
	; 	CDISK and IOBYTE are already defined into the monitor
	;
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
;!!!!!!! should read only whole traks. To be checked...............
CPMSIZ	EQU	BEGDAT-CCP+128	; include BIOS in reload count... see WBOOT
BIOHBY	EQU	($ >> 8) & $FF
	;
	; defines for optional code
	;
DFMT128		EQU	FALSE		; 128 b/s disks
DFMT256		EQU	FALSE		; 256 b/s disks
DFMT512		EQU	TRUE		; 512 b/s disks
USENODEBLOCK	EQU	DFMT128		; optional code for no deblock
RAFRTR		EQU	5		; # retrys on read-after-write error
RAFSHOW		EQU	TRUE		; Show errors occurring on RAF check
RAFCHR		EQU	'~'		; Char to be used for RAFSHOW
RAFDFLT		EQU	TRUE		; Initial status (enabled/disabled) for RAF
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
IF DFMT128
	; sector translation table 128 (skew = 6)
TR128:	DEFB	1,7,13,19		; sectors 1,2,3,4
	DEFB	25,31,5,11		; sectors 5,6,7,8
	DEFB	17,23,29,3		; sectors 9,10,11,12
	DEFB	9,15,21,27		; sectors 13,14,15,16
	DEFB	2,8,14,20		; sectors 17,18,19,20
	DEFB	26,32,6,12		; sectors 21,22,23,24
	DEFB	18,24,30,4		; sectors 25,26,27,28
	DEFB	10,16,22,28		; sectors 29,30,31,32
ENDIF
IF DFMT512
	; sector translation table for 512 bytes/11 sec. track (skew = 4)
TRANS:	DEFB	1,5,9,2 		; sectors 1,2,3,4
	DEFB	6,10,3,7	 	; sectors 5,6,7,8
	DEFB	11,4,8			; sectors 9,10,11
ENDIF
IF DFMT256
	; 256 byte/sec. native sector translation table (skew = 6)
TRA10:	DEFB	1,7		 	; sector 1,2
	DEFB	3,9		 	; sector 3,4
	DEFB	5,2		 	; sector 5,6
	DEFB	8,4		 	; sector 7,8
	DEFB	10,6		 	; sector 9,10
ENDIF
	;
	;       disk parameter block, common to all disks
	;
IF DFMT128
	;----------------------------------------------
	; Native size ported to 3,5" 80 track double side drive
	; (128 * 32 * 160)
DPB128:	DEFW    32			; sectors per track (DAB2)
	DEFB    4			; block shift factor
	DEFB    15			; block mask
	DEFB    0			; null mask
	DEFW    313			; disk size-1
	DEFW    127			; directory max
	DEFB    192			; alloc 0
	DEFB    0			; alloc 1
	DEFW    32			; medium changable
	DEFW    3			; track offset (DAC0)
	; non-standard part (Phisical CHS infos)
	DEFW	32			; sectors per track
	DEFW	128			; sector lenght
	DEFB	2			; heads
	DEFW	80			; tracks
	DEFB	0			; deblock shift
	DEFB	0			; deblock mask
	DEFB	16			; 128 byte sectors per block
ENDIF
IF DFMT512
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
ENDIF
IF DFMT256
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
	DEFB	1			; deblock shift
	DEFB	1			; deblock mask
	DEFB	16			; 128 byte sectors per block
ENDIF
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
SIGNON:	DEFB	CR,LF
	DEFB	'Z80DarkStar '
	DEFB	'0'+MSIZE/10		; memory size
	DEFB	'0'+(MSIZE MOD 10)
	DEFB	'K TPA ZCPR V'		; zcpr version
	DEFB	Z3REV/10+'0','.',(Z3REV MOD 10)+'0'
	DEFB	', CBIOSZ V'		; cbiosz version
	DEFB	CBREV/10+'0','.',(CBREV MOD 10)+'0',CR,LF
	DEFB	'(c) 2006 P. Betti <pbetti@lpconsul.net>'
	DEFB	CR,LF+$80
BFAILMSG:
	DEFB	CR,LF,"BOOT FAILURE !",CR,LF+$80
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
	LD	A,(TMPBYTE)		; set read-after-write bit
IF RAFDFLT
	SET	7,A
ELSE
	RES	7,A
ENDIF
	LD	(TMPBYTE),A
	XOR	A
	LD	(HSTACT),A		; invalidate deblock buffer
	LD	(UNACNT),A		; clear unalloc count
	LD	(NOPROW),A		; clear pre-read
IF	Z3WHL NE 0
	LD	(Z3WHL),A		; zcp3 wheel byte (non privileged)
ENDIF
IF	SHSTK NE 0
	LD	(SHSTK),A		; Shell stack cleared
ENDIF
	LD	A,(BOTDSK)		; check boot drive
	CP	$FF			; if $FF we are at first bootstrap
	JR	NZ,BOTOK		; boot drive already registered
	LD	A,(CDISK)		; otherwise CDISK is real boot drive
	LD	(BOTDSK),A		; register drive
BOTOK:	LD	(CDISK),A		; re-log boot drive
	XOR	A
	LD	(DSELBF),A		; resets drive command buffer
	; now the ZCPR3 part...
IF	EXPATH	NE 0			; init External Path
	LD	DE,EXPATH
	LD	HL,PATH
	LD	BC,9			; that is 9 bytes.
	LDIR
ENDIF
IF	RCP NE 0			; init Resident Command Package
	LD	HL,RCP
	CALL	ZERO128
	LD	HL,ZDSSTPR		; init embedded date stamper space
	CALL	ZERO128
ENDIF
IF	IOP NE 0			; init I/O Package with drivers
	LD	HL,IOP			; image taken from IODRIVERS
	LD	DE,IODRIVERS
	LD	BC,IODRVSIZ		; image size
	LDIR				; N.B. NOT SUPPORTED HERE
ENDIF
IF	FCP NE 0			; init Flow Command Package
	LD	HL,FCP
	CALL	ZERO128
ENDIF
IF	Z3ENV NE 0			; init Env. descriptor
	LD	HL,Z3ENV
	LD	B,128+16		; 128 bytes environ + 16 TCAP
	CALL	ZEROM
ENDIF
IF	Z3MSG NE 0
	LD	HL,Z3MSG		; init Message Buffer
	LD	B,80
	CALL	ZEROM
ENDIF
IF	Z3NDIR NE 0
	LD	HL,Z3NDIR		; init named directory buffer
	CALL	ZERO128
ENDIF
IF	Z3CL NE 0
	LD	DE,Z3CL			; init Command line buffer
	LD	HL,CMDSET
	LD	BC,5
	LDIR
ENDIF
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
	LD	A,$C3			; Initialize ISR to clock routine
	LD	($0038),A		;
	LD	HL,CLOISR		;
	LD	($0039),HL		;
	IM	1			; activate mode 1
	CALL	GENAIN			; permits interrupts reactivation by monitor
	EI				; enable the interrupt system
	LD	A,(CDISK)		; get current disk number
	LD	C,A			; send to the ccp
	;
	LD	A,(CWFLG)		; test for any loaded program
	OR	A
 	JP	NZ,CCP+3		; no: warm boot
	INC	A
	LD	(CWFLG),A
	LD	DE,COLDBEG
CLDCMND:
IF	Z3CL NE 0			; multiple cmd buffer ?
	LD	HL,Z3CL+4		; yes
ELSE
	LD	HL,CCP+8		; no
ENDIF
CLD1:	LD	A,(DE)			; copy cmd string
	LD	(HL),A
	INC	HL
	INC	DE
	OR	A
	JR	NZ,CLD1
	JP	CCP			; go to CCP
	;
	; service routine used on cold boot to init buffers
	;
ZERO128:
	LD	B,128
ZEROM:	LD	(HL),0
	INC	HL
	DJNZ	ZEROM
	RET
	; Cold boot command string
CWFLG:	DEFB	0
COLDBEG:
	DEFB	'STARTUP'		; Cold boot cmd (i.e. 'STARTUP')
COLDEND:
	DEFB	0
	; Default search path
PATH:	DEFB	IDISK1,IUSER1		; default path on cold boot
	DEFB	IDISK2,IUSER2
	DEFB	IDISK3,IUSER3
	DEFB	IDISK4,IUSER4
	DEFB	0
	; Initial values for External Command Line Buffer and
	; Named Directory memory-based buffers
IF	Z3CL NE 0
CMDSET:
	DEFW	Z3CL+4			; buffer beginning
	DEFB	Z3CLS			; size of i/o buffer
	DEFB	0
	DEFB	0
ENDIF
	;
	; RTC handler routine
	;
TIME:	LD	A,C			; read or write ?
	OR	A
	JR	NZ,TIMWRI
	PUSH	DE			; save user buffer address
	LD	HL,RTCBUF		; load private storage area
	CALL	RDTIME
	DEC	HL			; HL is at year buffer
	POP	DE			; restore use buffer
	;
	LD	A,7			; 7 byte to fix
TIMLOA:	LD	C,(HL)
	;
	CP	6			; offset 6 (local) is day of week...
	JR	Z,TIMSY0		; so skip it
	;
	EX	DE,HL			; swap HL and DE
	CP	1			; last (old) byte need to be saved
	JR	NZ,TIMNLS		; not the one
	LD	B,(HL)			; save in B
TIMNLS:	LD	(HL),C			; now can load C in (DE)
	EX	DE,HL			; reset swap
	INC	DE			; advance RTCBUF ptr
TIMSY0:	DEC	HL			; back one on top of RTCBUF
	DEC	A			; all done ?
	JR	NZ,TIMLOA		; if no loop
	DEC	DE			; exit: put DE at buffer top
	EX	DE,HL			; save buffer top in HL
	LD	E,B			; put in E old (top) buffer content
	XOR	A
	INC	A			; all good
	RET
	;
; TIMDOW: LD	B,A			; save counter
; 	LD	A,C			; load dow in A
; 	LD	(CLKDOW),A		; this is the place !
; 	LD	A,B			; restore counter
; 	JR	TIMSY0			; next
TIMWRI:	LD	A,$FF			; unsupported here
	RET

RTCBUF:
CLKSE:	DEFB	0
CLKMM:	DEFB	0
CLKHR:	DEFB	0
CLKDAY:	DEFB	0
CLKMON:	DEFB	0
CLKDOW:	DEFB	0
CLKYEA:	DEFB	0
; TIMDE:	DEFW	0
; CLKIMN:	DEFB	0
; CLKISE:	DEBF	0
; CLKTIK:	DEFB	0

CLOISR:	EI				; do nothing ISR
	RETI


;
; RTCOVF:	DEFB	50,60,60		; TICK,SEC,MIN,HR,DAY,MON,YEAR
;
; CLOISR:	PUSH	AF
; 	PUSH	BC
; 	PUSH	DE
; 	PUSH	HL
; 	LD	DE,RTCOVF
; 	LD	HL,CLKTIK
; 	LD	B,3			; up to an hour manage here than sync with RTC
; CLISRL:	INC	(HL)			; advance clock every tick (50HZ = 50 x sec.)
; 	LD	A,(DE)
; 	CP	(HL)
; 	JR	NZ,CLISRE
; 	XOR	A
; 	LD	(HL),A
; 	DEC	B
; 	JR	Z,ISRSYN		; an hour elapsed: call RTC to sync
; 	DEC	HL
; 	INC	DE
; 	JR	CLISRL
; 	;
; CLISRE:	POP	HL
; 	POP	DE
; 	POP	BC
; 	POP	AF
; 	EI
; 	RETI
; 	;
; ISRSYN:	LD	HL,RTCBUF		; point to the destination time string
; 	CALL	RDTIME
; 	DEC	HL			; HL is at year buffer
; 	LD	DE,RTCBUF		; now set date in the right format
; 	LD	A,7			; 7 byte to fix
; 	LD	C,(HL)
; 	CP	4			; offset 4 is day of week...
; 	JR	Z,ISRDOW		; so set in CLKDOW
; 	EX	DE,HL			; swap HL and DE
; 	LD	(HL),C			; now can load C in (DE)
; 	EX	DE,HL			; reset swap
; 	INC	DE			; advance RTCBUF ptr
; ISRSY0:	DEC	HL			; back one on top of RTCBUF
; 	DEC	A			; all done ?
; 	JR	Z,CLISRE		; if yes exit



; CLOON:	DI
; 	LD	A,$C3
; 	LD	($0038),A
; 	LD	HL,CLOISR
; 	LD	($0039),HL
; 	EI
; 	RET
;
; CLOOFF:	DI
; 	LD	A,$C9
; 	LD	($0038),A
; 	EI
; 	RET

	;----------------------------------------------------------------------
	;
	;	i/o drivers for the disk follow
	;
	;----------------------------------------------------------------------
	;
	;       move to the track 00 current drive
	;
HOME:	LD	A,(HSTWRT)		; check for pending write
	OR	A
	RET	NZ
	LD	(HSTACT),A		; clear host active flag
	LD	A,(SEKDSK)		; UNLESS is a real floppy
	CP	2			; is floppy ?
	RET	NC			; no
HOMFLO:	LD	(FDRVBUF),A		; HW
	DI				; disable interrupts
	CALL	DRVSEL			; drive activation
 	CALL	BHOME			; send cmd.
 	EI				; enable interrupts
 	RET				; go back
	;
	;       select disk given by register C
	;
SELDSK:
	XOR	A			; use deblock by default
IF USENODEBLOCK
	LD	(HASNOD),A		; ...
ENDIF
	OUT	(FDCDRVRCNT),A		; resets floppy selection
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
IF USENODEBLOCK
	LD	A,(PHYPRM+2)		; sec. len. in A
	CP	128			; need deblock ?
	JR	NZ,SELNDB		; yes: not a 128 bytes sector
	LD	A,1
	LD	(HASNOD),A		; disable deblock
	LD	BC,(SEKDSK)
	CALL	BSELDSK			; no: so set immediate
ENDIF
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
IF USENODEBLOCK
	LD	A,(HASNOD)		; no deblock. ?
	OR	A
	RET	Z
	JP	BSETTRK
ELSE
	RET
ENDIF
;
SETSEC:
	;set sector given by register c
	LD	A,C
	LD	(SEKSEC),A		; sector to seek
IF USENODEBLOCK
	LD	A,(HASNOD)		; no deblock. ?
	OR	A
	RET	Z
	LD	A,C
	LD	(HSTLGS),A		; sector to seek (log.)
ENDIF
	RET
;
SETDMA:
	;set dma address given by BC
	LD	(DMAADR),BC
IF USENODEBLOCK
	LD	A,(HASNOD)		; no deblock. ?
	OR	A
	RET	Z
	JP	BSETDMA
ELSE
	RET
ENDIF
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
	DI				; i/o with interrupts disabled
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
	EI				; reenable interrupts
	RET
	;
RDVRT:	CALL	VDSKRD			; call par. read
	BIT	0,A			; adjust Z flag for error test
	LD	(ERFLAG),A		; store error status
	POP	IX
	EI				; reenable interrupts
	RET
	;
	;       perform a physical write operation
	;
WRITEHST:
 	CALL	PHYSTR
DWRITH:	PUSH	IX
	LD	IX,PHYPRM		; IX point to current CHS info
	DI				; i/o with interrupts disabled
	LD	A,(FDRVBUF)		; get active drive
	CP	2			; is floppy ?
	JR	C,WRFLO			; yes
	CP	14			; is hard disk ?
	JR	C,WRVRT			; yes (fake call: HDD aren't implemented yet)
	JR	WRVRT			; then is a virtual drive
	;
WRFLO:	LD	A,(FTRKBUF)
	LD	E,A			; save FTRKBUF in case of side switch
	LD	D,RAFRTR		; # retrys
	;
WRFLT:	CALL	CHKSID			; side select
	CALL	DRVSEL			; activate drive
	CALL	BWRITE			; do write
	LD	(ERFLAG),A		; store error status
	JR	NZ,WRFL2		; Ouch !!
	;
	LD	A,(TMPBYTE)		; check for read-after-write on
	BIT	7,A
	JR	Z,WRFL2			; off, normal operations
	; read-after-write check
	LD	A,E
	LD	(FTRKBUF),A		; restore FTRKBUF
	CALL	CHKSID			; side select
	CALL	DRVSEL			; activate drive
	CALL	FSEEK			; re-seek
	JR	NZ,WRFL0
	;
	LD	HL,(FRDPBUF)
	LD	A,FDCREADC		; load read command
	CALL	SFDCCMD			; send to 1771
	JR	WRAF1
WRAF2:	RRCA
	JR	NC,WRAFE
WRAF1:	IN	A,(FDCCMDSTATR)
	BIT	1,A			; sec found
	JR	Z,WRAF2
	IN	A,(FDCDATAREG)		; data in
	CP	(HL)			; check it
	JR	NZ,WRFER		; check failed !
	INC	HL
	JP	WRAF1
WRAFE:	CALL	GFDCSTAT
	AND	$5C			; test for other errors
WRFL0:
	JR	Z,WRFL2			; OK
WRFL3:	XOR	A
	OUT	(FDCDRVRCNT),A
	INC	A
	LD	(ERFLAG),A		; store error status
WRFL2:	POP	IX
	EI				; reenable interrupts
	RET
WRFER:
IF RAFSHOW
	LD	C,RAFCHR
	CALL	BCONOUT
ENDIF
	DEC	D			; retry ?
	JR	Z,WRFL3			; no, unrecoverable
	LD	A,E
	LD	(FTRKBUF),A		; restore FTRKBUF
	JR	WRFLT			; yes, once more
	;
WRVRT:	CALL	VDSKWR			; call par. write
	BIT	0,A			; adjust Z flag for error test
	LD	(ERFLAG),A		; store error status
	POP	IX
	EI				; reenable interrupts
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
IF USENODEBLOCK
	LD	A,(HASNOD)		; no deblock. ?
	OR	A
	JP	NZ,READHST
ENDIF
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
IF USENODEBLOCK
	LD	A,(HASNOD)		; no deblock. ?
	OR	A
	JP	NZ,WRITEHST
ENDIF
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
	LD	HL,HSTDSK		; same disk?
	CP	(HL)			; sekdsk = hstdsk?
	JR	NZ,HSTLOA
;	same disk, same track?
	LD	HL,(HSTTRK)
	LD	BC,(SEKTRK)
	CALL	DIFF16			; sektrk = hsttrk?
	JR	NZ,HSTLOA
;	same disk, same track: same buffer too ?
	LD	A,(SEKHST)
	LD	HL,HSTSEC		; sekhst = hstsec?
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
WHSTFI:	LD	A,(MIOBYTE)		; write entry
	RES	0,A
	JR	HSTFIL
RHSTFI:	CALL	SK2HST			; sync SEK => HST on read
	LD	A,(MIOBYTE)
	SET	0,A
HSTFIL:
	; have to fill the host buffer
	LD	(MIOBYTE),A
	LD	BC,HSTBUF		; set DMA to buffer
	CALL	BSETDMA
	LD	A,(SEKDSK)		; save SEKDSK
	LD	(HSTTMP),A
	LD	A,(HSTDSK)		; set disk
	LD	C,A
	CALL	BSELDSK			; ... hw
	CALL	SELDSK			; ... logical
	LD	BC,(HSTTRK)		; set track
	CALL	BSETTRK
	LD	A,(HSTSEC)		; set sector
	LD	(HSTLGS),A

	LD	A,(MIOBYTE)		; read/write ?
	BIT	0,A
	JR	NZ,HSTFRD		; read
	CALL	WRITEHST		; for disk write
	JR	AFTRIO
HSTFRD:
	CALL	READHST
AFTRIO:
	LD	A,(HSTTMP)
	LD	(SEKDSK),A
	LD	C,A
	CALL	SELDSK
	XOR	A
	LD	(HSTWRT),A		; clear flag
 	RET
;
SK2HST:
	; update hst seek info's from local (SEKs)
	LD	A,(SEKDSK)
	LD	(HSTDSK),A
	LD	HL,(SEKTRK)
	LD	(HSTTRK),HL
	LD	A,(SEKHST)
	LD	(HSTSEC),A
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
SYNPND:
	; sync buffer to disk, invalidate buffer
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
IF USENODEBLOCK
HASNOD: DEFB	0		; signal no debl. usage
ENDIF
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
HSTDSK:	DEFS	1		; host disk number
HSTTRK:	DEFS	2		; host track number
HSTSEC:	DEFS	1		; host sector number
WRTTMP:	DEFS	1		; write track buffer
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

	IF	ENDDAT GT ZBUFBAS
	* BIOS OVERLAP ZCPR BUFFERS !! *
	ENDIF

; symbols...
wsym bios.sym

	END
;