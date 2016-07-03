;
;=======================================================================
;
; Modular Z80 DarkStar (NE Z80) Monitor
;
;=======================================================================
;
; CP/M 2 or 3 BIOS support utilities
; ---------------------------------------------------------------------


	;       character and disk i/o handlers for cp/m BIOS
	;	This are moved here from BIOS since we need to keep
	;	space...
;;
;; FDRVSEL - select drive for r/w ops
;
fdrvsel:
	push	af			;
	push	hl			;
	ld	hl,hdrvv		; 10
	ld	a,(fdrvbuf)		; 13
	add	a,l			; 4
	ld	l,a			; 4
	ld	a,(hl)			; 7
	ld	h,a			;
	ld	a, (dselbf)
	and	$f0
	or	h
	ld	(dselbf),a		; 13
	out	(fdcdrvrcnt),a		; 11
	pop	hl			;
	pop	af			;
	ret				;
	;
	; This used to translate the drive number in a cmd byte suitable
	; for drive selection on the floppy board
hdrvv:	defb	$01			; drive 1
	defb	$02			; drive 2
	defb	$04			; drive 3
	defb	$08 			; drive 4

;;
;; CPMBOOT - boostrap cp/m
;
cpmboot:
	ld	de,512
	call	setdprm
	ld	bc,$00
	call	trkset
	ld	a,(cdisk)		; get logged drive
	ld	c,a
	call	dsksel
	call	fdrvsel
	call	fhome
	ret	nz
	ld	bc,bldoffs		; read in loader
	call	dmaset
	ld	bc,$01
	call	secset
	call	fread
	ret	nz
	jp	bldoffs+2		; jump to the loader if all ok

;;
;; VCPMBT
;;
;; Boot CP/M from parallel link
;
vcpmbt:
	ld	bc, bldoffs          	; base transfer address
	call	dmaset
	ld	a,(cdisk)		; get logged drive
	ld	c, a			; make active
	call	dsksel
	ld	bc, 0			; START TRACK
	call	trkset
	ld	bc, 1			; start sector
	call	secset
	ld	de,128
	call	setdprm
	call	vdskrd			; perform i/o 128
	or	a
	ret	z
	ld	de,256
	call	setdprm
	call	vdskrd			; perform i/o 256
	or	a
	ret	z
	ld	de,512
	call	setdprm
	call	vdskrd			; perform i/o 512
	or	a
	ret

;;
;; HDCPM - boostrap cp/m from IDE
;
hdcpm:
	ld	a,(cdisk)		; get logged drive
	ld	c,a
	call	dsksel
	ld	bc,bldoffs		; read in loader @ BLDOFFS
	call	dmaset
	ld	bc,$00
	call	trkset
	ld	bc,$00
	call	secset
	call	readsector
	ld	d,0			; error type (no volume)
	ret	nz
	ld	de,(hdbsig)		; check for a valid bootloader
	ld	hl,(bldoffs)
	or	a
	sbc	hl,de
	ld	d,1			; error type (no bootloader)
	ret	nz			; no bootlader found
	jp	bldoffs+2		; jump to the loader if all ok
	ret

hdbsig:	defb	$55,$aa


trkset:
	ld	(ftrkbuf),bc
	ret
secset:
	ld	(fsecbuf),bc
	ret
dmaset:
	ld	(frdpbuf),bc
	ret
dsksel:
	ld	a,c
	ld	(fdrvbuf),a
	ret

; 	;
; 	;
; 	; RTC handler routine
; 	;
; CPTIME:	LD	A,C			; read or write ?
; 	OR	A
; 	JR	NZ,TIMWRI
; 	PUSH	DE			; save user buffer address
; 	PUSH	IY
; 	POP	HL			; load private storage area
; ; 	CALL	RDTIME
; 	DEC	HL			; HL is at year buffer
; 	POP	DE			; restore user buffer
; 	;
; 	LD	A,7			; 7 byte to fix
; TIMLOA:	LD	C,(HL)
; 	;
; 	CP	6			; offset 6 (local) is day of week...
; 	JR	Z,TIMSY0		; so skip it
; 	;
; 	EX	DE,HL			; swap HL and DE
; 	CP	1			; last (old) byte need to be saved
; 	JR	NZ,TIMNLS		; not the one
; 	LD	B,(HL)			; save in B
; TIMNLS:	LD	(HL),C			; now can load C in (DE)
; 	EX	DE,HL			; reset swap
; 	INC	DE			; advance RTCBUF ptr
; TIMSY0:	DEC	HL			; back one on top of RTCBUF
; 	DEC	A			; all done ?
; 	JR	NZ,TIMLOA		; if no loop
; 	DEC	DE			; exit: put DE at buffer top
; 	EX	DE,HL			; save buffer top in HL
; 	LD	E,B			; put in E old (top) buffer content
; 	XOR	A
; 	INC	A			; all good
; 	RET
; 	;
; TIMWRI:	LD	A,$FF			; unsupported here
; 	RET
; 	RET
