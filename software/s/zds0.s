;--------------------------------------------------------------------------
; crt0.s replacement for Z80 Darkstar (NEZ80)
; by Piergiorgio Betti <pbetti@lpconsul.net>
; 20140824
;--------------------------------------------------------------------------

	.module crt0
	.globl  _main

	.area _HEADER (ABS)

	;; Reset vector
	.org  0x100 ;; Start from address &100

init:

	;; Place stack below bios/bdos....
	ld	hl,(6)
	ld	sp,hl

	;; Initialise global variables
	call	gsinit
	call	_main
	jp	_exit


	;; Ordering of segments for the linker.
	.area	_HOME
	.area	_CODE
	.area	_GSINIT
	.area	_GSFINAL

	.area	_DATA
	.area	_BSS
	.area	_HEAP

	.area	_CODE


__clock::
	ret

_exit::
	ld	a,#255
	jp	0x0000


        .area   _GSINIT
gsinit::

        .area   _GSFINAL
        ret

;;;;;;;;;;;;;;;;
; eof - zds0.s ;
;;;;;;;;;;;;;;;;
