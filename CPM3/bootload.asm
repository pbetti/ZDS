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
;; 20180224	- lowercased
;;---------------------------------------------------------------------
;;
;;----------------------------------------------------------------------------
;; z80darkstar bootloader for floppies, hard (ide) and virtual disks
;;----------------------------------------------------------------------------
;;
	include	darkstar.equ
	include	syshw.inc

ishd?	macro
	xor	a
	push	hl
	ld	hl,ishdb
	cp	(hl)
	pop	hl
	endm

isvhd?	macro
	xor	a
	push	hl
	ld	hl,isvhd
	cp	(hl)
	pop	hl
	endm

;--------------------

	;; we can't no more support 128 byte sector format...
srefsiz	equ	512			; sector reference size
size	equ	8192			; more then the size of cpmldr

	org 	bldoffs			; code start

	defb	$55,$aa			; loader signature

;       CP/M 3 boot-loader for Z80Darkstar (NEZ80)
;
;       Copyrigth (C) 2005-2014 by Piergiorgio Betti
;
	;
	;       begin the load operation
	;

bootload:
	ld	b,bbpag << 4		; very important:
	ld	c,mmuport		; ensure that sysbios boot page ($bb)
	ld	a,(hmempag)		; is effectively selected, since sysbios
	sub	4			; boot code not always return to base (boot)
	out	(c),a			; page...
	;
	ld      sp,$80			; use space below buffer for stack
	ld	a,(cdisk)		; select...
	ld	c, a			; logged drive
	call	bbdsksel		;
	ld	ix,flsecs		; default floppy
	cp	2			; is floppy ?
	jp	m,blini			; yes
	cp	14			; is ide ?
	jp	m,hdini			; yes
	cp	15			; virtual hd ?
	jr	z,vhd			; yes (p:)
	jr	blini			; no, virtual floppy (o:)


vhd:
	ld	ix,hdsecs		; hd params
	xor	a			; will use as a flag for hd operations
	dec	a
	ld	(isvhd),a
	jr	blini

hdini:
	ld	ix,hdsecs		; hd params
	xor	a			; will use as a flag for hd operations
	dec	a
	ld	(ishdb),a
	;
	;	drive logged, calc sectors to read
	;
blini:	ld	l,(ix+0)		; sec. per track in hl
	ld	h,(ix+1)
	ld	e,(ix+2)		; sec. size in de
	ld	d,(ix+3)
	call	bbdprmset		; setup in sysbios
	push	ix
	ld	bc,size			; cp/m size in bc
	call	bbdiv16			; div cpmsize/secsize
	ld	d,c			; # sectors in d
	inc	d			; pad
	;
	; track, side, start sector
	;
	ld	bc, 0			; start track
	call	bbtrkset
	call	bbsidset		; side 0 select
	ld	iy,tpa			; iy = base offset
	ld      e,1			; start sector
	ishd?
	jr	nz,hdsect		; yes
	isvhd?
	jr	nz,inivh		; yes
	jr	blsect

inivh:
	inc	e			; offset 1 for virtual
	;
	;       load the next sector
	;
hdsect:
	ld	b,0
	ld	c,e
	ld	(fsecbuf),bc		; sector
	ld	(frdpbuf),iy		; dma
	jr	dord

blsect:	call	lsectra			; calc trans sector
	ld	(frdpbuf),iy		; next dma

	; since we are using a banked sysbios, to access the space
	; freed from f000 to fc00 we must ensure cp/m load operation
	; do not overwrite that space during bank switching operated by the
	; bios, to serve our requests...
dord:	ld	hl,(frdpbuf)		; load dma address in hl
	push	hl			; save it
	ld	hl,bmbelow		; temporary dma after us
	ld	(frdpbuf),hl		; set up
	ishd?
	jr	nz,rdide		; read hd sector
	isvhd?
	jr	nz,brdvrt		; read virtual hd sector
	; ------------------------------------------------
	ld	a,(fdrvbuf)		; get active drive
	cp	2			; is real floppy ?
	jp	p,brdvrt		; no
brdflo:	call	bbfdrvsel		; activate driver
	call	bbfread			; do read
	jr	ckerr
brdvrt:	call	bbrdvdsk		; call par. read
	jr	ckerr
rdide:	push	de
	push	iy			; save ptrs
	call	bbhdrd			; call ide read
	pop	iy
	pop	de
ckerr:	or	a
	jr	nz, bootnok

	pop	hl			; recover real dma address
	push	de			; saves de
	ex	de,hl			; dma in de
	ld	hl,bmbelow		; our buffer
	ld	bc,srefsiz		; size
	ldir				; put in right place
	pop	de			; recover our counters

	; go to next sector if load is incomplete
skiprd:	dec     d               	; sects=sects-1
	jp      z,tpa			; head for the cpmldr
	;
	;       more sectors to load
	;
blnxts:	inc     e			; sector = sector + 1
	ishd?
	jr	nz,hddma		; we do not check for end of track since
	isvhd?				; for lba hd this is quit impossible
	jr	nz,hddma		; (128kb tracks.......)
	ld	bc,512			; bump dma address
	add	iy,bc
	ld      a,e
	pop	ix			; recover table address
	push	ix
	cp      (ix+0)			; last sector of track ?
	jr      nz,blsect		; no, go read another
	;
	;       end of track, increment to next track
	;
	ld	bc, (ftrkbuf)		; track = track + 1
	inc	bc
	ld	(ftrkbuf),bc
	ld      e,0			; sector = 0
	jp      blsect			; for another track
bootnok:
	ld	hl, blfailm
	call	prstr
	;
	call	bbconin
 	jp	$fc00			; return to monitor boot menu
prstr:
	ld	c,(hl)
	ld	a,c
	res	7,c
	call	bbconout
	inc	hl
	rlca
	jr	nc,prstr
	ret
hddma:
	ld	bc,512			; bump dma address
	add	iy,bc
	jp	hdsect

	;
	; apply skew factor
	;
lsectra:
	push	hl
	push	bc
	ld	b,0
	ld	c,e			; current sec.
	ld	hl,trans		; hl= trans
	add     hl,bc			; hl= trans(sector)
	ld      l,(hl)			; l = trans(sector)
	ld      h,0			; hl= trans(sector)
	ld	(fsecbuf),hl
	pop	bc
	pop	hl
	ret				; with value in hl
	; sector translation table for 512 bytes/11 sec. track (skew = 4)
trans:	defb	1,5,9,2 		; sectors 1,2,3,4
	defb	6,10,3,7	 	; sectors 5,6,7,8
	defb	11,4,8			; sectors 9,10,11


blfailm:
	defb	cr,lf,"BOOT",'!'+$80
;sectors descs...
flsecs:	defw	11
	defw	512
hdsecs:	defw	256
	defw	512
ishdb:	defb	0
isvhd:	defb	0

	if	($-bootload+1) gt srefsiz
	* bootload too large!! *
	endif

bmbelow:
	defs	1

;----------------------------------------------------------------------------

	end


