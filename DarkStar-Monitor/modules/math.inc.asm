;
;=======================================================================
;
; Modular Z80 DarkStar (NE Z80) Monitor
;
;=======================================================================
;
; Simple math utilities
; ---------------------------------------------------------------------

;;
;; DIV16 - 16 BY 16 BIT DIVISION
;;
;; in BC = dividend
;; in DE = divisor
;; ----
;; out BC = quotient
;; out DE = remainder
div16:	ld	a,b
	ld	b,16
	ld	hl,0
divlo:	rl	c
	rla
	adc	hl,hl
	sbc	hl,de
	jr	nc,$+3
	add	hl,de
	ccf
	djnz	divlo
	rl	c
	rla
	ld	b,a
	ex	de,hl
	ret
;;
;;	TRANSK - calculate skew factor on-the-fly
;;
;; input	E = current sec
;;	 	C = # secs/track
;; output 	A = trans. sec
transk:	inc	c		; need for comparison
	ld	b,e		; init B as sec. counter
	ld	a,1		; start #
trask1:	dec	b		; end ?
	ret	z		; yes
	add	a,6		; apply skew factor
	cp	c		; # overflow ?
	jr	c,trask1	; no: next
	sub	c		; correct to lowest
	inc	a		; done
	cp	1		; overflow ?
	jr	nz,trask1	; no, next
	inc	a		; yes, adjust
	jr	trask1		; next


;;
;;	MUL16 - 16x16 bit multiplication
;;
;; 	in  DE = multiplicand
;;	    BC = multiplier
;;	out DE = result
mul16:	ld	a,c		; A = low mpler
	ld	c,b		; C = high mpler
	ld	b,16		; counter
	ld	hl,0
ml1601:	srl	c		; right shift mpr high
	rra			; rot. right mpr low
	jr	nc,ml1602	; test carry
	add	hl,de		; add mpd to result
ml1602:	ex	de,hl
	add	hl,hl		; double shift mpd
	ex	de,hl
	djnz	ml1601
	ex	de,hl
	ret
;;
;;	OFFCAL - apply a read skew factor to sequential written
;;	         floppies. Used by bootloader and CP/M WBOOT.
;;
;;	in   E = current sector counter
;;	    IY = base address
;;	    IX = dpt
offcal:
	ld	c,(ix+0)	; loads sec./track
	call	transk		; trans. sec. (in A)
	ld	(fsecbuf),a	; directly sets sector (no more then 255 secs/track !!)
	push	de		; saves DE
	ld	e,a		; now E has trans. value
	ld	a,(ftrkbuf)	; load track, no more than 255 system tracks !!
	ld	b,a		; counter
	or	a		; zero ?
	jr	z,offzer	; no
offgtz:	xor	a		; clear
offgt1:	add	a,(ix+0)	; shift index one track
	djnz	offgt1		; next
	add	a,e		; add sec. index
	ld	e,a		; reload on E
offzer: dec	e		; correct index to zero base
	dec	e
	ld	d,0		; DE now is dma offset
; 	PUSH	HL		; save base
	ld	c,(ix+2)	; sector len in BC
	ld	b,(ix+3)
	call	mul16		; calc relative offset (sec len x offset)
	push	iy
	pop	hl		; HL now base address
	add	hl,de		; calc final address
	ld	(frdpbuf),hl	; apply dma
	pop	de		; restore secs counters
	ret


