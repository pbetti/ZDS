;
;=======================================================================
;
; Modular Z80 DarkStar (NE Z80) Monitor
;
;=======================================================================
;
; IDE Interface on Multif-Board (8255)
; ---------------------------------------------------------------------
; ---------------------------------------------------------------------
;
; 20190211 - Dual drive support, some minor fixes
;
;......................................................................

;
;
; IDE Status Register:
;  bit 7: Busy	1=busy, 0=not busy
;  bit 6: Ready 1=ready for command, 0=not ready yet
;  bit 5: DF	1=fault occured insIDE drive
;  bit 4: DSC	1=seek complete
;  bit 3: DRQ	1=data request ready, 0=not ready to xfer yet
;  bit 2: CORR	1=correctable error occured
;  bit 1: IDX	vendor specific
;  bit 0: ERR	1=error occured
;

IS_BSY		equ	7
IS_RDY		equ	6
IS_DF		equ	5
IS_DSC		equ	4
IS_DRQ		equ	3
IS_COR		equ	2
IS_IDX		equ	1
IS_ERR		equ	0

idbufr		equ	trnpag << 12
hretries	equ	5
signsize	equ	8
entrysize	equ	8
ptblsize	equ	15


parrcrd	macro				; partition table record format
	defb	0			; active
	defb	0			; letter
	defb	0			; type
	defw	0			; start
	defw	0			; end
	defb	0			; reserved
	endm

	; Local storage for disks geometry
dsk0cyls:	defw	0		; For IDE disk 0 or master
dsk0heads:	defw	0
dsk0sectors:	defw	0
dsk1cyls:	defw	0		; For IDE disk 1 or slave
dsk1heads:	defw	0
dsk1sectors:	defw	0
ptstart:	defw	0
ptend:		defw	0
idtsav:		defb	0		; page # save
inretry:	defb	0		; retry on r/w errors
hdrvlog:	defb	0		; selected drive for operations
	; This are partition management
hdlog:		defb	$ff		; logged drive
tbloaded:	defb	0		; flag partition loaded
partbl0:				; local copy of the partition table drive 0
		parrcrd			; entry 0 ...
		parrcrd
		parrcrd
		parrcrd
		parrcrd
		parrcrd
		parrcrd
		parrcrd
		parrcrd
		parrcrd
		parrcrd
		parrcrd
		parrcrd
		parrcrd
		parrcrd
		parrcrd			; ... entry 15
partbl1:				; local copy of the partition table drive 1
		parrcrd			; entry 0 ...
		parrcrd
		parrcrd
		parrcrd
		parrcrd
		parrcrd
		parrcrd
		parrcrd
		parrcrd
		parrcrd
		parrcrd
		parrcrd
		parrcrd
		parrcrd
		parrcrd
		parrcrd			; ... entry 15
signstring:	defb	"AUAUUAUA"	; signature string

; 

;;
;; M/S select
;;

sel_master:
	ld	d,11100000b		; data for IDE SDH reg (512 bytes, LBA mode, master drive, head 0)
sel_ms:
	ld	e,regshd
	call	idewr8d
	ret

sel_slave:
	ld	d,11110000b		; data for IDE SDH reg (512 bytes, LBA mode, slave drive, head 0)
	jr	sel_ms

loghdrv:
	push	hl
	ld	hl,hdrvlog
	ld	(hl),d
	pop	hl
	ret
	
sel_logged_drive:
	ld	a,(hdrvlog)
	or	a
	jr	z,sel_master
	jr	sel_slave
	
;;
;; Initialize interface
;;
hdinit:
	call	sel_master
	ld	e,regstatus		; get status after initilization
	call	iderd8d			; check status
	ld	a,d
	and	11100000b
	cp	11100000b		; nothing connected
	ld	a,2			; signal no drive and ret
	ret	z
	
	ld	a,readcfg8255		; 10010010b
	out	(ideportctrl),a		; config 8255 chip, READ mode

	ld	a,iderstline
	out	(ideportc),a		; hard reset the disk drive

	ld	b,$20			; tunable
hdresdly0:
	dec	b
	jr	nz,hdresdly0		; delay (reset pulse width)

	xor	a
	out	(ideportc),a		; no IDE control lines asserted

	ld	de,32			; wait drive normal init
	call	delay			; pause 32 ms.

	ld	b,$ff			; tunable
hdwaitini0:
	call	sel_master		; wait longer (disc speed up)
	ld	e,regstatus		; get status after initilization
	call	iderd8d			; check status
	bit	IS_BSY,d
	jr	z, hdinitslave		; master ok, try for slave


	;Delay to allow drive to get up to speed
	push	bc			; (the 0FFH above)
	ld	bc,$ffff
delay2:	ld	d,2			; may need to adjust delay time to allow cold drive to
delay1:	dec	d			; to speed
	jp	nz,delay1
	dec	bc
	ld	a,c
	or	b
	jp	nz,delay2
	pop	bc
	djnz	hdwaitini0
	xor	a			; flag error on return
	dec	a
	ret

hdinitslave:
	call	sel_slave
	ld	e,regstatus		; get status after initilization
	call	iderd8d			; check status
	ld	a,d
	or	a
; 	ret	z			; got "00000000" if not present
	

	ld	b,$ff			; tunable
hdwaitini1:
	call	sel_slave		; wait longer (disc speed up)
	ld	e,regstatus		; get status after initilization
	call	iderd8d			; check status
	bit	IS_BSY,d
	jr	nz,hddelay1		; return if ready bit is zero
	ld	hl,cnfbyte
	set	7,(hl)			; signal 2nd drive
	ret

	;Delay to allow drive to get up to speed
hddelay1:
	push	bc			; (the 0FFH above)
	ld	bc,$ffff
delay21:ld	d,2			; may need to adjust delay time to allow cold drive to
delay11:dec	d			; to speed
	jp	nz,delay11
	dec	bc
	ld	a,c
	or	b
	jp	nz,delay21
	pop	bc
	djnz	hdwaitini1
	ld	hl,cnfbyte
	set	7,(hl)			; signal 2nd drive
	set	6,(hl)			; signal 2nd drive failure
	ret

;;
;; Get drive identification block
;;
driveid:
	; Mount transient page used for id buffer
	ld	b, trnpag
	call	mmgetp
	ld	(idtsav), a		; save current
	;
	ld	a,(hmempag)		; bios scratch page (phy)
	ld	b,trnpag		; transient page
	call	mmpmap			; mount it
	;
	call	idewaitnotbusy
	jr	c,idrnok

	call	sel_logged_drive
	ld	d,cmdid
	ld	e,regcommand
	call	idewr8d			; issue the command

	call	idewaitdrq		; wait for Busy=0, DRQ=1
	jr	c,idrnok

	ld	b,0
	ld	hl,idbufr		; store data here
	call	morerd16
	;;
	;; workaround for first word lossy drivers
	;;
	ld	a,(idbufr+18)
	cp	' '
	jr	nz,idrtrn
	; first word loss...
	ld	b,3			; # of retrys
idretry:
	push	bc
	call	sel_logged_drive
	call	idewaitnotbusy
	jr	c,idrnok

	ld	d,cmdid
	ld	e,regcommand
	call	idewr8d

	call	idewaitdrq		; Wait for Busy=0, DRQ=1
	jr	c,idrnok

	ld	b,0
	ld	hl,idbufr		; store data here
	call	morerd16i		; get words, try to recover 1st word already
					; on ide bus
	pop	bc
	ld	a,(idbufr+18)
	cp	' '
	jr	nz,idrtrn
	djnz	idretry
idrnok:
	call	rsidbuf
	xor	a
	dec	a
	ret				; * sigh * :-(
idrtrn:
	; prior to return we save disk params locally
	call	savegeo
	call	rsidbuf
	xor	a			; reset z flag
	ret

;;
;; restore scratch
;;
rsidbuf:
	ld	a,(idtsav)		; old
	ld	b,trnpag		; transient page
	call	mmpmap			; mount it
	ret

;;
;; Save disk geometry
;;
savegeo:
	push	iy
	push	af
	ld	a,(hdrvlog)
	or	a
	jr	nz,geo1
	; TODO: should work also for slave
	ld	iy,dsk0cyls	
	jr	ggeo
geo1:	
	ld	iy,dsk1cyls	
ggeo:
	pop	af
	ld	hl,idbufr + 2		; cyls
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	(iy+0), c
	ld	(iy+1), b
	ld	hl,idbufr + 6		; heads
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	(iy+2), c
	ld	(iy+3), b
	ld	hl,idbufr + 12		; sectors
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	(iy+4), c
	ld	(iy+5), b
	pop	iy
	ret

;;
;; Return disk geometry
;;
;; IX < cylinders, IY < heads, HL < sectors
gethdgeo:
	ld	a,(hdrvlog)
	or	a
	jr	nz,ggeo1
	ld	ix,(dsk0cyls)
	ld	iy,(dsk0heads)
	ld	hl,(dsk0sectors)
	ret
ggeo1:
	ld	ix,(dsk1cyls)
	ld	iy,(dsk1heads)
	ld	hl,(dsk1sectors)
	ret
	
	
;;
;; Get partition table
;;
getptable:
	ld	a,(hdrvlog)		; current drive, save it
	push	af
	ld	d,0			; drive 0
	call	loghdrv
	call	dogetptable
	ld	hl,cnfbyte
	bit	7,(hl)			; drive 1 present?
	jr	z,gotptab
	ld	d,1			; drive 1
	call	loghdrv
	call	dogetptable
gotptab:
	pop	af
	ld	(hdrvlog),a
	ret
dogetptable:
	ld	hl,tmpbyte		; enable unpartitioned addressing
	set	7,(hl)
	ld	bc,(dsk0sectors)	; verify we know disk geometry
	ld	a,(hdrvlog)		; m/s?
	or	a
	jr	z,gptable0
	ld	bc,(dsk1sectors)
gptable0:
	ld	a,c
	or	b
	jr	nz,getot00
	call	driveid			; no: load it
	jr	nz,getperr		; damn !
getot00:
	; mount transient page used for operations
	ld	b, trnpag
	call	mmgetp
	ld	(idtsav), a		; save current
	;
	ld	a,(hmempag)		; bios scratch page (phy)
	ld	b,trnpag		; transient page
	call	mmpmap			; mount it
	; read table
	ld	bc,0			; track 0
	call	trkset
	ld	bc,1			; sector 1
	call	secset
	ld	bc,idbufr		; DMA @ temp page
	call	dmaset
	call	readsector
	jr	nz,getperr		; :-(
	; check signature for valid table
	ld	de,signstring
	ld	hl,idbufr
	ld	bc,signsize
getot01:
	ld	a,(de)			; do compare
	inc	de
	cpi
	jr	nz,getperr		; invalid table
	jp	po,getot02
	jr	getot01
getot02:
	; copy table in, only active entries are copied
	exx
	ld	b,ptblsize		; count on table entries
	exx
	ld	hl,idbufr+signsize-entrysize
	ld	de,partbl0
	ld	a,(hdrvlog)
	or	a			; drive 0/1
	jr	z,getot04
	ld	de,partbl1
getot04:
	ld	b,entrysize
getot07:
	inc	hl
	djnz	getot07
getot05:
	ld	bc,entrysize
; 	ld	a,(hl)
; 	cp	'Y'			; is active ?
; 	jr	nz,getot03
	ldir
	exx
	dec	b
	exx
	jr	nz,getot05
	jr	getot06
getot03:
	exx
	dec	b
	exx
	jr	nz,getot04
getot06:
	xor	a
	push	af
	jr	getpexi
getperr:				; failure
	xor	a
	dec	a
	push	af
getpexi:
	; prior to return restore temporary
	call	rsidbuf
	ld	hl,tmpbyte		; disable unpartitioned addressing
	res	7,(hl)
	pop	af
	ret

;;
;; Read sector (512 bytes) from IDE
;;
readsector:
	call	sel_logged_drive	; m/s
	call	wrlba			; tell which sector we want to read from.
	ret	nz			; LBA error
	call	idewaitnotbusy
	jp	c,rdsnok		; status error

	ld	d,cmdread
	ld	e,regcommand
	call	idewr8d			; send sec read command to drive.
	call	idewaitdrq		; wait until it's got the data
	jp	c,rdsnok		; read/status error
	;
	ld	hl,(frdpbuf)		; DMA address
	ld	b,0			; read 512 bytes to [HL] (256X2 bytes)
morerd16:
	ld	a,regdata		; REG register address
	out	(ideportc),a

	or	iderdline		; pulse RD line
	out	(ideportc),a
morerd16i:
	in	a,(ideporta)		; read lower byte
	ld	(hl),a
	inc	hl
	in	a,(ideportb)		; read upper byte
	ld	(hl),a
	inc	hl

	ld	a,regdata		; deassert RD line
	out	(ideportc),a
	djnz	morerd16

	ld	e,regstatus
	call	iderd8d
	ld	a,d
	and	$01
	jr	nz,rdsnok
rdsok:
	xor	a			; ok
	ld	(inretry),a		; clean, in case...
	ret
rdsnok:
	ld	a,(inretry)		; in a retry loop ?
	or	a
	ld	hl,readsector		; where to come back
	jr	nz,ioretr		; handle retry
	ld	a,hretries+1		; no. start it
; 	JR	IORETR

	; ... fall through

	; retry handle, common for both read and write
ioretr:	dec	a
	ld	(inretry),a		; update count
	jr	z,unrecov		; unrecoverable error!
	call	hdinit			; reset drive
	jp	(hl)			; redo
unrecov:
	dec	a
	ret				; error

;;
;; Write a sector, specified by the 3 bytes in LBA
;;
writesector:
	call	sel_logged_drive	; m/s
	call	wrlba			; set LBA sector
	ret	nz			; LBA error
	call	idewaitnotbusy		; make sure drive is ready
	jp	c,wrsnok

	ld	d,cmdwrite
	ld	e,regcommand
	call	idewr8d			; tell drive to write a sector
	call	idewaitdrq		; wait unit it wants the data
	jp	c,wrsnok
;
	ld	hl,(frdpbuf)
	ld	b,0			; 256X2 bytes

	ld	a,writecfg8255
	out	(ideportctrl),a
wrsec1:	ld	a,(hl)
	inc	hl
	out	(ideporta),a		; write the lower byte
	ld	a,(hl)
	inc	hl
	out	(ideportb),a		; write upper byte
	ld	a,regdata
	push	af
	out	(ideportc),a		; send write command
	or	idewrline		; send WR pulse
	out	(ideportc),a
	pop	af
	out	(ideportc),a
	djnz	wrsec1

	ld	a,readcfg8255		; set 8255 back to read mode
	out	(ideportctrl),a

	ld	e,regstatus
	call	iderd8d
	ld	a,d
	and	$01
	jr	nz,wrsnok
wrsok:
	xor	a			; ok
	ret
wrsnok:
	ld	a,(inretry)		; in a retry loop ?
	or	a
	ld	hl,writesector		; where to come back
	jr	nz,ioretr		; handle retry
	ld	a,hretries+1		; no. start it
	jr	ioretr

;;
;; calculate partition offset and validate requested track
;;
trkoff:
	ld	a,(hdlog)		; check for disk change
	ld	b,a
	ld	a,(fdrvbuf)
	cp	b
	jr	z,nodchg		; unchanged
	;
	ld	b,ptblsize		; changed, search in table
	ld	e,entrysize
	ld	d,0
	inc	b
	add	a,'A'			; transform in letter
	ld	c,a			; save on C
	ld	iy,partbl0-entrysize	; point to table 0, back one slot
	ld	a,(hdrvlog)
	or	a			; drive 0/1
	jr	z,tonext
	ld	iy,partbl1-entrysize	; point to table 0, back one slot
tonext:	add	iy,de			; point to next
	dec	b
	jr	z,toferr		; not found !
	cp	(iy+1)			; compare
	jr	nz,tonext
	ld	a,(copsys)		; verify type
	or	a
	jr	z,notpck		; unspecified
	cp	(iy+2)
	jr	z,notpck		; ok, go on
	ld	a,c			; restore drive letter
	jr	tonext			; try again
notpck: ;
	ld	l,(iy+3)		; found, save data
	ld	h,(iy+4)		; start cyl
	ld	(ptstart),hl
	ld	l,(iy+5)
	ld	h,(iy+6)		; end cyl
	ld	(ptend),hl
nodchg:	; add offset, check partition boundaries
	ld	hl,(ftrkbuf)
	ld	de,(ptstart)
	add	hl,de			; in partition offset. simple!
	ld	c,l
	ld	b,h			; move on BC
	ld	de,(ptend)		; address larger than partition ?
	or	a
	sbc	hl,de
	jr	nc,toferr		; ouch!
	xor	a
	ret
toferr:	xor	a
	dec	a
	pop	hl			; do not reenter in WRLBA
	ret


;;
;; Setup LBA sector on IDE drive
;;
wrlba:
	ld	bc,(ftrkbuf)		; load requested track
	ld	hl,tmpbyte		; check for free/non free addressing
	bit	7,(hl)
	call	z,trkoff

	ld	d,b			; send high TRK#
	ld	e,regcylmsb
	call	idewr8d

	ld	d,c			; send low TRK#
	ld	e,regcyllsb
	call	idewr8d

	ld	a,(fsecbuf)		; get requested sector
	ld	d,a
	ld	e,regsector
	call	idewr8d

	ld	d,1			; one sector at a time (for now ?)
	ld	e,regseccnt
	call	idewr8d

	xor	a			; reset flags
	ret


;;
;; wait for drive to clear busy flag
;;
idewaitnotbusy:				; drive ready if 01000000
	ld	b,$ff
	ld	c,$ff			; delay, must be above 80H for 4MHz Z80
morewait:
	call	sel_logged_drive	; m/s
	ld	e,regstatus		; wait for RDY bit to be set
	call	iderd8d
	ld	a,d
	and	11000000b
	xor	01000000b
	jp	z,donenotbusy
	djnz	morewait
	dec	c
	jp	nz,morewait
	scf				; set carry to indicate an error
	ret
donenotbusy:
	or	a			; clear carry it indicate no error
	ret

;;
;; wait for drive to set data ready flag
;;
idewaitdrq:
	ld	b,$ff
	ld	c,$ff
moredrq:
	call	sel_logged_drive
	ld	e,regstatus		; wait for DRQ bit to be set
	call	iderd8d
	ld	a,d
	and	10001000b
	cp	00001000b
	jp	z,donedrq
	djnz	moredrq
	dec	c
	jp	nz,moredrq
	scf				; set carry to indicate error
	ret
donedrq:
	or	a			; clear carry
	ret

;;
;; Copy partition table at offset DE
;;
moveptable:
	push	af
	ld	hl,partbl0
	ld	a,(hdrvlog)
	or	a			; drive 0/1
	jr	z,dopmove
	ld	hl,partbl1
dopmove:
	ld	bc,16*8
	ldir
	pop	af
	ret

;------------------------------------------------------------------
; Low Level 8 bit R/W to the drive controller. These are the routines
; that talk directly to the drive controller registers, via the
; 8255 chip.
; Note the 16 bit I/O to the drive (which is only for SEC R/W) is done
; directly in the routines READSECTOR & WRITESECTOR for speed reasons.
;

;;
;; Read 8 bits from IDE register in [E], return info in [D]
;;
iderd8d:
	ld	a,e
	out	(ideportc),a		; drive address onto control lines

	or	iderdline		; RD pulse pin (40H)
	out	(ideportc),a		; assert read pin

	in	a,(ideporta)
	ld	d,a			; return with data in [D]

	ld	a,e			; clear WR line
	out	(ideportc),a

	xor	a
	out	(ideportc),a		; zero all port C lines
	ret

;;
;; Write Data in [D] to IDE register in [E]
;;
idewr8d:
	ld	a,writecfg8255		; set 8255 to write mode
	out	(ideportctrl),a

	ld	a,d			; get data put it in 8255 A port
	out	(ideporta),a

	ld	a,e			; select IDE register
	out	(ideportc),a

	or	idewrline		; lower WR line
	out	(ideportc),a
	nop

	ld	a,e			; clear WR line
	out	(ideportc),a
	nop

	ld	a,readcfg8255		; config 8255 chip, read mode on return
	out	(ideportctrl),a
	ret

;------------------------------------------------------------------------
