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
extern void setparity(void);
extern void setdatabits(void);
extern void setstopbits(void);
extern void sethost(void);
extern void edit(void);
extern void saveconfig(void);
extern void setbaud(void);
extern int goodbaud(int);


void setparity()
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

void setdatabits()
{
	int c;

	cls();

	do {
		printf ( "(7) data bits or (8) data bits?  " );
	} while ( ( c = ( bdos ( CONIN ) - '0' ) ) != 7 && c != 8 && c != 0 );

	if ( c )
		Line.databits = c;
}

void setstopbits()
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

void sethost()
{
	int c;

	for (;;) {
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
		
			default:
				printf ( "\007\nInvalid Entry\n" );
				wait ( 1 );
		}

	}
}

#endif		/* HOSTON */


void edit()
{
	static int i;
	char buffer[40];
	static char keypad[] = "0123456789";
	static char keybuf[2];

	buffer[0] = '\0';

	for (;;) {
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


void saveconfig()
{
	int i;
	FILE *fd;
	char filename[20];

	strcpy ( filename, Cfgfile );
	addu ( filename, Overdrive, Overuser );
	fd = fopen ( filename, "w" );

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

void setbaud()
{
	int baud;
	char buffer[20];

	buffer[0] = '\0';

	do {
		printf ( "\nEnter default modem bit rate:  " );

		getline ( buffer, 6 );
		if ( ! buffer[0] )
			break;

		baud = atoi ( buffer );
		printf ( "\n" );
	} while ( !goodbaud ( baud ) );
}

int goodbaud ( int value )
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
