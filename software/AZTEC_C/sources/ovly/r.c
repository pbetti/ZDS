/* Copyright (C) 1984 by Manx Software Systems */
#include <stdio.h>

main(argc, argv)
char **argv;
{
	register int (*func)();
	int (*prgload())();

	if (argc < 2) {
		fprintf(stderr, "usage: r progname args ...\n");
		exit(4);
	}
	++argv;
	if ((func = prgload(*argv)) == 0) {
		fprintf(stderr, "Cannot load program\n");
		exit(4);
	}
	(*func)(argc-1, argv);
}

#define OVMAGIC	0xf1

struct header {
	int magic;
	unsigned ovaddr;
	unsigned ovsize;
	unsigned ovbss;
	int (*ovbgn)();
};

static int (*prgload(argv0))()
char *argv0;
{
	int fd;
	char *topmem, *ovend, *sbrk();
	unsigned size;
	struct header header;
	char name[20];
	
	strcpy(name, argv0);
	strcat(name, ".ovr");
	if ((fd = open(name, 0)) < 0)
		return 0;
	if (read(fd, &header, sizeof header) < 0)
		return 0;
	/* check magic number on overlay file */
	if (header.magic != OVMAGIC || header.ovsize == 0)
		return 0;

	topmem = sbrk(0);
	ovend = header.ovaddr + header.ovsize + header.ovbss;
	if (topmem < ovend) {
		if (sbrk(ovend - topmem) == (char *)-1)
			return 0;
	}
	if (read(fd, header.ovaddr, header.ovsize) < header.ovsize)
		return 0;
	close(fd);
	return header.ovbgn;
}
