;;
;; REBOOT.ASM
;; (c) 2014 Piergiorgio Betti <pbetti@lpconsul.net>
;; This is a freeware program. You can use it without limitations.
;;
;;-----------------------------------------------------------------------------
;; Simple utility to reboot system
;;.............................................................................
;;
;; Revisions:
;;

; load symbols from BIOS ...
	include	darkstar.equ
	include syshw.inc
;
;
;
;--[ REAL CODE START HERE ]
;
	ORG	TPA
	;
	JP	REBOOT
;
;--[ INTERNAL STORAGE ]
;
; VARS
;
; MESSAGES
;
;
;--[ START ]

REBOOT:
	JP	$FC00

	;
	; TERMINATION
	;
EOP:
	; unreachable
	JP	$0000

;
;--[ ROUTINES ]
;


ZCO:	PUSH	AF	;Write character that is in [C]
	CALL	BBCONOUT
	POP	AF
	RET



; Print a string in [DE] up to '$'
PSTRING:
	PUSH	BC
	PUSH	DE
	PUSH	HL
	EX	DE,HL
PSTRX:	LD	A,(HL)
	CP	'$'
	JP	Z,DONEP
	CP	0
	JP	Z,DONEP
	LD	C,A
	CALL	ZCO
	INC	HL
	JP	PSTRX
DONEP:	POP	HL
	POP	DE
	POP	BC
	RET


ZCI:	;Return keyboard character in [A]
	PUSH	BC
	PUSH	DE
	PUSH	HL
	CALL	BBCONIN
	PUSH	AF
	LD	C,A
	CALL	BBCONOUT
	POP	AF
	POP	HL
	POP	DE
	POP	BC
	RET

ZCSTS:
	PUSH	BC
	PUSH	DE
	PUSH	HL
	CALL	BBCONST
	POP	HL
	POP	DE
	POP	BC
	CP	1
	RET


;--[ END OF PROGRAM ]
;

; REAL END
	END

;--EOF
