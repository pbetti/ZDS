
	.z80
; 	aseg

	;subttl	common file for basic interpreter
	;.sall

conto	defl	15		;character to supress output (usually control-o)
dbltrn	defl	0		;for double precision transcendentals

	if	0

	.PRINTX	/EXTENDED/


	.PRINTX	/LPT/

	.PRINTX	/CPM DISK/


	.PRINTX	/Z80/

	.PRINTX	/FAST/

	.PRINTX	/5.0 FEATURES/

	.PRINTX	/ANSI COMPATIBLE/

	endif

clmwid	defl	14		;make comma columns fourteen characters
datpsc	defl	128		;number of data bytes in disk sector
linln	defl	80		;terminal line length
lptlen	defl	132
buflen	defl	255		;long lines
namlen	defl	40		;maximum length name -- 3 to 127

numlev	defl	0*20+19+2*5	;number of stack levels reserved
				;by an explicit call to getstk

strsiz	defl	4

strsiz	defl	3
numtmp	defl	3		;number of string temporaries

numtmp	defl	10

md.rnd	defl	3		;the mode number for random files
md.sqi	defl	1		;the mode number for sequential input files
				;never written into a file
md.sqo	defl	2		;the mode for sequential output files
				;and program files
cpmwrm	defl	0		;cp/m warm boot addr
cpment	defl	cpmwrm+5	;cp/m bdos call addr
	cseg
trurom	defl	0

	;page
	TITLE	BASIC MPU 8080/8085/Z80/8086 (5.11)   /BILL GATES/PAUL ALLEN
	;subttl	version 5.11 -- not many features to go
;
;
;--------- ---- -- ---- ----- --- ---- -----
;copyright 1975 by bill gates and paul allen
;--------- ---- -- ---- ----- --- ---- -----
;
;originally written on the pdp-10 from
;february 9 to  april 9 1975
;
;bill gates wrote a lot of stuff.
;paul allen wrote other stuff and fast code.
;monte davidoff wrote the math package (f4i.mac).
;
;*

	;.xlist
	.list

	extrn	sin,log,exp,cos,tan,atn
	public	frmeql

bufofs	defl	0
bufofs	defl	2			;must crunch into earlier place for single quote
kbflen	defl	buflen+(buflen/4)	;make krunch buffer somewhat
					;larger than source buffer (buf)
	extrn	fname
	public	main,rlist,frmevl,nxtcon
	public	givint
	public	gtbytc,equltk,oldtxt
	public	vartab,gone,docnvf
	public	doasig
	public	fndfor
	public	ready,snerr,repini,intidx,intid2
	public	nxtcon,datptr,errfin,userr,savtxt,nferr,oldtxt
	extrn	outdo,inchri,inlin,crdo,crdonz,strcmp,fininl,ppswrt
	extrn	bltu,bltuc,clear,clearc,gtmprt,islet,islet2,ptrget
	extrn	qinlin,scrtch,stkini,runc,resfin,ptrgt2,stpend,dim
	extrn	dcompr,synchr
	public	getypr
	public	endbuf,buf
	public	strend,curlin,dv0err,chrgtr
	public	errst,errdd,errbs,temp2,aryta2,dimflg,arytab,tstop
	public	errcn
	public	frmevl,givdbl,eval,frmprn,errls,subflg,temp3,errso
	public	vartab,temp8
	extrn	sign
	extrn	open,close,prgfin,filind
	extrn	filinp,clsall,filout,indskc
	extrn	lrun
	extrn	filget
	public	atnfix,cosfix,sinfix,tanfix
	extrn	fpwr
	extrn	inxhrt
	extrn	sgn,abs,sqr,fdiv,fsub,fmult,rnd	;mathpk internals
	extrn	qint,zero,move,fout,fin,fcomp,fadd,pushf,int
	extrn	ends,next,restor,scrath,cont,fre
	extrn	movfr,movrf,movrm,inprt,linprt,fdivt
	extrn	movfm,movmf,floatr,fadds
	public	fac,faclo,overr,newstt,retvar,oldlin,frmchk,brktxt,chrcon
	public	fndlin,arytab,fini
	extrn	inrart,rneg,float
	extrn	stroui,bserr
	public	error,fcerr
	public	topmem
	public	valtyp
	public	tempst,temppt
	public	tmerr
	public	memsiz,fretop
	extrn	cat,frefac,frestr,fretmp,fretms,garba2,strcpy,getstk
	extrn	strlit,strlt2,strlt3,strlti,strout,strprt,stroui
	extrn	getspa,putnew,stop,omerr,reason
	extrn	instr
	extrn	prinus,puttmp
	extrn	fouth,fouto,stro$,strh$
	extrn	str$,len,asc,chr$,left$,right$,mid$,val
	public	errlin,onelin,oneflg,trcflg,buflin,lisprt
	extrn	strng$,space$,ton,toff
	extrn	signs
	public	fbuffr,minutk,plustk,linget,intxt,reddy
	extrn	ttychr
	public	txttab
	extrn	init
	extrn	tstack
	extrn	rndx
	extrn	umult
	extrn	signc,pophrt
	public	cntofl
	extrn	finlpt
	public	lptpos,prtflg
	extrn	consih,vmovfa,vmovaf,isign,conia,getbcd,vsign,vdfacs
	extrn	vmovmf,vmovfm,frcint,frcsng,frcdbl,vneg,pufout,dcxbrt,iadd
	extrn	isub,imult,icomp,ineg,dadd,dsub,dmult,ddiv,dcomp,vint
	extrn	findbl,ineg2

	extrn	idiv,imod
	extrn	vmove,valint,valsng,frcstr,chkstr,makint
	public	prmlen,prmln2,prmflg,nofuns,parm1,temp9
	public	dfaclo,arg,arglo,temp2,temp3,deftbl,funact
	extrn	move1
	public	strprn
	public	caltty
	extrn	scnsem
	public	$for,$while,errwe,errwh,endfor
	extrn	while,wend
	extrn	calls
	extrn	prochk

	extrn	write
	public	data,userr,subflg,temp9,$merge,scnlin
	public	$commo
	public	$delet
	extrn	chain,common

	;reader input

	public	start
start:
	public	jmpini
jmpini:	jp	init		;init is the intialization routine
				;it sets up certain
				;locations deletes functions if
				;desired and
				;changes this to jmp ready
				;warm start for isis

				;of the routine to convert [a,b]
				;to a floating point number in the fac
	defw	frcint		;turn fac into an integer in [h,l]
	defw	makint		;turn [h,l] into a value in the fac
				;set valtyp for integer

	;page
	;;subttl	rom version initalization, and constants
	;page
	;;subttl	dispatch tables, reserved word tables

;define some equivalences in case lptsw & cassw off
cload	defl	snerr
csave	defl	snerr


; these macro calls define the reswrd values
; and the table dispatch for statements and functions

; statements:
stmdsp:	;marks start of statement list
q	defl	128
	defw	ends
q	defl	q+1
$end	defl	q
	defw	for
q	defl	q+1
$for	defl	q
	defw	next
q	defl	q+1
$next	defl	q
	defw	datas
q	defl	q+1
$data	defl	q
	defw	input
q	defl	q+1
$input	defl	q
	defw	dim
q	defl	q+1
$dim	defl	q
	defw	read
q	defl	q+1
$read	defl	q
	defw	let
q	defl	q+1
$let	defl	q
	defw	goto
q	defl	q+1
$goto	defl	q
	defw	run
q	defl	q+1
$run	defl	q
	defw	ifs
q	defl	q+1
$if	defl	q
	defw	restor
q	defl	q+1
$resto	defl	q
	defw	gosub
q	defl	q+1
$gosub	defl	q
	defw	return
q	defl	q+1
$retur	defl	q
	defw	rem
q	defl	q+1
$rem	defl	q
	defw	stop
q	defl	q+1
$stop	defl	q
	defw	print
q	defl	q+1
$print	defl	q
	defw	clear
q	defl	q+1
$clear	defl	q
	defw	rlist
q	defl	q+1
$list	defl	q
	defw	scrath
q	defl	q+1
$new	defl	q

; 8k and above statements

	defw	ongoto
q	defl	q+1
$on	defl	q
	extrn	null
	defw	null
q	defl	q+1
$null	defl	q

	defw	fnwait
q	defl	q+1
$wait	defl	q
	defw	def
q	defl	q+1
$defi	defl	q
	defw	poke
q	defl	q+1
$poke	defl	q
	defw	cont
q	defl	q+1
$cont	defl	q
	defw	csave
q	defl	q+1
$csave	defl	q
	defw	cload
q	defl	q+1
$cload	defl	q

	defw	fnout
q	defl	q+1
$out	defl	q
	defw	lprint
q	defl	q+1
$lprin	defl	q
	defw	llist
q	defl	q+1
$llist	defl	q

; len2 and above statements

	public	iogor
iogor:	;dont allow console if code deleted
	defs	2
q	defl	q+1		;pad the hole
	defw	width
q	defl	q+1
$width	defl	q
	defw	elses
q	defl	q+1
$else	defl	q
	defw	ton
q	defl	q+1
$tron	defl	q
	defw	toff
q	defl	q+1
$troff	defl	q
	extrn	swap
	defw	swap
q	defl	q+1
$swap	defl	q
	defw	erase
q	defl	q+1
$erase	defl	q
	extrn	erase
	extrn	edit
	defw	edit
q	defl	q+1
$edit	defl	q
	defw	errors
q	defl	q+1
$error	defl	q
	defw	resume
q	defl	q+1
$resum	defl	q
	defw	delete
q	defl	q+1
$delet	defl	q
	defw	auto
q	defl	q+1
$auto	defl	q
	defw	reseq
q	defl	q+1
$renum	defl	q

; extended and above

	defw	defstr
q	defl	q+1
$defst	defl	q
	defw	defint
q	defl	q+1
$defin	defl	q
	defw	defrea
q	defl	q+1
$defsn	defl	q
	defw	defdbl
q	defl	q+1
$defdbi	defl	q
	defw	line
q	defl	q+1
$line	defl	q


;***********
; padding initially set to 10
q	defl	q+2
	defs	4
	defw	while
q	defl	q+1
$while	defl	q
	defw	wend
q	defl	q+1
$wend	defl	q
	defw	calls
q	defl	q+1
$call	defl	q
	defw	write
q	defl	q+1
$write	defl	q
	defw	datas
q	defl	q+1
$commo	defl	q
	defw	chain
q	defl	q+1
$chain	defl	q
	defw	option
q	defl	q+1
$optio	defl	q
	defw	random
q	defl	q+1
$rando	defl	q

; disk and above

	defs	2
q	defl	q+1
	extrn	system
	defw	system
q	defl	q+1
$syste	defl	q
q	defl	q+1
	defs	2
	extrn	field,get,put,load,merge
	defw	open
q	defl	q+1
$open	defl	q
	defw	field
q	defl	q+1
$field	defl	q
	defw	get
q	defl	q+1
$get	defl	q
	defw	put
q	defl	q+1
$put	defl	q
	defw	close
q	defl	q+1
$close	defl	q
	defw	load
q	defl	q+1
$load	defl	q
	defw	merge
q	defl	q+1
$merge	defl	q
	extrn	files
	defw	files
q	defl	q+1
$files	defl	q
	extrn	fname
	defw	fname
q	defl	q+1
$name	defl	q
	extrn	kill,lset,rset,save
	defw	kill
q	defl	q+1
$kill	defl	q
	defw	lset
q	defl	q+1
$lset	defl	q
	defw	rset
q	defl	q+1
$rset	defl	q
	defw	save
q	defl	q+1
$save	defl	q
	extrn	reset
	defw	reset
q	defl	q+1
$reset	defl	q
; ncr version ones.

numcmd	defl	q-$end+1
; tokens
;**********
;padding initially set to 2 between last disk statement and tokens
;padding set to 1 - feb 4, 1977
q	defl	q+1
;q must be set so tokens start at right place


q	defl	q+1
$to	defl	q
$to	defl	q
q	defl	q+1
$then	defl	q
thentk	defl	q
q	defl	q+1
$tab	defl	q
tabtk	defl	q
q	defl	q+1
$step	defl	q
steptk	defl	q

q	defl	q+1
$usr	defl	q
usrtk	defl	q
; 8k functions

q	defl	q+1
$fn	defl	q
fntk	defl	q
q	defl	q+1
$spc	defl	q
spctk	defl	q
q	defl	q+1
$not	defl	q
nottk	defl	q

; len2 tokens

q	defl	q+1
$erl	defl	q
erltk	defl	q
q	defl	q+1
$err	defl	q
erctk	defl	q

; extended tokens

q	defl	q+1
$strin	defl	q
q	defl	q+1
$using	defl	q
usintk	defl	q
q	defl	q+1
$instr	defl	q
insrtk	defl	q
q	defl	q+1
$dummy	defl	q
sngqtk	defl	q
q	defl	q+1
$varpt	defl	q

;ncr version tokens

;spcdsk tokens
q	defl	q+1
$inkey	defl	q
	public	$inkey
q	defl	q-1		;make sure doesnt interfere with reswrds below
;*********
;padding initially set to 18
q	defl	q+18

; operators

q	defl	q+1
$dummy	defl	q
greatk	defl	q
q	defl	q+1
$dummy	defl	q
equltk	defl	q
q	defl	q+1
$dummy	defl	q
lesstk	defl	q
q	defl	q+1
$dummy	defl	q
plustk	defl	q
q	defl	q+1
$dummy	defl	q
minutk	defl	q
q	defl	q+1
$dummy	defl	q
multk	defl	q
q	defl	q+1
$dummy	defl	q
divtk	defl	q


; 8k operators

q	defl	q+1
$dummy	defl	q
exptk	defl	q
q	defl	q+1
$and	defl	q
q	defl	q+1
$or	defl	q

; extended operators

q	defl	q+1
$xor	defl	q
q	defl	q+1
$eqv	defl	q
q	defl	q+1
$imp	defl	q
q	defl	q+1
$mod	defl	q
q	defl	q+1
$dummy	defl	q
idivtk	defl	q
lstopk	defl	q+1-plustk

; functions

q	defl	128
fundsp:
	defw	left$
q	defl	q+1
$left$	defl	q
onefun	defl	q
	defw	right$
q	defl	q+1
$right	defl	q
	defw	mid$
q	defl	q+1
$mid$	defl	q
midtk	defl	q
	defw	sgn
q	defl	q+1
$sgn	defl	q
	defw	vint
q	defl	q+1
$int	defl	q
	defw	abs
q	defl	q+1
$abs	defl	q
sqrfix:
	defw	sqr
q	defl	q+1
$sqr	defl	q
sqrtk	defl	q
	defw	rnd
q	defl	q+1
$rnd	defl	q
sinfix:
	defw	sin
q	defl	q+1
$sin	defl	q

; 8k functions

	defw	log
q	defl	q+1
$log	defl	q
	defw	exp
q	defl	q+1
$exp	defl	q
cosfix:
	defw	cos
q	defl	q+1
$cos	defl	q
tanfix:
	defw	tan
q	defl	q+1
$tan	defl	q
atnfix:
	defw	atn
q	defl	q+1
$atn	defl	q
atntk	defl	q
	defw	fre
q	defl	q+1
$fre	defl	q

	defw	fninp
q	defl	q+1
$inp	defl	q
	defw	pos
q	defl	q+1
$pos	defl	q
	defw	len
q	defl	q+1
$len	defl	q
	defw	str$
q	defl	q+1
$str$	defl	q
	defw	val
q	defl	q+1
$val	defl	q
	defw	asc
q	defl	q+1
$asc	defl	q
	defw	chr$
q	defl	q+1
$chr$	defl	q
	defw	peek
q	defl	q+1
$peek	defl	q
	defw	space$
q	defl	q+1
$space	defl	q
	defw	stro$
q	defl	q+1
$oct$	defl	q
	defw	strh$
q	defl	q+1
$hex$	defl	q
	defw	lpos
q	defl	q+1
$lpos	defl	q
lasnum	defl	q

; extended functions

	defw	frcint
q	defl	q+1
$cint	defl	q
	defw	frcsng
q	defl	q+1
$csng	defl	q
	defw	frcdbl
q	defl	q+1
$cdbl	defl	q
	extrn	fixer
	defw	fixer
q	defl	q+1
$dummy	defl	q
$fix	defl	q

;ncr version functions


; disk functions

;**********
;padding initially set to 10
q	defl	q+10
	defs	20
	defs	2		;pad in the hole
q	defl	q+1
	extrn	cvi,cvs,cvd
	defw	cvi
q	defl	q+1
$cvi	defl	q
	defw	cvs
q	defl	q+1
$cvs	defl	q
	defw	cvd
q	defl	q+1
$cvd	defl	q
	defs	2		;pad in the hole
q	defl	q+1
	extrn	eof,loc
	defw	eof
q	defl	q+1
$eof	defl	q
	defw	loc
q	defl	q+1
$loc	defl	q
	extrn	lof
	defw	lof
q	defl	q+1
$lof	defl	q
	extrn	mki$,mks$,mkd$
	defw	mki$
q	defl	q+1
$mki$	defl	q
	defw	mks$
q	defl	q+1
$mks$	defl	q
	defw	mkd$
q	defl	q+1
$mkd$	defl	q
	;end disk functions

; spcdsk functions
; the following tables are the alphabetic dispatch table
; followed by the reserved word table itself

alptab:

	defw	atab
	defw	btab
	defw	ctab
	defw	dtab
	defw	etab
	defw	ftab
	defw	gtab
	defw	htab
	defw	itab
	defw	jtab
	defw	ktab
	defw	ltab
	defw	mtab
	defw	ntab
	defw	otab
	defw	ptab
	defw	qtab
	defw	rtab
	defw	stab
	defw	ttab
	defw	utab
	defw	vtab
	defw	wtab
	defw	xtab
	defw	ytab
	defw	ztab


; the following macro is for functions. it doesnt turn the token bit 7 on.

reslst:

atab:
	defb	'N'
	defb	'D' or 128
	defb	$and
	defb	'B'
	defb	'S' or 128
	defb	$abs-128
	defb	'T'
	defb	'N' or 128
	defb	$atn-128
	defb	'S'
	defb	'C' or 128
	defb	$asc-128
	defb	'UT'
	defb	'O' or 128
	defb	$auto
	defb	0

btab:
	defb	0

ctab:
	defb	'LOS'
	defb	'E' or 128
	defb	$close
	defb	'ON'
	defb	'T' or 128
	defb	$cont
	defb	'LEA'
	defb	'R' or 128
	defb	$clear
	defb	'IN'
	defb	'T' or 128
	defb	$cint-128
	defb	'SN'
	defb	'G' or 128
	defb	$csng-128
	defb	'DB'
	defb	'L' or 128
	defb	$cdbl-128
	defb	'V'
	defb	'I' or 128
	defb	$cvi-128
	defb	'V'
	defb	'S' or 128
	defb	$cvs-128
	defb	'V'
	defb	'D' or 128
	defb	$cvd-128
	defb	'O'
	defb	'S' or 128
	defb	$cos-128
	defb	'HR'
	defb	'$' or 128
	defb	$chr$-128
	defb	'AL'
	defb	'L' or 128
	defb	$call
	defb	'OMMO'
	defb	'N' or 128
	defb	$commo
	defb	'HAI'
	defb	'N' or 128
	defb	$chain
	defb	0

dtab:
	defb	'AT'
	defb	'A' or 128
	defb	$data
	defb	'I'
	defb	'M' or 128
	defb	$dim
	defb	'EFST'
	defb	'R' or 128
	defb	$defst
	defb	'EFIN'
	defb	'T' or 128
	defb	$defin
	defb	'EFSN'
	defb	'G' or 128
	defb	$defsn
	defb	'EFDB'
	defb	'L' or 128
	defb	$defdbi
	defb	'E'
	defb	'F' or 128
	defb	$defi
	defb	'ELET'
	defb	'E' or 128
	defb	$delet


	defb	0

etab:
	defb	'N'
	defb	'D' or 128
	defb	$end
	defb	'LS'
	defb	'E' or 128
	defb	$else
	defb	'RAS'
	defb	'E' or 128
	defb	$erase
	defb	'DI'
	defb	'T' or 128
	defb	$edit
	defb	'RRO'
	defb	'R' or 128
	defb	$error
	defb	'R'
	defb	'L' or 128
	defb	$erl
	defb	'R'
	defb	'R' or 128
	defb	$err
	defb	'X'
	defb	'P' or 128
	defb	$exp-128
	defb	'O'
	defb	'F' or 128
	defb	$eof-128
	defb	'Q'
	defb	'V' or 128
	defb	$eqv
	defb	0

ftab:
	defb	'O'
	defb	'R' or 128
	defb	$for
	defb	'IEL'
	defb	'D' or 128
	defb	$field
	defb	'ILE'
	defb	'S' or 128
	defb	$files
	defb	''
	defb	'N' or 128
	defb	$fn
	defb	'R'
	defb	'E' or 128
	defb	$fre-128
	defb	'I'
	defb	'X' or 128
	defb	$fix-128



	defb	0

gtab:
	defb	'OT'
	defb	'O' or 128
	defb	$goto
	defb	'O'
	defb	' '
	defb	'T'
	defb	'O'+128
	defb	$goto
	defb	'OSU'
	defb	'B' or 128
	defb	$gosub
	defb	'E'
	defb	'T' or 128
	defb	$get
	defb	0

htab:
	defb	'EX'
	defb	'$' or 128
	defb	$hex$-128
	defb	0

itab:
	defb	'NPU'
	defb	'T' or 128
	defb	$input
	defb	''
	defb	'F' or 128
	defb	$if
	defb	'NST'
	defb	'R' or 128
	defb	$instr
	defb	'N'
	defb	'T' or 128
	defb	$int-128
	defb	'N'
	defb	'P' or 128
	defb	$inp-128
	defb	'M'
	defb	'P' or 128
	defb	$imp
	defb	'NKEY'
	defb	'$' or 128
	defb	$inkey
	defb	0

jtab:
	defb	0

ktab:
	defb	'IL'
	defb	'L' or 128
	defb	$kill
	defb	0

ltab:
	defb	'E'
	defb	'T' or 128
	defb	$let
	defb	'IN'
	defb	'E' or 128
	defb	$line
	defb	'OA'
	defb	'D' or 128
	defb	$load
	defb	'SE'
	defb	'T' or 128
	defb	$lset
	defb	'PRIN'
	defb	'T' or 128
	defb	$lprin
	defb	'LIS'
	defb	'T' or 128
	defb	$llist
	defb	'PO'
	defb	'S' or 128
	defb	$lpos-128
	defb	'IS'
	defb	'T' or 128
	defb	$list
	defb	'O'
	defb	'G' or 128
	defb	$log-128
	defb	'O'
	defb	'C' or 128
	defb	$loc-128
	defb	'E'
	defb	'N' or 128
	defb	$len-128
	defb	'EFT'
	defb	'$' or 128
	defb	$left$-128
	defb	'O'
	defb	'F' or 128
	defb	$lof-128
	defb	0

mtab:
	defb	'ERG'
	defb	'E' or 128
	defb	$merge
	defb	'O'
	defb	'D' or 128
	defb	$mod
	defb	'KI'
	defb	'$' or 128
	defb	$mki$-128
	defb	'KS'
	defb	'$' or 128
	defb	$mks$-128
	defb	'KD'
	defb	'$' or 128
	defb	$mkd$-128
	defb	'ID'
	defb	'$' or 128
	defb	$mid$-128
	defb	0

ntab:
	defb	'EX'
	defb	'T' or 128
	defb	$next
	defb	'UL'
	defb	'L' or 128
	defb	$null
	defb	'AM'
	defb	'E' or 128
	defb	$name
	defb	'E'
	defb	'W' or 128
	defb	$new
	defb	'O'
	defb	'T' or 128
	defb	$not
	defb	0

otab:
	defb	'U'
	defb	'T' or 128
	defb	$out
	defb	''
	defb	'N' or 128
	defb	$on
	defb	'PE'
	defb	'N' or 128
	defb	$open
	defb	''
	defb	'R' or 128
	defb	$or
	defb	'CT'
	defb	'$' or 128
	defb	$oct$-128

	defb	'PTIO'
	defb	'N' or 128
	defb	$optio

	defb	0

ptab:
	defb	'U'
	defb	'T' or 128
	defb	$put
	defb	'OK'
	defb	'E' or 128
	defb	$poke
	defb	'RIN'
	defb	'T' or 128
	defb	$print
	defb	'O'
	defb	'S' or 128
	defb	$pos-128
	defb	'EE'
	defb	'K' or 128
	defb	$peek-128
	defb	0
qtab:
	defb	0

rtab:
	defb	'EA'
	defb	'D' or 128
	defb	$read
	defb	'U'
	defb	'N' or 128
	defb	$run
	defb	'ESTOR'
	defb	'E' or 128
	defb	$resto
	defb	'ETUR'
	defb	'N' or 128
	defb	$retur
	defb	'E'
	defb	'M' or 128
	defb	$rem
	defb	'ESUM'
	defb	'E' or 128
	defb	$resum
	defb	'SE'
	defb	'T' or 128
	defb	$rset
	defb	'IGHT'
	defb	'$' or 128
	defb	$right-128
	defb	'N'
	defb	'D' or 128
	defb	$rnd-128
	defb	'ENU'
	defb	'M' or 128
	defb	$renum
	defb	'ESE'
	defb	'T' or 128
	defb	$reset
	defb	'ANDOMIZ'
	defb	'E' or 128
	defb	$rando
	defb	0

stab:
	defb	'TO'
	defb	'P' or 128
	defb	$stop
	defb	'WA'
	defb	'P' or 128
	defb	$swap
	defb	'AV'
	defb	'E' or 128
	defb	$save
	defb	'P'
	defb	'C'
	defb	'('+128
	defb	spctk
	defb	'TE'
	defb	'P' or 128
	defb	$step
	defb	'G'
	defb	'N' or 128
	defb	$sgn-128
	defb	'Q'
	defb	'R' or 128
	defb	$sqr-128
	defb	'I'
	defb	'N' or 128
	defb	$sin-128
	defb	'TR'
	defb	'$' or 128
	defb	$str$-128
	defb	'TRING'
	defb	'$' or 128
	defb	$strin
	defb	'PACE'
	defb	'$' or 128
	defb	$space-128

	defb	'YSTE'
	defb	'M' or 128
	defb	$syste
	defb	0

ttab:
	defb	'RO'
	defb	'N' or 128
	defb	$tron
	defb	'ROF'
	defb	'F' or 128
	defb	$troff
	defb	'A'
	defb	'B'
	defb	'('+128
	defb	tabtk
	defb	''
	defb	'O' or 128
	defb	$to
	defb	'HE'
	defb	'N' or 128
	defb	$then
	defb	'A'
	defb	'N' or 128
	defb	$tan-128
	defb	0

utab:
	defb	'SIN'
	defb	'G' or 128
	defb	$using
	defb	'S'
	defb	'R' or 128
	defb	$usr
	defb	0

vtab:
	defb	'A'
	defb	'L' or 128
	defb	$val-128
	defb	'ARPT'
	defb	'R' or 128
	defb	$varpt
	defb	0

wtab:
	defb	'IDT'
	defb	'H' or 128
	defb	$width
	defb	'AI'
	defb	'T' or 128
	defb	$wait
	defb	'HIL'
	defb	'E' or 128
	defb	$while
	defb	'EN'
	defb	'D' or 128
	defb	$wend
	defb	'RIT'
	defb	'E' or 128
	defb	$write
	defb	0

xtab:
	defb	'O'
	defb	'R' or 128
	defb	$xor
	defb	0
ytab:
	defb	0
ztab:
	defb	0

spctab:
	defb	'+'+128
	defb	plustk
	defb	'-'+128
	defb	minutk
	defb	'*'+128
	defb	multk
	defb	'/'+128
	defb	divtk
	defb	'^'+128
	defb	exptk
	defb	'\'+128
	defb	idivtk
	defb	''''+128
	defb	sngqtk
	defb	'>'+128
	defb	greatk
	defb	'='+128
	defb	equltk
	defb	'<'+128
	defb	lesstk
	defb	0

optab:	defb	121	;operator table contains
			;precedence followed by
			;the routine address
	defb	121
	defb	124
	defb	124
	defb	127
	defb	80
	defb	70
	defb	60		;precedence of "XOR"
	defb	50		;precedence of "EQV"
	defb	40		;precedence of "IMP"
	defb	122		;precedence of "MOD"
	defb	123		;precedence of "IDIV"

;
; used by assignment code to force the right hand value
; to correspond to the value type of the variable being
; assigned to.
;
frctbl:	defw	frcdbl
	defs	2
	defw	frcint
	defw	chkstr
	defw	frcsng
;
; these tables are used after the decision has been made
; to apply an operator and all the necessary conversion has
; been done to match the two argument types (applop)
;
dbldsp:	defw	dadd		;double precision routines
	defw	dsub
	defw	dmult
	defw	ddiv
	defw	dcomp
opcnt	defl	(($-dbldsp)/2)-1
sngdsp:	defw	fadd		;single precision routines
	defw	fsub
	defw	fmult
	defw	fdiv
	defw	fcomp
intdsp:	defw	iadd		;integer routines
	defw	isub
	defw	imult
	defw	intdiv
	defw	icomp
	page
	;subttl	error message table

q	defl	-2

errtab:
	defb	0
q	defl	0
q	defl	q+1
	defb	'NEXT without FOR',0
errnf	defl	q
q	defl	q+1
	defb	'Syntax error',0
errsn	defl	q
q	defl	q+1
	defb	'RETURN without GOSUB',0
errrg	defl	q
q	defl	q+1
	defb	'Out of DATA',0
errod	defl	q
q	defl	q+1
	defb	'Illegal function call',0
errfc	defl	q
	public	ovrmsg
ovrmsg:
q	defl	q+1
	defb	'Overflow',0
errov	defl	q
q	defl	q+1
	defb	'Out of memory',0
	public	errom
errom	defl	q
q	defl	q+1
	defb	'Undefined line number',0
errus	defl	q
q	defl	q+1
	defb	'Subscript out of range',0
errbs	defl	q
q	defl	q+1
	defb	'Duplicate Definition',0
errdd	defl	q
	public	divmsg
divmsg:
q	defl	q+1
	defb	'Division by zero',0
errdv0	defl	q
q	defl	q+1
	defb	'Illegal direct',0
errid	defl	q
q	defl	q+1
	defb	'Type mismatch',0
errtm	defl	q
q	defl	q+1
	defb	'Out of string space',0
errso	defl	q
q	defl	q+1
	defb	'String too long',0
errls	defl	q
q	defl	q+1
	defb	'String formula too complex',0
errst	defl	q
q	defl	q+1
	defb	'Can''t continue',0
errcn	defl	q
q	defl	q+1
	defb	'Undefined user function',0
erruf	defl	q
q	defl	q+1
	defb	'No RESUME',0
errnr	defl	q
q	defl	q+1
	defb	'RESUME without error',0
errre	defl	q
q	defl	q+1
	defb	'Unprintable error',0
errue	defl	q
q	defl	q+1
	defb	'Missing operand',0
errmo	defl	q
	public	errlbo
q	defl	q+1
	defb	'Line buffer overflow',0
errlbo	defl	q

q	defl	q+1
	defb	'?',0
q	defl	q+1
	defb	'?',0
q	defl	q+1
	defb	'FOR Without NEXT',0
errfn	defl	q
q	defl	q+1
	defb	'?',0
q	defl	q+1
	defb	'?',0
q	defl	q+1
	defb	'WHILE without WEND',0
errwh	defl	q
q	defl	q+1
	defb	'WEND without WHILE',0
errwe	defl	q
q	defl	q+1
	defb	'Graphics statement not implemented',0
errgs	defl	q
nondsk	defl	q		;last non disk error.

q	defl	49		;disk errors start at 50.
dskerr	defl	q		;first disk error
q	defl	q+1
	defb	'FIELD overflow',0
	public	errfov
errfov	defl	q
q	defl	q+1
	defb	'Internal error',0
	public	errier
errier	defl	q
q	defl	q+1
	defb	'Bad file number',0
	public	errbfn
errbfn	defl	q
q	defl	q+1
	defb	'File not found',0
	public	errfnf
errfnf	defl	q
q	defl	q+1
	defb	'Bad file mode',0
errbfm	defl	q
q	defl	q+1
	defb	'File already open',0
errfao	defl	q
q	defl	q+1
	defb	'?',0		;pad in hole
dskloc	defl	$+6
q	defl	q+1
	defb	'Disk I/O error',0
errioe	defl	q
q	defl	q+1
	defb	'File already exists',0
errfae	defl	q
q	defl	q+1
	defb	'?',0
q	defl	q+1
	defb	'?',0		;pad in hole
q	defl	q+1
	defb	'Disk full',0
errdfl	defl	q
q	defl	q+1
	defb	'Input past end',0
errrpe	defl	q
q	defl	q+1
	defb	'Bad record number',0
errbrn	defl	q
q	defl	q+1
	defb	'Bad file name',0
errnmf	defl	q
q	defl	q+1
	defb	'?',0
errmmm	defl	q
q	defl	q+1
	defb	'Direct statement in file',0
	public	errfdr
errfdr	defl	q
q	defl	q+1
	defb	'Too many files',0
errtmf	defl	q

lsterr	defl	q+1	;last error used for range checks in len2

	page
	;subttl	constants for rom basic i/o, rndx, fdiv, usrgo
	page
	;subttl	low segment -- ram -- ie this stuff is not constant
;
; this is the "VOLATILE" storage area and none of it
; can be kept in rom. any constants in this area cannot
; be kept in a rom, but must be loaded in by the
; program instructions in rom.
;

usrtab:
	defw	fcerr
	defw	fcerr
	defw	fcerr
	defw	fcerr
	defw	fcerr
	defw	fcerr
	defw	fcerr
	defw	fcerr
	defw	fcerr
	defw	fcerr		;set up dispatches
	public	nulcnt
nulcnt:	defb	1		;store here the number of nulls
				;to print after crlf
	public	charc
charc:	defb	0		;iscntc stores eaten char here when not a ^c
	public	errflg
errflg:	defb	0		;used to save the error number so edit can be
				;called on "SYNTAX ERROR"
	public	lptlst
lptlst:	defb	0		;last line printer operation. zero means linefeed
				;non-zero means print command (okia only)
lptpos:	defb	1		;position of lpt print head
prtflg:	defb	0		;whether output goes to lpt
	public	nlppos,lptsiz
lncmps	defl	(((lptlen/clmwid)-1)*clmwid);last comma field posit
nlppos:	defb	lncmps		;last col # beyond which no more comma fields
lptsiz:	defb	lptlen		;default line printer width
	public	linlen
linlen:	defb	linln		;line length
ncmpos	defl	(((linln/clmwid)-1)*clmwid)	;position beyond which there are
				;no more comma fields
clmlst:	defb	ncmpos		;position of last comma column
				;non-zero means send output to lpt
	public	rubsw
rubsw:	defb	0		;rubout switch =1 inside
				;the processing of a rubout (inlin)
cntofl:	defb	0		;supress output flag
				;non-zero means supress
				;reset by "INPUT",ready and errors
				;complemented by input of ^o
	public	ptrfil
ptrfil:	defw	0		;pointer to data block of current file
				;used by disk and ncr cassette code

topmem:
	defw	tstack+100	;top location to use for the stack
				;initially set up by init
				;according to memory size
				;to allow for 50 bytes of string space.
				;changed by a clear command with
				;an argument.
curlin:	defw	0+65534		;current line #
				;set to 65534 in pure version during init execution
				;set to 65535 when direct statements execute
txttab:	defw	tstack+1	;pointer to beginning of text
				;doesn'T CHANGE AFTER BEING
				;setup by init.
	public	overri
overri:	defw	ovrmsg		;address of message to print (overflow)
				;data segment again
;
;	end of initialized part of ram
;
;
; disk data storage area
;
	public	lstfre,maxtrk,dskmod,filpt1,filptr,maxfil
lstfre:	defs	2		;free place in directory
maxtrk:	defs	1		;allocate inside this track
dskmod:	defs	1		;mode of file just looked up
				;zero if file was just created
filpt1:	defs	2		;[filptr] always refetched from here
filptr:	defs	32		;pointers to data blocks for each file
maxfil:	defs	1		;highest file number allowed
	public	namcnt,nambuf,namtmp
namcnt:	defs	1		;the number of character beyond #2 in a var name
nambuf:	defs	namlen-2	;storage for chars beyond #2. used in ptrget
namtmp:	defs	2		;temp storage during name save at indlop
	public	dirtmp,filna2,filnam
dirtmp	defl	cpmwrm+128	;use cpm default buffer in low memory
filna2:	defs	16		;used by name code
filnam:	defs	33		;because cpm must have buffer for directory reads

;	cp/m 1.4 and 2.x support

	public	cpmvrn,cpmrea,cpmwri

cpmvrn:	defs	1	;cp/m version number (#0 is 2.x)
cpmrea:	defs	1		;cp/m read call
cpmwri:	defs	1		;cp/m write call
	defb	':'		;a colon for restarting input
kbuf:	defs	kbflen		;this is the krunch buffer
	public	bufmin
bufmin:	defb	44		;a comma (preload or rom)
				;used by input statement since the
				;data pointer always starts on a
				;comma or terminator
buf:	defs	buflen+1	;type in stored here
				;direct statements execute out of
				;here. remember "INPUT" smashes buf.
				;must be at a lower address
				;than dsctmp or assignment of string
				;values in direct statements won'T COPY
				;into string space -- which it must
	defs	2		;allow for single quote in big line
endbuf:	defs	1		;place to stop big lines
	public	ttypos
ttypos:	defs	1		;store terminal position here
dimflg:	defs	1		;in getting a pointer to a variable
				;it is important to remember whether it
				;is being done for "DIM" or not
				;dimflg and valtyp must be
				;consecutive locations
valtyp:	defs	1		;the type indicator
				;in the 8k 0=numeric 1=string
oprtyp:				;used to store operator number
				;in the extended momentarily before
				;operator application (applop)
dores:	defs	1		;whether can or can'T CRUNCH RES'd words
				;turned on in the 8k when "DATA"
				;being scanned by crunch so unquoted
				;strings won'T BE CRUNCHED.
donum:	defs	1		;flag for crunch =0 means
				;numbers allowed, (floating,int, dbl)
				;1 means numbers allowed, krunch by calling linget
				;-1 (377) means numbers disallowed
				;(scanning variable name)
contxt:	defs	2		;saved text pointer used by chrget
				;to save the text pointer after constant
				;has been scanned.
consav:	defs	1		;the saved token for a constant
				;after chrget has been called
contyp:	defs	1		;saved constant valtype
conlo:	defs	4		;saved constant value
	defs	4		;extra four bytes for double precision
memsiz:	defs	2		;highest location in memory
temppt:	defs	2		;pointer at first free temp descriptor
				;initialized to point to tempst
tempst:	defs	strsiz*numtmp	;storage for numtmp temp descriptors
	public	dsctmp,dscptr
dsctmp:	defs	strsiz		;string functions build answer descriptor here
				;must be after tempst and before parm1
dscptr	defl	$-2		;where string address is store in dsctmp
fretop:	defs	2		;top of string free space
temp3:	defs	2		;used to store the address of the end of
				;string arrays in garbage collection
				;and used momentarily by frmevl
				;used in extended by fout and
				;user defined functions
				;array variable handling temporary
temp8:	defs	2		;7/3/79 now used by garbage collection
				;not temp3 due to conflict
endfor:	defs	2		;saved text pointer at end of "FOR" statement
datlin:	defs	2		;data line # -- remember for errors
subflg:	defs	1		;flag whether subscripted variable allowed
				;"FOR" and user-defined function
				;pointer fetching turn
				;this on before calling ptrget
				;so arrays won'T BE DETECTED.
				;stkini and ptrget clear it.
	public	usflg
usflg:
flginp:	defs	1		;flags whether we are doing "INPUT"
				;or a read
	public	temp
temp:	defs	2		;temporary for statement code
				;newstt saves [h,l] here for input and ^c
				;"LET" saves variable
				;pointers here for "FOR"
				;"NEXT" saves its text pointer here
				;clearc saves [h,l] here
	public	ptrflg
ptrflg:	defs	1		;=0 if no line numbers converted
				;to pointers, non zero if pointers exist.
	public	autflg
autflg:	defs	1		;flag to inicate auto command in
				;progress =0 if not, non-zero if so.
autlin:	defs	2		;current line being inserted by auto
autinc:	defs	2		;the auto increment
savtxt:	defs	2		;place where newstt saves text pointer
				;for "RESUME" statement
	public	savstk,errlin
savstk:	defs	2		;newstt saves stack here before
				;so that error revery can
				;can restore the stack when an
				;error occurs
errlin:	defs	2		;line number where last error occured.
	public	dot
dot:	defs	2		;keeps current line for edit & list
errtxt:	defs	2		;text pointer for use by "RESUME"
	public	onelin
onelin:	defs	2		;the line to goto when an error
				;occurs
oneflg:	defs	1		;oneflg=1 if were are executing
				;an error trap routine, otherwise 0
temp2:	defs	2		;formula evaluator temp
				;must be preserved by operators
				;used in extended by fout and
				;user-defined functions
				;array variable handler temporary
oldlin:	defs	2		;old line number (setup by ^c,"STOP"
				;or "END" in a program)
oldtxt:	defs	2		;old text pointer
				;points at statement to be executed next
vartab:	defs	2		;pointer to start of simple
				;variable space
				;updated whenever the size of the
				;program changes, set to [txttab]
				;by scratch ("NEW").
arytab:	defs	2		;pointer to beginning of array
				;table
				;incremented by 6 whenever
				;a new simple variable is found, and
				;set to [vartab] by clearc.
strend:	defs	2		;end of storage in use
				;increased whenever a new array
				;or simple variable is encountered
				;set to [vartab] by clearc.
datptr:	defs	2		;pointer to data. initialized to point
				;at the zero in front of [txttab]
				;by "RESTORE" which is called by clearc
				;updated by execution of a "READ"
deftbl:	defs	26		;this gives the default valtyp for each
				;letter of the alphabet
				;it is set up by "CLEAR" and changed by
				;"DEFSTR" "DEFINT" "DEFSNG" "DEFDBL" and used
				;by ptrget when ! # % or $ don'T FOLLOW
				;a varaible name
;
; ram storage for user defined function parameter information
;
prmsiz	defl	100		;number of bytes for definition block
prmstk:	defw	0		;previous definition block on stack
				;block (for garbage collection)
prmlen:	defs	2		;the number of bytes in the active table
parm1:	defs	prmsiz		;the active parameter definition table
	public	prmprv,prmstk	;allow init to initialize this constant
prmprv:	defw	prmstk		;the pointer at the previous parameter
				;block (for garbage collection)
prmln2:	defs	2		;size of parameter block being built
parm2:	defs	prmsiz		;place to keep parameters being made
prmflg:	defs	1		;used by ptrget to flag if parm1 has been searched
aryta2:	defs	2		;stopping point for simple search
				;(either [arytab] or parm1+[prmlen])
nofuns:	defs	1		;zero if no functions active. saves time in simple search
temp9:	defs	2		;garbage collection temp to chain through parameter blocks
funact:	defs	2		;count of active functions
	public	inppas,nxttxt,nxtflg,fvalsv,nxtlin,optval,optflg
inppas:	defs	1		;flag telling whether input is scanning first or
				;second time. zero if first.
nxttxt:	defs	2		;used to save text pointer at start of next
nxtflg:	defs	1		;zero if "FOR" is using next code
				;to check for empty loop
fvalsv:	defs	4		;use to store the start value of the loop variable
				;since ansi says start and end are evaluated
				;before assignment takes place
nxtlin:	defs	2		;the line number during scan for "NEXT"
optval:	defs	1		;zero for option base 0 one for option base 1
optflg:	defs	1		;non-zero if "OPTION BASE" has been scanned
	public	patch
patch:	defs	30		;thirty bytes of patch space
	public	tempa
tempa:	defs	2		;misc temp used by call and list
	public	savfre
savfre:	defs	2		;fretop saved here by chain
	public	maxrec
maxrec:	defs	2		;maximum record size
	public	proflg
proflg:	defs	1		;non-zero if we have loaded a protected file w/o passwrd
	public	chnflg,chnlin,mdlflg,mrgflg,cmeptr,cmsptr
mrgflg:	defs	1		;non-zero if chain w/ merge in progress
mdlflg:	defs	1		;non-zero i chain w/ merge and delete in progress
cmeptr:	defs	2		;pointer tto end line to delete
cmsptr:	defs	2		;pointer to start line to delete
chnflg:	defs	1		;non-zero if chain in progress
chnlin:	defs	2		;destination line in new program
	public	swptmp
swptmp:	defs	4		;value of first "SWAP" variable stored here
	defs	4		;enough room for double precision
trcflg:	defs	1		;zero means no trace in progress

; this is the ram termporary area for the math package routines
;
				;the floating accumulator
	defs	1		;[temporary least significant byte]
dfaclo:	defs	4		;[four lowest orders for double precision]
faclo:	defs	2
	defs	1
				;[middle order of mantissa]
				;[high order of mantissa]
fac:	defs	2		;[exponent]
				;[temporary complement of sign in msb]
	public	fansii
	public	flgovc,ovcstr
flgovc:	defs	1		;overflow print flag,=0,1 print
				;further =1 change to 2
ovcstr:	defs	1		;place to store overflow flag after fin
fansii:	defs	1		;flag to force fixed output (see ansi)
	defs	1		;[temporary least significant byte]
arglo:	defs	7		;[location of second argument for double
arg:	defs	1		; precision]
				;for intel formats must have space for
				;11 bits of exponent
fbuffr:	defs	13		;buffer for fout

	defs	43-13		;the last 3 locations are temp for rom fmult
	public	fmltt1,fmltt2
fmltt1	defl	fbuffr+40
fmltt2	defl	fbuffr+41
	page
	;subttl	text constants for print out
;
; needed for messages in all versions
;
intxt:	dc	' in '
	defb	0
reddy:
	defb	10
	dc	'Ready'
	defb	13
	defb	10
	defb	0
brktxt:	dc	'Break'
	defb	0

	page
	;subttl	general storage management routines - fndfor, bltu, getstk
;
; find a "FOR" entry on the stack with the variable pointer
; passed in [d,e].
;
fndfor:	ld	hl,4+0		;ignoring everyones "NEWSTT"
				;and the return address of this
	add	hl,sp		;subroutine, set [h,l]=sp
looper:
	ld	a,(hl)		;see what type of thing is on the stack
	inc	hl
whlsiz	defl	6
	cp	$while
	jp	nz,stksrc
	ld	bc,0+whlsiz
	add	hl,bc
	jp	looper
stksrc:
	cp	$for		;is this stack entry a "FOR"?
	ret	nz		;no so ok
	ld	c,(hl)
	inc	hl		;do equivalent of pushm / xthl
	ld	b,(hl)
	inc	hl
	push	hl		;put h  on
	ld	l,c		;push b / xthl is slower
	ld	h,b
	ld	a,d		;for the "NEXT" statment without an argument
	or	e		;we match on anything
	ex	de,hl		;make sure we return [d,e]
	jp	z,popgof	;pointing to the variable
	ex	de,hl
	call	dcompr
forsiz	defl	13

forsiz	defl	14

forsiz	defl	forsiz+2
	public	forszc
forszc	defl	0+forsiz
popgof:	ld	bc,forszc	;to wipe out a "FOR" entry
	pop	hl
	ret	z		;if variable in this entry matches
				;return with [h,l] pointing the bottom
				;of the entry
	add	hl,bc
	jp	looper		;now pointing to the start of the next
				;entry. see if its a "FOR" entry
				;and if the variable matches
	page
	;subttl	error handling
; this routine is called to reset the stack if basic is
; extrnally stopped and then restarted.

	public	readyr
readyr:	ld	bc,stprdy	;address go to, also pop off garbage stack entry.
	jp	ereset		;reset stack, goto ready.

prgend:	ld	hl,(curlin)	;get current line #
	ld	a,h		;see if direct
	and	l		;and together
	inc	a		;set cc'S
	jp	z,endcnj	;if direct done, allow for debugging purposes
	ld	a,(oneflg)	;see if in on error
	or	a		;set cc
	ld	e,errnr		;"NO RESUME" error
	jp	nz,error	;yes, forgot resume
	extrn	endcon
endcnj:	jp	endcon		;no, let it end
derdfl:	ld	e,errdfl
	public	derdfl
	defb	1		;"DISK FULL"
derioe:	ld	e,errioe
	public	derioe
	defb	1		;"DISK I/O ERROR"
derbfm:	ld	e,errbfm
	public	derbfm
	defb	1		;"BAD FILE MODE"
derfnf:	ld	e,errfnf
	public	derfnf
	defb	1		;"FILE NOT FOUND"
derbfn:	ld	e,errbfn
	public	derbfn
	defb	1		;"BAD FILE NUMBER"
derier:	ld	e,errier
	public	derier
	defb	1		;"INTERNAL ERROR"
derrpe:	ld	e,errrpe
	public	derrpe
	defb	1		;"READ PAST END"
derfao:	ld	e,errfao
	public	derfao
	defb	1		;"FILE ALREADY OPEN"
dernmf:	ld	e,errnmf
	public	dernmf
	defb	1		;"BAD FILE NAME"
derbrn:	ld	e,errbrn
	public	derbrn
	defb	1		;"BAD RECORD NUMBER"
derfov:	ld	e,errfov
	public	derfov
	defb	1		;"FIELD OVERFLOW"
dertmf:	ld	e,errtmf
	public	dertmf
	defb	1		;"TOO MANY FILES"
derfae:	ld	e,errfae
	public	derfae
	;defb	1		;"FILE ALREADY EXISTS"
	;org	$-1
	jp	error
datsne:	ld	hl,(datlin)	;get data line
	ld	(curlin),hl	;make it current line
snerr:	ld	e,errsn		;"SYNTAX ERROR"
	defb	1q		;"LXI B," over the next 2
dv0err:	ld	e,errdv0	;division by zero
	defb	1q		;"LXI B," over the next 2
nferr:	ld	e,errnf		;"NEXT WITHOUT FOR" error
	public	dderr
	defb	1q		;"LXI B," over the next two bytes
dderr:	ld	e,errdd		;"REDIMENSIONED VARIABLE"
	defb	1q		;"LXI B," over the next 2 bytes
uferr:	ld	e,erruf		;"UNDEFINED FUNCTION" error
	defb	1q		;"LXI B," over the next two
reerr:	ld	e,errre		;"RESUME WITHOUT ERROR"
	defb	1q		;"LXI B," over the next two
overr:	ld	e,errov		;set overflow error code
	defb	1q		;"LXI B," over next two
moerr:	ld	e,errmo		;type mismatch error
	defb	1q		;"LXI	B," over the next two
tmerr:	ld	e,errtm		;type mismatch error
error:
	ld	hl,(curlin)	;get current line number
	ld	(errlin),hl	;save it for erl variable
	xor	a		;clear chain flag in case of error
	ld	(mrgflg),a	;also merge flag
	ld	(chnflg),a	;so it doesnt try to chain
	ld	a,h		;only set up dot if it isnt direct
	and	l
	inc	a
	jp	z,erresm
	ld	(dot),hl	;save it for edit or list
erresm:	ld	bc,errmor	;get return address in [b,c]
	public	ereset
	extrn	stkerr
ereset:	ld	hl,(savstk)	;get a good stack back
	jp	stkerr		;jump into stkini
errmor:	pop	bc		;pop off fndfor stopper
	ld	a,e		;[a]=error number
	ld	c,e		;also save it for later restore
	ld	(errflg),a	;save it so we know whether to call "EDIT"
	ld	hl,(savtxt)	;get saved text pointer
	ld	(errtxt),hl	;save for resume.
	ex	de,hl		;save savtxt ptr
	ld	hl,(errlin)	;get error line #
	ld	a,h		;test if direct line
	and	l		;set cc'S
	inc	a		;sets zero if direct line (65535)
	jp	z,ntmdcn	;if direct, dont modify oldtxt & oldlin
	ld	(oldlin),hl	;set oldlin=errlin.
	ex	de,hl		;get back savtxt
	ld	(oldtxt),hl	;save in oldtxt.
ntmdcn:	ld	hl,(onelin)	;see if we are trapping errors.
	ld	a,h		;by checking for line zero.
	or	l		;is it?
	ex	de,hl		;put line to go to in [d,e]
	ld	hl,oneflg	;point to error flag
	jp	z,notrap	;sorry, no trapping...
	and	(hl)		;a is non-zero, setzero if oneflg zero
	jp	nz,notrap	;if flag already set, force error
	dec	(hl)		;if already in error routine, force error
	ex	de,hl		;get line pointer in [h,l]
	jp	gone4		;go directly to newstt code
notrap:	xor	a		;a must be zero for contro
	ld	(hl),a		;reset oneflg
	ld	e,c		;get back error code
	ld	(cntofl),a	;force output
	call	crdonz		;crlf
	ld	hl,errtab	;get start of error table
	ld	a,e		;get error code
	cp	lsterr		;is it past last error?
	jp	nc,uperr	;yes, too big to print
	cp	dskerr+1	;disk error?
	jp	nc,ntder2	;yes
	cp	nondsk+1	;is it between last normal & first disk?
	jp	c,ntderr	;yes, ok to print it
uperr:	ld	a,errue+dskerr-nondsk;print "UNPRINTABLE ERROR"
ntder2:	sub	dskerr-nondsk	;fix offset into table of messages
	ld	e,a		;save back error code
ntderr:
	;on "SYNTAX ERROR"s
lepskp:	call	rem		;skip an error message
	inc	hl		;skip over this error message
	dec	e		;decrement error count
	jp	nz,lepskp	;skip some more
	push	hl		;save text pointer
	ld	hl,(errlin)	;get error line number
	ex	(sp),hl		;get back error text pointer
errfin:
	ld	a,(hl)		;get 1st char of error
	cp	'?'		;padded error?
	jp	nz,errfn1	;no,print
	pop	hl		;get line # off stack
	ld	hl,errtab
	jp	uperr		;make unprintable error

errfn1:
	call	strout		;print message
	pop	hl		;restore line number
	ld	de,0+65534	;is init executing?
	call	dcompr
	call	z,crdo		;do crlf
	extrn	systme
	jp	z,systme	;system error exit
	;exit to os
	;if so, restart it
	ld	a,h		;see if in direct mode
	and	l
	inc	a		;zero says direct mode
	call	nz,inprt	;print line number in [h,l]
; now fall into main interpreter loop
	;page
	;subttl	stprdy, ready, main, chead
;
; for "LIST" command stopping
; and for returning from a failed "CVER"
; and to correct a direct gosub which does input
;
	public	stprdy
	defb	76q		;skip the next byte with "MVI A,0"
stprdy:	pop	bc
ready:
	call	finlpt		;print any left overs
	xor	a
	ld	(cntofl),a	;force output
	call	prgfin		;finish output of a file
	call	crdonz		;if not already at left, send crlf
	ld	hl,reddy	;"OK" crlf crlf
repini:
	;by the init code. this is here so after
	;errors during init, init is restarted
	call	cpmwrm		;errors in cp/m initialization, return to cp/m
	ld	a,(errflg)	;see if it was a "SYNTAX ERROR"
	sub	errsn
	extrn	erredt
	call	z,erredt	;"EDIT" the bad line
main:	ld	hl,0+65535
	ld	(curlin),hl	;setup curlin for direct mode
	ld	a,(autflg)	;in an auto command?
	or	a		;set cc'S
	jp	z,ntauto	;no, reuglar mode
	ld	hl,(autlin)	;get current auto line
	push	hl		;save away for later use
	call	linprt		;print the line #
	pop	de		;get it back
	push	de		;save back again
	call	fndlin		;see if it exists
	ld	a,'*'		;char to print if line already exists
	jp	c,auteln	;doesnt exist
	ld	a,' '		;print space
auteln:	call	outdo		;print char
	call	inlin		;read a line
	pop	de		;get line # off stack
	jp	nc,autgod	;if no control-c, proceed
	xor	a		;clear autflg
	ld	(autflg),a	;by setting it to zero
	jp	ready		;print ready message

autres:	xor	a
	ld	(autflg),a	;clear auto flag
	jp	autstr		;and enter line

autgod:	ld	hl,(autinc)	;get increment
	add	hl,de		;add increment to this line
	jp	c,autres	;check for pathetic case
	push	de		;save line number #
	ld	de,0+65529	;check for line # too big
	call	dcompr
	pop	de		;get back line #
	jp	nc,autres	;if too big, quit
	ld	(autlin),hl	;save in next line
autstr:
				;set non-zero condition codes (see edit)
	ld	a,(buf)		;get char from buffer
	or	a		;is it null line?
	jp	z,main		;yes, leave line alone
	extrn	editrt
	jp	editrt		;jump into edit code
ntauto:
	call	inlin		;get a line from tty
	jp	c,main		;ignore ^c s
	call	chrgtr		;get the first
	inc	a		;see if 0 saving the carry flag
	dec	a
	jp	z,main		;if so, a blank line was input
	push	af		;save status indicator for 1st character
	call	linget		;read in a line #
	call	baksp		;back up the pointer
	ld	a,(hl)		;get the char
	cp	' '		;character a space?
	call	z,inxhrt	;then eat past it
				;one space always printed after line #
	public	edent
edent:	push	de		;save line #
	call	crunch		;crunch the line down
	pop	de		;restore line #
	pop	af		;was there a line #?
	ld	(savtxt),hl	;for resuming a direct stmt
				;restore text pointer
	extrn	dirdo
	jp	nc,dirdo	;make sure we'RE NOT READING A FILE
	push	de
	push	bc		;save line # and character count
	call	prochk		;dont allow any funny business with existing pgm
	call	chrgtr		;remember if this line is
	or	a		;set the zero flag on zero
	;lines that start with ":" should not be
	;ignored
	push	af		;blank so we don'T INSERT IT
	ex	de,hl		;save this line # in dot
	ld	(dot),hl
	ex	de,hl
	call	fndlin		;get a pointer to the line
	jp	c,lexist	;line exists, delete it
	pop	af		;get flag says whether line blank
	push	af		;save back
	jp	z,userr		;trying to delete non-existant line, error
	or	a		;clear flag that says line exists
lexist:	push	bc		;save the pointer
	push	af		;save registers
	push	hl		;save [h,l]
	call	deptr		;get rid of ptrs in pgm
	pop	hl		;get back pointer to next line
	pop	af		;get back psw
	pop	bc		;restore pointer to this line
	push	bc		;save back again
	call	c,del		;delete the line
nodel:	pop	de		;pop pointer at place to insert
	pop	af		;see if this line had
	;anything on it
	push	de		;save place to start fixing links
	jp	z,fini		;if not don'T INSERT
	pop	de		;get rid of start of link fix
	ld	a,(chnflg)	;only changet fretop if not chaining
	or	a
	jp	nz,levfre	;leave fretop alone
	ld	hl,(memsiz)	;delete all strings
	ld	(fretop),hl	;so reason doesnt use them
levfre:
	ld	hl,(vartab)	;current end
	ex	(sp),hl		;[h,l]=character count. vartab
	;onto the stack
	pop	bc		;[b,c]=old vartab
	push	hl		;save count of chars to move
	add	hl,bc
	push	hl		;save new vartab
	call	bltu
	pop	hl		;pop off vartab
	ld	(vartab),hl	;update vartab
	ex	de,hl
	ld	(hl),h		;fool chead with non-zero link
	pop	bc		;restore count of chars to move
	pop	de		;get line # off stack
	push	hl		;save start of place to fix links
	inc	hl		;so it doesn'T THINK
				;this link is the
				;end of the program
	inc	hl
	ld	(hl),e
	inc	hl		;put down line #
	ld	(hl),d
	inc	hl
	ld	de,kbuf		;move line frm kbuf to program area
	dec	bc		;fix up count of chars to move
	dec	bc		;(dont include line # & link)
	dec	bc		;
	dec	bc
mloopr:	ld	a,(de)		;now transfering line
				;in from buf
	ld	(hl),a
	inc	hl
	inc	de
	dec	bc		;decrement char count by 1
	ld	a,c		;test for count exhausted
	or	b		;by seeing if [b,c]=0
	jp	nz,mloopr
fini:
	pop	de		;get start of link fixing area
	call	chead		;fix links
	ld	hl,dirtmp	;don'T ALLOW ZERO TO BE CLOSED
	ld	(hl),0		;not sequential output
	ld	(filptr),hl
	ld	hl,(ptrfil)	;get file pointer, could be zero
	ld	(temp2),hl	;save it
	call	runc		;do clear & set up stack
	ld	hl,(filpt1)	;reset [filptr]
	ld	(filptr),hl
	ld	hl,(temp2)	;reset [ptrfil]
	ld	(ptrfil),hl
	jp	main		;go to main code
	public	linker
linker:
	ld	hl,(txttab)
	ex	de,hl
;
; chead goes through program storage and fixes
; up all the links. the end of each
; line is found by searching for the zero at the end.
; the double zero link is used to detect the end of the program
;
chead:	ld	h,d		;[h,l]=[d,e]
	ld	l,e
	ld	a,(hl)		;see if end of chain
	inc	hl		;bump pointer
	or	(hl)		;2nd byte

	ret	z
	inc	hl		;fix h to start of text
	inc	hl
czloop:	inc	hl		;bump pointer
	ld	a,(hl)		;get byte
czloo2:	or	a		;set cc'S
	jp	z,czlin		;end of line, done.
	cp	dblcon+1	;embedded constant?
	jp	nc,czloop	;no, get next
	cp	11		;is it linefeed or below?
	jp	c,czloop	;then skip past
	call	chrgt2		;get constant
	call	chrgtr		;get over it
	jp	czloo2		;go back for more
czlin:	inc	hl		;make [h,l] point after text
	ex	de,hl		;switch temp
	ld	(hl),e		;do first byte of fixup
	inc	hl		;advance pointer
	ld	(hl),d		;2nd byte of fixup
	jp	chead		;keep chaining til done

	;page
	;subttl	scnlin, fndlin - scan line range and find line # in program
;
; scnlin scans a line range of
; the form  #-# or # or #- or -# or blank
; and then finds the first line in the range
;
scnlin:	ld	de,0		;assume start list at zero
	push	de		;save initial assumption
	jp	z,alllst	;if finished, list it all
	pop	de		;we are going to grab a #
	call	linspc		;get a line #. if none, returns zero
	push	de		;save first
	jp	z,snglin	;if only # then done.
	call	synchr
	defb	minutk		;must be a dash.
alllst:	ld	de,0+65530	;assume max end of range
	call	nz,linspc	;get the end of range
	jp	nz,snerr	;must be terminator
snglin:	ex	de,hl		;[h,l] = final
	pop	de		;get initial in [d,e]
fndln1:	ex	(sp),hl		;put max on stack, return addr to [h,l]
	push	hl		;save return address back
;
; fndlin searches the program text for the line
; whose line # is passed in [d,e]. [d,e] is preserved.
; there are three possible returns:
;
;	1) zero flag set. carry not set.  line not found.
;	   no line in program greater than one sought.
;	   [b,c] points to two zero bytes at end of program.
;	   [h,l]=[b,c]
;
;	2) zero, carry set.
;	   [b,c] points to the link field in the line
;	   which is the line searched for.
;	   [h,l] points to the link field in the next line.
;
;	3) non-zero, carry not set.
;	   line not found, [b,c]  points to line in program
;	   greater than one searched for.
;	   [h,l] points to the link field in the next line.
;
fndlin:
	ld	hl,(txttab)	;get pointer to start of text
loop:
	ld	b,h		;if exiting because of end of program,
				;set [b,c] to point to double zeroes.
	ld	c,l
	ld	a,(hl)		;get word pointer to
	inc	hl		;bump pointer
	or	(hl)		;get 2nd byte
	dec	hl		;go back
	ret	z		;if zero then done
	inc	hl		;skip past and get the line #
	inc	hl
	ld	a,(hl)		;into [h,l] for comparison with
	inc	hl		;the line # being searched for
	ld	h,(hl)		;which is in [d,e]
	ld	l,a
	call	dcompr		;see if it matches or if we'VE GONE TOO FAR
	ld	h,b		;make [h,l] point to the start of the
	ld	l,c		;line beyond this one, by picking
	ld	a,(hl)		;up the link that [b,c] points at
	inc	hl
	ld	h,(hl)
	ld	l,a
	ccf			;turn carry on
	ret	z		;equal return
	ccf			;make carry zero
	ret	nc		;no match return (greater)
	jp	loop		;keep looping

	;page
	;subttl	pre fast crunch - compactification
	;page
	;page
	;subttl	fast crunch - compactification
;
; all "RESERVED" words are translated into single
; one or two (if two, first is always 377 octal)
; bytes with the msb on. this saves space and time
; by allowing for table dispatch during execution.
; therefore all statements appear together in the
; reserved word list in the same
; order they appear in in stmdsp.
;
; numeric constants are also converted to their internal
; binary representation to improve execution speed
; line numbers are also preceeded by a special token
; so that line numbers can be converted to pointers at execution
; time.
crunch:	xor	a		;say expecting floating numbers
	ld	(donum),a	;set flag acordingly
	ld	(dores),a	;allow crunching
	ld	bc,0+kbflen-3	;get length of krunch buffer
				;minus three because of zeros at end
	ld	de,kbuf		;setup destination pointer
kloop:	ld	a,(hl)		;get character from buf
				;setup b with a quote if it is a string
	cp	34		;quote sign?
	jp	z,strng		;yes, go to special string handling
	cp	' '		;space?
	jp	z,stuffh	;just stuff away
	or	a		;end of line?
	jp	z,crdone	;yes, done crunching
	ld	a,(dores)	;in data statement and no crunch?
	or	a
	ld	a,(hl)		;get the character again
	jp	nz,stuffh	;if no crunching just store
				;the character
	cp	'?'		;a qmark?
	ld	a,$print
	push	de		;save store pointer
	push	bc		;save char count
	jp	z,notfn2	;then use a "PRINT" token
				;***5.11 dont allow following line #***
	ld	de,spctab	;assume we'LL SEARCH SPECIAL CHAR TABLE
	call	makupl		;translate this char to upper case
	call	islet2		;letter?
	jp	c,tstnum	;not a letter, test for number
	push	hl		;save text pointer
	ld	bc,notgos	;place to return if not funny go
	push	bc
	cp	'G'		;first check for "GO "
	ret	nz
	inc	hl
	call	makupl
	cp	'O'
	ret	nz
	inc	hl
	call	makupl
	cp	' '
	ret	nz
	inc	hl
gskpsp:	call	makupl		;now skip any number of spaces
	inc	hl
	cp	' '
	jp	z,gskpsp
	cp	'S'
	jp	z,ckgosu	;looks like "GO SUB" not "GO TO"
	cp	'T'
	ret	nz
	call	makupl
	cp	'O'
	ld	a,$goto		;reswrd to use if matched
	jp	gputrs		;merge with "GO SUB"
ckgosu:	call	makupl
	cp	'U'
	ret	nz
	inc	hl
	call	makupl
	cp	'B'
	ld	a,$gosub
gputrs:	ret	nz
	pop	bc		;pop off the return address since matched
	pop	bc		;pop off the old text pointer
	jp	notfn2		;store the reserved word
notgos:	pop	hl
	call	makupl		;get back the character
	push	hl		;resave the text pointer
	ld	hl,alptab	;get pointer to alpha dispatch table
	sub	'A'		;subtract alpha offset
	add	a,a		;multiply by two
	ld	c,a		;save offset in [c] for dad.
	ld	b,0		;make high part of offset zero
	add	hl,bc		;add to table address
	ld	e,(hl)		;set up pointer in [d,e]
	inc	hl
	ld	d,(hl)		;get high part of address
	pop	hl		;get back source pointer
	inc	hl		;point to char after first alpha
tryaga:	push	hl		;save txtptr to start of search area
loppsi:
	call	makupl		;translate this char to upper case
	ld	c,a		;save char in [c]
	ld	a,(de)		;get byte from reserved word list
	and	127		;get rid of high bit
	jp	z,notres	;if=0 then end of this chars reslt
	inc	hl		;bump source pointer
	cp	c		;compare to char from source line
	jp	nz,lopskp	;if no match, search for next reswrd
	ld	a,(de)		;get reswrd byte again
	inc	de		;bump reslst pointer
	or	a		;set cc'S
	jp	p,loppsi	;see if rest ofchars match
	ld	a,c		;get last char of reswrd
	cp	'('		;if tab( or spc(, space need not follow
	jp	z,isresw	;is a resword
	ld	a,(de)		;look after char
	cp	$fn		;function?
	jp	z,isresw	;then no space need afterward
	cp	$usr		;or usr definition?
	jp	z,isresw
	call	makupl		;get next char in line (mc 6/22/80)
	cp	'.'		;is it a dot
	jp	z,isvars	;yes
	call	tstanm		;is it a letter immediately following reswrd
isvars:	ld	a,0		;set donum to -1
	jp	nc,notres	;if alpha, cant be reserved word
isresw:
	pop	af		;get rid of saved [h,l]
	ld	a,(de)		;get reswrd value
	or	a		;set cc'S
	jp	m,notfnt	;if minus, wasnt function token
	pop	bc		;get char count off stack
	pop	de		;get deposit pointer off stack
	or	200o		;make high order bit one
	push	af		;save fn char
	ld	a,377o		;get byte which preceeds fns
	call	krnsav		;save in krunch buffer
	xor	a		;make a zero
	ld	(donum),a	;to reset donum (floatings allowed)
	pop	af		;get function token
	call	krnsav		;store it
	jp	kloop		;keep krunching

lopskp:	pop	hl		;restore undefiled text pointer
lopsk2:	ld	a,(de)		;get a byte from reswrd list
	inc	de		;bump reslst pointer
	or	a		;set cc'S
	jp	p,lopsk2	;not end of reswrd, keep skipping
	inc	de		;point after token
	jp	tryaga		;try another reswrd

notfnt:	dec	hl		;fix text pointer
notfn2:	push	af		;save char to be save d in krunch buffer
	ld	bc,notrs2	;where to go if not line number reswrd
	push	bc		;save label address on stack
	cp	$resto		;restore can have following line number
	ret	z
	cp	$auto		;auto command
	ret	z		;scan line range &crunch
	cp	$renum		;renumber?
	ret	z
	cp	$delet		;delete?
	ret	z		;if so, crunch following line #
	cp	$edit		;edit?
	ret	z
	cp	$resum		;resume?
	ret	z		;crunch following line number
	cp	$erl		;error line
	ret	z		;crunch following line number
				;so that if "ERL=...THEN"
				;will resequence properly
				;this can make statements like
				;"PRINT ERL,1E20" do strange things
	cp	$else
	ret	z		;if else, crunch following line #
	cp	$run		;run?
	ret	z		;crunch following line #
	cp	$list		;list?
	ret	z
	cp	$llist		;lpt list?
	ret	z		;crunch following line #'S
	cp	$goto		;if goto, crunch line #
	ret	z
	cp	$then		;crunch line #'S AFTER 'then'
	ret	z
	cp	$gosub		;if gosub, crunch line #'S
	ret	z
	pop	af		;get rid of notrs2 return address
	xor	a		;get a zero (expect usuall numbers)
	defb	302q		;"JNZ" over next two bytes
notrs2:	ld	a,1		;say line #'S ALLOWED.
notrs6:	ld	(donum),a	;save in flag
	pop	af		;restore character to save in krunch buffer
	pop	bc		;get back the character count
	pop	de		;get stuff pointer back
	cp	$else		;have to put a hidden
				;colon in front of "ELSE"s
	push	af		;save current char ($else)
	call	z,krnsvc	;save ":" in crunch buffer
	pop	af		;get back token
cksngq:	cp	sngqtk		;single quoatation mark?
	jp	nz,ntsngt
	push	af		;save sngqtk
	call	krnsvc		;save ":" in crunch buffer
	ld	a,$rem		;store ":$REM" in front for execution
	call	krnsav		;save it
	pop	af		;get sngqtk back
	push	af		;save back as terminator for strng
	jp	strng2		;stuff the rest of the line without crunching
tstnum:	ld	a,(hl)		;get char
	cp	'.'		;test for start of floating #
	jp	z,numtry	;try inputting it as constant
	cp	'9'+1		;is it a digit?
	jp	nc,srcspc	;no, try other things
	cp	'0'		;try lower end
	jp	c,srcspc	;no try other possibilities
numtry:	ld	a,(donum)	;test for numbers allowed
	or	a		;set cc'S
	ld	a,(hl)		;get char if going to stuffh
	pop	bc		;restore char count
	pop	de		;restore dep. pointer
	jp	m,stuffh	;no, just stuff it (!)
	jp	z,fltget	;if donum=0 then floating #'S ALLOWED
	cp	'.'		;is it dot?
	jp	z,stuffh	;yes, stuff it for heavens sake! (edit .)
	ld	a,lincon	;get line # token
	call	krnsav		;save it
	push	de		;save deposit pointer
	call	linget		;get the line #.
	call	baksp		;back up pointer to after last digit
savint:	ex	(sp),hl		;exchange current [h,l] with saved [d,e]
	ex	de,hl		;get saved [d,e] in [d,e]
savi:	ld	a,l		;get low byte of value returned by linget
	call	krnsav		;save the low byte of line #
	ld	a,h		;get high byte
popstf:	pop	hl		;restore [h,l]
	call	krnsav		;save it too
	jp	kloop		;eat some more

fltget:	push	de		;save deposit pointer
	push	bc		;save char count
	ld	a,(hl)		;fin assumes char in [a]
	call	fin		;read the #
	call	baksp		;back up pointer to after last digit
	pop	bc		;restore char count
	pop	de		;restore deposit pointer
	push	hl		;save text pointer
	ld	a,(valtyp)	;get value type
	cp	2		;integer?
	jp	nz,ntintg	;no
	ld	hl,(faclo)	;get it
	ld	a,h		;get high part
	or	a		;is it zero?
	ld	a,2		;restore int valtyp
	jp	nz,ntintg	;then isnt single byte int
	ld	a,l		;get low byte
	ld	h,l		;get low byte in high byte to store
	ld	l,in2con	;get constant for 1 byte ints
	cp	10		;is it too big for a single byte constant?
	jp	nc,savi		;too big, use single byte int
	add	a,onecon	;make single byte constant
	jp	popstf		;pop h & stuff away char
ntintg:	push	af		;save for later
	rrca			;divide by two
	add	a,intcon-1	;add offset to get token
	call	krnsav		;save the token
	ld	hl,faclo	;get start pointer
	call	getypr		;set cc'S ON VALTYPE
	jp	c,ntdbl		;if not double, start moving at faclo
	ld	hl,dfaclo	;double, start moving at dfaclo
ntdbl:	pop	af		;restore count of bytes to move
movcon:	push	af		;save byte move count
	ld	a,(hl)		;get a byte
	call	krnsav		;save it in krunch buffer
	pop	af		;get back count
	inc	hl		;bump pointer into fac
	dec	a		;move it down
	jp	nz,movcon	;keep moving it
	pop	hl		;get back saved text pointer
	jp	kloop		;keep looping

srcspc:	ld	de,spctab-1	;get pointer to special character table
srcsp2:	inc	de		;move pointer ahead
	ld	a,(de)		;get byte from table
	and	177o		;mask off high bit
	jp	z,notrs5	;if end of table, stuff away, dont change donum
	inc	de		;bump pointer
	cp	(hl)		;is this special char same as current text char?
	ld	a,(de)		;get next reswrd
	jp	nz,srcsp2	;if no match, keep looking
	jp	notrs1		;found, save away and set donum=1.

ntsngt:
	cp	'&'		;octal constant?
	jp	nz,stuffh	;just stuff it away
	push	hl		;save text pointer
	call	chrgtr		;get next char
	pop	hl		;restore text pointer
	call	makups		;make char upper case
	cp	'H'		;hex constant?
	ld	a,octcon	;assume octal constant
	jp	nz,wuzoct	;yes, it was
	ld	a,hexcon	;no, was hex
wuzoct:	call	krnsav		;save it
	push	de		;save current deposit pointer
	push	bc		;save count
	call	octcns		;get the value
	pop	bc		;restore [b,c]
	jp	savint		;save the integer in the krunch buffer
stuffh:	inc	hl		;entry to bump [h,l]
	push	af		;save char as krnsav clobbers
	call	krnsav		;save char in krunch buffer
	pop	af		;restore char
	sub	':'		;see if it is a colon
	jp	z,colis		;if so allow crunching again
	cp	$data-':'
	jp	nz,nodatt	;see if it is a data token
	ld	a,1		;set line number allowed flag
				;kludge as has to be non-zero.
colis:	ld	(dores),a	;setup flag
	ld	(donum),a	;set number allowed flag
nodatt:	sub	$rem-':'
	jp	nz,kloop	;keep looping
	push	af		;save terminator on stack
str1:	ld	a,(hl)		;get a char
	or	a		;set condition codes
	ex	(sp),hl		;get saved terminator off stack, save [h,l]
	ld	a,h		;get terminator into [a] without affecting psw
	pop	hl		;restore [h,l]
	jp	z,crdone	;if end of line then done
	cp	(hl)		;compare char with this terminator
	jp	z,stuffh	;if yes, done with string
strng:
	push	af		;save terminator
	ld	a,(hl)		;get back line char
strng2:	inc	hl		;increment text pointer
	call	krnsav		;save char in krunch buffer
	jp	str1		;keep looping

crdone:

	;add 5 to line count & for in [b,c]
	ld	hl,0+kbflen+2	;get offset
	ld	a,l		;get count to subtract from
	sub	c		;subtract
	ld	c,a
	ld	a,h
	sbc	a,b
	ld	b,a
	ld	hl,kbuf-1	;get pointer to char before kbuf
				;as "GONE" does a chrget
	xor	a		;get a zero
	ld	(de),a		;need three 0'S ON THE END
	inc	de		;one for end-of-line
	ld	(de),a		;and 2 for a zero link
	inc	de		;since if this is a direct statement
	ld	(de),a		;its end must look like the end of a program
	ret			;end of crunching

krnsvc:	ld	a,':'		;get colon
krnsav:
				;in krunch buffer
	ld	(de),a		;save byte in krunch buffer
	inc	de		;bump pointer
	dec	bc		;decrement count of bytes left in buffer
	ld	a,c		;test if it went to zero
	or	b		;by seeing if double byte zero.
	ret	nz		;all done if still space left
	public	lboerr
lboerr:	ld	e,errlbo	;get error code
	jp	error		;jump to error routine

notres:	pop	hl		;get back pointer to original char
	dec	hl		;now point to first alpha char
	dec	a		;set a to minus one
	ld	(donum),a	;flag were in variable name
	pop	bc		;get back char count
	pop	de		;get back deposit pointer
	call	makupl		;get char from line, make upper case
krnvar:	call	krnsav		;save char
	inc	hl		;incrment source pointer
	call	makupl		;make upper case (?)
	call	islet2		;is it a letter?
	jp	nc,krnvar	;yes, eat
	cp	'9'+1		;digit?
	jp	nc,jkloop	;no, too large
	cp	'0'
	jp	nc,krnvar	;yes, eat
	cp	'.'		;is it dot
	jp	z,krnvar	;yes, dots ok in var names
jkloop:	jp	kloop		;done looking at variable name
notrs5:	ld	a,(hl)		;get char from line
	cp	32		;space or higher ?
	jp	nc,notrs1	;yes = save it
	cp	9		;tab ?
	jp	z,notrs1	;yes = that'S OK
	cp	10		;also allow...
	jp	z,notrs1	;...line feeds
	ld	a,32		;force rest to spaces
notrs1:	push	af		;save this char
	ld	a,(donum)	;get number ok flag
	inc	a		;see if in a variable name.
	jp	z,jntrs6	;if so & special char seen, reset donum
	dec	a		;otherwise leave donum unchanged.
jntrs6:	jp	notrs6

; routine to back up pointer after # eaten
baksp:	dec	hl		;point to previous char
	ld	a,(hl)		;get the char
	cp	' '		;a space?
	jp	z,baksp		;yes, keep backing up
	cp	9		;tab?
	jp	z,baksp		;yes, back up
	cp	10		;lf?
	jp	z,baksp
	inc	hl		;point to char after last non-space
	ret			;all done.

	;page
	;page
	;subttl	the non-extended "LIST" command



	;page
	;subttl	"FOR" statement
;
; a "FOR" entry on the stack has the following format:
;
; low address
;	token ($for in high byte)  1 byte
;	a pointer to the loop variable  2 bytes
;	a byte reflecting the sign of the increment 1 byte
;	the step 4 bytes
;	the upper value 4 bytes
;	the line # of the "FOR" statement 2 bytes
;	a text pointer into the "FOR" statement 2 bytes
; high address
;
; total 16 bytes
;

for:	ld	a,100
	ld	(subflg),a	;dont recognize subscripted variables
	call	ptrget		;get pointer to loop variable
	call	synchr
	defb	equltk		;skip over assignment "="
	push	de		;save the variable pointer
	ex	de,hl		;save the loop variable in temp
	ld	(temp),hl	;for use later on
	ex	de,hl
	ld	a,(valtyp)	;remember the loop variable type
	push	af
	call	frmevl		;get the start value
	pop	af		;reget the loop type
	push	hl		;save the text pointer
	call	docnvf		;force conversion to loop type
	ld	hl,fvalsv	;place to save the value
	call	movmf		;store for use in "NEXT"
	pop	hl		;get back the text pointer
	pop	de		;get back the variable pointer
	;the correct intial value
	;and store a pointer
	;to the variable in [temp]
	pop	bc		;get rid of the newstt return
	push	hl		;save the text pointer
	call	data		;set [h,l]=end of statement
	ld	(endfor),hl	;save for comparison
	ld	hl,0+2		;set up pointer into stack
	add	hl,sp
lpform:	call	looper		;must have variable pointer in [d,e]
	pop	de		;[d,e]=text pointer
	jp	nz,notol	;if no matching entry, don'T
				;eliminate anything
	add	hl,bc		;in the case of "FOR"
				;we eliminate the matching entry
				;as well as everything after it
	push	de		;save the text pointer
	dec	hl		;see if end text pointer of matching entry
	ld	d,(hl)		;matches the for we are handling
	dec	hl		;pick up the end of the "FOR" text pointer
	ld	e,(hl)		;for the entry on the stack
	inc	hl		;without changing [h,l]
	inc	hl
	push	hl		;save the stack pointer for the comparison
	ld	hl,(endfor)	;get ending text pointer for this "FOR"
	call	dcompr		;see if they match
	pop	hl		;get back the stack pointer
	jp	nz,lpform	;keep searching if no match
	pop	de		;get back the text pointer
	ld	sp,hl		;do the elimination
	ld	(savstk),hl	;update saved stack
				;since a matching entry was found
notol:	ex	de,hl		;[h,l]=text pointer
	ld	c,8		;make sure 16 bytes are available
				;off of the stack
	call	getstk
	push	hl		;really save the text pointer
	ld	hl,(endfor)	;pick up pointer at end of "FOR"
				;just beyond the terminator
	ex	(sp),hl		;put [h,l] pointer to terminator on the stack
				;and restore [h,l] as text pointer at
				;variable name
	push	hl		;push the text pointer onto the stack
	ld	hl,(curlin)	;[h,l] get the current line #
	ex	(sp),hl		;now the current line # is on the stack and
				;[h,l] is the text pointer
	call	synchr
	defb	$to		;"TO" is necessary
	call	getypr		;see what type this value has
	jp	z,tmerr		;give strings a "TYPE MISMATCH"
	jp	nc,tmerr	;as well as double-precision
	push	af		;save the integer/floating flag
	call	frmevl		;evaluate the target value formula
	pop	af		;pop off the flag
	push	hl		;save the text pointer
	jp	p,sngfor	;positive means single precision "FOR"-loop
	call	frcint		;coerce the final value
	ex	(sp),hl		;save it on the stack and reget the
	;text pointer
	ld	de,0+1		;default the step to be 1
	ld	a,(hl)		;see what character is next
	cp	steptk		;is there a "STEP" clause?
	call	z,getint	;if so, read the step into [d,e]
	push	de		;put the step onto the stack
	push	hl		;save the text pointer
	ex	de,hl		;step into [h,l]
	call	isign		;the sign of the step into [a]
	jp	stpsgn		;finish up the entry
				;by putting the sign of the step
				;and the dummy entries on the stack
sngfor:	call	frcsng
	call	movrf		;get the stuff
	pop	hl		;regain text pointer
	push	bc		;opposite of pushr
	push	de		;save the sign of the increment
	ld	bc,0+201o*256
	ld	d,c
	ld	e,d		;get 1.0 in the registers
	ld	a,(hl)		;get terminating character
	cp	steptk		;do we have "STEP" ?
	ld	a,1		;setup default sign
	jp	nz,oneon	;push some constants on if not
	call	frmchk		;don'T NEED TO CHECK THE TYPE
	push	hl
	call	frcsng
	call	movrf		;set up the registers
	call	sign		;get the sign of the increment
stpsgn:	pop	hl		;pop off the text pointer
oneon:	push	bc		;put value on backwards
	push	de		;opposite of pushr
	ld	c,a		;[c]=sign of step
	call	getypr		;must put on integer/single-precision flag
				;minus is set for integer case
	ld	b,a		;high byte = integer/single precision flag
	push	bc		;save flag and sign of step both
	dec	hl		;make sure the "FOR" ended properly
	call	chrgtr
	jp	nz,snerr
	call	nxtscn		;scan until the matching "NEXT" is found
	call	chrgtr		;fetch first character of "NEXT"
	push	hl		;make the next txtptr part of the entry
	push	hl
	ld	hl,(nxtlin)	;get the line number of next
	ld	(curlin),hl	;make it the current line
	ld	hl,(temp)	;get the pointer to the variable back
	ex	(sp),hl		;put the pointer to the variable
				;onto the stack and restore the text pointer
	ld	b,$for		;finish up "FOR"
	push	bc
	inc	sp
	push	af		;save the character
	push	af		;make a stack entry to substitute for "NEWSTT"
	extrn	nexts
	jp	nexts		;go execute "NEXT" with nxtflg zero
nxtcon:	ld	b,$for		;put a 'FOR' token onto the stack
	push	bc
	inc	sp		;the "TOKEN" only takes one byte of
	;stack space
;	jmp	newstt		;all done

	;page
	;subttl	new statement fetcher
;
; back here for new statement. character pointed to by [h,l]
; ":" or end-of-line. the address of this location is
; left on the stack when a statement is executed so
; it can merely do a return when it is done.
;
newstt:
	extrn	cntccn,iscntc
	push	hl
	public	const2,csts
csts	defl	0
const2:	call	csts		;get console status
	pop	hl		;restore all registers
	or	a		;set cc'S - 0 FALSE - NO CHAR TYPED
	call	nz,cntccn	;see if its control-c
				;if so, check for contrl-c
	ld	(savtxt),hl	;used by continue and input and clear and print using
	ex	de,hl		;save text pointer
	ld	hl,0		;save stack pointer
	add	hl,sp		;copy to [h,l]
	ld	(savstk),hl	;save it
				;to remember how to restart this
				;statement
	ex	de,hl		;get current text pointer back in [h,l]
				;to save bytes & speed
	ld	a,(hl)		;get current character
				;which terminated the last statement
	cp	':'		;is it a colon?
	jp	z,gone
	or	a
	jp	nz,snerr	;must be a zero
	inc	hl
gone4:	ld	a,(hl)		;check pointer to see if
				;it is zero, if so we are at the
				;end of the program
	inc	hl
	or	(hl)		;or in high part
	jp	z,prgend	;fix syntax error in unended error routine
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)		;get line # in [d,e]
	ex	de,hl		;[h,l]=line #
	ld	(curlin),hl	;setup curlin with the current line #
	ld	a,(trcflg)	;see if trace is on
	or	a		;non-zero means yes
	jp	z,nottrc	;skip this printing
	push	de		;save the text pointer
	ld	a,'['		;format the line number
	call	outdo		;output it
	call	linprt		;print the line # in [h,l]
	ld	a,']'		;some more formating
	call	outdo
	pop	de		;[d,e]=text pointer
nottrc:
	ex	de,hl		;restore the text pointer
gone:	call	chrgtr		;get the statement type
	ld	de,newstt	;push on a return address of newstt
	push	de		;statement
gone3:	ret	z		;if a terminator try again
				;"IF" comes here
gone2:	sub	$end		;"ON ... GOTO" and "ON ... GOSUB" come here
	jp	c,let		;must be a let
	cp	numcmd
				;a statement reserved word
	jp	nc,ismid$	;see if lhs mid$ case
	rlca			;multiply by 2
	ld	c,a
	ld	b,0
	ex	de,hl
	ld	hl,stmdsp	;statement dispatch table
	add	hl,bc		;add on offset
	ld	c,(hl)		;push the address to go to onto
	inc	hl		;the stack
	ld	b,(hl)		;pushm saves bytes but not speed
	push	bc
	ex	de,hl		;restore the text pointer
; newstt falls into chrget. this fetches the first char after
; the statement token and the chrget'S "RET" DISPATCHES TO STATEMENT

	;page
	;subttl	chrget - the next character scan routine
chrgtr:	inc	hl		;duplication of chrget rst for speed
	public	chrgt2
chrgt2:	ld	a,(hl)		;see chrget rst for explanation
	cp	':'
	ret	nc
;
; chrcon is the continuation of the chrget rst
;
; in extended, check for inline constant and if one
; move it into the fac & set valtyp appropriately
octcon	defl	11		;embeded octal constant
hexcon	defl	12		;embeded constant
ptrcon	defl	13		;a line reference constant
lincon	defl	14		;a line number unconverted to pointer
in2con	defl	15		;single byte (two byte with token) integer
concn2	defl	16		;token returned second type constant is scanned.
onecon	defl	17		;first of 10 (0-9) integer special tokens
intcon	defl	28		;regular 16 bit two'S COMPLEMENT INT
sngcon	defl	29		;single prec (4 byte) constant
concon	defl	30		;token returned by chrget after constant scanned
dblcon	defl	31		;double prec (8 byte) constant
chrcon:	cp	' '		;must skip spaces
	jp	z,chrgtr	;get another character
	jp	nc,notlft	;not special try other possib.
	or	a		;null at eol?
	ret	z		;yes, all done
	cp	octcon		;is it inline constant
	jp	c,notcon	;no, should be tab or lf
	cp	concon		;are we trying to re-scan a constant?
	jp	nz,ntrscc	;no.
	ld	a,(consav)	;get the saved constant token
	or	a		;set non-zero, non carry cc'S
	ret			;all done

ntrscc:	cp	concn2		;going to scan past embedded constant?
	jp	nz,ntrsc2	;no, try other cases
conscn:	ld	hl,(contxt)	;get saved text pointer
	jp	chrgt2		;and scan thing after constant
ntrsc2:	push	af		;save token to return
	inc	hl		;point to number
	ld	(consav),a	;save current token
	sub	intcon		;is it less than integer constant?
	jp	nc,maktkn	;no, not line number constant
	sub	365o		;<onecon-intcon>&^o377
				;less than embedded 1 byter
	jp	nc,onei		;was one byter
	cp	in2con-onecon	;is it two byter?
	jp	nz,frcinc	;nope, normal int
	ld	a,(hl)		;get embeded int
	inc	hl		;point after constant
onei:	ld	(contxt),hl	;save text pointer
	ld	h,0		;get upper byte of zero
onei2:	ld	l,a		;get value
	ld	(conlo),hl	;save constant value
	ld	a,2		;get valtype
	ld	(contyp),a	;set it up in save place
	ld	hl,numcon	;point to number re-scanner
	pop	af		;get back token
	or	a		;make sure number flag re-set
	ret			;return to caller

frcinc:	ld	a,(hl)		;get low byte of constant
	inc	hl		;point past it
	inc	hl		;to next thing
	ld	(contxt),hl	;save pointer past
	dec	hl		;back to high byte
	ld	h,(hl)		;get high byte
	jp	onei2		;finish scanning
maktkn:	inc	a		;calculate valtype
	rlca			;*2 to get valtype 0=2, 1=4, 3=8
	ld	(contyp),a	;contype now setup
	push	de		;save some rgs
	push	bc
	ld	de,conlo	;place to store saved constant
	ex	de,hl		;get text pointer in [d,e]
	ld	b,a		;setup counter in [b]
	call	move1		;move data in
	ex	de,hl		;get text pointer back
	pop	bc		;restore [b,c]
	pop	de
finin1:	ld	(contxt),hl	;save the good text pointer
	pop	af		;restore token
	ld	hl,numcon	;get pointer to fake text
	or	a		;clear carry so others dont think its a number
				;and set non-zero so not terminator
	ret			;all done
notcon:
	cp	9		;line feed or tab?
	jp	nc,chrgtr	;yes, eat.
notlft:	cp	'0'		;all characters greater than
				;"9" have returned, so see if numeric
	ccf			;make numerics have carry on
	inc	a		;set zero if [a]=0
	dec	a
	ret

numcon:	defb	concon		;these fake tokens force chrget
	defb	concn2		;to effectively re-scan the embeded constant

				; this routine moves the saved constant into the fac
confac:
	ld	a,(consav)	;get constant token
	cp	lincon+1	;line# constant? (erl=#)
	jp	nc,ntline	;no
	cp	ptrcon		;line pointer constant?
	jp	c,ntline	;no
	ld	hl,(conlo)	;get value
	jp	nz,fltlin	;must be line number, not pointer
	inc	hl		;point to line #
	inc	hl
	inc	hl
	ld	e,(hl)		;get line # in [d,e]
	inc	hl
	ld	d,(hl)		;get high part
	ex	de,hl		;value to [h,l]
fltlin:	call	ineg2		;float it
	jp	conscn		;restore text ptr
ntline:
	ld	a,(contyp)	;get saved constant valtyp
	ld	(valtyp),a	;save in real valtyp
	cp	8		;double precision
	jp	z,confdb	;yes
	ld	hl,(conlo)	;get low two bytes of fac
	ld	(faclo),hl	;save them
	ld	hl,(conlo+2)	;get next two bytes
	ld	(faclo+2),hl	;save them
	jp	conscn		;scan furthur
confdb:	ld	hl,conlo	;get pointer to saved constant area
	call	vmovfm		;move into fac
	jp	conscn		;restore text ptr & scan following character

	;page
	;subttl	defstr, defint, defsng, defdbl, intidx

defstr:	ld	e,3		;default some letters to string
	defb	1q		;"LXI B," over the next 2 bytes
defint:	ld	e,2		;default some letters to integer
	defb	1q		;"LXI B," over the next 2 bytes
defrea:	ld	e,4		;default some letters to single precision
	defb	1q		;"LXI B," over the next 2 bytes
defdbl:	ld	e,8		;default some letters to double precision
defcon:	call	islet		;make sure the argument is a letter
	ld	bc,snerr	;prepare "SYNTAX ERROR" return
	push	bc
	ret	c		;return if theres no letter
	sub	'A'		;make an offset into deftbl
	ld	c,a		;save the initial offset
	ld	b,a		;assume it will be the final offset
	call	chrgtr		;get the possible dash
	cp	minutk		;a range argument?
	jp	nz,notrng	;if not, just one letter
	call	chrgtr		;get the final position
	call	islet		;check for a letter
	ret	c		;give a syntax error if improper
	sub	'A'		;make it an offset
	ld	b,a		;put the final in [b]
	call	chrgtr		;get the terminator
notrng:	ld	a,b		;get the final character
	sub	c		;subtract the start
	ret	c		;if it'S LESS THATS NONSENSE
	inc	a		;setup the count right
	ex	(sp),hl		;save the text pointer and get rid
				;of the "SYNTAX ERROR" return
	ld	hl,deftbl	;point to the table of defaults
	ld	b,0		;setup a two-byte starting offset
	add	hl,bc		;make [h,l] point to the first entry
				;to be modified
lpdchg:	ld	(hl),e		;modify the default table
	inc	hl
	dec	a		;count dount the number of changes to make
	jp	nz,lpdchg
	pop	hl		;get back the text pointer
	ld	a,(hl)		;get last character
	cp	44		;is it a comma?
	ret	nz		;if not statement should have ended
	call	chrgtr		;otherwise set up to scan new range
	jp	defcon
;
; intidx reads a formula from the current position and
; turns it into a positive integer
; leaving the result in [d,e].  negative arguments
; are not allowed. [h,l] points to the terminating
; character of the formula on return.
;
intidx:	call	chrgtr
intid2:	call	getin2		;read a formula and get the
				;result as an integer in [d,e]
				;also set the condition codes based on
				;the high order of the result
	ret	p		;don'T ALLOW NEGATIVE NUMBERS
fcerr:	ld	e,errfc		;too big. function call error
	jp	error

	;page
	;subttl	linspc, linget
;
; linspc is the same as linget except in allows the
; current line (.) specifier
;
	public	linspc
linspc:	ld	a,(hl)		;get char from memory
	cp	'.'		;is it current line specifier
	ex	de,hl		;save text pointer
	ld	hl,(dot)	;get current line #
	ex	de,hl		;get back text pointer
	jp	z,chrgtr	;all done.

;
; linget reads a line # from the current text position
;
; line numbers range from 0 to 65529
;
; the answer is returned in [d,e].
; [h,l] is updated to point to the terminating character
; and [a] contains the terminating character with condition
; codes set up to reflect its value.
;
linget:	dec	hl		;backspace ptr
lingt2:	call	chrgtr		;fetch char (gobble line constants)
	cp	lincon		;embedded line constant?
	jp	z,lingt3	;yes, return double byte value
	cp	ptrcon		;also check for pointer
lingt3:	ex	de,hl		;save text ptr in [d,e]
	ld	hl,(conlo)	;get embedded line #
	ex	de,hl		;restore text ptr.
	jp	z,chrgtr	;eat following char
	dec	hl		;back up pointer
	ld	de,0		;zero accumulated line #
morlin:	call	chrgtr
	ret	nc		;was it a digit
	push	hl
	push	af
	ld	hl,0+6552	;see if the line # is too big
	call	dcompr
	jp	c,pophsr	;yes, don'T SCAN ANY MORE DIGITS IF SO
				;force caller to see digit and give syntax error
				;can'T JUST GO TO SYNTAX ERROR BECAUSE OF NON-FAST
				;renum which can'T TERMINATE
	ld	h,d		;save [d,e]
	ld	l,e
	add	hl,de
	add	hl,hl
	add	hl,de
	add	hl,hl		;putting [d,e]*10 into [h,l]
	pop	af
	sub	'0'
	ld	e,a
	ld	d,0
	add	hl,de		;add the new digit
	ex	de,hl
	pop	hl		;get back text pointer
	jp	morlin
pophsr:	pop	af		;get off terminating digit
	pop	hl		;get back old text pointer
	ret

	;page
	;subttl	run, goto, gosub, return, data, rem

run:	jp	z,runc		;no line # argument
	cp	lincon		;line number constant?
	jp	z,conrun	;yes
	cp	ptrcon		;line pointer (rather unlikely)
	jp	nz,lrun
conrun:
	;clean up,set [h,l]=[txttab]-1 and
	;return to newstt
	call	clearc		;clean up -- reset the stack
	;datptr,variables ...
	;[h,l] is the only thing preserved
	ld	bc,newstt
	jp	runc2		;put "NEWSTT" on and fall into "GOTO"
; a "GOSUB" entry on the stack has the following format
;
; low address
;
;	a token equal to $gosub 1 byte
;	the line # of the the "GOSUB" statement 2 bytes
;	a pointer into the text of the "GOSUB" 2 bytes
;
; high address
;
; total 5 bytes
;
gosub:	ld	c,3		;"GOSUB" entries are 5 bytes long
	call	getstk		;make sure there is room
	call	linget		;must scan line number now
	pop	bc		;pop off return address of "NEWSTT"
	push	hl		;really push the text pointer
	push	hl		;save text pointer
	ld	hl,(curlin)	;get the current line #
	ex	(sp),hl		;put curlin on the stack and [h,l]=text ptr
	ld	a,$gosub
	push	af		;put gosub token on the stack
	inc	sp		;the gosub token takes only one byte
	push	bc		;save newstt on stack
	jp	goto2		;have now grab line # properly
				;continue with subroutine
runc2:	push	bc		;restore return address
	;of "NEWSTT"
; and search. in the 8k we start where we
; are if we are  going to a forward location.
;
goto:	call	linget		;pick up the line #
				;and put it in [d,e]
goto2:
	ld	a,(consav)	;get token for line # back
	cp	ptrcon		;was it a pointer
	ex	de,hl		;assume so
	ret	z		;if it was, go back to newstt
	;with [h,l] as text ptr
	ex	de,hl		;flip back if not
	push	hl		;save current text ptr on stack
	ld	hl,(contxt)	;get pointer to right after constant
	ex	(sp),hl		;save on stack, restore current text ptr
	call	rem		;skip to the end of this line
	inc	hl		;point at the link beyond it
	push	hl		;save the pointer
	ld	hl,(curlin)	;get the current line #
	call	dcompr		;[d,e] contains where we are going
				;[h,l] contains the current line #
				;so comparing them tells us whether to
				;start searching from where we are or
				;to start searching from the beginning
				;of txttab
	pop	hl		;[h,l]=current pointer
	call	c,loop		;search from this point
	call	nc,fndlin	;search from the beginning -- actually
				;search again if above search failed
	jp	nc,userr	;line not found, death
	dec	bc		;point to zero at end of previous line
	ld	a,ptrcon	;pointer constant
	ld	(ptrflg),a	;set ptrflg
	pop	hl		;get saved pointer to right after constant
	call	conch2		;change line # to ptr
	ld	h,b		;[h,l]= pointer to the start of the
				;matched line
	ld	l,c		;now pointing at the first byte of the pointer
				;to the start of the next line
	ret			;go to newstt
userr:	ld	e,errus
	jp	error		;c=match, so if no match we
				;give a "US" error
;
; see "GOSUB" for the format of the stack entry
; "RETURN" restores the line number and text pointer on the stack
; after eliminating all the "FOR" entries in front of the "GOSUB"
; entry
;
return:	ret	nz		;blow him up if there isn'T A TERMINATOR
	ld	d,255		;make sure this variable pointer
				;in [d,e] never gets matched
	call	fndfor		;go past all the "FOR" entries
	ld	sp,hl		;update the stack
	ld	(savstk),hl	;update saved stack
	cp	$gosub
	ld	e,errrg		;error errrg is "RETURN WITHOUT GOSUB"
	jp	nz,error
	pop	hl		;get line # "GOSUB" was from
	ld	(curlin),hl	;put it into curlin
	ld	hl,newstt
	ex	(sp),hl		;put return address of "NEWSTT"
				;back onto the stack. get text pointer
				;from "GOSUB"
				;skip over some characters
				;since when "GOSUB" stuck the text pointer
				;onto the stack the line # argument hadn'T
				;been read in yet.

	defb	76q		;"MVI A," around pop h.
datah:	pop	hl		;get text pointer off stack

data:	defb	1q		;"LXI B," to pick up ":" into c and skip
	defb	':'		;"DATA" terminates on ":"
				;and 0. ":" only applies if
				;quotes have matched up

elses:	;executed "ELSE"s are skipped
;
; note: rem must preserve [d,e] because of "GO TO" and error
;
rem:	defb	16q		;"MVI C,"   the only terminator is zero
	defb	0		;no-operation
	;"DATA" actually executes this 0
remzer:	ld	b,0		;inside quotes the only terminator is zero
exchqt:	ld	a,c		;when a quote is seen the second
	ld	c,b		;terminator is traded, so in "DATA"
	ld	b,a		;colons inside quotations will have no effect
remer:
	dec	hl		;nop the inx h in chrget
remer1:	call	chrgtr		;get a char
	or	a		;zero is always a terminator
	ret	z
	cp	b		;test for the other terminator
	ret	z
	inc	hl
	cp	34		;is it a quote?
	jp	z,exchqt	;if so time to trade
;
; when an "IF" takes a false branch it must find the appropriate "ELSE"
; to start execution at. "DATA" counts the number of "IF"s
; it sees so that the "ELSE" code can match "ELSE"s with
; "IF"s. the count is kept in [d]
	;because then s have tno colon
	;multiple ifs can be found in a single
	;statement scan
	;this causes a problem for 8-bit data
	;in unquoted string data because $if might
	;be matched. fix is to have falsif ignore changes
	;in [d] if its a data statement
;
	inc	a		;function token?
	jp	z,remer1	;then ignore following fn number
	sub	$if+1		;is it an "IF"
	jp	nz,remer	;if not, continue on
	cp	b		;since "REM" can'T SMASH
				;[d,e] we have to be careful
				;so only if b doesn'T EQUAL
				;zero we increment d. (the "IF" count)
	adc	a,d		;carry on if [b] not zero
	ld	d,a		;update [d]
	jp	remer
	;page
	;subttl	"LET"
	public	letcon

; letcon is let entry point with valtyp-3 in [a]
; because getypr has been called
letcon:	pop	af		;get valtype off stack
	add	a,3		;make valtype correct
	jp	letcn2		;continue

let:	call	ptrget		;get the pointer to the variable
				;named in text and put
				;it into [d,e]
	call	synchr
	defb	equltk		;check for "="
	ex	de,hl		;must set up temp for "FOR"
	ld	(temp),hl	;up here so when user-functions
	ex	de,hl		;call redinp, temp doesn'T GET CHANGED
redinp:	push	de
	ld	a,(valtyp)
	push	af
	call	frmevl		;get the value of the formula
	pop	af		;get the valtyp of the
				;variable into [a]
				;into fac
letcn2:	ex	(sp),hl		;[h,l]=pointer to variable
				;text pointer to on top of stack
inpcom:	ld	b,a		;save valtyp
	ld	a,(valtyp)	;get present valtype
	cp	b		;compare the two
	ld	a,b		;get back current
	jp	z,letcn5	;valtype already set up, go!
	call	docnvf		;force valtpes to be [a]'S
letcn4:	ld	a,(valtyp)	;get valtype
letcn5:	ld	de,faclo	;assume this is where to start moveing
	cp	5		;is it?
	jp	c,letcn6	;yes
	ld	de,dfaclo	;no, use d.p. fac
letcn6:	push	hl		;save the pointer at the value position
	cp	3		;string?
	jp	nz,copnum	;numeric, so force it and copy
	ld	hl,(faclo)	;get pointer to the descriptor of the result
	push	hl		;save the pointer at the descriptor
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	hl,(txttab)	;if the data is in buf, or in disk
				;random buffer, copy.
	call	dcompr		;since buf changes all the time
	jp	nc,inbufc	;go copy, if data really is in buf
	ld	hl,(strend)	;see if it points into string space
	call	dcompr		;if not don'T COPY
	pop	de		;get back the pointer at the descriptor
	jp	nc,dntcpy	;don'T COPY LITERALS
	ld	hl,dsctmp	;now, see if its a variable
	call	dcompr		;by seeing if the descriptor
				;is in the temporary storage area (below dsctmp)
	jp	nc,dntcpy	;don'T COPY IF ITS NOT A VARIABLE
	defb	76q		;skip the next byte with a "MVI A,"
inbufc:	pop	de		;get the pointer to the descriptor
				;in [d,e]
	call	fretms		;free up a temorary pointing into buf
	ex	de,hl		;strcpy copies [h,l]
	call	strcpy		;copy variables in string space or
				;strings with data in buf
dntcpy:	call	fretms		;free up the temporary without
				;freeing up any string space
	ex	(sp),hl		;[h,l]=place to store the descriptor
				;leave a nonsense entry on the stack,
				;since the "POP	D" doesn'T EVER
				;matter in this case
copnum:	call	vmove		;copy a descriptor or a value
	pop	de		;for "FOR" pop off a pointer
				;at the loop variable into [d,e]
	pop	hl		;get the text pointer back
	ret

	;page
	;subttl	on..goto, on error goto code

ongoto:
	cp	$error		;"ON...ERROR"?
	jp	nz,ntoerr	;no.
	call	chrgtr		;get next thing
	call	synchr
	defb	$goto		;must have ...goto
	call	linget		;get following line #
	ld	a,d		;is line number zero?
	or	e		;see
	jp	z,restrp	;if on error goto 0, reset trap
	call	fndln1		;see if line exists (save [h,l] on stack)
	ld	d,b		;get pointer to line in [d,e]
	ld	e,c		;(link field of line)
	pop	hl		;restore [h,l]
	jp	nc,userr	;error if line not found
restrp:	ex	de,hl		;get line pointer in [h,l]
	ld	(onelin),hl	;save pointer to line or zero if 0.
	ex	de,hl		;back to normal
	ret	c		;you wouldn'T BELIEVE IT IF I TOLD YOU
	ld	a,(oneflg)	;are we in an "ON...ERROR" routine?
	or	a		;set condition codes
	ld	a,e		;want an even stack ptr. for 8086
	ret	z		;if not, have already disabled trapping.
	ld	a,(errflg)	;get error code
	ld	e,a		;into e.
	jp	erresm		;force the error to happen
ntoerr:

	call	getbyt		;get value into [e]
	ld	a,(hl)		;get the terminator back
	ld	b,a		;save this character for later
	cp	$gosub		;an "ON ... GOSUB" perhaps?
	jp	z,isgosu	;yes, some feature use
	call	synchr
	defb	$goto		;otherwise must be "GOTO"
	dec	hl		;back up character pointer
isgosu:	ld	c,e		;get count into  [c]
loopon:	dec	c		;see if enough skips
	ld	a,b		;put dispatch character in place
	jp	z,gone2		;if done, go off
	call	lingt2		;skip over a line #
	cp	44		;a comma
	ret	nz		;if a comma doesn'T DELIMIT THE END OF
				;the current line # we must be the end of the line
	jp	loopon		;continue gobbling line #s

	;page
	;subttl	resume, error statement code

resume:	ld	de,oneflg	;point to flag
	ld	a,(de)		;get flag
	or	a		;trap routine.
	jp	z,reerr		;give resume without error error
	inc	a		;make a=0
	ld	(errflg),a	;clear error flag so ^c doesn'T GIVE ERROR
	ld	(de),a		;reset flag
	ld	a,(hl)		;get current char back
	cp	$next		;resume next?
	jp	z,resnxt	;yup.
	call	linget		;get following line #
	ret	nz		;should terminate
	ld	a,d		;is line number zero?
	or	e		;test
	jp	nz,goto2	;do a goto that line.
	inc	a		;set non zero condition codes
	jp	restxt		;go to it
resnxt:	call	chrgtr		;must terminate
	ret	nz		;blow him up
restxt:	ld	hl,(errtxt)	;get pointer into line.
	ex	de,hl		;save errtxt in [d,e]
	ld	hl,(errlin)	;get line #
	ld	(curlin),hl	;save in current line #
	ex	de,hl
	ret	nz		;go to newstt if just "RESUME"
	ld	a,(hl)		;get ":" or line header
	or	a		;set cc
	jp	nz,notbgl	;#0 means must be ":"
	inc	hl		;skip header
	inc	hl
	inc	hl
	inc	hl
notbgl:	inc	hl		;point to start of this statement
	jp	data		;get next stmt

; this is the error <code> statement which forces
; an error of type <code> to occur
; <code> must be .ge. 0 and .le. 255
errors:	call	getbyt		;get the param
	ret	nz		;should have terminated
	or	a		;error code 0?
	jp	z,fcerr		;yes, error in itself
goerr:	jp	error		;force an error

	;page
	;subttl	auto command

; the auto [begginning line[,[increment]]]
; command is used to automatically generate line numbers
; for lines to be inserted. beginning line is
; used to specify the inital line (10 is assumed if ommited)
; and the increment is used to specify the increment used
; to generate the next line #. if only a comma is used after the
; beggining line, the old increment is used.
auto:	ld	de,0+10		;assume initial line # of 10
	push	de		;save it
	jp	z,sngaut	;if end of command use 10,10
	call	linspc		;get line #, allow use of . for current line
	ex	de,hl		;get txt ptr in [d,e]
	ex	(sp),hl		;put init on stack, get 10 in [h,l]
	jp	z,sngau1	;if terminator, use inc of 10
	ex	de,hl		;get text ptr back in [h,l]
	call	synchr
	defb	','		;comma must follow
	ex	de,hl		;save text ptr in [d,e]
	ld	hl,(autinc)	;get previous inc
	ex	de,hl		;get back text ptr; get in in[d,e]
	jp	z,sngaut	;use previous inc if terminator
	call	linget		;get inc
	jp	nz,snerr	;should have finished.
sngaut:	ex	de,hl		;get inc in [h,l]
sngau1:	ld	a,h		;see if zero
	or	l
	jp	z,fcerr		;zero inc gives fcerr
	ld	(autinc),hl	;save increment
	ld	(autflg),a	;set flag to use auto in main code.
	pop	hl		;get initial line #
	ld	(autlin),hl	;save in intial line
	pop	bc		;get rid of newstt addr
	jp	main		;jump into main code (for rest see after main:)

	;page
	;subttl	if ... then code

ifs:	call	frmevl		;evaluate a formula
	ld	a,(hl)		;get terminating character of formula

	cp	44
	call	z,chrgtr	;if so skip it
	cp	$goto		;allow "GOTO" as well
	jp	z,okgoto
	call	synchr
	defb	thentk		;must have a then
	dec	hl
okgoto:
	push	hl		;save the text pointer
	call	vsign
	pop	hl		;get back the text pointer
	jp	z,falsif	;handle possible "ELSE"
docond:	call	chrgtr		;pick up the first line # character
	ret	z		;return for "THEN :" or "ELSE :"
	cp	lincon		;line number constant?
	jp	z,goto		;do a "GOTO"
	cp	ptrcon		;pointer constant
	jp	nz,gone2	;execute statement, not goto
	ld	hl,(conlo)	;get text pointer
	ret			;fetch new statment
;
; "ELSE" handler. here on false "IF" condition
;
falsif:	ld	d,1		;number of "ELSE"s that must
				;be seen. "DATA" increments this
				;count every time an "IF" is seen
skpmrf:	call	data		;skip a statement
				;":" is stuck in front of "ELSE"s
				;so that "DATA" will stop before "ELSE" clauses
	or	a		;end of line?
	ret	z		;if so, no "ELSE" clause
	call	chrgtr		;see if we hit an "ELSE"
	cp	$else
	jp	nz,skpmrf	;no, still in the "THEN" clause
	dec	d		;decrement the number of "ELSE"s that
				;must be seen
	jp	nz,skpmrf	;skip more if haven'T SEEN
				;enough
	jp	docond		;found the right "ELSE" -- go execute

	;page
	;subttl	print code

lprint:	ld	a,1		;say non zero
	ld	(prtflg),a	;save away
	jp	newchr
print:
	ld	c,md.sqo	;setup output file
	call	filget
newchr:	dec	hl
	call	chrgtr		;get another character
	call	z,crdo		;print crlf if end without punctuation
printc:	jp	z,finprt	;finish by resetting flags
				;finish by resetting flags
				;in which case a terminator does not
				;mean we should type a crlf
				;but just return
	cp	usintk		;is it "PRINT USING" ?
	jp	z,prinus	;if so, use a special handler
	cp	tabtk
	jp	z,taber		;the tab function?
	cp	spctk
	jp	z,taber		;the spc function?
	push	hl		;save the text pointer
	cp	44
	jp	z,comprt	;is it a comma?
	cp	59		;is it a ";"
	jp	z,notabr
	pop	bc		;get rid of old text pointer
	call	frmevl		;evaluate the formula
	push	hl		;save text pointer
	call	getypr		;see if we have a string
	jp	z,strdon	;if so, print specialy
	call	fout		;make a number into a string
	call	strlit		;make it  a string
	ld	(hl),' '	;put a space at the end
	ld	hl,(faclo)	;and increase size by 1
	inc	(hl)		;size byte is first in descriptor

strdon:				;use folding for strings and #s
	ld	hl,(ptrfil)	;disk output?
	ld	a,h		;if so, don'T EVER FORCE A CRLF
	or	l
	jp	nz,linch2	;to be sent out
	ld	hl,(faclo)	;get the pointer
	ld	a,(prtflg)
	or	a
	jp	z,istty		;lpt or tty?
	ld	a,(lptsiz)	;get width of printer
	ld	b,a		;save in [b]
	inc	a		;is it infinite?
	jp	z,linch2	;then just print
	ld	a,(lptpos)
	or	a		;don'T DO A CRLF IF STRING LONGER THAN LINE
	jp	z,linch2	;length if position is 0
	add	a,(hl)
	ccf			;set nc if overflow on check
	jp	nc,linchk	;start on a new line
	cp	b		;check for overlap
	jp	linchk
istty:
	ld	a,(linlen)
	ld	b,a
	inc	a		;no overflow line width?
	jp	z,linch2	;yes
	ld	a,(ttypos)	;see where we are
				;see where we are
	or	a		;don'T DO CRLF
	jp	z,linch2	;if already at 0 even if string is longer that line length
	add	a,(hl)		;add this length
	ccf			;set nc if overflow on check
	jp	nc,linchk	;(possible since strings can be big..)
	dec	a		;actually equal to line length is ok
	cp	b
	public	linpt3
linpt3	defl	$-1
linchk:	call	nc,crdo		;if so crlf
linch2:	call	strprt		;print the number
	pop	hl
	jp	newchr		;print some more
comprt:
	ld	hl,(ptrfil)	;outputing into a file?
	ld	a,h		;if so, [ptrfil] .ne. 0
	or	l		;and special print position should
	extrn	nmlo.c
	ld	bc,nmlo.c	;be fetched from file data
	add	hl,bc		;[h,l] point at position
	ld	a,(hl)		;if file is active
	jp	nz,morcom
	ld	a,(prtflg)	;output to the line printer?
	or	a		;non-zero means yes
	jp	z,isctty	;no, do teletype comma
	ld	a,(nlppos)	;are we using infinite width?
	ld	b,a		;also put in [b]
	inc	a		;test
	ld	a,(lptpos)	;get line printer position
	jp	z,morcom	;always do modulus if width=255
	cp	b		;check if no more comma fields
	jp	chkcom		;use teletype check
isctty:
	ld	a,(clmlst)
	ld	b,a
	ld	a,(ttypos)	;get teletype position
ncmpos	defl	(((linln/clmwid)-1)*clmwid);position beyond which there are
	cp	255		;infinite width?
	jp	z,morcom	;do modulus

	cp	b
	public	linpt4
linpt4	defl	$-1		;fixed up by "TERMINAL WIDTH" question
chkcom:	call	nc,crdo		;type crlf
	jp	nc,notabr	;and quit if beyond the last comma field
morcom:	sub	clmwid		;get [a] modulus clmwid
	jp	nc,morcom
	cpl			;we want to  fill
				;the print position out
				;to an even clmwid, so
				;we print clmwid-[a] mod clmwid spaces
	jp	aspa2		;go print [a]+1 spaces
taber:
	push	af		;remember if [a]=spctk or tabtk
	call	chrgtr
	call	getin2		;evaluate the argument
	pop	af		;see if its spc or tab
	push	af
	cp	spctk		;if space leave alone
	jp	z,spcndc
	dec	de		;offset by 1
spcndc:	ld	a,d
	or	a		;make sure its not negative
	jp	p,tbnong
	ld	de,0
tbnong:	push	hl		;save the text pointer
	ld	hl,(ptrfil)	;see if going to disk file
	ld	a,h
	or	l
	jp	nz,lnomod	;dont mod
	ld	a,(prtflg)	;going to printer?
	or	a		;set flags
	ld	a,(lptsiz)	;get size
	jp	nz,lptmdf	;was lpt, mod by its size
	ld	a,(linlen)	;get the line length
lptmdf:	ld	l,a
	inc	a		;test for width of 255 (no folding)
	jp	z,lnomod	;if so, dont mod
	ld	h,0		;mod out by line length
	call	imod
	ex	de,hl		;set [e] = position to go to
lnomod:	pop	hl		;get back the text pointer
	call	synchr
	defb	')'
	dec	hl
	pop	af		;get back spctk or tabtk
	sub	spctk		;was it spctk?
	push	hl		;save the text pointer
	jp	z,dosizt	;value in [a]
	ld	hl,(ptrfil)	;outputing into a file?
	ld	a,h		;if so, [ptrfil] .ne. 0
	or	l		;and special print position should

	ld	bc,nmlo.c	;be fetched from file data
	add	hl,bc		;[h,l] point at position
	ld	a,(hl)		;if file is active
	jp	nz,dosizt	;do tab calculation now
	ld	a,(prtflg)	;line printer or tty?
	or	a		;non-zero means lpt
	jp	z,ttyist
	ld	a,(lptpos)	;get line printer position
	jp	dosizt
ttyist:
	ld	a,(ttypos)	;get teletype print position
				;see where we are
dosizt:	cpl			;print [e]-[a] spaces
	add	a,e
	jp	c,aspa2		;print if past current
	inc	a
	jp	z,notabr	;do nothing if at current
	call	crdo		;go to a new line
	ld	a,e		;get the position to go to
	dec	a
	jp	m,notabr
	;spaces
aspa2:	inc	a
aspac:	ld	b,a		;[b]=number of spaces to print
	ld	a,' '		;[a]=space
repout:	call	outdo		;print [a]
				;decrement the count
	dec	b
	jp	nz,repout
notabr:	pop	hl		;pick up text pointer
	call	chrgtr		;and the next character
	jp	printc		;and since we just printed
				;spaces, don'T CALL CRDO
				;if it'S THE END OF THE LINE
	public	finprt
finprt:
	xor	a

	ld	(prtflg),a
	push	hl		;save the text pointer
	ld	h,a		;[h,l]=0
	ld	l,a
	ld	(ptrfil),hl	;zero out ptrfil
	pop	hl		;get back the text pointer
	ret

	;page
	;subttl	line input, input and read code

line:
	call	synchr
	defb	$input
	cp	'#'		;see if there is a file number
	extrn	dline
	jp	z,dline		;do disk input line
	call	scnsem		;scan semicolon for no-cr
	call	qtinp		;print quoted string if one
	call	ptrget		;read string to store into
	call	chkstr		;make sure its a string
	push	de		;save pointer at variable
	push	hl		;save text pointer
	extrn	sinlin
	call	sinlin		;read a line of input
	pop	de		;get text pointer
	pop	bc		;get pointer at variable
	jp	c,stpend	;if control-c, stop
reline:	push	bc		;save back variable pointer
	push	de		;save text pointer
	ld	b,0		;setup zero as only terminator
	call	strlt3		;literalize the input
	pop	hl		;restore [h,l]=text pointer
	ld	a,3		;set three for string
	jp	letcn2		;do the assignment
tryagn:
	dc	'?Redo from start'
	defb	13
	defb	10
	defb	0
;
; here when passing over string literal in subscript of variable in input list
; on the first pass of input checking for type match and number
;
scnstr:	inc	hl		;look at the next character
	ld	a,(hl)		;fetch it
	or	a		;end of line?
	jp	z,snerr		;ending in string in subscript is bad syntax
	cp	34		;only other terminator is quote
	jp	nz,scnstr	;continue until quote or 0 is found
	jp	scncon		;continue matching parens since string ended

inpbak:	pop	hl		;get rid of pass1 data pointer
	pop	hl		;get rid of pass2 data pointer
	jp	rdoin2		;get rid of pass2 varlst pointer and retry
;
; here when the data that was typed in or in "DATA" statements
; is improperly formatted. for "INPUT" we start again.
; for "READ" we give a syntax error at the data line
;
trmnok:	ld	a,(flginp)	;was it read or input?
	or	a		;zero=input
	jp	nz,datsne	;give error at data line
rdoin2:	pop	bc		;get rid of the pointer into the variable list
rdoinp:
	ld	hl,tryagn
	call	strout		;print "?REDO FROM START"
				;to newstt pointing at the start of

				;start all over
	ld	hl,(savtxt)	;get saved text pointer
	ret			;go back to newstt
				;of the "INPUT" statement
filsti:	call	filinp
	push	hl		;put the text pointer on the stack
	ld	hl,bufmin	;point at a comma
	jp	inpcn3
input:

	cp	'#'
	jp	z,filsti
	call	scnsem		;scan semicolon for no-cr
	ld	bc,notqti	;where to go
	push	bc		;when done with quoted string
qtinp:	cp	34		;is it a quote?
	ld	a,0		;be talkative
	ld	(cntofl),a	;force output
	ld	a,255		;make non-zero value
	ld	(tempa+1),a	;flag to do "? "
	ret	nz		;just return
	call	strlti		;make the message a string
	ld	a,(hl)		;get char
	cp	','		;comma?
	jp	nz,nticma	;no
	xor	a		;flag not to do it
	ld	(tempa+1),a
	call	chrgtr		;fetch next char
	jp	inpcma		;continue
nticma:
	call	synchr
	defb	';'		;must end with semi-colon
inpcma:
	push	hl		;remember where it ended
	call	strprt		;print it out
	pop	hl		;get back saved text ptr
	ret			;all done
notqti:
	push	hl
getagn:
	ld	a,(tempa+1)	;do "? "
	or	a
	jp	z,supprs	;then suppress "?"
	ld	a,'?'		;type "?" and input a line of text
	call	outdo
	ld	a,' '
	call	outdo
	extrn	sinlin
supprs:	call	sinlin
	pop	bc		;take off since maybe leaving
	jp	c,stpend	;if empty leave
	push	bc		;put back  since didn'T LEAVE
;
; this is the first pass dictated by ansi requirment than no values be assigned
; before checking type and number. the variable list is scanned without evaluat
; subscripts and the input is scanned to get its type. no assignment
; is done
;
	ld	(hl),44		;put a comma in front of buf
	ex	de,hl		;save data pointer in [d,e]
	pop	hl		;get the varlst pointer into [h,l]
	push	hl		;resave the varlst pointer
	push	de		;save a copy of the data pointer for pass2
	push	de		;save the data pointer for pass1
	dec	hl		;read the first variable name
varlop:	ld	a,128		;don'T ALLOW SUBSCRIPTS -- RETURN POINTING TO "("
	ld	(subflg),a
	call	chrgtr		;advance text pointer
	call	ptrget		;scan name and return pointer in [d,e]
	ld	a,(hl)		;see if it ended on "("
	dec	hl		;rescan the terminator
	cp	'('		;array or not?
	jp	nz,endscn	;if not, variable name is done
	inc	hl		;now scan the subscript expression
	ld	b,0		;initialize the paren count
scnopn:	inc	b		;up the count for every "("
scncon:	call	chrgtr		;get the next character
	jp	z,snerr		;shouldn'T END STATEMENT IN EXPRESSION
	cp	34		;is there a quoted string constant
	jp	z,scnstr	;go scan the endtire constant (may contain parens)
	cp	'('		;another level of nesting?
	jp	z,scnopn	;increment coutn and keep scanning
	cp	')'		;one less level of parens?
	jp	nz,scncon	;no, keep scanning
				;decrement paren count. out of subscript?
	dec	b
	jp	nz,scncon	;if not at zero level, keep scanning
endscn:	call	chrgtr		;get terminating character
	jp	z,okvlst	;last variable in input list
	cp	44		;otherwise it must be a comma
	jp	nz,snerr	;badly formed input -- syntax error
okvlst:	ex	(sp),hl		;save the varlst pointer
				;get the data pointer into [h,l]
	ld	a,(hl)		;data should always have a leading comma
	cp	44		;is it properly formed?
	jp	nz,inpbak	;no, ask for complete reinput
	ld	a,1		;set ovcstr=1
	ld	(ovcstr),a
	call	scnval		;go into pass2 code and scan a value
	ld	a,(ovcstr)	;see if it was too big
	dec	a
	jp	nz,inpbak
	push	hl		;save the returned data pointer
	call	getypr		;release string
	call	z,frefac
	pop	hl
	dec	hl		;skip over spaces left after value scan
	call	chrgtr
;
; note check for overflow of input value here
;
	ex	(sp),hl		;save the data pointer
				;[h,l]=data list pointer
	ld	a,(hl)		;did variable list continue?
	cp	44		;must have had a comma
	jp	z,varlop	;go check another
	pop	hl		;get final data pointer
	dec	hl		;skip over any trailing spaces
	call	chrgtr
	or	a		;is it a true end?
	pop	hl		;get the start of data pointer for pass2
	jp	nz,rdoin2	;if data ended badly ask for reinput
inpcn3:
	ld	(hl),44		;setup comma at bufmin
	jp	inpcon
read:
	push	hl		;save the text pointer
	ld	hl,(datptr)	;get last data location
	defb	366q		;"ORI" to set [a] non-zero
inpcon:	xor	a		;set flag that this is an input
	ld	(flginp),a	;store the flag
;
; in the processing of data and read statements:
; one pointer points to the data (ie the numbers being fetched)
; and another points to the list of variables
;
; the pointer into the data always starts pointing to a
; terminator -- a , : or end-of-line
;
	ex	(sp),hl		;[h,l]=variable list pointer
				;data pointer goes on the stack
	jp	lopdat
lopdt2:	call	synchr
	defb	44		;make sure there is a ","
lopdat:	call	ptrget		;read the variable list
				;and get the pointer to a variable into [d,e]
	ex	(sp),hl		;put the variable list pointer onto the
				;stack and take the
				;data list pointer off
;
; note at this point we have a variable which wants data
; and so we must get data or complain
;
	push	de		;save the pointer to the variable we
				;are about to set up with a value
	ld	a,(hl)		;since the data list pointer always points
				;at a terminator lets read the
				;terminator into [a] and see what
				;it is
	cp	44
	jp	z,datbk		;a comma so a value must follow
	ld	a,(flginp)	;see what type of statement this was
	or	a
				;search for another data statement
	jp	nz,datlop
				;the data now starts at the beginning
				;of the buffer
				;and qinlin leaves [h,l]=buf
datbk:
	defb	366q		;set a non-zero
scnval:	xor	a		;set zero flag in [a]
	ld	(inppas),a	;store so early return check works
	ex	de,hl		;save the data pointer
	ld	hl,(ptrfil)	;see if a file read
	ld	a,h
	or	l
	ex	de,hl
	jp	nz,filind	;if so, special handling
	call	getypr		;is it a string?
	push	af		;save the type information
	jp	nz,numins	;if numeric, use fin to get it
				;only the varaible type is
				;checked so an unquoted string
				;can be all digits
	call	chrgtr
	ld	d,a		;assume quoted string
	ld	b,a		;setup terminators
	cp	34		;quote ?
	jp	z,nowget	;terminators ok
	ld	a,(flginp)	;input shouldn'T TERMINATE ON ":"
	or	a		;see if read or input
	ld	d,a		;set d to zero for input
	jp	z,ncolst
	ld	d,':'		;unquoted string terminators
ncolst:	ld	b,44		;are colon and comma
				;note: ansi uses [b]=44 as a flag to
				;trigger trailing space suppression
	dec	hl		;backup since start character must be included
				;in the quoted string case we don'T WANT TO
				;include the starting or ending quote
nowget:	call	strlt2		;make a string descriptor for the value
				;and copy if necessary
doasig:	pop	af		;pop off the type information
	add	a,3		;make valtype correct
	ld	c,a		;save value type in [c]
	ld	a,(inppas)	;see if scanning values for pass1
	or	a		;zero for pass1
	ret	z		;go back to pass1
	ld	a,c		;recover valtyp
	ex	de,hl		;[d,e]=text pointer
	ld	hl,strdn2	;return loc
	ex	(sp),hl		;[h,l]=place to store variable value
	push	de		;text pointer goes on
	jp	inpcom		;do assignment
numins:	call	chrgtr
	pop	af		;get back valtype of source
	push	af		;save back
	ld	bc,doasig	;assignment is complicated
				;even for numerics so use the "LET" code
	push	bc		;save on stack
	jp	c,fin		;if not double, call usual # inputter
	jp	findbl		;else call special routine which expects doubles
strdn2:
	dec	hl
	call	chrgtr
	jp	z,trmok
	cp	44
	jp	nz,trmnok	;ended properly?
trmok:
	ex	(sp),hl
	dec	hl		;look at terminator
	call	chrgtr		;and set up condition codes
	jp	nz,lopdt2	;not ending, check for comma
				;and get another variable
				;to fill with data

	pop	de		;pop off the pointer into data
	ld	a,(flginp)	;fetch the statement type flag
	or	a
				;input statement
	ex	de,hl
	jp	nz,resfin	;update datptr
	push	de		;save the text pointer
finprg:	pop	hl		;get back the text pointer
	jp	finprt
;
; the search for data statments is made by using the execution code
; for data to skip over statements. the start word of each statement
; is compared with $data. each new line number
; is stored in datlin so that if an error occurs while reading
; data the error message will give the line number of the
; ill-formatted data
;
datlop:	call	data
datfnd:	or	a
	jp	nz,nowlin
	inc	hl
	ld	a,(hl)
	inc	hl
	or	(hl)
	ld	e,errod		;no data is error errod
	jp	z,error		;if so complain
	inc	hl		;skip past line #
	ld	e,(hl)		;get data line #
	inc	hl
	ld	d,(hl)
	ex	de,hl
	ld	(datlin),hl
	ex	de,hl		;restore text pointer
nowlin:	call	chrgtr		;get the statement type
	cp	$data		;is is "DATA"?
	jp	nz,datlop	;not data so look some more
	jp	datbk		;continue reading



	;page

	;subttl	formula evaluation code

;
; the formula evaluator starts with
; [h,l] pointing to the first character of the formula.
; at the end [h,l] points to the terminator.
; the result is left in the fac.
; on return [a] does not reflect the terminating character
;
; the formula evaluator uses the operator table (optab)
; to determine precedence and dispatch addresses for
; each operator.
; a temporary result on the stack has the following format
;
; the address of 'RETAOP' -- the place to return on completion
; of operator application
;
; the floating point temporary result
;
; the address of the operator rountine
;
; the precedence of the operator
;
; total 10 bytes
;
frmeql:	call	synchr
	defb	equltk		;check for equal sign
	jp	frmevl		;evaluate formula and return
frmprn:	call	synchr
	defb	'('		;get paren before formula
frmevl:	dec	hl		;back up character pointer
frmchk:	ld	d,0		;initial dummy precedence is 0
lpoper:	push	de		;save precedence
	ld	c,1		;extra space needed for return address
	call	getstk		;make sure there is room for recursive calls
	call	eval		;evaluate something
				;reset overflow printing back to normal
	xor	a		;(set to 1 at fundsp to suppress
	ld	(flgovc),a	;multiple overflow messages)
tstop:	ld	(temp2),hl	;save text pointer
retaop:	ld	hl,(temp2)	;restore text ptr
	pop	bc		;pop off the precedence of oldop
notstv:	ld	a,(hl)		;get next character
	ld	(temp3),hl	;save updated character pointer
	cp	greatk		;is it an operator?
	ret	c		;no, all done (this can result in operator
				;application or actual return)
	cp	lesstk+1	;some kind of relational?
	jp	c,dorels	;yes, do it
	sub	plustk		;subtraxdct offset for first arithmetic
	ld	e,a		;must multiply by 3 since
				;optab entries are 3 long
	jp	nz,ntplus	;not addition op
	ld	a,(valtyp)	;see if left part is string
	cp	3		;see if its a string
	ld	a,e		;refetch op-value
	jp	z,cat		;must be cat
ntplus:
	cp	lstopk		;higher than the last op?
	ret	nc		;yes, must be terminator
	ld	hl,optab	;create index into optab
	ld	d,0		;make high byte of offset=0
	add	hl,de		;add in calculated offset
	ld	a,b		;[a] gets old precedence
	ld	d,(hl)		;remember new precedence
	cp	d		;old-new
	ret	nc		;must apply old op
				;if has greater or = precedence
				;new operator

	push	bc		;save the old precedence
	ld	bc,retaop	;put on the address of the
	push	bc		;place to return to after operator application
	ld	a,d		;see if the operator is exponentiation
	cp	127		;which has precedence 127
	jp	z,expstk	;if so, "FRCSNG" and make a special stack entry
	cp	81		;see if the operator is "AND" or "OR"
	jp	c,andord	;and if so "FRCINT" and
				;make a special stack entry
	and	254		;make 123 and 122 both map to 122
	cp	122		;make a special check for "MOD" and "IDIV"
	jp	z,andord	;if so, coerce arguments to integer
; this code pushes the current value in the fac
; onto the stack, except in the case of strings in which it calls
; type mismatch error. [d] and [e] are preserved.
;
numrel:	ld	hl,faclo	;save the value of the fac
pusval:	ld	a,(valtyp)	;find out what type of value we are saving
	sub	3		;setup the condition codes
				;set zero for strings
	jp	z,tmerr
	or	a		;set parity -- carry unaffected since off
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	push	bc		;push faclo+0,1 on the stack
	jp	m,vpushd	;all done if the data was an integer
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	push	bc		;push fac-1,0 on the stack
	jp	po,vpushd	;all done if we had a sng
	inc	hl
	ld	hl,dfaclo	;we have a double precison number
	ld	c,(hl)		;push its 4 lo bytes on the stack
	inc	hl
	ld	b,(hl)
	inc	hl
	push	bc
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	push	bc		;user-defined functions require that the
				;[h,l] returned points at the last value
				;byte and not beyond it
vpushd:
	add	a,3		;fix [a] to be the valtyp of the number
				;just pushed on the stack
	ld	c,e		;[c]=operator number
	ld	b,a		;[b]=type of value on the stack
	push	bc		;save these things for applop
	ld	bc,applop	;general operator application
				;routine -- does type conversions
fintmp:	push	bc		;save place to go
	ld	hl,(temp3)	;reget the text pointer
	jp	lpoper		;push on the precedence and read more formula
dorels:	ld	d,0		;assume no relation ops
				;also setup the high order of the index into optab
loprel:	sub	greatk		;is this one relation?
	jp	c,finrel	;relations all through
nmrel	defl	lesstk-greatk+1
	cp	nmrel		;is it really relational?
	jp	nc,finrel	;no just big
	cp	1		;set up bits by mapping
	rla			;0 to 1 1 to 2 and 2 to 4
	xor	d		;bring in the old bits
	cp	d		;make sure result is bigger
	ld	d,a		;save the mask
	jp	c,snerr		;don'T ALLOW TWO OF THE SAME
	ld	(temp3),hl	;save character pointer
	call	chrgtr		;get the next candidate
	jp	loprel
;
; for exponentiation we want to force the current value in the fac
; to be single precision. when application time comes we force
; the right hand operand to single precision as well
;
	extrn	fpwrq
expstk:	call	frcsng		;coerce left hand operand
	call	pushf		;put it on the stack
	ld	bc,fpwrq	;place to coerce right hand
				;operand and do exponentiation
	ld	d,127		;restore the precedence
	jp	fintmp		;finish entry and evaluate more formula
;
; for "AND" and "OR" and "\" and "MOD" we want to force the current value
; in the fac to be an integer, and at application time force the right
; hand operand to be an integer
;
andord:	push	de		;save the precedence
	call	frcint
	pop	de		;[d]=precedence
	push	hl		;push the left hand operand
	ld	bc,dandor	;"AND" and "OR" doer
	jp	fintmp		;push on this address,precedence
				;and continue evaluation
;
; here to build an entry for a relational operator
; strings are treated specially. numeric compares are different
; from most operator entries only in the fact that at the
; bottom instead of having retaop, docmp and the relational
; bits are stored. strings have strcmp,the pointer at the string descriptor,
; docmp and the relational bits.
;
finrel:	ld	a,b		;[a]=old precedence
	cp	100		;relationals have precedence 100
	ret	nc		;apply earlier operator if it has
				;higher precedence
	push	bc		;save the old precedence
	push	de		;save [d]=relational bits
	ld	de,0+256*100+opcnt;[d]=precedence=100
				;[e]=dispatch offset for
				;compares in applop=4
				;in case this is a numeric compare
	ld	hl,docmp	;routine to take compare routine result
				;and relational bits and return the answer
	push	hl		;does a jmp to retaop when done
	call	getypr		;see if we have a numeric compare
	jp	nz,numrel	;yes, build an applop entry
	ld	hl,(faclo)	;get the pointer at the string descriptor
	push	hl		;save it for strcmp
	ld	bc,strcmp	;string compare routine
	jp	fintmp		;push the address, reget the text pointer
				;save the precedence and scan
				;more of the formula
;
; applop is returned to when it is time to apply an arithmetic
; or numeric comparison operation.
; the stack has a double byte entry with the operator
; number and the valtyp of the value on the stack.
; applop decides what value level the operation
; will occur at, and converts the arguments. applop
; uses different calling conventions for each value type.
; integers: left in [d,e] right in [h,l]
; singles:  left in [b,c,d,e] right in the fac
; doubles:  left in fac   right in arg
;
applop:	pop	bc		;[b]=stack operand value type
				;[c]=operator offset
	ld	a,c		;save in memory since the stack will be busy
	ld	(oprtyp),a	;a ram location
	ld	a,(valtyp)	;get valtyp of fac
	cp	b		;are valtypes the same?
	jp	nz,valnsm	;no
	cp	2		;integer?
	jp	z,intdpc	;yes, dispatch!!
	cp	4		;single?
	jp	z,sngdpc	;yes, dispatch!!
	jp	nc,dbldpc	;must be double, dispatch!!
valnsm:	ld	d,a		;save in [d]
	ld	a,b		;check for double
	cp	8		;precision entry on the stack
	jp	z,stkdbl	;force fac to double
	ld	a,d		;get valtype of fac
	cp	8		;and if so, convert the stack operand
	jp	z,facdbl	;to double precision
	ld	a,b		;see if the stack entry is single
	cp	4		;precision and if so, convert
	jp	z,stksng	;the fac to single precision
	ld	a,d		;see if the fac is single precision
	cp	3		;and if so convert the stack to single
	jp	z,tmerr		;blow up on right hand string operand
	jp	nc,facsng	;precision
				;note: the stack must be integer at this point
intdpc:	ld	hl,intdsp	;integer integer case
	ld	b,0		;special dispatch for speed
	add	hl,bc		;[h,l] points to the address to go to
	add	hl,bc
	ld	c,(hl)		;[b,c]=routine address
	inc	hl
	ld	b,(hl)
	pop	de		;[d,e]=left hand operand
	ld	hl,(faclo)	;[h,l]=right hand operand
	push	bc		;dispatch
	ret
;
; the stack operand is double precision, so
; the fac must be forced to double precision, moved into arg
; and the stack value poped into the fac
;
stkdbl:	call	frcdbl		;make the fac double precision
dbldpc:	call	vmovaf		;move the fac into arg
	pop	hl		;pop off the stack operand into the fac
	ld	(dfaclo+2),hl
	pop	hl
	ld	(dfaclo),hl	;store low bytes away
sngdbl:	pop	bc
	pop	de
				;pop off a four byte value
	call	movfr		;into the fac
setdbl:	call	frcdbl		;make sure the left operand is
				;double precision
	ld	hl,dbldsp	;dispatch to a double precision routine
dodsp:	ld	a,(oprtyp)	;recall which operand it was
	rlca			;create a dispatch offset, since
				;table addresses are two bytes
	add	a,l		;add low byte of address
	ld	l,a		;save back
	adc	a,h		;add high byte
	sub	l		;subtract low
	ld	h,a		;result back
	ld	a,(hl)		;get the address
	inc	hl
	ld	h,(hl)
	ld	l,a
	jp	(hl)		;and perform the operation, returning
				;to retaop, except for compares which
				;return to docmp
;
; the fac is double precision and the stack is either
; integer or single precision and must be converted
;
facdbl:	push	bc		;save the stack value type
	call	vmovaf		;move the fac into arg
	pop	af		;pop the stack value type into [a]
	ld	(valtyp),a	;put it in valtyp for the force
				;routine
	cp	4		;see if its single, so we know
				;how to pop the value off
	jp	z,sngdbl	;it'S SINGLE PRECISION
				;so do a popr / call movfr
	pop	hl		;pop off the integer value
	ld	(faclo),hl	;save it for conversion
	jp	setdbl		;set it up
;
; this is the case where the stack is single precision
; and the fac is either single precision or integer
;
stksng:	call	frcsng		;convert the fac if necessary
sngdpc:	pop	bc
	pop	de
				;put the left hand operand in the registers
sngdo:	ld	hl,sngdsp	;setup the dispatch address
				;for the single precision operator routines
	jp	dodsp		;dispatch
;
; this is the case where the fac is single precision and the stack
; is an integer.
;
facsng:	pop	hl		;pop off the integer on the stack
	call	pushf		;save the fac on the stack
	call	consih		;convert [h,l] to a single precision
				;number in the fac
	call	movrf		;put the left hand operand in the registers
	pop	hl		;restore the fac
	ld	(fac-1),hl	;from the stack
	pop	hl
	ld	(faclo),hl
	jp	sngdo		;perform the operation
;
; here to do integer division. since we want 1/3 to be
; .333333 and not zero we have to force both arguments
; to be single-precision floating point numbers
; and use fdiv
;
intdiv:	push	hl		;save the right hand argument
	ex	de,hl		;[h,l]=left hand argument
	call	consih		;convert [h,l] to a single-precision
				;number in the fac
	pop	hl		;get back the right hand argument
	call	pushf		;push the converted left hand argument
				;onto the stack
	call	consih		;convert the right hand argument to a
				;single precision number in the fac
	jp	fdivt		;do the division after poping into the
				;registers the left hand argument

	;page
	;subttl	eval - evaluate variable, constant, function call

eval:
	call	chrgtr
	jp	z,moerr		;test for missing operand - if none give error
	jp	c,fin		;if numeric, interpret constant
	call	islet2		;variable name?
	jp	nc,isvar	;an alphabetic character means yes
	cp	dblcon+1	;is it an embeded constant
	jp	c,confac	;rescan the token & restore old text ptr
	inc	a		;is it a function call (preceded by 377)
	jp	z,isfun		;yes, do it
	dec	a		;fix a back
	cp	plustk		;ignore "+"
	jp	z,eval
	cp	minutk		;negation?
	jp	z,domin
	cp	34		;string constant?
	jp	z,strlti	;if so build a descriptor in a temporary
				;descriptor location and put a pointer to the
				;descriptor in faclo.
	cp	nottk		;check for "NOT" operator
	jp	z,noter
	cp	'&'		;octal constant?
	jp	z,octcns
	cp	erctk
	jp	nz,nterc	;no, try other possibilities
	call	chrgtr		;grab following char
				;is it a disk error call?
	ld	a,(errflg)	;get the error code.
				;"cpi over next byte
ntderc:	push	hl		;save text pointer
	call	sngflt		;return the value
	pop	hl		;restore text pointer
	ret			;all done.

nterc:	cp	erltk		;error line number variable.
	jp	nz,nterl	;no, try more things.
	call	chrgtr		;get following character
	push	hl		;save text pointer
	ld	hl,(errlin)	;get the offending line #
	call	ineg2		;float 2 byte unsinged int
	pop	hl		;restore text pointer
	ret			;return
nterl:
	cp	$varpt		;varptr call?
	jp	nz,ntvarp	;no
	call	chrgtr		;eat char after
	call	synchr
	defb	'('		;eat left paren
	extrn	getptr
	cp	'#'		;want pointer to file?
	jp	nz,nvrfil	;no, must be variable
	call	gtbytc		;read file #
	push	hl		;save text ptr
	call	getptr		;get ptr to file
	pop	hl		;restore text ptr
	jp	varret
nvrfil:
	call	ptrget		;get address of variable
	public	varret
varret:	call	synchr
	defb	')'		;eat right paren
	push	hl		;save text pointer
	ex	de,hl		;get value to return in [h,l]
	ld	a,h		;make sure not undefined var
	or	l		;set cc'S. ZERO IF UNDEF
	jp	z,fcerr		;all over if undef (dont want
				;user poking into zero if he'S
				;too lazy to check
	call	makint		;make it an int
	pop	hl		;restore text pointer
	ret
ntvarp:
	cp	usrtk		;user assembly language routine??
	jp	z,usrfn		;go handle it
	cp	insrtk		;is it the instr function??
	jp	z,instr		;dispatch
	extrn	inkey
	cp	$inkey		;inkey$ function?
	jp	z,inkey		;go do it
	cp	$strin		;string function?
	jp	z,strng$	;yes, go do it
	extrn	fixinp
	cp	$input		;fixed length input?
	jp	z,fixinp	;yes
	cp	fntk		;user-defined function?
	jp	z,fndoer
	;numbered characters allowed
	;so there is no need to check
	;the upper bound
; only possibility left is a formula in parentheses
parchk:	call	frmprn		;recursively evaluate the formula
	call	synchr
	defb	')'
	ret
domin:
	ld	d,125		;a precedence below ^
				;but above all else
	call	lpoper		;so ^ greater than unary minus
	ld	hl,(temp2)	;get text pointer
	push	hl
	call	vneg
labbck:	;functions that don't return
	;string values come back here
	pop	hl
	ret
isvar:	call	ptrget		;get a pointer to the
				;variable in [d,e]
retvar:	push	hl		;save the text pointer
	ex	de,hl		;put the pointer to the variable value
				;into [h,l]. in the case of a string
				;this is a pointer to a descriptor and not
				;an actual value
	ld	(faclo),hl	;in case it'S STRING STORE THE POINTER
				;to the descriptor in faclo.
	call	getypr		;for strings we just leave
	call	nz,vmovfm	;a pointer in the fac
				;the fac using [h,l] as the pointer.
	pop	hl		;restore the text pointer
	ret
	public	makupl,makups
makupl:	ld	a,(hl)		;get char from memory
makups:	cp	'A'+40o		;is it lower case range
	ret	c		;less
	cp	'Z'+41o		;greater
	ret	nc		;test
	and	137o		;make upper case
	ret			;done
	public	cnsget
cnsget:
	cp	'&'		;octal perhaps?
	jp	nz,linget
	public	octcns
octcns:	ld	de,0		;initialize to zero and ignore overflow
	call	chrgtr		;get first char
	call	makups		;make upper if nesc.
	cp	'O'		;octal?
	jp	z,lopoct	;if so, do it
	cp	'H'		;hex?
	jp	nz,lopoc2	;then do it
	ld	b,5		;init digit count
lophex:	inc	hl		;bump pointer
	ld	a,(hl)		;get char
	call	makups		;make upper case
	call	islet2		;fetch char, see if alpha
	ex	de,hl		;save [h,l]
	jp	nc,alptst	;yes, make sure legal hec
	cp	'9'+1		;is it bigger than largest digit?
	jp	nc,octfin	;yes, be forgiving & return
	sub	'0'		;convert digit, make binary
	jp	c,octfin	;be forgiving if not hex digit
	jp	nxthex		;add in offset
alptst:	cp	'F'+1		;is it legal hex?
	jp	nc,hexfin	;yes, terminate
	sub	'A'-10		;make binary value
nxthex:	add	hl,hl		;shift right four bits
	add	hl,hl
	add	hl,hl
	add	hl,hl
	or	l		;or on new digit
	ld	l,a		;save back
	dec	b		;too many digits?
	jp	z,overr		;yup.
	ex	de,hl		;get text pointer back in [h,l]
	jp	lophex		;keep eating


lopoc2:	dec	hl		;reget last character
lopoct:	call	chrgtr		;read a digit
	ex	de,hl		;result into [h,l]
	jp	nc,octfin	;out of digits means done
	cp	'8'		;is this an octal digit
	jp	nc,snerr	;no, too bad you will lose
	ld	bc,overr	;where to go on overflow error
	push	bc		;save addr on stack
	add	hl,hl		;multiply by eight
	ret	c		;overflow error
	add	hl,hl
	ret	c		;overflow error
	add	hl,hl
	ret	c		;overflow error
	pop	bc		;get rid of overr addr
	ld	b,0		;setup to add [b,c]
	sub	'0'
	ld	c,a
	add	hl,bc		;add in the digit
	ex	de,hl		;put text pointer back in [h,l]
	jp	lopoct		;scan more digits
hexfin:
octfin:
hocfin:
	call	makint		;save as an integer
	ex	de,hl		;[h,l]-text pointer
	ret
isfun:
	inc	hl		;bump source text pointer
	ld	a,(hl)		;get the actual token for fn
	sub	onefun		;make into offset
	extrn	rndmon
	cp	$rnd-onefun	;is it rnd?
	jp	nz,ntmrnd	;if not no need to check monadic
	push	hl		;save text pointer
	call	chrgtr		;see if next char is "("
	cp	'('
	pop	hl		;get back the old text pointer
	jp	nz,rndmon	;handle monadic case
	ld	a,$rnd-onefun
ntmrnd:
	ld	b,0
	rlca			;multiply by 2
	ld	c,a
	push	bc		;save the function # on the stack
	call	chrgtr
	ld	a,c		;look at function #
numgfn	defl	2*midtk-2*onefun+1
	cp	numgfn		;is it past lasnum?
	jp	nc,oknorm	;no, must be a normal function
;
; most functions take a single argument.
; the return address of these functions is a small routine
; that checks to make sure valtyp is 0 (numeric) and pops off
; the text pointer. so normal functions that return string results (i.e. chr$)
; must pop off the return address of labbck, and pop off the
; text pointer and then return to frmevl.
;
; the so called "FUNNY" functions can take more than one argument.
; the first of which must be string and the second of which
; must be a number between 0 and 256. the text pointer is
; passed to these functions so additional arguments
; can be read. the text pointer is passed in [d,e].
; the close parenthesis must be checked and return is directly
; to frmevl with [h,l] setup as the text pointer pointing beyond the ")".
; the pointer to the descriptor of the string argument
; is stored on the stack underneath the value of the integer
; argument (2 bytes)
;
; first argument always string -- second integer
	call	frmprn		;eat open paren and first arg
	call	synchr
	defb	44		;two args so comma must delimit
	call	chkstr		;make sure the first one was string
	ex	de,hl		;[d,e]=txtptr
	ld	hl,(faclo)	;get ptr at string descriptor
	ex	(sp),hl		;get function #
				;save the string ptr
	push	hl		;put the function # on
	ex	de,hl		;[h,l]=txtptr
	call	getbyt		;[e]=value of formula
	ex	de,hl		;text pointer into [d,e]
				;[h,l]=int value of second argument
	ex	(sp),hl		;save int value of second arg
				;[h,l]=function number
	jp	fingo		;dispatch to function
oknorm:
	call	parchk		;check out the argument
				;and make sure its followed by ")"
	ex	(sp),hl		;[h,l]=function # and save text pointer
;
; check if special coercion must be done for one of the transcendental
; functions (rnd, sqr, cos, sin, tan, atn, log, and exp)
; these functions do not look at valtyp, but rather assume the
; argument passed in the fac is single precision, so frcsng
; must be called before dispatching to them.
;
	ld	a,l		;[a]=function number
botcon	defl	(sqrtk-onefun)*2
	cp	botcon		;less than square root?
	jp	c,notfrf	;don'T FORCE THE ARGUMENT
topcon	defl	(atntk-onefun)*2+1
	cp	topcon		;bigger than arc-tangent?
	push	hl		;save the function number
	call	c,frcsng	;if not, force fac to single-precision
	pop	hl		;restore the function number
notfrf:
	ld	de,labbck	;return address
	push	de		;make them really come back
	ld	a,1		;function should only print overflow once
	ld	(flgovc),a
fingo:	ld	bc,fundsp	;function dispatch table
dispat:	add	hl,bc		;add on the offset
	ld	c,(hl)		;faster than pushm
	inc	hl
	ld	h,(hl)
	ld	l,c
	jp	(hl)		;go perform the function


; the folowing routine is called from fin in f4
; to scan leading signs for numbers. it was moved
; to f3 to eliminate byte extrnals
	public	minpls
minpls:
	dec	d		;set sign of exponent flag
	cp	minutk		;negative exponent?
	ret	z
	cp	'-'
	ret	z
	inc	d		;no, reset flag
	cp	'+'
	ret	z
	cp	plustk		;ignore "+"
	ret	z
	dec	hl		;check if last character was a digit
	ret			;return with non-zero set

	;page
	;subttl	more formula evaluation - logical, relational ops

docmp:	inc	a		;setup bits
	adc	a,a		;4=less 2=equal 1=greater
	pop	bc		;what did he want?
	and	b		;any bits match?
	add	a,255		;map 0 to 0
	sbc	a,a		;and all others to 377
	call	conia		;convert [a] to an integer signed
	jp	retapg		;return from operator application
				;place so the text pointer
				;will get set up to what it was
				;when lpoper returned.
noter:	ld	d,90		;"NOT" has precedence 90, so
	call	lpoper		;formula evaluation is entered with a dummy
				;entry of 90 on the stack
	call	frcint		;coerce the argument to integer
	ld	a,l		;complement [h,l]
	cpl
	ld	l,a
	ld	a,h
	cpl
	ld	h,a
	ld	(faclo),hl	;update the fac
	pop	bc		;frmevl, after seeing the precedence
				;of 90 thinks it is applying an operator
				;so it has the text pointer in temp2 so

retapg:	jp	retaop		;return to refetch it
getypr:	ld	a,(valtyp)	;replacement for "GETYPE" rst
	cp	8
;
; continuation of getype rst
;

cgetyp:	jp	nc,ncase	;split off no carry case
	sub	3		;set a correctly
	or	a		;now set logical'S OK
	scf			;carry must be set
	ret			;all done

ncase:	sub	3		;subtract correctly
	or	a		;set cc'S PROPERLY
	ret			;return

;
; dandor applies the "AND" and "OR" operators
; and should be used to implement all logical operators.
; whenever an operator is applied, its precedence is in [b].
; this fact is used to distinguish between "AND" and "OR".
; the right hand argument is coerced to integer, just as
; the left hand one was when it was pushed on the stack.
;
dandor:	push	bc		;save the precedence "OR"=70
	call	frcint		;coerce right hand argument to integer
	pop	af		;get back the precedence to distinguish
				;"AND" and "OR"
	pop	de		;pop off the left hand argument
	cp	122		;is the operator "MOD"?
	jp	z,imod		;if so, use monte'S SPECIAL ROUTINE
	cp	123		;is the operator "IDIV"?
	jp	z,idiv		;let monte handle it
	ld	bc,givint	;place to return when done
	push	bc		;save on stack
	cp	70		;set zero for "OR"
	jp	nz,notor
	ld	a,e		;setup low in [a]
	or	l
	ld	l,a
	ld	a,h
	or	d
	ret			;return the integer [a,l]
notor:
	cp	80		;and?
	jp	nz,notand
	ld	a,e
	and	l
	ld	l,a
	ld	a,h
	and	d
	ret			;return the integer [a,l]

notand:	cp	60		;xor?
	jp	nz,notxor	;no
	ld	a,e
	xor	l
	ld	l,a
	ld	a,h
	xor	d
	ret

notxor:	cp	50		;eqv?
	jp	nz,noteqv	;no
	ld	a,e		;low part
	xor	l
	cpl
	ld	l,a
	ld	a,h
	xor	d
	cpl
	ret
;for "IMP" use a imp b = not(a and not(b))
noteqv:	ld	a,l		;must be "IMP"
	cpl
	and	e
	cpl
	ld	l,a
	ld	a,h
	cpl
	and	d
	cpl
	ret

	;page
;
; this routine subtracts [d,e] from [h,l]
; and floats the result leaving it in fac.
;
givdbl:	ld	a,l		;[h,l]=[h,l]-[d,e]
	sub	e
	ld	l,a
	ld	a,h
	sbc	a,d
	ld	h,a		;save high byte in [h]
	jp	ineg2		;float 2 byte unsigned int
lpos:	ld	a,(lptpos)
	jp	sngfli
pos:
	ld	a,(ttypos)	;get teletype position
				;see where we are
sngfli:

	;in adds version tab positions start at column 1.
	inc	a
	public	sngflt
sngflt:	ld	l,a		;make [a] an unsigned integer
	xor	a
givint:	ld	h,a
	jp	makint

	;page
	;subttl	user defined (usr) assembly language function code

usrfn:	call	scnusr		;scan the usr#
	push	de		;save pointer
	call	parchk		;eat left paren and formula
	ex	(sp),hl		;save text pointer & get index into usrtab
	ld	c,(hl)		;get dispatch adress
	inc	hl		;bump pointer
	ld	b,(hl)		;pick up 2nd byte of address
	ld	hl,pophrt	;get address of pop h ret
	push	hl		;push it on
	push	bc		;save address of usr routine
	ld	a,(valtyp)	;get argument type in [a]
	push	af		;save valtyp
	cp	3		;string??
	call	z,frefac	;free it up
	pop	af		;get back valtyp
	ex	de,hl		;move possible desc. pointer to [d,e]
	ld	hl,faclo	;pointer to fac in [h,l]
	ret			;call usr routine
scnusr:	call	chrgtr		;get a char
	ld	bc,0		;assume usr0
	cp	onecon+10	;single byte int expected
	jp	nc,noargu	;no, must be defaulting to usr0
	cp	onecon		;is it smaller than onecon
	jp	c,noargu	;yes, assume trying to default to usr0
usercn:	call	chrgtr		;scan past next char
	ld	a,(conlo)	;get value of 1 byter
	;yup
	or	a		;make sure carry is off
	rla			;multiply by 2
	ld	c,a		;save offset in [c]
noargu:	ex	de,hl		;save text pointer in [d,e]
	ld	hl,usrtab	;get start of table
	add	hl,bc		;add on offset
	ex	de,hl		;restore text pointer, address to [d,e]
	ret			;return from scan routine

defusr:	call	scnusr		;scan the usr name
	push	de		;save pointer to usrtab entry
	call	synchr
	defb	equltk		;must have equal sign
	call	getin2		;get the address
	ex	(sp),hl		;text pointer to stack, get address
	ld	(hl),e		;save usr call address
	inc	hl		;bump pointer
	ld	(hl),d		;save high byte of address
	pop	hl		;restore text pointer
	ret			;return to newstt

	;page
	;subttl	simple-user-defined-function code
;
; in the 8k version (see later comment for extended)
; note only single arguments are allowed to functions
; and functions must be of the single line form:
; def fna(x)=x^2+x-2
; no strings can be involved with these functions
;
; idea: create a funny simple variable entry
; whose first character (second word in memory)
; has the 200 bit set.
; the value will be:
;
; 	a txtptr to the formula
;	the name of the parameter variable
;
; function names can be like "FNA4"
;

def:
	cp	usrtk		;defining the call address of usr routine?
	jp	z,defusr	;yes, do it
	call	getfnm		;get a pointer to the function name
	call	errdir		;def is "ILLEGAL DIRECT"
				;memory, restore the txtptr
				;and go to "DATA" skipping the
				;rest of the formula
	ex	de,hl		;[d,e] = the text pointer after the function
				;name and [h,l] = pointer at place to store
				;value of the function variable
	ld	(hl),e		;save the text pointer as the value
	inc	hl
	ld	(hl),d
	ex	de,hl		;restore the text pointer to [h,l]
	ld	a,(hl)		;get next char
	cp	'('		;does this function have args?
	jp	nz,data		;no
	call	chrgtr
scnlis:	call	ptrget		;get pointer to dummy var(create var)
	ld	a,(hl)		;get terminator
	cp	')'		;end of arg list?
	jp	z,data		;yes
	call	synchr
	defb	44		;"," must follow then
	jp	scnlis

fndoer:	call	getfnm		;get a pointer to
	ld	a,(valtyp)	;find out what kind of function it is
	or	a		;push this [a] on with a psw with carry off
				;so that when values are being popped off
				;and restored to parameters we will know
				;when to stop
				;when a valtyp is popped off with
				;carry off
	push	af		;save so that the final result will
				;be coerced to the function type
	ld	(temp2),hl	;save the text pointer that points past
				;the function name in the call
	ex	de,hl		;[h,l]=a pointer to the value of function
	ld	a,(hl)		;[h,l]=value of the function
	inc	hl		;which is a text pointer at the formal
	ld	h,(hl)		;parameter list in the definition
	ld	l,a
	or	h		;a zero text pointer means the function
				;was never defined
	jp	z,uferr		;if so, given an "UNDEFINED FUNCTION" error
	ld	a,(hl)		;see if there are any parameters
	cp	'('		;parameter list starts with "(""
	jp	nz,finvls	;skip over parameter setup
	call	chrgtr		;go past the "("
	ld	(temp3),hl	;save the text pointer to the start of the
	ex	de,hl		;parameter list.
	ld	hl,(temp2)	;now get the text-pointer from the call
				;which is pointing just past the
				;function name at the argument list
	call	synchr
	defb	'('		;make sure the argument list is there
	xor	a		;indicate end of values to assign
	push	af
	push	hl		;save the callers text pointer
	ex	de,hl		;get the pointer to the beginning of the
				;parameter list
asgmor:	ld	a,128		;outlaw arrays when scanning
	ld	(subflg),a	;parameters
	call	ptrget		;read a parameter
	ex	de,hl		;[d,e]=parameter list text,[h,l]=variable pointer
	ex	(sp),hl		;save the variables position and
				;get the pointer at the arg list
	ld	a,(valtyp)	;and its type (for coercion)
	push	af
	push	de		;save the text pointer into the parameter
	call	frmevl		;evaluate the argument
	ld	(temp2),hl	;save the argument list pointer
	pop	hl		;and the parameter list pointer
	ld	(temp3),hl
	pop	af		;get the value type
	call	docnvf		;coerce the argument
	ld	c,4		;make sure there is room for the value
	call	getstk
	ld	hl,0-8		;save eight places
	add	hl,sp
	ld	sp,hl
	call	vmovmf		;put value into reserved place in stack
	ld	a,(valtyp)	;save type for assignment
	push	af
	ld	hl,(temp2)	;reget the argument list pointer
	ld	a,(hl)		;see what comes after the argument formula
	cp	')'		;is the argument list ending?
	jp	z,popasg	;make sure the argument list also ended
	call	synchr
	defb	','		;skip over argument comma
	push	hl		;save the argument list text pointer
	ld	hl,(temp3)	;get the text pointer into the defintion'S
				;parameter list
	call	synchr
	defb	','		;skip over the parameter list comma
	jp	asgmor		;and bind the rest of the parameters
popas2:	pop	af		;if assignment is sucessful update prmln2
	ld	(prmln2),a	;indicate new variable is in place
popasg:	pop	af		;get the value type
	or	a
	jp	z,finasg	;zero means no more left to pop and assign
	ld	(valtyp),a
	ld	hl,0		;point into stack
	add	hl,sp		;to get saved value
	call	vmovfm		;put value into fac
	ld	hl,0+8		;free up stack area
	add	hl,sp
	ld	sp,hl
	pop	de		;get place to store to
	ld	l,3		;calculate the size of the looks (name)
lpsizl:	inc	l		;increment size
	dec	de		;point at previous character
	ld	a,(de)		;see if it is the length or another character
	or	a
	jp	m,lpsizl	;high bit indicates still part of name
	dec	de		;back up over looks
	dec	de
	dec	de
	ld	a,(valtyp)	;get size of value
	add	a,l		;add on size of name
	ld	b,a		;save total length in [b]
	ld	a,(prmln2)	;get current size of block
	ld	c,a		;save in [c]
	add	a,b		;get potential new size
	cp	prmsiz		;can'T EXCEED ALLOCATED STORAGE
	jp	nc,fcerr
	push	af		;save new size
	ld	a,l		;[a]=size of name
	ld	b,0		;[b,c]=size of parm2
	ld	hl,parm2	;base of place to store into
	add	hl,bc		;[h,l]=place to start the new variable
	ld	c,a		;[b,c]=length of name of variable
	call	bctran		;put in the new name
	ld	bc,popas2	;place to return after assignment
	push	bc
	push	bc		;save extra entry on stack
	jp	letcn4		;perform assignment on [h,l] (extra pop d)
finasg:	ld	hl,(temp2)	;get argument list pointer
	call	chrgtr		;skip over the closing parenthesis
	push	hl		;save the argument text pointer
	ld	hl,(temp3)	;get the parameter list text pointer
	call	synchr
	defb	')'		;make sure the parameter list
				;ended at the same time
	defb	76q		;skip the next byte with "MVI AL,"
finvls:	push	de		;here when there were no arguments
				;or parameters
				;save the text pointer of the caller
	ld	(temp3),hl	;save the text pointer of the function
	ld	a,(prmlen)	;push parm1 stuff onto the stack
	add	a,4		;with prmlen and prmstk (4 bytes extra)
	push	af		;save the number of bytes
	rrca			;number of two byte entries in [a]
	ld	c,a
	call	getstk		;is there room on the stack?
	pop	af		;[a]=amount to put onto stack
	ld	c,a
	cpl			;complement [a]
	inc	a
	ld	l,a
	ld	h,255
	add	hl,sp
	ld	sp,hl		;set up new stack
	push	hl		;save the new value for prmstk
	ld	de,prmstk	;fetch data from here
	call	bctran
	pop	hl
	ld	(prmstk),hl	;link parameter block for garbage collection
	ld	hl,(prmln2)	;now put parm2 into parm1
	ld	(prmlen),hl	;set up length
	ld	b,h
	ld	c,l		;[b,c]=transfer count
	ld	hl,parm1
	ld	de,parm2
	call	bctran
	ld	h,a		;clear out parm2
	ld	l,a
	ld	(prmln2),hl
	ld	hl,(funact)	;increment function count
	inc	hl
	ld	(funact),hl
	ld	a,h
	or	l		;set up active flag non-zero
	ld	(nofuns),a
	ld	hl,(temp3)	;get back the function definition text pointer
;	dcx	h		;detect a multi-line function
;	chrget			;if the definition ends now
;	jz	mulfun		;if ends, its a multi-line function
				;skip over the "=" in the definition
	call	frmeql		;and evaluate the definition formula
				;can have recursion at this point
	dec	hl
	call	chrgtr		;see if the statement ended right
	jp	nz,snerr	;this is a cheat, since the line
				;number of the error will be the callers
				;line # instead of the definitions line #
	call	getypr		;see it the result is a string
	jp	nz,nocprs	;whose descriptor is about to be wiped out
				;because it is sitting in parm1 (this
				; happens it the function is a projection
				; function on a string argument)
	ld	de,dsctmp	;dsctmp is past all the temp area
	ld	hl,(faclo)	;get the address of the descriptor
	call	dcompr
	jp	c,nocprs	;result is a temp - no copy nesc
	call	strcpy		;make a copy in dsctmp
	call	puttmp		;put result in a temp and make faclo point at it
nocprs:	ld	hl,(prmstk)	;get place to restore parm1 from stack
	ld	d,h
	ld	e,l
	inc	hl		;point at length
	inc	hl
	ld	c,(hl)		;[b,c]=length
	inc	hl
	ld	b,(hl)
	inc	bc		;include extra bytes
	inc	bc
	inc	bc
	inc	bc
	ld	hl,prmstk	;place to store into
	call	bctran
	ex	de,hl		;[d,e]=place to restore stack to
	ld	sp,hl
	ld	hl,(funact)	;decrease active function count
	dec	hl
	ld	(funact),hl
	ld	a,h
	or	l		;set up function flag
	ld	(nofuns),a
	pop	hl		;get back the callers text pointer
	pop	af		;get back the type of the function
docnvf:	push	hl		;save the text pointer
	and	7		;setup dispatch to force
				;formula type to conform
				;to the variable its being assigned to
	ld	hl,frctbl	;table of force routines
	ld	c,a		;[b,c]=two byte offset
	ld	b,0
	add	hl,bc
	call	dispat		;dispatch
	pop	hl		;get back the text pointer
	ret
;
; block transfer routine with source in [d,e] destination in [h,l]
; and count in [b,c]. transfer is forward.
;
bctral:	ld	a,(de)
	ld	(hl),a
	inc	hl
	inc	de
	dec	bc
bctran:	ld	a,b
	or	c
	jp	nz,bctral
	ret
;
; subroutine to see if we are in direct mode and
; complain if so
;
errdir:	push	hl		;save their [h,l]
	ld	hl,(curlin)	;see what the current line is
	inc	hl		;direct is 65,535 so now 0
	ld	a,h
	or	l		;is it zero now?
	pop	hl
	ret	nz		;return if not
	ld	e,errid		;"ILLEGAL DIRECT" error
	jp	error
;
; subroutine to get a pointer to a function name
;
getfnm:	call	synchr
	defb	fntk		;must start with "FN"
	ld	a,128		;dont allow an array
	ld	(subflg),a	;don'T RECOGNIZE THE "(" AS
				;the start of an array refereence
	or	(hl)		;put function bit on
	ld	c,a		;get first character into [c]

	jp	ptrgt2

	;page
	;subttl	string functions - left hand side mid$

ismid$:	cp	377o-$end	;lhs mid$?
	jp	nz,snerr	;no, error.
	inc	hl		;point to next char
	ld	a,(hl)		;get fn descriptor
	cp	midtk		;is it mid?
	jp	nz,snerr	;no, error
	inc	hl		;bump pointer
	extrn	lhsmid		;code is in bistrs.mac
	jp	lhsmid

	;page
	;subttl	inp, out, wait, console, width
;
; the following functions allow the
; user full access to the altair i/o ports
; inp(channel#) returns an integer which is the status
; of the channel. out channel#,value puts out the integer
; value on channel #. it is a statement, not a function.
;
fninp:	call	conint		;get integer channel #
	ld	(inpwrd+1),a	;gen inp instr
inpwrd:	in	a,(0)		;the inp instr
	jp	sngflt		;sngflt result

fnout:	call	setio		;get ready
				;do the "OUT" and return
	public	outwrd
outwrd:	out	(0),a		;do it
	ret
;
; the wait channel#,mask,mask2 waits until the status
; returned by channel# is non zero when xored with mask2
; and then anded with mask. if mask2 is not present it is assumed
; to be zero.
;
fnwait:	call	setio		;set up for wait
	push	af		;save the mask
	ld	e,0		;default mask2 to zero
	dec	hl
	call	chrgtr		;see if the statement ended
	jp	z,notthr	;if no third argument skip this
	call	synchr
	defb	44		;make sure there is a ","
	call	getbyt
notthr:	pop	bc		;reget the "AND" mask
lopinp:
stainp:	in	a,(0)		;the input instr
	xor	e		;xor with mask2
	and	b		;and with mask
	jp	z,lopinp	;loop until result is non-zero
				;note: this loop cannot be control-c'ED
				;unless the wait is being done on channel
				;zero. however a restart at 0 is ok.
	ret
consol:	jp	snerr
; this is the width (terminal width) command command
; arg must be .gt. 15 and .lt. 255

width:
	cp	$lprin		;width lprint?
	jp	nz,notwlp	;no
	call	chrgtr		;fetch next char
	call	getbyt		;get width
	ld	(lptsiz),a	;save it
	call	morcp3		;compute last comma column
	ld	(nlppos),a	;save it
	ret
notwlp:
	call	getbyt		;get the channel #
	ld	(linlen),a	;setup the line length
morcp2:
	call	morcp3
	ld	(clmlst),a	;set last comma posit
	ret			;done
morcp3:	sub	clmwid
	jp	nc,morcp3
	add	a,2*clmwid
	cpl
	inc	a
	add	a,e
	ret			;back to newstt
	public	getin2,getint
getint:	call	chrgtr
getin2:	call	frmevl		;evaluate a formula
intfr2:	push	hl		;save the text pointer
	call	frcint		;convert the formula to an integer in [h,l]
	ex	de,hl		;put the integer into [d,e]
	pop	hl		;retsore the text pointer
	ld	a,d		;set the condition codes on the high order
	or	a
	ret
setio:	call	getbyt		;get integer channel number in [a]
	ld	(stainp+1),a	;setup "WAIT"
	ld	(outwrd+1),a	;setup "OUT"
	call	synchr
	defb	44		;make sure there is a comma
	jp	getbyt
				;"MVI B," around the chrget (mvi ah,)
gtbytc:	call	chrgtr
	public	getbyt,conint
getbyt:	call	frmevl		;evaluate a formula
conint:	call	intfr2		;convert the fac to an integer in [d,e]
				;and set the condition codes based
				;on the high order
	jp	nz,fcerr	;wasn'T ERROR
	dec	hl		;actually functions can get here
				;with bad [h,l] but not serious
				;set condition codes on terminator
	call	chrgtr
	ld	a,e		;return the result in [a] and [e]
	ret

	;page
	;subttl	execute basic program on prom
	;go run it

	;page
	;subttl	extended rlist, delete, llist
llist:

	;prtflg=1 for regular list
	ld	a,1		;get non zero value
	ld	(prtflg),a	;save in i/o flag (end of lpt)
rlist:
	pop	bc		;get rid of newstt return addr
	call	scnlin		;scan line range
	push	bc		;save pointer to 1st line
	call	prochk		;dont even list line #
list4:	ld	hl,0+65535	;dont allow ^c to change
	ld	(curlin),hl	;continue parameters
	pop	hl		;get pointer to line
	pop	de		;get max line # off stack
	ld	c,(hl)		;[b,c]=the link pointing to the next line
	inc	hl
	ld	b,(hl)
	inc	hl
	ld	a,b		;see if end of chain
	or	c
	jp	z,ready		;last line, stop.
	push	hl		;don'T ALLOW ^C
	ld	hl,(ptrfil)
	ld	a,h		;on file output
	or	l
	pop	hl
	call	z,iscntc
				;check for control-c
	push	bc		;save link
	ld	c,(hl)		;push the line #
	inc	hl
	ld	b,(hl)
	inc	hl
	push	bc
	ex	(sp),hl		;get line # into [h,l]
	ex	de,hl		;get max line in [h,l]
	call	dcompr		;past last line in range?
	pop	bc		;text pointer to [b,c]
	jp	c,stprdy	;if past, then done listing.
	ex	(sp),hl		;save max on bottom of stack
	push	hl		;save link on top
	push	bc		;save text pointer back
	ex	de,hl		;get line # in [h,l]
	ld	(dot),hl	;save for later edit or list
				;and we want [h,l] on the stack
	call	linprt		;print as int without leading space
	pop	hl
	ld	a,(hl)		;get byte from line
	cp	9		;is it a tab?
	jp	z,nospal	;then dont print space
	ld	a,' '
	call	outdo		;print a space after the line #
nospal:	call	buflin		;unpack the line into buf
	ld	hl,buf		;point at the start of the unpacked characters
	call	lisprt		;print the line
	call	crdo		;print crlf
	jp	list4		;go back for next line
lisprt:	ld	a,(hl)
	or	a		;set cc
	ret	z		;if =0 then end of line
	extrn	outch1
	call	outch1		;output char and check for lf
	inc	hl		;incr pointer
	jp	lisprt		;print next char

buflin:	ld	bc,buf		;get start of text buffer
	ld	d,buflen	;get its length into [d]
	xor	a		;set on special char for space insertion
	ld	(tempa),a
	call	prochk		;only proceed if ok
	jp	ploop2		;start here

ploop:	inc	bc		;increment deposit ptr.
	inc	hl		;advance text ptr
	dec	d		;bump down count
	ret	z		;if buffer full, return
ploop2:	ld	a,(hl)		;get char from buf
	or	a		;set cc'S
	ld	(bc),a		;save this char
	ret	z		;if end of source buffer, all done.
	cp	octcon		;is it smaller than smallest embedded constant?
	jp	c,ntembl	;yes, dont treat as one
	cp	dblcon+1	;is it embeded constant?
	ld	e,a		;save char in [e]
	jp	c,prtvar	;print leading space if nesc.
ntembl:	or	a		;set cc'S
	jp	m,ploopr	;reserved word of some kind
	ld	e,a		;save char in [e]
	cp	'.'		;dot is part of var name
	jp	z,prtvar
	call	tstanm		;is char alphanumeric
	jp	nc,prtvar	;alphanumeric
	xor	a		;make special
	jp	plooph
prtvar:	ld	a,(tempa)	;what did we do last?
	or	a		;set condition codes
	jp	z,ploopg	;special, never insert space
	inc	a		;in reserved word?
	jp	nz,ploopg	;no
	ld	a,' '		;put out space before resword
	ld	(bc),a		;store in buffer
	inc	bc		;incrment pointer into buffer
	dec	d		;space left?
	ret	z		;no, done
ploopg:	ld	a,1		;store flag saying in var
plooph:	ld	(tempa),a
	ld	a,e		;get back char we had
	cp	octcon		;is it smaller than smallest embedded constant?
	jp	c,ploopz	;yes, dont treat as one
	cp	dblcon+1	;is it embeded constant?
	jp	c,numlin	;yes, unpack it
ploopz:	ld	(bc),a		;make sure byte stored after space
	jp	ploop		;store in buffer
ploopr:

	inc	a		;set zero if fn token
	ld	a,(hl)		;get char back
	jp	nz,ntfntk	;not function just treat normally
	inc	hl		;bump pointer
	ld	a,(hl)		;get char
	and	177o		;turn off high bit
ntfntk:	inc	hl		;advance to point after
	cp	sngqtk		;single quote token?
	jp	nz,ntqttk	;no, jump out
	dec	bc		;move deposit ptr back over :$rem
	dec	bc
	dec	bc
	dec	bc
	inc	d
	inc	d
	inc	d
	inc	d		;fix up char count
ntqttk:	cp	$else		;else?
	call	z,dcxbrt	;move deposit ptr back over leading colon.
	push	hl		;save text ptr.
	push	bc		;save deposit ptr.
	push	de		;save char count.
	ld	hl,reslst-1	;get ptr to start of reserved word list
	ld	b,a		;save this char in [b]
	ld	c,'A'-1		;init leading char value
ressr3:	inc	c		;bump leading char value.
ressr1:	inc	hl		;bump pointer into reslst
ressrc:	ld	d,h		;save ptr to start of this reswrd
	ld	e,l
ressr2:
	ld	a,(hl)		;get char from reslst
	or	a		;set cc'S
	jp	z,ressr3	;if end of this chars table, go back & bump c
	inc	hl		;bump source ptr
	jp	p,ressr2	;if not end of this reswrd, then keep looking
	ld	a,(hl)		;get ptr to reserved word value
	cp	b		;same as the one we search for?
	jp	nz,ressr1	;no, keep looking.
	ex	de,hl		;save found ptr in [h,l]
	cp	$usr		;usr function token?
	jp	z,noispa	;dont insert space
	cp	$fn		;is it function token?
noispa:
	ld	a,c		;get leading char
	pop	de		;restore line char count
	pop	bc		;restore deposit ptr
	ld	e,a		;save leading char
	jp	nz,ntfnex	;not "FN" expansion
	ld	a,(tempa)	;set cc'S ON TEMPA
	or	a
	ld	a,0		;clear reswrd flag - mark as special
	ld	(tempa),a	;set flag
	jp	morlnz		;do expansion
ntfnex:
	cp	'Z'+1		;was it a special char?
	jp	nz,ntspch	;non-special char
	xor	a		;set non-special
	ld	(tempa),a
	jp	morpur		;print it
ntspch:	ld	a,(tempa)	;what did we do last?
	or	a		;special?
	ld	a,255		;flag in reserved word
	ld	(tempa),a	;clear flag
morlnz:	jp	z,morln0	;get char and proceed
	ld	a,' '		;put space in buffer
	ld	(bc),a
	inc	bc
	dec	d		;any space left in buffer
	jp	z,ppswrt	;no, return
morln0:	ld	a,e
	jp	morln1		;continue
morpur:
	ld	a,(hl)		;get byte from reswrd
	inc	hl		;bump pointer
morlnp:	ld	e,a		;save char
morln1:	and	177o		;and off high order bit for disk & edit
	ld	(bc),a		;store this char
	inc	bc		;bump ptr
	dec	d		;bump down remaining char count
	jp	z,ppswrt	;if end of line, just return
	or	e		;set cc'S
	jp	p,morpur	;end of reswrd?
	cp	'('+128		;spc( or tab( ?
	jp	nz,ntspct	;no
	xor	a		;clear flag
	ld	(tempa),a	;to insert space afterwards
ntspct:
	pop	hl		;restore source ptr.
	jp	ploop2		;get next char from line

tstanm:	call	islet2		;letter?
	ret	nc		;yes
	cp	'0'		;digit?
	ret	c		;too small
	cp	'9'+1		;last digit
	ccf			;make carry right
	ret			;no carry=digit
numlin:	dec	hl		;move pointer back as chrget inx'S
	call	chrgtr		;scan the constant
	push	de		;save char count
	push	bc		;save deposit ptr
	push	af		;save constant type.
	call	confac		;move constant into fac
	pop	af		;restore constant type
	ld	bc,conlin	;put return addr on stack
	push	bc		;save it
	cp	octcon		;octal constant?
	jp	z,fouto		;print it
	cp	hexcon		;hex constant?
	jp	z,fouth		;print in hex
	ld	hl,(conlo)	;get line # value if one.
	jp	fout		;print remaining possibilities.
conlin:	pop	bc		;restore deposit ptr.
	pop	de		;restore char count
	ld	a,(consav)	;get saved constant token
	ld	e,'O'		;assume octal constant
	cp	octcon		;octal constant?
	jp	z,savbas	;yes, print it
	cp	hexcon		;hex constant?
	ld	e,'H'		;assume so.
	jp	nz,numsln	;not base constant
savbas:
	ld	a,'&'		;print leading base indicator
	ld	(bc),a		;save it
	inc	bc		;bump ptr
	dec	d		;bump down char count
	ret	z		;return if end of buffer
	ld	a,e		;get base char
	ld	(bc),a		;save it
	inc	bc		;bump ptr
	dec	d		;bump down base count
	ret	z		;end of buffer, done
				;[e] set up
numsln:
	ld	a,(contyp)	;get type of constant we are
	cp	4		;is it single or double prec?
	ld	e,0		;no, never print trailing type indicator
	jp	c,typset
	ld	e,'!'		;assume single prec.
	jp	z,typset	;is contyp=4, was single
	ld	e,'#'		;double prec indicator
typset:
	ld	a,(hl)		;get leading char
	cp	' '		;leading space
	call	z,inxhrt	;go by it
numsl2:	ld	a,(hl)		;get char from number buffer
	inc	hl		;bump pointer
	or	a		;set cc'S
	jp	z,numdn		;if zero, all done.
	ld	(bc),a		;save char in buf.
	inc	bc		;bump ptr
	dec	d		;see if end of buffer
	ret	z		;if end of buffer, return
	ld	a,(contyp)	;get type of constant to be printed
	cp	4		;test for single or double precision
	jp	c,numsl2	;no, was integer
	dec	bc		;pick up saved char
	ld	a,(bc)		;easier than pushing on stack
	inc	bc		;restore to point where it should
	jp	nz,dblscn	;if double, dont test for embeded "."
	cp	'.'		;test for fraction
	jp	z,zere		;if single & embeded ., then dont print !
dblscn:	cp	'D'		;double prec. exponent?
	jp	z,zere		;yes, mark no value type indicator nesc.
	cp	'E'		;single prec. exponent?
	jp	nz,numsl2	;no, proceed
zere:	ld	e,0		;mark no printing of type indicator
	jp	numsl2		;keep moving number chars into buf

numdn:
	ld	a,e		;get flag to indicate whether to insert
	or	a		;a "D" after double prec. #
	jp	z,nod		;no, dont insert it
	ld	(bc),a		;save in buffer
	inc	bc		;bump pointer
	dec	d		;decrment count of chars left in buffer
	ret	z		;=0, must truncate list of this line.
nod:
	ld	hl,(contxt)	;get back text pointer after constant
	jp	ploop2		;get next char
;
; the following code is for the delete range
; command. before the lines are deleted, 'OK'
; is typed.
;
delete:
	call	scnlin		;scan line range
	push	bc
	call	deptr		;change pointers back to numbers
	pop	bc
	pop	de		;pop max line off stack
	push	bc		;save pointer to start of deletion
				;for use by chead after fini
	push	bc		;save pointer to start of 1st line
	call	fndlin		;find the last line
	jp	nc,fcerrg	;must have a match on the upper bound
	ld	d,h		;[d,e] =  pointer at the start of the line
	ld	e,l		;beyond the last line in the range
	ex	(sp),hl		;save the pointer to the next line
	push	hl		;save the pointer to the start of
				;the first line in the range
	call	dcompr		;make sure the start comes before the end
fcerrg:	jp	nc,fcerr	;if not, "ILLEGAL FUNCTION CALL"
	ld	hl,reddy	;print "OK" prematurely
	call	strout
	pop	bc		;get pointer to first in [b,c]
	ld	hl,fini		;go back to fini when done
	ex	(sp),hl		;[h,l]=pointer to the next line
	public	del
; erase a line from memory
; [b,c]=start of line being deleted
; [d,e]=start of next line
del:
	ex	de,hl		;[d,e] now have the pointer to the line
				;beyond this one
	ld	hl,(vartab)	;compactifying to vartab
mloop:	ld	a,(de)
	ld	(bc),a		;shoving down to eliminate a line
	inc	bc
	inc	de
	call	dcompr
	jp	nz,mloop	;done compactifying?
	ld	h,b
	ld	l,c
	ld	(vartab),hl
	ret

	;page
	;subttl	peek and poke
;
; note: in the 8k peek only accepts positive numbers up to 32767
; poke will only take an address up to 32767 , no
; fudging allowed. the value is unsigned.
; in the extended version negative numbers can be
; used to refer to locations higher than 32767.
; the correspondence is given by subtracting 65536 from locations
; higher than 32767 or by specifying a positive number up to 65535.
;
peek:	call	frqint		;get an integer in [h,l]
	extrn	prodir
	call	prodir		;dont allow direct if protected file
	ld	a,(hl)		;get the value to return
	jp	sngflt		;and float it
poke:	call	frmevl		;read a formula
	push	hl		;save text ptr
	call	frqint		;force value into int in [h,l]
	ex	(sp),hl		;put value on stack & get txt ptr back
				;save value on stack
	call	prodir		;dont allow direct if protected file
	call	synchr
	defb	44		;check for a comma
	call	getbyt
	pop	de		;get the address back
	ld	(de),a		;store it away
	ret			;scanned everything
	public	frqint
frqint:	ld	bc,frcint	;return here
	push	bc		;save addr
	call	getypr		;set the cc'S ON VALTYPE
	ret	m		;return if already integer.
	ld	a,(fac)		;get exponent
	cp	220o		;is magnitude .gt. 32767
	ret	nz		;no, force integer
	ld	a,(fac-1)	;get sign of number
	or	a		;is it negative, only allowable # is -32768
	ret	m		;assume thats what it is, else give overflow
	ld	bc,221q*256+200q
	ld	de,0*256+0	;get -65536.
	jp	fadd		;subtract it, and then force integer
				;make the same for radio shack version


	;page
	;subttl	renumber

; the reseq(uence) command take up to three arguments
; reseq [nn[,mm[,inc]]]
; where nn is the first destination line of the
; lines being resequenced, lines less than mm are
; not resequenced, and inc is the increment.
reseq:
	ld	bc,0+10		;assume inc=10
	push	bc		;save on stack
	ld	d,b		;reseq all lines by setting [d,e]=0
	ld	e,b
	jp	z,resnn		;if just 'RESEQ' reseq 10 by 10
	cp	','		;comma
	jp	z,eatcom	;dont use starting # of zero
	push	de		;save [d,e]
	call	linspc		;get new nn
	ld	b,d		;get in in [b,c] where it belongs
	ld	c,e
	pop	de		;get back [d,e]
	jp	z,resnn		;if eos, done
eatcom:	call	synchr
	defb	','		;expect comma
	call	linspc		;get new mm
	jp	z,resnn		;if eos, done
	pop	af		;get rid of old inc
	call	synchr
	defb	','		;expect comma
	push	de		;save mm
	call	linget		;get new inc
	jp	nz,snerr	;should have terminated.
	ld	a,d		;see if inc=0 (illegal)
	or	e
	jp	z,fcerr		;yes, blow him up now
	ex	de,hl		;flip new inc & [h,l]
	ex	(sp),hl		;new inc onto stack
	ex	de,hl		;get [h,l] back, orig [d,e] back
resnn:	push	bc		;save nn on stack
	call	fndlin		;find mm line
	pop	de		;get nn off stack
	push	de		;save nn back
	push	bc		;save pointer to mm line
	call	fndlin		;find first line to reseq.
	ld	h,b		;get ptr to this line in [h,l]
	ld	l,c
	pop	de		;get line ptd to by mm
	call	dcompr		;compare to first line reseqed
	ex	de,hl		;get ptr to mm line in [h,l]
	jp	c,fcerr		;cant allow program to be resequed
				;on top of itself
	pop	de		;get nn back
	pop	bc		;get inc in [b,c]
	pop	af		;get rid of newstt
	push	hl		;save ptr to first line to reseq.
	push	de		;save nn on stack
	jp	nxtrsl
nxtrsc:	add	hl,bc		;add increment into
	jp	c,fcerr		;uh oh, his inc was too large.
	ex	de,hl		;flip link field, accum.
	push	hl		;save link field
	ld	hl,0+65529	;test for too large line
	call	dcompr		;compare to current #
	pop	hl		;restore link field
	jp	c,fcerr		;uh oh, his inc was too large.
nxtrsl:	push	de		;save current line accum
	ld	e,(hl)		;get link field into [d,e]
	ld	a,e		;get low part into k[a] for zero test
	inc	hl
	ld	d,(hl)		;get high part of link
	or	d		;set cc'S ON LINK FIELD
	ex	de,hl		;see if next link zero
	pop	de		;get back accum line #
	jp	z,ressd1	;zero, done
	ld	a,(hl)		;get first byte of link
	inc	hl		;inc pointer
	or	(hl)		;set cc'S
	dec	hl		;move pointer back
	ex	de,hl		;back in [d,e]
	jp	nz,nxtrsc	;inc count

ressd1:	push	bc		;save inc
	call	scclin		;scan program converting lines to ptrs.
	pop	bc		;get back inc
	pop	de		;get nn
	pop	hl		;get ptr to first line to reseq

resnx1:	push	de		;save current line
	ld	e,(hl)		;get link field
	ld	a,e		;prepare for zero link field test
	inc	hl
	ld	d,(hl)
	or	d
	jp	z,sccall	;stop reseqing when see end of pgm
	ex	de,hl		;flip line ptr, link field
	ex	(sp),hl		;put link on stack, get new line # off
	ex	de,hl		;put new line # in [d,e], this line
				;ptr in [h,l]
	inc	hl		;point to line # field.
	ld	(hl),e		;change to new line #
	inc	hl
	ld	(hl),d
	ex	de,hl		;get this line # in [h,l]
	add	hl,bc		;add inc
	ex	de,hl		;get new line # back in [d,e]
	pop	hl		;get ptr to next line
	jp	resnx1		;keep reseqing
sccall:	ld	bc,stprdy	;where to go when done
	push	bc		;save on stack
	defb	376q		;"CPI AL," call sccptr
; the subroutines scclin and sccptr convert all
; line #'s to pointers and vice-versa.
; the only special case is "ON ERROR GOTO 0" where the "0"
; is left as a line number token so it wont be changed by resequence.
	public	sccptr
scclin:	defb	366q		;"ORI AX," over next byte
sccptr:	xor	a		;set a=0
	ld	(ptrflg),a	;set to say wheter lines or ptrs extant
scnpgm:	ld	hl,(txttab)	;get ptr to start of pgm
	dec	hl		;nop next inx.
scnpln:	inc	hl		;point to byte after zero at end of line
	ld	a,(hl)		;get link field into [d,e]
	inc	hl		;bump ptr
	or	(hl)		;set cc'S
	ret	z		;return if all done.
	inc	hl		;point past line #
	ld	e,(hl)		;get low byte of line #
	inc	hl
	ld	d,(hl)		;get high byte of line #
scnext:	call	chrgtr		;get next char from line
scnex2:	or	a		;end of line
	jp	z,scnpln	;scan next line
	ld	c,a		;save [a]
	ld	a,(ptrflg)	;change line tokens which way?
	or	a		;set cc'S
	ld	a,c		;get back current char
	jp	z,scnpt2	;changing pointers to #'S
	cp	$error		;is it error token?
	jp	nz,nterrg	;no.
	call	chrgtr		;scan next char
	cp	$goto		;error goto?
	jp	nz,scnex2	;get next one
	call	chrgtr		;get next char
	cp	lincon		;line # constant?
	jp	nz,scnex2	;no, ignore.
	push	de		;save [d,e]
	call	lingt3		;get it
	ld	a,d		;is it line # zero?
	or	e		;set cc'S
	jp	nz,chgptr	;change it to a pointer
	jp	scnex3		;yes, dont change it
nterrg:	cp	lincon		;line # constant?
	jp	nz,scnext	;not, keep scanning
	push	de		;save current line # for possible error msg
	call	lingt3		;get line # of line constant into [d,e]
chgptr:
	push	hl		;save text pointer just at end of lincon 3 bytes
	call	fndlin		;try to find line in pgm.
	dec	bc		;point to zero at end of previous line
	ld	a,ptrcon	;change line # to ptr
	jp	c,makptr	;if line found chane # to ptr
	call	crdonz		;print crlf if required
	ld	hl,linm		;print "UNDEFINED LINE" message
	push	de		;save line #
	call	strout		;print it
	pop	hl		;get line # in [h,l]
	call	linprt		;print it
	pop	bc		;get text ptr off stack
	pop	hl		;get current line #
	push	hl		;save back
	push	bc		;save back text ptr
	call	inprt		;print it
scnpop:	pop	hl		;pop off current text pointer
scnex3:	pop	de		;get back current line #
	dec	hl		;backup pointer
	jp	scnext		;keep scanning

linm:	defb	'Undefined line '
	defb	0

scnpt2:	cp	ptrcon	;pointer
	jp	nz,scnext	;no, keep scanning
	push	de		;save current line #
	call	lingt3		;get #
	push	hl		;save text pointer
	ex	de,hl		;flip current text ptr & ptr
	inc	hl		;bump pointer
	inc	hl		;point to line # field
	inc	hl
	ld	c,(hl)		;pick up line #
	inc	hl		;point to high part
	ld	b,(hl)
	ld	a,lincon	;change to line constant
makptr:	ld	hl,scnpop	;place to return to after changing constant
	push	hl		;save on stack
conchg:	ld	hl,(contxt)	;get txt ptr after constant in [h,l]
conch2:	push	hl		;save ptr to end of constant
	dec	hl
	ld	(hl),b
	dec	hl
	ld	(hl),c		;change to value in [b,c]
	dec	hl		;point to constant token
	ld	(hl),a		;change to value in [a]
	pop	hl		;restore pointer to after constant
	ret

	public	deptr
deptr:	ld	a,(ptrflg)	;do line pointers exist in pgm?
	or	a		;set cc'S
	ret	z		;no, just return
	jp	sccptr		;convert then to line #'S




	;subttl	ansi - the routines to handle ansi features
datas	defl	data
option:	call	synchr
	defb	'B'
	call	synchr
	defb	'A'
	call	synchr
	defb	'S'
	call	synchr
	defb	'E'
	ld	a,(optflg)
	or	a		;have we seen option base before
	jp	nz,dderr	;if so "DOUBLE DIMENSION ERROR"
	push	hl		;save the text pointer
	ld	hl,(arytab)	;see if we have any arrays yet
	ex	de,hl
	ld	hl,(strend)
	call	dcompr		;if these are equal we have not
	jp	nz,dderr
	pop	hl
	ld	a,(hl)		;get the base number
	sub	'0'
	jp	c,snerr
	cp	2		;only 0 and 1 are legal
	jp	nc,snerr
	ld	(optval),a	;save if for dim and ptrget
	inc	a		;make sure [a] is non zero
	ld	(optflg),a	;flag that we have seen "OPTION BASE"
	call	chrgtr		;fetch the terminator
	ret

; this routine is called by the math package
; to print error messages wtout disturbing ptrfil, etc.
strprn:
	ld	a,(hl)		;get byte from message
	or	a		;end of message
	ret	z		;yes, done
	call	caltty		;print char
	inc	hl		;increment pointer
	jp	strprn		;print next char
caltty:	push	af		;save [a] on stack
	jp	ttychr		;put out char
				;print crlf and return
random:	jp	z,inprg		;if no argument ask from terminal
	call	frmevl		;fetch the formula argument
	push	hl
	call	frcint		;allow normal integers
	jp	strnds		;store the new random seed
	extrn	rndmn2
inprg:	push	hl
inprag:
	ld	hl,ranmes	;ask for some random input
	call	strout
	call	qinlin
	pop	de		;get back text pointer
	jp	c,stpend	;go away if control c
	push	de		;resave text pointer
	inc	hl		;move past bufmin to buf
	ld	a,(hl)		;get first char of typein (fin expects it)
	call	fin		;read a number
	ld	a,(hl)		;get the terminator
	or	a
	jp	nz,inprag	;don'T ALLOW BAD FORMAT
	call	frcint		;allow normal integers
strnds:	ld	(rndx+1),hl
	call	rndmn2
	pop	hl		;get back the text pointer
	ret
ranmes:	defb	'Random number seed (-32768- to 32767)'
	defb	0

;
; this code scans ahead to find the "NEXT" that matches a "FOR"
; in order to 1) handle empty loops and 2) make sure loops
; match up properly.
;
	public	wndscn
wndscn:	ld	c,errwh		;scan for matching wend this is error if fail
	jp	scncnt
nxtscn:	ld	c,errfn
scncnt:
	ld	b,0		;set up the count of "FOR"s seen
	ex	de,hl		;initialize nxtlin for next on same line
	ld	hl,(curlin)
	ld	(nxtlin),hl
	ex	de,hl		;restore the text pointer to [h,l]
forinc:	inc	b		;increment the count whenever "FOR" is seen
fnlop:	dec	hl		;** fix here for 5.03 can'T CALL DATA
scanwf:	call	chrgtr		;to skip to statement because could
	jp	z,fortrm	;have statement after "THEN"
ntqtsc:
	cp	$else		;else statment
	jp	z,fnnwst	;then allow next or wend after it
	cp	$then		;so scan using chrget waiting for end
	jp	nz,scanwf	;of statement or $then
fortrm:	or	a		;see how it ended
	jp	nz,fnnwst	;just new statement -- examine it
				;or could be colon in string but no harm
				;in non kanabs (hghbit) version since no reserved
				;words will match the next character
	inc	hl
	ld	a,(hl)		;scan the link at the start of the next line
	inc	hl
	or	(hl)		;to see if its zero (end of program)
	ld	e,c		;set up error number
	jp	z,error
	inc	hl		;pick up the new line number
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl		;[h,l]= new line number
	ld	(nxtlin),hl	;save as "NEXT" line number
	ex	de,hl
fnnwst:	call	chrgtr		;get the type of the next statement
	ld	a,c		;get the error number to see what we are
	cp	errfn		;scanning for
	ld	a,(hl)		;get back the character
	jp	z,nxtlok	;for/next searching
	cp	$while		;another while/wend nest?
	jp	z,forinc
	cp	$wend
	jp	nz,fnlop
	dec	b
	jp	nz,fnlop
	ret
nxtlok:
	cp	$for		;another "FOR"?
	jp	z,forinc	;increment the for count
	cp	$next		;end with next?
	jp	nz,fnlop	;skip over this statement
decnxt:	dec	b		;decrement the loop count
	ret	z		;return with [h,l] about to get first character of "NEXT" variable

;
; scan  the variables listed in a "NEXT" statement
;
	call	chrgtr		;see if there is a name
	jp	z,fortrm	;only one so scan more statements
	ex	de,hl		;save text pointer in [d,e]
	ld	hl,(curlin)	;save the current line number
	push	hl
	ld	hl,(nxtlin)	;make error come from "NEXT"
	ld	(curlin),hl
	ex	de,hl		;[h,l]= text pointer
	push	bc		;save the "FOR" count
	call	ptrget		;skip over the variable name
	pop	bc		;get back the "FOR" count
	dec	hl		;check terminator
	call	chrgtr
	ld	de,fortrm	;place to go to
	jp	z,trmnxt	;end of "NEXT"
	call	synchr
	defb	44		;should have commas in between
	dec	hl		;rescan first character
	ld	de,decnxt	;place to go back to
trmnxt:	ex	(sp),hl		;save the text pointer on the stack
	ld	(curlin),hl
	pop	hl
	push	de		;go off to address in [b,c]
	ret
;
; this routine clears flgovc to reset to normal overflow mode.
; in normal mode, overr always prints overflow because flgovc=0
; function dispatch, fin (&findbl), and exponentiation set up an overflow
; mode where flgovc=1 and after one overflow flgovc=2 and no more
; overflow messages are printed. fin (&findbl) also store flgovc in ovcstr
; before resetting flgovc so a caller can detect overflow occurance.
;
	public	clrovc,finovc
finovc:	push	af
	ld	a,(flgovc)	;store overflow flag to indicate
	ld	(ovcstr),a	;whether an overflow occured
	pop	af
clrovc:	push	af		;save everything
	xor	a		;normal overflow mode
	ld	(flgovc),a
	pop	af
	ret


;	end	start
