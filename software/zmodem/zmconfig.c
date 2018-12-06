/*************************************************************************/
/*									 */
/*		Configuration Overlay for ZMP - Module 1		 */
/*									 */
/*************************************************************************/


#include "zmp.h"

#ifdef   AZTEC_C
#include "libc.h"
#else
#include <stdio.h>
#endif

#include <ctype.h>
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

/* ../zmconfig.c */
extern int ovmain ( void );
extern void settransfer ( void );
extern void setsys ( void );
extern void setmodem ( void );
extern void gnewint ( char *, int * );
extern void gnewstr ( char *, char *, short );
extern void setline ( void );


ovmain()

{
	int c, cfgchanged, phonechanged;

#ifdef C80
	Cmode = 0;
#endif

	cfgchanged = phonechanged = FALSE;

	for (;;) {
		cls();
		printf ( "\r\t\t" );
		stndout();
		printf ( " CONFIGURATION MENU " );
		stndend();

		/*printf ( "\n\n\tA - Edit long distance access number\n" );*/

#ifdef HOSTON
		printf ( "\n\n\tH - Set host mode parameters\n" );
#endif

		printf ( "\n\n\tK - Edit keyboard macros\n" );
		printf ( "\tL - Set line parameters\n" );
		printf ( "\tM - Set modem parameters\n" );
		/*printf ( "\tP - Edit phone number list\n" );*/
		printf ( "\tS - Set system parameters\n" );
		printf ( "\tT - Set file transfer parameters\n" );
		printf ( "\tZ - Exit\n" );
		printf ( "\n   Select:  " );
		flush();
		c = toupper ( bdos ( CONIN ) );

		switch ( c ) {

			/*case 'A':
				ldedit();
				cfgchanged = TRUE;
				break;*/

#ifdef HOSTON

			case 'H':
				sethost();
				cfgchanged = TRUE;
				break;
#endif

			case 'K':
				edit();
				cfgchanged = TRUE;
				break;

			case 'L':
				setline();
				cfgchanged = TRUE;
				break;

			/*case 'M':
				setmodem();
				cfgchanged = TRUE;
				break;*/

			/*case 'P':
				phonedit();
				phonechanged = TRUE;
				break;*/

			case 'S':
				setsys();
				cfgchanged = TRUE;
				break;

			case 'T':
				settransfer();
				cfgchanged = TRUE;
				break;

			case ESC:
			case 'Z':
				if ( cfgchanged || phonechanged ) {
					printf ( "\nMake changes permanent? " );

					if ( c = toupper ( bdos ( CONIN ) ) == 'Y' ) {
						if ( cfgchanged )
							saveconfig();

						/*if ( phonechanged )
							savephone();*/

						kbwait ( 2 );
					}
				}

				cls();
				return 0;		/* Return from overlay */

			default:
				break;

		}			/* end of switch */

	}
}

void settransfer()
{
	int c;

	for (;;) {
		cls();
		printf ( "\r\t\t\t" );
		stndout();
		printf ( " FILE TRANSFER PARAMETERS " );
		stndend();
		printf ( "\n\n\tC - Set Checksum/CRC default - %s\n",
			Crcflag ? "CRC" : "Checksum" );
		printf ( "\tD - Set delay after each character in ASCII send - %d mS\n",
			Chardelay );
		printf ( "\tF - Toggle 32-bit FCS capability - %s\n",
			Wantfcs32 ? "Enabled" : "Disabled" );
		printf ( "\tL - Set delay after each line in ASCII send - %d mS\n",
			Linedelay );
		printf ( "\tW - Change Zmodem receive window size - %d\n", Zrwindow );
		printf ( "\tX - Toggle X-on/X-off protocol - %s\n",
			XonXoff ? "Enabled" : "Disabled" );
		printf ( "\tZ - Exit\n\n" );
		printf ( "   Select:  " );
		c = toupper ( bdos ( CONIN ) );
		putchar ( '\n' );

		switch ( c ) {
			case 'C':
				Crcflag = !Crcflag;
				break;

			case 'D':
				gnewint ( "character delay", &Chardelay );
				break;

			case 'F':
				Wantfcs32 = !Wantfcs32;
				break;

			case 'L':
				gnewint ( "line delay", &Linedelay );
				break;

			case 'W':
				gnewint ( "window size", &Zrwindow );
				break;

			case 'X':
				XonXoff = !XonXoff;
				break;

			case ESC:
			case 'Z':
				return;

			default:
				break;
		}

	}
}

void setsys()
{
	int c;
	char d;

	for (;;) {
		cls();
		printf ( "\r\t\t\t" );
		stndout();
		printf ( " SYSTEM PARAMETERS " );
		stndend();
		printf ( "\n\n\tB - Set print buffer size - %d bytes\n", Pbufsiz );
		printf ( "\tF - Toggle T-mode control character filter - now %s\n",
			Filter ? "ON" : "OFF" );
		printf ( "\tM - Set maximum drive on system - now %c:\n", Maxdrive );
		printf ( "\tP - Toggle T-mode parity bit removal - now %s\n",
			ParityMask ? "ON" : "OFF" );
		printf ( "\tZ - Exit\n\n" );
		printf ( "   Select:  " );
		c = toupper ( bdos ( CONIN ) );

		switch ( c ) {

			case 'B':
				gnewint ( "print buffer size", ( int * ) &Pbufsiz );
				Pbufsiz = Pbufsiz < 1 ? 512 : Pbufsiz;
				break;

			case 'F':
				Filter = !Filter;
				break;

			case 'M':
				printf ( "\n\nEnter new maximum drive: " );
				d = toupper ( bdos ( CONIN ) );
				Maxdrive = ( ( d >= 'A' ) && ( d <= 'P' ) ) ? d : 'B';
				break;

			case 'P':
				ParityMask = !ParityMask;
				break;

			case ESC:
			case 'Z':
				return;

			default:
				break;
		}

	}
}

/*char *Mdmstring[] = {
	"Modem init string.....",
	"Dialling command......",
	"Dial command suffix...",
	"Connect string........",
	"No Connect string 1...",
	"No Connect string 2...",
	"No Connect string 3...",
	"No Connect string 4...",
	"Hangup string.........",
	"Redial timeout delay..",
	"Redial pause delay...."
};*/


void gnewint ( char * prompt, int * intp )
{
	static char *temp;

	temp = Pathname;
	printf ( "\n\nEnter new %s:  ", prompt );
	getline ( temp, 20 );

	if ( temp[0] )
		*intp = atoi ( temp );
}

void gnewstr ( char * prompt, char * mstring, short length )
{
	char *temp;

	temp = Pathname;
	printf ( "\n\nEnter new %s:  ", prompt );
	getline ( temp, length );

	if ( temp[0] )
		strcpy ( mstring, temp );
}

void setline()
{
	int c;

	for (;;) {
		cls();
		printf ( "\r\t\t\t" );
		stndout();
		printf ( " LINE PARAMETERS " );
		stndend();
		printf ( "\n\n\tB - Bits per second.......%u\n",
			Baudtable[Line.baudindex] );
		printf ( "\tD - Number data bits......%d\n", Line.databits );
		printf ( "\tP - Parity................%c\n", Line.parity );
		printf ( "\tS - Number stop bits......%d\n", Line.stopbits );
		printf ( "\tZ - Exit\n\n" );
		printf ( "   Select:  " );
		c = toupper ( bdos ( CONIN ) );
		cls();

		switch ( c ) {
			case 'B':
				setbaud();
				break;

			case 'D':
				setdatabits();
				break;

			case 'P':
				setparity();
				break;

			case 'S':
				setstopbits();
				break;

			case ESC:
			case 'Z':
				return;

			default:
				break;
		}

	}
}
/********************** END OF ZMCONFIG MODULE 1 ****************************/
