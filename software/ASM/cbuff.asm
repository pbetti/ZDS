
; 	.Z80
; 	ASEG

;----------------------------------------------------------------
; 	   This is a module in the ASMLIB library.
;
; This module reads a line of input from the console and puts it into
; a standard CP/M console buffer pointed to by DE on entry. This is
; a little nicer that CP/M as it allows buffers to be pre-initialized
; so that it is printed when the buffer is input so that defaults can
; be loaded before entry of data.
;
;			Written		R.C.H.          22/10/83
;			Last Update	R.C.H.          22/10/83
;----------------------------------------------------------------
;
; 	NAME	'cbuff'
; 	PUBLI	C	CBUFF
; 	EXTRN	BELL,CIE,COE	; get and put a byte to screen
;
; 	MACLI	B	Z80
;
CBUFF:
	PUSH	AF
	LD	A,(DE)		; get buffer size in bytes
	OR	A
	JP	Z,CBUFFEND
	PUSH	HL
	PUSH	BC
	PUSH	DE
	EX	DE,HL		; put string address into HL
	LD	C,A		; Now C = buffer maximum size
INIT:
	LD	B,00		; character read = 0
	INC	HL		; hl -> size of character read now
; Here we detect if there is some data in the buffer to be pre printed
; and if there is the we print it.
	LD	A,(HL)		; get number of chars. in the buffer
	INC	HL		; point to string space now.
	OR	A
	JR	Z,RDLOOP
; Print the initialized character string, save the size for later
	LD	B,A
	PUSH	BC		; save
INIT2:
	LD	A,(HL)		; get the character
	INC	HL		; point to next string space byte
	CALL	DSPCHR		; print it, maybe control character
	DJNZ	INIT2		; print all characters
	POP	BC		; restore # of characters
;
; On entry here HL-> string space, next free byte, B = number of characters
; in the string. C = number of bytes in the buffer.


RDLOOP:
	CALL	CIE		; get a character
	CP	0DH		; end if carriage return
	JR	Z,EXITRD	; exit
	CP	0AH
	JR	Z,EXITRD
	CP	08		; backspace ??
	JR	NZ,RDLP1	; if not then continue
	CALL	BACKSP		; else backspace
	JR	RDLOOP		; keep on backspacing
RDLP1:
	CP	018H		; delete line ?
	JR	NZ,RDLP2
DEL1:
	CALL	BACKSP		; delete a character
	JR	NZ,DEL1		; keep on till all character deaded
	JR	RDLOOP		; start again ebonettes
;
; If here we check if the buffer is full. If so we ring the bell
RDLP2:
	LD	E,A		; save the character
	LD	A,B		; load byte count
	CP	C		; is it equal to the maximum ?
	JR	C,STRCH		; store the character if not full
	CALL	BELL		; else ring the bell
	JR	RDLOOP		; get more characters
;
; Buffer not full so save the character
STRCH:
	LD	A,E		; get character
	LD	(HL),A		; save it
	INC	HL		; point to next buffer byte
	INC	B		; increment byte count
	CALL	DSPCHR		; display the (maybe control) character
	JR	RDLOOP		; do again, more characters
;
; Display a control character by preceeding it with a  '^'
;
DSPCHR:
	CP	020H		; was it a space ?
	JP	NC,COE		; if not then print & return
	LD	E,A		; else save character
	LD	A,'^'		; indicate a control character
	CALL	COE
	LD	A,E		; restore character
	ADD	A,040H		; make printable
	JP	COE
;
; Send a backspace and detect if at the start of the line.
;
BACKSP:
	LD	A,B		; get character count
	OR	A
	RET	Z		; return if line empty
	DEC	HL		; decrement byte pointer
	LD	A,(HL)		; get the character
	CP	020H		; is it a control character ?
	JR	NC,BSP1		; if not then delete 1 char only
	CALL	BSP		; send a backspace
BSP1:
	CALL	BSP		; backspace 1
	DEC	B		; one less string byte
	RET
;
; Send the backspace
BSP:
	LD	A,08
	CALL	COE
	LD	A,' '		; erase the character
	CALL	COE
	LD	A,08
	JP	COE		; send and return
EXITRD:
; Set the number of bytes read into the buffer byte at DE + 1.
;
	POP	DE		; restore all registers (buffer addr)
	LD	A,B		; get # of characters
	INC	DE
	LD	(DE),A		; save in characters read byte
	DEC	DE		; restore de
;
	POP	BC
	POP	HL
CBUFFEND:
	POP	AF
	RET

; 	END

