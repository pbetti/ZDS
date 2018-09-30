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

int creat(char * name)
{
	register struct fcb *	fc;
	uint8_t			luid;

	if(!(fc = getfcb()))
		return -1;
	luid = getuid();
	if(!setfcb(fc, name)) {
		unlink(name);
		setuid(fc->uid);
		if(bdos(CPMMAKE, (uint16_t)fc) != 0) {
			setuid(luid);
			fc->use = 0;
			return -1;
		}
		setuid(luid);
		fc->use = U_WRITE;
	}
#if	0
	fc->dm[0] = 0;
	bmove((char *)fc->dm, (char *)&fc->dm[1], sizeof fc->dm - 1);
#endif
	return fc - _fcb;
}
