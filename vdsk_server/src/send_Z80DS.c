/***************************************************************************
 *   Copyright (C) 2005 by Piergiorgio Betti   *
 *   pbetti@lpconsul.net   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/
#include <ctype.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>
// #include "config.h"

#include "Z80_par_io.h"


static byte image[MAX_SIZE];

int main(int argc, char *argv[]) {
	byte b, *pb;
	int c;
	FILE *rfile;
	unsigned int size;
	unsigned int origin;
	struct stat finfo;

	if (argc < 2) {
		printf("Usage %s file [origin]\n", argv[0]);
		exit(1);
	}

	if (argc == 3)
		origin = atoi(argv[2]);
	else
		origin = 0x0100;

	if ((rfile = fopen(argv[1], "r")) == (FILE *)0) {
		printf("Error opening %s\n", argv[1]);
		exit(1);
	}

	if (stat(argv[1], &finfo)) {
		printf("Cannot stat %s\n", argv[1]);
		exit(1);
	}

	size = finfo.st_size;

	/* give access to requested ports */
	if (init_port())
		exit(1);

	/* gets actual status */
	showstat();

	/* make output reset handshake */
	makebdir(PAR_OUTPUT);
	setbit(CNTRP, BIT_STRB, 0);
	setbit(CNTRP, BIT_INIT, 0);


	b = ((origin & 0xff00) >> 8) & 0xff;
	printf ("Start at (%d) 0x%02x", origin, b);
	b = origin & 0xff;
	printf ("%02x\n", b);

	b = ((size & 0xff00) >> 8) & 0xff;
	printf ("Size is (%d) 0x%02x", size, b);
	b = size & 0xff;
	printf ("%02x\n", b);

	if (size > MAX_SIZE) {
		printf("Error: Your file is greater than acceptable: %d\n", MAX_SIZE);
		exit(1);
	}

	printf("waiting for start...\n"); fflush(stdout);

	b = ((origin & 0xff00) >> 8) & 0xff;
	send_byte(b);
	b = origin & 0xff;
	send_byte(b);

	b = ((size & 0xff00) >> 8) & 0xff;
	send_byte(b);
	b = size & 0xff;
	send_byte(b);

	pb = image;
	while (!feof(rfile)) {
		c = fgetc(rfile);
		if (c == EOF)
			break;
		*pb++ = (byte)c;
	}

	verbose = 1;

	if (send_block(image, (pb - image))) {
		printf("Error transferring data!!\n\n");
		exit(1);
	}

	printf("\n");

	printf("finished...\n");

	exit(0);
}

