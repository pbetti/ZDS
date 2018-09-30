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

static short	pushback;

char getch()
{
	short	c;

	if (c = pushback) {
		pushback = 0;
		return c;
	}
	while (!(c = bdos(0x06, 0xFF)))
		continue;
	return c;
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
