;--------------------------------------------------------------------------
; crt0.s replacement for Z80 Darkstar (NEZ80)
; by Piergiorgio Betti <pbetti@lpconsul.net>
; 20140824
;--------------------------------------------------------------------------

.include "darkstar.inc"

	.module crt0
	.globl  _main
	.globl	l__INITIALIZER
	.globl	s__INITIALIZED
	.globl	s__INITIALIZER

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

			; Fundamental routines for console i/o on sdcc
_putchar::
_putchar_rr_s::
	ld	hl,#2
	add	hl,sp

	ld	c,(hl)
	ld	a,c
	cp	#0x0a
	jr	nz,_putchar_00
	ld	c,#0x0d
	call	BBCONOUT
	ld	c,#0x0a
_putchar_00:
	call	BBCONOUT
	ret

_putchar_rr_dbs::

	ld	c,e
	call	BBCONOUT
	ret

_getchar::
	call	BBCONIN
	ld	l,a
	ret

__clock::
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

;;;;;;;;;;;;;;;;
; eof - zds0.s ;
;;;;;;;;;;;;;;;;
