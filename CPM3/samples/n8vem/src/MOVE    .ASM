	title 'bank & move module for CP/M3 linked BIOS'

	cseg

	public ?move,?xmove,?bank
	extrn @cbnk,?pdec,?pmsg

	maclib z80
	;maclib ports

	mpcl$ram	equ	78h	; N8VEM memory bank select latch
	

?xmove:		; N8VEM can't perform interbank moves
	ret

?move:
	xchg		; we are passed source in DE and dest in HL
	ldir		; use Z80 block move instruction
	xchg		; need next addresses in same regs
	ret

					; by exiting through bank select
?bank:
;	push	b
;	push	d
;	push	h
;	push	psw
;	lxi	h,0
;	mov	l,a
;	call	?pdec
;	lxi		h,log$msg
;	call	?pmsg
;	pop	psw
;	pop	h
;	pop	d
;	pop	b
	out	mpcl$ram
	ret
log$msg:
		db	0dh,0ah,0


	end
