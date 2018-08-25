;
;=======================================================================
;
; CP/M 3 Z80 DarkStar (NE Z80) Porting
;
;=======================================================================
;;---------------------------------------------------------------------
;; Version      : 1.0 - 20140904
;; Assemble     : SLR z80asm
;; Revisions:
;; 20140905	- Code start
;; 20180818	- Removed private stack
;;---------------------------------------------------------------------

	TITLE	'BANK & MOVE MODULE FOR THE MODULAR CP/M 3 BIOS'

	; define logical values:
	include	common.inc
	include syshw.inc

	public	?move,?xmove,?bank
	if banked
	public	bankbf
	endif

	extrn	@cbnk

	.z80

pages32k	equ	32768/4096	; physical pages for a 32k bank
pages48k	equ	49152/4096	; physical pages for a 48k bank

	cseg	; must be in common memory

	; setup an inter-bank move of 128 bytes on the next call
	; to ?move
?xmove:
	if banked
	ld	(srcbnk),bc		; c -> srcbnk, b -> dstbnk
	endif
	ret

; select bank in a

?bank:
	if banked
	push	bc
	push	de
	push	hl
	di				; for safety
	; **************************************************************
	; we MUST have first 50 bytes in cpu page 0 copied in every bank
	; so save them in buffer
	; **************************************************************
	ld	hl,0
	ld	de,pag0bf
	ld	bc,$50
	ldir
	; normalize bank page.
	; for now we leave a 32k hole every bank for 32k banks
	; just in case we switch to 48k banks (and 16k holes)
	sla	a
	sla	a
	sla	a
	sla	a
	; a is now physical base page address of bank
	; meaning bank 1 has pages 10h to 17h (for 32k banks)
	ld	e,pages48k		; # pages
	ld	c,mmuport		; mmu i/o address
	ld	d,a			; physical page pointer
	xor	a
bnkpag:
	ld	b,a			; logical page pointer
	out	(c),d
	inc	d			; phis. page address 00xxxh, 01xxxh....
	add	a,$10			; log. page address 0h,1h,2h.... (00h,10h....)
	dec	e
	jr	nz,bnkpag
	; **************************************************************
	; update first 50 bytes in cpu page 0
	; **************************************************************
	ld	hl,pag0bf
	ld	de,0
	ld	bc,$50
	ldir
	;
	pop	hl
	pop	de
	pop	bc
	ei				; let's run
	endif
	ret

	;  block move
?move:
	if banked
	ld	a,(srcbnk)		; contains 0ffh if normal block move
	inc	a
	jr	nz,interbankmove
	endif
	ex	de,hl			; we are passed source in de and dest in hl
	ldir				; use z80 block move instruction
	ex	de,hl			; need next address in same regs
	ret

	if banked

interbankmove:		; source in hl, dest in de, count in bc

	ld	a,(srcbnk)
	call	?bank			; source in place
	;
	push	hl
	push	bc
	ex	de,hl
	ld	de,bankbf		; to buffer
	ldir
	;
	pop	bc
	pop	de
	push	hl
	ld	a,(dstbnk)
	call	?bank			; dest. in place
	;
	ld	hl,bankbf
	ldir				; to destination
	pop	hl
	ex	de,hl
	;
	ld	a,(@cbnk)		; restore current
	call	?bank
	ld	a,$ff
	ld	(srcbnk),a
	ret


srcbnk:	defb	0ffh
dstbnk:	defb	0ffh
bankbf:	defs	128		; local temporary buffer for extended moves
pag0bf:	defs	50


	end

