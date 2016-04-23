;----------------------------------------------------------------
; This program tests some of the SME Systems boards and is used
; in the technical area for this purpose.
; The tests supported so far are.
;
; 1) Test SPC-29 PARALLEL ports
; 2) Test SPC-29 SERIAL port 1
; 3) Test SPC-29 SERIAL port 2
; 4) Test FDC-3  SERIAL port
; 5) Test SBC-800 Centronic printer port
; 6) Test SBC-800 Serial port 2
; 7) Test MPC-6 serial channels
; 8) Display ADC-32 analogue and bit channels
; 9) Tests DRC-II with interrupts, LDIR, LDDR, walking bit, barber pole,
;     bank switching and bank decoding.
;
; Since this program uses the ASMLIB library, it is easily modified and
; added to. All the rouines and code have been written as simply and as
; linearly as possible to allow mods and additions.
;
; As an aid to the user, this program checks itself and if there is any change
; in the executable portion then an error message will be reported. This is to
; detect faulty copies.
;
; Note: The MPC-6 test requires an I/O library capable of supporting it.
;       There are two such, CPMMPC and SBCMPC with iomun's of 3 and 4
;       respectively. If these are not used then this test displays an
;	error then exits back to the menu immediately. The actual name of
;       the i/o driver is displayed with the 'C' command.
;
;			Written		R.C.H.        23/11/83
;			Last Update	R.C.H.        20/02/84
;----------------------------------------------------------------
;
;		ASMLIB library routine names
;
	extrn	prolog,nibasc,pdacc,dispatch,inline
	extrn	quit,listout,consout,crlf,clear,ihhl
	extrn	pdde,delay,cst,bell,cie,coe,caps,portset
	extrn	randinit,rand8,pmenu,phde,hexasc,phacc
	extrn	clrcrc,addcrc,getcrc,xyinline,setxy,atoasc
	extrn	ionum,tname,pstring,cursor,pstr
	extrn	setatt,ramwbt,rambpt,datstart,datend
	extrn	lzb,nolzb,blzb,clkrd,getyorn
;
	maclib	z80
;
; HARDWARE EQUATES
;
; SPC-29 PARALLEL PORTS
;
data0	equ	054h
data1	equ	data0 + 1
data2	equ	data0 + 2
stat0	equ	data0 + 3
;
data3	equ	078h
data4	equ	data3 + 1
data5	equ	data3 + 2
stat1	equ	data3 + 3
;
data6	equ	098h
data7	equ	data6 + 1
data8	equ	data6 + 2
stat2	equ	data6 + 3
;
; SPC-29 SERIAL PORTS
;
spc1$st	equ	011h		
spc1$dt	equ	010h
spc2$st	equ	035h
spc2$dt	equ	034h
;
; FDC-3 equates
;
fdc3$st	equ	059h	
fdc3$dt	equ	058h
;
; SBC-800 Centronic port equates
;
cp$st1 	equ	084h
cp$st2 	equ	086h
cp$dt 	equ	085h
;
sbc$st2	equ	08bh
sbc$dt2	equ	08ah
;
; Base for logging on to MPC-6 channels
;
base	equ	0f8h
;
; ADC-32 port allocations
;
aBASE	EQU	40h
PORT0	EQU	aBASE+0
PORT1	EQU	aBASE+1
;
; Memory test equates
;
t9t1	equ	50000			; interrupts iteration size
t9t2	equ	1000   			; port addressing iteration size
t9t3	equ	1			; walking bit iteration size
t9t4	equ	1			; barber pole test iteration size
t9t5	equ	50  			; ldir / lddr iteration test size
ctc0	equ	08ch
ctc1	equ	ctc0+1
ctc2	equ	ctc0+2
ctc3	equ	ctc0+3
;
prgcrc	equ	00000h			; Program CRC for checking and display
;
; Lets go
;
start:	; Errors jump us here
	call	prolog
; Get a CRC of the program to display to the user for 3 seconds
st1:
	call	clrcrc			; clear users CRC code
; Put the program size into BC
	lxi	b,progend-st4		; get program size
	lxi	h,st4			; get program start
; Now read all bytes till BC = 0 and get the CRC code
st2:
	mov	a,m
	call	addcrc
	dcx	b			; one less byte to do later
	mov	a,b
	ora	c			; does b = c = 0
	jrz	st3
	inx	h			; point to next byte to do
	jr	st2			; keep on for all program
;
st3:
	call	clear
	call	xyinline
	db	25,10,'Program CRC = $'
	call	getcrc			; get the users CRC into HL
	xchg				; put into DE
	call	phde			; print the hex value of de
	call	xyinline
	db	25,11,'Correct CRC = $'
	lxi	d,prgcrc		; get original
	call	phde
;
	call	getcrc			; get CRC of this program again
	lxi	d,prgcrc		; get supposed correct version
; If the prgcrc = 00 then skip the next bit
	mov	a,d
	ora	a			; does D = E = 00 ??
	jz	st4			; skip the message display then
;
	mov	a,l			; else get the returned low 8 bit crc
	cmp	e
	jrnz	crc$error
	mov	a,h
	cmp	d
	jz	st4
; Here and the CRC values do not match
crc$error:
	mvi	d,20			; X screen address for error message
	mvi	e,13			; Y screen address
	call	cursor
;
	mvi	a,03
	call	setatt			; select reverse video characters
;
	call	inline
	db	07,'CRC MISMATCH - Faulty Copy$'
;
	xra	a
	call	setatt
;
; Now display the name of the I/O driver module that this has been set for
st4:
	call	xyinline
	db	19,15,'I/O Drivers are for $'
;
	call	ionum			; get the i/o driver number
	dcr	l			; make in the range 0..N
	mvi	h,00			; clear top byte
	lxi	d,names
	xchg				; DE = driver number, HL -> addresses
	dad	d
	dad	d			; add twice since WORD addresses
; Here and HL-> the address of the I/O driver name string
	mov	e,m			; low address byte
	inx	h
	mov	d,m			; high address
; Now DE -> the string to print
	call	pstring
;
; Now do a delay of 3 seconds to show the CRC
	lxi	d,3000
	call	delay			; all done 
;
;
; Jump here to do a new test
start1:
	call	clear
	lxi	d,menu
	call	pmenu
	call	cie
	call	caps
	call	coe
	cpi	'Q'			; Exit to the CP/M
	jz	quit
	cpi	'C'			; display the CRC codes ??
	jz	st1

;
	ani	07fh			; mask off parity
	cpi	'1'			; less than 1 ??
	jc	start1
	cpi	'9'+1			; greater than a 9 (maximum) ?
	jnc	start1
	sta	testno
;
	call	init			; do the initialization
	call	test
	jmp	start1
;
;
; initialize
; This routine must initialize one of the many devices that are
; possible. This is done with the TESTNO byte.
;
init:
	lda	testno
	cpi	'1'		; SPC-29 parallel ports ?
	jz	init1
	cpi	'2'		; SPC-29 serial port 1
	jz	init2
	cpi	'3'		; SPC-29 serial port 2
	jz	init3
	cpi	'4'
	jz	init4
	cpi	'5'
	jz	init5		; Centronic printer on SBC-800
	cpi	'6'
	jz	init6
	cpi	'7'
	jz	init7
	cpi	'8'
	jz	init8
	cpi	'9'
	jz	init9
; All else is not supported
	call	inline
	db	0dh,0ah,07,'NOT SUPPORTED DEVICE SELECTED$'
	lxi	d,5000
	call	delay
	pop	h		; drop the return off the stack
	jmp	start1		; exit quickly
;
;
init1:	; SET up SPC-29 parallel ports
	mvi	a,080h		; all outputs
	out	stat0
	out	stat1
	out	stat2
	ret
;
init2:	; initialize serial port 0 of SPC-29
	mvi	a,0aah		
	out	spc1$st
	mvi	a,040h
	out	spc1$st
	mvi	a,0cfh
	out	spc1$st
	mvi	a,027h
	out	spc1$st
	ret
;
init3:	; initialize serial port 2 of SPC-29
	mvi	a,0aah		
	out	spc2$st
	mvi	a,040h
	out	spc2$st
	mvi	a,0cfh
	out	spc2$st
	mvi	a,027h
	out	spc2$st
	ret
;
init4:	; initialize serial port of FDC-3
	mvi	a,0aah		
	out	fdc3$st
	mvi	a,040h
	out	fdc3$st
	mvi	a,0ceh
	out	fdc3$st
	mvi	a,027h
	out	fdc3$st
	ret
;
init5:	;Initialize the centronic printer
	ret

;
init6:	; Set up SBC-800 serial port 2 to 9600 baud
	lxi	d,in6
	call	portset
	ret
;
; Byte initialization strings
;
in6:	db	2,08Dh,045h,0Dh			; set up the ctc to / by 13dec
	db	08,08Bh,4,044h,1,0,3,0C1h,5,0EAh
	db	00
;
init7:
	ret
;
init8:
	ret
;
init9:
	ret					; no setups required for DRC-II
;
;----------------------------------------------------------------
; 			THE TESTS
;
;----------------------------------------------------------------
;
test:	; decode the users number then jump to the required test
	lda	testno
	cpi	'1'		; parallel ports on SPC-29 ??
	jz	test1
	cpi	'2'
	jz	test2		; serial port 1
	cpi	'3'
	jz	test3
	cpi	'4'
	jz	test4
	cpi	'5'
	jz	test5		; SBC-800 printer
	cpi	'6'
	jz	test6		; sbc-800 serial port 2
	cpi	'7'
	jz	test7		; test the MPC-6 serial channels
	cpi	'8'
	jz	test8		; display analogue input channels
	cpi	'9'
	jz	test9
	ret			; ignore all else
;
;----------------------------------------------------------------
; 	    THE SPC-29 PARALLEL PORT TESTER
;
; Turn on all bytes then turn off all bytes. This is done with a 1 second
; clock
;
test1:
	call	clear
	call	inline
	db	0dh,0ah,0ah,0ah
	db	0dh,0ah,'  --- PARALLEL PORT TESTER FOR SPC-29 ---'
	db	0dh,0ah
	db	0dh,0ah,'Ports must be addressed at 54h, 78h and 98h'
	db	0dh,0ah,0ah
	db	0dh,0ah,'Starting - enter a ^C to exit this test'
	db	0dh,0ah,0ah,'All leds on for 1 second$'
	mvi	a,0ffh
	call	sendall
	lxi	d,1000			; 1 second delay
	call	delay
;
	call	inline
	db	0dh,0ah,'All leds off for 1 second$'
;
	mvi	a,00h
	call	sendall
	lxi	d,1000
	call	delay
; Now strobe each light on by itself for .25 second so as to simulate the
; effect of motion.
	call	inline
	db	0dh,0ah,'Walking bit across all channels$'
;
	mvi	a,1
	mvi	b,8			; do 8 times
	lxi	d,1000			; 1.0 second delays
walkbit:
	call	sendall
	push	psw
	call	delay
	pop	psw
	add	a
	djnz	walkbit
;
	xra	a
	call	sendall			; turn all off
;
; Now walk a single bit along all the ports in each channel
;
	call	inline
	db	0dh,0ah,'Single channel sequential walking bit$'
;
	lxi	d,1000			; 1 second delay still
	mvi	a,1
	mvi	b,8			; 8 loops also
walk2:
	call	send0
	push	psw
	call	delay
	pop	psw
	add	a
	djnz	walk2
; Now do the next port(s) so as to walk the bit along
	xra	a
	call	sendall			; turn all off
	mvi	a,1
	mvi	b,8			; 8 loops also
walk3:
	call	send1
	push	psw
	call	delay
	pop	psw
	add	a
	djnz	walk3
;
; Do the last port
;
	xra	a
	call	sendall
	mvi	a,1
	mvi	b,8			; 8 loops also
walk4:
	call	send2
	push	psw
	call	delay
	pop	psw
	add	a
	djnz	walk4
; turn all bits off
	xra	a
	call	sendall
; 
; Random bits on / off for 100ms each for 10 seconds
;
	call	inline
	db	0dh,0ah,'10 Seconds of random chaff$'
	mvi	b,200			; 100 * 100 = 10 seconds
	lxi	d,seed
	call	randinit
chaff:
	push	b
	lxi	d,seed			; random number seed
	call	rand8
	call	send0
; next channel
	lxi	d,seed
	call	rand8
	call	send1
; last channel
	lxi	d,seed
	call	rand8
	call	send2
; restor delay counter
	lxi	d,50
	call	delay
	pop	b
	djnz	chaff			; loop on till all done
;
	xra	a
	call	sendall			; clear
;
asktoquit:
	call	inline
	db	0dh,0ah,'Do again ? $'
	call	cie
	call	caps
	cpi	'Y'
	jz	test1			; start again
	cpi	'N'
	ret				; back to the main loop
;
;
; All done, the following are subroutines
;
send0:
	out	data0
	out	data3
	out	data6
	jmp	send$end
;
send1:
	out	data1
	out	data4
	out	data7
	jmp	send$end
;
send2:
	out	data2
	out	data5
	out	data8
	jmp	send$end
;
sendall:
	out	data0
	out	data1
	out	data2
	out	data3
	out	data4
	out	data5
	out	data6
	out	data7
	out	data8
;
; Check of the user wants to exit this test to the menu
;
send$end:
	push	psw
	call	cst
	jrz	no$send$end
;
; Check for a control c
	call	cie			; get a key if pressed
	cpi	03			; control C ??
	jrnz	no$send$end		; ignore if not control c
 	pop	psw			; drop off the accumulator
	pop	h			; drop the test routine return address
 	ret				; return to the start loop
;
no$send$end:
	pop	psw
	ret
;
;----------------------------------------------------------------
;		TEST the SPC-29 SERIAL PORTS
;
; Tell the operator to swap top connectors and to press a return
; then print a string. After the string, go into echo mode
; and echo all characters till a control C.
; All characters entered are displayed as hex and decimal so as to
; pick a missing bit etc.
;----------------------------------------------------------------
;
test2:
	call	clear
	call	inline
	db	0dh,0ah,'Connect terminal to channel 1 of SPC-29 then'
	db	0dh,0ah,'Press the return key$'
	jmp	test$234$com
test3:
	call	clear
	call	inline
	db	0dh,0ah,'Connect terminal to channel 2 of SPC-29 then'
	db	0dh,0ah,'Press the return key$'
	jmp	test$234$com
;
test4:
	call	clear
	call	inline
	db	0dh,0ah,'Connect terminal serial channel to FDC-III then'
	db	0dh,0ah,'Press the return key$'
	jmp	test$234$com
;
test6:
	call	clear
	call	inline
	db	0dh,0ah,'Connect 9600 baud terminal to SBC-800 serial port 2'
	db	0dh,0ah,'then Press the return key$'
;
;
; All code is common now, the only difference is the I/O driver section
; which uses TESTNO to decide where to put characters.
;
test$234$com:
	call	cst
	jrz	test$234$com1
	call	cie
	cpi	03			; control C ?
	ret				; back to the main menu then
;
test$234$com1:
	call	cie$234			; get a character
	ani	07fh
	cpi	0dh			; a carriage return ?
	jrnz	test$234$com		; wait for it
;

	lxi	d,test$234$msg		; a little message for the terminal
	call	print$234
;
t234$com2:
	call	cie$234			; get a character
	ani	07fh
	cpi	03			; control C ?
	jz	exit$234		; exit 
	call	coe$234			; echo the character
	jr	t234$com2
;
exit$234:
	lxi	d,test$234$msg2
	call	print$234
exit$234$2:
	call	cie			; get system console character
	cpi	0dh
	jrnz	exit$234$2
	ret				; goto the main loop / menu
;
;
print$234:
	ldax	d
	cpi	'$'
	rz
	call	coe$234
	inx	d
	jr	print$234
;
; Get a character from one of 3 serial channels
;
cie$234:
	lda	testno
	cpi	'2'			; spc channel 1
	jrz	cie$spc1
	cpi	'3'
	jrz	cie$spc2
	cpi	'4'
	jrz	cie$fdc3
	cpi	'6'
	jrz	cie$sbc2
	ret
;
cie$spc1:
	call	cst
	jrz	cie$spc15
	call	cie
	cpi	03
	jz	cie$exit
cie$spc15:
	in	spc1$st
	ani	02			; receiver status
	jrz	cie$spc1
	in	spc1$dt			; get the data
	ret
;
;
cie$spc2:
	call	cst
	jrz	cie$spc25
	call	cie
	cpi	03
	jz	cie$exit
cie$spc25:
	in	spc2$st
	ani	02			; receiver status
	jrz	cie$spc2
	in	spc2$dt			; get the data
	ret
;
;
cie$fdc3:
	call	cst
	jrz	cie$fdc35
	call	cie
	cpi	03
	jz	cie$exit
cie$fdc35:
	in	fdc3$st
	ani	02			; receiver status
	jrz	cie$fdc3
	in	fdc3$dt			; get the data
	ret
; 
cie$sbc2:
	call	cst
	jrz	cie$sbc25
	call	cie
	cpi	03
	jz	cie$exit
cie$sbc25:
	in	sbc$st2
	ani	1
	jrz	cie$sbc2
	in	sbc$dt2
	ret
;
cie$exit:
;	pop	h			; drop off return address to test loop
	pop	h			; drop off return address to cie
	ret				; return from the test 2 3 4 6
;
;------------------------------------------------
; Put a character from one of 3 serial channels
;------------------------------------------------
coe$234:
	mov	c,a			; save the character
	lda	testno
	cpi	'2'			; spc channel 1
	jrz	coe$spc1
	cpi	'3'
	jrz	coe$spc2
	cpi	'4'
	jrz	coe$fdc3
	cpi	'6'
	jrz	coe$sbc2
	ret
;
coe$spc1:
	in	spc1$st
	ani	01			; transmitter status
	jrz	coe$spc1
	mov	a,c
	out	spc1$dt			; put the data
	ret
;
;
coe$spc2:
	in	spc2$st
	ani	01			; transmitter status
	jrz	coe$spc2
	mov	a,c
	out	spc2$dt			; put the data
	ret
;
;
coe$fdc3:
	in	fdc3$st
	ani	01			; transmitter status
	jrz	coe$fdc3
	mov	a,c
	out	fdc3$dt			; get the data
	ret
;
coe$sbc2:
	in	sbc$st2
	ani	4
	jrz	coe$sbc2
	mov	a,c
	out	sbc$dt2
	ret
;
;----------------------------------------------------------------
; Display the status bits of the centronic printer
; port and offer to output a byte to the port.
;----------------------------------------------------------------
;
test5:
	call	clear
	call	xyinline
	db	18,05,'---- SBC-800 Centronic Printer Port Test ----$'
;
test5$loop:
	call	inline
	db	0dh,0ah,0ah,'Enter a byte to send (hex) : $'
	call	ihhl
	mov	a,l
	out	cp$dt			; send to centronic data port
;
	call	inline
	db	0dh,0ah,'Busy = $'
	in	cp$st1			; get centronic status byte
	call	phacc			; display as hex
;
	call	inline
	db	0dh,0ah,' Ack = $'
	in	cp$st2
	call	phacc
;
; Continue ??
	call	inline
	db	0dh,0ah,'Again ? $'
	call	cie
	call	caps
	call	coe
	cpi	'Y'
	jz	test5$loop
	ret				; all done
;
;----------------------------------------------------------------
; 		T e s t   T h e   M P C - 6
;		---------------------------
;
; This routine reads the status of all MPC-6 channels and if a character
; is there it echoes it to the screen (back to the MPC-6). This is a good
; indication that the MPC-6 is in fact working. A test is done at the start
; of the program to see if the correct I/O driver module has been linked
; in, and if not then an error is reported.
; More than one terminal can be connected at a time, this program simply
; scans ALL channels and when a character is there, it echoes it.
;----------------------------------------------------------------
;
test7:
; Check that an MPC-6 is in the bus. This is done by reading the port
; which is the transmitter status. If bits incorrectly set then no MPC-6
;
	call	clear
	out	3			; perform a software reset
	call	xyinline
	db	1,10,'Checking for MPC-6 in bus - $'
; read the port
	in	1			; read the port
	cpi	03fh			; check the status (transmitter ready)
	jz	test7$mpcok
;
	call	bell			; hey
	mvi	a,3			; reverse video
	call	setatt
	call	inline
	db	'MPC-6 NOT VISIBLE at ports 0..3$'
	xra	a
	call	setatt
	lxi	d,2000
	call	delay
	ret				; return to main menu
;
test7$mpcok:
	call	inline
	db	' MPC-6 all present and correct$'
	lxi	d,2000			; 2 second delay
	call	delay
;
; Progress on to the next bit.
	call	clear
	call	ionum			; get the I/O driver number
	mov	a,l			; get the number
	cpi	3			; CP/M and MPC-6
	jrz	test7$ok
	cpi	4			; SBC-800 & mpc-6
	jrz	test7$ok		
; Display a message
	call	bell
	call	xyinline
	db	15,10,'WRONG I/O DRIVER MODULE, SEE R.C.H.$'
	lxi	d,3000
	call	delay
	ret				; return to main menu
;
test7$ok:
	call	clear
;
	call	xyinline
	db	15,10,'Enter characters on any MPC-6 channel$'
	call	xyinline
	db	18,11,'Enter control F to fill screen$'
	call	xyinline
	db	20,12,'Enter a control C to exit$'
;
	call	crlf
;
test7$start:
	xra	a			; clear the byte
test7$loop:
	sta	channel			; save
	adi	base			; add the log in vector
	call	coe			; do the log on
	call	cst
	jz	test7$ignore
; There is a character there
	call	cie
	cpi	03			; control C ??
	jz	test7$end
	cpi	6			; control F ??
	jnz	test7$loop3
; Load some counters to fill the screen, after a cursor addressing etc
	lxi	d,0
	call	cursor			; dont' bother to clear
	mvi	b,24			; Do all lines
test7$fl1:
	push	b
	mvi	b,80			; all characters on a line
test7$fl2:
	mvi	a,'X'
	call	coe
	call	xonof			; do a little handshake
	djnz	test7$fl2
	pop	b			; get number of lines done
	djnz	test7$fl1
; Now a little message in the middle
	call	xyinline
	db	35,11,'Like That ?$'
	call	getyorn
	jz	test7$ignore
	call	clear
	jmp	test7$ignore
;
;
test7$loop3:
	call	coe
;
test7$ignore:
	lda	channel
	inr	a
	cpi	7			; past end ??
	jz	test7$start		; if past end then re-load a 00
	jmp	test7$loop
;
test7$end:
	call	clear
	call	xyinline
	db	14,10,'Connect back to main port and press return$'
	mvi	a,base			; log back onto main port
	call	coe
; wait for a return now
test7$wait:
	call	cie
	cpi	0dh
	jrnz	test7$wait
	ret				; return to main menu
;
xonof:
	call	cst
	rz
	call	cie
	cpi	19
	rnz				; exit if not an X-off
xonwait:
	call	cie
	cpi	17			; x-on again ?
	rz
	call	bell
	jr	xonwait
;
;----------------------------------------------------------------
;          D I S P L A Y    A D C - 3 2   D A T A
;	   --------------------------------------
;
; This test displays all data that is on the A-TO-D card. This is
; done using the ANAIN library entry for the analogue channels, then
; reading the bit channels directly.
;----------------------------------------------------------------
;
test8:
;
	call	clear
	call	xyinline
	db	23,1,'A-TO-D Card Display$'
	call	xyinline
	db	00,23,'Press a key to exit$'
;
; LOOP THROUGH ALL 32 CHANNELS THEN DO AGAIN TILL STOPPED BY A KEY PRESS
;
test8$start:
	LXI	H,BTAB			; USE A LITTLE MEMORY TO STORE BIT DATA
	call	xyinline
	db	1,4,'A TO D =$'
	MVI	B,00
LOOP:
	; CHECK FOR 16 ENTRIES
	MOV	A,B
	CPI	16			; HALF WAY THERE
	JNZ	NOLF
	call	xyinline
	db	1,5,'A TO D =$'
NOLF:
	MOV	A,B
	OUT	PORT0
	CALL	DELAY$8			; A LITTLE DELAY FOR SAFETY SAKE
	ORI	80H
	OUT	PORT0
	CALL	DELAY$8
	ANI	07FH			; MASK OFF TOP BIT
	OUT	PORT0
	NOP
	NOP				; SMALL DELAY
LOOP1:
	IN	PORT1
	ANI	080H
	JZ	LOOP1
;
	IN	PORT0
	MOV	C,A			; SAVE VALUE INTO C
	IN	PORT1
	ANI	1			; MASK BIT OF OPTO CHANNEL
	MOV	M,A
	INX	H
;
; DISPLAY THE VALUE OF THE A TO D CHANNEL
;
	mvi	a,' '
	call	dispatch
	mov	a,c			; GET A TO D VALUE
	call	phacc			; display hex value
;
	inr	b
	mov	a,b
 	cpi	32
	jnz	loop
;
; HERE ALL THE ANALOG CHANNELS HAVE BEEN PRINTED
; NOW DO THE DIGITAL BIT CHANNELS
;
	call	xyinline
	db	1,15,'BITS  = $'
	lxi	h,btab			; POINT TO BIT TABLE
	mvi	b,16			; COUNT
loop3:
	mvi	a,' '
	call	dispatch
	mov	a,m
	inx	h
; A 00 MEANS THE CHANNEL IS ON (REMENBER ??)
	CPI	0
	jrz	p1
	mvi	a,'0'
	call	dispatch
	jr 	loop4
p1:
	mvi	a,'1'
	call	dispatch
loop4:
	dcr	b
	mov	a,b
	ora	a
	jnz	loop3
;
	call	cst
	jz	test8$start
	ret				; return to main menu
;
; Subroutines for this test
DELAY$8:
	push	b
	push	psw
	mvi	b,03		; WAIT A WHILE
DLOOP:
	call	cst
	jrnz	dloop2		; end of
	djnz	dloop
	pop	psw
	pop	b
	ret
dloop2:
	call	cie
	pop	h		; was psw
	pop	h		; was bc
	pop	h		; call delay
	ret			; all done, return from the test
;
;----------------------------------------------------------------
; This section tests the DRC-II dynamic memory board by doing the
; following.
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
test9:           
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
	call	do$test9		; do the actual test
;
; 	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; This section must bump the number of loops counter
; then must display it on the screen.
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
	mov	m,d		; save
	dcx	h
	mov	m,e		; save all
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
	sded	cur$cur			; save the address
	call	cursor			; set the cursor
	mvi	a,'*'
	call	dispatch
; Now check for the end of tests.
;
	call	cst
	jz	test9$start		; 00 = No character there
	call	cie			; Else we get the typed character
	ret				; return to main menu
;
; This is the actual memory testing section
; This decodes the test that must be done then jumps to it.
; A return is done from the test if all is well else the test
; will jump to test9$fail for an error.
;
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
vtab:
	org	((vtab - start) and 0fff0h) + 10h
vectors:
	dw	int0
	dw	int1
	dw	int2
	dw	int3			; interrupt address vectors
;
;
test9$test1:
; Check for SBC-800. Read CTC-0 which is running the 9600 baud terminal
; and see if we get an incrementing value. If not then no SBC-800 so return
	in	ctc0			; read CTC-0
	mov	b,a			; save
; Do 1 Ms delay
	lxi	d,1
	call	delay
; Re-get the CTC count and check if different
	in	ctc0			; read CTC channel 0 again
	cmp	b
	jnz	t9t1$start
; Here and NO SBC-800
	call	xyinline
	db	40,23,'SBC-800 Required for interrupt test$'
	ret
; 
; Start the Interrupt test by enabling interrupts on channel 3
;
; Set up interrupt vectors.
t9t1$start:
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
	rz
	jmp	t9t1$loop
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
	ret
;
dumret:
	reti				; clear pending CTC status
;
;
; ~~~~~~~~~~~~~~~~----------------~~~~~~~~~~~~~~~~
; This test does many output instructions to port addresses close to the
; bank select port of the DRC-II in the hope that this will trigger the 
; DRC-II to glithc and de-select itself. This is usually caused by faulty
; port decoding logic.
; ports user are f0..fe
; ----------------~~~~~~~~~~~~~~~~----------------
;
test9$test2:
	lxi	h,t9t2			; port iteration size
test9$test2$loop:
	push	h			; save loop counter
	mvi	b,0eh			; number of ports
	mvi	c,0f0h			; start port address
port$loop:
	call	send$port		; send port (HL) times
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
	lhld	mem$start
	lbcd	mem$size
	mov	e,a			; save this value
; Now the check of the byte in memory. Use a Z-80 auto check.
	mvi	a,'I'
	call	coe
	mvi	a,8
	call	coe
t9t5$loop2:
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
	lhld	mem$start
	lbcd	mem$size
	mov	e,a			; save the random check value
;
	mvi	a,'D'			; indicate a Decrementing test
	call	coe
	mvi	a,8			; backspace
	call	coe
; Now the check of the byte in memory. Use a Z-80 auto check.
t9t5$loop3:
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
	push	h			; save the address
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
	call	pdde			; display it
; After all this, bump the total number of fails, save and then display.
	lxi	d,0d15h			; col 13, line 21
	call	cursor
	lhld	t9$total$fails
	inx	h
	shld	t9$total$fails
	xchg
	call	pdde			; display as a decimal
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
	lxi	d,datend		; data end variable in ASMLIB
	lxi	h,0200h			; a little margin for error
	dad	d
	shld	mem$start		; save as the test area memory start
	lxi	d,01a04h		; 
	call	cursor
	xchg				; memory start is now in DE
	call	phde			; display without LZB
	push	d			; save the end address
; Get the memory end address, display, save then calculate the memory size 
; to be tested.
	lxi	d,01a05h
	call	cursor
; Load 0bfffh as the memory end address
	lxi	d,0bfffh
	sded	mem$end
	call	phde
; Now the memory size
	ora	a
	xchg				; HL = memory end address
	pop	d			; DE = memory start
	dsbc	d
	shld	mem$size		; save the memory size
;
	call	blzb
	ret
;
;----------------------------------------------------------------
; TESTNO is loaded from the users keypress. It is used to vector
; around this program and is a little vital. It is also used for
; input / output testing of serial devices to decode which
; i/O driver to be used. It is in ASCII not hex (easier).
;----------------------------------------------------------------
;
menu:
	db	10,03,'SME Systems Board Test Program V1.2$'
	db	10,04,'--------------20/01/84-------------$'

	db	10,06,'       Enter an option$'


	db	10,08,' 1) Test SPC-29 PARALLEL ports$'
	db	10,09,' 2) Test SPC-29 SERIAL port 1$'
	db	10,10,' 3) Test SPC-29 SERIAL port 2$'
	db	10,11,' 4) Test FDC-3  SERIAL port$'
	db	10,12,' 5) Test SBC-800 Centronic printer port$'
	db	10,13,' 6) Test SBC-800 Serial port 2$'
	db	10,14,' 7) Test MPC-6 serial channels$'
	db	10,15,' 8) Display ADC-32 data$'
	db	10,16,' 9) Test DRC-II memory$'
	db	10,17,' C) Display program CRC$'
	db	10,19,' Q) Quit to CP/M$'
	db	10,21,'?$'
	db	0ffh			; signal end
;
progend:
	db	00		; used to get the CRC code of the program
;
;
; The next addresses point to the names of the I/O drivers. This is used
; to display the name of the I/O device that ASMLIB has been linked for
; and is also used to check if the user has the correct driver to suit the
; application.
;
names:
	dw	io1			; CP/M io
	dw	io2			; SBC800 io
	dw	io3			; CPMMPC
	dw	io4			; SBCMPC
;
io1:	db	'CP/M$'
io2:	db	'SBC-800$'
io3:	db	'CP/M & MPC-6$'
io4:	db	'SBC-800 & MPC-6$'
;
channel	db	00			; channel to log onto (see mpc-6)
;
test$234$msg:
	db	0dh,0ah,'Entering Echo mode, press ^C to exit $'
;
test$234$msg2:
	db	0dh,0ah,'Connect terminal back to main port then'
	db	' PRESS A RETURN - BYE$'
;
seed	db	5,89,90,198,5,245
testno	db	00			; This is used by the initializer
;
btab	db	16
;
;~~~~ Test 9 data and variable 
;
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
t9$menu:
	db	30,01,'Memory Test Section$'
	db	21,04,'From$'
	db	23,05,'To$'
	db	36,04,'Time Start$'
	db	38,05,'Time End$'
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
;
	end
