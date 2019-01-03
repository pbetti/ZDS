/*			TERM module File 3				*/

#include "zmp.h"

#ifdef   AZTEC_C
#include "libc.h"
#else
#include <stdio.h>
#endif

#include <string.h>
#include <ctype.h>

/* ../zmterm2.c */
extern int keydisp(void);
extern void keep(char *, short);
extern int startcapture(void);
extern int docmd(void);
extern int capturetog(char *);
extern int comlabel(void);
extern int scplabel(void);
extern int diskstuff(void);
extern int possdirectory(char *);
extern int help(void);
extern void viewfile(char *);
extern void printfile(char *);

/* ../zmterm3.c */
extern void directory(void);
extern void sorted_dir(char *, unsigned);
extern void unsort_dir(void);
extern int printsep(short);
extern int domore(void);
extern int dirsort(char *, char *);
extern int cntbits(char);
extern void resetace(void);
extern void updateace(void);
extern void hangup(void);
extern void tlabel(void);
extern int waitakey(void);

/* ../zmterm.c */
extern int ovmain(void);
extern void prtchr(char);
extern void tobuffer(int);
extern void prompt(short);
extern void doexit(void);
extern void setace(int);

extern int getfirst(char *);
extern int getnext ( void );
extern int dio ( void );
extern int dirsort ( char * , char *  );
extern void cpm_free(void *);
extern char *grabmem ( unsigned * );


static short Lines, Entries;

void directory()
{
	short factor, cpm3;
	long *lp = ( long * ) CPMBUF;
	unsigned i, dtotal, atotal, allen, remaining, bls, dirbufsize;
	char * alloca, * p, * dirbuf;
	struct dpb * thedpb;

	cls();
	sprintf ( Buf, "Directory for Drive %c%d:", Currdrive, Curruser );
	putlabel ( Buf );
	bdos ( SETDMA, CPMBUF );     					/* set dma address */
	cpm3 = ( bdoshl ( 12 ) >= 0x30 );				/* get cp/m version (BCD) */
	dirbuf = grabmem ( &dirbufsize );
	
	if ( dirbuf != ( char * ) MEMORY_FULL ) 
		sorted_dir ( dirbuf, dirbufsize );
	else								/* not enough room */
		unsort_dir();						/* do unsorted directory */
	
	/* Now print free space on disk */
	if ( cpm3 ) {							/* cp/m 3 */
		bdos ( 46, Currdrive - 'A' );
		p = ( char * ) ( CPMBUF + 3 );
		*p = 0;							/* clear hi byte for long */
		remaining = ( short ) ( *lp / 8L );
	} else {							/* cp/m 2.2 */
		thedpb = ( struct dpb * ) bdoshl ( GETDPB, NULL ); 	/* fill dpb */
		alloca = ( char * ) bdoshl ( GETALL, NULL );
		bls = 0x0001;
		bls <<= thedpb->bsh + 7;
		factor = bls / 1024;
		dtotal = factor * ( thedpb->dsm + 1 );
		allen = ( thedpb->dsm / 8 ) + 1;

		for ( atotal = i = 0; i < allen; i++ )
			atotal += cntbits ( * ( alloca + i ) );

		atotal *= factor;
		remaining = dtotal - atotal;
	}

	if ( Lines >= DIRLINES - 1 )
		domore();

	if ( Entries )
		printf ( "\n\t%d", Entries );
	else
		printf ( "\n\tNo" );

	printf ( " File(s).\t\t" );
	printf ( "Space remaining on %c:  %dk\n", Currdrive, remaining );
}

/* Do sorted directory with filesizes */
void sorted_dir ( char * dirbuf, unsigned int dirbufsize )
{
	short count, limit, dircode, ksize, i;
	unsigned size;
	char filename[15];
	char *p, *q;
	struct sortentry *se;
	
	q = dirbuf;
	Lines = 2;
		
	limit = dirbufsize / sizeof ( struct sortentry ); 		/* how many */

	dircode = getfirst ( "????????.???" );
	
	for ( count = 0; dircode != 0xff; count++ ) {
		p = ( ( char * ) CPMBUF + dircode * 32 );

		for ( i = 0; i < 16; i++ )
			*q++ = *p++ & ( ( i > 0 && i < 12 )
					? 0x7f : 0xff );
		
		if ( count == limit ) { 				/* can't fit them in */
			cpm_free ( dirbuf );
			unsort_dir();					/* do unsorted directory */
			return;
		}

		dircode = getnext();
	}

	qsort ( dirbuf, count, 16, dirsort );				/* sort in alpha order */
	
	/* ok, now print them all */
	se = ( struct sortentry * ) dirbuf;

	for ( i = Entries = 0; i < count; i++ ) {
		if ( !i || memcmp ( se, se - 1, 12 ) ) {
			size = se->rc + ( se->s2 * 32
					  + se->ex ) * 128;
			ksize = ( size / 8 ) + ( ( size % 8 ) ? 1 : 0 );
			memcpy ( filename, se->name, 8 );
			filename[8] = '.';
			memcpy ( filename + 9, se->type, 3 );
			filename[12] = '\0';
			printf ( "%s%4dk", filename, ksize );

			if ( printsep ( SORTCOLS ) )
				break;

			Entries++;
		}

		se++;
	}

	cpm_free ( dirbuf );

	if ( Entries % SORTCOLS )
		printf ( "\n" );
}

/* Do unsorted directory */
void unsort_dir()
{
	short dircode, i;
	struct direntry *dp;
	char filename[30];
	
	Lines = 2;
	dircode = getfirst ( "????????.???" );

	for ( Entries = 0; dircode != 0xff; Entries++ ) {
		dp = ( struct direntry * ) ( CPMBUF + dircode * 32 );
		memcpy ( filename, dp->flname, 8 );
		filename[8] = '.';
		memcpy ( filename + 9, dp->ftype, 3 );
		filename[12] = '\0';

		for ( i = 0; i < 11; i++ )	/* remove attributes */
			filename[i] = filename[i] & 0x7f;

		printf ( "%s", filename );

		if ( printsep ( UNSORTCOLS ) )
			break;

		dircode = getnext();
	}

	if ( Entries % UNSORTCOLS )
		printf ( "\n" );
}

/* Print separator between directory entries. Do [more] if page full */
/* Return TRUE if end of page and ctl-c or ctl-k typed */
int printsep ( short count )
{
	if ( ( Entries % count ) == count - 1 ) {
		printf ( "\n" );

		if ( ++Lines == DIRLINES ) {	/* bump line count */
			Lines = 0;		/* pause if done a page */
			return domore();	/* then do [more] */
		}
	} else
		printf ( " | " );

	return FALSE;
}

/* Print [more] and wait for a key. Return TRUE if user hit ctl-c or ctl-k */
int domore()
{
	char c;

	printf ( "[more]" );
	flush();

	while ( ! ( c = bdos ( DIRCTIO, INPUT ) ) );	/* loop till we get one */

	printf ( "\b\b\b\b\b\b      \b\b\b\b\b\b" );

	if ( c == CTRLC || c == CTRLK )
		return TRUE;
	else
		return FALSE;
}

/* Function for qsort to compare two directory entries */
int dirsort ( char * p1, char * p2 )
{
	short j;

	if ( j = memcmp ( p1, p2, 12 ) )
		return j;

	/* Both are the same file -- sort on extent */
	if ( ( j = ( p1[14] * 32 + p1[12] ) - ( p2[14] * 32 + p2[12] ) ) > 0 )
		return -1;
	else
		return 1;
}

int cntbits ( char byte )
{
	static int i, count;

	for ( count = i = 0; i < 8; i++ ) {
		count += ( byte & 1 );
		byte >>= 1;
	}

	return count;
}

void resetace()  /* to default values */
{
	Current.cbaudindex = Line.baudindex;
	Current.cparity = Line.parity;
	Current.cdatabits = Line.databits;
	Current.cstopbits = Line.stopbits;
	updateace();
}

void updateace()
{
	initace ( Current.cbaudindex, Current.cparity,
		  Current.cdatabits, Current.cstopbits );
}

void hangup()
{
	stndout();
	printf ( "\n ZMP: Disconnect (Y/N) <N>? \007" );
	stndend();

	if ( toupper ( dio() ) != 'Y' ) {
		printf ( "\n" );
		return;
	}

	printf ( "\nHanging up...\n" );
	dtroff();			/* Turn DTR off for a bit */
	mswait ( 200 );			/* Like 200 ms */
	dtron();			/* Then back on again */
	mstrout ( Modem.hangup, FALSE );
	resetace();
}

void tlabel() /*print level 1 labels on the 25th line*/
{
	/*					Removed for now
	   killlabel();
	   printf(
	   "%s1> \033pReceive%s  Log  %s Dir  %sPrScr%s Send%sHangup%s Level %s Help %s",
	      Stline,Vl,Vl,Vl,Vl,Vl,Vl,Vl,Vl);
	   printf(
	   "Quit%s%02d%c%d%d%s%s%s%s%s%s\033q%s",Vl,Baudtable[Current.cbaudindex]/100,
	    Current.cparity,Current.cdatabits,Current.cstopbits,Vl,BFlag?"LG":"--",Vl,
	    PFlag?"PR":"--",Vl,FDx?"FDX":"HDX",Endline);
	*/

}

/* Prompt user and get any key */
int waitakey()
{
	char c;

	printf ( "\n Any key to continue: " );
	flush();

	while ( ! ( c = bdos ( DIRCTIO, INPUT ) ) );

	return c;
}

/*			End of TERM module				*/
