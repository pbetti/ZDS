
	.Z80
	ASEG

;		      COPYFAST.ASM Version 4.3
;
;REVISED	2007/02/25 Piergiorgio Betti <pbetti@lpconsul.net>
;	EXTENDED DISK RANGE TO A-P (INSTEAD OF A-F)
;
;REVISED	11/03/87
;
;	IN ADDITION TO MAKING RAPID COPIES OF A DISK, COPYFAST
;	IS USEFUL FOR MAKING BACKUP COPIES OF A DISK THAT HAS
;	HAD A FILE DAMAGED IN SOME WAY. YOU CAN THEN USE THE
;	COPY WHEN TRYING TO RECOVER THE FILE WITH A DISK UTILITY.
;	(ASSUMING YOUR CONTROLLER CAN STILL READ THE SECTORS)
;
;	AS IT IS CURRENTLY CONFIGURED COPYFAST WILL CORRECTLY
;	COPY SYSTEM TRACKS OTHER THAN TRACK 0 ONLY IF THEY
;	ARE OF THE SAME FORMAT AND SECTOR COUNT AS THE DATA TRACKS.
;
;	Note: to save people time, don't bother to change
;	the DOC file just to update the change history.
;
	ORG	0100H
;
;
;	Equates
;
FALSE	EQU	0		; define false
TRUE	EQU	NOT FALSE	;  define true
;
EXITCP	EQU	0		; warm start return to CP/M
FCB	EQU	5CH		; default FCB address
;
CR	EQU	0DH		; ASCII Carriage return
LF	EQU	0AH		; ASCII line feed
CTRLC	EQU	3		; ASCII control-C
;
NOLOG	EQU	01		;CALL SELDSK WITH NO LOGON
LOGON	EQU	00		;CALL SELDSK WITH LOGON
;
;	User-modifiable switches
;
SINGLE	EQU	FALSE		; TRUE for single drive copy program
;
NOCOMP	EQU	FALSE		; TRUE if no read checking at all
;			;   (DOCOMP MUST BE FALSE)
;			; FALSE if read checking is done,
;			;   check DOCOMP
DOCOMP	EQU	TRUE		; TRUE if byte-by-byte comparison
;			; desired on read-after-write check
;			; Must be FALSE if NOCOMP is TRUE
	IF	NOCOMP AND DOCOMP
DOCOMP	DEFL	FALSE		; cause error
	ENDIF
;
NUMERR	EQU	2		; number of error retries done
;
BUFFNU	EQU	0		; the number of full track buffers
;	that will fit in your system. This figure includes
;	the space used by the read-back buffers, if used
;	(minimum 2). If zero, the number of buffers will
;	be automatically computed at execution.
;
;	The next two values specify the copy range, and the program
;	can be run in other ways by the parameter (first character
;	of the first filename) given when COPYFAST is first invoked:
;			(Note: only complete tracks are copied)
;
;	All	0-(Lastrk-1)	   ***	Entire disk
;	Data	Firstrk-(Lastrk-1)	CP/M data area
;	First	Firstrk			CP/M directory track
;	Last	(Lastrk-1)		Last track on disk
;	One	1			Track one, UCSD directory
;	Pascal	1-(Lastrk-1)		UCSD Pascal data area
;	System	0-(Firstrk-1)	   ***	CP/M bootstrap
;	Zero	0		   ***	Track zero, UCSD bootstrap
;	nn	nn			One track, as specified
;	n1-n2	n1-n2			A specified range
;			***	NOTE: this option parameter is
;				functional only if CPM is TRUE.
;
;	The default range, currently Firstrk to Lastrk-1, is given
;	in the two values at TRKSRT.
;
FIRSTRK EQU	2		; the first data track copied.
;				; The bootstrap is assumed to be
;				; on tracks 0 to Firstrk-1
LASTRK	EQU	76 + 1		; the last track copied plus one
;
DIFFTRK EQU	0		; difference between first source
;				; track and the first object track.
;				; (applies only when default range
;				; is used)
;
; THE NEXT EQUATE MUST BE TRUE. IT WAS LEFT IN TO FACILITATE
; COMPARISON WITH THE ORIGINAL COPYFAST CODE.
CPM	EQU	TRUE		; TRUE for CP/M copy (thru BIOS)
;
BXTBL	EQU	TRUE		;TRUE TO USE BIOS SECTOR XLATE TABLE
;
; IF BXTBL IS TRUE THEN CHANGING THE VALUES FOR 'RSKEW', 'SLOW',
;AND 'TSKEW' WILL NOT MAKE A SIGNIFICANT DIFFERENCE IN PERFORMANCE
;BECAUSE THE ENTRIES IN THE SKEW TABLES 'WRITAB' AND 'READTAB'
;ARE NOT USED. (GIVING A MORE UNIVERSAL PROGRAM).
; ALSO, THE COPY TIME FOR A STANDARD IBM 3740 DISK MAY BE QUITE A
;BIT LONGER THAN A SEPARATE CUSTOM VERSION OF THE PROGRAM CONTAINING
;OPTIMIZED ENTRIES IN 'WRITAB' AND 'READTAB' (WITH BXTBL SET FALSE).
;
;
	IF	CPM
;
SDLAST	EQU	26		; the number of sectors per track
;			; Also determines the lengths of
;			; WRTAB, READTAB, and WRITAB
;			; CP/M 2 users: this must be the
;			; value in the first byte of the
;			; disk parameter block.
SDZERO	EQU	26		; the number of 128-byte sectors on
;			; track zero. This is usually 26
;			; even on double-density disks,
;			; per the IBM standard.
;			; SHOULD BE NO LARGER THAN SDLAST.
WRSWCH	EQU	FALSE		; TRUE if CP/M 2.2 block/deblock
;			; routines need various values in
;			; reg. C during writes. See WRTAB
WRCODE	EQU	2		; value passed to sector write rtn
;			; in reg. C if WRSWCH is FALSE
SECSIZ	EQU	128		; Note: 128 if CP/M BIOS is used
	ENDIF
;
	IF	CPM AND (NOT BXTBL)
RSKEW	EQU	TRUE		; TRUE if read interleaving needed
;			; Note: change READTAB if TRUE
SLOW	EQU	FALSE		; TRUE if slower interleaving wanted
TSKEW	EQU	5		; Amount of track-to-track skew
;			; (if RSKEW is FALSE)
;			; Should be less than SDLAST
	ENDIF
;
	IF	CPM AND BXTBL
RSKEW	EQU	FALSE
SLOW	EQU	FALSE
TSKEW	EQU	0
	ENDIF
;
;
;	the following shennanigans are because ASM does not
;	have an EQ operator for comparisons, and neither ASM
;	nor MAC will perform an IF exactly as described in
;	the manual. Therefor, a TRUE value is constructed
;	with AND's and shift's and OR's.
;
;
XXXSKW	EQU	(0-TSKEW) AND 0FF00H
TRSKW	EQU	((XXXSKW) OR (XXXSKW SHR 8)) AND (NOT RSKEW)
;
;
;
START:	DI
	JP	VECT1		; go initialize the branches
;
;
;	Useful constants placed here for finding easily
;	These can be changed using DDT to alter some of
;	the characteristics of the program to suit your
;	taste.
;
TRKSRT:	; default first and last+1 track numbers
;				; Can be changed at run time
	DEFB	FIRSTRK
	DEFB	LASTRK
BUFFNMB:; max. number of buffers
	DEFB	BUFFNU
SRCTRAK:; source track - object track
	DEFB	DIFFTRK
;
SPT0:	DEFB	SDZERO		;SECTORS PER TRACK 0
;
SPT:	DEFB	SDLAST		;128 BYTE SECTORS PER DATA TRACK
;
OFFSET:	DEFB	2		;NUMBER OF RESERVED (SYSTEM) TRACKS
;
;SET THE FOLLOWING NON-ZERO IF YOU DO NOT WANT THE PROGRAM
;TO OVERWRITE THE BDOS (e.g. USING CACHE22 OR OTHER CP/M MODIFICATION)
;
BDOSFG:	DEFB	01
;
;	A set of dummy branch points to the CBIOS that are
;	filled in by the VECTOR routine.
;
WBOOT:
	JP	$-$		; not used
CONST:
	JP	$-$
CONIN:
	JP	$-$
CONOUT:
	JP	$-$
BLIST:
	JP	$-$		; not used
PUNCH:
	JP	$-$		; not used
READER:
	JP	$-$		; not used
HOME:
	JP	$-$
SELDIS:
	JP	$-$
SETRAK:
	JP	$-$
SETSCT:
	JP	$-$
SETDMA:
	JP	$-$
BREAD:
	JP	$-$
WRITE:
	JP	$-$
LISTST:
	JP	$-$		; not used
SECTRAN:
	JP	$-$		; only CPM 2.2
;
;
;
;	This  is the point where the program returns to repeat  the
;	copy. Everything is re-initialized.
;
REPEAT:
	LD	SP,STKTOP	; se-initialize stack
	LD	DE,SOURCE
	CALL	PRINT		; ask for source drive
SRCELU:
	CALL	CONIN		; read response (upper case)
	CP	CTRLC
	JP	Z,EXIT		; CTRL-C means abort
	AND	5FH
	CP	'A'		;41H
	JP	C,SRCELU	; bad value - less than A
	CP	'P'		;50H
	JP	Z,SETSOU
	JP	C,SETSOU
	JP	SRCELU		; cad value - greater than P
SETSOU:
	LD	(SRCEME),A	; save the source drive
	IF	SINGLE
	LD	(OBJMES),A
	ENDIF
	SUB	'A'		;41H
	LD	(SRCEDR),A	; convert value to CP/M number
	LD	A,(SRCEME)
	LD	C,A
	CALL	CONOUT		; echo value to console
	IF	NOT SINGLE
	LD	DE,OBJECT	; prompt for destination disk
	CALL	PRINT
OBJLUP:	; read response
	CALL	CONIN
	CP	CTRLC		; CTRL-C means abort
	JP	Z,EXIT
	AND	5FH		; convert to upper case
	CP	'A'		;41H
	JP	C,OBJLUP	; bad value - less than A
	CP	'P'		;50H
	JP	Z,SETOBJ
	JP	C,SETOBJ
	JP	OBJLUP		; bad value - greater than P
SETOBJ:
	LD	HL,SRCEME	; Cannot have a one drive copy
	CP	(HL)
	JP	Z,OBJLUP
	LD	(OBJMES),A	; save the destination drive
	SUB	'A'		;41H
	LD	(OBJDRI),A	; convert value to CP/M number
	LD	A,(OBJMES)
	LD	C,A
	CALL	CONOUT		; echo object drive
	ENDIF
	IF	SINGLE
	LD	DE,WPMSG
	CALL	PRINT
	ENDIF
	LD	DE,SIGNON
	CALL	PRINT		; now give chance to change disks
;				; or give up
AGIN:
	CALL	CONIN		; read response from keyboard
	CP	CTRLC
	JP	Z,EXIT		; ctrl-C means quit
	CP	CR
	JP	NZ,AGIN		; CR means go. Ignore anything else
;
;	now go do it !
;
	LD	DE,CRLF
	CALL	PRINT		; now start actual copy
	CALL	COPY
	LD	DE,DONMSG
	CALL	PRINT		; copy is now done, say so
;
;	end of this copy
;
EXIT:	EI
	LD	SP,STKTOP	; re-initialize stack
	LD	HL,0FFFFH	; and maybe flush buffers (MP/M)
	CALL	SETDMA
	LD	A,(SRCEDR)	; first, select source drive
	LD	C,A
	CALL	SELDSK
	CALL	HOME		; home the disk in case
	IF	NOT SINGLE
	LD	A,(OBJDRI)
	LD	C,A		; now, select destination drive
	CALL	SELDSK
	CALL	HOME		; and home that disk, in case
	ENDIF
EXIT1:	EI
	LD	DE,REPMES	; ask if another copy is desired
	CALL	PRINT
	CALL	CONIN		; read response, upper case
	AND	5FH
	CP	'R'		; R means repeat
	JP	Z,REPEAT
	CP	CR		; carriage return means back to CP/M
	JP	NZ,EXIT1
	LD	C,0		; set default disk back to A
	LD	E,NOLOG
	CALL	SELDSK
	JP	EXITCP		; and warmstart back to CP/M
;
;	this is the main copy routine
;
COPY:
	LD	A,(SRCEDR)	; first, select source drive
	LD	C,A
	IF	CPM
	LD	E,LOGON		; logon request (2.2 deblocking)
	ENDIF
	CALL	SELDSK
	IF	NOT BXTBL
	LD	HL,0000
	LD	(XLT),HL	;SET NO SECTOR TRANSLATION
	ENDIF
	IF	BXTBL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	LD	(XLT),HL	;SAVE BIOS XLATE TABLE ADDRESS
;
	EX	DE,HL
	DEC	HL		;POINT TO DPH AGAIN
	LD	DE,10		;INDEX TO...
	ADD	HL,DE		;...DPB ADDRESS IN DPH
	LD	E,(HL)		;GET DPB...
	INC	HL
	LD	D,(HL)
	EX	DE,HL		;...ADDRESS TO HL
	PUSH	HL		;SAVE FOR LATER
	LD	DE,2		;INDEX TO BSH
	ADD	HL,DE
	LD	A,(HL)		;GET BSH
	LD	(BSH),A		;AND SAVE.
	POP	HL		;GET DPB ADDRESS
	PUSH	HL		;SAVE AGAIN
	LD	DE,5		;INDEX TO DSM
	ADD	HL,DE
	LD	E,(HL)		;GET LOW BYTE
	INC	HL
	LD	D,(HL)		;NOW GET HIGH BYTE
	EX	DE,HL		;DSM TO HL
	LD	(DSM),HL	;AND SAVE.
	POP	HL		;DPB ADDRESS
	PUSH	HL
	LD	A,(HL)		;GET SECTORS PER TRACK
	LD	(SPT),A		;AND SAVE.
	INC	HL
	LD	A,(HL)		;CHECK HIGH BYTE
	POP	HL		;GET BACK DPB ADDRESS
	OR	A		;MORE THAN 255 SPT?
	LD	DE,SPTERR
	JP	NZ,COPY3	;YES, QUIT
;
	LD	DE,13		;INDEX TO RESERVED
	ADD	HL,DE		;TRACK COUNT IN DPB.
	LD	A,(HL)		;GET LOW BYTE
	LD	(OFFSET),A	;AND SAVE.
	LD	A,(OPTFLG)	;CHECK COMMAND LINE OPTION
	CP	'D'		;COPY ONLY DATA TRACKS?
	LD	A,(HL)
	JP	NZ,COPY1
	LD	(TRKSRT),A	;YES, UPDATE START TRACK
COPY1:	CP	6		;CHECK LOW BYTE
	JP	NC,COPY2	;QUIT IF TOO MANY
	INC	HL
	LD	A,(HL)		;CHECK HIGH BYTE
	OR	A		;QUIT IF NON-ZERO
	JP	Z,COPY4
COPY2:	LD	HL,OFFSET	;BUT QUIT ONLY
	LD	A,(TRKSRT)	;IF ATTEMPTING
	CP	(HL)		;TO COPY
	JP	NC,COPY4	;A SYSTEM TRACK.
	LD	DE,OFFERR
COPY3:	CALL	PRINT		;NOTIFY USER
	JP	EXIT1		;AND BAIL OUT
;
;THE FOLLOWING LIFTED FROM FBAD.ASM V60
; Convert block number to track
;
COPY4:	;CALCULATE TRACKS/DISK IF 'ALL' OR 'DATA' OPTION
	LD	A,(OPTFLG)
	CP	'A'
	JP	Z,COPY5
	CP	'D'
	JP	NZ,COPY6
COPY5:	LD	HL,(DSM)	;GET MAXIMUM GROUP
	LD	A,(BSH)		; Dpb value that tells how to
;
SHIFTL:	ADD	HL,HL		; Shift group number to get
	DEC	A		; Disk-data-area relative
	JP	NZ,SHIFTL	; Record number
	EX	DE,HL		; Rel record # into 'DE'
	LD	A,(SPT)		; Records per track from DPB
	LD	L,A
	LD	H,0
;
; Negate HL
	LD	A,L
	CPL
	LD	L,A
	LD	A,H
	CPL
	LD	H,A
	INC	HL
;
	EX	DE,HL
	LD	BC,0		; Initialize quotient
;
; Divide by number of records
;	quotient = track
;	     mod = record
;
DIVLP:	INC	BC		; Dirty division
	ADD	HL,DE
	JP	C,DIVLP
	DEC	BC		; Fixup last
	LD	A,(OFFSET)	; But before we have track #,
	LD	L,A		; We have to add system track offset
	LD	H,0
	ADD	HL,BC
	LD	A,H
	OR	A		;MORE THAN 255 TRACKS ON DISK?
	LD	DE,TRKERR
	JP	NZ,COPY3	;YES, ERROR
	LD	A,L
	INC	A		;LASTRK+1
	LD	(TRKSRT+1),A	;UDATE LAST TRACK
;
COPY6:	CALL	RANGE		;DISPLAY COPY RANGE
	CALL	INITBF		;SETUP COPY BUFFERS
	ENDIF			;BXTBL
;
	CALL	VECTOR		;INITIALIZE BUFFER COUNT
;
	LD	A,(BUFFNMB)	; load desired buffer number
	OR	A
	JP	Z,VECT3		; if no autosize, put in
	IF	DOCOMP
	DEC	A		; subtract one for compare buffer
	LD	(BUFFNMB),A
	ENDIF
	LD	HL,BUFTMP
	CP	(HL)		; compare against number found
	JP	Z,VECT2
	JP	C,VECT2		; branch if smaller
	LD	DE,BUFERR
	CALL	PRINT		; print out error msg
	LD	A,(BUFTMP)
	CALL	PRTDEC		; print out buffer number
VECT3:
	LD	A,(BUFTMP)
	LD	(BUFFNMB),A	; put in smaller buffer number
VECT2:
	CALL	HOME		; home the disk first, in case
;				; the controller requires it.
;				; (this might be the first time
;				; the drive has been used)
	LD	A,(TRKSRT)
	CALL	SETTRK		; now start with first track
	IF	NOT SINGLE
	LD	A,(OBJDRI)
	LD	C,A		; now, select destination drive
	ENDIF
	IF	CPM AND (NOT SINGLE)
	LD	E,LOGON		; logon request (2.2 deblocking)
	ENDIF
	IF	NOT SINGLE
	CALL	SELDSK
	CALL	HOME		; and home that disk, in case
	ENDIF
;
;	return here to continue copy
;
RDLOOP:
	LD	A,(TRK)		; note current track
	LD	(TRKSAV),A
	XOR	A		; reset error counter
	LD	(CMPERR),A
	LD	DE,TRKM		; print the current starting track
	CALL	PRINT		; being copied
	LD	A,(TRKSAV)
	CALL	PRTDEC
TRYRDA:
	IF	SINGLE
	LD	DE,SIGNON	; now give operator chance to change disk
	ENDIF
	LD	A,(SRCEDR)	; select source drive
;
;	read  loop
;
	CALL	STARTL		; start the copy loop (reading source)
LOOP1:
	CALL	READT		; read one track
	JP	Z,LOOP4		; if all tracks read, go check errors
	LD	A,(ERR1)
	OR	A		; not all done, but see if error already
	JP	NZ,LOOP1	; and go try another track
;
;	now see if any errors in the previous operations
;
LOOP4:
	LD	A,(ERR1)	; now check if any errors
	OR	A
	JP	NZ,RDSKIP	; jump if no errors at all
	LD	A,10H
	LD	(ERR1),A	; reset error flag
;
;	allow NUMERR errors before giving up
;
	LD	A,(CMPERR)	; check the retry counter
	INC	A
	LD	(CMPERR),A
	CP	NUMERR		; normally ten retries max
	JP	NZ,LOOP1	; WAS TRYRDA
	LD	DE,MESGC	; if maximum error count,
	CALL	PRINT		;   print message
	XOR	A
	LD	(CMPERR),A	; full track error, reset error counter
	CALL	ENDLUP
	JP	NZ,LOOP1	; now bump up track and see if done
;
;	write loop
;
RDSKIP:
	XOR	A		; reset error counter
	LD	(CMPERR),A
TRYAGA:
	IF	SINGLE
	LD	DE,OBJMSG	; give chance to put in object disk
	ENDIF
	LD	A,(OBJDRI)	; now select destination disk
	CALL	STARTL		; start the write loop
LOOP2:
	CALL	WRITET		; write one track (and readback check)
	JP	Z,LOOP3		; if all tracks written, go check errors
	LD	A,(ERR1)
	OR	A		; not all done, but see if error already
	JP	NZ,LOOP2
;
;	now see if any errors in the previous operations
;
LOOP3:
	LD	A,(ERR1)	; now check if any errors
	OR	A
	JP	NZ,SKIP		; jump if no errors at all
;
;	allow NUMERR errors before giving up
;
	LD	A,(CMPERR)	; check the retry counter
	INC	A
	LD	(CMPERR),A
	CP	NUMERR		; normally ten retries max
	JP	NZ,TRYAGA
	LD	DE,MESGC	; if maximum error count,
	CALL	PRINT		;   print message
	LD	A,(BUFFNMB)
	LD	H,A
	LD	A,(TRK)		;   and set next track
	INC	A		;   past track in error
	SUB	H
	LD	(TRKSAV),A
;
;	copied all tracks correctly (or NUMERR errors)
;
SKIP:
	LD	A,(BUFFNMB)	; get number of buffers
	LD	H,A
	LD	A,(TRKSAV)	; bump up track counter
	ADD	A,H
	LD	(TRK),A
	LD	HL,TRKSRT+1	; see if copy operation is done
	CP	(HL)		; TRK < LASTRK+1
	RET	NC
	JP	NZ,RDLOOP	; go back and do more
	RET
;
;	This routine selects the disk,  and initializes the  buffer
;	address,  buffer counter, and track counter,and seeks to the
;	right track.
;
STARTL:
	IF	SINGLE
	PUSH	DE		; Preserve register
	LD	HL,0FFFFH	; and maybe flush buffers (MP/M)
	CALL	SETDMA
	CALL	HOME		; Home the disk for a deblocking CBIOS
;				; to get a chance to flush the buffer
	POP	DE		; Restore register
	CALL	PRINT		; now give chance to change disks
;				; or give up
AGIN1:
	CALL	CONIN		; read response from keyboard
	CP	CTRLC
	JP	Z,EXIT		; CTRL-C means quit
	CP	CR
	JP	NZ,AGIN1	; CR means go. Ignore anything else
	ENDIF
	IF	NOT SINGLE
	LD	C,A		; select the disk first
	ENDIF
	IF	CPM AND NOT SINGLE
	LD	E,NOLOG		; no logon here (2.2 deblocking)
	ENDIF
	IF	NOT SINGLE
	CALL	SELDSK
	ENDIF
	IF	TRSKW
	XOR	A		; zero out track sector skew
	LD	(TSECT),A
	LD	(TBUFF),A	; zero out coresponding buffer addr
	LD	(TBUFF+1),A
	ENDIF
	LD	HL,(BUF0)	; load address of first buffer
	LD	(BUF0SA),HL
	LD	A,10H		; reset error flag
	LD	(ERR1),A
	LD	A,(BUFFNMB)	; load number of buffers
	LD	(BUFFCO),A
	LD	A,(TRKSAV)	; load first track copied
;
;	set the track to be used, and add offset if source
;	drive. Save track number for error routine.
;
SETTRK:
	LD	(TRK),A		; save current track
	IF	(NOT SINGLE)
	LD	A,(CURRDI)	; check drive
	LD	C,A
	LD	A,(SRCEDR)	; is it source
	CP	C
	LD	A,(TRK)		; if object, skip
	JP	NZ,SETTR0
	LD	C,A		; now get difference
	LD	A,(SRCTRAK)
	ADD	A,C		; and do correction
SETTR0:
	ENDIF
	LD	C,A		; now go set track
	JP	SETRAK
;
;	set the DMA address (in HL)
;
DMASET:
	LD	C,L		; move HL to BC
	LD	B,H
	PUSH	BC		; save result and call CBIOS
	CALL	SETDMA
	POP	BC
	RET
;
;	these are the disk error handling routines
;
FAILR:
	LD	DE,MESGD	; read error message
	JP	DIE
FAILW:
	LD	DE,MESGE	; write error message
DIE:
	CALL	PRINT		; print the main error message
	LD	DE,ERM
	CALL	PRINT
	LD	A,(TRK)		; print the track number
	CALL	PRTDEC
	LD	DE,MESGB	; print sector message
	CALL	PRINT
	LD	A,(SECTOR)	; and print sector
	CALL	PRTDEC
	LD	DE,DRIVE	; print drive message
	CALL	PRINT
	LD	A,(CURRDI)
	ADD	A,'A'		; convert drive number to ASCII
	LD	C,A
	CALL	CONOUT		; and finally print drive
	XOR	A
	LD	(ERR1),A	; note the error so this track is retried
	CALL	CONST
	OR	A		; see if any console input present
	JP	Z,ENDLUP
	CALL	CONIN		; yes, see if aborting
	CP	CTRLC
	JP	Z,EXIT		; die if CTRL-C was hit
	JP	ENDLUP
;
;	read the full track now, no interleaving
;
READT:
	CALL	CONST
	OR	A		; see if any console input present
	JP	Z,READT0
	CALL	CONIN		; yes, see if aborting
	CP	CTRLC
	JP	Z,EXIT		; die if CTRL-C was hit
READT0:
	IF	(NOT RSKEW) AND (NOT TRSKW)
	LD	HL,(BUF0SA)	; first, get beginning of buffer
	LD	(DMAAD),HL
	ENDIF
	IF	TRSKW
	LD	HL,(BUF0SA)	; first, get beginning of buffer
	EX	DE,HL
	LD	HL,(TBUFF)	; and correct for skew
	ADD	HL,DE
	LD	(DMAAD),HL
	LD	A,(TSECT)	; initialize first sector
	LD	C,A
	ENDIF
	IF	(NOT TRSKW)
	LD	C,0		; initialize first sector
	ENDIF
	LD	A,(SPT)		; initialize sector count
	LD	B,A
RT3:
	IF	TRSKW
	LD	A,C		; check for skew too big
	LD	HL,SPT
	CP	(HL)
	JP	C,RT4		; jump if sector within range
	XOR	A
	LD	C,A		; out of range, back to sector 1
	LD	HL,(BUF0SA)
	LD	(DMAAD),HL
RT4:
	ENDIF
	IF	RSKEW
	INC	C		; increment sector counter
	PUSH	BC
	LD	HL,READTAB-1	; find the interleaved sector number
	CALL	XLATE		; using the READTAB
	CALL	SETSEC		; and set the sector
	LD	H,0
	DEC	C		; now compute the buffer location
	LD	L,C
	CALL	SHIFT		; and multiply by sector size
	EX	DE,HL
	LD	HL,(BUF0SA)	; and then adding to the buffer start
	ADD	HL,DE
	CALL	DMASET		; set the DMA and do the read
	ENDIF
	IF	(NOT RSKEW)
	INC	C		; increment sector counter
	PUSH	BC
	CALL	SETSEC		; set the sector
	LD	HL,(DMAAD)
	CALL	DMASET		; set the DMA
	LD	HL,SECSIZ
	ADD	HL,BC		; bump up the DMA for next time
	LD	(DMAAD),HL
	ENDIF
	IF	CPM
	LD	A,(TRK)		; see if track 0
	OR	A
	JP	NZ,ZER2		; jump if not
	LD	A,(SPT0)
	LD	HL,SECTOR
	CP	(HL)		; see if sector is on track
	JP	C,ZER28
ZER2:
	ENDIF
	CALL	BREAD		; now read one sector
	RRA
	CALL	C,FAILR		; if returned 01, read error
ZER28:	POP	BC
	DEC	B		; see if all sectors read
	JP	NZ,RT3
	IF	TRSKW
	LD	HL,(TBUFF)	; bump up skewed buffer
	LD	DE,SECSIZ*TSKEW
	ADD	HL,DE		; add the skew
	LD	(TBUFF),HL
	LD	A,(TSECT)	; now bump starting sector
	ADD	A,TSKEW
	LD	(TSECT),A	; and put it back
	LD	HL,SPT
	SBC	A,M		; SUB M  ?
	JP	C,ENDLUP	; jump if sector within range
	LD	(TSECT),A
	LD	HL,(TKSIZC)	; correct sector start and
	EX	DE,HL
	LD	HL,(TBUFF)
	ADD	HL,DE
	LD	(TBUFF),HL	;  buffer skew address
	ENDIF
	JP	ENDLUP		; return with complete track read
;
;	Write the full track,  with interleaving,  and then check it
;	by reading it all back in.
;
WRITET:
	CALL	CONST
	OR	A		; see if any console input present
	JP	Z,WRITE0
	CALL	CONIN		; yes, see if aborting
	CP	CTRLC
	JP	Z,EXIT		; die if CTRL-C was hit
WRITE0:
	LD	HL,(BUF0SA)	; first, get the beginning of buffer
	LD	(DMAAD),HL
	LD	C,0
	LD	A,(SPT)		; initialize sector counter
	LD	B,A
WT3:
	PUSH	BC
	LD	HL,WRITAB	; find the interleaved sector number
	CALL	XLATE1		; using the WRITAB
	CALL	SETSEC		; and set the sector
	LD	H,0
	DEC	C		; now compute the buffer location
	LD	L,C
	CALL	SHIFT		; and multiply by sector size
	EX	DE,HL
	LD	HL,(DMAAD)	; and then adding to the buffer start
	ADD	HL,DE
	CALL	DMASET		; set the DMA and do the write
	IF	(NOT WRSWCH) AND CPM
	LD	C,WRCODE	; value for CP/M 2.2 routine
	ENDIF
	IF	WRSWCH AND CPM
	POP	BC		; get sector number
	PUSH	BC
	LD	HL,WRTAB-1	; find the C reg. value for this
	LD	B,0
	ADD	HL,BC		; sector using the WRTAB
	LD	C,(HL)
	ENDIF
	IF	CPM
	LD	A,(TRK)		; see if track 0
	OR	A
	JP	NZ,ZER1		; jump if not
	LD	A,(SPT0)
	LD	HL,SECTOR
	CP	(HL)		; see if sector is on track
	JP	C,ZER18
ZER1:
	ENDIF
	CALL	WRITE
	RRA			; if 01 returned, write error
	CALL	C,FAILW
ZER18:	POP	BC
	INC	C		; increment sector count
	DEC	B
	JP	NZ,WT3		; and loop back if not done
	IF	DOCOMP AND (NOT RSKEW)
	LD	HL,BUF1		; first, get beginning of buffer
	LD	(DMAAD),HL
	ENDIF
	LD	C,0
	LD	A,(SPT)		; reinitialize sector counts for read
	LD	B,A
WT4:
	INC	C		; bump up sector counter
	PUSH	BC
	IF	RSKEW
	LD	HL,READTAB-1	; find the interleaved sector number
	CALL	XLATE		; using the READTAB
	CALL	SETSEC		; and set the sector
	ENDIF
	IF	RSKEW AND DOCOMP
	LD	H,0
	DEC	C		; now compute the buffer location
	LD	L,C
	CALL	SHIFT		; and multiply by sector size
	EX	DE,HL
	LD	HL,BUF1		; and then adding to the buffer start
	ADD	HL,DE
	CALL	DMASET		; now set the read buffer
	ENDIF
	IF	(NOT RSKEW) AND DOCOMP
	CALL	SETSEC		; set the sector
	LD	HL,(DMAAD)
	CALL	DMASET		; set the DMA
	LD	HL,SECSIZ
	ADD	HL,BC		; bump up the DMA for next time
	LD	(DMAAD),HL
	ENDIF
	IF	RSKEW AND (NOT DOCOMP)
	LD	HL,BUF1		; load the buffer address
	CALL	DMASET		; and set the read buffer
	ENDIF
	IF	(NOT RSKEW) AND (NOT DOCOMP)
	CALL	SETSEC		; now set the sector
	LD	HL,BUF1
	CALL	DMASET		; and set the read buffer
	ENDIF
	IF	CPM
	LD	A,(TRK)		; see if track 0
	OR	A
	JP	NZ,ZER3		; jump if not
	LD	A,(SPT0)
	LD	HL,SECTOR
	CP	(HL)		; see if sector is on track
	JP	C,ZER4
ZER3:
	ENDIF
	IF	NOT NOCOMP
	CALL	BREAD
	RRA			; was bit 0 set by disk error?
	CALL	C,FAILR
	ENDIF
	IF	CPM
ZER4:
	ENDIF
	POP	BC		; no error, see if all sectors read
	DEC	B
	JP	NZ,WT4		; if not all done, go back
	IF	DOCOMP
	PUSH	HL
	LD	HL,(TKSIZ)
	LD	B,H
	LD	C,L		; now, compare the track read in
	POP	HL
	ENDIF
	IF	CPM AND DOCOMP
	LD	A,(TRK)		; see if track 0
	OR	A
	JP	NZ,ZER5		; jump if not
	PUSH	HL
	LD	HL,(TK0SIZ)
	LD	B,H
	LD	C,L
	POP	HL
ZER5:
	ENDIF
	IF	DOCOMP
	LD	HL,(BUF0SA)
	LD	DE,BUF1
CMPLP:	LD	A,(DE)		; get read data
	CP	(HL)
	JP	NZ,CERR		; and if not what was written, error
	INC	HL
	INC	DE		; bump counters
	DEC	BC
	LD	A,C		; and count BC down to zero
	OR	B
	JP	NZ,CMPLP	; if all done, return
	JP	ENDLUP
;
;	print read verify compare error
;
CERR:	PUSH	HL		; save the goodies
	PUSH	DE
	PUSH	BC
	LD	DE,MESGA	; start the error message
	CALL	PRINT
	LD	A,(TRK)		; print the track number
	CALL	PRTDEC
	LD	DE,MESGB	; print more
	CALL	PRINT
	POP	HL		; pop the down counter
	DEC	HL
	ENDIF
	IF	DOCOMP
	ADD	HL,HL		; multiply by 2 to get sectors left
;
	LD	A,(SPT)
	SUB	H		; subtract from total number of sectors
	CALL	PRTDEC		; to get sector number, and print it
	LD	DE,MEM
	CALL	PRINT		; print second line
	POP	HL
	LD	A,(HL)		; get byte read
	LD	(DATA1),A	; and save it
	CALL	HLOUT		;PRINT HEX ADDRESS
	LD	C,','
	CALL	CONOUT		; comma
	POP	HL
	LD	A,(HL)		; get byte written
	LD	(DATA2),A	; and save it
	CALL	HLOUT		;PRINT HEX ADDRESS
	LD	DE,DATAM	; print data header
	CALL	PRINT
	LD	A,(DATA1)	; print byte read
	CALL	PRTHEX
	LD	C,','		; comma
	CALL	CONOUT
	LD	A,(DATA2)	; print byte written
	CALL	PRTHEX
	XOR	A
	LD	(ERR1),A	; note the error so this track is retried
	ENDIF
;
;	This  routine  is  used to check if another track is  to  be
;	read/written:   it   increments  buffer  address  and  track
;	counter,   and  decrements  the  buffer  counter.  Then,  it
;	terminates  the  loop if all buffers are full  or  the  last
;	track has been processed (Z flag set).
;
ENDLUP:
	LD	A,(ERR1)	; now check if any errors
	OR	A		; and return if so
	RET	Z
	LD	A,(TRK)		; increment track
	INC	A
	LD	HL,TRKSRT+1	; check if last track
	CP	(HL)
	RET	Z		; return if last track
	CALL	SETTRK
	LD	HL,BUFFCO	; decrement buffer counter
	DEC	(HL)
	RET	Z		; return if all buffers full/empty
	LD	HL,(TKSIZ)
	EX	DE,HL
	LD	HL,(BUF0SA)	; increment buffer address
	ADD	HL,DE
	LD	(BUF0SA),HL
	OR	0FFH		; non-zero to indicate more
	RET
;
;	this  routine  writes  messages  to  the  console.  Message
;	address  is in DE,  and terminates on a $.  The BDOS call is
;	not  used  here because BDOS may be destroyed by  the  track
;	buffers
;
PRINT:
	LD	A,(DE)		; get the character
	CP	'$'		;24H
	RET	Z		; quit if $
	PUSH	DE
	AND	$7F		; strip higher bit
	LD	C,A		; send it to the console
	CALL	CONOUT
	POP	DE		; go check next character
	INC	DE
	JP	PRINT
;
;	set the next sector to be used, and save that
;	number for the error routine, in case.
;	THE FOLLOWING HIDES ANY BIOS SECTOR TRANSLATION
;	FROM THE PROGRAM.
;
SETSEC:
	LD	A,C		; save the sector number
	LD	(SECTOR),A
	PUSH	BC
	LD	HL,OFFSET
	LD	A,(TRK)
	CP	(HL)		;SEE IF SYSTEM TRACK
	JP	C,SETS1		;SKIP IF SO.
	IF	CPM
	LD	HL,(XLT)	;GET XLATE TABLE ADDRESS
	EX	DE,HL		;IN DE
	LD	B,0		;CLEAR B
	DEC	C		; 1 TO N ==> 0 TO N-1
	CALL	SECTRAN
	POP	BC		;GET BACK SECTOR NUMBER
	PUSH	BC		;AND SAVE IT AGAIN
	ENDIF
	IF	BXTBL
	LD	B,H		;GET TRANSLATED
	LD	C,L		;SECTOR NUMBER
	ENDIF
SETS1:	CALL	SETSCT		; now go set the sector
	POP	BC		;RETURN WITH ORIGINAL SECTOR
	RET
;
;	set the disk to be used, and save that
;	for the error routine, in case
;
SELDSK:
	LD	A,C		; save the disk number
	LD	(CURRDI),A
	JP	SELDIS		; now select the disk
;
;	Routine to multiple value in HL by SECSIZ
;
SHIFT:
	ADD	HL,HL
	ADD	HL,HL		; The number of DAD H instructions
	ADD	HL,HL
	ADD	HL,HL		; MUST correspond to the buffer size
	ADD	HL,HL
	ADD	HL,HL		; i.e. 7 DADs means 128 byte (2^7)
	ADD	HL,HL
	RET
;
; (XLATE1)  WRITAB USAGE:	0 TO N-1 ==> 1 TO N
; (XLATE )  READTAB USAGE:	1 TO N   ==> 1 TO N
;
XLATE1:
	IF	BXTBL
	INC	C
	ENDIF
	IF	NOT BXTBL
	LD	A,(TRK)		;SEE IF TRACK 0
	OR	A
	JP	NZ,XLATE	;JUMP IF NOT
	INC	C		;ADJUST COUNT
	ENDIF
;
XLATE:
	LD	B,0
	IF	NOT BXTBL	;USE BUILT-IN SKEW TABLE
	LD	A,(TRK)		;SEE IF TRACK 0
	OR	A
	JP	Z,SKIPX		;JUMP IF YES
	ADD	HL,BC
	LD	C,(HL)
SKIPX:
	ENDIF
	RET			;ELSE,USE BIOS SECTRAN ROUTINE
;
;CONVERT VALUE IN HL TO ASCII HEX AND PRINT IT
;
HLOUT:	LD	A,H		;DISPLAY H
	PUSH	HL
	CALL	HEXOUT
	POP	HL
	LD	A,L		;DISPLAY L
PRTHEX:	CALL	HEXOUT
	LD	C,'H'		;DENOTES HEX VALUE
	JP	CONOUT
;
;	convert value in A reg. to ASCII hex and print it
;
HEXOUT:
	PUSH	AF		; save for LSN
	RRA
	RRA			; shift MSN nibble to LSN
	RRA
	RRA
	CALL	PRTNBL		; now print it
	POP	AF		; and then do LSN
PRTNBL:
	AND	0FH
	ADD	A,'0'		;convert to ASCII value
	CP	'0'+10		; over 9 ?
	JP	C,SML
	ADD	A,7		; convert 10 to A, etc.
SML:
	LD	C,A		; move to C for BIOS call
	CALL	CONOUT
	RET
;
;
;
;CONVERT BINARY IN (A) TO ASCII DECIMAL
;
PRTDEC:	LD	DE,3030H	;INITIALIZE TO ASCII ZEROS
	LD	C,30H
SUB100:	SUB	100
	JP	C,ADD100
	INC	E		;HUNDREDS DIGIT
	JP	SUB100
ADD100:	ADD	A,100
SUB10:	SUB	10
	JP	C,UNITS
	INC	D		;TENS DIGIT
	JP	SUB10
UNITS:	ADD	A,10
	ADD	A,C
	LD	C,A		;UNITS DIGIT
;
	PUSH	BC
	PUSH	DE
	LD	A,E
	CP	'0'		;LEADING ZERO?
	JP	Z,PD1		;YES, SKIP
	LD	C,A
	CALL	CONOUT
PD1:	POP	DE
	LD	C,D
	CALL	CONOUT
	POP	BC
	JP	CONOUT
;
;INITIALIZE COPY BUFFERS
;
	IF	BXTBL
INITBF:	LD	A,(SPT0)
	LD	L,A
	LD	H,0
	CALL	SHIFT		;CALC. SPT0*SECSIZ
	LD	(TK0SIZ),HL	;AND SAVE
;
	LD	A,(SPT)
	LD	L,A
	LD	H,0
	CALL	SHIFT		;CALC. SDLAST*SECSIZ
	LD	(TKSIZ),HL	;AND SAVE
	XOR	A		;NOW GET -(SDLAST*SECSIZ)
	SUB	L
	LD	L,A
	LD	A,0
	SBC	A,H
	LD	H,A
	LD	(TKSIZC),HL	;AND SAVE
	ENDIF			;BXTBL
;
	IF	DOCOMP AND BXTBL
	LD	HL,(TKSIZ)
	LD	DE,BUF1
	ADD	HL,DE
	LD	(BUF1END),HL
	ENDIF
	IF	(NOT DOCOMP) AND (NOT NOCOMP) AND BXTBL
	LD	HL,SECSIZ
	LD	DE,BUF1
	ADD	HL,DE
	LD	(BUF1END),HL
	ENDIF
	IF	NOCOMP AND BXTBL
	LD	HL,BUF1
	LD	(BUF1END),HL
	ENDIF
;
	IF	BXTBL
	LD	HL,(BUF1END)
	LD	(BUF0),HL
	EX	DE,HL
	LD	HL,(TKSIZ)
	ADD	HL,DE
	LD	(BUFEND),HL
	ENDIF
	RET
;
;
RANGE:	LD	DE,BGMES1	; Now print message giving copy range
	CALL	PRINT
	LD	A,(TRKSRT)
	CALL	PRTDEC		; print first track
	LD	DE,BGMES2
	CALL	PRINT
	LD	A,(TRKSRT+1)	; print last track
	DEC	A
	JP	PRTDEC
;
BGMES1:
	DEFB	CR,LF,'Copying from track $'
BGMES2:
	DEFB	' to track $'
;
;	all messages here for convenience in disassembling
;
DONMSG:
	DEFB	CR,LF,'*** COPY COMPLETE ***$'
DRIVE:
	DEFB	', drive $'
ERM:
	DEFB	CR,LF,'+ ERROR on track $'
MESGB:
	DEFB	' sector $'
MESGC:
	DEFB	CR,LF,'++PERMANENT $'
MESGD:
	DEFB	CR,LF,'+ READ ERROR $'
MESGE:
	DEFB	CR,LF,'+ WRITE ERROR $'
	IF	SINGLE
WPMSG:	DEFB	CR,LF,CR,LF,'WRITE PROTECT source disk $'
	ENDIF
SIGNON:
	DEFB	CR,LF,'Source on '
SRCEME:
	DEFB	0		; will be filled in later
	DEFB	':   '
	IF	NOT SINGLE
	DEFB	' Object on '
OBJMES:
	DEFB	0		; will be filled in later
	DEFB	':'
	ENDIF
SINOFF:
	IF	NOT SINGLE
	DEFB	CR,LF
	ENDIF
	DEFB	'Hit <RETURN> to continue, or <CONTROL-C> to exit: $'
	IF	SINGLE
OBJMSG:
	DEFB	CR,LF,'Object on '
OBJMES:
	DEFB	0		; will be filled in later
	DEFB	':   '
	DEFB	'Hit <RETURN> to continue, or <CONTROL-C> to exit: $'
	ENDIF
REPMES:
	DEFB	CR,LF,'<RETURN> to CP/M, or <R>epeat COPY: $'
CRLF:
	DEFB	CR,LF,'$'
SOURCE:
	DEFB	CR,LF,'SOURCE drive (A thru P): $'
	IF	NOT SINGLE
OBJECT:
	DEFB	CR,LF,'OBJECT drive (A thru P): $'
	ENDIF
TRKM:
	DEFB	CR,LF,'Copying track $'
;
	IF	DOCOMP
MESGA:
	DEFB	CR,LF,'+ Memory Compare ERROR on track $'
MEM:
	DEFB	CR,LF,'+ Memory Address $'
DATAM:
	DEFB	' (obj,src)   data: $'
	ENDIF			;DOCOMP
	IF	BXTBL
SPTERR:
	DEFB	CR,LF,'>255 SECTORS PER TRACK',CR,LF,'$'
OFFERR:
	DEFB	CR,LF,'>5 RESERVED (SYSTEM) TRACKS',CR,LF,'$'
TRKERR:
	DEFB	CR,LF,'>255 TRACKS ON DISK',CR,LF,'$'
	ENDIF			;BXTBL
;
BUFERR:
	DEFB	CR,LF,'TPA is too small - BUFFER SPACE REDUCED: $'
;
BUFTMP:	DEFB	0		; temporary storage for buffer counter
;
;	 This  is  the  sector interleave table.  If  you  want  the
;	program to work,  all sector numbers must be here somewhere.
;
WRITAB:
;
;THE FOLLOWING ARE FOR STANDARD IBM 3740 26 SPT FORMAT
	IF	CPM AND (NOT RSKEW) AND (NOT SLOW) AND (NOT BXTBL)
;	Interleave table for very fast controllers
;	gives time to switch between write and read.
	DEFB	25,26,1,2,3,4,5,6,7,8,9,10,11,12
	DEFB	13,14,15,16,17,18,19,20,21,22,23,24
	ENDIF
	IF	CPM AND (NOT RSKEW) AND SLOW AND (NOT BXTBL)
;	Interleave table for slower controllers
	DEFB	25,1,3,5,7,9,11,13,15,17,19,21,23
	DEFB	26,2,4,6,8,10,12,14,16,18,20,22,24
	ENDIF
	IF	CPM AND RSKEW AND (NOT SLOW) AND (NOT BXTBL)
;	Interleave table for slower controllers
	DEFB	25,1,3,5,7,9,11,13,15,17,19,21,23
	DEFB	26,2,4,6,8,10,12,14,16,18,20,22,24
	ENDIF
	IF	CPM AND RSKEW AND SLOW AND (NOT BXTBL)
;	Interleave table for very slow controllers
	DEFB	1,4,7,10,13,16,19,22,25,2,5,8,11
	DEFB	14,17,20,23,26,3,6,9,12,15,18,21,24
	ENDIF
;
;
;	 This  is the read skew table,  if needed.  The same general
;	considerations as the write skew table apply here also,  but
;	the table should start with sector 1.  Both the read and the
;	read-after write use this table.  As you can see,  the write
;	and read interleaving doesn't have to be the same.
;
READTAB:
;
	IF	RSKEW AND CPM AND (NOT BXTBL)
;THE FOLLOWING ARE FOR STANDARD IBM 3740 26 SPT FORMAT
	DEFB	1,3,5,7,9,11,13,15,17,19,21,23,25
	DEFB	2,4,6,8,10,12,14,16,18,20,22,24,26
	ENDIF
;
;
;	This is the write switch table. The values in this table
;	are passed to the sector write routine of CP/M 2.2 in
;	reg. C when each write occurs. This table is modified if
;	and only if some particular pattern is needed for your
;	blocking routine to work as fast or as well as possible.
;	Refer to the CP/M 2.2 Alteration Guide for more details.
;
	IF	WRSWCH AND CPM
WRTAB:
;
;THE FOLLOWING ARE FOR STANDARD IBM 3740 26 SPT FORMAT
	DEFB	2,2,2,2,2,2,2,2,2,2,2,2,2
	DEFB	2,2,2,2,2,2,2,2,2,2,2,2,2
	ENDIF
;
;	This is the initialization code, and occupies the lowest area
;	of the stack.
;	(The stack is about 40 bytes long)
;
VECTOR:
	LD	A,BUFFNU
	LD	(BUFFNMB),A	;INITIALIZE DEFAULT COUNT
	XOR	A
	LD	(BUFTMP),A	;CLEAR BUFTMP
;
	LD	HL,(1)		; get bottom of CBIOS
	LD	A,(BDOSFG)	;SEE IF
	OR	A		;WE DO NOT WANT
	JP	Z,VECT		;TO OVERWRITE THE BDOS.
	LD	HL,(6)		;GET BOTTOM OF BDOS
VECT:	LD	B,H
	LD	HL,(TKSIZ)
	EX	DE,HL		; get size of buffers
	LD	HL,(BUF0)	; start checking where buffer starts
VECT0:
	ADD	HL,DE		; add buffer size to buffer addr
	RET	C		; stop if at end of core
	LD	A,H
	CP	B		; check hi order byte if high
	RET	Z		; or equal
	RET	NC
	LD	A,(HL)		; gonna see if got memory
	CPL
	LD	(HL),A		; store complement in memory
	CP	(HL)		; and see if it is a good spot
	RET	NZ
	LD	A,(BUFTMP)	; buffer fits, add one to count
	INC	A
	LD	(BUFTMP),A	; and store
	JP	VECT0
;
;	the stack
;
	DEFS	64
STKTOP:
	DEFB	0
	DEFS	2		;EXTRA SPACE
;
;	variables
;
BUF0SA:	; buffer address
	DEFB	0,0
TRKSAV:	; track save area during read and write
	DEFB	0
BUFFCO:	; buffer counter
	DEFB	0
CMPERR:	; number of disk errors
	DEFB	0
TRK:	; current track
	DEFB	0
SRCEDR:	; source drive
	IF	NOT SINGLE
	DEFB	0
	ENDIF
OBJDRI:	; destination drive
	DEFB	0
CURRDI:	; drive for current operation
	DEFB	0
DMAAD:	; DMA address for current operation
	DEFB	0,0
ERR1:	; error flag (0 = error)
	DEFB	0
SECTOR:	; sector number for current operation
	DEFB	0
;
	IF	TRSKW
TSECT:
	DEFB	0		; skewed sector start for track
TBUFF:
	DEFB	0,0		; skewed buffer address
	ENDIF
;
BUF1END:DEFW	DSBUF1END
;
BUF0:	DEFW	DSBUF0
;
BUFEND:	DEFW	DSBUFEND
;
XLT:	DEFW	00		;ADDRESS OF BIOS SECTOR XLATE TABLE
;
BSH:	DEFB	0		;BLOCK SHIFT FROM BIOS DPB
;
DSM:	DEFW	00		;DRIVE SIZE FROM BIOS DPB
;
TK0SIZ:	DEFW	SDZERO*SECSIZ	;TRACK ZERO SIZE
;
TKSIZ:	DEFW	SDLAST*SECSIZ	;DATA TRACK SIZE
;
TKSIZC:	DEFW	-(SDLAST*SECSIZ); 0 - DATA TRACK SIZE
;
OPTFLG:	DEFB	0		;COMMAND LINE OPTION LETTER
;
;	the track buffers. BUFEND must not overlay the BIOS !
;
;	BUF1 is where the read-after-write is performed
;
	IF	DOCOMP
DATA1:
	DEFS	1		; used in compare
DATA2:
	DEFS	1
	ENDIF
;
BUF1	EQU	$
;
	IF	DOCOMP
DSBUF1END EQU	BUF1+(SECSIZ*SDLAST); space for a full track read
	ENDIF
;
	IF	(NOT DOCOMP) AND (NOT NOCOMP)
DSBUF1END EQU	BUF1+SECSIZ	; just one sector for CRC only
	ENDIF
	IF	NOCOMP
DSBUF1END EQU	$
	ENDIF
;
;	BUF0 is where all input tracks are read
;	Tho space for only one track is allocated here,
;	the program will use BUFFNU track buffers, or
;	up to the CBIOS, whichever is smaller
;
DSBUF0	EQU	DSBUF1END
DSBUFEND EQU	DSBUF0+(SECSIZ*SDLAST)
;
;	This is one-time code to initialize the branch table to
;	the CBIOS vectors. Only those vectors used are initialized.
;	Placed here so that it wont get clobbered by the stack
;
VECT1:
	LD	HL,(1)		; get warm boot address
	LD	SP,HL		; and save it in SP for DAD
	LD	HL,3
	ADD	HL,SP
	LD	(CONST+1),HL
;
	LD	HL,6
	ADD	HL,SP
	LD	(CONIN+1),HL
;
	LD	HL,9
	ADD	HL,SP
	LD	(CONOUT+1),HL
;
	IF	CPM
	LD	HL,15H		; home disk
	ADD	HL,SP
	LD	(HOME+1),HL
;
	LD	HL,18H		; select disk
	ADD	HL,SP
	LD	(SELDIS+1),HL
;
	LD	HL,1BH		; set track
	ADD	HL,SP
	LD	(SETRAK+1),HL
;
	LD	HL,1EH		; set sector
	ADD	HL,SP
	LD	(SETSCT+1),HL
;
	LD	HL,21H		; set dma
	ADD	HL,SP
	LD	(SETDMA+1),HL
;
	LD	HL,24H		; read disk
	ADD	HL,SP
	LD	(BREAD+1),HL
;
	LD	HL,27H		; write disk
	ADD	HL,SP
	LD	(WRITE+1),HL
;
	LD	C,12		; see if got CP/M 2.2
	CALL	5
	LD	A,H		; check for non-zero
	OR	L
	JP	NZ,GRUNJ1
	LD	A,$C9		; (RET) no SECTRAN for CP/M 1.4
	LD	(SECTRAN),A
	JP	GRUNJ2
GRUNJ1:
	LD	HL,2DH		; sector translate
	ADD	HL,SP
	LD	(SECTRAN+1),HL
GRUNJ2:
	ENDIF
;
;
;
;	Now check what kind of copy is wanted
;
	LD	SP,STKTOP	; initial stack
	LD	DE,INIT
	CALL	PRINT		; start program
	LD	HL,(TRKSRT)
;
	LD	A,(FCB+1)	; get character of parameter
	CP	' '		; check for default
	LD	A,'D'		;DEFAULT OPTION- DATA TRACKS
	LD	(OPTFLG),A	;SAVE OPTION
	JP	Z,COPYDEF
	LD	A,(FCB+1)	;GET CHARACTER AGAIN
	CP	'$'		;OPTION DESIGNATOR
	JP	NZ,COPYERR	;GIVE HELP
	LD	A,' '		;initl end of FCB
	LD	(FCB+8),A
	LD	HL,FCB+2
	LD	A,(HL)		;GET CHARACTER OF PARAMETER
	INC	HL
	AND	5FH		;UPPER CASE
	LD	(OPTFLG),A	;SAVE OPTION
	LD	B,A
	XOR	A		; no track shift
	LD	(SRCTRAK),A
	LD	A,B
	CP	'D'		; check for Data
	JP	Z,COPYDAT
	CP	'F'		; check for First
	JP	Z,COPYFIR
	CP	'L'		; check for Last
	JP	Z,COPYLAS
	CP	'O'		; check for One
	JP	Z,COPYONE
	CP	'P'		; check for Pascal
	JP	Z,COPYPAS
	IF	CPM
	CP	'A'		; check for All
	JP	Z,COPYALL
	CP	'S'		; check for System
	JP	Z,COPYSYS
	CP	'Z'		; check for Zero
	JP	Z,COPYZER
	ENDIF
	DEC	HL		;BACK UP POINTER
	CALL	GETNUM		; go check for number
	JP	NC,COPYNUM
COPYERR:
	LD	DE,CALLERR	; got a bad value
	CALL	PRINT
	JP	EXITCP
;
;	routine to decode a numeric value or range
;
COPYNUM:
	LD	D,A		; put in lastrk+1
	DEC	A
	LD	E,A		; put in first track
	LD	A,(HL)
	EX	DE,HL
	CP	' '		; check if only one parameter
	JP	Z,COPYDEF
	EX	DE,HL
	CP	','		; ALLOW A COMMA OR DASH
	JP	Z,CN1
	CP	'-'		; check for minus
	JP	NZ,COPYERR
CN1:	INC	HL		; get another number
	CALL	GETNUM
	JP	C,COPYERR
	LD	D,A		; put in last track
	CP	E
	JP	C,COPYERR
	LD	A,' '		; check for last character
	CP	(HL)
	JP	NZ,COPYERR
	EX	DE,HL		; all OK, go do it
	JP	COPYDEF
;
GETNUM:
	CALL	GETNM
	RET	C		;BAD VALUE
GETDUN:
	INC	B		; add 1 (for last track)
	LD	A,LASTRK
	CP	B		; check for valid range
	JP	C,GETER
	LD	A,B		; all done OK
	RET
;
GETNM:	LD	A,(HL)		; valid digit ?
	CP	'0'
	RET	C		; Carry flag if No
	CP	'9'+1
	CCF
	RET	C
	SUB	A		; initial the number
	LD	B,A
GETLUP:
	LD	A,B
	ADD	A,A		; * 2
	JP	C,GETER
	ADD	A,A		; * 4
	JP	C,GETER
	ADD	A,B		; * 5
	JP	C,GETER
	ADD	A,A		; * 10
	JP	C,GETER
	LD	B,A
	LD	A,(HL)		; get digit
	SUB	'0'
	ADD	A,B		; add to shifted number
	JP	C,GETER
	LD	B,A
	INC	HL		; get next character
	LD	A,(HL)
	CP	'0'		; check if digit
	CCF
	RET	NC
	CP	'9'+1
	JP	C,GETLUP
GETER:
	POP	HL		; gonna leave abnormally
	JP	COPYERR
;
;	implement the alphabetic abbreviations for range
;
COPYDAT:
	LD	H,LASTRK	; Data
	LD	L,FIRSTRK
	JP	COPYDEF
COPYFIR:
	LD	H,FIRSTRK+1	; First
	LD	L,FIRSTRK
	JP	COPYDEF
COPYLAS:
	LD	H,LASTRK	; Last
	LD	L,LASTRK-1
	JP	COPYDEF
COPYONE:
	LD	H,2		; One
	LD	L,1
	JP	COPYDEF
COPYPAS:
	LD	H,LASTRK	; Pascal
	LD	L,1
	JP	COPYDEF
COPYALL:
	IF	BXTBL
	CALL	GETNM		;CHECK FOR OPTIONAL TRACK 0 SECTOR COUNT
	JP	C,CPYALL
	LD	A,B
	LD	(SPT0),A
	ENDIF
CPYALL:	LD	H,LASTRK	; All
	LD	L,0
	JP	COPYDEF
COPYSYS:
	IF	BXTBL
	CALL	GETNM		;CHECK FOR OPTIONAL TRACK 0 SECTOR COUNT
	JP	C,CPYSYS
	LD	A,B
	LD	(SPT0),A
	ENDIF
CPYSYS:	LD	H,FIRSTRK	; System
	LD	L,0
	JP	COPYDEF
COPYZER:
	LD	H,1		; Zero
	LD	L,0
;
;	The one time finish - up routine
;
COPYDEF:
	LD	(TRKSRT),HL
	IF	NOT BXTBL	;GIVE COPY RANGE NOW
	CALL	RANGE
	ENDIF
;
	LD	HL,REPEAT	; go to mainline code now
	LD	(START+1),HL
	JP	(HL)
;
INIT:
	DEFB	CR,LF,'COPYFAST '
	DEFB	'v4.3R '
	IF	BXTBL
	DEFB	'    (Universal'
	ENDIF
;
	IF	NOT BXTBL
	DEFB	'    (Custom'	;e.g. IBM 3740 SS/SD
	ENDIF
	IF	SINGLE
	DEFB	' Single Drive'
	ENDIF
	DEFB	' Version)'
	DEFB	CR,LF
	DEFB	'Sector-for-Sector Disk Duplication Utility'
	DEFB	CR,LF,'$'
;
CALLERR:
	DEFB	CR,LF,'INVALID PARAMETER'
	DEFB	CR,LF,CR,LF
	DEFB	'       Usage:   [d:]COPYFAST ['
	DEFB	'$' OR 80H	;ALLOWS DOLLAR SIGN IN MESSAGE
	DEFB	'option]',CR,LF,CR,LF
	DEFB	'       Options are:  (first letter only)',CR,LF
	DEFB	'All     Entire disk',CR,LF
	DEFB	'Data    CP/M data area',CR,LF
;;	DB	'First   CP/M directory track',CR,LF
;;	DB	'Last    Last track on disk',CR,LF
;;	DB	'One     Track one, UCSD directory',CR,LF
;;	DB	'Pascal  UCSD Pascal data area',CR,LF
	DEFB	'System  CP/M bootstrap',CR,LF
;;	DB	'Zero    Track zero, UCSD bootstrap',CR,LF
	DEFB	'nn      One track, as specified',CR,LF
	DEFB	'n1-n2   A specified range',CR,LF,CR,LF
	IF	BXTBL
	DEFB	'An1 or Sn1 changes track 0 default SPT to n1',CR,LF
	ENDIF
	DEFB	'$'
;
;
	END
