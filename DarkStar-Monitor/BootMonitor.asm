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
	EXTERN	BBCONOUT, BBCONIN, BBCONST
	EXTERN	BBCRTCINI, BBCRTFILL, BBCURSET
	EXTERN	BBFREAD, BBFHOME, BBCPBOOT
	EXTERN	BBHDINIT, BBDRIVEID, BBU0INI, BBU1INI
	EXTERN	BBUPLCHR, BBPSNDBLK, BBPRCVBLK
	EXTERN	BBPRNCHR, BBRDVDSK, BBVCPMBT
 	EXTERN	BBHDBOOT
 	EXTERN	BBEPMNGR, BBEIDCK, BBLDPART

 	EXTERN	BBDSKSEL, BBDMASET, BBTRKSET, BBSECSET, BBHDRD

	EXTERN	DELAY, MMPMAP, MMGETP
	EXTERN	INTREN

;-------------------------------------

	DSEG

	NAME	'SYSMON'

ZDSMNTR	EQU	$		; start of monitor code

BMSTACK	EQU	(BBPAG << 12) - 1
HDIDBUF	EQU	(TRNPAG << 12)

BOOT:
	IF NOT BBDEBUG
	JP	BOOTI			; skip bank id
	ELSE
	JR	BOOTI
	ENDIF

SYSBIDB:
	DEFB	'SYSBIOSB'

;;
;; BOOT - Bring up system
;;
BOOTI:
	DI				; disable interrupts
	LD	B,BBPAG << 4
	LD	C,MMUPORT
	LD	A,EEPAGE0		; mount rom and start
	IF NOT BBDEBUG
	OUT	(C),A
	ENDIF
	; Reset memory
	LD	E,16			; ram page counter (15 + 1 for loop)
	LD	C,MMUPORT		; MMU I/O address
	XOR	A
	LD	B,A
	LD	D,A
MMURSLP:
	DEC	E
	JR	Z, MMURSEND
	OUT	(C),D
	INC	D			; phis. page address 00xxxh, 01xxxh, etc.
	ADD	A,$10
	LD	B,A			; logical page 00h, 10h, etc.
	JR	MMURSLP
MMURSEND:
	IF NOT BBDEBUG
	LD	D,EEPAGE0		; EEPROM page 0 (here) @ F000h
	OUT	(C),D
	ENDIF
	; Reset bios position after reset
	OUT	(MENAPRT),A  		; enable ram
	;
	LD	SP,$0080		; go on
	LD	HL,$0000
	LD	(CURPBUF),HL
	XOR	A			; initialize our buffers
	LD	(TMPBYTE),A
	LD	(CDISK),A
	LD	(COLBUF),A
	LD	(MIOBYTE),A
	LD	(DSELBF),A
	LD	(COPSYS),A
	LD	(CNFBYTE),A
	CPL
	LD	(RAM3BUF),A
	LD	HL,$FFFF
	LD	(FSEKBUF),HL
	LD	A,$C3
	LD	($0066),A
	LD	HL,BOOT
	LD	($0067),HL
	LD	A,$C9
	LD	($0008),A
	LD	($0038),A
	LD	HL,CNFBYTE		; enable XON protcol by default (UART0)
	SET	1,(HL)

	; now size banked memory
	LD	B,MMUTSTPAGE << 4	; save actual test page
	LD	C,MMUPORT
	LD	HL,MMUTSTADDR
	IN	A,(C)
	EX	AF,AF'

	LD	E,$BF-$0F		; number of pages to check
	LD	D,$0F			; first page
BNKPNXT:
	OUT	(C),D			; setup page

	LD	A,(HL)			; test if writable
	CPL
	LD	(HL),A
	CP	(HL)
	CPL
	LD	(HL),A
	JR	NZ,BNKTOHPAG

	INC	D			; next page
	DEC	E
	JR	NZ,BNKPNXT
BNKTOHPAG:
	EX	AF,AF'			; restore test page
	OUT	(C),A

	LD	A,D			; save size
; 	LD	A,$7F
	LD	(HMEMPAG),A
	;
	LD	HL,BMSTACK
	LD	SP,HL
 	LD	(BTPASIZ),HL

 	; NOW prior to go on we must place BIOS images in ram

	LD	A,(HMEMPAG)		; highest ram page
	LD	E,4			; # of pages
	SUB	E
	LD	D,BBIMGP		; base sysbios page
SHDWPAG:
 	LD	B,TRNPAG << 4		; mount source page on transient
	LD	C,MMUPORT
	OUT	(C),D			; transient mounted
	INC	D
	LD	B,BBAPPP << 4		; app page for destination
	OUT	(C),A			; destination in place
	INC	A
	EXX				; saves
	LD	HL, TRNPAG << 12	; source
	LD	DE, BBAPPP << 12	; dest
	LD	BC, 4096		; one page
	LDIR
	EXX
	DEC	E			; finished ?
	JR	Z,SHDWDONE
	JR	SHDWPAG
SHDWDONE:
	LD	B,BBPAG << 4		; put bootmonitor to final place
	LD	A,(HMEMPAG)		; highest ram page
	SUB	4
	OUT	(C),A
	JP	ONSHADOW		; jump to shadow

ONSHADOW:
	LD	B,BBAPPP << 4		; reset app page
	LD	D,BBAPPP
	OUT	(C),D
	LD	B,TRNPAG << 4		; and transient page
	LD	D,TRNPAG
	OUT	(C),D

 	; init fifo queues and remaining hw
	LD	B,FIFSIZE
	LD	HL,FIFOU0		; uart 0
	CALL	FIFOINI
	LD	HL,FIFOKB		; keyboard
	CALL	FIFOINI
	;
	XOR	A
	OUT	(FDCDRVRCNT),A		; resets floppy selection
	OUT	(CRTPRNTDAT),A
	OUT	(ALTPRNPRT),A
	CPL
	OUT	(CRTPRNTDAT),A
	OUT	(ALTPRNPRT),A
	LD	A, PPUINI		; init parallel port for rx
	OUT	(PPCNTRP), A
	LD	A,BLIFASTLINE
	LD	(CURSSHP),A
	;
	CALL	BBCRTCINI		; Initialize CRTC
		; workaround for "slow" init video boads
	LD	DE, 1000		; sleep 1 sec.
	CALL	DELAY
	CALL	BBCRTCINI		; Initialize CRTC (again)
		;
	CALL	BBCURSET		; and cursor shape
	;
 	LD	HL,MSYSRES		; tell user whats going on from now
 	CALL	OUTSTR
 	CALL	BBNKSIZ			; tell how many memory
	;
	LD	HL,MHD			; about IDE
	CALL	OUTSTR
 	CALL	BBHDINIT		; IDE init
	OR	A
	JR	NZ,IDEINOK
	CALL	BBLDPART
 	CALL	BBDRIVEID
	OR	A
	JR	NZ,IDEINOK
	LD	HL,MRDY
	CALL	OUTSTR
	; get hd params from scratch
	LD	B, TRNPAG
	CALL	MMGETP
	PUSH	AF			; save current
	;
	LD	A,(HMEMPAG)		; bios scratch page (phy)
	LD	B,TRNPAG		; transient page
	CALL	MMPMAP			; mount it
	;
	LD	A,' '+$80
	LD	HL,HDIDBUF + 54		; drive id string is @ BLDOFFS + 54
	LD	B,10                    ; and 20 bytes long
	CALL	HDBUFPRN
	CALL	OUTSTR
	CALL	OUTCRLF
	POP	AF			; remove scratch
	LD	B,TRNPAG		; transient page
	CALL	MMPMAP			; mount it

	JR	IDEIOK
IDEINOK:
	LD	HL,MNOT
	CALL	OUTSTR
IDEIOK:
	LD	A,U0DEFSPEED		; uart 0 init
	LD	(UART0BR),A
	CALL	BBU0INI
	LD	C,'0'
	CALL	DSUSTAT
	LD	A,U1DEFSPEED		; uart 1 init
	LD	(UART1BR),A
	CALL	BBU1INI
	LD	C,'1'
	CALL	DSUSTAT
	;
	LD	HL,MEEPR		; eeprom type
	CALL	OUTSTR
	CALL	BBEIDCK
	LD	B,A			; temp save
	AND	$0F			; mask result
	CP	EEP29EE
	JR	NZ,IS29X
	LD	HL,MEPEE		; 29ee
	JR	GOTETYPE
IS29X:	CP	EEP29XE
	JR	NZ,IS29C
	LD	HL,MEPXE		; 29xe
	JR	GOTETYPE
IS29C:	CP	EEP29C
	JR	NZ,ISUNS
	LD	HL,MEPC			; 29ee
	JR	GOTETYPE
ISUNS:	LD	HL,MEPUNS
GOTETYPE:
	CALL	OUTSTR
	LD	B,A
	AND	EEPROGLOCK
	JR	NZ,ISLCKD
	LD	HL,MPRON
	JR	ISPROG
ISLCKD:	LD	HL,MPROF
ISPROG:	CALL	OUTSTR
	CALL	OUTCRLF
	;
	LD	A,CTC0TCHI		; chan 0 prescaler
	LD	(CTC0TC),A
	LD	A,SYSHERTZ		; chan 1 prescaler
	LD	(CTC1TC),A
	;
	CALL	INTREN			; enable interrupts
	; finally print bios greetings
	JP	UGREET
;;
;; New code for direct access to bootloaders
;;
BOOTM:
	LD	HL,(BTPASIZ)		; The same as USRCMD
	LD	SP,HL
	LD	HL,USRCMD
	PUSH	HL
	LD	($0001),HL
	LD	A,$C3
	LD	($0000),A
	;
BMPRO:	LD	HL,MBMENU		; display the menu
	CALL	OUTSTR
	CALL	DOGETCHR		; get user choice
	PUSH	AF
	CALL	OUTCRLF
	POP	AF
	CP	CR			; go to monitor ?
	JP	Z,WELCOM		; yes
	CP	'A'			; is  a valid drive ?
	JP	M,BMPRO			; no < A
	CP	'Q'
	JP	P,BMPRO			; no > P
	SUB	'A'			; makes a number
	LD	(FDRVBUF),A		; is valid: store in monitor buffer
	LD	(CDISK),A		; and in CP/M buf
	CP	'C'-'A'			; is floppy ?
	JP	M,BBCPBOOT		; yes
	CP	'O'-'A'			; is hard disk ?
	JP	M,HDBOOT		; yes

	; ... fall through
DOVCPMB:
	CALL	BBVCPMBT
	JP	Z,BLDOFFS+2
	JR	BLERR

DOCPMB:
	CALL	BBCPBOOT
	JR	BLERR
HDBOOT:
	CALL	BBHDBOOT
	LD	A,D
	OR	A
	JR	NZ,NOBLER
	LD	HL,MHDERR
	JR	PBERR
BLERR:
	LD	HL,MBTERR
	JR	PBERR
NOBLER:
	LD	HL,MBTNBL
PBERR:	CALL	OUTSTR
	JR	BOOTM

;;
;; Display command help
;;
CMDHELP:
	LD	HL,MHELP
	CALL	OUTSTR
	JP	USRCMD

;;
;; initialize fifo queue
;;
;; HL = base address
;;  B = size

FIFOINI:
	PUSH	BC
	XOR	A
	LD	(HL),A			; cnt
	INC	HL
	LD	(HL),A			; nout
	INC	HL
	LD	A,B
	DEC	A
	LD	(HL),A			; mask for MOD ops
	INC	HL
	XOR	A
FIFINL:	LD	(HL),A			; actual buffer
	INC	HL
	DJNZ	FIFINL
	POP	BC
	RET

;;
;; UART init result
;;
DSUSTAT:
	PUSH	AF
	LD	HL,MUART
	CALL	OUTSTR
	CALL	BBCONOUT
	LD	C,' '
	CALL	BBCONOUT
	POP	AF
	OR	A
	JR	Z,DSUOK
	LD	HL,MNOT
	CALL	OUTSTR
	RET
DSUOK:	LD	HL,MRDY
	CALL	OUTSTR
	CALL	OUTCRLF
	RET

;;
;; Print string fro IDE buffer
;;
HDBUFPRN:
	INC	HL		;Text is low byte high byte format
	LD	C,(HL)
	CALL	BBCONOUT
	DEC	HL
	LD	C,(HL)
	CALL	BBCONOUT
	INC	HL
	INC	HL
	DEC	B
	JP	NZ,HDBUFPRN
	RET

;;
;; Size memory and report
;;
BBNKSIZ:
	LD	HL,$0000
	LD	DE,$0004
	LD	A,(HMEMPAG)
	INC	A			; correct count for last 4k
	LD	B,A
BBNKSIZ1:
	ADD	HL,DE
	DJNZ	BBNKSIZ1
	CALL	ASCIIHL
	LD	HL,MMBSIZE
	CALL	OUTSTR
	RET


;;
;; Output HL converted to ascii decimal (max 9999)
;;
ASCIIA:
	PUSH	BC
	PUSH	DE
	LD	H,0
	LD	L,A
	LD	E,4
	CALL	ASCIIHL0
	POP	DE
	POP	BC
	RET

ASCIIHL:
	PUSH	BC
	PUSH	DE
	LD	E,1
	CALL	ASCIIHL0
	POP	DE
	POP	BC
	RET

ASCIIHL0:
	LD	BC,-10000
	CALL	ASCIIHL1
	LD	BC,-1000
	CALL	ASCIIHL1
	LD	BC,-100
	CALL	ASCIIHL1
	LD	C,-10
	CALL	ASCIIHL1
	LD	C,-1
ASCIIHL1:
	LD	A,'0'-1
ASCIIHL2:
	INC	A
	ADD	HL,BC
	JR	C,ASCIIHL2
	SBC	HL,BC
	LD	C,A
	DEC	E
	RET	NZ
	INC	E
	CALL	BBCONOUT
	RET

;;
;; GETHNUM - get an hexadecimal string
;;
GET1HNUM:
	LD	B,$01
	LD	HL,$0000
	JR	GENTR

HEHEX:	JR	NZ,UCPROMPT
POP1PRM:
	DEC	B
	RET	Z
GETHNUM:
	LD	HL,$0000
GNXTC:	CALL	DOGETCHR
GENTR:	LD	C,A
	CALL	CHKHEX
	JR	C,HNHEX			; if not hex digit
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	OR	L
	LD	L,A
	JR	GNXTC
HNHEX:	EX	(SP),HL
	PUSH	HL
	LD	A,C
	CALL	CHKCTR
	JR	NC,HEHEX
	DJNZ	UCPROMPT
	RET

;;
;; Get a decimal string
;;
;; B < input len (in # of chars) HL > user input

IDHL:
	PUSH	BC		; save
	PUSH	DE
	LD	HL,0
IDHL2:
	CALL	BBCONIN		; Get a character
	CP	ESC
	JR	Z,IDHLE
	CP	CR
	JR	Z,IDHLOK
	LD	C,A
	PUSH	AF
	CALL	BBCONOUT
	POP	AF
	SUB	'0'
	JR	C,IDHL3		; Error since a non number
	CP	9 + 1		; Check if greater than 9
	JR	NC,IDHL3	; as above
	LD	D,H		; copy HL -> DE
	LD	E,L
	ADD	HL,HL		; * 2
	ADD	HL,HL		; * 4
	ADD	HL,DE		; * 5
	ADD	HL,HL		; * 10 total now
	LD	E,A		; Now add in the digit from the buffer
	LD	D,0
	ADD	HL,DE		; all done now
	DJNZ	IDHL2		; do next character from buffer
	JR	IDHLOK
IDHL3:	LD	A,$FF
	JR	IDHLE
IDHLOK:	XOR	A		; ok
IDHLE:	POP	DE
	POP	BC
	RET

;;
;; USRCMD - display prompt and process user commands
;;
UGREET:	CALL	OUTCRLF
	LD	HL,MVERSTR
	CALL	OUTSTR
WELCOM:	LD	HL,MBWCOM
	CALL	OUTSTR
	JR	USRCMD
UCPROMPT:
	LD	HL,URESTR		; reject string
	CALL	OUTSTR
USRCMD:
	LD	HL,(BTPASIZ)
	LD	SP,HL
	LD	HL,USRCMD
	PUSH	HL
	LD	($0001),HL
	LD	A,$C3
	LD	($0000),A
	CALL	OUTCRLF
	CALL	DOPROMPT
	SUB	$41			; convert to number
	JR	C,UCPROMPT		; minor 0
	CP	$1A
	JR	NC,UCPROMPT		; greater than jump table
	ADD	A,A
	LD	E,A
	LD	D,$00
	LD	B,$02
	LD	HL,UCMDTAB
	ADD	HL,DE
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	JP	(HL)

;;
;; Echo input
;;
KECHO:
	CALL	BBCONIN
	CP	3			; ^C stop test
	JP	Z,WELCOM
	LD	C,A
	CP	$20
	JR	NC,KDOE
	CP	$08
	JR	Z,KDOE
	PUSH	AF
	CALL	SPACER
	POP	AF
	CALL	H2AJ1
	LD	C,'-'
	CALL	BBCONOUT
	JR	KECHO
KDOE:	CALL	BBCONOUT
	JR	KECHO

;;
;;
;; PDNLOAD- prompt user for parallel download
;;
PDNLOAD:
	CALL	OUTCRLF
	LD	HL, SDLPR
	CALL	OUTSTR
	LD	B, 2			; get params (offset, size)
	CALL	GETHNUM
	POP	BC			; size
	CALL	OUTCRLF
	LD	HL, STRWAIT
	CALL	OUTSTR
	POP	DE			; offset
	CALL	BBPSNDBLK		; send data
	LD	D,C			; save result
	LD	HL,MTX
	CALL	OUTSTR
	LD	D,A
	OR	A
	JR	Z,PDNLOK
	LD	HL, MNOK		; error
	CALL	OUTSTR
	RET
PDNLOK:
	LD	HL,MOK			; success
	CALL	OUTSTR
	RET

;;
;; pupload data through parallel link
;;
;; use:
;;	none
;; unclean register usage: ALL
PUPLOAD:
	CALL	OUTCRLF
	LD	HL, STRWAIT
	CALL	OUTSTR

	CALL	BBUPLCHR		; in hi byte of upload offset
	LD	H,A
	CALL	BBUPLCHR		; in lo byte of upload offset
	LD	L,A
	CALL	BBUPLCHR		; in hi byte of data size
	LD	B,A
	CALL	BBUPLCHR		; in lo byte of data size
	LD	C,A
	EX	DE,HL			; put offset in DE
	CALL	OUTCRLF
	LD	HL, STRLOAD
	CALL	OUTSTR

	CALL	BBPRCVBLK		; upload data block
	PUSH	BC			; save result
	LD	HL,MRX
	CALL	OUTSTR
	POP	BC
	LD	A,C
	OR	A
	JR	Z,PUPLOK
	LD	HL, MNOK		; error
	CALL	OUTSTR
	RET
PUPLOK:
	LD	HL,MOK			; success
	CALL	OUTSTR
	RET

;;
;; FILLMEM - fill memory with a given values
;
FILLMEM:
	CALL	POP3NUM           ; was 00F730 CD 33 F9
FLME1:	LD	(HL),C
	CALL	CHKEOR
	JR	NC,FLME1
	POP	DE
	JP	USRCMD
;;
;; MEMCOMP - compare two ram regions
MEMCOMP:
	CALL	POP3NUM           ; was 00F73C CD 33 F9
MCONX:	LD	A,(BC)
	PUSH	BC
	LD	B,(HL)
	CP	B
	JR	Z,MCO1
	PUSH	AF
	CALL	HL2ASCB
	LD	A,B
	CALL	H2AJ3
	POP	AF
	CALL	H2AJ1
MCO1:	POP	BC
	CALL	IPTRCKBD
	JR	MCONX
;;
;; MEMDUMP - prompt user and dump memory area
;
MEMDUMP:
	CALL	POP2PRM
MDP6:	CALL	HL2ASCB
	LD	A,L
	CALL	DMPALIB
	PUSH	HL
MDP2:	LD	A,(HL)
	CALL	H2AJ1
	CALL	CHKEOR
	JR	C,MDP1
	CALL	SPACER
	LD	A,L
	AND	$0F
	JR	NZ,MDP2
MDP7:	POP	HL
	LD	A,L
	AND	$0F
	CALL	DMPALIA
MDP5:	LD	A,(HL)
	LD	C,A
	LD	A,(MIOBYTE)
	BIT	5,A			; serial output?
	JR	Z,MDP8
	RES	7,C
MDP8:	LD	A,C
	CP	$20
	JR	C,MDP3
	CP	$7F			; to protect serial output...
	JR	Z,MDP3
	JR	MDP4
MDP3:	LD	C,$2E
MDP4:	CALL	BBCONOUT
	CALL	CHKBRK
	LD	A,L
	AND	$0F
	JR	NZ,MDP5
	JR	MDP6
MDP1:	SUB	E
	CALL	DMPALIB
	JR	MDP7
;;
;; DMPALIB - beginning align (spacing) for a memdump
DMPALIB:
	AND	$0F
	LD	B,A
	ADD	A,A
	ADD	A,B
;;
;; DMPALIB - ascii align (spacing) for a memdump
DMPALIA:
	LD	B,A
	INC	B
ALIBN:	CALL	SPACER
	DJNZ	ALIBN
	RET
;;
;; GOEXEC - execute from user address
;
GOEXEC:
	CALL	POP1PRM
	POP	HL
	JP	(HL)
;;
;; PORTIN - input a byte from given port (display it in binary)
;
PORTIN:
	CALL	POP1PRM
	POP	BC
	IN	E,(C)
	CALL	BINDISP
	JP	USRCMD
;;
;; PORTOUT - output a byte to a give port
PORTOUT:
	CALL	GETHNUM
	POP	DE
	POP	BC
	OUT	(C),E
 	JP	USRCMD
;;
;; MEMMOVE - move data in memory
;
MEMMOVE:
	CALL	POP3NUM
MMNXT:	LD	A,(HL)
	LD	(BC),A
	CALL	IPTRCKBD
	JR	MMNXT
;;
;; RWMEM - lets user alter memory content
;
RWMEM:
	CALL	POP1PRM
	POP	HL
RWM3:	LD	A,(HL)
	CALL	H2AJ3
	CALL	VALGETCHR
	RET	C
	JR	Z,RWM1
	CP	$0A
	JR	Z,RWM2
	PUSH	HL
	CALL	GET1HNUM
	POP	DE
	POP	HL
	LD	(HL),E
	LD	A,C
	CP	$0D
	RET	Z
RWM1:	INC	HL
	INC	HL
RWM2:	DEC	HL
	LD	A,L
	AND	$07
	CALL	Z,HL2ASCB
	JR	RWM3

OURADD	EQU	$9000

;;
;; MEMTEST - test ram region
;;
MEMTEST:
	POP	HL			; Identify our page
	PUSH	HL
	LD	A,H
	AND	$F0			; logical page
	LD	B,A			; on B
	RRC	B			; move on low nibble
	RRC	B
	RRC	B
	RRC	B
	CALL	MMGETP			; physical page in A
	LD	(OURADD),A

	CALL	OUTCRLF
	LD	E,0			; page count
	LD	C,MMUPORT
	LD	B,$80			; test page
ETLOOP:
	OUT	(C),E
	PUSH	DE
	LD	HL,$8000
	LD	DE,$8FFF
MTNXT:	LD	A,(HL)
	PUSH	AF
	CPL
	LD	(HL),A
	XOR	(HL)
	CALL	NZ,MTERR
	POP	AF
	LD	(HL),A
	CALL	CHKEOR
	JR	C,ETPAGE
	JR	MTNXT
MTERR:
	POP	DE
	EXX
	CALL	OUTCRLF
	EXX
	LD	A,E
	EXX
	CALL	H2AJ1
	CALL	SPACER
	EXX
	LD	E,A
	CALL	HL2ASCB
	CALL	BINDISP
	JR	ETEXI
ETPAGE:
	POP	DE
ETPAG1:	INC	E
	LD	A,E
	CALL	ETPRPG
	LD	A,(OURADD)
	CP	E
	JR	Z,ETPAG1
	LD	A,(HMEMPAG)
	CP	E
	JR	NZ,ETLOOP
	CALL	OUTCRLF

ETEXI:	LD	E,$08		; reset page
	LD	C,MMUPORT
	LD	B,$80
	OUT	(C),E
	RET

ETPRPG:
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	HL,$0000
	LD	DE,$0004
	INC	A
	LD	B,A
ETPRPG1:
	ADD	HL,DE
	DJNZ	ETPRPG1
	CALL	ASCIIHL
	LD	C,CR
	CALL	BBCONOUT
	POP	HL
	POP	DE
	POP	BC
	RET


;;
;; BINDISP - display E in binary form
;
BINDISP:
	LD	B,$08
BDNXT:	LD	A,E
	RLCA
	LD	E,A
	LD	A,$18
	RLA
	LD	C,A
	CALL	BBCONOUT
	DJNZ	BDNXT
	POP	DE
	RET
;;
;; DOPROMPT - display prompt and wait for first key (uppercase)
;
DOPROMPT:
	CALL	MPROMPT
;; get a char in uppercase, and display too...
DOGETCHR:
	CALL	COIUPC
COUTCH:	PUSH	BC
	LD	C,A
	CALL	BBCONOUT
	LD	A,C
	POP	BC
	RET
;
POP3NUM:
	INC	B
	CALL	GETHNUM
	POP	BC
	POP	DE
	JP	OCRLF1
;;
;; inc HL and do a 16 bit compare between HL and DE
CHKEOR:
	INC	HL
	LD	A,H
	OR	L
	SCF
	RET	Z
	LD	A,E
	SUB	L
	LD	A,D
	SBC	A,H
	RET
;;
CBKEND:	POP	DE
	RET
;;
;; inc pointer BC and check kbd
IPTRCKBD:
	INC	BC
;;
CHKBRK:
	CALL	CHKEOR
	JR	C,CBKEND
	CALL	BBCONST
	OR	A
	RET	Z
	CALL	COIUPC
	CP	$13
	JR	NZ,CBKEND
	JP	COIUPC
;;
;; CHKHEX - check for hex ascii char in A
;
CHKHEX:
	SUB	$30
	RET	C
	CP	$17
	CCF
	RET	C
	CP	$0A
	CCF
	RET	NC
	SUB	$07
	CP	$0A
	RET
;; get chr and validate
VALGETCHR:
	CALL	DOGETCHR
;;
;; CHKCTR: check for valid char in string (space,comma,<CR>)
;
CHKCTR:
	CP	$20
	RET	Z
	CP	$2C
	RET	Z
	CP	$0D
	SCF
	RET	Z
	CCF
	RET
;
;; User command reject string
URESTR:
	DB	$AA
;
;; TOGGLEIO - toggle i/o on video/serial
TOGGLEIO:
	LD	HL,MIOBYTE
	BIT	5,(HL)
	JR	Z,TOGPR
	RES	5,(HL)
	JR	TOGJU
TOGPR:	SET	5,(HL)
TOGJU:	JP	UGREET

;;
;; Invoke EEPROM manager
;;
EPMANCAL:
	CALL	BBEPMNGR
	JP	WELCOM

;;
;; MATHHLDE - perform 16 bit add & sub between HL and DE
;
MATHHLDE:
	CALL	POP2PRM
	PUSH	HL
	ADD	HL,DE
	CALL	HL2ASCB
	POP	HL
	OR	A
	SBC	HL,DE
	JR	H2AEN1
;;
;; HL2ASC - convert & display HL 2 ascii
HL2ASC:
	CALL	OUTCRLF
H2AEN1:	LD	A,H
	CALL	H2AJ1
	LD	A,L
H2AJ1:	PUSH	AF
	RRCA
	RRCA
	RRCA
	RRCA
	CALL	H2AJ2
	POP	AF
H2AJ2:	CALL	NIB2ASC
	CALL	BBCONOUT
	RET

H2AJ3:	CALL	H2AJ1           ; entry point to display HEX and a "-"
MPROMPT:
	LD	C,$2D
	CALL	BBCONOUT
	RET



;;
;; HL2ASCB - convert & display HL 2 ascii leave a blank after
HL2ASCB:
	CALL	HL2ASC           ; was 00FA63 CD 46 FA
SPACER:	LD	C,$20
	CALL	BBCONOUT
	RET
;;
;;
;; COIUPC- convert reg A uppercase
COIUPC:
	CALL	BBCONIN
	CP	$60
	JP	M,COIRE
	CP	$7B
	JP	P,COIRE
	RES	5,A
COIRE:	RET

;;
;; NIB2ASC convert lower nibble in reg A to ascii in reg C
;
NIB2ASC:
	AND	$0F             ; was 00FDE0 E6 0F
	ADD	A,$90
	DAA
	ADC	A,$40
	DAA
	LD	C,A
	RET

;;
;; Get 2 (hex) params from stack
;;
POP2PRM:
	CALL	GETHNUM			; was 00FAAB CD DE F6
	POP	DE
	POP	HL
	JP	OUTCRLF

;;
;; Convert ascii buffer to binary
;;
;; (DE) < buffer, B < len, HL > converted
HEXCNV:
	LD	HL,$0000
HNXTH:	LD	A,(DE)
; 	LD	C,A
	CALL	CHKHEX
	JR	C,CNHX			; if not hex digit
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	OR	L
	LD	L,A
	INC	DE
	DJNZ	HNXTH

CNHX:	XOR	A
	CP	B			; ok if B = 0
	RET				; else ret NZ

;;
;; Get block
;;
;; B < block num - IY > blok address
RGETBLK:
	PUSH	HL
	PUSH	DE
	INC	B
	LD	DE,TBLBLK
	LD	HL,RAMTBL-TBLBLK
RGETBL1:
	ADD	HL,DE
	DJNZ	RGETBL1
	PUSH	HL		; ex HL,IY
	POP	IY
	POP	DE
	POP	HL
	RET

;;
;; Print a string of B length pointed by HL
;;
NPRINT:
	PUSH	BC
NPRIN1:
	LD	C,(HL)
	CALL	BBCONOUT
	INC	HL
	DJNZ	NPRIN1
	POP	BC
	RET


INAMEP	EQU	2
IPAGEP	EQU	2+TNAMELEN+2
IADDRP	EQU	2+TNAMELEN+2+TPAGELEN+2
ISIZEP	EQU	2+TNAMELEN+2+TPAGELEN+2+TIADDRLEN+2
IDESCP	EQU	2+TNAMELEN+2+TPAGELEN+2+TIADDRLEN+2+TSIZELEN+2

;;
;; Show image header
;;
DSPBLKID:
	PUSH	DE
	PUSH	IY			; name
	POP	HL
	LD	DE,INAMEP
	ADD	HL,DE
	LD	B,TNAMELEN
	CALL	NPRINT
	LD	HL,MISEP2
	CALL	OUTSTR
	PUSH	IY			; description
	POP	HL
	LD	DE,IDESCP
	ADD	HL,DE
	LD	B,TDESCLEN
	CALL	NPRINT
	LD	HL,MISEP3
	CALL	OUTSTR
	PUSH	IY			; address
	POP	HL
	LD	DE,IADDRP
	ADD	HL,DE
	LD	B,TIADDRLEN
	CALL	NPRINT
	POP	DE
	RET

;;
;; Convert tbl field to binary
;;
IMGT2BIN:
	PUSH	IY			; size
	POP	HL
	ADD	HL,DE
	EX	DE,HL
	CALL	HEXCNV
	RET

MRNRDY:
	DEFB	"Image in place, any key to run or <ESC> to exit",CR,LF+$80
MICHOI:
	DEFB	"Select an image number or <ESC> to exit:",' '+$80
MISLCT:
	DEFB	" Available images:",CR,LF+$80
MISEP1:
	DEFB	":",' '+$80
MISEP2:
	DEFB	" -",' '+$80
MISEP3:
	DEFB	" @",' '+$80

PAGBUF:	DEFB	0
ROMBUF:	DEFS	6
;;
;; Select a EEPROM image and run it
;;
ROMRUN:
	LD	B,TRNPAG		; copy table in ram
	CALL	MMGETP
	LD	(PAGBUF),A		; save current
	;
	LD	A,IMTPAG		; in eeprom table
	LD	B,TRNPAG		; transient page
	CALL	MMPMAP			; mount it
	;
	LD	HL,TRNPAG << 12
	LD	DE,RAMTBL		; our copy
	LD	BC,IMTSIZ
	LDIR				; do copy
	;
	LD	A,(PAGBUF)		; restore
	LD	B,TRNPAG		; transient page
	CALL	MMPMAP			; mount it
	; now we a copy of the table
ROMR1:	LD	C,FF			; draw page
	CALL	BBCONOUT
	LD	HL,MISLCT
	CALL	OUTSTR
	;
	LD	D,MAXBLK-1
	LD	E,1			; sysbios image is not selectable
RNBLK:
	LD	B,5
	LD	C,' '
DSPSPC:	CALL	BBCONOUT
	DJNZ	DSPSPC
	LD	A,E			; image number
	CALL	ASCIIA
	LD	HL,MISEP1
	CALL	OUTSTR
	LD	B,E
	CALL	RGETBLK
	LD	A,(IY+2)		; is a valid block ?
	OR	A
	JR	Z,TONBLK
	CALL	DSPBLKID		; yes, show it
TONBLK:	CALL	OUTCRLF
	INC	E
	DEC	D
	JR	NZ,RNBLK

	LD	HL,MICHOI		; prompt user
	CALL	OUTSTR
	LD	B,2			; 0 ~ 99
	CALL	IDHL
	PUSH	AF
	CALL	OUTCRLF
	POP	AF
	CP	ESC			; user abort ?
	JR	NZ,ROMR2
	JP	WELCOM
ROMR2:	OR	A
	JR	NZ,ROMR1
	LD	A,L			; check selection
	CP	MAXBLK
	JR	NC,ROMR1		; too big. ask again
	OR	A
	JR	Z,ROMR1			; zero, ask again
	LD	B,L
	CALL	RGETBLK			; point to block, extract image data

	LD	DE,IPAGEP
	CALL	IMGT2BIN
	LD	H,0
	LD	(ROMBUF),HL		; uses ROMBUF as temporary buffer

	LD	DE,IADDRP
	CALL	IMGT2BIN
	LD	(ROMBUF+1),HL
	LD	(ROMBUF+5),HL		; two copy, we need it later

	LD	DE,ISIZEP
	CALL	IMGT2BIN
	LD	(ROMBUF+3),HL

MULTI:
	LD	HL,(ROMBUF+3)		; image size
	LD	DE,4096
	OR	A			; clear carry
	SBC	HL,DE			; lesser than one page ?
	JR	C,SINGLE		; yes
	LD	HL,4096			; no
	JR	CP4K
SINGLE:
	LD	HL,(ROMBUF+3)		; reload image size
CP4K:	PUSH	HL			; ex HL,BC
	POP	BC			; BC size
	LD	A,(ROMBUF)		; A source (base) page in eeprom
	LD	DE,(ROMBUF+1)		; image location in ram

	CALL	PLACEPAGE		; write page

	LD	HL,(ROMBUF+3)		; reload image size
	LD	DE,4096			; page size
	OR	A			; clear carry
	SBC	HL,DE			; subtract to get remaining size
	JR	C,RUNRDY
	JR	Z,RUNRDY
	LD	(ROMBUF+3),HL		; left bytes
	LD	A,(ROMBUF)		; write another page...
	INC	A
	LD	(ROMBUF),A		; next page
	LD	HL,(ROMBUF+1)
	LD	DE,4096
	ADD	HL,DE
	LD	(ROMBUF+1),HL
	JR	MULTI
RUNRDY:
	LD	HL,MRNRDY		; all ready
	CALL	OUTSTR
	CALL	BBCONIN
	CP	ESC			; abort ?
	JP	Z,WELCOM
	LD	HL,(ROMBUF+5)
	JP	(HL)
PLACEPAGE:
	PUSH	BC
	PUSH	AF
	LD	B,TRNPAG		; place image in ram
	CALL	MMGETP
	LD	(PAGBUF),A		; save current
	;
	POP	AF
	LD	B,TRNPAG		; transient page
	CALL	MMPMAP			; mount it
	POP	BC
	;
	LD	HL,TRNPAG << 12
	LDIR				; do copy
	;
	LD	A,(PAGBUF)		; restore
	LD	B,TRNPAG		; transient page
	CALL	MMPMAP			; mount it
	RET


;-----------------------------------------------------------------------

UCMDTAB:
	DEFW	TOGGLEIO	; (A) alternate serial/video i/o
	DEFW	BOOTM		; (B) boot menu
	DEFW	MATHHLDE	; (C) sum & subtract HL, DE
	DEFW	MEMDUMP		; (D) dump memory
	DEFW	EPMANCAL	; (E) call eeprom manager
	DEFW	FILLMEM		; (F) fill memory
	DEFW	GOEXEC		; (G) go exec a sub
	DEFW	CMDHELP		; (H) help
	DEFW	PORTIN		; (I) port input
	DEFW	UCPROMPT	; (J) n/a
	DEFW	BOOT		; (K) restart system
	DEFW	UCPROMPT	; (L) n/a
	DEFW	MEMMOVE		; (M) move memory block
	DEFW	UCPROMPT	; (N) n/a
	DEFW	PORTOUT		; (O) output to a port
	DEFW	UCPROMPT	; (P) n/a
	DEFW	UCPROMPT	; (Q) n/a
	DEFW	ROMRUN		; (R) select rom image
	DEFW	RWMEM		; (S) alter memory
	DEFW	MEMTEST		; (T) test ram region
	DEFW	PUPLOAD		; (U) parallel Upload
	DEFW	MEMCOMP		; (V) compare mem blocks
	DEFW	PDNLOAD		; (W) parallel DoWnload
	DEFW	UCPROMPT	; (X) n/a
	DEFW	KECHO		; (Y) keyboard echo
	DEFW	UCPROMPT	; (Z) n/a
;;

MHELP:	DEFB	CR,LF,LF
	DEFB	"A - Alternate console",CR,LF
	DEFB	"B - Boot menu",CR,LF
	DEFB	"C - HL/DE sum, subtract",CR,LF
	DEFB	"D - Dump memory",CR,LF
	DEFB	"E - Eeprom manager",CR,LF
	DEFB	"F - Fill memory",CR,LF
	DEFB	"G - Go to execute address",CR,LF
	DEFB	"H - This help",CR,LF
	DEFB	"I - Input from port",CR,LF
	DEFB	"K - Reinit system",CR,LF
	DEFB	"M - Move memory",CR,LF
	DEFB	"O - Output to port",CR,LF
	DEFB	"R - Select ROM image",CR,LF
	DEFB	"S - Alter memory",CR,LF
	DEFB	"T - Test ram",CR,LF
	DEFB	"U - Upload from parallel",CR,LF
	DEFB	"V - Compare memory",CR,LF
	DEFB	"W - Download to parallel"
	DEFB	CR,LF+$80
;;
SDLPR:	DEFB	"Download",':'+$80
STRWAIT:
	DEFB	"Waiting for remote...",CR,LF+$80
STRLOAD:
	DEFB	"Loading",CR,LF+$80
;
MVERSTR:
	IF NOT BBDEBUG
	DEFB	"Z80 DarkStar - Banked Monitor - REL ",MONMAJ,'.',MONMIN,CR,LF+$80
	ELSE
	DEFB	"Z80 DarkStar - Banked Monitor - REL ",MONMAJ,'.',MONMIN," [DEBUG]",CR,LF+$80
	ENDIF
	; Boot messages
MSYSRES:
 	DEFB	"SYSTEM INIT...",CR,LF,LF+$80
MMBSIZE:
	DEFB	"k ram, 256k eeprom",CR,LF+$80
MSETSHA:
	DEFB	"Shadowing BIOS images:",CR,LF+$80
MOK:	DEFB	"Successful",CR,LF+$80
MNOK:	DEFB	"Error",CR,LF+$80
MTX:	DEFB	"Tx",' '+$80
MRX:	DEFB	"Rx",' '+$80
MFOL:	DEFB	':',' '+$80
MNOT:	DEFB	"not ready",CR,LF+$80
MRDY:	DEFB	"ready",' '+$80
MHD:	DEFB	"IDE Drive",' '+$80
MUART:	DEFB	"UART 16C550",' '+$80
MEEPR:	DEFB	"EEPROM is a",' '+$80
MPRON:	DEFB	"unlocked",CR,LF+$80
MPROF:	DEFB	"locked",CR,LF+$80
MEPEE:	DEFB	"29EE020",' '+$80
MEPXE:	DEFB	"29xE020",' '+$80
MEPC:	DEFB	"29C020",' '+$80
MEPUNS:	DEFB	"UNSUPPORTED",' '+$80

MBMENU:	DEFB	CR,LF
	DEFB	"BOOT from:",CR,LF,LF
	DEFB	" A-B = Floppy",CR,LF
	DEFB	" C-N = IDE Volume",CR,LF
	DEFB	" O-P = Virtual on parallel",CR,LF
	DEFB	"<RET> = Monitor prompt",CR,LF,LF
	DEFB	'-','>'+$80
MBWCOM:	DEFB	CR,LF
	DEFB	"Enter command: [B]oot Menu, [H]elp"
	DEFB	CR,LF+$80
MHDERR:	DEFB	"No Volume, "
MBTERR:	DEFB	"Boot error!",CR,LF+$80
MBTNBL:	DEFB	"No bootloader!",CR,LF+$80

;-------------------------------------
; Needed modules

include modules/crtcutils.lib.asm	; 6545 crtc utils

BMFILLO:
	DEFS	ZDSMNTR + $0BFF - BMFILLO
BMFILHI:
	DEFB	$00

; end of code - this will fill with zeroes to the end of
; the non-resident image

IF	MZMAC
WSYM bootmonitor.sym
ENDIF
;
;
	END
;
