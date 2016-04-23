;
;=======================================================================
;
; Modular Z80 DarkStar (NE Z80) Monitor
;
;=======================================================================
;
; Delay routine
; ---------------------------------------------------------------------

;;
;; DELAY
;;
;; This routine generate a delay from 1 to 65535 milliseconds.
;;

DELAY:				; was F13D
	PUSH	BC		; 11 c.
	PUSH	AF		; 11 c.
DLY2:
	LD	C, MSCNT	; 7 c.	(assume de = 1 = 1msec.)
DLY1:
	DEC	C		; 4 c. * MSCNT
	JR	NZ, DLY1	; 7/12 c. * MSCNT
	DEC	DE		; 6 c.
	LD	A, D		; 4 c.
	OR	E		; 4 c.
	JR	NZ, DLY2	; 7/12 c.

	POP	AF		; 10 c.
	POP	BC		; 10 c.
	RET			; 10.c

;; MSEC evaluation (ret ignored):
;
; 42 + (de) * (7 + 16 * MSCNT - 5 + 26) - 5
;
; 65 + 16 * MSCNT = ClockSpeed   (ClockSpeed is 1920 for Z80 DarkStar)
; (ClockSpeed - 65) / 16 = MSCNT = 116
; 2006/04/09:
; clock speed has been increased to 4MHz so now:
; (ClockSpeed - 65) / 16 = MSCNT = 116
; is
; (4000 - 65) / 16 = 246 = MSCNT
;

