;
;=======================================================================
;
; Modular Z80 DarkStar (NE Z80) Monitor
;
;=======================================================================
;
; MMU
; ---------------------------------------------------------------------

;; Reset MMU
; MMURESET:
; 	LD	E,16			; ram page counter (15 + 1 for loop)
; 	LD	C,MMUPORT		; MMU I/O address
; 	XOR	A
; 	LD	B,A
; 	LD	D,A
; MMURST1:
; 	DEC	E
; 	JR	Z, MMURST2
; 	OUT	(C),D
; 	INC	D			; phis. page address 00xxxh, 01xxxh, etc.
; 	ADD	A,$10
; 	LD	B,A			; logical page 0xh, 1xh, etc.
; 	JR	MMURST1
; MMURST2:
; 	LD	D,$C0			; EEPROM page 0 (here) @ F000h
; 	OUT	(C),D
; 	RET

;;
;; Map page into logical space
;;
;; D - physical page (0-ff)
;; B - logical page (0-f)
;; Use C
;; Registers are not saved because we could
;; not rely on stack position
;;
; mmupmap:
; 	ld	c,mmuport
; 	out	(c),d
; 	ret


;; FMEMSIZ - Size memory in physical space
;;           DO NOT TRY to check eeprom region
;;
fmemsiz:
	ld	b,mmtpapag		; last ram page before eeprom
	ld	hl,$ffff
fmemnp:
	inc	h
	ld	a,(hl)
	cpl
	ld	(hl),a
	cp	(hl)
	cpl
	ld	(hl),a
	jr	nz,fmestp
	ld	a,h
	cp	b
	jr	nz,fmemnp
	ret
fmestp:
	dec	h			; error or unavailable page
	ret

;;
;; Size banked memory
;;
;; Check for memory in address 0000F to BFFFF
;; First 14 pages are always tested at startup and
;; above BFFFF starts eeprom space
;;
;; Use all registers + stack
;;
;; *** WE NEED STACK IN A SAFE PLACE ***
;;
bnkmsiz:
	ld	b,mmutstpage << 4	; save actual test page
	ld	c,mmuport
	ld	hl,mmutstaddr
	in	a,(c)
	push	af

	ld	e,$bf-$0f		; number of pages to check
	ld	d,$0f			; first page
bnkpnxt:
	out	(c),d			; setup page

	ld	a,(hl)			; test if writable
	cpl
	ld	(hl),a
	cp	(hl)
	cpl
	ld	(hl),a
	jr	nz,bnktohpag

	inc	d			; next page
	dec	e
	jr	nz,bnkpnxt
bnktohpag:
	pop	af			; restore test page
	out	(c),a

	ld	a,d			; save size
; 	LD	A,$80
	ld	(hmempag),a
	ret



