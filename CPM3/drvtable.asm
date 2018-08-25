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
;;		- lowercased
;;---------------------------------------------------------------------

	title	'cp/m 3.1 drive tables'

dph 	macro 	?trans,?dpb,?csize,?asize
	local ?csv,?alv
	dw	?trans			; translate table address
	db	0,0,0,0,0,0,0,0,0	; bdos scratch area
	db	0			; media flag
	dw	?dpb			; disk parameter block
	if ?csize gt 0
	dw	?csv			; checksum vector
	else
	dw	0fffeh			; checksum vector allocated by
	endif				; gencpm
	if ?asize gt 0
	dw	?alv			; allocation vector
	else
	dw	0fffeh			; alloc vector allocated by gencpm
	endif
	dw	0fffeh			; dirbcb, dtabcb, hash alloc'd
	dw	0fffeh			; by gencpm
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
	public	@dtbl
	public	dph0,dph1,dph2,dph3,dph4,dph5,dph6
	public	dph7,dph8,dph9,dph10,dph11,dph12
	public	dph13,dph14,dph15

	extrn	hdvoid, fddvoid
	extrn	hrdvdsk, hwrvdsk, hdvlog
	extrn	iderddsk, idewrdsk, idelogin
	extrn	fddrd, fddwr, fddlog

	; include cp/m 3.0 macro library:

	if	banked
	dseg
	else
	cseg
	endif

	; extended disk parameter header for drive 0:
	defw	fddwr			; virt floppy disk write routine
	defw	fddrd			; virt floppy disk read routine
	defw	fddlog			; virt floppy disk login procedure
	defw	fddvoid			; virt floppy disk drive initialization routine (void)
	defb	0			; relative drive 0 on this controller
	defb	0			; media type

dph0:	dph	trans,fdpb,0,0

	; extended disk parameter header for drive 1:
	defw	fddwr			; virt floppy disk write routine
	defw	fddrd			; virt floppy disk read routine
	defw	fddlog			; virt floppy disk login procedure
	defw	fddvoid			; virt floppy disk drive initialization routine (void)
	defb	0			; relative drive 0 on this controller
	defb	0			; media type

dph1:	dph	trans,fdpb,0,0


	; extended disk parameter header for drive 2: (8 mb partition)
	dw	idewrdsk		; hard disk write routine
	dw	iderddsk		; hard disk read routine
	dw	idelogin		; hard disk login procedure
	dw	hdvoid			; hard disk drive initialization routine (void)
	db	0			; relative drive 0 on this controller
	db	0			; media type
dph2:	dph	0,idep8m,0,0

	; extended disk parameter header for drive 3: (8 mb partition)
	dw	idewrdsk		; hard disk write routine
	dw	iderddsk		; hard disk read routine
	dw	idelogin		; hard disk login procedure
	dw	hdvoid			; hard disk drive initialization routine (void)
	db	0			; relative drive 0 on this controller
	db	0			; media type
dph3:	dph	0,idep8m,0,0


; 	; extended disk parameter header for drive 14:
	defw	fddwr			; virt floppy disk write routine
	defw	fddrd			; virt floppy disk read routine
	defw	fddlog			; virt floppy disk login procedure
	defw	fddvoid			; virt floppy disk drive initialization routine (void)
	defb	0			; relative drive 0 on this controller
	defb	0			; media type

dph14:	dph	trans,fdpb,0,0

	; extended disk parameter header for drive 15:  (8 mb virtual)
	dw	hwrvdsk			; virt hard disk write routine
	dw	hrdvdsk			; virt hard disk read routine
	dw	hdvlog			; virt hard disk login procedure
	dw	hdvoid			; virt hard disk drive initialization routine (void)
	db	0			; relative drive 0 on this controller
	db	0			; media type
dph15:	dph	0,idep8m,0,0

	; make sure dpb's are in common memory:
	cseg

	; floppy drive 0

fdpb:
	dw	44			; spt
	db	4,15			; bsh, blm  --> 2048 bytes block
	db	0			; exm
	dw	433			; dsm
	dw	255			; drm
	db	11110000b		; alloc 0
	db	00000000b		; alloc 1
	;
	dw	64			; cks
	;
	dw	2			; off
	db	2,3			; psh, phm  --> 512 bytes physical sector

	; ide partition 1 is 512x256x64 lba or 8.388.608 bytes
	; dpb	512,256,64,2048,1024,1,8000h

idep8m:
	dw	1024			; spt
	db	4,15			; bsh, blm  --> 2048 bytes block
	db	0			; exm
	dw	4031			; dsm
	dw	1023			; drm
	db	0ffh,0ffh		; al0, al1
	;
	dw	8000h			; cks
	;
	dw	1			; off
	db	2,3			; psh, phm  --> 512 bytes physical sector

	; ide partition 2 is 512x256x64 lba or 8.388.608 bytes
	; dpb	512,256,64,2048,1024,1,8000h

; idep2dpb:
; 	dw	1024			; spt
; 	db	4,15			; bsh, blm  --> 2048 bytes block
; 	db	0			; exm
; 	dw	4031			; dsm
; 	dw	1023			; drm
; 	db	0ffh,0ffh		; al0, al1
; 	;
; 	dw	8000h			; cks
; 	;
; 	dw	1			; off
; 	db	2,3			; psh, phm  --> 512 bytes physical sector

; vhddpb:
; 	dw	1024			; spt
; 	db	4,15			; bsh, blm  --> 2048 bytes block
; 	db	0			; exm
; 	dw	4031			; dsm
; 	dw	1023			; drm
; 	db	0ffh,0ffh		; al0, al1
; 	;
; 	dw	8000h			; cks
; 	;
; 	dw	1			; off
; 	db	2,3			; psh, phm  --> 512 bytes physical sector

	; sector translation table for 512 bytes/11 sec. track (skew = 4)
trans:	defb	1,5,9,2 		; sectors 1,2,3,4
	defb	6,10,3,7	 	; sectors 5,6,7,8
	defb	11,4,8			; sectors 9,10,11

	if	banked
	dseg
	else
	cseg
	endif

;----------------------------------------------------

; dph0	equ	0			; for each enabled drive in above code
; dph1	equ	0			; comment equate here
; dph2	equ	0
; dph3	equ	0
dph4	equ	0
dph5	equ	0
dph6	equ	0
dph7	equ	0
dph8	equ	0
dph9	equ	0
dph10	equ	0
dph11	equ	0
dph12	equ	0
dph13	equ	0
; dph14	equ	0
; dph15	equ	0


@dtbl:	dw	dph0	; a:
	dw	dph1	; b:
	dw	dph2	; c:
	dw	dph3	; d:
	dw	dph4	; e:
	dw	dph5	; f:
	dw	dph6	; g:
	dw	dph7	; h:
	dw	dph8	; i:
	dw	dph9	; j:
	dw	dph10	; k:
	dw	dph11	; l:
	dw	dph12	; m:
	dw	dph13	; n:
	dw	dph14	; o:
	dw	dph15	; p:

	end
;----------------------------------------------------
