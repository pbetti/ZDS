

	TITLE	'CP/M 3 Banked BDOS Resident Module, Dec 1982'
;***************************************************************
;***************************************************************
;**                                                           **
;**   B a s i c    D i s k   O p e r a t i n g   S y s t e m  **
;**                                                           **
;**   R e s i d e n t   M o d u l e  -  B a n k e d  B D O S  **
;**                                                           **
;***************************************************************
;***************************************************************

;/*
;  Copyright (C) 1978,1979,1980,1981,1982
;  Digital Research
;  P.O. Box 579
;  Pacific Grove, CA 93950
;
;  December, 1982
;
;*/
;

;
; [JCE] Have the date and copyright messages in only one source file
;
@BDATE	MACRO
	DEFB	'101198'
	ENDM

@LCOPY	MACRO
	DEFB	'Copyright 1998, '
	DEFB	'Caldera, Inc.   '
	ENDM

@SCOPY	MACRO
	DEFB	'(c) 98 Caldera'
	ENDM
;
;
SSIZE	EQU	30
DISKFX	EQU	12
CONOUTFXX EQU	2
PRINTFX EQU	9
CONSTATFX EQU	11
SETDMAFX EQU	26
CHAINFX EQU	47
IOLOC	EQU	3

; 	ORG	0000H
BASE	EQU	$

BNKBDOS$PG EQU	BASE+0FC00H
RESBDOS$PG EQU	BASE+0FD00H
SCB$PG	EQU	BASE+0FE00H
BIOS$PG EQU	BASE+0FF00H

BNKBDOS EQU	BNKBDOS$PG+6
ERROR$JMP EQU	BNKBDOS$PG+7CH

BIOS	EQU	BIOS$PG
BOOTF	EQU	BIOS$PG		; 00. cold boot function
WBOOTF	EQU	BIOS$PG+3	; 01. warm boot function
CONSTF	EQU	BIOS$PG+6	; 02. console status function
CONINF	EQU	BIOS$PG+9	; 03. console input function
CONOUTF EQU	BIOS$PG+12	; 04. console output function
LISTF	EQU	BIOS$PG+15	; 05. list output function
PUNCHF	EQU	BIOS$PG+18	; 06. punch output function
READERF EQU	BIOS$PG+21	; 07. reader input function
HOMEF	EQU	BIOS$PG+24	; 08. disk home function
SELDSKF EQU	BIOS$PG+27	; 09. select disk function
SETTRKF EQU	BIOS$PG+30	; 10. set track function
SETSECF EQU	BIOS$PG+33	; 11. set sector function
SETDMAF EQU	BIOS$PG+36	; 12. set dma function
READF	EQU	BIOS$PG+39	; 13. read disk function
WRITEF	EQU	BIOS$PG+42	; 14. write disk function
LISTSTF EQU	BIOS$PG+45	; 15. list status function
SECTRAN EQU	BIOS$PG+48	; 16. sector translate
CONOUTSTF EQU	BIOS$PG+51	; 17. console output status function
AUXINSTF EQU	BIOS$PG+54	; 18. aux input status function
AUXOUTSTF EQU	BIOS$PG+57	; 19. aux output status function
DEVTBLF EQU	BIOS$PG+60	; 20. return device table address fx
DEVINITF EQU	BIOS$PG+63	; 21. initialize device function
DRVTBLF EQU	BIOS$PG+66	; 22. return drive table address
MULTIOF EQU	BIOS$PG+69	; 23. multiple i/o function
FLUSHF	EQU	BIOS$PG+72	; 24. flush function
MOVEF	EQU	BIOS$PG+75	; 25. memory move function
TIMEF	EQU	BIOS$PG+78	; 26. get/set system time function
SELMEMF EQU	BIOS$PG+81	; 27. select memory function
SETBNKF EQU	BIOS$PG+84	; 28. set dma bank function
XMOVEF	EQU	BIOS$PG+78	; 29. extended move function

SCONOUTF EQU	CONOUTF		; 31. escape sequence decoded conout
SCREENF EQU	0FFFFH		; 32. screen function

SERIAL:	DEFB	'654321'

	JP	BDOS
	JP	MOVE$OUT	;A = bank #
	;HL = dest, DE = srce
	JP	MOVE$TPA	;A = bank #
	;HL = dest, DE = srce
	JP	SEARCH$HASH	;A = bank #
	;HL = hash table address

	; on return, Z flag set for eligible DCNTs
	;	     Z flag reset implies unsuccessful search

	; Additional variables referenced directly by bnkbdos

HASHMX:		DEFW	0	;max hash search dcnt
RD$DIR:		DEFB	0	;read directory flag
MAKE$XFCB: 	DEFB	0	;Make XFCB flag
FIND$XFCB: 	DEFB	0	;Search XFCB flag
XDCNT:		DEFW	0	;current xdcnt

XDMAADD:	DEFW	COMMON$DMA
CURDMA:		DEFW	0
COPY$CR$ONLY: 	DEFB	0
USER$INFO: 	DEFW	0
KBCHAR:		DEFB	0
	JP	QCONINX

BDOS:	;arrive here from user programs
	LD	A,C		; c = BDOS function #

	;switch to local stack

	LD	HL,0
	LD	(ARET),HL
	ADD	HL,SP
	LD	(ENTSP),HL	; save stack pointer
	LD	SP,LSTACK
	LD	HL,GOBACK
	PUSH	HL

	CP	DISKFX
	JP	NC,DISK$FUNC

	LD	(FX),A		;[JCE] DRI patch 1

	LD	HL,FUNCTAB
	LD	B,0
	ADD	HL,BC
	ADD	HL,BC
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	JP	(HL)

	@LCOPY
	@BDATE
	DEFW	0,0,0,0,0,0,0,0,0,0,0

FUNCTAB:
	DEFW	WBOOTF, BANK$BDOS, BANK$BDOS, FUNC3
	DEFW	FUNC4, FUNC5, FUNC6, FUNC7
	DEFW	FUNC8, FUNC9, FUNC10, BANK$BDOS

FUNC3:
	CALL	READERF
	JP	STA$RET

FUNC4:
	LD	C,E
	JP	PUNCHF

FUNC5:
	LD	C,E
	JP	LISTF

FUNC6:
	LD	A,E
	INC	A
	JP	Z,DIRINP	;0ffh -> cond. input
	INC	A
	JP	Z,DIRSTAT	;0feh -> status
	INC	A
	JP	Z,DIRINP1	;0fdh -> input
	LD	C,E
	JP	CONOUTF		;	 output
DIRSTAT:
	CALL	CONSTX
	JP	STA$RET
DIRINP:
	CALL	CONSTX
	OR	A
	RET	Z
DIRINP1:
	CALL	CONIN
	JP	STA$RET

CONSTX:
	LD	A,(KBCHAR)
	OR	A
	LD	A,0FFH
	RET	NZ
	JP	CONSTF

CONIN:
	LD	HL,KBCHAR
	LD	A,(HL)
	LD	(HL),0
	OR	A
	RET	NZ
	JP	CONINF

FUNC7:
	CALL	AUXINSTF
	JP	STA$RET

FUNC8:
	CALL	AUXOUTSTF
	JP	STA$RET

FUNC9:
	LD	B,D
	LD	C,E
PRINT:
	LD	HL,OUTDELIM
	LD	A,(BC)
	CP	(HL)
	RET	Z
	INC	BC
	PUSH	BC
	LD	C,A
	CALL	BLK$OUT0
	POP	BC
	JP	PRINT

FUNC10:
	EX	DE,HL
	LD	A,L
	OR	H
	JP	NZ,FUNC10A
	LD	HL,BUFFER+2
	LD	(CONBUFFADD),HL
	LD	HL,(DMAAD)
FUNC10A:
	PUSH	HL
	LD	DE,BUFFER
	PUSH	DE
	LD	B,0
	LD	C,(HL)
	INC	BC
	INC	BC
	INC	BC
	EX	DE,HL
	CALL	MOVEF
	LD	(HL),0
	POP	DE
	PUSH	DE
	LD	C,10
	CALL	BANK$BDOS
	LD	A,(BUFFER+1)
	LD	C,A
	LD	B,0
	INC	BC
	INC	BC
	POP	DE
	POP	HL
	JP	MOVEF

FUNC111:
FUNC112:
	LD	(RES$FX),A
	EX	DE,HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	EX	DE,HL
	; hl = addr of string
	; bc = length of string
BLK$OUT:
	LD	A,B
	OR	C
	RET	Z
	PUSH	BC
	PUSH	HL
	LD	C,(HL)
	LD	DE,BLK$OUT2
	PUSH	DE
	LD	A,(RES$FX)
	CP	112
	JP	Z,LISTF

BLK$OUT0:
	LD	A,(CONMODE)
	LD	B,A
	AND	2
	JP	Z,BLK$OUT1
	LD	A,B
	AND	14H
	JP	Z,BLK$OUT1
	AND	10H
	JP	NZ,SCONOUTF
	JP	CONOUTF

BLK$OUT1:
	LD	E,C
	LD	C,CONOUTFXX
	JP	BANK$BDOS

BLK$OUT2:
	POP	HL
	INC	HL
	POP	BC
	DEC	BC
	JP	BLK$OUT

QCONINX:
	; switch to bank 1
	LD	A,1
	CALL	SELMEMF
	; get character
	LD	B,(HL)
	; return to bank zero
	XOR	A
	CALL	SELMEMF
	; return with character in A
	LD	A,B
	RET

SWITCH1:
	LD	DE,SWITCH0
	PUSH	DE
	LD	A,1
	CALL	SELMEMF
	JP	(HL)
SWITCH0:
	LD	B,A
	XOR	A
	CALL	SELMEMF
	LD	A,B
	RET

DISK$FUNC:
	CP	NDF
	JP	C,OKDF		;func < ndf
	CP	98
	JP	C,BADFUNC	;ndf < func < 98
	CP	NXDF
	JP	NC,BADFUNC	;func >= nxdf
	CP	111
	JP	Z,FUNC111
	CP	112
	JP	Z,FUNC112
	JP	DISK$FUNCTION

OKDF:
	CP	17
	JP	Z,SEARCH
	CP	18
	JP	Z,SEARCHN
	CP	SETDMAFX
	JP	NZ,DISK$FUNCTION

	; Set dma addr
	EX	DE,HL
	LD	(DMAAD),HL
	LD	(CURDMA),HL
	RET

SEARCH:
	EX	DE,HL
	LD	(SEARCHA),HL

SEARCHN:
	LD	HL,(SEARCHA)
	EX	DE,HL

DISK$FUNCTION:

;
;	Perform the required buffer tranfers from
;	the user bank to common memory
;

	LD	HL,DFCTBL-12
	LD	A,C
	CP	98
	JP	C,NORMALCPM
	LD	HL,XDFCTBL-98
NORMALCPM:
	LD	B,0
	ADD	HL,BC
	LD	A,(HL)

; ****  SAVE DFTBL ITEM, INFO, & FUNCTION *****

	LD	B,A
	PUSH	BC
	PUSH	DE

	RRA
	JP	C,CPYCDMAIN	;cdmain test
	RRA
	JP	C,CPYFCBIN	;fcbin test
	JP	NOCPYIN

CPYCDMAIN:
	LD	HL,(DMAAD)
	EX	DE,HL
	LD	HL,COMMON$DMA
	LD	BC,16
	CALL	MOVEF
	POP	DE
	PUSH	DE

CPYFCBIN:
	XOR	A
	LD	(COPY$CR$ONLY),A
	LD	HL,COMMONFCB
	LD	BC,36
	CALL	MOVEF
	LD	DE,COMMONFCB
	POP	HL
	POP	BC
	PUSH	BC
	PUSH	HL
	LD	(USER$INFO),HL

NOCPYIN:

	CALL	BANK$BDOS

	POP	DE		;restore FCB address
	POP	BC
	LD	A,B		;restore fcbtbl byte & function #
	AND	0FCH
	RET	Z		;[JCE] DRI Patch 13: F8 -> FC
	LD	HL,COMMONFCB
	EX	DE,HL
	LD	BC,33
	RLA
	JP	C,COPY$FCB$BACK	;fcbout test
	LD	C,36
	RLA
	JP	C,COPY$FCB$BACK	;pfcbout test
	RLA
	JP	C,CDMACPYOUT128	;cdmaout128 test
	LD	C,4
	RLA
	JP	C,MOVEF		;timeout test
	RLA
	JP	C,CDMACPYOUT003	;cdmaout003 test
	LD	C,6
	JP	MOVEF		;seriout

COPY$FCB$BACK:
	LD	A,(COPY$CR$ONLY)
	OR	A
	JP	Z,MOVEF
	LD	BC,14
	ADD	HL,BC
	EX	DE,HL
	ADD	HL,BC
	LD	A,(HL)
	LD	(DE),A
	INC	HL
	INC	DE
	LD	A,(HL)
	LD	(DE),A
	INC	BC
	INC	BC
	INC	BC
	ADD	HL,BC
	EX	DE,HL
	ADD	HL,BC
	LD	A,(DE)
	LD	(HL),A
	RET

CDMACPYOUT003:
	LD	HL,(DMAAD)
	LD	BC,3
	LD	DE,COMMON$DMA
	JP	MOVEF

CDMACPYOUT128:
	LD	HL,(DMAAD)
	LD	BC,128
	LD	DE,COMMON$DMA
	JP	MOVEF

PARSE:
	EX	DE,HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	LD	HL,BUFFER+133
	PUSH	HL
	PUSH	BC
	PUSH	DE
	LD	(BUFFER+2),HL
	LD	HL,BUFFER+4
	LD	(BUFFER),HL
	LD	BC,128
	CALL	MOVEF
	LD	(HL),0
	LD	C,152
	LD	DE,BUFFER
	CALL	BANK$BDOS
	POP	BC
	LD	A,L
	OR	H
	JP	Z,PARSE1
	LD	A,L
	AND	H
	INC	A
	JP	Z,PARSE1
	LD	DE,BUFFER+4
	LD	A,L
	SUB	E
	LD	L,A
	LD	A,H
	SBC	A,D
	LD	H,A
	ADD	HL,BC
	LD	(ARET),HL
PARSE1:
	POP	HL
	POP	DE
	LD	BC,36
	JP	MOVEF

BADFUNC:
	CP	152
	JP	Z,PARSE

	; A = 0 if fx >= 128, 0ffh otherwise
	RLA
	LD	A,0
	JP	C,STA$RET

	DEC	A

STA$RET:
	LD	(ARET),A

GOBACK:
	LD	HL,(ENTSP)
	LD	SP,HL		;user stack restored
	LD	HL,(ARET)
	LD	A,L
	LD	B,H		;BA = HL = aret
	RET

BANK$BDOS:

	XOR	A
	CALL	SELMEMF

	CALL	BNKBDOS

	LD	(ARET),HL
	LD	A,1
	JP	SELMEMF		;ret


MOVE$OUT:
	OR	A
	JP	Z,MOVEF
	CALL	SELMEMF
MOVE$RET:
	CALL	MOVEF
	XOR	A
	JP	SELMEMF

MOVE$TPA:
	LD	A,1
	CALL	SELMEMF
	JP	MOVE$RET

SEARCH$HASH: ; A = bank # , HL = hash table addr

	; Hash format
	; xxsuuuuu xxxxxxxx xxxxxxxx ssssssss
	; x = hash code of fcb name field
	; u = low 5 bits of fcb user field
	;     1st bit is on for XFCB's
	; s = shiftr(mod || ext,extshf)

	LD	(HASH$TBLA),HL
	CALL	SELMEMF
	; Push return address
	LD	HL,SEARCH$H7
	PUSH	HL
	; Reset read directory record flag
	XOR	A
	LD	(RD$DIR),A

	LD	HL,(HASH$TBLA)
	LD	B,H
	LD	C,L
	LD	HL,(HASHMX)
	EX	DE,HL
	; Return with Z flag set if dcnt = hash$mx
	LD	HL,(DCNT)
	PUSH	HL
	CALL	SUBDH
	POP	DE
	OR	L
	RET	Z
	; Push hash$mx-dcnt (# of hash$tbl entries to search)
	; Push dcnt+1
	PUSH	HL
	INC	DE
	EX	DE,HL
	PUSH	HL
	; Compute .hash$tbl(dcnt-1)
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
	; Restore stack & hl to .hash$tbl(dcnt)
	DEC	HL
	LD	A,L
	OR	H
	EX	(SP),HL
	PUSH	HL
	; Are we done?
	EX	DE,HL
	JP	NZ,SEARCH$H1	; no - keep searching
	; Search unsuccessful - return with Z flag reset
	INC	A
	POP	HL
	POP	HL
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
	PUSH	DE
	CALL	SEARCH$H6
	POP	DE
	JP	NZ,SEARCH$H2	; no
	; Does find$xfcb = 0ffh?
	LD	A,(FIND$XFCB)
	INC	A
	JP	Z,SEARCH$H45	; yes
	; Does find$xfcb = 0feh?
	INC	A
	JP	Z,SEARCH$H35	; yes
	; xdcnt+1 = 0feh & find$xfcb < 0feh
	; Open user 0 search
	; Does hash u field = 0?
	LD	A,(HL)
	AND	1FH
	JP	NZ,SEARCH$H2	; no
	; Search successful
	JP	SEARCH$H4
SEARCH$H35:
	; xdcnt+1 = 0feh & find$xfcb = 0feh
	; Delete search to return matching fcb's & xfcbs
	; Do hash user fields match?
	LD	A,(DE)
	XOR	(HL)
	AND	0FH
	JP	NZ,SEARCH$H2	; no
	; Exclude empty fcbs, sfcbs, and dir lbls
	LD	A,(HL)
	AND	30H
	CP	30H
	JP	Z,SEARCH$H2
SEARCH$H4:
	; successful search
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
	; Set directory read flag
	LD	A,0FFH
	LD	(RD$DIR),A
	XOR	A
	RET
SEARCH$H45:
	; xdcnt+1 = 0feh, find$xfcb = 0ffh
	; Rename search to save dcnt of xfcb in xdcnt
	; Is hash entry an xfcb?
	LD	A,(HL)
	AND	10H
	JP	Z,SEARCH$H2	; no
	; Do hash user fields agree?
	LD	A,(DE)
	XOR	(HL)
	AND	0FH
	JP	NZ,SEARCH$H2	; no
	; set xdcnt
	JP	SEARCH$H55
SEARCH$H5:
	; xdcnt+1 = 0ffh
	; Make search to save dcnt of empty fcb
	; is hash$tbl entry empty?
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
	; hash$mask = 0e0h if hashl = 3
	;           = 0c0h if hashl = 2
	LD	C,A
	RRCA
	RRCA
	RRA
	LD	B,A
	; hash s field does not pertain if hashl ~= 3
	; Does hash(0) fields match?
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
SEARCH$H7:
	; Return to bnkbdos
	PUSH	AF
	XOR	A
	CALL	SELMEMF
	POP	AF
	RET

SUBDH:
	;compute HL = DE - HL
	LD	A,E
	SUB	L
	LD	L,A
	LD	A,D
	SBC	A,H
	LD	H,A
	RET

COMPARE:
	LD	A,(DE)
	CP	(HL)
	RET	NZ
	INC	HL
	INC	DE
	DEC	C
	RET	Z
	JP	COMPARE

;	Disk Function Copy Table

CDMAIN	EQU	00000001B;copy 1ST 16 bytes of DMA to
	;common$dma on entry
FCBIN	EQU	00000010B	;fcb copy on entry
FCBOUT	EQU	10000000B	;fcb copy on exit
PFCBOUT EQU	01000000B	;random fcb copy on exit
CDMA128 EQU	00100000B	;copy 1st 128 bytes of common$dma
	;to DMA on exit
TIMEOUT EQU	00010000B	;copy date & time on exit
CDMA003 EQU	00001000B	;copy 1ST 3 bytes of common$dma
	;to DMA on exit
SEROUT	EQU	00000100B	;copy serial # on exit

DFCTBL:
	DEFB	0		; 12=return version #
	DEFB	0		; 13=reset disk system
	DEFB	0		; 14=select disk
	DEFB	FCBIN+FCBOUT+CDMAIN; 15=open file
	DEFB	FCBIN+FCBOUT	; 16=close file
	DEFB	FCBIN+CDMA128	; 17=search first
	DEFB	FCBIN+CDMA128	; 18=search next
	DEFB	FCBIN+CDMAIN	; 19=delete file
	DEFB	FCBIN+FCBOUT	; 20=read sequential
	DEFB	FCBIN+FCBOUT	; 21=write sequential
	DEFB	FCBIN+FCBOUT+CDMAIN; 22=make file
	DEFB	FCBIN+CDMAIN	; 23=rename file
	DEFB	0		; 24=return login vector
	DEFB	0		; 25=return current disk
	DEFB	0		; 26=set DMA address
	DEFB	0		; 27=get alloc address
	DEFB	0		; 28=write protect disk
	DEFB	0		; 29=get R/O vector
	DEFB	FCBIN+FCBOUT+CDMAIN; 30=set file attributes
	DEFB	0		; 31=get disk param addr
	DEFB	0		; 32=get/set user code
	DEFB	FCBIN+FCBOUT	; 33=read random
	DEFB	FCBIN+FCBOUT	; 34=write random
	DEFB	FCBIN+PFCBOUT	; 35=compute file size
	DEFB	FCBIN+PFCBOUT	; 36=set random record
	DEFB	0		; 37=drive reset
	DEFB	0		; 38=access drive
	DEFB	0		; 39=free drive
	DEFB	FCBIN+FCBOUT	; 40=write random w/ zero fill

	DEFB	FCBIN+FCBOUT	; 41=test & write record
	DEFB	0		; 42=record lock
	DEFB	0		; 43=record unlock
	DEFB	0		; 44=set multi-sector count
	DEFB	0		; 45=set BDOS error mode
	DEFB	CDMA003		; 46=get disk free space
	DEFB	0		; 47=chain to program
	DEFB	0		; 48=flush buffers
	DEFB	FCBIN		; 49=Get/Set system control block
	DEFB	FCBIN		; 50=direct BIOS call (CP/M)
NDF	EQU	($-DFCTBL)+12

XDFCTBL:
	DEFB	0		; 98=reset allocation vectors
	DEFB	FCBIN+CDMAIN	; 99=truncate file
	DEFB	FCBIN+CDMAIN	; 100=set directory label
	DEFB	0		; 101=return directory label data
	DEFB	FCBIN+FCBOUT+CDMAIN; 102=read file xfcb
	DEFB	FCBIN+CDMAIN	; 103=write or update file xfcb
	DEFB	FCBIN		; 104=set current date and time
	DEFB	FCBIN+TIMEOUT	; 105=get current date and time
	DEFB	FCBIN		; 106=set default password
	DEFB	FCBIN+SEROUT	; 107=return serial number
	DEFB	0		; 108=get/set program return code
	DEFB	0		; 109=get/set console mode
	DEFB	0		; 110=get/set output delimiter
	DEFB	0		; 111=print block
	DEFB	0		; 112=list block

NXDF	EQU	($-XDFCTBL)+98

RES$FX:	DEFS	1
HASH$TBLA:
	DEFS	2
BANK:	DEFS	1
ARET:	DEFS	2		;address value to return

BUFFER:	;function 10 256 byte buffer

COMMONFCB:
	DEFS	36		;fcb copy in common memory

COMMON$DMA:
	DEFS	220		;function 10 buffer cont.

	DEFS	SSIZE*2
LSTACK:
ENTSP:	DEFS	2

; BIOS intercept vector

WBOOTFX:JP	WBOOTF
	JP	SWITCH1
CONSTFX:JP	CONSTF
	JP	SWITCH1
CONINFX:JP	CONINF
	JP	SWITCH1
CONOUTFX: JP	CONOUTF
	JP	SWITCH1
LISTFX:	JP	LISTF
	JP	SWITCH1

	DEFW	0,0,0
	DEFW	0
	DEFW	0

OLOG:	DEFW	0
RLOG:	DEFW	0

PATCH$FLGS: DEFB	0,0,0,7	;[JCE] Patchlevel 7

; Base of RESBDOS

	DEFW	BASE+6

; Reserved for use by non-banked BDOS

	DEFS	2

; System Control Block

SCB:

; Expansion Area - 6 bytes

HASHL:	DEFB	0	;hash length (0,2,3)
HASH:	DEFW	0,0		;hash entry
VERSION:DEFB	31H		;version 3.1

; Utilities Section - 8 bytes

UTIL$FLGS: DEFW	0,0
DSPL$FLGS: DEFW	0
	DEFW	0

; CLP Section - 4 bytes

CLP$FLGS: DEFW	0
CLP$ERRCDE: DEFW	0

; CCP Section - 8 bytes

CCP$COMLEN: DEFB	0
CCP$CURDRV: DEFB	0
CCP$CURUSR: DEFB	0
CCP$CONBUFF: DEFW	0
CCP$FLGS: DEFW	0
	DEFB	0

; Device I/O Section - 32 bytes

CONWIDTH: DEFB	0
COLUMN:	DEFB	0
CONPAGE:DEFB	0
CONLINE:DEFB	0
CONBUFFADD: DEFW	0
CONBUFFLEN: DEFW	0
CONIN$RFLG: DEFW	0
CONOUT$RFLG: DEFW	0
AUXIN$RFLG: DEFW	0
AUXOUT$RFLG: DEFW	0
LSTOUT$RFLG: DEFW	0
PAGE$MODE: DEFB	0
PM$DEFAULT: DEFB	0
CTLH$ACT: DEFB	0
RUBOUT$ACT: DEFB	0
TYPE$AHEAD: DEFB	0
CONTRAN:DEFW	0
CONMODE:DEFW	0
	DEFW	BUFFER+64
OUTDELIM: DEFB	'$'
LISTCP:	DEFB	0
QFLAG:	DEFB	0

; BDOS Section - 42 bytes

SCBADD:	DEFW	SCB
DMAAD:	DEFW	0080H
SELDSK:	DEFB	0
INFO:	DEFW	0
RESEL:	DEFB	0
RELOG:	DEFB	0
FX:	DEFB	0
USRCODE:DEFB	0
DCNT:	DEFW	0
SEARCHA:DEFW	0
SEARCHL:DEFB	0
MULTCNT:DEFB	1
ERRORMODE: DEFB	0
SEARCHCHAIN: DEFB	0,0FFH,0FFH,0FFH
TEMP$DRIVE: DEFB	0
ERRDRV:	DEFB	0
	DEFW	0
MEDIA$FLAG: DEFB	0
	DEFW	0
BDOS$FLAGS: DEFB	80H
STAMP:	DEFB	0FFH,0FFH,0FFH,0FFH,0FFH
COMMONBASE: DEFW	0
ERROR:	JP	ERROR$JMP
BDOSADD:DEFW	BASE+6
	END


