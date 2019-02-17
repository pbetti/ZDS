;
;=======================================================================
;
; Modular Z80 DarkStar (NE Z80) Monitor
;
;=======================================================================
;
; UZI/FUZIX BIOS support utilities
; ---------------------------------------------------------------------

	extern	inline, bbconout


;;
;; Handle UZI type bootstrap
;;
uziboot:
uzidboot:
	ld	c,02h			; reset input case
	call	bbconout
	call	inline
	defb	cr,lf,"Invalid partition.",cr,lf,0
	ret
