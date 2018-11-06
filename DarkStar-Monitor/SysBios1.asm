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
;
; 20180910 - Minor change for unified console management
;
; ---------------------------------------------------------------------

; Common equates for BIOS/Monitor

include Common.inc.asm

	extern	delay, mmpmap, mmgetp, rldrom

	dseg

	name	'SYS1BI'

sysbios1	equ	$		; start of non resident BIOS

	; safe reload, something goes wrong if we are here

	jp	rldrom

sysbid1:
	defb	'SYSBIOS1'

;-------------------------------------
; Needed modules

include modules/consoleio.inc.asm	; 6545 crtc and console io
include modules/genio.inc.asm		; z80 pio on lx529
include modules/kbd.inc.asm		; keyboard
include modules/uartctc.inc.asm		; 16c550 and Z80CTC


sysb1lo:
	defs	sysbios1 + $0bff - sysb1lo
sysb1hi:
	defb	$00
;;
;; end of monitor code - this will fill with zeroes to the end of
;; the eprom

;-------------------------------------

; if	mzmac
; wsym sysbios1.sym
; endif
;
;
	end
;
