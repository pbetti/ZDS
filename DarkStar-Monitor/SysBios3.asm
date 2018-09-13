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
	defw	voidsrv		; 3
	defw	sysedt		; 4
	defw	romsel		; 5
	defw	romrun		; 6
	defw	bin2dec		; 7

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
	ld	hl,logotxt
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
inamep	equ	2
ipagep	equ	2+tnamelen+2
iaddrp	equ	2+tnamelen+2+tpagelen+2
isizep	equ	2+tnamelen+2+tpagelen+2+tiaddrlen+2
idescp	equ	2+tnamelen+2+tpagelen+2+tiaddrlen+2+tsizelen+2

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
	ld	a,e			; image number
	call	dispa
	call	inline
	defb	": ",0
	ld	c,e
	call	toblk
	ld	e,c
	ld	a,(iy+2)		; is a valid block ?
	or	a
	jr	z,tonblk
	call	dspblkid		; yes, show it
tonblk:
	call	crlf
	inc	e
	djnz	rnblk
	;
romask:
	ld	h,24
	ld	l,0
	call	bbsetcrs
	call	inline
	defb	"Select an image number or <ESC> to exit: ",0

	ld	d,2
	ld	e,SE_DEC
	call	isysed
	ld	(asav),a		; exit status
	or	a
	jr	nz,romexi		; abort
	ld	a,l
	or	a
	cp	maxblk
	jr	nc,rombep		; too big. ask again
	or	a
	jr	z,rombep		; zero, ask again
	ld	c,a
	push	hl
	call	toblk
	pop	hl
	ld	a,(iy+2)		; is a valid block ?
	or	a
	jr	z,rombep		; nok
	;
romexi:
	ld	(hlsav),hl
	call	rrestp
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

	ld	de,isizep
	ld	b,4
	call	imgt2bin
	ld	(rombuf+3),hl

	call	rrestp
	; start interbank copy
multi:
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
	call	inline			; what to do ?
	defb	cr,lf,"Image in place, any key to run or <ESC> to exit",cr,lf,0
	call	bbconin
	cp	esc			; abort ?
	ret	z
	ld	hl,(rombuf+5)		; jump to
	jp	(hl)
placepage:
	push	bc
	push	af
	call	rsavtp			; save transient
	;
	pop	af
	call	rmnttp			; mount and
	pop	bc
	ld	hl,trnpag << 12
	ldir				; do copy 4k
	;
	call	rrestp			; reset mmu
	ret
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
; print rom image field
pblkfld:
	push	iy
	pop	hl			; mov addr to hl
	add	hl,bc
	ld	b,(hl)			; fld length
pblkf0:
	inc	hl
	ld	c,(hl)
	call	bbconout
	djnz	pblkf0
	ret
	;
; display header
dspblkid:
	push	bc
	ld	bc,inamep-1		; name
	call	pblkfld
	call	inline
	defb	" - ",0
	ld	bc,idescp-1		; description
	call	pblkfld
	pop	bc
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
rombuf:	defs	6

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
	ld	hl,hl2dbuf
	or	a
	jr	z,prdhl1
	ld	b,4
prdhl2:
	ld	a,(hl)
	cp	'0'
	jr	nz,prdhl1
	inc	hl
	djnz	prdhl2
prdhl1:
	call	print
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
	defb	$20,$1b,$1b,$0d,$d4,$cc,$d5,$d4,$d0,$d5,$d4,$cc
	defb	$d5,$20,$20,$d4,$d5,$d4,$d4,$cc,$d5,$d4,$cc,$d5
	defb	$d4,$cc,$d5,$d4,$cc,$d5,$1b,$1c,$0d,$20,cr,lf
	defb	$20,$1b,$1b,$0d,$d4,$cc,$d3,$20,$cb,$cb,$d2,$cc
	defb	$d5,$20,$20,$cb,$cb,$cb,$cb,$cf,$20,$d4,$cc,$d3
	defb	$ce,$cc,$cf,$cb,$20,$cb,$1b,$1c,$0d,$20,cr,lf
	defb	$20,$1b,$1b,$0d,$d2,$cc,$cc,$cc,$d1,$d3,$d2,$cc
	defb	$d3,$20,$20,$d3,$d2,$d3,$d2,$cc,$d3,$d2,$cc,$d3
	defb	$d2,$cc,$d3,$d2,$cc,$d3,$1b,$1c,$0d,$20,cr,lf
	defb	$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1
	defb	$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1,$c1
	defb	$c1,$c1,$c1,$c1,cr,lf
	defb	cr,lf
	defb	0


;-------------------------------------
sysb3lo:
	defs	sysbios3 + $0bff - sysb3lo
sysb3hi:
	defb	$00
;;
;; end of code - this will fill with zeroes to the end of
;; the image

;-------------------------------------

if	mzmac
wsym sysbios3.sym
endif
;
;
	end
;
