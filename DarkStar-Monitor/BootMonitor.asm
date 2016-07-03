;
;=======================================================================
;
; Modular Z80 DarkStar (NE Z80) SysBios
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
; ---------------------------------------------------------------------
; Revisions:
; 20140905 - Modified hexadecimal constants to 0xxH format to be widely
;            accepted by different assemblers
; 20150714 - Changed to have timeouts on floppy operations that could
;            produce system locks. (I.e. in absence of floppy in drive)
; 20150714 - Modified to implement serial XON/XOFF and RTS/CTS
; ---------------------------------------------------------------------

; ---------------------------------------------------------------------
; SYSBIOS
;
; This is the BIOS non-resident portion of the new (banked)
; BIOS/Monitor for the NE Z80 (aka DarkStar)
;
; ---------------------------------------------------------------------
;
; Full BIOS memory scheme:
;
;	+-----------------+
;	+    SysCommon    +   <-- Resident portion. Common to all images
;	+   FC00 - FFFF   +
;	+-----------------+
;	+-----------------+   +-----------------+   +-----------------+
;	+     SysBios     +   +   BootMonitor   +   +     [Other]     +
;	+   F000 - FBFF   +   +   F000 - FBFF   +   +   F000 - FBFF   +
;	+-----------------+   +-----------------+   +-----------------+
;
;	         ^                     ^                     ^
;	         |                     |                     |
;	         ---------------------------------------------
;	                      Variable section
;
; The above are always assembled at ORG F000 and linked and allocated
; in the EEPROM in this way:
;
;	+-----------------+
;	+    SysCommon    +
;	+   FC00 - FFFF   +
;	+     SysBios     +     <-- EEPROM page 1 ($C1000)
;	+   F000 - FBFF   +
;	+-----------------+
;	+-----------------+
;	+    SysCommon    +
;	+   FC00 - FFFF   +
;	+   BootMonitor   +     <-- EEPROM page 0 ($C0000)
;	+   F000 - FBFF   +
;	+-----------------+
;
; ---------------------------------------------------------------------


; Common equates for BIOS/Monitor

include Common.inc.asm

;-------------------------------------
; External symbols
	extern	bbconout, bbconin, bbconst
	extern	bbcrtcini, bbcrtfill, bbcurset
	extern	bbfread, bbfhome, bbcpboot
	extern	bbhdinit, bbdriveid, bbu0ini, bbu1ini
	extern	bbuplchr, bbpsndblk, bbprcvblk
	extern	bbprnchr, bbrdvdsk, bbvcpmbt
 	extern	bbhdboot
 	extern	bbepmngr, bbeidck, bbldpart

 	extern	bbdsksel, bbdmaset, bbtrkset, bbsecset, bbhdrd

	extern	delay, mmpmap, mmgetp
	extern	intren

;-------------------------------------

	dseg

	name	'SYSMON'

zdsmntr	equ	$		; start of monitor code

bmstack	equ	(bbpag << 12) - 1
hdidbuf	equ	(trnpag << 12)

boot:
	if not bbdebug
	jp	booti			; skip bank id
	else
	jr	booti
	endif

sysbidb:
	defb	'SYSBIOSB'

;;
;; BOOT - Bring up system
;;
booti:
	di				; disable interrupts
	ld	b,bbpag << 4
	ld	c,mmuport
	ld	a,eepage0		; mount rom and start
	if not bbdebug
	out	(c),a
	endif
	; Reset memory
	ld	e,16			; ram page counter (15 + 1 for loop)
	ld	c,mmuport		; MMU I/O address
	xor	a
	ld	b,a
	ld	d,a
mmurslp:
	dec	e
	jr	z, mmursend
	out	(c),d
	inc	d			; phis. page address 00xxxh, 01xxxh, etc.
	add	a,$10
	ld	b,a			; logical page 00h, 10h, etc.
	jr	mmurslp
mmursend:
	if not bbdebug
	ld	d,eepage0		; EEPROM page 0 (here) @ F000h
	out	(c),d
	endif
	; Reset bios position after reset
	out	(menaprt),a  		; enable ram
	;
	ld	sp,$0080		; go on
	ld	hl,$0000
	ld	(curpbuf),hl
	xor	a			; initialize our buffers
	ld	(tmpbyte),a
	ld	(cdisk),a
	ld	(colbuf),a
	ld	(miobyte),a
	ld	(dselbf),a
	ld	(copsys),a
	ld	(cnfbyte),a
	cpl
	ld	(ram3buf),a
	ld	hl,$ffff
	ld	(fsekbuf),hl
	ld	a,$c3
	ld	($0066),a
	ld	hl,boot
	ld	($0067),hl
	ld	a,$c9
	ld	($0008),a
	ld	($0038),a
	ld	hl,cnfbyte		; enable XON protcol by default (UART0)
	set	1,(hl)

	; now size banked memory
	ld	b,mmutstpage << 4	; save actual test page
	ld	c,mmuport
	ld	hl,mmutstaddr
	in	a,(c)
	ex	af,af'

	ld	e,$bf-$0f		; number of pages to check
	ld	d,$0f			; first page
bnkpnxt:
	out	(c),d			; setup page

	ld	a,(hl)			; test if writable
	cpl
	ld	(hl),a
	cp	(hl)
	cpl
	ld	(hl),a
	jr	nz,bnktohpag

	inc	d			; next page
	dec	e
	jr	nz,bnkpnxt
bnktohpag:
	ex	af,af'			; restore test page
	out	(c),a

	ld	a,d			; save size
; 	LD	A,$7F
	ld	(hmempag),a
	;
	ld	hl,bmstack
	ld	sp,hl
 	ld	(btpasiz),hl

 	; NOW prior to go on we must place BIOS images in ram

	ld	a,(hmempag)		; highest ram page
	ld	e,4			; # of pages
	sub	e
	ld	d,bbimgp		; base sysbios page
shdwpag:
 	ld	b,trnpag << 4		; mount source page on transient
	ld	c,mmuport
	out	(c),d			; transient mounted
	inc	d
	ld	b,bbappp << 4		; app page for destination
	out	(c),a			; destination in place
	inc	a
	exx				; saves
	ld	hl, trnpag << 12	; source
	ld	de, bbappp << 12	; dest
	ld	bc, 4096		; one page
	ldir
	exx
	dec	e			; finished ?
	jr	z,shdwdone
	jr	shdwpag
shdwdone:
	ld	b,bbpag << 4		; put bootmonitor to final place
	ld	a,(hmempag)		; highest ram page
	sub	4
	out	(c),a
	jp	onshadow		; jump to shadow

onshadow:
	ld	b,bbappp << 4		; reset app page
	ld	d,bbappp
	out	(c),d
	ld	b,trnpag << 4		; and transient page
	ld	d,trnpag
	out	(c),d

 	; init fifo queues and remaining hw
	ld	b,fifsize
	ld	hl,fifou0		; uart 0
	call	fifoini
	ld	hl,fifokb		; keyboard
	call	fifoini
	;
	xor	a
	out	(fdcdrvrcnt),a		; resets floppy selection
	out	(crtprntdat),a
	out	(altprnprt),a
	cpl
	out	(crtprntdat),a
	out	(altprnprt),a
	ld	a, ppuini		; init parallel port for rx
	out	(ppcntrp), a
	ld	a,blifastline
	ld	(cursshp),a
	;
	call	bbcrtcini		; Initialize CRTC
		; workaround for "slow" init video boads
	ld	de, 1000		; sleep 1 sec.
	call	delay
	call	bbcrtcini		; Initialize CRTC (again)
		;
	call	bbcurset		; and cursor shape
	;
 	ld	hl,msysres		; tell user whats going on from now
 	call	outstr
 	call	bbnksiz			; tell how many memory
	;
	ld	hl,mhd			; about IDE
	call	outstr
 	call	bbhdinit		; IDE init
	or	a
	jr	nz,ideinok
	call	bbldpart
 	call	bbdriveid
	or	a
	jr	nz,ideinok
	ld	hl,mrdy
	call	outstr
	; get hd params from scratch
	ld	b, trnpag
	call	mmgetp
	push	af			; save current
	;
	ld	a,(hmempag)		; bios scratch page (phy)
	ld	b,trnpag		; transient page
	call	mmpmap			; mount it
	;
	ld	a,' '+$80
	ld	hl,hdidbuf + 54		; drive id string is @ BLDOFFS + 54
	ld	b,10                    ; and 20 bytes long
	call	hdbufprn
	call	outstr
	call	outcrlf
	pop	af			; remove scratch
	ld	b,trnpag		; transient page
	call	mmpmap			; mount it

	jr	ideiok
ideinok:
	ld	hl,mnot
	call	outstr
ideiok:
	ld	a,u0defspeed		; uart 0 init
	ld	(uart0br),a
	call	bbu0ini
	ld	c,'0'
	call	dsustat
	ld	a,u1defspeed		; uart 1 init
	ld	(uart1br),a
	call	bbu1ini
	ld	c,'1'
	call	dsustat
	;
	ld	hl,meepr		; eeprom type
	call	outstr
	call	bbeidck
	ld	b,a			; temp save
	and	$0f			; mask result
	cp	eep29ee
	jr	nz,is29x
	ld	hl,mepee		; 29ee
	jr	gotetype
is29x:	cp	eep29xe
	jr	nz,is29c
	ld	hl,mepxe		; 29xe
	jr	gotetype
is29c:	cp	eep29c
	jr	nz,isuns
	ld	hl,mepc			; 29ee
	jr	gotetype
isuns:	ld	hl,mepuns
gotetype:
	call	outstr
	ld	b,a
	and	eeproglock
	jr	nz,islckd
	ld	hl,mpron
	jr	isprog
islckd:	ld	hl,mprof
isprog:	call	outstr
	call	outcrlf
	;
	ld	a,ctc0tchi		; chan 0 prescaler
	ld	(ctc0tc),a
	ld	a,syshertz		; chan 1 prescaler
	ld	(ctc1tc),a
	;
	call	intren			; enable interrupts
	; finally print bios greetings
	jp	ugreet
;;
;; New code for direct access to bootloaders
;;
bootm:
	ld	hl,(btpasiz)		; The same as USRCMD
	ld	sp,hl
	ld	hl,usrcmd
	push	hl
	ld	($0001),hl
	ld	a,$c3
	ld	($0000),a
	;
bmpro:	ld	hl,mbmenu		; display the menu
	call	outstr
	call	dogetchr		; get user choice
	push	af
	call	outcrlf
	pop	af
	cp	cr			; go to monitor ?
	jp	z,welcom		; yes
	cp	'A'			; is  a valid drive ?
	jp	m,bmpro			; no < A
	cp	'Q'
	jp	p,bmpro			; no > P
	sub	'A'			; makes a number
	ld	(fdrvbuf),a		; is valid: store in monitor buffer
	ld	(cdisk),a		; and in CP/M buf
	cp	'C'-'A'			; is floppy ?
	jp	m,bbcpboot		; yes
	cp	'O'-'A'			; is hard disk ?
	jp	m,hdboot		; yes

	; ... fall through
dovcpmb:
	call	bbvcpmbt
	jp	z,bldoffs+2
	jr	blerr

docpmb:
	call	bbcpboot
	jr	blerr
hdboot:
	call	bbhdboot
	ld	a,d
	or	a
	jr	nz,nobler
	ld	hl,mhderr
	jr	pberr
blerr:
	ld	hl,mbterr
	jr	pberr
nobler:
	ld	hl,mbtnbl
pberr:	call	outstr
	jr	bootm

;;
;; Display command help
;;
cmdhelp:
	ld	hl,mhelp
	call	outstr
	jp	usrcmd

;;
;; initialize fifo queue
;;
;; HL = base address
;;  B = size

fifoini:
	push	bc
	xor	a
	ld	(hl),a			; cnt
	inc	hl
	ld	(hl),a			; nout
	inc	hl
	ld	a,b
	dec	a
	ld	(hl),a			; mask for MOD ops
	inc	hl
	xor	a
fifinl:	ld	(hl),a			; actual buffer
	inc	hl
	djnz	fifinl
	pop	bc
	ret

;;
;; UART init result
;;
dsustat:
	push	af
	ld	hl,muart
	call	outstr
	call	bbconout
	ld	c,' '
	call	bbconout
	pop	af
	or	a
	jr	z,dsuok
	ld	hl,mnot
	call	outstr
	ret
dsuok:	ld	hl,mrdy
	call	outstr
	call	outcrlf
	ret

;;
;; Print string fro IDE buffer
;;
hdbufprn:
	inc	hl		;Text is low byte high byte format
	ld	c,(hl)
	call	bbconout
	dec	hl
	ld	c,(hl)
	call	bbconout
	inc	hl
	inc	hl
	dec	b
	jp	nz,hdbufprn
	ret

;;
;; Size memory and report
;;
bbnksiz:
	ld	hl,$0000
	ld	de,$0004
	ld	a,(hmempag)
	inc	a			; correct count for last 4k
	ld	b,a
bbnksiz1:
	add	hl,de
	djnz	bbnksiz1
	call	asciihl
	ld	hl,mmbsize
	call	outstr
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
;; GETHNUM - get an hexadecimal string
;;
get1hnum:
	ld	b,$01
	ld	hl,$0000
	jr	gentr

hehex:	jr	nz,ucprompt
pop1prm:
	dec	b
	ret	z
gethnum:
	ld	hl,$0000
gnxtc:	call	dogetchr
gentr:	ld	c,a
	call	chkhex
	jr	c,hnhex			; if not hex digit
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,hl
	or	l
	ld	l,a
	jr	gnxtc
hnhex:	ex	(sp),hl
	push	hl
	ld	a,c
	call	chkctr
	jr	nc,hehex
	djnz	ucprompt
	ret

;;
;; Get a decimal string
;;
;; B < input len (in # of chars) HL > user input

idhl:
	push	bc		; save
	push	de
	ld	hl,0
idhl2:
	call	bbconin		; Get a character
	cp	esc
	jr	z,idhle
	cp	cr
	jr	z,idhlok
	ld	c,a
	push	af
	call	bbconout
	pop	af
	sub	'0'
	jr	c,idhl3		; Error since a non number
	cp	9 + 1		; Check if greater than 9
	jr	nc,idhl3	; as above
	ld	d,h		; copy HL -> DE
	ld	e,l
	add	hl,hl		; * 2
	add	hl,hl		; * 4
	add	hl,de		; * 5
	add	hl,hl		; * 10 total now
	ld	e,a		; Now add in the digit from the buffer
	ld	d,0
	add	hl,de		; all done now
	djnz	idhl2		; do next character from buffer
	jr	idhlok
idhl3:	ld	a,$ff
	jr	idhle
idhlok:	xor	a		; ok
idhle:	pop	de
	pop	bc
	ret

;;
;; USRCMD - display prompt and process user commands
;;
ugreet:	call	outcrlf
	ld	hl,mverstr
	call	outstr
welcom:	ld	hl,mbwcom
	call	outstr
	jr	usrcmd
ucprompt:
	ld	hl,urestr		; reject string
	call	outstr
usrcmd:
	ld	hl,(btpasiz)
	ld	sp,hl
	ld	hl,usrcmd
	push	hl
	ld	($0001),hl
	ld	a,$c3
	ld	($0000),a
	call	outcrlf
	call	doprompt
	sub	$41			; convert to number
	jr	c,ucprompt		; minor 0
	cp	$1a
	jr	nc,ucprompt		; greater than jump table
	add	a,a
	ld	e,a
	ld	d,$00
	ld	b,$02
	ld	hl,ucmdtab
	add	hl,de
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	jp	(hl)

;;
;; Echo input
;;
kecho:
	call	bbconin
	cp	3			; ^C stop test
	jp	z,welcom
	ld	c,a
; 	CP	$20
; 	JR	NC,KDOE
; 	CP	$08
; 	JR	Z,KDOE
; 	PUSH	AF
; 	CALL	SPACER
; 	POP	AF
; 	CALL	H2AJ1
; 	LD	C,'-'
; 	CALL	BBCONOUT
; 	JR	KECHO
kdoe:	call	bbconout
	jr	kecho

;;
;;
;; PDNLOAD- prompt user for parallel download
;;
pdnload:
	call	outcrlf
	ld	hl, sdlpr
	call	outstr
	ld	b, 2			; get params (offset, size)
	call	gethnum
	pop	bc			; size
	call	outcrlf
	ld	hl, strwait
	call	outstr
	pop	de			; offset
	call	bbpsndblk		; send data
	ld	d,c			; save result
	ld	hl,mtx
	call	outstr
	ld	d,a
	or	a
	jr	z,pdnlok
	ld	hl, mnok		; error
	call	outstr
	ret
pdnlok:
	ld	hl,mok			; success
	call	outstr
	ret

;;
;; pupload data through parallel link
;;
;; use:
;;	none
;; unclean register usage: ALL
pupload:
	call	outcrlf
	ld	hl, strwait
	call	outstr

	call	bbuplchr		; in hi byte of upload offset
	ld	h,a
	call	bbuplchr		; in lo byte of upload offset
	ld	l,a
	call	bbuplchr		; in hi byte of data size
	ld	b,a
	call	bbuplchr		; in lo byte of data size
	ld	c,a
	ex	de,hl			; put offset in DE
	call	outcrlf
	ld	hl, strload
	call	outstr

	call	bbprcvblk		; upload data block
	push	bc			; save result
	ld	hl,mrx
	call	outstr
	pop	bc
	ld	a,c
	or	a
	jr	z,puplok
	ld	hl, mnok		; error
	call	outstr
	ret
puplok:
	ld	hl,mok			; success
	call	outstr
	ret

;;
;; FILLMEM - fill memory with a given values
;
fillmem:
	call	pop3num           ; was 00F730 CD 33 F9
flme1:	ld	(hl),c
	call	chkeor
	jr	nc,flme1
	pop	de
	jp	usrcmd
;;
;; MEMCOMP - compare two ram regions
memcomp:
	call	pop3num           ; was 00F73C CD 33 F9
mconx:	ld	a,(bc)
	push	bc
	ld	b,(hl)
	cp	b
	jr	z,mco1
	push	af
	call	hl2ascb
	ld	a,b
	call	h2aj3
	pop	af
	call	h2aj1
mco1:	pop	bc
	call	iptrckbd
	jr	mconx
;;
;; MEMDUMP - prompt user and dump memory area
;
memdump:
	call	pop2prm
mdp6:	call	hl2ascb
	ld	a,l
	call	dmpalib
	push	hl
mdp2:	ld	a,(hl)
	call	h2aj1
	call	chkeor
	jr	c,mdp1
	call	spacer
	ld	a,l
	and	$0f
	jr	nz,mdp2
mdp7:	pop	hl
	ld	a,l
	and	$0f
	call	dmpalia
mdp5:	ld	a,(hl)
	ld	c,a
	ld	a,(miobyte)
	bit	5,a			; serial output?
	jr	z,mdp8
	res	7,c
mdp8:	ld	a,c
	cp	$20
	jr	c,mdp3
	cp	$7f			; to protect serial output...
	jr	z,mdp3
	jr	mdp4
mdp3:	ld	c,$2e
mdp4:	call	bbconout
	call	chkbrk
	ld	a,l
	and	$0f
	jr	nz,mdp5
	jr	mdp6
mdp1:	sub	e
	call	dmpalib
	jr	mdp7
;;
;; DMPALIB - beginning align (spacing) for a memdump
dmpalib:
	and	$0f
	ld	b,a
	add	a,a
	add	a,b
;;
;; DMPALIB - ascii align (spacing) for a memdump
dmpalia:
	ld	b,a
	inc	b
alibn:	call	spacer
	djnz	alibn
	ret
;;
;; GOEXEC - execute from user address
;
goexec:
	call	pop1prm
	pop	hl
	jp	(hl)
;;
;; PORTIN - input a byte from given port (display it in binary)
;
portin:
	call	pop1prm
	pop	bc
	in	e,(c)
	call	bindisp
	jp	usrcmd
;;
;; PORTOUT - output a byte to a give port
portout:
	call	gethnum
	pop	de
	pop	bc
	out	(c),e
 	jp	usrcmd
;;
;; MEMMOVE - move data in memory
;
memmove:
	call	pop3num
mmnxt:	ld	a,(hl)
	ld	(bc),a
	call	iptrckbd
	jr	mmnxt
;;
;; RWMEM - lets user alter memory content
;
rwmem:
	call	pop1prm
	pop	hl
rwm3:	ld	a,(hl)
	call	h2aj3
	call	valgetchr
	ret	c
	jr	z,rwm1
	cp	$0a
	jr	z,rwm2
	push	hl
	call	get1hnum
	pop	de
	pop	hl
	ld	(hl),e
	ld	a,c
	cp	$0d
	ret	z
rwm1:	inc	hl
	inc	hl
rwm2:	dec	hl
	ld	a,l
	and	$07
	call	z,hl2ascb
	jr	rwm3

ouradd	equ	$9000

;;
;; MEMTEST - test ram region
;;
memtest:
	pop	hl			; Identify our page
	push	hl
	ld	a,h
	and	$f0			; logical page
	ld	b,a			; on B
	rrc	b			; move on low nibble
	rrc	b
	rrc	b
	rrc	b
	call	mmgetp			; physical page in A
	ld	(ouradd),a

	call	outcrlf
	ld	e,0			; page count
	ld	c,mmuport
	ld	b,$80			; test page
etloop:
	out	(c),e
	push	de
	ld	hl,$8000
	ld	de,$8fff
mtnxt:	ld	a,(hl)
	push	af
	cpl
	ld	(hl),a
	xor	(hl)
	call	nz,mterr
	pop	af
	ld	(hl),a
	call	chkeor
	jr	c,etpage
	jr	mtnxt
mterr:
	pop	de
	exx
	call	outcrlf
	exx
	ld	a,e
	exx
	call	h2aj1
	call	spacer
	exx
	ld	e,a
	call	hl2ascb
	call	bindisp
	jr	etexi
etpage:
	pop	de
etpag1:	inc	e
	ld	a,e
	call	etprpg
	ld	a,(ouradd)
	cp	e
	jr	z,etpag1
	ld	a,(hmempag)
	cp	e
	jr	nz,etloop
	call	outcrlf

etexi:	ld	e,$08		; reset page
	ld	c,mmuport
	ld	b,$80
	out	(c),e
	ret

etprpg:
	push	bc
	push	de
	push	hl
	ld	hl,$0000
	ld	de,$0004
	inc	a
	ld	b,a
etprpg1:
	add	hl,de
	djnz	etprpg1
	call	asciihl
	ld	c,cr
	call	bbconout
	pop	hl
	pop	de
	pop	bc
	ret


;;
;; BINDISP - display E in binary form
;
bindisp:
	ld	b,$08
bdnxt:	ld	a,e
	rlca
	ld	e,a
	ld	a,$18
	rla
	ld	c,a
	call	bbconout
	djnz	bdnxt
	pop	de
	ret
;;
;; DOPROMPT - display prompt and wait for first key (uppercase)
;
doprompt:
	call	mprompt
;; get a char in uppercase, and display too...
dogetchr:
	call	coiupc
coutch:	push	bc
	ld	c,a
	call	bbconout
	ld	a,c
	pop	bc
	ret
;
pop3num:
	inc	b
	call	gethnum
	pop	bc
	pop	de
	jp	ocrlf1
;;
;; inc HL and do a 16 bit compare between HL and DE
chkeor:
	inc	hl
	ld	a,h
	or	l
	scf
	ret	z
	ld	a,e
	sub	l
	ld	a,d
	sbc	a,h
	ret
;;
cbkend:	pop	de
	ret
;;
;; inc pointer BC and check kbd
iptrckbd:
	inc	bc
;;
chkbrk:
	call	chkeor
	jr	c,cbkend
	call	bbconst
	or	a
	ret	z
	call	coiupc
	cp	$13
	jr	nz,cbkend
	jp	coiupc
;;
;; CHKHEX - check for hex ascii char in A
;
chkhex:
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
;; get chr and validate
valgetchr:
	call	dogetchr
;;
;; CHKCTR: check for valid char in string (space,comma,<CR>)
;
chkctr:
	cp	$20
	ret	z
	cp	$2c
	ret	z
	cp	$0d
	scf
	ret	z
	ccf
	ret
;
;; User command reject string
urestr:
	db	$aa
;
;; TOGGLEIO - toggle i/o on video/serial
toggleio:
	ld	hl,miobyte
	bit	5,(hl)
	jr	z,togpr
	res	5,(hl)
	jr	togju
togpr:	set	5,(hl)
togju:	jp	ugreet

;;
;; Invoke EEPROM manager
;;
epmancal:
	call	bbepmngr
	jp	welcom

;;
;; MATHHLDE - perform 16 bit add & sub between HL and DE
;
mathhlde:
	call	pop2prm
	push	hl
	add	hl,de
	call	hl2ascb
	pop	hl
	or	a
	sbc	hl,de
	jr	h2aen1
;;
;; HL2ASC - convert & display HL 2 ascii
hl2asc:
	call	outcrlf
h2aen1:	ld	a,h
	call	h2aj1
	ld	a,l
h2aj1:	push	af
	rrca
	rrca
	rrca
	rrca
	call	h2aj2
	pop	af
h2aj2:	call	nib2asc
	call	bbconout
	ret

h2aj3:	call	h2aj1           ; entry point to display HEX and a "-"
mprompt:
	ld	c,$2d
	call	bbconout
	ret



;;
;; HL2ASCB - convert & display HL 2 ascii leave a blank after
hl2ascb:
	call	hl2asc           ; was 00FA63 CD 46 FA
spacer:	ld	c,$20
	call	bbconout
	ret
;;
;;
;; COIUPC- convert reg A uppercase
coiupc:
	call	bbconin
	cp	$60
	jp	m,coire
	cp	$7b
	jp	p,coire
	res	5,a
coire:	ret

;;
;; NIB2ASC convert lower nibble in reg A to ascii in reg C
;
nib2asc:
	and	$0f
	add	a,$90
	daa
	adc	a,$40
	daa
	ld	c,a
	ret

;;
;; Get 2 (hex) params from stack
;;
pop2prm:
	call	gethnum			; was 00FAAB CD DE F6
	pop	de
	pop	hl
	jp	outcrlf

;;
;; Convert ascii buffer to binary
;;
;; (DE) < buffer, B < len, HL > converted
hexcnv:
	ld	hl,$0000
hnxth:	ld	a,(de)
; 	LD	C,A
	call	chkhex
	jr	c,cnhx			; if not hex digit
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,hl
	or	l
	ld	l,a
	inc	de
	djnz	hnxth

cnhx:	xor	a
	cp	b			; ok if B = 0
	ret				; else ret NZ

;;
;; Get block
;;
;; B < block num - IY > blok address
rgetblk:
	push	hl
	push	de
	inc	b
	ld	de,tblblk
	ld	hl,ramtbl-tblblk
rgetbl1:
	add	hl,de
	djnz	rgetbl1
	push	hl		; ex HL,IY
	pop	iy
	pop	de
	pop	hl
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


inamep	equ	2
ipagep	equ	2+tnamelen+2
iaddrp	equ	2+tnamelen+2+tpagelen+2
isizep	equ	2+tnamelen+2+tpagelen+2+tiaddrlen+2
idescp	equ	2+tnamelen+2+tpagelen+2+tiaddrlen+2+tsizelen+2

;;
;; Show image header
;;
dspblkid:
	push	de
	push	iy			; name
	pop	hl
	ld	de,inamep
	add	hl,de
	ld	b,tnamelen
	call	nprint
	ld	hl,misep2
	call	outstr
	push	iy			; description
	pop	hl
	ld	de,idescp
	add	hl,de
	ld	b,tdesclen
	call	nprint
	ld	hl,misep3
	call	outstr
	push	iy			; address
	pop	hl
	ld	de,iaddrp
	add	hl,de
	ld	b,tiaddrlen
	call	nprint
	pop	de
	ret

;;
;; Convert tbl field to binary
;;
imgt2bin:
	push	iy			; size
	pop	hl
	add	hl,de
	ex	de,hl
	call	hexcnv
	ret

mrnrdy:
	defb	"Image in place, any key to run or <ESC> to exit",CR,LF+$80
michoi:
	defb	"Select an image number or <ESC> to exit:",' '+$80
mislct:
	defb	" Available images:",CR,LF+$80
misep1:
	defb	":",' '+$80
misep2:
	defb	" -",' '+$80
misep3:
	defb	" @",' '+$80

pagbuf:	defb	0
rombuf:	defs	6
;;
;; Select a EEPROM image and run it
;;
romrun:
	ld	b,trnpag		; copy table in ram
	call	mmgetp
	ld	(pagbuf),a		; save current
	;
	ld	a,imtpag		; in eeprom table
	ld	b,trnpag		; transient page
	call	mmpmap			; mount it
	;
	ld	hl,trnpag << 12
	ld	de,ramtbl		; our copy
	ld	bc,imtsiz
	ldir				; do copy
	;
	ld	a,(pagbuf)		; restore
	ld	b,trnpag		; transient page
	call	mmpmap			; mount it
	; now we a copy of the table
romr1:	ld	c,ff			; draw page
	call	bbconout
	ld	hl,mislct
	call	outstr
	;
	ld	d,maxblk-1
	ld	e,1			; sysbios image is not selectable
rnblk:
	ld	b,5
	ld	c,' '
dspspc:	call	bbconout
	djnz	dspspc
	ld	a,e			; image number
	call	asciia
	ld	hl,misep1
	call	outstr
	ld	b,e
	call	rgetblk
	ld	a,(iy+2)		; is a valid block ?
	or	a
	jr	z,tonblk
	call	dspblkid		; yes, show it
tonblk:	call	outcrlf
	inc	e
	dec	d
	jr	nz,rnblk

	ld	hl,michoi		; prompt user
	call	outstr
	ld	b,2			; 0 ~ 99
	call	idhl
	push	af
	call	outcrlf
	pop	af
	cp	esc			; user abort ?
	jr	nz,romr2
	jp	welcom
romr2:	or	a
	jr	nz,romr1
	ld	a,l			; check selection
	cp	maxblk
	jr	nc,romr1		; too big. ask again
	or	a
	jr	z,romr1			; zero, ask again
	ld	b,l
	call	rgetblk			; point to block, extract image data

	ld	de,ipagep
	call	imgt2bin
	ld	h,0
	ld	(rombuf),hl		; uses ROMBUF as temporary buffer

	ld	de,iaddrp
	call	imgt2bin
	ld	(rombuf+1),hl
	ld	(rombuf+5),hl		; two copy, we need it later

	ld	de,isizep
	call	imgt2bin
	ld	(rombuf+3),hl

multi:
	ld	hl,(rombuf+3)		; image size
	ld	de,4096
	or	a			; clear carry
	sbc	hl,de			; lesser than one page ?
	jr	c,single		; yes
	ld	hl,4096			; no
	jr	cp4k
single:
	ld	hl,(rombuf+3)		; reload image size
cp4k:	push	hl			; ex HL,BC
	pop	bc			; BC size
	ld	a,(rombuf)		; A source (base) page in eeprom
	ld	de,(rombuf+1)		; image location in ram

	call	placepage		; write page

	ld	hl,(rombuf+3)		; reload image size
	ld	de,4096			; page size
	or	a			; clear carry
	sbc	hl,de			; subtract to get remaining size
	jr	c,runrdy
	jr	z,runrdy
	ld	(rombuf+3),hl		; left bytes
	ld	a,(rombuf)		; write another page...
	inc	a
	ld	(rombuf),a		; next page
	ld	hl,(rombuf+1)
	ld	de,4096
	add	hl,de
	ld	(rombuf+1),hl
	jr	multi
runrdy:
	ld	hl,mrnrdy		; all ready
	call	outstr
	call	bbconin
	cp	esc			; abort ?
	jp	z,welcom
	ld	hl,(rombuf+5)
	jp	(hl)
placepage:
	push	bc
	push	af
	ld	b,trnpag		; place image in ram
	call	mmgetp
	ld	(pagbuf),a		; save current
	;
	pop	af
	ld	b,trnpag		; transient page
	call	mmpmap			; mount it
	pop	bc
	;
	ld	hl,trnpag << 12
	ldir				; do copy
	;
	ld	a,(pagbuf)		; restore
	ld	b,trnpag		; transient page
	call	mmpmap			; mount it
	ret


;-----------------------------------------------------------------------

ucmdtab:
	defw	toggleio	; (A) alternate serial/video i/o
	defw	bootm		; (B) boot menu
	defw	mathhlde	; (C) sum & subtract HL, DE
	defw	memdump		; (D) dump memory
	defw	epmancal	; (E) call eeprom manager
	defw	fillmem		; (F) fill memory
	defw	goexec		; (G) go exec a sub
	defw	cmdhelp		; (H) help
	defw	portin		; (I) port input
	defw	ucprompt	; (J) n/a
	defw	boot		; (K) restart system
	defw	ucprompt	; (L) n/a
	defw	memmove		; (M) move memory block
	defw	ucprompt	; (N) n/a
	defw	portout		; (O) output to a port
	defw	ucprompt	; (P) n/a
	defw	ucprompt	; (Q) n/a
	defw	romrun		; (R) select rom image
	defw	rwmem		; (S) alter memory
	defw	memtest		; (T) test ram region
	defw	pupload		; (U) parallel Upload
	defw	memcomp		; (V) compare mem blocks
	defw	pdnload		; (W) parallel DoWnload
	defw	ucprompt	; (X) n/a
	defw	kecho		; (Y) keyboard echo
	defw	ucprompt	; (Z) n/a
;;

mhelp:	defb	cr,lf,lf
	defb	"A - Alternate console",CR,LF
	defb	"B - Boot menu",CR,LF
	defb	"C - HL/DE sum, subtract",CR,LF
	defb	"D - Dump memory",CR,LF
	defb	"E - Eeprom manager",CR,LF
	defb	"F - Fill memory",CR,LF
	defb	"G - Go to execute address",CR,LF
	defb	"H - This help",CR,LF
	defb	"I - Input from port",CR,LF
	defb	"K - Reinit system",CR,LF
	defb	"M - Move memory",CR,LF
	defb	"O - Output to port",CR,LF
	defb	"R - Select ROM image",CR,LF
	defb	"S - Alter memory",CR,LF
	defb	"T - Test ram",CR,LF
	defb	"U - Upload from parallel",CR,LF
	defb	"V - Compare memory",CR,LF
	defb	"W - Download to parallel"
	defb	cr,lf+$80
;;
sdlpr:	defb	"Download",':'+$80
strwait:
	defb	"Waiting for remote...",CR,LF+$80
strload:
	defb	"Loading",CR,LF+$80
;
mverstr:
	if not bbdebug
	defb	"Z80 DarkStar - Banked Monitor - REL ",MONMAJ,'.',MONMIN,CR,LF+$80
	else
	defb	"Z80 DarkStar - Banked Monitor - REL ",MONMAJ,'.',MONMIN," [DEBUG]",CR,LF+$80
	endif
	; Boot messages
msysres:
 	defb	"SYSTEM INIT...",CR,LF,LF+$80
mmbsize:
	defb	"k ram, 256k eeprom",CR,LF+$80
msetsha:
	defb	"Shadowing BIOS images:",CR,LF+$80
mok:	defb	"Successful",CR,LF+$80
mnok:	defb	"Error",CR,LF+$80
mtx:	defb	"Tx",' '+$80
mrx:	defb	"Rx",' '+$80
mfol:	defb	':',' '+$80
mnot:	defb	"not ready",CR,LF+$80
mrdy:	defb	"ready",' '+$80
mhd:	defb	"IDE Drive",' '+$80
muart:	defb	"UART 16C550",' '+$80
meepr:	defb	"EEPROM is a",' '+$80
mpron:	defb	"unlocked",CR,LF+$80
mprof:	defb	"locked",CR,LF+$80
mepee:	defb	"29EE020",' '+$80
mepxe:	defb	"29xE020",' '+$80
mepc:	defb	"29C020",' '+$80
mepuns:	defb	"UNSUPPORTED",' '+$80

mbmenu:	defb	cr,lf
	defb	"BOOT from:",CR,LF,LF
	defb	" A-B = Floppy",CR,LF
	defb	" C-N = IDE Volume",CR,LF
	defb	" O-P = Virtual on parallel",CR,LF
	defb	"<RET> = Monitor prompt",CR,LF,LF
	defb	'-','>'+$80
mbwcom:	defb	cr,lf
	defb	"Enter command: [B]oot Menu, [H]elp"
	defb	cr,lf+$80
mhderr:	defb	"No Volume, "
mbterr:	defb	"Boot error!",CR,LF+$80
mbtnbl:	defb	"No bootloader!",CR,LF+$80

;-------------------------------------
; Needed modules

include modules/crtcutils.lib.asm	; 6545 crtc utils

bmfillo:
	defs	zdsmntr + $0bff - bmfillo
bmfilhi:
	defb	$00

; end of code - this will fill with zeroes to the end of
; the non-resident image

if	mzmac
wsym bootmonitor.sym
endif
;
;
	end
;
