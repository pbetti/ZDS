;z80dasm: Portable Z80 disassembler
;Copyright (C) Marcel de Kogel 1996,1997
;Patched 2006 for uppercase by Piergiorgio Betti <pbetti@lpconsul.net>

; This is the original Micro Z80 Nuova Elettronica BIOS.
; I've disassembled it as of my best...

CR	EQU	$0D
LF	EQU	$0A

; CCP	EQU	$C400			; CCP offset
; LCCPOF	EQU	CCP-128			;
; BDOSB	EQU	CCP+$0800		; BDOS base offset
; BDOS	EQU	CCP+$0806		; BDOS entry point offset
; BIOS	EQU	CCP+$1600		; BIOS offset
; BIOSSZ	EQU	768			; BIOS size
; NSECT	EQU	(BIOS-CCP)+768		; CP/M size in # of sectors

MSIZE   EQU     56              ;CP/M VERSION MEMORY SIZE IN KILOBYTES
				; is 56k for NE Micro
	;
	;       "BIAS" IS ADDRESS OFFSET FROM 3400H FOR MEMORY SYSTEMS
	;       THAN 16K (REFERRED TO AS"B" THROUGHOUT THE TEXT)
	;
BIAS    EQU     (MSIZE-20)*1024
CCP     EQU     3400H+BIAS      ;BASE OF CCP
BDOS    EQU     CCP+806H        ;BASE OF BDOS
BDOSB	EQU	CCP+$0800	; BDOS base offset
BIOS    EQU     CCP+1600H       ;BASE OF BIOS
CDISK   EQU     0004H           ;CURRENT DISK NUMBER 0=A,... L5=P
IOBYTE  EQU     0003H           ;INTEL I/O BYTE
	;
	ORG     BIOS            ;ORIGIN OF THIS PROGRAM
NSECTS  EQU     ($-CCP)/128     ;WARM START SECTOR COUNT
	;


; DIRBF	EQU	$DD00
; CHK00	EQU	$DDFC
; CHK01	EQU	$DE0C
; CHK02	EQU	$DE1C
; CHK03	EQU	$DE2C
; ALL00	EQU	$DD80
; ALL01	EQU	$DD9F
; ALL02	EQU	$DDBE
; ALL03	EQU	$DDDD


	ORG	BIOS			; Addresses here are for a 56k system

	JP	JCPMBO			; BOOT		00DA00 C3 33 F0
WBOOTE:	JP	WBOOT			; WBOOT
	JP	CONST			; CONST
	JP	CONIN			; CONIN
	JP	CONOUT			; CONOUT
	JP	CBLIST			; LIST
	JP	PUNCH			; PUNCH
	JP	READER			; READER
	JP	HOME			; HOME
	JP	SELDSK			; SELDSK
	JP	JSETTR			; SETTRK
	JP	JSETSE			; SETSEC
	JP	JSETDM			; SETDMA
	JP	CBREAD			; READ
	JP	WRITE			; WRITE
	JP	LISTST			; LISTST
	JP	SECTRAN			; SECTRAN

DPBASE:	DEFW	TRANS,$0000		; DP header disk 1
	DEFW	$0000,$0000
	DEFW	DIRBF,$DAB2
	DEFW	CHK00,ALL00

	DEFW	TRANS,$0000		; DP header disk 2
	DEFW	$0000,$0000
	DEFW	DIRBF,$DAB2
	DEFW	CHK01,ALL01

	DEFW	TRANS,$0000		; DP header disk 3
	DEFW	$0000,$0000
	DEFW	DIRBF,$DAB2
	DEFW	CHK02,ALL02

	DEFW	TRANS,$0000		; DP header disk 4
	DEFW	$0000,$0000
	DEFW	DIRBF,$DAB2
	DEFW	CHK03,ALL03

	; This used to translate the drive number in a cmd byte suitable
	; for drive selection on the floppy board
HDRVV:	DEFB	$01			; drive 1
	DEFB	$02			; drive 2
	DEFB	$04			; drive 3
	DEFB	$08 			; drive 4

	; native sector translation table (skew = 6)
TRANS:	DEFB	$01,$07,$0D,$02 	; sectors 1,2,3,4
	DEFB	$08,$0E,$03,$09 	; sectors 5,6,7,8
	DEFB	$0F,$04,$0A,$10		; sectors 9,10,11,12
	DEFB	$05,$0B,$11,$06		; sectors 13,14,15,16
	DEFB	$0C			; sector 17
	DEFB	$12			; sector 18 ????? 8-?

	; ibm-3740...
TRNS1:	DEFB	1,7,13,19		;sectors 1,2,3,4
	DEFB	25,5,11,17		;sectors 5,6,7,8
	DEFB	23,3,9,15		;sectors 9,10,11,12
	DEFB	21,2,8,14		;sectors 13,14,15,16
	DEFB	20,26,6,12		;sectors 17,18,19,20
	DEFB	18,24,4,10		;sectors 21,22,23,24
	DEFB	16,22			;sectors 25,26

	;This seems an alternative DPB (ibm-3740) Hmm, a little weird however
	; why is it here ??
DPBL1:	DEFW    26			; sectors per track (DAA3)
	DEFB    3			; block shift factor
	DEFB    7			; block mask
	DEFB    0			; null mask
	DEFW    242			; disk size-1
	DEFW    63			; directory max
	DEFB    192			; alloc 0
	DEFB    0			; alloc 1
	DEFW    16			; medium not changable
	DEFW    3			; track offset (DAB1)

	; Native size (128 * 17 * 40) disk format DPB
DPBLK:	DEFW    17			; sectors per track (DAB2)
	DEFB    3			; block shift factor
	DEFB    7			; block mask
	DEFB    0			; null mask
	DEFW    77			; disk size-1
	DEFW    31			; directory max
	DEFB    128			; alloc 0
	DEFB    0			; alloc 1
	DEFW    8			; medium not changable
	DEFW    3			; track offset (DAC0)

	;This seems another alternative DPB... Very weird!!
	; May be a format for a double-sided drive?? (in native format)
DPBL2:	DEFW    17			; sectors per track (DAC1)
	DEFB    3			; block shift factor
	DEFB    7			; block mask
	DEFB    0			; null mask
	DEFW    162			; disk size-1
	DEFW    63			; directory max
	DEFB    192			; alloc 0
	DEFB    0			; alloc 1
	DEFW    16			; medium not changable
	DEFW    3			; track offset (DACF)


NULFN1:	RET				; 00DAD0 C9

NULFN2:	LD	A,$1A			; 00DAD1 3E 1A
	RET				; 00DAD3 C9

HOME:
	CALL	HDRVSEL			; 00DAD4 CD 08 DB
	JP	JMTRK0			; 00DAD7 C3 09 F0

SIGNON:	DEFB	CR,LF,"Micro Comp   * CP/M 56k v. 2.25",'$'


CBREAD:
	CALL	HDRVSEL			; 00DAFC CD 08 DB
	JP	JREAD			; 00DAFF C3 18 F0
WRITE:
	CALL	HDRVSEL			; 00DB02 CD 08 DB
	JP	JWRITE			; 00DB05 C3 1B F0

	; Select and activate floppy drive
HDRVSEL:
	PUSH	AF			;
	PUSH	HL			;
	LD	HL,HDRVV		; 10
	LD	A,(FDRVBUF)		; 13
	ADD	A,L			; 4
	LD	L,A			; 4
	LD	A,(HL)			; 7
	LD	(DSELBF),A		; 13
	OUT	(FDCDRVRCNT),A		; 11
	POP	HL			;
	POP	AF			;
	RET				;

	; Display a char string terminated by '$'
DSPMSG:
	LD	A,(HL)			; HL point to msg		00DB1B 7E
	CP	$24			; is the terminator '$' ?
	RET	Z			; yes
	PUSH	HL			;
	LD	C,A			;
	CALL	JCONOU			; disp. chr
	POP	HL			;
	INC	HL			; next chr
	JR	DSPMSG			; loop until '$'

	; Test printer busy status
HLISTST:
	IN	A,(CRTSERVDAT)		; 00DB28 DB 89
	BIT	PRNTBUSYBIT,A		; 00DB2A CB 47
	LD	A,$00			; 00DB2C 3E 00
	RET	NZ			; 00DB2E C0
	CPL				; 00DB2F 2F
	RET				; 00DB30 C9
	
	; this is an alternate sector TRANS table with skew = 4
	; for 26 sec. format, WHY ???
ALTR26:	DEFB	$01,$05,$09,$0D
	DEFB	$11,$15,$19,$03
	DEFB	$07,$0B,$0F,$13
	DEFB	$17,$02,$06,$0A
	DEFB	$0E,$12,$16,$1A
	DEFB	$04,$08,$0C,$10
	DEFB	$14,$18
	
	; the same for 17 sector format, again: WHY ???
ALTR17:	DEFB	$01,$05,$09,$0D
	DEFB	$11,$04,$08,$0C
	DEFB	$10,$03,$07,$0B
	DEFB	$0F,$02,$06,$0A
	DEFB	$0E

ALTROF:	DEFW	$DB4A
SECNUM:	DEFB	$11

WBOOT:
	LD	SP,$0080		;
	LD	C,0			; select drive 0 (should use BC)
	CALL	JSELDS			; 
	LD	C,0			; 
	CALL	JSETTR			; select track 0 (should use BC)
	CALL	HOME			; fseek 0
	JP	NZ,JUSRCM		; error, return to monitor
	LD	A,(DSELBF)		;
	BIT	5,A			; which format ??
	LD	A,17			; 17 sectors format
	LD	HL,ALTR17		; trans vec. skew 4
	JR	Z,WBTSLF		; jump to format store
	LD	A,26			; 26 sectors format
	LD	HL,ALTR26		; trans vec. skew 4
WBTSLF:	LD	(SECNUM),A		; store format selections
	LD	(ALTROF),HL		;
;
	LD	B,NSECT			; sector # to load. This is 50 in the original code
					; and so it reloads also the BIOS itself. This is
					; an error...
	LD	DE,2			; skip sector 0 (bootloader) at the beginning
	JR	WBTSTA			; start loading
WBTNXT:	LD	DE,1			; first sector, current track
WBTSTA:	PUSH	DE			;
	PUSH	BC			;
	LD	HL,(ALTROF)		; load skew 4 translation vec.
					; Note that tracks < 3 are written with contiguous
					; sector numbering. So loading of sectors with
					; a skew factor need a DMA load address that
					; follow sector jump...
	ADD	HL,DE			; translation HL (base) + DE (offset)
	LD	A,(FTRKBUF)		; 
	CP	1			; traccia 1 ?
	JP	M,WBTSSD		; traccia 0
	JR	NZ,WBT4			; 					00DBA1 20 0B
	LD	A,(SECNUM)		; 					00DBA3 3A 5E DB
	CP	26			; 					00DBA6 FE 1A
	JR	NZ,WBTSSD		; 					00DBA8 20 0A
	LD	A,19			; 					00DBAA 3E 13
	JR	WBT5			; 					00DBAC 18 02
WBT4:	LD	A,11			; 					00DBAE 3E 0B
WBT5:	CP	(HL)			; 					00DBB0 BE 	
	JP	M,WBT6			; 					00DBB1 FA E1 DB
WBTSSD:	LD	C,(HL)			; translate sector pointed by HL
	CALL	JSETSE			; set sector and dma
	LD	HL,(FTRKBUF)		; WHAT THE HELL IS DOING FROM HERE TO WBT7???
	INC	L			; 
	LD	A,(SECNUM)		; 
	LD	C,A			; 
	CPL				; 
	INC	A			; 
WBT7:	ADD	A,C			; 
	DEC	L			;
	JR	NZ,WBT7			; 
	DEC	A			; 
	ADD	A,H			; 
	LD	L,A			; 
	LD	H,0			; 
	ADD	HL,HL			;
	ADD	HL,HL			;
	ADD	HL,HL			;
	ADD	HL,HL			;
	ADD	HL,HL			;
	ADD	HL,HL			;
	ADD	HL,HL			;
	LD	DE,(CCP-128)		;
	ADD	HL,DE			;
	PUSH	HL			;
	POP	BC			;
	CALL	JSETDM			;
	CALL	CBREAD			; 
	JP	NZ,JUSRCM		; load error, return to monitor
WBT6:	POP	BC			; 
	DEC	B			; dec sector count
	JR	Z,GOCPM			; go CP/M if all loaded
	POP	DE			; 
	INC	DE			; 
	LD	A,(SECNUM)		; 
	INC	A			; 
	CP	E			; has read sector 17 (26) ?
	JR	NZ,WBTSTA		; no: next sector
	INC	C			; yes: next track
	CALL	JSETTR			; set it,
	JR	WBTNXT			; and restart sec. count
GOCPM:	
	LD	A,$C3			; init jump locations
	LD	($0000),A		;
	LD	($0005),A		; 
	LD	HL,BDOS			; 
	LD	($0006),HL		; set bdos base jump at $0005
	LD	HL,WBOOTE		; 
	LD	($0001),HL		; warm boot at $0000
	LD	BC,$0080		; 
	CALL	JSETDM			; default dma at $0080
	LD	HL,SIGNON		; 
	CALL	DSPMSG			; 
	LD	A,(CDISK)		; logged drive
	LD	C,A			; 
	JP	CCP			; 
	
	; This duplicate (clonate) the routine present into the monitor
	; send a char to the printer port
	
BPRNCHR:
	IN	A,(CRTSERVDAT)		; 00DC1B in from prn control port
	BIT	PRNTBUSYBIT,A		; busy ?
	JR	NZ,BPRNCHR		; yes
	LD	A,C			;
	OUT	(CRTPRNTDAT),A		; no, send char
	RET				;
	
	NOP				; 00DC25 00 
	NOP				; 00DC26 00 
	NOP				; 00DC27 00 
	NOP				; 00DC28 00 
	NOP				; 00DC29 00 
	NOP				; 00DC2A 00 
	NOP				; 00DC2B 00 
	NOP				; 00DC2C 00 
	NOP				; 00DC2D 00 
	NOP				; 00DC2E 00

	; execute monitor BCONST (console status)
CONSTJ:
	JP	BCONST			; 00DC2F C3 B9 FA
	
	NOP				; 00DC32 00 
	NOP				; 00DC33 00 
	NOP				; 00DC34 00 
	NOP				; 00DC35 00 
	NOP				; 00DC36 00 
	NOP				; 00DC37 00 

SELDSK:
	LD      HL,0			;error return code
	LD	A,C
	LD	(FDRVBUF),A		; store it
	CP	4			; must be between 0 and 3
	RET	NC			; no carry if 4,5,...
	LD	L,A			; L=disk number 0,1,2,3
	LD	H,0			;
	ADD	HL,HL			; *2
	ADD	HL,HL			; *4
	ADD	HL,HL			; *8
	ADD	HL,HL			; *16 (size of each header)
	LD	DE,DPBASE
	ADD	HL,DE			; HL=dpbase(diskno*16)
	RET

SECTRAN:
	EX      DE,HL			; HL= trans
	ADD     HL,BC			; HL= trans(sector)
	LD      L,(HL)			; L = trans(sector)
	LD      H,0			; HL= trans(sector)
	RET				; with value in HL

	; This jump to the "real" CONOUT in the Monitor
CONOUJ:	
	JP	JCONOU			; 00DC54 C3 06 F0
	
	NOP				; 00DC57 00 
	NOP				; 00DC58 00 
	NOP				; 00DC59 00 
	NOP				; 00DC5A 00 
	NOP				; 00DC5B 00 
	NOP				; 00DC5C 00 
	NOP				; 00DC5D 00 
	NOP				; 00DC5E 00 
	NOP				; 00DC5F 00 
	NOP				; 00DC60 00 
CONIN:
	LD	A,(IOBYTE)		; 00DC61 3A 03 00
	AND	$03			; 00DC64 E6 03 
	JP	Z,JCONIN			; 00DC66 CA 03 F0
	CP	$02			; 00DC69 FE 02 
	JP	M,JCONIN			; 00DC6B FA 03 F0
	JP	Z,NDEVMSG			; 00DC6E CA E6 DC
	JP	NDEVMSG			; 00DC71 C3 E6 DC
CONOUT:
	LD	A,(IOBYTE)		; 00DC74 3A 03 00
	AND	$03			; 00DC77 E6 03 
	JP	Z,CONOUJ			; 00DC79 CA 54 DC
	CP	$02			; 00DC7C FE 02 
	JP	M,CONOUJ			; 00DC7E FA 54 DC
	JP	Z,NDEVMSG			; 00DC81 CA E6 DC
	JP	NDEVMSG			; 00DC84 C3 E6 DC
CONST:
	LD	A,(IOBYTE)		; 00DC87 3A 03 00
	AND	$03			; 00DC8A E6 03
	JP	Z,CONSTJ			; 00DC8C CA 2F DC
	CP	$02			; 00DC8F FE 02 
	JP	M,CONSTJ			; 00DC91 FA 2F DC
	JP	Z,NDEVMSG			; 00DC94 CA E6 DC
	JP	NDEVMSG			; 00DC97 C3 E6 DC
CBLIST:
	LD	A,(IOBYTE)		; 00DC9A 3A 03 00
	AND	$C0			; 00DC9D E6 C0 
	JP	Z,JCONOU			; 00DC9F CA 06 F0
	CP	$80			; 00DCA2 FE 80 
	JP	M,JCONOU			; 00DCA4 FA 06 F0
	JP	Z,BPRNCHR			; 00DCA7 CA 1B DC
	JP	NDEVMSG			; 00DCAA C3 E6 DC
LISTST:
	LD	A,(IOBYTE)		; 00DCAD 3A 03 00
	AND	$C0			; 00DCB0 E6 C0 
	JP	Z,CONSTJ			; 00DCB2 CA 2F DC
	CP	$80			; 00DCB5 FE 80 
	JP	M,CONSTJ			; 00DCB7 FA 2F DC
	JP	Z,HLISTST			; 00DCBA CA 28 DB
	JP	NDEVMSG			; 00DCBD C3 E6 DC
PUNCH:
	LD	A,(IOBYTE)		; 00DCC0 3A 03 00
	AND	$30			; 00DCC3 E6 30 
	JP	Z,JCONOU			; 00DCC5 CA 06 F0
	CP	$20			; 00DCC8 FE 20 
	JP	M,NULFN1			; 00DCCA FA D0 DA
	JP	Z,NDEVMSG			; 00DCCD CA E6 DC
	JP	NDEVMSG			; 00DCD0 C3 E6 DC

READER:
	LD	A,(IOBYTE)		; 00DCD3 3A 03 00
	AND	$0C			; 00DCD6 E6 0C 
	JP	Z,JCONIN			; 00DCD8 CA 03 F0
	CP	$08			; 00DCDB FE 08 
	JP	M,NULFN2			; 00DCDD FA D1 DA
	JP	Z,NDEVMSG			; 00DCE0 CA E6 DC
	JP	NDEVMSG			; 00DCE3 C3 E6 DC

	; Display a no device message
NDEVMSG:
	XOR	A			; 
	LD	(IOBYTE),A		; reset IOBYTE
	LD	HL,MSNODEV		; load msg
	CALL	DSPMSG			; display
	JP	$0000			; do a WBOOT

MSNODEV:				; 00DCF3 0D
	DEFB	CR,LF,"*NO DEVICE",$

	;
	;       SCRATCH RAM AREA FOR BDOS USE
BEGDAT  EQU     $               ;BEGINNING OF DATA AREA
DIRBF:  DS      128             ;SCRATCH DIRECTORY AREA
ALL00:  DS      31              ;ALLOCATION VECTOR 0
ALL01:  DS      31              ;ALLOCATION VECTOR 1
ALL02:  DS      31              ;ALLOCATION VECTOR 2
ALL03:  DS      31              ;ALLOCATION VECTOR 3
CHK00:  DS      16              ;CHECK VECTOR 0
CHK01:  DS      16              ;CHECK VECTOR 1
CHK02:  DS      16              ;CHECK VECTOR 2
CHK03:  DS      16              ;CHECK VECTOR 3
	;
ENDDAT  EQU     $               ;END OF DATA AREA
DATSIZ  EQU     $-BEGDAT;       ;SIZE OF DATA AREA
	END

