
; XLATE5  -  converts 8080 source code to Z80 source code  -  10/27/84
;
;
;	XLATE translates a normal 8080 source code file (.ASM type)
;	into a Z80 source code with Zilog mnemonics.  Regardless if
;	the original file had colons behind labels or not, XLATE
;	puts colons after all labels except those having EQU, MACRO
;	or SET directives.  It also writes '.Z80' and 'ASEG' lines
;	at the very beginning of the new program - thus it is ready
;	to immediately assemble for absolute addresses using the
;	Microsoft M80 assembler with L80 linking loader.
;
;
;	NOTE2:	SINCE THIS PROGRAM ONLY READS, TRANSLATES AND
;		WRITES ONE RECORD AT A TIME, THE LENGTH OF TIME
;		IT WILL TAKE TO TRANSLATE A PROGRAM MAY VARY
;		CONSIDERABLY FROM WHAT MAY BE EXPECTED, DEPENDING
;		WHERE ON THE DISK THE INPUT AND OUTPUT FILES ARE
;		LOCATED PHYSICALLY.  A 'DOT' IS PRINTED ON THE
;		CRT FOR EACH 10 LINES WITH 50 DOTS PER LINE.
;		TWO LINES OF DOTS ARE THUS 1,000 LINES OF PGM.
;		(A 1900 LINE 8080 PROGRAM TOOK EXACTLY 3 MINUTES
;		ON A FRESH DISK AND OVER 6 MINUTES ON A NEARLY
;		FULL DISK.)
;					- notes by Irv Hoff
;-----------------------------------------------------------------------
;
; 10/27/84  Rewrote the program with Intel 8080 source code rather than
;    v5     Zilog Z80 source code.  It will now assemble with ASM.COM or
;	    other 8080 assemblers (and will also run on a 8080 or 8085
;	    processor now - previously it was limited to Z80 computers.)
;					- Irv Hoff
;
; 10/17/84  Program did not remove colons from 'SET' or 'MACRO' for M80
;    v4     use.  Fixed so if label is 7 characters, does not insert an
;	    extra space.  This helps keep the output file similar to the
;	    input file.  Displays 50 dots per line; two lines represent
;	    1000 lines of program.  Wrote a new help guide.  Fixed the
;	    bug which caused all comment lines starting with an asterisk
;	    to be capitalized even though the asterisk was changed to a
;	    semicolon.	Other incidental changes.
;					- Irv Hoff
;
; 02/18/84  Made program orientated to M80, (Conditionally), for people
;    v3     like myself that use nothing but M80 for Z80 programming.
;	    If M80 EQU is set NO, the program is essentially unchanged
;	    from v2.1.1.  If M80 EQU is set YES then the following
;	    changes take place during assembly:
;
;	    A.	Colons are NOT inserted in front of Equates as they were
;		in v2.1.1.
;	    B.	A <CR> & <LF> are NOT inserted after a Label if longer
;		than 6 characters long, instead a space is inserted.
;		M80 doesn't allow a <CR> in front of an Equate.
;	    C.	Removes ':' after labels that precede EQU if present.
;		M80 will not allow them.
;	    D.	Added a few more comments.  Changed the help request to
;		a '?'.	The help instruction info appears if no source
;		file is given.
;					- Bill Albright KB9BP
;-----------------------------------------------------------------------
;
; 07/21/83  Some modest corrections	- Richard Conn
;  v2.1.1
;
; 05/03/82  Disassembled Cromenco's CDOS XLATE.COM v 2.40 and modified
;  v2.1.0   into XLATE2.		- Richard Conn
;
;-----------------------------------------------------------------------
;
;
VERS	EQU	5		;version number
MONTH	EQU	10		;date as printed on CRT
DAY	EQU	27
YEAR	EQU	84
;
;
YES	EQU	0FFH
NO	EQU	0
;
;
M80	EQU	YES		;yes=source code useable by the M80 assm.
;
;
WBOOT	EQU	0
BDOS	EQU	5
DEFFCB	EQU	5CH
FCB2	EQU	6CH
LF	EQU	0AH
TAB	EQU	09
CR	EQU	0DH
BELL	EQU	07
;
;
	ORG	100H
;
;
; Start of program
;
	CALL	HCHECK		;check for help request
	LXI	SP,OBUFLPOS	;initialize stack pointer
	CALL	INIT		;initialize the program
;
LOOP	CALL	BUILDLINE	;build the next input line
	CALL	PROCESSOPS	;convert the op codes
	JMP	LOOP
;
;
; Main processing module
;
PROCESSOPS
	CALL	GETOP		;extract the next op code
	JZ	FLUSHLINE	;if none, flush
;
	LXI	H,OCS1		;process op code set 1
	LXI	B,10		;10 characters/dual entry
				;  (old op = 5, new op = 5)
	CALL	CMPOP		;scan for match in INLN buffer
	JZ	DOOCS1		;process if found
;
	LXI	H,OCS2		;process op code set 2
	LXI	B,10		;10 characters/dual entry
	CALL	CMPOP		;scan for match
	JZ	DOOCS2		;process
;
	LXI	H,OCS3		;process op code set 3
	LXI	B,10		;10 characters/dual entry
	CALL	CMPOP		;scan for match
	JZ	DOOCS3		;process
;
	LXI	H,OCS4		;process (extended ret) op code set 4
	LXI	B,5		;5 characters/single entry
	CALL	CMPOP		;scan for match
	CZ	DOOCS4		;convert into standard return forms if match
;
	LXI	H,RETS		;process (normal ret) op code set 5
	LXI	B,5		;5 characters/single entry
	CALL	CMPOP		;scan for match
	JZ	DORETS		;process
;
	LXI	H,CALLS		;process (call) op code set 6
	LXI	B,5		;5 characters/single entry
	CALL	CMPOP		;scan for match
	JZ	DOCALLS		;process
;
	LXI	H,JMPS		;process (jmp) op code set 7
	LXI	B,5		;5 characters/single entry
	CALL	CMPOP		;scan for match
	JZ	DOJMPS		;process
;
	LXI	H,OCS8		;process op code set 8
	LXI	B,12		;12 characters/dual entry
	CALL	CMPOP		;scan for match
	JZ	DOOCS8		;process
;
; No match in op code sets -- pass target op code as is
;
	MVI	B,5		;5 characters in target
	LXI	H,TARGOP	;point to target
;
POPS1	MOV	A,M		;get character
	CPI	' '		;end of op?
	JZ	POPS2		;output tab character if so
	CPI	TAB		;end of op?
	JZ	POPS2		;output tab character if so
	CALL	DOUTCHAR	;output op character
	INX	H		;point to next
	DCR	B		;one less to go
	JNZ	POPS1		;continue for 5 characters maximum
;
POPS2	MVI	A,TAB		;end op with <tab>
	CALL	DOUTCHAR	;output to disk
;
;
; Copy rest of input line as-is
;
COPYARGS
	LHLD	INLNPTR		;point to next character
;
CARGS1	MVI	C,0
;
CARGS2	MOV	A,M		;get character
	CPI	' '		;end of operands?
	JZ	CARGS4		;skip white space and output rest if so
	CPI	TAB		;end of operands?
	JZ	CARGS4		;skip white space and output rest if so
	CPI	CR		;end of line?
	JZ	FLUSHLINE	;flush if so
	CPI	';'		;beginning of comment = end of operands?
	JZ	CARGS5		;copy rest if so
	CPI	27H		;single quote?
	JNZ	CARGS3
	DCR	C
	JZ	CARGS3
	MVI	C,1
;
CARGS3	CALL	DOUTCHAR	;output character in a to disk
	INX	H		;point to next
	JMP	CARGS2
;
CARGS4	PUSH	H
	CALL	SKIPWHITE	;skip to next non-white character
	POP	H
	CPI	CR		;end of line?
	JZ	FLUSHLINE	;flush if so
	CPI	';'		;comment?
	JZ	CARGS5		;process comment if so
	CALL	OUTWHITE	;output a tab
	JMP	CARGS2		;restart processing
;
CARGS5	DCR	C
	INR	C
	JNZ	CARGS3
	CALL	SKIPWHITE
	MVI	B,41
;
CARGS6	LDA	OBUFLPOS	;check position in output line
	CMP	B
	JNC	FLUSHLINE
	DCR	A		;back up in output line
	ANI	0F8H		;artifically tab
	ADI	TAB
	CMP	B
	JZ	FLUSHLINE
	JC	CARGS7
	MVI	A,' '
	JMP	CARGS8
;
CARGS7	MVI	A,TAB
;
CARGS8	CALL	DOUTCHAR
	JMP	CARGS6
;.....
;
;
; Write rest of 'INLN' to disk
;
FLUSHLINE
	CALL	OUTSTR
	MVI	A,1		;reset position counter
	STA	OBUFLPOS
	RET
;.....
;
;
; Print PDOT for each ten lines
;
PDOT	LDA	LCOUNT		;get line count
	DCR	A		;count down
	STA	LCOUNT		;put line count
	RNZ			;done if not zero
	MVI	A,'.'		;print PDOT
	CALL	PCHAR
	MVI	A,10		;reset count
	STA	LCOUNT
	LDA	NLCOUNT		;new line?
	DCR	A
	STA	NLCOUNT
	RNZ
	LXI	D,CRLFSTR	;print new line
	CALL	PMSG
	MVI	A,50		;reset counter
	STA	NLCOUNT
	RET
;.....
;
;
; Output string pointed to by HL to disk (string ends in 0)
;
OUTSTR	MOV	A,M		;get character
	ANA	A		;done?
	RZ			;return if so
	CALL	DOUTCHAR
	INX	H		;point to next character
	JMP	OUTSTR
;
;
; Output all <sp> and <tab> characters found until a non-<sp> and
;  non-<tab> encountered
;
OUTWHITE
	MOV	A,M		;get character
	CPI	' '		;<sp>?
	JZ	OW1		;output it
	CPI	TAB		;<tab>?
	RNZ			;done if not
;
OW1	CALL	DOUTCHAR	;output character in 'A' to disk
	INX	H		;point to next character
	JMP	OUTWHITE	;continue
;
;
; Extract op code for input line and place in buffer
;
GETOP	LXI	H,INLN		;point to input line
	MOV	A,M		;get 1st character in line
	CPI	' '		;no label?
	JZ	GOP3		;skip to op code
	CPI	TAB		;no label?
	JZ	GOP3		;skip to op code
	CPI	';'		;comment?
	RZ			;done if so
;
;
; Line begins with a label -- process it
;
GOP1	MVI	C,0		;set label character count
;
GOP2	MOV	A,M		;get next character of label
	CPI	':'		;end of label?
	JZ	GOP4
	CPI	TAB		;end of label?
	JZ	GOP5
	CPI	CR		;end of label and no further processing?
	JZ	GOP5
	CPI	';'		;end of label and no further processing?
	JZ	GOP5
	CPI	' '		;end of label?
	JZ	GOP5
	CALL	DOUTCHAR	;output label character to disk
	INX	H		;point to next character
	INR	C		;increment label character count
	JMP	GOP2
;
;
; No label -- skip to op code, but check for a label with a leading
; space or a tab
;
GOP3	CALL	SKIPWHITE	;skip over white space
	PUSH	H		;save current .ASM ->
	CALL	FTODLM		;find a delimiter
	CPI	':'		;is a label ?
	POP	H		;restore .ASM ->
	JZ	GOP1		;go if a label was found
	JMP	GOP7		;else continue on
;
;
; End of label by ':' character
;
GOP4	 IF	M80		;space for a colon in front of EQU
	CALL	CHKEQU		;EQU follows after any spaces or tabs?
	JZ	GOP4A
	CALL	CHKMACRO	;MACRO follows after any spaces or tabs?
	JZ	GOP4A
	CALL	CHKSET		;SET follows after any spaces or tabs?
	JNZ	GOP4B		;no so write the colon
;
GOP4A	MVI	A,' '		;replace ':' with ' '
	CALL	DOUTCHAR	;in buffer
	INX	H		;-> next .ASM character
	RET			;copy rest of equate line as-is, Z-flag is set
;...

GOP4B	MVI	A,':'		;restore ':'
	 ENDIF			;M80

	INX	H		;skip ':' - next address in input line
;
	CALL	DOUTCHAR	;output the ':'
	MOV	A,M		;check for EOL
	CPI	CR		;do not double new line (skip new line after gop6)
	JZ	GOP8		;just continue processing with no tab
	JMP	GOP6		;not new line, so process for new line if long label
;
;
; Output ':' at end of label
;
GOP5	 IF	M80		;check for EQU after label and spaces/tabs
	CALL	CHKEQU
	JZ	GOP55
	CALL	CHKMACRO
	JZ	GOP55
	CALL	CHKSET
	JNZ	GOP58		;do not add colon if EQU follows
;
GOP55	MOV	A,C
	CPI	7
	JC	GOP7
	MVI	A,' '		;insert a space if > 7
	CALL	DOUTCHAR
	JMP	GOP8		;bypass the tab insertion
	 ENDIF			;M80
;
GOP58	MVI	A,':'		;output the ':'
	CALL	DOUTCHAR
;
;
; See if label is less than 7 characters long - if <7, then terminate
; with <tab>; if >6, then new line and <tab>, but if  M80  EQU	YES,
; add a space instead of a CR,LF.
;
GOP6	MOV	A,C		;get label character count
	CPI	7		;less than 7?
	JC	GOP7		;tab if less than 7
	JZ	GOP8
;
	 IF	M80
	MVI	A,' '		;insert a space if > 7
	CALL	DOUTCHAR
	JMP	GOP8		;bypass the tab insertion
	 ENDIF			;M80
;
	 IF	NOT M80		;CR,LF and tab if 'NOT M80'
	MVI	A,CR		;<CR>
	CALL	DOUTCHAR
	MVI	A,LF		;<LF>
	CALL	DOUTCHAR
	 ENDIF			;NOT M80
;
;
; Output <tab> after label to disk
;
GOP7	MVI	A,TAB		;<TAB>
	CALL	DOUTCHAR
;
;
; Skip to op code field and extract it if present
;
GOP8	CALL	SKIPWHITE	;skip to op code field
	MOV	A,M		;get first non-white character
	CPI	';'		;no op code if comment
	RZ			;done if comment
	CPI	CR		;no op code if eol
	RZ			;done if EOL
;
	SHLD	ILTOP		;save pointer to target op code
	MVI	B,5		;5 characters maximum in op code
	LXI	D,TARGOP	;copy to targop buffer
	CALL	COPYTODELIM	;copy until delimiter encountered
	CALL	SKIPWHITE	;skip over white space which follows
	SHLD	INLNPTR		;save pointer
	SUB	A
	INR	A		;Z-flag not set
	RET
;.....
;
;
;..IF M80: Z-flag set upon return if 'EQU' is the next .ASM word
;
	 IF	M80
CHKEQU	PUSH	H		;save .ASM text ->
	INX	H		;-> next .ASM character
	CALL	SKIPWHITE	;skip spaces & tabs for 'EQU' compare, -> next
	MOV	A,M		;character and fetch it
	CPI	'E'		;=E ?
	JNZ	NOTMACRO	;return if not
	INX	H		;-> 2nd character
	MOV	A,M
	CPI	'Q'		;=Q ?
	JNZ	NOTMACRO	;return if not
	INX	H
	MOV	A,M
	CPI	'U'		;=U ?
	POP	H		;restore .ASM text ->
	RET			;return with Z-flag set if an equate
;...
;
;
NOTEQU	POP	H		;restore .ASM text ->
	RET			;return with Z-flag not set
	 ENDIF			;M80
;.....
;
;
;..IF M80: Z-flag set upon return if 'MACRO' is the next .ASM word
;
	 IF	M80
CHKMACRO
	PUSH	H		;save .ASM text ->
	INX	H		;-> next .ASM char.
	CALL	SKIPWHITE	;skip spaces & tabs for 'MACRO' compare, -> next
	MOV	A,M		;character and fetch it
	CPI	'M'		;=M ?
	JNZ	NOTMACRO	;return if not
	INX	H		;-> 2nd char.
	MOV	A,M
	CPI	'A'		;=A ?
	JNZ	NOTMACRO	;return if not
	INX	H
	MOV	A,M
	CPI	'C'		;=C ?
	JNZ	NOTMACRO	;return if not
	INX	H
	MOV	A,M
	CPI	'R'		;=R ?
	JNZ	NOTMACRO
	INX	H
	MOV	A,M
	CPI	'O'		;=O ?
	POP	H		;restore .ASM text ->
	RET			;return with Z-flag set if an equate
;...
;
;
NOTMACRO
	POP	H		;restore .ASM text ->
	RET			;return with Z-flag not set
	 ENDIF			;M80
;.....
;
;
;..IF M80: Z-flag set upon return if 'SET' is the next .ASM word
;
	 IF	M80
CHKSET	PUSH	H		;save .ASM text ->
	INX	H		;-> next .ASM char.
	CALL	SKIPWHITE	;skip spaces & tabs for 'SET' compare, -> next
	MOV	A,M		;character and fetch it
	CPI	'S'		;=S ?
	JNZ	NOTMACRO	;return if not
	INX	H		;-> 2nd character
	MOV	A,M
	CPI	'E'		;=E ?
	JNZ	NOTMACRO	;return if not
	INX	H
	MOV	A,M
	CPI	'T'		;=T ?
	POP	H		;restore .ASM text ->
	RET			;return with Z-flag set if an equate
;.....
;
;
NOTSET	POP	H		;restore .ASM text ->
	RET			;return with Z-flag not set
	 ENDIF			;M80
;.....
;
;
; Compare op code pointed to by HL with target op code; return with the
; Z-flag set if a match was found, NZ if no match.
;
CMPOP	MOV	A,M		;no op code to compare?
	ANA	A		;a=0 if so
	JZ	CMPOP1		;failure if so
	PUSH	B
	MVI	B,5		;compare 5 bytes
	LXI	D,TARGOP	;point to target op code
	CALL	COMPHLDE	;compare
	POP	B
	RZ			;done if match
	DAD	B		;point to next op code in table
	JMP	CMPOP
;
CMPOP1	INR	A		;A=1 and NZ
	RET
;.....
;
;
; Process op codes in set 1 -- operand and comments fields are unchanged.
; HL points to op code table entry, 2nd element of which is to be output
; to disk.
;
DOOCS1	CALL	OUTNEWOP5CH	;output new op code
	JMP	COPYARGS	;copy operand and comment fields as-is
;
;
; Output second 5-character-maximum op code field pointed to by HL to
; disk and end in <tab>.
;
OUTNEWOP5CH
	LXI	B,5		;skip first 5 characters
	DAD	B		;point to second 5-character field
;
;
; Entry point to copy 5-character-maximum field pointed to by HL
;
ONO5C0	MVI	B,5
;
ONO5C1	MOV	A,M		;get the character
	CPI	' '		;<sp>?
	JZ	ONO5C2		;done if so
	CPI	TAB		;<tab>?
	JZ	ONO5C2		;done if so
	CALL	DOUTCHAR	;output character to disk
	INX	H		;point to next
	DCR	B		;one less to go
	JNZ	ONO5C1		;count down
;
ONO5C2	MVI	A,TAB		;output <tab> to disk
	JMP	DOUTCHAR	;output to disk
;
;
; Process op codes in set 2 - operand is 1 register or '(HL)' - HL points
; to op code table entry, 2nd element of which is to be output to disk
;
DOOCS2	CALL	OUTNEWOP5CH	;output new 5-character-maximum op code
	LHLD	INLNPTR		;point to operand field
;
ATHLCHECK
	MOV	A,M		;check for '(HL)' reference
	CPI	'M'		;takes the form of 'M' in 8080 mnemonics
	JNZ	CARGS1		;output normally if not
	INX	H		;point to character after
	PUSH	H		;save pointer
	LXI	H,ATHL		;output '(HL)'
	CALL	OUTSTR		;output to disk
	POP	H		;get pointer
	JMP	CARGS1		;process rest of line normally
;
ATHL	DB	'(HL)',0
;
;
; Pprocess op codes in set 3 - operand is BC, DE, HL, or PSW register
; pair.  HL points to op code table entry, 2nd element of which is to
; be output to disk
;
DOOCS3	CALL	OUTNEWOP5CH	;output new op code
;
RPCHECK	LHLD	INLNPTR		;point to operand field
	PUSH	H		;save pointer
	MOV	A,M		;get operand
	CPI	'B'		;for BC?
	JZ	PRBC		;output BC if so
	CPI	'D'		;for DE?
	JZ	PRDE		;output DE if so
	CPI	'H'		;for HL?
	JZ	PRHL		;output HL if so
	CPI	'P'		;for PSW?
	JNZ	L0309		;output whatever is there if not
	INX	H		;make sure it is 'PSW'
	MOV	A,M
	CPI	'S'
	JNZ	L0309		;output whatever is there if not
	INX	H
	MOV	A,M
	CPI	'W'
	JNZ	L0309		;output what ever is there if not
	POP	H		;it is 'PSW', so clear stack and point
	INX	H		;  to character after 'PSW'
	INX	H
	PUSH	H
	LXI	H,AFSTR		;print 'AF'
	JMP	PRREGPAIR	;do print
;
PRBC	LXI	H,BCSTR		;print 'BC'
	JMP	PRREGPAIR
;
PRDE	LXI	H,DESTR		;print 'DE'
	JMP	PRREGPAIR
;
PRHL	LXI	H,HLSTR		;print 'HL'
;
PRREGPAIR
	CALL	OUTSTR		;print string pointed to by HL and make HL on stack
	POP	H		;point to next character
	INX	H
	PUSH	H
;
L0309	POP	H		;print whatever other operand it is
	JMP	CARGS1		;print the operand
;
AFSTR	DB	'AF',0
BCSTR	DB	'BC',0
DESTR	DB	'DE',0
HLSTR	DB	'HL',0
;
;
; Process op code set 4 - EQ, NE, LT, GE, RET, CALL, and JMP.  HL points
; to op code table entry, 2nd element of which is to be output to disk.
;
DOOCS4	LDA	TARGOP+1	;look at second letter of target op
	LXI	H,ZFLG		;prepare for zero
	CPI	'E'		;if 'E', then form is 'EQ'
	JZ	ZCPUT		;change form to 'XZ ', where X=R,C,J
	LXI	H,NZFLG		;prepare for not zero
	CPI	'N'		;if 'N', then form is 'NE'
	JZ	ZCPUT
	LXI	H,CFLG		;prepare for carry
	CPI	'L'		;if 'L', then form is 'LT'
	JZ	ZCPUT
	LXI	H,NCFLG		;form must be 'GE', so no carry
;
ZCPUT	MOV	A,M		;get first character
	STA	TARGOP+1	;store it
	INX	H		;point to second character
	MOV	A,M		;get it
	STA	TARGOP+2	;store it
	RET
;...
;
;
ZFLG	DB	'Z '
NZFLG	DB	'NZ'
CFLG	DB	'C '
NCFLG	DB	'NC'
;.....
;
;
; Process op code set 5 -- return forms.  HL points to op code table
; entry, 2nd element of which is to be output to disk.
;
DORETS	LXI	H,RETSTR	;point to string to copy
	CALL	COPY5		;copy with optional cond
	JMP	COPYARGS	;copy rest of operand field and comments as-is

;
RETSTR	DB	'RET  ',0
;
DOCALLS	LXI	H,CALLSTR
	JMP	CP5WITHCOMMA	;copy and follow with comma
;
CALLSTR		DB	'CALL ',0
;
DOJMPS	LXI	H,JPSTR		;fall through
;
;
; Copy string at HL followed by condition code, a comma, and rest of the
; operand field
;
CP5WITHCOMMA
	CALL	COPY5
	MVI	A,','
	CALL	DOUTCHAR	;output comma to disk
	JMP	COPYARGS	;copy rest of operand field
;
JPSTR	DB	'JP   ',0
;
;
; Copy 5-character-maximum string pointed to by HL followed by <tab> and
; 2-character conditional.
;
COPY5	CALL	ONO5C0		;copy 5-character-maximum string pointed to by HL
	LDA	TARGOP+1	;output first character of conditional
	CALL	DOUTCHAR
	LDA	TARGOP+2	;output 2nd character of conditional if not <sp>
	CPI	' '
	RZ
	JMP	DOUTCHAR
;
;
; Process op code set 8 - this table contains the service routine address
; embedded in it after each op code pair; HL points to op code table
; entry, 2nd element of which is to be output to disk.
;
DOOCS8	PUSH	H		;save pointer to old (1st) op
	LXI	B,10		;point to address of service routine
	DAD	B
	MOV	C,M		;BC=routine address
	INX	H
	MOV	B,M
	POP	H		;point to old (1st) op
	PUSH	B		;routine address on stack
	RET			;jump to routine
;.....
;
;
; This converts 'DAD <RP>' to 'ADD HL,<RP>'
;
DO81	CALL	OUTNEWOP5CH	;output 'ADD<TAB>'
	LXI	H,DO81S		;output 'HL,'
	CALL	OUTSTR
	JMP	RPCHECK		;output <register pair>
;
DO81S	DB	'HL,',0
;
;
; This converts 'ADD R' to 'ADD A,R'
;    and 'ADC R' to 'ADC A,R'
;    and 'SBC R' to 'SBC A,R'
;
DO82	CALL	OUTNEWOP5CH	;output the 'IN<TAB>'
	LXI	H,DO82S		;output 'A,'
	JMP	DO8F1		;04C7H
;
DO82S	DB	'A,',0
;
;
; This converts 'LDA <ADR>' to 'LD A,(<ADR>)'
;    and 'IN <ADR>' to 'IN A,(<ADR>)'
;
DO83	CALL	OUTNEWOP5CH
	LXI	H,DO83S
	JMP	OUTCLP
;
DO83S	DB	'A,(',0
;
;
; This converts 'LDAX <RP>' to 'LD A,(<RP>)'
;
DO84	CALL	OUTNEWOP5CH	;output op code
	LHLD	INLNPTR		;point to operand
	MOV	A,M		;get 1st character of operand
	CPI	'B'		;bc reg pair?
	JZ	DO841		;process it
	CPI	'D'		;DE register pair?
	JZ	DO842		;process it
	JMP	CARGS1		;something funny -- process normally
;
DO841	LXI	H,DO841S
	JMP	DO8D3
;
DO842	LXI	H,DO842S
	JMP	DO8D3
;
DO841S	DB	'A,(BC)',0
DO842S	DB	'A,(DE)',0
;
;
; This converts 'LHLD <ADR>' to 'LD HL,(<ADR>)'
;
DO85	CALL	OUTNEWOP5CH
	LXI	H,DO85S
;
;
; This outputs the string pointed to by HL, outputs the rest of the
; operand field, outputs a closing ')', and outputs the rest of the
; input line
;
OUTCLP	CALL	OUTSTR		;01F9H
	CALL	OUTOPER		;04D5H
	MVI	A,')'		;29H
	CALL	DOUTCHAR	;0631H
	JMP	CARGS1		;0198H
;
DO85S	DB	'HL,(',0
;
;
; This converts 'MOV R,R' to 'LD R,R'
;
DO86	CALL	OUTNEWOP5CH
	LHLD	INLNPTR		;point to 1st character of operand field
	MOV	A,M		;get it
	CPI	'M'		;convert 'M' to '(HL)'?
	JNZ	DO862		;no conversion necessary
	PUSH	H
	LXI	H,ATHL		;output '(HL)'
	CALL	OUTSTR
	POP	H
;
;
; Output ',' followed by '(HL)' or 'R'
;
DO861	INX	H		;output comma and then 2nd 'R'
	MOV	A,M		;get comma
	CALL	DOUTCHAR
	INX	H		;point to 2nd 'R'
	JMP	ATHLCHECK	;output '(HL)' or 'R'
;
;
; Output 'R,' followed by '(HL)' or 'R'
;
DO862	CALL	DOUTCHAR	;output 'R'
	JMP	DO861		;output rest
;
;
; This converts 'PCHL' to 'JP<TAB>(HL)'
;
DO88	CALL	OUTNEWOP5CH
	LXI	H,ATHL		;output the '(HL)'
	JMP	DO8F1
;
;
; This converts 'RST N' to 'RST NNH'
;
DO89	CALL	OUTNEWOP5CH
	LXI	H,DO89S
	JMP	DO8F1
;
DO89S	DB	'8*',0		;multiply restart number by 8 for Z80
;
;
; This converts 'SHLD <ADR>' to 'LD (<ADR>),HL'
;
DO8A	CALL	OUTNEWOP5CH
	MVI	A,'('		;output opening '('
	CALL	DOUTCHAR
	CALL	OUTOPER		;output operand
	PUSH	H
	LXI	H,DO8AS		;output '),HL'
	JMP	DO8C2
;
DO8AS	DB	'),HL',0
;
;
; This converts 'SPHL' to 'LD SP,HL'
;
DO8B	CALL	OUTNEWOP5CH
	LXI	H,DO8BS
	JMP	DO8F1
;
DO8BS	DB	'SP,HL',0
;
;
; This converts 'STA <ADR>' to 'LD (<ADR>),A'
;    and 'OUT <ADR>' to 'OUT (<ADR>),A'
;
DO8C	CALL	OUTNEWOP5CH
	MVI	A,'('		;output '('
;
;
; This outputs '<OPERAND>),A'
;
DO8C1	CALL	DOUTCHAR	;output character in a
	CALL	OUTOPER		;output operand field
	PUSH	H
	LXI	H,DO8CS		;output '),A'
;
DO8C2	CALL	OUTSTR		;output string pointed to by HL
	POP	H		;clear stack
	JMP	CARGS1		;output rest of input line
;
DO8CS	DB	'),A',0
;
;
; This converts 'STAX <RP>' to 'LD (<RP>),A'
;
DO8D	CALL	OUTNEWOP5CH
	LHLD	INLNPTR		;point to 1st character of operand
	MOV	A,M		;get it
	CPI	'B'		;'BC' register pair?
	JZ	DO8D1		;output it if so
	CPI	'D'		;'DE' register pair?
	JZ	DO8D2		;output it if so
	JMP	CARGS1		;else, output whatever is there
;
DO8D1	LXI	H,DO8D1S
	JMP	DO8D3
;
DO8D2	LXI	H,DO8D2S
;
DO8D3	CALL	OUTSTR
	LHLD	INLNPTR		;point to after 'B' or 'D'
	INX	H
	JMP	CARGS1
;
DO8D1S	DB	'(BC),A',0
DO8D2S	DB	'(DE),A',0
;.....
;
;
; This converts 'XCHG' to 'EX DE,HL'
;
DO8E	CALL	OUTNEWOP5CH
	LXI	H,DO8ES
	JMP	DO8F1
;
DO8ES	DB	'DE,HL',0
;.....
;
;
; This converts 'XTHL' to 'EX (SP),HL'
;
DO8F	CALL	OUTNEWOP5CH
	LXI	H,DO8FS
;
DO8F1	CALL	OUTSTR		;01F9H
	JMP	COPYARGS	;0195H
;
DO8FS	DB	'(SP),HL',0
;.....
;
;
; Oxtput rest of operand field up to white space before ending comment
; or end of line.
;
OUTOPER	LHLD	INLNPTR		;point to next character in input line buffer
;
OOL1	MOV	A,M		;get next character
	CPI	';'		;beginning of comment?
	JZ	OOL2		;check for rest of operand
	CPI	CR		;end of line?
	JZ	OOL2		;check for rest of operand
	INX	H		;continue until either comment or EOL found
	JMP	OOL1
;
OOL2	DCX	H		;back up (over white space?)
	MOV	A,M		;get character
	CPI	' '		;white?
	JZ	OOL2		;continue backing
	CPI	TAB		;white?
	JZ	OOL2		;continue backing
	INX	H		;point to first white character
	XCHG			;save pointer in 'DE'
	LHLD	INLNPTR		;point to start of scan
;
OOL3	MOV	A,D		;all of operand field flushed?
	CMP	H		;check for pointer match
	JNZ	OOL4		;check for ponter match
	MOV	A,E		;rest of match?
	CMP	L
	RZ			;done if all match
;
OOL4	MOV	A,M		;output operand character to disk
	CALL	DOUTCHAR
	INX	H		;pint to next operand character
	JMP	OOL3		;continue until operand all out
;
;
; The following turns on various messages for manual translation
;
DO91	MVI	A,TAB		;ENDIFs
	STA	XLT1ON		;store <tab> to enable
	JMP	DO941
;
DO92	MVI	A,TAB		;includes
	STA	XLT2ON
	JMP	DO941
;
DO93	MVI	A,TAB		;lists
	STA	XLT3ON
	JMP	DO941
;
DO94	MVI	A,TAB		;MACROS
	STA	XLT4ON
;
DO941	CALL	OUTNEWOP5CH	;output new code
	MVI	A,CR		;turn on printed error message
	STA	ERR5ON		;turn on flag by starting with <cr>
	JMP	COPYARGS	;copy rest of code
;
;
; The following checks for the specification of a help option and prints
; the help message if so
;
HCHECK	LDA	DEFFCB+1	;get first character of file name
	CPI	'?'		;option?
	RNZ			;no help requested if not option
	LXI	D,HMSG1		;print help message
	CALL	PMSG
	POP	H		;remove 'CALL HCHECK' from stack
	RET			;return to original CP/M stack
;.....
;
;
; The following initializes the program for execution
;
INIT	LXI	D,HEADER	;print program banner
	CALL	PMSG
	MVI	A,10		;initialize PDOT print (line) count
	STA	LCOUNT
	MVI	A,50		;initialize new line print count
	STA	NLCOUNT
	MVI	A,1		;initialize output buffer line position
	STA	OBUFLPOS
	CALL	MAKEFNS		;set up file names
	CALL	OPENIN		;open input file
	CALL	OPENOUT		;open output file
	LXI	H,FHDR		;output '.Z80' and 'ASEG' to .MAC file
;
INIT1	MOV	A,M		;get character
	ORA	A		;done?
	JZ	INIT2
	CALL	DOUTCHAR	;output to disk
	INX	H		;point to next
	JMP	INIT1
;
INIT2	LDA	FCB2+1		;2nd file name present?
	CPI	' '		;<sp> if not
	RNZ			;done if so
	XRA	A		;a=0
	STA	OCS4		;turn off weird op code scan (req, etc)
	STA	NOXLT		;turn off scan for ENT, NAME, RAM, ROG
	STA	NOXLT2		;turn off scan for IFC, ICL, MAC, LST
	RET
;.....
;
;
; Set up file names
;
MAKEFNS	LXI	H,DEFFCB	;copy input file name from command
	LXI	D,FCBASM	;into this FCB for use
	MVI	B,9		;9 bytes
	CALL	MOVE		;copy
	MOV	A,M		;file type specified?
	CPI	' '		;none if <sp>
	JZ	MFN1
	MVI	B,3		;3 more bytes
	CALL	MOVE		;copy
;
MFN1	LXI	H,FCB2+1	;2nd file specified?
	MOV	A,M		;get first byte of file name
	DCX	H		;point to first byte of fcb
	CPI	' '		;no second file name?
	JNZ	MFN2		;skip reload of HL if there is a 2nd file name
	LXI	H,DEFFCB	;copy file name into output FCB
;
MFN2	LXI	D,FCBZ80	;output FCB
	MVI	B,9		;9 bytes
	CALL	MOVE		;copy
	LXI	H,FCB2+9	;point to file type
	MOV	A,M		;check for a file type
	CPI	' '		;none if <sp>
	JZ	MFN3
	MVI	B,3		;there is one, so copy it over
	CALL	MOVE		;copy
;
MFN3	LXI	D,PRFNM1	;print part 1 of file name message
	CALL	PMSG
	LXI	H,FCBASM	;print name of source file
	CALL	PRFNAME
	LXI	D,PRFNM2	;print part 2 of file name message
	CALL	PMSG
	LXI	H,FCBZ80	;print name of destination file
	CALL	PRFNAME
	LXI	D,CRLFSTR	;end line
	CALL	PMSG
	RET
;.....
;
;
; Print file name message
;
PRFNAME	MOV	A,M		;get disk number
	ADI	'@'		;add in ASCII bias
	CALL	PCHAR
	MVI	A,':'		;print colon
	CALL	PCHAR
	INX	H		;point to first character of file name
	MVI	B,8		;8 characters
	CALL	PRFNC
	MVI	A,'.'		;dot
	CALL	PCHAR
	MVI	B,3		;3 characters
	CALL	PRFNC
	RET
;...
;
;
PRFNC	MOV	A,M		;get next character
	INX	H		;point to next
	CALL	PCHAR		;print character
	DCR	B		;one less to go
	JNZ	PRFNC
	RET
;.....
;
;
; Open input file for processing
;
OPENIN	LXI	D,FCBASM	;open file for input
	MVI	C,0FH
	CALL	BDOS
	CPI	0FFH		;error?
	JZ	OIERR		;abort with error message if so
	MVI	A,80H		;initialize character count for buffer
	STA	IBUFCNT
	RET
;...
;
OIERR	LXI	D,ERR2		;input file error message
	JMP	ENDERR		;abort
;.....
;
;
; Open file for output
;
OPENOUT	LXI	D,FCBZ80	;open output file
	MVI	C,0FH
	CALL	BDOS
	CPI	0FFH		;error?
	JNZ	OOERR2		;abort if no error (overwrite old file)
;
OPENO1	LXI	D,FCBZ80	;else create output file
	MVI	C,16H
	CALL	BDOS
	CPI	0FFH		;error?
	JZ	OOERR1
	LXI	D,FCBZ80	;now open output file (redundant with make)
	MVI	C,0FH
	CALL	BDOS
	MVI	A,80H		;initialize count of bytes remaining
	STA	OBUFBACKCNT	;set count
	LXI	H,OBUF		;initialize address of next byte
	SHLD	OBUFPTR		;set pointer
	RET
;...
;
;
OOERR1	LXI	D,ERR3		;disk full
	JMP	ENDERR		;abort error
;
OOERR2	LXI	D,ERR4		;attempt to overwrite existing file
	CALL	PMSG
	MVI	C,1		;get response
	CALL	BDOS
	CALL	CAPS		;capitalize
	CPI	'Y'		;continue if yes
	LXI	D,ERR4A		;prep for abort
	JNZ	ENDERR		;abort error
	LXI	D,CRLFSTR	;new line
	CALL	PMSG
	LXI	D,FCBZ80	;delete old file
	MVI	C,19		;BDOS delete file
	CALL	BDOS
	JMP	OPENO1		;create new file and continue
;.....
;
;
; Check to see if character pointed to by HL is a delimiter and flush
; characters until it is; return with zero flag set when done.q
;
FTODLM	PUSH	B		;flush to delimiter
	CALL	DLIMSCAN	;do scan
	POP	B
	RZ			;match, so abort
	INX	H		;point to next character
	JMP	FTODLM		;continue scan
;
;
; Copy (HL) to (DE) for (B) bytes or until a delimiter is encountered
;
COPYTODELIM
	MOV	C,B		;let BC=old B (for LDI instruction)
	MVI	B,0
	PUSH	B		;save registers
	PUSH	D
	PUSH	H
	CALL	SPFILL		;fill destination buffer with spaces (pointed to by de)
	POP	H		; ... and 'C' bytes long
	POP	D
	POP	B
;
CTD1	PUSH	B		;save count
	CALL	DLIMSCAN	;scan for delimiter if encountered
	POP	B		;get the count back
	RZ			;done if a delimiter was found now
;
	MOV	A,M		;otherwise get the character and
	STAX	D		;  store it then increment for the
	INX	D		;  next position
	INX	H
	DCR	C		;one less to go
	JNZ	CTD1		;if not finished, check for next
	JMP	DLIMSCAN	;one last try if count is zero now
;
;
; Advance buffer pointer HL until non-white (non-<sp>, non-<tab>)
; encountered
;
SKIPWHITE
	MOV	A,M		;get character
	CPI	' '		;<sp>?
	JZ	SKPWH1		;skip if so
	CPI	TAB		;<tab>?
	RNZ			;done if not
;
SKPWH1	INX	H		;point to next character
	JMP	SKIPWHITE
;
;
; Check to see if character pointed to by HL is a delimiter
;
DLIMSCAN
	PUSH	D
	XCHG			;point to character with 'DE'
	LXI	H,DLIMS		;point to table of delimiters
	CALL	DELIMCHS	;do scan in general
	XCHG			;point to character with 'HL'
	MOV	A,M		;get character in 'A'
	POP	D
	RET
;...
;
;
; Table of valid delimiters
;
DLIMS	DB	1,1		;scan 1 byte at a time, and skip 1 byte if no match
	DB	','		;delimiters ...
	DB	':'
	DB	'+'
	DB	'-'
	DB	'/'
	DB	'*'
	DB	' '
	DB	')'
	DB	';'
	DB	CR
	DB	TAB		; ... to here
	DB	0		;end of table
;
;
; Scan for delimiter -- return with nz if not found or point to the
; delimiter with Z if found; on input, table pointed to by HL with the
; first two bytes giving number of bytes to check and number of bytes
; to skip, respectively, on each partial scan.
;
DELIMCHS
	CALL	SPCHSCAN	;do scan of table
	RNZ			;not found
	MOV	C,B		;character offset count in 'BC'
	MVI	B,0
	DAD	B		;point to character
	SUB	A		;set zero flag
	RET
;.....
;
;
; Scan special character table pointed to by HL for string pointed
; to by 'DE'; number of significant bytes to scan as first entry in the
; table, number of bytes to skip on failure as second entry in table;
; table ends in a binary 0.
;
SPCHSCAN
	MOV	B,M		;b=number of bytes to scan
	INX	H
	MOV	C,M		;'C'=number of bytes to skip on failure
	INX	H		;point to first valid byte in table
;
;
; Main scanning loop
;
SPCH1	MOV	A,M		;check for end of table
	ANA	A		;zero?
	JZ	SPCH2		;done if so
	CALL	COMPHLDE	;do compare
	RZ			;return if match
	MOV	A,C		;point to next table entry
	CALL	ADDHLA		;HL=HL+(size of table entry)
	JMP	SPCH1
;
;
; No match -- return NZ
;
SPCH2	INR	A		;A=1 and NZ
	RET
;.....
;
;
; Compare characters pointed to by 'DE' with that pointed to by 'HL' for
; 'B' bytes and return with Z-flag set if complete match, NZ if no match;
; HL, DE, BC not affected
;
COMPHLDE
	PUSH	H		;save registers
	PUSH	D
	PUSH	B
;
CMPHD1	LDAX	D		;get 'DE' character
	CMP	M		;compare to 'HL' character
	JNZ	CMPHD2		;no match
	INX	H		;point to next
	INX	D
	DCR	B		;one less to go
	JNZ	CMPHD1		;count down -- zero flag set on end
;
CMPHD2	POP	B		;restore registers
	POP	D
	POP	H
	RET
;.....
;
;
;  HL=HL+A
;
ADDHLA	ADD	L		;do it
	MOV	L,A
	RNC
	INX	H
	RET
;.....
;
;
; Move 'B' characters from 'HL' to 'DE'
;
MOVE	MOV	A,M
	STAX	D
	INX	D
	INX	H
	DCR	B
	JNZ	MOVE
	RET
;.....
;
;
; Fill memory pointed to by DE with spaces for BD bytes
;
SPFILL	MVI	A,' '		;<sp>
	STAX	D		;store first <sp>
	INX	D		;DE points to next byte
	DCR	C		;one less to go
	JNZ	SPFILL		;copy
	RET
;.....
;
;
; Output character in 'A' to disk file
;
DOUTCHAR
	PUSH	H		;save registers
	PUSH	D
	PUSH	B
	PUSH	PSW
	LHLD	OBUFPTR		;get address of next character position in out buffer
	MOV	M,A		;store character into out buffer
	CPI	TAB		;check for tab
	JNZ	NOTABOUT	;not tab -- do not update count
	LDA	OBUFLPOS	;tab -- update location in line
	DCR	A		;'A'=out buffer line position-1
	ANI	0F8H		;mask for tab
	ADI	TAB		;and add 9
	JMP	DOUT1
;
;
; Not a tab -- just increment position count
;
NOTABOUT
	LDA	OBUFLPOS	;get address of next character position in out buffer
	INR	A		;add 1 to it
;
DOUT1	STA	OBUFLPOS	;update out buffer line position
	INX	H		;increment buffer pointer
	LDA	OBUFBACKCNT	;get buffer byte count
	DCR	A		;buffer now full?
	JNZ	DOUT2		;continue if not
	LXI	D,OBUF		;write buffer to disk if so
	MVI	C,1AH		;set DMA address
	CALL	BDOS
	LXI	D,FCBZ80	;write block
	CALL	WRITEBLK
	LXI	H,OBUF		;reset output buffer pointer to 1st byte
	MVI	A,80H		;reset buffer byte count
;
DOUT2	SHLD	OBUFPTR		;update output buffer pointer
	STA	OBUFBACKCNT	;update buffer byte count
	POP	PSW		;restore registers
	POP	B
	POP	D
	POP	H
	RET
;.....
;
;
; Write block whose FCB is pointed to by 'DE' to disk
;
WRITEBLK
	MVI	C,15H		;CP/M BDOS write block
	CALL	BDOS
	ANA	A		;error?
	RZ			;ok if none
	LXI	D,ERR1		;else print error message and abort
	JMP	ENDERR
;.....
;
;
; Fill last block with EOF (1AH) and close output file
;
CTRLZFILL
	LDA	OBUFBACKCNT	;get remaining count
	CPI	80H		;full?
	JZ	CLOSEOUT	;close file then
	MVI	A,1AH		;else write EOL (1AH)
	CALL	DOUTCHAR
	JMP	CTRLZFILL
;
;
; Close output file
;
CLOSEOUT
	LXI	D,FCBZ80	;output FCB
	MVI	C,10H		;close file
	JMP	BDOS
;.....
;
;
; Extract next input line for disk file and place it as a 0-terminated
; string in buffer 'INLN'
;
BUILDLINE
	CALL	PDOT		;print activity dot
	XRA	A		;A=false or 0
	STA	INCMT		;turn comment flag off
	STA	INQUOTE		;turn quote flag off
	LXI	H,INLN		;point to INLN buffer
	MVI	B,80		;80 characters maximum
;
;
; Main build loop
;
NXTLCHAR
	PUSH	H
	LHLD	IBUFPTR		;point to next character in file
	SHLD	IBUFPTR
	XCHG			;put into 'DE'
	POP	H
	LDA	IBUFCNT		;check to see if buffer empty
	CPI	80H		;80H if so
	JNZ	PUTCHAR		;not empty, so place character in line
	PUSH	H
	PUSH	B
	LXI	D,IBUFFER	;read next block from input file
	MVI	C,1AH		;set DMA address
	CALL	BDOS
	LXI	D,FCBASM	;read the block
	MVI	C,14H
	CALL	BDOS
	DCR	A		;error?
	JZ	ENDALL		;done if so (assume EOF)
	POP	B
	POP	H
	LXI	D,IBUFFER	;set pointer to 1st byte of block
	SUB	A		;character count = 0
;
;
; Place character pointed to be 'DE' into INLN
;
PUTCHAR	STA	IBUFCNT		;save character count
	LDAX	D		;get character
	INX	D		;point to next
	PUSH	H
	PUSH	D
	XCHG			;put the 'DE' value into 'HL'
	SHLD	IBUFPTR		;save pointer
	POP	D
	LXI	H,IBUFCNT	;increment character count
	INR	M
	POP	H
	CALL	PCAPS		;capitalize character optionally
	MOV	M,A		;save character from file into INLN
	CPI	CR		;end of line?
	JZ	ENDBLINE	;done if so
;
	CPI	TAB		;tab expand?
	JZ	CONTBLINE	;process as normal character if so
	CPI	' '		;less than <sp>?
	JC	NXTLCHAR	;do not process if so
;
CONTBLINE
	DCR	B		;is buffer full?
	INX	H		;point to next character in INLN buffer
	JNZ	NXTLCHAR	;continue processing if not full
	INR	B		;write over last character for rest of line
	DCX	H
	JMP	NXTLCHAR	;continue
;.....
;
;
; Optionally capitalize character in 'A'
;
PCAPS	PUSH	PSW		;save character
	CPI	'*'
	JNZ	PCAPS0
	MOV	A,B		;see if in first column
	CPI	80
	JNZ	PCAPS0		;if not, continue
	POP	PSW		;clear the stack of the asterisk
	MVI	A,';'		;call the asterisk a semicolon instead
	PUSH	PSW		;now put the new character on the stack
	MVI	A,0FFH		;set comment flag
	STA	INCMT
	JMP	PCAPS5		;done
;
PCAPS0	LDA	INCMT		;in a comment?
	ORA	A		;0=no
	JNZ	PCAPS5		;done if so and do not capitalize
	LDA	INQUOTE		;in a quote?
	ORA	A		;0=no
	JNZ	PCAPS1		;do not capitalize if so
	POP	PSW		;not in comment or quote, so capitalize
	CALL	CAPS
	JMP	PCAPS2
PCAPS1	POP	PSW		;get character
;
PCAPS2	CPI	';'		;coming into a comment?
	JNZ	PCAPS3
	PUSH	PSW		;save character
	MVI	A,0FFH		;set comment flag
	STA	INCMT
	JMP	PCAPS5		;done
;
PCAPS3	PUSH	PSW		;save character
	LDA	INQUOTE		;in a quote?
	ORA	A		;0=no
	JZ	PCAPS4
	POP	PSW		;get character -- we are in a quote
	PUSH	PSW		;save it again
	CPI	27H		;are we leaving the quote?
	JNZ	PCAPS5
	XRA	A		;a=0
	STA	INQUOTE		;yes, so set not in quote
	JMP	PCAPS5
;
PCAPS4	POP	PSW		;get character
	PUSH	PSW		;save character one last time
	CPI	27H		;coming into a quote?
	JNZ	PCAPS5
	MVI	A,0FFH		;set inquote flag
	STA	INQUOTE
;
PCAPS5	POP	PSW		;get character
	RET			;done
;.....
;
;
; Store ending <lf> and <null>
;
ENDBLINE
	INX	H		;point to next position
	MVI	M,LF		;store <LF>
	INX	H
	MVI	M,0		;store <null>
	PUSH	H
	PUSH	D
	XCHG
	SHLD	IBUFPTR		;save input file pointer
	POP	D
	POP	H
;
;
; Check for empty line and just output new line if so; else return
;
ENDBL1	MOV	A,B		;line empty?
	SUI	80		;start over if so
	RNZ			;done if not empty
	MVI	A,CR		;output <CR><LF> to file for empty line
	CALL	DOUTCHAR
	MVI	A,LF
	CALL	DOUTCHAR
	JMP	BUILDLINE	;do next line
;.....
;
;
; Capitalize character in 'A'
;
CAPS	ANI	7FH		;mask out MSB
	CPI	61H		;do nothing if less than small 'a'
	RC
	CPI	7AH+1		;capitalize if between small 'a' and 'z', respectively
	RNC
	ANI	5FH		;capitalize
	RET
;.....
;
;
; End of processing
;
ENDALL	CALL	CTRLZFILL	;fill buffer with EOF (1AH)
	LXI	D,ERR5ON	;optionally print each error message if set
	CALL	PMSG
	LXI	D,XLT1ON
	CALL	PMSG
	LXI	D,XLT2ON
	CALL	PMSG
	LXI	D,XLT3ON
	CALL	PMSG
	LXI	D,XLT4ON
	CALL	PMSG
	LXI	D,MSG2
;
;
; Print message pointed to by de with preceeding <crlf> and finish up
;
ENDERR	PUSH	D		;save pointer
	LXI	D,CRLFSTR	;print <CR><LF>
	CALL	PMSG
	POP	D
	CALL	PMSG		;print message
	JMP	WBOOT		;done
;.....
;
;
; Print string pointed to by DE and ending in 0
;
PMSG	LDAX	D		;get character
	ANA	A		;ending 0?
	RZ			;done if so
	CALL	PCHAR		;output character in 'A'
	INX	D		;point to next character
	JMP	PMSG		;continue
;
;
; Print characterin 'A' on the CRT console
;
PCHAR	PUSH	PSW		;save registers
	PUSH	B
	PUSH	D
	PUSH	H
	MOV	E,A		;character in 'E'
	MVI	C,2		;console output
	CALL	BDOS
	POP	H		;restore registers
	POP	D
	POP	B
	POP	PSW
	RET
;.....
;
;
; ****	OP CODE TABLE, MESSAGE AND BUFFER AREA	****
;
; Op code tables
;
OCS1	DB	'ANI  AND  '
	DB	'CMA  CPL  '
	DB	'CMC  CCF  '
	DB	'CPI  CP   '
	DB	'HLT  HALT '
	DB	'JMP  JP   '
	DB	'ORI  OR   '
	DB	'RAL  RLA  '
	DB	'RAR  RRA  '
	DB	'RLC  RLCA '
	DB	'RRC  RRCA '
	DB	'STC  SCF  '
	DB	'SUI  SUB  '
	DB	'XRI  XOR  '
;
POPS	DB	'DB   DEFB '
	DB	'DS   DEFS '
	DB	'DW   DEFW '
	DB	'SET  DEFL '

NOXLT	DB	'ENT  ENTRY'
	DB	'NAM  NAME '
	DB	'RAM  DATA '
	DB	'ROG  REL  '
	DB	0		;end of table for OCS1
;
OCS2	DB	'ANA  AND  '
	DB	'CMP  CP   '
	DB	'DCR  DEC  '
	DB	'INR  INC  '
	DB	'MVI  LD   '
	DB	'ORA  OR   '
	DB	'SUB  SUB  '
	DB	'XRA  XOR  '
	DB	0		;end of table for OCS2
;
OCS3	DB	'DCX  DEC  '
	DB	'INX  INC  '
	DB	'LXI  LD   '
	DB	'POP  POP  '
	DB	'PUSH PUSH '
	DB	0		;end of table for OCS3
;
OCS4	DB	'REQ  RNE  RLT  RGE  CEQ '
	DB	' CNE  CLT  CGE  JEQ  JNE '
	DB	' JLT  JGE  '
	DB	0		;end of table for OCS4
;
RETS	DB	'RC   RNC  RZ   RNZ  RP  '
	DB	' RM   RPE  RPO  '
	DB	0		;end of table for returns
;
CALLS	DB	'CC   CNC  CZ   CNZ  CP  '
	DB	' CM   CPE  CPO  '
	DB	0		;end of table for calls
;
JMPS	DB	'JC   JNC  JZ   JNZ  JP  '
	DB	' JM   JPE  JPO  '
	DB	0		;end of table for jmps
;
OCS8	DB	'DAD  ADD  '
	DW	DO81
	DB	'ADD  ADD  '
	DW	DO82
	DB	'ADC  ADC  '
	DW	DO82
	DB	'SBB  SBC  '
	DW	DO82
	DB	'ADI  ADD  '
	DW	DO82
	DB	'ACI  ADC  '
	DW	DO82
	DB	'SBI  SBC  '
	DW	DO82
	DB	'IN   IN   '
	DW	DO83
	DB	'LDA  LD   '
	DW	DO83
	DB	'LDAX LD   '
	DW	DO84
	DB	'LHLD LD   '
	DW	DO85
	DB	'MOV  LD   '
	DW	 DO86
	DB	'PCHL JP   '
	DW	DO88
	DB	'RST  RST  '
	DW	DO89
	DB	'SHLD LD   '
	DW	DO8A
	DB	'SPHL LD   '
	DW	DO8B
	DB	'STA  LD   '
	DW	DO8C
	DB	'OUT  OUT  '
	DW	DO8C
	DB	'STAX LD   '
	DW	DO8D
	DB	'XCHG EX   '
	DW	DO8E
	DB	'XTHL EX   '
	DW	DO8F
;
NOXLT2	DB	'IFC  IF   '
	DW	DO91
	DB	'ICL  *INCL'
	DW	DO92
	DB	'LST  LIST '
	DW	DO93
	DB	'MAC  MACRO'
	DW	DO94
	DB	0		;end of table for OCS8 and NOXLT2
;.....
;
;
; Various messages and program header
;
HEADER	DB	CR,LF,CR,LF
	DB	'XLATE',VERS/1+'0','  8080-to-Z80 Translator  '
	DB	MONTH/10+'0',(MONTH MOD	10)+'0','/',DAY/10+'0'
	DB	(DAY MOD 10)+'0','/',YEAR/10+'0',(YEAR MOD 10)+'0'
	DB	CR,LF,CR,LF,0
;.....
;
;
; Help messages
;
HMSG1	DB	CR,LF,CR,LF,'XLATE translates an 8080 source code file '
	DB	'into a new Z80 source code',CR,LF,'file that is ready '
	DB	'to assemble using the Microsoft M80 assembler.  To'
	DB	CR,LF,'use, all these examples expect ''HELLO'' to be '
	DB	'an 8080 source code file.',CR,LF,'If a single name is '
	DB	'used the output file will have the same name, with'
	DB	CR,LF,'a .MAC type.',CR,LF
	DB	CR,LF,TAB,'A>XLATE HELLO',TAB,TAB,TAB,'(1)'
	DB	CR,LF,TAB,'A>XLATE HELLO.ASM',TAB,TAB,'(2)'
	DB	CR,LF,TAB,'A>XLATE HELLO.ASM TEST.TXT',TAB,'(3)',CR,LF
	DB	CR,LF,'Two lines will be automatically added at the '
	DB	'very start, for use with',CR,LF,'the M80 assembler:  '
	DB	'.Z80 and ASEG.  The first makes it unnecessary to'
	DB	CR,LF,'use the "/Z" when assembling and the second '
	DB	'insures absolute addresses',CR,LF,'when using L80 to '
	DB	'load the ''HELLO.REL'' file made by M80.',CR,LF,CR,LF
	DB	'All source code will be capitalized.  Any comment '
	DB	'line starting with an',CR,LF,'asterisk will be changed'
	DB	' to a semilcolon.',CR,LF,CR,LF,'Colons will be placed '
	DB	'behind all labels except EQU, MACRO and SET.  The'
	DB	CR,LF,'time it takes to run the program may double, '
	DB	'depending where on the disk',CR,LF,'the input and '
	DB	'output files are physically located at the moment.  A '
	DB	'dot',CR,LF,'is shown each 10 pmg lines, 50 dots to a '
	DB	'line - two are 1000 pgm lines.',CR,LF
	DB	0
;.....
;
;
; File name messages
;
PRFNM1	DB	'Source file: ',0
;
PRFNM2	DB	'  destination file: ',0
;
;
; First two lines of .MAC file will now have the following two lines:
;
FHDR	DB	CR,LF,TAB,'.Z80' ;for using Zilog mnemonics
	DB	CR,LF,TAB,'ASEG' ;insures absolute addresses
	DB	CR,LF,CR,LF,0
ERR1	DB	'++ Output file write error ++',CR,LF,BELL,0
ERR2	DB	'++ No source file found, for help type XLATE ? '
	DB	'<ret> ++',CR,LF,CR,LF,BELL,0
ERR3	DB	'++ No directory space ++',CR,LF,BELL,0
ERR4	DB	'Output file already exists - delete it and '
	DB	'continue (Y/N)? ',BELL,0
ERR4A	DB	CR,LF,'++ Aborting to CP/M ++',CR,LF,BELL,0
MSG2	DB	'Processing complete',CR,LF,BELL,0
CRLFSTR	DB	CR,LF,0
;.....
;
;
; Various error messages
;
ERR5ON	DB	0		;this byte is set to <CR> if string enabled
ERR5	DB	LF
	DB	'The following pseudo-ops have been used in your source '
	DB	'and have not',CR,LF,'been fully translated.  You must '
	DB	'complete the translation using an editor.',CR,LF
	DB	TAB,'Original:',TAB,TAB,'Must Be Translated To:',CR,LF
	DB	0		;end of string
XLT1ON	DB	0		;this byte is set to <tab> if string enabled
XLT1	DB	'#ENDIF',TAB,TAB,TAB,'ENDIF',CR,LF,0
XLT2ON	DB	0		;this byte is set to <tab> if string enabled
XLT2	DB	'ICL',TAB,TAB,TAB,'*INCLUDE',CR,LF,0
XLT3ON	DB	0		;this byte is set to <tab> if string enabled
XLT3	DB	'LST  <operands>',TAB,TAB,'LIST <valid ASMB operands>'
	DB	CR,LF,0
XLT4ON	DB	0		;this byte is set to <tab> if string enabled
XLT4	DB	'MAC <$parameters>',TAB,'MACRO <#parameters>',CR,LF
	DB	TAB,'[ ... ]',TAB,TAB,TAB,'MEND',CR,LF
	DB	TAB,'#macro-call',TAB,TAB,'macro-call',CR,LF,0
;.....
;
;
; Input file FCB
;
FCBASM	DB	0,0,0,0,0,0,0,0,0,'ASM',0
	DB	0,0,0,0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0
;
;
; Output file FCB
;
FCBZ80	DB	0,0,0,0,0,0,0,0,0,'MAC',0
	DB	0,0,0,0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0
;.....
;
;
; BUFFER DATA AREA
;
; stack area
;
	DS	128
;
; Current position in line of output buffer
;
OBUFLPOS  DS	1
;
; Counter for every 10 lines
;
LCOUNT	 DS	1
;
; Counter for every 50*10 lines
;
NLCOUNT	 DS	1
;
; In comment flag -- 0 means not
;
INCMT	 DS	1
;
; In quote flag -- 0 means not
;
INQUOTE	 DS	1
;
; Pointer to target op code in input line
;
ILTOP	 DS	2
;
; Op code to match against
;
TARGOP	 DS	5
;
; Pointer to current position in current input line
;
INLNPTR	 DS	2
;
; Pointer to current position in output buffer (block)
;
OBUFPTR	 DS	2
;
; Count of characters remaining in output buffer
;
OBUFBACKCNT  DS	1
;
; Output buffer (block)
;
OBUF	 DS	128
;
; Current input line buffer
;
INLN	 DS	80		;80 characters in line
	 DS	3		;3 extra for <cr> <lf> <null>
;
; Pointer to current position in input buffer
;
IBUFPTR	 DS	2
;
; Count of number of characters left in input buffer
;
IBUFCNT	 DS	1
;
; Input buffer (block)
;
IBUFFER	 DS	128

	 END
