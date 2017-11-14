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
; Buffers addresses labels
;

; -- Global --
iobyte		equ	0003h		; byte: Intel IOBYTE (CP/M 2.2 only)
cdisk		equ	0004h		; byte: Last logged drive
btpasiz		equ	0006h		; word: size of tpa + 1
;
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
					;         1: 0 = no ctrl on keypress	1 = ctrl on keypress
					;         2: 0 = scroll			1 = no scroll
					;         3: 0 = accept lowercase	1 = convert to uppercase
					;         4: 0 = destr. bkspace		1 = non destr. bkspace
					;         5: 0 = console out		1 = serial out
					;         6: 0 = disp. all chars	1 = obscure non punct.
					;         7: 0 = ctrl chr set 1		1 = ctrl chr set 2
tmpbyte		equ	miobyte-1	; byte: transients flags
					; - bits: 0: 0 = high in cursor addressing
					;         1: 0 = ESC catched by ANSI driver
					;         2: 0 = CSI catched by ANSI driver
					;         3: 0 = Two byte code ESC seq. from serial
					;         4: 0 = Plain serial i/o (disable ANSI driver)
					;         5: 0 = store interrupt status (on/off)
					;         6: 0 = floppy no home on err	1 = no home on err
					;         7: 0 = unlock LBA free addressing (unpartitioned)
cursshp		equ	tmpbyte-1	; cursor shape
curpbuf		equ	cursshp-2	; word: cursor position
ftrkbuf		equ	curpbuf-2	; word: track # for i/o (0 - 65535)
fdrvbuf		equ	ftrkbuf-1	; byte: drive number for i/0 (0 - 15)
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

;
; Some commodity equs
;
cr		equ	0dh		; ascii CR & LF
lf		equ	0ah
ff		equ	0ch		; FORM FEED (clear screen)
esc		equ	1bh		; ESCape
xonc		equ	11h		; Xon
xofc		equ	13h		; Xoff
true		equ	-1
false		equ	0
tpa		equ	0100h		; TPA base address (for CP/M)


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
;
