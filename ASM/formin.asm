;----------------------------------------------------------------
;        This is a module in the ASMLIB library.
;
; This program uses DE -> a data structure to read formatted
; screen input forms. The user must generate a set of menu strings
; which will be displayed and a set of data areas which will be
; filled by this program with user input. An example is....
;
; 	lxi	d,menu
;	call	formin			; display menu and read data. SIMPLE
;	jmp	wherever		; continue on, no error returns
;
; menu	db	x1,y1,'String 1$'
;	dw	data1			; address of data string 1
;	db	x2,y2,'String 2$'
;	dw	data2			; address of data string 2
;	db	Xn,Yn,'String N$'
;	dw	datan
;	db	0ffh			; end of table
;
; data1	db	6,0,0,0,0,0,0,0		; 6 character CP/M console buffer
; data2 db	3,0,0,0,0		; 3
; datan	db	5,3,'Hey',0,0		; Preinitialized 5 character buffer
;
; The user is limited to a maximum of 255 items in the menu maximum.
; Note that this module uses internal I/O and is completely self contained.
; All console I/O is done via direct console I/O function 6 due to the
; nature of the software. If the address of the console buffer is 00 then the
; program only prints the string so that menu items can be used as 
; non-accepting prompts.
;
;		Written		R.C.H.		20/8/83
;		Last Update	R.C.H.		22/10/83
;
; Added 00 console address code.			R.C.H.  21/9/83
; Added I/O driver linkages.				R.C.H.  22/10/83
; Fixed silly ^X bug					R.C.H.  06/03/84
;----------------------------------------------------------------
;
; All I/O is internal to this module other than primitive character i/o
;
	name	'formin'
	public	formin
	extrn	cie,coe
;
	maclib	z80
;
;
filchr	equ	'_'			; prompt characters
esc	equ	01bh			; end of job
del	equ	07fh			; delete key
erlin	equ	24 			; erase whole line (control X)
uplin	equ	11			; up a line in the display
dlin	equ	10			; down a line
lchr	equ	08			; left a character
;
; The program will display all the strings then display string 1 and wait
; for console input. When the strings are displayed the program checks if
; the console buffer is empty and if so will send a set of dashes and if
; not will display the characters along with any make-up dashes required.
;
formin:	; Note that the address of the menu is passed in register DE
	sded	mnuadr			; save the menu address.
	shld	hlsave			; save the registers
	sbcd	bcsave
;
print$menu:
	call	disp$item		; display a menu string and data area
	ldax	d			; get a byte
	cpi	0ffh 			; end ?
	jrnz	print$menu		; if not the keep on till end
;
;----------------------------------------------------------------
; This routine is responsible for handling the displaying and
; reading of input lines. It must ...
;
; 1) Display the current menu item & console buffer
; 2) Read characters into the console buffer and acting on them...
;   a.  Save in the buffer
;   b.  Goto next line and buffer
;   c.  Goto last line and buffer
;   d.  Goback a character in the line (destructively)
;   e.  Go forward in the line (non destructively)
;   f.  Return to the main handler to exit or whatever
;----------------------------------------------------------------
;
get$input:
	lded	mnuadr			; Get the menu address
	xra	a
	sta	itmnum			; save the menu item number
;
get$item:
; Now display the item DE points to.
	call	disp$item		; display menu & console buffer
; After DISP$ITEM DE -> the start of the NEXT item in the list.
	sded	nxtadr			; indicate the start of next item
; Next we must cursor position to the screen X and Y position of the data field
	lxi	d,bufx			; point to data buffer X, Y screeb addr
	call	setde			; position cursor using DE -> XY
; Now point to the buffer. We must re-print it if characters in it.
	lhld	conadr			; HL -> start of console buffer
	mov	a,l
	ora	h			; Is H = L = 0 ??
	jz	nxt$lin			; If so then process the next line
; 
	mov	c,m			; C = maximum characters allowed
	inx	h			; HL -> characters in the buffer
	mov	e,l
	mov	d,h			; copy address of length into DE
	inx	h			; now hl -> first character in string.
;
;Now we detect if there are already characters there. If so print them.
	ldax	d			; get the number
	ora	a
	jrz	no$chars
	mov	b,a			; set up a loop counter
pcl:
	mov	a,m			; fetch a character
	inx	h			; point to next character
	call	coe
	djnz	pcl			; print characters till b = 0
;
; This section of code assumes that C = maximum characters allowed and 
; DE -> characters in the buffer already. HL must point to characters in 
; the buffer and DE points to the character in the buffer actual length.
;
no$chars:	; Read console for characters.
	call	cie  			; get the character via direct input
; check if a terminator
	cpi	erlin
	jz	erase$line
	cpi	esc
	jz	fin$get			; finish of the get then
	cpi	0dh			; carriage return ?
	jz	nxt$lin
	cpi	uplin			; go up a line
	jz	prv$lin
	cpi	dlin
	jz	nxt$lin
	cpi	lchr
	jz	lft$chr
	cpi	del
	jz	lft$chr
	cpi	020h			; check if less than a space
	jrc	ign$chr		        ; ignore them
; If it is not a formatting character then save it then check if the
; buffer is full before inserting it. C = max allowed, B = current size
	sta	temp
	ldax	d			; get character read counter
	cmp	c			; compare to maximum allowed
	jrz	ign$chr			; ignore if exactly full
	jrnc	ign$chr			; no carry if too full
; If not full or overfull then we merely bump the count and save it back
	inr	a
	stax	d			; saved
; All else means that we can insert the character into the buffer
	lda	temp			; fetch
	mov	m,a			; save
	call	coe			; echo the character now
	inx	h			; point to next memory address
	jr	no$chars		; keep reading characters
;
; This trivial bit of code rings the bell then jumps to get another char.
; We usually get here due to an illegal control code or buffer full.
;
ign$chr:	; Ignore the character in a and ring bell then return to loop
	mvi	a,07			; bell code
	call	coe
	jr	no$chars		; get next character
;
; This piece of code handles the end of input due to carriage return or
; down a line code inputs. We must assume that all parameters are up to
; date so we only have to address the next line of the menu then return
; to the start of the get section to continue.
;
nxt$lin:
	lda	itmnum
	inr	a			; load.bump.save item number
	sta	itmnum
;
	lded	nxtadr			; get address of next item
	ldax	d
	cpi	0ffh			; is it the end of the menu ??
	jnz	get$item		; use it if it is NOT
	lded	mnuadr			; all else we get the start address
	xra	a
	sta	itmnum			; indicate first item number
	jmp	get$item		; restart from scratch
;
; This section of code must go back a line. It does this by backing up
; using $ characters as indicators. Note that if ITMNUM = 1 then
; no action is taken and we return to the read loop.
;
prv$lin:
	lda	itmnum			; get line number
	ora	a
	jz	no$chars		; ignore all this if line 1
	dcr	a
	sta	itmnum			; decrement and save
	ora	a
	jrnz	prv$lin1
	lded	mnuadr			; point to item 1 
	jmp	get$item
; If here then we must goto the (ITMNUM)'th dollar address + 3 in the menu
prv$lin1:
	lded	mnuadr			; point to start of menu
	mov	b,a			; save the counter
;
prv$lin2:
	ldax	d
	inx	d
	cpi	'$'
	jrnz	prv$lin2
	djnz	prv$lin2		; keep on till all found
	inx	d			; points to address byte 2
	inx	d			; points to start of string
	jmp	get$item		; get the data now
;
; Here we erase the whole line back to the start.
; b = number of characters in the buffer.
erase$line:
	ldax	d			; get the # character there
	ora	a			; See if none there yet
	jz	no$chars		; If none, skip the backspacing
	mov	b,a
eol2:
	call	back$char
	djnz	eol2
	xra	a			; get a zero into character count
	stax	d			; save line length
	jmp	no$chars
;
; Here we back the cursor up a character so long as there are characters 
; to back up in the buffer. If the buffer is empty then we ring the bell.
;
; DE -> characters in the buffer
; HL -> ascii characters in the buffer
;
lft$chr:
	ldax	d			; get the character count
	ora	a			; empty ??
	jz	ign$chr			; ring bell and continue
	dcr	a
	stax	d			; save the decremented count
	call	back$char		; do the backing up of the cursor
	jmp	no$chars
;
; Back the cursor up 1 character and write a null to the buffer.
;
back$char:
	dcx	h			; back up the memory pointer too
	mvi	m,00			; clear the buffer byte
; Send now a backspace, underline, backspace
	mvi	a,8
	call	coe
	mvi	a,filchr		; the fill character
	call	coe
	mvi	a,08
	call	coe
	ret
;
;----------------------------------------------------------------
; This is jumped to when the user enters an ESCAPE to quit the input
; to the data fields.
;----------------------------------------------------------------
;
fin$get:
	lded	mnuadr
	lhld	hlsave
	lbcd	bcsave
	ret
;
;----------------------------------------------------------------
; This large routine must use DE to print the menu item it points
; to and also print the console buffer the menu item points to. 
; If the console buffer has an address of 00 then it is ignored.
; On return DE must point to the next menu item or end of menu.
;----------------------------------------------------------------
;
disp$item:
	call	setde			; set up cursor DE-> address
	call	print			; print DE-> string
;
; Now we need to save the current screen address since this is where
; the console buffer is being printed so we need it for later homing to.
	lda	curx
	sta	bufx
	lda	cury
	sta	bufy			; saved
;
; Now load the address of the console buffer string
	xchg				; HL -> the address now
	mov	e,m
	inx	h
	mov	d,m
	inx	h
; Now HL -> next menu string, DE -> console buffer for this string. 
; This extensive section of code will print the console buffer or prompt
;
	sded	conadr			; save CONSOLE BUFFER address
; See if this menu string has no console buffer
	mov	a,e
	ora	d			; Is D = E = 0 ?
	jrz	fin$disp		; put address of menu into de then ret.
	ldax	d			; get its maximum length
	mov	b,a			; Save as a counter
	inx	d			; DE -> characters in the buffer
	inx	d			; DE -> first buffer character
print$con$buf:
	ldax	d
	inx	d			; point to next character
	ora	a			; is this character a null ?
	jrnz	pconbuf2
	mvi	a,filchr		; if it was load a default
pconbuf2:
	call	coe			; print it
	djnz	print$con$buf		; print next string
; Restore DE as pointer to the menu then do the next item / buffer
; Note that the address of the console buffer is saved in CONADR.
fin$disp:
	xchg				; DE -> next string start
	ret
;
;----------------------------------------------------------------
; Set up the screen address -> by DE stored in memory.
; The address is saved in curx, cury. Note that the offset (32) 
; is added to both x and y.
;----------------------------------------------------------------
;
setde:
	ldax	d			; get the X address
	sta	curx
	inx	d
	ldax	d
	sta	cury
	inx	d			; DE now -> past end
;
; Flow onto the next part which uses curx and cury to set up the cursor
;
;----------------------------------------------------------------
; Use the values in curx and cury for the cursor position to
; be used to set the cursor.
;----------------------------------------------------------------
;
setcur:
	mvi	a,esc
	call	coe
	mvi	a,'='
	call	coe
; Now the Y value
	lda	cury
	adi	32
	call	coe
; X address
	lda	curx
	adi	32
	jmp	coe     		; all done
;
;----------------------------------------------------------------
; Print the string -> by DE. Return with DE pointing past the 
; string end so as to point to the start of the next string.
; NOTE that this routine updates the CURX screen address. This is
; vital for all printing functions.
;----------------------------------------------------------------
;
print:
	ldax	d
	inx	d
	ora	a
	rz
	cpi	'$'			; END ?
	rz
	call	coe
	lda	curx
	inr	a
	sta	curx			; loaded.updated.saved
	jr	print
;
; Data storage of string addresses and cursor addresses.
;
	dseg
;
nxtadr	db	00,00				; current string address
conadr	db	00,00				; address of a console buffer
mnuadr	db	00,00				; address of a menu string
itmnum	db	00				; menu item number counter
;
bufx	db	00				; buffer start screen x value
bufy	db	00				; buffer start screen y value
;
curx:	db	00			; loaded by setxy
cury:	db	00			; as above
;
hlsave	db	00,00
bcsave	db	00,00				; preserver registers in these
temp	db	00				; save cons. character temp.
;
	end

