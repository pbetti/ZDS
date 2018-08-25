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
;; 20180819	- Lowecased
;; 20180823	- fixed, changed main routines
;;---------------------------------------------------------------------

	title	'time module for the modular cp/m 3 bios'

	.z80

	; define logical values:
	include	common.inc

	public	macclk

	extrn	@date,@hour,@min,@sec
	extrn	@bios$stack

	if	banked
	extrn	?bank
	extrn	@cbnk
	endif


	cseg				; time must be done from resident memory

macclk:
	ld	(spsave),sp
	ld	sp,@bios$stack		; switch to a local stack

	if	banked
	ld	a,(@cbnk)
	push	af			; save current bank number
	ld	a,0
	call	?bank
	endif

	call	dotime

	if	banked
	pop	af
	call	?bank			; restore caller's bank
	endif

	ld	sp,(spsave)
	ret

spsave: dw	0

	; zds clock support. hardware details behind sysbios

	if	banked
	dseg				; following goes to banked memory
	endif

dotime:
	ld	a,c			; set time ?
	or	a
        jp	nz,settime

	push	hl
	push	de
	ld	hl,timstr		; point to the destination time string
	di
	call	bbrdtime		; read clock
	ei
	ld	a,(dsmon)		; fetch month
	call	bcd2bin
	dec	a			; month = 0...11
	add	a,a
	ld	e,a
	ld	d,0
	ld	hl,mdays
	add	hl,de
	ld	c,(hl)
	inc	hl
	ld	b,(hl)			; month_days[month]
	ld	a,(dsyear)		; fetch year
	call	bcd2bin
	sub	78			; 1978
	jr	nc,t1
	add	a,100
t1:	ld	de,365
	ld	l,a
	ld	h,d
	call	mlthl
	ld	h,l
	ld	l,0
	ld	d,a
	call	mltde
	add	hl,de			; HL = A * 365
	add	hl,bc			; + month_days[month]
	ld	a,(dsday)		; fetch day
	call	bcd2bin
	ld	c,a			; day = 1...29,30, or 31
	ld	b,0
	add	hl,bc			; + day
	push	hl
	ld	hl,78			; 1978
	ld	de,0
	call	leapdays
	ex	de,hl
	pop	hl
	or	a
	sbc	hl,de			; - leap_days(78, 0)
	push	hl
	ld	a,(dsyear)		; year
	call	bcd2bin
	cp	78
	jr	nc,t2
	add	a,100
t2:	ld	l,a
	ld	h,0
	ld	a,(dsmon)		; month
	call	bcd2bin
	dec	a			; month = 0...11
	ld	e,a
	ld	d,0
	call	leapdays
	pop	de
	add	hl,de			; + leap_days(year, month)
	ld	(@date),hl
	ld	a,(dshour)
	call	cvthour			; convert hour to 24-hours format
	ld	(@hour),a
	ld	a,(dsmin)
	ld	(@min),a
	ld	a,(dssec)
	ld	(@sec),a
	pop	de
	pop	hl
	ret

settime:
	push	hl
	push	de
	ld	hl,(@date)
	call	convdate
	ld	a,(@hour)
	ld	(dshour),a
	ld	a,(@min)
	ld	(dsmin),a
	ld	a,(@sec)
	ld	(dssec),a
	ei
	ld	hl,timstr
	di
	call	bbsttim			; activate and set the clock
	ei
	pop	de
	pop	hl
	ret

	; Support routines

leapdays:
	ld	h,0			; just in case...
	ld	a,l
	rrca
	rrca
	and	3Fh
	ld	l,a			; HL = year / 4
	and	3
	ret	nz
	push	hl
	ld	hl,mdays
	add	hl,de
	add	hl,de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)			; month_days[month]
	pop	hl
	ld	a,d
	or	a
	ret	nz
	ld	a,59
	cp	d
	ret	nc
	dec	hl
	ret

bcd2bin:
	push	de
	ld	d,a
	and	0F0h
	ld	e,a
	ld	a,d
	and	0Fh
	srl	e
	add	a,e
	srl	e
	srl	e
	add	a,e
	pop	de
	ret

bin2bcd:
	push	bc
	ld	b,10
	ld	c,-1
sb1:	inc	c
	sub	b
	jr	nc,sb1
	add	a,b
	sla	c
	sla	c
	sla	c
	sla	c
	or	c
	pop	bc
	ret

; convert DS1302 hour to 24-hour format

cvthour:
	bit	7,a			; already in 24-hour format?
	ret	z			; return if yes
	and	7Fh
	bit	5,a			; check AM/PM bit
	ret	z			; return if AM
	and	1Fh
	add	a,12h			; correct if PM
	cp	24h			; hour >= 24?
	ret	c			; return if not
	sub	24h			; otherwise correct it
	ret

; compute day of week from number of days

computedow:
	push	hl
	dec	hl
	ld	e,7
	call	mydiv16			; day of week = (num days - 1) mod 7
	pop	hl
	ret

; compute year from number of days, returns year in BC and
; remaining number of days in HL

computeyear:
	ld	bc,78			; base year
cy1:	ld	de,365			; year length
	ld	a,c
	and	3			; leap year?
	jr	nz,cy2
	inc	de			; 366
cy2:	push	hl
	dec	de
	or	a
	sbc	hl,de			; rem days - year length
	jr	c,cy3			; return if <= 0
	pop	af
	dec	hl
	inc	bc			; ++year
	jr	cy1
cy3:	pop	hl
	ret

; compute month from remaining number of days
; on entry, C = leap bias, HL = rem days
; returns month in DE, rem days in HL

computemonth:
	push	hl
	ld	de,11			; E = month, D = 0
	ld	b,d			; B = 0
cm1:	ld	a,e
	cp	2			; jan or feb?
	jr	nc,cm2
	ld	c,b			; leap bias = 0
cm2:	ld	hl,mdays
	add	hl,de
	add	hl,de
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a			; HL = month_days[month]
	add	hl,bc			;      + leap bias
	ex	de,hl
	ex	(sp),hl			; HL = rem days
	ld	a,e
	sub	l
	ld	a,d
	sbc	a,h
	ex	(sp),hl
	ex	de,hl			; mdays[month] + leap_bias < rem days?
	jr	c,cm3			; return if yes
	dec	e
	jp	p,cm1
cm3:	pop	hl
	ret

; convert CP/M date (num of days) to dd mm yy
; HL - number of days (1 = Jan 1, 1978)

convdate:
	call	computedow		; compute day of week
	inc	a			; base 1
	ld	(dsdow),a
	call	computeyear		; compute year, return remaining days
	ld	a,c
	cp	100			; above year 2000?
	jr	c,cvd0
	sub	100			; correct if yes
cvd0:	call	bin2bcd
	ld	(dsyear),a
	ld	e,0			; leap bias
	ld	a,c
	and	3			; (year & 3) == 0 ?
	jr	nz,cvd1
	ld	a,l
	sub	59+1			; ..and (rem days > 59) ?
	ld	a,h			;   (after feb 29 on leap year)
	sbc	a,0
	jr	c,cvd1
	inc	e			; ..then leap bias = 1
cvd1:	ld	c,e
	call	computemonth
	push	de
	push	hl
	ld	hl,mdays
	add	hl,de
	add	hl,de
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a			; HL = month_days[month]
	ld	b,0
	add	hl,bc			;      + leap bias
	ex	de,hl
	pop	hl
	or	a
	sbc	hl,de			; day = rem days - HL
	ld	a,l
	call	bin2bcd
	ld	(dsday),a
	pop	de
	inc	de			; ++month (conver to base 1)
	ld	a,e
	call	bin2bcd
	ld	(dsmon),a
	ret



mlthl:
	push	af
	push	bc
	push	de
	ld	e,l
	ld	d,0
	ld	c,h
	ld	b,0
	call	mul16
	pop	de
	pop	bc
	pop	af
	ret

mltde:
	push	af
	push	bc
	push	hl
	ld	a,d
	ld	d,0
	ld	c,a
	ld	b,0
	call	mul16
	ex	de,hl
	pop	hl
	pop	bc
	pop	af
	ret

;.....
; divide 16-bit number in hl by 8-bit number in e.
; returns 16-bit quotient in hl, 8-bit remainder in a.

mydiv16:
	ld	b,16+1
	xor	a
mydiv:	adc	a,a
	sbc	a,e
	jr	nc,mydiv0
	add	a,e
mydiv0:	ccf
	adc	hl,hl
	djnz	mydiv
	ret

;
;;	mul16 - 16x16 bit multiplication
;;
;; 	in  de = multiplicand
;;	    bc = multiplier
;;	out de = result
mul16:	ld	a,c				; a = low mpler
	ld	c,b				; c = high mpler
	ld	b,16				; counter
	ld	hl,0
ml1601:	srl	c				; right shift mpr high
	rra					; rot. right mpr low
	jr	nc,ml1602			; test carry
	add	hl,de				; add mpd to result
ml1602:	ex	de,hl
	add	hl,hl				; double shift mpd
	ex	de,hl
	djnz	ml1601
	ret


mdays:
;		jan feb mar apr may jun jul aug sep oct nov dec
	dw	000,031,059,090,120,151,181,212,243,273,304,334

timstr:
	ds	8		; string for reading/setting date/time
dssec	equ	timstr+0
dsmin	equ	timstr+1
dshour	equ	timstr+2
dsday	equ	timstr+3
dsmon	equ	timstr+4
dsdow	equ	timstr+5
dsyear	equ	timstr+6

	db	0

	end
