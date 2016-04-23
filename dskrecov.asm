;
; test send 1
;
;list -1
;include darkstar.inc
;list 1

rsym darkstar.sym


;--------------------
	org $ea00
START:	jp	RECOVER
;START:	jp	STEP4
;       CP/M 2.2 boot-loader for Z80-Simulator
;
;       Copyrigth (C) 1988-95 by Udo Munk
;

SAVMSG:	DEFB	"Saving",$A0
STMSG:	defb	"Sec.:",' '+$80
STMSG1:	defb	" Trk.:",' '+$80
STMOK:	defb	" -> OK.",$0d,$0a+$80
STMNOK:	defb	" -> NOK.",$0d,$0a+$80
;
;       begin the load operation
;
RSEC:	defw	1
RTRK:	defw	0
RDMA:	defw	$0100
RBLK:	defb	10
WSEC:	defw	1
WTRK:	defw	0
WDMA:	defw	$0100
WSIZ:	defb	170		; (10 TRKS * 17 SECTS)

RECOVER:
	LD	HL,0
	LD	(RTRK),HL
	LD	(WTRK),HL
	INC	HL
	LD	(RSEC),HL
	LD	(WSEC),HL
	LD	HL,$0100
	LD	(RDMA),HL
	LD	(WDMA),HL
	LD	A,170
	LD	(WSIZ),A
	LD	A,10
	LD	(RBLK),A
	LD	A,(MIOBYTE)
	SET	0,A
	LD	C, 0		; drive A
	CALL	BSELDSK
	CALL	DRVSEL
	CALL	BHOME
STEP1:
	LD	A,(MIOBYTE)
	SET	0,A
	LD      BC,(RDMA)          ; base transfer address
	CALL	BSETDMA
	LD	BC,(RTRK)
	CALL	BSETTRK
	LD      BC,(RSEC)        	; START SECTOR
	CALL	BSETSEC
	CALL	DRVSEL
	CALL	AVMSG

	CALL	MREAD		; perform i/o
	AND	$1f             ; test for errors
	JR	Z, STEP2
	CALL	FILL11
 	LD	A,$01
 	OUT	(FDCDRVRCNT),A
	;CALL	BHOME
;	CALL	AVMSG
	LD	HL,STMNOK
	CALL	CONSTR
	JR	STEP5
STEP2:
;	CALL	AVMSG
	LD	HL,STMOK
	CALL	CONSTR
STEP5:
	LD	HL,RSEC
	INC	(HL)
	LD	HL,(RSEC)
	LD	A,L
	CP	18		; EOT ?
	JR	Z, STEP3	; NXT TRK
	LD	HL,(RDMA)
	LD	BC, 128		; SEC LEN
	ADD	HL,BC
	LD	(RDMA),HL
	JR	STEP1		; NXT SEC
STEP3:
	LD	HL,RTRK
	INC	(HL)
	LD	HL,(RTRK)
	LD	A,L
	LD	HL,RBLK
	CP	(HL)		; EOB ?
	JR	Z, STEP4	; NXT BLK
	LD	A,0
	LD	(RSEC), A	; LOOP
	JR	STEP5
STEP4:
	LD	C, 1		; drive B (on virtual)
	CALL	BSELDSK
WSTEP1:
	LD      BC,(WDMA)          ; base transfer address
	CALL	BSETDMA
	LD	BC,(WTRK)
	CALL	BSETTRK
	LD      BC,(WSEC)        	; START SECTOR
	CALL	BSETSEC

	CALL	VDSKWR		; perform i/o
	CALL	WAVMSG
	LD	HL,STMOK
	CALL	CONSTR
WSTEP2:
	LD	HL,WSIZ
	DEC	(HL)
	LD	A,(WSIZ)
	CP	0		; WEOB ?
	JR	Z,WSTEP4
WSTEP5:
	LD	HL,WSEC
	INC	(HL)
	LD	HL,(WSEC)
	LD	A,L
	CP	18		; EOT ?
	JR	Z, WSTEP3	; NXT TRK
	LD	HL,(WDMA)
	LD	BC, 128		; SEC LEN
	ADD	HL,BC
	LD	(WDMA),HL
	JR	WSTEP1		; NXT SEC
WSTEP3:
	LD	HL,WTRK
	INC	(HL)
	LD	A,0
	LD	(WSEC),A	; LOOP
	JR	WSTEP5
WSTEP4:
	LD	HL,(RBLK)
	LD	BC,10
	ADD	HL,BC
	LD	(RBLK),HL
	LD	A,L
	CP	50		; EOD ?
	JR	Z,RECOVEND
	LD	HL,1
	LD	(WSEC),HL
	LD	HL,WTRK
	INC	(HL)
	LD	HL,$0100
	LD	(WDMA),HL
	LD	HL,$0080
	LD	(RDMA),HL
	LD	A,170
	LD	(WSIZ),A
	LD	A,0
	LD	(RSEC),A	; LOOP
	LD	C, 0		; drive A
	CALL	BSELDSK
	CALL	DRVSEL
	JP	STEP5
RECOVEND:

	RET

AVMSG:
	LD	HL, STMSG
	CALL	CONSTR
	LD	HL,(RSEC)
	LD	A,L
	;DAA
	CALL	H2AJ1
	LD	HL, STMSG1
	CALL	CONSTR
	LD	HL,(RTRK)
	LD	A,L
	;DAA
	CALL	H2AJ1
	RET

WAVMSG:
	LD	HL, SAVMSG
	CALL	CONSTR
	LD	HL, STMSG
	CALL	CONSTR
	LD	HL,(WSEC)
	LD	A,L
	;DAA
	CALL	H2AJ1
	LD	HL, STMSG1
	CALL	CONSTR
	LD	HL,(WTRK)
	LD	A,L
	;DAA
	CALL	H2AJ1
	RET

FILL11:
	LD	B, 128
	LD	A, $11
	LD	HL,(RDMA)
FILL111:
	LD	(HL),A
	INC	HL
	DJNZ	FILL111
	RET

DMS0:	defb	" fseeked",' '+$80
DMS1:	defb	" timeout",' '+$80

MREAD:
	ld     a,(MIOBYTE)       ; was 00F50D 3A 47 00
	set    0,a
	jr     MWAITIO
;;
;; BWRITE - write a sector
;
MWRITE:
	ld     a,(MIOBYTE)       ; was 00F514 3A 47 00
	res    0,a
;;
;; BWAITIO - read or write a sector depending on MIOBYTE
;
MWAITIO:
	ld     (MIOBYTE),a       ; was 00F519 32 47 00
MFRWLP:	call   FSEEK
	jr     nz,MFSHTM
	ld     hl, DMS0
	call   CONSTR
	ld     b,$0a           ; 10 retries
MFRWNXT:
	ld     hl,(FRDPBUF)
	push   bc
	ld     bc,FRWWORD
	ld     a,(MIOBYTE)
	bit    0,a
	jr     z,MFRWWRO
	ld     de,$8000		; loop exit
	ld     a,FDCREADC           ; read command
	call   SFDCCMD
MFRRDY:
	dec	de
	ld	a, d
	or	e
	jr	z, MRDERR	; read tmout
	in     a,(FDCCMDSTATR)
	bit    1,a             ; sec found
	jr     z,MFRRDY
	ld     de,$8000		; loop exit
	ini
	jr     nz,MFRRDY
	jr     MFWEND
MFRWWRO:
	ld     a,FDCWRITC
	call   SFDCCMD
MFWRDY:
	in     a,(FDCCMDSTATR)
	bit    1,a
	jr     z,MFWRDY
	outi
	jr     nz,MFWRDY
MFWEND:
	call   GFDCSTAT
	pop    bc
	and    $1f             ; test fo errors
	jr     z,MFSHTM
	djnz   MFRWNXT
MFSHTM:
	push   af
	xor    a
	out    (FDCDRVRCNT),a
	pop    af
	ret
MRDERR:
	ld     hl, DMS1
	call   CONSTR
	pop    bc
	ld     b,1
	push   bc
	jr     MFWEND

	end
