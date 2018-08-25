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
;; 20180825	- removed debug code
;;		- lowecased
;;---------------------------------------------------------------------


	TITLE	'CPMLDR BIOS FOR CP/M 3.1'

	.z80

	; define logical values:
	include	common.inc
	include syshw.inc




dph 	macro 	?trans,?dpb,?csize,?asize
	local ?csv,?alv
	dw	?trans			; translate table address
	db	0,0,0,0,0,0,0,0,0	; bdos scratch area
	db	0			; media flag
	dw	?dpb			; disk parameter block
	dw	csv			; checksum vector
	dw	alv			; allocation vector
	dw	dirbcb			; directory buffer control block
	dw	databcb			; data buffer control block
	dw	0ffffh			; no hashing
	db	0			; hash bank
	endm

	; standard entry points

	jp	boot
	jp	wboot
	jp	const
	jp	conin
	jp	conout
	jp	blist
	jp	auxout
	jp	auxin
	jp	home
	jp	seldsk
	jp	settrk
	jp	setsec
	jp	setdma
	jp	read
	jp	write
	jp	listst
	jp	sectrn
	jp	conost
	jp	auxist
	jp	auxost
	jp	devtbl
	jp	?cinit
	jp	getdrv
	jp	multio
	jp	flush
	jp	?move
	jp	?time
	jp	bnksel
	jp	setbnk
	jp	?xmove
	jp	0
	jp	0
	jp	0


; 	; extended disk parameter header for drive 0:
	defw	fddwr			; floppy disk write routine
	defw	fddrd			; floppy disk read routine
	defw	void			; floppy disk login procedure
	defw	void			; floppy disk drive initialization routine (void)
	defb	0			; relative drive 0 on this controller
	defb	0			; media type

dph0:	dph	trans,fdpb,0,0

	; extended disk parameter header for drive 2:
	defw	idewrdsk		; hard disk write routine
	defw	iderddsk		; hard disk read routine
	defw	void			; hard disk login procedure
	defw	void			; hard disk drive initialization routine (void)
	defb	0			; relative drive 0 on this controller
	defb	0			; media type

dph2:	dph	0,hd8m,0,0

; 	; extended disk parameter header for drive 14:
	defw	fddwr			; virt floppy disk write routine
	defw	fddrd			; virt floppy disk read routine
	defw	void			; virt floppy disk login procedure
	defw	void			; virt floppy disk drive initialization routine (void)
	defb	0			; relative drive 0 on this controller
	defb	0			; media type

dph14:	dph	trans,fdpb,0,0

; extended disk parameter header for drive 15:
	defw	hwrvdsk			; virt hard disk write routine
	defw	hrdvdsk			; virt hard disk read routine
	defw	void			; virt hard disk login procedure
	defw	void			; virt hard disk drive initialization routine (void)
	defb	0			; relative drive 0 on this controller
	defb	0			; media type

dph15:	dph	0,hd8m,0,0

	; floppy drive 0

fdpb:
	defw	44			; spt
	defb	4,15			; bsh, blm  --> 2048 bytes block
	defb	0			; exm
	defw	433			; dsm
	defw	255			; drm
	defb	11110000b		; alloc 0
	defb	00000000b		; alloc 1
	;
	defw	64			; cks
	;
	defw	2			; off
	defb	2,3			; psh, phm  --> 512 bytes physical sector

	; ide partition 1 is 512x256x64 lba or 8.388.608 bytes
	; dpb	512,256,64,2048,1024,1,8000h

hd8m:
	defw	1024			; spt
	defb	4,15			; bsh, blm  --> 2048 bytes block
	defb	0			; exm
	defw	4031			; dsm
	defw	1023			; drm
	defb	0ffh,0ffh		; al0, al1
	;
	defw	8000h			; cks
	;
	defw	1			; off
	defb	2,3			; psh, phm  --> 512 bytes physical sector

	; sector translation table for 512 bytes/11 sec. track (skew = 4)
trans:	defb	1,5,9,2 		; sectors 1,2,3,4
	defb	6,10,3,7	 	; sectors 5,6,7,8
	defb	11,4,8			; sectors 9,10,11

@dtbl:	defw	dph0	; a:
	defw	dph0	; b:
	defw	dph2	; c:
	defw	dph2	; d:
	defw	dph2	; e:
	defw	dph2	; f:
	defw	dph2	; g:
	defw	dph2	; h:
	defw	dph2	; i:
	defw	dph2	; j:
	defw	dph2	; k:
	defw	dph2	; l:
	defw	dph2	; m:
	defw	dph2	; n:
	defw	dph14	; o:
	defw	dph15	; p:


const:
listst:
auxist:
auxost:
flush:
blist:
auxout:
devtbl:
?cinit:
multio:
?time:
bnksel:
setbnk:
?xmove:
dcbinit:
write:
wboot:
	xor	a			; routine has no function in loader bios:
	ret				; return a false status


conin:
auxin:
	ld	a,'z'-40h		; routine has no function in loader bios:
	ret

conout:					; routine outputs a character in [c] to the console:
	jp	bbconout

conost:					; return console output status:
	jp	bbconst

?move:
	ex	de,hl
	ldir
	ex	de,hl
	ret

seldsk:
	ld	a,(cdisk)
	ld	c,a
	ld	b,0
	call	bbdsksel
	ld	l,a
	ld	h,0
	add	hl,hl			; create index from drive code
	ld	bc,@dtbl
	add	hl,bc			; get pointer to dispatch table
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a			; point at disk descriptor
	ret

home:
	ld	bc,0			; home selected drive -- treat as settrk(0):

settrk:
	ld	(@trk),bc
	call	bbtrkset
	ret

setsec:
	ld	a,(fdrvbuf)		; select...
	cp	2			; is floppy ?
	jp	m,secin			; yes
	cp	14			; is ide ?
	jp	m,secin			; yes
	cp	15			; virtual hd ?
	jr	z,secadj		; yes (p:)
	jr	secin			; no, virtual floppy (o:)

secadj:	inc	bc			; virtual drive
secin:	ld	(@sect),bc
	call	bbsecset
	ret

setdma:
	ld	(@dma),bc
	call	bbdmaset
	ret


sectrn:
	ld	l,c
	ld	h,b
	ld	a,d
	or	e
	ret	z
	ex	de,hl
	add	hl,bc
	ld	l,(hl)
	ld	h,0
	ret

getdrv:
	ld	hl,@dtbl		; return address of disk drive table:
	ret

;--------------------------------------------------------------------------
;                                  BOOT
;                   ROUTINE DOES COLD BOOT INITIALIZATION:
;--------------------------------------------------------------------------


boot:

	ld	a,'3'
	ld	(copsys),a		; ostype for sysbios

	call	bbhdinit		; ide init
	or	a
	jr	nz,ideerr
	call	bbldpart
	ret				; ret z if no problem


ideerr:	ld	hl,mfail		; initialization of ide drive failed
	call	pstring
	call	bbconin
	jp	$fc00			; re-init system monitor

;------------------------------------------------------------------------------
;	   read a sector at @trk, @sec to address at @dma, from cdisk
;------------------------------------------------------------------------------

dread:
	ld	hl,(fdrvbuf)
	ld	h,0
	add	hl,hl			; get drive code and double it
	ld	de,@dtbl
	add	hl,de			; make address of table entry
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a 			; fetch table entry
	push	hl			; save address of table
	ld	de,-8
	add	hl,de			; point to read routine address
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a			; get address of routine
	pop	de			; recover address of table
	dec	de
	dec	de			; point to relative drive
	ld	a,(de)
	inc	de
	inc	de			; point to dph again
	jp	(hl)			; leap to driver

read:
	call	dread
	xor	a
; 	ret

void:					; void routine
	ret

	; wrapper for virtual hd read routine
hrdvdsk:
	push	ix
	push	iy
	ld	hl,(hdsecs)
	ld	de,(hdsecs+2)
	call	bbdprmset
	call	bbrdvdsk
	pop	iy
	pop	ix

	; wrapper for virtual hd write routine
hwrvdsk:
	ret

	; wrapper for ide hd read routine
iderddsk:
	push	iy
	call	bbhdrd
	pop	iy
	or	a
	ret	z
	ld	a,1			; correct return value for bdos
; 	ret

	; wrapper for ide hd write routine
idewrdsk:
	ret

	; floppy read routine
fddrd:
	push	ix
	ld	hl,(flsecs)
	ld	de,(flsecs+2)
	call	bbdprmset
	ld	a,(fdrvbuf)		; get active drive
	cp	2			; is hw floppy ?
	jr	c,rdflo			; yes
	jr	rdvrt			; no, then is a virtual drive
	;
rdflo:	call	chksid			; side select
	call	bbfdrvsel		; activate driver
	call	bbfread			; do read
	pop	ix
	jr	flret
	;
rdvrt:	call	bbrdvdsk		; call par. read
	bit	0,a			; adjust z flag for error test
	pop	ix
	jr	flret

	; floppy write routine
fddwr:
	jr	flok

	; adjust return value for floppies
flret:	jr	z,flok
	xor	a
	inc	a
	ret
flok:	xor	a
	ret

	;	test for side switch on floppies
	;
chksid:	ld	ix,flsecs		; chs infos
	ld	c,0			; side 0 by default
	ld	a,(ftrkbuf)		; get just the 8 bit part because we don't
					; have drivers with more than 255 tracks !!!
	cp	(ix+5)			; compare with physical (8 bit)
	jp	c,bbsidset		; track in range (0-39/0-79) ?
	ld	c,1			; no: side one
	sub	(ix+5)			; real cylinder on side 1
	ld	(ftrkbuf),a		; store for i/o ops
	jp	bbsidset		; ... and go to setsid

; print a string in [hl] up to '$'
pstring:
	ld	a,(hl)
	cp	'$'
	ret	z
	ld	c,a
	call	bbconout
	inc	hl
	jp	pstring

;-----------------------------------------------------------------------

mfail:
	defb	cr,lf,"Initilization of IDE Drive Failed.",cr,lf
	defb	"Press a key to continue.",cr,lf,'$'

@trk:	defs	2			; 2 bytes for next track to read or write
@dma:	defs	2			; 2 bytes for next dma address
@sect:	defs	2			; 2 bytes for sector
flsecs:	defw	11
	defw	512
	defb	2			; heads
	defw	80			; tracks
hdsecs:	defw	256
	defw	512




	; directory buffer control block:
dirbcb:
	defb	0ffh			; drive 0
	defs	3
	defs	1
	defs	1
	defs	2
	defs	2
	defw	dirbuf			; pointer to directory buffer

	; data buffer control block:
databcb:
	defb	0ffh			; drive 0
	defs	3
	defs	1
	defs	1
	defs	2
	defs	2
	defw	databuf			; pointer to data buffer

	; directory buffer
dirbuf:	defs	512

	; data buffer:
databuf:defs	512

	; drive allocation vector:
alv:	defs	1000			; space for double bit allocation vectors

csv:					; no checksum vector required for a hdisk
	defs	(1023/4)+1

	end

