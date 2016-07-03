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

delay:				; was F13D
	push	bc		; 11 c.
	push	af		; 11 c.
dly2:
	ld	c, mscnt	; 7 c.	(assume de = 1 = 1msec.)
dly1:
	dec	c		; 4 c. * MSCNT
	jr	nz, dly1	; 7/12 c. * MSCNT
	dec	de		; 6 c.
	ld	a, d		; 4 c.
	or	e		; 4 c.
	jr	nz, dly2	; 7/12 c.

	pop	af		; 10 c.
	pop	bc		; 10 c.
	ret			; 10.c

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

