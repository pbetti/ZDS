;
; test receive 1
;

INIT	equ	$1
READY	equ	$5
ACK	equ	$7
OKGO	equ	$3

DATAP	equ	$3
CNTRP	equ	$2
BEEPP	equ	$8f
BUFFER	equ	$7000

	org $100

START:	
	ld a,INIT
	out (CNTRP),a

	ld hl,BUFFER
LOOP:
	in a,(CNTRP)
	bit 0,a
	jr nz,LOOP

	ld a,READY
	out (CNTRP),a
WSTRB:
	in a,(CNTRP)
	bit 0,a
	jr z,WSTRB

	in a,(DATAP)
	ld (hl),a
	inc hl
	ld a,ACK
	out (CNTRP),a
	ld a,ACK
	out (CNTRP),a
	ld a,ACK
	out (CNTRP),a
	ld a,OKGO
	out (CNTRP),a
	in a,(CNTRP)
	bit 1,a
	jr nz,STOP
	jp LOOP
STOP:
	in a,(BEEPP)
	halt


	end


