
	.Z80
;	ASEG


	;SUBTTL	COMMON FILE FOR BASIC INTERPRETER
	;.SALL

conto	defl	15		;character to supress output (usually control-o)
dbltrn	defl	0		;for double precision transcendentals

	IF	0

	.PRINTX	/EXTENDED/


	.PRINTX	/LPT/

	.PRINTX	/CPM DISK/


	.PRINTX	/Z80/

	.PRINTX	/FAST/

	.PRINTX	/5.0 FEATURES/

	.PRINTX	/ANSI COMPATIBLE/
	ENDIF

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

	page
	TITLE	INIT INITAILIZATION FOR BASIC 8080/Z80 GATES/ALLEN/DAVIDOFF

swtchr	defl	'/'		;default switch character is slash
	extrn	cnsget
	extrn	chrgtr
	extrn	outdo,linprt,memsiz,crdo,txttab,omerr
	extrn	reason
	extrn	ready,stkini,curlin,repini
	extrn	dcompr
	extrn	synchr
	extrn	errflg
	extrn	const3,consts,const2,conin,conout,lptout

	extrn	maxfil
	extrn	lptpos
	extrn	qinlin,buf,snerr,fcerr,atn,atnfix,cosfix,tanfix,sinfix,cos
	page
; 	subttl	system initialization code

;this is the system initialization code
;it should be loaded at the end of the basic
;interpreter
	extrn	strout
	public	tstack
	public	initsa,init
initsa:
	extrn	nodsks
	call	nodsks
	ld	hl,(txttab)
	dec	hl
	ld	(hl),0
	extrn	lrun
	ld	hl,(cpmfil)	;point to start of command line
	ld	a,(hl)		;get byte pointed to
	or	a		;if zero, no file seen
	jp	nz,lrun		;try to run file
	jp	ready
endio:	defs	2
init:
	ld	hl,tstack	;set up temp stack
	ld	sp,hl
	xor	a		;initialize protect flag
	extrn	proflg
	ld	(proflg),a
	extrn	topmem,fretop
	ld	(topmem),hl
	extrn	savstk
	ld	(savstk),hl	;we restore stack when errors
	ld	hl,(cpmwrm+1)	;get start of bios vector table
	ld	bc,0+4		;csts
	add	hl,bc		;add four
	ld	e,(hl)		;pick up csts address
	inc	hl
	ld	d,(hl)
	ex	de,hl		;get csts address
	ld	(const3+1),hl	;third control-c check
	ld	(consts+1),hl	;save
	ld	(const2+1),hl	;fast control-c check
	ex	de,hl		;pointer back to [h,l]
	inc	hl		;point at ci address
	inc	hl
	ld	e,(hl)		;get low byte of ci address
	inc	hl
	ld	d,(hl)		;get high byte
	ex	de,hl		;input address to [h,l]
	ld	(conin+1),hl	;save in console input call
	ex	de,hl		;pointer back to [h,l]
	inc	hl		;skip "jmp" opcode
	inc	hl		;bump pointer
	ld	e,(hl)		;get output routine address
	inc	hl
	ld	d,(hl)
	ex	de,hl		;into [h,l]
	ld	(conout+1),hl	;save into output routine
	ex	de,hl		;pointer back to [h,l]
	inc	hl		;now point to printer output
	inc	hl		;routine address
	ld	e,(hl)		;pick it up
	inc	hl
	ld	d,(hl)
	ex	de,hl		;get address into [d,e]
	ld	(lptout+1),hl	;set print routine address

;	Check CP/M Version Number

	extrn	cpmvrn,cpmrea,cpmwri

	ld	c,12		;version test
	call	cpment
	ld	(cpmvrn),a	;[a] = version number (0 = 1.x)
	or	a		;test version number
	ld	hl,21*256+20+0	;1.x read / write
	jp	z,cpmvr1
	ld	hl,34*256+33+0	;2.x read / write
cpmvr1:	ld	(cpmrea),hl	;save read/write codes
	ld	hl,0+65534	;say initialization is executing
	ld	(curlin),hl	;in case of error message
	extrn	cntofl
	xor	a
	ld	(cntofl),a
	extrn	endbuf
	ld	(endbuf),a	;make sure overruns stop
	extrn	chnflg,mrgflg
	ld	(chnflg),a	;make sure chains and merges
	ld	(mrgflg),a	;dont try to happen
	ld	(errflg),a	;don't allow edit to be called on errors
	ld	hl,0		;get 0
	ld	(lptpos),hl	;zero flag and position
	extrn	maxrec
	ld	hl,0+128	;default max rec size
	ld	(maxrec),hl
	extrn	tempst,temppt
	ld	hl,tempst
	ld	(temppt),hl
	extrn	prmstk,prmprv
	ld	hl,prmstk	;initialize parameter block chain
	ld	(prmprv),hl
	ld	hl,(cpment+1)	;get last loc in memory
	ld	(memsiz),hl	;use as default
;
;
; the following code scans a cp/m command line for basic.
; the format of the command is:
;
; BASIC <FILE NAME>[/M:<TOPMEM>][/F:<FILES>]
;
;*
	ld	a,3		;default files
	ld	(maxfil),a	;by setting maxfil=3
	ld	hl,zerob	;point at zero byte
	ld	(cpmfil),hl	;so if re-initailize ok
	ld	a,(comagn)	;have we already read command line
	or	a		;and got error?
	jp	nz,errcmd	;then default
	inc	a		;make non-zero
	ld	(comagn),a	;store back non-zero for next time
tbuff	defl	cpmwrm+128	;where cp/m command buffer is located

	ld	hl,tbuff	;point to first char of command buffer
	ld	a,(hl)		;which contains # of chars in command
	or	a		;is there a command?
	ld	(cpmfil),hl	;save pointer to this zero
	jp	z,doncmd	;nothing in command buffer
	ld	b,(hl)		;and [b]
	inc	hl		;point to first char in buffer
tbflp:	ld	a,(hl)		;get char from buffer
	dec	hl		;back up pointer
	ld	(hl),a		;store char back
	inc	hl		;now advance char to one place
	inc	hl		;after previous posit.
	dec	b		;decrement count of chars to move
	jp	nz,tbflp	;keep moving chars
	dec	hl		;back up pointer
endcmd:	ld	(hl),0		;store terminator for chrget (0)
	ld	(cpmfil),hl	;save pointer to new zero (old destroyed)
	ld	hl,tbuff-1	;point to char before buffer
	call	chrgtr		;ignore leading spaces
	or	a
	jp	z,doncmd	;end of command
	cp	swtchr		;is it a slash
	jp	z,fndslh	;yes
	dec	hl		;back up pointer
	ld	(hl),34		;store double quote
	ld	(cpmfil),hl	;save pointer to start of file name
	inc	hl		;bump pointer
isslh:	cp	swtchr		;option?
	jp	z,fndslh	;yes
	call	chrgtr		;skip over char in file name
	or	a		;set cc's
	jp	nz,isslh	;keep looking for option
	jp	doncmd		;thats eit
fndslh:	ld	(hl),0		;store terminator over "/"
scansw:	call	chrgtr		;get char after slash
scans1:
	cp	'S'		;is it /s: ? (set max record size)
	JP	Z,WASS		;YES
	cp	'M'		;memory option
	push	af		;save indicator
	jp	z,wasm		;was memory option
	cp	'F'		;files option
	jp	nz,snerr	;not "m" or "f" error
wasm:	call	chrgtr		;get next char
	call	synchr
	defb	':'		;colon should follow
	call	cnsget		;get value following colon
	pop	af		;get back m/f flag
	jp	z,mem		;was memory option
	ld	a,d		;files cant be .gt. 255
	or	a		;set cc's
	jp	nz,fcerr	;function call error
	ld	a,e		;get low byte
	cp	16		;must be .lt. 16
	jp	nc,fcerr
	ld	(maxfil),a	;store in # of files
	jp	fok		;done
mem:	ex	de,hl		;put value in [d,e]
	ld	(memsiz),hl	;save into memsize
	ex	de,hl		;get back text pointer
fok:	dec	hl		;rescan last char
	call	chrgtr		;by calling chrget
	jp	z,doncmd	;end of command
	call	synchr
	defb	swtchr		;slash should follow
	jp	scans1		;scan next switch
wass:	call	chrgtr		;get char after "s"
	call	synchr
	defb	':'		;make sure colon follows
	call	cnsget		;get value following colon
	ex	de,hl		;save it
	ld	(maxrec),hl
	ex	de,hl
	jp	fok		;continue scanning
zerob:	defb	0		;zero byte
cpmfil:	defs	2		;pointer to basic load file
comagn:	defb	0		;we havent scanned command yet
errcmd:
doncmd:
askmem:
usedef:	dec	hl
	ld	hl,(memsiz)	;get size of memory
	push	hl		;also save for later
				;set up default string space
	pop	hl
	dec	hl		;always leave top byte unused because
				;val(string) makes byte in memory
				;beyond last char of string=0
	ld	(memsiz),hl	;save in real memory size
	dec	hl		;one lower is stktop
	push	hl		;save it on stack



	;keep all functions

;
; disk initialization routine
; setup  file info blocks
; the number of each and information for
; getting to pointers to each is stored. no locations are
; initialized, this is done by nodsks, first closing all files.
; the number of files is the file pointer table
;
	public	dskdat
dskdat	defl	endio		;start data after all code
asksk:
	ld	a,(maxfil)	;get highest file #
	ld	hl,dskdat	;get start of memory
	extrn	filpt1,filptr,maxfil,dblk.c
	ld	(filpt1),hl
	ld	de,filptr	;point to table to set up
	ld	(maxfil),a	;remember how many files
	inc	a		;always file 0 for internal use
	ld	bc,dblk.c	;size of a file info block plus $code
lopflb:	ex	de,hl		;[h,l] point into pointer block
	ld	(hl),e		;store the pointer at this file
	inc	hl
	ld	(hl),d
	inc	hl
	ex	de,hl
	add	hl,bc		;[h,l] point to next info block
	extrn	fnzblk
	push	hl		;save [h,l]
	ld	hl,(maxrec)	;get max record size
	ld	bc,fnzblk	;get size of other stuff
	add	hl,bc
	ld	b,h
	ld	c,l		;result to [b,c]
	pop	hl		;restore [h,l]
	dec	a		;are there more?
	jp	nz,lopflb
havfns:	;text always preceded by zero
	;store it
	inc	hl		;increment pointer
	ld	(txttab),hl	;save bottom of memory
	ld	(savstk),hl	;we restore stack when errors
	pop	de		;get  current memsiz
	ld	a,e		;calc total free/8
	sub	l
	ld	l,a
	ld	a,d
	sbc	a,h
	ld	h,a
	jp	c,omerr
	ld	b,3		;divide by 2 three times
shflf3:	or	a
	ld	a,h
	rra
	ld	h,a
	ld	a,l
	rra
	ld	l,a
	dec	b
	jp	nz,shflf3
	ld	a,h		;see how much
	cp	2		;if less than 512 use 1 eighth
	jp	c,smlstk
	ld	hl,0+512
smlstk:	ld	a,e		;subtract stack size from top mem
	sub	l
	ld	l,a
	ld	a,d
	sbc	a,h
	ld	h,a
	jp	c,omerr
	ld	(memsiz),hl
	ex	de,hl
	ld	(topmem),hl
	ld	(fretop),hl	;reason uses this...
	ld	sp,hl		;set up new stack
	ld	(savstk),hl
	ld	hl,(txttab)
	ex	de,hl
	call	reason
	ld	a,l		;subtract memsiz-txttab
	sub	e
	ld	l,a
	ld	a,h
	sbc	a,d
	ld	h,a
	dec	hl		;since two zeros exist between
	dec	hl		;txttab and strend, adjust
	push	hl		;save number of bytes to print
	ld	hl,heding	;get heading ("basic version...")
	call	strout		;print it
	pop	hl		;restore number of bytes to print
	call	linprt		;print # of bytes free
	ld	hl,words	;type the heading
	call	strout		;"bytes free"
	ld	hl,strout
	ld	(repini+1),hl
	call	crdo		;print carriage return
	extrn	readyr
	ld	hl,readyr
	extrn	jmpini
	ld	(jmpini+1),hl
	jp	initsa


auttxt:	defb	13
	defb	10
	defb	10
	defb	'Owned by Microsoft'
	defb	13
	defb	10
	defb	0


words:	defb	' Bytes Free'
	defb	0
heding:
	defb	26
	defb	'BASIC 5.2'
	defb	13
	defb	10



	defb	'MAGIC Operating System'
	defb	13
	defb	10
	defb	'    Copyright 1982 (C)'
	defb	13,10
	defb	32,32,32,32,32
	defb	0
lastwr:		:			;last word of system code+1
	defs	70+300*0+200*0+30*0	;space for temp stack
tstack:
	;make sure last word punched is ok
	end
