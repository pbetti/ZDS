/* Copyright (C) 1983, 1984 by Manx Software Systems */
#include "io.h"
#include "errno.h"

execlp(path, args)
char *path, *args;
{
	return execvp(path, &args);
}

execvp(path, argv)
char *path, **argv;
{
	register char *cp, *xp;
	int user, ouser;
	auto struct fcb fcb;
	auto char loader[70];
	extern char ldr_[];

	if ((user = fcbinit(path, &fcb)) == -1) {
		errno = EINVAL;
		return -1;
	}
	if (fcb.f_type[0] == ' ')
		strcpy(fcb.f_type, "COM");
	ouser = bdos(GETUSR, 255);
	bdos(GETUSR, user);
	if (bdos(OPNFIL, &fcb) == 255) {
		errno = ENOENT;
		return -1;
	}
	fcb.f_cr = 0;

	fcbinit(0, 0x5c);
	fcbinit(0, 0x6c);
	cp = (char *)0x81;
	if (*argv) {
		++argv;			/* skip arg0, used for unix (tm) compatibility */
		for (user = 0 ; (xp = *argv++) != 0 ; ++user) {
			if (user == 0)
				fcbinit(xp, 0x5c);
			else if (user == 1)
				fcbinit(xp, 0x6c);
			*cp++ = ' ';
			while (*xp) {
				if (cp > (char *)0xff)
					goto doload;
				*cp++ = *xp++;
			}
		}
	}

doload:
	*(char *)0x80 = cp - (char *)0x81;
	movmem(ldr_, loader, sizeof loader);
	(*(int (*)())loader)(&fcb, ouser);
}

