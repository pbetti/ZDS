	maclib	z80
	lxi	h,fin
	lxi	d,0c000h		; destination
	lxi	b,04000h		; size
	ldir
	jmp	0c000h
fin:
	end



