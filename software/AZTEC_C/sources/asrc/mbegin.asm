;Copyright (C) 1981,1982,1983 by Manx Software Systems
; :ts=8
BDOS	equ	5
	extrn Croot_
	dseg
;	
;	The 3 "ds 4" statements below must remain in EXACTLY the same order,
;	with no intervening statements!
;
	public	lnprm, lntmp, lnsec
lnprm:	ds	4
lntmp:	ds	4
lnsec:	ds	4
;
	public	Sysvec_
Sysvec_:	dw	0
	dw	0
	dw	0
	dw	0
	public	$MEMRY
$MEMRY:	dw	-1
	public	sbot
sbot: dw	0
	public	errno_
errno_:	dw	0
;
fcb:	db	0,'???????????',0,0,0,0
	ds	16
	cseg
	public	.begin
	public	_exit_
.begin:
	LHLD	BDOS+1
	SPHL
	lxi	d,-2048
	dad	d		;set heap limit at 2K below stack
	shld	sbot
	CALL	Croot_
_exit_:
	mvi	c,17	;search for first (used to flush deblock buffer)
	lxi	d,fcb
	call	BDOS
	lxi	b,0
	call	BDOS
	JMP	_exit_
	end	.begin
