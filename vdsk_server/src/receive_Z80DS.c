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
#include "config.h"

#include "Z80_par_io.h"

extern	void par_io_debug(void);

static byte image[MAX_SIZE];

int main(int argc, char * argv[]) {

	byte * pb, b;
	int count = 0, recv = 0;
	int written = 0;
	int started = 0;
	FILE *rfile;

	if (argc < 2) {
		printf("Usage %s [--partest] file_to_save\n", argv[0]);
		exit(1);
	}

	if (!strcmp(argv[1], "--partest")) {
		par_io_debug();
		exit(0);
	}

	if ((rfile = fopen(argv[1], "w")) == 0) {
		printf("Error opening %s\n", argv[1]);
		exit(1);
	}

	/* give access to requested ports */
	if (init_port())
		exit(1);

	/* gets actual status */
	showstat();

	printf("waiting for ready...\n");
	verbose = 1;

	if ((count = recv_block(image, -1 , 0)) < 0) {
		printf("Error receiving data!!\n");
		exit(1);
	}
	recv = count;

	pb = image;
	while (count--) {
		if (fputc(*pb++, rfile) != EOF) {
			++written;
		}
	}


	printf("\n");
	printf("Received %d (%04X) bytes.\n", recv, recv);
	printf("Written %d (%04X) bytes.\n", written, written);

	exit(0);
}

void par_io_debug()
{
	byte b;

	/* give access to requested ports */
	if (init_port())
		exit(1);
	printf("Port init ok\n");

	makebdir( PAR_INPUT );

	printf("PC handshake pin test.\n");
	printf("Check every status on Z80 (\"I2\" command).\n\n");

	printf("Strobe: 1 Init: 0. Show: xxxxxx00\n");
	setbit( CNTRP, BIT_STRB, 1 );  // 2 0
	setbit( CNTRP, BIT_INIT, 0 );
	printf("Press a key.\n");

	getc(stdin);

	printf("Strobe: 0 Init: 1. Show: xxxxxx11\n");
	setbit( CNTRP, BIT_STRB, 0 );
	setbit( CNTRP, BIT_INIT, 1 );
	printf("Press a key.\n");


	getc(stdin);

	printf("Strobe: 1 Init: 1. Show: xxxxxx10\n");
	setbit( CNTRP, BIT_STRB, 1 );
	setbit( CNTRP, BIT_INIT, 1 );
	printf("Press a key.\n");


	getc(stdin);

	printf("Strobe: 0 Init: 0. Show: xxxxxx01\n");
	setbit( CNTRP, BIT_STRB, 0 );
	setbit( CNTRP, BIT_INIT, 0 );
	printf("Press a key.\n");

	getc(stdin);

	printf("Z80 handshake pin test.\n");
	printf("Set status on Z80 (\"O2,x\" command).\n");
	printf("Where:\n");
	printf("x = 0 -> Status port: 0xBE (10xxxxxx):\n");
	printf("x = 2 -> Status port: 0xFE (11xxxxxx):\n");
	printf("x = 4 -> Status port: 0x3E (00xxxxxx):\n");
	printf("x = 6 -> Status port: 0x7E (01xxxxxx):\n\n");

	printf("Set Z80 & press a key.\n");
	getc(stdin);
	showstat();

	printf("Set Z80 & press a key.\n");
	getc(stdin);
	showstat();

	printf("Set Z80 & press a key.\n");
	getc(stdin);
	showstat();

	printf("Set Z80 & press a key.\n");
	getc(stdin);
	showstat();

	getc(stdin);

	printf("PC data pin test.\n");
	printf("Check every status on Z80 (\"I3\" command).\n\n");

	makebdir( PAR_OUTPUT );

	printf("Data bit: 00000000.\n");
	putbyte( 0x00);
	printf("Press a key.\n");

	getc(stdin);

	printf("Data bit: 11111111.\n");
	putbyte( 0xff );
	printf("Press a key.\n");

	getc(stdin);

	printf("Data bit: 10101010.\n");
	putbyte( 0xaa );
	printf("Press a key.\n");

	getc(stdin);

	printf("Data bit: 01010101.\n");
	putbyte( 0x55 );
	printf("Press a key.\n");

	getc(stdin);

	printf("Z80 data pin test.\n");
	printf("Set status on Z80 (\"O3,xx\" command).\n");
	printf("Where:\n");
	printf("x = 00 -> 00000000:\n");
	printf("x = FF -> 11111111:\n");
	printf("x = AA -> 10101010:\n");
	printf("x = 55 -> 01010101:\n\n");

	makebdir( PAR_INPUT );

	printf("Set Z80 & press a key.\n");
	getc(stdin);
	b = getbyte();
	printf( "0x%X (%s)\n", b, pbyte( b ) );

	printf("Set Z80 & press a key.\n");
	getc(stdin);
	b = getbyte();
	printf( "0x%X (%s)\n", b, pbyte( b ) );

	printf("Set Z80 & press a key.\n");
	getc(stdin);
	b = getbyte();
	printf( "0x%X (%s)\n", b, pbyte( b ) );

	printf("Set Z80 & press a key.\n");
	getc(stdin);
	b = getbyte();
	printf( "0x%X (%s)\n", b, pbyte( b ) );

	exit(0);

}