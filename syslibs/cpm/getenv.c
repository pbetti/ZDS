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


#define	ENVFILE	"ENVIRON"

char ** environ;

char * getenv(char * s)
{
	register char **	xp;
	register char *		cp;
	short			i;
	static char		setup;

	if(!setup) {
		FILE *	fp;
		char *	avec[40];
		char	abuf[128];

		i = 0;
		if(fp = fopen(ENVFILE, "r")) {
			while(i < sizeof avec/sizeof avec[0] && fgets(abuf, sizeof abuf, fp)) {
				cp = cpm_malloc(strlen(abuf)+1);
				strcpy(cp, abuf);
				cp[strlen(cp)-1] = 0;
				avec[i++] = cp;
			}
			fclose(fp);
		}
		avec[i] = 0;
		xp = (char **)cpm_malloc(i * sizeof avec[0]);
		memcpy(xp, avec, i * sizeof avec[0]);
		environ = xp;
		setup = 1;
	}
	i = strlen(s);
	for(xp = environ ; *xp ; xp++)
		if(strncmp(*xp, s, i) == 0 && (*xp)[i] == '=')
			return *xp + i+1;
	return (char *)0;
}
