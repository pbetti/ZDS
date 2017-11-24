;
;=======================================================================
;
; DarkStar sysdebg loader
;
;=======================================================================
;;---------------------------------------------------------------------
;; Version      : 1.0 - 20171123
;; Assemble     : SLR z80asm, myzmac
;; Revisions:
;; 20171119	- Initial revision
;;---------------------------------------------------------------------

	title	sysdbg loader


include ../../Common.inc.asm
include ../../darkstar.equ


DBSIZE	equ	12288		; 12288
DBSTART	equ	imgarea		; eprom image
DBDEST	equ	09000h		; where to place
EPSIZE	equ	4096		; 12288
EPSTART	equ	imgarea+DBSIZE	; eprom image
EPDEST	equ	0f000h		; where to place


		org 0100h

begin:
	call	inline
	defb	"Will load NE eprom LX390 4k dual boot version",cr,lf
	defb	"by Elettro Design.",cr,lf,cr,lf
	defb	"Sysdbg included and available at 9000h.",cr,lf,cr,lf
	defb	"Proceed? (y/n) ",0

	call	bbconin		; ok to go?
	cp	'y'
	jr	z,reloc
	cp	'Y'
	jr	z,reloc

	call	inline
	defb	cr,lf,"Ok. Exiting...",cr,lf,0

	jp	0		; return to prompt


reloc:
	di			; disable interrupts and system CTC
	call	bbresctc
	ld	hl,tmpbyte
	res	5,(hl)		; flag interrupts off

	ld	bc,DBSIZE	; move sysdbg8
	ld	de,DBDEST
	ld	hl,DBSTART
	ldir
	ld	bc,EPSIZE	; move eprom img
	ld	de,EPDEST
	ld	hl,EPSTART
	ldir

	jp	EPDEST



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
	jr	print

;;
;; Inline print
;;
inline:
	ex	(sp),hl			; get address of string (ret address)
	push	af
	push	de
	ex	de,hl
inline2:
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

; From here start the eprom image
imgarea	equ $
