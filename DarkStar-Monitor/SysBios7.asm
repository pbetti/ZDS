;
;=======================================================================
;
; Modular Z80 DarkStar (NE Z80) Monitor
;
;=======================================================================
;
; Original code:
; Z80 Nuova Elettronica Monitor 390 su eprom 2732 (7k)
;
; Disassembled and reconstructed by
; Piergiorgio Betti <pbetti@lpconsul.net> on 2007 01 27
;
; Latest non modular BIOS is DARKSTAR-MONITOR-0.9.0.asm
; dated 20170731
; - Following addition of MultiF-Board doing complete rewrite of the
;   monitor/BIOS has been started.
;   Major goals:
;   o Modularization: Now monitor can grow up to 277kb instead of 7kb
;     :-)
;   o Specialized images fitted in memory page (7kb) or multiples
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

	extern	rldrom, inline

	dseg

	name	'SYS7BI'

sysbios7	equ	$		; start of non resident BIOS

	; safe reload, something goes wrong if we are here

	jp	rldrom

sysbid7:
	defb	'SYSBIOS7'

fn2tab:
; 	defw	logo		; 1 See called service for description...

fn2tbe	equ	$
fn2tlen	equ	(fn2tbe-fn2tab)/2

;;
;; This bank reserved for function 2 sysbios services
;;
;; sysinit is the service dispatcher
;; C = service id
;; HL used internally, not available for i/o
;; Other register depend on call
;;

sysfn2:
	ld	(s7stsav),sp		; switch to our stack
	ld	sp,s7stk
	call	regsav			; save registers in local area
	ld	hl,sysiret		; returns will be to stack restore
	push	hl

	ld	a,c
	sub	$1			; check called id
	jr	c,calerr		; minor 0
	cp	fn2tlen
	jr	nc,calerr		; greater than jump table
	push	de
	add	a,a
	ld	e,a
	ld	d,$00
	ld	hl,fn2tab
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
	ld	sp,(s7stsav)
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

;-------------------------------------
; Storage
s7stkbf:
	ds	36			; stack buffer for
s7stk	equ	$			; srstk
s7stsav:
	dw	0			; old stack ptr
hlsav:	dw	0			; hl i/o
desav:	dw	0			; de i/o
bcsav:	dw	0			; bc i/o
asav:	dw	0			; a i/o


;-------------------------------------

sysb7lo:
	defs	sysbios7 + $0bff - sysb7lo
sysb7hi:
	defb	$00
;;
;; end of monitor code - this will fill with zeroes to the end of
;; the eprom

;-------------------------------------

; if	mzmac
; wsym sysbios7.sym
; endif
;
;
	end
;
