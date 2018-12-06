/******************** Initialisation Overlay for ZMP ***********************/

#define  INIT
#include "zmp.h"

#ifdef   AZTEC_C
#include "libc.h"
#else
#include <stdio.h>
#endif

#include <string.h>

/* ../zminit.c */
extern int ovmain(void);
extern int title(void);
extern int initializemodem(void);
extern int getconfig(void);
extern int xfgets(char *, int, FILE *);
extern int resetace(void);

extern int readline(int);

ovmain()
{
	unsigned u;

	userin();						/* perform user-defined entry routine */
	title();
	getconfig();
	initv();                				 /* set up interrupt vector */
	u = ( unsigned ) * Mspeed;

	if ( !u || u > 13 )
		initializemodem();				/* initialise uart as well */
	else {
		Current.cbaudindex = ( int ) ( *Mspeed );
		Current.cparity = Line.parity;			/* Only update */
		Current.cdatabits = Line.databits;		/*  internal   */
		Current.cstopbits = Line.stopbits;		/*  variables  */
	}

	Currdrive = Invokdrive;
	Curruser = Invokuser;
	reset ( Currdrive, Curruser );
	showcurs();
}


title()
{
	static char line1[] = "ZMP - A ZMODEM Program for CP/M";
	static char line3[] = "by Ron Murray";
	static char line4[] = "ported to Z80 Darkstar by Piergiorgio Betti";

	cls();
	LOCATE ( 7, ctr ( line1 ) );
	printf ( line1 );
	LOCATE ( 9, ctr ( Version ) );
	printf ( Version );
	LOCATE ( 10, ctr ( line3 ) );
	printf ( line3 );
	LOCATE ( 11, ctr ( line4 ) );
	printf ( line4 );
	LOCATE ( 14, 0 );
	hidecurs();
	flush();
}

/* Initialise the modem */
initializemodem()
{
	resetace();
	mstrout ( "\n\n", FALSE );
	mstrout ( Modem.init, FALSE );

	while ( readline ( 10 ) != TIMEOUT );	/* gobble echoed characters */
}

/* Read the .CFG file into memory */
getconfig()

{
	int i;
	FILE *fd;

	strcpy ( Pathname, Cfgfile );
	addu ( Pathname, Overdrive, Overuser );
	fd = fopen ( Pathname, "rb" );

	if ( fd ) {
		fscanf ( fd, "%d %d %d %d %d", &Crcflag, &Wantfcs32, &XonXoff,
			 &Filter, &ParityMask );

		for ( i = 0; i < 10; i++ )
			xfgets ( KbMacro[i], 22, fd );

		xfgets ( Mci, 20, fd );
		xfgets ( Sprint, 20, fd );
		xfgets ( Modem.init, 40, fd );
		xfgets ( Modem.dialcmd, 8, fd );
		xfgets ( Modem.dialsuffix, 8, fd );
		xfgets ( Modem.connect, 20, fd );
		xfgets ( Modem.busy1, 20, fd );
		xfgets ( Modem.busy2, 20, fd );
		xfgets ( Modem.busy3, 20, fd );
		xfgets ( Modem.busy4, 20, fd );
		xfgets ( Modem.hangup, 20, fd );
		fscanf ( fd, "%d %d", &Modem.timeout, &Modem.pause );
		fscanf ( fd, "%d %c %d %d", &Line.baudindex, &Line.parity,
			 &Line.databits, &Line.stopbits );
		fscanf ( fd, "%d %d %c %d %d", &Zrwindow, &Pbufsiz, &Maxdrive,
			 &Chardelay, &Linedelay );
		fclose ( fd );
	}
}

/* Read a string from a file and remove the newline characters */
xfgets ( buf, max, fd )
char *buf;
int max;
FILE *fd;

{
	short noerror = 1;
	char *p, *index();
	char tbuf[81];

	tbuf[0] = '\0';

	while ( !strlen ( tbuf ) && noerror ) {
		noerror = ( short ) fgets ( tbuf, 80, fd );

		while ( p = index ( tbuf, '\12' ) )
			strcpy ( p, p + 1 );

		while ( p = index ( tbuf, '\15' ) )
			strcpy ( p, p + 1 );
	}

	strncpy ( buf, tbuf, max );
}

resetace()  /* to default values */
{
	Current.cparity = Line.parity;
	Current.cdatabits = Line.databits;
	Current.cstopbits = Line.stopbits;
	Current.cbaudindex = Line.baudindex;
	initace ( Current.cbaudindex, Current.cparity,
		  Current.cdatabits, Current.cstopbits );
}

/* End of initialisation overlay */
