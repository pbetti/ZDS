;
; common part for parload.asm and parload1.asm ...
;

RELADR	EQU	$A000			; WHERE TO RUN
BEGIN	EQU	TPA + 512		; PLACE FOR THE RELOCATED
					; PART (AT LOAD TIME)
;
;
TRUE	EQU	-1
FALSE	EQU	0
;
