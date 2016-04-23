
	TITLE	'CP/M BDOS Interface, BDOS, Version 3.0 Dec, 1982'
;*****************************************************************
;*****************************************************************
;**                                                             **
;**   B a s i c    D i s k   O p e r a t i n g   S y s t e m    **
;**								**
;**            I n t e r f a c e   M o d u l e                  **
;**                                                             **
;*****************************************************************
;*****************************************************************
;
;	Copyright (c) 1978, 1979, 1980, 1981, 1982
;	Digital Research
;	Box 579, Pacific Grove
;	California
;
;       December 1982
;
ON	EQU	-1
OFF	EQU	0
TRUE	EQU	ON
FALSE	EQU	OFF
;
MPM	EQU	OFF
BANKED	EQU	ON

;
; [JCE] Have the date and copyright messages in only one source file
;
@BDATE	MACRO
	DEFB	'101198'
	ENDM

@LCOPY	MACRO
	DEFB	'COPYRIGHT 1998, '
	DEFB	'CALDERA, INC.   '
	ENDM

@SCOPY	MACRO
	DEFB	'(C) 98 CALDERA'
	ENDM
;
;	equates for non graphic characters
;

CTLA	EQU	01H		; control a
CTLB	EQU	02H		; control b
CTLC	EQU	03H		; control c
CTLE	EQU	05H		; physical eol
CTLF	EQU	06H		; control f
CTLG	EQU	07H		; control g
CTLH	EQU	08H		; backspace
CTLK	EQU	0BH		; control k
CTLP	EQU	10H		; prnt toggle
CTLQ	EQU	11H		; start screen
CTLR	EQU	12H		; repeat line
CTLS	EQU	13H		; stop screen
CTLU	EQU	15H		; line delete
CTLW	EQU	17H		; control w
CTLX	EQU	18H		; =ctl-u
CTLZ	EQU	1AH		; end of file
RUBOUT	EQU	7FH		; char delete
TAB	EQU	09H		; tab char
CR	EQU	0DH		; carriage return
LF	EQU	0AH		; line feed
CTL	EQU	5EH		; up arrow

; 	ORG	0000H
BASE		EQU	$

; Base page definitions

BNKBDOS$PG 	EQU	BASE+0FC00H
RESBDOS$PG 	EQU	BASE+0FD00H
SCB$PG		EQU	BASE+0FB00H
BIOS$PG 	EQU	BASE+0FF00H

; Bios equates

BIOS		EQU	BIOS$PG
BOOTF		EQU	BIOS$PG		; 00. cold boot function

	IF BANKED

WBOOTF		EQU	SCB$PG+68H	; 01. warm boot function
CONSTF		EQU	SCB$PG+6EH	; 02. console status function
CONINF		EQU	SCB$PG+74H	; 03. console input function
CONOUTF 	EQU	SCB$PG+7AH	; 04. console output function
LISTF		EQU	SCB$PG+80H	; 05. list output function

	ELSE

WBOOTF		EQU	BIOS$PG+3	; 01. warm boot function
CONSTF		EQU	BIOS$PG+6	; 02. console status function
CONINF		EQU	BIOS$PG+9	; 03. console input function
CONOUTF 	EQU	BIOS$PG+12	; 04. console output function
LISTF		EQU	BIOS$PG+15	; 05. list output function

	ENDIF

PUNCHF		EQU	BIOS$PG+18	; 06. punch output function
READERF 	EQU	BIOS$PG+21	; 07. reader input function
HOMEF		EQU	BIOS$PG+24	; 08. disk home function
SELDSKF 	EQU	BIOS$PG+27	; 09. select disk function
SETTRKF 	EQU	BIOS$PG+30	; 10. set track function
SETSECF 	EQU	BIOS$PG+33	; 11. set sector function
SETDMAF 	EQU	BIOS$PG+36	; 12. set dma function
READF		EQU	BIOS$PG+39	; 13. read disk function
WRITEF		EQU	BIOS$PG+42	; 14. write disk function
LISTSTF 	EQU	BIOS$PG+45	; 15. list status function
SECTRAN 	EQU	BIOS$PG+48	; 16. sector translate
CONOUTSTF 	EQU	BIOS$PG+51	; 17. console output status function
AUXINSTF 	EQU	BIOS$PG+54	; 18. aux input status function
AUXOUTSTF 	EQU	BIOS$PG+57	; 19. aux output status function
DEVTBLF 	EQU	BIOS$PG+60	; 20. retunr device table address fx
DEVINITF 	EQU	BIOS$PG+63	; 21. initialize device function
DRVTBLF 	EQU	BIOS$PG+66	; 22. return drive table address
MULTIOF 	EQU	BIOS$PG+69	; 23. multiple i/o function
FLUSHF		EQU	BIOS$PG+72	; 24. flush function
MOVEF		EQU	BIOS$PG+75	; 25. memory move function
TIMEF		EQU	BIOS$PG+78	; 26. system get/set time function
SELMEMF	 	EQU	BIOS$PG+81	; 27. select memory function
SETBNKF 	EQU	BIOS$PG+84	; 28. set dma bank function
XMOVEF		EQU	BIOS$PG+87	; 29. extended move function

	IF BANKED

; System Control Block equates

OLOG		EQU	SCB$PG+090H
RLOG		EQU	SCB$PG+092H

SCB		EQU	SCB$PG+09CH

; Expansion Area - 6 bytes

HASHL		EQU	SCB$PG+09CH
HASH		EQU	SCB$PG+09DH
VERSION 	EQU	SCB$PG+0A1H

; Utilities Section - 8 bytes

UTIL$FLGS 	EQU	SCB$PG+0A2H
DSPL$FLGS 	EQU	SCB$PG+0A6H

; CLP Section - 4 bytes

CLP$FLGS 	EQU	SCB$PG+0AAH
CLP$ERRCDE 	EQU	SCB$PG+0ACH

; CCP Section - 8 bytes

CCP$COMLEN 	EQU	SCB$PG+0AEH
CCP$CURDRV 	EQU	SCB$PG+0AFH
CCP$CURUSR 	EQU	SCB$PG+0B0H
CCP$CONBUFF 	EQU	SCB$PG+0B1H
CCP$FLGS 	EQU	SCB$PG+0B3H

; Device I/O Section - 32 bytes

CONWIDTH 	EQU	SCB$PG+0B6H
COLUMN		EQU	SCB$PG+0B7H
CONPAGE 	EQU	SCB$PG+0B8H
CONLINE 	EQU	SCB$PG+0B9H
CONBUFFADD 	EQU	SCB$PG+0BAH
CONBUFFLEN 	EQU	SCB$PG+0BCH
CONIN$RFLG 	EQU	SCB$PG+0BEH
CONOUT$RFLG 	EQU	SCB$PG+0C0H
AUXIN$RFLG 	EQU	SCB$PG+0C2H
AUXOUT$RFLG 	EQU	SCB$PG+0C4H
LSTOUT$RFLG 	EQU	SCB$PG+0C6H
PAGE$MODE 	EQU	SCB$PG+0C8H
PM$DEFAULT 	EQU	SCB$PG+0C9H
CTLH$ACT 	EQU	SCB$PG+0CAH
RUBOUT$ACT 	EQU	SCB$PG+0CBH
TYPE$AHEAD 	EQU	SCB$PG+0CCH
CONTRAN 	EQU	SCB$PG+0CDH
CONMODE 	EQU	SCB$PG+0CFH
OUTDELIM 	EQU	SCB$PG+0D3H
LISTCP		EQU	SCB$PG+0D4H
QFLAG		EQU	SCB$PG+0D5H

; BDOS Section - 42 bytes

SCBADD		EQU	SCB$PG+0D6H
DMAAD		EQU	SCB$PG+0D8H
OLDDSK		EQU	SCB$PG+0DAH
INFO		EQU	SCB$PG+0DBH
RESEL		EQU	SCB$PG+0DDH
RELOG		EQU	SCB$PG+0DEH
FX		EQU	SCB$PG+0DFH
USRCODE 	EQU	SCB$PG+0E0H
DCNT		EQU	SCB$PG+0E1H
;searcha	equ	scb$pg+0e3h
SEARCHL 	EQU	SCB$PG+0E5H
MULTCNT 	EQU	SCB$PG+0E6H
ERRORMODE 	EQU	SCB$PG+0E7H
SEARCHCHAIN 	EQU	SCB$PG+0E8H
TEMP$DRIVE 	EQU	SCB$PG+0ECH
ERRDRV		EQU	SCB$PG+0EDH
MEDIA$FLAG 	EQU	SCB$PG+0F0H
BDOS$FLAGS 	EQU	SCB$PG+0F3H
STAMP		EQU	SCB$PG+0F4H
COMMONBASE 	EQU	SCB$PG+0F9H
ERROR		EQU	SCB$PG+0FBH	;jmp error$sub
BDOSADD 	EQU	SCB$PG+0FEH

; Resbdos equates

RESBDOS 	EQU	RESBDOS$PG
MOVE$OUT 	EQU	RESBDOS$PG+9	; a=bank #, hl=dest, de=srce
MOVE$TPA 	EQU	RESBDOS$PG+0CH	; a=bank #, hl=dest, de=srce
SRCH$HASH 	EQU	RESBDOS$PG+0FH	; a=bank #, hl=hash table addr
HASHMX		EQU	RESBDOS$PG+12H	; max hash search dcnt
RD$DIR$FLAG 	EQU	RESBDOS$PG+14H	; directory read flag
MAKE$XFCB 	EQU	RESBDOS$PG+15H	; make function flag
FIND$XFCB 	EQU	RESBDOS$PG+16H	; search function flag
XDCNT		EQU	RESBDOS$PG+17H	; dcnt save for empty fcb,
	; user 0 fcb, or xfcb
XDMAAD		EQU	RESBDOS$PG+19H	; resbdos dma copy area addr
CURDMA		EQU	RESBDOS$PG+1BH	; current dma
COPY$CR$ONLY 	EQU	RESBDOS$PG+1DH; dont restore fcb flag
USER$INFO 	EQU	RESBDOS$PG+1EH	; user fcb address
KBCHAR		EQU	RESBDOS$PG+20H	; conbdos look ahead char
QCONINX 	EQU	RESBDOS$PG+21H	; qconin mov a,m routine

	ELSE

MOVE$OUT 	EQU	MOVEF
MOVE$TPA 	EQU	MOVEF

	ENDIF

;
SERIAL:	DEFB	'654321'
;
;	Enter here from the user's program with function number in c,
;	and information address in d,e
;

BDOSE:	; Arrive here from user programs
	EX	DE,HL
	LD	(INFO),HL
	EX	DE,HL		; info=de, de=info

	LD	A,C
	LD	(FX),A
	CP	14
	JP	C,BDOSE2
	LD	HL,0
	LD	(DIR$CNT),HL	; dircnt,multnum = 0
	LD	A,(OLDDSK)
	LD	(SELDSK),A	; Set seldsk

	IF BANKED
	DEC	A
	LD	(COPY$CR$INIT),A
	ENDIF

	; If mult$cnt ~= 1 then read or write commands
	; are handled by the shell
	LD	A,(MULTCNT)
	DEC	A
	JP	Z,BDOSE2
	LD	HL,MULT$FXS
BDOSE1:
	LD	A,(HL)
	OR	A
	JP	Z,BDOSE2
	CP	C
	JP	Z,SHELL
	INC	HL
	JP	BDOSE1
BDOSE2:
	LD	A,E
	LD	(LINFO),A	; linfo = low(info) - don't equ
	LD	HL,0
	LD	(ARET),HL	; Return value defaults to 0000
	LD	(RESEL),HL	; resel,relog = 0
	; Save user's stack pointer, set to local stack
	ADD	HL,SP
	LD	(ENTSP),HL	; entsp = stackptr

	IF NOT BANKED
	LD	SP,LSTACK	; local stack setup
	ENDIF

	LD	HL,GOBACK	; Return here after all functions
	PUSH	HL		; jmp goback equivalent to ret
	LD	A,C
	CP	NFUNCS
	JP	NC,HIGH$FXS	; Skip if invalid #
	LD	C,E		; possible output character to c
	LD	HL,FUNCTAB
	JP	BDOS$JMP
	; look for functions 98 ->
HIGH$FXS:
	CP	128
	JP	NC,TEST$152
	SUB	98
	JP	C,LRET$EQ$FF	; Skip if function < 98
	CP	NFUNCS2
	JP	NC,LRET$EQ$FF
	LD	HL,FUNCTAB2
BDOS$JMP:
	LD	E,A
	LD	D,0		; de=func, hl=.ciotab
	ADD	HL,DE
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)		; de=functab(func)
	LD	HL,(INFO)	; info in de for later xchg
	EX	DE,HL
	JP	(HL)		; dispatched

;	   CAUTION: In banked systems only,
;          error$sub is referenced indirectly by the SCB ERROR
; 	   field in RESBDOS as (0fc7ch).  This value is converted
; 	   to the actual address of error$sub by GENSYS.  If the offset
; 	   of error$sub is changed, the SCB ERROR value must also
; 	   be changed.

;
;	error subroutine
;

ERROR$SUB:
	LD	B,0
	PUSH	BC
	DEC	C
	LD	HL,ERRTBL
	ADD	HL,BC
	ADD	HL,BC
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	CALL	ERRFLG
	POP	BC
	LD	A,(ERRORMODE)
	OR	A
	RET	NZ
	JP	REBOOTE

MULT$FXS: DEFB	20,21,33,34,40,0

	IF BANKED
	@LCOPY
	@BDATE
	DEFS	5
	ELSE
	@SCOPY
	@BDATE

	;	31 level stack

	DEFW	0C7C7H,0C7C7H,0C7C7H,0C7C7H,0C7C7H,0C7C7H,0C7C7H
	DEFW	0C7C7H,0C7C7H,0C7C7H,0C7C7H,0C7C7H,0C7C7H,0C7C7H,0C7C7H
	DEFW	0C7C7H,0C7C7H,0C7C7H,0C7C7H,0C7C7H,0C7C7H,0C7C7H,0C7C7H
	DEFW	0C7C7H,0C7C7H,0C7C7H,0C7C7H,0C7C7H,0C7C7H,0C7C7H,0C7C7H
LSTACK:

	ENDIF

;	dispatch table for functions

FUNCTAB:
	DEFW	REBOOTX1, FUNC1, FUNC2, FUNC3
	DEFW	PUNCHF, LISTF, FUNC6, FUNC7
	DEFW	FUNC8, FUNC9, FUNC10, FUNC11
DISKF	EQU	($-FUNCTAB)/2	; disk funcs
	DEFW	FUNC12,FUNC13,FUNC14,FUNC15
	DEFW	FUNC16,FUNC17,FUNC18,FUNC19
	DEFW	FUNC20,FUNC21,FUNC22,FUNC23
	DEFW	FUNC24,FUNC25,FUNC26,FUNC27
	DEFW	FUNC28,FUNC29,FUNC30,FUNC31
	DEFW	FUNC32,FUNC33,FUNC34,FUNC35
	DEFW	FUNC36,FUNC37,FUNC38,FUNC39
	DEFW	FUNC40,LRET$EQ$FF,FUNC42,FUNC43
	DEFW	FUNC44,FUNC45,FUNC46,FUNC47
	DEFW	FUNC48,FUNC49,FUNC50
NFUNCS	EQU	($-FUNCTAB)/2

FUNCTAB2:
	DEFW	FUNC98,FUNC99
	DEFW	FUNC100,FUNC101,FUNC102,FUNC103
	DEFW	FUNC104,FUNC105,FUNC106,FUNC107
	DEFW	FUNC108,FUNC109,FUNC110,FUNC111
	DEFW	FUNC112

NFUNCS2 EQU	($-FUNCTAB2)/2

ERRTBL:
	DEFW	PERMSG
	DEFW	RODMSG
	DEFW	ROFMSG
	DEFW	SELMSG
	DEFW	0
	DEFW	0
	DEFW	PASSMSG
	DEFW	FXSTSMSG
	DEFW	WILDMSG

TEST$152:
	CP	152
	RET	NZ

;
;	PARSE version 3.0b  Oct 08 1982 - Doug Huskey
;
;
	; DE->.(.filename,.fcb)
	;
	; filename = [d:]file[.type][;password]
	;
	; fcb assignments
	;
	;   0     => drive, 0 = default, 1 = A, 2 = B, ...
	;   1-8   => file, converted to upper case,
	;            padded with blanks (left justified)
	;   9-11  => type, converted to upper case,
	;	     padded with blanks (left justified)
	;   12-15 => set to zero
	;   16-23 => password, converted to upper case,
	;	     padded with blanks
	;   24-25 => 0000h
	;   26    => length of password (0 - 8)
	;
	; Upon return, HL is set to FFFFH if DE locates
	;            an invalid file name;
	; otherwise, HL is set to 0000H if the delimiter
	;            following the file name is a 00H (NULL)
	; 	     or a 0DH (CR);
	; otherwise, HL is set to the address of the delimiter
	;            following the file name.
	;
	LD	HL,STHL$RET
	PUSH	HL
	LD	HL,(INFO)
	LD	E,(HL)		;get first parameter
	INC	HL
	LD	D,(HL)
	PUSH	DE		;save .filename
	INC	HL
	LD	E,(HL)		;get second parameter
	INC	HL
	LD	D,(HL)
	POP	HL		;DE=.fcb  HL=.filename
	EX	DE,HL
PARSE0:
	PUSH	HL		;save .fcb
	XOR	A
	LD	(HL),A		;clear drive byte
	INC	HL
	LD	BC,20H*256+11
	CALL	PAD		;pad name and type w/ blanks
	LD	BC,4
	CALL	PAD		;EXT, S1, S2, RC = 0
	LD	BC,20H*256+8
	CALL	PAD		;pad password field w/ blanks
	LD	BC,12
	CALL	PAD		;zero 2nd 1/2 of map, cr, r0 - r2
;
;	skip spaces
;
	CALL	SKPS
;
;	check for drive
;
	LD	A,(DE)
	CP	':'		;is this a drive?
	DEC	DE
	POP	HL
	PUSH	HL		;HL = .fcb
	JP	NZ,PARSE$NAME
;
;	Parse the drive-spec
;
PARSEDRV:
	CALL	DELIM
	JP	Z,PARSE$OK
	SUB	'A'
	JP	C,PERROR1
	CP	16
	JP	NC,PERROR1
	INC	DE
	INC	DE		;past the ':'
	INC	A		;set drive relative to 1
	LD	(HL),A		;store the drive in FCB(0)
;
;	Parse the file-name
;
PARSE$NAME:
	INC	HL		;HL = .fcb(1)
	CALL	DELIM
	JP	Z,PARSE$OK
	LD	BC,7*256

PARSE6:	LD	A,(DE)		;get a character
	CP	'.'		;file-type next?
	JP	Z,PARSE$TYPE	;branch to file-type processing
	CP	';'
	JP	Z,PARSEPW
	CALL	GFC		;process one character
	JP	NZ,PARSE6	;loop if not end of name
	JP	PARSE$OK
;
;	Parse the file-type
;
PARSE$TYPE:
	INC	DE		;advance past dot
	POP	HL
	PUSH	HL		;HL =.fcb
	LD	BC,9
	ADD	HL,BC		;HL =.fcb(9)
	LD	BC,2*256

PARSE8:	LD	A,(DE)
	CP	';'
	JP	Z,PARSEPW
	CALL	GFC		;process one character
	JP	NZ,PARSE8	;loop if not end of type
;
PARSE$OK:
	POP	BC
	PUSH	DE
	CALL	SKPS		;skip trailing blanks and tabs
	DEC	DE
	CALL	DELIM		;is next nonblank char a delim?
	POP	HL
	RET	NZ		;no
	LD	HL,0
	OR	A
	RET	Z		;return zero if delim = 0
	CP	CR
	RET	Z		;return zero if delim = cr
	EX	DE,HL
	RET
;
;	handle parser error
;
PERROR:
	POP	BC		;throw away return addr
PERROR1:
	POP	BC
	LD	HL,0FFFFH
	RET
;
;	Parse the password
;
PARSEPW:
	INC	DE
	POP	HL
	PUSH	HL
	LD	BC,16
	ADD	HL,BC
	LD	BC,7*256+1
PARSEPW1:
	CALL	GFC
	JP	NZ,PARSEPW1
	LD	A,7
	SUB	B
	POP	HL
	PUSH	HL
	LD	BC,26
	ADD	HL,BC
	LD	(HL),A
	LD	A,(DE)		;delimiter in A
	JP	PARSE$OK
;
;	get next character of name, type or password
;
GFC:	CALL	DELIM		;check for end of filename
	RET	Z		;return if so
	CP	' '		;check for control characters
	INC	DE
	JP	C,PERROR	;error if control characters encountered
	INC	B		;error if too big for field
	DEC	B
	JP	M,PERROR
	INC	C
	DEC	C
	JP	NZ,GFC1
	CP	'*'		;trap "match rest of field" character
	JP	Z,SETMATCH
GFC1:	LD	(HL),A		;put character in fcb
	INC	HL
	DEC	B		;decrement field size counter
	OR	A		;clear zero flag
	RET
;;
SETMATCH:
	LD	(HL),'?'	;set match one character
	INC	HL
	DEC	B
	JP	P,SETMATCH
	RET
;
;	check for delimiter
;
;	entry:	A = character
;	exit:	z = set if char is a delimiter
;
DELIMITERS: DEFB	CR,TAB,' .,:;[]=<>|',0

DELIM:	LD	A,(DE)	;get character
	PUSH	HL
	LD	HL,DELIMITERS
DELIM1:	CP	(HL)		;is char in table
	JP	Z,DELIM2
	INC	(HL)
	DEC	(HL)		;end of table? (0)
	INC	HL
	JP	NZ,DELIM1
	OR	A		;reset zero flag
DELIM2:	POP	HL
	RET	Z
	;
	;	not a delimiter, convert to upper case
	;
	CP	'a'
	RET	C
	CP	'z'+1
	JP	NC,DELIM3
	AND	05FH
DELIM3:	AND	07FH
	RET			;return with zero set if so
;
;	pad with blanks or zeros
;
PAD:	LD	(HL),B
	INC	HL
	DEC	C
	JP	NZ,PAD
	RET
;
;	skip blanks and tabs
;
SKPS:	LD	A,(DE)
	INC	DE
	CP	' '		;skip spaces & tabs
	JP	Z,SKPS
	CP	TAB
	JP	Z,SKPS
	RET
;
;	end of PARSE
;

ERRFLG:
	; report error to console, message address in hl
	PUSH	HL
	CALL	CRLF		; stack mssg address, new line
	LD	A,(ADRIVE)
	ADD	A,'A'
	LD	(DSKERR),A	; current disk name
	LD	BC,DSKMSG

	IF BANKED
	CALL	ZPRINT		; the error message
	ELSE
	CALL	PRINT
	ENDIF

	POP	BC

	IF BANKED
	LD	A,(BDOS$FLAGS)
	RLA
	JP	NC,ZPRINT
	CALL	ZPRINT		; error message tail
	LD	A,(FX)
	LD	B,30H
	LD	HL,PR$FX1
	CP	100
	JP	C,ERRFLG1
	LD	(HL),31H
	INC	HL
	SUB	100
ERRFLG1:
	SUB	10
	JP	C,ERRFLG2
	INC	B
	JP	ERRFLG1
ERRFLG2:
	LD	(HL),B
	INC	HL
	ADD	A,3AH
	LD	(HL),A
	INC	HL
	LD	(HL),20H
	LD	HL,PR$FCB
	LD	(HL),0
	LD	A,(RESEL)
	OR	A
	JP	Z,ERRFLG3
	LD	(HL),20H
	PUSH	DE
	LD	HL,(INFO)
	INC	HL
	EX	DE,HL
	LD	HL,PR$FCB1
	LD	C,8
	CALL	MOVE
	LD	(HL),'.'
	INC	HL
	LD	C,3
	CALL	MOVE
	POP	DE
ERRFLG3:
	CALL	CRLF
	LD	BC,PR$FX
	JP	ZPRINT

ZPRINT:
	LD	A,(BC)
	OR	A
	RET	Z
	PUSH	BC
	LD	C,A
	CALL	TABOUT
	POP	BC
	INC	BC
	JP	ZPRINT

PR$FX:	DEFB	'BDOS Function = '
PR$FX1:	DEFB	'   '
PR$FCB:	DEFB	' File = '
PR$FCB1:DEFS	12
	DEFB	0

	ELSE
	JP	PRINT
	ENDIF

REBOOTE:
	LD	HL,0FFFDH
	JP	REBOOTX0	; BDOS error
REBOOTX:
;;;	lxi h,0fffeh ; CTL-C error
	CALL	PATCH$1E25	;[JCE] DRI Patch 13
REBOOTX0:
	LD	(CLP$ERRCDE),HL
REBOOTX1:
	JP	WBOOTF

ENTSP:	DEFS	2	; entry stack pointer

SHELL:
	LD	HL,0
	ADD	HL,SP
	LD	(SHELL$SP),HL

	IF NOT BANKED
	LD	SP,SHELL$STK
	ENDIF

	LD	HL,SHELL$RTN
	PUSH	HL
	CALL	SAVE$RR
	CALL	SAVE$DMA
	LD	A,(MULTCNT)
MULT$IO:
	PUSH	AF
	LD	(MULT$NUM),A
	CALL	CBDOS
	OR	A
	JP	NZ,SHELL$ERR
	LD	A,(FX)
	CP	33
	CALL	NC,INCR$RR
	CALL	ADV$DMA
	POP	AF
	DEC	A
	JP	NZ,MULT$IO
	LD	H,A
	LD	L,A
	RET

SHELL$SP:
	DEFW	0

	DEFW	0C7C7H,0C7C7H,0C7C7H,0C7C7H,0C7C7H

SHELL$STK: ; shell has 5 level stack
HOLD$DMA: DEFW	0

CBDOS:
	LD	A,(FX)
	LD	C,A
CBDOS1:
	LD	HL,(INFO)
	EX	DE,HL
	JP	BDOSE2

ADV$DMA:
	LD	HL,(DMAAD)
	LD	DE,80H
	ADD	HL,DE
	JP	RESET$DMA1

SAVE$DMA:
	LD	HL,(DMAAD)
	LD	(HOLD$DMA),HL
	RET

RESET$DMA:
	LD	HL,(HOLD$DMA)
RESET$DMA1:
	LD	(DMAAD),HL
	JP	SETDMA

SHELL$ERR:
	POP	BC
	INC	A
	RET	Z
	LD	A,(MULTCNT)
	SUB	B
	LD	H,A
	RET

SHELL$RTN:
	PUSH	HL
	LD	A,(FX)
	CP	33
	CALL	NC,RESET$RR
	CALL	RESET$DMA
	POP	DE
	LD	HL,(SHELL$SP)
	LD	SP,HL
	EX	DE,HL
	LD	A,L
	LD	B,H
	RET

	PAGE


	TITLE	'CP/M Bdos Interface, Bdos, Version 3.0 Nov, 1982'
;*****************************************************************
;*****************************************************************
;**                                                             **
;**   B a s i c    D i s k   O p e r a t i n g   S y s t e m    **
;**								**
;**               C o n s o l e   P o r t i o n                 **
;**                                                             **
;*****************************************************************
;*****************************************************************
;
;       November 1982
;
;
;	Console handlers
;
CONIN:
	;read console character to A
	LD	HL,KBCHAR
	LD	A,(HL)
	LD	(HL),0
	OR	A
	RET	NZ
	;no previous keyboard character ready
	JP	CONINF		;get character externally
	;ret
;
CONECH:
	LD	HL,STA$RET
	PUSH	HL
CONECH0:
	;read character with echo
	CALL	CONIN
	CALL	ECHOC
	JP	C,CONECH1	;echo character?
	;character must be echoed before return
	PUSH	AF
	LD	C,A
	CALL	TABOUT
	POP	AF
	RET
CONECH1:
	CALL	TEST$CTLS$MODE
	RET	NZ
	CP	CTLS
	JP	NZ,CONECH2
	CALL	CONBRK2
	JP	CONECH0
CONECH2:
	CP	CTLQ
	JP	Z,CONECH0
	CP	CTLP
	JP	Z,CONECH0
	RET
;
ECHOC:
	;echo character if graphic
	;cr, lf, tab, or backspace
	CP	CR
	RET	Z		;carriage return?
	CP	LF
	RET	Z		;line feed?
	CP	TAB
	RET	Z		;tab?
	CP	CTLH
	RET	Z		;backspace?
	CP	' '
	RET			;carry set if not graphic
;
CONSTX:
	LD	A,(KBCHAR)
	OR	A
	JP	NZ,CONB1
	CALL	CONSTF
	AND	1
	RET
;
	IF BANKED

SET$CTLS$MODE:
	;SET CTLS STATUS OR INPUT FLAG FOR QUEUE MANAGER
	LD	HL,QFLAG
	LD	(HL),40H
	EX	(SP),HL
	JP	(HL)

	ENDIF
;
TEST$CTLS$MODE:
	;RETURN WITH Z FLAG RESET IF CTL-S CTL-Q CHECKING DISABLED
	LD	B,A
	LD	A,(CONMODE)
	AND	2
	LD	A,B
	RET
;
CONBRK:	;check for character ready
	CALL	TEST$CTLS$MODE
	JP	NZ,CONSTX
	LD	A,(KBCHAR)
	OR	A
	JP	NZ,CONBRK1	;skip if active kbchar
	;no active kbchar, check external break
	;DOES BIOS HAVE TYPE AHEAD?
	IF BANKED
	LD	A,(TYPE$AHEAD)
	INC	A
	JP	Z,CONSTX	;YES
	ENDIF
	;CONBRKX CALLED BY CONOUT

CONBRKX:
	;HAS CTL-S INTERCEPT BEEN DISABLED?
	CALL	TEST$CTLS$MODE
	RET	NZ		;YES
	;DOES KBCHAR CONTAIN CTL-S?
	LD	A,(KBCHAR)
	CP	CTLS
	JP	Z,CONBRK1	;YES
	IF BANKED
	CALL	SET$CTLS$MODE
	ENDIF
	;IS A CHARACTER READY FOR INPUT?
	CALL	CONSTF
	IF BANKED
	POP	HL
	LD	(HL),0
	ENDIF
	AND	1
	RET	Z		;NO
	;character ready, read it
	IF BANKED
	CALL	SET$CTLS$MODE
	ENDIF
	CALL	CONINF
	IF BANKED
	POP	HL
	LD	(HL),0
	ENDIF
CONBRK1:
	CP	CTLS
	JP	NZ,CONB0	;check stop screen function
	;DOES KBCHAR CONTAIN A CTL-S?
	LD	HL,KBCHAR
	CP	(HL)
	JP	NZ,CONBRK2	;NO
	LD	(HL),0		; KBCHAR = 0
	;found ctls, read next character
CONBRK2:

	IF BANKED
	CALL	SET$CTLS$MODE
	ENDIF
	CALL	CONINF		;to A
	IF BANKED
	POP	HL
	LD	(HL),0
	ENDIF
	CP	CTLC
	JP	NZ,CONBRK3
	LD	A,(CONMODE)
	AND	08H
	JP	Z,REBOOTX
	XOR	A
CONBRK3:
	SUB	CTLQ
	RET	Z		; RETURN WITH A = ZERO IF CTLQ
	INC	A
	CALL	CONB3
	JP	CONBRK2
CONB0:
	LD	HL,KBCHAR

	LD	B,A
	;IS CONMODE(1) TRUE?
	LD	A,(CONMODE)
	RRA
	JP	NC,$+7		;NO
	;DOES KBCHAR = CTLC?
	LD	A,CTLC
	CP	(HL)
	RET	Z		;YES - RETURN
	LD	A,B

	CP	CTLQ
	JP	Z,CONB2
	CP	CTLP
	JP	Z,CONB2
	;character in accum, save it
	LD	(HL),A
CONB1:
	;return with true set in accumulator
	LD	A,1
	RET
CONB2:
	XOR	A
	LD	(HL),A
	RET
CONB3:
	CALL	Z,TOGGLE$LISTCP
	LD	C,7
	CALL	NZ,CONOUTF
	RET
;
TOGGLE$LISTCP:
	; IS PRINTER ECHO DISABLED?
	LD	A,(CONMODE)
	AND	14H
	JP	NZ,TOGGLE$L1	;YES
	LD	HL,LISTCP
	LD	A,1
	XOR	(HL)
	AND	1
	LD	(HL),A
	RET
TOGGLE$L1:
	XOR	A
	RET
;
QCONOUTF:
	;DOES FX = INPUT?
	LD	A,(FX)
	DEC	A
	JP	Z,CONOUTF	;YES
	;IS ESCAPE SEQUENCE DECODING IN EFFECT?
	LD	A,B
;;;	ANI 8		;[JCE] DRI Patch 13
	AND	10H
	JP	NZ,SCONOUTF	;YES
	JP	CONOUTF
;
CONOUT:
	;compute character position/write console char from C
	;compcol = true if computing column position
	LD	A,(COMPCOL)
	OR	A
	JP	NZ,COMPOUT
	;write the character, then compute the column
	;write console character from C
	;B ~= 0 -> ESCAPE SEQUENCE DECODING
	LD	A,(CONMODE)
	AND	14H
	LD	B,A
	PUSH	BC
	;CALL CONBRKX FOR OUTPUT FUNCTIONS ONLY
	LD	A,(FX)
	DEC	A
	CALL	NZ,CONBRKX
	POP	BC
	PUSH	BC		;recall/save character
	CALL	QCONOUTF	;externally, to console
	POP	BC
	;SKIP ECHO WHEN CONMODE & 14H ~= 0
	LD	A,B
	OR	A
	JP	NZ,COMPOUT
	PUSH	BC		;recall/save character
	;may be copying to the list device
	LD	A,(LISTCP)
	OR	A
	CALL	NZ,LISTF	;to printer, if so
	POP	BC		;recall the character
COMPOUT:
	LD	A,C		;recall the character
	;and compute column position
	LD	HL,COLUMN	;A = char, HL = .column
	CP	RUBOUT
	RET	Z		;no column change if nulls
	INC	(HL)		;column = column + 1
	CP	' '
	RET	NC		;return if graphic
	;not graphic, reset column position
	DEC	(HL)		;column = column - 1
	LD	A,(HL)
	OR	A
	RET	Z		;return if at zero
	;not at zero, may be backspace or end line
	LD	A,C		;character back to A
	CP	CTLH
	JP	NZ,NOTBACKSP
	;backspace character
	DEC	(HL)		;column = column - 1
	RET
NOTBACKSP:
	;not a backspace character, eol?
	CP	CR
	RET	NZ		;return if not
	;end of line, column = 0
	LD	(HL),0		;column = 0
	RET
;
CTLOUT:
	;send C character with possible preceding up-arrow
	LD	A,C
	CALL	ECHOC		;cy if not graphic (or special case)
	JP	NC,TABOUT	;skip if graphic, tab, cr, lf, or ctlh
	;send preceding up arrow
	PUSH	AF
	LD	C,CTL
	CALL	CONOUT		;up arrow
	POP	AF
	OR	40H		;becomes graphic letter
	LD	C,A		;ready to print
	IF BANKED
	CALL	CHK$COLUMN
	RET	Z
	ENDIF
	;(drop through to tabout)
;
TABOUT:
	;IS FX AN INPUT FUNCTION?
	LD	A,(FX)
	DEC	A
	JP	Z,TABOUT1	;YES - ALWAYS EXPAND TABS FOR ECHO
	;HAS TAB EXPANSION BEEN DISABLED OR
	;ESCAPE SEQUENCE DECODING BEEN ENABLED?
	LD	A,(CONMODE)
	AND	14H
	JP	NZ,CONOUT	;YES
TABOUT1:
	;expand tabs to console
	LD	A,C
	CP	TAB
	JP	NZ,CONOUT	;direct to conout if not
	;tab encountered, move to next tab position
TAB0:

	IF BANKED
	LD	A,(FX)
	CP	1
	JP	NZ,TAB1
	CALL	CHK$COLUMN
	RET	Z
TAB1:
	ENDIF

	LD	C,' '
	CALL	CONOUT		;another blank
	LD	A,(COLUMN)
	AND	111B		;column mod 8 = 0 ?
	JP	NZ,TAB0		;back for another if not
	RET
;
;
BACKUP:
	;back-up one screen position
	CALL	PCTLH

	IF BANKED
	LD	A,(COMCHR)
	CP	CTLA
	RET	Z
	ENDIF

	LD	C,' '
	CALL	CONOUTF
;	(drop through to pctlh)				;
PCTLH:
	;send ctlh to console without affecting column count
	LD	C,CTLH
	JP	CONOUTF
	;ret
;
CRLFP:
	;print #, cr, lf for ctlx, ctlu, ctlr functions
	;then move to strtcol (starting column)
	LD	C,'#'
	CALL	CONOUT
	CALL	CRLF
	;column = 0, move to position strtcol
CRLFP0:
	LD	A,(COLUMN)
	LD	HL,STRTCOL
	CP	(HL)
	RET	NC		;stop when column reaches strtcol
	LD	C,' '
	CALL	CONOUT		;print blank
	JP	CRLFP0
;;
;
CRLF:
	;carriage return line feed sequence
	LD	C,CR
	CALL	CONOUT
	LD	C,LF
	JP	CONOUT
	;ret
;
PRINT:
	;print message until M(BC) = '$'
	LD	HL,OUTDELIM
	LD	A,(BC)
	CP	(HL)
	RET	Z		;stop on $
	;more to print
	INC	BC
	PUSH	BC
	LD	C,A		;char to C
	CALL	TABOUT		;another character printed
	POP	BC
	JP	PRINT
;
QCONIN:

	IF BANKED
	LD	HL,(APOS)
	LD	A,(HL)
	LD	(CTLA$SW),A
	ENDIF
	;IS BUFFER ADDRESS = 0?
	LD	HL,(CONBUFFADD)
	LD	A,L
	OR	H
	JP	Z,CONIN		;YES
	;IS CHARACTER IN BUFFER < 5?

	IF BANKED
	CALL	QCONINX		; mov a,m with bank 1 switched in
	ELSE
	LD	A,(HL)
	ENDIF

	INC	HL
	OR	A
	JP	NZ,QCONIN1	; NO
	LD	HL,0
QCONIN1:
	LD	(CONBUFFADD),HL
	LD	(CONBUFFLEN),HL
	RET	NZ		; NO
	JP	CONIN

	IF BANKED

CHK$COLUMN:
	LD	A,(CONWIDTH)
	LD	E,A
	LD	A,(COLUMN)
	CP	E
	RET
;
EXPAND:
	EX	DE,HL
	LD	HL,(APOS)
	EX	DE,HL
EXPAND1:
	LD	A,(DE)
	OR	A
	RET	Z
	INC	DE
	INC	HL
	LD	(HL),A
	INC	B
	JP	EXPAND1
;
COPY$XBUFF:
	LD	A,B
	OR	A
	RET	Z
	PUSH	BC
	LD	C,B
	PUSH	HL
	EX	DE,HL
	INC	DE
	LD	HL,XBUFF
	CALL	MOVE
	LD	(HL),0
	LD	(XPOS),HL
	POP	HL
	POP	BC
	RET
;
COPY$CBUFF:
	LD	A,(CCP$FLGS+1)
	RLA
	RET	NC
	LD	HL,XBUFF
	LD	DE,CBUFF
	INC	C
	JP	NZ,COPY$CBUFF1
	EX	DE,HL
	LD	A,B
	OR	A
	RET	Z
	LD	(CBUFF$LEN),A
	PUSH	DE
	LD	BC,COPY$CBUFF2
	PUSH	BC
	LD	B,A
COPY$CBUFF1:
	INC	B
	LD	C,B
	JP	MOVE
COPY$CBUFF2:
	POP	HL
	DEC	HL
	LD	(HL),0
	RET
;
SAVE$COL:
	LD	A,(COLUMN)
	LD	(SAVE$COLUMN),A
	RET
;
CLEAR$RIGHT:
	LD	A,(COLUMN)
	LD	HL,CTLA$COLUMN
	CP	(HL)
	RET	NC
	LD	C,20H
	CALL	CONOUT
	JP	CLEAR$RIGHT
;
REVERSE:
	LD	A,(SAVE$COLUMN)
	LD	HL,COLUMN
	CP	(HL)
	RET	NC
	LD	C,CTLH
	CALL	CONOUT
	JP	REVERSE
;
CHK$BUFFER$SIZE:
	PUSH	BC
	PUSH	HL
	LD	HL,(APOS)
	LD	E,0
CBS1:
	LD	A,(HL)
	OR	A
	JP	Z,CBS2
	INC	E
	INC	HL
	JP	CBS1
CBS2:
	LD	A,B
	ADD	A,E
	CP	C
	PUSH	AF
	LD	C,7
	CALL	NC,CONOUTF
	POP	AF
	POP	HL
	POP	BC
	RET	C
	POP	DE
	POP	DE
	JP	READNX
;
REFRESH:
	LD	A,(CTLA$SW)
	OR	A
	RET	Z
	LD	A,(COMCHR)
	CP	CTLA
	RET	Z
	CP	CTLF
	RET	Z
	CP	CTLW
	RET	Z
REFRESH0:
	PUSH	HL
	PUSH	BC
	CALL	SAVE$COL
	LD	HL,(APOS)
REFRESH1:
	LD	A,(HL)
	OR	A
	JP	Z,REFRESH2
	LD	C,A
	CALL	CHK$COLUMN
	JP	C,REFRESH05
	LD	A,E
	LD	(COLUMN),A
	JP	REFRESH2
REFRESH05:
	PUSH	HL
	CALL	CTLOUT
	POP	HL
	INC	HL
	JP	REFRESH1
REFRESH2:
	LD	A,(COLUMN)
	LD	(NEW$CTLA$COL),A
REFRESH3:
	CALL	CLEAR$RIGHT
	CALL	REVERSE
	LD	A,(NEW$CTLA$COL)
	LD	(CTLA$COLUMN),A
	POP	BC
	POP	HL
	RET
;
INIT$APOS:
	LD	HL,APOSI
	LD	(APOS),HL
	XOR	A
	LD	(CTLA$SW),A
	RET
;
INIT$XPOS:
	LD	HL,XBUFF
	LD	(XPOS),HL
	RET
;
SET$CTLA$COLUMN:
	LD	HL,CTLA$SW
	LD	A,(HL)
	OR	A
	RET	NZ
	INC	(HL)
	LD	A,(COLUMN)
	LD	(CTLA$COLUMN),A
	RET
;
READI:
	CALL	CHK$COLUMN
	CALL	NC,CRLF
	LD	A,(CBUFF$LEN)
	LD	B,A
	LD	C,0
	CALL	COPY$CBUFF
	ELSE

READI:
	LD	A,D
	OR	E
	JP	NZ,READ
	LD	HL,(DMAAD)
	LD	(INFO),HL
	INC	HL
	INC	HL
	LD	(CONBUFFADD),HL
	ENDIF

READ:	;read to info address (max length, current length, buffer)

	IF BANKED
	CALL	INIT$XPOS
	CALL	INIT$APOS
READX:
	CALL	REFRESH
	XOR	A
	LD	(CTLW$SW),A
READX1:

	ENDIF

	LD	A,1
	LD	(FX),A
	LD	A,(COLUMN)
	LD	(STRTCOL),A	;save start for ctl-x, ctl-h
	LD	HL,(INFO)
	LD	C,(HL)
	INC	HL
	PUSH	HL
	XOR	A
	LD	B,A
	LD	(SAVEPOS),A
	CP	C
	JP	NZ,$+4
	INC	C
	;B = current buffer length,
	;C = maximum buffer length,
	;HL= next to fill - 1
READNX:
	;read next character, BC, HL active
	PUSH	BC
	PUSH	HL		;blen, cmax, HL saved
READN0:

	IF BANKED
	LD	A,(CTLW$SW)
	OR	A
	CALL	Z,QCONIN
NXTLINE:
	LD	(COMCHR),A
	ELSE
	CALL	QCONIN		;next char in A
	ENDIF

	;ani 7fh ;mask parity bit
	POP	HL
	POP	BC		;reactivate counters
	CP	CR
	JP	Z,READEN	;end of line?
	CP	LF
	JP	Z,READEN	;also end of line

	IF BANKED
	CP	CTLF
	JP	NZ,NOT$CTLF
DO$CTLF:
	CALL	CHK$COLUMN
	DEC	E
	CP	E
	JP	NC,READNX
DO$CTLF0:
	EX	DE,HL
	LD	HL,(APOS)
	LD	A,(HL)
	OR	A
	JP	Z,CTLW$L15
	INC	HL
	LD	(APOS),HL
	EX	DE,HL
	JP	NOTR
NOT$CTLF:
	CP	CTLW
	JP	NZ,NOT$CTLW
DO$CTLW:
	EX	DE,HL
	LD	HL,(APOS)
	LD	A,(HL)
	OR	A
	JP	Z,CTLW$L1
	EX	DE,HL
	CALL	CHK$COLUMN
	DEC	E
	CP	E
	EX	DE,HL
	JP	C,CTLW$L0
	EX	DE,HL
	CALL	REFRESH0
	EX	DE,HL
	JP	CTLW$L13
CTLW$L0:
	LD	HL,(APOS)
	LD	A,(HL)
	INC	HL
	LD	(APOS),HL
	JP	CTLW$L3
CTLW$L1:
	LD	HL,CTLA$SW
	LD	A,(HL)
	LD	(HL),0
	OR	A
	JP	Z,CTLW$L2
CTLW$L13:
	LD	HL,CTLW$SW
	LD	(HL),0
CTLW$L15:
	EX	DE,HL
	JP	READNX
CTLW$L2:
	LD	A,(CTLW$SW)
	OR	A
	JP	NZ,CTLW$L25
	LD	A,B
	OR	A
	JP	NZ,CTLW$L15
	CALL	INIT$XPOS
CTLW$L25:
	LD	HL,(XPOS)
	LD	A,(HL)
	OR	A
	LD	(CTLW$SW),A
	JP	Z,CTLW$L15
	INC	HL
	LD	(XPOS),HL
CTLW$L3:
	LD	HL,CTLW$SW
	LD	(HL),CTLW
	EX	DE,HL
	JP	NOTR
NOT$CTLW:
	CP	CTLA
	JP	NZ,NOT$CTLA
DO$CTLA:
	;do we have any characters to back over?
	LD	A,(STRTCOL)
	LD	D,A
	LD	A,(COLUMN)
	CP	D
	JP	Z,READNX
	LD	(COMPCOL),A	;COL > 0
	LD	A,B
	OR	A
	JP	Z,LINELEN
	;characters remain in buffer, backup one
	DEC	B		;remove one character
	;compcol > 0 marks repeat as length compute
	;backup one position in xbuff
	PUSH	HL
	CALL	SET$CTLA$COLUMN
	POP	DE
	LD	HL,(APOS)
	DEC	HL
	LD	(APOS),HL
	LD	A,(DE)
	LD	(HL),A
	EX	DE,HL
	JP	LINELEN
NOT$CTLA:
	CP	CTLB
	JP	NZ,NOT$CTLB
DO$CTLB:
	LD	A,(SAVEPOS)
	CP	B
	JP	NZ,CTLB$L0
	LD	A,CTLW
	LD	(CTLA$SW),A
	LD	(COMCHR),A
	JP	DO$CTLW
CTLB$L0:
	EX	DE,HL
	LD	HL,(APOS)
	INC	B
CTLB$L1:
	DEC	B
	LD	A,(SAVEPOS)
	CP	B
	JP	Z,CTLB$L2
	DEC	HL
	LD	A,(DE)
	LD	(HL),A
	DEC	DE
	JP	CTLB$L1
CTLB$L2:
	LD	(APOS),HL
	PUSH	BC
	PUSH	DE
	CALL	SET$CTLA$COLUMN
CTLB$L3:
	LD	A,(COLUMN)
	LD	B,A
	LD	A,(STRTCOL)
	CP	B
	JP	Z,READN0
	LD	C,CTLH
	CALL	CONOUT
	JP	CTLB$L3
NOT$CTLB:
	CP	CTLK
	JP	NZ,NOT$CTLK
	EX	DE,HL
	LD	HL,APOSI
	LD	(APOS),HL
	EX	DE,HL
	CALL	REFRESH
	JP	READNX
NOT$CTLK:
	CP	CTLG
	JP	NZ,NOT$CTLG
	LD	A,(CTLA$SW)
	OR	A
	JP	Z,READNX
	JP	DO$CTLF0
NOT$CTLG:
	ENDIF

	CP	CTLH
	JP	NZ,NOTH		;backspace?
	LD	A,(CTLH$ACT)
	INC	A
	JP	Z,DO$RUBOUT
DO$CTLH:
	;do we have any characters to back over?
	LD	A,(STRTCOL)
	LD	D,A
	LD	A,(COLUMN)
	CP	D
	JP	Z,READNX
	LD	(COMPCOL),A	;COL > 0
	LD	A,B
	OR	A
	JP	Z,$+4
	;characters remain in buffer, backup one
	DEC	B		;remove one character
	;compcol > 0 marks repeat as length compute
	JP	LINELEN		;uses same code as repeat
NOTH:
	;not a backspace
	CP	RUBOUT
	JP	NZ,NOTRUB	;rubout char?
	LD	A,(RUBOUT$ACT)
	INC	A
	JP	Z,DO$CTLH
DO$RUBOUT:
	IF BANKED
	LD	A,RUBOUT
	LD	(COMCHR),A
	LD	A,(CTLA$SW)
	OR	A
	JP	NZ,DO$CTLH
	ENDIF
	;rubout encountered, rubout if possible
	LD	A,B
	OR	A
	JP	Z,READNX	;skip if len=0
	;buffer has characters, resend last char
	LD	A,(HL)
	DEC	B
	DEC	HL		;A = last char
	;blen=blen-1, next to fill - 1 decremented
	JP	RDECH1		;act like this is an echo
NOTRUB:
	;not a rubout character, check end line
	CP	CTLE
	JP	NZ,NOTE		;physical end line?
	;yes, save active counters and force eol
	PUSH	BC
	LD	A,B
	LD	(SAVEPOS),A
	PUSH	HL
	IF BANKED
	LD	A,(CTLA$SW)
	OR	A
	CALL	NZ,CLEAR$RIGHT
	ENDIF
	CALL	CRLF
	IF BANKED
	CALL	REFRESH
	ENDIF
	XOR	A
	LD	(STRTCOL),A	;start position = 00
	JP	READN0		;for another character
NOTE:
	;not end of line, list toggle?
	CP	CTLP
	JP	NZ,NOTP		;skip if not ctlp
	;list toggle - change parity
	PUSH	HL		;save next to fill - 1
	PUSH	BC
	XOR	A
	CALL	CONB3
	POP	BC
	POP	HL
	JP	READNX		;for another char
NOTP:
	;not a ctlp, line delete?
	CP	CTLX
	JP	NZ,NOTX
	POP	HL		;discard start position
	;loop while column > strtcol
BACKX:
	LD	A,(STRTCOL)
	LD	HL,COLUMN
	IF BANKED
	CP	(HL)
	JP	C,BACKX1
	LD	HL,(APOS)
	LD	A,(HL)
	OR	A
	JP	NZ,READX
	JP	READ
BACKX1:
	ELSE
	CP	(HL)
	JP	NC,READ		;start again
	ENDIF
	DEC	(HL)		;column = column - 1
	CALL	BACKUP		;one position
	JP	BACKX
NOTX:
	;not a control x, control u?
	;not control-X, control-U?
	CP	CTLU
	JP	NZ,NOTU		;skip if not
	IF BANKED
	EX	(SP),HL
	CALL	COPY$XBUFF
	EX	(SP),HL
	ENDIF
	;delete line (ctlu)
DO$CTLU:
	CALL	CRLFP		;physical eol
	POP	HL		;discard starting position
	JP	READ		;to start all over
NOTU:
	;not line delete, repeat line?
	CP	CTLR
	JP	NZ,NOTR
	XOR	A
	LD	(SAVEPOS),A
	IF BANKED
	EX	DE,HL
	CALL	INIT$APOS
	EX	DE,HL
	LD	A,B
	OR	A
	JP	Z,DO$CTLU
	EX	DE,HL
	LD	HL,(APOS)
	INC	B
CTLR$L1:
	DEC	B
	JP	Z,CTLR$L2
	DEC	HL
	LD	A,(DE)
	LD	(HL),A
	DEC	DE
	JP	CTLR$L1
CTLR$L2:
	LD	(APOS),HL
	PUSH	BC
	PUSH	DE
	CALL	CRLFP
	LD	A,CTLW
	LD	(CTLW$SW),A
	LD	(CTLA$SW),A
	JP	READN0
	ENDIF
LINELEN:
	;repeat line, or compute line len (ctlh)
	;if compcol > 0
	PUSH	BC
	CALL	CRLFP		;save line length
	POP	BC
	POP	HL
	PUSH	HL
	PUSH	BC
	;bcur, cmax active, beginning buff at HL
REP0:
	LD	A,B
	OR	A
	JP	Z,REP1		;count len to 00
	INC	HL
	LD	C,(HL)		;next to print
	DEC	B
	POP	DE
	PUSH	DE
	LD	A,D
	SUB	B
	LD	D,A
	PUSH	BC
	PUSH	HL		;count length down
	LD	A,(SAVEPOS)
	CP	D
	CALL	C,CTLOUT
	POP	HL
	POP	BC		;recall remaining count
	JP	REP0		;for the next character
REP1:
	;end of repeat, recall lengths
	;original BC still remains pushed
	PUSH	HL		;save next to fill
	LD	A,(COMPCOL)
	OR	A		;>0 if computing length
	JP	Z,READN0	;for another char if so
	;column position computed for ctlh
	LD	HL,COLUMN
	SUB	(HL)		;diff > 0
	LD	(COMPCOL),A	;count down below
	;move back compcol-column spaces
BACKSP:
	;move back one more space
	CALL	BACKUP		;one space
	LD	HL,COMPCOL
	DEC	(HL)
	JP	NZ,BACKSP
	IF BANKED
	CALL	REFRESH
	ENDIF
	JP	READN0		;for next character
NOTR:
	;not a ctlr, place into buffer
	;IS BUFFER FULL?
	PUSH	AF
	LD	A,B
	CP	C
	JP	C,RDECH0	;NO
	;DISCARD CHARACTER AND RING BELL
	POP	AF
	PUSH	BC
	PUSH	HL
	LD	C,7
	CALL	CONOUTF
	JP	READN0
RDECH0:

	IF BANKED
	LD	A,(COMCHR)
	CP	CTLG
	JP	Z,RDECH05
	LD	A,(CTLA$SW)
	OR	A
	CALL	NZ,CHK$BUFFER$SIZE
RDECH05:
	ENDIF

	POP	AF
	INC	HL
	LD	(HL),A		;character filled to mem
	INC	B		;blen = blen + 1
RDECH1:
	;look for a random control character
	PUSH	BC
	PUSH	HL		;active values saved
	LD	C,A		;ready to print
	IF BANKED
	CALL	SAVE$COL
	ENDIF
	CALL	CTLOUT		;may be up-arrow C
	POP	HL
	POP	BC
	IF BANKED
	LD	A,(COMCHR)
	CP	CTLG
	JP	Z,DO$CTLH
	CP	RUBOUT
	JP	Z,RDECH2
	CALL	REFRESH
RDECH2:
	ENDIF
	LD	A,(CONMODE)
	AND	08H
;;;			JNZ NOTC	;[JCE] DRI Patch 13
	JP	NZ,PATCH$064B

	LD	A,(HL)		;recall char
	CP	CTLC		;set flags for reboot test
PATCH$064B: LD	A,B		;move length to A
	JP	NZ,NOTC		;skip if not a control c
	CP	1		;control C, must be length 1
	JP	Z,REBOOTX	;reboot if blen = 1
	;length not one, so skip reboot
NOTC:
	;not reboot, are we at end of buffer?
	IF BANKED
	CP	C
	JP	NC,BUFFER$FULL
	ELSE
	JP	READNX		;go for another if not
	ENDIF

	IF BANKED
	PUSH	BC
	PUSH	HL
	CALL	CHK$COLUMN
	JP	C,READN0
	LD	A,(CTLA$SW)
	OR	A
	JP	Z,DO$NEWLINE
	LD	A,(COMCHR)
	CP	CTLW
	JP	Z,BACK$ONE
	CP	CTLF
	JP	Z,BACK$ONE

DO$NEWLINE:
	LD	A,CTLE
	JP	NXTLINE

BACK$ONE:
	;back up to previous character
	POP	HL
	POP	BC
	DEC	B
	EX	DE,HL
	LD	HL,(APOS)
	DEC	HL
	LD	(APOS),HL
	LD	A,(DE)
	LD	(HL),A
	EX	DE,HL
	DEC	HL
	PUSH	BC
	PUSH	HL
	CALL	REVERSE
	;disable ctlb or ctlw
	XOR	A
	LD	(CTLW$SW),A
	JP	READN0

BUFFER$FULL:
	XOR	A
	LD	(CTLW$SW),A
	JP	READNX
	ENDIF
READEN:
	;end of read operation, store blen
	IF BANKED
	CALL	EXPAND
	ENDIF
	POP	HL
	LD	(HL),B		;M(current len) = B
	IF BANKED
	PUSH	BC
	CALL	COPY$XBUFF
	POP	BC
	LD	C,0FFH
	CALL	COPY$CBUFF
	ENDIF
	LD	HL,0
	LD	(CONBUFFADD),HL
	LD	C,CR
	JP	CONOUT		;return carriage
	;ret
;
FUNC1	EQU	CONECH
	;return console character with echo
;
FUNC2 	EQU	TABOUT
	;write console character with tab expansion
;
FUNC3:
	;return reader character
	CALL	READERF
	JP	STA$RET
;
;func4:	equated to punchf
	;write punch character
;
;func5:	equated to listf
	;write list character
	;write to list device
;
FUNC6:
	;direct console i/o - read if 0ffh
	LD	A,C
	INC	A
	JP	Z,DIRINP	;0ffh => 00h, means input mode
	INC	A
	JP	Z,DIRSTAT	;0feh => direct STATUS function
	INC	A
	JP	Z,DIRINP1	;0fdh => direct input, no status
	JP	CONOUTF
DIRSTAT:
	;0feH in C for status
	CALL	CONSTX
	JP	NZ,LRET$EQ$FF
	JP	STA$RET
DIRINP:
	CALL	CONSTX		;status check
	OR	A
	RET	Z		;skip, return 00 if not ready
	;character is ready, get it
DIRINP1:
	CALL	CONIN		;to A
	JP	STA$RET
;
FUNC7:
	CALL	AUXINSTF
	JP	STA$RET
;
FUNC8:
	CALL	AUXOUTSTF
	JP	STA$RET
;
FUNC9:
	;write line until $ encountered
	EX	DE,HL		;was lhld info
	LD	C,L
	LD	B,H		;BC=string address
	JP	PRINT		;out to console

FUNC10	EQU	READI
	;read a buffered console line

FUNC11:
	;IS CONMODE(1) TRUE?
	LD	A,(CONMODE)
	RRA
	JP	NC,NORMAL$STATUS;NO
	;CTL-C ONLY STATUS CHECK
	IF BANKED
	LD	HL,QFLAG
	LD	(HL),80H
	PUSH	HL
	ENDIF
	LD	HL,CTLC$STAT$RET
	PUSH	HL
	;DOES KBCHAR = CTL-C?
	LD	A,(KBCHAR)
	CP	CTLC
	JP	Z,CONB1		;YES
	;IS THERE A READY CHARACTER?
	CALL	CONSTF
	OR	A
	RET	Z		;NO
	;IS THE READY CHARACTER A CTL-C?
	CALL	CONINF
	CP	CTLC
	JP	Z,CONB0		;YES
	LD	(KBCHAR),A
	XOR	A
	RET

CTLC$STAT$RET:

	IF BANKED
	CALL	STA$RET
	POP	HL
	LD	(HL),0
	RET
	ELSE
	JP	STA$RET
	ENDIF

NORMAL$STATUS:
	;check console status
	CALL	CONBRK
	;(drop through to sta$ret)
STA$RET:
	;store the A register to aret
	LD	(ARET),A
FUNC$RET: ;
	RET			;jmp goback (pop stack for non cp/m functions)
;
SETLRET1:
	;set lret = 1
	LD	A,1
	JP	STA$RET		;
;
FUNC109:;GET/SET CONSOLE MODE
	;DOES DE = 0FFFFH?
	LD	A,D
	AND	E
	INC	A
	LD	HL,(CONMODE)
	JP	Z,STHL$RET	;YES - RETURN CONSOLE MODE
	EX	DE,HL
	LD	(CONMODE),HL
	RET			;NO - SET CONSOLE MODE
;
FUNC110:;GET/SET FUNCTION 9 DELIMITER
	LD	HL,OUTDELIM
	;DOES DE = 0FFFFH?
	LD	A,D
	AND	E
	INC	A
	LD	A,(HL)
	JP	Z,STA$RET	;YES - RETURN DELIMITER
	LD	(HL),E
	RET			;NO - SET DELIMITER
;
FUNC111:;PRINT BLOCK TO CONSOLE
FUNC112:;LIST BLOCK
	EX	DE,HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	EX	DE,HL
	;HL = ADDR OF STRING
	;BC = LENGTH OF STRING
BLK$OUT:
	LD	A,B
	OR	C
	RET	Z
	PUSH	BC
	PUSH	HL
	LD	C,(HL)
	LD	A,(FX)
	CP	111
	JP	Z,BLK$OUT1
	CALL	LISTF
	JP	BLK$OUT2
BLK$OUT1:
	CALL	TABOUT
BLK$OUT2:
	POP	HL
	INC	HL
	POP	BC
	DEC	BC
	JP	BLK$OUT

SCONOUTF EQU	CONOUTF

;
;	data areas
;
COMPCOL:DEFB	0		;true if computing column position
STRTCOL:DEFB	0		;starting column position after read

	IF NOT BANKED

KBCHAR:	DEFB	0	;initial key char = 00

	ENDIF

SAVEPOS:DEFB	0		;POSITION IN BUFFER CORRESPONDING TO
	;BEGINNING OF LINE
	IF BANKED

COMCHR:	DEFB	0
CBUFF$LEN: DEFB	0
CBUFF:	DEFS	256
	DEFB	0
XBUFF:	DEFB	0
	DEFS	354
APOSI:	DEFB	0
XPOS:	DEFW	0
APOS:	DEFW	0
CTLA$SW:DEFB	0
CTLW$SW:DEFB	0
SAVE$COLUMN: DEFB	0
CTLA$COLUMN: DEFB	0
NEW$CTLA$COL: DEFB	0

	ENDIF

;	end of BDOS Console module

;
;**********************************************************************
;*****************************************************************
;
;	Error Messages

	IF BANKED

MD	EQU	0

	ELSE

MD	EQU	24H

	ENDIF

DSKMSG:	DEFB	'CP/M Error On '
DSKERR:	DEFB	' : ',MD
PERMSG:	DEFB	'Disk I/O',MD
SELMSG:	DEFB	'Invalid Drive',MD
ROFMSG:	DEFB	'Read/Only File',MD
RODMSG:	DEFB	'Read/Only Disk',MD

	IF NOT MPM

PASSMSG:

	IF BANKED
	DEFB	'Password Error',MD
	ENDIF

FXSTSMSG:
	DEFB	'File Exists',MD

WILDMSG:
	DEFB	'? in Filename',MD

	ENDIF

	IF MPM

SETLRET1:
	LD	A,1
STA$RET:
	LD	(ARET),A
FUNC$RET:
	RET
ENTSP:	DEFS	2

	ENDIF

;*****************************************************************
;*****************************************************************
;
;	common values shared between bdosi and bdos

	IF MPM

USRCODE:DEFB	0		; current user number

	ENDIF

ARET:	DEFS	2		; address value to return
LRET	EQU	ARET		; low(aret)

;*****************************************************************
;*****************************************************************
;**								**
;**   b a s i c    d i s k   o p e r a t i n g	 s y s t e m	**
;**								**
;*****************************************************************
;*****************************************************************

;	literal constants

ENDDIR	EQU	0FFFFH		; end of directory
LBYTE	EQU	1		; number of bytes for "byte" type
LWORD	EQU	2		; number of bytes for "word" type

;	fixed addresses in low memory

TFCB	EQU	005CH		; default fcb location
TBUFF	EQU	0080H		; default buffer location

;	error message handlers

ROD$ERROR:
	; report read/only disk error
	LD	C,2
	JP	GOERR

ROF$ERROR:
	; report read/only file error
	LD	C,3
	JP	GOERR

SEL$ERROR:
	; report select error
	LD	C,4
	; Invalidate curdsk to force select call
	; at next curselect call
	LD	A,0FFH
	LD	(CURDSK),A

GOERR:
	; hl = .errorhandler, call subroutine
	LD	H,C
	LD	L,0FFH
	LD	(ARET),HL

	IF MPM
	CALL	TEST$ERRORMODE
	JP	NZ,RTN$PHY$ERRS
	LD	A,C
	LD	HL,PERERR-2
	JP	BDOS$JMP
	ELSE

GOERR1:
	LD	A,(ADRIVE)
	LD	(ERRDRV),A
	LD	A,(ERRORMODE)
	INC	A
	CALL	NZ,ERROR
	ENDIF

RTN$PHY$ERRS:

	IF MPM
	LD	A,(LOCK$SHELL)
	OR	A
	JP	NZ,LOCK$PERR
	ENDIF

	; Return 0ffffh if fx = 27 or 31

	LD	A,(FX)
	CP	27
	JP	Z,GOBACK0
	CP	31
	JP	Z,GOBACK0
	JP	GOBACK

	IF MPM

TEST$ERRORMODE:
	LD	DE,PNAME+4
TEST$ERRORMODE1:
	CALL	RLR
	ADD	HL,DE
	LD	A,(HL)
	AND	80H
	RET
	ENDIF

	IF BANKED

SET$COPY$CR$ONLY:
	LD	A,(COPY$CR$INIT)
	LD	(COPY$CR$ONLY),A
	RET

RESET$COPY$CR$ONLY:
	XOR	A
	LD	(COPY$CR$INIT),A
	LD	(COPY$CR$ONLY),A
	RET

	ENDIF

BDE$E$BDE$M$HL:
	LD	A,E
	SUB	L
	LD	E,A
	LD	A,D
	SBC	A,H
	LD	D,A
	RET	NC
	DEC	B
	RET

BDE$E$BDE$P$HL:
	LD	A,E
	ADD	A,L
	LD	E,A
	LD	A,D
	ADC	A,H
	LD	D,A
	RET	NC
	INC	B
	RET

SHL3BV:
	INC	C
SHL3BV1:
	DEC	C
	RET	Z
	ADD	HL,HL
	ADC	A,A
	JP	SHL3BV1

INCR$RR:
	CALL	GET$RRA
	INC	(HL)
	RET	NZ
	INC	HL
	INC	(HL)
	RET	NZ
	INC	HL
	INC	(HL)
	RET

SAVE$RR:
	CALL	SAVE$RR2
	EX	DE,HL
SAVE$RR1:
	LD	C,3
	JP	MOVE		; ret
SAVE$RR2:
	CALL	GET$RRA
	LD	DE,SAVE$RANR
	RET

RESET$RR:
	CALL	SAVE$RR2
	JP	SAVE$RR1	; ret

COMPARE:
	LD	A,(DE)
	CP	(HL)
	RET	NZ
	INC	HL
	INC	DE
	DEC	C
	RET	Z
	JP	COMPARE

;
;	local subroutines for bios interface
;

MOVE:
	; Move data length of length c from source de to
	; destination given by hl
	INC	C		; in case it is zero
MOVE0:
	DEC	C
	RET	Z		; more to move
	LD	A,(DE)
	LD	(HL),A		; one byte moved
	INC	DE
	INC	HL		; to next byte
	JP	MOVE0

SELECTDISK:
	; Select the disk drive given by register D, and fill
	; the base addresses curtrka - alloca, then fill
	; the values of the disk parameter block
	LD	C,D		; current disk# to c
	; lsb of e = 0 if not yet logged - in
	CALL	SELDSKF		; hl filled by call
	; hl = 0000 if error, otherwise disk headers
	LD	A,H
	OR	L
	RET	Z		; Return with C flag reset if select error
	; Disk header block address in hl
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL		; de=.tran
	LD	(CDRMAXA),HL
	INC	HL
	INC	HL		; .cdrmax
	LD	(CURTRKA),HL
	INC	HL
	INC	HL		; hl=.currec
	LD	(CURRECA),HL
	INC	HL
	INC	HL		; hl=.buffa
	INC	HL
	LD	(DRVLBLA),HL
	INC	HL
	LD	(LSN$ADD),HL
	INC	HL
	INC	HL
	; de still contains .tran
	EX	DE,HL
	LD	(TRANV),HL	; .tran vector
	LD	HL,DPBADDR	; de= source for move, hl=dest
	LD	C,ADDLIST
	CALL	MOVE		; addlist filled
	; Now fill the disk parameter block
	LD	HL,(DPBADDR)
	EX	DE,HL		; de is source
	LD	HL,SECTPT	; hl is destination
	LD	C,DPBLIST
	CALL	MOVE		; data filled
	; Now set single/double map mode
	LD	HL,(MAXALL)	; largest allocation number
	LD	A,H		; 00 indicates < 255
	LD	HL,SINGLE
	LD	(HL),TRUE	; Assume a=00
	OR	A
	JP	Z,RETSELECT
	; high order of maxall not zero, use double dm
	LD	(HL),FALSE
RETSELECT:
	; C flag set indicates successful select
	SCF
	RET

HOME:
	; Move to home position, then offset to start of dir
	CALL	HOMEF
	XOR	A		; constant zero to accumulator
	LD	HL,(CURTRKA)
	LD	(HL),A
	INC	HL
	LD	(HL),A		; curtrk=0000
	LD	HL,(CURRECA)
	LD	(HL),A
	INC	HL
	LD	(HL),A		; currec=0000
	INC	HL
	LD	(HL),A		; currec high byte=00

	IF MPM
	LD	HL,0
	LD	(DBLK),HL	; dblk = 0000
	ENDIF

	RET

RDBUFF:
	; Read buffer and check condition
	LD	A,1
	LD	(READF$SW),A
	CALL	READF		; current drive, track, sector, dma
	JP	DIOCOMP		; Check for i/o errors

WRBUFF:
	; Write buffer and check condition
	; write type (wrtype) is in register c
	XOR	A
	LD	(READF$SW),A
	CALL	WRITEF		; current drive, track, sector, dma
DIOCOMP:; Check for disk errors
	OR	A
	RET	Z
	LD	C,A
	CALL	CHK$MEDIA$FLAG
	LD	A,C
	CP	3
	JP	C,GOERR
	LD	C,1
	JP	GOERR

CHK$MEDIA$FLAG:
	; A = 0ffh -> media changed
	INC	A
	RET	NZ

	IF BANKED
	; Handle media changes as I/O errors for
	; permanent drives
	CALL	CHKSIZ$EQ$8000H
	RET	Z
	ENDIF

	; BIOS says media change occurred
	; Is disk logged-in?
	LD	HL,(DLOG)
	CALL	TESTVECTOR
	LD	C,1
	RET	Z		; no - return error
	CALL	MEDIA$CHANGE
	POP	HL		; Discard return address
	; Was this a flush operation (fx = 48)?
	LD	A,(FX)
	CP	48
	RET	Z		; yes
	; Is this a flush to another drive?
	LD	HL,ADRIVE
	LD	A,(SELDSK)
	CP	(HL)
	JP	NZ,RESET$RELOG
	; Bail out if fx = read, write, close, or search next
	CALL	CHK$EXIT$FXS
	; Is this a directory read operation?
	LD	A,(READF$SW)
	OR	A
	RET	NZ		; yes
	; Error - directory write operation
	LD	C,2
	JP	GOERR		; Return disk read/only error

RESET$RELOG:
	; Reset relog if flushing to another drive
	XOR	A
	LD	(RELOG),A
	RET

	IF BANKED

CHKSIZ$EQ$8000H:
	; Return with Z flag set if drive permanent
	; with no checksum vector
	LD	HL,(CHKSIZ)
	LD	A,80H
	CP	H
	RET	NZ
	XOR	A
	CP	L
	RET

	ENDIF

SEEKDIR:
	; Seek the record containing the current dir entry

	IF MPM
	LD	DE,0FFFFH	; mask = ffff
	LD	HL,(DBLK)
	LD	A,H
	OR	L
	JP	Z,SEEKDIR1
	LD	A,(BLKMSK)
	LD	E,A
	XOR	A
	LD	D,A		; mask = blkmsk
	LD	A,(BLKSHF)
	LD	C,A
	XOR	A
	CALL	SHL3BV		; ahl = shl(dblk,blkshf)
SEEKDIR1:
	PUSH	HL
	PUSH	AF		; Save ahl
	ENDIF

	LD	HL,(DCNT)	; directory counter to hl
	LD	C,DSKSHF
	CALL	HLROTR		; value to hl
	LD	(DREC),HL

	IF MPM

;	arecord = shl(dblk,blkshf) + shr(dcnt,dskshf) & mask

	LD	A,L
	AND	E
	LD	L,A		; dcnt = dcnt & mask
	LD	A,H
	AND	D
	LD	H,A
	POP	BC
	POP	DE
	CALL	BDE$E$BDE$P$HL

	ELSE
	LD	B,0
	EX	DE,HL
	ENDIF

SET$ARECORD:
	LD	HL,ARECORD
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	LD	(HL),B
	RET

SEEK:
	; Seek the track given by arecord (actual record)

	LD	HL,(CURTRKA)
	LD	C,(HL)
	INC	HL
	LD	B,(HL)		; bc = curtrk
	PUSH	BC		; s0 = curtrk
	LD	HL,(CURRECA)
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	B,(HL)		; bde = currec
	LD	HL,(ARECORD)
	LD	A,(ARECORD+2)
	LD	C,A		; chl = arecord
SEEK0:
	LD	A,L
	SUB	E
	LD	A,H
	SBC	A,D
	LD	A,C
	SBC	A,B
	PUSH	HL		; Save low(arecord)
	JP	NC,SEEK1	; if arecord >= currec then go to seek1
	LD	HL,(SECTPT)
	CALL	BDE$E$BDE$M$HL	; currec = currec - sectpt
	POP	HL
	EX	(SP),HL
	DEC	HL
	EX	(SP),HL		; curtrk = curtrk - 1
	JP	SEEK0
SEEK1:
	LD	HL,(SECTPT)
	CALL	BDE$E$BDE$P$HL	; currec = currec + sectpt
	POP	HL		; Restore low(arecord)
	LD	A,L
	SUB	E
	LD	A,H
	SBC	A,D
	LD	A,C
	SBC	A,B
	JP	C,SEEK2		; if arecord < currec then go to seek2
	EX	(SP),HL
	INC	HL
	EX	(SP),HL		; curtrk = curtrk + 1
	PUSH	HL		; save low (arecord)
	JP	SEEK1
SEEK2:
	EX	(SP),HL
	PUSH	HL		; hl,s0 = curtrk, s1 = low(arecord)
	LD	HL,(SECTPT)
	CALL	BDE$E$BDE$M$HL	; currec = currec - sectpt
	POP	HL
	PUSH	DE
	PUSH	BC
	PUSH	HL		; hl,s0 = curtrk,
	; s1 = high(arecord,currec), s2 = low(currec),
	; s3 = low(arecord)
	EX	DE,HL
	LD	HL,(OFFSET)
	ADD	HL,DE
	LD	B,H
	LD	C,L
	LD	(TRACK),HL
	CALL	SETTRKF		; call bios settrk routine
	; Store curtrk
	POP	DE
	LD	HL,(CURTRKA)
	LD	(HL),E
	INC	HL
	LD	(HL),D
	; Store currec
	POP	BC
	POP	DE
	LD	HL,(CURRECA)
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	LD	(HL),B		; currec = bde
	POP	BC		; bc = low(arecord), de = low(currec)
	LD	A,C
	SUB	E
	LD	L,A		; hl = bc - de
	LD	A,B
	SBC	A,D
	LD	H,A
	CALL	SHR$PHYSHF
	LD	B,H
	LD	C,L

	LD	HL,(TRANV)
	EX	DE,HL		; bc=sector#, de=.tran
	CALL	SECTRAN		; hl = tran(sector)
	LD	C,L
	LD	B,H		; bc = tran(sector)
	LD	(SECTOR),HL
	CALL	SETSECF		; sector selected
	LD	HL,(CURDMA)
	LD	C,L
	LD	B,H
	JP	SETDMAF
	; ret
SHR$PHYSHF:
	LD	A,(PHYSHF)
	LD	C,A
	JP	HLROTR

;	file control block (fcb) constants

EMPTY	EQU	0E5H		; empty directory entry
LSTREC	EQU	127		; last record# on extent
RECSIZ	EQU	128		; record size
FCBLEN	EQU	32		; file control block size
DIRREC	EQU	RECSIZ/FCBLEN	; directory fcbs / record
DSKSHF	EQU	2		; log2(dirrec)
DSKMSK	EQU	DIRREC-1
FCBSHF	EQU	5		; log2(fcblen)

EXTNUM	EQU	12		; extent number field
MAXEXT	EQU	31		; largest extent number
UBYTES	EQU	13		; unfilled bytes field
MODNUM	EQU	14		; data module number

MAXMOD	EQU	64		; largest module number

FWFMSK	EQU	80H		; file write flag is high order modnum
NAMLEN	EQU	15		; name length
RECCNT	EQU	15		; record count field
DSKMAP	EQU	16		; disk map field
LSTFCB	EQU	FCBLEN-1
NXTREC	EQU	FCBLEN
RANREC	EQU	NXTREC+1	; random record field (2 bytes)

;	reserved file indicators

ROFILE	EQU	9	; high order of first type char
INVIS	EQU	10		; invisible file in dir command

;	utility functions for file access

DM$POSITION:
	; Compute disk map position for vrecord to hl
	LD	HL,BLKSHF
	LD	C,(HL)		; shift count to c
	LD	A,(VRECORD)	; current virtual record to a
DMPOS0:
	OR	A
	RRA
	DEC	C
	JP	NZ,DMPOS0
	; a = shr(vrecord,blkshf) = vrecord/2**(sect/block)
	LD	B,A		; Save it for later addition
	LD	A,8
	SUB	(HL)		; 8-blkshf to accumulator
	LD	C,A		; extent shift count in register c
	LD	A,(EXTVAL)	; extent value ani extmsk
DMPOS1:
	; blkshf = 3,4,5,6,7, c=5,4,3,2,1
	; shift is 4,3,2,1,0
	DEC	C
	JP	Z,DMPOS2
	OR	A
	RLA
	JP	DMPOS1
DMPOS2:
	; Arrive here with a = shl(ext and extmsk,7-blkshf)
	ADD	A,B		; Add the previous shr(vrecord,blkshf) value
	; a is one of the following values, depending upon alloc
	; bks blkshf
	; 1k   3     v/8 + extval * 16
	; 2k   4     v/16+ extval * 8
	; 4k   5     v/32+ extval * 4
	; 8k   6     v/64+ extval * 2
	; 16k  7     v/128+extval * 1
	RET			; with dm$position in a

GETDMA:
	LD	HL,(INFO)
	LD	DE,DSKMAP
	ADD	HL,DE
	RET

GETDM:
	; Return disk map value from position given by bc
	CALL	GETDMA
	ADD	HL,BC		; Index by a single byte value
	LD	A,(SINGLE)	; single byte/map entry?
	OR	A
	JP	Z,GETDMD	; Get disk map single byte
	LD	L,(HL)
	LD	H,B
	RET			; with hl=00bb
GETDMD:
	ADD	HL,BC		; hl=.fcb(dm+i*2)
	; double precision value returned
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	RET

INDEX:
	; Compute disk block number from current fcb
	CALL	DM$POSITION	; 0...15 in register a
	LD	(DMINX),A
	LD	C,A
	LD	B,0
	CALL	GETDM		; value to hl
	LD	(ARECORD),HL
	LD	A,L
	OR	H
	RET

ATRAN:
	; Compute actual record address, assuming index called

;	arecord = shl(arecord,blkshf)

	LD	A,(BLKSHF)
	LD	C,A
	LD	HL,(ARECORD)
	XOR	A
	CALL	SHL3BV
	LD	(ARECORD),HL
	LD	(ARECORD+2),A

	LD	(ARECORD1),HL	; Save low(arecord)

;	arecord = arecord or (vrecord and blkmsk)

	LD	A,(BLKMSK)
	LD	C,A
	LD	A,(VRECORD)
	AND	C
	LD	B,A		; Save vrecord & blkmsk in reg b & blk$off
	LD	(BLK$OFF),A
	LD	HL,ARECORD
	OR	(HL)
	LD	(HL),A
	RET

GET$ATTS:
	; Get volatile attributes starting at f'5
	; info locates fcb
	LD	HL,(INFO)
	LD	DE,8
	ADD	HL,DE		; hl = .fcb(f'8)
	LD	C,4
GET$ATTS$LOOP:
	LD	A,(HL)
	ADD	A,A
	PUSH	AF
	LD	A,D
	RRA
	LD	D,A
	POP	AF
	RRCA
	LD	(HL),A
	DEC	HL
	DEC	C
	JP	NZ,GET$ATTS$LOOP
	LD	A,D
	RET

GETS1:
	; Get current s1 field to a
	CALL	GETEXTA
	INC	HL
	LD	A,(HL)
	RET

GET$RRA:
	; Get current ran rec field address to hl
	LD	HL,(INFO)
	LD	DE,RANREC
	ADD	HL,DE		; hl=.fcb(ranrec)
	RET

GETEXTA:
	; Get current extent field address to hl
	LD	HL,(INFO)
	LD	DE,EXTNUM
	ADD	HL,DE		; hl=.fcb(extnum)
	RET

GETRCNTA:
	; Get reccnt address to hl
	LD	HL,(INFO)
	LD	DE,RECCNT
	ADD	HL,DE
	RET

GETFCBA:
	; Compute reccnt and nxtrec addresses for get/setfcb
	CALL	GETRCNTA
	EX	DE,HL		; de=.fcb(reccnt)
	LD	HL,[NXTREC-RECCNT]
	ADD	HL,DE		; hl=.fcb(nxtrec)
	RET

GETFCB:
	; Set variables from currently addressed fcb
	CALL	GETFCBA		; addresses in de, hl
	LD	A,(HL)
	LD	(VRECORD),A	; vrecord=fcb(nxtrec)
	EX	DE,HL
	LD	A,(HL)
	OR	A
	JP	NZ,GETFCB0
	CALL	GET$DIR$EXT
	LD	C,A
	CALL	SET$RC
	LD	A,(HL)
GETFCB0:
	CP	81H
	JP	C,GETFCB1
	LD	A,80H
GETFCB1:
	LD	(RCOUNT),A	; rcount=fcb(reccnt) or 80h
	CALL	GETEXTA		; hl=.fcb(extnum)
	LD	A,(EXTMSK)	; extent mask to a
	AND	(HL)		; fcb(extnum) and extmsk
	LD	(EXTVAL),A
	RET

SETFCB:
	; Place values back into current fcb
	CALL	GETFCBA		; addresses to de, hl
	; fcb(cr) = vrecord
	LD	A,(VRECORD)
	LD	(HL),A
	; Is fx < 22? (sequential read or write)
	LD	A,(FX)
	CP	22
	JP	NC,$+4		; no
	; fcb(cr) = fcb(cr) + 1
	INC	(HL)
	EX	DE,HL
	LD	A,(HL)
	CP	80H
	RET	NC		; dont reset fcb(rc) if > 7fh
	LD	A,(RCOUNT)
	LD	(HL),A		; fcb(reccnt)=rcount
	RET

ZERO$EXT$MOD:
	CALL	GETEXTA
	LD	(HL),D
	INC	HL
	INC	HL
	LD	(HL),D
	RET

ZERO:
	LD	(HL),B
	INC	HL
	DEC	C
	RET	Z
	JP	ZERO

HLROTR:
	; hl rotate right by amount c
	INC	C		; in case zero
HLROTR0:DEC	C
	RET	Z		; return when zero
	LD	A,H
	OR	A
	RRA
	LD	H,A		; high byte
	LD	A,L
	RRA
	LD	L,A		; low byte
	JP	HLROTR0

COMPUTE$CS:
	; Compute checksum for current directory buffer
	LD	HL,(BUFFA)	; current directory buffer
	LD	BC,4		; b = 0, c = 4
COMPUTE$CS0:
	LD	D,32		; size of fcb
	XOR	A		; clear checksum value
COMPUTE$CS1:
	ADD	A,(HL)
	INC	HL
	DEC	D
	JP	NZ,COMPUTE$CS1
	XOR	B
	LD	B,A
	DEC	C
	JP	NZ,COMPUTE$CS0
	RET			; with checksum in a

	IF MPM

COMPUTE$CS:
	; Compute checksum for current directory buffer
	LD	C,RECSIZ	; size of directory buffer
	LD	HL,(BUFFA)	; current directory buffer
	XOR	A		; Clear checksum value
COMPUTECS0:
	ADD	A,(HL)
	INC	HL
	DEC	C		; cs = cs+buff(recsiz-c)
	JP	NZ,COMPUTECS0
	RET			; with checksum in a

CHKSUM$FCB: ; Compute checksum for fcb
	; Add 1st 12 bytes of fcb + curdsk +
	;     high$ext + xfcb$read$only + bbh
	LD	HL,PDCNT
	LD	A,(HL)
	INC	HL
	ADD	A,(HL)		; Add high$ext
	INC	HL
	ADD	A,(HL)		; Add xfcb$read$only
	INC	HL
	ADD	A,(HL)		; Add curdsk
	ADD	A,0BBH		; Add 0bbh to bias checksum
	LD	HL,(INFO)
	LD	C,12
	CALL	COMPUTECS0
	; Skip extnum
	INC	HL
	; Add fcb(s1)
	ADD	A,(HL)
	INC	HL
	; Skip modnum
	INC	HL
	; Skip fcb(reccnt)
	; Add disk map
	INC	HL
	LD	C,16
	CALL	COMPUTECS0
	OR	A
	RET			; Z flag set if checksum valid

SET$CHKSUM$FCB:
	CALL	CHKSUM$FCB
	RET	Z
	LD	B,A
	CALL	GETS1
	CPL
	ADD	A,B
	CPL
	LD	(HL),A
	RET

RESET$CHKSUM$FCB:
	XOR	A
	LD	(COMP$FCB$CKS),A
	CALL	CHKSUM$FCB
	RET	NZ
	CALL	GETS1
	INC	(HL)
	RET

	ENDIF

CHECK$FCB:

	IF MPM
	XOR	A
	LD	(CHECK$FCB4),A
CHECK$FCB1:
	CALL	CHEK$FCB
	RET	Z
CHECK$FCB2:

	AND	0FH
	JP	NZ,CHECK$FCB3
	LD	A,(PDCNT)
	OR	A
	JP	Z,CHECK$FCB3
	CALL	SET$SDCNT
	LD	(DONT$CLOSE),A
	CALL	CLOSE1
	LD	HL,LRET
	INC	(HL)
	JP	Z,CHECK$FCB3
	LD	(HL),0
	CALL	PACK$SDCNT
	LD	B,5
	CALL	SEARCH$OLIST
	RET	Z
CHECK$FCB3:

	POP	HL		; Discard return address
CHECK$FCB4:
	NOP
	LD	A,10
	JP	STA$RET

SET$FCB$CKS$FLAG:
	LD	A,0FFH
	LD	(COMP$FCB$CKS),A
	RET

	ELSE
	CALL	GETS1
	LD	HL,(LSN$ADD)
	CP	(HL)
	CALL	NZ,CHK$MEDIA$FCB
	ENDIF

CHEK$FCB:
	LD	A,(HIGH$EXT)

	IF MPM

	; if ext & 0110$0000b = 0110$0000b then
	; set fcb(0) to 0 (user 0)

	CP	0110$0000B
	JP	NZ,CHEK$FCB1
	ELSE
	OR	A
	RET	Z
	ENDIF

	LD	HL,(INFO)
	XOR	A
	LD	(HL),A		; fcb(0) = 0
CHEK$FCB1:

	IF MPM
	JP	CHKSUM$FCB	; ret
	ELSE
	RET

CHK$MEDIA$FCB:
	; fcb(s1) ~= DPH login sequence # field
	; Is fcb addr < bdosadd?

	IF BANKED
	LD	HL,(USER$INFO)
	ELSE
	LD	HL,(INFO)
	ENDIF

	EX	DE,HL
	LD	HL,(BDOSADD)
	CALL	SUBDH
	JP	NC,CHK$MEDIA1	; no
	; Is rlog(drive) true?
	LD	HL,(RLOG)
	CALL	TESTVECTOR
	RET	Z		; no
CHK$MEDIA1:
	; Return invalid fcb error code
	POP	HL
	POP	HL
CHK$MEDIA2:
	LD	A,10
	JP	STA$RET
	ENDIF

HLROTL:
	; Rotate the mask in hl by amount in c
	INC	C		; may be zero
HLROTL0:DEC	C
	RET	Z		; return if zero
	ADD	HL,HL
	JP	HLROTL0

SET$DLOG:
	LD	DE,DLOG
SET$CDISK:
	; Set a "1" value in curdsk position of bc
	LD	A,(CURDSK)
SET$CDISK1:
	LD	C,A		; Ready parameter for shift
	LD	HL,1		; number to shift
	CALL	HLROTL		; hl = mask to integrate
	LD	A,(DE)
	OR	L
	LD	(DE),A
	INC	DE
	LD	A,(DE)
	OR	H
	LD	(DE),A
	RET

NOWRITE:
	; Return true if dir checksum difference occurred
	LD	HL,(RODSK)

TESTVECTOR:
	LD	A,(CURDSK)
TESTVECTOR1:
	LD	C,A
	CALL	HLROTR
	LD	A,L
	AND	1B
	RET			; non zero if curdsk bit on

CHECK$RODIR:
	; Check current directory element for read/only status
	CALL	GETDPTRA	; address of element

CHECK$ROFILE:
	; Check current buff(dptr) or fcb(0) for r/o status
	CALL	RO$TEST
	RET	NC		; Return if not set
	JP	ROF$ERROR	; Exit to read only disk message

RO$TEST:
	LD	DE,ROFILE
	ADD	HL,DE
	LD	A,(HL)
	RLA
	RET			; carry set if r/o

CHECK$WRITE:
	; Check for write protected disk
	CALL	NOWRITE
	RET	Z		; ok to write if not rodsk
	JP	ROD$ERROR	; read only disk error

GETDPTRA:
	; Compute the address of a directory element at
	; positon dptr in the buffer

	LD	HL,(BUFFA)
	LD	A,(DPTR)
ADDH:
	; hl = hl + a
	ADD	A,L
	LD	L,A
	RET	NC
	; overflow to h
	INC	H
	RET

GETMODNUM:
	; Compute the address of the module number
	; bring module number to accumulator
	; (high order bit is fwf (file write flag)
	LD	HL,(INFO)
	LD	DE,MODNUM
	ADD	HL,DE		; hl=.fcb(modnum)
	LD	A,(HL)
	RET			; a=fcb(modnum)

CLRMODNUM:
	; Clear the module number field for user open/make
	CALL	GETMODNUM
	LD	(HL),0		; fcb(modnum)=0
	RET

CLR$EXT:
	; fcb ext = fcb ext & 1fh
	CALL	GETEXTA
	LD	A,(HL)
	AND	00011111B
	LD	(HL),A
	RET

SETFWF:
	CALL	GETMODNUM	; hl=.fcb(modnum), a=fcb(modnum)
	; Set fwf (file write flag) to "1"
	OR	FWFMSK
	LD	(HL),A		; fcb(modnum)=fcb(modnum) or 80h
	; also returns non zero in accumulator
	RET

COMPCDR:
	; Return cy if cdrmax > dcnt
	LD	HL,(DCNT)
	EX	DE,HL		; de = directory counter
	LD	HL,(CDRMAXA)	; hl=.cdrmax
	LD	A,E
	SUB	(HL)		; low(dcnt) - low(cdrmax)
	INC	HL		; hl = .cdrmax+1
	LD	A,D
	SBC	A,(HL)		; hig(dcnt) - hig(cdrmax)
	; condition dcnt - cdrmax  produces cy if cdrmax>dcnt
	RET

SETCDR:
	; if not (cdrmax > dcnt) then cdrmax = dcnt+1
	CALL	COMPCDR
	RET	C		; Return if cdrmax > dcnt
	; otherwise, hl = .cdrmax+1, de = dcnt
	INC	DE
	LD	(HL),D
	DEC	HL
	LD	(HL),E
	RET

SUBDH:
	; Compute hl = de - hl
	LD	A,E
	SUB	L
	LD	L,A
	LD	A,D
	SBC	A,H
	LD	H,A
	RET

NEWCHECKSUM:
	LD	C,0FEH		; Drop through to compute new checksum
CHECKSUM:
	; Compute current checksum record and update the
	; directory element if c=true, or check for = if not
	; drec < chksiz?
	LD	HL,(DREC)
	EX	DE,HL
	LD	HL,(CHKSIZ)
	LD	A,H
	AND	7FH
	LD	H,A		; Mask off permanent drive bit
	CALL	SUBDH		; de-hl
	RET	NC		; Skip checksum if past checksum vector size
	; drec < chksiz, so continue
	PUSH	BC		; Save init flag
	CALL	COMPUTE$CS	; Check sum value to a
	LD	HL,(CHECKA)	; address of check sum vector
	EX	DE,HL
	LD	HL,(DREC)
	ADD	HL,DE		; hl = .check(drec)
	POP	BC		; Recall true=0ffh or false=00 to c
	INC	C		; 0ffh produces zero flag
	JP	Z,INITIAL$CS
	INC	C		; 0feh produces zero flag
	JP	Z,UPDATE$CS

	IF MPM
	INC	C
	JP	Z,TEST$DIR$CS
	ENDIF

	; not initializing, compare
	CP	(HL)		; compute$cs=check(drec)?
	RET	Z		; no message if ok
	; checksum error, are we beyond
	; the end of the disk?
	CALL	NOWRITE
;;;			rnz	;[JCE] DRI Patch 13
	NOP

MEDIA$CHANGE:
	CALL	DISCARD$DATA

	IF MPM
	CALL	FLUSH$FILE0
	ELSE
	LD	A,0FFH
	LD	(RELOG),A
	LD	(HASHL),A
	CALL	SET$RLOG
	ENDIF

	; Reset the drive

	CALL	SET$DLOG
	JP	RESET$37X

	IF MPM
TEST$DIR$CS:
	CP	(HL)
	JP	NZ,FLUSH$FILES
	RET
	ENDIF

INITIAL$CS:
	; initializing the checksum
	CP	(HL)
	LD	(HL),A
	RET	Z
	; or 1 into login seq # if media change
	LD	HL,(LSN$ADD)
	LD	A,1
	OR	(HL)
	LD	(HL),A
	RET

UPDATE$CS:
	; updating the checksum
	LD	(HL),A
	RET

SET$RO:
	; Set current disk to read/only
	LD	A,(SELDSK)
	LD	DE,RODSK
	CALL	SET$CDISK1	; sets bit to 1
	; high water mark in directory goes to max
	LD	HL,(DIRMAX)
	INC	HL
	EX	DE,HL		; de = directory max
	LD	HL,(CDRMAXA)	; hl = .cdrmax
	LD	(HL),E
	INC	HL
	LD	(HL),D		; cdrmax = dirmax
	RET

SET$RLOG:
	; rlog(seldsk) = true
	LD	HL,(OLOG)
	CALL	TESTVECTOR
	RET	Z
	LD	DE,RLOG
	JP	SET$CDISK

TST$LOG$FXS:
	LD	A,(CHKSIZ+1)
	AND	80H
	RET	NZ
	LD	HL,LOG$FXS
TST$LOG0:
	LD	A,(FX)
	LD	B,A
TST$LOG1:
	LD	A,(HL)
	CP	B
	RET	Z
	INC	HL
	OR	A
	JP	NZ,TST$LOG1
	INC	A
	RET

TEST$MEDIA$FLAG:
	LD	HL,(LSN$ADD)
	INC	HL
	LD	A,(HL)
	OR	A
	RET

CHK$EXIT$FXS:
	LD	HL,GOBACK
	PUSH	HL
	; does fx = read or write function?
	; and is drive removable?
	LD	HL,RW$FXS
	CALL	TST$LOG0
	JP	Z,CHK$MEDIA2	; yes
	; is fx = close or searchn function?
	; and is drive removable?
	LD	HL,SC$FXS
	CALL	TST$LOG0
	JP	Z,LRET$EQ$FF	; yes
	POP	HL
	RET

TST$RELOG:
	LD	HL,RELOG
	LD	A,(HL)
	OR	A
	RET	Z
	LD	(HL),0
DRV$RELOG:
	CALL	CURSELECT
	LD	HL,0
	LD	(DCNT),HL
	XOR	A
	LD	(DPTR),A
	RET

SET$LSN:
	LD	HL,(LSN$ADD)
	LD	C,(HL)
	CALL	GETS1
	LD	(HL),C
	RET

DISCARD$DATA$BCB:
	LD	HL,(DTABCBA)
	LD	C,4
	JP	DISCARD0

DISCARD$DATA:
	LD	HL,(DTABCBA)
	JP	DISCARD

DISCARD$DIR:
	LD	HL,(DIRBCBA)

DISCARD:
	LD	C,1
DISCARD0:
	LD	A,L
	AND	H
	INC	A
	RET	Z

	IF BANKED
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
DISCARD1:
	PUSH	HL
	PUSH	BC
	LD	DE,ADRIVE
	CALL	COMPARE
	POP	BC
	POP	HL
	JP	NZ,DISCARD2

	LD	(HL),0FFH
DISCARD2:
	LD	DE,13
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	LD	A,L
	OR	H
	RET	Z
	JP	DISCARD1
	ELSE
	PUSH	HL
	LD	DE,ADRIVE
	CALL	COMPARE
	POP	HL
	RET	NZ
	LD	(HL),0FFH
	RET
	ENDIF

GETBUFFA:
	PUSH	DE
	LD	DE,10
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)

	IF BANKED
	INC	HL
	LD	A,(HL)
	LD	(BUFFER$BANK),A
	ENDIF

	EX	DE,HL
	POP	DE
	RET

RDDIR:
	; Read a directory entry into the directory buffer
	CALL	SEEKDIR
	LD	A,3
	JP	WRDIR0

SEEK$COPY:
WRDIR:
	; Write the current directory entry, set checksum
	CALL	CHECK$WRITE
	CALL	NEWCHECKSUM	; Initialize entry
	LD	A,5
WRDIR0:
	LD	HL,0
	LD	(LAST$BLOCK),HL
	LD	HL,(DIRBCBA)

	IF BANKED
	CP	5
	JP	NZ,$+6
	LD	HL,(CURBCBA)
	ENDIF

	CALL	DEBLOCK

SETDATA:
	; Set data dma address
	LD	HL,(DMAAD)
	JP	SETDMA		; to complete the call

SETDIR1:
	CALL	GETBUFFA

SETDMA:
	; hl=.dma address to set (i.e., buffa or dmaad)
	LD	(CURDMA),HL
	RET

DIR$TO$USER:

	IF NOT MPM
	; Copy the directory entry to the user buffer
	; after call to search or searchn by user code
	LD	HL,(BUFFA)
	EX	DE,HL		; source is directory buffer
	LD	HL,(XDMAAD)	; destination is user dma address
	LD	BC,RECSIZ	; copy entire record
	CALL	MOVEF
	ENDIF
	; Set lret to dcnt & 3 if search successful
	LD	HL,LRET
	LD	A,(HL)
	INC	A
	RET	Z
	LD	A,(DCNT)
	AND	DSKMSK
	LD	(HL),A
	RET

MAKE$FCB$INV: ; Flag fcb as invalid
	; Reset fcb write flag
	CALL	SETFWF
	; Set 1st two bytes of diskmap to ffh
	INC	HL
	INC	HL
	LD	A,0FFH
	LD	(HL),A
	INC	HL
	LD	(HL),A
	RET

CHK$INV$FCB: ; Check for invalid fcb
	CALL	GETDMA
	JP	TEST$FFFF

TST$INV$FCB: ; Test for invalid fcb
	CALL	CHK$INV$FCB
	RET	NZ
	POP	HL
	LD	A,9
	JP	STA$RET
	; lret = 9

END$OF$DIR:
	; Return zero flag if at end of directory, non zero
	; if not at end (end of dir if dcnt = 0ffffh)
	LD	HL,DCNT
TEST$FFFF:
	LD	A,(HL)		; may be 0ffh
	INC	HL
	CP	(HL)		; low(dcnt) = high(dcnt)?
	RET	NZ		; non zero returned if different
	; high and low the same, = 0ffh?
	INC	A		; 0ffh becomes 00 if so
	RET

SETENDDIR:
	; Set dcnt to the end of the directory
	LD	HL,ENDDIR
	LD	(DCNT),HL
	RET

READ$DIR:
	CALL	R$DIR
	JP	R$DIR1

R$DIR:
	; Read next directory entry, with c=true if initializing

	LD	HL,(DIRMAX)
	EX	DE,HL		; in preparation for subtract
	LD	HL,(DCNT)
	INC	HL
	LD	(DCNT),HL	; dcnt=dcnt+1
	; Continue while dirmax >= dcnt (dirmax-dcnt no cy)
	CALL	SUBDH		; de-hl

	JP	C,SETENDDIR

READ$DIR0:
	; not at end of directory, seek next element
	; initialization flag is in c
	LD	A,(DCNT)
	AND	DSKMSK		; low(dcnt) and dskmsk
	LD	B,FCBSHF	; to multiply by fcb size
READ$DIR1:
	ADD	A,A
	DEC	B
	JP	NZ,READ$DIR1
	; a = (low(dcnt) and dskmsk) shl fcbshf
	LD	(DPTR),A	; ready for next dir operation
	OR	A
	RET	NZ		; Return if not a new record
READ$DIR2:
	PUSH	BC		; Save initialization flag c
	CALL	RDDIR		; Read the directory record
	POP	BC		; Recall initialization flag
	LD	A,(RELOG)
	OR	A
	RET	NZ
	JP	CHECKSUM	; Checksum the directory elt

R$DIR2:
	CALL	READ$DIR2
R$DIR1:
	LD	A,(RELOG)
	OR	A
	RET	Z
	CALL	CHK$EXIT$FXS
	CALL	TST$RELOG
	JP	RDDIR

GETALLOCBIT:
	; Given allocation vector position bc, return with byte
	; containing bc shifted so that the least significant
	; bit is in the low order accumulator position.  hl is
	; the address of the byte for possible replacement in
	; memory upon return, and d contains the number of shifts
	; required to place the returned value back into position
	LD	A,C
	AND	111B
	INC	A
	LD	E,A
	LD	D,A
	; d and e both contain the number of bit positions to shift

	LD	H,B
	LD	L,C
	LD	C,3		; bc = bc shr 3
	CALL	HLROTR		; hlrotr does not touch d and e
	LD	B,H
	LD	C,L

	LD	HL,(ALLOCA)	; base address of allocation vector
	ADD	HL,BC
	LD	A,(HL)		; byte to a, hl = .alloc(bc shr 3)
	; Now move the bit to the low order position of a
ROTL:	RLCA
	DEC	E
	JP	NZ,ROTL
	RET

SETALLOCBIT:
	; bc is the bit position of alloc to set or reset.  the
	; value of the bit is in register e.
	PUSH	DE
	CALL	GETALLOCBIT	; shifted val a, count in d
	AND	11111110B	; mask low bit to zero (may be set)
	POP	BC
	OR	C		; low bit of c is masked into a
	; jmp rotr ; to rotate back into proper position
	; ret

ROTR:
	; byte value from alloc is in register a, with shift count
	; in register c (to place bit back into position), and
	; target alloc position in registers hl, rotate and replace
	RRCA
	DEC	D
	JP	NZ,ROTR		; back into position
	LD	(HL),A		; back to alloc
	RET

COPY$ALV:
	; If Z flag set, copy 1st ALV to 2nd
	; Otherwise, copy 2nd ALV to 1st

	IF NOT BANKED
	LD	A,(BDOS$FLAGS)
	RLCA
	RLCA
	RET	C
	ENDIF

	PUSH	AF
	CALL	GET$NALBS
	LD	B,H
	LD	C,L
	LD	HL,(ALLOCA)
	LD	D,H
	LD	E,L
	ADD	HL,BC
	POP	AF
	JP	Z,MOVEF
	EX	DE,HL
	JP	MOVEF

SCANDM$AB:
	; Set/Reset 1st and 2nd ALV
	PUSH	BC
	CALL	SCANDM$A
	POP	BC
	;jmp scandm$b

SCANDM$B:
	; Set/Reset 2nd ALV

	IF NOT BANKED
	LD	A,(BDOS$FLAGS)
	AND	40H
	RET	NZ
	ENDIF

	PUSH	BC
	CALL	GET$NALBS
	EX	DE,HL
	LD	HL,(ALLOCA)
	POP	BC
	PUSH	HL
	ADD	HL,DE
	LD	(ALLOCA),HL
	CALL	SCANDM$A
	POP	HL
	LD	(ALLOCA),HL
	RET

SCANDM$A:
	; Set/Reset 1st ALV
	; Scan the disk map addressed by dptr for non-zero
	; entries, the allocation vector entry corresponding
	; to a non-zero entry is set to the value of c (0,1)
	CALL	GETDPTRA	; hl = buffa + dptr
	; hl addresses the beginning of the directory entry
	LD	DE,DSKMAP
	ADD	HL,DE		; hl now addresses the disk map
	PUSH	BC		; Save the 0/1 bit to set
	LD	C,FCBLEN-DSKMAP+1; size of single byte disk map + 1
SCANDM0:
	; Loop once for each disk map entry
	POP	DE		; Recall bit parity
	DEC	C
	RET	Z		; all done scanning?
	; no, get next entry for scan
	PUSH	DE		; Replace bit parity
	LD	A,(SINGLE)
	OR	A
	JP	Z,SCANDM1
	; single byte scan operation
	PUSH	BC		; Save counter
	PUSH	HL		; Save map address
	LD	C,(HL)
	LD	B,0		; bc=block#
	JP	SCANDM2
SCANDM1:
	; double byte scan operation
	DEC	C		; count for double byte
	PUSH	BC		; Save counter
	LD	C,(HL)
	INC	HL
	LD	B,(HL)		; bc=block#
	PUSH	HL		; Save map address
SCANDM2:
	; Arrive here with bc=block#, e=0/1
	LD	A,C
	OR	B		; Skip if = 0000
	JP	Z,SCANDM3
	LD	HL,(MAXALL)	; Check invalid index
	LD	A,L
	SUB	C
	LD	A,H
	SBC	A,B		; maxall - block#
	CALL	NC,SETALLOCBIT
	; bit set to 0/1
SCANDM3:
	POP	HL
	INC	HL		; to next bit position
	POP	BC		; Recall counter
	JP	SCANDM0		; for another item

GET$NALBS: ; Get # of allocation vector bytes
	LD	HL,(MAXALL)
	LD	C,3
	; number of bytes in allocation vector is (maxall/8)+1
	CALL	HLROTR
	INC	HL
	RET

	IF MPM

TEST$DIR:
	CALL	HOME
	CALL	SETENDDIR
TEST$DIR1:
	LD	C,0FEH
	CALL	READ$DIR
	LD	A,(FLUSHED)
	OR	A
	RET	NZ
	CALL	END$OF$DIR
	RET	Z
	JP	TEST$DIR1
	ENDIF

INITIALIZE:
	; Initialize the current disk
	; lret = false ; set to true if $ file exists
	; Compute the length of the allocation vector - 2

	IF MPM
	LD	HL,(TLOG)
	CALL	TESTVECTOR
	JP	Z,INITIALIZE1
	LD	HL,(TLOG)
	CALL	REMOVE$DRIVE
	LD	(TLOG),HL
	XOR	A
	LD	(FLUSHED),A
	CALL	TEST$DIR
	RET	Z
INITIALIZE1:
	ELSE

	CALL	TEST$MEDIA$FLAG
	LD	(HL),0
;;;	call discard$data ;[JCE] DRI Patch 13
;;;	call discard$dir

	ENDIF
;[JCE] DRI Patch 13

	IF BANKED
;;;	; Is drive permanent with no chksum vector?
;;;	call chksiz$eq$8000h
;;;	jnz initialize2 ; no
;;;	; Is this an initial login operation?
;;;	; register A = 0
;;;	lhld lsn$add
;;;	cmp m
;;;	mvi m,2
;;;	call test$media$flag
;;;	mvi m,0 ; Reset media change flag
	CALL	CHKSIZ$EQ$8000H
	JP	NZ,PATCH$13FF
	LD	HL,(LSN$ADD)
	CP	(HL)
	NOP
	NOP
	JP	Z,PATCH$13FF
	JP	PATCH$2D40

PATCH$13FF:

	CALL	DISCARD$DATA
	CALL	DISCARD$DIR

INITIALIZE2:
	ELSE	;BANKED
	CALL	DISCARD$DATA	;[JCE] DRI Patch 13
	CALL	DISCARD$DIR

	ENDIF

	CALL	GET$NALBS	; Get # of allocation vector bytes
	LD	B,H
	LD	C,L		; Count down bc til zero
	LD	HL,(ALLOCA)	; base of allocation vector
	; Fill the allocation vector with zeros
INITIAL0:
	LD	(HL),0
	INC	HL		; alloc(i)=0
	DEC	BC		; Count length down
	LD	A,B
	OR	C
	JP	NZ,INITIAL0

	LD	HL,(DRVLBLA)
	LD	(HL),A		; Zero out drive desc byte

	; Set the reserved space for the directory

	LD	HL,(DIRBLK)
	EX	DE,HL
	LD	HL,(ALLOCA)	; hl=.alloc()
	LD	(HL),E
	INC	HL
	LD	(HL),D		; sets reserved directory blks
	; allocation vector initialized, home disk
	CALL	HOME
	; cdrmax = 3 (scans at least one directory record)
	LD	HL,(CDRMAXA)
	LD	(HL),4
	INC	HL
	LD	(HL),0

	CALL	SETENDDIR	; dcnt = enddir
	LD	HL,(HASHTBLA)
	LD	(ARECORD1),HL

	; Read directory entries and check for allocated storage

INITIAL2:
	LD	C,TRUE
	CALL	READ$DIR
	CALL	END$OF$DIR
	IF BANKED
	JP	Z,PATCH$2D6A	;[JCE] DRI Patch 13
	ELSE
	JP	Z,COPY$ALV
	ENDIF
	; not end of directory, valid entry?
	CALL	GETDPTRA	; hl = buffa + dptr
	EX	DE,HL
	LD	HL,(ARECORD1)
	LD	A,H
	AND	L
	INC	A
	EX	DE,HL
	; is hashtbla ~= 0ffffh
	CALL	NZ,INIT$HASH	; yes - call init$hash
	LD	A,21H
	CP	(HL)
	JP	Z,INITIAL2	; Skip date & time records

	LD	A,EMPTY
	CP	(HL)
	JP	Z,INITIAL2	; go get another item

	LD	A,20H
	CP	(HL)
	JP	Z,DRV$LBL
	LD	A,10H
	AND	(HL)
	JP	NZ,INITIAL3

	; Now scan the disk map for allocated blocks

	LD	C,1		; set to allocated
	CALL	SCANDM$A
INITIAL3:
	CALL	SETCDR		; set cdrmax to dcnt
	JP	INITIAL2	; for another entry

DRV$LBL:
	LD	DE,EXTNUM
	ADD	HL,DE
	LD	A,(HL)
	LD	HL,(DRVLBLA)
	LD	(HL),A
	JP	INITIAL3

COPY$DIRLOC:
	; Copy directory location to lret following
	; delete, rename, ... ops

	LD	A,(DIRLOC)
	JP	STA$RET
	; ret

COMPEXT:
	; Compare extent# in a with that in c, return nonzero
	; if they do not match
	PUSH	BC		; Save c's original value
	PUSH	AF
	LD	A,(EXTMSK)
	CPL
	LD	B,A
	; b has negated form of extent mask
	LD	A,C
	AND	B
	LD	C,A		; low bits removed from c
	POP	AF
	AND	B		; low bits removed from a
	SUB	C
	AND	MAXEXT		; Set flags
	POP	BC		; Restore original values
	RET

GET$DIR$EXT:
	; Compute directory extent from fcb
	; Scan fcb disk map backwards
	CALL	GETFCBA		; hl = .fcb(vrecord)
	LD	C,16
	LD	B,C
	INC	C
	PUSH	BC
	; b=dskmap pos (rel to 0)
GET$DE0:
	POP	BC
	DEC	C
	XOR	A		; Compare to zero
GET$DE1:
	DEC	HL
	DEC	B		; Decr dskmap position
	CP	(HL)
	JP	NZ,GET$DE2	; fcb(dskmap(b)) ~= 0
	DEC	C
	JP	NZ,GET$DE1
	; c = 0 -> all blocks = 0 in fcb disk map
GET$DE2:
	LD	A,C
	LD	(DMINX),A
	LD	A,(SINGLE)
	OR	A
	LD	A,B
	JP	NZ,GET$DE3
	RRA			; not single, divide blk idx by 2
GET$DE3:
	PUSH	BC
	PUSH	HL		; Save dskmap position & count
	LD	L,A
	LD	H,0		; hl = non-zero blk idx
	; Compute ext offset from last non-zero
	; block index by shifting blk idx right
	; 7 - blkshf
	LD	A,(BLKSHF)
	LD	D,A
	LD	A,7
	SUB	D
	LD	C,A
	CALL	HLROTR
	LD	B,L
	; b = ext offset
	LD	A,(EXTMSK)
	CP	B
	POP	HL
	JP	C,GET$DE0
	; Verify computed extent offset <= extmsk
	CALL	GETEXTA
	LD	C,(HL)
	CPL
	AND	MAXEXT
	AND	C
	OR	B
	; dir ext = (fcb ext & (~ extmsk) & maxext) | ext offset
	POP	BC		; Restore stack
	RET			; a = directory extent

SEARCHI:
	; search initialization
	LD	HL,(INFO)
	LD	(SEARCHA),HL	; searcha = info
SEARCHI1:
	LD	A,C
	LD	(SEARCHL),A	; searchl = c
	CALL	SET$HASH
	LD	A,0FFH
	LD	(DIRLOC),A	; changed if actually found
	RET

SEARCH$NAMLEN:
	LD	C,NAMLEN
	JP	SEARCH
SEARCH$EXTNUM:
	LD	C,EXTNUM
SEARCH:
	; Search for directory element of length c at info
	CALL	SEARCHI
SEARCH1:; entry point used by rename
	CALL	SETENDDIR	; dcnt = enddir
	CALL	TST$LOG$FXS
	CALL	Z,HOME
	; (drop through to searchn)

SEARCHN:
	; Search for the next directory element, assuming
	; a previous call on search which sets searcha and
	; searchl

	IF MPM
	LD	HL,USER0PASS
	XOR	A
	CP	(HL)
	LD	(HL),A
	CALL	NZ,SWAP
	ELSE
	XOR	A
	LD	(USER0PASS),A
	ENDIF

	CALL	SEARCH$HASH
	JP	NZ,SEARCH$FIN
	LD	C,FALSE
	CALL	READ$DIR	; Read next dir element
	CALL	END$OF$DIR
	JP	Z,SEARCH$FIN
	; not end of directory, scan for match
	LD	HL,(SEARCHA)
	EX	DE,HL		; de=beginning of user fcb
	LD	A,(DE)		; first character
	CP	EMPTY		; Keep scanning if empty
	JP	Z,SEARCHNEXT
	; not empty, may be end of logical directory
	PUSH	DE		; Save search address
	CALL	COMPCDR		; past logical end?
	POP	DE		; Recall address
	JP	NC,SEARCH$FIN	; artificial stop
SEARCHNEXT:
	CALL	GETDPTRA	; hl = buffa+dptr
	LD	A,(SEARCHL)
	LD	C,A		; length of search to c
	LD	B,0		; b counts up, c counts down

	LD	A,(HL)
	CP	EMPTY
	CALL	Z,SAVE$DCNT$POS1

	IF BANKED
	XOR	A
	LD	(SAVE$XFCB),A
	LD	A,(HL)
	AND	11101111B
	CP	(HL)
	JP	Z,SEARCHLOOP
	EX	DE,HL
	CP	(HL)
	EX	DE,HL
	JP	NZ,SEARCHLOOP
	LD	A,(FIND$XFCB)
	OR	A
	JP	Z,SEARCHN
	LD	(SAVE$XFCB),A
	JP	SEARCHOK
	ENDIF

SEARCHLOOP:
	LD	A,C
	OR	A
	JP	Z,ENDSEARCH
	LD	A,(DE)
	CP	'?'
	JP	Z,SEARCHOK	; ? in user fcb
	; Scan next character if not ubytes
	LD	A,B
	CP	UBYTES
	JP	Z,SEARCHOK
	; not the ubytes field, extent field?
	CP	EXTNUM		; may be extent field
	JP	Z,SEARCHEXT	; Skip to search extent
	CP	MODNUM
	LD	A,(DE)
	CALL	Z,SEARCHMOD
	SUB	(HL)
	AND	7FH		; Mask-out flags/extent modulus
	JP	NZ,SEARCHNM	; Skip if not matched
	JP	SEARCHOK	; matched character
SEARCHEXT:
	LD	A,(DE)
	; Attempt an extent # match
	PUSH	BC		; Save counters

	IF MPM
	PUSH	HL
	LD	HL,(SDCNT)
	INC	H
	JP	NZ,DONT$SAVE
	LD	HL,(DCNT)
	LD	(SDCNT),HL
	LD	HL,(DBLK)
	LD	(SDBLK),HL
DONT$SAVE:
	POP	HL
	ENDIF

	LD	C,(HL)		; directory character to c
	CALL	COMPEXT		; Compare user/dir char

	LD	B,A
	LD	A,(USER0PASS)
	INC	A
	JP	Z,SAVE$DCNT$POS2
	; Disable search of user 0 if any fcb
	; is found under the current user #
	XOR	A
	LD	(SEARCH$USER0),A
	LD	A,B

	POP	BC		; Recall counters
	OR	A		; Set flag
	JP	NZ,SEARCHN	; Skip if no match
SEARCHOK:
	; current character matches
	INC	DE
	INC	HL
	INC	B
	DEC	C
	JP	SEARCHLOOP
ENDSEARCH:
	; entire name matches, return dir position

	IF BANKED
	LD	A,(SAVE$XFCB)
	INC	A
	JP	NZ,ENDSEARCH1
	LD	A,(XDCNT+1)
	CP	0FEH
	CALL	Z,SAVE$DCNT$POS0
	JP	SEARCHN
ENDSEARCH1:
	ENDIF

	XOR	A
	LD	(DIRLOC),A	; dirloc = 0
	LD	(LRET),A	; lret = 0
	; successful search -
	; return with zero flag reset
	LD	B,A
	INC	B
	RET
SEARCHMOD:
	AND	3FH
	RET			; Mask off high 2 bits
SEARCH$FIN:
	; end of directory, or empty name

	CALL	SAVE$DCNT$POS1

	; Set dcnt = 0ffffh
	CALL	SETENDDIR	; may be artifical end
LRET$EQ$FF:
	; unsuccessful search -
	; return with zero flag set
	; lret,low(aret) = 0ffh
	LD	A,255
	LD	B,A
	INC	B
	JP	STA$RET

SEARCHNM: ; search no match routine
	LD	A,B
	OR	A
	JP	NZ,SEARCHN	; fcb(0)?
	LD	A,(HL)
	OR	A
	JP	NZ,SEARCHN	; dir fcb(0)=0?
	LD	A,(SEARCH$USER0)
	OR	A
	JP	Z,SEARCHN
	LD	(USER0PASS),A

	IF MPM
	CALL	SWAP
	ENDIF

	JP	SEARCHOK

	IF MPM

SWAP:	; Swap dcnt,sdblk with sdcnt0,sdblk0
	PUSH	HL
	PUSH	DE
	PUSH	BC
	LD	DE,SDCNT
	LD	HL,SDCNT0
	LD	B,4
SWAP1:
	LD	A,(DE)
	LD	C,A
	LD	A,(HL)
	LD	(DE),A
	LD	(HL),C
	INC	HL
	INC	DE
	DEC	B
	JP	NZ,SWAP1
	POP	BC
	POP	DE
	POP	HL!
	RET
	ENDIF

SAVE$DCNT$POS2:
	; Save directory position of matching fcb
	; under user 0 with matching extent # & modnum = 0
	; a = 0 on entry
	OR	B
	POP	BC
	LD	BC,SEARCHN
	PUSH	BC
	RET	NZ
	INC	HL
	INC	HL
	LD	A,(HL)
	OR	A
	RET	NZ
	; Call if user0pass = 0ffh &
	;	  dir fcb(extnum) = fcb(extnum)
	;	  dir fcb(modnum) = 0
SAVE$DCNT$POS0:
	CALL	SAVE$DCNT$POS	; Return to searchn
SAVE$DCNT$POS1:
	; Save directory position of first empty fcb
	; or the end of the directory

	PUSH	HL
	LD	HL,(XDCNT)
	INC	H
	JP	NZ,SAVE$DCNT$POS$RET; Return if h ~= 0ffh


SAVE$DCNT$POS:
	LD	HL,(DCNT)
	LD	(XDCNT),HL

	IF MPM
	LD	HL,(DBLK)
	LD	(XDBLK),HL
	ENDIF

SAVE$DCNT$POS$RET:
	POP	HL
	RET

	IF BANKED

INIT$XFCB$SEARCH:
	LD	A,0FFH
INIT$XFCB$SEARCH1:
	LD	(FIND$XFCB),A
	LD	A,0FEH
	LD	(XDCNT+1),A
	RET

DOES$XFCB$EXIST:
	LD	A,(XDCNT+1)
	CP	0FEH
	RET	Z
	CALL	SET$DCNT$DBLK
	XOR	A
	CALL	INIT$XFCB$SEARCH1
	LD	HL,(SEARCHA)
	LD	A,(HL)
	OR	10H
	LD	(HL),A
	LD	C,EXTNUM
	CALL	SEARCHI1
	JP	SEARCHN

XDCNT$EQ$DCNT:
	LD	HL,(DCNT)
	LD	(XDCNT),HL
	RET

RESTORE$DIR$FCB:
	CALL	SET$DCNT$DBLK
	LD	C,NAMLEN
	CALL	SEARCHI
	JP	SEARCHN
	ENDIF

DELETE:
	; Delete the currently addressed file
	CALL	GET$ATTS

	IF BANKED
	LD	(ATTRIBUTES),A
	; Make search return matching fcbs and xfcbs
DELETEX:
	LD	A,0FEH
	CALL	INIT$XFCB$SEARCH1
	ELSE
	; Return with aret = 0 for XFCB only delete
	; in non-banked systems
	RLA
	RET	C
	ENDIF

; Delete pass 1 - check r/o attributes and xfcb passwords

	CALL	SEARCH$EXTNUM
	RET	Z

DELETE00:
	JP	Z,DELETE1

	IF BANKED
	; Is addressed dir fcb an xfcb?
	CALL	GETDPTRA
	LD	A,(HL)
	AND	10H
	JP	NZ,DELETE01	; yes

	IF MPM
	CALL	TST$OLIST	; Verify fcb not open by someone else
	ENDIF

	; Check r/o attribute if this is not an
	; xfcb only delete operation.
	LD	A,(ATTRIBUTES)
	RLA
	CALL	NC,CHECK$RODIR
	ELSE
	CALL	CHECK$RODIR
	ENDIF

	IF BANKED
	; Are xfcb passwords enabled?
	CALL	GET$DIR$MODE
	RLA
	JP	C,DELETE02	; no
	ENDIF

	; Is this a wild card delete operation?
	LD	HL,(INFO)
	CALL	CHK$WILD
	JP	Z,DELETE02	; yes
	; Not wild & passwords inactive
	; Skip to pass 2
	JP	DELETE11

	IF BANKED

DELETE01:
	; Check xfcb password if passwords enabled
	CALL	GET$DIR$MODE
	RLA
	JP	NC,DELETE02
	CALL	CHK$XFCB$PASSWORD
	JP	Z,DELETE02
	CALL	CHK$PW$ERROR
	JP	DELETEX
	ENDIF

DELETE02:
	CALL	SEARCHN
	JP	DELETE00

; Delete pass 2 - delete all matching fcbs and/or xfcbs.

DELETE1:
	CALL	SEARCH$EXTNUM

DELETE10:
	JP	Z,COPY$DIRLOC
DELETE11:
	CALL	GETDPTRA

	IF BANKED
	; Is addressed dir fcb an xfcb?
	LD	A,(HL)
	AND	10H
	JP	NZ,DELETE12	; yes
	IF MPM
	PUSH	HL
	CALL	CHK$OLIST	; Delete olist item if present
	POP	HL
	ENDIF
	; Is this delete operation xfcb only?
	LD	A,(ATTRIBUTES)
	AND	80H
	JP	NZ,DELETE13	; yes
	ENDIF

DELETE12:
	; Delete dir fcb or xfcb
	; if fcb free all alocated blocks.

	LD	(HL),EMPTY

	IF BANKED

DELETE13:
	PUSH	AF		; Z flag set => free FCB blocks
	; Zero password mode byte in sfcb if sfcb exists
	; Does sfcb exist?
	CALL	GETDTBA$8
	OR	A
	JP	NZ,$+4		; no
	; Zero mode byte
	LD	(HL),A
	ENDIF

	CALL	WRDIR
	LD	C,0

	IF BANKED
	POP	AF
	CALL	Z,SCANDM$AB
	ELSE
	CALL	SCANDM$AB
	ENDIF

	CALL	FIX$HASH
	CALL	SEARCHN
	JP	DELETE10

GET$BLOCK:
	; Given allocation vector position bc, find the zero bit
	; closest to this position by searching left and right.
	; if found, set the bit to one and return the bit position
	; in hl.  if not found (i.e., we pass 0 on the left, or
	; maxall on the right), return 0000 in hl
	LD	D,B
	LD	E,C		; copy of starting position to de
RIGHTTST:
	LD	HL,(MAXALL)	; value of maximum allocation#
	LD	A,E
	SUB	L
	LD	A,D
	SBC	A,H		; right=maxall?
	JP	NC,RETBLOCK0	; return block 0000 if so
	INC	DE
	PUSH	BC
	PUSH	DE		; left, right pushed
	LD	B,D
	LD	C,E		; ready right for call
	CALL	GETALLOCBIT
	RRA
	JP	NC,RETBLOCK	; Return block number if zero
	POP	DE
	POP	BC		; Restore left and right pointers
LEFTTST:
	LD	A,C
	OR	B
	JP	Z,RIGHTTST	; Skip if left=0000
	; left not at position zero, bit zero?
	DEC	BC
	PUSH	DE
	PUSH	BC		; left,right pushed
	CALL	GETALLOCBIT
	RRA
	JP	NC,RETBLOCK	; return block number if zero
	; bit is one, so try the right
	POP	BC
	POP	DE		; left, right restored
	JP	RIGHTTST
RETBLOCK:
	RLA
	INC	A		; bit back into position and set to 1
	; d contains the number of shifts required to reposition
	CALL	ROTR		; move bit back to position and store
	POP	HL
	POP	DE		; hl returned value, de discarded
	RET
RETBLOCK0:
	; cannot find an available bit, return 0000
	LD	A,C
	OR	B
	JP	NZ,LEFTTST	; also at beginning
	LD	HL,0000H
	RET

COPY$DIR:
	; Copy fcb information starting at c for e bytes
	; into the currently addressed directory entry
	LD	D,80H
COPY$DIR0:
	CALL	COPY$DIR2
	INC	C
COPY$DIR1:
	DEC	C
	JP	Z,SEEK$COPY
	LD	A,(HL)
	AND	B
	PUSH	BC
	LD	B,A
	LD	A,(DE)
	AND	7FH
	OR	B
	LD	(HL),A
	POP	BC
	INC	HL
	INC	DE
	JP	COPY$DIR1
COPY$DIR2:
	PUSH	DE		; Save length for later
	LD	B,0		; double index to bc
	LD	HL,(INFO)	; hl = source for data
	ADD	HL,BC
	INC	HL
	LD	A,(HL)
	SUB	'$'
	CALL	Z,SET$SUBMIT$FLAG
	DEC	HL
	EX	DE,HL		; de=.fcb(c), source for copy
	CALL	GETDPTRA	; hl=.buff(dptr), destination
	POP	BC		; de=source, hl=dest, c=length
	RET

SET$SUBMIT$FLAG:
	LD	DE,CCP$FLGS
	LD	A,(DE)
	OR	1
	LD	(DE),A
	RET

CHECK$WILD:
	; Check for ? in file name or type
	LD	HL,(INFO)
CHECK$WILD0: ; entry point used by rename
	CALL	CHK$WILD
	RET	NZ
	LD	A,9
	JP	SET$ARET

CHK$WILD:
	LD	C,11
CHK$WILD1:
	INC	HL
	LD	A,3FH
	SUB	(HL)
	AND	7FH
	RET	Z
	DEC	C
	JP	NZ,CHK$WILD1
	OR	A
	RET

COPY$USER$NO:
	LD	HL,(INFO)
	LD	A,(HL)
	LD	BC,DSKMAP
	ADD	HL,BC
	LD	(HL),A
	RET

RENAME:
	; Rename the file described by the first half of
	; the currently addressed file control block. The
	; new name is contained in the last half of the
	; currently addressed file control block.  The file
	; name and type are changed, but the reel number
	; is ignored.  The user number is identical.

	; Verify that the new file name does not exist.
	; Also verify that no wild chars exist in
	; either filename.

	IF MPM
	CALL	GETATTS
	LD	(ATTRIBUTES),A
	ENDIF

	; Verify that no wild chars exist in 1st filename.
	CALL	CHECK$WILD

	IF BANKED
	; Check password of file to be renamed.
	CALL	CHK$PASSWORD
	CALL	NZ,CHK$PW$ERROR
	; Setup search to scan for xfcbs.
	CALL	INIT$XFCB$SEARCH
	ENDIF

	; Copy user number to 2nd filename
	CALL	COPY$USER$NO
	LD	(SEARCHA),HL

	; Verify no wild chars exist in 2nd filename
	CALL	CHECK$WILD0

	; Verify new filename does not already exist
	LD	C,EXTNUM
	LD	HL,(SEARCHA)
	CALL	SEARCHI1
	CALL	SEARCH1
	JP	NZ,FILE$EXISTS	; New filename exists

	IF BANKED
	; If an xfcb exists for the new filename, delete it.
	CALL	DOES$XFCB$EXIST
	CALL	NZ,DELETE11
	ENDIF

	CALL	COPY$USER$NO

	IF BANKED
	CALL	INIT$XFCB$SEARCH
	ENDIF

	; Search up to the extent field
	CALL	SEARCH$EXTNUM
	RET	Z
	CALL	CHECK$RODIR	; may be r/o file

	IF MPM
	CALL	CHK$OLIST
	ENDIF

	; Copy position 0
RENAME0:
	; not end of directory, rename next element
	LD	C,DSKMAP
	LD	E,EXTNUM
	CALL	COPY$DIR
	; element renamed, move to next

	CALL	FIX$HASH
	CALL	SEARCHN
	JP	NZ,RENAME0
RENAME1:

	IF BANKED
	CALL	DOES$XFCB$EXIST
	JP	Z,COPY$DIRLOC
	CALL	COPY$USER$NO
	JP	RENAME0
	ELSE
	JP	COPY$DIRLOC
	ENDIF

INDICATORS:
	; Set file indicators for current fcb
	CALL	GET$ATTS	; Clear f5' through f8'
	LD	(ATTRIBUTES),A

	IF BANKED
	CALL	CHK$PASSWORD
	CALL	NZ,CHK$PW$ERROR
	ENDIF

	CALL	SEARCH$EXTNUM	; through file type
	RET	Z

	IF MPM
	CALL	CHK$OLIST
	ENDIF

INDIC0:
	; not end of directory, continue to change
	LD	C,0
	LD	E,EXTNUM	; Copy name
	CALL	COPY$DIR2
	CALL	MOVE
	LD	A,(ATTRIBUTES)
	AND	40H
	JP	Z,INDIC1

	; If interface att f6' set, dir fcb(s1) = fcb(cr)

	PUSH	HL
	CALL	GETFCBA
	LD	A,(HL)
	POP	HL
	INC	HL
	LD	(HL),A
INDIC1:
	CALL	SEEK$COPY
	CALL	SEARCHN
	JP	Z,COPY$DIRLOC
	JP	INDIC0

OPEN:
	; Search for the directory entry, copy to fcb
;;;	call search$namlen	;[JCE] DRI Patch 13
	CALL	PATCH$1E3E
OPEN1:
	RET	Z		; Return with lret=255 if end
	; not end of directory, copy fcb information
OPEN$COPY:
	CALL	SETFWF
	LD	E,A
	PUSH	HL
	DEC	HL
	DEC	HL
	LD	D,(HL)
	PUSH	DE		; Save extent# & module# with fcb write flag set
	CALL	GETDPTRA
	EX	DE,HL		; hl = .buff(dptr)
	LD	HL,(INFO)	; hl=.fcb(0)
	LD	C,NXTREC	; length of move operation
	CALL	MOVE		; from .buff(dptr) to .fcb(0)
	; Note that entire fcb is copied, including indicators
	CALL	GET$DIR$EXT
	LD	C,A
	; Restore module # and extent #
	POP	DE
	POP	HL
	LD	(HL),E
	DEC	HL
	DEC	HL
	LD	(HL),D
	; hl = .user extent#, c = dir extent#
	; above move set fcb(reccnt) to dir(reccnt)
	; if fcb ext < dir ext then fcb(reccnt) = fcb(reccnt) | 128
	; if fcb ext = dir ext then fcb(reccnt) = fcb(reccnt)
	; if fcb ext > dir ext then fcb(reccnt) = 0

SET$RC:	; hl=.fcb(ext), c=dirext
	LD	B,0
	EX	DE,HL
	LD	HL,[RECCNT-EXTNUM]
	ADD	HL,DE
	; Is fcb ext = dirext?
	LD	A,(DE)
	SUB	C
	JP	Z,SET$RC2	; yes
	; Is fcb ext > dirext?
	LD	A,B
	JP	NC,SET$RC1	; yes - fcb(rc) = 0
	; fcb ext  < dirext
	; fcb(rc) = 128 | fcb(rc)
	LD	A,128
	OR	(HL)
SET$RC1:
	LD	(HL),A
	RET
SET$RC2:
	; fcb ext = dirext
	LD	A,(HL)
	OR	A
	RET	NZ		; ret if fcb(rc) ~= 0
SET$RC3:
	LD	(HL),0		; required by function 99
	LD	A,(DMINX)
	OR	A
	RET	Z		; ret if no blks in fcb
	LD	(HL),128
	RET			; fcb(rc) = 128

MERGEZERO:
	; hl = .fcb1(i), de = .fcb2(i),
	; if fcb1(i) = 0 then fcb1(i) := fcb2(i)
	LD	A,(HL)
	INC	HL
	OR	(HL)
	DEC	HL
	RET	NZ		; return if = 0000
	LD	A,(DE)
	LD	(HL),A
	INC	DE
	INC	HL		; low byte copied
	LD	A,(DE)
	LD	(HL),A
	DEC	DE
	DEC	HL		; back to input form
	RET

RESTORE$RC:
	; hl = .fcb(extnum)
	; if fcb(rc) > 80h then fcb(rc) = fcb(rc) & 7fh
	PUSH	HL
	LD	DE,[RECCNT-EXTNUM]
	ADD	HL,DE
	LD	A,(HL)
	CP	81H
	JP	C,RESTORE$RC1
	AND	7FH
	LD	(HL),A
RESTORE$RC1:
	POP	HL
	RET

CLOSE:
	; Locate the directory element and re-write it
	XOR	A
	LD	(LRET),A

	IF MPM
	LD	(DONT$CLOSE),A
	ENDIF

	CALL	NOWRITE
	RET	NZ		; Skip close if r/o disk
	; Check file write flag - 0 indicates written
	CALL	GETMODNUM	; fcb(modnum) in a
	AND	FWFMSK
	RET	NZ		; Return if bit remains set
CLOSE1:
	CALL	CHK$INV$FCB
	JP	Z,MERGERR

	IF MPM
	CALL	SET$FCB$CKS$FLAG
	ENDIF

;;;	call get$dir$ext
	CALL	PATCH$1DFD	;[JCE] DRI patch 7

	LD	C,A
	LD	B,(HL)
	PUSH	BC
	; b = original extent, c = directory extent
	; Set fcb(ex) to directory extent
	LD	(HL),C
	; Recompute fcb(rc)
	CALL	RESTORE$RC
	; Call set$rc if fcb ext > dir ext
	LD	A,C
	CP	B
	CALL	C,SET$RC
	CALL	CLOSE$FCB
	; Restore original extent & reset fcb(rc)
	CALL	GETEXTA
	POP	BC
	LD	C,(HL)
	LD	(HL),B
	JP	SET$RC		; Reset fcb(rc)

CLOSE$FCB:
	; Locate file
	CALL	SEARCH$NAMLEN
	RET	Z		; Return if not found
	; Merge the disk map at info with that at buff(dptr)
	LD	BC,DSKMAP
	CALL	GET$FCB$ADDS
	LD	C,[FCBLEN-DSKMAP]; length of single byte dm
MERGE0:
	LD	A,(SINGLE)
	OR	A
	JP	Z,MERGED	; Skip to double
	; This is a single byte map
	; if fcb(i) = 0 then fcb(i) = buff(i)
	; if buff(i) = 0 then buff(i) = fcb(i)
	; if fcb(i) <> buff(i) then error
	LD	A,(HL)
	OR	A
	LD	A,(DE)
	JP	NZ,FCBNZERO
	; fcb(i) = 0
	LD	(HL),A		; fcb(i) = buff(i)
FCBNZERO:
	OR	A
	JP	NZ,BUFFNZERO
	; buff(i) = 0
	LD	A,(HL)
	LD	(DE),A		; buff(i)=fcb(i)
BUFFNZERO:
	CP	(HL)
	JP	NZ,MERGERR	; fcb(i) = buff(i)?
	JP	DMSET		; if merge ok
MERGED:
	; This is a double byte merge operation
	CALL	MERGEZERO	; buff = fcb if buff 0000
	EX	DE,HL
	CALL	MERGEZERO
	EX	DE,HL		; fcb = buff if fcb 0000
	; They should be identical at this point
	LD	A,(DE)
	CP	(HL)
	JP	NZ,MERGERR	; low same?
	INC	DE
	INC	HL		; to high byte
	LD	A,(DE)
	CP	(HL)
	JP	NZ,MERGERR	; high same?
	; merge operation ok for this pair
	DEC	C		; extra count for double byte
DMSET:
	INC	DE
	INC	HL		; to next byte position
	DEC	C
	JP	NZ,MERGE0	; for more
	; end of disk map merge, check record count
	; de = .buff(dptr)+32, hl = .fcb(32)

	EX	DE,HL
	LD	BC,-[FCBLEN-EXTNUM]
	ADD	HL,BC
	PUSH	HL
	CALL	GET$DIR$EXT
	POP	DE

	; hl = .fcb(extnum), de = .buff(dptr+extnum)

	CALL	COMPARE$EXTENTS

	; b=1 -> fcb(ext) ~= dir ext = buff(ext)
	; b=2 -> fcb(ext) = dir ext ~= buff(ext)
	; b=3 -> fcb(ext) = dir ext = buff(ext)

	; fcb(ext), buff(ext) = dir ext
	LD	(HL),A
	LD	(DE),A
	PUSH	BC

	LD	BC,[RECCNT-EXTNUM]
	ADD	HL,BC
	EX	DE,HL
	ADD	HL,BC
	POP	BC

	; hl = .buff(rc) , de = .fcb(rc)

	DEC	B
	JP	Z,MRG$RC1	; fcb(rc) = buff(rc)

	DEC	B
	JP	Z,MRG$RC2	; buff(rc) = fcb(rc)

	LD	A,(DE)
	CP	(HL)
	JP	C,MRG$RC1	; Take larger rc
	OR	A
	JP	NZ,MRG$RC2
	CALL	SET$RC3

MRG$RC1:EX	DE,HL

MRG$RC2:LD	A,(DE)
	LD	(HL),A

	IF MPM
	LD	A,(DONT$CLOSE)
	OR	A
	RET	NZ
	ENDIF

	; Set t3' off indicating file update
	CALL	GETDPTRA
	LD	DE,11
	ADD	HL,DE
	LD	A,(HL)
	AND	7FH
	LD	(HL),A
	CALL	SETFWF
	LD	C,1
	CALL	SCANDM$B	; Set 2nd ALV vector
	JP	SEEK$COPY	; OK to "wrdir" here - 1.4 compat
	; ret
MERGERR:
	; elements did not merge correctly
	CALL	MAKE$FCB$INV
	JP	LRET$EQ$FF

COMPARE$EXTENTS:
	LD	B,1
	CP	(HL)
	RET	NZ
	INC	B
	EX	DE,HL
	CP	(HL)
	EX	DE,HL
	RET	NZ
	INC	B
	RET

SET$XDCNT:
	LD	HL,0FFFFH
	LD	(XDCNT),HL
	RET

SET$DCNT$DBLK:
	LD	HL,(XDCNT)
SET$DCNT$DBLK1:
	LD	A,11111100B
	AND	L
	LD	L,A
	DEC	HL
	LD	(DCNT),HL

	IF MPM
	LD	HL,(XDBLK)
	LD	(DBLK),HL
	ENDIF

	RET

	IF MPM

SDCNT$EQ$XDCNT:
	LD	HL,SDCNT
	LD	DE,XDCNT
	LD	C,4
	JP	MOVE
	ENDIF

MAKE:
	; Create a new file by creating a directory entry
	; then opening the file

;;;	lxi h,xdcnt	;[JCE] DRI Patch 13
	CALL	PATCH$1E31

	CALL	TEST$FFFF
	CALL	NZ,SET$DCNT$DBLK

	LD	HL,(INFO)
	PUSH	HL		; Save fcb address, Look for E5
	LD	HL,EFCB
	LD	(INFO),HL	; info = .empty
	LD	C,1

	CALL	SEARCHI
	CALL	SEARCHN

	; zero flag set if no space
	POP	HL		; Recall info address
	LD	(INFO),HL	; in case we return here
	RET	Z		; Return with error condition 255 if not found

	IF BANKED
	; Return early if making an xfcb
	LD	A,(MAKE$XFCB)
	OR	A
	RET	NZ
	ENDIF

	; Clear the remainder of the fcb
	; Clear s1 byte
	LD	DE,13
	ADD	HL,DE
	LD	(HL),D
	INC	HL
	; Clear and save file write flag of modnum
	LD	A,(HL)
	PUSH	AF
	PUSH	HL
	AND	3FH
	LD	(HL),A
	INC	HL
	LD	A,1
	LD	C,FCBLEN-NAMLEN	; number of bytes to fill
MAKE0:
	LD	(HL),D
	INC	HL
	DEC	C
	JP	NZ,MAKE0
	DEC	A
	LD	C,D
	CALL	Z,GETDTBA
	OR	A
	LD	C,10
	JP	Z,MAKE0
	CALL	SETCDR		; may have extended the directory
	; Now copy entry to the directory
	LD	C,0
	LD	DE,FCBLEN
	CALL	COPY$DIR0
	; and restore the file write flag
	POP	HL
	POP	AF
	LD	(HL),A
	; and set the fcb write flag to "1"
	CALL	FIX$HASH
	JP	SETFWF

OPEN$REEL:
	; Close the current extent, and open the next one
	; if possible.	rmf is true if in read mode

	IF BANKED
	CALL	RESET$COPY$CR$ONLY
	ENDIF

	CALL	GETEXTA
	LD	A,(HL)
	LD	C,A
	INC	C
	CALL	COMPEXT
	JP	Z,OPEN$REEL3
	PUSH	HL
	PUSH	BC
	CALL	CLOSE
	POP	BC
	POP	HL
	LD	A,(LRET)
	INC	A
	RET	Z
	LD	A,MAXEXT
	AND	C
	LD	(HL),A		; Incr extent field
	; Advance to module & save
	INC	HL
	INC	HL
	LD	A,(HL)
	LD	(SAVE$MOD),A
	JP	NZ,OPEN$REEL0	; Jump if in same module

OPEN$MOD:
	; Extent number overflow, go to next module
	INC	(HL)		; fcb(modnum)=++1
	; Module number incremented, check for overflow

	LD	A,(HL)
	AND	3FH		; Mask high order bits

	JP	Z,OPEN$R$ERR	; cannot overflow to zero

	; otherwise, ok to continue with new module
OPEN$REEL0:
	CALL	SET$XDCNT	; Reset xdcnt for make

	IF MPM
	CALL	SET$SDCNT
	ENDIF

;;;		call search$namlen	;[JCE] DRI Patch 13
	CALL	PATCH$1E3E	;Next extent found?

	JP	NZ,OPEN$REEL1
	; end of file encountered
	LD	A,(RMF)
	INC	A		; 0ffh becomes 00 if read
	JP	Z,OPEN$R$ERR	; sets lret = 1
	; Try to extend the current file
	CALL	MAKE
	; cannot be end of directory
	JP	Z,OPEN$R$ERR	; with lret = 1

	IF MPM
	CALL	FIX$OLIST$ITEM
	CALL	SET$FCB$CKS$FLAG
	ENDIF

	JP	OPEN$REEL2
OPEN$REEL1:
	; not end of file, open
	CALL	OPEN$COPY

	IF MPM
	CALL	SET$FCB$CKS$FLAG
	ENDIF

OPEN$REEL2:

	IF NOT MPM
	CALL	SET$LSN
	ENDIF

	CALL	GETFCB		; Set parameters
	XOR	A
	LD	(VRECORD),A
	JP	STA$RET		; lret = 0
	; ret ; with lret = 0
OPEN$R$ERR:
	; Restore module and extent
	CALL	GETMODNUM
	LD	A,(SAVE$MOD)
	LD	(HL),A
	DEC	HL
	DEC	HL
	LD	A,(HL)
	DEC	A
	AND	1FH
	LD	(HL),A
	JP	SETLRET1	; lret = 1

OPEN$REEL3:
	INC	(HL)		; fcb(ex) = fcb(ex) + 1
	CALL	GET$DIR$EXT
	LD	C,A
	; Is new extent beyond dir$ext?
	CP	(HL)
	JP	NC,OPEN$REEL4	; no
	DEC	(HL)		; fcb(ex) = fcb(ex) - 1
	; Is this a read fx?
	LD	A,(RMF)
	INC	A
	JP	Z,SETLRET1	; yes - Don't advance ext
	INC	(HL)		; fcb(ex) = fcb(ex) + 1
OPEN$REEL4:
	CALL	RESTORE$RC
	CALL	SET$RC
	JP	OPEN$REEL2

SEQDISKREAD:
DISKREAD: ; (may enter from seqdiskread)
	CALL	TST$INV$FCB	; Check for valid fcb
	LD	A,TRUE
	LD	(RMF),A		; read mode flag = true (open$reel)

	IF MPM
	LD	(DONT$CLOSE),A
	ENDIF

	; Read the next record from the current fcb
	CALL	GETFCB		; sets parameters for the read
DISKREAD0:
	LD	A,(VRECORD)
	LD	HL,RCOUNT
	CP	(HL)		; vrecord-rcount
	; Skip if rcount > vrecord
	JP	C,RECORDOK

	IF MPM
	CALL	TEST$DISK$FCB
	JP	NZ,DISKREAD0
	LD	A,(VRECORD)
	ENDIF

	; not enough records in the extent
	; record count must be 128 to continue
	CP	128		; vrecord = 128?
	JP	NZ,SETLRET1	; Skip if vrecord<>128
	CALL	OPEN$REEL	; Go to next extent if so
	; Check for open ok
	LD	A,(LRET)
	OR	A
	JP	NZ,SETLRET1	; Stop at eof
RECORDOK:
	; Arrive with fcb addressing a record to read

	IF BANKED
	CALL	SET$COPY$CR$ONLY
	ENDIF

	CALL	INDEX		; Z flag set if arecord = 0

	IF MPM
	JP	NZ,RECORDOK1
	CALL	TEST$DISK$FCB
	JP	NZ,DISKREAD0
	ENDIF

	JP	Z,SETLRET1	; Reading unwritten data
RECORDOK1:
	; Record has been allocated, read it
	CALL	ATRAN		; arecord now a disk address
	CALL	CHECK$NPRS
	JP	C,SETFCB
	JP	NZ,READ$DEBLOCK

	CALL	SETDATA
	CALL	SEEK		; to proper track,sector

	IF BANKED
	LD	A,1
	CALL	SETBNKF
	ENDIF

	CALL	RDBUFF		; to dma address
	JP	SETFCB		; Replace parameter

READ$DEBLOCK:
	LD	HL,0
	LD	(LAST$BLOCK),HL
	LD	A,1
	CALL	DEBLOCK$DTA
	JP	SETFCB

CHECK$NPRS:
	;
	; on exit,  c flg	   -> no i/o operation
	;	    z flg & ~c flg -> direct(physical) i/o operation
	;	   ~z flg & ~c flg -> indirect(deblock) i/o operation
	;
	;	   Dir$cnt contains the number of 128 byte records
	;	   to transfer directly.  This routine sets dir$cnt
	;	   when initiating a sequence of direct physical
	;	   i/o operations.  Dir$cnt is decremented each
	;	   time check$nprs is called during such a sequence.
	;
	; Is direct transfer operation in progress?
	LD	A,(BLK$OFF)
	LD	B,A
	LD	A,(PHYMSK)
	LD	C,A
	AND	B
	PUSH	AF
	LD	A,(DIR$CNT)
	CP	2
	JP	C,CHECK$NPR1	; no
	; yes - Decrement direct record count
	DEC	A
	LD	(DIR$CNT),A
	; Are we at a new physical record?
	POP	AF
	SCF
	RET	NZ		; no - ret with c flg set
	; Perform physical i/o operation
	XOR	A
	RET			; Return with z flag set and c flag reset
CHECK$NPR1:
	; Are we in mid-physical record?
	POP	AF
	JP	Z,CHECK$NPR11	; no
CHECK$NPR1A:
	; Is phymsk = 0?
	LD	A,C
	OR	A
	RET	Z		; yes - Don't deblock
CHECK$NPR1B:
	; Deblocking required
	OR	1
	RET			; ret with z flg reset and c flg reset
CHECK$NPR11:
	LD	A,C
	CPL
	LD	D,A		; d = ~phymsk
	LD	HL,VRECORD
	; Is mult$num < 2?
	LD	A,(MULT$NUM)
	CP	2
	JP	C,CHECK$NPR1A	; yes
	ADD	A,(HL)
	CP	80H
	JP	C,CHECK$NPR2
	LD	A,80H
CHECK$NPR2: ; a = min(vrecord + mult$num),80h) = x
	PUSH	BC		; Save low(arecord) & blkmsk, phymsk
	LD	B,(HL)
	LD	(HL),7FH	; vrecord = 7f
	PUSH	BC		; Save vrecord
	PUSH	HL		; Save .vrecord
	PUSH	AF		; Save x
	LD	A,(BLKMSK)
	LD	E,A
	INC	E
	CPL
	AND	B
	LD	B,A
	; b = vrecord & ~blkmsk
	; e = blkmsk + 1
	POP	HL		; h = x
	; Is this a read function?
	LD	A,(RMF)
	OR	A
	JP	Z,CHECK$NPR21	; no
	; Is rcount & ~phymsk < x?
	LD	A,(RCOUNT)
	AND	D
	CP	H
	JP	C,CHECK$NPR23	; yes
CHECK$NPR21:
	LD	A,H		; a = x
CHECK$NPR23:
	SUB	B		; a = a - vrecord & ~blkmsk
	LD	C,A		; c = max # of records from beginning of curr blk
	; Is c < blkmsk+1?
	CP	E
	JP	C,CHECK$NPR8	; yes

	IF BANKED
	PUSH	BC		; c = max # of records
	; Compute maximum disk map position
	CALL	DM$POSITION
	LD	B,A		; b = index of last block in extent
	; Does the last block # = the current block #?
	LD	A,(DMINX)
	CP	B
	LD	E,A
	JP	Z,CHECK$NPR5	; yes
	; Compute # of blocks in sequence
	LD	C,A
	PUSH	BC
	LD	B,0
	CALL	GETDM		; hl = current block #
CHECK$NPR4:
	; Get next block #
	PUSH	HL
	INC	BC
	CALL	GETDM
	POP	DE
	INC	DE
	; Does next block # = previous block # + 1?
	LD	A,D
	SUB	H
	LD	D,A
	LD	A,E
	SUB	L
	OR	D
	JP	Z,CHECK$NPR4	; yes
	; Is next block # = 0?
	LD	A,H
	OR	L
	JP	NZ,CHECK$NPR45	; no
	; Is this a read function?
	LD	A,(RMF)
	OR	A
	JP	NZ,CHECK$NPR45	; no
	; Is next block # > maxall?
	LD	HL,(MAXALL)
	LD	A,L
	SUB	E
	LD	A,H
	SBC	A,D
	JP	C,CHECK$NPR45	; yes
	; Is next block # allocated?
	PUSH	BC
	PUSH	DE
	LD	B,D
	LD	C,E
	CALL	GETALLOCBIT
	POP	HL
	POP	BC
	RRA
	JP	NC,CHECK$NPR4	; no - it will be later
CHECK$NPR45:
	DEC	C
	POP	DE
	; Is max dm position less than c?
	LD	A,D
	CP	C
	JP	C,CHECK$NPR5	; yes
	LD	A,C		; no
CHECK$NPR5: ; a = index of last block
	SUB	E
	LD	B,A
	INC	B		; b = # of consecutive blks
	LD	A,(BLKMSK)
	INC	A
	LD	C,A
CHECK$NPR6:
	DEC	B
	JP	Z,CHECK$NPR7
	ADD	A,C
	JP	CHECK$NPR6
CHECK$NPR7:
	POP	BC
	LD	B,C		; b = max # of records
	LD	C,A		; c = (# of consecutive blks)*(blkmsk+1)
	LD	A,(RMF)
	OR	A
	JP	Z,CHECK$NPR8
	LD	A,B
	CP	C
	JP	C,CHECK$NPR9
	ELSE
	LD	C,E		; multis-sector max = 1 block in non-banked systems
	ENDIF

CHECK$NPR8:
	LD	A,C
CHECK$NPR9:
	; Restore vrecord
	POP	HL
	POP	BC
	LD	(HL),B
	POP	BC
	; a = max # of consecutive records including current blk
	; b = low(arecord) & blkmsk
	; c = phymsk
	; Is mult$num > a - b
	LD	HL,MULT$NUM
	LD	D,(HL)
	SUB	B
	CP	D
	JP	NC,CHECK$NPR10
	LD	D,A		; yes - use smaller value to compute dir$cnt
CHECK$NPR10:
	; Does this operation involve at least 1 physical record?
	LD	A,C
	CPL
	AND	D
	LD	(DIR$CNT),A
	JP	Z,CHECK$NPR1B	; Deblocking required
	; Flush any pending buffers before doing multiple reads
	PUSH	AF
	LD	A,(RMF)
	OR	A
	JP	Z,CHECK$NPR10A
	CALL	FLUSHX
	CALL	SETDATA
CHECK$NPR10A:
	POP	AF
	LD	H,A		; Save # of 128 byte records
	; Does this operation involve more than 1 physical record?
	; Register h contains number of 128 byte records
	CALL	SHR$PHYSHF
	LD	A,H
	CP	1
	LD	C,A
	CALL	NZ,MULTIOF	; yes - Make bios call
	XOR	A
	RET			; Return with z flg set

	IF MPM

TEST$UNLOCKED:
	LD	A,(HIGH$EXT)
	AND	80H
	RET

TEST$DISK$FCB:
	CALL	TEST$UNLOCKED
	RET	Z
	LD	A,(DONT$CLOSE)
	OR	A
	RET	Z
	CALL	CLOSE1
TEST$DISK$FCB1:
	POP	DE
	LD	HL,LRET
	INC	(HL)
	LD	A,11
	JP	Z,STA$RET
	LD	(HL),0
	PUSH	DE
	CALL	GETRCNTA
	LD	A,(HL)
	LD	(RCOUNT),A	; Reset rcount
	XOR	A
	LD	(DONT$CLOSE),A
	INC	A
	RET
	ENDIF

RESET$FWF:
	CALL	GETMODNUM	; hl=.fcb(modnum), a=fcb(modnum)
	; Reset the file write flag to mark as written fcb
	AND	(NOT FWFMSK) AND 0FFH; bit reset
	LD	(HL),A		; fcb(modnum) = fcb(modnum) and 7fh
	RET

SET$FILEWF:
	CALL	GETMODNUM
	AND	01000000B
	PUSH	AF
	LD	A,(HL)
	OR	01000000B
	LD	(HL),A
	POP	AF
	RET

SEQDISKWRITE:
DISKWRITE: ; (may enter here from seqdiskwrite above)
	LD	A,FALSE
	LD	(RMF),A		; read mode flag
	; Write record to currently selected file

	CALL	CHECK$WRITE	; in case write protected

	IF BANKED
	LD	A,(XFCB$READ$ONLY)
	OR	A
	LD	A,3
	JP	NZ,SET$ARET
	ENDIF

	LD	A,(HIGH$EXT)

	IF MPM
	AND	0100$0000B
	ELSE
	OR	A
	ENDIF

	; Z flag reset if r/o mode
	LD	A,3
	JP	NZ,SET$ARET

	LD	HL,(INFO)	; hl = .fcb(0)
	CALL	CHECK$ROFILE	; may be a read-only file

	CALL	TST$INV$FCB	; Test for invalid fcb

	CALL	UPDATE$STAMP

	CALL	GETFCB		; to set local parameters
	LD	A,(VRECORD)
	CP	LSTREC+1	; vrecord-128
	JP	C,DISKWRITE0
	CALL	OPEN$REEL	; vrecord = 128, try to open next extent
	LD	A,(LRET)
	OR	A
	RET	NZ		; no available fcb
DISKWRITE0:

	IF MPM
	LD	A,0FFH
	LD	(DONT$CLOSE),A
DISKWRITE1:

	ENDIF

	; Can write the next record, so continue
	CALL	INDEX		; Z flag set if arecord = 0
	JP	Z,DISKWRITE2
	; Was the last write operation for the same block & drive?
	LD	HL,ADRIVE
	LD	DE,LASTDRIVE
	LD	C,3
	CALL	COMPARE
	JP	Z,DISKWRITE15	; yes
	; no - force preread in blocking/deblocking
	LD	A,0FFH
	LD	(LAST$OFF),A
DISKWRITE15:

	IF MPM
	; If file is unlocked, verify record is not locked
	; Record has to be allocated to be locked
	CALL	TEST$UNLOCKED
	JP	Z,NOT$UNLOCKED
	CALL	ATRAN
	LD	C,A
	LD	A,(MULTCNT)
	LD	B,A
	PUSH	BC
	CALL	TEST$LOCK
	POP	BC
	XOR	A
	LD	C,A
	PUSH	BC
	JP	DISKWR10
NOT$UNLOCKED:
	INC	A
	ENDIF

	LD	C,0		; Marked as normal write operation for wrbuff
	JP	DISKWR1
DISKWRITE2:

	IF MPM
	CALL	TEST$DISK$FCB
	JP	NZ,DISKWRITE1
	ENDIF

	IF BANKED
	CALL	RESET$COPY$CR$ONLY
	ENDIF

	; not allocated
	; The argument to getblock is the starting
	; position for the disk search, and should be
	; the last allocated block for this file, or
	; the value 0 if no space has been allocated
	CALL	DM$POSITION
	LD	(DMINX),A	; Save for later
	LD	BC,0000H	; May use block zero
	OR	A
	JP	Z,NOPBLOCK	; Skip if no previous block
	; Previous block exists at a
	LD	C,A
	DEC	BC		; Previous block # in bc
	CALL	GETDM		; Previous block # to hl
	LD	B,H
	LD	C,L		; bc=prev block#
NOPBLOCK:
	; bc = 0000, or previous block #
	CALL	GET$BLOCK	; block # to hl
	; Arrive here with block# or zero
	LD	A,L
	OR	H
	JP	NZ,BLOCKOK
	; Cannot find a block to allocate
	LD	A,2
	JP	STA$RET		; lret=2
BLOCKOK:

	IF MPM
	CALL	SET$FCB$CKS$FLAG
	ENDIF

	; allocated block number is in hl
	LD	(ARECORD),HL
	LD	(LAST$BLOCK),HL
	XOR	A
	LD	(LAST$OFF),A
	LD	A,(ADRIVE)
	LD	(LASTDRIVE),A
	EX	DE,HL		; block number to de
	LD	HL,(INFO)
	LD	BC,DSKMAP
	ADD	HL,BC		; hl=.fcb(dskmap)
	LD	A,(SINGLE)
	OR	A		; Set flags for single byte dm
	LD	A,(DMINX)	; Recall dm index
	JP	Z,ALLOCWD	; Skip if allocating word
	; Allocating a byte value
	CALL	ADDH
	LD	(HL),E		; single byte alloc
	JP	DISKWRU		; to continue
ALLOCWD:
	; Allocate a word value
	LD	C,A
	LD	B,0		; double(dminx)
	ADD	HL,BC
	ADD	HL,BC		; hl=.fcb(dminx*2)
	LD	(HL),E
	INC	HL
	LD	(HL),D		; double wd
DISKWRU:
	; disk write to previously unallocated block
	LD	C,2		; marked as unallocated write
DISKWR1:
	; Continue the write operation of no allocation error
	; c = 0 if normal write, 2 if to prev unalloc block
	PUSH	BC		; Save write flag
	CALL	ATRAN		; arecord set
DISKWR10:
	LD	A,(FX)
	CP	40
	JP	NZ,DISKWR11	; fx ~= wrt rndm zero fill
	LD	A,C
	DEC	A
	DEC	A
	JP	NZ,DISKWR11	; old allocation

	; write random zero fill + new block

	POP	BC
	PUSH	AF		; zero write flag
	LD	HL,(ARECORD)
	PUSH	HL
	LD	HL,PHYMSK
	LD	E,(HL)
	INC	E
	LD	D,A
	PUSH	DE
	LD	HL,(DIRBCBA)

	IF BANKED
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
FILL00:
	PUSH	HL
	CALL	GET$NEXT$BCBA
	POP	DE
	JP	NZ,FILL00
	EX	DE,HL
	ENDIF

	; Force prereads in blocking/deblocking
	; Discard BCB
	DEC	A
	LD	(LAST$OFF),A
	LD	(HL),A
	CALL	SETDIR1		; Set dma to BCB buffer
	; Zero out BCB buffer
	POP	DE
	PUSH	DE
	XOR	A
FILL0:
	LD	(HL),A
	INC	HL
	INC	D
	JP	P,FILL0
	LD	D,A
	DEC	E
	JP	NZ,FILL0
	; Write 1st physical record of block
	LD	HL,(ARECORD1)
	LD	C,2
FILL1:
	LD	(ARECORD),HL
	PUSH	BC
	CALL	DISCARD$DATA$BCB
	CALL	SEEK

	IF BANKED
	XOR	A
	CALL	SETBNKF
	ENDIF

	POP	BC
	CALL	WRBUFF
	LD	HL,(ARECORD)
	POP	DE
	PUSH	DE
	; Continue writing until blkmsk & arecord = 0
	ADD	HL,DE
	LD	A,(BLKMSK)
	AND	L
	LD	C,0
	JP	NZ,FILL1
	; Restore arecord
	POP	HL
	POP	HL
	LD	(ARECORD),HL

	CALL	SETDATA		; Restore dma
DISKWR11:

	POP	DE
	LD	A,(VRECORD)
	LD	D,A		; Load and save vrecord
	PUSH	DE
	CALL	CHECK$NPRS

	JP	C,DONT$WRITE
	JP	Z,WRITE

	LD	A,2		; deblock write code
	CALL	DEBLOCK$DTA
	JP	DONT$WRITE
WRITE:
	CALL	SETDATA
	CALL	SEEK

	IF BANKED
	LD	A,1
	CALL	SETBNKF
	ENDIF

	; Discard matching BCB if write is direct
	CALL	DISCARD$DATA$BCB

	; Set write flag to zero if arecord & blkmsk ~= 0

	POP	BC
	PUSH	BC
	LD	A,(ARECORD)
	LD	HL,BLKMSK
	AND	(HL)
	JP	Z,WRITE0
	LD	C,0
WRITE0:
	CALL	WRBUFF

DONT$WRITE:
	POP	BC		; c = 2 if a new block was allocated, 0 if not
	; Increment record count if rcount<=vrecord
	LD	A,B
	LD	HL,RCOUNT
	CP	(HL)		; vrecord-rcount
	JP	C,DISKWR2
	; rcount <= vrecord
	LD	(HL),A
	INC	(HL)		; rcount = vrecord+1

	IF MPM
	CALL	TEST$UNLOCKED
	JP	Z,WRITE1

	; for unlocked files
	;   rcount = rcount & (~ blkmsk) + blkmsk + 1

	LD	A,(BLKMSK)
	LD	B,A
	INC	B
	CPL
	LD	C,A
	LD	A,(HL)
	DEC	A
	AND	C
	ADD	A,B
	LD	(HL),A
WRITE1:
	ENDIF

	LD	C,2		; Mark as record count incremented
DISKWR2:
	; a has vrecord, c=2 if new block or new record#
	DEC	C
	DEC	C
	JP	NZ,NOUPDATE
	CALL	RESET$FWF

	IF MPM
	CALL	TEST$UNLOCKED
	JP	Z,NOUPDATE
	LD	A,(RCOUNT)
	CALL	GETRCNTA
	LD	(HL),A
	CALL	CLOSE
	CALL	TEST$DISK$FCB1
	ENDIF

NOUPDATE:
	; Set file write flag if reset
	CALL	SET$FILEWF

	IF BANKED
	JP	NZ,DISKWRITE3
	; Reset fcb file write flag to ensure t3' gets
	; reset by the close function
	CALL	RESET$FWF
	CALL	RESET$COPY$CR$ONLY
	JP	SETFCB
DISKWRITE3:
	CALL	SET$COPY$CR$ONLY
	ELSE
	CALL	Z,RESET$FWF
	ENDIF
	JP	SETFCB		; Replace parameters
	; ret

RSEEK:
	; Random access seek operation, c=0ffh if read mode
	; fcb is assumed to address an active file control block
	; (1st block of FCB = 0ffffh if previous bad seek)
	PUSH	BC		; Save r/w flag
	LD	HL,(INFO)
	EX	DE,HL		; de will hold base of fcb
	LD	HL,RANREC
	ADD	HL,DE		; hl=.fcb(ranrec)
	LD	A,(HL)
	AND	7FH
	PUSH	AF		; record number
	LD	A,(HL)
	RLA			; cy=lsb of extent#
	INC	HL
	LD	A,(HL)
	RLA
	AND	11111B		; a=ext#
	LD	C,A		; c holds extent number, record stacked

	LD	A,(HL)
	AND	11110000B
	INC	HL
	OR	(HL)
	RRCA
	RRCA
	RRCA
	RRCA
	LD	B,A
	; b holds module #

	; Check high byte of ran rec <= 3
	LD	A,(HL)
	AND	11111100B
	POP	HL
	LD	L,6
	LD	A,H

	; Produce error 6, seek past physical eod
	JP	NZ,SEEKERR

	; otherwise, high byte = 0, a = sought record
	LD	HL,NXTREC
	ADD	HL,DE		; hl = .fcb(nxtrec)
	LD	(HL),A		; sought rec# stored away

	; Arrive here with b=mod#, c=ext#, de=.fcb, rec stored
	; the r/w flag is still stacked.  compare fcb values

	LD	A,(FX)
	CP	99
	JP	Z,RSEEK3
	; Check module # first
	PUSH	DE
	CALL	CHK$INV$FCB
	POP	DE
	JP	Z,RANCLOSE
	LD	HL,MODNUM
	ADD	HL,DE
	LD	A,B		; b=seek mod#
	SUB	(HL)
	AND	3FH
	JP	NZ,RANCLOSE	; same?
	; Module matches, check extent
	LD	HL,EXTNUM
	ADD	HL,DE
	LD	A,(HL)
	CP	C
	JP	Z,SEEKOK2	; extents equal
	CALL	COMPEXT
	JP	NZ,RANCLOSE
	; Extent is in same directory fcb
	PUSH	BC
	CALL	GET$DIR$EXT
	POP	BC
	CP	C
	JP	NC,RSEEK2	; jmp if dir$ext > ext
	POP	DE
	PUSH	DE
	INC	E
	JP	NZ,RSEEK2	; jmp if write fx
	INC	E
	POP	DE
	JP	SETLRET1	; error - reading unwritten data
RSEEK2:
	LD	(HL),C		; fcb(ext) = c
	LD	C,A		; c = dir$ext
	; hl=.fcb(ext),c=dir ext
	CALL	RESTORE$RC
	CALL	SET$RC
	JP	SEEKOK1
RANCLOSE:
	PUSH	BC
	PUSH	DE		; Save seek mod#,ext#, .fcb
	CALL	CLOSE		; Current extent closed
	POP	DE
	POP	BC		; Recall parameters and fill
	LD	L,3		; Cannot close error #3
	LD	A,(LRET)
	INC	A
	JP	Z,SEEKERR
RSEEK3:
	CALL	SET$XDCNT	; Reset xdcnt for make

	IF MPM
	CALL	SET$SDCNT
	ENDIF

	LD	HL,EXTNUM
	ADD	HL,DE
	PUSH	HL
	LD	D,(HL)
	LD	(HL),C		; fcb(extnum)=ext#
	INC	HL
	INC	HL
	LD	A,(HL)
	LD	E,A
	PUSH	DE
	AND	040H
	OR	B
	LD	(HL),A
	; fcb(modnum)=mod#
	CALL	OPEN		; Is the file present?
	LD	A,(LRET)
	INC	A
	JP	NZ,SEEKOK	; Open successful?
	; Cannot open the file, read mode?
	POP	DE
	POP	HL
	POP	BC		; r/w flag to c (=0ffh if read)
	PUSH	BC
	PUSH	HL
	PUSH	DE		; Restore stack
	LD	L,4		; Seek to unwritten extent #4
	INC	C		; becomes 00 if read operation
	JP	Z,BADSEEK	; Skip to error if read operation
	; Write operation, make new extent
	CALL	MAKE
	LD	L,5		; cannot create new extent #5
	JP	Z,BADSEEK	; no dir space

	IF MPM
	CALL	FIX$OLIST$ITEM
	ENDIF

	; file make operation successful
SEEKOK:
	POP	BC
	POP	BC		; Discard top 2 stacked items

	IF MPM
	CALL	SET$FCB$CKS$FLAG
	ELSE
	CALL	SET$LSN
	ENDIF

SEEKOK1:

	IF BANKED
	CALL	RESET$COPY$CR$ONLY
	ENDIF

SEEKOK2:
	POP	BC		; Discard r/w flag or .fcb(ext)
	XOR	A
	JP	STA$RET		; with zero set
BADSEEK:
	; Restore fcb(ext) & fcb(mod)
	POP	DE
	EX	(SP),HL		; Save error flag
	LD	(HL),D
	INC	HL
	INC	HL
	LD	(HL),E
	POP	HL		; Restore error flag
SEEKERR:

	IF BANKED
	CALL	RESET$COPY$CR$ONLY; Z flag set
	INC	A		; Reset Z flag
	ENDIF

	POP	BC		; Discard r/w flag
	LD	A,L
	JP	STA$RET		; lret=#, nonzero

RANDISKREAD:
	; Random disk read operation
	LD	C,TRUE		; marked as read operation
	CALL	RSEEK
	CALL	Z,DISKREAD	; if seek successful
	RET

RANDISKWRITE:
	; Random disk write operation
	LD	C,FALSE		; marked as write operation
	CALL	RSEEK
	CALL	Z,DISKWRITE	; if seek successful
	RET

COMPUTE$RR:
	; Compute random record position for getfilesize/setrandom
	EX	DE,HL
	ADD	HL,DE
	; de=.buf(dptr) or .fcb(0), hl = .f(nxtrec/reccnt)
	LD	C,(HL)
	LD	B,0		; bc = 0000 0000 ?rrr rrrr
	LD	HL,EXTNUM
	ADD	HL,DE
	LD	A,(HL)
	RRCA
	AND	80H		; a=e000 0000
	ADD	A,C
	LD	C,A
	LD	A,0
	ADC	A,B
	LD	B,A
	; bc = 0000 000? errrr rrrr
	LD	A,(HL)
	RRCA
	AND	0FH
	ADD	A,B
	LD	B,A
	; bc = 000? eeee errrr rrrr
	LD	HL,MODNUM
	ADD	HL,DE
	LD	A,(HL)		; a=xxmm mmmm
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A		; cy=m a=mmmm 0000

	OR	A
	ADD	A,B
	LD	B,A
	PUSH	AF		; Save carry
	LD	A,(HL)
	RRA
	RRA
	RRA
	RRA
	AND	00000011B	; a=0000 00mm
	LD	L,A
	POP	AF
	LD	A,0
	ADC	A,L		; Add carry
	RET

COMPARE$RR:
	LD	E,A		; Save cy
	LD	A,C
	SUB	(HL)
	LD	D,A
	INC	HL		; lst byte
	LD	A,B
	SBC	A,(HL)
	INC	HL		; middle byte
	PUSH	AF
	OR	D
	LD	D,A
	POP	AF
	LD	A,E
	SBC	A,(HL)		; carry if .fcb(ranrec) > directory
	RET

SET$RR:
	LD	(HL),E
	DEC	HL
	LD	(HL),B
	DEC	HL
	LD	(HL),C
	RET

GETFILESIZE:
	; Compute logical file size for current fcb
	; Zero the receiving ranrec field
	CALL	GET$RRA
	PUSH	HL		; Save position
	LD	(HL),D
	INC	HL
	LD	(HL),D
	INC	HL
	LD	(HL),D		; =00 00 00
	CALL	SEARCH$EXTNUM
GETSIZE:
	JP	Z,SETSIZE
	; current fcb addressed by dptr
	CALL	GETDPTRA
	LD	DE,RECCNT	; ready for compute size
	CALL	COMPUTE$RR
	; a=0000 00mm bc = mmmm eeee errr rrrr
	; Compare with memory, larger?
	POP	HL
	PUSH	HL		; Recall, replace .fcb(ranrec)
	CALL	COMPARE$RR
	CALL	NC,SET$RR
	CALL	SEARCHN
	LD	A,0
	LD	(ARET),A
	JP	GETSIZE
SETSIZE:

	POP	HL		; Discard .fcb(ranrec)
	RET

SETRANDOM:
	; Set random record from the current file control block
	EX	DE,HL
	LD	DE,NXTREC	; Ready params for computesize
	CALL	COMPUTE$RR	; de=info, a=0000 00mm, bc=mmmm eeee errr rrrr
	LD	HL,RANREC
	ADD	HL,DE		; hl = .fcb(ranrec)
	LD	(HL),C
	INC	HL
	LD	(HL),B
	INC	HL
	LD	(HL),A		; to ranrec
	RET

DISK$SELECT:
	; Select disk info for subsequent input or output ops
	LD	(ADRIVE),A
DISK$SELECT1: ; called by deblock
	LD	(HL),A		; curdsk = seldsk or adrive
	LD	D,A		; Save seldsk in register D for selectdisk call
	LD	HL,(DLOG)
	CALL	TESTVECTOR	; test$vector does not modify DE
	LD	E,A
	PUSH	DE		; Send to seldsk, save for test below
	CALL	SELECTDISK
	POP	HL		; Recall dlog vector
	JP	NC,SEL$ERROR	; returns with C flag set if select ok
	; Is the disk logged in?
	DEC	L		; reg l = 1 if so
	RET

TMPSELECT:
	LD	HL,SELDSK
	LD	(HL),E

CURSELECT:
	LD	A,(SELDSK)
	LD	HL,CURDSK
	CP	(HL)
	JP	NZ,SELECT
	CP	0FFH
	RET	NZ		; return if seldsk ~= ffh

SELECT:
	CALL	DISK$SELECT

	IF MPM
	JP	NZ,SELECT1	; no
	; yes - drive previously logged in
	LD	HL,(RLOG)
	CALL	TESTVECTOR
	LD	(REM$DRV),A
	RET			; Set rem$drv & return
SELECT1:

	ELSE
	RET	Z		; yes - drive previously logged in
	ENDIF

	CALL	INITIALIZE	; Log in the directory

	; Increment login sequence # if odd
	LD	HL,(LSN$ADD)
	LD	A,(HL)
	AND	1
	PUSH	AF
	ADD	A,(HL)
	LD	(HL),A
	POP	AF
	CALL	NZ,SET$RLOG

	CALL	SET$DLOG

	IF MPM
	LD	HL,CHKSIZ+1
	LD	A,(HL)
	RLA
	LD	A,0
	JP	C,SELECT2
	LD	DE,RLOG
	CALL	SET$CDISK	; rlog=set$cdisk(rlog)
	LD	A,1
SELECT2:
	LD	(REM$DRV),A
	ENDIF

	RET

RESELECTX:
	XOR	A
	LD	(HIGH$EXT),A

	IF BANKED
	LD	(XFCB$READ$ONLY),A
	ENDIF

	JP	RESELECT1

RESELECT:
	; Check current fcb to see if reselection necessary
	LD	BC,807FH
	LD	HL,(INFO)
	LD	DE,7
	EX	DE,HL
	ADD	HL,DE

	IF BANKED
	; xfcb$read$only = 80h & fcb(7)
	LD	A,(HL)
	AND	B
	LD	(XFCB$READ$ONLY),A
	; fcb(7) = fcb(7) & 7fh
	LD	A,(HL)
	AND	C
	LD	(HL),A
	ENDIF

	IF MPM
	; if fcb(8) & 80h
	;    then fcb(8) = fcb(8) & 7fh, high$ext = 60h
	;    else high$ext = fcb(ext) & 0e0h
	INC	HL
	LD	DE,4
	LD	A,(HL)
	AND	C
	CP	(HL)
	LD	(HL),A
	LD	A,60H
	JP	NZ,RESELECT0
	ADD	HL,DE
	LD	A,0E0H
	AND	(HL)
RESELECT0:
	LD	(HIGH$EXT),A
	ELSE
	; high$ext = 80h & fcb(8)
	INC	HL
	LD	A,(HL)
	AND	B
	LD	(HIGH$EXT),A
	; fcb(8) = fcb(8) & 7fh
	LD	A,(HL)
	AND	C
	LD	(HL),A
	ENDIF

	; fcb(ext) = fcb(ext) & 1fh
	CALL	CLR$EXT
RESELECT1:

	LD	HL,0

	IF BANKED
	LD	(MAKE$XFCB),HL	; make$xfcb,find$xfcb = 0
	ENDIF
	LD	(XDCNT),HL	; required by directory hashing

	XOR	A
	LD	(SEARCH$USER0),A
	DEC	A
	LD	(RESEL),A	; Mark possible reselect
	LD	HL,(INFO)
	LD	A,(HL)		; drive select code
	LD	(FCBDSK),A	; save drive code
	AND	00011111B		; non zero is auto drive select
	DEC	A		; Drive code normalized to 0..30, or 255
	LD	(LINFO),A	; Save drive code
	CP	0FFH
	JP	Z,NOSELECT
	; auto select function, seldsk saved above
	LD	(SELDSK),A
NOSELECT:
	CALL	CURSELECT
	; Set user code
	LD	A,(USRCODE)	; 0...15
	LD	HL,(INFO)
	LD	(HL),A
NOSELECT0:
	; Discard directory BCB's if drive is removable
	; and fx = 15,17,19,22,23,30 etc.
	CALL	TST$LOG$FXS
	CALL	Z,DISCARD$DIR
	; Check for media change on currently slected disk
	CALL	CHECK$MEDIA
	; Check for media change on any other disks
	JP	CHECK$ALL$MEDIA

CHECK$MEDIA:
	; Check media if DPH media flag set.
	; Is DPH media flag set?
	CALL	TEST$MEDIA$FLAG
	RET	Z		; no
	; Test for media change by reading directory
	; to current high water mark or until media change
	; is detected.
	; First reset DPH media flag & discard directory BCB's
	LD	(HL),0
	CALL	DISCARD$DIR
	LD	HL,(DCNT)
	PUSH	HL
	CALL	HOME
	CALL	SETENDDIR
CHECK$MEDIA1:
	LD	C,FALSE
	CALL	R$DIR
	LD	HL,RELOG
	LD	A,(HL)
	OR	A
	JP	Z,CHECK$MEDIA2
	LD	(HL),0
	POP	HL
	LD	A,(FX)
	CP	48
	RET	Z
	CALL	DRV$RELOG
	JP	CHK$EXIT$FXS
CHECK$MEDIA2:
	CALL	COMPCDR
	JP	C,CHECK$MEDIA1
	POP	HL
	LD	(DCNT),HL
	RET

CHECK$ALL$MEDIA:
	; This routine checks all logged-in drives for
	; a set DPH media flag and pending buffers.  It reads
	; the directory for these drives to verify that media
	; has not changed.  If media has changed, the drives
	; get reset (but not relogged-in).
	; Is SCB media flag set?
	LD	HL,MEDIA$FLAG
	LD	A,(HL)
	OR	A
	RET	Z		; no
	; Reset SCB media flag
	LD	(HL),0
	; Test logged-in drives only
	LD	HL,(DLOG)
	LD	A,16
CHK$AM1:
	DEC	A
	ADD	HL,HL
	JP	NC,CHK$AM2
	; A = drive #
	; Select drive
	PUSH	AF
	PUSH	HL
	LD	HL,CURDSK
	CALL	DISK$SELECT
	; Does drive have pending data buffers?
	CALL	TEST$PENDING
	CALL	NZ,CHECK$MEDIA	; yes
	POP	HL
	POP	AF
CHK$AM2:
	OR	A
	JP	NZ,CHK$AM1
	JP	CURSELECT

TEST$PENDING:
	; On return, Z flag reset if buffer pending

	; Does dta$bcba = 0ffffh
	LD	HL,(DTABCBA)
	LD	A,L
	AND	H
	INC	A
	RET	Z		; yes

	IF BANKED

TEST$P1:
	; Does bcb addr = 0?
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	A,E
	OR	D
	RET	Z		; yes - no pending buffers
	LD	HL,4
	ELSE
	LD	DE,4
	ENDIF

	; Is buffer pending?
	ADD	HL,DE
	LD	A,(HL)
	OR	A		; A ~= 0 if so

	IF BANKED
	RET	NZ		; yes
	; no - advance to next bcb
	LD	HL,13
	ADD	HL,DE
	JP	TEST$P1
	ELSE
	RET
	ENDIF

GET$DIR$MODE:
	LD	HL,(DRVLBLA)
	LD	A,(HL)

	IF NOT BANKED
	AND	7FH		; Mask off password bit
	ENDIF

	RET

	IF BANKED

CHK$PASSWORD:
	CALL	GET$DIR$MODE
	AND	80H
	RET	Z

CHK$PW:	; Check password
	CALL	GETXFCB
	RET	Z		; a = xfcb options
	JP	CMP$PW

CHK$PW$ERROR:
	; Disable special searches
	XOR	A
	LD	(XDCNT+1),A
	; pw$fcb = dir$xfcb
	CALL	GETDPTRA
	EX	DE,HL
	LD	C,12
	LD	HL,PW$FCB
	PUSH	HL
	CALL	MOVE
	LD	A,(DE)
	INC	HL
	LD	(HL),A
	POP	DE
	LD	HL,(INFO)
	LD	A,(HL)
	LD	(DE),A
	; push original info and xfcb password mode
	; info = .pw$fcb
	PUSH	HL
	EX	DE,HL
	LD	(INFO),HL
	; Does fcb(ext = 0, mod = 0) exist?
	CALL	SEARCH$NAMLEN
	JP	Z,CHK$PWE2	; no
	; Does sfcb exist for fcb ?
	CALL	GETDTBA$8
	OR	A
	JP	NZ,CHK$PWE1	; no
	EX	DE,HL
	LD	HL,PW$MODE
	; Is sfcb password mode nonzero?
	LD	B,(HL)
	LD	A,(DE)
	LD	(HL),A
	OR	A
	JP	Z,CHK$PWE2	; no
	; Do password modes match?
	XOR	B
	AND	0E0H
	JP	Z,CHK$PWE1	; yes
	; no - update xfcb to match sfcb
	CALL	GETXFCB
	JP	Z,CHK$PWE1	; no xfcb (error)
	LD	A,(PW$MODE)
	LD	(HL),A
	CALL	NOWRITE
	CALL	Z,SEEK$COPY
CHK$PWE1:
	POP	HL
	LD	(INFO),HL
	LD	A,(FX)
	CP	15
	RET	Z
	CP	22
	RET	Z

PW$ERROR: ; password error
	LD	A,7
	JP	SET$ARET

CHK$PWE2:
	XOR	A
	LD	(PW$MODE),A
	CALL	NOWRITE
	JP	NZ,CHK$PWE3
	; Delete xfcb
	CALL	GETXFCB
	PUSH	AF
	LD	HL,(INFO)
	LD	A,(HL)
	OR	10H
	LD	(HL),A
	POP	AF
	CALL	NZ,DELETE10
CHK$PWE3:
	; Restore info
	POP	HL
	LD	(INFO),HL
	RET

CMP$PW:	; Compare passwords
	INC	HL
	LD	B,(HL)
	LD	A,B
	OR	A
	JP	NZ,CMP$PW2
	LD	D,H
	LD	E,L
	INC	HL
	INC	HL
	LD	C,9
CMP$PW1:
	INC	HL
	LD	A,(HL)
	DEC	C
	RET	Z
	OR	A
	JP	Z,CMP$PW1
	CP	20H
	JP	Z,CMP$PW1
	EX	DE,HL
CMP$PW2:
	LD	DE,[23-UBYTES]
	ADD	HL,DE
	EX	DE,HL
	LD	HL,(XDMAAD)
	LD	C,8
CMP$PW3:
	LD	A,(DE)
	XOR	B
	CP	(HL)
	JP	NZ,CMP$PW4
	DEC	DE
	INC	HL
	DEC	C
	JP	NZ,CMP$PW3
	RET
CMP$PW4:
	DEC	DE
	DEC	C
	JP	NZ,CMP$PW4
	INC	DE

	IF MPM
	CALL	GET$DF$PWA
	INC	A
	JP	NZ,CMP$PW5
	INC	A
	RET
CMP$PW5:

	ELSE
	LD	HL,DF$PASSWORD
	ENDIF

	LD	C,8
	JP	COMPARE

	IF MPM

GET$DF$PWA: ; a = ff => no df pwa
	CALL	RLR
	LD	BC,CONSOLE
	ADD	HL,BC
	LD	A,(HL)
	CP	16
	LD	A,0FFH
	RET	NC
	LD	A,(HL)
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	H,0
	LD	L,A
	LD	BC,DFPASSWORD
	ADD	HL,BC
	RET
	ENDIF

SET$PW:	; Set password in xfcb
	PUSH	HL		; Save .xfcb(ex)
	LD	BC,8		; b = 0, c = 8
	LD	DE,[23-EXTNUM]
	ADD	HL,DE
	EX	DE,HL
	LD	HL,(XDMAAD)
SET$PW0:
	XOR	A
	PUSH	AF
SET$PW1:
	LD	A,(HL)
	LD	(DE),A
	OR	A
	JP	Z,SET$PW2
	CP	20H
	JP	Z,SET$PW2
	INC	SP
	INC	SP
	PUSH	AF
SET$PW2:
	ADD	A,B
	LD	B,A
	DEC	DE
	INC	HL
	DEC	C
	JP	NZ,SET$PW1
	POP	AF
	OR	B
	POP	HL
	JP	NZ,SET$PW3
	; is fx = 100 (directory label)?
	LD	A,(FX)
	CP	100
	JP	Z,SET$PW3	; yes
	LD	(HL),0		; zero xfcb(ex) - no password
SET$PW3:
	INC	DE
	LD	C,8
SET$PW4:
	LD	A,(DE)
	XOR	B
	LD	(DE),A
	INC	DE
	DEC	C
	JP	NZ,SET$PW4
	INC	HL
	RET

GETXFCB:
	LD	HL,(INFO)
	LD	A,(HL)
	PUSH	AF
	OR	010H
	LD	(HL),A
	CALL	SEARCH$EXTNUM
	LD	A,0
	LD	(LRET),A
	LD	HL,(INFO)
	POP	BC
	LD	(HL),B
	RET	Z
GETXFCB1:
	CALL	GETDPTRA
	EX	DE,HL
	LD	HL,EXTNUM
	ADD	HL,DE
	LD	A,(HL)
	AND	0E0H
	OR	1
	RET

ADJUST$DMAAD:
	PUSH	HL
	LD	HL,(XDMAAD)
	ADD	HL,DE
	LD	(XDMAAD),HL
	POP	HL
	RET

INIT$XFCB:
	CALL	SETCDR		; may have extended the directory
	LD	BC,1014H	; b=10h, c=20
INIT$XFCB0:
	; b = fcb(0) logical or mask
	; c = zero count
	PUSH	BC
	CALL	GETDPTRA
	EX	DE,HL
	LD	HL,(INFO)
	EX	DE,HL
	; Zero extnum and modnum
	LD	A,(DE)
	OR	B
	LD	(HL),A
	INC	DE
	INC	HL
	LD	C,11
	CALL	MOVE
	POP	BC
	INC	C
INIT$XFCB1:
	DEC	C
	RET	Z
	LD	(HL),0
	INC	HL
	JP	INIT$XFCB1

CHK$XFCB$PASSWORD:
	CALL	GETXFCB1
CHK$XFCB$PASSWORD1:
	PUSH	HL
	CALL	CMP$PW
	POP	HL
	RET

	ENDIF

STAMP1:
	LD	C,0
	JP	STAMP3
STAMP2:
	LD	C,4
STAMP3:
	CALL	GETDTBA
	OR	A
	RET	NZ
	LD	DE,SEEK$COPY
	PUSH	DE
STAMP4:

	IF MPM
	PUSH	HL
	CALL	GET$STAMP$ADD
	EX	DE,HL
	POP	HL
	ELSE
	LD	DE,STAMP
	ENDIF

	PUSH	HL
	PUSH	DE
	LD	C,0
	CALL	TIMEF		; does not modify hl,de
	LD	C,4
	CALL	COMPARE
	LD	C,4
	POP	DE
	POP	HL
	JP	NZ,MOVE
	POP	HL
	RET

STAMP5:
	CALL	GETDPTRA
	ADD	HL,BC
	LD	DE,FUNC$RET
	PUSH	DE
	JP	STAMP4

	IF BANKED

GETDTBA$8:
	LD	C,8
	ENDIF

GETDTBA:
	; c = offset of sfcb subfield (0,4,8)
	; Return with a = 0 if sfcb exists

	; Does fcb occupy 4th item of sector?
	LD	A,(DCNT)
	AND	3
	CP	3
	RET	Z		; yes
	LD	B,A
	LD	HL,(BUFFA)
	LD	DE,96
	ADD	HL,DE
	; Does sfcb reside in 4th directory item?
	LD	A,(HL)
	SUB	21H
	RET	NZ		; no
	; hl = hl + 10*lret + 1 + c
	LD	A,B
	ADD	A,A
	LD	E,A
	ADD	A,A
	ADD	A,A
	ADD	A,E
	INC	A
	ADD	A,C
	LD	E,A
	ADD	HL,DE
	XOR	A
	RET

QSTAMP:
	; Is fcb 1st logical fcb for file?
	CALL	QDIRFCB1
	RET	NZ		; no
QSTAMP1:
	; Does directory label specify requested stamp?
	LD	HL,(DRVLBLA)
	LD	A,C
	AND	(HL)
	JP	NZ,NOWRITE	; yes - verify drive r/w
	INC	A
	RET			; no - return with Z flag reset

QDIRFCB1:
	; Routine to determine if fcb is 1st directory fcb
	; for file
	; Is fcb(ext) & ~extmsk & 00011111b = 0?
	LD	A,(EXTMSK)
	OR	11100000B
	CPL
	LD	B,A
	CALL	GETEXTA
	LD	A,(HL)
	AND	B
	RET	NZ		; no
	; is fcb(mod) & 0011$1111B = 0?
	INC	HL
	INC	HL
	LD	A,(HL)
	AND	3FH
	RET			; Z flag set if zero

UPDATE$STAMP:
	; Is update stamping requested on drive?
	LD	C,00100000B
	CALL	QSTAMP1
	RET	NZ		; no
	; Has file been written to since it was opened?
	CALL	GETMODNUM
	AND	40H
	RET	NZ		; yes - update stamp performed
	; Search for 1st dir fcb
	CALL	GETEXTA
	LD	B,(HL)
	LD	(HL),0
	PUSH	HL
	INC	HL
	INC	HL
	LD	C,(HL)
	LD	(HL),0
	PUSH	BC
	; Search from beginning of directory
	CALL	SEARCH$NAMLEN
	; Perform update stamp if dir fcb 1 found
	CALL	NZ,STAMP2
	XOR	A
	LD	(LRET),A
	; Restore fcb extent and module fields
	POP	BC
	POP	HL
	LD	(HL),B
	INC	HL
	INC	HL
	LD	(HL),C
	RET

	IF MPM

PACK$SDCNT:

;packed$dcnt = dblk(low 15 bits) || dcnt(low 9 bits)

;	if sdblk = 0 then dblk = shr(sdcnt,blkshf+2)
;		     else dblk = sdblk
;	dcnt = sdcnt & (blkmsk || '11'b)
;
;	packed$dcnt format (24 bits)
;
;	12345678 12345678 12345678
;	23456789 .......1 ........ sdcnt (low 9 bits)
;	........ 9abcdef. 12345678 sdblk (low 15 bits)
;
	LD	HL,(SDBLK)
	LD	A,H
	OR	L
	JP	NZ,PACK$SDCNT1
	LD	A,(BLKSHF)
	ADD	A,2
	LD	C,A
	LD	HL,(SDCNT)
	CALL	HLROTR
PACK$SDCNT1:
	ADD	HL,HL
	EX	DE,HL
	LD	HL,SDCNT
	LD	B,1
	LD	A,(BLKMSK)
	RLA
	OR	B
	RLA
	OR	B
	AND	(HL)
	LD	(PACKED$DCNT),A
	LD	A,(BLKSHF)
	CP	7
	JP	NZ,PACK$SDCNT2
	INC	HL
	LD	A,(HL)
	AND	B
	JP	Z,PACK$SDCNT2
	LD	A,E
	OR	B
	LD	E,A
PACK$SDCNT2:
	EX	DE,HL
	LD	(PACKED$DCNT+1),HL
	RET

; olist element = link(2) || atts(1) || dcnt(3) ||
;		 pdaddr(2) || opncnt(2)
;
;	link = 0 -> end of list
;
;	atts - 80 - open in locked mode
;	       40 - open in unlocked mode
;	       20 - open in read/only mode
;	       10 - deleted item
;	       0n - drive code (0-f)
;
;	dcnt = packed sdcnt+sdblk
;	pdaddr = process descriptor addr
;	opncnt = # of open calls - # of close calls
;		 olist item freed by close when opncnt = 0
;
; llist element = link(2) || drive(1) || arecord(3) ||
;		 pdaddr(2) || .olist$item(2)
;
;	link = 0 -> end of list
;
;	drive - 0n - drive code (0-f)
;
;	arecord = record number of locked record
;	pdaddr = process descriptor addr
;	.olist$item = address of file's olist item

SEARCH$OLIST:
	LD	HL,OPEN$ROOT
	JP	SRCH$LIST0
SEARCH$LLIST:
	LD	HL,LOCK$ROOT
	JP	SRCH$LIST0
SEARCHN$LIST:
	LD	HL,(CUR$POS)
SRCH$LIST0:
	LD	(PRV$POS),HL

; search$olist, search$llist, searchn$list conventions
;
;	b = 0 -> return next item
;	b = 1 -> search for matching drive
;	b = 3 -> search for matching dcnt
;	b = 5 -> search for matching dcnt + pdaddr
;	if found then z flag is set
;		      prv$pos -> previous list element
;		      cur$pos -> found list element
;		      hl -> found list element
;	else prv$pos -> list element to insert after
;
;	olist and llist are maintained in drive order

SRCH$LIST1:
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	LD	A,L
	OR	H
	JP	Z,SRCH$LIST3
	XOR	A
	CP	B
	JP	Z,SRCH$LIST6
	INC	HL
	INC	HL!
	LD	DE,CURDSK
	LD	A,(HL)
	AND	0FH
	LD	C,A
	LD	A,(DE)
	SUB	C
	JP	NZ,SRCH$LIST4
	LD	A,B
	DEC	A
	JP	Z,SRCH$LIST5
	LD	C,B
	PUSH	HL
	INC	DE
	INC	HL
	CALL	COMPARE
	POP	HL
	JP	Z,SRCH$LIST5
SRCH$LIST2:
	DEC	HL
	DEC	HL
	LD	(PRV$POS),HL
	JP	SRCH$LIST1
SRCH$LIST3:
	INC	A
	RET
SRCH$LIST4:
	JP	NC,SRCH$LIST2
SRCH$LIST5:
	DEC	HL
	DEC	HL
SRCH$LIST6:
	LD	(CUR$POS),HL
	RET

DELETE$ITEM: ; hl -> item to be deleted
	DI
	PUSH	DE
	PUSH	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	HL,(PRV$POS)
	LD	(CUR$POS),HL
	; prv$pos.link = delete$item.link
	LD	(HL),E
	INC	HL
	LD	(HL),D

	LD	HL,(FREE$ROOT)
	EX	DE,HL
	; free$root = .delete$item
	POP	HL
	LD	(FREE$ROOT),HL
	; delete$item.link = previous free$root
	LD	(HL),E
	INC	HL
	LD	(HL),D
	POP	DE
	EI
	RET

CREATE$ITEM: ; hl -> new item if successful
	; z flag set if no free items
	LD	HL,(FREE$ROOT)
	LD	A,L
	OR	H
	RET	Z
	PUSH	DE
	PUSH	HL
	LD	(CUR$POS),HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	; free$root = free$root.link
	EX	DE,HL
	LD	(FREE$ROOT),HL

	LD	HL,(PRV$POS)
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	POP	HL
	; create$item.link = prv$pos.link
	LD	(HL),E
	INC	HL
	LD	(HL),D
	DEC	HL
	EX	DE,HL
	LD	HL,(PRV$POS)
	; prv$pos.link = .create$item
	LD	(HL),E
	INC	HL
	LD	(HL),D
	EX	DE,HL
	POP	DE
	RET

SET$OLIST$ITEM:
	; a = attributes
	; hl = olist entry address
	INC	HL
	INC	HL
	LD	B,A
	LD	DE,CURDSK
	LD	A,(DE)
	OR	B
	LD	(HL),A
	INC	HL
	INC	DE
	LD	C,5
	CALL	MOVE
	XOR	A
	LD	(HL),A
	INC	HL
	LD	(HL),A
	RET

SET$SDCNT:
	LD	A,0FFH
	LD	(SDCNT+1),A
	RET

TST$OLIST:
	LD	A,0C9H
	LD	(CHK$OLIST05),A
	JP	CHK$OLIST0
CHK$OLIST:
	XOR	A
	LD	(CHK$OLIST05),A
CHK$OLIST0:
	LD	DE,DCNT
	LD	HL,SDCNT
	LD	C,4
	CALL	MOVE
	CALL	PACK$SDCNT
	LD	B,3
	CALL	SEARCH$OLIST
	RET	NZ
	POP	DE		; pop return address
	INC	HL
	INC	HL
	LD	A,(HL)
	AND	80H
	JP	Z,OPENX06
	DEC	HL
	DEC	HL
	PUSH	DE
	PUSH	HL
	CALL	COMPARE$PDS
	POP	HL
	POP	DE
	JP	NZ,OPENX06
	PUSH	DE		; Restore return address
CHK$OLIST05:
	NOP			; tst$olist changes this instr to ret
	CALL	DELETE$ITEM
	LD	A,(PDCNT)
CHK$OLIST1:
	ADD	A,16
	JP	Z,CHK$OLIST1
	LD	(PDCNT),A

	PUSH	AF
	CALL	RLR
	LD	BC,PDCNT$OFF
	ADD	HL,BC
	POP	AF
	LD	(HL),A
	RET

REMOVE$FILES: ; bc = pdaddr
	LD	HL,(CUR$POS)
	PUSH	HL
	LD	HL,(PRV$POS)
	PUSH	HL
	LD	D,B
	LD	E,C
	LD	HL,OPEN$ROOT
	LD	(CUR$POS),HL
REMOVE$FILE1:
	LD	B,0
	PUSH	DE
	CALL	SEARCHN$LIST
	POP	DE
	JP	NZ,REMOVE$FILE2
	LD	BC,6
	CALL	TST$TBL$LMT
	JP	NZ,REMOVE$FILE1
	INC	HL
	INC	HL
	LD	A,(HL)
	OR	10H
	LD	(HL),A
	LD	(DELETED$FILES),A
	JP	REMOVE$FILE1
REMOVE$FILE2:
	POP	HL
	LD	(PRV$POS),HL
	POP	HL
	LD	(CUR$POS),HL
	RET

DELETE$FILES:
	LD	HL,OPEN$ROOT
	LD	(CUR$POS),HL
DELETE$FILE1:
	LD	B,0
	CALL	SEARCH$NLIST
	RET	NZ
	INC	HL
	INC	HL
	LD	A,(HL)
	AND	10H
	JP	Z,DELETE$FILE1
	DEC	HL
	DEC	HL
	CALL	REMOVE$LOCKS
	CALL	DELETE$ITEM
	JP	DELETE$FILE1

FLUSH$FILES:
	LD	HL,FLUSHED
	LD	A,(HL)
	OR	A
	RET	NZ
	INC	(HL)
FLUSH$FILE0:
	LD	HL,OPEN$ROOT
	LD	(CUR$POS),HL
FLUSH$FILE1:
	LD	B,1
	CALL	SEARCHN$LIST
	RET	NZ
	PUSH	HL
	CALL	REMOVE$LOCKS
	CALL	DELETE$ITEM
	POP	HL
	LD	DE,6
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	HL,PDCNT$OFF
	ADD	HL,DE
	LD	A,(HL)
	AND	1
	JP	NZ,FLUSH$FILE1
	LD	A,(HL)
	OR	1
	LD	(HL),A
	LD	HL,(PDADDR)
	LD	C,2
	CALL	COMPARE
	JP	NZ,FLUSH$FILE1
	LD	A,(PDCNT)
	ADD	A,10H
	LD	(PDCNT),A
	JP	FLUSH$FILE1

FREE$FILES:
	; free$mode = 1 - remove curdsk files for process
	;	      0 - remove all files for process
	LD	HL,(PDADDR)
	EX	DE,HL
	LD	HL,OPEN$ROOT
	LD	(CURPOS),HL
FREE$FILES1:
	LD	A,(FREE$MODE)
	LD	B,A
	PUSH	DE
	CALL	SEARCHN$LIST
	POP	DE
	RET	NZ
	LD	BC,6
	CALL	TST$TBL$LMT
	JP	NZ,FREE$FILES1
	PUSH	HL
	INC	HL
	INC	HL
	INC	HL
	CALL	TEST$FFFF
	JP	NZ,FREE$FILES2
	CALL	TEST$FFFF
	JP	Z,FREE$FILES3
FREE$FILES2:
	LD	A,0FFH
	LD	(INCR$PDCNT),A
FREE$FILES3:
	POP	HL
	CALL	REMOVE$LOCKS
	CALL	DELETE$ITEM
	JP	FREE$FILES1

REMOVE$LOCKS:
	LD	(FILE$ID),HL
	INC	HL
	INC	HL
	LD	A,(HL)
	AND	40H
	JP	Z,REMOVE$LOCK3
	PUSH	DE
	LD	HL,(PRV$POS)
	PUSH	HL
	LD	HL,(FILE$ID)
	EX	DE,HL
	LD	HL,LOCK$ROOT
	LD	(CUR$POS),HL
REMOVE$LOCK1:
	LD	B,0
	PUSH	DE
	CALL	SEARCHN$LIST
	POP	DE
	JP	NZ,REMOVE$LOCK2
	LD	BC,8
	CALL	TST$TBL$LMT
	JP	NZ,REMOVE$LOCK1
	CALL	DELETE$ITEM
	JP	REMOVE$LOCK1
REMOVE$LOCK2:
	POP	HL
	LD	(PRV$POS),HL
	POP	DE
REMOVE$LOCK3:
	LD	HL,(FILE$ID)
	RET

TST$TBL$LMT:
	PUSH	HL
	ADD	HL,BC
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	SUB	E
	JP	NZ,TST$TBL$LMT1
	LD	A,H
	SUB	D
TST$TBL$LMT1:
	POP	HL
	RET

CREATE$OLIST$ITEM:
	LD	B,1
	CALL	SEARCH$OLIST
	DI
	CALL	CREATE$ITEM
	LD	A,(ATTRIBUTES)
	CALL	SET$OLIST$ITEM
	EI
	RET

COUNT$OPENS:
	XOR	A
	LD	(OPEN$CNT),A
	LD	HL,(PDADDR)
	EX	DE,HL
	LD	HL,OPEN$ROOT
	LD	(CURPOS),HL
COUNT$OPEN1:
	LD	B,0
	PUSH	DE
	CALL	SEARCHN$LIST
	POP	DE
	JP	NZ,COUNT$OPEN2
	LD	BC,6
	CALL	TST$TBL$LMT
	JP	NZ,COUNT$OPEN1
	LD	A,(OPEN$CNT)
	INC	A
	LD	(OPEN$CNT),A
	JP	COUNT$OPEN1
COUNT$OPEN2:
	LD	HL,OPEN$MAX
	LD	A,(OPEN$CNT)
	RET

COUNT$LOCKS:
	XOR	A
	LD	(LOCK$CNT),A
	EX	DE,HL
	LD	HL,LOCK$ROOT
	LD	(CUR$POS),HL
COUNT$LOCK1:
	LD	B,0
	PUSH	DE
	CALL	SEARCHN$LIST
	POP	DE
	RET	NZ
	LD	BC,8
	CALL	TST$TBL$LMT
	JP	NZ,COUNT$LOCK1
	LD	A,(LOCK$CNT)
	INC	A
	LD	(LOCK$CNT),A
	JP	COUNT$LOCK1

CHECK$FREE:
	LD	A,(MULTCNT)
	LD	E,A
	LD	D,0
	LD	HL,FREE$ROOT
	LD	(CUR$POS),HL
CHECK$FREE1:
	LD	B,0
	PUSH	DE
	CALL	SEARCHN$LIST
	POP	DE
	JP	NZ,CHECK$FREE2
	INC	D
	LD	A,D
	SUB	E
	JP	C,CHECK$FREE1
	RET
CHECK$FREE2:
	POP	HL
	LD	A,14
	JP	STA$RET

LOCK:	; record lock and unlock
	CALL	RESELECT
	CALL	CHECK$FCB
	CALL	TEST$UNLOCKED
	RET	Z		; file not opened in unlocked mode
	LD	HL,(XDMAAD)
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	INC	HL
	INC	HL
	LD	A,(HL)
	LD	B,A
	LD	A,(CURDSK)
	SUB	B
	AND	0FH
	JP	NZ,LOCK8	; invalid file id
	LD	A,B
	AND	40H
	JP	Z,LOCK8		; invalid file id
	DEC	HL
	DEC	HL
	LD	(FILE$ID),HL
	LD	A,(LOCK$UNLOCK)
	INC	A
	JP	NZ,LOCK1	; jmp if unlock
	CALL	COUNT$LOCKS
	LD	A,(LOCK$CNT)
	LD	B,A
	LD	A,(MULTCNT)
	ADD	A,B
	LD	B,A
	LD	A,(LOCK$MAX)
	CP	B
	LD	A,12
	JP	C,STA$RET	; too many locks by this process
	CALL	CHECK$FREE
LOCK1:
	CALL	SAVE$RR
	LD	HL,LOCK9
	PUSH	HL
	LD	A,(MULTCNT)
LOCK2:
	PUSH	AF
	CALL	GET$LOCK$ADD
	LD	A,(LOCK$UNLOCK)
	INC	A
	JP	NZ,LOCK3
	CALL	TEST$LOCK
LOCK3:
	POP	AF
	DEC	A
	JP	Z,LOCK4
	CALL	INCR$RR
	JP	LOCK2
LOCK4:
	CALL	RESET$RR
	LD	A,(MULTCNT)
LOCK5:
	PUSH	AF
	CALL	GET$LOCK$ADD
	LD	A,(LOCK$UNLOCK)
	INC	A
	JP	NZ,LOCK6
	CALL	SET$LOCK
	JP	LOCK7
LOCK6:
	CALL	FREE$LOCK
LOCK7:
	POP	AF
	DEC	A
	RET	Z
	CALL	INCR$RR
	JP	LOCK5
LOCK8:
	LD	A,13
	JP	STA$RET		; invalid file id
LOCK9:
	CALL	RESET$RR
	RET

GET$LOCK$ADD:
	LD	HL,0
	ADD	HL,SP
	LD	(LOCK$SP),HL
	LD	A,0FFH
	LD	(LOCK$SHELL),A
	CALL	RSEEK
	XOR	A
	LD	(LOCK$SHELL),A
	CALL	GETFCB
	LD	HL,(ARET)
	LD	A,L
	OR	A
	JP	NZ,LOCK$ERR
	CALL	INDEX
	LD	HL,1
	JP	Z,LOCK$ERR
	CALL	ATRAN
	RET

LOCK$PERR:
	XOR	A
	LD	(LOCK$SHELL),A
	EX	DE,HL
	LD	HL,(LOCK$SP)
	LD	SP,HL
	EX	DE,HL
LOCK$ERR:
	POP	DE		; Discard return address
	POP	BC		; b = mult$cnt-# recs processed
	LD	A,(MULTCNT)
	SUB	B
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	OR	H
	LD	H,A
	LD	B,A
	LD	(ARET),HL
	RET

TEST$LOCK:
	CALL	MOVE$ARECORD
	LD	B,3
	CALL	SEARCH$LLIST
	RET	NZ
	CALL	COMPARE$PDS
	RET	Z
	LD	HL,8
	JP	LOCK$ERR

SET$LOCK:
	CALL	MOVE$ARECORD
	LD	B,1
	CALL	SEARCH$LLIST
	DI
	CALL	CREATE$ITEM
	XOR	A
	CALL	SET$OLIST$ITEM
	EX	DE,HL
	LD	HL,(FILE$ID)
	EX	DE,HL
	LD	(HL),D
	DEC	HL
	LD	(HL),E
	EI
	RET

FREE$LOCK:
	CALL	MOVE$ARECORD
	LD	B,5
	CALL	SEARCH$LLIST
	RET	NZ
FREE$LOCK0:
	CALL	DELETE$ITEM
	LD	B,5
	CALL	SEARCHN$LIST
	RET	NZ
	JP	FREE$LOCK0

COMPARE$PDS:
	LD	DE,6
	ADD	HL,DE
	EX	DE,HL
	LD	HL,PDADDR
	LD	C,2
	JP	COMPARE


MOVE$ARECORD:
	LD	DE,ARECORD
	LD	HL,PACKED$DCNT


FIX$OLIST$ITEM:
	LD	DE,XDCNT
	LD	HL,SDCNT
	; Is xdblk,xdcnt < sdblk,sdcnt
	LD	C,4
	OR	A!
FIX$OL1:
	LD	A,(DE)
	SBC	A,(HL)
	INC	HL
	INC	DE
	DEC	C
	JP	NZ,FIX$OL1
	RET	NC
	; yes - update olist entry
	CALL	SWAP
	CALL	SDCNT$EQ$XDCNT
	LD	HL,OPEN$ROOT
	LD	(CUR$POS),HL
	; Find file's olist entry
FIX$OL2:
	CALL	SWAP
	CALL	PACK$SDCNT
	CALL	SWAP
	LD	B,3
	CALL	SEARCHN$LIST
	RET	NZ
	; Update olist entry with new dcnt value
	PUSH	HL
	CALL	PACK$SDCNT
	POP	HL
	INC	HL
	INC	HL
	INC	HL
	LD	DE,PACKED$DCNT
	LD	C,3
	CALL	MOVE
	JP	FIX$OL2

HL$EQ$HL$AND$DE:
	LD	A,L
	AND	E
	LD	L,A
	LD	A,H
	AND	D
	LD	H,A
	RET

REMOVE$DRIVE:
	EX	DE,HL
	LD	A,(CURDSK)
	LD	C,A
	LD	HL,1
	CALL	HLROTL
	LD	A,L
	CPL
	AND	E
	LD	E,A
	LD	A,H
	CPL
	AND	D
	LD	D,A
	EX	DE,HL
	RET

DISKRESET:
	LD	HL,0
	LD	(NTLOG),HL
	XOR	A
	LD	(SET$RO$FLAG),A
	LD	HL,(INFO)
INTRNLDISKRESET:
	EX	DE,HL
	LD	HL,(OPEN$ROOT)
	LD	A,H
	OR	L
	RET	Z
	EX	DE,HL
	LD	A,(CURDSK)
	PUSH	AF
	LD	B,0
DSKRST1:
	LD	A,L
	RRA
	JP	C,DSKRST3
DSKRST2:
	LD	C,1
	CALL	HLROTR
	INC	B
	LD	A,H
	OR	L
	JP	NZ,DSKRST1
	POP	AF
	LD	(CURDSK),A
	LD	HL,(NTLOG)
	EX	DE,HL
	LD	HL,(TLOG)
	LD	A,L
	OR	E
	LD	L,A
	LD	A,H
	OR	D
	LD	H,A
	LD	(TLOG),HL
	INC	A
	RET
DSKRST3:
	PUSH	BC
	PUSH	HL
	LD	A,B
	LD	(CURDSK),A
	LD	HL,(RLOG)
	CALL	TESTVECTOR1
	PUSH	AF
	LD	HL,(RODSK)
	LD	A,(CURDSK)
	CALL	TESTVECTOR1
	LD	B,A
	POP	HL
	LD	A,(SET$RO$FLAG)
	OR	B
	OR	H
	LD	(CHECK$DISK),A
	LD	HL,OPEN$ROOT
	LD	(CUR$POS),HL
DSKRST4:
	LD	B,1
	CALL	SEARCHN$LIST
	JP	NZ,DSKRST6
	LD	A,(CHECK$DISK)
	OR	A
	JP	Z,DSKRST5
	PUSH	HL
	CALL	COMPARE$PDS
	JP	Z,DSKRST45
	POP	HL
	XOR	A
	EX	DE,HL
	JP	DSKRST6
DSKRST45:
	LD	DE,NTLOG
	CALL	SET$CDISK
	POP	HL
	JP	DSKRST4
DSKRST5:
	LD	HL,(INFO)
	CALL	REMOVE$DRIVE
	LD	(INFO),HL
	OR	1
DSKRST6:
	POP	HL
	POP	BC
	JP	NZ,DSKRST2

	; error - olist item exists for another process
	; for removable drive to be reset
	POP	AF
	LD	(CURDSK),A
	LD	A,B
	ADD	A,41H		; a = ascii drive
	LD	HL,6
	ADD	HL,DE
	LD	C,(HL)
	INC	HL
	LD	B,(HL)		; bc = pdaddr
	PUSH	AF
	CALL	TEST$ERRORMODE
	POP	DE
	JP	NZ,DSKRST7
	LD	A,D

	PUSH	BC
	PUSH	AF
	CALL	RLR
	LD	DE,CONSOLE
	ADD	HL,DE
	LD	D,(HL)		; d = console #
	LD	BC,DENIEDMSG
	CALL	XPRINT
	POP	AF
	LD	C,A
	CALL	CONOUTX
	LD	C,':'
	CALL	CONOUTX
	LD	BC,CNSMSG
	CALL	XPRINT
	POP	HL
	PUSH	HL
	LD	BC,CONSOLE
	ADD	HL,BC
	LD	A,(HL)
	ADD	A,'0'
	LD	C,A
	CALL	CONOUTX
	LD	BC,PROGMSG
	CALL	XPRINT
	POP	HL
	CALL	DSPLYNM

DSKRST7:
	POP	HL		; Remove return addr from diskreset
	LD	HL,0FFFFH
	LD	(ARET),HL	; Flag the error
	RET

DENIEDMSG:
	DEFB	CR,LF,'disk reset denied, drive ',0
CNSMSG:
	DEFB	' console ',0
PROGMSG:
	DEFB	' program ',0
	ENDIF

;
;	individual function handlers
;

FUNC12:
	; Return version number

	IF MPM
	LD	HL,0100H+DVERS
	JP	STHL$RET
	ELSE
	LD	A,(VERSION)
	JP	STA$RET		; lret = dvers (high = 00)
	ENDIF

FUNC13:

	IF MPM
	LD	HL,(DLOG)
	LD	(INFO),HL
	CALL	DISKRESET
	JP	Z,RESET$ALL
	CALL	RESET$37
	JP	FUNC13$CONT
RESET$ALL:

	; Reset disk system - initialize to disk 0
	LD	HL,0
	LD	(RODSK),HL
	LD	(DLOG),HL

	LD	(RLOG),HL
	LD	(TLOG),HL
FUNC13$CONT:
	LD	A,0FFH
	LD	(CURDSK),A
	ELSE
	LD	HL,0FFFFH
	CALL	RESET$37X
	ENDIF
	XOR	A
	LD	(OLDDSK),A	; Note that usrcode remains unchanged

	IF MPM
	XOR	A
	CALL	GETMEMSEG	; a = mem seg tbl index
	OR	A
	RET	Z
	INC	A
	RET	Z
	CALL	RLRADR
	LD	BC,MSEGTBL-RLROS
	ADD	HL,BC
	ADD	A,A
	ADD	A,A
	LD	E,A
	LD	D,0
	ADD	HL,DE
	LD	H,(HL)
	LD	L,80H
	JP	INTRNLSETDMA
	ELSE
	LD	HL,TBUFF
	LD	(DMAAD),HL	; dmaad = tbuff
	JP	SETDATA		; to data dma address
	ENDIF

FUNC14:

	IF MPM
	CALL	TMPSELECT	; seldsk = reg e
	CALL	RLR
	LD	BC,DISKSELECT
	ADD	HL,BC
	LD	A,(HL)
	AND	0FH
	RRCA
	RRCA
	RRCA
	RRCA
	LD	B,A
	LD	A,(SELDSK)
	OR	B
	RRCA
	RRCA
	RRCA
	RRCA
	LD	(HL),A
	RET
	ELSE
	CALL	TMPSELECT	; seldsk = reg e
	LD	A,(SELDSK)
	LD	(OLDDSK),A
	RET
	ENDIF

FUNC15:
	; Open file
	CALL	CLRMODNUM	; Clear the module number

	IF MPM
	CALL	RESELECT
	XOR	A
	LD	(MAKE$FLAG),A
	CALL	SET$SDCNT
	LD	HL,OPEN$FILE
	PUSH	HL
	LD	A,0C9H
	LD	(CHECK$FCB4),A
	CALL	CHECK$FCB1
	POP	HL
	LD	A,(HIGH$EXT)
	CP	060H
	JP	NZ,OPEN$FILE
	CALL	HOME
	CALL	SETENDDIR
	JP	OPEN$USER$ZERO
OPEN$FILE:
	CALL	SET$SDCNT
	CALL	RESET$CHKSUM$FCB; Set invalid check sum
	ELSE
	CALL	RESELECTX
	ENDIF

	CALL	CHECK$WILD	; Check for wild chars in fcb

	IF MPM

	CALL	GET$ATTS
	AND	1100$0000B	; a = attributes
	CP	1100$0000B
	JP	NZ,ATT$OK
	AND	0100$0000B	; Mask off unlock mode
ATT$OK:
	LD	(HIGH$EXT),A
	LD	B,A
	OR	A
	RRA
	JP	NZ,ATT$SET
	LD	A,80H
ATT$SET:
	LD	(ATTRIBUTES),A
	LD	A,B
	AND	80H
	JP	NZ,CALL$OPEN
	ENDIF

	LD	A,(USRCODE)
	OR	A
	JP	Z,CALL$OPEN
	LD	A,0FEH
	LD	(XDCNT+1),A
	INC	A
	LD	(SEARCH$USER0),A

	IF MPM
	LD	(SDCNT0+1),A
	ENDIF

CALL$OPEN:
	CALL	OPEN
	CALL	OPENX		; returns if unsuccessful, a = 0
	LD	HL,SEARCH$USER0
	CP	(HL)
	RET	Z
	LD	(HL),A
	LD	A,(XDCNT+1)
	CP	0FEH
	RET	Z
;
;	file exists under user 0
;

	IF MPM
	CALL	SWAP
	ENDIF

	CALL	SET$DCNT$DBLK

	IF MPM
	LD	A,0110$0000B
	ELSE
	LD	A,80H
	ENDIF

	LD	(HIGH$EXT),A
OPEN$USER$ZERO:
	; Set fcb user # to zero
	LD	HL,(INFO)
	LD	(HL),0
	LD	C,NAMLEN
	CALL	SEARCHI
	CALL	SEARCHN
	CALL	OPEN1		; Attempt reopen under user zero
	CALL	OPENX		; openx returns only if unsuccessful
	RET
OPENX:
	CALL	END$OF$DIR
	RET	Z
	CALL	GETFCBA
	LD	A,(HL)
	INC	A
	JP	NZ,OPENXA
	DEC	DE
	DEC	DE
	LD	A,(DE)
	LD	(HL),A
OPENXA:
	; open successful
	POP	HL		; Discard return address
	; Was file opened under user 0 after unsuccessful
	; attempt to open under user n?

	IF MPM
	LD	A,(HIGH$EXT)
	CP	060H
	JP	Z,OPENX00	; yes
	; Was file opened in locked mode?
	OR	A
	JP	NZ,OPENX0	; no
	; does user = zero?
	LD	HL,(INFO)
	OR	(HL)
	JP	NZ,OPENX0	; no
	; Does file have read/only attribute set?
	CALL	ROTEST
	JP	NC,OPENX0	; no
	; Does file have system attribute set?
	INC	HL
	LD	A,(HL)
	RLA
	JP	NC,OPENX0	; no

	; Force open mode to read/only mode and set user 0 flag
	; if file opened in locked mode, user = 0, and
	; file has read/only and system attributes set

OPENX00:

	ELSE
	LD	A,(HIGH$EXT)
	RLA
	JP	NC,OPENX0
	ENDIF

	; Is file under user 0 a system file ?

	IF MPM
	LD	A,20H
	LD	(ATTRIBUTES),A
	ENDIF

	LD	HL,(INFO)
	LD	DE,10
	ADD	HL,DE
	LD	A,(HL)
	AND	80H
	JP	NZ,OPENX0	; yes - open successful
	; open fails
	LD	(HIGH$EXT),A
	JP	LRET$EQ$FF
OPENX0:

	IF MPM
	CALL	RESET$CHKSUM$FCB
	ELSE
	CALL	SET$LSN
	ENDIF

	IF BANKED

	; Are passwords enabled on drive?
	CALL	GET$DIR$MODE
	AND	80H
	JP	Z,OPENX1A	; no
	; Is this 1st dir fcb?
	CALL	QDIRFCB1
	JP	NZ,OPENX0A	; no
	; Does sfcb exist?
	CALL	GETDTBA$8
	OR	A
	JP	NZ,OPENX0A	; no
	; Is sfcb password mode read or write?
	LD	A,(HL)
	AND	0C0H
	JP	Z,OPENX1A	; no
	; Does xfcb exist?
	CALL	XDCNT$EQ$DCNT
	CALL	GETXFCB
	JP	NZ,OPENX0B	; yes
	; no - set sfcb password mode to zero
	CALL	RESTORE$DIR$FCB
	RET	Z		; (error)
	; Does sfcb still exist?
	CALL	GETDTBA$8
	OR	A
	JP	NZ,OPENX1A	; no (error)
	; sfcb password mode = 0
	LD	(HL),A
	; update sfcb
	CALL	NOWRITE
	CALL	Z,SEEK$COPY
	JP	OPENX1A
OPENX0A:
	CALL	XDCNT$EQ$DCNT
	; Does xfcb exist?
	CALL	GETXFCB
	JP	Z,OPENX1	; no
OPENX0B:
	; yes - check password
	CALL	CMP$PW
	JP	Z,OPENX1
	CALL	CHK$PW$ERROR
	LD	A,(PW$MODE)
	AND	0C0H
	JP	Z,OPENX1
	AND	80H
	JP	NZ,PW$ERROR
	LD	A,080H
	LD	(XFCB$READ$ONLY),A
OPENX1:
	CALL	RESTORE$DIR$FCB
	RET	Z		; (error)
OPENX1A:
	CALL	SET$LSN

	IF MPM
	CALL	PACK$SDCNT
	; Is this file currently open?
	LD	B,3
	CALL	SEARCH$OLIST
	JP	Z,OPENX04
OPENX01:
	; no - is olist full?
	LD	HL,(FREE$ROOT)
	LD	A,L
	OR	H
	JP	NZ,OPENX03
	; yes - error
OPENX02:
	LD	A,11
	JP	SET$ARET
OPENX03:
	; Has process exceeded open file maximum?
	CALL	COUNT$OPENS
	SUB	(HL)
	JP	C,OPENX035
	; yes - error
OPENX034:
	LD	A,10
	JP	SET$ARET
OPENX035:
	; Create new olist element
	CALL	CREATE$OLIST$ITEM
	JP	OPENX08
OPENX04:
	; Do file attributes match?
	INC	HL
	INC	HL
	LD	A,(ATTRIBUTES)
	OR	(HL)
	CP	(HL)
	JP	NZ,OPENX06
	; yes - is open mode locked?
	AND	80H
	JP	NZ,OPENX07
	; no - has this file been opened by this process?
	LD	HL,(PRV$POS)
	LD	(CUR$POS),HL
	LD	B,5
	CALL	SEARCHN$LIST
	JP	NZ,OPENX01
OPENX05:
	; yes - increment open file count
	LD	DE,8
	ADD	HL,DE
	INC	(HL)
	JP	NZ,OPENX08
	; count overflow
	INC	HL
	INC	(HL)
	JP	OPENX08
OPENX06:
	; error - file opened by another process in imcompatible mode
	LD	A,5
	JP	SET$ARET
OPENX07:
	; Does this olist item belong to this process?
	DEC	HL
	DEC	HL
	PUSH	HL
	CALL	COMPARE$PDS
	POP	HL
	JP	NZ,OPENX06	; no - error
	JP	OPENX05		; yes
OPENX08:; Wopen ok
	; Was file opened in unlocked mode?
	LD	A,(ATTRIBUTES)
	AND	40H
	JP	Z,OPENX09	; no
	; yes - return .olist$item in ranrec field of fcb
	CALL	GET$RRA
	LD	DE,CUR$POS
	LD	C,2
	CALL	MOVE
OPENX09:
	CALL	SET$FCB$CKS$FLAG
	LD	A,(MAKE$FLAG)
	OR	A
	RET	NZ
	ENDIF
	ENDIF

	LD	C,01000000B
OPENX2:
	CALL	QSTAMP
	CALL	Z,STAMP1
	LD	DE,OLOG
	JP	SET$CDISK

FUNC16:
	; Close file
	CALL	RESELECT

	IF MPM
	CALL	GET$ATTS
	LD	(ATTRIBUTES),A
	LD	HL,CLOSE00
	PUSH	HL
	LD	A,0C9H
	LD	(CHECK$FCB4),A
	CALL	CHECK$FCB1
	POP	HL
	CALL	SET$SDCNT
	CALL	GETMODNUM
	AND	80H
	JP	NZ,CLOSE01
	CALL	CLOSE
	JP	CLOSE02
CLOSE00:
	LD	A,6
	JP	SET$ARET
CLOSE01:
	LD	A,0FFH
	LD	(DONT$CLOSE),A
	CALL	CLOSE1
CLOSE02:
	ELSE
	CALL	SET$LSN
	CALL	CHEK$FCB
	CALL	CLOSE
	ENDIF

	LD	A,(LRET)
	INC	A
	RET	Z

	JP	FLUSH		; Flush buffers

	IF MPM
	LD	A,(ATTRIBUTES)
	RLA
	RET	C
	CALL	PACK$SDCNT
	; Find olist item for this process & file
	LD	B,5
	CALL	SEARCH$OLIST
	JP	NZ,CLOSE03
	; Decrement open count
	PUSH	HL
	LD	DE,8
	ADD	HL,DE
	LD	A,(HL)
	SUB	1
	LD	(HL),A
	INC	HL
	LD	A,(HL)
	SBC	A,0
	LD	(HL),A
	DEC	HL
	; Is open count = 0ffffh
	CALL	TEST$FFFF
	POP	HL
	JP	NZ,CLOSE03
	; yes - remove file's olist entry
	LD	(FILE$ID),HL
	CALL	DELETE$ITEM
	CALL	RESET$CHKSUM$FCB
	; if unlocked file, remove file's locktbl entries
	CALL	TEST$UNLOCKED
	JP	Z,CLOSE03
	LD	HL,(FILE$ID)
	CALL	REMOVE$LOCKS
CLOSE03:
	RET

	ENDIF

FUNC17:
	; Search for first occurrence of a file
	EX	DE,HL
	XOR	A
CSEARCH:
	PUSH	AF
	LD	A,(HL)
	CP	'?'
	JP	NZ,CSEARCH1	; no reselect if ?
	CALL	CURSELECT
	CALL	NOSELECT0
	LD	C,0
	JP	CSEARCH3
CSEARCH1:
	CALL	GETEXTA
	LD	A,(HL)
	CP	'?'
	JP	Z,CSEARCH2
	CALL	CLR$EXT
	CALL	CLRMODNUM
CSEARCH2:
	CALL	RESELECTX
	LD	C,NAMLEN
CSEARCH3:
	POP	AF
	PUSH	AF
	JP	Z,CSEARCH4
	; dcnt = dcnt & 0fch
	LD	HL,(DCNT)
	PUSH	HL
	LD	A,0FCH
	AND	L
	LD	L,A
	LD	(DCNT),HL
	CALL	RDDIR
	POP	HL
	LD	(DCNT),HL
CSEARCH4:
	POP	AF
	LD	HL,DIR$TO$USER
	PUSH	HL
	JP	Z,SEARCH
	LD	A,(SEARCHL)
	LD	C,A
	CALL	SEARCHI
	JP	SEARCHN

FUNC18:
	; Search for next occurrence of a file name

	IF BANKED
	EX	DE,HL
	LD	(SEARCHA),HL
	ELSE
	LD	HL,(SEARCHA)
	LD	(INFO),HL
	ENDIF

	OR	1
	JP	CSEARCH

FUNC19:
	; Delete a file
;;;	call reselectx	;[JCE] DRI Patch 13
	CALL	PATCH$1E38
	JP	DELETE

FUNC20:
	; Read a file
	CALL	RESELECT
	CALL	CHECK$FCB
	JP	SEQDISKREAD

FUNC21:
	; Write a file
	CALL	RESELECT
	CALL	CHECK$FCB
	JP	SEQDISKWRITE

FUNC22:
	; Make a file

	IF BANKED
	CALL	GET$ATTS
	LD	(ATTRIBUTES),A
	ENDIF

	CALL	CLR$EXT
	CALL	CLRMODNUM	; fcb mod = 0
	CALL	RESELECTX

	IF MPM
	CALL	RESET$CHKSUM$FCB
	ENDIF

	CALL	CHECK$WILD
	CALL	SET$XDCNT	; Reset xdcnt for make

	IF MPM
	CALL	SET$SDCNT
	ENDIF

	CALL	OPEN		; Verify file does not already exist

	IF MPM
	CALL	RESET$CHKSUM$FCB
	ENDIF

	; Does dir fcb for fcb exist?
	; ora a required to reset carry
	CALL	END$OF$DIR
	OR	A
	JP	Z,MAKEA0	; no
	; Is dir$ext < fcb(ext)?
	CALL	GET$DIR$EXT
	CP	(HL)
	JP	NC,FILE$EXISTS	; no
MAKEA0:
	PUSH	AF		; carry set if dir fcb already exists

	IF MPM
	LD	A,(ATTRIBUTES)
	AND	80H
	RRCA
	JP	NZ,MAKEX00
	LD	A,80H
MAKEX00:
	LD	(MAKE$FLAG),A
	LD	A,(SDCNT+1)
	INC	A
	JP	Z,MAKEX01
	CALL	PACK$SDCNT
	LD	B,3
	CALL	SEARCH$OLIST
	JP	Z,MAKE$X02
MAKEX01:
	LD	HL,(FREE$ROOT)
	LD	A,L
	OR	H
	JP	Z,OPENX02
	JP	MAKEX03
MAKEX02:
	INC	HL
	INC	HL
	LD	A,(MAKEFLAG)
	AND	(HL)
	JP	Z,OPENX06
	DEC	HL
	DEC	HL
	CALL	COMPARE$PDS
	JP	Z,MAKEX03
	LD	A,(MAKEFLAG)
	RLA
	JP	C,OPENX06
MAKEX03:

	ENDIF

	IF BANKED
	; Is fcb 1st fcb for file?
	CALL	QDIRFCB1
	JP	Z,MAKEX04	; yes
	; no - does dir lbl require passwords?
	CALL	GET$DIR$MODE
	AND	80H
	JP	Z,MAKEX04
	; no - does xfcb exist with mode 1 or 2 password?
	CALL	GETXFCB
	JP	Z,MAKEX04
	; yes - check password
	CALL	CHK$XFCB$PASSWORD1
	JP	Z,MAKEX04
	; Verify password error
	CALL	CHK$PW$ERROR
	LD	A,(PW$MODE)
	AND	0C0H
	JP	NZ,PW$ERROR
MAKEX04:

	ENDIF

	; carry on stack indicates a make not required because
	; of extent folding
	POP	AF
	CALL	NC,MAKE

	IF MPM
	CALL	RESET$CHKSUM$FCB
	ENDIF

	; end$of$dir call either applies to above make or open call
	CALL	END$OF$DIR
	RET	Z		; Return if make unsuccessful

	IF NOT MPM
	CALL	SET$LSN
	ENDIF

	IF BANKED

	; Are passwords activated by dir lbl?
	CALL	GET$DIR$MODE
	AND	80H
	JP	Z,MAKE3A
	; Did user set password attribute?
	LD	A,(ATTRIBUTES)
	AND	40H
	JP	Z,MAKE3A
	; Is fcb file's 1st logical fcb?
	CALL	QDIRFCB1
	JP	NZ,MAKE3A
	; yes - does xfcb already exist for file
	CALL	XDCNT$EQ$DCNT
	CALL	GETXFCB
	JP	NZ,MAKE00	; yes
	; Attempt to make xfcb
	LD	A,0FFH
	LD	(MAKE$XFCB),A
	CALL	MAKE
	JP	NZ,MAKE00
	; xfcb make failed - delete fcb that was created above
	CALL	SEARCH$NAMLEN
	CALL	DELETE10
	JP	LRET$EQ$FF	; Return with a = 0ffh

MAKE00:
	CALL	INIT$XFCB	; Initialize xfcb
	; Get password mode from dma + 8
	EX	DE,HL
	LD	HL,(XDMAAD)
	LD	BC,8
	ADD	HL,BC
	EX	DE,HL
	LD	A,(DE)
	AND	0E0H
	JP	NZ,MAKE2
	LD	A,080H		; default password mode is read protect
MAKE2:
	LD	(PW$MODE),A
	; Set xfcb password mode field
	PUSH	AF
	CALL	GETXFCB1
	POP	AF
	LD	(HL),A
	; Set xfcb password and password checksum
	; Fix hash table and write xfcb
	CALL	SET$PW
	LD	(HL),B
	CALL	SDL3
	; Return to fcb
	CALL	RESTORE$DIR$FCB
	RET	Z
	; Does sfcb exist?
	LD	C,8
	CALL	GETDTBA
	OR	A
	JP	NZ,MAKE3A	; no
	; Place password mode in sfcb if sfcb exists
	LD	A,(PW$MODE)
	LD	(HL),A
	CALL	SEEK$COPY
	CALL	SET$LSN
	ENDIF

MAKE3A:
	LD	C,01010000B

	IF MPM
	CALL	OPENX2
	LD	A,(MAKE$FLAG)
	LD	(ATTRIBUTES),A
	AND	40H
	RLA
	LD	(HIGH$EXT),A
	LD	A,(SDCNT+1)
	INC	A
	JP	NZ,MAKEXX02
	CALL	SDCNT$EQ$XDCNT
	CALL	PACK$SDCNT
	JP	OPENX03
MAKEXX02:
	CALL	FIX$OLIST$ITEM
	JP	OPENX1
	JP	SET$FCB$CKS$FLAG
	ELSE
	CALL	OPENX2
	LD	C,00100000B
	CALL	QSTAMP
	RET	NZ
	CALL	STAMP2
	JP	SET$FILEWF
	ENDIF

FILE$EXISTS:
	LD	A,8
SET$ARET:
	LD	C,A
	LD	(ARET+1),A
	CALL	LRET$EQ$FF

	IF MPM
	CALL	TEST$ERRORMODE
	JP	NZ,GOBACK
	ELSE
	JP	GOERR1
	ENDIF

	IF MPM
	LD	A,C
	SUB	3
	LD	L,A
	LD	H,0
	ADD	HL,HL
	LD	DE,XERR$LIST
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	JP	REPORT$ERR
	ENDIF

FUNC23:
	; Rename a file
;;;	call reselectx	;[JCE] DRI Patch 13
	CALL	PATCH$1E38
	JP	RENAME

FUNC24:
	; Return the login vector
	LD	HL,(DLOG)
	JP	STHL$RET

FUNC25:
	; Return selected disk number
	LD	A,(SELDSK)
	JP	STA$RET

FUNC26:

	IF MPM
	; Save dma address in process descriptor
	LD	HL,(INFO)
INTRNLSETDMA:
	EX	DE,HL
	CALL	RLR
	LD	BC,DISKSETDMA
	ADD	HL,BC
	LD	(HL),E
	INC	HL
	LD	(HL),D
	ENDIF

	; Set the subsequent dma address to info
	EX	DE,HL
	LD	(DMAAD),HL	; dmaad = info
	JP	SETDATA		; to data dma address

FUNC27:
	; Return the login vector address
	CALL	CURSELECT
	LD	HL,(ALLOCA)
	JP	STHL$RET

	IF MPM

FUNC28:
	; Write protect current disk
	; first check for open files on disk
	LD	A,0FFH
	LD	(SET$RO$FLAG),A
	LD	A,(SELDSK)
	LD	C,A
	LD	HL,0001H
	CALL	HLROTL
	CALL	INTRNLDISKRESET
	JP	SET$RO
	ELSE

FUNC28  EQU	SET$RO ; Write protect current disk

	ENDIF

FUNC29:
	; Return r/o bit vector
	LD	HL,(RODSK)
	JP	STHL$RET

FUNC30:
	; Set file indicators
	CALL	CHECK$WILD
;;;	call reselectx	;[JCE] DRI Patch 13
	CALL	PATCH$1E38
	CALL	INDICATORS
	JP	COPY$DIRLOC	; lret=dirloc

FUNC31:
	; Return address of disk parameter block
	CALL	CURSELECT
	LD	HL,(DPBADDR)
STHL$RET:
	LD	(ARET),HL
	RET

FUNC32:
	; Set user code
	LD	A,(LINFO)
	CP	0FFH
	JP	NZ,SETUSRCODE
	; Interrogate user code instead
	LD	A,(USRCODE)
	JP	STA$RET		; lret=usrcode
SETUSRCODE:
	AND	0FH
	LD	(USRCODE),A

	IF MPM
	PUSH	AF
	CALL	RLR
	LD	BC,DISKSELECT
	ADD	HL,BC
	POP	BC
	LD	A,(HL)
	AND	0F0H
	OR	B
	LD	(HL),A
	ENDIF

	RET

FUNC33:
	; Random disk read operation
	CALL	RESELECT
	CALL	CHECK$FCB
	JP	RANDISKREAD	; to perform the disk read

FUNC34:
	; Random disk write operation
	CALL	RESELECT
	CALL	CHECK$FCB
	JP	RANDISKWRITE	; to perform the disk write

FUNC35:
	; Return file size (0-262,144)
	CALL	RESELECT
	JP	GETFILESIZE

FUNC36	EQU	SETRANDOM; Set random record

FUNC37:
	; Drive reset

	IF MPM
	CALL	DISKRESET
RESET$37:
	LD	HL,(INFO)
	ELSE
	EX	DE,HL
	ENDIF

RESET$37X:
	LD	A,L
	CPL
	LD	E,A
	LD	A,H
	CPL
	LD	HL,(DLOG)
	AND	H
	LD	D,A
	LD	A,L
	AND	E
	LD	E,A
	LD	HL,(RODSK)
	EX	DE,HL
	LD	(DLOG),HL

	IF MPM
	PUSH	HL
	CALL	HL$EQ$HL$AND$DE
	ELSE
	LD	A,L
	AND	E
	LD	L,A
	LD	A,H
	AND	D
	LD	H,A
	ENDIF

	LD	(RODSK),HL

	IF MPM
	POP	HL
	EX	DE,HL
	LD	HL,(RLOG)
	CALL	HL$EQ$HL$AND$DE
	LD	(RLOG),HL
	ENDIF

	; Force select call in next curselect
	LD	A,0FFH
	LD	(CURDSK),A
	RET

	IF MPM

FUNC38:
	; Access drive

	LD	HL,PACKED$DCNT
	LD	A,0FFH
	LD	(HL),A
	INC	HL
	LD	(HL),A
	INC	HL
	LD	(HL),A
	XOR	A
	EX	DE,HL
	LD	BC,16
ACC$DRV0:
	ADD	HL,HL
	ADC	A,B
	DEC	C
	JP	NZ,ACC$DRV0
	OR	A
	RET	Z
	LD	(MULTCNT),A
	DEC	A
	PUSH	AF
	CALL	ACC$DRV02
	POP	AF
	JP	OPENX02		; insufficient free lock list items
ACC$DRV02:
	CALL	CHECK$FREE
	POP	HL		; Discard return addr, free space exists
	CALL	COUNT$OPENS
	POP	BC
	ADD	A,B
	JP	C,OPENX034
	SUB	(HL)
	JP	NC,OPENX034	; openmax exceeded
	LD	HL,(INFO)
	LD	A,(CURDSK)
	PUSH	AF
	LD	A,16
ACC$DRV1:
	DEC	A
	ADD	HL,HL
	JP	C,ACC$DRV2
ACC$DRV15:
	OR	A
	JP	NZ,ACC$DRV1
	POP	AF
	LD	(CURDSK),A
	RET
ACC$DRV2:
	PUSH	AF
	PUSH	HL
	LD	(CURDSK),A
	CALL	CREATE$OLIST$ITEM
	POP	HL
	POP	AF
	JP	ACC$DRV15

FUNC39:
	; Free drive
	LD	HL,(OPEN$ROOT)
	LD	A,H
	OR	L
	RET	Z
	XOR	A
	LD	(INCR$PDCNT),A
	INC	A
	LD	(FREE$MODE),A
	LD	HL,(INFO)
	LD	A,H
	CP	L
	JP	NZ,FREE$DRV1
	INC	A
	JP	NZ,FREE$DRV1
	LD	(FREE$MODE),A
	CALL	FREE$FILES
	JP	FREE$DRV3
FREE$DRV1:
	LD	A,(CURDSK)
	PUSH	AF
	LD	A,16
FREE$DRV2:
	DEC	A
	ADD	HL,HL
	JP	C,FREE$DRV4
FREE$DRV25:
	OR	A
	JP	NZ,FREE$DRV2
	POP	AF
	LD	(CURDSK),A
FREE$DRV3:
	LD	A,(INCR$PDCNT)
	OR	A
	RET	Z
	LD	A,(PDCNT)
	JP	CHK$OLIST1
FREE$DRV4:
	PUSH	AF
	PUSH	HL
	LD	(CURDSK),A
	CALL	FREE$FILES
	POP	HL
	POP	AF
	JP	FREE$DRV25
	ELSE

FUNC38	EQU	FUNC$RET
FUNC39	EQU	FUNC$RET

	ENDIF

FUNC40	EQU	FUNC34	; Write random with zero fill

	IF MPM

FUNC41	EQU	FUNC$RET; Test & write
FUNC42:	; Record lock
	LD	A,0FFH
	LD	(LOCK$UNLOCK),A
	JP	LOCK
FUNC43:	; Record unlock
	XOR	A
	LD	(LOCK$UNLOCK),A
	JP	LOCK

	ELSE

FUNC42	EQU	FUNC$RET; Record lock
FUNC43	EQU	FUNC$RET	; Record unlock

	ENDIF

FUNC44:	; Set multi-sector count
	LD	A,E
	OR	A
	JP	Z,LRET$EQ$FF
	CP	129
	JP	NC,LRET$EQ$FF
	LD	(MULTCNT),A

	IF MPM
	LD	D,A
	CALL	RLR
	LD	BC,MULTCNT$OFF
	ADD	HL,BC
	LD	(HL),D
	ENDIF

	RET

FUNC45:	; Set bdos error mode

	IF MPM
	CALL	RLR
	LD	BC,PNAME+4
	ADD	HL,BC
	CALL	SET$PFLAG
	LD	(HL),A
	INC	HL
	CALL	SET$PFLAG
	LD	(HL),A
	RET

SET$PFLAG:
	LD	A,(HL)
	AND	7FH
	INC	E
	RET	NZ
	OR	80H
	RET
	ELSE
	LD	A,E
	LD	(ERRORMODE),A
	ENDIF

	RET

FUNC46:
	; Get free space
	; Perform temporary select of specified drive
	CALL	TMPSELECT
	LD	HL,(ALLOCA)
	EX	DE,HL		; de = alloc vector addr
	CALL	GET$NALBS	; Get # alloc blocks
	; hl = # of allocation vector bytes
	; Count # of true bits in allocation vector
	LD	BC,0		; bc = true bit accumulator
GSP1:	LD	A,(DE)
GSP2:	OR	A
	JP	Z,GSP4
GSP3:	RRA
	JP	NC,GSP3
	INC	BC
	JP	GSP2
GSP4:	INC	DE
	DEC	HL
	LD	A,L
	OR	H
	JP	NZ,GSP1
	; hl = 0 when allocation vector processed
	; Compute maxall + 1 - bc
	LD	HL,(MAXALL)
	INC	HL
	LD	A,L
	SUB	C
	LD	L,A
	LD	A,H
	SBC	A,B
	LD	H,A
	; hl = # of available blocks on drive
	LD	A,(BLKSHF)
	LD	C,A
	XOR	A
	CALL	SHL3BV
	; ahl = # of available sectors on drive
	; Store ahl in beginning of current dma
	EX	DE,HL
	LD	HL,(XDMAAD)
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	LD	(HL),A
	RET

	IF MPM

FUNC47	EQU	FUNC$RET

	ELSE

FUNC47:	; Chain to program
	LD	HL,CCP$FLGS
	LD	A,(HL)
	OR	80H
	LD	(HL),A
	INC	E
	JP	NZ,REBOOTX1
	LD	A,(HL)
	OR	40H
	LD	(HL),A
	JP	REBOOTX1
	ENDIF

FUNC48:	; Flush buffers
	CALL	CHECK$ALL$MEDIA
	CALL	FLUSHF
	CALL	DIOCOMP
FLUSH0:	; Function 98 entry point
	LD	HL,(DLOG)
	LD	A,16
FLUSH1:
	DEC	A
	ADD	HL,HL
	JP	NC,FLUSH5
	PUSH	AF
	PUSH	HL
	LD	E,A
	CALL	TMPSELECT	; seldsk = e
	LD	A,(FX)
	CP	48
	JP	Z,FLUSH3
	; Function 98 - reset allocation
	; Copy 2nd ALV over 1st ALV
	CALL	COPY$ALV
	IF BANKED
	JP	PATCH$2D3A	;[JCE] DRI Patch 13
	ELSE
	JP	FLUSH35
	ENDIF

FLUSH3:
	CALL	FLUSHX
	; if e = 0ffh then discard buffers after possible flush
	LD	A,(LINFO)
	INC	A
	JP	NZ,FLUSH4
FLUSH35:
	CALL	DISCARD$DATA
FLUSH4:
	POP	HL
	POP	AF
FLUSH5:
	OR	A
	JP	NZ,FLUSH1
	RET

FLUSH:
	CALL	FLUSHF
	CALL	DIOCOMP
FLUSHX:
	LD	A,(PHYMSK)
	OR	A
	RET	Z
	LD	A,4
	JP	DEBLOCK$DTA

	IF MPM

FUNC49	EQU	FUNC$RET

	ELSE

FUNC49:	; Get/Set system control block

	EX	DE,HL
	LD	A,(HL)
	CP	99
	RET	NC
	EX	DE,HL
	LD	HL,SCB
	ADD	A,L
	LD	L,A
	EX	DE,HL
	INC	HL
	LD	A,(HL)
	CP	0FEH
	JP	NC,FUNC49$SET
	EX	DE,HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	JP	STHL$RET
FUNC49$SET:
	LD	B,A
	INC	HL
	LD	A,(HL)
	LD	(DE),A
	INC	B
	RET	Z
	INC	HL
	INC	DE
	LD	A,(HL)
	LD	(DE),A
	RET
	ENDIF

	IF MPM

FUNC50	EQU	FUNC$RET

	ELSE

FUNC50:	; Direct bios call
	; de -> function (1 byte)
	;	a  value (1 byte)
	;	bc value (2 bytes)
	;	de value (2 bytes)
	;	hl value (2 bytes)

	LD	HL,FUNC50$RET
	PUSH	HL
	EX	DE,HL

	IF BANKED
	LD	A,(HL)
	CP	27
	RET	Z
	CP	12
	JP	NZ,DIRBIOS1
	LD	DE,DIRBIOS3
	PUSH	DE
DIRBIOS1:
	CP	9
	JP	NZ,DIRBIOS2
	LD	DE,DIRBIOS4
	PUSH	DE
DIRBIOS2:

	ENDIF

	PUSH	HL
	INC	HL
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	EX	(SP),HL
	LD	A,(HL)
	PUSH	HL
	LD	L,A
	ADD	A,A
	ADD	A,L

	LD	HL,BIOS

	ADD	A,L
	LD	L,A
	EX	(SP),HL
	INC	HL
	LD	A,(HL)
	POP	HL
	EX	(SP),HL
	RET

	IF BANKED

DIRBIOS3:
	LD	A,1
	JP	SETBNKF

DIRBIOS4:
	LD	A,L
	OR	H
	RET	Z
	EX	DE,HL
	LD	HL,10
	ADD	HL,DE
	LD	(HL),0		; Zero login sequence #
	LD	HL,(COMMONBASE)
	CALL	SUBDH
	EX	DE,HL
	RET	NC
	; Copy DPH to common memory
	EX	DE,HL
	LD	HL,(INFO)
	INC	HL
	PUSH	HL
	LD	BC,25
	CALL	MOVEF
	POP	HL
	RET
	ENDIF

FUNC50$RET:

	IF BANKED
	LD	(ARET),HL
	LD	B,A
	LD	HL,(INFO)
	LD	A,(HL)
	CP	9
	RET	Z
	CP	16
	RET	Z
	CP	20
	RET	Z
	CP	22
	RET	Z
	LD	A,B
	JP	STA$RET
	ELSE
	EX	DE,HL
	LD	HL,(ENTSP)
	LD	SP,HL
	EX	DE,HL
	RET
	ENDIF
	ENDIF

FUNC98	EQU	FLUSH0	; Reset Allocation

FUNC99:	; Truncate file
	CALL	RESELECTX
	CALL	CHECK$WILD

	IF BANKED
	CALL	CHK$PASSWORD
	CALL	NZ,CHK$PW$ERROR
	ENDIF

	LD	C,TRUE
	CALL	RSEEK
	JP	NZ,LRET$EQ$FF
	; compute dir$fcb size
	CALL	GETDPTRA
	LD	DE,RECCNT
	CALL	COMPUTE$RR	; cba = fcb size
	; Is random rec # >= dir$fcb size
	CALL	GET$RRA
	CALL	COMPARE$RR
	JP	C,LRET$EQ$FF	; yes ( > )
	OR	D
	JP	Z,LRET$EQ$FF	; yes ( = )
	; Perform truncate
	CALL	CHECK$RODIR	; may be r/o file
	CALL	WRDIR		; verify BIOS can write to disk
	CALL	UPDATE$STAMP	; Set update stamp
	CALL	SEARCH$EXTNUM
TRUNC1:
	JP	Z,COPY$DIRLOC
	; is dirfcb < fcb?
	CALL	COMPARE$MOD$EXT
	JP	C,TRUNC2	; yes
	; remove dirfcb blocks from allocation vector
	PUSH	AF
	LD	C,0
	CALL	SCANDM$AB
	POP	AF
	; is dirfcb = fcb?
	JP	Z,TRUNC3	; yes
	; delete dirfcb
	CALL	GETDPTRA
	LD	(HL),EMPTY
	CALL	FIX$HASH
TRUNC15:
	CALL	WRDIR
TRUNC2:
	CALL	SEARCHN
	JP	TRUNC1
TRUNC3:
	CALL	GETFCB
	CALL	DM$POSITION
	CALL	ZERO$DM
	; fcb(extnum) = dir$ext after blocks removed
	CALL	GET$DIR$EXT
	CP	(HL)
	LD	(HL),A
	PUSH	AF
	; fcb(rc) = fcb(cr) + 1
	CALL	GETFCBA
	LD	A,(HL)
	INC	A
	LD	(DE),A
	; rc = 0 or 128 if dir$ext < fcb(extnum)
	POP	AF
	EX	DE,HL
	CALL	NZ,SET$RC3
	; rc = 0 if no blocks remain in fcb
	LD	A,(DMINX)
	OR	A
	CALL	Z,SET$RC3
	LD	BC,11
	CALL	GET$FCB$ADDS
	EX	DE,HL
	; reset archive (t3') attribute bit
	LD	A,(HL)
	AND	7FH
	LD	(HL),A
	INC	HL
	INC	DE
	; dirfcb(extnum) = fcb(extnum)
	LD	A,(DE)
	LD	(HL),A
	; advance to .fcb(reccnt) & .dirfcb(reccnt)
	INC	HL
	LD	(HL),0
	INC	HL
	INC	HL
	INC	DE
	INC	DE
	INC	DE
	; dirfcb_rc+dskmap = fcb_rc+dskmap
	LD	C,17
	CALL	MOVE
	; restore non-erased blkidxs in allocation vector
	LD	C,1
	CALL	SCANDM$AB
	JP	TRUNC15

GET$FCB$ADDS:
	CALL	GETDPTRA
	ADD	HL,BC
	EX	DE,HL
	LD	HL,(INFO)
	ADD	HL,BC
	RET

COMPARE$MOD$EXT:
	LD	BC,MODNUM
	CALL	GET$FCB$ADDS
	LD	A,(HL)
	AND	3FH
	LD	B,A
	; compare dirfcb(modnum) to fcb(modnum)
	LD	A,(DE)
	CP	B
	RET	NZ		; dirfcb(modnum) ~= fcb(modnum)
	DEC	HL
	DEC	HL
	DEC	DE
	DEC	DE
	; compare dirfcb(extnum) to fcb(extnum)
	LD	A,(DE)
	LD	C,(HL)
	CALL	COMPEXT
	RET	Z		; dirfcb(extnum) = fcb(extnum)
	LD	A,(DE)
	CP	(HL)
	RET

ZERO$DM:
	INC	A
	LD	HL,SINGLE
	INC	(HL)
	JP	Z,ZERO$DM1
	ADD	A,A
ZERO$DM1:
	DEC	(HL)
	CALL	GETDMA
	LD	C,A
	LD	B,0
	ADD	HL,BC
	LD	A,16
ZERO$DM2:
	CP	C
	RET	Z
	LD	(HL),B
	INC	HL
	INC	C
	JP	ZERO$DM2

	IF BANKED

FUNC100:; Set directory label
	; de -> .fcb
	;	drive location
	;	name & type fields user's discretion
	;	extent field definition
	;	bit 1 (80h): enable passwords on drive
	;	bit 2 (40h): enable file access
	;	bit 3 (20h): enable file update stamping
	;	bit 4 (10h): enable file create stamping
	;	bit 8 (01h): assign new password to dir lbl
	CALL	RESELECTX
	LD	HL,(INFO)
	LD	(HL),21H
	LD	C,1
	CALL	SEARCH
	JP	NZ,SDL0
	CALL	GETEXTA
	LD	A,(HL)
	AND	01110000B
	JP	NZ,LRET$EQ$FF
SDL0:
	; Does dir lbl exist on drive?
	LD	HL,(INFO)
	LD	(HL),20H
	LD	C,1
	CALL	SET$XDCNT
	CALL	SEARCH
	JP	NZ,SDL1
	; no - make one
	LD	A,0FFH
	LD	(MAKE$XFCB),A
	CALL	MAKE
	RET	Z		; no dir space
	CALL	INIT$XFCB
	LD	BC,24
	CALL	STAMP5
	CALL	STAMP1
SDL1:
	; Update date & time stamp
	LD	BC,28
	CALL	STAMP5
	CALL	STAMP2
	; Verify password - new dir lbl falls through
	CALL	CHK$XFCB$PASSWORD
	JP	NZ,PW$ERROR
	LD	BC,0
	CALL	INIT$XFCB0
	; Set dir lbl dta in extent field
	LD	A,(DE)
	OR	1H
	LD	(HL),A
	; Low bit of dir lbl data set to indicate dir lbl exists
	; Update drive's dir lbl vector element
	PUSH	HL
	LD	HL,(DRVLBLA)
	LD	(HL),A
	POP	HL
SDL2:
	; Assign new password to dir lbl or xfcb?
	LD	A,(DE)
	AND	1
	JP	Z,SDL3
	; yes - new password field is in 2nd 8 bytes of dma
	LD	DE,8
	CALL	ADJUST$DMAAD
	CALL	SET$PW
	LD	(HL),B
	LD	DE,-8
	CALL	ADJUST$DMAAD
SDL3:
	CALL	FIX$HASH
	JP	SEEK$COPY
	ELSE

FUNC100 EQU	LRET$EQ$FF
FUNC103 EQU	LRET$EQ$FF

	ENDIF

FUNC101:
	; Return directory label data
	; Perform temporary select of specified drive
	CALL	TMPSELECT
	CALL	GET$DIR$MODE
	JP	STA$RET

FUNC102:
	; Read file xfcb
	CALL	RESELECTX
	CALL	CHECK$WILD
	CALL	ZERO$EXT$MOD
	CALL	SEARCH$NAMLEN
	RET	Z
	CALL	GETDMA
	LD	BC,8
	CALL	ZERO
	PUSH	HL
	LD	C,0
	CALL	GETDTBA
	OR	A
	JP	NZ,RXFCB2
	POP	DE
	EX	DE,HL
	LD	C,8

	IF BANKED
	CALL	MOVE
	LD	A,(DE)
	JP	RXFCB3
	ELSE
	JP	MOVE
	ENDIF

RXFCB2:
	POP	HL
	LD	BC,8

	IF BANKED
	CALL	ZERO
	CALL	GETXFCB
	RET	Z
	LD	A,(HL)
RXFCB3:
	CALL	GETEXTA
	LD	(HL),A
	RET
	ELSE
	JP	ZERO
	ENDIF

	IF BANKED

FUNC103:
	; Write or update file xfcb
	CALL	RESELECTX
	; Are passwords enabled in directory label?
	CALL	GET$DIR$MODE
	RLA
	JP	NC,LRET$EQ$FF	; no
	CALL	CHECK$WILD
	; Save .fcb(ext) & ext
	CALL	GETEXTA
	LD	B,(HL)
	PUSH	HL
	PUSH	BC
	; Set extent & mod to zero
	CALL	ZERO$EXT$MOD
	; Does file's 1st fcb exist in directory?
	CALL	SEARCH$NAMLEN
	; Restore extent
	POP	BC
	POP	HL
	LD	(HL),B
	RET	Z		; no
	CALL	SET$XDCNT
	; Does sfcb exist?
	CALL	GETDTBA$8
	OR	A
	JP	Z,WXFCB5	; yes
	; No - Does xfcb exist?
	CALL	GETXFCB
	JP	NZ,WXFCB1	; yes
WXFCB0:
	; no - does file exist in directory?
	LD	A,0FFH
	LD	(MAKE$XFCB),A
	CALL	SEARCH$EXTNUM
	RET	Z
	; yes - attempt to make xfcb for file
	CALL	MAKE
	RET	Z		; no dir space
	; Initialize xfcb
	CALL	INIT$XFCB
WXFCB1:
	; Verify password - new xfcb falls through
	CALL	CHK$XFCB$PASSWORD
	JP	NZ,PW$ERROR
	; Set xfcb options data
	PUSH	HL
	CALL	GETEXTA
	POP	DE
	EX	DE,HL
	LD	A,(HL)
	OR	A
	JP	NZ,WXFCB2
	LD	A,(DE)
	AND	1
	JP	NZ,WXFCB2
	CALL	SDL3
	JP	WXFCB4
WXFCB2:
	LD	A,(DE)
	AND	0E0H
	JP	NZ,WXFCB3
	LD	A,80H
WXFCB3:
	LD	(HL),A
	CALL	SDL2
WXFCB4:
	CALL	GETXFCB1
	DEC	A
	LD	(PW$MODE),A
	CALL	ZERO$EXT$MOD
	CALL	SEARCH$NAMLEN
	RET	Z
	CALL	GETDTBA$8
	OR	A
	RET	NZ
	LD	A,(PW$MODE)
	LD	(HL),A
	JP	SEEK$COPY
WXFCB5:
	; Take sfcb's password mode over xfcb's mode
	LD	A,(HL)
	PUSH	AF
	CALL	GETXFCB
	; does xfcb exist?
	POP	BC
	JP	Z,WXFCB0	; no
	; Set xfcb's password mode to sfcb's mode
	LD	(HL),B
	JP	WXFCB1

	ENDIF

FUNC104:; Set current date and time

	IF MPM
	CALL	GET$STAMP$ADD
	ELSE
	LD	HL,STAMP
	ENDIF
	CALL	COPY$STAMP
	LD	(HL),0
	LD	C,0FFH
	JP	TIMEF

FUNC105:; Get current date and time



	IF MPM
	CALL	GET$STAMP$ADD
	ELSE
	LD	C,0
	CALL	TIMEF
	LD	HL,STAMP
	ENDIF

	EX	DE,HL
	CALL	COPY$STAMP
	LD	A,(DE)
	JP	STA$RET

COPY$STAMP:
	LD	C,4
	JP	MOVE		; ret

	IF MPM

GET$STAMP$ADD:
	CALL	RLRADR
	LD	BC,-5
	ADD	HL,BC
	RET
	ENDIF

	IF BANKED

FUNC106:; Set default password

	IF MPM
	CALL	GET$DF$PWA
	INC	A
	RET	Z
	LD	BC,7
	ADD	HL,BC
	ELSE
	LD	HL,DF$PASSWORD+7
	ENDIF
	EX	DE,HL
	LD	BC,8
	PUSH	HL
	JP	SET$PW0
	ELSE

FUNC106 EQU	FUNC$RET

	ENDIF

FUNC107:; Return serial number

	IF MPM
	LD	HL,(SYSDAT)
	LD	L,181
	ELSE
	LD	HL,SERIAL
	ENDIF

	EX	DE,HL
	LD	C,6
	JP	MOVE

FUNC108:; Get/Set program return code

	; Is de = 0ffffh?
	LD	A,D
	AND	E
	INC	A
	LD	HL,(CLP$ERRCDE)
	JP	Z,STHL$RET	; yes - return return code
	EX	DE,HL
	LD	(CLP$ERRCDE),HL
	RET			; no - set return code

GOBACK0:
	LD	HL,0FFFFH
	LD	(ARET),HL
GOBACK:
	; Arrive here at end of processing to return to user
	LD	A,(RESEL)
	OR	A
	JP	Z,RETMON

	IF MPM
	LD	A,(COMP$FCB$CKS)
	OR	A
	CALL	NZ,SET$CHKSUM$FCB
	ENDIF

	LD	HL,(INFO)
	LD	A,(FCBDSK)
	LD	(HL),A		; fcb(0)=fcbdsk
	IF BANKED

	; fcb(7) = fcb(7) | xfcb$read$only
	LD	DE,7
	ADD	HL,DE
	LD	A,(XFCB$READ$ONLY)
	OR	(HL)
	LD	(HL),A

	ENDIF
	IF MPM
	; if high$ext = 60h then fcb(8) = fcb(8) | 80h
	;		    else fcb(ext) = fcb(ext) | high$ext

	CALL	GETEXTA
	LD	A,(HIGH$EXT)
	CP	60H
	JP	NZ,GOBACK2
	LD	DE,-4
	ADD	HL,DE
	LD	A,80H
GOBACK2:
	OR	(HL)
	LD	(HL),A
	ELSE
	; fcb(8) = fcb(8) | high$ext
	IF BANKED
	INC	HL
	ELSE
	LD	DE,8
	ADD	HL,DE
	ENDIF
	LD	A,(HIGH$EXT)
	OR	(HL)
	LD	(HL),A
	ENDIF

;	return from the disk monitor

RETMON:
	LD	HL,(ENTSP)
	LD	SP,HL
	LD	HL,(ARET)
	LD	A,L
	LD	B,H
	RET
;
;	data areas
;
EFCB:		DEFB	EMPTY		; 0e5=available dir entry
RODSK:		DEFW	0		; read only disk vector
DLOG:		DEFW	0		; logged-in disks

	IF MPM

RLOG:		DEFW	0		; removeable logged-in disks
TLOG:		DEFW	0		; removeable disk test login vector
NTLOG:		DEFW	0		; new tlog vector
REM$DRV:	DEFS	LBYTE		; curdsk removable drive switch
	; 0 = permanent drive, 1 = removable drive
	ENDIF

	IF NOT BANKED

XDMAAD	EQU	$
CURDMA:		DEFS	LWORD		; current dma address

	ENDIF

	IF NOT MPM

BUFFA:		DEFS	LWORD	; pointer to directory dma address

	ENDIF

;
;	curtrka - alloca are set upon disk select
;	(data must be adjacent, do not insert variables)
;	(address of translate vector, not used)
CDRMAXA:	DEFS	LWORD		; pointer to cur dir max value (2 bytes)
CURTRKA:	DEFS	LWORD		; current track address (2)
CURRECA:	DEFS	LWORD		; current record address (3)
DRVLBLA:	DEFS	LWORD		; current drive label byte address (1)
LSN$ADD:	DEFS	LWORD		; login sequence # address (1)
	; +1 -> bios media change flag (1)
DPBADDR:	DEFS	LWORD		; current disk parameter block address
CHECKA:		DEFS	LWORD		; current checksum vector address
ALLOCA:		DEFS	LWORD		; current allocation vector address
DIRBCBA:	DEFS	LWORD		; dir bcb list head
DTABCBA:	DEFS	LWORD		; data bcb list head
HASHTBLA:
		DEFS	LWORD		; directory hash table address
		DEFS	LBYTE		; directory hash table bank

ADDLIST EQU	$-DPBADDR	; address list size

;
;	       buffer control block format
;
; bcb format : drv(1) || rec(3) || pend(1) || sequence(1) ||
;	       0	 1	   4	      5
;
;	       track(2) || sector(2) || buffer$add(2) ||
;	       6	   8		10
;
;	       bank(1) || link(2)
;	       12	  13
;

;	sectpt - offset obtained from disk parm block at dpbaddr
;	(data must be adjacent, do not insert variables)
SECTPT:		DEFS	LWORD		; sectors per track
BLKSHF:		DEFS	LBYTE		; block shift factor
BLKMSK:		DEFS	LBYTE		; block mask
EXTMSK:		DEFS	LBYTE		; extent mask
MAXALL:		DEFS	LWORD		; maximum allocation number
DIRMAX:		DEFS	LWORD		; largest directory number
DIRBLK:		DEFS	LWORD		; reserved allocation bits for directory
CHKSIZ:		DEFS	LWORD		; size of checksum vector
OFFSET:		DEFS	LWORD		; offset tracks at beginning
PHYSHF:		DEFS	LBYTE		; physical record shift
PHYMSK:		DEFS	LBYTE		; physical record mask
DPBLIST EQU	$-SECTPT	; size of area
;
;	local variables
;
DREC:		DEFS	LWORD		; directory record number
BLK$OFF:	DEFS	LBYTE		; record offset within block
LAST$OFF: 	DEFS	LBYTE		; last offset within new block
LASTDRIVE: 	DEFS	LBYTE	; drive of last new block
LAST$BLOCK: 	DEFS	LWORD	; last new block

; The following two variables are initialized as a pair on entry

DIR$CNT:	DEFS	LBYTE		; direct i/o count
MULT$NUM: 	DEFS	LBYTE		; multi-sector number

TRANV:		DEFS	LWORD	; address of translate vector
LOCK$UNLOCK:
MAKE$FLAG:
RMF:		DEFS	LBYTE		; read mode flag for open$reel
INCR$PDCNT:
DIRLOC:		DEFS	LBYTE		; directory flag in rename, etc.
FREE$MODE:
LINFO:		DEFS	LBYTE		; low(info)
DMINX:		DEFS	LBYTE		; local for diskwrite

	IF MPM

SEARCHL:	DEFS	LBYTE		; search length

	ENDIF
	IF BANKED

SEARCHA:	DEFS	LWORD		; search address

	ENDIF

	IF BANKED

SAVE$XFCB:
		DEFS	LBYTE		; search xfcb save flag

	ENDIF

SINGLE:		DEFS	LBYTE	; set true if single byte allocation map

	IF MPM

SELDSK:		DEFS	LBYTE	; currently selected disk

	ENDIF

SELDSK:		DEFS	LBYTE	; disk on entry to bdos
RCOUNT:		DEFS	LBYTE		; record count in current fcb
EXTVAL:		DEFS	LBYTE		; extent number and extmsk
SAVE$MOD:
		DEFS	LBYTE		; open$reel module save field

VRECORD:	DEFS	LBYTE		; current virtual record

	IF NOT MPM

CURDSK:		DEFB	0FFH	; current disk

	ENDIF

ADRIVE:		DEFB	0FFH	; current blocking/deblocking disk
ARECORD:	DEFS	LWORD		; current actual record
		DEFS	LBYTE

SAVE$RANR: 	DEFS	3	; random record save area
ARECORD1: 	DEFS	LWORD		; current actual block# * blkmsk
ATTRIBUTES: 	DEFS	LBYTE	; make attribute hold area
READF$SW: 	DEFS	LBYTE		; BIOS read/write switch

;******** following variable order critical *****************

	IF MPM

MULTCNT: 	DEFS	LBYTE	; multi-sector count
PDCNT:		DEFS	LBYTE		; process descriptor count

	ENDIF

HIGH$EXT: 	DEFS	LBYTE	; fcb high ext bits

	IF BANKED

XFCB$READ$ONLY: DEFS	LBYTE	; xfcb read only flag

	ENDIF
	IF MPM

CURDSK:		DEFB	0FFH	;current disk
PACKED$DCNT: 	DEFS	3	;
PDADDR:		DEFS	LWORD		;
;************************************************************
CUR$POS:	DEFS	LWORD		;
PRV$POS:	DEFS	LWORD		;
SDCNT:		DEFS	LWORD		;
SDBLK:		DEFS	LWORD		;
SDCNT0:		DEFS	LWORD		;
SDBLK0:		DEFS	LWORD		;
DONT$CLOSE: 	DEFS	LBYTE	;
OPEN$CNT: ; mp/m temp variable for open
LOCK$CNT: 	DEFS	LWORD		; mp/m temp variable for lock
FILE$ID:	DEFS	LWORD		; mp/m temp variable for lock
DELETED$FILES: 	DEFS	LBYTE
LOCK$SHELL:	DEFS	LBYTE
LOCK$SP:	DEFS	LWORD
SET$RO$FLAG: 	DEFS	LBYTE
CHECK$DISK: 	DEFS	LBYTE
FLUSHED:	DEFS	LBYTE
FCB$CKS$VALID:	DEFS	LBYTE
;				mp/m variables	*

	ENDIF

;	local variables for directory access
DPTR:		DEFS	LBYTE		; directory pointer 0,1,2,3

SAVE$HASH: 	DEFS	4	; hash code save area

	IF BANKED

COPY$CR$INIT: 	DEFS	LBYTE	; copy$cr$only initialization value

	ELSE

HASHMX:		DEFS	LWORD	; cdrmax or dirmax
XDCNT:		DEFS	LWORD		; empty directory dcnt

	ENDIF

	IF MPM

XDCNT:		DEFS	LWORD	; empty directory dcnt
XDBLK:		DEFS	LWORD		; empty directory block
DCNT:		DEFS	LWORD		; directory counter 0,1,...,dirmax
DBLK:		DEFS	LWORD		; directory block index

	ENDIF

SEARCH$USER0: 	DEFS	LBYTE	; search user 0 for file (open)

USER0PASS: 	DEFS	LBYTE	; search user 0 pass flag

FCBDSK:		DEFS	LBYTE	; disk named in fcb

	IF MPM

MAKE$XFCB: 	DEFS	1
FIND$XFCB: 	DEFS	1

	ENDIF

LOG$FXS:	DEFB	15,16,17,19,22,23,30,35,99,100,102,103,0
RW$FXS:		DEFB	20,21,33,34,40,41,0
SC$FXS:		DEFB	16,18,0

	IF MPM

COMP$FCB$CKS: 	DEFS	LBYTE	; compute fcb checksum flag

	ENDIF
	IF BANKED

PW$FCB:		DEFS	12	;1 |
		DEFB	0		;2 |
PW$MODE:	DEFB	0		;3 |- Order critical
		DEFB	0		;4 |
		DEFB	0		;5 |

DF$PASSWORD:	 DEFS	8

	IF MPM
		DEFS	120
	ENDIF
	ENDIF

PHY$OFF:	DEFS	LBYTE
CURBCBA:	DEFS	LWORD

	IF BANKED

LASTBCBA: 	DEFS	LWORD
ROOTBCBA: 	DEFS	LWORD
EMPTYBCBA: 	DEFS	LWORD
SEQBCBA:	DEFS	LWORD
BUFFER$BANK: 	DEFS	LBYTE

	ENDIF

TRACK:		DEFS	LWORD
SECTOR:		DEFS	LWORD

;	**************************
;	Blocking/Deblocking Module
;	**************************

DEBLOCK$DTA:
	LD	HL,(DTABCBA)

	IF BANKED
	CP	4
	JP	NZ,DEBLOCK
DEBLOCK$FLUSH:
	; de = addr of 1st bcb
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	; Search for dirty bcb with lowest track #
	LD	HL,0FFFFH
	LD	(TRACK),HL
	EX	DE,HL
DEBLOCK$FLUSH1:
	; Does current drive own bcb?
	LD	A,(ADRIVE)
	CP	(HL)
	JP	NZ,DEBLOCK$FLUSH2;no
	; Is bcb's buffer pending?
	EX	DE,HL
	LD	HL,4
	ADD	HL,DE
	LD	A,(HL)
	EX	DE,HL
	INC	A
	JP	NZ,DEBLOCK$FLUSH2; no
	; Is bcb(6) < track?
	PUSH	HL
	INC	DE
	INC	DE
	EX	DE,HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	; Subdh computes hl = de - hl
	LD	HL,(TRACK)
	CALL	SUBDH
	POP	HL
	JP	NC,DEBLOCK$FLUSH2; no
	; yes - track = bcb(6) , sector = addr(bcb)
	EX	DE,HL
	LD	(TRACK),HL
	EX	DE,HL
	LD	(SECTOR),HL
DEBLOCK$FLUSH2:
	; Is this the last bcb?
	CALL	GET$NEXT$BCBA
	JP	NZ,DEBLOCK$FLUSH1; no - hl = addr of next bcb
	; Does track = ffff?
	LD	HL,TRACK
	CALL	TEST$FFFF
	RET	Z		; yes - no bcb to flush
	; Flush bcb located by sector
	LD	HL,(SECTOR)
	XOR	A
	LD	A,4
	CALL	DEBLOCK
	LD	HL,(DTABCBA)
	JP	DEBLOCK$FLUSH	; Repeat until no bcb's to flush
	ENDIF

DEBLOCK:

	; BDOS Blocking/Deblocking routine
	; a = 1 -> read command
	; a = 2 -> write command
	; a = 3 -> locate command
	; a = 4 -> flush command
	; a = 5 -> directory update

	PUSH	AF		; Save z flag and deblock fx

	; phy$off = low(arecord) & phymsk
	; low(arecord) = low(arecord) & ~phymsk
	CALL	DEBLOCK8
	LD	A,(ARECORD)
	LD	E,A
	AND	B
	LD	(PHY$OFF),A
	LD	A,E
	AND	C
	LD	(ARECORD),A

	IF BANKED
	POP	AF
	PUSH	AF
	CALL	NZ,GET$BCBA
	ENDIF

	LD	(CURBCBA),HL
	CALL	GETBUFFA
	LD	(CURDMA),HL
	; hl = curbcba, de = .adrive, c = 4
	CALL	DEBLOCK9
	; Is BCB discarded?
	LD	A,(HL)
	INC	A
	JP	Z,DEBLOCK2	; yes
	; Is command flush?
	POP	AF
	PUSH	AF
	CP	4
	JP	NC,DEBLOCK1	; yes
	; Is referenced physical record already in buffer?

;;;	call compare	;[JCE] DRI patch 7
	CALL	PATCH$1E0C

	JP	Z,DEBLOCK45	; yes
	XOR	A
DEBLOCK1:
	; Does buffer contain an updated record?
	CALL	DEBLOCK10
	CP	5
	JP	Z,DEBLOCK15
	LD	A,(HL)
	OR	A
	JP	Z,DEBLOCK2	; no
DEBLOCK15:
	; Reset record pending flag
	LD	(HL),0
	; Save arecord
	LD	HL,(ARECORD)
	PUSH	HL
	LD	A,(ARECORD+2)
	PUSH	AF
	; Flush physical record buffer
	CALL	DEBLOCK9
	EX	DE,HL
	CALL	MOVE
	; Select drive to be flushed
	LD	HL,CURDSK
	LD	A,(ADRIVE)
	CP	(HL)
	CALL	NZ,DISK$SELECT1
	; Write record if drive logged-in
	LD	A,1
	CALL	Z,DEBLOCK$IO
	; Restore arecord
	POP	BC
	POP	DE
	CALL	SET$ARECORD
	; Restore selected drive
	CALL	CURSELECT
DEBLOCK2:
	; Is deblock command flush | dir write?
	POP	AF
	CP	4
	RET	NC		; yes - return
	; Is deblock command write?
	PUSH	AF
	CP	2
	JP	NZ,DEBLOCK25	; no
	; Is blk$off < last$off
	LD	HL,LAST$OFF
	LD	A,(BLK$OFF)
	CP	(HL)
	JP	NC,DEBLOCK3	; no
DEBLOCK25:
	; Discard BCB on read operations in case
	; I/O error occurs
;;;	lhld curbcba		;[JCE] DRI Patch 7
	CALL	PATCH$1E1C
	LD	(HL),0FFH
	; Read physical record buffer
	LD	A,2
	JP	DEBLOCK35
DEBLOCK3:
	; last$off = blk$off + 1
	INC	A
	LD	(HL),A
	; Place track & sector in bcb
	XOR	A
DEBLOCK35:
	CALL	DEBLOCK$IO
DEBLOCK4:
	CALL	DEBLOCK9	; phypfx = adrive || arecord
	CALL	MOVE
	LD	(HL),0		; zero pending flag

	IF BANKED
	; Zero logical record sequence
	INC	HL
	CALL	SET$BCB$SEQ
	ENDIF

DEBLOCK45:
	; recadd = phybuffa + phy$off*80h
	LD	A,(PHY$OFF)
	INC	A
	LD	DE,80H
	LD	HL,0FF80H
DEBLOCK5:
	ADD	HL,DE
	DEC	A
	JP	NZ,DEBLOCK5
	EX	DE,HL
	LD	HL,(CURDMA)
	ADD	HL,DE
	; If deblock command = locate then buffa = recadd; return
	POP	AF
	CP	3
	JP	NZ,DEBLOCK6
	LD	(BUFFA),HL
	RET
DEBLOCK6:
	EX	DE,HL
	LD	HL,(DMAAD)
	LD	BC,80H
	; If deblock command = read
	CP	1

	IF BANKED
	JP	NZ,DEBLOCK7
	; then move to tpa
	LD	A,(COMMONBASE+1)
	DEC	A
	CP	D
	JP	C,MOVE$TPA
	LD	A,(BUFFER$BANK)
	LD	C,A
	LD	B,1
	CALL	DEBLOCK12
	LD	BC,80H
	JP	MOVE$TPA
DEBLOCK7:

	ELSE
	JP	Z,MOVE$TPA	; then move to dma
	ENDIF

	; else move from dma
	EX	DE,HL

	IF BANKED
	LD	A,(COMMONBASE+1)
	DEC	A
	CP	H
	JP	C,DEBLOCK75
	LD	A,(BUFFER$BANK)
	LD	B,A
	LD	C,1
	CALL	DEBLOCK12
	LD	BC,80H
DEBLOCK75:

	ENDIF

	CALL	MOVE$TPA
	; Set physical record pending flag for write command
	CALL	DEBLOCK10
	LD	(HL),0FFH
	RET

DEBLOCK8:
	LD	A,(PHYMSK)
	LD	B,A
	CPL
	LD	C,A
	RET

DEBLOCK9:
	LD	HL,(CURBCBA)
	LD	DE,ADRIVE
	LD	C,4
	RET

DEBLOCK10:
	LD	DE,4
DEBLOCK11:
	LD	HL,(CURBCBA)
	ADD	HL,DE
	RET

	IF BANKED

DEBLOCK12:
	PUSH	HL
	PUSH	DE
	CALL	XMOVEF
	POP	DE
	POP	HL
	RET
	ENDIF

DEBLOCK$IO:
	; a = 0 -> seek only
	; a = 1 -> write
	; a = 2 -> read
	PUSH	AF
	CALL	SEEK

	IF BANKED
	LD	A,(BUFFER$BANK)
	CALL	SETBNKF
	ENDIF

	LD	C,1
	POP	AF
	DEC	A
	JP	Z,WRBUFF
	CALL	P,RDBUFF
	; Move track & sector to bcb
	CALL	DEBLOCK10
	INC	HL
	INC	HL
	LD	DE,TRACK
	LD	C,4
	JP	MOVE

	IF BANKED

GET$BCBA:
;;;	shld rootbcba	;[JCE] DRI Patch 13
	CALL	PATCH$2D30
	LD	DE,-13
	ADD	HL,DE
	LD	(LASTBCBA),HL
	CALL	GET$NEXT$BCBA
	PUSH	HL
	; Is there only 1 bcb in list?
	CALL	GET$NEXT$BCBA
	POP	HL
	RET	Z		; yes - return
	EX	DE,HL
	LD	HL,0
	LD	(EMPTYBCBA),HL
	LD	(SEQBCBA),HL
	EX	DE,HL
GET$BCB1:
	; Does bcb contain requested record?
	LD	(CURBCBA),HL
	CALL	DEBLOCK9
	CALL	COMPARE
	JP	Z,GET$BCB4	; yes
	; Is bcb discarded?
	LD	HL,(CURBCBA)
	LD	A,(HL)
	INC	A
	JP	NZ,GET$BCB11	; no
	EX	DE,HL
	LD	HL,(LASTBCBA)
	LD	(EMPTYBCBA),HL
	JP	GET$BCB14
GET$BCB11:
	; Does bcb contain record from current disk?
	LD	A,(ADRIVE)
	CP	(HL)
	JP	NZ,GET$BCB15	; no
	EX	DE,HL
	LD	HL,5
	ADD	HL,DE
	LD	A,(PHYMSK)
	; Is phymsk = 0?
	OR	A
	JP	Z,GET$BCB14	; yes
	; Does bcb(5) [bcb sequence] = phymsk?
	CP	(HL)
	JP	NZ,GET$BCB14	; no
;;;	lhld seqbcba	;[JCE] DRI Patch 13
;;;	mov a,l
;;;	ora h
	LD	A,(PATCH$2D39)
	OR	A
	NOP
	JP	NZ,GET$BCB14
	LD	HL,(LASTBCBA)
	LD	(SEQBCBA),HL
GET$BCB14:
	EX	DE,HL
GET$BCB15:
	; Advance to next bcb - list exhausted?
	PUSH	HL
	CALL	GET$NEXT$BCBA
	POP	DE
	JP	Z,GET$BCB2	; yes
	EX	DE,HL
	LD	(LASTBCBA),HL
	EX	DE,HL
	JP	GET$BCB1
GET$BCB2:
	; Matching bcb not found
	; Was a sequentially accessed bcb encountered?
;;;	lhld seqbcba	;[JCE] DRI Patch 13
	LD	HL,(EMPTYBCBA)

	LD	A,L
	OR	H
	JP	NZ,GET$BCB25	; yes
	; Was a discarded bcb encountered?
;;;	lhld emptybcba	;[JCE] DRI Patch 13
	LD	HL,(SEQBCBA)

	LD	A,L
	OR	H
	JP	Z,GET$BCB3	; no
GET$BCB25:
	LD	(LASTBCBA),HL
GET$BCB3:
	; Insert selected bcb at head of list
	LD	HL,(LASTBCBA)
	CALL	GET$NEXT$BCBA
	LD	(CURBCBA),HL
	CALL	GET$NEXT$BCBA
	EX	DE,HL
	CALL	LAST$BCB$LINKS$DE
	LD	HL,(ROOTBCBA)
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	HL,(CURBCBA)
	LD	BC,13
	ADD	HL,BC
	LD	(HL),E
	INC	HL
	LD	(HL),D
	LD	HL,(CURBCBA)
	EX	DE,HL
	LD	HL,(ROOTBCBA)
	LD	(HL),E
	INC	HL
	LD	(HL),D
	EX	DE,HL
	RET
GET$BCB4:
	; BCB matched arecord
	LD	HL,(CURBCBA)
	LD	DE,5
	ADD	HL,DE
	; Does bcb(5) = phy$off?
	LD	A,(PHY$OFF)
	CP	(HL)
	JP	Z,GET$BCB5	; yes
	; Does bcb(5) + 1 = phy$off?
	INC	(HL)
	CP	(HL)
	JP	Z,GET$BCB5	; yes
	CALL	SET$BCB$SEQ
GET$BCB5:
	; Is bcb at head of list?
	LD	HL,(CURBCBA)
	EX	DE,HL
	LD	HL,(ROOTBCBA)
	LD	A,(HL)
	INC	HL
	LD	L,(HL)
	LD	H,A
	CALL	SUBDH
	OR	L
	EX	DE,HL
	RET	Z		; yes
	JP	GET$BCB3	; no - insert bcb at head of list

LAST$BCB$LINKS$DE:
	LD	HL,(LASTBCBA)
	LD	BC,13
	ADD	HL,BC
	LD	(HL),E
	INC	HL
	LD	(HL),D
	RET

GET$NEXT$BCBA:
	LD	BC,13
	ADD	HL,BC
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	LD	A,H
	OR	L
	RET

SET$BCB$SEQ:
	LD	A,(PHY$OFF)
	LD	(HL),A
	OR	A
	RET	Z
	LD	A,(PHYMSK)
	INC	A
	LD	(HL),A
	RET

	ENDIF

	IF NOT MPM
	IF NOT BANKED

PATCH$1DFD: ;[JCE] DRI Patch 7
	LD	A,(CHKSIZ+1)
	RLA
	JP	C,GET$DIR$EXT
	LD	A,0FFH
	LD	(PATCH$1E24),A
	JP	GET$DIR$EXT

PATCH$1E0C:
	CP	3
	JP	NZ,COMPARE
	LD	A,(PATCH$1E24)
	INC	A
	JP	NZ,COMPARE
	POP	HL
	JP	DEBLOCK25

PATCH$1E1C:
	XOR	A
	LD	(PATCH$1E24),A
	LD	HL,(CURBCBA)
	RET

PATCH$1E24:
	DEFB	0

PATCH$1E25:
	LD	HL,0
	LD	(CONBUFFADD),HL
	LD	(CCP$CONBUFF),HL
	DEC	HL
	DEC	HL
	RET

PATCH$1E31: ;Patch 13
	CALL	CHECK$WRITE
	LD	HL,XDCNT
	RET

PATCH$1E38:
	CALL	RESELECTX
	JP	CHECK$WRITE

PATCH$1E3E:
	CALL	SETFWF
	JP	SEARCH$NAMLEN

		DEFS	41		;[JCE] Was 112 before patching
LAST:
	ORG	BASE + (((LAST-BASE)+255) AND 0FF00H) - 112

OLOG:		DEFW	0
RLOG:		DEFW	0

PATCH$FLGS: 	DEFB	0,0,0,6	;Patchlevel
		DEFW	BASE+6
	XOR	A
	RET

; System Control Block

SCB:

; Expansion Area - 6 bytes

HASHL:		DEFB	0
HASH:		DEFW	0,0
VERSION:	DEFB	31H

; Utilities Section - 8 bytes

UTIL$FLGS: 	DEFW	0,0
DSPL$FLGS: 	DEFW	0
		DEFW	0

; CLP Section - 4 bytes

CLP$FLGS: 	DEFW	0
CLP$ERRCDE: 	DEFW	0

; CCP Section - 8 bytes

CCP$COMLEN: 	DEFB	0
CCP$CURDRV: 	DEFB	0
CCP$CURUSR: 	DEFB	0
CCP$CONBUFF: 	DEFW	0
CCP$FLGS: 	DEFW	0
		DEFB	0

; Device I/O Section - 32 bytes

CONWIDTH: 	DEFB	0
COLUMN:		DEFB	0
CONPAGE:	DEFB	0
CONLINE:	DEFB	0
CONBUFFADD: 	DEFW	0
CONBUFFLEN: 	DEFW	0
CONIN$RFLG: 	DEFW	0
CONOUT$RFLG: 	DEFW	0
AUXIN$RFLG: 	DEFW	0
AUXOUT$RFLG: 	DEFW	0
LSTOUT$RFLG: 	DEFW	0
PAGE$MODE: 	DEFB	0
PM$DEFAULT: 	DEFB	0
CTLH$ACT: 	DEFB	0
RUBOUT$ACT: 	DEFB	0
TYPE$AHEAD: 	DEFB	0
CONTRAN:	DEFW	0
CONMODE:	DEFW	0
		DEFB	0
		DEFB	0
OUTDELIM: 	DEFB	'$'
LISTCP:		DEFB	0
QFLAG:		DEFB	0

; BDOS Section - 42 bytes

SCBADD:		DEFW	SCB
DMAAD:		DEFW	0080H
OLDDSK:		DEFB	0
INFO:		DEFW	0
RESEL:		DEFB	0
RELOG:		DEFB	0
FX:		DEFB	0
USRCODE:	DEFB	0
DCNT:		DEFW	0
SEARCHA:	DEFW	0
SEARCHL:	DEFB	0
MULTCNT:	DEFB	1
ERRORMODE: 	DEFB	0
SEARCHCHAIN: 	DEFB	0,0FFH,0FFH,0FFH
TEMP$DRIVE: 	DEFB	0
ERRDRV:		DEFB	0
		DEFW	0
MEDIA$FLAG: 	DEFB	0
		DEFW	0
BDOS$FLAGS: 	DEFB	0
STAMP:		DEFB	0FFH,0FFH,0FFH,0FFH,0FFH
COMMONBASE: 	DEFW	0
ERROR:	JP	ERROR$SUB
BDOSADD:	DEFW	BASE+6

	ENDIF
	ENDIF

;	************************
;	Directory Hashing Module
;	************************

; Hash format
; xxsuuuuu xxxxxxxx xxxxxxxx ssssssss
; x = hash code of fcb name field
; u = low 5 bits of fcb user field
;     1st bit is on for XFCB's
; s = shiftr(mod || ext,extshf)

	IF NOT BANKED

HASHORG:
	ORG	BASE+(((HASHORG-BASE)+255) AND 0FF00H)
	ENDIF

INIT$HASH:
	; de = .hash table entry
	; hl = .dir fcb
	PUSH	HL
	PUSH	DE
	CALL	GET$HASH
	; Move computed hash to hash table entry
	POP	HL
	LD	DE,HASH
	LD	BC,4

	IF BANKED
	LD	A,(HASHTBLA+2)
	CALL	MOVE$OUT
	ELSE
	CALL	MOVEF
	ENDIF

	; Save next hash table entry address
	LD	(ARECORD1),HL
	; Restore dir fcb address
	POP	HL
	RET

SET$HASH:
	; Return if searchl = 0
	OR	A
	RET	Z
	; Is searchl < 12 ?
	CP	12
	JP	C,SET$HASH2	; yes - hashl = 0
	; Is searchl = 12 ?
	LD	A,2
	JP	Z,SET$HASH1	; yes - hashl = 2
	LD	A,3		; hashl = 3
SET$HASH1:
	LD	(HASHL),A
	EX	DE,HL
	; Is dir hashing invoked for drive?
	CALL	TEST$HASH
	RET	Z		; no
	EX	DE,HL
	LD	A,(FX)
	CP	16
	JP	Z,GET$HASH	; bdos fx = 16
	CP	35
	JP	Z,SET$HASH15
	CP	20
	JP	NC,GET$HASH	; bdos fx = 20 or above
SET$HASH15:
	LD	A,2
	LD	(HASHL),A	; bdos fx = 15,17,18,19, or 35
	; if fcb wild then hashl = 0, hash = fcb(0)
	;	      else hashl = 2, hash = get$hash
	PUSH	HL
	CALL	CHK$WILD
	POP	HL
	JP	NZ,GET$HASH
SET$HASH2:
	XOR	A
	LD	(HASHL),A
	; jmp get$hash

GET$HASH:
	; hash(0) = fcb(0)
	LD	A,(HL)
	LD	(HASH),A
	INC	HL
	EX	DE,HL
	; Don't compute hash for dir lbl & sfcb's
	LD	HL,0
	AND	20H
	JP	NZ,GET$HASH6
	; b = 11, c = 8, ahl = 0
	; Compute fcb name hash (000000xx xxxxxxxxx xxxxxxxx) (ahl)
	LD	BC,0B08H
GET$HASH1:
	; Don't shift if fcb(8)
	DEC	C
	PUSH	BC
	JP	Z,GET$HASH3
	; Don't shift if fcb(6)
	DEC	C
	DEC	C
	JP	Z,GET$HASH3
	; ahl = ahl * 2
	ADD	HL,HL
	ADC	A,A
	PUSH	AF
	LD	A,B
	; is b odd?
	RRA
	JP	C,GET$HASH4	; yes
	; ahl = ahl * 2 for even fcb(i)
	POP	AF
	ADD	HL,HL
	ADC	A,A
GET$HASH3:
	PUSH	AF
GET$HASH4:
	; a = fcb(i) & 7fh - 20h divided by 2 if even
	LD	A,(DE)
	AND	7FH
	SUB	20H
	RRA
	JP	NC,GET$HASH5
	RLA
GET$HASH5:
	; ahl = ahl + a
	LD	C,A
	LD	B,0
	POP	AF
	ADD	HL,BC
	ADC	A,0
	POP	BC
	; advance to next fcb char
	INC	DE
	DEC	B
	JP	NZ,GET$HASH1
GET$HASH6:
	; ahl = 000000xx xxxxxxxx xxxxxxxx
	; Store low 2 bytes of hash
	LD	(HASH+1),HL
	LD	HL,HASH
	; hash(0) = hash(0) (000uuuuu) | xx000000
	AND	3
	RRCA
	RRCA
	OR	(HL)
	LD	(HL),A
	; Does fcb(0) = e5h, 20h, or 21h?
	AND	20H
	JP	NZ,GET$HASH9	; yes
	; bc = 00000mmm mmmeeeee, m = module #, e = extent
	LD	A,(DE)
	AND	1FH
	LD	C,A
	INC	DE
	INC	DE
	LD	A,(DE)
	AND	3FH
	RRCA
	RRCA
	RRCA
	LD	D,A
	AND	7
	LD	B,A
	LD	A,D
	AND	0E0H
	OR	C
	LD	C,A
	; shift bc right by # of bits in extmsk
	LD	A,(EXTMSK)
GET$HASH7:
	RRA
	JP	NC,GET$HASH8
	PUSH	AF
	LD	A,B
	RRA
	LD	B,A
	LD	A,C
	RRA
	LD	C,A
	POP	AF
	JP	GET$HASH7
GET$HASH8:
	; hash(0) = hash(0) (xx0uuuuu) | 00s00000
	LD	A,B
	AND	1
	RRCA
	RRCA
GET$HASH9:
	RRCA
	OR	(HL)
	LD	(HL),A
	; hash(3) = ssssssss
	LD	DE,3
	ADD	HL,DE
	LD	(HL),C
	RET

TEST$HASH:
	LD	HL,(HASHTBLA)
	LD	A,L
	OR	H
	INC	A
	RET

SEARCH$HASH:
	; Does hash table exist for drive?
	CALL	TEST$HASH
	RET	Z		; no
	; Has dir hash search been disabled?
	LD	A,(HASHL)
	INC	A
	RET	Z		; yes
	; Is searchl = 0?
	LD	A,(SEARCHL)
	OR	A
	RET	Z		; yes
	; hashmx = cdrmaxa if searchl ~= 1
	;	   dir$max if searchl = 1
	LD	HL,(CDRMAXA)
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	DEC	A
	JP	NZ,SEARCH$H0
	LD	HL,(DIRMAX)
SEARCH$H0:
	LD	(HASHMX),HL

	IF BANKED
	; call search$hash in resbdos, a = bank, hl = hash tbl addr
	LD	A,(HASHTBLA+2)
	LD	HL,(HASHTBLA)
	CALL	SRCH$HASH
	; Was search successful?
	JP	NZ,SEARCH$H1	; no
	; Is directory read required?
	LD	A,(RD$DIR$FLAG)
	OR	A
	LD	C,0
	CALL	NZ,R$DIR2	; yes if Z flag reset
	; Is function = 18?
	LD	A,(FX)
	SUB	18
	RET	Z		; Never reset dcnt for fx 18
	; Was media change detected by above read?
	LD	A,(HASHL)
	INC	A
	CALL	Z,SETENDDIR	; yes
	XOR	A
	RET			; search$hash successful
SEARCH$H1:
	; Was search initiated from beginning of directory?
	CALL	END$OF$DIR
	RET	NZ		; no
	; Is bdos fx = 15,17,19,22,23,30?
	CALL	TST$LOG$FXS
	RET	NZ		; no
	; Disable hash & return successful
	LD	A,0FFH
	LD	(HASHL),A
	LD	HL,(CDRMAXA)
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	DEC	HL
	CALL	SET$DCNT$DBLK1
	XOR	A
	RET
	ELSE
	LD	HL,(HASHTBLA)
	LD	B,H
	LD	C,L
	LD	HL,(HASHMX)
	EX	DE,HL
	; Return with Z flag set if dcnt = hashmx
	LD	HL,(DCNT)
	PUSH	HL
	CALL	SUBDH
	POP	DE
	OR	L
	RET	Z
	; Push hashmx - dcnt (# of hashtbl entries to search)
	; Push dcnt + 1
	PUSH	HL
	INC	DE
	EX	DE,HL
	PUSH	HL
	; Compute .hash$tbl(dcnt)
	DEC	HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,BC
SEARCH$H1:
	; Advance hl to address of next hash$tbl entry
	LD	DE,4
	ADD	HL,DE
	LD	DE,HASH
	; Do hash u fields match?
	LD	A,(DE)
	XOR	(HL)
	AND	1FH
	JP	NZ,SEARCH$H3	; no
	; Do hash's match?
	CALL	SEARCH$H6
	JP	Z,SEARCH$H4	; yes
SEARCH$H2:
	EX	DE,HL
	POP	HL
SEARCH$H25:
	; de = .hash$tbl(dcnt), hl = dcnt
	; dcnt = dcnt + 1
	INC	HL
	EX	(SP),HL
	; hl = # of hash$tbl entries to search
	; decrement & test for zero
	; Restore stack & hl to .hashtbl(dcnt)
	DEC	HL
	LD	A,L
	OR	H
	EX	(SP),HL
	PUSH	HL
	; Are we done?
	EX	DE,HL
	JP	NZ,SEARCH$H1	; no - keep searching
	; Search unsuccessful
	POP	HL
	POP	HL
	; Was search initiated from beginning of directory?
	CALL	END$OF$DIR
	RET	NZ		; no
	; Is fx = 15,17,19,22,23,30 & drive removeable?
	CALL	TST$LOG$FXS
	RET	NZ		; no
	; Disable hash & return successful
	LD	A,0FFH
	LD	(HASHL),A
	LD	HL,(CDRMAXA)
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	DEC	HL
	CALL	SET$DCNT$DBLK1
	XOR	A
	RET

SEARCH$H3:
	; Does xdcnt+1 = 0ffh?
	LD	A,(XDCNT+1)
	INC	A
	JP	Z,SEARCH$H5	; yes
	; Does xdcnt+1 = 0feh?
	INC	A
	JP	NZ,SEARCH$H2	; no - continue searching
	; Do hash's match?
	CALL	SEARCH$H6
	JP	NZ,SEARCH$H2	; no
	; xdcnt+1 = 0feh
	; Open user 0 search
	; Does hash u field = 0?
	LD	A,(HL)
	AND	1FH
	JP	NZ,SEARCH$H2	; no
	; Search successful
SEARCH$H4:
	; Successful search
	; Set dcnt to search$hash dcnt-1
	; dcnt gets incremented by read$dir
	; Also discard search$hash loop count
	LD	HL,(DCNT)
	EX	DE,HL
	POP	HL
	DEC	HL
	LD	(DCNT),HL
	POP	BC
	; Does dcnt&3 = 3?
	LD	A,L
	AND	03H
	CP	03H
	RET	Z		; yes
	; Does old dcnt & new dcnt reside in same sector?
	LD	A,E
	AND	0FCH
	LD	E,A
	LD	A,L
	AND	0FCH
	LD	L,A
	CALL	SUBDH
	OR	L
	RET	Z		; yes
	; Read directory record
	CALL	READ$DIR2
	; Has media change been detected?
	LD	A,(HASHL)
	INC	A
	CALL	Z,SETENDDIR	; dcnt = -1 if hashl = 0ffh
	XOR	A
	RET
SEARCH$H5:
	; xdcnt+1 = 0ffh
	; Make search to save dcnt of empty fcb
	; Is hash$tbl entry empty?
	LD	A,(HL)
	CP	0F5H
	JP	NZ,SEARCH$H2	; no
SEARCH$H55:
	; xdcnt = dcnt
	EX	DE,HL
	POP	HL
	LD	(XDCNT),HL
	JP	SEARCH$H25
SEARCH$H6:
	; hash compare routine
	; Is hashl = 0?
	LD	A,(HASHL)
	OR	A
	RET	Z		; yes - hash compare successful
	; b = 0f0h if hashl = 3
	;     0d0h if hashl = 2
	LD	C,A
	RRCA
	RRCA
	RRCA
	OR	1001$0000B
	LD	B,A
	; hash s field must be screened out of hash(0)
	; if hashl = 2
	; Do hash(0) fields match?
	LD	A,(DE)
	XOR	(HL)
	AND	B
	RET	NZ		; no
	; Compare remainder of hash fields for hashl bytes
	PUSH	HL
	INC	HL
	INC	DE
	CALL	COMPARE
	POP	HL
	RET
	ENDIF

FIX$HASH:
	CALL	TEST$HASH
	RET	Z
	LD	HL,SAVE$HASH
	LD	DE,HASH
	LD	BC,4
	PUSH	HL
	PUSH	DE
	PUSH	BC
	CALL	MOVEF
	LD	HL,(HASHTBLA)
	PUSH	HL
	CALL	GETDPTRA
	CALL	GET$HASH
	LD	HL,(DCNT)
	ADD	HL,HL
	ADD	HL,HL
	POP	DE
	ADD	HL,DE
	POP	BC
	POP	DE
	PUSH	DE
	PUSH	BC

	IF BANKED
	LD	A,(HASHTBLA+2)
	CALL	MOVE$OUT
	ELSE
	CALL	MOVEF
	ENDIF

	POP	BC
	POP	HL
	POP	DE
	JP	MOVEF

	IF NOT MPM
	IF BANKED

PATCH$1DFD: ;[JCE] DRI Patch 7
	LD	A,(CHKSIZ+1)
	RLA
	JP	C,GET$DIR$EXT
	LD	A,0FFH
	LD	(PATCH$1E24),A
	JP	GET$DIR$EXT

PATCH$1E0C:
	CP	3
	JP	NZ,COMPARE
	LD	A,(PATCH$1E24)
	INC	A
	JP	NZ,COMPARE
	POP	HL
	JP	DEBLOCK25

PATCH$1E1C:
	XOR	A
	LD	(PATCH$1E24),A
	LD	HL,(CURBCBA)
	RET

PATCH$1E24:
	DEFB	0

PATCH$1E25:
	LD	HL,0
	LD	(CONBUFFADD),HL
	LD	(CCP$CONBUFF),HL
	DEC	HL
	DEC	HL
	RET

PATCH$2D30:
	LD	(ROOTBCBA),HL
	SUB	3
	LD	(PATCH$2D39),A
	RET

PATCH$2D39:
	DEFB	0

PATCH$2D3A:
	CALL	PATCH$2D43
	JP	FLUSH4

PATCH$2D40:
	CALL	COPY$ALV
PATCH$2D43:
	LD	HL,(DTABCBA)
	LD	A,L
	AND	H
	INC	A
	RET	Z
PATCH$2D4A:
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	A,D
	OR	E
	RET	Z
	LD	HL,ADRIVE
	LD	A,(DE)
	CP	(HL)
	JP	NZ,PATCH$2D63
	LD	HL,4
	ADD	HL,DE
	LD	A,0FFH
	CP	(HL)
	JP	NZ,PATCH$2D63
	LD	(DE),A
PATCH$2D63:
	LD	HL,0DH
	ADD	HL,DE
	JP	PATCH$2D4A

PATCH$2D6A:
	CALL	COPY$ALV
	LD	HL,(LSN$ADD)
	LD	A,(HL)
	OR	A
	RET	NZ
	LD	(HL),2
	RET

PATCH$1E31:
	CALL	CHECK$WRITE
	LD	HL,XDCNT
	RET

PATCH$1E38:
	CALL	RESELECTX
	JP	CHECK$WRITE

PATCH$1E3E:
	CALL	SETFWF
	JP	SEARCH$NAMLEN

LAST:

	DEFS	BASE + $2DFF - LAST

	DEFB	0

	ENDIF	;BANKED

	ELSE	;not MPM

	DEFS	192
LAST:
	ORG	(((LAST-BASE)+255) AND 0FF00H) - 192

	;	bnkbdos patch area

	DEFW	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DEFW	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DEFW	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DEFW	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DEFW	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DEFW	0,0,0,0,0,0,0,0,0,0,0,0

FREE$ROOT: 	DEFW	$-$
OPEN$ROOT: 	DEFW	0
LOCK$ROOT: 	DEFW	0
LOCK$MAX: 	DEFB	0
OPEN$MAX: 	DEFB	0

;	BIOS access table

BIOS	EQU	$		; base of the bios jump table
BOOTF	EQU	BIOS		; cold boot function
WBOOTF	EQU	BOOTF+3		; warm boot function
CONSTF	EQU	WBOOTF+3	; console status function
CONINF	EQU	CONSTF+3	; console input function
CONOUTF EQU	CONINF+3	; console output function
LISTF	EQU	CONOUTF+3	; list output function
PUNCHF	EQU	LISTF+3		; punch output function
READERF EQU	PUNCHF+3	; reader input function
HOMEF	EQU	READERF+3	; disk home function
SELDSKF EQU	HOMEF+3		; select disk function
SETTRKF EQU	SELDSKF+3	; set track function
SETSECF EQU	SETTRKF+3	; set sector function
SETDMAF EQU	SETSECF+3	; set dma function
READF	EQU	SETDMAF+3	; read disk function
WRITEF	EQU	READF+3		; write disk function
LISTSTF EQU	WRITEF+3	; list status function
SECTRAN EQU	LISTSTF+3	; sector translate

	ENDIF

	END


