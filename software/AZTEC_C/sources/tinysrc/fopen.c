/*	Copyright (C) 1981, 1982 by Manx Software Systems */
/*	Copyright (C) 1983, 1984 by Manx Software Systems */
#include "stdio.h"
#include "errno.h"

#define MAXFILE 4
#define RBUFSIZ 1024
#define WBUFSIZ 1024
#define RDNSCT	(RBUFSIZ/128)
#define WRNSCT	(WBUFSIZ/128)

#define	OPNFIL	15
#define CLSFIL	16
#define DELFIL	19
#define READSQ	20
#define WRITSQ	21
#define MAKFIL	22
#define SETDMA	26
#define READRN	33
#define WRITRN	34
#define FILSIZ	35
#define SETREC	36

static FILE Cbuffs[MAXFILE];
static char writbuf[WBUFSIZ];
static char readbuf[RBUFSIZ];
static char *bufeof;
static FILE *curread;
static FILE *writfp;

FILE *
fopen(name,mode)
char *name,*mode;
{
	register FILE *fp;
	int user;

	fp = Cbuffs;
	while ( fp->_bp ) {
		if ( ++fp >= Cbuffs+MAXFILE ) {
			errno = ENFILE;
			return (NULL);
		}
	}

	if ((user = fcbinit(name,&fp->_fcb)) == -1) {
		errno = EINVAL;
		return NULL;
	}

	if (user == 255)
		user = getusr();
	fp->user = user;
	setusr(user);
	if (*mode == 'r') {
		if (bdos(OPNFIL,&fp->_fcb) == 0xff) {
			errno = ENOENT;
			rstusr();
			return NULL;
		}
		fp->_bp = readbuf;
		curread = 0;
	} else {
		if ( writfp )
			return NULL;
		bdos(DELFIL, &fp->_fcb);
		if (bdos(MAKFIL,&fp->_fcb) == 0xff) {
			errno = ENOENT;
			rstusr();
			return NULL;
		}
		fp->_bp = writbuf;
		writfp = fp;
	}
	rstusr();
	fp->_fcb.f_overfl = fp->_fcb.f_record = 0;
	return fp;
}

fclose(ptr)
register FILE *ptr;
{
	register int err;

	err = 0;
	if (ptr == writfp) {  /* if writing flush buffer */
		err = flush(ptr->_bp - writbuf);
		writfp = 0;
	} else if (ptr == curread)
		curread = 0;
	setusr(ptr->user);
	if (bdos(CLSFIL,&ptr->_fcb) == 0xff)
		err = -1;
	rstusr();
	ptr->_bp = 0;
	return err;
}

agetc(ptr)
register FILE *ptr;
{
	register int c;

top:
	if ((c = getc(ptr)) != EOF) {
		switch (c &= 127) {
		case 0x1a:
			--ptr->_bp;
			return EOF;
		case '\r':
		case 0:
			goto top;
		}
	}
	return c;
}

getc(ptr)
register FILE *ptr;
{
	register int j;

	if (ptr != curread) {
readit:
		curread = 0;		/* mark nobody as current read */
		setusr(ptr->user);
		if ((j = RDNSCT - blkrd(&ptr->_fcb,readbuf,RDNSCT)) == 0)
			return -1;
		rstusr();
		ptr->_fcb.f_record -= j;
		bufeof = readbuf + j*128;
		curread = ptr;
	}
	if (ptr->_bp >= bufeof) {
		ptr->_fcb.f_record += (bufeof-readbuf) >> 7;
		ptr->_bp = readbuf;
		goto readit;
	}
	return *ptr->_bp++ & 255;
}

aputc(c,ptr)
register int c; register FILE *ptr;
{
	c &= 127;
	if (c == '\n')
		if (putc('\r',ptr) == EOF)
			return EOF;
	return putc(c,ptr);
}

putc(c,ptr)
int c; register FILE *ptr;
{
	*ptr->_bp++ = c;
	if (ptr->_bp >= writbuf+WBUFSIZ) {
		if (flush(WBUFSIZ))
			return EOF;
		ptr->_bp = writbuf;
	}
	return (c&255);
}

flush(len)
register int len;
{
	while (len & 127)
		writbuf[len++] = 0x1a;
	setusr(writfp->user);
	if (len != 0 && blkwr(&writfp->_fcb,writbuf,len>>7) != 0) {
		rstusr();
		return EOF;
	}
	rstusr();
	return 0;
}
