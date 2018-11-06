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

int open(char * name, int mode)
{
	register struct fcb *	fc;
	uint8_t			luid;

	if (mode+1 > U_RDWR)
		mode = U_RDWR;

	if (!(fc = getfcb()))
		return -1;

	if (!setfcb(fc, name)) {
		if(mode == U_READ && bdos(CPMVERS, 0) >= 0x30)
			fc->name[5] |= 0x80;	/* read-only mode */
	
		luid = getuid();
		setuid(fc->uid);
	
		if(bdos(CPMOPN, (uint16_t)fc) != 0) {
			putfcb(fc);
			setuid(luid);
			return -1;
		}

		setuid(luid);
		fc->use = mode;
	}
	
	return fc - _fcb;
}
