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
//  29.09.18 Piergiorgio Betti   Creation date
//

#include <cpm.h>

uint8_t bdos(uint8_t func8, uint16_t  parm16) __naked {
	func8; parm16;
	__asm
		ld	hl,#2
		add	hl,sp


		ld		c,(hl)	; Load function
		inc		hl
		ld		e,(hl)	; Prepare parameter in E ...
		inc		hl
		ld		d,(hl)  ; And prepare parameter in D
		call	5		; Make BDOS call!

		ld	l,a
		ret
	__endasm;
}


uint16_t bdoshl(uint8_t func8, uint16_t  parm16) __naked {
	func8; parm16;
	__asm
	ld	hl,#2
	add	hl,sp


	ld		c,(hl)	; Load function
	inc		hl
	ld		e,(hl)	; Prepare parameter in E ...
	inc		hl
	ld		d,(hl)  ; And prepare parameter in D
	call	5		; Make BDOS call!

	ret
	__endasm;
}

