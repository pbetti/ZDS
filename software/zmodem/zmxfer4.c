/********************** START OF XFER MODULE 4 ******************************/

/* rz.c By Chuck Forsberg modified for cp/m by Hal Maney */

#include "zmp.h"
#include "zmodem.h"

#ifdef   AZTEC_C
#include "libc.h"
#else
#include <stdio.h>
#endif

#include <string.h>

/* ../zmxfer2.c */
extern int wcsend(int, char *[]);
extern int wcs(char *);
extern int wctxpn(char *);
extern char *itoa(short, char *);
extern char *ltoa(long, char[]);
extern int getnak(void);
extern int wctx(long);
extern int wcputsec(char *, int, int);
extern int filbuf(char *, int);
extern int newload(char *, int);

/* ../zmxfer3.c */
extern int getzrxinit(void);
extern int sendzsinit(void);
extern int zsendfile(char *, int);
extern int zsndfdata(void);
extern int getinsync(int);
extern int saybibi(void);
extern char *ttime(long);
extern int tfclose(void);
extern int uneof(FILE *);
extern int slabel(void);

/* ../zmxfer4.c */
extern int wcreceive(char *);
extern int wcrxpn(char *);
extern int wcrx(void);
extern int wcgetsec(char *, int);
extern int procheader(char *);
extern char *substr(char *, char *);
extern int canit(void);
extern int clrreports(void);

/* ../zmxfer5.c */
extern int zperr(char *, int);
extern int dreport(int, int );
extern int lreport(int, long);
extern int sreport(int, long);
extern int clrline(int);
extern int tryz(void);
extern int rzmfile(void);
extern int rzfile(void);
extern int statrep(long);
extern int crcrept(int);
extern int putsec(int, int );
extern int zmputs(char *);
extern int testexist(char *);
extern int closeit(void);
extern int ackbibi(void);
extern long atol(char *);
extern int rlabel(void);

/* ../zmxfer.c */
extern int ovmain(char);
extern int sendout(int);
extern int bringin(int);
extern int endstat(int, int );
extern int protocol(int);
extern int updcrc(unsigned, unsigned );
extern long updc32(int, long);
extern int asciisend(char *);
extern int checkpath(char *);
extern int xmchout(char);
extern int testrxc(short);

/* ../zzm2.c */
extern int zrbhdr(char *);
extern int zrb32hdr(char *);
extern int zrhhdr(char *);
extern int zputhex(int);
extern int zsendline(int);
extern int zgethex(void);
extern int zgeth1(void);
extern int zdlread(void);
extern int noxrd7(void);
extern int stohdr(long);
extern long rclhdr(char *);

/* ../zzm.c */
extern int zsbhdr(int , char *);
extern int zsbh32(char *, int );
extern int zshhdr(int , char *);
extern int zsdata(char *, int, int );
extern int zsda32(char *, int, int );
extern int zrdata(char *, int );
extern int zrdat32(char *, int );
extern int zgethdr(char *, int);
extern int prhex(int);

extern int allocerror ( char * );
extern int opabort ( void );
extern int readline(int);
extern int openerror ( int, char *, int );

int Tryzhdrtype;	   /* Header type to send corresponding to Last rx close */
char *Rxptr;

wcreceive ( filename )
char *filename;
{
	char *grabmem(), *alloc();
	static int c;

	rlabel();
	QuitFlag = FALSE;
	Zctlesc = 0;
	Baudrate = Baudtable[Current.cbaudindex];
	Tryzhdrtype = ZRINIT;
	Secbuf = alloc ( KSIZE + 1 );

	if ( allocerror ( Secbuf ) )
		return NERROR;

	Cpmbuf = grabmem ( &Cpbufsize );

	if ( allocerror ( Cpmbuf ) )
		return NERROR;

	Cpindex = 0;				/* just in case */
	Rxptr = Cpmbuf;				/* ditto */
	Rxtimeout = 100;           		/* 10 seconds */
	Errors = 0;

#ifdef   DEBUG
	printf ( "\nbuffer size = %u\n", Cpbufsize );
	wait ( 5 );
#endif

	savecurs();
	hidecurs();
	box();

	if ( filename == ( char * ) 0 ) {        /* batch transfer */
		Crcflag = ( Wcsmask == 0377 );

		if ( c = tryz() ) {              /* zmodem transfer */
			report ( PROTOCOL, "ZMODEM Receive" );

			if ( c == ZCOMPL )
				goto good;

			if ( c == NERROR )
				goto fubar;

			c = rzmfile();

			if ( c )
				goto fubar;
		} else {                          /* ymodem batch transfer */
			report ( PROTOCOL, "YMODEM Receive" );
			report ( BLKCHECK, Crcflag ? "CRC" : "Checksum" );

			for ( ;; ) {
				if ( opabort() )
					goto fubar;

				if ( wcrxpn ( Secbuf ) == NERROR )
					goto fubar;

				if ( Secbuf[0] == 0 )
					goto good;

				if ( procheader ( Secbuf ) == NERROR )
					goto fubar;

				if ( wcrx() == NERROR )
					goto fubar;
			}
		}
	} else {
		report ( PROTOCOL, "XMODEM Receive" );
		strcpy ( Pathname, filename );
		checkpath ( Pathname );

#ifdef AZTEC_C

		Fd = fopen ( Pathname, "wb" );

		if ( openerror ( Fd, Pathname, BUFIOT ) )
#else
		testexist ( Pathname );

		Fd = creat ( Pathname, 0 );

		if ( openerror ( Fd, Pathname, UBIOT ) )
#endif

			goto fubar1;

		if ( wcrx() == NERROR )               /* xmodem */
			goto fubar;
	}

good:
	free ( Cpmbuf );
	free ( Secbuf );
	showcurs();
	restcurs();
	return OK;

fubar:
	canit();

#ifdef AZTEC_C

	if ( Fd )
#else
	if ( Fd >= 0 )
#endif

		unlink ( Pathname );	/* File incomplete: erase it */

fubar1:
	free ( Cpmbuf );
	free ( Secbuf );
	showcurs();
	restcurs();
	return NERROR;
}

/*
 * Fetch a pathname from the other end as a C ctyle ASCIZ string.
 * Length is indeterminate as long as less than Blklen
 * A null string represents no more files (YMODEM)
 */

wcrxpn ( rpn )
char *rpn;	/* receive a pathname */
{
	static int c;

	purgeline();

et_tu:
	Firstsec = TRUE;
	Eofseen = FALSE;
	mcharout ( Crcflag ? WANTCRC : NAK );

	while ( ( c = wcgetsec ( rpn, 100 ) ) != 0 ) {
		if ( QuitFlag )
			return NERROR;

		if ( c == WCEOT ) {
			mcharout ( ACK );
			readline ( INTRATIME );
			goto et_tu;
		}

		return NERROR;
	}

	mcharout ( ACK );
	return OK;
}

/*
 * Adapted from CMODEM13.C, written by
 * Jack M. Wierda and Roderick W. Hart
 */

wcrx()
{
	static int sectnum, sectcurr;
	static char sendchar;
	static int cblklen;			/* bytes to dump this block */
	long charsgot;

	Firstsec = TRUE;
	sectnum = 0;
	charsgot = 0L;
	Eofseen = FALSE;
	sendchar = Crcflag ? WANTCRC : NAK;
	report ( BLKCHECK, Crcflag ? "CRC" : "Checksum" );

	for ( ;; ) {
		if ( opabort() )
			return NERROR;

		mcharout ( sendchar );	         /* send it now, we're ready! */
		sectcurr = wcgetsec ( Rxptr, Firstsec || ( sectnum & 0177 ) ? 50 : 130 );

		if ( sectcurr == ( sectnum + 1 & Wcsmask ) ) {
			charsgot += Blklen;
			sreport ( ++sectnum, charsgot );
			cblklen = Blklen;

			if ( putsec ( cblklen, FALSE ) == NERROR )
				return NERROR;

			sendchar = ACK;
		} else if ( sectcurr == ( sectnum & Wcsmask ) ) {
			zperr ( "Duplicate Sector", TRUE );
			sendchar = ACK;
		} else if ( sectcurr == WCEOT ) {
			if ( closeit() )
				return NERROR;

			mcharout ( ACK );
			return OK;
		} else if ( sectcurr == NERROR )
			return NERROR;
		else {
			zperr ( "Sync Error", TRUE );
			return NERROR;
		}
	}
}

/*
 * Wcgetsec fetches a Ward Christensen type sector.
 * Returns sector number encountered or NERROR if valid sector not received,
 * or CAN CAN received
 * or WCEOT if eot sector
 * time is timeout for first char, set to 4 seconds thereafter
 ***************** NO ACK IS SENT IF SECTOR IS RECEIVED OK **************
 *    (Caller must do that when he is good and ready to get next sector)
 */

wcgetsec ( rxbuf, maxtime )
char *rxbuf;
int maxtime;
{
	static int checksum, wcj, firstch;
	static unsigned oldcrc;
	static char *p;
	static int sectcurr;

	for ( Lastrx = Errors = 0; Errors < RETRYMAX; ) { /* errors incr by zperr */
		if ( opabort() )
			return NERROR;

		if ( ( firstch = readline ( maxtime ) ) == STX ) {
			Blklen = KSIZE;
			goto get2;
		}

		if ( firstch == SOH ) {
			Blklen = SECSIZ;
get2:
			sectcurr = readline ( INTRATIME );

			if ( ( sectcurr + ( oldcrc = readline ( INTRATIME ) ) ) == Wcsmask ) {
				oldcrc = checksum = 0;

				for ( p = rxbuf, wcj = Blklen; --wcj >= 0; ) {
					if ( ( firstch = readline ( INTRATIME ) ) < 0 )
						goto bilge;

					oldcrc = updcrc ( firstch, oldcrc );
					checksum += ( *p++ = firstch );
				}

				if ( ( firstch = readline ( INTRATIME ) ) < 0 )
					goto bilge;

				if ( Crcflag ) {
					oldcrc = updcrc ( firstch, oldcrc );

					if ( ( firstch = readline ( INTRATIME ) ) < 0 )
						goto bilge;

					oldcrc = updcrc ( firstch, oldcrc );

					if ( oldcrc & 0xFFFF )
						zperr ( "CRC Error", TRUE );
					else {
						Firstsec = FALSE;
						return sectcurr;
					}
				} else if ( ( ( checksum - firstch ) &Wcsmask ) == 0 ) {
					Firstsec = FALSE;
					return sectcurr;
				} else
					zperr ( "Checksum error", TRUE );
			} else
				zperr ( "Block nr garbled", TRUE );
		}
		/* make sure eot really is eot and not just mixmash */
		else if ( firstch == EOT && readline ( 10 ) == TIMEOUT )
			return WCEOT;
		else if ( firstch == CAN ) {
			if ( Lastrx == CAN ) {
				zperr ( "Sender CANcelled", TRUE );
				return NERROR;
			} else {
				Lastrx = CAN;
				continue;
			}
		} else if ( firstch == TIMEOUT ) {
			if ( Firstsec ) {
				zperr ( "TIMEOUT", TRUE );
				goto humbug;
			}

bilge:
			zperr ( "TIMEOUT", TRUE );
		} else
			zperr ( "Bad header", TRUE );

humbug:
		Lastrx = 0;

		while ( readline ( 50 ) != TIMEOUT )
			if ( QuitFlag )
				return NERROR;

		if ( Firstsec ) {
			if ( Xmodem && ( Errors == RETRYMAX / 2 ) )
				Crcflag = !Crcflag;

			report ( BLKCHECK, Crcflag ? "CRC" : "Checksum" );
			mcharout ( Crcflag ? WANTCRC : NAK );
		} else {
			maxtime = 40;
			mcharout ( NAK );
		}
	}

	/* try to stop the bubble machine. */
	canit();
	return NERROR;
}

/*
 * Process incoming file information header
 */
procheader ( name )
char *name;
{
	long atol();
	static char *p, *ap, c;

	/*
	 *  Process YMODEM,ZMODEM remote file management requests
	 */

	clrreports();
	p = name + 1 + strlen ( name );

	if ( *p ) {	/* file coming from Unix or DOS system */
		ap = p;

		while ( ( c = *p ) && ( c != ' ' ) ) /* find first space or null */
			++p;

		if ( c )
			*p = '\0';

		/* ap now points to a long integer in ascii */
		report ( FILESIZE, ap );
		report ( SENDTIME, ttime ( atol ( ap ) ) );
	}

	strcpy ( Pathname, name );
	checkpath ( Pathname );

#ifdef AZTEC_C
	Fd = fopen ( Pathname, "wb" );

	if ( openerror ( Fd, Pathname, BUFIOT ) )
#else
	testexist ( Pathname );

	Fd = creat ( Pathname, 0 );

	if ( openerror ( Fd, Pathname, UBIOT ) )
#endif

		return NERROR;

	return OK;
}

/*
 * substr(string, token) searches for token in string s
 * returns pointer to token within string if found, NULL otherwise
 */
char *
substr ( s, t )
char *s, *t;
{
	static int i;

	if ( ( i = stindex ( s, t ) ) != -1 )
		return s + i;
	else
		return NULL;
}

/* send cancel string to get the other end to shut up */
canit()
{
	static char canistr[] = {
		24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 0
	};

	mstrout ( canistr, FALSE );
	purgeline();
}

clrreports()
{
	static int i;

	for ( i = 4; i < 13; i++ )
		clrline ( i );
}
/************************** END OF MODULE 8 *********************************/
