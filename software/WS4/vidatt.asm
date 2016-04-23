
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
	and	00001110B
	jr	z,nohigh
	ld	hl,vhigh
	jp	string
nohigh:
	ld	hl,vnor
	jp	string


vnor:	defb	02,$11,$0d
vblink:	defb	03,$1b,$02,$0d
vrev:	defb	03,$1b,$1b,$0d
vund:	defb	03,$1b,$03,$0d
vhigh:	defb	03,$1b,$06,$0d

	end
