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
MMUPMAP:
	LD	C,MMUPORT
	OUT	(C),D
	RET


;; FMEMSIZ - Size memory in physical space
;;           DO NOT TRY to check eeprom region
;;
FMEMSIZ:
	LD	B,MMTPAPAG		; last ram page before eeprom
	LD	HL,$FFFF
FMEMNP:
	INC	H
	LD	A,(HL)
	CPL
	LD	(HL),A
	CP	(HL)
	CPL
	LD	(HL),A
	JR	NZ,FMESTP
	LD	A,H
	CP	B
	JR	NZ,FMEMNP
	RET
FMESTP:
	DEC	H			; error or unavailable page
	RET

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
BNKMSIZ:
	LD	B,MMUTSTPAGE << 4	; save actual test page
	LD	C,MMUPORT
	LD	HL,MMUTSTADDR
	IN	A,(C)
	PUSH	AF

	LD	E,$BF-$0F		; number of pages to check
	LD	D,$0F			; first page
BNKPNXT:
	OUT	(C),D			; setup page

	LD	A,(HL)			; test if writable
	CPL
	LD	(HL),A
	CP	(HL)
	CPL
	LD	(HL),A
	JR	NZ,BNKTOHPAG

	INC	D			; next page
	DEC	E
	JR	NZ,BNKPNXT
BNKTOHPAG:
	POP	AF			; restore test page
	OUT	(C),A

	LD	A,D			; save size
; 	LD	A,$80
	LD	(HMEMPAG),A
	RET


