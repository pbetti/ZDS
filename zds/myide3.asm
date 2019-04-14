
;
; Test Program to intreact with the CPM3 type BIOS for the S100Computers IDE in
;==============================================================================
;
;	V1.7	3/1/2010	;Removed Z80 Code (so it can be translated to 8086 code later)
;	V2.0	1/23/2011	;Updated to accomidate two CF cards (Master/Slave) & better me
;				;note I still have more work to do with this but what is here seem OK.
;	V2.1	2/5/2011	;Menu driven, and added code to copy & restore disk data from a
	;"backup" partition on disk

;Ports for 8255 chip. Change these to specify where your 8255 is addressed,
;The first three control which 8255 ports have the control signals,
;upper and lower data bytes.  The last one (IDEportCtrl), is for mode setting f
;8255 to configure its actual I/O ports (A,B & C).
;
;Note most drives these days dont use the old Head,Track, Sector terminology. I
;we use "Logical Block Addressing" or LBA. This is what we use below. LBA treat
; as one continous set of sectors, 0,1,2,3,... 3124,....etc.  However as seen b
;convert this LBA to heads,tracks and sectors to be compatible with CPM & MSDOS

include darkstar.equ
include Common.inc.asm
include services.inc.asm


IDEportA	EQU	0E0H		;lower 8 bits of IDE interface
IDEportB	EQU	0E1H		;upper 8 bits of IDE interface
IDEportC	EQU	0E2H		;control lines for IDE interface
IDEportCtrl	EQU	0E3H		;8255 configuration port

READcfg8255	EQU	10010010b	;Set 8255 IDEportC to output, IDEportA/B input
WRITEcfg8255	EQU	10000000b	;Set all three 8255 ports to output mode

;IDE control lines for use with IDEportC.

IDEa0line	EQU	01H	;direct from 8255 to IDE interface
IDEa1line	EQU	02H	;direct from 8255 to IDE interface
IDEa2line	EQU	04H	;direct from 8255 to IDE interface
IDEcs0line	EQU	08H	;inverter between 8255 and IDE interface
IDEcs1line	EQU	10H	;inverter between 8255 and IDE interface
IDEwrline	EQU	20H	;inverter between 8255 and IDE interface
IDErdline	EQU	40H	;inverter between 8255 and IDE interface
IDErstline	EQU	80H	;inverter between 8255 and IDE interface
;
;Symbolic constants for the IDE Drive registers, which makes the
;code more readable than always specifying the address bits

REGdata		EQU	IDEcs0line
REGerr		EQU	IDEcs0line + IDEa0line
REGseccnt	EQU	IDEcs0line + IDEa1line
REGsector	EQU	IDEcs0line + IDEa1line + IDEa0line
REGcylinderLSB	EQU	IDEcs0line + IDEa2line
REGcylinderMSB	EQU	IDEcs0line + IDEa2line + IDEa0line
REGshd		EQU	IDEcs0line + IDEa2line + IDEa1line		;(0EH)
REGcommand	EQU	IDEcs0line + IDEa2line + IDEa1line + IDEa0line	;(0FH)
REGstatus	EQU	IDEcs0line + IDEa2line + IDEa1line + IDEa0line
REGcontrol	EQU	IDEcs1line + IDEa2line + IDEa1line
REGastatus	EQU	IDEcs1line + IDEa2line + IDEa1line

;IDE Command Constants.  These should never change.

COMMANDrecal	EQU	10H
COMMANDread	EQU	20H
COMMANDwrite	EQU	30H
COMMANDinit	EQU	91H
COMMANDid	EQU	0ECH
COMMANDspindown	EQU	0E0H
COMMANDspinup	EQU	0E1H
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
;
				;Equates for display on SD Systems Video Board (Used In CPM Debugging mode only)
scroll	equ	01h		;set scrool direction up.
lf	equ	0ah
cr	equ	0dh
bs	equ	08h		;back space (required for sector display)
bell	equ	07h
; space	equ	20h
tab	equ	09h		;tab across (8 spaces for sd-board)
esc	equ	1bh
clear	equ	1ch		;sd systems video board, clear to eol. (use 80 spaces if eol not available
				;on other video cards)
;
sec$size equ	512		;assume sector size as 512. (not tested for other sizes)
maxsec	equ	0ffh		;sectors per track for cf my memory drive, kingston cf 8g. (for cpm format, 0-3ch)
				;this translates to lba format of 1 to 3d sectors, for a total of 61 sectors/track.
				;this cf card actully has 3f sectors/track. will use 3d for my cpm3 system because
				;my seagate drive has 3d sectors/track. don't want different cpm3.sys files around
				;so this program as is will also work with a seagate 6531 ide drive
maxtrk	equ	0ffh		;cpm3 allows up to 8mg so 0-256 "tracks"
@dma		equ	frdpbuf
@sec		equ	fsecbuf
@trk		equ	ftrkbuf


rdcon	equ	1		;for cp/m i/o
wrcon	equ	2
; print	equ	9
const	equ	11		;console stat
bdos	equ	5

false	equ	0
true	equ	-1

cpm		equ	false	; true if output via cpm, false if direct to hardware
debug		equ	true

abort	equ	0h
; abort	equ	0f000h
;
	org	100h
;
begin:
	ld	sp,stack
	ld	de,sign$on	;print a welcome message
	call	pstring
	ld	hl,tmpbyte	; enable unpartitioned addressing
	set	7,(hl)
	ld	d,0
	call	loghdrv		;sel master 
	ld	bc,buffer
	call	dmaset
	jp	over$tbl

	;command branch table
tbl:	defw	error		; "a"
	defw	backup		; "b"
	defw	error		; "c"  copy disk partition
	defw	display		; "d"  sector contents display:- on/off
	defw	error		; "e"
	defw	format		; "f"  format current disk
	defw	restore		; "g"  restore backup
	defw	error		; "h"
	defw	iddump		; "i"
	defw	error		; "j"
	defw	prgres		; "k"
	defw	set$lba		; "l"  set lba value (set track,sector)
; 	defw	booter		; "m"
	defw	error		; "m"
	defw	power$down	; "n"  power down hard disk command
	defw	error		; "o"
	defw	error		; "p"
	defw	error		; "q"
	defw	read$sec	; "r"  read sector to data buffer
	defw	seq$rd		; "s"  sequental sec read and display contents
	defw	dreset		; "t"
	defw	power$up	; "u"  power up hard disk command
	defw	n$rd$sec	; "v"  read n sectors
	defw	write$sec	; "w"  write data buffer to current sector
	defw	diskswitch	; "x"  write n sectors
	defw	statdbg		; "y"
	defw	n$wr$sec	; "z"

over$tbl:
	ld	a,readcfg8255	;10010010b
	out	(ideportctrl),a	;config 8255 chip, read mode

	xor	a		; no status debug
	ld	(dbgstat),a

	call	hdinit		;initialize the board and drive. if there is no drive abort
	jp	z,init$ok	;setup for main menu commands

; 	xor	a
; 	ld	(dbgstat),a
; 
	ld	de,init$error
	call	pstring
	call	showerrors
	jp	abort

init$ok:
	ld	a,(cnfbyte)
	bit	7,a
	jr	nz,init$ok0	; may be dual IDE
	ld	d,0
	call	loghdrv		; single IDE force selection
init$ok0:
	call	driveid		;get the drive id info. if there is no drive, abort
	or	a
	jp	z,init$ok1

	ld	de,id$error
	call	pstring
	call	showerrors
	jp	abort

init$ok1: ;print the drive's model number
	ld	de, msgmdl
	call	pstring
	ld	hl,idbufr + 54
	ld	b,10		;character count in words
	call	printname	;print [hl], [b] x 2 characters
	call	zcrlf
	; print the drive's serial number
	ld	de, msgsn
	call	pstring
	ld	hl,idbufr + 20
	ld	b, 5		;character count in words
	call	printname
	call	zcrlf
	;print the drive's firmware revision string
	ld	de, msgrev
	call	pstring
	ld	hl,idbufr + 46
	ld	b, 2
	call	printname	;character count in words
	call	zcrlf
	;print the drive's cylinder, head, and sector specs
	ld	de, msgcy
	call	pstring
	ld	hl,idbufr + 2
	call	printparm
	ld	de,msghd
	call	pstring
	ld	hl,idbufr + 6
	call	printparm
	ld	de, msgsc
	call	pstring
	ld	hl,idbufr + 12
	call	printparm
	call	zcrlf
	;default position will be first block
	ld	hl,0
	ld	(fsecbuf),hl	;default to track 0, sec 0
	ld	(@trk),hl
	ld	hl,buffer	;set dma address to buffer
	ld	(@dma),hl


mainloop: ;a 1 line prompt
	ld	a,(@displayflag);do we have detail sector data display flag on or off
	or	a		;nz = on (initially 0ffh so detailed sector display on)
	jp	nz,display1
	ld	de,cmd$string1	;list command options (turn display option to on)
	jp	p,display2
display1:
	ld	de,cmd$string2	;list command options (turn display option to off)
display2:
	call	pstring

	call	wrlba		;update lba on drive
	call	displayposition	;display current track,sector,head#

	ld	de,prompt	;'>'
	call	pstring

	call	getcmd		;simple character input (note, no fancy checking)
	cp	esc		;abort if esc
	jp	z,abort
	call	upper
	call	zcrlf

; 	org	1000h

	sbc	a,'@'		;adjust to 0,1ah

	add	a,a		;x2
	ld	hl,tbl		;get menu selection
	add	a,l
	ld	l,a
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a		;jump to table pointer
	jp	(hl)		;jmp (hl)

diskswitch:
	ld	a,(hdrvlog)
	inc	a
	and	00000001b
	ld	(hdrvlog),a
	jp	init$ok
prgres:
	ld	c,0ch
	call	zco
	jp	init$ok

read$sec: ;read sector @ lba to the ram buffer
	ld	hl,buffer	;point to buffer
	ld	(@dma),hl

	call	readsector

	jp	z,main1b	;z means the sector read was ok
	call	zcrlf
	jp	mainloop
main1b:	ld	de, msgrd	;sector read ok
	call	pstring

	ld	a,(@displayflag);do we have detail sector data display flag on or off
	or	a		;nz = on
	jp	z,mainloop
	ld	a,1
	ld	(dmppause),a
	ld	hl,buffer	;point to buffer. show sector data flag is on
	ld	(@dma),hl
	call	hexdump		;show sector data
	jp	mainloop

write$sec: ;write data in ram buffer to sector @ lba
	ld	de,msgsure	;are you sure?
	call	pstring
	call	zci
	call	upper
	cp	'Y'
	jp	nz,main2c
	call	zcrlf
	
	ld	hl,buffer	;point to buffer
	xor	a
	ld	b,a
fillpat:	
	ld	(hl),a
	inc	hl
	inc	a
	ld	(hl),a
	inc	hl
	inc	a
	djnz	fillpat

	ld	hl,buffer	;point to buffer
	ld	(@dma),hl

	call	writesector

	jp	z,main2b	;z means the sector write was ok
	call	zcrlf
	jp	mainloop
main2b:	ld	de, msgwr	;sector written ok
	call	pstring
main2c:	jp	mainloop


set$lba:;set the logical block address
	ld	de,get$lba
	call	pstring
	call	ghex32lba	;get new cpm style track & sector number and put them in ram at
	jp	c,main3b	;ret c set if abort/error
	call	wrlba		;update lba on drive
main3b:	call	zcrlf
	jp	mainloop

power$up: ;set the drive to spin up (for hard disk connections)
	call	spinup
	jp	mainloop

power$down: ;set the drive to spin down (for hard disk connections)
	call	spindown
	jp	mainloop

display:;do we have detail sector data display flag on or off
	ld	a,(@displayflag)
	cpl			;flip it
	ld	(@displayflag),a
	jp	mainloop	;update display and back to next menu command

statdbg:
	ld	a,(dbgstat)
	cpl			;flip it
	ld	(dbgstat),a
	jp	mainloop	;update display and back to next menu command


seq$rd:	;do sequential reads
	call	sequentialreads
	jp	mainloop

n$rd$sec: ;read n sectors >>>> note no check is made to not overwrite
	ld	de,readn$msg	;cpm etc. in high ram
	call	pstring
	call	gethex
	jp	c,mainloop	;abort if esc (c flag set)
	ld	(seccount),a	;store sector count

	ld	hl,buffer	;point to buffer
	ld	(@dma),hl
nextrsec:
	ld	de,readingn$msg
	call	pstring
	call	wrlba		;update lba on drive
	call	displayposition	;display current track,sector,head#

	ld	hl,(@dma)
	call	readsector
	ld	(@dma),hl

	ld	a,(seccount)
	dec	a
	ld	(seccount),a
	jp	z,mainloop

	ld	hl,(@sec)
	inc	hl
	ld	(@sec),hl
	ld	a,l		;0 to 62 cpm sectors
	cp	maxsec-1
	jp	nz,nextrsec

	ld	hl,0		;back to cpm sector 0
	ld	(@sec),hl
	ld	hl,(@trk)	;bump to next track
	inc	hl
	ld	(@trk),hl
	ld	a,l		;0-ffh tracks (only)
	jp	nz,nextrsec

	ld	de,atend	;tell us we are at end of disk
	call	pstring
	jp	mainloop

n$wr$sec: ;write n sectors
	ld	de,msgsure	;are you sure?
	call	pstring
	call	zci
	call	upper
	cp	'Y'
	jp	nz,main2c

	ld	de,writen$msg
	call	pstring
	call	gethex
	jp	c,mainloop	;abort if esc (c flag set)
	ld	(seccount),a	;store sector count

	ld	hl,buffer	;point to buffer
	ld	(@dma),hl
nextwsec:
	ld	de,writingn$msg
	call	pstring
	call	wrlba		;update lba on drive
	call	displayposition	;display current track,sector,head#

	ld	hl,(@dma)
	call	writesector
	ld	(@dma),hl

	ld	a,(seccount)
	dec	a
	ld	(seccount),a
	jp	z,mainloop

	ld	hl,(@sec)
	inc	hl
	ld	(@sec),hl
	ld	a,l		;0 to 62 cpm sectors
	cp	maxsec-1
	jp	nz,nextwsec

	ld	hl,0		;back to cpm sector 0
	ld	(@sec),hl
	ld	hl,(@trk)	;bump to next track
	inc	hl
	ld	(@trk),hl
	ld	a,l		;0-ffh tracks (only)
	jp	nz,nextwsec

	ld	de,atend	;tell us we are at end of disk
	call	pstring
	jp	mainloop


format:	;format (fill sectors with e5's for cpm directory empty)
	ld	de,format$msg
	call	pstring
	ld	de,msgsure	;are you sure?
	call	pstring
	call	zci
	call	upper
	cp	'Y'
	jp	nz,mainloop
	ld	hl,buffer	;fill buffer with 0e5's (512 of them)
	ld	b,0
fill0:	ld	a,0e5h		;<-- sector fill character (0e5's for cpm)
	ld	(hl),a
	inc	hl
	ld	(hl),a
	inc	hl
	djnz	fill0
	call	zcrlf
;
next$format:
	ld	hl,buffer
	ld	(@dma),hl
	call	writesector	;will return error if there was one
	jp	z,main9b	;z means the sector write was ok
	call	zcrlf
	jp	mainloop
main9b:	call	zeol		;clear line cursor is on
	call	displayposition	;display actual current track,sector,head#
	call	zcsts		;any keyboard character will stop display
; 	cp	01h		;cpm says something there
	jp	nz,wrnextsec1
	call	zci		;flush character
	ld	de,continue$msg
	call	pstring
	call	zci
	cp	esc
	jp	z,mainloop
	call	zcrlf
wrnextsec1:
	ld	hl,(@sec)
	inc	hl
	ld	(@sec),hl	;0 to maxsec cpm sectors
	ld	a,l
	cp	maxsec
	jp	nz,next$format

	ld	hl,0		;back to cpm sector 0
	ld	(@sec),hl
	ld	hl,(@trk)	;bump to next track
	inc	hl
	ld	(@trk),hl
	ld	a,l		;0-ffh tracks (only)
	cp	maxtrk
	jp	nz,next$format

	ld	de,formatdone	;tell us we are all done.
	call	pstring
	jp	mainloop


backup:	;backup the cpm partition to another area on the same cf-card/disk
	ld	de,copymsg
	call	pstring
	call	zci
	call	upper
	cp	'Y'
	jp	nz,mainloop

	ld	hl,0		;start with cpm sector 0
	ld	(@sec),hl
	ld	(@sec1),hl
	ld	(@sec2),hl	;and on second partition
	ld	(@trk),hl	;and track 0
	ld	(@trk1),hl
	ld	hl,maxtrk+0200h+1;<<<<< vip this assumes cpm3 is on tracks 0-maxtrk. (0-ff
	ld	(@trk2),hl	;it skips an area to be safe. however if you have other stuff on
	;cf card at that location (eg dos partition) change this value
	call	zcrlf
	call	zcrlf

nextcopy1:
	call	zeol		;clear line cursor is on
	ld	de,rbackup$msg	;for each track update display
	call	pstring
	ld	a,(@trk1+1)	;high trk byte
	call	phex
	ld	a,(@trk1)	;low trk byte
	call	phex
	ld	de,wbackup$msg
	call	pstring
	ld	a,(@trk2+1)	;high trk byte
	call	phex
	ld	a,(@trk2)	;low trk byte
	call	phex
	ld	de,h$msg
	call	pstring

nextcopy:
	ld	a,(@sec1)
	ld	(@sec),a
	ld	hl,(@trk1)
	ld	(@trk),hl
	call	wrlba		;update lba on "1st" drive

	ld	hl,buffer	;point to buffer
	ld	(@dma),hl
	call	readsector	;get sector data to buffer

	ld	a,(@sec2)
	ld	(@sec),a
	ld	hl,(@trk2)
	ld	(@trk),hl
	call	wrlba		;update lba on "2nd" drive

	ld	hl,buffer	;point to buffer
	ld	(@dma),hl
	call	writesector	;write buffer data to sector

	call	zcsts		;any keyboard character will stop display
; 	cp	01h		;cpm says something there
	jp	nz,bknextsec1
	call	zci		;flush character
	ld	de,continue$msg
	call	pstring
	call	zci
	cp	esc
	jp	z,mainloop

bknextsec1:
	ld	hl,(@sec)
	inc	hl
	ld	(@sec1),hl
	ld	(@sec2),hl
	ld	a,l		;0 to 62 cpm sectors
	cp	maxsec-1
	jp	nz,nextcopy

	ld	hl,0		;back to cpm sector 0
	ld	(@sec1),hl
	ld	(@sec2),hl

	ld	hl,(@trk1)	;bump to next track
	inc	hl
	ld	(@trk1),hl

	ld	hl,(@trk2)	;bump to next track
	inc	hl
	ld	(@trk2),hl

	ld	hl,(@trk1)	;check if we are done
	ld	a,l		;0-ffh tracks (only)
	cp	maxtrk
	jp	nz,nextcopy1

	ld	de,backupdone	;tell us we are all done.
	call	pstring
	jp	mainloop



restore:;restore disk from backup partition
	ld	de,restoremsg
	call	pstring
	call	zci
	call	upper
	cp	'Y'
	jp	nz,mainloop

	ld	hl,0		;start with cpm sector 0
	ld	(@sec),hl
	ld	(@sec1),hl
	ld	(@sec2),hl	;and on second partition
	ld	(@trk),hl	;and track 0
	ld	(@trk1),hl
	ld	hl,maxtrk+0200h+1;<<<<< vip this assumes cpm3 is on tracks 0-maxtrk. (0-ff
	ld	(@trk2),hl	;it skips an area to be safe. however if you have other stuff on
	;cf card at that location (eg dos partition) change this value
	call	zcrlf
	call	zcrlf

nextrestore1:
	call	zeol		;clear line cursor is on
	ld	de,rbackup$msg	;for each track update display
	call	pstring
	ld	a,(@trk2+1)	;high trk byte
	call	phex
	ld	a,(@trk2)	;low trk byte
	call	phex
	ld	de,wbackup$msg
	call	pstring
	ld	a,(@trk1+1)	;high trk byte
	call	phex
	ld	a,(@trk1)	;low trk byte
	call	phex
	ld	de,h$msg
	call	pstring

nextrestore:
	ld	a,(@sec2)	;point to backup partition
	ld	(@sec),a
	ld	hl,(@trk2)
	ld	(@trk),hl
	call	wrlba		;update lba on "1st" drive

	ld	hl,buffer	;point to buffer
	ld	(@dma),hl
	call	readsector	;get sector data to buffer

	ld	a,(@sec1)
	ld	(@sec),a
	ld	hl,(@trk1)
	ld	(@trk),hl
	call	wrlba		;update lba on "2nd" drive

	ld	hl,buffer	;point to buffer
	ld	(@dma),hl
	call	writesector	;write buffer data to sector

	call	zcsts		;any keyboard character will stop display
; 	cp	01h		;cpm says something there
	jp	nz,resnextsec1
	call	zci		;flush character
	ld	de,continue$msg
	call	pstring
	call	zci
	cp	esc
	jp	z,mainloop

resnextsec1:
	ld	hl,(@sec)
	inc	hl
	ld	(@sec1),hl
	ld	(@sec2),hl
	ld	a,l		;0 to 62 cpm sectors
	cp	maxsec-1
	jp	nz,nextrestore

	ld	hl,0		;back to cpm sector 0
	ld	(@sec1),hl
	ld	(@sec2),hl

	ld	hl,(@trk1)	;bump to next track
	inc	hl
	ld	(@trk1),hl

	ld	hl,(@trk2)	;bump to next track
	inc	hl
	ld	(@trk2),hl

	ld	hl,(@trk2)	;check if we are done
	ld	a,l		;0-ffh tracks (only)
	cp	maxtrk
	jp	nz,nextrestore1

	ld	de,restoredone	;tell us we are all done.
	call	pstring
	jp	mainloop


error:	ld	de, msgerr;cmd error msg
	call	pstring
	jp	mainloop

iddump:
	ld	a,1
	ld	(dmppause),a

	call	ihexdump
	jp	mainloop	;display what is in buffer

dreset:
	call	hdinit		;initialize the board and drive. if there is no drive abort
	jp	z,init$ok	;setup for main menu commands

	ld	de,init$error
	call	pstring
	call	showerrors
	jp	mainloop


;---------------- Support Routines -------------------------------------------

; driveid:call	idewaitnotbusy	;do the identify drive command, and return with the
; 				;filled with info about the drive
; 	jr	c,idrnok	;if busy return nz
; 	ld	d,commandid
; 	ld	e,regcommand
; 	call	idewr8d		;issue the command
; 
; 	call	idewaitdrq	;wait for busy=0, drq=1
; 	jp	c,showerrors
; 
; 	ld	b,0		;256 words
; 	ld	hl,idbuffer	;store data here
; 	call	morerd16	;get 256 words of data from regdata port to [hl]
; 	;;
; 	;; workaround for first word lossy drivers
; 	;;
; 	ld	a,(idbuffer+18)
; 	cp	' '
; 	jr	nz,idrtrn
; 	; first word loss...
; 	ld	b,3
; idretry:
; 	push	bc
; 	call	idewaitnotbusy
; 	ret	c		;if busy return nz
; 	ld	d,commandid
; 	ld	e,regcommand
; 	call	idewr8d		;issue the command
; 
; 	call	idewaitdrq	;wait for busy=0, drq=1
; 	jp	c,showerrors
; 
; 	ld	b,0		;256 words
; 	ld	hl,idbuffer	;store data here
; 	call	morerd16i	;get 256 words of data from regdata port to [hl]
; 	pop	bc
; 	ld	a,(idbuffer+18)
; 	cp	' '
; 	jr	nz,idrtrn
; 	djnz	idretry
; idrnok:
; 	ld	a,1
; 	ret			; * sigh * :-(
; idrtrn:
; 	xor	a		; reset z flag
; 	ret

spinup:
	ld	d,commandspinup
spup2:	ld	e,regcommand
	call	idewr8d
	call	idewaitnotbusy
	jp	c,showerrors
	or	a		;clear carry
	ret



spindown: ;tell the drive to spin down
	call	idewaitnotbusy
	jp	c,showerrors
	ld	d,commandspindown
	jp	spup2

sequentialreads:
	call	idewaitnotbusy	;sequentially read sectors one at a time from current posi
	jp	c,showerrors
	call	zcrlf
nextsec:
	ld	hl,buffer	;point to buffer
	ld	(@dma),hl

	call	readsector	;if there are errors they will show up in readsector
	jp	z,seqok
	ld	de,continue$msg
	call	pstring
	call	zci
	cp	esc		;abort if esc
	ret	z

seqok:	call	zeol		;clear line cursor is on
	call	displayposition	;display current track,sector,head#

	ld	hl,buffer	;point to buffer
	ld	(@dma),hl
	xor	a
	ld	(dmppause),a

	ld	a,(@displayflag);do we have detail sector data display flag on or off
	or	a		;nz = on
	call	nz,hexdump
	call	zcrlf
	call	zcrlf
	call	zcrlf

	call	zcsts		;any keyboard character will stop display
; 	cp	01h		;cpm says something there
	jp	nz,nextsec1
	call	zci		;flush character
	ld	de,continue$msg
	call	pstring
	call	zci
	cp	esc
	ret	z
	call	zcrlf
nextsec1:
	ld	hl,(@sec)
	inc	hl
	ld	(@sec),hl
	ld	a,l		;0 to 62 cpm sectors
	cp	maxsec-1
	jp	nz,nextsec

	ld	hl,0		;back to cpm sector 0
	ld	(@sec),hl
	ld	hl,(@trk)	;bump to next track
	inc	hl
	ld	(@trk),hl
	jp	nextsec		;note will go to last sec on disk unless stopped
;
;
;
displayposition: ;display current track,sector & head position
	ld	de,hdcurmsg	;display in lba format
	call	pstring		;---- cpm format ----
	ld	a,(hdrvlog)	;hd unit
	call	phex

	ld	de,msgcpmtrk	;display in lba format
	call	pstring		;---- cpm format ----
	ld	a,(@trk+1)	;high trk byte
	call	phex
	ld	a,(@trk)	;low trk byte
	call	phex

	ld	de,msgcpmsec
	call	pstring		;sec = (16 bits)
	ld	a,(@sec+1)	;high sec
	call	phex
	ld	a,(@sec)	;low sec
	call	phex
	;---- lba format ----
	ld	de, msglba
	call	pstring		;(lba = 00 (<-- old "heads" = 0 for these drives).
	ld	a,(@trk+1)	;high "cylinder" byte
	call	phex
	ld	a,(@trk)	;low "cylinder" byte
	call	phex
	ld	a,(@sec)
	call	phex
	ld	de, msgbracket	;)$
	call	pstring
	ret

;
printname: ;send text up to [b]
	inc	hl		;text is low byte high byte format
	ld	c,(hl)
	call	zco
	dec	hl
	ld	c,(hl)
	call	zco
	inc	hl
	inc	hl
	dec	b
	jp	nz,printname
	ret
;
zcrlf:
	push	af
	ld	c,cr
	call	zco
	ld	c,lf
	call	zco
	pop	af
	ret
;
zeol:	;cr and clear current line
	ld	c,cr
	call	zco
	ld	c,clear		;note hardware dependent, (use 80 spaces if necessary)
	call	zco
	ret

zcsts:
	if	cpm
	push	bc
	push	de
	push	hl
	ld	c,const
	call	bdos		;returns with 1 in [a] if character at keyboard
	pop	hl
	pop	de
	pop	bc
	cp	1
	ret
	else
	push	bc
	push	de
	push	hl
	call	bbconst
	pop	hl
	pop	de
	pop	bc
	cp	$ff
	ret
	endif

;
zco:	;write character that is in [c]
	if	cpm
	push	af
	push	bc
	push	de
	push	hl
	ld	e,c
	ld	c,wrcon
	call	bdos
	pop	hl
	pop	de
	pop	bc
	pop	af
	ret
	else
	push	af
	push	bc
	push	de
	push	hl
	call	bbconout
	pop	hl
	pop	de
	pop	bc
	pop	af
	ret
	endif

zci:	;return keyboard character in [a]
	if	cpm
	push	bc
	push	de
	push	hl
	ld	c,rdcon
	call	bdos
	pop	hl
	pop	de
	pop	bc
	ret
	else
	push	bc
	push	de
	push	hl
	call	bbconin
	pop	hl
	pop	de
	pop	bc
	ret
	endif
;
;
;	;print a string in [de] up to '$'
pstring:
	if	cpm
	ld	c,print
	jp	bdos		;print message,
	else
	push	bc
	push	de
	push	hl
	ex	de,hl
pstrx:	ld	a,(hl)
	cp	'$'
	jp	z,donep
	ld	c,a
	call	zco
	inc	hl
	jp	pstrx
donep:	pop	hl
	pop	de
	pop	bc
	ret
	endif
;
;
showerrors:
	if	not debug
	or	a		;set nz flag
	scf			;set carry flag
	ret
	else
	call	zcrlf
	ld	e,regstatus	;get status in status register
	call	iderd8d
	ld	a,d
	and	1h
	jp	nz,moreerror	;go to  regerr register for more info
;				;all ok if 01000000
	push	af		;save for return below
	and	80h
	jp	z,not7
	ld	de,drive$busy	;drive busy (bit 7) stuck high.   status =
	call	pstring
	jp	doneerr
not7:	and	40h
	jp	nz,not6
	ld	de,drive$not$ready;drive not ready (bit 6) stuck low.  status =
	call	pstring
	jp	doneerr
not6:	and	20h
	jp	nz,not5
	ld	de,drive$wr$fault;drive write fault.    status =
	call	pstring
	jp	doneerr
not5:	ld	de,unknown$error
	call	pstring
	jp	doneerr
;
moreerror: ;get here if bit 0 of the status register indicated a problem
	ld	e,regerr	;get error code in regerr
	call	iderd8d
	ld	a,d
	push	af

	and	10h
	jp	z,note4
	ld	de,sec$not$found
	call	pstring
	jp	doneerr
;
note4:	and	80h
	jp	z,note7
	ld	de,bad$block
	call	pstring
	jp	doneerr
note7:	and	40h
	jp	z,note6
	ld	de,unrecover$err
	call	pstring
	jp	doneerr
note6:	and	4h
	jp	z,note2
	ld	de,invalid$cmd
	call	pstring
	jp	doneerr
note2:	and	2h
	jp	z,note1
	ld	de,trk0$err
	call	pstring
	jp	doneerr
note1:	ld	de,unknown$error1
	call	pstring
	jp	doneerr
;
doneerr:pop	af
	push	af
	call	zbits
	call	zcrlf
	pop	af
	or	a		;set z flag
	scf			;set carry flag
	ret
	endif

;
;------------------------------------------------------------------
; print a 16 bit number in ram located @ [hl] (note special low byte first)
;
printparm:
	push	hl
	pop	de
	ld	b,(hl)
	inc	hl
	ld	c,(hl)
	ld	a,c
	call	phex
	ld	a,b
	call	phex
	ld	c,' '
	call	zco
	ld	c,'('
	call	zco
	push	de
	pop	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	call	bn2a16
	call	pstring
	ld	c,')'
	call	zco
	ret
;
; print an 8 bit number, located in [a]

phex:	push	af
	push	bc
	push	af
	rrca
	rrca
	rrca
	rrca
	call	zconv
	pop	af
	call	zconv
	pop	bc
	pop	af
	ret
;
zconv:	and	0fh		;hex to ascii and print it
	add	a,90h
	daa
	adc	a,40h
	daa
	ld	c,a
	call	zco
	ret

;display bit pattern in [a]
;
zbits:	push	af
	push	bc
	push	de
	ld	e,a
	ld	b,8
bq2:	sla	e		;z80 op code for sla a,e
	ld	a,18h
	adc	a,a
	ld	c,a
	call	zco
	djnz	bq2
	pop	de
	pop	bc
	pop	af
	ret

	;get cpm style track# & sector# data and convert to lba format
ghex32lba:
	ld	de,enter$secl	;enter sector number
	call	pstring
	call	gethex		;get 2 hex digits
	ret	c
	ld	(fsecbuf),a	;note: no check data is < maxsec, sectors start 0,1,2,3....
	call	zcrlf

	ld	de,enter$trkh	;enter high byte track number
	call	pstring
	call	gethex		;get 2 hex digits
	ret	c
	ld	(ftrkbuf+1),a
	call	zcrlf

	ld	de,enter$trkl	;enter low byte track number
	call	pstring
	call	gethex		;get 2 more hex digits
	ret	c
	ld	(ftrkbuf),a
	call	zcrlf
	xor	a
	or	a		;to return nc
	ret
;
;
GETHEX:
	call	getcmd		;get a character from keyboard & echo
	cp	esc
	jp	z,hexabort
	cp	'/'		;check 0-9, a-f
	jp	c,hexabort
	cp	'F'+1
	jp	nc,hexabort
	call	asbin		;convert to binary
	rlca			;shift to high nibble
	rlca
	rlca
	rlca
	ld	b,a		;store it
	call	getcmd		;get 2nd character from keyboard & echo
	cp	esc
	jp	z,hexabort
	cp	'/'		;check 0-9, a-f
	jp	c,hexabort
	cp	'F'+1
	jp	nc,hexabort
	call	asbin		;convert to binary
	or	b		;add in the first digit
	or	a		;to return nc
	ret
hexabort:
	scf			;set carry flag
	ret
;
;
getcmd:	call	zci		;get a character, convert to uc, echo it
	call	upper
	cp	esc
	ret	z		;don't echo an esc
	if	not cpm
	push	af		;save it
	push	bc
	ld	c,a
	call	zco		;echo it
	pop	bc
	pop	af		;get it back
	endif
	ret
;
;				;convert lc to uc
upper:	cp	'a'		;must be >= lowercase a
	ret	c		; else go back...
	cp	'z'+1		;must be <= lowercase z
	ret	nc		; else go back...
	sub	'a'-'A'		;subtract lowercase bias
	ret
;
	;ascii to binary conversion routine
asbin:	sub	30h
	cp	0ah
	ret	m
	sub	07h
	ret



hexdump:			;print a hexdump of the data in the 512 byte buffer (@dma)
	push	af
	push	bc
	push	de
	push	hl

; 	ld	hl,buffer
	push	hl
	ld	de,511
	add	hl,de
	ld	e,l
	ld	d,h
	pop	hl
	call	memdump

	pop	hl
	pop	de
	pop	bc
	pop	af
	ret

ihexdump:			;print a hexdump of the data in the 512 byte buffer (@dma)
	push	af
	push	bc
	push	de
	push	hl

	ld	hl,idbuffer
	ld	de,idbuffer+511
	call	memdump


	pop	hl
	pop	de
	pop	bc
	pop	af
	ret
;
;
;;
;; Routines for binary to decimal conversion
;;
;; (C) Piergiorgio Betti <pbetti@lpconsul.eu> - 2006
;;
;; The active part is taken from:
;; David Barrow - Assembler routines for the Z80
;; CENTURY COMMUNICATIONS LTD - ISBN 0 7126 0506 1
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
;; generic storage

ival16:	defs	2
oval16:	defs	6

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
	ld	(hl),'$'
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
	ld	(hl),'$'
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

;;
;; memdump - prompt user and dump memory area
;
memdump:
	ld	b,255	; row counter, for the sake of simplicity
	ld	a,b
	ld	(bsave),a
	ld	(dmasave),hl
mdp6:
	push	hl
	ld	hl,(dmasave)
	ld	c,l
	ld	b,h
	pop	hl
	push	hl
	sbc	hl,bc
	call	hl2ascb
	pop	hl
	ld	a,l
	call	dmpalib
	push	hl
mdp2:	ld	a,(hl)
	call	h2aj1
	call	chkeor
	jr	c,mdp1
	call	spacer
	ld	a,l
	and	$0f
	jr	nz,mdp2
mdp7:	pop	hl
	ld	a,l
	and	$0f
	call	dmpalia
mdp5:	ld	a,(hl)
	ld	c,a
	cp	$20
	jr	c,mdp3
	jr	mdp4
mdp3:	ld	c,$2e
mdp4:	call	zco
	call	chkbrk
	ld	a,l
	and	$0f
	jr	nz,mdp5
	jr	mdp6
mdp1:	sub	e
	call	dmpalib
	jr	mdp7

;;
cbkend:	pop	de
	ret
chkbrk:
	call	chkeor
	jr	c,cbkend
	ld	a,(dmppause)
	or	a
	jr	z,chkbrk1
	ld	a,(bsave)
	ld	b,a
	dec	b
	call	z,wpause
	ld	a,b
	ld	(bsave),a
	ret
chkbrk1:
	call	zcsts
	or	a
	ret	z
	call	coiupc
	cp	$13
	jr	nz,cbkend
; 	jp	coiupc
;;
;;
;; coiupc- convert reg a uppercase
coiupc:
	call	zci
	cp	$60
	jp	m,coire
	cp	$7b
	jp	p,coire
	res	5,a
coire:	ret

;;
wpause:
	ld	de,wpausemsg
	call	pstring
	call	zci
	jr	cbkend
;;
;; dmpalib - beginning align (spacing) for a memdump
dmpalib:
	and	$0f
	ld	b,a
	add	a,a
	add	a,b
;;
;; dmpalib - ascii align (spacing) for a memdump
dmpalia:
	ld	b,a
	inc	b
alibn:	call	spacer
	djnz	alibn
	ret
;;
;; hl2asc - convert & display hl 2 ascii
hl2asc:
	call	zcrlf
h2aen1:	ld	a,h
	call	h2aj1
	ld	a,l
h2aj1:	push	af
	rrca
	rrca
	rrca
	rrca
	call	h2aj2
	pop	af
h2aj2:	call	nib2asc
	call	zco
	ret
; h2aj3:	call	h2aj1           ; entry point to display hex and a "-"
hl2ascb:
	call	hl2asc
spacer:	ld	c,$20
	call	zco
	ret
;;
;; nib2asc convert lower nibble in reg a to ascii in reg c
;
nib2asc:
	and	$0f
	add	a,$90
	daa
	adc	a,$40
	daa
	ld	c,a
	ret
;;
;; inc hl and do a 16 bit compare between hl and de
chkeor:
	inc	hl
	ld	a,h
	or	l
	scf
	ret	z
	ld	a,e
	sub	l
	ld	a,d
	sbc	a,h
	ret
	
trkset:
	ld	(ftrkbuf),bc
	ret
secset:
	ld	(fsecbuf),bc
	ret
dmaset:
	ld	(frdpbuf),bc
	ret
	
;######################################################################	


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

; 	extern	bbhdinit, bbldpart, bbsysint
; 	extern	bbuziboot, bbconin, bbconout
; 	extern	bbdprmset, bbtrkset, bbdsksel
; 	extern	bbfdrvsel, bbfhome, bbdmaset
; 	extern	bbsecset, bbfread, bbrdvdsk
; 	extern	bbhdrd, bbhdrd, bbhdinit
; 	extern	bbldpart

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
	call	dsksel
	ld	bc,bldoffs		; read in loader @ BLDOFFS
	call	bbdmaset
	ld	bc,$00
	call	bbtrkset
	ld	bc,$00
	call	bbsecset
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

dsksel:
	push	de
	ld	a,c
	cp	'C'-'A'			; is floppy ?
	jp	m,dsksel1		; yes
	cp	'M'-'A'			; is special
	jp	p,dsksel1		; yes	
	
	cp	'H'-'A'			; which hd unit?
	jp	p,dskselhd1		; < H unit 0 (CDEFG)
	ld	d,0			; sel drive 0
	call	loghdrv
	jr	dsksel1
dskselhd1:
	ld	d,1			; >= H unit 1 (HIJKL)
	call	loghdrv	
dsksel1:	
	pop	de
	ld	(fdrvbuf),a
	ret


;;
;; Handle CP/M type bootstrap
;;
;; A = drive
;;

cpmboot:
	ld	b,a
	ld	c,02h			; reset input case
	call	bbconout
	ld	a,b
; 	ld	a,(asav)

cpmdboot:
	cp	'A'			; is  a valid drive ?
	jp	m,drvidw		; no < A
	cp	'Q'
	jp	p,drvidw		; no > P

	sub	'A'			; makes a number
	ld	(fdrvbuf),a		; is valid: store in monitor buffer
	ld	(cdisk),a		; and in CP/M buf

	cp	'C'-'A'			; is floppy ?
	jp	m,doflp			; yes

	cp	'M'-'A'			; is hard disk ?
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
	jp	z,bmuzi
	cp	'C'
	jr	z,bmcpm
bminv:
	call	inline
	defb	cr,lf,"Invalid selection",cr,lf,0
	ret

bmcpm:
	call	inline
	defb	cr,lf,"Enter drive (<AB> floppy, <C-L> HD, <MN> special <OP> virtual): ",0
	ld	c,SI_EDIT
	ld	e,SE_STR
	ld	d,1
	call	bbsysint
	or	a
	jr	nz,bminv
	call	inline
	defb	cr,lf,"Boot..",cr,lf,0
	ld	a,(iedtbuf)
; 	call	cpmdboot
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
; 	call	uzidboot
	ret


;----- EOF -----
;######################################################################	
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
trn_mount	equ	false		; mount banked buffer


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
	
sel_loggedhd:
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
	ret	z			; got "00000000" if not present
	

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
	if	trn_mount
	; Mount transient page used for id buffer
	ld	b, trnpag
	call	mmgetp
	ld	(idtsav), a		; save current
	;
	ld	a,(hmempag)		; bios scratch page (phy)
	ld	b,trnpag		; transient page
	call	mmpmap			; mount it
	endif
	;
	call	idewaitnotbusy
	jr	c,idrnok

	call	sel_loggedhd
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
	call	sel_loggedhd
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
	if	trn_mount
	ld	a,(idtsav)		; old
	ld	b,trnpag		; transient page
	call	mmpmap			; mount it
	endif
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
	if	trn_mount
	ld	b, trnpag
	call	mmgetp
	ld	(idtsav), a		; save current
	;
	ld	a,(hmempag)		; bios scratch page (phy)
	ld	b,trnpag		; transient page
	call	mmpmap			; mount it
	endif
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
	call	sel_loggedhd		; m/s
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
	call	sel_loggedhd		; m/s
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
	jr	z,trkof0
	ld	iy,partbl1-entrysize	; point to table 0, back one slot
trkof0:	ld	a,c			; restore drive letter
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
	call	sel_loggedhd		; m/s
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
	call	sel_loggedhd
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

;
; -------------------------------------------------------------------------------------------------
;
sign$on:	db	CR,LF,'IDE Disk Drive Test Program (V2.0) (Using CPM3 BIOS Routines)',CR,LF
		db	'cpm Track,Sectors --> LBA mode',CR,LF,'$'
init$error:	db	'Initilizing Drive Error.',CR,LF,'$'
id$error:	db	'Error obtaining Drive ID.',CR,LF,'$'
init$dr$ok:	db	'Drive Initilized OK.',CR,LF,LF,'$'
msgmdl:		db	'Model: $'
msgsn:		db	'S/N:   $'
msgrev:		db	'Rev:   $'
msgcy:		db	'Cylinders: $'
msghd:		db	', Heads: $'
msgsc:		db	', Sectors: $'
hdcurmsg:	db	'HD UNIT = $'
msgcpmtrk:	db	' CPM TRK = $'
msgcpmsec:	db	' CPM SEC = $'
msglba:		db	'  (LBA = 00$'
msgbracket	db	')$'
                
                
cmd$string1: 	db	CR,LF,LF,'                 MAIN MENU',CR,LF
		db	'(L) Set LBA value  (R) Read Sector to Buffer  (W) Write Buffer '
		db	'to Sector',CR,LF
		db	'(D) Display ON     (S) Sequental Sec Read     (F) Format Disk',CR,LF
		db	'(V) Read N Sectors (Z) Write N Sectors        (B) Backup disk',CR,LF
		db	'(G) Restore Backup (X) Change HD Unit         (K) Reset',CR,LF
		db	'(U) Power Up       (N) Power Down             (ESC) Quit',CR,LF,LF
		db	lf,'Current: $'
                
cmd$string2: 	db	CR,LF,LF,'                 MAIN MENU',CR,LF
	 	db	'(L) Set LBA value  (R) Read Sector to Buffer  (W) Write Buffer '
		db	'to Sector',CR,LF
		db	'(D) Display OFF    (S) Sequental Sec Read     (F) Format Disk',CR,LF
		db	'(V) Read N Sectors (Z) Write N Sectors        (B) Backup disk',CR,LF
		db	'(G) Restore Backup (X) Change HD Unit         (K) Reset',CR,LF
		db	'(U) Power Up       (N) Power Down             (ESC) Quit',CR,LF,LF
		db	'current settings:- $'

prompt:		db	CR,LF,LF,'Please enter command >$'
msgsure:	db	CR,LF,'Warning: this will change data on the drive, '
		db	'are you sure? (Y/N)...$'
msgrd:		db	CR,LF,'Sector Read OK',CR,LF,'$'
msgwr:		db	CR,LF,'Sector Write OK',CR,LF,'$'
get$lba:	db	'Enter CPM style TRK & SEC values (in hex).',CR,LF,'$'
sec$rw$error	db	'Drive Error, Status Register = $'
err$reg$data	db	'Drive Error, Error Register = $'
enter$secl	db	'Starting sector number,(xxH) = $'
enter$trkl	db	'Track number (LOW byte, xxH) = $'
enter$trkh	db	'Track number (HIGH byte, xxH) = $'
enter$head	db	'Head number (01-0f) = $'
enter$count	db	'Number of sectors to R/W = $'
drive$busy	db	'Drive Busy (bit 7) stuck high.   Status = $'
drive$not$ready	db	'Drive Ready (bit 6) stuck low.  Status = $'
drive$wr$fault	db	'Drive write fault.    Status = $'
unknown$error	db	'Unknown error in status register.   Status = $'
bad$block	db	'Bad Sector ID.    Error Register = $'
unrecover$err	db	'Uncorrectable data error.  Error Register = $'
read$id$error	db	'Error setting up to read Drive ID',CR,LF,'$'
sec$not$found	db	'Sector not found. Error Register = $'
invalid$cmd	db	'Invalid Command. Error Register = $'
trk0$err	db	'Track Zero not found. Error Register = $'
unknown$error1	db	'Unknown Error. Error Register = $'
continue$msg	db	CR,LF,'To Abort enter ESC. Any other key to continue. $'
format$msg	db	'Fill sectors with 0H (e.g for CPM directory sectors).$'
readn$msg	db	CR,LF,'Read multiple sectors from current disk/CF card to RAM buffer.'
		db	cr,lF,'How many 512 byte sectores (xx HEX):$'
writen$msg	db	CR,LF,'Write multiple sectors RAM buffer current disk/CF card.'
		db	cr,lF,'How many 512 byte sectores (xx HEX):$'
readingn$msg	db	CR,LF,'Reading Sector at:- $'
writingn$msg	db	CR,LF,'Writing Sector at:- $'
msgerr		db	CR,LF,'Sorry, that was not a valid menu option!$'
formatdone	db	CR,LF,'Disk Format Complete.',CR,LF,'$'
backupdone	db	CR,LF,'Disk partition copy complete.',CR,LF,'$'
copymsg		db	CR,LF,'Copy disk partition to a second area on disk (CF card).'
		db	CR,LF,'>>> This assumes that tracks greater than MAXTRK '
		db	'(for cPM, 0FFH) are unused <<<'
		db	CR,LF,'>>> on this disk. Be sure you have nothing in this '
		db	'"backup partition area". <<<'
		db	CR,LF,BELL,'Warning: This will change data in the partition area, '
		db	'are you sure? (Y/N)...$ '
atend		db	CR,LF,'At end of disk partition!',CR,LF,'$'
rbackup$msg	db	'Reading track: $'
wbackup$msg	db	'H. Writing track: $'
h$msg		db	'h$'
restoremsg	db	CR,LF,'Restore disk with data from backup partition on disk (CF card).'
		db	CR,LF,BELL,'Warning: This will change data on disk, '
		db	'are you sure? (Y/N)...$ '
restoredone	db	CR,LF,'Restore of disk data from backup partition complete.',CR,LF,'$'
wpausemsg	db	CR,LF,'-- More -- $'
dbgstmpre	db	'Pre status: $'
dbgstmpst	db	'  Post status: $'
; -------------------------- RAM usage ----------------------------------------
ramarea		db	'           RAM STORE AREA -------->'		;useful for debugging
asav		dw	0
@drive$sec	db	0h
@drive$trk	dw	0h
@displayflag	db	0ffh		;display of sector data initially on
dmasave		dw	0h
bsave		dw	0
;
@sec1		dw	0h		;for disk partition copy
@trk1		dw	0h
@sec2		dw	0h
@trk2		dw	0h
startlinehex	dw	0h
startlineascii	dw	0h
bytecount	dw	0h
seccount	dw	0h
;
dmppause	db	0h
dbgstat		db	0h
;
delaystore	db	0h
;
		ds	40h
stack		dw	0h

 	org	$2700
;
idbuffer	ds	512
;
buffer		db	76h					;put a z80 halt instruction here in case we
								;jump to a sector in error
		db	"<--Start buffer area"			;a 512 byte buffer
		ds	476
		db	"end of buffer-->"
;
	END



