;z80dasm: Portable Z80 disassembler
;Copyright (C) Marcel de Kogel 1996,1997
;Patched 2006 for uppercase by Piergiorgio Betti <pbetti@lpconsul.net>

; link to DarkStar Monitor symbols...
rsym darkstar.sym


CR	EQU	$0D
LF	EQU	$0A
BEL	EQU	$07
FCB1	EQU	$005C			; DEFAULT FCB STRUCTURE
;DSELBF	EQU	$004E
TPA	EQU	$0100
	;
	ORG	TPA

GOFMT:	JP	FORMAT			; 000100 the beginning
	;
SCRTCH:	DEFS	128			; local stack area
SPAREA	EQU	$
	;
	; include routines to print ascii values
include ../ASM/bit2040.asm
	;;
	; Here is the data to compose the track
FTRBEG:	DEFB	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DEFB	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DEFB	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DEFB	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;
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
	DEFB	$FF,$FF,$FF,$FF				; 173 byte block
	DEFB	$FF,$FF,$FF,$FF,$FF,$FF
	;
	; Disks format vector
DFTAB:	DEFB	40,1,18,0		; 40 TRK SS
	DEFB	40,2,18,0		; 40 TRK DS
	DEFB	80,1,18,0		; 80 TRK SS
	DEFB	80,2,18,0		; 80 TRK DS
	;
	;
CODBEG	EQU	$			; begin code...
	;
	; Show a zero terminated string
ZSDSPCL:				; 0239
	LD	C,CR			;
	CALL	JCONOU			; send CR
	LD	C,LF			;
	CALL	JCONOU			; send LF
ZSDSP:	LD	A,(HL)			; pick char pointed by HL
	OR	A			; is the terminating NUL ?
	RET	Z			; yes
	PUSH	HL			; no
	LD	C,A			;
	CALL	JCONOU			; display it
	POP	HL			;
	INC	HL			;
	JP	ZSDSP			;
	;
	; this copy a decimal converted string in area
	; pointed by HL
PLDECS:	PUSH	HL			; load HL on IY
	POP	IY			;
	LD	HL,OVAL16		; result of conversion
PLDNXT:	LD	A,(HL)			; pick char pointed by HL
	OR	A			; is the terminating NUL ?
	RET	Z			; yes
	LD	(IY+0),A		; digit copy
	INC	HL			; next locations
	INC	IY			;
	JP	PLDNXT			;
	; get user input
GCHR:
	CALL	JCONIN			; take from console
	AND	$7F			;
	CP	$60			;
	JP	M,GCDSP			; verify alpha
	CP	$7B			;
	JP	P,GCDSP			;
	RES	5,A			; convert to uppercase
GCDSP:	PUSH	BC			;
	LD	C,A			;
	CALL	JCONOU			;
	LD	A,C			;
	POP	BC			;
	RET				;

FORMAT:
	LD	SP,SPAREA		; init stack
	LD	A,40			; 40 tracks by default
	LD	(TNUMBF),A		;
	LD	A,1			; 1 side
	LD	(TSIDES),A		;
	LD	HL,MCHOI		; ask format
	CALL	ZSDSP			;
USEL:	CALL	GCHR			;
	CP	$03			; CTRL+C ?
	JP	Z,EXIT			; exit
	CP	CR			; return ?
	JP	Z,EXNOS			; exit
	SUB	'0'			; convert to binary
	DEC	A			; adjust base
	CP	$04			; is in range 0-3
	JP	P,WRNGD			; no
	LD	(TFRMT),A		; store user selection
	LD	E,A			; copy drive num on DE
	LD	D,0			;
	LD	IX,DFTAB		; load format parameter base
	ADD	IX,DE			; for check
	ADD	IX,DE			;
	ADD	IX,DE			;
	ADD	IX,DE			;
	LD	C,(IX+0)		;
	CALL	BIN2A8			; convert tracks to decimal
	LD	HL,MUSNT		;
	CALL	PLDECS			;
	LD	C,(IX+1)		;
	CALL	BIN2A8			; convert sides to decimal
	LD	HL,MUSSD		;
	CALL	PLDECS			;
	LD	HL,MUSFM		;
	CALL	ZSDSP			; show to the user
	;
	LD	HL,MDCHO		; ask for drive id
	CALL	ZSDSP			;
	CALL	GCHR			;
	CP	$03			; CTRL+C ?
	JP	Z,EXIT			; exit
	CP	CR			; return ?
	JP	Z,EXNOS			; exit
	CP	'A'			; is A or B ?
	JP	M,WRNGD			;
	CP	'C'			;
	JP	P,WRNGD			; no
	SUB	'A'			; makes number
	LD	(TDRIV),A		; store user selection
	LD	(FDRVBUF),A		; store drive num
	;
	LD	HL,MCFM			; ask confirm
	CALL	ZSDSPCL			;
	CALL	GCHR			;
	CP	'Y'			; is 'Y' ?
	JP	NZ,WCMND		; no
	LD	C,'e'			; complete answer with (Y)es
	CALL	JCONOU			;
	LD	C,'s'			; complete answer with (Y)es
	CALL	JCONOU			;
	LD	C,CR			;
	CALL	JCONOU			;
	LD	C,LF			;
	CALL	JCONOU			;
	;
AGAIN:	CALL	WAITKY			; wait for disk in drive
	; Defines format parameters
	LD	A,(TFRMT)		; retrieve format
	LD	E,A			; store drive num on DE
	LD	D,0			; for later use
	LD	IX,DFTAB		; format parameter base
	ADD	IX,DE			; type offset
	ADD	IX,DE			;
	ADD	IX,DE			;
	ADD	IX,DE			;
	LD	A,(IX+0)		; TRACKS
	LD	(TNUMBF),A		; store # of tracks
	LD	D,(IX+1)		; SIDES - loads in DE (sides+sectors)
	LD	E,(IX+2)		;
	XOR	A			;
	LD	(FITRKN),A		; start track
	LD	(TCOUNT),A
	LD	(CSIDE),A		; start side
	LD	C,A			; for SETSID
	INC	A			;
	LD	(FISECN),A		;
	;
	CALL	SETSID
	CALL	DRVSEL
	LD	A,$03			; 1771 RESTORE
	CALL	JFDCMD			;
	CALL	JFSTAT			;
	;
TRSTA:	LD	HL,FTRBEG		; start sequence
	LD	C,FDCDATAREG		; set C to 1771 data port
	LD	B,40			; 40 bytes to send
	LD	A,$F4			; 1771 WRITE TRACK
	CALL	JFDCMD			;
WFDC:	IN	A,(FDCCMDSTATR)		; check ready
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
	CP	E			; if not all # sec image written
	JP	NZ,WSECD		; next sector
WTEAG:	IN	A,(FDCCMDSTATR)		; ready to write again ?
	BIT	0,A			;
	JP	Z,WTEND			; no
	LD	A,$FF			; pad with FF
	OUT	(FDCDATAREG),A		;
	JP	WTEAG			;
WTEND:	CALL	JFSTAT			;
	AND	$E7			;
	JP	NZ,UNRERR		; very bad: format failed
	;
	PUSH	DE
	LD	HL,MFMTT		; inform user about progress
	CALL	ZSDSP			;
	LD	A,(FITRKN)		; track
	LD	C,A			;
	CALL	BIN2A8			;
	LD	HL,OVAL16		;
	CALL	ZSDSP			;
	LD	HL,MFMTS		;
	CALL	ZSDSP			;
	LD	A,(CSIDE)		; side
	LD	C,A			;
	CALL	BIN2A8			;
	LD	HL,OVAL16		;
	CALL	ZSDSP			;
	LD	C,CR			;
	CALL	JCONOU			; at beginning of line
	POP	DE
	;
	LD	A,(CSIDE)		; verify side
	INC	A			; inc. side
	CP	D			; exists ?
	JR	Z,ADVTRK		; no
	LD	(CSIDE),A		; set it
	LD	C,A			;
	CALL	SETSID			; activate
	CALL	DRVSEL			; transfer to hardware
;	LD	A,(FITRKN)		; adjust trk offset
; 	ADD	E			; sum n. of tracks on side 0
; 	LD	(FITRKN),A		; done
; 	JR	SIDOK			;
	LD	A,$01			; resets sector counters
	LD	(FISECN),A		;
	LD	B,$00			;
	JP	TRSTA			; restart write
ADVTRK:	XOR	A			;
	LD	(CSIDE),A		; restore side 0
	LD	C,A			;
	CALL	SETSID			;
	CALL	DRVSEL			; transfer to hardware
	LD	A,(TCOUNT)		; get cylinder counter
	INC	A			; next track
	LD	HL,TNUMBF		;
	CP	(HL)			; EOD ?
	JP	Z,RSTART		; yes
	LD	(TCOUNT),A		; update track counters
	LD	(FITRKN),A		;
SIDOK:	LD	A,$01			; resets sector counters
	LD	(FISECN),A		;
	LD	B,$00			;
	; verify remove.........
; VL1:	DJNZ	VL1			; ?????? 000370 10 FE
; VL2:	DJNZ	VL2			; ?????? 000372 10 FE
	;
	LD	A,$53			; 1771 STEP-IN
	CALL	JFDCMD			;
	CALL	JFSTAT			;
	JP	TRSTA			; restart write

WCMND:	LD	HL,MCMDA		; 00037F 21 2A 04
	JP	DSPER

; 	JP	RSTART			;

WRNGD:	LD	HL,MCHO2		;
 	JP	DSPER			;

EXNOS:	LD	HL,MNSEL		; no sel msg
EXIT:	CALL	OUTCRLF			;
	JP	$0000			; jump to BOOT

	; restart from beginning
DSPER:	CALL	ZSDSP			;
RSTART:	LD	A,$00			; reset drives
	OUT	(FDCDRVRCNT),A		;
	LD	HL,MANOT		; ask for another
	CALL	ZSDSPCL			;
	CALL	GCHR			;
	CP	'Y'			; is 'Y' ?
	JP	NZ,EXIT		; no
	LD	C,'e'			; complete answer with (Y)es
	CALL	JCONOU			;
	LD	C,'s'			; complete answer with (Y)es
	CALL	JCONOU			;
	LD	C,CR			;
	CALL	JCONOU			;
	LD	C,LF			;
	CALL	JCONOU			;
	JP	AGAIN			;
	;
UNRERR:	LD	HL,MCRSH
	CALL	ZSDSPCL
	LD	HL,MCMDA
	JR	EXIT
	;
WAITKY:	LD	HL,MINDS
	CALL	ZSDSP
	CALL	JCONIN
	RET
	;
MCMDA:	DEFB	CR,LF,"Format aborted.",CR,LF,$00
MCFM:	DEFB	CR,LF,"Are you shure ? ",$00
MCHOI:	DEFB	"* Z80DarkStar DISK FORMAT *",CR,LF
	DEFB	CR,LF
MCHO2:	DEFB	CR,LF
	DEFB	"SELECT DISK FORMAT:",CR,LF
	DEFB	CR,LF
	DEFB	"1 - 40 TRACK, SS",CR,LF
	DEFB	"2 - 40 TRACK, DS",CR,LF
	DEFB	"3 - 80 TRACK, SS",CR,LF
	DEFB	"4 - 80 TRACK, DS",CR,LF
	DEFB	CR,LF
	DEFB	"SELECT 1-4 :"
	DEFB	$00
MNSEL:	DEFB	"NO selection, exiting...",CR,LF,$00
MCRSH:	DEFB	BEL,"UNRECOVERABLE ERROR DURING FORMAT !",CR,LF,$00
MFMTT:	DEFB	"Formatted track ",$00
MFMTS:	DEFB	", side ",$00
MUSFM:	DEFB	CR,LF,"Using format "
MUSNT:	DEFB	"00"
	DEFB	" tracks, "
MUSSD:	DEFB	"0"
	DEFB	" sides.",CR,LF,$00
MDCHO:	DEFB	"Select drive (A/B): ",$00
MANOT:	DEFB	CR,LF,"Format another ? ",$00
MINDS:	DEFB	CR,LF,"Insert disk and press any key...",CR,LF,$00

TNUMBF:	DEFB	$28			; # of tracks to format
TSIDES:	DEFB	$01			; and # of sides
TNSECT:	DEFS	1			; # if sectors per track
CSIDE:	DEFS	1			; current side register
TCOUNT:	DEFS	1			; cylinder counter
TFRMT:	DEFS	1			; users' format selection
TDRIV:	DEFS	1			; users' drive selection

	END
