;
;=======================================================================
;
; Modular Z80 DarkStar (NE Z80) Monitor
;
;=======================================================================
;
; Generic I/O ports
; ---------------------------------------------------------------------

gioini:
	ld	a,$cf			; 11-00-1111 mode ctrl word
					; Mode 3 (bit mode port B)
	out	(crtprntcnt),a		; send to PIO0
	ex	af,af'
	xor	a			; bit mask 00000000 (all outputs)
	out	(crtprntcnt),a		; send to PIO0
	ex	af,af'			; reload mode 3 ctrl word
	out	(crtkeybcnt),a		; send to PIO1
	ex	af,af'
	dec	a			; load bit mask 11111111 (all inputs)
	out	(crtkeybcnt),a		; send to PIO1
	ex	af,af'
	out	(crtservcnt),a		; reload mode 3 ctrl word
	ld	a,$5d			; bit mask 01011101
					;          ||||||||- b0 in  (printer busy line)
					;          |||||||-- b1 out (40/80 col. mode)
					;          ||||||--- b2 in  (unassigned)
					;          |||||---- b3 in  (unassigned)
					;          ||||----- b4 in  (unassigned)
					;          ||------- b5 out (ds1320 clock line)
					;          ||------- b6 in  (ds1320 i/o line)
					;          |-------- b7 out (ds1320 RST line)
	out	(crtservcnt),a		; send to PIO2
	in	a,(crtservdat)		; read data port PIO2
	res	clkrst,a		; ensure DS1320 RST line is low (active)
	res	1,a			; Modo 40/80 colonne (80)
	out	(crtservdat),a		; send to PIO2
	ret

;;
;; PRNCHR - send a char to printer port (from C)
;
prnchr:
	in	a,(crtservdat) 
	bit	prntbusybit,a
	jr	nz,prnchr
	ld	a,c
	out	(crtprntdat),a
	ret


