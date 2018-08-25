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
;; 20140904	- Code start
;; 20180819	- Lowercased
;;		  Removed debug code
;; 20180024	- Added embedded debugger (see WITHDBG)
;;---------------------------------------------------------------------

TITLE	'ROOT MODULE OF RELOCATABLE BIOS FOR CP/M 3.1'


	.Z80

	; define logical values:
	include	common.inc
	include syshw.inc

	; this enable embedded debugger if true
WITHDBG	equ	false

;		  Copyright (C), 1982
;		 Digital Research, Inc
;		     P.O. Box 579
;		Pacific Grove, CA  93950

;   This is the invariant portion of the modular BIOS and is
;	distributed as source for informational purposes only.
;	All desired modifications should be performed by
;	adding or changing externally defined modules.
;	This allows producing "standard" I/O modules that
;	can be combined to support a particular system
;	configuration.
;
;   Modified for faster character I/O by Udo Munk

bell	equ	7
ctlq	equ	'q'-'@'
ctls	equ	's'-'@'

ccp	equ	0100h				; console command processor gets loaded
						; into the tpa

	cseg					; gencpm puts cseg stuff in common memory

	; variables in system data page

	extrn	@covec,@civec,@aovec		; i/o redirection vectors
	extrn	@aivec,@lovec
	extrn	@mxtpa				; addr of system entry point
	extrn	@bnkbf				; 128 byte scratch buffer

	; initialization

	extrn	?init				; general initialization
	extrn	?ldccp,?rlccp			; load & reload ccp for boot & wboot

	; user defined character i/o routines

	extrn	?ci,?co,?cist,?cost		; each take device in <b>
	extrn	?cinit				; (re)initialize device in <c>
	extrn	@ctbl				; physical character device table

	; disk communication data items

	extrn	@dtbl				; table of pointers to xdphs
	public	@adrv,@rdrv,@trk,@sect		; parameters for disk i/o
	public	@dma,@dbnk,@cnt			;    ''       ''   ''  ''

	; memory control

	public	@cbnk				; current bank
	extrn	?xmove,?move			; select move bank, and block move
	extrn	?bank				; select cpu bank

	; clock support

	extrn	macclk				; signal time operation

	; general utility routines

	public	?pmsg,?pdec			; print message, print number from 0 to 65535
	public	?pderr				; print bios disk error message header

	include	modebaud.inc			; define mode bits

	; external names for bios entry points

	public	?boot,?wboot,?const,?conin,?cono,?list,?auxo,?auxi
	public	?home,?sldsk,?sttrk,?stsec,?stdma,?read,?write
	public	?lists,?sctrn
	public	?conos,?auxis,?auxos,?dvtbl,?devin,?drtbl
	public	?mltio,?flush,?mov,?tim,?bnksl,?stbnk,?xmov

	public	@bios$stack
	if WITHDBG
	public	embdbg
	endif

	; BIOS Jump vector.

	; All BIOS routines are invoked by calling these
	; entry points.

?boot:	jp	boot			; initial entry on cold start
?wboot:	jp	wboot			; reentry on program exit, warm start

?const:	jp	const			; return console input status
?conin:	jp	conin			; return console input character
?cono:	jp	conout			; send console output character
?list:	jp	blist			; send list output character
?auxo:	jp	auxout			; send auxiliary output character
?auxi:	jp	auxin			; return auxiliary input character

?home:	jp	home			; set disks to logical home
?sldsk:	jp	seldsk			; select disk drive, return disk parameter info
?sttrk:	jp	settrk			; set disk track
?stsec:	jp	setsec			; set disk sector
?stdma:	jp	setdma			; set disk i/o memory address
?read:	jp	read			; read physical block(s)
?write:	jp	write			; write physical block(s)

?lists:	jp	listst			; return list device status
?sctrn:	jp	sectrn			; translate logical to physical sector

?conos:	jp	conost			; return console output status
?auxis:	jp	auxist			; return aux input status
?auxos:	jp	auxost			; return aux output status
?dvtbl:	jp	devtbl			; return address of device def table
?devin:	jp	?cinit			; change baud rate of device

?drtbl:	jp	getdrv			; return address of disk drive  table
?mltio:	jp	multio			; set multiple record count for disk i/o
?flush:	jp	flush			; flush bios maintained disk caching

?mov:	jp	?move			; block move memory to memory
?tim:	jp	macclk			; signal time and date operation
?bnksl:	jp	bnksel			; select bank for code execution and default dma
?stbnk:	jp	setbnk			; select different bank for disk i/o dma operation
?xmov:	jp	?xmove			; set source and destination banks for one operation

	jp	0			; reserved for future expansion
	jp	0			; reserved for future expansion
	jp	0			; reserved for future expansion


	; boot
	;	initial entry point for system startup.
	if banked
	dseg				; this part can be banked
	endif

boot:
	ld	b,bbpag << 4		; ensure that sysbios base page ($bb)
	ld	c,mmuport		; is in place
	ld	a,(hmempag)
	sub	4
	out	(c),a

	ld	sp,@bios$stack
	ld	c,15			; initialize all 16 character devices
c$init$loop:
	push	bc
	call	?cinit
	pop	bc
	dec	c
	jp	p,c$init$loop

	call	?init			; perform any additional system initialization

	ld	bc,16*256+0
	ld	hl,@dtbl		; init all 16 logical disk drives
d$init$loop:
	push	bc			; save remaining count and abs drive
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl			; grab @drv entry
	ld	a,e
	or	d
	jr	z,d$init$next		; if null, no drive
	push	hl			; save @drv pointer
	ex	de,hl			; xdph address in <hl>
	dec	hl
	dec	hl
	ld	a,(hl)
	ld	(@rdrv),a		; get relative drive code
	ld	a,c
	ld	(@adrv),a		; get absolute drive code
	dec	hl			; point to init pointer
	ld	d,(hl)
	dec	hl
	ld	e,(hl)			; get init pointer
	ex	de,hl
	call	ipchl			; call init routine
	pop	hl			; recover @drv pointer
d$init$next:
	pop	bc			; recover counter and drive #
	inc	c
	dec	b
	jr	nz,d$init$loop		; and loop for each drive

	jp	boot$1

	cseg				; following in resident memory

boot$1:
	call	setjumps
	call	?ldccp			; fetch ccp for first time
	jp	ccp


	; WBOOT
	;	Entry for system restarts.

wboot:
	ld	sp,@bios$stack
	call	setjumps		; initialize page zero
	call	?rlccp			; reload ccp
	jp	ccp			; then reset jmp vectors and exit to ccp

setjumps:

    if banked
	ld	a,0
	call	?bnksl
	call	dosetjmps
	ld	a,1
	call	?bnksl
    endif

dosetjmps:
	ld	a,0c3h			; jp opcode
	ld	(0),a
	ld	(5),a			; set up jumps in page zero
	ld	hl,?wboot
	ld	(1),hl			; bios warm start entry
	ld	hl,(@mxtpa)
	ld	(6),hl			; bdos system call entry
	ret

	ds	64
@bios$stack 	equ	$


	; devtbl
	;	return address of character device table

devtbl:
	ld	hl,@ctbl
	ret


	; getdrv
	;	return address of drive table

getdrv:
	ld	hl,@dtbl
	ret

	; conout
	;	console output. send character in <c>
	;	to all selected devices

conout:
	ld	hl,(@covec)		; fetch console output bit vector
	jr	out$scan


	; auxout
	;	auxiliary output. send character in <c>
	;	to all selected devices

auxout:
	ld	hl,(@aovec)		; fetch aux output bit vector
	jr	out$scan


	; blist
	;	list output. send character in <c>
	;	to all selected devices.

blist:
	ld	hl,(@lovec)		; fetch list output bit vector

out$scan:
	ld	b,0			; start with device 0
co$next:
	add	hl,hl			; shift out next bit
	jr	nc,not$out$device
	push	hl			; save the vector
	push	bc			; restore and resave the character and device
	call	?co			; if device selected, print it
	pop	bc			; recover count and character
	pop	hl			; recover the rest of the vector
not$out$device:
	inc	b			; next device number
	ld	a,h
	or	l			; see if any devices left
	jr	nz,co$next		; and go find them...
	ret


	; CONOST
	;	Console Output Status. Return true if
	;	all selected console output devices
	;	are ready.

conost:
	ld	hl,(@covec)		; get console output bit vector
	jr	ost$scan


	; AUXOST
	;	Auxiliary Output Status. Return true if
	;	all selected auxiliary output devices
	;	are ready.

auxost:
	ld	hl,(@aovec)		; get aux output bit vector
	jr	ost$scan


	; LISTST
	;	List Output Status. Return true if
	;	all selected list output devices
	;	are ready.

listst:
	ld	hl,(@lovec)		; get list output bit vector

ost$scan:
	ld	b,0			; start with device 0
cos$next:
	add	hl,hl			; check next bit
	push	hl			; save the vector
	push	bc			; save the count
	ld	a,0ffh			; assume device ready
	call	c,coster		; check status for this device
	pop	bc			; recover count
	pop	hl			; recover bit vector
	or	a			; see if device ready
	ret	z			; if any not ready, return false
	inc	b			; drop device number
	ld	a,h
	or	l			; see if any more selected devices
	jr	nz,cos$next
	or	0ffh			; all selected were ready, return true
	ret

coster:		; check for output device ready, including optional
		;xon/xoff support
	ld	l,b
	ld	h,0			; make device code 16 bits
	push	hl			; save it in stack
	add	hl,hl
	add	hl,hl
	add	hl,hl			; create offset into device characteristics tbl
	ld	de,@ctbl+6
	add	hl,de			; make address of mode byte
	ld	a,(hl)
	and	mb$xon$xoff
	pop	hl			; recover console number in <hl>
	jp	z,?cost			; not a xon device, go get output status direct
	ld	de,xofflist
	add	hl,de			; make pointer to proper xon/xoff flag
	call	cist1			; see if this keyboard has character
	ld	a,(hl)
	call	nz,ci1			; get flag or read key if any
	cp	ctlq
	jr	nz,not$q		; if its a ctl-q,
	ld	a,0ffh			; set the flag ready
not$q:
	cp	ctls
	jr	nz,not$s		; if its a ctl-s,
	ld	a,00h			; clear the flag
not$s:
	ld	(hl),a			; save the flag
	call	cost1			; get the actual output status,
	and	(hl)			; and mask with ctl-q/ctl-s flag
	ret				; return this as the status

cist1:		; get input status with <bc> and <hl> saved
	push	bc
	push	hl
	call	?cist
	pop	hl
	pop	bc
	or	a
	ret

cost1:		; get output status, saving <bc> & <hl>
	push	bc
	push	hl
	call	?cost
	pop	hl
	pop	bc
	or	a
	ret

ci1:		; get input, saving <bc> & <hl>
	push	bc
	push	hl
	call	?ci
	pop	hl
	pop	bc
	ret


	; CONST
	;	Console Input Status. Return true if
	;	any selected console input device
	;	has an available character.

const:
	ld	hl,(@civec)		; get console input bit vector
	jr	ist$scan


	; AUXIST
	;	Auxiliary Input Status. Return true if
	;	any selected auxiliary input device
	;	has an available character.

auxist:
	ld	hl,(@aivec)		; get aux input bit vector

ist$scan:
	ld	b,0			; start with device 0
cis$next:
	add	hl,hl			; check next bit
	ld	a,0			; assume device not ready
	call	c,cist1			; check status for this device
	or	a
	ret	nz			; if any ready, return true
	inc	b			; next device number
	ld	a,h
	or	l			; see if any more selected devices
	jr	nz,cis$next
	xor	a			; all selected were not ready, return false
	ret


	; CONIN
	;	Console Input. Return character from first
	;		ready console input device.

conin:
	ld	hl,(@civec)
	jr	in$scan


	; AUXIN
	;	Auxiliary Input. Return character from first
	;	ready auxiliary input device.

auxin:
	ld	hl,(@aivec)

in$scan:
	push	hl			; save bit vector
	ld	b,0
ci$next:
	add	hl,hl			; shift out next bit
	ld	a,0			; insure zero a (nonexistant device not ready).
	call	c,cist1			; see if the device has a character
	or	a
	jr	nz,ci$rdy		; this device has a character
	inc	b			; else, next device
	ld	a,h
	or	l			; see if any more devices
	jr	nz,ci$next		; go look at them
	pop	hl			; recover bit vector
	jr	in$scan			; loop til we find a character
ci$rdy:
	pop	hl			; discard extra stack
	jp	?ci


	; utility subroutines

ipchl:					; vectored call point
	jp	(hl)

?pmsg:		; print message @<hl> up to a null
		; saves <bc> & <de>
	push	bc
	push	de
pmsg$loop:
	ld	a,(hl)
	or	a
	jr	z,pmsg$exit
	ld	c,a
	push	hl
	call	?cono
	pop	hl
	inc	hl
	jr	pmsg$loop
pmsg$exit:
	pop	de
	pop	bc
	ret


?pdec0:		; print binary number 0-65535 from <hl>, with leading zeros
	ld	b,1
	jr	pdec1

?pdec:		; print binary number 0-65535 from <hl>, no leading zeros

	ld	b,0
pdec1:	ld	de,-10000
	call	sbcnt
	ld	de,-1000
	call	sbcnt
	ld	de,-100
	call	sbcnt
	ld	de,-10
	call	sbcnt
	ld	a,l
	add	a,'0'
	ld	c,a
	jp	?cono

sbcnt:	ld	c,'0'-1
sb1:	inc	c
	add	hl,de
	jr	c,sb1
	sbc	hl,de
	ld	a,b
	or	a
	jr	nz,sb2
	ld	a,c
	cp	'0'
	ret	z
	ld	b,1
sb2:	push	hl
	push	bc
	call	?cono
	pop	bc
	pop	hl
	ret

?pderr:
	ld	hl,drive$msg
	call	?pmsg			; error header
	ld	a,(@adrv)
	add	a,'a'
	ld	c,a
	call	?cono			; drive code
	ld	hl,track$msg
	call	?pmsg			; track header
	ld	hl,(@trk)
	call	?pdec0			; track number
	ld	hl,sector$msg
	call	?pmsg			; sector header
	ld	hl,(@sect)
	call	?pdec0			; sector number
	ret


	; BNKSEL
	;	Bank Select. Select CPU bank for further execution.

bnksel:
	ld	(@cbnk),a		; remember current bank
	jp	?bank			; and go exit through users
					; physical bank select routine

xofflist:
	db 	-1,-1,-1,-1,-1,-1,-1,-1	; ctl-s clears to zero
	db	-1,-1,-1,-1,-1,-1,-1,-1

	if banked
	dseg	; following resides in banked memory
        endif

	; Disk I/O interface routines


	; SELDSK
	;	Select Disk Drive. Drive code in <C>.
	;	Invoke login procedure for drive
	;	if this is first select. Return
	;	address of disk parameter header
	;	in <HL>

seldsk:
	call	bbdsksel
	ld	a,c
	ld	(@adrv),a		; save drive select code
	ld	l,c
	ld	h,0
	add	hl,hl			; create index from drive code
	ld	bc,@dtbl
	add	hl,bc			; get pointer to dispatch table
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a			; point at disk descriptor
	or	h
	ret	z			; if no entry in table, no disk
	ld	a,e
	and	1
	jr	nz,not$first$select	; examine login bit
	push	hl
	ex	de,hl			; put pointer in stack & <de>
	ld	hl,-2
	add	hl,de
	ld	a,(hl)
	ld	(@rdrv),a		; get relative drive
	ld	hl,-6
	add	hl,de			; find login addr
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a			; get address of login routine
	call	ipchl			; call login
	pop	hl			; recover dph pointer
not$first$select:
	ret


	; HOME
	;	Home selected drive. Treated as SETTRK(0).

home:
	ld	bc,0			; same as set track zero


	; SETTRK
	;	Set Track. Saves track address from <BC>
	;	in @TRK for further operations.

settrk:
	ld	(@trk),bc
	call	bbtrkset
	ret


	; SETSEC
	;	Set Sector. Saves sector number from <BC>
	;	in @sect for further operations.

setsec:

	ld	a,(fdrvbuf)		; select...
	cp	2			; is floppy ?
	jp	m,secin			; yes
	cp	14			; is ide ?
	jp	m,secin			; yes
	cp	15			; virtual hd ?
	jr	z,secadj		; yes (p:)
	jr	secin			; no, virtual floppy (o:)

secadj:	inc	bc
secin:	ld	(@sect),bc
	call	bbsecset
	ret


	; SETDMA
	;	Set Disk Memory Address. Saves DMA address
	;	from <BC> in @DMA and sets @DBNK to @CBNK
	;	so that further disk operations take place
	;	in current bank.

setdma:
	ld	(@dma),bc
	call	bbdmaset
	ld	a,(@cbnk)		; default dma bank is current bank
					; fall through to set dma bank


	; SETBNK
	;	Set Disk Memory Bank. Saves bank number
	;	in @DBNK for future disk data
	;	transfers.

setbnk:
	ld	(@dbnk),a
	ret


	; SECTRN
	;	Sector Translate. Indexes skew table in <DE>
	;	with sector in <BC>. Returns physical sector
	;	in <HL>. If no skew table (<DE>=0) then
	;	returns physical=logical.

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


	; READ
	;	Read physical record from currently selected drive.
	;	Finds address of proper read routine from
	;	extended disk parameter header (XDPH).

read:
	ld	hl,(@adrv)
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
	jr	rw$common		; use common code


	; WRITE
	;	Write physical sector from currently selected drive.
	;	Finds address of proper write routine from
	;	extended disk parameter header (XDPH).

write:
	ld	hl,(@adrv)
	ld	h,0
	add	hl,hl			; get drive code and double it
	ld	de,@dtbl
	add	hl,de			; make address of table entry
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a			; fetch table entry
	push	hl			; save address of table
	ld	de,-10
	add	hl,de			; point to write routine address

rw$common:
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a			; get address of routine
	pop	de			; recover address of table
	dec	de
	dec	de			; point to relative drive
	ld	a,(de)
	ld	(@rdrv),a		; get relative drive code and post it
	inc	de
	inc	de			; point to dph again
	jp	(hl)			; leap to driver


	; MULTIO
	;	Set multiple sector count. Saves passed count in
	;	@CNT

multio:
	ld	(@cnt),a
	ret


	; FLUSH
	;	BIOS deblocking buffer flush. Not implemented.

flush:
	xor	a
	ret				; return with no error

	; error message components

drive$msg:	db	cr,lf,bell,'bios error on ',0
track$msg:	db	': t-',0
sector$msg:	db	', s-',0

	; disk communication data items

	cseg	; in common memory

@adrv:	ds	1		; currently selected disk drive
@rdrv:	ds	1		; controller relative disk drive
@trk:	ds	2		; current track number
@sect:	ds	2		; current sector number
@dma:	ds	2		; current dma address
@cnt:	db	0		; record count for multisector transfer
@dbnk:	db	0		; bank for dma operations

	cseg	; common memory

@cbnk:	db	0		; bank for processor operations

;:::::::::::  DEBUGGER  ::::::::::::
	if WITHDBG
include	sysdbg.emb
	endif
;:::::::::::  DEBUGGER  ::::::::::::

	end

