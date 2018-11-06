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
 *	freopen.c - stdio freopen
 */

// extern int	open(char *, int), creat(char *, int);

FILE * freopen(char * name, char * mode, register FILE * iob)
{
	uint8_t c;

	fclose(iob);
	c = 0;
	iob->_flag &= _IONBF;
	switch (*mode) {

	case 'w':
		c++;
	case 'a':
		c++;
	case 'r':
		if (mode[1] == 'b')
			iob->_flag = _IOBINARY;
		break;
	}

	switch (c) {

	case 0:
		iob->_file = open(name, U_READ);
		break;

	case 1:
		if ((iob->_file = open(name, U_WRITE)) >= 0)
			break;
		/* else fall through */
	case 2:
		iob->_file = creat(name);
		break;
	}

	if (iob->_file < 0)
		return (FILE *)NULL;

	if (!(iob->_flag & (_IONBF|_IOMYBUF)))
		iob->_base = _bufallo();

	if (iob->_base == (char *)-1) {
		iob->_base = (char *)0;
		close(iob->_file);
		iob->_flag = 0;
		
		return (FILE *)NULL;
	}

	iob->_ptr = iob->_base;
	iob->_cnt = 0;

	if (c)
		iob->_flag |= _IOWRT;
	else
		iob->_flag |= _IOREAD;

	if (iob->_base && c)
		iob->_cnt = BUFSIZ;
	
	if (c == 1)
		fseek(iob, 0L, 2);

	return iob;
}
