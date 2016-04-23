;
;=======================================================================
;
; Modular Z80 DarkStar (NE Z80) Monitor
;
;=======================================================================
;
; Generic I/O ports
; ---------------------------------------------------------------------

GIOINI:
	LD	A,$CF			; 11-00-1111 mode ctrl word
					; Mode 3 (bit mode port B)
	OUT	(CRTPRNTCNT),A		; send to PIO0
	EX	AF,AF'
	XOR	A			; bit mask 00000000 (all outputs)
	OUT	(CRTPRNTCNT),A		; send to PIO0
	EX	AF,AF'			; reload mode 3 ctrl word
	OUT	(CRTKEYBCNT),A		; send to PIO1
	EX	AF,AF'
	DEC	A			; load bit mask 11111111 (all inputs)
	OUT	(CRTKEYBCNT),A		; send to PIO1
	EX	AF,AF'
	OUT	(CRTSERVCNT),A		; reload mode 3 ctrl word
	LD	A,$5D			; bit mask 01011101
					;          ||||||||- b0 in  (printer busy line)
					;          |||||||-- b1 out (40/80 col. mode)
					;          ||||||--- b2 in  (unassigned)
					;          |||||---- b3 in  (unassigned)
					;          ||||----- b4 in  (unassigned)
					;          ||------- b5 out (ds1320 clock line)
					;          ||------- b6 in  (ds1320 i/o line)
					;          |-------- b7 out (ds1320 RST line)
	OUT	(CRTSERVCNT),A		; send to PIO2
	IN	A,(CRTSERVDAT)		; read data port PIO2
	RES	CLKRST,A		; ensure DS1320 RST line is low (active)
	RES	1,A			; Modo 40/80 colonne (80)
	OUT	(CRTSERVDAT),A		; send to PIO2
	RET

;;
;; PRNCHR - send a char to printer port (from C)
;
PRNCHR:
	IN	A,(CRTSERVDAT) 
	BIT	PRNTBUSYBIT,A
	JR	NZ,PRNCHR
	LD	A,C
	OUT	(CRTPRNTDAT),A
	RET

