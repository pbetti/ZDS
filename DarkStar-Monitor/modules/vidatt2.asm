
string	equ	$8302

	org $03c1

	bit	1,c
	jr	z,nowarn
	ld	hl,vblink
	jp	string
nowarn:
	bit	2,c
	jr	z,nomark
	ld	hl,vrev
	jp	string
nomark:
	bit	3,c
	jr	z,nound
	ld	hl,vund
	jp	string
nound:
	ld	a,c
; 	and	00001110B
	or	a
	jr	z,nohigh
	ld	hl,vhigh
	jp	string
nohigh:
	ld	hl,vnor
	jp	string

vmap:	defb	00000000b	; strike out
	defb	00000110b	; warnings & errors
	defb	00000100b	; block
	defb	00001000b	; underline
	defb	00011000b	; subscript
	defb	00011000b	; superscript
	defb	00000100b	; menu, headline, bold, double
	defb	00000000b	; italics, RET, backspace
	
vnor:	defb	01,$11

sblink:	defb	03,$1b,$02,$0
srev:	defb	03,$1b,$1b,$0
sund:	defb	03,$1b,$03,$0
shigh:	defb	03,$1b,$06,$0

rblink:	defb	03,$1b,$01,$0
rrev:	defb	03,$1b,$1c,$0
rund:	defb	03,$1b,$03,$0
rhigh:	defb	03,$1b,$1c,$0

	end
