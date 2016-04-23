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

; PASMO	EQU	1
MZMAC	EQU	1
; ZMAC	EQU	1			; ZMAC Z80 assembler, not Linux/Unix version

; ... only one at a time can be active (1) ...

;
; Monitor version numbers (major.minor)
;
MONMAJ		EQU	'3'
MONMIN		EQU	'4'

;
; Buffers addresses labels
;

; -- Global --
IOBYTE		EQU	0003H		; byte: Intel IOBYTE (CP/M 2.2 only)
CDISK		EQU	0004H		; byte: Last logged drive
BTPASIZ		EQU	0006H		; word: size of tpa + 1
;
; -- Private --
HMEMPAG		EQU	000BH		; byte: highest ram page
BBCBANK		EQU	000CH		; byte: current bank
BBCSTCK		EQU	000DH		; word: current stack
		;
PRVTOP		EQU	004FH		; top of private area storage
COLBUF		EQU	PRVTOP		; byte:
DSELBF		EQU	COLBUF-1	; byte: floppy drive select status
					; - bits: 0 = drive 0
					; - bits: 1 = drive 1
					; - bits: 2 = drive 2
					; - bits: 3 = drive 3
					; - bits: 4 = unused
					; - bits: 5 = head select
					; - bits: 6 = motor on (disabled by jumper)
					; - bits: 7 = unused
KBDBYTE		EQU	DSELBF-1	; byte: store keyboard input
MIOBYTE		EQU	KBDBYTE-1	; byte:
					; - bits: 0: 0 = floppy write		1 = floppy read
					;         1: 0 = no ctrl on keypress	1 = ctrl on keypress
					;         2: 0 = scroll			1 = no scroll
					;         3: 0 = accept lowercase	1 = convert to uppercase
					;         4: 0 = destr. bkspace		1 = non destr. bkspace
					;         5: 0 = console out		1 = serial out
					;         6: 0 = disp. all chars	1 = obscure non punct.
					;         7: 0 = ctrl chr set 1		1 = ctrl chr set 2
TMPBYTE		EQU	MIOBYTE-1	; byte: transients flags
					; - bits: 0: 0 = high in cursor addressing
					;         1: 0 = ESC catched by ANSI driver
					;         2: 0 = CSI catched by ANSI driver
					;         3: 0 = Two byte code ESC seq. from serial
					;         4: 0 = Plain serial i/o (disable ANSI driver)
					;         5: 0 = store interrupt status (on/off)
					;         6: 0 = floppy home on err	1 = no home on err
					;         7: 0 = unlock LBA free addressing (unpartitioned)
CURSSHP		EQU	TMPBYTE-1	; cursor shape
CURPBUF		EQU	CURSSHP-2	; word: cursor position
FTRKBUF		EQU	CURPBUF-2	; word: track # for i/o (0 - 65535)
FDRVBUF		EQU	FTRKBUF-1	; byte: drive number for i/0 (0 - 15)
FSECBUF		EQU	FDRVBUF-2	; word: sector # for i/o (1 .. 65535)
FRDPBUF		EQU	FSECBUF-2	; word: dma address for i/o
FSEKBUF		EQU	FRDPBUF-2	; word: current track number for drive A/B
RAM3BUF		EQU	FSEKBUF-1	; byte:
RAM2BUF		EQU	RAM3BUF-1	; byte:
RAM1BUF		EQU	RAM2BUF-1	; byte:
RAM0BUF		EQU	RAM1BUF-1	; byte:
RST7SP3		EQU	003AH		; keep clear area of RST38 (RST7)
RST7SP2		EQU	0039H
RST7SP1		EQU	0038H
RSRVBUF		EQU	RST7SP1-9	; free 9 byte buffer
APPBUF		EQU	RSRVBUF-2	; word: generic buffer
COPSYS		EQU	APPBUF-1	; Op system type for partition selection
UART0BR		EQU	COPSYS-1	; UART 0 baudrate
UART1BR		EQU	UART0BR-1	; UART 1 baudrate
CTC0TC		EQU	UART1BR-1	; CTC channel 0 time constant
CTC1TC		EQU	CTC0TC-1	; CTC channel 1 time constant
TIMRCON		EQU	CTC1TC-1	; timer buf
CNFBYTE		EQU	TIMRCON-1	; config byte
					; - bits: 0: 0 = UART1 intr disabled	1 = RST8 redir UART1
					;         1: 1 = XON/XOFF enabled on UART0
					;         2: 1 = RTS/CTS enabled on UART0
					;         3: 0 = unused/reserved
					;         4: 0 = unused/reserved
					;         5: 0 = unused/reserved
					;         6: 0 = unused/reserved
					;         7: 0 = unused/reserved
FIFOSTO		EQU	000FH		; fifo queues storage start
FIFSIZE		EQU	8		; fifo queue lenght
FIFBLOK		EQU	11		; fifo queue size
FIFOU0		EQU	FIFOSTO		; uart 0 queue (alternate console)
FIFOKB		EQU	FIFOU0+FIFBLOK	; keyboard queue
FIFOEND		EQU	FIFOKB+FIFBLOK	; fifo blocks end
;
BLDOFFS		EQU	3000H		; place for disk bootloader

;
; Some commodity equs
;
CR		EQU	0DH		; ascii CR & LF
LF		EQU	0AH
FF		EQU	0CH		; FORM FEED (clear screen)
ESC		EQU	1BH		; ESCape
XONC		EQU	11H		; Xon
XOFC		EQU	13H		; Xoff
TRUE		EQU	-1
FALSE		EQU	0
TPA		EQU	0100H		; TPA base address (for CP/M)

;
; Modules equs
;
	; delay
MSCNT		EQU	246
	; mmu
MMUTSTPAGE	EQU	0DH		; logical page used for sizing
MMUTSTADDR	EQU	MMUTSTPAGE<<12	; logical page used for sizing

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
CRTBASE		EQU	80H
	; RAM0 for ascii chars & semi6. Combined with RAM1 and RAM2 for graphics
CRTRAM0DAT	EQU	CRTBASE		; RAM0 access: PIO0 port A data register
CRTRAM0CNT	EQU	CRTBASE+2	; RAM0 access: PIO0 port A control register
	; Printer port
CRTPRNTDAT	EQU	CRTBASE+1	; PRINTER (output): PIO0 port B data register
CRTPRNTCNT	EQU	CRTBASE+3	; PRINTER (output): PIO0 port B control register
					; STROBE is generated by hardware
	; RAM1 for graphics. (pixel index by RAM0+RAM1+RAM2)
CRTRAM1DAT	EQU	CRTBASE+4	; RAM1 access: PIO1 port A data register
CRTRAM1CNT	EQU	CRTBASE+6	; RAM1 access: PIO1 port A control register
	; Keyboard port (negated). Bit 7 is for strobe
CRTKEYBDAT	EQU	CRTBASE+5	; KEYBOARD (input): PIO1 port B data register
CRTKEYBCNT	EQU	CRTBASE+7	; KEYBOARD (input): PIO1 port B control register
KEYBSTRBBIT	EQU	7		; Strobe bit
	; RAM2 for graphics. (pixel index by RAM0+RAM1+RAM2)
CRTRAM2DAT	EQU	CRTBASE+8	; RAM2 access: PIO2 port A data register
CRTRAM2CNT	EQU	CRTBASE+10	; RAM2 access: PIO2 port A control register
	; Service/User port
CRTSERVDAT	EQU	CRTBASE+9	; Service (i/o): PIO2 port B data register
CRTSERVCNT	EQU	CRTBASE+11	; Service (i/o): PIO2 port B control register
PRNTBUSYBIT	EQU	0		; Printer BUSY bit		(in)	1
CRTWIDTHBIT	EQU	1		; Set 40/80 chars per line	(out)	0
PIO2BIT2	EQU	2		; user 1 (input)		(in)	1
PIO2BIT3	EQU	3		; user 2 (input)		(in)	1
PIO2BIT4	EQU	4		; user 3 (input)		(in)	1
CLKSCLK		EQU	5		; DS1320 clock line		(out)	0
CLKIO		EQU	6		; DS1320 I/O line		(i/o)	1
CLKRST		EQU	7		; DS1320 RST line		(out)	0
	; normal set for PIO2 (msb) 01011101 (lsb) that is hex $5D
					; Other bits available to user
	; RAM3 control chars/graphics attributes
CRTRAM3PORT	EQU	CRTBASE+14	; RAM3 port
CRTBLINKBIT	EQU	0		; Blink
CRTREVRSBIT	EQU	1		; Reverse
CRTUNDERBIT	EQU	2		; Underline
CRTHILITBIT	EQU	3		; Highlight
CRTMODEBIT	EQU	4		; ASCII/GRAPHIC mode
	; Beeper port
CRTBEEPPORT	EQU	CRTBASE+15	; Beeper port
	; 6545 CRT controller ports
CRT6545ADST	EQU	CRTBASE+12	; Address & Status register
CRT6545DATA	EQU	CRTBASE+13	; Data register
	; Cursor modes
BLISLOWBLOK	EQU	40H		; Blink, slow, block
BLISLOWLINE	EQU	4AH		; Blink, slow, line
BLIFASTBLOK	EQU	60H		; Blink, fast, block
BLIFASTLINE	EQU	6AH		; Blink, fast, line
CURSOROFF	EQU	20H		; Off
FIXBLOCK	EQU	00H		; Fixed, block
CURSORON	EQU	0AH		; On

; ---------------------------------------------------------------------
; LX390 FDC CONTROLLER:
; ---------------------------------------------------------------------
FDCBASE		EQU	0D0H
FDCCMDSTATR	EQU	FDCBASE		; Command and status register
FDCTRAKREG	EQU	FDCBASE+1	; Track register
FDCSECTREG	EQU	FDCBASE+2	; Sector register
FDCDATAREG	EQU	FDCBASE+7	; Data register *** Verificare che sia $d7
FDCDRVRCNT	EQU	FDCBASE+6	; Driver select/control register
;
FDCRESTC	EQU	00000111b	; 1771 restore (seek to trak 0) cmd
FDCSEEKC	EQU	00010111b	; seek cmd
FDCREADC	EQU	10001000b	; read cmd
FDCWRITC	EQU	10101000b	; write cmd
FDCRESET	EQU	11010000b	; fdc reset immediate cmd
;
; ---------------------------------------------------------------------
; LX389: PARALLEL INTERFACE
; ---------------------------------------------------------------------
; alternate printer port
ALTPRNPRT	EQU	03H
;
; parallel port PC link
PPDATAP		EQU	03H		; Data port
PPCNTRP		EQU	02H		; Control port
PPSTROB		EQU	0		; Strobe bit
PPAKSTB		EQU	1		; Acknowledge/Stop bit
;
PPDINI		EQU	00H		; 00000000 Dnl Init byte
PPDRDY		EQU	04H		; 00000100 Dnl Ready
PPDSTP		EQU	06H		; 00000110 Dnl Stop
PPDOKG		EQU	02H		; 00000010 Dnl Ok Go
PPUINI		EQU	01H		; 00000001 Upl Init byte
PPURDY		EQU	05H		; 00000101 Upl Ready
PPUACK		EQU	07H		; 00000111 Upl Acknowledge
PPUOKG		EQU	03H		; 00000011 Upl Ok Go
;
; virtual disks (PC-linked over parallel port)
VDRDSEC		EQU	0		; read sector command
VDWRSEC		EQU	1		; write sector command
VDBUFSZ		EQU	10		; 10 bytes block
; ---------------------------------------------------------------------
; MULTF-BOARD: MMU, IDE, SERIAL, CTC
; ---------------------------------------------------------------------
; -- I/O --
MMUPORT		EQU	20H
MENAPRT		EQU	21H
; -- Map --
EEPAGE0		EQU	0C0H		; page 0 of eeprom
EEPSTA		EQU	0F000H		; eeprom location after MMU reset
MMTPAPAG	EQU	(EEPSTA>>8)-1	; TPA top page (256 bytes pages)
IMTPAG		EQU	0FFH		; eeprom page with image table
IMTSIZ		EQU	1024		; size
RAMTBL		EQU	0E000H		; ram table location
TBLBLK		EQU	48		; block size
MAXBLK		EQU	20		; max images
RTBSIZ		EQU	TBLBLK * MAXBLK	; real table size
					; A table block is:
TNAMELEN	EQU	8		;	name		: 8 bytes
TPAGELEN	EQU	2		;	page offset	: 2 bytes
TIADDRLEN	EQU	4		;	image address	: 4 bytes
TSIZELEN	EQU	4		;	image size	: 4 bytes
TDESCLEN	EQU	20		;	description	: 20 bytes
; -- IDE --
IDEPORTA	EQU	0E0H		; lower 8 bits of IDE interface
IDEPORTB	EQU	0E1H		; upper 8 bits of IDE interface
IDEPORTC	EQU	0E2H		; control lines for IDE interface
IDEPORTCTRL	EQU	0E3H		; 8255 configuration port

READCFG8255	EQU	10010010b	; Set 8255 IDEportC to output, IDEportA/B input
WRITECFG8255	EQU	10000000b	; Set all three 8255 ports to output mode
;IDE control lines for use with IDEportC.
IDEA0LINE	EQU	01H		; direct from 8255 to IDE interface
IDEA1LINE	EQU	02H		; direct from 8255 to IDE interface
IDEA2LINE	EQU	04H		; direct from 8255 to IDE interface
IDECS0LINE	EQU	08H		; inverter between 8255 and IDE interface
IDECS1LINE	EQU	10H		; inverter between 8255 and IDE interface
IDEWRLINE	EQU	20H		; inverter between 8255 and IDE interface
IDERDLINE	EQU	40H		; inverter between 8255 and IDE interface
IDERSTLINE	EQU	80H		; inverter between 8255 and IDE interface
;Symbolic constants for the IDE Drive registers
REGDATA		EQU	IDECS0LINE
REGERR		EQU	IDECS0LINE + IDEA0LINE
REGSECCNT	EQU	IDECS0LINE + IDEA1LINE
REGSECTOR	EQU	IDECS0LINE + IDEA1LINE + IDEA0LINE
REGCYLLSB	EQU	IDECS0LINE + IDEA2LINE
REGCYLMSB	EQU	IDECS0LINE + IDEA2LINE + IDEA0LINE
REGSHD		EQU	IDECS0LINE + IDEA2LINE + IDEA1LINE		;(0EH)
REGCOMMAND	EQU	IDECS0LINE + IDEA2LINE + IDEA1LINE + IDEA0LINE	;(0FH)
REGSTATUS	EQU	IDECS0LINE + IDEA2LINE + IDEA1LINE + IDEA0LINE
REGCONTROL	EQU	IDECS1LINE + IDEA2LINE + IDEA1LINE
REGASTATUS	EQU	IDECS1LINE + IDEA2LINE + IDEA1LINE
;IDE Command Constants.
CMDRECAL	EQU	010H
CMDREAD		EQU	020H
CMDWRITE	EQU	030H
CMDINIT		EQU	091H
CMDID		EQU	0ECH
CMDSPINDOWN	EQU	0E0H
CMDSPINUP	EQU	0E1H
; -- 16C550 UARTS --
UART0BASE	EQU	0C0H		; Port base address for 0
UART1BASE	EQU	0C8H		; Port base address for 1
UART0		EQU	UART0BASE	; Select UART 0
UART1		EQU	UART1BASE	; Select UART 1
R0RXTX		EQU	0		; (r/w) RXD/TXD Transmit/Receive Buffer
R0BRDL		EQU	0		; (r/w) DLL  if bit 7 of LCR is set: Baud Rate Divisor LSB
R1IER		EQU	1		; (r/w) IER - Interrupt Enable Register
R1BRDM		EQU	1		; (r/w) DLM if bit 7 of LCR is set: Baud Rate Divisor MSB
R2IIR		EQU	2		; (r)   IIR - Interrupt Identification Register
R2FCR		EQU	2		; (w)   FCR - FIFO Control Register
R3LCR		EQU	3		; (r/w) LCR - Line Control Register
R4MCR		EQU	4		; (r/w) MCR - Modem Control Register
R5LSR		EQU	5		; (r)   LSR - Line Status Register
R6MSR		EQU	6		; (r)   MSR - Modem Status Register
R7SPR		EQU	7		; (r/w) SPR - Scratch Pad Register
	; speeds:
UART1200	EQU	96		; = 1,843,200 / ( 16 x 1200 )
UART2400	EQU	48		; = 1,843,200 / ( 16 x 2400 )
UART4800	EQU	24		; = 1,843,200 / ( 16 x 4800 )
UART9600	EQU	12		; = 1,843,200 / ( 16 x 9600 )
UART19K2	EQU	06		; = 1,843,200 / ( 16 x 19,200 )
UART38K4	EQU	03		; = 1,843,200 / ( 16 x 38,400 )
UART57K6	EQU	02		; = 1,843,200 / ( 16 x 57,600 )
UART115K2	EQU	01		; = 1,843,200 / ( 16 x 115,200 )

U0DEFSPEED	EQU	UART19K2	; UART 0 default speed
U1DEFSPEED	EQU	UART9600	; UART 1 default speed
; -- Z80CTC --
CTCBASE		EQU	0E8H
CTCCHAN0	EQU	CTCBASE+0	; Channel 1 - Free
CTCCHAN1	EQU	CTCBASE+1	; Channel 2 - System Timer
CTCCHAN2	EQU	CTCBASE+2	; Channel 3 - UART 1 Interrupt
CTCCHAN3	EQU	CTCBASE+3	; Channel 4 - UART 0 Interrupt
CTC0TCHI	EQU	32		; hi speed chan. 0 tc: 4Mhz / 256 / 32 = 488.28 Hz
CTC1TC100HZ	EQU	5		; lo speed chan. 1 tc: 488.28 Hz / 5 = ~ 97.6 Hz
CTC1TC50HZ	EQU	10		; lo speed chan. 1 tc: 488.28 Hz / 10 = ~ 48.8 Hz
CTC1TC25HZ	EQU	19		; lo speed chan. 1 tc: 488.28 Hz / 19 = ~ 25 Hz
CTC1TC10HZ	EQU	48		; lo speed chan. 1 tc: 488.28 Hz / 48 = ~ 10 Hz
CTC1TC2HZ	EQU	244		; lo speed chan. 1 tc: 488.28 Hz / 244 = ~ 2 Hz
SYSHERTZ	EQU	CTC1TC25HZ	; System timer hertz
; -- EEPROM --
EEP29EE		EQU	01H		; type 29EE020
EEP29XE		EQU	02H		; type 29LE020 or 29VE020
EEP29C		EQU	04H		; type 29C020
EEPUNSUPP	EQU	08H		; unsupported
EEPROGLOCK	EQU	10H		; programming locked
	;
EERINEPROM	EQU	80H		; tried to program eeprom running inside it

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


;-------------------------------------
; Production / Testing

BBDEBUG	EQU	TRUE


;-------------------------------------
; Segments, pages locations

IF	BBDEBUG

BBIMGP	EQU	04H		; Image location (DEBUG)
BBAPPP	EQU	0EH
BBPAG	EQU	0FH		; Base page location

ELSE

BBIMGP	EQU	EEPAGE0		; Image location
BBAPPP	EQU	0EH
BBPAG	EQU	0FH		; Base page location

ENDIF

TRNPAG	EQU	0DH		; Page used for transient MMU ops
BBBASE	EQU	BBPAG << 12	; non resident base address
BBCOMN	EQU	BBBASE + 0C00H	; resident portion address

SYSBASE EQU	BBBASE		; use this to have 60K TPA
; SYSBASE EQU	BBCOMN		; use this to have 63K TPA

;-------------------------------------
