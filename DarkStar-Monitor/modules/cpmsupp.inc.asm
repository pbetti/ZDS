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
	push	af			; save regs
	push	bc
	
	ld	a,(fdrvbuf)		; load drive #
	ld	b,a
	inc 	b			; on b (+1 for loop)
	xor	a
	scf
fdrvs0:
	rla				; rotate to get
	djnz	fdrvs0			; drive id
	
	ld	b,a			; save on b
	ld	a,(dselbf)		; current select
	and	11110000b		; reset current id
	or	b			; and replace with new
	ld	(dselbf),a		; update current
	out	(fdcdrvrcnt),a		; activate selection
	
	pop	bc
	pop	af
	ret

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

