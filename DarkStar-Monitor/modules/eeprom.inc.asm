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

EETSAV:		DEFB	0			; page # save
EIDBUF:		DEFS	3			; id buffer
EPRGEN:		DEFB	0			; programming enabled
	; Programming parameters
ESOURCEADR:	DEFW	0			; base address of the image to be burned
EDESTPAG:	DEFB	0			; eeprom address on which to start burning
EIMGSIZE:	DEFW	0			; size of the image


EEMONT		EQU	TRNPAG << 12
EEPAGE2		EQU	$C2			; page 2 of eeprom
EEPAGE5		EQU	$C5			; page 5 of eeprom
EADDR0000	EQU	EEMONT			; 0000
EADDR0001	EQU	EEMONT+$1		; 0001
EADDR0002	EQU	EEMONT+$2		; 0002
EADDR5555	EQU	EEMONT+$555		; 5555
EADDR2AAA	EQU	EEMONT+$AAA		; 2AAA

EE29EE020	EQU	$BF10			; 29ee020 id (SST)
EE29XE020	EQU	$BF12			; 29le020 or 29ve020 id (SST)
EE29C020	EQU	$DA45			; 29c020 id (Winbond)

;;
;; Retrieves chip ID code
;;

EIDCHECK:
	CALL	TRNSAVE			; save page config
	DI				; NO interrupt on eeprom maniplation
	CALL	EPRGINTRO		; start prg mode
	LD	A,$90
	LD	(EADDR5555),A		; 5555H
	LD	DE,1
	CALL	DELAY			; pause 1 msec
	;
	LD	D,EEPAGE0		; get data
	CALL	TRNMOUNT
	LD	IX,EIDBUF
	LD	A,(EADDR0000)		; 0000
	LD	(IX+0),A
	LD	A,(EADDR0001)		; 0001 prod id
	LD	(IX+1),A
	LD	A,(EADDR0002)		; 0002 boot block lockout
	LD	(IX+2),A
	;
	CALL	EPRGINTRO		; exit
	LD	A,$F0
	LD	(EADDR5555),A		; 5555H
	LD	DE,170
	CALL	DELAY			; pause 170 msec
	;
	LD	D,(IX+0)		; what we have?
	LD	E,(IX+1)
	LD	HL,EE29EE020
	CALL	CPHLDE
	JR	Z,ETYP29EE
	LD	HL,EE29XE020
	CALL	CPHLDE
	JR	Z,ETYP29XE
	LD	HL,EE29C020
	CALL	CPHLDE
	JR	Z,ETYP29C
	;
	LD	A,EEPUNSUPP		; unsupported
	OR	A,EEPROGLOCK		; ... and write locked
	LD	E,A			; return code on E
	LD	A,$FF
	LD	(EPRGEN),A		; lock programming
	JR	EIDEXI
ETYP29EE:
	LD	A,EEP29EE		; 29ee020
	LD	E,A			; return code on E
	XOR	A
	LD	(EPRGEN),A		; unlock programming
	JR	EIDEXI
ETYP29XE:
	LD	A,EEP29XE		; 29Xe020
	LD	E,A			; return code on E
	XOR	A
	LD	(EPRGEN),A		; unlock programming
	JR	EIDEXI
ETYP29C:
	LD	A,EEP29C		; 29c020
	LD	E,A			; return code on E
	LD	A,(IX+2)		; check for boot block lock
	CP	$FF
	JR	NZ,ETYP29C1		; free!
	LD	(EPRGEN),A		; Oops!! locked! ...lock programming
	LD	A,E
	OR	A,EEPROGLOCK		; update return status
	LD	E,A
	JR	EIDEXI
ETYP29C1:
	XOR	A
	LD	(EPRGEN),A		; unlock programming
	JR	EIDEXI
EIDEXI:
	CALL	TRNRESTORE		; umount transient
	LD	A,E
	EI
	RET

;;
;; Program the EEPROM
;;
;; Could not run if we are on the eeprom itself.
;; This routine MUST BE NOT INTERRUPTED until it ends
;; Also interrupts are disabled until complete.
;; ** Write on temporary page, so it must be used **
;; ** WITHIN 4k boundaries                        **

EEPROGRAM:
	LD	A,(EPRGEN)		; Do not run if programming locked
	OR	A
	RET	NZ
	CALL	CHEKRUN			; Do not run if inside eeprom
	CALL	TRNSAVE
	DI				; NO interrupt on eeprom manipulation
	CALL	EPROTOFF		; * disable protection *
	LD	A,(EDESTPAG)		; mount eeprom page
	LD	D,A
	CALL	TRNMOUNT
	LD	HL,(ESOURCEADR)		; programming parameters
	LD	DE,EEMONT
	LD	BC,(EIMGSIZE)
EPRG0:	LD	A,80H			; per page are 128 bytes to load
PRADR:	DEFB	$C3
	DEFW	EPRG2			; progress update (must be patched)

EPRG2:	DEC	A
	LDI				; copy source to dest, dec bc
	JP	PO,EPRG3		; exit if no more bytes are left to load
	JP	NZ,EPRG2		; loop until page full
	PUSH	DE
	LD	DE,30
	CALL	DELAY			; pause 30 ms when page full
	POP	DE
	JP	EPRG0
EPRG3:	LD	DE,170
	CALL	DELAY			; pause 170 ms
	CALL	EPROTON			; * enable protection *
	EI
	CALL	TRNRESTORE
	RET



;;
;; Disable software data protection
;;
EPROTOFF:
	CALL	EPRGINTRO		; start prg mode
	LD	A,$80
	LD	(EADDR5555),A		; 5555H
	CALL	EPRGINTRO		; start prg mode
	LD	A,$20
	LD	(EADDR5555),A		; 5555H
	LD	DE,70
	CALL	DELAY			; pause 70 msec
	RET
;
;;
;; Enable software data protection
;;
EPROTON:
	CALL	EPRGINTRO		; start prg mode
	LD	A,$A0
	LD	(EADDR5555),A		; 5555H
	LD	DE,170
	CALL	DELAY			; pause 170 msec
	RET

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

EPRGINTRO:
		LD	D,EEPAGE5
		CALL	TRNMOUNT
		LD	A,$AA
		LD	(EADDR5555),A	;5555H
		LD	D,EEPAGE2
		CALL	TRNMOUNT
		LD	A,$55
		LD	(EADDR2AAA),A	;2AAAH
		LD	D,EEPAGE5
		CALL	TRNMOUNT
		RET

;;
;; Save transient
;;
TRNSAVE:
	; Save transient page setup
	LD	B, TRNPAG
	CALL	MMGETP
	LD	(EETSAV), A		; save current
	RET

;;
;; Mount transient
;;
;;  D = requested page
TRNMOUNT:
	; Mount transient page used for operations
	LD	A,D			; which page
	LD	B,TRNPAG		; transient page
	CALL	MMPMAP			; mount it
	RET

;;
;; Umount transient, restoring old
;;
TRNRESTORE:
	LD	A,(EETSAV)		; old
	LD	B,TRNPAG		; transient page
	CALL	MMPMAP			; mount it
	RET

;;
;; Check we are running from RAM space
;;
CHEKRUN:
	POP	HL			; where we are ?
	PUSH	HL			; load our address in HL
	LD	A,H
	AND	$F0			; logical page
	LD	B,A			; on B
	RRC	B			; move on low nibble
	RRC	B
	RRC	B
	RRC	B
	CALL	MMGETP			; physical page in A
	LD	B,EEPAGE0
	CP	B			; do check
	RET	M			; below eeprom: ok
	; in eeprom space, very bad...
	POP	HL			; clear last call
	LD	A,EERINEPROM		; load error code
	RET				; return to caller parent

;;
;; 16 bit compare
;;
CPHLDE:	OR	A			; clear carry
	SBC	HL,DE			; compare by subtraction
	ADD	HL,DE			; restore
	RET

; ------------

