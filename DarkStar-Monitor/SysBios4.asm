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
include	services.inc.asm

	extern	rldrom, inline

	dseg

	name	'SYS4BI'

sysbios4	equ	$		; start of non resident BIOS

	; safe reload, something goes wrong if we are here

	jp	rldrom

sysbid4:
	defb	'SYSBIOS4'

montab:
 	defw	cpmboot		; 1 See called service for description...
 	defw	uziboot		; 2
 	defw	booter		; 3

montbe	equ	$
montlen	equ	(montbe-montab)/2

;;
;; This bank reserved for monitor sysbios services
;;
;; sysmon is the service dispatcher
;; C = service id
;; HL used internally, not available for i/o
;; Other register depend on call
;;

sysmon:
	ld	(s4stsav),sp		; switch to our stack
	ld	sp,s4stk
	call	regsav			; save registers in local area
	ld	hl,sysiret		; returns will be to stack restore
	push	hl

	ld	a,c
	sub	$1			; check called id
	jr	c,calerr		; minor 0
	cp	montlen
	jr	nc,calerr		; greater than jump table
	push	de
	add	a,a
	ld	e,a
	ld	d,$00
	ld	hl,montab
	add	hl,de
	pop	de
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	jp	(hl)
	;
sysiret:				; global exit
	call	regrst			; recover reg. status
	ld	sp,(s4stsav)
	ret
	;
calerr:
	call	inline
	defb	"sysbio3: invalid call.",cr,lf,0
	ret
	;
; Store/save register in input
regsav:
	ld	(asav),a
	ld	(hlsav),hl
	ld	(desav),de
	ld	(bcsav),bc
	ret
	;
; Recover register in output
regrst:
	ld	a,(asav)
	ld	hl,(hlsav)
	ld	de,(desav)
	ld	bc,(bcsav)
	ret

	

;-------------------------------------
; Needed modules
;include modules/consoleio.inc.asm	; 6545 crtc and console io
include modules/cpmsupp.inc.asm		; CP/M support routines
include modules/uzisupp.inc.asm		; UZI/FUZIX support routines

;-------------------------------------
; Storage
s4stkbf:
	ds	36			; stack buffer for
s4stk	equ	$			; srstk
s4stsav:
	dw	0			; old stack ptr
hlsav:	dw	0			; hl i/o
desav:	dw	0			; de i/o
bcsav:	dw	0			; bc i/o
asav:	dw	0			; a i/o


;-------------------------------------
sysb4lo:
	defs	sysbios4 + $0bff - sysb4lo
sysb4hi:
	defb	$00
;;
;; end of monitor code - this will fill with zeroes to the end of
;; the eprom


; if	mzmac
; wsym sysbios4.sym
; endif
;
;
	end
;
