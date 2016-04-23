;===============================================================================
; BASIC language interpreter
; (c) 1978 Microsoft
; Modified to run on Space-Time Productions Z80 Board 2004-2005
;===============================================================================
;
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
; This version of BASIC (plain, no BASIC1) assumes:
; ROM in the bottom 16K area from $0000-$3FFF
; RAM from $4000-$FFFF (skips $4000-$400F for Dallas RAMified Timekeeper)
; RST08 will transmit an ASCII character
; RST10 will receive  an ASCII character
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;
;------------------------------------------------------------------------------
; Memory Map
;------------------------------------------------------------------------------
RAM	equ	$4000		; STACK BOTTOM     (4010-40FF)
STACK	equ	$4100		; STACK TOP        (4010-40FF)
SYSVAR	equ	$4100		; SYSTEM VAR SPACE (4100-41FF)
INBUFF	equ	$4160		; INPUT  BUFFER    (4160-41AF)
BUFFER	equ	$41B0		; CRUNCH BUFFER    (41B0-41FF)

BASICV	equ	$4200		; BASIC  VAR SPACE (4200-42FF)
LTEXT	equ	$4300		; BASIC PROGRAM    (4300-FFFF)
;------------------------------------------------------------------------------
; System Variables and Storage
;------------------------------------------------------------------------------
IOBASE	equ	SYSVAR		;COPY OF PIO MAP   (3100-310F)

DUMPBUF	equ	SYSVAR+$30	; ASCII chars from memory command $30-$3F
NMI	equ	SYSVAR+$40	; JP TO NMIV


LSTVAR	equ	$5F		; LAST VARIABLE SPACE AVAILABLE, DO NOT PASS GO
;------------------------------------------------------------------------------
;General Equates
;------------------------------------------------------------------------------
LF	equ	$0A		; LINE FEED
CS	equ	$0C		; FORM FEED
CR	equ	$0D		; CARRIAGE RETURN
CTRLC	equ	$03		; <CTRL-C>
CTRLG	equ	$07		; <CTRL-G>
CTRLO	equ	$0F		; <CTRL-O>
CTRLQ	equ	$11		; <CTRL-Q>
CTRLR	equ	$12		; <CTRL-R>
CTRLS	equ	$13		; <CTRL-S>
CTRLU	equ	$15		; <CTRL-U>
CTRLZ	equ	$1A		; <CTRL-Z>
ESC	equ	$1B		; ESCAPE KEY
DEL	equ	$7F		; DELETE KEY
BKSP	equ	$08		; BACK SPACE
ZERBYT	equ	$-1		; A zero byte (?)
;------------------------------------------------------------------------------
; BASIC ERROR CODE VALUES
;------------------------------------------------------------------------------
NF      equ     $01            ; NEXT without FOR
SN      equ     $02            ; Syntax error
RG      equ     $03            ; RETURN without GOSUB
OD      equ     $04            ; Out of DATA
FC      equ     $05            ; Function call error
OV      equ     $06            ; Overflow
OM      equ     $07            ; Out of memory
UL      equ     $08            ; Undefined line number
BS      equ     $09            ; Bad subscript
DD      equ     $0A            ; Re-DIMensioned array
DZ      equ     $0B            ; Division by zero (/0)
ID      equ     $0C            ; Illegal direct
TM      equ     $0D            ; Type miss-match
OS      equ     $0E            ; Out of string space
LS      equ     $0F            ; String too long
ST      equ     $10            ; String formula too complex
CN      equ     $11            ; Can't CONTinue
UF      equ     $12            ; UnDEFined FN function
MO      equ     $13            ; Missing operand
SO	equ	 $14            ; Stack overflow
HX	equ	 $15		; Not valid HEX value
;------------------------------------------------------------------------------
; RESERVED WORD TOKEN VALUES
;  Tokens occupy from $80 thru $CF connected to each reserved word in the
;  "WORDS:" list; these are the only ones referenced by indexing routines
;------------------------------------------------------------------------------
ZEND    equ     080H           ; END
ZFOR    equ     081H           ; FOR
ZDATA   equ     083H           ; DATA
ZGOTO   equ     088H           ; GOTO
ZGOSUB  equ     08CH           ; GOSUB
ZREM    equ     08EH           ; REM
ZPRINT  equ     09EH           ; PRINT
ZNEW    equ     0A4H           ; NEW
ZTAB    equ     0A5H           ; TAB
ZTO     equ     0A6H           ; TO
ZFN     equ     0A7H           ; FN
ZSPC    equ     0A8H           ; SPC
ZTHEN   equ     0A9H           ; THEN
ZNOT    equ     0AAH           ; NOT
ZSTEP   equ     0ABH           ; STEP
ZPLUS   equ     0ACH           ; +
ZMINUS  equ     0ADH           ; -
ZTIMES  equ     0AEH           ; *
ZDIV    equ     0AFH           ; /
ZOR     equ     0B2H           ; OR
ZGTR    equ     0B3H           ; >
ZEQUAL  equ     0B4H           ; M
ZLTH    equ     0B5H           ; <
ZSGN    equ     0B6H           ; SGN
ZPOINT  equ     0C7H           ; POINT
ZLEFT   equ     0CDH           ; LEFT$
;------------------------------------------------------------------------------
; BASIC WORKSPACE LOCATIONS
;------------------------------------------------------------------------------
WRKSPC	equ	BASICV		; Initially $4200
USR	equ	BASICV+$03	; "USR(X)" JUMP, SET INITALLY TO FN ERROR
OUTSUB	equ	BASICV+$06	; "OUT P,N"
OTPORT	equ	BASICV+$07	; PORT (P)
DIVSUP	equ	BASICV+$09	; DIVISION SUPPORT ROUTINE
DIV1	equ	BASICV+$0A	; <- VALUES TO
DIV2	equ	BASICV+$0E	; <- ADDED
DIV3	equ	BASICV+$12	; <- DURING
DIV4	equ	BASICV+$15	; <- DIVISION CALC
SEED	equ	BASICV+$17	; RANDOM SEED NUMBER
LSTRND	equ	BASICV+$3A	; LAST RANDOM NUMBER
INPSUB	equ	BASICV+$3E	; "INP(X)" ROUTINE
INPORT	equ	BASICV+$3F	; PORT(X)
NULLS	equ	BASICV+$41	; NUMBER OF NULLS POS(X) NUMBER
LWIDTH	equ	BASICV+$42	; TERMINAL WIDTH
COMMAN	equ	BASICV+$43	; WIDTH FOR COMMAS
NULFLG	equ	BASICV+$44	; NULL AFTER INPUT BYTE FLAG
CTLOFG	equ	BASICV+$45	; CONTROL "O" FLAG OUTPUT ENABLE
LINESC	equ	BASICV+$46	; LINES COUNTER
LINESN	equ	BASICV+$48	; LINES NUMBER
CHKSUM	equ	BASICV+$4A	; ARRAY LOAD/SAVE CHECK SUM
NMIFLG	equ	BASICV+$4C	; FLAG FOR NMI BREAK ROUTINE
BRKFLG	equ	BASICV+$4D	; BREAK FLAG

CURPOS	equ	BASICV+$4E	; CHARACTER POSITION ON LINE
LCRFLG	equ	BASICV+$4F	; LOCATE/CREATE FLAG
TYPE	equ	BASICV+$50	; DATA TYPE FLAG
DATFLG	equ	BASICV+$51	; LITERAL STATEMENT FLAG
FORFLG	equ	BASICV+$52	; "FOR" LOOP FLAG
LSTBIN	equ	BASICV+$53	; LAST BYTE ENTERED
LREADFG	equ	BASICV+$54	; LREAD/INPUT FLAG
LINEAT	equ	BASICV+$55	; Current line number

RAMTOP  equ    BASICV+$60      ; Physical end of RAM
PROGST	equ	BASICV+$62	; START OF BASIC LTEXT AREA
STLOOK	equ	BASICV+$64	; PROGRAM START + 100 BYTES
FRERAM  equ	BASICV+$66	; Calculated ram for BASIC program text
SYSRAM	equ	BASICV+$68	; Calculated ram for BASIC text+vars
BASTXT	equ	BASICV+$6A	; Pointer to start of program
STRSPC	equ	BASICV+$6C	; Bottom of string space in use
PROGND	equ	BASICV+$6E	; END OF PROGRAM
VAREND	equ	BASICV+$70	; END OF VARIABLES
ARREND	equ	BASICV+$72	; END OF ARRAYS
LSTRAM	equ	BASICV+$74	; LAST AVAILABLE RAM

TMSTPT	equ	BASICV+$81	; TEMPORARY STRING POINTER
TMSTPL	equ	BASICV+$83	; TEMPORARY STRING POOL
TMPSTR	equ	BASICV+$8F	; TEMPORARY STRING
STRBOT	equ	BASICV+$93	; BOTTOM OF STRING SPACE
CUROPR	equ	BASICV+$95	; CURRENT OPERATOR IN EVAL
LOOPST	equ	BASICV+$97	; FIRST STATEMENT OF LOOP
DATLIN	equ	BASICV+$99	; LINE OF CURRENT DATA ITEM
BRKLIN	equ	BASICV+$A6	; LINE OF BREAK
NXTOPR	equ	BASICV+$A8	; NEXT OPERATOR IN EVAL
ERRLIN	equ	BASICV+$AA	; LINE OF ERROR
CONTAD	equ	BASICV+$AC	; WHERE TO CONTINUE
NXTDAT	equ	BASICV+$AE	; NEXT DATA ITEM

FNRGNM	equ	BASICV+$B0	; NAME OF "FN" ARGUMENT
FNARG	equ	BASICV+$B2	; FN ARGUMENT VALUE

FPREG	equ	BASICV+$C0	; FLOATING POINT REGISTER $C0 $C1 $C2
FPEXP	equ	BASICV+$C3	; FLOATING POINT EXPONENT
SGNRES	equ	BASICV+$C4	; SIGN OF RESULT

PBUFF	equ	BASICV+$D0	; NUMERIC DISPLAY PRINT BUFFER

MULVAL	equ	BASICV+$E0	; MULTIPLIER

X1POS	equ	BASICV+$F0	; X position integer from GETXY
Y1POS	equ	BASICV+$F2	; Y position integer from GETXY
X2POS	equ	BASICV+$F4	; X2 position for calculations
Y2POS	equ	BASICV+$F6	; Y2 position for calculations
RADIUS	equ	BASICV+$F8	; Radius for circle, elipse calcs

;------------------------------------------------------------------------------
; I/O routines for the DarkStar Z80
;------------------------------------------------------------------------------

CONOUT	equ	$fb10
CONIN	equ	$f866
GETKBD	equ	$f094

;------------------------------------------------------------------------------
; B A S I C   Cold  Start
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
BASIC	org	$1000		; START IN ROM 2
CSTART	DI			; Disable INTerrupts
	LD	SP,STACK	; Set SP pointer
;------------------------------------------------------------------------------
; LOAD DEFAULTS INTO TABLE IN WORKSPACE
;------------------------------------------------------------------------------
INIT	LD	HL,INITAB	; Source=Init table
	LD	DE,WRKSPC	; Dest=Basic Var space in static RAM
	LD	BC,INITX-INITAB	; Number of bytes to copy
	LDIR			; Make the move
	LD	HL,SIGNON	; Get SIGNON message
	CALL	PRT		; Clear the screen and print it out

	LD	HL,$4300	; START OF OFF-BOARD RAM
	LD	(PROGST),HL	; SET START OF PROGRAM LTEXT
	LD	(BASTXT),HL	; LOAD BASTXT VARIABLE AS WELL
	LD	DE,$4374	; PROGST + 100 BYTES
	LD	(STLOOK),DE	; SAVE IT, CONTINUE INTO UPPPER MEM TEST
;------------------------------------------------------------------------------
; We assume there is > 100 bytes of expansion ram available above
; $4000, so we set the parameters and start checking upward, watching for
; HL rollover from $FFFF to $0000, meaning full ram thru $FFFF
;------------------------------------------------------------------------------
TSTMEM	LD	HL,$4300	; START OF PROGRAM LTEXT AREA
TSTMEM1	LD	A,$AA		; BINARY 1010 1010 BIT PATTERN TO TEST MEMORY
	LD	(HL),A		; STORE THE BYTE TO MEMORY
	CP	(HL)		; SEE IF MEMORY IS RESPONDING A-(HL)
	JR	NZ,SETTOP	; NO? MUST BE PAST TOP OF RAM
	XOR	A		; ZERO OUT A AS WE GO
	LD	(HL),A		; SAVE IT BACK
	INC	HL		; YES IT WORKS, TRY NEXT LOCATION
	LD	A,H		; SEE IF HL ROLLED OVER TO $0000
	OR	L		; SET THE Z FLAG WITH RESULT
	JR	NZ,TSTMEM1	; HL NOT ROLLED OVER, LOOP UNTIL TOP OF RAM LOCATED
;------------------------------------------------------------------------------
; SETS MEMORY ALLOCATIONS BASED ON HL BEING ONE OVER THE PHYSICAL TOP OF RAM
;------------------------------------------------------------------------------
SETTOP	DEC	HL		; BACK ONE BYTE TO LAST KNOWN GOOD RAM ADDRESS
	LD	(RAMTOP),HL	; PHYSICAL TOP OF RAM (WHAT THE HARDWARE HAS)
	LD	(LSTRAM),HL	; LOGICAL  TOP OF RAM (CAN BE CHANGED BY CLEAR)
	LD	DE,$FF06	; -250 BYTES FOR STRING SPACE LOCATION
	ADD	HL,DE		; ALLOCATE STRING SPACE
	LD	(STRSPC),HL	; SAVE STRING SPACE (STRSPC=LSTRAM-100)
	LD	DE,(PROGST)	; GET START OF RAM AGAIN
	DEC	DE		; COUNT BOTTOM BYTE
	OR	A		; CLEAR CARRY FLAG
	SBC	HL,DE		; GET [STRSPC-PROGST]
	LD	(FRERAM),HL	; SAVE IT
	LD	HL,(RAMTOP)	; RETRIEVE PHYSICAL END OF RAM
	LD	DE,(PROGST)	; $4010 EXPANSION BOARD
	DEC	DE		; COUNT BOTTOM BYTE, ALSO
	OR	A		; CLEAR CARRY FLAG
	SBC	HL,DE		; GET DIFFERENCE
	LD	(SYSRAM),HL	; STORE SYSTEM RAM (SYSRAM=RAMTOP-PROGST-1)
;------------------------------------------------------------------------------
; Signon message, retrieve RAM parameters
;------------------------------------------------------------------------------
	LD	HL,(SYSRAM)	; Get SYSRAM value back
	CALL	PRNTHL		; Print number of bytes total
	LD	HL,SRAM		; " System Ram" message
	CALL	PRT		; Print the message
	LD	HL,(FRERAM)	; GET BYTES FREE BACK
	CALL	PRNTHL		; OUTPUT AMOUNT OF FREE MEMORY
	LD	HL,BFREE	; " Bytes Free" MESSAGE
	CALL	PRT		; Print the message
	XOR	A		; Clear A to zero
	LD	(BUFFER),A	; Mark end of buffer
	LD	HL,(PROGST)	; Locate at start of BASTXT
	LD	(HL),A		; Initialize BASIC area

	CALL	CLRPTR		; CLEAR POINTERS AND SET UP PROGRAM AREA
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
; B A S I C   Warm  Start
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
WARMST	EI			; Enable INTerrupts to system
BRKRET	CALL    CLREG           ; Clear registers and stack
        JP      PRNTOK          ; Go to get command line

BAKSTK	LD      HL,4            ; Look for "FOR" block with
        ADD     HL,SP           ; same index as specified
LOKFOR	LD      A,(HL)          ; Get block ID
        INC     HL              ; Point to index address
        CP      ZFOR            ; Is it a "FOR" token
        RET     NZ              ; No - exit
        LD      C,(HL)          ; BC = Address of "FOR" index
        INC     HL
        LD      B,(HL)
        INC     HL              ; Point to sign of STEP
        PUSH    HL              ; Save pointer to sign
        LD      L,C             ; HL = address of "FOR" index
        LD      H,B
        LD      A,D             ; See if an index was specified
        OR      E               ; DE = 0 if no index specified
        EX      DE,HL           ; Specified index into HL
        JR      Z,INDFND        ; Skip if no index given
        EX      DE,HL           ; Index back into DE
        CALL    CPHLDE          ; Compare index with one given
INDFND	LD      BC,16-3         ; Offset to next block
        POP     HL              ; Restore pointer to sign
        RET     Z               ; Return if block found
        ADD     HL,BC           ; Point to next block
        JR      LOKFOR          ; Keep on looking

MOVUP	CALL    ENFMEM          ; See if enough memory
MOVSTR	PUSH    BC              ; Save end of source
        EX      (SP),HL         ; Swap source and dest" end
        POP     BC              ; Get end of destination
MOVLP	CALL    CPHLDE          ; See if list moved
        LD      A,(HL)          ; Get byte
        LD      (BC),A          ; Move it
        RET     Z               ; Exit if all done
        DEC     BC              ; Next byte to move to
        DEC     HL              ; Next byte to move
        JR      MOVLP           ; Loop until all bytes moved
;------------------------------------------------------------------------------
; Check variable space "stack" to see if getting near end of available space
;------------------------------------------------------------------------------
CHKSTK	PUSH    HL              ; Save code string address
        LD      HL,(ARREND)     ; Lowest free memory
        LD      B,0             ; BC = Number of levels to test
        ADD     HL,BC           ; 2 Bytes for each level
        ADD     HL,BC
	defb	$3E		; Skip "PUSH HL"
;------------------------------------------------------------------------------
; ENFMEM had to be completely rebuilt to properly check for mem limits
;------------------------------------------------------------------------------
ENFMEM	PUSH	HL		; Save code string address
	PUSH	DE		; Use to calc available space
	LD	DE,50		; 50 Bytes minimum RAM
	ADD	HL,DE		; See if requested address rolls over $FFFF
	JR	C,OMERR		; Too high for CPU to physically address

	LD	DE,(LSTRAM)	; Get physical top of RAM
	EX	DE,HL		; Swap for subtraction
	SBC	HL,DE		; Subtract RAMTOP-(code string address+50)
	EX	DE,HL		; Swap code string back to HL
	JR	C,OMERR		; Requested address is > RAMTOP

	LD	HL,$0000	; Check if SP is about to overrun limits
	ADD	HL,SP		; Move SP into HL
	LD	DE,RAM+10	; Nearing lowest available stack position $4010
	SBC	HL,DE		; Subtract current SP-RAM ($40xx-$4010)
	JR	C,SOERR		; SP has overrun into BASIC variable table
	JR	Z,SOERR		; SP is right at bottom of available space

	POP	DE		; If requested memory is o.k. then,
	POP	HL		; Restore values and
	RET			; Return to the calling program
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
; Error Control
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
DATSNR	LD      HL,(DATLIN)     ; Get line of current DATA item
        LD      (LINEAT),HL     ; Save as current line
SNERR	LD	E,SN            ; ?SyNtax Error
        defb	01H             ; Skip "LD E,DZ" using "LD BC,(nnnn)"
DZERR	LD      E,DZ            ; ?/0 Error Divide by Zero
        defb   01H             ; Skip "LD E,NF"
NFERR	LD      E,NF            ; ?Next without For Error
        defb   01H             ; Skip "LD E,DD"
DDERR	LD      E,DD            ; ?DD Error
        defb   01H             ; Skip "LD E,UF"
UFERR	LD      E,UF            ; ?Undefined Fn Error
        defb   01H             ; Skip "LD E,OV
OVERR	LD      E,OV            ; ?OV Error
        defb   01H             ; Skip "LD E,TM"
TMERR	LD      E,TM            ; ?TM Error
	defb	01H		; Skip "LD E,SO"
SOERR	LD	E,SO		; ?Stack Overflow
	defb	01H		; Skip "LD E,OM"
OMERR	LD      E,OM            ; Error - Out of Memory
	defb	01H		; Skip "LE E,HX"
HXERR	LD	E,HX		; Error - Not valid HEX value
;------------------------------------------------------------------------------	
ERROR	CALL    CLREG           ; Clear registers and stack
        LD      (CTLOFG),A      ; Enable output (A is 0)
        CALL    STTLIN          ; Start new line
        LD      HL,ERRORS       ; Point to error codes
        LD      D,A             ; D = 0 (A is 0)
        LD      A,'?'
        CALL    OUTC            ; Output "?"
        LD	A,$20		; <SPACE>
        CALL	OUTC		; Output space
ERROR0  LD	A,(HL)		; Get character in error table
        CP	E		; Arrived at correct msg?
	INC	HL		; Next location
	JR	NZ,ERROR0	; Seek until correct msg found
	CALL    PRS             ; Output message
	LD	HL,ERRMSG	; " Error" text
ERRIN	CALL	PRS	        ; Output message
        LD      HL,(LINEAT)     ; Get line of error
        LD      DE,-2           ; Cold start error if -2
        CALL    CPHLDE          ; See if cold start error
        JP      Z,CSTART        ; Cold start error - Restart
        LD      A,H             ; Was it a direct error?
        AND     L               ; Line = -1 if direct error
        INC     A
        CALL    NZ,LINEIN       ; No - output line of error
        defb	$3E             ; Skip "POP BC"
POPNOK	POP     BC              ; Drop address in input buffer
;------------------------------------------------------------------------------
; LREADY
;------------------------------------------------------------------------------
PRNTOK	XOR     A               ; Output "Ok" and get command
        LD      (CTLOFG),A      ; Enable output
        CALL    STTLIN          ; Start new line
        LD      HL,OKMSG        ; "Ok" message
        CALL    PRS             ; Output "Ok"
GETCMD	LD      HL,-1           ; Flag direct mode
        LD      (LINEAT),HL     ; Save as current line
        CALL    TTYLIN          ; Get an input line
        JR      C,GETCMD        ; Get line again if break
        CALL    GETCHR          ; Get first character
        INC     A               ; Test if end of line
        DEC     A               ; Without affecting Carry
        JR      Z,GETCMD        ; Nothing entered - Get another
        PUSH    AF              ; Save Carry status
        CALL    AS2HX            ; Get line number into DE
        PUSH    DE              ; Save line number
        CALL    CRUNCH          ; Tokenise rest of line
        LD      B,A             ; Length of tokenised line
        POP     DE              ; Restore line number
        POP     AF              ; Restore Carry
        JP      NC,EXCUTE       ; No line number - Direct mode
        PUSH    DE              ; Save line number
        PUSH    BC              ; Save length of tokenised line
        XOR     A
        LD      (LSTBIN),A      ; Clear last byte input
        CALL    GETCHR          ; Get next character
        OR      A               ; Set flags
        PUSH    AF              ; And save them
        CALL    SRCHLN          ; Search for line number in DE
        JR      C,LINFND        ; Jump if line found
        POP     AF              ; Get status
        PUSH    AF              ; And re-save
        JP      Z,ULERR         ; Nothing after number - Error
        OR      A               ; Clear Carry
LINFND	PUSH    BC              ; Save address of line in prog
        JR      NC,INEWLN       ; Line not found - Insert new
        EX      DE,HL           ; Next line address in DE
        LD      HL,(PROGND)     ; End of program
SFTPRG	LD      A,(DE)          ; Shift rest of program down
        LD      (BC),A
        INC     BC              ; Next destination
        INC     DE              ; Next source
        CALL    CPHLDE          ; All done?
        JR      NZ,SFTPRG       ; More to do
        LD      H,B             ; HL - New end of program
        LD      L,C
        LD      (PROGND),HL     ; Update end of program
;------------------------------------------------------------------------------
; Insert new line into BASIC program
;------------------------------------------------------------------------------
INEWLN	POP     DE              ; Get address of line,
        POP     AF              ; Get status
        JR      Z,SETPTR        ; No text - Set up pointers
        LD      HL,(PROGND)     ; Get end of program
        EX      (SP),HL         ; Get length of input line
        POP     BC              ; End of program to BC
        ADD     HL,BC           ; Find new end
        PUSH    HL              ; Save new end
        CALL    MOVUP           ; Make space for line
        POP     HL              ; Restore new end
        LD      (PROGND),HL     ; Update end of program pointer
        EX      DE,HL           ; Get line to move up in HL
        LD      (HL),H          ; Save MSB
        POP     DE              ; Get new line number
        INC     HL              ; Skip pointer
        INC     HL
        LD      (HL),E          ; Save LSB of line number
        INC     HL
        LD      (HL),D          ; Save MSB of line number
        INC     HL              ; To first byte in line
        LD      DE,BUFFER       ; Copy buffer to program
MOVBUF	LD      A,(DE)          ; Get source
        LD      (HL),A          ; Save destinations
        INC     HL              ; Next source
        INC     DE              ; Next destination
        OR      A               ; Done?
        JR      NZ,MOVBUF       ; No - Repeat
SETPTR	CALL    RUNFST          ; Set line pointers
        INC     HL              ; To LSB of pointer
        EX      DE,HL           ; Address to DE
PTRLP	LD      H,D             ; Address to HL
        LD      L,E
        LD      A,(HL)          ; Get LSB of pointer
        INC     HL              ; To MSB of pointer
        OR      (HL)            ; Compare with MSB pointer
        JP      Z,GETCMD        ; Get command line if end
        INC     HL              ; To LSB of line number
        INC     HL              ; Skip line number
        INC     HL              ; Point to first byte in line
        XOR     A               ; Looking for 00 byte
FNDEND	CP      (HL)            ; Found end of line?
        INC     HL              ; Move to next byte
        JR      NZ,FNDEND       ; No - Keep looking
        EX      DE,HL           ; Next line address to HL
        LD      (HL),E          ; Save LSB of pointer
        INC     HL
        LD      (HL),D          ; Save MSB of pointer
        JR      PTRLP           ; Do next line
;------------------------------------------------------------------------------
; Search for a particular Line Number (DE) in BASIC program text
; Z =DE line number is found, or DE is at end of program, and DE > largest no.
; NC=DE line number not found and HL has found a line with number > DE
;------------------------------------------------------------------------------
SRCHLN	LD      HL,(BASTXT)     ; Start of program text
SRCHLP: LD      B,H             ; BC = Address to look at
        LD      C,L
        LD      A,(HL)          ; Get address of next line
        INC     HL
        OR      (HL)            ; Two "00"s, End of program found?
        DEC     HL
        RET     Z               ; Yes - Line not found
        INC     HL
        INC     HL
        LD      A,(HL)          ; Get LSB of line number
        INC     HL
        LD      H,(HL)          ; Get MSB of line number
        LD      L,A
        CALL    CPHLDE          ; Compare with line in DE
        LD      H,B             ; HL = Start of this line
        LD      L,C
        LD      A,(HL)          ; Get LSB of next line address
        INC     HL
        LD      H,(HL)          ; Get MSB of next line address
        LD      L,A             ; Next line to HL
        CCF
        RET     Z               ; Lines found - Exit
        CCF
        RET     NC              ; Line not found, at line after line # in DE
        JR      SRCHLP          ; Keep looking
;------------------------------------------------------------------------------
; NEW
;------------------------------------------------------------------------------
NEW:    RET     NZ              ; Return if any more on line
CLRPTR: LD      HL,(BASTXT)     ; Point to start of program
        XOR     A               ; Set program area to empty
        LD      (HL),A          ; Save LSB = 00
        INC     HL
        LD      (HL),A          ; Save MSB = 00
        INC     HL
	LD	(HL),A		; Mark end of program
        LD      (PROGND),HL     ; Set program end in variables

RUNFST: LD      HL,(BASTXT)     ; Clear all variables
        DEC     HL

INTVAR: LD      (BRKLIN),HL     ; Initialise RUN variables
        LD      HL,(LSTRAM)     ; Get end of RAM
        LD      (STRBOT),HL     ; Clear string space
        XOR     A
        CALL    RESTOR          ; Reset DATA pointers
        LD      HL,(PROGND)     ; Get end of program
        LD      (VAREND),HL     ; Clear variables
        LD      (ARREND),HL     ; Clear arrays

CLREG:  POP     BC              ; Save return address
        LD      SP,STACK        ; Set stack
        LD      HL,TMSTPL       ; Temporary string pool
        LD      (TMSTPT),HL     ; Reset temporary string ptr
        XOR     A               ; A = 00
        LD      L,A             ; HL = 0000
        LD      H,A
        LD      (CONTAD),HL     ; No CONTinue
        LD      (FORFLG),A      ; Clear FOR flag
        LD      (FNRGNM),HL     ; Clear FN argument
        PUSH    HL              ; HL = 0000
        PUSH    BC              ; Put back return
DOAGN:  LD      HL,(BRKLIN)     ; Get address of code to RUN
        RET                     ; Return to execution driver
;------------------------------------------------------------------------------
; Prompt for input
;------------------------------------------------------------------------------
PROMPT: LD      A,'?'           ; "?"
        CALL    OUTC            ; Output character
        LD      A,$20           ; Space
        CALL    OUTC            ; Output character
	JP	TTYLIN		; This was formerly RINPUT vector XRINPUT
;------------------------------------------------------------------------------
; CRUNCH converts and tokenizes the line of text at HL into the BUFFER at DE
; Called by GETCMD shortly after TTYLIN
;
;------------------------------------------------------------------------------
CRUNCH: XOR     A               ; Tokenise line @ HL to BUFFER
        LD      (DATFLG),A      ; Reset literal flag
        LD      C,2+3           ; 2 byte number and 3 nulls
        LD      DE,BUFFER       ; Start of input buffer
CRNCLP: LD      A,(HL)          ; Get byte
        CP      $20             ; Is it a space?
        JR      Z,MOVDIR        ; Yes - Copy direct
        LD      B,A             ; Save character
        CP      $22             ; Is it a quote?
        JP      Z,CPYLIT        ; Yes - Copy literal string
        OR      A               ; Is it end of buffer?
        JP      Z,ENDBUF        ; Yes - End buffer
        LD      A,(DATFLG)      ; Get data type
        OR      A               ; Literal?
        LD      A,(HL)          ; Get byte to copy
        JR      NZ,MOVDIR       ; Literal - Copy direct
        CP      '?'             ; Is it "?" short for PRINT
        LD      A,ZPRINT        ; "PRINT" token
        JR      Z,MOVDIR        ; Yes - replace it
        LD      A,(HL)          ; Get byte again
        CP      '0'             ; Is it less than "0"
        JR      C,FNDWRD        ; Yes - Look for reserved words
        CP      $3C             ; Is it "0123456789:;" ?
        JR      C,MOVDIR        ; Yes - copy it direct
FNDWRD: PUSH    DE              ; Look for reserved words
        LD      DE,WORDS-1      ; Point to WORDS table
        PUSH    BC              ; Save count
        LD      BC,RETNAD       ; Where to return to
        PUSH    BC              ; Save return address
        LD      B,ZEND-1        ; First token value -1
        LD      A,(HL)          ; Get byte
        CP      'a'             ; Less than "a" ?
        JR      C,SEARCH        ; Yes - search for words
        CP      'z'+1           ; Greater than "z" ?
        JR      NC,SEARCH       ; Yes - search for words
        AND     01011111B       ; Force upper case
        LD      (HL),A          ; Replace byte
SEARCH: LD      C,(HL)          ; Search for a word
        EX      DE,HL
GETNXT: INC     HL              ; Get next reserved word
        OR      (HL)            ; Start of word?
        JP      P,GETNXT        ; D7? No - move on
        INC     B               ; Increment token value
        LD      A,(HL)          ; Get byte from table
        AND     01111111B       ; Strip bit 7
        RET     Z               ; Return if end of list
        CP      C               ; Same character as in buffer?
        JR      NZ,GETNXT       ; No - get next word
        EX      DE,HL
        PUSH    HL              ; Save start of word

NXTBYT: INC     DE              ; Look through rest of word
        LD      A,(DE)          ; Get byte from table
        OR      A               ; End of word ?
        JP      M,MATCH         ; Yes - Match found
        LD      C,A             ; Save it
        LD      A,B             ; Get token value
        CP      ZGOTO           ; Is it "GOTO" token ?
        JR      NZ,NOSPC        ; No - Don't allow spaces
        CALL    GETCHR          ; Get next character
        DEC     HL              ; Cancel increment from GETCHR
NOSPC:  INC     HL              ; Next byte
        LD      A,(HL)          ; Get byte
        CP      'a'             ; Less than "a" ?
        JR      C,NOCHNG        ; Yes - don't change
        AND     01011111B       ; Make upper case
NOCHNG: CP      C               ; Same as in buffer ?
        JR      Z,NXTBYT        ; Yes - keep testing
        POP     HL              ; Get back start of word
        JR      SEARCH          ; Look at next word

MATCH:  LD      C,B             ; Word found - Save token value
        POP     AF              ; Throw away return
        EX      DE,HL
        RET                     ; Return to "RETNAD"
RETNAD: EX      DE,HL           ; Get address in string
        LD      A,C             ; Get token value
        POP     BC              ; Restore buffer length
        POP     DE              ; Get destination address
MOVDIR: INC     HL              ; Next source in buffer
        LD      (DE),A          ; Put byte in buffer
        INC     DE              ; Move up buffer
        INC     C               ; Increment length of buffer
        SUB     $3A             ; End of statement ":" ?
        JR      Z,SETLIT        ; Jump if multi-statement line
        CP      ZDATA-3AH       ; Is it DATA statement ?
        JR      NZ,TSTREM       ; No - see if REM
SETLIT: LD      (DATFLG),A      ; Set literal flag
TSTREM: SUB     ZREM-3AH        ; Is it REM?
        JP      NZ,CRNCLP       ; No - Leave flag
        LD      B,A             ; Copy rest of buffer
NXTCHR: LD      A,(HL)          ; Get byte
        OR      A               ; End of line ?
        JR      Z,ENDBUF        ; Yes - Terminate buffer
        CP      B               ; End of statement ?
        JR      Z,MOVDIR        ; Yes - Get next one
CPYLIT: INC     HL              ; Move up source string
        LD      (DE),A          ; Save in destination
        INC     C               ; Increment length
        INC     DE              ; Move up destination
        JR      NXTCHR          ; Repeat

ENDBUF: LD      HL,BUFFER-1     ; Point to start of buffer
        LD      (DE),A          ; Mark end of buffer (A = 00)
        INC     DE
        LD      (DE),A          ; A = 00
        INC     DE
        LD      (DE),A          ; A = 00
        RET

DODEL:  LD      A,(NULFLG)      ; Get null flag status
        OR      A               ; Is it zero?
        LD      A,0             ; Zero A - Leave flags
        LD      (NULFLG),A      ; Zero null flag
        JR      NZ,ECHDEL       ; Set - Echo it
        DEC     B               ; Decrement length
        JR      Z,TTYLIN        ; Get line again if empty
        CALL    OUTC            ; Output null character
        defb   $3E             ; Skip "DEC B"
ECHDEL: DEC     B               ; Count bytes in buffer
        DEC     HL              ; Back space buffer
        JR      Z,OTKLN         ; No buffer - Try again
        LD      A,(HL)          ; Get deleted byte
        CALL    OUTC            ; Echo it
        JR      MORINP          ; Get more input

DELCHR: DEC     B               ; Count bytes in buffer
        DEC     HL              ; Back space buffer
        CALL    OUTC            ; Output character in A
        JR      NZ,MORINP       ; Not end - Get more
OTKLN:  CALL    OUTC            ; Output character in A
KILIN:  CALL    PRNTCR          ; Output CRLF
;------------------------------------------------------------------------------
; Get a line from TTY into INBUFF, located in register HL
;  This code was changed to stop overlapping in BUFFER during CRUNCH
;------------------------------------------------------------------------------
TTYLIN  LD      HL,INBUFF       ; Get a line by character
        LD      B,1             ; Set buffer as empty
        XOR     A
        LD      (NULFLG),A      ; Clear null flag
MORINP  CALL    CLOTST          ; Get character and test <CTRL-O>
        LD      C,A             ; Save character in C
        CP      DEL             ; Delete character?
        JR      Z,DODEL         ; Yes - Process it
        LD      A,(NULFLG)      ; Get null flag
        OR      A               ; Test null flag status
        JR      Z,PROCES        ; Reset - Process character
        LD      A,0             ; Set a null
        CALL    OUTC            ; Output null
        XOR     A               ; Clear A
        LD      (NULFLG),A      ; Reset null flag
PROCES: LD      A,C             ; Get character
        CP      CTRLG           ; <CTRL-G> Bell?
        JR      Z,PUTCTL        ; Yes - Save it
        CP      CTRLC           ; Is it <CTRL-C> (BREAK)?
        CALL    Z,PRNTCR        ; Yes - Output CRLF
        CP	ESC		; <ESCAPE>?
        CALL	Z,PRNTCR	; Yes - Output CRLF
        SCF                     ; Flag break
        RET     Z               ; Return if <CTRL-C> or <ESC>
        CP      CR              ; Is it <Enter> key?
        JP      Z,TENDIN        ; Yes - Terminate input
        CP      CTRLU           ; Is it <CTRL-U>?
        JR      Z,KILIN         ; Yes - Get another line
        CP      '@'             ; Is it "@" <Kill line>?
        JR      Z,OTKLN         ; Yes - Kill line
        CP      BKSP            ; Is it <Backspace>?
        JR      Z,DELCHR        ; Yes - Delete character
        CP      CTRLR           ; Is it <CTRL-R>?
        JR      NZ,PUTBUF       ; No - Put in buffer
        PUSH    BC              ; Save buffer length
        PUSH    DE              ; Save DE
        PUSH    HL              ; Save buffer address
        LD      (HL),0          ; Mark end of buffer
        CALL    OUTC		; OUTPUT THE CHARACTER
        CALL	PRNTCR		; PRINT CR,LF
        LD      HL,INBUFF       ; Point to buffer start
        CALL    PRS             ; Output buffer
        POP     HL              ; Restore buffer address
        POP     DE              ; Restore DE
        POP     BC              ; Restore buffer length
        JR      MORINP          ; Get another character
TENDIN  LD	(HL),0		; Terminate buffer end
	LD	HL,INBUFF-1	; Reset pointer
	JP	PRNTCR		; Print CRLF and do nulls, RETurn      
;------------------------------------------------------------------------------
; BUFFER
;------------------------------------------------------------------------------
PUTBUF: CP      $20             ; Is it a control code?
        JR      C,MORINP        ; Yes - Ignore
PUTCTL: LD      A,B             ; Get number of bytes in buffer
        CP      81              ; Test for line overflow
        LD      A,CTRLG         ; Set a bell
        JR      NC,OUTNBS       ; Ring bell if buffer full
        LD      A,C             ; Get character
        LD      (HL),C          ; Save in buffer
        LD      (LSTBIN),A      ; Save last input byte
        INC     HL              ; Move up buffer
        INC     B               ; Increment length
OUTIT:  CALL    OUTC            ; Output the character entered
        JR      MORINP          ; Get another character

OUTNBS: CALL    OUTC            ; Output bell and back over it
        LD      A,BKSP          ; Set back space
        JR      OUTIT           ; Output it and get more
;------------------------------------------------------------------------------
CPHLDE: LD      A,H             ; Get H
        SUB     D               ; Compare with D
        RET     NZ              ; Different - Exit
        LD      A,L             ; Get L
        SUB     E               ; Compare with E
        RET                     ; Return status
;------------------------------------------------------------------------------
CHKSYN: LD      A,(HL)          ; Check syntax of character
        EX      (SP),HL         ; Address of test byte
        CP      (HL)            ; Same as in code string?
        INC     HL              ; Return address
        EX      (SP),HL         ; Put it back
        JP      Z,GETCHR        ; Yes - Get next character
        JP      SNERR           ; Different - ?SN Error
;------------------------------------------------------------------------------
; LLIST Command
;------------------------------------------------------------------------------
LLIST:   CALL    AS2HX            ; ASCII number to DE
        RET     NZ              ; Return if anything extra
        POP     BC              ; Rubbish - Not needed
        CALL    SRCHLN          ; Search for line number in DE
        PUSH    BC              ; Save address of line
        CALL    SETLIN          ; Set up lines counter
LLISTLP: POP     HL              ; Restore address of line
        LD      C,(HL)          ; Get LSB of next line
        INC     HL
        LD      B,(HL)          ; Get MSB of next line
        INC     HL
        LD      A,B             ; BC = 0 (End of program)?
        OR      C
        JP      Z,PRNTOK        ; Yes - Go to command mode
        CALL    COUNT           ; Count lines <deleted TSTBRK from next line>

;	RST	18H		; Ck SIO status
	CALL	DSCHKSIO	; Ck SIO status
	JR	NC,LLIST0	; No key, continue
;	RST	10H		; Get the key into A
	CALL	DSCONIN		; Get the key into A
	CP	ESC		; Escape key?
	JR	Z,RSLNBK	; Yes, break
	CP	CTRLC		; <Ctrl-C>
	JR	Z,RSLNBK	; Yes, break
	CP	CTRLS		; Stop scrolling?
	CALL	Z,STALL		; Stall, or continue if no stall

LLIST0   PUSH    BC              ; Save address of next line
        CALL    PRNTCR          ; Output CRLF
        LD      E,(HL)          ; Get LSB of line number
        INC     HL
        LD      D,(HL)          ; Get MSB of line number
        INC     HL
        PUSH    HL              ; Save address of line start
        EX      DE,HL           ; Line number to HL
        CALL    PRNTHL          ; Output line number in decimal
        LD      A,$20           ; Space after line number
        POP     HL              ; Restore start of line address
LSTLP2: CALL    OUTC            ; Output character in A
LSTLP3: LD      A,(HL)          ; Get next byte in line
        OR      A               ; End of line?
        INC     HL              ; To next byte in line
        JR      Z,LLISTLP        ; Yes - get next line
        JP      P,LSTLP2        ; No token - output it
        SUB     ZEND-1          ; Find and output word
        LD      C,A             ; Token offset+1 to C
        LD      DE,WORDS        ; Reserved word list
FNDTOK: LD      A,(DE)          ; Get character in list
        INC     DE              ; Move on to next
        OR      A               ; Is it start of word?
        JP      P,FNDTOK        ; No - Keep looking for word
        DEC     C               ; Count words
        JR      NZ,FNDTOK       ; Not there - keep looking
OUTWRD: AND     01111111B       ; Strip bit 7
        CALL    OUTC            ; Output first character
        LD      A,(DE)          ; Get next character
        INC     DE              ; Move on to next
        OR      A               ; Is it end of word?
        JP      P,OUTWRD        ; No - output the rest
        JR      LSTLP3          ; Next byte in line

SETLIN: PUSH    HL              ; Set up LINES counter
        LD      HL,(LINESN)     ; Get LINES number
        LD      (LINESC),HL     ; Save in LINES counter
        POP     HL
        RET

COUNT:  PUSH    HL              ; Save code string address
        PUSH    DE
        LD      HL,(LINESC)     ; Get LINES counter
        LD      DE,-1
        ADC     HL,DE           ; Decrement
        LD      (LINESC),HL     ; Put it back
        POP     DE
        POP     HL              ; Restore code string address
        RET     P               ; Return if more lines to go
        
        CALL	WAITCR		; Wait for <ENTER> before continuing
        
        PUSH    HL              ; Save code string address
        LD      HL,(LINESN)     ; Get LINES number
        LD      (LINESC),HL     ; Reset LINES counter
        POP     HL              ; Restore code string address
        JR      COUNT           ; Keep on counting

RSLNBK: LD      HL,(LINESN)     ; Get LINES number
        LD      (LINESC),HL     ; Reset LINES counter
        JP      BRKRET          ; Go and output "Break"
;------------------------------------------------------------------------------
; FOR
;------------------------------------------------------------------------------
FOR:    LD      A,64H           ; Flag "FOR" assignment
        LD      (FORFLG),A      ; Save "FOR" flag
        CALL    LET             ; Set up initial index
        POP     BC              ; Drop RETurn address
        PUSH    HL              ; Save code string address
        CALL    DATA            ; Get next statement address
        LD      (LOOPST),HL     ; Save it for start of lo6p
        LD      HL,2            ; Offset for "FOR" block
        ADD     HL,SP           ; Point to it
FORSLP: CALL    LOKFOR          ; Look for existing "FOR" block
        POP     DE              ; Get code string address
        JR      NZ,FORFND       ; No nesting found
        ADD     HL,BC           ; Move into "FOR" block
        PUSH    DE              ; Save code string address
        DEC     HL
        LD      D,(HL)          ; Get MSB of loop statement
        DEC     HL
        LD      E,(HL)          ; Get LSB of loop statement
        INC     HL
        INC     HL
        PUSH    HL              ; Save block address
        LD      HL,(LOOPST)     ; Get address of loop statement
        CALL    CPHLDE          ; Compare the FOR loops
        POP     HL              ; Restore block address
        JR      NZ,FORSLP       ; Different FORs - Find another
        POP     DE              ; Restore code string address
        LD      SP,HL           ; Remove all nested loops

FORFND: EX      DE,HL           ; Code string address to HL
        LD      C,8
        CALL    CHKSTK          ; Check for 8 levels of stack
        PUSH    HL              ; Save code string address
        LD      HL,(LOOPST)     ; Get first statement of loop
        EX      (SP),HL         ; Save and restore code string
        PUSH    HL              ; Re-save code string address
        LD      HL,(LINEAT)     ; Get current line number
        EX      (SP),HL         ; Save and restore code string
        CALL    TSTNUM          ; Make sure it's a number
        CALL    CHKSYN          ; Make sure "TO" is next
        defb   ZTO             ; "TO" token
        CALL    GETNUM          ; Get "TO" expression value
        PUSH    HL              ; Save code string address
        CALL    BCDEFP          ; Move "TO" value to BCDE
        POP     HL              ; Restore code string address
        PUSH    BC              ; Save "TO" value in block
        PUSH    DE
        LD      BC,8100H        ; BCDE - 1 (default STEP)
        LD      D,C             ; C=0
        LD      E,D             ; D=0
        LD      A,(HL)          ; Get next byte in code string
        CP      ZSTEP           ; See if "STEP" is stated
        LD      A,1             ; Sign of step = 1
        JR      NZ,SAVSTP       ; No STEP given - Default to 1
        CALL    GETCHR          ; Jump over "STEP" token
        CALL    GETNUM          ; Get step value
        PUSH    HL              ; Save code string address
        CALL    BCDEFP          ; Move STEP to BCDE
        CALL    TSTSGN          ; Test sign of FPREG
        POP     HL              ; Restore code string address
SAVSTP: PUSH    BC              ; Save the STEP value in block
        PUSH    DE
        PUSH    AF              ; Save sign of STEP
        INC     SP              ; Don't save flags
        PUSH    HL              ; Save code string address
        LD      HL,(BRKLIN)     ; Get address of index variable
        EX      (SP),HL         ; Save and restore code string
PUTFID: LD      B,ZFOR          ; "FOR" block marker
        PUSH    BC              ; Save it
        INC     SP              ; Don't save C
;------------------------------------------------------------------------------
; RUNCNT executes the line of BASIC program at (HL) until (HL)=$00
;------------------------------------------------------------------------------
RUNCNT: CALL    TSTBRK          ; Execution driver - Test break
        LD      (BRKLIN),HL     ; Save code address for break
        LD      A,(HL)          ; Get next byte in code string
        CP      $3A             ; Multi statement line ":" ?
        JR      Z,EXCUTE        ; Yes - Execute it
        OR      A               ; End of line?
        JP      NZ,SNERR        ; No - Syntax error
        INC     HL              ; Point to address of next line
        LD      A,(HL)          ; Get LSB of line pointer
        INC     HL
        OR      (HL)            ; Is it zero (End of prog)?
        JP      Z,ENDPRG        ; Yes - Terminate execution
        INC     HL              ; Point to line number
        LD      E,(HL)          ; Get LSB of line number
        INC     HL
        LD      D,(HL)          ; Get MSB of line number
        EX      DE,HL           ; Line number to HL
        LD      (LINEAT),HL     ; Save as current line number
        EX      DE,HL           ; Line number back to DE
EXCUTE: CALL    GETCHR          ; Get key word
        LD      DE,RUNCNT       ; Where to RETurn to
        PUSH    DE              ; Save for RETurn
IFJMP:  RET     Z               ; Go to RUNCNT if end of STMT
ONJMP:  SUB     ZEND            ; Is it a token?
        JP      C,LET           ; No - try to assign it
        CP      ZNEW+1-ZEND     ; END to NEW ?
        JP      NC,SNERR        ; Not a key word - ?SN Error
        RLCA                    ; Double it
        LD      C,A             ; BC = Offset into table
        LD      B,0
        EX      DE,HL           ; Save code string address
        LD      HL,WORDTB       ; Keyword address table
        ADD     HL,BC           ; Point to routine address
        LD      C,(HL)          ; Get LSB of routine address
        INC     HL
        LD      B,(HL)          ; Get MSB of routine address
        PUSH    BC              ; Save routine address
        EX      DE,HL           ; Restore code string address
;------------------------------------------------------------------------------
; Gets a character from (HL) checks for ASCII numbers
;  RETURNS: Char A 
;  NC if char is ;<=>?@ A-z
;  CY is set if 0-9
;------------------------------------------------------------------------------
GETCHR: INC     HL              ; Point to next character
        LD      A,(HL)          ; Get next code string byte
        CP      $3A             ; Z if ":", RETurn if alpha
        RET     NC              ; NC if > "9"
        CP      $20		; Is it a space
        JR      Z,GETCHR        ; Skip over and get next
        CP      $30		; "0"
        CCF                     ; NC if < "0" (i.e. "*", CY set if 0 thru 9
        INC     A               ; Test for zero without disturbing CY
        DEC     A               ; Z if Null character $00
        RET
;------------------------------------------------------------------------------
; Convert "$nnnn" to FPREG
; Gets a character from (HL) checks for Hexadecimal ASCII numbers "$nnnn"
; Char is in A, NC if char is ;<=>?@ A-z, CY is set if 0-9
;------------------------------------------------------------------------------
HEXTFP	EX	DE,HL		; Move code string pointer to DE
	LD	HL,$0000	; Zero out the value
	CALL	GETHEX		; Check the number for valid hex
	JP	C,HXERR		; First value wasn't hex, HX error
	JR	HEXLP1		; Convert first character
HEXLP	CALL	GETHEX		; Get second and addtional characters
	JR	C,HEXIT		; Exit if not a hex character
HEXLP1	ADD	HL,HL		; Rotate 4 bits to the left
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	OR	L		; Add in D0-D3 into L
	LD	L,A		; Save new value
	JR	HEXLP		; And continue until all hex characters are in

GETHEX	INC	DE		; Next location
	LD	A,(DE)		; Load character at pointer
	SUB	$30		; Get absolute value
	RET	C		; < "0", error
	CP	$0A
	JR	C,NOSUB7	; Is already in the range 0-9
	SUB	$07		; Reduce to A-F
	CP	$0A		; Value should be $0A-$0F at this point
	RET	C		; CY set if was : ; < = > ? @
NOSUB7	CP	$10		; > Greater than "F"?
	CCF
	RET			; CY set if it wasn't valid hex
		
HEXIT	EX	DE,HL		; Value into DE, Code string into HL
	LD	A,D		; Load DE into AC
	LD	C,E		; For prep to
	PUSH	HL		; Store Code String Address
	CALL	ACPASS		; ACPASS to set AC as integer into FPREG
	POP	HL		; Restore Code String Address
	RET			; Finish up
;------------------------------------------------------------------------------	
; RESTORE command
;------------------------------------------------------------------------------
RESTOR: EX      DE,HL           ; Save code string address
        LD      HL,(BASTXT)     ; Point to start of program
        JR      Z,RESTNL        ; Just RESTORE - reset pointer
        EX      DE,HL           ; Restore code string address
        CALL    AS2HX            ; Get line number to DE
        PUSH    HL              ; Save code string address
        CALL    SRCHLN          ; Search for line number in DE
        LD      H,B             ; HL = Address of line
        LD      L,C
        POP     DE              ; Restore code string address
        JP      NC,ULERR        ; ?UL Error if not found
RESTNL: DEC     HL              ; Byte before DATA statement
UPDATA: LD      (NXTDAT),HL     ; Update DATA pointer
        EX      DE,HL           ; Restore code string address
        RET
;------------------------------------------------------------------------------
; Check for BREAK during RUN or LLIST, process Scroll Controls <Ctrl-S>,<Ctrl-Q>
;------------------------------------------------------------------------------
TSTBRK	CALL	DSCHKSIO	; Ck SIO status
	RET	NC		; No key, go back
	CALL	DSCONIN		; Get the key into A
	CP	ESC		; Escape key?
	JR	Z,BRK		; Yes, break
	CP	CTRLC		; <Ctrl-C>
	JR	Z,BRK		; Yes, break
	CP	ESC		; <ESC>
	JR	Z,BRK		; Yes, break
	CP	CTRLS		; Stop scrolling?
	RET	NZ		; Other key, ignore
	
STALL	CALL	DSCONIN		; Wait for key
	CP	CTRLQ		; Resume scrolling?
	RET	Z		; Release the chokehold
	CP	ESC		; Second break?
	JR	Z,STOP		; Break during hold exits prog
	CP	CTRLC		; Second break?
	JR	Z,STOP		; Break during hold exits prog
	JR	STALL		; Loop until <Ctrl-Q> or <brk>

BRK	LD	A,$FF		; Set BRKFLG
	LD	(BRKFLG),A	; Store it
STOP	RET	NZ		; Exit if anything else
	defb	$F6		; Skip "Load (BRKLIN),HL
PEND	RET	NZ		; Exit if anything else
	LD	(BRKLIN),HL	; Current line for Break
	defb	$21		; Skip "OR $FF"
INPBRK	OR	$FF		; Set flags for "Break" status
	POP	BC		; Lose the RETurn
ENDPRG  LD      HL,(LINEAT)     ; Get current line number
        PUSH    AF              ; Save STOP / END status
        LD      A,L             ; Is it direct break?
        AND     H		; If HL=$FFFF break during direct mode
        INC     A               ; Line number is -1 if direct break
        JR      Z,NOLIN         ; Yes - No line number
        LD      (ERRLIN),HL     ; Save line of break
        LD      HL,(BRKLIN)     ; Get point of break
        LD      (CONTAD),HL     ; Save point to CONTinue
NOLIN   XOR     A
        LD      (CTLOFG),A      ; Enable output
        CALL    STTLIN          ; Start a new line
        POP     AF              ; Restore STOP / END status
        LD      HL,BRKMSG       ; "Break" message
        JP      NZ,ERRIN        ; "in line" wanted?
        JP      PRNTOK          ; Go to command mode
;------------------------------------------------------------------------------
; CONTinue
;------------------------------------------------------------------------------
CONT:   LD      HL,(CONTAD)     ; Get CONTinue address
        LD      A,H             ; Is it zero?
        OR      L
        LD      E,CN            ; ?CN Error
        JP      Z,ERROR         ; Yes - output "?CN Error"
        EX      DE,HL           ; Save code string address
        LD      HL,(ERRLIN)     ; Get line of last break
        LD      (LINEAT),HL     ; Set up current line number
        EX      DE,HL           ; Restore code string address
        RET                     ; CONTinue where left off
;------------------------------------------------------------------------------
; NULL sets number of nulls to generate after PRNTCR
;------------------------------------------------------------------------------
NULL:   CALL    GETINT          ; Get integer 0-255
        RET     NZ              ; Return if bad value
        LD      (NULLS),A       ; Set nulls number
        RET
;------------------------------------------------------------------------------
; Gets Character at (HL) and verifies it is Alpha
;------------------------------------------------------------------------------
CHKLTR: LD      A,(HL)          ; Get byte
        CP      'A'             ; < "A" ?
        RET     C               ; Carry set if not letter
        CP      'Z'+1           ; > "Z" ?
        CCF
        RET                     ; Carry set if not letter
;------------------------------------------------------------------------------
; Converts FPreg to INTeger
;------------------------------------------------------------------------------
FPSINT: CALL    GETCHR          ; Get next character
POSINT: CALL    GETNUM          ; Get integer 0 to 32767
DEPINT: CALL    TSTSGN          ; Test sign of FPREG
        JP      M,FCERR         ; Negative - ?FC Error
DEINT:  LD      A,(FPEXP)       ; Get integer value to DE
        CP      80H+16          ; Exponent in range (16 bits)?
        JP      C,FPINT         ; Yes - convert it
        LD      BC,9080H        ; BCDE = -32768, 16-bit integer 
        LD      DE,0000
        PUSH    HL              ; Save code string address
        CALL    CMPNUM          ; Compare FPREG with BCDE
        POP     HL              ; Restore code string address
        LD      D,C             ; MSB to D
        RET     Z               ; Return if in range
FCERR:  LD      E,FC            ; ?FC Error
        JP      ERROR           ; Output error-
;------------------------------------------------------------------------------
; Converts ASCII number to DE integer binary
; Used to process Line Numbers from BASIC text
;------------------------------------------------------------------------------
AS2HX:   DEC     HL              ; ASCII number to DE binary
GETLN:  LD      DE,0            ; Get number to DE
GTLNLP: CALL    GETCHR          ; Get next character
        RET     NC              ; Exit if not a digit
        PUSH    HL              ; Save code string address
        PUSH    AF              ; Save digit
        LD      HL,65529/10     ; Largest number 65529
        CALL    CPHLDE          ; Number in range?
        JP      C,SNERR         ; No - ?SN Error
        LD      H,D             ; HL = Number
        LD      L,E
        ADD     HL,DE           ; Times 2
        ADD     HL,HL           ; Times 4
        ADD     HL,DE           ; Times 5
        ADD     HL,HL           ; Times 10
        POP     AF              ; Restore digit
        SUB     $30             ; Make it 0 to 9
        LD      E,A             ; DE = Value of digit
        LD      D,0
        ADD     HL,DE           ; Add to number
        EX      DE,HL           ; Number to DE
        POP     HL              ; Restore code string address
        JR      GTLNLP          ; Go to next character
;------------------------------------------------------------------------------
; CLEAR
;------------------------------------------------------------------------------
CLEAR:  JP      Z,INTVAR        ; Just "CLEAR" Keep parameters
        CALL    POSINT          ; Get integer 0 to 32767 to DE
        DEC     HL              ; Cancel increment
        CALL    GETCHR          ; Get next character
        PUSH    HL              ; Save code string address
        LD      HL,(LSTRAM)     ; Get end of RAM
        JR      Z,STORED        ; No value given - Use stored
        POP     HL              ; Restore code string address
        CALL    CHKSYN          ; Check for comma
        defb   ','
        PUSH    DE              ; Save number
        CALL    POSINT          ; Get integer 0 to 32767
        DEC     HL              ; Cancel increment
        CALL    GETCHR          ; Get next character
        JP      NZ,SNERR        ; ?SN Error if more on line
        EX      (SP),HL         ; Save code string address
        EX      DE,HL           ; Number to DE
STORED: LD      A,L             ; Get LSB of new RAM top
        SUB     E               ; Subtract LSB of string space
        LD      E,A             ; Save LSB
        LD      A,H             ; Get MSB of new RAM top
        SBC     A,D             ; Subtract MSB of string space
        LD      D,A             ; Save MSB
        JP      C,OMERR         ; ?OM Error if not enough mem
        PUSH    HL              ; Save RAM top
        LD      HL,(PROGND)     ; Get program end
        LD      BC,40           ; 40 Bytes minimum working RAM
        ADD     HL,BC           ; Get lowest address
        CALL    CPHLDE          ; Enough memory?
        JP      NC,OMERR        ; No - ?OM Error
        EX      DE,HL           ; RAM top to HL
        LD      (STRSPC),HL     ; Set new string space
        POP     HL              ; End of memory to use
        LD      (LSTRAM),HL     ; Set new top of RAM
        POP     HL              ; Restore code string address
        JP      INTVAR          ; Initialise variables
;------------------------------------------------------------------------------
; Program RUN
;------------------------------------------------------------------------------
RUN:    JP      Z,RUNFST        ; RUN from start if just RUN
        CALL    INTVAR          ; Initialise variables
        LD      BC,RUNCNT       ; Execution driver loop
        JR      RUNLIN          ; RUN from line number
;------------------------------------------------------------------------------
; GOSUB
;------------------------------------------------------------------------------
GOSUB:  LD      C,3             ; 3 Levels of stack needed
        CALL    CHKSTK          ; Check for 3 levels of stack
        POP     BC              ; Get return address
        PUSH    HL              ; Save code string for RETURN
        PUSH    HL              ; And for GOSUB routine
        LD      HL,(LINEAT)     ; Get current line
        EX      (SP),HL         ; Into stack - Code string out
        LD      A,ZGOSUB        ; "GOSUB" token
        PUSH    AF              ; Save token
        INC     SP              ; Don't save flags
;------------------------------------------------------------------------------
; RUN LINE NUMBER
;------------------------------------------------------------------------------
RUNLIN: PUSH    BC              ; Save return address
;------------------------------------------------------------------------------
; GOTO
;------------------------------------------------------------------------------
GOTO:   CALL    AS2HX            ; ASCII number to DE binary
        CALL    REM             ; Get end of line
        PUSH    HL              ; Save end of line
        LD      HL,(LINEAT)     ; Get current line
        CALL    CPHLDE          ; Line after current?
        POP     HL              ; Restore end of line
        INC     HL              ; Start of next line
        CALL    C,SRCHLP        ; Line is after current line
        CALL    NC,SRCHLN       ; Line is before current line
        LD      H,B             ; Set up code string address
        LD      L,C
        DEC     HL              ; Incremented after
        RET     C               ; Line found
ULERR:  LD      E,UL            ; ?UL Error - Undefined Line number
        JP      ERROR           ; Output error message
;------------------------------------------------------------------------------
; RETURN
;------------------------------------------------------------------------------
RETURN: RET     NZ              ; Return if not just RETURN
        LD      D,-1            ; Flag "GOSUB" search
        CALL    BAKSTK          ; Look "GOSUB" block
        LD      SP,HL           ; Kill all FORs in subroutine
        CP      ZGOSUB          ; Test for "GOSUB" token
        LD      E,RG            ; ?RG Error
        JP      NZ,ERROR        ; Error if no "GOSUB" found
        POP     HL              ; Get RETURN line number
        LD      (LINEAT),HL     ; Save as current
        INC     HL              ; Was it from direct statement?
        LD      A,H
        OR      L               ; Return to line
        JP      NZ,RETLIN       ; No - Return to line
        LD      A,(LSTBIN)      ; Any INPUT in subroutine?
        OR      A               ; If so buffer is corrupted
        JP      NZ,POPNOK       ; Yes - Go to command mode
RETLIN: LD      HL,RUNCNT       ; Execution driver loop
        EX      (SP),HL         ; Into stack - Code string out
        defb     3EH             ; Skip "POP HL"
NXTDTA: POP     HL              ; Restore code string address
;------------------------------------------------------------------------------
; DATA/REM
;------------------------------------------------------------------------------
DATA:   defb   $01,$3A         ; ":" End of statement
REM:    LD      C,0             ; 00  End of statement
        LD      B,0
NXTSTL: LD      A,C             ; Statement and byte
        LD      C,B
        LD      B,A             ; Statement end byte
NXTSTT: LD      A,(HL)          ; Get byte
        OR      A               ; End of line?
        RET     Z               ; Yes - Exit
        CP      B               ; End of statement?
        RET     Z               ; Yes - Exit
        INC     HL              ; Next byte
        CP      $22             ; Literal string?
        JR      Z,NXTSTL        ; Yes - Look for another '"'
        JR      NXTSTT          ; Keep looking
;------------------------------------------------------------------------------
; ASSIGN A VARIABLE
;------------------------------------------------------------------------------
LET:    CALL    GETVAR          ; Get variable name
        CALL    CHKSYN          ; Make sure "=" follows
        defb   ZEQUAL          ; "=" token
        PUSH    DE              ; Save address of variable
        LD      A,(TYPE)        ; Get data type
        PUSH    AF              ; Save type
        CALL    EVAL            ; Evaluate expression
        POP     AF              ; Restore type
        EX      (SP),HL         ; Save code - Get var addr
        LD      (BRKLIN),HL     ; Save address of variable
        RRA                     ; Adjust type
        CALL    CHKTYP          ; Check types are the same
        JR      Z,LETNUM        ; Numeric - Move value
LETSTR: PUSH    HL              ; Save address of string var
        LD      HL,(FPREG)      ; Pointer to string entry
        PUSH    HL              ; Save it on stack
        INC     HL              ; Skip over length
        INC     HL
        LD      E,(HL)          ; LSB of string address
        INC     HL
        LD      D,(HL)          ; MSB of string address
        LD      HL,(BASTXT)     ; Point to start of program
        CALL    CPHLDE          ; Is string before program?
        JR      NC,CRESTR       ; Yes - Create string entry
        LD      HL,(STRSPC)     ; Point to string space
        CALL    CPHLDE          ; Is string literal in program?
        POP     DE              ; Restore address of string
        JR      NC,MVSTPT       ; Yes - Set up pointer
        LD      HL,TMPSTR       ; Temporary string pool
        CALL    CPHLDE          ; Is string in temporary pool?
        JR      NC,MVSTPT       ; No - Set up pointer
        defb   $3E             ; Skip "POP DE"
CRESTR: POP     DE              ; Restore address of string
        CALL    BAKTMP          ; Back to last tmp-str entry
        EX      DE,HL           ; Address of string entry
        CALL    SAVSTR          ; Save string in string area
MVSTPT: CALL    BAKTMP          ; Back to last tmp-str entry
        POP     HL              ; Get string pointer
        CALL    DETHL4          ; Move string pointer to var
        POP     HL              ; Restore code string address
        RET

LETNUM: PUSH    HL              ; Save address of variable
        CALL    FPTHL           ; Move value to variable
        POP     DE              ; Restore address of variable
        POP     HL              ; Restore code string address
        RET
;------------------------------------------------------------------------------
; ON Gosub/Goto
;------------------------------------------------------------------------------
ON:     CALL    GETINT          ; Get integer 0-255
        LD      A,(HL)          ; Get "GOTO" or "GOSUB" token
        LD      B,A             ; Save in B
        CP      ZGOSUB          ; "GOSUB" token?
        JR      Z,ONGO          ; Yes - Find line number
        CALL    CHKSYN          ; Make sure it's "GOTO"
        defb   ZGOTO           ; "GOTO" token
        DEC     HL              ; Cancel increment
ONGO:   LD      C,E             ; Integer of branch value
ONGOLP: DEC     C               ; Count branches
        LD      A,B             ; Get "GOTO" or "GOSUB" token
        JP      Z,ONJMP         ; Go to that line if right one
        CALL    GETLN           ; Get line number to DE
        CP      ','             ; Another line number?
        RET     NZ              ; No - Drop through
        JR      ONGOLP          ; Yes - loop
;------------------------------------------------------------------------------
; IF/THEN
;------------------------------------------------------------------------------
IFT:     CALL    EVAL            ; Evaluate expression
        LD      A,(HL)          ; Get token
        CP      ZGOTO           ; "GOTO" token?
        JR      Z,IFTGO          ; Yes - Get line
        CALL    CHKSYN          ; Make sure it's "THEN"
        defb   ZTHEN           ; "THEN" token
        DEC     HL              ; Cancel increment
IFTGO:   CALL    TSTNUM          ; Make sure it's numeric
        CALL    TSTSGN          ; Test state of expression
        JP      Z,REM           ; False - Drop through
        CALL    GETCHR          ; Get next character
        JP      C,GOTO          ; Number - GOTO that line
        JP      IFJMP           ; Otherwise do statement
;------------------------------------------------------------------------------
; PRINTing routines
;------------------------------------------------------------------------------
MRPRNT: DEC     HL              ; DEC 'cos GETCHR INCs
        CALL    GETCHR          ; Get next character
PRINT:  JP      Z,PRNTCR        ; CRLF if just PRINT
PRNTLP: RET     Z               ; End of list - Exit
        CP      ZTAB            ; "TAB(" token?
        JP      Z,DOTAB         ; Yes - Do TAB routine
        CP      ZSPC            ; "SPC(" token?
        JP      Z,DOTAB         ; Yes - Do SPC routine
        PUSH    HL              ; Save code string address
        CP      ','             ; Comma?
        JP      Z,DOCOM         ; Yes - Move to next zone
        CP      $3B             ; Semi-colon?
        JP      Z,NEXITM        ; Do semi-colon routine
        POP     BC              ; Code string address to BC
        CALL    EVAL            ; Evaluate expression
        PUSH    HL              ; Save code string address
        LD      A,(TYPE)        ; Get variable type
        OR      A               ; Is it a string variable?
        JR      NZ,PRNTST       ; Yes - Output string contents
        CALL    NUMASC          ; Convert number to text
        CALL    CRTST           ; Create temporary string
        LD      (HL),$20        ; Followed by a space
        LD      HL,(FPREG)      ; Get length of output
        INC     (HL)            ; Plus 1 for the space
        LD      HL,(FPREG)      ; < Not needed >
        LD      A,(LWIDTH)      ; Get width of line
        LD      B,A             ; To B
        INC     B               ; Width 255 (No limit)?
        JR      Z,PRNTNB        ; Yes - Output number string
        INC     B               ; Adjust it
        LD      A,(CURPOS)      ; Get cursor position
        ADD     A,(HL)          ; Add length of string
        DEC     A               ; Adjust it
        CP      B               ; Will output fit on this line?
        CALL    NC,PRNTCR       ; No - CRLF first
PRNTNB: CALL    PRS1            ; Output string at (HL)
        XOR     A               ; Skip CALL by setting "Z" flag
PRNTST: CALL    NZ,PRS1         ; Output string at (HL)
        POP     HL              ; Restore code string address
        JP      MRPRNT          ; See if more to PRINT
;------------------------------------------------------------------------------
; PRINT A NEW LINE
;------------------------------------------------------------------------------
STTLIN: LD      A,(CURPOS)      ; Make sure on new line
        OR      A               ; Already at start?
        RET     Z               ; Yes - Do nothing
        JR      PRNTCR          ; Start a new line
;------------------------------------------------------------------------------
ENDINP: LD      (HL),0          ; Mark end of buffer
        LD      HL,BUFFER-1     ; Point to buffer
PRNTCR: LD      A,CR            ; Load a CR
        CALL    OUTC            ; Output character
        LD	A,LF		; Load a LF
	CALL	OUTC		; Output character
DONULL: XOR     A               ; Set to position 0
        LD      (CURPOS),A      ; Store it
        LD      A,(NULLS)       ; Get number of nulls
NULLP:  DEC     A               ; Count them
        RET     Z               ; Return if done
        PUSH    AF              ; Save count
        XOR     A               ; Load a null
        CALL    OUTC            ; Output it
        POP     AF              ; Restore count
        JR      NULLP           ; Keep counting
;------------------------------------------------------------------------------
; PROCESS COMMA FOR SPACING
;------------------------------------------------------------------------------
DOCOM:  LD      A,(LWIDTH)      ; Get terminal width
        LD      B,A             ; Save in B
        LD      A,(CURPOS)      ; Get current position
        LD	C,A		; Save in C
        LD	A,(COMMAN)	; Get comma width
        ADD	A,C		; Add to current cursor location
        CP      B               ; Within the terminal width limit?
        CALL    NC,PRNTCR       ; Beyond limit - output CRLF
        JR      NC,NEXITM       ; Get next item
ZONELP: SUB     5               ; Next zone of 5 characters
        JR      NC,ZONELP       ; Repeat if more zones
        CPL                     ; Number of spaces to output
        JR      ASPCS           ; Output them
;------------------------------------------------------------------------------
; PROCESS "TAB(X)" FOR SPACING
;------------------------------------------------------------------------------
DOTAB:  PUSH    AF              ; Save token
        CALL    FNDNUM          ; Evaluate expression
        CALL    CHKSYN          ; Make sure ")" follows
        defb   ")"
        DEC     HL              ; Back space on to ")"
        POP     AF              ; Restore token
        SUB     ZSPC            ; Was it "SPC(" ?
        PUSH    HL              ; Save code string address
        JR      Z,DOSPC         ; Yes - Do "E" spaces
        LD      A,(CURPOS)      ; Get current position
DOSPC:  CPL                     ; Number of spaces to print to
        ADD     A,E             ; Total number to print
        JR      NC,NEXITM       ; TAB < Current POS(X)
ASPCS:  INC     A               ; Output A spaces
        LD      B,A             ; Save number to print
        LD      A,$20           ; Space
SPCLP:  CALL    OUTC            ; Output character in A
        DEC     B               ; Count them
        JR      NZ,SPCLP        ; Repeat if more
NEXITM: POP     HL              ; Restore code string address
        CALL    GETCHR          ; Get next character
        JP      PRNTLP          ; More to print
;------------------------------------------------------------------------------
; INPUT
;------------------------------------------------------------------------------
INPUT:  CALL    IDTEST          ; Test for illegal direct
        LD      A,(HL)          ; Get character after "INPUT"
        CP      $22             ; Is there a prompt string?
        LD      A,0             ; Clear A and leave flags
        LD      (CTLOFG),A      ; Enable output
        JR      NZ,NOPMPT       ; No prompt - get input
        CALL    QTSTR           ; Get string terminated by '"'
        CALL    CHKSYN          ; Check for ";" after prompt
        defb	$3B		; SEMI COLON
        PUSH    HL              ; Save code string address
        CALL    PRS1            ; Output prompt string
        defb   $3E             ; Skip "PUSH HL"
NOPMPT: PUSH    HL              ; Save code string address
        CALL    PROMPT          ; Get input with "? " prompt
        POP     BC              ; Restore code string address
        JP      C,INPBRK        ; Break pressed - Exit
        INC     HL              ; Next byte
        LD      A,(HL)          ; Get it
        OR      A               ; End of line?
        DEC     HL              ; Back again
        PUSH    BC              ; Re-save code string address
        JP      Z,NXTDTA        ; Yes - Find next DATA stmt
        LD      (HL),','        ; Store comma as separator
        JP      NXTITM          ; Get next item
;------------------------------------------------------------------------------
; LREAD data
;------------------------------------------------------------------------------
LREAD:   PUSH    HL              ; Save code string address
        LD      HL,(NXTDAT)     ; Next DATA statement
        defb   $F6             ; Flag "LREAD"
NXTITM: XOR     A               ; Flag "INPUT"
        LD      (LREADFG),A      ; Save "LREAD"/"INPUT" flag
        EX      (SP),HL         ; Get code str' , Save pointer
        JR      GTVLUS          ; Get values

NEDMOR: CALL    CHKSYN          ; Check for comma between items
        defb   ','
GTVLUS: CALL    GETVAR          ; Get variable name
        EX      (SP),HL         ; Save code str" , Get pointer
        PUSH    DE              ; Save variable address
        LD      A,(HL)          ; Get next "INPUT"/"DATA" byte
        CP      ','             ; Comma?
        JR      Z,ANTVLU        ; Yes - Get another value
        LD      A,(LREADFG)      ; Is it LREAD?
        OR      A
        JP      NZ,FDTLP        ; Yes - Find next DATA stmt
        LD      A,'?'           ; More INPUT needed
        CALL    OUTC            ; Output character
        CALL    PROMPT          ; Get INPUT with prompt
        POP     DE              ; Variable address
        POP     BC              ; Code string address
        JP      C,INPBRK        ; Break pressed
        INC     HL              ; Point to next DATA byte
        LD      A,(HL)          ; Get byte
        OR      A               ; Is it zero (No input) ?
        DEC     HL              ; Back space INPUT pointer
        PUSH    BC              ; Save code string address
        JP      Z,NXTDTA        ; Find end of buffer
        PUSH    DE              ; Save variable address
ANTVLU: LD      A,(TYPE)        ; Check data type
        OR      A               ; Is it numeric?
        JR      Z,INPBIN        ; Yes - Convert to binary
        CALL    GETCHR          ; Get next character
        LD      D,A             ; Save input character
        LD      B,A             ; Again
        CP      $22             ; Start of literal sting?
        JR      Z,STRENT        ; Yes - Create string entry
        LD      A,(LREADFG)      ; "LREAD" or "INPUT" ?
        OR      A
        LD      D,A             ; Save 00 if "INPUT"
        JR      Z,ITMSEP        ; "INPUT" - End with 00
        LD      D,$3A           ; "DATA" - End with 00 or ":"
ITMSEP: LD      B,','           ; Item separator
        DEC     HL              ; Back space for DTSTR
STRENT: CALL    DTSTR           ; Get string terminated by D
        EX      DE,HL           ; String address to DE
        LD      HL,LTSTND       ; Where to go after LETSTR
        EX      (SP),HL         ; Save HL , get input pointer
        PUSH    DE              ; Save address of string
        JP      LETSTR          ; Assign string to variable

INPBIN: CALL    GETCHR          ; Get next character
        CALL    ASCTFP          ; Convert ASCII to FP number
        EX      (SP),HL         ; Save input ptr, Get var addr
        CALL    FPTHL           ; Move FPREG to variable
        POP     HL              ; Restore input pointer
LTSTND: DEC     HL              ; DEC 'cos GETCHR INCs
        CALL    GETCHR          ; Get next character
        JR      Z,MORDT         ; End of line - More needed?
        CP      ','             ; Another value?
        JP      NZ,BADINP       ; No - Bad input
MORDT:  EX      (SP),HL         ; Get code string address
        DEC     HL              ; DEC 'cos GETCHR INCs
        CALL    GETCHR          ; Get next character
        JR      NZ,NEDMOR       ; More needed - Get it
        POP     DE              ; Restore DATA pointer
        LD      A,(LREADFG)      ; "LREAD" or "INPUT" ?
        OR      A
        EX      DE,HL           ; DATA pointer to HL
        JP      NZ,UPDATA       ; Update DATA pointer if "LREAD"
        PUSH    DE              ; Save code string address
        OR      (HL)            ; More input given?
        LD      HL,EXTIG        ; "?Extra ignored" message
        CALL    NZ,PRS          ; Output string if extra given
        POP     HL              ; Restore code string address
        RET
FDTLP:  CALL    DATA            ; Get next statement
        OR      A               ; End of line?
        JR      NZ,FANDT        ; No - See if DATA statement
        INC     HL
        LD      A,(HL)          ; End of program?
        INC     HL
        OR      (HL)            ; 00 00 Ends program
        LD      E,OD            ; ?OD Error
        JP      Z,ERROR         ; Yes - Out of DATA
        INC     HL
        LD      E,(HL)          ; LSB of line number
        INC     HL
        LD      D,(HL)          ; MSB of line number
        EX      DE,HL
        LD      (DATLIN),HL     ; Set line of current DATA item
        EX      DE,HL
FANDT:  CALL    GETCHR          ; Get next character
        CP      ZDATA           ; "DATA" token
        JR      NZ,FDTLP        ; No "DATA" - Keep looking
        JR      ANTVLU          ; Found - Convert input

BADINP: LD      A,(LREADFG)      ; LREAD or INPUT?
        OR      A
        JP      NZ,DATSNR       ; LREAD - ? Data Syntax Error
        POP     BC              ; Throw away code string addr
        LD      HL,REDO         ; "Redo from start" message
        CALL    PRS             ; Output string
        JP      DOAGN           ; Do last INPUT again
;------------------------------------------------------------------------------
; NEXT
;------------------------------------------------------------------------------
NEXT:   LD      DE,0            ; In case no index given
NEXT1:  CALL    NZ,GETVAR       ; Get index address
        LD      (BRKLIN),HL     ; Save code string address
        CALL    BAKSTK          ; Look for "FOR" block
        JP      NZ,NFERR        ; No "FOR" - "Next without FOR" Error
        LD      SP,HL           ; Clear nested loops
        PUSH    DE              ; Save index address
        LD      A,(HL)          ; Get sign of STEP
        INC     HL
        PUSH    AF              ; Save sign of STEP
        PUSH    DE              ; Save index address
        CALL    PHLTFP          ; Move index value to FPREG
        EX      (SP),HL         ; Save address of TO value
        PUSH    HL              ; Save address of index
        CALL    ADDPHL          ; Add STEP to index value
        POP     HL              ; Restore address of index
        CALL    FPTHL           ; Move value to index variable
        POP     HL              ; Restore address of TO value
        CALL    LOADFP          ; Move TO value to BCDE
        PUSH    HL              ; Save address of line of FOR
        CALL    CMPNUM          ; Compare index with TO value
        POP     HL              ; Restore address of line num
        POP     BC              ; Address of sign of STEP
        SUB     B               ; Compare with expected sign
        CALL    LOADFP          ; BC = Loop stmt,DE = Line num
        JP      Z,KILFOR        ; Loop finished - Terminate it
        EX      DE,HL           ; Loop statement line number
        LD      (LINEAT),HL     ; Set loop line number
        LD      L,C             ; Set code string to loop
        LD      H,B
        JP      PUTFID          ; Put back "FOR" and continue

KILFOR: LD      SP,HL           ; Remove "FOR" block
        LD      HL,(BRKLIN)     ; Code string after "NEXT"
        LD      A,(HL)          ; Get next byte in code string
        CP      ','             ; More NEXTs ?
        JP      NZ,RUNCNT       ; No - Do next statement
        CALL    GETCHR          ; Position to index name
        JR      NEXT1           ; Re-enter NEXT routine
;------------------------------------------------------------------------------
; Evaluate and Process variable/math functions
;------------------------------------------------------------------------------
GETNUM: CALL    EVAL            ; Get a numeric expression
TSTNUM: defb   $F6             ; Clear carry (numeric)
TSTSTR: SCF                     ; Set carry (string)
CHKTYP: LD      A,(TYPE)        ; Check types match
        ADC     A,A             ; Expected + actual
        OR      A               ; Clear carry , set parity
        RET     PE              ; Even parity - Types match
        JP      TMERR           ; Different types - Error

OPNPAR: CALL    CHKSYN          ; Make sure "(" follows
        defb   '('
EVAL:   DEC     HL              ; Evaluate expression & save
        LD      D,0             ; Precedence value
EVAL1:  PUSH    DE              ; Save precedence
        LD      C,1
        CALL    CHKSTK          ; Check for 1 level of stack
        CALL    OPRND           ; Get next expression value
EVAL2:  LD      (NXTOPR),HL     ; Save address of next operator
EVAL3:  LD      HL,(NXTOPR)     ; Restore address of next opr
        POP     BC              ; Precedence value and operator
        LD      A,B             ; Get precedence value
        CP      $78             ; "AND" or "OR" ?
        CALL    NC,TSTNUM       ; No - Make sure it's a number
        LD      A,(HL)          ; Get next operator / function
        LD      D,0             ; Clear Last relation
RLTLP:  SUB     ZGTR            ; ">" Token
        JR      C,FOPRND        ; + - * / ^ AND OR - Test it
        CP      ZLTH+1-ZGTR     ; < = >
        JR      NC,FOPRND       ; Function - Call it
        CP      ZEQUAL-ZGTR     ; "="
        RLA                     ; <- Test for legal
        XOR     D               ; <- combinations of < = >
        CP      D               ; <- by combining last token
        LD      D,A             ; <- with current one
        JP      C,SNERR         ; Error if "<<" "==" or ">>"
        LD      (CUROPR),HL     ; Save address of current token
        CALL    GETCHR          ; Get next character
        JR      RLTLP           ; Treat the two as one

FOPRND: LD      A,D             ; < = > found ?
        OR      A
        JP      NZ,TSTRED       ; Yes - Test for reduction
        LD      A,(HL)          ; Get operator token
        LD      (CUROPR),HL     ; Save operator address
        SUB     ZPLUS           ; Operator or function?
        RET     C               ; Neither - Exit
        CP      ZOR+1-ZPLUS     ; Is it + - * / ^ AND OR ?
        RET     NC              ; No - Exit
        LD      E,A             ; Coded operator
        LD      A,(TYPE)        ; Get data type
        DEC     A               ; FF = numeric , 00 = string
        OR      E               ; Combine with coded operator
        LD      A,E             ; Get coded operator
        JP      Z,CONCAT        ; String concatenation
        RLCA                    ; Times 2
        ADD     A,E             ; Times 3
        LD      E,A             ; To DE (D is 0)
        LD      HL,PRITAB       ; Precedence table
        ADD     HL,DE           ; To the operator concerned
        LD      A,B             ; Last operator precedence
        LD      D,(HL)          ; Get evaluation precedence
        CP      D               ; Compare with eval precedence
        RET     NC              ; Exit if higher precedence
        INC     HL              ; Point to routine address
        CALL    TSTNUM          ; Make sure it's a number

STKTHS: PUSH    BC              ; Save last precedence & token
        LD      BC,EVAL3        ; Where to go on prec' break
        PUSH    BC              ; Save on stack for return
        LD      B,E             ; Save operator
        LD      C,D             ; Save precedence
        CALL    STAKFP          ; Move value to stack
        LD      E,B             ; Restore operator
        LD      D,C             ; Restore precedence
        LD      C,(HL)          ; Get LSB of routine address
        INC     HL
        LD      B,(HL)          ; Get MSB of routine address
        INC     HL
        PUSH    BC              ; Save routine address
        LD      HL,(CUROPR)     ; Address of current operator
        JP      EVAL1           ; Loop until prec' break
;------------------------------------------------------------------------------
; Process Operand
;------------------------------------------------------------------------------
OPRND:  XOR     A               ; Get operand routine
        LD      (TYPE),A        ; Set numeric expected
        CALL    GETCHR          ; Get next character
        LD      E,MO            ; Error - Missing Operand
        JP      Z,ERROR         ; No operand - Error
        JP      C,ASCTFP        ; Number - Get value
        CALL    CHKLTR          ; See if a letter
        JP      NC,CONVAR       ; Letter - Find variable
     	
     	CP	'$'		; Hex number indicated? [function added]
     	JP	Z,HEXTFP	; Convert Hex to FPREG
     
        CP      ZPLUS           ; "+" Token ?
        JR      Z,OPRND         ; Yes - Look for operand
        CP      '.'             ; "." ?
        JP      Z,ASCTFP        ; Yes - Create FP number
        CP      ZMINUS          ; "-" Token ?
        JP      Z,MINUS         ; Yes - Do minus
        CP      $22             ; Literal string ?
        JP      Z,QTSTR         ; Get string terminated by '"'
        CP      ZNOT            ; "NOT" Token ?
        JP      Z,EVNOT         ; Yes - Eval NOT expression
        CP      ZFN             ; "FN" Token ?
        JP      Z,DOFN          ; Yes - Do FN routine
        SUB     ZSGN            ; Is it a function?
        JP      NC,FNOFST       ; Yes - Evaluate function
EVLPAR: CALL    OPNPAR          ; Evaluate expression in "()"
        CALL    CHKSYN          ; Make sure ")" follows
        defb   ')'
        RET

MINUS:  LD      D,7DH           ; "-" precedence
        CALL    EVAL1           ; Evaluate until prec' break
        LD      HL,(NXTOPR)     ; Get next operator address
        PUSH    HL              ; Save next operator address
        CALL    INVSGN          ; Negate value
RETNUM: CALL    TSTNUM          ; Make sure it's a number
        POP     HL              ; Restore next operator address
        RET
;------------------------------------------------------------------------------
; Loads a variable with name at (HL) into FPREG
;------------------------------------------------------------------------------
CONVAR: CALL    GETVAR          ; Get variable address to DE
FRMEVL: PUSH    HL              ; Save code string address
        EX      DE,HL           ; Variable address to HL
        LD      (FPREG),HL      ; Save address of variable
        LD      A,(TYPE)        ; Get type
        OR      A               ; Numeric?
        CALL    Z,PHLTFP        ; Yes - Move contents to FPREG
        POP     HL              ; Restore code string address
        RET

FNOFST: LD      B,0             ; Get address of function
        RLCA                    ; Double function offset
        LD      C,A             ; BC = Offset in function table
        PUSH    BC              ; Save adjusted token value
        CALL    GETCHR          ; Get next character
        LD      A,C             ; Get adjusted token value
        CP      2*(ZPOINT-ZSGN) ; Adjusted "POINT" token?
        JP      Z,POINT         ; Yes - Do "POINT"
        CP      2*(ZLEFT-ZSGN)-1; Adj' LEFT$,RIGHT$ or MID$ ?
        JR      C,FNVAL         ; No - Do function
        CALL    OPNPAR          ; Evaluate expression  (X,...
        CALL    CHKSYN          ; Make sure "," follows
        defb   ','
        CALL    TSTSTR          ; Make sure it's a string
        EX      DE,HL           ; Save code string address
        LD      HL,(FPREG)      ; Get address of string
        EX      (SP),HL         ; Save address of string
        PUSH    HL              ; Save adjusted token value
        EX      DE,HL           ; Restore code string address
        CALL    GETINT          ; Get integer 0-255
        EX      DE,HL           ; Save code string address
        EX      (SP),HL         ; Save integer,HL = adj' token
        JR      GOFUNC          ; Jump to string function

FNVAL:  CALL    EVLPAR          ; Evaluate expression
        EX      (SP),HL         ; HL = Adjusted token value
        LD      DE,RETNUM       ; Return number from function
        PUSH    DE              ; Save on stack
GOFUNC: LD      BC,FNCTAB       ; Function routine addresses
        ADD     HL,BC           ; Point to right address
        LD      C,(HL)          ; Get LSB of address
        INC     HL              ;
        LD      H,(HL)          ; Get MSB of address
        LD      L,C             ; Address to HL
        JP      (HL)            ; Jump to function

SGNEXP: DEC     D               ; Dee to flag negative exponent
        CP      ZMINUS          ; "-" token ?
        RET     Z               ; Yes - Return
        CP      '-'             ; "-" ASCII ?
        RET     Z               ; Yes - Return
        INC     D               ; Inc to flag positive exponent
        CP      '+'             ; "+" ASCII ?
        RET     Z               ; Yes - Return
        CP      ZPLUS           ; "+" token ?
        RET     Z               ; Yes - Return
        DEC     HL              ; DEC 'cos GETCHR INCs
        RET                     ; Return "NZ"
;------------------------------------------------------------------------------
; AND / OR integer FPREG < FPREG (AND/OR) last
;------------------------------------------------------------------------------
POR:    defb   $F6             ; Flag "OR"
PAND:   XOR     A               ; Flag "AND"
        PUSH    AF              ; Save "AND" / "OR" flag
        CALL    TSTNUM          ; Make sure it's a number
        CALL    DEINT           ; Get integer -32768 to 32767
        POP     AF              ; Restore "AND" / "OR" flag
        EX      DE,HL           ; <- Get last
        POP     BC              ; <-  value
        EX      (SP),HL         ; <-  from
        EX      DE,HL           ; <-  stack
        CALL    FPBCDE          ; Move last value to FPREG
        PUSH    AF              ; Save "AND" / "OR" flag
        CALL    DEINT           ; Get integer -32768 to 32767
        POP     AF              ; Restore "AND" / "OR" flag
        POP     BC              ; Get value
        LD      A,C             ; Get LSB
        LD      HL,ACPASS       ; Address of save AC as current
        JR      NZ,POR1         ; Jump if OR
        AND     E               ; "AND" LSBs
        LD      C,A             ; Save LSB
        LD      A,B             ; Get MBS
        AND     D               ; "AND" MSBs
        JP      (HL)            ; Save AC as current (ACPASS)

POR1:   OR      E               ; "OR" LSBs
        LD      C,A             ; Save LSB
        LD      A,B             ; Get MSB
        OR      D               ; "OR" MSBs
        JP      (HL)            ; Save AC as current (ACPASS)
;------------------------------------------------------------------------------
TSTRED  LD      HL,CMPLOG       ; Logical compare routine
        LD      A,(TYPE)        ; Get data type
        RRA                     ; Carry set = string
        LD      A,D             ; Get last precedence value
        RLA                     ; Times 2 plus carry
        LD      E,A             ; To E
        LD      D,64H           ; Relational precedence
        LD      A,B             ; Get current precedence
        CP      D               ; Compare with last
        RET     NC              ; Eval if last was rel' or log'
        JP      STKTHS          ; Stack this one and get next

CMPLOG  defw   CMPLG1          ; Compare two values / strings
CMPLG1  LD      A,C             ; Get data type
        OR      A
        RRA
        POP     BC              ; Get last expression to BCDE
        POP     DE
        PUSH    AF              ; Save status
        CALL    CHKTYP          ; Check that types match
        LD      HL,CMPRES       ; Result to comparison
        PUSH    HL              ; Save for RETurn
        JP      Z,CMPNUM        ; Compare values if numeric
        XOR     A               ; Compare two strings
        LD      (TYPE),A        ; Set type to numeric
        PUSH    DE              ; Save string name
        CALL    GSTRCU          ; Get current string
        LD      A,(HL)          ; Get length of string
        INC     HL
        INC     HL
        LD      C,(HL)          ; Get LSB of address
        INC     HL
        LD      B,(HL)          ; Get MSB of address
        POP     DE              ; Restore string name
        PUSH    BC              ; Save address of string
        PUSH    AF              ; Save length of string
        CALL    GSTRDE          ; Get second string
        CALL    LOADFP          ; Get address of second string
        POP     AF              ; Restore length of string 1
        LD      D,A             ; Length to D
        POP     HL              ; Restore address of string 1
CMPSTR  LD      A,E             ; Bytes of string 2 to do
        OR      D               ; Bytes of string 1 to do
        RET     Z               ; Exit if all bytes compared
        LD      A,D             ; Get bytes of string 1 to do
        SUB     1
        RET     C               ; Exit if end of string 1
        XOR     A
        CP      E               ; Bytes of string 2 to do
        INC     A
        RET     NC              ; Exit if end of string 2
        DEC     D               ; Count bytes in string 1
        DEC     E               ; Count bytes in string 2
        LD      A,(BC)          ; Byte in string 2
        CP      (HL)            ; Compare to byte in string 1
        INC     HL              ; Move up string 1
        INC     BC              ; Move up string 2
        JR      Z,CMPSTR        ; Same - Try next bytes
        CCF                     ; Flag difference (">" or "<")
        JP      FLGDIF          ; "<" gives -1 , ">" gives +1

CMPRES  INC     A               ; Increment current value
        ADC     A,A             ; Double plus carry
        POP     BC              ; Get other value
        AND     B               ; Combine them
        ADD     A,-1            ; Carry set if different
        SBC     A,A             ; 00 - Equal , FF - Different
        JP      FLGREL          ; Set current value & continue
;------------------------------------------------------------------------------
; NOT  FPREG = NOT(FPREG)
;------------------------------------------------------------------------------
EVNOT   LD      D,5AH           ; Precedence value for "NOT"
        CALL    EVAL1           ; Eval until precedence break
        CALL    TSTNUM          ; Make sure it's a number
        CALL    DEINT           ; Get integer -32768 - 32767
        LD      A,E             ; Get LSB
        CPL                     ; Invert LSB
        LD      C,A             ; Save "NOT" of LSB
        LD      A,D             ; Get MSB
        CPL                     ; Invert MSB
        CALL    ACPASS          ; Save AC as current
        POP     BC              ; Clean up stack
        JP      EVAL3           ; Continue evaluation
;------------------------------------------------------------------------------
; DIM
;------------------------------------------------------------------------------
DIMRET  DEC     HL              ; DEC 'cos GETCHR INCs
        CALL    GETCHR          ; Get next character
        RET     Z               ; End of DIM statement
        CALL    CHKSYN          ; Make sure "," follows
        defb   ','
DIM     LD      BC,DIMRET       ; Return to "DIMRET"
        PUSH    BC              ; Save on stack
        defb     0F6H            ; Flag "Create" variable
GETVAR  XOR     A               ; Find variable address,to DE
        LD      (LCRFLG),A      ; Set locate / create flag
        LD      B,(HL)          ; Get First byte of name
GTFNAM  CALL    CHKLTR          ; See if a letter
        JP      C,SNERR         ; ?SN Error if not a letter
        XOR     A
        LD      C,A             ; Clear second byte of name
        LD      (TYPE),A        ; Set type to numeric
        CALL    GETCHR          ; Get next character
        JR      C,SVNAM2        ; Numeric - Save in name
        CALL    CHKLTR          ; See if a letter
        JR      C,CHARTY        ; Not a letter - Check type
SVNAM2  LD      C,A             ; Save second byte of name
ENDNAM  CALL    GETCHR          ; Get next character
        JR      C,ENDNAM        ; Numeric - Get another
        CALL    CHKLTR          ; See if a letter
        JR      NC,ENDNAM       ; Letter - Get another
CHARTY  SUB     '$'             ; String variable?
        JR      NZ,NOTSTR       ; No - Numeric variable
        INC     A               ; A = 1 (string type)
        LD      (TYPE),A        ; Set type to string
        RRCA                    ; A = 80H , Flag for string
        ADD     A,C             ; 2nd byte of name has bit 7 on
        LD      C,A             ; Resave second byte on name
        CALL    GETCHR          ; Get next character
NOTSTR  LD      A,(FORFLG)      ; Array name needed ?
        DEC     A
        JP      Z,ARLDSV        ; Yes - Get array name
        JP      P,NSCFOR        ; No array with "FOR" or "FN"
        LD      A,(HL)          ; Get byte again
        SUB     '('             ; Subscripted variable?
        JP      Z,SBSCPT        ; Yes - Sort out subscript

NSCFOR  XOR     A               ; Simple variable
        LD      (FORFLG),A      ; Clear "FOR" flag
        PUSH    HL              ; Save code string address
        LD      D,B             ; DE = Variable name to find
        LD      E,C
        LD      HL,(FNRGNM)     ; FN argument name
        CALL    CPHLDE          ; Is it the FN argument?
        LD      DE,FNARG        ; Point to argument value
        JP      Z,POPHRT        ; Yes - Return FN argument value
        LD      HL,(VAREND)     ; End of variables
        EX      DE,HL           ; Address of end of search
        LD      HL,(PROGND)     ; Start of variables address
FNDVAR  CALL    CPHLDE          ; End of variable list table?
        JR      Z,CFEVAL        ; Yes - Called from EVAL?
        LD      A,C             ; Get second byte of name
        SUB     (HL)            ; Compare with name in list
        INC     HL              ; Move on to first byte
        JR      NZ,FNTHR        ; Different - Find another
        LD      A,B             ; Get first byte of name
        SUB     (HL)            ; Compare with name in list
FNTHR   INC     HL              ; Move on to LSB of value
        JP      Z,RETADR        ; Found - Return address
        INC     HL              ; <- Skip
        INC     HL              ; <- over
        INC     HL              ; <- F.P.
        INC     HL              ; <- value
        JP      FNDVAR          ; Keep looking

CFEVAL  POP     HL              ; Restore code string address
        EX      (SP),HL         ; Get return address
        PUSH    DE              ; Save address of variable
        LD      DE,FRMEVL       ; Return address in EVAL
        CALL    CPHLDE          ; Called from EVAL ?
        POP     DE              ; Restore address of variable
        JP      Z,RETNUL        ; Yes - Return null variable
        EX      (SP),HL         ; Put back return
        PUSH    HL              ; Save code string address
        PUSH    BC              ; Save variable name
        LD      BC,6            ; 2 byte name plus 4 byte data
        LD      HL,(ARREND)     ; End of arrays
        PUSH    HL              ; Save end of arrays
        ADD     HL,BC           ; Move up 6 bytes
        POP     BC              ; Source address in BC
        PUSH    HL              ; Save new end address
        CALL    MOVUP           ; Move arrays up
        POP     HL              ; Restore new end address
        LD      (ARREND),HL     ; Set new end address
        LD      H,B             ; End of variables to HL
        LD      L,C
        LD      (VAREND),HL     ; Set new end address

ZEROLP  DEC     HL              ; Back through to zero variable
        LD      (HL),0          ; Zero byte in variable
        CALL    CPHLDE          ; Done them all?
        JP      NZ,ZEROLP       ; No - Keep on going
        POP     DE              ; Get variable name
        LD      (HL),E          ; Store second character
        INC     HL
        LD      (HL),D          ; Store first character
        INC     HL
RETADR  EX      DE,HL           ; Address of variable in DE
        POP     HL              ; Restore code string address
        RET

RETNUL  LD      (FPEXP),A       ; Set result to zero
        LD      HL,ZERBYT       ; Also set a null string
        LD      (FPREG),HL      ; Save for EVAL
        POP     HL              ; Restore code string address
        RET

SBSCPT  PUSH    HL              ; Save code string address
        LD      HL,(LCRFLG)     ; Locate/Create and Type
        EX      (SP),HL         ; Save and get code string
        LD      D,A             ; Zero number of dimensions
SCPTLP  PUSH    DE              ; Save number of dimensions
        PUSH    BC              ; Save array name
        CALL    FPSINT          ; Get subscript (0-32767)
        POP     BC              ; Restore array name
        POP     AF              ; Get number of dimensions
        EX      DE,HL
        EX      (SP),HL         ; Save subscript value
        PUSH    HL              ; Save LCRFLG and TYPE
        EX      DE,HL
        INC     A               ; Count dimensions
        LD      D,A             ; Save in D
        LD      A,(HL)          ; Get next byte in code string
        CP      ','             ; Comma (more to come)?
        JR      Z,SCPTLP        ; Yes - More subscripts
        CALL    CHKSYN          ; Make sure ")" follows
        defb   ')'
        LD      (NXTOPR),HL     ; Save code string address
        POP     HL              ; Get LCRFLG and TYPE
        LD      (LCRFLG),HL     ; Restore Locate/create & type
        LD      E,0             ; Flag not SAVE* or LOAD*
        PUSH    DE              ; Save number of dimensions (D)
        defb   $11             ; Skip "PUSH HL" and "PUSH AF'

ARLDSV  PUSH    HL              ; Save code string address
        PUSH    AF              ; A = 00 , Flags set = Z,N
        LD      HL,(VAREND)     ; Start of arrays
        defb   $3E             ; Skip "ADD HL,DE"
FNDARY  ADD     HL,DE           ; Move to next array start
        EX      DE,HL
        LD      HL,(ARREND)     ; End of arrays
        EX      DE,HL           ; Current array pointer
        CALL    CPHLDE          ; End of arrays found?
        JR      Z,CREARY        ; Yes - Create array
        LD      A,(HL)          ; Get second byte of name
        CP      C               ; Compare with name given
        INC     HL              ; Move on
        JR      NZ,NXTARY       ; Different - Find next array
        LD      A,(HL)          ; Get first byte of name
        CP      B               ; Compare with name given
NXTARY  INC     HL              ; Move on
        LD      E,(HL)          ; Get LSB of next array address
        INC     HL
        LD      D,(HL)          ; Get MSB of next array address
        INC     HL
        JR      NZ,FNDARY       ; Not found - Keep looking
        LD      A,(LCRFLG)      ; Found Locate or Create it?
        OR      A
        JP      NZ,DDERR        ; Create - ?DD Error
        POP     AF              ; Locate - Get number of dim'ns
        LD      B,H             ; BC Points to array dim'ns
        LD      C,L
        JP      Z,POPHRT        ; Jump if array load/save
        SUB     (HL)            ; Same number of dimensions?
        JP      Z,FINDEL        ; Yes - Find element
BSERR   LD      E,BS            ; ?BS Error
        JP      ERROR           ; Output error
;------------------------------------------------------------------------------
; CREATE ARRAY IN MEMORY
;------------------------------------------------------------------------------
CREARY  LD      DE,4            ; 4 Bytes per entry
        POP     AF              ; Array to save or 0 dim'ns?
        JP      Z,FCERR         ; Yes - ?FC Error
        LD      (HL),C          ; Save second byte of name
        INC     HL
        LD      (HL),B          ; Save first byte of name
        INC     HL
        LD      C,A             ; Number of dimensions to C
        CALL    CHKSTK          ; Check if enough memory
        INC     HL              ; Point to number of dimensions
        INC     HL
        LD      (CUROPR),HL     ; Save address of pointer
        LD      (HL),C          ; Set number of dimensions
        INC     HL
        LD      A,(LCRFLG)      ; Locate of Create?
        RLA                     ; Carry set = Create
        LD      A,C             ; Get number of dimensions
CRARLP  LD      BC,10+1         ; Default dimension size 10
        JR      NC,DEFSIZ       ; Locate - Set default size
        POP     BC              ; Get specified dimension size
        INC     BC              ; Include zero element
DEFSIZ  LD      (HL),C          ; Save LSB of dimension size
        INC     HL
        LD      (HL),B          ; Save MSB of dimension size
        INC     HL
        PUSH    AF              ; Save num' of dim'ns an status
        PUSH    HL              ; Save address of dim'n size
        CALL    MLDEBC          ; Multiply DE by BC to find
        EX      DE,HL           ; amount of mem needed (to DE)
        POP     HL              ; Restore address of dimension
        POP     AF              ; Restore number of dimensions
        DEC     A               ; Count them
        JR      NZ,CRARLP       ; Do next dimension if more
        PUSH    AF              ; Save locate/create flag
        LD      B,D             ; MSB of memory needed
        LD      C,E             ; LSB of memory needed
        EX      DE,HL
        ADD     HL,DE           ; Add bytes to array start
        JP      C,OMERR         ; Too big - Error
        CALL    ENFMEM          ; See if enough memory
        LD      (ARREND),HL     ; Save new end of array

ZERARY  DEC     HL              ; Back through array data
        LD      (HL),0          ; Set array element to zero
        CALL    CPHLDE          ; All elements zeroed?
        JR      NZ,ZERARY       ; No - Keep on going
        INC     BC              ; Number of bytes + 1
        LD      D,A             ; A=0
        LD      HL,(CUROPR)     ; Get address of array
        LD      E,(HL)          ; Number of dimensions
        EX      DE,HL           ; To HL
        ADD     HL,HL           ; Two bytes per dimension size
        ADD     HL,BC           ; Add number of bytes
        EX      DE,HL           ; Bytes needed to DE
        DEC     HL
        DEC     HL
        LD      (HL),E          ; Save LSB of bytes needed
        INC     HL
        LD      (HL),D          ; Save MSB of bytes needed
        INC     HL
        POP     AF              ; Locate / Create?
        JR      C,ENDDIM        ; A is 0 , End if create
FINDEL  LD      B,A             ; Find array element
        LD      C,A
        LD      A,(HL)          ; Number of dimensions
        INC     HL
        defb     16H             ; Skip "POP HL"
FNDELP  POP     HL              ; Address of next dim' size
        LD      E,(HL)          ; Get LSB of dim'n size
        INC     HL
        LD      D,(HL)          ; Get MSB of dim'n size
        INC     HL
        EX      (SP),HL         ; Save address - Get index
        PUSH    AF              ; Save number of dim'ns
        CALL    CPHLDE          ; Dimension too large?
        JP      NC,BSERR        ; Yes - ?BS Error
        PUSH    HL              ; Save index
        CALL    MLDEBC          ; Multiply previous by size
        POP     DE              ; Index supplied to DE
        ADD     HL,DE           ; Add index to pointer
        POP     AF              ; Number of dimensions
        DEC     A               ; Count them
        LD      B,H             ; MSB of pointer
        LD      C,L             ; LSB of pointer
        JR      NZ,FNDELP       ; More - Keep going
        ADD     HL,HL           ; 4 Bytes per element
        ADD     HL,HL
        POP     BC              ; Start of array
        ADD     HL,BC           ; Point to element
        EX      DE,HL           ; Address of element to DE
ENDDIM  LD      HL,(NXTOPR)     ; Got code string address
        RET
;------------------------------------------------------------------------------
; FRE list amount of free memory remaining
;------------------------------------------------------------------------------
FRE     LD      HL,(ARREND)     ; Start of free memory
        EX      DE,HL           ; To DE
        LD	HL,(RAMTOP)	; Top of physical memory
        LD      A,(TYPE)        ; Dummy argument type
        OR      A		; If string, return free string memory
        JR      Z,FRENUM        ; Numeric - Free variable space
        CALL    GSTRCU          ; Current string to pool
        CALL    GARBGE          ; Garbage collection
        LD      HL,(STRSPC)     ; Bottom of string space in use
        EX      DE,HL           ; To DE
        LD      HL,(STRBOT)     ; Bottom of string space
FRENUM  LD      A,L             ; Get LSB of end
        SUB     E               ; Subtract LSB of beginning
        LD      C,A             ; Save difference if C
        LD      A,H             ; Get MSB of end
        SBC     A,D             ; Subtract MSB of beginning
;------------------------------------------------------------------------------        
ACPASS  LD      B,C             ; Return integer AC
ABPASS  LD      D,B             ; Return integer AB
        LD      E,0		; Numeric type
        LD      HL,TYPE         ; Point to type
        LD      (HL),E          ; Set type to numeric
        LD      B,80H+16        ; 16 bit integer
        JP      RETINT          ; Return the integer
;------------------------------------------------------------------------------
; POS returns current cursor position
;------------------------------------------------------------------------------
POS     LD      A,(CURPOS)      ; Get cursor position
PASSA   LD      B,A             ; Put A into AB
        XOR     A               ; Zero A
        JR      ABPASS          ; Return integer AB
;------------------------------------------------------------------------------
; DEF FN define function
;------------------------------------------------------------------------------
DEF     CALL    CHEKFN          ; Get "FN" and name
        CALL    IDTEST          ; Test for illegal direct
        LD      BC,DATA         ; To get next statement
        PUSH    BC              ; Save address for RETurn
        PUSH    DE              ; Save address of function ptr
        CALL    CHKSYN          ; Make sure "(" follows
        defb   '('
        CALL    GETVAR          ; Get argument variable name
        PUSH    HL              ; Save code string address
        EX      DE,HL           ; Argument address to HL
        DEC     HL
        LD      D,(HL)          ; Get first byte of arg name
        DEC     HL
        LD      E,(HL)          ; Get second byte of arg name
        POP     HL              ; Restore code string address
        CALL    TSTNUM          ; Make sure numeric argument
        CALL    CHKSYN          ; Make sure ")" follows
        defb   ')'
        CALL    CHKSYN          ; Make sure "=" follows
        defb     ZEQUAL          ; "=" token
        LD      B,H             ; Code string address to BC
        LD      C,L
        EX      (SP),HL         ; Save code str , Get FN ptr
        LD      (HL),C          ; Save LSB of FN code string
        INC     HL
        LD      (HL),B          ; Save MSB of FN code string
        JP      SVSTAD          ; Save address and do function
;------------------------------------------------------------------------------
; Perform FN function
;------------------------------------------------------------------------------
DOFN    CALL    CHEKFN          ; Make sure FN follows
        PUSH    DE              ; Save function pointer address
        CALL    EVLPAR          ; Evaluate expression in "()"
        CALL    TSTNUM          ; Make sure numeric result
        EX      (SP),HL         ; Save code str , Get FN ptr
        LD      E,(HL)          ; Get LSB of FN code string
        INC     HL
        LD      D,(HL)          ; Get MSB of FN code string
        INC     HL
        LD      A,D             ; And function DEFined?
        OR      E
        JP      Z,UFERR         ; No - ?UF Error
        LD      A,(HL)          ; Get LSB of argument address
        INC     HL
        LD      H,(HL)          ; Get MSB of argument address
        LD      L,A             ; HL = Arg variable address
        PUSH    HL              ; Save it
        LD      HL,(FNRGNM)     ; Get old argument name
        EX      (SP),HL         ; Save old , Get new
        LD      (FNRGNM),HL     ; Set new argument name
        LD      HL,(FNARG+2)    ; Get LSB,NLSB of old arg value
        PUSH    HL              ; Save it
        LD      HL,(FNARG)      ; Get MSB,EXP of old arg value
        PUSH    HL              ; Save it
        LD      HL,FNARG        ; HL = Value of argument
        PUSH    DE              ; Save FN code string address
        CALL    FPTHL           ; Move FPREG to argument
        POP     HL              ; Get FN code string address
        CALL    GETNUM          ; Get value from function
        DEC     HL              ; DEC 'cos GETCHR INCs
        CALL    GETCHR          ; Get next character
        JP      NZ,SNERR        ; Bad character in FN - Error
        POP     HL              ; Get MSB,EXP of old arg
        LD      (FNARG),HL      ; Restore it
        POP     HL              ; Get LSB,NLSB of old arg
        LD      (FNARG+2),HL    ; Restore it
        POP     HL              ; Get name of old arg
        LD      (FNRGNM),HL     ; Restore it
        POP     HL              ; Restore code string address
        RET
;------------------------------------------------------------------------------
; Determine if Immediate or if operating in program RUN
;------------------------------------------------------------------------------
IDTEST  PUSH    HL              ; Save code string address
        LD      HL,(LINEAT)     ; Get current line number
        INC     HL              ; -1 means direct statement
        LD      A,H
        OR      L
        POP     HL              ; Restore code string address
        RET     NZ              ; Return if in program
        LD      E,ID            ; ?ID Error
        JP      ERROR

CHEKFN  CALL    CHKSYN          ; Make sure FN follows
        defb     ZFN             ; "FN" token
        LD      A,80H
        LD      (FORFLG),A      ; Flag FN name to find
        OR      (HL)            ; FN name has bit 7 set
        LD      B,A             ; in first byte of name
        CALL    GTFNAM          ; Get FN name
        JP      TSTNUM          ; Make sure numeric function
;------------------------------------------------------------------------------
; STR function turns numeric into string value
;------------------------------------------------------------------------------
STR     CALL    TSTNUM          ; Make sure it's a number
        CALL    NUMASC          ; Turn number into text
STR1    CALL    CRTST           ; Create string entry for it
        CALL    GSTRCU          ; Current string to pool
        LD      BC,TOPOOL       ; Save in string pool
        PUSH    BC              ; Save address on stack

SAVSTR  LD      A,(HL)          ; Get string length
        INC     HL
        INC     HL
        PUSH    HL              ; Save pointer to string
        CALL    TESTR           ; See if enough string space
        POP     HL              ; Restore pointer to string
        LD      C,(HL)          ; Get LSB of address
        INC     HL
        LD      B,(HL)          ; Get MSB of address
        CALL    CRTMST          ; Create string entry
        PUSH    HL              ; Save pointer to MSB of addr
        LD      L,A             ; Length of string
        CALL    TOSTRA          ; Move to string area
        POP     DE              ; Restore pointer to MSB
        RET
;------------------------------------------------------------------------------
MKTMST  CALL    TESTR           ; See if enough string space
CRTMST  LD      HL,TMPSTR       ; Temporary string
        PUSH    HL              ; Save it
        LD      (HL),A          ; Save length of string
        INC     HL
SVSTAD  INC     HL
        LD      (HL),E          ; Save LSB of address
        INC     HL
        LD      (HL),D          ; Save MSB of address
        POP     HL              ; Restore pointer
        RET
;------------------------------------------------------------------------------
CRTST   DEC     HL              ; DEC - INCed after
QTSTR   LD      B,$22           ; Terminating quote "
        LD      D,B             ; Quote to D
DTSTR   PUSH    HL              ; Save start
        LD      C,-1            ; Set counter to -1
QTSTLP  INC     HL              ; Move on
        LD      A,(HL)          ; Get byte
        INC     C               ; Count bytes
        OR      A               ; End of line?
        JR      Z,CRTSTE        ; Yes - Create string entry
        CP      D               ; Terminator D found?
        JR      Z,CRTSTE        ; Yes - Create string entry
        CP      B               ; Terminator B found?
        JR      NZ,QTSTLP       ; No - Keep looking
CRTSTE  CP      $22             ; End with '"'?
        CALL    Z,GETCHR        ; Yes - Get next character
        EX      (SP),HL         ; Starting quote
        INC     HL              ; First byte of string
        EX      DE,HL           ; To DE
        LD      A,C             ; Get length
        CALL    CRTMST          ; Create string entry
TSTOPL  LD      DE,TMPSTR       ; Temporary string
        LD      HL,(TMSTPT)     ; Temporary string pool pointer
        LD      (FPREG),HL      ; Save address of string ptr
        LD      A,1
        LD      (TYPE),A        ; Set type to string
        CALL    DETHL4          ; Move string to pool
        CALL    CPHLDE          ; Out of string pool?
        LD      (TMSTPT),HL     ; Save new pointer
        POP     HL              ; Restore code string address
        LD      A,(HL)          ; Get next code byte
        RET     NZ              ; Return if pool OK
        LD      E,ST            ; ?ST Error
        JP      ERROR           ; String pool overflow
;------------------------------------------------------------------------------
; Print String routines
;------------------------------------------------------------------------------
PRNUMS  INC     HL              ; Skip leading space
PRS     CALL    CRTST           ; Create string entry for it
PRS1    CALL    GSTRCU          ; Current string to pool
        CALL    LOADFP          ; Move string block to BCDE
        INC     E               ; Length + 1
PRSLP   DEC     E               ; Count characters
        RET     Z               ; End of string
        LD      A,(BC)          ; Get byte to output
        CALL    OUTC            ; Output character in A
        CP      CR              ; Return?
        CALL    Z,DONULL        ; Yes - Do nulls
        INC     BC              ; Next byte in string
        JR      PRSLP           ; More characters to output
;------------------------------------------------------------------------------
TESTR   OR      A               ; Test if enough room (string length=A)
        defb   $0E             ; No garbage collection done
GRBDON  POP     AF              ; Garbage collection done
        PUSH    AF              ; Save status
        LD      HL,(STRSPC)     ; Bottom of string space in use
        EX      DE,HL           ; To DE
        LD      HL,(STRBOT)     ; Bottom of string area
        CPL                     ; Negate length (Top down)
        LD      C,A             ; -Length to BC
        LD      B,-1            ; BC = negeative length of string
        ADD     HL,BC           ; Add to bottom of space in use
        INC     HL              ; Plus one for 2's complement
        CALL    CPHLDE          ; Below string RAM area?
        JR      C,TESTOS        ; Tidy up if not done else err
        LD      (STRBOT),HL     ; Save new bottom of area
        INC     HL              ; Point to first byte of string
        EX      DE,HL           ; Address to DE
POPAF   POP     AF              ; Throw away status push
        RET
TESTOS  POP     AF              ; Garbage collect been done?
        LD      E,OS            ; ?OS Error
        JP      Z,ERROR         ; Yes - Not enough string apace
        CP      A               ; Flag garbage collect done
        PUSH    AF              ; Save status
        LD      BC,GRBDON       ; Garbage collection done
        PUSH    BC              ; Save for RETurn
GARBGE  LD      HL,(LSTRAM)     ; Get end of RAM pointer
GARBLP  LD      (STRBOT),HL     ; Reset string pointer
        LD      HL,0
        PUSH    HL              ; Flag no string found
        LD      HL,(STRSPC)     ; Get bottom of string space
        PUSH    HL              ; Save bottom of string space
        LD      HL,TMSTPL       ; Temporary string pool
GRBLP   EX      DE,HL
        LD      HL,(TMSTPT)     ; Temporary string pool pointer
        EX      DE,HL
        CALL    CPHLDE          ; Temporary string pool done?
        LD      BC,GRBLP        ; Loop until string pool done
        JP      NZ,STPOOL       ; No - See if in string area
        LD      HL,(PROGND)     ; Start of simple variables
SMPVAR  EX      DE,HL
        LD      HL,(VAREND)     ; End of simple variables
        EX      DE,HL
        CALL    CPHLDE          ; All simple strings done?
        JP      Z,ARRLP         ; Yes - Do string arrays
        LD      A,(HL)          ; Get type of variable
        INC     HL
        INC     HL
        OR      A               ; "S" flag set if string
        CALL    STRADD          ; See if string in string area
        JR      SMPVAR          ; Loop until simple ones done

GNXARY  POP     BC              ; Scrap address of this array
ARRLP   EX      DE,HL
        LD      HL,(ARREND)     ; End of string arrays
        EX      DE,HL
        CALL    CPHLDE          ; All string arrays done?
        JP      Z,SCNEND        ; Yes - Move string if found
        CALL    LOADFP          ; Get array name to BCDE
        LD      A,E             ; Get type of array
        PUSH    HL              ; Save address of num of dim'ns
        ADD     HL,BC           ; Start of next array
        OR      A               ; Test type of array
        JP      P,GNXARY        ; Numeric array - Ignore it
        LD      (CUROPR),HL     ; Save address of next array
        POP     HL              ; Get address of num of dim'ns
        LD      C,(HL)          ; BC = Number of dimensions
        LD      B,0
        ADD     HL,BC           ; Two bytes per dimension size
        ADD     HL,BC
        INC     HL              ; Plus one for number of dim'ns
GRBARY  EX      DE,HL
        LD      HL,(CUROPR)     ; Get address of next array
        EX      DE,HL
        CALL    CPHLDE          ; Is this array finished?
        JR      Z,ARRLP         ; Yes - Get next one
        LD      BC,GRBARY       ; Loop until array all done
STPOOL  PUSH    BC              ; Save return address
        OR      80H             ; Flag string type
STRADD  LD      A,(HL)          ; Get string length
        INC     HL
        INC     HL
        LD      E,(HL)          ; Get LSB of string address
        INC     HL
        LD      D,(HL)          ; Get MSB of string address
        INC     HL
        RET     P               ; Not a string - Return
        OR      A               ; Set flags on string length
        RET     Z               ; Null string - Return
        LD      B,H             ; Save variable pointer
        LD      C,L
        LD      HL,(STRBOT)     ; Bottom of new area
        CALL    CPHLDE          ; String been done?
        LD      H,B             ; Restore variable pointer
        LD      L,C
        RET     C               ; String done - Ignore
        POP     HL              ; Return address
        EX      (SP),HL         ; Lowest available string area
        CALL    CPHLDE          ; String within string area?
        EX      (SP),HL         ; Lowest available string area
        PUSH    HL              ; Re-save return address
        LD      H,B             ; Restore variable pointer
        LD      L,C
        RET     NC              ; Outside string area - Ignore
        POP     BC              ; Get return , Throw 2 away
        POP     AF              ; 
        POP     AF              ; 
        PUSH    HL              ; Save variable pointer
        PUSH    DE              ; Save address of current
        PUSH    BC              ; Put back return address
        RET                     ; Go to it

SCNEND  POP     DE              ; Addresses of strings
        POP     HL              ; 
        LD      A,L             ; HL = 0 if no more to do
        OR      H
        RET     Z               ; No more to do - Return
        DEC     HL
        LD      B,(HL)          ; MSB of address of string
        DEC     HL
        LD      C,(HL)          ; LSB of address of string
        PUSH    HL              ; Save variable address
        DEC     HL
        DEC     HL
        LD      L,(HL)          ; HL = Length of string
        LD      H,0
        ADD     HL,BC           ; Address of end of string+1
        LD      D,B             ; String address to DE
        LD      E,C
        DEC     HL              ; Last byte in string
        LD      B,H             ; Address to BC
        LD      C,L
        LD      HL,(STRBOT)     ; Current bottom of string area
        CALL    MOVSTR          ; Move string to new address
        POP     HL              ; Restore variable address
        LD      (HL),C          ; Save new LSB of address
        INC     HL
        LD      (HL),B          ; Save new MSB of address
        LD      L,C             ; Next string area+1 to HL
        LD      H,B
        DEC     HL              ; Next string area address
        JP      GARBLP          ; Look for more strings

CONCAT  PUSH    BC              ; Save prec' opr & code string
        PUSH    HL              ; 
        LD      HL,(FPREG)      ; Get first string
        EX      (SP),HL         ; Save first string
        CALL    OPRND           ; Get second string
        EX      (SP),HL         ; Restore first string
        CALL    TSTSTR          ; Make sure it's a string
        LD      A,(HL)          ; Get length of second string
        PUSH    HL              ; Save first string
        LD      HL,(FPREG)      ; Get second string
        PUSH    HL              ; Save second string
        ADD     A,(HL)          ; Add length of second string
        LD      E,LS            ; ?LS Error
        JP      C,ERROR         ; String too long - Error
        CALL    MKTMST          ; Make temporary string
        POP     DE              ; Get second string to DE
        CALL    GSTRDE          ; Move to string pool if needed
        EX      (SP),HL         ; Get first string
        CALL    GSTRHL          ; Move to string pool if needed
        PUSH    HL              ; Save first string
        LD      HL,(TMPSTR+2)   ; Temporary string address
        EX      DE,HL           ; To DE
        CALL    SSTSA           ; First string to string area
        CALL    SSTSA           ; Second string to string area
        LD      HL,EVAL2        ; Return to evaluation loop
        EX      (SP),HL         ; Save return,get code string
        PUSH    HL              ; Save code string address
        JP      TSTOPL          ; To temporary string to pool

SSTSA   POP     HL              ; Return address
        EX      (SP),HL         ; Get string block,save return
        LD      A,(HL)          ; Get length of string
        INC     HL
        INC     HL
        LD      C,(HL)          ; Get LSB of string address
        INC     HL
        LD      B,(HL)          ; Get MSB of string address
        LD      L,A             ; Length to L
TOSTRA  INC     L               ; INC - DECed after
TSALP   DEC     L               ; Count bytes moved
        RET     Z               ; End of string - Return
        LD      A,(BC)          ; Get source
        LD      (DE),A          ; Save destination
        INC     BC              ; Next source
        INC     DE              ; Next destination
        JR      TSALP           ; Loop until string moved

GETSTR  CALL    TSTSTR          ; Make sure it's a string
GSTRCU  LD      HL,(FPREG)      ; Get current string
GSTRHL  EX      DE,HL           ; Save DE
GSTRDE  CALL    BAKTMP          ; Was it last tmp-str?
        EX      DE,HL           ; Restore DE
        RET     NZ              ; No - Return
        PUSH    DE              ; Save string
        LD      D,B             ; String block address to DE
        LD      E,C
        DEC     DE              ; Point to length
        LD      C,(HL)          ; Get string length
        LD      HL,(STRBOT)     ; Current bottom of string area
        CALL    CPHLDE          ; Last one in string area?
        JR      NZ,POPHL        ; No - Return
        LD      B,A             ; Clear B (A=0)
        ADD     HL,BC           ; Remove string from str' area
        LD      (STRBOT),HL     ; Save new bottom of str' area
POPHL   POP     HL              ; Restore string
        RET

BAKTMP  LD      HL,(TMSTPT)     ; Get temporary string pool top
        DEC     HL              ; Back
        LD      B,(HL)          ; Get MSB of address
        DEC     HL              ; Back
        LD      C,(HL)          ; Get LSB of address
        DEC     HL              ; Back
        DEC     HL              ; Back
        CALL    CPHLDE          ; String last in string pool?
        RET     NZ              ; Yes - Leave it
        LD      (TMSTPT),HL     ; Save new string pool top
        RET
;------------------------------------------------------------------------------
; LEN string length
;------------------------------------------------------------------------------
LEN:    LD      BC,PASSA        ; To return integer A
        PUSH    BC              ; Save address
GETLEN: CALL    GETSTR          ; Get string and its length
        XOR     A
        LD      D,A             ; Clear D
        LD      (TYPE),A        ; Set type to numeric
        LD      A,(HL)          ; Get length of string
        OR      A               ; Set status flags
        RET
;------------------------------------------------------------------------------
; ASC string value
;------------------------------------------------------------------------------
ASC:    LD      BC,PASSA        ; To return integer A
        PUSH    BC              ; Save address
GTFLNM: CALL    GETLEN          ; Get length of string
        JP      Z,FCERR         ; Null string - Error
        INC     HL
        INC     HL
        LD      E,(HL)          ; Get LSB of address
        INC     HL
        LD      D,(HL)          ; Get MSB of address
        LD      A,(DE)          ; Get first byte of string
        RET
;------------------------------------------------------------------------------
; CHR
;------------------------------------------------------------------------------
CHR:    LD      A,1             ; One character string
        CALL    MKTMST          ; Make a temporary string
        CALL    MAKINT          ; Make it integer A
        LD      HL,(TMPSTR+2)   ; Get address of string
        LD      (HL),E          ; Save character
TOPOOL: POP     BC              ; Clean up stack
        JP      TSTOPL          ; Temporary string to pool
;------------------------------------------------------------------------------
; LEFT$
;------------------------------------------------------------------------------
LEFT:   CALL    LFRGNM          ; Get number and ending ")"
        XOR     A               ; Start at first byte in string
;------------------------------------------------------------------------------
; RIGHT$
;------------------------------------------------------------------------------
RIGHT1: EX      (SP),HL         ; Save code string,Get string
        LD      C,A             ; Starting position in string
;------------------------------------------------------------------------------
; MID$
;------------------------------------------------------------------------------        
MID1:   PUSH    HL              ; Save string block address
        LD      A,(HL)          ; Get length of string
        CP      B               ; Compare with number given
        JR      C,ALLFOL        ; All following bytes required
        LD      A,B             ; Get new length
        defb     11H             ; Skip "LD C,0"
ALLFOL: LD      C,0             ; First byte of string
        PUSH    BC              ; Save position in string
        CALL    TESTR           ; See if enough string space
        POP     BC              ; Get position in string
        POP     HL              ; Restore string block address
        PUSH    HL              ; And re-save it
        INC     HL
        INC     HL
        LD      B,(HL)          ; Get LSB of address
        INC     HL
        LD      H,(HL)          ; Get MSB of address
        LD      L,B             ; HL = address of string
        LD      B,0             ; BC = starting address
        ADD     HL,BC           ; Point to that byte
        LD      B,H             ; BC = source string
        LD      C,L
        CALL    CRTMST          ; Create a string entry
        LD      L,A             ; Length of new string
        CALL    TOSTRA          ; Move string to string area
        POP     DE              ; Clear stack
        CALL    GSTRDE          ; Move to string pool if needed
        JP      TSTOPL          ; Temporary string to pool

RIGHT:  CALL    LFRGNM          ; Get number and ending ")"
        POP     DE              ; Get string length
        PUSH    DE              ; And re-save
        LD      A,(DE)          ; Get length
        SUB     B               ; Move back N bytes
        JR      RIGHT1          ; Go and get sub-string

MID:    EX      DE,HL           ; Get code string address
        LD      A,(HL)          ; Get next byte "," or ")"
        CALL    MIDNUM          ; Get number supplied
        INC     B               ; Is it character zero?
        DEC     B
        JP      Z,FCERR         ; Yes - Error
        PUSH    BC              ; Save starting position
        LD      E,255           ; All of string
        CP      ')'             ; Any length given?
        JR      Z,RSTSTR        ; No - Rest of string
        CALL    CHKSYN          ; Make sure "," follows
        defb   ','
        CALL    GETINT          ; Get integer 0-255
RSTSTR: CALL    CHKSYN          ; Make sure ")" follows
        defb   ')'
        POP     AF              ; Restore starting position
        EX      (SP),HL         ; Get string,8ave code string
        LD      BC,MID1         ; Continuation of MID$ routine
        PUSH    BC              ; Save for return
        DEC     A               ; Starting position-1
        CP      (HL)            ; Compare with length
        LD      B,0             ; Zero bytes length
        RET     NC              ; Null string if start past end
        LD      C,A             ; Save starting position-1
        LD      A,(HL)          ; Get length of string
        SUB     C               ; Subtract start
        CP      E               ; Enough string for it?
        LD      B,A             ; Save maximum length available
        RET     C               ; Truncate string if needed
        LD      B,E             ; Set specified length
        RET                     ; Go and create string
;------------------------------------------------------------------------------
; VAL
;------------------------------------------------------------------------------
VAL:    CALL    GETLEN          ; Get length of string
        JP      Z,RESZER        ; Result zero
        LD      E,A             ; Save length
        INC     HL
        INC     HL
        LD      A,(HL)          ; Get LSB of address
        INC     HL
        LD      H,(HL)          ; Get MSB of address
        LD      L,A             ; HL = String address
        PUSH    HL              ; Save string address
        ADD     HL,DE
        LD      B,(HL)          ; Get end of string+1 byte
        LD      (HL),D          ; Zero it to terminate
        EX      (SP),HL         ; Save string end,get start
        PUSH    BC              ; Save end+1 byte
        LD      A,(HL)          ; Get starting byte
        CALL    ASCTFP          ; Convert ASCII string to FP
        POP     BC              ; Restore end+1 byte
        POP     HL              ; Restore end+1 address
        LD      (HL),B          ; Put back original byte
        RET

LFRGNM: EX      DE,HL           ; Code string address to HL
        CALL    CHKSYN          ; Make sure ")" follows
        defb     ")"
MIDNUM: POP     BC              ; Get return address
        POP     DE              ; Get number supplied
        PUSH    BC              ; Re-save return address
        LD      B,E             ; Number to B
        RET
;------------------------------------------------------------------------------
; INPUT
;------------------------------------------------------------------------------
INP:    CALL    MAKINT          ; Make it integer A
        LD      (INPORT),A      ; Set input port
        CALL    INPSUB          ; Get input from port
        JP      PASSA           ; Return integer A
;------------------------------------------------------------------------------
; OUTPUT
;------------------------------------------------------------------------------
POUT:   CALL    SETIO           ; Set up port number
        JP      OUTSUB          ; Output data and return
;------------------------------------------------------------------------------
; WAIT
;------------------------------------------------------------------------------
WAIT:   CALL    SETIO           ; Set up port number
        PUSH    AF              ; Save AND mask
        LD      E,0             ; Assume zero if none given
        DEC     HL              ; DEC 'cos GETCHR INCs
        CALL    GETCHR          ; Get next character
        JR      Z,NOXOR         ; No XOR byte given
        CALL    CHKSYN          ; Make sure "," follows
        defb   ','
        CALL    GETINT          ; Get integer 0-255 to XOR with
NOXOR:  POP     BC              ; Restore AND mask
WAITLP: CALL    INPSUB          ; Get input
        XOR     E               ; Flip selected bits
        AND     B               ; Result non-zero?
        JR      Z,WAITLP        ; No = keep waiting
        RET
;------------------------------------------------------------------------------
; Process INP and OUT
;------------------------------------------------------------------------------
SETIO:  CALL    GETINT          ; Get integer 0-255
        LD      (INPORT),A      ; Set input port
        LD      (OTPORT),A      ; Set output port
        CALL    CHKSYN          ; Make sure "," follows
        defb   ','
        JP      GETINT          ; Get integer 0-255 and return

FNDNUM: CALL    GETCHR          ; Get next character
GETINT: CALL    GETNUM          ; Get a number from 0 to 255
MAKINT: CALL    DEPINT          ; Make sure value 0 - 255
        LD      A,D             ; Get MSB of number
        OR      A               ; Zero?
        JP      NZ,FCERR        ; No - Error
        DEC     HL              ; DEC 'cos GETCHR INCs
        CALL    GETCHR          ; Get next character
        LD      A,E             ; Get number to A
        RET
;------------------------------------------------------------------------------
; PEEK
;------------------------------------------------------------------------------
PEEK:   CALL    DEINT           ; Get memory address
        LD      A,(DE)          ; Get byte in memory
        JP      PASSA           ; Return integer A
;------------------------------------------------------------------------------
; POKE
;------------------------------------------------------------------------------
POKE:   CALL    GETNUM          ; Get memory address
        CALL    DEINT           ; Get integer -32768 to 3276
        PUSH    DE              ; Save memory address
        CALL    CHKSYN          ; Make sure "," follows
        defb   ','
        CALL    GETINT          ; Get integer 0-255
        POP     DE              ; Restore memory address
        LD      (DE),A          ; Load it into memory
        RET
;------------------------------------------------------------------------------
; HEX( [Will replace DEEK] Convert 16 bit number to Hexadecimal string
;------------------------------------------------------------------------------
HEX     CALL	TSTNUM		; Verify it's a number
	CALL    DEINT           ; Get integer -32768 to 32767
        PUSH	HL		; Save code string address
	PUSH	BC		; Save contents of BC
	LD	HL,PBUFF
	LD	(HL),'$'	; Store "$" to start of conv buffer
	INC	HL		; Index next
	LD	A,D		; Get high order into A
	CALL	BYT2ASC		; Convert D to ASCII
	LD	(HL),B		; Store it to PBUFF+1
	INC	HL		; Next location
	LD	(HL),C		; Store C to PBUFF+2
	LD	A,E		; Get lower byte
	CALL	BYT2ASC		; Convert E to ASCII
	INC	HL		; Save B
	LD	(HL),B		;  to PBUFF+3
	INC	HL		; Save C
	LD	(HL),C		;  to PBUFF+4
	LD	A,$20		; Create a <spc> after the number
	INC	HL		; Index next
	LD	(HL),A		; PBUFF+5 to space
	XOR	A		; Terminating character
	INC	HL		; PBUFF+6 to zero
	LD	(HL),A		; Store zero to terminate
	INC	HL		; Make sure PBUFF is terminated
	LD	(HL),A		; Store the double zero there
	POP	BC		; Get BC back
	POP	HL		; Retrieve code string
	JP	STR1		; Convert the PBUFF to a string and return it
;------------------------------------------------------------------------------
; Convert byte in A to ASCII in BC, same as routine in Monitor at $0326
;------------------------------------------------------------------------------
BYT2ASC	LD	B,A		; Save original value
	AND	$0F		; Strip off upper nybble
	CP	$0A		; 0-9?
	JR	C,ADD30		; If A-F, add 7 more
	ADD	A,$07		; Bring value up to ASCII A-F
ADD30	ADD	A,$30		; And make ASCII
	LD	C,A		; Save converted char to C
	LD	A,B		; Retrieve original value
	RRCA			; and Rotate it right
	RRCA
	RRCA
	RRCA
	AND	$0F		; Mask off upper nybble
	CP	$0A		; 0-9? < A hex?
	JR	C,ADD301	; Skip Add 7
	ADD	A,$07		; Bring it up to ASCII A-F
ADD301	ADD	A,$30		; And make it full ASCII
	LD	B,A		; Store high order byte
	RET	
;------------------------------------------------------------------------------
; VECTOR Set address for USR jump vector [formerly DOKE]
;------------------------------------------------------------------------------
VECTOR	CALL	GETNUM		; Get a number
	CALL	DEINT		; Get integer into DE
	LD	(USR+1),DE	; Store vector at USR vector
	RET
;------------------------------------------------------------------------------
; WIDTH
;------------------------------------------------------------------------------
WIDTH:  CALL    GETINT          ; Get integer 0-255
        LD      A,E             ; Width to A
        LD      (LWIDTH),A      ; Set width
        RET
;------------------------------------------------------------------------------
; LINES
;------------------------------------------------------------------------------
LINES:  CALL    GETNUM          ; Get a number
        CALL    DEINT           ; Get integer -32768 to 32767
        LD      (LINESC),DE     ; Set lines counter
        LD      (LINESN),DE     ; Set lines number
        RET
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
; 
; Start of   F L O A T I N G   P O I N T   M A T H
;
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
ROUND:  LD      HL,HALF         ; Add 0.5 to FPREG
ADDPHL: CALL    LOADFP          ; Load FP at (HL) to BCDE
        JR      FPADD           ; Add BCDE to FPREG

SUBPHL: CALL    LOADFP          ; FPREG = -FPREG + number at HL
        defb     21H             ; Skip "POP BC" and "POP DE"
PSUB:   POP     BC              ; Get FP number from stack
        POP     DE
SUBCDE: CALL    INVSGN          ; Negate FPREG
FPADD:  LD      A,B             ; Get FP exponent
        OR      A               ; Is number zero?
        RET     Z               ; Yes - Nothing to add
        LD      A,(FPEXP)       ; Get FPREG exponent
        OR      A               ; Is this number zero?
        JP      Z,FPBCDE        ; Yes - Move BCDE to FPREG
        SUB     B               ; BCDE number larger?
        JR      NC,NOSWAP       ; No - Don't swap them
        CPL                     ; Two's complement
        INC     A               ;  FP exponent
        EX      DE,HL
        CALL    STAKFP          ; Put FPREG on stack
        EX      DE,HL
        CALL    FPBCDE          ; Move BCDE to FPREG
        POP     BC              ; Restore number from stack
        POP     DE
NOSWAP: CP      24+1            ; Second number insignificant?
        RET     NC              ; Yes - First number is result
        PUSH    AF              ; Save number of bits to scale
        CALL    SIGNS           ; Set MSBs & sign of result
        LD      H,A             ; Save sign of result
        POP     AF              ; Restore scaling factor
        CALL    SCALE           ; Scale BCDE to same exponent
        OR      H               ; Result to be positive?
        LD      HL,FPREG        ; Point to FPREG
        JP      P,MINCDE        ; No - Subtract FPREG from CDE
        CALL    PLUCDE          ; Add FPREG to CDE
        JP      NC,RONDUP       ; No overflow - Round it up
        INC     HL              ; Point to exponent
        INC     (HL)            ; Increment it
        JP      Z,OVERR         ; Number overflowed - Error
        LD      L,1             ; 1 bit to shift right
        CALL    SHRT1           ; Shift result right
        JP      RONDUP          ; Round it up

MINCDE: XOR     A               ; Clear A and carry
        SUB     B               ; Negate exponent
        LD      B,A             ; Re-save exponent
        LD      A,(HL)          ; Get LSB of FPREG
        SBC     A, E            ; Subtract LSB of BCDE
        LD      E,A             ; Save LSB of BCDE
        INC     HL
        LD      A,(HL)          ; Get NMSB of FPREG
        SBC     A,D             ; Subtract NMSB of BCDE
        LD      D,A             ; Save NMSB of BCDE
        INC     HL
        LD      A,(HL)          ; Get MSB of FPREG
        SBC     A,C             ; Subtract MSB of BCDE
        LD      C,A             ; Save MSB of BCDE
CONPOS: CALL    C,COMPL         ; Overflow - Make it positive

BNORM:  LD      L,B             ; L = Exponent
        LD      H,E             ; H = LSB
        XOR     A
BNRMLP: LD      B,A             ; Save bit count
        LD      A,C             ; Get MSB
        OR      A               ; Is it zero?
        JR      NZ,PNORM        ; No - Do it bit at a time
        LD      C,D             ; MSB = NMSB
        LD      D,H             ; NMSB= LSB
        LD      H,L             ; LSB = VLSB
        LD      L,A             ; VLSB= 0
        LD      A,B             ; Get exponent
        SUB     8               ; Count 8 bits
        CP      -24-8           ; Was number zero?
        JR      NZ,BNRMLP       ; No - Keep normalising
RESZER: XOR     A               ; Result is zero
SAVEXP: LD      (FPEXP),A       ; Save result as zero
        RET

NORMAL: DEC     B               ; Count bits
        ADD     HL,HL           ; Shift HL left
        LD      A,D             ; Get NMSB
        RLA                     ; Shift left with last bit
        LD      D,A             ; Save NMSB
        LD      A,C             ; Get MSB
        ADC     A,A             ; Shift left with last bit
        LD      C,A             ; Save MSB
PNORM:  JP      P,NORMAL        ; Not done - Keep going
        LD      A,B             ; Number of bits shifted
        LD      E,H             ; Save HL in EB
        LD      B,L
        OR      A               ; Any shifting done?
        JP      Z,RONDUP        ; No - Round it up
        LD      HL,FPEXP        ; Point to exponent
        ADD     A,(HL)          ; Add shifted bits
        LD      (HL),A          ; Re-save exponent
        JR      NC,RESZER       ; Underflow - Result is zero
        RET     Z               ; Result is zero
RONDUP: LD      A,B             ; Get VLSB of number
RONDB:  LD      HL,FPEXP        ; Point to exponent
        OR      A               ; Any rounding?
        CALL    M,FPROND        ; Yes - Round number up
        LD      B,(HL)          ; B = Exponent
        INC     HL
        LD      A,(HL)          ; Get sign of result
        AND     10000000B       ; Only bit 7 needed
        XOR     C               ; Set correct sign
        LD      C,A             ; Save correct sign in number
        JP      FPBCDE          ; Move BCDE to FPREG

FPROND: INC     E               ; Round LSB
        RET     NZ              ; Return if ok
        INC     D               ; Round NMSB
        RET     NZ              ; Return if ok
        INC     C               ; Round MSB
        RET     NZ              ; Return if ok
        LD      C,80H           ; Set normal value
        INC     (HL)            ; Increment exponent
        RET     NZ              ; Return if ok
        JP      OVERR           ; Overflow error
;------------------------------------------------------------------------------
; ADD FPREG AT (HL) TO BCDE
;------------------------------------------------------------------------------
PLUCDE: LD      A,(HL)          ; Get LSB of FPREG
        ADD     A,E             ; Add LSB of BCDE
        LD      E,A             ; Save LSB of BCDE
        INC     HL
        LD      A,(HL)          ; Get NMSB of FPREG
        ADC     A,D             ; Add NMSB of BCDE
        LD      D,A             ; Save NMSB of BCDE
        INC     HL
        LD      A,(HL)          ; Get MSB of FPREG
        ADC     A,C             ; Add MSB of BCDE
        LD      C,A             ; Save MSB of BCDE
        RET
;------------------------------------------------------------------------------
; Compliment FP number in BCDE
;------------------------------------------------------------------------------
COMPL:  LD      HL,SGNRES       ; Sign of result
        LD      A,(HL)          ; Get sign of result
        CPL                     ; Negate it
        LD      (HL),A          ; Put it back
        XOR     A
        LD      L,A             ; Set L to zero
        SUB     B               ; Negate exponent,set carry
        LD      B,A             ; Re-save exponent
        LD      A,L             ; Load zero
        SBC     A,E             ; Negate LSB
        LD      E,A             ; Re-save LSB
        LD      A,L             ; Load zero
        SBC     A,D             ; Negate NMSB
        LD      D,A             ; Re-save NMSB
        LD      A,L             ; Load zero
        SBC     A,C             ; Negate MSB
        LD      C,A             ; Re-save MSB
        RET
;------------------------------------------------------------------------------
; Rescales BCDE 
;------------------------------------------------------------------------------
SCALE:  LD      B,0             ; Clear underflow
SCALLP: SUB     8               ; 8 bits (a whole byte)?
        JR      C,SHRITE        ; No - Shift right A bits
        LD      B,E             ; <- Shift
        LD      E,D             ; <- right
        LD      D,C             ; <- eight
        LD      C,0             ; <- bits
        JR      SCALLP          ; More bits to shift

SHRITE: ADD     A,8+1           ; Adjust count
        LD      L,A             ; Save bits to shift
SHRLP:  XOR     A               ; Flag for all done
        DEC     L               ; All shifting done?
        RET     Z               ; Yes - Return
        LD      A,C             ; Get MSB
SHRT1:  RRA                     ; Shift it right
        LD      C,A             ; Re-save
        LD      A,D             ; Get NMSB
        RRA                     ; Shift right with last bit
        LD      D,A             ; Re-save it
        LD      A,E             ; Get LSB
        RRA                     ; Shift right with last bit
        LD      E,A             ; Re-save it
        LD      A,B             ; Get underflow
        RRA                     ; Shift right with last bit
        LD      B,A             ; Re-save underflow
        JR      SHRLP           ; More bits to do

UNITY	  defb   $00,$00,$00,$81 ; 1.00000

LOGTAB  defb   3               ; TABLE USED BY LOG
        defb   $AA,$56,$19,$80 ; 0.59898
        defb   $F1,$22,$76,$80 ; 0.96147
        defb   $45,$AA,$38,$82 ; 2.88539
;------------------------------------------------------------------------------
; LOG
;------------------------------------------------------------------------------
LOG:    CALL    TSTSGN          ; Test sign of value
        OR      A
        JP      PE,FCERR        ; ?FC Error if <= zero
        LD      HL,FPEXP        ; Point to exponent
        LD      A,(HL)          ; Get exponent
        LD      BC,8035H        ; BCDE = SQR(1/2)
        LD      DE,04F3H
        SUB     B               ; Scale value to be < 1
        PUSH    AF              ; Save scale factor
        LD      (HL),B          ; Save new exponent
        PUSH    DE              ; Save SQR(1/2)
        PUSH    BC
        CALL    FPADD           ; Add SQR(1/2) to value
        POP     BC              ; Restore SQR(1/2)
        POP     DE
        INC     B               ; Make it SQR(2)
        CALL    DVBCDE          ; Divide by SQR(2)
        LD      HL,UNITY        ; Point to 1.
        CALL    SUBPHL          ; Subtract FPREG from 1
        LD      HL,LOGTAB       ; Coefficient table
        CALL    SUMSER          ; Evaluate sum of series
        LD      BC,8080H        ; BCDE = -0.5
        LD      DE,0000H
        CALL    FPADD           ; Subtract 0.5 from FPREG
        POP     AF              ; Restore scale factor
        CALL    RSCALE          ; Re-scale number
MULLN2: LD      BC,8031H        ; BCDE = Ln(2)
        LD      DE,7218H
        defb     21H             ; Skip "POP BC" and "POP DE"
;------------------------------------------------------------------------------
; FLOATING POINT MULTIPLY
;------------------------------------------------------------------------------
MULT:   POP     BC              ; Get number from stack
        POP     DE
FPMULT: CALL    TSTSGN          ; Test sign of FPREG
        RET     Z               ; Return zero if zero
        LD      L,0             ; Flag add exponents
        CALL    ADDEXP          ; Add exponents
        LD      A,C             ; Get MSB of multiplier
        LD      (MULVAL),A      ; Save MSB of multiplier
        EX      DE,HL
        LD      (MULVAL+1),HL   ; Save rest of multiplier
        LD      BC,0            ; Partial product (BCDE) = zero
        LD      D,B
        LD      E,B
        LD      HL,BNORM        ; Address of normalise
        PUSH    HL              ; Save for return
        LD      HL,MULT8        ; Address of 8 bit multiply
        PUSH    HL              ; Save for NMSB,MSB
        PUSH    HL              ; 
        LD      HL,FPREG        ; Point to number
MULT8:  LD      A,(HL)          ; Get LSB of number
        INC     HL              ; Point to NMSB
        OR      A               ; Test LSB
        JP      Z,BYTSFT        ; Zero - shift to next byte
        PUSH    HL              ; Save address of number
        LD      L,8             ; 8 bits to multiply by
MUL8LP: RRA                     ; Shift LSB right
        LD      H,A             ; Save LSB
        LD      A,C             ; Get MSB
        JR      NC,NOMADD       ; Bit was zero - Don't add
        PUSH    HL              ; Save LSB and count
        LD      HL,(MULVAL+1)   ; Get LSB and NMSB
        ADD     HL,DE           ; Add NMSB and LSB
        EX      DE,HL           ; Leave sum in DE
        POP     HL              ; Restore MSB and count
        LD      A,(MULVAL)      ; Get MSB of multiplier
        ADC     A,C             ; Add MSB
NOMADD: RRA                     ; Shift MSB right
        LD      C,A             ; Re-save MSB
        LD      A,D             ; Get NMSB
        RRA                     ; Shift NMSB right
        LD      D,A             ; Re-save NMSB
        LD      A,E             ; Get LSB
        RRA                     ; Shift LSB right
        LD      E,A             ; Re-save LSB
        LD      A,B             ; Get VLSB
        RRA                     ; Shift VLSB right
        LD      B,A             ; Re-save VLSB
        DEC     L               ; Count bits multiplied
        LD      A,H             ; Get LSB of multiplier
        JR      NZ,MUL8LP       ; More - Do it
POPHRT: POP     HL              ; Restore address of number
        RET

BYTSFT: LD      B,E             ; Shift partial product left
        LD      E,D
        LD      D,C
        LD      C,A
        RET

DIV10:  CALL    STAKFP          ; Save FPREG on stack
        LD      BC,8420H        ; BCDE = 10.
        LD      DE,0000H
        CALL    FPBCDE          ; Move 10 to FPREG
;------------------------------------------------------------------------------
; Division  FPREG = (last) / FPREG
;------------------------------------------------------------------------------
DIV:    POP     BC              ; Get number from stack
        POP     DE
DVBCDE: CALL    TSTSGN          ; Test sign of FPREG
        JP      Z,DZERR         ; Error if division by zero
        LD      L,-1            ; Flag subtract exponents
        CALL    ADDEXP          ; Subtract exponents
        INC     (HL)            ; Add 2 to exponent to adjust
        INC     (HL)
        DEC     HL              ; Point to MSB
        LD      A,(HL)          ; Get MSB of dividend
        LD      (DIV3),A        ; Save for subtraction
        DEC     HL
        LD      A,(HL)          ; Get NMSB of dividend
        LD      (DIV2),A        ; Save for subtraction
        DEC     HL
        LD      A,(HL)          ; Get MSB of dividend
        LD      (DIV1),A        ; Save for subtraction
        LD      B,C             ; Get MSB
        EX      DE,HL           ; NMSB,LSB to HL
        XOR     A
        LD      C,A             ; Clear MSB of quotient
        LD      D,A             ; Clear NMSB of quotient
        LD      E,A             ; Clear LSB of quotient
        LD      (DIV4),A        ; Clear overflow count
DIVLP:  PUSH    HL              ; Save divisor
        PUSH    BC
        LD      A,L             ; Get LSB of number
        CALL    DIVSUP          ; Subt' divisor from dividend
        SBC     A,0             ; Count for overflows
        CCF
        JR      NC,RESDIV       ; Restore divisor if borrow
        LD      (DIV4),A        ; Re-save overflow count
        POP     AF              ; Scrap divisor
        POP     AF
        SCF                     ; Set carry to
        defb     0D2H            ; Skip "POP BC" and "POP HL"

RESDIV: POP     BC              ; Restore divisor
        POP     HL
        LD      A,C             ; Get MSB of quotient
        INC     A
        DEC     A
        RRA                     ; Bit 0 to bit 7
        JP      M,RONDB         ; Done - Normalise result
        RLA                     ; Restore carry
        LD      A,E             ; Get LSB of quotient
        RLA                     ; Double it
        LD      E,A             ; Put it back
        LD      A,D             ; Get NMSB of quotient
        RLA                     ; Double it
        LD      D,A             ; Put it back
        LD      A,C             ; Get MSB of quotient
        RLA                     ; Double it
        LD      C,A             ; Put it back
        ADD     HL,HL           ; Double NMSB,LSB of divisor
        LD      A,B             ; Get MSB of divisor
        RLA                     ; Double it
        LD      B,A             ; Put it back
        LD      A,(DIV4)        ; Get VLSB of quotient
        RLA                     ; Double it
        LD      (DIV4),A        ; Put it back
        LD      A,C             ; Get MSB of quotient
        OR      D               ; Merge NMSB
        OR      E               ; Merge LSB
        JP      NZ,DIVLP        ; Not done - Keep dividing
        PUSH    HL              ; Save divisor
        LD      HL,FPEXP        ; Point to exponent
        DEC     (HL)            ; Divide by 2
        POP     HL              ; Restore divisor
        JP      NZ,DIVLP        ; Ok - Keep going
        JP      OVERR           ; Overflow error

ADDEXP: LD      A,B             ; Get exponent of dividend
        OR      A               ; Test it
        JR      Z,OVTST3        ; Zero - Result zero
        LD      A,L             ; Get add/subtract flag
        LD      HL,FPEXP        ; Point to exponent
        XOR     (HL)            ; Add or subtract it
        ADD     A,B             ; Add the other exponent
        LD      B,A             ; Save new exponent
        RRA                     ; Test exponent for overflow
        XOR     B
        LD      A,B             ; Get exponent
        JP      P,OVTST2        ; Positive - Test for overflow
        ADD     A,80H           ; Add excess 128
        LD      (HL),A          ; Save new exponent
        JP      Z,POPHRT        ; Zero - Result zero
        CALL    SIGNS           ; Set MSBs and sign of result
        LD      (HL),A          ; Save new exponent
        DEC     HL              ; Point to MSB
        RET

OVTST1: CALL    TSTSGN          ; Test sign of FPREG
        CPL                     ; Invert sign
        POP     HL              ; Clean up stack
OVTST2: OR      A               ; Test if new exponent zero
OVTST3: POP     HL              ; Clear off return address
        JP      P,RESZER        ; Result zero
        JP      OVERR           ; Overflow error

MLSP10: CALL    BCDEFP          ; Move FPREG to BCDE
        LD      A,B             ; Get exponent
        OR      A               ; Is it zero?
        RET     Z               ; Yes - Result is zero
        ADD     A,2             ; Multiply by 4
        JP      C,OVERR         ; Overflow - ?OV Error
        LD      B,A             ; Re-save exponent
        CALL    FPADD           ; Add BCDE to FPREG (Times 5)
        LD      HL,FPEXP        ; Point to exponent
        INC     (HL)            ; Double number (Times 10)
        RET     NZ              ; Ok - Return
        JP      OVERR           ; Overflow error

TSTSGN: LD      A,(FPEXP)       ; Get sign of FPREG
        OR      A
        RET     Z               ; RETurn if number is zero
        LD      A,(FPREG+2)     ; Get MSB of FPREG
        defb     0FEH            ; Test sign
RETREL: CPL                     ; Invert sign
        RLA                     ; Sign bit to carry
FLGDIF: SBC     A,A             ; Carry to all bits of A
        RET     NZ              ; Return -1 if negative
        INC     A               ; Bump to +1
        RET                     ; Positive - Return +1
;------------------------------------------------------------------------------
; SGN
;------------------------------------------------------------------------------
SGN:    CALL    TSTSGN          ; Test sign of FPREG
FLGREL: LD      B,80H+8         ; 8 bit integer in exponent
        LD      DE,0            ; Zero NMSB and LSB
RETINT: LD      HL,FPEXP        ; Point to exponent
        LD      C,A             ; CDE = MSB,NMSB and LSB
        LD      (HL),B          ; Save exponent
        LD      B,0             ; CDE = integer to normalise
        INC     HL              ; Point to sign of result
        LD      (HL),80H        ; Set sign of result
        RLA                     ; Carry = sign of integer
        JP      CONPOS          ; Set sign of result
;------------------------------------------------------------------------------
; ABS
;------------------------------------------------------------------------------
ABS:    CALL    TSTSGN          ; Test sign of FPREG
        RET     P               ; Return if positive
INVSGN: LD      HL,FPREG+2      ; Point to MSB
        LD      A,(HL)          ; Get sign of mantissa
        XOR     80H             ; Invert sign of mantissa
        LD      (HL),A          ; Re-save sign of mantissa
        RET
;------------------------------------------------------------------------------
; Saves FPREG to stack
;------------------------------------------------------------------------------
STAKFP: EX      DE,HL           ; Save code string address
        LD      HL,(FPREG)      ; LSB,NLSB of FPREG
        EX      (SP),HL         ; Stack them,get return
        PUSH    HL              ; Re-save return
        LD      HL,(FPREG+2)    ; MSB and exponent of FPREG
        EX      (SP),HL         ; Stack them,get return
        PUSH    HL              ; Re-save return
        EX      DE,HL           ; Restore code string address
        RET
;------------------------------------------------------------------------------
; Loads BCDE to FPREG
;------------------------------------------------------------------------------
PHLTFP: CALL    LOADFP          ; Number at HL to BCDE
FPBCDE: EX      DE,HL           ; Save code string address
        LD      (FPREG),HL      ; Save LSB,NLSB of number
        LD      H,B             ; Exponent of number
        LD      L,C             ; MSB of number
        LD      (FPREG+2),HL    ; Save MSB and exponent
        EX      DE,HL           ; Restore code string address
        RET
;------------------------------------------------------------------------------
; Loads BCDE from FPREG
;------------------------------------------------------------------------------
BCDEFP: LD      HL,FPREG        ; Point to FPREG
LOADFP: LD      E,(HL)          ; Get LSB of number
        INC     HL
        LD      D,(HL)          ; Get NMSB of number
        INC     HL
        LD      C,(HL)          ; Get MSB of number
        INC     HL
        LD      B,(HL)          ; Get exponent of number
INCHL:  INC     HL              ; Used for conditional "INC HL"
        RET
;------------------------------------------------------------------------------
; Moves FPREG to (HL)
;------------------------------------------------------------------------------
FPTHL:  LD      DE,FPREG        ; Point to FPREG
DETHL4: LD      B,4             ; 4 bytes to move
DETHLB: LD      A,(DE)          ; Get source
        LD      (HL),A          ; Save destination
        INC     DE              ; Next source
        INC     HL              ; Next destination
        DEC     B               ; Count bytes
        JR      NZ,DETHLB       ; Loop if more
        RET
;------------------------------------------------------------------------------
SIGNS:  LD      HL,FPREG+2      ; Point to MSB of FPREG
        LD      A,(HL)          ; Get MSB
        RLCA                    ; Old sign to carry
        SCF                     ; Set MSBit
        RRA                     ; Set MSBit of MSB
        LD      (HL),A          ; Save new MSB
        CCF                     ; Complement sign
        RRA                     ; Old sign to carry
        INC     HL
        INC     HL
        LD      (HL),A          ; Set sign of result
        LD      A,C             ; Get MSB
        RLCA                    ; Old sign to carry
        SCF                     ; Set MSBit
        RRA                     ; Set MSBit of MSB
        LD      C,A             ; Save MSB
        RRA
        XOR     (HL)            ; New sign of result
        RET
;------------------------------------------------------------------------------
; Compare two FP numbers BCDE and FPREG with exponents
;------------------------------------------------------------------------------
CMPNUM: LD      A,B             ; Get exponent of number
        OR      A
        JP      Z,TSTSGN        ; Zero - Test sign of FPREG
        LD      HL,RETREL       ; Return relation routine
        PUSH    HL              ; Save for return
        CALL    TSTSGN          ; Test sign of FPREG
        LD      A,C             ; Get MSB of number
        RET     Z               ; FPREG zero - Number's MSB
        LD      HL,FPREG+2      ; MSB of FPREG
        XOR     (HL)            ; Combine signs
        LD      A,C             ; Get MSB of number
        RET     M               ; Exit if signs different
        CALL    CMPFP           ; Compare FP numbers
        RRA                     ; Get carry to sign
        XOR     C               ; Combine with MSB of number
        RET
;------------------------------------------------------------------------------
; Compare BCDE - FPREG, setting Z flag if =
;------------------------------------------------------------------------------
CMPFP:  INC     HL              ; Point to exponent
        LD      A,B             ; Get exponent
        CP      (HL)            ; Compare exponents
        RET     NZ              ; Different
        DEC     HL              ; Point to MBS
        LD      A,C             ; Get MSB
        CP      (HL)            ; Compare MSBs
        RET     NZ              ; Different
        DEC     HL              ; Point to NMSB
        LD      A,D             ; Get NMSB
        CP      (HL)            ; Compare NMSBs
        RET     NZ              ; Different
        DEC     HL              ; Point to LSB
        LD      A,E             ; Get LSB
        SUB     (HL)            ; Compare LSBs
        RET     NZ              ; Different
        POP     HL              ; Drop RETurn
        POP     HL              ; Drop another RETurn
        RET
;------------------------------------------------------------------------------
; Convert FPREG to FPREG 24 Bit Integer format
;------------------------------------------------------------------------------
FPINT:  LD      B,A             ; <- Move
        LD      C,A             ; <- exponent
        LD      D,A             ; <- to all
        LD      E,A             ; <- bits
        OR      A               ; Test exponent
        RET     Z               ; Zero - Return zero
        PUSH    HL              ; Save pointer to number
        CALL    BCDEFP          ; Move FPREG to BCDE
        CALL    SIGNS           ; Set MSBs & sign of result
        XOR     (HL)            ; Combine with sign of FPREG
        LD      H,A             ; Save combined signs
        CALL    M,DCBCDE        ; Negative - Decrement BCDE
        LD      A,80H+24        ; 24 bits
        SUB     B               ; Bits to shift
        CALL    SCALE           ; Shift BCDE
        LD      A,H             ; Get combined sign
        RLA                     ; Sign to carry
        CALL    C,FPROND        ; Negative - Round number up
        LD      B,0             ; Zero exponent
        CALL    C,COMPL         ; If negative make positive
        POP     HL              ; Restore pointer to number
        RET
;------------------------------------------------------------------------------
; Decrement BCDE number
;------------------------------------------------------------------------------
DCBCDE: DEC     DE              ; Decrement BCDE
        LD      A,D             ; Test LSBs
        AND     E
        INC     A
        RET     NZ              ; Exit if LSBs not FFFF
        DEC     BC              ; Decrement MSBs
        RET
;------------------------------------------------------------------------------
; INT
;------------------------------------------------------------------------------
INT:    LD      HL,FPEXP        ; Point to exponent
        LD      A,(HL)          ; Get exponent
        CP      80H+24          ; Integer accuracy only?
        LD      A,(FPREG)       ; Get LSB
        RET     NC              ; Yes - Already integer
        LD      A,(HL)          ; Get exponent
        CALL    FPINT           ; F.P to integer
        LD      (HL),80H+24     ; Save 24 bit integer
        LD      A,E             ; Get LSB of number
        PUSH    AF              ; Save LSB
        LD      A,C             ; Get MSB of number
        RLA                     ; Sign to carry
        CALL    CONPOS          ; Set sign of result
        POP     AF              ; Restore LSB of number
        RET

MLDEBC: LD      HL,0            ; Clear partial product
        LD      A,B             ; Test multiplier
        OR      C
        RET     Z               ; Return zero if zero
        LD      A,16            ; 16 bits
MLDBLP: ADD     HL,HL           ; Shift P.P left
        JP      C,BSERR         ; ?BS Error if overflow
        EX      DE,HL
        ADD     HL,HL           ; Shift multiplier left
        EX      DE,HL
        JR      NC,NOMLAD       ; Bit was zero - No add
        ADD     HL,BC           ; Add multiplicand
        JP      C,BSERR         ; ?BS Error if overflow
NOMLAD: DEC     A               ; Count bits
        JR      NZ,MLDBLP       ; More
        RET
;------------------------------------------------------------------------------
; Converts ASCII number to FP for computations
;------------------------------------------------------------------------------
ASCTFP: CP      '-'             ; Negative?
        PUSH    AF              ; Save it and flags
        JP      Z,CNVNUM        ; Yes - Convert number
        CP      '+'             ; Positive?
        JR      Z,CNVNUM        ; Yes - Convert number
        DEC     HL              ; DEC 'cos GETCHR INCs
CNVNUM: CALL    RESZER          ; Set result to zero
        LD      B,A             ; Digits after point counter
        LD      D,A             ; Sign of exponent
        LD      E,A             ; Exponent of ten
        CPL
        LD      C,A             ; Before or after point flag
MANLP:  CALL    GETCHR          ; Get next character
        JR      C,ADDIG         ; Digit - Add to number
        CP      '.'
        JR      Z,DPOINT        ; "." - Flag point
        CP      'E'
        JR      NZ,CONEXP       ; Not "E" - Scale number
        CALL    GETCHR          ; Get next character
        CALL    SGNEXP          ; Get sign of exponent
EXPLP:  CALL    GETCHR          ; Get next character
        JR      C,EDIGIT        ; Digit - Add to exponent
        INC     D               ; Is sign negative?
        JR      NZ,CONEXP       ; No - Scale number
        XOR     A
        SUB     E               ; Negate exponent
        LD      E,A             ; And re-save it
        INC     C               ; Flag end of number
DPOINT: INC     C               ; Flag point passed
        JR      Z,MANLP         ; Zero - Get another digit
CONEXP: PUSH    HL              ; Save code string address
        LD      A,E             ; Get exponent
        SUB     B               ; Subtract digits after point
SCALMI: CALL    P,SCALPL        ; Positive - Multiply number
        JP      P,ENDCON        ; Positive - All done
        PUSH    AF              ; Save number of times to /10
        CALL    DIV10           ; Divide by 10
        POP     AF              ; Restore count
        INC     A               ; Count divides

ENDCON: JR      NZ,SCALMI       ; More to do
        POP     DE              ; Restore code string address
        POP     AF              ; Restore sign of number
        CALL    Z,INVSGN        ; Negative - Negate number
        EX      DE,HL           ; Code string address to HL
        RET

SCALPL: RET     Z               ; Exit if no scaling needed
MULTEN: PUSH    AF              ; Save count
        CALL    MLSP10          ; Multiply number by 10
        POP     AF              ; Restore count
        DEC     A               ; Count multiplies
        RET

ADDIG:  PUSH    DE              ; Save sign of exponent
        LD      D,A             ; Save digit
        LD      A,B             ; Get digits after point
        ADC     A,C             ; Add one if after point
        LD      B,A             ; Re-save counter
        PUSH    BC              ; Save point flags
        PUSH    HL              ; Save code string address
        PUSH    DE              ; Save digit
        CALL    MLSP10          ; Multiply number by 10
        POP     AF              ; Restore digit
        SUB     $30             ; Make it absolute
        CALL    RSCALE          ; Re-scale number
        POP     HL              ; Restore code string address
        POP     BC              ; Restore point flags
        POP     DE              ; Restore sign of exponent
        JR      MANLP           ; Get another digit

RSCALE: CALL    STAKFP          ; Put number on stack
        CALL    FLGREL          ; Digit to add to FPREG
;------------------------------------------------------------------------------
; FP Addition
;------------------------------------------------------------------------------        
PADD:   POP     BC              ; Restore number
        POP     DE
        JP      FPADD           ; Add BCDE to FPREG and return

EDIGIT: LD      A,E             ; Get digit
        RLCA                    ; Times 2
        RLCA                    ; Times 4
        ADD     A,E             ; Times 5
        RLCA                    ; Times 10
        ADD     A,(HL)          ; Add next digit
        SUB     $30             ; Make it absolute
        LD      E,A             ; Save new digit
        JP      EXPLP           ; Look for another digit
;------------------------------------------------------------------------------
; Prints " in " + Line number in HL for Error Handling
;------------------------------------------------------------------------------
LINEIN: PUSH    HL              ; Save code string address
        LD      HL,INMSG        ; Output " in "
        CALL    PRS             ; Output string at HL
        POP     HL              ; Restore code string address
;------------------------------------------------------------------------------
; Convert HL to ASCII and Print
;------------------------------------------------------------------------------        
PRNTHL: EX      DE,HL           ; Code string address to DE
        XOR     A
        LD      B,80H+24        ; 24 bits
        CALL    RETINT          ; Return the integer
        LD      HL,PRNUMS       ; Print number string
        PUSH    HL              ; Save for return
;------------------------------------------------------------------------------
; Convert FPREG to ASCII in PBUFF
;------------------------------------------------------------------------------
NUMASC: LD      HL,PBUFF        ; Convert number to ASCII
        PUSH    HL              ; Save for return
        CALL    TSTSGN          ; Test sign of FPREG
        LD      (HL),$20        ; Space at start
        JP      P,SPCFST        ; Positive - Space to start
        LD      (HL),'-'        ; "-" sign at start
SPCFST: INC     HL              ; First byte of number
        LD      (HL),'0'        ; "0" if zero
        JP      Z,JSTZER        ; Return "0" if zero
        PUSH    HL              ; Save buffer address
        CALL    M,INVSGN        ; Negate FPREG if negative
        XOR     A               ; Zero A
        PUSH    AF              ; Save it
        CALL    RNGTST          ; Test number is in range
SIXDIG: LD      BC,9143H        ; BCDE - 99999.9
        LD      DE,4FF8H
        CALL    CMPNUM          ; Compare numbers
        OR      A
        JP      PO,INRNG        ; > 99999.9 - Sort it out
        POP     AF              ; Restore count
        CALL    MULTEN          ; Multiply by ten
        PUSH    AF              ; Re-save count
        JR      SIXDIG          ; Test it again

GTSIXD: CALL    DIV10           ; Divide by 10
        POP     AF              ; Get count
        INC     A               ; Count divides
        PUSH    AF              ; Re-save count
        CALL    RNGTST          ; Test number is in range
INRNG:  CALL    ROUND           ; Add 0.5 to FPREG
        INC     A
        CALL    FPINT           ; F.P to integer
        CALL    FPBCDE          ; Move BCDE to FPREG
        LD      BC,0306H        ; 1E+06 to 1E-03 range
        POP     AF              ; Restore count
        ADD     A,C             ; 6 digits before point
        INC     A               ; Add one
        JP      M,MAKNUM        ; Do it in "E" form if < 1E-02
        CP      6+1+1           ; More than 999999 ?
        JP      NC,MAKNUM       ; Yes - Do it in "E" form
        INC     A               ; Adjust for exponent
        LD      B,A             ; Exponent of number
        LD      A,2             ; Make it zero after

MAKNUM: DEC     A               ; Adjust for digits to do
        DEC     A
        POP     HL              ; Restore buffer address
        PUSH    AF              ; Save count
        LD      DE,POWERS       ; Powers of ten
        DEC     B               ; Count digits before point
        JR      NZ,DIGTXT       ; Not zero - Do number
        LD      (HL),'.'        ; Save point
        INC     HL              ; Move on
        LD      (HL),'0'        ; Save zero
        INC     HL              ; Move on
DIGTXT: DEC     B               ; Count digits before point
        LD      (HL),'.'        ; Save point in case
        CALL    Z,INCHL         ; Last digit - move on
        PUSH    BC              ; Save digits before point
        PUSH    HL              ; Save buffer address
        PUSH    DE              ; Save powers of ten
        CALL    BCDEFP          ; Move FPREG to BCDE
        POP     HL              ; Powers of ten table
        LD      B,'0'-1         ; ASCII "0" - 1
TRYAGN: INC     B               ; Count subtractions
        LD      A,E             ; Get LSB
        SUB     (HL)            ; Subtract LSB
        LD      E,A             ; Save LSB
        INC     HL
        LD      A,D             ; Get NMSB
        SBC     A,(HL)          ; Subtract NMSB
        LD      D,A             ; Save NMSB
        INC     HL
        LD      A,C             ; Get MSB
        SBC     A,(HL)          ; Subtract MSB
        LD      C,A             ; Save MSB
        DEC     HL              ; Point back to start
        DEC     HL
        JR      NC,TRYAGN       ; No overflow - Try again
        CALL    PLUCDE          ; Restore number
        INC     HL              ; Start of next number
        CALL    FPBCDE          ; Move BCDE to FPREG
        EX      DE,HL           ; Save point in table
        POP     HL              ; Restore buffer address
        LD      (HL),B          ; Save digit in buffer
        INC     HL              ; And move on
        POP     BC              ; Restore digit count
        DEC     C               ; Count digits
        JR      NZ,DIGTXT       ; More - Do them
        DEC     B               ; Any decimal part?
        JR      Z,DOEBIT        ; No - Do "E" bit
SUPTLZ: DEC     HL              ; Move back through buffer
        LD      A,(HL)          ; Get character
        CP      $30             ; "0" character?
        JR      Z,SUPTLZ        ; Yes - Look back for more
        CP      '.'             ; A decimal point?
        CALL    NZ,INCHL        ; Move back over digit

DOEBIT: POP     AF              ; Get "E" flag
        JR      Z,NOENED        ; No "E" needed - End buffer
        LD      (HL),'E'        ; Put "E" in buffer
        INC     HL              ; And move on
        LD      (HL),'+'        ; Put '+' in buffer
        JP      P,OUTEXP        ; Positive - Output exponent
        LD      (HL),'-'        ; Put "-" in buffer
        CPL                     ; Negate exponent
        INC     A
OUTEXP: LD      B,$2F           ; ASCII "0" - 1
EXPTEN: INC     B               ; Count subtractions
        SUB     10              ; Tens digit
        JR      NC,EXPTEN       ; More to do
        ADD     A,$30+10        ; Restore and make ASCII
        INC     HL              ; Move on
        LD      (HL),B          ; Save MSB of exponent
JSTZER: INC     HL              ;
        LD      (HL),A          ; Save LSB of exponent
        INC     HL
NOENED: LD      (HL),C          ; Mark end of buffer
        POP     HL              ; Restore code string address
        RET

RNGTST: LD      BC,9474H        ; BCDE = 999999.
        LD      DE,23F7H
        CALL    CMPNUM          ; Compare numbers
        OR      A
        POP     HL              ; Return address to HL
        JP      PO,GTSIXD       ; Too big - Divide by ten
        JP      (HL)            ; Otherwise return to caller
;------------------------------------------------------------------------------
;  FP REGISTERS  E   D   C   B
HALF	defb	$00,$00,$00,$80	;0.5
;------------------------------------------------------------------------------
POWERS	defb	$A0,$86,$01	; 100000
	defb	$10,$27,$00	;  10000
	defb	$E8,$03,$00	;   1000
	defb	$64,$00,$00	;    100
	defb	$0A,$00,$00	;     10
	defb	$01,$00,$00	;      1
;------------------------------------------------------------------------------	
NEGAFT: LD  HL,INVSGN           ; Negate result
        EX      (SP),HL         ; To be done after caller
        JP      (HL)            ; Return to caller
;------------------------------------------------------------------------------
; SQR
;------------------------------------------------------------------------------
SQR:    CALL    STAKFP          ; Put value on stack
        LD      HL,HALF         ; Set power to 1/2
        CALL    PHLTFP          ; Move 1/2 to FPREG
;------------------------------------------------------------------------------
; FPREG = (last) ^ FPREG
;------------------------------------------------------------------------------
POWER:  POP     BC              ; Get base
        POP     DE
        CALL    TSTSGN          ; Test sign of power
        LD      A,B             ; Get exponent of base
        JR      Z,EXP           ; Make result 1 if zero
        JP      P,POWER1        ; Positive base - Ok
        OR      A               ; Zero to negative power?
        JP      Z,DZERR         ; Yes - ?/0 Error
POWER1: OR      A               ; Base zero?
        JP      Z,SAVEXP        ; Yes - Return zero
        PUSH    DE              ; Save base
        PUSH    BC
        LD      A,C             ; Get MSB of base
        OR      01111111B       ; Get sign status
        CALL    BCDEFP          ; Move power to BCDE
        JP      P,POWER2        ; Positive base - Ok
        PUSH    DE              ; Save power
        PUSH    BC
        CALL    INT             ; Get integer of power
        POP     BC              ; Restore power
        POP     DE
        PUSH    AF              ; MSB of base
        CALL    CMPNUM          ; Power an integer?
        POP     HL              ; Restore MSB of base
        LD      A,H             ; but don't affect flags
        RRA                     ; Exponent odd or even?
POWER2: POP     HL              ; Restore MSB and exponent
        LD      (FPREG+2),HL    ; Save base in FPREG
        POP     HL              ; LSBs of base
        LD      (FPREG),HL      ; Save in FPREG
        CALL    C,NEGAFT        ; Odd power - Negate result
        CALL    Z,INVSGN        ; Negative base - Negate it
        PUSH    DE              ; Save power
        PUSH    BC
        CALL    LOG             ; Get LOG of base
        POP     BC              ; Restore power
        POP     DE
        CALL    FPMULT          ; Multiply LOG by power
;------------------------------------------------------------------------------
; EXP
;------------------------------------------------------------------------------
EXP:    CALL    STAKFP          ; Put value on stack
        LD      BC,$8138        ; BCDE = 1/Ln(2)
        LD      DE,$AA3B
        CALL    FPMULT          ; Multiply value by 1/LN(2)
        LD      A,(FPEXP)       ; Get exponent
        CP      80H+8           ; Is it in range?
        JP      NC,OVTST1       ; No - Test for overflow
        CALL    INT             ; Get INT of FPREG
        ADD     A,80H           ; For excess 128
        ADD     A,2             ; Exponent > 126?
        JP      C,OVTST1        ; Yes - Test for overflow
        PUSH    AF              ; Save scaling factor
        LD      HL,UNITY        ; Point to 1.
        CALL    ADDPHL          ; Add 1 to FPREG
        CALL    MULLN2          ; Multiply by LN(2)
        POP     AF              ; Restore scaling factor
        POP     BC              ; Restore exponent
        POP     DE
        PUSH    AF              ; Save scaling factor
        CALL    SUBCDE          ; Subtract exponent from FPREG
        CALL    INVSGN          ; Negate result
        LD      HL,EXPTAB       ; Coefficient table
        CALL    SMSER1          ; Sum the series
        LD      DE,0            ; Zero LSBs
        POP     BC              ; Scaling factor
        LD      C,D             ; Zero MSB
        JP      FPMULT          ; Scale result to correct value

EXPTAB: defb     8                   ; Table used by EXP
        defb     $40,$2E,$94,$74     ; -1/7! (-1/5040)
        defb     $70,$4F,$2E,$77     ;  1/6! ( 1/720)
        defb     $6E,$02,$88,$7A     ; -1/5! (-1/120)
        defb     $E6,$A0,$2A,$7C     ;  1/4! ( 1/24)
        defb     $50,$AA,$AA,$7E     ; -1/3! (-1/6)
        defb     $FF,$FF,$7F,$7F     ;  1/2! ( 1/2)
        defb     $00,$00,$80,$81     ; -1/1! (-1/1)
        defb     $00,$00,$00,$81     ;  1/0! ( 1/1)

SUMSER: CALL    STAKFP          ; Put FPREG on stack
        LD      DE,MULT         ; Multiply by "X"
        PUSH    DE              ; To be done after
        PUSH    HL              ; Save address of table
        CALL    BCDEFP          ; Move FPREG to BCDE
        CALL    FPMULT          ; Square the value
        POP     HL              ; Restore address of table
SMSER1: CALL    STAKFP          ; Put value on stack
        LD      A,(HL)          ; Get number of coefficients
        INC     HL              ; Point to start of table
        CALL    PHLTFP          ; Move coefficient to FPREG
        defb     06H             ; Skip "POP AF"
SUMLP:  POP     AF              ; Restore count
        POP     BC              ; Restore number
        POP     DE
        DEC     A               ; Cont coefficients
        RET     Z               ; All done
        PUSH    DE              ; Save number
        PUSH    BC
        PUSH    AF              ; Save count
        PUSH    HL              ; Save address in table
        CALL    FPMULT          ; Multiply FPREG by BCDE
        POP     HL              ; Restore address in table
        CALL    LOADFP          ; Number at HL to BCDE
        PUSH    HL              ; Save address in table
        CALL    FPADD           ; Add coefficient to FPREG
        POP     HL              ; Restore address in table
        JR      SUMLP           ; More coefficients
;------------------------------------------------------------------------------
; Random number generator
;------------------------------------------------------------------------------        
RND:    CALL    TSTSGN          ; Test sign of FPREG
        LD      HL,SEED+2       ; Random number seed
        JP      M,RESEED        ; Negative - Re-seed
        LD      HL,LSTRND       ; Last random number
        CALL    PHLTFP          ; Move last RND to FPREG
        LD      HL,SEED+2       ; Random number seed
        RET     Z               ; Return if RND(0)
        ADD     A,(HL)          ; Add (SEED)+2)
        AND     00000111B       ; 0 to 7
        LD      B,0
        LD      (HL),A          ; Re-save seed
        INC     HL              ; Move to coefficient table
        ADD     A,A             ; 4 bytes
        ADD     A,A             ; per entry
        LD      C,A             ; BC = Offset into table
        ADD     HL,BC           ; Point to coefficient
        CALL    LOADFP          ; Coefficient to BCDE
        CALL    FPMULT  ;       ; Multiply FPREG by coefficient
        LD      A,(SEED+1)      ; Get (SEED+1)
        INC     A               ; Add 1
        AND     00000011B       ; 0 to 3
        LD      B,0
        CP      1               ; Is it zero?
        ADC     A,B             ; Yes - Make it 1
        LD      (SEED+1),A      ; Re-save seed
        LD      HL,RNDTAB-4     ; Addition table
        ADD     A,A             ; 4 bytes
        ADD     A,A             ; per entry
        LD      C,A             ; BC = Offset into table
        ADD     HL,BC           ; Point to value
        CALL    ADDPHL          ; Add value to FPREG
RND1:   CALL    BCDEFP          ; Move FPREG to BCDE
        LD      A,E             ; Get LSB
        LD      E,C             ; LSB = MSB
        XOR     01001111B       ; Fiddle around
        LD      C,A             ; New MSB
        LD      (HL),80H        ; Set exponent
        DEC     HL              ; Point to MSB
        LD      B,(HL)          ; Get MSB
        LD      (HL),80H        ; Make value -0.5
        LD      HL,SEED         ; Random number seed
        INC     (HL)            ; Count seed
        LD      A,(HL)          ; Get seed
        SUB     171             ; Do it modulo 171
        JR      NZ,RND2         ; Non-zero - Ok
        LD      (HL),A          ; Zero seed
        INC     C               ; Fillde about
        DEC     D               ; with the
        INC     E               ; number
RND2:   CALL    BNORM           ; Normalise number
        LD      HL,LSTRND       ; Save random number
        JP      FPTHL           ; Move FPREG to last and return

RESEED: LD      (HL),A          ; Re-seed random numbers
        DEC     HL
        LD      (HL),A
        DEC     HL
        LD      (HL),A
        JR      RND1            ; Return RND seed

RNDTAB: defb     068H,0B1H,046H,068H     ; Table used by RND
        defb     099H,0E9H,092H,069H
        defb     010H,0D1H,075H,068H
;------------------------------------------------------------------------------
; COS, SIN
;------------------------------------------------------------------------------
COS:    LD      HL,HALFPI       ; Point to PI/2
        CALL    ADDPHL          ; Add it to PPREG
SIN:    CALL    STAKFP          ; Put angle on stack
        LD      BC,8349H        ; BCDE = 2 PI
        LD      DE,0FDBH
        CALL    FPBCDE          ; Move 2 PI to FPREG
        POP     BC              ; Restore angle
        POP     DE
        CALL    DVBCDE          ; Divide angle by 2 PI
        CALL    STAKFP          ; Put it on stack
        CALL    INT             ; Get INT of result
        POP     BC              ; Restore number
        POP     DE
        CALL    SUBCDE          ; Make it 0 <= value < 1
        LD      HL,QUARTR       ; Point to 0.25
        CALL    SUBPHL          ; Subtract value from 0.25
        CALL    TSTSGN          ; Test sign of value
        SCF                     ; Flag positive
        JP      P,SIN1          ; Positive - Ok
        CALL    ROUND           ; Add 0.5 to value
        CALL    TSTSGN          ; Test sign of value
        OR      A               ; Flag negative
SIN1:   PUSH    AF              ; Save sign
        CALL    P,INVSGN        ; Negate value if positive
        LD      HL,QUARTR       ; Point to 0.25
        CALL    ADDPHL          ; Add 0.25 to value
        POP     AF              ; Restore sign
        CALL    NC,INVSGN       ; Negative - Make positive
        LD      HL,SINTAB       ; Coefficient table
        JP      SUMSER          ; Evaluate sum of series

HALFPI: defb     0DBH,00FH,049H,081H     ; 1.5708 (PI/2)

QUARTR: defb     000H,000H,000H,07FH     ; 0.25

SINTAB: defb     5                       ; Table used by SIN
        defb     0BAH,0D7H,01EH,086H     ; 39.711
        defb     064H,026H,099H,087H     ;-76.575
        defb     058H,034H,023H,087H     ; 81.602
        defb     0E0H,05DH,0A5H,086H     ;-41.342
        defb     0DAH,00FH,049H,083H     ;  6.2832
;------------------------------------------------------------------------------
; TANgent
;------------------------------------------------------------------------------
TAN:    CALL    STAKFP          ; Put angle on stack
        CALL    SIN             ; Get SIN of angle
        POP     BC              ; Restore angle
        POP     HL
        CALL    STAKFP          ; Save SIN of angle
        EX      DE,HL           ; BCDE = Angle
        CALL    FPBCDE          ; Angle to FPREG
        CALL    COS             ; Get COS of angle
        JP      DIV             ; TAN = SIN / COS
;------------------------------------------------------------------------------
; Arctangent
;------------------------------------------------------------------------------
ATN:    CALL    TSTSGN          ; Test sign of value
        CALL    M,NEGAFT        ; Negate result after if -ve
        CALL    M,INVSGN        ; Negate value if -ve
        LD      A,(FPEXP)       ; Get exponent
        CP      81H             ; Number less than 1?
        JP      C,ATN1          ; Yes - Get arc tangnt
        LD      BC,8100H        ; BCDE = 1
        LD      D,C
        LD      E,C
        CALL    DVBCDE          ; Get reciprocal of number
        LD      HL,SUBPHL       ; Sub angle from PI/2
        PUSH    HL              ; Save for angle > 1
ATN1:   LD      HL,ATNTAB       ; Coefficient table
        CALL    SUMSER          ; Evaluate sum of series
        LD      HL,HALFPI       ; PI/2 - angle in case > 1
        RET                     ; Number > 1 - Sub from PI/2

ATNTAB: defb     9                       ; Table used by ATN
        defb     04AH,0D7H,03BH,078H     ; 1/17
        defb     002H,06EH,084H,07BH     ;-1/15
        defb     0FEH,0C1H,02FH,07CH     ; 1/13
        defb     074H,031H,09AH,07DH     ;-1/11
        defb     084H,03DH,05AH,07DH     ; 1/9
        defb     0C8H,07FH,091H,07EH     ;-1/7
        defb     0E4H,0BBH,04CH,07EH     ; 1/5
        defb     06CH,0AAH,0AAH,07FH     ;-1/3
        defb     000H,000H,000H,081H     ; 1/1
;------------------------------------------------------------------------------
;  End of F L O A T I N G    P O I N T   M A T H
;------------------------------------------------------------------------------        

;------------------------------------------------------------------------------
; HARDWARE SPECIFIC ROUTINES
;------------------------------------------------------------------------------
WAITCR	CALL	DSCONIN		; Get a character in
	CP	$03		; Is it <Break>?
	JP	Z,PRNTOK	; Go to prompt
	CP	$0D		; Is it <Enter>?
	JR	NZ,WAITCR	; No, keep looking
	RET			; Yes, return to calling routine
;------------------------------------------------------------------------------
; OUTPUT CHARACTER ROUTINE
;------------------------------------------------------------------------------
OUTC:   PUSH    AF              ; Save character
        LD      A,(CTLOFG)      ; Get control "O" flag
        OR      A               ; Is it set?
        JP      NZ,POPAF        ; Yes - don't output
        POP     AF              ; Restore character
        PUSH    BC              ; Save buffer length
        PUSH    AF              ; Save character
        CP      $20             ; Is it a control code?
        JR      C,DINPOS        ; Yes - Don't INC POS(X)
        LD      A,(LWIDTH)      ; Get line width
        LD      B,A             ; To B
        LD      A,(CURPOS)      ; Get cursor position
        INC     B               ; Width 255?
        JR      Z,INCLEN        ; Yes - No width limit
        DEC     B               ; Restore width
        CP      B               ; At end of line?
        CALL    Z,PRNTCR        ; Yes - output CRLF
INCLEN: INC     A               ; Move on one character
        LD      (CURPOS),A      ; Save new position
DINPOS: POP     AF              ; Restore character
        POP     BC              ; Restore buffer length
        PUSH    AF              ; Save character
        PUSH    BC              ; Save buffer length
        LD      C,A             ; Character to C

	CALL	DSCONOUT	; Send it

        POP     BC              ; Restore buffer length
        POP     AF              ; Restore character
        RET
;------------------------------------------------------------------------------
; INPUT CHARACTER ROUTINE
;------------------------------------------------------------------------------
CLOTST: CALL	DSCONIN             ; Get input character
        CP      CTRLO           ; Is it control "O"?
        RET     NZ              ; No don't flip flag
        LD      A,(CTLOFG)      ; Get flag
        CPL                     ; Flip it
        LD      (CTLOFG),A      ; Put it back
        XOR     A               ; Null character
        RET
;------------------------------------------------------------------------------	
; NMI Vectors to here
;------------------------------------------------------------------------------	
BREAK:  PUSH    AF              ; Save character
        LD      A,$FF		; Set the break flag
        LD      (BRKFLG),A      ; Flag break
        POP     AF              ; Restore character

ARETN:  RETN                    ; Return from NMI
;------------------------------------------------------------------------------
; SCREEN (ABREVIATED, THIS ROUTINE USELESS FOR THIS SBC)
;------------------------------------------------------------------------------
SCREEN: CALL    GETINT          ; Get integer 0 to 255
        PUSH    AF              ; Save column
        CALL    CHKSYN          ; Make sure "," follows
        defb   ','
        CALL    GETINT          ; Get integer 0 to 255
        RET
;------------------------------------------------------------------------------
; Set a pixel at X,Y
;------------------------------------------------------------------------------
PSET	CALL	GETXY		; GET (X,Y)
	NOP			; REST OF CODE HERE
	RET
;------------------------------------------------------------------------------
; Clear a pixel at X,Y
;------------------------------------------------------------------------------
RESET	CALL	GETXY		; GET (X,Y)
	NOP			; REST OF CODE HERE
	RET
;------------------------------------------------------------------------------
; Check if pixel is set at X,Y
;------------------------------------------------------------------------------
POINT	CALL	GETXY		; GET (X,Y)
	XOR	A		; ZERO OUT A
	LD	B,A		; SET AB TO $0000
	CALL	ABPASS		; PASS THE ZERO BACK TO THE PROGRAM
	NOP			; REST OF CODE HERE
	RET
;------------------------------------------------------------------------------
GETXY   CALL    GETNUM          ; Get a number
        CALL    DEINT           ; Get integer -32768 to 32767
        LD	(X1POS),DE	; Save X value
        CALL    CHKSYN          ; Make sure "," follows
        defb	','
        CALL    GETNUM          ; Get a number
        CALL    DEINT           ; Get integer -32768 to 32767
	LD	(Y1POS),DE	; Save Y value
	RET        
;------------------------------------------------------------------------------
; LOAD Program
;------------------------------------------------------------------------------
LOAD	CP	ZTIMES		; "*" token?
	JP	Z,SNERR		; Yes, Sorry we don't handle Array Loads
	CALL	CLRPTR		; No, it's a new program, perform "NEW"
	
	EX	AF,AF'		; Save registers to alternate set AF
	EXX			; Save BC,DE,HL
	LD	HL,TLOAD	; Get "Send Program file now." text
	CALL	PRS		; Print it

	CALL	LOADA		; Load INTEL hex file

	EXX			; Reclaim the registers BC,DE,HL
	EX	AF,AF'		; Reclaim registers AF
	JP	WARMST		; Warm start the new program
;------------------------------------------------------------------------------
; SAVE Program
;------------------------------------------------------------------------------
SAVE	CP	ZTIMES		; "*" Token following? ("SAVE*")
	JP	Z,SNERR		; Yes, We have no Array SAve
	PUSH	HL		; Save code string address
	EX	AF,AF'		; Save registers AF	
	EXX			; Save BC,DE,HL
	LD	DE,(PROGST)	; START OF PROGRAM	
	LD	HL,(PROGND)	; END OF PROGRAM
		
	CALL	SINTLX		; DO THE INTEL HEX SAVE
	
	EXX			; Reclaim BC,DE,HL
	EX	AF,AF'		; Reclaim AF
	POP	HL		; Reclaim code string address
	RET			; Finished, return to BASIC
;------------------------------------------------------------------------------
; S A V E    I N T E L    H E X    R E C O R D S 
;   HL=START,DE=END
;   INTEL HEX FORMAT - EACH LINE STARTS WITH A COLON ":" AND CONTAINS
;   :LLAAAATTDDDDDDDDDDDDDDCC WHERE LL=RECORD LENGTH, AAAA=RECORD ADDRESS, 
;   DD=DATA IN ASCII HEX, CC=CHECKSUM ALL HEX VALUE BYTES SHOULD ADD UP TO $00
;------------------------------------------------------------------------------
SINTLX	XOR	A		; CLEAR ACCUM AND FLAGS
	PUSH	DE		; TEMP SAVE START ADDRESS
	SBC	HL,DE		; HL= END-START
	LD	D,H		; TRANSFER TO DE
	LD	E,L
	POP	HL		; PUT START ADDRESS INTO HL
SAVE1	LD	A,D		; ARE WE SAVING < $100 BYTES?
	OR	A		; TEST D
	JR	Z,LSTREC	; LAST RECORD

	LD	A,$FF		; OTHERWISE, RECORD LENGTH = $FF
	CALL	DMPREC		; WRITE THE NEXT $FF BYTES RECORD
	JR	SAVE1		; KEEP GOING UNTIL FINISHED	

LSTREC	LD	A,E		; BETWEEN $00 AND $FF BYTES LEFT TO SAVE
	CALL	DMPREC		; DUMP THE FINAL RECORD

	LD	A,$0D		; CREATE THE CLOSING LINE
	CALL	DSCONOUT	; PRINT THE CR
	LD	A,$0A		; LOAD A LF
	CALL	DSCONOUT	; PRINT IT
	LD	A,':'		; EOF LINE
	CALL	DSCONOUT	; PRINT THE COLON AT START OF LINE
	XOR	A		; RECORD LENGTH = $00
	CALL 	HEXOUT		; OUTPUT IT
	XOR	A		; ADDRESS=$0000
	CALL	HEXOUT		; OUTPUT IT
	XOR	A		; OUTPUT IT AGAIN
	CALL	HEXOUT		; FINISH ADDRESS
	LD	A,$01		; EOF INDICATION
	CALL	HEXOUT		; OUTPUT THAT
	LD	A,$FF		; FAKE THE CHECKSUM
	CALL	HEXOUT		; OUTPUT THE FINAL BYTE
	LD	A,$0D		; CARRIAGE RET
	CALL	DSCONOUT
	LD	A,$0A		; LF
	CALL	DSCONOUT
	RET			; FINISHED AT LAST
;------------------------------------------------------------------------------
; ENTER WITH A=# OF BYTES IN RECORD, HL POINTS AT START OF RECORD TO SAVE
;------------------------------------------------------------------------------
DMPREC	LD	B,A		; SAVE LENGTH IN B
	LD	A,$0D		; PRINT CR
	CALL	DSCONOUT	; OUTPUT
	LD	A,$0A		; PRINT LF
	CALL	DSCONOUT	; OUTPUT
	LD	A,':'		; COLON IS START OF LINE
	CALL	DSCONOUT	; OUTPUT IT
	LD	A,B		; GET LENGTH BACK
	LD	C,A		; START THE CHECKSUM
	CALL	HEXOUT		; WRITE (ACCUM) THE LENGTH OUT
	CALL	HLHEX		; OUTPUT HL IN HEX
	LD	A,C		; GET CHECKSUM
	ADD	A,H		; ADD HIGH ADDRESS
	ADD	A,L		; ADD LOW  ADDRESS
	LD	C,A		; SAVE NEW CHECKSUM
	XOR	A		; DATA TYPE = $00
	CALL	HEXOUT		; OUTPUT THE BYTE
	INC	B		; BUMP COUNTER TO GET LAST BYTE
MEMHEX	LD	A,(HL)		; GET MEMORY CONTENTS
	CALL	HEXOUT		; AND OUTPUT
	LD	A,(HL)		; GET MEMORY CONTENTS AGAIN
	ADD	A,C		; ADD TO CHECKSUM
	LD	C,A		; STORE NEW CHECKSUM
	INC	HL		; NEXT MEMORY LOCATION
	
	DEC	DE		; REDUCE THE POINTER
	
	DJNZ	MEMHEX		; CONTINUE UNTIL RECORD SAVED
	LD	A,C		; RETRIEVE CHECKSUM
	CPL			; INVERT TO CREATE ONE'S COMPLEMENT
	INC	A		; CREATE TWO'S COMPLEMENT
	CALL	HEXOUT		; WRITE CHECKSUM OUT
	RET	
;------------------------------------------------------------------------------
; Convert HL to HEX ASCII and print it, part of INTEL Hex save
;------------------------------------------------------------------------------
HLHEX	LD	A,H		; GET H
	CALL	HEXOUT		; CONVERT IT
	LD	A,L
;------------------------------------------------------------------------------
; Convert byte in A to HEX ASCII and print it, part of INTEL Hex save
;------------------------------------------------------------------------------	
HEXOUT	PUSH 	AF		;Convert the upper nybble to Hex ASCII first
       	RRA			;Slowly
       	RRA			; Rotate
       	RRA			;  It
       	RRA			;   Over to the right
       	CALL 	HEXOP		;Convert the nybble D3-D0 to Hex ASCII
       	POP 	AF		;Retrieve the original value and convert the lower nybble
HEXOP  	AND 	$0F		;Convert the nybble at D3-D2-D1-D0 to Hex ASCII char
       	CP 	10		;Neat trick for converting nybble to ASCII
       	SBC 	A,$69
       	DAA			;Uses DAA trick
	CALL	DSCONOUT
	RET
;------------------------------------------------------------------------------
; end of  S A V E   I N T E L   H E X 
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
; Load file in Intel Hex Format
;------------------------------------------------------------------------------
; Intel Hex Format is:
;   1) Colon (Frame 0)
;   2) Record Length Field (Frames 1 and 2)
;   3) Load Address Field (Frames 3,4,5,6)
;   4) Record Type Field (Frames 7 and 8)
;   5) Data Field (Frames 9 to 9+2*(Record Length)-1
;   6) Checksum Field - Sum of all byte values from Record Length to and Including Checksum Field = 0 ]
;------------------------------------------------------------------------------		
LOADA	CALL	DSCONIN		; Get a character
	CP	$3A		; COLON? MUST BE START OF INTEL HEX LINE
	JR	NZ,CKERR		;MUST BE GARBAGE, EXIT

	LD	E,$00		; RECORD LENGTH FIELD
	CALL	CKSUM		; GET US 2 CHARS INTO BC, CONVERT TO BYTE
	LD	D,A		; LOAD RECORD LENGTH COUNT INTO D
	CALL	CKSUM		; GET NEXT TWO CHARS, MEMORY LOAD ADDRESS <H>
	LD	H,A		; PUT IT IN H
	CALL	CKSUM		; GET NEXT TWO CHARS, MEMORY LOAD ADDRESS <L>
	LD	L,A
	CALL	CKSUM		; GET NEXT TWO CHARS, RECORD FIELD TYPE
	CP	$01		; RECORD FIELD $00=DATA, $01 IS EOF
	JR	NZ,DATAT
	CALL	CKSUM		; GET NEXT TWO CHARS, ASSEMBLE INTO BYTE
	LD	A,E
	AND	A
	RET	Z		; CHECKSUMS OK THUS FAR
	JR	CKERR		; NOT ZERO, MUST BE GARBAGE

DATAT	LD	A,D		; IS A LINE OF DATA
	AND	A
	JR	Z,CKCK
	CALL	CKSUM
	LD	(HL),A
	INC	HL
	DEC	D
	JR	DATAT
	
CKCK	CALL	CKSUM
	LD	A,E
	AND	A
	JR	Z,LOADA		; Keep getting characters until done

CKERR	LD	HL,TCKSM	; GET "Checksum Error" message
	JP	PRT		; and print it

GETVAL	CALL	DSCONIN		; RX a Character
	CP	$03          	; <CTRL-C>?
	RET	Z
	CP	$20		; LESS THAN <SPC>?
	JR	C,GETVAL
	RET
CKSUM	CALL	GETVAL
	LD	B,A
	CALL	GETVAL
	LD	C,A
	CALL	ASC2BYT
	LD	C,A
	LD	A,E
	SUB	C
	LD	E,A
	LD	A,C
	RET
;------------------------------------------------------------------------------
; CLEAR THE TTYA DISPLAY
;------------------------------------------------------------------------------
CLS	LD	A,CS		;$0C FORM FEED
	CALL	DSCONOUT	;PRINT IT
	RET
;------------------------------------------------------------------------------
; PRINT A STRING OF CHARACTERS DIRECT UNTIL CHAR=$00
;------------------------------------------------------------------------------
PRT	LD	A,(HL)		; LOAD LTEXT AT (HL)
	OR	A		; IS IT $00? TERMINATOR
	RET	Z		; FINISHED
	CALL	DSCONOUT	; PRINT THE CHARACTER
	INC	HL		; INDEX LOCATION
	JR	PRT		; CONTINUE UNTIL FINISHED
;------------------------------------------------------------------------------
; EXIT BASIC TO MONITOR
;------------------------------------------------------------------------------
EXIT	LD	A,CR		; CARRIAGE RETURN
	CALL	DSCONOUT	; PRINT IT
	LD	A,LF		; LINE FEED
	CALL	DSCONOUT	; PRINT IT
	RST	00H		; EXIT TO RESTART
;------------------------------------------------------------------------------
;Convert ASCII in BC to byte value in A
;------------------------------------------------------------------------------
ASC2BYT	LD	A,B		;MOVE HI BYTE TO A
	SUB	$30		;CONVERT IT TO VALUE
	CP	$0A		;0-9?
	JR	C,ASC2B1	;IF NO, IS A-F SO
	SUB	$07		;SUBTRACT 7 MORE
ASC2B1	RLCA			;AND MOVE IT
	RLCA			;TO THE LEFT NYBBLE
	RLCA			;VERY
	RLCA			;SLOWLY
	LD	B,A		;AND SAVE IT TO B
	LD	A,C		;GET LOW BYTE TO A
	SUB	$30		;CONVERT TO ASCII
	CP	$0A		;0-9?
	JR	C,ASC2B2	;IF NO, IS A-F SO
	SUB	$07		;WE SUBTRACT 7 MORE
ASC2B2	ADD	A,B		;AND STORE IT WITH THE HI NYBBLE
	RET			;SO WE CAN FINISH
;------------------------------------------------------------------------------
; I/O routines for the DarkStar Z80
;------------------------------------------------------------------------------

DSCHKSIO:			; DO NOTHING ON DARKSTAR
	RET

DSCONIN:			; GET A CHAR
	JP	GETKBD

DSCONOUT:			; PUT A CHAR
	LD C, A
	JP CONOUT
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
; FUNCTION ADDRESS TABLE
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
FNCTAB: defw     SGN
        defw     INT
        defw     ABS
        defw     USR
        defw     FRE
        defw     INP
        defw     POS
        defw     SQR
        defw     RND
        defw     LOG
        defw     EXP
        defw     COS
        defw     SIN
        defw     TAN
        defw     ATN
        defw     PEEK
        defw     HEX		; Was "DEEK"
        defw     POINT
        defw     LEN
        defw     STR
        defw     VAL
        defw     ASC
        defw     CHR
        defw     LEFT
        defw     RIGHT
        defw     MID
;------------------------------------------------------------------------------
; RESERVED WORD LLIST
;------------------------------------------------------------------------------
WORDS:  defb     'E'+ $80,"ND"
        defb     'F'+80H,"OR"
        defb     'N'+80H,"EXT"
        defb     'D'+80H,"ATA"
        defb     'I'+80H,"NPUT"
        defb     'D'+80H,"IM"
        defb     'R'+80H,"EAD"
        defb     'L'+80H,"ET"
        defb     'G'+80H,"OTO"
        defb     'R'+80H,"UN"
        defb     'I'+80H,"F"
        defb     'R'+80H,"ESTORE"
        defb     'G'+80H,"OSUB"
        defb     'R'+80H,"ETURN"
        defb     'R'+80H,"EM"
        defb     'S'+80H,"TOP"
        defb     'O'+80H,"UT"
        defb     'O'+80H,"N"
        defb     'N'+80H,"ULL"
        defb     'W'+80H,"AIT"
        defb     'D'+80H,"EF"
        defb     'P'+80H,"OKE"
        defb     'V'+80H,"ECTOR"
        defb     'S'+80H,"CREEN"
        defb     'L'+80H,"INES"
        defb     'C'+80H,"LS"
        defb     'W'+80H,"IDTH"
        defb     'E'+80H,"XIT"		; formerly MONITR
        defb     'S'+80H,"ET"
        defb     'R'+80H,"ESET"
        defb     'P'+80H,"RINT"
        defb     'C'+80H,"ONT"
        defb     'L'+80H,"IST"
        defb     'C'+80H,"LEAR"
        defb     'L'+80H,"OAD"
        defb     'S'+80H,"AVE"
        defb     'N'+80H,"EW"
        defb     'T'+80H,"AB("
        defb     'T'+80H,"O"
        defb     'F'+80H,"N"
        defb     'S'+80H,"PC("
        defb     'T'+80H,"HEN"
        defb     'N'+80H,"OT"
        defb     'S'+80H,"TEP"
;------------------------------------------------------------------------------
        defb     '+'+80H
        defb     '-'+80H
        defb     '*'+80H
        defb     '/'+80H
        defb     '^'+80H
        defb     'A'+80H,"ND"
        defb     'O'+80H,"R"
        defb     '>'+80H
        defb     '='+80H
        defb     '<'+80H
;------------------------------------------------------------------------------
        defb     'S'+80H,"GN"
        defb     'I'+80H,"NT"
        defb     'A'+80H,"BS"
        defb     'U'+80H,"SR"
        defb     'F'+80H,"RE"
        defb     'I'+80H,"NP"
        defb     'P'+80H,"OS"
        defb     'S'+80H,"QR"
        defb     'R'+80H,"ND"
        defb     'L'+80H,"OG"
        defb     'E'+80H,"XP"
        defb     'C'+80H,"OS"
        defb     'S'+80H,"IN"
        defb     'T'+80H,"AN"
        defb     'A'+80H,"TN"
        defb     'P'+80H,"EEK"
        defb     'H'+80H,"EX"		;Was DEEK
        defb     'P'+80H,"OINT"
        defb     'L'+80H,"EN"
        defb     'S'+80H,"TR$"
        defb     'V'+80H,"AL"
        defb     'A'+80H,"SC"
        defb     'C'+80H,"HR$"
        defb     'L'+80H,"EFT$"
        defb     'R'+80H,"IGHT$"
        defb     'M'+80H,"ID$"
        defb     80H             	; End of list marker
;------------------------------------------------------------------------------
; KEYWORD ADDRESS TABLE
;------------------------------------------------------------------------------
WORDTB: defw     PEND
        defw     FOR
        defw     NEXT
        defw     DATA
        defw     INPUT
        defw     DIM
        defw     LREAD
        defw     LET
        defw     GOTO
        defw     RUN
        defw     IFT
        defw     RESTOR
        defw     GOSUB
        defw     RETURN
        defw     REM
        defw     STOP
        defw     POUT
        defw     ON
        defw     NULL
        defw     WAIT
        defw     DEF
        defw     POKE
        defw     VECTOR
        defw     SCREEN
        defw     LINES
        defw     CLS
        defw     WIDTH
        defw     EXIT
        defw     PSET
        defw     RESET
        defw     PRINT
        defw     CONT
        defw     LLIST
        defw     CLEAR
        defw     LOAD
        defw     SAVE
        defw     NEW
;------------------------------------------------------------------------------
; ARITHMETIC PRECEDENCE TABLE
;------------------------------------------------------------------------------
PRITAB: defb     $79           ; Precedence value
        defw     PADD          ; FPREG = <last> + FPREG

        defb     $79           ; Precedence value
        defw     PSUB          ; FPREG = <last> - FPREG

        defb     $7C           ; Precedence value
        defw     MULT          ; PPREG = <last> * FPREG

        defb     $7C           ; Precedence value
        defw     DIV           ; FPREG = <last> / FPREG

        defb     $7F           ; Precedence value
        defw     POWER         ; FPREG = <last> ^ FPREG

        defb     $50           ; Precedence value
        defw     PAND          ; FPREG = <last> AND FPREG

        defb     $46           ; Precedence value
        defw     POR           ; FPREG = <last> OR FPREG
;------------------------------------------------------------------------------
; BASIC VARIABLES INITIALIZATION TABLE
;  This "parametric data" is copied into the BASICV block on Cold Start
;------------------------------------------------------------------------------
INITAB: JP      WARMST          ; Warm start jump, located at BASICV    $00-$02
        JP      FCERR           ; "USR (X)" jump (Set to Error)         $03-$05

        OUT     (0),A           ; "OUT p,n" skeleton                    $06-$07
        RET			;                                       $08

        SUB     0               ; Division support routine              $09-16
        LD      L,A		
        LD      A,H
        SBC     A,0
        LD      H,A
        LD      A,B
        SBC     A,0
        LD      B,A
        LD      A,0
        RET

        defb	$00,$00,$00	; Random number seed                    $17-19

                                ; Table used by RND
        defb	$35,$4A,$CA,$99     ;-2.65145E+07                     $1A-3D
        defb	$39,$1C,$76,$98     ; 1.61291E+07
        defb	$22,$95,$B3,$98     ;-1.17691E+07
        defb	$0A,$DD,$47,$98     ; 1.30983E+07
        defb	$53,$D1,$99,$99     ;-2-01612E+07
        defb	$0A,$1A,$9F,$98     ;-1.04269E+07
        defb	$65,$BC,$CD,$98     ;-1.34831E+07
        defb	$D6,$77,$3E,$98     ; 1.24825E+07
        defb	$52,$C7,$4F,$80     ; Last random number

        IN      A,(0)           ; INP (x) skeleton                      $3E-3F
        RET			;                                       $40

        defb	$01		; Number of NULLs                       $41
        defb	79		; Terminal width (79)                   $42
        defb	5		; Width for commas (16 columns)         $43
        defb	$00		; Null after input byte flag            $44
        defb	$00		; Output enabled (CTRLOFG)              $45
        defw	$0014		; Initial lines counter(20)             $46-47
        defw	$0014		; Initial lines number (20)             $48-49
        defw	$0000		; Array load/save check sum             $4A-$4B
        defb	$00		; Break not by NMI                      $4C
        defb	$00		; Break flag                            $4D
	defb	$00		; CURPOS                                $4E
	defb	$00		; LCRFLG Locate/Create Flag		$4F
	defb	$00		; TYPE Data type flag			$50
	defb	$00		; DATFLG literal statement flag		$51
	defb	$00		; FORFLG "FOR" loop flag		$52
	defb	$00		; Last byte entered			$53
	defb	$00		; LREAD/INPUT flag			$54
	defw	-2		; Current LINE NUMBER			$55-$56
INITX	defb	$00		; END OF INITIALISATION TABLE
;------------------------------------------------------------------------------
; BASIC ERROR CODE LLIST
;------------------------------------------------------------------------------
ERRORS: defb     $01,"NEXT without FOR"
	defb     $00,$02,"Syntax"
        defb	  $00,$03,"RETURN without GOSUB"
        defb	  $00,$04,"Out of DATA"
        defb	  $00,$05,"Illegal function call"
        defb	  $00,$06,"Overflow"
        defb	  $00,$07,"Out of Memory"
        defb	  $00,$08,"Undefined Line"
        defb	  $00,$09,"Bad Subscript"
        defb	  $00,$0A,"Re-DIM'd array"
        defb     $00,$0B,"Division by zero"
        defb	  $00,$0C,"Illegal direct"
        defb     $00,$0D,"Type Mismatch"
        defb     $00,$0E,"Out of string space"
        defb     $00,$0F,"String too long"
        defb     $00,$10,"String too complex"
        defb     $00,$11,"Can't CONTinue"
        defb	  $00,$12,"Undefined Function"
        defb     $00,$13,"Missing Operand"
        defb     $00,$14,"Stack Overflow"
	defb	  $00,$15,"Not valid HEX"
	defb	  $00
;------------------------------------------------------------------------------
; LTEXT MESSAGES
;------------------------------------------------------------------------------
SIGNON	defb	$0C,"Z80 BASIC Version 5.0",CR,LF
	defb	"Z80 DarkStar"
	defb	" system by P.Betti <pbetti@lpconsul.net>",CR,LF,0,0

SRAM	defb	" System Ram",CR,LF,0,0
BFREE	defb	" Bytes free",CR,LF,0,0
OKMSG	defb	"Ok",CR,LF,0,0
ERRMSG	defb	" error",0
BRKMSG	defb	"Break",0
INMSG	defb	" in ",0
REDO    defb   "?Redo from start",CR,LF,0
EXTIG   defb   "?Extra ignored",CR,LF,0
TNORAM	defb	"No external RAM"
	defb	" detected above $4000",CR,LF,0,0
TSAVE	defb	"Capture text file now.",CR,LF,0,0
TLOAD	defb	"Send Program file now.",CR,LF,0,0
TCKSM	defb	"Checksum Error on load.",CR,LF,0,0
;------------------------------------------------------------------------------
; The following vectors are placed at the top of BASIC's ROMs so that future
; users of USR(x) may easily locate the routines DEINT and ABPASS, regardless
; which version of BASIC this is. Also BASIC's cold start and warmstart vectors
;------------------------------------------------------------------------------
	org	$2FF4
	JP	CSTART		; COLD START
	JP	WARMST		; WARM START
	JP	DEINT		; PASS FPREG INTO INTEGER IN DE
	JP	ABPASS		; PASS INTEGER IN AB INTO FPREG
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
FINIS	end			;END OF ASSEMBLY
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
