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
extern int main ( void );
extern char *grabmem ( unsigned * );
extern int getpathname ( char * );
extern int linetolist ( void );
extern int freepath ( int );
extern int reset ( unsigned, int );
extern int addu ( char *, int, int );
extern int deldrive ( char * );
extern int dio ( void );
extern int chrin ( void );
extern int getch ( void );
extern int flush ( void );
extern int purgeline ( void );
extern int openerror ( int, char *, int );
extern int wrerror ( char * );
extern char *alloc ( int );
extern int allocerror ( char * );
extern int perror ( char * );
extern int kbwait ( unsigned );
extern int readstr ( char *, int );
extern int isin ( char *, char * );
extern int report ( int, char * );
extern int mstrout ( char *, int );

/* ../zmp2.c */
extern int fstat ( char *, struct stat * );
extern unsigned filelength ( struct zfcb * );
extern int roundup ( int, int );
extern int getfirst ( char * );
extern int getnext ( void );
extern int process_flist ( int );
extern int ctr ( char * );
extern int opabort ( void );
extern int readock ( int, int );
extern int readline ( int );
extern int putlabel ( char[] );
extern int killlabel ( void );
extern int mgetchar ( int );
extern int dummylong ( void );
extern int box ( void );
extern int clrbox ( void );
extern int mread ( char *, int, int );
extern int mcharinp ( void );
extern int mcharout ( char );
extern int minprdy ( void );

fstat ( fname, status )
char *fname;
struct stat *status;
{
	unsigned filelength();

	fcbinit ( fname, ( struct fcb * ) &Thefcb );
	status->records = filelength ( &Thefcb );
	getfirst ( fname );
	fcbinit ( "????????.???", ( struct fcb * ) &Thefcb );
}

unsigned
filelength ( fcbp )
struct zfcb *fcbp;
{
	int olduser;

	bdos ( SETDMA, CPMBUF );     /* set dma address */
	olduser = getuid();		/* save this user number */
	setuid ( fcbp->freserved & 0x0f );	/* go to file's user no. */
	bdos ( 35, fcbp );
	setuid ( olduser );		/* restore original */
	return fcbp->ranrec;
}

roundup ( dividend, divisor )
int dividend, divisor;
{
	return ( dividend / divisor + ( ( dividend % divisor ) ? 1 : 0 ) );
}

getfirst ( aname )   /* ambiguous file name */
char *aname;
{
	bdos ( SETDMA, CPMBUF );     /* set dma address */
	fcbinit ( aname, ( struct fcb * ) &Thefcb );
	return bdos ( SFF, ( struct fcb * ) &Thefcb ) & 0xff;
}

getnext()
{
	bdos ( SETDMA, CPMBUF );     /* set dma address */
	return bdos ( SFN, NULL ) & 0xff;
}
/*
memcpy(dest,source,count)
char *dest, *source;
int count;
{
   while (count--)
      *dest++ = *source++;
}

memset(dest,byte,count)
char *dest, byte;
int count;
{
   while (count--)
      *dest++ = byte;
}
*/
/* command: expand wild cards in the command line.  (7/25/83)
 * usage: command(&argc, &argv) modifies argc and argv as necessary
 * uses sbrk to create the new arg list
 * NOTE: requires fcbinit() and bdos() from file stdlib.c.  When used
 *	with a linker and stdlib.rel, remove the #include stdlib.c.
 *
 * Written by Dr. Jim Gillogly; Modified for CP/M by Walt Bilofsky.
 * Modified by HM to just get ambiguous fn for zmodem, ymodem.
 */
/*
int vcount,*loc_vector,in_count,*ext_vector;
char *curfname,*fnptr;
*/
static expand();
int vcount, in_count;
char * curfname;
char ** loc_vector;
char ** ext_vector;
char * fnptr;

int process_flist ( int argcp )
{
	char * p, c;
	char * f_alloc[MAXFILES];

	loc_vector = f_alloc;
	in_count = argcp;
	ext_vector = Pathlist;
	vcount = 0;

	for ( curfname = *ext_vector; in_count--; curfname = * ( ++ext_vector ) ) {

#ifdef   DEBUG
		printf ( "\nDoing %s", curfname );
#endif
		c = 0;

		for ( fnptr = curfname; *fnptr; fnptr++ ) {	/* Need expansion ? */
			if ( *fnptr == '?' || *fnptr == '*' ) {
				c = 1;				/* yes */
			}
		}

		if ( c ) {				/* do expansion */
			if ( !expand() ) {		/* Too many */
				return 0;
			}

			continue; 			/* expand each name at most once */
		}

		loc_vector[vcount] = alloc ( FNSIZE );
		p = curfname;

		while ( c = *p )				/* Convert to lower case */
			*p++ = tolower ( c );

		strcpy ( loc_vector[vcount++], curfname );	/* no expansion */
	}

	argcp = vcount;
	loc_vector[vcount++] = ( char * ) - 1;
	ext_vector = ( char ** ) alloc ( sizeof ( char * ) * vcount );

	while ( vcount-- )
		ext_vector[vcount] = loc_vector[vcount];

	return argcp;
}

static int expand()		/* Returns FALSE if error */
{
	struct fcb cur_fcb;
	static char *p, *q, *r, c;
	static int i, flg, olduser;

#ifdef   DEBUG
	printf ( "\nExpanding %s", curfname );
#endif
	olduser = getuid();			/* save original user area */
	fcbinit ( curfname, &cur_fcb );

	if ( cur_fcb.dr == -1 )
		cur_fcb.dr = '?';		/* Check for all users */

	for ( i = flg = 1; i <= 11; ++i ) {	/* Expand *'s */
		if ( i == 9 )
			flg = 1;

		if ( cur_fcb.name[i - 1] == '*' )
			flg = 0;

		if ( flg == 0 )
			cur_fcb.name[i - 1] = '?';
	}

	/*setuid(cur_fcb[13]);			 go to specified user area */
	setuid ( cur_fcb.uid );			/* go to specified user area */
	flg = CPMFFST;
	bdos ( CPMSDMA, 0x80 );			/* Make sure DMA address OK */

	while ( ( ( i = bdos ( flg, cur_fcb ) ) & 0xff ) != 0xff ) {

		loc_vector[vcount++] = q = alloc ( FNSIZE );

		if ( vcount >= MAXFILES - 1 ) {
			printf ( "Too many file names.\n" );
			setuid ( olduser );
			return FALSE;
		}

		p = ( char * ) ( 0x81 + i * 32 );		/* Where to find dir. record */

		/* transfer du: first */
		if ( ( index ( curfname, ':' ) ) && curfname[0] != '?' ) {
			r = curfname;

			do
				*q++ = c = *r++;

			while ( c != ':' );
		}

		/* Now transfer filename */
		for ( i = 12; --i; ) {
			if ( i == 3 )
				*q++ = '.';

			if ( ( *q = tolower ( *p++ & 0177 ) ) != ' ' )
				++q;
		}

		*q = 0;
		flg = CPMFNXT;
	}

	setuid ( olduser );
	return TRUE;
}

ctr ( p )
char *p;
{
	return max ( ( 80 - strlen ( p ) ) / 2, 0 );
}

opabort()
{
	Lastkey = getch() & 0xff;

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

readock ( timeout, count )
int timeout, count;
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

readline ( n )
int n;
{
	return ( readock ( n, 1 ) );
}

putlabel ( string )
char string[];
{
	cls();
	locate ( 0, ctr ( string ) - 1 );	/* Centre on top line */
	stndout();			/* Inverse video */
	printf ( " %s \n\n", string );	/* Print the string */
	stndend();			/* Inverse off */
}

killlabel() /*disable 25th line*/
{
	cls();			/* just clear screen */
}

mgetchar ( seconds )      /* allows input from modem or operator */
int seconds;
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

#ifdef AZTEC_C
/* Dummy routine to allow long arithmetic in overlays */
dummylong()
{
	long a = 1L;

	a = a * 2L;
}
#endif

box()          /* put box on screen for file transfer */
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
	putchar ( UL );

	for ( i = 1; i < WD - 1; i++ )
		putchar ( HORIZ );

	putchar ( UR );
	LOCATE ( BR, LC );
	putchar ( LL );

	for ( i = 1; i < WD - 1; i++ )
		putchar ( HORIZ );

	putchar ( LR );

	for ( i = 1; i < HT - 1; i++ ) {
		LOCATE ( TR + i, LC );
		putchar ( VERT );
		LOCATE ( TR + i, RC );
		putchar ( VERT );
	}

	clrbox();

	for ( i = 1; i < 11; i++ ) {
		locate ( TR + i, start[i] );
		printf ( headings[i] );
	}
}

clrbox()
{
	register int i;

	for ( i = TR + 1; i < BR; i++ ) {
		locate ( i, LC + 1 );
		printf ( "                                       " );
	}
}

mread ( buffer, count, timeout )	/* time in tenths of secs */
char *buffer;
int count, timeout;
{
	int i, c;

	i = 0;

	while ( ! ( c = mrd() ) && ( timeout-- ) && !opabort() );

	if ( c )
		buffer[i++] = mcharinp();

	return i;
}

mcharinp()
{
	static unsigned c;

	c = mchin();

	if ( Stopped ) {
		mchout ( CTRLQ );
		Stopped = FALSE;
	}

	return c;
}

mcharout ( c )
char c;
{
	while ( !moutrdy() )
		opabort();	/* Test for operator abort while we wait */

	mchout ( c );		/* Then send it */
}

minprdy()
{
	return mirdy() || Stopped;
}

/* 			End of MAIN module 				*/
