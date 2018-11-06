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

void zvset(uint8_t vatr, uint8_t onoff)
{
	if (vatr == zNORMAL) {
		putch(0x11);
	}
	if (vatr & zREVERSE) {
		if (onoff == zON)
			printf("%s", "\x1B\x1B\x0D");
		else
			printf("%s", "\x1B\x1C\x0D");
	}
	if (vatr & zBLINK) {
		if (onoff == zON)
			printf("%s", "\x1B\x02\x0D");
		else
			printf("%s", "\x1B\x01\x0D");
	}
	if (vatr & zUNDERLINE) {
		if (onoff == zON)
			printf("%s", "\x1B\x04\x0D");
		else
			printf("%s", "\x1B\x03\x0D");
	}
	if (vatr & zHIGHLIGHT) {
		if (onoff == zON)
			printf("%s", "\x1B\x06\x0D");
		else
			printf("%s", "\x1B\x05\x0D");
	}
	if (vatr & zRED) {
		if (onoff == zON)
			printf("%s", "\x1B\x0e\x0D");
		else
			printf("%s", "\x1B\x0f\x0D");
	}
	if (vatr & zGREEN) {
		if (onoff == zON)
			printf("%s", "\x1B\x10\x0D");
		else
			printf("%s", "\x1B\x11\x0D");
	}
	if (vatr & zBLU) {
		if (onoff == zON)
			printf("%s", "\x1B\x1d\x0D");
		else
			printf("%s", "\x1B\x1e\x0D");
	}
	if (vatr & zCURSOR) {
		if (onoff == zON)
			putch(0x05);
		else
			putch(0x04);
	}
}

void putchrep(uint8_t c, uint8_t n) __naked
{
	n; c;

	__asm

	.include "darkstar.inc"

	push	iy
	ld	iy,#4
	add	iy,sp

	ld	c, 0 (iy)			; C = fill char
	ld	b, 1 (iy)			; B = times
	ld	a,b
	or	a
	jr	z,putchr1

	call	RPCH

putchr1:
	pop	iy

	ret

	__endasm;
}
