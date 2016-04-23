;
; ZDB23.B - Phone Dialing Module
;
; 01/29/92
; Joe Mortensen
;	adapted from a standalone program (DIALER.COM) by Bruce Morgen
;
; Dial phone number in phone field of ZDB record
;
dial:	call	clrmnu
	dc	1,'Turn on Modem, Pick Up Phone, Press RET (^C to Abort)',2
	call	cin
	cp	3		; ^C aborts
	jp	z,menu
;
; Check for valid phone number
;
	ld	hl,phon		; Point to phone field
	ld	a,(hl)
	cp	' '		; Is there a leading space?
	jr	z,done		; Yes, not valid
	or	a		; Null?
	jr	z,done		; Yes, empty field
;
; Initialize the modem
;
	push	hl		; Save phone field address
	call	mreset		; Send 'ATZ' to reset modem
	ld	hl,init		; Send 'ATX0S7=0' string to modem
	call	pstr
;
	ld	hl,tone		; Send tone dial string 'ATDT'
;
tonelp:	ld	a,(hl)
	or	a
	jr	z,tonelp0
;
	call	pout		; Send character to modem
	inc	hl		; Point to next character
	call	waitp1s		; Give modem time to handle it
	jr	tonelp
;
tonelp0:call	clrmnu
	dc	1,'Dialing....'	,2
;
; Send phone number to modem
;
	pop	hl		; Get back phone field address
;
diallp:	ld	a,(hl)		; Get character
	cp	' '		; Space?
	jr	z,tstr		; Yes, end of string
	or	a		; Null?
	jr	z,tstr		; Yes, end of string
;
	call	cout		; Display character on screen
	call	pout		; Send character to modem
	inc	hl		; Point to next digit
	call	waitp1s		; Give modem time to handle it
	jr	diallp		; Repeat loop
;
tstr:	ld	a,cr
	call	pout
	ld	b,0		; Allow enough delay for long credit
	call	halflp		;   card strings
	call	mreset
;
done:	jp	menu
;
; Send reset string to modem
;
mreset:	ld	hl,dflt		; Reset modem
;
; Send null-terminated string to modem
;
pstr:	ld	a,(hl)		; Get character
	or	a
	jr	z,pstr0		; Done
;
	call	pout
	inc	hl
	jr	pstr
;
pstr0:	ld	a,cr
	call	pout
;
; Delay loop to allow modem time to handle strings
;
halfsec:ld	b,5
;
halflp:	call	waitp1s
	djnz	halflp
	ret
;
; Modem 'AT' commands
;
dflt:	db	'ATZ',0		; Hayes reset to defaults command
init:	db	'ATX0S7=0',0	; X0=dialtone and busy signal not recognized
				; S7=0 = no wait for dialtone/busy signal
tone:	db	'ATDT',0	; Dial using tone
;
; End of ZDB.B
;
