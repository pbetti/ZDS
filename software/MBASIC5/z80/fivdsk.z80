
	.z80
	;aseg

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
	page	
	title	fivdsk 5.0 features - variable length records, protected files /p. allen
	;.sall	

	extrn	dcompr
	extrn	chrgtr,synchr
;
;the 5.0 disk code is essentially an extra level of buffering
;for random disk i/o files. sequential i/o is not
;affected by the 5.0 code. great care has been taken to
;insure compatibility with existing code to support diverse
;operating systems. the 5.0 disk code has its
;own data structure for handling the variable length
;records in random files. this data structure sits right after
;the regular data block for the file and consumes an amount of 
;memory equal to  maxrec (the maximum allowed record size) plus
;9 bytes.
;
;here is the content of the data block:
;
;fd.siz size 2			;variable length record size default 128
;fd.phy size 2			;current physical record #
;fd.log size 2			;current logical record number
;fd.chg size 1			;future flag for accross block prints etc.
;fd.ops size 2			;output print position for print, input, write
;fd.dat size fd.zsiz		;actual field data buffer
;				;size is fd.siz bytes long
;
;date				fix
;----				---
;8/6/179				make put, get increment loc correctly
;8/14/1979			puuut in basic cococompiler switch (main source)
;%
	extrn	datofs,derbfm,derbrn,fcerr,maxtrk,fivdpt,locofs
	extrn	fd.siz,fd.phy,fd.log,fd.chg,fd.ops,fd.dat
	extrn	derfov,nmlofs
	extrn	filscn,proflg,curlin,sincon,atncon,gtmprt
	extrn	temp,txttab,vartab,snerr,maxrec
	page	
	;subttl	varecs - variable record scan for open
	public	varecs,tempb,filofv,filifv,cmpfbc

;	enter varecs with file mode in [a]

varecs:	cp	md.rnd		;random?
	ret	nz		;no, give error later if he gave record length
	dec	hl		;back up pointer
	call	chrgtr		;test for eol
	push	de		;save [d,e]
	ld	de,0+datpsc	;assume record length=datpsc
	jp	z,notsep	;no other params for open
	push	bc		;save file data block pointer
	extrn	intidx
	call	intidx		;get record length
	pop	bc		;get back file data block
notsep:	push	hl		;save text pointer
	ld	hl,(maxrec)	;is size ok?
	call	dcompr
	jp	c,fcerr		;no, give error
	ld	hl,0+fd.siz	;stuff into data block
	add	hl,bc
	ld	(hl),e
	inc	hl
	ld	(hl),d
	xor	a		;clear other bytes in data block
	ld	e,7		;# of bytes to clear
zofivb:	inc	hl		;increment pointer
	ld	(hl),a		;clear byte
	dec	e		;count down
	jp	nz,zofivb	;go back for more
	pop	hl		;text pointer 
	pop	de		;restore [d,e]
	ret	
	page	
	;subttl	put and get statements

	public	get,put
put:	defb	366o		;"ORI"to set non-zero flag
get:	xor	a		;set zero
	ld	(pgtflg),a	;save flag
	call	filscn		;get pointer at file data block
	cp	md.rnd		;must be a random file
	jp	nz,derbfm	;if not, "Bad file mode"
	push	bc		;save pointer at file data block
	push	hl		;save text pointer
	ld	hl,0+fd.log	;fetch current logical posit
	add	hl,bc
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	de		;compensate for "DCX D" when call intidx
	ex	(sp),hl		;save data block pointer and get text pointer
	ld	a,(hl)
	cp	44		;is there a record number
	call	z,intidx	;read it if there, 1-indexed
	dec	hl		;make sure statement ends
	call	chrgtr
	jp	nz,snerr
	ex	(sp),hl		;save text pointer, get data block pointer
	ld	a,e		;get record #
	or	d		;make sure its not zero
	jp	z,derbrn	;if so, "Bad record number"
	dec	hl
	ld	(hl),e
	inc	hl
	ld	(hl),d
	dec	de
	pop	hl		;get back text pointer 
	pop	bc
	push	hl		;save back text pointer 
	push	bc		;pointer to file data block
	ld	hl,0+fd.ops	;zero output file posit
	add	hl,bc
	xor	a
	ld	(hl),a
	inc	hl
	ld	(hl),a
	ld	hl,0+fd.siz	;get logical record size in [d,e]
	add	hl,bc
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ex	de,hl		;record size to [d,e], posit in [h,l]
	push	de		;save record size (count of bytes)
; record size in [d,e]
; logical position in [h,l]
; this code computes physical record # in [h,l]
; offset into buffer in [d,e]
	push	hl		;save logical posit
	ld	hl,0+datpsc	;get sector size
	call	dcompr		;compare the two
	pop	hl		;restore logical posit
	jp	nz,ntlsap	;if record size=sector size, done
	ld	de,0		;set offset to zero
	jp	donclc		;done with calculations
ntlsap:	ld	b,d		;copy record size to [b,c]
	ld	c,e
	ld	a,20o		;16 by 16 multiply
	ex	de,hl		;put multiplier in [d,e]
	ld	hl,0		;set both parts of product to zero
	push	hl		;2nd part is on stack
frmul1:	add	hl,hl
	ex	(sp),hl
	jp	nc,fnocry
	add	hl,hl
	inc	hl
	jp	fnocy0
fnocry:	add	hl,hl
fnocy0:	ex	(sp),hl
	ex	de,hl
	add	hl,hl		;rotate [d,e] left one
	ex	de,hl
	jp	nc,fnocy2	;add in [b,c] if ho=1
	add	hl,bc
	ex	(sp),hl
	jp	nc,fnoinh
	inc	hl
fnoinh:	ex	(sp),hl
fnocy2:	dec	a		;are we done multiplying
	jp	nz,frmul1	;no, go back for next bit of product
; now divide by the number of bytes in a sector
	if	datpsc-256
	ld	e,l		;remainder is just low byte
	ld	d,0		;of which ho is 0
	ld	l,h		;annd record # is shifted down
	pop	bc		;get most sig. byte of record #
	ld	h,c		;set record # to it
	ld	a,b		;make sure rest=0
	or	a
	jp	nz,fcerr
	endif			;uh-oh
	if	datpsc-128
	if	datpsc-256
	pop	de		;get high word of dividend in [d,e]
	ld	bc,0		;set dividend to zero.
kepsub:	push	bc		;save dividend
	ld	bc,0-datpsc	;get divisor (# of bytes sector)
	add	hl,bc		;subtract it
	jp	c,guarcy	;carry from low bytes implies cary from high
	ex	de,hl		;subtract -1 from high byte
	ld	bc,0-1
	add	hl,bc
	ex	de,hl		;put result back where it belongs
guarcy:	pop	bc		;restore dividend
	jp	nc,dondiv	;finished
	inc	bc		;add one to it
	ld	a,b		;see if overflowed
	or	c
	jp	nz,kepsub	;keep at it till done
	jp	fcerr		;yes give error
dondiv:	push	bc		;save dividend
	ld	bc,0+datpsc	;correct for one too many subtraction
	add	hl,bc		;by adding divisor back in
	pop	de		;dividend ends up in [d,e], remainder in [h,l]
	ex	de,hl
	endif	
	endif			;put values in right regs for rest of code
	if	datpsc-128
	ld	a,l		;get low byte of result
	and	127		;get rid of high bit
	ld	e,a		;this is it
	ld	d,0		;set high byte of remainder to zero
	pop	bc		;get high word of product
	ld	a,l		;get msb of low word
	ld	l,h
	ld	h,c
	add	hl,hl		;make space for it
	jp	c,fcerr		;uh-oh record # to big!
	rla			;is it set?
	jp	nc,doninh	;not set
	inc	hl		;copy it into low bit
doninh:	ld	a,b		;get high byte of record #
	or	a		; is it non-zero
	jp	nz,fcerr
	endif			;bad
donclc:
; at this point, record #is in [h,l]
; offset into record in [d,e]
; stack:
; count of bytes to read or write
; data block
; text pointer
; return address
	ld	(record),hl	;save record size
	pop	hl		;get count
	pop	bc		;pointer to file data block
	push	hl		;save back count
	ld	hl,0+fd.dat	;point to field buffer
	add	hl,bc		;add start of data block
	ld	(lbuff),hl	;save pointer to field buffer
nxtopd:	ld	hl,0+datofs	;point to physical buffer
	add	hl,bc		;add file block offset
	add	hl,de
	ld	(pbuff),hl	;save
	pop	hl		;get count
	push	hl		;save count
	ld	hl,0+datpsc	;[h,l]=datpsc-offset
	ld	a,l
	sub	e
	ld	l,a
	ld	a,h
	sbc	a,d
	ld	h,a
	pop	de		;get back count (destroy offset)
	push	de		;save count
	call	dcompr		;which is smaller, count or datpsc-offset?
	jp	c,datmof	;the latter
	ld	h,d		;copy count into bytes
	ld	l,e
datmof:	ld	a,(pgtflg)	;put or get
	or	a		;set cc's
	jp	z,fivdrd	;was read
	ld	de,0+datpsc	;if bytes .lt. datpsc then read(sector)
	call	dcompr
	jp	nc,nofvrd	;(idea-if writing full buffer, no need to read)
	push	hl		;save bytes
	call	getsub		;read record.
	pop	hl		;bytes
nofvrd:	push	bc
	ld	b,h
	ld	c,l
	ld	hl,(pbuff)
	ex	de,hl
	ld	hl,(lbuff)	;get ready to move bytes between buffers
	call	fdmov		;move bytes to physical buffer
	ld	(lbuff),hl	;store updated pointer
	ld	d,b		;count to [d,e]
	ld	e,c
	pop	bc		;restore fdb pointer
	call	putsub		;do write
nxfvbf:	pop	hl		;count
	ld	a,l		;make count correct
	sub	e
	ld	l,a
	ld	a,h
	sbc	a,d
	ld	h,a
	or	l		;is count zero?
	ld	de,0		;set offset=0
	push	hl		;save count
	ld	hl,(record)
	inc	hl		;increment it
	ld	(record),hl	;save back
	jp	nz,nxtopd	;keep working on it
	pop	hl		;get rid of count
	pop	hl		;restore text pointer
	ret			;done

; read code
; [h,l]=bytes
; [d,e]=count
fivdrd:	push	hl		;save bytes
	call	getsub		;do read
	pop	hl		;get back bytes
	push	bc
	ld	b,h
	ld	c,l
	ld	hl,(lbuff)	;point to logical buffer
	ex	de,hl
	ld	hl,(pbuff)
	call	fdmov
	ex	de,hl		;get pointer to field buffer in [h,l]
	ld	(lbuff),hl	;save back updated logical buffer
	ld	d,b		;count to [d,e]
	ld	e,c
	pop	bc
	jp	nxfvbf
putsub:	defb	366q
getsub:	xor	a
	ld	(maxtrk),a	;get/put fflag
	push	bc
	push	de
	push	hl
	ld	hl,(record)
	ex	de,hl
	ld	hl,0+fd.phy	;point to physical record #
	add	hl,bc		;add offset to file buffer
	push	hl		;save this pointer
	ld	a,(hl)		;get current phys. rec #
	inc	hl
	ld	h,(hl)
	ld	l,a
	inc	de
	call	dcompr		;do we already have record in buffer
	pop	hl		;restore pointer
	ld	(hl),e
	inc	hl
	ld	(hl),d		;store new record number
	jp	nz,ntreds	;curent and previos record numbers are different
	ld	a,(maxtrk)	;trying to do read?
	or	a
	jp	z,subret	;if trying to read and record already
	;in buffer, do nothing
ntreds:	ld	hl,subret	;where to return to
	push	hl
	push	bc		;file data block
	push	hl		;dummy text pointer
	ld	hl,0+locofs+1	;where [h,l] is expected to be
	add	hl,bc
	jp	fivdpt		;call old put/get
subret:	pop	hl
	pop	de
	pop	bc
	ret			;restore all regs and return to caller

; move bytes from [h,l] to [d,e] [b,c] times
fdmov:	push	bc		;save count
fdmov1:	ld	a,(hl)		;get byte
	ld	(de),a		;store it
	inc	hl
	inc	de
	dec	bc		;decrement count
	ld	a,b		;gone to zero?
	or	c
	jp	nz,fdmov1	;go back for more
	pop	bc		;return with count in [d,e]
	ret	

filofv:	pop	af		;get character off stack
	push	de		;save [d,e]
	push	bc		;save [b,c]
	push	af		;save back char
	ld	b,h		;[b,c]=file data block
	ld	c,l
	call	cmpfps		;any room in buffer
	jp	z,derfov	;no
	call	setfpi		;save new position
	ld	hl,0+fd.dat-1	;index into data buffer
	add	hl,bc		;add start of file control block
	add	hl,de		;add offset into buffer
	pop	af		;get back char
	ld	(hl),a		;store in buffer
	push	af		;save char
	ld	hl,0+nmlofs	;set up [h,l] to point at print posit
	add	hl,bc
	ld	d,(hl)		;get present position
	ld	(hl),0		;assume set it to zero
	cp	13		;is it <cr>?
	jp	z,fiscr		;yes
	add	a,224		;set carry for spaces & higher
	ld	a,d		;add one to current posit
	adc	a,0
	ld	(hl),a
fiscr:	pop	af		;restore all regs
	pop	bc
	pop	de
	pop	hl
	ret	

filifv:	push	de		;save [d,e]
	call	cmpfbc		;compare to present posit
	jp	z,derfov	;return with null 
	call	setfpi		;set new position
	ld	hl,0+fd.dat-1	;point to data
	add	hl,bc
	add	hl,de
	ld	a,(hl)		;get the byte
	or	a		;clear carry (no eof)
	pop	de		;restore [d,e]
	pop	hl		;restore [h,l]
	pop	bc		;restore [b,c]
	ret	

getfsz:	ld	hl,0+fd.siz	;point to record size
	jp	getfp1		;continue
getfps:	ld	hl,0+fd.ops	;point to output position
getfp1:	add	hl,bc		;add offset into buffer
	ld	e,(hl)		;get value
	inc	hl
	ld	d,(hl)
	ret	

setfpi:	inc	de		;increment current posit
setfps:	ld	hl,0+fd.ops	;point to output position
	add	hl,bc		;add file control block address
	ld	(hl),e
	inc	hl
	ld	(hl),d
	ret	
cmpfbc:	ld	b,h		;copy file data block into [b,c]
	ld	c,l
cmpfps:	call	getfps		;get present posit
	push	de		;save it
	call	getfsz		;get file size
	ex	de,hl		;into [h,l]
	pop	de		;get back posit
	call	dcompr		;see if were at end
	ret	

	page	
	;subttl	protected files

	public	prolod
	extrn	binpsv
	public	prosav
prosav:	call	chrgtr		;get char after "S"
	ld	(temp),hl	;save text pointer
	extrn	sccptr
	call	sccptr		;get rid of goto pointers
	call	pencod		;encode binary
	ld	a,254		;put out 254 at start of file
	call	binpsv		;do save
	call	pdecod		;re-decode binary
	jp	gtmprt		;back to newstt

n1	defl	11		;number of bytes to use from atncon
n2	defl	13		;number of bytes to use from sincon
	public	pencod
pencod:	ld	bc,0+n1+n2*256	;initialize both counters
	ld	hl,(txttab)	;starting point
	ex	de,hl		;into [d,e]
encdbl:	ld	hl,(vartab)	;at end?
	call	dcompr		;test
	ret	z		;yes
	ld	hl,atncon	;point to first scramble table
	ld	a,l		;use [c] to index into it
	add	a,c
	ld	l,a
	ld	a,h
	adc	a,0
	ld	h,a
	ld	a,(de)		;get byte from program
	sub	b		;subtract counter for no reason
	xor	(hl)		;xor entry
	push	af		;save result
	ld	hl,sincon	;calculate offset into sincon using [b]
	ld	a,l
	add	a,b
	ld	l,a
	ld	a,h
	adc	a,0
	ld	h,a
	pop	af		;get back current byte
	xor	(hl)		;xor on this one too
	add	a,c		;add counter for randomness
	ld	(de),a		;store back in program
	inc	de		;incrment pointer
	dec	c		;decrment first table index
	jp	nz,cntzer	;still non-zero
	ld	c,n1		;re-initialize counter 1
cntzer:	dec	b		;dedecrement counter-2
	jp	nz,encdbl	;still non-zero, go for more
	ld	b,n2		;re-initialize counter 2
	jp	encdbl		;keep going until done
prolod:
pdecod:	ld	bc,0+n1+n2*256	;initialize both counters
	ld	hl,(txttab)	;starting point
	ex	de,hl		;into [d,e]
decdbl:	ld	hl,(vartab)	;at end?
	call	dcompr		;test
	ret	z		;yes
	ld	hl,sincon	;calculate offset into sincon using [b]
	ld	a,l
	add	a,b
	ld	l,a
	ld	a,h
	adc	a,0
	ld	h,a
	ld	a,(de)		;get byte from program
	sub	c		;subtract counter for randomness
	xor	(hl)		;xor on this one too
	push	af		;save result
	ld	hl,atncon	;point to first scramble table
	ld	a,l		;use [c] to index into it
	add	a,c
	ld	l,a
	ld	a,h
	adc	a,0
	ld	h,a
	pop	af		;get back current byte
	xor	(hl)		;xor entry
	add	a,b		;add counter for no reason
	ld	(de),a		;store back in program
	inc	de		;increment pointer
	dec	c		;decrment first table index
	jp	nz,cntzr2	;still non-zero
	ld	c,n1		;re-initialize counter 1
cntzr2:	dec	b
	jp	nz,decdbl	;decrement counter-2, still non-zero, go for more
	ld	b,n2		;re-initialize counter 2
	jp	decdbl		;keep going until done

	public	prochk,prodir
prodir:	push	hl		;save [h,l]
	ld	hl,(curlin)	;get current line #
	ld	a,h		;direct?
	and	l
	pop	hl		;restore [h,l]
	inc	a		;if a=0, direct
	ret	nz
prochk:	push	af		;save flags
	ld	a,(proflg)	;is this a protected file?
	or	a		;set cc's
	jp	nz,fcerr	;yes, give error
	pop	af		;restore flags
	ret	

tempb:	;used by field
record:	defs	2		;record #
lbuff:	defs	2		;logical buffer address
pbuff:	defs	2		;physical buffer address
pgtflg:	defs	1		;put/get flag (non zero=put)

;	end	
