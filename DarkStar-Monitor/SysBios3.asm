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

	EXTERN	DELAY, MMPMAP, MMGETP
	EXTERN	BBCONIN, BBCONOUT, RLDROM

	DSEG

	NAME	'SYS3BI'

SYSBIOS3	EQU	$		; start of non resident BIOS

	; safe reload, something goes wrong if we are here

	JP	RLDROM

SYSBID3:
	DEFB	'SYSBIOS3'

;
FILCHR		EQU	'-'		; prompt characters
LINCHRC		EQU	$C1		; line draw char
LINCHRS		EQU	'_'		; line draw char (serial)
DELIM1		EQU	'['
DELIM2		EQU	']'
ESC		EQU	$1B		; end of job
DEL		EQU	$7F		; delete key
ERLIN		EQU	$18		; erase whole line (control X)
UPLIN		EQU	$15		; up a line in the display
DLIN		EQU	$1A		; down a line
LCHR		EQU	$08		; left a character
IMTORG		EQU	$0000		; location in page
IMGORG		EQU	$1000


;;
;; Manage EEPROM images
;;
EPMANAGER:
	LD	B,TRNPAG		; copy table in ram
	CALL	MMGETP
	LD	(TEMP),A		; save current
	;
	LD	A,IMTPAG		; in eeprom table
	LD	B,TRNPAG		; transient page
	CALL	MMPMAP			; mount it
	;
	LD	HL,[TRNPAG << 12 ] + IMTORG
	LD	DE,RAMTBL		; our copy
	LD	BC,IMTSIZ
	LDIR				; do copy
	;
	LD	A,(TEMP)		; restore
	LD	B,TRNPAG		; transient page
	CALL	MMPMAP			; mount it
	;
	LD	A,$CD			; patch burn routine
	LD	(PRADR),A		; for progress routine
	LD	HL,PBYTECOUNT
	LD	(PRADR+1),HL		; that is PBYTECOUNT
	;
	LD	(SPREG),SP
	LD	SP,BBBASE - 128		; switch to our stack

PDRAW:	LD	C,FF			; draw page
	CALL	BBCONOUT
	CALL	CRSROF
	CALL	REVON
	CALL	INLINEXY
	DEFB	0
	DEFB	(80 - (MGTE - MGTS))/2
MGTS:	DEFB	" * EEPROM MANAGER * ",0
MGTE:	CALL	CLRATR

	CALL	DISPIMGS
	XOR	A
	LD	(CURBLK),A		; at block 0
	LD	B,A
	INC	A
	CALL	SELECT

	LD	H,13
	LD	L,0
	CALL	SETCUR
	CALL	PLIN80
	CALL	INLINEXY
	DEFB	13,59
	DEFB	"[ Image Editor ]",0
	CALL	DBOTTOMLINE

	LD	H,23
	LD	L,1
	CALL	SETCUR
	CALL	REVON
	LD	C,' '
	LD	B,78
	CALL	PSTR
	CALL	INLINEXY
	DEFB	23
	DEFB	(80 - (MMIE - MMIS))/2
MMIS:	DEFB	" Select: Up/Dn - Image: [A]dd [D]elete [M]odify - Table: [C]lear ",0
MMIE:	CALL	REVOF
	CALL	HLITON
	CALL	INLINEXY
	DEFB	22
	DEFB	(80 - (MESE - MESS))/2
MESS:	DEFB	"ESC: Stop/Exit",0
MESE:	CALL	CLRATR

WCMD:	CALL	BBCONIN
	CALL	ATOUP
WCMD1:
	CP	'C'			; clear table
	JP	Z,CTABLE
	CP	ESC			; exit
	JP	Z,DOEXI
	CP	$05			; ^E up
	JP	Z,PRVBLK
	CP	$18			; ^X down
	JP	Z,NXTBLK
	CP	$15			; up
	JP	Z,PRVBLK
	CP	$1A			; down
	JP	Z,NXTBLK
	CP	'G'		;***** debugger *****
	JP	Z,$A000
	CP	'A'			; add image
	JP	Z,ADDIM
	CP	'F'
	JP	Z,FAKEOP
	CP	'M'
	JP	Z,MODIM
	CP	'D'
	JP	Z,DELIM

	JR	WCMD

;;
;; Disable writing on eeprom
;;
FAKEOP:
	LD	A,$FF
	LD	(FLAGFAKE),A		; disabled
	CALL	INLINEXY
	DEFB	13,5
	DEFB	" Locked ",0
	JP	WCMD

;;
;; Return to Bootmonitor
;;
DOEXI:
	CALL	CRSRON
	LD	C,FF
	CALL	BBCONOUT
	LD	SP,(SPREG)		; restore old stack
	RET

;;
;; Clear Table
;;
CTABLE:
	CALL	INLINEXY
	DEFB	20
	DEFB	(80 - (MCTE - MCTS))/2
MCTS:	DEFB	"Completely erase table ?",0
MCTE:
	CALL	ASKCNF
	JP	NZ,RESETEDT
	CALL	CONFIRM1
	JP	NZ,RESETEDT
	CALL	CONFIRM2
	JP	NZ,RESETEDT
	CALL	CLRMSG
	LD	HL,RAMTBL
	LD	DE,RAMTBL+1
	LD	BC,IMTSIZ-1
	LD	(HL),0
	LDIR
	CALL	SY2TBL			; system entry
	JP	PDRAW

;;
;; Add image
;;
ADDIM:
	LD	A,(INAME+1)		; free slot ?
	OR	A
	JR	Z,ADDIM1		; is free
	CALL	INLINEXY
	DEFB	20
	DEFB	(80 - (MOVE - MOVS))/2
MOVS:	DEFB	"Can't overwrite slot!",0
MOVE:
	CALL	BBCONIN
	CALL	CLRMSG
	JP	WCMD			; exit

ADDIM1:
	CALL	REVON
	CALL	INLINEXY
	DEFB	20
	DEFB	(80 - (MIWE - MIWS))/2
MIWS:	DEFB	" Image MUST BE present in ram @ 1000H and no more 32Kb in size ",0
MIWE:	CALL	REVOF

	CALL	CLREDT			; init blank buffer
	CALL	INLINEXY
	DEFB	19,61
	DEFB	"Add Image",$1,0		; activate caps-lock toot
	LD	DE,EDITMSK
	CALL	FORMIN			; edit form
	LD	C,$2
	CALL	BBCONOUT		; reset caps-lock
	CALL	CLRMSG
	CALL	VALIDATE		; validate input
	LD	A,$FF
	LD	(FLAGBURN),A		; will burn image & table
ASKTBURN:
	; well
	CALL	CONFIRM1
	JP	NZ,RESETEDT
	CALL	CONFIRM2
	JP	NZ,RESETEDT
	; ok... hope you know what you're doing.
	LD	A,(CURBLK)
	LD	B,A
	CALL	GETBLK
	CALL	ED2TBL			; update table
	CALL	CLRMSG

	CALL	INLINEXY
	DEFB	20
	DEFB	(80 - (MHOE - MHOS))/2
MHOS:	DEFB	"Hope you know what you are doing",0
MHOE:
	CALL	INLINEXY
	DEFB	21
	DEFB	(80 - (MBSE - MBSS))/2
MBSS:	DEFB	"Press a key to start burning",0
MBSE:
	CALL	BBCONIN
	CALL	CLRMSG
	CALL	BLNKON
	CALL	INLINEXY
	DEFB	20
	DEFB	(80 - (MBSE - MBSS))/2
MBUS:	DEFB	"Burning. Please wait. Do nothing until end.",0
MBUE:	CALL	BLNKOF

	LD	A,(FLAGFAKE)		; write locked ?
	OR	A
	JR	NZ,AFTERBURN		; yes

	LD	A,(FLAGBURN)		; write image
	OR	A
	JR	Z,TBLBURN		; no

	CALL	BURNIMAGE
TBLBURN:
	CALL	BURNTABLE
AFTERBURN:
	CALL	CLRMSG
	CALL	INLINEXY
	DEFB	20
	DEFB	(80 - (MBDE - MBDS))/2
MBDS:	DEFB	"Done. Press any key.",0
MBDE:
	CALL	BBCONIN
	XOR	A
	LD	(FLAGBURN),A		; reset image write
	JP	PDRAW


;;
;; Modify image
;;
MODIM:
	CALL	REVON
	CALL	INLINEXY
	DEFB	20
	DEFB	(80 - (MMTE - MMTS))/2
MMTS:	DEFB	" This will modify just table entry and NOT image on EEPROM ",0
MMTE:	CALL	REVOF

	CALL	INLINEXY
	DEFB	19,61
	DEFB	"Modify Entry",$1,0	; activate caps-lock toot
	LD	DE,EDITMSK
	CALL	FORMIN			; edit form
	LD	C,$2
	CALL	BBCONOUT		; reset caps-lock
	CALL	CLRMSG
	CALL	VALIDATE		; validate input
	; ok
	LD	B,1
	LD	A,(CURBLK)		; intercept rewrite on block 0
	OR	A
	JR	NZ,ASKRBR
	CALL	BLNKON
	CALL	INLINEXY
	DEFB	21
	DEFB	(80 - (MR0E - MR0S))/2
MR0S:	DEFB	"** SYSTEM BLOCK!! **",0
MR0E:	LD	B,3
ASKRBR:	CALL	BLNKON
	CALL	INLINEXY
	DEFB	20
	DEFB	(80 - (MRBE - MRBS))/2
MRBS:	DEFB	"REBURN Image too ?",0
MRBE:	CALL	BLNKOF
	CALL	ASKCNF
	JP	NZ,RBATBL0		; if answer is "no"
	DJNZ	ASKRBR
	LD	A,$FF
	LD	(FLAGBURN),A		; will burn image & table
	JP	ASKTBURN
RBATBL0:
	LD	A,(CURBLK)		; recheck block 0 and in case skip
	OR	A			; write at all
	JP	NZ,ASKTBURN
	JP	RESETEDT

;;
;; Delete image
;;
DELIM:
	LD	A,(CURBLK)
	LD	B,A
	CALL	GETBLK
	LD	A,(INAME+1)
	OR	A
	JP	Z,WCMD
	CALL	INLINEXY
	DEFB	19,61
	DEFB	"Delete Entry",0
	CALL	CLRMSG
	CALL	INLINEXY
	DEFB	20
	DEFB	(80 - (MDTE - MDTS))/2
MDTS:	DEFB	"ERASE this table entry ?",0
MDTE:
	CALL	ASKCNF
	JP	NZ,RESETEDT
	CALL	CLREDT			; clear buffer block
	; well
	JP	ASKTBURN

;;
;; Clear messages area (rows 20, 21)
;;
CLRMSG:
	LD	H,20
	LD	L,0
	CALL	SETCUR
	CALL	CLREOL
	CALL	CRLF
	CALL	CLREOL
	RET

;;
;; Confirm routines
;;
;; Z flag > yes, any other key = no
CONFIRM2:
	CALL	CLRMSG
	CALL	BLNKON
	CALL	INLINEXY
	DEFB	20
	DEFB	(80 - (MC2E - MC2S))/2
MC2S:	DEFB	"Really confirm ? (y/n)",0
MC2E:	CALL	BLNKOF
	JR	ASKCNF

CONFIRM1:
	CALL	CLRMSG
	CALL	HLITON
	CALL	INLINEXY
	DEFB	20
	DEFB	(80 - (MC1E - MC1S))/2
MC1S:	DEFB	"Confirm ? (y/n)",0
MC1E:	CALL	HLITOF

ASKCNF:	CALL	BBCONIN
	CALL	ATOUP
	CP	'Y'
	PUSH	AF
	CALL	CLRMSG
	POP	AF
	RET

;;
;; Validate input and store parameters in binary
;;
VALIDATE:
	LD	DE,BEADDR		; rom page
	LD	B,2			; len 2
	CALL	HEXSTOR
	JR	NZ,INVALID
	LD	HL,(CNVBUF)
	LD	(CURPAG),HL

	LD	DE,BIADDR		; image base address
	LD	B,4			; len 4
	CALL	HEXSTOR
	JR	NZ,INVALID
	LD	HL,(CNVBUF)
	LD	(CURADR),HL

	LD	DE,BSIZE		; image size
	LD	B,4			; len 4
	CALL	HEXSTOR
	JR	NZ,INVALID
	LD	HL,(CNVBUF)
	LD	(CURSIZ),HL

	;**** should check for overlapping here...

	LD	BC,0
	LD	HL,(CURADR)		; check overlap of $D000-$DFFF region
					; that is forbidden
	LD	DE,[TRNPAG << 12] + $0FFF
	OR	A
	SBC	HL,DE
	JR	NC,VAL2
	INC	B
VAL2:	LD	HL,(CURADR)		; greater than $DFFF: ok
	LD	DE,(CURSIZ)
	ADD	HL,DE
	LD	DE,TRNPAG << 12
	OR	A
	SBC	HL,DE
	JR	C,VAL3
	INC	C
VAL3:
	LD	A,B
	AND	C
	JR	NZ,INVALID
	RET

INVALID:
	POP	HL			; clear last call
	CALL	HLITON
	CALL	INLINEXY
	DEFB	20
	DEFB	(80 - (MNVE - MNVS))/2
MNVS:	DEFB	"Wrong data!",0
MNVE:	CALL	HLITOF
	CALL	BBCONIN

	; fall through

;;
;; Reset editor
;;
RESETEDT:
	CALL	CLRMSG
	CALL	DBOTTOMLINE
	LD	A,(CURBLK)
	LD	B,A
	INC	A
	CALL	SELECT
	JP	WCMD

;;
;; Convert ascii buffer to binary
;;
HEXSTOR:
	LD	HL,$0000
NXTH:	LD	A,(DE)
	LD	C,A
	CALL	CHECKHEX
	JR	C,CNHEX			; if not hex digit
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	OR	L
	LD	L,A
	INC	DE
	DJNZ	NXTH

CNHEX:	LD	(CNVBUF),HL
	XOR	A
	CP	B			; ok if B = 0
	RET				; else ret NZ


;;
;; CHKHEX - check for hex ascii char in A
;
CHECKHEX:
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

;;
;; Show images
;;
DISPIMGS:
	CALL	SY2TBL			; system entry
	LD	E,1
	LD	D,MAXBLK
	LD	B,0
	LD	H,2			; initial row
	LD	L,2
NBLK:	CALL	SETCUR
	LD	A,B			; image number
	PUSH	HL
	CALL	ASCIIA
	PUSH	DE
	LD	DE,MSEP
	CALL	PRINT
	PUSH	BC
	CALL	GETBLK
	LD	A,(HL)			; is a valid block ?
	CP	TNAMELEN
	JR	Z,BLKDSP		; yes
	LD	(TEMP),HL		; save block address
	CALL	CLREDT			; init buffer block
	LD	HL,(TEMP)		; reinit HL
	CALL	ED2TBL			; init table block
	LD	HL,(TEMP)		; reinit HL
BLKDSP:	CALL	TBL2ED
	CALL	DSPBLKID
	POP	BC
	POP	DE
	POP	HL
	DEC	D
	JR	Z,DISPIEND
	DEC	E
	JR	Z,DRCOL
	INC	B
	LD	E,1
	INC	H
	LD	L,2
	JR	NBLK
DRCOL:
	INC	B
	LD	L,42
	JR	NBLK
DISPIEND:
	CALL	CLREDT			; clear buffer block
	RET


;;
;; Display block name
;;
DSPBLKID:
	LD	HL,BNAME
	LD	B,TNAMELEN
	CALL	NPRINT
	LD	DE,MSEP
	CALL	PRINT
	LD	HL,BDESC
	LD	B,TDESCLEN
	CALL	NPRINT
	RET

;;
;; Select previous block
;;
PRVBLK:
	LD	A,(CURBLK)		; get actual
	OR	A
	JR	Z,PRVBLE		; at top
	LD	B,A
	XOR	A
	CALL	SELECT			; update old
	LD	A,(CURBLK)
	DEC	A
	LD	(CURBLK),A		; move up
	LD	B,A
	INC	A
	CALL	SELECT			; update new
PRVBLE:
	JP	WCMD

;;
;; Select previous block
;;
NXTBLK:
	LD	A,(CURBLK)		; get actual
	CP	MAXBLK-1
	JR	Z,NXTBLE		; at bottom
	LD	B,A
	XOR	A
	CALL	SELECT			; update old
	LD	A,(CURBLK)
	INC	A
	LD	(CURBLK),A		; move up
	LD	B,A
	INC	A
	CALL	SELECT			; update new
NXTBLE:
	JP	WCMD


;;
;; Select a block
;;
;; B < block A < 0 normal, 1 reversed

SELECT:
	PUSH	DE
	PUSH	HL
	PUSH	AF
	LD	A,B			; calc line
	SRL	A
	ADD	A,2			; add screen offset
	LD	H,A
	BIT	0,B			; calc row
	JR	Z,SELC1			; even is on right col
	LD	L,47
	JR	SELC2
SELC1:	LD	L,7
SELC2:	CALL	SETCUR			; locate cursor
	CALL	GETBLK			; get block addr from B
	CALL	TBL2ED			; in buffer
	POP	AF
	PUSH	AF
	OR	A
	JR	Z,SELC3
	CALL	REVON
SELC3:	CALL	DSPBLKID		; do display
	CALL	REVOF
	POP	AF
	OR	A
	JR	Z,SELC4
	LD	DE,EDITMSK
	CALL	PRINTMENU
SELC4:	POP	HL
	POP	DE
	RET

;;
;; Clear editor buffer
;;
CLREDT:
	LD	HL,EDTCPY
	LD	DE,INAME
	LD	BC,EDTSIZ
	LDIR
	RET

;;
;; Copy block from table to buffer
;;
;; HL < table block address
TBL2ED:
	LD	DE,INAME
	LD	BC,EDTSIZ
	LDIR
	RET

;;
;; Copy block from table to buffer
;;
;; HL < table block address
ED2TBL:
	EX	DE,HL
	LD	HL,INAME
	LD	BC,EDTSIZ
	LDIR
	EX	DE,HL
	RET

;;
;; Copy SYSTEM block from table to buffer
;;
SY2TBL:
	LD	DE,RAMTBL
	LD	HL,EDTSYS
	LD	BC,EDTSIZ
	LDIR
	RET
;;
;; Get block
;;
;; B < block num - HL > blok address
GETBLK:
	PUSH	DE
	INC	B
	LD	DE,TBLBLK
	LD	HL,RAMTBL-TBLBLK
GETBL1:	ADD	HL,DE
	DJNZ	GETBL1
	POP	DE
	RET

;;
;; Draw bottom line
;;
DBOTTOMLINE:
	LD	H,19
	LD	L,0
	CALL	SETCUR
	CALL	PLIN80
	CALL	INLINEXY
	DEFB	19,59
	DEFB	"[              ]",0
	RET


;;
;; Draw a line
;;
;; plin80: line 80 chars
;; plin  : line as long as B content
;; pstr  : C char as long as B content
PLIN80:
	LD	B,80			; across the screen
PLIN:
	LD	C,LINCHRC
	LD	A,(MIOBYTE)		; conf. location
	BIT	5,A
	JR	Z,PSTR			; video
	LD	C,LINCHRS		; serial
PSTR:	CALL	BBCONOUT
	DJNZ	PSTR
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
;; Print byte count during burn
;;
PBYTECOUNT:
	PUSH	HL
	PUSH	DE
	PUSH	BC
	PUSH	AF
	LD	H,21			; where to show progress
	LD	L,38
	CALL	SETCUR
	LD	HL,(CNVBUF)
	LD	DE,128
	ADD	HL,DE
	LD	(CNVBUF),HL
	CALL	ASCIIHL
	POP	AF
	POP	BC
	POP	DE
	POP	HL
	RET

;;
;; To uppecase A
;;
ATOUP:
	CP	$60
	JP	M,ATEXI
	CP	$7B
	JP	P,ATEXI
	RES	5,A
ATEXI:	RET


;;
;; Emit new line
CRLF:
	CALL	INLINE
	DEFB	CR,LF,0
	RET

;;
;; Some video utilities

CRSRON:	LD	C,$05
	JR 	ZDDCHR

CRSROF:	LD	C,$04
	JR 	ZDDCHR

CLREOL:	LD	C,$0F
	JR 	ZDDCHR

CLRATR:	LD	C,$11
	JR 	ZDDCHR

ZDDCHR: CALL	BBCONOUT
	RET

BLNKON:
	CALL	INLINE
	DB	$1B,$02,$0D,$00
	RET
BLNKOF:
	CALL	INLINE
	DB	$1B,$01,$0D,$00
	RET
REVON:
	CALL	INLINE
	DB	$1B,$1B,$0D,$00
	RET
REVOF:
	CALL	INLINE
	DB	$1B,$1C,$0D,$00
	RET
UNDRON:
	CALL	INLINE
	DB	$1B,$04,$0D,$00
	RET
UNDROF:
	CALL	INLINE
	DB	$1B,$03,$0D,$00
	RET
HLITON:
	CALL	INLINE
	DB	$1B,$06,$0D,$00
	RET
HLITOF:
	CALL	INLINE
	DB	$1B,$05,$0D,$00
	RET
;;
;; Set cursor position. Absolute
;;
;; HL = cursor pos.
;; N.B.: This routine does not check for limits

SETCUR:
	PUSH	BC
	LD	C,ESC
	CALL	BBCONOUT
; X address
	LD	A,L
	ADD	A,32
	LD	C,A
	CALL	BBCONOUT
; Now the Y value
	LD	A,H
	ADD	A,32
	LD	C,A
	CALL	BBCONOUT
; terminate
	LD	C,0
	CALL	BBCONOUT
	POP	BC
	RET

;----------------------------------------------------------------
;        FORMIN is a routine taken from the ASMLIB library
;                    by Richard C Holmes
;
; The routine will display all the strings then display string 1 and wait
; for console input. When the strings are displayed the program checks if
; the console buffer is empty and if so will send a set of dashes and if
; not will display the characters along with any make-up dashes required.
;
FORMIN:	; Note that the address of the menu is passed in register DE
	LD	(MNUADR),DE		; save the menu address.
	LD	(HLSAVE),HL		; save the registers
	LD	(BCSAVE),BC
;
	CALL	CRSRON
	CALL	PRINTMENU
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
GETINPUT:
	LD	DE,(MNUADR)		; Get the menu address
	XOR	A
	LD	(ITMNUM),A		; save the menu item number
;
GETITEM:
; Now display the item DE points to.
	CALL	DISPITEM		; display menu & console buffer
; After DISPITEM DE -> the start of the NEXT item in the list.
	LD	(NXTADR),DE		; indicate the start of next item
; Next we must cursor position to the screen X and Y position of the data field
	LD	DE,BUFX			; point to data buffer X, Y screeb addr
	CALL	SETXY			; position cursor using DE -> XY
; Now point to the buffer. We must re-print it if characters in it.
	LD	HL,(CONADR)		; HL -> start of console buffer
	LD	A,L
	OR	H			; Is H = L = 0 ??
	JP	Z,NXTLIN		; If so then process the next line
;
	LD	C,(HL)			; C = maximum characters allowed
	INC	HL			; HL -> characters in the buffer
	LD	E,L
	LD	D,H			; copy address of length into DE
	INC	HL			; now hl -> first character in string.
;
;Now we detect if there are already characters there. If so print them.
	LD	A,(DE)			; get the number
	OR	A
	JR	Z,NOCHARS
	LD	B,A			; set up a loop counter
PCL:
	LD	A,(HL)			; fetch a character
	INC	HL			; point to next character
	CALL	COE
	DJNZ	PCL			; print characters till b = 0
;
; This section of code assumes that C = maximum characters allowed and
; DE -> characters in the buffer already. HL must point to characters in
; the buffer and DE points to the character in the buffer actual length.
;
NOCHARS: ; Read console for characters.
	CALL	BBCONIN			; get the character via direct input
; check if a terminator
	CP	ERLIN
	JP	Z,ERASELINE
	CP	ESC
	JP	Z,FINGET		; finish of the get then
	CP	0DH			; carriage return ?
	JP	Z,NXTLIN
	CP	UPLIN			; go up a line
	JP	Z,PRVLIN
	CP	DLIN
	JP	Z,NXTLIN
	CP	LCHR
	JP	Z,LFTCHR
	CP	DEL
	JP	Z,LFTCHR
	CP	020H			; check if less than a space
	JR	C,IGNCHR			; ignore them
; If it is not a formatting character then save it then check if the
; buffer is full before inserting it. C = max allowed, B = current size
	LD	(TEMP),A
	LD	A,(DE)			; get character read counter
	CP	C			; compare to maximum allowed
	JR	Z,IGNCHR		; ignore if exactly full
	JR	NC,IGNCHR		; no carry if too full
; If not full or overfull then we merely bump the count and save it back
	INC	A
	LD	(DE),A			; saved
; All else means that we can insert the character into the buffer
	LD	A,(TEMP)		; fetch
	LD	(HL),A			; save
	CALL	COE			; echo the character now
	INC	HL			; point to next memory address
	JR	NOCHARS			; keep reading characters
;
; This trivial bit of code rings the bell then jumps to get another char.
; We usually get here due to an illegal control code or buffer full.
;
IGNCHR:; Ignore the character in a and ring bell then return to loop
	LD	A,07			; bell code
	CALL	COE
	JR	NOCHARS			; get next character
;
; This piece of code handles the end of input due to carriage return or
; down a line code inputs. We must assume that all parameters are up to
; date so we only have to address the next line of the menu then return
; to the start of the get section to continue.
;
NXTLIN:
	LD	A,(ITMNUM)
	INC	A			; load.bump.save item number
	LD	(ITMNUM),A
;
	LD	DE,(NXTADR)		; get address of next item
	LD	A,(DE)
	CP	0FFH			; is it the end of the menu ??
	JP	NZ,GETITEM		; use it if it is NOT
	LD	DE,(MNUADR)		; all else we get the start address
	XOR	A
	LD	(ITMNUM),A		; indicate first item number
	JP	GETITEM			; restart from scratch
;
; This section of code must go back a line. It does this by backing up
; using $ characters as indicators. Note that if ITMNUM = 1 then
; no action is taken and we return to the read loop.
;
PRVLIN:
	LD	A,(ITMNUM)		; get line number
	OR	A
	JP	Z,NOCHARS		; ignore all this if line 1
	DEC	A
	LD	(ITMNUM),A		; decrement and save
	OR	A
	JR	NZ,PRVLIN1
	LD	DE,(MNUADR)		; point to item 1
	JP	GETITEM
; If here then we must goto the (ITMNUM)'th dollar address + 3 in the menu
PRVLIN1:
	LD	DE,(MNUADR)		; point to start of menu
	LD	B,A			; save the counter
;
PRVLIN2:
	LD	A,(DE)
	INC	DE
	CP	'$'
	JR	NZ,PRVLIN2
	DJNZ	PRVLIN2			; keep on till all found
	INC	DE			; points to address byte 2
	INC	DE			; points to start of string
	JP	GETITEM			; get the data now
;
; Here we erase the whole line back to the start.
; b = number of characters in the buffer.
ERASELINE:
	LD	A,(DE)			; get the # character there
	OR	A			; See if none there yet
	JP	Z,NOCHARS		; If none, skip the backspacing
	LD	B,A
EOL2:
	CALL	BACKCHAR
	DJNZ	EOL2
	XOR	A			; get a zero into character count
	LD	(DE),A			; save line length
	JP	NOCHARS
;
; Here we back the cursor up a character so long as there are characters
; to back up in the buffer. If the buffer is empty then we ring the bell.
;
; DE -> characters in the buffer
; HL -> ascii characters in the buffer
;
LFTCHR:
	LD	A,(DE)			; get the character count
	OR	A			; empty ??
	JP	Z,IGNCHR		; ring bell and continue
	DEC	A
	LD	(DE),A			; save the decremented count
	CALL	BACKCHAR		; do the backing up of the cursor
	JP	NOCHARS
;
; Back the cursor up 1 character and write a null to the buffer.
;
BACKCHAR:
	DEC	HL			; back up the memory pointer too
	LD	(HL),00			; clear the buffer byte
; Send now a backspace, underline, backspace
	CALL	INLINE
	DEFB	$1B,$19,$0D,0
	LD	A,8
	CALL	COE
	LD	A,FILCHR		; the fill character
	CALL	COE
	LD	A,08
	CALL	COE
	CALL	INLINE
	DEFB	$1B,$1A,$0D,0
	RET
;
;----------------------------------------------------------------
; This is jumped to when the user enters an ESCAPE to quit the input
; to the data fields.
;----------------------------------------------------------------
;
FINGET:
	CALL	CRSROF
	LD	DE,(MNUADR)
	LD	HL,(HLSAVE)
	LD	BC,(BCSAVE)
	RET
;
;----------------------------------------------------------------
; This large routine must use DE to print the menu item it points
; to and also print the console buffer the menu item points to.
; If the console buffer has an address of 00 then it is ignored.
; On return DE must point to the next menu item or end of menu.
;----------------------------------------------------------------
;
DISPITEM:
	CALL	SETXY			; set up cursor DE-> address
	CALL	PRINT			; print DE-> string
	LD	C,DELIM1
	CALL	BBCONOUT
	LD	A,(CURX)
	INC	A
	LD	(CURX),A		; updated
;
; Now we need to save the current screen address since this is where
; the console buffer is being printed so we need it for later homing to.
	LD	A,(CURX)
	LD	(BUFY),A
	LD	A,(CURY)
	LD	(BUFX),A		; saved
;
; Now load the address of the console buffer string
	EX	DE,HL			; HL -> the address now
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
; Now HL -> next menu string, DE -> console buffer for this string.
; This extensive section of code will print the console buffer or prompt
;
	LD	(CONADR),DE		; save CONSOLE BUFFER address
; See if this menu string has no console buffer
	LD	A,E
	OR	D			; Is D = E = 0 ?
	JR	Z,FINDISP		; put address of menu into de then ret.
	LD	A,(DE)			; get its maximum length
	LD	B,A			; Save as a counter
	INC	DE			; DE -> characters in the buffer
	INC	DE			; DE -> first buffer character
PRINTCONBUF:
	LD	A,(DE)
	INC	DE			; point to next character
	OR	A			; is this character a null ?
	JR	NZ,PCONBUF2
	LD	A,FILCHR		; if it was load a default
PCONBUF2:
	CALL	COE			; print it
	DJNZ	PRINTCONBUF		; print next string
; Restore DE as pointer to the menu then do the next item / buffer
; Note that the address of the console buffer is saved in CONADR.
FINDISP:
	EX	DE,HL			; DE -> next string start
	LD	C,DELIM2
	CALL	BBCONOUT
	RET
;
PRINTMENU:
	CALL	DISPITEM		; display a menu string and data area
	LD	A,(DE)			; get a byte
	CP	0FFH			; end ?
	JR	NZ,PRINTMENU		; if not the keep on till end
	RET
;----------------------------------------------------------------
; Set up the screen address -> by DE stored in memory.
; The address is saved in curx, cury. Note that the offset (32)
; is added to both x and y.
;----------------------------------------------------------------
;
SETXY:
	LD	A,(DE)			; get the X address
	LD	(CURY),A
	INC	DE
	LD	A,(DE)
	LD	(CURX),A
	INC	DE			; DE now -> past end
; X address
	LD	A,(CURY)
	LD	H,A
	LD	A,(CURX)
	LD	L,A
	CALL	SETCUR
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

;----------------------------------------------------------------
; Print the string -> by DE. Return with DE pointing past the
; string end so as to point to the start of the next string.
; NOTE that this routine updates the CURX screen address. This is
; vital for all printing functions.
;----------------------------------------------------------------
;
PRINT:
	LD	A,(DE)
	INC	DE
	OR	A
	RET	Z
	CP	'$'			; END ?
	RET	Z
	CP	0			; END ?
	RET	Z
	CALL	COE
	LD	A,(CURX)
	INC	A
	LD	(CURX),A		; loaded.updated.saved
	JR	PRINT
;;
;; Print but at row,col (first two bytes in string)
;;
PRINTXY:
	CALL	SETXY
	JR	PRINT

;;
;; Inline print at row,col (first two bytes in string)
;;
INLINEXY:
	EX	(SP),HL			; get address of string (ret address)
	PUSH	AF
	PUSH	DE
	EX	DE,HL
	CALL	SETXY
	JR	INLINE2

;;
;; Inline print
;;
INLINE:
	EX	(SP),HL			; get address of string (ret address)
	PUSH	AF
	PUSH	DE
	EX	DE,HL
INLINE2:
; 	LD	A,(DE)
; 	INC	DE			; point to next character
; 	CP	'$'
; 	JR	Z,INLINE3
; 	CP	0
; 	JR	Z,INLINE3
; 	CALL	COE
; 	JR	INLINE2
	CALL	PRINT
INLINE3:
	EX	DE,HL
	POP	DE
	POP	AF
	EX	(SP),HL			; load return address after the '$'
	RET				; back to code immediately after string


; output A to console
COE:
	PUSH	BC
	LD	C,A
	CALL	BBCONOUT
	POP	BC
	RET

;------------------------------------------------------------
; Programming routines
;------------------------------------------------------------

;;
;; Burn table on eeprom
;;
BURNTABLE:
	LD	A,IMTPAG		; eeprom images table page
	LD	(EDESTPAG),A
	LD	HL,RAMTBL		; updated table in ram
	LD	(ESOURCEADR),HL
	LD	HL,IMTSIZ		; table size
	LD	(EIMGSIZE),HL
	LD	HL,0			; clear count buffer
	LD	(CNVBUF),HL
	CALL	EEPROGRAM		; do it ! .... brrrr .....
	RET

;;
;; Burn image on eeprom
;;
BURNIMAGE:
	; here we do the work on 4k page basis
	LD	A,(CURPAG)		; destination (base) page in eeprom
	LD	(EDESTPAG),A
	LD	HL,IMGORG		; image location ($1000)
	LD	(ESOURCEADR),HL
MLTPAGE:
	LD	HL,(CURSIZ)		; image size
	LD	DE,4096
	OR	A			; clear carry
	SBC	HL,DE			; lesser than one page ?
	JR	C,ONEPAGE		; yes
	LD	HL,4096			; no
	JR	DO4K
ONEPAGE:
	LD	HL,(CURSIZ)		; reload image size
DO4K:	LD	(EIMGSIZE),HL

	LD	HL,0			; clear count buffer
	LD	(CNVBUF),HL
	CALL	EEPROGRAM		; write page
	LD	HL,(CURSIZ)		; reload image size
	LD	DE,4096			; page size
	OR	A			; clear carry
	SBC	HL,DE			; subtract to get remaining size
	JR	C,BIMEXI
	JR	Z,BIMEXI
	LD	(CURSIZ),HL		; left bytes
	LD	A,(EDESTPAG)		; write another page...
	INC	A
	LD	(EDESTPAG),A		; next page
	LD	HL,(ESOURCEADR)
	LD	DE,4096
	ADD	HL,DE
	LD	(ESOURCEADR),HL
	JR	MLTPAGE
BIMEXI:
	RET

;------------------------------------------------------------
; Data storage of string addresses and cursor addresses.
;
NXTADR:	DEFB	00,00			; current string address
CONADR:	DEFB	00,00			; address of a console buffer
MNUADR:	DEFB	00,00			; address of a menu string
ITMNUM:	DEFB	00			; menu item number counter
;
BUFX:	DEFB	00			; buffer start screen x value
BUFY:	DEFB	00			; buffer start screen y value
;
CURX:	DEFB	00			; loaded by setxy
CURY:	DEFB	00			; as above
;
HLSAVE:	DEFB	00,00
BCSAVE:	DEFB	00,00			; preserve registers in these
TEMP:	DEFB	00,00			; save cons. character temp.
;
CNVBUF:	DEFS	2			; conversion buffer
CURBLK:	DEFS	1			; working block number
CURPAG:	DEFS	2
CURADR:	DEFS	2
CURSIZ:	DEFS	2
SPREG:	DEFW	0
FLAGFAKE:
	DEFB	0			; fake operations nothing will be saved
FLAGBURN:
	DEFB	0			; burn image
;
EDITMSK:
	DEFB	14,02,"Name ......: $"
	DEFW	INAME
	DEFB	15,02,"EEPROM page: $"
	DEFW	IEADDR
	DEFB	16,02,"IMG addr ..: $"
	DEFW	IIADDR
	DEFB	17,02,"Size ......: $"
	DEFW	ISIZE
	DEFB	18,02,"Description: $"
	DEFW	IDESC
	DEFB	$FF			; end of table

INAME:	DEFB	8,0			; 8 image name
BNAME:	DEFS	8
IEADDR:	DEFB	2,0			; 4 hexadecimal image location in eeprom (4k page bound)
BEADDR:	DEFS	2
IIADDR:	DEFB	4,0			; 4 hexadecimal image ram address
BIADDR:	DEFS	4
ISIZE:	DEFB	4,0			; 4 hexadecimal image size
BSIZE:	DEFS	4
IDESC:	DEFB	20,0			; image description
BDESC:	DEFS	20


EDTCPY:	DEFB	8,0			; editor clear copy
	DEFS	8
	DEFB	2,0
	DEFS	2
	DEFB	4,0
	DEFS	4
	DEFB	4,0
	DEFS	4
	DEFB	20,0
	DEFS	20
EDTSIZ	EQU	$ - EDTCPY

EDTSYS:	DEFB	8,8			; sysbios fixed entry
	DEFB	"SYSBIOS "
	DEFB	2,2
	DEFB	"C0"
	DEFB	4,4
	DEFB	"F000"
	DEFB	4,4
	DEFB	"4000"
	DEFB	20,20
	DEFB	"SYSTEM BIOS/MONITOR "

MSEP:	DEFB	" - ",0
	;
;-------------------------------------
; Needed modules
include modules/eeprom.inc.asm		; eeprom


SYSB3LO:
	DEFS	SYSBIOS3 + $0BFF - SYSB3LO
SYSB3HI:
	DEFB	$00
;;
;; end of code - this will fill with zeroes to the end of
;; the image

;-------------------------------------

IF	MZMAC
WSYM sysbios3.sym
ENDIF
;
;
	END
;
