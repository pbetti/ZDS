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
extern int keydisp(void);
extern int keep(char *, int);
extern int startcapture(void);
extern int docmd(void);
extern int capturetog(char *);
extern int comlabel(void);
extern int scplabel(void);
extern int diskstuff(void);
extern int possdirectory(char *);
extern int help(void);
extern int viewfile(char *);
extern int printfile(char *);

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
extern int tobuffer(int);
extern void prompt(short);
extern int toprinter(int);
extern int toggleprt(void);
extern int getprtbuf(void);
extern int doexit(void);
extern int prtservice(void);
extern int pready(void);
extern int adjustprthead(void);
extern int setace(int);
extern int dial(void);
extern int shownos(void);
extern int loadnos(void);

extern int allocerror ( char * );
extern int dio ( void );
extern int bios ( int );
extern int readline(int);
extern int readstr(char *, int);
extern int isin(char *, char *);
extern int kbwait(unsigned);
char *alloc(), *index();
static short Chpos;

ovmain()
{

	static short i, mdmdata, dolabel, keycount, keypoint;
	static short lastkey = '\0', fkey, autopos;
	static char keybuf[25], autoseq[] = { '*', '*', CTRLX, 'B', '0', '0' };
	static char kbdata;

	if ( FirsTerm ) {
		locate ( 0, 0 );		/* print header if first time*/
		prompt ( FALSE );		/* but don't clear screen */
		locate ( 15, 0 );		/* then put cursor near bottom */
		printf ( "Ready.     \n" );	/* overwrite 'wait' */
		Chpos = 0;		/* clear character position */
		FirsTerm = FALSE;	/* don't come here again */
	} else
		prompt ( TRUE );

	startcapture();
	autopos = keycount = 0;	/* no remote xfer, no keys in buffer */
	Zmodem = FALSE;			/* ensure we don't auto zmodem */
	purgeline();			/* get rid of any junk */

	/* Main loop: */

	while ( TRUE ) {
		if ( keycount ) {		/* get any buffered keys */
			kbdata = keybuf[keypoint++];
			keycount--;

			if ( kbdata == RET ) {	/* Translate ! to CR/LF */
				kbdata = CR;
				keybuf[--keypoint] = LF;
				keycount++;	/* get LF next time */
			}

			if ( kbdata == WAITASEC ) {	/* handle pause */
				wait ( 1 );
				kbdata = '\0';	/* that's it for this loop */
			}
		} else
			kbdata = getch();	/* if none, any at keyboard */

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

					case PRTSCRN:
						/*
						screenprint();
						dolabel = FALSE;
						Chpos = 0;
						*/
						break;

					case HANGUP:
						hangup();
						dolabel = FALSE;
						Chpos = 0;
						break;

					case COMMAND:
						docmd();
						break;

					case DIAL:
						keep ( Lastlog, FALSE );
						dial();
						dolabel = FALSE;
						Chpos = 0;
						purgeline();
						startcapture();
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

					case TOGPRT:
						toggleprt();
						dolabel = FALSE;
						Chpos = 0;
						break;

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
							mcharout ( kbdata ); /* send it if not anything else */

						break;

				}		/* end of switch*/

				if ( dolabel )
					prompt ( TRUE );	/* print header */

			}			/* end of if lastkey == ESC */

			else if ( ( lastkey = kbdata ) != ESC ) {
				mcharout ( kbdata );	/* Not a function key */
ilfloop:

				if ( !FDx ) {
					prtchr ( kbdata );

					if ( kbdata == CR ) {
						kbdata = LF;

						if ( RemEcho )
							mcharout ( kbdata );

						goto ilfloop;
					}
				}
			}
		}                    /*  end of if char at kbd  */

		if ( minprdy() ) {
			mdmdata = mcharinp();	/* Character at modem */

			if ( mdmdata == autoseq[autopos++] ) {	/* ZRQINIT? */
				if ( autopos == autolen ) {
					printf ( "\nZmodem receive.\n" );
					Zmodem = TRUE;	/* yes, do auto.. */
					return RECEIVE;	/* ..zmodem receive */
				}
			} else	/* no, reset ZRQINIT sequence test */
				autopos = ( mdmdata == '*' ) ? 1 : 0;

			if ( ParityMask )			/* if flag on, */
				mdmdata &= 0x7f;	/* remove parity */

			if ( Filter && ( mdmdata > '\r' ) && ( mdmdata < ' ' ) )
				goto endloop;	/* filter control chars */

olfloop:
			prtchr ( mdmdata );	/* print the character */
			tobuffer ( mdmdata );
			toprinter ( mdmdata );

			if ( RemEcho ) {
				mcharout ( mdmdata );

				if ( mdmdata == CR ) {
					mdmdata = LF;
					goto olfloop;
				}
			}
		}

endloop:
		prtservice();     /* service printer at the end of each loop */
	}    /* end of while */
}/* end of main */


/* print character, handling tabs (can't use bdos 2 as it reacts to ctl-s) */
void prtchr ( char c )
{
	if ( c == '\t' ) {			/* process tabs */
		bdos ( DIRCTIO, ' ' );		/* do at least one */

		while ( ++Chpos % 8 )
			bdos ( DIRCTIO, ' ' ); 	/* pad with space */
	} else {
		bdos ( DIRCTIO, c );		/* just print it */

		if ( c >= ' ' )			/* if printable, */
			Chpos++;	/* bump character position */
		else if ( c == '\r' )		/* cr resets  it */
			Chpos = 0;
	}
}

tobuffer ( c )
int c;
{
	if ( BFlag ) {
		MainBuffer[TxtPtr++] = ( char ) c;

		if ( TxtPtr > Buftop ) {
			keep ( Lastlog, TRUE );	/* must be true since remote */
			startcapture();		/* is probably still going */
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
	Chpos = 0;			/* reset character position */
}

toprinter ( i )
int i;
{
	char c;

	c = ( char ) i;

	if ( PFlag && ( c != '\f' ) ) {	/* don't print form feeds */
		*Prthead++ = c;
		adjustprthead();
	}
}

toggleprt()
{
	PFlag = !PFlag;

	if ( PFlag ) {
		if ( getprtbuf() != OK )
			PFlag = FALSE;
		else printf ( "\nPrinter ON\n" );
	} else {
		while ( prtservice() )
			;	/* Empty the buffer */

		bdos ( 5, '\r' );	/* do final cr/lf */
		bdos ( 5, '\n' );
		free ( Prtbuf );
		printf ( "\nPrinter OFF\n" );
	}
}

getprtbuf()
{
	keep ( Lastlog, TRUE );	/* need to steal some of the buffer */
	Prtbuf = alloc ( Pbufsiz );

	if ( allocerror ( Prtbuf ) )
		return NERROR;

	Prthead = Prttail = Prtbottom = Prtbuf;
	Prttop = Prtbuf + Pbufsiz - 1;
	startcapture();

#ifdef DEBUG
	printf ( "\nPrtbuf = %x\n", Prtbuf );
#endif

	return OK;
}

/* Quit. */
doexit()
{
	static char c;

	killlabel();
	putlabel ( "Are you SURE you want to exit ZMP? (Y/N) <Y>" );

	if ( c = toupper ( dio() ) == 'N' )
		return;

	keep ( Lastlog, FALSE );
	reset ( Invokdrive, Invokuser );
	/*	deinitvector();     //restore interrupt vector*/
	cls();
/* 	userout();	 user-defined exit routine */
	exit ( 0 );		/* and quit */

}

prtservice()    /*printer service routine*/
{

	if ( PFlag ) {
		if ( pready() ) {
			if ( Prthead != Prttail ) {
				bdos ( 5, *Prttail++ );    /* write list byte */

				if ( Prttail > Prttop )
					Prttail = Prtbottom;
			}

			return ( Prthead != Prttail );	/* Return true if buffer full */
		}
	}
}

pready()   /*get printer status using bios call*/
{
	return ( bios ( 14 + 1 ) );

}

adjustprthead()
{
	if ( Prthead > Prttop )
		Prthead = Prtbottom;
}

setace ( n ) /* for a particular phone call */
int n;
{
	Current.cbaudindex = Book[n].pbaudindex;
	Current.cparity = Book[n].pparity;
	Current.cdatabits = Book[n].pdatabits;
	Current.cstopbits = Book[n].pstopbits;
	updateace();
}

dial()
{
	static char *number;      /* buffer for number to be sent to modem */
	static char *result;      /* buffer for responses from modem */
	static char *instr;       /* buffer for numbers entered at keyboard */
	static int connect;
	static int status, i, j, n, nocnt, action, c;
	static char *p;

	if ( allocerror ( number = alloc ( 128 ) ) )
		return;

	if ( allocerror ( result = alloc ( 128 ) ) )
		return;

	if ( allocerror ( instr = alloc ( 128 ) ) )
		return;

	status = shownos();
	printf ( "\nEnter letters and/or numbers, separated by commas..\n: " );
	QuitFlag = connect = FALSE;
	Dialing = TRUE;

	if ( j = getline ( instr, 80 ) ) {
		putlabel ( "Automatic Redial:  Press ESC to stop" );

		for ( i = 0, nocnt = 1; instr[i]; i++ )
			if  ( instr[i] == ',' ) {
				instr[i] = 0;
				nocnt++;
			}

		i = nocnt;

		while ( TRUE ) {
			p = instr;
			nocnt = i;

			while ( nocnt-- ) {
				n = -1;
				strcpy ( number, Modem.dialcmd );

				if ( *p == '+' ) {
					strcat ( number, Sprint );
					p++;
				} else if ( *p == '-' ) {
					strcat ( number, Mci );
					p++;
				}

				if ( ( status == OK ) && ( j = strlen ( p ) ) == 1 ) {
					if ( isalpha ( n = *p ) ) {
						n = toupper ( n ) - 'A';
						setace ( n );
						strcat ( number, Book[n].number );
						strcat ( number, Modem.dialsuffix );
						mstrout ( number, FALSE );
						printf ( "\nDialing %s...",
							 Book[n].name );
					} else {
						printf ( "\nInvalid Number\n" );
						goto abort;
					}
				} else {
					strcat ( number, p );
					strcat ( number, Modem.dialsuffix );
					mstrout ( number, FALSE );
					printf ( "\nDialing %s...", p );
				}

				/*flush modem input*/
				while ( readline ( 10 ) != TIMEOUT );

				do {
					action = readstr ( result, Modem.timeout );

					if ( action == TIMEOUT )
						goto abort;

					printf ( "%s\n", result );
				} while ( ! ( c = isin ( result, Modem.connect ) )
					  && !isin ( result, Modem.busy1 )
					  && !isin ( result, Modem.busy2 )
					  && !isin ( result, Modem.busy3 )
					  && !isin ( result, Modem.busy4 ) );

				if ( c ) {    /* got connect string */
					printf ( "\007\nOn Line to %s\n",
						 n >= 0 ? Book[n].name : p );

					if ( n >= 0 )
						FDx = !Book[n].echo;

					connect = TRUE;
					goto done;
				}

				mcharout ( CR );

				/* wait for modem */
				while ( readline ( 10 ) != TIMEOUT );

				p += j + 1;
			}

			if ( kbwait ( Modem.pause ) )
				goto abort;
		}
	}

abort:
	printf ( "Call Aborted.\n" );
	mcharout ( CR );
	readstr ( result, 1 );  /*gobble last result*/
	resetace();

done:
	flush();

	if ( Book != ( struct phonebook * ) MEMORY_FULL )
		free ( Book );

	free ( instr );
	free ( result );
	free ( number );
	Dialing = FALSE;
	return connect;
}

shownos()
{
	static int i, j, status;

	cls();

	if ( ( status = loadnos() ) == OK ) {
		stndout();
		printf ( "         NAME                NUMBER          B   P D S E" );
		stndend();

		for ( i = 0, j = 1; i < 20; i++, j++ ) {
			LOCATE ( i + 1, 0 );
			printf ( "%c - %s", i + 'A', Book[i].name );
			LOCATE ( i + 1, 41 - strlen ( Book[i].number ) );
			printf ( Book[i].number );
			LOCATE ( i + 1, 44 );
			printf ( "%4d %c", Baudtable[Book[i].pbaudindex],
				 Book[i].pparity );
			printf ( " %d %d %c\n", Book[i].pdatabits,
				 Book[i].pstopbits, Book[i].echo ? 'H' : 'F' );
		}
	}

	return status;
}

loadnos()
{
	static unsigned amount;
	char dummy;
	int i, result;
	FILE *fd;

	result = NERROR;
	amount = 21 * sizeof ( struct phonebook );
	Book = ( struct phonebook * ) alloc ( amount );

	if ( !allocerror ( (char *)Book ) ) {
		strcpy ( Pathname, Phonefile );
		addu ( Pathname, Overdrive, Overuser );
		fd = fopen ( Pathname, "r" );

		if ( fd ) {
			for ( i = 0; i < 20; i++ ) {
				fgets ( Book[i].name, 17, fd );
				fscanf ( fd, "%c %s %d %c",
					 &dummy,
					 Book[i].number,
					 &Book[i].pbaudindex,
					 &Book[i].pparity );
				fscanf ( fd, "%d %d %d",
					 &Book[i].pdatabits,
					 &Book[i].pstopbits,
					 &Book[i].echo );
				fgetc ( fd );		/* remove LF */
			}

			fclose ( fd );
			result = OK;
		}
	}

	return result;
}
/*			End of TERM module File 1			*/
