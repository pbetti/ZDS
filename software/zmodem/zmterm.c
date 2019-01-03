	/*			TERM module File #1				*/

#include "zmp.h"

#ifdef   AZTEC_C
#include "libc.h"
#else
#include <stdio.h>
#endif

#include <ctype.h>
#include <conio.h>
#include <string.h>


#define autolen 6		/* length of ZRQINIT required for auto rx */

/* ../zmterm2.c */
extern void keydisp(void);
extern void keep(char *, short);
extern void startcapture(void);
extern void docmd(void);
extern void capturetog(char *);
extern void comlabel(void);
extern void scplabel(void);
extern void diskstuff(void);
extern int possdirectory(char *);
extern int help(void);
extern void viewfile(char *);
extern void printfile(char *);

/* ../zmterm3.c */
extern int directory(void);
extern int sorted_dir(unsigned char *, unsigned);
extern int unsort_dir(void);
extern int printsep(int);
extern int domore(void);
extern int dirsort(char *, char *);
extern int cntbits(int);
extern int resetace(void);
extern int updateace(void);
extern int hangup(void);
extern int tlabel(void);
extern int waitakey(void);

/* ../zmterm.c */
extern int ovmain(void);
extern void prtchr(char);
extern void tobuffer(int);
extern void prompt(short);
extern void doexit(void);
extern void setace(int);

extern int allocerror ( char * );
extern int dio ( void );
extern int bios ( int );
extern int readline(int);
extern int readstr(char *, int);
extern int isin(char *, char *);
extern int kbwait(unsigned);
extern int getchi ( void );


extern int mcharinp ( void );
extern int mcharout ( char );
extern int minprdy ( void );
extern int deinitv( void );
extern void * cpm_malloc ( size_t );
extern void cpm_free(void *);


static short Chpos;


int ovmain()
{

	static short i, mdmdata, dolabel, keycount, keypoint;
	static short lastkey = '\0', fkey, autopos;
	static char keybuf[25], autoseq[] = { '*', '*', CTRLX, 'B', '0', '0' };
	static char kbdata;

	if ( FirsTerm ) {
		locate ( 0, 0 );				/* print header if first time*/
		prompt ( FALSE );				/* but don't clear screen */
		locate ( 15, 0 );				/* then put cursor near bottom */
		printf ( "Ready!     \n" );			/* overwrite 'wait' */
		Chpos = 0;			
		/* clear character position */
		FirsTerm = FALSE;				/* don't come here again */
	} else
		prompt ( TRUE );

	startcapture();
	autopos = keycount = 0;					/* no remote xfer, no keys in buffer */
	Zmodem = FALSE;						/* ensure we don't auto zmodem */
	purgeline();						/* get rid of any junk */

	/* Main loop: */

	for (;;) {
		if ( keycount ) {				/* get any buffered keys */
			kbdata = keybuf[keypoint++];
			keycount--;

			if ( kbdata == RET ) {			/* Translate ! to CR/LF */
				kbdata = CR;
				keybuf[--keypoint] = LF;
				keycount++;			/* get LF next time */
			}

			if ( kbdata == WAITASEC ) {		/* handle pause */
				wait ( 1 );
				kbdata = '\0';			/* that's it for this loop */
			}
		} else
			kbdata = getchi();			/* if none, any at keyboard */

		if ( kbdata )  {
			if ( lastkey == ESC ) {
				fkey = toupper ( kbdata );
				/* allow ESC ESC without complications */
				lastkey = ( kbdata == ESC ) ? '\0' : kbdata;
				dolabel = TRUE;
				flush();

				switch ( fkey ) {

					case RECEIVE:
					case SEND:
					case CONFIG:
						keep ( Lastlog, FALSE );
						return fkey;

					case USER:
						printf ( "\nEnter overlay number: " );
						scanf ( "%d", &Userid );
						return fkey;

					case CAPTURE:
						capturetog ( Logfile );
						dolabel = FALSE;
						Chpos = 0;
						break;

					case DIR:
						killlabel();
						keep ( Lastlog, FALSE );
						directory();
						startcapture();
						Chpos = 0;
						dolabel = FALSE;
						break;

					case HANGUP:
						hangup();
						dolabel = FALSE;
						Chpos = 0;
						break;

					case COMMAND:
						docmd();
						break;
#ifdef HOSTON

					case HOST:
						keep ( Lastlog, TRUE );
						QuitFlag = FALSE;
						Inhost = TRUE;

						while ( !QuitFlag )
							dohost();

						Inhost = FALSE;
						flush();
						cls();
						startcapture();
						break;
#endif
					case DISK:
						diskstuff();
						Chpos = 0;
						break;

					case HELP:
						if ( keybuf[0] = help() ) {
							lastkey = ESC;
							keycount = 1;
							keypoint = 0;
							dolabel = FALSE;
						}

						Chpos = 0;
						break;

					case QUIT:
						doexit();
						break;

					case CLRSCR:
						cls();
						break;

					case BRK:
						sendbrk();
						printf ( "\nBreak sent.\n" );
						dolabel = FALSE;
						Chpos = 0;
						break;

					case DISPKEYS:
						keydisp();
						dolabel = FALSE;
						break;

					default:
						dolabel = FALSE;
						i = fkey - '0';

						if ( ( i >= 0 ) && ( i <= 9 ) )  {
							strcpy ( keybuf, KbMacro[i] );
							keycount = strlen ( keybuf );
							keypoint = 0;
						} else
							mcharout ( kbdata ); 	/* send it if not anything else */

						break;

				}		/* end of switch*/

				if ( dolabel )
					prompt ( TRUE );			/* print header */

			}							/* end of if lastkey == ESC */

			else if ( ( lastkey = kbdata ) != ESC ) {
				
				mcharout ( kbdata );				/* Not a function key */

			}
		}                    						/*  end of if char at kbd  */

		if ( minprdy() ) {

			mdmdata = mcharinp();					/* Character at modem */

			if ( mdmdata == autoseq[autopos++] ) {			/* ZRQINIT? */
				if ( autopos == autolen ) {
					printf ( "\nZmodem receive.\n" );
					Zmodem = TRUE;				/* yes, do auto.. */
					return RECEIVE;				/* ..zmodem receive */
				}
			} else							/* no, reset ZRQINIT sequence test */
				autopos = ( mdmdata == '*' ) ? 1 : 0;

			if ( ParityMask )					/* if flag on, */
				mdmdata &= 0x7f;				/* remove parity */

			if ( Filter && ( mdmdata > '\r' ) && ( mdmdata < ' ' ) )
				;						/* filter control chars */
			else {

				prtchr ( mdmdata );				/* print the character */
				tobuffer ( mdmdata );

				if ( RemEcho ) {
					mcharout ( mdmdata );

					if ( mdmdata == CR ) {
						mcharout ( LF );
					}
				}
			}
		}
	}    /* end of while */				
} /* end of main */


/* print character, handling tabs (can't use bdos 2 as it reacts to ctl-s) */
void prtchr ( char c )
{
	if ( c == '\t' ) {						/* process tabs */
		bdos ( DIRCTIO, ' ' );					/* do at least one */

		while ( ++Chpos % 8 )
			bdos ( DIRCTIO, ' ' ); 				/* pad with space */
	} else {						
		bdos ( DIRCTIO, c );					/* just print it */

		if ( c >= ' ' )						/* if printable, */
			Chpos++;					/* bump character position */
		else if ( c == '\r' )					/* cr resets  it */
			Chpos = 0;
	}
}

void tobuffer ( int c )
{
	if ( BFlag ) {
		MainBuffer[TxtPtr++] = ( char ) c;

		if ( TxtPtr > Buftop ) {
			keep ( Lastlog, TRUE );				/* must be true since remote */
			startcapture();					/* is probably still going */
		}		
	}
}

/* Print message at top of page. Clear screen first if clear set */
void prompt ( short clear )
{
	if ( clear )
		cls();

	printf ( "\rTerminal Mode: ESC H for help.\t\t" );
	printf ( "Drive %c%d:   %u baud\n", Currdrive, Curruser,
		 Baudtable[Current.cbaudindex] );
	Chpos = 0;							/* reset character position */
}


/* Quit. */
void doexit()
{
	static char c;

	killlabel();
	putlabel ( "Are you SURE you want to exit ZMP? (Y/N) <Y>" );

	if ( c = toupper ( dio() ) == 'N' )
		return;

	keep ( Lastlog, FALSE );
	reset ( Invokdrive, Invokuser );
	deinitv();    						 	/* restore interrupt vector*/
	cls();
 	userout();	 						/* user-defined exit routine */
	exit ( 0 );							/* and quit */

}


void setace ( int n ) 		/* for a particular phone call */
{
	Current.cbaudindex = Book[n].pbaudindex;
	Current.cparity = Book[n].pparity;
	Current.cdatabits = Book[n].pdatabits;
	Current.cstopbits = Book[n].pstopbits;
	updateace();
}

/*			End of TERM module File 1			*/
