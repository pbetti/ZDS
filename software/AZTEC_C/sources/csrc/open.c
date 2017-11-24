/* Copyright (C) 1982 by Manx Software Systems */
#include "errno.h"
#include "fcntl.h"
#include "io.h"

#define MAXFILE	8	/* maximum number of open DISK files */
int bdf_(), ret_(), fileop();
/*
 * note: The ioctl function knows that the condev read/write numbers are
 * 2.  It uses this information to patch the read/write tables.
 */
static struct device condev = { 2, 2, 1, 0, ret_ };
static struct device bdosout= { 0, 3, 0, 0, ret_ };
static struct device bdosin = { 3, 0, 0, 0, ret_ };
static struct device filedev= { 1, 1, 0, 1, fileop };

/*
 * device table, contains names and pointers to device entries
 */
static struct devtabl devtabl[] = {
	{ "con:", &condev, 2 },
	{ "CON:", &condev, 2 },
	{ "lst:", &bdosout, 5 },
	{ "LST:", &bdosout, 5 },
	{ "prn:", &bdosout, 5 },
	{ "PRN:", &bdosout, 5 },
	{ "pun:", &bdosout, 4 },
	{ "PUN:", &bdosout, 4 },
	{ "rdr:", &bdosin, 3 },
	{ "RDR:", &bdosin, 3 },
	{ 0, &filedev, 0 }		/* this must be the last slot in the table! */
};


creat(name, mode)
char *name;
{
	return open(name, O_WRONLY|O_TRUNC|O_CREAT, mode);
}

open(name, flag, mode)
char *name;
{
	register struct devtabl *dp;
	register struct channel *chp;
	register struct device *dev;
	int fd, mdmask;

	for (chp = chantab, fd = 0 ; fd < MAXCHAN ; ++chp, ++fd)
		if (chp->c_close == bdf_)
			goto fndchan;
	errno = EMFILE;
	return -1;

fndchan:
	for (dp = devtabl ; dp->d_name ; ++dp)
		if (strcmp(dp->d_name, name) == 0)
			break;
	dev = dp->d_dev;
	mdmask = (flag&3) + 1;
	if (mdmask&1) {
		if ((chp->c_read = dev->d_read) == 0) {
			errno = EACCES;
			return -1;
		}
	}
	if (mdmask&2) {
		if ((chp->c_write = dev->d_write) == 0) {
			errno = EACCES;
			return -1;
		}
	}
	chp->c_arg = dp->d_arg;
	chp->c_ioctl = dev->d_ioctl;
	chp->c_seek = dev->d_seek;
	chp->c_close = ret_;
	if ((*dev->d_open)(name, flag, mode, chp, dp) < 0) {
		chp->c_close = bdf_;
		return -1;
	}
	return fd;
}

close(fd)
{
	register struct channel *chp;

	if (fd < 0 || fd > MAXCHAN) {
		errno = EBADF;
		return -1;
	}
	chp = &chantab[fd];
	fd = (*chp->c_close)(chp->c_arg);
	chp->c_read = chp->c_write = chp->c_ioctl = chp->c_seek = 0;
	chp->c_close = bdf_;
	return fd;
}

static struct fcbtab fcbtab[MAXFILE];

static
fileop(name,flag,mode,chp,dp)
char *name; struct channel *chp; struct devtabl *dp;
{
	register struct fcbtab *fp;
	int filecl();
	int user;

	for ( fp = fcbtab ; fp < fcbtab+MAXFILE ; ++fp )
		if ( fp->flags == 0 )
			goto havefcb;
	errno = ENFILE;
	return -1;

havefcb:
	if ((user = fcbinit(name,&fp->fcb)) == -1) {
		errno = EINVAL;
		return -1;
	}
	if (user == 255)
		user = getusr();
	setusr(user);
	if (flag & O_TRUNC)
		bdos(DELFIL, &fp->fcb);
	if (bdos(OPNFIL,&fp->fcb) == 0xff) {
		if ((flag&(O_TRUNC|O_CREAT)) == 0 || bdos(MAKFIL,&fp->fcb) == 0xff) {
			errno = ENOENT;
			rstusr();
			return -1;
		}
	} else if ((flag&(O_CREAT|O_EXCL)) == (O_CREAT|O_EXCL)) {
		errno = EEXIST;
		rstusr();
		return -1;
	}
	
	fp->offset = fp->fcb.f_overfl = fp->fcb.f_record = 0;
	fp->user = user;
	chp->c_arg = fp;
	fp->flags = (flag&3)+1;
	chp->c_close = filecl;
	if (flag&O_APPEND)
		_Ceof(fp);
	rstusr();
	return 0;
}

static
filecl(fp)
register struct fcbtab *fp;
{
	_zap();		/* zap work buffer, so data is not reused */
	setusr(fp->user);
	bdos(CLSFIL,&fp->fcb);
	rstusr();
	fp->flags = 0;
	return 0;
}

