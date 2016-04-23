;	CP/M 3 LDRBIOS for the N8VEM Single Board Computer (ECB IDE Interface)
;
;	 by Max Scane AUG 2009
;
	maclib	z80
;
;	I/O ports
;
UART				EQU	68H		; N8VEM 16550 UART
MPCL$RAM			EQU	78H		; BASE IO ADDRESS OF RAM MEMORY PAGER CONFIGURATION LATCH
MPCL$ROM			EQU	7CH		; BASE IO ADDRESS OF ROM MEMORY PAGER CONFIGURATION LATCH
;
;
;; IDE REGISTER			IO PORT		; FUNCTION
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





;;IDE Command Constants.  These should never change.
ide$cmd$recal		EQU	10H
ide$cmd$read		EQU	20H
ide$cmd$write		EQU	30H
ide$cmd$init		EQU	91H
ide$cmd$id			EQU	0ECH
ide$cmd$spindown	EQU	0E0H
ide$cmd$spinup		EQU	0E1H

;
CR				EQU	13
LF				EQU 10
;
	CSEG
;
;	jump vector for individual subroutines
;	* needs to be implemented
;
	jmp		BOOT		; * perform cold start initialization
	jmp		WBOOT		;   perform warm start initialization
	jmp		CONST		;   check for console input char ready
	jmp		CONIN		;   read console character in
	jmp		CONOUT		; * write console character out
	jmp		LIST		;   write list character out
	jmp		AUXOUT		;   write auxiliary output char
	jmp		AUXIN		;   read auxiliary input char
	jmp		HOME		; * move head to track 0 on selcted disk
	jmp		SELDSK		; * select disk drive
	jmp		SETTRK		; * set track number
	jmp		SETSEC		; * set sector number
	jmp		SETDMA		; * set dma address
	jmp		READ		; * read specified sector
	jmp		WRITE		;   write specified sector
	jmp		LISTST		;   return list status
	jmp		SECTRAN		; * translate logical to physical sector
	jmp		CONOST		;   return output status of console
	jmp		AUXIST		;   return input status of aux. port
	jmp		AUXOST		;   return output status of aux. port
	jmp		DEVTBL		;   return address of character i/o table
	jmp		DEVINI		;   initialize character i/o devices
	jmp		DRVTBL		;   return address of disk drive table
	jmp		MULTIO		;   set number of sectors to read/write
	jmp		FLUSH		;   flush deblocking buffers
	jmp		MOVE		; * memory to memory move
	jmp		TIME		;   time set/get signal
	jmp		SELMEM		;   select bank of memory
	jmp		SETBNK		;   specify bank for dma operation
	jmp		XMOVE		;   set bank for memory dma transfer
	jmp		0			;   reserved for system implementor
	jmp		0			;   reserved for future use
	jmp		0			;   reserved for future use
;
;	fixed data tables for the N8VEM PP IDE 8MB disk
;
;	disk parameter header
;
DPH0:	
	DW	0			;sector translation table
	DB	0,0,0,0,0,0,0,0,0	;bdos scratch area
	DB	0			;media flag
	DW	DPB0			;disk parameter block
	DW	0FFFEH			;checksum vector
	DW	0FFFEH			;allocation vector
	DW	0FFFEH			;directory buffer control block
	DW	0FFFFH			;dtabcb not used
	DW	0FFFFH			;hashing not used
	DB	0				;hash bank


DPB0:					; DISK PARAMETER BLOCK (IDE HARD DISK 8MB)
	DW	256			; 256 SECTORS OF 128 BYTES PER 32K TRACK
	DB	5			; BLOCK SHIFT FACTOR (SIZE OF ALLOCATION BLOCK)
	DB	31			; PART OF THE ALLOCATION BLOCK SIZE MATH
	DB	1			; DEFINES SIZE OF EXTENT (DIRECTORY INFO)
	DW	2017		; BLOCKSIZE [4096] * NUMBER OF BLOCKS + 1 = DRIVE SIZE
						; HD PARTITION 3 IS 16128 SECTORS LONG
						; AT 512 BYTES EACH WHICH IS 
						; 2016 BLOCKS AT 4096 BYTES A PIECE.
	DW	511			; NUMBER OF DIRECTORY ENTRIES
	DB	11110000b	; BIT MAP OF SPACE ALLOCATED TO DIRECTORY
	DB	00000000b	; DIRECTORY CAN HAVE UP TO 16 BLOCKS ALLOCATED
	DW	0			; SIZE OF DIRECTORY CHECK [0 IF NON REMOVEABLE]
	DW	1			; 1 TRACK (32K) RESERVED FOR SYSTEM	
	DB	0,0			; physical sector size and shift (bios is de-blocking)



track:	ds	2
sector:	ds	2
dmaad:	ds	2
diskno:	ds	1

LBA$OFFSET$LO:	DW	0			; IDE HD PARTITION STARTING SECTOR (LOW 16 BITS)
LBA$OFFSET$HI:	DW	0			; IDE HD PARTITION STARTING SECTOR (HI 16 BITS, 12 USED)
LBA$TARGET$LO:	DW	0			; IDE HD PARTITION TARGET SECTOR (LOW 16 BITS)
LBA$TARGET$HI:	DW	0			; IDE HD PARTITION TARGET SECTOR (HI 16 BITS, 12 USED)
IDE$LBA0:		DS	1			; SET LBA 0:7
IDE$LBA1:		DS	1			; SET LBA 8:15
IDE$LBA2:		DS	1			; SET LBA 16:23
IDE$LBA3:		DS	1			; LOWEST 4 BITS USED ONLY TO ENABLE LBA MODE 
SECTOR$INDEX:	DB	0			; WHERE 128 BYTE CP/M SECTOR IS IN 512 BYTE IDE HD SECTOR
SECTOR$BUFFER:	DS	512			; STORAGE FOR 512 BYTE IDE HD SECTOR

;
;	signon message
;
signon:
	DB	13,10
	DB	'LDRBIOS3 V0.1 for the N8VEM SBC (ECB), '
	DB	'by Max Scane 2009'
	DB	CR,LF,0
;
;	end of fixed tables
;
;	individual subroutines to perform each function
;
BOOT:	
	lxi		h,signon	;print message
BOOTL:  
	mov		a,m
	ora		a
	jz		WBOOT
	mov		c,a
	call	CONOUT
	inx		h
	jmp		BOOTL
;
;	those are not implemented in loader bios
;
WBOOT:
CONST:
CONIN:
LIST:
AUXOUT:
AUXIN:
WRITE:
LISTST:
CONOST:
AUXIST:
AUXOST:
DEVTBL:
DEVINI:
DRVTBL:
MULTIO:
FLUSH:
TIME:
SELMEM:
SETBNK:
XMOVE:	RET
;
;	console character output from register c
;
CONOUT:
		in		UART+05h		; N8VEM UART
		ani		20h
		jz		conout
		mov		a,c
		out		UART
		ret
		
punch:
		mov		a,c
		ret

reader:
		mvi		a,1ah
		ani		07fh
		ret

rdrsts:
		mvi		a,0ffh
        ret

;
;	i/o drivers for the disk follow
;
;	move to the track 00 position of current drive
;	translate this call into a settrk call with parameter 00
;
HOME:	
		mvi		c,0			;select track 0
		jmp		SETTRK		;we will move to 00 on first read/write
;
;	select disk given by register C
;
SELDSK: 
		lxi		h,0000H		;error return code
		mov		a,c
		cpi		0			;we boot from drive 0 only
		rnz					;return error
							;disk number is in the proper range
							;return proper disk parameter header address
		sta		diskno
		lxi		h,DPH0
		ret
;
;	set track given by register c
;
SETTRK: 
		sbcd	track
		ret
;		mov		a,c
;		sta		track
;		ret
;
;	set sector given by register c
;
SETSEC:
		sbcd	sector
		ret
;		mov		a,c
;		sta		sector
;		ret
;
;	translate the sector given by BC using the
;	translate table given by DE
;
SECTRAN:
		mov		h,b 		; translation not required
		mov		l,c
		ret

;
;	set dma address given by registers b and c
;
SETDMA:
		mov		h,b
		mov		l,c
		shld	dmaad
		ret
;
;	perform read operation
;
READ:
READ$HDPART1:
	
	lxi		h,0001h				; INITIALIZE LBA OFFSET SECTOR LO WORD
	shld	LBA$OFFSET$LO
	lxi		h,0000h				; INITIALIZE LBA OFFSET SECTOR HI WORD
	shld	LBA$OFFSET$HI

									; BDOS TRACK PARAMETER (16 BITS)
									; BDOS SECTOR PARAMETER (16 BITS)

	lhld	track					; LOAD TRACK # (WORD)
	mov		B,L						; SAVE LOWER 8 BITS (TRACK # 0-255)
	lhld	sector					; LOAD SECTOR # (WORD)
	mov		H,B						; HL IS 8 BIT TRACK IN H, 8 BIT SECTOR IN L

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
	ani		00001111b				; ONLY LOWER FOUR BITS ARE VALID
	adi		11100000b				; ENABLE LBA BITS 5:7=111 IN IDE_LBA3
	sta		IDE$LBA3

		
	CALL	read$sector				; READ THE IDE HARD DISK SECTOR
									; NEED TO ADD ERROR CHECKING HERE, CARRY FLAG IS SET IF IDE_READ_SECTOR SUCCESS
									; COMPUTE STARTING ADDRESS OF CP/M SECTOR IN READ IDE HD SECTOR BUFFER

	lxi		H,SECTOR$BUFFER 		; LOAD HL WITH SECTOR BUFFER ADDRESS
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
	lhld	dmaad					; LOAD HL WITH DMA ADDRESS

	lxi		b,128
	call	move

	mvi		a,0							; RETURN ERROR CODE READ SUCCESSFUL A=0

	
	RET


; -----------------------------------------------------------------------------	
	;read a sector, specified by the 4 bytes in "lba",
	;Return, acc is zero on success, non-zero for an error

	read$sector:
	call	ide$wait$not$busy	;make sure drive is ready
	call	wr$lba				;tell it which sector we want
	call	ide$wait$not$busy
	mvi		a, ide$cmd$read
	out		ide$command
	call	ide$wait$drq		;wait until it's got the data
	bit		0,a					;check for error bit set
	jnz		get$err
	lxi		h,sector$buffer		;read data into temp buffer
	call	read$data			;grab the data
	mvi		a,0
	ret




;---------------------------------------------------------------------	
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

							; SHIFT PARTITION OFFSET RIGHT 1 BIT

	stc
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
	
	
	
	
;------------------------------------------------------------------------------
; IDE INTERNAL SUBROUTINES 
;------------------------------------------------------------------------------


	
;----------------------------------------------------------------------------
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
	mov		a,m
	out		ide$data$lo
	inx		h
	
	mov		a,m
	out		ide$data$hi
	inx		h
	
	djnz	wrblk2
	ret

;-----------------------------------------------------------------------------

	;write the logical block address to the drive's registers
wr$lba:
	lda		IDE$LBA0+3		; MSB
	ani		0fh
	ori		0e0h
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
	
;



	;when an error occurs, we get acc.0 set from a call to ide$drq
	;or ide$wait$not$busy (which read the drive's status register).  If
	;that error bit is set, we should jump here to read the drive's
	;explaination of the error, to be returned to the user.  If for
	;some reason the error code is zero (shouldn't happen), we'll
	;return 255, so that the main program can always depend on a
	;return of zero to indicate success.
get$err:
	in		ide$err
	ana		a
	jz		gerr2
	
	push	psw
	lxi		h,err$msg		; send out error message header
;	call	?pmsg
	
	mvi		h,0
	pop		psw
	push	psw
	mov		l,a				
;	call	?pdec			; now print IDE status
	
;	lxi		h,crlf
;	call	?pmsg
	
	pop		psw
	ret
	
gerr2:
	mvi		a, 255
	ret

err$msg:
	db	'IDE BIOS Error, status=',0
	
		
;-------------------------------------------------------------------------------


		;initialize the ide drive
ide$init:
	mvi		a, 10100000b
	out		ide$head
init1:	
	in		ide$status
						;should probably check for a timeout here
	bit		6,a			; wait for RDY bit to be set
	jz		init1
	bit		7,a
	jnz		init1	;wait for BSY bit to be clear
	ret


	

; -----------------------------------------------------------------------------
;
;   End of IDE Code
;
; -----------------------------------------------------------------------------
	

;	memory move
;
MOVE:
		xchg	
		ldir
		xchg
		ret

	
	END			;of bios
