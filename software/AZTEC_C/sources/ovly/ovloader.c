/* Copyright (C) 1983, 1984 by Manx Software Systems */

#define OVMAGIC	0xf1

struct header {
	int magic;
	unsigned ovaddr;
	unsigned ovsize;
	unsigned ovbss;
	int (*ovbgn)();
};

static char *ovname;

#asm
	public	ovloader
ovloader:
	lxi	h,2
	dad	sp
	mov	e,m
	inx	h
	mov	d,m
	xchg
	shld	ovname_
;
	call	_ovld_
	pchl
#endasm

static
_ovld()
{
	int fd, flag;
	auto struct header hdr;
	extern char *_mbot;
	auto char filename[64];
	
	flag = 0;
	strcpy(filename, ovname);
	for (;;) {
		strcat(filename, ".ovr");
		if ((fd = open(filename, 0)) >= 0)
			break;
		if (flag++)
			loadabort(10);
		strcpy(filename, "a:");
		strcat(filename, ovname);
	}

	if (read(fd, &hdr, sizeof hdr) != sizeof hdr)
		loadabort(20);

	/* check magic number on overlay file */
	if (hdr.magic != OVMAGIC)
		loadabort(30);

	if (_mbot < hdr.ovaddr+hdr.ovsize+hdr.ovbss)
		loadabort(40);

	if (read(fd, hdr.ovaddr, hdr.ovsize) < hdr.ovsize)
		loadabort(50);
	close(fd);
	return hdr.ovbgn;
}

static
loadabort(code)
{
	char buffer[80];

	sprintf(buffer, "Error %d loading overlay: %s$", code, ovname);
	bdos(9, buffer);
	exit(10);
}
