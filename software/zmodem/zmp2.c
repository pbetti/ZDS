/*			MAIN module File #2				*/

#include "zmp.h"

#ifdef   AZTEC_C
#include "libc.h"
#else
#include <stdio.h>
#endif

#define fcbinit(a,b)	setfcb(b,a)

#include <ctype.h>
#include <string.h>

extern int bios ( int );
extern int index ( char *, char );
extern int max ( int, int );

/* ../zmp.c */
extern char *grabmem ( unsigned * );
extern void reset ( unsigned, int );
extern void addu ( char *, int, int );
extern void deldrive ( char * );
extern int dio ( void );
extern int chrin ( void );
extern int getchi ( void );
extern void flush ( void );
extern void purgeline ( void );
extern int openerror ( int, char *, int );
extern void wrerror ( char * );
extern void * cpm_malloc ( size_t );
extern void cpm_free(void *);
extern int allocerror ( char * );
extern void perror ( char * );
extern int kbwait ( unsigned );
extern int readstr ( char *, int );
extern int isin ( char *, char * );
extern void report ( int, char * );
extern void mstrout ( char *, int );

/* ../zmp2.c */
extern void fstat ( char *, struct stat * );
extern unsigned filelength ( struct zfcb * );
extern int roundup ( int, int );
extern int getfirst ( char * );
extern int getnext ( void );
extern int ctr ( char * );
extern int opabort ( void );
extern int readock ( int, int );
extern int readline ( int );
extern void putlabel ( char * );
extern void killlabel ( void );
extern int mgetchar ( int );
extern int dummylong ( void );
extern void box ( void );
extern void clrbox ( void );
extern int mread ( char *, int, int );
extern int mcharinp ( void );
extern void mcharout ( char );
extern int minprdy ( void );
extern int mrd ( void );
extern int mirdy ( void );
extern int mchin ( void );
extern void putc8 ( unsigned char );


void fstat ( char * fname, struct stat * status )
{
	unsigned filelength();

	fcbinit ( fname, ( struct fcb * ) &Thefcb );
	status->records = filelength ( &Thefcb );
	getfirst ( fname );
	fcbinit ( "????????.???", ( struct fcb * ) &Thefcb );
}

unsigned int filelength ( struct zfcb * fcbp )
{
	int olduser;

	bdos ( SETDMA, CPMBUF );     /* set dma address */
	olduser = getuid();		/* save this user number */
	setuid ( fcbp->freserved & 0x0f );	/* go to file's user no. */
	bdos ( 35, fcbp );
	setuid ( olduser );		/* restore original */
	return fcbp->ranrec;
}

int roundup ( int dividend, int divisor )
{
	return ( dividend / divisor + ( ( dividend % divisor ) ? 1 : 0 ) );
}

int getfirst ( char * aname )   /* ambiguous file name */
{
	bdos ( SETDMA, CPMBUF );     /* set dma address */
	fcbinit ( aname, ( struct fcb * ) &Thefcb );
	return bdos ( SFF, ( struct fcb * ) &Thefcb ) & 0xff;
}

int getnext()
{
	bdos ( SETDMA, CPMBUF );     /* set dma address */
	return bdos ( SFN, NULL ) & 0xff;
}


int ctr ( char * p )
{
	return max ( ( 80 - strlen ( p ) ) / 2, 0 );
}

int opabort()
{
	Lastkey = getchi() & 0xff;

	if ( Lastkey == ESC ) {
		flush();

		if ( !Inhost && !Dialing )
			report ( MESSAGE, "Operator abort" );

		QuitFlag = TRUE;
	}

	return QuitFlag;
}

/*
 * readock(timeout, count) reads character(s) from modem
 *  (1 <= count <= 3)
 * it attempts to read count characters. If it gets more than one,
 * it is an error unless all are CAN
 * (otherwise, only normal response is ACK, CAN, or C)
 *
 * timeout is in tenths of seconds
 */

int readock ( int timeout, int count )
{
	static int c;
	static char byt[5];

	c = mread ( byt, count, timeout );

	if ( c < 1 )
		return TIMEOUT;

	if ( c == 1 )
		return ( byt[0] & 0xff );
	else
		while ( c )
			if ( byt[--c] != CAN )
				return NERROR;

	return CAN;
}

int readline ( int n )
{
	return ( readock ( n, 1 ) );
}

void putlabel ( char * string )
{
	cls();
	locate ( 0, ctr ( string ) - 1 );	/* Centre on top line */
	stndout();			/* Inverse video */
	printf ( " %s \n\n", string );	/* Print the string */
	stndend();			/* Inverse off */
}

void killlabel() /*disable 25th line*/
{
	cls();			/* just clear screen */
}

int mgetchar ( int seconds )      /* allows input from modem or operator */
{
	static int c, tenths;

	Lastkey = 0;
	tenths = seconds * 10;

	if ( ( c = readline ( tenths ) ) != TIMEOUT )
		return ( c & 0xff );
	else if ( Lastkey )
		return Lastkey;

	return TIMEOUT;
}


void box()          /* put box on screen for file transfer */
{
	register int i;
	static char *headings[] = { "", "Protocol:", "File Name:", "File Size:",
				    "Block Check:", "Transfer Time:",
				    "Bytes Transferred:", "Blocks Transferred:",
				    "Sectors in File:", "Error Count:",
				    "Last Message:  NONE"
				  };
	static int start[] = { 0, 13 + LC, 12 + LC, 12 + LC, 10 + LC, 8 + LC, 4 + LC, 3 + LC, 6 + LC,
			       10 + LC, 9 + LC
			     };

	LOCATE ( TR, LC );
	putc8 ( UL );

	for ( i = 1; i < WD - 1; i++ )
		putc8 ( HORIZ );

	putc8 ( UR );
	LOCATE ( BR, LC );
	putc8 ( LL );

	for ( i = 1; i < WD - 1; i++ )
		putc8 ( HORIZ );

	putc8 ( LR );

	for ( i = 1; i < HT - 1; i++ ) {
		LOCATE ( TR + i, LC );
		putc8 ( VERT );
		LOCATE ( TR + i, RC );
		putc8 ( VERT );
	}

	clrbox();

	for ( i = 1; i < 11; i++ ) {
		locate ( TR + i, start[i] );
		printf ( headings[i] );
	}
}

void clrbox()
{
	register int i;

	for ( i = TR + 1; i < BR; i++ ) {
		locate ( i, LC + 1 );
		printf ( "                                       " );
	}
}

int mread ( char * buffer, int count, int timeout )	/* time in tenths of secs */
{
	int i, c;

	i = 0;

	while ( ! ( c = mrd() ) && ( timeout-- ) && !opabort() );

	if ( c )
		buffer[i++] = mcharinp();

	return i;
}

int mcharinp()
{
	static unsigned c;

	c = mchin();

	if ( Stopped ) {
		mchout ( CTRLQ );
		Stopped = FALSE;
	}

	return c;
}

void mcharout ( char c )
{
	/*while ( !moutrdy() )
		opabort();*/	/* Test for operator abort while we wait */
		
	mchout ( c );		/* Then send it */
}

int minprdy()
{
	return mirdy() || Stopped;
}

/* 			End of MAIN module 				*/
