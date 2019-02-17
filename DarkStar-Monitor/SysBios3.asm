;
;=======================================================================
;
; Modular Z80 DarkStar (NE Z80) Monitor
;
;=======================================================================
;
;-----------------------------------------------------------------------

; Common equates for BIOS/Monitor

include	Common.inc.asm
include	services.inc.asm

	extern	delay, mmpmap, mmgetp
	extern	bbconin, bbconout, rldrom
	extern	inline, print
	extern	bbsetcrs, bbgetcrs
	extern	bbgetdsr, bbsetdsr
	extern	rpch, bbdbox, bbldpart, bbmvpart

	dseg

	name	'SYS3BI'

sysbios3	equ	$		; start of non resident BIOS

	; safe reload, something goes wrong if we are here

	jp	rldrom

sysbid3:
	defb	'SYSBIOS3'

srvtab:
	defw	logo		; 1 See called service for description...
	defw	veffect		; 2
	defw	memtest		; 3
	defw	sysedt		; 4
	defw	romsel		; 5
	defw	romrun		; 6
	defw	bin2dec		; 7
	defw	zsetup		; 8
	defw	romboot		; 9

srvtbe	equ	$
srvtlen	equ	(srvtbe-srvtab)/2

;;
;; This bank reserved for internal sysbios services
;;
;; sysinit is the service dispatcher
;; C = service id
;; HL used internally, not available for i/o
;; Other register depend on call
;;

sysint:
	ld	(s3stsav),sp		; switch to our stack
	ld	sp,s3stk
	call	regsav			; save registers in local area
	ld	hl,sysiret		; returns will be to stack restore
	push	hl

	ld	a,c
	sub	$1			; check called id
	jr	c,calerr		; minor 0
	cp	srvtlen
	jr	nc,calerr		; greater than jump table
	push	de
	add	a,a
	ld	e,a
	ld	d,$00
	ld	hl,srvtab
	add	hl,de
	pop	de
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	jp	(hl)
	;
sysiret:				; global exit
	call	regrst			; recover reg. status
	ld	sp,(s3stsav)
	ret
	;
calerr:
	call	inline
	defb	"sysbio3: invalid call.",cr,lf,0
	ret
	;
; Store/save register in input
regsav:
	ld	(asav),a
	ld	(hlsav),hl
	ld	(desav),de
	ld	(bcsav),bc
	ret
	;
; Recover register in output
regrst:
	ld	a,(asav)
	ld	hl,(hlsav)
	ld	de,(desav)
	ld	bc,(bcsav)
	ret

;;
;; Print out logo
;;
logo:
	ld	hl,nologotxt
	ld	a,e
	cp	DL_NONE
	jr	z,disp_logo

	ld	hl,logotxt
disp_logo:
	call	print
	ret

;;
;; Set/reset crt effect
;;
;; E = effect id
;; Does not check for arg constraints...
;;
veffect:
	ld	de,(desav)		; we need e
iveff:	; internal call
	ld	a,e			; to index hl
	ld	hl,efftab
	add	a,a			; x 2
	add	a,a			; x 4
	ld	b,0
	ld	c,a			; bc = offset
	add	hl,bc			; indexed
	call	print			; emit sequence
	ret

efftab:
	defb	$1b,$02,$0d,$00		; blnkon
	defb	$1b,$01,$0d,$00		; blnkof
	defb	$1b,$1b,$0d,$00		; revon
	defb	$1b,$1c,$0d,$00		; revof
	defb	$1b,$04,$0d,$00		; undron
	defb	$1b,$03,$0d,$00		; undrof
	defb	$1b,$06,$0d,$00		; hliton
	defb	$1b,$05,$0d,$00		; hlitof

;;
;; void service
;;
voidsrv:
	ret

	;;
;;	sysedt - field/input editor
;;
;;	D = buffer length
;;	E = mode
;;
isysed:
	ld	hl,seicll		; internal call
	inc	(hl)
sysedt:
	call	seisin
	jr	nz,seicll0
	ld	de,(desav)
seicll0:
	push	de
	call	bbgetcrs		; get position on screen
	pop	de

	ld	(seiloc),hl		; to scr buffer (origin)
	ld	(secloc),hl		; to scr buffer (current)
	ld	hl,iedtbuf
	ld	(sebloc),hl		; init buffer cursor
	xor	a
	ld	(secnt),a
	ld	a,d
	or	a
	jp	z,seerr			; void field
	ld	(sebfl),a		; save len
		; mode
	bit	7,e
	jr	nz,sysed01		; preloaded buffer
	call	sezero			; clear buffer
sysed01:
	res	7,e
	ld	a,e
	ld	(semode),a
		; should check ! > 128
	call	serfrsh
sysed0:
	ld	hl,(secloc)
	call	bbsetcrs		; place cursor
	ld	de,(sebloc)		; de = buf cursor
sysed00:
	call	bbconin			; get next
	ld	c,a			; save input on c

		; special key
	cp	cr			; return, end
	jr	z,sysede
	cp	esc			; exit on user req
	jr	z,seexff
	cp	bs			; backspace
	jp	z,seback
	cp	7fh			; backspace/canc
	jp	z,seback
	push	de
	call	seval			; validate upon mode
	pop	de
	jr	c,sysed00

		; input length
	ld	a,(sebfl)
	ld	b,a
	ld	a,(secnt)
	cp	b			; >= flen ?
	push	af			; yes, reject
	call	nc,seign
	pop	af
	jr	nc,sysed00

	ld	a,c			; recover input
	ld	(de),a			; on buffer
	inc	de			; to next on buffer
	ld	(sebloc),de
	ld	hl,seccol
	inc	(hl)			; to next on screen
	ld	hl,secnt
	inc	(hl)
	call	bbconout
	jr	sysed0

seex00:
	xor	a
	jr	seexit
seexff:
	xor	a
	dec	a
seexit:
	push	hl			; reset int. call
	ld	hl,seicll
	dec	(hl)
	pop	hl
	ld	(asav),a
	ret

sysede:
	ld	a,(semode)
	or	a
	ld	c,a
	jr	z,seex00
	ld	hl,0			; in non str mode return on hl
	ld	de,iedtbuf		; from buffer
	ld	a,(secnt)
	or	a
	jr	z,seex00		; null input
	ld	b,a
	cp	4
	jr	c,sysede0
	ld	b,4			; max a word (ffff or 9999)
sysede0:
	ld	a,c
	cp	SE_HEX
	jr	z,sysedx
sysedd:
	ld	a,(de)
	inc	de
	push	de
	sub	'0'
	ld	d,h			; copy HL -> DE
	ld	e,l
	add	hl,hl			; * 2
	add	hl,hl			; * 4
	add	hl,de			; * 5
	add	hl,hl			; * 10 total now
	ld	e,a			; Now add in the digit from the buffer
	ld	d,0
	add	hl,de
	pop	de
	djnz	sysedd
	call	seisin
	jr	nz,seicll1
	ld	(hlsav),hl
seicll1:
	jr	seex00
sysedx:
	call	sehexcv
	call	seisin
	jr	nz,seicll2
seicll2:
	ld	(hlsav),hl
	jr	seex00
; validate input on mode
seval:
	ld	a,(semode)
	or	a
	jr	z,sevalv
	cp	SE_HEX
	jr	z,sevalx
	ld	a,c
	sub	'0'
	ret	c			; Error since a non number
	cp	9 + 1			; Check if greater than 9
	jr	nc,sevali		; as above
sevalv:
	xor	a
	ret
sevali:
	call	seign
	scf
	ret
sevalx:
	ld	a,c
	cp	$60			; to uppercase
	jp	m,sevax0
	cp	$7b
	jp	p,sevax0
	res	5,a			;--
	ld	c,a			; store for later use
sevax0:
	call	sehexh
	jr	c,sevali
	ret
;handle hex
sehexh:
	sub	$30
	ret	c
	cp	$17
	ccf
	ret	c
	cp	$0a
	ccf
	ret	nc
	sub	$07
	cp	$0a
	ret	nc
	ret
; handle backspace
seback:
	ld	a,(secnt)		; empty buf ?
	or	a
	push	af
	call	z,seign
	pop	af
	jp	z,sysed00

	ex	de,hl			; update buffer
	dec	hl
	ld	(sebloc),hl
	ld	(hl),0
	ld	hl,secnt
	dec	(hl)

	ld	c,18h			; update screen
	call	bbconout		; left
	ld	c,iedtfil		; fill
	call	bbconout
	ld	hl,seccol
	dec	(hl)			; to next on screen
	jp	sysed0
; ignore warn
seign:
	ld	c,07h			; bell code
	call	bbconout
	ret				; get next character
; clear buffer
sezero:
	ld	hl,iedtbuf
	ld	b,d
sezer0:
	ld	(hl),0
	inc	hl
	djnz	sezer0
	ret
; paint field
serfrsh:
	ld	hl,(seiloc)		; at begin
	ld	(secloc),hl		; curr too
	call	bbsetcrs		; on screen
	ld	hl,iedtbuf		; on buffer
	ld	de,(secloc)		; de pos on screen
	ld	a,(sebfl)		; len
	ld	b,a			; b = cnt
serfrs0:
	ld	c,(hl)
	inc	c
	dec	c
	jr	z,serfrs4
serfrs1:
	call	bbconout
	push	hl
	ld	hl,secnt
	inc	(hl)
	pop	hl
	inc	hl
	inc	de
	djnz	serfrs0
	ld	(sebloc),hl
	jr	serfrs3
serfrs4:
	ld	(sebloc),hl
serfrs2:
	ld	c,iedtfil		; str end, put filler
	call	bbconout
	inc	hl
	ld	(hl),0
	djnz	serfrs2
serfrs3:
	ld	(secloc),de
	ret
; error !
seerr:
	call	inline
	defb	"Edt err!",0
	ret
	;
; internal call ?
seisin:
	ld	a,(seicll)
	or	a
	ret
	;
; covert to hex (shared with romrun)
sehexcv:
	ld	a,(de)
	inc	de
	call	sehexh
	add	hl,hl      		; * 2
	add	hl,hl      		; * 4
	add	hl,hl      		; * 8
	add	hl,hl      		; * 16 total now
	or	l          		; Now add in the digit from the buffer
	ld	l,a
	djnz	sehexcv
	ret

;-- sysedt buffers --
seiloc:					; initial crs position
seicol:	defb	0			; column
seirow:	defb	0			; row
secloc:					; current crs position
seccol:	defb	0			; column
secrow:	defb	0			; row
sebloc:					; buffer position
sebcol:	defb	0			; column
sebrow:	defb	0			; row
sebfl:	defb	0			;
secnt:	defb	0			; chr count
semode:	defb	0			; mode
seicll:	defb	0

;----- rom map equates -----
inamep	equ	0
ipagep	equ	0+tnamelen
iaddrp	equ	0+tnamelen+tpagelen
isizep	equ	0+tnamelen+tpagelen+tiaddrlen
idescp	equ	0+tnamelen+tpagelen+tiaddrlen+tsizelen

;;
;; Select a EEPROM image
;;
romsel:
	call	rsavtp			; save current
	;
	ld	a,imtpag		; in eeprom table
	call	rmnttp
	;
	; table in place
	ld	c,ff			; draw page
	call	bbconout
	ld	e,EF_REVON
	call	iveff
	call	inline
	defb	lf," Available images ",cr,lf,lf,0
	ld	e,EF_REVOFF
	call	iveff
	;
	ld	b,maxblk-1
	ld	e,1			; sysbios image is not selectable
rnblk:
	push	bc
	ld	a,e			; to second col?
	cp	21
	jr	c,rnblk1

	push	de
	call	bbgetcrs
	ld	de,40			; yes, second col
	add	hl,de
	call	bbsetcrs
	pop	de

rnblk1:
	ld	a,e			; image number
	call	dispa
	call	inline
	defb	": ",0
	ld	c,e
	call	toblk
	ld	e,c
	ld	a,(iy)			; is a valid block ?
	or	a	
	jr	z,tonblk
	call	dspblkid		; yes, show it
tonblk:
	call	crlf
	inc	e

	ld	a,e			; to second col?
	cp	21
	jr	nz,tonblk1

	ld	l,0
	ld	h,3
	call	bbsetcrs

tonblk1:
	pop	bc
	djnz	rnblk
	
romask:
	ld	h,24
	ld	l,0
	call	bbsetcrs
	call	inline
	defb	"Select an image number or <ESC> to exit: ",0

	ld	d,2
	ld	e,SE_DEC
	call	isysed
	ld	(hlsav),hl
	ld	(asav),a		; exit status
	or	a
	jr	nz,romabrt		; abort
	ld	a,l
	or	a
	cp	maxblk
	jr	nc,rombep		; too big. ask again
	or	a
	jr	z,rombep		; zero, ask again
	ld	c,a
	call	toblk
	ld	a,(iy)		; is a valid block ?
	or	a
	jr	z,rombep		; nok
	;
romexi:
	; copy rom name at 0200h for setup utiity
	push	iy			; iy -> hl
	pop	hl
	ld	bc,tnamelen
	ld	de,0200h		; destination
	ldir				; go
	;
romabrt:
	call	rrestp
	ld	hl,(hlsav)
	ret
	;
rombep:
	ld	c,07h			; bell code
	call	bbconout
	jr	romask
	;
; get/save transient page
rsavtp:
	ld	b,trnpag		; ask mmu page
	call	mmgetp
	ld	(pagbuf),a		; save current
	ret
; mount on transient
rmnttp:
	ld	b,trnpag		; transient page
	call	mmpmap			; mount it
	ret
; restore transient
rrestp:
	ld	a,(pagbuf)		; restore
	ld	b,trnpag		; transient page
	call	mmpmap			; mount it
	ret

romlder	equ	$7000
rombuf	equ	(romlder - 7)	

;;
;; Get an EEPROM image on ram
;;
;; E = image id
;;
romrun:
	call	rsavtp			; save current t. page
	;
	ld	a,imtpag		; in eeprom map
	call	rmnttp

	ld	c,e
	call	toblk
	ld	de,ipagep
	ld	b,2
	call	imgt2bin
	ld	h,0
	ld	(rombuf),hl		; uses ROMBUF as temporary buffer

	ld	de,iaddrp
	ld	b,4
	call	imgt2bin
	ld	(rombuf+1),hl
	ld	(rombuf+5),hl		; two copy, we need it later

	ld	e,(iy+isizep)
	ld	d,(iy+isizep+1)
	ld	(rombuf+3),de

	call	rrestp

	; move loader in place and jump to it
	ld	hl,lder_start
	ld	de,romlder
	ld	bc,lder_end - lder_start
	ldir

	jp	romlder

lder_start	equ $

	phase	romlder

	; start interbank copy
multi:
	ld	sp,rombuf
	ld	hl,(rombuf+3)		; image size
	ld	de,4096
	or	a			; clear carry
	sbc	hl,de			; lesser than one page ?
	jr	c,single		; yes
	ld	hl,4096			; no
	jr	cp4k
single:
	ld	hl,(rombuf+3)		; reload image size
cp4k:	ld	c,l
	ld	b,h			; BC size
	ld	a,(rombuf)		; A source (base) page in eeprom
	ld	de,(rombuf+1)		; destination address in ram

	call	placepage		; write page

	ld	hl,(rombuf+3)		; reload image size
	ld	de,4096			; page size
	or	a			; clear carry
	sbc	hl,de			; subtract to get remaining size
	jr	c,runrdy
	jr	z,runrdy
	ld	(rombuf+3),hl		; left bytes
	ld	a,(rombuf)		; write another page...
	inc	a
	ld	(rombuf),a		; next page
	ld	hl,(rombuf+1)
	ld	de,4096
	add	hl,de
	ld	(rombuf+1),hl
	jr	multi
runrdy:
	; call	inline			; what to do ?
	; defb	cr,lf,"Image in place, any key to run or <ESC> to exit",cr,lf,0
	; call	bbconin
	; cp	esc			; abort ?
	; ret	z
	ld	hl,(rombuf+5)		; jump to
	jp	(hl)

placepage	equ	$ + $1000
; placepage:
	push	bc
	push	af
	call	lrsavtp			; save transient
	;
	pop	af
	call	lrmnttp			; mount and
	pop	bc
	ld	hl,trnpag << 12
	ldir				; do copy 4k
	;
	call	lrrestp			; reset mmu
	ret

; get/save transient page
lrsavtp		equ	$ + $1000
; lrsavtp:
	ld	b,trnpag		; ask mmu page
	call	lmmgetp
	ld	(pagsav),a		; save current
	ret
; mount on transient
lrmnttp		equ	$ + $1000
; lrmnttp:
	ld	b,trnpag		; transient page
	call	lmmpmap			; mount it
	ret
; restore transient
lrrestp		equ	$ + $1000
; lrrestp:
	ld	a,(pagsav)		; restore
	ld	b,trnpag		; transient page
	call	lmmpmap			; mount it
	ret

pagsav	equ	$ + $1000
	defb 	0

;;
;; Map page into logical space
;;
;; A - physical page (0-ff)
;; B - logical page (0-f)
;; Use C
;;
lmmpmap		equ	$ + $1000
; lmmpmap:
	sla	b
	sla	b
	sla	b
	sla	b
	ld	c,mmuport
	out	(c),a
	ret

;;
;; Get physical page address
;;
;; B - logical page (0-f)
;; A - return page number
;; Use C
;;
lmmgetp		equ	$ + $1000
; lmmgetp:
	sla	b
	sla	b
	sla	b
	sla	b
	ld	c,mmuport
	in	a,(c)
	ret


	dephase

lder_end	equ $

;
; Convert A to ascii
dispa:
	push	bc
	push	de
	ld	h,0
	ld	l,a
	call	asciihl
	ld	hl,hl2dbuf+3
	call	prdhl1
	pop	de
	pop	bc
	ret
	;
; point to rom image record
;
; C < block num - IY > blok address
toblk:
	push	bc
	ld	b,c			; blk #
	ld	de,tblblk		; blk size
	ld	iy,trnpag << 12		; blk table
toblk0:
	add	iy,de			; to blk
	djnz	toblk0
	pop	bc
	ret
	;
; display header
dspblkid:
	push	hl
	push	bc
	push	de

	push	iy
	pop	hl			; hl = inamep = blk
	call	print

	call	bbgetcrs
	ld	de, tnamelen
	add	hl,de
	call	bbsetcrs
	call	inline
	defb	" - ",0
	
	push	iy
	pop	de			; de = blk

	ld	hl, idescp
	add	hl, de			; hl = idescp
	call	print

	pop	de
	pop	bc
	pop	hl	
	ret
;
; Convert tbl field to binary
;
imgt2bin:
	push	iy			; size
	pop	hl
	add	hl,de
	ex	de,hl
	call	sehexcv
	ret
	;
pagbuf:	defb	0

;;
;; emit cr,lf sequence
;;
crlf:
	call	inline
	defb	$0d,$0a,0
	ret


;;
;; Output HL converted to ascii decimal (max 9999)
;;
;; E = with/without lead zeros
;;

bin2dec:
	ld	hl,(hlsav)
	call	asciihl			; convert to buffer
	ld	de,(desav)
	exx
	ld	de,(desav)		; de also on alternate
	exx
	res	7,e			; strip 2 digit option
	inc	e
	dec	e
	jr	z,prdhlz
	jr	prdhlnz
	;
asciihl:
	ld	de,hl2dbuf
asciihl0:
	ld	bc,-10000
	call	asciihl1
	ld	bc,-1000
	call	asciihl1
	ld	bc,-100
	call	asciihl1
	ld	c,-10
	call	asciihl1
	ld	c,-1
asciihl1:
	ld	a,'0'-1
asciihl2:
	inc	a
	add	hl,bc
	jr	c,asciihl2
	sbc	hl,bc
	ld	(de),a
	inc	de
	ret
	;
hl2dbuf:
	defb	0,0,0,0,0,0
	; decimal HL print
prdhlz:
	xor	a
	jr	prdhl0
prdhlnz:
	xor	a
	dec	a
prdhl0:
	exx
	bit	7,e			; two digit active ?
	exx
	jr	z,prdhl3
	ld	hl,hl2dbuf+3
	ld	b,1
	jr	prdhl4
prdhl3:
	ld	hl,hl2dbuf
	ld	b,4
prdhl4:
	or	a
	jr	z,prdhl1
prdhl2:
	ld	a,(hl)
	cp	'0'
	jr	nz,prdhl1
	inc	hl
	djnz	prdhl2
prdhl1:
	call	print
	ret

msyset:
	defb	" System Setup ",0
eoma	equ	$
dsrcpy	equ	0100h			; dsr copy space
stpcol	equ	11			; cursor column

zsdraw:	defb	0			; >0 = draw only
zsrepa:	defb	0			; >0 = repaint whole screen

;;
;; System setup
;;
zsetup:
	ld	c,ff
	call	bbconout		; clear screen
	ld	c,01h			; force uppercase input
	call	bbconout
	ld	h,1
	ld	l,(80-(eoma-msyset))/2	; paint head
	call	bbsetcrs
	ld	e,EF_REVON
	call	iveff
	ld	hl,msyset
	call	print
	ld	e,EF_REVOFF
	call	iveff
	call	crlf
	call	crlf

	ld	e,EF_UNDRON		; General
	call	iveff
	call	inline
	defb	" General ",0
	ld	e,EF_UNDROFF
	call	iveff
	call	inline
	defb	cr,lf,lf
	defb	"Boot Type:     <D>rive <R>om"
	defb	cr,lf
	defb	"Console  :     <C>rt <S>erial"
	defb	cr,lf,lf
	defb	"Boot Logo:     <L>arge <S>mall <N>one"
	defb	cr,lf
	defb	"Delay    :     <0-99> seconds"
	defb	cr,lf,lf,0

	ld	e,EF_UNDRON		; Volume, if boot = Drive
	call	iveff
	call	inline
	defb	" Drive boot ",0
	ld	e,EF_UNDROFF
	call	iveff
	call	inline
	defb	cr,lf,lf
	defb	"OS Type  :     <C>pm like <U>zi like"
	defb	cr,lf,lf
	defb	"Drive    :     <A-B> floppy <C-N> HD <O-P> virtual"
	defb	cr,lf,lf
	defb	"Partition:"
	defb	cr,lf,lf,0

	ld	e,EF_UNDRON		; ROM image, if boot = ROM
	call	iveff
	call	inline
	defb	" ROM boot ",0
	ld	e,EF_UNDROFF
	call	iveff
	call	inline
	defb	cr,lf,lf
	defb	"ROM Id   :",0fh
	defb	0

	; setup data
	ld	a,(zsrepa)		; in repaint?
	or	a
	jr	nz,zsdata

	call	lddsr			; copy dsr to buf

	ld	a,(dsrcpy+DSR_VALID)	; check for valid setup
	cp	0aah
	call	nz,zsclr		; no, clear buf
zsdata:
	xor	a			; unact. action string
	call	zspro

	xor	a			; display setup
	dec	a
	ld	(zsdraw),a
	call	aboo			; call itself
	xor	a
	ld	(zsdraw),a		; done

	ld	a,(zsrepa)		; in repaint?
	or	a
	ret	nz			; yes, ret

aboo:					; boot type
	ld	h,5			; in place
	ld	l,stpcol
	call	bbsetcrs
	ld	hl,dsrcpy+DSR_BOOTTYP
	ld	a,(zsdraw)		; draw only ?
	or	a
	call	nz,zspch		; display
	jr	nz,acon			; and skip
	ld	d,1
	ld	e,SE_STR+SE_EXTSTR
	call	zsedt
	ld	a,(iedtbuf)
	cp	'R'
	jr	z,aboox
	cp	'D'
	jr	z,aboox
	call	seign
	jr	aboo
aboox:
	ld	(dsrcpy+DSR_BOOTTYP),a	; exit status
acon:					; console type
	ld	h,6			; in place
	ld	l,stpcol
	call	bbsetcrs
	ld	hl,dsrcpy+DSR_CONSOLE
	ld	a,(zsdraw)		; draw only ?
	or	a
	call	nz,zspch		; display
	jr	nz,alog			; and skip
	ld	d,1
	ld	e,SE_STR+SE_EXTSTR
	call	zsedt
	ld	a,(iedtbuf)
	cp	'C'
	jr	z,aconx
	cp	'S'
	jr	z,aconx
	call	seign
	jr	acon
aconx:
	ld	(dsrcpy+DSR_CONSOLE),a	; exit status


alog:					; console type
	ld	h,8			; in place
	ld	l,stpcol
	call	bbsetcrs
	ld	hl,dsrcpy+DSR_LOGO
	ld	a,(zsdraw)		; draw only ?
	or	a
	call	nz,zspch		; display
	jr	nz,adel			; and skip
	ld	d,1
	ld	e,SE_STR+SE_EXTSTR
	call	zsedt
	ld	a,(iedtbuf)
	cp	'L'
	jr	z,alogx
	cp	'S'
	jr	z,alogx
	cp	'N'
	jr	z,alogx
	call	seign
	jr	alog
alogx:
	ld	(dsrcpy+DSR_LOGO),a	; exit status

adel:					; boot delay
	ld	h,9			; in place
	ld	l,stpcol
	call	bbsetcrs
	ld	hl,dsrcpy+DSR_DELAY
	ld	a,(zsdraw)		; draw only ?
	or	a
	jr	z,adele			; no continue
	ld	a,(hl)
	call	dispa
	jr	adelx
adele:
	ld	d,2
	ld	e,SE_DEC+SE_EXTSTR
	call	zsdedt
	ld	a,l
	ld	(dsrcpy+DSR_DELAY),a	; exit status

adelx:
	ld	a,(dsrcpy+DSR_BOOTTYP)	; reload boot type
	cp	'R'
	jp	z,arom			; skip drive if rom boot

aost:					; OS type
	ld	h,13			; in place
	ld	l,stpcol
	call	bbsetcrs
	ld	hl,dsrcpy+DSR_OS
	ld	a,(zsdraw)		; draw only ?
	or	a
	call	nz,zspch		; display
	jr	nz,adrv			; and skip
	ld	d,1
	ld	e,SE_STR+SE_EXTSTR
	call	zsedt
	ld	a,(iedtbuf)
	cp	'C'
	jr	z,aostx
	cp	'U'
	jr	z,aostx
	call	seign
	jr	aost
aostx:
	ld	(dsrcpy+DSR_OS),a	; exit status

adrv:					; boot drive
	ld	h,15			; in place
	ld	l,stpcol
	call	bbsetcrs
	ld	hl,dsrcpy+DSR_DRIVE
	ld	a,(zsdraw)		; draw only ?
	or	a
	call	nz,zspch		; display
	jr	nz,apar			; and skip
	ld	d,1
	ld	e,SE_STR+SE_EXTSTR
	call	zsedt
	ld	a,(iedtbuf)
	cp	'A'
	jr	c,adrv0
	cp	'U'
	jr	nc,adrv0
	jr	adrvx
adrv0:
	call	seign
	jr	adrv
adrvx:
	ld	(dsrcpy+DSR_DRIVE),a	; exit status

apar:
	ld	h,3			; draw part. box
	ld	l,54
	ld	b,17
	ld	c,20
	ld	e,1
	call	bbdbox
	ld	h,3
	ld	l,55
	call	bbsetcrs
	call	inline
	defb	" HD Partitions ",0
	call	bbldpart		; load partition table
	ld	de,0200h
	call	bbmvpart		; move where readable

	ld	h,4
	ld	l,56
	call	bbsetcrs
	call	inline
	defb	"#  Active ID  Type",0
	ld	e,16			; # partitions
	ld	d,1
	ld	h,5
	ld	l,56
	push	ix
	ld	ix,0200h
ppar:
	push	hl
	call	bbsetcrs
	ld	a,d
	call	dispa
	inc	d
	push	de
	ld	c,' '
	ld	b,3
	call	rpch
	ld	a,(ix+0)		; active
	cp	'Y'
	jr	nz,ppar0
	call	inline
	defb	"Yes",0
	jr	ppar1
ppar0:
	call	inline
	defb	"No ",0
ppar1:
	ld	c,' '
	ld	b,3
	call	rpch
	ld	a,(ix+1)		; volid
	or	a
	jr	nz,ppar2
	ld	a,' '
ppar2:
	ld	c,a
	call	bbconout
	ld	c,' '
	ld	b,2
	call	rpch
	ld	a,(ix+2)		; type
	call	zshdtyp
	call	print
	ld	de,8
	add	ix,de
	pop	de
	pop	hl
	inc	h
	dec	e
	jr	nz,ppar
	pop	ix

	ld	h,17			; in place
	ld	l,stpcol
	call	bbsetcrs
	ld	hl,dsrcpy+DSR_HDPART
	ld	a,(zsdraw)		; draw only ?
	or	a
	jr	z,apare			; no continue
	ld	a,(hl)
	call	dispa
	jr	zsconf
apare:
	ld	d,2
	ld	e,SE_DEC+SE_EXTSTR
	call	zsedt
	ld	a,l
aparx:
	ld	(dsrcpy+DSR_HDPART),a	; exit status
	jr	zsconf			; yes

arom:
	ld	h,21			; in place
	ld	l,stpcol
	call	bbsetcrs
	call	romprint
	ld	hl,aksel
	call	print
	ld	a,(zsdraw)		; draw only ?
	or	a
	jr	nz,zsconf		; yes skip

	call	bbconin
	call	romsel

	push	hl			; do screen
	xor	a			; high a
	dec	a
	ld	(zsrepa),a		; call for repaint
	call	zsetup
	xor	a			; low a
	ld	(zsrepa),a		; reset repaint
	ld	h,21			; in place
	ld	l,stpcol		; restore cursor
	call	bbsetcrs
	pop	hl

zsconf:
	ld	a,(zsdraw)		; draw only ?
	or	a
	ret	nz			; yes, return

	xor	a
	dec	a
	call	zspro			; save?

zscfr:
	call	bbconin
	cp	'N'
	jp	z,zsdata
	cp	'Y'
	jp	z,wrdsr
	cp	'E'
	jr	z,zsbye
	call	seign			; wrong input
	jr	zscfr
zsbye:
	xor	a
	dec	a
zsret:
	ld	(asav),a

	ret
;
; display data in draw mode
zspch:
	push	af
	ld	c,(hl)
	call	bbconout
	pop	af
	ret
;
; decode part. type
zshdtyp:
	ld	hl,mtcpm
	cp	'2'
	ret	z
	cp	'3'
	ret	z
	cp	'C'
	ret	z
	cp	'T'
	ret	z
	ld	hl,mtuzi
	cp	'U'
	ret	z
	ld	hl,mtdos
	cp	'N'
	ret	z
	ld	hl,mtoth
	cp	'O'
	ret	z
	ld	hl,mtnan
	ret
	;
mtcpm:	defb	"CP/M",0
mtuzi:	defb	"UZI",0
mtdos:	defb	"NDOS",0
mtoth:	defb	"OTHR",0
mtnan:	defb	"N/A",0

; call editor, check for abort
zsedt:
	ld	a,(hl)
	ld	(iedtbuf),a
	call	isysed
	or	a
	ret	z			; ok
	pop	de			; abort, delete our call
	jr	zsbye
;
; call decimal editor, check for abort
zsdedt:
	push	de
	ld	l,(hl)
	ld	h,0
	call	asciihl
	ld	a,(hl2dbuf+3)
	ld	(iedtbuf),a
	ld	a,(hl2dbuf+4)
	ld	(iedtbuf+1),a
	pop	de
	call	isysed
	or	a
	ret	z			; ok
	pop	de			; abort, delete our call
	jp	zsbye
; setup exit prompt
;
zspro:
	push	af
	ld	h,23
	ld	l,0
	call	bbsetcrs
	ld	c,$c1
	ld	b,80
	call	rpch
	pop	af
	or	a			; active ?
	jr	z,zspro0		; no
	ld	e,EF_REVON		; yes, reverse
	call	iveff
zspro0:
	ld	h,23
	ld	l,2
	call	bbsetcrs
	call	inline
	defb	" Save? ",0
	ld	e,EF_REVOFF		; clear effect
	call	iveff
	call	inline
	defb	" <Y>es <N>o <E>xit ",0
	ret
;
; load dsr copy
lddsr:
	ld	hl,dsrcpy		; temp buffer
	ld	e,0			; index
	ld	b,31			; 31 regs
lddsr0:
	call	bbgetdsr
	ld	(hl),d
	inc	hl
	inc	e
	djnz	lddsr0
	ret
;
; write dsr copy and exit
wrdsr:
	ld	a,0aah			; validate config
	ld	(dsrcpy+DSR_VALID),a

	ld	hl,dsrcpy		; temp buffer
	ld	e,0			; index
	ld	b,31			; 31 regs
wrdsr0:
	ld	d,(hl)
	call	bbsetdsr
	inc	hl
	inc	e
	djnz	wrdsr0
	xor	a
	jp	zsret
	;
; clear dsr buffer
zsclr:
	ld	hl,dsrcpy		; temp buffer
	xor	a			; index
	ld	b,31			; 31 regs
zsclr0:
	ld	(hl),0
	inc	hl
	djnz	zsclr0
	ret

ouradd	equ	$9000


;;
;; MEMTEST - test ram region
;;
memtest:
	pop	hl			; Identify our page
	push	hl
	ld	a,h
	and	$f0			; logical page
	ld	b,a			; on B
	rrc	b			; move on low nibble
	rrc	b
	rrc	b
	rrc	b
	call	mmgetp			; physical page in A
	ld	(ouradd),a

	call	crlf
	ld	e,0			; page count
	ld	c,mmuport
	ld	b,$80			; test page
etloop:
	out	(c),e
	push	de
	ld	hl,$8000
	ld	de,$8fff
mtnxt:	ld	a,(hl)
	push	af
	cpl
	ld	(hl),a
	xor	(hl)
	call	nz,mterr
	pop	af
	ld	(hl),a
	or	a
	sbc	hl,de
	add	hl,de
	jr	nc,etpage
	jr	mtnxt
mterr:
	pop	de
	exx
	call	crlf
	exx
	ld	a,e
	exx
	ld	e,BD_ZERO
	call	bin2dec
	exx
	jr	etexi
etpage:
	pop	de
etpag1:	inc	e
	ld	a,e
	call	etprpg
	ld	a,(ouradd)
	cp	e
	jr	z,etpag1
	ld	a,(hmempag)
	cp	e
	jr	nz,etloop
	call	crlf

etexi:	ld	e,$08		; reset page
	ld	c,mmuport
	ld	b,$80
	out	(c),e
	ret

etprpg:
	push	bc
	push	de
	push	hl
	ld	hl,$0000
	ld	de,$0004
	inc	a
	ld	b,a
etprpg1:
	add	hl,de
	djnz	etprpg1
	ld	e,BD_ZERO
	call	bin2dec
	ld	c,cr
	call	bbconout
	pop	hl
	pop	de
	pop	bc
	ret

rbm1:	defb	0fh, " : ",0
rbm2:	defb	0fh," - ",0
aksel:	defb	" <any key> to select",0

;;
;; boot from ROM
;;
romboot:
	push	de
	call	inline
	defb	"rom image ",0
	pop	de
	jr	romboot1

romprint:
	ld	a,(dsrcpy+DSR_ROMIMG)
	ld	l,a
	ld	h,0
	ld	(hlsav),hl
	ld	e,BD_NOZERO+BD_2DIGIT
	ld	(desav),de
	call	bin2dec
	ld	hl,rbm1
	call	print

	ld	a,(dsrcpy+DSR_ROMIMG)
	ld	e,a
	or	a
	ret	z
romboot1:
	call	rsavtp			; save current t. page
	;
	ld	a,imtpag		; in eeprom map
	call	rmnttp

	ld	c,e
	call	toblk
	push	iy
	pop	de			; de = blk
	ld	hl, inamep
	add	hl, de			; hl = idescp
	call	print
	ld	hl,rbm2
	call	print
	push	iy
	pop	de			; de = blk
	ld	hl, idescp
	add	hl, de			; hl = idescp
	call	print
	call	rrestp
	ret


;-------------------------------------
; Needed modules

;-------------------------------------
; Storage
s3stkbf:
	ds	36			; stack buffer for
s3stk	equ	$			; srstk
s3stsav:
	dw	0			; old stack ptr
hlsav:	dw	0			; hl i/o
desav:	dw	0			; de i/o
bcsav:	dw	0			; bc i/o
asav:	dw	0			; a i/o

;-------------------------------------
; Routine data

logotxt:
	defb	cr,lf
	defb	$20,$d4,$cc,$d5,$d4,$d0,$d5,$d4,$cc
	defb	$d5,$20,$20,$d4,$d5,$d4,$d4,$cc,$d5,$d4,$cc,$d5
	defb	$d4,$cc,$d5,$d4,$cc,$d5,$20,cr,lf
	defb	$20,$d4,$cc,$d3,$20,$cb,$cb,$d2,$cc
	defb	$d5,$20,$20,$cb,$cb,$cb,$cb,$cf,$20,$d4,$cc,$d3
	defb	$ce,$cc,$cf,$cb,$20,$cb,$20,cr,lf
	defb	$20,$d2,$cc,$cc,$cc,$d1,$d3,$d2,$cc
	defb	$d3,$20,$20,$d3,$d2,$d3,$d2,$cc,$d3,$d2,$cc,$d3
	defb	$d2,$cc,$d3,$d2,$cc,$d3,$20,cr,lf
	defb	$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1
	defb	$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1
	defb	$c1,$c1,$c1,$c1,cr,lf

	defb	cr,lf
	defb	0

nologotxt:
	defb	lf,lf,"-----   Z80 Darkstar System   -----",cr,lf,lf,lf,lf,0 

;-------------------------------------
sysb3lo:
	defs	sysbios3 + $0bff - sysb3lo
sysb3hi:
	defb	$00
;;
;; end of code - this will fill with zeroes to the end of
;; the image

;-------------------------------------

; if	mzmac
; wsym sysbios3.sym
; endif
;
;
	end
;
