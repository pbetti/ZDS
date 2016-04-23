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
CKIRET:	PUSH	AF
	LD	A,(TMPBYTE)
	BIT	5,A			; interrupt disabled if zero
	JR	Z,CKINOI
	EI				; enabled...
CKINOI:	POP	AF
	RET

;;
;; reset (disable) interrupts restore
;;
GDISIN:
	LD	HL,TMPBYTE
	RES	5,(HL)
	RET
;;
;; set (enable) interrupts restore
;;
GENAIN:
	LD	HL,TMPBYTE
	SET	5,(HL)
	RET

