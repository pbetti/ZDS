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

int read(uint8_t fd, char * buf, uint16_t nbytes)
{
	register	struct fcb *	fc;
	uint8_t		size, offs, luid;
	uint16_t	cnt;
	char		buffer[SECSIZE+2];

	cnt = 0;
	if(fd >= MAXFILE)
		return -1;

	fc = &_fcb[fd];

	switch(fc->use) {

		case U_RDR:
			cnt = nbytes;
			while(nbytes) {
				nbytes--;
				if((*buf++ = (bdos(CPMRRDR, 0) & 0x7f)) == '\n')
					break;
			}
			return cnt - nbytes;

		case U_CON:
			if(nbytes > SECSIZE)
				nbytes = SECSIZE;
			buffer[0] = nbytes;
			bdos(CPMRCOB, (uint16_t)buffer);
			cnt = (uint8_t)buffer[1];
			if(cnt < nbytes) {
				bdos(CPMWCON, (uint16_t)'\n');
				buffer[cnt+2] = '\n';
				cnt++;
			}
			memmove(buf, &buffer[2], cnt);
			return cnt;

		case U_READ:
		case U_RDWR:
			luid = getuid();
			cnt = nbytes;
			while(nbytes) {
				_sigchk();
				setuid(fc->uid);
				offs = fc->rwp%SECSIZE;
				if((size = SECSIZE - offs) > nbytes)
					size = nbytes;
				_putrno(fc->ranrec, fc->rwp/SECSIZE);
				if(size == SECSIZE) {
					bdos(CPMSDMA, (uint16_t)buf);
					if(bdos(CPMRRAN, (uint16_t)fc))
						break;
				} else {
					bdos(CPMSDMA, (uint16_t)buffer);
					if(bdos(CPMRRAN, (uint16_t)fc))
						break;
					memmove(buf, buffer+offs, size);
				}
				buf += size;
				fc->rwp += size;
				nbytes -= size;
				setuid(luid);
			}
			setuid(luid);
			return cnt - nbytes;

		default:
			return -1;
	}
}
