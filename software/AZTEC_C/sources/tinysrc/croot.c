/*	Copyright (C) 1981, 1982 by Manx Software Systems */
/*	Copyright (C) 1983 by Manx Software Systems */

#define MAXARGS 30
static char *Argv[MAXARGS];
static char Argbuf[128];
static int Argc;

Croot()
{
	register char *cp;

	movmem((char *)0x81, Argbuf, 127);
	Argbuf[*(char *)0x80 & 0x7f] = 0;
	Argv[0] = "";
	cp = Argbuf;
	Argc = 1;
	while (Argc < MAXARGS) {
		while (*cp == ' ' || *cp == '\t')
			++cp;
		if (*cp == 0)
			break;
		Argv[Argc++] = cp;
		while (*++cp)
			if (*cp == ' ' || *cp == '\t') {
				*cp++ = 0;
				break;
			}
	}
	main(Argc,Argv);
	_exit();
}

exit(code)
{
	_exit();
}

getchar()
{
	register int c;

	if ((c = bdos(1)) == '\r') {
		bdos(2,'\n');
		c = '\n';
	} else if (c == 0x1a)
		c = -1;
	return c;
}

putchar(c)
{
	if (c == '\n')
		bdos(2,'\r');
	bdos(2,c);
	return c&255;
}
