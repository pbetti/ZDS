/*	Copyright (C) 1981, 1982 by Manx Software Systems */
/*	Copyright (C) 1983 by Manx Software Systems */

printf(fmt,args)
char *fmt; unsigned args;
{
	int putchar();

	format(putchar,fmt,&args);
}

format(putsub, fmt, args)
register int (*putsub)(); register char *fmt; unsigned *args;
{
	register int c;
	char *ps;
	char s[8];
	static char *dconv(), *hexconv();

	while ( c = *fmt++ ) {
		if ( c == '%' ) {
			switch ( c = *fmt++ ) {
			case 'x':
				ps = hexconv(*args++, s+7);
				break;
			case 'u':
				ps = dconv(*args++, s+7);
				break;
			case 'd':
				if ( (int)*args < 0 ) {
					ps = dconv(-*args++, s+7);
					*--ps = '-';
				} else
					ps = dconv(*args++, s+7);
				break;
			case 's':
				ps = *args++;
				break;
			case 'c':
				c = *args++;
			default:
				goto deflt;
			}

			while ( *ps )
				(*putsub)(*ps++);
			
		} else
	deflt:
			(*putsub)(c);
	}
}

static char *
dconv(n, s)
register char *s; register unsigned n;
{
	*s = 0;
	do {
		*--s = n%10 + '0';
	} while ( (n /= 10) != 0 );
	return s;
}

static char *
hexconv(n, s)
register char *s; register unsigned n;
{
	*s = 0;
	do {
		*--s = "0123456789abcdef" [n&15];
	} while ( (n >>= 4) != 0 );
	return s;
}
