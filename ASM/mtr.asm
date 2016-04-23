;----------------------------------------------------------------
; This program tests the DRC-II card. It tests all 4 banks of 64 k.
;
; Since this program uses the ASMLIB library, it is easily modified and
; added to. All the rouines and code have been written as simply and as
; linearly as possible to allow mods and additions.
;
;			Written		R.C.H.        19/01/84
;			Last Update	R.C.H.        19/01/84
;----------------------------------------------------------------
;
;		ASMLIB library routine names
;
	extrn	prolog,nibasc,pdacc,dispatch,inline
	extrn	quit,listout,consout,crlf,clear
	extrn	pdde,delay,cst,bell,cie,coe,caps
	extrn	randinit,rand8,pmenu,phde,hexasc,phacc
	extrn	xyinline,setxy,atoasc
	extrn	ionum,tname,pstring,cursor,pstr
	extrn	setatt,ramwbt,rambpt
	extrn	lzb,nolzb,blzb,clkrd
;
	maclib	z80
;
; Memory test variables
;
t9t1	equ	50000			; interrupts iteration size
t9t2	equ	500   			; port addressing iteration size
t9t3	equ	1			; walking bit iteration size
t9t4	equ	1			; barber pole test iteration size
t9t5	equ	05   			; ldir / lddr iteration test size
ctc0	equ	08ch
ctc1	equ	ctc0+1
ctc2	equ	ctc0+2
ctc3	equ	ctc0+3
bnk$max	equ	3			; test banks 00,01,02,03
mstart	equ	00000h			; test memory ending at
mend	equ	0bfffh			; test memory starting at
;
super$start:
	call	prolog
	jmp	start
	nop
	nop				; make on an 8 address boundary
;
; This is the interupt interrupt table that must start on an address
; boundary of 8
;
vectors:
	dw	int0
	dw	int1
	dw	int2
	dw	int3			; interrupt address vectors
;
start:
; Initializations
; Clear all the ram storage areas used by this test
	lxi	h,sram
	mvi	m,00
	mov	e,l
	mov	d,h
	inx	d			; bump for the destination
	lxi	b,eram-sram-1		; the size
	ldir
;
	mvi	a,bnk$max		; indicate maximum bank
	sta	t9$bnk
	call	sel$bnk			; force a select and display of bank 0
;
; shift initialized random number seed to the real seed.
	lxi	h,iseed
	lxi	d,seed
	lxi	b,6
	ldir				; shift the initialized seed
;
;----------------------------------------------------------------
; The DRC-II is tested by the following things.
;
; 1) Fast interrupts from a CTC on SBC-800. This can cause problems
;    if DRC-II decoding and refresf circuitry is faulty.
; 2) Port decoding by quickly writing to ports F0..FE to check for
;    a faulty port decoder chip of excess glitches on the bus.
; 3) Walking bit test up memory and down memory.
; 4) Barber pole memory test up and down memory.
; 5) Test with a repeated number of LDIR Z-80 instructions.
; 6) Test with a number of LDDR instructions.
;
; These tests are meant to be the most demanding that the DRC-II can
; ever experience. This is meant to show up marginal boards.
;----------------------------------------------------------------
;
	call	clear
	call	t9$overlay		; display the overlay
	lxi	d,140bh
	sded	cur$cur			; save the current cursor address
	call	cursor			; set up
	mvi	a,'*'
	call	dispatch
	xra	a
	sta	t9$no			; save the test number as 00
;
test9$start:
	lded	cur$cur
	call	cursor			; reset to the current cursor position
	call	do$test9		; do the actual test
;
; 	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; This section must bump the number of loops counter
; then must display it on the screen.
; When all tests have been done for a bank, the next bank must be selected
; and dislayed on the screen.
; After this it must move the test indicator star to the next
; test in the loop.
;
	lded	cur$cur
	push	d			; save for later use
	mov	a,d			; get X value
	adi	16			; point to the loop counter x value
	mov	d,a			; save back
	call	cursor			; set it up
; Get the loop value, bump, save, write
	lda	t9$no			; get test 9 test number, 0..4
	lxi	h,t9$loops		; point to the loop counters
	mov	e,a
	mvi	d,00			; use t9$no to index into loop values
	dad	d
	dad	d			; Now HL -> an individual loop value
	mov	e,m
	inx	h
	mov	d,m
	inx	d			; Bump the value
	mov	m,d			; save
	dcx	h
	mov	m,e			; save all
; DE = loops done
	call	pdde			; print as a decimal
;
; Move the test indicator star.
	pop	d			; restore cursor address
	call	cursor			; set up
	mvi	a,' '
	call	dispatch		; clear it
; Go to the next test position.
	lded	cur$cur
	mov	a,e			; get y address
	cpi	19			; last ??
	jrz	t9$restart
	inr	e
	inr	e			; points to next test
; Bump the test number
	lda	t9$no
	inr	a			; indicate next test in progress
	jr	t9$restart$over
t9$restart:
	lxi	d,140bh
	xra	a			; re-set to test number 00
t9$restart$over:
	sta	t9$no			; save the test number
	push	psw
	sded	cur$cur			; save the address
	call	cursor			; set the cursor
	mvi	a,'*'
	call	dispatch
; Select the next bank to be tested
	pop	psw
	ora	a			; bank zero again ??
	cz	sel$bnk			; select next bank then
; Now check for the end of tests.
;
	call	chk$abrt
	jmp	test9$start
;
chk$abrt:
	call	cst
	rz				; 00 = No character there
	call	cie			; Else we get the typed character
	pop	h			; clear the stack
;
	call	inline
	db	0dh,0ah,'Bye$'
	jmp	0e000h			; jump to monitor warm start
;
; This routine must select a memory bank in the range 0..3. The bank
; number is saved in t9$bnk and used for display when an error happens
; also the number is used to increment to get the actual bank number.
;
sel$bnk:
	lxi	d,01906h		; line 6, col 25
	call	cursor			; set the cursor up
; Now get the last bank number and send it.
	lda	t9$bnk			; check if > maximum
	cpi	bnk$max  		; too far ??
	jrnz	sel$bnk1
	mvi	a,0ffh			; use bank 00 next time
sel$bnk1$
	inr	a			; get the next bank for testing
	sta	t9$bnk
 	out	0ffh			; send it
	call	lzb
	call	phacc			; display the bank number
	call	blzb			; display standard
	ret
;
; This is the actual memory testing section
; This decodes the test that must be done then jumps to it.
; A return is done from the test if all is well else the test
; will jump to test9$fail for an error.
;
do$test9:
	lxi	h,test9$table
	lda	t9$no			; get the test number
	mov	e,a
	mvi	d,00
	dad	d
	dad	d			; Now HL -> and address to go to
	mov	e,m			; get low address
	inx	h
	mov	d,m			; get high address
	push	d			; put address on stack
	ret				; goto the address
;
test9$table:	; A table of routine addresses
	dw	test9$test1		; Interrupts
	dw	test9$test2		; Port decoding
	dw	test9$test3		; Walking Bit
	dw	test9$test4		; Barber pole
	dw	test9$test5		; LDIR / LDDR
;
;----------------~~~~~~~~~~~~~~~~----------------
;    The memory test routines
;~~~~~~~~~~~~~~~~----------------~~~~~~~~~~~~~~~~
;
; Do an interrupt response test. This initializes the
; SBC-800 CTC channel 3 for fast interrupts then counts for
; the iteration size to complete the test. When done the interrupts
; are disabled.
; If no SBC-800 there then this test returns immediately.
;
;
test9$test1:
; Fill memory with a random value.
	lxi	d,seed
	call	randinit		; initialize random number generator
	lxi	d,seed
	call	rand8
	lhld	mem$start
	mov	m,a			; send the byte into ram
	mov	e,l
	mov	d,h			; get a copy
	inx	d			; point to next byte in ram
	lbcd	mem$size		; get memory size
	ldir				; fill memory.
; 
; Now we start the Interrupt test by enabling interrupts on CTC channel 3
;
; Set up interrupt vectors.
	lxi	h,t9t1			; get iteration size
	shld	int$count		; clear the interrupt counter
	lxi	d,vectors
	mov	a,e			; low 8 bits of address
	out	ctc0			; send. This is accepted as a vector
	mov	a,d			; high 8 bits
	stai				; put into interrupt register of Z80
; Initialize the CTC for interrupts on channel 3 only
	mvi	a,085h			; timer mode with interrupts
	out	ctc3			; in timer mode, clk is from the bus
	mvi	a,20			; count down value
	out	ctc3			; put in the value
	im2				; enable interrupts NOW
	ei
;
; Perform wait till int$count = 00 and exit then.
;
t9t1$loop:
	lhld	int$count
	mov	a,h
	ora	l			; H = L = 0 ??
	jnz	t9t1$loop
	jmp	stop$ctc
;
; These are the interrupt service routines
int0:
int1:
int2:
	call	stop$ctc		; stop the CTC
	call	inline			; display a message now
	db	0dh,0ah,'SBC-800 Illegal Interrupt$'
	ret				; return to the main loop
;
int3:
	lhld	int$count
	dcx	h
	shld	int$count
; Check if this is the end of the cycle
	mov	a,l
	ora	h			; does H = L = 00 ??
	jz	stop$ctc
; If not a stop then keep on.
	ei				; re-enable interrupts
	reti				; return from interrupt
;
stop$ctc:	; Clear the CTC 
	di				; stop interrupts
	call	dumret
	mvi	a,2
	out	ctc3			; stop the timer NOW
	mvi	a,45			; tell it a time constant follows
	out	ctc3
	mvi	a,13			; the constant
	out	ctc3			; this starts it counting ONLY
	ei				; re-enable interrupts for any pending
;
; Since we have stopped the CTC , now we can check if memory got corrupted
; while the interrupts were enabled and running.
;
	lhld	mem$start
	lbcd	mem$size		; load registers
	dcx	b			; check 1 byte less
;
t1$chk$loop:
	mov	a,m			; get current byte
	inx	h			; point to next byte
	cmp	m			; does m(HL) = m(HL+1) ??
	jnz	test9$fail		; on a fail, print again.
	dcx	b
	mov	a,c
	ora	b			; does B = C = 00 ??
	jnz	t1$chk$loop		; loop till BC = 0
; Clear the check symbol
	ret
;
dumret:
	reti				; clear pending CTC status
;
;
; ~~~~~~~~~~~~~~~~----------------~~~~~~~~~~~~~~~~
; This test does many output instructions to port addresses close to the
; bank select port of the DRC-II in the hope that this will trigger the 
; DRC-II to glitch and de-select itself. This is usually caused by faulty
; port decoding logic.
; ports user are f0..fe
; ----------------~~~~~~~~~~~~~~~~----------------
;
test9$test2:
	lxi	h,t9t2			; port iteration size
test9$test2$loop:
	call	chk$abrt		; look for a key press
	push	h			; save loop counter
	mvi	b,0eh			; number of ports
	mvi	c,0f0h			; start port address
port$loop:
	call	send$port		; send port (HL) times
	call	chk$abrt		; look for an exit command
	inr	c
	djnz	port$loop
; Check for end of tests
	pop	h			; restore counter
	dcx	h
	mov	a,l
	ora	h			; see if H = L = 0 ???
	jrnz	test9$test2$loop
	ret				; keep on till done
;
; Now the subroutine
send$port:
	push	b			; save
	mvi	b,255			; loop size
	outir				; send m(HL) -> p(C) for (B) times
	pop	b
	ret
;
; This is the walking bit test. This is taken from the
; ASMLIB library which is a routine by Leventhals' book 'Z-80 Subroutines'
;
test9$test3:
	lxi	b,t9t3			; number of loops
; the loop. Load registers, call the routine, exit if an error.
test9$test3$loop:
	push	b			; save it
	call	chk$abrt
	lded	mem$start		; start of memory
	lhld	mem$end			; end of memory
	call	ramwbt			; do the test
	pop	b
	jc	test9$fail 		; error exit if a failure.
	dcx	b
	mov	a,c
	ora	b			; does B = C = 00 ????
	jrnz	test9$test3$loop
	ret				; do a return when all loop pass
;
; ~~~~ Barber Pole Test ~~~~
;
; This is the barber pole test. This is taken from the
; ASMLIB library which is a routine by Leventhals' book 'Z-80 Subroutines'
;
test9$test4:
	lxi	b,t9t4			; number of loops
; the loop. Load registers, call the routine, exit if an error.
test9$test4$loop:
	push	b			; save it
	call	chk$abrt
	lded	mem$start		; start of memory
	lhld	mem$end			; end of memory
	call	rambpt			; do the test
	pop	b
	jc	test9$fail 		; error exit if a failure.
	dcx	b
	mov	a,c
	ora	b			; does B = C = 00 ????
	jrnz	test9$test4$loop
	ret				; do a return when all loops pass
;
; ~~~~ LDIR / LDDR test. ~~~~
; This moves a byte up and down the total available memory and then checks
; is for accuracy. On each iteration the byte is loaded from the random number
; generator so that a wide range of test values is checked. 
; Each iteration does an LDIR then a check, an LDDR then a check.
;
test9$test5:
	lxi	b,t9t5			; get the number of loops
t9t5$loop:
	push	b			; save
; Do the LDIR test first
	lxi	d,seed			; get a random number 
	call	rand8			; A = random number
	lbcd	mem$size		; get size of memory to test
	dcx	b			; one less
	lhld	mem$start		; get start address
	mov	m,a			; load the seed
	mov	e,l
	mov	d,h			; copy into DE for the destination
	inx	d			; bump by one to propogate up ram
	ldir				; do the move.
	mov	e,a			; save check value
	call	chk$abrt
	lhld	mem$start
	lbcd	mem$size
	dcx	b			; one byte less
; Now the check of the byte in memory. Use a Z-80 auto check.
	mvi	a,'I'
	call	coe
	mvi	a,8
	call	coe
t9t5$loop2:
	call	chk$abrt		; abort ????
	mov	a,e			; restore checking value
	cci				; check m(HL) = A
	jnz	t9t5$error
	mov	e,a			; save
	mov	a,c
	ora	b			; does B = C = 0 ??
	jnz	t9t5$loop2
;
; **** Now do the LDDR checking. This is done in a similar way ****
;
	lxi	d,seed			; get a random number 
	call	rand8			; A = random number
	lbcd	mem$size		; get size of memory to test
;	dcx	b			; one less
	lhld	mem$end  		; get start address
	mov	m,a			; load the seed
	mov	e,l
	mov	d,h			; copy into DE for the destination
	dcx	d			; deduct one to propogate down ram
	lddr				; do the move.
	mov	e,a			; save the check value
	call	chk$abrt
	lhld	mem$start
	lbcd	mem$size
	dcx	b			; one byte less to test
;
	mvi	a,'D'			; indicate a Decrementing test
	call	coe
	mvi	a,8			; backspace
	call	coe
; Now the check of the byte in memory. Use a Z-80 auto check.
t9t5$loop3:
	call	chk$abrt
	mov	a,e			; restore checking value
	cci				; check m(HL) = A
	jnz	t9t5$error
	mov	e,a			; save
	mov	a,c
	ora	b			; does B = C = 0 ??
	jnz	t9t5$loop3
; Decrement the iteration counter and check for end of this test.
	pop	b			; restore iteration counter
	dcx	b			; one less loop to do
	mov	a,c
	ora	b			; check if the iteration is done
	jnz	t9t5$loop
; Clear old I or D when here
	mvi	a,' '			; blank it
	call	coe
	ret				; exit if all done
;
;
t9t5$error:
	pop	b			; restore stack
	jmp	test9$fail
;
; If a test fails then this routine is called. It increments the
; fail counter, displays the value and also the address where the fail
; occurred. This is the error section.
;
; On calling here HL -> error address in memory
;
test9$fail:
	push	h			; save the failure address
; Index to the fail column
	lded	cur$cur			; get current cursor address
	mov	a,d			; get X address
	adi	23			; add 23 to get to the fail column
	mov	d,a
	call	cursor			; get there
; Now get the number of fails, bump, save, display
	lxi	h,t9$fails		; point to start of fail table
	lda	t9$no			; get the test number
	mov	e,a
	mvi	d,00			; load an index
	dad	d
	dad	d			; now HL -> fail number for this test
	mov	e,m
	inx	h
	mov	d,m			; now DE = number of fails
	inx	d			; bump
	mov	m,d
	dcx	h
	mov	m,e			; saved now
; Now display it
	call	pdde			; display as a decimal.
; Now we need to display the address where the fail occurred
	call	inline
	db	'      $'		; Use spaces to get there
	pop	d			; restore HL -> DE for display
	call	phde			; display it as hex
; Now we display the bank where it happened.
	call	inline
	db	'   bank ($'
	lda	t9$bnk			; get the bank number
	call	lzb
	call	phacc			; print it
	call	nolzb
	mvi	a,')'
	call	coe
;
; After all this, bump the total number of fails, save and then display.
	lxi	d,0d15h			; col 13, line 21
	call	cursor
	lhld	t9$total$fails
	inx	h
	shld	t9$total$fails
	xchg
	call	pdde			; display as a decimal
	call	blzb			; go back to standard blanking
	ret				; all done
;
;----------------------------------------------------------------
; Major section to display the test 9 overlay that has all the parameters 
; etc on it. This also displays the time start and a few other things to 
; improve the niceness of the program.
;----------------------------------------------------------------
;
t9$overlay:
	lxi	d,t9$menu
	call	pmenu			; display the text in one go
; Put a line under the double line test headings
	lxi	d,010ah			; col 1 , line 10
	call	cursor
	mvi	b,61			; do 61 times
	mvi	a,'-'			; send this character
	call	pstr			; print a string of characters entry
;
; Now display the iteration size values
	call	blzb			; select standard blanking
	lxi	d,1c0bh			; X=28, Y=11
	call	cursor
	lxi	d,t9t1			; first test size display
	call	pdde			; display as a decimal
;
	lxi	d,1c0dh			; X=28, Y=13
	call	cursor
	lxi	d,t9t2			; second test size display
	call	pdde			; display as a decimal
;
	lxi	d,1c0fh			; X=28, Y=15
	call	cursor
	lxi	d,t9t3			; third test size display
	call	pdde			; display as a decimal
;
	lxi	d,1c11h			; X=28, Y=17
	call	cursor
	lxi	d,t9t4			; fourth test
	call	pdde
;
	lxi	d,1c13h			; X=28, Y=19
	call	cursor
	lxi	d,t9t5			; fourth test
	call	pdde
;
; Put a line under the tests, this places them in a table
	lxi	d,0114h
	call	cursor
	mvi	a,'-'
	mvi	b,61
	call	pstr
;
; Display the time now
	lxi	d,03004h
	call	cursor
	lxi	d,tim$buf		; locate a time string buffer
	call	clkrd
;
	call	nolzb			; display time without lzb
	lda	hrs
	ani	03fh			; mask off top bits
	call	phacc
	mvi	a,':'			; a spacer
	call	dispatch
	lda	mins
	call	phacc
	mvi	a,':'
	call	dispatch
	lda	secs
	call	phacc
; Now get memory start address and save
	lxi	d,01a04h
	call	cursor
	lxi	d,mstart
	sded	mem$start		; save the start address
	call	phde			; display without LZB
; Get the memory end address, display, save then calculate the memory size 
; to be tested.
	lxi	d,01a05h
	call	cursor
; Load 0bfffh as the memory end address
	lxi	d,mend  		; memory end
	sded	mem$end
	call	phde
; Now the memory size
;	lxi	h,0bffh			; save as the memory size
	lxi	h,mend - mstart  	; memory start - end
	shld	mem$size		; save the memory size
;
	call	blzb
	ret
;
iseed	db	5,89,90,198,5,245
;
t9$menu:
	db	26,01,'Memory Test - ROM Version$'
	db	21,04,'From$'
	db	23,05,'To$'
	db	36,04,'Time Start$'
	db	38,05,'Time End$'
	db	21,06,'Bank$'
	db	03,08,'Test$'
	db	16,08,'Current  Iterations  Loops  Fails  Fail Address$'
	db	18,09,'Test      Size$'
	db	01,11,'Interrupts$'
	db	01,13,'Port Addressing$'
	db	01,15,'Walking Bit$'
	db	01,17,'Barber Pole$'
	db	01,19,'LDIR / LDDR$'
	db	01,21,'Total Fails$'
	db	01,23,'Press Any Key To Quit$'
	db	0ffh
;
	dseg
;
; Simple data atorage areas. Use the D switch in the linker
; to set these after assembly.
;
sram:					; start of ram
;
seed:	db	0,0,0,0,0,0 		; random number seed value
t9$no:	db	00			; test 9 section #
t9$bnk:	db	00			; memory board bank number
t9$loops:
	db	00,00			; section loop counter
	db	00,00			; section loop counter
	db	00,00			; section loop counter
	db	00,00			; section loop counter
	db	00,00			; section loop counter
;
t9$fails:
	db	00,00			; number of fails
	db	00,00			; number of fails
	db	00,00			; number of fails
	db	00,00			; number of fails
	db	00,00			; number of fails
;
t9$total$fails:
	db	00,00			; total number of fails
;
mem$start:
	db	00,00
;
mem$end:
	db	00,00
;
mem$size:
	db	00,00
;
int$count:
	db	00,00			; number of interrupt cycles
;
cur$cur:
	db	00,00			; current cursor position
;
tim$buf:
	db	00,00,00,00
hrs	db	00
mins	db	00
secs	db	00
;
eram:					; end of ram
;
;
	end


