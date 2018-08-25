;
;=======================================================================
;
; Modular Z80 DarkStar (NE Z80) Monitor
;
;=======================================================================
;
; EEPROM management
; ---------------------------------------------------------------------


	;; write sequence steps
;-----------------------------------------------------------------------
; 		CALL	EIDCHECK	;do id check of user flash prom
; 		CALL	PROT_OFF	;disable sw protection
; 		CALL	FL_PROG		;program flash
; 		CALL	PROT_ON		;enable sw protection
;-----------------------------------------------------------------------

eetsav:		defb	0			; page # save
eidbuf:		defs	3			; id buffer
eprgen:		defb	0			; programming enabled
	; Programming parameters
esourceadr:	defw	0			; base address of the image to be burned
edestpag:	defb	0			; eeprom address on which to start burning
eimgsize:	defw	0			; size of the image


eemont		equ	trnpag << 12
eepage2		equ	$c2			; page 2 of eeprom
eepage5		equ	$c5			; page 5 of eeprom
eaddr0000	equ	eemont			; 0000
eaddr0001	equ	eemont+$1		; 0001
eaddr0002	equ	eemont+$2		; 0002
eaddr5555	equ	eemont+$555		; 5555
eaddr2aaa	equ	eemont+$aaa		; 2AAA

ee29ee020	equ	$bf10			; 29ee020 id (SST)
ee29xe020	equ	$bf12			; 29le020 or 29ve020 id (SST)
ee29c020	equ	$da45			; 29c020 id (Winbond)

;;
;; Retrieves chip ID code
;;

eidcheck:
	call	trnsave			; save page config
	di				; NO interrupt on eeprom manipulation
	call	eprgintro		; start prg mode
	ld	a,$90
	ld	(eaddr5555),a		; 5555H
	ld	de,1
	call	delay			; pause 1 msec
	;
	ld	d,eepage0		; get data
	call	trnmount
	ld	ix,eidbuf
	ld	a,(eaddr0000)		; 0000
	ld	(ix+0),a
	ld	a,(eaddr0001)		; 0001 prod id
	ld	(ix+1),a
	ld	a,(eaddr0002)		; 0002 boot block lockout
	ld	(ix+2),a
	;
	call	eprgintro		; exit
	ld	a,$f0
	ld	(eaddr5555),a		; 5555H
	ld	de,170
	call	delay			; pause 170 msec
	;
	ld	d,(ix+0)		; what we have?
	ld	e,(ix+1)
	ld	hl,ee29ee020
	call	cphlde
	jr	z,etyp29ee
	ld	hl,ee29xe020
	call	cphlde
	jr	z,etyp29xe
	ld	hl,ee29c020
	call	cphlde
	jr	z,etyp29c
	;
	ld	a,eepunsupp		; unsupported
	or	a,eeproglock		; ... and write locked
	ld	e,a			; return code on E
	ld	a,$ff
	ld	(eprgen),a		; lock programming
	jr	eidexi
etyp29ee:
	ld	a,eep29ee		; 29ee020
	ld	e,a			; return code on E
	xor	a
	ld	(eprgen),a		; unlock programming
	jr	eidexi
etyp29xe:
	ld	a,eep29xe		; 29Xe020
	ld	e,a			; return code on E
	xor	a
	ld	(eprgen),a		; unlock programming
	jr	eidexi
etyp29c:
	ld	a,eep29c		; 29c020
	ld	e,a			; return code on E
	ld	a,(ix+2)		; check for boot block lock
	cp	$ff
	jr	nz,etyp29c1		; free!
	ld	(eprgen),a		; Oops!! locked! ...lock programming
	ld	a,e
	or	a,eeproglock		; update return status
	ld	e,a
	jr	eidexi
etyp29c1:
	xor	a
	ld	(eprgen),a		; unlock programming
	jr	eidexi
eidexi:
	call	trnrestore		; umount transient
	ld	a,e
	ei
	ret

;;
;; Program the EEPROM
;;
;; Could not run if we are on the eeprom itself.
;; This routine MUST BE NOT INTERRUPTED until it ends
;; Also interrupts are disabled until complete.
;; ** Write on temporary page, so it must be used **
;; ** WITHIN 4k boundaries                        **

eeprogram:
	ld	a,(eprgen)		; Do not run if programming locked
	or	a
	ret	nz
	call	chekrun			; Do not run if inside eeprom
	call	trnsave
	di				; NO interrupt on eeprom manipulation
	call	eprotoff		; * disable protection *
	ld	a,(edestpag)		; mount eeprom page
	ld	d,a
	call	trnmount
	ld	hl,(esourceadr)		; programming parameters
	ld	de,eemont
	ld	bc,(eimgsize)
eprg0:	ld	a,80h			; per page are 128 bytes to load
pradr:	defb	$c3
	defw	eprg2			; progress update (must be patched)

eprg2:	dec	a
	ldi				; copy source to dest, dec bc
	jp	po,eprg3		; exit if no more bytes are left to load
	jp	nz,eprg2		; loop until page full
	push	de
	ld	de,30
	call	delay			; pause 30 ms when page full
	pop	de
	jp	eprg0
eprg3:	ld	de,170
	call	delay			; pause 170 ms
	call	eproton			; * enable protection *
	ei
	call	trnrestore
	ret



;;
;; Disable software data protection
;;
eprotoff:
	call	eprgintro		; start prg mode
	ld	a,$80
	ld	(eaddr5555),a		; 5555H
	call	eprgintro		; start prg mode
	ld	a,$20
	ld	(eaddr5555),a		; 5555H
	ld	de,70
	call	delay			; pause 70 msec
	ret
;
;;
;; Enable software data protection
;;
eproton:
	call	eprgintro		; start prg mode
	ld	a,$a0
	ld	(eaddr5555),a		; 5555H
	ld	de,170
	call	delay			; pause 170 msec
	ret

;;
;; Erase flash
;;
;; ** permanently disabled **

; EEPERASE:
; 	CALL	EPRGINTRO		; start prg mode
; 	LD	A,$80
; 	LD	(EADDR5555),A		; 5555H
; 	CALL	EPRGINTRO		; start prg mode
; 	LD	A,$10
; 	LD	(EADDR5555),A		; 5555H
; 	LD	DE,170
; 	CALL	DELAY			; pause 170 msec
; 	RET

;;
;; Send initial initial prg sequence
;; **** leave transient on page 5 to complete sequence ****
;;

eprgintro:
		ld	d,eepage5
		call	trnmount
		ld	a,$aa
		ld	(eaddr5555),a	;5555H
		ld	d,eepage2
		call	trnmount
		ld	a,$55
		ld	(eaddr2aaa),a	;2AAAH
		ld	d,eepage5
		call	trnmount
		ret

;;
;; Save transient
;;
trnsave:
	; Save transient page setup
	ld	b, trnpag
	call	mmgetp
	ld	(eetsav), a		; save current
	ret

;;
;; Mount transient
;;
;;  D = requested page
trnmount:
	; Mount transient page used for operations
	ld	a,d			; which page
	ld	b,trnpag		; transient page
	call	mmpmap			; mount it
	ret

;;
;; Umount transient, restoring old
;;
trnrestore:
	ld	a,(eetsav)		; old
	ld	b,trnpag		; transient page
	call	mmpmap			; mount it
	ret

;;
;; Check we are running from RAM space
;;
chekrun:
	pop	hl			; where we are ?
	push	hl			; load our address in HL
	ld	a,h
	and	$f0			; logical page
	ld	b,a			; on B
	rrc	b			; move on low nibble
	rrc	b
	rrc	b
	rrc	b
	call	mmgetp			; physical page in A
	ld	b,eepage0
	cp	b			; do check
	ret	m			; below eeprom: ok
	; in eeprom space, very bad...
	pop	hl			; clear last call
	ld	a,eerineprom		; load error code
	ret				; return to caller parent

;;
;; 16 bit compare
;;
cphlde:	or	a			; clear carry
	sbc	hl,de			; compare by subtraction
	add	hl,de			; restore
	ret

; ------------

