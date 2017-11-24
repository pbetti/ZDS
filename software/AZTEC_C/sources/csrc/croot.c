/* Copyright (C) 1981,1982,1984 by Manx Software Systems */
#include "errno.h"
#include "fcntl.h"
#include "io.h"

int bdf_(), ret_();

/*
 * channel table: relates fd's to devices
 */
struct channel chantab[] = {
	{ 2, 0, 1, 0, ret_, 2 },
	{ 0, 2, 1, 0, ret_, 2 },
	{ 0, 2, 1, 0, ret_, 2 },
	{ 0, 0, 0, 0, bdf_, 0 },
	{ 0, 0, 0, 0, bdf_, 0 },
	{ 0, 0, 0, 0, bdf_, 0 },
	{ 0, 0, 0, 0, bdf_, 0 },
	{ 0, 0, 0, 0, bdf_, 0 },
	{ 0, 0, 0, 0, bdf_, 0 },
	{ 0, 0, 0, 0, bdf_, 0 },
	{ 0, 0, 0, 0, bdf_, 0 },
};

#define MAXARGS 30
static char *Argv[MAXARGS];
static char Argbuf[128];
static int Argc;
int (*cls_)() = ret_;

Croot()
{
	register char *cp, *fname;
	register int k;

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
#ifndef NOREDIR
		if (*cp == '>') {		/* redirect output */
			k = 1;
			goto redirect;
		} else if (*cp == '<') {	/* redirect input */
			k = 0;
redirect:
			while (*++cp == ' ' || *cp == '\t')
				;
			fname = cp;
			while (*++cp)
				if (*cp == ' ' || *cp == '\t') {
					*cp++ = 0;
					break;
				}
			close(k);
			if (k)
				k = creat(fname, 0666);
			else
				k = open(fname, O_RDONLY);
			if (k == -1) {
				strcpy(0x80, "Can't open file for redirection: ");
				strcat(0x80, fname);
				strcat(0x80, "$");
				bdos(9,0x80);
				exit(10);
			}
		} else
#endif
		{
			Argv[Argc++] = cp;
			while (*++cp)
				if (*cp == ' ' || *cp == '\t') {
					*cp++ = 0;
					break;
				}
		}
	}
	main(Argc,Argv);
	exit(0);
}

exit(code)
{
	register int fd;

	(*cls_)();
	for (fd = 0 ; fd < MAXCHAN ; )
		close(fd++);
	if (code && (bdos(24)&1) != 0)
		unlink("A:$$$.SUB");
	_exit();
}

bdf_()
{
	errno = EBADF;
	return -1;
}

ret_()
{
	return 0;
}

