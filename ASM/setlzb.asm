;----------------------------------------------------------------
;        This is a module in the ASMLIB library
;
; Enable leading zero blanking on the next numeric output.
;
;			Written     	R.C.H.     16/8/83
;			Last Update	R.C.H.	   31/12/83
;
; Eliminate all self modifying code		 R.C.H.   22/10/83
; Add ? to front of global subroutines		 R.C.H.   31/12/83
;----------------------------------------------------------------
;
	name	'setlzb'
;
	public	lzb,blzb,clzb,nolzb
	public	?lzpr1,?lzpr2,?lzpr3,?lzprint
	extrn	?lzbchr,?blank,dispatch
	maclib	z80
;
; Leadng zero printing is done in the different modes by recoginzing the
; following codes. These are defined as follows.
;
; 00	No lzb, standard default
; 01	Standard leading zero blanking
; 02	Blank filled leading zero blanking
; 03    Character filled leading zero blanking
;
lzb:
	push	psw
	mvi	a,1			; Select
lzb$common:
	sta	lzbtype			; Save in the data byte for it
	pop	psw
	ret
;
;----------------------------------------------------------------
;       Enable blank filled LZB on next numeric output.
;----------------------------------------------------------------
;
blzb:
	push	psw
	mvi	a,2
	jr	lzb$common
;
;----------------------------------------------------------------
; Enable character fill leading zero blanking. Character in A
;----------------------------------------------------------------
;
clzb:
	push	psw
	sta	?lzbchr			; save the character to lzb fill with
	mvi	a,3			; Character filled lzb code
	jr	lzb$common
;
;----------------------------------------------------------------
; Clear Leading Zero blanking
;----------------------------------------------------------------
;
nolzb:
	push	psw
	xra	a
	jr	lzb$common
;
;----------------------------------------------------------------
; This section is rather important since it is used by all numeric 
; printing routines to leading zero print digits. All the routines 
; for the different types of leading zero printing are contained 
; herein. Also note that the LZ$PRINT label is called by all or
; most numeric prionting routines and uses the lzbtype byte to
; jump to the required printing routine.
;----------------------------------------------------------------
;
?lzprint:
	push	h			; Deepest on the stack
	push	d
	push	psw
	lda	lzbtype			; Load the destination
	mvi	d,0
	mov	e,a			; Load the offset
	lxi	h,lz$table		; Point to start of table
	dad	d
	dad	d			; Index into the table
	mov	e,m
	inx	h
	mov	d,m			; Now de -> the routine
	xchg				; HL -> the address
	pop	psw
	pop	d
	xthl				; Restore hl, stack -> address
	ret				; Goto the table address
;
; The following table of routines is indexed into by the leading
; zero blanking type byte to get the address of the required routine
; to print the character in A.
;
lz$table:
	dw	dispatch
	dw	?lzpr1		; Standard lzb
	dw	?lzpr2		; Blank filled lzb
	dw	?lzpr3		; Character filled lzb
;
; The following three routines are pointed to by the above jump 
; when it is modified by a call to one of the entries.
;
?lzpr1:	; Standard leading zero suppression
	call	chk$blank		; See if we are past LZB due to a digit
	cpi	'0'			; is it a space ?
	rz
	jmp	dispatch		; else print if not = 0
?lzpr2:	; If it is = 0 then print a space
	call	chk$blank		; See if we are past LZB due to a digit
	cpi	'0'
	jnz	dispatch		; print it if > 0
	mvi	a,' '			; else load a space
	jmp	dispatch
?lzpr3:	; If the character = 0 then use the LZBCHR character to print
	call	chk$blank		; See if we are past LZB due to a digit
	cpi	'0'			; zero ?
	jnz	dispatch		; print is > 0
	lda	?lzbchr			; else load the fill character
	jmp	dispatch
;
chk$blank:	; Check the blank byte. If it is not 00 then we print the digit
	cpi	'0'			; is the digit a zero ?
	jrnz	set$blank		; Set the blank byte
; If the digit is a zero then detect if we MUST print it then
	lda	?blank
	ora	a			; if 00 the we do no need to
	jrnz	send$blank		
	mvi	a,'0'
	ret				; return and do what may
;
send$blank:	; Here is jumped to when blank <> 0 so we must print it
	pop	psw			; kill the return address
	mvi	a,'0'			; load a zero
	jmp	dispatch		; send the byte
;
set$blank:
	push	psw			; save the digit
	mvi	a,0ffh
	sta	?blank
	pop	psw
	ret				; return to the caller, blank set
;
	dseg
lzbtype:
	db	00			; Type of leading zero blanking
;
	end































