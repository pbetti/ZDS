;
;=======================================================================
;
; Modular Z80 DarkStar (NE Z80) Monitor
;
;=======================================================================
;
; Parallel communication - parallel 2
; ---------------------------------------------------------------------

vdskbuf:
	defs	vdbufsz			; i/o command buffer
szbuf:	defs	2
cksum:	defb	0
s_vhdr:	defb	"@IO@"

PP_SET_RX macro
	ld	a,$cf			; 11-00-1111 mode ctrl word
	out	(ppdatctr),a		; data port mode 3
	ld	a,$ff			; load bit mask 11111111 (all inputs)
	out	(ppdatctr),a		; data port in RX
	in	a,(pphnddat)
	res	PB_TXRX,a
	res	PL_RX,a
	out	(pphnddat),a
	endm

PP_SET_TX macro
	in	a,(pphnddat)
	set	PB_TXRX,a
	res	PL_TX,a
	out	(pphnddat),a
	ld	a,$cf			; 11-00-1111 mode ctrl word
	out	(ppdatctr),a		; data port mode 3
	ld	a,$00			; load bit mask 00000000 (all outputs)
	out	(ppdatctr),a		; data port in RX
	endm

PP_RDY	macro
	in	a,(pphnddat)
	set	PB_BUSY,a
	res	PB_ACK,a
	out	(pphnddat),a
	endm

PP_NACK	macro
	in	a,(pphnddat)
	or	00001010b
	out	(pphnddat),a
	endm

PP_STOP	macro
	in	a,(pphnddat)
	or	00001010b
	out	(pphnddat),a
	endm

PP_OKGO	macro
	in	a,(pphnddat)
	res	PB_BUSY,a
	set	PB_ACK,a
	out	(pphnddat),a
	endm

PP_CLR	macro
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

uplchr:
	in	a, (pphnddat)		; wait for remote ready to tx
	bit	PB_INIT, a
	ret	nz
	bit	PB_STRB, a
	jr	nz, uplchr

	push	bc
	PP_RDY
upwstrb:
	in	a, (pphnddat)		; wait for data
	bit	PB_STRB, a
	jr	z, upwstrb

	in	a,(ppdatdat)
	ld	c, a			; copy on C (return value)

	PP_OKGO
	ld	b,$20			; <---- tunable
upwdly:	nop
	djnz	upwdly
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
psndch:
	in	a, (pphnddat)		; wait synchro strobe from remote
	bit	PB_STRB, a
	jr	nz, psndch

	ld	a, (hl)
	out	(ppdatdat), a		; out data and then emit ready signal
	inc	hl
	PP_RDY
					;; remote should reset strobe when PPDRDY is get...
pwackb:
	in	a, (pphnddat)		; wait ack from remote
	bit	PB_INIT, a
	jr	z, pwackb

	PP_OKGO					;; remote should reset ack when PPDOKG is get...
	push	bc
	ld	b,$20			; <---- tunable
pswdly:	nop
	djnz	pswdly
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
prcvblk:
	push	af
	ex	de,hl			; offset in HL
	PP_CLR				; init parallel port for rx
	PP_SET_RX
	ld	de,cksum
	xor	a			; used to calc checksum
	ld	(de),a
	call	uplchr			; get two bytes of block size
	ld	(szbuf),a
	call	uplchr
	ld	(szbuf+1),a
	ld	iy,(szbuf)		; IY count from remote size
prbloo:	call	uplchr			; begin real transfer
	jr	nz, prnak		; stopped here: error!
	ld	(hl),a			; store data
	ld	a,(de)			; update csum
	add	a,(hl)
	ld	(de),a
	inc	hl
	dec	iy
	dec	bc			; check for upload end
	ld	a,b
	or	c
	jr	nz,prbloo		; next
	ld	(szbuf),iy		; receive buffer full
	ld	bc,(szbuf)
	ld	a,b			; received size match?
	or	c
	jr	nz, prnak		; no
	call	uplchr			; flush sender waiting checksum byte
	ld	b,a
	ld	a,(de)			; block end: calc. final csum
	cpl
	inc	a
	cp	b			; match ?
	jr	z, prbend		; yes: exit
prnak:
	PP_NACK				; send negative aknowledge
	ld	c, 1			; rx error
prbend:	ld	de, 5			; 5 msec wait
	call	delay
	PP_CLR				; clean handshake
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
psndblk:
	push	af
	ex	de,hl			; offset in HL
	ld	de,cksum
	xor	a			; will carry the checksum
	ld	(de),a
	ld	(szbuf), bc		; store block size to send it
	PP_CLR				; setup port for tx
	PP_SET_TX
	push	hl			; save DMA in HL
	ld	hl, szbuf
	call	psndch			; send len. lsb
	call	psndch			; send len. msb
	pop	hl			; restore HL
psnxtc:
	ld	a,(de)
	add	a,(hl)			; block bytes summing
	ld	(de),a
	call	psndch			; send byte
	dec	bc			; check for transfer end
	ld	a, b
	or	c
	jr	nz, psnxtc
	ld	a,(de)			; block end: calc. final csum
	cpl
	inc	a
	ld	hl, szbuf		; store in first byte of SZBUF
	ld	(hl),a
	call	psndch			; send csum
	ld	de, 4			; 4 more msec. to get okgo
	call	delay
	PP_STOP
	ld	de, 5			; 5 msec. to stop remote
	call	delay
	PP_CLR
	ld	c, 0			; ret ok (maybe)
	in	a, (pphnddat)		; in result code
	and	00001010b		; mask
	cp	00001010b		; init and strobe set ?
	jr	nz, psbok
	ld	c, 1			; ret nok on reg. C
psbok:
	pop	af
	ret

;----------------------------------------------------------
; PC-LINKED VIRTUAL DISK HANDLE ROUTINES
; ---------------------------------------------------------
;;
;; VDSKRD - read a sector form remote
;;
;; use:
;;	none
;; unclean register usage: A, IY

vdskrd:
	push	iy
	push	de
	push	bc
	push	hl
	ld	d, 2			; retries
vdrtry:	ld	iy, vdskbuf
	ld	hl, s_vhdr
	ld	b, 4
vdrsl1: ld	c, (hl)
	ld	(iy + 0), c
	inc	iy
	inc	hl
	djnz	vdrsl1

	ld	c, vdrdsec		; read command
	ld	(iy + 0), c
	ld	hl, fdrvbuf
	ld	c, (hl)			; drive
	ld	(iy + 1), c
	ld	bc, (fsecbuf)		; sector
	dec	bc			; base sector # is zero...
	ld	(iy + 2), c
	ld	(iy + 3), b
	ld	bc, (ftrkbuf)		; track
	ld	(iy + 4), c
	ld	(iy + 5), b

	push	de
	ld	de, vdskbuf		; command offset
	ld	bc, vdbufsz		; block size
	call	psndblk			; send command block
	pop	de
	ld	a, c
	or	a			; what happens ?
	jr	z, vdrok		; tx ok
	dec	d			; retry ?
	jr	nz, vdrtry
	ld	a, 1			; ret tx err
	jr	vdrnok
					; receive sector now
vdrok:	push	de
	ld	de, (frdpbuf)		; set dma address
	ld	bc,(csptr+2)
	call	prcvblk			; download sector
	pop	de
	ld	a, c
	or	a			; what happens ?
	jr	z, vdrend		; rx ok
	dec	d			; retry ?
	jr	nz, vdrtry
	ld	a, 1			; ret rx err
	jr	vdrnok
vdrend:	xor	a
vdrnok:	pop 	hl
	pop	bc
	pop	de
	pop	iy
	ret

;;
;; VDSKWR - write a sector to remote
;;
;; use:
;;	none
;; unclean register usage: A

vdskwr:
	push	iy
	push	de
	push	bc
	push	hl
	ld	d, 2			; retries
vdwtry:	ld	iy, vdskbuf
	ld	hl, s_vhdr
	ld	b, 4
vdwsl1: ld	c, (hl)
	ld	(iy + 0), c
	inc	iy
	inc	hl
	djnz	vdwsl1

	ld	c, vdwrsec		; read command
	ld	(iy + 0), c
	ld	hl, fdrvbuf
	ld	c, (hl)			; drive
	ld	(iy + 1), c
	ld	bc, (fsecbuf)		; sector
	dec	bc			; base sector # is zero...
	ld	(iy + 2), c
	ld	(iy + 3), b
	ld	bc, (ftrkbuf)		; track
	ld	(iy + 4), c
	ld	(iy + 5), b

	push	de
	ld	de, vdskbuf		; command offset
	ld	bc, vdbufsz		; block size
	call	psndblk			; send command block
	pop	de
	ld	a, c
	or	a			; what happens ?
	jr	z, vdwok		; tx ok
	dec	d			; retry ?
	jr	nz, vdwtry
	ld	a, 1			; ret tx err
	jr	vdwnok
					; receive sector now
vdwok:	push	de
	ld	de, (frdpbuf)		; set dma address
	ld	bc, (csptr+2)		; vdisk sector length
	call	psndblk			; upload sector
	pop	de
	ld	a, c
	or	a			; what happens ?
	jr	z, vdwend		; tx ok
	dec	d			; retry ?
	jr	nz, vdwtry
	ld	a, 1			; ret tx err
	jr	vdwnok
vdwend:	ld	a, 0
vdwnok:	pop 	hl
	pop	bc
	pop	de
	pop	iy
	ret


