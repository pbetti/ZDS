
	TITLE	'CP/M V3.1 Loader'


;	Copyright (C) 1982
;	Digital Research
;	Box 579, Pacific Grove
;	California, 93950

;  Revised:
;    01 Nov 82  by Bruce Skidmore

;
; [JCE] Have the date and copyright messages in only one source file
;
@BDATE	MACRO
	DEFB	'101814'
	ENDM

@LCOPY	MACRO
	DEFB	'Copyright 2014, '
	DEFB	'P. Betti        '
	ENDM

@SCOPY	MACRO
	DEFB	'(C) 98 Caldera'
	ENDM
;
BASE	EQU	$
ABASE	EQU	BASE-0100H

CR	EQU	0DH
LF	EQU	0AH

FCB	EQU	ABASE+005CH	;default FCB address
BUFF	EQU	ABASE+0080H	;default buffer address

;
;	System Equates
;
RESETSYS 	EQU	13		;reset disk system
PRINTBUF 	EQU	09		;print string
OPEN$FUNC 	EQU	15		;open function
READ$FUNC 	EQU	20		;read sequential
SETDMA$FUNC	EQU	26		;set dma address
;
;	Loader Equates
;
COMTOP	EQU	ABASE+80H
COMLEN	EQU	ABASE+81H
BNKTOP	EQU	ABASE+82H
BNKLEN	EQU	ABASE+83H
OSENTRY EQU	ABASE+84H

	CSEG

	LD	SP,STACKBOT

	CALL	BOOTF		;first call is to Cold Boot

	LD	C,RESETSYS	;Initialize the System
	CALL	BDOS

	LD	C,PRINTBUF	;print the sign on message
	LD	DE,SIGNON
	CALL	BDOS

	LD	C,OPEN$FUNC	;open the CPM3.SYS file
	LD	DE,CPMFCB
	CALL	BDOS
	CP	0FFH
	LD	DE,OPENERR
	JP	Z,ERROR

	LD	DE,BUFF
	CALL	SETDMA$PROC

	CALL	READ$PROC	;read the load record

	LD	HL,BUFF
	LD	DE,MEM$TOP
	LD	C,6
CLOOP:
	LD	A,(HL)
	LD	(DE),A
	INC	DE
	INC	HL
	DEC	C
	JP	NZ,CLOOP

	CALL	READ$PROC	;read display info

	LD	C,PRINTBUF	;print the info
	LD	DE,BUFF
	CALL	BDOS

;
;	Main System Load
;

;
;	Load Common Portion of System
;
	LD	A,(RES$LEN)
	LD	H,A
	LD	A,(MEM$TOP)
	CALL	LOAD
;
;	Load Banked Portion of System
;
	LD	A,(BANK$LEN)
	OR	A
	JP	Z,EXECUTE
	LD	H,A
	LD	A,(BANK$TOP)
	CALL	LOAD
;
;	Execute System
;
EXECUTE:
	LD	HL,FCB+1
	LD	A,(HL)
	CP	'$'
	JP	NZ,EXECUTE$SYS
	INC	HL
	LD	A,(HL)
	CP	'B'
	CALL	Z,BREAK
EXECUTE$SYS:
	LD	SP,OSENTRY$ADR
	RET

;
;	Load Routine
;
;	Input:   A = Page Address of load top
;		 H = Length in pages of module to read
;
LOAD:
	OR	A		;clear carry
	LD	D,A
	LD	E,0
	LD	A,H
	RLA
	LD	H,A		;h = length in records of module
LOOP:
	EX	DE,HL
	LD	BC,-128
	ADD	HL,BC		;decrement dma address by 128
	EX	DE,HL
	PUSH	DE
	PUSH	HL
	CALL	SETDMA$PROC
	CALL	READ$PROC
	POP	HL
	POP	DE
	DEC	H
	JP	NZ,LOOP
	RET

;
;	Set DMA Routine
;
SETDMA$PROC:
	LD	C,SETDMA$FUNC
	CALL	BDOS
	RET

;
;	Read Routine
;
READ$PROC:
	LD	C,READ$FUNC	;Read the load record
	LD	DE,CPMFCB	;into address 80h
	CALL	BDOS
	OR	A
	LD	DE,READERR
	RET	Z
;
;	Error Routine
;
ERROR:
	LD	C,PRINTBUF	;print error message
	CALL	BDOS
	DI
	HALT

BREAK:
	DEFB	0FFH
	RET

CPMFCB:
	DEFB	0,'CPM3    SYS',0,0,0,0,0,0
	DEFW	0,0,0,0,0,0,0,0,0

OPENERR:
	DEFB	CR,LF
	DEFB	'CPMLDR error:  failed to open CPM3.SYS'
	DEFB	CR,LF,'$'

READERR:
	DEFB	CR,LF
	DEFB	'CPMLDR error:  failed to read CPM3.SYS'
	DEFB	CR,LF,'$'

SIGNON:
	DEFB	CR,LF
	DEFB	'CP/M V3.1 Loader',CR,LF
	DEFB	'Copyright (C) 1998, Caldera Inc.    '
	DEFB	CR,LF,'2014 (c) Piergiorgio Betti'
	DEFB	CR,LF,'$'

	@BDATE		;[JCE] Build date
	DEFB	0,0,0,0
STACKBOT:

MEM$TOP:
	DEFS	1
RES$LEN:
	DEFS	1
BANK$TOP:
	DEFS	1
BANK$LEN:
	DEFS	1
OSENTRY$ADR:
	DEFS	2

;	title	'CP/M 3.0 LDRBDOS Interface, Version 3.1 Nov, 1982'
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
;       Nov 1982
;
;
;	equates for non graphic characters
;

RUBOUT	EQU	7FH	; char delete
TAB	EQU	09H		; tab char
CR	EQU	0DH		; carriage return
LF	EQU	0AH		; line feed
CTLH	EQU	08H		; backspace


;
SERIAL:	DEFB	0,0,0,0,0,0
;
;	Enter here from the user's program with function number in c,
;	and information address in d,e
;

BDOS:
BDOSE:	; Arrive here from user programs
	EX	DE,HL
	LD	(INFO),HL
	EX	DE,HL		; info=de, de=info

	LD	A,C
	CP	14
	JP	C,BDOSE2
	LD	(FX),A		; Save disk function #
	XOR	A
	LD	(DIRCNT),A
	LD	A,(SELDSK)
	LD	(OLDDSK),A	; Save seldsk

BDOSE2:
	LD	A,E
	LD	(LINFO),A	; linfo = low(info) - don't equ
	LD	HL,0
	LD	(ARET),HL	; Return value defaults to 0000
	LD	(RESEL),HL	; resel = 0
	; Save user's stack pointer, set to local stack
	ADD	HL,SP
	LD	(ENTSP),HL	; entsp = stackptr

	LD	SP,LSTACK	; local stack setup

	LD	HL,GOBACK	; Return here after all functions
	PUSH	HL		; jmp goback equivalent to ret
	LD	A,C
	CP	NFUNCS
	JP	NC,HIGH$FXS	; Skip if invalid #
	LD	C,E		; possible output character to c
	LD	HL,FUNCTAB
	JP	BDOS$JMP

	; look for functions 100 ->
HIGH$FXS:
	SBC	A,100
	JP	C,LRET$EQ$FF	; Skip if function < 100

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


;	dispatch table for functions

FUNCTAB:
	DEFW	FUNC$RET, FUNC1, FUNC2, FUNC3
	DEFW	FUNC$RET, FUNC$RET, FUNC6, FUNC$RET
	DEFW	FUNC$RET, FUNC9, FUNC10, FUNC11
DISKF	EQU	($-FUNCTAB)/2	; disk funcs
	DEFW	FUNC12,FUNC13,FUNC14,FUNC15
	DEFW	FUNC16,FUNC17,FUNC18,FUNC19
	DEFW	FUNC20,FUNC21,FUNC22,FUNC23
	DEFW	FUNC24,FUNC25,FUNC26,FUNC27
	DEFW	FUNC28,FUNC29,FUNC30,FUNC31
	DEFW	FUNC32,FUNC33,FUNC34,FUNC35
	DEFW	FUNC36,FUNC37,FUNC38,FUNC39
	DEFW	FUNC40,FUNC42,FUNC43
	DEFW	FUNC44,FUNC45,FUNC46,FUNC47
	DEFW	FUNC48,FUNC49,FUNC50
NFUNCS	EQU	($-FUNCTAB)/2


ENTSP:	DEFS	2	; entry stack pointer

	;	40 level stack

	DEFW	0C7C7H,0C7C7H,0C7C7H,0C7C7H,0C7C7H,0C7C7H,0C7C7H,0C7C7H
	DEFW	0C7C7H,0C7C7H,0C7C7H,0C7C7H,0C7C7H,0C7C7H,0C7C7H,0C7C7H
	DEFW	0C7C7H,0C7C7H,0C7C7H,0C7C7H,0C7C7H,0C7C7H,0C7C7H,0C7C7H
	DEFW	0C7C7H,0C7C7H,0C7C7H,0C7C7H,0C7C7H,0C7C7H,0C7C7H,0C7C7H
	DEFW	0C7C7H,0C7C7H,0C7C7H,0C7C7H,0C7C7H,0C7C7H,0C7C7H,0C7C7H
LSTACK:


PAGE
	TITLE	"CP/M 3.0 LDRBDOS Interface, Version 3.1 July, 1982"
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
;       July, 1982
;
;
;	console handlers

CONOUT:
	;compute character position/write console char from C
	;compcol = true if computing column position
	LD	A,(COMPCOL)
	OR	A
	JP	NZ,COMPOUT
	;write the character, then compute the column
	;write console character from C
	PUSH	BC		;recall/save character
	CALL	CONOUTF		;externally, to console
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
	;not at zero, may be backspace or eol
	LD	A,C		;character back to A
	CP	CTLH
	JP	NZ,NOTBACKSP
	;backspace character
	DEC	(HL)		;column = column - 1
	RET

NOTBACKSP:
	;not a backspace character, eol?
	CP	LF
	RET	NZ		;return if not
	;end of line, column = 0
	LD	(HL),0		;column = 0
	RET
;
;
TABOUT:
	;expand tabs to console
	LD	A,C
	CP	TAB
	JP	NZ,CONOUT	;direct to conout if not
	;tab encountered, move to next tab pos
TAB0:
	LD	C,' '
	CALL	CONOUT		;another blank
	LD	A,(COLUMN)
	AND	111B		;column mod 8 = 0 ?
	JP	NZ,TAB0		;back for another if not
	RET
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
;
FUNC2 	EQU	TABOUT
	;write console character with tab expansion
;
FUNC9:
	;write line until $ encountered
	EX	DE,HL		;was lhld info
	LD	C,L
	LD	B,H		;BC=string address
	JP	PRINT		;out to console
;
STA$RET:
	;store the A register to aret
	LD	(ARET),A
FUNC$RET:
	RET			;jmp goback (pop stack for non cp/m functions)
;
SETLRET1:
	;set lret = 1
	LD	A,1
	JP	STA$RET
;
FUNC1 	EQU 	FUNC$RET
;
FUNC3 	EQU 	FUNC$RET
;
FUNC6 	EQU 	FUNC$RET
;
FUNC10 	EQU	FUNC$RET
FUNC11 	EQU	FUNC$RET
;
;	data areas
;


COMPCOL:DEFB	0	;true if computing column position
;	end of BDOS Console module

;**********************************************************************
;*****************************************************************
;
;	Error Messages

MD	EQU	24H

ERR$MSG:DEFB	CR,LF,'BDOS ERR: ',MD
ERR$SELECT: DEFB	'Select',MD
ERR$PHYS: DEFB	'Perm.',MD

;*****************************************************************
;*****************************************************************
;
;	common values shared between bdosi and bdos


ARET:	DEFS	2	; address value to return
LRET	EQU	ARET		; low(aret)

;*****************************************************************
;*****************************************************************
;**                                                             **
;**   b a s i c    d i s k   o p e r a t i n g   s y s t e m    **
;**                                                             **
;*****************************************************************
;*****************************************************************

;	literal constants

TRUE	EQU	0FFH		; constant true
FALSE	EQU	000H		; constant false
ENDDIR	EQU	0FFFFH		; end of directory
LBYTE	EQU	1		; number of bytes for "byte" type
LWORD	EQU	2		; number of bytes for "word" type

;	fixed addresses in low memory

TBUFF	EQU	0080H		; default buffer location

;	error message handlers

SEL$ERROR:
	; report select error
	LD	BC,ERR$MSG
	CALL	PRINT
	LD	BC,ERR$SELECT
	JP	GOERR1

GOERR:
	LD	BC,ERR$MSG
	CALL	PRINT
	LD	BC,ERR$PHYS
GOERR1:
	CALL	PRINT
	DI
	HALT

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
	INC	HL
	INC	HL
	LD	(CURTRKA),HL
	INC	HL
	INC	HL		; hl=.currec
	LD	(CURRECA),HL
	INC	HL
	INC	HL		; hl=.buffa
	INC	HL
	INC	HL
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

	RET

PASS$ARECORD:
	LD	HL,ARECORD
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	B,(HL)
	RET

RDBUFF:
	; Read buffer and check condition
	CALL	PASS$ARECORD
	CALL	READF		; current drive, track, sector, dma


DIOCOMP:; Check for disk errors
	OR	A
	RET	Z
	LD	C,A
	CP	3
	JP	C,GOERR
	LD	C,1
	JP	GOERR

SEEKDIR:
	; Seek the record containing the current dir entry

	LD	HL,(DCNT)	; directory counter to hl
	LD	C,DSKSHF
	CALL	HLROTR		; value to hl

	LD	B,0
	EX	DE,HL

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

SHR$PHYSHF:
	LD	A,(PHYSHF)
	LD	C,A
	JP	HLROTR


;	file control block (fcb) constants

EMPTY	EQU	0E5H		; empty directory entry
RECSIZ	EQU	128		; record size
FCBLEN	EQU	32		; file control block size
DIRREC	EQU	RECSIZ/FCBLEN	; directory fcbs / record
DSKSHF	EQU	2		; log2(dirrec)
DSKMSK	EQU	DIRREC-1
FCBSHF	EQU	5		; log2(fcblen)

EXTNUM	EQU	12	; extent number field
MAXEXT	EQU	31		; largest extent number
UBYTES	EQU	13		; unfilled bytes field

NAMLEN	EQU	15	; name length
RECCNT	EQU	15		; record count field
DSKMAP	EQU	16		; disk map field
NXTREC	EQU	FCBLEN

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
	LD	(RCOUNT),A	; rcount=fcb(reccnt)
	CALL	GETEXTA		; hl=.fcb(extnum)
	LD	A,(EXTMSK)	; extent mask to a
	AND	(HL)		; fcb(extnum) and extmsk
	LD	(EXTVAL),A
	RET

SETFCB:
	; Place values back into current fcb
	CALL	GETFCBA		; addresses to de, hl
	LD	C,1

	LD	A,(VRECORD)
	ADD	A,C
	LD	(HL),A		; fcb(nxtrec)=vrecord+seqio
	EX	DE,HL
	LD	A,(RCOUNT)
	LD	(HL),A		; fcb(reccnt)=rcount
	RET

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

HLROTL:
	; Rotate the mask in hl by amount in c
	INC	C		; may be zero
HLROTL0:DEC	C
	RET	Z		; return if zero

	ADD	HL,HL
	JP	HLROTL0

SET$CDISK:
	; Set a "1" value in curdsk position of bc
	LD	A,(SELDSK)
	PUSH	BC		; Save input parameter
	LD	C,A		; Ready parameter for shift
	LD	HL,1		; number to shift
	CALL	HLROTL		; hl = mask to integrate
	POP	BC		; original mask
	LD	A,C
	OR	L
	LD	L,A
	LD	A,B
	OR	H
	LD	H,A		; hl = mask or rol(1,curdsk)
	RET

TEST$VECTOR:
	LD	A,(SELDSK)
	LD	C,A
	CALL	HLROTR
	LD	A,L
	AND	1B
	RET			; non zero if curdsk bit on

GETDPTRA:
	; Compute the address of a directory element at
	; positon dptr in the buffer

	LD	HL,(BUFFA)
	LD	A,(DPTR)
	; hl = hl + a
	ADD	A,L
	LD	L,A
	RET	NC
	; overflow to h
	INC	H
	RET

CLR$EXT:
	; fcb ext = fcb ext & 1fh

	CALL	GETEXTA
	LD	A,(HL)
	AND	00011111B
	LD	(HL),A
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

GETBUFFA:
	PUSH	DE
	LD	DE,10
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	POP	DE
	RET


RDDIR:
	; Read a directory entry into the directory buffer
	CALL	SEEKDIR
	LD	A,(PHYMSK)
	OR	A
	JP	Z,RDDIR1
	LD	A,3
	CALL	DEBLOCK$DIR
	JP	SETDATA

RDDIR1:
	CALL	SETDIR		; directory dma
	LD	(BUFFA),HL
	CALL	SEEK
	CALL	RDBUFF		; directory record loaded

SETDATA:
	; Set data dma address
	LD	HL,(DMAAD)
	JP	SETDMA		; to complete the call

SETDIR:
	; Set directory dma address

	LD	HL,(DIRBCBA)
	CALL	GETBUFFA

SETDMA:
	; hl=.dma address to set (i.e., buffa or dmaad)
	LD	(CURDMA),HL
	RET

END$OF$DIR:
	; Return zero flag if at end of directory, non zero
	; if not at end (end of dir if dcnt = 0ffffh)
	LD	HL,DCNT
	LD	A,(HL)		; may be 0ffh
	INC	HL
	CP	(HL)		; low(dcnt) = high(dcnt)?
	RET	NZ		; non zero returned if different
	; high and low the same, = 0ffh?
	INC	A		; 0ffh becomes 00 if so
	RET

SET$END$DIR:
	; Set dcnt to the end of the directory
	LD	HL,ENDDIR
	LD	(DCNT),HL
	RET


READ$DIR:
	; Read next directory entry, with c=true if initializing

	LD	HL,(DIRMAX)
	EX	DE,HL		; in preparation for subtract
	LD	HL,(DCNT)
	INC	HL
	LD	(DCNT),HL	; dcnt=dcnt+1

	; while(dirmax >= dcnt)
	CALL	SUBDH		; de-hl
	JP	C,SET$END$DIR
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

	PUSH	BC		; Save initialization flag c
	CALL	RDDIR		; Read the directory record
	POP	BC		; Recall initialization flag
	RET
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


SEARCH:
	; Search for directory element of length c at info
	LD	HL,(INFO)
	LD	(SEARCHA),HL	; searcha = info
	LD	A,C
	LD	(SEARCHL),A	; searchl = c

	CALL	SET$END$DIR	; dcnt = enddir
	CALL	HOME		; to start at the beginning

SEARCHN:
	; Search for the next directory element, assuming
	; a previous call on search which sets searcha and
	; searchl

	LD	C,FALSE
	CALL	READ$DIR	; Read next dir element
	CALL	END$OF$DIR
	JP	Z,LRET$EQ$FF
	; not end of directory, scan for match
	LD	HL,(SEARCHA)
	EX	DE,HL		; de=beginning of user fcb

	CALL	GETDPTRA	; hl = buffa+dptr
	LD	A,(SEARCHL)
	LD	C,A		; length of search to c
	LD	B,0		; b counts up, c counts down

	LD	A,(HL)
	CP	EMPTY
	JP	Z,SEARCHN

SEARCHLOOP:
	LD	A,C
	OR	A
	JP	Z,ENDSEARCH
	; Scan next character if not ubytes
	LD	A,B
	CP	UBYTES
	JP	Z,SEARCHOK
	; not the ubytes field, extent field?
	CP	EXTNUM		; may be extent field
	JP	Z,SEARCHEXT	; Skip to search extent
	LD	A,(DE)
	SUB	(HL)
	AND	7FH		; Mask-out flags/extent modulus
	JP	NZ,SEARCHN	; Skip if not matched
	JP	SEARCHOK	; matched character
SEARCHEXT:
	LD	A,(DE)
	; Attempt an extent # match
	PUSH	BC		; Save counters
	LD	C,(HL)		; directory character to c
	CALL	COMPEXT		; Compare user/dir char
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
	XOR	A
	LD	(LRET),A	; lret = 0
	; successful search -
	; return with zero flag reset
	LD	B,A
	INC	B
	RET
LRET$EQ$FF:
	; unsuccessful search -
	; return with zero flag set
	; lret,low(aret) = 0ffh
	LD	A,255
	LD	B,A
	INC	B
	JP	STA$RET

OPEN:
	; Search for the directory entry, copy to fcb
	LD	C,NAMLEN
	CALL	SEARCH
	RET	Z		; Return with lret=255 if end

	; not end of directory, copy fcb information
OPEN$COPY:
	CALL	GETEXTA
	LD	A,(HL)
	PUSH	AF		; save extent to check for extent
	; folding - move moves entire dir FCB
	CALL	GETDPTRA
	EX	DE,HL		; hl = .buff(dptr)
	LD	HL,(INFO)	; hl=.fcb(0)
	LD	C,NXTREC	; length of move operation
	CALL	MOVE		; from .buff(dptr) to .fcb(0)

	; Note that entire fcb is copied, including indicators

	CALL	GET$DIR$EXT
	LD	C,A
	POP	AF
	LD	(HL),A		; restore extent

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
	LD	A,(DE)
	SUB	C
	JP	Z,SET$RC2
	LD	A,B
	JP	NC,SET$RC1
	LD	A,128
	LD	B,(HL)

SET$RC1:
	LD	(HL),A
	LD	A,B
	LD	(ACTUAL$RC),A
	RET
SET$RC2:
	LD	(ACTUAL$RC),A
	LD	A,(HL)
	OR	A
	RET	NZ		; ret if rc ~= 0
	LD	A,(DMINX)
	OR	A
	RET	Z		; ret if no blks in fcb
	LD	A,(FX)
	CP	15
	RET	Z		; ret if fx = 15
	LD	(HL),128	; rc = 128
	RET

RESTORE$RC:
	; hl = .fcb(extnum)
	; if actual$rc ~= 0 then rcount = actual$rc
	PUSH	HL
	LD	A,(ACTUAL$RC)
	OR	A
	JP	Z,RESTORE$RC1
	LD	DE,[RECCNT-EXTNUM]
	ADD	HL,DE
	LD	(HL),A
	XOR	A
	LD	(ACTUAL$RC),A

RESTORE$RC1:
	POP	HL
	RET

OPEN$REEL:
	; Close the current extent, and open the next one
	; if possible.

	CALL	GETEXTA
	LD	A,(HL)
	LD	C,A
	INC	C
	CALL	COMPEXT
	JP	Z,OPEN$REEL3

	LD	A,MAXEXT
	AND	C
	LD	(HL),A		; Incr extent field
	LD	C,NAMLEN
	CALL	SEARCH		; Next extent found?
	; not end of file, open
	CALL	OPEN$COPY

OPEN$REEL2:
	CALL	GETFCB		; Set parameters
	XOR	A
	LD	(VRECORD),A
	JP	STA$RET		; lret = 0
OPEN$REEL3:
	INC	(HL)		; fcb(ex) = fcb(ex) + 1
	CALL	GET$DIR$EXT
	LD	C,A
	; Is new extent beyond dir$ext?
	CP	(HL)
	JP	NC,OPEN$REEL4	; no
	DEC	(HL)		; fcb(ex) = fcb(ex) - 1
	JP	SETLRET1
OPEN$REEL4:
	CALL	RESTORE$RC
	CALL	SET$RC
	JP	OPEN$REEL2

SEQDISKREAD:
	; Sequential disk read operation
	; Read the next record from the current fcb

	CALL	GETFCB		; sets parameters for the read

	LD	A,(VRECORD)
	LD	HL,RCOUNT
	CP	(HL)		; vrecord-rcount
	; Skip if rcount > vrecord
	JP	C,RECORDOK

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

	CALL	INDEX		; Z flag set if arecord = 0

	JP	Z,SETLRET1	; Reading unwritten data

	; Record has been allocated
	CALL	ATRAN		; arecord now a disk address

	LD	A,(PHYMSK)
	OR	A		; if not 128 byte sectors
	JP	NZ,READ$DEBLOCK	; go to deblock

	CALL	SETDATA		; Set curdma = dmaad
	CALL	SEEK		; Set up for read
	CALL	RDBUFF		; Read into (curdma)
	JP	SETFCB		; Update FCB

CURSELECT:
	LD	A,(SELDSK)
	INC	A
	JP	Z,SEL$ERROR
	DEC	A
	LD	HL,CURDSK
	CP	(HL)
	RET	Z

	; Skip if seldsk = curdsk, fall into select
SELECT:
	; Select disk info for subsequent input or output ops
	LD	(HL),A		; curdsk = seldsk

	LD	D,A		; Save seldsk in register D for selectdisk call
	LD	HL,(DLOG)
	CALL	TEST$VECTOR	; test$vector does not modify DE
	LD	E,A
	PUSH	DE		; Send to seldsk, save for test below
	CALL	SELECTDISK
	POP	HL		; Recall dlog vector
	JP	NC,SEL$ERROR	; returns with C flag set if select ok
	; Is the disk logged in?
	DEC	L		; reg l = 1 if so
	RET	Z		; yes - drive previously logged in

	LD	HL,(DLOG)
	LD	C,L
	LD	B,H		; call ready
	CALL	SET$CDISK
	LD	(DLOG),HL	; dlog=set$cdisk(dlog)
	RET

SET$SELDSK:
	LD	A,(LINFO)
	LD	(SELDSK),A
	RET

RESELECTX:
	XOR	A
	LD	(HIGH$EXT),A
	JP	RESELECT1
RESELECT:
	; Check current fcb to see if reselection necessary
	LD	A,80H
	LD	B,A
	DEC	A
	LD	C,A		; b = 80h, c = 7fh
	LD	HL,(INFO)
	LD	DE,7
	EX	DE,HL
	ADD	HL,DE
	LD	A,(HL)
	AND	B
	; fcb(7) = fcb(7) & 7fh
	LD	A,(HL)
	AND	C
	LD	(HL),A
	; high$ext = 80h & fcb(8)
	INC	HL
	LD	A,(HL)
	AND	B
	LD	(HIGH$EXT),A
	; fcb(8) = fcb(8) & 7fh
	LD	A,(HL)
	AND	C
	LD	(HL),A
	; fcb(ext) = fcb(ext) & 1fh
	CALL	CLR$EXT

	; if fcb(rc) & 80h
	;    then fcb(rc) = 80h, actual$rc = fcb(rc) & 7fh
	;    else actual$rc = 0

	CALL	GETRCNTA
	LD	A,(HL)
	AND	B
	JP	Z,RESELECT1
	LD	A,(HL)
	AND	C
	LD	(HL),B

RESELECT1:
	LD	(ACTUAL$RC),A

	LD	HL,0
	LD	(FCBDSK),HL	; fcbdsk = 0
	LD	A,TRUE
	LD	(RESEL),A	; Mark possible reselect
	LD	HL,(INFO)
	LD	A,(HL)		; drive select code
	AND	00011111B		; non zero is auto drive select
	DEC	A		; Drive code normalized to 0..30, or 255
	LD	(LINFO),A	; Save drive code
	CP	0FFH
	JP	Z,NOSELECT
	; auto select function, seldsk saved above
	LD	A,(HL)
	LD	(FCBDSK),A	; Save drive code
	CALL	SET$SELDSK

NOSELECT:
	CALL	CURSELECT
	LD	A,0
	LD	HL,(INFO)
	LD	(HL),A
	RET

;
;	individual function handlers
;

FUNC12	EQU	FUNC$RET

FUNC13:

	; Reset disk system - initialize to disk 0
	LD	HL,0
	LD	(DLOG),HL

	XOR	A
	LD	(SELDSK),A
	DEC	A
	LD	(CURDSK),A

	LD	HL,TBUFF
	LD	(DMAAD),HL	; dmaad = tbuff
	JP	SETDATA		; to data dma address

FUNC14:
	; Select disk info
	CALL	SET$SELDSK	; seldsk = linfo
	JP	CURSELECT

FUNC15:
	; Open file
	CALL	RESELECTX
	CALL	OPEN
	CALL	OPENX		; returns if unsuccessful, a = 0
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
	LD	C,01000000B
	RET

FUNC16	EQU	FUNC$RET

FUNC17	EQU	FUNC$RET

FUNC18	EQU	FUNC$RET

FUNC19	EQU	FUNC$RET

FUNC20:
	; Read a file
	CALL	RESELECT
	JP	SEQDISKREAD

FUNC21	EQU	FUNC$RET

FUNC22	EQU	FUNC$RET

FUNC23	EQU	FUNC$RET

FUNC24	EQU	FUNC$RET

FUNC25:	LD	A,(SELDSK)
	JP	STA$RET

FUNC26:	EX	DE,HL
	LD	(DMAAD),HL
	JP	SETDATA

FUNC27	EQU	FUNC$RET

FUNC28 	EQU FUNC$RET

FUNC29	EQU	FUNC$RET

FUNC30	EQU	FUNC$RET

FUNC31	EQU	FUNC$RET

FUNC32	EQU	FUNC$RET

FUNC33	EQU	FUNC$RET

FUNC34	EQU	FUNC$RET

FUNC35	EQU	FUNC$RET

FUNC36	EQU	FUNC$RET

FUNC37	EQU	FUNC$RET

FUNC38	EQU	FUNC$RET

FUNC39	EQU	FUNC$RET

FUNC40	EQU	FUNC$RET

FUNC42	EQU	FUNC$RET

FUNC43	EQU	FUNC$RET

FUNC44	EQU	FUNC$RET

FUNC45	EQU	FUNC$RET

FUNC46	EQU	FUNC$RET

FUNC47	EQU	FUNC$RET

FUNC48	EQU	FUNC$RET

FUNC49	EQU	FUNC$RET

FUNC50	EQU	FUNC$RET

FUNC100 EQU	FUNC$RET

FUNC101 EQU	FUNC$RET

FUNC102 EQU	FUNC$RET

FUNC103 EQU	FUNC$RET

FUNC104 EQU	FUNC$RET

FUNC105 EQU	FUNC$RET

FUNC106 EQU	FUNC$RET

FUNC107 EQU	FUNC$RET

FUNC108 EQU	FUNC$RET

FUNC109 EQU	FUNC$RET


GOBACK:
	; Arrive here at end of processing to return to user
	LD	A,(FX)
	CP	15
	JP	C,RETMON
	LD	A,(OLDDSK)
	LD	(SELDSK),A	; Restore seldsk
	LD	A,(RESEL)
	OR	A
	JP	Z,RETMON

	LD	HL,(INFO)
	LD	(HL),0		; fcb(0)=0
	LD	A,(FCBDSK)
	OR	A
	JP	Z,GOBACK1
	; Restore fcb(0)
	LD	(HL),A		; fcb(0)=fcbdsk
GOBACK1:
	; fcb(8) = fcb(8) | high$ext
	INC	HL
	LD	A,(HIGH$EXT)
	OR	(HL)
	LD	(HL),A
	; fcb(rc) = fcb(rc) | actual$rc
	CALL	GETRCNTA
	LD	A,(ACTUAL$RC)
	OR	(HL)
	LD	(HL),A
	; return from the disk monitor
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
DLOG:	DEFW	0		; logged-in disks
CURDMA:	DEFS	LWORD		; current dma address
BUFFA:	DEFS	LWORD		; pointer to directory dma address

;
;	curtrka - alloca are set upon disk select
;	(data must be adjacent, do not insert variables)
;	(address of translate vector, not used)
CDRMAXA:DEFS	LWORD		; pointer to cur dir max value (2 bytes)
CURTRKA:DEFS	LWORD		; current track address (2)
CURRECA:DEFS	LWORD		; current record address (3)
DRVLBLA:DEFS	LWORD		; current drive label byte address (1)
LSN$ADD:DEFS	LWORD		; login sequence # address (1)
	; +1 -> bios media change flag (1)
DPBADDR:DEFS	LWORD		; current disk parameter block address
CHECKA:	DEFS	LWORD		; current checksum vector address
ALLOCA:	DEFS	LWORD		; current allocation vector address
DIRBCBA:DEFS	LWORD		; dir bcb list head
DTABCBA:DEFS	LWORD		; data bcb list head
HASH$TBLA:
	DEFS	LWORD
	DEFS	LBYTE

ADDLIST EQU	$-DPBADDR	; address list size

;
; 	       buffer control block format
;
; bcb format : drv(1) || rec(3) || pend(1) || sequence(1) ||
;	       0         1         4          5
;
;	       track(2) || sector(2) || buffer$add(2) ||
;	       6           8            10
;
;	       link(2)
;	       12
;

;	sectpt - offset obtained from disk parm block at dpbaddr
;	(data must be adjacent, do not insert variables)
SECTPT:	DEFS	LWORD		; sectors per track
BLKSHF:	DEFS	LBYTE		; block shift factor
BLKMSK:	DEFS	LBYTE		; block mask
EXTMSK:	DEFS	LBYTE		; extent mask
MAXALL:	DEFS	LWORD		; maximum allocation number
DIRMAX:	DEFS	LWORD		; largest directory number
DIRBLK:	DEFS	LWORD		; reserved allocation bits for directory
CHKSIZ:	DEFS	LWORD		; size of checksum vector
OFFSET:	DEFS	LWORD		; offset tracks at beginning
PHYSHF:	DEFS	LBYTE		; physical record shift
PHYMSK:	DEFS	LBYTE		; physical record mask
DPBLIST EQU	$-SECTPT	; size of area
;
;	local variables
;
BLK$OFF:DEFS	LBYTE		; record offset within block
DIRCNT:DEFS	LBYTE		; direct i/o count

TRANV:	DEFS	LWORD	; address of translate vector
LINFO:	DEFS	LBYTE		; low(info)
DMINX:	DEFS	LBYTE		; local for diskwrite

ACTUAL$RC:
	DEFS	LBYTE		; directory ext record count

SINGLE:	DEFS	LBYTE	; set true if single byte allocation map


OLDDSK:	DEFS	LBYTE	; disk on entry to bdos
RCOUNT:	DEFS	LBYTE		; record count in current fcb
EXTVAL:	DEFS	LBYTE		; extent number and extmsk

VRECORD:DEFS	LBYTE		; current virtual record

CURDSK:

ADRIVE:	DEFB	0FFH	; current disk
ARECORD:DEFS	LWORD		; current actual record
	DEFS	LBYTE

ARECORD1: DEFS	LWORD	; current actual block# * blkmsk

;******** following variable order critical *****************

HIGH$EXT: DEFS	LBYTE	; fcb high ext bits
;xfcb$read$only:	ds	byte

;	local variables for directory access
DPTR:	DEFS	LBYTE		; directory pointer 0,1,2,3

;
;	local variables initialized by bdos at entry
;
FCBDSK:	DEFS	LBYTE		; disk named in fcb

PHY$OFF:DEFS	LBYTE
CURBCBA:DEFS	LWORD

TRACK:	DEFS	LWORD
SECTOR:	DEFS	LWORD

READ$DEBLOCK:
	LD	A,1
	CALL	DEBLOCK$DTA
	JP	SETFCB

COLUMN:	DEFB	0
OUTDELIM: DEFB	'$'

DMAAD:	DEFW	0080H
SELDSK:	DEFB	0
INFO:	DEFW	0
RESEL:	DEFB	0
FX:	DEFB	0
DCNT:	DEFW	0
SEARCHA:DEFW	0
SEARCHL:DEFB	0


; 	**************************
; 	Blocking/Deblocking Module
;	**************************

DEBLOCK$DIR:

	LD	HL,(DIRBCBA)

	JP	DEBLOCK

DEBLOCK$DTA:
	LD	HL,(DTABCBA)

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

	LD	(CURBCBA),HL
	CALL	GETBUFFA
	LD	(CURDMA),HL

	CALL	DEBLOCK9
	; Is command flush?
	POP	AF
	PUSH	AF
	CP	4
	JP	NC,DEBLOCK1	; yes
	; Is referenced physical record
	;already in buffer?
	CALL	COMPARE
	JP	Z,DEBLOCK45	; yes
	XOR	A
DEBLOCK1:
	CALL	DEBLOCK10
	; Read physical record buffer
	LD	A,2
	CALL	DEBLOCK$IO

	CALL	DEBLOCK9	; phypfx = adrive || arecord
	CALL	MOVE
	LD	(HL),0		; zero pending flag

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
	; If deblock command = locate
	; then buffa = recadd; return
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
	JP	MOVE$TPA	; then move to dma

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

DEBLOCK$IO:
	; a = 0 -> seek only
	; a = 1 -> write
	; a = 2 -> read
	PUSH	AF
	CALL	SEEK
	POP	AF
	DEC	A
	CALL	P,RDBUFF
	; Move track & sector to bcb
	CALL	DEBLOCK10
	INC	HL
	INC	HL
	LD	DE,TRACK
	LD	C,4
	JP	MOVE

	ORG	BASE+((($-BASE)+255) AND 0FF00H)-1
	DEFB	0

; Bios equates

BIOS$PG EQU	$

BOOTF	EQU	BIOS$PG+00	; 00. cold boot
CONOUTF EQU	BIOS$PG+12	; 04. console output function
HOMEF	EQU	BIOS$PG+24	; 08. disk home function
SELDSKF EQU	BIOS$PG+27	; 09. select disk function
SETTRKF EQU	BIOS$PG+30	; 10. set track function
SETSECF EQU	BIOS$PG+33	; 11. set sector function
SETDMAF EQU	BIOS$PG+36	; 12. set dma function
SECTRAN EQU	BIOS$PG+48	; 16. sector translate
MOVEF	EQU	BIOS$PG+75	; 25. memory move function
READF	EQU	BIOS$PG+39	; 13. read disk function
MOVE$OUT EQU	MOVEF
MOVE$TPA EQU	MOVEF

	END
