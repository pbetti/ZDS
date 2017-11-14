/************************ START OF XFER MODULE 2 ****************************/

/* sz.c By Chuck Forsberg modified for cp/m by Hal Maney */


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
extern int readock ( int, int );

/*
 * Attention string to be executed by receiver to interrupt streaming data
 *  when an error is detected.  A pause (0336) may be needed before the
 *  ^C (03) or after it. 0337 causes a break to be sent.
 */

#define SLEEP 0336

char *ltoa(), *alloc(), *grabmem();
char Myattn[] = { CTRLC, SLEEP, 0 };

unsigned Txwindow = 0;	/* Control the size of the transmitted window */
unsigned Txwspac;	      /* Spacing between zcrcq requests */
unsigned Txwcnt;	      /* Counter used to space ack requests */
int Noeofseen;
int Totsecs;		      /* total number of sectors this file */
char *Txbuf;
int Filcnt; 		      /* count of number of files opened */
unsigned Rxbuflen = 16384;	/* Receiver's max buffer length */
int Rxflags = 0;
long Bytcnt;
long Lastread;		      /* Beginning offset of last buffer read */
int Lastn;		         /* Count of last buffer read or -1 */
int Dontread;		      /* Don't read the buffer, it's still there */
long Lastsync;		      /* Last offset to which we got a ZRPOS */
int Beenhereb4;		   /* How many times we've been ZRPOS'd same place */
int Incnt;              /* count for chars not read from the Cpmbuf */

wcsend ( argc, argp )
int argc;                     /* nr of files to send */
char *argp[];                 /* list of file names */
{
	int n, status;

	slabel();
	Zctlesc = 0;
	Incnt = 0;
	Baudrate = Baudtable[Current.cbaudindex];
	Filcnt = Errors = 0;

#ifdef AZTEC_C
	Fd = 0;
#else
	Fd = -1;
#endif

	Txbuf = alloc ( KSIZE );

	if ( allocerror ( Txbuf ) )
		return NERROR;

	Cpmbuf = grabmem ( &Cpbufsize );

	if ( allocerror ( Cpmbuf ) )
		return NERROR;

	Cpindex = 0;                        /* just in case */
	Crcflag  = FALSE;
	Firstsec = TRUE;
	Bytcnt = -1;
	Rxtimeout = 600;
	savecurs();
	hidecurs();
	box();
	status = NERROR;
	report ( PROTOCOL, Xmodem ? "XMODEM Send" : Zmodem ? "ZMODEM Send" : "YMODEM Send" );

	if ( Zmodem ) {
		stohdr ( 0L );
		zshhdr ( ZRQINIT, Txhdr );

		if ( getzrxinit() == NERROR )
			goto badreturn;
	}

	for ( n = 0; n < argc; ++n ) {
		clrreports();
		Totsecs = 0;

		if ( opabort() || wcs ( argp[n] ) == NERROR )
			goto badreturn;

		tfclose();
	}

	Totsecs = 0;

	if ( Filcnt == 0 ) {	/* we couldn't open ANY files */
		canit();
		goto badreturn;
	}

	zperr ( "Complete", FALSE );

	if ( Zmodem )
		saybibi();
	else if ( !Xmodem )
		wctxpn ( "" );

	status = OK;

badreturn:
	free ( Cpmbuf );
	free ( Txbuf );
	showcurs();
	restcurs();

	if ( status == NERROR )
		tfclose();

	return status;
}

wcs ( oname )
char *oname;
{
	unsigned length;
	long flen;

	/*#ifdef AZTEC_C
		if ((Fd=fopen(oname,"rb"))==BUFIOT) {
	#else*/
	if ( ( Fd = open ( oname, 0 ) ) == UBIOT ) {
		/*#endif*/

		zperr ( "Can't open file", TRUE );
		wait ( 2 );
		return OK;	/* pass over it, there may be others */
	}

	++Noeofseen;
	Lastread = 0L;
	Lastn = -1;
	Dontread = FALSE;
	++Filcnt;
	fstat ( oname, &Fs );

	switch ( wctxpn ( oname ) ) { /* transmit path name */
		case NERROR:
			if ( Zmodem )
				canit();	/* Send CAN */

			return NERROR;

		case ZSKIP:
			return OK;
	}

	length = Fs.records;
	flen = ( long ) length * 128;

	if ( !Zmodem && wctx ( flen ) == NERROR )
		return NERROR;

	return 0;
}

/*
 * generate and transmit pathname block consisting of
 *  pathname (null terminated),
 *  file length, mode time (null) and file mode (null)
 *  in octal.
 *  N.B.: modifies the passed name, may extend it!
 */
wctxpn ( name )
char *name;
{
	static char *p;
	char buf[20];
	static unsigned length;
	static long nrbytes;

	memset ( Txbuf, '\0', KSIZE );
	length = Fs.records;
	nrbytes = ( long ) length * 128;
	report ( PATHNAME, name );
	lreport ( FILESIZE, nrbytes );
	dreport ( FBLOCKS, length );
	report ( SENDTIME, ttime ( nrbytes ) );

	if ( Xmodem )               /* xmodem, don't send path name */
		return OK;

	if ( !Zmodem ) {
		Blklen = KSIZE;

		if ( getnak() )
			return NERROR;
	}

	strcpy ( Txbuf, name );
	deldrive ( Txbuf );		/* remove drive ind if any */
	p = Txbuf + strlen ( Txbuf );
	++p;
	strcpy ( p, ltoa ( nrbytes, buf ) );

	if ( Zmodem )
		return zsendfile ( Txbuf, 1 + strlen ( p ) + ( p - Txbuf ) );

	if ( wcputsec ( Txbuf, 0, SECSIZ ) == NERROR )
		return NERROR;

	return OK;
}

/* itoa - convert n to characters in s. */
char * itoa ( short n, char * s )
{
	static short c, k;
	static char *p, *q;

	if ( ( k = n ) < 0 )	/* record sign */
		n = -n; 	/* make n positive */

	q = p = s;

	do {		/* generate digits in reverse order */
		*p++ = n % 10 + '0';  /* get next digit */
	} while ( ( n /= 10 ) > 0 );	/* delete it */

	if ( k < 0 ) *p++ = '-';

	*p = 0;

	/* reverse string in place */
	while ( q < --p ) {
		c = *q;
		*q++ = *p;
		*p = c;
	}

	return ( s );
}

/* ltoa - convert n to characters in s. */
char *ltoa ( n, s )
char s[];
long n;
{
	static long c, k;
	static char *p, *q;

	if ( ( k = n ) < 0 )	/* record sign */
		n = -n; 	/* make n positive */

	q = p = s;

	do {		/* generate digits in reverse order */
		*p++ = n % 10 + '0';  /* get next digit */
	} while ( ( n /= 10 ) > 0 );	/* delete it */

	if ( k < 0 ) *p++ = '-';

	*p = 0;

	/* reverse string in place */
	while ( q < --p ) {
		c = *q;
		*q++ = *p;
		*p = c;
	}

	return ( s );
}

getnak()
{
	static int firstch;

	Lastrx = 0;

	for ( ;; ) {
		if ( opabort() )
			return NERROR;

		switch ( firstch = readock ( 800, 1 ) ) {
			case ZPAD:
				if ( getzrxinit() )
					return NERROR;

				return FALSE;

			case TIMEOUT:
				zperr ( "Timeout on PName", TRUE );
				return TRUE;

			case WANTCRC:
				Crcflag = TRUE;

			case NAK:
				return FALSE;

			case CAN:
				if ( ( firstch = readock ( 20, 1 ) ) == CAN && Lastrx == CAN )
					return TRUE;

			default:
				break;
		}

		Lastrx = firstch;
	}

	/*report ( BLKCHECK, Crcflag ? "CRC" : "Checksum" );*/
}

wctx ( flen )
long flen;
{
	static int thisblklen, i;
	static unsigned sectnum, attempts, firstch;
	static long charssent;

	charssent = 0L;
	Firstsec = TRUE;
	thisblklen = Blklen;
	i = 0;

	while ( ( firstch = readock ( 1, 2 ) ) != NAK
		&& firstch != WANTCRC
		&& firstch != CAN
		&& !opabort()
		&& ++i < Rxtimeout )
		;

	if ( QuitFlag )
		return NERROR;

	if ( firstch == CAN ) {
		zperr ( "Rcvr CANcelled", TRUE );
		return NERROR;
	}

	if ( firstch == WANTCRC )
		Crcflag = TRUE;

	report ( BLKCHECK, Crcflag ? "CRC" : "Checksum" );
	sectnum = 0;

	for ( ;; ) {
		if ( opabort() )
			return NERROR;

		if ( flen <= ( charssent + 896L ) )
			Blklen = thisblklen = 128;

		if ( !filbuf ( Txbuf, thisblklen ) )
			break;

		purgeline();	/* ignore anything got while loading */

		if ( wcputsec ( Txbuf, ++sectnum, thisblklen ) == NERROR )
			return NERROR;

		charssent += thisblklen;
		sreport ( sectnum, charssent );
	}

	attempts = 0;

	do {
		dreport ( ERRORS, attempts );
		purgeline();
		mcharout ( EOT );
		++attempts;
	} while ( ( firstch = ( readock ( Rxtimeout, 1 ) ) != ACK )
		  && attempts < RETRYMAX
		  && !opabort() );

	if ( attempts == RETRYMAX ) {
		zperr ( "No ACK on EOT", TRUE );
		return NERROR;
	} else if ( QuitFlag ) /* from opabort */
		return NERROR;
	else
		return OK;
}

wcputsec ( buf, sectnum, cseclen )
char *buf;
int sectnum;
int cseclen;	/* data length of this sector to send */
{
	static unsigned checksum;
	static char *cp;
	static unsigned oldcrc;
	static int wcj;
	static int firstch;
	static int attempts;

	firstch = 0;	/* part of logic to detect CAN CAN */

	dreport ( ERRORS, 0 );

	for ( attempts = 0; attempts <= RETRYMAX; attempts++ ) {
		if ( opabort() )
			return NERROR;

		if ( attempts )
			dreport ( ERRORS, attempts );

		Lastrx = firstch;
		mcharout ( cseclen == KSIZE ? STX : SOH );
		mcharout ( sectnum );
		mcharout ( ~sectnum );
		oldcrc = checksum = 0;

		for ( wcj = cseclen, cp = buf; --wcj >= 0; ) {
			mcharout ( *cp );
			oldcrc = updcrc ( ( 0377 & *cp ), oldcrc );
			checksum += *cp++;
		}

		if ( Crcflag ) {
			oldcrc = updcrc ( 0, updcrc ( 0, oldcrc ) );
			mcharout ( ( int ) oldcrc >> 8 );
			mcharout ( ( int ) oldcrc );
		} else
			mcharout ( checksum );

		firstch = readock ( Rxtimeout, ( Noeofseen && sectnum ) ? 2 : 1 );
gotnak:

		switch ( firstch ) {
			case CAN:
				if ( Lastrx == CAN ) {
cancan:
					zperr ( "Rcvr CANcelled", TRUE );
					return NERROR;
				}

				break;

			case TIMEOUT:
				zperr ( "Timeout on ACK", TRUE );
				continue;

			case WANTCRC:
				if ( Firstsec )
					Crcflag = TRUE;

				report ( BLKCHECK, Crcflag ? "CRC" : "Checksum" );

			case NAK:
				zperr ( "NAK on sector", TRUE );
				continue;

			case ACK:
				Firstsec = FALSE;
				Totsecs += ( cseclen >> 7 );
				return OK;

			case NERROR:
				zperr ( "Got burst", TRUE );
				break;

			default:
				zperr ( "Bad sector ACK", TRUE );
				break;
		}

		for ( ;; ) {
			if ( opabort() )
				return NERROR;

			Lastrx = firstch;

			if ( ( firstch = readock ( Rxtimeout, 2 ) ) == TIMEOUT )
				break;

			if ( firstch == NAK || firstch == WANTCRC )
				goto gotnak;

			if ( firstch == CAN && Lastrx == CAN )
				goto cancan;
		}
	}

	zperr ( "Retry Exceeded", TRUE );
	return NERROR;
}

/* fill buf with count chars padding with ^Z for CPM */

filbuf ( buf, count )
char *buf;
int count;
{
	static int c, m;

	c = m = newload ( buf, count );

	if ( m <= 0 )
		return 0;

	while ( m < count )
		buf[m++] = CTRLZ;

	return c;
}

newload ( buf, count )
int count;
char *buf;
{
	static int j;

	j = 0;

	while ( count-- ) {
		if ( Incnt <= 0 ) {

#ifdef AZTEC_C
			Incnt = fread ( Cpmbuf, 1, Cpbufsize, Fd );
#else
			Incnt = read ( Fd, Cpmbuf, Cpbufsize );
#endif

			Cpindex = 0;

			if ( Incnt <= 0 )
				break;
		}

		buf[j++] = Cpmbuf[Cpindex++];
		--Incnt;
	}

	return ( j ? j : -1 );
}
/************************** END OF MODULE 7 *********************************/
