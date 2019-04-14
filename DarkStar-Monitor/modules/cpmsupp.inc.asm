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
	extern	bbdprmset, bbtrkset, bbdsksel
	extern	bbfdrvsel, bbfhome, bbdmaset
	extern	bbsecset, bbfread, bbrdvdsk
	extern	bbhdrd, bbhdrd, bbhdinit
	extern	bbldpart

;;
;; CPMBOOT - boostrap cp/m
;
flpboot:
	ld	de,512
	call	bbdprmset
	ld	bc,$00
	call	bbtrkset
	ld	a,(cdisk)		; get logged drive
	ld	c,a
	call	bbdsksel
	call	bbfdrvsel
	call	bbfhome
	ret	nz
	ld	bc,bldoffs		; read in loader
	call	bbdmaset
	ld	bc,$01
	call	bbsecset
	call	bbfread
	ret	nz
	jp	bldoffs+2		; jump to the loader if all ok

;;
;; VCPMBT
;;
;; Boot CP/M from parallel link
;
vcpmbt:
	ld	bc, bldoffs          	; base transfer address
	call	bbdmaset
	ld	a,(cdisk)		; get logged drive
	ld	c, a			; make active
	call	bbdsksel
	ld	bc, 0			; START TRACK
	call	bbtrkset
	ld	bc, 1			; start sector
	call	bbsecset
	ld	de,128
	call	bbdprmset
	call	bbrdvdsk		; perform i/o 128
	or	a
	jr	z,vbgo
	ld	de,256
	call	bbdprmset
	call	bbrdvdsk		; perform i/o 256
	or	a
	jr	z,vbgo
	ld	de,512
	call	bbdprmset
	call	bbrdvdsk		; perform i/o 512
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
	call	bbdsksel
	ld	bc,bldoffs		; read in loader @ BLDOFFS
	call	bbdmaset
	ld	bc,$00
	call	bbtrkset
	ld	bc,$00
	call	bbsecset
	call	bbhdrd
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



;;
;; Handle CP/M type bootstrap
;;
;; A = drive
;;

cpmboot:
	ld	a,(asav)
cpmdboot:
	ld	b,a
	ld	c,02h			; reset input case
	call	bbconout
	ld	a,b
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
	call	bbhdinit
	call	bbldpart		; load partition table
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
	jp	z,bmuzi
	cp	'C'
	jr	z,bmcpm
bminv:
	call	inline
	defb	cr,lf,"Invalid selection",cr,lf,0
	ret

bmcpm:
	call	inline
	defb	cr,lf,"Enter drive (<AB> floppy, <C-N> HD, <OP> virtual): ",0
	ld	c,SI_EDIT
	ld	e,SE_STR
	ld	d,1
	call	bbsysint
	or	a
	jr	nz,bminv
	call	inline
	defb	cr,lf,"Boot..",cr,lf,0
	ld	a,(iedtbuf)
	call	cpmdboot
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
	call	uzidboot
	ret


;----- EOF -----
