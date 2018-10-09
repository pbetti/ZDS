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
//  29.09.18 Piergiorgio Betti   Creation date
//

#include <cpm.h>


#define	setuid(x)	bdos(CPMSUID, x)
#define	getuid()	bdos(CPMSUID, 0xFF)
#define	TPA		0x100
#define	DBUF		0x80
#define	DFCB		0x5C

static void doexec(register struct fcb *fc, uint8_t luid)
{
	char * dma;

	dma = (char *)TPA;
	do {
		bdos(CPMSDMA, (uint16_t)dma);
		dma += SECSIZE;
	} while(bdos(CPMREAD, (uint16_t)fc) == 0);
	setuid(luid);
	bdos(CPMSDMA, (uint16_t)DBUF);
	(*(void (*)())TPA)();
}


// int execl(char * name, char * arg1)
// {
// 	return execv(name, &arg1);
// }
//
// int execv(char * name, char ** arg)
// {
// 	struct fcb	fc;
// 	uchar		luid;
// 	short		i, j;
// 	register char *	cp;
// 	char		progbuf[128];	/* storage for the code */
//
// 	for(i = 1, j = 0 ; arg[i] ; i++)
// 		j += strlen(arg[i])+1;
// 	if(j >= 126)
// 		return -1;		/* arg list too big */
// 	if(i > 1)
// 		setfcb(DFCB, arg[1]);
// 	else
// 		setfcb(DFCB, "");
// 	cp = (char *)DBUF;
// 	*cp++ = j;
// 	*cp = 0;
// 	for(i = 0 ; arg[i] ; i++) {
// 		strcat(cp, " ");
// 		strcat(cp, arg[i]);
// 	}
// 	setfcb(&fc, name);
// 	if(fc.ft[0] != ' ')
// 		return -1;
// 	strncpy(fc.ft, "COM", 3);
// 	luid = getuid();
// 	setuid(fc.uid);
// 	if(bdos(CPMOPN, &fc) == -1) {
// 		setuid(luid);
// 		return -1;
// 	}
// 	memmove(progbuf, doexec, sizeof progbuf);
// 	(*(void (*)())progbuf)(&fc, luid);
// }
