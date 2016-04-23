;
;=======================================================================
;
; CP/M 3 Z80 DarkStar (NE Z80) Porting
;
;=======================================================================
;;---------------------------------------------------------------------
;; Version      : 1.0 - 20140904
;; Assemble     : SLR z80asm
;; Revisions:
;; 20140905	- Code start
;;---------------------------------------------------------------------

	TITLE	'CP/M 3.1 DRIVE TABLES'

dph 	macro 	?trans,?dpb,?csize,?asize
	local ?csv,?alv
	dw	?trans			; translate table address
	db	0,0,0,0,0,0,0,0,0	; BDOS Scratch area
	db	0			; media flag
	dw	?dpb			; disk parameter block
	if ?csize gt 0
	dw	?csv			; checksum vector
	else
	dw	0fffeh			; checksum vector allocated by
	endif				; GENCPM
	if ?asize gt 0
	dw	?alv			; allocation vector
	else
	dw	0fffeh			; alloc vector allocated by GENCPM
	endif
	dw	0fffeh			; dirbcb, dtabcb, hash alloc'd
	dw	0fffeh			; by GENCPM
	dw	0fffeh			;
	db	0			; hash bank
	if ?csize gt 0
?csv	ds	?csize			; checksum vector
	endif
	if ?asize gt 0
?alv	ds	?asize			; allocation vector
	endif
	endm


	; define logical values:
	include	common.inc

	; define public labels:
	PUBLIC	@DTBL
	PUBLIC	DPH0,DPH1,DPH2,DPH3,DPH4,DPH5,DPH6
	PUBLIC	DPH7,DPH8,DPH9,DPH10,DPH11,DPH12
	PUBLIC	DPH13,DPH14,DPH15

	EXTRN	HDVOID, FDDVOID
	EXTRN	HRDVDSK, HWRVDSK, HDVLOG
	EXTRN	IDERDDSK, IDEWRDSK, IDELOGIN
	EXTRN	FDDRD, FDDWR, FDDLOG

	; include cp/m 3.0 macro library:

	IF	BANKED
	DSEG
	ELSE
	CSEG
	ENDIF

	; extended disk parameter header for drive 0:
	DEFW	FDDWR			; virt floppy disk write routine
	DEFW	FDDRD			; virt floppy disk read routine
	DEFW	FDDLOG			; virt floppy disk login procedure
	DEFW	FDDVOID			; virt floppy disk drive initialization routine (void)
	DEFB	0			; relative drive 0 on this controller
	DEFB	0			; media type

DPH0:	DPH	TRANS,FDPB,0,0

	; extended disk parameter header for drive 1:
	DEFW	FDDWR			; virt floppy disk write routine
	DEFW	FDDRD			; virt floppy disk read routine
	DEFW	FDDLOG			; virt floppy disk login procedure
	DEFW	FDDVOID			; virt floppy disk drive initialization routine (void)
	DEFB	0			; relative drive 0 on this controller
	DEFB	0			; media type

DPH1:	DPH	TRANS,FDPB,0,0


	; extended disk parameter header for drive 2: (8 Mb partition)
	DW	IDEWRDSK		; hard disk write routine
	DW	IDERDDSK		; hard disk read routine
	DW	IDELOGIN		; hard disk login procedure
	DW	HDVOID			; hard disk drive initialization routine (void)
	DB	0			; relative drive 0 on this controller
	DB	0			; media type
DPH2:	DPH	0,IDEP8M,0,0

	; extended disk parameter header for drive 3: (8 Mb partition)
	DW	IDEWRDSK		; hard disk write routine
	DW	IDERDDSK		; hard disk read routine
	DW	IDELOGIN		; hard disk login procedure
	DW	HDVOID			; hard disk drive initialization routine (void)
	DB	0			; relative drive 0 on this controller
	DB	0			; media type
DPH3:	DPH	0,IDEP8M,0,0


; 	; extended disk parameter header for drive 14:
	DEFW	FDDWR			; virt floppy disk write routine
	DEFW	FDDRD			; virt floppy disk read routine
	DEFW	FDDLOG			; virt floppy disk login procedure
	DEFW	FDDVOID			; virt floppy disk drive initialization routine (void)
	DEFB	0			; relative drive 0 on this controller
	DEFB	0			; media type

DPH14:	DPH	TRANS,FDPB,0,0

	; extended disk parameter header for drive 15:  (8 Mb virtual)
	DW	HWRVDSK			; virt hard disk write routine
	DW	HRDVDSK			; virt hard disk read routine
	DW	HDVLOG			; virt hard disk login procedure
	DW	HDVOID			; virt hard disk drive initialization routine (void)
	DB	0			; relative drive 0 on this controller
	DB	0			; media type
DPH15:	DPH	0,IDEP8M,0,0

	; make sure dpb's are in common memory:
	CSEG

	; Floppy drive 0

FDPB:
	DW	44			; SPT
	DB	4,15			; BSH, BLM  --> 2048 BYTES BLOCK
	DB	0			; EXM
	DW	433			; DSM
	DW	255			; DRM
	DB	11110000B		; alloc 0
	DB	00000000B		; alloc 1
	;
	DW	64			; CKS
	;
	DW	2			; OFF
	DB	2,3			; PSH, PHM  --> 512 BYTES PHYSICAL SECTOR

	; IDE partition 1 is 512x256x64 LBA or 8.388.608 bytes
	; DPB	512,256,64,2048,1024,1,8000H

IDEP8M:
	DW	1024			; SPT
	DB	4,15			; BSH, BLM  --> 2048 BYTES BLOCK
	DB	0			; EXM
	DW	4031			; DSM
	DW	1023			; DRM
	DB	0FFH,0FFH		; AL0, AL1
	;
	DW	8000H			; CKS
	;
	DW	1			; OFF
	DB	2,3			; PSH, PHM  --> 512 BYTES PHYSICAL SECTOR

	; IDE partition 2 is 512x256x64 LBA or 8.388.608 bytes
	; DPB	512,256,64,2048,1024,1,8000H

; IDEP2DPB:
; 	DW	1024			; SPT
; 	DB	4,15			; BSH, BLM  --> 2048 BYTES BLOCK
; 	DB	0			; EXM
; 	DW	4031			; DSM
; 	DW	1023			; DRM
; 	DB	0FFH,0FFH		; AL0, AL1
; 	;
; 	DW	8000H			; CKS
; 	;
; 	DW	1			; OFF
; 	DB	2,3			; PSH, PHM  --> 512 BYTES PHYSICAL SECTOR

; VHDDPB:
; 	DW	1024			; SPT
; 	DB	4,15			; BSH, BLM  --> 2048 BYTES BLOCK
; 	DB	0			; EXM
; 	DW	4031			; DSM
; 	DW	1023			; DRM
; 	DB	0FFH,0FFH		; AL0, AL1
; 	;
; 	DW	8000H			; CKS
; 	;
; 	DW	1			; OFF
; 	DB	2,3			; PSH, PHM  --> 512 BYTES PHYSICAL SECTOR

	; sector translation table for 512 bytes/11 sec. track (skew = 4)
TRANS:	DEFB	1,5,9,2 		; sectors 1,2,3,4
	DEFB	6,10,3,7	 	; sectors 5,6,7,8
	DEFB	11,4,8			; sectors 9,10,11

	IF	BANKED
	DSEG
	ELSE
	CSEG
	ENDIF

;----------------------------------------------------

; DPH0	EQU	0			; for each enabled drive in above code
; DPH1	EQU	0			; comment equate here
; DPH2	EQU	0
; DPH3	EQU	0
DPH4	EQU	0
DPH5	EQU	0
DPH6	EQU	0
DPH7	EQU	0
DPH8	EQU	0
DPH9	EQU	0
DPH10	EQU	0
DPH11	EQU	0
DPH12	EQU	0
DPH13	EQU	0
; DPH14	EQU	0
; DPH15	EQU	0


@DTBL:	DW	DPH0	; A:
	DW	DPH1	; B:
	DW	DPH2	; C:
	DW	DPH3	; D:
	DW	DPH4	; E:
	DW	DPH5	; F:
	DW	DPH6	; G:
	DW	DPH7	; H:
	DW	DPH8	; I:
	DW	DPH9	; J:
	DW	DPH10	; K:
	DW	DPH11	; L:
	DW	DPH12	; M:
	DW	DPH13	; N:
	DW	DPH14	; O:
	DW	DPH15	; P:

	END
;----------------------------------------------------
