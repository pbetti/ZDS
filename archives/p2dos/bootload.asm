;;
;;----------------------------------------------------------------------------
;; Z80DARKSTAR BOOTLOADER FOR FLOPPIES, HARD (IDE) AND VIRTUAL DISKS
;;----------------------------------------------------------------------------
;;
rsym bios.sym				; take symbols from bios


;--------------------
SREFSIZ	EQU	512			; sector reference size
IF SREFSIZ EQ 512
SIZE	EQU	(512*11*2)		; size of cp/m system
ELSE
SIZE	EQU	(128*32*2)-1		; size of cp/m system
ENDIF
					; high order byte of monitor
MONHBY	EQU	((SYSBASE - SREFSIZ) >> 8) & $FF

	ORG BLDOFFS			; code start


;       CP/M 2.2 boot-loader for Z80-Simulator
;
;       Copyrigth (C) 2005-06 by Piergiorgio Betti
;
	;
	;       begin the load operation
	;
BOOTLOAD:
	LD      SP,$80			; use space below buffer for stack
	LD	A,(CDISK)		; select...
	LD	C, A			; logged drive
	CALL	BBDSKSEL		;
	LD	IX,FLSECS		; default floppy
	CP	3			; is floppy ?
	JP	M,BLINI			; yes
	LD	IX,VDSECS		; no
	;
	;	drive logged, calc sectors to read
	;
BLINI:	LD	E,(IX+2)		; sec. size in DE
	LD	D,(IX+3)
	LD	BC,SIZE			; CP/M size in BC
	CALL	BBDIV16			; div cpmsize/secsize
	LD	D,C			; # SECTORS in D
	INC	D			; pad
	;
	; track, side, start sector
	;
	LD	BC, 0			; START TRACK
	CALL	BBTRKSET
	CALL	BBSIDSET		; side 0 select
	LD      E,2			; START SECTOR
	LD	IY,CCP			; IY = base offset
	;
	;       load the next sector
	;
BLSECT:	CALL	BBOFFCAL		; calc trans sector and offset
IF SREFSIZ EQ 512
	LD	A,(FRDPBUF+1)		; high order byte of dma in A
	CP	MONHBY			; since read is out-of-order we discard
	JP	P,SKIPRD		; sectors overwriting MONITOR area
ENDIF
	; since we are using a banked bios, to access the space
	; freed from F000 to FC00 we must ensure CP/M load operation
	; do NOT overwrite that space during bank switching operated by the
	; BIOS, to serve our requests...
	LD	HL,(FRDPBUF)		; load DMA address in HL
	PUSH	HL			; save it
	LD	HL,BMBELOW		; temporary DMA after us
	LD	(FRDPBUF),HL		; set up
	; ------------------------------------------------
	LD	A,(FDRVBUF)		; get active drive
	CP	2			; is floppy ?
	JP	P,BRDVRT		; no
BRDFLO:	CALL	BBFDRVSEL		; activate driver
	CALL	BBFREAD			; do read
	JR	CKERR
BRDVRT:	CALL	BBRDVDSK		; call par. read
CKERR:	OR	A
	JR	NZ, BOOTNOK

	POP	HL			; recover real DMA address
	PUSH	DE			; saves DE
	EX	DE,HL			; DMA in DE
	LD	HL,BMBELOW		; our buffer
	LD	BC,SREFSIZ		; size
	LDIR				; put in right place
	POP	DE			; recover our counters

	; go to next sector if load is incomplete
SKIPRD:	DEC     D               	; sects=sects-1
	JP      Z,BIOS			; head for the bios
	;
	;       more sectors to load
	;
BLNXTS:	INC     E		; sector = sector + 1
	LD      A,E
	DEC	A		; offset is zero based in table
	CP      (IX+0)		; last sector of track ?
	JR      C,BLSECT	; no, go read another
	;
	;       end of track, increment to next track
	;
	LD	BC, (FTRKBUF)	; track = track + 1
	INC	BC
	LD	(FTRKBUF),BC
	LD      E,1		; sector = 0
	JR      BLSECT		; for another group
BOOTNOK:
	LD	HL, BLFAILM
	CALL	PRSTR
	;
	CALL	BBCONIN		; *** TO SETUP WHEN THINGS IN FINAL PLACE
	JP	$1000		; jump to debugger
; 	JP	BMPRO		; Return to monitor boot menu
PRSTR:
	LD	C,(HL)
	LD	A,C
	RES	7,C
	CALL	BBCONOUT
	INC	HL
	RLCA
	JR	NC,PRSTR
	RET

BLFAILM:
	DEFB	CR,LF,"BOOT",'!'+$80
;SECTORS DESCS...
VDSECS:	DEFW	11
	DEFW	512
FLSECS:	DEFW	11
	DEFW	512

	IF	($-BOOTLOAD+1) GT SREFSIZ
	* BOOTLOAD too large!! *
	ENDIF

BMBELOW:
	DEFS	1

;----------------------------------------------------------------------------

	END


