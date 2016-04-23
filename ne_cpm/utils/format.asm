;z80dasm: Portable Z80 disassembler
;Copyright (C) Marcel de Kogel 1996,1997
;Patched 2006 for uppercase by Piergiorgio Betti <pbetti@lpconsul.net>

; link to DarkStar Monitor symbols...
rsym darkstar.sym

	
CR	EQU	$0D
LF	EQU	$0A
FCB1	EQU	$005C			; DEFAULT FCB STRUCTURE	
DRVSLBF	EQU	$004E
TPA	EQU	$0100

	ORG	TPA

	JP	FORMAT			; 000100 the beginning

	; Here is the data to compose the track
FTRBEG:	DEFB	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DEFB	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DEFB	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DEFB	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF

FTRBG2:	DEFB	$00,$00,$00,$00,$00,$00
	DEFB	$FE					; addr mark
FITRKN:	DEFB	$00					; track #
	DEFB	$00					;
FISECN:	DEFB	$00					; sector #
	DEFB	$00
	DEFB	$F7					; CRC mark
	DEFB	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DEFB	$FF
	DEFB	$00,$00,$00,$00,$00,$00
	DEFB	$FB					; data addr mark
	DEFB	$E5,$E5,$E5,$E5,$E5,$E5,$E5,$E5
	DEFB	$E5,$E5,$E5,$E5,$E5,$E5,$E5,$E5
	DEFB	$E5,$E5,$E5,$E5,$E5,$E5,$E5,$E5
	DEFB	$E5,$E5,$E5,$E5,$E5,$E5,$E5,$E5
	DEFB	$E5,$E5,$E5,$E5,$E5,$E5,$E5,$E5
	DEFB	$E5,$E5,$E5,$E5,$E5,$E5,$E5,$E5
	DEFB	$E5,$E5,$E5,$E5,$E5,$E5,$E5,$E5
	DEFB	$E5,$E5,$E5,$E5,$E5,$E5,$E5,$E5
	DEFB	$E5,$E5,$E5,$E5,$E5,$E5,$E5,$E5
	DEFB	$E5,$E5,$E5,$E5,$E5,$E5,$E5,$E5
	DEFB	$E5,$E5,$E5,$E5,$E5,$E5,$E5,$E5
	DEFB	$E5,$E5,$E5,$E5,$E5,$E5,$E5,$E5
	DEFB	$E5,$E5,$E5,$E5,$E5,$E5,$E5,$E5
	DEFB	$E5,$E5,$E5,$E5,$E5,$E5,$E5,$E5
	DEFB	$E5,$E5,$E5,$E5,$E5,$E5,$E5,$E5
	DEFB	$E5,$E5,$E5,$E5,$E5,$E5,$E5,$E5
	DEFB	$F7					; CRC mark
	DEFB	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DEFB	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	
UUSD1	EQU	$			; should be $01de
	DEFB	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DEFB	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DEFB	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DEFB	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DEFB	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DEFB	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DEFB	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DEFB	$FF,$FF,$FF,$FF,$FF
	DEFB	$85,$FC,$DE,$FB,$00,$00,$5D,$00,$0D
	DEFB	$00,$62,$20,$00,$00,$AC,$02

CODBEG	EQU	$			; begin code...
	; Show a zero terminated string
ZSDSPCL:				; 0239
	LD	C,CR			; 
	CALL	JCONOU			; send CR
	LD	C,LF			; 
	JP	JCONOU			; send LF
ZSDSP:	LD	A,(HL)			; pick char pointed by HL
	OR	A			; is the terminating NUL ?
	RET	Z			; yes
	PUSH	HL			; no
	LD	C,A			;
	CALL	JCONOU			; display it
	POP	HL			;
	INC	HL			;
	JP	ZSDSP			;

	; get user input
GCHR:
	CALL	JCONIN			; take from console
	AND	$7F			; 
	CP	$60			; 
	JP	M,GCDSP			; verify alpha
	CP	$7B			; 
	JP	P,GCDSP			; 
	RES	5,A			; 
GCDSP:	PUSH	BC			; 
	LD	C,A			; 
	CALL	JCONOU			; 
	LD	A,C			; 
	POP	BC			; 
	RET				; 
	
FORMAT:
	LD	SP,CODBEG		; init stack
	LD	A,40			; 40 tracks by default
	LD	(TNUMBF),A		;
	LD	DE,FCB1+1		; point filename in FCB1
	LD	A,(DE)			; 
	CP	$20			; is space: no arguments
	JP	Z,NOARG			; 
	LD	HL,$0000		; still checking...
ARGLP:	LD	A,(DE)			;
	INC	DE			; 
	CP	$20			; is space ?
	JP	Z,SPNUL			; yes
	OR	A			; is NUL ?
	JP	Z,SPNUL			; yes
	SUB	$30			; is ':' ?
	CP	LF			; 
	JP	NC,ATRKERR		;
	ADD	HL,HL			;
	PUSH	HL			;
	ADD	HL,HL			;
	ADD	HL,HL			;
	POP	BC			;
	ADD	HL,BC			;
	LD	C,A			;
	LD	B,$00			;
	ADD	HL,BC			;
	JP	ARGLP			;
SPNUL:	LD	A,H			;
	OR	A			;
	JP	NZ,ATRKERR		;
	LD	A,L			;
	OR	A			;
	JP	Z,ATRKERR		; 
	LD	(TNUMBF),A		;
NOARG:	CALL	ZSDSPCL			;
	LD	HL,MFMT			; ask drive
	CALL	ZSDSP			; 
	CALL	GCHR			; 
	CP	$03			; CTRL+C ?
	JP	Z,EXIT			; exit
	CP	CR			; return ?
	JP	Z,EXIT			; exit
	RES	5,A			; 
	SUB	'A'			; sub 'A'
	JP	M,WRNGD			; 
	CP	$04			; is in range 0-3
	JP	P,WRNGD			; no
	LD	(FDRVBUF),A		; store drive num
	CALL	ZSDSPCL			; 
	LD	HL,MCFM			; ask confirm
	CALL	ZSDSP			; 
	CALL	GCHR			; 
	CP	'S'			; is 'S' ?
	JP	NZ,WCMND		; no
	LD	C,'I'			; complete answer with 'I' (SI = YES)
	CALL	JCONOU			; 
	LD	C,CR			; 
	CALL	JCONOU			; 
	LD	A,$00			; 
	LD	(FITRKN),A		;
	INC	A			; 
	LD	(FISECN),A		;
;	LD	HL,($0006)		; load BDOS start entry point
;					; that for the 56k is $CC06 and
;					; for 60k is $DC06
;	LD	DE,$0F02		; offset to $DB08/$EB08
;	ADD	HL,DE			;
;	LD	(CBDSEL+1),HL		; calc address of HDRVSEL in BIOS
;CBDSEL:	CALL	$0000			; call BIOS HDRVSEL
	CALL	HDRVSEL
	LD	A,(DRVSLBF)		;
	BIT	5,A			; ibm-3740 ?
	JP	NZ,WRNGT		; yes: unsupported
	LD	A,$03			; 1771 RESTORE
	CALL	JFDCMD			;
	CALL	JFSTAT			;
TRSTA:	LD	HL,FTRBEG		; start sequence
	LD	C,FDCDATAREG		; set C to 1771 data port
	LD	B,40			; 40 bytes to send
	LD	A,$F4			; 1771 WRITE TRACK
	CALL	JFDCMD			;
WFDC:	IN	A,(FDCCMDSTATR)		; chek ready
	BIT	1,A			;
	JR	Z,WFDC			;
	OUTI				; loop send byte
	JR	NZ,WFDC			;
WSECD:	LD	HL,FTRBG2		; sector image
	LD	B,173			; 173 bytes to send
WFDC1:	IN	A,(FDCCMDSTATR)		;
	BIT	1,A			;
	JR	Z,WFDC1			;
	OUTI				; 
	JR	NZ,WFDC1		; 
	LD	A,(FISECN)		; 
	INC	A			; 
	LD	(FISECN),A		; 
	CP	18			; if not all 17 sec image written
	JP	NZ,WSECD		; next sector
WTEAG:	IN	A,(FDCCMDSTATR)		; ready to write again ?
	BIT	0,A			; 
	JP	Z,WTEND			; no
	LD	A,$FF			; pad with FF
	OUT	(FDCDATAREG),A		; 
	JP	WTEAG			; 
WTEND:	CALL	JFSTAT			; 
	AND	$E7			; 
	JP	NZ,JUSRCM		; very bad: return to monitor ......
	LD	C,'.'			;
	CALL	JCONOU			; print a '.' for the track
	LD	A,(FITRKN)		; 
	INC	A			; next track
	LD	HL,TNUMBF		; 
	CP	(HL)			; EOD ?
	JP	Z,RSTART		; yes
	LD	(FITRKN),A		; 
	LD	A,$01			; 
	LD	(FISECN),A		; 
	LD	B,$00			; 
VL1:	DJNZ	VL1			; ?????? 000370 10 FE
VL2:	DJNZ	VL2			; ?????? 000372 10 FE
	LD	A,$53			; 1771 STEP-IN
	CALL	JFDCMD			; 
	CALL	JFSTAT			; 
	JP	TRSTA			;
	
WCMND:	LD	HL,MCMDA		; 00037F 21 2A 04

DSPER:	CALL	ZSDSP			; 
	JP	RSTART			; 
	
WRNGD:	LD	HL,MNDRV		; 
	JP	DSPER			; 

EXIT:	CALL	ZSDSPCL			; 
	JP	$0000			; jump to BOOT
	
WRNGT:	LD	HL,MNTIP		; 
	CALL	ZSDSP			; 
	JP	RSTART			; 

MNTIP:	DEFB	CR,LF,"tipo drive non ammesso",CR,LF,$00

	; restart from beginning
RSTART:	LD	A,$00			; reset drives
	OUT	(FDCDRVRCNT),A		;
	JP	FORMAT			; 

	; Display track # error
ATRKERR:
	LD	HL,MNTRK		;
	CALL	ZSDSP			;
	JP	$0000			;

	; Select and activate floppy drive
HDRVSEL:
	PUSH	AF			;
	PUSH	HL			;
	LD	HL,HDRVV		;
	LD	A,(FDRVBUF)		;
	ADD	A,L			;
	LD	L,A			;
	LD	A,(HL)			;
	LD	(DRVSLBF),A		;
	OUT	(FDCDRVRCNT),A		;
	POP	HL			;
	POP	AF			;
	RET				;

	; This used to translate the drive number in a cmd byte suitable
	; for drive selection on the floppy board
HDRVV:	DEFB	$01			; drive 1
	DEFB	$02			; drive 2
	DEFB	$04			; drive 3
	DEFB	$08 			; drive 4

MNDRV:	DEFB	CR,LF,"nome drive non ammesso",CR,LF,$00
MNTRK:	DEFB	CR,LF,"numero tracce non ammesso",CR,LF,$00
MFMT:	DEFB	"Elettro Design FORMATTAZIONE DISCO 5",$22," ? ",$00
MCMDA:	DEFB	CR,LF,"comando annullato",CR,LF,$00
MCFM:	DEFB	"sicuro s/n ? ",$00

TNUMBF:	DEFB	$28			; 00044E 28

UUSD2:	DEFB	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DEFB	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DEFB	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DEFB	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DEFB	$00,$00,$00,$00,$00,$00,$00,$00

	; This seem just junk 'til the EOF
	;	
; 	CP	$FF			; 000480 FE FF
; 	JP	NZ,$0BCF		; 000482 C2 CF 0B 
; 	LD	A,C			; 000485 79 
; 	OR	A			; 000486 B7 
; 	JP	P,$0BCF			; 000487 F2 CF 0B 
; 	LD	B,C			; 00048A 41 
; 	LD	A,D			; 00048B 7A 
; 	JP	$0299			; 00048C C3 99 02 
; 	CALL	$00DC			; 00048F CD DC 00 
; 	OR	B			; 000492 B0 
; 	LD	C,E			; 000493 4B 
; 	LD	B,D			; 000494 42 
; 	CALL	$01F4			; 000495 CD F4 01 
; 	LD	A,C			; 000498 79 
; 	CALL	$01F4			; 000499 CD F4 01 
; 	LD	A,B			; 00049C 78 
; 	JP	$01F4			; 00049D C3 F4 01 
; 	CALL	$00DC			; 0004A0 CD DC 00 
; 	OR	B			; 0004A3 B0 
; 	CALL	$01F4			; 0004A4 CD F4 01 
; 	LD	A,C			; 0004A7 79 
; 	CALL	$00A1			; 0004A8 CD A1 00 
; 	JP	$0299			; 0004AB C3 99 02 
; 	LD	C,$08			; 0004AE 0E 08 
; 	LD	DE,$00F8		; 0004B0 11 F8 00 
; 	LD	HL,$0D8A		; 0004B3 21 8A 0D 
; 	CALL	$00FC			; 0004B6 CD FC 00 
; 	JP	NZ,$02C5		; 0004B9 C2 C5 02 
; 	LD	A,E			; 0004BC 7B 
; 	CPL				; 0004BD 2F 
; 	RLCA				; 0004BE 07 
; 	RLCA				; 0004BF 07 
; 	RLCA				; 0004C0 07 
; 	RST	08H			; 0004C1 CF 
; 	JP	$02E2			; 0004C2 C3 E2 02 
; 	LD	DE,$00FD		; 0004C5 11 FD 00 
; 	LD	C,$03			; 0004C8 0E 03 
; 	LD	HL,$0D96		; 0004CA 21 96 0D 
; 	CALL	$00FC			; 0004CD CD FC 00 
; 	JP	NZ,$032E		; 0004D0 C2 2E 03 
; 	LD	A,E			; 0004D3 7B 
; 	CPL				; 0004D4 2F 
; 	ADD	A,$01			; 0004D5 C6 01 
; 	RRCA				; 0004D7 0F 
; 	RRCA				; 0004D8 0F 
; 	LD	C,A			; 0004D9 4F 
; 	CALL	$0139			; 0004DA CD 39 01 
; 	CALL	$00D6			; 0004DD CD D6 00 
; 	OR	C			; 0004E0 B1 
; 	LD	C,A			; 0004E1 4F 
; 	CALL	$0156			; 0004E2 CD 56 01 
; 	CP	$08			; 0004E5 FE 08 
; 	JP	C,$0300			; 0004E7 DA 00 03 
; 	SBC	A,$0B			; 0004EA DE 0B 
; 	CALL	$0120			; 0004EC CD 20 01 
; 	LD	A,$06			; 0004EF 3E 06 
; 	OR	C			; 0004F1 B1 
; 	LD	B,A			; 0004F2 47 
; 	LD	A,$CB			; 0004F3 3E CB 
; 	CALL	$01F4			; 0004F5 CD F4 01 
; 	PUSH	BC			; 0004F8 C5 
; 	CALL	$00BD			; 0004F9 CD BD 00 
; 	POP	BC			; 0004FC C1 
; 	JP	$0299			; 0004FD C3 99 02 
