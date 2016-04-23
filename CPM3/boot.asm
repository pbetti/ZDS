;
;=======================================================================
;
; CP/M 3 Z80 DarkStar (NE Z80) Porting
;
;=======================================================================
;;---------------------------------------------------------------------
;; Version      : 1.0 - 20140904
;; Assemble     : SLR z80asm
;; Revisions:
;; 20140905	- Code start
;;---------------------------------------------------------------------

	TITLE	'BOOT LOADER MODULE FOR CP/M 3.1'

	.Z80

	; define logical values:
	include	common.inc
	include	syshw.inc

LDRDBG	EQU	false

FTRACE	macro	p1
	if ldrdbg
	ld	(OLDSTACK),SP
	ld	sp,NEWSTACK
	push	af
	push	bc
	push	de
	push	hl
	call	inline
	defb	p1,cr,lf,'$'
	call	bbconin
	pop	hl
	pop	de
	pop	bc
	pop	af
	ld	sp,(OLDSTACK)
	endif
	endm

HEX16	macro	p1,p2
	if ldrdbg
	ld	(OLDSTACK),SP
	ld	sp,NEWSTACK
	push	af
	push	bc
	push	de
	push	hl
	ld	a,p1
	call	phex
	ld	a,p2
	call	phex
	ld	c,CR
	call	BBCONOUT
	ld	c,LF
	call	BBCONOUT
	pop	hl
	pop	de
	pop	bc
	pop	af
	ld	sp,(OLDSTACK)
	endif
	endm

HEX8	macro	p1
	if ldrdbg
	ld	(OLDSTACK),SP
	ld	sp,NEWSTACK
	push	af
	push	bc
	push	de
	push	hl
	ld	a,p1
	call	phex
	ld	c,CR
	call	BBCONOUT
	ld	c,LF
	call	BBCONOUT
	pop	hl
	pop	de
	pop	bc
	pop	af
	ld	sp,(OLDSTACK)
	endif
	endm

	; define public labels:
	PUBLIC	?INIT,?LDCCP,?RLCCP
	PUBLIC	IDEERR

	; externally defined entry points and labels:
	EXTRN	?PMSG,?PDERR,?CONIN
	EXTRN	@CIVEC,@COVEC,@AIVEC,@AOVEC,@LOVEC
	EXTRN	@CBNK,?BNKSL,@DTBL
	IF	BANKED
	EXTRN	BANKBF
	ENDIF

;
;
	; we can do initialization from banked memory (if we have it):
	IF BANKED
	DSEG				; init done from banked memory
	ELSE
	CSEG				; init to be done from common memory
	ENDIF

BDOS	EQU	5			; BDOS entry point
CCPBNK	EQU	8

	;; ?init
	;; hardware initialization other than character and disk i/o:
?INIT:
	; assign console input and output to crtc:
	LD	HL,1000000000000000B	; assign console to CRTC:
	LD	(@CIVEC),HL
	LD	(@COVEC),HL
	LD	HL,0100000000000000B	; assign auxiliary to UART0:
	LD	(@AIVEC),HL
	LD	(@AOVEC),HL
	LD	HL,0001000000000000B	; assign printer to LPT:
	LD	(@LOVEC),HL

	LD	A,'3'
	LD	(COPSYS),A		; identify opsys for partitions

	LD	A,(CDISK)
	INC	A
	LD	(BOOTDRIVE),A		; remember boot drive

	PUSH	IY
	CALL	BBHDINIT		; IDE init
	OR	A
	JR	NZ,IDEERR
	CALL	BBLDPART
	POP	IY

	; print the sign-on message:
	LD	HL,SIGNONMSG		; point to it
	JP	?PMSG			; and print it

IDEERR:
	LD	HL,IDEMSG		; report the error
	JP	?PMSG
	;

	IF BANKED
	CSEG
	ENDIF

	;; ?ldccp
	;; this routine is entered to load the ccp.com file into the tpa bank
	;; at system cold start:
?LDCCP:
	; set up the fcb for the file operation:
	XOR	A			; zero extent
	LD	(CCPFCB+15),A
	LD	A,(BOOTDRIVE)
	LD	(CCPFCB),A		; set drive
	LD	HL,0			; start at beginning of file
	LD	(FCBNR),HL

	; try to open the ccp.com file:
	LD	DE,CCPFCB		; point to fcb
	CALL	LOPEN			; attempt the open operation
	INC	A			; was it on the disk ?
	JR	NZ,CCPFOUND		; yes -- go load it

	; we arrive here when ccp.com file wasn't found:
	LD	HL,CCPMSG		; report the error
	CALL	?PMSG
	CALL	?CONIN			; get a response
	JR	?LDCCP			; and try again

	; file was opened ok -- read it in:
CCPFOUND:
	LD	DE,0100H		; load at bottom of tpa
	CALL	LSETDMA			; by setting the next dma address
	LD	DE,128			; Set multi sector i/o count
	CALL	LSETMULTI		; to allow up to 16k bytes in one operation
	LD	DE,CCPFCB		; point to the fcb
	CALL	LREAD			; And read the ccp in
	CP	1			; error 1 is ok, since we read until EOF
	JR	Z,POSTLOAD
	OR	A			; 0
	JR	Z,POSTLOAD

	LD	HL,LDERRM
	CALL	?PMSG
	CALL	?PDERR
	CALL	BBCONIN
	JP	$FC00			; reboot system

POSTLOAD:

	; following code for banked systems -- moves ccp image to bank 2
	; for later reloading at warm starts:
	IF	BANKED

	LD	HL,0100H		; get ccp image from start of tpa
	LD	B,25			; transfer 25 logical sectors
	LD	A,(@CBNK)		; get current bank
	PUSH	AF			; and save it
LD1:
	PUSH	BC			; save sector count
	LD	A,1			; Select tpa bank
	CALL	?BNKSL
	LD	BC,128			; transfer 128 bytes to temporary buffer
	LD	DE,BANKBF		; temporary buffer addr in [de]
	PUSH	HL			; save source address
	PUSH	DE			; and destination
	PUSH	BC			; and count
	LDIR				; block move sector to temporary buffer
	LD	A,CCPBNK		; select bank to save ccp in
	CALL	?BNKSL
	POP	BC			; get back count
	POP	HL			; last destination will be new source addr
	POP	DE			; last source will be new destination
	LDIR				; block move sector from buffer to alternate
	; bank
	EX	DE,HL			; next addr will be new source addr
	POP	BC			; get back sector count
	DJNZ	LD1			; drop sector count and loop till done...
	POP	AF			; when done -- restore original bank
	JP	?BNKSL

	ELSE

	; if non-banked we return through here:
	RET

	ENDIF


	;; ?rlccp
	;; routine reloads ccp image from bank 2 if banked system or from the
	;; disk if non-banked version:
?RLCCP:
	IF	BANKED
	; following code for banked version:
	LD	HL,0100H		; get ccp image from start of alternate buffER
	LD	B,25			; transfer 25 logical sectors
	LD	A,(@CBNK)		; get current bank
	PUSH	AF			; and save it
RL1:
	PUSH	BC			; save sector count
	LD	A,CCPBNK		; select alternate bank
	CALL	?BNKSL
	LD	BC,128			; transfer 128 bytes to temporary buffER
	LD	DE,BANKBF		; temporary buffer addr in [de]
	PUSH	HL			; save source address
	PUSH	DE			; and destination
	PUSH	BC			; and count
	LDIR				; block move sector to temporary buffer
	LD	A,1			; put ccp to tpa bank
	CALL	?BNKSL
	POP	BC			; get back count
	POP	HL			; last destination will be new source addr
	POP	DE			; last source will be new destination
	LDIR				; block move sector from buffer to tpa bank
	EX	DE,HL			; next addr will be new source addr
	POP	BC			; get back sector count
	DJNZ	RL1			; drop sector count and loop till done...
	POP	AF			; get back last current bank #
	JP	?BNKSL			; select it and return

	ELSE
	; following code is for non-banked versions:
	JP	?LDCCP			; just do load as though cold boot

	ENDIF

;
	IF	BANKED
	CSEG
	ENDIF

	; cp/m bdos function interfaces

	; open file:
LOPEN:
	LD	C,15
	JP	BDOS		; open file control block

	; set dma address:
LSETDMA:
	LD	C,26
	JP	BDOS		; set data transfer address

	; set multi sector i/o count:
LSETMULTI:
	LD	C,44
	JP	BDOS		; set record count

	; read file record:
LREAD:
	LD	C,20
	JP	BDOS		; read records

	; ccp not found error message:
CCPMSG:
	DEFB	CR,LF,"BIOS ERR: NO CCP.COM FILE",0
	; ide init error
IDEMSG:
	DEFB	CR,LF,"IDE HD INIT ERROR.",0
	; load error
LDERRM:
	DEFB	CR,LF,"LOAD ERROR. REBOOTING",0

BOOTDRIVE:
	DB	0

	; fcb for ccp.com file loading:
CCPFCB:
	DEFB	1			; auto-select drive a
	DEFB	"CCP     COM"		; file name and type
	DEFB	0,0,0,0
	DEFS	16
FCBNR:	DEFB	0,0,0,0
;
;
	IF	BANKED
	CSEG
	ENDIF


	; SYSTEM SIGN-ON MESSAGE:
SIGNONMSG:
	DEFB	CR,LF,CR,LF,"Z80 CP/M version 3.1 (Piergiorgio Betti 06/09/2014)"
	IF NOT BANKED
	DEFB	CR,LF,"Non banked version."
	ELSE
	DEFB	CR,LF,"Banked version."
	ENDIF
	IF ZPM3
	DEFB	CR,LF,"+ ZPM3 r.10 2/1/93 by Simeon Cran"
	ELSE
	DEFB	CR,LF,"+ CP/M 3 Plus standard BDOS"
	ENDIF
	DEFB	CR,LF,0


	IF LDRDBG
; Print a string in [HL] up to '$'
PSTRING:
	LD	A,(HL)
	CP	'$'
	RET	Z
	LD	C,A
	CALL	BBCONOUT
	INC	HL
	JP	PSTRING

;;
;; Inline print
;;
INLINE:
	EX	(SP),HL			; get address of string (ret address)
	CALL	PSTRING
	EX	(SP),HL			; load return address after the '$'
	RET				; back to code immediately after string

PHEX:	PUSH	AF
	PUSH	BC
	PUSH	AF
	RRCA
	RRCA
	RRCA
	RRCA
	CALL	ZCONV
	POP	AF
	CALL	ZCONV
	POP	BC
	POP	AF
	RET
;
ZCONV:	AND	0FH		;HEX to ASCII and print it
	ADD	A,90H
	DAA
	ADC	A,40H
	DAA
	LD	C,A
	CALL	BBCONOUT
	RET

OLDSTACK:
	DEFW	0
	DEFS	40
NEWSTACK:
	DEFW	0

	ENDIF

	END

