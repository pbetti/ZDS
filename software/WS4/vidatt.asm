
string	equ	$8302

	org $03c1

	bit	1,c
	jr	z,nowarn
	ld	hl,vwarn
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
	call	string
nound:
	ld	a,c
	or	a
	jr	z,nohigh
	ld	hl,vhigh
	jp	string
nohigh:
	ld	hl,vnor
	jp	string


vnor:	defb	02,$11,$0d
vblink:	defb	03,$1b,$02,$0
vrev:	defb	03,$1b,$1b,$0
vund:	defb	03,$1b,$04,$0
vhigh:	defb	03,$1b,$1b,$0
vwarn:	defb	03,$1b,$02,$04,$0

	end
