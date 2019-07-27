
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
	title	inlin basic interpreter input line routine/whg/pga/mbm, etc.
	;subttl	inlin - line input routine
	public	inlin,qinlin
	extrn	fininl
	extrn	buf,crdo,inchr,outdo
	extrn	lisprt
	extrn	ctrlpt


; this is the line input routine
; it reads characters into buf using _ as the
; character delete character and @ as the line delete character
; if more than buflen character are typed, no echoing
; is done until a  _ @ or carriage-return is typed.
; control-g will be typed for each extra character.
; the routine is entered at inlin, at qinlin to type a question mark
; and a space first

qinlin:	ld	a,'?'		;get a qmark
	call	outdo		;type it
	ld	a,' '		;space
	call	outdo		;type it too
	jp	inlin		;no crunching in this case
inlinc:	call	inchr		;get a char
	cp	1		;control a?
	jp	nz,inlnc1	;no, treat normally
	ld	(hl),0		;save terminator
	jp	inled1		;go edit from here

inlinq:	ld	(hl),b		;store zero in buf
inlin:
	xor	a		;clear type ahead char
	extrn	charc
	ld	(charc),a	;like so
	public	sinlin
	extrn	tempa
	xor	a
	ld	(tempa),a	;flag to do cr
sinlin:
				;save current cursor address (ttypos)
	call	inchr		;get char
	cp	1		;control-a?
	jp	nz,inlins	;go do it
inled1:
	call	crdo		;type crlf
	ld	hl,0+65535	;get special line #
	extrn	inled
	jp	inled		;go to edit code.
				;get char
rubout:
	extrn	rubsw
	ld	a,(rubsw)	;are we already rubbing out?
	or	a		;set cc'S
	ld	a,'\'		;get ready to type backslash
	ld	(rubsw),a	;make rubsw non-zero if not already
	jp	nz,notbeg	;not rubbing back to beggining
	dec	b		;at beginning of line?
	jp	z,inlinq	;set first byte in buf to zero
	call	outdo		;send backslash
	inc	b		;effectively skip next instruction
notbeg:	dec	b		;back up char count by 1
	dec	hl		;and line posit
	jp	z,inlinn	;and re-set up input
	ld	a,(hl)		;otherwise get char to echo
	call	outdo		;send it
	jp	inlinc		;and get next char

linlin:	dec	b		;back arrow so decrement count
linln2:	dec	hl		;back up pointer
	call	outdo
	jp	nz,inlinc	;not too many so continue
inlinn:	call	outdo		;print the @, or a second _ if there
				;were too many
inlinu:	call	crdo		;type a crlf
inlins:	ld	hl,buf
	ld	b,1		;character count
	push	af
	xor	a		;always clear rubout switch
	ld	(rubsw),a	;by storing in
	pop	af
inlnc1:
	ld	c,a		;save current char in [c]
	cp	177o		;character delete?
	jp	z,rubout	;do it
	ld	a,(rubsw)	;been doing a rubout?
	or	a		;set cc'S
	jp	z,notrub	;nope.
	ld	a,'\'		;get ready to type slash
	call	outdo		;send it
	xor	a		;clear rubsw
	ld	(rubsw),a	;like so.
notrub:	ld	a,c		;get back current char
	cp	7		;is it bob albrecht ringing the bell
	jp	z,goodch	;for school kids?
	cp	3		;control-c?

	call	z,ctrlpt	;type ^ followed by char, and crlf
	scf			;return with carry on
	ret	z		;if it was control-c
	cp	13		;is it a carriage return?
	jp	z,gfninl
	cp	9		;tab?
	jp	z,goodch	;save it
	cp	10		;lf?
	jp	nz,chkfun	;no, see if funny char
	dec	b		;see if only char on line
	jp	z,inlin		;it is, ignore
	inc	b		;restore b
	jp	goodch		;is lf and not null line
chkfun:
	cp	'U'-100o	;line delete? (control-u)
	call	z,ctrlpt	;print ^u
	jp	z,inlin
	cp	8		;backspace? (control-h)?
	jp	nz,ntbksp	;no
drbksp:	dec	b		;at start of line?
	jp	z,sinlin
	call	outdo		;send backspace
	ld	a,' '		;send space to wipe out char
	call	outdo
	ld	a,8		;send another backspace
	jp	linln2
ntbksp:
	cp	24		;is it control-x (line delete)
	jp	nz,ntctlx	;no
	ld	a,'#'		;send number sign
	jp	inlinn		;send # sign and echo
ntctlx:
	cp	18		;control-r?
	jp	nz,ntctlr	;no
	push	bc		;save [b,c]
	push	de		;save [d,e]
	push	hl		;save [h,l]
	ld	(hl),0		;store terminator
	call	crdo		;do crlf
	ld	hl,buf		;point to start of buffer
	call	lisprt		;handle line-feeds properly
	pop	hl		;restore [h,l]
	pop	de		;restore [d,e]
	pop	bc		;restore [b,c]
	jp	inlinc		;get next char
ntctlr:
	cp	32		;check for funny characters
	jp	c,inlinc
				;philips must echo controls
goodch:	ld	a,b		;get current length
				;*** special check if buffer 255 long for len2
	inc	a		;bump line length
	extrn	ptrfil,linget,curlin
	jp	nz,outbnd	;no cause for bell
	push	hl		;save [h,l]
	ld	hl,(ptrfil)	;see if reading from disk
	ld	a,h		;by testing for ptrfil
	or	l		;non-zero
	pop	hl		;restore [h,l]
	ld	a,7		;get bell char
	jp	z,outbel	;not reading from disk, send bell
	ld	hl,buf		;make [h,l] point to buff
	call	linget		;get line number
	ex	de,hl		;get line # in [h,l]
	ld	(curlin),hl	;save in current line #
	extrn	error
	extrn	lboerr
	jp	lboerr		;give line buffer overflow error
outbnd:
	ld	a,c		;restore  current character into [a]
	ld	(hl),c		;store this character
	inc	hl		;bump pointer into buf
	inc	b		;increment character count
outbel:
	call	outdo		;send the char
				;send char
	sub	10		;lf??
	jp	nz,inlinc	;no, get next char
	extrn	ttypos
	ld	(ttypos),a	;make sure ttypos=0.
				;make sure ttypos=0
	ld	a,13		;send cr.
	call	outdo		;by calling outchr
eatnul:	call	inchr		;eat next char
	or	a		;null after lf?
	jp	z,eatnul	;dont let it get by
	cp	13		;a carriage return??
	jp	z,inlinc	;eat it & get next char
	jp	inlnc1		;use it
				;must echo the char
	page
	extrn	tempa
	public	scnsem
	extrn	chrgtr,bufmin
gfninl:
	ld	a,(tempa)	;do cr or not?
	or	a		;test
	jp	z,fininl	;yes
	xor	a		;make zero
	ld	(hl),a		;store terminator
	ld	hl,bufmin	;get pointer to start of buf
	ret			;done

scnsem:	push	af		;save char
	ld	a,0		;assume no semi
	ld	(tempa),a
	pop	af		;get back char
	cp	';'		;is it a semi?
	ret	nz		;no
	ld	(tempa),a	;flag no cr from inlin
	jp	chrgtr
;	end

