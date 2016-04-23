
	.Z80

TITLE:	'CP/M 3 - PROGRAM LOADER RSX - November 1982'
;	version 3.0b  Nov 04 1982 - Kathy Strutynski
;	version 3.0c  Nov 23 1982 - Doug Huskey
;	              Dec 22 1982 - Bruce Skidmore
;
;
;	copyright (c) 1982
;	digital research
;	box 579
;	pacific grove, ca.
;	93950
;
; 		****************************************************
; 		*****  THE FOLLOWING VALUES MUST BE PLACED IN    ***
; 		*****  EQUATES AT THE FRONT OF CCP3.ASM.         ***
; 		*****                                            ***
; 		*****  NOTE: DUE TO PLACEMENT AT THE FRONT THESE ***
; 		*****  EQUATES CAUSE PHASE ERRORS WHICH CAN BE   ***
; 		*****  IGNORED.                                  ***
EQU1	EQU	RSXSTART +0100H	;set this equate in the CCP
EQU2	EQU	FIXCHAIN +0100H	;set this equate in the CCP
EQU3	EQU	FIXCHAIN1+0100H	;set this equate in the CCP
EQU4	EQU	FIXCHAIN2+0100H	;set this equate in the CCP
EQU5	EQU	RSX$CHAIN+0100H	;set this equate in the CCP
EQU6	EQU	RELOC    +0100H	;set this equate in the CCP
EQU7	EQU	CALCDEST +0100H	;set this equate in the CCP
EQU8	EQU	SCBADDR	 +0100H	;set this equate in the CCP
EQU9	EQU	BANKED	 +0100H	;set this equate in the CCP
EQU10	EQU	RSXEND	 +0100H	;set this equate in the CCP
CCPORG	EQU	CCP		;set origin to this in CCP
PATCH	EQU	PATCHAREA+0100H	;LOADER patch area

CCP	EQU	401H		;[JCE] was 41A before patches
	;ORIGIN OF CCP3.ASM


; 		****************************************************

;	conditional assembly toggles:

TRUE		EQU	-1
FALSE		EQU	0
SPACESAVER 	EQU	TRUE

STACKSIZE 	EQU	32		;16 levels of stack
VERSION 	EQU	30H
TPA		EQU	100H
CCPTOP		EQU	0FH		;top page of CCP
OSBASE		EQU	06H		;base page in BDOS jump
OFF$NXT 	EQU	10		;address in next jmp field
CURREC		EQU	32		;current record field in fcb
RANREC		EQU	33		;random record field in fcb



;
;
;     dsect for SCB
;
BDOSBASE 	EQU	98H		; offset from page boundary
CCPFLAG1 	EQU	0B3H		; offset from page boundary
MULTICNT 	EQU	0E6H		; offset from page boundary
RSX$ONLY$CLR 	EQU	0FDH	;clear load RSX flag
RSX$ONLY$SET 	EQU	002H
RSCBADD 	EQU	3AH		;offset of scbadd in SCB
DMAAD		EQU	03CH		;offset of DMA address in SCB
BDOSADD 	EQU	62H		;offset of bdosadd in SCB
;
LOADFLAG 	EQU	02H		;flag for LOADER in memory
;
;     dsect for RSX
RENTRY		EQU	06H		;RSX contain jump to start
;
NEXTADD 	EQU	0BH		;address of next RXS in chain
PREVADD	 	EQU	0CH		;address of previous RSX in chain
WARMFLG 	EQU	0EH		;remove on wboot flag
ENDCHAIN 	EQU	18H		;end of RSX chain flag
;
;
READF		EQU	20		;sequential read
DMAF		EQU	26		;set DMA address
SCBF		EQU	49		;get/set SCB info
LOADF		EQU	59		;load function
;
;
MAXREAD 	EQU	64		;maximum of 64 pages in MULTIO
;
;
WBOOT		EQU	0000H		;BIOS warm start
BDOS		EQU	0005H		;bdos entry point
PRINT		EQU	9		;bdos print function
VERS		EQU	12		;get version number
MODULE		EQU	200H		;module address
;
;	DSECT for COM file header
;
COMSIZE 	EQU	TPA+1H
SCBCODE 	EQU	TPA+3H
RSXOFF		EQU	TPA+10H
RSXLEN		EQU	TPA+12H
;
;
CR		EQU	0DH
LF		EQU	0AH
;
;
	CSEG
;
;
;     ********* LOADER  RSX HEADER ***********
;
RSXSTART:
	JP	CCP		;the ccp will move this loader to
	DEFB	0,0,0		;high memory, these first 6 bytes
	;will receive the serial number from
	;the 6 bytes prior to the BDOS entry
	;point
TOJUMP:
	JP	BEGIN
NEXT:	DEFB	0C3H		;jump to next module
NEXTJMP:DEFW	06
PREVJMP:DEFW	07
	DEFB	0		;warm start flag
	DEFB	0		;bank flag
	DEFB	'LOADER  '	;RSX name
	DEFB	0FFH		;end of RSX chain flag
	DEFB	0		;reserved
	DEFB	0		;patch version number

;     ********* LOADER  RSX ENTRY POINT ***********

BEGIN:
	LD	A,C
	CP	LOADF
	JP	NZ,NEXT
BEGINLOD:
	POP	BC
	PUSH	BC		;BC = return address
	LD	HL,0		;switch stacks
	ADD	HL,SP
	LD	SP,STACK	;our stack
	LD	(USTACK),HL	;save user stack address
	PUSH	BC		;save return address
	EX	DE,HL		;save address of user's FCB
	LD	(USRFCB),HL
	LD	A,H		;is .fcb = 0000h
	OR	L
	PUSH	AF
	CALL	Z,RSX$CHAIN	;if so , remove RSXs with remove flag on
	POP	AF
	CALL	NZ,LOADFILE
	POP	DE		;return address
	LD	HL,TPA
	LD	A,(HL)
	CP	0C9H
	JP	Z,RSXFILE
	LD	A,D		;check return address
	DEC	A		; if CCP is calling
	OR	E		; it will be 100H
	JP	NZ,RETUSER1	;jump if not CCP
RETUSER:
	LD	A,(PREVJMP+1)	;get high byte
	OR	A		;is it the zero page (i.e. no RSXs present)
	JP	NZ,RETUSER1	;jump if not
	LD	HL,(NEXTJMP)	;restore five....don't stay arround
	LD	(OSBASE),HL
	LD	(NEWJMP),HL
	CALL	SETMAXB
RETUSER1:
	LD	HL,(USTACK)	;restore the stack
	LD	SP,HL
	XOR	A
	LD	L,A
	LD	H,A		;A,HL=0 (successful return)
	RET			;CCP pushed 100H on stack
;
;
;	BDOS FUNC 59 error return
;
RETERROR:
	LD	DE,0FEH
RETERROR1:
	;DE = BDOS error return
	LD	HL,(USTACK)
	LD	SP,HL
	POP	HL		;get return address
	PUSH	HL
	DEC	H		;is it 100H?
	LD	A,H
	OR	L
	EX	DE,HL		;now HL = BDOS error return
	LD	A,L
	LD	B,H
	RET	NZ		;return if not the CCP
;
;
LOADERR:
	LD	C,PRINT
	LD	DE,NOGO		;cannot load program
	CALL	BDOS		;to print the message
	JP	WBOOT		;warm boot

;
;
;;
;************************************************************************
;
;	MOVE RSXS TO HIGH MEMORY
;
;************************************************************************
;
;
;      RSX files are present
;

RSXF1:	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)		;BC contains RSX length
	LD	A,(BANKED)
	OR	A		;is this the non-banked system?
	JP	Z,RSXF2		;jump if so
	INC	HL		;HL = banked/non-banked flag
	INC	(HL)		;is this RSX only for non-banked?
	JP	Z,RSXF3		;skip if so
RSXF2:	PUSH	DE		;save offset
	CALL	CALCDEST	;calculate destination address and bias
	POP	HL		;rsx offset in file
	CALL	RELOC		;move and relocate file
	CALL	FIXCHAIN	;fix up rsx address chain
RSXF3:	POP	HL		;RSX length field in header


RSXFILE:
	;HL = .RSX (n-1) descriptor
	LD	DE,10H		;length of RSX descriptor in header
	ADD	HL,DE		;HL = .RSX (n) descriptor
	PUSH	HL		;RSX offset field in COM header
	LD	E,(HL)
	INC	HL
	LD	D,(HL)		;DE = RSX offset
	LD	A,E
	OR	D
	JP	NZ,RSXF1	;jump if RSX offset is non-zero
;
;
;
COMFILE:
	;RSXs are in place, now call SCB setting code
	CALL	SCBCODE		;set SCB flags for this com file
	;is there a real COM file?
	LD	A,(MODULE)	;is this an RSX only
	CP	0C9H
	JP	NZ,COMFILE2	;jump if real COM file
	LD	HL,(SCBADDR)
	LD	L,CCPFLAG1
	LD	A,(HL)
	OR	RSX$ONLY$SET	;set if RSX only
	LD	(HL),A
COMFILE2:
	LD	HL,(COMSIZE)	;move COM module to 100H
	LD	B,H
	LD	C,L		;BC contains length of COM module
	LD	HL,TPA+100H	;address of source for COM move to 100H
	LD	DE,TPA		;destination address
	CALL	MOVE
	JP	RETUSER1	;restore stack and return
;;
;************************************************************************
;
;	ADD AN RSX TO THE CHAIN
;
;************************************************************************
;
;
FIXCHAIN:
	LD	HL,(OSBASE)	;next RSX link
	LD	L,0
	LD	BC,6
	CALL	MOVE		;move serial number down
	LD	E,ENDCHAIN
	LD	(DE),A		;set loader flag=0
	LD	E,PREVADD+1
	LD	(DE),A		;set previous field to 0007H
	DEC	DE
	LD	A,7
	LD	(DE),A		;low byte = 7H
	LD	L,E		;HL address previous field in next RSX
	LD	E,NEXTADD	;change previous field in link
	LD	(HL),E
	INC	HL
	LD	(HL),D		;current <-- next
;
FIXCHAIN1:
	;entry:	H=next RSX page,
	;	DE=.(high byte of next RSX field) in current RSX
	EX	DE,HL		;HL-->current  DE-->next
	LD	(HL),D		;put page of next RSX in high(next field)
	DEC	HL
	LD	(HL),6
;
FIXCHAIN2:
	;entry:	H=page of lowest active RSX in the TPA
	;this routine resets the BDOS address @ 6H and in the SCB
	LD	L,6
	LD	(OSBASE),HL	;change base page BDOS vector
	LD	(NEWJMP),HL	;change SCB value for BDOS vector
;
;
SETMAXB:
	LD	DE,SCBADD2
SCBFUN:
	LD	C,SCBF
	JP	BDOS
;
;
;;
;************************************************************************
;
;	REMOVE TEMPORARY RSXS
;
;************************************************************************
;
;
;
RSX$CHAIN:
	;
	;	Chase up RSX chain, removing RSXs with the
	;	remove flag on (0FFH)
	;
	LD	HL,(OSBASE)	;base of RSX chain
	LD	B,H

RSX$CHAIN1:
	;B  = current RSX
	LD	H,B
	LD	L,ENDCHAIN
	INC	(HL)
	DEC	(HL)		;is this the loader?
	RET	NZ		;return if so (m=0ffh)
	LD	L,NEXTADD	;address of next node
	LD	B,(HL)		;DE -> next link
;
;
CHECK$REMOVE:
;
	LD	L,WARMFLG	;check remove flag
	LD	A,(HL)		;warmflag in A
	OR	A		;FF if remove on warm start
	JP	Z,RSX$CHAIN1	;check next RSX if not
;
REMOVE:
	;remove this RSX from chain
;
	;first change next field of prior link to point to next RSX
	;HL = current  B = next
;
	LD	L,PREVADD
	LD	E,(HL)		;address of previous RSX link
	INC	HL
	LD	D,(HL)
	LD	A,B		;A = next (high byte)
	LD	(DE),A		;store in previous link
	DEC	DE		;previous RSX chains to next RSX
	LD	A,6		;initialize low byte to 6
	LD	(DE),A		;
	INC	DE		;DE = .next (high byte)
;
	;now change previous field of next link to address previous RSX
	LD	H,B		;next in HL...previous in DE
	LD	L,PREVADD
	LD	(HL),E
	INC	HL
	LD	(HL),D		;next chained back to previous RSX
	LD	A,D		;check to see if this is the bottom
	OR	A		;RSX...
	PUSH	BC
	CALL	Z,FIXCHAIN2	;reset BDOS BASE to page in H
	POP	BC
	JP	RSX$CHAIN1	;check next RSX in the chain
;
;
;;
;************************************************************************
;
;	PROGRAM LOADER
;
;************************************************************************
;
;
;
LOADFILE:
;	entry: HL = .FCB
	PUSH	HL
	LD	DE,SCBDMA
	CALL	SCBFUN
	EX	DE,HL
	POP	HL		;.fcb
	PUSH	HL		;save .fcb
	LD	BC,CURREC
	ADD	HL,BC
	LD	(HL),0		;set current record to 0
	INC	HL
	LD	C,(HL)		;load address
	INC	HL
	LD	H,(HL)
	LD	L,C
	DEC	H
	INC	H
	JP	Z,RETERROR	;Load address < 100h
	PUSH	HL		;now save load address
	PUSH	DE		;save the user's DMA
	PUSH	HL
	CALL	MULTIO1		;returns A=multio
	POP	HL
	PUSH	AF		;save A = user's multisector I/O
	LD	E,128		;read 16k

	;stack:		|return address|
	;		|.FCB          |
	;		|Load address  |
	;		|users DMA     |
	;		|users Multio  |
	;

LOADF0:
	;HL= next load address (DMA)
	; E= number of records to read
	LD	A,(OSBASE+1)	;calculate maximum number of pages
	DEC	A
	SUB	H
	JP	C,ENDLOAD	;we have used all we can
	INC	A
	CP	MAXREAD		;can we read 16k?
	JP	NC,LOADF2
	RLCA			;change to sectors
	LD	E,A		;save for multi i/o call
	LD	A,L		;A = low(load address)
	OR	A
	JP	Z,LOADF2	;load on a page boundary
	LD	B,2		;(to subtract from # of sectors)
	DEC	A		;is it greater than 81h?
	JP	M,SUBTRACT	;080h < l(adr) <= 0FFh (subtract 2)
	DEC	B		;000h < l(adr) <= 080h (subtract 1)
SUBTRACT:
	LD	A,E		;reduce the number of sectors to
	SUB	B		;compensate for non-page aligned
	;load address
	JP	Z,ENDLOAD	;can't read zero sectors
	LD	E,A
;
LOADF2:
	;read the file
	PUSH	DE		;save number of records to read
	PUSH	HL		;save load address
	CALL	MULTIO		;set multi-sector i/o
	POP	HL
	PUSH	HL
	CALL	READB		;read sector
	POP	HL
	POP	DE		;restore number of records
	PUSH	AF		;zero flag set if no error
	LD	A,E		;number of records in A
	INC	A
	RRA			;convert to pages
	ADD	A,H
	LD	H,A		;add to load address
	LD	(LOADTOP),HL	;save next free page address
	POP	AF
	JP	Z,LOADF0	;loop if more to go

LOADF4:
	;FINISHED load  A=1 if successful (eof)
	;		A>1 if a I/O error occured
	;
	POP	BC		;B=multisector I/O count
	DEC	A		;not eof error?
	LD	E,B		;user's multisector count
	CALL	MULTIO
	LD	C,DMAF		;restore the user's DMA address
	POP	DE
	PUSH	AF		;zero flag => successful load
	CALL	BDOS		; user's DMA now restored
	POP	AF
	LD	HL,(BDOSRET)	;BDOS error return
	EX	DE,HL
	JP	NZ,RETERROR1
	POP	DE		;load address
	POP	HL		;.fcb
	LD	BC,9		;is it a PRL?
	ADD	HL,BC		;.fcb(type)
	LD	A,(HL)
	AND	7FH		;get rid of attribute bit
	CP	'P'		;is it a P?
	RET	NZ		;return if not
	INC	HL
	LD	A,(HL)
	AND	7FH
	CP	'R'		;is it a R
	RET	NZ		;return if not
	INC	HL
	LD	A,(HL)
	AND	7FH
	SUB	'L'		;is it a L?
	RET	NZ		;return if not
	;load PRL file
	LD	A,E
	OR	A		;is load address on a page boundary
	JP	NZ,RETERROR	;error, if not
	LD	H,D
	LD	L,E		;HL,DE = load address
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	LD	L,E		;HL,DE = load address BC = length
;	jmp	reloc			;relocate PRL file at load address
;
;;
;************************************************************************
;
;	PAGE RELOCATOR
;
;************************************************************************
;
;
RELOC:
;	HL,DE = load address (of PRL header)
;	BC    = length of program (offset of bit map)
	INC	H		;offset by 100h to skip header
	PUSH	DE		;save destination address
	PUSH	BC		;save length in bc
	CALL	MOVE		;move rsx to correct memory location
	POP	BC
	POP	DE
	PUSH	DE		;save DE for fixchain...base of RSX
	LD	E,D		;E will contain the BIAS from 100h
	DEC	E		;base address is now 100h
	;after move HL addresses bit map
	;
	;storage moved, ready for relocation
	;	HL addresses beginning of the bit map for relocation
	;	E contains relocation bias
	;	D contain relocation address
	;	BC contains length of code
REL0:	PUSH	HL		;save bit map base in stack
	LD	H,E		;relocation bias is in e
	LD	E,0
;
REL1:	LD	A,B		;bc=0?
	OR	C
	JP	Z,ENDREL
;
;	not end of the relocation, may be into next byte of bit map
	DEC	BC		;count length down
	LD	A,E
	AND	111B		;0 causes fetch of next byte
	JP	NZ,REL2
;	fetch bit map from stacked address
	EX	(SP),HL
	LD	A,(HL)		;next 8 bits of map
	INC	HL
	EX	(SP),HL		;base address goes back to stack
	LD	L,A		;l holds the map as we process 8 locations
REL2:	LD	A,L
	RLA			;cy set to 1 if relocation necessary
	LD	L,A		;back to l for next time around
	JP	NC,REL3		;skip relocation if cy=0
;
;	current address requires relocation
	LD	A,(DE)
	ADD	A,H		;apply bias in h
	LD	(DE),A
REL3:	INC	DE		;to next address
	JP	REL1		;for another byte to relocate
;
ENDREL:	;end of relocation
	POP	DE		;clear stacked address
	POP	DE		;restore DE to base of PRL
	RET


;
;;
;************************************************************************
;
;	PROGRAM LOAD TERMINATION
;
;************************************************************************
;
;;
;;
ENDLOAD:
	CALL	MULTIO1		;try to read after memory is filled
	LD	HL,80H		;set load address = default buffer
	CALL	READB
	JP	NZ,LOADF4	;eof => successful
	LD	HL,0FEH		;set BDOSRET to indicate an error
	LD	(BDOSRET),HL
	JP	LOADF4		;unsuccessful (file to big)
;
;;
;
;;
;************************************************************************
;
;	SUBROUTINES
;
;************************************************************************
;
;
;
;	Calculate RSX base in the top of the TPA
;
CALCDEST:
;
;	calcdest returns destination in DE
;	BC contains length of RSX
;
	LD	A,(OSBASE+1)	;a has high order address of memory top
	DEC	A		;page directly below bdos
	DEC	BC		;subtract 1 to reflect last byte of code
	SUB	B		;a has high order address of reloc area
	INC	BC		;add 1 back get bit map offset
	CP	CCPTOP		;are we below the CCP
	JP	C,LOADERR
	LD	HL,(LOADTOP)
	CP	H		;are we below top of this module
	JP	C,LOADERR
	LD	D,A
	LD	E,0		;d,e addresses base of reloc area
	RET
;
;;
;;-----------------------------------------------------------------------
;;
;;	move memory routine

MOVE:
;	move source to destination
;	where source is in HL and destination is in DE
;	and length is in BC
;
	LD	A,B		;bc=0?
	OR	C
	RET	Z
	DEC	BC		;count module size down to zero
	LD	A,(HL)		;get next absolute location
	LD	(DE),A		;place it into the reloc area
	INC	DE
	INC	HL
	JP	MOVE
;;
;;-----------------------------------------------------------------------
;;
;;	Multi-sector I/O
;;	(BDOS function #44)
;
MULTIO1:
	LD	E,1		;set to read 1 sector
;
MULTIO:
	;entry: E = new multisector count
	;exit:	A = old multisector count
	LD	HL,(SCBADDR)
	LD	L,MULTICNT
	LD	A,(HL)
	LD	(HL),E
	RET
;;
;;-----------------------------------------------------------------------
;;
;;	read file
;;	(BDOS function #20)
;;
;;	entry:	hl = buffer address (readb only)
;;	exit	z  = set if read ok
;;
READB:	EX	DE,HL
SETBUF:	LD	C,DMAF
	PUSH	HL		;save number of records
	CALL	BDOS
	LD	C,READF
	LD	HL,(USRFCB)
	EX	DE,HL
	CALL	BDOS
	LD	(BDOSRET),HL	;save bdos return
	POP	DE		;restore number of records
	OR	A
	RET	Z		;no error on read
	LD	E,H		;change E to number records read
	RET
;
;
;************************************************************************
;
;	DATA AREA
;
;************************************************************************
;

NOGO:	DEFB	CR,LF,'Cannot load Program$'

PATCHAREA:
	DEFS	36		;36 byte patch area

SCBADDR:DEFW	0
BANKED:	DEFB	0

SCBDMA:	DEFB	DMAAD
	DEFB	00H		;getting the value
SCBADD2:DEFB	BDOSADD		;current top of TPA
	DEFB	0FEH		;set the value
;

	IF	NOT SPACESAVER

NEWJMP:	DEFS	2	;new BDOS vector
LOADTOP:DEFS	2		;page above loaded program
USRFCB:	DEFS	2		;contains user FCB add
USTACK:	DEFS	2		; user stack on entry
BDOSRET:DEFS	2		;bdos error return
;
RSXEND:		:
STACK	EQU	RSXEND+STACKSIZE

	ELSE

RSXEND:
NEWJMP	EQU	RSXEND
LOADTOP EQU	RSXEND+2
USRFCB	EQU	RSXEND+4
USTACK	EQU	RSXEND+6
BDOSRET EQU	RSXEND+8
STACK	EQU	RSXEND+10+STACKSIZE

	ENDIF
	END

