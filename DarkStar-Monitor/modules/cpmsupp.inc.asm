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

	extern	bbhdinit, bbldpart, bbsysint
	extern	bbuziboot, bbconin, bbconout

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
flpboot:
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
	jr	z,vbgo
	ld	de,256
	call	setdprm
	call	vdskrd			; perform i/o 256
	or	a
	jr	z,vbgo
	ld	de,512
	call	setdprm
	call	vdskrd			; perform i/o 512
	or	a
	jr	z,vbgo
	ret				; bad
vbgo:
	jp	bldoffs+2		; jump to the loader if all ok

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

;;
;; Handle CP/M type bootstrap
;;
;; A = drive
;;

cpmboot:
	push	af
	ld	c,02h			; reset input case
	call	bbconout
	pop	af

	cp	'A'			; is  a valid drive ?
	jp	m,drvidw		; no < A
	cp	'Q'
	jp	p,drvidw		; no > P

	sub	'A'			; makes a number
	ld	(fdrvbuf),a		; is valid: store in monitor buffer
	ld	(cdisk),a		; and in CP/M buf

	cp	'C'-'A'			; is floppy ?
	jp	m,doflp			; yes

	cp	'O'-'A'			; is hard disk ?
	jp	m,dohd			; yes
;
	call	vcpmbt			; then virtual
	jr	blerr

doflp:
	call	flpboot
	jr	blerr
dohd:
	call	hdcpm
	ld	a,d
	or	a
	jr	nz,noblder
	jr	volerr
blerr:
	call	inline
	defb	cr,lf,"Boot error!",cr,lf,0
	ret

noblder:
	call	inline
	defb	cr,lf,"No bootloader!",cr,lf,0
	ret

volerr:
	call	inline
	defb	cr,lf,"No Volume!",cr,lf,0
	ret

drvidw:
	call	inline
	defb	cr,lf,"Wrong drive ID!",cr,lf,0
	ret

;;
;; Handle manual bootstrap
;;
booter:
	call	hdinit
	call	getptable		; load partition table
	call	inline
	defb	01h,"CP/M or UZI boot (C/U) ? ",0
	ld	c,SI_EDIT
	ld	e,SE_STR
	ld	d,1
	call	bbsysint
	or	a
	ret	nz
	ld	a,(iedtbuf)
	cp	'U'
	jr	z,bmuzi
	cp	'C'
	jr	z,bmcpm
bminv:
	call	inline
	defb	cr,lf,"Invalid selection",cr,lf,0
	ret

bmcpm:
	call	inline
	defb	cr,lf,"Enter drive (<A-B> floppy, <C-N> HD, <O-P> virtual): ",0
	ld	c,SI_EDIT
	ld	e,SE_STR
	ld	d,1
	call	bbsysint
	or	a
	jr	nz,bminv
	call	inline
	defb	cr,lf,"Boot..",cr,lf,0
	ld	a,(iedtbuf)
	call	cpmboot
	ret

bmuzi:
	call	inline
	defb	cr,lf,"Enter partition number:",0
	ld	c,SI_EDIT
	ld	e,SE_DEC
	ld	d,2
	call	bbsysint
	or	a
	jp	nz,bminv
	call	uziboot
	ret


;----- EOF -----
