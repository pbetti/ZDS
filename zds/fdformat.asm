;;----------------------------------------------------------------------------
;; FORMAT.COM - Z80DarkStar Floppy format utility
;;
;; (c) 2006 Piergiorgio Betti <pbetti@lpconsul.net>
;;
;; 2006/03/15 - Release 3.2
;; Now handle 128/256 bytes per sector (17/10 sectors/track)
;;
;; originally disassembly of the Micro Z80 of Nuova Elettronica produced
;; with:
;z80dasm: Portable Z80 disassembler
;Copyright (C) Marcel de Kogel 1996,1997
;Patched 2006 for uppercase by Piergiorgio Betti <pbetti@lpconsul.net>
;20140917 CP/M3 and modular SYSBIOS port
;;----------------------------------------------------------------------------

; link to DarkStar Monitor symbols...
include	darkstar.equ
include	syshw.inc


cr	equ	$0d
lf	equ	$0a
bel	equ	$07
fcb1	equ	$005c			; default fcb structure
tpa	equ	$0100
	;
	org	tpa

gofmt:	jp	format			; 000100 the beginning
	;
scrtch:	defs	128			; local stack area
sparea	equ	$
	;
	; include routines to print ascii values
include bit2040.asm
	;;
	; here is the data to compose the track
ftrbeg:	defb	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	defb	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	defb	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	defb	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	;
ftrbg2:	defb	$00,$00,$00,$00,$00,$00
	defb	$fe					; addr mark
fitrkn:	defb	$00					; track #
	defb	$00					;
fisecn:	defb	$00					; sector #
fisecl:	defb	$00					; sectro len.
	defb	$f7					; crc mark
	defb	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	defb	$ff
	defb	$00,$00,$00,$00,$00,$00
dam:	defb	$00					; data addr mark (30 bytes)
	;
	;	sector data here...
	;
fipose:	defb	$f7					; data crc mark
	defb	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	defb	$ff,$ff,$ff,$ff				; 173 byte block (originally + 128 $e5)
	defb	$ff,$ff,$ff,$ff,$ff,$ff
	;
	; disks format vector
dftab:	;defb	40,1,18,0		; 40 trk ss	; 40 tracks formats
	;defb	40,2,18,0		; 40 trk ds	; removed...
	;defb	80,1,18,0		; 80 trk ss	; ... 80 tracks ss too
	defb	80,2,18,0		; 80 trk ds 128 bytes 17 sec.
	defb	40,1,11,1		; 40 trk ss 256 bytes 10 sec.
	defb	80,2,12,2		; 80 trk ds 512 bytes 11 sec.
	;
nedos:	defb	1			; Is a NE-DOS disk ?
					; start from 1 if not, from 0 if yes
damstd	equ	$fb			; standard data address mark
damdos	equ	$fa			; standard data address mark
	;
codbeg	equ	$			; begin code...
	;
	; show a zero terminated string
zsdspcl:				; 0239
	ld	c,cr			;
	call	bbconout		; send cr
	ld	c,lf			;
	call	bbconout		; send lf
zsdsp:	ld	a,(hl)			; pick char pointed by hl
	or	a			; is the terminating nul ?
	ret	z			; yes
	push	hl			; no
	ld	c,a			;
	call	bbconout		; display it
	pop	hl			;
	inc	hl			;
	jp	zsdsp			;
	;
	; this copy a decimal converted string in area
	; pointed by hl
pldecs:	push	hl			; load hl on iy
	pop	iy			;
	ld	hl,oval16		; result of conversion
pldnxt:	ld	a,(hl)			; pick char pointed by hl
	or	a			; is the terminating nul ?
	ret	z			; yes
	ld	(iy+0),a		; digit copy
	inc	hl			; next locations
	inc	iy			;
	jp	pldnxt			;
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
bq2:	sla	e		;z80 op code for sla a,e
	ld	a,18h
	adc	a,a
	ld	c,a
	call	bbconout
	djnz	bq2
	pop	de
	pop	bc
	pop	af
	ret

format:
	ld	sp,sparea		; init stack
	ld	a,40			; 40 tracks by default
	ld	(tnumbf),a		;
	ld	a,1			; 1 side
	ld	(tsides),a		;
	ld	hl,mchoi		; ask format
	call	zsdsp			;
usel:	call	gchr			;
	cp	$03			; ctrl+c ?
	jp	z,exit			; exit
	cp	cr			; return ?
	jp	z,exnos			; exit
	sub	'0'			; convert to binary
	dec	a			; adjust base
	cp	$03			; is in range 0-2
	jp	p,wrngd			; no
	ld	(tfrmt),a		; store user selection
	ld	e,a			; copy drive num on de
	ld	d,0			;
	ld	ix,dftab		; load format parameter base
	add	ix,de			; for check
	add	ix,de			;
	add	ix,de			;
	add	ix,de			;
	ld	c,(ix+0)		;
	call	bin2a8			; convert tracks to decimal
	ld	hl,musnt		;
	call	pldecs			;
	ld	c,(ix+1)		;
	call	bin2a8			; convert sides to decimal
	ld	hl,mussd		;
	call	pldecs			;
	ld	a,(ix+3)		; sector len.
	cp	0			; 128 ? ...
	jr	nz,sl256		; no
	ld	hl,128			; yes
	ld	(tslen),hl		; store
	jr	ushw
sl256:	cp	1			; 256 ? ...
	jr	nz,sl512		; no
	ld	hl,256			; yes
	ld	(tslen),hl		; store

isndos:	ld	hl,mndos		; ask for NE-DOS
	call	zsdspcl			;
	call	gchr			;
	cp	'Y'			; is 'y' ?
	jp	nz,noned		; no
	ld	c,'e'			; complete answer with (y)es
	call	bbconout		;
	ld	c,'s'			; complete answer with (y)es
	call	bbconout		;
	ld	c,cr			;
	call	bbconout		;
	ld	c,lf			;
	call	bbconout		;
	xor	a			;
	ld	(nedos),a		; set NEDOS compatibilty (0)
	ld	hl,(tslen)		;
	jr	ushw			;
noned:	cp	'N'			; is 'n' ?
	jp	nz,isndos		; no, ask again
	ld	c,'o'			; complete answer with (y)es
	call	bbconout		;
	ld	c,cr			;
	call	bbconout		;
	ld	c,lf			;
	call	bbconout		;
	ld	hl,(tslen)		;
	jr	ushw			;
sl512:	cp	2			; 512 ? ...
	jr	nz,ushw			; no (... error!)
	ld	hl,512			; yes
	ld	(tslen),hl		; store
ushw:	push	hl			; sec. len. in bc
	pop	bc			;
	call	bn2a16			; convert to decimal
	ld	hl,mussl		;
	call	pldecs			;
	ld	hl,musfm		;
	call	zsdsp			; show to the user
	;
	ld	hl,mdcho		; ask for drive id
	call	zsdsp			;
	call	gchr			;
	cp	$03			; ctrl+c ?
	jp	z,exit			; exit
	cp	cr			; return ?
	jp	z,exnos			; exit
	cp	'A'			; is a or b ?
	jp	m,wrngd			;
	cp	'C'			;
	jp	p,wrngd			; no
	sub	'A'			; makes number
	ld	(tdriv),a		; store user selection
	ld	(fdrvbuf),a		; store drive num
	;
	ld	hl,mcfm			; ask confirm
	call	zsdspcl			;
	call	gchr			;
	cp	'Y'			; is 'y' ?
	jp	nz,wcmnd		; no
	ld	c,'e'			; complete answer with (y)es
	call	bbconout		;
	ld	c,'s'			; complete answer with (y)es
	call	bbconout		;
	ld	c,cr			;
	call	bbconout		;
	ld	c,lf			;
	call	bbconout		;
	;
again:	call	waitky			; wait for disk in drive
	; defines format parameters
	ld	a,(tfrmt)		; retrieve format
	ld	e,a			; store drive num on de
	ld	d,0			; for later use
	ld	ix,dftab		; format parameter base
	add	ix,de			; type offset
	add	ix,de			;
	add	ix,de			;
	add	ix,de			;
	ld	a,(ix+0)		; tracks
	ld	(tnumbf),a		; store # of tracks
; 	ld	d,(ix+1)		; sides - loads in de (sides+sectors)
	ld	e,(ix+2)		; get # sec.
	ld	a,(nedos)		; nedos mode?
	or	a			; zero = yes
	jr	nz,getscl		; no, go on
	dec	e			; else adjust
getscl:	ld	a,(ix+3)		; get sector len. byte
	ld	(fisecl),a		;
	xor	a			;
	ld	(fitrkn),a		; start track
	ld	(tcount),a
	ld	(cside),a		; start side
	ld	c,a			; for bbsidset
	ld	a,(nedos)		; start sec. #
	ld	(fisecn),a		;
	;
	call	bbsidset
	call	bbfdrvsel
	ld	a,$03			; 1771 restore
	call	jfdcmd			;
	call	jfstat			;
	;
trsta:
	ld	a,(nedos)		; evaluate correct DAM for NEDOS directory
	or	a			;
	jr	nz,stddsk		; standard
	ld	a,(fitrkn)		; DAM patch only for directory (track 17)
	cp	17			;
	jr	nz,stddsk		; regular
	ld	a,damdos		; track 17
	jr	damapp			; proceed
stddsk:	ld	a,damstd		;
damapp:	ld	(dam),a			; proceed
	di				; no interrupts disturbing us
	ld	hl,ftrbeg		; start sequence
	ld	c,fdcdatareg		; set c to 1771 data port
	ld	b,40			; 40 bytes to send
	ld	a,$f4			; 1771 write track
	call	jfdcmd			;
wfdc:	in	a,(fdccmdstatr)		; check ready
	bit	1,a			;
	jp	z,wfdc			;
	outi				; loop send byte
	jp	nz,wfdc			;
wsecd:	ld	hl,ftrbg2		; id field sector image
	ld	b,30			; 30 bytes to send
wfdc1:	in	a,(fdccmdstatr)		;
	bit	1,a			;
	jp	z,wfdc1			;
	outi				;
	jp	nz,wfdc1		; id field written
	ld	hl,(tslen)
	ld	d,$e5			; null sector data
wfdc2:	in	a,(fdccmdstatr)		;
	bit	1,a			;
	jp	z,wfdc2			;
	out	(c),d			; out
	dec	hl			; dec counters
	ld	a,h			; zero ?
	or	l			;
	jp	nz,wfdc2		; no, next $e5
	ld	hl,fipose		; end data field sector image
	ld	b,15			; 15 bytes to send
wfdc3:	in	a,(fdccmdstatr)		;
	bit	1,a			;
	jp	z,wfdc3			;
	outi				;
	jp	nz,wfdc3		; end data field written
	ld	a,(fisecn)		;
	inc	a			;
	ld	(fisecn),a		;
	cp	e			; if not all # sec image written
	jp	nz,wsecd		; next sector
wteag:	in	a,(fdccmdstatr)		; ready to write again ?
	bit	0,a			;
	jp	z,wtend			; no
	ld	a,$ff			; pad with ff
	out	(fdcdatareg),a		;
	inc	b
	jp	wteag			;
wtend:
	call	jfstat			;
	and	$e7			;
	jp	nz,unrerr		; very bad: format failed
	;
; 	call	zcrlf
; 	ld	a,b
; 	call	h2aj2
; 	call	zcrlf
	push	de
	ld	hl,mfmtt		; inform user about progress
	call	zsdsp			;
	ld	a,(fitrkn)		; track
	ld	c,a			;
	call	bin2a8			;
	ld	hl,oval16		;
	call	zsdsp			;
	ld	hl,mfmts		;
	call	zsdsp			;
	ld	a,(cside)		; side
	ld	c,a			;
	call	bin2a8			;
	ld	hl,oval16		;
	call	zsdsp			;
	ld	c,cr			;
	call	bbconout		; at beginning of line
	pop	de
	;
	ld	a,(cside)		; verify side
	inc	a			; inc. side
	cp	(ix+1)			; exists ?
	jr	z,advtrk		; no
	ld	(cside),a		; set it
	ld	c,a			;
	call	bbsidset		; activate
	call	bbfdrvsel		; transfer to hardware
;	ld	a,(fitrkn)		; adjust trk offset
; 	add	e			; sum n. of tracks on side 0
; 	ld	(fitrkn),a		; done
; 	jr	sidok			;
	ld	a,(nedos)		; resets sector counters
	ld	(fisecn),a		;
	ld	b,$00			;
	jp	trsta			; restart write
advtrk:	xor	a			;
	ld	(cside),a		; restore side 0
	ld	c,a			;
	call	bbsidset		;
	call	bbfdrvsel		; transfer to hardware
	ld	a,(tcount)		; get cylinder counter
	inc	a			; next track
	ld	hl,tnumbf		;
	cp	(hl)			; eod ?
	jp	z,rstart		; yes
	ld	(tcount),a		; update track counters
	ld	(fitrkn),a		;
sidok:
	ld	a,(nedos)		; resets sector counters
	ld	(fisecn),a		;
	ld	b,$00			;
	; verify remove.........
; vl1:	djnz	vl1			; ?????? 000370 10 fe
; vl2:	djnz	vl2			; ?????? 000372 10 fe
	;
	ld	a,$53			; 1771 step-in
	call	jfdcmd			;
	call	jfstat			;
	jp	trsta			; restart write

wcmnd:	ld	hl,mcmda		; 00037f 21 2a 04
	call	zsdsp			;
	jp	rstart			;

; 	jp	rstart			;

wrngd:	ld	hl,mcho2		;
	call	zsdsp			;
	jp	rstart			;

exnos:	ld	hl,mnsel		; no sel msg
exit:	call	zcrlf			;
	ei				; ensure interrupts re-enabled
	jp	$0000			; jump to boot

	; restart from beginning
rstart:
	ld	a,$00			; reset drives
	out	(fdcdrvrcnt),a		;
	ei				; now can reenable interrupts
	ld	hl,manot		; ask for another
	call	zsdspcl			;
	call	gchr			;
	cp	'Y'			; is 'y' ?
	jp	nz,exit		; no
	ld	c,'e'			; complete answer with (y)es
	call	bbconout		;
	ld	c,'s'			; complete answer with (y)es
	call	bbconout		;
	ld	c,cr			;
	call	bbconout		;
	ld	c,lf			;
	call	bbconout		;
	jp	again			;
	;
unrerr:
	push	af
	ld	hl,mcrsh
	call	zsdspcl
	ld	hl,mcmda
	pop	af
	call	zbits
	ld	c,' '
	call	bbconout
	ld	a,(fisecn)
	ld	c,a			; err sector
	call	bin2a8			; convert decimal
	ld	hl,ersec		;
	call	pldecs			;
	ld	hl,ersec		;
	call	zsdsp
	call	zcrlf
; 	jr	exit
	jr	rstart
	;
waitky:	ld	hl,minds
	call	zsdsp
	call	bbconin
	ret

;;
;; sfdccmd - send 1771 a command
;
jfdcmd:
	push	af
sndcl:
	in	a,(fdccmdstatr)
	bit	0,a			; check busy
	jp	nz,sndcl
	pop	af
	out	(fdccmdstatr),a
	ex	(sp),hl
	ex	(sp),hl
	ex	(sp),hl
	ex	(sp),hl
	ret
;;
;; jfstat - get 1771 status and copy on buffer
;
jfstat:
	in	a,(fdccmdstatr)
	bit	0,a
	jp	nz,jfstat
	ret
	;
mcmda:	defb	cr,lf,"Format aborted.",cr,lf,$00
mcfm:	defb	cr,lf,"Are you shure ? ",$00
mndos:	defb	cr,lf,"Is a NE-DOS disk ? ",$00
mchoi:	defb	"* Z80DarkStar DISK FORMAT *",cr,lf
	defb	cr,lf
mcho2:	defb	cr,lf
	defb	"SELECT DISK FORMAT:",CR,LF
	defb	cr,lf
	defb	"1 - 80 TRACK, 128 bytes, 17 sectors/track, DS CP/M2",cr,lf
	defb	"2 - 40 TRACK, 256 bytes, 10 sectors/track, SS NEDOS",cr,lf
	defb	"3 - 80 TRACK, 512 bytes, 11 sectors/track, DS CP/M3",cr,lf
	defb	cr,lf
	defb	"Select 1-3 :"
	defb	$00
mnsel:	defb	"NO selection, exiting...",cr,lf,$00
mcrsh:	defb	bel,"ERROR DURING FORMAT ! : ",$00
mfmtt:	defb	"Formatted track ",$00
mfmts:	defb	", side ",$00
musfm:	defb	cr,lf,"Using format "
musnt:	defb	"00"
	defb	" tracks, "
mussd:	defb	"0"
	defb	" sides, "
mussl:	defb	"000"
	defb	" bytes/sec.",cr,lf,$00
mdcho:	defb	"Select drive (A/B): ",$00
manot:	defb	cr,lf,"Format another ? ",$00
minds:	defb	cr,lf,"Insert disk and press any key...",cr,lf,$00
ersec:	defb	"  ",0

tnumbf:	defb	$28			; # of tracks to format
tsides:	defb	$01			; and # of sides
tnsect:	defs	1			; # if sectors per track
cside:	defs	1			; current side register
tslen:	defs	2			; sector lenght
tcount:	defs	1			; cylinder counter
tfrmt:	defs	1			; users' format selection
tdriv:	defs	1			; users' drive selection

	END
