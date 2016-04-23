;;
;;----------------------------------------------------------------------------
;; Z80DARKSTAR BOOTLOADER FOR FLOPPIES, HARD (IDE) AND VIRTUAL DISKS
;;----------------------------------------------------------------------------
;;
	include	darkstar.equ
	include	syshw.inc

ISHD?	macro
	xor	a
	push	hl
	ld	hl,ISHDB
	cp	(hl)
	pop	hl
	endm

ISVHD?	macro
	xor	a
	push	hl
	ld	hl,ISVHD
	cp	(hl)
	pop	hl
	endm

;--------------------

	;; We CAN'T no more support 128 byte sector format...
SREFSIZ	EQU	512			; sector reference size
SIZE	EQU	8192			; more then the size of CPMLDR

	ORG 	BLDOFFS			; code start

	DEFB	$55,$AA			; loader signature

;       CP/M 3 boot-loader for Z80Darkstar (NEZ80)
;
;       Copyrigth (C) 2005-2014 by Piergiorgio Betti
;
	;
	;       begin the load operation
	;

BOOTLOAD:
	LD	B,BBPAG << 4		; very important:
	LD	C,MMUPORT		; ensure that sysbios boot page ($BB)
	LD	A,(HMEMPAG)		; is effectively selected, since sysbios
	SUB	4			; boot code not always return to base (boot)
	OUT	(C),A			; page...
	;
	LD      SP,$80			; use space below buffer for stack
	LD	A,(CDISK)		; select...
	LD	C, A			; logged drive
	CALL	BBDSKSEL		;
	LD	IX,FLSECS		; default floppy
	CP	2			; is floppy ?
	JP	M,BLINI			; yes
	CP	14			; is IDE ?
	JP	M,HDINI			; yes
	CP	15			; virtual hd ?
	JR	Z,VHD			; yes (P:)
	JR	BLINI			; no, virtual floppy (O:)


VHD:
	LD	IX,HDSECS		; hd params
	XOR	A			; will use as a flag for hd operations
	DEC	A
	LD	(ISVHD),A
	JR	BLINI

HDINI:
	LD	IX,HDSECS		; hd params
	XOR	A			; will use as a flag for hd operations
	DEC	A
	LD	(ISHDB),A
	;
	;	drive logged, calc sectors to read
	;
BLINI:	LD	L,(IX+0)		; sec. per track in HL
	LD	H,(IX+1)
	LD	E,(IX+2)		; sec. size in DE
	LD	D,(IX+3)
	CALL	BBDPRMSET		; setup in sysbios
	PUSH	IX
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
	LD	IY,TPA			; IY = base offset
	LD      E,1			; START SECTOR
	ISHD?
	JR	NZ,HDSECT		; yes
	ISVHD?
	JR	NZ,INIVH		; yes
	JR	BLSECT

INIVH:
	INC	E			; offset 1 for virtual
	;
	;       load the next sector
	;
HDSECT:
	LD	B,0
	LD	C,E
	LD	(FSECBUF),BC		; sector
	LD	(FRDPBUF),IY		; dma
	JR	DORD

BLSECT:	CALL	LSECTRA			; calc trans sector
	LD	(FRDPBUF),IY		; next dma

	; since we are using a banked sysbios, to access the space
	; freed from F000 to FC00 we must ensure CP/M load operation
	; do NOT overwrite that space during bank switching operated by the
	; BIOS, to serve our requests...
DORD:	LD	HL,(FRDPBUF)		; load DMA address in HL
	PUSH	HL			; save it
	LD	HL,BMBELOW		; temporary DMA after us
	LD	(FRDPBUF),HL		; set up
	ISHD?
	JR	NZ,RDIDE		; read HD sector
	ISVHD?
	JR	NZ,BRDVRT		; read virtual HD sector
	; ------------------------------------------------
	LD	A,(FDRVBUF)		; get active drive
	CP	2			; is real floppy ?
	JP	P,BRDVRT		; no
BRDFLO:	CALL	BBFDRVSEL		; activate driver
	CALL	BBFREAD			; do read
	JR	CKERR
BRDVRT:	CALL	BBRDVDSK		; call par. read
	JR	CKERR
RDIDE:	PUSH	DE
	PUSH	IY			; save ptrs
	CALL	BBHDRD			; call ide read
	POP	IY
	POP	DE
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
	JP      Z,TPA			; head for the cpmldr
	;
	;       more sectors to load
	;
BLNXTS:	INC     E			; sector = sector + 1
	ISHD?
	JR	NZ,HDDMA		; we do not check for end of track since
	ISVHD?				; for lba hd this is quit impossible
	JR	NZ,HDDMA		; (128kb tracks.......)
	LD	BC,512			; bump dma address
	ADD	IY,BC
	LD      A,E
	POP	IX			; recover table address
	PUSH	IX
	CP      (IX+0)			; last sector of track ?
	JR      NZ,BLSECT		; no, go read another
	;
	;       end of track, increment to next track
	;
	LD	BC, (FTRKBUF)		; track = track + 1
	INC	BC
	LD	(FTRKBUF),BC
	LD      E,0			; sector = 0
	JP      BLSECT			; for another track
BOOTNOK:
	LD	HL, BLFAILM
	CALL	PRSTR
	;
	CALL	BBCONIN
 	JP	$FC00			; Return to monitor boot menu
PRSTR:
	LD	C,(HL)
	LD	A,C
	RES	7,C
	CALL	BBCONOUT
	INC	HL
	RLCA
	JR	NC,PRSTR
	RET
HDDMA:
	LD	BC,512			; bump dma address
	ADD	IY,BC
	JP	HDSECT

	;
	; APPLY SKEW FACTOR
	;
LSECTRA:
	PUSH	HL
	PUSH	BC
	LD	B,0
	LD	C,E			; current sec.
	LD	HL,TRANS		; HL= trans
	ADD     HL,BC			; HL= trans(sector)
	LD      L,(HL)			; L = trans(sector)
	LD      H,0			; HL= trans(sector)
	LD	(FSECBUF),HL
	POP	BC
	POP	HL
	RET				; with value in HL
	; sector translation table for 512 bytes/11 sec. track (skew = 4)
TRANS:	DEFB	1,5,9,2 		; sectors 1,2,3,4
	DEFB	6,10,3,7	 	; sectors 5,6,7,8
	DEFB	11,4,8			; sectors 9,10,11


BLFAILM:
	DEFB	CR,LF,"BOOT",'!'+$80
;SECTORS DESCS...
FLSECS:	DEFW	11
	DEFW	512
HDSECS:	DEFW	256
	DEFW	512
ISHDB:	DEFB	0
ISVHD:	DEFB	0

	IF	($-BOOTLOAD+1) GT SREFSIZ
	* BOOTLOAD too large!! *
	ENDIF

BMBELOW:
	DEFS	1

;----------------------------------------------------------------------------

	END


