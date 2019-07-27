
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

FILE * inasm, * outasm;


void wline(char * wbuf)
{
	char * p = wbuf;
	int susp27 = 0;
	int susp22 = 0;
	int susp = 0;

	while(*p) {
// 		if (*p == ';')
// 			break;
		if (*p == 0x27)
			susp27 = !susp27;
		if (*p == 0x22)
			susp22 = !susp22;
		if (susp22 || susp27)
			susp = 1;
		else
			susp = 0;
		if (isalnum(*p))
			if (!susp)
				*p = tolower(*p);
		++p;
	}

	if (fputs(wbuf, outasm) == EOF) {
		printf("Error writing output file\n");
		exit(1);
	}
}

main(int argc, char **argv)
{
	char buf[2048];
	char *p;

	if (argc < 3) {
		printf("Usage: %s  in-filename out-filename\n", argv[0]);
		exit(1);
	}

	if ((inasm = fopen(argv[1], "r")) == NULL) {
		printf("Error opening %s\n", argv[1]);
		exit(1);
	}

	if ((outasm = fopen(argv[2], "w")) == NULL) {
		printf("Error opening %s\n", argv[2]);
		exit(1);
	}

	while (!feof(inasm)) {
		fgets(buf, 2048, inasm);

		wline(buf);
	}

	fclose(inasm);
	fclose(outasm);
	exit(0);
}



