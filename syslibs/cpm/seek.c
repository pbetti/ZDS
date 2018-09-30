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

long _fsize(uint8_t fd)
{
	register struct fcb *	fc;
	long			tmp;
	uint8_t			luid;

	if(fd >= MAXFILE)
		return -1;
	fc = &_fcb[fd];
	luid = getuid();
	setuid(fc->uid);
	bdos(CPMCFS, (uint8_t)fc);
	setuid(luid);
	tmp = (long)fc->ranrec[0] + ((long)fc->ranrec[1] << 8) + ((long)fc->ranrec[2] << 16);
	tmp *= SECSIZE;
	if(tmp > fc->rwp)
		return tmp;
	return fc->rwp;
}

long lseek(uint8_t fd, long offs, uint8_t whence)
{
	register struct fcb *	fc;
	long			pos;

	if(fd >= MAXFILE)
		return -1;
	fc = &_fcb[fd];
	switch(whence) {

	default:
		pos = offs;
		break;

	case 1:
		pos = fc->rwp + offs;
		break;

	case 2:
		pos = offs + _fsize(fd);
		break;
	}
	if(pos >= 0) {
		fc->rwp = pos;
		return fc->rwp;
	}
	return -1;
}

