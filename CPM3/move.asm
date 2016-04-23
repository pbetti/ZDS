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

	TITLE	'BANK & MOVE MODULE FOR THE MODULAR CP/M 3 BIOS'

	; define logical values:
	include	common.inc
	include syshw.inc

	PUBLIC	?MOVE,?XMOVE,?BANK
	IF BANKED
	PUBLIC	BANKBF
	ENDIF

	EXTRN	@CBNK

	.Z80

PAGES32K	EQU	32768/4096	; physical pages for a 32k bank
PAGES48K	EQU	49152/4096	; physical pages for a 48k bank

	CSEG	; must be in common memory

	; setup an inter-bank move of 128 bytes on the next call
	; to ?move
?XMOVE:
	IF BANKED
	LD	(SRCBNK),BC		; C -> srcbnk, b -> dstbnk
	ENDIF
	RET

; select bank in A

?BANK:
	IF BANKED
	LD	(TMPSP),SP
	LD	SP,TMPSTK
	PUSH	BC
	PUSH	DE
	PUSH	HL
	DI				; for safety
	; **************************************************************
	; we MUST have first 50 bytes in cpu page 0 copied in every bank
	; so save them in buffer
	; **************************************************************
	LD	HL,0
	LD	DE,PAG0BF
	LD	BC,$50
	LDIR
	; normalize bank page.
	; for now we leave a 32k hole every bank for 32k banks
	; just in case we switch to 48k banks (and 16k holes)
	SLA	A
	SLA	A
	SLA	A
	SLA	A
	; A is now physical base page address of bank
	; meaning bank 1 has pages 10h to 17h (for 32k banks)
	LD	E,PAGES48K		; # pages
	LD	C,MMUPORT		; MMU I/O address
	LD	D,A			; physical page pointer
	XOR	A
BNKPAG:
	LD	B,A			; logical page pointer
	OUT	(C),D
	INC	D			; phis. page address 00xxxh, 01xxxh....
	ADD	A,$10			; log. page address 0h,1h,2h.... (00h,10h....)
	DEC	E
	JR	NZ,BNKPAG
	; **************************************************************
	; UPDATE first 50 bytes in cpu page 0
	; **************************************************************
	LD	HL,PAG0BF
	LD	DE,0
	LD	BC,$50
	LDIR
	;
	POP	HL
	POP	DE
	POP	BC
	LD	SP,(TMPSP)
	EI				; let's run
	ENDIF
	RET

	;  block move
?MOVE:
	IF BANKED
	LD	A,(SRCBNK)		; contains 0ffh if normal block move
	INC	A
	JR	NZ,INTERBANKMOVE
	ENDIF
	EX	DE,HL			; we are passed source in de and dest in hl
	LDIR				; use z80 block move instruction
	EX	DE,HL			; need next address in same regs
	RET

	IF BANKED

INTERBANKMOVE:		; source in HL, dest in DE, count in BC

	LD	A,(SRCBNK)
	CALL	?BANK			; source in place
	;
	PUSH	HL
	PUSH	BC
	EX	DE,HL
	LD	DE,BANKBF		; to buffer
	LDIR
	;
	POP	BC
	POP	DE
	PUSH	HL
	LD	A,(DSTBNK)
	CALL	?BANK			; dest. in place
	;
	LD	HL,BANKBF
	LDIR				; to destination
	POP	HL
	EX	DE,HL
	;
	LD	A,(@CBNK)		; restore current
	CALL	?BANK
	LD	A,$FF
	LD	(SRCBNK),A
	RET

	DEFS	12
TMPSTK:
TMPSP:	DEFS	2
SRCBNK:	DEFB	0FFH
DSTBNK:	DEFB	0FFH
BANKBF:	DEFS	128		; local temporary buffer for extended moves
PAG0BF:	DEFS	50



	ENDIF

	END

