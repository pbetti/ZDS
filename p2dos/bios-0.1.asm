;       CBIOS for Z80-DarkStar
;
;
; link to DarkStar Monitor symbols...
rsym darkstar.sym
;
VERS    EQU     22      ;VERSION 2.2
;
CCP	EQU	$D400		;base of ccp
BDOS	EQU	CCP+$0806	;base of bdos
BIOS	EQU	CCP+$1600	;base of bios
	; current disk should change to 3/4
;CDISK	EQU	$0001		;current disk number 0=A,...,15=P
;IOBYTE	EQU	$0003		;intel i/o byte
IOBVAL  EQU	$95            	;and its default value
CR      EQU     0DH		;CARRIAGE RETURN
LF      EQU     0AH		;LINE FEED;
;

NSECTS  EQU	(BIOS-CCP)/128  ;warm start sector count
;
;	jump vector for individual subroutines
;
	ORG	BIOS

	JP      CBBOOT            ;cold start
WBOOTE: JP      WBOOT           ;warm start
	JP      CONST           ;console status
	JP      CONIN           ;console character in
	JP      CONOUT          ;console character out
	JP      CBLIST            ;list character out
	JP      PUNCH           ;punch character out
	JP      READER          ;reader character out
	JP      HOME            ;move head to home position
	JP      SELDEFSK          ;select disk
	JP      SETTRK          ;set track number
	JP      SETSEC          ;set sector number
	JP      SETDMA          ;set dma address
	JP      CBREAD            ;read disk
	JP      WRITE           ;write disk
	JP      LISTST          ;return list status
	JP      SECTRAN         ;sector translate
	JP	TIME		;get/set time
;
;	fixed data tables for four-drive standard
;	IBM-compatible 8" disks
;
;	disk parameter header for disk 00
DPBASE:	DEFW	TRANS,0000
	DEFW	0000, 0000
	DEFW	DIRBF,DPBLK
	DEFW	CHK00,ALL00
;	disk parameter header for disk 01
	DEFW	TRANS,0000
	DEFW	0000 ,0000
	DEFW	DIRBF,DPBLK
	DEFW	CHK01,ALL01
;	disk parameter header for disk 02
	DEFW	TRANSHD,0000
	DEFW	0000,0000
	DEFW	DIRBF,DPBLKHD
	DEFW	CHK02,ALL02
;	disk parameter header for disk 03
	DEFW	TRANSHD,0000
	DEFW	0000,0000
	DEFW	DIRBF,DPBLKHD
	DEFW	CHK03,ALL03
;
;	sector translate vector
;
TRANS:	DEFB	1,7,13,19	;sectors 1,2,3,4
	DEFB	25,5,11,17	;sectors 5,6,7,8
	DEFB	23,3,9,15	;sectors 9,10,11,12
	DEFB	21,2,8,14	;sectors 13,14,15,16
	DEFB	20,26,6,12	;sectors 17,18,19,20
	DEFB	18,24,4,10	;sectors 21,22,23,24
	DEFB	16,22		;sectors 25,26

TRANSHD:
	DEFB	1,2,3,4,5,6,7,8
	DEFB	9,10,11,12,13,14,15,16
	DEFB	17,18,19,20,21,22,23,24
	DEFB	25,26,27,28,29,30,31,32
;
;       disk parameter block, common to all disks
;
DPBLK:  DEFW    26              ;sectors per track
	DEFB    3               ;block shift factor
	DEFB    7               ;block mask
	DEFB    0               ;null mask
	DEFW    242             ;disk size-1
	DEFW    63              ;directory max
	DEFB    192             ;alloc 0
	DEFB    0               ;alloc 1
	DEFW    1               ;medium not changable
	DEFW    2               ;track offset

DPBLKHD:
	DEFW    32              ;sectors per track
	DEFB    4               ;block shift factor (bsh) (popcount(block size-1)-7)
	DEFB    15              ;block mask (blm) (block size/128-1)
	DEFB    0               ;null mask (exm)
	DEFW    2047            ;disk size-1 (DEFSm)
	DEFW    255             ;directory max (drm)
	DEFB    240             ;alloc 0 (al01 high)
	DEFB    0               ;alloc 1 (al01 low)
	DEFW    0               ;because medium not changable with z80sim!
	DEFW    0               ;track offset

SIGNON:	DEFB	CR,LF,LF
	DEFB	'60'		;MEMORY SIZE FILLED BY RELOCATOR
	DEFB	'k (P2DOS) CP/M vers '
	DEFB	VERS/10+'0','.',VERS MOD 10+'0'
	DEFB	CR,LF+$80
BFAILMSG:
	DEFB	CR,LF,"CP/M BOOT FAILURE !",CR,LF+$80
;
;	end of fixed tables
;
;	individual subroutines to perform each function
;       simplest case is to just perform parameter initialization
;
CBBOOT: LD      SP,$80		;use space below buffer for stack
        LD      A,IOBVAL	;init i/o byte
	LD	(IOBYTE),A	;clear the iobyte
	LD	HL, SIGNON	; print signon message
	CALL	CONSTR
	; current drive is already logged by the monitor
;	XOR     A		;zero in the accum
;	LD	(CDISK),A	;select disk zero
	JR	GOCPM		;initialize and go to cp/m
;
;       simplest case is to read the disk until all sectors loaded
;
WBOOT:	LD	SP, $0080
	LD      BC,CCP          ; base transfer address
	CALL	BSETDMA
	LD	C, 0		; drive A
	CALL	BSELDSK
	LD	BC, 0		; START TRACK
	CALL	BSETTRK
	LD      E,2            	; START SECTOR
	LD      D,NSECTS         ; d=# sectors to load
;       load the next sector
LSECT:	LD	B, 0
	LD	C, E		; SECTOR
	CALL	BSETSEC
	CALL	CBREAD		; perform i/o
	CP	$00
	JR	NZ, BOOTFAIL

CONT:	DEC     D               ; sects=sects-1
	JR	NZ, NEXTOP
	JP      GOCPM		; Jump to CCP
;       more sectors to load
NEXTOP:	LD	HL, (FRDPBUF)
	LD	BC, VDSECLN
	ADD	HL, BC		; next sector #, offset
	LD	(FRDPBUF), HL
	INC     E               ; sector = sector + 1
	LD      A,E
	CP      27              ; last sector of track ?
	JR      C,LSECT         ; no, go read another
;
;       end of track, increment to next track
;
	LD	HL, (FTRKBUF)	; track = track + 1
	INC	HL
	LD	(FTRKBUF), HL
	LD      E,1             ; sector = 1
	JR      LSECT           ; for another group
BOOTFAIL:
	LD	HL, BFAILMSG
	CALL	CONSTR
	JP	WBOOT
;	end of load operation, set parameters and go to cp/m
GOCPM:
	LD	A,$C3		;c3 is a jmp instruction
	LD	($0000),A	;for jmp to wboot
	LD	HL,WBOOTE	;wboot entry point
	LD	($0001),HL	;set address field for jmp at 0
;
	LD	($0005),A	;for jmp to bdos
	LD	HL,BDOS		;bdos entry point
	LD	($0006),HL	;address field of jump at 5 to bdos
;
	LD	BC,$80		;default dma address is 80h
	CALL	SETDMA
;
;	EI			;enable the interrupt system
	LD	A,(CDISK)	;get current disk number
	LD	C,A		;send to the ccp
	JP      CCP             ;go to cp/m for further processing
;
;
;       character i/o handlers

;       console status, return 0ffh if character ready, 00h if not
;
CONST:  LD      A,(IOBYTE)
        AND     $03
	JR	TTYST		; FIXME: FORCED FOR NOW !!!!
        JR      Z,TTYST
        CP      1
        JR      Z,CRTST
        CP      2
        JR      Z,BATST
        JR      NULST

;       return reader status ($ff if char available, 0 else)
;
BATST:
READEFST:
	LD      A,(IOBYTE)
        AND     $0c
        JR      Z,TTYST
        CP      $04
        JR      Z,RDRST
        CP      $08
        JR      Z,NULST
        JR      NULST

TTYST:
CRTST:  ;IN      A,(CONSTA)      ;get console input status
	JP	JCONST
	;RET

RDRST:  LD      A,$FF
        RET

NULST:  XOR     A
        RET

;       return list status (0 if not ready, 1 if ready)
;
LISTST: LD      A,(IOBYTE)
        AND     $C0
        JR      Z,TTYOST
        CP      $40
        JR      Z,CRTOST
        CP      $80
        JR      Z,LPTOST
        JR      NULOST

TTYOST:
CRTOST: LD      A,$ff
	RET

LPTOST: LD      A,$ff
	RET

NULOST: LD      A,$ff
	RET

;       console character into register a
;
CONIN:  LD      A,(IOBYTE)
        AND     $03
	JR	TTYIN		; FIXME: Forced for now!!!
        JR      Z,TTYIN
        CP      1
        JR      Z,CRTIN
        CP      2
        JR      Z,BATIN
        JR      NULIN

;       read character into register a from reader device
;
BATIN:
READER: LD      A,(IOBYTE)
        AND     $0c
        JR      Z,TTYIN
        CP      $04
        JR      Z,RDRIN
        CP      $08
        JR      Z,NULIN
        JR      NULIN

TTYIN:
CRTIN:  JP	JCONIN

RDRIN:  LD	A,26
	RET

NULIN:  LD      A,26
        RET

;       console character output from register c
;
CONOUT: LD      A,(IOBYTE)
        AND     $03
	JR	TTYOUT		; FIXME: Forced for now!!!
        JR      Z,TTYOUT
        CP      1
        JR      Z,CRTOUT
        CP      2
        JR      Z,BATOUT
        JR      NULOUT

;       list character from register c
;
BATOUT:
CBLIST:
	LD      A,(IOBYTE)
        AND     $C0
        JR      Z,TTYOUT
        CP      $40
        JR      Z,CRTOUT
        CP      $80
        JR      Z,LPTOUT
        JR      NULOUT

;       punch character from register c
;
PUNCH:  LD      A,(IOBYTE)
        AND     $30
        JR      Z,TTYOUT
        CP      $10
        JR      Z,PUNOUT
        CP      $20
        JR      Z,NULOUT
        JR      NULOUT

TTYOUT:
CRTOUT: JP	JCONOU

LPTOUT: RET

PUNOUT: RET

NULOUT: RET

;	i/o drivers for the disk follow
;
;       move to the track 00 position of current drive
;	translate this call into a settrk call with parameter 00
;
HOME:   LD      BC,0            ;select track 0
	JP      SETTRK          ;we will move to 00 on first read/write
;
;       select disk given by register C
;
SELDEFSK:
	LD      HL,0            ;error return code
	LD	A,C
	CP	4		;must be between 0 and 3
	RET	NC		;no carry if 4,5,...
;	disk number is in the proper range
;	compute proper disk parameter header address
	CALL	BSELDSK
	LD	L,C		;L=disk number 0,1,2,3
	ADD	HL,HL		;*2
	ADD	HL,HL		;*4
	ADD	HL,HL		;*8
	ADD	HL,HL		;*16 (size of each header)
	LD	DE,DPBASE
	ADD	HL,DE		;HL=.dpbase(diskno*16)
	RET
;
;       set track given by register bc
;
SETTRK: JP	JSETTR
;
;       set sector given by register c
;
SETSEC: JP	JSETSE
;
;       translate the sector given by BC using the
;       translate table given by DE
;
SECTRAN:
	EX      DE,HL           ;HL=.trans
	ADD     HL,BC           ;HL=.trans(sector)
	LD      L,(HL)          ;L = trans(sector)
	LD      H,0             ;HL= trans(sector)
	RET                     ;with value in HL

TIME:   RET

RTCBUF:	DEFB 0,0,0,0,0
;
;       set dma address given by registers b and c
;
SETDMA: JP	JSETDM
;
;       perform read operation
;
CBREAD:	JP	VDSKRD		; FIXME: Just call parallel read for now
;
;       perform a write operation
;
WRITE:  JP	VDSKWR		; FIXME: Just call parallel write for now
;
;       enter here from read and write to perform the actual i/o
;	operation.  return a 00h in register a if the operation completes
;	properly, and 01h if an error occurs during the read or write
;
;       in this case, we have saved the disk number in 'diskno' (0-3)
;			the track number in 'track' (0-76)
;			the sector number in 'sector' (1-26)
;			the dma address in 'dmaad' (0-65535)
;
WAITIO: RET
;
;	the remainder of the CBIOS is reserved uninitialized
;	data area, and does not need to be a part of the
;	system memory image (the space must be available,
;	however, between "begdat" and "enddat").
;
;	scratch ram area for BDOS use
;
.useg
BEGDAT:                          ;beginning of data area
DIRBF:  DEFS    128                ;scratch directory area
ALL00:  DEFS    31                 ;allocation vector 0
ALL01:  DEFS    31                 ;allocation vector 1
ALL02:  DEFS    256                ;allocation vector 2
ALL03:  DEFS    256                ;allocation vector 3
CHK00:  DEFS    16                 ;check vector 0
CHK01:  DEFS    16                 ;check vector 1
CHK02:  DEFS    16                 ;check vector 2
CHK03:  DEFS    16                 ;check vector 3
;
ENDDAT:                          ;end of data area
