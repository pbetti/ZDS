
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
	;subttl	disk parameters and documentation
	title	disk code for cpm/ontel/mostek/dmc/beehive: whg,pga,mbm


;extrnal symbols


	extrn	derbfm,derbfn,derbrn,derdfl
	extrn	derfao,derfnf,derioe,dernmf,dertmf
	extrn	finprt,outdo,crdo
	extrn	temp,strout,strlt3,snerr,scrtch
	extrn	faclo,fout,conint
	extrn	clsall,filfrm,filidx,getbyt,filscn


	extrn	buf


	extrn	dcompr,getypr,synchr

	extrn	filnam
	extrn	filna2
	extrn	dirtmp
	
	extrn	conia,givint,sngflt,ptrfil,popaht,maxtrk
	extrn	frmevl,frestr,chrgtr,gtmprt,ttypos,linlen
	extrn	fcerr
	
;internal symbols

	public	ntopnc,filout,filou3,indskc
	public	nmlofs,nmlofc,nmlo.c,datofs,datofc,locofs
	public	eof,clsfil,loc
	public	fname,open,kill,indskb,prgfil




;
;
;			revision history
;			-------- -------
;
;11/7/77		fixed eof() code to use ornofs instead of nmlofs, pga
;12/2/77  (4.41) 	fixed random access to close extents pga
;12/17/77		additional code to support ontel dos basic, p.zilber
;12/29/77 (4.42)	fixed bug where get, put w/o rec not inc curloc, pga
;1/5/78   (4.43) 	fixed another random bug, line printer ^c prob. pga
;7/23/79		add beehive interace and cleanup conditionals
;
;
;
;file information:
;
;	 1	mode of the file
;f.blk1	(n)	1st block of space, usually fcb( cpm: 33, ontel: 42,
;		mostek: 47 ). zero for others
;locofs	 2	curloc, # of sectors read or writeen for sequential.
;		for random files, it is the last record # +1.
;ornofs	 1/2	seq input: 	# of bytes in sector when read.
;		seq output:	# bytes in output sector( # written )
;		random:		set to datpsc by put and get, sometimes
;				zeroed by outsq2 setup for dskout code.
;nmlofs	 1/2	seq input:	# bytes left in input buffer
;		seq output:	position of imaginary print head
;f.blk2	(n)	2nd block of space( 6 byte chain links for ontel,
;		160 bytes for dmc, 10 bytes for beehiv )
;datofs	(n)	sector buffer, length = datpsc
;
;extra information for 5.0 version only:
;
;fd.siz	 2	variable length record size( default = 128 )
;fd.phy	 2	current physical record #
;fd.log	 2	current logical record #
;fd.chg	 1	future flag for across record prints, etc.
;fd.ops	 2	output print position for print, input, write
;fd.dat	(n)	data buffer for field, size is (fd.siz). fd.max is max.
;
;%

;file modes

md.000	defl	0		;the mode number for no file, internal
				;use only as an escape from open
md.rnd	defl	3		;the mode number for random files
md.sqi	defl	1		;the mode number for sequential input
				;files never written into a file
md.sqo	defl	2		;the mode for sequential output files
				;and program files

;disk code configuration switches

spc1st	defl	1 or 0 or 0 or 0 or 0 or 0;1st block exists
spc2nd	defl	0 or 0 or 0	;2nd block exists
sw2byt	defl	0 or 0 or 0	;2 byte offsets (datpsc .gt. 255)
swlof	defl	1 or 0 or 0 or 0 or 0 or 0;there is a lof function
swres	defl	1 or 0 or 0	;there is a reset statement
swfil	defl	0 or 1 or 0 or 0 or 0;there is a files command
swdskf	defl	(0 or 0) and (0-1);there is a dskf function

; offsets into file blocks for specific entries

locofs	defl	34+3*1+9*0+14*0-10*0+267*0-30*0;offset to curloc bytes
ornofs	defl	2+locofs	;offset to number of bytes
				;originally in the buffer
nmlofs	defl	1+ornofs+0	;offset to bytes remaining in the buffer
nmlofc	defl	0+nmlofs
				;or the print position on output
nmlo.c	defl	0+nmlofs


datofs	defl	1+nmlofs+0+6*0+288*0+10*0;offset to buffer
datofc	defl	0+datofs
dblksz	defl	datofs+datpsc
	public	dblk.c
dblk.c	defl	0+dblksz

q	defl	dblksz
;define	ent(sym,siz),<
;intern	sym
;sym=q
;q=q+siz>

	public	fd.siz,fd.phy,fd.log,fd.chg,fd.ops,fd.dat
fd.max	defl	0		;size of field buffer

;ent	fd.siz,2		;variable length record size default 128
fd.siz	defl	q
q	defl	q+2
;ent	fd.phy,2		;current physical record #
fd.phy	defl	q
q	defl	q+2
;ent	fd.log,2		;current logical record number
fd.log	defl	q
q	defl	q+2
;ent	fd.chg,1		;future flag for accross block prints etc.
fd.chg	defl	q
q	defl	q+1
;ent	fd.ops,2		;output print position for print, input, write
fd.ops	defl	q
q	defl	q+2
;ent	fd.dat,fd.max		;actual field data buffer
fd.dat	defl	q
q	defl	q+fd.max
				;size is fd.siz bytes long

	public	fnzblk
fnzblk	defl	0+q

eofchr	defl	26+2*0-22*0-23*0;end of file character

	;subttl	operating system calls and other data


	extrn	cpmvrn,cpmrea,cpmwri

; cpm call identifiers

c.open	defl	15
c.clos	defl	16
c.dele	defl	19
;c.writ==21
c.make	defl	22
c.rena	defl	23
c.buff	defl	26		;set dma address
c.gdrv	defl	25		;get currently selected drive
c.sdrv	defl	14		;set currently selected drive
c.rest	defl	13		;initialize bdos
c.sear	defl	17		;search for file

; offsets into cp/m fcb (file control block)
fcb.fn	defl	1-0		;file name
fcb.ft	defl	9-0		;extension
fcb.ex	defl	12+20*0		;file extent
fcb.rc	defl	15+23*0		;record count = current extent size
fcb.nr	defl	32+8*0		;next record number
fcb.rn	defl	33		;cp/m 2.x random record number





;special for cp/m testing

	;subttl	eof function

	public	eof
eof:	call	filfrm		;convert argument to file number
	jp	z,derbfn	;bad file number - not found !!!
				;and set [b,c] to point to file data block
	cp	md.sqo		;is it a sequential output file?
	jp	z,derbfm	;then give bad file mode
ornchk:	ld	hl,0+ornofs	;see if any bytes arrived in this buffer
	add	hl,bc
	ld	a,(hl)		;zero iff it is end of file
	or	a		;set cc'S
	jp	z,waseof	;no bytes left
	ld	a,(bc)		;** 5.11 **  get file mode
	cp	md.rnd		;is it a random file?
	jp	z,waseof	;** 5.11 **  (a) .ne. 0 - not eof
	inc	hl		;point to number left in buffer
	ld	a,(hl)		;get number of bytes in buffer
	or	a		;non-zero?
	jp	nz,chkctz	;then check for control-z
	push	bc		;save [b,c]
	ld	h,b		;get fcb pointer in [b,c]
	ld	l,c
	call	readin		;read another buffer
	pop	bc		;restore [b,c]
	jp	ornchk		;have new buffer, use previous procedure
chkctz:	ld	a,datpsc and 377o;get # of bytes in full buffer
	sub	(hl)		;subtract left
	ld	c,a		;put in [b,c] for dad
	ld	b,0
	add	hl,bc		;add to ornofs offset
	inc	hl		;add one to point to byte in buffer
	ld	a,(hl)		;get byte
	sub	eofchr		;if control-z, eof (control-\ is fs)
waseof:	sub	1		;map 0 to -1 and all others to 0
	sbc	a,a
	jp	conia		;convert to an integer and return

	;subttl	outseq	-- sequential output for a data block

;
; [b,c] points at file data block
;
	public	outseq
outseq:	ld	d,b		;put file block offset in [d,e]
	ld	e,c
	inc	de		;point to fcb
outsq2:	ld	hl,0+ornofs	;point to number in buffer
	add	hl,bc		;add start of file data block
	push	bc		;save file data pointer
	xor	a
	ld	(hl),a		;zero out number in data buffer

;	output next record in file
;
;	(a) = 0
;	(hl) points to nmlofs-1
;	(de) points to file data block + 1 ( fcb if spc2nd=0)
;	(bc) points to file data block

	call	setbuf		;set buffer address
	ld	a,(cpmwri)	;get write code
	call	accfil		;access file
	cp	255
	jp	z,dertmf	;too many files - 5.11
	dec	a		;error extending file? (1)
	jp	z,derioe	;yes
	dec	a		;disk full? (2)
	jp	nz,outsok	;no
	pop	de		;get back file pointer
	xor	a		;get zero
	ld	(de),a		;mark as closed
	ld	c,c.clos	;close it
	inc	de		;point to fcb
	call	cpment		;call cp/m
	jp	derdfl		;give "DISK FULL" error message
outsok:	inc	a		;too many files?
	jp	z,dertmf	;yes

	pop	bc		;get pointer at curloc
	ld	hl,0+locofs	;by adding offset to file pointer
	add	hl,bc
	ld	e,(hl)		;increment it
	inc	hl
	ld	d,(hl)
	inc	de
	ld	(hl),d
	dec	hl
	ld	(hl),e
	ret	

	;subttl	close a file
; file number is in [a]
; zero all information. if file is open, raise its disks head
; if file is sequential output, send final sector of data

	public	clsfil
clsfil:	call	filidx		;get pointer to data
	jp	z,ntopnc	;return if not open
				;save file #
	push	bc		;save file pointer
	ld	a,(bc)		;get file mode
	ld	d,b		;put file block offset in [d,e]
	ld	e,c
	inc	de		;point to fcb
	push	de		;save [d,e] for later
	cp	md.sqo		;seqential output?
	jp	nz,noforc	;no need to force partial output buffer
	ld	hl,clsfl1	;return here
	push	hl		;save on stack
	push	hl		;need extra stack entry
	ld	h,b		;get file pointer
	ld	l,c		;into [h,l]
	ld	a,eofchr	;put out control-z (or fs)
	jp	filou4		;jump into char output code

clsfl1:	ld	hl,0+ornofs	;chars in buffer
	add	hl,bc		;test
	ld	a,(hl)		;test ornofs
	or	a
	call	nz,outsq2	;force out buffer


noforc:	pop	de		;get back fcb pointer

;	close file
;
;	(de) points to fcb
;	((sp)) points to file data block

	call	setbuf		;set dma address
	ld	c,c.clos	;the close
	call	cpment		;call cpm
;*****	no check for errors





	pop	bc		;restore file pointer
ntopnc:	ld	d,datofs	;number of bytes to zero
	xor	a
morczr:	ld	(bc),a
	inc	bc
	dec	d
	jp	nz,morczr
	ret	

	;subttl	loc (current location) and lof (last record number)

	public	loc
loc:	call	filfrm		;convert argument and point at data block
	jp	z,derbfn	;if not open, "BAD FILE NUMBER"
	cp	md.rnd		;random mode?
	ld	hl,0+locofs+1	;assume not
	jp	nz,loc1		;no, use curloc
	ld	hl,0+fd.log+1	;point at logical record number
loc1:
intred:	add	hl,bc
intret:	ld	a,(hl)
	dec	hl
	ld	l,(hl)
	jp	givint
	page	
	public	lof
lof:	call	filfrm		;convert argument and index
	jp	z,derbfn	;"BAD FILE NUMBER" if not open

;	(bc) points to file data block

	ld	hl,0+fcb.rc+1	;point to record number
	add	hl,bc
	ld	a,(hl)		;get rc
	jp	sngflt	;float it
				;return with lof in (hl)
				;swlof

	;subttl	filout -- put a character in an output buffer and output if necessary
;
; call at filout with [h,l] to be saved on the stack
; and the character in the high order byte below the [h,l]
; on the stack. the current data is output if there are 128
; character stuffed into the data area.
; filout is normally called from outdo (outchr)
;
filout:	pop	hl		;get saved [h,l] off stack
	pop	af		;get save char off stack
filou3:	push	hl		;save the [h,l]
	push	af		;save the character again
	ld	hl,(ptrfil)	;get the pointer to the file
	ld	a,(hl)		;what is the mode?
	cp	md.sqi		;must be echoing or "EXTRA IGNORED"
				;during the reading of a file
	jp	z,popaht	;so ignore this outchr
	extrn	filofv
	cp	md.rnd		;random?
	jp	z,filofv	;yes, finish up in fivdk.mac
	pop	af		;take the character off
filou4:	push	de
	push	bc
	ld	b,h		;setup [b,c] for outseq
	ld	c,l
	push	af		;re-save output character
	ld	de,0+ornofs	;point at the number of characters in the
	add	hl,de		;buffer currently
	ld	a,(hl)
	cp	datpsc and 377o	;is the buffer full?
	push	hl		;save pointer at character count
	call	z,outseq	;output if full
	pop	hl		;get back data block pointer
	inc	(hl)		;increment the number of characters
	ld	c,(hl)		;fetch for offset into data
	ld	b,0
	inc	hl		;point at print position
	public	filupp
filupp:
	pop	af		;get the output character
	push	af		;resave for output
	ld	d,(hl)		;[d]=current position
	cp	13		;back to zero position with return?
	ld	(hl),b		;assume reset to zero since [b]=0
	jp	z,iscrds	;all done updating position
	add	a,224		;set carry for spaces and higher
	ld	a,d		;[a]=current position
	adc	a,b		;add on carry since [b]=0
	ld	(hl),a		;update the position in the data block
iscrds:	add	hl,bc
	pop	af		;get the character
	pop	bc
	pop	de
	ld	(hl),a		;save it in the data area
	pop	hl		;get back saved [h,l]
	ret	

	;subttl	put and get statements

;	extrn	get,put
	public	fivdpt
fivdpt:
	dec	de		;map record number 1=0 logical
	dec	hl
	ld	(hl),e
	inc	hl
	ld	(hl),d		;setup curloc again
	inc	hl		;point to orn
	ld	(hl),datpsc and 377o;set number in the buffer to datspc
	inc	hl
	ld	(hl),datpsc and 377o
	pop	hl		;[h,l]=text pointer
	ex	(sp),hl		;save text pointer, [h,l]=start of data block
	ld	b,h
	ld	c,l

;	random file access
;
;	(de) = physical block #
;	(bc) points to file data block
;	(hl) points to file data block

	push	hl		;save data block pointer
	ld	a,(cpmvrn)	;get version number
	or	a
	jp	z,rndvr1	;version 1.x

	ld	hl,0+fcb.rn+1	;offset to random record number
	add	hl,bc
	ld	(hl),e		;set new random record number
	inc	hl
	ld	(hl),d
	inc	hl
	ld	(hl),0
	jp	rnddon		;finished setting record number

rndvr1:	ld	hl,0+fcb.ex+1	;point to extent
	add	hl,bc		;add start of file control block
	ld	a,e		;get low byte of offset
	rla			;get high bit in carry
	ld	a,d		;get high byte
	rla			;rotate in high byte of low part
	ld	d,(hl)		;put original extent in [d]
	cp	d		;are new and old extent the same?
	jp	z,samext	;same extent, dont re-open
	push	de		;save record number
	push	af		;save new extent
	push	hl		;save pointer to extent
	push	bc		;save file pointer
	ld	de,dirtmp	;read directory in here for open
	ld	c,c.buff	;set cpm buffer address
	call	cpment
	pop	de		;get cpm fcb pointer
	push	de		;save back
	inc	de		;point to fcb
	ld	c,c.clos	;close previous extent (?!)
	call	cpment		;call cp/m
	pop	de		;get back fcb pointer
	pop	hl		;restore pointer to extent field
	pop	af		;get back new extent
	ld	(hl),a		;store new extent
	push	de
	inc	de		;point to fcb
	ld	c,c.open	;open new extent
	push	de		;save extent pointer
	call	cpment		;by calling cp/m
	pop	de		;restore fcb pointer
	inc	a		;does extent exist?
	jp	nz,rndok	;yes
	ld	c,c.make	;make the extent exist
	call	cpment		;call cp/m
	inc	a		;room in directory?
	jp	z,dertmf	;no
rndok:	pop	bc		;restore [b,c]
	pop	de		;restore record number
samext:	ld	hl,0+fcb.nr+1	;next record field
	add	hl,bc		;point to it
	ld	a,e		;get low 7 bits of record #
	and	127
	ld	(hl),a		;set record #

rnddon:
	pop	hl		;[h,l] point at file data block

;	(bc) points to file data block
;	(hl) points to file data block

	ld	a,(maxtrk)	;get flag for "PUT" or "GET"
	or	a
	jp	nz,putfin	;do the putting
	call	readin		;perform the get
	pop	hl		;get the text pointer
	ret	

putfin:
	ld	hl,0+fcb.nr+1	;look at record #
	add	hl,bc		;[h,l] points to it
	ld	a,(hl)		;get it
	cp	127		;last record in extent?
	push	af		;save indicator
	ld	de,dirtmp	;save here
	ld	hl,0+datofs	;point to data
	add	hl,bc
	push	de		;save dirtmp pointer
	push	hl		;save data pointer
	call	z,bufmov	;not last extent
	call	outseq		;output the data
	pop	de		;restore data pointer
	pop	hl		;restore pointer to dirtmp
	pop	af		;restore indicator
	call	z,bufmov	;move sector
	pop	hl		;get the text pointer
	jp	finprt		;zero ptrfil

bufmov:	push	bc		;save [b,c]
	ld	b,datpsc	;# of bytes to move
bufslp:	ld	a,(hl)		;get byte from buffer
	inc	hl		;bump pointer
	ld	(de),a		;save in dirtmp
	inc	de		;bump pointer
	dec	b
	jp	nz,bufslp	;keep moving bytes
	pop	bc		;restore [b,c]
	ret	

	;subttl	indskc, fillsq, and readin -- for reading characters and buffers

;
; get a character from a sequential file in [ptrfil]
; all registers except [d,e] smashed
;
;	'C' set if eof read
;
indskb:	push	bc		;save char counter
	push	hl		;save [h,l]
indsk3:	ld	hl,(ptrfil)	;get data block pointer
	extrn	filifv
	ld	a,(hl)		;get file mode
	cp	md.rnd		;random?
	jp	z,filifv	;do input
	ld	bc,0+nmlofs	;see how many characters left
	add	hl,bc
	ld	a,(hl)		;get the number
	or	a
	jp	z,fillsq	;must go read some more -- if can
	dec	hl		;point at ornofs
	ld	a,(hl)		;get original number
	inc	hl		;point at number left again
	dec	(hl)		;decrement the number
	sub	(hl)		;subtract to give offset
	ld	c,a		;[c]=offset
	add	hl,bc
	ld	a,(hl)		;get the data
	or	a		;reset carry flag for no eof
	pop	hl		;restore [h,l]
popbrt:	pop	bc		;restore
	ret	

fillsq:	dec	hl		;back up pointer
	ld	a,(hl)		;to ornofs
	or	a		;did we hit eof on previous read?
	jp	z,fills1	;yes
	call	read2		;read a record
;	ora	a		;used to be - was it eof?
	jp	nz,indsk3	;return with a char
fills1:	scf			;carry is eof flag
	pop	hl		;restore [h,l]
	pop	bc		;eof detected
	ld	a,eofchr	;return with char=control-z (or =fs)
	ret	

read2:	ld	hl,(ptrfil)	;get data pointer
readin:	push	de
	ld	d,h		;put fcb pointer in [d,e]
	ld	e,l
	inc	de
	ld	bc,0+locofs	;point to curloc
	add	hl,bc
	ld	c,(hl)		;update [curloc]
	inc	hl
	ld	b,(hl)
	inc	bc
	dec	hl
	ld	(hl),c
	inc	hl
	ld	(hl),b
	inc	hl		;point to number read
	inc	hl		;point to nmlofs
	push	hl		;save [h,l]
; zero out the buffer in case nothing read
	ld	c,datpsc	;number of bytes/buffer
zrrnd:	inc	hl		;increment buffer pointer
	ld	(hl),0		;zero it
	dec	c		;decrement count
	jp	nz,zrrnd	;keep zeroing

;	read specified record in file
;
;	(de) points to fcb
;
;	if sw2byt = 0,
;		(a) = number of bytes read
;	if sw2byt = 1,
;		(de) = number of bytes read
;
;	if eof, return with (a) or (de) zero and
;		jump to readi2
;
;	returns 'Z' set if eof

	call	setbuf		;set cpm buffer address
	ld	a,(cpmrea)	;get read code
	call	accfil		;access file
	or	a		;eof?
	ld	a,0		;return 0 if eof
	jp	nz,readi2	;assume eof if error
readi1:	ld	a,datpsc	;otherwise, have 128 bytes
readi2:	pop	hl		;point back to # read
	ld	(hl),a		;store number read
	dec	hl		;point at number originally
	ld	(hl),a		;store number read
	or	a		;test for eof
	pop	de		;get [d,e] back
	ret	

setbuf:	push	bc		;save [b,c]
	push	de		;save [d,e]
	push	hl		;save [h,l]
	ld	hl,0+datofs-1	;point to buffer
	add	hl,de		;add
	ex	de,hl		;put buffer address in [d,e]
	ld	c,c.buff	;set up buffer address
	call	cpment		;call cpm
	pop	hl		;restore [h,l]
	pop	de		;restore [d,e]
	pop	bc		;restore [b,c]
	ret	

;
indskc:
	call	indskb		;get char
	ret	c		;if eof, return with end of file character
	cp	eofchr		;was it a control-z (or fs)?
	scf			;set carry
	ccf			;make sure carry reset
	ret	nz		;no
	push	bc		;save [b,c]
	push	hl		;save [h,l]
	ld	hl,(ptrfil)	;get pointer to file data block
	ld	bc,0+ornofs	;point to number originally in buffer
	add	hl,bc
	ld	(hl),0		;force it to zero
	inc	hl		;point to number in buffer
	ld	(hl),0		;force to zero.
	scf			;set eof flag
	pop	hl		;restore [h,l]
	pop	bc		;restore [b,c]
	ret	


	;subttl	namfil -- scan a file name and name command

namfil:	call	frmevl		;evaluate string
	push	hl		;save text pointer
	call	frestr	;free up the temp
	ld	a,(hl)		;get length of string
	or	a		;null string?
	jp	z,dernmf	;yes, error
	push	af		;no "." seen
	inc	hl		;pick up pointer to string
	ld	e,(hl)		;by getting address
	inc	hl		;out of descriptor
	ld	h,(hl)
	ld	l,e		;[h,l] points to string
	ld	e,a		;save length

;	(hl) points to filename
;	(a) = length
;	(e) = length
;	((sp)) = no carry

	cp	2		;can there be a device?
	jp	c,nodev		;no, name too short
	ld	c,(hl)		;[c]=possible device name
	inc	hl		;point to next char
	ld	a,(hl)		;get it
	dec	e		;decrement count for device name
	cp	':'		;colon for device name?
	jp	z,chkfil	;yes, so now get file name
	dec	hl		;back up pointer by one
	inc	e		;compensate for dcr
nodev:	dec	hl		;back up pointer
	inc	e		;increment char count to compensate for next decr
	ld	c,'A'-1		;use currently selected drive
chkfil:	dec	e		;decrment char count
	jp	z,dernmf	;error if no filename
	ld	a,c		;get drive #
	sub	'A'-1		;convert to logical number
	jp	c,dernmf	;not in range
	cp	27		;bigger than 27
	jp	nc,dernmf	;not allowed
	ld	bc,filnam	;where to put name
	ld	(bc),a		;store disk # in fcb
	inc	bc		;point to where first char of file name is stored
	ld	d,11-2*0	;length of name
filinx:	inc	hl		;bump pointer
fillop:	dec	e		;end of string
	jp	m,filspc	;yes, fill rest of field with blanks
	ld	a,(hl)		;get char
	cp	'.'		;extension?
	jp	nz,fillo1	;no
fillo0:	call	fillnm		;yes, fill name with blanks
	pop	af		;restore cc'S
	scf			;flag "." seen
	push	af		;save cc'S BACK
	jp	filinx		;yes, ignore "."
fillo1:
	ld	(bc),a		;copy char
	inc	bc
	inc	hl
	dec	d		;decrment possible count of chars
	jp	nz,fillop
gotnam:
	xor	a		;clear extent field
	ld	(filnam+12),a
	pop	af		;restore condition codes
	pop	hl		;get back text pointer
	ret	

fillnm:	ld	a,d	;get # of chars
	cp	11+8*0-2*0	;initial position?
	jp	z,dernmf	;dont allow null filename
	cp	3		;filled field?
	jp	c,dernmf	;no, but 2nd "."
	ret	z		;yes, back to loop
filln1:	ld	a,' '		;fill with space
	ld	(bc),a
	inc	bc
	dec	d
	jp	fillnm
filspc:	inc	d		;chars left in file buffer
	dec	d		;test
	jp	z,gotnam	;no
filsp2:	ld	a,' '		;space
	ld	(bc),a		;store
	inc	bc
	dec	d		;filled whole field?
	jp	nz,filsp2	;no, more spaces
	jp	gotnam		;yes, make sure name ok
	page	
fname:		
	call	namfil		;pick up the old name to use
	push	hl		;save the text pointer
	ld	de,dirtmp	;read directory in here
	ld	c,c.buff	;set buffer address
	call	cpment		;call cp/m
	ld	de,filnam	;see if original name exists
	ld	c,c.open	;by opening
	call	cpment		;call cp/m
	inc	a		;does it exist?
	jp	z,derfnf	;file not found
	ld	hl,filna2	;save file name in filna2
	ld	de,filnam
	ld	b,12+3*0-2*0+2*0+3*0-3*0;set [c]=max file name length
namrmv:	ld	a,(de)		;get byte from file
	ld	(hl),a		;save byte in "OLD" file name
	inc	hl		;bump pointers
	inc	de
	dec	b
	jp	nz,namrmv
	pop	hl		;get the text pointer back
	call	synchr
	defb	'A'		;make sure "AS" is there
	call	synchr
	defb	'S'		;
	call	namfil		;read the new name
	push	hl		;save the text pointer
	ld	a,(filnam)	;get disk # of file name
	ld	hl,filna2	;point to orig file
	cp	(hl)		;compare
	jp	nz,fcerr	;disks must be the same
	ld	de,filnam	;see if original name exists
	ld	c,c.open	;by opening
	call	cpment		;call cp/m
	inc	a		;does it exist?
	extrn	derfae
	jp	nz,derfae	;yes
	ld	c,c.rena	;rename operation
	ld	de,filna2	;point at old name fcb
	call	cpment		;call cpm
;	inr	a		;file found?
;****dont check error return, cp/m has problems****
;	jz	derfnf		;no
	pop	hl		;restore text pointer
	ret	



	;subttl	open statement and all directory handling

open:	ld	b,finprt	;zero ptrfil when done
	push	bc
	call	frmevl		;read the file mode
	push	hl		;save the text pointer
	call	frestr		;free string temp & check string
	ld	a,(hl)		;make sure its not a null string
	or	a
	jp	z,derbfm	;if so, "BAD FILE MODE"
	inc	hl
	ld	c,(hl)		;[b,c] point at mode character
	inc	hl
	ld	b,(hl)
	ld	a,(bc)		;[a]=mode character
	and	-1-' '		;force to upper case
	ld	d,md.sqo	;assume its "O"
	cp	'O'		;is it?
	jp	z,havmod	;[d] has correct mode
	ld	d,md.sqi	;assume sequential
	cp	'I'		;is it?
	jp	z,havmod	;[d] says sequential input
	ld	d,md.rnd	;must be random
	cp	'R'
	jp	nz,derbfm	;if not, no match so "BAD FILE MODE"
havmod:	pop	hl		;get back the text pointer
	call	synchr
	defb	44		;skip comma before file number
	push	de		;save the file mode
	cp	'#'		;skip a possible "#"
	call	z,chrgtr
	call	getbyt		;read the file number
	call	synchr
	defb	44		;skip comma before name
	ld	a,e		;[a]=file number
	or	a		;make sure file wasn'T ZERO
	jp	z,derbfn	;if so, "BAD FILE NUMBER"
	pop	de		;get back file mode
prgfil:	ld	e,a		;save file number in [e]
	push	de		;save the mode in [d]
	;since program file [a]=0
	call	filidx		;[b,c] point at file data block
	jp	nz,derfao	;if non zero mode, "FILE ALREADY OPEN"
	pop	de		;[d]=file mode
	ld	a,d		;file mode to [a]
	ld	(bc),a		;save in file block
	push	bc		;save pointer at file data block
	push	de		;save back file mode and number
	call	namfil		;read the name
	pop	de		;restore file number
	pop	bc		;get back file data block pointer
	push	bc		;save back
	extrn	varecs
	push	af		;save extension flag
	ld	a,(bc)		;get file mode
	call	varecs		;scan record length field
	pop	af		;get back extension flag
	extrn	temp
	ld	(temp),hl	;save the text pointer for a while
	jp	c,prgdot	;if "." seen, dont default extension
	ld	a,e		;get file number
	or	a		;set condition codes
	jp	nz,prgdot	;not file 0, dont default file name
	ld	hl,filnam+9-0-0-2*0;point to first char of extension
	ld	a,(hl)		;get it
	cp	' '		;blank extension
	jp	nz,prgdot	;non-blank extension, dont use default
	ld	(hl),'B'	;set default extension
	inc	hl
	ld	(hl),'A'
	inc	hl
	ld	(hl),'S'	;set ".BAS"
	;bascom
prgdot:	pop	hl		;[h,l]=pointer at file data block
	ld	(ptrfil),hl	;setup as current file
	push	hl		;save back file data block pointer
	inc	hl		;point to fcb entry
	ld	de,filnam	;get pointer to scanned file name
	ld	c,12+0+0*3+2*0+3*0;number of bytes to copy
opnlp:	ld	a,(de)		;get byte from filnam
	ld	(hl),a		;store in file data block
	inc	de
	inc	hl
	dec	c		;decrment count of bytes to move
	jp	nz,opnlp	;keep looping

;	open file
;
;	((sp)) points to file data block
;	((sp)+2) contains the file mode - dmc!x3200!r2e

	ld	(hl),0		;make sure extent field is zero
	ld	de,0+20		;point to nr field
	add	hl,de
	ld	(hl),0		;set to zero
	pop	de		;get pointer to file data block back in [d]
	push	de		;save again for later
	inc	de
	call	setbuf		;set buffer address
	pop	hl		;get back file data block ptr
	push	hl		;save back
	ld	a,(hl)		;get mode
	cp	md.sqo		;seqential output?
	jp	nz,opnfil	;no, do cpm open call
	push	de		;save fcb pointer
	ld	c,c.dele	;delete existing output file, if any
	call	cpment		;call cp/m
	pop	de		;restore fcb pointer
makfil:	ld	c,c.make	;create file
	call	cpment		;call cpm
	inc	a		;test for too many files
	jp	z,dertmf	;that was the case
	jp	opnset		;finish setup of file data block
opnfil:	ld	c,c.open	;cpm code for open
	call	cpment		;call cpm
	inc	a		;file not found
	jp	nz,opnset	;found
	pop	de		;get back file pointer
	push	de		;save back
	ld	a,(de)		;get mode of file
	cp	md.rnd		;random?
	jp	nz,derfnf	;no, seqential input, file not found
	inc	de		;make [d,e]=fcb pointer
	jp	makfil		;make file

;	((sp)) points to file data block
;	((sp)+2) contains the file mode - dmc!x3200!r2e

opnset:	pop	de	;point to file info
	push	de		;save pointer back
	ld	hl,0+locofs	;point to curloc
	add	hl,de
	xor	a		;zero curloc in case this file
	;was just killed
	ld	(hl),a
	inc	hl
	ld	(hl),a
	inc	hl
	ld	(hl),a		;zero number of bytes in the buffer
	inc	hl
	ld	(hl),a		;zero print position
	pop	hl		;get pointer at mode
	ld	a,(hl)		;see what has to be done
	cp	md.rnd		;is it random mode?
	jp	z,rndfin	;yes random finish up
	cp	md.sqi		;if sequential all that is left to do
	jp	nz,gtmprt	;fetch text pointer and done

;
; finish up sequential input after finding file
;
	call	read2		;read first data block
opn000:
	ld	hl,(temp)	;get back the text pointer
	ret	

rndfin:	ld	bc,0+datofs;now advance pointer to data
	add	hl,bc		;by adding proper offset
	ld	c,datpsc	;# of bytes to zero
zrrndt:	ld	(hl),b
	inc	hl
	dec	c
	jp	nz,zrrndt
	jp	gtmprt		;get text pointer

	;subttl	system (exit) command - return to cpm (or exit to os)

	public	system
	public	systme
system:
	ret	nz		;should terminate
	call	clsall		;close all data files
systme:	jp	cpmwrm		;warm start cp/m
	;bascom

	;subttl	reset command - force directory re-read on all disks

	public	reset
reset:	ret	nz		;should terminate
	push	hl		;save text pointer
	call	clsall		;close all files
	ld	c,c.gdrv	;get drive currently selected
	call	cpment		;get it in [a]
	push	af		;save current drive #
	ld	c,c.rest	;do the reset call
	call	cpment
	pop	af		;get drive to select
	ld	e,a		;into [e]
	ld	c,c.sdrv	;set drive
	call	cpment		;call cpm
	pop	hl		;restore text pointer
	ret	

	;subttl	kill command

kill:	
	call	namfil		;scan file name
	push	hl		;save text pointer
	ld	de,dirtmp	;read directory in here
	ld	c,c.buff	;set buffer address
	call	cpment		;for cp/m
	ld	de,filnam	;try to open file
	push	de		;save fcb pointer
	ld	c,c.open
	call	cpment
	inc	a		;file found?
	pop	de		;get back pointer to fcb
	push	de		;save back
	push	af		;save found flag
	ld	c,c.clos	;this may not be nesc.
	call	nz,cpment	;close file
	pop	af		;restore found indicator
	pop	de		;restore fcb pointer
	jp	z,derfnf	;yes
	ld	c,c.dele	;code for delete
	call	cpment		;call cpm
	pop	hl		;get back text pointer
	ret	

	;subttl	files command - list the directory

; this is the files[<filename>] command
; which prints the files which match the <filename> wildcard specifier
; if <filename> is omitted, all the files on the currently selected drive
; are listed
	public	files
files:
	jp	nz,filnb	;file name was specified
	push	hl		;save text pointer
	ld	hl,filnam	;point to file name
	ld	(hl),0		;set current drive
	inc	hl		;bump pointer
	ld	c,11+8*0	;match all files
	call	filqst		;set file name and extension to question marks
	pop	hl		;restore text pointer
filnb:	call	nz,namfil	;scan file name
	xor	a		;make sure extent is zero
	ld	(filnam+12),a
	push	hl		;save text pointer
	ld	hl,filnam+1	;get first char of file name
	ld	c,8		;fill name with question marks
	call	filqs
	ld	hl,filnam+9	;point to extension
	ld	c,3		;3 chars in extension
	call	filqs		;fill it with qmarks
	ld	de,dirtmp	;set buffer to 80 hex
	ld	c,c.buff
	call	cpment
	ld	de,filnam	;point to fcb
	ld	c,c.sear	;do initial search for file
	call	cpment		;call cp/m
	cp	255		;find first incarnation of file
	jp	z,derfnf	;no
filnxt:	and	3		;mask off low two bits
	add	a,a		;multiply by 32
	add	a,a
	add	a,a
	add	a,a
	add	a,a
	ld	c,a		;put offset in [b,c]
	ld	b,0
	ld	hl,dirtmp+1	;point to directory buffer
	add	hl,bc		;point to fcb entry in directory
	ld	c,11+5*0+11*0	;chars in name
mornam:	ld	a,(hl)		;get file name char
	inc	hl		;bump pointer
	call	outdo		;print it
	ld	a,c		;get  char posit
	cp	4+5*0		;about to print extension?
	jp	nz,notext	;no
	ld	a,(hl)		;get first char of extension
	cp	' '		;if so, not space
	jp	z,prispa	;print space
	ld	a,'.'		;print dot
prispa:	call	outdo
notext:	dec	c		;decrement char count
	jp	nz,mornam	;more of name to print
	ld	a,(ttypos)	;get current tty posit
	add	a,13+6*0+9*0+2*0;space for next name?
	ld	d,a		;save in d
	ld	a,(linlen)	;get length of terminal line
	cp	d		;compre to current posit
	jp	c,nwfiln	;need to force crlf
	ld	a,' '		;two spaces between file names
	call	outdo
	call	outdo
	;or three
nwfiln:
	call	c,crdo		;type crlf
	ld	de,filnam	;point at fcb
	ld	c,c.sear+1	;search for next entry
	call	cpment		;search for next incarnation
	cp	255		;no more?
	jp	nz,filnxt	;more.
nwfil2:
	pop	hl		;restore text pointer
	ret	

filqs:	ld	a,(hl)		;get char
	cp	'*'		;wild card?
	ret	nz		;no, return
filqst:	ld	(hl),'?'	;store question mark
	inc	hl		;bump pointer
	dec	c		;decrement count of qmarks
	jp	nz,filqst	;keep saving qmarks
	ret	
	;final cr/lf
	;swfil

	;subttl	dskf function


	;subttl	miscellaneous operating system i/o

accfil:	push	de		;save fcb address
	ld	c,a
	push	bc
	call	cpment
	pop	bc
	pop	de
	push	af
	ld	hl,0+fcb.rn	;point to random record number
	add	hl,de
	inc	(hl)
	jp	nz,accfl1
	inc	hl
	inc	(hl)
	jp	nz,accfl1
	inc	hl
	inc	(hl)
accfl1:	ld	a,c		;get back cpm call code
	cp	34		;is it random write/
	jp	nz,accfl2	;no

	pop	af		;get error code and map into 1.4 errors
	or	a
	ret	z
	cp	5
	jp	z,dertmf	;too many files
	cp	3
	ld	a,1		;turn into i/o error
	ret	z
	inc	a		;default to disk space full (2)
	ret	

accfl2:	pop	af
	ret	



	;subttl	bascom o.s. dependent data areas


;	end	
