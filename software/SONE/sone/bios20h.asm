;
;********************************************************
;*							*
;*	    UNIVERSAL BASIC I/O SYSTEM (BIOS)		*
;*		       Vers. 1.8			*
;*							*
;*     A,B = 5 Inc. 32,10 sec/trk 256 byte/sec		*
;*     C,D = 5 Inc. 32,10 sec/trk 256 byte/sec		*
;*     E,F = 5 Inc. 17 sec/trk	  128 byte/sec (old Lg)	*
;*							*
;*    nota: aggiungere diagnostica errori in fdd i/o	*
;*							*
;********************************************************
;
	title	Bios 2.0 for NE CP/M 2.2 with Hard-Disk Basf 6188
;	subttl	Copyright Studio Lg, Genova - Last rev 15/08/1984 09:06
;	Programmers: Martino Stefano & Gallarani Paolo
;
	; Disassembly/retype Piergiorgio Betti & Pino Giaquinto 2015/04/25
	;
	include sysent.asm		; read in os allocation
	include const.asm		; read in system constants
;
;
;********************************************************
;*							*
;*	    UNIVERSAL BASIC I/O SYSTEM (BIOS)		*
;*		       Vers. 2.0			*
;*							*
;*                     System IPL			*
;*							*
;********************************************************
;
; 	subttl	IPL for NE BIOS 2.0 with Hard-Disk BASF 6188
;	Programmers: Martino Stefano & Gallarani Paolo
;
;
;********************************************************
;*							*
;*		IPL for NEW BIOS			*
;*							*
;********************************************************
;
;	this program loaded in ram by rom boot, load the cp/m
;	bios, set bios sysflag and go to wboote
;
;
;	subttl	IPL for NE BIOS 1.8 with Hard-Disk BASF 6188
;
	aseg
	.phase ipl			; origin of IPL
;
;
wdbboot:
	; entry point for bios boot from hard disk
	jp	wdbbt1			; jump to hard bios boot
;
fdbboot:
	; entry point for bios boot from floppy disk
	jp	fdbbt1			; jump to floppy bios boot
iplmsg:
	; message for ipl checking
	defb	'IPL'
;
;
wdbbt1:
	; load bios from hard disk
	ld	hl,bbtdsk		; H.L = bios boot r/w para pointer
	call	wdio			; read bios
	or	a			; read error ?
	jr	nz,bbterr		; yes, then reinitialize system
					; A = 0 because not error occurs
bbtok:
	; bios has been loaded
	ld	(sysflag),a		; set bios system flag
	ld	ix,vidareas		; init video table
	call	vidinit
	ld	hl,iobyte		; point to iobyte
	ld	(hl),DftI.O		; value for i/o byte (lst:=lpt:)
	inc	hl			; point to logdsk
	ld	(hl),0			; set cp/m logical disk = 0
	ld	de,cpmmsg		; D.E = cp/m message
	call	strout			; print it
	jp	wboote			; jump to bios wboote
	;
	; error in reading BIOS
	;
bbterr:
	ld	de,bbtermsg		; D.E = bios boot error message
	call	strout			; print it
	wait1cr:
	call	cin			; wait one char.
	cp	cr			; cr ?
	jr	nz,wait1cr		;
	;
fdbbt1:
	jp	bootrom			; load IPL from FDD ?
;
;
	; bios boot r/w para table (initially for wdd)
;
bbtdsk:	defb	0			; dsk-0 sid 0
bbttrk:	defw	0			; cylinder number
bbtsec:	defb	24			; secor number (for wdd)
bbtdma:	defw	bios			; bios start address
btprw:	defb	0			; read operation
;
wdbloc:	defb	biossiz			; for wdd boot (6 sec. to load)
;
bbtxlt:
	; sector translate table for floppy disk (256 byte/sec)
	; the first two sector are occuped by ccp + bdos
	; than bbtxlt starts at 4' sector
	;
	defb	9,5,2,8,4,10
;
cpmmsg:
	defb	ffeed,cr,lf,lf,pfx,'H',(cmsize+1)/10+'0',(cmsize+1) mod 10+'0','K N.E. New Disk System - '
	defb	'vers ',high vers,low vers
	defb	' rev ',rev/10+'0','.',rev mod 10+'0',pfx,'@'
	defb	cr,lf,bell,endmsg
;
;
bbtermsg:
	defb	bell,cr,lf,'Cannot load your BIOS.'
	defb	cr,lf,'Set new system diskette in disk A,'
;
	defs	wdbboot+256-$	; free space on IPL ram
;
	.dephase
;
;********************************************************
;*							*
;*		CP/M 2 Operating System			*
;*							*
;********************************************************
;
if asmcpm
	include ccpbdos.asm
endif
;
;********************************************************
;*							*
;*			BIOS				*
;*							*
;********************************************************
;
;	jump vector for individual subroutines
;
	.phase	bios		; origin of this program
;
	jp	boot		; cold start
wboote:
	jp	wboot		; warm start
	jp	const		; console status
	jp	conin		; console character in
	jp	conout		; console character out
	jp	listd		; list character out
	jp	punch		; punch character out
	jp	reader		; reader character in
	jp	home		; move head to home position
	jp	seldsk		; select disk
	jp	settrk		; set track number
	jp	setsec		; set sector number
	jp	setdma		; set dma address
	jp	read		; read disk
	jp	write		; write disk
	jp	listst		; return list status
	jp	sectran		; sector translate
;
;
;
;********************************************************
;* D P B T A B L E					*
;*							*
;*	W/F  Size  B/S   S/T  Trk  Hds  R/T  Capacity	*
;* -	--- ------ ---   --   ---  ---  --- ---------	*
;* A: = wdd   5"   256	 32   360			*
;* B: = wdd   5"   256	 32   360			*
;* C: = fdd   5"   256	 10				*
;* D: = fdd   5"   256	 10				*
;* E: = fdd   5"   128	 17				*
;* F: = fdd   5"   128	 17				*
;*							*
;********************************************************
;
;
dpbase	equ	$	; base of disk parameter header
;
	; dpe0,dpe1 = disk parameter header for hard disk
dpe0:
	defw	xlt0, 0000h	; no translate table
	defw	0000h, 0000h	; scratch area
	defw	dirbuf, dpb0	; dir buff, parm block
	defw	csv0, alv0	; check, alloc vector
dpe1:
	defw	xlt0, 0000h	; no translate table
	defw	0000h, 0000h	; scratch area
	defw	dirbuf, dpb01	; dir buff, parm block
	defw	csv1, alv1	; check, alloc vector
;
	; dpe2,dpe3 = disk parameter header for floppy disk (256 byte/sec)
dpe2:	; 256 byte/sec - Single Side
	defw	xlt1, 0000h	; translate table
	defw	0000h, 0000h	; scratch area
	defw	dirbuf,dpb1	; dir buff,parm block
	defw	csv2,alv2	; check,alloc vector
	;
dpe3:	; 256 byte/sec - Single Side
	defw	xlt1,0000h	; translate table
	defw	0000h,0000h	; scratch area
	defw	dirbuf,dpb12	; dir buff,parm block
	defw	csv3,alv3	; check,alloc vector
;
	; dpe4,dpe5 = disk parameter header for floppy disk (128 byte/sec)
dpe4:	; 128 byte/sec - Single Side
	defw	xlt2,0000h	; translate table
	defw	0000h,0000h	; scratch area
	defw	dirbuf,dpb2	; dir buff,parm block
	defw	csv4,alv4	; check,alloc vector
	;
dpe5:	; 128 byte/sec - Single Side
	defw	xlt2,0000h	; translate table
	defw	0000h,0000h	; scratch area
	defw	dirbuf,dpb2	; dir buff,parm block
	defw	csv5,alv5	; check,alloc vector
;
;
xlt0	equ	0		; no sector translate for hard disk
;
xlt1:
	; sector translate table for floppy disk (256 byte/sec)
	defb	1,2,13,14,5,6,17,18,9,10,3,4,15,16,7,8,19,20,11,12
	defb	21,22,33,34,25,26,37,38,29,30,23,24,35,36,27,28,39,40,31,32
;
xlt2:
	; sector translate table for floppy disk (128 byte/sec)
	defb	1,7,13,2,8,14,3,9,15
	defb	4,10,16,5,11,17,6,12
;
;
dpb0:
	; disk parameter block for hard disk 0 (256 byte/sector 1 res. trk)
	defw	128		; SPT (sec/trk) (32 sect * (256/128) * 2 side)
	defb	5		; BSH
	defb	31		; BLM
	defb	1		; EXM (extent mask)
	defw	1435		; DSM (disk size in BLS units - 1) (5740 kbyte)
	defw	1023		; DRM (directory elements - 1)
	defb	11111111b	; AL0
	defb	00000000b	; AL1
	defw	0		; CKS disk fixed, no dir. check vector
	defw	1		; OFF (track offset)
;
dpb01:
	; disk parameter block for hard disk 1 (256 byte/sector no res. trk)
	defw	128		; SPT (sec/trk) (32 sect * (256/128) * 2 side)
	defb	5		; BSH
	defb	31		; BLM
	defb	1		; EXM (extent mask)
	defw	1439		; DSM (disk size in BLS units - 1) (5756 kbyte)
	defw	1023		; DRM (directory elements - 1)
	defb	11111111b	; AL0
	defb	00000000b	; AL1
	defw	0		; CKS disk fixed, no dir. check vector
	defw	0		; OFF (track offset)
;
;
dpb1:
	; disk parameter block for floppy disk
	; 256 byte/sector - Single Side
	defw	20		; SPT (sec/trk) (10 sect * (256/128) * 1 side)
	defb	4		; BSH
	defb	15		; BLM
	defb	1		; EXM (extent mask)
	defw	45		; DSM (disk size in BLS unit) (90 kbyte)
	defw	63		; DRM (directory elements - 1)
	defb	10000000b	; AL0
	defb	00000000b	; AL1
	defw	16		; CKS = (DRM + 1)/4 (size dir. check vect.)
	defw	3		; OFF (track offset)
;
dpb12:
	; disk parameter block for floppy disk
	; 256 byte/sector - Single Side
	defw	40		; SPT (sec/trk) (10 sect * (256/128))
	defb	4		; BSH
	defb	15		; BLM
	defb	1		; EXM (extent mask)
	defw	94		; DSM (disk size in BLS unit) (90 kbyte)
	defw	63		; DRM (directory elements - 1)
	defb	10000000b	; AL0
	defb	00000000b	; AL1
	defw	16		; CKS = (DRM + 1)/4 (size dir. check vect.)
	defw	2		; OFF (track offset)
;
;
dpb2:
	; disk parameter block for floppy disk (128 byte/sector)
	defw	17		; SPT (SEC/trk)
	defb	3		; BSH
	defb	7		; BLM
	defb	0		; EXM (extent mask)
	defw	77		; DSM (disk size in BLS unit) (77 kbyte)
	defw	31		; DRM (directory elements - 1)
	defb	10000000b	; AL0
	defb	00000000b	; AL1
	defw	8		; CKS = (DRM + 1)/4 (size dir. check vect.)
	defw	3		; OFF (track offset)
;
;
;
;********************************************************
;* B O O T						*
;*		Exec a Cold Boot			*
;********************************************************
;
boot:
	; set A = sysflag and go to bootrom
	ld	a,(sysflag)	; if A = 0 then load IPL from WDD
	jp      bootrom		; else from FDD
;
;
;
;********************************************************
;* W B O O T						*
;*		Load bdos + ccp				*
;*		From wdd or Single/Side Fdd		*
;********************************************************
;
wboot:
	ld	sp,stack	; set stack pointer
	call	WrtPng		; Write any pending sector
	ld	hl,CurDsk	; point to cp/m log disk
	ld	a,(hl)		; load cp/m logical disk
	and     00001111b	; mask out User
	cp	maxdsk		; disk overflow ?
	jr	c,wb_1		; no, then go to wboot
wb_0:
	ld	(hl),0		; else clear cp/m log disk
				; H=0
wb_1:
	; Set parameter,
	; then load from Hard or Floppy Disk
	ld	hl,0		; HL=0
	ld	(PrePhy),hl	; Dsk 0 - side 0 & low Track=0
	ld	h,2		; Sector #2
	ld	(PreTrk+1),hl	; Set High Trk=0 & Sector #2
	ld	h,cpmsiz	; ccp + bdos size in sector number
	ld	(PreR.W),hl	; set Read op. and # of sec (for wdd)
	ld	hl,ccp		; Cp/m starting add
	ld	(PreDma),hl	; set it
	;
	; Hard or Floppy ?
	;
	ld	a,(sysflag)	; load system flag
	or	a		; sysflag = 0 ?
	jr	nz,fd_wb	; no, load from floppy
wd_wb:
	; load from hard disk
	ld	hl,PrePhy	; H.L = wdd boot para adrs
	call	wdio		; call wdd read
	or	a		; wdd i/o error ?
	jr	nz,exboot	; yes, then retry
	jr	syschk		; no, then go to system check
;
fd_wb:
	; load cp/m from floppy disk
	ld	b,cpmsiz	; ccp + bdos size in sector number
	ld	de,wbxlt+1	; D.E = sector translate table
fd_wb.3:
	push	bc		; save sector count
	push	de		; save xlt1 pointer
	ld	a,(de)		; load physical sector
	ld	(PreSec),a	; set physical sector number
	ld	hl,PrePhy	; H.L = boot para adrs
	call	fdiod		; read 256 byte
	pop	de		;
	pop	bc		;
	or	a		; read error ?
	jr	nz,exboot	; yes, then retry
	ld	hl,PreDma+1	; HL = high current dma adrs
	inc	(hl)		; DMA=DMA+256
	dec	b		; warm boot end ?
	jr	z,syschk	; yes, then go to system check
	inc	de		; xlt1 pointer + 1
	ld	a,e		;
	cp	low (wbxlt+fddsec); end of track ?
	jr	nz,fd_wb.3	; no, load next sector
	ld	hl,PreTrk	; H.L = track para adrs
	inc	(hl)		;track = track + 1
	ld	de,wbxlt	; point to start xlt table
	jr	fd_wb.3		; load first sector to next track
	;
	; CP/M has been loaded
syschk:
	; cp/m system check
	ld	a,(ccp+2)	; load third data of cp/m
	cp	high (ccp+35Ch)	; check for correct jp andress
	jr	nz,exboot	; no, error
	ld	a,0c3h		; jump command
	ld	(0000),a	; location 0000h
	ld	hl,wboote	; wboot address
	ld	(0001),hl	;
	ld	(0005),a	; location 0005h
	ld	hl,bdos		; bdos address
	ld	(0006),hl	;
	ld	a,0ffh		; A = 0ffh
	ld	(PreDsk),a	; Physic disk para -> 'ff'
	ld	hl,defbuf	; Default Buffer
	ld	(PreDma),hl	; set it
	ld	bc,defldma	; BC = default dma adrs
	call	setdma		; cp/m dma = 0080h
	ld	a,(CurDsk)	; load cp/m Default disk
	ld	c,a		;
	jp	ccp		; and jump to ccp
	;
	defs	20		; free space
;
wbxlt:
	defb	1,7,3,9,5,2,8,4,10,6
;
;
exboot:
exbot1:
	ld	de,nosysmsg	; D.E = no system message
	call	msgcr		; print it and wait cr
	jp	wb_1		; retry boot
;
;
;
;********************************************************
;*							*
;*	*** Logical Peripheral Device Sub ***		*
;*							*
;********************************************************
;
;
;********************************************************
;* C o n S t						*
;*	Return console status (A=-1 if char ready)	*
;********************************************************
;
const:
	ld	a,(iobyte)	; load intel i/o byte
	and	00000011b	; mask bit 0,1
	cp	2		;
	jp	c,csts		; jump rom console status
	jr	notdev		; jump no device
;
;
;********************************************************
;* C o n I n						*
;*	Read char from console				*
;********************************************************
;
conin:
	ld	a,(iobyte)	; load intel i/o byte
	and	00000011b	; mask bit 0,1
	cp	2		;
	jr	nc,notdev	; >1, no device
				;
	push	IX		; preserve IX for Z80's prgm
	call	cin		; rom console input
	pop	IX		; restore
	ret			; done
;
;
;********************************************************
;* C o n O u t						*
;*	Write C caracter on console			*
;********************************************************
;
conout:
	ld	a,(iobyte)	; load intel i/o byte
	and	00000011b	; mask bit 0,1
	cp	2		; >1, then
	jr	nc,notdev	; jump no device
				;
	push	IX		; Save
	push	IY		;	Register
	call	cout		; call console output
	pop	IY		; Restore
	pop	IX		;	Registers
	ret			; done
;
;
;
;********************************************************
;*	P R I N T E R   S u b r o u t i n e		*
;********************************************************
;
;
;********************************************************
;* L i s t						*
;*	Write C caracter on printer			*
;********************************************************
;
listd:
	ld	a,(iobyte)	; load intel i/o byte
	and	11000000b	; mask bit 6,7
	cp	080h		;
	jp	c,cout		; jump rom console output
	jp	z,lout		; jump printer output
	ret			; no device, data lost
;	jr	notdev		; jump no device
;
;********************************************************
;* L i s t S t						*
;*	Return printer status				*
;********************************************************
;
listst:
	ld	a,(iobyte)	; load intel i/o byte
	and	11000000b	; mask bit 6,7
	cp	080h		;
	jp	c,csts		; jump rom console status
	jp	z,lsts		; jump printer status
	ret			; no device, now ret 11000000b
	;jr	notdev		; jump no device
;
;
;
;********************************************************
;* S E R I A L   D E V I C E S   S u b r o u t i n e	*
;********************************************************
;
;
;********************************************************
;* P u n c h						*
;*	Puncher output					*
;********************************************************
;
punch:
	if	PUN		; if PUNcher exists
	ld	a,(iobyte)	; load intel i/o byte
	and	00110000b	; mask bit 4,5
	cp	00010000b	;
	jp	c,cout		; = TTY: jump rom console output
				; = PTP:
	jp	nz,notdev	; else no device exist
	jp	0000		; spare jump
	; start of PTP: dev subroutine
	ret
	else			; no puncher devices
	ret			; data lost
	endif
;
;
;********************************************************
;* R e a d e r						*
;*	Reader input					*
;********************************************************
;
reader:
	if	RDR		; if ReaDeR exists
	ld	a,(iobyte)	; load intel i/o byte
	and	00001100b	; mask bit 2,3
	cp	00000100b	;
	jp	c,cin		; = TTY: jump rom console input
				; = PTR:
	jr	nz,notdev	; else no device exists
	; start of PTR: dev subroutine
	jump	0000		; spare jump
	ELSE			; if no device
	nop			;
	nop			;
	ld	a,'Z'-'@'	; set ^z = EOF
	ret			; end
	endif
;
notdev:
	; print not device message and go to cpm
	ld	a,DftI.O	; set default i/o byte
	ld	(iobyte),a	;
	ld	de,ndevmsg	; D.E = no device msg
	call	strout		; print it
	jp	wboot		; return to cp/m
;
;
;
;********************************************************
;*		Disk I/O Subroutine			*
;********************************************************
;
;
;********************************************************
;* S e l D s k						*
;*		Select logical disk from reg. C		*
;*		Ret HL=.DPB or 0 if error		*
;********************************************************
;
SelDsk:
	ld	hl,0		; return 0000h if error
	ld	a,c		;
	cp	maxdsk		; too large ?
	ret	nc		; leave HL = 0000
;
	ld	a,(sysflag)	; load system flag
	or	a		; if system flag = 0 then disk
	ld	a,c		;	 restore disk # on a
	jr	z,SDsk.1	; A,B = hard disk; C,D = floppy disk
	cp	wddsiz+fddsiz	; Disk # > D:
	jr	nc,SDsk.1	; yes, no exchange
	xor	00000010b	; A,B -> C,D and vice-versa
				; A,B = floppy disk; C,D = hard disk
SDsk.1:
	ld	(LogDsk),a	; set logical disk number
	ld	l,a		; L = disk number
	add	hl,hl		; HL = disk number * 16
	add	hl,hl		; HL = disk number * 16
	add	hl,hl		; HL = disk number * 16
	add	hl,hl		; HL = disk number * 16
	ld	de,dpbase	;
	add	hl,de		;H.L disk table adrs
	ret
;
;
;********************************************************
;* H O M E						*
;*		Select logical track 0			*
;********************************************************
;
Home:
	ld	bc,0		; Track #0000
;
;
;********************************************************
;* S e t T r k						*
;*		Select logical track from reg.s BC	*
;********************************************************
;
SetTrk:
;
	ld	(LogTrk),bc	; Save low and high byte
	ret			;
;
;
;********************************************************
;* S e t T r a n					*
;*		Translate the BC sector using trans	*
;*		table pointed by DE			*
;********************************************************
;
SecTran:
	ex	de,hl		; H.L = sectran table adrs
	ld	a,l		; check for -> 0000
	or	h		; this means no sec tran
	add	hl,bc		; compute sector (BC = sec num)
	jr	z,Strn_5	; no sec tran
	ld	l,(hl)		; get trans sector
	ld	h,0		; high = 0
	ret			; done
Strn_5:
	inc	l		; convert to base 1
	ret
;
;
;********************************************************
;* S e t S e c						*
;*		Set sector from registers BC		*
;********************************************************
;
SetSec:
	ld	a,c		; Only low byte
	ld	(LogSec),a	; because sector < 256
	ret			;
;
;
;********************************************************
;* S e t D M A						*
;*		Set DMA address from registers BC	*
;********************************************************
;
SetDMA:
	ld	(LogDMA),bc	; set logical DMA
	ret
;
;
;********************************************************
;* R e a d						*
;*		Read sector specified by prev param	*
;*		@ spec DMA (ret A=-1 if error)		*
;********************************************************
;
read:
	xor	a		; set disk read operation
	ld	c,wrual		; write type (to unallocated)
	jr	rw00		;
;
;
;********************************************************
;* W r i t e						*
;*		Write sector specified by prev param	*
;*		from spec DMA (ret A=-1 if error)	*
;********************************************************
;
write:
	ld	a,1		; set write operation
rw00:
	ld	(LogR.W),a	; set read or write operation
	ld	de,LogDsk	; DE. LogDsk
	ld	a,(de)		; A = Logical Disk number
	cp	wddsiz+fddsiz	; check for 256 byte/sec dsk
	jr	c,RW256		; yes, jump to it
;
;
;********************************************************
;* R W 1 2 8	- 	Read o Write 128 byte/sec dsk	*
;*		Write pending sectors			*
;*		just read or write sector		*
;*		set no sector buffered			*
;********************************************************
;
RW128:
	and	1		; mask bit 1 for unit select
	ld	(PhyDsk),a	; set Disk Unit & Side 0
	call	WrtPng		; Write Pending Sectors
	ld	a,(LogSec)	;
	ld	(PhySec),a	; Physical sector = Logical
RW128.1:
	ld	hl,PhyDsk	; Point to Operation Table
	call	fdios		; read o write 128 byte
	ld	hl,PreDsk	; Point to Sector Buffered tbl
	ld	(hl),0ffh	; set no sector buffered
	or	a		;fdd i/o error ?
	ret	z		; no, then normal return
	ld	de,ioerrmsg	; D.E = Disk err message
	call	strout		; print it
	call	cin		; wait one char.
	cp	cr		; is return ?
	jr	z,RW128.1	; yes, then retry
	cp	'C'-'@'		; is cntrl C ?
	jp	z,wboot		; yes, wboot
	ld	a,1		; Set error
	or	a		; set flag
	ret			; ret with operation status on A
;
;
;********************************************************
;* R W 2 5 6	- 	Read o Write 256 byte/sec dsk	*
;********************************************************
;
RW256:
	ld	h,wddspt	; if disk number is 0 or 1
	cp	wddsiz		; then H = wdd sector/track
	jr	c,R256.1	;
	ld	h,fddspt	; else H = fdd sector/track
R256.1:
	ld	a,c		; get &
	ld	(WrType),a	; set CP/M write type
	dec	de		; DE. LogSec
	ld	a,(de)		; Get Logical Sector
	dec	a		; to base 0
	ld	l,0		; initial side = 0
R256.2:
	cp	h		; repeat until
	jr	c,R256.3	; log sec < sec /trk
	inc	l		; side up
	sub	h		; log sec = log sec - sec/trk
	jr	R256.2		; retry
	R256.3:
	or	a		;carry = 0
	rra			; A = A/2
	inc	a		; to base 1
	ld	(PhySec),a	; Set physical sector
	sla	l		; to bit 4
	sla	l		; to bit 4
	sla	l		; to bit 4
	sla	l		; to bit 4
	inc	de		; DE.LogDsk
	ld	a,(de)		; get LogDsk
	and	1		; only unit number
	or	l		; merge side
	ld	(PhyDsk),a	; set unit and side
	;
	ld	b,5		; byte count for old-new para compare
				; D.E => CP/M	Disk para (new)
	ld	hl,PreDsk	; H.L =>	Disk para (old)
rw01:
	; compare old para with new para (dsk,sid,trk,sec)
	ld	a,(de)		; A = new para
	cp	(hl)		; (hl) = old para
	jr	nz,wtchk	; new <> old
	inc	hl		; next para adrs
	inc	de		;
	djnz	rw01		; repeat until end para
	jr	match		; dsk, sid,trk,sec,equ
wtchk:
	call	WrtPng		; Write Pending Sectors
	ret	nz		; return if error
	;
	ld	bc,5		; 5 parameters
	ld	hl,LogDsk	; H.L = new para adrs
	ld	de,PreDsk	; D.E = old para adrs
	ldir			; new para -> old para
	call	diskrd		; disk read
	or	a		; read error ?
	ret	nz		; error return
match:
	ld	a,(LogSec)	; load logical sector
	dec	a		; convert to base 0
	and	secmsk		; sector mask
	ld	h,a
	ld	l,0		; get high or low buff adrs
	srl	h		; HL=HL*128=(*256)/2
	rr	l
	ld	de,defbuf	; D.E = phys sector buff start adrs
	add	hl,de		; H.L = log sector buff start adrs
	ld	de,(LogDma)	; D.E = user dma adrs
	ld	bc,128		; BC = moving count
	ld	a,(LogR.W)	; load r/w flag
	or	a		; read ?
	jr	z,rwbuf		;
	ld	(WrtFlg),a	; write flag on (A=1)
	ex	de,hl		; H.L = user dma adrs
rwbuf:
	ldir			; move (hl) to (de)
	ld	a,(WrType)	; load write type
	cp	wrdir		; directory write ?
	ld	a,0		; prepare no errors
	call	z,WrtPng	; yes, write Phys sector
	or	a		; set flags
	ret			; return status (A)
;
;
;********************************************************
;* W r t P n g						*
;*		Check for pending Sectors		*
;*		Write if active				*
;********************************************************
;
WrtPng:
	ld	hl,WrtFlg
	ld	a,(hl)		; get flag
	ld	(hl),0		; & clear
	or	a		; was active ?
	ret	z		; no, return
	call	diskwt		; yes, write flush data
	ret			; return status & flag
;
;
;********************************************************
;* D i s k R d						*
;*		Read Physical Sector			*
;********************************************************
;
diskrd:
	; disk read
	xor	a		; 0 = read
	jr	rdwt
;
;
;********************************************************
;* D i s k W t						*
;*		Write Physical Sector			*
;********************************************************
;
diskwt:
	; disk write
	ld	a,1		; 1 = write
	rdwt:
	ld	(PreR.W),a	; set r/w para
rdwt0:
	ld	hl,PrePhy	; H.L = i/o para adrs
	ld	a,(PreDsk)	; load i/o unit number
	cp	wddsiz		; wdd i/o ?
	jr	nc,fdrdwt	; no, then fdd i/o
wdrdwt:
	ld	a,1		; one sector to wdd i/o
	ld	(PreBlk),a	; set wdd sector block
	call	wdio		; exec. wdd i/o
	or	a		; i/o error ?
	ret	z		; no, then normal return
	call	SendErr		; Print Error Code
	;
NoBuff:
rdwterr:
	ld	a,0ffh		; set no sector buffered
	ld	(PreDsk),a	;
	and	1		; A=1
	ret
fdrdwt:
fdrw1:
	call	fdiod		; r/w 256 byte
fdrw2:
	or	a		; fdd i/o error ?
	ret	z		; no, then normal return
	ld	de,ioerrmsg	; D.E = Disk err message
	call	strout		; print it
	call	cin		; wait one char.
	cp	cr		; is return ?
	jr	z,rdwt0		; yes, then retry
	cp	'C'-'@'		; is cntrl C ?
	jr	nz,NoBuff	; Set Error and no sector buff
	jp	wboote		; else go to wboot
;
;
;
;********************************************************
;*		Send Error Message on console		*
;********************************************************
;
SendErr:
	push	af		; save character
	rrca			; get 4 msb's
	rrca			; get 4 msb's
	rrca			; get 4 msb's
	rrca			; get 4 msb's
	call	HxChar		; print 4 msb's
	ld	(ErrHig),a	; store high Error code
	pop	af		; get 4 lsb's
	call	HxChar		;
	ld	(ErrLow),a	; store low Error code
	ld	de,ErrMsg	;
	call	strout		; print it
	ret			;done
	;
	; Convert A low nibble in Hex ASCII Char
	;
HxChar:
	and	0Fh		; keep 4 lsb's
	add	a,90h		; develop a supplement of 6
	daa			; and carry
	adc	a,'@'		; sum ASCII offset
	daa			;
	ret
;
;
;
msgcr:
	; print string pointed by DE and wait cr
	call	strout		; print it
waitcr:
	call	cin		; wait one char.
	cp	cr		; cr ?
	jr	nz,waitcr	;
	ret
;
;
;
;********************************************************
;*							*
;*		Initialized RAM data areas		*
;*							*
;********************************************************
;
nosysmsg:
	defb	cr,lf,bell,'Set system diskette in disk A,',cr,lf
	defb	'ok push return. ',endmsg
;
ErrMsg:
	defb	cr,lf,bell,'Error #'
ErrHig:	defb	'0'
ErrLow:	defb	'0'
	defb	' - ',endmsg
;
;
ioerrmsg:
	defb	cr,lf,bell,'DISK I/O ERROR',cr,lf
	defb	'<RETURN> retry, ^C abort, any key to continue'
	defb	endmsg
;
ndevmsg:
	defb	cr,lf,bell,'.NO Device.',cr,lf,endmsg
;
;
;
;********************************************************
;*		B i o s   INPUT/OUTPUT   Tables		*
;********************************************************
;
sysflag:
	defb	0		; system flag for disk assignement
;
vidareas:
	; video routine data areas
	defs	32
;
; Logical Parameter Table
;
LogSec:	defb	1		; CP/M logical Sector number
LogDsk:	defb	0		; CP/M logical Disk number
PhyDsk:	defb	0		; Physical Disk Number
LogTrk:	defw	0000		; Physical Track Number
PhySec:	defb	1		; Physical Sector Number
LogDma:	defw	0080h		; CP/M logical Dma address
LogR.W:	defb	0		; CP/M logical R/W Flag
;
; Previous Parameter Table
;
PreDsk:	defb	0ffh		; Previous CP/M Disk
PrePhy:	defb	0		; Previous Phys Disk
PreTrk:	defw	0000		; Previous Phys=Logical Track
PreSec:	defb	1		; Previous Phys Sector
PreDma:	defw	defbuf		; Physical DMA add
PreR.W:	defb	0		; Phys R/W operation
PreBlk:	defb	1		; Phys # of Sectors (for wdd)
WrtFlg:	defb	0		; Write Pending Flag
Wrtype:	defb	1		; BDos Write Type
;
;
	defs	bios+600h-$		; free space on bios ram
;
;
;
;********************************************************
;*							*
;*		Disk data areas				*
;*							*
;********************************************************
;
defbuf:	defs	secsiz		; default i/o dma address
dirbuf:	defs	128		; directory buffer
;
;
;********************************************************
;*		Allocation and check vectors		*
;********************************************************
;
alv2:	defs	12		; alloc vector 2
csv2:	defs	16		; check vector 2
;
alv3:	defs	12		; alloc vector 3
csv3:	defs	16		; check vector 3
;
;
	; extfdd alloc and check vector
;
alv4:	defs	10		; alloc vector 4
csv4:	defs	8		; check vector 4
;
alv5:	defs	10		; alloc vector 5
csv5:	defs	8		; check vector 5
;
	; wdd alloc and check vector
;
alv0:	defs	181		; alloc vector 0 (1440K/8)+1
csv0:	defs	0		; no check vector 0
;
alv1:	defs	181		; alloc vector 1 (1440K/8)+1
csv1:	defs	0		; no check vector 1
;
	defs	bios+0a00h-$	; free space
;
	.dephase		; end of bios + data areas
; 	end 100h
	end
;
