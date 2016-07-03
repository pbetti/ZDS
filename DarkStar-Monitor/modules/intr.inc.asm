;
;=======================================================================
;
; Modular Z80 DarkStar (NE Z80) Monitor
;
;=======================================================================
;
; Interrupt handling (old non mode 2 for now) 
; ---------------------------------------------------------------------

;
;; return with interrupt enable checksum
;;
ckiret:	push	af
	ld	a,(tmpbyte)
	bit	5,a			; interrupt disabled if zero
	jr	z,ckinoi
	ei				; enabled...
ckinoi:	pop	af
	ret

;;
;; reset (disable) interrupts restore
;;
gdisin:
	ld	hl,tmpbyte
	res	5,(hl)
	ret
;;
;; set (enable) interrupts restore
;;
genain:
	ld	hl,tmpbyte
	set	5,(hl)
	ret


