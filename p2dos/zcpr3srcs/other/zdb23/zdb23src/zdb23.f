;
; ZDB23.F - Datafile Output Module
;
dfile:	ld	(fflag),a	; Save filetype flag
	call	ioinit		; Initialize for file output
;
; Select key for output file records
;
df0:	xor	a
	ld	(keyflg),a	; Initialize flags
	ld	(xclflg),a

	ld	hl,kamsg	; Point to trailing menu message
	call	clredm		; Display menu, get command
	ld	(keyflg),a	; Save flag
	ld	de,dftbl
	call	acase3
	jr	df0
;
df1:	call	qmenu		; Test for common exit-to-menu commands
	jr	df0		; Else try again
;
dftbl:	db	13
	dw	df1
	db	'P'
	dw	outk0
	db	'F'
	dw	find
	db	'X'
	dw	qfind
	db	'.'
	dw	next
	db	'>'
	dw	next
	db	'<'
	dw	prev
	db	','
	dw	prev
	db	'K'
	dw	iskey
	db	'A'
	dw	outk0
	db	ctrll		; Repeat find
	dw	repsrch
	db	'S'
	dw	allbut
	db	'L'		; Repeat find
	dw	repsrch
	db	cr
	dw	output
;
allbut:	ld	(xclflg),a	; Set exclude flag
;
iskey:	call	lblkey		; Get key for selection
	ld	a,c		; Check for empty key
	or	a
	ret	z		; Yes, go try again
;
outk0:	call	gotop		; Set file pointer to beginning
;
	ld	a,(keyflg)
	cp	'K'		; Key search?
	jr	nz,stfil	; No, start writing file
;
outklp:	call	ckeoi
	jp	c,nofind
;
	call	rrinc		; Read next record, increment pointers
	call	findmatch
	jr	nz,outklp	; No match yet
;
; Set up and write output file
;
stfil:	ld	a,' '		; Pad filename buffer
	ld	hl,ofbuf
	ld	b,18
;
stplp:	ld	(hl),a
	inc	hl
	djnz	stplp
;
	ld	de,outfcb
	ld	hl,ofbuf
	call	zmvdfn		; Expand filename to message buffer
	ld	a,')'		; Plug in end parethesis
	ld	(hl),a
	call	clrmnu
	db	1,'Output filename (<RET>='
ofbuf:	dc	'                  >' ; Pad each time through
;
	ld	bc,1600h	; Initialize count, set max length of 21
	ld	hl,172bh	; Position cursor
	call	srchpad
	ld	hl,fnbuf	; Point to filename buffer
	call	getk0		; Get filename
	ret	c		; Exit if abort
	jr	z,stfil3	; None, use default
;
	inc	hl		; Point to first character
	push	hl		; Save pointer
	ld	b,0
	add	hl,bc		; Add length
	ld	(hl),0		; Terminate filename string for fnamz
	pop	hl		; Restore pointer
	call	atest		; Test for wildcards
	jr	z,badfn		; Yes, bad filespec
;
	push	hl		; Save buffer pointer
	call	dirtdu		; Check for named directory
	pop	hl		; Restore buffer pointer
	ld	de,outfcb
	jr	z,stfil0	; No, continue
;
	ld	a,':'		; Find colon
;
colp:	cp	(hl)		; Compare with colon
	inc	hl		; Point past it
	jr	z,stfil1	; Found
	jr	colp
;
stfil0:	ld	bc,0		; Kill passed du:
;
stfil1:	push	hl
	ld	hl,outfcb+12
	call	inifcb1		; Initialize fcb
	pop	hl
	call	fnamz		; Fill in fcb
	jr	z,badfn		; Error
;
	ld	a,(outfcb+1)
	cp	' '		; Must have some filename...
	jr	nz,stfil2	; Ok
;
badfn:	call	vprint
	dc	2,cr,lf,'  ',1,'Bad Filespec'
	call	pak		; Press any key message
	call	cin
	call	initfcb		; Reinitialize fcb
	jp	stfil		; And try again
;
stfil2:	ld	a,b
	or	c
	jr	z,stfil3	; BC=0, so we're done
;
	ld	a,b
	inc	a		; Make drive A=1
	ld	(de),a		; Save it
	ld	a,c
	ld	(outfcb+13),a	; Save user
;
stfil3:	call	stndend
	call	bpinit		; Initialize buffer pointer
	call	ofile		; Create file
	call	dwf		; Display writing file message
;
	ld	a,(fflag)
	cp	'W'
	jr	nz,keytst	; Skip date
;
; Start WSF file with current date
;
	ld	hl,today	; Get today's date
	ld	de,wsdatbf
	call	mdata1		; Save it in "January 1, 1991" form
	ld	hl,wsdatbf
;
wsdatlp:ld	a,(hl)
	inc	hl
	or	a
	jr	z,wsdat0
;
	call	fout
	jr	wsdatlp
;
wsdat0:	call	fcrlf
	call	fcrlf
;
keytst:	ld	a,(keyflg)
	cp	'K'		; Is this by key?
	jr	z,reclpa	; Write first matching record in ADR/CDF
;
; Write file
;
reclp:	ld	a,(keyflg)
	cp	true		; Done
	jp	z,dfdone
;
	cp	'P'
	jr	nz,reclp0	; Not current
;
	ld	a,true
	ld	(keyflg),a	; Set key flag for one pass
	jr	reclp1
;
reclp0:	call	ckeoi		; Check for end of index
	jp	c,dfdone	; Quit when done
;
	call	rrinc		; Read next record, increment pointers
	call	delrec		; Check for deleted records
	jr	z,reclp		; Skip them
;
	ld	a,(keyflg)	; Check for key flag
	cp	'K'
	jr	nz,unmatch	; No, check for excluded records
;
	call	findmatch
	jr	nz,reclp	; If no match, go to next record
;
reclpa:	ld	a,true		; If match, set fndflg to true
	ld	(fndflg),a
;
unmatch:ld	a,(xclflg)	; Check exclude flag
	or	a
	jr	z,reclp1	; No, write all records
;
	call	findmatch	; Find non-matching records
	jr	z,reclp0	; Write non-matching records
;
reclp1:	ld	hl,afpnl
	ld	b,11		; 11 fields for CDF and WSF files
	ld	a,(fflag)
	cp	'W'
	jr	z,reclp2	; Skip over first name field
;
	cp	'A'
	jr	nz,fldlp	; Not ADR
;
	ld	b,8		; 8 fields for ADR file
;
fldlp:	push	bc		; Save field count
	push	hl
	call	lhlhl
;
	ld	a,(fflag)
	cp	'W'
	jr	nz,fldlp0
;
	ld	a,(hl)
	or	a		; Is field empty?
	call	nz,wpstr	; No, move field in WSF format
	jr	efld
;
fldlp0:	cp	'A'
	jr	nz,fldlp2	; Not ADR
;
	ld	a,(hl)
	or	a		; Is field empty?
	jr	nz,fldlp1	; No
;
	ld	a,b		; Get field count
	cp	2		; ZIP?
	call	z,fcrlf		; Yes, add new line after empty ZIP
	jr	efld
;
fldlp1:	call	adstr		; Move field in ASCII address format
	jr	efld
;
fldlp2:	call	fpstr		; Move field in CDF format
;
efld:	ld	a,b		; Test field count
	dec	a
	jr	z,fdone
;
	ld	a,(fflag)	; Get filetype
	cp	'C'
	ld	a,','
	call	z,fout		; Add comma if CDF entry
	pop	hl
	pop	bc
;
reclp2:	inc	hl
	inc	hl
	djnz	fldlp
;
fdone:	ld	a,(fflag)
	cp	'C'		; CDF file?
	jr	nz,fdone0
;
	pop	hl
	inc	hl
	inc	hl
	push	hl		; Balance stack for exit
	call	lhlhl		; Get date pointer
;
; Move date to CDF file
;
	ld	a,','
	call	fout
	call	putquo		; Start with ,"
;
	ld	b,3
;
dtlp:	ld	a,(hl)
	inc	hl
	call	fa2hc
	djnz	dtsep
;
	call	putquo		; End with quote
	jr	fdone0
;
dtsep:	ld	a,'/'
	call	fout		; Separator
	jr	dtlp
;
fdone0:	call	fcrlf		; Append crlf
;
fdone1:	pop	hl
	pop	bc
	jp	reclp
;
; Append crlf
;
fcrlf:	ld	a,cr
	call	fout
	ld	a,lf
	jr	fout
;
dfdone:	call	fx$clo
	ld	a,(keyflg)	; Was file selected by key?
	cp	'K'
	jr	nz,dfdon0	; No, we're done
;
	xor	a		; Yes, reset flag
	ld	(keyflg),a
	ld	a,(fndflg)	; Any matching records found?
	or	a
	jp	z,nofind	; No, display not-found message
;
dfdon0:	jp	rcurr		; Yes, redisplay current record
;
; Move string in ADR format
;
adstr:	call	fstr		; Move string to file
	ld	a,b		; Get field number
	ld	de,adtbl
	jp	acase3
;
adtbl:	db	3		; 3 exceptions
	dw	fcrlf		; New line is default
	db	8
	dw	deflt		; Add space after FNAME
	db	4
	dw	deflt		; Add space after CITY
	db	3
	dw	deflt		; Add space after ST
;
fpstr:	call	putquo
;
fpstr1:	call	fstr		; Move string to file
;
putquo:	ld	a,'"'		; Fall thru to output quote
;
; Send byte in A to output file
;
fout:	push	hl		; Save record pointer
	push	af		; Save byte
	ld	hl,(bytenxt)	; Get pointer to next byte
	ld	de,(mem)	; See if byte will fit in buffer
	call	comphd
	call	nc,flushb	; Flush buffer to file if byte won't fit
	pop	af		; Restore byte
	ld	(hl),a		; Put it in buffer
	inc	hl		; Point to next byte
	ld	(bytenxt),hl	; Update buffer pointer
	pop	hl		; Restore record pointer
	ret
;
; Close output file, fill last record with EOF characters
;	Exit:  NZ if error in closing file
;
fx$clo:	ld	hl,(bytenxt)	; Get buffer pointer
	ld	a,l		; Done if on page boundary
	and	7fh
	jr	z,fxc0
;
	ld	(hl),eof	; Poke EOF char
	inc	hl
	ld	(bytenxt),hl	; Update pointer
	jr	fx$clo		; Loop until last record is full
;
fxc0:	call	flushb		; Flush buffers to disk
	ld	de,outfcb	; Get fcb address
	jp	f$close		; Close file and quit
;
; Flush buffer to disk and initialize for next write
;
flushb:	push	bc		; Save registers
	or	a		; Clear CARRY
	ld	hl,(bytenxt)	; Get next byte
	ld	de,(bufadr)	; Get start of buffer
	push	de		; Save buffer pointer
	sbc	hl,de		; Get length of buffer
;
	ld	bc,127		; Calculate number of records
	add	hl,bc
	add	hl,hl
	ld	c,h		; BC=number of records
;
nrecs:	pop	hl		; Restore buffer pointer
;
flblp:	call	setdma		; Set dma
	ld	de,outfcb	; Point to fcb
	call	f$write		; Write next record
	jp	nz,wrterr	; Quit if write error
;
	ld	de,128		; Get record length
	add	hl,de		; Point to next record
	dec	bc		; Count down
	ld	a,b
	or	c
	jr	nz,flblp	; Loop to write all records
;
	pop	bc		; Restore BC
;
; Initialize file output buffer byte pointer
;
bpinit:	ld	hl,(bufadr)	; Point to start of buffer
	jp	bpnew		; And save new pointer
;
; Create output file
;
ofile:	ld	hl,cmdbuf	; Set dma to command buffer
	call	setdma
	ld	a,(outfcb+13)	; Get output file user
	and	7fh		; Filter it
	ld	e,a
	ld	c,gsusr		; Set user
	call	bdos
	ld	de,outfcb	; Point to output FCB
	call	f$exist		; Check for existing file
	jr	z,mopen		; None, continue
;
felp:	call	clrmnu
	dc	1,bel,'File Already Exists - A=Append  O=Overwrite '
	call	qquit
	call	capin
	cp	'O'
	cp	'A'
	jr	z,aopen		; Open for appending
	cp	'O'
	jr	z,oopen		; Overwrite
	pop	hl		; Discard return address
	call	qmret		; Test for common return exit commands
	ret	z
	push	hl		; Restore return address
	jr	felp
;
aopen:	ld	hl,(bufadr)	; Get buffer address
	push	hl
	call	setdma		; Set dma
	call	f$appl		; Open file for appending
;
; Scan last record of append file for EOF, set buffer pointer
;
	pop	hl		; Point to buffer
	ld	b,128		; Only look at first record
;
splp:	ld	a,(hl)		; Get byte
	or	a		; Check for empty record
	jr	z,bpnew		; Save new pointer
	cp	eof		; Check for EOF
	jr	z,bpnew		; Save new pointer
	inc	hl
	djnz	splp
;
bpnew:	ld	(bytenxt),hl	; Save as next byte pointer
	ret
;
oopen:	call	f$delete	; Delete existing file
;
mopen:	call	f$mopen		; Open and/or create file
	jp	nz,nogood	; Error - no directory space
;
wpstr2:	ret			; Table address for RET instruction
;
; Output BCD date in A as two ASCII bytes
;
fa2hc:	push	af		; Save A
	rrca			; Exchange nybbles
	rrca
	rrca
	rrca
	call	fahc		; Output low-order nybble as hex
	pop	af		; Restore A and fall thru
;
fahc:	and	0fh		; Mask for low nybble
	add	'0'		; Convert to '0'-'9'
	jp	fout		; Print
;
; Move 0-terminated string to file buffer
;
fstr:	ld	a,(hl)		; Get character
	inc	hl		; Point to next
	or	a
	ret	z		; Quit at first null
;
	call	fout		; Move character
	jr	fstr
;
; Write string to file
;
wpstr:	call	fstr		; Move string to file
	ld	a,b		; Get field number
	ld	de,wstbl
	jp	acase3
;
wstbl:	db	5
	dw	deflt
	db	10
	dw	addfst
	db	9
	dw	punct
	db	8
	dw	punct
	db	7
	dw	punct
	db	1
	dw	wpstr2
;
addfst:	call	punct
	ld	hl,fstnm
;
addfst0:call	fstr		; Move string to file
;
punct:	ld	a,','
	call	fout
;
deflt:	ld	a,' '
	jp	fout
;
dwf:	call	clrmnu
	dc	1,'Writing File '
;
	call	zprdfn
	jp	stndend
;
; Initialize buffers for file output
;
ioinit:	call	chkmem		; Check for adequate memory space
	jr	c,nomem
;
	ld	l,0
	push	hl		; Save top of memory
	ld	(mem),hl	; Save top of buffer
	ld	de,4000h
	sbc	hl,de
	pop	de		; Restore top of memory
	call	comphd		; Carry set if TOB<TOM
	jr	c,initfcb	; Continue
;
nomem:	call	clrmnu
	dc	bel,1,'Not Enough Memory'
	call	pak		; Press any key message
	pop	hl
	jp	cin
;
initfcb:ld	hl,fcb+1	; Get default datafile name
	ld	de,outfcb+1	; Point to io filename
	ld	bc,8
	ldir			; Move name to fcb
;
	ld	a,(fflag)	; Add appropriate filetype
	ld	hl,adrtyp
	cp	'A'
	jr	z,inifcb0	; ASCII address filetype
;
	ld	hl,cdftyp
	cp	'C'
	jr	z,inifcb0	; CDF filetype
;
	ld	hl,wstyp	; WSF filetype
;
inifcb0:ld	bc,3
	ldir
;
	ex	de,hl
;
inifcb1:ld	b,24		; Zero the back end of the fcb
	jp	fillz
;
; Test buffer at HL for C bytes for character in A
;
atest:	ld	b,0		; Count in C
	push	bc		; Save count
	ld	a,'*'		; Test for '*'
	call	wcpir
	pop	bc		; Restore count for next test
	ret	z		; Bad filespec
;
	ld	a,'?'		; Test for '?'
;
wcpir:	push	hl
	cpir
	pop	hl
	ret
;
; Move filename pointed to by DE to buffer pointed to by HL
;
mfn2:	ld	b,8		; Move filename
	call	prfnx
	ld	(hl),'.'	; Store period in buffer
	inc	hl		; Point to next
	ld	b,3		; Move filetype
;
prfnx:	ld	a,(de)		; Get character
	and	7fh		; Filter out hi bit
	cp	' '		; Space?
	jr	z,prfnx9	; Yes, quit
;
	ld	(hl),a		; Store character in buffer
	inc	hl		; Point to next
;
prfnx9:	inc	de		; Point to next
	djnz	prfnx
	ret
;
; End of ZDB.F
;
