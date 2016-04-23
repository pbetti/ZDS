	title 'ECB Floppy Disk drive handler for the N8VEM SBC'

;    CP/M-80 Version 3     --  Modular BIOS

;	Disk I/O Module for ECB Diskio FDC Port

	;	Initial version 0.01,
	;		Single density only .	- MJS, 6 Sep 2009

	true	equ -1
	false	equ not true

	banked	equ true	
	
	dseg

    ; Disk drive dispatching tables for linked BIOS

	public	ecfd0

    ; Variables containing parameters passed by BDOS

	extrn	@adrv,@rdrv
	extrn	@dma,@trk,@sect
	extrn	@dbnk, @cbnk

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
	extrn	?bank			; bank selection


    ; Port Address Equates

	;maclib ports

	

; IDE REGISTER			IO PORT			; FUNCTION
FMSR				EQU	036H		; ADDRESS OF MAIN STATUS REGISTER
FDATA				EQU	037H		; FLOPPY DATA REGISTER
FLATCH				EQU	03AH		; FLOPPY CONFIGURATION LATCH
FDMA				EQU	03CH		; PSEUDO DMA ADDRESS
;
; FDC CONFIGURATION LATCH OUTPUT BIT PATTERNS
MOTOR				EQU	00000000b	; BIT PATTERN IN LATCH FOR MOTOR CONTROL (ON)
TERMCN				EQU	00000001b	; BIT PATTERN IN LATCH TO WRITE A TC STROBE
RESETL				EQU	00000010b	; BIT PATTERN IN LATCH TO RESET ALL BITS
MINI				EQU	00000100b	; BIT PATTERN IN LATCH TO SET MINI MODE FDC9229 LOW DENS=1, HIGH DENS=0
PRECOMP				EQU	00100000b	; BIT PATTERN IN LATCH TO SET WRITE PRECOMP 125 NS:
FDDENSITY			EQU	01000000b	; BIT PATTERN IN LATCH TO FLOPPY LOW DENSITY (HIGH IS 0)
FDREADY				EQU	10000000b	; BIT PATTERN IN LATCH TO FLOPPY READY (P-34):



    ; CP/M 3 Disk definition macros

	maclib cpm3

    ; Z80 macro library instruction definitions

	maclib z80

    ; common control characters

cr		equ 13
lf		equ 10
bell	equ 7


    ; Extended Disk Parameter Headers (XPDHs)

		dw	fd$write
		dw	fd$read
		dw	fd$login
		dw	fd$init
		db	0,0					; relative drive zero
ecfd0:
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

dpb0:							; DISK PARAMETER BLOCK (FLOPPY DISK 720KB)
		DW  36					; 36 SECTORS OF 128 BYTES PER 4.5K TRACK
		DB  4					; BLOCK SHIFT FACTOR (SIZE OF ALLOCATION BLOCK)
		DB  15					; PART OF THE ALLOCATION BLOCK SIZE MATH
		DB  0						; DEFINES SIZE OF EXTENT (DIRECTORY INFO);
;		DB  1					; DEFINES SIZE OF EXTENT (DIRECTORY INFO)
		DW  350					; BLOCKSIZE [2048] * NUMBER OF BLOCKS + 1 = DRIVE SIZE
		DW  127					; NUMBER OF DIRECTORY ENTRIES
		DB  11000000b			; BIT MAP OF SPACE ALLOCATED TO DIRECTORY
		DB  00000000b			; DIRECTORY CAN HAVE UP TO 16 BLOCKS ALLOCATED
		DW  32					; SIZE OF DIRECTORY CHECK [0 IF NON REMOVEABLE]
		DW  4					; FIRST 4 TRACKS TRACKS RESERVED (18K FOR SYSTEM)
		DB	0,0					; physical sector size and shift (bios is de-blocking)

;trans	skew 26,6,1		
		
		
TMPBUF:							; TEMPORARY BUFFER FOR MEM DISK TRANSFERS
SECTOR$BUFFER:	DS	512			; STORAGE FOR 512 BYTE IDE HD SECTOR		
spare			ds	20			;spare
FLOPPYSTACK		DB	00				;**** needs attention ***
PARKSTACK		DB	00,00,00,00
		
	dseg	; rest is banked


		

SECTOR$INDEX:	DB	0			; WHERE 128 BYTE CP/M SECTOR IS IN 512 BYTE IDE HD SECTOR
SECST:			DW	0			; SECTOR IN ROM/RAM START ADDRESS
pTRACK			DS 2			; TWO BYTES FOR TRACK #
pSECTOR 		DS 2			; TWO BYTES FOR SECTOR #


;
; DISK COMMAND BLOCK
;
CMD:		DB	0			; COMMAND READ OR WRITE,
UNIT:		DB	0			; PHYSICAL DRIVE 0->3
HEAD:		DB	0			; HEAD SEL 0 OR 1
DENS:		DB	2			; DENSITY
EOTSEC:		DB	09			; LAST SECTOR OF TRACK
GAP:		DB	1BH			; VALUE FOR IRG <GAP3>
SECSIZ:		DB	80H			; HOW MANY BYTES TO TRANSFER/4
DTL:		DB	0FFH			; SIZE OF SECTOR
SRTHUT:		DB	7FH			; STEP RATE AND HEAD UNLOAD TIME
HDLT:		DB	05H			; HEAD LOAD TIME
MIN:		DB	MINI			; LATCH BIT PATTERN FOR FDC9229 MINITRUE
PRE:		DB	PRECOMP			; LATCH BIT PATTERN FOR FDC9229 PRECOMP 125ns
;
; FLOPPY STATUS RESULT STORAGE
;
ST0:		DB	0			; STORE STATUS 0
ST1:		DB	0			; ST1
ST2:		DB	0			; ST2
SCYL:		DB	0			; TRACK
SHEAD:		DB	0			; HEAD 0 OR 1
SREC:		DB	0			; SECTOR
SNBIT:		DB	0			; DENSITY
ST0A:		DB	0			; STORE STATUS 0
ST1A:		DB	0			; ST1
RETRY		DB	0			; RETRIES

FLATCH$STORE:
			DB	00
TRACK:		DS	2			; TWO BYTES FOR TRACK #
SECTOR:		DS	2			; TWO BYTES FOR SECTOR #








    ; Disk I/O routines for standardized BIOS interface

; Initialization entry point.

;		called for first time initialization.


fd$init:
	call	SETUPDRIVE
	ret

fd$login:
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

fd$read:
READ$FLOPPY$DISK:

	di						; DISABLE INTERRUPTS

	lxi		h,0
	dad		sp
	shld	PARKSTACK		; SAVE STACK POINTER.
	lxi		sp,FLOPPYSTACK	;
	

				; BDOS TRACK PARAMETER (16 BITS)
				; BDOS SECTOR PARAMETER (16 BITS)

	lda		@trk			; LOAD TRACK # (LOW BYTE)
	ani		1				; FILTER OUT HEAD
	sta		HEAD			; STORE HEAD
	lda		@trk			; SAVE TRACK IN A
	
	SRLR		A					; REMOVE HEAD BIT	
	
	sta		pTRACK			; STORE IN TRACK

	
	lda		@sect			; LOAD SECTOR # (LOW BYTE)
	sta		SECTOR$INDEX	; STORE SECTOR IN SECTOR INDEX
	
	SRLR		A		; 
	SRLR		A		; DIVIDE BY 4 (FOR BLOCKING)
	
	
	sta		pSECTOR			; STORE IN SECTOR
	
	lda		SECTOR$INDEX
	ani		03H		;
	sta		SECTOR$INDEX

	
	mvi		a,20			; 5 RETRIES
	sta		RETRY

READ$FLOPPY$DISK$RETRY:
	call	FLOPPYREAD	; READ THE FLOPPY DISK SECTOR
	lda		ST0			;
	ani		0F8H		; MASK OF DRIVE AND HEAD SELECTION
	mov		b,a			;
	lda		ST1			;
	ora		B			; IF ZERO READ WAS OK
	jz		READ$FLOPPY$DISK$OK
	lda		RETRY
	dcr		a
	sta		RETRY
	jnz		READ$FLOPPY$DISK$RETRY
	lda		ST1
	jmp 	READ$FLOPPY$DISK$EXIT	; ERROR, RETURN ERROR TO BDOS

READ$FLOPPY$DISK$OK:
								; COMPUTE STARTING ADDRESS OF CP/M SECTOR IN READ SECTOR BUFFER
	lxi		h,SECTOR$BUFFER 	; LOAD HL WITH SECTOR BUFFER ADDRESS
	lda		SECTOR$INDEX 		; GET THE SECTOR INDEX (CP/M SECTOR OFFSET IN BUFFER)
	rrc							; MOVE BIT 0 TO BIT 7
	rrc							; DO AGAIN - IN EFFECT MULTIPLY BY 4
	mvi		d,0					; PUT RESULT AS 16 VALUE IN DE, UPPER BYTE IN D IS $00
	mov		e,a					; PUT ADDRESS OFFSET IN E
	dad		d					; MULTIPLY BY 2, TOTAL MULTIPLICATION IS X 128
	dad		d					; CP/M SECTOR STARTING ADDRESS IN IDE HD SECTOR BUFFER
								; COPY CP/M SECTOR TO BDOS DMA ADDRESS BUFFER
	mov		d,h					; TRANSFER HL REGISTERS TO DE
	mov		e,l
	lhld	@dma				; LOAD HL WITH DMA ADDRESS
	
	lxi		b,128
;	call	?move
	call	xfer				; move data to TPA bank
	
	mvi		a,0					; NO ERROR
READ$FLOPPY$DISK$EXIT:	
	lhld	PARKSTACK
	sphl
	ei							; RE-ENABLE INTERRUPTS
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




	


fd$write:

WRITE$FLOPPY$DISK:

	di								; DISABLE INTERRUPTS

	lxi		h,0
	dad		sp
	shld	PARKSTACK				; SAVE STACK POINTER.
	lxi		sp,FLOPPYSTACK	;

	

				; BDOS TRACK PARAMETER (16 BITS)
				; BDOS SECTOR PARAMETER (16 BITS)

	lda		@trk					; LOAD TRACK # (LOW BYTE)
	ani		01						; FILTER OUT HEAD
	sta		HEAD					; STORE HEAD
	lda		@trk					; SAVE TRACK IN A
	SRLR	A							; REMOVE HEAD BIT	
	sta		pTRACK					; STORE IN TRACK

	
	lda		@sect					; LOAD SECTOR # (LOW BYTE)
	sta		SECTOR$INDEX			; STORE SECTOR IN SECTOR INDEX
	
	SRLR		A		; 
	SRLR		A		; DIVIDE BY 4 (FOR BLOCKING)
	
	sta		pSECTOR					; STORE IN SECTOR
	lda		SECTOR$INDEX
	ani		03		;
	sta		SECTOR$INDEX
	
	mvi		a,20					; 5 RETRIES
	sta		RETRY	;

WRITE$READ$FLOPPY$DISK$RETRY:
	call	FLOPPYREAD			; READ THE FLOPPY DISK SECTOR
	lda		ST0		;
	ani		0F8h				; MASK OF DRIVE AND HEAD SELECTION
	mov		b,a
	lda		ST1
	ora		b					; IF ZERO READ WAS OK
	jz		WRITE$READ$FLOPPY$DISK$OK
	lda		RETRY	;
	dcr		a		;
	sta		RETRY	;
	jnz		WRITE$READ$FLOPPY$DISK$RETRY
	jmp	 	WRITE$FLOPPY$DISK$OK	; ERROR, RETURN ERROR TO BDOS
	
WRITE$READ$FLOPPY$DISK$OK:	
							; COMPUTE STARTING ADDRESS OF CP/M SECTOR IN READ SECTOR BUFFER	
	lxi		h,SECTOR$BUFFER ; LOAD HL WITH SECTOR BUFFER ADDRESS
	lda		SECTOR$INDEX	 ; GET THE SECTOR INDEX (CP/M SECTOR OFFSET IN BUFFER)
	rrc						; MOVE BIT 0 TO BIT 7
	rrc						; DO AGAIN - IN EFFECT MULTIPLY BY 64
	mvi		d,0				; PUT RESULT AS 16 VALUE IN DE, UPPER BYTE IN D IS $00
	mov		e,a				; PUT ADDRESS OFFSET IN E
	dad		d				; CP/M SECTOR STARTING ADDRESS IN IDE HD SECTOR BUFFER
	dad		d				; MULTIPLY BY 2, TOTAL MULTIPLICATION IS X 128

	shld	SECST			; KEEP CP/M SECTOR ADDRESS FOR LATER USE

							; COPY CP/M SECTOR FROM BDOS DMA ADDRESS BUFFER
		
	
	lhld	@dma			; LOAD HL WITH DMA ADDRESS (WHERE THE DATA TO BE WRITTEN IS)
	mov		d,h				; TRANSFER HL REGISTERS TO DE
	mov		e,l
	lhld	SECST			; LOAD CP/M SECTOR ADDRESS (WHERE THE DATA IS TO BE WRITTEN)

	lxi		b,128
;	call	?move
	call	xfer			; move data from dma buffer to sector buffer


							; floppy SECTOR IS NOW UPDATED WITH CURRENT CP/M SECTOR DATA SO WRITE TO DISK
	mvi		a,20			; 5 RETRIES
	sta		RETRY	;

WRITE$FLOPPY$DISK$RETRY:
	call	FLOPPYWRITE		; WRITE THE FLOPPY DISK SECTOR
	lda		ST0		;
	ani		0F8h			; MASK OF DRIVE AND HEAD SELECTION
	mov		b,a		;
	lda		ST1		;
	ora		b			; IF ZERO READ WAS OK
	jz		WRITE$FLOPPY$DISK$OK
	lda		RETRY	;
	dcr		a		;
	sta		RETRY	;
	jnz		WRITE$FLOPPY$DISK$RETRY
WRITE$FLOPPY$DISK$OK:	
	lda		ST1		;

	lhld	PARKSTACK
	sphl;

	ei			; RE-ENABLE INTERRUPTS


	ret


	
	
;
;
;	SETUP FLOPPY DRIVE SETTINGS 
;
;
;
;
SETUPDRIVE:
	mvi		a,RESETL		; RESET SETTINGS
	ori		MINI			; SELECT MINI FLOPPY (low dens=1, high dens=0)
	ori		PRECOMP			; SELECT PRECOMP 
	ori		FDDENSITY		; SELECT DENSITY
	ori		FDREADY			; SELECT READY SIGNAL
	sta		FLATCH$STORE	; SAVE SETTINGS
	
	call	OUTFLATCH		; OUTPUT TO CONTROLLER
	
	mvi		a,01h			;
	sta		UNIT		; SET UNIT 1
	mvi		a,2			; DENSITY
	sta		DENS		;
	mvi		a,09h			;
	sta		EOTSEC		; LAST SECTOR OF TRACK			
	mvi		a,7Fh			;
	sta		SRTHUT		; STEP RATE AND HEAD UNLOAD TIME
	mvi		a,05H			;
	sta		HDLT			; HEAD LOAD TIME
	mvi		a,0Dh			;
	sta		GAP			; GAP 
	mvi		a,80h			;
	sta		SECSIZ		; SECTOR SIZE /4
	;
	call	CHECKINT		; CHECK INTERRUPT STATUS, MAKE SURE IT IS CLEAR
	call	CHECKINT		; CHECK INTERRUPT STATUS, MAKE SURE IT IS CLEAR
	call	CHECKINT		; CHECK INTERRUPT STATUS, MAKE SURE IT IS CLEAR
	call	CHECKINT		; CHECK INTERRUPT STATUS, MAKE SURE IT IS CLEAR
	call	CHECKINT		; CHECK INTERRUPT STATUS, MAKE SURE IT IS CLEAR
	call	CHECKINT		; CHECK INTERRUPT STATUS, MAKE SURE IT IS CLEAR
	;					
	lxi		h,FLATCH$STORE	; POINT TO FLATCH
	res		1,m				; SET MOTOR ON
	call	OUTFLATCH		; OUTPUT TO CONTROLLER
	nop				;
	nop				;
	mvi		a,00h			; ZERO TRACK
	sta		pTRACK			; STORE TRACK
	call	SETTRACK		; DO IT	
	nop				;
	nop				;
	lxi		h,FLATCH$STORE	; POINT TO FLATCH
	setb		1,m			; SET MOTOR OFF
	call	OUTFLATCH		; OUTPUT TO CONTROLLER
	ret
;

;
;
;	SEND SETTINGS TO FLOPPY CONTROLLER
;
;
OUTFLATCH:
	lda		FLATCH$STORE	; SET A TO SETTINGS
	out		FLATCH			; OUTPUT TO CONTROLLER
	ret

		
;
;
; 	READ A FLOPPY DISK SECTOR 	
;
;	
FLOPPYREAD:
	mvi		a,46h			; BIT 6 SETS MFM, 06H IS READ COMMAND
	sta		CMD
	jmp		DSKOP
;
;
;
; 	WRITE A FLOPPY DISK SECTOR 	
;
;	
FLOPPYWRITE:
	mvi		a,45h			; BIT 6 SETS MFM, 05H IS WRITE COMMAND
	sta		CMD
	jmp		DSKOP
;
;
;
; 	PERFORM A DISK OPERATION 	
;
;		
DSKOP:
	lxi		h,FLATCH$STORE	; POINT TO FLATCH
	setb		1,m			; SET MOTOR OFF
	call	OUTFLATCH		; OUTPUT TO CONTROLLER
					;
	call	CHECKINT		; CHECK INTERRUPT STATUS, MAKE SURE IT IS CLEAR
	cpi		0FFh			; DID IT RETURN WITH ERROR CODE?
	jz		DSKEXIT			; IF YES, EXIT WITH ERROR CODE
	lda		UNIT			; GET DISK UNIT NUMBER
	ani		03h				; MASK FOR FOUR DRIVES.
	mov		b,a				; PARK IT IN B
	lda		HEAD			; GET HEAD SELECTION
	ani		01h				; INSURE SINGLE BIT
	ral
	ral						; MOVE HEAD TO BIT 2 POSITION
	ora		b				; OR HEAD TO UNIT BYTE IN COMMAND BLOCK
	sta		UNIT			; STORE IN UNIT
					;
	lxi		h,FLATCH$STORE	; POINT TO FLATCH
	res		1,m			; SET MOTOR ON
	call	OUTFLATCH		; OUTPUT TO CONTROLLER	
					;
	mvi		a,03h			; SPECIFY COMMAND
	call	PFDATA			; PUSH IT
	lda		SRTHUT			; STEP RATE AND HEAD UNLOAD TIME
	call	PFDATA			; PUSH THAT
	lda		HDLT			;
	call	PFDATA			; PUSH THAT
					;
	call	SETTRACK		; PERFORM SEEK TO TRACK
					;
	jnz		DSKEXIT			; IF ERROR, EXIT
					;
	lda		CMD				; WHAT COMMAND IS PENDING?
	ora		a				; SET FLAGS
	jmp		DOSO4			; NO, MUST BE READ OR WRITE COMMAND
DSKEXIT:	
	lxi		h,FLATCH$STORE		; POINT TO FLATCH
	setb		1,m				; SET MOTOR OFF
	call	OUTFLATCH		; OUTPUT TO CONTROLLER
				;
	ori		0FFh			; SET -1 IF ERROR
	ret

RESULT:	
	mvi		c,07h			; LOAD C WITH NUMBER OF STATUS BYTES
	lxi		h,ST0			; POINT TO STATS STORAGE
RS3:
	call	GFDATA			; GET FIRST BYTE
	mov		m,a			; SAVE IT
	inx		h			; POINTER++
	dcr		c			; CC-1
	jnz		RS3			; LOOP TIL C0
	lda		ST0			; LOAD STS0
	ani		0F8h		; MASK OFF DRIVE #
	mov		b,a			; PARK IT
	lda		ST1			; LOAD STS1
	ora		b			; ACC OR B ->ACC IF 0 THEN SUCCESS
					;

	
RSTEXIT:
	call	CHECKINT			; CHECK INTERRUPT STATUS, MAKE SURE IT IS CLEAR
	lxi		h,FLATCH$STORE		; POINT TO FLATCH
	setb		1,m				; SET MOTOR OFF
	call	OUTFLATCH			; OUTPUT TO CONTROLLER
	ret							; DONE RETURN TO CALLER.
	
	
DOSO4:
	lxi		h,SECTOR$BUFFER	; GET BUFFER ADDRESS TO HL
	lda		SECSIZ			; XFERLEN
	mov		c,a				; C WILL BE THE NUMBER OF TRANSACTIONS
							; DIVIDED BY 4
					
	lda		CMD		
	call	PFDATA			; PUSH COMMAND TO I8272
	lda		UNIT	
	call	PFDATA	
	lda		pTRACK	
	call	PFDATA	
	lda		HEAD	
	call	PFDATA	
	lda		pSECTOR	
	inr		a		
	call	PFDATA	
	lda		DENS	
	call	PFDATA			; WHAT DENSITY
	lda		EOTSEC	
	call	PFDATA			; ASSUME SC (SECTOR COUNT)  EOT
	lda		GAP			;
	call	PFDATA			; WHAT GAP IS NEEDED
	lda		DTL			; DTL, IS THE LAST COMMAND BYTE TO I8272
	call	PFDATAS
	lda		CMD			; READ IS 0 IS THIS A READ OR WRITE?
	ani		00000001b		; WRITE IS 1
	jnz		WRR				; JMP WRITE IF 1
;

	;
; PERFORM READ
; LOOP EXECUTES 4X, THIS ALLOWS C RATHER THAN BC AS COUNTER
; SAVING A FEW TSTATES. MAKES UP TO 1024 BYTE SECTORS POSSIBLE.
; FROM READ TO READ MUST NOT EXCEED 25US WORST CASE MIN.
; (76T STATES FOR 3MHZ 8085) or (100 T STATES FOR 4MHZ Z80)
;

RDD$POLL:
FDC$READP0:
	in		FMSR		;
	ora		a			; test if byte ready RQM1
	jp		FDC$READP0	; bit 7=0	;	
					;
	ani		20h			;
	jz		DSKOPEND		;jump if in results mode
					;
	in		FDATA		;
	mov		m,a
	inx		h


	
	
FDC$READP1:
	in		FMSR		;
	ora		a			;
	jp		FDC$READP1		;
					;
	ani		20h			;
	jz		DSKOPEND		;
					;
	in		FDATA		;
	mov		m,a
	inx		h			;
					;
FDC$READP2:
	in		FMSR		;
	ora		a			;
	jp		FDC$READP2		;
					;
	ani		20h			;
	jz		DSKOPEND		;
					;
	in		FDATA		;
	mov		m,a			;
	inx		h			;
					;
FDC$READP3:
	in		FMSR			; 11
	ora		a				; 4
	jp		FDC$READP3		; 10
					;
	ani		20h				; 7
	jz		DSKOPEND		; 10

	in		FDATA			; 11
	mov		m,a				; 10
	inx		h				; 11
					;
	dcr		c				; 4
	jnz		FDC$READP0		; 11



DSKOPEND:
	lxi		h,FLATCH$STORE	; POINT TO FLATCH
	setb		0,m			; SET TC
	call	OUTFLATCH		; OUTPUT TO CONTROLLER
	nop
	nop						; 2 MICROSECOND DELAY
	res		0,m			; RESET TC
	call	OUTFLATCH		; OUTPUT TO CONTROLLER
	nop
	nop						; 2 MICROSECOND DELAY
	nop
	nop						; 2 MICROSECOND DELAY
	setb		1,m			; TURN OFF MOTOR
	call	OUTFLATCH		; OUTPUT TO CONTROLLER
	jmp		RESULT			; GET STATUS BYTES <RESULT PHASE>

WRR:
FDC$WRITEP0:
	in		FMSR		;
	ora		a				; test if byte ready RQM1
	jp		FDC$WRITEP0		;	
					;
	ani		20h			;
	jz		DSKOPEND		;jump if in results mode
					;
	mov		a,m
	out		FDATA
	inx		h

FDC$WRITEP1:
	in		FMSR
	ora		a
	jp		FDC$WRITEP1

	ani		20h	
	jz		DSKOPEND

	mov		a,m
	out		FDATA
	inx		h

FDC$WRITEP2:
	in		FMSR		;
	ora		a			;
	jp		FDC$WRITEP2		;
					;
	ani		20h			;
	jz		DSKOPEND		;
					;
	mov		a,m
	out		FDATA		;	
	inx		h			;
					;
FDC$WRITEP3:
	in		FMSR		; 11
	ora		a			; 4
	jp		FDC$WRITEP3		; 10
					;
	ani		20h			; 7
	jz		DSKOPEND		; 10
					;
	mov		a,m
	out		FDATA		;	
	inx		h			; 11
					;
	dcr		c			; 4
	jnz		FDC$WRITEP0		; 11
	jmp		DSKOPEND		; 10
	
		
;
;
; 	SEEK TO A TRACK ON GIVEN UNIT
; 	A: TRACK #
;
;
SETTRACK:
							; ANY INTERUPT PENDING
							; IF YES FIND OUT WHY/CLEAR
	call	CHECKINT		; CHECK INTERRUPT STATUS, MAKE SURE IT IS CLEAR
	cpi		0FFH			; DID IT RETURN WITH ERROR CODE?
	jz		SETTRKEXIT

	lda		pTRACK			; GET TRACK
	ora		a				; SET FLAGS
	jz		RECAL			; IF 0 PERFORM RECAL INSTEAD OF SEEK
	mvi		a,0FH			; SEEK COMMAND
	call	PFDATA			; PUSH COMMAND
	lda		UNIT			; SAY WHICH UNIT
	call	PFDATA			; SEND THAT
	lda		pTRACK			; TO WHAT TRACK
	call	PFDATA			; SEND THAT TOO
	jmp		WAINT			; WAIT FOR INTERRUPT SAYING DONE
RECAL:
	mvi		a,07H			; RECAL TO TRACK 0
	call	PFDATA			; SEND IT
	lda		UNIT			; WHICH UNIT
	call	PFDATA			; SEND THAT TOO
;
WAINT:
;
	call	DELAYHSEC		; DELAY TO LET HEADS SETTLE BEFORE READ

							; WAIT HERE FOR INTERRPT SAYING DONE
							; LOOP TIL INTERRUPT
	call	CHECKINT		; CHECK INTERRUPT STATUS
;
SETTRKEXIT:
	ret


;
; WRITE A COMMAND OR PARAMETER SEQUENCE
;
; TRANSFERS ARE SYNCHONIZED BYT MSR D7 <RQM> AND D6 <DIO>
;	RQM  DIO
;	0	0	BUSY
;	1	0	WRITE TO DATA REGISTER PERMITTED
;	1	1	BYTE FOR READ BY HOST PENDING
;	0	1	BUSY
;
;
;
PFDATAS:
	push	psw			; STORE AF
PFDS1:
	in		FMSR		; READING OR WRITING IS KEYS TO D7 RQM
	ani		80H			; MASK OFF RQM BIT 
	jz		PFDS1			; WAIT FOR RQM TO BE TRUE.
	in		FMSR		; READ STATUS
	ani		40H			; WAITING FOR INPUT?
	cnz		ERRORT		; NO, SIGNAL ERROR
	pop		psw			; RESTORE AF
	out		FDATA		; OUTPUT A TO CONTROLLER
	ret		
	
;
;
; WRITE A COMMAND OR PARAMETER SEQUENCE
;
; TRANSFERS ARE SYNCHONIZED BYT MSR D7 <RQM> AND D6 <DIO>
;	RQM  DIO
;	0	0	BUSY
;	1	0	WRITE TO DATA REGISTER PERMITTED
;	1	1	BYTE FOR READ BY HOST PENDING
;	0	1	BUSY
;
;
;
PFDATA:
	push	psw			; STORE AF
PFD1:
	in		FMSR		; READING OR WRITING IS KEYS TO D7 RQM
	ani		80H			; MASK OFF RQM BIT 
	jz		PFD1			; WAIT FOR RQM TO BE TRUE.
	in		FMSR		; READ STATUS
	ani		40H			; WAITING FOR INPUT?
	cnz		ERRORT		; NO, SIGNAL ERROR
	pop		psw			; RESTORE AF
	out		FDATA		; OUTPUT A TO CONTROLLER
	nop					; WAIT 24 US BEFORE READING FMSR AGAIN
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	ret


;
;
; CHECK FOR ACTIVE FDC INTERRUPTS BEFORE GIVING I8272 COMMANDS
; POLL RQM FOR WHEN NOT BUSY AND THEN SEND FDC
; SENSE INTERRUPT COMMAND.  IF IT RETURNS WITH NON ZERO
; ERROR CODE, PASS BACK TO CALLING ROUTINE FOR HANDLING
;
;
CHECKINT:
	in		FMSR			; READING OR WRITING IS KEYS TO D7 RQM
	ani		80H				; MASK OFF RQM BIT
	jz		CHECKINT		; WAIT FOR RQM TO BE TRUE. WAIT UNTIL DONE
	in		FMSR			; READ STATUS
	ani		40H				; WAITING FOR INPUT?
	jnz		CHECKINTDONE	; NO, SIGNAL ERROR
	call	SENDINT			; SENSE INTERRUPT COMMAND
CHECKINTDONE:
	ret				;
	

;
;
; DELAY FOR 1/2 SECOND
;
;		
DELAYHSEC:
	lxi		H,0000H		; 65536
DELDM:
	nop					; (4 T) 
	nop					; (4 T)
	nop					; (4 T)
	nop					; (4 T)
	dcr		l			; (6 T)
	jnz		DELDM		; (10 T) 24 T  8 MICROSECONDS AT 4 MHZ
	dcr		h			; (6 T)
	jnz		DELDM		; (10 T) (8 US * 256) * 256  524288 US  .5 SECONDS
	ret

; ERRORT
;
; ERROR HANDLING
;
;			
ERRORT:
	in		FDATA		; CLEAR THE JUNK OUT OF DATA REGISTER
	in		FMSR		; CHECK WITH RQM
	ani		80H			; IF STILL NOT READY, READ OUT MORE JUNK
	jz		ERRORT		;
	mvi		a,0FFh				; RETURN ERROR CODE -1
					;
	ret
;SENDINT
;
; SENSE INTERRUPT COMMAND
;
;			
SENDINT:
	mvi		A,08H			; SENSE INTERRUPT COMMAND
	call	PFDATA			; SEND IT
	call	GFDATA			; GET RESULTS
	sta		ST0A			; STORE THAT
	ani		0c0h				; MASK OFF INTERRUPT STATUS BITS
	cpi		80h				; CHECK IF INVALID COMMAND
	jz		ENDSENDINT		; YES, EXIT
	call	GFDATA			; GET ANOTHER (STATUS CODE 1)
	sta		ST1A			; SAVE THAT
	lda		ST0A			; GET FIRST ONE
	ani		0C0H			; MASK OFF ALL BUT INTERRUPT CODE 00 IS NORMAL
ENDSENDINT:
	ret				;ANYTHING ELSE IS AN ERROR


;GFDATA
;
; GET DATA FROM FLOPPY CONTROLLER
;
; TRANSFERS ARE SYNCHONIZED BYT MSR D7 <RQM> AND D6 <DIO>
;	RQM  DIO
;	0	0	BUSY
;	1	0	WRITE TO DATA REGISTER PERMITTED
;	1	1	BYTE FOR READ BY HOST PENDING
;	0	1	BUSY
;
;
;		
GFDATA:
	in		FMSR		; READ STATUS BYTE
	ani		80H			; MASK OFF RQM
	jz		GFDATA		; LOOP WHILE BUSY
	in		FMSR		; READ STSTUS BUTE
	ani		40H			; MASK OFF DIO
	cz		ERRORT		; IF WRITE EXPECTED RUN ERRORRT
	in		FDATA		; READ DATA
	nop				; WAIT 24 US BEFORE READING FMSR AGAIN
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	nop				;
	ret
	


	end
