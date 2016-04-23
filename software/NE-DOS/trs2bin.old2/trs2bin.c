//
// Simple program to convert trs-dos binary format in plain binary
// Piergiorgio Betti <pbetti@lpconsul.net>
//
// --- 20080121 ---
// Creation date
//

#include <stdio.h>
#include <errno.h>


main(int argc, char **argv)
{
	FILE * ifile, * ofile;
	char * myname = argv[0];
	char c;
	unsigned char block_count = 0;
	int block_address = 0;
	unsigned char block_data_buffer[512];
	
	// some check
	if (argc < 3) {
		usage(myname);
		exit(1);
	}

	ifile = open_file(argv[1], "r");
	ofile = open_file(argv[2], "w");

	// begin: get first char...
	c = fgetc(ifile);
	
	if (c == 0x01) {	// load data follows
		block_count = fgetc(ifile);
		if (block_count == 0) block_count = 256;
		c = fgetc(ifile);		// LSB
		block_address = fgetc(ifile); 	// MSB
		block_address = ((block_address <<= 8) & 0xf0) + (c & 0x0f);
		fread(block_data_buffer, block_count - 2, 1, ifile);
	}
	else if (c == 0x02) {	// execution address start

	}
	else if (c < 0x20) {	// ignoring block
	}
}


void usage(char * myname)
{
	printf("usage: %s  in_filename out_filename\n");
}

FILE * open_file(char * filename, char * mode)
{
	FILE * pfile = fopen(filename, mode);
	if (pfile == 0) {
		fprintf(stderr, "Error %s opening '%s'.\n", perror(myname), filename);
		exit(1);
	}

	return pfile;
}