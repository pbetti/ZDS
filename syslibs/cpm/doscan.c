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


#include <ctype.h>
#include <string.h>
#include <stdarg.h>
#include <limits.h>
#include <cpm.h>
/*
 * doscan.c - scan formatted input
 */

#define	NUMLEN		512
#define	NR_CHARS	256

static char	Xtable[NR_CHARS];
static char	inp_buf[NUMLEN];

/*
* (c) copyright 1987 by the Vrije Universiteit, Amsterdam, The Netherlands.
* See the copyright notice in the ACK home directory, in the file "Copyright".
*/

static unsigned long string2long(register const char *nptr, char **endptr,
	    int base, int is_signed);

long int strtol(register const char *nptr, char **endptr, int base)
{
	return (signed long)string2long(nptr, endptr, base, 1);
}

unsigned long int strtoul(register const char *nptr, char **endptr, int base)
{
	return (unsigned long)string2long(nptr, endptr, base, 0);
}

#define between(a, c, z)  ((unsigned) ((c) - (a)) <= (unsigned) ((z) - (a)))

static unsigned long string2long(register char *nptr, char ** endptr,
	    int base, int is_signed)
{
	register unsigned int v;
	register unsigned long val = 0;
	register int c;
	int ovfl = 0, sign = 1;
	char *startnptr = nptr, *nrstart;

	if (endptr) *endptr = (char *)nptr;
	while (isspace(*nptr)) nptr++;
	c = *nptr;

	if (c == '-' || c == '+') {
		if (c == '-') sign = -1;
		nptr++;
	}
	nrstart = nptr;			/* start of the number */

	/* When base is 0, the syntax determines the actual base */
	if (base == 0)
		if (*nptr == '0')
			if (*++nptr == 'x' || *nptr == 'X') {
				base = 16;
				nptr++;
			}
			else	base = 8;
			else	base = 10;
			else if (base==16 && *nptr=='0' && (*++nptr =='x' || *nptr =='X'))
				nptr++;

			for (;;) {
				c = *nptr;
				if (between('0', c, '9')) {
					v = c - '0';
				} else
					if (between('a', c, 'z')) {
						v = c - 'a' + 0xa;
					} else
						if (between('A', c, 'Z')) {
							v = c - 'A' + 0xA;
						} else {
							break;
						}
						if (v >= base) break;
						if (val > (ULONG_MAX - v) / base) ovfl++;
						val = (val * base) + v;
					nptr++;
			}
			if (endptr) {
				if (nrstart == nptr) *endptr = (char *)startnptr;
				else *endptr = (char *)nptr;
			}

			if (!ovfl) {
				/* Overflow is only possible when converting a signed long. */
				if (is_signed
					&& (   (sign < 0 && val > -(unsigned long)LONG_MIN)
					|| (sign > 0 && val > LONG_MAX)))
					ovfl++;
			}

			if (ovfl) {
// 				errno = ERANGE;
				if (is_signed)
					if (sign < 0) return LONG_MIN;
					else return LONG_MAX;
					else return ULONG_MAX;
			}
			return (long) sign * val;
}


/* Collect a number of characters which constitute an ordinal number.
 * When the type is 'i', the base can be 8, 10, or 16, depending on the
 * first 1 or 2 characters. This means that the base must be adjusted
 * according to the format of the number. At the end of the function, base
 * is then set to 0, so strtol() will get the right argument.
 */
static char * o_collect(register int c, register FILE *stream, char type,
			unsigned int width, int *basep)
{
	register char *bufp = inp_buf;
	register int base = 10;

	switch (type) {
	case 'i':	/* i means octal, decimal or hexadecimal */
	case 'p':
	case 'x':
	case 'X':	base = 16;	break;
	case 'd':
	case 'u':	base = 10;	break;
	case 'o':	base = 8;	break;
	case 'b':	base = 2;	break;
	}

	if (c == '-' || c == '+') {
		*bufp++ = c;
		if (--width)
		    c = getc(stream);
	}

	if (width && c == '0' && base == 16) {
		*bufp++ = c;
		if (--width)
			c = getc(stream);
		if (c != 'x' && c != 'X') {
			if (type == 'i') base = 8;
		}
		else if (width) {
			*bufp++ = c;
			if (--width)
				c = getc(stream);
		}
	}
	else if (type == 'i') base = 10;

	while (width) {
		if (((base == 10) && isdigit(c))
		    || ((base == 16) && isxdigit(c))
		    || ((base == 8) && isdigit(c) && (c < '8'))
		    || ((base == 2) && isdigit(c) && (c < '2'))) {
			*bufp++ = c;
			if (--width)
				c = getc(stream);
		}
		else break;
	}

	if (width && c != EOF) ungetc(c, stream);
	if (type == 'i') base = 0;
	*basep = base;
	*bufp = '\0';
	return bufp - 1;
}

#ifdef	USE_FLOAT
/* The function f_collect() reads a string that has the format of a
 * floating-point number. The function returns as soon as a format-error
 * is encountered, leaving the offending character in the input. This means
 * that 1.el leaves the 'l' in the input queue. Since all detection of
 * format errors is done here, _doscan() doesn't call strtod() when it's
 * not necessary, although the use of the width field can cause incomplete
 * numbers to be passed to strtod(). (e.g. 1.3e+)
 */
static char * f_collect(register int c, register FILE *stream, register unsigned int width)
{
	register char *bufp = inp_buf;
	int digit_seen = 0;

	if (c == '-' || c == '+') {
		*bufp++ = c;
		if (--width)
			c = getc(stream);
	}

	while (width && isdigit(c)) {
		digit_seen++;
		*bufp++ = c;
		if (--width)
			c = getc(stream);
	}
	if (width && c == '.') {
		*bufp++ = c;
		if(--width)
			c = getc(stream);
		while (width && isdigit(c)) {
			digit_seen++;
			*bufp++ = c;
			if (--width)
				c = getc(stream);
		}
	}

	if (!digit_seen) {
		if (width && c != EOF) ungetc(c, stream);
		return inp_buf - 1;
	}
	else digit_seen = 0;

	if (width && (c == 'e' || c == 'E')) {
		*bufp++ = c;
		if (--width)
			c = getc(stream);
		if (width && (c == '+' || c == '-')) {
			*bufp++ = c;
			if (--width)
				c = getc(stream);
		}
		while (width && isdigit(c)) {
			digit_seen++;
			*bufp++ = c;
			if (--width)
				c = getc(stream);
		}
		if (!digit_seen) {
			if (width && c != EOF) ungetc(c,stream);
			return inp_buf - 1;
		}
	}

	if (width && c != EOF) ungetc(c, stream);
	*bufp = '\0';
	return bufp - 1;
}
#endif


/*
 * the routine that does the scanning
 */

int _doscan(register FILE *stream, const char *format, va_list ap)
{
	int		done = 0;	/* number of items done */
	int		nrchars = 0;	/* number of characters read */
	int		conv = 0;	/* # of conversions */
	int		base;		/* conversion base */
	unsigned long	val;		/* an integer value */
	register char	*str;		/* temporary pointer */
	char		*tmp_string;	/* ditto */
	unsigned	width = 0;	/* width of field */
	int		flags;		/* some flags */
	int		reverse;	/* reverse the checking in [...] */
	int		kind;
	register int	ic = EOF;	/* the input character */
#ifdef	USE_FLOAT
	long double	ld_val;
#endif

	if (!*format) return 0;

	while (1) {
		if (isspace(*format)) {
			while (isspace(*format))
				format++;	/* skip whitespace */
			ic = getc(stream);
			nrchars++;
			while (isspace (ic)) {
				ic = getc(stream);
				nrchars++;
			}
			if (ic != EOF) ungetc(ic,stream);
			nrchars--;
		}
		if (!*format) break;	/* end of format */

		if (*format != '%') {
			ic = getc(stream);
			nrchars++;
			if (ic != *format++) break;	/* error */
			continue;
		}
		format++;
		if (*format == '%') {
			ic = getc(stream);
			nrchars++;
			if (ic == '%') {
				format++;
				continue;
			}
			else break;
		}
		flags = 0;
		if (*format == '*') {
			format++;
			flags |= FL_NOASSIGN;
		}
		if (isdigit (*format)) {
			flags |= FL_WIDTHSPEC;
			for (width = 0; isdigit (*format);)
				width = width * 10 + *format++ - '0';
		}

		switch (*format) {
		case 'h': flags |= FL_SHORT; format++; break;
		case 'l': flags |= FL_LONG; format++; break;
		case 'L': flags |= FL_LONGDOUBLE; format++; break;
		}
		kind = *format;
		if ((kind != 'c') && (kind != '[') && (kind != 'n')) {
			do {
				ic = getc(stream);
				nrchars++;
			} while (isspace(ic));
			if (ic == EOF) break;		/* outer while */
		} else if (kind != 'n') {		/* %c or %[ */
			ic = getc(stream);
			if (ic == EOF) break;		/* outer while */
			nrchars++;
		}
		switch (kind) {
		default:
			/* not recognized, like %q */
			return conv || (ic != EOF) ? done : EOF;
			break;
		case 'n':
			if (!(flags & FL_NOASSIGN)) {	/* silly, though */
				if (flags & FL_SHORT)
					*va_arg(ap, short *) = (short) nrchars;
				else if (flags & FL_LONG)
					*va_arg(ap, long *) = (long) nrchars;
				else
					*va_arg(ap, int *) = (int) nrchars;
			}
			break;
		case 'p':		/* pointer */
// 			set_pointer(flags);
			/* fallthrough */
		case 'b':		/* binary */
		case 'd':		/* decimal */
		case 'i':		/* general integer */
		case 'o':		/* octal */
		case 'u':		/* unsigned */
		case 'x':		/* hexadecimal */
		case 'X':		/* ditto */
			if (!(flags & FL_WIDTHSPEC) || width > NUMLEN)
				width = NUMLEN;
			if (!width) return done;

			str = o_collect(ic, stream, kind, width, &base);
			if (str < inp_buf
			    || (str == inp_buf
				    && (*str == '-'
					|| *str == '+'))) return done;

			/*
			 * Although the length of the number is str-inp_buf+1
			 * we don't add the 1 since we counted it already
			 */
			nrchars += str - inp_buf;

			if (!(flags & FL_NOASSIGN)) {
				if (kind == 'd' || kind == 'i')
				    val = strtol(inp_buf, &tmp_string, base);
				else
				    val = strtoul(inp_buf, &tmp_string, base);
				if (flags & FL_LONG)
					*va_arg(ap, unsigned long *) = (unsigned long) val;
				else if (flags & FL_SHORT)
					*va_arg(ap, unsigned short *) = (unsigned short) val;
				else
					*va_arg(ap, unsigned *) = (unsigned) val;
			}
			break;
		case 'c':
			if (!(flags & FL_WIDTHSPEC))
				width = 1;
			if (!(flags & FL_NOASSIGN))
				str = va_arg(ap, char *);
			if (!width) return done;

			while (width && ic != EOF) {
				if (!(flags & FL_NOASSIGN))
					*str++ = (char) ic;
				if (--width) {
					ic = getc(stream);
					nrchars++;
				}
			}

			if (width) {
				if (ic != EOF) ungetc(ic,stream);
				nrchars--;
			}
			break;
		case 's':
			if (!(flags & FL_WIDTHSPEC))
				width = 0xffff;
			if (!(flags & FL_NOASSIGN))
				str = va_arg(ap, char *);
			if (!width) return done;

			while (width && ic != EOF && !isspace(ic)) {
				if (!(flags & FL_NOASSIGN))
					*str++ = (char) ic;
				if (--width) {
					ic = getc(stream);
					nrchars++;
				}
			}
			/* terminate the string */
			if (!(flags & FL_NOASSIGN))
				*str = '\0';
			if (width) {
				if (ic != EOF) ungetc(ic,stream);
				nrchars--;
			}
			break;
		case '[':
			if (!(flags & FL_WIDTHSPEC))
				width = 0xffff;
			if (!width) return done;

			if ( *++format == '^' ) {
				reverse = 1;
				format++;
			} else
				reverse = 0;

			for (str = Xtable; str <= &Xtable[NR_CHARS-1]
							; str++)
				*str = 0;

			if (*format == ']') Xtable[*format++] = 1;

			while (*format && *format != ']') {
				Xtable[*format++] = 1;
				if (*format == '-') {
					format++;
					if (*format
					    && *format != ']'
					    && *(format) >= *(format -2)) {
						int c;

						for( c = *(format -2) + 1
						    ; c <= *format ; c++)
							Xtable[c] = 1;
						format++;
					}
					else Xtable['-'] = 1;
				}
			}
			if (!*format) return done;

			if (!(Xtable[ic] ^ reverse)) {
			/* MAT 8/9/96 no match must return character */
				ungetc(ic, stream);
				return done;
			}

			if (!(flags & FL_NOASSIGN))
				str = va_arg(ap, char *);

			do {
				if (!(flags & FL_NOASSIGN))
					*str++ = (char) ic;
				if (--width) {
					ic = getc(stream);
					nrchars++;
				}
			} while (width && ic != EOF && (Xtable[ic] ^ reverse));

			if (width) {
				if (ic != EOF) ungetc(ic, stream);
				nrchars--;
			}
			if (!(flags & FL_NOASSIGN)) {	/* terminate string */
				*str = '\0';
			}
			break;
#ifdef	USE_FLOAT
		case 'e':
		case 'E':
		case 'f':
		case 'g':
		case 'G':
			if (!(flags & FL_WIDTHSPEC) || width > NUMLEN)
				width = NUMLEN;

			if (!width) return done;
			str = f_collect(ic, stream, width);

			if (str < inp_buf
			    || (str == inp_buf
				&& (*str == '-'
				    || *str == '+'))) return done;

			/*
			 * Although the length of the number is str-inp_buf+1
			 * we don't add the 1 since we counted it already
			 */
			nrchars += str - inp_buf;

			if (!(flags & FL_NOASSIGN)) {
				ld_val = strtod(inp_buf, &tmp_string);
				if (flags & FL_LONGDOUBLE)
					*va_arg(ap, long double *) = (long double) ld_val;
				else
				    if (flags & FL_LONG)
					*va_arg(ap, double *) = (double) ld_val;
				else
					*va_arg(ap, float *) = (float) ld_val;
			}
			break;
#endif
		}		/* end switch */
		conv++;
		if (!(flags & FL_NOASSIGN) && kind != 'n') done++;
		format++;
	}
	return conv || (ic != EOF) ? done : EOF;
}

