/* Copyright (C) 1983, 1984 by Manx Software Systems */
#include "errno.h"

unlink(name)
char *name;
{
	auto char delfcb[40];
	register int user;

	user = fcbinit(name,delfcb);
	setusr(user);
	user = bdos(19,delfcb);
	rstusr();
	if (user == 0xff) {
		errno = ENOENT;
		return -1;
	}
	return 0;
}

