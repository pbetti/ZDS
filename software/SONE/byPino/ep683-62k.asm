;
;
;
;********************************************************
;*							*
;*		N E W   R O M   Vers. 4.8		*
;*		    For N.E. Computer			*
;*							*
;********************************************************
;
;
	.title  Rom 4.8 for NE CP/M 2.2 with Hard-Disk
	;subttl	Copyright Studio Lg, Genova - Last rev 18/08/1984 17:30
;	Programmer: Martino Stefano
;	All Modified by Gallerani Paolo
;
;
;
vers	.equ	'H'		; Version for Hard-Disk
rev	.equ	48		; Revision level
;
;
false	.equ	0
true	.equ	1
;
;
rom	.equ	0f800h		; <--- rom start
necnt	.equ	true		; fdd controller by n.e.
mdcnt	.equ	false		; fdd controller by micro design
md80vid	.equ	false		; video int. 80*24 by micro design
ne80vid	.equ	true		; video int. 80*24 by n.e.
hard	.equ	true		; hard disk with xebec cnt
;
;
;********************************************************
;*							*
;*		Ram data areas equates			*
;*							*
;********************************************************
;
ram	.equ	00040h		; top of ram data areas
fd0otr	.equ	ram		; fdd0 old track num.	
fd1otr	.equ	ram+1		; fdd1 old track num.	
fd2otr	.equ	ram+2		; fdd2 old track num.	
fd3otr	.equ	ram+3		; fdd3 old track num.	
unit	.equ	ram+4		; fdd old unit select
hladrs	.equ	ram+5		; two byte for HL save
pnt.ix	.equ	ram+7		; routines table address
spare	.equ	ram+9		; not used
task	.equ	ram+10		; six byte for wdd cmd out
ipldma	.equ	01000h		; IPL dma address
stack	.equ	ipldma		; stack ram area for IPL
;
;
;********************************************************
;*							*
;*		ASCII EQUIVALENTS			*
;*							*
;********************************************************
;
bell	.equ	'G'-'@'		; ring beeper
backsp	.equ	'H'-'@'		; back space char.
ffeed	.equ	'L'-'@'		; form feed char.
cr	.equ	'M'-'@'		; carriage-return char.
lf	.equ	'J'-'@'		; line-feed char.
endmsg	.equ	'$'		; end of print message
;
;
;********************************************************
;*							*
;*			ROM				*
;*							*
;********************************************************
;
	.org	rom		; EPROM PC
;
	jp	reset		; jmp here to hardware reset
	jp	cin		; console input
	jp	cout		; console output
	jp	csts		; console status
	jp	lout		; printer output
	jp	lsts		; printer status
	jp	fdios		; fdd I/O 128 byte
	jp	fdiod		; fdd I/O 256 byte
	jp	wdini		; wdd initialization
	jp	wdio		; wdd I/O 256 byte
	jp	strout		; print string -> DE until endmsg
	jp	boot		; load IPL and exec. it
	jp	printat		; print string -> DE until endmsg at cursor -> HL
	jp	movcurs		; move video cursor at -> HL
	jp	initialize	; initialize video
;
CompFlg:
	.byte	rev		; current revision level
;
;
;
;********************************************************
;*							*
;*		    Rom data areas			*
;*							*
;********************************************************
;
DPBIPL:	;
	; Disk Parameter Block
	; for fd & wd IPL boot
	;
	.byte	0		; first unit & side 0
	.word	0		; first track  = 0000
	.byte	1		; first sector = 1
	.word	ipldma		; ipl dma address
	.byte	0		; read code
	.byte	1		; 1 sector read
				; for wdd read
;
;
;
inimsg:
	.byte	ffeed,cr,lf,19,'L'
	.text	"  NEW FIRMWARE Vers. "
	.byte	vers
	.text	" rev "
	.byte	rev/10+'0','.',rev%10+'0'
	.text	"  "
	.byte	19,'@',bell,cr,lf,endmsg
;
;
;********************************************************
;*							*
;*	      Jump here after hardware reset		*
;*							*
;********************************************************
;
reset:
	xor	a			; clear accumulator
	out	(fddlch),a		; deselect any drive
	ld	sp,stack		; set stack pointer
	ld	hl,ram			; top of ram data areas
	ld	b,16			; number of byte to clear
rst00:
	ld	(hl),a			; clear ram
	inc	hl			; inc. ram pointer
	djnz	rst00			; repeat until end of ram data areas
	ld	ix,ipldma+500h		; IX = reset routines table
	call	initialize		; initialize video and video table
;
	ld	de,inimsg		; D.E = initial message
	call	strout			; print it
;
;
	#if	hard			;
;
;
;************************************************
;* W D B O O T					*
;* Do Boot according if there is		*
;* Hard Disk interface and reading errors	*
;* else boot from Floppy			*
;************************************************
;
; Last Revision 08/05/85 17:18 by Gallerani Paolo
;
	; Now test if there are hard disk interface
;
	in	a,(rport1)		; load cntlr status
	and	11100000b		; mask bit 5,6,7. Hard disk exist ?
	jr	nz,fdbtwt		; no, then go to fdd boot
;
;
	out	(wport1),a		; reset hard cntrl
	ld	de,wdfdmsg		; D.E = question message
	call	pr_AT_12.12		; print it @ 12,12
;
;
WaitKey:
	; wait for push 'F' or wdd ready
	call	csts			; get console status
					; key pushed ?
	jr	z,CkRdy			; no, then check for wdd ready
	call	cin			; wait one char.
	res	5,a			; convert up-case
	cp	'F'			; is 'F' ?
	jr	nz,WaitKey		; no, then ignore
	;
	; Selected boot from floppy
	; Wait for Hard-Disk ready
	;
	ld	de,fdbtmsg		; D.E = 'ok for .. ' message
	call	pr_AT_12.12		; print it @ 12,12
;
WtHdRdy:
	call	wtwdrdy			; wdd ready ?
	jr	nz,WtHdRdy		; no, loop
	call	wdini			; yes, then initialize wdd
	jr	FddBot			; and go to fdd boot
;
CkRdy:
	call	wtwdrdy			; wdd ready ?
	jr	nz,WaitKey		; no, return to test console
	call	wdini			; else can initialize wdd
	xor	a			; set A=0 for wdd boot
	jr	WdBoot			; do boot
;
; Wait aproax 3 seconds
; then boot from floppy
;
fdbtwt:
	ld	b,4
timer:
	ld	de,8000h		; set soft timer
timer1:
	dec	de			; timer 1 down
	ld	a,e			;
	or	d			;
	jr	nz,timer1		;
	djnz	timer			; timer 2 down
;
; Restore Unit 1 (option)
;
FddBot:
	ld	a,2			;
	out	(fddlch),a		; set unit 1
	xor	a			; restore cmd without verify
	out	(fddcmd),a		; send out to 1771
	call	waitfd			; wait until end command
	jr	FdBoot			; set boot from FDD
;
;
;
; ***********************************************
; *		Boot Entry point		*
; *	If A=0 then boot from Hard else Floppy	*
; ***********************************************
;
boot:
	or	a			; Is A = 0 ?
	jr	nz,FdBoot		; no, then go to fdd boot
;
;
; ***********************************************
; *		Boot from Hard			*
; ***********************************************
;
WdBoot:
	push	af			; save flag
	ld	hl,DPBIPL		; H.L -> IPL boot para adrs
	call	wdio			; read one sector
	;
	; Check for Errors
	; then test for IPL ok
	;
ipltest:
	or	a			; read error ?
	jr	nz,ioerr		; yes, then goto I/O error
	; test for IPL
	ld	hl,ipldma+6		; H.L = IPL message
	ld	a,(hl)			; get 1' char.
	cp	'I'			; is 'I' ?
	jr	nz,noipl		; no, then go to no IPL
	inc	hl			; H.L point next char.
	ld	a,(hl)			; get 2' char.
	cp	'P'			; is 'P' ?
	jr	nz,noipl		; no. then go to no IPL
	inc	hl			; H.L point next char.
	ld	a,(hl)			; get 3' char.
	cp	'L'			; is 'L' ?
	jr	nz,noipl		; yes, then goto IPL ok
	;
	; IPL has been loaded
	; compute entry point
	;
iplok:
	pop	af			; IPL Flag
	or	a			;
	jp	z,ipldma		; if A = 0 then wdd bios boot
	jp	ipldma+3		; 	   else fdd bios boot
	;
	;
	;
	; ***** No IPL Error *****
noipl:
	ld	de,noiplmsg		; D.E = no IPL message
	jr	io.01			; print it and retry
	;
	; Print I/O error msg then boot from floppy
	; ***** I/O Error *****
ioerr:
	ld	de,ioermsg		; D.E = I/O error message
io.01:
	call	strout			; print it
	pop	af			; take off boot flag
	ld	de,setnew		; D.E = set new disk message
	call	strout			; print message
waitcr:
	call	cin			; wait one char.
	cp	cr			; is return ?
	jr	nz,waitcr		; no, wait cr
	ld	c,bell			;
	call	cout			; ring beeper
;
;
; ***********************************************
; *		Boot from floppy 0		*
; ***********************************************
; Recalibrate Unit 0, then load IPL from it
;
FdBoot:
	ld	a,1			;
	out	(fddlch),a		; set unit 0
	push	af			; use for Boot from floppy flag
	call	fdsek0			; move fdd head to track 0
	ld	hl,DPBIPL		; H.L -> IPL boot para adrs.
	call	fdiod			; read one sector
	jr	ipltest			; check for errors
;
;
;************************************************
;*						*
;*		Data area			*
;*						*
;************************************************
;
wdfdmsg:
	.text	"Push [F] for boot from floppy disk or wait hard disk ready"
	.byte	endmsg
;
fdbtmsg:
	.byte	bell
	.text	"Ok for boot from floppy disk. Wait until hard disk ready. "
	.byte	endmsg
;
;
ioermsg:
	.byte	cr,lf,19,'H'
	.text	"DISK ERROR"
	.byte	endmsg
;
noiplmsg:
	.byte	cr,lf,19,'H'
	.text	"No IPL on disk."
	.byte	endmsg
;
setnew:
	.byte	cr,lf
	.text	"Set system diskette in disk A,"
	.byte	cr,lf
	.text	"and push return"
	.byte	19,'@',bell,endmsg
;
	#endif	; hard
;
;
;********************************************************
;*							*
;*		   Console routines			*
;*							*
;********************************************************
;
	#if	ne80vid
;
;********************************************************
;*							*
;*	    Video, Keyboard, Printer routines		*
;* 	       for video interface 80*24		*
;*		 by Nuova Eletronica			*
;*							*
;********************************************************
;
;
; Copyright (C) 1983, 1984 by Studio Lg, Genova - Italy
; Author: Martino Stefano
; Third Modify by Gallerani Paolo
; Last Revision 06/08/84 21:00
;
; Compatibility Version 4.1-1
;
	#if	rev < 41
	.echo	".*** Warning:Incompatible Video Board Driver ***."
	#endif	; rev < 41
;
;
strvid	.equ	0		; start video cursor
endvid	.equ	77fh		; end video cursor
;
;	*****  PIO command code  ****
;
mode0	.equ	00fh		; mode 0 command code (output)
mode1	.equ	04fh		; mode 1 command code (input)
mode2	.equ	08fh		; mode 2 command code (bidiretional)
mode3	.equ	0cfh		; mode 3 command code (bit control)
;
;
ioadd	.equ	080h		; i/o port top address
;
	; PIO 0 data and control port address
data0a	.equ	ioadd+0		; read/write ram 0
data0b	.equ	ioadd+1		; write printer
cont0a	.equ	ioadd+2
cont0b	.equ	ioadd+3
;
	; PIO 1 data and control port address
data1a	.equ	ioadd+4		; read/write ram 1
data1b	.equ	ioadd+5		; read keyboard
cont1a	.equ	ioadd+6
cont1b	.equ	ioadd+7
;
	; PIO 2 data and control port address
data2a	.equ	ioadd+8		; read/write ram 2
data2b	.equ	ioadd+9		; board flag
cont2a	.equ	ioadd+10
cont2b	.equ	ioadd+11
;
;
addreg	.equ	ioadd+12		; 6545 address register port
datreg	.equ	ioadd+13		; 6545 register port
;
vidatr	.equ	ioadd+14		; video ram attribute
;
beep	.equ	ioadd+15		; beeper port address
;
;
;	*****  board flag  (data2b)  *****
;
;	bit	direction	    function
;
;	 0	  <---		   Printer Busy
;	 1	  --->		1 = 40  0 = 80 char/line
;	 2	  --->		      Spare
;	 3	  --->		      Spare
;	 4	  <---		      Spare
;	 5	  <---		      Spare
;	 6	  <---		      Spare
;	 7	  <---		      Spare
;
;
;	*****  Video Attributes  (vidatr)  *****
;
;	bit	direction	    function
;
;	 0	  <--->		    Blinking
;	 1	  <--->		    Reverse
;	 2	  <--->		  Under-score
;	 3	  <--->		   High-light
;	 4	  <--->		    Graphics
;	 5	   ---		    Not used
;	 6	   ---		    Not used
;	 7	   ---		    Not used
;
;
;
;
;********************************************************
;* L s t S						*
;*		Return printer status			*
;********************************************************
;
lsts:
	in	a,(data2b)	; read board flag
	and	00000001b	; mask printer busy bit
	dec	a		; 0 -> ff, 1 -> 00
	ret			;   0 printer not ready
				; 255 printer ready
;
;
;********************************************************
;* L O u t						*
;*		Print char on printer			*
;********************************************************
;
lout:
	in	a,(data2b)	; wit printer ready
	bit	0,a		;
	jr	nz,lout		;
	ld	a,c		; load char. to print
	out	(data0b),a	; send out to printer
	ret			; and ret
;
;
;********************************************************
;* C S t s						*
;*		Return console status			*
;********************************************************
;
csts:
	in	a,(data1b)	; read console
	and     10000000b	; only strobe
	rlca			; to bit 1
	dec	a		; 1 -> 0, 0 -> ff
	ret			; 0 if no key pushed
				; 255 if key pushed
;
;
;********************************************************
;* C I n						*
;*		Wait a Key from console			*
;********************************************************
;
cin:
	ld	ix,(pnt.ix)	; IX = routines table
	in	a,(data1b)	; wait pushed key
	bit	7,a		;
	jr	nz,cin		;
	push	af		; save key
cinp00:
	in	a,(data1b)	; wait depress key
	bit	7,a		;
	jr	z,cinp00	;
	pop	af		; restore pushed key
	xor	01111111b	; complements
	bit	5,(ix+004)	; key beep bit on ?
	jr	nz,cinp11	; no, then count
	out	(beep),a	; yes, then ring bell
cinp11:
	bit	6,(ix+004)	; alpha lock bit on ?
	ret	nz		; no, then return
	cp	'a'		; yes, then convert upper case
	ret	c		; ret if A < 'a'
	cp	'z'+1		;
	ret	nc		; ret if A > 'z'
	res	5,a		; convert up-case
	ret			; and ret
;
;
;********************************************************
;* C O u t						*
;*		Print char on console			*
;********************************************************
;
cout:
	ld	ix,(pnt.ix)	; IX = routines table
	ld	l,(ix+000)	; load video pointer (L)
	ld	h,(ix+001)	; load video pointer (H)
	ld	a,(ix+005)	; load prefix location
	or	a		; any prefix are set ?
	jr	nz,pfxset	; yes, then goto prefix set
	ld	a,c		; load char. to print
	cp	' '		; if char. < space
	jp	c,cntchar	; then go to control caracter
	call	charout		; print char. at HL
	inc	hl		; increase video pointer
cout11:
	call	vidcompare	; end of screen ?
	jr	c,cout00	; no, then count
	ld	de,0ffb0h	;
	add	hl,de		;
	call	updtdstart	; update display start (scrolling)
cout00:
	ld	(ix+000),l	; save video pointer
	ld	(ix+001),h	;
	call	updtvid		; update video pointer
	ret			; and ret
;
;
pfxset:
	; any prefix are set
	ld	iy,pfxtab-2	; IY -> prefix table
	add	a,a		; A prefix code * 2
	ld	e,a		;
	ld	d,0		; DE = pfx * 2
	add	iy,de		; IY -> pfx routine address
	ld	de,clrpfx	; DE = clear prefix address
	push	de		; store in stack
	ld	e,(iy+000)	;
	ld	d,(iy+001)	; DE = pfx routine address
	push	de		; store in stack
	ld	a,c		; A = char. to print
	ret			; and go to pfx routine
;
;
pfxtab:
	.word	pfx01		; video attribute prefix
	.word	pfx02		; cursor off/on	prefix
	.word	pfx03		; scroll/no scroll
	.word	pfx04		; keyboard normal/alpha look prefix
	.word	pfx05		; escape prefix
	.word	pfx06		; ESC '+' prefix
	.word	pfx07		; ESC '=' prefix
	.word	pfx08		; ESC '+' Yco prefix
	.word	pfx09		; ESC '=' Yco prefix
	.word	pfx10		; keyboard mute/beep
;
;
;
pfx01:
	; set video attribute
	sub	'@'		; subcrtact offset
	cp	16		; max number attribute
	ret	nc		; ret if A > 15
	cpl			; complements
	ld	b,a		; save video attribute on B
	ld	a,(ix+004)	; load old video attribute
	or	00011111b	; clear old attribute
	and	b		; mask new attribute with scroll and keyb. para
	ld	(ix+004),a	; set new video attribute
	ret			; and return
;
;
;
pfx03:
	; set scroll/no scroll
	bit	0,a		; is pair
	jr	nz,pfx033	; no, then no scrolling
	set	7,(ix+004)	; set scrolling flag
	ret			; and ret
pfx033:
	res	7,(ix+004)	; reset scrolling flag
	ret			; and ret
;
;
pfx04:
	; set keyboard normal/alpha lock
	bit	0,a		; is pair
	jr	nz,pfx044	; no, then alpha lock
	set	6,(ix+004)	; set normal keyb.
	ret			; and ret
pfx044:
	res	6,(ix+004)	; set alpha lock keyb
	ret			; and ret
;
;
pfx10:
	; set keyboard mute/beep
	bit	0,a		; is pair
	jr	nz,pfx101	; no, then beep key
	set	5,(ix+004)	; set mute keyb.
	ret			; and ret
pfx101:
	res	5,(ix+004)	; set beep keyb.
	ret			; and ret
;
;
pfx05:
	; escape prefix (move cursor and graphics)
	pop	de		; take off clear prefix address
	cp	'+'		; is '+' ?
	jr	nz,pfx055	; no, then retry

;
	; ESC '+'
	ld	(ix+005),6	; set ESC '+' prefix
	ret			; and return
;
pfx055:
	cp	'='		; is '=' ?
	jp	nz,clrpfx	; * no, then retry
;
	; ESC '='
	ld	(ix+005),7	; set ESC '=' prefix
	ret			; and return
;pfx056:
; ESC 'graphics comands'
; da implementare
;
;pfx05end:
;	push	de		; set clear prefix address
;	ret			; go to it
;
;
pfx06:
	; compute Yco in ESC '+'
	call	relcompute	; subct. offset and return X,Y curs. pos.
	jr	nz,pfx066	; BIT 7 of A = 1 then cursor <--
	add	a,h		; BIT ' of A = 0 then cursor -->
	jr	pfx067		;
pfx066:
	sub	h		; compute Yco
	neg			;
pfx067:
	ld	b,24		; max Yco
	call	xy1compare	; compare A with max Yco
	ld	(ix+006),a	; set new Yco
	ld	a,8		; set ESC '+' Yco prefix
	jp	setpfx		; restore clear prefix address
;
pfx08:
	; compute Xco in ESC '+' and move cursor
	call	relcompute	; subct. offset and return X,Y curs. pos.
	jr	nz,pfx088	; BIT 7 of A = 1 then cursor up
	add	a,l		; BIT ' of A = 0 then cursor down
	jr	pfx089		;
pfx088:
	sub	l		; compute Xco
	neg			;
pfx089:
	ld	b,80		; max Xco
	call	xy1compare	; compare A with max Xco
	jr	pfx099		; compute cursor address and set it
;
relcompute:
	sub	' '		; subctract offset
	push	af		; save relative Xco or Yco
	ld	bc,80		; BC = char/row
	call	divide		; compute actual Xco and Yco
	ld	h,a		; H = Yco, L = Xco
	pop	af		; restore relative X/Y
	bit	7,a		; set flag for plus or minus
	res	7,a		;
	ret			; and ret
;
;
pfx07:
	; compute Yco in ESC '='
	ld	b,24		; max Yco
	call	xycompare	; compare with max Yco
	ld	(ix+006),a	; set Yco
	ld	a,9		; set ESC = '=' Yco prefix
	jp	setpfx		; restore clear prefix address
;
pfx09:
	; compute Xco in ESC '=' and move cursor
	ld	b,80		; max Xc0
	call	xycompare	; compare with max Xco
pfx099:
	ld	l,(ix+006)	;
pfx09a:
	ld	h,0		; HL = Yco
;
	add	hl,hl		; multiplay Yco per 16
	add	hl,hl		; multiplay Yco per 16
	add	hl,hl		; multiplay Yco per 16
	add	hl,hl		; multiplay Yco per 16
;
	push	hl		; save Yco * 16
;
	add	hl,hl		; multiplay Yco per 16
	add	hl,hl		; multiplay Yco per 16
;
	pop	de		; DE = Yco * 16
	add	hl,de		; HL = Yco * 80
	ld	e,a		;
	ld	d,0		; DE = Xco
	add	hl,de		; HL = Yco*80 + Xco
setnwcpos:
	; set new cursor position
	ld	(ix+007),l	; set last cursor position
	ld	(ix+008),h	;
	jp	cout00		; set new video pointer and ret
;
;
movcurs:
	; move cursor at H = Yco, L = Xco
	ld	ix,(pnt.ix)	; IX = routines table
	ld	a,h		; load Yco
	ld	b,24		; max Yco
	call	xy1compare	; compare with max Yco
	ld	a,l		; load Xco
	ld	b,80		; max Xco
	call	xy1compare	; compare with max Xco
	ld	l,h		; L = Yco, A = Xco
	jr	pfx09a		; compute cursor address, move it and ret
;
;
xycompare:
	; A = Xco or Yco + offset, B = max Xco or Yco
	sub	' '		; subctract offset
xy1compare:
	cp	b		; compare with max Xco or Yco
	ret	c		; ret if A < Xco or Yco
	out	(beep),a	; ring beeper
	pop	de		; restore normal return address
	ret			; and retunr to clear prefix
;
;
clrpfx:
	; clear prefix
	ld	(ix+005),0	; clear prefix
	ret			; and ret
;
;
cntchar:
	; control character
	cp	4		;
	ret	c		; ret if char. < 4
	cp	28		;
	ret	nc		; ret if char. > 27
	ld	de,cout00	; DE = return address
	push	de		; store in stack
	ld	iy,chrtab - 8	; IY -> chr$ table (char 4 - 27)
	add	a,a		; A = A*2
	ld	e,a		;
	ld	d,0		;
	add	iy,de		; IY -> chr$ routine address
	ld	e,(iy+000)	; load routine address (L)
	ld	d,(iy+001)	; load routine address (H)
	push	de		; put it on stack
	ld	de,80		; DE = char for line for utility
	ret			; go to chr$(xx) routine
;
chrtab:
	; control character table
	.word	chr04		; move cursor at last addressement
	.word	chr05		; clear to end of line
	.word	chr06		; clear to end of screen
	.word	chr07		; beeper
	.word	chr08		; cursor left (back space)
	.word	nochr		; not implemented
	.word	chr10		; cursor down (line feed)
	.word	chr11		; cursor beginning of screen (home)
	.word	chr12		; clear screen
	.word	chr13		; cursor beginning of line (carriage return)
	.word	chr14		; cursor right
	.word	chr15		; cursor up
	.word	nochr		; not implemented
	.word	nochr		; not implemented
	.word	nochr		; not implemented
	.word	chr19		; video attribute prefix
	.word	chr20		; cursor off/on	prefix
	.word	chr21		; scroll yes/no prefix
	.word	chr22		; keyboard normal/alpha look prefix
	.word	chr23		; keyboard mute/beep
	.word	nochr		; not implemented
	.word	nochr		; not implemented
	.word	nochr		; not implemented
	.word	chr27		; cursor and graphics prefix
;
;
chr19:
	; video attribute prefix
	ld	a,001		; set pfx code
	jr	setpfx		; and ret
;
;
chr20:
	; cursor off/on prefix
	ld	a,002		; set pfx code
	jr	setpfx		; and ret
;
;
chr21:
	; scroll/no scroll prefix
	ld	a,003		; set pfx code
	jr	setpfx		; and ret
;
;
chr22:
	; keyboard normal/alpha look prefix
	ld	a,004		; set pfx code
	jr	setpfx		; and ret
;
;
chr23:
	; keyboard mute/beep prefix
	ld	a,010		; set pfx code
	jr	setpfx		; and ret
;
;
chr27:
	; escape prefix
	ld	a,005		; set pfx code
				; and ret
;
setpfx:
	ld	(ix+005),a	; set prefix code
;
nochr:
	pop	de		; restore cout00 return address
	ret			; and return to caller
;
;
chr07:
	; beeper
	out	(beep),a	; ring beeper
	jr	nochr		; and ret
;
;
chr04:
	; move cursor at last addressement
	ld	l,(ix+007)	; load last cursor position
	ld	h,(ix+008)	;
	ret			; set it and return
;
;
chr10:
				; DE = char. for line
	add	hl,de		; HL point to next line
	pop	de		; restore return address
	jp	cout11		; and go to eventually scrolling
;
chr11:
	; move cursor at start of screen
	ld	hl,strvid	; HL = start video
	ret			; return
;
;
chr14:
	; cursor right
	inc	hl		; increase video pointer
	call	vidcompare	; end of screen + 1 ?
	ret	c		; no, then ret
	dec	hl		; dec. video pointer
	ret
;
chr08:
	; back space
	ld	de,1		; DE = one char. to subctract
				; go to subctract HL with DE
;
chr15:
	; cursor up
				; DE = character for line
;
subpointer:
	xor	a		; clear carry
	sbc	hl,de		; HL = video pointer - one line
	ret	nc		; ret if HL >= start video
	add	hl,de		; restore originally video pointer
	ret			; and ret
;
;
;	*****  various routines entry point  *****
;
;
charout:
	; send out character contained in A register at HL cursor position
	push	de		; save register
	push	hl		;
	push	af		;
	call	updtvid		; update video pointer
	pop	af		; restore char. to print
	call	sendout		; send out to RAM 0
	pop	hl		; restore register
	pop	de		;
	ret			; and ret
;
;
sendout:
	; send out character contained in reg. A to video RAM 0
	push	af		; save character
sendo0:
	in	a,(addreg)	; load 6545 status
	bit	7,a		; test sync bit
	jr	z,sendo0	; wait if busy
	ex	(sp),hl		; delay
	ex	(sp),hl		; delay
	ld	a,(ix+004)	; load video attribute
	or	11110000b	; mask video attribute
	out	(vidatr),a	; send out on video attribute ram (RAM 3)
	pop	af		; restore char.
	push	af		; resave char.
	out	(data0a),a	; write char. on video ram (RAM 0)
	xor	a		; clear accumulator
	out	(datreg),a	; write 0 to register 6545
	pop	af		; restore character
	ret			; and ret
;
;
vidcompare:
	; compare for HL = endvid+1
	push	hl		; save video pointer
	ld	de,endvid+1	; DE = end video + 1
	xor	a		; clear carry
	sbc	hl,de		; subctract HL with DE
	pop	hl		; restore video pointer
	ret			; and ret
;
pfx02:
	; set cursor off/on
	bit	0,a		; is pair
	jr	nz,curson	; no, then cursor on
				; yes, then cursor off
;
;
cursoff:
	; cursor off
	ld	b,00100000b	; no cursor type
outdat:
	ld	a,10		; cursor start register
	out	(addreg),a	; set 6545 cursor start register
	ld	a,b
	out	(datreg),a	; send out to 6545 cursor start register
;
setdummy:
	ld	a,31		; A = dummy location
	out	(addreg),a	; send out to 6545 register address
	ret			; and return
;
;
curson:
	; cursor on
	ld	a,10		; cursor start register
	out	(addreg),a	; set 6545 cursor start register
	ld	b,00000000b	; cursor fixed (blinking hardware)
	jr	outdat		; set it
;
;
updtvid:
	; update video pointer
	ld	e,(ix+002)	; load curently display start (L)
	ld	d,(ix+003)	; load curently display start (H)
	add	hl,de		; compute relative position
				; and count with updtcpur
updtcpur:
	; update 6545 cursor position and 6545 update register at HL
	ld	a,14		; cursor position (H) register
	out	(addreg),a	; set it
	ld	a,h		; load cursor address (H)
	out	(datreg),a	; set it
	ld	a,15		; cursor position (L) register
	out	(addreg),a	; set it
	ld	a,l		; load cursor address (L)
	out	(datreg),a	; set it
;
updtureg:
	; update 'update register' at HL
	ld	a,18		; update address (H) register
	out	(addreg),a	; set it
	ld	a,h		; load cursor address (H)
	out	(datreg),a	; set it
	ld	a,19		; update address (L) register
	out	(addreg),a	; set it
	ld	a,l		; load cursor address (L)
	out	(datreg),a	; set it
	jr	setdummy	; set dummy location and return
;
;
updtdstart:
	; update display start
	bit	7,(ix+004)	; test no scroll flag; is zero ?
	jr	z,noupdstart	; yes, then no scrolling
	push	hl		; save video pointer
	ld	l,(ix+002)	; load curently display start (L)
	ld	h,(ix+003)	; load curently display start (H)
	ld	de,80		; DE = char. for line
	add	hl,de		; point to next line
	res	3,h		;
	ld	(ix+002),l	; save curently display start (L)
	ld	(ix+003),h	; save curently display start (H)
	ld	a,12		; disp. start (H) register
	out	(addreg),a	; set it
	ld	a,h		; load disp. start address (H)
	out	(datreg),a	; set it
	ld	a,13		; disp. start (L) register
	out	(addreg),a	; set it
	ld	a,l		; load disp. start adress (L)
	out	(datreg),a	; set it
	ld	hl,endvid+1	; set new video pointer
	jr	cescr1		; go to clear to end screen
;
noupdstart:
	ld	bc,80		; BC = char/row
	call	divide		; HL = Xco
	ret			; and ret
;
;
chr05:
cendlin:
	; clear to end line starting at HL
	push	hl		; save video pointer
	call	cbeglin		; call cursor begin of line
	add	hl,de		;
	ex	de,hl		;
	pop	hl		; restore video pointer
	push	hl		; resave it
	jr	cescr0		; go to clear 'DE' char.
;
chr12:
	; clear screen
	ld	hl,strvid	; HL = start video
				; and clear to end of screen
;
chr06:
cendscr:
	; clear to end of screen starting at HL
	push	hl		; save video pointer
	ld	de,endvid +81	; DE = end video + one line + 1
cescr0:
	di			;
	xor	a		; clear carry
	ex	de,hl		; computer number of
	sbc	hl,de		; character then remaining
	ex	de,hl		; until end (line or screen)
cescr1:
	push	de		; save number of char.
	call	updtvid		; update video pointer
	pop	de		; restore char. number
cescr2:
	ld	a,d		; DE is zero ?
	or	e		;
	jr	z,cescr3	; yes, then exit
cescr4:
	in	a,(addreg)	; load 6545 status
	bit	7,a		; test sync bit
	jr	z,cescr4	; wait if busy
	ex	(sp),hl		; delay
	ex	(sp),hl		; delay
	ld	a,' '		; load space
	out	(data0a),a	; write char. on video ram (RAM 0)
	ld	a,11111111b	; video normal mode attribute
	out	(vidatr),a	; send out on video attribute ram (RAM 3)
	xor	a		; clear accumulator
	out	(datreg),a	; write 0 to register 6545
	dec	de		; dec. char counter
	jr	cescr2		; and count
cescr3:
	pop	hl		; restore video pointer
	ei			;
	ret			; and return
;
;
chr13:
cbeglin:
	; cursor beginning of line
	push	bc		; save register
	ld	b,d
	ld	c,e		; bc = char. for line
	call	divide		;
	ld	l,0		;
	ld	d,b		;
	ld	e,c		;
	pop	bc		; restore register
cbegl0:
	ret	z		;
	add	hl,de		;
	dec	a		;
	jr	cbegl0		;
;
;
divide:
	; division routine: divide HL with BC; quoto in A, resto in HL
	xor	a		; clear accumulator and carry flag
hl.gt.0:
	sbc	hl,bc		;
	inc	a		;
	jr	nc,hl.gt.0	;
	dec	a		;
	add	hl,bc		;
	ret
;
;
;
initialize:
	; PIO, 6545 and IX table initialization
;
	ld	(pnt.ix),ix	; set IX table address
	ld	a,mode2		; bidirectional mode
	out	(cont0a),a	; set port a PIO 0
	out	(cont1a),a	; set port a PIO 1
	out	(cont2a),a	; set port a PIO 2
	ld	a,mode3		; control mode
	out	(cont0b),a	;
	ex	af,af'		; save control mode
	ld	a,00000000b	; set i/o bit
	out	(cont0b),a	; set port b PIO 0
	ex	af,af'		; restore control mode
	out	(cont1b),a	;
	ex	af,af'		; save control mode
	ld	a,11111111b	; set i/o bit
	out	(cont1b),a	; set port b PIO 1
	ex	af,af'		; restore control mode
	out	(cont2b),a	;
	ld	a,11110001b	; set i/o bit
	out	(cont2b),a	; set port b PIO 2
;
	in	a,(data2b)	; read board flag
	res	1,a		; set 80 char for line
	out	(data2b),a	;
;
	ld	hl,tab6545	; HL -> 6545 initialization table
	ld	b,12		; data output counter
init00:
	ld	a,b		; load on a
	dec	a		;
	out	(addreg),a	; set 6545 register
	ld	a,(hl)		; get data for init
	out	(datreg),a	; send out on 6545 register
	inc	hl		; point to next data
	djnz	init00		; and count until are output
;
	ld	b,8		; filling rimanents register with 00
init01:
	ld	a,b		;
	add	a,11		;
	out	(addreg),a	; set 6545 register
	xor	a		; clear accumulator
	out	(datreg),a	; send out to 6545 register
	djnz	init01		; and count until all are output
;
	ld	a,31		; A = dummy location
	out	(addreg),a	; send out to 6545 register
;
	xor	a		; clear accumulator
	ld	hl,(pnt.ix)	; HL -> routines table
	ld	b,16		; 16 byte to clear
init02:
	ld	(hl),a		; clear byte of table
	inc	hl		; increase table pointer
	djnz	init02		; count until all are cleared
;
	dec	a		; initial video attribute, scroll flag,
				; no alpha look and mute keyboard
	ld	(ix+004),a	; set initial video attribute
	ret			; and return to caller
;
tab6545:
	; 6545 initialization table
;
;	.radix	16
;
	.byte	0bh,00h		; cursor end, cursor start
	.byte	0bh		; scan line-1
	.byte	48h		; mode control
	.byte	18h		; vert. sync position
	.byte	18h		; vert. displayed
	.byte	00h		; vert. total adjust
	.byte	1ah		; vert. total-1
	.byte	28h		; vsync, hsync widths
	.byte	57h		; horiz. sync position
	.byte	50h		; horiz. displayed
	.byte	6fh		; horiz. total-1
;
;	.radix	10
;
;
;
;
;
rdcpos:
	; read cursor pos and set update reg = cpos reg
	ld	a,14		; cursor position (H) register
	out	(addreg),a	; set it
	in	a,(datreg)	; read cursor address (H)
	ld	h,a		; store it in H reg.
	ld	a,15		; cursor position (L) register
	out	(addreg),a	; set it
	in	a,(datreg)	; read cursor address (L)
	ld	l,a		; store it in L reg.
	jp	updtureg	; and update 'update register'
;
	#endif	; ne80vid
;
;
;********************************************************
;*							*
;*		Print string pointed by DE		*
;*							*
;********************************************************
;
;
; *** Print @ position 12,12 ***
;
pr_AT_12.12: ld	hl,12 * 256 + 12 ; @ 12,12
;
;
; *** Print string @ position HL
;
printat:
	push	de		; save string pointer
	call	movcurs		; move cursor at HL
	pop	de		; restore str pointer and count
				; with strout
;
;
; *** Print string pointed by DE ***
;
strout:
	ld	a,(de)		; load char.
	cp	endmsg		; end message
	ret	z		; yes, then return
	ld	c,a		; else move to register C
	push	de		; save text pointer
	call	cout		; and print it
	pop	de		; restore text pointer
	inc	de		; point to next char
	jr	strout		; and repeat
	;
;
;
;********************************************************
;*							*
;*		   Floppy disk routines			*
;*							*
;********************************************************
;
;
	#if	necnt
;
;********************************************************
;*							*
;*	     Floppy disk driver and subroutine		*
;*	  For N.E. 5 Inc. floppy disk controller	*
;*							*
;********************************************************
;
; Copyright (C) 1983, 1984 by Studio Lg, Genova - Italy
; Author: Martino Stefano
; Third Modify by Gallerani Paolo
; Last Revision 06/08/84 21:00
;
; Compatibility Version 4.2-1
;
	#if	rev < 42
	.echo	".*** Warning:Incompatible Floppy Disk Driver ***."
	#endif	; rev < 42
;
rtycnt	.equ	3		; max retries before disk I/O error
rstcnt	.equ	2		; max restore before disk I/O error
	;
;
;
;********************************************************
;*							*
;*		FD 1771 I/O port			*
;*							*
;********************************************************
;
fddsts	.equ	0d0h		; fdd status port
fddtrk	.equ	0d1h		; fdd track port
fddsec	.equ	0d2h		; fdd sector port
fddlch	.equ	0d6h		; fdd lach port
fdddat	.equ	0d7h		; fdd data port
fddcmd	.equ	fddsts		; fdd command port
;
;
;********************************************************
;*							*
;*		FD 1771 Command Summary			*
;*							*
;********************************************************
;
fddrest	.equ	00000110b	; fdd restore command code
fddsek	.equ	00010110b	; fdd seek command code
fddrd	.equ	10001000b	; fdd read command code
fddwt	.equ	10101000b	; fdd write command code
fddrst	.equ	11010000b	; fdd reset int. command code
	;
;
;
;********************************************************
;*							*
;*		Routines Entry point			*
;*							*
;********************************************************
;
;
;
;********************************************************
;* F D I O S 	Fdd I/O 128 byte			*
;********************************************************
;
fdios:
	xor	a		; CY = 0 then 128 byte r/w
	jr	fdio		; go to common entry point
;
;
;********************************************************
;* F D I O D 	Fdd I/O 128 byte			*
;********************************************************
;
fdiod:
	scf			; CY = 1 then 256 byte r/w
;
;
fdio:
	ld	ix,(pnt.ix)	; IX = routines table
	set	0,(ix+009)	; set 256 byte r/w
	jr	c,fdio00	; jmp if cy = 1
	res	0,(ix+009)	; set 128 byte r/w
fdio00:
	ld	a,(hl)		; get unit num. and side
	ld	d,a		; save for side select
	and	00000011b	; mask bit 0 and bit 1 (unit num.)
	call	newdrv		; select drive and restore old trk num.
	inc	hl		; H.L track para adrs
	ld	(hladrs),hl
	ld	c,rstcnt	; C = restore count
rty00:
	ld	b,rtycnt	; B = retry count
rty01:
	push	bc
	ld	hl,(hladrs)	; H.L track para adrs
	ld	b,(hl)		; B = track num.
	inc	hl		; skip track hi byte for Wdd comp.
	inc	hl		; H.L sector para adrs
	ld	a,(hl)		; A = sector num.
	out	(fddsec),a	; set sector num.
	ld	a,b		; set new track
	out	(fdddat),a	; number and
	ld	a,fddsek	; execute seek
	out	(fddcmd),a	; command
	call	err1get		; wait until end command
	or	a		; error detect ?
	jr	nz,fdderchk	; yes ! go to error check
trkok:
	; track and sector are ok
	inc	hl		; H.L dma para adrs 
	ld	e,(hl)		; E = dma adrs low
	inc	hl		;
	ld	d,(hl)		; D = dma adrs high
	inc	hl		; H.L R/W para adrs (0 = read, 1 = write)
	bit	0,(ix+009)	; test bit 0 of (ix+009) for fdd num byte
	ld	a,128		; if bit 0 = 0 then 128 byte r/w
	jr	z,trkok1	;
	xor	a		; else 256 byte r/w
trkok1:
	ld	b,a		; B = num. byte to R/W
	ld	c,fdddat	; C = fdd data I/O port
;
	ld	a,(hl)		; A = R/W para
	ex	de,hl		; HL = dma adrs
	or	a		; test for read or write
	jr	nz,fdwrite	; if nz then write
fdread:
	; else fdd read
	ld	a,fddrd		; fdd read command
	out	(fddcmd),a	; exec. command
	call	fddelay		; wait aproax 56 microS
	jr	fdrd01
;
fdrd00:
	rrca			; busy bit --> CY
	jr	nc,fdioend	; if busy = 0 then end read
fdrd01:
	in	a,(fddsts)	; test fdd status
	bit	1,a		; data request active ?
	jr	z,fdrd00	; no ! then test busy bit
	ini			; read one byte
	jr	nz,fdrd01	; and wait until all are read
;
	jr	fdioend		; go to end fdio
fdwrite:
	; fdd write
	ld	a,fddwt		; fdd write command
	out	(fddcmd),a	; exec. command
	call	fddelay		; wait aproax 56 microS
	jr	fdwt01
;
fdwt00:
	rrca			; busy bit --> CY
	jr	nc,fdioend	; if busy = 0 then end write
fdwt01:
	in	a,(fddsts)	; test fdd status
	bit	1,a		; data request active ?
	jr	z,fdwt00	; no ! then test busy bit
	outi			; write one byte
	jr	nz,fdwt01	; and wait until all are write
;
fdioend:
	; end of read or write
	ld	h,b		; save byte counter
	call	err2get		; wait until end command
	or	a		; error occurs ?
	jr	nz,fdderchk	; then error check else A = 0
	or	h		; all byte are read or write ?
	ld	a,00000010b	; set density error
	jr	nz,fdderchk	; no, then i/o error
	xor	a		; clear accumulator for normal return
	pop	bc		; else restore BC
	jr	fddret		; and ret to call
;
;
fdderchk:
	; fdd check for any error
	pop	bc		; B = rtycnt. C = rstcnt
	push	af		; save fdd status
	and	00000011b	; bit 0 = time-out error
				; bit 1 = density error
	jr	nz,fddrt1	; ret if one
	pop	af		; restore fdd status
	dec	b		; retry count down
	jr	nz,rty01	; repeat until rtycnt = 0
	dec	c		; restore count down
	jr	z,fddret	; retry error return
	push	af		; save fdd status
	call	fdsek0		; fdd seek to track 0
	or	a		; error ?
	jr	nz,fddrt1	; then rty err
	pop	af		; restore fdd status
	jp	rty00		; and retry
fddret:
	push	af		; save fdd status
fddrt1:
	xor	a		; clear register A
	out	(fddlch),a	; deselect any drive
	pop	af		; restore fdd status
	ret			; and ret
;
;
fdsek0:
	; fdd seek to track 0
	push	bc		; save register
	ld	a,fddrest	; fdd restore command
	out	(fddcmd),a	; exec. command
	call	waitfd		; wait until end command
	pop	bc		; restore register
	ret			; and ret
;
;
err1get:
	; return error in A register for type 1 command
	call	waitfd		; wait until end command
	or	a		; time out error ?
	ret	nz		; yes, return to call
	ld	a,b		; else load fdd status
	and	00010000b	; mask bit 4 (seek error)
	sla	a		; move to bit 5
	ld	c,a		; save seek error bit
	ld	a,b		; reload fdd status
	and	00001000b	; mask bit 3 (crc error)
	or	c		; A: bit 3 = crc, bit 5 = seek
	ret			; return to call
;
err2get:
	; return error in A register for type 2 command
	call	waitfd		; wait until end comand
	or	a		; time out error ?
	ret	nz		; yes, return to caller
	ld	a,b		; load fdd status
	and	01011100b	; mask wrt-prtc,rnf,crc,lst-dat error
	ret			; and return
;
fddelay:
	ex	(sp),hl		; delay beetwen write command reg.
	ex	(sp),hl		; to read status reg.
	ex	(sp),hl		;
	ex	(sp),hl		;
	ret
;
waitfd:
	; wait until fdd busy is reset
	call	fddelay		; wait aproax 56 microS
	ld	b,2		; set soft timer
wait00:
	ld	de,0		; for aproax five seconds
wait01:
	in	a,(fddsts)	; input to fdd status
	bit	0,a		; test busy bit
	jr	z,wait02	; jump if no command is in progress
	dec	de		;
	ld	a,d		; timer down
	or	e		;
	jr	nz,wait01	;
	dec	b		;
	jr	nz,wait00	; time out
timeout:
	ld	a,fddrst	; reset fdd controller
	out	(fddcmd),a	; exec. command
	ld	a,00000001b	; set time-out bit error
	ret			; and ret
wait02:
	ld	b,a		; save fdd status in B register
	xor	a		; clear accumulator for
	ret			; normal return
;
newdrv:
	; select new drive and restore old trk num.
	push	hl		; save para pointer
	ld	c,a		;
	ld	b,0		; BC = new unit num.
	ld	hl,fddtab	;
	add	hl,bc		; HL. byte to select drive
	ld	e,(hl)		; E = byte to select drive
	ld	a,d		; A = unit num. and side
	and	00010000b	; mask bit 4 (side)
	sla	a		; move side to bit 5
	or	e		; A = unit + 5/8 sel + side
	out	(fddlch),a	; select new drive and side
	ld	hl,0044h	; H.L old unit num.
	ld	a,(hl)		; A = old unit num.
	cp	c		; old unit equ new unit ?
	jr	z,drvequ	; skip if yes
	ld	(hl),c		; save new unit num.
	ld	hl,fd0otr	;
	push	hl		;
	add	a,l		; * Version for less space (4/6)
	ld	l,a		;	add only low byte *
;;	ld	e,a		;
;;	ld	d,0		; DE = old unit num.
;;	add	hl,de		; H.L old trk of unit num.
	in	a,(fddtrk)	; save track num.
	ld	(hl),a		;of old unt num.
	pop	hl		;
	add	hl,bc		; H.L old trk of new unit num.
	ld	a,(hl)		; select old track
	out	(fddtrk),a	; num. of new unit
drvequ:
	pop	hl		; restore para pointer
	ret			; and ret
;
fddtab:
	; if fdd controller by n.e.
	.byte	01,02,04,08	; unit 0 to 3 are 5 inch (bit 5 = 0)
;
	#endif	; necnt
;
;
;********************************************************
;*							*
;*		    Hard disk routines			*
;*							*
;********************************************************
;
;
	#if	hard		; hard disk exist
;
; ***************************************
; * Size Table for			*
; *		Hard Disk BASF 6188	*
; ***************************************
;
;
Cyls	.equ	360		; number of cylinders
hCyls	.equ	01h		; high Cyls
lCyls	.equ	68h		; low Cyls
Heads	.equ	4		; number of heads
;
initab:
	.byte	hCyls,lCyls	; number of cylinders
	.byte	Heads		; number of heads
	.byte	0,128		; starting reduced current cylinder
	.byte	0,64		; starting write precompensation cylinder
	.byte	11		; maximum ECC data burst length
;
;
;
;********************************************************
;*							*
;*	Winchester disk driver and subroutine		*
;*							*
;********************************************************
;
; Copyright (C) 1983, 1984 Studio Lg, Genova - Italy
; Author: Martino Stefano
; Third Modify by Gallerani Paolo
; Last Revision 06/08/84 21:07
;
; Compatibility Versione 4.2-1
;
	#if	rev < 42
	.echo	".*** Warning:Incompatible Hard Disk Driver ***."
	#endif	; rev < 42
;
;
;
;********************************************************
;*							*
;*	HARD DISK OUTPUT AND INPUT PORTS		*
;*							*
;********************************************************
;
wport0	.equ	0b8h		; sasi write port 0 - write data
wport1	.equ	0b9h		; sasi write port 1 - software reset
wport2	.equ	0bah		; sasi write port 2 - cntlr select
wport3	.equ	0bbh		; sasi write port 3 - not used
rport0	.equ	0b8h		; sasi read port 0 - read data
rport1	.equ	0b9h		; sasi read port 1 - read status
rport2	.equ	0bah		; sasi read port 2 - not used
rport3	.equ	0bbh		; sasi read port 3 - not used
;
;********************************************************
;*							*
;*	HARD DISK VARIOUS EQUATES			*
;*							*
;********************************************************
;
reqbit	.equ	000h		; request line bit position
reqmsk	.equ	001h		; request mask for bit test
busybit	.equ	001h		; busy line bit posistion
busymsk	.equ	002h		; busy mask for bit test
msgbit	.equ	002h		; message line bit position
msgmsk	.equ	004h		; message mask for bit test
cdbit	.equ	003h		; command/data bit posistion
cdmsk	.equ	008h		; command/data mask for bit test
iobit	.equ	004h		; input/output bit position
iomsk	.equ	010h		; input/output mask for bit test
errmsk	.equ	002h		; test for an error
;
;********************************************************
;*							*
;*	HARD DISK CONTROLLER COMMAND EQUATES		*
;*							*
;********************************************************
;
drvrdy	.equ	000h		; test drive ready command
format	.equ	004h		; format command code
read	.equ	008h		; read command code
write	.equ	00ah		; write command code
sense	.equ	003h		; status sense command code
initl	.equ	00ch		; initialize disk size command
seek	.equ	00bh		; seek command size
recal	.equ	001h		; recalibrate command code
ramdiag	.equ	0e0h		; ram diagnostic command code
;
;
parowmsg:
	.byte	cr,lf,
	.text	"HardDisk Parameter overflow"
	.byte	endmsg
;
;
;
;********************************************************
;*							*
;*		Routines Entry point			*
;*							*
;********************************************************
;
;
wdio:
	; wdd i/o 256 byte
	in	a,(rport1)	; load cntlr status
	and	11100000b	; mask bit 5,6,7. Hard disk exist ?
	ret	nz		; ret in not
	ld	(hladrs),hl	; save r/w para adrs
wdio1:
	ld	a,(hl)		; A = unit & side
	ld	b,a		; save in B for unit
	and	00110000b	; mask side number
	srl	a		; move side number to bit 0,1
	srl	a		; move side number to bit 0,1
	srl	a		; move side number to bit 0,1
	srl	a		; move side number to bit 0,1
	cp	Heads/2		; test for side overflow
	jp	nc,parower	; if side > /Heads/2)-1 then para overflow
	bit	0,b		; test unit number
	jr	z,wdio2		; jump if unit 0
	add	a,(Heads/2)	;
wdio2:
	ld	c,a		; C = head address (0 to Heads-1)
	inc	hl		; H.L = track para adrs.
	ld	e,(hl)		; E = low byte track number
	inc	hl		; point to high byte
	ld	d,(hl)		; D = track hugh byte
	inc	hl		; point to sector
	push	hl		; save sec para pointer
	and	a		; cy=0
	ld	hl,Cyls-1	; Max # of Cyl
	sbc	hl,de		; compare with par
	jr	c,parov0	; overflow: out of disk bounds
	ld	hl,0		; reset product
	ld	b,h		; BC = head address
	add	hl,de		; HL = track * Heads
	add	hl,de		; HL = track * Heads
	add	hl,de		; HL = track * Heads
	add	hl,de		; HL = track * Heads
	add	hl,bc		; HL = (track * Heads) + head address
	add	hl,hl		; HL = (track * Heads + head address)*32
	add	hl,hl		; HL = (track * Heads + head address)*32
	add	hl,hl		; HL = (track * Heads + head address)*32
	add	hl,hl		; HL = (track * Heads + head address)*32
	add	hl,hl		; HL = (track * Heads + head address)*32
	ex	de,hl		; DE = (track * Heads + head address)*32
	pop	hl		; H.L = track para adrs.
	ld	a,(hl)		; A = sector number
	dec	a		; convert sector to base 0
	cp	32		; test for sector overflow
	jr	nc,parower	; if sector-1 > 31 then para overflow
	ld	c,a		; BC=sector number
	ex	de,hl		; HL= (trk*Hds+hda)*32 , D.E = sec para adrs
	add	hl,bc		; HL= (track * Hds + head address)*32 + sec num
	ld	a,h		; A = mddle address
	ld	h,l		;
	ld	l,a		; swap H with L
	ld	(task+2),hl	; set middle and low address
	ex	de,hl		; H.L = sec para adrs
	inc	hl		; H.L = dma para adrs
	ld	e,(hl)		;
	inc	hl		;
	ld	d,(hl)		; DE = dma address
	push	de		; save dma address
	inc	hl		; H.L = r/w para adrs
	ld	a,(hl)		; A = r/w flag (0 = read, 1 = write)
	push	af		;
	inc	hl		; H.L = block count
	ld	a,(hl)		; A = num sec to r/w
	ld	(task+4),a	; set block count
	ld	e,a		; E = num sec to r/w
	pop	af		; A = r/w flag
	pop	hl		; HL = dma address
	ld	bc,wport0	; wdd data port
				; B = 0 = r/w 256 byte
	or	a		; read or write ?
	jr	nz,wdwrite	; A = 1 then write
;
wdread:
	; wdd read 256 byte
	call	selcntlr	; select the controller
	ld	a,read		; read sector command
	call	taskout		; send out to controller
wdrd1:
	call	reqwait		; wait for the controller request
	ret	nz		; no cntlr request then error (wd.rty)
	and	cdmsk		; check for input status
	jr	nz,wdsts	; C/D- active, read status
	inir			; read 256 byte (one sector)
	dec	e		; sector counter down
	jr	nz,wdrd1	; no zero then read next sector
wdsts:
	call	getstat		; get completion status
	ret			; return status
;
;
parov0:
	pop	hl		; pop parameter pointer
parower:
	; wdd i/o para overflow
	ld	de,parowmsg	; D.E = par overflow message
	call	strout		; print it
	ld	a,40h		; 'Parameter Overflow'
	ret			; return with error
;
;
wdwrite:
	; wdd write 256 byte
	call	selcntlr	; select the controller
	ld	a,write		; write sector command
	call	taskout		; send out to controller
wdwt1:
	call	reqwait		; wait for controller request
	ret	nz		; no cntlr request then error
	and	cdmsk		; check for input status
	jr	nz,wdsts	; C/D- active, read status
	otir			; write 256 byte (one sector)
	dec	e		; sector counter down
	jr	nz,wdwt1	; no zero then read next sector
	jr	wdsts		; return with status
;
;
wdini:
	; initialize Drive Characteristics
	out	(wport1),a	; send out a reset pulse
;
wddrdy:
	call	wtwdrdy		; wdd ready ?
	ret	nz		; error if not
;
	call	selcntlr	; select the controller
	ld	a,initl		; initialize disk size command
	call	taskout		; send out the command
	ld	hl,initab	; point to drive size tab.
	ld	b,8		; set up a byte counter
	call	reqwait		; wait for controller request
	ret	nz		; no zero then error
iniz00:
	ld	a,(hl)		; get a byte to send out
	out	(wport0),a	; send it to the controller
	inc	hl		; bump the drive size tab. pointer
	djnz	iniz00		; decrement the byte count and
				; wait until all are output
	call	getstat		; get completion status
	ret	nz		; ret if error completion
;
	call	selcntlr	; select the controller
	ld	a,recal		; recalibrate command code
	call	taskout		; send command to cntlr
	call	getstat		; get completion status
	ret			; ret with status
;
selcntlr:
	; selects the default controller
	in	a,(rport1)	; read status port
	and	busymsk		; mask busy bit
	jr	nz,selcntlr	; loop if busy
	ld	a,1		; cntrl default select code
	out	(wport0),a	; send it to trasparent latch
	out	(wport2),a	; generate a select strobe
selc00:
	in	a,(rport1)	; get cntrl response
	and	busymsk		; isolate the busy mask
	jr	z,selc00	; wait for cntrl busy
	ret			; busy has arrived,exit
;
wtwdrdy:
	; test for drive ready
	call	selcntlr	; select the controller
	ld	a,drvrdy	; drive ready command
	call	taskout		; send out the command
	call	getstat		; get completion status
	ret			; and ret to caller
;
;
taskout:
	; send out the command contained in A register
	push	hl		; Save Ptr
	ld	hl,task		; Point to table
	ld	(hl),a		; store command
	ld	d,6		; six bytes
	call	reqwait		; wait for request
	ret	nz		; no, error
task1:
	ld	a,(hl)		; get one byte
	out	(wport0),a	; send it
	inc	hl		; point	to next
	dec	d		; dec counter
	jr	nz,task1	; loop until zero
	pop	hl		; restore
	ret			; cmd send
;
getstat:
	call	reqwait		; wait for request
	ret	nz		; no, error
	in	a,(rport0)	; get status byte
	ld	d,a		; save
	call	reqwait		; wait for another
	ret	nz		; no, error
	in	a,(rport0)	; get fill byte
	ld	a,d		; restore
	and	errmsk		; only status bit
	ret	z		; no error, return A=0
;
; Get Sense Status
;
	call	selcntlr	; select the controller
	ld	a,sense		; sense status command
	call	taskout		; send out to controller
	call	reqwait		; wait for controller request
	ret	nz		; no cntlr request then error
	in	a,(rport0)	; get error code
	ld	e,a		; save
	in	a,(rport0)	; get one byte
	in	a,(rport0)	; get one byte
	in	a,(rport0)	; get one byte
	call	getstat		; get completion status
	ld	a,e		; restore error code
	or	a		; set flag
	ret			; return it
;
;
reqwait:
	push	bc		; save register
	push	de		;
	ld	b,8		; set soft timer for aproax 15 Second
reqwt0:
	ld	de,0		;
reqwt1:
	in	a,(rport1)	; get cntlr status bits
	ld	c,a		; save on c
	and	reqmsk		; only request bit (A=0 or A=1)
	jr	nz,reqwtex	; exit if (REQ=1)
	dec	de		; timer 1 down
	ld	a,d		; check for elapsed
	or	e		;
	jr	nz,reqwt1	; no, loop
	djnz	reqwt0		; timer 2 down
	ld	c,0ffh		; time out error (A=FF)
reqwtex:
	dec	a		; A=A-1    (A=0  ,  A=FF)
				; set flag (Z=REQ, NZ=timeout)
	ld	a,c		; return status on A
	pop	de		; restore
	pop	bc		;	registers
	ret			; and ret
;
	#else	; hard		; hard disk don't exist
;
wdio:
	ld	a,1		; wdd i/o error
	ret			;
;
wdini:
	ret			; return
;
	#endif	;hard
;
;
;
	.fill	6
	.end			; end of this program

