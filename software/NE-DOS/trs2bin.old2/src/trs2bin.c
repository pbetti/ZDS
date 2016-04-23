/***************************************************************************
 *   Copyright (C) 2008 by Piergiorgio Betti   *
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


#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

//
// Simple program to convert trs-dos binary format in plain binary
// Piergiorgio Betti <pbetti@lpconsul.net>
//
// --- 20080121 ---
// Creation date
//

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>

extern FILE * open_file(char * filename, char * mode);
extern void usage(char* me);
extern char * bin_filename(char * nbase, int offset, char * buf);
extern char * map_filename(char * nbase, char * buf);

static char * myname;
static unsigned char block_data_buffer[512];
static char * oname_base, buf[1024];


int main(int argc, char *argv[])
{
	FILE * ifile, * ofile, * mfile;
	unsigned char c;
	int block_count = 0, f_offset = 0;
	int block_address = 0, last_block_address = -1, initial_offset;

	myname = argv[0];

	// some check
	if (argc < 3) {
		usage(argv[0]);
		exit(1);
	}

	oname_base = argv[2];

	ifile = open_file(argv[1], "r");
	mfile = open_file(map_filename(oname_base, buf), "w");

	fprintf(mfile, "%s:\n", argv[0]);
	fprintf(mfile, "Converting [%s] into [%s]\n\n", argv[1], oname_base);

	while (!feof(ifile)) {
		// begin: get first char...
		c = fgetc(ifile);

		if (c == 0x01) {	// load data follows
			block_count = fgetc(ifile);
			++f_offset;
			if (block_count == 0) block_count = 256;
			c = fgetc(ifile);		// LSB
			++f_offset;
			block_address = fgetc(ifile); 	// MSB
			++f_offset;
			block_address = ((block_address <<= 8) & 0xff00) + (c & 0xff);
			block_count -= 2;	// because block_address is part of the byte count
			fread(block_data_buffer, block_count, 1, ifile);
			f_offset += block_count;

			if (last_block_address != block_address) {
				// new block, truncate binary output if any
				initial_offset = block_address;
				last_block_address = block_address + block_count;
				ofile = open_file(bin_filename(oname_base, initial_offset, buf), "w");
			}
			else {
				// contiguous addresses
				last_block_address = block_address + block_count;
				ofile = open_file(bin_filename(oname_base, initial_offset, buf), "a");
			}

			fprintf(mfile, "block type 01 at offset %04X, lenght %d (%02X) bytes in %s, offset=%04X\n",
				block_address, block_count, block_count, buf, f_offset);

			fwrite(block_data_buffer, block_count, 1, ofile);
			if (ferror(ofile)) {
				perror(argv[0]);
				exit(1);
			}

			fclose(ofile);
		}
		else if (c == 0x02) {	// execution address start
			block_count = fgetc(ifile);	// ignored
			++f_offset;
			if (block_count == 0) block_count = 256;
			c = fgetc(ifile);		// LSB
			++f_offset;
			block_address = fgetc(ifile); 	// MSB
			++f_offset;
			block_address = ((block_address <<= 8) & 0xff00) + (c & 0xff);
			block_count -= 2;	// because block_address is part of the byte count
			fprintf(mfile, "block type 02 set address %04X as execution starting point. File offset %04X\n",
				block_address, f_offset);
			break;
		}
		else if (c < 0x20) {	// ignoring block
			block_count = fgetc(ifile);
			++f_offset;
			if (block_count == 0) block_count = 256;

			fread(block_data_buffer, block_count, 1, ifile);
			f_offset += block_count;

			fprintf(mfile, "block type %02d skip %d (%02X) bytes, offset=%04X\n",
				c, block_count, block_count, f_offset);
		}
		else {
			fprintf(mfile, "unblocked/unknown code at offset %04X to EOF.\n",
				f_offset);

			ofile = open_file(bin_filename(oname_base, 0xffff, buf), "w");
			while (!feof(ifile)) {
				c = fgetc(ifile);
				fputc(c, ofile);
			}
			fclose(ofile);
		}
	}

  return EXIT_SUCCESS;
}


char * map_filename(char * nbase, char * buf)
{
	// remove extensions
	char * p = nbase + strlen(nbase);

	while (p > nbase) {
		if (*p == '.') *p = '\0';
		--p;
	}

	strcpy(buf, nbase);
	strcat(buf, ".map");

	return buf;
}

char * bin_filename(char * nbase, int offset, char * buf)
{
	// remove extensions
	char * p = nbase + strlen(nbase);

	while (p > nbase) {
		if (*p == '.') *p = '\0';
		--p;
	}

	sprintf(buf, "%s_offset_%04X.bin", nbase, offset);

	return buf;
}


void usage(char * me)
{
	printf("usage: %s  in_filename out_filename\n", me);
}

FILE * open_file(char * filename, char * mode)
{
	FILE * pfile = fopen(filename, mode);
	if (pfile == 0) {
		perror(myname);
		exit(1);
	}

	return pfile;
}

