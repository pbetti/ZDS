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
;; 20180826	- Removed debug code
;;		- lowecased
;;---------------------------------------------------------------------

	TITLE	'BOOT LOADER MODULE FOR CP/M 3.1'

	.Z80

	; define logical values:
	include	common.inc
	include	syshw.inc

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
	if banked
	dseg				; init done from banked memory
	else
	cseg				; init to be done from common memory
	endif

bdos	equ	5			; bdos entry point
ccpbnk	equ	8

	;; ?init
	;; hardware initialization other than character and disk i/o:
?init:
	; assign console input and output to crtc:
	ld	hl,1000000000000000b	; assign console to crtc:
	ld	(@civec),hl
	ld	(@covec),hl
	ld	hl,0100000000000000b	; assign auxiliary to uart0:
	ld	(@aivec),hl
	ld	(@aovec),hl
	ld	hl,0001000000000000b	; assign printer to lpt:
	ld	(@lovec),hl

	ld	a,'3'
	ld	(copsys),a		; identify opsys for partitions

	ld	a,(cdisk)
	inc	a
	ld	(bootdrive),a		; remember boot drive

	push	iy
	call	bbhdinit		; ide init
	or	a
	jr	nz,ideerr
	call	bbldpart
	pop	iy

	; print the sign-on message:
	ld	hl,signonmsg		; point to it
	jp	?pmsg			; and print it

ideerr:
	ld	hl,idemsg		; report the error
	jp	?pmsg
	;

	if banked
	cseg
	endif

	;; ?ldccp
	;; this routine is entered to load the ccp.com file into the tpa bank
	;; at system cold start:
?ldccp:
	; set up the fcb for the file operation:
	xor	a			; zero extent
	ld	(ccpfcb+15),a
	ld	a,(bootdrive)
	ld	(ccpfcb),a		; set drive
	ld	hl,0			; start at beginning of file
	ld	(fcbnr),hl

	; try to open the ccp.com file:
	ld	de,ccpfcb		; point to fcb
	call	lopen			; attempt the open operation
	inc	a			; was it on the disk ?
	jr	nz,ccpfound		; yes -- go load it

	; we arrive here when ccp.com file wasn't found:
	ld	hl,ccpmsg		; report the error
	call	?pmsg
	call	?conin			; get a response
	jr	?ldccp			; and try again

	; file was opened ok -- read it in:
ccpfound:
	ld	de,0100h		; load at bottom of tpa
	call	lsetdma			; by setting the next dma address
	ld	de,128			; set multi sector i/o count
	call	lsetmulti		; to allow up to 16k bytes in one operation
	ld	de,ccpfcb		; point to the fcb
	call	lread			; and read the ccp in
	cp	1			; error 1 is ok, since we read until eof
	jr	z,postload
	or	a			; 0
	jr	z,postload

	ld	hl,lderrm
	call	?pmsg
	call	?pderr
	call	bbconin
	jp	$fc00			; reboot system

postload:

	; following code for banked systems -- moves ccp image to bank 2
	; for later reloading at warm starts:
	if	banked

	ld	hl,0100h		; get ccp image from start of tpa
	ld	b,25			; transfer 25 logical sectors
	ld	a,(@cbnk)		; get current bank
	push	af			; and save it
ld1:
	push	bc			; save sector count
	ld	a,1			; select tpa bank
	call	?bnksl
	ld	bc,128			; transfer 128 bytes to temporary buffer
	ld	de,bankbf		; temporary buffer addr in [de]
	push	hl			; save source address
	push	de			; and destination
	push	bc			; and count
	ldir				; block move sector to temporary buffer
	ld	a,ccpbnk		; select bank to save ccp in
	call	?bnksl
	pop	bc			; get back count
	pop	hl			; last destination will be new source addr
	pop	de			; last source will be new destination
	ldir				; block move sector from buffer to alternate
	; bank
	ex	de,hl			; next addr will be new source addr
	pop	bc			; get back sector count
	djnz	ld1			; drop sector count and loop till done...
	pop	af			; when done -- restore original bank
	jp	?bnksl

	else

	; if non-banked we return through here:
	ret

	endif


	;; ?rlccp
	;; routine reloads ccp image from bank 2 if banked system or from the
	;; disk if non-banked version:
?rlccp:
	if	banked
	; following code for banked version:
	ld	hl,0100h		; get ccp image from start of alternate buffer
	ld	b,25			; transfer 25 logical sectors
	ld	a,(@cbnk)		; get current bank
	push	af			; and save it
rl1:
	push	bc			; save sector count
	ld	a,ccpbnk		; select alternate bank
	call	?bnksl
	ld	bc,128			; transfer 128 bytes to temporary buffer
	ld	de,bankbf		; temporary buffer addr in [de]
	push	hl			; save source address
	push	de			; and destination
	push	bc			; and count
	ldir				; block move sector to temporary buffer
	ld	a,1			; put ccp to tpa bank
	call	?bnksl
	pop	bc			; get back count
	pop	hl			; last destination will be new source addr
	pop	de			; last source will be new destination
	ldir				; block move sector from buffer to tpa bank
	ex	de,hl			; next addr will be new source addr
	pop	bc			; get back sector count
	djnz	rl1			; drop sector count and loop till done...
	pop	af			; get back last current bank #
	jp	?bnksl			; select it and return

	else
	; following code is for non-banked versions:
	jp	?ldccp			; just do load as though cold boot

	endif

;
	if	banked
	cseg
	endif

	; cp/m bdos function interfaces

	; open file:
lopen:
	ld	c,15
	jp	bdos		; open file control block

	; set dma address:
lsetdma:
	ld	c,26
	jp	bdos		; set data transfer address

	; set multi sector i/o count:
lsetmulti:
	ld	c,44
	jp	bdos		; set record count

	; read file record:
lread:
	ld	c,20
	jp	bdos		; read records

	; ccp not found error message:
ccpmsg:
	defb	cr,lf,"BIOS ERR: NO CCP.COM FILE",0
	; ide init error
idemsg:
	defb	cr,lf,"IDE HD INIT ERROR.",0
	; load error
lderrm:
	defb	cr,lf,"LOAD ERROR. REBOOTING",0

bootdrive:
	db	0

	; fcb for ccp.com file loading:
ccpfcb:
	defb	1			; auto-select drive a
	defb	"CCP     COM"		; file name and type
	defb	0,0,0,0
	defs	16
fcbnr:	defb	0,0,0,0
;
;
	if	banked
	cseg
	endif


	; system sign-on message:
signonmsg:
	defb	cr,lf,cr,lf,"Z80 CP/M version 3.1 (Piergiorgio Betti 06/09/2014)"
	if not banked
	defb	cr,lf,"Non banked version."
	else
	defb	cr,lf,"Banked version."
	endif
	if zpm3
	defb	cr,lf,"+ ZPM3 r.10 2/1/93 by Simeon Cran"
	else
	defb	cr,lf,"+ CP/M 3 Plus standard BDOS"
	endif
	defb	cr,lf,0


	end

