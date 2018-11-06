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

static	HDGEO geometry;

int getHDgeo(HDGEO * geometry) __naked
{
	geometry;

	__asm

	.include "darkstar.inc"

	; buffer address in DE
	pop	bc
	pop	de
	push	de
	push	bc
	;
	push	ix
	; get data
	call	BBHDGEO
	push	hl
	pop	bc			; sectors in BC
	;
	ex	de,hl			; buf addr now in HL
	push	ix
	pop	de
	ld	(hl),e
	inc	hl
	ld	(hl),d
	inc	hl
	;
	push	iy
	pop	de
	ld	(hl),e
	inc	hl
	;
	push	bc
	pop	de
	ld	(hl),e

	pop	ix
	; return value
	ld	hl,#0x0000

	ret
	__endasm;


}

int hdRead(uint8_t * buf, uint16_t track, uint16_t sector) __naked
{
	buf; track; sector;

	__asm

	.include "darkstar.inc"

	;
	; Read HD sector
	;
	ld	hl,#2
	add	hl,sp
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	; set DMA address (from BC)
	call	BBDMASET

	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	; set track #
	call	BBTRKSET

	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	; 	inc	hl
	; set sect #
	call	BBSECSET

	; now read it
	call	BBHDRD
	ld	l,a

	; return value
	ld	h,#0x00

	ret

	__endasm;

}

int hdWrite(uint8_t * buf, uint16_t track, uint16_t sector) __naked
{
	buf; track; sector;

	__asm

	.include "darkstar.inc"

	;
	; Write HD sector
	;
	_hdWrite_::
	ld	hl,#2
	add	hl,sp
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	; set DMA address (from BC)
	call	BBDMASET

	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	; set track #
	call	BBTRKSET

	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	; 	inc	hl
	; set sect #
	call	BBSECSET

	; now read it
	call	BBHDWR
	ld	l,a

	; return value
	ld	h,#0x00

	ret

	__endasm;

}

void unlockHDAccess()
{
	unsigned char * tmpbyte = (unsigned char *)TMPBYTE;

	*tmpbyte |= 1 << 7;
}

void lockHDAccess()
{
	unsigned char * tmpbyte = (unsigned char *)TMPBYTE;

	*tmpbyte &= ~(1 << 7);
}

