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
	ld	ix,csptr
	ld	(miobyte),a
	ld	b,rtrycnt		; # retries
frwnxt:
	call	fseek			; go to trk/sec
	jr	nz,fioend

	di				; not interruptible
	ld	hl,(frdpbuf)
	ld	e,(ix+2)		; need to know buffer size on r/w
	ld	d,(ix+3)

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

	ld	a,(miobyte)		; nok
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


