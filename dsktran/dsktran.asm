;
;=======================================================================
;
; DarkStar (NE Z80) Disk Transfer Utility
;
;=======================================================================
;;---------------------------------------------------------------------
;; Version      : 1.0 - 20171119
;; Assemble     : SLR z80asm, myzmac
;; Revisions:
;; 20171119	- Initial revision
;;---------------------------------------------------------------------

title	ZDS Disk Transfer Utility


include ../Common.inc.asm
include ../darkstar.equ

bel	equ	$07
ctlc	equ	'C'-'@'
bs	equ	'H'-'@'
VERSION	equ	10

DBGDMA	equ	false

;--------------------
	org	tpa

begin:	jp	recover

;
;       begin the load operation
;
rsec:	defw	1
rtrk:	defw	0
rsid:	defb	0
rdma:	defw	prgend

wsec:	defw	1
wtrk:	defw	0
wsid:	defb	0
wdma:	defw	prgend

rwerr:	defb	0

	; Disks format vector
dgeotab:
	defb	0,0,0		; tracks, sides, sectors
	defw	512		; sec. size

odrive:	defb	0
ddrive:	defb	0
tsize:	defw	0
dsize:	defw	0
	defw	0
atsize:	defs	12
adsize:	defs	12

useract:
	call	bbconin

usrexit:
	cp	ctlc
	ret	nz
	call	inline
	defb	cr,lf,esc,$04,cr
	defb	esc,$04,cr,"User break.",esc,$03,cr
	defb	" Return to system.",cr,lf,cr,lf,0

	ld	hl,11
	ld	de,512		; restore normal disk param
	call	bbdprmset

	jp	0		; goodbye, cruel world

recover:
	ld	ix, dgeotab	; disk param ptr

	call	inline
	defb	ff
	defb	esc,$06,cr,"ZDS Disk Image Transfer Utility",esc,$05,cr
	defb	cr,lf
	defb	"version ", version/10+'0','.',(version mod 10)+'0',cr,lf
	defb 	cr,lf,cr,lf,cr,lf,0

asktraks:
	call	inline
	defb	"Enter # of traks per side",cr,lf
	defb	" - 1 = 40",cr,lf
	defb	" - 2 = 80",cr,lf
	defb	"--> ",0
asktrk1:
	call	bbconin
	call	usrexit
	cp	'1'
	jr	nz,asktrk2
	call	inline
	defb	esc,esc,cr," 40 Tracks ",esc,$1c,cr,0
	ld	e,40
	ld	(ix+0),e
	jr	asksides
asktrk2:
	cp	'2'
	jr	nz,asktrk1
	call	inline
	defb	esc,esc,cr," 80 Tracks ",esc,$1c,cr,0
	ld	e,80
	ld	(ix+0),e

asksides:
	call	zcrlf
	call	inline
	defb	"Enter disk sides",cr,lf
	defb	" - 1 = SS, Single Side",cr,lf
	defb	" - 2 = DS, Double Side",cr,lf
	defb	"--> ",0
asksid1:
	call	bbconin
	call	usrexit
	cp	'1'
	jr	nz,asksid2
	call	inline
	defb	esc,esc,cr," Single Side ",esc,$1c,cr,0
	ld	e,1
	ld	(ix+1),e
	jr	asksects
asksid2:
	cp	'2'
	jr	nz,asksid1
	call	inline
	defb	esc,esc,cr," Double Side ",esc,$1c,cr,0
	ld	e,2
	ld	(ix+1),e

asksects:
	call	zcrlf
	call	inline
	defb	"Enter # of sectors/size per track",cr,lf
	defb	" - 1 = 17 (sone/edcpm 128)",cr,lf
	defb	" - 2 = 10 (nedos/sone 256)",cr,lf
	defb	" - 3 = 11 (cpm3/zds 512)",cr,lf
	defb	"--> ",0
asksec1:
	call	bbconin
	call	usrexit
	cp	'1'
	jr	nz,asksec2
	call	inline
	defb	esc,esc,cr," 17/128 ",esc,$1c,cr,0
	ld	e,17
	ld	(ix+2),e
; 	jr	asksize
	ld	de,128
	ld	(ix+3),e
	ld	(ix+4),d
	call	bbdprmset
	jr	askconf
asksec2:
	cp	'2'
	jr	nz,asksec3
	call	inline
	defb	esc,esc,cr," 10/256 ",esc,$1c,cr,0
	ld	e,10
	ld	(ix+2),e
; 	jr	asksize
	ld	de,256
	ld	(ix+3),e
	ld	(ix+4),d
	call	bbdprmset
	jr	askconf
asksec3:
	cp	'3'
	jr	nz,asksec1
	call	inline
	defb	esc,esc,cr," 11/512 ",esc,$1c,cr,0
	ld	e,11
	ld	(ix+2),e
	ld	de,512
	ld	(ix+3),e
	ld	(ix+4),d
	call	bbdprmset

; asksize:
; 	call	zcrlf
; 	call	inline
; 	defb	"Enter sector size",cr,lf
; 	defb	" - 1 = 128",cr,lf
; 	defb	" - 2 = 256",cr,lf
; 	defb	" - 3 = 512",cr,lf
; 	defb	"--> ",0
; asksiz1:
; 	call	bbconin
; 	call	usrexit
; 	cp	'1'
; 	jr	nz,asksiz2
; 	call	inline
; 	defb	esc,esc,cr," 128 ",esc,$1c,cr,0
; 	ld	de,128
; 	ld	(ix+3),e
; 	ld	(ix+4),d
; 	jr	askconf
; asksiz2:
; 	cp	'2'
; 	jr	nz,asksiz3
; 	call	inline
; 	defb	esc,esc,cr," 256 ",esc,$1c,cr,0
; 	ld	de,256
; 	ld	(ix+3),e
; 	ld	(ix+4),d
; 	jr	askconf
; asksiz3:
; 	cp	'3'
; 	jr	nz,asksiz1
; 	call	inline
; 	defb	esc,esc,cr," 512 ",esc,$1c,cr,0
; 	ld	de,512
; 	ld	(ix+3),e
; 	ld	(ix+4),d

askconf:
	ld	c,(ix+3)		;
	ld	b,(ix+4)		;
	call	bn2a16			; convert size to decimal
	ld	hl,pdsize		;
	call	pldecs			;
	ld	c,(ix+2)		;
	call	bin2a8			; convert # secs. to decimal
	ld	hl,pdsecs		;
	call	pldecs			;
	ld	c,(ix+0)		;
	call	bin2a8			; convert # tracks to decimal
	ld	hl,pdtrks		;
	call	pldecs			;
	ld	c,(ix+1)		;
	call	bin2a8			; convert # sides to decimal
	ld	hl,pdsids		;
	call	pldecs			;

	call	inline
	defb	cr,lf,lf,"Your disk format is:",cr,lf
pdsize:	defb	"000"
	defb	" bytes, "
pdsecs:	defb	"00"
	defb	" sectors, "
pdtrks:	defb	"00"
	defb	" tracks, "
pdsids:	defb	"0"
	defb	" side(s)"
	defb	cr,lf,cr,lf,"Continue (y/n)? ",0

	call	gchr			;
	call	usrexit
	cp	'Y'			; is 'y' ?
	jr	nz,unconf		; no
	call	inline
	defb	"es",cr,lf,lf,0
	jr	askdrives
unconf:
	call	inline
	defb	bs,"No",cr,lf,lf,0
	jp	asktraks

askdrives:
	call	inline
	defb	"Enter origin drive (A-P): ",0
	call	gchr			;
	call	usrexit
	cp	'A'			; is valid ?
	jp	m,wrongdrv		;
	cp	'P'+1			;
	jp	p,wrongdrv		; no

	sub	'A'			; makes number
	ld	(odrive),a		; store user selection

	call	inline
	defb	cr,lf,"Enter destination drive (A-P): ",0
	call	gchr			;
	call	usrexit
	cp	'A'			; is valid ?
	jp	m,wrongdrv		;
	cp	'P'+1			;
	jp	p,wrongdrv		; no

	sub	'A'			; makes number
	ld	b,a			; is the same ?
	ld	a,(odrive)
	sub	b			; yes
	jr	z,samedrv		; error

	ld	a,b
	ld	(ddrive),a		; store user selection
	jr	recover2		; go on

wrongdrv:
	call	inline
	defb	cr,lf,"Drive selection invalid",cr,lf,lf,0
	jp	askdrives

samedrv:
	call	inline
	defb	cr,lf,"Origin and destination drive cannot be the same",cr,lf,lf,0
	jp	askdrives

recover2:
	call	zcrlf

	ld	d,0			; calc track size
	ld	e,(ix+2)		; #sectors in DE
	ld	c,(ix+3)
	ld	b,(ix+4)		; sec. size in BC
	call	bbmul16
	ld	(tsize),de		; store res.

	ld	b,0			; calc disk size
	ld	c,(ix+0)		; #tracks in BC LSB
	exx				; zero MSB
	ld	bc,0
	ld	de,0
	exx
	call	mul32			; get 1 side size
					; res. in HL',HL

	ld	b,0			; calc disk size
	ld	c,(ix+1)		; #sides in BC
	ex	de,hl			; hl to de LSB
	exx
	ld	bc,0			; zero BC MSB
	ex	de,hl			; hl to de MSB
	exx
	call	mul32			; res. in HL',HL
	ld	(dsize),hl		; store LSB
	exx
	ld	(dsize+2),hl		; store MSB
	exx

	call	inline
	defb	"Track size ",0
	ld	bc,(tsize)		;
	call	bn2a16			; convert size to decimal
	ld	hl,atsize		;
	call	pldecs			;
	ld	de,atsize
	call	print
	call	inline
	defb	" bytes, disk size ",0
	ld	bc,(dsize)		;
	exx
	ld	bc,(dsize+2)
	exx
	call	bn2a32			; convert size to decimal
	ld	hl,adsize		;
	call	pldecs			;
	ld	de,adsize
	call	print
	call	inline
	defb	" bytes.",cr,lf,lf,0

recover3:				; read & write one track
					; at a time
	ld	hl,0
	ld	(rtrk),hl		; init track 0
	inc	hl
	ld	(rsec),hl		; sector 1
	ld	hl,prgend
	ld	(rdma),hl		; dma address
	xor	a
	ld	(rsid),a		; side 0

	ld	a,(odrive)		; select origin drive
	ld	c,a
	call	mseldsk
	call	mhome
readsec:
	ld      bc,(rdma)		; base transfer address
	call	bbdmaset
	ld	bc,(rtrk)		; track
	call	bbtrkset
	ld      bc,(rsec)        	; sector
	call	bbsecset
	ld      bc,(rsid)        	; side
	ld	b,0
	call	sidset

	ld	a,(odrive)		; select origin drive
	ld	c,a
	call	mseldsk
	call	mread		; perform i/o
	or	a		; test for errors
	jr	z, reads2	; ok

	ld	(rwerr),a
	call	fill11		; read error
reads2:
	call	advmsgr
	xor	a
	ld	(rwerr),a
readnsec:
	ld	hl,(rdma)	; next sector dma
	ld	c,(ix+3)	; sec len
	ld	b,(ix+4)
	add	hl,bc		; move dma
	ld	(rdma),hl

	ld	hl,rsec
	inc	(hl)		; to next sector on trk
	ld	hl,(rsec)
	ld	a,l
	ld	e,(ix+2)

	inc	e		; overflow
	cp	e		; eot ?
	jr	z, readnsid	; nxt trk/sid

	jr	readsec		; nxt sec
readnsid:
	ld	hl,rsid
	inc	(hl)		; to next side
	ld	a,(rsid)
	ld	e,(ix+1)

	cp	e		; eos ?
	jr	z, readntrk	; nxt trk

	ld	hl,1
	ld	(rsec),hl	; to begin of track, next side

	jr	readsec
readntrk:
	ld	hl,(rtrk)	; update write routine register
	ld	(wtrk),hl

	call	writetrack	; flush buffer

	ld	hl,rtrk
	inc	(hl)		; to next track
	ld	hl,(rtrk)
	ld	a,l
 	ld	e,(ix+0)
; 	ld	e,5		; ******** DEBUG ******

	cp	e		; eod ?
	jr	z, opdone	; done

	ld	hl,1		; reset sector
	ld	(rsec),hl
	ld	hl,prgend	; reset dma
	ld	(rdma),hl
	xor	a		; reset side
	ld	(rsid),a

	ld	a,(odrive)		; re-select origin drive
	ld	c,a
	call	mseldsk

	jp	readsec

opdone:
	call	inline
	defb	cr,lf,lf,"Job done.",cr,lf
	defb	"Do another disk? (y/n) ",0

	call	gchr			;
	call	usrexit
	cp	'Y'			; is 'y' ?
	jr	nz,opdone2		; no
	call	inline
	defb	"es",cr,lf,lf,0
	jp	asktraks

opdone2:
	call	inline
	defb	bs,"No. Bye.",cr,lf,lf,0

	ld	hl,11
	ld	de,512
	call	bbdprmset

	jp	0

;
; flush (write) current track in memory to disk.
;
writetrack:
	ld	hl,1			; init registers
	ld	(wsec),hl		; sector 1
	ld	hl,prgend
	ld	(wdma),hl		; dma address
	xor	a
	ld	(wsid),a		; side 0

	ld	a,(ddrive)		; select destination drive
	ld	c,a
	call	mseldsk

	ld	hl,(wtrk)		; if on trk0 perform fhome
	ld	a,l
	or	h
	call	z,mhome
writesec:
	ld      bc,(wdma)		; base transfer address
	call	bbdmaset
	ld	bc,(wtrk)		; track
	call	bbtrkset
	ld      bc,(wsec)        	; sector
	call	bbsecset
	ld      bc,(wsid)        	; side
	ld	b,0
	call	sidset

	ld	a,(ddrive)		; select destination drive
	ld	c,a
	call	mseldsk
	call	mwrite		; perform i/o
	or	a		; test for errors
	jr	z, writes2	; ok

 	ld	(rwerr),a	; write error
writes2:
	call	advmsgw
	xor	a
	ld	(rwerr),a
writensec:
	ld	hl,(wdma)	; next sectro dma
	ld	c,(ix+3)	; sec len
	ld	b,(ix+4)
	add	hl,bc		; move dma
	ld	(wdma),hl

	ld	hl,wsec
	inc	(hl)		; to next sector on trk
	ld	hl,(wsec)
	ld	a,l
	ld	e,(ix+2)

	inc	e		; overflow
	cp	e		; eot ?
	jr	z, writensid	; nxt trk/sid

	jr	writesec	; nxt sec
writensid:
	ld	hl,wsid
	inc	(hl)		; to next side
	ld	a,(wsid)
	ld	e,(ix+1)

	cp	e		; eos ?
	ret	z		; write done

	ld	hl,1
	ld	(wsec),hl	; to begin of track, next side

	jr	writesec

;
; Fill bad sector with 11h
;
fill11:
	ld	c,(ix+3)
	ld	b,(ix+4)
	ld	e, $11
	ld	hl,(rdma)
fill111:
	ld	(hl),e
	inc	hl
	dec	bc
	ld	a,b
	or	c
	jr	nz,fill111
	ret

;
; used to blank buffers
;
fillbf:
	ld	(hl),c
	inc	hl
	djnz	fillbf
	ret


;
; update progress status
;
advmsgr:
	ld	iy,rsec
	call	inline
	defb	"Read  ",0
	jr	advmsg
advmsgw:
	ld	iy,wsec
	call	inline
	defb	"Write ",0
advmsg:
	call	bbconst			; user break?
	or	a
	call	nz,useract		; verify

	ld	c,(iy+0)		;
	ld	b,(iy+1)
	call	bin2a8			; convert # secs. to decimal
	ld	hl,advsec		;
	call	pldecs			;
	ld	c,(iy+2)		;
	ld	b,(iy+3)
	call	bin2a8			; convert # tracks to decimal
	ld	hl,advtrk		;
	call	pldecs			;
	ld	c,(iy+4)		;
	call	bin2a8			; convert # sides to decimal
	ld	hl,advsid		;
	call	pldecs			;

	call	inline
	defb	"sector: "
advsec:	defb	"  "
	defb	" track: "
advtrk:	defb	"  "
	defb	" side: "
advsid:	defb	"0"
	defb	0

	ld	a,(rwerr)		; in error?
	or	a
	jr	z,advok			; no

	call	inline
	defb	" - Error: ",0
	call	zbits
	call	zcrlf
	call	cleanmsg
	ret
advok:
	call	inline
if DBGDMA
	defb	"          ",0
	call	dbgbuf
else
	defb	"         ",cr,0
endif
	call	cleanmsg
	ret

cleanmsg:
	ld	c,' '
	ld	b,2
	ld	hl,advsec
	call	fillbf			;
	ld	b,2
	ld	hl,advtrk		;
	call	fillbf			;
	ld	b,1
	ld	hl,advsid		;
	call	fillbf			;
	ret

if DBGDMA

dbgbuf:
	ld	b,10		; 10 bytes
	ld	l,(iy+5)
	ld	h,(iy+6)
dbgb1:
	ld	a,(hl)
	call	h2aj1
	ld	c,$20
	call	bbconout
	inc	hl
	djnz	dbgb1
	call	zcrlf
	ret

h2aj1:	push	af
	rrca
	rrca
	rrca
	rrca
	call	h2aj2
	pop	af
h2aj2:	call	nib2asc
	call	bbconout
	ret

nib2asc:
	and	$0f             ; was 00fde0 e6 0f
	add	a,$90
	daa
	adc	a,$40
	daa
	ld	c,a
	ret

endif

	;
; disk drive select
;
mseldsk:
	call	bbdsksel
	ld	a,c
	cp	'B'+1-'@'		; is real drive?
	ret	p			; no
	call	bbfdrvsel		; yes
	ret

;
; home floppy drive
;
mhome:
	ld	a,c
	cp	'B'+1-'@'		; is real drive?
	ret	p			; no
	call	fhome			; yes
	ret

;
; read sector
;
mread:
	ld	a,(odrive)
	cp	'B'+1-'@'		; is real drive?
	jp	p,mreadv		; no
	call	fread
	ret
mreadv:
	call	bbrdvdsk
	ret

;
; write sector
;
mwrite:
	ld	a,(ddrive)
	cp	'B'+1-'@'		; is real drive?
	jp	p,mwritev		; no
	call	fwrite
	ret
mwritev:
	call	bbwrvdsk
	ret

;
;=======================================================================
;
; Modular Z80 DarkStar (NE Z80) Monitor
;
;=======================================================================
;
; Floppy I/O
; ---------------------------------------------------------------------
; ---------------------------------------------------------------------
; Revisions:
; 20150714 - Changed to have timeouts on floppy operations that could
;            produce system locks. (I.e. in absence of floppy in drive)
; ---------------------------------------------------------------------


rtrycnt		equ	3		; # retry count for errors

;;
;; FDC delay
;
fdcdly:
	ex	(sp),hl
	ex	(sp),hl
	ex	(sp),hl
	ex	(sp),hl
	ex	(sp),hl
	ex	(sp),hl
	ex	(sp),hl
	ex	(sp),hl
	ret

;;
;; waitfd - get 1771 status and copy on buffer
;
waitfd:
	; wait until fdd busy is reset
	call	fdcdly			; wait aproax 56 micros
	ld	b,4			; set soft timer
fwait00:
	ld	de,0			; for ~ five seconds
fwait01:
	in	a,(fdccmdstatr)		; input to fdd status
	bit	0,a			; test busy bit
	ret	z			; exit if no command is in progress
; 	jr	z,fwait02		; jump if no command is in progress
	dec	de			;
	ld	a,d			; timer down
	or	e			;
	jr	nz,fwait01		;
	dec	b			;
	jr	nz,fwait00		; time out
ftimeout:
	ld	a,fdcreset		; reset fdd controller
	out	(fdccmdstatr),a		; exec. command
	xor	a
	out	(fdcdrvrcnt),a
	inc	a			; set time-out bit error
	or	a			; set NZ
	ret				; and ret
;
;;
;; set HL to right track buffer (a or b)
;
gtrkbuf:
	ld	hl,fsekbuf
	ld	a,(fdrvbuf)
	add	a,l
	ld	l,a
	ret
;;
;; FHOME - move head to trak 0 (cp/m home like)
;;
fhome:
	push	bc			; save register
	push	de
	ld	a,fdcrestc		; fdd restore command
	out	(fdccmdstatr),a		; exec. command
	call	waitfd			; wait until end command
	ld	c,a			; save status

	call	gtrkbuf			; proceed
	in	a,(fdctrakreg)
	ld	(hl),a
	ld	a,c			; restore status
	and	00011001b		; set Z flag
	or	a
	pop	de
	pop	bc			; restore register
	ret

;;
;; FSEEK - seek to specific track/sector
;
fseek:
	push	bc
	push	de
	ld	b,rtrycnt		; retrys number
	call	gtrkbuf
	ld	a,(hl)
	out	(fdctrakreg),a
fretr1:
	ld	a,(fsecbuf)
	out	(fdcsectreg),a
	ld	a,(ftrkbuf)
	out	(fdcdatareg),a
	ld	a,fdcseekc		; seek cmd
	out	(fdccmdstatr),a		; exec. command
	ld	c,b			; save retry count
	call	waitfd
	ld	b,c			; restore retry count
	and	00011001b
	jr	z,fskend		; ok

	call	fhome			; seek error
	jr	nz,fskend
	djnz	fretr1			; retry
fskend:
	in	a,(fdctrakreg)
	ld	(hl),a
	pop	de
	pop	bc
	ret
;;
;; FREAD - read a sector
;
fread:
	ld	a,(miobyte)
	set	0,a
	jr	flopio
;;
;; FWRITE - write a sector
;
fwrite:
	ld	a,(miobyte)
	res	0,a
;;
;; FLOPIO - read or write a sector depending on MIOBYTE
;
flopio:
	push	de
	ld	(miobyte),a
	ld	b,rtrycnt		; # retries
frwnxt:
	call	fseek			; go to trk/sec
	jr	nz,fioend

	di				; not interruptible
	ld	hl,(frdpbuf)
	ld	e,(ix+3)		; need to know buffer size on r/w
	ld	d,(ix+4)

	ld	a,(miobyte)
	bit	0,a			; read or write?
	jr	z,frwwro		; go to write

	ld	a,fdcreadc		; read command
	out	(fdccmdstatr),a		; exec. command
	call	fdcdly
	jr	frrdy
frbsy:
	rrca				; busy bit to carry flag
	jr	nc,fwend		; if busy 0 end read
frrdy:
	in	a,(fdccmdstatr)
	bit	1,a			; data request active ?
	jr	z,frbsy			; no: check busy bit

	in	a,(fdcdatareg)		; get data
	ld	(hl),a
	inc	hl
	jr	frrdy
frwwro:
	ld	a,fdcwritc		; write command
	out	(fdccmdstatr),a		; exec. command
	call	fdcdly
	jr	fwrdy
frwbsy:
	rrca				; busy bit to carry flag
	jr	nc,fwend		; if busy 0 end read
fwrdy:
	in	a,(fdccmdstatr)
	bit	1,a
	jr	z,frwbsy
	ld	a,(hl)
	out	(fdcdatareg),a
	inc	hl
	dec	de		; 6 c.
	ld	a,d		; 4 c.
	or	e		; 4 c.
	jr	nz,fwrdy	; 7/12 c.
fwend:
	ei				; end of critical operations
	ld	c,b			; save retry count
	call	waitfd
	ld	b,c			; restore retry count
	and	01011100b		; mask wrt-prtc,rnf,crc,lst-dat error
	jr	z,fioend		; ok

	ld	a,(tmpbyte)		; nok
	bit	6,a			; seek to home in error?
	jr	nz,fiotry		; no

	call	fhome			; yes, do seek
	jr	nz,fioend		; seek error eeek!!
fiotry:
	djnz	frwnxt			; retry if in count
fioend:
	push	af
	xor	a
	out	(fdcdrvrcnt),a		; shut down

	pop	af
	pop	de
	ret

;;
;; SIDSET - set current side bit on DSELBF
;;          selected side on C
;;
sidset:
	ld	hl,dselbf		; loads drive interf. buffer
	ld	a,c			; which side ?
	cp	0			;
	jr	nz,sidone		; side 1
	res	5,(hl)			; side 0
	ret				;
sidone:
	set	5,(hl)			;
	ret






;----------------------------------------------------------------
; Print the string -> by DE. Return with DE pointing past the
; string end so as to point to the start of the next string.
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

;;
;; routines for binary to decimal conversion
;;
;; (c) piergiorgio betti <pbetti@lpconsul.net> - 2006
;;
;; the active part is taken from:
;; david barrow - assembler routines for the z80
;; century communications ltd - isbn 0 7126 0506 1
;;


;;
;; bin2a8 - convert an 8 bit value to ascii
;;
;; input	c = value to be converted
;; output	de = converted string address
;
bin2a8: push	hl
	push	af
	ld	b,0
	ld	(ival16),bc
	ld	hl,ival16
	ld	de,oval16
	ld	a,1			; one byte conversion
	call	lngibd
	ld	de,oval16
	pop	af
	pop	hl
	ret
	;
;;
;; bn2a16 - convert a 16 bit value to ascii
;;
;; input	bc = value to be converted
;; output	de = converted string address
;
bn2a16: push	hl
	push	af
	ld	(ival16),bc
	ld	hl,ival16
	ld	de,oval16
	ld	a,2			; two byte conversion
	call	lngibd
	ld	de,oval16
	pop	af
	pop	hl
	ret
	;
;;
;; bn2a32 - convert a 16 bit value to ascii
;;
;; input	bc  = value to be converted LSB
;;		bc' = value to be converted MSB
;; output	de  = converted string address
;
bn2a32: push	hl
	push	af
	ld	(ival16),bc
	exx
	ld	(ival16+2),bc
	exx
	ld	hl,ival16
	ld	de,oval16
	ld	a,4			; four byte conversion
	call	lngibd
	ld	de,oval16
	pop	af
	pop	hl
	ret
	;
;; generic storage

ival16:	defs	4
oval16:	defs	12

;;
;;
;; lngibd - convert long integer of given precision to ascii
;;
;; input	hl addresses the first byte of the binary value
;;		which must be stored with the low order byte in
;;		lowest memory.
;;		de addresses the first byte of the destination
;;		area which must be larger enough to accept the
;;		decimal result (2.42 * binary lenght + 1).
;;		a = binary byte lenght (1 to 255)

;;
cvbase	equ	10		; conversion base
vptr	equ	hilo		; storage area equ


hilo:	defs	2		; storage area

lngibd:	ld	c,a
	ld	b,0
	dec	hl
	ld	(vptr),hl
	ld	a,-1
	ld	(de),a
	add	hl,bc
	;
nxtmsb:	ld	a,(hl)
	or	a
	jp	nz,msbfnd
	dec	hl
	dec	c
	jp	nz,nxtmsb
	;
	ex	de,hl
	ld	(hl),'0'
	inc	hl
	ld	(hl),0
	ret
	;
msbfnd:	ld	b,a
	ld	a,$80
	;
nxtmsk:	cp	b
	jp	c,mskfnd
	jp	z,mskfnd
	rrca
	jp	nxtmsk
	;
mskfnd:	ld	b,a
	push	bc
	ld	hl,(vptr)
	ld	b,0
	add	hl,bc
	and	(hl)
	add	a,$ff
	ld	l,e
	ld	h,d
	;
nxtopv:	ld	a,(hl)
	inc	a
	jp	z,opvdon
	dec	a
	adc	a,a
	;
	cp	cvbase
	jp	c,nocoul
	sub	cvbase
nocoul:	ccf
	;
	ld	(hl),a
	inc	hl
	jp	nxtopv
	;
opvdon:	jp	nc,extdon
	ld	(hl),1
	inc	hl
	ld	(hl),-1
	;
extdon:	pop	bc
	ld	a,b
	rrca
	jp	nc,mskfnd
	dec	c
	jp	nz,mskfnd
	;
	; reverse digit order. add ascii digits hi-nibbles
	ld	(hl),0
	;
nxtcnv:	dec	hl
	ld	a,l
	sub	e
	ld	a,h
	sbc	a,d
	ret	c
	;
	ld	a,(de)
	or	$30
	ld	b,a
	ld	a,(hl)
	or	$30
	ld	(hl),b
	ld	(de),a
	;
	inc	de
	jp	nxtcnv

	;
	; this copy a decimal converted string in area
	; pointed by hl
pldecs:
	ex	de,hl			; load hl on de
	ld	hl,oval16		; result of conversion
pldnxt:	ld	a,(hl)			; pick char pointed by hl
	or	a			; is the terminating nul ?
	ret	z			; yes
	ld	(de),a			; digit copy
	ld	(hl),0			; leave digit clean
	inc	hl			; next locations
	inc	de			;
	jp	pldnxt			;

	; new line sequence
zcrlf:
	ld	c,cr			;
	call	bbconout		; send cr
	ld	c,lf			;
	call	bbconout		; send lf
	ret

	;display bit pattern in [a]
	;
zbits:	push	af
	push	bc
	push	de
	ld	e,a
	ld	b,8
bq2:	sla	e
	ld	a,18h
	adc	a,a
	ld	c,a
	call	bbconout
	djnz	bq2
	pop	de
	pop	bc
	pop	af
	ret

	; get user input
gchr:
	call	bbconin			; take from console
	and	$7f			;
	cp	$60			;
	jp	m,gcdsp			; verify alpha
	cp	$7b			;
	jp	p,gcdsp			;
	res	5,a			; convert to uppercase
gcdsp:	push	bc			;
	ld	c,a			;
	call	bbconout		;
	ld	a,c			;
	pop	bc			;
	ret				;

;==================================================
; multiply routine 32*32bit=32bit
; h'l'hl = b'c'bc * d'e'de
; needs register a, changes flags
;
mul32:
        and     a               ; reset carry flag
        sbc     hl,hl           ; lower result = 0
        exx
        sbc     hl,hl           ; higher result = 0
        ld      a,b             ; mpr is ac'bc
        ld      b,32            ; initialize loop counter
mul32loop:
        sra     a               ; right shift mpr
        rr      c
        exx
        rr      b
        rr      c               ; lowest bit into carry
        jr      nc,mul32noadd
        add     hl,de           ; result += mpd
        exx
        adc     hl,de
        exx
mul32noadd:
        sla     e               ; left shift mpd
        rl      d
        exx
        rl      e
        rl      d
        djnz    mul32loop
        exx

; result in h'l'hl
        ret


;-----------------------------------------------

prgend	equ	$

	end
