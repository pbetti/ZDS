;----------------------------------------------------------------
;          This is a module in the ASMLIB library.
;
; This module uses a barber pole type approach to testing memory.
; The barber pole is an uneven number of bytes long so that address
; and page faults are detected. This is supposedly better than
; walking bit tests at detecting faults in memory. This program
; may be modified to suit the type of ram chips that are being used.
; If the ram chips are 1 bit wide (4116 or 4864 etc) then use the
; size1 equate.
; Ir ram is 8 bits wide (6116 etc) then use size 8.
; The effect of these is to modify the size of the barber pole pattern
; that is written into memory and to optimize the test so that will
; find faults in addressing better.
;
; If an error is found then HL-> memeory in error and A = the value
; that was being tested.
;
;          This is the barber pole memory test program from
;          Byte December 1982
;
;                         Written	R.C.H.       22/10/83
;                         Last Update   R.C.H.       24/10/83
;----------------------------------------------------------------
;
	name	'rambpt'
	public	rambpt
	maclib	z80
;
true	equ	0ffffh
false	equ	not true
size1	equ	true		; 1 bit wide memories
size8	equ	not size1	; 8 or 4 bit wide memories
;
	if	size1
lnpat	equ	017
	endif
;
	if	size8
lnpat	equ	9
	endif

;
; here DE -> start of memory to be tested, Hl --> end of test area
;
rambpt:
	sded	memst		; Save memory start address
	shld	memnd
;
; Test if end > start
;
	xchg			; now DE = end address, HL = start
	mov	a,h
	cma	
	mov	h,a		; Take complement
	mov	a,l
	cma
	mov	l,a
	inx	h		; Bump to take the complement
	dad	d		; Add the 2's complement
	jc	main3		; Carry and all is ok else error
;
; Here and end is > start address
;
	stc			; set the carry flag
	ret
;
main3:
	inx	h		; Calculate number of bytes to test
	shld	nbyte
	mvi	a,lnpat		; Load pattern length
	sta	patln		; Save in length
	sta	ncycl		; Load cycle counter
	lxi	b,patrn		; Point to the pattern to put in ram
	push	b
main4:
	lhld	nbyte
	xchg			; Put number of bytes in DE
	lhld	memst		; Load HL with start address
;
; This routine drops the barber pole into memory
;
main5:
	ldax	b		; get a pattern byte
	mov	m,a		; put into memory
	inx	b		; point to next batrber pole pattern
	inx	h		; bump memory pointer
	dcx	d		; decrement counter of bytes
	mov	a,d		
	ora	e		; is DE = 0 ??
	jz	main6		; if so then test the pattern
	lda	patln		; decerment the pattern length
	dcr	a
	sta	patln
	jnz	main5		; If not zero, load another byte
	pop	b
	push	b		; Restore the pattern start pointer
	mvi	a,lnpat		; Re-load pattern length
	sta	patln
	jmp	main5
;
; Test the barber pole in memory
;
main6:
	pop	b
	push	b		; Get start of pattern
	mvi	a,lnpat		; get length of pattern
	sta	patln		; save in length store
	lhld	nbyte		; get the size
	xchg
	lhld	memst		; get the start address
;
;
main7:
	ldax	b		; get the pattern byte
	cmp	m		; is memory the same as the pattern ?
	jnz	error		; error if it is not
	inx	b		; next pattern character
	inx	h		; next memory
	dcx	d		; one less byte to test
	mov	a,e
	ora	d		; end of bytes ?
	jz	main8		; end if d = e = 0
	lda	patln
	dcr	a
	sta	patln
	jnz	main7		; keep on till patln = 0
	pop	b
	push	b		; restore pattern start address
	mvi	a,lnpat
	sta	patln
	jmp	main7
;
; Shift the barber pole left by 1 bit and test for last shift
;
main8:
	lda	ncycl
	pop	b
	inx	b		; shift left by moving table pointer
	push	b
	mvi	a,lnpat		; get the length
	sta	patln
	lda	ncycl		; get number of cycles done
	dcr	a
	sta	ncycl
	jnz	main4		; keep on till ncycl = 0
;
; end of test when here
;
	pop	b		; restore pattern pointer & stack
	ora	a		; disable carry flag if it was set
	ret			; all done, no errors
;
; Error handler
; If an error then return carry flag set, HL-> error
; and A = value written to ram.
;
error:
	pop	b		; restore stack. BC -> barber pole pattern.
	stc			; set carry to indiacte a testing error
	ret
;
; For 1 bit wide memories, use the following
	if	size1
patrn	db	00h,01h,02,04h,08h,10h,20h,40h,80h
	db	0feh,0fdh,0fbh,0f7h,0efh,0dfh,0bfh,07fh
     	db	00h,01h,02,04h,08h,10h,20h,40h,80h
	db	0feh,0fdh,0fbh,0f7h,0efh,0dfh,0bfh,07fh
	endif
;
; For 4 and 8 bit wide rams use the following.
;
	if	size8
patrn	db	00h,11h,22h,44h,88h,0eeh,0ddh,0bbh,077h
      	db	00h,11h,22h,44h,88h,0eeh,0ddh,0bbh,077h
	endif

;
	dseg
memnd	db	00,00
memst	db	00,00
nbyte	db	00,00
ncycl	db	00,00
patln	db	00,00
	end


