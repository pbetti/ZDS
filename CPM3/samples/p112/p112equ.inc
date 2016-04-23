false	equ	0
true	equ	not false

banked	equ	true

date	macro
	db	'26-May-2007'	; BIOS build date
	endm

common$base equ 0C000h          ; 48k bank size
num$banks   equ 3               ; system, user and one extra bank


; Z182 hardware configurations

tkssec	equ	20		; ticks per second

hispeed	equ	true

mhz	defl	16		; CPU xtal freq, truncated to nearest even MHz

	if	not hispeed
mhz	defl	mhz / 2
	endif

;prtcons equ	50000 / tkssec	; use 50000 for 8/16 MHz systems
;				;     51200 for 6.144/9.216/18.432/36.864
prtcons	equ	2500 ; div is signed in M80!

reload	equ	prtcons * mhz	; Programmable Reload Timer value

