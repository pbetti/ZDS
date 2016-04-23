#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>
#include <asm/io.h>
/*#include <sys/io.h>*/

#define ZBYTE	unsigned char
#define ZPORT	unsigned long

extern char * pbyte(ZBYTE);
extern void makebdir(ZBYTE);
extern void showstat(void);
extern void setbit(ZPORT, ZBYTE, ZBYTE);
extern ZBYTE testbit(ZPORT, ZBYTE);
extern int send_byte(ZBYTE);
extern int init_port();

#define BASEP		0x378
#define DATAP		BASEP
#define STATP		BASEP+1
#define CNTRP		BASEP+2
#define NUMPORTS	3
#define TIMEP		0x80

#define BIT_BDIR	0x20		/* I/O parallel port mode */
#define BIT_BUSY	0x80		/* input bit on status port */
#define BIT_ACK		0x40		/* input bit on status port */
#define BIT_STRB	0x01		/* output bit on control port */
#define BIT_INIT	0x04		/* output bit on control port */

int main(int argc, char *argv[]) {
	ZBYTE b;
	int c;
	ZBYTE d1,d2 = 0;
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

	if ((rfile = fopen(argv[1], "r")) == (char *)0) {
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
	makebdir(0);
	setbit(CNTRP, BIT_STRB, 0);
	setbit(CNTRP, BIT_INIT, 0);

	/* Handshake test:
	   1) Reset strobe output
	   2) BIT_BUSY = 1 and BIT_ACK = 0: Z80 ready
	   3) --> send byte and set BIT_STRB
	   4) BIT_BUSY = 1 and BIT_ACK = 1: Z80 aknowledge
	      --> IGNORED
	   5) BIT_BUSY = 0 and BIT_ACK = 1: Z80 got data, go on
	   6) --> start again

	   BIT_INIT = 1: stop send data to Z80
	*/
	if (testbit(STATP, BIT_BUSY) == 1 && testbit(STATP, BIT_ACK) == 0)  {
		printf("WARNING: Z80 ALREADY STARTED\n");
	}


	b = ((origin & 0xff00) >> 8) & 0xff;
	printf ("Start at (%d )0x%02x", origin, b);
	b = origin & 0xff;
	printf ("%02x\n", b);

	b = ((size & 0xff00) >> 8) & 0xff;
	printf ("Size is (%d) 0x%02x", size, b);
	b = size & 0xff;
	printf ("%02x\n", b);

	printf("waiting for start...\n"); fflush(stdout);

	b = ((origin & 0xff00) >> 8) & 0xff;
	send_byte(b);
	b = origin & 0xff;
	send_byte(b);

	b = ((size & 0xff00) >> 8) & 0xff;
	send_byte(b);
	b = size & 0xff;
	send_byte(b);
/*
	for (b = 0; b < 4; b++) {
		c = 0;
		while(c < 0xFF) {
			send_byte(c++);
		}
	}
*/
	while (!feof(rfile)) {
		c = fgetc(rfile);
		if (c == EOF)
			break;
		send_byte((ZBYTE) c);
	}

	printf("\n");

	d1 = testbit(STATP, BIT_BUSY);
	d2 = testbit(STATP, BIT_ACK);
	printf("BIT_BUSY(%d) BIT_ACK(%d)\n", d1, d2);

	setbit(CNTRP, BIT_INIT, 1);
	printf("finished...\n");

}

int send_byte(ZBYTE byte)
{
	//printf("waiting for ready...\n");
	setbit(CNTRP, BIT_STRB, 1);
	while (testbit(STATP, BIT_BUSY) != 1 || testbit(STATP, BIT_ACK) != 0)  {
		;
	}
	//printf("sending data...\n");
	outb(byte, DATAP);
	setbit(CNTRP, BIT_STRB, 0);
	/*
	while (testbit(STATP, BIT_BUSY) != 1 || testbit(STATP, BIT_ACK) != 1)  {
		;
	}
	*/
	while (testbit(STATP, BIT_BUSY) != 0 || testbit(STATP, BIT_ACK) != 1)  {
		;
	}
	//printf("ok! go on...\n");
	printf("."); fflush(stdout);
	return (0);
}

int init_port()
{
	/* give access to requested ports */
	if (ioperm(TIMEP, 1, 1) < 0) {
		printf("Access denied to port 0x%X\n", TIMEP);
		return (1);
	}
	if (ioperm(BASEP, 3, 1) < 0) {
		printf("Access denied to port 0x%X (+3)\n", BASEP);
		return (1);
	}
	return (0);
}

void showstat()
{
	ZBYTE b;

	b = inb(DATAP);
	printf("Data port: 0x%X (%s)\n", b, pbyte(b));
	b = inb(STATP);
	printf("Status port: 0x%X (%s)\n", b, pbyte(b));
	b = inb(CNTRP);
	printf("Control port: 0x%X (%s)\n", b, pbyte(b));
}

char * pbyte(ZBYTE b)
{
	static char mybuf[9];
	ZBYTE a;
	int i = 0;

	for (i = 0; i < 8; i++) {
		a = b;
		b >>= 1;
		a &= 0x01;
		if (a)
			mybuf[7-i] = '1';
		else
			mybuf[7-i] = '0';
	}
	mybuf[9] = '\0';

	return mybuf;
}
	
void makebdir(ZBYTE m)
{
	ZBYTE buf;
	
	if (m) {
		buf = inb(CNTRP);
		buf |= BIT_BDIR;	/* high bit 5 */
		outb(buf, CNTRP);
	}
	else {
		buf = inb(CNTRP);
		buf &= ~BIT_BDIR;	/* low bit 5 */
		outb(buf, CNTRP);
	}
}

void setbit(ZPORT port, ZBYTE bit, ZBYTE s)
{
	ZBYTE b;

	b = inb(port);
	if (s)
		b |= bit;
	else
		b &= ~bit;
	outb(b, port);
}

ZBYTE testbit(ZPORT port, ZBYTE bit)
{
	ZBYTE b, rb;

	b = inb(port);
	rb = ((b & bit) == 0) ? 0 : 1;
	if (bit == BIT_BUSY && port == STATP)
		return(!rb);
	else
		return(rb);
}
