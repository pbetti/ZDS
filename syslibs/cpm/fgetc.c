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
;	 *	fgetc for Zios stdio
;	 */


#define	CPMEOF	032		/* ctrl-Z */

int fgetc(register FILE * f)
{
	int	c;

	if(f->_flag & _IOEOF || !(f->_flag & _IOREAD)) {
reteof:
		f->_flag |= _IOEOF;
		return EOF;
	}
loop:
	if(f->_cnt > 0) {
		c = (unsigned)*f->_ptr++;
		f->_cnt--;
	} else if(f->_flag & _IOSTRG)
		goto reteof;
	else
		c = _filbuf(f);
	if(f->_flag & _IOBINARY)
		return c;
	if(c == '\r')
		goto loop;
	if(c == CPMEOF) {
		f->_cnt++;
		f->_ptr--;
		goto reteof;
	}
	return c;
}

