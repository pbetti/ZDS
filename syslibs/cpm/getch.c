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

#include <cpm.h>

static	short	pushback;
static	char keydecode(short);

char getch()
{
	short	c;

	if (c = pushback) {
		pushback = 0;
		return c;
	}
	while (!(c = bdos(0x06, 0xFF)))
		continue;
	return keydecode(c);
}

char keydecode(short c1)
{
	short	c2;

	delay(2);	// wait 2 ms to check user ESCaped
	c2 = bdos(0x06, 0xFF);
	if (!c2) {			// single stroke
		if (c1 == 0x07) return K_DEL;
		if (c1 == 0x16) return K_INS;
		if (c1 == 0x12) return K_PGUP;
		if (c1 == 0x03) return K_PGDN;
		if (c1 == 0x05) return K_UP;
		if (c1 == 0x18) return K_DOWN;
		if (c1 == 0x13) return K_LEFT;
		if (c1 == 0x04) return K_RIGHT;
		return c1;
	}
	if (c2 && c1 == 0x1b) {		// double stroke
		if (c2 == 'A') return K_F1;
		if (c2 == 'B') return K_F2;
		if (c2 == 'C') return K_F3;
		if (c2 == 'D') return K_F4;
		if (c2 == 'E') return K_F5;
		if (c2 == 'F') return K_F6;
		if (c2 == 'G') return K_F7;
		if (c2 == 'H') return K_F8;
		if (c2 == 'I') return K_F9;
		if (c2 == 'J') return K_F10;
		if (c2 == 'K') return K_F11;
		if (c2 == 'L') return K_F12;
	}
	if (c2 && c1 == 0x11) {		// double stroke
		if (c2 == 'S') return K_HOME;
		if (c2 == 'D') return K_END;
	}
	return c1;
}


char getche()
{
	short	c;

	if (c = pushback) {
		pushback = 0;
		return c;
	}
	return bdos(0x01, 0) & 0xFF;
}

void ungetch(char c)
{
	pushback = c;
}

void putch(char c)
{
	if(c == '\n')
		bdos(0x02, (uint16_t)'\r');
	bdos(0x02, c);
}

int kbhit()
{
	return (bdos(0x0B, 0) & 0xFF) != 0;
}
