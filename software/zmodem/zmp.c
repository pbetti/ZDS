/*************************************************************************/
/*									 */
/*		ZMP - A ZMODEM Program for CP/M				 */
/*									 */
/*	Developed from H. Maney's Heath-specific HMODEM			 */
/*		by Ron Murray and Lindsay Allen				 */
/*									 */
/*************************************************************************/
/*									 */
/* See separate file zmp-hist.doc for details of modification history	 */
/*									 */
/*************************************************************************/
/*                                                                       */
/*  This source code may be distributed freely without restriction       */
/*  for the express purpose of promoting the use of the ZMODEM           */
/*  file transfer protocol.  Programmers are requested to include        */
/*  credit (in the source code) to the developers for any code           */
/*  incorporated from this program.                                      */
/*                                                                       */
/*  This program was inspired by lmodem.c written by David D. Clark      */
/*  in the November 83 issue of Byte.  Although it bears no resemblance  */
/*  to David's program, I can credit him with sparking my interest in    */
/*  modem programs written in C.                                         */
/*                                 - Hal Maney                           */
/*                                                                       */
/*************************************************************************/
/*                                                                       */
/*  The following files comprise ZMP:					 */
/*                                                                       */
/*    zmp.h	        the header file                                  */
/*    zmp.c             the main program Pt.1                            */
/*    zmp2.c            The main program Pt.2				 */
/*    zmterm.c		Terminal overlay				 */
/*    zmterm2.c			"					 */
/*    zmconfig.c        Configuration overlay				 */
/*    zminit.c		Initialisation overlay				 */
/*    zmxfer.c +>>	File transfer overlay (with the next 3)		 */
/*    zmxfer2.c		Chuck Forsberg's sz.c modified for cp/m          */
/*    zmxfer3.c				"				 */
/*    zmxfer4.c         Chuck Forsberg's rz.c modified for cp/m          */
/*    zmxfer5.c				"				 */
/*    zzm.c		Chuck Forsberg's zm.c modified for cp/m          */
/*    zzm2.c				"				 */
/*    zmovl.mac		Sample user-dependent overlay source		 */
/*    zmodem.h          zmodem header file                               */
/*    zmconfig.c        configuration overlay                            */
/*    zconfig.h         configuration overlay header                     */
/*                                                                       */
/*************************************************************************/

#define  MAIN	1

#include "zmp.h"

#ifdef   AZTEC_C
#include "libc.h"
#else
#include <stdio.h>
#endif

#ifdef HI_TECH_C
#include <signal.h>
#endif

#include <ctype.h>
#include <string.h>

extern int bios ( int );

/* ../zmp.c */
extern int main ( void );
extern char *grabmem ( unsigned * );
extern int getpathname ( char * );
extern int linetolist ( void );
extern void freepath ( int );
extern void reset ( unsigned, int );
extern void addu ( char *, int, int );
extern void deldrive ( char * );
extern int dio ( void );
extern int chrin ( void );
extern int getch ( void );
extern void flush ( void );
extern void purgeline ( void );
extern int openerror ( int, char *, int );
extern void wrerror ( char * );
extern char *alloc ( int );
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
extern int process_flist ( int );
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
extern int * getvars( void );
extern char * malloc (int);

extern char * alloc();

/*char ** Pathlist;*/

main()
{
	static int termcmd;
	short *p, i;
	char *q;


	Invokdrive = bdos ( GETCUR, NULL ) + 'A';
	Invokuser = getuid();

	p = (short *)getvars();

	Overdrive = *p++;		/* get du: for overlays etc */
	Overuser = *p++;
	Userover = ( char * ) *p++;	/* user-defined overlay list */

	if ( !Overdrive ) {		/* use Invokdrive if zero */
		Overdrive = Invokdrive;
		Overuser = Invokuser;
	}

	strcpy ( Pathname, Initovly );
	addu ( Pathname, Overdrive, Overuser );
	ovloader ( Pathname, 0 );	/* Do initialisation */

	/************** the main loop ************************/

	for (;;) {
		printf ( "\nWait..." );
		strcpy ( Pathname, Termovly );
		addu ( Pathname, Overdrive, Overuser );
		termcmd = ovloader ( Pathname, 0 );			/* Load the TERM overlay */
		printf ( "\nLoading overlay...\n" );

		switch ( termcmd ) {

			case RECEIVE:
			case SEND:
				strcpy ( Pathname, Xferovly );
				addu ( Pathname, Overdrive, Overuser );
				ovloader ( Pathname, termcmd );
				putchar ( '\007' );			/* tell user it's finished */
				mswait ( 300 );
				putchar ( '\007' );
				break;

#ifdef HOSTON

			case HOST:
				keep ( Lastlog );			/* This will need modifying */
				QuitFlag = FALSE;
				Inhost = TRUE;				/* if host mode is enabled */
	
				while ( !QuitFlag )
					dohost();

				Inhost = FALSE;
				flush();
				cls();
				startcapture();
				break;
#endif

			case CONFIG:
				strcpy ( Pathname, Configovly );
				addu ( Pathname, Overdrive, Overuser );
				ovloader ( Pathname, 0 );
				break;

			case USER:
				for ( i = 0, q = Userover; *q; i++ ) {
					if ( i == Userid ) {			/* if it's the one, */
						strcpy ( Pathname, q );
						addu ( Pathname, Overdrive, Overuser );
						ovloader ( Pathname, 0 );	/* execute it */
						break;
					} else
						while ( *q++ );			/* find the end of this one */
				}

				if ( ! ( *q ) )
					printf ( "Overlay %d not defined.\n", Userid );

				break;

			default:
				printf ( "Fatal error in %s.OVR\n", Termovly );
				exit ( 0 );
				break;
		}	/* end of switch*/
	}	/* end of while */
}	/* end of main */


char * grabmem ( unsigned int * sizep )      		/* grab all available memory */
{
	static char *p, *q;
	static unsigned size;

#ifdef HI_TECH_C
	q = alloc ( BUFSIZ + 10 );			/* Make sure we have enough for disk i/o */
#endif

#ifdef AZTEC_C
	q = alloc ( BUFSIZ );				/* Ditto */
#endif

	size = BUFSTART + 10;				/* allow some overrun */

	while ( ( p = alloc ( size ) ) == ( char * ) MEMORY_FULL ) {
		size -= 1024;

		if ( ( size - 10 ) < 2048 ) {
			size = 0;
			break;
		}
	}

#ifdef DEBUG
	printf ( "\ngrabmem = %x %d\n", p, size );
#endif

	*sizep = size - 10;				/* don't mention the overrun */
	free ( q );					/* Free disk i/o space */
	return p;
}

int getpathname ( char * string )
{
	static char *buffer;

	buffer = Pathname;
	sprintf ( buffer, "\nPlease enter file name%s:  ", string );
	printf ( buffer );

	getline ( Pathname, PATHLEN );

	if ( !strlen ( Pathname ) )
		return 0;

	return linetolist();
}

int linetolist()   					/* expand and put Pathnames in Pathlist, return count */
{
	static char *p;
	static int count;
	static char **tempalloc;

#ifdef DEBUG
	static int i;
#endif

	tempalloc = Pathlist = ( char ** ) alloc ( 510 );

	if ( allocerror ( ( char * ) tempalloc ) )
		return 0;

#ifdef   DEBUG
	printf ( "Pathlist = %x\n", Pathlist );
#endif

	count = 0;
	Pathlist[count++] = Pathname;

	for ( p = Pathname; *p; p++ ) {     		/* break up into substrings */
		if ( *p == ' ' ) {
			*p = '\0';

			while ( *++p == ' ' );		/* dump extra spaces */

			Pathlist[count++] = p;
		}
	}

#ifdef   DEBUG
	printf ( "\nbefore command\n" );

	for ( i = 0; i < count; i++ )
		printf ( "%d %s\n", i, Pathlist[i] );

#endif

	count = process_flist ( count );

#ifdef   DEBUG
	printf ( "\nafter command\n" );

	for ( i = 0; i < count; i++ )
		printf ( "%d %s\n", i, Pathlist[i] );

#endif

	free ( tempalloc );
	return count;
}

void freepath ( int n )
{
	if ( n ) {
		while ( n )
			free ( Pathlist[--n] );

		free ( Pathlist );
	}
}

void reset ( unsigned int drive, int user )
{
	drive = toupper ( drive );

	if ( isalpha ( drive ) && drive <= Maxdrive && user >= 0 && user <= 15 ) {
		Currdrive = drive;
		bdos ( RESET, NULL );
		bdos ( SELDSK, ( Currdrive - 'A' ) & 0xff );
		Curruser = user;
		setuid ( user );
	}
}

void addu ( char * filename, int drive, int user )
{
	/*
	if ( !isin ( filename, ":" ) && user >= 0 && user <= 15 ) {
		strcpy ( Buf, filename );
		filename[0] = ( char ) drive;
		sprintf ( filename + 1, "%d", user );
		sprintf ( ( user < 10 ) ? filename + 2 : filename + 3, ":%s", Buf );
	}
	*/
	return;
}

void deldrive ( char * filename )
{
	char *i, *index();

	if ( ( i = index ( filename, ':' ) ) != ( char * ) NULL )
		strcpy ( filename, i + 1 );
}

int dio()	/* direct console port inp when bdos is too slow */
{
	return bios ( 2 + 1 );
}

int chrin()	/* Direct console input which repeats character */
{
	return bdos ( CONIN );
}

int getch()
{
	return bdos ( DIRCTIO, INPUT );
}

void flush()
{
	while ( bdos ( GCS, NULL ) )   				/*clear type-ahead buffer*/
		bdos ( CONIN, NULL );

	getch();           /*and anything else*/
}

void purgeline()
{
	while ( minprdy() )					/*while there are characters...*/
		mcharinp();					/*gobble them*/
}

int openerror ( int chan, char * fname, int test )
{
	int result;

	if ( result = ( chan == test ) ) {
		printf ( "\n\nERROR - Cannot open %s\n\n", fname );
		wait ( 3 );
	}

	return result;
}

void wrerror ( char * fname )
{
	printf ( "\n\nERROR - Cannot write to %s\n\n", fname );
	wait ( 3 );
}


char * alloc ( int cnt )
{
	return malloc ( cnt );
}

int allocerror ( char * p )
{
	static int status;

	if ( status = ( p == ( char * ) MEMORY_FULL ) )
		perror ( "Memory allocation failure" );

	return status;
}

void perror ( char * string )
{
	printf ( "\007\nERROR - %s\n\n", string );
	wait ( 3 );
}


kbwait ( unsigned int seconds )
{
	static unsigned t;
	static int c;

	t = seconds * 10;

	while ( ! ( c = getch() ) && ( t-- ) )
		MSWAIT ( 100 );

	return ( ( c & 0xff ) == ESC );
}

int readstr ( char * p, int t )
{
	static int c;

	t *= 10;                				/* convert to tenths */
	flush();

	while ( ( ( c = readline ( t ) ) != CR ) && ( c != TIMEOUT ) ) {
		if ( c != LF )
			*p++ = c;
	}

	*p = 0;
	return c;
}

int isin ( char * received, char * expected )
{
	return ( stindex ( received, expected ) != -1 );
}

void report ( int row, char * string )
{
	LOCATE ( row, RPTPOS );
	printf ( string );
}

void mstrout ( char * string, int echo )  		/* echo flag means send to screen also */
{
	static char c;

	while ( c = *string++ ) {
		if ( ( c == RET ) || ( c == '\n' ) ) { 	/* RET is a ! */
			mcharout ( CR );
			mcharout ( LF );
			c = '\n';
		} else if ( c == WAITASEC )
			wait ( 1 );
		else
			mcharout ( c );

		if ( echo )
			putchar ( c );
	}

	MSWAIT ( 100 );   				/* wait 100 ms */
	purgeline();
}

/*			End of MAIN module File 1			*/
