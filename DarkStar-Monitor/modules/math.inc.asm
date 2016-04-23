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
DIV16:	LD	A,B
	LD	B,16
	LD	HL,0
DIVLO:	RL	C
	RLA
	ADC	HL,HL
	SBC	HL,DE
	JR	NC,$+3
	ADD	HL,DE
	CCF
	DJNZ	DIVLO
	RL	C
	RLA
	LD	B,A
	EX	DE,HL
	RET
;;
;;	TRANSK - calculate skew factor on-the-fly
;;
;; input	E = current sec
;;	 	C = # secs/track
;; output 	A = trans. sec
TRANSK:	INC	C		; need for comparison
	LD	B,E		; init B as sec. counter
	LD	A,1		; start #
TRASK1:	DEC	B		; end ?
	RET	Z		; yes
	ADD	A,6		; apply skew factor
	CP	C		; # overflow ?
	JR	C,TRASK1	; no: next
	SUB	C		; correct to lowest
	INC	A		; done
	CP	1		; overflow ?
	JR	NZ,TRASK1	; no, next
	INC	A		; yes, adjust
	JR	TRASK1		; next


;;
;;	MUL16 - 16x16 bit multiplication
;;
;; 	in  DE = multiplicand
;;	    BC = multiplier
;;	out DE = result
MUL16:	LD	A,C		; A = low mpler
	LD	C,B		; C = high mpler
	LD	B,16		; counter
	LD	HL,0
ML1601:	SRL	C		; right shift mpr high
	RRA			; rot. right mpr low
	JR	NC,ML1602	; test carry
	ADD	HL,DE		; add mpd to result
ML1602:	EX	DE,HL
	ADD	HL,HL		; double shift mpd
	EX	DE,HL
	DJNZ	ML1601
	EX	DE,HL
	RET
;;
;;	OFFCAL - apply a read skew factor to sequential written
;;	         floppies. Used by bootloader and CP/M WBOOT.
;;
;;	in   E = current sector counter
;;	    IY = base address
;;	    IX = dpt
OFFCAL:
	LD	C,(IX+0)	; loads sec./track
	CALL	TRANSK		; trans. sec. (in A)
	LD	(FSECBUF),A	; directly sets sector (no more then 255 secs/track !!)
	PUSH	DE		; saves DE
	LD	E,A		; now E has trans. value
	LD	A,(FTRKBUF)	; load track, no more than 255 system tracks !!
	LD	B,A		; counter
	OR	A		; zero ?
	JR	Z,OFFZER	; no
OFFGTZ:	XOR	A		; clear
OFFGT1:	ADD	A,(IX+0)	; shift index one track
	DJNZ	OFFGT1		; next
	ADD	A,E		; add sec. index
	LD	E,A		; reload on E
OFFZER: DEC	E		; correct index to zero base
	DEC	E
	LD	D,0		; DE now is dma offset
; 	PUSH	HL		; save base
	LD	C,(IX+2)	; sector len in BC
	LD	B,(IX+3)
	CALL	MUL16		; calc relative offset (sec len x offset)
; 	EX	DE,HL		; move result (rel.offset) in DE
	PUSH	IY
	POP	HL		; HL now base address

; 	POP	HL		; restore base address
; 	PUSH	HL		; re-save
	ADD	HL,DE		; calc final address
	LD	(FRDPBUF),HL	; apply dma
; 	POP	HL		; re-restore base address
	POP	DE		; restore secs counters
	RET

