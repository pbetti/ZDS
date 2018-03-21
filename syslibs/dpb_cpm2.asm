;
; Disk paramtere block for CP/M 2
;

;
; version for ZDSnative
;
DPBVRT:	DEFW	TRANS, 0000
	DEFW	0000,  0000
	DEFW	DIRBF,DPBNDS
	DEFW	CHK02,ALL02


	; sector translation table for 512 bytes/11 sec. track (skew = 4)
TRANS:	DEFB	1,5,9,2 		; sectors 1,2,3,4
	DEFB	6,10,3,7	 	; sectors 5,6,7,8
	DEFB	11,4,8			; sectors 9,10,11

	; Ultimate size 11 * 512 * 160
DPBNDS:	DEFW    44			; sectors per track (DAB2)
	DEFB    4			; block shift factor
	DEFB    15			; block mask
	DEFB    0			; null mask
	DEFW    433			; disk size-1
	DEFW    255			; directory max
	DEFB    240			; alloc 0
	DEFB    0			; alloc 1
	DEFW    64			; medium changable
	DEFW    2			; track offset (DAC0)
	; non-standard part (Phisical CHS infos)
	DEFW	11			; sectors per track
	DEFW	512			; sector lenght
	DEFB	2			; heads
	DEFW	80			; tracks
	DEFB	2			; deblock shift
	DEFB	3			; deblock mask
	DEFB	16			; 128 byte sectors per block


DIRBF:  DEFS    128		; scratch directory area
ALL02:  DEFS    55		; allocation vector 2
CHK02:  DEFS    64		; check vector 2


;;
