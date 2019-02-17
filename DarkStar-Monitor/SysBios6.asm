;
;=======================================================================
;
; Modular Z80 DarkStar (NE Z80) Monitor
;
;=======================================================================
;
; Original code:
; Z80 Nuova Elettronica Monitor 390 su eprom 2632 (6k)
;
; Disassembled and reconstructed by
; Piergiorgio Betti <pbetti@lpconsul.net> on 2006 01 26
;
; Latest non modular BIOS is DARKSTAR-MONITOR-0.9.0.asm
; dated 20160631
; - Following addition of MultiF-Board doing complete rewrite of the
;   monitor/BIOS has been started.
;   Major goals:
;   o Modularization: Now monitor can grow up to 266kb instead of 6kb
;     :-)
;   o Specialized images fitted in memory page (6kb) or multiples
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

	name	'SYS6BI'

sysbios6	equ	$		; start of non resident BIOS

	; safe reload, something goes wrong if we are here

	jp	rldrom

sysbid6:
	defb	'SYSBIOS6'

fn1tab:
; 	defw	logo		; 1 See called service for description...

fn1tbe	equ	$
fn1tlen	equ	(fn1tbe-fn1tab)/2

;;
;; This bank reserved for function 1 sysbios services
;;
;; sysinit is the service dispatcher
;; C = service id
;; HL used internally, not available for i/o
;; Other register depend on call
;;

sysfn1:
	ld	(s6stsav),sp		; switch to our stack
	ld	sp,s6stk
	call	regsav			; save registers in local area
	ld	hl,sysiret		; returns will be to stack restore
	push	hl

	ld	a,c
	sub	$1			; check called id
	jr	c,calerr		; minor 0
	cp	fn1tlen
	jr	nc,calerr		; greater than jump table
	push	de
	add	a,a
	ld	e,a
	ld	d,$00
	ld	hl,fn1tab
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
	ld	sp,(s6stsav)
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
s6stkbf:
	ds	36			; stack buffer for
s6stk	equ	$			; srstk
s6stsav:
	dw	0			; old stack ptr
hlsav:	dw	0			; hl i/o
desav:	dw	0			; de i/o
bcsav:	dw	0			; bc i/o
asav:	dw	0			; a i/o


;-------------------------------------

sysb6lo:
	defs	sysbios6 + $0bff - sysb6lo
sysb6hi:
	defb	$00
;;
;; end of monitor code - this will fill with zeroes to the end of
;; the eprom

;-------------------------------------

; if	mzmac
; wsym sysbios6.sym
; endif
;
;
	end
;
