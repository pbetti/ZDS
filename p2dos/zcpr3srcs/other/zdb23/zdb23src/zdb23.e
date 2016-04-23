;
; ZDB23.E - Editing Module
;
; Routines for adding, editing, and deleting records
;
edit:	xor	a		; Edit existing data record
	ld	(newflg),a
	call	decfptr
	call	edita
	jp	wrecs		; Write data record and resort index
;
; Add a new record
;
new:	call	chkmem		; Check to see if enough memory left
	jp	c,nomem		; Out of memory, jump to out of memory message
;
	call	iniblk		; Initialize edblk
	call	displa		; Display it
	ld	a,true		; Set "new" flag
	ld	(newflg),a
;
edita:	call	clkfnd		; Update time
	ld	hl,today	; Get date from buffer
	ld	de,datmod	; And move to datmod
	ld	bc,3
	ldir
	call	newdat		; Get the date and display it
;
	call	gxymsg
	db	23,1,1
	db	'^S/^D=Char<> ^V=InsertTog   ^G/^T=EraChar/Word  '
	db	' ^R=Copy<Buff    ^Q=Quit/NoSave'
	db	2,cr,lf,1
	db	'^A/^F=Word<> ^E/^X=Field<>     ^Y=EraCursor>    '
	db	' ^C=Copy>Buff  ^W/ESC=Exit/Save'
	dc	2
;
edflds:	ld	hl,pospanel	; Point to cursor position panel
	ld	de,afpnl	; Point to field address panel
	ld	b,(hl)		; Number of fields
	inc	hl
;
efloop:	ld	a,(hl)		; Save row position
	ld	(lpos),a
	call	@goxy		; Position cursor
	push	bc		; Save count
	ld	b,(hl)		; Get field length
	dec	hl		; Save column position
	ld	a,(hl)
	ld	(cpos),a
	inc	hl		; Point to next field
	inc	hl
	ex	de,hl		; Hl=field address
	push	hl
	call	lhlhl		; Get field pointer in hl
	push	de
	call	edloop		; Edit field
	pop	de
	pop	hl
	inc	hl		; Point to next field address
	inc	hl
	ex	de,hl		; Hl=next field cursor position
	pop	bc
	cp	esc		; Quit edloop?
	jr	z,term		; Yes, go to end
	cp	ctrlw		; ^W same as esc
	jr	z,term
	cp	ctrlq		; ^Q to quit without saving edit
	jr	z,term
	cp	ctrle		; If ^e, go to previous field
	jr	z,prevf
	djnz	efloop		; Else do next field
	jr	term		; Done
;
prevf:	or	a		; Clear carry
	push	bc		; Save count
	ld	bc,6		; Back up to previous field cursor pos
	sbc	hl,bc
	ex	de,hl
	ld	bc,4		; Back up to previous field
	sbc	hl,bc
	ex	de,hl
	pop	bc		; Restore count
	inc	b		; Back up one field
	ld	a,(pospanel)	; Get number of fields
	cp	b		; Test for first field
	jr	nc,efloop	; Loop or fall thru if past first field
;
term:	push	af
	call	delins		; Delete insert msg
	pop	af
	cp	ctrlq		; Exit without saving?
	jr	nz,term1
;
term0:	ld	a,(newflg)	; Editing an existing record?
	or	a
	jr	nz,xadd		; Add abort
;
	pop	hl		; If edit abort, discard return address
	call	incfptr		; Increment one data record
	call	incfptr
	jr	xedit
;
xadd:	call	ckdel		; Quit if no non-deleted records
;
xedit:	call	getrp		; Update current record/count display
	jp	menu
;
term1:	call	clrmnu
	dc	1,'TAB=Edit  Q=Quit  [RET=SAVE] ?',2,bs
term2:	call	capin
	cp	tab
	jp	z,edita
	cp	'Q'
	jr	z,term0
	cp	cr
	jr	z,term3
	call	beep
	jr	term2
;
term3:	call	curoff
	ld	a,(newflg)	; Editing an existing record?
	or	a
	ret	z		; Yes, we're done here
;
	ld	hl,(recs)	; Get number of index records
	ld	(xfptr),hl	; Save it for updinx and to
	ld	(fptr),hl	; Keep track of appended records
	ld	hl,(n)
	ld	(count),hl	; Save number of index records
	call	rwrtblk
;
	call	updinx		; Add new key to index table
	call	inxsrt		; Rebuild order table and sort index
	ld	hl,(recs)	; Increment record count
	inc	hl
	inc	hl
	ld	(recs),hl
;
	call	curtim		; Update time
	call	getrp
	call	clrmnu
	dc	1,'Add another record? [Y]/n ?',2,bs
	call	getchar
	cp	'N'
	jp	nz,new
	ret
;
; Edloop is a fairly complete line editor, using WordStar-like
; editing commands.
; Entry:HL=line buffer pointer
;	B =max number of characters
; ESC will exit at any point and take you back to the calling routine.
; ^Q aborts edit.
;
edloop:	call	curon
	xor	a
	ld	(capflag),a	; Set cap flag to no
	ld	c,a		; Initialize character count
	ld	a,b		; Get count
	cp	3		; State?
	jr	nz,edlp1	; No
;
edlp0:	ld	(capflag),a	; Set caps flag
;
edlp1:	ld	a,(capflag)	; Check caps flag
	or	a
	jr	z,edlp2		; Get exact input
;
	call	capin		; Get caps input
	jr	edlp3
;
edlp2:	call	cin		; Get character
;
edlp3:	call	isctrl		; Is it a control character?
	jr	z,edcase	; Yes
;
alpha:	push	af		; No
	inc	c
	ld	a,c		; Check to see if you've reached the maximum
	cp	b		; Number of characters
	jr	z,noroom
;
	call	stndout
	ld	a,(insflg)	; Check for insert mode
	or	a
	jr	z,alpha1	; No
;
	push	hl		; Save string pointer
	push	bc		; Save counter
	ld	a,b		; Get max characters
	sub	c		; Find number of characters to move
	dec	a
	or	a
	jr	z,alpha0
;
	ld	c,a
	ld	b,0
	add	hl,bc		; Hl = last byte in string
	ld	d,h		; De points to character destination
	ld	e,l
	dec	hl		; Hl points to character
	lddr			; Shift line right
	inc	hl
	call	vpstr		; Display shifted line
;
alpha0:	pop	bc		; Restore counter
	pop	hl		; Restore string pointer
	call	movcur		; Restore cursor
;
alpha1:	pop	af
	ld	(hl),a		; Add to string
	inc	hl		; Update string pointer
	call	cout		; Handle alphanumeric characters normally
	call	stndend
	call	currt		; Update cursor position
	jr	edlp1		; Get next character
;
noroom:	pop	af
	call	beep
	dec	c
	jr	edlp1
;
; Parse edloop command table
;
edcase:	ld	de,edtbl
	call	acase3
	jr	edlp1		; Return from match routines
;
eddunx:	scf			; Set CARRY to indicate abort
;
eddun:	pop	iy		; Discard local return address
	ret
;
edtbl:	db	19		; Number of cases
	dw	termky		; No other match
	db	esc		; Esc - finish add/edit
	dw	eddunx
	db	ctrlw		; ^W same as esc
	dw	eddunx
	db	ctrlq		; ^Q to exit without saving edit
	dw	eddunx
	db	ctrle		; ^E - move to previous field
	dw	eddun
	db	cr		; Cr - next field
	dw	eddun
	db	tab		; Tab - next field
	dw	eddun
	db	ctrlx		; ^X - next field
	dw	eddun
	db	ctrlg		; ^G - delete character at cursor, shift
	dw	delchr		; Rest of line left
	db	ctrlt		; ^T - delete word right
	dw	delwrt
	db	ctrlv		; ^V - toggle insert character mode
	dw	insert
	db	ctrly		; ^Y -- erases from cursor to end of line
	dw	eralin
	db	del		; Delete - same as ^G
	dw	delchr
	db	ctrls		; ^S - cursor left
	dw	lcurs		; BS - cursor left
	db	bs		; ^H - cursor left
	dw	lcurs
	db	ctrld		; ^D - cursor right
	dw	rcurs
	db	ctrla		; ^A - word left
	dw	wrdlft
	db	ctrlf		; ^F - word right
	dw	wrdrt
	db	ctrlc		; ^C - copy entire edblk to copy buffer
	dw	cpyblk
	db	ctrlr		; ^R - copy from buffer to edblk
	dw	ditto
;
; Check for terminal arrow keys
;
termky:	push	hl		; Save pointer
	ld	hl,(tcap)	; Get tcap address
	cp	(hl)		; Is it up arrow?
	jr	nz,termky0	; No, jump
;
	ld	a,ctrle		; Yes, convert to ^E and quit
	pop	hl
	jr	eddun
;
termky0:inc	hl		; Move to next char in tcap
	cp	(hl)		; Is it down arrow?
	jr	nz,termky1	; No, try next one
;
	pop	hl		; Yes, quit
	jr	eddun
;
termky1:inc	hl		; Move to next char in tcap
	cp	(hl)		; Is it right arrow?
	jr	nz,termky2	; Now, try next one
;
	pop	hl		; Yes, jump to rcurs
	jr	rcurs
;
termky2:inc	hl		; Move to next char in tcap
	cp	(hl)		; Is it left arrow?
	jr	nz,akdun	; No, quit
;
	pop	hl		; Yes, jump to lcurs
	jr	lcurs
;
akdun:	pop	hl		; Restore pointer
	jp	beep
;
; Move cursor left
;
lcurs:	xor	a
	cp	c		; If c=0, beep
	jp	z,beep		; And quit
	dec	c		; Else decrement character count
	dec	hl		; Move pointer
	jr	curlf		; Decrement cursor position
;
insert:	ld	a,(insflg)
	cpl
	ld	(insflg),a
	or	a		; Set?
	jr	z,delins	; Cancel insert msg
;
	call	gxymsg
	db	01,40,1,'Ins',2,0 ; Insert message
	jr	movcur		; Restore cursor
;
delchr:	push	hl		; Save cursor position
	push	bc		; Save count
	call	stndout
	ld	d,h
	ld	e,l		; Position in de
	inc	hl		; Point to next character
;
dellp:	ld	a,(hl)		; Get next character
	ldi			; Move it
	call	cout		; Display it
	or	a		; Check for end of field
	jr	nz,dellp
;
deldun:	ld	a,' '
	call	cout		; Cover last moved character
	call	stndend
	pop	bc		; Restore count
	pop	hl		; Restore cursor position and fall thru
;
movcur:	push	hl		; Move cursor to position stored
	ld	hl,(cpos)	; In cpos
	call	gotoxy
	pop	hl
	ret
;
delwrt:	ld	a,(hl)		; Delete word right (^T)
	cp	' '		; If a=space, delete it and quit
	jr	z,delchr
;
	or	a		; Quit if a=null
	ret	z
;
	call	delchr		; Otherwise delete character and repeat
	jr	delwrt
;
delins:	xor	a		; Delete insert msg and reset flag
	ld	(insflg),a
	call	gxymsg
	db	01,40,1,'   ',2,0
	jr	movcur
;
; Move cursor right
;
rcurs:	xor	a		; Check character at pointer (before it's
	cp	(hl)		; Incremented).  Null (end of string)?
	jp	z,beep		; Yes, so beep and quit
;
	inc	c		; No, so bump character count
	inc	hl		; Increment pointer
;
currt:	push	hl		; Increment cursor location in cpos
	ld	hl,(cpos)
	inc	l
	jr	svcur
;
curlf:	push	hl		; Decrement cursor location in cpos
	ld	hl,(cpos)
	dec	l
;
svcur:	ld	(cpos),hl
	pop	hl
	jr	movcur
;
; Erase from cursor to end of line
;
eralin:	push	bc		; Save bc
	ld	a,b
	sub	a,c		; How many spaces to end of field?
	ld	b,a		; Number of spaces to underscore
	push	bc		; Save count
	call	pad
	pop	bc		; Restore count
	push	hl		; Save field pointer
	call	fillz		; Fill remainder of field with 0's
	pop	hl		; Restore field pointer
	pop	bc
	jr	movcur		; Restore cursor to original position
;
wrdlft:	call	lcurs		; Move one char left
;
wrdlf0:	xor	a
	cp	c		; If count = 0, stop
	ret	z
	call	lcurs		; Move again until space character found
	ld	a,' '
	cp	(hl)		; If char=space, move cursor right one char
	jr	z,rcurs		; And quit
	jr	wrdlf0		; Else keep going
;
wrdrt:	xor	a		; Move cursor one word right
	cp	(hl)		; If char=null, quit
	ret	z
;
	ld	a,' '
	cp	(hl)		; If char=space, move cursor right one char
	jr	z,rcurs		; And quit
;
	call	rcurs		; Else keep going
	jr	wrdrt
;
; Copy EDBLK to copy buffer
;
cpyblk:	push	hl		; Save registers
	push	de
	push	bc
	ld	hl,edblk	; Point to edit buffer
	ld	de,cpybfr	; And copy buffer
	ld	bc,253		; Move 253 bytes (date not needed)
	ldir
	call	beep		; Beep twice to acknowledge move
	call	halfsec		; Brief delay
	call	beep
	pop	bc		; Restore registers
	pop	de
	pop	hl
	ret			; Done
;
; Move contents of copy buffer to empty fields in EDBLK
;
ditto:	push	bc		; Save registers
	push	hl
	ld	hl,pospanel	; Point to position panel
	ld	b,(hl)		; Get number of fields to process
	ld	hl,afpnl	; Point to field panel
	ld	de,cpybfr	; And copy buffer
;
dloop0:	push	hl		; Save pointer to field
	call	lhlhl		; Get field address
	ld	a,(hl)		; Check for empty field
	or	a
	jr	nz,nxtfld	; Something there - get next field
;
dloop1:	ld	a,(de)		; Check copy buffer
	or	a
	jr	z,nxtfld	; Nothing there, get next field
;
	ld	(hl),a		; Move byte to EDBLK
	inc	hl
	inc	de		; Bump pointers
	jr	dloop1		; Get next byte
;
nxtfld:	pop	hl		; Get back field panel
	inc	hl
	inc	hl		; Point to next
	push	hl		; Save field panel pointer
	call	lhlhl		; Get field address
	ld	de,512		; Add offset to copy buffer
	add	hl,de
	ex	de,hl		; DE=pointer to field in copy buffer
	pop	hl		; Get back field panel pointer
	djnz	dloop0		; And go again
	call	displa		; Re-display entire record
	pop	hl		; Get back registers
	pop	bc
	jp	movcur		; Put cursor back
;
iniblk:	ld	hl,edblk	; Zeroes everything in the
	ld	b,255		; Editing block
;
; Fill B bytes with 0 starting at address in HL
;
fillz:	ld	(hl),0
	inc	hl
	djnz	fillz
	ret
;
; End of ZDB.E
;
