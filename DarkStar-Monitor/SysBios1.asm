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

	NAME	'SYS1BI'

SYSBIOS1	EQU	$		; start of non resident BIOS

	; safe reload, something goes wrong if we are here

	JP	RLDROM

SYSBID1:
	DEFB	'SYSBIOS1'

;-------------------------------------
; Needed modules

include modules/crtc.inc.asm		; 6545 crtc
include modules/genio.inc.asm		; z80 pio on lx529
include modules/kbd.inc.asm		; keyboard
include modules/uartctc.inc.asm		; 16c550 and Z80CTC


SYSB1LO:
	DEFS	SYSBIOS1 + $0BFF - SYSB1LO
SYSB1HI:
	DEFB	$00
;;
;; end of monitor code - this will fill with zeroes to the end of
;; the eprom

;-------------------------------------

IF	MZMAC
WSYM sysbios1.sym
ENDIF
;
;
	END
;
