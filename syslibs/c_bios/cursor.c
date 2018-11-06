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
//  Module: c_bios header
//
//  HISTORY:
//  -[Date]- -[Who]------------- -[What]---------------------------------------
//  27.09.18 Piergiorgio Betti   Creation date
//

#include <c_bios.h>

void setcrs(uint8_t r, uint8_t c)
{
	r; c;
	__asm

	.include "darkstar.inc"

	ld	hl,#2
	add	hl,sp
	ld	d,(hl)
	inc	hl
	ld	e,(hl)
	ex	de,hl		; x,y  on HL

	call	BBSETCRS


	; return value
	ld	hl,#0x00
	__endasm;
}

void getcrs(uint8_t * x, uint8_t * y)
{
	uint16_t rval = _getcrs();
	*y = rval & 0xff;
	*x = (rval >> 8) & 0xff;

	return;
}

uint16_t _getcrs() __naked
{
	__asm

	.include "darkstar.inc"

	; get it
	call	BBGETCRS

	ret
	__endasm;
}

void cls()
{
	__asm

	.include "darkstar.inc"

	ld	c,#0x0c
	call	BBCONOUT
	__endasm;
}
