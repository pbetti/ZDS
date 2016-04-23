	title	M$ BASIC Interpreter
	name	('MBASIC')

; DASMed version of Microsoft BASIC interpreter MBASIC.COM
; By W. Cirsovius

	.z80
	aseg
	org	0100h

FALSE	equ	0
TRUE	equ	NOT FALSE

OS	equ	0000h
BDOS	equ	0005h
CCP	equ	0080h
DMA	equ	0080h

_@CST	equ	2

.vers	equ	12
.resdsk	equ	13
.logdsk	equ	14
.open	equ	15
.close	equ	16
.srcfrs	equ	17
.srcnxt	equ	18
.delete	equ	19
.rdseq	equ	20
.wrseq	equ	21
.make	equ	22
.rename	equ	23
.retdsk	equ	25
.setdma	equ	26
.rdrnd	equ	33
.wrrnd	equ	34

OSerr	equ	255

_drv	equ	1
_nam	equ	8
_ext	equ	3

_EX	equ	12
_RRN	equ	33

reclng	equ	128

null	equ	00h
CtrlC	equ	'C'-'@'
bell	equ	07h
bs	equ	08h
tab	equ	09h
lf	equ	0ah
cr	equ	0dh
eof	equ	1ah
esc	equ	1bh
rubout	equ	7fh

NoMSB	equ	01111111b
MSB	equ	10000000b

TOKLEN	equ	315		; Length of token line ??

$PROT$	equ	13*256+11	; Init loop for protection

_OR	macro
	db	0f6h
	endm

_CP	macro
	db	0feh
	endm

_LD.BC	macro
	db	001h
	endm

_LD.DE	macro
	db	011h
	endm

_LD.HL	macro
	db	021h
	endm

_LD.A	macro
	db	03eh
	endm

_LD.B	macro
	db	006h
	endm

_LD.C	macro
	db	00eh
	endm

_LD.D	macro
	db	016h
	endm

_LD.L	macro
	db	02eh
	endm

_LDA	macro
	db	03ah
	endm

_JP.NZ	macro
	db	0c2h
	endm

_JP.Z	macro
	db	0cah
	endm

_JP.NC	macro
	db	0d2h
	endm

_JP.C	macro
	db	0dah
	endm

_JP.M	macro
	db	0fah
	endm

l0000	equ	00h
l0001	equ	01h
l0002	equ	02h
l0004	equ	04h
l0005	equ	05h
l0006	equ	06h
l0007	equ	07h
l0008	equ	08h
l0009	equ	09h
l000a	equ	0ah
l000d	equ	0dh
l000e	equ	0eh
l000f	equ	0fh
l0010	equ	10h
l0011	equ	11h
l0014	equ	14h
l001e	equ	1eh
l0021	equ	21h
l0022	equ	22h
l0025	equ	25h
l0026	equ	26h
l0027	equ	27h
l0028	equ	28h
l0029	equ	29h
l0042	equ	42h
l004e	equ	4eh
l007f	equ	7fh
l0080	equ	80h
l0082	equ	82h
l00a9	equ	0a9h
l00aa	equ	0aah
l00ab	equ	0abh
l00ad	equ	0adh
l00ae	equ	0aeh
l00b0	equ	0b0h
l00b1	equ	0b1h
l00b2	equ	0b2h
l00b4	equ	0b4h
l00b8	equ	0b8h
l00c5	equ	0c5h
l00ff	equ	0ffh
l6404	equ	6404h
l7218	equ	7218h
l772b	equ	772bh
l7e22	equ	7e22h
l7f00	equ	7f00h
l7f80	equ	7f80h
l8000	equ	8000h
l8031	equ	8031h
l8080	equ	8080h
l8138	equ	8138h
l9080	equ	9080h
l9143	equ	9143h
l9180	equ	9180h
l9474	equ	9474h
laa3b	equ	0aa3bh
lb60e	equ	0b60eh
lf983	equ	0f983h
lffaa	equ	0ffaah
lffc0	equ	0ffc0h
lfff8	equ	0fff8h
lfff9	equ	0fff9h
lfffa	equ	0fffah
lfffe	equ	0fffeh
lffff	equ	0ffffh

	jp	l5d8c
;
	dw	_CINT
	dw	st.INT
;
; Statement table
;
l0107:
	dw	_END		; 0x81 : END
	dw	l11bf		; 0x82 : FOR
	dw	l459e		; 0x83 : NEXT
	dw	_DATA		; 0x84 : DATA
	dw	l1863		; 0x85 : INPUT
	dw	_DIM		; 0x86 : DIM
	dw	l1940		; 0x87 : READ
	dw	_LET		; 0x88 : LET
	dw	l1495		; 0x89 : GOTO
	dw	_RUN		; 0x8a : RUN
	dw	l1651		; 0x8b : IF
	dw	l43e6		; 0x8c : RESTORE
	dw	l147d		; 0x8d : GOSUB
	dw	l14d1		; 0x8e : RETURN
	dw	l14ee		; 0x8f : REM
	dw	l4401		; 0x90 : STOP
	dw	l169c		; 0x91 : PRINT
	dw	l450e		; 0x92 : CLEAR
	dw	l2089		; 0x93 : LIST
	dw	l4320		; 0x94 : NEW
	dw	l1585		; 0x95 : ON
	dw	l4473		; 0x96 : NULL
	dw	l2003		; 0x97 : WAIT
	dw	l1e2b		; 0x98 : DEF
	dw	l22c0		; 0x99 : POKE
	dw	l445d		; 0x9a : CONT
	dw	l0cc9		; 0x9b : ??
	dw	l0cc9		; 0x9c : ??
	dw	l1ffd		; 0x9d : OUT
	dw	l1694		; 0x9e : LPRINT
	dw	l2084		; 0x9f : LLIST
	dw	0
	dw	l2024		; 0xa1 : WIDTH
	dw	l14ee		; 0xa2 : ELSE
	dw	l447c		; 0xa3 : TRON
	dw	l447d		; 0xa4 : TROFF
	dw	l4482		; 0xa5 : SWAP
	dw	l44c4		; 0xa6 : ERASE
	dw	l3ce3		; 0xa7 : EDIT
	dw	l1610		; 0xa8 : ERROR
	dw	l15d3		; 0xa9 : RESUME
	dw	l227c		; 0xaa : DELETE
	dw	l161b		; 0xab : AUTO
	dw	l22f9		; 0xac : RENUM
	dw	l13c9		; 0xad : DEFSTR
	dw	l13cc		; 0xae : DEFINT
	dw	l13cf		; 0xaf : DEFSNG
	dw	l13d2		; 0xb0 : DEFDBL
	dw	l17f5		; 0xb1 : LINE
	dw	0
	dw	0
	dw	l4c58		; 0xb4 : WHILE
	dw	l4c7b		; 0xb5 : WEND
	dw	l4cf1		; 0xb6 : CALL
	dw	l507b		; 0xb7 : WRITE
	dw	_DATA		; 0xb8 : COMMON
	dw	l4d74		; 0xb9 : CHAIN
	dw	l243d		; 0xba : OPTION
	dw	l2487		; 0xbb : RANDOMIZE
	dw	0
	dw	l59b7		; 0xbd : SYSTEM
	dw	0
	dw	_OPEN		; 0xbf : OPEN
	dw	l5417		; 0xc0 : FIELD
	dw	l5afe		; 0xc1 : GET
	dw	l5afd		; 0xc2 : PUT
	dw	l53d9		; 0xc3 : CLOSE
	dw	l529b		; 0xc4 : LOAD
	dw	l535c		; 0xc5 : MERGE
	dw	l5a04		; 0xc6 : FILES
	dw	l5865		; 0xc7 : NAME
	dw	l59d7		; 0xc8 : ??
	dw	l547b		; 0xc9 : LSET
	dw	l547a		; 0xca : RSET
	dw	l539a		; 0xcb : SAVE
	dw	l59be		; 0xcc : RESET
;
; Function table
;
l019f:
	dw	l4948		; 0x01 : LEFT$
	dw	l4979		; 0x02 : RIGHT$
	dw	l4983		; 0x03 : MID$
	dw	l287c		; 0x04 : SGN
	dw	l2a80		; 0x05 : INT
	dw	l2867		; 0x06 : ABS
	dw	l36c0		; 0x07 : SQR
	dw	l37dd		; 0x08 : RND
	dw	l387f		; 0x09 : SIN
	dw	l26bd		; 0x0a : LOG
	dw	l372b		; 0x0b : EXP
	dw	l3879		; 0x0c : COS
	dw	l391c		; 0x0d : TAN
	dw	l3931		; 0x0e : ATN
	dw	l4af6		; 0x0f : FRE
	dw	l1ff2		; 0x10 : INP
	dw	l1dd1		; 0x11 : POS
	dw	l48d6		; 0x12 : LEN
	dw	l4696		; 0x13 : STR$
	dw	l49a4		; 0x14 : VAL
	dw	l48e2		; 0x15 : ASC
	dw	l48f2		; 0x16 : CHR$
	dw	l22b6		; 0x17 : PEEK
	dw	l492b		; 0x18 : SPACE$
	dw	l468a		; 0x19 : OCT$
	dw	l4690		; 0x1a : HEX$
	dw	l1dcb		; 0x1b : LPOS
	dw	_CINT		; 0x1c : CINT
	dw	l29f4		; 0x1d : CSNG
	dw	l2a20		; 0x1e : CDBL
	dw	l2a6d		; 0x1f : FIX
	dw	0
	dw	0
	dw	0
	dw	0
	dw	0
	dw	0
	dw	0
	dw	0
	dw	0
	dw	0
	dw	0
	dw	l517a		; 0x2b : CVI
	dw	l517d		; 0x2c : CVS
	dw	l5180		; 0x2d : CVD
	dw	0
	dw	l558e		; 0x2f : EOF
	dw	l5640		; 0x30 : LOC
	dw	l5658		; 0x31 : LOF
	dw	l5161		; 0x32 : MKI$
	dw	l5164		; 0x33 : MKS$
	dw	l5167		; 0x34 : MKD$
;
; Keyword table
;
l0207:
	dw	l023b		; A
	dw	l024c
	dw	l024d
	dw	l0287
	dw	l02b0
	dw	l02d5
	dw	l02eb
	dw	l02fd
	dw	l0302
	dw	l031e
	dw	l031f
	dw	l0324
	dw	l0358
	dw	l0371
	dw	l0384
	dw	l039a
	dw	l03ae
	dw	l03af
	dw	l03ed
	dw	l0422
	dw	l0439
	dw	l0442
	dw	l044c
	dw	l0464
	dw	l0468
	dw	l0469
;
; A..
;
l023b:
	dc	'UTO'
	db	0abh
	dc	'ND'
	db	0f7h
	dc	'BS'
	db	006h
	dc	'TN'
	db	00eh
	dc	'SC'
	db	015h
	db	0
;
; B..
;
l024c:
	db	0
;
; C..
;
l024d:
	dc	'LOSE'
	db	0c3h
	dc	'ONT'
	db	09ah
	dc	'LEAR'
	db	092h
	dc	'INT'
	db	01ch
	dc	'SNG'
	db	01dh
	dc	'DBL'
	db	01eh
	dc	'VI'
	db	02bh
	dc	'VS'
	db	02ch
	dc	'VD'
	db	02dh
	dc	'OS'
	db	00ch
	dc	'HR$'
	db	016h
	dc	'ALL'
	db	0b6h
	dc	'OMMON'
	db	0b8h
	dc	'HAIN'
	db	0b9h
	db	0
;
; D..
;
l0287:
	dc	'ELETE'
	db	0aah
	dc	'ATA'
	db	084h
	dc	'IM'
	db	086h
	dc	'EFSTR'
	db	0adh
	dc	'EFINT'
	db	0aeh
	dc	'EFSNG'
	db	0afh
	dc	'EFDBL'
	db	0b0h
	dc	'EF'
	db	098h
	db	0
;
; E..
;
l02b0:
	dc	'LSE'
	db	0a2h
	dc	'ND'
	db	081h
	dc	'RASE'
	db	0a6h
	dc	'DIT'
	db	0a7h
	dc	'RROR'
	db	0a8h
	dc	'RL'
	db	0d6h
	dc	'RR'
	db	0d7h
	dc	'XP'
	db	00bh
	dc	'OF'
	db	02fh
	dc	'QV'
	db	0fah
	db	0
;
; F..
;
l02d5:
	dc	'OR'
	db	082h
	dc	'IELD'
	db	0c0h
	dc	'ILES'
	db	0c6h
	dc	'N'
	db	0d3h
	dc	'RE'
	db	00fh
	dc	'IX'
	db	01fh
	db	0
;
; G..
;
l02eb:
	dc	'OTO'
	db	089h
	dc	'O TO'
	db	089h
	dc	'OSUB'
	db	08dh
	dc	'ET'
	db	0c1h
	db	0
;
; H..
;
l02fd:
	dc	'EX$'
	db	01ah
	db	0
;
; I..
;
l0302:
	dc	'NPUT'
	db	085h
	dc	'F'
	db	08bh
	dc	'NSTR'
	db	0dah
	dc	'NT'
	db	005h
	dc	'NP'
	db	010h
	dc	'MP'
	db	0fbh
	dc	'NKEY$'
	db	0ddh
	db	0
;
; J..
;
l031e:
	db	0
;
; K..
;
l031f:
	dc	'ILL'
	db	0c8h
	db	0
;
; L..
;
l0324:
	dc	'PRINT'
	db	09eh
	dc	'LIST'
	db	09fh
	dc	'POS'
	db	01bh
	dc	'ET'
	db	088h
	dc	'INE'
	db	0b1h
	dc	'OAD'
	db	0c4h
	dc	'SET'
	db	0c9h
	dc	'IST'
	db	093h
	dc	'OG'
	db	00ah
	dc	'OC'
	db	030h
	dc	'EN'
	db	012h
	dc	'EFT$'
	db	001h
	dc	'OF'
	db	031h
	db	0
;
; M..
;
l0358:
	dc	'ERGE'
	db	0c5h
	dc	'OD'
	db	0fch
	dc	'KI$'
	db	032h
	dc	'KS$'
	db	033h
	dc	'KD$'
	db	034h
	dc	'ID$'
	db	003h
	db	0
;
; N..
;
l0371:
	dc	'EXT'
	db	083h
	dc	'ULL'
	db	096h
	dc	'AME'
	db	0c7h
	dc	'EW'
	db	094h
	dc	'OT'
	db	0d5h
	db	0
;
; O..
;
l0384:
	dc	'PEN'
	db	0bfh
	dc	'UT'
	db	09dh
	dc	'N'
	db	095h
	dc	'R'
	db	0f8h
	dc	'CT$'
	db	019h
	dc	'PTION'
	db	0bah
	db	0
;
; P..
;
l039a:
	dc	'RINT'
	db	091h
	dc	'UT'
	db	0c2h
	dc	'OKE'
	db	099h
	dc	'OS'
	db	011h
	dc	'EEK'
	db	017h
	db	0
;
; Q..
;
l03ae:
	db	0
;
; R..
;
l03af:
	dc	'ETURN'
	db	08eh
	dc	'EAD'
	db	087h
	dc	'UN'
	db	08ah
	dc	'ESTORE'
	db	08ch
	dc	'EM'
	db	08fh
	dc	'ESUME'
	db	0a9h
	dc	'SET'
	db	0cah
	dc	'IGHT$'
	db	002h
	dc	'ND'
	db	008h
	dc	'ENUM'
	db	0ach
	dc	'ESET'
	db	0cch
	dc	'ANDOMIZE'
	db	0bbh
	db	0
;
; S..
;
l03ed:
	dc	'TOP'
	db	090h
	dc	'WAP'
	db	0a5h
	dc	'AVE'
	db	0cbh
	dc	'PC('
	db	0d4h
	dc	'TEP'
	db	0d1h
	dc	'GN'
	db	004h
	dc	'QR'
	db	007h
	dc	'IN'
	db	009h
	dc	'TR$'
	db	013h
	dc	'TRING$'
	db	0d8h
	dc	'PACE$'
	db	018h
	dc	'YSTEM'
	db	0bdh
	db	0
;
; T..
;
l0422:
	dc	'HEN'
	db	0cfh
	dc	'RON'
	db	0a3h
	dc	'ROFF'
	db	0a4h
	dc	'AB('
	db	0d0h
	dc	'O'
	db	0ceh
	dc	'AN'
	db	00dh
	db	0
;
; U..
;
l0439:
	dc	'SING'
	db	0d9h
	dc	'SR'
	db	0d2h
	db	0
;
; V..
;
l0442:
	dc	'AL'
	db	014h
	dc	'ARPTR'
	db	0dch
	db	0
;
; W..
;
l044c:
	dc	'IDTH'
	db	0a1h
	dc	'AIT'
	db	097h
	dc	'HILE'
	db	0b4h
	dc	'END'
	db	0b5h
	dc	'RITE'
	db	0b7h
	db	0
;
; X..
;
l0464:
	dc	'OR'
	db	0f9h
	db	0
;
; Y..
;
l0468:
	db	0
;
; Z..
;
l0469:
	db	0
;
; Operator table
;
l046a:
	dc	'+'
	db		0f2h
	dc	'-'
	db		0f3h
	dc	'*'
	db		0f4h
	dc	'/'
	db		0f5h
	dc	'^'
	db		0f6h
	dc	'\'
	db		0fdh
	dc	''''
	db		0dbh
	dc	'>'
	db		0efh
	dc	'='
	db		0f0h
	dc	'<'
	db		0f1h
	db	0
l047f:
	db	79h,79h,7ch,7ch,7fh,50h
	db	46h,3ch,32h,28h,7ah,7bh
l048b:
	dw	l2a20
	dw	0
	dw	_CINT
	dw	vrf.str
	dw	l29f4
l0495:
	dw	l2c26
	dw	l2c1f
	dw	l2d64
	dw	l2e44
	dw	l2973
l049f:
	dw	l2588
	dw	l2585
	dw	l2703
	dw	l2769
	dw	l2906
l04a9:
	dw	l2b31
	dw	l2b25
	dw	l2b51
	dw	l1b84
	dw	l2933
l04b3:
	db	null
	db	'NEXT without FOR',null
	db	'Syntax error',null
	db	'RETURN without GOSUB',null
	db	'Out of DATA',null
	db	'Illegal function call',null
l0509:
	db	'Overflow',null
	db	'Out of memory',null
	db	'Undefined line number',null
	db	'Subscript out of range',null
	db	'Duplicate Definition',null
l0562:
	db	'Division by zero',null
	db	'Illegal direct',null
	db	'Type mismatch',null
	db	'Out of string space',null
	db	'String too long',null
	db	'String formula too complex',null
	db	'Can''t continue',null
	db	'Undefined user function',null
	db	'No RESUME',null
	db	'RESUME without error',null
	db	'Unprintable error',null
	db	'Missing operand',null
	db	'Line buffer overflow',null
	db	'?',null
	db	'?',null
	db	'FOR Without NEXT',null
	db	'?',null
	db	'?',null
	db	'WHILE without WEND',null
	db	'WEND without WHILE',null
;
; 50 .. 67 -> mapped to 31 .. 48
;
	db	'FIELD overflow',null
	db	'Internal error',null
	db	'Bad file number',null
	db	'File not found',null
	db	'Bad file mode',null
	db	'File already open',null
	db	'?',null
	db	'Disk I/O error',null
	db	'File already exists',null
	db	'?',null
	db	'?',null
	db	'Disk full',null
	db	'Input past end',null
	db	'Bad record number',null
	db	'Bad file name',null
	db	'?',null
	db	'Direct statement in file',null
	db	'Too many files',null
l0774:
	db	18h,14h,18h,14h,18h,14h,18h
	db	14h,18h,14h,18h,14h,18h,14h
	db	18h,14h,18h,14h,18h,14h
l0788:
	db	1
l0789:
	db	0
err.num:
	dw	0
colLST:
	db	0		; Printer column
iodev:
	db	0		; Character device (0 is console)
l078e:
	db	70h
l078f:
	db	84h
l0790:
	db	80
l0791:
	db	56
rub.flg:
	db	0
_brk:
	db	0
FP:
	dw	0		; Current file pointer
heap:
	dw	l60a3
dir.mode:
	dw	lfffe
prg.base:
	dw	l6040
l079c:
	dw	l0509
l079e:
	db	0
opnsave:
	db	0
l07a0:
	dw	0
F.ptr:
	dw	0
F.arr:
	ds	2*16		; File array
opnfiles:
	db	0		; Max open files (/F)
l07c5:
	db	0
l07c6:
	ds	38
l07ec:
	dw	0
l07ee:
	ds	16
@@FCB:
	ds	33
OSvers:
	db	0	; OS version (0 is not CP/M 2.x or 3.x)
f_rd:
	db	0	; File read function
f_wr:
	db	0	; File write function
l0822:
	db	':'
@TOKEN:
	ds	TOKLEN+3
l0961:
	db	','
$LINE:
	ds	258
l0a64:
	db	0
colCON:
	db	0		; Console column
l0a66:
	db	0
$ARGLEN:
	db	0
l0a68:
	db	0
l0a69:
	db	0
l0a6a:
	dw	0
l0a6c:
	db	0
l0a6d:
	db	0
l0a6e:
	dw	0
l0a70:
	ds	6
himem:
	dw	0		; Hi memory (/M)
STR.ptr:
	dw	0
STR.arr:
	ds	11*3
mem.top:
	dw	0
l0a9d:
	dw	0
_f.$$:
	dw	0
l0aa1:
	dw	0
direct_1:
	dw	0
l0aa5:
	db	0
l0aa6:
	db	0
@@ptr:
	dw	0
l0aa9:
	db	0
auto.mode:
	db	0
AUTO.inc:
	dw	0
AUTO.line:
	dw	0
l0aaf:
	dw	0
curstk:
	dw	0
direct_2:
	dw	0
l0ab5:
	dw	0
l0ab7:
	dw	0
l0ab9:
	dw	0
l0abb:
	db	0
l0abc:
	dw	0
direct_4:
	dw	0
cont.mode:
	dw	0
prg.top:
	dw	0
l0ac4:
	dw	0
l0ac6:
	dw	0
DATA.ptr:
	dw	0
l0aca:
	ds	26
l0ae4:
	dw	0
l0ae6:
	dw	0
l0ae8:
	ds	100
l0b4c:
	dw	0
l0b4e:
	dw	0
l0b50:
	ds	100
l0bb4:
	db	0
l0bb5:
	db	0
l0bb6:
	db	0
l0bb7:
	db	0
l0bb8:
	dw	0
l0bba:
	dw	0
l0bbc:
	db	0
l0bbd:
	dw	0
l0bbf:
	db	0
l0bc0:
	ds	4
direct_3:
	dw	0
l0bc6:
	db	0
l0bc7:
	ds	31
l0be6:
	db	0
l0be7:
	db	0
l0be8:
	dw	0
recsiz:
	dw	0		; File record size (/S)
_prot:
	db	0
l0bed:
	db	0
l0bee:
	db	0
l0bef:
	dw	0
l0bf1:
	dw	0
l0bf3:
	db	0
l0bf4:
	dw	0
l0bf6:
	ds	8
trcflg:
	db	0		; TRON/TROFF (0 is TROFF)
l0bff:
	db	0
$$ARG:
	ds	8
l0c08:
	db	0
l0c09:
	db	0
l0c0a:
	db	0
l0c0b:
	db	0
l0c0c:
	db	0
l0c0d:
	ds	6
l0c13:
	db	0
l0c14:
	db	0
l0c15:
	db	0
l0c16:
	ds	26
l0c30:
	ds	6
l0c36:
	db	0
l0c37:
	ds	9
l0c40:
	db	' in '
l0c44:
	db	0
l0c45:
	db	'Ok',cr,lf,null
l0c4a:
	db	'Break',null
;
; Find FOR or WHILE - Zero set indicates either found
;
l0c50:
	ld	hl,2*2
	add	hl,sp		; Get stack pointer base
l0c54:
	ld	a,(hl)		; Get token
	inc	hl
	cp	0b4h		; Test WHILE
	jp	nz,l0c62
	ld	bc,2*3
	add	hl,bc		; .. fix pointer
	jp	l0c54		; .. try next
l0c62:
	cp	082h		; Test FOR
	ret	nz		; .. nope
	ld	c,(hl)		; Fetch ???
	inc	hl
	ld	b,(hl)
	inc	hl
	push	hl
	ld	h,b
	ld	l,c
	ld	a,d		; Test zero
	or	e
	ex	de,hl
	jp	z,l0c76		; .. yeap, skip
	ex	de,hl
	call	cp.r		; Compare HL:DE
l0c76:
	ld	bc,2*8
	pop	hl		; Get back pointer
	ret	z		; .. end
	add	hl,bc		; .. bump and fix next
	jp	l0c54
;
; ENTRY	Reg HL holds current stack pointer
;
l0c7f:
	ld	bc,l0d86	; Load execution address
	jp	l0cfc		; .. reset error environment
;
;
;
l0c85:
	ld	hl,(dir.mode)	; Get direct mode
	ld	a,h
	and	l
	inc	a
	jp	z,l0c97		; .. -1 is valid direct
	ld	a,(l0abb)
	or	a
	ld	e,19		; No RESUME
	jp	nz,_error
l0c97:
	jp	l4419
;
; Disk full
;
l0c9a:
	ld	e,61
	_LD.BC
;
; Disk I/O error
;
l0c9d:
	ld	e,57
	_LD.BC
;
; Bad file mode
;
l0ca0:
	ld	e,54
	_LD.BC
;
; File not found
;
l0ca3:
	ld	e,53
	_LD.BC
;
; Bad file number
;
l0ca6:
	ld	e,52
	_LD.BC
;
; Internal error
;
l0ca9:
	ld	e,51
	_LD.BC
;
; Input past end
;
l0cac:
	ld	e,62
	_LD.BC
;
; File already open
;
l0caf:
	ld	e,55
	_LD.BC
;
; Bad file name
;
l0cb2:
	ld	e,64
	_LD.BC
;
; Bad record number
;
l0cb5:
	ld	e,63
	_LD.BC
;
; Field overflow
;
l0cb8:
	ld	e,50
	_LD.BC
;
; Too many files
;
l0cbb:
	ld	e,67
	_LD.BC
;
; File already exists
;
l0cbe:
	ld	e,58
	jp	_error
;
;
;
l0cc3:
	ld	hl,(direct_1)	; Get direct state
	ld	(dir.mode),hl	; .. set it
;
; Statement : 0x9b : ??
;             0x9c : ??
;
; Syntax error
;
l0cc9:
	ld	e,2
	_LD.BC
;
; Division by zero
;
l0ccc:
	ld	e,11
	_LD.BC
;
; NEXT without FOR
;
l0ccf:
	ld	e,1
	_LD.BC
;
; Redimensioned array
;
l0cd2:
	ld	e,10
	_LD.BC
;
; Undefined user function
;
l0cd5:
	ld	e,18
	_LD.BC
;
; RESUME without error
;
l0cd8:
	ld	e,20
	_LD.BC
;
; Overflow
;
l0cdb:
	ld	e,6
	_LD.BC
;
; Missing operand
;
l0cde:
	ld	e,22
	_LD.BC
;
; Type mismatch
;
l0ce1:
	ld	e,13
;
; Process error - Error # in reg E
;
_error:
	ld	hl,(dir.mode)	; Get direct mode
	ld	(direct_2),hl	; .. save
	xor	a
	ld	(l0bed),a
	ld	(l0bf3),a
	ld	a,h
	and	l
	inc	a
	jp	z,l0cf9
	ld	(l0ab5),hl
l0cf9:
	ld	bc,l0d02	; Get return address
l0cfc:
	ld	hl,(curstk)	; .. get stack
	jp	l43a2		; .. reset error environment
;
; Error processing cont'd
;
l0d02:
	pop	bc
	ld	a,e		; Get error number
	ld	c,e
	ld	(err.num),a	; .. save
	ld	hl,(l0aaf)
	ld	(l0ab7),hl
	ex	de,hl
	ld	hl,(direct_2)	; Get direct mode
	ld	a,h
	and	l
	inc	a
	jp	z,l0d1f		; .. -1 is direct
	ld	(direct_4),hl	; .. save
	ex	de,hl
	ld	(cont.mode),hl	; .. set CONT state
l0d1f:
	ld	hl,(l0ab9)
	ld	a,h
	or	l
	ex	de,hl
	ld	hl,l0abb
	jp	z,l0d34
	and	(hl)
	jp	nz,l0d34
	dec	(hl)
	ex	de,hl
	jp	l12c0
l0d34:
	xor	a
	ld	(hl),a
	ld	e,c
	ld	(_brk),a	; Set echo mode
	call	cls.CON		; Clear console
	ld	hl,l04b3	; Init message pointer
	ld	a,e		; Get error number
	cp	67+1		; Test range
	jp	nc,l0d50
	cp	50		; Test I/O error
	jp	nc,l0d52	; .. yeap
	cp	30+1		; Test within standard
	jp	c,l0d55		; .. yeap
l0d50:
	ld	a,21+50-30-1	; Map for unprintable error
l0d52:
	sub	50-30-1		; .. gap in 30-50
	ld	e,a		; Set count
l0d55:
	call	l14ee		; Skip message
	inc	hl
	dec	e
	jp	nz,l0d55	; .. till found
	push	hl
	ld	hl,(direct_2)	; Get direct mode
	ex	(sp),hl		; Get back message
l0d62:
	ld	a,(hl)
	cp	'?'		; Test defined
	jp	nz,l0d6f	; .. nope
	pop	hl
	ld	hl,l04b3	; .. reset pointer
	jp	l0d50		; .. tell unprintable error
l0d6f:
	call	l4723
	pop	hl
	ld	de,lfffe
	call	cp.r
	call	z,fnl		; HL = DE, new line
	jp	z,l59bb
	ld	a,h
	and	l
	inc	a
	call	nz,l3112
	_LD.A
;
;
;
l0d86:
	pop	bc
;
; (Re)start BASIC interpreter
;
l0d87::
	call	cls.dev_io	; Clear I/O
	xor	a
	ld	(_brk),a	; Set echo mode
	call	l534d
	call	cls.CON		; Clear console
	ld	hl,l0c45
	call	$-$		; Tell ok
@@MSG	equ	$-2
	ld	a,(err.num)	; Get error number
	sub	2		; Test syntax error
	call	z,l3cd5		; .. yeap
l0da2:
	ld	hl,lffff
	ld	(dir.mode),hl	; Set direct mode
	ld	a,(auto.mode)	; Get AUTO mode
	or	a
	jp	z,l0df9		; .. no AUTO selected
	ld	hl,(AUTO.inc)	; Get AUTO increment
	push	hl
	call	l311a
	pop	de
	push	de
	call	l0ef8
	ld	a,'*'
	jp	c,l0dc2
	ld	a,' '
l0dc2:
	call	putchar		; Print blank or '*'
	call	gets		; Input a line
	pop	de
	jp	nc,l0dda	; .. ok
	xor	a
	ld	(auto.mode),a	; .. clear AUTO mode
	jp	l0d87
l0dd3:
	xor	a
	ld	(auto.mode),a	; .. clear AUTO mode
	jp	l0def
l0dda:
	ld	hl,(AUTO.line)	; Get AUTO line
	add	hl,de		; Add increment
	jp	c,l0dd3		; .. out of range
	push	de
	ld	de,lfff9	; Get max line
	call	cp.r		; Compare HL:DE
	pop	de
	jp	nc,l0dd3	; HL >= DE
	ld	(AUTO.inc),hl	; .. set increment
l0def:
	ld	a,($LINE)	; Test any in line
	or	a
	jp	z,l0da2		; .. nope
	jp	l3ee2
l0df9::
	call	gets		; Input a line
	jp	c,l0da2		; .. end of file
	call	get.tok		; Get from line
	inc	a		; Test any character here
	dec	a
	jp	z,l0da2		; .. nope
	push	af
	call	l1428
	call	trlskip		; Skip trailing blanks
	ld	a,(hl)		; .. get character
	cp	' '		; Test blank
	call	z,inc.hl	; .. yeap, skip it
l0e14:
	push	de
	call	cp.token	; Copy token line
	pop	de
	pop	af
	ld	(l0aaf),hl	; Init buffer
	jp	nc,l538a
	push	de
	push	bc
	call	l5d65
	call	get.tok
	or	a
	push	af
	ex	de,hl
	ld	(l0ab5),hl
	ex	de,hl
	call	l0ef8
	jp	c,l0e3b
	pop	af
	push	af
	jp	z,l14cc
	or	a
l0e3b:
	push	bc
	push	af
	push	hl
	call	l2435
	pop	hl
	pop	af
	pop	bc
	push	bc
	call	c,l22a2
	pop	de
	pop	af
	push	de
	jp	z,l0e87
	pop	de
	ld	a,(l0bf3)
	or	a
	jp	nz,l0e5c
	ld	hl,(himem)	; Get high memory
	ld	(mem.top),hl	; .. save for top
l0e5c:
	ld	hl,(prg.top)	; Get top of program
	ex	(sp),hl
	pop	bc
	push	hl
	add	hl,bc
	push	hl
	call	l42b6
	pop	hl
	ld	(prg.top),hl	; .. save new top
	ex	de,hl
	ld	(hl),h
	pop	bc
	pop	de
	push	hl
	inc	hl
	inc	hl
	ld	(hl),e
	inc	hl
	ld	(hl),d
	inc	hl
	ld	de,@TOKEN	; Load token buffer
	dec	bc		; .. fix length
	dec	bc
	dec	bc
	dec	bc
l0e7d:
	ld	a,(de)		; Unpack token
	ld	(hl),a
	inc	hl
	inc	de
	dec	bc
	ld	a,c
	or	b
	jp	nz,l0e7d
l0e87:
	pop	de
	call	l0eaf
	ld	hl,l0080
	ld	(hl),0
	ld	(F.arr),hl	; .. save into file array
	ld	hl,(FP)		; Get file pointer
	ld	(l0abc),hl
	call	l4337
	ld	hl,(F.ptr)	; Get base file pointer
	ld	(F.arr),hl	; .. into array
	ld	hl,(l0abc)
	ld	(FP),hl		; .. reset file pointer
	jp	l0da2
l0eab:
	ld	hl,(prg.base)	; Get base of program
	ex	de,hl
l0eaf:
	ld	h,d
	ld	l,e
	ld	a,(hl)
	inc	hl
	or	(hl)
	ret	z
	inc	hl
	inc	hl
l0eb7:
	inc	hl
	ld	a,(hl)
l0eb9:
	or	a
	jp	z,l0ed0
	cp	' '
	jp	nc,l0eb7
	cp	lf+1
	jp	c,l0eb7
	call	l1306
	call	get.tok
	jp	l0eb9
l0ed0:
	inc	hl
	ex	de,hl
	ld	(hl),e
	inc	hl
	ld	(hl),d
	jp	l0eaf
l0ed8:
	ld	de,l0000
	push	de
	jp	z,l0eeb
	pop	de
	call	l141d
	push	de
	jp	z,l0ef4
	call	ilcmp
	db	0f3h
l0eeb:
	ld	de,lfffa
	call	nz,l141d
	jp	nz,l0cc9
l0ef4:
	ex	de,hl
	pop	de
l0ef6:
	ex	(sp),hl
	push	hl
l0ef8:
	ld	hl,(prg.base)	; Get base of program
l0efb:
	ld	b,h
	ld	c,l
	ld	a,(hl)
	inc	hl
	or	(hl)
	dec	hl
	ret	z
	inc	hl
	inc	hl
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	call	cp.r		; Compare HL:DE
	ld	h,b
	ld	l,c
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ccf
	ret	z		; .. same
	ccf
	ret	nc
	jp	l0efb
;
; Copy token line from reg HL
; EXIT	Reg BC holds length of token line
;	Reg HL points to token buffer
;
cp.token::
	xor	a		; Init some values
	ld	(l0a69),a
	ld	(l0a68),a
	ld	bc,TOKLEN	; Init length
	ld	de,@TOKEN	; .. and destination
l0f25:
	ld	a,(hl)		; Get next
	or	a		; .. test end
	jp	nz,l0f3d	; .. nope
l0f2a:
	ld	hl,TOKLEN+5
	ld	a,l		; Calculate current length
	sub	c
	ld	c,a
	ld	a,h
	sbc	a,b
	ld	b,a
	ld	hl,l0822	; Set buffer address
	xor	a
	ld	(de),a		; Close next three bytes
	inc	de
	ld	(de),a
	inc	de
	ld	(de),a
	ret
l0f3d:
	cp	'"'		; Test string follows
	jp	z,l0f79		; .. yeap
	cp	' '		; Test blank
	jp	z,l0f4f		; .. yeap
	ld	a,(l0a68)
	or	a
	ld	a,(hl)
	jp	z,l0f82
l0f4f:
	inc	hl
	push	af
	call	_st.token	; Save token
	pop	af
	sub	':'
	jp	z,l0f61
	cp	084h-':'
	jp	nz,l0f67
	ld	a,1
l0f61:
	ld	(l0a68),a	; (Re)Set values
	ld	(l0a69),a
l0f67:
	sub	08fh-':'
	jp	nz,l0f25
	push	af
l0f6d:
	ld	a,(hl)
	or	a
	ex	(sp),hl
	ld	a,h
	pop	hl
	jp	z,l0f2a
	cp	(hl)
	jp	z,l0f4f
l0f79:
	push	af		; Save delimiter
	ld	a,(hl)		; Get character
l0f7b:
	inc	hl
	call	_st.token	; Save token
	jp	l0f6d
l0f82:
	cp	'?'		; Test special
	ld	a,091h
	push	de
	push	bc
	jp	z,l1048		; .. map to PRINT
	ld	de,l046a				;;;????????
	call	toupper_	; Get upper case
	call	isalph_		; Test A..Z
;;::
	jp	c,l1097		; .. nope, maybe number
	push	hl		; Save pointer
	ld	de,l0fcc
	call	cp.str		; Find GO
	jp	nz,key.token	; .. nope, get token
	call	get.tok
	ld	de,l0fd0
	call	cp.str		; Find TO
	ld	a,089h		; .. set GOTO
	jp	z,l0fb8		; .. got it		;;;?????????
	ld	de,l0fd3
	call	cp.str		; Find SUB
	jp	nz,key.token	; .. nope, get token
l0fb8:
	ld	a,08dh		; Set GOSUB
	pop	bc
	jp	l1048
;
; Compare strings in DE:HL - Zero set indicates match
;
cp.str:
	ld	a,(de)		; Get from 1st string
	or	a
	ret	z		; End if zero
	ld	c,a		; .. save
	call	toupper_	; Get upper case
	cp	c
	ret	nz
	inc	hl
	inc	de
	jp	cp.str
;
l0fcc:
	db	'GO ',null
l0fd0:
	db	'TO',null
l0fd3:
	db	'UB',null
;
; Find key word in token table
;
key.token:
	pop	hl		; Get back pointer
	call	toupper_	; Get upper case
	push	hl
	ld	hl,l0207	; Init key table
	sub	'A'		; Strip off offset
	add	a,a
	ld	c,a		; .. for index
	ld	b,0
	add	hl,bc		; .. into table
	ld	e,(hl)		; Fetch corresponding $address
	inc	hl
	ld	d,(hl)
	pop	hl
	inc	hl
l0fea:
	push	hl
l0feb:
	call	toupper_	; Get upper case
	ld	c,a
	ld	a,(de)
	and	NoMSB		; No hi bit
	jp	z,l1164		; .. end of table
	inc	hl
	cp	c		; Compare
	jp	nz,l103c	; .. maybe next one
	ld	a,(de)
	inc	de
	or	a		; Test match
	jp	p,l0feb		; .. no, maybe next time :-)
	ld	a,c
	cp	'('		; Test open argument
	jp	z,l1021		; .. yeap
	ld	a,(de)		; Fetch token
	cp	0d3h		; Test FN
	jp	z,l1021
	cp	0d2h		; .. or USR
	jp	z,l1021
	call	toupper_	; Get upper case
	cp	'.'
	jp	z,l101c
	call	l21e2
l101c:
	ld	a,0
	jp	nc,l1164
l1021:
	pop	af
	ld	a,(de)		; Get token
	or	a		; Test range
	jp	m,l1047		; .. 0x80 .. 0xFF
	pop	bc
	pop	de
	or	MSB		; Set bit 0x80
	push	af
	ld	a,0ffh
	call	_st.token	; Give token prefix
	xor	a
	ld	(l0a69),a	; Clear ??
	pop	af
	call	_st.token	; .. store token
	jp	l0f25
l103c:
	pop	hl
l103d:
	ld	a,(de)		; .. fix table for next one
	inc	de
	or	a
	jp	p,l103d
	inc	de
	jp	l0fea
l1047:
	dec	hl
l1048:
	push	af		; Save token
	ld	de,l105a	; Init table
	ld	c,a
l104d:
	ld	a,(de)		; Get token
	or	a		; Test end
	jp	z,l1069		; .. yeap
	inc	de
	cp	c		; .. compare
	jp	nz,l104d	; .. nop found
	jp	l106b		; .. hit it
;
; Token table
;
l105a:
	db	08ch		; RESTORE
	db	0abh		; AUTO
	db	0ach		; RENUM
	db	0aah		; DELETE
	db	0a7h		; EDIT
	db	0a9h		; RESUME
	db	0d6h		; FRE
	db	0a2h		; ELSE
	db	08ah		; RUN
	db	093h		; LIST
	db	09fh		; LLIST
	db	089h		; GOTO
	db	0cfh		; THEN
	db	08dh		; GOSUB
	db	0
;
; -> Did *NOT* find token in above table
;
l1069::
	xor	a
	_JP.NZ
;
; -> Did find token in above table
;
l106b:
	ld	a,1
l106d:
	ld	(l0a69),a	; Set flag
	pop	af		; Get back token
	pop	bc
	pop	de
	cp	0a2h		; Test ELSE
	push	af
	call	z,_st.delim	; Store delimiter ':' if so
	pop	af
	cp	0b4h		; Test WHILE
	jp	nz,l1084
	call	_st.token	; .. store token
	ld	a,0f2h		; .. map it
l1084:
	cp	0dbh		; Test ???
	jp	nz,l1135
	push	af
	call	_st.delim	; Store delimiter ':'
	ld	a,08fh		; Map REM
	call	_st.token
	pop	af
	push	af
	jp	l0f7b
;
; -> Got not letter A..Z, so try digit
;
l1097::
	ld	a,(hl)		; Get next
	cp	'.'		; .. test special
	jp	z,l10a7
	cp	'9'+1		; Test digit
	jp	nc,l1122	; .. nope
	cp	'0'
	jp	c,l1122
l10a7:
	ld	a,(l0a69)
	or	a
	ld	a,(hl)
	pop	bc
	pop	de
	jp	m,l0f4f
	jp	z,l10d3
	cp	'.'		; Test special
	jp	z,l0f4f
	ld	a,00eh
	call	_st.token	; Store ???
	push	de
	call	l1428		; Fix for next
	call	trlskip		; Skip trailing blanks
l10c5:
	ex	(sp),hl
	ex	de,hl
l10c7:
	ld	a,l
	call	_st.token	; Store low number
	ld	a,h
l10cc:
	pop	hl
	call	_st.token	; Store high number
	jp	l0f25
l10d3::
	push	de
	push	bc
	ld	a,(hl)					;;** WHY
	call	cnvnum		; Convert to number
	call	trlskip		; Skip trailing blanks
	pop	bc
	pop	de
	push	hl
	ld	a,($ARGLEN)	; Get length
	cp	2		; Test word
	jp	nz,l10ff	; .. nope
	ld	hl,($$ARG+4)	; Fetch result
	ld	a,h
	or	a
	ld	a,2
	jp	nz,l10ff
	ld	a,l		; Set byte
	ld	h,l
	ld	l,00fh		; .. set default token
	cp	9+1		; Test 0..9
	jp	nc,l10c7	; .. nope, save as byte
	add	a,011h		; .. map 0..9 to 0x11..0x1A
	jp	l10cc		; .. save
l10ff:
	push	af
	rrca
	add	a,01bh
	call	_st.token	; Store number prefix
	ld	hl,$$ARG+4
	call	get.type	; Get type
	jp	c,l1112		; .. single precision
	ld	hl,$$ARG	; Fix for double precision
l1112:
	pop	af
l1113:
	push	af
	ld	a,(hl)
	call	_st.token	; Store number
	pop	af
	inc	hl
	dec	a
	jp	nz,l1113
	pop	hl
	jp	l0f25
;
; -> Neither letter nor digit, try operator
;
l1122::
	ld	de,l046a-1	; Init table
l1125:
	inc	de
	ld	a,(de)		; Get operator
	and	NoMSB		; Strip off MSB
	jp	z,l118e		; .. not found
	inc	de
	cp	(hl)		; .. compare
	ld	a,(de)
	jp	nz,l1125	; .. no match
	jp	l11a0		; .. set it
l1135:
	cp	'&'
	jp	nz,l0f4f
	push	hl
	call	get.tok
	pop	hl
	call	toupper		; Get upper case
	cp	'H'
	ld	a,00bh
	jp	nz,l114b
	ld	a,00ch
l114b:
	call	_st.token	; Store ???
	push	de
	push	bc
	call	ato??_		; Get number
	pop	bc
	jp	l10c5		; .. store number
;
; Save delimter ':' into buffer ^DE - remaining length in BC
;
_st.delim:
	ld	a,':'
;
; Save Accu into buffer ^DE - remaining length in BC
;
_st.token:
	ld	(de),a		; .. save it
	inc	de		; Bump buffer
	dec	bc		; .. count down
	ld	a,c
	or	b		; Test remainder
	ret	nz		; .. yeap
l115f:
	ld	e,23		; Line overflow
	jp	_error
;
; -> Got no keyword in table
;
l1164:
	pop	hl
	dec	hl
	dec	a
	ld	(l0a69),a
	pop	bc
	pop	de
	call	toupper_	; Get upper case
l116f:
	call	_st.token	; Store variable name
	inc	hl
	call	toupper_	; Get upper case
	call	isalph_		; Test A..Z
	jp	nc,l116f	; .. yeap
	cp	'9'+1
	jp	nc,l118b
	cp	'0'
	jp	nc,l116f
	cp	'.'
	jp	z,l116f
l118b:
	jp	l0f25
l118e:
	ld	a,(hl)		; Get from line
	cp	' '		; Test valid character
	jp	nc,l11a0	; .. yeap
	cp	tab		; .. or tab
	jp	z,l11a0
	cp	lf		; .. or line feed
	jp	z,l11a0
	ld	a,' '		; Map control
l11a0:
	push	af		; Save token
	ld	a,(l0a69)
	inc	a
	jp	z,l11a9
	dec	a
l11a9:
	jp	l106d
;
; Skip trailing blanks
;
trlskip:
	dec	hl		; Get previous
	ld	a,(hl)		; .. fetch character
	cp	' '		; Test blank
	jp	z,trlskip
	cp	tab		; .. tab
	jp	z,trlskip
	cp	lf		; .. or line feed
	jp	z,trlskip
	inc	hl		; .. fix pointer
	ret
;
; Statement : FOR <var>=<exp> TO <exp> [STEP <exp>]
;
l11bf:
	ld	a,64h
	ld	(l0aa5),a
	call	var.adr		; Get address of variable
	call	ilcmp		; Verify '='
	db	0f0h
	push	de
	ex	de,hl
	ld	(@@ptr),hl	; .. save address
	ex	de,hl
	ld	a,($ARGLEN)	; Get length of value
	push	af
	call	EXPR		; Get expression
	pop	af
	push	hl
	call	l1fac
	ld	hl,l0bc0
	call	l28c0
	pop	hl
	pop	de
	pop	bc
	push	hl
	call	_DATA		; .. process data field
	ld	(l0aa1),hl
	ld	hl,l0002
	add	hl,sp
l11f1:
	call	l0c54
	jp	nz,l1211
	add	hl,bc
	push	de
	dec	hl
	ld	d,(hl)
	dec	hl
	ld	e,(hl)
	inc	hl
	inc	hl
	push	hl
	ld	hl,(l0aa1)
	call	cp.r		; Compare HL:DE
	pop	hl
	pop	de
	jp	nz,l11f1	; .. HL <> DE
	pop	de
	ld	sp,hl		; Set stack
	ld	(curstk),hl	; .. save it
	_LD.C
l1211:
	pop	de
	ex	de,hl
	ld	c,8
	call	tstmem		; Verify enough memory
	push	hl
	ld	hl,(l0aa1)
	ex	(sp),hl
	push	hl
	ld	hl,(dir.mode)	; Get direct mode
	ex	(sp),hl
	call	ilcmp		; Verify TO
	db	0ceh
	call	get.type	; Get type
	jp	z,l0ce1		; .. pointer
	jp	nc,l0ce1	; .. double precision
	push	af
	call	EXPR		; Get expression
	pop	af
	push	hl
	jp	p,l124e
	call	_CINT		; Get integer
	ex	(sp),hl
	ld	de,1		; Set default step
	ld	a,(hl)		; Get next
	cp	0d1h		; Test STEP
	call	z,l2053		; .. yeap, get step
	push	de
	push	hl
	ex	de,hl
	call	l2892
	jp	l1271
l124e:
	call	l29f4
	call	l28b4
	pop	hl
	push	bc
	push	de
	ld	bc,081h*256+0
	ld	d,c
	ld	e,d
	ld	a,(hl)
	cp	0d1h
	ld	a,1
	jp	nz,l1272
	call	l1a03
	push	hl
	call	l29f4
	call	l28b4
	call	l2845
l1271:
	pop	hl
l1272:
	push	bc
	push	de
	ld	c,a
	call	get.type	; Get type
	ld	b,a		; .. save
	push	bc
	dec	hl
	call	get.tok
	jp	nz,l0cc9
	call	l24e2
	call	get.tok
	push	hl
	push	hl
	ld	hl,(direct_3)	; Set direct mode
	ld	(dir.mode),hl	; .. reet it
	ld	hl,(@@ptr)	; Get address of variable
	ex	(sp),hl
	ld	b,82h
	push	bc
	inc	sp
	push	af
	push	af
	jp	l45a0
l129c:
	ld	b,82h
	push	bc
	inc	sp
l12a0:
	push	hl
	call	$-$		; Get console state
$CST1	equ	$-2
	pop	hl
	or	a
	call	nz,l425c	; .. got character
	ld	(l0aaf),hl
	ex	de,hl
	ld	hl,0
	add	hl,sp		; .. copy stack
	ld	(curstk),hl	; .. save it
	ex	de,hl
	ld	a,(hl)
	cp	':'
	jp	z,l12e5
	or	a
	jp	nz,l0cc9
	inc	hl
l12c0:
	ld	a,(hl)
	inc	hl
	or	(hl)
	jp	z,l0c85
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	ld	(dir.mode),hl	; Set direct mode
	ld	a,(trcflg)	; Test TRON
	or	a
	jp	z,l12e4		; .. nope
	push	de
	ld	a,'['
	call	putchar
	call	l311a
	ld	a,']'
	call	putchar
	pop	de
l12e4:
	ex	de,hl
l12e5:
	call	get.tok
	ld	de,l12a0
	push	de
	ret	z
l12ed:
	sub	081h
	jp	c,_LET		; .. aha, LET it be
	cp	0cch-081h+1
	jp	nc,l1fe2
	rlca
	ld	c,a
	ld	b,0
	ex	de,hl
	ld	hl,l0107
	add	hl,bc
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	push	bc
	ex	de,hl
;
;
;
get.tok::
	inc	hl
l1306:
	ld	a,(hl)		; Get character
	cp	'9'+1		; Test range
	ret	nc		; .. not numeric
l130a:
	cp	' '		; Skip blanks
	jp	z,get.tok
	jp	nc,l1386	; .. maybe number
	or	a
	ret	z
	cp	lf+1		; Test control
	jp	c,l1381
	cp	'^'-'@'		; Test special
	jp	nz,l1323
	ld	a,(l0a6c)	; .. map it
	or	a
	ret
l1323:
	cp	'P'-'@'
	jp	z,l1360
	push	af
	inc	hl
	ld	(l0a6c),a
	sub	1ch
	jp	nc,l1366
	sub	11h-1ch
	jp	nc,l133e
	cp	0fh-11h
	jp	nz,l1352
	ld	a,(hl)
	inc	hl
l133e:
	ld	(l0a6a),hl
	ld	h,0
l1343:
	ld	l,a
	ld	(l0a6e),hl
	ld	a,2
	ld	(l0a6d),a
	ld	hl,l138c
	pop	af
	or	a
	ret
l1352:
	ld	a,(hl)
	inc	hl
	inc	hl
	ld	(l0a6a),hl
	dec	hl
	ld	h,(hl)
	jp	l1343
l135d:
	call	l138e
l1360:
	ld	hl,(l0a6a)	; Get pointer
	jp	l1306
l1366:
	inc	a
	rlca
	ld	(l0a6d),a
	push	de
	push	bc
	ld	de,l0a6e
	ex	de,hl
	ld	b,a
	call	l28cd
	ex	de,hl
	pop	bc
	pop	de
	ld	(l0a6a),hl
	pop	af
	ld	hl,l138c
	or	a
	ret
l1381:
	cp	tab		; .. look for tab
	jp	nc,get.tok
l1386:
	cp	'0'		; Test number
	ccf
	inc	a
	dec	a
	ret
;
;
;
l138c:
	ld	e,10h
;
;
;
l138e:
	ld	a,(l0a6c)
	cp	0fh
	jp	nc,l13ab
	cp	0dh
	jp	c,l13ab
	ld	hl,(l0a6e)
	jp	nz,l13a8
	inc	hl
	inc	hl
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
l13a8:
	jp	l2c03
l13ab:
	ld	a,(l0a6d)
	ld	($ARGLEN),a	; Set length
	cp	8		; Test double precision
	jp	z,l13c3
	ld	hl,(l0a6e)	; .. unpack single precision
	ld	($$ARG+4),hl
	ld	hl,(l0a70)
	ld	($$ARG+6),hl
	ret
l13c3:
	ld	hl,l0a6e
	jp	l28ee
;
; Statement : DEF<type> <range(s) of letters>
;
; Statement : DEFSTR
;
l13c9:
	ld	e,3
	_LD.BC
;
; Statement : DEFINT
;
l13cc:
	ld	e,2
	_LD.BC
;
; Statement : DEFSNG
;
l13cf:
	ld	e,4
	_LD.BC
;
; Statement : DEFDBL
;
l13d2:
	ld	e,8
l13d4:
	call	isalph		; Test A..Z
	ld	bc,l0cc9
	push	bc
	ret	c		; .. nope
	sub	'A'
	ld	c,a
	ld	b,a
	call	get.tok
	cp	0f3h
	jp	nz,l13f5
	call	get.tok
	call	isalph		; Test A..Z
	ret	c		; .. nope
	sub	'A'
	ld	b,a
	call	get.tok
l13f5:
	ld	a,b
	sub	c
	ret	c
	inc	a
	ex	(sp),hl
	ld	hl,l0aca
	ld	b,0
	add	hl,bc
l1400:
	ld	(hl),e
	inc	hl
	dec	a
	jp	nz,l1400
	pop	hl
	ld	a,(hl)
	cp	','
	ret	nz
	call	get.tok
	jp	l13d4
l1411:
	call	get.tok
l1414:
	call	l2056
	ret	p
;
; Process illegal function call
;
_ill.func:
	ld	e,5		; Illegal function call
	jp	_error
;
;
;
l141d:
	ld	a,(hl)
	cp	'.'
	ex	de,hl
	ld	hl,(l0ab5)
	ex	de,hl
	jp	z,get.tok
;
;
;
l1428:
	dec	hl
l1429:
	call	get.tok
	cp	0eh
	jp	z,l1433
	cp	0dh
l1433:
	ex	de,hl
	ld	hl,(l0a6e)
	ex	de,hl
	jp	z,get.tok
	xor	a
	ld	(l0a6c),a
	dec	hl
	ld	de,l0000
l1443:
	call	get.tok
	ret	nc
	push	hl
	push	af
	ld	hl,l1998
	call	cp.r
	jp	c,l1464		; HL < DE
	ld	h,d
	ld	l,e
	add	hl,de
	add	hl,hl
	add	hl,de
	add	hl,hl
	pop	af
	sub	'0'
	ld	e,a
	ld	d,0
	add	hl,de
	ex	de,hl
	pop	hl
	jp	l1443
l1464:
	pop	af
	pop	hl
	ret
;
; Statement : RUN [<line number>]
;             RUN <filename>[,R]
;
_RUN:
	jp	z,l4337		; .. simple start
	cp	00eh		; Test number follows
	jp	z,l1474
	cp	00dh
	jp	nz,_FRUN	; .. must be file
l1474:
	call	l433b
	ld	bc,l12a0
	jp	l1494
;
; Statement : GOSUB <line number>
;
l147d:
	ld	c,3
	call	tstmem		; Verify enough memory
	call	l1428
	pop	bc
	push	hl
	push	hl
	ld	hl,(dir.mode)	; Get direct mode
	ex	(sp),hl
	ld	a,08dh		; Set GOSUB
	push	af
	inc	sp
	push	bc
	jp	l1498
l1494:
	push	bc
;
; Statement : GOTO <line number>
;
l1495:
	call	l1428
l1498:
	ld	a,(l0a6c)
	cp	0dh
	ex	de,hl
	ret	z
	cp	0eh
	jp	nz,l0cc9
	ex	de,hl
	push	hl
	ld	hl,(l0a6a)
	ex	(sp),hl
	call	l14ee
	inc	hl
	push	hl
	ld	hl,(dir.mode)	; Get direct mode
	call	cp.r		; Compare HL:DE
	pop	hl
	call	c,l0efb		; .. HL < DE
	call	nc,l0ef8
	jp	nc,l14cc
	dec	bc
	ld	a,0dh
	ld	(l0aa9),a
	pop	hl
	call	l242c
	ld	h,b
	ld	l,c
	ret
l14cc:
	ld	e,8		; Undefined line
	jp	_error
;
; Statement : RETURN
;
l14d1:
	ret	nz
	ld	d,-1		; Set direction
	call	l0c50		; .. fix for FOR, WHILE
	ld	sp,hl		; Set for stack
	ld	(curstk),hl	; .. save it
	cp	8dh
	ld	e,3		; Return without GOSUB
	jp	nz,_error
	pop	hl
	ld	(dir.mode),hl	; .. set direct mode
	ld	hl,l12a0
	ex	(sp),hl
	_LD.A
l14eb:
	pop	hl
;
; Statement : DATA <list of constants>
;             COMMON <list of variables>
;
_DATA:
	_LD.BC
	_LDA
;
; Statement : REM <remark>
;             ELSE <statement(s)>|<line number>
;
l14ee:
	ld	c,0
	ld	b,0
l14f2:
	ld	a,c
	ld	c,b
	ld	b,a
l14f5:
	dec	hl
l14f6:
	call	get.tok
	or	a
	ret	z
	cp	b
	ret	z
	inc	hl
	cp	'"'
	jp	z,l14f2
	inc	a
	jp	z,l14f6
	sub	8ch
	jp	nz,l14f5
	cp	b
	adc	a,d
	ld	d,a
	jp	l14f5
l1512:
	pop	af
	add	a,3
	jp	l152d
;
; Statement : LET <var>=<expr>
;
_LET:
	call	var.adr		; Get address of variable
	call	ilcmp		; Verify '='
	db	0f0h
	ex	de,hl
	ld	(@@ptr),hl	; Save address
	ex	de,hl
	push	de
	ld	a,($ARGLEN)	; Get length of value
	push	af
	call	EXPR		; Get expression
	pop	af
l152d:
	ex	(sp),hl
l152e:
	ld	b,a
	ld	a,($ARGLEN)	; Get length
	cp	b		; Test same
	ld	a,b
	jp	z,l153d		; .. yeap
	call	l1fac
l153a:
	ld	a,($ARGLEN)	; Get length
l153d:
	ld	de,$$ARG+4
	cp	4+1		; Test integer or single
	jp	c,l1548		; .. yeap
	ld	de,$$ARG
l1548:
	push	hl
	cp	3		; Test pointer
	jp	nz,l157f	; .. nope
	ld	hl,($$ARG+4)
	push	hl
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	hl,(prg.base)	; Get base of program
	call	cp.r
	jp	nc,l1573	; HL >= DE
	ld	hl,(l0ac6)
	call	cp.r		; Compare HL:DE
	pop	de
	jp	nc,l157b	; .. HL >= DE
	ld	hl,STR.arr+10*3	; Point to last record
	call	cp.r
	jp	nc,l157b	; HL >= DE
	_LD.A
l1573:
	pop	de
	call	l48c6
	ex	de,hl
	call	l46a3
l157b:
	call	l48c6
	ex	(sp),hl
l157f:
	call	l28c9
	pop	de
	pop	hl
	ret
;
; Statement : ON ERROR GOTO <line number>
;             ON <expr> GOSUB <list of line numbers>
;             ON <expr> GOTO <list of line numbers>
;
l1585:
	cp	0a8h		; Test ERROR
	jp	nz,l15b5	; .. nope
	call	get.tok
	call	ilcmp		; Verify GOTO
	db	089h
	call	l1428
	ld	a,d
	or	e
	jp	z,l15a2
	call	l0ef6
	ld	d,b
	ld	e,c
	pop	hl
	jp	nc,l14cc
l15a2:
	ex	de,hl
	ld	(l0ab9),hl
	ex	de,hl
	ret	c
	ld	a,(l0abb)
	or	a
	ld	a,e
	ret	z
	ld	a,(err.num)	; Get error number
	ld	e,a
	jp	l0cf9		; .. process error
l15b5:
	call	l2075
	ld	a,(hl)
	ld	b,a
	cp	08dh		; Test GOSUB
	jp	z,l15c4
	call	ilcmp		; Verify GOTO
	db	089h
	dec	hl
l15c4:
	ld	c,e
l15c5:
	dec	c
	ld	a,b
	jp	z,l12ed
	call	l1429
	cp	','
	ret	nz
	jp	l15c5
;
; Statement : RESUME
;             RESUME 0
;             RESUME NEXT
;             RESUME <line number>
;
l15d3:
	ld	de,l0abb
	ld	a,(de)
	or	a
	jp	z,l0cd8
	inc	a
	ld	(err.num),a	; .. bump error number
	ld	(de),a
	ld	a,(hl)
	cp	83h
	jp	z,l15f3
	call	l1428
	ret	nz
	ld	a,d
	or	e
	jp	nz,l1498
	inc	a
	jp	l15f7
l15f3:
	call	get.tok
	ret	nz
l15f7:
	ld	hl,(l0ab7)
	ex	de,hl
	ld	hl,(direct_2)	; Get direct mode
	ld	(dir.mode),hl	; .. reset it
	ex	de,hl
	ret	nz
	ld	a,(hl)
	or	a
	jp	nz,l160c
	inc	hl
	inc	hl
	inc	hl
	inc	hl
l160c:
	inc	hl
	jp	_DATA		; .. process DATA
;
; Statement : ERROR <integer expr>
;
l1610:
	call	l2075
	ret	nz
	or	a
	jp	z,_ill.func	; .. illegal call if zero
	jp	_error		; .. process error
;
; Statement : AUTO [<line number>[,increment>]]
;
l161b:
	ld	de,10		; Set default values
	push	de
	jp	z,l163d		; .. no argues
	call	l141d
	ex	de,hl
	ex	(sp),hl
	jp	z,l163e
	ex	de,hl
	call	ilcmp
	db	','
	ex	de,hl
	ld	hl,(AUTO.line)	; Get AUTO line
	ex	de,hl
	jp	z,l163d
	call	l1428
	jp	nz,l0cc9
l163d:
	ex	de,hl
l163e:
	ld	a,h		; Test line 0
	or	l
	jp	z,_ill.func	; Illegal call on line zero
	ld	(AUTO.line),hl	; Save AUTO line
	ld	(auto.mode),a	; .. AUTO mode
	pop	hl
	ld	(AUTO.inc),hl	; .. AUTO increment
	pop	bc
	jp	l0da2
;
; Statement : IF <expr> THEN {<statement(s)>|<line number>}
;                      [ELSE {<statement(s)>|<line number>}]
;             IF <expr> GOTO <line number>
;                      [ELSE {<statement(s)>|<line number>}]
;
l1651:
	call	EXPR		; Get expression
	ld	a,(hl)
	cp	','
	call	z,get.tok
	cp	089h		; Test GOTO
	jp	z,l1664
	call	ilcmp		; Verify THEN
	db	0cfh
	dec	hl
l1664:
	push	hl
	call	l2886
	pop	hl
	jp	z,l167e
l166c:
	call	get.tok
	ret	z
	cp	0eh
	jp	z,l1495
	cp	0dh
	jp	nz,l12ed
	ld	hl,(l0a6e)
	ret
l167e:
	ld	d,1
l1680:
	call	_DATA		; .. process DATA
	or	a
	ret	z
	call	get.tok
	cp	0a2h
	jp	nz,l1680
	dec	d
	jp	nz,l1680
	jp	l166c
;
; Statement : LPRINT [<list of expr>]
;             LPRINT USING <string expr>;<list of expr>
;
l1694:
	ld	a,1
	ld	(iodev),a	; Set printer
	jp	l16a1
;
; Statement : PRINT [<list of expr>]
;             PRINT USING <string expr>;<list of expr>
;             PRINT#<file number>[,<list of expr>]
;             PRINT#<file number>,USING <string expr>;<list of expr>
;
l169c:
	ld	c,2
	call	l510d
l16a1:
	dec	hl
	call	get.tok
	call	z,fnl		; .. give new line
l16a8:
	jp	z,clr.FP	; .. reset file setting on end
	cp	0d9h
	jp	z,l3ef7
	cp	0d0h
	jp	z,l1765
	cp	0d4h
	jp	z,l1765
	push	hl
	cp	','
	jp	z,l1725
	cp	';'
	jp	z,l17e2
	pop	bc
	call	EXPR		; Get expression
	push	hl
	call	get.type	; Get type
	jp	z,l16dc		; .. got pointer
	call	l3129
	call	l46c7
	ld	(hl),' '
	ld	hl,($$ARG+4)
	inc	(hl)
l16dc:
	call	fpact		; Test file active
	jp	nz,l171e	; .. yeap
	ld	hl,($$ARG+4)
	ld	a,(iodev)	; Test device
	or	a
	jp	z,l1705		; .. console
	ld	a,(l078f)
	ld	b,a
	inc	a
	jp	z,l171e
	ld	a,(colLST)	; Get column
	or	a
	jp	z,l171e		; .. left side
	add	a,(hl)
	ccf
	jp	nc,l171b
	dec	a
	cp	b
	jp	l171b
l1705:
	ld	a,(l0790)
	ld	b,a
	inc	a
	jp	z,l171e
	ld	a,(colCON)	; Get column
	or	a
	jp	z,l171e		; .. left side
	add	a,(hl)
	ccf
	jp	nc,l171b
	dec	a
	cp	b
l171b:
	call	nc,fnl		; .. give new line
l171e:
	call	l4726
	pop	hl
	jp	l16a1
l1725:
	ld	bc,l0028
	ld	hl,(FP)		; Get file pointer
	add	hl,bc
	call	fpact		; Test file active
	ld	a,(hl)
	jp	nz,l175c	; .. yeap
	ld	a,(iodev)	; Get device
	or	a
	jp	z,l1749		; .. console
	ld	a,(l078e)
	ld	b,a
	inc	a
	ld	a,(colLST)	; Get column
	jp	z,l175c
	cp	b
	jp	l1756
l1749:
	ld	a,(l0791)
	ld	b,a
	ld	a,(colCON)	; Get column
	cp	255
	jp	z,l175c
	cp	b
l1756:
	call	nc,fnl		; .. give new line
	jp	nc,l17e2
l175c:
	sub	0eh
	jp	nc,l175c
	cpl
	jp	l17d7
l1765:
	push	af
	call	get.tok
	call	l2056
	pop	af
	push	af
	cp	0d4h
	jp	z,l1774
	dec	de
l1774:
	ld	a,d
	or	a
	jp	p,l177c
	ld	de,l0000
l177c:
	push	hl
	call	fpact		; Test file active
	jp	nz,l179b	; .. yeap
	ld	a,(iodev)	; Get device
	or	a
	ld	a,(l078f)
	jp	nz,l1790	; .. printer
	ld	a,(l0790)
l1790:
	ld	l,a
	inc	a
	jp	z,l179b
	ld	h,0
	call	l2c0d
	ex	de,hl
l179b:
	pop	hl
	call	ilcmp
	db	')'
	dec	hl
	pop	af
	sub	0d4h
	push	hl
	jp	z,l17c6
	ld	bc,l0028
	ld	hl,(FP)		; Get file pointer
	add	hl,bc
	call	fpact		; Test file active
	ld	a,(hl)
	jp	nz,l17c6	; .. yeap
	ld	a,(iodev)	; Get device
	or	a
	jp	z,l17c3		; .. console
	ld	a,(colLST)	; Get printer column
	jp	l17c6
l17c3:
	ld	a,(colCON)	; Get console column
l17c6:
	cpl
	add	a,e
	jp	c,l17d7
	inc	a
	jp	z,l17e2
	call	fnl		; .. give new line
	ld	a,e
	dec	a
	jp	m,l17e2
l17d7:
	inc	a
	ld	b,a
	ld	a,' '
l17db:
	call	putchar		; .. give blanks
	dec	b
	jp	nz,l17db
l17e2:
	pop	hl
	call	get.tok
	jp	l16a8
;
; Reset file pointer, enable console
;
clr.FP:
	xor	a
	ld	(iodev),a	; Set console
	push	hl
	ld	h,a
	ld	l,a
	ld	(FP),hl		; Clear file pointer
	pop	hl
	ret
;
; Statement : LINE INPUT [;][<"prompt string">;] <string var>
;             LINE INPUT#<file number>,<string var>
;
l17f5:
	call	ilcmp		; Verify INPUT
	db	085h
	cp	'#'		; Test from file
	jp	z,l51a7		; .. yeap
	call	l4c48
	call	l186f
	call	var.adr		; Get address of variable
	call	vrf.str		; Verify string
	push	de
	push	hl
	call	l4b30
	pop	de
	pop	bc
	jp	c,l4416
	push	bc
	push	de
	ld	b,0
	call	l46ca
	pop	hl
	ld	a,3
	jp	l152d
l1821:
	db	'?Redo from start',cr,lf,null
;
;
;
l1834:
	inc	hl
	ld	a,(hl)
	or	a
	jp	z,l0cc9
	cp	'"'
	jp	nz,l1834
	jp	l18da
l1842:
	pop	hl
	pop	hl
	jp	l184e
l1847:
	ld	a,(l0aa6)
	or	a
	jp	nz,l0cc3
l184e:
	pop	bc
	ld	hl,l1821
	call	l4723
	ld	hl,(l0aaf)
	ret
;
;
;
l1859:
	call	l510b
	push	hl
	ld	hl,l0961
	jp	l193b
;
; Statement : INPUT [;][<"prompt string">;] <list of variables>
;             INPUT#<file number>,<list of variables>
;
l1863:
	cp	'#'		; Test from file
	jp	z,l1859		; .. yeap
	call	l4c48
	ld	bc,l1899
	push	bc		; Set return address
l186f:
	cp	'"'		; Test string follows
	ld	a,FALSE
	ld	(_brk),a	; Set echo mode
	ld	a,TRUE
	ld	(l0be7),a	; Set no string follows
	ret	nz		; .. no string
	call	l46c8
	ld	a,(hl)
	cp	','		; Test list
	jp	nz,l188f
	xor	a
	ld	(l0be7),a	; .. set string follows
	call	get.tok
	jp	l1893
l188f:
	call	ilcmp		; Verify delimiter
	db	';'
l1893:
	push	hl
	call	l4726
	pop	hl
	ret
;
;
;
l1899:
	push	hl
	ld	a,(l0be7)	; Test previous string
	or	a
	jp	z,l18ab		; .. nope
	ld	a,'?'
	call	putchar		; Indicate input requested
	ld	a,' '
	call	putchar
l18ab:
	call	l4b30
	pop	bc
	jp	c,l4416
	push	bc
	xor	a
	ld	(l0aa6),a
	ld	(hl),','
	ex	de,hl
	pop	hl
	push	hl
	push	de
	push	de
	dec	hl
l18bf:
	ld	a,80h
	ld	(l0aa5),a
	call	get.tok
	call	l3a89
	ld	a,(hl)
	dec	hl
	cp	5bh
	jp	z,l18d6
	cp	'('
	jp	nz,l18fd
l18d6:
	inc	hl
	ld	b,0
l18d9:
	inc	b
l18da:
	call	get.tok
	jp	z,l0cc9
	cp	'"'
	jp	z,l1834
	cp	'('
	jp	z,l18d9
	cp	'['
	jp	z,l18da
	cp	']'
	jp	z,l18f9
	cp	')'
	jp	nz,l18da
l18f9:
	dec	b
	jp	nz,l18da
l18fd:
	call	get.tok
	jp	z,l1908
	cp	','
	jp	nz,l0cc9
l1908:
	ex	(sp),hl
	ld	a,(hl)
	cp	','
	jp	nz,l1842
	ld	a,1
	ld	(l0c0a),a
	call	l1964
	ld	a,(l0c0a)
	dec	a
	jp	nz,l1842
	push	hl
	call	get.type	; Get type
	call	z,l48a8		; .. process pointer
	pop	hl
	dec	hl
	call	get.tok
	ex	(sp),hl
	ld	a,(hl)
	cp	','
	jp	z,l18bf
	pop	hl
	dec	hl
	call	get.tok
	or	a
	pop	hl
	jp	nz,l184e
l193b:
	ld	(hl),','
	jp	l1945
;
; Statement : READ <list of variables>
;
l1940:
	push	hl
	ld	hl,(DATA.ptr)	; Get DATA pointer
	_OR
l1945:
	xor	a
	ld	(l0aa6),a
	ex	(sp),hl
	jp	l1951
l194d:
	call	ilcmp
	db	','
l1951:
	call	var.adr		; Get address of variable
	ex	(sp),hl
	push	de
	ld	a,(hl)
	cp	','
	jp	z,l1963
	ld	a,(l0aa6)
	or	a
	jp	nz,l19d3
l1963:
	_OR
l1964:
	xor	a
	ld	(l0bbc),a
	call	fpact		; Test file active
	jp	nz,l5197	; .. yeap
	call	get.type	; Get type
	push	af
	jp	nz,l19a2	; .. not a pointer
	call	get.tok
	ld	d,a
	ld	b,a
	cp	'"'
	jp	z,l198c
	ld	a,(l0aa6)
	or	a
	ld	d,a
	jp	z,l1989
	ld	d,':'
l1989:
	ld	b,','
	dec	hl
l198c:
	call	l46cb
l198f:
	pop	af		; Get back type
	add	a,3		; .. fix for real
	ld	c,a
	ld	a,(l0bbc)
	or	a
	ret	z
l1998:
	ld	a,c
	ex	de,hl
	ld	hl,l19b1
	ex	(sp),hl
	push	de
	jp	l152e
l19a2:
	call	get.tok
	pop	af
	push	af
	ld	bc,l198f
	push	bc		; Set return address
	jp	c,cnvnum	; .. get single
	jp	cnvdoub		; .. double
l19b1:
	dec	hl
	call	get.tok
	jp	z,l19bd
	cp	','
	jp	nz,l1847
l19bd:
	ex	(sp),hl
	dec	hl
	call	get.tok
	jp	nz,l194d
	pop	de
	ld	a,(l0aa6)
	or	a
	ex	de,hl
	jp	nz,l43fc
	push	de
	pop	hl
	jp	clr.FP		; Reset file I/O
l19d3:
	call	_DATA		; Process DATA
	or	a
	jp	nz,l19ec
	inc	hl
	ld	a,(hl)
	inc	hl
	or	(hl)
	ld	e,4		; Out of data
	jp	z,_error
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	ld	(direct_1),hl	; Save direct mode
	ex	de,hl
l19ec:
	call	get.tok
	cp	84h
	jp	nz,l19d3
	jp	l1963
l19f7:
	call	ilcmp		; Verify '='
	db	0f0h
	jp	EXPR		; .. get expression then
l19fe:
	call	ilcmp
	db	'('
;
; Get expression
;
EXPR::
	dec	hl
l1a03:
	ld	d,0
l1a05:
	push	de
	ld	c,1
	call	tstmem		; Verify enough memory
	call	l1b93
	xor	a
	ld	(l0c09),a
l1a12:
	ld	(l0abc),hl
l1a15:
	ld	hl,(l0abc)
	pop	bc
	ld	a,(hl)
	ld	(l0a9d),hl
	cp	0efh
	ret	c
	cp	0f2h
	jp	c,l1a8e
	sub	0f2h
	ld	e,a
	jp	nz,l1a34
	ld	a,($ARGLEN)	; Get length of arg
	cp	3		; Test pointer
	ld	a,e
	jp	z,l485b
l1a34:
	cp	0ch
	ret	nc
	ld	hl,l047f
	ld	d,0
	add	hl,de
	ld	a,b
	ld	d,(hl)
	cp	d
	ret	nc
	push	bc
	ld	bc,l1a15
	push	bc
	ld	a,d
	cp	7fh
	jp	z,l1aac
	cp	'Q'
	jp	c,l1aba
	and	0feh
	cp	7ah
	jp	z,l1aba
l1a58:
	ld	hl,$$ARG+4
	ld	a,($ARGLEN)	; Get length of arg
	sub	3		; Test pointer
	jp	z,l0ce1		; .. yeap
	or	a
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	push	bc
	jp	m,l1a7f
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	push	bc
	jp	po,l1a7f
	ld	hl,$$ARG
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	push	bc
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	push	bc
l1a7f:
	add	a,3
	ld	c,e
	ld	b,a
	push	bc
	ld	bc,l1ae3
l1a87:
	push	bc
	ld	hl,(l0a9d)
	jp	l1a05
l1a8e:
	ld	d,0
l1a90:
	sub	0efh
	jp	c,l1ac6
	cp	3
	jp	nc,l1ac6
	cp	1
	rla
	xor	d
	cp	d
	ld	d,a
	jp	c,l0cc9
	ld	(l0a9d),hl
	call	get.tok
	jp	l1a90
l1aac:
	call	l29f4
	call	l2899
	ld	bc,l36cc
	ld	d,7fh
	jp	l1a87
l1aba:
	push	de
	call	_CINT		; Get integer
	pop	de
	push	hl
	ld	bc,l1d75
	jp	l1a87
l1ac6:
	ld	a,b
	cp	64h
	ret	nc
	push	bc
	push	de
	ld	de,l6404
	ld	hl,l1d42
	push	hl
	call	get.type	; Get type
	jp	nz,l1a58	; .. not a pointer
	ld	hl,($$ARG+4)
	push	hl
	ld	bc,l465c
	jp	l1a87
l1ae3:
	pop	bc
	ld	a,c
	ld	(l0a68),a
	ld	a,($ARGLEN)	; Get length of arg
	cp	b		; Test same
	jp	nz,l1afc	; .. nope
	cp	2		; Test integer
	jp	z,l1b18
	cp	4		; .. or single precision
	jp	z,l1b67
	jp	nc,l1b2b
l1afc:
	ld	d,a
	ld	a,b
	cp	8		; Test double precision
	jp	z,l1b28
	ld	a,d
	cp	8
	jp	z,l1b4f
	ld	a,b
	cp	4
	jp	z,l1b64
	ld	a,d
	cp	3
	jp	z,l0ce1
	jp	nc,l1b6f
l1b18:
	ld	hl,l04a9
	ld	b,0
	add	hl,bc
	add	hl,bc
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	pop	de
	ld	hl,($$ARG+4)
	push	bc
	ret
l1b28:
	call	l2a20
l1b2b:
	call	l28f4
	pop	hl
	ld	($$ARG+2),hl
	pop	hl
	ld	($$ARG),hl
l1b36:
	pop	bc
	pop	de
	call	l28a9
l1b3b:
	call	l2a20
	ld	hl,l0495
l1b41:
	ld	a,(l0a68)
	rlca
	add	a,l
	ld	l,a
	adc	a,h
	sub	l
	ld	h,a
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	jp	(hl)
l1b4f:
	ld	a,b		; Get length
	push	af
	call	l28f4
	pop	af
	ld	($ARGLEN),a	; Set length of arg
	cp	4		; Test single precision
	jp	z,l1b36		; .. yeap
	pop	hl
	ld	($$ARG+4),hl
	jp	l1b3b
l1b64:
	call	l29f4
l1b67:
	pop	bc
	pop	de
l1b69:
	ld	hl,l049f
	jp	l1b41
l1b6f:
	pop	hl
	call	l2899
	call	l2a14
	call	l28b4
	pop	hl
	ld	($$ARG+6),hl
	pop	hl
	ld	($$ARG+4),hl
	jp	l1b69
l1b84:
	push	hl
	ex	de,hl
	call	l2a14
	pop	hl
	call	l2899
	call	l2a14
	jp	l2767
;
;
;
l1b93:
	call	get.tok		; Fetch token
	jp	z,l0cde		; .. error, we expect more
	jp	c,cnvnum	; .. get number
	call	isalph_		; Test A..Z
	jp	nc,l1c4a	; .. yeap
	cp	' '
	jp	c,l135d
	inc	a
	jp	z,l1cd3
	dec	a
	cp	0f2h		; Test unary '+'
	jp	z,l1b93		; .. skip it
	cp	0f3h		; Test unary '-'
	jp	z,l1c3c
	cp	'"'		; Test string
	jp	z,l46c8
	cp	0d5h		; .. NOT
	jp	z,l1d4f
	cp	'&'		; .. maybe number
	jp	z,ato??_	; .. yeap
	cp	0d7h		; Test ERR
	jp	nz,l1bd6	; .. nope
l1bca:
	call	get.tok		; Skip token
	ld	a,(err.num)	; Get error number
	push	hl
	call	l1dd5		; .. expand byte
	pop	hl
	ret
l1bd6:
	cp	0d6h
	jp	nz,l1be7
	call	get.tok
	push	hl
	ld	hl,(direct_2)	; Get direct mode
	call	l2c03
	pop	hl
	ret
l1be7:
	cp	0dch
	jp	nz,l1c16
	call	get.tok
	call	ilcmp
	db	'('
	cp	'#'
	jp	nz,l1c03
	call	l2072
	push	hl
	call	l5150
	pop	hl
	jp	l1c06
l1c03:
	call	l3a89
l1c06:
	call	ilcmp
	db	')'
	push	hl
	ex	de,hl
	ld	a,h
	or	l
	jp	z,_ill.func	; .. error if zero
	call	st.INT		; Save integer result
	pop	hl
	ret
l1c16:
	cp	0d2h
	jp	z,l1ddb
	cp	0dah
	jp	z,l49cb
	cp	0ddh
	jp	z,l426f
	cp	0d8h
	jp	z,l4900
	cp	85h
	jp	z,l5527
	cp	0d3h
	jp	z,l1e54
l1c34:
	call	l19fe
	call	ilcmp
	db	')'
	ret
;
; -> Got unary '-'
;
l1c3c:
	ld	d,7dh
	call	l1a05
	ld	hl,(l0abc)
	push	hl
	call	l286b
l1c48:
	pop	hl
	ret
l1c4a:
	call	var.adr		; Get address of variable
l1c4d:
	push	hl
	ex	de,hl
	ld	($$ARG+4),hl
	call	get.type	; Get type
	call	nz,l28ee	; .. not a pointer
	pop	hl
	ret
;
; Get upper case Accu from ^HL
;
toupper_:
	ld	a,(hl)
;
; Get upper case Accu
;
toupper:
	cp	'a'
	ret	c
	cp	'z'+1
	ret	nc
	and	5fh
	ret
;
; Convert ASCII [decimal,octal,hexadecimal] to binary
;
ato??:
	cp	'&'		; Test hex or octal
	jp	nz,l1428	; .. nope, get decimal
ato??_:
	ld	de,0		; Clear result
	call	get.tok
	call	toupper		; Get upper case
	cp	'O'		; Test octal
	jp	z,l1cad		; .. yeap
	cp	'H'
	jp	nz,l1cac
	ld	b,5
l1c7e:
	inc	hl
	ld	a,(hl)
	call	toupper		; Get upper case
	call	isalph_		; Test A..Z
	ex	de,hl
	jp	nc,l1c97	; .. yeap
	cp	'9'+1
	jp	nc,l1cce
	sub	'0'
	jp	c,l1cce
	jp	l1c9e
l1c97:
	cp	'F'+1
	jp	nc,l1cce
	sub	'A'-10
l1c9e:
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,hl
	or	l
	ld	l,a
	ex	de,hl
	dec	b
	jp	nz,l1c7e
	jp	l0cdb
l1cac:
	dec	hl
l1cad:
	call	get.tok
	ex	de,hl
	jp	nc,l1cce
	cp	'7'+1
	jp	nc,l0cc9
	ld	bc,l0cdb
	push	bc
	add	hl,hl
	ret	c
	add	hl,hl
	ret	c
	add	hl,hl
	ret	c
	pop	bc
	ld	b,0
	sub	'0'
	ld	c,a
	add	hl,bc
	ex	de,hl
	jp	l1cad
l1cce:
	call	st.INT		; Save integer result
	ex	de,hl
	ret
;
;
;
l1cd3:
	inc	hl
	ld	a,(hl)
	sub	81h
	cp	7
	jp	nz,l1ce8
	push	hl
	call	get.tok
	cp	'('
	pop	hl
	jp	nz,l37cc
	ld	a,7
l1ce8:
	ld	b,0
	rlca
	ld	c,a
	push	bc
	call	get.tok
	ld	a,c
	cp	5
	jp	nc,l1d0f
	call	l19fe
	call	ilcmp
	db	','
	call	vrf.str		; Verify string follows
	ex	de,hl
	ld	hl,($$ARG+4)
	ex	(sp),hl
	push	hl
	ex	de,hl
	call	l2075
	ex	de,hl
	ex	(sp),hl
	jp	l1d29
l1d0f:
	call	l1c34
	ex	(sp),hl
	ld	a,l
	cp	0ch
	jp	c,l1d20
	cp	1bh
	push	hl
	call	c,l29f4
	pop	hl
l1d20:
	ld	de,l1c48
	push	de
	ld	a,1
	ld	(l0c09),a
l1d29:
	ld	bc,l019f
;
; Jump thru table in ^BC, indexed by HL
;
j.i.bc:
	add	hl,bc		; Get table entry
	ld	c,(hl)		; Fetch address
	inc	hl
	ld	h,(hl)
	ld	l,c
	jp	(hl)		; .. jump
;
;
;
l1d32:
	dec	d
	cp	0f3h
	ret	z
	cp	'-'
	ret	z
	inc	d
	cp	'+'
	ret	z
	cp	0f2h
	ret	z
	dec	hl
	ret
l1d42:
	inc	a
	adc	a,a
	pop	bc
	and	b
	add	a,0ffh
	sbc	a,a
	call	l287f
	jp	l1d61
;
; -> Got NOT
;
l1d4f:
	ld	d,05ah
	call	l1a05
	call	_CINT		; Get integer
	ld	a,l		; .. build complement
	cpl
	ld	l,a
	ld	a,h
	cpl
	ld	h,a
	ld	($$ARG+4),hl	; .. save result
	pop	bc
l1d61:
	jp	l1a15
;
; Get type of argument
; EXIT	Z  if pointer
;	C  if integer, single precision or pointer
;	M  if integer
;	PO if single precision
;	Accu holds type-3
;
get.type:
	ld	a,($ARGLEN)	; Get length of arg
	cp	8		; Test double precision
	jp	nc,l1d71	; .. yeap
	sub	3		; .. subtract for flags
	or	a
	scf			; .. indicate result
	ret
l1d71:
	sub	3		; Fix for offset
	or	a		; .. clear flags
	ret
;
;
;
l1d75:
	ld	a,b
	push	af
	call	_CINT		; Get integer
	pop	af
	pop	de
	cp	7ah
	jp	z,l2c0d
	cp	7bh
	jp	z,l2ba8
	ld	bc,l1dd7
	push	bc		; Set return address
	cp	'F'
	jp	nz,l1d95
	ld	a,e
	or	l
	ld	l,a
	ld	a,h
	or	d
	ret
l1d95:
	cp	'P'
	jp	nz,l1da0
	ld	a,e
	and	l
	ld	l,a
	ld	a,h
	and	d
	ret
l1da0:
	cp	'<'
	jp	nz,l1dab
	ld	a,e
	xor	l
	ld	l,a
	ld	a,h
	xor	d
	ret
l1dab:
	cp	'2'
	jp	nz,l1db8
	ld	a,e
	xor	l
	cpl
	ld	l,a
	ld	a,h
	xor	d
	cpl
	ret
l1db8:
	ld	a,l
	cpl
	and	e
	cpl
	ld	l,a
	ld	a,h
	cpl
	and	d
	cpl
	ret
l1dc2:
	ld	a,l
	sub	e
	ld	l,a
	ld	a,h
	sbc	a,d
	ld	h,a
	jp	l2c03
;
; Function : LPOS(X)
;
l1dcb:
	ld	a,(colLST)	; Get printer position
	jp	l1dd4
;
; Function : POS(I)
;
l1dd1:
	ld	a,(colCON)	; Get console position
l1dd4:
	inc	a
l1dd5:
	ld	l,a		; Save byte
	xor	a
l1dd7:
	ld	h,a		; .. expand byte
	jp	st.INT		; .. and save as integer
;
;
;
l1ddb:
	call	l1dfa
	push	de
	call	l1c34
	ex	(sp),hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	hl,l2757
	push	hl
	push	de
	ld	a,($ARGLEN)	; Get length of arg
	push	af
	cp	3		; Test pointer
	call	z,l48a8
	pop	af
	ex	de,hl
	ld	hl,$$ARG+4
	ret
l1dfa:
	call	get.tok
	ld	bc,l0000
	cp	1bh
	jp	nc,l1e13
	cp	11h
	jp	c,l1e13
	call	get.tok
	ld	a,(l0a6e)
	or	a
	rla
	ld	c,a
l1e13:
	ex	de,hl
	ld	hl,l0774
	add	hl,bc
	ex	de,hl
	ret
l1e1a:
	call	l1dfa
	push	de
	call	ilcmp
	db	0f0h
	call	l22d1
	ex	(sp),hl
	ld	(hl),e
	inc	hl
	ld	(hl),d
	pop	hl
	ret
;
; Statement : DEF FN<name>[<parameter list>]=<function definition>
;             DEF<type> <range of letters>
;             DEF USR[<digit>]=<integer expr>
;
l1e2b:
	cp	0d2h
l1e2d:
	jp	z,l1e1a
	call	l1fd4
	call	l1fc6
	ex	de,hl
	ld	(hl),e
	inc	hl
	ld	(hl),d
	ex	de,hl
	ld	a,(hl)
	cp	'('
	jp	nz,_DATA	; Process DATA
	call	get.tok
l1e44:
	call	var.adr		; Get address of variable
	ld	a,(hl)
	cp	')'
	jp	z,_DATA		; Process DATA
	call	ilcmp
	db	','
	jp	l1e44
l1e54:
	call	l1fd4
	ld	a,($ARGLEN)	; Get length of arg
	or	a
	push	af
	ld	(l0abc),hl
	ex	de,hl
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ld	a,h
	or	l
	jp	z,l0cd5
	ld	a,(hl)
	cp	'('
	jp	nz,l1f1e
	call	get.tok
	ld	(l0a9d),hl
	ex	de,hl
	ld	hl,(l0abc)
	call	ilcmp
	db	'('
	xor	a
	push	af
	push	hl
	ex	de,hl
l1e81:
	ld	a,80h
	ld	(l0aa5),a
	call	var.adr		; Get address of variable
	ex	de,hl
	ex	(sp),hl
	ld	a,($ARGLEN)	; Get length of arg
	push	af
	push	de
	call	EXPR		; Get expresison
	ld	(l0abc),hl
	pop	hl
	ld	(l0a9d),hl
	pop	af
	call	l1fac
	ld	c,4
	call	tstmem		; Verify enough memory
	ld	hl,-2*4
	add	hl,sp
	ld	sp,hl
	call	l28f7
	ld	a,($ARGLEN)	; Get length of arg
	push	af
	ld	hl,(l0abc)
	ld	a,(hl)
	cp	')'
	jp	z,l1ecb
	call	ilcmp
	db	','
	push	hl
	ld	hl,(l0a9d)
	call	ilcmp
	db	','
	jp	l1e81
l1ec7:
	pop	af
	ld	(l0b4e),a
l1ecb:
	pop	af
	or	a
	jp	z,l1f0f
	ld	($ARGLEN),a	; .. save length of arg
	ld	hl,l0000
	add	hl,sp
	call	l28ee
	ld	hl,l0008
	add	hl,sp
	ld	sp,hl
	pop	de
	ld	l,3
l1ee2:
	inc	l
	dec	de
	ld	a,(de)
	or	a
	jp	m,l1ee2
	dec	de
	dec	de
	dec	de
	ld	a,($ARGLEN)	; Get length of arg
	add	a,l
	ld	b,a
	ld	a,(l0b4e)
	ld	c,a
	add	a,b
	cp	64h
	jp	nc,_ill.func	; .. overflow
	push	af
	ld	a,l
	ld	b,0
	ld	hl,l0b50
	add	hl,bc
	ld	c,a
	call	l1fc0
	ld	bc,l1ec7
	push	bc
	push	bc
	jp	l153a
l1f0f:
	ld	hl,(l0abc)
	call	get.tok
	push	hl
	ld	hl,(l0a9d)
	call	ilcmp
	db	')'
	_LD.A
l1f1e:
	push	de
	ld	(l0a9d),hl
	ld	a,(l0ae6)
	add	a,4
	push	af
	rrca
	ld	c,a
	call	tstmem		; Verify enough memory
	pop	af
	ld	c,a
	cpl
	inc	a
	ld	l,a
	ld	h,-1
	add	hl,sp
	ld	sp,hl
	push	hl
	ld	de,l0ae4
	call	l1fc0
	pop	hl
	ld	(l0ae4),hl
	ld	hl,(l0b4e)
	ld	(l0ae6),hl
	ld	b,h
	ld	c,l
	ld	hl,l0ae8
	ld	de,l0b50
	call	l1fc0
	ld	h,a
	ld	l,a
	ld	(l0b4e),hl
	ld	hl,(l0bba)
	inc	hl
	ld	(l0bba),hl
	ld	a,h
	or	l
	ld	(l0bb7),a
	ld	hl,(l0a9d)
	call	l19f7
	dec	hl
	call	get.tok
	jp	nz,l0cc9
	call	get.type	; Get type
	jp	nz,l1f88	; .. not a pointer
	ld	de,STR.arr+10*3	; Point to last record
	ld	hl,($$ARG+4)
	call	cp.r
	jp	c,l1f88		; HL < DE
	call	l46a3
	call	l4701
l1f88:
	ld	hl,(l0ae4)
	ld	d,h
	ld	e,l
	inc	hl
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	bc
	inc	bc
	inc	bc
	inc	bc
	ld	hl,l0ae4
	call	l1fc0
	ex	de,hl
	ld	sp,hl
	ld	hl,(l0bba)
	dec	hl
	ld	(l0bba),hl
	ld	a,h
	or	l
	ld	(l0bb7),a
	pop	hl
	pop	af
l1fac:
	push	hl
	and	00000111b	; Mask
	ld	hl,l048b
	ld	c,a
	ld	b,0
	add	hl,bc
	call	j.i.bc		; .. jump thru table
	pop	hl
	ret
;
; Move BC bytes ^DE -> ^HL
;
l1fbb:
	ld	a,(de)
	ld	(hl),a
	inc	hl
	inc	de
	dec	bc
l1fc0:
	ld	a,b
	or	c
	jp	nz,l1fbb
	ret
;
;
;
l1fc6:
	push	hl
	ld	hl,(dir.mode)	; Get direct mode
	inc	hl		; .. map -1 to 0
	ld	a,h
	or	l
	pop	hl
	ret	nz		; .. -1 is direct
	ld	e,12		; Illegal direct
	jp	_error
;
;
;
l1fd4:
	call	ilcmp
	db	0d3h
	ld	a,80h
	ld	(l0aa5),a
	or	(hl)
	ld	c,a
	jp	l3990
l1fe2:
	cp	7eh
	jp	nz,l0cc9
	inc	hl
	ld	a,(hl)
	inc	hl
	cp	83h
	jp	z,l4a60
	jp	l0cc9
;
; Function : INP(I)
;
l1ff2:
	call	get.byte	; Get port number
	ld	(l1ff9),a	; .. save for argue
	in	a,($-$)		; Fetch byte from port
l1ff9	equ	$-1
	jp	l1dd5
;
; Statement : OUT <port number>,<byte>
;
l1ffd:
	call	l2062
	out	($-$),a
l2001	equ	$-1
	ret
;
; Statement : WAIT <port number>,<expr>[,<expr>]
;
l2003:
	call	l2062
	push	af
	ld	e,0
	dec	hl
	call	get.tok
	jp	z,l2017
	call	ilcmp
	db	','
	call	l2075
l2017:
	pop	af
	ld	d,a
l2019:
	in	a,($-$)
l201a	equ	$-1
	xor	e
	and	d
	jp	z,l2019
	ret
	jp	l0cc9
;
; Statement : WIDTH [LPRINT] <integer expr>
;
l2024:
	cp	9eh
	jp	nz,l203a
	call	get.tok
	call	l2075
	ld	(l078f),a
	ld	e,a
	call	l2048
	ld	(l078e),a
	ret
l203a:
	call	l2075
	ld	(l0790),a
	ld	e,a
	call	l2048
	ld	(l0791),a
	ret
l2048:
	sub	0eh
	jp	nc,l2048
	add	a,1ch
	cpl
	inc	a
	add	a,e
	ret
l2053:
	call	get.tok
l2056:
	call	EXPR		; Get expresison
;
; Get word in range 0..32767 - Zero set if range 0..255
;
get.word:
	push	hl
	call	_CINT		; Get integer
	ex	de,hl
	pop	hl
	ld	a,d		; Build flag
	or	a
	ret
;
;
;
l2062:
	call	l2075
	ld	(l201a),a
	ld	(l2001),a
	call	ilcmp
	db	','
	jp	l2075
;
;
;
l2072:
	call	get.tok
l2075:
	call	EXPR		; Get expresison
;
; Get byte in range 0..255
;
get.byte:
	call	get.word	; Get it
	jp	nz,_ill.func	; .. should be a byte
	dec	hl
	call	get.tok		; .. skip token
	ld	a,e		; .. get byte
	ret
;
; Statement : LLIST [<line number>[-[<line number>]]]
;
l2084:
	ld	a,1
	ld	(iodev),a	; Set printer
;
; Statement : LIST [<line number>[-[<line number>]]]
;
l2089:
	pop	bc
	call	l0ed8
	push	bc
	call	l5d65
l2091:
	ld	hl,lffff
	ld	(dir.mode),hl	; Set direct mode
	pop	hl
	pop	de
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	ld	a,b
	or	c
	jp	z,l0d87
	call	fpact		; Test file active
	call	z,condir	; .. nope, get from console
	push	bc
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	push	bc
	ex	(sp),hl
	ex	de,hl
	call	cp.r
	pop	bc
	jp	c,l0d86		; HL < DE
	ex	(sp),hl
	push	hl
	push	bc
	ex	de,hl
	ld	(l0ab5),hl
	call	l311a
	pop	hl
	ld	a,(hl)
	cp	9
	jp	z,l20cd
	ld	a,' '
	call	putchar
l20cd:
	call	l20e6
	ld	hl,$LINE
	call	l20dc		; Print line
	call	fnl		; Give new line
	jp	l2091
;
; Print line ^HL closed by ZERO
;
l20dc:
	ld	a,(hl)
	or	a
	ret	z
	call	l42a5		; Print character, test new line
	inc	hl
	jp	l20dc
;
; Find token ???
;
l20e6:
	ld	bc,$LINE	; Init line pointer
	ld	d,255		; .. and length
	xor	a
	ld	(l0be6),a
	call	l5d65
	jp	l20f9
l20f5:
	inc	bc
	inc	hl
	dec	d
	ret	z
l20f9:
	ld	a,(hl)
	or	a
	ld	(bc),a
	ret	z
	cp	0bh
	jp	c,l2108
	cp	' '
	ld	e,a
	jp	c,l211c
l2108:
	or	a
	jp	m,l2141
	ld	e,a
	cp	'.'
	jp	z,l211c
	call	l21e2		; Test digit
	jp	nc,l211c	; .. yeap
	xor	a
	jp	l212f
l211c:
	ld	a,(l0be6)
	or	a
	jp	z,l212d
	inc	a
	jp	nz,l212d
	ld	a,' '
	ld	(bc),a
	inc	bc
	dec	d
	ret	z
l212d:
	ld	a,1
l212f:
	ld	(l0be6),a
	ld	a,e
	cp	0bh
	jp	c,l213d
	cp	' '
	jp	c,l21ed
l213d:
	ld	(bc),a
	jp	l20f5
l2141:
	inc	a
	ld	a,(hl)
	jp	nz,l214a
	inc	hl
	ld	a,(hl)
	and	7fh
l214a:
	inc	hl
	cp	0dbh
	jp	nz,l2158
	dec	bc
	dec	bc
	dec	bc
	dec	bc
	inc	d
	inc	d
	inc	d
	inc	d
l2158:
	cp	0a2h
	call	z,l2a6b
	cp	0b4h
	jp	nz,l216c
	ld	a,(hl)
	inc	hl
	cp	0f2h
	ld	a,0b4h
	jp	z,l216c
	dec	hl
l216c:
	push	hl
	push	bc
	push	de
	ld	hl,l023b-1	; Init table
	ld	b,a
	ld	c,'A'-1		; .. and key
l2175:
	inc	c
l2176:
	inc	hl
	ld	d,h
	ld	e,l
l2179:
	ld	a,(hl)
	or	a
	jp	z,l2175
	inc	hl
	jp	p,l2179
	ld	a,(hl)
	cp	b
	jp	nz,l2176
	ex	de,hl
	cp	0d2h
	jp	z,l218f
	cp	0d3h
l218f:
	ld	a,c
	pop	de
	pop	bc
	ld	e,a
	jp	nz,l21a2
	ld	a,(l0be6)
	or	a
	ld	a,0
	ld	(l0be6),a
	jp	l21b7
l21a2:
	cp	'Z'+1
	jp	nz,l21ae
	xor	a
	ld	(l0be6),a
	jp	l21c6
l21ae:
	ld	a,(l0be6)
	or	a
	ld	a,0ffh
	ld	(l0be6),a
l21b7:
	jp	z,l21c2
	ld	a,' '
	ld	(bc),a
	inc	bc
	dec	d
	jp	z,pop.a		; .. end
l21c2:
	ld	a,e
	jp	l21c9
l21c6:
	ld	a,(hl)
	inc	hl
	ld	e,a
l21c9:
	and	7fh
	ld	(bc),a
	inc	bc
	dec	d
	jp	z,pop.a		; .. end
	or	e
	jp	p,l21c6
	cp	0a8h
	jp	nz,l21de
	xor	a
	ld	(l0be6),a
l21de:
	pop	hl
	jp	l20f9
;
; Test alphanumeric - Carry set says no
;
l21e2:
	call	isalph_		; Test A..Z
	ret	nc		; .. yeap
	cp	'0'		; .. test 0..9
	ret	c
	cp	'9'+1
	ccf
	ret
;
;
;
l21ed:
	dec	hl
	call	get.tok
	push	de
	push	bc
	push	af
	call	l138e
	pop	af
	ld	bc,l220c
	push	bc
	cp	0bh
	jp	z,l366f
	cp	0ch
	jp	z,l3672
	ld	hl,(l0a6e)
	jp	l3129
l220c:
	pop	bc
	pop	de
	ld	a,(l0a6c)
	ld	e,'O'
	cp	0bh
	jp	z,l221f
	cp	0ch
	ld	e,'H'
	jp	nz,l222a
l221f:
	ld	a,'&'
	ld	(bc),a
	inc	bc
	dec	d
	ret	z
	ld	a,e
	ld	(bc),a
	inc	bc
	dec	d
	ret	z
l222a:
	ld	a,(l0a6d)
	cp	4
	ld	e,0
	jp	c,l223b
	ld	e,'!'
	jp	z,l223b
	ld	e,'#'
l223b:
	ld	a,(hl)		; Get next
	cp	' '		; Test blank
	call	z,inc.hl	; .. yeap, skip it
l2241:
	ld	a,(hl)
	inc	hl
	or	a
	jp	z,l226d
	ld	(bc),a
	inc	bc
	dec	d
	ret	z
	ld	a,(l0a6d)
	cp	4
	jp	c,l2241
	dec	bc
	ld	a,(bc)
	inc	bc
	jp	nz,l225e
	cp	'.'
	jp	z,l2268
l225e:
	cp	'D'
	jp	z,l2268
	cp	'E'
	jp	nz,l2241
l2268:
	ld	e,0
	jp	l2241
l226d:
	ld	a,e
	or	a
	jp	z,l2276
	ld	(bc),a
	inc	bc
	dec	d
	ret	z
l2276:
	ld	hl,(l0a6a)
	jp	l20f9
;
; Statement : DELETE [<line number>[-[<line number>]]]
;
l227c:
	call	l0ed8
	push	bc
	call	l2435
	pop	bc
	pop	de
	push	bc
	push	bc
	call	l0ef8
	jp	nc,l2294
	ld	d,h
	ld	e,l
	ex	(sp),hl
	push	hl
	call	cp.r		; Compare HL:DE
l2294:
	jp	nc,_ill.func	; HL >= DE, error
	ld	hl,l0c45
	call	l4723
	pop	bc
	ld	hl,l0e87
	ex	(sp),hl
l22a2:
	ex	de,hl
	ld	hl,(prg.top)	; Get top
l22a6:
	ld	a,(de)		; .. unpack
	ld	(bc),a
	inc	bc
	inc	de
	call	cp.r
	jp	nz,l22a6	; Loop till HL = DE
	ld	h,b
	ld	l,c
	ld	(prg.top),hl	; .. save new top
	ret
;
; Function : PEEK(I)
;
l22b6:
	call	l22db
	call	l5d5c
	ld	a,(hl)
	jp	l1dd5
;
; Statement : POKE <address>,<byte>
;
l22c0:
	call	l22d1
	push	de
	call	l5d5c
	call	ilcmp
	db	','
	call	l2075
	pop	de
	ld	(de),a
	ret
l22d1:
	call	EXPR		; Get expresison
	push	hl
	call	l22db
	ex	de,hl
	pop	hl
	ret
l22db:
	ld	bc,_CINT	; Set return address
	push	bc
	call	get.type	; Get type
	ret	m		; .. integer
	ld	a,($$ARG+7)	; Fetch exponent
	cp	90h
	ret	nz
	call	l2845
	ret	m
	call	l29f4
	ld	bc,l9180
	ld	de,l0000
	jp	l2588
;
; Statement : RENUM [[<new number>][,[<old number>][,<increment>]]]
;
l22f9:
	ld	bc,l000a
	push	bc
	ld	d,b
	ld	e,b
	jp	z,l232f
	cp	','
	jp	z,l2311
	push	de
	call	l141d
	ld	b,d
	ld	c,e
	pop	de
	jp	z,l232f
l2311:
	call	ilcmp
	db	','
	call	l141d
	jp	z,l232f
	pop	af
	call	ilcmp
	db	','
	push	de
	call	l1428
	jp	nz,l0cc9
	ld	a,d
	or	e
	jp	z,_ill.func	; Error if zero
	ex	de,hl
	ex	(sp),hl
	ex	de,hl
l232f:
	push	bc
	call	l0ef8
	pop	de
	push	de
	push	bc
	call	l0ef8
	ld	h,b
	ld	l,c
	pop	de
	call	cp.r		; Compare HL:DE
	ex	de,hl
	jp	c,_ill.func	; HL < DE, error
	pop	de
	pop	bc
	pop	af
	push	hl
	push	de
	jp	l235b
l234b:
	add	hl,bc
	jp	c,_ill.func	; .. error on overflow
	ex	de,hl
	push	hl
	ld	hl,lfff9
	call	cp.r		; Compare HL:DE
	pop	hl
	jp	c,_ill.func	; HL < DE, error
l235b:
	push	de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	a,d
	or	e
	ex	de,hl
	pop	de
	jp	z,l236e
	ld	a,(hl)
	inc	hl
	or	(hl)
	dec	hl
	ex	de,hl
	jp	nz,l234b
l236e:
	push	bc
	call	l2391
	pop	bc
	pop	de
	pop	hl
l2375:
	push	de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	a,d
	or	e
	jp	z,l238c
	ex	de,hl
	ex	(sp),hl
	ex	de,hl
	inc	hl
	ld	(hl),e
	inc	hl
	ld	(hl),d
	ex	de,hl
	add	hl,bc
	ex	de,hl
	pop	hl
	jp	l2375
l238c:
	ld	bc,l0d86
	push	bc
	_CP
;
;
;
l2391:
	_OR
;
;
;
l2392:
	xor	a
	ld	(l0aa9),a
	ld	hl,(prg.base)	; Get base of program
	dec	hl
l239a:
	inc	hl
	ld	a,(hl)		; Get memory pointer
	inc	hl
	or	(hl)		; Test end of program
	ret	z		; .. yeap
	inc	hl
	ld	e,(hl)		; Fetch line number
	inc	hl
	ld	d,(hl)
l23a3:
	call	get.tok		; Get token
l23a6:
	or	a		; Test end of line
	jp	z,l239a		; .. yeap, get next one
	ld	c,a
	ld	a,(l0aa9)
	or	a
	ld	a,c
	jp	z,l2412
	cp	0a8h		; Test ERROR
	jp	nz,l23d4
	call	get.tok
	cp	089h		; .. GOTO
	jp	nz,l23a6
	call	get.tok
	cp	00eh
	jp	nz,l23a6
	push	de
	call	l1433
	ld	a,d
	or	e
	jp	nz,l23dd
	jp	l23fd
l23d4:
	cp	00eh
	jp	nz,l23a3
	push	de
	call	l1433
l23dd:
	push	hl
	call	l0ef8
	dec	bc
	ld	a,00dh
	jp	c,l2425
	call	cls.CON		; Clear console
	ld	hl,l2402
	push	de
	call	l4723
	pop	hl
	call	l311a
	pop	bc
	pop	hl
	push	hl
l23f8:
	push	bc
	call	l3112
l23fc:
	pop	hl
l23fd:
	pop	de
	dec	hl
l23ff:
	jp	l23a3
;
l2402:
	db	'Undefined line ',null
;
;
;
l2412:
	cp	00dh
	jp	nz,l23ff
	push	de
	call	l1433
	push	hl
	ex	de,hl
	inc	hl
	inc	hl
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	a,00eh
l2425:
	ld	hl,l23fc
	push	hl
	ld	hl,(l0a6a)
l242c:
	push	hl
	dec	hl
	ld	(hl),b
	dec	hl
	ld	(hl),c
	dec	hl
	ld	(hl),a
	pop	hl
	ret
;
;
;
l2435:
	ld	a,(l0aa9)
	or	a
	ret	z
	jp	l2392
;
; Statement : OPTION BASE n
;
l243d:
	call	ilcmp
	db	'B'
	call	ilcmp
	db	'A'
	call	ilcmp
	db	'S'
	call	ilcmp
	db	'E'
	ld	a,(l0bc7)
	or	a
	jp	nz,l0cd2
	push	hl
	ld	hl,(l0ac4)
	ex	de,hl
	ld	hl,(l0ac6)
	call	cp.r
	jp	nz,l0cd2	; HL <> DE
	pop	hl
	ld	a,(hl)
	sub	'0'
	jp	c,l0cc9
	cp	2
	jp	nc,l0cc9
	ld	(l0bc6),a
	inc	a
	ld	(l0bc7),a
	call	get.tok
	ret
;
; Print string ^HL on console
;
l2479:
	ld	a,(hl)		; Get character
	or	a
	ret	z		; .. end
	call	l2483
	inc	hl
	jp	l2479
;
; Print character in Accu on console
;
l2483:
	push	af
	jp	conout		; .. put to console
;
; Statement : RANDOMIZE [<expr>]
;
l2487:
	jp	z,l2494		; .. no argue
	call	EXPR		; Get expresison
	push	hl
	call	_CINT		; Get integer
	jp	l24b0
l2494:
	push	hl
l2495:
	ld	hl,l24b8
	call	l4723
	call	l4b0d
	pop	de
	jp	c,l4416
	push	de
	inc	hl
	ld	a,(hl)		;			**** WHY ??
	call	cnvnum		; Get number
	ld	a,(hl)
	or	a
	jp	nz,l2495
	call	_CINT		; Get integer
l24b0:
	ld	(l386a),hl
	call	l37cf
	pop	hl
	ret
;
l24b8:
	db	'Random number seed (-32768 to 32767)',null
;
l24dd:
	ld	c,29		; WHILE without WEND
	jp	l24e4
l24e2:
	ld	c,26		; FOR without NEXT
l24e4:
	ld	b,0
	ex	de,hl
	ld	hl,(dir.mode)	; Get direct mode
	ld	(direct_3),hl	; .. save
	ex	de,hl
l24ee:
	inc	b
l24ef:
	dec	hl
l24f0:
	call	get.tok
	jp	z,l2500
	cp	0a2h
	jp	z,l2515
	cp	0cfh
	jp	nz,l24f0
;
;
;
l2500:
	or	a
	jp	nz,l2515
	inc	hl
	ld	a,(hl)
	inc	hl
	or	(hl)
	ld	e,c
	jp	z,_error
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	ld	(direct_3),hl	; Set direct mode
	ex	de,hl
l2515:
	call	get.tok
	ld	a,c
	cp	1ah
	ld	a,(hl)
	jp	z,l252e
	cp	0b4h
	jp	z,l24ee
	cp	0b5h
	jp	nz,l24ef
	dec	b
	jp	nz,l24ef
	ret
l252e:
	cp	82h
	jp	z,l24ee
	cp	83h
	jp	nz,l24ef
;
;
;
l2538:
	dec	b
	ret	z
	call	get.tok
	jp	z,l2500
	ex	de,hl
	ld	hl,(dir.mode)	; Get direct mode
	push	hl		; .. save
	ld	hl,(direct_3)	; .. get new mode
	ld	(dir.mode),hl	; .. set it
	ex	de,hl
	push	bc
	call	var.adr		; Get address of variable
	pop	bc
	dec	hl
	call	get.tok
	ld	de,l2500
	jp	z,l2563
	call	ilcmp
	db	','
	dec	hl
	ld	de,l2538
l2563:
	ex	(sp),hl
	ld	(dir.mode),hl	; .. set direct mode
	pop	hl
	push	de		; .. set return address
	ret
;
;
;
l256a:
	push	af
	ld	a,(l0c09)
	ld	(l0c0a),a
	pop	af
;
;
;
l2572:
	push	af
	xor	a
	ld	(l0c09),a
	pop	af
	ret
;
;
;
l2579:
	ld	hl,l360d
l257c:
	call	l28b7
	jp	l2588
l2582:
	call	l28b7
l2585:
	call	l2874
l2588:
	ld	a,b
	or	a
	ret	z
	ld	a,($$ARG+7)
	or	a
	jp	z,l28a9
	sub	b
	jp	nc,l25a2
	cpl
	inc	a
	ex	de,hl
	call	l2899
	ex	de,hl
	call	l28a9
	pop	bc
	pop	de
l25a2:
	cp	19h
	ret	nc
	push	af
	call	l28d6
	ld	h,a
	pop	af
	call	l2662
	ld	a,h
	or	a
	ld	hl,$$ARG+4
	jp	p,l25c9
	call	l2642
	jp	nc,l2623
	inc	hl
	inc	(hl)
	jp	z,l3088
	ld	l,1
	call	l2689
	jp	l2623
l25c9:
	xor	a
	sub	b
	ld	b,a
	ld	a,(hl)
	sbc	a,e
	ld	e,a
	inc	hl
	ld	a,(hl)
	sbc	a,d
	ld	d,a
	inc	hl
	ld	a,(hl)
	sbc	a,c
	ld	c,a
l25d7:
	call	c,l264e
l25da:
	ld	l,b
	ld	h,e
	xor	a
l25dd:
	ld	b,a
	ld	a,c
	or	a
	jp	nz,l260e
	ld	c,d
	ld	d,h
	ld	h,l
	ld	l,a
	ld	a,b
	sub	8
	cp	0e0h
	jp	nz,l25dd
;
; Zero exponent of real
;
st.ZERO:
	xor	a
;
; Set exponent of number
;
st.EXP:
	ld	($$ARG+7),a	; .. store it
	ret
;
;
;
l25f4:
	ld	a,h
	or	l
	or	d
	jp	nz,l2606
	ld	a,c
l25fb:
	dec	b
	rla
	jp	nc,l25fb
	inc	b
	rra
	ld	c,a
	jp	l2611
l2606:
	dec	b
	add	hl,hl
	ld	a,d
	rla
	ld	d,a
	ld	a,c
	adc	a,a
	ld	c,a
l260e:
	jp	p,l25f4
l2611:
	ld	a,b
	ld	e,h
	ld	b,l
	or	a
	jp	z,l2623
	ld	hl,$$ARG+7
	add	a,(hl)
	ld	(hl),a
	jp	nc,st.ZERO	; .. zero number
	jp	z,st.ZERO
l2623:
	ld	a,b
l2624:
	ld	hl,$$ARG+7
	or	a
	call	m,l2635
	ld	b,(hl)
	inc	hl
	ld	a,(hl)
	and	80h
	xor	c
	ld	c,a
	jp	l28a9
l2635:
	inc	e
	ret	nz
	inc	d
	ret	nz
	inc	c
	ret	nz
	ld	c,80h
	inc	(hl)
	ret	nz
	jp	l3087
l2642:
	ld	a,(hl)
	add	a,e
	ld	e,a
	inc	hl
	ld	a,(hl)
	adc	a,d
	ld	d,a
	inc	hl
	ld	a,(hl)
	adc	a,c
	ld	c,a
	ret
l264e:
	ld	hl,l0c08
	ld	a,(hl)
	cpl
	ld	(hl),a
	xor	a
	ld	l,a
	sub	b
	ld	b,a
	ld	a,l
	sbc	a,e
	ld	e,a
	ld	a,l
	sbc	a,d
	ld	d,a
	ld	a,l
	sbc	a,c
	ld	c,a
	ret
l2662:
	ld	b,0
l2664:
	sub	8
	jp	c,l2671
	ld	b,e
	ld	e,d
	ld	d,c
	ld	c,0
	jp	l2664
l2671:
	add	a,9
	ld	l,a
	ld	a,d
	or	e
	or	b
	jp	nz,l2685
	ld	a,c
l267b:
	dec	l
	ret	z
	rra
	ld	c,a
	jp	nc,l267b
	jp	l268b
l2685:
	xor	a
	dec	l
	ret	z
	ld	a,c
l2689:
	rra
	ld	c,a
l268b:
	ld	a,d
	rra
	ld	d,a
	ld	a,e
	rra
	ld	e,a
	ld	a,b
	rra
	ld	b,a
	jp	l2685
l2697:
	db	000h,000h,000h,081h
l269b:
	db	4
	db	09ah,0f7h,019h,083h
	db	024h,063h,043h,083h
	db	075h,0cdh,08dh,084h
	db	0a9h,07fh,083h,082h
l26ac:
	db	4
	db	000h,000h,000h,081h
	db	0e2h,0b0h,04dh,083h
	db	00ah,072h,011h,083h
	db	0f4h,004h,035h,07fh
;
; Function : LOG(X)
;
l26bd:
	call	l2845
	or	a
	jp	pe,_ill.func	; .. invalid call
	call	l26d0
	ld	bc,l8031
	ld	de,l7218
	jp	l2703
l26d0:
	call	l28b4
	ld	a,80h
	ld	($$ARG+7),a
	xor	b
	push	af
	call	l2899
	ld	hl,l269b
	call	l37a7
	pop	bc
	pop	hl
	call	l2899
	ex	de,hl
	call	l28a9
	ld	hl,l26ac
	call	l37a7
	pop	bc
	pop	de
	call	l2769
	pop	af
	call	l2899
	call	l2854
	pop	bc
	pop	de
	jp	l2588
;
;
;
l2703:
	call	l2845
	ret	z
	ld	l,0
	call	l2803
	ld	a,c
	ld	(l273c),a
	ex	de,hl
	ld	(l2737),hl
	ld	bc,l0000
	ld	d,b
	ld	e,b
	ld	hl,l25da
	push	hl
	ld	hl,l2725
	push	hl
	push	hl
	ld	hl,$$ARG+4
l2725:
	ld	a,(hl)
	inc	hl
	or	a
	jp	z,l2759
	push	hl
	ex	de,hl
	ld	e,8
l272f:
	rra
	ld	d,a
	ld	a,c
	jp	nc,l273d
	push	de
	ld	de,l0000
l2737	equ	$-2
	add	hl,de
	pop	de
	adc	a,0
l273c	equ	$-1
l273d:
	rra
	ld	c,a
	ld	a,h
	rra
	ld	h,a
	ld	a,l
	rra
	ld	l,a
	ld	a,b
	rra
	ld	b,a
	and	10h
	jp	z,l2751
	ld	a,b
	or	' '
	ld	b,a
l2751:
	dec	e
	ld	a,d
	jp	nz,l272f
	ex	de,hl
l2757:
	pop	hl
	ret
l2759:
	ld	b,e
	ld	e,d
	ld	d,c
	ld	c,a
	ret
l275e:
	call	l2899
	ld	hl,l2dae
	call	l28a6
l2767:
	pop	bc
	pop	de
l2769:
	call	l2845
	jp	z,l3090
	ld	l,0ffh
	call	l2803
	inc	(hl)
	jp	z,l3067
	inc	(hl)
	jp	z,l3067
	dec	hl
	ld	a,(hl)
	ld	(l27a0),a
	dec	hl
	ld	a,(hl)
	ld	(l279c),a
	dec	hl
	ld	a,(hl)
	ld	(l2798),a
	ld	b,c
	ex	de,hl
	xor	a
	ld	c,a
	ld	d,a
	ld	e,a
	ld	(l27a3),a
l2794:
	push	hl
	push	bc
	ld	a,l
	sub	0
l2798	equ	$-1
	ld	l,a
	ld	a,h
	sbc	a,0
l279c	equ	$-1
	ld	h,a
	ld	a,b
	sbc	a,0
l27a0	equ	$-1
	ld	b,a
	ld	a,0
l27a3	equ	$-1
	sbc	a,0
	ccf
	jp	nc,l27b1
	ld	(l27a3),a
	pop	af
	pop	af
	scf
	_JP.NC
l27b1:
	pop	bc
	pop	hl
	ld	a,c
	inc	a
	dec	a
	rra
	jp	p,l27cf
	rla
	ld	a,(l27a3)
	rra
	and	0c0h
	push	af
	ld	a,b
	or	h
	or	l
	jp	z,l27ca
	ld	a,' '
l27ca:
	pop	hl
	or	h
	jp	l2624
l27cf:
	rla
	ld	a,e
	rla
	ld	e,a
	ld	a,d
	rla
	ld	d,a
	ld	a,c
	rla
	ld	c,a
	add	hl,hl
	ld	a,b
	rla
	ld	b,a
	ld	a,(l27a3)
	rla
	ld	(l27a3),a
	ld	a,c
	or	d
	or	e
	jp	nz,l2794
	push	hl
	ld	hl,$$ARG+7
	dec	(hl)
	pop	hl
	jp	nz,l2794
	jp	st.ZERO		; Set zero number
l27f6:
	ld	a,0ffh
	_LD.L
l27f9:
	xor	a
	ld	hl,l0c13
	ld	c,(hl)
	inc	hl
	xor	(hl)
	ld	b,a
	ld	l,0
l2803:
	ld	a,b
	or	a
	jp	z,l2827
	ld	a,l
	ld	hl,$$ARG+7
	xor	(hl)
	add	a,b
	ld	b,a
	rra
	xor	b
	ld	a,b
	jp	p,l2826
	add	a,80h
	ld	(hl),a
	jp	z,l2757
	call	l28d6
	ld	(hl),a
l281f:
	dec	hl
	ret
	call	l2845
	cpl
	pop	hl
l2826:
	or	a
l2827:
	pop	hl
	jp	p,st.ZERO	; Set zero number
	jp	l3067
l282e:
	call	l28b4
	ld	a,b
	or	a
	ret	z
	add	a,2
	jp	c,l3080
	ld	b,a
	call	l2588
	ld	hl,$$ARG+7
	inc	(hl)
	ret	nz
	jp	l3080
;
;
;
l2845:
	ld	a,($$ARG+7)
	or	a
	ret	z
	ld	a,($$ARG+6)
	_CP
l284e:
	cpl
l284f:
	rla
l2850:
	sbc	a,a
	ret	nz
	inc	a
	ret
l2854:
	ld	b,88h
	ld	de,l0000
l2859:
	ld	hl,$$ARG+7
	ld	c,a
	ld	(hl),b
	ld	b,0
	inc	hl
	ld	(hl),80h
	rla
	jp	l25d7
;
; Function : ABS(X)
;
l2867:
	call	l2886
	ret	p
l286b:
	call	get.type	; Get type
	jp	m,l2bf8		; .. integer
	jp	z,l0ce1		; .. pointer
l2874:
	ld	hl,$$ARG+6	; Point to MSD of mantissa
	ld	a,(hl)
	xor	MSB		; .. toggle sign
	ld	(hl),a
	ret
;
; Function : SGN(X)
;
l287c:
	call	l2886
l287f:
	ld	l,a		; Get byte result
	rla			; .. get MSB
	sbc	a,a		; .. as 0x00 or 0xFF
	ld	h,a
	jp	st.INT		; .. save result
;
;
;
l2886:
	call	get.type	; Get type
	jp	z,l0ce1		; .. pointer
	jp	p,l2845		; .. single/double precision
	ld	hl,($$ARG+4)	; Get integer
l2892:
	ld	a,h		; Test zero result
	or	l
	ret	z		; .. yeap
	ld	a,h
	jp	l284f
;
;
;
l2899:
	ex	de,hl
	ld	hl,($$ARG+4)
	ex	(sp),hl
	push	hl
	ld	hl,($$ARG+6)
	ex	(sp),hl
	push	hl
	ex	de,hl
	ret
l28a6:
	call	l28b7
l28a9:
	ex	de,hl
	ld	($$ARG+4),hl
	ld	h,b
	ld	l,c
	ld	($$ARG+6),hl
	ex	de,hl
	ret
;
;
;
l28b4:
	ld	hl,$$ARG+4
l28b7:
	ld	e,(hl)
	inc	hl
l28b9:
	ld	d,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
;
; HL=HL+1 
;
inc.hl:
	inc	hl
	ret
;
;
;
l28c0:
	ld	de,$$ARG+4
l28c3:
	ld	b,4
	jp	l28cd
l28c8:
	ex	de,hl
l28c9:
	ld	a,($ARGLEN)	; Get length of arg
	ld	b,a
l28cd:
	ld	a,(de)		; .. unpack value
	ld	(hl),a
	inc	de
	inc	hl
	dec	b
	jp	nz,l28cd
	ret
;
;
;
l28d6:
	ld	hl,$$ARG+6
	ld	a,(hl)
	rlca
	scf
	rra
	ld	(hl),a
	ccf
	rra
	inc	hl
	inc	hl
	ld	(hl),a
	ld	a,c
	rlca
	scf
	rra
	ld	c,a
	rra
	xor	(hl)
	ret
l28eb:
	ld	hl,l0c0d
l28ee:
	ld	de,l28c8
	jp	l28fa
l28f4:
	ld	hl,l0c0d
l28f7:
	ld	de,l28c9
l28fa:
	push	de
	ld	de,$$ARG+4
	call	get.type	; Get type
	ret	c		; .. single precision
	ld	de,$$ARG	; .. return double precision
	ret
;
; ENTRY	Reg BCDE hold ???
;
l2906:
	ld	a,b
	or	a
	jp	z,l2845
	ld	hl,l284e
	push	hl
	call	l2845
	ld	a,c
	ret	z
	ld	hl,$$ARG+6
	xor	(hl)
	ld	a,c
	ret	m
	call	l2920		; Compare
l291d:
	rra
	xor	c
	ret
;
; Compare BCDE : ^HL - Return 2 levels if match
;
l2920:
	inc	hl
	ld	a,b
	cp	(hl)		; Compare
	ret	nz
	dec	hl
	ld	a,c
	cp	(hl)
	ret	nz
	dec	hl
	ld	a,d
	cp	(hl)
	ret	nz
	dec	hl
	ld	a,e
	sub	(hl)
	ret	nz
	pop	hl		; .. fix stack
	pop	hl
	ret
;
;
;
l2933:
	ld	a,d
	xor	h
	ld	a,h
	jp	m,l284f
	cp	d
	jp	nz,l2940
	ld	a,l
	sub	e
	ret	z
l2940:
	jp	l2850
l2943:
	ld	hl,l0c0d
	call	l28c9
l2949:
	ld	de,l0c14
	ld	a,(de)
	or	a
	jp	z,l2845
	ld	hl,l284e
	push	hl
	call	l2845
	dec	de
	ld	a,(de)
	ld	c,a
	ret	z
	ld	hl,$$ARG+6
	xor	(hl)
	ld	a,c
	ret	m
	inc	de
	inc	hl
	ld	b,8
l2966:
	ld	a,(de)
	sub	(hl)
	jp	nz,l291d
	dec	de
	dec	hl
	dec	b
	jp	nz,l2966
	pop	bc
	ret
l2973:
	call	l2949
	jp	nz,l284e
	ret
;
; Function : CINT(X)
;
_CINT:
	call	get.type	; Get type
	ld	hl,($$ARG+4)	; .. fetch integer
	ret	m		; .. got it
	jp	z,l0ce1		; Pointer is not valid here
	jp	po,l2999	; .. single precision
	call	l28f4
	ld	hl,l3609
	call	l28ee
	call	l2c26
	call	l29fe
	jp	l299c
l2999:
	call	l2579
l299c:
	ld	a,($$ARG+6)
	or	a
	push	af
	and	7fh
	ld	($$ARG+6),a
	ld	a,($$ARG+7)
	cp	90h
	jp	nc,l0cdb
	call	l2a42
	ld	a,($$ARG+7)
	or	a
	jp	nz,l29bd
	pop	af
	ex	de,hl
	jp	l29c2
l29bd:
	pop	af
	ex	de,hl
	jp	p,l29c8
l29c2:
	ld	a,h		; Build complement
	cpl
	ld	h,a
	ld	a,l
	cpl
	ld	l,a
l29c8:
	jp	st.INT		; Save result
;
;
;
l2xxx::
	ld	hl,l0cdb
	push	hl
l29cf:
	ld	a,($$ARG+7)
	cp	90h
	jp	nc,l29e5
	call	l2a42
	ex	de,hl
l29db:
	pop	de
;
; Save integer in reg HL and set length of it
;
st.INT:
	ld	($$ARG+4),hl	; Save it
;
; Set integer type
;
tp.INT:
	ld	a,2
tp.???:
	ld	($ARGLEN),a	; Set length
	ret
;
;
;
l29e5:
	ld	bc,l9080
	ld	de,l0000
	call	l2906
	ret	nz
	ld	h,c
	ld	l,d
	jp	l29db
;
; Function : CSNG(X)
;
l29f4:
	call	get.type	; Get type
	ret	po		; .. got single precision
	jp	m,l2a11		; .. got integer
	jp	z,l0ce1		; .. invalid pointer here
l29fe:
	call	l28b4
	call	tp.SNGL		; Set single precision
	ld	a,b
	or	a
	ret	z
	call	l28d6
	ld	hl,$$ARG+3
	ld	b,(hl)
	jp	l2623
l2a11:
	ld	hl,($$ARG+4)
l2a14:
	call	tp.SNGL		; Set single precision
	ld	a,h
	ld	d,l
	ld	e,0
	ld	b,90h
	jp	l2859
;
; Function : CDBL(X)
;
l2a20:
	call	get.type	; Get type
	ret	nc		; .. got double precision
	jp	z,l0ce1		; .. pointer is not valid here
	call	m,l2a11		; .. got integer
l2a2a:
	ld	hl,0		; Clear hi end
	ld	($$ARG),hl
	ld	($$ARG+2),hl
;
; Set double precision type
;
tp.DOUB:
	ld	a,8
	_LD.BC
;
; Set single precision type
;
tp.SNGL:
	ld	a,4
	jp	tp.???
;
; Verify string pointer token follows
;
vrf.str:
	call	get.type	; Get type
	ret	z		; .. got pointer
	jp	l0ce1		; .. error
;
;
;
l2a42:
	ld	b,a
	ld	c,a
	ld	d,a
	ld	e,a
	or	a
	ret	z
	push	hl
	call	l28b4
	call	l28d6
	xor	(hl)
	ld	h,a
	call	m,l2a66
	ld	a,98h
	sub	b
	call	l2662
	ld	a,h
	rla
	call	c,l2635
	ld	b,0
	call	c,l264e
	pop	hl
	ret
l2a66:
	dec	de
	ld	a,d
	and	e
	inc	a
	ret	nz
l2a6b:
	dec	bc
	ret
;
; Function : FIX(X)
;
l2a6d:
	call	get.type	; Get type
	ret	m		; .. got integer
	call	l2845
	jp	p,l2a80
	call	l2874
	call	l2a80
	jp	l286b
;
; Function : INT(X)
;
l2a80:
	call	get.type	; Get type
	ret	m		; .. got integer
	jp	nc,l2aa6	; .. got double precision
	jp	z,l0ce1		; Pointer is invalis here
	call	l29cf
l2a8d:
	ld	hl,$$ARG+7
	ld	a,(hl)
	cp	98h
	ld	a,($$ARG+4)
	ret	nc
	ld	a,(hl)
	call	l2a42
	ld	(hl),98h
	ld	a,e
	push	af
	ld	a,c
	rla
	call	l25d7
	pop	af
	ret
l2aa6:
	ld	hl,$$ARG+7
	ld	a,(hl)
	cp	90h
	jp	nz,l2aca
	ld	c,a
	dec	hl
	ld	a,(hl)
	xor	80h
	ld	b,6
l2ab6:
	dec	hl
	or	(hl)
	dec	b
	jp	nz,l2ab6
	or	a
	ld	hl,l8000
	jp	nz,l2ac9
	call	st.INT		; .. save result
	jp	l2a20
l2ac9:
	ld	a,c
l2aca:
	or	a
	ret	z
	cp	0b8h
	ret	nc
l2acf:
	push	af
	call	l28b4
	call	l28d6
	xor	(hl)
	dec	hl
	ld	(hl),0b8h
	push	af
	dec	hl
	ld	(hl),c
	call	m,l2afa
	ld	a,($$ARG+6)
	ld	c,a
	ld	hl,$$ARG+6
	ld	a,0b8h
	sub	b
	call	l2d25
	pop	af
	call	m,l2cdd
	xor	a
	ld	(l0bff),a
	pop	af
	ret	nc
	jp	l2c91
l2afa:
	ld	hl,$$ARG
l2afd:
	ld	a,(hl)
	dec	(hl)
	or	a
	inc	hl
	jp	z,l2afd
	ret
l2b05:
	push	hl
	ld	hl,l0000
	ld	a,b
	or	c
	jp	z,l2b22
	ld	a,10h
l2b10:
	add	hl,hl
	jp	c,l3bd6
	ex	de,hl
	add	hl,hl
	ex	de,hl
	jp	nc,l2b1e
	add	hl,bc
	jp	c,l3bd6
l2b1e:
	dec	a
	jp	nz,l2b10
l2b22:
	ex	de,hl
	pop	hl
	ret
l2b25:
	ld	a,h
	rla
	sbc	a,a
	ld	b,a
	call	l2bee
	ld	a,c
	sbc	a,b
	jp	l2b34
l2b31:
	ld	a,h
	rla
	sbc	a,a
l2b34:
	ld	b,a
	push	hl
	ld	a,d
	rla
	sbc	a,a
	add	hl,de
	adc	a,b
	rrca
	xor	h
	jp	p,l29db
	push	bc
	ex	de,hl
	call	l2a14
	pop	af
	pop	hl
	call	l2899
	ex	de,hl
	call	l2c08
	jp	l304e
l2b51:
	ld	a,h
	or	l
	jp	z,st.INT	; .. save zero
	push	hl
	push	de
	call	l2be2
	push	bc
	ld	b,h
	ld	c,l
	ld	hl,l0000
	ld	a,10h
l2b63:
	add	hl,hl
	jp	c,l2b89
	ex	de,hl
	add	hl,hl
	ex	de,hl
	jp	nc,l2b71
	add	hl,bc
	jp	c,l2b89
l2b71:
	dec	a
	jp	nz,l2b63
	pop	bc
	pop	de
l2b77:
	ld	a,h
	or	a
	jp	m,l2b81
	pop	de
	ld	a,b
	jp	l2bea
l2b81:
	xor	80h
	or	l
	jp	z,l2b9a
	ex	de,hl
	_LD.BC
l2b89:
	pop	bc
	pop	hl
	call	l2a14
	pop	hl
	call	l2899
	call	l2a14
l2b95:
	pop	bc
	pop	de
	jp	l2703
l2b9a:
	ld	a,b
	or	a
	pop	bc
	jp	m,st.INT	; .. save result
	push	de
	call	l2a14
	pop	de
	jp	l2874
l2ba8:
	ld	a,h
	or	l
	jp	z,l0ccc
	call	l2be2
	push	bc
	ex	de,hl
	call	l2bee
	ld	b,h
	ld	c,l
	ld	hl,l0000
	ld	a,11h
	push	af
	or	a
	jp	l2bcb
l2bc1:
	push	af
	push	hl
	add	hl,bc
	jp	nc,l2bca
	pop	af
	scf
	_LD.A
l2bca:
	pop	hl
l2bcb:
	ld	a,e
	rla
	ld	e,a
	ld	a,d
	rla
	ld	d,a
	ld	a,l
	rla
	ld	l,a
	ld	a,h
	rla
	ld	h,a
	pop	af
	dec	a
	jp	nz,l2bc1
	ex	de,hl
	pop	bc
	push	de
	jp	l2b77
l2be2:
	ld	a,h
	xor	d
	ld	b,a
	call	l2be9
	ex	de,hl
l2be9:
	ld	a,h
l2bea:
	or	a
	jp	p,st.INT	; Save result
l2bee:
	xor	a
	ld	c,a
	sub	l		; Negate value
	ld	l,a
	ld	a,c
	sbc	a,h
	ld	h,a
	jp	st.INT		; Save result
;
l2bf8:
	ld	hl,($$ARG+4)
	call	l2bee
	ld	a,h
	xor	80h
	or	l
	ret	nz
l2c03:
	ex	de,hl
	call	tp.SNGL		; Set single type precision
	xor	a
l2c08:
	ld	b,98h
	jp	l2859
l2c0d:
	push	de
	call	l2ba8
	xor	a
	add	a,d
	rra
	ld	h,a
	ld	a,e
	rra
	ld	l,a
	call	tp.INT		; Set integer type
	pop	af
	jp	l2bea
l2c1f:
	_LD.HL
l2c20:
	inc	de
	inc	c
	ld	a,(hl)
	xor	80h
	ld	(hl),a
l2c26:
	ld	hl,l0c14
	ld	a,(hl)
	or	a
	ret	z
	ld	b,a
	dec	hl
	ld	c,(hl)
	ld	de,$$ARG+7
	ld	a,(de)
	or	a
	jp	z,l28eb
	sub	b
	jp	nc,l2c52
	cpl
	inc	a
	push	af
	ld	c,8
	inc	hl
	push	hl
l2c42:
	ld	a,(de)
	ld	b,(hl)
	ld	(hl),a
	ld	a,b
	ld	(de),a
	dec	de
	dec	hl
	dec	c
	jp	nz,l2c42
	pop	hl
	ld	b,(hl)
	dec	hl
	ld	c,(hl)
	pop	af
l2c52:
	cp	'9'
	ret	nc
	push	af
	call	l28d6
	ld	hl,l0c0c
	ld	b,a
	ld	a,0
	ld	(hl),a
	ld	(l0bff),a
	pop	af
	ld	hl,l0c13
	call	l2d25
	ld	a,b
	or	a
	jp	p,l2c86
	ld	a,(l0c0c)
	ld	(l0bff),a
	call	l2cfa
	jp	nc,l2ccb
	ex	de,hl
	inc	(hl)
	jp	z,l3088
	call	l2d51
	jp	l2ccb
l2c86:
	ld	a,9eh
	call	l2cfc
	ld	hl,l0c08
	call	c,l2d12
l2c91:
	xor	a
l2c92:
	ld	b,a
	ld	a,($$ARG+6)
	or	a
	jp	nz,l2cba
	ld	hl,l0bff
	ld	c,8
l2c9f:
	ld	d,(hl)
	ld	(hl),a
	ld	a,d
	inc	hl
	dec	c
	jp	nz,l2c9f
	ld	a,b
	sub	8
	cp	0c0h
	jp	nz,l2c92
	jp	st.ZERO		; Set zero number
l2cb2:
	dec	b
	ld	hl,l0bff
	call	l2d59
	or	a
l2cba:
	jp	p,l2cb2
	ld	a,b
	or	a
	jp	z,l2ccb
	ld	hl,$$ARG+7
	add	a,(hl)
	ld	(hl),a
	jp	nc,st.ZERO	; Set zero number
	ret	z
l2ccb:
	ld	a,(l0bff)
l2cce:
	or	a
	call	m,l2cdd
	ld	hl,l0c08
	ld	a,(hl)
	and	80h
	dec	hl
	dec	hl
	xor	(hl)
	ld	(hl),a
	ret
l2cdd:
	ld	hl,$$ARG
	ld	b,7
l2ce2:
	inc	(hl)
	ret	nz
	inc	hl
	dec	b
	jp	nz,l2ce2
	inc	(hl)
	jp	z,l3088
	dec	hl
	ld	(hl),80h
	ret
l2cf1:
	ld	de,l0c30
	ld	hl,l0c0d
	jp	l2d02
l2cfa:
	ld	a,8eh
l2cfc:
	ld	hl,l0c0d
l2cff:
	ld	de,$$ARG
l2d02:
	ld	c,7
	ld	(l2d09),a
	xor	a
l2d08:
	ld	a,(de)
l2d09:
	adc	a,(hl)
	ld	(de),a
	inc	de
	inc	hl
	dec	c
	jp	nz,l2d08
	ret
l2d12:
	ld	a,(hl)
	cpl
	ld	(hl),a
	ld	hl,l0bff
	ld	b,8
	xor	a
	ld	c,a
l2d1c:
	ld	a,c
	sbc	a,(hl)
	ld	(hl),a
	inc	hl
	dec	b
	jp	nz,l2d1c
	ret
l2d25:
	ld	(hl),c
	push	hl
l2d27:
	sub	8
	jp	c,l2d3c
	pop	hl
l2d2d:
	push	hl
	ld	de,8*256+0	;;l0800
l2d31:
	ld	c,(hl)		; .. get old
	ld	(hl),e		; .. set new
	ld	e,c
	dec	hl
	dec	d
	jp	nz,l2d31
	jp	l2d27
l2d3c:
	add	a,9
	ld	d,a
l2d3f:
	xor	a
	pop	hl
	dec	d
	ret	z
l2d43:
	push	hl
	ld	e,8
l2d46:
	ld	a,(hl)
	rra
	ld	(hl),a
	dec	hl
	dec	e
	jp	nz,l2d46
	jp	l2d3f
l2d51:
	ld	hl,$$ARG+6
	ld	d,1
	jp	l2d43
l2d59:
	ld	c,8
l2d5b:
	ld	a,(hl)
	rla
	ld	(hl),a
	inc	hl
	dec	c
	jp	nz,l2d5b
	ret
l2d64:
	call	l2845
	ret	z
	ld	a,(l0c14)
	or	a
	jp	z,st.ZERO	; Set zero number
	call	l27f9
	call	l2e9d
	ld	(hl),c
	inc	de
	ld	b,7
l2d79:
	ld	a,(de)
	inc	de
	or	a
	push	de
	jp	z,l2d99
	ld	c,8
l2d82:
	push	bc
	rra
	ld	b,a
	call	c,l2cfa
	call	l2d51
	ld	a,b
	pop	bc
	dec	c
	jp	nz,l2d82
l2d91:
	pop	de
	dec	b
	jp	nz,l2d79
	jp	l2c91
l2d99:
	ld	hl,$$ARG+6
	call	l2d2d
	jp	l2d91
l2da2:
	db	0cdh,0cch,0cch,0cch,0cch,0cch,04ch,07dh
	db	000h,000h,000h,000h
l2dae:
	db	000h,000h,020h,084h
l2db2:
	ld	a,($$ARG+7)
	cp	'A'
	jp	nc,l2dc6
	ld	de,l2da2
	ld	hl,l0c0d
	call	l28c9
	jp	l2d64
l2dc6:
	ld	a,($$ARG+6)
	or	a
	jp	p,l2dd6
	and	7fh
	ld	($$ARG+6),a
	ld	hl,l2874
	push	hl
l2dd6:
	call	l2e0e
	ld	de,$$ARG
	ld	hl,l0c0d
	call	l28c9
	call	l2e0e
	call	l2c26
	ld	de,$$ARG
	ld	hl,l0c0d
	call	l28c9
	ld	a,0fh
l2df3:
	push	af
	call	l2e16
	call	l2e22
	call	l2c26
	ld	hl,l0c13
	call	l2e33
	pop	af
	dec	a
	jp	nz,l2df3
	call	l2e0e
	call	l2e0e
l2e0e:
	ld	hl,$$ARG+7
	dec	(hl)
	ret	nz
	jp	st.ZERO		; Set zero number
l2e16:
	ld	hl,l0c14
	ld	a,4
l2e1b:
	dec	(hl)
	ret	z
	dec	a
	jp	nz,l2e1b
	ret
l2e22:
	pop	de
	ld	a,4
	ld	hl,l0c0d
l2e28:
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	push	bc
	dec	a
	jp	nz,l2e28
	push	de
	ret
l2e33:
	pop	de
	ld	a,4
	ld	hl,l0c14
l2e39:
	pop	bc
	ld	(hl),b
	dec	hl
	ld	(hl),c
	dec	hl
	dec	a
	jp	nz,l2e39
	push	de
	ret
l2e44:
	ld	a,(l0c14)
	or	a
	jp	z,l3094
	ld	a,($$ARG+7)
	or	a
	jp	z,st.ZERO	; Set zero number
	call	l27f6
	inc	(hl)
	inc	(hl)
	jp	z,l3088
	call	l2e9d
	ld	hl,l0c37
	ld	(hl),c
	ld	b,c
l2e62:
	ld	a,9eh
	call	l2cf1
	ld	a,(de)
	sbc	a,c
	ccf
	jp	c,l2e74
	ld	a,8eh
	call	l2cf1
	xor	a
	_JP.C
l2e74:
	ld	(de),a
	inc	b
	ld	a,($$ARG+6)
	inc	a
	dec	a
	rra
	jp	m,l2cce
	rla
	ld	hl,$$ARG
	ld	c,7
	call	l2d5b
	ld	hl,l0c30
	call	l2d59
	ld	a,b
	or	a
	jp	nz,l2e62
	ld	hl,$$ARG+7
	dec	(hl)
	jp	nz,l2e62
	jp	st.ZERO		; Set zero number
l2e9d:
	ld	a,c
	ld	(l0c13),a
	dec	hl
	ld	de,l0c36
	ld	bc,7*256+0	;;l0700
l2ea8:
	ld	a,(hl)
	ld	(de),a		; Unpack
	ld	(hl),c		; .. and clear
	dec	de
	dec	hl
	dec	b
	jp	nz,l2ea8
	ret
l2eb2:
	call	l28f4
	ex	de,hl
	dec	hl
	ld	a,(hl)
	or	a
	ret	z
	add	a,2
	jp	c,l3088
	ld	(hl),a
	push	hl
	call	l2c26
	pop	hl
	inc	(hl)
	ret	nz
	jp	l3088
;
; Convert ^HL to double number
;
cnvdoub:
	call	st.ZERO		; .. set zero number
	call	tp.DOUB		; Set type
	_OR
;
; Convert ^HL to number
;
cnvnum:
	xor	a
	ld	bc,l256a
	push	bc		; Set return address
	push	af		; Save entry code
	ld	a,1
	ld	(l0c09),a	; Init counter
	pop	af
	ex	de,hl
	ld	bc,l00ff
	ld	h,b
	ld	l,b
	call	z,st.INT	; Set integer if not double
	ex	de,hl
	ld	a,(hl)		; Get character
	cp	'&'		; Test hex
	jp	z,ato??_	; .. yeap, get hex number
	cp	'-'		; Check sign
	push	af
	jp	z,l2ef9		; .. yeap
	cp	'+'		; Test default
	jp	z,l2ef9
	dec	hl		; .. fix for 1st digit
l2ef9:
	call	get.tok
	jp	c,l2fe0
	cp	'.'		; Test decimal point
	jp	z,l2f86
	cp	'e'		; .. or exponent
	jp	z,l2f0b
	cp	'E'
l2f0b:
	jp	nz,l2f35
	push	hl
	call	get.tok
	cp	'l'
	jp	z,l2f23
	cp	'L'
	jp	z,l2f23
	cp	'q'
	jp	z,l2f23
	cp	'Q'
l2f23:
	pop	hl
	jp	z,l2f34
	ld	a,($ARGLEN)	; Get length
	cp	8		; Test double precision
	jp	z,l2f4e		; .. yeap
	ld	a,0
	jp	l2f4e
l2f34:
	ld	a,(hl)		; Get next
l2f35:
	cp	'%'		; Test integer value
	jp	z,l2f93
	cp	'#'		; .. double precision
	jp	z,l2fa4
	cp	'!'		; .. single precision
	jp	z,l2fa5
	cp	'd'		; .. double exponential
	jp	z,l2f4e
	cp	'D'
	jp	nz,l2f65
l2f4e:
	or	a
	call	l2fae
	call	get.tok
	call	l1d32
l2f58:
	call	get.tok
	jp	c,l3053
	inc	d
	jp	nz,l2f65
	xor	a
	sub	e
	ld	e,a
l2f65:
	push	hl
	ld	a,e
	sub	b
	ld	e,a
l2f69:
	call	p,l2fbd
	call	m,l2fcd
	jp	nz,l2f69
	pop	hl
	pop	af
	push	hl
	call	z,l286b
	pop	hl
	call	get.type	; Get type
	ret	pe		; .. not single precision
	push	hl
	ld	hl,l2757
	push	hl
	call	l29e5
	ret
l2f86:
	call	get.type	; Get type
	inc	c
	jp	nz,l2f65
	call	c,l2fae		; .. not double
	jp	l2ef9
;
; -> Integer value (%)
;
l2f93::
	call	get.tok
	pop	af
	push	hl
	ld	hl,l2757
	push	hl
	ld	hl,_CINT	; Set return address
	push	hl
	push	af
	jp	l2f65
;
; -> Double precision value (#)
;
l2fa4:
	or	a
;
; -> Single precision value (!)
;
l2fa5:
	call	l2fae
	call	get.tok
	jp	l2f65
l2fae:
	push	hl
	push	de
	push	bc
	push	af
	call	z,l29f4
	pop	af
	call	nz,l2a20
	pop	bc
	pop	de
	pop	hl
	ret
l2fbd:
	ret	z
l2fbe:
	push	af
	call	get.type	; Get type
	push	af
	call	po,l282e	; .. got single
	pop	af
	call	pe,l2eb2	; .. got double
	pop	af
l2fcb:
	dec	a
	ret
l2fcd:
	push	de
	push	hl
	push	af
	call	get.type	; Get type
	push	af
	call	po,l275e	; .. got single
	pop	af
	call	pe,l2db2	; .. got double
	pop	af
	pop	hl
	pop	de
	inc	a
	ret
l2fe0:
	push	de
	ld	a,b
	adc	a,c
	ld	b,a
	push	bc
	push	hl
	ld	a,(hl)
	sub	'0'
	push	af
	call	get.type	; Get type
	jp	p,l3019		; .. not integer
	ld	hl,($$ARG+4)
	ld	de,0ccdh	;;l0ccd
	call	cp.r
	jp	nc,l3015	; HL >= DE
	ld	d,h
	ld	e,l
	add	hl,hl
	add	hl,hl
	add	hl,de
	add	hl,hl
	pop	af
	ld	c,a
	add	hl,bc
	ld	a,h
	or	a
	jp	m,l3013
	ld	($$ARG+4),hl
l300d:
	pop	hl
	pop	bc
	pop	de
	jp	l2ef9
l3013:
	ld	a,c
	push	af
l3015:
	call	l2a11
	scf
l3019:
	jp	nc,l3035	; .. got double
	ld	bc,l9474
	ld	de,02400h	;;l2400
	call	l2906
	jp	p,l3032
	call	l282e
	pop	af
	call	l3048
	jp	l300d
l3032:
	call	l2a2a
l3035:
	call	l2eb2
	call	l28f4
	pop	af
	call	l2854
	call	l2a2a
	call	l2c26
	jp	l300d
l3048:
	call	l2899
	call	l2854
l304e:
	pop	bc
	pop	de
	jp	l2588
l3053:
	ld	a,e
	cp	9+1
	jp	nc,l3062
	rlca
	rlca
	add	a,e
	rlca
	add	a,(hl)
	sub	'0'
	ld	e,a
	_JP.M
l3062:
	ld	e,07fh
	jp	l2f58
l3067:
	push	hl
	ld	hl,$$ARG+6
	call	get.type	; Get type
	jp	po,l3077	; .. got single
	ld	a,(l0c13)
	jp	l3078
l3077:
	ld	a,c
l3078:
	xor	(hl)
	rla
	pop	hl
	jp	l309e
l307e:
	pop	af
	pop	af
l3080:
	ld	a,($$ARG+6)
	rla
	jp	l309e
l3087:
	pop	af
l3088:
	ld	a,(l0c08)
	cpl
	rla
	jp	l309e
l3090:
	ld	a,c
	jp	l3097
l3094:
	ld	a,(l0c13)
l3097:
	rla
	ld	hl,l0562
	ld	(l079c),hl
l309e:
	push	hl
	push	bc
	push	de
	push	af
	push	af
	ld	hl,(l0ab9)
	ld	a,h
	or	l
	jp	nz,l30cb
	ld	hl,l0c09
	ld	a,(hl)
	or	a
	jp	z,l30b8
	dec	a
	jp	nz,l30cb
	inc	(hl)
l30b8:
	ld	hl,(l079c)
	call	l2479
	ld	(colCON),a	; .. set column
	ld	a,cr
	call	l2483
	ld	a,lf
	call	l2483
l30cb:
	pop	af
	ld	hl,$$ARG+4
	ld	de,l310a
	jp	nc,l30d8
	ld	de,l310e
l30d8:
	call	l28c3
	call	get.type	; Get type
	jp	c,l30ea		; .. not double
	ld	hl,$$ARG
	ld	de,l310e
	call	l28c3
l30ea:
	ld	hl,(l0ab9)
	ld	a,h
	or	l
	ld	hl,(l079c)
	ld	de,l0509
	ex	de,hl
	ld	(l079c),hl
	jp	z,l3105
	call	cp.r
	jp	z,l0cdb		; HL = DE
	jp	l0ccc
l3105:
	pop	af
	pop	de
	pop	bc
	pop	hl
	ret
;
l310a:
	db	0ffh,0ffh,07fh,0ffh
l310e:
	db	0ffh,0ffh,0ffh,0ffh
;
;
;
l3112:
	push	hl
	ld	hl,l0c40
	call	l4723
	pop	hl
;
;
;
l311a:
	ld	bc,l4722
	push	bc
	call	st.INT		; Save result
	xor	a
	call	l31b2		; Init string
	or	(hl)
	jp	l3146
l3129:
	xor	a
l312a:
	call	l31b2		; Init string
	and	00001000b	; Test bit
	jp	z,l3134
	ld	(hl),'+'
l3134:
	ex	de,hl
	call	l2886
	ex	de,hl
	jp	p,l3146
	ld	(hl),'-'
	push	bc
	push	hl
	call	l286b
	pop	hl
	pop	bc
	or	h
l3146:
	inc	hl
	ld	(hl),'0'
	ld	a,(l0a9d)
	ld	d,a
	rla
	ld	a,($ARGLEN)	; Get length
	jp	c,l32d7
	jp	z,l32cf
	cp	4		; Test integer or pointer
	jp	nc,l31bb	; .. nope
	ld	bc,l0000
	call	l35ba
l3162:
	ld	hl,l0c16
	ld	b,(hl)
	ld	c,' '
	ld	a,(l0a9d)
	ld	e,a
	and	' '
	jp	z,l317f
	ld	a,b
	cp	c
	ld	c,'*'
	jp	nz,l317f
	ld	a,e
	and	4
	jp	nz,l317f
	ld	b,c
l317f:
	ld	(hl),c
	call	get.tok
	jp	z,l319f
	cp	'E'
	jp	z,l319f
	cp	'D'
	jp	z,l319f
	cp	'0'
	jp	z,l317f
	cp	','
	jp	z,l317f
	cp	'.'
	jp	nz,l31a2
l319f:
	dec	hl
	ld	(hl),'0'
l31a2:
	ld	a,e
	and	10h
	jp	z,l31ab
	dec	hl
	ld	(hl),'$'
l31ab:
	ld	a,e
	and	4
	ret	nz
	dec	hl
	ld	(hl),b
	ret
;
; Init string
;
l31b2:
	ld	(l0a9d),a
	ld	hl,l0c16
	ld	(hl),' '	; Init blank
	ret
;
;
;
l31bb:
	call	l2899
	ex	de,hl
	ld	hl,($$ARG)
	push	hl
	ld	hl,($$ARG+2)
	push	hl
	ex	de,hl
	push	af
	xor	a
	ld	(l0c0b),a
	pop	af
	push	af
	call	l3266
	ld	b,'E'
	ld	c,0
l31d6:
	push	hl
	ld	a,(hl)
l31d8:
	cp	b
	jp	z,l3207
	cp	'9'+1
	jp	nc,l31e7
	cp	'0'
	jp	c,l31e7
	inc	c
l31e7:
	inc	hl
	ld	a,(hl)
	or	a
	jp	nz,l31d8
	ld	a,'D'
	cp	b
	ld	b,a
	pop	hl
	ld	c,0
	jp	nz,l31d6
l31f7:
	pop	af
	pop	bc
	pop	de
	ex	de,hl
	ld	($$ARG),hl
	ld	h,b
	ld	l,c
	ld	($$ARG+2),hl
	ex	de,hl
	pop	bc
	pop	de
	ret
l3207:
	push	bc
	ld	b,0
	inc	hl
	ld	a,(hl)
l320c:
	cp	'+'
	jp	z,l324e
	cp	'-'
	jp	z,l3225
	sub	'0'
	ld	c,a
	ld	a,b
	add	a,a
	add	a,a
	add	a,b
	add	a,a
l321e:
	add	a,c
	ld	b,a
	cp	10h
	jp	nc,l324e
l3225:
	inc	hl
	ld	a,(hl)
	or	a
	jp	nz,l320c
	ld	h,b
	pop	bc
	ld	a,b
	cp	'E'
	jp	nz,l3243
	ld	a,c
	add	a,h
	cp	9
	pop	hl
	jp	nc,l31f7
l323b:
	ld	a,80h
	ld	(l0c0b),a
	jp	l3253
l3243:
	ld	a,h
	add	a,c
	cp	12h
	pop	hl
	jp	nc,l31f7
	jp	l323b
l324e:
	pop	bc
	pop	hl
	jp	l31f7
l3253:
	pop	af
	pop	bc
	pop	de
	ex	de,hl
	ld	($$ARG),hl
	ld	h,b
	ld	l,c
	ld	($$ARG+2),hl
	ex	de,hl
	pop	bc
	pop	de
	call	l28a9
	inc	hl
l3266:
	cp	5
	push	hl
	sbc	a,0
	rla
	ld	d,a
	inc	d
	call	l345c
	ld	bc,3*256+0	;;l0300
	push	af
	ld	a,(l0c0b)
	or	a
	jp	p,l3281
	pop	af
	add	a,d
	jp	l328b
l3281:
	pop	af
	add	a,d
	jp	m,l328f
	inc	d
	cp	d
	jp	nc,l328f
l328b:
	inc	a
	ld	b,a
	ld	a,2
l328f:
	sub	2
	pop	hl
	push	af
	call	l34fb
	ld	(hl),'0'
	call	z,inc.hl	; .. advance pointer
	call	l3522
l329e:
	dec	hl
	ld	a,(hl)
	cp	'0'
	jp	z,l329e
	cp	'.'		; Test dot
	call	nz,inc.hl	; .. skip if not
	pop	af
	jp	z,l32d0		; .. zero result
l32ae:
	push	af
	call	get.type	; Get type
	ld	a,'"'
	adc	a,a
	ld	(hl),a		; Save " or #
	inc	hl
	pop	af
	ld	(hl),'+'	; Set default sign
	jp	p,l32c1
	ld	(hl),'-'	; .. change it
	cpl
	inc	a
l32c1:
	ld	b,'0'-1		; Init count
l32c3:
	inc	b		; Count tens
	sub	10		; .. make < 0
	jp	nc,l32c3
	add	a,'9'+1		; .. get units
	inc	hl
	ld	(hl),b		; .. save as byte
	inc	hl
	ld	(hl),a
l32cf:
	inc	hl
l32d0:
	ld	(hl),null	; Close string
	ex	de,hl
	ld	hl,l0c16	; Return pointer
	ret
;
;
;
l32d7:
	inc	hl
	push	bc
	cp	4
	ld	a,d
	jp	nc,l3351
	rra
	jp	c,l33ee
	ld	bc,0603h	;;l0603
	call	l34f3
	pop	de
	ld	a,d
	sub	5
	call	p,l34cf
	call	l35ba
l32f3:
	ld	a,e
	or	a
	call	z,l281f
	dec	a
	call	p,l34cf
l32fc:
	push	hl
	call	l3162
	pop	hl
	jp	z,l3306
	ld	(hl),b
	inc	hl
l3306:
	ld	(hl),0
	ld	hl,l0c15
l330b:
	inc	hl
l330c:
	ld	a,(l0abc)
	sub	l
	sub	d
	ret	z
	ld	a,(hl)
	cp	' '
	jp	z,l330b
	cp	'*'
	jp	z,l330b
	dec	hl
l331e:
	push	hl
l331f:
	push	af
	ld	bc,l331f
	push	bc
	call	get.tok
	cp	'-'
	ret	z
	cp	'+'
	ret	z
	cp	'$'
	ret	z
	pop	bc
	cp	'0'
	jp	nz,l3349
	inc	hl
	call	get.tok
	jp	nc,l3349
	dec	hl
	_LD.BC
l333f:
	dec	hl
	ld	(hl),a
	pop	af
	jp	z,l333f
	pop	bc
	jp	l330c
l3349:
	pop	af
	jp	z,l3349
	pop	hl
	ld	(hl),'%'
	ret
l3351:
	push	hl
	rra
	jp	c,l33f5
	jp	z,l336d
	ld	de,l3611
	call	l2943
	ld	d,10h
	jp	m,l337b
l3364:
	pop	hl
	pop	bc
	call	l3129		; .. get number
	dec	hl
	ld	(hl),'%'	; .. save type
	ret
l336d:
	ld	bc,lb60e
	ld	de,l1bca
	call	l2906
	jp	p,l3364
	ld	d,6
l337b:
	call	l2845
	call	nz,l345c
	pop	hl
	pop	bc
	jp	m,l33a0
	push	bc
	ld	e,a
	ld	a,b
	sub	d
	sub	e
	call	p,l34cf
	call	l34e6
	call	l3522
	or	e
	call	nz,l34df
	or	e
	call	nz,l350e
	pop	de
	jp	l32f3
l33a0:
	ld	e,a
	ld	a,c
	or	a
	call	nz,l2fcb
	add	a,e
	jp	m,l33ab
	xor	a
l33ab:
	push	bc
	push	af
l33ad:
	call	m,l2fcd
	jp	m,l33ad
	pop	bc
	ld	a,e
	sub	b
	pop	bc
	ld	e,a
	add	a,d
	ld	a,b
	jp	m,l33c9
	sub	d
	sub	e
	call	p,l34cf
	push	bc
	call	l34e6
	jp	l33da
l33c9:
	call	l34cf
	ld	a,c
	call	l3512
	ld	c,a
	xor	a
	sub	d
	sub	e
	call	l34cf
	push	bc
	ld	b,a
	ld	c,a
l33da:
	call	l3522
	pop	bc
	or	c
	jp	nz,l33e5
	ld	hl,(l0abc)
l33e5:
	add	a,e
	dec	a
	call	p,l34cf
	ld	d,b
	jp	l32fc
l33ee:
	push	hl
	push	de
	call	l2a11
	pop	de
	xor	a
l33f5:
	jp	z,l33fb
	ld	e,10h
	_LD.BC
l33fb:
	ld	e,6
	call	l2845
	scf
	call	nz,l345c
	pop	hl
	pop	bc
	push	af
	ld	a,c
	or	a
	push	af
	call	nz,l2fcb
	add	a,b
	ld	c,a
	ld	a,d
	and	4
	cp	1
	sbc	a,a
	ld	d,a
	add	a,c
	ld	c,a
	sub	e
	push	af
	push	bc
l341b:
	call	m,l2fcd
l341e:
	jp	m,l341b
	pop	bc
	pop	af
	push	bc
	push	af
	jp	m,l3429
	xor	a
l3429:
	cpl
	inc	a
	add	a,b
	inc	a
	add	a,d
	ld	b,a
	ld	c,0
	call	l3522
	pop	af
	call	p,l34d8
	call	l350e
	pop	bc
	pop	af
	jp	nz,l344c
	call	l281f
	ld	a,(hl)
	cp	'.'		; Test dot
	call	nz,inc.hl	; .. skip if not
	ld	(l0abc),hl
l344c:
	pop	af
	jp	c,l3453
	add	a,e
	sub	b
	sub	d
l3453:
	push	bc
	call	l32ae
	ex	de,hl
	pop	de
	jp	l32fc
;
;
;
l345c:
	push	de
	xor	a
	push	af
	call	get.type	; Get type
	jp	po,l3480	; .. got single
l3465:
	ld	a,($$ARG+7)
	cp	91h
	jp	nc,l3480
	ld	de,l35f1
	ld	hl,l0c0d
	call	l28c9
	call	l2d64
	pop	af
	sub	0ah
	push	af
	jp	l3465
l3480:
	call	l34b2
l3483:
	call	get.type	; Get type
	jp	pe,l3495	; .. not single
	ld	bc,l9143
	ld	de,04ff9h
	call	l2906
	jp	l349b
l3495:
	ld	de,l35f9
	call	l2943
l349b:
	jp	p,l34ae
	pop	af
	call	l2fbe
	push	af
	jp	l3483
l34a6:
	pop	af
	call	l2fcd
	push	af
	call	l34b2
l34ae:
	pop	af
	or	a
	pop	de
	ret
l34b2:
	call	get.type	; Get type
	jp	pe,l34c4	; .. not single
	ld	bc,l9474
	ld	de,l23f8
	call	l2906
	jp	l34ca
l34c4:
	ld	de,l3601
	call	l2943
l34ca:
	pop	hl
	jp	p,l34a6
	jp	(hl)
l34cf:
	or	a
l34d0:
	ret	z
	dec	a
	ld	(hl),'0'
	inc	hl
	jp	l34d0
l34d8:
	jp	nz,l34df
l34db:
	ret	z
	call	l350e
l34df:
	ld	(hl),'0'
	inc	hl
	dec	a
	jp	l34db
l34e6:
	ld	a,e
	add	a,d
	inc	a
	ld	b,a
	inc	a
l34eb:
	sub	3
	jp	nc,l34eb
	add	a,5
	ld	c,a
l34f3:
	ld	a,(l0a9d)
	and	'@'
	ret	nz
	ld	c,a
	ret
l34fb:
	dec	b
	jp	p,l350f
	ld	(l0abc),hl
	ld	(hl),'.'
l3504:
	inc	hl
	ld	(hl),'0'
	inc	b
	jp	nz,l3504
	inc	hl
	ld	c,b
	ret
l350e:
	dec	b
l350f:
	jp	nz,l351a
l3512:
	ld	(hl),'.'
	ld	(l0abc),hl
	inc	hl
	ld	c,b
	ret
l351a:
	dec	c
	ret	nz
	ld	(hl),','
l351e:
	inc	hl
	ld	c,3
	ret
l3522:
	push	de
	call	get.type	; Get type
	jp	po,l3571	; .. got single
	push	bc
	push	hl
	call	l28f4
	ld	hl,l3609
	call	l28ee
	call	l2c26
	xor	a
	call	l2acf
	pop	hl
	pop	bc
	ld	de,l3619
	ld	a,0ah
l3542:
	call	l350e
	push	bc
	push	af
	push	hl
	push	de
	ld	b,'0'-1
l354b:
	inc	b
	pop	hl
	push	hl
	ld	a,9eh
	call	l2cff
	jp	nc,l354b
	pop	hl
	ld	a,8eh
	call	l2cff
	ex	de,hl
	pop	hl
	ld	(hl),b
	inc	hl
	pop	af
	pop	bc
	dec	a
	jp	nz,l3542
	push	bc
	push	hl
	ld	hl,$$ARG
	call	l28a6
	jp	l357e
l3571:
	push	bc
	push	hl
	call	l2579
	ld	a,1
	call	l2a42
	call	l28a9
l357e:
	pop	hl
	pop	bc
	xor	a
	ld	de,l365f
l3584:
	ccf
	call	l350e
	push	bc
	push	af
	push	hl
	push	de
	call	l28b4
	pop	hl
	ld	b,'0'-1
l3592:
	inc	b
	ld	a,e
	sub	(hl)
	ld	e,a
	inc	hl
	ld	a,d
	sbc	a,(hl)
	ld	d,a
	inc	hl
	ld	a,c
	sbc	a,(hl)
	ld	c,a
	dec	hl
	dec	hl
	jp	nc,l3592
	call	l2642
	inc	hl
	call	l28a9
	ex	de,hl
	pop	hl
	ld	(hl),b
	inc	hl
	pop	af
	pop	bc
	jp	c,l3584
	inc	de
	inc	de
	ld	a,4
	jp	l35c0
l35ba:
	push	de
	ld	de,l3665
	ld	a,5
l35c0:
	call	l350e
	push	bc
	push	af
	push	hl
	ex	de,hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	push	bc
	inc	hl
	ex	(sp),hl
	ex	de,hl
	ld	hl,($$ARG+4)
	ld	b,'0'-1
l35d3:
	inc	b
	ld	a,l
	sub	e
	ld	l,a
	ld	a,h
	sbc	a,d
	ld	h,a
	jp	nc,l35d3
	add	hl,de
	ld	($$ARG+4),hl
	pop	de
	pop	hl
	ld	(hl),b
	inc	hl
	pop	af
	pop	bc
	dec	a
	jp	nz,l35c0
	call	l350e
	ld	(hl),a
	pop	de
	ret
;
l35f1::
	db	000h,000h,000h,000h,0f9h,002h,015h,0a2h
l35f9:
	db	0e1h,0ffh,09fh,031h,0a9h,05fh,063h,0b2h
l3601:
	db	0feh,0ffh,003h,0bfh,0c9h,01bh,00eh,0b6h
l3609:
	db	000h,000h,000h,000h
l360d:
	db	000h,000h,000h,080h
l3611:
	db	000h,000h,004h,0bfh,0c9h,01bh,00eh,0b6h
l3619:
	db	000h,080h,0c6h,0a4h,07eh,08dh,003h,000h
	db	040h,07ah,010h,0f3h,05ah,000h,000h,0a0h
	db	072h,04eh,018h,009h,000h,000h,010h,0a5h
	db	0d4h,0e8h,000h,000h,000h,0e8h,076h,048h
	db	017h,000h,000h,000h,0e4h,00bh,054h,002h
	db	000h,000h,000h,0cah,09ah,03bh,000h,000h
	db	000h,000h,0e1h,0f5h,005h,000h,000h,000h
	db	080h,096h,098h,000h,000h,000h,000h,040h
	db	042h,00fh,000h,000h,000h,000h
l365f:
	db	0a0h,86h,01h,10h,27h,00h
l3665:
	dw	10000
	dw	 1000
	dw	  100
	dw	   10
	dw	    1
;
;
;
l366f:
	xor	a
	ld	b,a
	_JP.NZ
l3672:
	ld	b,1
	push	bc
	call	l22db
	pop	bc
	ld	de,l0c15
	push	de
	xor	a
	ld	(de),a
	dec	b
	inc	b
	ld	c,6
	jp	z,l368e
	ld	c,4
l3688:
	add	hl,hl
	adc	a,a
l368a:
	add	hl,hl
	adc	a,a
	add	hl,hl
	adc	a,a
l368e:
	add	hl,hl
	adc	a,a
	or	a
	jp	nz,l369f
	ld	a,c
	dec	a
	jp	z,l369f
	ld	a,(de)
	or	a
	jp	z,l36ab
	xor	a
l369f:
	add	a,'0'
	cp	'9'+1
	jp	c,l36a8
	add	a,'A'-'9'-1
l36a8:
	ld	(de),a
	inc	de
	ld	(de),a
l36ab:
	xor	a
	dec	c
	jp	z,l36b8
	dec	b
	inc	b
	jp	z,l368a
	jp	l3688
l36b8:
	ld	(de),a
	pop	hl
	ret
l36bb:
	ld	hl,l2874
	ex	(sp),hl
	jp	(hl)
;
; Function : SQR(X)
;
l36c0:
	call	l2899
	ld	hl,l360d
	call	l28a6
	jp	l36cf
l36cc:
	call	l29f4
l36cf:
	pop	bc
	pop	de
	ld	hl,l2572
	push	hl
	ld	a,1
	ld	(l0c09),a
	call	l2845
	ld	a,b
	jp	z,l372b
	jp	p,l36e8
	or	a
	jp	z,l3097
l36e8:
	or	a
	jp	z,st.EXP	; .. zero exponent
	push	de
	push	bc
	ld	a,c
	or	7fh
	call	l28b4
	jp	p,l3713
	push	af
	ld	a,($$ARG+7)
	cp	99h
	jp	c,l3704
	pop	af
	jp	l3713
l3704:
	pop	af
	push	de
	push	bc
	call	l2a8d
	pop	bc
	pop	de
	push	af
	call	l2906
	pop	hl
	ld	a,h
	rra
l3713:
	pop	hl
	ld	($$ARG+6),hl
	pop	hl
	ld	($$ARG+4),hl
	call	c,l36bb
l371e:
	call	z,l2874
	push	de
	push	bc
	call	l26bd
	pop	bc
	pop	de
	call	l2703
;
; Function : EXP(X)
;
l372b:
	ld	bc,l8138
	ld	de,laa3b
	call	l2703
	ld	a,($$ARG+7)
	cp	88h
	jp	nc,l3760
	cp	68h
	jp	c,l3772
	call	l2899
	call	l2a8d
	add	a,81h
	pop	bc
	pop	de
	jp	z,l3763
	push	af
	call	l2585
	ld	hl,l377b
	call	l37a7
	pop	bc
	ld	de,l0000
	ld	c,d
	jp	l2703
l3760:
	call	l2899
l3763:
	ld	a,($$ARG+6)
	or	a
	jp	p,l376f
	pop	af
	pop	af
	jp	st.ZERO		; Zero real number
l376f:
	jp	l307e
l3772:
	ld	bc,81h*256+0
	ld	de,l0000
	jp	l28a9
;
l377b:
	db	7
	db	07ch,088h,059h,074h
	db	0e0h,097h,026h,077h
	db	0c4h,01dh,01eh,07ah
	db	05eh,050h,063h,07ch
	db	01ah,0feh,075h,07eh
	db	018h,072h,031h,080h
	db	000h,000h,000h,081h
;
;
;
l3798:
	call	l2899
	ld	de,l2b95
	push	de
	push	hl
	call	l28b4
	call	l2703
	pop	hl
l37a7:
	call	l2899
	ld	a,(hl)
	inc	hl
	call	l28a6
	_LD.B
l37b0:
	pop	af
	pop	bc
	pop	de
	dec	a
	ret	z
	push	de
	push	bc
	push	af
	push	hl
	call	l2703
	pop	hl
	call	l28b7
	push	hl
	call	l2588
	pop	hl
	jp	l37b0
l37c8:
	ld	d,d
	rst	0
	ld	c,a
	add	a,b
l37cc:
	call	get.tok
l37cf:
	push	hl
	ld	hl,l2697
	call	l28a6
	call	l37dd
	pop	hl
	jp	tp.SNGL		; Set single precision type
;
; Function : RND[(X)]
;
l37dd:
	call	l2845
	ld	hl,l3848
	jp	m,l383e
	ld	hl,l3869
	call	l28a6
	ld	hl,l3848
	ret	z
	add	a,(hl)
	and	7
	ld	b,0
	ld	(hl),a
	inc	hl
	add	a,a
	add	a,a
	ld	c,a
	add	hl,bc
	call	l28b7
	call	l2703
	ld	a,(l3847)
	inc	a
	and	3
	ld	b,0
	cp	1
	adc	a,b
	ld	(l3847),a
	ld	hl,l3869
	add	a,a
	add	a,a
	ld	c,a
	add	hl,bc
	call	l257c
l3819:
	call	l28b4
	ld	a,e
	ld	e,c
	xor	'O'
	ld	c,a
	ld	(hl),80h
	dec	hl
	ld	b,(hl)
	ld	(hl),80h
	ld	hl,l3846
	inc	(hl)
	ld	a,(hl)
	sub	0abh
	jp	nz,l3835
	ld	(hl),a
	inc	c
	dec	d
	inc	e
l3835:
	call	l25da
	ld	hl,l3869
	jp	l28c0
l383e:
	ld	(hl),a
	dec	hl
	ld	(hl),a
	dec	hl
	ld	(hl),a
	jp	l3819
l3846:
	db	0
l3847:
	db	0
l3848:
	db	000h,035h,04ah,0cah,099h,039h,01ch,076h
	db	098h,022h,095h,0b3h,098h,00ah,0ddh,047h
	db	098h,053h,0d1h,099h,099h,00ah,01ah,09fh
	db	098h,065h,0bch,0cdh,098h,0d6h,077h,03eh
	db	098h
l3869:
	db	052h
l386a:
	db	0c7h,04fh,080h,068h,0b1h,046h,068h
	db	099h,0e9h,092h,069h,010h,0d1h,075h,068h
;
; Function : COS(X)
;
l3879:
	ld	hl,l38ff
	call	l257c
;
; Function : SIN(X)
;
l387f:
	ld	a,($$ARG+7)
	cp	77h
	ret	c
	ld	a,($$ARG+6)
	or	a
	jp	p,l3895
	and	7fh
	ld	($$ARG+6),a
	ld	de,l2874
	push	de
l3895:
	ld	bc,l7e22
	ld	de,lf983
	call	l2703
	call	l2899
	call	l2a8d
	pop	bc
	pop	de
	call	l2585
	ld	bc,l7f00
	ld	de,l0000
	call	l2906
	jp	m,l38d9
	ld	bc,l7f80
	ld	de,l0000
	call	l2588
	ld	bc,l8080
	ld	de,l0000
	call	l2588
	call	l2845
	call	p,l2874
	ld	bc,l7f00
	ld	de,l0000
	call	l2588
	call	l2874
l38d9:
	ld	a,($$ARG+6)
	or	a
	push	af
	jp	p,l38e6
	xor	80h
	ld	($$ARG+6),a
l38e6:
	ld	hl,l3907
	call	l3798
	pop	af
	ret	p
	ld	a,($$ARG+6)
	xor	80h
	ld	($$ARG+6),a
	ret
;
	db	000h,000h,000h,000h,083h,0f9h,022h,07eh
l38ff:
	db	0dbh,00fh,049h,081h,000h,000h,000h,07fh
l3907:
	db	5
	db	0fbh,0d7h,01eh,086h
	db	065h,026h,099h,087h
	db	058h,034h,023h,087h
	db	0e1h,05dh,0a5h,086h
	db	0dbh,00fh,049h,083h
;
; Function : TAN(X)
;
l391c:
	call	l2899
	call	l387f
	pop	bc
	pop	hl
	call	l2899
	ex	de,hl
	call	l28a9
	call	l3879
	jp	l2767
;
; Function : ATN(X)
;
l3931:
	call	l2845
	call	m,l36bb
	call	m,l2874
	ld	a,($$ARG+7)
	cp	81h
	jp	c,l394e
	ld	bc,81h*256+0
	ld	d,c
	ld	e,c
	call	l2769
	ld	hl,l2582
	push	hl
l394e:
	ld	hl,l3958
	call	l3798
	ld	hl,l38ff
	ret
l3958:
	db	9
	db	04ah,0d7h,03bh,078h
	db	002h,06eh,084h,07bh
	db	0feh,0c1h,02fh,07ch
	db	074h,031h,09ah,07dh
	db	084h,03dh,05ah,07dh
	db	0c8h,07fh,091h,07eh
	db	0e4h,0bbh,04ch,07eh
	db	06ch,0aah,0aah,07fh
	db	000h,000h,000h,081h
;
; Return of DIM
;
l397d:
	dec	hl
	call	get.tok		; Get token
	ret	z		; .. aha, end of line
	call	ilcmp		; Verify delimiter
	db	','
;
; Statement : DIM <list of subscripted variables>
;
_DIM:
	ld	bc,l397d
	push	bc		; Set return address
	_OR			; .. and fall into DIM
;
; Fetch address of variable
;
var.adr::
	xor	a
	ld	(l0a66),a
	ld	c,(hl)
l3990:
	call	isalph		; Test A..Z
	jp	c,l0cc9		; .. nope
	xor	a
	ld	b,a
	ld	(l07c5),a
	inc	hl
	ld	a,(hl)
	cp	'.'
	jp	c,l39e3
	jp	z,l39b5
	cp	'9'+1
	jp	nc,l39af
	cp	'0'
	jp	nc,l39b5
l39af:
	call	isalph_		; Test A..Z
	jp	c,l39e3		; .. nope
l39b5:
	ld	b,a
	push	bc
	ld	b,0ffh
	ld	de,l07c5
l39bc:
	or	80h
	inc	b
	ld	(de),a
	inc	de
	inc	hl
	ld	a,(hl)
	cp	'9'+1
	jp	nc,l39cd
	cp	'0'
	jp	nc,l39bc
l39cd:
	call	isalph_		; Test A..Z
	jp	nc,l39bc	; .. yeap
	cp	'.'
	jp	z,l39bc
	ld	a,b
	cp	''''
	jp	nc,l0cc9
	pop	bc
	ld	(l07c5),a
	ld	a,(hl)
l39e3:
	cp	'&'
	jp	nc,l39ff
	ld	de,l3a0d
	push	de
	ld	d,2
	cp	'%'
	ret	z
	inc	d
	cp	'$'
	ret	z
	inc	d
	cp	'!'
	ret	z
	ld	d,8
	cp	'#'
	ret	z
	pop	af
l39ff:
	ld	a,c
	and	7fh
	ld	e,a
	ld	d,0
	push	hl
	ld	hl,STR.arr+5*3	; Point to record
	add	hl,de
	ld	d,(hl)
	pop	hl
	dec	hl
l3a0d:
	ld	a,d
	ld	($ARGLEN),a	; Set length
	call	get.tok
	ld	a,(l0aa5)
	dec	a
	jp	z,l3b92
	jp	p,l3a29
l3a1e:
	ld	a,(hl)
	sub	'('
	jp	z,l3b16
	sub	'3'
	jp	z,l3b16
l3a29:
	xor	a
	ld	(l0aa5),a
	push	hl
	ld	a,(l0bb7)
	or	a
	ld	(l0bb4),a
	jp	z,l3a7d
	ld	hl,(l0ae6)
	ld	de,l0ae8
	add	hl,de
	ld	(l0bb5),hl
	ex	de,hl
	jp	l3a63
l3a46:
	ld	a,(de)
	ld	l,a
	inc	de
	ld	a,(de)
	inc	de
	cp	c
	jp	nz,l3a5b
	ld	a,($ARGLEN)	; Get length
	cp	l		; Test same
	jp	nz,l3a5b
	ld	a,(de)
	cp	b
	jp	z,l3ae5
l3a5b:
	inc	de
l3a5c:
	ld	a,(de)
l3a5d:
	ld	h,0
	add	a,l
	inc	a
	ld	l,a
	add	hl,de
l3a63:
	ex	de,hl
	ld	a,(l0bb5)
	cp	e
	jp	nz,l3a46
	ld	a,(l0bb6)
	cp	d
	jp	nz,l3a46
	ld	a,(l0bb4)
	or	a
	jp	z,l3a92
	xor	a
	ld	(l0bb4),a
l3a7d:
	ld	hl,(l0ac4)
	ld	(l0bb5),hl
	ld	hl,(prg.top)	; Get top of program
	jp	l3a63
l3a89:
	call	var.adr		; Get address of variable
l3a8c:
	ret
l3a8d:
	ld	d,a
	ld	e,a
	pop	bc
	ex	(sp),hl
	ret
l3a92:
	pop	hl
	ex	(sp),hl
	push	de
	ld	de,l3a8c
	call	cp.r
	jp	z,l3a8d		; HL = DE
	ld	de,l1c4d
	call	cp.r
	pop	de
	jp	z,l3b00		; HL = DE
	ex	(sp),hl
	push	hl
	push	bc
	ld	a,($ARGLEN)	; Get length
	ld	b,a
	ld	a,(l07c5)
	add	a,b
	inc	a
	ld	c,a
	push	bc
	ld	b,0
	inc	bc
	inc	bc
	inc	bc
	ld	hl,(l0ac6)
	push	hl
	add	hl,bc
	pop	bc
	push	hl
	call	l42b6
	pop	hl
	ld	(l0ac6),hl
	ld	h,b
	ld	l,c
	ld	(l0ac4),hl
l3ace:
	dec	hl
	ld	(hl),0
	call	cp.r
	jp	nz,l3ace	; HL <> DE
	pop	de
	ld	(hl),d
	inc	hl
	pop	de
	ld	(hl),e
	inc	hl
	ld	(hl),d
	call	l3ca3
	ex	de,hl
	inc	de
	pop	hl
	ret
l3ae5:
	inc	de
	ld	a,(l07c5)
	ld	h,a
	ld	a,(de)
	cp	h
	jp	nz,l3a5c
	or	a
	jp	nz,l3af6
	inc	de
	pop	hl
	ret
l3af6:
	ex	de,hl
	call	l3cb8
	ex	de,hl
	jp	nz,l3a5d
	pop	hl
	ret
l3b00:
	ld	($$ARG+7),a
	ld	h,a
	ld	l,a
	ld	($$ARG+4),hl
	call	get.type	; Get type
	jp	nz,l3b14	; .. not a pointer
	ld	hl,l0c44
	ld	($$ARG+4),hl
l3b14:
	pop	hl
	ret
l3b16:
	push	hl
	ld	hl,(l0a66)
	ex	(sp),hl
	ld	d,a
l3b1c:
	push	de
	push	bc
	ld	de,l07c5
	ld	a,(de)
	or	a
	jp	z,l3b58
	ex	de,hl
	add	a,2
	rra
	ld	c,a
	call	tstmem		; Verify enough memory
	ld	a,c
l3b2f:
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	push	bc
	dec	a
	jp	nz,l3b2f
	push	hl
	ld	a,(l07c5)
	push	af
	ex	de,hl
	call	l1411
	pop	af
	ld	(l07ec),hl
	pop	hl
	add	a,2
	rra
l3b49:
	pop	bc
	dec	hl
	ld	(hl),b
	dec	hl
	ld	(hl),c
	dec	a
	jp	nz,l3b49
	ld	hl,(l07ec)
	jp	l3b5f
l3b58:
	call	l1411
	xor	a
	ld	(l07c5),a
l3b5f:
	ld	a,(l0bc6)
	or	a
	jp	z,l3b6c
	ld	a,d
	or	e
	jp	z,l3bd6
	dec	de
l3b6c:
	pop	bc
	pop	af
	ex	de,hl
	ex	(sp),hl
	push	hl
	ex	de,hl
	inc	a
	ld	d,a
	ld	a,(hl)
	cp	','
	jp	z,l3b1c
	cp	')'
	jp	z,l3b84
	cp	']'
	jp	nz,l0cc9
l3b84:
	call	get.tok
	ld	(l0abc),hl
	pop	hl
	ld	(l0a66),hl
	ld	e,0
	push	de
	_LD.DE
l3b92:
	push	hl
	push	af
	ld	hl,(l0ac4)
	_LD.A
l3b98:
	add	hl,de
	ex	de,hl
	ld	hl,(l0ac6)
	ex	de,hl
	call	cp.r
	jp	z,l3bf0		; HL = DE
	ld	e,(hl)
	inc	hl
	ld	a,(hl)
	inc	hl
	cp	c
	jp	nz,l3bb8
	ld	a,($ARGLEN)	; Get length
	cp	e
	jp	nz,l3bb8
	ld	a,(hl)
	cp	b
	jp	z,l3bdc
l3bb8:
	inc	hl
l3bb9:
	ld	e,(hl)
	inc	e
	ld	d,0
	add	hl,de
l3bbe:
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	jp	nz,l3b98
	ld	a,(l0a66)
	or	a
	jp	nz,l0cd2
	pop	af
	ld	b,h
	ld	c,l
	jp	z,l2757
	sub	(hl)
	jp	z,l3c5d
l3bd6:
	ld	de,9		; Subscript out of range
	jp	_error
l3bdc:
	inc	hl
	ld	a,(l07c5)
	cp	(hl)
	jp	nz,l3bb9
	inc	hl
	or	a
	jp	z,l3bbe
	dec	hl
	call	l3cb8
	jp	l3bbe
l3bf0:
	ld	a,($ARGLEN)	; Get length
	ld	(hl),a
	inc	hl
	ld	e,a
	ld	d,0
	pop	af
	jp	z,l3c96
	ld	(hl),c
	inc	hl
	ld	(hl),b
	call	l3ca3
	inc	hl
	ld	c,a
	call	tstmem		; Verify memory
	inc	hl
	inc	hl
	ld	(l0a9d),hl
	ld	(hl),c
	inc	hl
	ld	a,(l0a66)
	rla
	ld	a,c
l3c13:
	jp	c,l3c23
	push	af
	ld	a,(l0bc6)
	xor	0bh
	ld	c,a
	ld	b,0
	pop	af
	jp	nc,l3c25
l3c23:
	pop	bc
	inc	bc
l3c25:
	ld	(hl),c
	push	af
	inc	hl
	ld	(hl),b
	inc	hl
	call	l2b05
	pop	af
	dec	a
	jp	nz,l3c13
	push	af
	ld	b,d
	ld	c,e
	ex	de,hl
	add	hl,de
	jp	c,l42dd
	call	l42eb
	ld	(l0ac6),hl
l3c40:
	dec	hl
	ld	(hl),0
	call	cp.r
	jp	nz,l3c40	; HL <> DE
	inc	bc
	ld	d,a
	ld	hl,(l0a9d)
	ld	e,(hl)
	ex	de,hl
	add	hl,hl
	add	hl,bc
	ex	de,hl
	dec	hl
	dec	hl
	ld	(hl),e
	inc	hl
	ld	(hl),d
	inc	hl
	pop	af
	jp	c,l3c92
l3c5d:
	ld	b,a
	ld	c,a
	ld	a,(hl)
	inc	hl
	_LD.D
l3c62:
	pop	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ex	(sp),hl
	push	af
	call	cp.r
	jp	nc,l3bd6	; HL >= DE
	call	l2b05
	add	hl,de
	pop	af
	dec	a
	ld	b,h
	ld	c,l
	jp	nz,l3c62
	ld	a,($ARGLEN)	; Get length
	ld	b,h
	ld	c,l
	add	hl,hl
	sub	4
	jp	c,l3c8a
	add	hl,hl
	jp	z,l3c8f
	add	hl,hl
l3c8a:
	or	a
	jp	po,l3c8f
	add	hl,bc
l3c8f:
	pop	bc
	add	hl,bc
	ex	de,hl
l3c92:
	ld	hl,(l0abc)
	ret
l3c96:
	scf
	sbc	a,a
	pop	hl
	ret
;
;
;
l3c9a:
	ld	a,(hl)
	inc	hl
;
;
;
l3c9c:
	push	bc
	ld	b,0
	ld	c,a
	add	hl,bc
	pop	bc
	ret
;
;
;
l3ca3:
	push	bc
	push	de
	push	af
	ld	de,l07c5
	ld	a,(de)		; Get length
	ld	b,a
	inc	b
l3cac:
	ld	a,(de)		; .. Unpack
	inc	de
	inc	hl
	ld	(hl),a
	dec	b
	jp	nz,l3cac
	pop	af
	pop	de
	pop	bc
	ret
;
;
;
l3cb8:
	push	de
	push	bc
	ld	de,l07c6
	ld	b,a		; Set length
	inc	hl
	inc	b
l3cc0:
	dec	b
	jp	z,l3cd2
	ld	a,(de)
	inc	de
	cp	(hl)		; .. compare
	inc	hl
	jp	z,l3cc0
	ld	a,b
	dec	a
	call	nz,l3c9c
	xor	a
	dec	a
l3cd2:
	pop	bc
	pop	de
	ret
;
;
;
l3cd5:
	ld	(err.num),a	; Set error number
	ld	hl,(direct_2)	; Get direct mode
	or	h
	and	l
	inc	a
	ex	de,hl
	ret	z		; .. -1 is direct, end
	jp	l3ce7
;
; Statement : EDIT <line number>
;
l3ce3:
	call	l141d
	ret	nz
l3ce7:
	pop	hl
l3ce8:
	ex	de,hl
	ld	(l0ab5),hl
	ex	de,hl
	call	l0ef8
	jp	nc,l14cc
	ld	h,b
	ld	l,c
	inc	hl
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	push	bc
	call	l20e6
l3cff:
	pop	hl
;
; -> Edit entry from outer space
;
__EDIT::
	push	hl
	ld	a,h
	and	l
	inc	a
	ld	a,'!'
	call	z,putchar
	call	nz,l311a
	ld	a,' '
	call	putchar
	ld	hl,$LINE	; Init pointer
	push	hl
	ld	c,-1
l3d17:
	inc	c
	ld	a,(hl)
	inc	hl
	or	a
	jp	nz,l3d17
	pop	hl
	ld	b,a
l3d20:
	ld	d,0
l3d22:
	call	conin		; Get character
	or	a
	jp	z,l3d22		; .. wait for any
	call	toupper		; .. as upper case
	sub	'0'		; Test number
	jp	c,l3d41		; .. nope
	cp	9+1
	jp	nc,l3d41
	ld	e,a
	ld	a,d
	rlca
	rlca
	add	a,d
	rlca
	add	a,e
	ld	d,a
	jp	l3d22
l3d41:
	push	hl
	ld	hl,l3d20
	ex	(sp),hl
	dec	d
	inc	d
	jp	nz,l3d4c
	inc	d
l3d4c:
	cp	bs-'0'
	jp	z,l3eba
	cp	rubout-'0'
	jp	z,l3ec9
	cp	cr-'0'
	jp	z,l3ed7
	cp	' '-'0'
	jp	z,l3da8
	cp	'a'-'0'
	jp	c,l3d67
	sub	'a'-'A'
l3d67:
	cp	'Q'-'0'
	jp	z,l3eec
	cp	'L'-'0'
	jp	z,l3de2
	cp	'S'-'0'
	jp	z,l3dbb
	cp	'I'-'0'
	jp	z,l3e3e
	cp	'D'-'0'
	jp	z,l3dec
	cp	'C'-'0'
	jp	z,l3e09
	cp	'E'-'0'
	jp	z,l3eda
	cp	'X'-'0'
	jp	z,l3e39
	cp	'K'-'0'
	jp	z,l3db5
	cp	'H'-'0'
	jp	z,l3e36
	cp	'A'-'0'
	ld	a,bell
	jp	nz,putchar
;
; -> A : Restart editing
;
	pop	bc
	pop	de
	call	fnl		; Give new line
	jp	l3ce8
;
; -> Space
;
l3da8:
	ld	a,(hl)
	or	a
	ret	z
	inc	b
	call	l42a5		; Print character, test new line
	inc	hl
	dec	d
	jp	nz,l3da8
	ret
;
; -> K : Search and delete string
;
l3db5:
	push	hl
	ld	hl,l3e03
	ex	(sp),hl
	scf
;
; -> S : Search for string
;
l3dbb:
	push	af
	call	conin		; Get character
	ld	e,a
	pop	af
	push	af
	call	c,l3e03
l3dc5:
	ld	a,(hl)
	or	a
	jp	z,l3de0
	call	l42a5		; Print character, test new line
	pop	af
	push	af
	call	c,l3e81
	jp	c,l3dd7
	inc	hl
	inc	b
l3dd7:
	ld	a,(hl)
	cp	e
	jp	nz,l3dc5
	dec	d
	jp	nz,l3dc5
l3de0:
	pop	af
	ret
;
; -> L : List remainder of line
;
l3de2:
	call	l20dc		; Print it
	call	fnl		; Give new line
	pop	bc
	jp	l3cff
;
; -> D : Delete character(s) to the right
;
l3dec:
	ld	a,(hl)
	or	a
	ret	z
	ld	a,'\'
	call	l42a5		; Print character, test new line
l3df4:
	ld	a,(hl)
	or	a
	jp	z,l3e03
	call	l42a5		; Print character, test new line
	call	l3e81
	dec	d
	jp	nz,l3df4
l3e03:
	ld	a,'\'
	call	putchar
	ret
;
; -> C : Change text
;
l3e09:
	ld	a,(hl)
	or	a
	ret	z
l3e0c:
	call	conin		; Get character
	cp	' '		; Test valid input
	jp	nc,l3e2b
	cp	lf
	jp	z,l3e2b
	cp	bell
	jp	z,l3e2b
l3e1e:
	cp	tab
	jp	z,l3e2b
	ld	a,bell
	call	putchar
	jp	l3e0c
l3e2b:
	ld	(hl),a
	call	l42a5		; Print character, test new line
	inc	hl
	inc	b
	dec	d
	jp	nz,l3e09
	ret
;
; -> H : Delete all characters to the right
;
l3e36:
	ld	(hl),0
	ld	c,b
;
; -> X : Extend line
;
l3e39:
	ld	d,0ffh
	call	l3da8
;
; -> I : Insert text
;
l3e3e:
	call	conin		; Get character
	cp	rubout
	jp	z,l3e71
	cp	bs
	jp	z,l3e73
	cp	cr
	jp	z,l3ed7
	cp	esc
	ret	z
	cp	bs		; *** WHY AGAIN ??
	jp	z,l3e73
	cp	lf
	jp	z,l3e91
	cp	bell
	jp	z,l3e91
	cp	tab
	jp	z,l3e91
	cp	' '
	jp	c,l3e3e
	cp	'_'
	jp	nz,l3e91
;
; -> Rubout in I-mode
;
l3e71:
	ld	a,'_'
;
; -> Backspace in I-mode
;
l3e73:
	dec	b
	inc	b
	jp	z,l3e99
	call	l42a5		; Print character, test new line
	dec	hl
	dec	b
	ld	de,l3e3e
	push	de
l3e81:
	push	hl
	dec	c
l3e83:
	ld	a,(hl)
	or	a
	scf
	jp	z,l2757
	inc	hl
	ld	a,(hl)
	dec	hl
	ld	(hl),a
	inc	hl
	jp	l3e83
;
; -> Several control-cgars in I-mode
;
l3e91:
	push	af
	ld	a,c
	cp	0ffh
	jp	c,l3ea1
	pop	af
l3e99:
	ld	a,bell
	call	putchar
l3e9e:
	jp	l3e3e
l3ea1:
	sub	b
	inc	c
	inc	b
	push	bc
	ex	de,hl
	ld	l,a
	ld	h,0
	add	hl,de
	ld	b,h
	ld	c,l
	inc	hl
	call	l42b9
	pop	bc
	pop	af
	ld	(hl),a
	call	l42a5		; Print character, test new line
	inc	hl
	jp	l3e9e
;
; -> Backspace
;
l3eba:
	ld	a,b
	or	a
	ret	z
	dec	hl
	ld	a,bs
	call	l42a5		; Print character, test new line
	dec	b
	dec	d
	jp	nz,l3ec9
	ret
;
; -> Rubout
;
l3ec9:
	ld	a,b
	or	a
	ret	z
	dec	b
	dec	hl
	ld	a,(hl)
	call	l42a5		; Print character, test new line
	dec	d
	jp	nz,l3ec9
	ret
;
; -> Return
;
l3ed7:
	call	l20dc		; Print line
;
; -> E : Return, but do not print remainder
;
l3eda:
	call	fnl		; Give new line
	pop	bc
	pop	de
	ld	a,d
	and	e
	inc	a
l3ee2:
	ld	hl,l0961
	ret	z
	scf
	push	af
	inc	hl
	jp	l0e14
;
; -> Q : Return to MS BASIC level
;
l3eec:
	pop	bc
	pop	de
	ld	a,d
	and	e
	inc	a
	jp	z,l421c
	jp	l0d87
l3ef7:
	call	l1a03
	call	vrf.str		; Verify string follows
	call	ilcmp
	db	';'
	ex	de,hl
	ld	hl,($$ARG+4)
	jp	l3f11
l3f08:
	ld	a,(l0aa6)
	or	a
	jp	z,l3f1b
	pop	de
	ex	de,hl
l3f11:
	push	hl
	xor	a
	ld	(l0aa6),a
	inc	a
	push	af
	push	de
	ld	b,(hl)
	or	b
l3f1b:
	jp	z,_ill.func	; Invalid call
l3f1e:
	inc	hl
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	jp	l3f45
l3f26:
	ld	e,b
	push	hl
	ld	c,2
l3f2a:
	ld	a,(hl)
	inc	hl
	cp	'\'
	jp	z,l4091
	cp	' '
	jp	nz,l3f3b
	inc	c
	dec	b
	jp	nz,l3f2a
l3f3b:
	pop	hl
	ld	b,e
	ld	a,'\'
l3f3f:
	call	l40cc
	call	putchar
l3f45:
	xor	a
	ld	e,a
	ld	d,a
l3f48:
	call	l40cc
	ld	d,a
	ld	a,(hl)
	inc	hl
	cp	'!'
	jp	z,l408e
	cp	'#'
	jp	z,l3fa1
	cp	'&'
	jp	z,l4089
	dec	b
	jp	z,l4067
	cp	'+'
	ld	a,8
	jp	z,l3f48
	dec	hl
	ld	a,(hl)
	inc	hl
	cp	'.'
	jp	z,l3fc0
	cp	'_'
	jp	z,l407d
	cp	'\'
	jp	z,l3f26
	cp	(hl)
	jp	nz,l3f3f
	cp	'$'
	jp	z,l3f9a
	cp	'*'
	jp	nz,l3f3f
	ld	a,b
	inc	hl
	cp	2
	jp	c,l3f92
	ld	a,(hl)
	cp	'$'
l3f92:
	ld	a,' '
	jp	nz,l3f9e
	dec	b
	inc	e
	_CP
l3f9a:
	xor	a
	add	a,10h
	inc	hl
l3f9e:
	inc	e
	add	a,d
	ld	d,a
l3fa1:
	inc	e
	ld	c,0
	dec	b
	jp	z,l3ff6
	ld	a,(hl)
	inc	hl
	cp	'.'
	jp	z,l3fcb
	cp	'#'
	jp	z,l3fa1
	cp	','
	jp	nz,l3fd7
	ld	a,d
	or	01000000b
	ld	d,a
	jp	l3fa1
l3fc0:
	ld	a,(hl)
	cp	'#'
	ld	a,'.'
	jp	nz,l3f3f
	ld	c,1
	inc	hl
l3fcb:
	inc	c
	dec	b
	jp	z,l3ff6
	ld	a,(hl)
	inc	hl
	cp	'#'
	jp	z,l3fcb
l3fd7:
	push	de
	ld	de,l3ff4
	push	de
	ld	d,h
	ld	e,l
	cp	'^'
	ret	nz
	cp	(hl)
	ret	nz
	inc	hl
	cp	(hl)
	ret	nz
	inc	hl
	cp	(hl)
	ret	nz
	inc	hl
	ld	a,b
	sub	4
	ret	c
	pop	de
	pop	de
	ld	b,a
	inc	d
	inc	hl
	_JP.Z
l3ff4:
	ex	de,hl
	pop	de
l3ff6:
	ld	a,d
	dec	hl
	inc	e
	and	8
	jp	nz,l4016
	dec	e
	ld	a,b
	or	a
	jp	z,l4016
	ld	a,(hl)
	sub	'-'
	jp	z,l4011
	cp	0feh
	jp	nz,l4016
	ld	a,8
l4011:
	add	a,4
	add	a,d
	ld	d,a
	dec	b
l4016:
	pop	hl
	pop	af
	jp	z,l4072
	push	bc
	push	de
	call	EXPR		; Get expression
	pop	de
	pop	bc
	push	bc
	push	hl
	ld	b,e
	ld	a,b
	add	a,c
	cp	19h
	jp	nc,_ill.func	; Invalid call
	ld	a,d
	or	80h
	call	l312a
	call	l4723
l4035:
	pop	hl
	dec	hl
	call	get.tok
	scf
	jp	z,l404e
	ld	(l0aa6),a
	cp	';'
	jp	z,l404b
	cp	','
	jp	nz,l0cc9
l404b:
	call	get.tok
l404e:
	pop	bc
	ex	de,hl
	pop	hl
	push	hl
	push	af
	push	de
	ld	a,(hl)
	sub	b
	inc	hl
	ld	d,0
	ld	e,a
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	add	hl,de
l405f:
	ld	a,b
	or	a
	jp	nz,l3f45
	jp	l406d
l4067:
	call	l40cc
	call	putchar
l406d:
	pop	hl
	pop	af
	jp	nz,l3f08
l4072:
	call	c,fnl		; Give new line
	ex	(sp),hl
	call	l48ab
	pop	hl
	jp	clr.FP		; Reset file I/O
l407d:
	call	l40cc
	dec	b
	ld	a,(hl)
	inc	hl
	call	putchar
	jp	l405f
l4089:
	ld	c,0
	jp	l4092
l408e:
	ld	c,1
	_LD.A
l4091:
	pop	af
l4092:
	dec	b
	call	l40cc
	pop	hl
	pop	af
	jp	z,l4072
	push	bc
	call	EXPR		; Get expression
	call	vrf.str		; Verify string follows
	pop	bc
	push	bc
	push	hl
	ld	hl,($$ARG+4)
	ld	b,c
	ld	c,0
	ld	a,b
	push	af
	ld	a,b
	or	a
	call	nz,l494f
	call	l4726
	ld	hl,($$ARG+4)
	pop	af
	or	a
	jp	z,l4035
	sub	(hl)
	ld	b,a
	ld	a,' '
	inc	b
l40c2:
	dec	b
	jp	z,l4035
	call	putchar
	jp	l40c2
l40cc:
	push	af
	ld	a,d
	or	a
	ld	a,'+'
	call	nz,putchar
	pop	af
	ret
;
; Put character to active device
;
putchar::
	push	af
	push	hl
	call	fpact		; Test file active
	jp	nz,fputc	; .. yeap, get from there
	pop	hl
	ld	a,(iodev)	; Test console
	or	a
	jp	z,conout	; .. yeap
	pop	af
	push	af
	cp	bs		; Test backspace
	jp	nz,l40fc
	ld	a,(colLST)	; Get column
	sub	1
	jp	c,l40f8		; .. already at left side
	ld	(colLST),a
l40f8:
	pop	af
	jp	lstout		; Put to printer
l40fc:
	cp	tab
	jp	nz,l4110
l4101:
	ld	a,' '
	call	putchar
	ld	a,(colLST)	; Get column
	and	00000111b	; .. modulo 8
	jp	nz,l4101
	pop	af
	ret
l4110:
	pop	af
	push	af
	sub	cr
	jp	z,l4133
	jp	c,l4136
	ld	a,(l078f)
	inc	a
	ld	a,(colLST)	; Get column
	jp	z,l412d
	push	hl
	ld	hl,l078f
	cp	(hl)
	pop	hl
	call	z,cls.LST	; .. close printer
l412d:
	cp	255
	jp	z,l4136
	inc	a
l4133:
	ld	(colLST),a
l4136:
	pop	af
;
; Put character in Accu to printer
;
lstout:
	push	af
	push	bc
	push	de
	push	hl
	ld	c,a
	call	$-$		; Put character to printer
$POT	equ	$-2
	pop	hl
	pop	de
	pop	bc
	pop	af
	ret
;
; Clear device I/O
;
cls.dev_io:
	xor	a
	ld	(iodev),a	; Set console
	ld	a,(colLST)	; .. test any in printer column
	or	a
	ret	z		; .. nope
;
; Close printer line
;
cls.LST:
	ld	a,cr
	call	lstout		; .. give CR.LF
	ld	a,lf
	call	lstout
	xor	a
	ld	(colLST),a	; Clear column
	ret
;
; Put character to console - Remember character on stack
;
conout::
	ld	a,(_brk)	; Test echo
	or	a
	jp	nz,pop.a	; .. nope
	pop	af
	push	bc
	push	af
	cp	bs		; Test backspace
	jp	nz,l417b
	ld	a,(colCON)	; Get column
	or	a
	jp	z,l418d		; .. already at left side
	dec	a
	ld	(colCON),a
	ld	a,bs
	jp	l41ae
l417b:
	cp	tab
	jp	nz,l4190
l4180:
	ld	a,' '
	call	putchar
	ld	a,(colCON)	; Get column
	and	00000111b	; .. modulo 8
	jp	nz,l4180
l418d:
	pop	af
	pop	bc
	ret
l4190:
	cp	' '
	jp	c,l41ae
	ld	a,(l0790)
	ld	b,a
	ld	a,(colCON)	; Get column
	inc	b
	jp	z,l41a5
	dec	b
	cp	b
	call	z,fnl		; Give new line
l41a5:
	cp	255
	jp	z,l41ae
	inc	a
	ld	(colCON),a
l41ae:
	pop	af
	pop	bc
	push	af
	pop	af
	push	af
	push	bc
	push	de
	push	hl
	ld	c,a
	call	$-$		; Put character to console
$COT	equ	$-2
	pop	hl
	pop	de
	pop	bc
	pop	af
	ret
;
; Get character from active device
;
getchar:
	call	fpact		; Test file active
	jp	z,conin		; .. nope, get from keyboard
	call	fgetc		; Get from file
	ret	nc		; .. well done
	push	bc
	push	de
	push	hl
	call	l534d
	pop	hl
	pop	de
	pop	bc
	ld	a,(l0bf3)
	or	a
	jp	nz,l5030
	ld	a,(l079e)
	or	a
	jp	z,l41e7
	ld	hl,l12a0
	push	hl
	jp	l4337
l41e7:
	push	hl
	push	bc
	push	de
	ld	hl,l0c45
	call	l4723
	pop	de
	pop	bc
	xor	a
	pop	hl
	ret
;
; Get character from console into Accu
;
conin:
	push	bc
	push	de
	push	hl
	call	$-$		; Get input character
$CIN	equ	$-2
	pop	hl
	pop	de
	pop	bc
	and	NoMSB		; Strip off hi bit
	cp	'O'-'@'		; Test special
	ret	nz
	ld	a,(_brk)	; Test echo
	or	a
	call	z,l4441		; .. yeap
	cpl			; Toggle state
	ld	(_brk),a
	or	a
	jp	z,l4441
	xor	a
	ret
;
; Clear console
;
cls.CON:
	ld	a,(colCON)	; Test any in console column
	or	a
	ret	z		; .. nope
	jp	fnl		; Give new line
;
;
;
l421c:
	ld	(hl),0
	ld	hl,l0961
;
;
;
fnl:
	ld	a,cr
	call	putchar		; Give new line
	ld	a,lf
	call	putchar
l422b:
	call	fpact		; Test file active
	jp	z,l4233		; .. nope
	xor	a
	ret
l4233:
	ld	a,(iodev)	; Test console
	or	a
	jp	z,l423f		; .. yeap
	xor	a
	ld	(colLST),a	; .. clear printer column
	ret
l423f:
	xor	a
	ld	(colCON),a	; Clear console column
	ld	a,(l0788)
l4246:
	dec	a
	ret	z
	push	af
	xor	a
	call	putchar		; Give zeroes
	pop	af
	jp	l4246
;
; Process input chacater - Zero set indicates none
;
condir:
	push	bc
	push	de
	push	hl
	call	$-$		; Get state of console
$CST2	equ	$-2
	pop	hl
	pop	de
	pop	bc
	or	a
	ret	z		; .. no character here
l425c:
	call	conin		; Get character
	cp	'S'-'@'
	call	z,conin		; .. skip it
	ld	(l0789),a
	cp	CtrlC		; Test break
	call	z,prCtrl	; .. echo it
	jp	l4401
l426f:
	call	get.tok
	push	hl
	call	l4299
	jp	nz,l4283
	call	$-$		; Get state of console
$CST3	equ	$-2
	or	a
	jp	z,l428c		; .. nothing pressed
	call	conin		; .. get character
l4283:
	push	af
	call	l46b7
	pop	af
	ld	e,a
	call	l48f8
l428c:
	ld	hl,l0c44
	ld	($$ARG+4),hl
	ld	a,3
	ld	($ARGLEN),a	; Set pointer length
	pop	hl
	ret
l4299:
	ld	a,(l0789)
	or	a
	ret	z
	push	af
	xor	a
	ld	(l0789),a
	pop	af
	ret
;
; Print character, test new line
;
l42a5:
	call	putchar		; Print character
	cp	lf		; Test new line
	ret	nz		; .. nope
	ld	a,cr
	call	putchar		; Give return
	call	l422b		; Process new line
	ld	a,lf
	ret
;
;
;
l42b6:
	call	l42eb
l42b9:
	push	bc
	ex	(sp),hl
	pop	bc
l42bc:
	call	cp.r		; Compare HL:DE
	ld	a,(hl)		; Unpack
	ld	(bc),a
	ret	z		; .. till end
	dec	bc
	dec	hl
	jp	l42bc
;
; Verify enough memory available
; ENTRY	Reg C holds amount to be checked for
;
tstmem:
	push	hl
	ld	hl,(himem)	; Get top of memory
	ld	b,0		; .. make 16 bit
	add	hl,bc		; .. get new top
	add	hl,bc
	ld	a,LOW 0ffc6h
	sub	l		; Test enough
	ld	l,a
	ld	a,HIGH 0ffc6h
	sbc	a,h
	ld	h,a
	jp	c,l42dd		; .. nope
	add	hl,sp		; Check for stack
	pop	hl
	ret	c		; .. ok
;
; Process memory overflow
;
l42dd:
	ld	hl,(heap)	; Get heap
	dec	hl		; .. fix
	dec	hl
	ld	(curstk),hl	; .. for stack
l42e5:
	ld	de,7		; Out of memory
	jp	_error
;
;
;
l42eb:
	call	cmp.top		; Compare against top
	ret	nc		; .. ok
	push	bc
	push	de
	push	hl
	call	l4767
	pop	hl
	pop	de
	pop	bc
	call	cmp.top		; Test room available
	ret	nc		; .. yeap
	jp	l42e5		; .. out of memory
;
; Compare pointer to top of memory
; EXIT	Zero set if same
;	Carry set if HL > ^'mem.top'
;
cmp.top:
	push	de
	ex	de,hl
	ld	hl,(mem.top)	; Get top of memory
	call	cp.r		; Compare HL:DE
	ex	de,hl
	pop	de
	ret
;
;
;
l430a:
	ld	a,(opnfiles)	; Get max files
	ld	b,a
	ld	hl,F.arr	; .. init file array
	xor	a
	inc	b
l4313:
	ld	e,(hl)		; Fetch pointer
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	(de),a		; .. set passive
	dec	b
	jp	nz,l4313
	call	l540d
	xor	a
;
; Statement : NEW
;
l4320:
	ret	nz		; .. end if more in line
l4321:
	ld	hl,(prg.base)	; Get base of program
	call	l447d
	ld	(_prot),a	; Clear protection of file
	ld	(auto.mode),a	; .. AUTO
	ld	(l0aa9),a
	ld	(hl),a		; Clear last line
	inc	hl
	ld	(hl),a
	inc	hl
	ld	(prg.top),hl	; .. save top
l4337:
	ld	hl,(prg.base)	; Get base of program
	dec	hl
l433b:
	ld	(@@ptr),hl	; .. set as pointer
	ld	a,(l0bed)
	or	a
	jp	nz,l4358
	xor	a
	ld	(l0bc7),a
	ld	(l0bc6),a
	ld	b,1ah
	ld	hl,l0aca
l4351:
	ld	(hl),4
	inc	hl
	dec	b
	jp	nz,l4351
l4358:
	ld	de,l37c8
	ld	hl,l3869
	call	l28c3
	ld	hl,l3846
	xor	a
	ld	(hl),a
	inc	hl
	ld	(hl),a
	inc	hl
	ld	(hl),a
	xor	a
	ld	(l0abb),a
	ld	l,a
	ld	h,a
	ld	(l0ab9),hl
	ld	(cont.mode),hl	; .. and CONT mode
	ld	hl,(himem)	; Get top of memory
	ld	a,(l0bf3)
	or	a
	jp	nz,l4383
	ld	(mem.top),hl	; .. set top of memory
l4383:
	xor	a
	call	l43e6
	ld	hl,(prg.top)	; Get top of program
	ld	(l0ac4),hl
	ld	(l0ac6),hl
	ld	a,(l0bed)
	or	a
	call	z,l540d
;
; Reset error environment
;
l4397:
	pop	bc		; Get caller
	ld	hl,(heap)	; .. and heap
	dec	hl		; .. fix
	dec	hl
	ld	(curstk),hl	; .. for stack
	inc	hl
	inc	hl
;
; Reset error environment
;
l43a2:
	ld	sp,hl		; Get stack
	ld	hl,STR.arr
	ld	(STR.ptr),hl	; .. reset string pointer
	call	l2572
	call	cls.dev_io	; Clear device I/O
	call	clr.FP		; .. reset file I/O
	xor	a
	ld	h,a
	ld	l,a
	ld	(l0ae6),hl
	ld	(l0bb7),a
	ld	(l0b4e),hl
	ld	(l0bba),hl
	ld	(l0ae4),hl
	ld	(l0aa5),a
	push	hl
	push	bc		; Save caller
l43c9:
	ld	hl,(@@ptr)	; Get back pointer
	ret
;
; Compare HL:DE - Zero says same
;		  Carry says HL < DE
;
cp.r:
	ld	a,h		; Compare hi
	sub	d
	ret	nz		; .. not same
	ld	a,l		; .. lo if hi matches
	sub	e
	ret
;
; Immediate ^HL buffer compare - Match is a *MUST*
;
ilcmp:
	ld	a,(hl)		; Get from buffer
	ex	(sp),hl
	cp	(hl)		; .. compare
	jp	nz,l43e3	; .. no match, error
	inc	hl
	ex	(sp),hl
	inc	hl
	ld	a,(hl)		; Get next
	cp	':'
	ret	nc
	jp	l130a
l43e3:
	jp	l0cc9
;
; Statement : RESTORE [<line number>]
;
l43e6:
	ex	de,hl
	ld	hl,(prg.base)	; Get base of program
	jp	z,l43fb		; .. totally restored
	ex	de,hl
	call	l1428
	push	hl
	call	l0ef8
	ld	h,b
	ld	l,c
	pop	de
	jp	nc,l14cc
l43fb:
	dec	hl
l43fc:
	ld	(DATA.ptr),hl	; Save pointer
	ex	de,hl
	ret
;
; Statement : STOP
;
l4401:
	ret	nz
	inc	a
	jp	l440c
;
; Statement : END
;
_END:
	ret	nz		; Skip if more in line
	push	af
	call	z,l540d
	pop	af
l440c:
	ld	(l0aaf),hl
	ld	hl,STR.arr
	ld	(STR.ptr),hl	; .. reset string pointer
	_LD.HL
l4416:
	or	0ffh
	pop	bc
l4419:
	ld	hl,(dir.mode)	; Get direct mode
	push	hl
	push	af
	ld	a,l
	and	h
	inc	a
	jp	z,l442d		; .. -1 is direct
	ld	(direct_4),hl	; .. save
	ld	hl,(l0aaf)
	ld	(cont.mode),hl	; .. set CONT mode
l442d:
	xor	a
	ld	(_brk),a	; Set echo
	call	cls.dev_io	; Clear device I/O
	call	cls.CON		; .. and console
	pop	af
	ld	hl,l0c4a
	jp	nz,l0d62
	jp	l0d86
l4441:
	ld	a,'O'-'@'
;
; Echo control character in Accu
;
prCtrl:
	push	af
	sub	CtrlC		; Test abort
	jp	nz,l444f	; .. nope
	ld	(iodev),a	; .. set console if so
	ld	(_brk),a	; .. and echo
l444f:
	ld	a,'^'
	call	putchar		; Indicate control
	pop	af
	add	a,'@'
	call	putchar		; .. print mapped control
	jp	fnl		; Give new line
;
; Statement : CONT
;
l445d:
	ld	hl,(cont.mode)	; Get mode
	ld	a,h
	or	l
	ld	de,17		; Can't continue
	jp	z,_error
	ex	de,hl
	ld	hl,(direct_4)	; Get direct mode
	ex	de,hl		;			** ???????
	ex	de,hl		;			** ???????
	ld	(dir.mode),hl	; .. set it
	ex	de,hl
	ret
;
; Statement : NULL <expr>
;
l4473:
	call	l2075
	ret	nz
	inc	a
	ld	(l0788),a
	ret
;
; Statement : TRON
;
l447c:
	_LD.A
;
; Statement : TROFF
;
l447d:
	xor	a
	ld	(trcflg),a	; (Re)Set trace flag
	ret
;
; Statement : SWAP <variable>,<variable>
;
l4482:
	call	var.adr		; Get address of 1st variable
	push	de
	push	hl
	ld	hl,l0bf6
	call	l28c9
	ld	hl,(l0ac4)
	ex	(sp),hl
	call	get.type	; Get type
	push	af		; .. save
	call	ilcmp
	db	','
	call	var.adr		; Get address of 2nd variable
	pop	af
	ld	b,a
	call	get.type	; .. get type of 2nd
	cp	b		; Verify same type
	jp	nz,l0ce1	; .. nope
	ex	(sp),hl
	ex	de,hl
	push	hl
	ld	hl,(l0ac4)
	call	cp.r
	jp	nz,l44c1	; HL <> DE
	pop	de
	pop	hl
	ex	(sp),hl
	push	de
	call	l28c9
	pop	hl
	ld	de,l0bf6
	call	l28c9
	pop	hl
	ret
l44c1:
	jp	_ill.func	; Invalid call
;
; Statement : ERASE <list of array variables>
;
l44c4:
	ld	a,1
	ld	(l0aa5),a
	call	var.adr		; Get address of variable
	jp	nz,l44c1
	push	hl
	ld	(l0aa5),a
	ld	h,b
	ld	l,c
	dec	bc
	dec	bc
	dec	bc
l44d8:
	ld	a,(bc)
	dec	bc
	or	a
	jp	m,l44d8
	dec	bc
	dec	bc
	add	hl,de
	ex	de,hl
	ld	hl,(l0ac6)	; Get top
l44e5:
	call	cp.r		; Compare HL:DE
	ld	a,(de)		; .. unpack
	ld	(bc),a
	inc	de
	inc	bc
	jp	nz,l44e5	; .. till top reached
	dec	bc
	ld	h,b
	ld	l,c
	ld	(l0ac6),hl
	pop	hl
	ld	a,(hl)
	cp	','
	ret	nz
	call	get.tok
	jp	l44c4
l4500:
	pop	af
	pop	hl
	ret
;
; Test ^HL alphabetical character - Carry set says no
;
isalph:
	ld	a,(hl)		; Get character
;
; Test Accu alphabetical character - Carry set says no
;
isalph_:
	cp	'A'		; .. test range
	ret	c
	cp	'Z'+1
	ccf
	ret
;
;
;
l450b:
	jp	l433b
;
; Statement : CLEAR [,[<expr1>][,<expr2>]]
;
l450e:
	jp	z,l450b
	cp	','
	jp	z,l4520
	call	l1414
	dec	hl
	call	get.tok
	jp	z,l450b
l4520:
	call	ilcmp
	db	','
	jp	z,l450b
	ex	de,hl
	ld	hl,(heap)	; Get heap
	ex	de,hl
	cp	','
	jp	z,l4534
	call	l4579
l4534:
	dec	hl
	call	get.tok
	push	de
	jp	z,l4585
	call	ilcmp
	db	','
	jp	z,l4585
	call	l4579
	dec	hl
	call	get.tok
	jp	nz,l0cc9
l454d:
	ex	(sp),hl
	push	hl
	ld	hl,l004e
	call	cp.r
	jp	nc,l4582	; HL >= DE -- overflow
	pop	hl
	call	l4597
	jp	c,l4582		; .. overflow
	push	hl
	ld	hl,(prg.top)	; Get top of program
	ld	bc,l0014
	add	hl,bc
	call	cp.r
	jp	nc,l4582	; HL >= DE -- overflow
	ex	de,hl
	ld	(himem),hl	; Set new top of memory
	pop	hl
	ld	(heap),hl	; .. and heap
	pop	hl
	jp	l450b
l4579:
	call	l22d1
	ld	a,d
	or	e
	jp	z,_ill.func	; Invalid if zero
	ret
l4582:
	jp	l42dd		; .. fix pointers, overflow
l4585:
	push	hl
	ld	hl,(heap)	; Get heap
	ex	de,hl
	ld	hl,(himem)	; .. and top of memory
	ld	a,e
	sub	l
	ld	e,a
	ld	a,d
	sbc	a,h
	ld	d,a
	pop	hl
	jp	l454d
l4597:
	ld	a,l
	sub	e
	ld	e,a
	ld	a,h
	sbc	a,d
	ld	d,a
	ret
;
; Statement : NEXT [<variable>][,<variable>...]
;
l459e:
	push	af
	_OR
l45a0:
	xor	a
	ld	(l0bbf),a
	pop	af
	ld	de,0		; .. set direction
l45a8:
	ld	(l0bbd),hl
	call	nz,var.adr	; Get address of variable
	ld	(@@ptr),hl	; .. save
	call	l0c50		; Fix for FOR, WHILE
	jp	nz,l0ccf	; .. NEXT without FOR
	ld	sp,hl
	push	de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	push	hl
	ld	hl,(l0bbd)
	call	cp.r
	jp	nz,l0ccf	; HL <> DE
	pop	hl
	pop	de
	push	de
	ld	a,(hl)
	push	af
	inc	hl
	push	de
	ld	a,(hl)
	inc	hl
	or	a
	jp	m,l45f9
	call	l28a6
	ex	(sp),hl
	push	hl
	ld	a,(l0bbf)
	or	a
	jp	nz,l45e7
	ld	hl,l0bc0
	call	l28a6
	xor	a
l45e7:
	call	nz,l257c
	pop	hl
	call	l28c0
	pop	hl
	call	l28b7
	push	hl
	call	l2906
	jp	l462f
l45f9:
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	ex	(sp),hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	push	hl
	ld	l,c
	ld	h,b
	ld	a,(l0bbf)
	or	a
	jp	nz,l4615
	ld	hl,(l0bc0)
	jp	l4620
l4615:
	call	l2b31
	ld	a,($ARGLEN)	; Get length
	cp	4		; Test single precision
	jp	z,l0cdb		; .. yeap
l4620:
	ex	de,hl
	pop	hl
	ld	(hl),d
	dec	hl
	ld	(hl),e
	pop	hl
	push	de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ex	(sp),hl
	call	l2933
l462f:
	pop	hl
	pop	bc
	sub	b
	call	l28b7
	jp	z,l4641
	ex	de,hl
	ld	(dir.mode),hl	; Set direct mode
	ld	l,c
	ld	h,b
	jp	l129c
l4641:
	ld	sp,hl		; Set stack
	ld	(curstk),hl	; .. save
	ld	hl,(@@ptr)	; Get back token pointer
	ld	a,(hl)
	cp	','
	jp	nz,l12a0
	call	get.tok
	call	l45a8
;
; Test file active - Zero set indicates not
;
fpact:
	push	hl
	ld	hl,(FP)		; Get file pointer
	ld	a,h		; Get result
	or	l
	pop	hl
	ret
;
;
;
l465c:
	call	str.adr		; Get address of string
	ld	a,(hl)		; Fetch length
	inc	hl
	ld	c,(hl)		; .. and pointer
	inc	hl
	ld	b,(hl)
	pop	de
	push	bc
	push	af
	call	l48ac
	pop	af
	ld	d,a
	ld	e,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	pop	hl
l4672:
	ld	a,e
	or	d
	ret	z
	ld	a,d
	sub	1
	ret	c
	xor	a
	cp	e
	inc	a
	ret	nc
	dec	d
	dec	e
	ld	a,(bc)
	inc	bc
	cp	(hl)
	inc	hl
	jp	z,l4672
	ccf
	jp	l2850
;
; Function : OCT$(X)
;
l468a:
	call	l366f
	jp	l4699
;
; Function : HEX$(X)
;
l4690:
	call	l3672
	jp	l4699
;
; Function : STR$(X)
;
l4696:
	call	l3129
l4699:
	call	l46c7
	call	l48a8
	ld	bc,l48fc
	push	bc
l46a3:
	ld	a,(hl)
	inc	hl
	push	hl
	call	l473c
	pop	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	call	l46bc
	push	hl
	ld	l,a
	call	l489b
	pop	de
	ret
;
;
;
l46b7:
	ld	a,1
l46b9:
	call	l473c
l46bc:
	ld	hl,STR.arr+10*3	; Point to last record
	push	hl
	ld	(hl),a		; Save length
	inc	hl
	ld	(hl),e		; .. and pointer
	inc	hl
	ld	(hl),d
	pop	hl
	ret
;
;
;
l46c7:
	dec	hl
l46c8:
	ld	b,'"'		; Set character
l46ca:
	ld	d,b		; Copy character
l46cb:
	push	hl
	ld	c,-1		; Init count
l46ce:
	inc	hl
	ld	a,(hl)		; Get character
	inc	c
	or	a		; Test end
	jp	z,l46dd
	cp	d		; Find sync character
	jp	z,l46dd
	cp	b		; .. next
	jp	nz,l46ce
l46dd:
	cp	'"'
	call	z,get.tok
	push	hl
	ld	a,b
	cp	','
	jp	nz,l46f5
	inc	c
l46ea:
	dec	c
	jp	z,l46f5
	dec	hl
	ld	a,(hl)
	cp	' '
	jp	z,l46ea
l46f5:
	pop	hl
	ex	(sp),hl
	inc	hl
	ex	de,hl
	ld	a,c
	call	l46bc
l46fd:
	ld	de,STR.arr+10*3	; Point to last record
	_LD.A
l4701:
	push	de
	ld	hl,(STR.ptr)
	ld	($$ARG+4),hl	; Set string pointer
	ld	a,3
	ld	($ARGLEN),a	; .. and length
	call	l28c9
	ld	de,STR.arr+3*11
	call	cp.r		; Compare HL:DE
	ld	(STR.ptr),hl	; .. save pointer
	pop	hl
	ld	a,(hl)
	ret	nz		; .. disd not reach top
	ld	de,16		; String formula too complex
	jp	_error
;
;
;
l4722:
	inc	hl
;
;
;
l4723:
	call	l46c7
l4726:
	call	l48a8
	call	l28b9
	inc	d
l472d:
	dec	d
	ret	z
	ld	a,(bc)
	call	putchar		; .. print character
	cp	cr
	call	z,l422b		; Process new line
	inc	bc
	jp	l472d
;
;
;
l473c:
	or	a
	_LD.C
l473e:
	pop	af
	push	af
	ld	hl,(l0ac6)
	ex	de,hl
	ld	hl,(mem.top)	; Get top of memory
	cpl
	ld	c,a
	ld	b,-1
	add	hl,bc
	inc	hl
	call	cp.r
	jp	c,l475a		; HL < DE
	ld	(mem.top),hl	; .. set top of memory
	inc	hl
	ex	de,hl
pop.a:
	pop	af
	ret
l475a:
	pop	af
	ld	de,14		; Out of string space
	jp	z,_error
	cp	a
	push	af
	_LD.BC
l47xx::
	ld	a,'G'
	push	bc
;
;
;
l4767:
	ld	hl,(himem)	; Get top of memory
l476a:
	ld	(mem.top),hl	; .. set top
	ld	hl,l0000
	push	hl
	ld	hl,(l0ac6)
	push	hl
	ld	hl,STR.arr	; Init array
l4778:
	ex	de,hl
	ld	hl,(STR.ptr)	; Get string pointer
	ex	de,hl
	call	cp.r		; Compare HL:DE
	ld	bc,l4778
	jp	nz,l4812	; .. no match
	ld	hl,l0b4c
	ld	(l0bb8),hl
	ld	hl,(l0ac4)
	ld	(l0bb5),hl
	ld	hl,(prg.top)	; Get top of program
l4795:
	ex	de,hl
	ld	hl,(l0bb5)
	ex	de,hl
	call	cp.r
	jp	z,l47b9		; HL = DE
	ld	a,(hl)
	inc	hl
	inc	hl
	inc	hl
	push	af
	call	l3c9a
	pop	af
	cp	3
	jp	nz,l47b2
	call	l4813
	xor	a
l47b2:
	ld	e,a
	ld	d,0
	add	hl,de
	jp	l4795
l47b9:
	ld	hl,(l0bb8)
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	a,d
	or	e
	ld	hl,(l0ac4)
	jp	z,l47db
	ex	de,hl
	ld	(l0bb8),hl
	inc	hl
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ex	de,hl
	add	hl,de
	ld	(l0bb5),hl
	ex	de,hl
	jp	l4795
l47da:
	pop	bc
l47db:
	ex	de,hl
	ld	hl,(l0ac6)
	ex	de,hl
	call	cp.r
	jp	z,l4837		; HL = DE
	ld	a,(hl)
	inc	hl
	push	af
	inc	hl
	inc	hl
	call	l3c9a
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	pop	af
	push	hl
	add	hl,bc
	cp	3
	jp	nz,l47da
	ld	(_f.$$),hl	; Save pointer
	pop	hl
	ld	c,(hl)
	ld	b,0
	add	hl,bc
	add	hl,bc
	inc	hl
l4804:
	ex	de,hl
	ld	hl,(_f.$$)	; Get file pointer
	ex	de,hl
	call	cp.r
	jp	z,l47db		; HL = DE
	ld	bc,l4804
l4812:
	push	bc		; Set return address
;
;
;
l4813:
	xor	a
	or	(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ret	z
	ld	b,h
	ld	c,l
	ld	hl,(mem.top)	; Get top of memory
	call	cp.r		; Compare HL:DE
	ld	h,b
	ld	l,c
	ret	c		; HL < DE
	pop	hl
	ex	(sp),hl
	call	cp.r		; Compare HL:DE
	ex	(sp),hl
	push	hl
	ld	h,b
	ld	l,c
	ret	nc		; HL >= DE
	pop	bc
	pop	af
	pop	af
	push	hl
	push	de
	push	bc
	ret
l4837:
	pop	de
	pop	hl
	ld	a,h
	or	l
	ret	z
	dec	hl
	ld	b,(hl)
	dec	hl
	ld	c,(hl)
	push	hl
	dec	hl
	ld	l,(hl)
	ld	h,0
	add	hl,bc
	ld	d,b
	ld	e,c
	dec	hl
	ld	b,h
	ld	c,l
	ld	hl,(mem.top)	; Get top of memory
	call	l42b9
	pop	hl
	ld	(hl),c
	inc	hl
	ld	(hl),b
	ld	h,b
	ld	l,c
	dec	hl
	jp	l476a
;
;
;
l485b:
	push	bc
	push	hl
	ld	hl,($$ARG+4)
	ex	(sp),hl
	call	l1b93
	ex	(sp),hl
	call	vrf.str		; Verify string follows
	ld	a,(hl)
	push	hl
	ld	hl,($$ARG+4)
	push	hl
	add	a,(hl)
	ld	de,15		; String too long
	jp	c,_error
	call	l46b9
	pop	de
	call	l48ac
	ex	(sp),hl
	call	l48ab
	push	hl
	ld	hl,(STR.arr+10*3+1)
	ex	de,hl		; Get last address
	call	l4893
	call	l4893
	ld	hl,l1a12
	ex	(sp),hl
	push	hl
	jp	l46fd
;
;
;
l4893:
	pop	hl
	ex	(sp),hl
	ld	a,(hl)		; Get length
	inc	hl
	ld	c,(hl)		; .. and pointer
	inc	hl
	ld	b,(hl)
	ld	l,a
l489b:
	inc	l
l489c:
	dec	l		; Test done
	ret	z		; .. yeap
	ld	a,(bc)		; .. unpack
	ld	(de),a
	inc	bc
	inc	de
	jp	l489c
;
; Fetch address of string record
;
str.adr:
	call	vrf.str		; Verify string follows
l48a8:
	ld	hl,($$ARG+4)	; Fetch address of string
l48ab:
	ex	de,hl
l48ac:
	call	l48c6
	ex	de,hl
	ret	nz
	push	de
	ld	d,b
	ld	e,c
	dec	de
	ld	c,(hl)
	ld	hl,(mem.top)	; Get top of memory
	call	cp.r
	jp	nz,l48c4	; HL <> DE
	ld	b,a
	add	hl,bc
	ld	(mem.top),hl	; .. save top of memory
l48c4:
	pop	hl
	ret
;
;
;
l48c6:
	ld	hl,(STR.ptr)	; Get string pointer
	dec	hl
	ld	b,(hl)
	dec	hl
	ld	c,(hl)
	dec	hl
	call	cp.r
	ret	nz		; HL <> DE
	ld	(STR.ptr),hl	; .. save new
	ret
;
; Function : LEN(X$)
;
l48d6:
	ld	bc,l1dd5
	push	bc
l48da:
	call	str.adr		; Get address of string
	xor	a
	ld	d,a		; Clear hi
	ld	a,(hl)		; .. fetch length
	or	a
	ret
;
; Functin : ASC(X$)
;
l48e2:
	ld	bc,l1dd5
	push	bc
l48e6:
	call	l48da		; Get string and its length
	jp	z,_ill.func	; .. empty string
	inc	hl
	ld	e,(hl)		; Fetch pointer
	inc	hl
	ld	d,(hl)
	ld	a,(de)		; .. fetch (1st) character
	ret
;
; Function : CHR$(I)
;
l48f2:
	call	l46b7
	call	get.byte	; Get byte
l48f8:
	ld	hl,(STR.arr+10*3+1)
	ld	(hl),e		; .. save as character
l48fc:
	pop	bc
	jp	l46fd
l4900:
	call	get.tok
	call	ilcmp
	db	'('
	call	l2075
	push	de
	call	ilcmp
	db	','
	call	EXPR		; Get expression
	call	ilcmp
	db	')'
	ex	(sp),hl
	push	hl
	call	get.type	; Get type
	jp	z,l4924		; .. got pointer
	call	get.byte	; Get byte
	jp	l4927
l4924:
	call	l48e6
l4927:
	pop	de
	call	l4930
;
; Function : SPACE$(X)
;
l492b:
	call	get.byte	; Get byte length
	ld	a,' '		; .. set filler
l4930:
	push	af
	ld	a,e
	call	l46b9
	ld	b,a
	pop	af
	inc	b
	dec	b
	jp	z,l48fc
	ld	hl,(STR.arr+10*3+1)
l493f:
	ld	(hl),a		; .. set constant
	inc	hl
	dec	b
	jp	nz,l493f
	jp	l48fc
;
; Function : LEFT$(X$)
;
l4948:
	call	l49c1
	xor	a
l494c:
	ex	(sp),hl
	ld	c,a
	_LD.A
l494f:
	push	hl
l4950:
	push	hl
	ld	a,(hl)
	cp	b
	jp	c,l4958
	ld	a,b
	_LD.DE
l4958:
	ld	c,0
	push	bc
	call	l473c
	pop	bc
	pop	hl
	push	hl
	inc	hl
	ld	b,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,b
	ld	b,0
	add	hl,bc
	ld	b,h
	ld	c,l
	call	l46bc
	ld	l,a
	call	l489b
	pop	de
	call	l48ac
	jp	l46fd
;
; Function : RIGHT$(X$,I)
;
l4979:
	call	l49c1
	pop	de
	push	de
	ld	a,(de)
	sub	b
	jp	l494c
;
; Function : MID$(X$,I[,J])
;
l4983:
	ex	de,hl
	ld	a,(hl)
	call	l49c6
	inc	b
	dec	b
	jp	z,_ill.func	; Invalid if zero
	push	bc
	call	l4ae3
	pop	af
	ex	(sp),hl
	ld	bc,l4950
	push	bc
	dec	a
	cp	(hl)
	ld	b,0
	ret	nc
	ld	c,a
	ld	a,(hl)
	sub	c
	cp	e
	ld	b,a
	ret	c
	ld	b,e
	ret
;
; Funciton : VAL(X$)
;
l49a4:
	call	l48da
	jp	z,l1dd5
	ld	e,a
	inc	hl
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	push	hl
	add	hl,de
	ld	b,(hl)
	ld	(hl),d
	ex	(sp),hl
	push	bc
	dec	hl
	call	get.tok
	call	cnvdoub		; Convert double
	pop	bc
	pop	hl
	ld	(hl),b
	ret
l49c1:
	ex	de,hl
	call	ilcmp
	db	')'
l49c6:
	pop	bc
	pop	de
	push	bc
	ld	b,e
	ret
l49cb:
	call	get.tok
	call	l19fe
	call	get.type	; Get type
	ld	a,1
	push	af
	jp	z,l49ed		; .. got pointer
	pop	af
	call	get.byte	; Get byte
	or	a		; Verify not zero
	jp	z,_ill.func	; .. invalid if so
	push	af
	call	ilcmp
	db	','
	call	EXPR		; Get expression
	call	vrf.str		; Verify string follows
l49ed:
	call	ilcmp
	db	','
	push	hl
	ld	hl,($$ARG+4)
	ex	(sp),hl
	call	EXPR		; Get expression
	call	ilcmp
	db	')'
	push	hl
	call	str.adr		; Get address of string
	ex	de,hl
	pop	bc
	pop	hl
	pop	af
	push	bc
	ld	bc,l2757
	push	bc
	ld	bc,l1dd5
	push	bc
	push	af
	push	de
	call	l48ab
	pop	de
	pop	af
	ld	b,a
	dec	a
	ld	c,a
	cp	(hl)
	ld	a,0
	ret	nc
	ld	a,(de)
	or	a
	ld	a,b
	ret	z
	ld	a,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,b
	ld	b,0
	add	hl,bc
	sub	c
	ld	b,a
	push	bc
	push	de
	ex	(sp),hl
	ld	c,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	pop	hl
l4a34:
	push	hl
	push	de
	push	bc
l4a37:
	ld	a,(de)
	cp	(hl)
	jp	nz,l4a55
	inc	de
	dec	c
	jp	z,l4a4c
	inc	hl
	dec	b
	jp	nz,l4a37
	pop	de
	pop	de
	pop	bc
l4a49:
	pop	de
	xor	a
	ret
l4a4c:
	pop	hl
	pop	de
	pop	de
	pop	bc
	ld	a,b
	sub	h
	add	a,c
	inc	a
	ret
l4a55:
	pop	bc
	pop	de
	pop	hl
	inc	hl
	dec	b
	jp	nz,l4a34
	jp	l4a49
l4a60:
	call	ilcmp
	db	'('
	call	var.adr		; Get address of variable
	call	vrf.str		; Verify string follows
	push	hl
	push	de
	ex	de,hl
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	hl,(l0ac6)
	call	cp.r
	jp	c,l4a8d		; HL < DE
	ld	hl,(prg.base)	; Get base of program
	call	cp.r
	jp	nc,l4a8d	; HL >= DE
	pop	hl
	push	hl
	call	l46a3
	pop	hl
	push	hl
	call	l28c9
l4a8d:
	pop	hl
	ex	(sp),hl
	call	ilcmp
	db	','
	call	l2075
	or	a
	jp	z,_ill.func	; Invalid if zero
	push	af
	ld	a,(hl)
	call	l4ae3
	push	de
	call	l19f7
	push	hl
	call	str.adr		; Get address of string
	ex	de,hl
	pop	hl
	pop	bc
	pop	af
	ld	b,a
	ex	(sp),hl
	push	hl
	ld	hl,l2757
	ex	(sp),hl
	ld	a,c
	or	a
	ret	z
	ld	a,(hl)
	sub	b
	jp	c,_ill.func	; .. invalid
	inc	a
	cp	c
	jp	c,l4ac0
	ld	a,c
l4ac0:
	ld	c,b
	dec	c
	ld	b,0
	push	de
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,e
	add	hl,bc
	ld	b,a
	pop	de
	ex	de,hl
	ld	c,(hl)
	inc	hl
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ex	de,hl
	ld	a,c
	or	a
	ret	z
l4ad8:
	ld	a,(de)
	ld	(hl),a
	inc	de
	inc	hl
	dec	c
	ret	z
	dec	b
	jp	nz,l4ad8
	ret
l4ae3:
	ld	e,0ffh
	cp	')'
	jp	z,l4af1
	call	ilcmp
	db	','
	call	l2075
l4af1:
	call	ilcmp
	db	')'
	ret
;
; Function : FRE(0)
;            FRE("")
;
l4af6:
	call	get.type	; Get type
	jp	nz,l4b02	; .. not a pointer
	call	l48a8
	call	l4767
l4b02:
	ex	de,hl
	ld	hl,(l0ac6)
	ex	de,hl
	ld	hl,(mem.top)	; Get top of memory
	jp	l1dc2
l4b0d:
	ld	a,'?'
	call	putchar		; Give mark
	ld	a,' '
	call	putchar
	jp	gets		; .. then get line
;
;
;
l4b1a:
	call	getchar		; Get character
	cp	'A'-'@'		; Test line to be edited
	jp	nz,l4b7a	; .. nope
	ld	(hl),null	; Close line
	jp	l4b38
l4b27:
	ld	(hl),b
;
; Input line from input
;
gets:
	xor	a
	ld	(l0789),a
	xor	a
	ld	(l0be6),a
;
;
;
l4b30:
	call	getchar		; Get character
	cp	'A'-'@'		; Test line to be edited
	jp	nz,l4b6f	; .. nope
l4b38:
	call	fnl		; Give new line
	ld	hl,lffff
	jp	__EDIT		; .. edit line
;
;
;
l4b41:
;;
;; THIS WILL CHANGE THE DELETE KEY TO FUNCTION LIKE BACK SPACE.
;;	ld	a,bs
;;	jp	l4BBC
;;
	ld	a,(rub.flg)
	or	a		; Test in rubout state
	ld	a,'\'
	ld	(rub.flg),a	; .. force it
	jp	nz,l4b55	; .. yeap, was already in it
	dec	b
	jp	z,l4b27
	call	putchar		; .. print
	inc	b
l4b55:
	dec	b
	dec	hl
	jp	z,l4b69
	ld	a,(hl)
	call	putchar		; .. print
	jp	l4b1a
lxxx:
	dec	b
l4b62:
	dec	hl
	call	putchar		; .. print
	jp	nz,l4b1a
l4b69:
	call	putchar		; .. print
	call	fnl		; Give new line
l4b6f:
	ld	hl,$LINE	; Init line pointer
	ld	b,1		; .. count
	push	af
	xor	a
	ld	(rub.flg),a	; Set no rubout
	pop	af
;
;
;
l4b7a:
	ld	c,a		; Get character
	cp	rubout		; Test delete
	jp	z,l4b41		; .. yeap
	ld	a,(rub.flg)
	or	a		; Test in rubout state
	jp	z,l4b90		; .. nope
	ld	a,'\'
	call	putchar		; Close state
	xor	a
	ld	(rub.flg),a	; Set no rubout
l4b90:
	ld	a,c
	cp	bell		; Test bell
	jp	z,l4bfa		; .. yeap
	cp	CtrlC		; .. interrupt
	call	z,prCtrl	; .. yeap, echo
	scf
	ret	z		; .. yeap
	cp	cr		; .. test end of line
	jp	z,l4c3b		; .. yeap
	cp	tab		; .. or tab
	jp	z,l4bfa
	cp	lf		; .. new line
	jp	nz,l4bb4
	dec	b
	jp	z,gets
	inc	b
	jp	l4bfa
l4bb4:
	cp	'U'-'@'		; Test delete line
	call	z,prCtrl	; .. yeap, echo
	jp	z,gets
;;l4BBC:
	cp	bs		; Test backspace
	jp	nz,l4bd2
	dec	b
	jp	z,l4b30
	call	putchar
	ld	a,' '
	call	putchar
	ld	a,bs
	jp	l4b62
l4bd2:
	cp	'X'-'@'		; Test ??
	jp	nz,l4bdc
	ld	a,'#'
	jp	l4b69
l4bdc:
	cp	'R'-'@'		; Test list line
	jp	nz,l4bf5
	push	bc
	push	de
	push	hl
	ld	(hl),null	; .. close line
	call	fnl		; Give new line
	ld	hl,$LINE	; Init line pointer
	call	l20dc		; .. type line
	pop	hl
	pop	de
	pop	bc
	jp	l4b1a
l4bf5:
	cp	' '		; Test control
	jp	c,l4b1a		; .. yeap, skip
l4bfa:
	ld	a,b		; Test remainder
	or	a
	jp	nz,l4c18	; .. yeap
	push	hl
	ld	hl,(FP)		; Get file pointer
	ld	a,h
	or	l
	pop	hl
	ld	a,bell
	jp	z,l4c1c		; .. no file active
	ld	hl,$LINE	; Init line pointer
	call	l1428
	ex	de,hl
	ld	(dir.mode),hl	; Set direct mode
	jp	l115f
l4c18:
	ld	a,c
	ld	(hl),c		; Save character
	inc	hl		; .. bump line pointer
	inc	b		; .. as well as count
l4c1c:
	call	putchar
	sub	lf		; Test new line
	jp	nz,l4b1a
	ld	(colCON),a	; .. clear console column if so
	ld	a,cr
	call	putchar
l4c2c:
	call	getchar		; Get character
	or	a		; Test any
	jp	z,l4c2c		; .. nope, wait
	cp	cr		; Test new line
	jp	z,l4b1a		; .. yeap
	jp	l4b7a
l4c3b:
	ld	a,(l0be6)
	or	a
	jp	z,l421c
	xor	a
	ld	(hl),a
	ld	hl,l0961
	ret
l4c48:
	push	af
	ld	a,0
	ld	(l0be6),a
	pop	af
	cp	';'
	ret	nz
	ld	(l0be6),a
	jp	get.tok
;
; Statement : WHILE <expr]
;
l4c58:
	ld	(l0aa1),hl
	call	l24dd
	call	get.tok
	ex	de,hl
	call	l4cc1
	inc	sp
	inc	sp
	jp	nz,l4c6f
	add	hl,bc
	ld	sp,hl		; Set stack
	ld	(curstk),hl	; .. save
l4c6f:
	ld	hl,(dir.mode)	; Get direct mode
	push	hl
	ld	hl,(l0aa1)
	push	hl
	push	de
	jp	l4ca1
;
; Statement : WEND
;
l4c7b:
	jp	nz,l0cc9
	ex	de,hl
	call	l4cc1
	jp	nz,l4ceb
	ld	sp,hl		; Set stack
	ld	(curstk),hl	; .. save
	ex	de,hl
	ld	hl,(dir.mode)	; Get direct mode
	ex	de,hl		;			*** ?????
	ex	de,hl		;			*** ?????
	ld	(direct_3),hl	; .. save
	ex	de,hl
	inc	hl
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ld	(dir.mode),hl	; Set direct mode
	ex	de,hl
l4ca1:
	call	EXPR		; Get expression
	push	hl
	call	l2886
	pop	hl
	jp	z,l4cb5
	ld	bc,l00b4
	ld	b,c
	push	bc
	inc	sp
	jp	l12a0
l4cb5:
	ld	hl,(direct_3)	; Get direct mode
	ld	(dir.mode),hl	; .. set it
	pop	hl
	pop	bc
	pop	bc
	jp	l12a0
l4cc1:
	ld	hl,l0004
	add	hl,sp
l4cc5:
	ld	a,(hl)
	inc	hl
	ld	bc,l0082
	cp	c
	jp	nz,l4cd5
	ld	bc,l0010
	add	hl,bc
	jp	l4cc5
l4cd5:
	ld	bc,l00b4
	cp	c
	ret	nz
	push	hl
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	call	cp.r		; Compare HL:DE
	pop	hl
	ld	bc,l0006
	ret	z		; .. same
	add	hl,bc
	jp	l4cc5
l4ceb:
	ld	de,30		; WEND without WHILE
	jp	_error
;
; Statement : CALL <variable name>[<arg list>]
;
l4cf1:
	ld	a,80h
	ld	(l0aa5),a
	call	var.adr		; Get address of variable
	push	hl
	ex	de,hl
	call	get.type	; Get type
	call	l28ee
	call	l22db
	ld	(l0be6),hl
	ld	c,32
	call	tstmem		; Verify enough memory
	pop	de
	ld	hl,-2*32	;;lffc0
	add	hl,sp
	ld	sp,hl
	ex	de,hl
	ld	c,' '
	dec	hl
	call	get.tok
	ld	(@@ptr),hl	; .. save token pointer
	jp	z,l4d5f
	call	ilcmp
	db	'('
l4d23:
	push	bc
	push	de
	call	var.adr		; Get address of variable
	ex	(sp),hl
	ld	(hl),e
	inc	hl
	ld	(hl),d
	inc	hl
	ex	(sp),hl
	pop	de
	pop	bc
	ld	a,(hl)
	cp	','
	jp	nz,l4d3d
	dec	c
	call	get.tok
	jp	l4d23
l4d3d:
	call	ilcmp
	db	')'
	ld	(@@ptr),hl	; .. save token pointer
	ld	a,'!'
	sub	c
	pop	hl
	dec	a
	jp	z,l4d5f
	pop	de
	dec	a
	jp	z,l4d5f
	pop	bc
	dec	a
	jp	z,l4d5f
	push	bc
	push	hl
	ld	hl,l0002
	add	hl,sp
	ld	b,h
	ld	c,l
	pop	hl
l4d5f:
	push	hl
	ld	hl,l4d6a
	ex	(sp),hl
	push	hl
	ld	hl,(l0be6)
	ex	(sp),hl
	ret
l4d6a:
	ld	hl,(curstk)	; Get stack
	ld	sp,hl		; .. set it
	ld	hl,(@@ptr)	; Get back token pointer
	jp	l12a0
;
; Statement : CHAIN [MERGE] <filename>
;                   [,[line number expr>][,ALL][,DELETE <range>]]
;
l4d74:
	xor	a
	ld	(l0bed),a
	ld	(l0bee),a
	ld	a,(hl)
	ld	de,l00c5
	cp	e
	jp	nz,l4d87
	ld	(l0bed),a
	inc	hl
l4d87:
	dec	hl
	call	get.tok
	call	l5294
	push	hl
	ld	hl,l0000
	ld	(l0bf4),hl
	pop	hl
	dec	hl
	call	get.tok
	jp	z,l4e07
	call	ilcmp
	db	','
	cp	','
	jp	z,l4db8
	call	EXPR		; Get expression
	push	hl
	call	l22db
	ld	(l0bf4),hl
	pop	hl
	dec	hl
	call	get.tok
	jp	z,l4e07
l4db8:
	call	ilcmp
	db	','
	ld	de,l00aa
	cp	e
	jp	z,l4ddb
	call	ilcmp
	db	'A'
	call	ilcmp
	db	'L'
	call	ilcmp
	db	'L'
	jp	z,l4f4e
	call	ilcmp
	db	','
	cp	e
	jp	nz,l0cc9
	or	a
l4ddb:
	push	af
	ld	(l0bee),a
	call	get.tok
	call	l0ed8
	push	bc
	call	l2435
	pop	bc
	pop	de
	push	bc
	ld	h,b
	ld	l,c
	ld	(l0bf1),hl
	call	l0ef8
	jp	nc,l4e00
	ld	d,h
	ld	e,l
	ld	(l0bef),hl
	pop	hl
	call	cp.r		; Compare HL:DE
l4e00:
	jp	nc,_ill.func	; .. HL >= DE, invalid call
	pop	af
	jp	nz,l4f4e
l4e07:
	ld	hl,(dir.mode)	; Get direct mode
	push	hl
	ld	hl,(prg.base)	; .. and base of program
	dec	hl
l4e0f:
	inc	hl
	ld	a,(hl)
	inc	hl
	or	(hl)
	jp	z,l4ecf
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	ld	(dir.mode),hl	; Set direct mode
	ex	de,hl
l4e1f:
	call	get.tok
l4e22:
	or	a
	jp	z,l4e0f
	cp	':'
	jp	z,l4e1f
	ld	de,l00b8
	cp	e
	jp	z,l4e3c
	call	get.tok
	call	_DATA		; Process DATA
	dec	hl
	jp	l4e1f
l4e3c:
	call	get.tok
	jp	z,l4e22
l4e42:
	push	hl
	ld	a,1
	ld	(l0aa5),a
	call	l3a89
	jp	z,l4ea2
	ld	a,b
	or	80h
	ld	b,a
	xor	a
	call	l3b92
	ld	a,0
	ld	(l0aa5),a
	jp	nz,l4e68
	ld	a,(hl)
	cp	'('
	jp	nz,l4e6e
	pop	af
	jp	l4ebe
l4e68:
	ld	a,(hl)
	cp	'('
	jp	z,_ill.func	; Invalid if paren
l4e6e:
	pop	hl
	call	l3a89
	ld	a,d
	or	e
	jp	nz,l4e8f
	ld	a,b
	or	80h
	ld	b,a
	ld	de,l4e8a
	push	de
	ld	de,l3a8c
	push	de
	ld	a,($ARGLEN)	; Get length of arg
	ld	d,a
	jp	l3a29
l4e8a:
	ld	a,d
	or	e
	jp	z,_ill.func	; Invalid if zero
l4e8f:
	push	hl
	ld	b,d
	ld	c,e
	ld	hl,l4eb1
	push	hl
l4e96:
	dec	bc
l4e97:
	ld	a,(bc)
	dec	bc
	or	a
	jp	m,l4e97
	ld	a,(bc)
	or	MSB		; Set bit
	ld	(bc),a
	ret
l4ea2:
	ld	(l0aa5),a
	ld	a,(hl)
	cp	'('
	jp	nz,l4e6e
	ex	(sp),hl
	dec	bc
	dec	bc
	call	l4e96
l4eb1:
	pop	hl
	dec	hl
	call	get.tok
	jp	z,l4e22
	cp	'('
	jp	nz,l4ec8
l4ebe:
	call	get.tok
	call	ilcmp
	db	')'
	jp	z,l4e22
l4ec8:
	call	ilcmp
	db	','
	jp	l4e42
l4ecf:
	pop	hl
	ld	(dir.mode),hl	; Set direct mode
	ex	de,hl
	ld	hl,(l0ac4)
	ex	de,hl
	ld	hl,(prg.top)	; Get top of program
l4edb:
	call	cp.r
	jp	z,l4f23		; HL = DE
	push	hl
	ld	c,(hl)
	inc	hl
	inc	hl
	ld	a,(hl)
	or	a
	push	af
	and	7fh
	ld	(hl),a
	inc	hl
	call	l3c9a
	ld	b,0
	add	hl,bc
	pop	af
	pop	bc
	jp	m,l4edb
	push	bc
	call	l4f07
	ld	hl,(l0ac4)
	add	hl,de
	ld	(l0ac4),hl
	ex	de,hl
	pop	hl
	jp	l4edb
l4f07:
	ex	de,hl
	ld	hl,(l0ac6)	; Get top
l4f0b:
	call	cp.r		; Compare HL:DE
	ld	a,(de)		; .. unpack
	ld	(bc),a
	inc	de
	inc	bc
	jp	nz,l4f0b	; .. until top reached
	ld	a,c
	sub	l
	ld	e,a
	ld	a,b
	sbc	a,h
	ld	d,a
	dec	de
	dec	bc
	ld	h,b
	ld	l,c
	ld	(l0ac6),hl
	ret
l4f23:
	ex	de,hl
	ld	hl,(l0ac6)
	ex	de,hl
l4f28:
	call	cp.r
	jp	z,l4f4e		; HL = DE
	push	hl
	inc	hl
	inc	hl
	ld	a,(hl)
	or	a
	push	af
	and	7fh
	ld	(hl),a
	inc	hl
	call	l3c9a
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	add	hl,bc
	pop	af
	pop	bc
	jp	m,l4f28
	push	bc
	call	l4f07
	ex	de,hl
	pop	hl
	jp	l4f28
l4f4e:
	ld	hl,(prg.top)	; Get top of program
l4f51:
	ex	de,hl
	ld	hl,(l0ac4)
	ex	de,hl
	call	cp.r
	jp	z,l4f76		; HL = DE
	ld	a,(hl)
	inc	hl
	inc	hl
	inc	hl
	push	af
	call	l3c9a
	pop	af
	cp	3
	jp	nz,l4f6e
	call	l4fae
	xor	a
l4f6e:
	ld	e,a
	ld	d,0
	add	hl,de
	jp	l4f51
l4f75:
	pop	bc
l4f76:
	ex	de,hl
	ld	hl,(l0ac6)
	ex	de,hl
	call	cp.r
	jp	z,l4fd8		; HL = DE
	ld	a,(hl)
	inc	hl
	inc	hl
	push	af
	inc	hl
	call	l3c9a
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	pop	af
	push	hl
	add	hl,bc
	cp	3
	jp	nz,l4f75
	ld	(l0a9d),hl
	pop	hl
	ld	c,(hl)
	ld	b,0
	add	hl,bc
	add	hl,bc
	inc	hl
l4f9f:
	ex	de,hl
	ld	hl,(l0a9d)
	ex	de,hl
	call	cp.r
	jp	z,l4f76		; HL = DE
	ld	bc,l4f9f
	push	bc
l4fae:
	ld	a,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	or	a
	ret	z
	push	hl
	ld	hl,(prg.top)	; Get top of program
	call	cp.r		; Compare HL:DE
	pop	hl
	ret	c		; HL < DE
	push	hl
	ld	hl,(prg.base)	; Get base of program
	call	cp.r		; Compare HL:DE
	pop	hl
	ret	nc		; HL >= DE
	push	hl
	dec	hl
	dec	hl
	dec	hl
	push	hl
	call	l46a3
	pop	hl
	ld	b,3
	call	l28cd
	pop	hl
	ret
l4fd8:
	call	l4767
	ld	hl,(l0ac6)
	ld	b,h
	ld	c,l
	ex	de,hl
	ld	hl,(prg.top)	; Get top of program
	ex	de,hl
	ld	hl,(l0ac4)
	ld	a,l
	sub	e
	ld	l,a
	ld	a,h
	sbc	a,d
	ld	h,a
	ld	(l0bb8),hl
	ld	hl,(mem.top)	; Get top of memory
	ld	(l0be8),hl
	call	l42b9
	ld	h,b
	ld	l,c
	dec	hl
	ld	(mem.top),hl	; .. save top
	ld	a,(l0bee)
	or	a
	jp	z,l501b
	ld	hl,(l0bf1)
	ld	b,h
	ld	c,l
	ld	hl,(l0bef)
	call	l22a2
	ld	(l0ac4),hl
	ld	(l0ac6),hl
	call	l0eab
l501b:
	ld	a,1
	ld	(l0bf3),a
	ld	a,(l0bed)
	or	a
	jp	nz,l536d
	ld	a,(opnfiles)	; Get max files
	ld	(opnsave),a	; .. save
	jp	l52b9
l5030:
	xor	a
	ld	(l0bf3),a
	ld	(l0bed),a
	ld	hl,(prg.top)	; Get top of program
	ld	b,h
	ld	c,l
	ld	hl,(l0bb8)
	add	hl,bc
	ld	(l0ac4),hl
	ld	hl,(mem.top)	; Get top of memory
	inc	hl
	ex	de,hl
	ld	hl,(l0be8)
	ld	(mem.top),hl	; Set top
l504e:
	call	cp.r		; Compare HL:DE
	ld	a,(de)		; .. unpack
	ld	(bc),a
	inc	de
	inc	bc
	jp	nz,l504e	; .. until top reached
	dec	bc
	ld	h,b
	ld	l,c
	ld	(l0ac6),hl
	ex	de,hl
	ld	hl,(l0bf4)
	ex	de,hl
	ld	hl,(prg.base)	; Get base of program
	dec	hl
	ld	a,d
	or	e
	jp	z,l12a0
	call	l0ef8
	jp	nc,l14cc
	dec	bc
	ld	h,b
	ld	l,c
	jp	l12a0
	jp	_DATA		; Process DATA
;
; Statement : WRITE [<list of exprs>]
;             WRITE#<file number>,<list of exprs>
;
l507b:
	ld	c,2
	call	l510d
	dec	hl
	call	get.tok
	jp	z,l50da
l5087:
	call	EXPR		; Get expression
	push	hl
	call	get.type	; Get type
	jp	z,l50ca		; .. got pointer
	call	l3129
	call	l46c7
	ld	hl,($$ARG+4)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	a,(de)
	cp	' '
	jp	nz,l50aa
	inc	de
	ld	(hl),d
	dec	hl
	ld	(hl),e
	dec	hl
	dec	(hl)
l50aa:
	call	l4726
l50ad:
	pop	hl
	dec	hl
	call	get.tok
	jp	z,l50da
	cp	';'
	jp	z,l50bf
	call	ilcmp
	db	','
	dec	hl
l50bf:
	call	get.tok
	ld	a,','
	call	putchar
	jp	l5087
l50ca:
	ld	a,'"'
	call	putchar
	call	l4726
	ld	a,'"'
	call	putchar
	jp	l50ad
l50da:
	push	hl
	ld	hl,(FP)		; Get file pointer
	ld	a,h
	or	l
	jp	z,l5104		; .. no file active
	ld	a,(hl)		; Get mode
	cp	3		; Test 'R'
	jp	nz,l5104	; .. nope
	call	l5cc2
	ld	a,l
	sub	e
	ld	l,a
	ld	a,h
	sbc	a,d
	ld	h,a
	ld	de,lfffe
	add	hl,de
	jp	nc,l5104
l50f9:
	ld	a,' '
	call	putchar
	dec	hl
	ld	a,h
	or	l
	jp	nz,l50f9
l5104:
	pop	hl
	call	fnl		; Give new line
	jp	clr.FP		; Reset file I/O
;
; Open file number for read
;
l510b:
	ld	c,1
;
; Open file number for I/O
; ENTRY	Reg C holds file mode
;
l510d:
	cp	'#'
	ret	nz
	push	bc
	call	l512a
	pop	de
	cp	e
	jp	z,l511e
	cp	3		; Verify random
	jp	nz,l0ca0	; .. bad file mode if not
l511e:
	call	ilcmp
	db	','
l5122:
	ld	d,b
	ld	e,c
	ex	de,hl
	ld	(FP),hl		; .. set file pointer
	ex	de,hl
	ret
l512a:
	dec	hl
	call	get.tok
	cp	'#'
	call	z,get.tok
	call	EXPR		; Get expression
;
; Get file number from token and test it
; EXIT	Accu holds file type
;	Zero set if file passive
;	Reg BC holds file pointer
;
filnum:
	call	get.byte	; Get byte as file number
;
; Test file number in Accu - Exit as above
;
fn.a:
	ld	e,a		; Save number
;
; Test file number in reg E - Exit as above
;
fn.e:
	ld	a,(opnfiles)	; Get max number of open files
	cp	e
	jp	c,l0ca6		; .. too many files open
	ld	d,0
	push	hl
	ld	hl,F.arr	; Point into file array
	add	hl,de
	add	hl,de
	ld	c,(hl)		; .. fetch pointer
	inc	hl
	ld	b,(hl)
	ld	a,(bc)		; Get file number
	or	a		; .. set flag
	pop	hl
	ret
;
; ENTRY	Reg E holds file number
; EXIT	Reg DE points to ???
;
l5150:
	call	fn.e		; Get file state
	ld	hl,l0029
	cp	3		; Test 'R'
	jp	nz,l515e	; .. nope
	ld	hl,l00b2
l515e:
	add	hl,bc
	ex	de,hl
	ret
;
; Function : MKI$(<integer expression>)
;
l5161:
	ld	a,2
	_LD.BC
;
; Function : MKS$(<single precision expression>)
;
l5164:
	ld	a,4
	_LD.BC
;
; Function : MKD$(<double precision expression>)
;
l5167:
	ld	a,8
	push	af
	call	l1fac
	pop	af
	call	l46b9
	ld	hl,(STR.arr+10*3+1)
	call	l28f7
	jp	l48fc
;
; Function : CVI(<2-byte string>)
;
l517a:
	ld	a,2-1
	_LD.BC
;
; Function : CVS(<4-byte string>)
;
l517d:
	ld	a,4-1
	_LD.BC
;
; Function : CVD(<8-byte string>)
;
l5180:
	ld	a,8-1
	push	af		; Save length
	call	str.adr		; Get address of string
	pop	af
	cp	(hl)		; .. compare length
	jp	nc,_ill.func	; .. invalid call
	inc	a
	ld	($ARGLEN),a	; .. set length
	inc	hl
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	jp	l28ee
l5197:
	call	get.type	; Get type
	ld	bc,l198f
	ld	de,l2c20
	jp	nz,l51bb	; .. no pointer
	ld	e,d
	jp	l51bb
l51a7:
	call	l510b		; Open file for read
	call	var.adr		; Get address of variable
	call	vrf.str		; Verify string follows
	ld	bc,clr.FP	; Reset I/O routine
	push	bc		; .. for return address
	push	de
	ld	bc,l1512
	xor	a
	ld	d,a
	ld	e,a
l51bb:
	push	af
	push	bc
	push	hl
l51be:
	call	fgetc		; Get character from file
	jp	c,l0cac		; .. end of file
	cp	' '
	jp	nz,l51ce
	inc	d
	dec	d
	jp	nz,l51be
l51ce:
	cp	'"'
	jp	nz,l51e3
	ld	b,a
	ld	a,e
	cp	','
	ld	a,b
	jp	nz,l51e3
	ld	d,b
	ld	e,b
	call	fgetc		; Get from file
	jp	c,l5231		; .. end of file
l51e3:
	ld	hl,$LINE	; Init line
	ld	b,255		; .. and length
l51e8:
	ld	c,a
	ld	a,d
	cp	'"'
	ld	a,c
	jp	z,l521c
	cp	0dh
	push	hl
	jp	z,l5251
	pop	hl
	cp	lf
	jp	nz,l521c
	ld	c,a
	ld	a,e
	cp	','
	ld	a,c
	call	nz,l528a
	call	fgetc		; Get from file
	jp	c,l5231		; .. end of file
	cp	cr
	jp	nz,l521c
	ld	a,e
	cp	' '
	jp	z,l522b
	cp	','
	ld	a,cr
	jp	z,l522b
l521c:
	or	a
	jp	z,l522b
	cp	d
	jp	z,l5231
	cp	e
	jp	z,l5231
	call	l528a
l522b:
	call	fgetc		; Get from file
	jp	nc,l51e8	; .. get next
l5231:
	push	hl
	cp	'"'
	jp	z,l523c
	cp	' '
	jp	nz,l5264
l523c:
	call	fgetc		; Get from file
	jp	c,l5264		; .. end of file
	cp	' '
	jp	z,l523c
	cp	','
	jp	z,l5264
	cp	cr
	jp	nz,l525c
l5251:
	call	fgetc		; Get from file
	jp	c,l5264		; .. end of file
	cp	lf
	jp	z,l5264
l525c:
	ld	hl,(FP)		; Get file pointer
	ld	bc,l0028
	add	hl,bc
	inc	(hl)
l5264:
	pop	hl
l5265:
	ld	(hl),null
	ld	hl,l0961
	ld	a,e
	sub	' '
	jp	z,l5278
	ld	b,d
	ld	d,0
	call	l46cb
	pop	hl
	ret
l5278:
	call	get.type	; Get type
	push	af
	call	get.tok
	pop	af
	push	af
	call	c,cnvnum	; Get number if not double
	pop	af
	call	nc,cnvdoub	; .. got double
	pop	hl
	ret
;
;
;
l528a:
	or	a
	ret	z
	ld	(hl),a
	inc	hl
	dec	b
	ret	nz
	pop	bc
	jp	l5265
;
;
;
l5294:
	ld	d,1		; Set file mode "I"
l5296:
	xor	a
	jp	l58fe
;
; Load file given in command line
;
_FRUN:
	_OR
;
; Statement : LOAD <filename>[,R]
;
l529b::
	xor	a
	push	af
	call	l5294
	ld	a,(opnfiles)	; Get max number of files open
	ld	(opnsave),a	; .. save
	dec	hl
	call	get.tok		; Get next
	jp	z,l52be		; .. end, so load it
	call	ilcmp		; Find ','
	db	','
	call	ilcmp		; .. and 'R'
	db	'R'
	jp	nz,l0cc9
	pop	af
l52b9:
	xor	a
	ld	(opnfiles),a	; .. clear max open files
	_OR
l52be:
	pop	af
	ld	(l079e),a
	ld	hl,DMA		; Set buffer
	ld	(hl),0		; .. clear first byte
	ld	(F.arr),hl	; .. save buffer
	call	l4321
	ld	a,(opnsave)
	ld	(opnfiles),a	; Reset max open files
	ld	hl,(F.ptr)	; Get base file pointer
	ld	(F.arr),hl	; .. into array
	ld	(FP),hl		; .. and file pointer
	ld	hl,(dir.mode)	; Get direct mode
	inc	hl
	ld	a,h
	and	l
	inc	a
	jp	nz,l52e9	; .. not direct
	ld	(dir.mode),hl	; .. save direct mode
l52e9:
	call	fgetc		; Get from file
	jp	c,l0da2		; .. error
	cp	0feh		; Test protected
	jp	nz,l52fa
	ld	(_prot),a	; .. set as flag
	jp	l52fe
l52fa:
	inc	a		; Test tokenized
	jp	nz,l537f	; .. nope, pure ASCII
l52fe:
	ld	hl,(prg.base)	; Get base of program
l5301:
	ex	de,hl
	ld	hl,(mem.top)	; .. get top of memory
	ld	bc,-86		;;lffaa
	add	hl,bc
	call	cp.r		; Compare HL:DE
	ex	de,hl
	jp	c,l5356		; HL < DE, overflow
	call	fget		; Get from file
	ld	(hl),a
	inc	hl
	jp	nc,l5301	; .. loop till end
;::
	ld	(prg.top),hl	; Save top
	ld	a,(_prot)	; Test file protected
	or	a
	call	nz,funprot	; .. yeap, unprotect it
	call	l0eab
	inc	hl
	inc	hl
	ld	(prg.top),hl	; .. save top of program
	ld	hl,opnfiles
	ld	a,(hl)		; Get max open files
	ld	(opnsave),a	; .. save
	ld	(hl),0		; .. set passive
	call	l4337
	ld	a,(opnsave)
	ld	(opnfiles),a	; .. reset max open files
	ld	a,(l0bf3)
	or	a
	jp	nz,l5030
	ld	a,(l079e)
	or	a
	jp	z,l0d87
	jp	l12a0
;
;
;
l534d:
	call	clr.FP		; Reset file I/O
	call	l5606
	jp	l43c9
;
;
;
l5356:
	call	l4321
	jp	l42dd		; .. overflow
;
; Statement : MERGE <filename>
;
l535c:
	pop	bc
	call	l5294
	dec	hl
	call	get.tok
	jp	z,l536d
	call	l534d
	jp	l0cc9
l536d:
	xor	a
	ld	(l079e),a
	call	fgetc		; Get from file
	jp	c,l0da2		; .. end of file
	inc	a		; Verify not 0xFF or 0xFE
	jp	z,l0ca0		; .. bad file mode otherwise
	inc	a
	jp	z,l0ca0
l537f:
	ld	hl,(FP)		; Get file pointer
	ld	bc,l0028
	add	hl,bc
	inc	(hl)
	jp	l0da2
l538a:
	push	hl
	ld	hl,(FP)		; Get file pointer
	ld	a,h
	or	l
	ld	de,66		; Direct statement in file
	jp	nz,_error
	pop	hl
	jp	l12e5
;
; Statement : SAVE <filename> [,{A|P}]
;
l539a:
	ld	d,2
	call	l5296
	dec	hl
	call	get.tok		; Get next
	jp	z,l53b6		; .. simple save
	call	ilcmp		; Test ',P'
	db	','
	cp	'P'
	jp	z,l5cd1
	call	ilcmp		; .. or ',A'
	db	'A'
	jp	l2089
l53b6:
	call	l2392
	call	l5d65
	ld	a,0ffh		; Set token marker
l53be:
	call	fput		; Put indicator to file
	ex	de,hl
	ld	hl,(prg.top)	; Get top of program
	ex	de,hl
	ld	hl,(prg.base)	; .. and base
l53c9:
	call	cp.r
	jp	z,l534d		; HL = DE
	ld	a,(hl)
	inc	hl
	push	de
	call	fput		; Put tokens to file
	pop	de
	jp	l53c9
;
; Statement : CLOSE [[#]<file number>[,[#]<file number>...]]
;
l53d9:
	ld	bc,l5606
	ld	a,(opnfiles)	; Get max open files
	jp	nz,l53fc	; .. aha, not all files
	push	hl
l53e3:
	push	bc
	push	af
	ld	de,l53eb
	push	de
	push	bc
	ret
l53eb:
	pop	af
	pop	bc
	dec	a
	jp	p,l53e3
	pop	hl
	ret
l53f3:
	pop	bc
	pop	hl
	ld	a,(hl)
	cp	','
	ret	nz
	call	get.tok
l53fc:
	push	bc
	ld	a,(hl)
	cp	'#'
	call	z,get.tok
	call	l2075
	ex	(sp),hl
	push	hl
	ld	de,l53f3
	push	de
	jp	(hl)
;
;
;
l540d:
	push	de
	push	bc
	xor	a		; Set flag for all files
	call	l53d9
	pop	bc
	pop	de
	xor	a
	ret
;
; Statement : FIELD [#]<file number>,<field width> AS <string var> ...
;
l5417:
	call	l512a
	jp	z,l0ca6
	sub	3		; Verify random access
	jp	nz,l0ca0	; Bad file mode if not
	ex	de,hl
	ld	hl,l00a9
	add	hl,bc
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ld	(l0be6),hl
	ld	hl,l0000
	ld	(l5d6f),hl
	ld	a,h
	ex	de,hl
	ld	de,l00b2
l5439:
	ex	de,hl
	add	hl,bc
	ld	b,a
	ex	de,hl
	ld	a,(hl)
	cp	','
	ret	nz
	push	de
	push	bc
	call	l2072
	push	af
	call	ilcmp
	db	'A'
	call	ilcmp
	db	'S'
	call	var.adr		; Get address of variable
	call	vrf.str		; Verify string follows
	pop	af
	pop	bc
	ex	(sp),hl
	ld	c,a
	push	de
	push	hl
	ld	hl,(l5d6f)
	ld	b,0
	add	hl,bc
	ld	(l5d6f),hl
	ex	de,hl
	ld	hl,(l0be6)
	call	cp.r
	jp	c,l0cb8		; HL < DE
	pop	hl
	pop	de
	ex	de,hl
	ld	(hl),c
	inc	hl
	ld	(hl),e
	inc	hl
	ld	(hl),d
	pop	hl
	jp	l5439
;
; Statement : RSET <string variable>=<string expr>
;
l547a:
	_OR
;
; Statement : LSET <string variable>=<string expr>
;
l547b:
	scf
	push	af
	call	var.adr		; Get address of variable
	call	vrf.str		; Verify string follows
	push	de
	call	l19f7
	pop	bc
	ex	(sp),hl
	push	hl
	push	bc
	call	str.adr		; Get address of string
	ld	b,(hl)
	ex	(sp),hl
	ld	a,(hl)
	ld	c,a
	push	bc
	push	hl
	push	af
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	or	a
	jp	z,l54fc
	ld	hl,(prg.base)	; Get base of program
	call	cp.r
	jp	nc,l54d7	; HL >= DE
	ld	hl,(prg.top)	; Get top of program
	call	cp.r
	jp	c,l54d7		; HL < DE
	ld	e,c
	ld	d,0
	ld	hl,(l0ac6)
	add	hl,de
	ex	de,hl
	ld	hl,(mem.top)	; Get top of memory
	call	cp.r
	jp	c,l5510		; HL < DE
	pop	af
l54c1:
	ld	a,c
	call	l473c
	pop	hl
	pop	bc
	ex	(sp),hl
	push	de
	push	bc
	call	str.adr		; Get address of string
	pop	bc
	pop	de
	ex	(sp),hl
	push	bc
	push	hl
	inc	hl
	push	af
	ld	(hl),e
	inc	hl
	ld	(hl),d
l54d7:
	pop	af
	pop	hl
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	pop	bc
	pop	hl
	inc	hl
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ld	a,c
	cp	b
	jp	nc,l54ea
	ld	b,a
l54ea:
	sub	b
	ld	c,a
	pop	af
	call	nc,l5506
	inc	b
l54f1:
	dec	b
	jp	z,l5501
	ld	a,(hl)
	ld	(de),a
	inc	hl
	inc	de
	jp	l54f1
l54fc:
	pop	bc
	pop	bc
	pop	bc
	pop	bc
l5500:
	pop	bc
l5501:
	call	c,l5506
	pop	hl
	ret
l5506:
	ld	a,' '
	inc	c
l5509:
	dec	c
	ret	z
	ld	(de),a
	inc	de
	jp	l5509
l5510:
	pop	af
	pop	hl
	pop	bc
	ex	(sp),hl
	ex	de,hl
	jp	nz,l5521
	push	bc
	ld	a,b
	call	l46b9
	call	l46fd
	pop	bc
l5521:
	ex	(sp),hl
	push	bc
	push	hl
	jp	l54c1
l5527:
	call	get.tok
	call	ilcmp
	db	'$'
	call	ilcmp
	db	'('
	call	l2075
	push	de
	ld	a,(hl)
	cp	','
	jp	nz,l554b
	call	get.tok
	call	l512a
	cp	2		; Exclude 'O'
	jp	z,l0ca0		; .. bad file mode
	call	l5122
	xor	a
l554b:
	push	af
	call	ilcmp
	db	')'
	pop	af
	ex	(sp),hl
	push	af
	ld	a,l
	or	a
	jp	z,_ill.func	; Invalid if zero
	push	hl
	call	l46b9
	ex	de,hl
	pop	bc
l555e:
	pop	af
	push	af
	jp	z,l5585
	call	l4299
	jp	nz,l556c
	call	conin		; Get character from console
l556c:
	cp	CtrlC		; Test break
	jp	z,l557e		; .. yeap
l5571:
	ld	(hl),a
	inc	hl
	dec	c
	jp	nz,l555e
	pop	af
	call	clr.FP		; Reset file I/O
	jp	l46fd
l557e:
	ld	hl,(curstk)	; Get stack
	ld	sp,hl		; .. set it
	jp	l4419
l5585:
	call	fgetc		; Get from file
	jp	c,l0cac		; .. error on eof
	jp	l5571
;
; Function : EOF(<file number>)
;
l558e:
	call	filnum		; Get file number
	jp	z,l0ca6		; .. bad file number
	cp	2		; Exclude 'O'
	jp	z,l0ca0		; .. bad file mode
l5599:
	ld	hl,l0027
	add	hl,bc
	ld	a,(hl)
	or	a
	jp	z,l55c3
	ld	a,(bc)
	cp	3
	jp	z,l55c3
	inc	hl
	ld	a,(hl)
	or	a
	jp	nz,l55b8
	push	bc
	ld	h,b
	ld	l,c
	call	l577d
	pop	bc
	jp	l5599
l55b8:
	ld	a,reclng
	sub	(hl)
	ld	c,a
	ld	b,0
	add	hl,bc
	inc	hl
	ld	a,(hl)
	sub	eof
l55c3:
	sub	1
	sbc	a,a
	jp	l287f
;
; Write record to file
;
l55c9:
	ld	d,b
	ld	e,c
	inc	de
l55cc:
	ld	hl,l0027
	add	hl,bc
	push	bc
	xor	a
	ld	(hl),a
	call	SetDskBuff	; Set disk buffer
	ld	a,(f_wr)	; Get write function
	call	l5a9e		; .. write
	cp	OSerr
	jp	z,l0cbb
	dec	a
	jp	z,l0c9d
	dec	a
	jp	nz,l55f5
	pop	de
	xor	a
	ld	(de),a
	ld	c,.close
	inc	de
	call	BDOS
	jp	l0c9a
l55f5:
	inc	a
	jp	z,l0cbb
	pop	bc
	ld	hl,l0025
	add	hl,bc
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	de
	ld	(hl),d
	dec	hl
	ld	(hl),e
	ret
;
;
;
l5606:
	call	fn.a		; Get state of file
	jp	z,l5636		; .. file is passive
	push	bc		; Save pointer
	ld	a,(bc)		; Get file number
	ld	d,b
	ld	e,c
	inc	de
	push	de
	cp	2		; Test 'O' ???
	jp	nz,l562c
	ld	hl,l5623
	push	hl
	push	hl
	ld	h,b
	ld	l,c
	ld	a,1ah
	jp	l5679
l5623:
	ld	hl,l0027
	add	hl,bc
	ld	a,(hl)
	or	a
	call	nz,l55cc
l562c:
	pop	de
	call	SetDskBuff	; Set disk buffer
	ld	c,.close
	call	BDOS
	pop	bc
l5636:
	ld	d,')'
	xor	a
l5639:
	ld	(bc),a
	inc	bc
	dec	d
	jp	nz,l5639
	ret
;
; Function : LOC(<file number>)
;
l5640:
	call	filnum		; Get file number
	jp	z,l0ca6		; .. bad file number
	cp	3
	ld	hl,l0026
	jp	nz,l5651
	ld	hl,l00ae
l5651:
	add	hl,bc
	ld	a,(hl)
	dec	hl
	ld	l,(hl)
	jp	l1dd7
;
; Function : LOF(<file number>)
;
l5658:
	call	filnum		; Get file number
	jp	z,l0ca6		; .. bad file number
	ld	hl,l0010
	add	hl,bc
	ld	a,(hl)
	jp	l1dd5
;
; Put character in Accu to file
;
fputc:
	pop	hl
	pop	af
fput:
	push	hl
	push	af
	ld	hl,(FP)		; Get file pointer
	ld	a,(hl)		; .. fetch mode
	cp	1
	jp	z,l4500		; .. 'I'
	cp	3
	jp	z,l5c65		; .. 'R'
	pop	af		; .. here on 'O'
l5679:
	push	de
	push	bc
	ld	b,h
	ld	c,l
	push	af
	ld	de,l0027
	add	hl,de
	ld	a,(hl)		; Get record pointer
	cp	reclng
	push	hl
	call	z,l55c9		; Write record if filled
	pop	hl
	inc	(hl)		; Bump record count
	ld	c,(hl)		; .. get for index
	ld	b,0
	inc	hl
	pop	af		; Get back character
	push	af
	ld	d,(hl)
	cp	cr
	ld	(hl),b
	jp	z,l569d
	add	a,0e0h
	ld	a,d
	adc	a,b
	ld	(hl),a
l569d:
	add	hl,bc		; Position buffer
	pop	af
	pop	bc
	pop	de
	ld	(hl),a		; .. save character
	pop	hl
	ret
;
;
;
l56a4:
	dec	de
	dec	hl
	ld	(hl),e
	inc	hl
	ld	(hl),d
	inc	hl
	ld	(hl),80h
	inc	hl
	ld	(hl),80h
	pop	hl
	ex	(sp),hl
	ld	b,h
	ld	c,l
	push	hl
	ld	a,(OSvers)	; Get OS version
	or	a
	jp	z,l56c8		; Not CP/M 2.x or 3.x
	ld	hl,l0022
	add	hl,bc
	ld	(hl),e
	inc	hl
	ld	(hl),d
	inc	hl
	ld	(hl),0
	jp	l570d
l56c8:
	ld	hl,l000d
	add	hl,bc
	ld	a,e
	rla
	ld	a,d
	rla
	ld	d,(hl)
	cp	d
	jp	z,l5705
	push	de
	push	af
	push	hl
	push	bc
	ld	de,DMA
	ld	c,.setdma
	call	BDOS
	pop	de
	push	de
	inc	de
	ld	c,.close
	call	BDOS
	pop	de
	pop	hl
	pop	af
	ld	(hl),a
	push	de
	inc	de
	ld	c,.open
	push	de
	call	BDOS
	pop	de
	inc	a
	jp	nz,l5703
	ld	c,.make
	call	BDOS
	inc	a
	jp	z,l0cbb
l5703:
	pop	bc
	pop	de
l5705:
	ld	hl,l0021
	add	hl,bc
	ld	a,e
	and	7fh
	ld	(hl),a
l570d:
	pop	hl
	ld	a,(l07a0)
	or	a
	jp	nz,l571a
	call	l577d
	pop	hl
	ret
l571a:
	ld	hl,l0021
	add	hl,bc
	ld	a,(hl)
	cp	7fh
	push	af
	ld	de,l0080
	ld	hl,l0029
	add	hl,bc
	push	de
	push	hl
	call	z,l573b
	call	l55c9
	pop	de
	pop	hl
	pop	af
	call	z,l573b
	pop	hl
	jp	clr.FP		; Reset file I/O
l573b:
	push	bc
	ld	b,80h
l573e:
	ld	a,(hl)
	inc	hl
	ld	(de),a
	inc	de
	dec	b
	jp	nz,l573e
	pop	bc
	ret
;
; Get byte from active file
; EXIT	Accu holds character
;	Carry set indicates end of file
;
fget::
	push	bc
	push	hl
l574a:
	ld	hl,(FP)		; Get file pointer
	ld	a,(hl)		; Fetch mode
	cp	3		; .. test 'R'
	jp	z,l5c96		; .. yeap
	ld	bc,l0028
	add	hl,bc
	ld	a,(hl)
	or	a
	jp	z,l5768
	dec	hl
	ld	a,(hl)
	inc	hl
	dec	(hl)
	sub	(hl)
	ld	c,a
	add	hl,bc		; Calculate buffer index
	ld	a,(hl)		; .. get character
	or	a
	pop	hl
	pop	bc
	ret
l5768:
	dec	hl
	ld	a,(hl)		; Test end of file
	or	a
	jp	z,l5774		; .. yeap
	call	l577a		; Read buffer
	jp	nz,l574a
l5774:
	scf
	pop	hl
	pop	bc
	ld	a,eof
	ret
;
; Read from actual file
;
l577a:
	ld	hl,(FP)		; Get file pointer
l577d:
	push	de
	ld	d,h
	ld	e,l
	inc	de
	ld	bc,l0025
	add	hl,bc		; Position pointer
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	bc		; .. bump
	dec	hl
	ld	(hl),c		; .. bring it back
	inc	hl
	ld	(hl),b
	inc	hl
	inc	hl
	push	hl
	ld	c,reclng	; Set length
l5792:
	inc	hl
	ld	(hl),0		; Clear buffer
	dec	c
	jp	nz,l5792
	call	SetDskBuff	; Set disk buffer
	ld	a,(f_rd)	; Get read function
	call	l5a9e		; .. read
	or	a
	ld	a,0
	jp	nz,l57aa
	ld	a,reclng
l57aa:
	pop	hl
	ld	(hl),a
	dec	hl
	ld	(hl),a
	or	a
	pop	de
	ret
;
; Set disk buffer from file pointer in ^HL
;
SetDskBuff:
	push	bc
	push	de
	push	hl
	ld	hl,l0028
	add	hl,de		; Position buffer
	ex	de,hl
	ld	c,.setdma
	call	BDOS		; .. set it
	pop	hl
	pop	de
	pop	bc
	ret
;
; Get character from active file
; EXIT	Accu holds character
;	Carry set on end of file
;
fgetc::
	call	fget		; Get byte from file
	ret	c		; .. end of file
	cp	eof		; Test end of file
	scf
	ccf
	ret	nz		; .. nope
	push	bc
	push	hl
	ld	hl,(FP)		; Get file pointer
	ld	bc,l0027
	add	hl,bc		; Position pointer
	ld	(hl),0		; .. clear value
	inc	hl
	ld	(hl),0
	scf			; Set end of file
	pop	hl
	pop	bc
	ret
;
; Parse file name
;
parse:
	call	EXPR		; Get expression
	push	hl
	call	str.adr		; Get address of string
	ld	a,(hl)		; .. length
	or	a
	jp	z,l0cb2		; .. empty
	push	af
	inc	hl
	ld	e,(hl)		; Fetch pointer
	inc	hl
	ld	h,(hl)
	ld	l,e
	ld	e,a		; Set length
	cp	2		; Test possible drive
	jp	c,l5800		; .. nope
	ld	c,(hl)		; Get possible drive
	inc	hl
	ld	a,(hl)
	dec	e
	cp	':'		; Test drive delimiter
	jp	z,l5804		; .. yeap
	dec	hl
	inc	e
l5800:
	dec	hl
	inc	e
	ld	c,'A'-1		; Set default drive
l5804:
	dec	e		; Test end
	jp	z,l5862
	ld	a,c
	and	11011111b	; Get upper case
	sub	'A'-1		; Get binary drive
	jp	c,l5862
	cp	'Z'-'A'+2
	jp	nc,l5862
	ld	bc,@@FCB	; Get FCB
	ld	(bc),a		; .. set drive
	inc	bc
	ld	d,_nam+_ext	; Set max
l581c:
	inc	hl
l581d:
	dec	e		; Count down
	jp	m,l5852		; .. end
	ld	a,(hl)
	cp	'.'		; Test delimiter
	jp	nz,l5830	; .. nope
	call	l583e		; .. fix name field
	pop	af
	scf
	push	af
	jp	l581c
l5830:
	ld	(bc),a		; ..save into FCB
	inc	bc
	inc	hl
	dec	d
	jp	nz,l581d
l5837:
	xor	a
	ld	(@@FCB+_EX),a	; .. clear extent
	pop	af
	pop	hl
	ret
;
;
;
l583e:
	ld	a,d
	cp	_nam+_ext	; Test empty name
	jp	z,l5862		; .. yeap
	cp	_ext
	jp	c,l5862
	ret	z
	ld	a,' '
	ld	(bc),a		; .. blank remainder
	inc	bc
	dec	d
	jp	l583e
;
;
;
l5852:
	inc	d		; Test FCB completely filled
	dec	d
	jp	z,l5837		; .. yeap
l5857:
	ld	a,' '
	ld	(bc),a		; .. blank remainder
	inc	bc
	dec	d
	jp	nz,l5857
	jp	l5837
l5862:
	jp	l0cb2
;
; Statement : NAME <old filename> AS <new filename>
;
l5865:
	call	parse		; Parse file
	push	hl
	ld	de,DMA
	ld	c,.setdma
	call	BDOS
	ld	de,@@FCB
	ld	c,.open
	call	BDOS		; Find old file
	inc	a
	jp	z,l0ca3
	ld	hl,l07ee
	ld	de,@@FCB
	ld	b,_drv+_nam+_ext
l5885:
	ld	a,(de)		; .. unpack old name
	ld	(hl),a
	inc	hl
	inc	de
	dec	b
	jp	nz,l5885
	pop	hl
	call	ilcmp		; Verify 'AS'
	db	'A'
	call	ilcmp
	db	'S'
	call	parse		; Parse file
	push	hl
	ld	a,(@@FCB)
	ld	hl,l07ee
	cp	(hl)
	jp	nz,_ill.func	; Invalid if not same
	ld	de,@@FCB
	ld	c,.open
	call	BDOS		; Test new file already there
	inc	a
	jp	nz,l0cbe	; .. yeap
	ld	c,.rename
	ld	de,l07ee
	call	BDOS		; Rename file
	pop	hl
	ret
;
; Statement : OPEN <mode>,[#]<file number>,<filename>[,<reclen>]
;
; Mode mapping:	'I' -> 1
;		'O' -> 2
;		'R' -> 3
;
_OPEN:
	ld	bc,clr.FP	; Reset file I/O routine
	push	bc		; .. for reset
	call	EXPR		; Get expression
	push	hl
	call	str.adr		; Get address of string
	ld	a,(hl)		; .. length
	or	a
	jp	z,l0ca0		; .. bad file mode if empty
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	a,(bc)		; Get mode
	and	11011111b	; .. as upper case
	ld	d,2
	cp	'O'		; Test output
	jp	z,l58e6
	ld	d,1
	cp	'I'		; .. input
	jp	z,l58e6
	ld	d,3
	cp	'R'		; .. random
	jp	nz,l0ca0	; .. bad file mode if none
l58e6:
	pop	hl
	call	ilcmp
	db	','
	push	de
	cp	'#'
	call	z,get.tok
	call	l2075
	call	ilcmp
	db	','
	ld	a,e
	or	a
	jp	z,l0ca6
	pop	de
;
; ENTRY	Reg D holds file mode
;	Accu holds file number
;
l58fe:
	ld	e,a		; Save file number
	push	de
	call	fn.a		; Test file active
	jp	nz,l0caf	; .. nope
	pop	de
	push	bc
	push	de
	call	parse		; Parse file
	pop	de
	pop	bc
	push	bc
	push	af
	ld	a,d
	call	l5acd		; Set up for random access
	pop	af
	ld	(@@ptr),hl	; Save token pointer
	jp	c,l5931
	ld	a,e
	or	a
	jp	nz,l5931
	ld	hl,@@FCB+_drv+_nam
	ld	a,(hl)		; Test extension
	cp	' '
	jp	nz,l5931	; .. yeap
	ld	(hl),'B'	; .. set '.BAS'
	inc	hl
	ld	(hl),'A'
	inc	hl
	ld	(hl),'S'
l5931:
	pop	hl
	ld	a,d
	push	af
	ld	(FP),hl		; .. save file pointer
	push	hl
	inc	hl
	ld	de,@@FCB
	ld	c,_drv+_nam+_ext
l593e:
	ld	a,(de)		; Unpack FCB
	ld	(hl),a
	inc	de
	inc	hl
	dec	c
	jp	nz,l593e
	xor	a
	ld	(hl),a
	ld	de,l0014
	add	hl,de
	ld	(hl),a
	pop	de
	push	de
	inc	de
	call	SetDskBuff	; Set disk buffer
	pop	hl
	pop	af
	push	af
	push	hl
	cp	2		; Test 'O'
	jp	nz,l596f	; .. nope
	push	de
	ld	c,.delete
	call	BDOS		; Delete old file
	pop	de
l5963:
	ld	c,.make
	call	BDOS		; Create new one
	inc	a
	jp	z,l0cbb
	jp	l5985
l596f:
	ld	c,.open
	call	BDOS		; Open file
	inc	a
	jp	nz,l5985	; .. got it
	pop	de
	pop	af
	push	af
	push	de
	cp	3		; Test 'R'
	jp	nz,l0ca3	; .. nope, error
	inc	de
	jp	l5963		; Create file
l5985:
	pop	de
	pop	af
	ld	(de),a		; Set file type
	push	de
	ld	hl,l0025
	add	hl,de
	xor	a
	ld	(hl),a		; Clear ???
	inc	hl
	ld	(hl),a
	inc	hl
	ld	(hl),a
	inc	hl
	ld	(hl),a
	pop	hl		; Get back file pointer
	ld	a,(hl)
	cp	3		; Test random
	jp	z,l59a8		; .. yeap, clear buffer
	cp	1		; Test read
	jp	nz,l43c9	; .. nope
	call	l577a		; Read buffer
	ld	hl,(@@ptr)	; Get token pointer
	ret
l59a8:
	ld	bc,l0029
	add	hl,bc		; Point to buffer
	ld	c,reclng
l59ae:
	ld	(hl),b		; .. clear buffer
	inc	hl
	dec	c
	jp	nz,l59ae
	jp	l43c9
;
; Statement : SYSTEM
;
l59b7:
	ret	nz
	call	l540d
l59bb:
	jp	OS
;
; Statement : RESET
;
l59be:
	ret	nz
	push	hl
	call	l540d
	ld	c,.retdsk
	call	BDOS		; Get logged drive
	push	af
	ld	c,.resdsk
	call	BDOS		; Reset entire system
	pop	af
	ld	e,a
	ld	c,.logdsk
	call	BDOS		; .. log current one
	pop	hl
	ret
;
; Statement : KILL <filename>
;
l59d7:
	call	parse		; Parse file
	push	hl
	ld	de,DMA
	ld	c,.setdma
	call	BDOS		; Set disk buffer
	ld	de,@@FCB
	push	de
	ld	c,.open
	call	BDOS		; Open file
	inc	a
	pop	de
	push	de
	push	af
	ld	c,.close
	jp	z,l59f8		; .. not on board
	call	BDOS		; .. else close
l59f8:
	pop	af
	pop	de
	jp	z,l0ca3
	ld	c,.delete
	call	BDOS		; Delete file
	pop	hl
	ret
;
; Statement : FILES [<filename>]
;
l5a04:
	jp	nz,l5a14
	push	hl
	ld	hl,@@FCB
	ld	(hl),0		; Set default drive
	inc	hl
	ld	c,_nam+_ext
	call	l5a96		; Set all wildcard
	pop	hl
l5a14:
	call	nz,parse	; .. parse file if argue
	xor	a
	ld	(@@FCB+_EX),a	; Clear extent
	push	hl
	ld	hl,@@FCB+_drv
	ld	c,_nam
	call	l5a92		; Map '*' -> '??...'
	ld	hl,@@FCB+_drv+_nam
	ld	c,_ext
	call	l5a92		; .. again
	ld	de,DMA
	ld	c,.setdma
	call	BDOS		; Set disk buffer
	ld	de,@@FCB
	ld	c,.srcfrs
	call	BDOS		; Search file
	cp	OSerr
	jp	z,l0ca3		; .. none found
l5a41:
	and	00000011b	; Mask directory code
	add	a,a		; .. *32
	add	a,a
	add	a,a
	add	a,a
	add	a,a
	ld	c,a
	ld	b,0
	ld	hl,DMA+1
	add	hl,bc		; Position name
	ld	c,_nam+_ext
l5a51:
	ld	a,(hl)
	inc	hl
	call	putchar		; Print file name
	ld	a,c
	cp	_ext+1
	jp	nz,l5a67
	ld	a,(hl)
	cp	' '
	jp	z,l5a64
	ld	a,'.'
l5a64:
	call	putchar		; Give blank or delimiter
l5a67:
	dec	c
	jp	nz,l5a51
	ld	a,(colCON)	; Get console column
	add	a,_nam+_ext+2
	ld	d,a
	ld	a,(l0790)
	cp	d
	jp	c,l5a80
	ld	a,' '
	call	putchar		; Give two blanks
	call	putchar
l5a80:
	call	c,fnl		; Give new line
	ld	de,@@FCB
	ld	c,.srcnxt
	call	BDOS		; Try to get next file
	cp	OSerr
	jp	nz,l5a41	; .. yeap
	pop	hl
	ret
;
; Map '*' to '??..'
;
l5a92:
	ld	a,(hl)
	cp	'*'		; Test wildcard
	ret	nz		; .. nope
;
; Fill FCB with single wildcards
;
l5a96:
	ld	(hl),'?'	; .. do it
	inc	hl
	dec	c
	jp	nz,l5a96
	ret
;
; Process R/W file function in Accu
;
l5a9e:
	push	de
	ld	c,a
	push	bc
	call	BDOS		; .. do it
	pop	bc
	pop	de
	push	af
	ld	hl,_RRN
	add	hl,de
	inc	(hl)		; Bump record count
	jp	nz,l5ab6
	inc	hl
	inc	(hl)
	jp	nz,l5ab6
	inc	hl
	inc	(hl)
l5ab6:
	ld	a,c
	cp	.wrrnd		; Test random write
	jp	nz,l5acb	; .. nope
	pop	af
	or	a		; Test write ok
	ret	z
	cp	5		; .. no directory space
	jp	z,l0cbb
	cp	3		; .. cannot close extent
	ld	a,1
	ret	z
	inc	a
	ret
l5acb:
	pop	af
	ret
;
;
;
l5acd:
	cp	3		; Test random access
	ret	nz		; .. nope
	dec	hl
	call	get.tok
	push	de
	ld	de,l0080
	jp	z,l5ae0
	push	bc
	call	l1411
	pop	bc
l5ae0:
	push	hl
	ld	hl,(recsiz)	; Get record size
	call	cp.r
	jp	c,_ill.func	; HL < DE, invalid
	ld	hl,l00a9
	add	hl,bc
	ld	(hl),e
	inc	hl
	ld	(hl),d
	xor	a
	ld	e,7
l5af4:
	inc	hl
	ld	(hl),a
	dec	e
	jp	nz,l5af4
	pop	hl
	pop	de
	ret
;
; Statement : PUT [#]<file number>[,<record number>]
;
l5afd:
	_OR
;
; Statement : GET [#]<file number>[,<record number>]
;
l5afe:
	xor	a
	ld	(l5d75),a
	call	l512a
	cp	3		; Verify random access
	jp	nz,l0ca0	; .. bad file mode if not
	push	bc
	push	hl
	ld	hl,l00ad
	add	hl,bc
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	de
	ex	(sp),hl
	ld	a,(hl)
	cp	','
	call	z,l1411
	dec	hl
	call	get.tok
	jp	nz,l0cc9
	ex	(sp),hl
	ld	a,d
	or	e
	jp	z,l0cb5
	dec	hl
	ld	(hl),e
	inc	hl
	ld	(hl),d
	dec	de
	pop	hl
	pop	bc
	push	hl
	push	bc
	ld	hl,l00b0
	add	hl,bc
	xor	a
	ld	(hl),a
	inc	hl
	ld	(hl),a
	ld	hl,l00a9
	add	hl,bc
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ex	de,hl
	push	de
	push	hl
	ld	hl,l0080
	call	cp.r		; Compare HL:DE
	pop	hl
	jp	nz,l5b54	; .. not same
	ld	de,l0000
	jp	l5b92
l5b54:
	ld	b,d
	ld	c,e
	ld	a,10h
	ex	de,hl
	ld	hl,l0000
	push	hl
l5b5d:
	add	hl,hl
	ex	(sp),hl
	jp	nc,l5b67
	add	hl,hl
	inc	hl
	jp	l5b68
l5b67:
	add	hl,hl
l5b68:
	ex	(sp),hl
	ex	de,hl
	add	hl,hl
	ex	de,hl
	jp	nc,l5b76
	add	hl,bc
	ex	(sp),hl
	jp	nc,l5b75
	inc	hl
l5b75:
	ex	(sp),hl
l5b76:
	dec	a
	jp	nz,l5b5d
	ld	a,l
	and	7fh
	ld	e,a
	ld	d,0
	pop	bc
	ld	a,l
	ld	l,h
	ld	h,c
	add	hl,hl
	jp	c,_ill.func	; .. invalid if overflow
	rla
	jp	nc,l5b8d
	inc	hl
l5b8d:
	ld	a,b
	or	a
	jp	nz,_ill.func	; .. invalid if not zero
l5b92:
	ld	(l5d6f),hl
	pop	hl
	pop	bc
	push	hl
	ld	hl,l00b2
	add	hl,bc
	ld	(l5d71),hl
l5b9f:
	ld	hl,l0029
	add	hl,bc
	add	hl,de
	ld	(l5d73),hl
	pop	hl
	push	hl
	ld	hl,l0080
	ld	a,l
	sub	e
	ld	l,a
	ld	a,h
	sbc	a,d
	ld	h,a
	pop	de
	push	de
	call	cp.r
	jp	c,l5bbc		; HL < DE
	ld	h,d
	ld	l,e
l5bbc:
	ld	a,(l5d75)
	or	a
	jp	z,l5c02
	ld	de,l0080
	call	cp.r
	jp	nc,l5bd1	; HL >= DE
	push	hl
	call	l5c20
	pop	hl
l5bd1:
	push	bc
	ld	b,h
	ld	c,l
	ex	de,hl
	ld	hl,(l5d73)
	ex	de,hl
	ld	hl,(l5d71)
	call	l5c58
	ld	(l5d71),hl
	ld	d,b
	ld	e,c
	pop	bc
	call	l5c1f
l5be8:
	ld	hl,(l5d6f)
	inc	hl
	ld	(l5d6f),hl
	pop	hl
	ld	a,l
	sub	e
	ld	l,a
	ld	a,h
	sbc	a,d
	ld	h,a
	ld	a,h
	or	l
	ld	de,l0000
	push	hl
	jp	nz,l5b9f
	pop	hl
	pop	hl
	ret
l5c02:
	push	hl
	call	l5c20
	pop	hl
	push	bc
	ld	b,h
	ld	c,l
	ex	de,hl
	ld	hl,(l5d71)
	ex	de,hl
	ld	hl,(l5d73)
	call	l5c58
	ex	de,hl
	ld	(l5d71),hl
	ld	d,b
	ld	e,c
	pop	bc
	jp	l5be8
l5c1f:
	_OR
l5c20:
	xor	a
	ld	(l07a0),a
	push	bc
	push	de
	push	hl
	ex	de,hl
	ld	hl,(l5d6f)
	ex	de,hl
	ld	hl,l00ab
	add	hl,bc
	push	hl
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	inc	de
	call	cp.r		; Compare HL:DE
	pop	hl
	ld	(hl),e
	inc	hl
	ld	(hl),d
	jp	nz,l5c47	; .. not same
	ld	a,(l07a0)
	or	a
	jp	z,l5c54
l5c47:
	ld	hl,l5c54
	push	hl
	push	bc
	push	hl
	ld	hl,l0026
	add	hl,bc
	jp	l56a4
l5c54:
	pop	hl
	pop	de
	pop	bc
	ret
l5c58:
	push	bc
l5c59:
	ld	a,(hl)
	ld	(de),a
	inc	hl
	inc	de
	dec	bc
	ld	a,b
	or	c
	jp	nz,l5c59
	pop	bc
	ret
l5c65:
	pop	af
	push	de
	push	bc
	push	af
	ld	b,h
	ld	c,l
	call	l5cc4
	jp	z,l5c93
	call	l5cb9
	ld	hl,l00b1
	add	hl,bc
	add	hl,de
	pop	af
	ld	(hl),a
	push	af
	ld	hl,l0028
	add	hl,bc
	ld	d,(hl)
	ld	(hl),0
	cp	0dh
	jp	z,l5c8e
	add	a,0e0h
	ld	a,d
	adc	a,0
	ld	(hl),a
l5c8e:
	pop	af
	pop	bc
	pop	de
	pop	hl
	ret
l5c93:
	jp	l0cb8
l5c96:
	push	de
	call	l5cc2
	jp	z,l5c93
	call	l5cb9
	ld	hl,l00b1
	add	hl,bc
	add	hl,de
	ld	a,(hl)
	or	a
	pop	de
	pop	hl
	pop	bc
	ret
l5cab:
	ld	hl,l00a9
	jp	l5cb4
l5cb1:
	ld	hl,l00b0
l5cb4:
	add	hl,bc
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ret
l5cb9:
	inc	de
	ld	hl,l00b0
	add	hl,bc
	ld	(hl),e
	inc	hl
	ld	(hl),d
	ret
l5cc2:
	ld	b,h
	ld	c,l
l5cc4:
	call	l5cb1
	push	de
	call	l5cab
	ex	de,hl
	pop	de
	call	cp.r		; Compare HL:DE (Z = C <)
	ret
l5cd1:
	call	get.tok
	ld	(@@ptr),hl	; Save token pointer
	call	l2392
	call	fprotect	; Protect file
	ld	a,0feh		; Set protect marker
	call	l53be		; .. save file
	call	funprot		; Unprotect file
	jp	l43c9
;
; Protect file in memory
;
fprotect:
	ld	bc,$PROT$	; Init loop value
	ld	hl,(prg.base)	; Get base of program
	ex	de,hl
l5cef:
	ld	hl,(prg.top)	; Get top of program
	call	cp.r		; Test all done
	ret	z		; .. yeap
	ld	hl,l3958	; Get array pointer
	ld	a,l
	add	a,c		; .. point into
	ld	l,a
	ld	a,h
	adc	a,0
	ld	h,a
	ld	a,(de)		; Get token
	sub	b		; .. subtract index
	xor	(hl)		; .. toggle from arry
	push	af		; .. save
	ld	hl,l3907	; Get 2nd array pointer
	ld	a,l
	add	a,b		; .. point into
	ld	l,a
	ld	a,h
	adc	a,0
	ld	h,a
	pop	af
	xor	(hl)		; .. toggle again
	add	a,c		; .. add offset
	ld	(de),a		; .. save byte
	inc	de
	dec	c		; Count down index
	jp	nz,l5d19
	ld	c,LOW $PROT$	; Reset index
l5d19:
	dec	b		; .. same for 2nd index
	jp	nz,l5cef
	ld	b,HIGH $PROT$
	jp	l5cef
;
; Unprotrect file in memory
;
funprot:
	ld	bc,$PROT$	; Init loop counts
	ld	hl,(prg.base)	; Get base of program
	ex	de,hl
l5d29:
	ld	hl,(prg.top)	; Get top of program
	call	cp.r
	ret	z		; HL = DE
	ld	hl,l3907	; Get 1st array
	ld	a,l
	add	a,b		; .. point into
	ld	l,a
	ld	a,h
	adc	a,0
	ld	h,a
	ld	a,(de)		; Get byte
	sub	c		; .. fix
	xor	(hl)		; .. toggle from table
	push	af
	ld	hl,l3958	; Get 2nd array
	ld	a,l
	add	a,c		; .. point into
	ld	l,a
	ld	a,h
	adc	a,0
	ld	h,a
	pop	af
	xor	(hl)		; .. toggle
	add	a,b		; .. fix
	ld	(de),a		; .. save token
	inc	de
	dec	c		; Count down index
	jp	nz,l5d53
	ld	c,LOW $PROT$	; .. reset index
l5d53:
	dec	b		; Same for 2nd index
	jp	nz,l5d29
	ld	b,HIGH $PROT$
	jp	l5d29
;
;
;
l5d5c:
	push	hl
	ld	hl,(dir.mode)	; Get direct mode
	ld	a,h
	and	l
	pop	hl
	inc	a
	ret	nz		; .. -1 is direct
l5d65:
	push	af
	ld	a,(_prot)	; Test file protected
;;
;; CHANGE	or	a
;; TO		xor	a
;; IF A PROTECTED FILE SHOULD BE LISTED [OR SKIP ROUTINE]
;;
	or	a
	jp	nz,_ill.func	; .. yeap, invalid
	pop	af
	ret
;
l5d6f:
	dw	0
l5d71:
	dw	0
l5d73:
	dw	0
l5d75:
	db	0
;
;
;
l5d76:
	call	l430a
	ld	hl,(prg.base)	; Get base of program
	dec	hl
	ld	(hl),0
	ld	hl,(_f.$$)	; Get file pointer
	ld	a,(hl)		; Test file given to be loaded
	or	a
	jp	nz,_FRUN	; .. yeap, load it
	jp	l0d87
;
; +++++ DYNAMIC SPACE STARTS HERE +++++
;
_F.arr:
	ds	2		; Start of file array
;
; ## COLD ENTRY ##
;
l5d8c::
	ld	hl,l603f
	ld	sp,hl		; Set local stack
	xor	a
	ld	(_prot),a	; Clear protection
	ld	(heap),hl	; Init heap
	ld	sp,hl		; .. for stack		**** ?????
	ld	hl,l0822
	ld	(hl),':'
	call	l4397		; Init error environment
	ld	(colCON),a	; Set console column
	ld	(curstk),hl	; .. save stack
	ld	hl,(OS+1)	; Get BIOS vector
	ld	bc,3*(_@CST-1)+1
	add	hl,bc		; Point to console state
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	ld	($CST3),hl	; .. save it
	ld	($CST2),hl
	ld	($CST1),hl
	ex	de,hl
	inc	hl
	inc	hl
	ld	e,(hl)		; Get console input routine
	inc	hl
	ld	d,(hl)
	ex	de,hl
	ld	($CIN),hl	; .. save
	ex	de,hl
	inc	hl
	inc	hl
	ld	e,(hl)		; .. same for output
	inc	hl
	ld	d,(hl)
	ex	de,hl
	ld	($COT),hl
	ex	de,hl
	inc	hl
	inc	hl
	ld	e,(hl)		; .. finally printer output
	inc	hl
	ld	d,(hl)
	ex	de,hl
	ld	($POT),hl
	ld	c,.vers
	call	BDOS		; Get OS version
	ld	(OSvers),a
	or	a
	ld	hl,.wrseq*256+.rdseq
	jp	z,l5dea
	ld	hl,.wrrnd*256+.rdrnd
l5dea:
	ld	(f_rd),hl	; Save R/W mode
	ld	hl,lfffe
	ld	(dir.mode),hl	; Set direct mode
	xor	a		; Init ..
	ld	(_brk),a	; .. console echo
	ld	(l0a64),a
	ld	(l0bf3),a
	ld	(l0bed),a
	ld	(err.num),a	; .. error number
	ld	hl,0
	ld	(colLST),hl
	ld	hl,reclng
	ld	(recsiz),hl	; Init record size
	ld	hl,STR.arr
	ld	(STR.ptr),hl	; .. string pointer
	ld	hl,l0ae4
	ld	(l0b4c),hl
	ld	hl,(BDOS+1)
	ld	(himem),hl	; Init highest memory
	ld	a,3
	ld	(opnfiles),a	; .. max number of open files
	ld	hl,l5ed4
	ld	(_f.$$),hl	; Set NULL pointer
	ld	a,(l5ed5)
	or	a
	jp	nz,l5ed6
	inc	a
	ld	(l5ed5),a
	ld	hl,CCP		; Init command buffer
	ld	a,(hl)		; .. get length
	or	a
	ld	(_f.$$),hl	; Save buffer
	jp	z,l5ed6		; .. empty command
	ld	b,(hl)
	inc	hl
l5e44:
	ld	a,(hl)		; Unpack line right justified
	dec	hl
	ld	(hl),a
	inc	hl
	inc	hl
	dec	b
	jp	nz,l5e44
	dec	hl
	ld	(hl),null	; .. close line
	ld	(_f.$$),hl	; .. save final pointer
	ld	hl,CCP-1
	call	get.tok		; Get character
	or	a
	jp	z,l5ed6
	cp	'/'		; Test option(s)
	jp	z,l5e78		; ..yeap
	dec	hl
	ld	(hl),'"'	; Set string
	ld	(_f.$$),hl	; .. set pointer
	inc	hl
l5e69:
	cp	'/'
	jp	z,l5e78
	call	get.tok		; Get next character
	or	a
	jp	nz,l5e69
	jp	l5ed6
l5e78:
	ld	(hl),null	; Overwrite '/'
	call	get.tok		; Get next character
l5e7d:
	call	toupper_	; Get upper case
	cp	'S'		; Test max record size
	jp	z,l5ec2
	cp	'M'		; .. highest memory location
	push	af
	jp	z,l5e90
	cp	'F'		; .. number of files
	jp	nz,l0cc9
l5e90:
	call	get.tok		; Get next character
	call	ilcmp		; Position ':'
	db	':'
	call	ato??		; Convert ASCII to binary
	pop	af
	jp	z,l5eaf		; .. got /M
	ld	a,d
	or	a
	jp	nz,_ill.func	; Invalid call if > 255
	ld	a,e
	cp	15+1		; Test too many files
	jp	nc,_ill.func	; .. yeap, invalid call
	ld	(opnfiles),a	; .. set new max
	jp	l5eb4
l5eaf:
	ex	de,hl
	ld	(himem),hl	; Save top of memory
	ex	de,hl
l5eb4:
	dec	hl
	call	get.tok		; Get next character
	jp	z,l5ed6		; .. end
	call	ilcmp		; Position '/'
	db	'/'
	jp	l5e7d
l5ec2:
	call	get.tok		; Get next character
	call	ilcmp		; Position ':'
	db	':'
	call	ato??		; Convert ASCII to binary
	ex	de,hl
	ld	(recsiz),hl	; .. set new size
	ex	de,hl
	jp	l5eb4
;
l5ed4:
	db	0
l5ed5:
	db	0
;
l5ed6:
	dec	hl		; ** WHY ???
	ld	hl,(himem)	; Get top of memory
	dec	hl		; .. fix
	ld	(himem),hl
	dec	hl
	push	hl		; Save top pointer
	ld	a,(opnfiles)	; Get max number of open files
	ld	hl,_F.arr	; Init data pointer
	ld	(F.ptr),hl	; .. into base file pointer
	ld	de,F.arr
	ld	(opnfiles),a	; ** WHY ???
	inc	a		; .. bump
	ld	bc,l00a9
l5ef3::
	ex	de,hl
	ld	(hl),e		; Save into file array
	inc	hl
	ld	(hl),d
	inc	hl
	ex	de,hl
	add	hl,bc		; Add base amount
	push	hl
	ld	hl,(recsiz)	; Get record size
	ld	bc,l00b2
	add	hl,bc		; .. add new amount
	ld	b,h		; .. copy
	ld	c,l
	pop	hl
	dec	a		; .. for all files
	jp	nz,l5ef3
	inc	hl
	ld	(prg.base),hl	; Set final pointer for base
	ld	(curstk),hl	; .. and stack
	pop	de		; Get back top pointer
	ld	a,e
	sub	l		; Test enough room
	ld	l,a
	ld	a,d
	sbc	a,h
	ld	h,a
	jp	c,l42dd		; .. nope
	ld	b,3
l5f1c:
	or	a
	ld	a,h		; Divide size by 8
	rra
	ld	h,a
	ld	a,l
	rra
	ld	l,a
	dec	b
	jp	nz,l5f1c
	ld	a,h
	cp	HIGH 0200h	; Test space
	jp	c,l5f30
	ld	hl,0200h	; .. truncate it
l5f30:
	ld	a,e
	sub	l		; Test in range
	ld	l,a
	ld	a,d
	sbc	a,h
	ld	h,a
	jp	c,l42dd		; .. nope
	ld	(himem),hl	; .. save new top
	ex	de,hl
	ld	(heap),hl	; .. set heap
	ld	(mem.top),hl	; .. and top of memory
	ld	sp,hl		; .. load stack
	ld	(curstk),hl	; .. save it
	ld	hl,(prg.base)	; Get base of program
	ex	de,hl
	call	l42eb
	ld	a,l
	sub	e
	ld	l,a
	ld	a,h
	sbc	a,d
	ld	h,a
	dec	hl
	dec	hl
	push	hl
	ld	hl,l5f9a
	call	l4723
	pop	hl
	call	l311a
	ld	hl,l5f8e
	call	l4723
	ld	hl,l4723
	ld	(@@MSG),hl	; Init string routine
	call	fnl		; Give new line
	ld	hl,l0c7f
	jp	l5d76
;
	db	cr,lf,lf,'Owned by Microsoft',cr,lf,null
l5f8e:
	db	' Bytes free',null
l5f9a:
	db	'BASIC-80 Rev. 5'
l5fa9:
	db	'.21',cr,lf
	db	'[CP/M Version]',cr,lf
	db	'Copyright 1977-1981 (C) by Microsoft',cr,lf
	db	'Created: 28-Jul-81',cr,lf,null
l5ff9::

l603f	equ	l5ff9+2*35
l6040	equ	l603f+1
l60a3	equ	l6040+99

	end

