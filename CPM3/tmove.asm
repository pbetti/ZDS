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
;;---------------------------------------------------------------------

; 	TITLE	'BANK & MOVE MODULE FOR THE MODULAR CP/M 3 BIOS'
;
; ;	CP/M-80 Version 3	-- Modular BIOS
; ;	Bank and Move Module for P112
; ;	Initial version 1.0
; ;	Compile with M80
;
; 	PUBLIC	?MOVE,?XMOVE,?BANK
;
; 	EXTRN	@CBNK,@DBNK,@DMA
;
; 	.Z80
;
; 	; define logical values:
TRUE	EQU	-1
FALSE	EQU	0


	; determine if for bank select or not:
BANKED	EQU	TRUE		;< ... BANKED VERSION

	;
	; some other equs...
	;
CR	EQU     0DH		; CARRIAGE RETURN
LF	EQU     0AH		; LINE FEED;
FF	EQU	0CH		; FORM FEED (clear screen)

	include syshw.inc

PAGES32K	EQU	32768/4096	; physical pages for a 32k bank
PAGES48K	EQU	49152/4096	; physical pages for a 48k bank



BANKED		EQU	TRUE

	ORG	$9000

	NOP
	NOP
	NOP
	LD	A,1			; switch to bank 1
	CALL	?BANK
	NOP
	LD	A,0			; switch to bank 0
	CALL	?BANK
	NOP
	NOP
	LD	BC,$0100		; b 1 to b 0
	CALL	?XMOVE
	LD	DE,$0100		; from
	LD	HL,$0200		; to
	LD	BC,128			; size
	CALL	?MOVE
	NOP
	NOP

@CBNK:	DEFB	0


	include move.asm

	END

