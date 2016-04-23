	title 'Memory Disk drive handler for the N8VEM SBC'

;   CP/M-80 Version 3     --  Modular BIOS

;	Disk I/O Module for N8VEM Memory disks 

	;	Version 0.02,
	;		Single drive only 	- 	MJS, 11 Aug 2009
	;		Multi drive 		- 	MJS, 4 Sep 2009
	;		Banked version		-	MJS 30 Jun 2010
	;
	; Warning:  Parts of this driver cannot be banked and must live in common memory
	; due to page swapping required to access the RAM
	;
	; Note: RAMdisk gets cleared on boot.  Need to change this for N8VEM V2
	;

true	equ -1
false	equ not true

banked	equ true		
	
	dseg
	

    ; Disk drive dispatching tables for linked BIOS

	public	mdd0			;RAM Drive
	public	mdd1			;ROM Drive

    ; Variables containing parameters passed by BDOS

	extrn	@adrv,@rdrv
	extrn	@dma,@trk,@sect
	extrn	@dbnk,@cbnk

    ; System Control Block variables

	extrn	@ermde			; BDOS error mode

    ; Utility routines in standard BIOS

	extrn	?wboot			; warm boot vector
	extrn	?pmsg			; print message @<HL> up to 00, saves <BC> & <DE>
	extrn	?pdec			; print binary number in <HL> from 0 to 99.
	extrn	?pderr			; print BIOS disk error header
	extrn	?conin,?cono	; con in and out
	extrn	?const			; get console status
	extrn	?move			;move memory
	extrn	?bank			; select bank
	

    ; Port Address Equates

	;maclib ports
	


mpcl$ram		equ	78h		; BASE IO ADDRESS OF RAM MEMORY PAGER CONFIGURATION LATCH
mpcl$rom		equ	7Ch		; BASE IO ADDRESS OF ROM MEMORY PAGER CONFIGURATION LATCH

    ; CP/M 3 Disk definition macros

	maclib cpm3

    ; Z80 macro library instruction definitions

	maclib z80

    ; common control characters

cr		equ 13
lf		equ 10
bell	equ 7

crlf:
		db	cr,lf,0

    ; Extended Disk Parameter Headers (XPDHs)

		dw	md$write
		dw	md$read
		dw	md$login
		dw	md$init
		db	0,0				; relative drive zero
mdd0:
		DW	0				;sector translation table
		DB	0,0,0,0,0,0,0,0,0	;bdos scratch area
		DB	0					;media flag
		DW	dpbmd			;disk parameter block (RAM disk)
		DW	0FFFEH			;checksum vector
		DW	0FFFEH			;allocation vector
		DW	0FFFEH			;directory buffer control block
		DW	0FFFEH			;dtabcb not used
		DW	0FFFEH			;hashing
		DB	0				;hash bank
;
;
;
		dw	md$write
		dw	md$read
		dw	md$login
		dw	md$init
		db	1,0				; relative drive one
mdd1:
		DW	0				;sector translation table
		DB	0,0,0,0,0,0,0,0,0	;bdos scratch area
		DB	0					;media flag
		DW	dpbrd			;disk parameter block (ROM disk)
		DW	0FFFEH			;checksum vector
		DW	0FFFEH			;allocation vector
		DW	0FFFEH			;directory buffer control block
		DW	0FFFEH			;dtabcb not used
		DW	0FFFEH			;hashing
		DB	0				;hash bank		
		
	cseg	; DPB must be resident

dpbmd:					;N8VEM DISK PARAMETER BLOCK (RAMDISK 512K, 448K usable)
	dw	 	256	 		; 256 SECTORS OF 128 BYTES PER 32K TRACK
	db 		4 			; BLOCK SHIFT FACTOR (SIZE OF ALLOCATION BLOCK)
	db 		15 			; PART OF THE ALLOCATION BLOCK SIZE MATH
	db 		1 			; DEFINES SIZE OF EXTENT (DIRECTORY INFO)
	dw 		207 		; BLOCKSIZE [2048] * NUMBER OF BLOCKS + 1 = DRIVE SIZE
	dw 		255 		; NUMBER OF DIRECTORY ENTRIES
	db 		11110000b  	; BIT MAP OF SPACE ALLOCATED TO DIRECTORY
	db 		00000000b  	; DIRECTORY CAN HAVE UP TO 16 BLOCKS ALLOCATED

	dw		8000h		; fixed disk checksumming not required
	dw 		2 	  		; 1 TRACK RESERVED [FIRST 32K OF RAM]
	db		0,0			; physical sector size and shift (bios is de-blocking)
		
		
dpbrd:					;DISK PARAMETER BLOCK (ROMDISK 1MB) 
	dw		256			; 256 SECTORS OF 128 BYTES PER 32K TRACK
	db		4 			; BLOCK SHIFT FACTOR (SIZE OF ALLOCATION BLOCK)
	db 		15 			; PART OF THE ALLOCATION BLOCK SIZE MATH
	db	 	0 			; DEFINES SIZE OF EXTENT (DIRECTORY INFO)
	dw 		511 		; BLOCKSIZE [2048] * NUMBER OF BLOCKS +1 =DRIVE SIZE
	dw 		255 		; NUMBER OF DIRECTORY ENTRIES
	db		11110000b 	; BIT MAP OF SPACE ALLOCATED TO DIRECTORY
	db	 	00000000b 	; DIRECTORY CAN HAVE UP TO 16 BLOCKS ALLOCATED
	dw		8000h 	  	; SIZE OF DIRECTORY CHECK [0 IF NON REMOVEABLE]
	dw		1 	  		; 1 TRACK RESERVED [FIRST 32K OF ROM]
	db		0,0			; physical sector size and shift (bios is de-blocking)
;
		


PAGER:			DS	1		; COPY OF PAGER BYTE
SECST:			DW	0		; SECTOR IN ROM/RAM START ADDRESS

TMPBUF:						; TEMPORARY BUFFER FOR MEM DISK TRANSFERS
SECTOR$BUFFER:	DS	128		; Storage for 128 BYTE Memory disk sector



	dseg	; rest is banked




    ; Disk I/O routines for standardized BIOS interface

	; Initialization entry point.

	;called for first time initialization.

	cseg				; because we are changing banks, we must be in common memory
	
md$init:

	if banked	

	lda		@rdrv		; only do this once
	ana		a
	rnz


	mvi		a,2h		; switch in first 32K lower page (first track)
	call	?bank		; select first page of ramdisk
	
						; Formatting the ram is simple as clearing the directory area 
						; to a value of E5h (the first 8k of track 2 of the ramdisk).
	lxi		h,0000h		; starting memory address of track 2, sector 0 in HL
	lxi		b,1fffh		; 8K of directory sectors reserved (length in BC)
	mvi		a,0e5h		; initializing value in A 
	mov		e,l			
	mov		d,h
	inx		d
	mov		m,a
	ldir				; fill memory

	lda		@cbnk		; get current bank
	call	?bank		; and select it

	endif	
	
	ret

	dseg				; rest is banked

md$login:
		; This entry is called when a logical drive is about to
		; be logged into for the purpose of density determination.

		; It may adjust the parameters contained in the disk
		; parameter header pointed at by <DE>

	ret	; we have nothing to do in a fixed disk  environment.


; disk READ and WRITE entry points.

		; these entries are called with the following arguments:

			; relative drive number in @rdrv (8 bits)
			; absolute drive number in @adrv (8 bits)
			; disk transfer address in @dma (16 bits)
			; disk transfer bank	in @dbnk (8 bits)
			; disk track address	in @trk (16 bits)
			; disk sector address	in @sect (16 bits)
			; pointer to XDPH in <DE>

		; they transfer the appropriate data, perform retries
		; if necessary, then return an error code in <A>

	cseg
	
md$read:

read$ram$disk:
	
	di
							; IF RAM, PROCEED WITH NORMAL TRACK/SECTOR READ
	call	SECPAGE			; SETUP FOR READ OF RAM OR ROM DISK
	call 	PAGERB			; SET PAGER WITH DRIVE AND TRACK
	lhld	SECST			; GET ROM/RAM ADDRESS
	mov		e,l
	mov		d,h				; GET IT INTO DE
	lxi		h,TMPBUF		; LOAD HL WITH TEMP BUF ADDRESS

	lxi		b,128			;
	call	?move

;
; NOW WITH THE ROM/RAM DATA IN THE BUFFER WE CAN NOW MOVE IT TO THE 
;  DMA ADDRESS (IN RAM)
;
	call	RPAGE			; SET PAGE TO CP/M RAM

	lxi		h,TMPBUF		; GET ROM/RAM ADDRESS
	mov		e,l
	mov		d,h				; GET IT INTO DE
	lhld	@dma			; LOAD HL WITH DMA ADDRESS

	lxi		b,128
	call	xfer			; transfer data to dma buffer	

	mvi		a,0H
	ei						; RE-ENABLE INTERRUPTS
	ret
	
;----------------------------------------------------------------------------------------------------------------------
md$write:
	lda		@rdrv			; get drive unit number
	cpi		01h				;check for write to ROM disk
	jnz		write$ram$disk
	mvi		a,02			; signal an error
	ret
	
WRITE$RAM$DISK:
	di
	lhld	@dma		; GET DMA ADDRESS
	mov		e,l
	mov		d,h			; GET IT INTO DE
	lxi		h,TMPBUF	; LOAD HL WITH TEMP BUF ADDRESS

	lxi		b,128
	call	xfer

;
;  NOW THAT DATA IS IN THE TEMP BUF WE SET TO RAM PAGE
;   FOR WRITE.
;
	call	SECPAGE		; GET RAM PAGE WRITE ADDRESS
	call	PAGERB		; SET PAGER WITH DRIVE AND TRACK
	lxi		h,TMPBUF	; GET TEMP BUFFER ADDRESS
	mov		e,l
	mov		d,h			; GET IT INTO DE
	lhld	SECST		; LOAD HL WITH DMA ADDRESS (WHERE TO WRITE TO)

	lxi		b,128		; copy sector to ram drive
	call	?move

	call	RPAGE		; SET BACK TO RAM
if banked	
	lda		@cbnk					; get current bank
	call	?bank					; and select it
endif		
	
	mvi		a,00h		; Indicate sucess to BDOS
	ei					; RE-ENABLE INTERRUPTS
	ret

	;----------------------------------------------------------------------------
	
	;
; UTILITY ROUTINE FOR SECTOR TO PAGE ADDRESS
;   USES HL AND CARRY
;SECPAG:	LHLD	SECTOR
SECPAGE:
	lhld	@sect
	dad		h
	dad		h
	dad		h
	dad		h
	dad		h
	dad		h
	dad		h				; *128
	shld	SECST			; SAVE SECTOR STARTING ADDRESS
	ret
;
;  PAGER BYTE CREATION
;    ASSEMBLES DRIVE AND TRACK AND SENDS IT TO PAGER PORT
;
PAGERB:	
	lhld	@trk
	lda		@rdrv			; get drive unit number
	cpi		01h				;
	jz		ROMD			; READ FROM 1M ROM DISK
	ani		1				; MASK FOR 1 BIT OF DRIVE SELECT 
	rrc						; MOVE BIT 0 TO BIT 7
	ora		l				; OR L WITH ACC TO COMBINE TRACK AND DRIVE
	out		MPCL$RAM		; SEND TO RAM PORT MAPPER
	sta	 	PAGER			; SAVE COPY (JUST BECAUSE)
	ret
ROMD:	
	ani		1				; MASK FOR 1 BIT OF DRIVE SELECT 
	rrc						; MOVE BIT 0 TO BIT 7
	ora		l				; OR L WITH ACC TO COMBINE TRACK AND DRIVE
	ani		07FH			; STRIP OFF BIT 7 (ROM_ENABLE BIT)
	out		MPCL$ROM	 	; SEND TO ROM PORT MAPPER
	sta	 	PAGER			; SAVE COPY (JUST BECAUSE)
	ret
;
;   RESET PAGER BACK TO RAM.  
;
RPAGE:
	mvi		a,80H			; DESELECT ROM PAGE
	out		MPCL$ROM		; SELECT RAM
	mvi		a,0				; SET TO RAM, TRACK 0
	out		MPCL$RAM		; SELECT RAM
	sta 	PAGER			; SAVE COPY OF PAGER BYTE
	ret


;-----------------------------------------------------------------------

	cseg							; must be in common memory
;
;	Transfer routine to move data in and out of the sector buffer
; 	for banked system theis must be located in common memory
;	enter with HL & DE containing source/destination addresses
;
xfer:
 if banked
	lda		@dbnk					; get dma bank for data transfer
	call	?bank					; and select it
endif
	
	call	?move					; move the data into dma location

if banked	
	lda		@cbnk					; get current bank
	call	?bank					; and select it
endif	

	ret
	
	end
