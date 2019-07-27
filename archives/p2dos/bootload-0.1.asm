;
; test send 1
;
;list -1
;include darkstar.inc
;list 1

rsym bios.sym


;--------------------
	SIZE	EQU	BEGDAT-CCP		; size of cp/m system
	SECTS	EQU	(SIZE/128)+1		; # of sectors to load
	STSAVE	EQU	CCP			; save stack

	ORG $2000

;       CP/M 2.2 boot-loader for Z80-Simulator
;
;       Copyrigth (C) 1988-95 by Udo Munk
;       Copyrigth (C) 2005-06 by Piergiorgio Betti
;


;
;       begin the load operation
;
BOOTLOAD:
;  	LD	IY, (STSAVE)		; SAVE STACK.
; 	LD	SP, $0080
	LD      BC,CCP          	; base transfer address
	CALL	BSETDMA
	LD	A,(CDISK)
	LD	C, A			; logged drive
	CALL	BSELDSK
	LD	BC, 0			; START TRACK
	CALL	BSETTRK
	CALL	SETSID			; side 0 select
	LD      E,2            		; START SECTOR
	LD      D,SECTS         	; d=# sectors to load
;
;       load the next sector
;
BLSECT:	LD	B, 0
	LD	C, E			; SECTOR
	CALL	BSETSEC
	LD	A,(FDRVBUF)		; get active drive
	CP	2			; is floppy ?
	JP	P,BRDVRT		; no
	;
BRDFLO:	CALL	DRVSEL			; activate driver
	CALL	JREAD			; do read
	LD	IX,FLSECS
	JR	CKERR
	;
BRDVRT:	CALL	VDSKRD			; call par. read
	LD	IX,VDSECS
CKERR:	CP	$00
	JR	NZ, BOOTNOK
	; go to next sector if load is incomplete
	DEC     D               	; sects=sects-1
;	JR	NZ, BLNXTS
	JP      Z,BIOS			; head for the bios
;
;       more sectors to load
;
BLNXTS:	LD	HL, (FRDPBUF)
	; --------- need to be parametrized
; 	LD	BC, 128
	LD	C,(IX+1)
	LD	B,(IX+2)
	; ---------------------------------
	ADD	HL, BC		; next sector #, offset
	LD	(FRDPBUF), HL
;
	INC     E		; sector = sector + 1
	LD      A,E
	CP      (IX+0)		; last sector of track ?
	JR      C,BLSECT	; no, go read another
;
;       end of track, increment to next track
;
	LD	HL, (FTRKBUF)	; track = track + 1
	INC	HL
	LD	(FTRKBUF), HL
	LD      E,1		; sector = 1
	JR      BLSECT		; for another group
BOOTNOK:
	CALL	OUTCRLF
	LD	HL, BLFAILM
	CALL	CONSTR
				; RIPRISTINA LO STACK DEL MONITOR
;  	LD	(STSAVE),IY
;  	LD	SP,(STSAVE)	; SAVE STACK. NOT FOR FINAL LOADER
	JP	BMPRO		; Return to monitor boot menu

BLFAILM:
	DEFB	"BOOT!",CR,LF+$80
;SECTORS DESCS...
VDSECS:	DEFB	27
	DEFW	128
FLSECS:	DEFB	18
	DEFW	128

	IF	($-BOOTLOAD) GT	128
	* BOOTLOAD over 128 bytes - too large!! *
	ENDIF

	END


