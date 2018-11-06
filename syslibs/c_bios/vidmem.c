//
//  '########'########::'######:::'##::: ##'########'########:'#######:::'#####:::
//  ..... ##: ##.... ##'##... ##:: ###:: ## ##.....:..... ##:'##.... ##:'##.. ##::
//  :::: ##:: ##:::: ## ##:::..::: ####: ## ##:::::::::: ##:: ##:::: ##'##:::: ##:
//  ::: ##::: ##:::: ##. ######::: ## ## ## ######::::: ##:::: #######: ##:::: ##:
//  :: ##:::: ##:::: ##:..... ##:: ##. #### ##...::::: ##::::'##.... ## ##:::: ##:
//  : ##::::: ##:::: ##'##::: ##:: ##:. ### ##::::::: ##::::: ##:::: ##. ##:: ##::
//   ######## ########:. ######::: ##::. ## ######## ########. #######::. #####:::
//  ........:........:::......::::..::::..:........:........::.......::::.....::::
//
//  Sysbios C interface library
//  P.Betti  <pbetti@lpconsul.eu>
//
//  Module: c_bios
//
//  HISTORY:
//  -[Date]- -[Who]------------- -[What]---------------------------------------
//  27.09.18 Piergiorgio Betti   Creation date
//

#include <c_bios.h>
#include <cpm.h>


void getvregion(uint16_t * vbuf, uint8_t x, uint8_t y, uint8_t rows, uint8_t cols)
{
	register uint8_t ncols;

	while (rows--) {
		ncols = cols;
		setcrs(x,y);
		while (ncols--) {
			*vbuf = getvchr();
			++vbuf;
		}
		++x;
	}
}

uint16_t getvchr() __naked
{
	__asm

	crtbase		.equ	0x80
	crtram0dat	.equ	crtbase		; RAM0 access PIO0 port A data register
	crtram3port	.equ	crtbase+14	; RAM3 port
	crt6545adst	.equ	crtbase+12	; Address & Status register
	crt6545data	.equ	crtbase+13	; Data register


	00001$:
	in	a,(crt6545adst)
	bit	7,a
	jr	z,00001$

	in	a,(crtram0dat)
	ld	l,a
	in	a,(crtram3port)
	ld	h,a
	xor	a
	out	(crt6545data),a

	ret

	__endasm;

}

void putvregion(uint16_t * vbuf, uint8_t x, uint8_t y, uint8_t rows, uint8_t cols)
{
	register uint8_t ncols;

	while (rows--) {
		ncols = cols;
		setcrs(x,y);
		while (ncols--) {
			putvchr(*vbuf);
			++vbuf;
		}
		++x;
	}
}

void putvchr(uint16_t vch) __naked
{
	vch;

	__asm

	crtbase		.equ	0x80
	crtram0dat	.equ	crtbase		; RAM0 access PIO0 port A data register
	crtram3port	.equ	crtbase+14	; RAM3 port
	crt6545adst	.equ	crtbase+12	; Address & Status register
	crt6545data	.equ	crtbase+13	; Data register

	ld	hl,#2
	add	hl,sp
	ld	c,(hl)
	inc	hl
	ld	b,(hl)


	00001$:
	in	a,(crt6545adst)
	bit	7,a
	jr	z,00001$

	ld	a,c
	out	(crtram0dat),a
	ld	a,b
	out	(crtram3port),a
	xor	a
	out	(crt6545data),a

	ret

	__endasm;

}

void drawbox(uint8_t r, uint8_t c, uint8_t hsize, uint8_t vsize, uint8_t dflag) __naked
{
	r; c; hsize; vsize; dflag;

	__asm

	.include "darkstar.inc"

	push	iy
	ld	iy,#4
	add	iy,sp

	ld	h, 0 (iy)
	ld	l, 1 (iy)			; HL = row,col
	ld	b, 2 (iy)
	ld	c, 3 (iy)			; BC = h,v size
	ld	e, 4 (iy)			; E = s/d

	call	BBDBOX

	pop	iy

	ret

	__endasm;
}

void clrvregion(uint8_t x, uint8_t y, uint8_t rows, uint8_t cols)
{
	uint16_t empty = 0xef00;
	uint8_t ncols;

	while (rows--) {
		ncols = cols;
		setcrs(x,y);
		while (ncols--) {
			putvchr(empty);
		}
		++x;
	}
}

