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
/*
 *	Formatted number printing for Z80 printf and debugger
 */
#define	NDIG	30		/* max number of digits to be printed */
#define	putch(x)	(*pputch)(x)

unsigned char _pnum(unsigned long i, char f, char w, unsigned char s, unsigned char base, void (*pputch)(char))
{
	register char * cp;
	unsigned char fw;
	char buf[NDIG+1];

	if(f > NDIG)
		f = NDIG;

	if(s && (long)i < 0)
		i = -i;
	else
		s = 0;
	if(f == 0 && i == 0)
		f++;

	cp = &buf[NDIG];
	while(i || f > 0) {
		*--cp = "0123456789ABCDEF"[i%base];
		i /= base;
		f--;
	}
	fw = f = (&buf[NDIG] - cp) + s;
	if(fw < w)
		fw = w;
	while(w-- > f)
		putch(' ');
	if(s) {
		putch('-');
		f--;
	}
	while(f--)
		putch(*cp++);
	return fw;
}
