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
PRINT	equ	$0fb10
RAM3BUF	equ	$3043
CLEAR	equ	$0f0e7
CONSTR  equ	$0fa9c
LOCATE	equ	$0f06e

	org $e100

START:
	call CLEAR
;	ld hl,$0000
;	call LOCATE
;	ld b, $0ff
;LOOP:
;	ld c, b
;	call PRINT
;	djnz LOOP

STAMPA:
	;ld hl, STRING2
	;call CONSTR

	ret

	;org $200
STRING2:
	;defb 0,0
	defb 'CON DISPTR', $a0

	end
