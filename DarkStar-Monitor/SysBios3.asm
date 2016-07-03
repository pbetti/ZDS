;
;=======================================================================
;
; Modular Z80 DarkStar (NE Z80) Monitor
;
;=======================================================================
;
; Original code:
; Z80 Nuova Elettronica Monitor 390 su eprom 2532 (4k)
;
; Disassembled and reconstructed by
; Piergiorgio Betti <pbetti@lpconsul.net> on 2005 01 26
;
; Latest non modular BIOS is DARKSTAR-MONITOR-0.9.0.asm
; dated 20140531
; - Following addition of MultiF-Board doing complete rewrite of the
;   monitor/BIOS has been started.
;   Major goals:
;   o Modularization: Now monitor can grow up to 256kb instead of 4kb
;     :-)
;   o Specialized images fitted in memory page (4kb) or multiples
;   o Full support for new hardware
;   o I/O rewrite for MODE 2 interrupts
;   Minor goals:
;   o Full code clean-up & reorganization
; ---------------------------------------------------------------------

; Common equates for BIOS/Monitor

include Common.inc.asm

	extern	delay, mmpmap, mmgetp
	extern	bbconin, bbconout, rldrom

	dseg

	name	'SYS3BI'

sysbios3	equ	$		; start of non resident BIOS

	; safe reload, something goes wrong if we are here

	jp	rldrom

sysbid3:
	defb	'SYSBIOS3'

;
filchr		equ	'-'		; prompt characters
linchrc		equ	$c1		; line draw char
linchrs		equ	'_'		; line draw char (serial)
delim1		equ	'['
delim2		equ	']'
esc		equ	$1b		; end of job
del		equ	$7f		; delete key
erlin		equ	$18		; erase whole line (control X)
uplin		equ	$15		; up a line in the display
dlin		equ	$1a		; down a line
lchr		equ	$08		; left a character
imtorg		equ	$0000		; location in page
imgorg		equ	$1000


;;
;; Manage EEPROM images
;;
epmanager:
	ld	b,trnpag		; copy table in ram
	call	mmgetp
	ld	(temp),a		; save current
	;
	ld	a,imtpag		; in eeprom table
	ld	b,trnpag		; transient page
	call	mmpmap			; mount it
	;
	ld	hl,[trnpag << 12 ] + imtorg
	ld	de,ramtbl		; our copy
	ld	bc,imtsiz
	ldir				; do copy
	;
	ld	a,(temp)		; restore
	ld	b,trnpag		; transient page
	call	mmpmap			; mount it
	;
	ld	a,$cd			; patch burn routine
	ld	(pradr),a		; for progress routine
	ld	hl,pbytecount
	ld	(pradr+1),hl		; that is PBYTECOUNT
	;
	ld	(spreg),sp
	ld	sp,bbbase - 128		; switch to our stack

pdraw:	ld	c,ff			; draw page
	call	bbconout
	call	crsrof
	call	revon
	call	inlinexy
	defb	0
	defb	(80 - (mgte - mgts))/2
mgts:	defb	" * EEPROM MANAGER * ",0
mgte:	call	clratr

	call	dispimgs
	xor	a
	ld	(curblk),a		; at block 0
	ld	b,a
	inc	a
	call	select

	ld	h,13
	ld	l,0
	call	setcur
	call	plin80
	call	inlinexy
	defb	13,59
	defb	"[ Image Editor ]",0
	call	dbottomline

	ld	h,23
	ld	l,1
	call	setcur
	call	revon
	ld	c,' '
	ld	b,78
	call	pstr
	call	inlinexy
	defb	23
	defb	(80 - (mmie - mmis))/2
mmis:	defb	" Select: Up/Dn - Image: [A]dd [D]elete [M]odify - Table: [C]lear ",0
mmie:	call	revof
	call	hliton
	call	inlinexy
	defb	22
	defb	(80 - (mese - mess))/2
mess:	defb	"ESC: Stop/Exit",0
mese:	call	clratr

wcmd:	call	bbconin
	call	atoup
wcmd1:
	cp	'C'			; clear table
	jp	z,ctable
	cp	esc			; exit
	jp	z,doexi
	cp	$05			; ^E up
	jp	z,prvblk
	cp	$18			; ^X down
	jp	z,nxtblk
	cp	$15			; up
	jp	z,prvblk
	cp	$1a			; down
	jp	z,nxtblk
	cp	'G'		;***** debugger *****
	jp	z,$a000
	cp	'A'			; add image
	jp	z,addim
	cp	'F'
	jp	z,fakeop
	cp	'M'
	jp	z,modim
	cp	'D'
	jp	z,delim

	jr	wcmd

;;
;; Disable writing on eeprom
;;
fakeop:
	ld	a,$ff
	ld	(flagfake),a		; disabled
	call	inlinexy
	defb	13,5
	defb	" Locked ",0
	jp	wcmd

;;
;; Return to Bootmonitor
;;
doexi:
	call	crsron
	ld	c,ff
	call	bbconout
	ld	sp,(spreg)		; restore old stack
	ret

;;
;; Clear Table
;;
ctable:
	call	inlinexy
	defb	20
	defb	(80 - (mcte - mcts))/2
mcts:	defb	"Completely erase table ?",0
mcte:
	call	askcnf
	jp	nz,resetedt
	call	confirm1
	jp	nz,resetedt
	call	confirm2
	jp	nz,resetedt
	call	clrmsg
	ld	hl,ramtbl
	ld	de,ramtbl+1
	ld	bc,imtsiz-1
	ld	(hl),0
	ldir
	call	sy2tbl			; system entry
	jp	pdraw

;;
;; Add image
;;
addim:
	ld	a,(iname+1)		; free slot ?
	or	a
	jr	z,addim1		; is free
	call	inlinexy
	defb	20
	defb	(80 - (move - movs))/2
movs:	defb	"Can't overwrite slot!",0
move:
	call	bbconin
	call	clrmsg
	jp	wcmd			; exit

addim1:
	call	revon
	call	inlinexy
	defb	20
	defb	(80 - (miwe - miws))/2
miws:	defb	" Image MUST BE present in ram @ 1000H and no more 32Kb in size ",0
miwe:	call	revof

	call	clredt			; init blank buffer
	call	inlinexy
	defb	19,61
	defb	"Add Image",$1,0		; activate caps-lock toot
	ld	de,editmsk
	call	formin			; edit form
	ld	c,$2
	call	bbconout		; reset caps-lock
	call	clrmsg
	call	validate		; validate input
	ld	a,$ff
	ld	(flagburn),a		; will burn image & table
asktburn:
	; well
	call	confirm1
	jp	nz,resetedt
	call	confirm2
	jp	nz,resetedt
	; ok... hope you know what you're doing.
	ld	a,(curblk)
	ld	b,a
	call	getblk
	call	ed2tbl			; update table
	call	clrmsg

	call	inlinexy
	defb	20
	defb	(80 - (mhoe - mhos))/2
mhos:	defb	"Hope you know what you are doing",0
mhoe:
	call	inlinexy
	defb	21
	defb	(80 - (mbse - mbss))/2
mbss:	defb	"Press a key to start burning",0
mbse:
	call	bbconin
	call	clrmsg
	call	blnkon
	call	inlinexy
	defb	20
	defb	(80 - (mbse - mbss))/2
mbus:	defb	"Burning. Please wait. Do nothing until end.",0
mbue:	call	blnkof

	ld	a,(flagfake)		; write locked ?
	or	a
	jr	nz,afterburn		; yes

	ld	a,(flagburn)		; write image
	or	a
	jr	z,tblburn		; no

	call	burnimage
tblburn:
	call	burntable
afterburn:
	call	clrmsg
	call	inlinexy
	defb	20
	defb	(80 - (mbde - mbds))/2
mbds:	defb	"Done. Press any key.",0
mbde:
	call	bbconin
	xor	a
	ld	(flagburn),a		; reset image write
	jp	pdraw


;;
;; Modify image
;;
modim:
	call	revon
	call	inlinexy
	defb	20
	defb	(80 - (mmte - mmts))/2
mmts:	defb	" This will modify just table entry and NOT image on EEPROM ",0
mmte:	call	revof

	call	inlinexy
	defb	19,61
	defb	"Modify Entry",$1,0	; activate caps-lock toot
	ld	de,editmsk
	call	formin			; edit form
	ld	c,$2
	call	bbconout		; reset caps-lock
	call	clrmsg
	call	validate		; validate input
	; ok
	ld	b,1
	ld	a,(curblk)		; intercept rewrite on block 0
	or	a
	jr	nz,askrbr
	call	blnkon
	call	inlinexy
	defb	21
	defb	(80 - (mr0e - mr0s))/2
mr0s:	defb	"** SYSTEM BLOCK!! **",0
mr0e:	ld	b,3
askrbr:	call	blnkon
	call	inlinexy
	defb	20
	defb	(80 - (mrbe - mrbs))/2
mrbs:	defb	"REBURN Image too ?",0
mrbe:	call	blnkof
	call	askcnf
	jp	nz,rbatbl0		; if answer is "no"
	djnz	askrbr
	ld	a,$ff
	ld	(flagburn),a		; will burn image & table
	jp	asktburn
rbatbl0:
	ld	a,(curblk)		; recheck block 0 and in case skip
	or	a			; write at all
	jp	nz,asktburn
	jp	resetedt

;;
;; Delete image
;;
delim:
	ld	a,(curblk)
	ld	b,a
	call	getblk
	ld	a,(iname+1)
	or	a
	jp	z,wcmd
	call	inlinexy
	defb	19,61
	defb	"Delete Entry",0
	call	clrmsg
	call	inlinexy
	defb	20
	defb	(80 - (mdte - mdts))/2
mdts:	defb	"ERASE this table entry ?",0
mdte:
	call	askcnf
	jp	nz,resetedt
	call	clredt			; clear buffer block
	; well
	jp	asktburn

;;
;; Clear messages area (rows 20, 21)
;;
clrmsg:
	ld	h,20
	ld	l,0
	call	setcur
	call	clreol
	call	crlf
	call	clreol
	ret

;;
;; Confirm routines
;;
;; Z flag > yes, any other key = no
confirm2:
	call	clrmsg
	call	blnkon
	call	inlinexy
	defb	20
	defb	(80 - (mc2e - mc2s))/2
mc2s:	defb	"Really confirm ? (y/n)",0
mc2e:	call	blnkof
	jr	askcnf

confirm1:
	call	clrmsg
	call	hliton
	call	inlinexy
	defb	20
	defb	(80 - (mc1e - mc1s))/2
mc1s:	defb	"Confirm ? (y/n)",0
mc1e:	call	hlitof

askcnf:	call	bbconin
	call	atoup
	cp	'Y'
	push	af
	call	clrmsg
	pop	af
	ret

;;
;; Validate input and store parameters in binary
;;
validate:
	ld	de,beaddr		; rom page
	ld	b,2			; len 2
	call	hexstor
	jr	nz,invalid
	ld	hl,(cnvbuf)
	ld	(curpag),hl

	ld	de,biaddr		; image base address
	ld	b,4			; len 4
	call	hexstor
	jr	nz,invalid
	ld	hl,(cnvbuf)
	ld	(curadr),hl

	ld	de,bsize		; image size
	ld	b,4			; len 4
	call	hexstor
	jr	nz,invalid
	ld	hl,(cnvbuf)
	ld	(cursiz),hl

	;**** should check for overlapping here...

	ld	bc,0
	ld	hl,(curadr)		; check overlap of $D000-$DFFF region
					; that is forbidden
	ld	de,[trnpag << 12] + $0fff
	or	a
	sbc	hl,de
	jr	nc,val2
	inc	b
val2:	ld	hl,(curadr)		; greater than $DFFF: ok
	ld	de,(cursiz)
	add	hl,de
	ld	de,trnpag << 12
	or	a
	sbc	hl,de
	jr	c,val3
	inc	c
val3:
	ld	a,b
	and	c
	jr	nz,invalid
	ret

invalid:
	pop	hl			; clear last call
	call	hliton
	call	inlinexy
	defb	20
	defb	(80 - (mnve - mnvs))/2
mnvs:	defb	"Wrong data!",0
mnve:	call	hlitof
	call	bbconin

	; fall through

;;
;; Reset editor
;;
resetedt:
	call	clrmsg
	call	dbottomline
	ld	a,(curblk)
	ld	b,a
	inc	a
	call	select
	jp	wcmd

;;
;; Convert ascii buffer to binary
;;
hexstor:
	ld	hl,$0000
nxth:	ld	a,(de)
	ld	c,a
	call	checkhex
	jr	c,cnhex			; if not hex digit
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,hl
	or	l
	ld	l,a
	inc	de
	djnz	nxth

cnhex:	ld	(cnvbuf),hl
	xor	a
	cp	b			; ok if B = 0
	ret				; else ret NZ


;;
;; CHKHEX - check for hex ascii char in A
;
checkhex:
	sub	$30
	ret	c
	cp	$17
	ccf
	ret	c
	cp	$0a
	ccf
	ret	nc
	sub	$07
	cp	$0a
	ret

;;
;; Show images
;;
dispimgs:
	call	sy2tbl			; system entry
	ld	e,1
	ld	d,maxblk
	ld	b,0
	ld	h,2			; initial row
	ld	l,2
nblk:	call	setcur
	ld	a,b			; image number
	push	hl
	call	asciia
	push	de
	ld	de,msep
	call	print
	push	bc
	call	getblk
	ld	a,(hl)			; is a valid block ?
	cp	tnamelen
	jr	z,blkdsp		; yes
	ld	(temp),hl		; save block address
	call	clredt			; init buffer block
	ld	hl,(temp)		; reinit HL
	call	ed2tbl			; init table block
	ld	hl,(temp)		; reinit HL
blkdsp:	call	tbl2ed
	call	dspblkid
	pop	bc
	pop	de
	pop	hl
	dec	d
	jr	z,dispiend
	dec	e
	jr	z,drcol
	inc	b
	ld	e,1
	inc	h
	ld	l,2
	jr	nblk
drcol:
	inc	b
	ld	l,42
	jr	nblk
dispiend:
	call	clredt			; clear buffer block
	ret


;;
;; Display block name
;;
dspblkid:
	ld	hl,bname
	ld	b,tnamelen
	call	nprint
	ld	de,msep
	call	print
	ld	hl,bdesc
	ld	b,tdesclen
	call	nprint
	ret

;;
;; Select previous block
;;
prvblk:
	ld	a,(curblk)		; get actual
	or	a
	jr	z,prvble		; at top
	ld	b,a
	xor	a
	call	select			; update old
	ld	a,(curblk)
	dec	a
	ld	(curblk),a		; move up
	ld	b,a
	inc	a
	call	select			; update new
prvble:
	jp	wcmd

;;
;; Select previous block
;;
nxtblk:
	ld	a,(curblk)		; get actual
	cp	maxblk-1
	jr	z,nxtble		; at bottom
	ld	b,a
	xor	a
	call	select			; update old
	ld	a,(curblk)
	inc	a
	ld	(curblk),a		; move up
	ld	b,a
	inc	a
	call	select			; update new
nxtble:
	jp	wcmd


;;
;; Select a block
;;
;; B < block A < 0 normal, 1 reversed

select:
	push	de
	push	hl
	push	af
	ld	a,b			; calc line
	srl	a
	add	a,2			; add screen offset
	ld	h,a
	bit	0,b			; calc row
	jr	z,selc1			; even is on right col
	ld	l,47
	jr	selc2
selc1:	ld	l,7
selc2:	call	setcur			; locate cursor
	call	getblk			; get block addr from B
	call	tbl2ed			; in buffer
	pop	af
	push	af
	or	a
	jr	z,selc3
	call	revon
selc3:	call	dspblkid		; do display
	call	revof
	pop	af
	or	a
	jr	z,selc4
	ld	de,editmsk
	call	printmenu
selc4:	pop	hl
	pop	de
	ret

;;
;; Clear editor buffer
;;
clredt:
	ld	hl,edtcpy
	ld	de,iname
	ld	bc,edtsiz
	ldir
	ret

;;
;; Copy block from table to buffer
;;
;; HL < table block address
tbl2ed:
	ld	de,iname
	ld	bc,edtsiz
	ldir
	ret

;;
;; Copy block from table to buffer
;;
;; HL < table block address
ed2tbl:
	ex	de,hl
	ld	hl,iname
	ld	bc,edtsiz
	ldir
	ex	de,hl
	ret

;;
;; Copy SYSTEM block from table to buffer
;;
sy2tbl:
	ld	de,ramtbl
	ld	hl,edtsys
	ld	bc,edtsiz
	ldir
	ret
;;
;; Get block
;;
;; B < block num - HL > blok address
getblk:
	push	de
	inc	b
	ld	de,tblblk
	ld	hl,ramtbl-tblblk
getbl1:	add	hl,de
	djnz	getbl1
	pop	de
	ret

;;
;; Draw bottom line
;;
dbottomline:
	ld	h,19
	ld	l,0
	call	setcur
	call	plin80
	call	inlinexy
	defb	19,59
	defb	"[              ]",0
	ret


;;
;; Draw a line
;;
;; plin80: line 80 chars
;; plin  : line as long as B content
;; pstr  : C char as long as B content
plin80:
	ld	b,80			; across the screen
plin:
	ld	c,linchrc
	ld	a,(miobyte)		; conf. location
	bit	5,a
	jr	z,pstr			; video
	ld	c,linchrs		; serial
pstr:	call	bbconout
	djnz	pstr
	ret

;;
;; Output HL converted to ascii decimal (max 9999)
;;
asciia:
	push	bc
	push	de
	ld	h,0
	ld	l,a
	ld	e,4
	call	asciihl0
	pop	de
	pop	bc
	ret

asciihl:
	push	bc
	push	de
	ld	e,1
	call	asciihl0
	pop	de
	pop	bc
	ret

asciihl0:
	ld	bc,-10000
	call	asciihl1
	ld	bc,-1000
	call	asciihl1
	ld	bc,-100
	call	asciihl1
	ld	c,-10
	call	asciihl1
	ld	c,-1
asciihl1:
	ld	a,'0'-1
asciihl2:
	inc	a
	add	hl,bc
	jr	c,asciihl2
	sbc	hl,bc
	ld	c,a
	dec	e
	ret	nz
	inc	e
	call	bbconout
	ret

;;
;; Print byte count during burn
;;
pbytecount:
	push	hl
	push	de
	push	bc
	push	af
	ld	h,21			; where to show progress
	ld	l,38
	call	setcur
	ld	hl,(cnvbuf)
	ld	de,128
	add	hl,de
	ld	(cnvbuf),hl
	call	asciihl
	pop	af
	pop	bc
	pop	de
	pop	hl
	ret

;;
;; To uppecase A
;;
atoup:
	cp	$60
	jp	m,atexi
	cp	$7b
	jp	p,atexi
	res	5,a
atexi:	ret


;;
;; Emit new line
crlf:
	call	inline
	defb	cr,lf,0
	ret

;;
;; Some video utilities

crsron:	ld	c,$05
	jr 	zddchr

crsrof:	ld	c,$04
	jr 	zddchr

clreol:	ld	c,$0f
	jr 	zddchr

clratr:	ld	c,$11
	jr 	zddchr

zddchr: call	bbconout
	ret

blnkon:
	call	inline
	db	$1b,$02,$0d,$00
	ret
blnkof:
	call	inline
	db	$1b,$01,$0d,$00
	ret
revon:
	call	inline
	db	$1b,$1b,$0d,$00
	ret
revof:
	call	inline
	db	$1b,$1c,$0d,$00
	ret
undron:
	call	inline
	db	$1b,$04,$0d,$00
	ret
undrof:
	call	inline
	db	$1b,$03,$0d,$00
	ret
hliton:
	call	inline
	db	$1b,$06,$0d,$00
	ret
hlitof:
	call	inline
	db	$1b,$05,$0d,$00
	ret
;;
;; Set cursor position. Absolute
;;
;; HL = cursor pos.
;; N.B.: This routine does not check for limits

setcur:
	push	bc
	ld	c,esc
	call	bbconout
; X address
	ld	a,l
	add	a,32
	ld	c,a
	call	bbconout
; Now the Y value
	ld	a,h
	add	a,32
	ld	c,a
	call	bbconout
; terminate
	ld	c,0
	call	bbconout
	pop	bc
	ret

;----------------------------------------------------------------
;        FORMIN is a routine taken from the ASMLIB library
;                    by Richard C Holmes
;
; The routine will display all the strings then display string 1 and wait
; for console input. When the strings are displayed the program checks if
; the console buffer is empty and if so will send a set of dashes and if
; not will display the characters along with any make-up dashes required.
;
formin:	; Note that the address of the menu is passed in register DE
	ld	(mnuadr),de		; save the menu address.
	ld	(hlsave),hl		; save the registers
	ld	(bcsave),bc
;
	call	crsron
	call	printmenu
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
getinput:
	ld	de,(mnuadr)		; Get the menu address
	xor	a
	ld	(itmnum),a		; save the menu item number
;
getitem:
; Now display the item DE points to.
	call	dispitem		; display menu & console buffer
; After DISPITEM DE -> the start of the NEXT item in the list.
	ld	(nxtadr),de		; indicate the start of next item
; Next we must cursor position to the screen X and Y position of the data field
	ld	de,bufx			; point to data buffer X, Y screeb addr
	call	setxy			; position cursor using DE -> XY
; Now point to the buffer. We must re-print it if characters in it.
	ld	hl,(conadr)		; HL -> start of console buffer
	ld	a,l
	or	h			; Is H = L = 0 ??
	jp	z,nxtlin		; If so then process the next line
;
	ld	c,(hl)			; C = maximum characters allowed
	inc	hl			; HL -> characters in the buffer
	ld	e,l
	ld	d,h			; copy address of length into DE
	inc	hl			; now hl -> first character in string.
;
;Now we detect if there are already characters there. If so print them.
	ld	a,(de)			; get the number
	or	a
	jr	z,nochars
	ld	b,a			; set up a loop counter
pcl:
	ld	a,(hl)			; fetch a character
	inc	hl			; point to next character
	call	coe
	djnz	pcl			; print characters till b = 0
;
; This section of code assumes that C = maximum characters allowed and
; DE -> characters in the buffer already. HL must point to characters in
; the buffer and DE points to the character in the buffer actual length.
;
nochars: ; Read console for characters.
	call	bbconin			; get the character via direct input
; check if a terminator
	cp	erlin
	jp	z,eraseline
	cp	esc
	jp	z,finget		; finish of the get then
	cp	0dh			; carriage return ?
	jp	z,nxtlin
	cp	uplin			; go up a line
	jp	z,prvlin
	cp	dlin
	jp	z,nxtlin
	cp	lchr
	jp	z,lftchr
	cp	del
	jp	z,lftchr
	cp	020h			; check if less than a space
	jr	c,ignchr			; ignore them
; If it is not a formatting character then save it then check if the
; buffer is full before inserting it. C = max allowed, B = current size
	ld	(temp),a
	ld	a,(de)			; get character read counter
	cp	c			; compare to maximum allowed
	jr	z,ignchr		; ignore if exactly full
	jr	nc,ignchr		; no carry if too full
; If not full or overfull then we merely bump the count and save it back
	inc	a
	ld	(de),a			; saved
; All else means that we can insert the character into the buffer
	ld	a,(temp)		; fetch
	ld	(hl),a			; save
	call	coe			; echo the character now
	inc	hl			; point to next memory address
	jr	nochars			; keep reading characters
;
; This trivial bit of code rings the bell then jumps to get another char.
; We usually get here due to an illegal control code or buffer full.
;
ignchr:; Ignore the character in a and ring bell then return to loop
	ld	a,07			; bell code
	call	coe
	jr	nochars			; get next character
;
; This piece of code handles the end of input due to carriage return or
; down a line code inputs. We must assume that all parameters are up to
; date so we only have to address the next line of the menu then return
; to the start of the get section to continue.
;
nxtlin:
	ld	a,(itmnum)
	inc	a			; load.bump.save item number
	ld	(itmnum),a
;
	ld	de,(nxtadr)		; get address of next item
	ld	a,(de)
	cp	0ffh			; is it the end of the menu ??
	jp	nz,getitem		; use it if it is NOT
	ld	de,(mnuadr)		; all else we get the start address
	xor	a
	ld	(itmnum),a		; indicate first item number
	jp	getitem			; restart from scratch
;
; This section of code must go back a line. It does this by backing up
; using $ characters as indicators. Note that if ITMNUM = 1 then
; no action is taken and we return to the read loop.
;
prvlin:
	ld	a,(itmnum)		; get line number
	or	a
	jp	z,nochars		; ignore all this if line 1
	dec	a
	ld	(itmnum),a		; decrement and save
	or	a
	jr	nz,prvlin1
	ld	de,(mnuadr)		; point to item 1
	jp	getitem
; If here then we must goto the (ITMNUM)'th dollar address + 3 in the menu
prvlin1:
	ld	de,(mnuadr)		; point to start of menu
	ld	b,a			; save the counter
;
prvlin2:
	ld	a,(de)
	inc	de
	cp	'$'
	jr	nz,prvlin2
	djnz	prvlin2			; keep on till all found
	inc	de			; points to address byte 2
	inc	de			; points to start of string
	jp	getitem			; get the data now
;
; Here we erase the whole line back to the start.
; b = number of characters in the buffer.
eraseline:
	ld	a,(de)			; get the # character there
	or	a			; See if none there yet
	jp	z,nochars		; If none, skip the backspacing
	ld	b,a
eol2:
	call	backchar
	djnz	eol2
	xor	a			; get a zero into character count
	ld	(de),a			; save line length
	jp	nochars
;
; Here we back the cursor up a character so long as there are characters
; to back up in the buffer. If the buffer is empty then we ring the bell.
;
; DE -> characters in the buffer
; HL -> ascii characters in the buffer
;
lftchr:
	ld	a,(de)			; get the character count
	or	a			; empty ??
	jp	z,ignchr		; ring bell and continue
	dec	a
	ld	(de),a			; save the decremented count
	call	backchar		; do the backing up of the cursor
	jp	nochars
;
; Back the cursor up 1 character and write a null to the buffer.
;
backchar:
	dec	hl			; back up the memory pointer too
	ld	(hl),00			; clear the buffer byte
; Send now a backspace, underline, backspace
	call	inline
	defb	$1b,$19,$0d,0
	ld	a,8
	call	coe
	ld	a,filchr		; the fill character
	call	coe
	ld	a,08
	call	coe
	call	inline
	defb	$1b,$1a,$0d,0
	ret
;
;----------------------------------------------------------------
; This is jumped to when the user enters an ESCAPE to quit the input
; to the data fields.
;----------------------------------------------------------------
;
finget:
	call	crsrof
	ld	de,(mnuadr)
	ld	hl,(hlsave)
	ld	bc,(bcsave)
	ret
;
;----------------------------------------------------------------
; This large routine must use DE to print the menu item it points
; to and also print the console buffer the menu item points to.
; If the console buffer has an address of 00 then it is ignored.
; On return DE must point to the next menu item or end of menu.
;----------------------------------------------------------------
;
dispitem:
	call	setxy			; set up cursor DE-> address
	call	print			; print DE-> string
	ld	c,delim1
	call	bbconout
	ld	a,(curx)
	inc	a
	ld	(curx),a		; updated
;
; Now we need to save the current screen address since this is where
; the console buffer is being printed so we need it for later homing to.
	ld	a,(curx)
	ld	(bufy),a
	ld	a,(cury)
	ld	(bufx),a		; saved
;
; Now load the address of the console buffer string
	ex	de,hl			; HL -> the address now
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
; Now HL -> next menu string, DE -> console buffer for this string.
; This extensive section of code will print the console buffer or prompt
;
	ld	(conadr),de		; save CONSOLE BUFFER address
; See if this menu string has no console buffer
	ld	a,e
	or	d			; Is D = E = 0 ?
	jr	z,findisp		; put address of menu into de then ret.
	ld	a,(de)			; get its maximum length
	ld	b,a			; Save as a counter
	inc	de			; DE -> characters in the buffer
	inc	de			; DE -> first buffer character
printconbuf:
	ld	a,(de)
	inc	de			; point to next character
	or	a			; is this character a null ?
	jr	nz,pconbuf2
	ld	a,filchr		; if it was load a default
pconbuf2:
	call	coe			; print it
	djnz	printconbuf		; print next string
; Restore DE as pointer to the menu then do the next item / buffer
; Note that the address of the console buffer is saved in CONADR.
findisp:
	ex	de,hl			; DE -> next string start
	ld	c,delim2
	call	bbconout
	ret
;
printmenu:
	call	dispitem		; display a menu string and data area
	ld	a,(de)			; get a byte
	cp	0ffh			; end ?
	jr	nz,printmenu		; if not the keep on till end
	ret
;----------------------------------------------------------------
; Set up the screen address -> by DE stored in memory.
; The address is saved in curx, cury. Note that the offset (32)
; is added to both x and y.
;----------------------------------------------------------------
;
setxy:
	ld	a,(de)			; get the X address
	ld	(cury),a
	inc	de
	ld	a,(de)
	ld	(curx),a
	inc	de			; DE now -> past end
; X address
	ld	a,(cury)
	ld	h,a
	ld	a,(curx)
	ld	l,a
	call	setcur
	ret

;;
;; Print a string of B length pointed by HL
;;
nprint:
	push	bc
nprin1:
	ld	c,(hl)
	call	bbconout
	inc	hl
	djnz	nprin1
	pop	bc
	ret

;----------------------------------------------------------------
; Print the string -> by DE. Return with DE pointing past the
; string end so as to point to the start of the next string.
; NOTE that this routine updates the CURX screen address. This is
; vital for all printing functions.
;----------------------------------------------------------------
;
print:
	ld	a,(de)
	inc	de
	or	a
	ret	z
	cp	'$'			; END ?
	ret	z
	cp	0			; END ?
	ret	z
	call	coe
	ld	a,(curx)
	inc	a
	ld	(curx),a		; loaded.updated.saved
	jr	print
;;
;; Print but at row,col (first two bytes in string)
;;
printxy:
	call	setxy
	jr	print

;;
;; Inline print at row,col (first two bytes in string)
;;
inlinexy:
	ex	(sp),hl			; get address of string (ret address)
	push	af
	push	de
	ex	de,hl
	call	setxy
	jr	inline2

;;
;; Inline print
;;
inline:
	ex	(sp),hl			; get address of string (ret address)
	push	af
	push	de
	ex	de,hl
inline2:
; 	LD	A,(DE)
; 	INC	DE			; point to next character
; 	CP	'$'
; 	JR	Z,INLINE3
; 	CP	0
; 	JR	Z,INLINE3
; 	CALL	COE
; 	JR	INLINE2
	call	print
inline3:
	ex	de,hl
	pop	de
	pop	af
	ex	(sp),hl			; load return address after the '$'
	ret				; back to code immediately after string


; output A to console
coe:
	push	bc
	ld	c,a
	call	bbconout
	pop	bc
	ret

;------------------------------------------------------------
; Programming routines
;------------------------------------------------------------

;;
;; Burn table on eeprom
;;
burntable:
	ld	a,imtpag		; eeprom images table page
	ld	(edestpag),a
	ld	hl,ramtbl		; updated table in ram
	ld	(esourceadr),hl
	ld	hl,imtsiz		; table size
	ld	(eimgsize),hl
	ld	hl,0			; clear count buffer
	ld	(cnvbuf),hl
	call	eeprogram		; do it ! .... brrrr .....
	ret

;;
;; Burn image on eeprom
;;
burnimage:
	; here we do the work on 4k page basis
	ld	a,(curpag)		; destination (base) page in eeprom
	ld	(edestpag),a
	ld	hl,imgorg		; image location ($1000)
	ld	(esourceadr),hl
mltpage:
	ld	hl,(cursiz)		; image size
	ld	de,4096
	or	a			; clear carry
	sbc	hl,de			; lesser than one page ?
	jr	c,onepage		; yes
	ld	hl,4096			; no
	jr	do4k
onepage:
	ld	hl,(cursiz)		; reload image size
do4k:	ld	(eimgsize),hl

	ld	hl,0			; clear count buffer
	ld	(cnvbuf),hl
	call	eeprogram		; write page
	ld	hl,(cursiz)		; reload image size
	ld	de,4096			; page size
	or	a			; clear carry
	sbc	hl,de			; subtract to get remaining size
	jr	c,bimexi
	jr	z,bimexi
	ld	(cursiz),hl		; left bytes
	ld	a,(edestpag)		; write another page...
	inc	a
	ld	(edestpag),a		; next page
	ld	hl,(esourceadr)
	ld	de,4096
	add	hl,de
	ld	(esourceadr),hl
	jr	mltpage
bimexi:
	ret

;------------------------------------------------------------
; Data storage of string addresses and cursor addresses.
;
nxtadr:	defb	00,00			; current string address
conadr:	defb	00,00			; address of a console buffer
mnuadr:	defb	00,00			; address of a menu string
itmnum:	defb	00			; menu item number counter
;
bufx:	defb	00			; buffer start screen x value
bufy:	defb	00			; buffer start screen y value
;
curx:	defb	00			; loaded by setxy
cury:	defb	00			; as above
;
hlsave:	defb	00,00
bcsave:	defb	00,00			; preserve registers in these
temp:	defb	00,00			; save cons. character temp.
;
cnvbuf:	defs	2			; conversion buffer
curblk:	defs	1			; working block number
curpag:	defs	2
curadr:	defs	2
cursiz:	defs	2
spreg:	defw	0
flagfake:
	defb	0			; fake operations nothing will be saved
flagburn:
	defb	0			; burn image
;
editmsk:
	defb	14,02,"Name ......: $"
	defw	iname
	defb	15,02,"EEPROM page: $"
	defw	ieaddr
	defb	16,02,"IMG addr ..: $"
	defw	iiaddr
	defb	17,02,"Size ......: $"
	defw	isize
	defb	18,02,"Description: $"
	defw	idesc
	defb	$ff			; end of table

iname:	defb	8,0			; 8 image name
bname:	defs	8
ieaddr:	defb	2,0			; 4 hexadecimal image location in eeprom (4k page bound)
beaddr:	defs	2
iiaddr:	defb	4,0			; 4 hexadecimal image ram address
biaddr:	defs	4
isize:	defb	4,0			; 4 hexadecimal image size
bsize:	defs	4
idesc:	defb	20,0			; image description
bdesc:	defs	20


edtcpy:	defb	8,0			; editor clear copy
	defs	8
	defb	2,0
	defs	2
	defb	4,0
	defs	4
	defb	4,0
	defs	4
	defb	20,0
	defs	20
edtsiz	equ	$ - edtcpy

edtsys:	defb	8,8			; sysbios fixed entry
	defb	"SYSBIOS "
	defb	2,2
	defb	"C0"
	defb	4,4
	defb	"F000"
	defb	4,4
	defb	"4000"
	defb	20,20
	defb	"SYSTEM BIOS/MONITOR "

msep:	defb	" - ",0
	;
;-------------------------------------
; Needed modules
include modules/eeprom.inc.asm		; eeprom


sysb3lo:
	defs	sysbios3 + $0bff - sysb3lo
sysb3hi:
	defb	$00
;;
;; end of code - this will fill with zeroes to the end of
;; the image

;-------------------------------------

if	mzmac
wsym sysbios3.sym
endif
;
;
	end
;
