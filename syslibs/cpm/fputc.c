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

extern int _flsbuf(uint8_t, FILE *);
/*
 *	fputc for Zios stdio
 */

int fputc(char c, register FILE * f)
{
	if ((f->_flag & _IOBINARY) == 0 && c == '\n')
		fputc('\r', f);
	if (f->_file == 1) {
		putch(c);		// = stdout. dirty, but faster
		goto stdout_fast;
	}
	if (!(f->_flag & _IOWRT))
		return EOF;
	if (f->_cnt > 0) {
		f->_cnt--;
		*f->_ptr++ = c;
	} else {
		return _flsbuf(c, f);
	}
stdout_fast:
	return c;
}
