; This is the VIDATT routine for WordStar 4.0, CP/M Edition, tailored for 
; the Kaypro 4/84 screen 9/9/87 by Bob Snider, Columbus OH, CIS 70000,302.
; This routine ignores the BRITE flag, since all functions are customized.
; To modify to your own likes see the definitions below for M$UNDERLINE,
; M$DIM, M$REVERSE, and M$BLINK.

; Bits passed in reg C indicate WordStar text attributes:
; none	Normal text
; 0	Strike out
; 1	Warning and error messages
; 2	Marked block of text
; 3	Underlined
; 4	Subscripted
; 5	Superscripted
; 6	Bold
; 7	Italic or ribbon color

; The following labels define the above bits.
A$STRIKE	EQU	00000001B
A$WARNING	EQU	00000010B
A$MARKED	EQU	00000100B
A$UNDERLINED	EQU	00001000B
A$SUBSCRIPT	EQU	00010000B
A$SUPERSCRIPT	EQU	00100000B
A$BOLD		EQU	01000000B
A$ITALIC	EQU	10000000B
A$ALL		EQU	11111111B	;ALL ATTRIBUTES

; The following labels define the screen action to be taken if any
; of the attributes specified are on. The screen actions are independent
; of one another; you can have any combination active at once for a
; single WordStar attribute. If an action is not taken, its opposite 
; action is, ie. underscore versus no underscore.
; Plain text (00 attribute) will be normal everything.

; The bold and underlined attributes will appear underlined on the screen:
M$UNDERLINE	EQU	A$BOLD + A$UNDERLINED
; Everything except underlined attributes (and normal text) will appear dim:
M$DIM		EQU	A$ALL - A$UNDERLINED
; Bold, marked text, and warning messages will be in reverse video:
M$REVERSE	EQU	A$BOLD + A$MARKED + A$WARNING
; Nothing blinks. If you want it to, additionally change DOR: in the code:
M$BLINK		EQU	0

; Declare other symbols used.
ESC	EQU	1BH		;ASCII ESCAPE CHARACTER
STRING	EQU	0283H		;STRING DISPLAY ROUTINE IN WORDSTAR

	ORG	03C1H		;VIDATT STARTS HERE IN WS.COM
VIDATT:
	MOV	A,C		;GET VIDEO ATTRIBUTE BYTE
	LXI	H,UNDER		;POINT AT START UNDERSCORE STRING
	ANI	M$UNDERLINE	;ARE ANY BITS ON AS REQUESTED ABOVE?
	JNZ	DOU		;YES, USE IT
	LXI	H,NOUNDER	;NO, USE STOP UNDERSCORE INSTEAD
DOU:	CALL	STRING		;SEND THAT TO STRING ROUTINE
	MOV	A,C		;GET ATTRIBUTE AGAIN
	LXI	H,DIM		;POINT AT START LOW INTENSITY STRING
	ANI	M$DIM		;CHECK FOR ANY REQESTED ATTRIBUTES
	JNZ	DOD		;YES, USE IT
	LXI	H,NODIM		;NO, USE NORMAL (NOT DIM) INSTEAD
DOD:	CALL	STRING		;SEND STRING OUT
	MOV	A,C		;GET ATTR AGAIN
	LXI	H,REVERSE	;POINT AT REVERSE VIDEO STRING
	ANI	M$REVERSE	;CHECK FOR ANY REQUESTED ATTRIBUTES
	JNZ	DOR		;YES, USE IT
	LXI	H,NOREVERSE	;NO, USE NONREVERSED
DOR:	JMP	STRING		;SEND IT AND DON'T RETURN

; For those who want blinking, the JMP at DOR: must be changed to a CALL
; in order to fall thru into the blink test below. The clear screen
; string should turn off blinking initially.

	MOV	A,C		;GET ATTR ONE LAST TIME
	LXI	H,BLINK		;POINT AT BLINKING STRING
	ANI	M$BLINK		;IS IT WHATEVER?
	JNZ	DOB		;YES
	LXI	H,NOBLINK	;NO, USE NO BLINK
DOB:	JMP	STRING		;AND FINAL JUMP TO STRING ROUTINE

; These are the video strings for the Kaypro 4/84. Count and bytes.

UNDER:		DB	3,ESC,'B3'	;START UNDERLINE
NOUNDER:	DB	3,ESC,'C3'	;STOP UNDERLINE
DIM:		DB	3,ESC,'B1'	;START DIM
NODIM:		DB	3,ESC,'C1'	;STOP DIM
REVERSE:	DB	3,ESC,'B0'	;START REVERSE VIDEO
NOREVERSE:	DB	3,ESC,'C0'	;STOP REVERSE VIDEO
BLINK:		DB	3,ESC,'B2'	;START BLINK
NOBLINK:	DB	3,ESC,'C2'	;STOP BLINK
		DB	52H,51H,53H

ENDPATCH:
	END


