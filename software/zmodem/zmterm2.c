/*			TERM module File 2				*/


#include "zmp.h"

#ifdef   AZTEC_C
#include "libc.h"
#else
#include <stdio.h>
#endif

#include <ctype.h>
#include <conio.h>
#include <string.h>


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
extern void toprinter(int);
extern void toggleprt(void);
extern int getprtbuf(void);
extern void doexit(void);
extern int prtservice(void);
extern int pready(void);
extern void adjustprthead(void);
extern void setace(int);
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
extern int cntbits(int);
extern int chrin(void);
extern int openerror ( int, char *, int );

extern int mcharinp ( void );
extern int mcharout ( char );
extern int minprdy ( void );

/* Display current keyboard macros */
void keydisp()
{
	short i;

	cls();
	printf ( "\r\t\t" );
	stndout();
	printf ( " KEYPAD MACRO LIST \n\n" );
	stndend();

	for ( i = 0; i < 10; i++ )
		printf ( "\t%d - %s\n", i, KbMacro[i] );

	printf ( "\n\n" );
}

/* Save a buffer to a file. If flag set, send ctl-s/ctl-q to stop remote */
void keep ( char *filename, short flag )
{
	short fl;

	if ( !BFlag )
		return;

	if ( !TxtPtr )
		goto cleanup;

	if ( flag )
		mcharout ( CTRLS );

	while ( TxtPtr % 128 )
		MainBuffer[TxtPtr++] = 0;

	strcpy ( Pathname, filename );
	addu ( Pathname, Invokdrive, Invokuser );

	if ( ( fl = open ( Pathname, 1 ) ) == UBIOT )
		if ( ( fl = creat ( Pathname, 0 ) ) == UBIOT )
			openerror ( (int) fl, Pathname, UBIOT );

	if ( fl != UBIOT ) {
		lseek ( fl, 0L, 2 );
		write ( fl, MainBuffer, TxtPtr );
		close ( fl );
	}

	if ( flag )
		mcharout ( CTRLQ );

	TxtPtr = 0;

cleanup:
	free ( MainBuffer );
}

void startcapture()     /* allocate capture buffer */
{
	char *grabmem();

	if ( !BFlag )
		return;

	MainBuffer = grabmem ( &Bufsize );
	Buftop = Bufsize - 1;
	TxtPtr = 0;

#ifdef DEBUG
	printf ( "\ncapture Bufsize = %u\n", Bufsize );
#endif

}

/* Allow user to change things */
void docmd()
{
	char c, parity, databits, stopbits;
	int i, oldfdx, oldremecho, oldbaud;
	unsigned baud;

start:
	cls();
	printf ( "\t\t" );
	stndout();
	printf ( " CHANGE LINE PARAMETERS \n" );
	stndend();
	printf ( "\n\tB - Change Baud Rate (now %u)\n",
		 Baudtable[Current.cbaudindex] );
	printf ( "\tD - Set Half/Full Duplex/Echo\n" );
	printf ( "\tF - Turn Control Character Filter %s\n",
		 Filter ? "OFF" : "ON" );
	printf ( "\tI - Initialise Modem\n" );
	printf ( "\tP - %s Parity Bit in Terminal Mode\n",
		 ParityMask ? "Pass" : "Strip" );
	printf ( "\tU - Set up UART: Parity, Stop Bits, Data Bits\n" );
	printf ( "\tZ - Exit\n" );
	printf ( "\n Select: " );

	switch ( c = toupper ( bdos ( CONIN ) ) ) {

		case 'B' :
			do {
				printf ( "\nEnter new baud rate: " );
				scanf ( "%d", &baud );

				while ( getchar() != '\n' );	/* flush */

				for ( i = 0; i < 13; i++ )
					if ( Baudtable[i] == baud )
						break;
			} while ( i > 12 ); /* Don't leave till it's right */

			oldbaud = Current.cbaudindex;
			Current.cbaudindex = i;
			updateace();

			/* error if change is intended but rejected */
			if ( ( *Mspeed == oldbaud ) && ( i != oldbaud ) ) {
				Current.cbaudindex = oldbaud;
				printf ( "\nBaud rate %u not available.\n", baud );
				waitakey();
			}

			break;

		case 'D':
			oldfdx = FDx;	/* Save original */
			oldremecho = RemEcho;
			FDx = TRUE;
			RemEcho = FALSE;
			printf ( "\n<F>ull Duplex, <H>alf Duplex or Remote <E>cho? " );

			switch ( c = toupper ( bdos ( CONIN ) ) ) {

				case 'H' :
					FDx = FALSE;
					break;

				case 'E' :
					FDx = FALSE;
					RemEcho = TRUE;
					break;

				case 'F' :
					break;

				default  :
					FDx = oldfdx;	/* no change */
					RemEcho = oldremecho;
					break;
			}

			break;

		case 'F':
			Filter = !Filter;
			break;

		case 'P':
			ParityMask = !ParityMask;
			break;

		case 'I':
			initace ( Current.cbaudindex, Current.cparity,
				  Current.cdatabits, Current.cstopbits );
			mstrout ( "\n\n", FALSE );
			mstrout ( Modem.init, FALSE );

			while ( readline ( 10 ) != TIMEOUT );

			break;

		case 'U':
			do {
				printf ( "\nEnter new parity (E, O, N): " );
				parity = toupper ( bdos ( CONIN ) );
			} while ( ( parity != 'E' ) && ( parity != 'O' )
				  && ( parity != 'N' ) );

			Current.cparity = parity;

			do {
				printf ( "\nEnter number of data bits (7,8): " );
				databits = bdos ( CONIN );
			} while ( ( databits != '7' ) && ( databits != '8' ) );

			Current.cdatabits = databits - '0';

			do {
				printf ( "\nEnter number of stop bits (1,2): " );
				stopbits = bdos ( CONIN );
			} while ( ( stopbits != '1' ) && ( stopbits != '2' ) );

			Current.cstopbits = stopbits - '0';
			updateace();
			break;


		case ESC:
		case 'Z':
			return;

		default:
			break;

	}		/* End of main switch */

	goto start;	/* Loop till esc or Z */
}

void capturetog ( char * filename )
{
	if ( !BFlag ) {
		BFlag = TRUE;
		startcapture();

		if ( allocerror ( MainBuffer ) )
			BFlag = FALSE;
		else {
			printf ( "\nEnter capture filename (cr = %s): ", filename );

			if ( getline ( Buf, 16 ) )
				strcpy ( Lastlog, Buf );
			else
				strcpy ( Lastlog, filename );

			printf ( "\nCapture ON\n" );
		}
	} else {
		keep ( Lastlog, FALSE );	/* assume remote not running */
		BFlag = FALSE;
		printf ( "\nCapture OFF\n" );
	}
}

void comlabel() /*print level 2 labels*/
{
	/*					** Removed for now
	   killlabel();
	   printf(
	   "%s2> \033p   Dial%sHost%sConfigure%sPrint%sDisk%sHangup%s Level %s",
	    Stline,Vl,Vl,Vl,Vl,Vl,Vl,Vl);
	   printf("Help%sQuit%s   %02d%c%d%d%s%s%s%s%s%s\033q%s",Vl,Vl,
	    Baudtable[Current.cbaudindex]/100,Current.cparity,Current.cdatabits,
	    Current.cstopbits,Vl,BFlag?"LG":"--",Vl,PFlag?"PR":"--",Vl,
	    FDx?"FDX":"HDX",Endline);
	*/
}

void scplabel()
{
	/*		removed
		putlabel("READING THE SCREEN -> Please wait...");
	*/
}

void diskstuff()
{
	static int c, drive, user;
	char newname[20];
	char q, *j;

	for ( ;; ) {
		cls();
		printf ( "\r\t\t" );
		stndout();
		printf ( " FILE AND DISK COMMANDS \n" );
		stndend();
		printf ( "\n\tC - Change disk in default drive\n" );
		printf ( "\tD - Directory of current disk\n" );
		printf ( "\tE - Erase file on default drive\n" );
		printf ( "\tF - Change default name of capture file (currently %s)\n",
			 Logfile );
		printf ( "\tL - Log into new du: (currently %c%d:)\n", Currdrive, Curruser );
		/*printf ( "\tP - Print a file on default drive\n" );*/
		printf ( "\tR - Rename a file on default drive\n" );
		printf ( "\tV - View a file on default drive\n" );
		printf ( "\tZ - Exit\n" );
		printf ( "\n Select: " );
		flush();
		c = toupper ( chrin() );

		switch ( c ) {

			case 'C':
				printf ( "\nChange disk in %c: then press any key...", Currdrive );
				flush();
				chrin();
				reset ( Currdrive, Curruser );
				break;

			case 'D':
				directory();
				waitakey();
				break;

			case 'E':
				if ( !possdirectory ( "Erase" ) )
					break;

				printf ( "\nAre you sure? (Y/N) <N>  " );
				flush();
				c = toupper ( chrin() );

				if ( c == 'Y' )
					unlink ( Pathname );

				break;

			case 'F':
				if ( !BFlag ) {
					printf ( "\nEnter new filename: " );
					scanf ( "%s", Logfile );
				} else {
					printf ( "\nNot while capture on!\n" );
					waitakey();
				}

				break;

			case 'L':
				printf ( "\nEnter the new default du:  " );
				flush();

				if ( !getline ( Pathname, 10 ) )
					break;

				drive = Currdrive;
				user = Curruser;
				j = Pathname;

				if ( isalpha ( q = toupper ( *j ) ) ) {
					drive = q;
					j++;
				}

				if ( isdigit ( q = *j ) )
					user = q - '0';

				if ( isdigit ( q = *++j ) )
					user = user * 10 + q - '0';
				
				reset ( drive, user );
				Currdrive = drive;
				Curruser = user;
				break;

/*			case 'P':
				if ( !possdirectory ( "Print" ) )
					break;

				addu ( Pathname, Currdrive, Curruser );
				printfile ( Pathname );
				break;*/

			case 'R':
				if ( !possdirectory ( "Rename" ) )
					break;

				flush();
				printf ( "New name for %s: ", Pathname );

				if ( !getline ( newname, 16 ) )
					break;

				rename ( Pathname, newname );
				break;

			case 'V':
				if ( !possdirectory ( "View" ) )
					break;

				addu ( Pathname, Currdrive, Curruser );
				cls();
				viewfile ( Pathname );
				waitakey();
				break;

			case 'Z':
			case ESC:
				return;

			default:
				break;
		}
	}
}

/* Prompt user and possibly give directory */
int possdirectory ( char * prompt )
{
	short x;

	do {
		printf ( "\n%s which file (CR = quit, ? = directory)? ", prompt );

		if ( !getline ( Pathname, 16 ) )
			return FALSE;

		if ( x = ( Pathname[0] == '?' ) )
			directory();
	} while ( x );

	return TRUE;
}

int help()
{
	int c;

	cls();
	printf ( "\r\t\t\t\t" );
	stndout();
	printf ( " ZMP HELP \n\n" );
	stndend();
	strcpy ( Pathname, "ZMP.HLP" );
	addu ( Pathname, Overdrive, Overuser );
	viewfile ( Pathname );
	printf ( "\nEnter function (cr to abort): " );
	return ( ( c = dio() ) == CR ? 0 : c );
}

/* View a file set up in Pathname */
void viewfile(char * fname)
{
	int i = 0;
	char c, kbdata;
	FILE *fd;

	fd = fopen ( fname, "rb" );	/* Use binary or it ignores CR */

	if ( openerror ( (int) fd, fname, BUFIOT ) )
		return;

	do {

		for ( i = 0; ( i < 21 ) && ( ( c = getc ( fd ) ) != EOF ) && ( c != CTRLZ ); ) {
			if ( c != LF )
				putchar ( c );

			if ( c == CR ) {		/* This will even print TRS80 files */
				putchar ( LF );
				++i;
			}
		}

		if ( ( c == EOF ) || ( c == CTRLZ ) )
			break;

		printf ( "\n\n Typing %s - ", fname );
		flush();

		if ( ( ( kbdata = bdos ( CONIN ) ) == CTRLC ) || ( kbdata == CTRLX ) )
			break;

		printf ( "\n" );

	} while ( i > -1 );

	fclose ( fd );
}

/* Print a file set up in fname */
void printfile(char * fname)
{
	char c;
	FILE *fd;

	fd = fopen ( fname, "rb" );	/* Use binary or it ignores CR */

	if ( openerror ( (int) fd, fname, BUFIOT ) )
		return;

	printf ( "\nAny key to abort..\n" );

	while ( ( ( c = getc ( fd ) ) != EOF ) && ( c != CTRLZ )
		&& ! ( bdos ( DIRCTIO, INPUT ) ) ) {
		if ( c != LF )
			bdos ( LWRITE, c );	/* list output */

		if ( c == CR )			/* This will even print TRS80 files */
			bdos ( LWRITE, LF );
	}

	fclose ( fd );
}

/*			End of TERM module File 2			*/
