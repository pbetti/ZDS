	extrn	prolog,coe,dispatch,inline,quit
	extrn	clear,cie,randinit,rand16,rand8,cst
	extrn	cursor,setxy,delay,bell,caps,CUROFF,CURON
;
	maclib	z80
;
	call	prolog
	call	clear
	lxi	d,seed
	call	randinit
	lxi	h,items			; point to screen characters
;
	call	curoff			; disable cursor
start:
	push	h
	call	setup
	pop	h
	mov	a,m
	cpi	0ffh			; end ??
	jrnz	start1
	lxi	h,items			; point to start of items again then
	mov	a,m
start1:
	call	coe
	inx	h			; point to next item for next time
	jmp	start
;
setup:
	lxi	d,3
	call	delay
	call	cst
	jrz	loop1
	call	cie
	call	caps
	cpi	03
	jz	exit
	cpi	'C'
	cz	clear
	call	bell
loop1:
	lxi	d,seed
	call	rand8
	cpi	79			; greater than 79 ?
	jrnc	loop1
	sta	x
;
loop2:
	lxi	d,seed
	call	rand8
	cpi	23
	jrnc	loop2
	mov	e,a			; load y value
;
	lda	x
	mov	d,a			; load x value
	call	cursor
	ret
;
exit:
	lxi	d,023
	call	cursor
	call	curon
	jmp	quit
;
x:	db	00
;
items:	db	' O X V < > - + ^ * + : ',0ffh
;
seed:
	db	5,7,01,90,89,2
	end



