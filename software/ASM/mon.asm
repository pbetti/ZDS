;****************************************************************
;*          SME Systems SBC-800 monitor programme		*
;*   		Written by Steve Sparrow 			*
;*	Copyright (c) 1981,2,3 SME Systems Melbourne		*
;****************************************************************
; Conversion to intel opcodes and mods to run at 100 h		*
; done by 					R.C.H. 21/5/82	*
; Jump table and substitute memory 		L.I.P. 2/3/83	*
; Rationalize G command	& add P ^ and dump + ^ - variants	*
;						R.C.H. 2/3/83	*
; Fix clock and parallel printer problems			*
; Add code for external calling and return	R.C.H. 22/3/83  *
; Add x-on/ x-off for main console		R.C.H.  7/5/83  *
; Add continuous port map command		R.C.H.  7/5/83  *
; Add enter string command			R.C.H.  7/5/83  *
; Add mods to handle blank lines better		R.C.H.  7/5/83  *
; Added NMI memory protect and halt loader	R.C.H.  7/5/83  *
; Added printer S and P messages		R.C.H.  7/5/83  *
; Added better escape handling to coe		R.C.H. 10/5/83  *
; Restored disk I/O				R.C.H. 19/7/83  *
; Modified printer dead test and nmi code       R.C.H.  3/8/83  *
; Added equate for 6 Mhz CPU operation		L.I.P.  5/8/83  *
; Added equate for VDC 8024 operation		L.I.P. 15/8/83	*
; Modified clock software			R&L    26/8/83  *
; Modified to run as stand alone monitor	R.C.H. 24/10/83 *
;****************************************************************
;
	name	'mon'
	public	mon
	extrn	coe,cie,cst,loe,clkrd,clkwr
	maclib	z80
;
cr	equ	0dh
lf	equ	0ah
esc	equ	1bh			; Break character
;
cpos1	equ	01bh			; Cursor positioning lead in code
cpos2	equ	'='
offset	equ	020h			; Offset for vdu cursor positioioning
cscrn	equ	01ah			; Clear screen code
;
;****************************************************************
;*          start of the main program here			* 
;**************************************************************** 
;
mon:
	lxi	h,00
	dad	sp
	shld	usr$stk			; save stack pointer
;
; Signon and start the show off
	lxi	h,signon		; Go print the message
	call	ptxt
	jr	warm			; Perform a warm boot.
;
signon:
	db	cr,lf
	db	'ASMLIB Monitor'
	db	cr,lf,3
signon2:
	db	'M>'
	db	3
;
; Warm1 is the restart address after all routines are finished.
;
warm1:	
warm:
	lhld	usr$stk			; set up the stack
	sphl	
	call	crlf			; New line
	lxi	h,signon2
	call	ptxt			; Print the M> message
	call	echo			; Get character and echo it
	cpi	cr
	jrz	warm1
	cpi	lf
	jrz	warm1
	mov	c,a
	push	b			; Save character
	call	prspc			; Space across 1
	call	gaddr			; Get operands
    	pop	b
	mov	a,c			; Restore first command
	lxi	h,warm1			; Save address of re-entry
	push	h			; On stack
	lded	opr1 			; Operand 1
 	lxiy	stcktop			; Set iy to stack top
;
;****************************************************************
;*			Check key against table			*
;****************************************************************
;
	sui	'A'
	jrc	erdisp			; Incorrect command
	cpi	'Z'-'A'+1		; Only A to Z allowed.
	jrnc	erdisp
	add	a			; *2
	push	d			; Save it
	mov	e,a
	mvi	d,0			; Index into table
	lxi	h,jmptbl		; Table of routines
	dad	d			; Point to it
	mov	e,m
	inx	h
	mov	d,m
	xchg
	pop	d			; Restore
	push	h			; Load stack with routine address
	lhld	opr2
	ret				; To the routine
;
;****************************************************************
;* 		Display a ? for an error prompt			*
;****************************************************************
;
erdisp:
	mvi	a,'?'			; ? = illegal data
	call	coe
	jmp	warm1			; Re-enter monitor
;
;****************************************************************
; Display memory as if it were a page of text. Hex data is not  *
; displayed, it is converted into a '.' to be comaptible with   *
; the dump command.						*
;****************************************************************
;
adump:
	lda	opcnt
	ora	a
	jz	erdisp			; No operands cause an error
	cpi	1			; 1 operand gives a screen full
	jrz	scrnful
; Display from start to a finish. Start is in de, finish in hl
	call	rngchk			; Check end is after the start
	lhld	opr2			; Re-load ending address if ok.
adump1:
	push	h			; Save ending address
	ldax	d			; Get the character
	call	makasc			; make it ascii into C
	mov	a,c
	call	coe
	inx	d			; Bump memory source address
	ora	a			; Clear carry
	dsbc	d			; Subtract current address from end 
	pop	h			; Restore the ending address
	jrnz	adump1			; When equal, next page is asked for
;
; Here we read the console for an escape or a space
adwait:	; Wait for a legitimate ascii dump command
	call	cie
	cpi	01bh
	jz	warm1
	cpi	' '			; next K ?
	jrz	adump2
	cpi	'^'			; Previous K ?
	jrz	adump3
	cpi	'?'			; Do you want to know the address ??
	jrnz	adwait			; If not this then keep on waiting
	call	prhl			; Print the current ending address
	jr	adwait			; Wait on Norelle, all things come....
;
adump2:	; Add the standard screen display amount to the end address
	lxi	b,1024			; Dsiplay the next 1k
	dad	b			; End address is now 1k on
	call	crlf
	jr	adump1
;
adump3:	; Display the previous k to the one on the screen
	ora	a			; Clear carry
	lxi	b,2048			; A sort of double back up is required
	dsbc	b			; HL & DE point to 2 k back
	push	h
	pop	d			; Copy end into start
	jr	adump2			; Load the new end address
;
; Here the user entered only one operand so he wants a standard screenfull
scrnful:
	push	d
	pop	h			; Copy start address into end
	jr	adump2
;
;****************************************************************
; 	Execute a program at an optional address		*
;****************************************************************
;
go:	lda	opcnt 			; See if operands entered
	ana	a
	jrz	go1			; Use last given address
	sded	temp8
go1:
	lhld	temp8
	pchl				; Start execution at the address
;
;****************************************************************
;*		Block move memory routine			*
;****************************************************************
;
move:	call	rngchk			; See that end > start
	mov	b,h
	mov	c,l			; Bc = count of bytes
	xchg		
	lded	opr3			; Get destination
	ora	a
	dsbc	d			; Check no everlay
	jrnc	move2			; Skip if likely
	lhld	opr3			; Get back dest
	dad	b			; Add to byte count
	dcx	h			; Less 1
	mov	d,h
	mov	e,l			; Copy to de
	lhld	opr2			; Get end
	lddr				; Fill backwards
	ret
;
move2:	lhld	opr1			; Forward block move
	ldir
move1:	ret
;
;****************************************************************
;*		This is the hexadecimal calculator		*
;****************************************************************
;
hexad:	
	push	h
	dad	d			; Add opr1 and opr2
	mvi	a,'+' 			; Display sum
	call	coe
	call	prhl			; Display contents hl
	call	prspc			; Space
	pop	h			; Restore opr2
	xchg				; Swap opr1 and opr2
	ora	a			; Clear flags
	dsbc	d			; Subtract other way
	mvi	a,'-' 
	call	coe			; Display difference
	call	prhl
	ret				; Return to warm1
;
;****************************************************************
;*		Exam port contents				*
;*		cmd => i pp (x) where x means forever		*
;****************************************************************
;
portin:
	resy	0,12
	lda	opr1			; Get port number
	mov	c,a			; Into reg c
	mvi	b,1			; Default count
	lda	opcnt			; How many operands
	cpi	2			; 2 ?
	jrc	porti1			; Skip if less
	lda	opr2			; Get operand 2 (no.Displays)
	mov	b,a			; To reg b
	ora	a			; See if zero
	jrnz	porti1			; Skip if not
	sety	0,12 			; Set flag
porti1:	mov	a,c			; Get back port no.
	call	pracc			; Display port no.+ space
	inp	a
	call	pracc			; Go display value
	call	chkabrt			; See if abort pressed
	push	b
	call	crlf			; New line
	pop	b
	bity	0,12			; See if continuos or loop count
	jrnz	porti1			; Loop if not
	djnz	porti1			; Count - 1
	ret
;
;****************************************************************
;*		Output a value to a port			*
;*		cmd => o pp (xx) (yy)				*
;*	xx= data yy = optional count, 0 = forever		*
;****************************************************************
;
portout:
	resy	0,12			; Reset continous flag
	lda	opr1			; Get port no.
	mov	c,a			; To c
	lda	opr2			; Get data
	mov	d,a			; Into d
	mvi	b,1			; Default count = 1
	lda	opcnt			; See how many operands
	cpi	3
	jrc	pout1			; Skip if < 3
	lda	opr3			; Get loop count
	mov	b,a			; Into reg b
	ora	a			; See if zero
	jrnz	pout1			; Skip if not
	sety	0,12			; Set continuous flag
pout1:	outp	d			; Send data
	call	chkabrt			; See if abort wanted
	bity	0,12			; Test for continuous
	jrnz	pout1			; Skip if yes
	djnz	pout1			; Counter - 1
	ret
;
;****************************************************************
;*		Fill memory with data				*
;*		cmd => f ssss ffff dd				*
;****************************************************************
;
fill:	lda	opr3			; Get data to fill with
	push	h			; Save hl
	call	rngchk			; Check de < hl
	pop	h
fill1:	stax	d			; Save data
	push	h
	ora	a			; Clear flags leave acc.
	dsbc	d			; See if address match
	pop	h			; Restore end address
	inx	d			; Next location
	jrnz	fill1			; Skip if no match
	ret
;
;****************************************************************
;*		Locate a string in memory			*
;*		cmd => l ssss ffff b1 b2 b3... B5		*
;****************************************************************
;
locat:	
	call	rngchk			; Make sure end > start
	lda	opcnt			; How many operands
	sui	3			; Subtract 3
	jc	erdisp			; Error 3 minimum
	mov	b,a			; Save difference
	inr	a			; Add 1
	sta	opcnt   		; Save operand count
	lxi	h,opr4-1
	lxi	d,opr4
locat1:	ldax	d			; Get data
	mov	m,a			; Save it
	inx	h			; Next location
	inx	d
	inx	d
	djnz	locat1			; Loop till all operands crushed
locat2:	lda	opcnt
	mov	b,a			; Save opcount
	lhld	opr1			; Get start address
	lxi	d,opr3
locat3:	ldax	d			; Get operand
	cmp	m			; Compare to memory
	jrnz	locat4			; Skip if no match
	inx	h			; Next memory location
	inx	d			; Next operand
	djnz	locat3			; Opcount - 1
	lhld	opr1
	call	prhl			; Memory address
	call	crlf			; New line
	call	chkabrt			; See if abort wanted
locat4:	lhld	opr2			; Get end address
	lded	opr1 			; Get start address
	ora	a
	dsbc	d			; Compare them
	rz				; If same, exit
	inx	d			; Next location
	sded	opr1    		; Update start address
	jr	locat2			; Loop around
;
;****************************************************************
;*		Verify 2 blocks of memory			*
;*		cmd => v ssss ffff ssss				*
;****************************************************************
;
verify:	
	call	rngchk			; Check start and end address
	push	h			; Save difference
	pop	b			; Count into bc
	xchg				; Swap start and end
	lded	opr3 			; Get destination block
verif1:	ldax	d			; Byte from dest
	cci				; Block compare with increment
	inx	d			; Next locat for test
	jrnz	verif2			; If no match skip
	rpo				; End of compare, exit
	jr	verif1			; Loop
;
verif2:	push	psw			; No match
	push	b
	push	d			; Save all regs
	dcx	h			; Go back one location
	call	prhl			; Display pointer
	mov	a,m			; Get contents
	inx	h			; Increment pointer
	call	pracc			; Print value
	pop	d
	push	d
	push	h
	xchg				; Get dest block
	dcx	h			; Back one
	call	prhl			; Print pointer
	mov	a,m			; Get data
	call	prhex			; Display it also
	call	crlf			; New line
	pop	h
	pop	d
	pop	b
	pop	psw			; Restore regs
	rpo
	call	chkabrt			; Test for abort key
	jr	verif1			; Then loop
;
;****************************************************************
;*		Test memory for errors				*
;*		cmd => t ssss ffff				*
;****************************************************************
;
mtest:	
	xchg				; Swap start and end
	inx	d			; De = start+1
	mvi	b,0			; Count = 256
mtest1:	lhld	opr1			; Get start address
mtest2:	mov	a,l
	xra	h			; Compare to h
	xra	b			; Then count
	mov	m,a			; Save in memory (auto change)
	inx	h			; Next location
	push	h			; Save pointer
	ora	a			; Clear flags
	dsbc	d			; Start - dest
	pop	h			; Restore pointer
	jrnz	mtest2			; Loop if not finished
	lhld	opr1			; Get back start address
mtest3:	mov	a,l
	xra	h
	xra	b			; Reconstruct data to test
	cmp	m
	cnz	mtest4			; If no match, display error
	inx	h			; Next loc
	push	h			; Save it
	ora	a
	dsbc	d			; See if end of test
	pop	h
	jrnz	mtest3			; Skip if not
	inr	b			; Bit count done
	call	chkabrt			; See if abort wanted
	mvi	a,'P'			; Indicate 1 pass
	call	coe
	jr	mtest1			; Loop to restart
;
mtest4:	push	psw			; Save test byte
	call	prhl			; Print address
	pop	psw
	call	pracc			; Print test byte
	mov	a,m			; Get invalid data
	call	pracc			; Print it also
	jmp	crlf			; Display crlf, then return
;
;****************************************************************
;*		Dump memory contents				*
;*		cmd => d ssss ffff				*
;****************************************************************
;
dump:	resy	0,12			; Reset flag
	xchg				; Swap operands hl = start now
	lda	opcnt			; Get count
	cpi	2			; See if < 2
	jrnc	dump2			; Skip if so
dump1:	lxi	d,255			; Number of bytes per screen
	push	h			; Start saved
	dad	d			; Add to block
	shld	opr2			; Save as end address
	pop	h			; Restore start address
dump2:	call	crlf			; New line
	push	h
	pop	b			; Get into bc
	push	h
	lhld	opr2			; Hl = end address
	ora	a
	dsbc	b			; Find difference
	jc	erdisp			; If range wrong, error
	lxi	b,15			; Characters per line
	ora	a
	dsbc	b			; Subtract
	mvi	b,16
	jrz	dump3			; End of line
	jrnc	dump4
	mov	a,l
	add	b
	mov	b,a
dump3:	sety	0,12
dump4:	pop	h
	push	b
	call	prhl2			; Print pointer address
	pop	b
	call	dump6			; Do the display
	call	chkabrt			; See if abort wanted
	bity	0,12
	jrz	dump2
dump5:	
	call	cie			; get a character
	cpi	01bh
	jz	warm1
; Note that no echo done of any character entered. This is intentional
	cpi	'^'			; Display last page ?
	jrz	dump7
	cpi	'-'			; Display one whole K ago ?
	jrz	dump8			
	cpi	'+'			; Display next K ?
	jrz	dump9			
	cpi	' '			; Space = continue
	jrnz	dump5			; Loop till it is
dump10:
	resy	0,12			; Reset screen flag
	call	crlf			; New line
	jr	dump1			; Loop round
;
dump8:
	ora	a			; Clear carry
	lxi	d,512+256		; Allow to back up 1024 bytes
	dsbc	d			; by flowing into dump7
;
dump7:
	ora	a			; Clear carry
	lxi	d,512			; Do a double back up
	dsbc	d
	jr	dump10
;
dump9:
	lxi	d,1024-256		; One K from start of last display
	dad	d
	jr	dump10
;
dump6:	push	b
	push	h
;
pbiny:	mov	a,m
	call	pracc
	call	prsep			; Check for a separator in line middle
	inx	h
	djnz	pbiny			; Print the hex values
	call	prspc
	call	prspc
	pop	h
	pop	b
;
pasci:	mov	a,m			; Print the ascii contents
	inx	h			; Bump memory pointer
	call	makasc
	mov	a,c
	call	coe
	djnz	pasci
	ret
;
; Here the character in A is converted into ascii or is given a '.' if 
; hex. The result is put into c for easy access via coe.
;
makasc:
	ani	07fh			; Make in the range
	mov	c,a
	cpi	020h			; Lower than a space is illegal
	jrc	noasc			; Not ascii
	cpi	07bh			; Higher than upper case is illegal too
	rc				; return with ascii character in C
noasc:	mvi	c,02eh			; Replace with a '.'
	ret
;
;****************************************************************
;*		Examine / alter memory locations		*
;*		cmd => e llll (xx)				*
;****************************************************************
;
exmem:	
	xchg				; Hl gets start
exmem1:	call	prhl			; Display pointer
	mov	a,m			; Get byte
	call	prhex			; Print hex value
	mvi	a,'-'
	call	coe			; Then marker
	push	h
	call	gaddr			; Get data from user
	pop	h
	lda	opcnt			; Get bytes entered
	ani	3
	jrz	exmem3			; If none, skip
	lda	opr1			; Get data
	mov	m,a			; Copy to memory
	inx	h			; Next location
	lda	lastchr
	cpi	00dh			; Was it a carriage ret ?
	jrz	exmem1			; Skip if so
exmem2:	dcx	h			; Restore pointer
	jr	exmem1			; Loop
;
exmem3:	lda	lastchr			; Get back last char
	cpi	'^'			; Was it an up-carrot
	jrz	exmem2			; If so, stay on this location
	inx	h			; Else next location
	jr	exmem1			; Loop around
;
;****************************************************************
;*		Port examine / modify command			*
;*		cmd => p pp 					*
;****************************************************************
;
port:	; See if display whole port space
	lda	lastchr			; Get the character
	cpi	'^'			; Carrot causes whole page
	jrz	pmap
	cpi	'&'
	jrnz	porta
; Do a repeated port map display with cursor positioning. An escape ends it.
cport:
	mvi	a,cscrn			; Erase screen code
	call	coe
cport1:
; DO a cursor position to line 5 column 1
	mvi	a,cpos1			; First cursor position code
	call	coe
	mvi	a,cpos2			; Second cursor position code
	call	coe
	mvi	a,3+offset		; Row + offset first
	call	coe
	mvi	a,1+offset		; Column next
	call	coe
	call	pmap			; Display the port map
	jr	cport1
;
pmap:
; This section causes the whole port address space to be displayed
	mvi	e,16			; Number of 16 port lines
	mvi	c,00			; Start at port 00
pm1:
	mvi	b,16			; 16 ports per line displayed
	mov	l,c			; Get start port #
	mvi	h,00
	push	b
	call	crlf			; Space apart
	call	prhl2			; Print port #
	pop	b
pm2:
	inp	a			; Get the port from (c)
	push	b			; Save the counters
	call	pracc			; Print a port & a space
	call	prsep			; Check if we need a line separator
	call	chkabrt			; Detect if we need to quit-a-motto
	pop	b
	inr	c			; Next port next time
	djnz	pm2
; Detect if all lines have been sent to screen ( = all ports done)
	dcr	e			; Decrement line counter
	mov	a,e
	ora	a			; End of the lines ?
	jrnz	pm1
	ret
;
porta:
	lda	opr1			; Get port no
	mov	c,a			; Into c
port1:	mov	a,c			; Get back port no
	call	pracc			; Display it
	inp	a			; Get contents
	call	pracc			; Print also
	push	b
	call	gaddr			; See if data to be altered
	pop	b
	lda	lastchr			; Get character entered
	mov	h,a
	lda	opcnt			; Get opcount
	ana	a
	jrz	port3			; If none, skip
	lda	opr1
	outp	a			; Send data out
	mvi	a,'^'			; Test for carrot
	cmp	h
	jrz	port1			; Skip if so
port2:	inr	c			; Next port number
	jr	port1			; Loop
;
port3:	mvi	a,'^'
	cmp	h
	jrnz	port2			; Skip if not carrot
	dcr	c			; Port no.- 1
	jr	port1
;
;****************************************************************
; 		Quit the monitor				*
;****************************************************************
;
quit:
	lhld	usr$stk
	sphl
	ret
;
;****************************************************************
;      Select a memory bank using port 0ffh			*	
;****************************************************************
;
bank:
	lda	opcnt
	cpi	1
	jnz	warm1			; Only one operand allowed
	lda	opr1			; Get port no
	out	0ffh			; set bank
	jmp	warm

;****************************************************************
;      Enter a string into memory at opr1 till an escape.       *	
;****************************************************************
;
string:
	lda	opcnt
	cpi	1
	jnz	warm1			; Only one operand allowed
	xchg				; Put the destination address in hl
; Do a crlf then enter text till a control Z
	lxi	d,00			; Set up a character counter
string1:
	call	cie			; Get a character
	cpi	01ah			; Control Z
	jz	string2			; End of the command.
	mov	m,a			; Put into memory
	call	coe			; Echo to screen
	inx	h
	inx	d			; Bump pointers
	jr	string1
string2:	; Here when the user has had enough and entered a control Z
	call	crlf
	xchg				; Put character counter into hl
	mvi	a,'>'
	call	coe
	call	prhl			; Print the number of characters
	jmp	warm			; Process next command
;
;****************************************************************
;*	Clock routines to set and clear the clock registers	*
;****************************************************************
;
clock:	lxi	h,clkstrg		; Clock string
	lda	opcnt
	ora	a			; See if set/display
	jrz	readit
;
writit:	cpi	7			; Should be 7 operands (0-6)
	jc	erdisp			; Error not enough
	lxi	d,opr1
	mvi	b,7
writ0:	ldax	d
	mov	m,a
	inx	d
	inx	d
	inx	h
	djnz	writ0
	lxi	d,clkstrg
	call	clkwr			; Go write clock
	ret
;
readit:
	lxi	d,clkstrg
	call	clkrd			; Go read clock string
	lxix	clkstrg			; Point to it
	ldx	a,2
	call	prhex			; Print date
	mvi	a,'-'
	call	coe
	ldx	a,1
	call	prhex
	mvi	a,'-'
	call	coe
	ldx	a,0
	call	pracc			; Print year
	call	prspc			; And extra space
	ldx	a,4			; Skip to hours
	call	prhex
	mvi	a,':'
	call	coe
	ldx	a,5
	call	prhex
	mvi	a,':'
	call	coe
	ldx	a,6
	call	prhex
	call	crlf
	ret
;
chkabrt:	; Detect if the user wanted to quit or not
	call	cst			; See if abort pressed
	rz				; Return if no character pending
	call	cie			; Get the character, conin handles esc
	cpi	01bh
	jz	warm1
	cpi	'.'
	jz	warm1
	ret
;
;****************************************************************
;*		See if de less than hl				*
;****************************************************************
;
rngchk:	ora	a			; Clear flags
	dsbc	d
	jc	erdisp
	inx	h
	ret
;
pracc:	push	b
	call	prhex
	call	prspc
	pop	b
	ret
;
crlf:	mvi	a,00dh
	call	coe
	mvi	a,10
	jmp	coe
;
prspc:	mvi	a,' '
	jmp	coe
;
ptxt:	mov	a,m
	cpi	003h
	rz	
	call	coe
	inx	h
	jr	ptxt
;
prhex:	push	psw
	rrc
	rrc
	rrc
	rrc
	call	phex1
	pop	psw
phex1:	ani	00fh
	adi	090h
	daa
	aci	040h
	daa
	jmp	coe
;
makhex:	sui	'0'			; Remove ascii bias
	cpi	10			; If 0 - 9, return
	rm
	sui	7			; Else make a - f = 10 - 15
	ret
;
valnum:	cpi	'0'
	jrc	valbad			; Check = '0' - '9'
	cpi	'9'+1
	jrc	valnok
	cpi	'A'-1			; Check = 'A' - 'F'
	jrc	valbad
	cpi	'G'
	jrnc	valbad
valnok:	xra	a			; Set zero flag for good exit
	ret
;
valbad:	xra	a			; Set acc = 1
	inr	a
	ret
;
;****************************************************************
;*		Checks for end of numeric entry			*
;****************************************************************
;
valdm:	cpi	' '			; valid delim
	rz	
	cpi	'^'			; Alternate code for cr (*)
	jrz	valdm1
	cpi	'&'			; This is allowed for cont' commands
	jrz	valdm1
	cpi	cr			; End of command
	rnz				; Exit if not a one of these
;
valdm1:	push	b			; Save counters etc
	call	crlf			; Issue a carriage return
	pop	b
	xra	a			; Set zero flag = valid delim
	ret
;
ghex:
	lxi	h,00
	mov	b,l
ghex1:
	call	echo
	inr	b
	call	valdm
	rz
	call	valnum
	rnz
	mov	a,c
	call	makhex
	dad	h
	dad	h
	dad	h
	dad	h
	add	l			; add in lower digit
	mov	l,a			; put back in
	jr	ghex1
;
echo:	call	cie
	ani	07fh
	cpi	'a'			; Ensure in upper case
	jrc	noconv
	cpi	'z'+1
	jrnc	noconv
	ani	05fh
noconv:
	mov	c,a			; save
	call	coe			; echo to console converted
	ret
;
;****************************************************************
;*	Collect up to 9 bytes of numeric data			*
;*	separated by spaces if entered				*
;****************************************************************
;
gaddr:
	xra	a
	lxi	h,opr1
	push	h
	popix
	mov	m,a
	lxi	b,13
	lxi	d,opr1+1
	ldir				; Clear 13 bytes of ram
	sta	opcnt
;
gaddr1:
	call	ghex
	jnz	erdisp
	mov	a,c
	sta	lastchr
	cpi	' '
	jrz	gaddr2
	dcr	b
	rz
gaddr2:
	stx	l,000h
	stx	h,001h
	lda	opcnt
	inr	a
	sta	opcnt
	inxix
	inxix
	mov	a,c
	cpi	' '
	jrz	gaddr1
	ret
;
prhl:	mov	a,h
	call	prhex
	mov	a,l
	jmp	pracc
;
prhl2:	; Print contents of hl and also extra spaces 
	call	prhl	
	jr	prsep2			; Send an additional space
;
prsep:	; If b = 8 then print a '- ' else return
	mov	a,b
	cpi	9			; Already done 8 characters ??
	rnz				; Return if not at exact match
	mvi	a,'-'
	call	coe
prsep2:
	jmp	prspc			; Print a space
;
;****************************************************************
;*		Printer output routine				*
;****************************************************************
;
poe:	
	mov	a,c
	jmp	loe
;
;************************************************
;*	Table of routines for indirect jump	*
;************************************************
;
jmptbl:
	dw	adump			; A Ascii display of memory
	dw	bank			; B Set memory bank using port 0FFh
	dw	erdisp			; error
	dw	dump			; D display memory
	dw	exmem			; E examine memory
	dw	fill			; F fill memory
	dw	go			; G go to program
	dw	hexad			; H hex sum and difference
	dw	portin			; I input from port
	dw	erdisp			; J
	dw	clock			; K read/write clock
	dw	locat			; L locate string
	dw	move			; M move memory
	dw	erdisp			; N
	dw	portout			; O output to a port
	dw	port			; P examine port
	dw	quit  			; quit this monitor
	dw	erdisp			; error
	dw	exmem			; S Substitute memory duplicate
	dw	mtest			; T test ram
	dw	string			; U User the console for writing to ram
	dw	verify			; V verify ram
	dw	erdisp			; error
	dw	erdisp			; X
	dw	erdisp			; error
	dw	erdisp			; error
;
	dseg
;
	ds	10
stcktop
	ds	10
opcnt	db	00
lastchr	db	00
opr1	db	00,00
opr2	db	00,00
opr3	db	00,00
opr4	db	00,00
opr5	db	00,00
opr6	db	00,00
opr7	db	00,00
temp2	db	00,00
temp6	db	00,00
temp8	db	00,00
clkstrg	db	0,0,0,0,0,0,0
usr$stk	db	00,00
;
	end


