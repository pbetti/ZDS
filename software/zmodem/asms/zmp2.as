global	_fstat
global	ncsv, cret, indir
global	_setfcb
global	_Thefcb
global	_filelength
global	_getfirst
psect	text
_fstat:
global csv
call csv
ld	l,(ix+6)
ld	h,(ix+7)
push	hl
ld	hl,_Thefcb
push	hl
call	_setfcb
pop	bc
ld	hl,_Thefcb
ex	(sp),hl
call	_filelength
pop	bc
push	hl
ld	e,(ix+8)
ld	d,(ix+9)
ld	hl,15
add	hl,de
pop	de
ld	(hl),e
inc	hl
ld	(hl),d
ld	l,(ix+6)
ld	h,(ix+7)
push	hl
call	_getfirst
ld	hl,19f
ex	(sp),hl
ld	hl,_Thefcb
push	hl
call	_setfcb
jp	cret
global	_bdos
global	_getuid
global	_setuid
_filelength:
global csv
call csv
push hl
ld	hl,128
push	hl
ld	hl,26
push	hl
call	_bdos
pop	bc
pop	bc
call	_getuid
ld	h,0
ld	(ix+-2),l
ld	(ix+-1),h
ld	e,(ix+6)
ld	d,(ix+7)
ld	hl,13
add	hl,de
ld	c,(hl)
inc	hl
ld	b,(hl)
ld	a,c
and	15
ld	l,a
xor	a
ld	h,a
push	hl
call	_setuid
ld	l,(ix+6)
ld	h,(ix+7)
ex	(sp),hl
ld	hl,35
push	hl
call	_bdos
pop	bc
ld	l,(ix+-2)
ld	h,(ix+-1)
ex	(sp),hl
call	_setuid
pop	bc
ld	e,(ix+6)
ld	d,(ix+7)
ld	hl,33
add	hl,de
ld	a,(hl)
inc	hl
ld	h,(hl)
ld	l,a
jp	cret
global	_roundup
global	amod
global	adiv
_roundup:
global csv
call csv
ld	e,(ix+8)
ld	d,(ix+9)
ld	l,(ix+6)
ld	h,(ix+7)
call	amod
ld	a,l
or	h
jp	nz,L2
ld	hl,0
jp	L1
L2:
ld	hl,1
L1:
push	hl
ld	e,(ix+8)
ld	d,(ix+9)
ld	l,(ix+6)
ld	h,(ix+7)
call	adiv
pop	de
add	hl,de
jp	cret
_getfirst:
global csv
call csv
ld	hl,128
push	hl
ld	hl,26
push	hl
call	_bdos
pop	bc
ld	l,(ix+6)
ld	h,(ix+7)
ex	(sp),hl
ld	hl,_Thefcb
push	hl
call	_setfcb
pop	bc
ld	hl,_Thefcb
ex	(sp),hl
ld	hl,17
push	hl
call	_bdos
pop	bc
pop	bc
ld	a,l
rla
xor	a
ld	h,a
jp	cret
global	_getnext
_getnext:
ld	hl,128
push	hl
ld	hl,26
push	hl
call	_bdos
pop	bc
ld	hl,0
ex	(sp),hl
ld	hl,18
push	hl
call	_bdos
pop	bc
pop	bc
ld	a,l
rla
xor	a
ld	h,a
ret	
global	_ctr
global	_max
global	_strlen
_ctr:
global csv
call csv
ld	hl,0
push	hl
ld	l,(ix+6)
ld	h,(ix+7)
push	hl
call	_strlen
pop	bc
ex	de,hl
ld	hl,80
or	a
sbc	hl,de
srl	h
rr	l
push	hl
call	_max
pop	bc
pop	bc
jp	cret
global	_opabort
global	_Lastkey
global	_getchi
global	_flush
global	_Inhost
global	_Dialing
global	_report
global	_QuitFlag
_opabort:
call	_getchi
xor	a
ld	h,a
ld	(_Lastkey),hl
ld	de,27
or	a
sbc	hl,de
jp	nz,l19
call	_flush
ld	hl,(_Inhost)
ld	a,l
or	h
jp	nz,l20
ld	hl,(_Dialing)
ld	a,l
or	h
jp	nz,l20
ld	hl,29f
push	hl
ld	hl,12
push	hl
call	_report
pop	bc
pop	bc
l20:
ld	hl,1
ld	(_QuitFlag),hl
l19:
ld	hl,(_QuitFlag)
ret	
global	_readock
global	_mread
global	wrelop
psect	bss
F545:
defs	2
F546:
defs	5
psect	text
_readock:
global csv
call csv
ld	l,(ix+6)
ld	h,(ix+7)
push	hl
ld	l,(ix+8)
ld	h,(ix+9)
push	hl
ld	hl,F546
push	hl
call	_mread
pop	bc
pop	bc
pop	bc
ld	(F545),hl
ld	de,1
call	wrelop
jp	p,l22
ld	hl,-2
jp	cret
l22:
ld	de,1
ld	hl,(F545)
or	a
sbc	hl,de
jp	nz,l25
ld	a,(F546)
ld	l,a
rla
xor	a
ld	h,a
jp	cret
l26:
ld	de,F546
ld	hl,(F545)
dec	hl
ld	(F545),hl
add	hl,de
ld	a,(hl)
cp	24
jp	z,l25
ld	hl,-1
jp	cret
l25:
ld	hl,(F545)
ld	a,l
or	h
jp	nz,l26
ld	hl,24
jp	cret
global	_readline
_readline:
global csv
call csv
ld	hl,1
push	hl
ld	l,(ix+6)
ld	h,(ix+7)
push	hl
call	_readock
pop	bc
pop	bc
jp	cret
global	_putlabel
global	_cls
global	_locate
global	_stndout
global	_printf
global	_stndend
_putlabel:
global csv
call csv
call	_cls
ld	l,(ix+6)
ld	h,(ix+7)
push	hl
call	_ctr
pop	bc
dec	hl
push	hl
ld	hl,0
push	hl
call	_locate
pop	bc
pop	bc
call	_stndout
ld	l,(ix+6)
ld	h,(ix+7)
push	hl
ld	hl,39f
push	hl
call	_printf
pop	bc
pop	bc
call	_stndend
jp	cret
global	_killlabel
_killlabel:
jp	_cls
global	_mgetchar
global	amul
psect	bss
F554:
defs	2
F555:
defs	2
psect	text
_mgetchar:
global csv
call csv
ld	hl,0
ld	(_Lastkey),hl
ld	de,10
ld	l,(ix+6)
ld	h,(ix+7)
call	amul
ld	(F555),hl
push	hl
call	_readline
pop	bc
ld	(F554),hl
ld	de,-2
or	a
sbc	hl,de
jp	z,l33
ld	hl,(F554)
xor	a
ld	h,a
jp	cret
l35:
ld	hl,-2
jp	cret
l33:
ld	hl,(_Lastkey)
ld	a,l
or	h
jp	z,l35
jp	cret
global	_box
psect	data
F557:
defw	49f
defw	59f
defw	69f
defw	79f
defw	89f
defw	99f
defw	109f
defw	119f
defw	129f
defw	139f
defw	149f
F558:
defw	0
defw	32
defw	31
defw	31
defw	29
defw	27
defw	23
defw	22
defw	25
defw	29
defw	28
global	_putc8
global	wrelop
global	wrelop
global	wrelop
global	_clrbox
global	wrelop
psect	text
_box:
global csv
call csv
push hl
ld	hl,19
push	hl
ld	hl,2
push	hl
call	_locate
pop	bc
ld	l,201
ex	(sp),hl
call	_putc8
pop	bc
ld	(ix+-2),1
ld	(ix+-1),0
jp	l40
l37:
ld	l,193
push	hl
call	_putc8
pop	bc
ld	l,(ix+-2)
ld	h,(ix+-1)
inc	hl
ld	(ix+-2),l
ld	(ix+-1),h
l40:
ld	de,40
ld	l,(ix+-2)
ld	h,(ix+-1)
call	wrelop
jp	m,l37
ld	l,202
push	hl
call	_putc8
ld	hl,19
ex	(sp),hl
ld	hl,13
push	hl
call	_locate
pop	bc
ld	l,199
ex	(sp),hl
call	_putc8
pop	bc
ld	(ix+-2),1
ld	(ix+-1),0
jp	l44
l41:
ld	l,193
push	hl
call	_putc8
pop	bc
ld	l,(ix+-2)
ld	h,(ix+-1)
inc	hl
ld	(ix+-2),l
ld	(ix+-1),h
l44:
ld	de,40
ld	l,(ix+-2)
ld	h,(ix+-1)
call	wrelop
jp	m,l41
ld	l,200
push	hl
call	_putc8
pop	bc
ld	(ix+-2),1
ld	(ix+-1),0
jp	l48
l45:
ld	hl,19
push	hl
ld	l,(ix+-2)
ld	h,(ix+-1)
inc	hl
inc	hl
push	hl
call	_locate
pop	bc
ld	l,192
ex	(sp),hl
call	_putc8
pop	bc
ld	hl,59
push	hl
ld	l,(ix+-2)
ld	h,(ix+-1)
inc	hl
inc	hl
push	hl
call	_locate
pop	bc
ld	l,192
ex	(sp),hl
call	_putc8
pop	bc
ld	l,(ix+-2)
ld	h,(ix+-1)
inc	hl
ld	(ix+-2),l
ld	(ix+-1),h
l48:
ld	de,11
ld	l,(ix+-2)
ld	h,(ix+-1)
call	wrelop
jp	m,l45
call	_clrbox
ld	(ix+-2),1
ld	(ix+-1),0
jp	l52
l49:
ld	de,F558
ld	l,(ix+-2)
ld	h,(ix+-1)
add	hl,hl
add	hl,de
ld	c,(hl)
inc	hl
ld	b,(hl)
push	bc
ld	l,(ix+-2)
ld	h,(ix+-1)
inc	hl
inc	hl
push	hl
call	_locate
pop	bc
pop	bc
ld	de,F557
ld	l,(ix+-2)
ld	h,(ix+-1)
add	hl,hl
add	hl,de
ld	c,(hl)
inc	hl
ld	b,(hl)
push	bc
call	_printf
pop	bc
ld	l,(ix+-2)
ld	h,(ix+-1)
inc	hl
ld	(ix+-2),l
ld	(ix+-1),h
l52:
ld	de,11
ld	l,(ix+-2)
ld	h,(ix+-1)
call	wrelop
jp	m,l49
jp	cret
global	wrelop
_clrbox:
global csv
call csv
push hl
ld	(ix+-2),3
ld	(ix+-1),0
jp	l57
l54:
ld	hl,20
push	hl
ld	l,(ix+-2)
ld	h,(ix+-1)
push	hl
call	_locate
pop	bc
ld	hl,159f
ex	(sp),hl
call	_printf
pop	bc
ld	l,(ix+-2)
ld	h,(ix+-1)
inc	hl
ld	(ix+-2),l
ld	(ix+-1),h
l57:
ld	de,13
ld	l,(ix+-2)
ld	h,(ix+-1)
call	wrelop
jp	m,l54
jp	cret
global	_mrd
global	_mcharinp
_mread:
global csv
call csv
push hl
push hl
ld	(ix+-2),0
ld	(ix+-1),0
l60:
call	_mrd
ld	(ix+-4),l
ld	(ix+-3),h
ld	a,l
or	h
jp	nz,l61
ld	l,(ix+10)
ld	h,(ix+11)
dec	hl
ld	(ix+10),l
ld	(ix+11),h
inc	hl
ld	a,l
or	h
jp	z,l61
call	_opabort
ld	a,l
or	h
jp	z,l60
l61:
ld	a,(ix+-4)
or	(ix+-3)
jp	z,l62
call	_mcharinp
ld	a,l
ld	e,(ix+6)
ld	d,(ix+7)
ld	l,(ix+-2)
ld	h,(ix+-1)
inc	hl
ld	(ix+-2),l
ld	(ix+-1),h
dec	hl
add	hl,de
ld	(hl),a
l62:
ld	l,(ix+-2)
ld	h,(ix+-1)
jp	cret
global	_mchin
global	_Stopped
global	_mchout
psect	bss
F565:
defs	2
psect	text
_mcharinp:
call	_mchin
ld	(F565),hl
ld	hl,(_Stopped)
ld	a,l
or	h
jp	z,l64
ld	hl,17
push	hl
call	_mchout
pop	bc
ld	hl,0
ld	(_Stopped),hl
l64:
ld	hl,(F565)
ret	
global	_mcharout
_mcharout:
global csv
call csv
ld	a,(ix+6)
ld	l,a
rla
sbc	a,a
ld	h,a
push	hl
call	_mchout
jp	cret
global	_minprdy
global	_mirdy
_minprdy:
call	_mirdy
ld	a,l
or	h
jp	nz,L9
ld	hl,(_Stopped)
ld	a,l
or	h
jp	z,L8
L9:
ld	hl,1
ret	
L8:
ld	hl,0
ret	
psect	data
19:
defb	63,63,63,63,63,63,63,63,46,63,63,63,0
29:
defb	79,112,101,114,97,116,111,114,32,97,98,111,114,116,0
39:
defb	32,37,115,32,10,10,0
49:
defb	0
59:
defb	80,114,111,116,111,99,111,108,58,0
69:
defb	70,105,108,101,32,78,97,109,101,58,0
79:
defb	70,105,108,101,32,83,105,122,101,58,0
89:
defb	66,108,111,99,107,32,67,104,101,99,107,58,0
99:
defb	84,114,97,110,115,102,101,114,32,84,105,109,101,58,0
109:
defb	66,121,116,101,115,32,84,114,97,110,115,102,101,114,114,101
defb	100,58,0
119:
defb	66,108,111,99,107,115,32,84,114,97,110,115,102,101,114,114
defb	101,100,58,0
129:
defb	83,101,99,116,111,114,115,32,105,110,32,70,105,108,101,58
defb	0
139:
defb	69,114,114,111,114,32,67,111,117,110,116,58,0
149:
defb	76,97,115,116,32,77,101,115,115,97,103,101,58,32,32,78
defb	79,78,69,0
159:
defb	32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
defb	32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
defb	32,32,32,32,32,32,32,0
psect	text
7,110,115,102,101,114,114,101
defb	100,58,0
119:
defb	66,108,111,