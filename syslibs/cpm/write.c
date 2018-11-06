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

int write(uint8_t fd, char * buf, uint16_t nbytes)
{
	register struct fcb *	fc;
	uint8_t size, offs, luid;
	short c;
	uint16_t count;
	char buffer[SECSIZE];

	if (fd >= MAXFILE)
		return -1;
	fc = &_fcb[fd];
	offs = CPMWCON;
	count = nbytes;
	switch (fc->use) {

		case U_PUN:
			while (nbytes--) {
				_sigchk();
				bdos(CPMWPUN, *buf++);
			}
			return count;

		case U_LST:
			offs = CPMWLST;
		case U_CON:
			while (nbytes--) {
				_sigchk();
				c = *buf++;
				bdos(offs, c);
			}
			return count;

		case U_WRITE:
		case U_RDWR:
			luid = getuid();
			while (nbytes) {
				_sigchk();
				setuid(fc->uid);
				offs = fc->rwp%SECSIZE;
				if ((size = SECSIZE - offs) > nbytes)
					size = nbytes;
				_putrno(fc->ranrec, fc->rwp/SECSIZE);
				if (size == SECSIZE) {
					bdos(CPMSDMA, (uint16_t)buf);
				} else {
					bdos(CPMSDMA, (uint16_t)buffer);
					buffer[0] = CPMETX;
					memmove(buffer+1, buffer, SECSIZE-1);
					bdos(CPMRRAN, (uint16_t)fc);
					memmove(buffer+offs, buf, size);
				}
				if (bdos(CPMWRAN, (uint16_t)fc))
					break;
				buf += size;
				fc->rwp += size;
				nbytes -= size;
				setuid(luid);
			}
			setuid(luid);
			return count-nbytes;

		default:
			return -1;
	}
}
