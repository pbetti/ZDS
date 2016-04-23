;----------------------------------------------------------------
;         This is a module in the ASMLIB Library.
;
; This module takes the accumulator and uses it to index into an 
; internal table of screen attributes that are sent to the screen. 
; If an attribute is already set then it is cleared first before a 
; new attribute is set. This function is also used by the formin 
; routine for its video attribute setting.
; This module also is patchable by external routines so that screen
; attributes for different terminals are customizable.
;
; The tname routine returns the current terminal driver name
; which is exactly 6 ascii characters long
;
; Current attributes supported are
; 00	Default state, no attributes. Clear current attribute.
; 01	1/2 intensity characters.
; 02	Blinking characters.
; 03	Reverse characters.
; 04 	Underline.
;
;		    Written		R.C.H.	6/9/83
;		    Last Update		R.C.H.	22/11/83
;----------------------------------------------------------------
;
	name	'setatt'
;
	public	setatt,tname
	extrn	coe
	maclib	z80
;
numatt	equ	7		; Number of attributes supported
;
tname	lxi	h,termnam
	ret
;
setatt:
	cpi	numatt		; In range ??
	rnc			; Return wit tail B/N legs if too big
	push	d
	push	b
	push	h
	push	psw		; Save the users attribute
	lda	curatt		; Get the current attribute
	ora	a
	jrz	doatt		; If 00, no need to clear old one
; Here we must clear the old attribute before proceeding.
	dcr	a		; Make the attribute in range
	lxi	h,attclr	; Point to the tbale of clear atts.
	call	index
	call	att$send	; Send the attributes -> by HL
doatt:
	pop	psw		; Get users attribute
	sta	curatt		; Save in ram.
	ora	a		; Is it attribute 00 ?
	jrz	set$end		; Ignore if so
	dcr	a		; Make in the correct range then
; Now index into the table of attribute setting bytes to get the req'd code.
	lxi	h,attset	; Point to start
	call	index		; Get hl -> start
	call	att$send	; Send attributes -> by HL
; Re-load registers and return.
set$end:
	pop	h
	pop	b
	pop	d
	ret
;
; This routine must use HL -> a counter byte to send the proceeeding bytes
; to the console.
;
att$send:	
	mov	a,m
	ora	a		; See if a null length ?
	rz			; Return if a null string
	mov	b,a		; Else load the length
sloop:
	inx	h		; Point to next character
	mov	a,m
	call	coe		; Send
	djnz	sloop
	ret
;
; This routine that follows simply indexes into the table 
; of bytes. Each table entry is assumed to be 5 bytes long.
;
; On entry hl -> start of table, on exit hl -> first element in line (a)
;
index:	
	ora	a
	rz			; Return if no loops needed
	mvi	d,0		; Clear upper register
	mov	e,a		; Load counter
; Multiply A by 5 then add to HL
	add	a		; * 2 (double original)
	add	a		; * 4
	add	e		; * 5 (add original)
	mov	e,a		; load into indexing register
	dad	d		; now HL -> start of this entry
	ret			; hl -> start of a line

; ~~~~ The following table of bytes is used to SET a video attribute. ~~~~
;
setid:
	db	0ffh,01ah,0ffh,01ah,00		; this flags the set att. table
termnam:
	db	'ABM 85'		; 6 bytes allowed for terminal name
attset:
	db	2,01bh,029h,00,00	; Start half intensity
	db	2,01bh,05eh,00,00	; Start blinking
	db	2,01bh,06ah,00,00	; Start reverse video
	db	2,01bh,06ch,00,00	; Start underline
	db	00,00,00,00,00		; extra for later
	db	00,00,00,00,00		; extra for later
	db	0ffh			; end table flag
;
; ~~~~ The following table of bytes is used to CLEAR video attributes ~~~~
;
clrid:
	db	0ffh,01ah,0ffh,1ah,01	; This flags the clear att. table
attclr:
	db	02,01bh,028h,00,00	; End half intensity
	db	02,01bh,071h,00,00	; End blinking
	db	02,01bh,06bh,00,00	; End reverse video
	db	02,01bh,06dh,00,00	; End underline
	db	00,00,00,00,00		; extra for later
	db	00,00,00,00,00		; extra for later
	db	0ffh			; end table flag
;
; Data variables / flag storage next
;
	dseg				
;
curatt	db	00			; Current attribute in use
;
;
	end



