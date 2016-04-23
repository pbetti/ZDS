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

;-------------------------------------
; Common equates for BIOS/Monitor

include Common.inc.asm
;-------------------------------------
; Symbols from parent sub-pages
include sysbios.equ

;-------------------------------------
; Some macro

BBJTOBNK macro 	bnknum, raddr
	CALL	BBEXEC
	DEFW	raddr
	DEFB	bnknum
	ENDM

	; select register form uart.
	; similar to banked, exported macro but used in ISR
CRDUREG	macro	uregister
	LD	A,B		; B is uart id
	ADD	A,uregister
	LD	C,A
	IN	A,(C)
	endm

	CSEG

	NAME	'SYSCMN'

SYSCOMMON	EQU	$		; start of resident BIOS
SYSCOM:

	; safe reload, something goes wrong if we are here

	JP	RLDROM

	;----------------
	; Banked routines

	; SYSBIOS1
	PUBLIC	BBCRTCINI, BBCRTFILL, VCONOUT, VCONIN
	PUBLIC	VCONST, BBCURSET
	PUBLIC	BBU0INI, BBU1INI, SCONOUT, SCONIN
	PUBLIC	SCONST, BBU1RX, BBU1TX, BBU1ST

	; SYSBIOS2
	PUBLIC	BBFWRITE, BBFLOPIO, BBFHOME, BBFREAD
	PUBLIC	BBSIDSET, BBFDRVSEL, BBDPRMSET

	PUBLIC	BBWRVDSK, BBUPLCHR, BBRDVDSK, BBPSNDBLK
	PUBLIC	BBPRCVBLK, BBPRNCHR

	PUBLIC	BBTRKSET, BBSECSET, BBDMASET, BBDSKSEL
	PUBLIC	BBCPBOOT, BBVCPMBT

	PUBLIC	BBDIV16, BBMUL16, BBOFFCAL
	PUBLIC	BBSTTIM, BBRDTIME

	PUBLIC	BBHDINIT, BBDRIVEID, BBHDGEO
	PUBLIC	BBHDRD, BBHDWR, BBHDBOOT, BBLDPART

	; SYSBIOS3
	PUBLIC	BBEPMNGR, BBEIDCK

	; Resident routines
	PUBLIC	DELAY, MMPMAP, MMGETP, BBCONST
	PUBLIC	BBCONIN, BBCONOUT, RLDROM

	; Interrupts vector table & mngmt
	PUBLIC	SINTVEC, INTREN, INTRDI, FSTAT
	PUBLIC	FOUT, SRXSTP, SRXRSM

;-------------------------------------
; Internal BIOS calls

BBCRTCINI:	BBJTOBNK 1, CRTCINI
BBCRTFILL:	BBJTOBNK 1, CRTFILL
VCONOUT:	BBJTOBNK 1, BCONOUT
VCONIN:		BBJTOBNK 1, BCONIN
VCONST:		BBJTOBNK 1, BCONST
BBCURSET:	BBJTOBNK 1, CURSET
SCONOUT:	BBJTOBNK 1, TXCHAR0
SCONIN:		BBJTOBNK 1, RXCHAR0
SCONST:		BBJTOBNK 1, USTATUS0
BBU0INI:	BBJTOBNK 1, INIUART0
BBU1TX:		BBJTOBNK 1, TXCHAR1
BBU1RX:		BBJTOBNK 1, RXCHAR1
BBU1ST:		BBJTOBNK 1, USTATUS1
BBU1INI:	BBJTOBNK 1, INIUART1
BBINICTC:	BBJTOBNK 1, INICTC
BBRESCTC:	BBJTOBNK 1, RESCTC

BBPSNDBLK:	BBJTOBNK 2, PSNDBLK
BBUPLCHR:	BBJTOBNK 2, UPLCHR
BBPRCVBLK:	BBJTOBNK 2, PRCVBLK
BBRDVDSK:	BBJTOBNK 2, VDSKRD
BBWRVDSK:	BBJTOBNK 2, VDSKWR
BBFHOME:	BBJTOBNK 2, FHOME
BBFREAD:	BBJTOBNK 2, FREAD
BBFWRITE:	BBJTOBNK 2, FWRITE
BBFLOPIO:	BBJTOBNK 2, FLOPIO
BBPRNCHR:	BBJTOBNK 2, PRNCHR
BBSTTIM:	BBJTOBNK 2, STTIM
BBRDTIME:	BBJTOBNK 2, RDTIME
BBTRKSET:	BBJTOBNK 2, TRKSET
BBSECSET:	BBJTOBNK 2, SECSET
BBDMASET:	BBJTOBNK 2, DMASET
BBDSKSEL:	BBJTOBNK 2, DSKSEL
BBCPBOOT:	BBJTOBNK 2, CPMBOOT
BBVCPMBT:	BBJTOBNK 2, VCPMBT
BBSIDSET:	BBJTOBNK 2, SIDSET
BBFDRVSEL:	BBJTOBNK 2, FDRVSEL
BBDIV16:	BBJTOBNK 2, DIV16
BBMUL16:	BBJTOBNK 2, MUL16
BBOFFCAL:	BBJTOBNK 2, OFFCAL
BBHDINIT:	BBJTOBNK 2, HDINIT
BBDRIVEID:	BBJTOBNK 2, DRIVEID
BBHDWR:		BBJTOBNK 2, WRITESECTOR
BBHDRD:		BBJTOBNK 2, READSECTOR
BBHDGEO:	BBJTOBNK 2, GETHDGEO
BBHDBOOT:	BBJTOBNK 2, HDCPM
BBLDPART:	BBJTOBNK 2, GETPTABLE
BBDPRMSET:	BBJTOBNK 2, SETDPRM

BBEPMNGR:	BBJTOBNK 3, EPMANAGER
BBEIDCK:	BBJTOBNK 3, EIDCHECK

;;
;; Switch bank and jump
;;

BBEXEC:
	DI				; protect bank switch
	EXX				; save registers
	EX	AF,AF'
	EX	(SP),HL
	POP	DE			; remove call to us from stack

	LD	B,BBPAG	<< 4		; where we are ?
	LD	C,MMUPORT
	IN	A,(C)
	LD	(BBCBANK),A		; save current bank

	LD	E,(HL)			; E low byte of called routine
	INC	HL			; and
	LD	D,(HL)			; hi byte. DE = routine address
	INC	HL
	LD	L,(HL)			; routine bank in L
	LD	A,(HMEMPAG)		; calculate destination bank
	SUB	A,L
	OUT	(C),A			; and switch to it

	LD	(BBCSTCK),SP
	LD	HL,(BBCSTCK)		; save current stack pointer
	LD	SP,BBSTACK		; and use local stack for i/o
	PUSH	HL			; push old stack on new
	LD	A,(BBCBANK)		; reload old bank
	PUSH	AF			; and push on stack

	EI				; ready to run
	LD	HL,BBCALRET		; routine return forced to BBCALRET
	PUSH	HL			; so put it on stack
	PUSH	DE			; routine address also on stack
	EXX				; restore registers as on entry
	EX	AF,AF'

	RET				; dispatch to banked part of routine

;;
;; arrive here after called routine finished
;;
BBCALRET:
	DI
	EXX
	EX	AF,AF'
	LD	B,BBPAG << 4
	LD	C,MMUPORT
	POP	AF			; old bank
	POP	HL			; old stack
	OUT	(C),A			; restore bank
	LD	SP,HL			; restore previous stack
	EXX				; restore output register
	EX	AF,AF'
	EI				; reenable interrupts
	RET				; and return...

;;
;; Unused / fake handle
;;
BBVOID:
	RET

;-------------------------------------
; NON-banked common routines follow...

;;
;; Map page into logical space
;;
;; A - physical page (0-ff)
;; B - logical page (0-f)
;; Use C
;;
MMPMAP:
	SLA	B
	SLA	B
	SLA	B
	SLA	B
	LD	C,MMUPORT
	OUT	(C),A
	RET

;;
;; Get physical page address
;;
;; B - logical page (0-f)
;; A - return page number
;; Use C
;;
MMGETP:
	SLA	B
	SLA	B
	SLA	B
	SLA	B
	LD	C,MMUPORT
	IN	A,(C)
	RET

;;
;; DELAY
;;
;; This routine generate a delay from 1 to 65535 milliseconds.
;;

MSCNT	EQU	246

DELAY:
	PUSH	BC		; 11 c.
	PUSH	AF		; 11 c.
DLY2:
	LD	C, MSCNT	; 7 c.	(assume de = 1 = 1msec.)
DLY1:
	DEC	C		; 4 c. * MSCNT
	JR	NZ, DLY1	; 7/12 c. * MSCNT
	DEC	DE		; 6 c.
	LD	A, D		; 4 c.
	OR	E		; 4 c.
	JR	NZ, DLY2	; 7/12 c.

	POP	AF		; 10 c.
	POP	BC		; 10 c.
	RET			; 10.c

;; MSEC evaluation (ret ignored):
;
; 42 + (de) * (7 + 16 * MSCNT - 5 + 26) - 5
;
; 65 + 16 * MSCNT = ClockSpeed   (ClockSpeed is 1920 for Z80 DarkStar)
; (ClockSpeed - 65) / 16 = MSCNT = 116
; 2006/04/09:
; clock speed has been increased to 4MHz so now:
; (ClockSpeed - 65) / 16 = MSCNT = 116
; is
; (4000 - 65) / 16 = 246 = MSCNT
;

; ---------------------------------------------------------------------
; Console redirection

BBCONIN:
	LD	A,(MIOBYTE)		; conf. location
	BIT	5,A
	JP	Z,VCONIN		; video
	JP	SCONIN			; serial

BBCONOUT:
	LD	A,(MIOBYTE)		; conf. location
	BIT	5,A
	JP	Z,VCONOUT		; video
	JP	SCONOUT			; serial

BBCONST:
	LD	A,(MIOBYTE)		; conf. location
	BIT	5,A
	JP	Z,VCONST		; video
	JP	SCONST			; serial



;************************************************************************
;    FIFO BUFFERS FOR CP/M BIOS
;
; The following code by Glenn Ewing and Bob Richardson
; This code Copyright (c) 1981 MicroPro International Corp.
; made available by permission of the authors
;
;	The fifo input and output routines provide no protection
;	from underflow and overflow.  The calling code must use
;	the fstat routine to ensure that these conditions are
;	avoided.  Also, the calling code must enable and disable
;	interupts as appropriate to ensure proper maintainance of
;	the variables.
;
;; FSTAT
;; routine to determine status (fullness) of a buffer.
;; enter with IX = adr of cnt.
;; return Z-flag set if buffer empty, C-flag set if buffer full.
;; note that buffer capacity is actually size-1.
;
FSTAT:
	LD	A, (IX + 0)		; get cnt
	PUSH	DE
	LD	E, (IX + 2)		; get mask
	AND	E			; cnt = cnt mod size
	DEC	E			; e = size - 2
	CP	E			; test for full
	POP	DE
	INC	A			; clear z leaving cy
	DEC	A
	CCF
	RET
;
;; FIN
;; routine to enter a character into a buffer.
;; enter with C=chr, IX=.cnt
FIN:
	LD	A, (IX + 0)		; compute: (cnt + nout) mod size
	INC	(IX + 0)		; first update cnt
	ADD	A, (IX + 1)
	AND	(IX + 2)
	PUSH	DE
	LD	E, A			; compute base + nin
	LD	D, 0
	INC	IX
	INC	IX
	INC	IX
	ADD	IX, DE
	POP	DE
	LD	(IX+0), C		; store character
	RET
;
;; FOUT
;; routine to retreve a character from a buffer.
;; enter with IC=.cnt
;; return with C=chr
;
FOUT:
	DEC	(IX + 0)		; update cnt
	LD	A, (IX + 1)		; compute: base + nout
	INC	(IX + 1)
	AND	(IX + 2)
	PUSH	DE
	LD	E, A
	LD	D, 0
	INC	IX
	INC	IX
	INC	IX
	ADD	IX, DE
	POP	DE
	LD	C, (IX + 0)		; get chr
	RET

;************************************************************************

;
;-------------------------------------
; ISRs

;;
;; Interrupts enable / setup
;;
INTREN:
	DI
	IM	2
	LD	A,$FF
	LD	I,A
	CALL	BBINICTC
	; will call keyboard ini when available
	LD	HL,TMPBYTE
	SET	5,(HL)			; flag interrupts on
	EI
	RET

	;;
;; Interrupts disable
;;
INTRDI:
	DI
	CALL	BBRESCTC
	; will call keyboard res when available
	LD	HL,TMPBYTE
	RES	5,(HL)			; flag interrupts off
	RET

;;
;; System timer
;;
SYTIMR:
	PUSH	AF
	LD	A,(TIMRCON)
	INC	A
	LD	(TIMRCON),A
	POP	AF

	; fall through
;;
;; Void ISR
;;
VOIDISR:
	EI
	RETI

;;
;; Uart 0 receiver
;;
U0ISR:
	LD	(UASTAV),SP		; private stack
	LD	SP,UASTAK
	PUSH	AF			; reg. save
	PUSH	BC
	PUSH	IX
	CALL	SRXSTP			; lock rx
	LD	B,UART0
UISRI:	CRDUREG	R5LSR			; read status
	BIT	0,A			; data available in rx buffer?
	JR	Z,UISRE			; no.
	LD	C,B
	IN	C,(C)			; read data
	LD	IX,FIFOU0		; select our fifo
	CALL	FSTAT			; chek for room in it
	JR	C,UISRE			; throw away character if queue full
	CALL	FIN			; insert
	JR	UISRI			; repeat for more data in UART (not local) fifo
UISRE:
	POP	IX			; reg. restore
	POP	BC
	POP	AF
	LD	SP,(UASTAV)
	EI
	RETI

;;
;; Uart 1 receiver
;;
U1ISR:
	PUSH	AF
	LD	A,(CNFBYTE)
	BIT	0,A			; check for intr redir on rst8
	JR	Z,U1NUL			; ignore interrupt
	POP	AF
	RST	8			; redirect to user handler
U1NUL:
	POP	AF
	EI
	RETI

;;
;;	Lock RX on UART0
;
SRXSTP:
	LD	B,XOFC
	JR	DOSTX

;;
;;	Unlock RX on UART0
;
SRXRSM:
	LD	B,XONC
DOSTX:
	LD	A,(CNFBYTE)
	BIT	1,A			; xon/xoff enabled ?
	RET	Z			; no
	JR	TX0


;;
;; mini tx on uart 0
;;
;; B: output char

TX0:
	LD	C, UART0+R5LSR
TX01:
	IN	A,(C)			; read status
	BIT	5,A			; ready to send?
	JP	Z,TX01			; no, retry.
	LD	C, UART0+R0RXTX
	OUT	(C),B
	RET


;---------------------------------------------------------------------

;;
;; Reentry routine for safe jump to sysbios base page
RLDROM:
	LD	B,BBPAG << 4		; select bios space
	LD	C,MMUPORT
	LD	A,EEPAGE0		; remount rom and start again
	OUT	(C),A
	JP	BBPAG << 12

;
;-------------------------------------
; Storage
UASTAV:	DEFW	0
; SYCRES:	DEFW	0
UASTKB:	DEFS	10
UASTAK	EQU	$

BBSTBASE:
	DEFS	36
BBSTACK:
SYSCMLO:
	DEFS	SYSCOMMON + $03FF - SYSCMLO - 15

SINTVEC:				; interrupts vector table (8 entries)
	DEFW	VOIDISR			; CTC - chan. 0
	DEFW	SYTIMR			; CTC - chan. 1 sys timer
	DEFW	U1ISR			; CTC - chan. 2 uart 1
	DEFW	U0ISR			; CTC - chan. 3 uart 0
	DEFS	16 - 8

; SYSCMHI:
; 	DEFB	0

;
; end of code - this will fill with zeroes to the end of
; the image


IF	MZMAC
WSYM syscommon.sym
ENDIF
;
;
	END
;
