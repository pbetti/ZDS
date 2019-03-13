;===============================================================================
; BASIC language interpreter
; (c) 1978 Microsoft
; Modified to run on Space-Time Productions Z80 Board 2004-2005
; Modified to run on Z80 Darkstar 2008
;===============================================================================
;
include ../darkstar.equ
include syshw.inc
;------------------------------------------------------------------------------
; Memory Map
;------------------------------------------------------------------------------
mbase	equ	$3000
ram	equ	mbase		; STACK BOTTOM     (3010-30FF)
stack	equ	mbase+$100	; STACK TOP        (3010-30FF)
sysvar	equ	mbase+$100	; SYSTEM VAR SPACE (3100-31FF)
inbuff	equ	mbase+$160	; INPUT  BUFFER    (3160-31AF)
buffer	equ	mbase+$1b0	; CRUNCH BUFFER    (31b0-31FF)

basicv	equ	mbase+$200	; BASIC  VAR SPACE (3200-32FF)
ltext	equ	mbase+$300	; BASIC PROGRAM    (3300-FFFF)
;------------------------------------------------------------------------------
; System Variables and Storage
;------------------------------------------------------------------------------
iobase	equ	sysvar		;COPY OF PIO MAP   (3100-310F)

dumpbuf	equ	sysvar+$30	; ASCII chars from memory command $30-$3F
nmi	equ	sysvar+$40	; JP TO NMIV


lstvar	equ	$5f		; LAST VARIABLE SPACE AVAILABLE, DO NOT PASS GO
;------------------------------------------------------------------------------
;General Equates
;------------------------------------------------------------------------------
lf	equ	$0a		; LINE FEED
cs	equ	$0c		; FORM FEED
cr	equ	$0d		; CARRIAGE RETURN
ctrlc	equ	$03		; <CTRL-C>
ctrlg	equ	$07		; <CTRL-G>
ctrlo	equ	$0f		; <CTRL-O>
ctrlq	equ	$11		; <CTRL-Q>
ctrlr	equ	$12		; <CTRL-R>
ctrls	equ	$13		; <CTRL-S>
ctrlu	equ	$15		; <CTRL-U>
ctrlz	equ	$1a		; <CTRL-Z>
esc	equ	$1b		; ESCAPE KEY
del	equ	$7f		; DELETE KEY
bksp	equ	$08		; BACK SPACE
zerbyt	equ	$-1		; A zero byte (?)
;------------------------------------------------------------------------------
; BASIC ERROR CODE VALUES
;------------------------------------------------------------------------------
nf      equ     $01            ; NEXT without FOR
sn      equ     $02            ; Syntax error
rg      equ     $03            ; RETURN without GOSUB
od      equ     $04            ; Out of DATA
fc      equ     $05            ; Function call error
ov      equ     $06            ; Overflow
om      equ     $07            ; Out of memory
ul      equ     $08            ; Undefined line number
ws      equ     $09            ; Bad subscript
dd      equ     $0a            ; Re-DIMensioned array
dz      equ     $0b            ; Division by zero (/0)
id      equ     $0c            ; Illegal direct
tm      equ     $0d            ; Type miss-match
os      equ     $0e            ; Out of string space
ls      equ     $0f            ; String too long
st      equ     $10            ; String formula too complex
cn      equ     $11            ; Can't CONTinue
uf      equ     $12            ; UnDEFined FN function
mo      equ     $13            ; Missing operand
so	equ	 $14            ; Stack overflow
hx	equ	 $15		; Not valid HEX value
;------------------------------------------------------------------------------
; RESERVED WORD TOKEN VALUES
;  Tokens occupy from $80 thru $CF connected to each reserved word in the
;  "WORDS:" list; these are the only ones referenced by indexing routines
;------------------------------------------------------------------------------
zend    equ     080h           ; END
zfor    equ     081h           ; FOR
zdata   equ     083h           ; DATA
zgoto   equ     088h           ; GOTO
zgosub  equ     08ch           ; GOSUB
zrem    equ     08eh           ; REM
zprint  equ     09eh           ; PRINT
znew    equ     0a4h           ; NEW
ztab    equ     0a5h           ; TAB
zto     equ     0a6h           ; TO
zfn     equ     0a7h           ; FN
zspc    equ     0a8h           ; SPC
zthen   equ     0a9h           ; THEN
znot    equ     0aah           ; NOT
zstep   equ     0abh           ; STEP
zplus   equ     0ach           ; +
zminus  equ     0adh           ; -
ztimes  equ     0aeh           ; *
zdiv    equ     0afh           ; /
zor     equ     0b2h           ; OR
zgtr    equ     0b3h           ; >
zequal  equ     0b4h           ; M
zlth    equ     0b5h           ; <
zsgn    equ     0b6h           ; SGN
zpoint  equ     0c7h           ; POINT
zleft   equ     0cdh           ; LEFT$
;------------------------------------------------------------------------------
; BASIC WORKSPACE LOCATIONS
;------------------------------------------------------------------------------
wrkspc	equ	basicv		; Workspace
usr	equ	basicv+$03	; "USR(X)" JUMP, SET INITALLY TO FN ERROR
outsub	equ	basicv+$06	; "OUT P,N"
otport	equ	basicv+$07	; PORT (P)
divsup	equ	basicv+$09	; DIVISION SUPPORT ROUTINE
div1	equ	basicv+$0a	; <- VALUES TO
div2	equ	basicv+$0e	; <- ADDED
div3	equ	basicv+$12	; <- DURING
div4	equ	basicv+$15	; <- DIVISION CALC
seed	equ	basicv+$17	; RANDOM SEED NUMBER
lstrnd	equ	basicv+$3a	; LAST RANDOM NUMBER
inpsub	equ	basicv+$3e	; "INP(X)" ROUTINE
inport	equ	basicv+$3f	; PORT(X)
nulls	equ	basicv+$41	; NUMBER OF NULLS POS(X) NUMBER
lwidth	equ	basicv+$42	; TERMINAL WIDTH
comman	equ	basicv+$43	; WIDTH FOR COMMAS
nulflg	equ	basicv+$44	; NULL AFTER INPUT BYTE FLAG
ctlofg	equ	basicv+$45	; CONTROL "O" FLAG OUTPUT ENABLE
linesc	equ	basicv+$46	; LINES COUNTER
linesn	equ	basicv+$48	; LINES NUMBER
chksum	equ	basicv+$4a	; ARRAY LOAD/SAVE CHECK SUM
nmiflg	equ	basicv+$4c	; FLAG FOR NMI BREAK ROUTINE
brkflg	equ	basicv+$4d	; BREAK FLAG

curpos	equ	basicv+$4e	; CHARACTER POSITION ON LINE
lcrflg	equ	basicv+$4f	; LOCATE/CREATE FLAG
type	equ	basicv+$50	; DATA TYPE FLAG
datflg	equ	basicv+$51	; LITERAL STATEMENT FLAG
forflg	equ	basicv+$52	; "FOR" LOOP FLAG
lstbin	equ	basicv+$53	; LAST BYTE ENTERED
lreadfg	equ	basicv+$54	; LREAD/INPUT FLAG
lineat	equ	basicv+$55	; Current line number

ramtop  equ	basicv+$60      ; Physical end of RAM
progst	equ	basicv+$62	; START OF BASIC LTEXT AREA
stlook	equ	basicv+$64	; PROGRAM START + 100 BYTES
freram  equ	basicv+$66	; Calculated ram for BASIC program text
sysram	equ	basicv+$68	; Calculated ram for BASIC text+vars
bastxt	equ	basicv+$6a	; Pointer to start of program
strspc	equ	basicv+$6c	; Bottom of string space in use
prognd	equ	basicv+$6e	; END OF PROGRAM
varend	equ	basicv+$70	; END OF VARIABLES
arrend	equ	basicv+$72	; END OF ARRAYS
lstram	equ	basicv+$74	; LAST AVAILABLE RAM

tmstpt	equ	basicv+$81	; TEMPORARY STRING POINTER
tmstpl	equ	basicv+$83	; TEMPORARY STRING POOL
tmpstr	equ	basicv+$8f	; TEMPORARY STRING
strbot	equ	basicv+$93	; BOTTOM OF STRING SPACE
curopr	equ	basicv+$95	; CURRENT OPERATOR IN EVAL
loopst	equ	basicv+$97	; FIRST STATEMENT OF LOOP
datlin	equ	basicv+$99	; LINE OF CURRENT DATA ITEM
brklin	equ	basicv+$a6	; LINE OF BREAK
nxtopr	equ	basicv+$a8	; NEXT OPERATOR IN EVAL
errlin	equ	basicv+$aa	; LINE OF ERROR
contad	equ	basicv+$ac	; WHERE TO CONTINUE
nxtdat	equ	basicv+$ae	; NEXT DATA ITEM

fnrgnm	equ	basicv+$b0	; NAME OF "FN" ARGUMENT
fnarg	equ	basicv+$b2	; FN ARGUMENT VALUE

fpreg	equ	basicv+$c0	; FLOATING POINT REGISTER $C0 $C1 $C2
fpexp	equ	basicv+$c3	; FLOATING POINT EXPONENT
sgnres	equ	basicv+$c4	; SIGN OF RESULT

pbuff	equ	basicv+$d0	; NUMERIC DISPLAY PRINT BUFFER

mulval	equ	basicv+$e0	; MULTIPLIER

x1pos	equ	basicv+$f0	; X position integer from GETXY
y1pos	equ	basicv+$f2	; Y position integer from GETXY
x2pos	equ	basicv+$f4	; X2 position for calculations
y2pos	equ	basicv+$f6	; Y2 position for calculations
radius	equ	basicv+$f8	; Radius for circle, elipse calcs

;------------------------------------------------------------------------------
; B A S I C   Cold  Start
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
basic	org	$100		; START 
cstart	di			; Disable INTerrupts
	ld	sp,stack	; Set SP pointer
;------------------------------------------------------------------------------
; LOAD DEFAULTS INTO TABLE IN WORKSPACE
;------------------------------------------------------------------------------
init	ld	hl,basicv	; Full clear working area
	ld	(hl),0		; to zero
	ld	de,basicv+1	; follow hl
	ld	bc,ltext-basicv	; size
	ldir			; do it
	ld	hl,initab	; Source=Init table
	ld	de,wrkspc	; Dest=Basic Var space in static RAM
	ld	bc,initx-initab	; Number of bytes to copy
	ldir			; Make the move
	ld	hl,signon	; Get SIGNON message
	call	prt		; Clear the screen and print it out

	ld	hl,ltext	; START OF OFF-BOARD RAM
	ld	(progst),hl	; SET START OF PROGRAM LTEXT
	ld	(bastxt),hl	; LOAD BASTXT VARIABLE AS WELL
	ld	de,ltext+$74	; PROGST + 100 BYTES
	ld	(stlook),de	; SAVE IT, CONTINUE INTO UPPER MEM TEST
;------------------------------------------------------------------------------
; We assume there is > 100 bytes of expansion ram available above
; $3000, so we set the parameters and start checking upward, watching for
; HL rollover from $FFFF to $0000, meaning full ram thru $FFFF
;------------------------------------------------------------------------------
tstmem	ld	hl,ltext	; START OF PROGRAM LTEXT AREA
	ld	de,$f000	; shadow ram space
tstmem1	ld	a,$aa		; BINARY 1010 1010 BIT PATTERN TO TEST MEMORY
	ld	(hl),a		; STORE THE BYTE TO MEMORY
	cp	(hl)		; SEE IF MEMORY IS RESPONDING A-(HL)
	jr	nz,settop	; NO? MUST BE PAST TOP OF RAM
	xor	a		; ZERO OUT A AS WE GO
	ld	(hl),a		; SAVE IT BACK
	inc	hl		; YES IT WORKS, TRY NEXT LOCATION
	call	cphlde		; over top ?
	jr	nz,tstmem1	; HL NOT ROLLED OVER, LOOP UNTIL TOP OF RAM LOCATED
;------------------------------------------------------------------------------
; SETS MEMORY ALLOCATIONS BASED ON HL BEING ONE OVER THE PHYSICAL TOP OF RAM
;------------------------------------------------------------------------------
settop	dec	hl		; BACK ONE BYTE TO LAST KNOWN GOOD RAM ADDRESS
	ld	(ramtop),hl	; PHYSICAL TOP OF RAM (WHAT THE HARDWARE HAS)
	ld	(lstram),hl	; LOGICAL  TOP OF RAM (CAN BE CHANGED BY CLEAR)
	ld	de,$f800	; -2048 BYTES FOR STRING SPACE LOCATION
	add	hl,de		; ALLOCATE STRING SPACE
	ld	(strspc),hl	; SAVE STRING SPACE (STRSPC=LSTRAM-reserved space)
	ld	de,$ff80	; -128 BYTES FOR TEMPORARY STRING SPACE LOCATION
	add	hl,de		; ALLOCATE STRING SPACE
	ld	(tmstpl),hl	; SAVE STRING SPACE (STRSPC=LSTRAM-reserved space)
	ld	(tmstpt),hl	; SAVE STRING SPACE (STRSPC=LSTRAM-reserved space)
	ld	de,(progst)	; GET START OF RAM AGAIN
	dec	de		; COUNT BOTTOM BYTE
	or	a		; CLEAR CARRY FLAG
	sbc	hl,de		; GET [STRSPC-PROGST]
	ld	(freram),hl	; SAVE IT
	ld	hl,(ramtop)	; RETRIEVE PHYSICAL END OF RAM
	ld	de,(progst)	; $4010 EXPANSION BOARD
	dec	de		; COUNT BOTTOM BYTE, ALSO
	or	a		; CLEAR CARRY FLAG
	sbc	hl,de		; GET DIFFERENCE
	ld	(sysram),hl	; STORE SYSTEM RAM (SYSRAM=RAMTOP-PROGST-1)
;------------------------------------------------------------------------------
; Signon message, retrieve RAM parameters
;------------------------------------------------------------------------------
	ld	hl,(sysram)	; Get SYSRAM value back
	call	prnthl		; Print number of bytes total
	ld	hl,sram		; " System Ram" message
	call	prt		; Print the message
	ld	hl,(freram)	; GET BYTES FREE BACK
	call	prnthl		; OUTPUT AMOUNT OF FREE MEMORY
	ld	hl,bfree	; " Bytes Free" MESSAGE
	call	prt		; Print the message
	xor	a		; Clear A to zero
	ld	(buffer),a	; Mark end of buffer
	ld	hl,(progst)	; Locate at start of BASTXT
	ld	(hl),a		; Initialize BASIC area

	call	clrptr		; CLEAR POINTERS AND SET UP PROGRAM AREA
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
; B A S I C   Warm  Start
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
warmst	ei			; Enable INTerrupts to system
brkret	call    clreg           ; Clear registers and stack
        jp      prntok          ; Go to get command line

bakstk	ld      hl,4            ; Look for "FOR" block with
        add     hl,sp           ; same index as specified
lokfor	ld      a,(hl)          ; Get block ID
        inc     hl              ; Point to index address
        cp      zfor            ; Is it a "FOR" token
        ret     nz              ; No - exit
        ld      c,(hl)          ; BC = Address of "FOR" index
        inc     hl
        ld      b,(hl)
        inc     hl              ; Point to sign of STEP
        push    hl              ; Save pointer to sign
        ld      l,c             ; HL = address of "FOR" index
        ld      h,b
        ld      a,d             ; See if an index was specified
        or      e               ; DE = 0 if no index specified
        ex      de,hl           ; Specified index into HL
        jr      z,indfnd        ; Skip if no index given
        ex      de,hl           ; Index back into DE
        call    cphlde          ; Compare index with one given
indfnd	ld      bc,16-3         ; Offset to next block
        pop     hl              ; Restore pointer to sign
        ret     z               ; Return if block found
        add     hl,bc           ; Point to next block
        jr      lokfor          ; Keep on looking

movup	call    enfmem          ; See if enough memory
movstr	push    bc              ; Save end of source
        ex      (sp),hl         ; Swap source and dest" end
        pop     bc              ; Get end of destination
movlp	call    cphlde          ; See if list moved
        ld      a,(hl)          ; Get byte
        ld      (bc),a          ; Move it
        ret     z               ; Exit if all done
        dec     bc              ; Next byte to move to
        dec     hl              ; Next byte to move
        jr      movlp           ; Loop until all bytes moved
;------------------------------------------------------------------------------
; Check variable space "stack" to see if getting near end of available space
;------------------------------------------------------------------------------
chkstk	push    hl              ; Save code string address
        ld      hl,(arrend)     ; Lowest free memory
        ld      b,0             ; BC = Number of levels to test
        add     hl,bc           ; 2 Bytes for each level
        add     hl,bc
	defb	$3e		; Skip "PUSH HL"
;------------------------------------------------------------------------------
; ENFMEM had to be completely rebuilt to properly check for mem limits
;------------------------------------------------------------------------------
enfmem	push	hl		; Save code string address
	push	de		; Use to calc available space
	ld	de,50		; 50 Bytes minimum RAM
	add	hl,de		; See if requested address rolls over $FFFF
	jr	c,omerr		; Too high for CPU to physically address

	ld	de,(lstram)	; Get physical top of RAM
	ex	de,hl		; Swap for subtraction
	sbc	hl,de		; Subtract RAMTOP-(code string address+50)
	ex	de,hl		; Swap code string back to HL
	jr	c,omerr		; Requested address is > RAMTOP

	ld	hl,$0000	; Check if SP is about to overrun limits
	add	hl,sp		; Move SP into HL
	ld	de,ram+10	; Nearing lowest available stack position $4010
	sbc	hl,de		; Subtract current SP-RAM ($40xx-$4010)
	jr	c,soerr		; SP has overrun into BASIC variable table
	jr	z,soerr		; SP is right at bottom of available space

	pop	de		; If requested memory is o.k. then,
	pop	hl		; Restore values and
	ret			; Return to the calling program
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
; Error Control
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
datsnr	ld      hl,(datlin)     ; Get line of current DATA item
        ld      (lineat),hl     ; Save as current line
snerr	ld	e,sn            ; ?SyNtax Error
        defb	01h             ; Skip "LD E,DZ" using "LD BC,(nnnn)"
dzerr	ld      e,dz            ; ?/0 Error Divide by Zero
        defb   01h             ; Skip "LD E,NF"
nferr	ld      e,nf            ; ?Next without For Error
        defb   01h             ; Skip "LD E,DD"
dderr	ld      e,dd            ; ?DD Error
        defb   01h             ; Skip "LD E,UF"
uferr	ld      e,uf            ; ?Undefined Fn Error
        defb   01h             ; Skip "LD E,OV
overr	ld      e,ov            ; ?OV Error
        defb   01h             ; Skip "LD E,TM"
tmerr	ld      e,tm            ; ?TM Error
	defb	01h		; Skip "LD E,SO"
soerr	ld	e,so		; ?Stack Overflow
	defb	01h		; Skip "LD E,OM"
omerr	ld      e,om            ; Error - Out of Memory
	defb	01h		; Skip "LE E,HX"
hxerr	ld	e,hx		; Error - Not valid HEX value
;------------------------------------------------------------------------------	
error	call    clreg           ; Clear registers and stack
        ld      (ctlofg),a      ; Enable output (A is 0)
        call    sttlin          ; Start new line
        ld      hl,errors       ; Point to error codes
        ld      d,a             ; D = 0 (A is 0)
        ld      a,'?'
        call    outc            ; Output "?"
        ld	a,$20		; <SPACE>
        call	outc		; Output space
error0  ld	a,(hl)		; Get character in error table
        cp	e		; Arrived at correct msg?
	inc	hl		; Next location
	jr	nz,error0	; Seek until correct msg found
	call    prs             ; Output message
	ld	hl,errmsg	; " Error" text
errin	call	prs	        ; Output message
        ld      hl,(lineat)     ; Get line of error
        ld      de,-2           ; Cold start error if -2
        call    cphlde          ; See if cold start error
        jp      z,cstart        ; Cold start error - Restart
        ld      a,h             ; Was it a direct error?
        and     l               ; Line = -1 if direct error
        inc     a
        call    nz,linein       ; No - output line of error
        defb	$3e             ; Skip "POP BC"
popnok	pop     bc              ; Drop address in input buffer
;------------------------------------------------------------------------------
; LREADY
;------------------------------------------------------------------------------
prntok	xor     a               ; Output "Ok" and get command
        ld      (ctlofg),a      ; Enable output
        call    sttlin          ; Start new line
        ld      hl,okmsg        ; "Ok" message
        call    prs             ; Output "Ok"
getcmd	ld      hl,-1           ; Flag direct mode
        ld      (lineat),hl     ; Save as current line
        call    ttylin          ; Get an input line
        jr      c,getcmd        ; Get line again if break
        call    getchr          ; Get first character
        inc     a               ; Test if end of line
        dec     a               ; Without affecting Carry
        jr      z,getcmd        ; Nothing entered - Get another
        push    af              ; Save Carry status
        call    as2hx            ; Get line number into DE
        push    de              ; Save line number
        call    crunch          ; Tokenise rest of line
        ld      b,a             ; Length of tokenised line
        pop     de              ; Restore line number
        pop     af              ; Restore Carry
        jp      nc,excute       ; No line number - Direct mode
        push    de              ; Save line number
        push    bc              ; Save length of tokenised line
        xor     a
        ld      (lstbin),a      ; Clear last byte input
        call    getchr          ; Get next character
        or      a               ; Set flags
        push    af              ; And save them
        call    srchln          ; Search for line number in DE
        jr      c,linfnd        ; Jump if line found
        pop     af              ; Get status
        push    af              ; And re-save
        jp      z,ulerr         ; Nothing after number - Error
        or      a               ; Clear Carry
linfnd	push    bc              ; Save address of line in prog
        jr      nc,inewln       ; Line not found - Insert new
        ex      de,hl           ; Next line address in DE
        ld      hl,(prognd)     ; End of program
sftprg	ld      a,(de)          ; Shift rest of program down
        ld      (bc),a
        inc     bc              ; Next destination
        inc     de              ; Next source
        call    cphlde          ; All done?
        jr      nz,sftprg       ; More to do
        ld      h,b             ; HL - New end of program
        ld      l,c
        ld      (prognd),hl     ; Update end of program
;------------------------------------------------------------------------------
; Insert new line into BASIC program
;------------------------------------------------------------------------------
inewln	pop     de              ; Get address of line,
        pop     af              ; Get status
        jr      z,setptr        ; No text - Set up pointers
        ld      hl,(prognd)     ; Get end of program
        ex      (sp),hl         ; Get length of input line
        pop     bc              ; End of program to BC
        add     hl,bc           ; Find new end
        push    hl              ; Save new end
        call    movup           ; Make space for line
        pop     hl              ; Restore new end
        ld      (prognd),hl     ; Update end of program pointer
        ex      de,hl           ; Get line to move up in HL
        ld      (hl),h          ; Save MSB
        pop     de              ; Get new line number
        inc     hl              ; Skip pointer
        inc     hl
        ld      (hl),e          ; Save LSB of line number
        inc     hl
        ld      (hl),d          ; Save MSB of line number
        inc     hl              ; To first byte in line
        ld      de,buffer       ; Copy buffer to program
movbuf	ld      a,(de)          ; Get source
        ld      (hl),a          ; Save destinations
        inc     hl              ; Next source
        inc     de              ; Next destination
        or      a               ; Done?
        jr      nz,movbuf       ; No - Repeat
setptr	call    runfst          ; Set line pointers
        inc     hl              ; To LSB of pointer
        ex      de,hl           ; Address to DE
ptrlp	ld      h,d             ; Address to HL
        ld      l,e
        ld      a,(hl)          ; Get LSB of pointer
        inc     hl              ; To MSB of pointer
        or      (hl)            ; Compare with MSB pointer
        jp      z,getcmd        ; Get command line if end
        inc     hl              ; To LSB of line number
        inc     hl              ; Skip line number
        inc     hl              ; Point to first byte in line
        xor     a               ; Looking for 00 byte
fndend	cp      (hl)            ; Found end of line?
        inc     hl              ; Move to next byte
        jr      nz,fndend       ; No - Keep looking
        ex      de,hl           ; Next line address to HL
        ld      (hl),e          ; Save LSB of pointer
        inc     hl
        ld      (hl),d          ; Save MSB of pointer
        jr      ptrlp           ; Do next line
;------------------------------------------------------------------------------
; Search for a particular Line Number (DE) in BASIC program text
; Z =DE line number is found, or DE is at end of program, and DE > largest no.
; NC=DE line number not found and HL has found a line with number > DE
;------------------------------------------------------------------------------
srchln	ld      hl,(bastxt)     ; Start of program text
srchlp: ld      b,h             ; BC = Address to look at
        ld      c,l
        ld      a,(hl)          ; Get address of next line
        inc     hl
        or      (hl)            ; Two "00"s, End of program found?
        dec     hl
        ret     z               ; Yes - Line not found
        inc     hl
        inc     hl
        ld      a,(hl)          ; Get LSB of line number
        inc     hl
        ld      h,(hl)          ; Get MSB of line number
        ld      l,a
        call    cphlde          ; Compare with line in DE
        ld      h,b             ; HL = Start of this line
        ld      l,c
        ld      a,(hl)          ; Get LSB of next line address
        inc     hl
        ld      h,(hl)          ; Get MSB of next line address
        ld      l,a             ; Next line to HL
        ccf
        ret     z               ; Lines found - Exit
        ccf
        ret     nc              ; Line not found, at line after line # in DE
        jr      srchlp          ; Keep looking
;------------------------------------------------------------------------------
; NEW
;------------------------------------------------------------------------------
new:    ret     nz              ; Return if any more on line
clrptr: ld      hl,(bastxt)     ; Point to start of program
        xor     a               ; Set program area to empty
        ld      (hl),a          ; Save LSB = 00
        inc     hl
        ld      (hl),a          ; Save MSB = 00
        inc     hl
	ld	(hl),a		; Mark end of program
        ld      (prognd),hl     ; Set program end in variables

runfst: ld      hl,(bastxt)     ; Clear all variables
        dec     hl

intvar: ld      (brklin),hl     ; Initialise RUN variables
        ld      hl,(lstram)     ; Get end of RAM
        ld      (strbot),hl     ; Clear string space
        xor     a
        call    restor          ; Reset DATA pointers
        ld      hl,(prognd)     ; Get end of program
        ld      (varend),hl     ; Clear variables
        ld      (arrend),hl     ; Clear arrays

clreg:  pop     bc              ; Save return address
        ld      sp,stack        ; Set stack
        ld      hl,tmstpl       ; Temporary string pool
        ld      (tmstpt),hl     ; Reset temporary string ptr
        xor     a               ; A = 00
        ld      l,a             ; HL = 0000
        ld      h,a
        ld      (contad),hl     ; No CONTinue
        ld      (forflg),a      ; Clear FOR flag
        ld      (fnrgnm),hl     ; Clear FN argument
        push    hl              ; HL = 0000
        push    bc              ; Put back return
doagn:  ld      hl,(brklin)     ; Get address of code to RUN
        ret                     ; Return to execution driver
;------------------------------------------------------------------------------
; Prompt for input
;------------------------------------------------------------------------------
prompt: ld      a,'?'           ; "?"
        call    outc            ; Output character
        ld      a,$20           ; Space
        call    outc            ; Output character
	jp	ttylin		; This was formerly RINPUT vector XRINPUT
;------------------------------------------------------------------------------
; CRUNCH converts and tokenizes the line of text at HL into the BUFFER at DE
; Called by GETCMD shortly after TTYLIN
;
;------------------------------------------------------------------------------
crunch: xor     a               ; Tokenise line @ HL to BUFFER
        ld      (datflg),a      ; Reset literal flag
        ld      c,2+3           ; 2 byte number and 3 nulls
        ld      de,buffer       ; Start of input buffer
crnclp: ld      a,(hl)          ; Get byte
        cp      $20             ; Is it a space?
        jr      z,movdir        ; Yes - Copy direct
        ld      b,a             ; Save character
        cp      $22             ; Is it a quote?
        jp      z,cpylit        ; Yes - Copy literal string
        or      a               ; Is it end of buffer?
        jp      z,endbuf        ; Yes - End buffer
        ld      a,(datflg)      ; Get data type
        or      a               ; Literal?
        ld      a,(hl)          ; Get byte to copy
        jr      nz,movdir       ; Literal - Copy direct
        cp      '?'             ; Is it "?" short for PRINT
        ld      a,zprint        ; "PRINT" token
        jr      z,movdir        ; Yes - replace it
        ld      a,(hl)          ; Get byte again
        cp      '0'             ; Is it less than "0"
        jr      c,fndwrd        ; Yes - Look for reserved words
        cp      $3c             ; Is it "0123456789:;" ?
        jr      c,movdir        ; Yes - copy it direct
fndwrd: push    de              ; Look for reserved words
        ld      de,words-1      ; Point to WORDS table
        push    bc              ; Save count
        ld      bc,retnad       ; Where to return to
        push    bc              ; Save return address
        ld      b,zend-1        ; First token value -1
        ld      a,(hl)          ; Get byte
        cp      'a'             ; Less than "a" ?
        jr      c,search        ; Yes - search for words
        cp      'z'+1           ; Greater than "z" ?
        jr      nc,search       ; Yes - search for words
        and     01011111b       ; Force upper case
        ld      (hl),a          ; Replace byte
search: ld      c,(hl)          ; Search for a word
        ex      de,hl
getnxt: inc     hl              ; Get next reserved word
        or      (hl)            ; Start of word?
        jp      p,getnxt        ; D7? No - move on
        inc     b               ; Increment token value
        ld      a,(hl)          ; Get byte from table
        and     01111111b       ; Strip bit 7
        ret     z               ; Return if end of list
        cp      c               ; Same character as in buffer?
        jr      nz,getnxt       ; No - get next word
        ex      de,hl
        push    hl              ; Save start of word

nxtbyt: inc     de              ; Look through rest of word
        ld      a,(de)          ; Get byte from table
        or      a               ; End of word ?
        jp      m,match         ; Yes - Match found
        ld      c,a             ; Save it
        ld      a,b             ; Get token value
        cp      zgoto           ; Is it "GOTO" token ?
        jr      nz,nospc        ; No - Don't allow spaces
        call    getchr          ; Get next character
        dec     hl              ; Cancel increment from GETCHR
nospc:  inc     hl              ; Next byte
        ld      a,(hl)          ; Get byte
        cp      'a'             ; Less than "a" ?
        jr      c,nochng        ; Yes - don't change
        and     01011111b       ; Make upper case
nochng: cp      c               ; Same as in buffer ?
        jr      z,nxtbyt        ; Yes - keep testing
        pop     hl              ; Get back start of word
        jr      search          ; Look at next word

match:  ld      c,b             ; Word found - Save token value
        pop     af              ; Throw away return
        ex      de,hl
        ret                     ; Return to "RETNAD"
retnad: ex      de,hl           ; Get address in string
        ld      a,c             ; Get token value
        pop     bc              ; Restore buffer length
        pop     de              ; Get destination address
movdir: inc     hl              ; Next source in buffer
        ld      (de),a          ; Put byte in buffer
        inc     de              ; Move up buffer
        inc     c               ; Increment length of buffer
        sub     $3a             ; End of statement ":" ?
        jr      z,setlit        ; Jump if multi-statement line
        cp      zdata-3ah       ; Is it DATA statement ?
        jr      nz,tstrem       ; No - see if REM
setlit: ld      (datflg),a      ; Set literal flag
tstrem: sub     zrem-3ah        ; Is it REM?
        jp      nz,crnclp       ; No - Leave flag
        ld      b,a             ; Copy rest of buffer
nxtchr: ld      a,(hl)          ; Get byte
        or      a               ; End of line ?
        jr      z,endbuf        ; Yes - Terminate buffer
        cp      b               ; End of statement ?
        jr      z,movdir        ; Yes - Get next one
cpylit: inc     hl              ; Move up source string
        ld      (de),a          ; Save in destination
        inc     c               ; Increment length
        inc     de              ; Move up destination
        jr      nxtchr          ; Repeat

endbuf: ld      hl,buffer-1     ; Point to start of buffer
        ld      (de),a          ; Mark end of buffer (A = 00)
        inc     de
        ld      (de),a          ; A = 00
        inc     de
        ld      (de),a          ; A = 00
        ret

dodel:  ld      a,(nulflg)      ; Get null flag status
        or      a               ; Is it zero?
        ld      a,0             ; Zero A - Leave flags
        ld      (nulflg),a      ; Zero null flag
        jr      nz,echdel       ; Set - Echo it
        dec     b               ; Decrement length
        jr      z,ttylin        ; Get line again if empty
        call    outc            ; Output null character
        defb   $3e             ; Skip "DEC B"
echdel: dec     b               ; Count bytes in buffer
        dec     hl              ; Back space buffer
        jr      z,otkln         ; No buffer - Try again
        ld      a,(hl)          ; Get deleted byte
        call    outc            ; Echo it
        jr      morinp          ; Get more input

delchr: dec     b               ; Count bytes in buffer
        dec     hl              ; Back space buffer
        call    outc            ; Output character in A
        jr      nz,morinp       ; Not end - Get more
otkln:  call    outc            ; Output character in A
kilin:  call    prntcr          ; Output CRLF
;------------------------------------------------------------------------------
; Get a line from TTY into INBUFF, located in register HL
;  This code was changed to stop overlapping in BUFFER during CRUNCH
;------------------------------------------------------------------------------
ttylin  ld      hl,inbuff       ; Get a line by character
        ld      b,1             ; Set buffer as empty
        xor     a
        ld      (nulflg),a      ; Clear null flag
morinp  call    clotst          ; Get character and test <CTRL-O>
        ld      c,a             ; Save character in C
        cp      del             ; Delete character?
        jr      z,dodel         ; Yes - Process it
        ld      a,(nulflg)      ; Get null flag
        or      a               ; Test null flag status
        jr      z,proces        ; Reset - Process character
        ld      a,0             ; Set a null
        call    outc            ; Output null
        xor     a               ; Clear A
        ld      (nulflg),a      ; Reset null flag
proces: ld      a,c             ; Get character
        cp      ctrlg           ; <CTRL-G> Bell?
        jr      z,putctl        ; Yes - Save it
        cp      ctrlc           ; Is it <CTRL-C> (BREAK)?
        call    z,prntcr        ; Yes - Output CRLF
        cp	esc		; <ESCAPE>?
        call	z,prntcr	; Yes - Output CRLF
        scf                     ; Flag break
        ret     z               ; Return if <CTRL-C> or <ESC>
        cp      cr              ; Is it <Enter> key?
        jp      z,tendin        ; Yes - Terminate input
        cp      ctrlu           ; Is it <CTRL-U>?
        jr      z,kilin         ; Yes - Get another line
        cp      '@'             ; Is it "@" <Kill line>?
        jr      z,otkln         ; Yes - Kill line
        cp      bksp            ; Is it <Backspace>?
        jr      z,delchr        ; Yes - Delete character
        cp      ctrlr           ; Is it <CTRL-R>?
        jr      nz,putbuf       ; No - Put in buffer
        push    bc              ; Save buffer length
        push    de              ; Save DE
        push    hl              ; Save buffer address
        ld      (hl),0          ; Mark end of buffer
        call    outc		; OUTPUT THE CHARACTER
        call	prntcr		; PRINT CR,LF
        ld      hl,inbuff       ; Point to buffer start
        call    prs             ; Output buffer
        pop     hl              ; Restore buffer address
        pop     de              ; Restore DE
        pop     bc              ; Restore buffer length
        jr      morinp          ; Get another character
tendin  ld	(hl),0		; Terminate buffer end
	ld	hl,inbuff-1	; Reset pointer
	jp	prntcr		; Print CRLF and do nulls, RETurn      
;------------------------------------------------------------------------------
; BUFFER
;------------------------------------------------------------------------------
putbuf: cp      $20             ; Is it a control code?
        jr      c,morinp        ; Yes - Ignore
putctl: ld      a,b             ; Get number of bytes in buffer
        cp      81              ; Test for line overflow
        ld      a,ctrlg         ; Set a bell
        jr      nc,outnbs       ; Ring bell if buffer full
        ld      a,c             ; Get character
        ld      (hl),c          ; Save in buffer
        ld      (lstbin),a      ; Save last input byte
        inc     hl              ; Move up buffer
        inc     b               ; Increment length
outit:  call    outc            ; Output the character entered
        jr      morinp          ; Get another character

outnbs: call    outc            ; Output bell and back over it
        ld      a,bksp          ; Set back space
        jr      outit           ; Output it and get more
;------------------------------------------------------------------------------
cphlde: ld      a,h             ; Get H
        sub     d               ; Compare with D
        ret     nz              ; Different - Exit
        ld      a,l             ; Get L
        sub     e               ; Compare with E
        ret                     ; Return status
;------------------------------------------------------------------------------
chksyn: ld      a,(hl)          ; Check syntax of character
        ex      (sp),hl         ; Address of test byte
        cp      (hl)            ; Same as in code string?
        inc     hl              ; Return address
        ex      (sp),hl         ; Put it back
        jp      z,getchr        ; Yes - Get next character
        jp      snerr           ; Different - ?SN Error
;------------------------------------------------------------------------------
; LLIST Command
;------------------------------------------------------------------------------
llist:   call    as2hx            ; ASCII number to DE
        ret     nz              ; Return if anything extra
        pop     bc              ; Rubbish - Not needed
        call    srchln          ; Search for line number in DE
        push    bc              ; Save address of line
        call    setlin          ; Set up lines counter
llistlp: pop     hl              ; Restore address of line
        ld      c,(hl)          ; Get LSB of next line
        inc     hl
        ld      b,(hl)          ; Get MSB of next line
        inc     hl
        ld      a,b             ; BC = 0 (End of program)?
        or      c
        jp      z,prntok        ; Yes - Go to command mode
        call    count           ; Count lines <deleted TSTBRK from next line>

;	RST	18H		; Ck SIO status
	call	dschksio	; Ck SIO status
	jr	nc,llist0	; No key, continue
;	RST	10H		; Get the key into A
	call	dsconin		; Get the key into A
	cp	esc		; Escape key?
	jr	z,rslnbk	; Yes, break
	cp	ctrlc		; <Ctrl-C>
	jr	z,rslnbk	; Yes, break
	cp	ctrls		; Stop scrolling?
	call	z,stall		; Stall, or continue if no stall

llist0   push    bc              ; Save address of next line
        call    prntcr          ; Output CRLF
        ld      e,(hl)          ; Get LSB of line number
        inc     hl
        ld      d,(hl)          ; Get MSB of line number
        inc     hl
        push    hl              ; Save address of line start
        ex      de,hl           ; Line number to HL
        call    prnthl          ; Output line number in decimal
        ld      a,$20           ; Space after line number
        pop     hl              ; Restore start of line address
lstlp2: call    outc            ; Output character in A
lstlp3: ld      a,(hl)          ; Get next byte in line
        or      a               ; End of line?
        inc     hl              ; To next byte in line
        jr      z,llistlp        ; Yes - get next line
        jp      p,lstlp2        ; No token - output it
        sub     zend-1          ; Find and output word
        ld      c,a             ; Token offset+1 to C
        ld      de,words        ; Reserved word list
fndtok: ld      a,(de)          ; Get character in list
        inc     de              ; Move on to next
        or      a               ; Is it start of word?
        jp      p,fndtok        ; No - Keep looking for word
        dec     c               ; Count words
        jr      nz,fndtok       ; Not there - keep looking
outwrd: and     01111111b       ; Strip bit 7
        call    outc            ; Output first character
        ld      a,(de)          ; Get next character
        inc     de              ; Move on to next
        or      a               ; Is it end of word?
        jp      p,outwrd        ; No - output the rest
        jr      lstlp3          ; Next byte in line

setlin: push    hl              ; Set up LINES counter
        ld      hl,(linesn)     ; Get LINES number
        ld      (linesc),hl     ; Save in LINES counter
        pop     hl
        ret

count:  push    hl              ; Save code string address
        push    de
        ld      hl,(linesc)     ; Get LINES counter
        ld      de,-1
        adc     hl,de           ; Decrement
        ld      (linesc),hl     ; Put it back
        pop     de
        pop     hl              ; Restore code string address
        ret     p               ; Return if more lines to go
        
        call	waitcr		; Wait for <ENTER> before continuing
        
        push    hl              ; Save code string address
        ld      hl,(linesn)     ; Get LINES number
        ld      (linesc),hl     ; Reset LINES counter
        pop     hl              ; Restore code string address
        jr      count           ; Keep on counting

rslnbk: ld      hl,(linesn)     ; Get LINES number
        ld      (linesc),hl     ; Reset LINES counter
        jp      brkret          ; Go and output "Break"
;------------------------------------------------------------------------------
; FOR
;------------------------------------------------------------------------------
for:    ld      a,64h           ; Flag "FOR" assignment
        ld      (forflg),a      ; Save "FOR" flag
        call    let             ; Set up initial index
        pop     bc              ; Drop RETurn address
        push    hl              ; Save code string address
        call    data            ; Get next statement address
        ld      (loopst),hl     ; Save it for start of lo6p
        ld      hl,2            ; Offset for "FOR" block
        add     hl,sp           ; Point to it
forslp: call    lokfor          ; Look for existing "FOR" block
        pop     de              ; Get code string address
        jr      nz,forfnd       ; No nesting found
        add     hl,bc           ; Move into "FOR" block
        push    de              ; Save code string address
        dec     hl
        ld      d,(hl)          ; Get MSB of loop statement
        dec     hl
        ld      e,(hl)          ; Get LSB of loop statement
        inc     hl
        inc     hl
        push    hl              ; Save block address
        ld      hl,(loopst)     ; Get address of loop statement
        call    cphlde          ; Compare the FOR loops
        pop     hl              ; Restore block address
        jr      nz,forslp       ; Different FORs - Find another
        pop     de              ; Restore code string address
        ld      sp,hl           ; Remove all nested loops

forfnd: ex      de,hl           ; Code string address to HL
        ld      c,8
        call    chkstk          ; Check for 8 levels of stack
        push    hl              ; Save code string address
        ld      hl,(loopst)     ; Get first statement of loop
        ex      (sp),hl         ; Save and restore code string
        push    hl              ; Re-save code string address
        ld      hl,(lineat)     ; Get current line number
        ex      (sp),hl         ; Save and restore code string
        call    tstnum          ; Make sure it's a number
        call    chksyn          ; Make sure "TO" is next
        defb   zto             ; "TO" token
        call    getnum          ; Get "TO" expression value
        push    hl              ; Save code string address
        call    bcdefp          ; Move "TO" value to BCDE
        pop     hl              ; Restore code string address
        push    bc              ; Save "TO" value in block
        push    de
        ld      bc,8100h        ; BCDE - 1 (default STEP)
        ld      d,c             ; C=0
        ld      e,d             ; D=0
        ld      a,(hl)          ; Get next byte in code string
        cp      zstep           ; See if "STEP" is stated
        ld      a,1             ; Sign of step = 1
        jr      nz,savstp       ; No STEP given - Default to 1
        call    getchr          ; Jump over "STEP" token
        call    getnum          ; Get step value
        push    hl              ; Save code string address
        call    bcdefp          ; Move STEP to BCDE
        call    tstsgn          ; Test sign of FPREG
        pop     hl              ; Restore code string address
savstp: push    bc              ; Save the STEP value in block
        push    de
        push    af              ; Save sign of STEP
        inc     sp              ; Don't save flags
        push    hl              ; Save code string address
        ld      hl,(brklin)     ; Get address of index variable
        ex      (sp),hl         ; Save and restore code string
putfid: ld      b,zfor          ; "FOR" block marker
        push    bc              ; Save it
        inc     sp              ; Don't save C
;------------------------------------------------------------------------------
; RUNCNT executes the line of BASIC program at (HL) until (HL)=$00
;------------------------------------------------------------------------------
runcnt: call    tstbrk          ; Execution driver - Test break
        ld      (brklin),hl     ; Save code address for break
        ld      a,(hl)          ; Get next byte in code string
        cp      $3a             ; Multi statement line ":" ?
        jr      z,excute        ; Yes - Execute it
        or      a               ; End of line?
        jp      nz,snerr        ; No - Syntax error
        inc     hl              ; Point to address of next line
        ld      a,(hl)          ; Get LSB of line pointer
        inc     hl
        or      (hl)            ; Is it zero (End of prog)?
        jp      z,endprg        ; Yes - Terminate execution
        inc     hl              ; Point to line number
        ld      e,(hl)          ; Get LSB of line number
        inc     hl
        ld      d,(hl)          ; Get MSB of line number
        ex      de,hl           ; Line number to HL
        ld      (lineat),hl     ; Save as current line number
        ex      de,hl           ; Line number back to DE
excute: call    getchr          ; Get key word
        ld      de,runcnt       ; Where to RETurn to
        push    de              ; Save for RETurn
ifjmp:  ret     z               ; Go to RUNCNT if end of STMT
onjmp:  sub     zend            ; Is it a token?
        jp      c,let           ; No - try to assign it
        cp      znew+1-zend     ; END to NEW ?
        jp      nc,snerr        ; Not a key word - ?SN Error
        rlca                    ; Double it
        ld      c,a             ; BC = Offset into table
        ld      b,0
        ex      de,hl           ; Save code string address
        ld      hl,wordtb       ; Keyword address table
        add     hl,bc           ; Point to routine address
        ld      c,(hl)          ; Get LSB of routine address
        inc     hl
        ld      b,(hl)          ; Get MSB of routine address
        push    bc              ; Save routine address
        ex      de,hl           ; Restore code string address
;------------------------------------------------------------------------------
; Gets a character from (HL) checks for ASCII numbers
;  RETURNS: Char A 
;  NC if char is ;<=>?@ A-z
;  CY is set if 0-9
;------------------------------------------------------------------------------
getchr: inc     hl              ; Point to next character
        ld      a,(hl)          ; Get next code string byte
        cp      $3a             ; Z if ":", RETurn if alpha
        ret     nc              ; NC if > "9"
        cp      $20		; Is it a space
        jr      z,getchr        ; Skip over and get next
        cp      $30		; "0"
        ccf                     ; NC if < "0" (i.e. "*", CY set if 0 thru 9
        inc     a               ; Test for zero without disturbing CY
        dec     a               ; Z if Null character $00
        ret
;------------------------------------------------------------------------------
; Convert "$nnnn" to FPREG
; Gets a character from (HL) checks for Hexadecimal ASCII numbers "$nnnn"
; Char is in A, NC if char is ;<=>?@ A-z, CY is set if 0-9
;------------------------------------------------------------------------------
hextfp	ex	de,hl		; Move code string pointer to DE
	ld	hl,$0000	; Zero out the value
	call	gethex		; Check the number for valid hex
	jp	c,hxerr		; First value wasn't hex, HX error
	jr	hexlp1		; Convert first character
hexlp	call	gethex		; Get second and addtional characters
	jr	c,hexit		; Exit if not a hex character
hexlp1	add	hl,hl		; Rotate 4 bits to the left
	add	hl,hl
	add	hl,hl
	add	hl,hl
	or	l		; Add in D0-D3 into L
	ld	l,a		; Save new value
	jr	hexlp		; And continue until all hex characters are in

gethex	inc	de		; Next location
	ld	a,(de)		; Load character at pointer
	sub	$30		; Get absolute value
	ret	c		; < "0", error
	cp	$0a
	jr	c,nosub7	; Is already in the range 0-9
	sub	$07		; Reduce to A-F
	cp	$0a		; Value should be $0A-$0F at this point
	ret	c		; CY set if was : ; < = > ? @
nosub7	cp	$10		; > Greater than "F"?
	ccf
	ret			; CY set if it wasn't valid hex
		
hexit	ex	de,hl		; Value into DE, Code string into HL
	ld	a,d		; Load DE into AC
	ld	c,e		; For prep to
	push	hl		; Store Code String Address
	call	acpass		; ACPASS to set AC as integer into FPREG
	pop	hl		; Restore Code String Address
	ret			; Finish up
;------------------------------------------------------------------------------	
; RESTORE command
;------------------------------------------------------------------------------
restor: ex      de,hl           ; Save code string address
        ld      hl,(bastxt)     ; Point to start of program
        jr      z,restnl        ; Just RESTORE - reset pointer
        ex      de,hl           ; Restore code string address
        call    as2hx            ; Get line number to DE
        push    hl              ; Save code string address
        call    srchln          ; Search for line number in DE
        ld      h,b             ; HL = Address of line
        ld      l,c
        pop     de              ; Restore code string address
        jp      nc,ulerr        ; ?UL Error if not found
restnl: dec     hl              ; Byte before DATA statement
updata: ld      (nxtdat),hl     ; Update DATA pointer
        ex      de,hl           ; Restore code string address
        ret
;------------------------------------------------------------------------------
; Check for BREAK during RUN or LLIST, process Scroll Controls <Ctrl-S>,<Ctrl-Q>
;------------------------------------------------------------------------------
tstbrk	call	dschksio	; Ck SIO status
	ret	nc		; No key, go back
	call	dsconin		; Get the key into A
	cp	esc		; Escape key?
	jr	z,brk		; Yes, break
	cp	ctrlc		; <Ctrl-C>
	jr	z,brk		; Yes, break
	cp	esc		; <ESC>
	jr	z,brk		; Yes, break
	cp	ctrls		; Stop scrolling?
	ret	nz		; Other key, ignore
	
stall	call	dsconin		; Wait for key
	cp	ctrlq		; Resume scrolling?
	ret	z		; Release the chokehold
	cp	esc		; Second break?
	jr	z,stop		; Break during hold exits prog
	cp	ctrlc		; Second break?
	jr	z,stop		; Break during hold exits prog
	jr	stall		; Loop until <Ctrl-Q> or <brk>

brk	ld	a,$ff		; Set BRKFLG
	ld	(brkflg),a	; Store it
stop	ret	nz		; Exit if anything else
	defb	$f6		; Skip "Load (BRKLIN),HL
pend	ret	nz		; Exit if anything else
	ld	(brklin),hl	; Current line for Break
	defb	$21		; Skip "OR $FF"
inpbrk	or	$ff		; Set flags for "Break" status
	pop	bc		; Lose the RETurn
endprg  ld      hl,(lineat)     ; Get current line number
        push    af              ; Save STOP / END status
        ld      a,l             ; Is it direct break?
        and     h		; If HL=$FFFF break during direct mode
        inc     a               ; Line number is -1 if direct break
        jr      z,nolin         ; Yes - No line number
        ld      (errlin),hl     ; Save line of break
        ld      hl,(brklin)     ; Get point of break
        ld      (contad),hl     ; Save point to CONTinue
nolin   xor     a
        ld      (ctlofg),a      ; Enable output
        call    sttlin          ; Start a new line
        pop     af              ; Restore STOP / END status
        ld      hl,brkmsg       ; "Break" message
        jp      nz,errin        ; "in line" wanted?
        jp      prntok          ; Go to command mode
;------------------------------------------------------------------------------
; CONTinue
;------------------------------------------------------------------------------
cont:   ld      hl,(contad)     ; Get CONTinue address
        ld      a,h             ; Is it zero?
        or      l
        ld      e,cn            ; ?CN Error
        jp      z,error         ; Yes - output "?CN Error"
        ex      de,hl           ; Save code string address
        ld      hl,(errlin)     ; Get line of last break
        ld      (lineat),hl     ; Set up current line number
        ex      de,hl           ; Restore code string address
        ret                     ; CONTinue where left off
;------------------------------------------------------------------------------
; NULL sets number of nulls to generate after PRNTCR
;------------------------------------------------------------------------------
null:   call    getint          ; Get integer 0-255
        ret     nz              ; Return if bad value
        ld      (nulls),a       ; Set nulls number
        ret
;------------------------------------------------------------------------------
; Gets Character at (HL) and verifies it is Alpha
;------------------------------------------------------------------------------
chkltr: ld      a,(hl)          ; Get byte
        cp      'A'             ; < "A" ?
        ret     c               ; Carry set if not letter
        cp      'Z'+1           ; > "Z" ?
        ccf
        ret                     ; Carry set if not letter
;------------------------------------------------------------------------------
; Converts FPreg to INTeger
;------------------------------------------------------------------------------
fpsint: call    getchr          ; Get next character
posint: call    getnum          ; Get integer 0 to 32767
depint: call    tstsgn          ; Test sign of FPREG
        jp      m,fcerr         ; Negative - ?FC Error
deint:  ld      a,(fpexp)       ; Get integer value to DE
        cp      80h+16          ; Exponent in range (16 bits)?
        jp      c,fpint         ; Yes - convert it
        ld      bc,9080h        ; BCDE = -32768, 16-bit integer 
        ld      de,0000
        push    hl              ; Save code string address
        call    cmpnum          ; Compare FPREG with BCDE
        pop     hl              ; Restore code string address
        ld      d,c             ; MSB to D
        ret     z               ; Return if in range
fcerr:  ld      e,fc            ; ?FC Error
        jp      error           ; Output error-
;------------------------------------------------------------------------------
; Converts ASCII number to DE integer binary
; Used to process Line Numbers from BASIC text
;------------------------------------------------------------------------------
as2hx:  dec     hl              ; ASCII number to DE binary
getln:  ld      de,0            ; Get number to DE
gtlnlp: call    getchr          ; Get next character
        ret     nc              ; Exit if not a digit
        push    hl              ; Save code string address
        push    af              ; Save digit
        ld      hl,65529/10     ; Largest number 65529
        call    cphlde          ; Number in range?
        jp      c,snerr         ; No - ?SN Error
        ld      h,d             ; HL = Number
        ld      l,e
        add     hl,de           ; Times 2
        add     hl,hl           ; Times 4
        add     hl,de           ; Times 5
        add     hl,hl           ; Times 10
        pop     af              ; Restore digit
        sub     $30             ; Make it 0 to 9
        ld      e,a             ; DE = Value of digit
        ld      d,0
        add     hl,de           ; Add to number
        ex      de,hl           ; Number to DE
        pop     hl              ; Restore code string address
        jr      gtlnlp          ; Go to next character
;------------------------------------------------------------------------------
; CLEAR
;------------------------------------------------------------------------------
clear:  jp      z,intvar        ; Just "CLEAR" Keep parameters
        call    posint          ; Get integer 0 to 32767 to DE
        dec     hl              ; Cancel increment
        call    getchr          ; Get next character
        push    hl              ; Save code string address
        ld      hl,(lstram)     ; Get end of RAM
        jr      z,stored        ; No value given - Use stored
        pop     hl              ; Restore code string address
        call    chksyn          ; Check for comma
        defb   ','
        push    de              ; Save number
        call    posint          ; Get integer 0 to 32767
        dec     hl              ; Cancel increment
        call    getchr          ; Get next character
        jp      nz,snerr        ; ?SN Error if more on line
        ex      (sp),hl         ; Save code string address
        ex      de,hl           ; Number to DE
stored: ld      a,l             ; Get LSB of new RAM top
        sub     e               ; Subtract LSB of string space
        ld      e,a             ; Save LSB
        ld      a,h             ; Get MSB of new RAM top
        sbc     a,d             ; Subtract MSB of string space
        ld      d,a             ; Save MSB
        jp      c,omerr         ; ?OM Error if not enough mem
        push    hl              ; Save RAM top
        ld      hl,(prognd)     ; Get program end
        ld      bc,40           ; 40 Bytes minimum working RAM
        add     hl,bc           ; Get lowest address
        call    cphlde          ; Enough memory?
        jp      nc,omerr        ; No - ?OM Error
        ex      de,hl           ; RAM top to HL
        ld      (strspc),hl     ; Set new string space
        pop     hl              ; End of memory to use
        ld      (lstram),hl     ; Set new top of RAM
        pop     hl              ; Restore code string address
        jp      intvar          ; Initialise variables
;------------------------------------------------------------------------------
; Program RUN
;------------------------------------------------------------------------------
run:    jp      z,runfst        ; RUN from start if just RUN
        call    intvar          ; Initialise variables
        ld      bc,runcnt       ; Execution driver loop
        jr      runlin          ; RUN from line number
;------------------------------------------------------------------------------
; GOSUB
;------------------------------------------------------------------------------
gosub:  ld      c,3             ; 3 Levels of stack needed
        call    chkstk          ; Check for 3 levels of stack
        pop     bc              ; Get return address
        push    hl              ; Save code string for RETURN
        push    hl              ; And for GOSUB routine
        ld      hl,(lineat)     ; Get current line
        ex      (sp),hl         ; Into stack - Code string out
        ld      a,zgosub        ; "GOSUB" token
        push    af              ; Save token
        inc     sp              ; Don't save flags
;------------------------------------------------------------------------------
; RUN LINE NUMBER
;------------------------------------------------------------------------------
runlin: push    bc              ; Save return address
;------------------------------------------------------------------------------
; GOTO
;------------------------------------------------------------------------------
goto:   call    as2hx           ; ASCII number to DE binary
        call    rem             ; Get end of line
        push    hl              ; Save end of line
        ld      hl,(lineat)     ; Get current line
        call    cphlde          ; Line after current?
        pop     hl              ; Restore end of line
        inc     hl              ; Start of next line
        call    c,srchlp        ; Line is after current line
        call    nc,srchln       ; Line is before current line
        ld      h,b             ; Set up code string address
        ld      l,c
        dec     hl              ; Incremented after
        ret     c               ; Line found
ulerr:  ld      e,ul            ; ?UL Error - Undefined Line number
        jp      error           ; Output error message
;------------------------------------------------------------------------------
; RETURN
;------------------------------------------------------------------------------
return: ret     nz              ; Return if not just RETURN
        ld      d,-1            ; Flag "GOSUB" search
        call    bakstk          ; Look "GOSUB" block
        ld      sp,hl           ; Kill all FORs in subroutine
        cp      zgosub          ; Test for "GOSUB" token
        ld      e,rg            ; ?RG Error
        jp      nz,error        ; Error if no "GOSUB" found
        pop     hl              ; Get RETURN line number
        ld      (lineat),hl     ; Save as current
        inc     hl              ; Was it from direct statement?
        ld      a,h
        or      l               ; Return to line
        jp      nz,retlin       ; No - Return to line
        ld      a,(lstbin)      ; Any INPUT in subroutine?
        or      a               ; If so buffer is corrupted
        jp      nz,popnok       ; Yes - Go to command mode
retlin: ld      hl,runcnt       ; Execution driver loop
        ex      (sp),hl         ; Into stack - Code string out
        defb     3eh            ; Skip "POP HL"
nxtdta: pop     hl              ; Restore code string address
;------------------------------------------------------------------------------
; DATA/REM
;------------------------------------------------------------------------------
data:   defb    $01,$3a         ; ":" End of statement
rem:    ld      c,0             ; 00  End of statement
        ld      b,0
nxtstl: ld      a,c             ; Statement and byte
        ld      c,b
        ld      b,a             ; Statement end byte
nxtstt: ld      a,(hl)          ; Get byte
        or      a               ; End of line?
        ret     z               ; Yes - Exit
        cp      b               ; End of statement?
        ret     z               ; Yes - Exit
        inc     hl              ; Next byte
        cp      $22             ; Literal string?
        jr      z,nxtstl        ; Yes - Look for another '"'
        jr      nxtstt          ; Keep looking
;------------------------------------------------------------------------------
; ASSIGN A VARIABLE
;------------------------------------------------------------------------------
let:    call    getvar          ; Get variable name
        call    chksyn          ; Make sure "=" follows
        defb    zequal          ; "=" token
        push    de              ; Save address of variable
        ld      a,(type)        ; Get data type
        push    af              ; Save type
        call    eval            ; Evaluate expression
        pop     af              ; Restore type
        ex      (sp),hl         ; Save code - Get var addr
        ld      (brklin),hl     ; Save address of variable
        rra                     ; Adjust type
        call    chktyp          ; Check types are the same
        jr      z,letnum        ; Numeric - Move value
letstr: push    hl              ; Save address of string var
        ld      hl,(fpreg)      ; Pointer to string entry
        push    hl              ; Save it on stack
        inc     hl              ; Skip over length
        inc     hl
        ld      e,(hl)          ; LSB of string address
        inc     hl
        ld      d,(hl)          ; MSB of string address
        ld      hl,(bastxt)     ; Point to start of program
        call    cphlde          ; Is string before program?
        jr      nc,crestr       ; Yes - Create string entry
        ld      hl,(strspc)     ; Point to string space
        call    cphlde          ; Is string literal in program?
        pop     de              ; Restore address of string
        jr      nc,mvstpt       ; Yes - Set up pointer
        ld      hl,tmpstr       ; Temporary string pool
        call    cphlde          ; Is string in temporary pool?
        jr      nc,mvstpt       ; No - Set up pointer
        defb    $3e             ; Skip "POP DE"
crestr: pop     de              ; Restore address of string
        call    baktmp          ; Back to last tmp-str entry
        ex      de,hl           ; Address of string entry
        call    savstr          ; Save string in string area
mvstpt: call    baktmp          ; Back to last tmp-str entry
        pop     hl              ; Get string pointer
        call    dethl4          ; Move string pointer to var
        pop     hl              ; Restore code string address
        ret

letnum: push    hl              ; Save address of variable
        call    fpthl           ; Move value to variable
        pop     de              ; Restore address of variable
        pop     hl              ; Restore code string address
        ret
;------------------------------------------------------------------------------
; ON Gosub/Goto
;------------------------------------------------------------------------------
on:     call    getint          ; Get integer 0-255
        ld      a,(hl)          ; Get "GOTO" or "GOSUB" token
        ld      b,a             ; Save in B
        cp      zgosub          ; "GOSUB" token?
        jr      z,ongo          ; Yes - Find line number
        call    chksyn          ; Make sure it's "GOTO"
        defb   zgoto           ; "GOTO" token
        dec     hl              ; Cancel increment
ongo:   ld      c,e             ; Integer of branch value
ongolp: dec     c               ; Count branches
        ld      a,b             ; Get "GOTO" or "GOSUB" token
        jp      z,onjmp         ; Go to that line if right one
        call    getln           ; Get line number to DE
        cp      ','             ; Another line number?
        ret     nz              ; No - Drop through
        jr      ongolp          ; Yes - loop
;------------------------------------------------------------------------------
; IF/THEN
;------------------------------------------------------------------------------
ift:    call    eval            ; Evaluate expression
        ld      a,(hl)          ; Get token
        cp      zgoto           ; "GOTO" token?
        jr      z,iftgo         ; Yes - Get line
        call    chksyn          ; Make sure it's "THEN"
        defb    zthen           ; "THEN" token
        dec     hl              ; Cancel increment
iftgo:  call    tstnum          ; Make sure it's numeric
        call    tstsgn          ; Test state of expression
        jp      z,rem           ; False - Drop through
        call    getchr          ; Get next character
        jp      c,goto          ; Number - GOTO that line
        jp      ifjmp           ; Otherwise do statement
;------------------------------------------------------------------------------
; PRINTing routines
;------------------------------------------------------------------------------
mrprnt: dec     hl              ; DEC 'cos GETCHR INCs
        call    getchr          ; Get next character
prints: jp      z,prntcr        ; CRLF if just PRINT
prntlp: ret     z               ; End of list - Exit
        cp      ztab            ; "TAB(" token?
        jp      z,dotab         ; Yes - Do TAB routine
        cp      zspc            ; "SPC(" token?
        jp      z,dotab         ; Yes - Do SPC routine
        push    hl              ; Save code string address
        cp      ','             ; Comma?
        jp      z,docom         ; Yes - Move to next zone
        cp      $3b             ; Semi-colon?
        jp      z,nexitm        ; Do semi-colon routine
        pop     bc              ; Code string address to BC
        call    eval            ; Evaluate expression
        push    hl              ; Save code string address
        ld      a,(type)        ; Get variable type
        or      a               ; Is it a string variable?
        jr      nz,prntst       ; Yes - Output string contents
        call    numasc          ; Convert number to text
        call    crtst           ; Create temporary string
        ld      (hl),$20        ; Followed by a space
        ld      hl,(fpreg)      ; Get length of output
        inc     (hl)            ; Plus 1 for the space
        ld      hl,(fpreg)      ; < Not needed >
        ld      a,(lwidth)      ; Get width of line
        ld      b,a             ; To B
        inc     b               ; Width 255 (No limit)?
        jr      z,prntnb        ; Yes - Output number string
        inc     b               ; Adjust it
        ld      a,(curpos)      ; Get cursor position
        add     a,(hl)          ; Add length of string
        dec     a               ; Adjust it
        cp      b               ; Will output fit on this line?
        call    nc,prntcr       ; No - CRLF first
prntnb: call    prs1            ; Output string at (HL)
        xor     a               ; Skip CALL by setting "Z" flag
prntst: call    nz,prs1         ; Output string at (HL)
        pop     hl              ; Restore code string address
        jp      mrprnt          ; See if more to PRINT
;------------------------------------------------------------------------------
; PRINT A NEW LINE
;------------------------------------------------------------------------------
sttlin: ld      a,(curpos)      ; Make sure on new line
        or      a               ; Already at start?
        ret     z               ; Yes - Do nothing
        jr      prntcr          ; Start a new line
;------------------------------------------------------------------------------
endinp: ld      (hl),0          ; Mark end of buffer
        ld      hl,buffer-1     ; Point to buffer
prntcr: ld      a,cr            ; Load a CR
        call    outc            ; Output character
        ld	a,lf		; Load a LF
	call	outc		; Output character
donull: xor     a               ; Set to position 0
        ld      (curpos),a      ; Store it
        ld      a,(nulls)       ; Get number of nulls
nullp:  dec     a               ; Count them
        ret     z               ; Return if done
        push    af              ; Save count
        xor     a               ; Load a null
        call    outc            ; Output it
        pop     af              ; Restore count
        jr      nullp           ; Keep counting
;------------------------------------------------------------------------------
; PROCESS COMMA FOR SPACING
;------------------------------------------------------------------------------
docom:  ld      a,(lwidth)      ; Get terminal width
        ld      b,a             ; Save in B
        ld      a,(curpos)      ; Get current position
        ld	c,a		; Save in C
        ld	a,(comman)	; Get comma width
        add	a,c		; Add to current cursor location
        cp      b               ; Within the terminal width limit?
        call    nc,prntcr       ; Beyond limit - output CRLF
        jr      nc,nexitm       ; Get next item
zonelp: sub     5               ; Next zone of 5 characters
        jr      nc,zonelp       ; Repeat if more zones
        cpl                     ; Number of spaces to output
        jr      aspcs           ; Output them
;------------------------------------------------------------------------------
; PROCESS "TAB(X)" FOR SPACING
;------------------------------------------------------------------------------
dotab:  push    af              ; Save token
        call    fndnum          ; Evaluate expression
        call    chksyn          ; Make sure ")" follows
        defb    ")"
        dec     hl              ; Back space on to ")"
        pop     af              ; Restore token
        sub     zspc            ; Was it "SPC(" ?
        push    hl              ; Save code string address
        jr      z,dospc         ; Yes - Do "E" spaces
        ld      a,(curpos)      ; Get current position
dospc:  cpl                     ; Number of spaces to print to
        add     a,e             ; Total number to print
        jr      nc,nexitm       ; TAB < Current POS(X)
aspcs:  inc     a               ; Output A spaces
        ld      b,a             ; Save number to print
        ld      a,$20           ; Space
spclp:  call    outc            ; Output character in A
        dec     b               ; Count them
        jr      nz,spclp        ; Repeat if more
nexitm: pop     hl              ; Restore code string address
        call    getchr          ; Get next character
        jp      prntlp          ; More to print
;------------------------------------------------------------------------------
; INPUT
;------------------------------------------------------------------------------
input:  call    idtest          ; Test for illegal direct
        ld      a,(hl)          ; Get character after "INPUT"
        cp      $22             ; Is there a prompt string?
        ld      a,0             ; Clear A and leave flags
        ld      (ctlofg),a      ; Enable output
        jr      nz,nopmpt       ; No prompt - get input
        call    qtstr           ; Get string terminated by '"'
        call    chksyn          ; Check for ";" after prompt
        defb	$3b		; SEMI COLON
        push    hl              ; Save code string address
        call    prs1            ; Output prompt string
        defb    $3e             ; Skip "PUSH HL"
nopmpt: push    hl              ; Save code string address
        call    prompt          ; Get input with "? " prompt
        pop     bc              ; Restore code string address
        jp      c,inpbrk        ; Break pressed - Exit
        inc     hl              ; Next byte
        ld      a,(hl)          ; Get it
        or      a               ; End of line?
        dec     hl              ; Back again
        push    bc              ; Re-save code string address
        jp      z,nxtdta        ; Yes - Find next DATA stmt
        ld      (hl),','        ; Store comma as separator
        jp      nxtitm          ; Get next item
;------------------------------------------------------------------------------
; LREAD data
;------------------------------------------------------------------------------
lread:  push    hl              ; Save code string address
        ld      hl,(nxtdat)     ; Next DATA statement
        defb    $f6             ; Flag "LREAD"
nxtitm: xor     a               ; Flag "INPUT"
        ld      (lreadfg),a     ; Save "LREAD"/"INPUT" flag
        ex      (sp),hl         ; Get code str' , Save pointer
        jr      gtvlus          ; Get values

nedmor: call    chksyn          ; Check for comma between items
        defb    ','
gtvlus: call    getvar          ; Get variable name
        ex      (sp),hl         ; Save code str" , Get pointer
        push    de              ; Save variable address
        ld      a,(hl)          ; Get next "INPUT"/"DATA" byte
        cp      ','             ; Comma?
        jr      z,antvlu        ; Yes - Get another value
        ld      a,(lreadfg)     ; Is it LREAD?
        or      a
        jp      nz,fdtlp        ; Yes - Find next DATA stmt
        ld      a,'?'           ; More INPUT needed
        call    outc            ; Output character
        call    prompt          ; Get INPUT with prompt
        pop     de              ; Variable address
        pop     bc              ; Code string address
        jp      c,inpbrk        ; Break pressed
        inc     hl              ; Point to next DATA byte
        ld      a,(hl)          ; Get byte
        or      a               ; Is it zero (No input) ?
        dec     hl              ; Back space INPUT pointer
        push    bc              ; Save code string address
        jp      z,nxtdta        ; Find end of buffer
        push    de              ; Save variable address
antvlu: ld      a,(type)        ; Check data type
        or      a               ; Is it numeric?
        jr      z,inpbin        ; Yes - Convert to binary
        call    getchr          ; Get next character
        ld      d,a             ; Save input character
        ld      b,a             ; Again
        cp      $22             ; Start of literal sting?
        jr      z,strent        ; Yes - Create string entry
        ld      a,(lreadfg)     ; "LREAD" or "INPUT" ?
        or      a
        ld      d,a             ; Save 00 if "INPUT"
        jr      z,itmsep        ; "INPUT" - End with 00
        ld      d,$3a           ; "DATA" - End with 00 or ":"
itmsep: ld      b,','           ; Item separator
        dec     hl              ; Back space for DTSTR
strent: call    dtstr           ; Get string terminated by D
        ex      de,hl           ; String address to DE
        ld      hl,ltstnd       ; Where to go after LETSTR
        ex      (sp),hl         ; Save HL , get input pointer
        push    de              ; Save address of string
        jp      letstr          ; Assign string to variable

inpbin: call    getchr          ; Get next character
        call    asctfp          ; Convert ASCII to FP number
        ex      (sp),hl         ; Save input ptr, Get var addr
        call    fpthl           ; Move FPREG to variable
        pop     hl              ; Restore input pointer
ltstnd: dec     hl              ; DEC 'cos GETCHR INCs
        call    getchr          ; Get next character
        jr      z,mordt         ; End of line - More needed?
        cp      ','             ; Another value?
        jp      nz,badinp       ; No - Bad input
mordt:  ex      (sp),hl         ; Get code string address
        dec     hl              ; DEC 'cos GETCHR INCs
        call    getchr          ; Get next character
        jr      nz,nedmor       ; More needed - Get it
        pop     de              ; Restore DATA pointer
        ld      a,(lreadfg)     ; "LREAD" or "INPUT" ?
        or      a
        ex      de,hl           ; DATA pointer to HL
        jp      nz,updata       ; Update DATA pointer if "LREAD"
        push    de              ; Save code string address
        or      (hl)            ; More input given?
        ld      hl,extig        ; "?Extra ignored" message
        call    nz,prs          ; Output string if extra given
        pop     hl              ; Restore code string address
        ret
fdtlp:  call    data            ; Get next statement
        or      a               ; End of line?
        jr      nz,fandt        ; No - See if DATA statement
        inc     hl
        ld      a,(hl)          ; End of program?
        inc     hl
        or      (hl)            ; 00 00 Ends program
        ld      e,od            ; ?OD Error
        jp      z,error         ; Yes - Out of DATA
        inc     hl
        ld      e,(hl)          ; LSB of line number
        inc     hl
        ld      d,(hl)          ; MSB of line number
        ex      de,hl
        ld      (datlin),hl     ; Set line of current DATA item
        ex      de,hl
fandt:  call    getchr          ; Get next character
        cp      zdata           ; "DATA" token
        jr      nz,fdtlp        ; No "DATA" - Keep looking
        jr      antvlu          ; Found - Convert input

badinp: ld      a,(lreadfg)     ; LREAD or INPUT?
        or      a
        jp      nz,datsnr       ; LREAD - ? Data Syntax Error
        pop     bc              ; Throw away code string addr
        ld      hl,redo         ; "Redo from start" message
        call    prs             ; Output string
        jp      doagn           ; Do last INPUT again
;------------------------------------------------------------------------------
; NEXT
;------------------------------------------------------------------------------
next:   ld      de,0            ; In case no index given
next1:  call    nz,getvar       ; Get index address
        ld      (brklin),hl     ; Save code string address
        call    bakstk          ; Look for "FOR" block
        jp      nz,nferr        ; No "FOR" - "Next without FOR" Error
        ld      sp,hl           ; Clear nested loops
        push    de              ; Save index address
        ld      a,(hl)          ; Get sign of STEP
        inc     hl
        push    af              ; Save sign of STEP
        push    de              ; Save index address
        call    phltfp          ; Move index value to FPREG
        ex      (sp),hl         ; Save address of TO value
        push    hl              ; Save address of index
        call    addphl          ; Add STEP to index value
        pop     hl              ; Restore address of index
        call    fpthl           ; Move value to index variable
        pop     hl              ; Restore address of TO value
        call    loadfp          ; Move TO value to BCDE
        push    hl              ; Save address of line of FOR
        call    cmpnum          ; Compare index with TO value
        pop     hl              ; Restore address of line num
        pop     bc              ; Address of sign of STEP
        sub     b               ; Compare with expected sign
        call    loadfp          ; BC = Loop stmt,DE = Line num
        jp      z,kilfor        ; Loop finished - Terminate it
        ex      de,hl           ; Loop statement line number
        ld      (lineat),hl     ; Set loop line number
        ld      l,c             ; Set code string to loop
        ld      h,b
        jp      putfid          ; Put back "FOR" and continue

kilfor: ld      sp,hl           ; Remove "FOR" block
        ld      hl,(brklin)     ; Code string after "NEXT"
        ld      a,(hl)          ; Get next byte in code string
        cp      ','             ; More NEXTs ?
        jp      nz,runcnt       ; No - Do next statement
        call    getchr          ; Position to index name
        jr      next1           ; Re-enter NEXT routine
;------------------------------------------------------------------------------
; Evaluate and Process variable/math functions
;------------------------------------------------------------------------------
getnum: call    eval            ; Get a numeric expression
tstnum: defb    $f6             ; Clear carry (numeric)
tststr: scf                     ; Set carry (string)
chktyp: ld      a,(type)        ; Check types match
        adc     a,a             ; Expected + actual
        or      a               ; Clear carry , set parity
        ret     pe              ; Even parity - Types match
        jp      tmerr           ; Different types - Error

opnpar: call    chksyn          ; Make sure "(" follows
        defb   '('
eval:   dec     hl              ; Evaluate expression & save
        ld      d,0             ; Precedence value
eval1:  push    de              ; Save precedence
        ld      c,1
        call    chkstk          ; Check for 1 level of stack
        call    oprnd           ; Get next expression value
eval2:  ld      (nxtopr),hl     ; Save address of next operator
eval3:  ld      hl,(nxtopr)     ; Restore address of next opr
        pop     bc              ; Precedence value and operator
        ld      a,b             ; Get precedence value
        cp      $78             ; "AND" or "OR" ?
        call    nc,tstnum       ; No - Make sure it's a number
        ld      a,(hl)          ; Get next operator / function
        ld      d,0             ; Clear Last relation
rltlp:  sub     zgtr            ; ">" Token
        jr      c,foprnd        ; + - * / ^ AND OR - Test it
        cp      zlth+1-zgtr     ; < = >
        jr      nc,foprnd       ; Function - Call it
        cp      zequal-zgtr     ; "="
        rla                     ; <- Test for legal
        xor     d               ; <- combinations of < = >
        cp      d               ; <- by combining last token
        ld      d,a             ; <- with current one
        jp      c,snerr         ; Error if "<<" "==" or ">>"
        ld      (curopr),hl     ; Save address of current token
        call    getchr          ; Get next character
        jr      rltlp           ; Treat the two as one

foprnd: ld      a,d             ; < = > found ?
        or      a
        jp      nz,tstred       ; Yes - Test for reduction
        ld      a,(hl)          ; Get operator token
        ld      (curopr),hl     ; Save operator address
        sub     zplus           ; Operator or function?
        ret     c               ; Neither - Exit
        cp      zor+1-zplus     ; Is it + - * / ^ AND OR ?
        ret     nc              ; No - Exit
        ld      e,a             ; Coded operator
        ld      a,(type)        ; Get data type
        dec     a               ; FF = numeric , 00 = string
        or      e               ; Combine with coded operator
        ld      a,e             ; Get coded operator
        jp      z,concat        ; String concatenation
        rlca                    ; Times 2
        add     a,e             ; Times 3
        ld      e,a             ; To DE (D is 0)
        ld      hl,pritab       ; Precedence table
        add     hl,de           ; To the operator concerned
        ld      a,b             ; Last operator precedence
        ld      d,(hl)          ; Get evaluation precedence
        cp      d               ; Compare with eval precedence
        ret     nc              ; Exit if higher precedence
        inc     hl              ; Point to routine address
        call    tstnum          ; Make sure it's a number

stkths: push    bc              ; Save last precedence & token
        ld      bc,eval3        ; Where to go on prec' break
        push    bc              ; Save on stack for return
        ld      b,e             ; Save operator
        ld      c,d             ; Save precedence
        call    stakfp          ; Move value to stack
        ld      e,b             ; Restore operator
        ld      d,c             ; Restore precedence
        ld      c,(hl)          ; Get LSB of routine address
        inc     hl
        ld      b,(hl)          ; Get MSB of routine address
        inc     hl
        push    bc              ; Save routine address
        ld      hl,(curopr)     ; Address of current operator
        jp      eval1           ; Loop until prec' break
;------------------------------------------------------------------------------
; Process Operand
;------------------------------------------------------------------------------
oprnd:  xor     a               ; Get operand routine
        ld      (type),a        ; Set numeric expected
        call    getchr          ; Get next character
        ld      e,mo            ; Error - Missing Operand
        jp      z,error         ; No operand - Error
        jp      c,asctfp        ; Number - Get value
        call    chkltr          ; See if a letter
        jp      nc,convar       ; Letter - Find variable
     	
     	cp	'$'		; Hex number indicated? [function added]
     	jp	z,hextfp	; Convert Hex to FPREG
     
        cp      zplus           ; "+" Token ?
        jr      z,oprnd         ; Yes - Look for operand
        cp      '.'             ; "." ?
        jp      z,asctfp        ; Yes - Create FP number
        cp      zminus          ; "-" Token ?
        jp      z,minus         ; Yes - Do minus
        cp      $22             ; Literal string ?
        jp      z,qtstr         ; Get string terminated by '"'
        cp      znot            ; "NOT" Token ?
        jp      z,evnot         ; Yes - Eval NOT expression
        cp      zfn             ; "FN" Token ?
        jp      z,dofn          ; Yes - Do FN routine
        sub     zsgn            ; Is it a function?
        jp      nc,fnofst       ; Yes - Evaluate function
evlpar: call    opnpar          ; Evaluate expression in "()"
        call    chksyn          ; Make sure ")" follows
        defb   ')'
        ret

minus:  ld      d,7dh           ; "-" precedence
        call    eval1           ; Evaluate until prec' break
        ld      hl,(nxtopr)     ; Get next operator address
        push    hl              ; Save next operator address
        call    invsgn          ; Negate value
retnum: call    tstnum          ; Make sure it's a number
        pop     hl              ; Restore next operator address
        ret
;------------------------------------------------------------------------------
; Loads a variable with name at (HL) into FPREG
;------------------------------------------------------------------------------
convar: call    getvar          ; Get variable address to DE
frmevl: push    hl              ; Save code string address
        ex      de,hl           ; Variable address to HL
        ld      (fpreg),hl      ; Save address of variable
        ld      a,(type)        ; Get type
        or      a               ; Numeric?
        call    z,phltfp        ; Yes - Move contents to FPREG
        pop     hl              ; Restore code string address
        ret

fnofst: ld      b,0             ; Get address of function
        rlca                    ; Double function offset
        ld      c,a             ; BC = Offset in function table
        push    bc              ; Save adjusted token value
        call    getchr          ; Get next character
        ld      a,c             ; Get adjusted token value
        cp      2*(zpoint-zsgn) ; Adjusted "POINT" token?
        jp      z,point         ; Yes - Do "POINT"
        cp      2*(zleft-zsgn)-1; Adj' LEFT$,RIGHT$ or MID$ ?
        jr      c,fnval         ; No - Do function
        call    opnpar          ; Evaluate expression  (X,...
        call    chksyn          ; Make sure "," follows
        defb   ','
        call    tststr          ; Make sure it's a string
        ex      de,hl           ; Save code string address
        ld      hl,(fpreg)      ; Get address of string
        ex      (sp),hl         ; Save address of string
        push    hl              ; Save adjusted token value
        ex      de,hl           ; Restore code string address
        call    getint          ; Get integer 0-255
        ex      de,hl           ; Save code string address
        ex      (sp),hl         ; Save integer,HL = adj' token
        jr      gofunc          ; Jump to string function

fnval:  call    evlpar          ; Evaluate expression
        ex      (sp),hl         ; HL = Adjusted token value
        ld      de,retnum       ; Return number from function
        push    de              ; Save on stack
gofunc: ld      bc,fnctab       ; Function routine addresses
        add     hl,bc           ; Point to right address
        ld      c,(hl)          ; Get LSB of address
        inc     hl              ;
        ld      h,(hl)          ; Get MSB of address
        ld      l,c             ; Address to HL
        jp      (hl)            ; Jump to function

sgnexp: dec     d               ; Dee to flag negative exponent
        cp      zminus          ; "-" token ?
        ret     z               ; Yes - Return
        cp      '-'             ; "-" ASCII ?
        ret     z               ; Yes - Return
        inc     d               ; Inc to flag positive exponent
        cp      '+'             ; "+" ASCII ?
        ret     z               ; Yes - Return
        cp      zplus           ; "+" token ?
        ret     z               ; Yes - Return
        dec     hl              ; DEC 'cos GETCHR INCs
        ret                     ; Return "NZ"
;------------------------------------------------------------------------------
; AND / OR integer FPREG < FPREG (AND/OR) last
;------------------------------------------------------------------------------
por:    defb    $f6             ; Flag "OR"
pand:   xor     a               ; Flag "AND"
        push    af              ; Save "AND" / "OR" flag
        call    tstnum          ; Make sure it's a number
        call    deint           ; Get integer -32768 to 32767
        pop     af              ; Restore "AND" / "OR" flag
        ex      de,hl           ; <- Get last
        pop     bc              ; <-  value
        ex      (sp),hl         ; <-  from
        ex      de,hl           ; <-  stack
        call    fpbcde          ; Move last value to FPREG
        push    af              ; Save "AND" / "OR" flag
        call    deint           ; Get integer -32768 to 32767
        pop     af              ; Restore "AND" / "OR" flag
        pop     bc              ; Get value
        ld      a,c             ; Get LSB
        ld      hl,acpass       ; Address of save AC as current
        jr      nz,por1         ; Jump if OR
        and     e               ; "AND" LSBs
        ld      c,a             ; Save LSB
        ld      a,b             ; Get MBS
        and     d               ; "AND" MSBs
        jp      (hl)            ; Save AC as current (ACPASS)

por1:   or      e               ; "OR" LSBs
        ld      c,a             ; Save LSB
        ld      a,b             ; Get MSB
        or      d               ; "OR" MSBs
        jp      (hl)            ; Save AC as current (ACPASS)
;------------------------------------------------------------------------------
tstred  ld      hl,cmplog       ; Logical compare routine
        ld      a,(type)        ; Get data type
        rra                     ; Carry set = string
        ld      a,d             ; Get last precedence value
        rla                     ; Times 2 plus carry
        ld      e,a             ; To E
        ld      d,64h           ; Relational precedence
        ld      a,b             ; Get current precedence
        cp      d               ; Compare with last
        ret     nc              ; Eval if last was rel' or log'
        jp      stkths          ; Stack this one and get next

cmplog  defw    cmplg1          ; Compare two values / strings
cmplg1  ld      a,c             ; Get data type
        or      a
        rra
        pop     bc              ; Get last expression to BCDE
        pop     de
        push    af              ; Save status
        call    chktyp          ; Check that types match
        ld      hl,cmpres       ; Result to comparison
        push    hl              ; Save for RETurn
        jp      z,cmpnum        ; Compare values if numeric
        xor     a               ; Compare two strings
        ld      (type),a        ; Set type to numeric
        push    de              ; Save string name
        call    gstrcu          ; Get current string
        ld      a,(hl)          ; Get length of string
        inc     hl
        inc     hl
        ld      c,(hl)          ; Get LSB of address
        inc     hl
        ld      b,(hl)          ; Get MSB of address
        pop     de              ; Restore string name
        push    bc              ; Save address of string
        push    af              ; Save length of string
        call    gstrde          ; Get second string
        call    loadfp          ; Get address of second string
        pop     af              ; Restore length of string 1
        ld      d,a             ; Length to D
        pop     hl              ; Restore address of string 1
cmpstr  ld      a,e             ; Bytes of string 2 to do
        or      d               ; Bytes of string 1 to do
        ret     z               ; Exit if all bytes compared
        ld      a,d             ; Get bytes of string 1 to do
        sub     1
        ret     c               ; Exit if end of string 1
        xor     a
        cp      e               ; Bytes of string 2 to do
        inc     a
        ret     nc              ; Exit if end of string 2
        dec     d               ; Count bytes in string 1
        dec     e               ; Count bytes in string 2
        ld      a,(bc)          ; Byte in string 2
        cp      (hl)            ; Compare to byte in string 1
        inc     hl              ; Move up string 1
        inc     bc              ; Move up string 2
        jr      z,cmpstr        ; Same - Try next bytes
        ccf                     ; Flag difference (">" or "<")
        jp      flgdif          ; "<" gives -1 , ">" gives +1

cmpres  inc     a               ; Increment current value
        adc     a,a             ; Double plus carry
        pop     bc              ; Get other value
        and     b               ; Combine them
        add     a,-1            ; Carry set if different
        sbc     a,a             ; 00 - Equal , FF - Different
        jp      flgrel          ; Set current value & continue
;------------------------------------------------------------------------------
; NOT  FPREG = NOT(FPREG)
;------------------------------------------------------------------------------
evnot   ld      d,5ah           ; Precedence value for "NOT"
        call    eval1           ; Eval until precedence break
        call    tstnum          ; Make sure it's a number
        call    deint           ; Get integer -32768 - 32767
        ld      a,e             ; Get LSB
        cpl                     ; Invert LSB
        ld      c,a             ; Save "NOT" of LSB
        ld      a,d             ; Get MSB
        cpl                     ; Invert MSB
        call    acpass          ; Save AC as current
        pop     bc              ; Clean up stack
        jp      eval3           ; Continue evaluation
;------------------------------------------------------------------------------
; DIM
;------------------------------------------------------------------------------
dimret  dec     hl              ; DEC 'cos GETCHR INCs
        call    getchr          ; Get next character
        ret     z               ; End of DIM statement
        call    chksyn          ; Make sure "," follows
        defb    ','
dim     ld      bc,dimret       ; Return to "DIMRET"
        push    bc              ; Save on stack
        defb    0f6h            ; Flag "Create" variable
getvar  xor     a               ; Find variable address,to DE
        ld      (lcrflg),a      ; Set locate / create flag
        ld      b,(hl)          ; Get First byte of name
gtfnam  call    chkltr          ; See if a letter
        jp      c,snerr         ; ?SN Error if not a letter
        xor     a
        ld      c,a             ; Clear second byte of name
        ld      (type),a        ; Set type to numeric
        call    getchr          ; Get next character
        jr      c,svnam2        ; Numeric - Save in name
        call    chkltr          ; See if a letter
        jr      c,charty        ; Not a letter - Check type
svnam2  ld      c,a             ; Save second byte of name
endnam  call    getchr          ; Get next character
        jr      c,endnam        ; Numeric - Get another
        call    chkltr          ; See if a letter
        jr      nc,endnam       ; Letter - Get another
charty  sub     '$'             ; String variable?
        jr      nz,notstr       ; No - Numeric variable
        inc     a               ; A = 1 (string type)
        ld      (type),a        ; Set type to string
        rrca                    ; A = 80H , Flag for string
        add     a,c             ; 2nd byte of name has bit 7 on
        ld      c,a             ; Resave second byte on name
        call    getchr          ; Get next character
notstr  ld      a,(forflg)      ; Array name needed ?
        dec     a
        jp      z,arldsv        ; Yes - Get array name
        jp      p,nscfor        ; No array with "FOR" or "FN"
        ld      a,(hl)          ; Get byte again
        sub     '('             ; Subscripted variable?
        jp      z,sbscpt        ; Yes - Sort out subscript

nscfor  xor     a               ; Simple variable
        ld      (forflg),a      ; Clear "FOR" flag
        push    hl              ; Save code string address
        ld      d,b             ; DE = Variable name to find
        ld      e,c
        ld      hl,(fnrgnm)     ; FN argument name
        call    cphlde          ; Is it the FN argument?
        ld      de,fnarg        ; Point to argument value
        jp      z,pophrt        ; Yes - Return FN argument value
        ld      hl,(varend)     ; End of variables
        ex      de,hl           ; Address of end of search
        ld      hl,(prognd)     ; Start of variables address
fndvar  call    cphlde          ; End of variable list table?
        jr      z,cfeval        ; Yes - Called from EVAL?
        ld      a,c             ; Get second byte of name
        sub     (hl)            ; Compare with name in list
        inc     hl              ; Move on to first byte
        jr      nz,fnthr        ; Different - Find another
        ld      a,b             ; Get first byte of name
        sub     (hl)            ; Compare with name in list
fnthr   inc     hl              ; Move on to LSB of value
        jp      z,retadr        ; Found - Return address
        inc     hl              ; <- Skip
        inc     hl              ; <- over
        inc     hl              ; <- F.P.
        inc     hl              ; <- value
        jp      fndvar          ; Keep looking

cfeval  pop     hl              ; Restore code string address
        ex      (sp),hl         ; Get return address
        push    de              ; Save address of variable
        ld      de,frmevl       ; Return address in EVAL
        call    cphlde          ; Called from EVAL ?
        pop     de              ; Restore address of variable
        jp      z,retnul        ; Yes - Return null variable
        ex      (sp),hl         ; Put back return
        push    hl              ; Save code string address
        push    bc              ; Save variable name
        ld      bc,6            ; 2 byte name plus 4 byte data
        ld      hl,(arrend)     ; End of arrays
        push    hl              ; Save end of arrays
        add     hl,bc           ; Move up 6 bytes
        pop     bc              ; Source address in BC
        push    hl              ; Save new end address
        call    movup           ; Move arrays up
        pop     hl              ; Restore new end address
        ld      (arrend),hl     ; Set new end address
        ld      h,b             ; End of variables to HL
        ld      l,c
        ld      (varend),hl     ; Set new end address

zerolp  dec     hl              ; Back through to zero variable
        ld      (hl),0          ; Zero byte in variable
        call    cphlde          ; Done them all?
        jp      nz,zerolp       ; No - Keep on going
        pop     de              ; Get variable name
        ld      (hl),e          ; Store second character
        inc     hl
        ld      (hl),d          ; Store first character
        inc     hl
retadr  ex      de,hl           ; Address of variable in DE
        pop     hl              ; Restore code string address
        ret

retnul  ld      (fpexp),a       ; Set result to zero
        ld      hl,zerbyt       ; Also set a null string
        ld      (fpreg),hl      ; Save for EVAL
        pop     hl              ; Restore code string address
        ret

sbscpt  push    hl              ; Save code string address
        ld      hl,(lcrflg)     ; Locate/Create and Type
        ex      (sp),hl         ; Save and get code string
        ld      d,a             ; Zero number of dimensions
scptlp  push    de              ; Save number of dimensions
        push    bc              ; Save array name
        call    fpsint          ; Get subscript (0-32767)
        pop     bc              ; Restore array name
        pop     af              ; Get number of dimensions
        ex      de,hl
        ex      (sp),hl         ; Save subscript value
        push    hl              ; Save LCRFLG and TYPE
        ex      de,hl
        inc     a               ; Count dimensions
        ld      d,a             ; Save in D
        ld      a,(hl)          ; Get next byte in code string
        cp      ','             ; Comma (more to come)?
        jr      z,scptlp        ; Yes - More subscripts
        call    chksyn          ; Make sure ")" follows
        defb    ')'
        ld      (nxtopr),hl     ; Save code string address
        pop     hl              ; Get LCRFLG and TYPE
        ld      (lcrflg),hl     ; Restore Locate/create & type
        ld      e,0             ; Flag not SAVE* or LOAD*
        push    de              ; Save number of dimensions (D)
        defb    $11             ; Skip "PUSH HL" and "PUSH AF'

arldsv  push    hl              ; Save code string address
        push    af              ; A = 00 , Flags set = Z,N
        ld      hl,(varend)     ; Start of arrays
        defb    $3e             ; Skip "ADD HL,DE"
fndary  add     hl,de           ; Move to next array start
        ex      de,hl
        ld      hl,(arrend)     ; End of arrays
        ex      de,hl           ; Current array pointer
        call    cphlde          ; End of arrays found?
        jr      z,creary        ; Yes - Create array
        ld      a,(hl)          ; Get second byte of name
        cp      c               ; Compare with name given
        inc     hl              ; Move on
        jr      nz,nxtary       ; Different - Find next array
        ld      a,(hl)          ; Get first byte of name
        cp      b               ; Compare with name given
nxtary  inc     hl              ; Move on
        ld      e,(hl)          ; Get LSB of next array address
        inc     hl
        ld      d,(hl)          ; Get MSB of next array address
        inc     hl
        jr      nz,fndary       ; Not found - Keep looking
        ld      a,(lcrflg)      ; Found Locate or Create it?
        or      a
        jp      nz,dderr        ; Create - ?DD Error
        pop     af              ; Locate - Get number of dim'ns
        ld      b,h             ; BC Points to array dim'ns
        ld      c,l
        jp      z,pophrt        ; Jump if array load/save
        sub     (hl)            ; Same number of dimensions?
        jp      z,findel        ; Yes - Find element
bserr   ld      e,ws            ; ?BS Error
        jp      error           ; Output error
;------------------------------------------------------------------------------
; CREATE ARRAY IN MEMORY
;------------------------------------------------------------------------------
creary  ld      de,4            ; 4 Bytes per entry
        pop     af              ; Array to save or 0 dim'ns?
        jp      z,fcerr         ; Yes - ?FC Error
        ld      (hl),c          ; Save second byte of name
        inc     hl
        ld      (hl),b          ; Save first byte of name
        inc     hl
        ld      c,a             ; Number of dimensions to C
        call    chkstk          ; Check if enough memory
        inc     hl              ; Point to number of dimensions
        inc     hl
        ld      (curopr),hl     ; Save address of pointer
        ld      (hl),c          ; Set number of dimensions
        inc     hl
        ld      a,(lcrflg)      ; Locate of Create?
        rla                     ; Carry set = Create
        ld      a,c             ; Get number of dimensions
crarlp  ld      bc,10+1         ; Default dimension size 10
        jr      nc,defsiz       ; Locate - Set default size
        pop     bc              ; Get specified dimension size
        inc     bc              ; Include zero element
defsiz  ld      (hl),c          ; Save LSB of dimension size
        inc     hl
        ld      (hl),b          ; Save MSB of dimension size
        inc     hl
        push    af              ; Save num' of dim'ns an status
        push    hl              ; Save address of dim'n size
        call    mldebc          ; Multiply DE by BC to find
        ex      de,hl           ; amount of mem needed (to DE)
        pop     hl              ; Restore address of dimension
        pop     af              ; Restore number of dimensions
        dec     a               ; Count them
        jr      nz,crarlp       ; Do next dimension if more
        push    af              ; Save locate/create flag
        ld      b,d             ; MSB of memory needed
        ld      c,e             ; LSB of memory needed
        ex      de,hl
        add     hl,de           ; Add bytes to array start
        jp      c,omerr         ; Too big - Error
        call    enfmem          ; See if enough memory
        ld      (arrend),hl     ; Save new end of array

zerary  dec     hl              ; Back through array data
        ld      (hl),0          ; Set array element to zero
        call    cphlde          ; All elements zeroed?
        jr      nz,zerary       ; No - Keep on going
        inc     bc              ; Number of bytes + 1
        ld      d,a             ; A=0
        ld      hl,(curopr)     ; Get address of array
        ld      e,(hl)          ; Number of dimensions
        ex      de,hl           ; To HL
        add     hl,hl           ; Two bytes per dimension size
        add     hl,bc           ; Add number of bytes
        ex      de,hl           ; Bytes needed to DE
        dec     hl
        dec     hl
        ld      (hl),e          ; Save LSB of bytes needed
        inc     hl
        ld      (hl),d          ; Save MSB of bytes needed
        inc     hl
        pop     af              ; Locate / Create?
        jr      c,enddim        ; A is 0 , End if create
findel  ld      b,a             ; Find array element
        ld      c,a
        ld      a,(hl)          ; Number of dimensions
        inc     hl
        defb    16h             ; Skip "POP HL"
fndelp  pop     hl              ; Address of next dim' size
        ld      e,(hl)          ; Get LSB of dim'n size
        inc     hl
        ld      d,(hl)          ; Get MSB of dim'n size
        inc     hl
        ex      (sp),hl         ; Save address - Get index
        push    af              ; Save number of dim'ns
        call    cphlde          ; Dimension too large?
        jp      nc,bserr        ; Yes - ?BS Error
        push    hl              ; Save index
        call    mldebc          ; Multiply previous by size
        pop     de              ; Index supplied to DE
        add     hl,de           ; Add index to pointer
        pop     af              ; Number of dimensions
        dec     a               ; Count them
        ld      b,h             ; MSB of pointer
        ld      c,l             ; LSB of pointer
        jr      nz,fndelp       ; More - Keep going
        add     hl,hl           ; 4 Bytes per element
        add     hl,hl
        pop     bc              ; Start of array
        add     hl,bc           ; Point to element
        ex      de,hl           ; Address of element to DE
enddim  ld      hl,(nxtopr)     ; Got code string address
        ret
;------------------------------------------------------------------------------
; FRE list amount of free memory remaining
;------------------------------------------------------------------------------
fre     ld      hl,(arrend)     ; Start of free memory
        ex      de,hl           ; To DE
        ld	hl,(ramtop)	; Top of physical memory
        ld      a,(type)        ; Dummy argument type
        or      a		; If string, return free string memory
        jr      z,frenum        ; Numeric - Free variable space
        call    gstrcu          ; Current string to pool
        call    garbge          ; Garbage collection
        ld      hl,(strspc)     ; Bottom of string space in use
        ex      de,hl           ; To DE
        ld      hl,(strbot)     ; Bottom of string space
frenum  ld      a,l             ; Get LSB of end
        sub     e               ; Subtract LSB of beginning
        ld      c,a             ; Save difference if C
        ld      a,h             ; Get MSB of end
        sbc     a,d             ; Subtract MSB of beginning
;------------------------------------------------------------------------------        
acpass  ld      b,c             ; Return integer AC
abpass  ld      d,b             ; Return integer AB
        ld      e,0		; Numeric type
        ld      hl,type         ; Point to type
        ld      (hl),e          ; Set type to numeric
        ld      b,80h+16        ; 16 bit integer
        jp      retint          ; Return the integer
;------------------------------------------------------------------------------
; POS returns current cursor position
;------------------------------------------------------------------------------
pos     ld      a,(curpos)      ; Get cursor position
passa   ld      b,a             ; Put A into AB
        xor     a               ; Zero A
        jr      abpass          ; Return integer AB
;------------------------------------------------------------------------------
; DEF FN define function
;------------------------------------------------------------------------------
def     call    chekfn          ; Get "FN" and name
        call    idtest          ; Test for illegal direct
        ld      bc,data         ; To get next statement
        push    bc              ; Save address for RETurn
        push    de              ; Save address of function ptr
        call    chksyn          ; Make sure "(" follows
        defb   '('
        call    getvar          ; Get argument variable name
        push    hl              ; Save code string address
        ex      de,hl           ; Argument address to HL
        dec     hl
        ld      d,(hl)          ; Get first byte of arg name
        dec     hl
        ld      e,(hl)          ; Get second byte of arg name
        pop     hl              ; Restore code string address
        call    tstnum          ; Make sure numeric argument
        call    chksyn          ; Make sure ")" follows
        defb   ')'
        call    chksyn          ; Make sure "=" follows
        defb     zequal          ; "=" token
        ld      b,h             ; Code string address to BC
        ld      c,l
        ex      (sp),hl         ; Save code str , Get FN ptr
        ld      (hl),c          ; Save LSB of FN code string
        inc     hl
        ld      (hl),b          ; Save MSB of FN code string
        jp      svstad          ; Save address and do function
;------------------------------------------------------------------------------
; Perform FN function
;------------------------------------------------------------------------------
dofn    call    chekfn          ; Make sure FN follows
        push    de              ; Save function pointer address
        call    evlpar          ; Evaluate expression in "()"
        call    tstnum          ; Make sure numeric result
        ex      (sp),hl         ; Save code str , Get FN ptr
        ld      e,(hl)          ; Get LSB of FN code string
        inc     hl
        ld      d,(hl)          ; Get MSB of FN code string
        inc     hl
        ld      a,d             ; And function DEFined?
        or      e
        jp      z,uferr         ; No - ?UF Error
        ld      a,(hl)          ; Get LSB of argument address
        inc     hl
        ld      h,(hl)          ; Get MSB of argument address
        ld      l,a             ; HL = Arg variable address
        push    hl              ; Save it
        ld      hl,(fnrgnm)     ; Get old argument name
        ex      (sp),hl         ; Save old , Get new
        ld      (fnrgnm),hl     ; Set new argument name
        ld      hl,(fnarg+2)    ; Get LSB,NLSB of old arg value
        push    hl              ; Save it
        ld      hl,(fnarg)      ; Get MSB,EXP of old arg value
        push    hl              ; Save it
        ld      hl,fnarg        ; HL = Value of argument
        push    de              ; Save FN code string address
        call    fpthl           ; Move FPREG to argument
        pop     hl              ; Get FN code string address
        call    getnum          ; Get value from function
        dec     hl              ; DEC 'cos GETCHR INCs
        call    getchr          ; Get next character
        jp      nz,snerr        ; Bad character in FN - Error
        pop     hl              ; Get MSB,EXP of old arg
        ld      (fnarg),hl      ; Restore it
        pop     hl              ; Get LSB,NLSB of old arg
        ld      (fnarg+2),hl    ; Restore it
        pop     hl              ; Get name of old arg
        ld      (fnrgnm),hl     ; Restore it
        pop     hl              ; Restore code string address
        ret
;------------------------------------------------------------------------------
; Determine if Immediate or if operating in program RUN
;------------------------------------------------------------------------------
idtest  push    hl              ; Save code string address
        ld      hl,(lineat)     ; Get current line number
        inc     hl              ; -1 means direct statement
        ld      a,h
        or      l
        pop     hl              ; Restore code string address
        ret     nz              ; Return if in program
        ld      e,id            ; ?ID Error
        jp      error

chekfn  call    chksyn          ; Make sure FN follows
        defb    zfn             ; "FN" token
        ld      a,80h
        ld      (forflg),a      ; Flag FN name to find
        or      (hl)            ; FN name has bit 7 set
        ld      b,a             ; in first byte of name
        call    gtfnam          ; Get FN name
        jp      tstnum          ; Make sure numeric function
;------------------------------------------------------------------------------
; STR function turns numeric into string value
;------------------------------------------------------------------------------
str     call    tstnum          ; Make sure it's a number
        call    numasc          ; Turn number into text
str1    call    crtst           ; Create string entry for it
        call    gstrcu          ; Current string to pool
        ld      bc,topool       ; Save in string pool
        push    bc              ; Save address on stack

savstr  ld      a,(hl)          ; Get string length
        inc     hl
        inc     hl
        push    hl              ; Save pointer to string
        call    testr           ; See if enough string space
        pop     hl              ; Restore pointer to string
        ld      c,(hl)          ; Get LSB of address
        inc     hl
        ld      b,(hl)          ; Get MSB of address
        call    crtmst          ; Create string entry
        push    hl              ; Save pointer to MSB of addr
        ld      l,a             ; Length of string
        call    tostra          ; Move to string area
        pop     de              ; Restore pointer to MSB
        ret
;------------------------------------------------------------------------------
mktmst  call    testr           ; See if enough string space
crtmst  ld      hl,tmpstr       ; Temporary string
        push    hl              ; Save it
        ld      (hl),a          ; Save length of string
        inc     hl
svstad  inc     hl
        ld      (hl),e          ; Save LSB of address
        inc     hl
        ld      (hl),d          ; Save MSB of address
        pop     hl              ; Restore pointer
        ret
;------------------------------------------------------------------------------
crtst   dec     hl              ; DEC - INCed after
qtstr   ld      b,$22           ; Terminating quote "
        ld      d,b             ; Quote to D
dtstr   push    hl              ; Save start
        ld      c,-1            ; Set counter to -1
qtstlp  inc     hl              ; Move on
        ld      a,(hl)          ; Get byte
        inc     c               ; Count bytes
        or      a               ; End of line?
        jr      z,crtste        ; Yes - Create string entry
        cp      d               ; Terminator D found?
        jr      z,crtste        ; Yes - Create string entry
        cp      b               ; Terminator B found?
        jr      nz,qtstlp       ; No - Keep looking
crtste  cp      $22             ; End with '"'?
        call    z,getchr        ; Yes - Get next character
        ex      (sp),hl         ; Starting quote
        inc     hl              ; First byte of string
        ex      de,hl           ; To DE
        ld      a,c             ; Get length
        call    crtmst          ; Create string entry
tstopl  ld      de,tmpstr       ; Temporary string
        ld      hl,(tmstpt)     ; Temporary string pool pointer
        ld      (fpreg),hl      ; Save address of string ptr
        ld      a,1
        ld      (type),a        ; Set type to string
        call    dethl4          ; Move string to pool
        call    cphlde          ; Out of string pool?
        ld      (tmstpt),hl     ; Save new pointer
        pop     hl              ; Restore code string address
        ld      a,(hl)          ; Get next code byte
        ret     nz              ; Return if pool OK
        ld      e,st            ; ?ST Error
        jp      error           ; String pool overflow
;------------------------------------------------------------------------------
; Print String routines
;------------------------------------------------------------------------------
prnums  inc     hl              ; Skip leading space
prs     call    crtst           ; Create string entry for it
prs1    call    gstrcu          ; Current string to pool
        call    loadfp          ; Move string block to BCDE
        inc     e               ; Length + 1
prslp   dec     e               ; Count characters
        ret     z               ; End of string
        ld      a,(bc)          ; Get byte to output
        call    outc            ; Output character in A
        cp      cr              ; Return?
        call    z,donull        ; Yes - Do nulls
        inc     bc              ; Next byte in string
        jr      prslp           ; More characters to output
;------------------------------------------------------------------------------
testr   or      a               ; Test if enough room (string length=A)
        defb    $0e             ; No garbage collection done
grbdon  pop     af              ; Garbage collection done
        push    af              ; Save status
        ld      hl,(strspc)     ; Bottom of string space in use
        ex      de,hl           ; To DE
        ld      hl,(strbot)     ; Bottom of string area
        cpl                     ; Negate length (Top down)
        ld      c,a             ; -Length to BC
        ld      b,-1            ; BC = negeative length of string
        add     hl,bc           ; Add to bottom of space in use
        inc     hl              ; Plus one for 2's complement
        call    cphlde          ; Below string RAM area?
        jr      c,testos        ; Tidy up if not done else err
        ld      (strbot),hl     ; Save new bottom of area
        inc     hl              ; Point to first byte of string
        ex      de,hl           ; Address to DE
popaf   pop     af              ; Throw away status push
        ret
testos  pop     af              ; Garbage collect been done?
        ld      e,os            ; ?OS Error
        jp      z,error         ; Yes - Not enough string apace
        cp      a               ; Flag garbage collect done
        push    af              ; Save status
        ld      bc,grbdon       ; Garbage collection done
        push    bc              ; Save for RETurn
garbge  ld      hl,(lstram)     ; Get end of RAM pointer
garblp  ld      (strbot),hl     ; Reset string pointer
        ld      hl,0
        push    hl              ; Flag no string found
        ld      hl,(strspc)     ; Get bottom of string space
        push    hl              ; Save bottom of string space
        ld      hl,tmstpl       ; Temporary string pool
grblp   ex      de,hl
        ld      hl,(tmstpt)     ; Temporary string pool pointer
        ex      de,hl
        call    cphlde          ; Temporary string pool done?
        ld      bc,grblp        ; Loop until string pool done
        jp      nz,stpool       ; No - See if in string area
        ld      hl,(prognd)     ; Start of simple variables
smpvar  ex      de,hl
        ld      hl,(varend)     ; End of simple variables
        ex      de,hl
        call    cphlde          ; All simple strings done?
        jp      z,arrlp         ; Yes - Do string arrays
        ld      a,(hl)          ; Get type of variable
        inc     hl
        inc     hl
        or      a               ; "S" flag set if string
        call    stradd          ; See if string in string area
        jr      smpvar          ; Loop until simple ones done

gnxary  pop     bc              ; Scrap address of this array
arrlp   ex      de,hl
        ld      hl,(arrend)     ; End of string arrays
        ex      de,hl
        call    cphlde          ; All string arrays done?
        jp      z,scnend        ; Yes - Move string if found
        call    loadfp          ; Get array name to BCDE
        ld      a,e             ; Get type of array
        push    hl              ; Save address of num of dim'ns
        add     hl,bc           ; Start of next array
        or      a               ; Test type of array
        jp      p,gnxary        ; Numeric array - Ignore it
        ld      (curopr),hl     ; Save address of next array
        pop     hl              ; Get address of num of dim'ns
        ld      c,(hl)          ; BC = Number of dimensions
        ld      b,0
        add     hl,bc           ; Two bytes per dimension size
        add     hl,bc
        inc     hl              ; Plus one for number of dim'ns
grbary  ex      de,hl
        ld      hl,(curopr)     ; Get address of next array
        ex      de,hl
        call    cphlde          ; Is this array finished?
        jr      z,arrlp         ; Yes - Get next one
        ld      bc,grbary       ; Loop until array all done
stpool  push    bc              ; Save return address
        or      80h             ; Flag string type
stradd  ld      a,(hl)          ; Get string length
        inc     hl
        inc     hl
        ld      e,(hl)          ; Get LSB of string address
        inc     hl
        ld      d,(hl)          ; Get MSB of string address
        inc     hl
        ret     p               ; Not a string - Return
        or      a               ; Set flags on string length
        ret     z               ; Null string - Return
        ld      b,h             ; Save variable pointer
        ld      c,l
        ld      hl,(strbot)     ; Bottom of new area
        call    cphlde          ; String been done?
        ld      h,b             ; Restore variable pointer
        ld      l,c
        ret     c               ; String done - Ignore
        pop     hl              ; Return address
        ex      (sp),hl         ; Lowest available string area
        call    cphlde          ; String within string area?
        ex      (sp),hl         ; Lowest available string area
        push    hl              ; Re-save return address
        ld      h,b             ; Restore variable pointer
        ld      l,c
        ret     nc              ; Outside string area - Ignore
        pop     bc              ; Get return , Throw 2 away
        pop     af              ; 
        pop     af              ; 
        push    hl              ; Save variable pointer
        push    de              ; Save address of current
        push    bc              ; Put back return address
        ret                     ; Go to it

scnend  pop     de              ; Addresses of strings
        pop     hl              ; 
        ld      a,l             ; HL = 0 if no more to do
        or      h
        ret     z               ; No more to do - Return
        dec     hl
        ld      b,(hl)          ; MSB of address of string
        dec     hl
        ld      c,(hl)          ; LSB of address of string
        push    hl              ; Save variable address
        dec     hl
        dec     hl
        ld      l,(hl)          ; HL = Length of string
        ld      h,0
        add     hl,bc           ; Address of end of string+1
        ld      d,b             ; String address to DE
        ld      e,c
        dec     hl              ; Last byte in string
        ld      b,h             ; Address to BC
        ld      c,l
        ld      hl,(strbot)     ; Current bottom of string area
        call    movstr          ; Move string to new address
        pop     hl              ; Restore variable address
        ld      (hl),c          ; Save new LSB of address
        inc     hl
        ld      (hl),b          ; Save new MSB of address
        ld      l,c             ; Next string area+1 to HL
        ld      h,b
        dec     hl              ; Next string area address
        jp      garblp          ; Look for more strings

concat  push    bc              ; Save prec' opr & code string
        push    hl              ; 
        ld      hl,(fpreg)      ; Get first string
        ex      (sp),hl         ; Save first string
        call    oprnd           ; Get second string
        ex      (sp),hl         ; Restore first string
        call    tststr          ; Make sure it's a string
        ld      a,(hl)          ; Get length of second string
        push    hl              ; Save first string
        ld      hl,(fpreg)      ; Get second string
        push    hl              ; Save second string
        add     a,(hl)          ; Add length of second string
        ld      e,ls            ; ?LS Error
        jp      c,error         ; String too long - Error
        call    mktmst          ; Make temporary string
        pop     de              ; Get second string to DE
        call    gstrde          ; Move to string pool if needed
        ex      (sp),hl         ; Get first string
        call    gstrhl          ; Move to string pool if needed
        push    hl              ; Save first string
        ld      hl,(tmpstr+2)   ; Temporary string address
        ex      de,hl           ; To DE
        call    sstsa           ; First string to string area
        call    sstsa           ; Second string to string area
        ld      hl,eval2        ; Return to evaluation loop
        ex      (sp),hl         ; Save return,get code string
        push    hl              ; Save code string address
        jp      tstopl          ; To temporary string to pool

sstsa   pop     hl              ; Return address
        ex      (sp),hl         ; Get string block,save return
        ld      a,(hl)          ; Get length of string
        inc     hl
        inc     hl
        ld      c,(hl)          ; Get LSB of string address
        inc     hl
        ld      b,(hl)          ; Get MSB of string address
        ld      l,a             ; Length to L
tostra  inc     l               ; INC - DECed after
tsalp   dec     l               ; Count bytes moved
        ret     z               ; End of string - Return
        ld      a,(bc)          ; Get source
        ld      (de),a          ; Save destination
        inc     bc              ; Next source
        inc     de              ; Next destination
        jr      tsalp           ; Loop until string moved

getstr  call    tststr          ; Make sure it's a string
gstrcu  ld      hl,(fpreg)      ; Get current string
gstrhl  ex      de,hl           ; Save DE
gstrde  call    baktmp          ; Was it last tmp-str?
        ex      de,hl           ; Restore DE
        ret     nz              ; No - Return
        push    de              ; Save string
        ld      d,b             ; String block address to DE
        ld      e,c
        dec     de              ; Point to length
        ld      c,(hl)          ; Get string length
        ld      hl,(strbot)     ; Current bottom of string area
        call    cphlde          ; Last one in string area?
        jr      nz,pophl        ; No - Return
        ld      b,a             ; Clear B (A=0)
        add     hl,bc           ; Remove string from str' area
        ld      (strbot),hl     ; Save new bottom of str' area
pophl   pop     hl              ; Restore string
        ret

baktmp  ld      hl,(tmstpt)     ; Get temporary string pool top
        dec     hl              ; Back
        ld      b,(hl)          ; Get MSB of address
        dec     hl              ; Back
        ld      c,(hl)          ; Get LSB of address
        dec     hl              ; Back
        dec     hl              ; Back
        call    cphlde          ; String last in string pool?
        ret     nz              ; Yes - Leave it
        ld      (tmstpt),hl     ; Save new string pool top
        ret
;------------------------------------------------------------------------------
; LEN string length
;------------------------------------------------------------------------------
len:    ld      bc,passa        ; To return integer A
        push    bc              ; Save address
getlen: call    getstr          ; Get string and its length
        xor     a
        ld      d,a             ; Clear D
        ld      (type),a        ; Set type to numeric
        ld      a,(hl)          ; Get length of string
        or      a               ; Set status flags
        ret
;------------------------------------------------------------------------------
; ASC string value
;------------------------------------------------------------------------------
asc:    ld      bc,passa        ; To return integer A
        push    bc              ; Save address
gtflnm: call    getlen          ; Get length of string
        jp      z,fcerr         ; Null string - Error
        inc     hl
        inc     hl
        ld      e,(hl)          ; Get LSB of address
        inc     hl
        ld      d,(hl)          ; Get MSB of address
        ld      a,(de)          ; Get first byte of string
        ret
;------------------------------------------------------------------------------
; CHR
;------------------------------------------------------------------------------
chr:    ld      a,1             ; One character string
        call    mktmst          ; Make a temporary string
        call    makint          ; Make it integer A
        ld      hl,(tmpstr+2)   ; Get address of string
        ld      (hl),e          ; Save character
topool: pop     bc              ; Clean up stack
        jp      tstopl          ; Temporary string to pool
;------------------------------------------------------------------------------
; LEFT$
;------------------------------------------------------------------------------
left:   call    lfrgnm          ; Get number and ending ")"
        xor     a               ; Start at first byte in string
;------------------------------------------------------------------------------
; RIGHT$
;------------------------------------------------------------------------------
right1: ex      (sp),hl         ; Save code string,Get string
        ld      c,a             ; Starting position in string
;------------------------------------------------------------------------------
; MID$
;------------------------------------------------------------------------------        
mid1:   push    hl              ; Save string block address
        ld      a,(hl)          ; Get length of string
        cp      b               ; Compare with number given
        jr      c,allfol        ; All following bytes required
        ld      a,b             ; Get new length
        defb    11h             ; Skip "LD C,0"
allfol: ld      c,0             ; First byte of string
        push    bc              ; Save position in string
        call    testr           ; See if enough string space
        pop     bc              ; Get position in string
        pop     hl              ; Restore string block address
        push    hl              ; And re-save it
        inc     hl
        inc     hl
        ld      b,(hl)          ; Get LSB of address
        inc     hl
        ld      h,(hl)          ; Get MSB of address
        ld      l,b             ; HL = address of string
        ld      b,0             ; BC = starting address
        add     hl,bc           ; Point to that byte
        ld      b,h             ; BC = source string
        ld      c,l
        call    crtmst          ; Create a string entry
        ld      l,a             ; Length of new string
        call    tostra          ; Move string to string area
        pop     de              ; Clear stack
        call    gstrde          ; Move to string pool if needed
        jp      tstopl          ; Temporary string to pool

right:  call    lfrgnm          ; Get number and ending ")"
        pop     de              ; Get string length
        push    de              ; And re-save
        ld      a,(de)          ; Get length
        sub     b               ; Move back N bytes
        jr      right1          ; Go and get sub-string

mid:    ex      de,hl           ; Get code string address
        ld      a,(hl)          ; Get next byte "," or ")"
        call    midnum          ; Get number supplied
        inc     b               ; Is it character zero?
        dec     b
        jp      z,fcerr         ; Yes - Error
        push    bc              ; Save starting position
        ld      e,255           ; All of string
        cp      ')'             ; Any length given?
        jr      z,rststr        ; No - Rest of string
        call    chksyn          ; Make sure "," follows
        defb   ','
        call    getint          ; Get integer 0-255
rststr: call    chksyn          ; Make sure ")" follows
        defb   ')'
        pop     af              ; Restore starting position
        ex      (sp),hl         ; Get string,8ave code string
        ld      bc,mid1         ; Continuation of MID$ routine
        push    bc              ; Save for return
        dec     a               ; Starting position-1
        cp      (hl)            ; Compare with length
        ld      b,0             ; Zero bytes length
        ret     nc              ; Null string if start past end
        ld      c,a             ; Save starting position-1
        ld      a,(hl)          ; Get length of string
        sub     c               ; Subtract start
        cp      e               ; Enough string for it?
        ld      b,a             ; Save maximum length available
        ret     c               ; Truncate string if needed
        ld      b,e             ; Set specified length
        ret                     ; Go and create string
;------------------------------------------------------------------------------
; VAL
;------------------------------------------------------------------------------
val:    call    getlen          ; Get length of string
        jp      z,reszer        ; Result zero
        ld      e,a             ; Save length
        inc     hl
        inc     hl
        ld      a,(hl)          ; Get LSB of address
        inc     hl
        ld      h,(hl)          ; Get MSB of address
        ld      l,a             ; HL = String address
        push    hl              ; Save string address
        add     hl,de
        ld      b,(hl)          ; Get end of string+1 byte
        ld      (hl),d          ; Zero it to terminate
        ex      (sp),hl         ; Save string end,get start
        push    bc              ; Save end+1 byte
        ld      a,(hl)          ; Get starting byte
        call    asctfp          ; Convert ASCII string to FP
        pop     bc              ; Restore end+1 byte
        pop     hl              ; Restore end+1 address
        ld      (hl),b          ; Put back original byte
        ret

lfrgnm: ex      de,hl           ; Code string address to HL
        call    chksyn          ; Make sure ")" follows
        defb     ")"
midnum: pop     bc              ; Get return address
        pop     de              ; Get number supplied
        push    bc              ; Re-save return address
        ld      b,e             ; Number to B
        ret
;------------------------------------------------------------------------------
; INPUT
;------------------------------------------------------------------------------
inp:    call    makint          ; Make it integer A
        ld      (inport),a      ; Set input port
        call    inpsub          ; Get input from port
        jp      passa           ; Return integer A
;------------------------------------------------------------------------------
; OUTPUT
;------------------------------------------------------------------------------
pout:   call    setio           ; Set up port number
        jp      outsub          ; Output data and return
;------------------------------------------------------------------------------
; WAIT
;------------------------------------------------------------------------------
wait:   call    setio           ; Set up port number
        push    af              ; Save AND mask
        ld      e,0             ; Assume zero if none given
        dec     hl              ; DEC 'cos GETCHR INCs
        call    getchr          ; Get next character
        jr      z,noxor         ; No XOR byte given
        call    chksyn          ; Make sure "," follows
        defb  	 ','
        call    getint          ; Get integer 0-255 to XOR with
noxor:  pop     bc              ; Restore AND mask
waitlp: call    inpsub          ; Get input
        xor     e               ; Flip selected bits
        and     b               ; Result non-zero?
        jr      z,waitlp        ; No = keep waiting
        ret
;------------------------------------------------------------------------------
; Process INP and OUT
;------------------------------------------------------------------------------
setio:  call    getint          ; Get integer 0-255
        ld      (inport),a      ; Set input port
        ld      (otport),a      ; Set output port
        call    chksyn          ; Make sure "," follows
        defb    ','
        jp      getint          ; Get integer 0-255 and return

fndnum: call    getchr          ; Get next character
getint: call    getnum          ; Get a number from 0 to 255
makint: call    depint          ; Make sure value 0 - 255
        ld      a,d             ; Get MSB of number
        or      a               ; Zero?
        jp      nz,fcerr        ; No - Error
        dec     hl              ; DEC 'cos GETCHR INCs
        call    getchr          ; Get next character
        ld      a,e             ; Get number to A
        ret
;------------------------------------------------------------------------------
; PEEK
;------------------------------------------------------------------------------
peek:   call    deint           ; Get memory address
        ld      a,(de)          ; Get byte in memory
        jp      passa           ; Return integer A
;------------------------------------------------------------------------------
; POKE
;------------------------------------------------------------------------------
poke:   call    getnum          ; Get memory address
        call    deint           ; Get integer -32768 to 3276
        push    de              ; Save memory address
        call    chksyn          ; Make sure "," follows
        defb   ','
        call    getint          ; Get integer 0-255
        pop     de              ; Restore memory address
        ld      (de),a          ; Load it into memory
        ret
;------------------------------------------------------------------------------
; HEX( [Will replace DEEK] Convert 16 bit number to Hexadecimal string
;------------------------------------------------------------------------------
hex     call	tstnum		; Verify it's a number
	call    deint           ; Get integer -32768 to 32767
        push	hl		; Save code string address
	push	bc		; Save contents of BC
	ld	hl,pbuff
	ld	(hl),'$'	; Store "$" to start of conv buffer
	inc	hl		; Index next
	ld	a,d		; Get high order into A
	call	byt2asc		; Convert D to ASCII
	ld	(hl),b		; Store it to PBUFF+1
	inc	hl		; Next location
	ld	(hl),c		; Store C to PBUFF+2
	ld	a,e		; Get lower byte
	call	byt2asc		; Convert E to ASCII
	inc	hl		; Save B
	ld	(hl),b		;  to PBUFF+3
	inc	hl		; Save C
	ld	(hl),c		;  to PBUFF+4
	ld	a,$20		; Create a <spc> after the number
	inc	hl		; Index next
	ld	(hl),a		; PBUFF+5 to space
	xor	a		; Terminating character
	inc	hl		; PBUFF+6 to zero
	ld	(hl),a		; Store zero to terminate
	inc	hl		; Make sure PBUFF is terminated
	ld	(hl),a		; Store the double zero there
	pop	bc		; Get BC back
	pop	hl		; Retrieve code string
	jp	str1		; Convert the PBUFF to a string and return it
;------------------------------------------------------------------------------
; Convert byte in A to ASCII in BC, same as routine in Monitor at $0326
;------------------------------------------------------------------------------
byt2asc	ld	b,a		; Save original value
	and	$0f		; Strip off upper nybble
	cp	$0a		; 0-9?
	jr	c,add30		; If A-F, add 7 more
	add	a,$07		; Bring value up to ASCII A-F
add30	add	a,$30		; And make ASCII
	ld	c,a		; Save converted char to C
	ld	a,b		; Retrieve original value
	rrca			; and Rotate it right
	rrca
	rrca
	rrca
	and	$0f		; Mask off upper nybble
	cp	$0a		; 0-9? < A hex?
	jr	c,add301	; Skip Add 7
	add	a,$07		; Bring it up to ASCII A-F
add301	add	a,$30		; And make it full ASCII
	ld	b,a		; Store high order byte
	ret	
;------------------------------------------------------------------------------
; VECTOR Set address for USR jump vector [formerly DOKE]
;------------------------------------------------------------------------------
vector	call	getnum		; Get a number
	call	deint		; Get integer into DE
	ld	(usr+1),de	; Store vector at USR vector
	ret
;------------------------------------------------------------------------------
; WIDTH
;------------------------------------------------------------------------------
width:  call    getint          ; Get integer 0-255
        ld      a,e             ; Width to A
        ld      (lwidth),a      ; Set width
        ret
;------------------------------------------------------------------------------
; LINES
;------------------------------------------------------------------------------
lines:  call    getnum          ; Get a number
        call    deint           ; Get integer -32768 to 32767
        ld      (linesc),de     ; Set lines counter
        ld      (linesn),de     ; Set lines number
        ret
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
; 
; Start of   F L O A T I N G   P O I N T   M A T H
;
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
round:  ld      hl,half         ; Add 0.5 to FPREG
addphl: call    loadfp          ; Load FP at (HL) to BCDE
        jr      fpadd           ; Add BCDE to FPREG

subphl: call    loadfp          ; FPREG = -FPREG + number at HL
        defb    21h             ; Skip "POP BC" and "POP DE"
psub:   pop     bc              ; Get FP number from stack
        pop     de
subcde: call    invsgn          ; Negate FPREG
fpadd:  ld      a,b             ; Get FP exponent
        or      a               ; Is number zero?
        ret     z               ; Yes - Nothing to add
        ld      a,(fpexp)       ; Get FPREG exponent
        or      a               ; Is this number zero?
        jp      z,fpbcde        ; Yes - Move BCDE to FPREG
        sub     b               ; BCDE number larger?
        jr      nc,noswap       ; No - Don't swap them
        cpl                     ; Two's complement
        inc     a               ;  FP exponent
        ex      de,hl
        call    stakfp          ; Put FPREG on stack
        ex      de,hl
        call    fpbcde          ; Move BCDE to FPREG
        pop     bc              ; Restore number from stack
        pop     de
noswap: cp      24+1            ; Second number insignificant?
        ret     nc              ; Yes - First number is result
        push    af              ; Save number of bits to scale
        call    signs           ; Set MSBs & sign of result
        ld      h,a             ; Save sign of result
        pop     af              ; Restore scaling factor
        call    scale           ; Scale BCDE to same exponent
        or      h               ; Result to be positive?
        ld      hl,fpreg        ; Point to FPREG
        jp      p,mincde        ; No - Subtract FPREG from CDE
        call    plucde          ; Add FPREG to CDE
        jp      nc,rondup       ; No overflow - Round it up
        inc     hl              ; Point to exponent
        inc     (hl)            ; Increment it
        jp      z,overr         ; Number overflowed - Error
        ld      l,1             ; 1 bit to shift right
        call    shrt1           ; Shift result right
        jp      rondup          ; Round it up

mincde: xor     a               ; Clear A and carry
        sub     b               ; Negate exponent
        ld      b,a             ; Re-save exponent
        ld      a,(hl)          ; Get LSB of FPREG
        sbc     a, e            ; Subtract LSB of BCDE
        ld      e,a             ; Save LSB of BCDE
        inc     hl
        ld      a,(hl)          ; Get NMSB of FPREG
        sbc     a,d             ; Subtract NMSB of BCDE
        ld      d,a             ; Save NMSB of BCDE
        inc     hl
        ld      a,(hl)          ; Get MSB of FPREG
        sbc     a,c             ; Subtract MSB of BCDE
        ld      c,a             ; Save MSB of BCDE
conpos: call    c,compl         ; Overflow - Make it positive

bnorm:  ld      l,b             ; L = Exponent
        ld      h,e             ; H = LSB
        xor     a
bnrmlp: ld      b,a             ; Save bit count
        ld      a,c             ; Get MSB
        or      a               ; Is it zero?
        jr      nz,pnorm        ; No - Do it bit at a time
        ld      c,d             ; MSB = NMSB
        ld      d,h             ; NMSB= LSB
        ld      h,l             ; LSB = VLSB
        ld      l,a             ; VLSB= 0
        ld      a,b             ; Get exponent
        sub     8               ; Count 8 bits
        cp      -24-8           ; Was number zero?
        jr      nz,bnrmlp       ; No - Keep normalising
reszer: xor     a               ; Result is zero
savexp: ld      (fpexp),a       ; Save result as zero
        ret

normal: dec     b               ; Count bits
        add     hl,hl           ; Shift HL left
        ld      a,d             ; Get NMSB
        rla                     ; Shift left with last bit
        ld      d,a             ; Save NMSB
        ld      a,c             ; Get MSB
        adc     a,a             ; Shift left with last bit
        ld      c,a             ; Save MSB
pnorm:  jp      p,normal        ; Not done - Keep going
        ld      a,b             ; Number of bits shifted
        ld      e,h             ; Save HL in EB
        ld      b,l
        or      a               ; Any shifting done?
        jp      z,rondup        ; No - Round it up
        ld      hl,fpexp        ; Point to exponent
        add     a,(hl)          ; Add shifted bits
        ld      (hl),a          ; Re-save exponent
        jr      nc,reszer       ; Underflow - Result is zero
        ret     z               ; Result is zero
rondup: ld      a,b             ; Get VLSB of number
rondb:  ld      hl,fpexp        ; Point to exponent
        or      a               ; Any rounding?
        call    m,fprond        ; Yes - Round number up
        ld      b,(hl)          ; B = Exponent
        inc     hl
        ld      a,(hl)          ; Get sign of result
        and     10000000b       ; Only bit 7 needed
        xor     c               ; Set correct sign
        ld      c,a             ; Save correct sign in number
        jp      fpbcde          ; Move BCDE to FPREG

fprond: inc     e               ; Round LSB
        ret     nz              ; Return if ok
        inc     d               ; Round NMSB
        ret     nz              ; Return if ok
        inc     c               ; Round MSB
        ret     nz              ; Return if ok
        ld      c,80h           ; Set normal value
        inc     (hl)            ; Increment exponent
        ret     nz              ; Return if ok
        jp      overr           ; Overflow error
;------------------------------------------------------------------------------
; ADD FPREG AT (HL) TO BCDE
;------------------------------------------------------------------------------
plucde: ld      a,(hl)          ; Get LSB of FPREG
        add     a,e             ; Add LSB of BCDE
        ld      e,a             ; Save LSB of BCDE
        inc     hl
        ld      a,(hl)          ; Get NMSB of FPREG
        adc     a,d             ; Add NMSB of BCDE
        ld      d,a             ; Save NMSB of BCDE
        inc     hl
        ld      a,(hl)          ; Get MSB of FPREG
        adc     a,c             ; Add MSB of BCDE
        ld      c,a             ; Save MSB of BCDE
        ret
;------------------------------------------------------------------------------
; Compliment FP number in BCDE
;------------------------------------------------------------------------------
compl:  ld      hl,sgnres       ; Sign of result
        ld      a,(hl)          ; Get sign of result
        cpl                     ; Negate it
        ld      (hl),a          ; Put it back
        xor     a
        ld      l,a             ; Set L to zero
        sub     b               ; Negate exponent,set carry
        ld      b,a             ; Re-save exponent
        ld      a,l             ; Load zero
        sbc     a,e             ; Negate LSB
        ld      e,a             ; Re-save LSB
        ld      a,l             ; Load zero
        sbc     a,d             ; Negate NMSB
        ld      d,a             ; Re-save NMSB
        ld      a,l             ; Load zero
        sbc     a,c             ; Negate MSB
        ld      c,a             ; Re-save MSB
        ret
;------------------------------------------------------------------------------
; Rescales BCDE 
;------------------------------------------------------------------------------
scale:  ld      b,0             ; Clear underflow
scallp: sub     8               ; 8 bits (a whole byte)?
        jr      c,shrite        ; No - Shift right A bits
        ld      b,e             ; <- Shift
        ld      e,d             ; <- right
        ld      d,c             ; <- eight
        ld      c,0             ; <- bits
        jr      scallp          ; More bits to shift

shrite: add     a,8+1           ; Adjust count
        ld      l,a             ; Save bits to shift
shrlp:  xor     a               ; Flag for all done
        dec     l               ; All shifting done?
        ret     z               ; Yes - Return
        ld      a,c             ; Get MSB
shrt1:  rra                     ; Shift it right
        ld      c,a             ; Re-save
        ld      a,d             ; Get NMSB
        rra                     ; Shift right with last bit
        ld      d,a             ; Re-save it
        ld      a,e             ; Get LSB
        rra                     ; Shift right with last bit
        ld      e,a             ; Re-save it
        ld      a,b             ; Get underflow
        rra                     ; Shift right with last bit
        ld      b,a             ; Re-save underflow
        jr      shrlp           ; More bits to do

unity	defb   $00,$00,$00,$81 ; 1.00000

logtab  defb   3               ; TABLE USED BY LOG
        defb   $aa,$56,$19,$80 ; 0.59898
        defb   $f1,$22,$76,$80 ; 0.96147
        defb   $45,$aa,$38,$82 ; 2.88539
;------------------------------------------------------------------------------
; LOG
;------------------------------------------------------------------------------
log:    call    tstsgn          ; Test sign of value
        or      a
        jp      pe,fcerr        ; ?FC Error if <= zero
        ld      hl,fpexp        ; Point to exponent
        ld      a,(hl)          ; Get exponent
        ld      bc,8035h        ; BCDE = SQR(1/2)
        ld      de,04f3h
        sub     b               ; Scale value to be < 1
        push    af              ; Save scale factor
        ld      (hl),b          ; Save new exponent
        push    de              ; Save SQR(1/2)
        push    bc
        call    fpadd           ; Add SQR(1/2) to value
        pop     bc              ; Restore SQR(1/2)
        pop     de
        inc     b               ; Make it SQR(2)
        call    dvbcde          ; Divide by SQR(2)
        ld      hl,unity        ; Point to 1.
        call    subphl          ; Subtract FPREG from 1
        ld      hl,logtab       ; Coefficient table
        call    sumser          ; Evaluate sum of series
        ld      bc,8080h        ; BCDE = -0.5
        ld      de,0000h
        call    fpadd           ; Subtract 0.5 from FPREG
        pop     af              ; Restore scale factor
        call    rscale          ; Re-scale number
mulln2: ld      bc,8031h        ; BCDE = Ln(2)
        ld      de,7218h
        defb     21h             ; Skip "POP BC" and "POP DE"
;------------------------------------------------------------------------------
; FLOATING POINT MULTIPLY
;------------------------------------------------------------------------------
mult:   pop     bc              ; Get number from stack
        pop     de
fpmult: call    tstsgn          ; Test sign of FPREG
        ret     z               ; Return zero if zero
        ld      l,0             ; Flag add exponents
        call    addexp          ; Add exponents
        ld      a,c             ; Get MSB of multiplier
        ld      (mulval),a      ; Save MSB of multiplier
        ex      de,hl
        ld      (mulval+1),hl   ; Save rest of multiplier
        ld      bc,0            ; Partial product (BCDE) = zero
        ld      d,b
        ld      e,b
        ld      hl,bnorm        ; Address of normalise
        push    hl              ; Save for return
        ld      hl,mult8        ; Address of 8 bit multiply
        push    hl              ; Save for NMSB,MSB
        push    hl              ; 
        ld      hl,fpreg        ; Point to number
mult8:  ld      a,(hl)          ; Get LSB of number
        inc     hl              ; Point to NMSB
        or      a               ; Test LSB
        jp      z,bytsft        ; Zero - shift to next byte
        push    hl              ; Save address of number
        ld      l,8             ; 8 bits to multiply by
mul8lp: rra                     ; Shift LSB right
        ld      h,a             ; Save LSB
        ld      a,c             ; Get MSB
        jr      nc,nomadd       ; Bit was zero - Don't add
        push    hl              ; Save LSB and count
        ld      hl,(mulval+1)   ; Get LSB and NMSB
        add     hl,de           ; Add NMSB and LSB
        ex      de,hl           ; Leave sum in DE
        pop     hl              ; Restore MSB and count
        ld      a,(mulval)      ; Get MSB of multiplier
        adc     a,c             ; Add MSB
nomadd: rra                     ; Shift MSB right
        ld      c,a             ; Re-save MSB
        ld      a,d             ; Get NMSB
        rra                     ; Shift NMSB right
        ld      d,a             ; Re-save NMSB
        ld      a,e             ; Get LSB
        rra                     ; Shift LSB right
        ld      e,a             ; Re-save LSB
        ld      a,b             ; Get VLSB
        rra                     ; Shift VLSB right
        ld      b,a             ; Re-save VLSB
        dec     l               ; Count bits multiplied
        ld      a,h             ; Get LSB of multiplier
        jr      nz,mul8lp       ; More - Do it
pophrt: pop     hl              ; Restore address of number
        ret

bytsft: ld      b,e             ; Shift partial product left
        ld      e,d
        ld      d,c
        ld      c,a
        ret

div10:  call    stakfp          ; Save FPREG on stack
        ld      bc,8420h        ; BCDE = 10.
        ld      de,0000h
        call    fpbcde          ; Move 10 to FPREG
;------------------------------------------------------------------------------
; Division  FPREG = (last) / FPREG
;------------------------------------------------------------------------------
div:    pop     bc              ; Get number from stack
        pop     de
dvbcde: call    tstsgn          ; Test sign of FPREG
        jp      z,dzerr         ; Error if division by zero
        ld      l,-1            ; Flag subtract exponents
        call    addexp          ; Subtract exponents
        inc     (hl)            ; Add 2 to exponent to adjust
        inc     (hl)
        dec     hl              ; Point to MSB
        ld      a,(hl)          ; Get MSB of dividend
        ld      (div3),a        ; Save for subtraction
        dec     hl
        ld      a,(hl)          ; Get NMSB of dividend
        ld      (div2),a        ; Save for subtraction
        dec     hl
        ld      a,(hl)          ; Get MSB of dividend
        ld      (div1),a        ; Save for subtraction
        ld      b,c             ; Get MSB
        ex      de,hl           ; NMSB,LSB to HL
        xor     a
        ld      c,a             ; Clear MSB of quotient
        ld      d,a             ; Clear NMSB of quotient
        ld      e,a             ; Clear LSB of quotient
        ld      (div4),a        ; Clear overflow count
divlp:  push    hl              ; Save divisor
        push    bc
        ld      a,l             ; Get LSB of number
        call    divsup          ; Subt' divisor from dividend
        sbc     a,0             ; Count for overflows
        ccf
        jr      nc,resdiv       ; Restore divisor if borrow
        ld      (div4),a        ; Re-save overflow count
        pop     af              ; Scrap divisor
        pop     af
        scf                     ; Set carry to
        defb    0d2h            ; Skip "POP BC" and "POP HL"

resdiv: pop     bc              ; Restore divisor
        pop     hl
        ld      a,c             ; Get MSB of quotient
        inc     a
        dec     a
        rra                     ; Bit 0 to bit 7
        jp      m,rondb         ; Done - Normalise result
        rla                     ; Restore carry
        ld      a,e             ; Get LSB of quotient
        rla                     ; Double it
        ld      e,a             ; Put it back
        ld      a,d             ; Get NMSB of quotient
        rla                     ; Double it
        ld      d,a             ; Put it back
        ld      a,c             ; Get MSB of quotient
        rla                     ; Double it
        ld      c,a             ; Put it back
        add     hl,hl           ; Double NMSB,LSB of divisor
        ld      a,b             ; Get MSB of divisor
        rla                     ; Double it
        ld      b,a             ; Put it back
        ld      a,(div4)        ; Get VLSB of quotient
        rla                     ; Double it
        ld      (div4),a        ; Put it back
        ld      a,c             ; Get MSB of quotient
        or      d               ; Merge NMSB
        or      e               ; Merge LSB
        jp      nz,divlp        ; Not done - Keep dividing
        push    hl              ; Save divisor
        ld      hl,fpexp        ; Point to exponent
        dec     (hl)            ; Divide by 2
        pop     hl              ; Restore divisor
        jp      nz,divlp        ; Ok - Keep going
        jp      overr           ; Overflow error

addexp: ld      a,b             ; Get exponent of dividend
        or      a               ; Test it
        jr      z,ovtst3        ; Zero - Result zero
        ld      a,l             ; Get add/subtract flag
        ld      hl,fpexp        ; Point to exponent
        xor     (hl)            ; Add or subtract it
        add     a,b             ; Add the other exponent
        ld      b,a             ; Save new exponent
        rra                     ; Test exponent for overflow
        xor     b
        ld      a,b             ; Get exponent
        jp      p,ovtst2        ; Positive - Test for overflow
        add     a,80h           ; Add excess 128
        ld      (hl),a          ; Save new exponent
        jp      z,pophrt        ; Zero - Result zero
        call    signs           ; Set MSBs and sign of result
        ld      (hl),a          ; Save new exponent
        dec     hl              ; Point to MSB
        ret

ovtst1: call    tstsgn          ; Test sign of FPREG
        cpl                     ; Invert sign
        pop     hl              ; Clean up stack
ovtst2: or      a               ; Test if new exponent zero
ovtst3: pop     hl              ; Clear off return address
        jp      p,reszer        ; Result zero
        jp      overr           ; Overflow error

mlsp10: call    bcdefp          ; Move FPREG to BCDE
        ld      a,b             ; Get exponent
        or      a               ; Is it zero?
        ret     z               ; Yes - Result is zero
        add     a,2             ; Multiply by 4
        jp      c,overr         ; Overflow - ?OV Error
        ld      b,a             ; Re-save exponent
        call    fpadd           ; Add BCDE to FPREG (Times 5)
        ld      hl,fpexp        ; Point to exponent
        inc     (hl)            ; Double number (Times 10)
        ret     nz              ; Ok - Return
        jp      overr           ; Overflow error

tstsgn: ld      a,(fpexp)       ; Get sign of FPREG
        or      a
        ret     z               ; RETurn if number is zero
        ld      a,(fpreg+2)     ; Get MSB of FPREG
        defb     0feh            ; Test sign
retrel: cpl                     ; Invert sign
        rla                     ; Sign bit to carry
flgdif: sbc     a,a             ; Carry to all bits of A
        ret     nz              ; Return -1 if negative
        inc     a               ; Bump to +1
        ret                     ; Positive - Return +1
;------------------------------------------------------------------------------
; SGN
;------------------------------------------------------------------------------
sgn:    call    tstsgn          ; Test sign of FPREG
flgrel: ld      b,80h+8         ; 8 bit integer in exponent
        ld      de,0            ; Zero NMSB and LSB
retint: ld      hl,fpexp        ; Point to exponent
        ld      c,a             ; CDE = MSB,NMSB and LSB
        ld      (hl),b          ; Save exponent
        ld      b,0             ; CDE = integer to normalise
        inc     hl              ; Point to sign of result
        ld      (hl),80h        ; Set sign of result
        rla                     ; Carry = sign of integer
        jp      conpos          ; Set sign of result
;------------------------------------------------------------------------------
; ABS
;------------------------------------------------------------------------------
abs:    call    tstsgn          ; Test sign of FPREG
        ret     p               ; Return if positive
invsgn: ld      hl,fpreg+2      ; Point to MSB
        ld      a,(hl)          ; Get sign of mantissa
        xor     80h             ; Invert sign of mantissa
        ld      (hl),a          ; Re-save sign of mantissa
        ret
;------------------------------------------------------------------------------
; Saves FPREG to stack
;------------------------------------------------------------------------------
stakfp: ex      de,hl           ; Save code string address
        ld      hl,(fpreg)      ; LSB,NLSB of FPREG
        ex      (sp),hl         ; Stack them,get return
        push    hl              ; Re-save return
        ld      hl,(fpreg+2)    ; MSB and exponent of FPREG
        ex      (sp),hl         ; Stack them,get return
        push    hl              ; Re-save return
        ex      de,hl           ; Restore code string address
        ret
;------------------------------------------------------------------------------
; Loads BCDE to FPREG
;------------------------------------------------------------------------------
phltfp: call    loadfp          ; Number at HL to BCDE
fpbcde: ex      de,hl           ; Save code string address
        ld      (fpreg),hl      ; Save LSB,NLSB of number
        ld      h,b             ; Exponent of number
        ld      l,c             ; MSB of number
        ld      (fpreg+2),hl    ; Save MSB and exponent
        ex      de,hl           ; Restore code string address
        ret
;------------------------------------------------------------------------------
; Loads BCDE from FPREG
;------------------------------------------------------------------------------
bcdefp: ld      hl,fpreg        ; Point to FPREG
loadfp: ld      e,(hl)          ; Get LSB of number
        inc     hl
        ld      d,(hl)          ; Get NMSB of number
        inc     hl
        ld      c,(hl)          ; Get MSB of number
        inc     hl
        ld      b,(hl)          ; Get exponent of number
inchl:  inc     hl              ; Used for conditional "INC HL"
        ret
;------------------------------------------------------------------------------
; Moves FPREG to (HL)
;------------------------------------------------------------------------------
fpthl:  ld      de,fpreg        ; Point to FPREG
dethl4: ld      b,4             ; 4 bytes to move
dethlb: ld      a,(de)          ; Get source
        ld      (hl),a          ; Save destination
        inc     de              ; Next source
        inc     hl              ; Next destination
        dec     b               ; Count bytes
        jr      nz,dethlb       ; Loop if more
        ret
;------------------------------------------------------------------------------
signs:  ld      hl,fpreg+2      ; Point to MSB of FPREG
        ld      a,(hl)          ; Get MSB
        rlca                    ; Old sign to carry
        scf                     ; Set MSBit
        rra                     ; Set MSBit of MSB
        ld      (hl),a          ; Save new MSB
        ccf                     ; Complement sign
        rra                     ; Old sign to carry
        inc     hl
        inc     hl
        ld      (hl),a          ; Set sign of result
        ld      a,c             ; Get MSB
        rlca                    ; Old sign to carry
        scf                     ; Set MSBit
        rra                     ; Set MSBit of MSB
        ld      c,a             ; Save MSB
        rra
        xor     (hl)            ; New sign of result
        ret
;------------------------------------------------------------------------------
; Compare two FP numbers BCDE and FPREG with exponents
;------------------------------------------------------------------------------
cmpnum: ld      a,b             ; Get exponent of number
        or      a
        jp      z,tstsgn        ; Zero - Test sign of FPREG
        ld      hl,retrel       ; Return relation routine
        push    hl              ; Save for return
        call    tstsgn          ; Test sign of FPREG
        ld      a,c             ; Get MSB of number
        ret     z               ; FPREG zero - Number's MSB
        ld      hl,fpreg+2      ; MSB of FPREG
        xor     (hl)            ; Combine signs
        ld      a,c             ; Get MSB of number
        ret     m               ; Exit if signs different
        call    cmpfp           ; Compare FP numbers
        rra                     ; Get carry to sign
        xor     c               ; Combine with MSB of number
        ret
;------------------------------------------------------------------------------
; Compare BCDE - FPREG, setting Z flag if =
;------------------------------------------------------------------------------
cmpfp:  inc     hl              ; Point to exponent
        ld      a,b             ; Get exponent
        cp      (hl)            ; Compare exponents
        ret     nz              ; Different
        dec     hl              ; Point to MBS
        ld      a,c             ; Get MSB
        cp      (hl)            ; Compare MSBs
        ret     nz              ; Different
        dec     hl              ; Point to NMSB
        ld      a,d             ; Get NMSB
        cp      (hl)            ; Compare NMSBs
        ret     nz              ; Different
        dec     hl              ; Point to LSB
        ld      a,e             ; Get LSB
        sub     (hl)            ; Compare LSBs
        ret     nz              ; Different
        pop     hl              ; Drop RETurn
        pop     hl              ; Drop another RETurn
        ret
;------------------------------------------------------------------------------
; Convert FPREG to FPREG 24 Bit Integer format
;------------------------------------------------------------------------------
fpint:  ld      b,a             ; <- Move
        ld      c,a             ; <- exponent
        ld      d,a             ; <- to all
        ld      e,a             ; <- bits
        or      a               ; Test exponent
        ret     z               ; Zero - Return zero
        push    hl              ; Save pointer to number
        call    bcdefp          ; Move FPREG to BCDE
        call    signs           ; Set MSBs & sign of result
        xor     (hl)            ; Combine with sign of FPREG
        ld      h,a             ; Save combined signs
        call    m,dcbcde        ; Negative - Decrement BCDE
        ld      a,80h+24        ; 24 bits
        sub     b               ; Bits to shift
        call    scale           ; Shift BCDE
        ld      a,h             ; Get combined sign
        rla                     ; Sign to carry
        call    c,fprond        ; Negative - Round number up
        ld      b,0             ; Zero exponent
        call    c,compl         ; If negative make positive
        pop     hl              ; Restore pointer to number
        ret
;------------------------------------------------------------------------------
; Decrement BCDE number
;------------------------------------------------------------------------------
dcbcde: dec     de              ; Decrement BCDE
        ld      a,d             ; Test LSBs
        and     e
        inc     a
        ret     nz              ; Exit if LSBs not FFFF
        dec     bc              ; Decrement MSBs
        ret
;------------------------------------------------------------------------------
; INT
;------------------------------------------------------------------------------
int:    ld      hl,fpexp        ; Point to exponent
        ld      a,(hl)          ; Get exponent
        cp      80h+24          ; Integer accuracy only?
        ld      a,(fpreg)       ; Get LSB
        ret     nc              ; Yes - Already integer
        ld      a,(hl)          ; Get exponent
        call    fpint           ; F.P to integer
        ld      (hl),80h+24     ; Save 24 bit integer
        ld      a,e             ; Get LSB of number
        push    af              ; Save LSB
        ld      a,c             ; Get MSB of number
        rla                     ; Sign to carry
        call    conpos          ; Set sign of result
        pop     af              ; Restore LSB of number
        ret

mldebc: ld      hl,0            ; Clear partial product
        ld      a,b             ; Test multiplier
        or      c
        ret     z               ; Return zero if zero
        ld      a,16            ; 16 bits
mldblp: add     hl,hl           ; Shift P.P left
        jp      c,bserr         ; ?BS Error if overflow
        ex      de,hl
        add     hl,hl           ; Shift multiplier left
        ex      de,hl
        jr      nc,nomlad       ; Bit was zero - No add
        add     hl,bc           ; Add multiplicand
        jp      c,bserr         ; ?BS Error if overflow
nomlad: dec     a               ; Count bits
        jr      nz,mldblp       ; More
        ret
;------------------------------------------------------------------------------
; Converts ASCII number to FP for computations
;------------------------------------------------------------------------------
asctfp: cp      '-'             ; Negative?
        push    af              ; Save it and flags
        jp      z,cnvnum        ; Yes - Convert number
        cp      '+'             ; Positive?
        jr      z,cnvnum        ; Yes - Convert number
        dec     hl              ; DEC 'cos GETCHR INCs
cnvnum: call    reszer          ; Set result to zero
        ld      b,a             ; Digits after point counter
        ld      d,a             ; Sign of exponent
        ld      e,a             ; Exponent of ten
        cpl
        ld      c,a             ; Before or after point flag
manlp:  call    getchr          ; Get next character
        jr      c,addig         ; Digit - Add to number
        cp      '.'
        jr      z,dpoint        ; "." - Flag point
        cp      'E'
        jr      nz,conexp       ; Not "E" - Scale number
        call    getchr          ; Get next character
        call    sgnexp          ; Get sign of exponent
explp:  call    getchr          ; Get next character
        jr      c,edigit        ; Digit - Add to exponent
        inc     d               ; Is sign negative?
        jr      nz,conexp       ; No - Scale number
        xor     a
        sub     e               ; Negate exponent
        ld      e,a             ; And re-save it
        inc     c               ; Flag end of number
dpoint: inc     c               ; Flag point passed
        jr      z,manlp         ; Zero - Get another digit
conexp: push    hl              ; Save code string address
        ld      a,e             ; Get exponent
        sub     b               ; Subtract digits after point
scalmi: call    p,scalpl        ; Positive - Multiply number
        jp      p,endcon        ; Positive - All done
        push    af              ; Save number of times to /10
        call    div10           ; Divide by 10
        pop     af              ; Restore count
        inc     a               ; Count divides

endcon: jr      nz,scalmi       ; More to do
        pop     de              ; Restore code string address
        pop     af              ; Restore sign of number
        call    z,invsgn        ; Negative - Negate number
        ex      de,hl           ; Code string address to HL
        ret

scalpl: ret     z               ; Exit if no scaling needed
multen: push    af              ; Save count
        call    mlsp10          ; Multiply number by 10
        pop     af              ; Restore count
        dec     a               ; Count multiplies
        ret

addig:  push    de              ; Save sign of exponent
        ld      d,a             ; Save digit
        ld      a,b             ; Get digits after point
        adc     a,c             ; Add one if after point
        ld      b,a             ; Re-save counter
        push    bc              ; Save point flags
        push    hl              ; Save code string address
        push    de              ; Save digit
        call    mlsp10          ; Multiply number by 10
        pop     af              ; Restore digit
        sub     $30             ; Make it absolute
        call    rscale          ; Re-scale number
        pop     hl              ; Restore code string address
        pop     bc              ; Restore point flags
        pop     de              ; Restore sign of exponent
        jr      manlp           ; Get another digit

rscale: call    stakfp          ; Put number on stack
        call    flgrel          ; Digit to add to FPREG
;------------------------------------------------------------------------------
; FP Addition
;------------------------------------------------------------------------------        
padd:   pop     bc              ; Restore number
        pop     de
        jp      fpadd           ; Add BCDE to FPREG and return

edigit: ld      a,e             ; Get digit
        rlca                    ; Times 2
        rlca                    ; Times 4
        add     a,e             ; Times 5
        rlca                    ; Times 10
        add     a,(hl)          ; Add next digit
        sub     $30             ; Make it absolute
        ld      e,a             ; Save new digit
        jp      explp           ; Look for another digit
;------------------------------------------------------------------------------
; Prints " in " + Line number in HL for Error Handling
;------------------------------------------------------------------------------
linein: push    hl              ; Save code string address
        ld      hl,inmsg        ; Output " in "
        call    prs             ; Output string at HL
        pop     hl              ; Restore code string address
;------------------------------------------------------------------------------
; Convert HL to ASCII and Print
;------------------------------------------------------------------------------        
prnthl: ex      de,hl           ; Code string address to DE
        xor     a
        ld      b,80h+24        ; 24 bits
        call    retint          ; Return the integer
        ld      hl,prnums       ; Print number string
        push    hl              ; Save for return
;------------------------------------------------------------------------------
; Convert FPREG to ASCII in PBUFF
;------------------------------------------------------------------------------
numasc: ld      hl,pbuff        ; Convert number to ASCII
        push    hl              ; Save for return
        call    tstsgn          ; Test sign of FPREG
        ld      (hl),$20        ; Space at start
        jp      p,spcfst        ; Positive - Space to start
        ld      (hl),'-'        ; "-" sign at start
spcfst: inc     hl              ; First byte of number
        ld      (hl),'0'        ; "0" if zero
        jp      z,jstzer        ; Return "0" if zero
        push    hl              ; Save buffer address
        call    m,invsgn        ; Negate FPREG if negative
        xor     a               ; Zero A
        push    af              ; Save it
        call    rngtst          ; Test number is in range
sixdig: ld      bc,9143h        ; BCDE - 99999.9
        ld      de,4ff8h
        call    cmpnum          ; Compare numbers
        or      a
        jp      po,inrng        ; > 99999.9 - Sort it out
        pop     af              ; Restore count
        call    multen          ; Multiply by ten
        push    af              ; Re-save count
        jr      sixdig          ; Test it again

gtsixd: call    div10           ; Divide by 10
        pop     af              ; Get count
        inc     a               ; Count divides
        push    af              ; Re-save count
        call    rngtst          ; Test number is in range
inrng:  call    round           ; Add 0.5 to FPREG
        inc     a
        call    fpint           ; F.P to integer
        call    fpbcde          ; Move BCDE to FPREG
        ld      bc,0306h        ; 1E+06 to 1E-03 range
        pop     af              ; Restore count
        add     a,c             ; 6 digits before point
        inc     a               ; Add one
        jp      m,maknum        ; Do it in "E" form if < 1E-02
        cp      6+1+1           ; More than 999999 ?
        jp      nc,maknum       ; Yes - Do it in "E" form
        inc     a               ; Adjust for exponent
        ld      b,a             ; Exponent of number
        ld      a,2             ; Make it zero after

maknum: dec     a               ; Adjust for digits to do
        dec     a
        pop     hl              ; Restore buffer address
        push    af              ; Save count
        ld      de,powers       ; Powers of ten
        dec     b               ; Count digits before point
        jr      nz,digtxt       ; Not zero - Do number
        ld      (hl),'.'        ; Save point
        inc     hl              ; Move on
        ld      (hl),'0'        ; Save zero
        inc     hl              ; Move on
digtxt: dec     b               ; Count digits before point
        ld      (hl),'.'        ; Save point in case
        call    z,inchl         ; Last digit - move on
        push    bc              ; Save digits before point
        push    hl              ; Save buffer address
        push    de              ; Save powers of ten
        call    bcdefp          ; Move FPREG to BCDE
        pop     hl              ; Powers of ten table
        ld      b,'0'-1         ; ASCII "0" - 1
tryagn: inc     b               ; Count subtractions
        ld      a,e             ; Get LSB
        sub     (hl)            ; Subtract LSB
        ld      e,a             ; Save LSB
        inc     hl
        ld      a,d             ; Get NMSB
        sbc     a,(hl)          ; Subtract NMSB
        ld      d,a             ; Save NMSB
        inc     hl
        ld      a,c             ; Get MSB
        sbc     a,(hl)          ; Subtract MSB
        ld      c,a             ; Save MSB
        dec     hl              ; Point back to start
        dec     hl
        jr      nc,tryagn       ; No overflow - Try again
        call    plucde          ; Restore number
        inc     hl              ; Start of next number
        call    fpbcde          ; Move BCDE to FPREG
        ex      de,hl           ; Save point in table
        pop     hl              ; Restore buffer address
        ld      (hl),b          ; Save digit in buffer
        inc     hl              ; And move on
        pop     bc              ; Restore digit count
        dec     c               ; Count digits
        jr      nz,digtxt       ; More - Do them
        dec     b               ; Any decimal part?
        jr      z,doebit        ; No - Do "E" bit
suptlz: dec     hl              ; Move back through buffer
        ld      a,(hl)          ; Get character
        cp      $30             ; "0" character?
        jr      z,suptlz        ; Yes - Look back for more
        cp      '.'             ; A decimal point?
        call    nz,inchl        ; Move back over digit

doebit: pop     af              ; Get "E" flag
        jr      z,noened        ; No "E" needed - End buffer
        ld      (hl),'E'        ; Put "E" in buffer
        inc     hl              ; And move on
        ld      (hl),'+'        ; Put '+' in buffer
        jp      p,outexp        ; Positive - Output exponent
        ld      (hl),'-'        ; Put "-" in buffer
        cpl                     ; Negate exponent
        inc     a
outexp: ld      b,$2f           ; ASCII "0" - 1
expten: inc     b               ; Count subtractions
        sub     10              ; Tens digit
        jr      nc,expten       ; More to do
        add     a,$30+10        ; Restore and make ASCII
        inc     hl              ; Move on
        ld      (hl),b          ; Save MSB of exponent
jstzer: inc     hl              ;
        ld      (hl),a          ; Save LSB of exponent
        inc     hl
noened: ld      (hl),c          ; Mark end of buffer
        pop     hl              ; Restore code string address
        ret

rngtst: ld      bc,9474h        ; BCDE = 999999.
        ld      de,23f7h
        call    cmpnum          ; Compare numbers
        or      a
        pop     hl              ; Return address to HL
        jp      po,gtsixd       ; Too big - Divide by ten
        jp      (hl)            ; Otherwise return to caller
;------------------------------------------------------------------------------
;  FP REGISTERS  E   D   C   B
half	defb	$00,$00,$00,$80	;0.5
;------------------------------------------------------------------------------
powers	defb	$a0,$86,$01	; 100000
	defb	$10,$27,$00	;  10000
	defb	$e8,$03,$00	;   1000
	defb	$64,$00,$00	;    100
	defb	$0a,$00,$00	;     10
	defb	$01,$00,$00	;      1
;------------------------------------------------------------------------------	
negaft: ld      hl,invsgn       ; Negate result
        ex      (sp),hl         ; To be done after caller
        jp      (hl)            ; Return to caller
;------------------------------------------------------------------------------
; SQR
;------------------------------------------------------------------------------
sqr:    call    stakfp          ; Put value on stack
        ld      hl,half         ; Set power to 1/2
        call    phltfp          ; Move 1/2 to FPREG
;------------------------------------------------------------------------------
; FPREG = (last) ^ FPREG
;------------------------------------------------------------------------------
power:  pop     bc              ; Get base
        pop     de
        call    tstsgn          ; Test sign of power
        ld      a,b             ; Get exponent of base
        jr      z,exp           ; Make result 1 if zero
        jp      p,power1        ; Positive base - Ok
        or      a               ; Zero to negative power?
        jp      z,dzerr         ; Yes - ?/0 Error
power1: or      a               ; Base zero?
        jp      z,savexp        ; Yes - Return zero
        push    de              ; Save base
        push    bc
        ld      a,c             ; Get MSB of base
        or      01111111b       ; Get sign status
        call    bcdefp          ; Move power to BCDE
        jp      p,power2        ; Positive base - Ok
        push    de              ; Save power
        push    bc
        call    int             ; Get integer of power
        pop     bc              ; Restore power
        pop     de
        push    af              ; MSB of base
        call    cmpnum          ; Power an integer?
        pop     hl              ; Restore MSB of base
        ld      a,h             ; but don't affect flags
        rra                     ; Exponent odd or even?
power2: pop     hl              ; Restore MSB and exponent
        ld      (fpreg+2),hl    ; Save base in FPREG
        pop     hl              ; LSBs of base
        ld      (fpreg),hl      ; Save in FPREG
        call    c,negaft        ; Odd power - Negate result
        call    z,invsgn        ; Negative base - Negate it
        push    de              ; Save power
        push    bc
        call    log             ; Get LOG of base
        pop     bc              ; Restore power
        pop     de
        call    fpmult          ; Multiply LOG by power
;------------------------------------------------------------------------------
; EXP
;------------------------------------------------------------------------------
exp:    call    stakfp          ; Put value on stack
        ld      bc,$8138        ; BCDE = 1/Ln(2)
        ld      de,$aa3b
        call    fpmult          ; Multiply value by 1/LN(2)
        ld      a,(fpexp)       ; Get exponent
        cp      80h+8           ; Is it in range?
        jp      nc,ovtst1       ; No - Test for overflow
        call    int             ; Get INT of FPREG
        add     a,80h           ; For excess 128
        add     a,2             ; Exponent > 126?
        jp      c,ovtst1        ; Yes - Test for overflow
        push    af              ; Save scaling factor
        ld      hl,unity        ; Point to 1.
        call    addphl          ; Add 1 to FPREG
        call    mulln2          ; Multiply by LN(2)
        pop     af              ; Restore scaling factor
        pop     bc              ; Restore exponent
        pop     de
        push    af              ; Save scaling factor
        call    subcde          ; Subtract exponent from FPREG
        call    invsgn          ; Negate result
        ld      hl,exptab       ; Coefficient table
        call    smser1          ; Sum the series
        ld      de,0            ; Zero LSBs
        pop     bc              ; Scaling factor
        ld      c,d             ; Zero MSB
        jp      fpmult          ; Scale result to correct value

exptab: defb    8                   ; Table used by EXP
        defb    $40,$2e,$94,$74     ; -1/7! (-1/5040)
        defb    $70,$4f,$2e,$77     ;  1/6! ( 1/720)
        defb    $6e,$02,$88,$7a     ; -1/5! (-1/120)
        defb    $e6,$a0,$2a,$7c     ;  1/4! ( 1/24)
        defb    $50,$aa,$aa,$7e     ; -1/3! (-1/6)
        defb    $ff,$ff,$7f,$7f     ;  1/2! ( 1/2)
        defb    $00,$00,$80,$81     ; -1/1! (-1/1)
        defb    $00,$00,$00,$81     ;  1/0! ( 1/1)

sumser: call    stakfp          ; Put FPREG on stack
        ld      de,mult         ; Multiply by "X"
        push    de              ; To be done after
        push    hl              ; Save address of table
        call    bcdefp          ; Move FPREG to BCDE
        call    fpmult          ; Square the value
        pop     hl              ; Restore address of table
smser1: call    stakfp          ; Put value on stack
        ld      a,(hl)          ; Get number of coefficients
        inc     hl              ; Point to start of table
        call    phltfp          ; Move coefficient to FPREG
        defb     06h             ; Skip "POP AF"
sumlp:  pop     af              ; Restore count
        pop     bc              ; Restore number
        pop     de
        dec     a               ; Cont coefficients
        ret     z               ; All done
        push    de              ; Save number
        push    bc
        push    af              ; Save count
        push    hl              ; Save address in table
        call    fpmult          ; Multiply FPREG by BCDE
        pop     hl              ; Restore address in table
        call    loadfp          ; Number at HL to BCDE
        push    hl              ; Save address in table
        call    fpadd           ; Add coefficient to FPREG
        pop     hl              ; Restore address in table
        jr      sumlp           ; More coefficients
;------------------------------------------------------------------------------
; Random number generator
;------------------------------------------------------------------------------        
rnd:    call    tstsgn          ; Test sign of FPREG
        ld      hl,seed+2       ; Random number seed
        jp      m,reseed        ; Negative - Re-seed
        ld      hl,lstrnd       ; Last random number
        call    phltfp          ; Move last RND to FPREG
        ld      hl,seed+2       ; Random number seed
        ret     z               ; Return if RND(0)
        add     a,(hl)          ; Add (SEED)+2)
        and     00000111b       ; 0 to 7
        ld      b,0
        ld      (hl),a          ; Re-save seed
        inc     hl              ; Move to coefficient table
        add     a,a             ; 4 bytes
        add     a,a             ; per entry
        ld      c,a             ; BC = Offset into table
        add     hl,bc           ; Point to coefficient
        call    loadfp          ; Coefficient to BCDE
        call    fpmult  ;       ; Multiply FPREG by coefficient
        ld      a,(seed+1)      ; Get (SEED+1)
        inc     a               ; Add 1
        and     00000011b       ; 0 to 3
        ld      b,0
        cp      1               ; Is it zero?
        adc     a,b             ; Yes - Make it 1
        ld      (seed+1),a      ; Re-save seed
        ld      hl,rndtab-4     ; Addition table
        add     a,a             ; 4 bytes
        add     a,a             ; per entry
        ld      c,a             ; BC = Offset into table
        add     hl,bc           ; Point to value
        call    addphl          ; Add value to FPREG
rnd1:   call    bcdefp          ; Move FPREG to BCDE
        ld      a,e             ; Get LSB
        ld      e,c             ; LSB = MSB
        xor     01001111b       ; Fiddle around
        ld      c,a             ; New MSB
        ld      (hl),80h        ; Set exponent
        dec     hl              ; Point to MSB
        ld      b,(hl)          ; Get MSB
        ld      (hl),80h        ; Make value -0.5
        ld      hl,seed         ; Random number seed
        inc     (hl)            ; Count seed
        ld      a,(hl)          ; Get seed
        sub     171             ; Do it modulo 171
        jr      nz,rnd2         ; Non-zero - Ok
        ld      (hl),a          ; Zero seed
        inc     c               ; Fillde about
        dec     d               ; with the
        inc     e               ; number
rnd2:   call    bnorm           ; Normalise number
        ld      hl,lstrnd       ; Save random number
        jp      fpthl           ; Move FPREG to last and return

reseed: ld      (hl),a          ; Re-seed random numbers
        dec     hl
        ld      (hl),a
        dec     hl
        ld      (hl),a
        jr      rnd1            ; Return RND seed

rndtab: defb    068h,0b1h,046h,068h     ; Table used by RND
        defb    099h,0e9h,092h,069h
        defb    010h,0d1h,075h,068h
;------------------------------------------------------------------------------
; COS, SIN
;------------------------------------------------------------------------------
cos:    ld      hl,halfpi       ; Point to PI/2
        call    addphl          ; Add it to PPREG
sin:    call    stakfp          ; Put angle on stack
        ld      bc,8349h        ; BCDE = 2 PI
        ld      de,0fdbh
        call    fpbcde          ; Move 2 PI to FPREG
        pop     bc              ; Restore angle
        pop     de
        call    dvbcde          ; Divide angle by 2 PI
        call    stakfp          ; Put it on stack
        call    int             ; Get INT of result
        pop     bc              ; Restore number
        pop     de
        call    subcde          ; Make it 0 <= value < 1
        ld      hl,quartr       ; Point to 0.25
        call    subphl          ; Subtract value from 0.25
        call    tstsgn          ; Test sign of value
        scf                     ; Flag positive
        jp      p,sin1          ; Positive - Ok
        call    round           ; Add 0.5 to value
        call    tstsgn          ; Test sign of value
        or      a               ; Flag negative
sin1:   push    af              ; Save sign
        call    p,invsgn        ; Negate value if positive
        ld      hl,quartr       ; Point to 0.25
        call    addphl          ; Add 0.25 to value
        pop     af              ; Restore sign
        call    nc,invsgn       ; Negative - Make positive
        ld      hl,sintab       ; Coefficient table
        jp      sumser          ; Evaluate sum of series

halfpi: defb    0dbh,00fh,049h,081h     ; 1.5708 (PI/2)

quartr: defb    000h,000h,000h,07fh     ; 0.25

sintab: defb    5                       ; Table used by SIN
        defb    0bah,0d7h,01eh,086h     ; 39.711
        defb    064h,026h,099h,087h     ;-76.575
        defb    058h,034h,023h,087h     ; 81.602
        defb    0e0h,05dh,0a5h,086h     ;-41.342
        defb    0dah,00fh,049h,083h     ;  6.2832
;------------------------------------------------------------------------------
; TANgent
;------------------------------------------------------------------------------
tan:    call    stakfp          ; Put angle on stack
        call    sin             ; Get SIN of angle
        pop     bc              ; Restore angle
        pop     hl
        call    stakfp          ; Save SIN of angle
        ex      de,hl           ; BCDE = Angle
        call    fpbcde          ; Angle to FPREG
        call    cos             ; Get COS of angle
        jp      div             ; TAN = SIN / COS
;------------------------------------------------------------------------------
; Arctangent
;------------------------------------------------------------------------------
atn:    call    tstsgn          ; Test sign of value
        call    m,negaft        ; Negate result after if -ve
        call    m,invsgn        ; Negate value if -ve
        ld      a,(fpexp)       ; Get exponent
        cp      81h             ; Number less than 1?
        jp      c,atn1          ; Yes - Get arc tangnt
        ld      bc,8100h        ; BCDE = 1
        ld      d,c
        ld      e,c
        call    dvbcde          ; Get reciprocal of number
        ld      hl,subphl       ; Sub angle from PI/2
        push    hl              ; Save for angle > 1
atn1:   ld      hl,atntab       ; Coefficient table
        call    sumser          ; Evaluate sum of series
        ld      hl,halfpi       ; PI/2 - angle in case > 1
        ret                     ; Number > 1 - Sub from PI/2

atntab: defb    9                       ; Table used by ATN
        defb    04ah,0d7h,03bh,078h     ; 1/17
        defb    002h,06eh,084h,07bh     ;-1/15
        defb    0feh,0c1h,02fh,07ch     ; 1/13
        defb    074h,031h,09ah,07dh     ;-1/11
        defb    084h,03dh,05ah,07dh     ; 1/9
        defb    0c8h,07fh,091h,07eh     ;-1/7
        defb    0e4h,0bbh,04ch,07eh     ; 1/5
        defb    06ch,0aah,0aah,07fh     ;-1/3
        defb    000h,000h,000h,081h     ; 1/1
;------------------------------------------------------------------------------
;  End of F L O A T I N G    P O I N T   M A T H
;------------------------------------------------------------------------------        

;------------------------------------------------------------------------------
; HARDWARE SPECIFIC ROUTINES
;------------------------------------------------------------------------------
waitcr	call	dsconin		; Get a character in
	cp	$03		; Is it <Break>?
	jp	z,prntok	; Go to prompt
	cp	$0d		; Is it <Enter>?
	jr	nz,waitcr	; No, keep looking
	ret			; Yes, return to calling routine
;------------------------------------------------------------------------------
; OUTPUT CHARACTER ROUTINE
;------------------------------------------------------------------------------
outc:   push    af              ; Save character
        ld      a,(ctlofg)      ; Get control "O" flag
        or      a               ; Is it set?
        jp      nz,popaf        ; Yes - don't output
        pop     af              ; Restore character
        push    bc              ; Save buffer length
        push    af              ; Save character
        cp      $20             ; Is it a control code?
        jr      c,dinpos        ; Yes - Don't INC POS(X)
        ld      a,(lwidth)      ; Get line width
        ld      b,a             ; To B
        ld      a,(curpos)      ; Get cursor position
        inc     b               ; Width 255?
        jr      z,inclen        ; Yes - No width limit
        dec     b               ; Restore width
        cp      b               ; At end of line?
        call    z,prntcr        ; Yes - output CRLF
inclen: inc     a               ; Move on one character
        ld      (curpos),a      ; Save new position
dinpos: pop     af              ; Restore character
        pop     bc              ; Restore buffer length
        push    af              ; Save character
        push    bc              ; Save buffer length
        ld      c,a             ; Character to C

	call	dsconout	; Send it

        pop     bc              ; Restore buffer length
        pop     af              ; Restore character
        ret
;------------------------------------------------------------------------------
; INPUT CHARACTER ROUTINE
;------------------------------------------------------------------------------
clotst: call	dsconin             ; Get input character
        cp      ctrlo           ; Is it control "O"?
        ret     nz              ; No don't flip flag
        ld      a,(ctlofg)      ; Get flag
        cpl                     ; Flip it
        ld      (ctlofg),a      ; Put it back
        xor     a               ; Null character
        ret
;------------------------------------------------------------------------------	
; NMI Vectors to here
;------------------------------------------------------------------------------	
break:  push    af              ; Save character
        ld      a,$ff		; Set the break flag
        ld      (brkflg),a      ; Flag break
        pop     af              ; Restore character

aretn:  retn                    ; Return from NMI
;------------------------------------------------------------------------------
; SCREEN (ABREVIATED, THIS ROUTINE USELESS FOR THIS SBC)
;------------------------------------------------------------------------------
screen: call    getint          ; Get integer 0 to 255
        push    af              ; Save column
        call    chksyn          ; Make sure "," follows
        defb   ','
        call    getint          ; Get integer 0 to 255
        ret
;------------------------------------------------------------------------------
; Set a pixel at X,Y
;------------------------------------------------------------------------------
pset	call	getxy		; GET (X,Y)
	nop			; REST OF CODE HERE
	ret
;------------------------------------------------------------------------------
; Clear a pixel at X,Y
;------------------------------------------------------------------------------
reset	call	getxy		; GET (X,Y)
	nop			; REST OF CODE HERE
	ret
;------------------------------------------------------------------------------
; Check if pixel is set at X,Y
;------------------------------------------------------------------------------
point	call	getxy		; GET (X,Y)
	xor	a		; ZERO OUT A
	ld	b,a		; SET AB TO $0000
	call	abpass		; PASS THE ZERO BACK TO THE PROGRAM
	nop			; REST OF CODE HERE
	ret
;------------------------------------------------------------------------------
getxy   call    getnum          ; Get a number
        call    deint           ; Get integer -32768 to 32767
        ld	(x1pos),de	; Save X value
        call    chksyn          ; Make sure "," follows
        defb	','
        call    getnum          ; Get a number
        call    deint           ; Get integer -32768 to 32767
	ld	(y1pos),de	; Save Y value
	ret        
;------------------------------------------------------------------------------
; LOAD Program
;------------------------------------------------------------------------------
load	cp	ztimes		; "*" token?
	jp	z,snerr		; Yes, Sorry we don't handle Array Loads
	call	clrptr		; No, it's a new program, perform "NEW"
	
	ex	af,af'		; Save registers to alternate set AF
	exx			; Save BC,DE,HL
	ld	hl,tload	; Get "Send Program file now." text
	call	prs		; Print it

	call	loada		; Load INTEL hex file

	exx			; Reclaim the registers BC,DE,HL
	ex	af,af'		; Reclaim registers AF
	jp	warmst		; Warm start the new program
;------------------------------------------------------------------------------
; SAVE Program
;------------------------------------------------------------------------------
save	cp	ztimes		; "*" Token following? ("SAVE*")
	jp	z,snerr		; Yes, We have no Array SAve
	push	hl		; Save code string address
	ex	af,af'		; Save registers AF	
	exx			; Save BC,DE,HL
	ld	de,(progst)	; START OF PROGRAM	
	ld	hl,(prognd)	; END OF PROGRAM
		
	call	sintlx		; DO THE INTEL HEX SAVE
	
	exx			; Reclaim BC,DE,HL
	ex	af,af'		; Reclaim AF
	pop	hl		; Reclaim code string address
	ret			; Finished, return to BASIC
;------------------------------------------------------------------------------
; S A V E    I N T E L    H E X    R E C O R D S 
;   HL=START,DE=END
;   INTEL HEX FORMAT - EACH LINE STARTS WITH A COLON ":" AND CONTAINS
;   :LLAAAATTDDDDDDDDDDDDDDCC WHERE LL=RECORD LENGTH, AAAA=RECORD ADDRESS, 
;   DD=DATA IN ASCII HEX, CC=CHECKSUM ALL HEX VALUE BYTES SHOULD ADD UP TO $00
;------------------------------------------------------------------------------
sintlx	xor	a		; CLEAR ACCUM AND FLAGS
	push	de		; TEMP SAVE START ADDRESS
	sbc	hl,de		; HL= END-START
	ld	d,h		; TRANSFER TO DE
	ld	e,l
	pop	hl		; PUT START ADDRESS INTO HL
save1	ld	a,d		; ARE WE SAVING < $100 BYTES?
	or	a		; TEST D
	jr	z,lstrec	; LAST RECORD

	ld	a,$ff		; OTHERWISE, RECORD LENGTH = $FF
	call	dmprec		; WRITE THE NEXT $FF BYTES RECORD
	jr	save1		; KEEP GOING UNTIL FINISHED	

lstrec	ld	a,e		; BETWEEN $00 AND $FF BYTES LEFT TO SAVE
	call	dmprec		; DUMP THE FINAL RECORD

	ld	a,$0d		; CREATE THE CLOSING LINE
	call	dsconout	; PRINT THE CR
	ld	a,$0a		; LOAD A LF
	call	dsconout	; PRINT IT
	ld	a,':'		; EOF LINE
	call	dsconout	; PRINT THE COLON AT START OF LINE
	xor	a		; RECORD LENGTH = $00
	call 	hexout		; OUTPUT IT
	xor	a		; ADDRESS=$0000
	call	hexout		; OUTPUT IT
	xor	a		; OUTPUT IT AGAIN
	call	hexout		; FINISH ADDRESS
	ld	a,$01		; EOF INDICATION
	call	hexout		; OUTPUT THAT
	ld	a,$ff		; FAKE THE CHECKSUM
	call	hexout		; OUTPUT THE FINAL BYTE
	ld	a,$0d		; CARRIAGE RET
	call	dsconout
	ld	a,$0a		; LF
	call	dsconout
	ret			; FINISHED AT LAST
;------------------------------------------------------------------------------
; ENTER WITH A=# OF BYTES IN RECORD, HL POINTS AT START OF RECORD TO SAVE
;------------------------------------------------------------------------------
dmprec	ld	b,a		; SAVE LENGTH IN B
	ld	a,$0d		; PRINT CR
	call	dsconout	; OUTPUT
	ld	a,$0a		; PRINT LF
	call	dsconout	; OUTPUT
	ld	a,':'		; COLON IS START OF LINE
	call	dsconout	; OUTPUT IT
	ld	a,b		; GET LENGTH BACK
	ld	c,a		; START THE CHECKSUM
	call	hexout		; WRITE (ACCUM) THE LENGTH OUT
	call	hlhex		; OUTPUT HL IN HEX
	ld	a,c		; GET CHECKSUM
	add	a,h		; ADD HIGH ADDRESS
	add	a,l		; ADD LOW  ADDRESS
	ld	c,a		; SAVE NEW CHECKSUM
	xor	a		; DATA TYPE = $00
	call	hexout		; OUTPUT THE BYTE
	inc	b		; BUMP COUNTER TO GET LAST BYTE
memhex	ld	a,(hl)		; GET MEMORY CONTENTS
	call	hexout		; AND OUTPUT
	ld	a,(hl)		; GET MEMORY CONTENTS AGAIN
	add	a,c		; ADD TO CHECKSUM
	ld	c,a		; STORE NEW CHECKSUM
	inc	hl		; NEXT MEMORY LOCATION
	
	dec	de		; REDUCE THE POINTER
	
	djnz	memhex		; CONTINUE UNTIL RECORD SAVED
	ld	a,c		; RETRIEVE CHECKSUM
	cpl			; INVERT TO CREATE ONE'S COMPLEMENT
	inc	a		; CREATE TWO'S COMPLEMENT
	call	hexout		; WRITE CHECKSUM OUT
	ret	
;------------------------------------------------------------------------------
; Convert HL to HEX ASCII and print it, part of INTEL Hex save
;------------------------------------------------------------------------------
hlhex	ld	a,h		; GET H
	call	hexout		; CONVERT IT
	ld	a,l
;------------------------------------------------------------------------------
; Convert byte in A to HEX ASCII and print it, part of INTEL Hex save
;------------------------------------------------------------------------------	
hexout	push 	af		;Convert the upper nybble to Hex ASCII first
       	rra			;Slowly
       	rra			; Rotate
       	rra			;  It
       	rra			;   Over to the right
       	call 	hexop		;Convert the nybble D3-D0 to Hex ASCII
       	pop 	af		;Retrieve the original value and convert the lower nybble
hexop  	and 	$0f		;Convert the nybble at D3-D2-D1-D0 to Hex ASCII char
       	cp 	10		;Neat trick for converting nybble to ASCII
       	sbc 	a,$69
       	daa			;Uses DAA trick
	call	dsconout
	ret
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
loada	call	dsconin		; Get a character
	or	a		; null ?
	jr	z,loada		; ignore
	cp	$3a		; COLON? MUST BE START OF INTEL HEX LINE
	jr	nz,ckerr		;MUST BE GARBAGE, EXIT

	ld	e,$00		; RECORD LENGTH FIELD
	call	cksum		; GET US 2 CHARS INTO BC, CONVERT TO BYTE
	ld	d,a		; LOAD RECORD LENGTH COUNT INTO D
	call	cksum		; GET NEXT TWO CHARS, MEMORY LOAD ADDRESS <H>
	ld	h,a		; PUT IT IN H
	call	cksum		; GET NEXT TWO CHARS, MEMORY LOAD ADDRESS <L>
	ld	l,a
	call	cksum		; GET NEXT TWO CHARS, RECORD FIELD TYPE
	cp	$01		; RECORD FIELD $00=DATA, $01 IS EOF
	jr	nz,datat
	call	cksum		; GET NEXT TWO CHARS, ASSEMBLE INTO BYTE
	ld	a,e
	and	a
	ret	z		; CHECKSUMS OK THUS FAR
	jr	ckerr		; NOT ZERO, MUST BE GARBAGE

datat	ld	a,d		; IS A LINE OF DATA
	and	a
	jr	z,ckck
	call	cksum
	ld	(hl),a
	inc	hl
	dec	d
	jr	datat
	
ckck	call	cksum
	ld	a,e
	and	a
	jr	z,loada		; Keep getting characters until done

ckerr	ld	hl,tcksm	; GET "Checksum Error" message
	jp	prt		; and print it

getval	call	dsconin		; RX a Character
	or	a
	jr	z,getval
	cp	$03          	; <CTRL-C>?
	ret	z
	cp	$20		; LESS THAN <SPC>?
	jr	c,getval
	ret
cksum	call	getval
	ld	b,a
	call	getval
	ld	c,a
	call	asc2byt
	ld	c,a
	ld	a,e
	sub	c
	ld	e,a
	ld	a,c
	ret
;------------------------------------------------------------------------------
; CLEAR THE TTYA DISPLAY
;------------------------------------------------------------------------------
cls	ld	a,cs		;$0C FORM FEED
	call	dsconout	;PRINT IT
	ret
;------------------------------------------------------------------------------
; PRINT A STRING OF CHARACTERS DIRECT UNTIL CHAR=$00
;------------------------------------------------------------------------------
prt	ld	a,(hl)		; LOAD LTEXT AT (HL)
	or	a		; IS IT $00? TERMINATOR
	ret	z		; FINISHED
	call	dsconout	; PRINT THE CHARACTER
	inc	hl		; INDEX LOCATION
	jr	prt		; CONTINUE UNTIL FINISHED
;------------------------------------------------------------------------------
; EXIT BASIC TO MONITOR
;------------------------------------------------------------------------------
exit	ld	a,cr		; CARRIAGE RETURN
	call	dsconout	; PRINT IT
	ld	a,lf		; LINE FEED
	call	dsconout	; PRINT IT
	ld	c,mmuport	; address MMU
	ld	b,bbpag << 4	; put bootmonitor in place
	ld	a,(hmempag)	; highest ram page
	sub	4
	out	(c),a

	rst	00h		; EXIT TO RESTART
;------------------------------------------------------------------------------
;Convert ASCII in BC to byte value in A
;------------------------------------------------------------------------------
asc2byt	ld	a,b		;MOVE HI BYTE TO A
	sub	$30		;CONVERT IT TO VALUE
	cp	$0a		;0-9?
	jr	c,asc2b1	;IF NO, IS A-F SO
	sub	$07		;SUBTRACT 7 MORE
asc2b1	rlca			;AND MOVE IT
	rlca			;TO THE LEFT NYBBLE
	rlca			;VERY
	rlca			;SLOWLY
	ld	b,a		;AND SAVE IT TO B
	ld	a,c		;GET LOW BYTE TO A
	sub	$30		;CONVERT TO ASCII
	cp	$0a		;0-9?
	jr	c,asc2b2	;IF NO, IS A-F SO
	sub	$07		;WE SUBTRACT 7 MORE
asc2b2	add	a,b		;AND STORE IT WITH THE HI NYBBLE
	ret			;SO WE CAN FINISH
;------------------------------------------------------------------------------
; I/O routines for the DarkStar Z80
;------------------------------------------------------------------------------

dschksio:			; DO NOTHING ON DARKSTAR
	ret

dsconin:			; GET A CHAR
	call	bbconst
	ret	z
	jp	bbconin


dsconout:			; PUT A CHAR
	ld	c, a
	jp 	bbconout
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
; FUNCTION ADDRESS TABLE
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
fnctab: defw     sgn
        defw     int
        defw     abs
        defw     usr
        defw     fre
        defw     inp
        defw     pos
        defw     sqr
        defw     rnd
        defw     log
        defw     exp
        defw     cos
        defw     sin
        defw     tan
        defw     atn
        defw     peek
        defw     hex		; Was "DEEK"
        defw     point
        defw     len
        defw     str
        defw     val
        defw     asc
        defw     chr
        defw     left
        defw     right
        defw     mid
;------------------------------------------------------------------------------
; RESERVED WORD LLIST
;------------------------------------------------------------------------------
words:  defb     'E'+ $80,"ND"
        defb     'F'+80h,"OR"
        defb     'N'+80h,"EXT"
        defb     'D'+80h,"ATA"
        defb     'I'+80h,"NPUT"
        defb     'D'+80h,"IM"
        defb     'R'+80h,"EAD"
        defb     'L'+80h,"ET"
        defb     'G'+80h,"OTO"
        defb     'R'+80h,"UN"
        defb     'I'+80h,"F"
        defb     'R'+80h,"ESTORE"
        defb     'G'+80h,"OSUB"
        defb     'R'+80h,"ETURN"
        defb     'R'+80h,"EM"
        defb     'S'+80h,"TOP"
        defb     'O'+80h,"UT"
        defb     'O'+80h,"N"
        defb     'N'+80h,"ULL"
        defb     'W'+80h,"AIT"
        defb     'D'+80h,"EF"
        defb     'P'+80h,"OKE"
        defb     'V'+80h,"ECTOR"
        defb     'S'+80h,"CREEN"
        defb     'L'+80h,"INES"
        defb     'C'+80h,"LS"
        defb     'W'+80h,"IDTH"
        defb     'E'+80h,"XIT"		; formerly MONITR
        defb     'S'+80h,"ET"
        defb     'R'+80h,"ESET"
        defb     'P'+80h,"RINT"
        defb     'C'+80h,"ONT"
        defb     'L'+80h,"IST"
        defb     'C'+80h,"LEAR"
        defb     'L'+80h,"OAD"
        defb     'S'+80h,"AVE"
        defb     'N'+80h,"EW"
        defb     'T'+80h,"AB("
        defb     'T'+80h,"O"
        defb     'F'+80h,"N"
        defb     'S'+80h,"PC("
        defb     'T'+80h,"HEN"
        defb     'N'+80h,"OT"
        defb     'S'+80h,"TEP"
;------------------------------------------------------------------------------
        defb     '+'+80h
        defb     '-'+80h
        defb     '*'+80h
        defb     '/'+80h
        defb     '^'+80h
        defb     'A'+80h,"ND"
        defb     'O'+80h,"R"
        defb     '>'+80h
        defb     '='+80h
        defb     '<'+80h
;------------------------------------------------------------------------------
        defb     'S'+80h,"GN"
        defb     'I'+80h,"NT"
        defb     'A'+80h,"BS"
        defb     'U'+80h,"SR"
        defb     'F'+80h,"RE"
        defb     'I'+80h,"NP"
        defb     'P'+80h,"OS"
        defb     'S'+80h,"QR"
        defb     'R'+80h,"ND"
        defb     'L'+80h,"OG"
        defb     'E'+80h,"XP"
        defb     'C'+80h,"OS"
        defb     'S'+80h,"IN"
        defb     'T'+80h,"AN"
        defb     'A'+80h,"TN"
        defb     'P'+80h,"EEK"
        defb     'H'+80h,"EX"		;Was DEEK
        defb     'P'+80h,"OINT"
        defb     'L'+80h,"EN"
        defb     'S'+80h,"TR$"
        defb     'V'+80h,"AL"
        defb     'A'+80h,"SC"
        defb     'C'+80h,"HR$"
        defb     'L'+80h,"EFT$"
        defb     'R'+80h,"IGHT$"
        defb     'M'+80h,"ID$"
        defb     80h             	; End of list marker
;------------------------------------------------------------------------------
; KEYWORD ADDRESS TABLE
;------------------------------------------------------------------------------
wordtb: defw     pend
        defw     for
        defw     next
        defw     data
        defw     input
        defw     dim
        defw     lread
        defw     let
        defw     goto
        defw     run
        defw     ift
        defw     restor
        defw     gosub
        defw     return
        defw     rem
        defw     stop
        defw     pout
        defw     on
        defw     null
        defw     wait
        defw     def
        defw     poke
        defw     vector
        defw     screen
        defw     lines
        defw     cls
        defw     width
        defw     exit
        defw     pset
        defw     reset
        defw     prints
        defw     cont
        defw     llist
        defw     clear
        defw     load
        defw     save
        defw     new
;------------------------------------------------------------------------------
; ARITHMETIC PRECEDENCE TABLE
;------------------------------------------------------------------------------
pritab: defb     $79           ; Precedence value
        defw     padd          ; FPREG = <last> + FPREG

        defb     $79           ; Precedence value
        defw     psub          ; FPREG = <last> - FPREG

        defb     $7c           ; Precedence value
        defw     mult          ; PPREG = <last> * FPREG

        defb     $7c           ; Precedence value
        defw     div           ; FPREG = <last> / FPREG

        defb     $7f           ; Precedence value
        defw     power         ; FPREG = <last> ^ FPREG

        defb     $50           ; Precedence value
        defw     pand          ; FPREG = <last> AND FPREG

        defb     $46           ; Precedence value
        defw     por           ; FPREG = <last> OR FPREG
;------------------------------------------------------------------------------
; BASIC VARIABLES INITIALIZATION TABLE
;  This "parametric data" is copied into the BASICV block on Cold Start
;------------------------------------------------------------------------------
initab: jp      warmst          ; Warm start jump, located at BASICV    $00-$02
        jp      fcerr           ; "USR (X)" jump (Set to Error)         $03-$05

        out     (0),a           ; "OUT p,n" skeleton                    $06-$07
        ret			;                                       $08

        sub     0               ; Division support routine              $09-16
        ld      l,a		
        ld      a,h
        sbc     a,0
        ld      h,a
        ld      a,b
        sbc     a,0
        ld      b,a
        ld      a,0
        ret

        defb	$00,$00,$00	; Random number seed                    $17-19

                                ; Table used by RND
        defb	$35,$4a,$ca,$99     ;-2.65145E+07                     $1A-3D
        defb	$39,$1c,$76,$98     ; 1.61291E+07
        defb	$22,$95,$b3,$98     ;-1.17691E+07
        defb	$0a,$dd,$47,$98     ; 1.30983E+07
        defb	$53,$d1,$99,$99     ;-2-01612E+07
        defb	$0a,$1a,$9f,$98     ;-1.04269E+07
        defb	$65,$bc,$cd,$98     ;-1.34831E+07
        defb	$d6,$77,$3e,$98     ; 1.24825E+07
        defb	$52,$c7,$4f,$80     ; Last random number

        in      a,(0)           ; INP (x) skeleton                      $3E-3F
        ret			;                                       $40

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
initx	defb	$00		; END OF INITIALISATION TABLE
;------------------------------------------------------------------------------
; BASIC ERROR CODE LLIST
;------------------------------------------------------------------------------
errors: defb     $01,"NEXT without FOR"
	defb     $00,$02,"Syntax"
        defb	  $00,$03,"RETURN without GOSUB"
        defb	  $00,$04,"Out of DATA"
        defb	  $00,$05,"Illegal function call"
        defb	  $00,$06,"Overflow"
        defb	  $00,$07,"Out of Memory"
        defb	  $00,$08,"Undefined Line"
        defb	  $00,$09,"Bad Subscript"
        defb	  $00,$0a,"Re-DIM\'d array"
        defb     $00,$0b,"Division by zero"
        defb	  $00,$0c,"Illegal direct"
        defb     $00,$0d,"Type Mismatch"
        defb     $00,$0e,"Out of string space"
        defb     $00,$0f,"String too long"
        defb     $00,$10,"String too complex"
        defb     $00,$11,"Can\'t CONTinue"
        defb	  $00,$12,"Undefined Function"
        defb     $00,$13,"Missing Operand"
        defb     $00,$14,"Stack Overflow"
	defb	  $00,$15,"Not valid HEX"
	defb	  $00
;------------------------------------------------------------------------------
; LTEXT MESSAGES
;------------------------------------------------------------------------------
signon	defb	$0c,"Z80 DarkStar ROM BASIC v 1.1 - P.Betti (c) 2008",cr,lf
	defb	"based on Microsoft BASIC v 4.7b",cr,lf,lf,0

sram	defb	" System Ram",cr,lf,0,0
bfree	defb	" Bytes free",cr,lf,0,0
okmsg	defb	"Ok",cr,lf,0,0
errmsg	defb	" error",0
brkmsg	defb	"Break",0
inmsg	defb	" in ",0
redo    defb   "?Redo from start",cr,lf,0
extig   defb   "?Extra ignored",cr,lf,0
tnoram	defb	"No external RAM"
	defb	" detected.",cr,lf,0,0
tsave	defb	"Capture text file now.",cr,lf,0,0
tload	defb	"Send Program file now.",cr,lf,0,0
tcksm	defb	"Checksum Error on load.",cr,lf,0,0
zrbend	equ	$
;------------------------------------------------------------------------------
; The following vectors are placed at the top of BASIC's ROMs so that future
; users of USR(x) may easily locate the routines DEINT and ABPASS, regardless
; which version of BASIC this is. Also BASIC's cold start and warmstart vectors
;------------------------------------------------------------------------------
	defs	mbase-zrbend-$1000-12+cstart
	jp	cstart		; COLD START
	jp	warmst		; WARM START
	jp	deint		; PASS FPREG INTO INTEGER IN DE
	jp	abpass		; PASS INTEGER IN AB INTO FPREG
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
finis	end			;END OF ASSEMBLY
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
	
	
