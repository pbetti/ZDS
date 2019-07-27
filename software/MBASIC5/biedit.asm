
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
	title	biedit	basic interpreter edit routines/pga etc.
	;subttl	edit command
;
;
;[c] contains count of characters in line
;[b] contains current character position 0=first in line.
;[d] contains number of times to repeat this subcommand
;[h,l] point to current character
;
;*
	public	erredt,edit,editrt,popart
	extrn	buf,buflin,crdo,dot,edent,errflg,fininl,fndlin,inchri,outch1
	extrn	linprt,linspc,lisprt,makups,outdo,pophrt,ready,userr
	extrn	bltuc,errlin
erredt:	ld	(errflg),a	;reset the flag to call edit
	ld	hl,(errlin)	;get the line number
	or	h		;see if it was direct
	and	l
	inc	a		;set zero flag on direct
	ex	de,hl		;line number into [d,e]
	ret	z		;go back if direct
	jp	eredit
edit:	call	linspc		;get the argument line number
	ret	nz		;error if not end of line
eredit:	pop	hl		;get rid of newstt address
eedits:	ex	de,hl		;save current line in dot
	ld	(dot),hl	;for later edit or list
	ex	de,hl		;get back line # in [h,l]
	call	fndlin		;find the line in question
	jp	nc,userr	;if not found, undefined statement error.
	ld	h,b		;ponter to line is in [b,c]
	ld	l,c		;transfer it to [h,l]
	inc	hl		;pass over pointer to next line
	inc	hl		;like so.
	ld	c,(hl)		;get first byte of line #
	inc	hl		;move to 2nd byte
	ld	b,(hl)		;pick it up into b
	inc	hl		;advance to point to first byte of line
	push	bc		;save line # on stack
	call	buflin		;unpack line into buf
	public	inled
lled:	pop	hl		;get back line #
inled:	push	hl		;save it back on stack
	ld	a,h		;test for double byte zero
	and	l
	inc	a
	ld	a,'!'		;get prompt for direct edit
	call	z,outdo		;send it
	call	nz,linprt	;print line # if not inlin edit
	ld	a,' '		;type a space
	call	outdo		;...
	ld	hl,buf		;get start of buf in [h,l]
	push	hl		;save [h,l] while we calc line length
	ld	c,255		;assume 0 char line
lenlp:	inc	c		;bump count of chars
	ld	a,(hl)		;get char from line
	inc	hl		;bump pointer
	or	a
	jp	nz,lenlp	;if not zero (end of line) keep counting...
	pop	hl		;get back pointer to line
	ld	b,a		;set current line posit to zero
disped:	ld	d,0		;assume repition count is zero
dispi:
	call	inchri		;get a char from user
	or	a		;ignore nulls
	jp	z,dispi
	call	makups		;make upper case command
	sub	'0'		;get rid of offset
	jp	c,notdgi	;...
	cp	10
	jp	nc,notdgi
	ld	e,a		;save char
	ld	a,d		;get accum repitition
	rlca			;multiply by 2
	rlca			;by 4
	add	a,d		;and add to get 5*d
	rlca			;*2 to get 10*d
	add	a,e		;add digit
	ld	d,a		;save back new accum
	jp	dispi		;get next char

notdgi:	push	hl		;save text pointer
	ld	hl,disped	;put return address to disped
	ex	(sp),hl		;on the stack
	dec	d		;see if d=0 (rep factor)
	inc	d		;set condition codes
	jp	nz,ntzerd	;branch around
	inc	d		;make it 1
ntzerd:
	cp	8-'0'		;backspace?
	jp	z,baked		;handle it
	cp	177o-'0'	;del?
	jp	z,deled		;backspace pointer
	cp	13-'0'		;carriage return
	jp	z,cred		;done editing
	cp	' '-'0'		;space
	jp	z,sped		;go to routine
	cp	'A'+40o-'0'	;command in lower case?
	jp	c,notlw4	;no, so ok.
	sub	40o		;convert to upper case
notlw4:	cp	'Q'-'0'		;quit?
	jp	z,qed		;if so, quit & print "OK" or return to inlin
	cp	'L'-'0'		;l?
	jp	z,led		;branch
	cp	'S'-'0'		;s?
	jp	z,sed		;search
	cp	'I'-'0'		;i?
	jp	z,ied		;insert
	cp	'D'-'0'		;d?
	jp	z,ded		;delete
	cp	'C'-'0'		;c?
	jp	z,ced		;change
	cp	'E'-'0'		;end?
	jp	z,eed		;(same as <cr> but doesnt print rest)
	cp	'X'-'0'		;extend?
	jp	z,xed		;go to end of line & insert
	cp	'K'-'0'		;kill??
	jp	z,ked		;(same as "S" but deletes chars)
	cp	'H'-'0'		;hack??
	jp	z,hed		;hack off the rest of the line & insert
	cp	'A'-'0'		;again??
	ld	a,7		;get ready to type bel.
	jp	nz,outdo	;no match, send bel and return to dispatcher
	pop	bc		;dispi return address
	pop	de		;line number into [d,e]
	call	crdo		;type a carriage return line-feed
	jp	eedits		;restart editing

sped:	ld	a,(hl)		;get char from curent posit
	or	a		;are we at end of line?
	ret	z		;if so, return
	inc	b		;bump current position
	call	outch1		;type character
	inc	hl		;move pointer to next char
	dec	d		;test if done with repititions
	jp	nz,sped		;repeat
	ret			;return to dispatcher

ked:	push	hl		;save current char posit
	ld	hl,typslh	;type slash when done
	ex	(sp),hl		;put it on stack & get posit back
	scf			;set the carry flag
sed:	push	af		;save condition codes
	call	inchri		;get search char
	ld	e,a		;save it
	pop	af
	push	af
	call	c,typslh	;type beginning slash for "K"
srcalp:	ld	a,(hl)
	or	a
	jp	z,popart
	call	outch1		;type the char
	pop	af		;get kill flag
	push	af		;save back
	call	c,delchr	;delete the char if k command.
	jp	c,notsrc	;and dont move pointer as delchr already did
	inc	hl
	inc	b		;increment line posit
notsrc:	ld	a,(hl)		;are we at end
	cp	e		;are current char & search
	jp	nz,srcalp	;char the same? if not, look more
	dec	d		;look for n matches
	jp	nz,srcalp	;if not 0, keep looking

popart:	pop	af		;get rid of kill flag
	ret			;done searching
led:	call	lisprt		;type rest of line
	call	crdo		;type carriage return
	pop	bc		;get rid of return to disped
	jp	lled		;go to main code

ded:	ld	a,(hl)		;get char which we are trying to delete
	or	a		;is it the end of line marker?
	ret	z		;done if so
	ld	a,'\'		;type backslash
	call	outch1		;like so
dellp:	ld	a,(hl)		;get char from line
	or	a		;are we at end?
	jp	z,typslh	;type slash
	call	outch1		;type char we'RE GOING TO DELETE
	call	delchr		;delete current char
	dec	d		;decrement delete count
	jp	nz,dellp	;keep doing it
typslh:
	ld	a,'\'		;type ending slash
	call	outdo		;like so
	ret

ced:	ld	a,(hl)		;are we at end of line?
	or	a		;see if 0
	ret	z		;return
ced2:	call	inchri		;get char to replace char
	cp	32		;is it control char?
	jp	nc,notccc	;no
	cp	10		;is it lf?
	jp	z,notccc	;yes
	cp	7		;or bell?
	jp	z,notccc	;ok
	cp	9		;or tab?
	jp	z,notccc	;ok
	ld	a,7		;get bell
	call	outdo		;send it
	jp	ced2		;retry
notccc:	ld	(hl),a		;save in memory
	call	outch1		;echo the char were using to replace
	inc	hl		;bump pointer
	inc	b		;increment position within line
	dec	d		;are we done changing?
	jp	nz,ced		;if not, change some more.
	ret			;done
hed:	ld	(hl),0		;make line end at current position
	ld	c,b		;set up line length correctly

xed:	ld	d,255		;find end of line
	call	sped		;by calling spacer
;now fall into insert code
ied:
	call	inchri		;get char to insert

	cp	177o		;delete??
	jp	z,typarw	;yes, act like "_"
	cp	8		;backspace?
	jp	z,typar1	;do delete
	cp	15o		;is it a carriage return?
	jp	z,cred		;dont insert, and simulate <cr>
	cp	33o		;is it escape?
	ret	z		;if so, done.
	cp	8		;backspace?
	jp	z,typar1	;type backarrow and delete
	cp	10		;line feed?
	jp	z,ntarrw	;allow it
	cp	7		;bell?
	jp	z,ntarrw	;allow it
	cp	9		;tab?
	jp	z,ntarrw	;allow it
	cp	32		;is it illegal char
	jp	c,ied		;too small
	cp	'_'		;delete previous char inserted?
	jp	nz,ntarrw	;if not, jump around next code
typarw:
	ld	a,'_'		;type it
typar1:	dec	b		;are we at start of line?
	inc	b		;lets see
	jp	z,dingi		;if so, type ding.
	call	outch1		;type the back arrow
	dec	hl		;back up the pointer
	dec	b		;move back posit in line
	ld	de,ied		;set up return address
	push	de		;save it  on stack & fall through
; subroutine to delete char pointed to by [h,l]. corrects c.
delchr:	push	hl		;save current posit pointer
	dec	c		;make length of line one less
cmprss:	ld	a,(hl)		;get char to delete
	or	a		;are we at end of line
	scf			;flag that delchr was called (for k)
	jp	z,pophrt	;if so, done compressing
	inc	hl		;point to next byte
	ld	a,(hl)		;pick it up
	dec	hl		;now back again
	ld	(hl),a		;deposit it
	inc	hl		;now to next byte
	jp	cmprss		;keep crunching
ntarrw:	push	af		;save the char to be inserted
	ld	a,c		;get length of line
	cp	buflen		;see if we arent trying to make line too long
	jp	c,okins		;if length ok, go insert
	pop	af		;get the unlawful char
dingi:
	ld	a,7		;type a bell to let user know
	call	outdo		;it all over
iedg:	jp	ied		;he has to type <esc> to get out
okins:	sub	b		;calc pointer to 0 at end of line
	inc	c		;we are going to have line longer by 1
	inc	b		;position moves up one also
	push	bc		;save [b,c]
	ex	de,hl		;save [d,e] in [h,l]
	ld	l,a		;save # of bytes to move in [l]
	ld	h,0		;get set to add [d,e] to [h,l]
	add	hl,de		;calc high pointer
	ld	b,h		;get high byte to move pointer
	ld	c,l		;in [b,c]
	inc	hl		;always move at least zero at end
	call	bltuc		;move line out 1 char
	pop	bc		;restore [b,c]
	pop	af		;get char back
	ld	(hl),a		;save it in line
	call	outch1		;type the char
	inc	hl		;point to next char
	jp	iedg		;and go get more chars

baked:	ld	a,b		;are we moving back past the
	or	a		;first character
	ret	z		;don'T ALLOW IT
	dec	hl		;move char pointer back
	ld	a,8
	call	outch1		;echo it
	dec	b		;change current position
	dec	d		;are we done moving back?
	jp	nz,deled	;if not, go back more
	ret			;return

deled:	ld	a,b		;are we moving back past the
	or	a		;first character
	ret	z		;don'T ALLOW IT
	dec	b		;change current position
	dec	hl		;move char pointer back
	ld	a,(hl)		;get current char
	call	outch1		;echo it
	dec	d		;are we done moving back?
	jp	nz,deled	;if not, go back more
	ret			;return

cred:	call	lisprt		;type rest of line
eed:	call	crdo		;type carriage return
	pop	bc		;get rid of disped address
	pop	de		;get line # off stack
	ld	a,d		;double byte zero.
	and	e
	inc	a		;set zero if [d,e] = all ones.
editrt:	;used by auto code
	ld	hl,buf-1	;start krunching at buf
	ret	z		;return to inlin if called from there
	scf			;flag line # was seen to fool insert code
	push	af		;psw is on stack
	inc	hl		;now point at buf.
	jp	edent		;go to entry point in main code

qed:	pop	bc		;get rid of disped address
	pop	de		;get line # off stack
	ld	a,d		;double byte zero.
	and	e
	inc	a		;set zero if [d,e] = all ones.
	jp	z,fininl	;type cr and store zero in buf.
	jp	ready		;otherwise called from main
;	end
