
	TITLE	'FIND+ 2.0'
;
;		    FYNDE.ASM   Copyright (C) 1982
;		    Universidad Autonoma de Puebla
;
;	The original of FIND wasn't copyright and neither is
;	my work on it here. Bill Bolton
;
;	-----------------------------------------------------
;
;	Reassembly of FIND.COM, which was originally extracted
;	from the CBBS(R) package available from Ward Christensen
;	and Randy Suess. However, considerable rearrangement has
;	taken place, most notably the following:
;
;	*    <no file name> results in a screen of information
;	*    the search pattern may be a regular expression
;	*    label+line number as an alternative to line number
;	*    instance count reported, both per file and globally
;	*    files listed in a table in the data section at the end
;	     are automatically excluded
;	*    squeezed files do not deter the search
;
;	To achieve compatibility with MicroShell the vertical bar
;	may be replaced by exclamation point; all syntactic elements
;	are defined by EQU's and may be redefined. LABEL|PATTERN
;	is checked for balanced parentheses and non-null arguments
;	to forestall the most common failure modes. Had MicroShell
;	not been available, an option to direct the output to some
;	disk file would probably have been included.
;
;
;VERSION LIST, in reverse order for easy on line scanning
;
;23/Oct/84 Added exclusion table code to check for file types
;	   not to serach. Fixed bug when searching large files,
;	   often started on non-zero exetent, which mightly
;	   confused the file unsqueezing mechanism. Now once a
;	   suitable file is found to search the extent is forced
;	   to zero to start. Added conditional code for RCPM
;	   use to test for SYS and F2 attributes along the lines
;	   of FIND+. Lifted usage message from FIND+, added version
;	   number to signon message. Version 2.0
;	   Bill Bolton, Software Tools RCPM, Brisbane, Australia
;
;04/Jul/84 No false matches with nul lines. Harold V. Mcintosh
;
;01/Jul/84 Scan squeezed files. Harold V. McIntosh
;
;20/Dec/82 Originally written. Harold V. McIntosh
;
;	----------------------------------------------------------


TRUE	equ	0FFH
FALSE	equ	0
;
VERS	equ	20		;version number
;
HT	equ	09H		;horizontal tab
LF	equ	0AH		;line feed
CR	equ	0DH		;carriage return
KZ	equ	1AH		;^Z
MASK	equ	7FH		;ASCII mask

;	Delimiters for the command line

LSQ	equ	'['		;begin alternative list
RSQ	equ	']'		;end alternative list
LBR	equ	'{'		;begin iterated expression
RBR	equ	'}'		;end iterated expression
ORR	equ	'|'		;separate alternatives

;	Representatives of characters or classes.

TAB	equ	'_'		;substitute for tab
QUE	equ	'?'		;represent any byte
ALF	equ	'@'		;represent any alphanumeric

;	CP/M and other locations and parameters

cfcb	equ	005CH		;CP/M's file control block
cblk	equ	007CH		;CP/M's block counter
csiz	equ	0080H		;CP/M's record size
cbuf	equ	0080H		;CP/M's record buffer
ksiz	equ	255		;sector capacity of IN buffer
isiz	equ	ksiz*128	;buffer 2 file extents in memory
hsiz	equ	256		;max characters in Huffman code
;
RCPM	equ	FALSE		;true for RCPM use
;
;	------------
	org	100H
;	------------

X0100:
	lxi	sp,stak
	lda	cfcb+1		;file name
	cpi	' '
	jnz	X0143
	lxi	h,usage
ferm:
	call	mssg		;message to console
	jmp	0000

X0143:
	lxi	h,signon
	call	mssg		;message to console
	mvi	c,12
	lxi	d,cfcb		;CP/M's file control block
	lxi	h,file
	call	miuc		;block move
	xra	a
	sta	enth
	lxi	h,cbuf		;CP/M's record buffer
	mov	e,m
	mov	c,e
	mov	d,a
	xchg
	inx	d
	dad	d
	mov	m,a
	xchg
X0152:
	inx	h
	dcr	c
	mov	a,m
	ora	a
	jz	X029C
	cpi	' '
	jnz	X0152
	inx	h
	call	bala		;check balance of [], {}.
	call	nula		;check for null alternatives
	lxi	d,patt		;command line pattern
	call	muve
	mvi	c,4
	lxi	d,lzer
	lxi	h,dtot
	call	miuc		;block move
	lxi	h,0000
	shld	lapo
	lxi	h,patt		;command line pattern
	shld	papo
	call	next
	ora	a
	jz	scan
	shld	papo
	lxi	h,patt
	shld	lapo

;	Scan the directory for file names.

scan:
	mvi	c,26		;(1A) set DMA address
	lxi	d,cbuf		;CP/M's record buffer
	call	0005		; - B D O S -
	mvi	c,17		;(11) search once
	lxi	d,file
	call	0005		; - B D O S -
	lxi	h,enth
	inr	m
	mov	c,m
fnth:
	inr	a
	jz	done		;we're all done
	dcr	c
	jz	this
	push	b
	mvi	c,18		;(12) search again
	lxi	d,file
	call	0005		; - B D O S -
	pop	b
	jmp	fnth

;	We're all done.

done:
	lxi	h,dtot
	jmp	ferm		;final (error) message

;	A prospective file has been located

this:
	dcr	a
	ani	03
	add	a
	add	a
	add	a
	add	a
	add	a
	adi	81H
	mov	e,a
	mvi	d,00
	mvi	c,11
	lxi	h,cfcb+1	;CP/M's file control block
	call	miuc		;block move
	lxi	h,cfcb+12
	xra	a
	mov	m,a		;make sure we start on extent 0

	if	rcpm		;your favourite catalogue file type

	lda	cfcb+9
	ani	mask
	cpi	'A'		;file type of ALL/AQL always OK
	jnz	tagtest		; on Software Tools RCPM
	lda	cfcb+10
	ani	mask
	cpi	'L'
	cnz	Qcheck		;maybe squeezed
	jnz	tagtest
	lda	cfcb+11
	ani	mask
	cpi	'L'
	jz	ok	
tagtest:
	lda	cfcb+2
	ani	80h		;TAG2 attribute set?
	jnz	scan		;yes
	lda	cfcb+10		;no
	ani	80h		;SYS attribute set?
	jnz	scan		;yes

	endif	;rcpm

	call	ignore		;disregard files in table
	jz	scan

;	Open the file, check for squeezing.

ok:
	mvi	c,15		;(0F) open file
	lxi	d,cfcb		;CP/M's FCB
	call	0005		; - B I O S -
	inr	a
	jz	0000		;quit [without message]
	xra	a
	sta	cblk		;block pointer
	sta	dens		;z/nz=un/squeezed
	sta	mult		;repeat factor
	lxi	h,0000
	shld	ictr		;input counter

	lxi	h,cfcb+10	;CP/M's file control block
	mov	a,m
	cpi	'Q'
	jnz	nsqz
	call	gbyt		;fetch one byte
	cpi	076H
	jnz	nsqz
	call	gbyt		;fetch one byte
	cpi	0FFH
	jnz	nsqz
	lxi	h,dens		;z/nz=un/squeezed
	mvi	m,0FFH
	call	rwor		;fetch word

;	unsqueezed file name

	lxi	b,200CH		;twelve spaces
	lxi	h,uzfn		;unsqueezed file's name
	call	fiuc		;block fill

	mvi	b,8
	lxi	d,uzfn		;unsqueezed file's name
luup:
	call	gbyt		;fetch one byte
	ora	a
	jz	ldic
	cpi	'.'
	jz	luuw
	stax	d
	inx	d
	dcr	b
	jnz	luup
luuz:
	call	gbyt
	ora	a
	jz	ldic
	cpi	'.'
	jnz	luuz
luuw:
	mvi	b,3
	lxi	d,uzfn+8
	stax	d
	inx	d
luur:
	call	gbyt
	ora	a
	jz	ldic
	stax	d
	inx	d
	dcr	b
	jnz	luur
luus:
	call	gbyt
	ora	a
	jnz	luus

;	load code directory

ldic:
	call	rwor		;fetch word
	lxi	b,hsiz
	mov	a,c
	sub	l
	mov	a,b
	sbb	h
	jnc	ldii
	lxi	h,M8		;'code table won't fit'
	call	mssg
	jmp	scan

ldii:
	dad	h
	dad	h
	mov	c,l
	mov	b,h
	lxi	d,code		;code table
ldij:
	call	gbyt		;fetch one byte
	stax	d
	inx	d
	dcx	b
	mov	a,c
	ora	b
	jnz	ldij

	lxi	h,roco		;rotation count
	mvi	m,1

nsqz:
	mvi	c,4
	lxi	d,lzer
	lxi	h,lnum		;'line number'
	call	miuc		;block move

	mvi	c,4
	lxi	d,lzer
	lxi	h,ftot		;'file total'
	call	miuc		;block move

	mvi	c,8
	lxi	d,cfcb+1	;file name
	lxi	h,fnam		;'file name'
	call	miuc		;block move

	mvi	c,3
	lxi	d,0065H		;extension
	lxi	h,fext		;'file extension'
	call	miuc		;block move

	lxi	h,fhed
	call	mssg		;message to console
	lda	dens
	ora	a
	jz	sixs
	lxi	h,hesq		;'[original]'
	call	mssg

sixs:
;	lxi	b,2006H		;six spaces
;	lxi	h,llbl
;	call	fiuc		;block fill

X01C8:
	lxi	h,lnum+3	;increment l.c.
	call	inco		;increment line counter
	lxi	h,lbuf		;line buffer
	mvi	b,0FFH
X01E0:
	inr	b
	jm	X01FD
	push	b
	push	h
	call	inch		;char from big bffr to line bffr
	pop	h
	pop	b
	mov	m,a
	inx	h
	cpi	KZ
	jnz	X01E8
	lxi	h,ftot
	call	mssg		;message to console
	jmp	scan
X01E8:
	cpi	LF
	jnz	X01E0
	jmp	X0202

X01FD:
	mvi	m,CR
	inx	h
	mvi	m,LF
	inx	h

;	Check console for termination request. If one
;	is present, clear it out before leaving.

X0202:
	mvi	m,00		;guarantee right hand fence
	mvi	c,11		;(0B) console status
	call	0005		; - B I O S -
	ora	a
	jz	culi
	mvi	c,1		;(01) read console
	call	0005		; - B D O S -
	cpi	03H		;^C
	jnz	skpf
	lxi	h,M4		;"search terminated"
	jmp	ferm		;final (error) message

skpf:
	lxi	h,M5		;"remainder of file skipped"
	call	mssg		;message to console
	jmp	scan

;	Scan the current line.
;	First see if it is labelled.

culi:
	lhld	lapo
	mov	a,h
	ora	l
	jz	X0217		;no label requested
	xchg
	lxi	h,lbuf
	call	chek
	jnz	X0217		;label not found
	push	h
	lxi	b,2006H		;six spaces
	lxi	h,llbl
	call	fiuc		;block fill
	pop	h
	lxi	d,llbl+5
	mvi	c,6
didl:
	dcx	h
	mov	a,m
	cpi	HT		;ignore tabs in text
	jz	didl
	cpi	' '		;quit at head of line
	jc	dido
	stax	d
	dcx	d
	dcr	c
	jnz	didl
dido:
	mvi	c,4
	lxi	d,lzer
	lxi	h,lnum
	call	miuc		;block move

;	Now look for the pattern

X0217:
	lxi	h,lbuf		;line buffer
X021A:
	xchg
	lhld	papo		;pattern pointer
	xchg
	push	h
	call	chek
	pop	h
	jz	X0263
	mov	a,m
	cpi	CR
	jz	X01C8		;increment l.c. at X026A
	inx	h
	jmp	X021A

;	Pattern matches, so type label & line containing it

X0263:
;	lxi	h,llbl		;line label
;	call	mssg		;message to console
	lxi	h,lbuf		;line buffer
	call	mssg		;message to console
	lxi	h,ftot+3
	call	inco
	lxi	h,dtot+3
	call	inco
	jmp	X01C8		;increment l.c. at X026A

;	Increment ASCII counter at (HL-3).

inco:
	mov	a,m
	ori	30H
	inr	a
	mov	m,a
	cpi	':'
	rnz
	mvi	m,'0'
	dcx	h
	jmp	inco

;	Memory to console

mssg:
	mov	e,m
	inx	h
	push	h
	mvi	c,2		;(02) write console
	call	0005		; - B I O S -
	pop	h
	mov	a,m
	ora	a
	jnz	mssg		;message to console
	ret

X029C:
	lxi	h,M3		;"bad pattern"
	call	ferm		;final (error) message

;	decode next character

dnch:
	lxi	h,code		;code table
dncr:
	call	rbit
	jnc	dncs
	inx	h
	inx	h
dncs:
	mov	e,m
	inx	h
	mov	d,m
	mov	a,d
	cpi	0FEH
	jz	dnct
	ora	a
	jp	dncu
	mov	a,e
	cma
	stc
	cmc
	ret

dnct:
	stc
	ret

;	Calculate <code>+4*<offset>.

dncu:
	lxi	h,code		;code table
	dad	d
	dad	d
	dad	d
	dad	d
	jmp	dncr

;	read one bit at a time

rbit:
	push	h
	lxi	h,roco		;rotation count
	dcr	m
	jnz	rbiu
	mvi	m,8
	call	gbyt		;fetch one byte
	sta	roby		;rotating byte
rbiu:
	lda	roby		;rotating byte
	rar
	sta	roby		;rotating byte
	pop	h
	ret

;	read one word

rwor:
	call	gbyt		;fetch one byte
	push	psw
	call	gbyt		;fetch one byte
	pop	h
	mov	l,h
	mov	h,a
	ret

;	Fetch the next byte. The input buffer will be refreshed if it
;	is necessary. For normal files, one byte will be extracted from
;	the input buffer; for squeezed files, one byte will be decoded
;	from the incoming bit stream and subtracted from the checksum.

inch:
	lda	dens		;z/nz = un/squeezed
	ora	a
	jz	gbyt		;fetch one byte
	lda	mult		;repeat factor
	ora	a
	jz	gusq
	dcr	a
	sta	mult		;repeat factor
	lda	lach		;last character read
	ret

gusq:
	call	dnch
	jnc	guss
	mvi	a,1AH
	ret

guss:
	cpi	090H
	jz	gusu
	sta	lach		;last character read
	ret

gusu:
	call	dnch
	ora	a
	jnz	gusv
	mvi	a,090H
	ret

gusv:
	dcr	a
	dcr	a
	sta	mult		;repeat factor
	lda	lach		;last character read
	ret

;	unsqueezed (normal) text

gbyt:
	lhld	ictr		;input counter
	mov	a,h
	ora	l
	cz	indi		;disk to IN area
	lhld	ictr		;input counter
	dcx	h
	shld	ictr		;input counter
	lhld	iptr		;input pointer
	mov	a,m
	inx	h
	shld	iptr		;input pointer
	ret

indi:
	mvi	b,ksiz
	lxi	h,isiz
	shld	ictr		;input counter
	lxi	h,ibuf		;input buffer
	shld	iptr		;input pointer
indd:
	mvi	m,KZ
	push	h
	push	b
	xchg
	mvi	c,26		;(1A) set DMA address
	call	0005		; - B D O S -
	lxi	d,cfcb		;CP/M's file control block
	mvi	c,20		;(14) read one record
	call	0005		; - B D O S -
	pop	b
	pop	h
	ora	a
	rnz
	dcr	b
	rz
	lxi	d,csiz		;CP/M's record size
	dad	d
	jmp	indd

;	Disregard certain files

ignore:
	mvi	c,(table$end - table$start)/3
	lxi	h,table$start-3
	shld	store
loop:
	lhld	store		;get pointer
	lxi	d,3		;bump to next entry
	dad	d
	shld	store
	lxi	d,cfcb+9	;point to start of file type
	call	match		;matched?
	rz			;yes
	dcr	c		;no, finished count?
	jnz	loop		;no
	mvi	a,1		;yes
	ora	a		;return non-zero
	ret
;
match:
	ldax	d
	ani	mask
	cmp	m		;first character match?
	rnz			;no
	inx	h
	inx	d
	ldax	d
	ani	mask
	cmp	m		;second character match?
	cnz	Qcheck		;squeezed version of file type?
	rnz			;no
	inx	h
	inx	d
	ldax	d
	ani	mask
	cmp	m		;third character match?
	ret
;	
Qcheck
	cpi	'Q'
	ret
;
;	Advance to next alternative

nexx:
	mov	e,m
	inx	h
	mov	d,m
	xchg
next:
	mov	a,m
	ora	a
	rz
	inx	h
	call	enda
	rz
	call	begb
	jz	nexx
	jmp	next

;	Block fill with C B's starting at (HL).

fiuc:
	mov	m,b
	inx	h
	dcr	c
	jnz	fiuc		;block fill
	ret

;	Block move of C bytes from (DE) to (HL).

miuc:
	ldax	d
	mov	m,a
	inx	d
	inx	h
	dcr	c
	jnz	miuc		;block move
	ret

;	Move and semi-compile the command line.

muve:
	mov	a,m
	cpi	TAB
	jnz	munt
	mvi	a,HT
munt:
	stax	d
	inx	h
	inx	d
	cpi	RBR
	jz	murb
	cpi	RSQ
	jz	murb
	cpi	LBR
	jz	mulb
	cpi	LSQ
	jz	mulb
must:
	dcr	c
	jnz	muve
	ret

murb:
	xthl
	mov	m,e
	inx	h
	mov	m,d
	pop	h
	jmp	must

mulb:
	push	d
	inx	d
	inx	d
	jmp	must

;	Check balance of []'s and {}'s.

bala:
	push	h
	push	b
	lxi	b,0101H
balb:
	mov	a,m
	inx	h
	cpi	LSQ
	jnz	balc
	inr	b
	jmp	balb
balc:
	cpi	RSQ
	jnz	bald
	dcr	b
	jz	balx
	jmp	balb
bald:
	cpi	LBR
	jnz	bale
	inr	c
	jmp	balb
bale:
	cpi	RBR
	jnz	balf
	dcr	c
	jz	balx
	jmp	balb
balf:
	ora	a
	jnz	balb
	mov	a,c
	cpi	01
	jnz	balx
	mov	a,b
	cpi	01
	pop	b
	pop	h
	rz
balx:
	lxi	h,M3		;"bad pattern"
	jmp	ferm		;final (error) message

;	Check for termination of alternative.

enda:
	cpi	ORR
	rz
endb:
	cpi	RSQ
	rz
	cpi	RBR
	rz
	ora	a
	ret

;	Check for beginning of alternative.

bega:
	cpi	ORR
	rz
begb:
	cpi	LSQ
	rz
	cpi	LBR
	ret

;	Check for null alternative.

nula:
	push	h
	call	nulb
	pop	h
	ret
nulb:
	mov	a,m
	inx	h
	ora	a
	rz
	call	bega
	jnz	nulb
	mov	a,m
	call	enda
	jnz	nulb
	jmp	balx

;	Check for given expression.

chek:
	ldax	d
	inx	d
	call	enda
	rz
	mov	b,a
	mov	a,m
	cpi	CR
	jz	chno
	mov	a,b
	cpi	LBR
	jz	chlb
	cpi	LSQ
	jz	chsq
	mov	c,m
	inx	h
	cpi	QUE
	jz	chek
	cpi	ALF
	jz	chal
	cmp	c
	jz	chek
	mov	b,a
	mov	a,c
	cpi	'a'
	jc	chno
	cpi	'{'
	jnc	chno
	ani	05FH
	cmp	b
	jz	chek
chno:
	ori	0FFH
	ret

;	Check alphanumeric.

chal:
	mov	a,c
	cpi	'0'
	jc	chno
	cpi	':'
	jc	chek
	cpi	'A'
	jc	chno
	cpi	'['
	jc	chek
	cpi	'a'
	jc	chno
	cpi	'{'
	jc	chek
	jmp	chno

;	Check list of alternatives.

chsq:
	mov	c,l
	mov	b,h
	lhld	sqxx
	push	h
	lhld	sqaa
	push	h
	lhld	sqzz
	push	h
	mov	l,c
	mov	h,b
	shld	sqxx
	xchg
	mov	e,m
	inx	h
	mov	d,m
	inx	h
	shld	sqaa
	xchg
	shld	sqzz
chaa:
	lhld	sqxx
	call	chek
	jz	chff
chbb:
	lhld	sqaa		;fail so find next alternative
chcc:
	call	next
	cpi	RSQ
	jz	chdd		;no more alternatives, so fail
	cpi	ORR
	jnz	chcc
	shld	sqaa
	xchg
	jmp	chaa		;try next alternative
chdd:
	lhld	sqxx
	ori	0FFH
chee:
	mov	c,l
	mov	b,h
	pop	h
	shld	sqzz
	pop	h
	shld	sqaa
	pop	h
	shld	sqxx
	mov	l,c
	mov	h,b
	ret
chff:
	xchg			;good alternative, try rest
	lhld	sqzz
	xchg
	call	chek
	jz	chee
	jmp	chbb

;	Check iterative pattern.

chlb:
	mov	c,l
	mov	b,h
	lhld	text
	push	h
	lhld	texx
	push	h
	lhld	rest
	push	h
	lhld	repeat
	push	h
	lhld	repp
	push	h
	mov	l,c
	mov	h,b
	shld	text
	shld	texx
	xchg
	mov	e,m
	inx	h
	mov	d,m
	inx	h
	shld	repeat
	shld	repp
	xchg
	shld	rest
chlc:
	lhld	rest
	xchg
	lhld	text
	call	chek		;check rest
	jz	chzz
chii:
	lhld	repeat		;rest failed
	xchg
	lhld	text		;keep same text
	call	chek		;try out the rer
	jnz	choo
	shld	text		;repeater worked, record progress
	lhld	repp		;start alternatives over again
	shld	repeat
	jmp	chlc
choo:
	lhld	repeat		;rer failed, try next
chxx:
	call	next
	cpi	RBR
	jz	chyy		;this was the last, quit
	cpi	ORR
	jnz	chxx
	shld	repeat
	jmp	chii
chyy:
	lhld	texx
	ori	00		;emphasize the RBR
chzz:
	mov	c,l
	mov	b,h
	pop	h
	shld	repp
	pop	h
	shld	repeat
	pop	h
	shld	rest
	pop	h
	shld	texx
	pop	h
	shld	text
	mov	l,c
	mov	h,b
	ret

;	Data area

	if	rcpm

usage	db	CR,LF,CR,LF
	db	'Usage:',CR,LF
	db	HT,'FIND filename.typ string[|string]'
	db	CR,LF,CR,LF
	db	'Where:',CR,LF
	db	HT,'filename.typ =',HT,'any CATALOG name, (* and ? allowed).'
	db	CR,LF
	db	HT,HT,HT,'CATALOG names are...'
	db	CR,LF,LF
	db	HT,HT,HT,'SIGM-1.AQL to SIGM-4.AQL, CPMCAT.AQL'
	db	CR,LF
	db	HT,HT,HT,'CUGCAT.AQL, MISC.AQL, PCBLUE.AQL'
	db	CR,LF
	db	CR,LF
	db	HT,'string',HT,'     =',HT,'any string of characters'
	db	CR,LF
	db	HT,HT,HT,'(* and ? not allowed).'
	db	CR,LF,LF
	db	HT,'|',HT,'     =',HT,'optional OR connector for multiple strings'
	db	CR,LF
	db	HT,HT,HT,'i.e. FIND MISC.AQL DOC|TXT'
	db	CR,LF,CR,LF
	db	'Type HELP THIS-SYS for a full description of FIND'
	db	CR,LF,0
	endif	;rcpm

	if	not rcpm

usage	db	'The command line',CR,LF
	db	'     FYNDE D:FILE.EXT EXPRESSION',CR,LF
	db	'will search through all instances of FILE.EXT',CR,LF
	db	'(which may be an ambiguous reference) on disk D',CR,LF
	db	'to find lines containing EXPRESSION. Such lines',CR,LF
	db	'will be presented on the console preceded by a',CR,LF
	db	'line number, and classified by file. EXPRESSION',CR,LF
	db	'may have the form LABEL!PATTERN or simply the',CR,LF
	db	'form PATTERN. Both may contain:',CR,LF
	db	'     [p1!p2!...!pn]  alternative strings',CR,LF
	db	'     {p1!p2!...!pn}  repeated alternatives',CR,LF
	db	'     ? any single character',CR,LF
	db	'     @ for any alphanumeric: a-z, A-Z, 0-9',CR,LF
	db	'     _ in place of horizontal tab',CR,LF
	db	'When a label is present, lines will be numbered',CR,LF
	db	'relative to the label.  Example: X{?}:![call!ret]',CR,LF
	db	'will list calls and returns relative to labels',CR,LF
	db	'like X0100: or X33:. LABEL begins in column 1,',CR,LF
	db	'PATTERN can begin in any column. Squeezed files',CR,LF
	db	'will be searched as well as unsqueezed ones. Use',CR,LF
	db	'^C to quit, any other key skips rest of file.',CR,LF
	db	00

	endif	;not rcpm

signon	db	CR,LF
	db	'FIND+ Version '
	db	VERS/10 + '0','.',VERS MOD 10 + '0'
	db	CR,LF,0

M3	db	'-- Bad Pattern --',00

M4	db	CR,LF,'-- Search Terminated --',00

M5	db	' -- Remainder of File Skipped --',CR,LF,00

M8	db	' -- Code Table Won''t Fit --',CR,LF,00

enth	ds	1
file	db	'DFilenameEXT',00
	ds	19

sqxx	ds	2
sqaa	ds	2
sqzz	ds	2
text	ds	2
texx	ds	2
rest	ds	2
repeat	ds	2
repp	ds	2

	ds	100		;stack area
stak	ds	2		;initialize stack pointer
lapo	ds	2		;label pointer
papo	ds	2		;pattern pointer
store	ds	2		;name pointer
hesq	db	'[original]  '
uzfn	db	'original.xxx'	;unsqueezed file's name
	db	CR,LF,00
fhed	db	CR,LF
	db	'----> File  '
fnam	db	'xxxxxxxx.'	;filename
fext	db	'xxx',CR,LF,00	;file extension
llbl	db	'      +'
lnum	db	'         ',00
lzer	db	'   0'
ftot	db	CR,LF
	db	'      matching lines found in this file.',CR,LF,00
dtot	db	'      matching lines in all the files searched.',CR,LF,00
;
;	Table of file types to exclude for searchhing
;
table$start
	db	'COM'		;CP/M command file
	db	'OBJ'		;CP/M command file
	db	'LBR'		;LU/LAR library file
	db	'CMD'		;CP/M-86 command file
	db	'REL'		;Relocatable file
	db	'C0M'		;MSDOS command file
	db	'EXE'		;MSDOS command file
	db	'OVR'		;Overlay file
	db	'OVL'		;Overlay file
	db	'CRL'		;BDS C relocatable file
	db	'IRL'		;Libarary file
table$end	
;
	db	00		;fence for line buffer
lbuf	ds	85H		;line buffer
dens	ds	1		;z/nz = un/squeezed
roby	ds	1		;rotating byte
roco	ds	1		;rotation count
mult	ds	1		;r factor
lach	ds	1		;last character read
ictr	ds	2		;input counter
iptr	ds	2		;input pointer
ibuf	ds	isiz		;input buffer
patt	ds	256		;command line pattern
code	ds	4*csiz		;Huffman code table
fini	ds	0

	end

