
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

FILE * inasm, * outasm;


void wline(char * wbuf)
{
	char * p = wbuf;

	while(*p) {
		if (*p == ';' || *p == 0x27 || *p == 0x22)
			break;
		if (isalnum(*p))
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

// 		p = buf;
// 		if (*p != '\t') {
// 			wline(buf);
// 			continue;
// 		}
// 		++p;
// 		if (!isalnum(*p)) {
// 			wline(buf);
// 			continue;
// 		}
// 		if (*p == ';') {
// 			wline(buf);
// 			continue;
// 		}
// 		while (*p != ' ' && *p != '\t' && *p)
// 			++p;
// 		if (*p == '\t') {
// 			wline(buf);
// 			continue;
// 		}
// 		if (*p == ' ') {
// 			*p = '\0';
// 			wline(buf);
// 			wline("\t");
// 			++p;
// 			while (*p == ' ' && *p)
// 				++p;
// 			wline(p);
// 			continue;
// 		}
		wline(buf);
	}

	fclose(inasm);
	fclose(outasm);
	exit(0);
}



