;--------------------------------------------------------------------------
; crt0.s replacement for Z80 Darkstar (NEZ80)
; by Piergiorgio Betti <pbetti@lpconsul.net>
; 20181002
; CP/M 3 version
;--------------------------------------------------------------------------

.include "darkstar.inc"

bdos	.equ	0x5	; where to call
cdio	.equ	0x6	; direct console i/o

	.module crt0
	.globl  _main
	.globl	l__INITIALIZER
	.globl	s__INITIALIZED
	.globl	s__INITIALIZER
	.globl	s__HEAP_END

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
;
	.area	_HOME
	.area	_CODE
	.area	_INITIALIZED
	.area   _GSINIT
	.area   _GSFINAL
	.area	_DATA
	.area	_INITIALIZER
	.area	_BSEG
	.area   _BSS
	.area   _HEAP


	.area	_CODE

			; Fundamental routines for console i/o on sdcc
_putchar::
_putchar_rr_s::
	ld	hl,#2
	add	hl,sp

	ld	e,(hl)
	ld	c,#cdio
	call	bdos
	ret

_putchar_rr_dbs::

	ld	c,#cdio
	call	bdos
	ret

_getchar::
	ld	e,#0xfd
	ld	c,#cdio
	call	bdos
	ret

_heapend::
	ld	hl, #s__HEAP_END
	ret

_exit::
	ld	a,#255
	jp	0x0000


	.area   _GSINIT
gsinit::
	ld	bc, #l__INITIALIZER
	ld	a, b
	or	a, c
	jr	Z, gsinit_next
	ld	de, #s__INITIALIZED
	ld	hl, #s__INITIALIZER
	ldir
gsinit_next:

	.area   _GSFINAL
	ret

        .area   _HEAP_END
__cpm_sdcc_heap_end::
        .ds     1

;;;;;;;;;;;;;;;;
; eof - cpm0.s ;
;;;;;;;;;;;;;;;;
