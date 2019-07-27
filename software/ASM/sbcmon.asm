;----------------------------------------------------------------
; This program reads 4 digital input lines on an SBC-800 board
; parallel port lines and uses them to count external events.
; It is assumed that the lines will be low, going high, then low
; again. The leading edge is detected and when the falling edge is
; found then a counter is incermented. 
;
;			Written		R.C.H.     23/10/83
;			Last Update     R.C.H.     08/12/83
;----------------------------------------------------------------
;
	extrn	prolog,inline,cie,coe,cst,cursor,clkrd,bell
	extrn	bell,setxy,pmenu,quit,clear,caps,crlf
	extrn	nolzb,lzb,blzb,phacc,pdde,phde,dispatch,hexbcd
	extrn	curon,curoff,clkrd,xyinline
;
data	equ	080h		; data port to read for the 4 switches
stat	equ	data+3		; status port for the data port
cntmax	equ	030		; loops between time check & print
timx	equ	22		; time x column screen address
timy	equ	22		; time y row address
;
	call	prolog
	call	clear
	lxi	d,display	; display a message
	call	pmenu
	call	curoff		; disable the cursor
	call	blzb		; nice blanking is required
; Clear all the counts next
	call	clear0
	call	clear1
	call	clear2
	call	clear3		; all set to 00, status also
; Now we set up a default status of the on / off switches by setting them on
	mvi	c,0ffh		; all switches on
	call	check4
	call	check5
	call	check6
	call	check7
;
; Set up the 8255 to be an input device on channel A
	mvi	a,090h		; a inputs, b&c outputs
	out	stat
;
	mvi	a,1		; display time soonest possible 
	sta	counts		; save a loop counter
;
; Now go straight into the loop.
; Read the input port PA0 and detect which switches are on and off
; Use this to detect switch transitions.
;
loop:
	in	data
	mov	c,a		; save the data byte
	call	check0		; bits 0--7 are counters
	call	check1
	call	check2
	call	check3
	call	check4		; bits 4--7 are on / off switches
	call	check5
	call	check6
	call	check7
	call	chk$counts	; check the loop counter
	call	do$bell		; ring bell only if a changed counter
	call	cst		; character typed ?
	jz	loop
	call	cie
	call	caps
	cpi	'Q'
	jz	finish
	lxi	h,loop
	push	h		; put a return address on stack
	cpi	'0'
	jz  	clear0
	cpi	'1'
	jz  	clear1
	cpi	'2'
	jz  	clear2
	cpi	'3'
	jz  	clear3
	cpi	'T'
	jz	tog$bell	; toggle the bell
	jmp	bell		; all else was an illegal character
;
finish:
	lxi	d,21		; line 22
	call	cursor
	call	crlf
	call	curon		; restore the cursor
	jmp	quit
;
;----------------------------------------------------------------
; This routine must get the count of the number of times the
; program has looped and when it is 00 it prints the time
; on the screen where it is set up for.
;----------------------------------------------------------------
;
chk$counts:
	lda	counts
	dcr	a
	sta	counts
	ora	a
	rnz			; exit if not end of loop
;
	mvi	a,cntmax	; get maximum count value
	sta	counts
; Now get the time
	lxi	d,tbuff		; point to time buffer
	call	clkrd		; read the clock into it
; Now check the validity of the time


; Now we check if the seconds has changed since the last time we were here
	lda	old$secs
	mov	c,a		; save
	lda	secs		; get current seconds value
	cmp	c		; same ??
	rz			; return now if the same
	sta	old$secs	; save the seconds
;
; Since time is ok, print it after x,y addressing
prnt$time:
	mvi	d,timx + 7
	mvi	e,timy
	call	cursor		; do the set up
;
	call	nolzb
	lda	hrs	
	call	phacc		; display it
	mvi	a,':'
	call	dispatch
	lda	mins
	call	phacc
	mvi	a,':'
	call	dispatch
	lda	secs
	call	phacc
	call	blzb		; back to blank filled lzb again
;
; Now print the loops counter. This = the number of seconds we have run.
	lhld	loops
	inx	h
	shld	loops
	xchg			; load into DE
	call	inline
	db	'  $'
	call	pdde
	ret
;
;----------------------------------------------------------------
; The following four routines use the byte passed in and use
; it to detect a switch transition. A switch transition occurrs
; when an input goes high then low.
;----------------------------------------------------------------
;
check0:
	mov	a,c		; fetch input byte
	ani	1		; make it a 1 or a 0 only
	mov	e,a		; put into e
	lda	status0
	cmp	e		; is the previous value the same ??
	rz			; exit if so
; We have gone high-> low or low-> high if here
	jnc	c0fall		; no carry means a falling edge
; Here and there is a rising edge.
	mvi	a,1
	sta	status0		; save it
	ret
; Here and a falling edge detected.
c0fall:
	xra	a
	sta	status0
	lhld	s0		; load the count value
	inx	h
	shld	s0
; set up cursor and display
dsp0:	; The entry to display hl on the screen
	lxi	d,0a06h
	call	cursor
	xchg
	call 	pdde
	mvi	a,0ffh
	sta	ring		; flag a change in a counter
	ret
;
; Second counter exactly the same way
;
check1:
	mov	a,c		; fetch input byte
	ani	2		; make it a 1 or a 0 only
	mov	e,a		; put into e
	lda	status1
	cmp	e		; is the previous value the same ??
	rz			; exit if so
; We have gone high-> low or low-> high if here
	jnc	c1fall		; no carry means a falling edge
; Here and there is a rising edge.
	mvi	a,2		; save the bit number
	sta	status1		; save it
	ret
; Here and a falling edge detected.
c1fall:
	xra	a
	sta	status1
	lhld	s1		; load the count value
	inx	h
	shld	s1
; set up cursor and display
dsp1:	; The entry to display hl on the screen
	lxi	d,0a08h
	call	cursor
	xchg
	call 	pdde
	mvi	a,0ffh
	sta	ring
	ret
;
; Third counter
;
check2:
	mov	a,c		; fetch input byte
	ani	4		; make it a 1 or a 0 only
	mov	e,a		; put into e
	lda	status2
	cmp	e		; is the previous value the same ??
	rz			; exit if so
; We have gone high-> low or low-> high if here
	jnc	c2fall		; no carry means a falling edge
; Here and there is a rising edge.
	mvi	a,4
	sta	status2		; save it
	ret
; Here and a falling edge detected.
c2fall:
	xra	a
	sta	status2
	lhld	s2		; load the count value
	inx	h
	shld	s2
; set up cursor and display
dsp2:	; The entry to display hl on the screen
	lxi	d,0a0ah
	call	cursor
	xchg
	call 	pdde
	mvi	a,0ffh
	sta	ring
	ret
;
; Fourth and last counter
;
check3:
	mov	a,c		; fetch input byte
	ani	8		; make it a 1 or a 0 only
	mov	e,a		; put into e
	lda	status3
	cmp	e		; is the previous value the same ??
	rz			; exit if so
; We have gone high-> low or low-> high if here
	jnc	c3fall		; no carry means a falling edge
; Here and there is a rising edge.
	mvi	a,8
	sta	status3		; save it
	ret
; Here and a falling edge detected.
c3fall:
	xra	a
	sta	status3
	lhld	s3		; load the count value
	inx	h
	shld	s3
; set up cursor and display
dsp3:	; The entry to display hl on the screen
	lxi	d,0a0ch
	call	cursor
	xchg
	call 	pdde
	mvi	a,0ffh
	sta	ring
	ret
;
;----------------------------------------------------------------
; These routines display the status of the on / off switches 
; connected to bits 4 to 7 inclusive. 
; The only time the switch has its message changed is when there is a 
; transition from one state to another. All else causes a return.
; On entry register C = the input byte. Each routine checks its bit
; to see if there is a change from the bit saved in memory. If a 
; difference then the message is changed and the bit saved.
;----------------------------------------------------------------
;
check4:
	mov	a,c		; fetch the bit
	ani	010h		; test bit 4
	mov	e,a		; save it back
	lda	s4
	cmp	e		; is the original equal to the new ?
	rz		; This is the immediate exit if no change
;
; Here we do a conditional bell.
; Now write the new bit back to memory then test is the message should be 
; an on or off message, print it then return.
	mov	a,e		; restore masked / tested bit
	sta	s4
	ora	a
	jz	c4off		; display check 4 off message
; Here display the on message
	lxi	d,0c0eh
	call	cursor
	call	inline
	db	' ON$'
	ret
c4off:
	lxi	d,0c0eh
	call	cursor
	call	inline	
	db	'OFF$'
	ret
;
; Check the second switch status
;
check5:
	mov	a,c		; fetch the bit
	ani	020h		; test bit 5
	mov	e,a		; save it back
	lda	s5
	cmp	e		; is the original equal to the new ?
	rz		; This is the immediate exit if no change
;
; Here we do a conditional bell.
; Now write the new bit back to memory then test is the message should be 
; an on or off message, print it then return.
	mov	a,e		; restore masked / tested bit
	sta	s5
	ora	a
	jz	c5off		; display check 4 off message
; Here display the on message
	lxi	d,0c10h
	call	cursor
	call	inline
	db	' ON$'
	ret
c5off:
	lxi	d,0c10h
	call	cursor
	call	inline	
	db	'OFF$'
	ret
;
; Check the tried switch
;
check6:
	mov	a,c		; fetch the bit
	ani	040h		; test bit 6
	mov	e,a		; save it back
	lda	s6
	cmp	e		; is the original equal to the new ?
	rz		; This is the immediate exit if no change
;
; Here we do a conditional bell.
; Now write the new bit back to memory then test is the message should be 
; an on or off message, print it then return.
	mov	a,e		; restore masked / tested bit
	sta	s6
	ora	a
	jz	c6off		; display check 4 off message
; Here display the on message
	lxi	d,0c12h
	call	cursor
	call	inline
	db	' ON$'
	ret
c6off:
	lxi	d,0c12h
	call	cursor
	call	inline	
	db	'OFF$'
	ret
;
; Check the last (bottom) switch
;
check7:
	mov	a,c		; fetch the bit
	ani	080h		; test bit 4
	mov	e,a		; save it back
	lda	s7
	cmp	e		; is the original equal to the new ?
	rz		; This is the immediate exit if no change
;
; Here we do a conditional bell.
; Now write the new bit back to memory then test is the message should be 
; an on or off message, print it then return.
	mov	a,e		; restore masked / tested bit
	sta	s7
	ora	a
	jz	c7off		; display check 4 off message
; Here display the on message
	lxi	d,0c14h
	call	cursor
	call	inline
	db	' ON$'
	ret
c7off:
	lxi	d,0c14h
	call	cursor
	call	inline	
	db	'OFF$'
	ret
;
; Clear the counters. This is called at program start and when
; keystroke options are entered
;
clear0:
	xra	a
	lxi	h,0
	shld	s0
	sta	status0
	jmp	dsp0		; display this new value
;
clear1:
	xra	a
	lxi	h,0
	shld	s1
	sta	status1
	jmp	dsp1
;
clear2:
	xra	a
	lxi	h,0
	shld	s2
	sta	status2
	jmp	dsp2
;
clear3:
	xra	a
	lxi	h,0
	shld	s3
	sta	status3
	jmp	dsp3
;
; This is the conditional bell ringer. If the bell status flag is
; 00 then the bell is not sounded else if non zero then it is rung.
;
do$bell:
	lda	bell$stat
	ora	a
	rz
; Now we check the bell code in ring. If this is not 00 then we clear it
; then ring the bell. This byte really only is used to indicate
; a changed counter.
	lda	ring
	ora	a
	rz				; exit since no counters tripped
	xra	a
	sta	ring			; clear the byte if it is set
	jmp	bell			; return after ringing the bell
;
; This simple routine toggles the bell in and out. The bell is 
; in when the bell stat byte is not 00.
;
tog$bell:
	lxi	d,0340ah		; col 53, lin 10
	call	cursor
;
	lda	bell$stat
	xri	0ffh			; toggle it
	sta	bell$stat
;
	ora	a			; 00 and bell off
	jz	tog$bell2
; here and the bell is on, next time we toggle off
	call	inline
	db	'OFF$'
	ret
; here and the bell is disabled so we toggle it on next time
tog$bell2:
	call	inline
	db	'ON $'
	ret
;
; Message display area next
;
display:
	db	12,00,'SBC-800 Switch Transition Counter  V1.0$'
	db	00,06,' Count 0$'
	db	00,08,' Count 1$'
	db	00,10,' Count 2$'
	db	00,12,' Count 3$'
	db	00,14,'Switch 0 $'
	db	00,16,'Switch 1 $'
	db	00,18,'Switch 2 $'
	db	00,20,'Switch 3 $'
	db	36,04,'------Options----$'
	db	36,06,'0 = Clear Count 0$'
	db	36,07,'1 = Clear Count 1$'
	db	36,08,'2 = Clear Count 2$'
	db	36,09,'3 = Clear Count 3$'
	db	36,10,'T = Toggle bell ON$'
	db	36,12,'Q = Quit$'
	db	timx,timy,'Time$'
	db	timx+24,timy,'Total Seconds$'
	db	0ffh
;
	dseg
;
; The next 8 sections are used to detect leading edges and to
; count switch transitions.
;
s0	db	00,00
status0	db	00
s1	db	00,00
status1	db	00
s2	db	00,00
status2	db	00
s3	db	00,00
status3	db	00
;
; The next 4 locations are for the switches
;
s4	db	00
s5	db	00
s6	db	00
s7	db	00
;
; Status flags
;
bell$stat:
	db	00			; 00 = bell off, else bell on
ring	db	00			; 00 = no ring, 0ffh = change so ring
;
; A buffer to read the time into
;
loops	db	00,00			; loop counter = total seconds run
counts	db	00			; count program loops
old$secs	
	db	00			; Save to check time against
;
tbuff:	db	00,00,00,00		; year, month, day, dow
hrs	db	00
mins	db	00
secs	db	00
;
	end
