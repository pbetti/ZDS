;;
;; SYSINIT.ASM
;; (c) 2016 Piergiorgio Betti <pbetti@lpconsul.net>
;; This is a freeware program. You can use it without limitations.
;;
;;-----------------------------------------------------------------------------
;; Simple utility to initialize system (CP/M) boot sectors.
;;.............................................................................
;;
;; Revisions:
;; 20160309	- Initial version
;;

; load symbols from BIOS ...
	include	darkstar.equ
	include syshw.inc
;
LDRDBG	EQU	FALSE

ISHD?	macro
	xor	a
	push	hl
	ld	hl,ISHDB
	cp	(hl)
	pop	hl
	endm

ISVHD?	macro
	xor	a
	push	hl
	ld	hl,ISVHD
	cp	(hl)
	pop	hl
	endm

;
VERSMA	EQU	1			; VERSION MAJOR,MINOR
VERSMI	EQU	0
;
;--[ REAL CODE START HERE ]
;
	ORG	TPA
	;
	JP	SYSTRN
;
;--[ INTERNAL STORAGE ]
;
; VARS
STKBAS:	DEFS	64			; LOCAL STACK
STKTOP	EQU	$
SRCD:	DEFS	1			; SOURCE,DEST DISKS
DSTD:	DEFS	1
SNSEC:	DEFW	0			; S&D SECTORS #
SLSEC:	DEFW	0			; S&D SECTORS LEN
CSEC:	DEFW	0			; I/O REGISTERS: SEC
CTRK:	DEFW	0			; TRACK
COFF:	DEFW	0			; DMA
CTRN:	DEFW	0
RSEC:	DEFB	0
DSKD:	DEFB	0			; current BDOS disk
SSIZ5:	DEFW	512
;
; MESSAGES
;
LOGONM:	DEFB	CR,LF
	DEFB	"SYSINIT ",(VERSMA+'0'),'.',(VERSMI+'0')
	DEFB	CR,LF
	DEFB	"CP/M disk initialization utility."
	DEFB	CR,LF,CR,LF,0
MDESDK:	DEFB	CR,LF,"ENTER DESTINATION DISK [A-P] : ",0
MWRNGD:	DEFB	CR,LF,"WRONG DRIVE NUMBER!",CR,LF,0
MWRERR:	DEFB	CR,LF,"WRITE ERROR!",CR,LF,0
MINSED:	DEFB	CR,LF,"Insert ",0
MDESTI:	DEFB	"destination ",0
MPRESS:	DEFB	"disk and press any key..",CR,LF,0
MDONE:	DEFB	CR,LF,"CP/M + BOOTLOADER TRANSFERRED OK.",CR,LF,0
;
;--[ START ]
; prompt user for destination

SYSTRN:
	LD	SP,STKTOP		; INIT STACK
	LD	IY,SSIZ5 - 2
				
	LD	A,(FDRVBUF)		; store current drive
	LD	(DSKD),A

	LD	DE,LOGONM		; DISP LOGON
	CALL	PSTRING
	;
GOTSRC:	LD	DE,MDESDK		; ASK FOR DESTINATION
	CALL	PSTRING
	CALL	ZCI			; GET IT
	CALL	CHKDNM			; CHECK RANGE
	LD	(DSTD),A		; STORE ANSWER
	CP	$FF
	JR	NZ,GOTDST
	LD	DE,MWRNGD		; WARN USER
	CALL	PSTRING
	JR	GOTSRC			; ASK AGAIN
	;
GOTDST:
	;
	LD	HL,512			; hd sec len
STP1ALL:
	LD	(SLSEC),HL		; STORE
	EX	DE,HL			; STORE LEN IN DE AS DIVISOR
	LD	BC,8192			; STORE CP/M LEN AS DIVIDEND
	CALL	BBDIV16			; DIVIDEND
	PUSH	BC			; BC IS THE QUOTIENT
	POP	HL			; LOAD IN HL
	INC	HL			; ADD 1 FOR THE BOOTLOADER
	LD	(SNSEC),HL		; STORE #
	;
LOADED:	LD	DE,MINSED		; PROMPT USER FOR DEST. IN DRIVE
	CALL	PSTRING
	LD	DE,MDESTI
	CALL	PSTRING
	LD	DE,MPRESS
	CALL	PSTRING
	CALL	BBCONIN			; WAIT...
	CP	3			; CTL-C
	JP	Z,0			; EXIT

	XOR	A
	LD	(ISHDB),A
	LD	(ISVHD),A

	LD	IY,FLSECS		; default floppy
	LD	A,(DSTD)		; RETRIEVE DST
	CP	2			; is floppy ?
	JP	M,DOWR			; yes
	CP	14			; is IDE ?
	JP	M,WHDINI			; yes
	CP	15			; virtual hd ?
	JR	Z,WVHD			; yes (P:)
	JR	DOWR			; no, virtual floppy (O:)

WVHD:
	LD	IY,HDSECS		; hd params
	XOR	A			; will use as a flag for hd operations
	DEC	A
	LD	(ISVHD),A
	JR	DOWR

WHDINI:
	LD	IY,HDSECS		; hd params
	XOR	A			; will use as a flag for hd operations
	DEC	A
	LD	(ISHDB),A

DOWR:
	LD	L,(IY+0)		; sec. per track in HL
	LD	H,(IY+1)
	LD	E,(IY+2)		; sec. size in DE
	LD	D,(IY+3)
	CALL	BBDPRMSET
	LD	A,(DSTD)		; RETRIEVE DST
	LD	C,A
	CALL	BBDSKSEL		; CALL BIOS DIRECTLY
	;
STEP11:
	;
	; now SAVE the image
	;
	LD	HL,SYSSTO
	LD	(COFF),HL		; INIT DMA
	XOR	A
	LD	(CTRK),A		; INIT TRACK
	LD	(RSEC),A		; SEC. COUNT
DWTRK:
	LD	(CSEC),A		; SECTOR
WNSEC:	LD	BC,(COFF)		; TRANSFER PARAMS TO BIOS
	CALL	BBDMASET
	IF LDRDBG
	CALL	HEXDUMP
	CALL	OUTCRLF
	ENDIF
	LD	BC,(CTRK)
	CALL	BBTRKSET

	LD	BC,(CSEC)		; TRANSLATE SECTOR
	ISHD?
	JR	NZ,WSSEC		; read HD sector
	ISVHD?
	JR	NZ,WSVRT		; read virtual HD sector
	; ------------------------------------------------
	LD	DE,TRANS
	CALL	LSECTRA
	LD	B,H
	LD	C,L
	JR	WSSEC
WSVRT:	INC	BC
WSSEC:	CALL	BBSECSET

	ISHD?
	JR	NZ,WRIDE		; read HD sector
	ISVHD?
	JR	NZ,BWRVRT		; read virtual HD sector
	; ------------------------------------------------
	LD	A,(DSTD)		; WRITE SECTOR
	CP	2			; is real floppy ?
	JP	P,BWRVRT		; no
BWRFLO:	CALL	BBFDRVSEL		; activate driver
	CALL	BBFWRITE		; do write
	JR	WGO
BWRVRT:	CALL	BBWRVDSK		; call par. read
	JR	WGO
WRIDE:	CALL	BBHDWR			; call ide read

WGO:
	LD	HL,(COFF)
	LD	BC,(SLSEC)
	ADD	HL,BC			; NEXT DMA OFFSET
	LD	(COFF),HL
	;
	LD	A,(SNSEC)		; CHECK IMAGE SIZE
	LD	B,A
	LD	A,(RSEC)
	CP	B			; ALL SECS SAVED ?
	JR	Z,SAVED
	INC	A
	LD	(RSEC),A		; NO
	;
	LD	A,(CSEC)
	INC	A
	LD	(CSEC),A
	ISHD?
	JP	NZ,WNSEC
	ISVHD?
	JP	NZ,WNSEC
	LD	A,(CSEC)
	LD	B,(IY+0)
	CP	B			; EOT ?
	JR	Z,WNTRK
	JP	WNSEC
WNTRK:	LD	A,(CTRK)
	INC	A
	LD	(CTRK),A
	XOR	A
	JP	DWTRK

SAVED:
	LD	DE,MDONE		; ENDING
	CALL	PSTRING

	LD	A,(DSKD)		; restore default drive
	LD	C,A
	CALL	BBDSKSEL		; CALL BIOS DIRECTLY

	;
	; TERMINATION
	;
EOP:
	JP	$0000

;
;--[ ROUTINES ]
;
	;
	; APPLY SKEW FACTOR
	;
LSECTRA:
	EX      DE,HL			; HL= trans
	ADD     HL,BC			; HL= trans(sector)
	LD      L,(HL)			; L = trans(sector)
	LD      H,0			; HL= trans(sector)
	RET				; with value in HL
	; sector translation table for 512 bytes/11 sec. track (skew = 4)
TRANS:	DEFB	1,5,9,2 		; sectors 1,2,3,4
	DEFB	6,10,3,7	 	; sectors 5,6,7,8
	DEFB	11,4,8			; sectors 9,10,11


FLSECS:	DW	11
	DW	512
	DB	2			; heads
	DW	80			; tracks
HDSECS:	DW	256
	DW	512
ISHDB:	DEFB	0
ISVHD:	DEFB	0

	;
	; CHECK ENTERED DRIVE NUM
	;
CHKDNM:	CP	$60			; CONVERT UPPERCASE
	JP	M,CKRNG
	CP	$7B
	JP	P,CKRNG
	RES	5,A
CKRNG:	CP	'A'			; MUST BE BETWEEN A AND P
	JP	M,CHKDKO
	CP	'Q'
	JP	P,CHKDKO
	SUB	'A'			; OK
	RET
CHKDKO:	LD	A,$FF
	RET

; Print a string in [DE] up to '$'
PSTRING:
	PUSH	BC
	PUSH	DE
	PUSH	HL
	EX	DE,HL
PSTRX:	LD	A,(HL)
	CP	'$'
	JP	Z,DONEP
	CP	0
	JP	Z,DONEP
	LD	C,A
	CALL	ZCO
	INC	HL
	JP	PSTRX
DONEP:	POP	HL
	POP	DE
	POP	BC
	RET

ZCO:	PUSH	AF	;Write character that is in [C]
	CALL	BBCONOUT
	POP	AF
	RET

ZCI:	;Return keyboard character in [A]
	PUSH	BC
	PUSH	DE
	PUSH	HL
	CALL	BBCONIN
	CP	3			; CTL-C
	JP	Z,0			; EXIT
	PUSH	AF
	LD	C,A
	CALL	BBCONOUT
	POP	AF
	POP	HL
	POP	DE
	POP	BC
	RET

	IF LDRDBG

;;
;; Inline print
;;
INLINE:
	EX	(SP),HL			; get address of string (ret address)
	CALL	PSTRING
	EX	(SP),HL			; load return address after the '$'
	RET				; back to code immediately after string

PHEX:	PUSH	AF
	PUSH	BC
	PUSH	AF
	RRCA
	RRCA
	RRCA
	RRCA
	CALL	ZCONV
	POP	AF
	CALL	ZCONV
	POP	BC
	POP	AF
	RET
;
ZCONV:	AND	0FH		;HEX to ASCII and print it
	ADD	A,90H
	DAA
	ADC	A,40H
	DAA
	LD	C,A
	CALL	BBCONOUT
	RET
OLDSTACK:
	DEFW	0
	DEFS	40
NEWSTACK:
	DEFW	0

;
HL2ASC:
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
;; HL2ASCB - convert & display HL 2 ascii leave a blank after
HL2ASCB:
	CALL	HL2ASC           ; was 00FA63 CD 46 FA
SPACER:	LD	C,$20
	CALL	BBCONOUT
	RET

NIB2ASC:
	AND	$0F             ; was 00FDE0 E6 0F
	ADD	A,$90
	DAA
	ADC	A,$40
	DAA
	LD	C,A
	RET

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


;; OUTCRLF - CR/LF through OUTSTR
;

OUTCRLF:
	PUSH	HL			; was 00FAB0 E5
OCRLF1:	LD	HL,CRLFTAB
	CALL	OUTSTR
	POP	HL
	RET

CRLFTAB:
	DB	$0D,$8A

ZCRLF:
	PUSH	AF
	LD	C,CR
	CALL	ZCO
	LD	C,LF
	CALL	ZCO
	POP	AF
	RET

ZBITS:	PUSH	AF
	PUSH	BC
	PUSH	DE
	LD	E,A
	LD	B,8
BQ2:	SLA	E		;Z80 Op code for SLA A,E
	LD	A,18H
	ADC	A,A
	LD	C,A
	CALL	ZCO
	DJNZ	BQ2
	POP	DE
	POP	BC
	POP	AF
	RET

HEXDUMP:			;print a hexdump of the data in the 512 byte buffer (@DMA)
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL

	LD	HL,(FRDPBUF)
	PUSH	HL
	LD	DE,256
	ADD	HL,DE
	LD	E,L
	LD	D,H
	POP	HL
	CALL	MEMDUMP

	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET

MEMDUMP:
	EXX
	LD	B,255	; row counter, for the sake of simplicity
	EXX
	LD	(DMASAVE),HL
MDP6:
	PUSH	HL
	LD	HL,(DMASAVE)
	LD	C,L
	LD	B,H
	POP	HL
	PUSH	HL
	SBC	HL,BC
; 	CALL	HL2ASCB
; 	CALL	SPACER
	CALL	OUTCRLF
	POP	HL
	LD	A,L
; 	CALL	DMPALIB
	PUSH	HL
MDP2:	LD	A,(HL)
	CALL	H2AJ1
	CALL	CHKEOR
	JR	C,MDP1
	CALL	SPACER
	LD	A,L
	AND	$0F
	JR	NZ,MDP2
MDP7:	POP	HL
	LD	A,L
	AND	$0F
; 	CALL	DMPALIA
MDP5:	LD	A,(HL)
	LD	C,A
	CP	$20
	JR	C,MDP3
	JR	MDP4
MDP3:	LD	C,$2E
MDP4:	CALL	ZCO
	CALL	CHKBRK
	LD	A,L
	AND	$0F
	JR	NZ,MDP5
	JR	MDP6
MDP1:	SUB	E
; 	CALL	DMPALIB
	call	spacer
	JR	MDP7

;;
CBKEND:	POP	DE
	RET

CHKBRK:
	CALL	CHKEOR			; was 00F949 CD 3C F9
	JR	C,CBKEND
	CALL	ZCSTS
	OR	A
	RET	Z
	CALL	COIUPC
	CP	$13
	JR	NZ,CBKEND
; 	JP	COIUPC
;;
;;
;; COIUPC- convert reg A uppercase
COIUPC:
	CALL	ZCI
	CP	$60
	JP	M,COIRE
	CP	$7B
	JP	P,COIRE
	RES	5,A
COIRE:	RET

;;
WPAUSE:
	LD	DE,WPAUSEMSG
	CALL	PSTRING
	CALL	ZCI
	RET
;;
;; DMPALIB - beginning align (spacing) for a memdump
DMPALIB:
	AND	$0F
	LD	B,A
	ADD	A,A
	ADD	A,B
;;
;; DMPALIB - ascii align (spacing) for a memdump
DMPALIA:
	LD	B,A
	INC	B
ALIBN:	CALL	SPACER
	DJNZ	ALIBN
	RET

;; inc HL and do a 16 bit compare between HL and DE
CHKEOR:
	INC	HL
	LD	A,H
	OR	L
	SCF
	RET	Z
	LD	A,E
	SUB	L
	LD	A,D
	SBC	A,H
	RET

ZCSTS:
	PUSH	BC
	PUSH	DE
	PUSH	HL
	CALL	BBCONST
	POP	HL
	POP	DE
	POP	BC
	CP	1
	RET

AUTO:		DB	0
DMASAVE		DW	0
DMPPAUSE	DB	0
WPAUSEMSG	DB	"-- more --",CR,LF,'$'

	ENDIF

;--[ END OF PROGRAM ]
; after this point system image will be loaded...
;
SYSSTO	EQU	$
	; binary image of bootloader
incbin bootload.bin
	ORG SYSSTO+512
	; binary image of cpm3 loader
incbin cpmldr.com

; REAL END
	END

;--EOF
