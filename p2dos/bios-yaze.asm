;       CBIOS for Z80-Simulator
;
;       Copyright (C) 1988-95 by Udo Munk
;
CCP	EQU	$E400		;base of ccp
BDOS	EQU	CCP+$0806	;base of bdos
BIOS	EQU	CCP+$1600	;base of bios
CDISK	EQU	$0004		;current disk number 0=A,...,15=P
IOBYTE	EQU	$0003		;intel i/o byte
IOBVAL  EQU	$95            ;and its default value
;
;       I/O ports
;
CONSTA  EQU	0               ;console status port
CONDAT  EQU	1               ;console data port
PRTDAT  EQU	3               ;printer data port
AUXSTA  EQU	4               ;auxiliary status port
AUXDAT  EQU	5               ;auxiliary data port
FDCD    EQU	10              ;fdc-port: # of drive
FDCTL   EQU	11              ;fdc-port: low byte of track #
FDCTH   EQU	12		;fdc-port: high byte of track #
FDCS    EQU	13              ;fdc-port: # of sector
FDCOP   EQU	14              ;fdc-port: command
FDCST   EQU	15              ;fdc-port: status
DMAL    EQU	16              ;dma-port: dma address low
DMAH    EQU	17              ;dma-port: dma address high
CLKC	EQU	25		;clock command port
CLKD	EQU	26		;clock data port
;

NSECTS  EQU	[BIOS-CCP]/128  ;warm start sector count
;
;	jump vector for individual subroutines
;
	JP      BOOT            ;cold start
WBOOTE: JP      WBOOT           ;warm start
	JP      CONST           ;console status
	JP      CONIN           ;console character in
	JP      CONOUT          ;console character out
	JP      CBLIST            ;list character out
	JP      PUNCH           ;punch character out
	JP      CBREADER          ;reader character out
	JP      HOME            ;move head to home position
	JP      SELDSK          ;select disk
	JP      SETTRK          ;set track number
	JP      SETSEC          ;set sector number
	JP      SETDMA          ;set dma address
	JP      CBREAD            ;read disk
	JP      WRITE           ;write disk
	JP      CBLISTST          ;return list status
	JP      SECTRAN         ;sector translate
	JP	TIME		;get/set time
;
	;
BOTDSK:	DEFB	$FF			; store id of boot drive
	;				; N.B. placed here to be easily accessible
	;				; by the BDOS
;	fixed data tables for four-drive standard
;	IBM-compatible 8" disks
;
;	disk parameter header for disk 00
DPBASE:	DW	TRANS,0000
	DW	0000, 0000
	DW	DIRBF,DPBLK
	DW	CHK00,ALL00
;	disk parameter header for disk 01
	DW	TRANS,0000
	DW	0000 ,0000
	DW	DIRBF,DPBLK
	DW	CHK01,ALL01
;	disk parameter header for disk 02
	DW	TRANSHD,0000
	DW	0000,0000
	DW	DIRBF,DPBLKHD
	DW	CHK02,ALL02
;	disk parameter header for disk 03
	DW	TRANSHD,0000
	DW	0000,0000
	DW	DIRBF,DPBLKHD
	DW	CHK03,ALL03
;
;	sector translate vector
;
TRANS:	DB	1,7,13,19	;sectors 1,2,3,4
	DB	25,5,11,17	;sectors 5,6,7,8
	DB	23,3,9,15	;sectors 9,10,11,12
	DB	21,2,8,14	;sectors 13,14,15,16
	DB	20,26,6,12	;sectors 17,18,19,20
	DB	18,24,4,10	;sectors 21,22,23,24
	DB	16,22		;sectors 25,26

TRANSHD:	DB	1,2,3,4,5,6,7,8
	DB	9,10,11,12,13,14,15,16
	DB	17,18,19,20,21,22,23,24
	DB	25,26,27,28,29,30,31,32
;
;       disk parameter block, common to all disks
;
DPBLK:  DW    26              ;sectors per track
	DB    3               ;block shift factor
	DB    7               ;block mask
	DB    0               ;null mask
	DW    242             ;disk size-1
	DW    63              ;directory max
	DB    192             ;alloc 0
	DB    0               ;alloc 1
	DW    0               ;medium not changable
	DW    2               ;track offset

DPBLKHD: DW    32              ;sectors per track
	DB    4               ;block shift factor (bsh) (popcount(block size-1)-7)
	DB    15              ;block mask (blm) (block size/128-1)
	DB    0               ;null mask (exm)
	DW    2047            ;disk size-1 (dsm)
	DW    255             ;directory max (drm)
	DB    240             ;alloc 0 (al01 high)
	DB    0               ;alloc 1 (al01 low)
	DW    0               ;because medium not changable with z80sim!
	DW    0               ;track offset

;
;	end of fixed tables
;
;	individual subroutines to perform each function
;       simplest case is to just perform parameter initialization
;
BOOT:   LD      SP,$80         ;use space below buffer for stack
        LD      A,IOBVAL        ;init i/o byte
	LD	(IOBYTE),A	;clear the iobyte
        XOR     A               ;zero in the accum
	LD	(CDISK),A	;select disk zero
	JR	GOCPM		;initialize and go to cp/m
;
;       simplest case is to read the disk until all sectors loaded
;
WBOOT:  LD      SP,$80         ;use space below buffer for stack
	LD	C,0		;select disk 0
	CALL	SELDSK
	CALL	HOME		;go to track 00
;
	LD	B,NSECTS	;b counts # of sectors to load
	LD	C,0		;c has the current track number
	LD	D,2		;d has the next sector to read
;	note that we begin by reading track 0, sector 2 since sector 1
;	contains the cold start loader, which is skipped in a warm start
	LD      HL,CCP          ;base of cp/m (initial load point)
LOAD1:                          ;load one more sector
	PUSH    BC              ;save sector count, current track
	PUSH    DE              ;save next sector to read
	PUSH    HL              ;save dma address
	LD      C,D             ;get sector address to register c
	CALL    SETSEC          ;set sector address from register c
	POP     BC              ;recall dma address to b,c
	PUSH    BC              ;replace on stack for later recall
	CALL    SETDMA          ;set dma address from b,c
;	drive set to 0, track set, sector set, dma address set
	CALL CBREAD
	CP	0		;any errors?
	JR	NZ,WBOOT	;retry the entire boot if an error occurs
;	no error, move to next sector
	POP     HL              ;recall dma address
	LD      DE,128          ;dma=dma+128
	ADD     HL,DE           ;new dma address is in h,l
	POP     DE              ;recall sector address
	POP     BC              ;recall number of sectors remaining, and current trk
	DEC     B               ;sectors=sectors-1
	JR      Z,GOCPM         ;transfer to cp/m if all have been loaded
;	more sectors remain to load, check for track change
	INC	D
	LD      A,D             ;sector=27?, if so, change tracks
	CP      27
	JR      C,LOAD1         ;carry generated if sector<27
;	end of current track, go to next track
	LD      D,1             ;begin with first sector of next track
	INC     C               ;track=track+1
;	save register state, and change tracks
	PUSH    BC
	LD      B,0
	CALL    SETTRK          ;track address set from register c
	POP     BC
	JR      LOAD1           ;for another sector
;	end of load operation, set parameters and go to cp/m
GOCPM:
	LD	A,$C3		;c3 is a jmp instruction
	LD	(0),A		;for jmp to wboot
	LD	HL,WBOOTE	;wboot entry point
	LD	(1),HL		;set address field for jmp at 0
;
	LD	(5),A		;for jmp to bdos
	LD	HL,BDOS		;bdos entry point
	LD	(6),HL		;address field of jump at 5 to bdos
;
	LD	BC,$80		;default dma address is 80h
	CALL	SETDMA
;
	EI			;enable the interrupt system
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
        JR      Z,TTYST
        CP      1
        JR      Z,CRTST
        CP      2
        JR      Z,BATST
        JR      NULST

;       return reader status ($ff if char available, 0 else)
;
BATST:
CBREADST: LD      A,(IOBYTE)
        AND     $0c
        JR      Z,TTYST
        CP      $04
        JR      Z,RDRST
        CP      $08
        JR      Z,NULST
        JR      NULST

TTYST:
CRTST:  IN      A,(CONSTA)      ;get console input status
	RET

RDRST:  IN      A,(AUXSTA)
        AND     $1
        RET     Z
        LD      A,$FF
        RET

NULST:  XOR     A
        RET

;       return list status (0 if not ready, 1 if ready)
;
CBLISTST: LD      A,(IOBYTE)
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
;       RET

;       console character into register a
;
CONIN:  LD      A,(IOBYTE)
        AND     $03
        JR      Z,TTYIN
        CP      1
        JR      Z,CRTIN
        CP      2
        JR      Z,BATIN
        JR      NULIN

;       read character into register a from reader device
;
BATIN:
CBREADER: LD      A,(IOBYTE)
        AND     $0c
        JR      Z,TTYIN
        CP      $04
        JR      Z,RDRIN
        CP      $08
        JR      Z,NULIN
        JR      NULIN

TTYIN:
CRTIN:  IN      A,(CONSTA)
        OR      A
        JR      Z,CONIN
        IN      A,(CONDAT)      ;get character from console
	RET

RDRIN:  IN      A,(AUXSTA)
        OR      A
        JR      Z,CBREADER
        IN      A,(AUXDAT)
	RET

NULIN:  LD      A,26
        RET

;       console character output from register c
;
CONOUT: LD      A,(IOBYTE)
        AND     $03
        JR      Z,TTYOUT
        CP      1
        JR      Z,CRTOUT
        CP      2
        JR      Z,BATOUT
        JR      NULOUT

;       list character from register c
;
BATOUT:
CBLIST:   LD      A,(IOBYTE)
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
CRTOUT: LD      A,C             ;get to accumulator
	OUT     (CONDAT),A      ;send character to console
	RET

LPTOUT: LD      A,C             ;character to register a
	OUT     (PRTDAT),A
	RET

PUNOUT: LD      A,C             ;character to register a
	OUT     (AUXDAT),A
	RET

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
SELDSK: LD      HL,0            ;error return code
	LD	A,C
	CP	4		;must be between 0 and 3
	RET	NC		;no carry if 4,5,...
;	disk number is in the proper range
;	compute proper disk parameter header address
	OUT     (FDCD),A        ;select disk drive
	IN	A,(FDCST)
	OR	A
	RET	NZ
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
SETTRK: LD      A,C
	OUT     (FDCTL),A
	LD      A,B
	OUT     (FDCTH),A
	RET
;
;       set sector given by register c
;
SETSEC: LD      A,C
	OUT     (FDCS),A
	RET
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

TIME:
	LD	A,C
	OR	A
	RET	NZ
	XOR	A
	OUT	(CLKC),A	;seconds in BCD
	IN	A,(CLKD)
	LD	(RTCBUF+4),A
	LD	A,3
	OUT	(CLKC),A	;date LSB since 1,1,1978
	IN	A,(CLKD)
	LD	(RTCBUF),A
	LD	A,4
	OUT	(CLKC),A	;date MSB since 1,1,1978
	IN	A,(CLKD)
	LD	(RTCBUF+1),A
	LD	A,2
	OUT	(CLKC),A	;hours in BCD
	IN	A,(CLKD)
	LD	(RTCBUF+2),A
	LD	A,1
	OUT	(CLKC),A	;minutes in BCD
	IN	A,(CLKD)
	LD	(RTCBUF+3),A
	LD	HL,RTCBUF
	RET

RTCBUF:	DB 0,0,0,0,0
;
;       set dma address given by registers b and c
;
SETDMA: LD      A,C             ;low order address
	OUT     (DMAL),A
	LD      A,B             ;high order address
	OUT     (DMAH),A        ;in dma
	RET
;
;       perform read operation
;
CBREAD:   XOR     A               ;read command -> A
	JP      WAITIO          ;to perform the actual i/o
;
;       perform a write operation
;
WRITE:  LD      A,1             ;write command -> A
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
WAITIO: OUT     (FDCOP),A       ;start i/o operation
	IN      A,(FDCST)       ;status of i/o operation -> A
	RET
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
DIRBF:  DS    128                ;scratch directory area
ALL00:  DS    31                 ;allocation vector 0
ALL01:  DS    31                 ;allocation vector 1
ALL02:  DS    256                ;allocation vector 2
ALL03:  DS    256                ;allocation vector 3
CHK00:  DS    16                 ;check vector 0
CHK01:  DS    16                 ;check vector 1
CHK02:  DS    16                 ;check vector 2
CHK03:  DS    16                 ;check vector 3
;
ENDDAT:                          ;end of data area
