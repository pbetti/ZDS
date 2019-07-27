;;
;; ZDS - parallel link binary image loader
;;

; link to monitor and bios symbols
rsym bios.sym

;
include parload.inc
;

ZDSDIRECTIO	EQU	TRUE		; enable monitor calls in cpmio.asm


	ORG	RELADR

	JP	LDER

	; include routines to print ascii values
include ../ASM/bit2040.asm
include ../ASM/cpmio.asm
include ../ASM/cbuff.asm

; CONHEX:
; 	LD	HL,$0000		; was 00F6DE 21 00 00
; GNXTC:	CALL	DOGETCHR
; GENTR:	LD	C,A
; 	CALL	CHKHEX
; 	JR	C,HNHEX			; if not hex digit
; 	ADD	HL,HL
; 	ADD	HL,HL
; 	ADD	HL,HL
; 	ADD	HL,HL
; 	OR	L
; 	LD	L,A
; 	JR	GNXTC
; HNHEX:	EX	(SP),HL
; 	PUSH	HL
; 	LD	A,C
; 	CALL	CHKCTR
; 	JR	NC,HEHEX
; 	DJNZ	UCREJ
; 	RET

	; get user input
GCHR:
	CALL	BBCONIN			; take from console
	AND	$7F			;
	CP	$60			;
	JP	M,GCDSP			; verify alpha
	CP	$7B			;
	JP	P,GCDSP			;
	RES	5,A			; convert to uppercase
GCDSP:	PUSH	BC			;
	LD	C,A			;
	CALL	BBCONOUT		;
	LD	A,C			;
	POP	BC			;
	RET				;

	;
	; Show a zero terminated string
LFEED:	LD	C,CR			;
	CALL	BBCONOUT		; send CR
	LD	C,LF			;
	CALL	BBCONOUT		; send LF
	RET
ZSDSP:	LD	A,(HL)			; pick char pointed by HL
	OR	A			; is the terminating NUL ?
	RET	Z			; yes
	PUSH	HL			; no
	LD	C,A			;
	CALL	BBCONOUT		; display it
	POP	HL			;
	INC	HL			;
	JP	ZSDSP			;

EXIT:	CALL	LFEED
	JP	$0000			; jump to BOOT

	;
	; INTERNAL STORAGE
	;
UOPER:	DEFS	1
UFILN:					; FILEBNAME BUFFER
	DEFB	254			; MAX LEN
	DEFB	0			; STR LEN
UFILNS:	DEFS	254			; string space
CMDBUF:	DEFS	8			; REMOTE COMMAND STRUCTURE
FTRHDR:	DEFB	"@FT@"
	;
	; where the real things starts...
	;
LDER:
	LD	HL,SOMSG
	CALL	ZSDSP

LDER01:	LD	HL,UDMSG
	CALL	ZSDSP
	CALL	GCHR			;
	CP	$03			; CTRL+C ?
	JP	Z,EXIT			; exit
	CP	'S'
	JR	NZ,LDER00
	LD	(UOPER),A
	LD	HL,SSEND
	CALL	ZSDSP
	JR	LDER05
LDER00:	CP	'R'
	JR	NZ,LDER01
	LD	(UOPER),A
	LD	HL,SRECE
	CALL	ZSDSP
	JR	LDER05
LDER05:	;
	CALL	LFEED
	LD	HL,SFILN
	CALL	ZSDSP
	LD	DE,UFILN		; input buffer
	CALL	CBUFF
	LD	A,(UFILN+1)		; str lenght in buffer
	OR	A
	JR	Z,LDER01
	;
	;
	; prepare command for remote
	LD	HL,FTRHDR
	LD	DE,CMDBUF
	LD	BC,4
	LDIR				; HEADER
	;
	LD	A,(UOPER)
	CP	'S'
	JR	NZ,LDER10
	LD	C, VDWRSEC		; send command
	LD	(IY + 0), C
	JR	LDER15
LDER10:	LD	C, VDRDSEC		; read command
	LD	(IY + 0), C
LDER15:	XOR	A			; drive
	LD	(IY + 1), A
	LD	BC,0			; sector
	LD	(IY + 2), C
	LD	(IY + 3), B
	;LD	BC, (FTRKBUF)		; track
	LD	(IY + 4), C
	LD	(IY + 5), B
	;
	LD	HL,CMDBUF		; command offset
	LD	BC,VDBUFSZ		; block size
	CALL	BBPSNDBLK		; send command block
	LD	A,C
	OR	A			; what happens ?
	JP	NZ,BADTRX		; tx nok
	;
	LD	HL,UFILN+1
	LD	BC,255
	CALL	BBPSNDBLK		; send filename block
	LD	A,C
	OR	A			; what happens ?
	JP	NZ,BADTRX		; tx nok
	;
	LD	A,(UOPER)
	CP	'S'
	JR	NZ,LDER20		; send data

LDER20:
	LD	HL,RDYMSG
	CALL	ZSDSP
	CALL	BBCONIN
	LD	HL,RNING
	CALL	ZSDSP
	CALL	BBUPLCHR		; in hi byte of upload offset
	LD	H,D
	CALL	BBUPLCHR		; in lo byte of upload offset
	LD	L,D
	CALL	BBUPLCHR		; in hi byte of data size
	LD	B,D
	CALL	BBUPLCHR		; in lo byte of data size
	LD	C,D
	PUSH	HL
	POP	DE
	PUSH	HL
	PUSH	BC
	LD	HL,LDMSG
	CALL	ZSDSP
	LD	L,C
	LD	H,B
	CALL	H2AEN1
	LD	HL,LDMS1
	CALL	ZSDSP
	LD	L,E
	LD	H,D
	CALL	H2AEN1
	CALL	OUTCRLF
	POP	BC
	POP	HL
	PUSH	HL
	CALL	BBPRCVBLK		; upload data block
	POP	HL
	JP	(HL)

BADTRX:
	LD	HL,IOEMSG
	CALL	ZSDSP
	JP	EXIT

;;
;; HL2ASC - convert & display HL 2 ascii
HL2ASC:
	CALL	OUTCRLF           ; was 00FA46 CD B0 FA
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
;; NIB2ASC convert lower nibble in reg A to ascii in reg C
;
NIB2ASC:
	AND	$0F             ; was 00FDE0 E6 0F
	ADD	A,$90
	DAA
	ADC	A,$40
	DAA
	LD	C,A
	RET

;;
;;
;; OUTSTR print a string using BBCONOUT
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


;;
;; OUTCRLF - CR/LF through OUTSTR
;

OUTCRLF:
	PUSH	HL			; was 00FAB0 E5
OCRLF1:	LD	HL,CRLFTAB
	CALL	ZSDSP
	POP	HL
	RET

	;
	; MESSAGES
	;
CRLFTAB:
	DEFB	CR,LF,0
SOMSG:	DEFB	$0C,"Z80DARKSTAR PARALLEL LINK BINARY LOADER",CR,LF
	DEFB	"ver 1.0 (c) 2006, Piergiorgio Betti <pbetti@lpconsul.net>",CR,LF,0
RDYMSG:	DEFB	CR,LF,LF
	DEFB	"PRESS ANY KEY WHEN REMOTE IS READY FOR DOWNLOAD...",0
RNING:	DEFB	CR,LF,LF,"LOADER RUNNING",CR,LF,0
LDMSG:	DEFB	"LOADING ",0
LDMS1:	DEFB	" BYTES AT ",0
UDMSG:	DEFB	"Select [S]end or [R]eceive : ",0
SSEND:	DEFB	"end",0
SRECE:	DEFB	"eceive",0
SFILN:	DEFB	"Filename : ",0
IOEMSG:	DEFB	"LINK I/O ERROR...",CR,LF,0

MYTOP	EQU	$

wsym parload1.sym

	END
