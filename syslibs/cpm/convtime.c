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
 *	This routine converts the date and time in CP/M-86 format
 *	to Unix style date and time - seconds since 00:00:00 Jan  1 1970
 */

#define	EPOCH	2922-1		/* difference between 1970 and 1978 - note
				   adjustment since CP/M numbers days from
				   1 and Unix numbers them from 0 */


int frmbcd(uint8_t c)
{
	return (c & 0xF) + ((c >> 4) & 0xF) * 10;
}

time_t convtime(struct tod * tod)
{
	time_t	t;

	t = tod->day+EPOCH;
	t *= 24;				/* now have hours */
	t += frmbcd(tod->hour);			/* add in hours from the time */
	t *= 60;				/* now minutes */
	t += frmbcd(tod->min);			/* add minutes */
	t *= 60;				/* Seconds! */
	t += frmbcd(tod->sec);
	return t;
}
