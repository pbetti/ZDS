;
;=======================================================================
;
; Modular Z80 DarkStar (NE Z80) Monitor
;
;=======================================================================
;
; CP/M 2 or 3 BIOS support utilities
; ---------------------------------------------------------------------


	;       character and disk i/o handlers for cp/m BIOS
	;	This are moved here from BIOS since we need to keep
	;	space...
;;
;; FDRVSEL - select drive for r/w ops
;
FDRVSEL:
	PUSH	AF			;
	PUSH	HL			;
	LD	HL,HDRVV		; 10
	LD	A,(FDRVBUF)		; 13
	ADD	A,L			; 4
	LD	L,A			; 4
	LD	A,(HL)			; 7
	LD	H,A			;
	LD	A, (DSELBF)
	AND	$F0
	OR	H
	LD	(DSELBF),A		; 13
	OUT	(FDCDRVRCNT),A		; 11
	POP	HL			;
	POP	AF			;
	RET				;
	;
	; This used to translate the drive number in a cmd byte suitable
	; for drive selection on the floppy board
HDRVV:	DEFB	$01			; drive 1
	DEFB	$02			; drive 2
	DEFB	$04			; drive 3
	DEFB	$08 			; drive 4

;;
;; CPMBOOT - boostrap cp/m
;
CPMBOOT:
	LD	DE,512
	CALL	SETDPRM
	LD	BC,$00
	CALL	TRKSET
	LD	A,(CDISK)		; get logged drive
	LD	C,A
	CALL	DSKSEL
	CALL	FDRVSEL
	CALL	FHOME
	RET	NZ
	LD	BC,BLDOFFS		; read in loader
	CALL	DMASET
	LD	BC,$01
	CALL	SECSET
	CALL	FREAD
	RET	NZ
	JP	BLDOFFS+2		; jump to the loader if all ok

;;
;; VCPMBT
;;
;; Boot CP/M from parallel link
;
VCPMBT:
	LD	BC, BLDOFFS          	; base transfer address
	CALL	DMASET
	LD	A,(CDISK)		; get logged drive
	LD	C, A			; make active
	CALL	DSKSEL
	LD	BC, 0			; START TRACK
	CALL	TRKSET
	LD	BC, 1			; start sector
	CALL	SECSET
	LD	DE,128
	CALL	SETDPRM
	CALL	VDSKRD			; perform i/o 128
	OR	A
	RET	Z
	LD	DE,256
	CALL	SETDPRM
	CALL	VDSKRD			; perform i/o 256
	OR	A
	RET	Z
	LD	DE,512
	CALL	SETDPRM
	CALL	VDSKRD			; perform i/o 512
	OR	A
	RET

;;
;; HDCPM - boostrap cp/m from IDE
;
HDCPM:
	LD	A,(CDISK)		; get logged drive
	LD	C,A
	CALL	DSKSEL
	LD	BC,BLDOFFS		; read in loader @ BLDOFFS
	CALL	DMASET
	LD	BC,$00
	CALL	TRKSET
	LD	BC,$00
	CALL	SECSET
	CALL	READSECTOR
	LD	D,0			; error type (no volume)
	RET	NZ
	LD	DE,(HDBSIG)		; check for a valid bootloader
	LD	HL,(BLDOFFS)
	OR	A
	SBC	HL,DE
	LD	D,1			; error type (no bootloader)
	RET	NZ			; no bootlader found
	JP	BLDOFFS+2		; jump to the loader if all ok
	RET

HDBSIG:	DEFB	$55,$AA


TRKSET:
	LD	(FTRKBUF),BC
	RET
SECSET:
	LD	(FSECBUF),BC
	RET
DMASET:
	LD	(FRDPBUF),BC
	RET
DSKSEL:
	LD	A,C
	LD	(FDRVBUF),A
	RET

; 	;
; 	;
; 	; RTC handler routine
; 	;
; CPTIME:	LD	A,C			; read or write ?
; 	OR	A
; 	JR	NZ,TIMWRI
; 	PUSH	DE			; save user buffer address
; 	PUSH	IY
; 	POP	HL			; load private storage area
; ; 	CALL	RDTIME
; 	DEC	HL			; HL is at year buffer
; 	POP	DE			; restore user buffer
; 	;
; 	LD	A,7			; 7 byte to fix
; TIMLOA:	LD	C,(HL)
; 	;
; 	CP	6			; offset 6 (local) is day of week...
; 	JR	Z,TIMSY0		; so skip it
; 	;
; 	EX	DE,HL			; swap HL and DE
; 	CP	1			; last (old) byte need to be saved
; 	JR	NZ,TIMNLS		; not the one
; 	LD	B,(HL)			; save in B
; TIMNLS:	LD	(HL),C			; now can load C in (DE)
; 	EX	DE,HL			; reset swap
; 	INC	DE			; advance RTCBUF ptr
; TIMSY0:	DEC	HL			; back one on top of RTCBUF
; 	DEC	A			; all done ?
; 	JR	NZ,TIMLOA		; if no loop
; 	DEC	DE			; exit: put DE at buffer top
; 	EX	DE,HL			; save buffer top in HL
; 	LD	E,B			; put in E old (top) buffer content
; 	XOR	A
; 	INC	A			; all good
; 	RET
; 	;
; TIMWRI:	LD	A,$FF			; unsupported here
; 	RET
