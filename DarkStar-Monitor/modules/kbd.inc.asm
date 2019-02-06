;
;=======================================================================
;
; Modular Z80 DarkStar (NE Z80) Monitor
;
;=======================================================================
;
; Keyboard management
;
; NOTE: This is still to manage keyboard from LX529 port, WITHOUT
; interrupts.
; Will be rewritten for the new port ASAP
; ---------------------------------------------------------------------

;;
;; BCONIN - main keyboard input handle
;
cirbf:
	xor	a
	ld	(kbdbyte),a		; clear buffer
bconin:
	in	a,(crtkeybdat)		; in from PIO
	cpl
	bit	7,a			; pressed ?
	jr	z,cirbf			; no: wait for user action
	push	hl			; yes
	ld	hl,miobyte
	bit	1,(hl)			; autorepeat off ?
	jr	nz,ciwdp
	ld	hl,kbdbyte
	cp	(hl)			; test input with buffer
	jr	z,cieqb			; EQUALS: enter autorepeat mode
	ld	hl,$f0ff		; auto repeat start time
	jr	ciprc			; jump to press cycle
cieqb:
	ld	hl,$1400		; button autorepeat delay (in AR mode)
ciprc:
	push	af
cisti:
	in	a,(crtkeybdat)		; press cycle: check for keyb release
	cpl
	bit	7,a			; is still pressed?
	jr	z,cigon			; no, go on
	dec	hl			; dec AR loop time
	ld	a,l
	or	h			; timeout reached ?
	jr	nz,cisti		; no timeout: check again
cigon:
	pop	af			; now process input
	ld	hl,miobyte
cilop:
	ld	(kbdbyte),a
	res	7,a			; make ASCII
	bit	3,(hl)			; transform to uppercase ?
	pop	hl
	ret	z			; no
	cp	'a'			; yes: is less then 'a' ?
	ret	m			; yes: return, already ok
	cp	'{'			; no: then is greater than 'z' ?
	ret	p			; yes: ok!
	res	5,a			; no: convert uppercase...
	ret
ciwdp:
	in	a,(crtkeybdat)		; press cycle: check for keyb release
	cpl
	bit	7,a			; is still pressed?
	jr	nz,ciwdp		; yes, wait
	jr	cilop


;;
bconst:
	in	a,(crtkeybdat)
	cpl
	bit	7,a
	ex	af,af'
	xor	a
	ld	(kbdbyte),a		; clear AR buffer...
	ex	af,af'
	jr	nz,bconsp
	xor	a			; no data
	ret
bconsp:
	ld	a,$ff			; ok get data
	ret


;;


