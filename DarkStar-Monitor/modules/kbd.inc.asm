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
CIRBF:	XOR	A
	LD	(KBDBYTE),A		; clear buffer
BCONIN:
	IN	A,(CRTKEYBDAT)		; in from PIO
	CPL
	BIT	7,A			; pressed ?
	JR	Z,CIRBF			; no: wait for user action
	PUSH	HL			; yes
	LD	HL,KBDBYTE
	CP	(HL)			; test input with buffer
	JR	Z,CIEQB			; EQUALS: enter autorepeat mode
	LD	HL,$A0FF		; auto repeat start time
	JR	CIPRC			; jump to press cycle
CIEQB:	LD	HL,$0400		; button autorepeat delay (in AR mode)
CIPRC:	PUSH	AF
CISTI:	IN	A,(CRTKEYBDAT)		; press cycle: check for keyb release
	CPL
	BIT	7,A			; is still pressed?
	JR	Z,CIGON			; no, go on
	DEC	HL			; dec AR start time
	LD	A,L
	OR	H			; timeout reached ?
	JR	NZ,CISTI		; no timeout: check again
CIGON:	POP	AF			; now process input
	LD	(KBDBYTE),A
	RES	7,A			; make ASCII
	LD	HL,MIOBYTE
CILOP:	BIT	3,(HL)			; transform to uppercase ?
	POP	HL
	RET	Z			; no
	CP	'a'			; yes: is less then 'a' ?
	RET	M			; yes: return, already ok
	CP	'{'			; no: then is greater than 'z' ?
	RET	P			; yes: ok!
	RES	5,A			; no: convert uppercase...
	RET

;;
BCONST:
	IN	A,(CRTKEYBDAT)
	CPL
	BIT	7,A
	JR	NZ,BCONSP
	XOR	A
	LD	(KBDBYTE),A		; clear AR buffer...
	RET
BCONSP:	LD	A,$FF
	RET


;;
	
