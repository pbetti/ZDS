/*************************************************************************/
/*															  			 */
/*		Configuration Overlay for ZMP - Module 2		 				 */
/*									 									 */
/*************************************************************************/


#include "zmp.h"
#include "zconfig.h"

#ifdef   AZTEC_C
#include "libc.h"
#else
#include <stdio.h>
#endif

#include <ctype.h>
#include <string.h>
#include <stdlib.h>

/* ../zmconf2.c */
extern int setparity(void);
extern int setdatabits(void);
extern int setstopbits(void);
extern int sethost(void);
extern int phonedit(void);
extern int cshownos(void);
extern int cloadnos(void);
extern int ldedit(void);
extern int edit(void);
extern int savephone(void);
extern int saveconfig(void);
extern int setbaud(void);
extern int goodbaud(int);


setparity()
{
	int c;

	cls();

	do {
		printf ( "(N)o parity, (O)dd parity, or (E)ven parity?  " );
	} while ( ( c = toupper ( bdos ( CONIN ) ) ) != 'N' && c != 'O'
		  && c != 'E' && c != 0 );

	if ( c )
		Line.parity = c;
}

setdatabits()
{
	int c;

	cls();

	do {
		printf ( "(7) data bits or (8) data bits?  " );
	} while ( ( c = ( bdos ( CONIN ) - '0' ) ) != 7 && c != 8 && c != 0 );

	if ( c )
		Line.databits = c;
}

setstopbits()
{
	int c;

	cls();

	do {
		printf ( "(1) stop bit or (2) stop bits?  " );
	} while ( ( c = ( bdos ( CONIN ) - '0' ) ) != 1 && c != 2 && c != 0 );

	if ( c );

	Line.stopbits = c;
}

#ifdef HOSTON

sethost()
{
	int c;

start:
	cls();
	printf ( "\r\t\t\t" );
	stndout();
	printf ( " HOST MODE PARAMETERS " );
	stndend();
	printf ( "\n\n\tA - Welcome string.....%s\n", Host.welcome );
	printf ( "\tB - Autoanswer string..%s\n", Host.autoanswer );
	printf ( "\tC - Password...........%s\n", Host.password );
	printf ( "\tD - Connection type....%s\n", Host.modemconnection ?
		 "MODEM" : "DIRECT" );
	printf ( "\tZ - Exit\n\n" );
	printf ( "   Select:  " );
	c = toupper ( bdos ( CONIN ) );
	cls();

	switch ( c ) {
		case 'A':
			gnewstr ( "welcome string", Host.welcome, 20 );
			break;

		case 'B':
			gnewstr ( "autoanswer string", Host.autoanswer, 20 );
			break;

		case 'C':
			gnewstr ( "password", Host.password, 20 );
			break;

		case 'D':
			printf ( "(M)odem or (D)irect connection? <M> :  " );

			if ( toupper ( bdos ( CONIN ) ) == 'D' )
				Host.modemconnection = FALSE;
			else
				Host.modemconnection = TRUE;

			break;

		case ESC:
		case 'Z':
			return;
			break;

		default:
			printf ( "\007\nInvalid Entry\n" );
			wait ( 1 );
			break;
	}

	goto start;
}

#endif		/* HOSTON */

phonedit()
{
	int i, c, change;
	char *answer;

	cloadnos();
	answer = Pathname;

	while ( TRUE ) {
		flush();
		cshownos();
		printf ( "\nEnter letter of phone number to change/enter,\n" );
		printf ( "or anything else to EXIT:  " );
		c = toupper ( bdos ( CONIN ) ) - 'A';

		if ( c < 0 || c > 20 )
			break;

		change = TRUE;
		flush();
		printf ( "\n          Name:  %s\nEnter new name:  ",
			 PBook[c].name );

		getline ( answer, 18 );
		if ( answer[0] ) {
			while ( strlen ( answer ) < 17 )
				strcat ( answer, " " ); /* Pad with spaces */

			strcpy ( PBook[c].name, answer );
		}

		printf ( "\n          Number:  %s\nEnter new number:  ",
			 PBook[c].number );

		getline ( answer, 18 );
		if ( answer[0] )
			strcpy ( PBook[c].number, answer );

		printf ( "\n          Bit rate:  %u\nEnter new bit rate:  ",
			 Baudtable[PBook[c].pbaudindex] );

		getline ( answer, 18 );
		if ( answer[0] ) {
			for ( i = 0; i < 13; i++ ) {
				if ( atoi ( answer ) == Baudtable[i] ) {
					PBook[c].pbaudindex = i;
					break;
				}
			}
		}

		printf ( "\n          Parity:  %c\nEnter new parity:  ",
			 PBook[c].pparity );

		getline ( answer, 18 );
		if ( answer[0] )
			PBook[c].pparity = toupper ( answer[0] );

		printf ( "\n    Nr data bits:  %d\nEnter new number:  ",
			 PBook[c].pdatabits );

		getline ( answer, 18 );
		if ( answer[0] )
			PBook[c].pdatabits = atoi ( answer );

		printf ( "\n    Nr stop bits:  %d\nEnter new number:  ",
			 PBook[c].pstopbits );

		getline ( answer, 18 );
		if ( answer[0] )
			PBook[c].pstopbits = atoi ( answer );

		printf ( "\n                Duplex:  %s\nEnter (H)alf or (F)ull:  ",
			 PBook[c].echo ? "Half" : "Full" );

		getline ( answer, 18 );
		if ( answer[0] )
			PBook[c].echo = ( toupper ( answer[0] ) == 'H' );
	}

	flush();
	cls();
}

cshownos()
{
	int i, j;

	cls();
	stndout();
	printf ( "         NAME                NUMBER          B   P D S E" );
	stndend();

	for ( i = 0, j = 1; i < 20; i++, j++ ) {
		LOCATE ( i + 1, 0 );
		printf ( "%c - %s", i + 'A', PBook[i].name );
		printf ( " %s", PBook[i].number );
		LOCATE ( i + 1, 44 );
		printf ( "%4d %c", Baudtable[PBook[i].pbaudindex],
			 PBook[i].pparity );
		printf ( " %d %d %c\n", PBook[i].pdatabits, PBook[i].pstopbits,
			 PBook[i].echo ? 'H' : 'F' );
	}
}

cloadnos()
{
	int i, result;
	char dummy;
	FILE *fd;

	result = NERROR;
	strcpy ( Pathname, Phonefile );
	addu ( Pathname, Overdrive, Overuser );
	fd = fopen ( Pathname, "r" );

	if ( fd ) {
		for ( i = 0; i < 20; i++ ) {
			fgets ( PBook[i].name, 17, fd );
			fscanf ( fd, "%c %s %d %c %d %d %d",
				 &dummy,
				 PBook[i].number,
				 &PBook[i].pbaudindex,
				 &PBook[i].pparity,
				 &PBook[i].pdatabits,
				 &PBook[i].pstopbits,
				 &PBook[i].echo );
			fgetc ( fd );	/* remove LF */
		}

		fclose ( fd );
		result = OK;
	}

	return result;
}

ldedit()
{
	char *p, *answer;
	int c;

	answer = Pathname;

	while (TRUE) {

		cls();
		printf ( "\r\t\t\t" );
		stndout();
		printf ( " LONG DISTANCE ACCESS CODE " );
		stndend();
		printf ( "\n\nEnter access code to edit:\n\n" );
		printf ( "  + (currently '%s')\n  - (currently '%s')\n\tor Z to exit: ",
			Sprint, Mci );
		c = toupper ( bdos ( CONIN ) );

		switch ( c ) {

			case '+':
				p = Sprint;
				break;

			case '-':
				p = Mci;
				break;

			case ESC:
			case 'Z':
				return;

			default:
				continue;
		}

		printf ( "\nEnter new code: " );

		getline ( answer, 20 );
		if ( answer[0] )
			strcpy ( p, answer );

	}
}

edit()
{
	static int i;
	static char *buffer;
	static char keypad[] = "0123456789";
	static char keybuf[2];

	buffer = Pathname;

	while ( TRUE ) {
		cls();
		flush();
		printf ( "\r\t\t" );
		stndout();
		printf ( " KEYPAD MACRO LIST \n\n" );
		stndend();

		for ( i = 0; i < 10; i++ )
			printf ( "%d - %s\n", i, KbMacro[i] );

		printf ( "\nPress key of macro to edit, esc to quit:  " );
		keybuf[0] = bdos ( CONIN );
		keybuf[1] = '\0';

		switch ( keybuf[0] ) {

			case ESC:
			case 'Z':
				break;

			default:
				i = stindex ( keypad, keybuf );

#ifdef DEBUG
				printf ( "\nKeypad = %s\n   I = %d   Keybuf = %s\n", keypad, i, keybuf );
				wait ( 2 );
#endif

				if ( i < 0 || i > 9 )
					continue;

				flush();
				printf ( "\nIf you want the macro to end with a RETURN,\n" );
				printf ( "add a '!' to the end of your entry (20 characters max)." );
				printf ( "\n\nOld Macro:  %s", KbMacro[i] );
				printf ( "\n\nNew Macro:  " );

				getline ( buffer, 21 );
				if ( buffer[0] )
					strcpy ( KbMacro[i], buffer );

				continue;
		}	/* end of switch */

		break;
	}		/* end of WHILE */

	flush();
}

savephone()
{
	int i;
	FILE *fd;

	strcpy ( Pathname, Phonefile );
	addu ( Pathname, Overdrive, Overuser );
	fd = fopen ( Pathname, "w" );

	if ( fd ) {
		printf ( "\nSaving Phone numbers..." );

		for ( i = 0; i < 20; i++ ) {
			fprintf ( fd, "%s %s %d %c %d %d %d\n",
				  PBook[i].name,
				  PBook[i].number,
				  PBook[i].pbaudindex,
				  PBook[i].pparity,
				  PBook[i].pdatabits,
				  PBook[i].pstopbits,
				  PBook[i].echo );
		}

		fclose ( fd );
		printf ( "Successful.\n" );
	} else wrerror ( Phonefile );
}

saveconfig()
{
	int i;
	FILE *fd;

	strcpy ( Pathname, Cfgfile );
	addu ( Pathname, Overdrive, Overuser );
	fd = fopen ( Pathname, "w" );

	if ( fd ) {
		printf ( "\n\nSaving Configuration..." );
		fprintf ( fd, "%d %d %d %d %d\n", Crcflag, Wantfcs32,
			  XonXoff, Filter, ParityMask );

		for ( i = 0; i < 10; i++ )
			fprintf ( fd, "%s\n", KbMacro[i] );

		fprintf ( fd, "%s\n%s\n", Mci, Sprint );
		fprintf ( fd, "%s\n%s\n%s\n", Modem.init, Modem.dialcmd,
			  Modem.dialsuffix );
		fprintf ( fd, "%s\n%s\n%s\n", Modem.connect, Modem.busy1,
			  Modem.busy2 );
		fprintf ( fd, "%s\n%s\n%s\n", Modem.busy3, Modem.busy4,
			  Modem.hangup );
		fprintf ( fd, "%d %d\n", Modem.timeout, Modem.pause );
		fprintf ( fd, "%d %c %d %d\n", Line.baudindex, Line.parity,
			  Line.databits, Line.stopbits );
		fprintf ( fd, "%d %u %c %d %d\n", Zrwindow, Pbufsiz, Maxdrive,
			  Chardelay, Linedelay );
		fclose ( fd );
		printf ( "Successful.\n" );
	} else wrerror ( Cfgfile );
}

setbaud()
{
	int baud;
	char *buffer;

	buffer = Pathname;

	do {
		printf ( "\nEnter default modem bit rate:  " );

		getline ( buffer, 6 );
		if ( ! buffer[0] )
			break;

		baud = atoi ( buffer );
		printf ( "\n" );
	} while ( !goodbaud ( baud ) );
}

goodbaud ( value )
int value;
{
	int i;

	for ( i = 0; i < 14; i++ ) {
		if ( value == Baudtable[i] ) {
			Line.baudindex = i;
			return TRUE;
		}
	}

	printf ( "\nInvalid entry\n" );
	wait ( 1 );
	return FALSE;
}

/************************* END OF ZMCONFIG MODULE 2 *************************/
