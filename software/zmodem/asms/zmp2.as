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
global	_process_flist
global	_loc_vector
global	_in_count
global	_ext_vector
global	_Pathlist
global	_vcount
global	_curfname
global	_fnptr
global	_alloc
global	_strcpy
_process_flist:
call ncsv
defw -513
push	ix
pop	de
ld	hl,-513
add	hl,de
ld	(_loc_vector),hl
ld	l,(ix+6)
ld	h,(ix+7)
ld	(_in_count),hl
ld	hl,(_Pathlist)
ld	(_ext_vector),hl
ld	hl,0
ld	(_vcount),hl
ld	hl,(_ext_vector)
ld	c,(hl)
inc	hl
ld	b,(hl)
ld	(_curfname),bc
jp	l21
l18:
ld	(ix+-3),0
ld	hl,(_curfname)
ld	(_fnptr),hl
jp	l25
l22:
ld	hl,(_fnptr)
ld	a,(hl)
cp	63
jp	z,L3
ld	a,(hl)
cp	42
jp	nz,l24
L3:
ld	(ix+-3),1
l24:
ld	hl,(_fnptr)
inc	hl
ld	(_fnptr),hl
l25:
ld	hl,(_fnptr)
ld	a,(hl)
or	a
jp	nz,l22
ld	a,(ix+-3)
or	a
jp	z,l27
call	_expand
ld	a,l
or	h
jp	nz,l20
ld	hl,0
jp	cret
l27:
ld	hl,17
push	hl
call	_alloc
pop	bc
push	hl
ld	de,(_loc_vector)
ld	hl,(_vcount)
add	hl,hl
add	hl,de
pop	de
ld	(hl),e
inc	hl
ld	(hl),d
ld	hl,(_curfname)
ld	(ix+-2),l
ld	(ix+-1),h
jp	l29
l30:
ld	a,(ix+-3)
add	a,32
ld	l,(ix+-2)
ld	h,(ix+-1)
inc	hl
ld	(ix+-2),l
ld	(ix+-1),h
dec	hl
ld	(hl),a
l29:
ld	l,(ix+-2)
ld	h,(ix+-1)
ld	a,(hl)
ld	(ix+-3),a
or	a
jp	nz,l30
ld	hl,(_curfname)
push	hl
ld	de,(_loc_vector)
ld	hl,(_vcount)
inc	hl
ld	(_vcount),hl
dec	hl
add	hl,hl
add	hl,de
ld	c,(hl)
inc	hl
ld	b,(hl)
push	bc
call	_strcpy
pop	bc
pop	bc
l20:
ld	hl,(_ext_vector)
inc	hl
inc	hl
ld	(_ext_vector),hl
ld	c,(hl)
inc	hl
ld	b,(hl)
ld	(_curfname),bc
l21:
ld	hl,(_in_count)
dec	hl
ld	(_in_count),hl
inc	hl
ld	a,l
or	h
jp	nz,l18
ld	hl,(_vcount)
ld	(ix+6),l
ld	(ix+7),h
ld	de,(_loc_vector)
ld	hl,(_vcount)
inc	hl
ld	(_vcount),hl
dec	hl
add	hl,hl
add	hl,de
ld	de,-1
ld	(hl),e
inc	hl
ld	(hl),d
ld	hl,(_vcount)
add	hl,hl
push	hl
call	_alloc
pop	bc
ld	(_ext_vector),hl
jp	l32
l33:
ld	de,(_loc_vector)
ld	hl,(_vcount)
add	hl,hl
add	hl,de
ld	c,(hl)
inc	hl
ld	b,(hl)
ld	de,(_ext_vector)
ld	hl,(_vcount)
add	hl,hl
add	hl,de
ld	(hl),c
inc	hl
ld	(hl),b
l32:
ld	hl,(_vcount)
dec	hl
ld	(_vcount),hl
inc	hl
ld	a,l
or	h
jp	nz,l33
ld	l,(ix+6)
ld	h,(ix+7)
jp	cret
global	brelop
global	wrelop
global	wrelop
global	wrelop
global	_printf
global	shal
global	_index
psect	bss
F563:
defs	2
F564:
defs	2
F565:
defs	2
F566:
defs	1
F567:
defs	2
F568:
defs	2
F569:
defs	2
psect	text
_expand:
call ncsv
defw -42
call	_getuid
ld	h,0
ld	(F569),hl
ld	hl,(_curfname)
push	hl
push	ix
pop	de
ld	hl,-42
add	hl,de
push	hl
call	_setfcb
pop	bc
pop	bc
ld	b,65
ld	a,(ix+-42)
call	brelop
jp	c,L5
ld	e,(ix+-42)
ld	d,0
ld	hl,80
call	wrelop
jp	nc,l36
L5:
ld	(ix+-42),63
l36:
ld	hl,1
ld	(F568),hl
ld	(F567),hl
jp	l40
l37:
ld	de,9
ld	hl,(F567)
or	a
sbc	hl,de
jp	nz,l41
ld	hl,1
ld	(F568),hl
l41:
push	ix
pop	de
ld	hl,(F567)
add	hl,de
ld	de,-42
add	hl,de
ld	a,(hl)
cp	42
jp	nz,l42
ld	hl,0
ld	(F568),hl
l42:
ld	hl,(F568)
ld	a,l
or	h
jp	nz,l39
push	ix
pop	de
ld	hl,(F567)
add	hl,de
ld	de,-42
add	hl,de
ld	(hl),63
l39:
ld	hl,(F567)
inc	hl
ld	(F567),hl
l40:
ld	de,(F567)
ld	hl,11
call	wrelop
jp	p,l37
ld	l,(ix+-1)
ld	h,0
push	hl
call	_setuid
ld	hl,17
ld	(F568),hl
ld	hl,128
ex	(sp),hl
ld	hl,26
push	hl
call	_bdos
pop	bc
pop	bc
jp	l44
l45:
ld	hl,17
push	hl
call	_alloc
pop	bc
ex	de,hl
ld	(F564),de
push	de
ld	de,(_loc_vector)
ld	hl,(_vcount)
inc	hl
ld	(_vcount),hl
dec	hl
add	hl,hl
add	hl,de
pop	de
ld	(hl),e
inc	hl
ld	(hl),d
ld	de,254
ld	hl,(_vcount)
call	wrelop
jp	m,l47
ld	hl,29f
push	hl
call	_printf
ld	hl,(F569)
ex	(sp),hl
call	_setuid
pop	bc
ld	hl,0
jp	cret
l47:
ld	de,129
ld	b,5
ld	hl,(F567)
call	shal
add	hl,de
ld	(F563),hl
ld	l,58
push	hl
ld	hl,(_curfname)
push	hl
call	_index
pop	bc
pop	bc
ld	a,l
or	h
jp	z,l48
ld	hl,(_curfname)
ld	a,(hl)
cp	63
jp	z,l48
ld	(F565),hl
l51:
ld	hl,(F565)
ld	a,(hl)
inc	hl
ld	(F565),hl
ld	(F566),a
ld	hl,(F564)
inc	hl
ld	(F564),hl
dec	hl
ld	(hl),a
cp	58
jp	nz,l51
l48:
ld	hl,12
ld	(F567),hl
jp	l55
l52:
ld	de,3
ld	hl,(F567)
or	a
sbc	hl,de
jp	nz,l56
ld	hl,(F564)
inc	hl
ld	(F564),hl
dec	hl
ld	(hl),46
l56:
ld	hl,(F563)
ld	a,(hl)
inc	hl
ld	(F563),hl
and	127
add	a,32
ld	hl,(F564)
ld	(hl),a
cp	32
jp	z,l55
inc	hl
ld	(F564),hl
l55:
ld	hl,(F567)
dec	hl
ld	(F567),hl
ld	a,l
or	h
jp	nz,l52
ld	hl,(F564)
ld	(hl),0
ld	hl,18
ld	(F568),hl
l44:
push	ix
pop	de
ld	hl,-42
add	hl,de
ex	de,hl
ld	hl,-42
add	hl,sp
ld	sp,hl
ex	de,hl
ld	bc,42
ldir
ld	hl,(F568)
push	hl
call	_bdos
exx
ld	hl,44
add	hl,sp
ld	sp,hl
exx
ld	a,l
rla
sbc	a,a
ld	h,a
ld	(F567),hl
xor	a
ld	h,a
ld	de,255
or	a
sbc	hl,de
jp	nz,l45
ld	hl,(F569)
push	hl
call	_setuid
pop	bc
ld	hl,1
jp	cret
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
global	_getch
global	_flush
global	_Inhost
global	_Dialing
global	_report
global	_QuitFlag
_opabort:
call	_getch
xor	a
ld	h,a
ld	(_Lastkey),hl
ld	de,27
or	a
sbc	hl,de
jp	nz,l60
call	_flush
ld	hl,(_Inhost)
ld	a,l
or	h
jp	nz,l61
ld	hl,(_Dialing)
ld	a,l
or	h
jp	nz,l61
ld	hl,39f
push	hl
ld	hl,12
push	hl
call	_report
pop	bc
pop	bc
l61:
ld	hl,1
ld	(_QuitFlag),hl
l60:
ld	hl,(_QuitFlag)
ret	
global	_readock
global	_mread
global	wrelop
psect	bss
F574:
defs	2
F575:
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
ld	hl,F575
push	hl
call	_mread
pop	bc
pop	bc
pop	bc
ld	(F574),hl
ld	de,1
call	wrelop
jp	p,l63
ld	hl,-2
jp	cret
l63:
ld	de,1
ld	hl,(F574)
or	a
sbc	hl,de
jp	nz,l66
ld	a,(F575)
ld	l,a
rla
xor	a
ld	h,a
jp	cret
l67:
ld	de,F575
ld	hl,(F574)
dec	hl
ld	(F574),hl
add	hl,de
ld	a,(hl)
cp	24
jp	z,l66
ld	hl,-1
jp	cret
l66:
ld	hl,(F574)
ld	a,l
or	h
jp	nz,l67
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
ld	hl,49f
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
F583:
defs	2
F584:
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
ld	(F584),hl
push	hl
call	_readline
pop	bc
ld	(F583),hl
ld	de,-2
or	a
sbc	hl,de
jp	z,l74
ld	hl,(F583)
xor	a
ld	h,a
jp	cret
l76:
ld	hl,-2
jp	cret
l74:
ld	hl,(_Lastkey)
ld	a,l
or	h
jp	z,l76
jp	cret
global	_box
psect	data
F586:
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
defw	159f
F587:
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
global	_fputc
global	__iob
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
ld	hl,__iob+8
ex	(sp),hl
ld	hl,43
push	hl
call	_fputc
pop	bc
pop	bc
ld	(ix+-2),1
ld	(ix+-1),0
jp	l81
L7:
ld	hl,45
push	hl
call	_fputc
pop	bc
pop	bc
ld	l,(ix+-2)
ld	h,(ix+-1)
inc	hl
ld	(ix+-2),l
ld	(ix+-1),h
l81:
ld	de,40
ld	l,(ix+-2)
ld	h,(ix+-1)
call	wrelop
ld	hl,__iob+8
push	hl
jp	m,L7
ld	hl,43
push	hl
call	_fputc
pop	bc
ld	hl,19
ex	(sp),hl
ld	hl,13
push	hl
call	_locate
pop	bc
ld	hl,__iob+8
ex	(sp),hl
ld	hl,43
push	hl
call	_fputc
pop	bc
pop	bc
ld	(ix+-2),1
ld	(ix+-1),0
jp	l85
L8:
ld	hl,45
push	hl
call	_fputc
pop	bc
pop	bc
ld	l,(ix+-2)
ld	h,(ix+-1)
inc	hl
ld	(ix+-2),l
ld	(ix+-1),h
l85:
ld	de,40
ld	l,(ix+-2)
ld	h,(ix+-1)
call	wrelop
ld	hl,__iob+8
push	hl
jp	m,L8
ld	hl,43
push	hl
call	_fputc
pop	bc
pop	bc
ld	(ix+-2),1
ld	(ix+-1),0
jp	l89
l86:
ld	hl,19
push	hl
ld	l,(ix+-2)
ld	h,(ix+-1)
inc	hl
inc	hl
push	hl
call	_locate
pop	bc
ld	hl,__iob+8
ex	(sp),hl
ld	hl,124
push	hl
call	_fputc
pop	bc
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
ld	hl,__iob+8
ex	(sp),hl
ld	hl,124
push	hl
call	_fputc
pop	bc
pop	bc
ld	l,(ix+-2)
ld	h,(ix+-1)
inc	hl
ld	(ix+-2),l
ld	(ix+-1),h
l89:
ld	de,11
ld	l,(ix+-2)
ld	h,(ix+-1)
call	wrelop
jp	m,l86
call	_clrbox
ld	(ix+-2),1
ld	(ix+-1),0
jp	l93
l90:
ld	de,F587
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
ld	de,F586
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
l93:
ld	de,11
ld	l,(ix+-2)
ld	h,(ix+-1)
call	wrelop
jp	m,l90
jp	cret
global	wrelop
_clrbox:
global csv
call csv
push hl
ld	(ix+-2),3
ld	(ix+-1),0
jp	l98
l95:
ld	hl,20
push	hl
ld	l,(ix+-2)
ld	h,(ix+-1)
push	hl
call	_locate
pop	bc
ld	hl,169f
ex	(sp),hl
call	_printf
pop	bc
ld	l,(ix+-2)
ld	h,(ix+-1)
inc	hl
ld	(ix+-2),l
ld	(ix+-1),h
l98:
ld	de,13
ld	l,(ix+-2)
ld	h,(ix+-1)
call	wrelop
jp	m,l95
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
l101:
call	_mrd
ld	(ix+-4),l
ld	(ix+-3),h
ld	a,l
or	h
jp	nz,l102
ld	l,(ix+10)
ld	h,(ix+11)
dec	hl
ld	(ix+10),l
ld	(ix+11),h
inc	hl
ld	a,l
or	h
jp	z,l102
call	_opabort
ld	a,l
or	h
jp	z,l101
l102:
ld	a,(ix+-4)
or	(ix+-3)
jp	z,l103
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
l103:
ld	l,(ix+-2)
ld	h,(ix+-1)
jp	cret
global	_mchin
global	_Stopped
global	_mchout
psect	bss
F594:
defs	2
psect	text
_mcharinp:
call	_mchin
ld	(F594),hl
ld	hl,(_Stopped)
ld	a,l
or	h
jp	z,l105
ld	hl,17
push	hl
call	_mchout
pop	bc
ld	hl,0
ld	(_Stopped),hl
l105:
ld	hl,(F594)
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
jp	nz,L15
ld	hl,(_Stopped)
ld	a,l
or	h
jp	z,L14
L15:
ld	hl,1
ret	
L14:
ld	hl,0
ret	
psect	data
19:
defb	63,63,63,63,63,63,63,63,46,63,63,63,0
29:
defb	84,111,111,32,109,97,110,121,32,102,105,108,101,32,110,97
defb	109,101,115,46,10,0
39:
defb	79,112,101,114,97,116,111,114,32,97,98,111,114,116,0
49:
defb	32,37,115,32,10,10,0
59:
defb	0
69:
defb	80,114,111,116,111,99,111,108,58,0
79:
defb	70,105,108,101,32,78,97,109,101,58,0
89:
defb	70,105,108,101,32,83,105,122,101,58,0
99:
defb	66,108,111,99,107,32,67,104,101,99,107,58,0
109:
defb	84,114,97,110,115,102,101,114,32,84,105,109,101,58,0
119:
defb	66,121,116,101,115,32,84,114,97,110,115,102,101,114,114,101
defb	100,58,0
129:
defb	66,108,111,99,107,115,32,84,114,97,110,115,102,101,114,114
defb	101,100,58,0
139:
defb	83,101,99,116,111,114,115,32,105,110,32,70,105,108,101,58
defb	0
149:
defb	69,114,114,111,114,32,67,111,117,110,116,58,0
159:
defb	76,97,115,116,32,77,101,115,115,97,103,101,58,32,32,78
defb	79,78,69,0
169:
defb	32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
defb	32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
defb	32,32,32,32,32,32,32,0
psect	bss
_vcount:
defs	2
_ext_vector:
defs	2
_in_count:
defs	2
_loc_vector:
defs	2
_curfname:
defs	2
_fnptr:
defs	2
psect	text
58,0
139:
defb	83,101,99,116,111,114,115,32,105,110,32,70,105,108,101,58
defb