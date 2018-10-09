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

#include <stdlib.h>
#include <cpm.h>

static union stdbuf
{
	char		bufarea[BUFSIZ];
	union stdbuf *	link;
} *	freep;

char * _bufallo()
{
	register union stdbuf *	pp;

	if(pp = freep)
		freep = pp->link;
	else
		pp = (union stdbuf *)malloc(BUFSIZ);
	return pp->bufarea;
}

void _buffree(char * pp)
{
	register union stdbuf * up;

	up = (union stdbuf *)pp;
	up->link = freep;
	freep = up;
}
