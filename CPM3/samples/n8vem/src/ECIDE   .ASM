	title 'ECB IDE hard drive handler for the N8VEM SBC'

;    CP/M-80 Version 3     --  Modular BIOS

;	Disk I/O Module for ECB Diskio IDE Port

	;	Initial version 0.01,
	;		Single drive only with no partitions.	- MJS, 31 Aug 2009
	;		Multiple partitions - fixed table.		- MJS 8 Sep 2009
	;		Added support for banked environment	- MJS 26 Jun 2010

true	equ -1
false	equ not true

banked	equ true	
	
	dseg

    ; Disk drive dispatching tables for linked BIOS

	public	ecdd0,ecdd1,ecdd2,ecdd3

    ; Variables containing parameters passed by BDOS

	extrn	@adrv,@rdrv
	extrn	@dma,@trk,@sect
	extrn	@dbnk,@cbnk

    ; System Control Block variables

	extrn	@ermde		; BDOS error mode

    ; Utility routines in standard BIOS

	extrn	?wboot			; warm boot vector
	extrn	?pmsg			; print message @<HL> up to 00, saves <BC> & <DE>
	extrn	?pdec			; print binary number in <HL> from 0 to 99.
	extrn	?pderr			; print BIOS disk error header
	extrn	?conin,?cono	; con in and out
	extrn	?const			; get console status
	extrn	?move			; move memory
	extrn	?bank			; select bank


    ; Port Address Equates

	;maclib ports
	

; IDE REGISTER			IO PORT		; FUNCTION
ide$data$lo			EQU	20H		; DATA PORT (LOW BYTE)
ide$err				EQU	21H		; READ: ERROR REGISTER; WRITE: PRECOMP
ide$sec$cnt			EQU	22H		; SECTOR COUNT
ide$sector			EQU	23H		; SECTOR NUMBER
ide$cyl$lsb			EQU	24H		; CYLINDER LOW
ide$cyl$msb			EQU	25H		; CYLINDER HIGH
ide$head			EQU	26H		; DRIVE/HEAD
ide$status			EQU	27H		; READ: STATUS; WRITE: COMMAND
ide$command			EQU	27H		; READ: STATUS; WRITE: COMMAND
ide$data$hi			EQU	28H		; DATA PORT (HIGH BYTE)
ide$astatus			EQU	2EH		; READ: ALTERNATIVE STATUS; WRITE; DEVICE CONTROL
ide$addr			EQU	2FH		; DRIVE ADDRESS (READ ONLY)

;IDE Command Constants.  These should never change.
ide$cmd$recal		EQU	10H
ide$cmd$read		EQU	20H
ide$cmd$write		EQU	30H
ide$cmd$init		EQU	91H
ide$cmd$id			EQU	0ECH
ide$cmd$spindown	EQU	0E0H
ide$cmd$spinup		EQU	0E1H



    ; CP/M 3 Disk definition macros

	maclib cpm3

    ; Z80 macro library instruction definitions

	maclib z80

    ; common control characters

cr		equ 13
lf		equ 10
bell	equ 7


    ; Extended Disk Parameter Headers (XPDHs)

		dw	ec$write
		dw	ec$read
		dw	ec$login
		dw	ec$init
		db	0,0					; relative drive zero
ecdd0:
		DW	0					;sector translation table
		DB	0,0,0,0,0,0,0,0,0	;bdos scratch area
		DB	0					;media flag
		DW	dpb0				;disk parameter block
		DW	0FFFEH				;checksum vector
		DW	0FFFEH				;allocation vector
		DW	0FFFEH				;directory buffer control block
		DW	0FFFEH				;dtabcb not used
		DW	0FFFEH				;hashing
		DB	0					;hash bank


		dw	ec$write
		dw	ec$read
		dw	ec$login
		dw	ec$init
		db	1,0					; relative drive one
ecdd1:
		DW	0					;sector translation table
		DB	0,0,0,0,0,0,0,0,0	;bdos scratch area
		DB	0					;media flag
		DW	dpb0				;disk parameter block
		DW	0FFFEH				;checksum vector
		DW	0FFFEH				;allocation vector
		DW	0FFFEH				;directory buffer control block
		DW	0FFFEH				;dtabcb not used
		DW	0FFFEH				;hashing
		DB	0					;hash bank

		dw	ec$write
		dw	ec$read
		dw	ec$login
		dw	ec$init
		db	2,0					; relative drive two
ecdd2:
		DW	0					;sector translation table
		DB	0,0,0,0,0,0,0,0,0	;bdos scratch area
		DB	0					;media flag
		DW	dpb0				;disk parameter block
		DW	0FFFEH				;checksum vector
		DW	0FFFEH				;allocation vector
		DW	0FFFEH				;directory buffer control block
		DW	0FFFEH				;dtabcb not used
		DW	0FFFEH				;hashing
		DB	0					;hash bank

		dw	ec$write
		dw	ec$read
		dw	ec$login
		dw	ec$init
		db	3,0					; relative drive three
ecdd3:
		DW	0					;sector translation table
		DB	0,0,0,0,0,0,0,0,0	;bdos scratch area
		DB	0					;media flag
		DW	dpb0				;disk parameter block
		DW	0FFFEH				;checksum vector
		DW	0FFFEH				;allocation vector
		DW	0FFFEH				;directory buffer control block
		DW	0FFFEH				;dtabcb not used
		DW	0FFFEH				;hashing
		DB	0					;hash bank



		cseg	; DPB must be resident

dpb0:							; DISK PARAMETER BLOCK (IDE HARD DISK 8MB)
		DW	256					; 256 SECTORS OF 128 BYTES PER 32K TRACK
		DB	5					; BLOCK SHIFT FACTOR (SIZE OF ALLOCATION BLOCK)
		DB	31					; PART OF THE ALLOCATION BLOCK SIZE MATH
		DB	1					; DEFINES SIZE OF EXTENT (DIRECTORY INFO)
		DW	2017				; BLOCKSIZE [4096] * NUMBER OF BLOCKS + 1 = DRIVE SIZE
								; HD PARTITION 3 IS 16128 SECTORS LONG
								; AT 512 BYTES EACH WHICH IS 
								; 2016 BLOCKS AT 4096 BYTES A PIECE.
		DW	511					; NUMBER OF DIRECTORY ENTRIES
		DB	11110000b			; BIT MAP OF SPACE ALLOCATED TO DIRECTORY
		DB	00000000b			; DIRECTORY CAN HAVE UP TO 16 BLOCKS ALLOCATED

		DW	8000h				; fixed disk checksumming not required
		DW	1					; 1 TRACK (32K) RESERVED FOR SYSTEM	
		DB	0,0					; physical sector size and shift (bios is de-blocking)

		
dpb1:							;DISK PARAMETER BLOCK (IDE HARD DISK 1024K)
		DW 	256	 				; 256 SECTORS OF 128 BYTES PER 32K TRACK
		DB 	4 					; BLOCK SHIFT FACTOR (SIZE OF ALLOCATION BLOCK)
		DB 	15 					; PART OF THE ALLOCATION BLOCK SIZE MATH
		DB 	0 					; DEFINES SIZE OF EXTENT (DIRECTORY INFO)
		DW 	497 				; BLOCKSIZE [2048] * NUMBER OF BLOCKS + 1 = DRIVE SIZE
							; HD PARTITION 4 IS 4032 SECTORS LONG
							; AT 512 BYTES EACH WHICH IS 
							; 1008 BLOCKS AT 2048 BYTES A PIECE.
							; NOT USING ALL OF THE AVAILABLE SECTORS SINCE THIS
							; DRIVE IS INTENDED TO EMULATE A ROM DRIVE AND COPIED
							; INTO A ROM IN THE FUTURE.
		DW 	255 				; NUMBER OF DIRECTORY ENTRIES
		DB 	11110000b  			; BIT MAP OF SPACE ALLOCATED TO DIRECTORY
		DB 	00000000b  			; DIRECTORY CAN HAVE UP TO 16 BLOCKS ALLOCATED
		DW 	0 	  				; SIZE OF DIRECTORY CHECK [0 IF NON REMOVEABLE]
		DW 	1 	  				; 1 TRACK RESERVED [FIRST 32K OF PARTITION]		
		DB	0,0					; physical sector size and shift (bios is de-blocking)
		

TMPBUF:							; TEMPORARY BUFFER FOR MEM DISK TRANSFERS		
SECTOR$BUFFER:	DS	512			; STORAGE FOR 512 BYTE IDE HD SECTOR
								; Must be located in common memory

	dseg	; rest is banked		
		
LBA$OFFSET$LO:	DW	0			; IDE HD PARTITION STARTING SECTOR (LOW 16 BITS)
LBA$OFFSET$HI:	DW	0			; IDE HD PARTITION STARTING SECTOR (HI 16 BITS, 12 USED)

LBA$TARGET$LO:	DW	0			; IDE HD PARTITION TARGET SECTOR (LOW 16 BITS)
LBA$TARGET$HI:	DW	0			; IDE HD PARTITION TARGET SECTOR (HI 16 BITS, 12 USED)

IDE$LBA0:		DB	0			; SET LBA 0:7
IDE$LBA1:		DB	0			; SET LBA 8:15
IDE$LBA2:		DB	0			; SET LBA 16:23
IDE$LBA3:		DB	0			; LOWEST 4 BITS USED ONLY TO ENABLE LBA MODE 
IDE$DEV			DB	0			; Selected device (Master or Slave)

SECTOR$INDEX:	DB	0			; WHERE 128 BYTE CP/M SECTOR IS IN 512 BYTE IDE HD SECTOR

SECST:			DW	0			; SECTOR IN ROM/RAM START ADDRESS



IDE$CURR$DEV	DB	0FFH		; Currently selected device (Master or Slave)

P$TABLE:
								; here is the partition table listing the offset and length values for each logical drive
								; currently this is hard coded but later on it will be derived from the MBR
								;at the moment we don't check the size parameter to see if we overflow the partition

P1:								; partition 1 relative drive 0
			DW	0001h		;start low word
			DW	0000h		;start hi word
			DW	4000h		;size lo word
			DW	0000H		;size hi word
				
P2:								; partition 2 relative drive 1
			DW	4001h		;start low word
			DW	0000h		;start hi word
			DW	4000h		;size lo word
			DW	0000h		;size hi word

P3:								; partition 3 relative drive 2
;			DW	8000h		;start low word
			DW	0000h		;start low word
			DW	0100h		;start hi word
			DW	4000h		;size lo word
			DW	0000h		;size hi word

P4:								; partition 4 relative drive 3
			DW	0C000h		;start low word
			DW	0000h		;start hi word
			DW	4000h		;size lo word
			DW	0000h		;size hi word






    ; Disk I/O routines for standardized BIOS interface

; Initialization entry point.

;		called for first time initialization.


ec$init:
		lda		@rdrv			; only do this once
		ana		a
		rnz
		
		mvi		a,0
		sta		IDE$DEV			; select master drive
		sta		IDE$LBA0
		sta		IDE$LBA1
		sta		IDE$LBA2
		sta		IDE$LBA3
		
		lxi		h,sector$buffer	; setup address for read sector
		call	read$sector		; load in the partition table


;		lxi		h,sector$buffer		; load LBA0 from drive to get partition table
;		lhld		sig$offset			; get partition table signature
;		mvi		a,xx				; first sig byte
;		cmp		h
;		jnz		inv$tbl
;		mvi		a,yy				; second sig byte
;		cmp		l
;		jnz		inv$tbl

		
		;; display partition table here.....
		
		ret
		
inv$tbl:
		lxi		h,tbl$msg
		call	?pmsg
		ret

crlf:
		db	cr,lf,0
tblmsg:
		db	'Invalid partition table found.  Using defaults.',cr,lf,0

ec$login:
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

ec$read:
	jmp		read$hdpart1
		
READ$HDPART1:

	call	get$offset				; calculate the appropriate LBA offset for the relative drive
	

	
									; BDOS TRACK PARAMETER (16 BITS)
									; BDOS SECTOR PARAMETER (16 BITS)

	lhld	@trk					; LOAD TRACK # (WORD)
	mov		b,l						; SAVE LOWER 8 BITS (TRACK # 0-255)
	lhld	@sect					; LOAD SECTOR # (WORD)
	mov		h,b						; HL IS 8 BIT TRACK IN H, 8 BIT SECTOR IN L

	CALL	CONVERT$IDE$SECTOR$CPM	; COMPUTE WHERE THE CP/M SECTOR IS ON THE
									; IDE PARTITION
									; MAP COMPUTED IDE HD SECTOR TO LBA REGISTERS
									; LBA REGISTERS STORE 28 BIT VALUE OF IDE HD SECTOR ADDRESS

	lda		LBA$TARGET$LO	 		; LOAD LBA REGISTER 0 WITH SECTOR ADDRESS TO READ
	sta		IDE$LBA0
	lda		LBA$TARGET$LO+1		 	; LOAD LBA REGISTER 1 WITH SECTOR ADDRESS TO READ
	sta		IDE$LBA1
	lda		LBA$TARGET$HI		 	; LOAD LBA REGISTER 2 WITH SECTOR ADDRESS TO READ
	sta		IDE$LBA2
	lda		LBA$TARGET$HI+1		 	; LOAD LBA REGISTER 3 WITH SECTOR ADDRESS TO READ
;	ani		00001111b					; ONLY LOWER FOUR BITS ARE VALID
;	adi		11100000b					; ENABLE LBA BITS 5:7=111 IN IDE_LBA3
	sta		IDE$LBA3
	ani		00010000b				; separate dev select bit
	sta		IDE$DEV					; save device select bit
;
	lxi		h,SECTOR$BUFFER	
	call	read$sector				; READ THE IDE HARD DISK SECTOR
									; NEED TO ADD ERROR CHECKING HERE, CARRY FLAG IS SET IF IDE_READ_SECTOR SUCCESS
									; COMPUTE STARTING ADDRESS OF CP/M SECTOR IN READ IDE HD SECTOR BUFFER

	lxi		h,SECTOR$BUFFER 		; LOAD HL WITH SECTOR BUFFER ADDRESS
	lda		SECTOR$INDEX	 		; GET THE SECTOR INDEX (CP/M SECTOR OFFSET IN BUFFER)
	rrc								; MOVE BIT 0 TO BIT 7
	rrc								; DO AGAIN - IN EFFECT MULTIPLY BY 64
	mvi		d,0						; PUT RESULT AS 16 VALUE IN DE, UPPER BYTE IN D IS $00
	mov		e,a						; PUT ADDRESS OFFSET IN E
	dad		d						; MULTIPLY BY 2, TOTAL MULTIPLICATION IS X 128
	dad		d						; CP/M SECTOR STARTING ADDRESS IN IDE HD SECTOR BUFFER

									; COPY CP/M SECTOR TO BDOS DMA ADDRESS BUFFER
	mov		d,h						; TRANSFER HL REGISTERS TO DE
	mov		e,l
	lhld	@dma					; LOAD HL WITH DMA ADDRESS
	lxi		b,128
	;
	call	xfer					; transfer data to dma buffer
	;
	mvi		a,0						; RETURN ERROR CODE READ SUCCESSFUL A=0
	ret



	;read a sector, specified by the 4 bytes in "lba",
	;Return, acc is zero on success, non-zero for an error
read$sector:

	push	h					; save buffer address
	call	ide$select			; select the appropriate physical drive
	
	call	ide$wait$not$busy	;make sure drive is ready
	call	wr$lba				;tell it which sector we want

	call	ide$wait$not$busy

	mvi		a, ide$cmd$read
	out		ide$command

	call	ide$wait$drq		;wait until it's got the data
	bit		0,a					;check for error bit set
	jnz		get$err

;	lxi		h,sector$buffer		;read data into temp buffer
	pop		h					; get buffer address
	
	call	read$data			;grab the data

	mvi		a,0
	ret


ec$write:

WRITE$HDPART1:

	call	get$offset			; calculate the appropriate LBA offset for the relative drive

								; BDOS TRACK PARAMETER (16 BITS)
								; BDOS SECTOR PARAMETER (16 BITS)

	lhld	@trk				; LOAD TRACK # (WORD)
	mov		b,l					; SAVE LOWER 8 BITS (TRACK # 0-255)
	lhld	@sect				; LOAD SECTOR # (WORD)
	mov		h,b					; HL IS 8 BIT TRACK IN H, 8 BIT SECTOR IN L

	CALL	CONVERT$IDE$SECTOR$CPM ; COMPUTE WHERE THE CP/M SECTOR IS ON THE
								; IDE PARTITION
								; MAP COMPUTED IDE HD SECTOR TO LBA REGISTERS
								; LBA REGISTERS STORE 28 BIT VALUE OF IDE HD SECTOR ADDRESS

	lda		LBA$TARGET$LO 		; LOAD LBA REGISTER 0 WITH SECTOR ADDRESS TO READ
	sta		IDE$LBA0
	lda		LBA$TARGET$LO+1 	; LOAD LBA REGISTER 1 WITH SECTOR ADDRESS TO READ
	sta		IDE$LBA1
	lda		LBA$TARGET$HI 		; LOAD LBA REGISTER 2 WITH SECTOR ADDRESS TO READ
	sta		IDE$LBA2
	lda		LBA$TARGET$HI+1		 ; LOAD LBA REGISTER 3 WITH SECTOR ADDRESS TO READ
;	ani		00001111b			; ONLY LOWER FOUR BITS ARE VALID
;	adi		11100000b			; ENABLE LBA BITS 5:7=111 IN IDE_LBA3
	sta		IDE$LBA3

	lxi		h,sector$buffer
								; READ IDE HD SECTOR
	call	read$sector			; READ THE IDE HARD DISK SECTOR

; NEED TO ADD ERROR CHECKING HERE, CARRY FLAG IS SET IF IDE_READ_SECTOR SUCCESS

								; COMPUTE STARTING ADDRESS OF CP/M SECTOR IN READ IDE HD SECTOR BUFFER

	lxi		h,SECTOR$BUFFER 	; LOAD HL WITH SECTOR BUFFER ADDRESS
	lda		SECTOR$INDEX 		; GET THE SECTOR INDEX (CP/M SECTOR OFFSET IN BUFFER)
	rrc							; MOVE BIT 0 TO BIT 7
	rrc							; DO AGAIN - IN EFFECT MULTIPLY BY 64
	mvi		d,00h				; PUT RESULT AS 16 VALUE IN DE, UPPER BYTE IN D IS $00
	mov		e,a					; PUT ADDRESS OFFSET IN E
	dad		d					; CP/M SECTOR STARTING ADDRESS IN IDE HD SECTOR BUFFER
	dad		d					; MULTIPLY BY 2, TOTAL MULTIPLICATION IS X 128

	shld		SECST			; KEEP CP/M SECTOR ADDRESS FOR LATER USE

								; COPY CP/M SECTOR FROM BDOS DMA ADDRESS BUFFER

	lhld	@dma				; LOAD HL WITH DMA ADDRESS (WHERE THE DATA TO BE WRITTEN IS)
	mov		d,h					; TRANSFER HL REGISTERS TO DE
	mov		e,l
	lhld	SECST				; LOAD CP/M SECTOR ADDRESS (WHERE THE DATA IS TO BE WRITTEN)
	lxi		b,128

	call	xfer				; move data from dma buffer to sector buffer
	

				; IDE HD SECTOR IS NOW UPDATED WITH CURRENT CP/M SECTOR DATA SO WRITE TO DISK

	lxi		h,sector$buffer
	CALL	write$sector 		; WRITE THE UPDATED IDE HARD DISK SECTOR

; NEED TO ADD ERROR CHECKING HERE, CARRY FLAG IS SET IF IDE_WRITE_SECTOR SUCCES

	mvi		A,00h		; RETURN ERROR CODE WRITE SUCCESSFUL A=0
	RET
	



write$sector:
	push	h					; save buffer address
	call	ide$select			; select the appropriate physical drive
	call	ide$wait$not$busy	;make sure drive is ready
	call	wr$lba				;tell it which sector we want
 
	mvi		a, ide$cmd$write
	out		ide$command

	call	ide$wait$drq		;wait unit it wants the data
	bit		0,a					; check for error returned
	jnz		get$err
	
;	lxi		h, sector$buffer
	pop		h					; restore buffer address
	
	call	write$data			;give the data to the drive
	call	ide$wait$not$busy	;wait until the write is complete
	bit		0,a
	jnz		get$err
	mvi		a,0
	ret
	
	
;---------------------------------------------------------------------	
; get$offset use the @rdrv variable as an index into the memory based partition table to derive an LBA offset
; this allows  common read/write routines to access any logical drive using the partition table
;
get$offset:	
	lda		@rdrv				; which partition are we going to use
	stc
	cmc
	ral							; *2
	ral							; *4
	ral							;*8
	lxi		b,0					; get index into bc
	mov		c,a
	
	lxi		h,p$table			; get base address of partition table
	dad		b					; calculate the appropriate entry
	mov		e,m					; get low word into DE
	inx		h
	mov		d,m
	inx		h

	push	d					; save in stack
	mov		e,m					; now get hi word into DE
	inx		h
	mov		d,m
	inx		h
	
	xchg						; get ready to save values
	shld	LBA$OFFSET$HI

	pop		h
	shld	LBA$OFFSET$LO

	ret
	
;-----------------------------------------------------------------------

	cseg							; must be in common memory
;
;	Transfer routine to move data in and out of the sector buffer
; 	for banked system this must be located in common memory
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
	
;-----------------------------------------------------------------------

	desg							; the rest is banked


CONVERT$IDE$SECTOR$CPM:

				; COMPUTES WHERE THE CP/M SECTOR IS IN THE IDE PARTITION
				; IDE HD SECTORS ARE 512 BYTES EACH, CP/M SECTORS ARE 128 BYTES EACH
				; MAXIMUM SIZE OF CP/M DISK IS 8 MB = 65536 (16 BITS) X 128 BYTES PER SECTOR
				; IDE HD PARTITION CAN HAVE AT MOST 16384 IDE SECTORS -> 65536 CP/M SECTORS
				; EACH IDE HD SECTOR CONTAINS 4 ADJACENT CP/M SECTORS
				; 
				; INPUT:
				; IDE HD PARTITION STARTING SECTOR NUMBER (FROM PARTITION TABLE)
				;  - LOWER 16 BITS STORED IN LBA_OFFSET_LO
				;  - UPPER 16 BITS STORED IN LBA_OFFSET_HI
				; PARTITION OFFSET IN HL (16 BITS)
				;  - A UNIQUELY COMPUTED FUNCTION BASED ON GEOMETRY OF DISKS NUMBER OF
				;    CP/M TRACKS AND SECTORS SPECIFIED IN DPB
				; 
				; 
				; OUTPUT:
				; IDE TARGET SECTOR (SENT TO IDE HD CONTROLLER FOR READ OPERATION)
				;  - LOWER 16 BITS STORED IN LBA_TARGET_LO
				;  - UPPER 16 BITS STORED IN LBA_TARGET_HI
				; CP/M TO IDE HD SECTOR MAPPING PARAMETER STORED IN SECTOR_INDEX
				;  - 8 BIT VALUE WITH 4 LEGAL STATES (00, 01, 02, 04) WHICH IS
				;    TO BE USED TO COMPUTE STARTING ADDRESS OF 128 BYTE CP/M SECTOR ONCE
				;    512 BYTE IDE HD SECTOR READ INTO MEMORY BUFFER
				; 

				; ROTATE WITH CARRY 16 BIT TRACK,SECTOR VALUE IN HL TO GET 14 BIT IDE HD
				; TARGET SECTOR IN PARTITION
				; KEEP LAST TWO BITS IN B FOR IDE HD SECTOR TO CP/M SECTOR TRANSLATION

				; COMPUTE SECTOR_INDEX 

	xra		a				; ZERO ACCUMULATOR
	mov		a,l				; STORE LAST 2 BITS OF L IN B
	ani		00000011b		; 
	mov		b,a
	sta		SECTOR$INDEX	; LOCATES WHERE THE 128 BYTE CP/M SECTOR
							; IS WITHIN THE 512 BYTE IDE HD SECTOR
							; COMPUTE WHICH IDE HD SECTOR TO READ TO WITHIN 4 CP/M SECTORS 
							; SHIFTS 16 BIT PARTITION OFFSET TO THE RIGHT 2 BITS AND ADDS RESULT TO
							; IDE HD PARTITION STARTING SECTOR
	stc						; SHIFT PARTITION OFFSET RIGHT 1 BIT
	cmc						; CLEAR CARRY FLAG
	mov		a,h				; 16 BIT ROTATE HL WITH CARRY
	rar
	mov		h,a				; ROTATE HL RIGHT 1 BIT (DIVIDE BY 2)
	mov		a,l
	rar
	mov		l,a

							; SHIFT PARTITION OFFSET RIGHT 1 BIT
	stc
	cmc						; CLEAR CARRY FLAG
	mov		a,h				; 16 BIT ROTATE HL WITH CARRY
	rar
	mov		h,a				; ROTATE HL RIGHT 1 BIT (DIVIDE BY 2)
	mov		a,l
	rar
	mov		l,a

				; ADD RESULTING 14 BIT VALUE TO IDE HD PARTITION STARTING SECTOR
				; STORE RESULT IN IDE HD TARGET SECTOR PARAMETER

	lda		LBA$OFFSET$LO	 		; 16 BIT ADD OF LBA_OFFSET_LO WITH HL
	ADD		L
	sta		LBA$TARGET$LO
	lda		LBA$OFFSET$LO+1
	adc		h
	sta		LBA$TARGET$LO+1		 	; STORE OVERFLOW BIT IN CARRY

	lxi		h,0000h
	lda		LBA$OFFSET$HI	 		; 16 BIT ADD WITH CARRY OF LBA_OFFSET_HI WITH $0000
	adc		l
	sta		LBA$TARGET$HI
	lda		LBA$OFFSET$HI+1
	adc		h
	sta		LBA$TARGET$HI+1
	ret
	
;-----------------------------------------------------------------------------
	
ide$wait$not$busy:
	in		ide$status		;wait for RDY bit to be set
	bit		7,a
	jnz		ide$wait$not$busy
	ret


ide$wait$ready:
	in		ide$status		;wait for RDY bit to be set
	bit		6,a					; test for Drive Ready
	jz		ide$wait$ready
	bit		7,a					; test for busy
	jnz		ide$wait$ready
	ret

	;Wait for the drive to be ready to transfer data.
	;Returns the drive's status in Acc
ide$wait$drq:
	in		ide$status			;wait for DRQ bit to be set
	bit		3,a					; wait for drq
	jz		ide$wait$drq
	ret

	
;------------------------------------------------------------------------------

	;Read a block of 512 bytes (one sector) from the drive
	;and store it in memory @ HL
read$data:
	mvi		b, 0			; word counter
rdblk2:
	call	ide$wait$drq
	in		ide$data$lo
	mov		m, a
	inx		h

	in		ide$data$hi
	mov		m, a
	inx		h

	djnz	rdblk2
	ret

;-----------------------------------------------------------------------------

	;Write a block of 512 bytes (at HL) to the drive
write$data:
	mvi		b,0
wrblk2: 
	call	ide$wait$drq
	
	inx		h
	mov		a,m
	out		ide$data$hi
	dcx		h
	
	mov		a,m
	out		ide$data$lo
	inx		h
	inx		h
	
	djnz	wrblk2
	ret


;-----------------------------------------------------------------------------

	;write the logical block address to the drive's registers
wr$lba:
	lda		IDE$LBA0+3		; MSB
;	ani		0fh
	ani		00011111b		; Unit number is in lba3
	ori		0e0h			; Enable LBA addressing
	out		ide$head
	
	lda		IDE$LBA0+2
	out		ide$cyl$msb
	
	lda		IDE$LBA0+1
	out		ide$cyl$lsb
	
	lda		IDE$LBA0+0		; LSB
	out		ide$sector
	
	mvi		a,1
	out		ide$sec$cnt
	ret
	
;-----------------------------------------------------------------------------
get$err:
	in		ide$err
	ana		a
	jz		gerr2
	
	push	psw
	lxi		h,err$msg		; send out error message header
	call	?pmsg
	
	mvi		h,0
	pop		psw
	push	psw
	mov		l,a				
	call	?pdec			; now print IDE status
	
	lxi		h,crlf
	call	?pmsg
	
	pop		psw
	ret
	
gerr2:
	mvi		a, 255
	ret

err$msg:
	db	'IDE BIOS Error, status=',0



ide$select:
	lda		IDE$CURR$DEV		; get current drive
	mov		b,a
	lda		IDE$DEV				; get selected drive
	cmp		b					; Have we changed devices?
	rz							; if no then select not necessary

	sta		IDE$CURR$DEV		; update current device
	
	ani		00010000b			; isolate unit select bit
	ori		11100000b			; set LBA mode
	out		ide$head	

	call	ide$wait$ready
	ret							; end of device selection


	
		;initialize the ide drive
ide$init:
	mvi		a, 10100000b		; drive 0 LBA mode
	out		ide$head
init1:	
	in		ide$status
								;should probably check for a timeout here
	bit		6,a					; wait for RDY bit to be set
	jz		init1
	bit		7,a
	jnz		init1				;wait for BSY bit to be clear
	ret

	end
