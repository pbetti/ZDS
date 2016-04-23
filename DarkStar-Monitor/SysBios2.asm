;
;=======================================================================
;
; Modular Z80 DarkStar (NE Z80) Monitor
;
;=======================================================================
;
; Original code:
; Z80 Nuova Elettronica Monitor 390 su eprom 2532 (4k)
;
; Disassembled and reconstructed by
; Piergiorgio Betti <pbetti@lpconsul.net> on 2005 01 26
;
; Latest non modular BIOS is DARKSTAR-MONITOR-0.9.0.asm
; dated 20140531
; - Following addition of MultiF-Board doing complete rewrite of the
;   monitor/BIOS has been started.
;   Major goals:
;   o Modularization: Now monitor can grow up to 256kb instead of 4kb
;     :-)
;   o Specialized images fitted in memory page (4kb) or multiples
;   o Full support for new hardware
;   o I/O rewrite for MODE 2 interrupts
;   Minor goals:
;   o Full code clean-up & reorganization
; ---------------------------------------------------------------------

; Common equates for BIOS/Monitor

include Common.inc.asm

	EXTERN	DELAY, MMPMAP, MMGETP, RLDROM

	DSEG

	NAME	'SYS2BI'

SYSBIOS2	EQU	$		; start of non resident BIOS

	; safe reload, something goes wrong if we are here

	JP	RLDROM

SYSBID2:
	DEFB	'SYSBIOS2'

;
; store sector size for variable disk format operations
;
; HL < # secs per track, DE < sec. lenght
SETDPRM:
	LD	(CSPTR),HL
	LD	(CSLEN),DE
	RET


;-------------------------------------
; Needed modules
include modules/floppy.inc.asm		; fd1771
include modules/parcom.inc.asm		; parallel link
include modules/clock.inc.asm		; ds1302
include modules/cpmsupp.inc.asm		; CP/M support routines
include modules/math.inc.asm		; math support
include modules/ide.inc.asm		; 8255 ide i/f

;-------------------------------------

CSPTR:	DEFW	0
CSLEN:	DEFW	0

SYSB2LO:
	DEFS	SYSBIOS2 + $0BFF - SYSB2LO
SYSB2HI:
	DEFB	$00
;;
;; end of code - this will fill with zeroes to the end of
;; the image

;-------------------------------------

IF	MZMAC
WSYM sysbios2.sym
ENDIF
;
;
	END
;
