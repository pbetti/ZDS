;
; NDOSBOOT
; NEDOS BOOT FROM CP/M 8-)
;
; link to DarkStar Monitor symbols...
rsym ../../bios.sym

NDISPGRCH	EQU	DISPCH
GRAM0BUF	EQU	$3040
GRAM1BUF	EQU	$3041
GRAM2BUF	EQU	$3042
GRAM3BUF	EQU	$3043
LOADOFFS	EQU	$9F80	; where it will be...

CODESIZE	EQU	ENDCODE - LOADOFFS

	ORG	LOADOFFS

NDSPAR	DEFS	128
GOBOOT:
	LD	SP,NDSPAR
	LD	BC,$0000
	CALL	BSETTRK
; 	INC	A
; 	OUT	(FDCDRVRCNT),A
	CALL	HOME
; 	JP	NZ,TOCPM
	JP	NDOSSTA           ; 00F3FD C3 03 F4

NEDOSCR:
	; -------------------
	CALL   CLRSCRGR
	LD     HL,STR005
	CALL   DISPSTR
	LD     HL,STR006
	CALL   DISPSTR
	LD     HL,STR007
	CALL   DISPSTR
NDSLP3:	LD     A,$FF
	LD     (GRAM3BUF),A
	LD     HL,STR009
	CALL   DISPSTR
	LD     HL,$0526
	CALL   SDCUAE
	CALL   GETKBD
	LD     HL,(STR008)
	PUSH   HL
	CALL   SDCUAE
	POP    HL
	; BLANK STR008 SPACE
	LD     B,$1A
NDSLP0:	LD     A,$20
	CALL   NDISPGRCH
	DJNZ   NDSLP0
	LD     HL,$0526
	CALL   SDCUAE
	XOR    A
	OUT    (FDCDRVRCNT),A
	OUT    (FDCCMDSTATR),A
NDSLP2:
	EX     (SP),HL
	EX     (SP),HL
	IN     A,(FDCCMDSTATR)
	BIT    1,A
	JR     Z,NDSLP1
	LD     A,FDCCMDSTATR
	OUT    (FDCCMDSTATR),A
	JR     NDSLP2
NDSLP1:
	LD     HL,$0000
	LD     ($9000),HL
	LD     HL,$1500
	LD     ($9002),HL
	LD     A,$01
	OUT    (FDCDRVRCNT),A
	LD     B,$05
NDSJ1:	LD     A,$0B
	OUT    (FDCCMDSTATR),A
	EX     (SP),HL
	EX     (SP),HL
	DJNZ   NDSJ1
NDSJ2:	IN     A,(FDCCMDSTATR)
	BIT    0,A
	JR     NZ,NDSJ2
NDSJ5:	LD     DE,($9002)
	LD     HL,($9000)
	CALL   NDSRDSEC
	LD     A,($9002)
	INC    A
	CP     $0A
	JR     NZ,NDSJ3
	LD     A,($9003)
	INC    A
	LD     ($9003),A
	XOR    A
NDSJ3:	LD     ($9002),A
	DEC    HL
	LD     A,(HL)
	LD     ($9001),A
	DEC    HL
	LD     A,(HL)
	LD     ($9000),A
	DEC    HL
	LD     A,(HL)
	CP     $01
	JR     NZ,NDSJ4
	DEC    HL
	LD     A,(HL)
	CP     $01
	JR     Z,NDSJ5
	RST    00H
NDSJ4:	LD     HL,STR008
	XOR    A
	OUT    (FDCDRVRCNT),A
	LD     A,$F0
	LD     (RAM3BUF),A
	CALL   DISPSTR
	JP     NDSLP3
;;
NDSRDSEC:
	LD     A,E
	OUT    (FDCSECTREG),A
	LD     A,D
	OUT    (FDCDATAREG),A
	LD     A,$1A
	OUT    (FDCCMDSTATR),A
	EX     (SP),HL
	EX     (SP),HL
NRD1:	IN     A,(FDCCMDSTATR)
	RRCA
	JR     C,NRD1
	LD     A,$88
	OUT    (FDCCMDSTATR),A
	PUSH   BC
	POP    BC
	JR     NRD2
NRD4:	RRCA
	JR     NC,NRD3
NRD2:	IN     A,(FDCCMDSTATR)
	BIT    1,A
	JR     Z,NRD4
	IN     A,(FDCDATAREG)
	LD     (HL),A
	INC    HL
	JR     NRD2
NRD3:	IN     A,(FDCCMDSTATR)
	AND    $5C
	RET    Z
	LD     A,FDCCMDSTATR
	OUT    (FDCCMDSTATR),A
	RET
;;
;; NDSHW - TEST VIDEO HARDWARE FOR NEDOS
NDSHW:
	LD     HL,$7F00
	LD     ($9006),HL
	XOR    A
	EX     AF,AF'
	LD     HL,$FFFF
	LD     (GRAM0BUF),HL
	LD     HL,$EFFF
	LD     (GRAM2BUF),HL
	CALL   NFILVRAMG
	CALL   RDRR19R12
	LD     HL,$0780
NDH1:	IN     A,(CRT6545ADST)
	BIT    7,A
	JR     Z,NDH1
	IN     A,(CRTRAM0DAT)
	INC    A
	JR     NZ,NDH2
	IN     A,(CRTRAM1DAT)
	INC    A
	JR     NZ,NDH2
	IN     A,(CRTRAM2DAT)
	INC    A
	JR     Z,NDH3
NDH2:	LD     ($9004),SP
	LD     SP,($9006)
	PUSH   HL
	LD     ($9006),SP
	LD     SP,($9004)
	EX     AF,AF'
	LD     A,$01
	EX     AF,AF'
NDH3:	DEC    HL
	XOR    A
	OUT    (CRT6545DATA),A
	LD     A,H
	OR     L
	JR     NZ,NDH1
	CALL   RDRR19R12
	EX     AF,AF'
	OR     A
	JR     Z,NDH4
	CALL   CLRSCRGR
	LD     HL,STR010
	CALL   DISPSTR
	LD     HL,$0140
	CALL   SDCUAE
	LD     ($9004),SP
NDH7:	LD     A,$20
	CALL   NDISPGRCH
	LD     SP,($9006)
	POP    HL
	LD     ($9006),SP
	LD     A,H
	ADD    A,$30
	CALL   NDISPGRCH
	LD     H,$00
	ADD    HL,HL
	ADD    HL,HL
	ADD    HL,HL
	ADD    HL,HL
	LD     A,H
	CP     $0A
	JR     C,NDH5
	ADD    A,$07
NDH5:	ADD    A,$30
	CALL   NDISPGRCH
	OR     A
	LD     A,L
	RRA
	RRA
	RRA
	RRA
	CP     $0A
	JR     C,NDH6
	ADD    A,$07
NDH6:	ADD    A,$30
	CALL   NDISPGRCH
	LD     A,($9007)
	CP     $7F
	JR     NZ,NDH7
	LD     SP,($9004)
	LD     HL,STR011
	CALL   DISPSTR
	CALL   SCUROF
	CALL   GETKBD
NDH4:	JP     CLRSCRGR

;--------------------------------------------------------

STR001:                        ; 00F301
	; -------------------
	db    $0b,$01
	db    "GRAFIC - MONITOR 1.0",$00
STR002:                        ; 00F318
	db    $04,$02
	db    "type",$00
STR003:                        ; 00F31F
	db    $3a,$03
	db    $22,"ESC",$22," for BOOTSTRAPPING",$00
STR004:                        ; 00F339
        db    $d9,$03
	db    $22,"RETURN",$22," for testing VIDEO",$00
STR005:                        ; 00F356
	db    $08,$01
	db    "BOOTSTRAP Version GRAFIC 1.0",$00
STR006:                        ; 00F375
	db    $9f,$01
	db    "Insert NE-DOS-DISK Version GRAFIC in drive 0",$00
STR007:                        ; 00F3A4
	db    $4e,$02
	db    "then type a key",$00
STR008:                        ; 00F3B6
	db    $89,$03
	db    " No NE-DOS Version GRAFIC ",$00
STR009:                        ; 00F3D3
	db    $25,$05
	db    "> <",$00
STR010:                        ; 00F3D9
	db    $0e,$00
	db    "Errorpoints :",$00
STR011:                        ; 00F3E9
	db    $28,$00
	db    "Please type a key",$00
;;
;;
NDOSSTA:
	IN     A,(CRT6545ADST)         ; 00F403 DB 8C
	XOR    A               ; 00F405 AF
	OUT    (FDCDRVRCNT),A         ; 00F406 D3 D6
	DI                     ; 00F408 F3
	LD     SP,$7000        ; 00F409 31 00 70
	CALL   INICRT           ; 00F40C CD A5 F0
NDST1:	CALL   NDSHW           ; 00F40F CD 27 F2
	LD     HL,STR001        ; 00F412 21 01 F3
	CALL   DISPSTR           ; 00F415 CD E1 F2
	LD     HL,STR002        ; 00F418 21 18 F3
	CALL   DISPSTR           ; 00F41B CD E1 F2
	LD     HL,STR003        ; 00F41E 21 1F F3
	CALL   DISPSTR           ; 00F421 CD E1 F2
	LD     HL,STR004        ; 00F424 21 39 F3
	CALL   DISPSTR           ; 00F427 CD E1 F2
	LD     HL,STR009        ; 00F42A 21 D3 F3
	CALL   DISPSTR           ; 00F42D CD E1 F2
	LD     HL,$0526        ; 00F430 21 26 05
	CALL   SDCUAE           ; 00F433 CD 60 F0
KBLP0:
	CALL   GETKBD           ; 00F436 CD 94 F0
	CP     $1B             ; 00F439 FE 1B
	JP     Z,NEDOSCR         ; 00F43B CA 3D F1
	CP     $0D             ; 00F43E FE 0D
	JR     Z,NDST1         ; 00F440 28 CD
	JR     TOCPM           ; 00F442 18 F2

;;
;; NDISPGR - Display a full graphic char frpm GRAMBUF
;
NDISPGR:
	IN     A,(CRT6545ADST)         ; 00F044 DB 8C
	BIT    7,A             ; 00F046 CB 7F
	JR     Z,NDISPGR         ; 00F048 28 FA
	LD     HL,GRAM0BUF        ; 00F04A 21 40 30
	LD     A,(HL)          ; 00F04D 7E
	OUT    (CRTRAM0DAT),A         ; 00F04E D3 80
	INC    HL              ; 00F050 23
	LD     A,(HL)          ; 00F051 7E
	OUT    (CRTRAM1DAT),A         ; 00F052 D3 84
	INC    HL              ; 00F054 23
	LD     A,(HL)          ; 00F055 7E
	OUT    (CRTRAM2DAT),A         ; 00F056 D3 88
	INC    HL              ; 00F058 23
	LD     A,(HL)          ; 00F059 7E
	OUT    (CRTRAM3PORT),A         ; 00F05A D3 8E
	XOR    A               ; 00F05C AF
	OUT    (CRT6545DATA),A         ; 00F05D D3 8D
	RET                    ; 00F05F C9
;;
;; NFILVRAMG - Fill the video ram in graphic mode (from GRAMBUF)
;
NFILVRAMG:
	LD     HL,$0000        ; 00F126 21 00 00
	CALL   RDRR19R12           ; 00F129 CD D8 F0
NFVLP0:	PUSH   HL              ; 00F12C E5
	CALL   NDISPGR           ; 00F12D CD 44 F0
	POP    HL              ; 00F130 E1
	INC    HL              ; 00F131 23
	LD     A,H             ; 00F132 7C
	CP     $07             ; 00F133 FE 07
	JR     NZ,NFVLP0        ; 00F135 20 F5
	LD     A,L             ; 00F137 7D
	CP     $80             ; 00F138 FE 80
	JR     NZ,NFVLP0        ; 00F13A 20 F0
	RET                    ; 00F13C C9

;;
;; GETKBD - wait for a key and return in A
;
GETKBD:
	; wait for strobe clean
	IN	A,(CRTKEYBDAT)		; was 00F094 DB 85
	CPL
	BIT	7,A
	JR	NZ,GETKBD
	; wait for keypress
GKLP0:	IN	A,(CRTKEYBDAT)
	CPL
	BIT	7,A
	JR	Z,GKLP0
	AND	$7F
	RET
;;
TOCPM:
	JP	$0000

ENDCODE	EQU	$

wsym ndosboot.sym

