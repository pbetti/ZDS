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
;   o Full code clean-up & reoarganization
; ---------------------------------------------------------------------
; Revisions:
; 20140905 - Modified hexadecimal constants to 0xxH format to be widely
;            accepted by different assemblers
; 20150714 - Modified to implement serial XON/XOFF and RTS/CTS
; 20170331 - Fixed uart1 isr routine
; 20180831 - v3.8.1 modifying for 4.0.0
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
;
; Define which assembler we are using
;

; PASMO	equ	1
mzmac	equ	1
; ZMAC	equ	1			; ZMAC Z80 assembler, not Linux/Unix version

; ... only one at a time can be active (1) ...

;
; Monitor version numbers (major.minor.subrel)
;
monmaj		equ	'3'
monmin		equ	'9'
subrel		equ	'7'

;
; Buffers addresses labels
;

; -- Global --
iobyte		equ	0003h		; byte: Intel IOBYTE (CP/M 2.2 only)
cdisk		equ	0004h		; byte: Last logged drive
btpasiz		equ	0006h		; word: size of tpa + 1
;
; -- Private --
hmempag		equ	000bh		; byte: highest ram page
bbcbank		equ	000ch		; byte: current bank
bbcstck		equ	000dh		; word: current stack
		;
prvtop		equ	004fh		; top of private area storage
colbuf		equ	prvtop		; byte:
dselbf		equ	colbuf-1	; byte: floppy drive select status
					; - bits: 0 = drive 0
					; - bits: 1 = drive 1
					; - bits: 2 = drive 2
					; - bits: 3 = drive 3
					; - bits: 4 = unused
					; - bits: 5 = head select
					; - bits: 6 = motor on (disabled by jumper)
					; - bits: 7 = unused
kbdbyte		equ	dselbf-1	; byte: store keyboard input
miobyte		equ	kbdbyte-1	; byte:
					; - bits: 0: 0 = floppy write		1 = floppy read
					;         1: 0 = autorepeat on		1 = autorepeat off
					;         2: 0 = scroll			1 = no scroll
					;         3: 0 = accept lowercase	1 = convert to uppercase
					;         4: 0 = destr. bkspace		1 = non destr. bkspace
					;         5: 0 = console out		1 = serial out
					;         6: 0 = floppy home on err	1 = no home on err
					;         7: 0 = ctrl chr set 1		1 = ctrl chr set 2
tmpbyte		equ	miobyte-1	; byte: transients flags
					; - bits: 0: 0 = high in cursor addressing
					;         1: 0 = ESC catched by ANSI driver
					;         2: 0 = CSI catched by ANSI driver
					;         3: 0 = Two byte code ESC seq. from serial
					;         4: 0 = Plain serial i/o (disable ANSI driver)
					;         5: 0 = store interrupt status (on/off)
					;         6: 0 = high in ansi query
					;         7: 0 = unlock LBA free addressing (unpartitioned)
cursshp		equ	tmpbyte-1	; cursor shape
curpbuf		equ	cursshp-2	; word: cursor position
ftrkbuf		equ	curpbuf-2	; word: track # for i/o (0 - 65535)
fdrvbuf		equ	ftrkbuf-1	; byte: drive number for i/o (0 - 15)
fsecbuf		equ	fdrvbuf-2	; word: sector # for i/o (1 .. 65535)
frdpbuf		equ	fsecbuf-2	; word: dma address for i/o
fsekbuf		equ	frdpbuf-2	; word: current track number for drive A/B
ram3buf		equ	fsekbuf-1	; byte:
ram2buf		equ	ram3buf-1	; byte:
ram1buf		equ	ram2buf-1	; byte:
ram0buf		equ	ram1buf-1	; byte:
rst7sp3		equ	003ah		; keep clear area of RST38 (RST7)
rst7sp2		equ	0039h
rst7sp1		equ	0038h
vstabuf		equ	rst7sp1-2	; word: Display start addr
rsrvbuf		equ	vstabuf-7	; free 7 byte buffer
appbuf		equ	rsrvbuf-2	; word: generic buffer
copsys		equ	appbuf-1	; Op system type for partition selection
uart0br		equ	copsys-1	; UART 0 baudrate
uart1br		equ	uart0br-1	; UART 1 baudrate
ctc0tc		equ	uart1br-1	; CTC channel 0 time constant
ctc1tc		equ	ctc0tc-1	; CTC channel 1 time constant
timrcon		equ	ctc1tc-1	; timer buf
cnfbyte		equ	timrcon-1	; config byte
					; - bits: 0: 0 = UART1 intr disabled	1 = RST8 redir UART1
					;         1: 1 = XON/XOFF enabled on UART0
					;         2: 1 = RTS/CTS enabled on UART0
					;         3: 0 = unused/reserved
					;         4: 0 = unused/reserved
					;         5: 0 = unused/reserved
					;         6: 0 = unused/reserved
					;         7: 0 = unused/reserved
fifosto		equ	000fh		; fifo queues storage start
fifsize		equ	16		; fifo queue lenght
fifblok		equ	fifsize+3	; fifo queue size
fifou0		equ	fifosto		; uart 0 queue (alternate console)
fifoend		equ	fifou0+fifblok	; fifo blocks end
;
iedtbuf		equ	0080h		; monitor editor buffer (internal only)
iedtfil		equ	'-'		; filler char
;
bldoffs		equ	3000h		; place for disk bootloader

;
; Some commodity equs
;
cr		equ	0dh		; ascii cr & lf
lf		equ	0ah
ff		equ	0ch		; form feed (clear screen)
bs		equ	08h		; backspace
ceol		equ	0fh		; clear to EOL
ceop		equ	0eh		; clear to EOp
cron		equ	05h		; cursor on
crof		equ	04h		; cursor off
esc		equ	1bh		; ESCape
beep		equ	07h		; beep
xonc		equ	11h		; Xon
xofc		equ	13h		; Xoff
true		equ	-1
false		equ	0
tpa		equ	0100h		; TPA base address (for CP/M)
mondelay	equ	10		; seconds to auto monitor

;
; Modules equs
;
	; delay
mscnt		equ	246
	; mmu
mmutstpage	equ	0dh		; logical page used for sizing
mmutstaddr	equ	mmutstpage<<12	; logical page used for sizing

; Conventionally all bios/monitor images start at $F000.
; Except for special cases all code is copied to ram @ $F000.
; In this case eeprom page 0 is directly mapped into logical space
; by hardware so we can initialize the system at cold boot.
;
; We assume to initialize MMU as follow:
;
; +--------+
; |  F000  |	-> $C0000  eeprom page 0
; +--------+
; +--------+
; |  EFFF  |
; +--------+
;     ...       -> $00000 to $0EFFF ram
; +--------+
; |  0000  |
; +--------+
;


; include	modules/hwequs.inc.asm
; Hardware equates
; ---------------------------------------------------------------------

; ---------------------------------------------------------------------
; LX529 VIDEO BOARD:
; ---------------------------------------------------------------------
crtbase		equ	80h
	; RAM0 for ascii chars & semi6. Combined with RAM1 and RAM2 for graphics
crtram0dat	equ	crtbase		; RAM0 access: PIO0 port A data register
crtram0cnt	equ	crtbase+2	; RAM0 access: PIO0 port A control register
	; Printer port
crtprntdat	equ	crtbase+1	; PRINTER (output): PIO0 port B data register
crtprntcnt	equ	crtbase+3	; PRINTER (output): PIO0 port B control register
					; STROBE is generated by hardware
	; RAM1 for graphics. (pixel index by RAM0+RAM1+RAM2)
crtram1dat	equ	crtbase+4	; RAM1 access: PIO1 port A data register
crtram1cnt	equ	crtbase+6	; RAM1 access: PIO1 port A control register
	; Keyboard port (negated). Bit 7 is for strobe
crtkeybdat	equ	crtbase+5	; KEYBOARD (input): PIO1 port B data register
crtkeybcnt	equ	crtbase+7	; KEYBOARD (input): PIO1 port B control register
keybstrbbit	equ	7		; Strobe bit
	; RAM2 for graphics. (pixel index by RAM0+RAM1+RAM2)
crtram2dat	equ	crtbase+8	; RAM2 access: PIO2 port A data register
crtram2cnt	equ	crtbase+10	; RAM2 access: PIO2 port A control register
	; Service/User port
crtservdat	equ	crtbase+9	; Service (i/o): PIO2 port B data register
crtservcnt	equ	crtbase+11	; Service (i/o): PIO2 port B control register
prntbusybit	equ	0		; Printer BUSY bit		(in)	1
crtwidthbit	equ	1		; Set 40/80 chars per line	(out)	0
pio2bit2	equ	2		; user 1 (input)		(in)	1
pio2bit3	equ	3		; user 2 (input)		(in)	1
pio2bit4	equ	4		; user 3 (input)		(in)	1
clksclk		equ	5		; DS1320 clock line		(out)	0
clkio		equ	6		; DS1320 I/O line		(i/o)	1
clkrst		equ	7		; DS1320 RST line		(out)	0
	; normal set for PIO2 (msb) 01011101 (lsb) that is hex $5D
					; Other bits available to user
	; RAM3 control chars/graphics attributes
crtram3port	equ	crtbase+14	; RAM3 port
crtblinkbit	equ	0		; Blink
crtrevrsbit	equ	1		; Reverse
crtunderbit	equ	2		; Underline
crthilitbit	equ	3		; Highlight
crtmodebit	equ	4		; ASCII/GRAPHIC mode
	; Beeper port
crtbeepport	equ	crtbase+15	; Beeper port
	; 6545 CRT controller ports
crt6545adst	equ	crtbase+12	; Address & Status register
crt6545data	equ	crtbase+13	; Data register
	; Cursor modes
blislowblok	equ	40h		; Blink, slow, block
blislowline	equ	4ah		; Blink, slow, line
blifastblok	equ	60h		; Blink, fast, block
blifastline	equ	6ah		; Blink, fast, line
cursoroff	equ	20h		; Off
fixblock	equ	00h		; Fixed, block
cursoron	equ	0ah		; On
	; 6545 register index
vr0.hrtot	equ	0		; Total horizontal chars
vr1.hrdis	equ	1		; Total horizontal displayed ch.
vr2.hrsyncpos	equ	2		; Horizontal sync position
vr3.hrvrsyncw	equ	3		; Hsync and vsync width
					; (bit 0-3 hsync, bit 4-7 vsync)
vr4.vrchrow	equ	4		; Total ch. rows in a frame
vr5.vradj	equ	5		; Vertical additional scan lines
vr6.vrdisrows	equ	6		; Displayed char rows
vr7.vrsyncpos	equ	7		; Vertical sync position
vr8.crtmode	equ	8		; Operating mode
					; 76543210
					; ||||||++ Interlace
					; |||||+-- Addressing bin/rowcol
					; ||||+--- Memory shared/transp.
					; |||+---- Display delay no/yes
					; ||+----- Cursor delay no/yes
					; |+------ Pin 34 addr/strobe
					; |------- Access blank/interl.
vr9.scanlines	equ	9		; Scan lines per char row
vr10.crstart	equ	10		; Cursor start line bit 0-4
					; bit 6-5
					;     0 0 = No blink
					;     0 1 = No cursor
					;     1 0 = Blink 1/16 rate
					;     1 1 = Blink 1/32 rate
vr11.crend	equ	11		; Cursor end line bit 0-4
vr12.dstarth	equ	12		; Display start address high
vr13.dstartl	equ	13		; Display start address low
vr14.curposh	equ	14		; Cursor position high
vr15.curposl	equ	15		; Cursor position low
vr16.lpenh	equ	16		; LPEN position high
vr17.lpenl	equ	17		; LPEN position low
vr18.updaddrh	equ	18		; Update (next char) address H
vr19.updaddrl	equ	19		; Update (next char) address L
vr31.dummy	equ	31		; Dummy register for transparent
					; addressing update checkin
endvid		equ	07cfh		; end video cursor (25*80)
; ---------------------------------------------------------------------
; LX390 FDC CONTROLLER:
; ---------------------------------------------------------------------
fdcbase		equ	0d0h
fdccmdstatr	equ	fdcbase		; Command and status register
fdctrakreg	equ	fdcbase+1	; Track register
fdcsectreg	equ	fdcbase+2	; Sector register
fdcdatareg	equ	fdcbase+7	; Data register *** Verificare che sia $d7
fdcdrvrcnt	equ	fdcbase+6	; Driver select/control register
;
fdcrestc	equ	00000111b	; 1771 restore (seek to trak 0) cmd
fdcseekc	equ	00010110b	; seek cmd
fdcreadc	equ	10001000b	; read cmd
fdcwritc	equ	10101000b	; write cmd
fdcreset	equ	11010000b	; fdc reset immediate cmd
;
; ---------------------------------------------------------------------
; LX389: PARALLEL INTERFACE
; ---------------------------------------------------------------------
; alternate printer port
altprnprt	equ	03h
;
; parallel port PC link
ppdatap		equ	03h		; Data port
ppcntrp		equ	02h		; Control port
ppstrob		equ	0		; Strobe bit
ppakstb		equ	1		; Acknowledge/Stop bit
;
ppdini		equ	00h		; 00000000 Dnl Init byte
ppdrdy		equ	04h		; 00000100 Dnl Ready
ppdstp		equ	06h		; 00000110 Dnl Stop
ppdokg		equ	02h		; 00000010 Dnl Ok Go
ppuini		equ	01h		; 00000001 Upl Init byte
ppurdy		equ	05h		; 00000101 Upl Ready
ppuack		equ	07h		; 00000111 Upl Acknowledge
ppuokg		equ	03h		; 00000011 Upl Ok Go
;
; virtual disks (PC-linked over parallel port)
vdrdsec		equ	0		; read sector command
vdwrsec		equ	1		; write sector command
vdbufsz		equ	10		; 10 bytes block
; ---------------------------------------------------------------------
; MULTF-BOARD: MMU, IDE, SERIAL, CTC
; ---------------------------------------------------------------------
; -- I/O --
mmuport		equ	20h
menaprt		equ	21h
; -- Map --
eepage0		equ	0c0h		; page 0 of eeprom
eepsta		equ	0f000h		; eeprom location after MMU reset
mmtpapag	equ	(eepsta>>8)-1	; TPA top page (256 bytes pages)
imtpag		equ	0ffh		; eeprom page with image table
imtsiz		equ	1024		; size
ramtbl		equ	0e000h		; ram table location
tblblk		equ	48		; block size
maxblk		equ	20		; max images
rtbsiz		equ	tblblk * maxblk	; real table size
					; A table block is:
tnamelen	equ	8		;	name		: 8 bytes
tpagelen	equ	2		;	page offset	: 2 bytes
tiaddrlen	equ	4		;	image address	: 4 bytes
tsizelen	equ	4		;	image size	: 4 bytes
tdesclen	equ	20		;	description	: 20 bytes
; -- IDE --
ideporta	equ	0e0h		; lower 8 bits of IDE interface
ideportb	equ	0e1h		; upper 8 bits of IDE interface
ideportc	equ	0e2h		; control lines for IDE interface
ideportctrl	equ	0e3h		; 8255 configuration port

readcfg8255	equ	10010010b	; Set 8255 IDEportC to output, IDEportA/B input
writecfg8255	equ	10000000b	; Set all three 8255 ports to output mode
;IDE control lines for use with IDEportC.
idea0line	equ	01h		; direct from 8255 to IDE interface
idea1line	equ	02h		; direct from 8255 to IDE interface
idea2line	equ	04h		; direct from 8255 to IDE interface
idecs0line	equ	08h		; inverter between 8255 and IDE interface
idecs1line	equ	10h		; inverter between 8255 and IDE interface
idewrline	equ	20h		; inverter between 8255 and IDE interface
iderdline	equ	40h		; inverter between 8255 and IDE interface
iderstline	equ	80h		; inverter between 8255 and IDE interface
;Symbolic constants for the IDE Drive registers
regdata		equ	idecs0line
regerr		equ	idecs0line + idea0line
regseccnt	equ	idecs0line + idea1line
regsector	equ	idecs0line + idea1line + idea0line
regcyllsb	equ	idecs0line + idea2line
regcylmsb	equ	idecs0line + idea2line + idea0line
regshd		equ	idecs0line + idea2line + idea1line		;(0EH)
regcommand	equ	idecs0line + idea2line + idea1line + idea0line	;(0FH)
regstatus	equ	idecs0line + idea2line + idea1line + idea0line
regcontrol	equ	idecs1line + idea2line + idea1line
regastatus	equ	idecs1line + idea2line + idea1line
;IDE Command Constants.
cmdrecal	equ	010h
cmdread		equ	020h
cmdwrite	equ	030h
cmdinit		equ	091h
cmdid		equ	0ech
cmdspindown	equ	0e0h
cmdspinup	equ	0e1h
; -- 16C550 UARTS --
uart0base	equ	0c0h		; Port base address for 0
uart1base	equ	0c8h		; Port base address for 1
uart0		equ	uart0base	; Select UART 0
uart1		equ	uart1base	; Select UART 1
r0rxtx		equ	0		; (r/w) RXD/TXD Transmit/Receive Buffer
r0brdl		equ	0		; (r/w) DLL  if bit 7 of LCR is set: Baud Rate Divisor LSB
r1ier		equ	1		; (r/w) IER - Interrupt Enable Register
r1brdm		equ	1		; (r/w) DLM if bit 7 of LCR is set: Baud Rate Divisor MSB
r2iir		equ	2		; (r)   IIR - Interrupt Identification Register
r2fcr		equ	2		; (w)   FCR - FIFO Control Register
r3lcr		equ	3		; (r/w) LCR - Line Control Register
r4mcr		equ	4		; (r/w) MCR - Modem Control Register
r5lsr		equ	5		; (r)   LSR - Line Status Register
r6msr		equ	6		; (r)   MSR - Modem Status Register
r7spr		equ	7		; (r/w) SPR - Scratch Pad Register
	; fifo
ufifo1		equ	00000111b	; 1 char
ufifo4		equ	01000111b	; 4 char
ufifo8		equ	10000111b	; 8 char
ufifo14		equ	11000111b	; 14 char
	; speeds:
uart1200	equ	96		; = 1,843,200 / ( 16 x 1200 )
uart2400	equ	48		; = 1,843,200 / ( 16 x 2400 )
uart4800	equ	24		; = 1,843,200 / ( 16 x 4800 )
uart9600	equ	12		; = 1,843,200 / ( 16 x 9600 )
uart19k2	equ	06		; = 1,843,200 / ( 16 x 19,200 )
uart38k4	equ	03		; = 1,843,200 / ( 16 x 38,400 )
uart57k6	equ	02		; = 1,843,200 / ( 16 x 57,600 )
uart115k2	equ	01		; = 1,843,200 / ( 16 x 115,200 )

u0defspeed	equ	uart19k2	; UART 0 default speed
u1defspeed	equ	uart9600	; UART 1 default speed
; -- Z80CTC --
ctcbase		equ	0e8h
ctcchan0	equ	ctcbase+0	; Channel 1 - Free
ctcchan1	equ	ctcbase+1	; Channel 2 - System Timer
ctcchan2	equ	ctcbase+2	; Channel 3 - UART 1 Interrupt
ctcchan3	equ	ctcbase+3	; Channel 4 - UART 0 Interrupt
ctc0tchi	equ	32		; hi speed chan. 0 tc: 4Mhz / 256 / 32 = 488.28 Hz
ctc1tc100hz	equ	5		; lo speed chan. 1 tc: 488.28 Hz / 5 = ~ 97.6 Hz
ctc1tc50hz	equ	10		; lo speed chan. 1 tc: 488.28 Hz / 10 = ~ 48.8 Hz
ctc1tc25hz	equ	19		; lo speed chan. 1 tc: 488.28 Hz / 19 = ~ 25 Hz
ctc1tc10hz	equ	48		; lo speed chan. 1 tc: 488.28 Hz / 48 = ~ 10 Hz
ctc1tc2hz	equ	244		; lo speed chan. 1 tc: 488.28 Hz / 244 = ~ 2 Hz
syshertz	equ	ctc1tc25hz	; System timer hertz
; -- EEPROM --
eep29ee		equ	01h		; type 29EE020
eep29xe		equ	02h		; type 29LE020 or 29VE020
eep29c		equ	04h		; type 29C020
eepunsupp	equ	08h		; unsupported
eeproglock	equ	10h		; programming locked
	;
eerineprom	equ	80h		; tried to program eeprom running inside it

;
; MMU organization
;
; MMU manage 16 4kb pages in Z80 address space (logical)
; It can assign any of 256 4k pages (physical) from its
; 1Mb address space.
;
; To load phisycal page XXh to logical page (in CPU address space) Y,
; you should consider that MMU is at a fixed address 20h and that
; logical 4K page Y is derived in the MMU by the usage of A12,A13,A14
; and A15 address lines during an I/O instruction.
;
; So to address phys. ram page 00h at the top of logical space page Fh
; you need to have Fh * on top address lines * because this address
; is the index to MMU page.
;
; So:
;
; 	LD	A,00h		<--- phis. page number	00xxxh (4k page)
; 	LD	B,F0h		<--- log. page number 	 Fxxxh (cpu page)
; 	LD	C,20h		<--- MMU I/O address
; 	OUT	(C),A
; 	RET
;
; The OUT instruction place:
; A on data lines D0-D7
; Fh (from B register) on A12-A15
; on port 20h (C register)
;
;
; Memory is organized as follow:
;
;	Slot 1	-> RAM	  -> 512k from 00000h to 7ffffh (mandatory)
;	Slot 2	-> RAM	  -> 128k from 80000h to 9ffffh (option 1)
;	Slot 2	-> RAM    -> 256k from 80000h to bffffh (option 2)
;	Slot 3	-> EEPROM -> 256k from c0000h to fffffh (mandatory)
;

;*************************************
; Production / Testing
bbdebug		equ	true
;*************************************

;-------------------------------------
; Segments, pages locations

if	bbdebug

bbimgp		equ	04h		; Image location (DEBUG)
bbappp		equ	0eh		; Temporary page/bank
bbpag		equ	0fh		; Base page location

else

bbimgp		equ	eepage0		; Image location
bbappp		equ	0eh		; Temporary page/bank
bbpag		equ	0fh		; Base page location

endif

trnpag		equ	0dh		; Page used for transient MMU ops
bbbase		equ	bbpag << 12	; non resident base address
bbcomn		equ	bbbase + 0c00h	; resident portion address

; sysbase 	equ	bbbase		; use this to have 60K TPA
; sysbase 	equ	bbcomn		; use this to have 63K TPA

;-------------------------------------
