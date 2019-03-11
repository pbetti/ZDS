;
;=======================================================================
;
; Modular Z80 DarkStar (NE Z80) SysBios
;
;=======================================================================
;
; ---------------------------------------------------------------------
; Revisions:
; 20180831 - Created
; 20190217 - multi service routines
; ---------------------------------------------------------------------
;
; This include specifiy service ids for sysxxx routine on bank > 2
;
;
; --- sysint service list -----------------------
SI_LOGO		equ	1
SI_EFFECT	equ	2
SI_MEMTEST	equ	3
SI_EDIT		equ	4
SI_ROMSEL	equ	5
SI_ROMRUN	equ	6
SI_B2D		equ	7
SI_SETUP	equ	8
SI_ROMBOOT	equ	9

; --- sysmon service list -----------------------
SM_CPMBOOT	equ	1
SM_UZIBOOT	equ	2
SM_USERBOOT	equ	3
SM_HELP		equ	4

; --- effect list -------------------------------
EF_BLNKON	equ	0
EF_BLNKOFF	equ	1
EF_REVON	equ	2
EF_REVOFF	equ	3
EF_UNDRON	equ	4
EF_UNDROFF	equ	5
EF_HLITON	equ	6
EF_HLITOFF	equ	7

; --- editor modes ------------------------------
SE_STR		equ	0
SE_HEX		equ	1
SE_DEC		equ	2
	; mode options
SE_EXTSTR	equ	10000000b
; --- ds1302 ram --------------------------------
DS_READ		equ	0
DS_WRITE	equ	1

DSR_BOOTTYP	equ	0
DSR_DRIVE	equ	1
DSR_OS		equ	3
DSR_HDPART	equ	4
DSR_ROMIMG	equ	5
DSR_DELAY	equ	6
DSR_LOGO	equ	7
DSR_CONSOLE	equ	28
DSR_VALID	equ	29
DSR_SCRATCH	equ	30

; --- logo display ------------------------------
DL_LARGE	equ	0
DL_SMALL	equ	1
DL_NONE		equ	2

; --- binary to decimal -------------------------
BD_ZERO		equ	0
BD_NOZERO	equ	1
	; options
BD_2DIGIT	equ	10000000b

;-----------------------------------------------------------------------
