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

#include <limits.h>
#include <stdarg.h>
#include <cpm.h>

extern int _doprnt(const char *, va_list, FILE *);
extern int cpm_vsnprintf(char *, size_t, const char *, va_list);

int cpm_sprintf(char *s, const char *format, ...)
{
	va_list ap;
	int retval;

	va_start(ap, format);

	retval = cpm_vsnprintf(s, INT_MAX, format, ap);

	va_end(ap);

	return retval;
}

int cpm_snprintf(char *s, size_t n, const char *format, ...)
{
	va_list ap;
	int retval;

	va_start(ap, format);

	retval = cpm_vsnprintf(s, n, format, ap);

	va_end(ap);

	return retval;
}

int cpm_vsnprintf(char *s, size_t n, const char *format, va_list arg)
{
	FILE tmp_stream;

	tmp_stream._flag  = _IOWRT|_IOBINARY|_IOSTRG;
	tmp_stream._base    = (unsigned char *) s;
	tmp_stream._ptr    = (unsigned char *) s;
	tmp_stream._cnt  = n-1;

	_doprnt(format, arg, &tmp_stream);
	tmp_stream._ptr  = 0;

	return tmp_stream._ptr - s;
}

// int cpm_vsprintf(char *s, const char *format, va_list arg)
// {
// 	return cpm_vsnprintf(s, INT_MAX, format, arg);
// }
