;
; test video funcs
;
; link to DarkStar Monitor symbols...
include	Common.inc.asm
include	darkstar.equ


	org	tpa
	jp	begin

include	zdsvid.lib


begin:
	ld	hl,ms1
	call	dispwt
	; at home
	call	zdhomnc
	ld	hl,ms2
	call	dispwt
	; at home clear
	call	zdhome
	ld	hl,ms3
	call	dispwt
	; print, scroll
; 	ld	b,$30
; pst:	ld	hl,ms4
; 	call zddspnl
; 	ld	a,b
; ; 	call	h2aj2
; 	djnz	pst
; 	ld	hl,ms5
; 	call	dispwt
	; attributes
	call	zdhome
	ld	hl,amsn
	call	zddsp
	call	blnkon
	ld	hl,amsb
	call	zddsp
	call	blnkof
	call	revon
	ld	hl,amsr
	call	zddsp
	call	revof
	call	undron
	ld	hl,amsu
	call	zddsp
	call	undrof
	call	hliton
	ld	hl,amsh
	call	zddsp
	call	hlitof
	call	grphon
	ld	hl,amsg
	call	zddsp
	call	grphof
	call	dispwt
	; cursor off
	call	crsrof
	ld	hl,ms6
	call	dispwt

	; cursor on
	call	crsron
	ld	hl,ms7
	call	dispwt

	ld	h,0
	ld	l,0
	call	setcur
	ld	hl,ms0000
	call	zddsp

	ld	h,2
	ld	l,2
	call	setcur
	ld	hl,ms0202
	call	zddsp

	ld	h,10
	ld	l,40
	call	setcur
; 	ld	hl,ms1010
; 	call	zddsp


	call	zddspnl
	call	gchr
	call	inline
	defb	"End.",cr,lf,0

exit:
; 	jp	jboot
	jp	0
	;;
	;; routines
	;;
	;
	; show msg, wait user
dispwt:	call	zddsp
	call	zddspnl
	call	gchr
	ret
	;

setcur:
	push	bc
	ld	c,esc
	call	bbconout
; x address
	ld	a,l
	add	a,32
	ld	c,a
	call	bbconout
; now the y value
	ld	a,h
	add	a,32
	ld	c,a
	call	bbconout
; terminate
	ld	c,0
	call	bbconout
	pop	bc

	ret





	;
	; msgs...
MS1:	DEFB	"PRESS A KEY TO BEGIN",$00
MS2:	DEFB	"AT HOME NO CLEAR...",CR,LF,$00
MS3:	DEFB	"AT HOME WITH CLEAR...",CR,LF,$00
MS4:	DEFB	"ROW PRINT & SCROLL TEST ",$00
MS5:	DEFB	"PRINT,SCROLL END...",CR,LF,$00
MS6:	DEFB	"CURSOR OFF...",CR,LF,$00
MS7:	DEFB	"CURSOR ON...",CR,LF,$00
MS8:	DEFB	"40 COLUMN MODE...",CR,LF,$00
MS9:	DEFB	"80 COLUMN MODE...",CR,LF,$00
MS10:	DEFB	"CRT HARD RESET...",CR,LF,$00
MS0000:	DEFB	"@ POSITION 0,0",CR,LF,$00
MS0202:	DEFB	"@ POSITION 2,2",CR,LF,$00
MS1010:	DEFB	"@ POSITION 10,10",CR,LF,$00


MS99:	DEFB	"TEST END.",CR,LF,$00

AMSN:	DEFB	"> QUESTO E' NORMAL <",CR,LF,$00
AMSB:	DEFB	"> QUESTO E' BLINKING <",CR,LF,$00
AMSR:	DEFB	"> QUESTO E' REVERSE <",CR,LF,$00
AMSU:	DEFB	"> QUESTO E' UNDERLINE <",CR,LF,$00
AMSH:	DEFB	"> QUESTO E' HIGHLIGHT <",CR,LF,$00
AMSG:	DEFB	"> QUESTO E' GRAPHIC < (GRAPHIC)",CR,LF,$00
; 	DEFB	"> ",$1B,$0F,$0D,"QUESTO E' BIT 5 (UNKN)",$1B,$0E,$0D," <",CR,LF	;,$00
; 	DEFB	"> ",$1B,$11,$0D,"QUESTO E' BIT 6 (UNKN)",$1B,$10,$0D," <",CR,LF	;,$00
; 	DEFB	"> ",$1B,$1E,$0D,"QUESTO E' BIT 7 (UNKN)",$1B,$1D,$0D," <",CR,LF,$00

	END
