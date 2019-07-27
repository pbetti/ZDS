
include Common.inc.asm
;-------------------------------------
; Symbols from parent sub-pages
include darkstar.mac


	org	$0100

	xor	a			; parallel 2 PIO
	out	(ppdatctr),a		; chip reset
	out	(pphndctr),a		; chip reset
	ld	a,$cf			; 11-00-1111 mode ctrl word
	out	(ppdatctr),a		; data port mode 3
	ex	af,af'
	ld	a,$ff			; load bit mask 11111111 (all inputs)
	out	(ppdatctr),a		; data port in RX
	ex	af,af'
	out	(pphndctr),a		; resend mode 3 ctrl word to handshake port
	ld	a,10000101b		; bit mask 76543210
					;          ||||||||- b0 in  (reset_init)
					;          |||||||-- b1 out (busy)
					;          ||||||--- b2 in  (strobe)
					;          |||||---- b3 out (ack)
					;          ||||----- b4 out (TXRX)
					;          ||------- b5 out (TX led)
					;          ||------- b6 out (RX led)
					;          |-------- b7 in  (unassigned)
	out	(pphndctr),a
	in	a,(pphnddat)
	and	10000101b		; RX mode and reset handhake and mode leds
	or	01100000b
	out	(pphnddat),a

; ask:
; 	call	inline
; 	defb	"1 upload, 2 download ",0
; 	call	bbconin
; 	cp	'1'
; 	jr	z,doupl
; 	cp	'2'
; 	jr	nz,ask
; 	jr	ask
;
; doupl:
; 	call	outcrlf
	ld	hl, tstrwait
; 	call	print

if	WITH_OLD_PARA
	;
else
	call	fpp_clr
	call	fpp_set_rx
endif
	call	tuplchr		; in hi byte of upload offset
	ld	h,a
	call	tuplchr		; in lo byte of upload offset
	ld	l,a
	call	tuplchr		; in hi byte of data size
	ld	b,a
	call	tuplchr		; in lo byte of data size
	ld	c,a

	push	bc
	push	hl
	ld	hl, tstrload
	call	print
	pop	hl
; 	call	h2a
	call	inline
	defb	cr,lf,lf,0
	pop	bc

	ex	de,hl			; put offset in DE
	call	tprcvblk			; upload data block
	push	bc			; save result
	ld	hl,tmrx
	call	print
	pop	bc
	ld	a,c
	or	a
	jr	z,tpuplok
	ld	hl, tmnot		; error
	call	print
	jp	0
tpuplok:
	ld	hl,tmrdy			; success
	call	print
	jp	0

if	WITH_OLD_PARA
	;
else
;;
;; parallel 2 modes
;;
fpp_clr:
	in	a,(pphnddat)
	and	10000101b		; RX mode and reset handhake and mode leds
	or	01100000b
	out	(pphnddat),a
	ret

fpp_set_rx:
	in	a,(pphnddat)
	res	PB_TXRX,a
	res	PL_RX,a
	out	(pphnddat),a
	ret



;
;=======================================================================
;
; Modular Z80 DarkStar (NE Z80) Monitor
;
;=======================================================================
;
; Parallel communication - parallel 2
; ---------------------------------------------------------------------

tvdskbuf:
	defs	vdbufsz			; i/o command buffer
tszbuf:	defs	2
tcksum:	defb	0
ts_vhdr:	defb	"@IO@"

tPP_SET_RX macro
	ld	a,$cf			; 11-00-1111 mode ctrl word
	out	(ppdatctr),a		; data port mode 3
	ld	a,$ff			; load bit mask 11111111 (all inputs)
	out	(ppdatctr),a		; data port in RX
	in	a,(pphnddat)
	res	PB_TXRX,a
	res	PL_RX,a
	out	(pphnddat),a
	endm

tPP_SET_TX macro
	in	a,(pphnddat)
	set	PB_TXRX,a
	res	PL_TX,a
	out	(pphnddat),a
	ld	a,$cf			; 11-00-1111 mode ctrl word
	out	(ppdatctr),a		; data port mode 3
	ld	a,$00			; load bit mask 00000000 (all outputs)
	out	(ppdatctr),a		; data port in RX
	endm

tPP_RDY	macro
	in	a,(pphnddat)
	set	PB_BUSY,a
	res	PB_ACK,a
	out	(pphnddat),a
	endm

tPP_NACK	macro
	in	a,(pphnddat)
	or	00001010b
	out	(pphnddat),a
	endm

tPP_STOP	macro
	in	a,(pphnddat)
	or	00001010b
	out	(pphnddat),a
	endm

tPP_OKGO	macro
	in	a,(pphnddat)
	res	PB_BUSY,a
	set	PB_ACK,a
	out	(pphnddat),a
	endm

tPP_CLR	macro
	in	a,(pphnddat)
	and	10000101b		; RX mode and reset handhake and mode leds
	or	01100000b
	out	(pphnddat),a
	endm

;;
;; get a byte from remote
;;
;; use:
;;	none
;; return:
;;	A  - received byte

tuplchr:
	in	a, (pphnddat)		; wait for remote ready to tx
	bit	PB_INIT, a
	ret	nz
	bit	PB_STRB, a
	jr	nz, tuplchr

	push	bc
; 	ld	a, ppurdy		; signal ready to receive
; 	out	(pphnddat), a
	tPP_RDY
tupwstrb:
	in	a, (pphnddat)		; wait for data
	bit	PB_STRB, a
	jr	z, tupwstrb

	in	a,(ppdatdat)
	ld	c, a			; copy on C (return value)

; 	ld	a, ppuokg		; let's remote run...
; 	out	(pphnddat), a
	tPP_OKGO
	ld	b,$20			; <---- tunable
tupwdly:	nop
	djnz	tupwdly
	in	a, (pphnddat)		; in remote answer
	bit	PB_INIT, a		; check for stop requests
	ld	a,c
	pop	bc
	ret

;--------------------
;; Routines to manage data send (download) over parallel port
;;
;; PSNDCH - send a byte over parallel
;;
;; use:
;; HL - point to byte to transfer (updated after exec)
;; unclean register usage: A, DE
tpsndch:
	in	a, (pphnddat)		; wait synchro strobe from remote
	bit	PB_STRB, a
	jr	nz, tpsndch

	ld	a, (hl)
	out	(ppdatdat), a		; out data and then emit ready signal
	inc	hl
; 	ld	a, ppdrdy
; 	out	(pphnddat), a
	tPP_RDY
					;; remote should reset strobe when PPDRDY is get...
tpwackb:
	in	a, (pphnddat)		; wait ack from remote
	bit	PB_INIT, a
	jr	z, tpwackb

; 	ld	a, ppdokg		; reset ready bit and let remote run waiting 1 msec.
; 	out	(pphnddat), a
	tPP_OKGO
					;; remote should reset ack when PPDOKG is get...
	push	bc
	ld	b,$20			; <---- tunable
tpswdly:	nop
	djnz	tpswdly
	pop	bc
	ret

;
;; PRCVBLK - upload a block through parallel link
;;
;; use:
;;	DE - offset of storage area
;;	BC - block size
;; unclean register usage: A, HL, IY
;; return:
;; C: Rx status 0 = ok >0 = error
tprcvblk:
	push	af
	ex	de,hl			; offset in HL
; 	ld	a, ppuini		; init parallel port for rx
; 	out	(pphnddat),a
	tPP_CLR
	tPP_SET_RX
	ld	de,tcksum
	xor	a			; used to calc chetcksum
	ld	(de),a
	call	tuplchr			; get two bytes of block size
	ld	(tszbuf),a
	call	tuplchr
	ld	(tszbuf+1),a
	ld	iy,(tszbuf)		; IY count from remote size
tprbloo:	call	tuplchr			; begin real transfer
	jr	nz, tprnak		; stopped here: error!
	ld	(hl),a			; store data
	ld	a,(de)			; update csum
	add	a,(hl)
	ld	(de),a
	inc	hl
	dec	iy
	dec	bc			; check for upload end
	ld	a,b
	or	c
	jr	nz,tprbloo		; next
	ld	(tszbuf),iy		; receive buffer full
	ld	bc,(tszbuf)
	ld	a,b			; received size match?
	or	c
	jr	nz, tprnak		; no
	call	tuplchr			; flush sender waiting chetcksum byte
	ld	b,a
	ld	a,(de)			; block end: calc. final csum
	cpl
	inc	a
	cp	b			; match ?
	jr	z, tprbend		; yes: exit
tprnak:
; 	ld	a,ppuack		; send negative aknowledge
; 	out	(pphnddat),a
	tPP_NACK
	ld	c, 1			; rx error
tprbend:	ld	de, 5			; 5 msec wait
	call	delay
; 	ld	a, ppuini		; clean handshake
; 	out	(pphnddat), a
	tPP_CLR
	pop	af
	ret

;;
;; PSNDBLK - send a block over parallel link
;;
;; use:
;; DE - point to the base of block to transfer
;; BC - block size
;; unclean register usage: A, HL
;; return:
;; C: Tx status 0 = ok >0 = error
;;
tpsndblk:
	push	af
	ex	de,hl			; offset in HL
	ld	de,tcksum
	xor	a			; will carry the chetcksum
	ld	(de),a
	ld	(tszbuf), bc		; store block size to send it
; 	ld	a, ppdini		; setup port for tx
; 	out	(pphnddat), a
	tPP_CLR
	tPP_SET_TX
	push	hl			; save DMA in HL
	ld	hl, tszbuf
	call	tpsndch			; send len. lsb
	call	tpsndch			; send len. msb
	pop	hl			; restore HL
tpsnxtc:
	ld	a,(de)
	add	a,(hl)			; block bytes summing
	ld	(de),a
	call	tpsndch			; send byte
	dec	bc			; check for transfer end
	ld	a, b
	or	c
	jr	nz, tpsnxtc
	ld	a,(de)			; block end: calc. final csum
	cpl
	inc	a
	ld	hl, tszbuf		; store in first byte of SZBUF
	ld	(hl),a
	call	tpsndch			; send csum
	ld	de, 34			; 34 more msec. to get okgo
	call	delay
; 	ld	a, ppdstp
; 	out	(pphnddat), a
	tPP_STOP
	ld	de, 35			; 35 msec. to stop remote
	call	delay
; 	ld	a, ppuini
; 	out	(pphnddat), a		; leave parallel clean
	tPP_CLR
	ld	c, 0			; ret ok (maybe)
	in	a, (pphnddat)		; in result code
	and	00001010b		; mask
	cp	00001010b		; init and strobe set ?
	jr	nz, tpsbok
	ld	c, 1			; ret nok on reg. C
tpsbok:
	pop	af
	ret

; ;----------------------------------------------------------
; ; PC-LINKED VIRTUAL DISK HANDLE ROUTINES
; ; ---------------------------------------------------------
; ;;
; ;; VDSKRD - read a sector form remote
; ;;
; ;; use:
; ;;	none
; ;; unclean register usage: A, IY
;
; vdskrd:
; 	push	iy
; 	push	de
; 	push	bc
; 	push	hl
; 	ld	d, 2			; retries
; vdrtry:	ld	iy, tvdskbuf
; 	ld	hl, ts_vhdr
; 	ld	b, 4
; vdrsl1: ld	c, (hl)
; 	ld	(iy + 0), c
; 	inc	iy
; 	inc	hl
; 	djnz	vdrsl1
;
; 	ld	c, vdrdsec		; read command
; 	ld	(iy + 0), c
; 	ld	hl, fdrvbuf
; 	ld	c, (hl)			; drive
; 	ld	(iy + 1), c
; 	ld	bc, (fsecbuf)		; sector
; 	dec	bc			; base sector # is zero...
; 	ld	(iy + 2), c
; 	ld	(iy + 3), b
; 	ld	bc, (ftrkbuf)		; track
; 	ld	(iy + 4), c
; 	ld	(iy + 5), b
;
; 	push	de
; 	ld	de, tvdskbuf		; command offset
; 	ld	bc, vdbufsz		; block size
; 	call	tpsndblk			; send command block
; 	pop	de
; 	ld	a, c
; 	or	a			; what happens ?
; 	jr	z, vdrok		; tx ok
; 	dec	d			; retry ?
; 	jr	nz, vdrtry
; 	ld	a, 1			; ret tx err
; 	jr	vdrnok
; 					; receive sector now
; vdrok:	push	de
; 	ld	de, (frdpbuf)		; set dma address
; 	ld	bc,(csptr+2)
; 	call	tprcvblk			; download sector
; 	pop	de
; 	ld	a, c
; 	or	a			; what happens ?
; 	jr	z, vdrend		; rx ok
; 	dec	d			; retry ?
; 	jr	nz, vdrtry
; 	ld	a, 1			; ret rx err
; 	jr	vdrnok
; vdrend:	xor	a
; vdrnok:	pop 	hl
; 	pop	bc
; 	pop	de
; 	pop	iy
; 	ret
;
; ;;
; ;; VDSKWR - write a sector to remote
; ;;
; ;; use:
; ;;	none
; ;; unclean register usage: A
;
; vdskwr:
; 	push	iy
; 	push	de
; 	push	bc
; 	push	hl
; 	ld	d, 2			; retries
; vdwtry:	ld	iy, tvdskbuf
; 	ld	hl, ts_vhdr
; 	ld	b, 4
; vdwsl1: ld	c, (hl)
; 	ld	(iy + 0), c
; 	inc	iy
; 	inc	hl
; 	djnz	vdwsl1
;
; 	ld	c, vdwrsec		; read command
; 	ld	(iy + 0), c
; 	ld	hl, fdrvbuf
; 	ld	c, (hl)			; drive
; 	ld	(iy + 1), c
; 	ld	bc, (fsecbuf)		; sector
; 	dec	bc			; base sector # is zero...
; 	ld	(iy + 2), c
; 	ld	(iy + 3), b
; 	ld	bc, (ftrkbuf)		; track
; 	ld	(iy + 4), c
; 	ld	(iy + 5), b
;
; 	push	de
; 	ld	de, tvdskbuf		; command offset
; 	ld	bc, vdbufsz		; block size
; 	call	tpsndblk			; send command block
; 	pop	de
; 	ld	a, c
; 	or	a			; what happens ?
; 	jr	z, vdwok		; tx ok
; 	dec	d			; retry ?
; 	jr	nz, vdwtry
; 	ld	a, 1			; ret tx err
; 	jr	vdwnok
; 					; receive sector now
; vdwok:	push	de
; 	ld	de, (frdpbuf)		; set dma address
; 	ld	bc, (csptr+2)		; vdisk sector length
; 	call	tpsndblk			; upload sector
; 	pop	de
; 	ld	a, c
; 	or	a			; what happens ?
; 	jr	z, vdwend		; tx ok
; 	dec	d			; retry ?
; 	jr	nz, vdwtry
; 	ld	a, 1			; ret tx err
; 	jr	vdwnok
; vdwend:	ld	a, 0
; vdwnok:	pop 	hl
; 	pop	bc
; 	pop	de
; 	pop	iy
; 	ret

tstrwait:
	defb	"Waiting host...  ",0
tstrload:
	defb	"loading at: ",0

tmrx:	defb	"Rx",' ',0

tmnot:	defb	"fail",0
tmrdy:	defb	"ok",' ',0


