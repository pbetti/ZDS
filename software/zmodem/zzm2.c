
/* ZZM.C Part 2 */

#include "zmp.h"
#include "zmodem.h"

#undef DEBUG

#ifdef   AZTEC_C
#include "libc.h"
#else
#include <stdio.h>
#endif

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

extern int readline(int);

extern long updc32();

/* Receive a binary style header (type and position) */
zrbhdr ( hdr )
char *hdr;
{
	static int c, n;
	static unsigned crc;

	if ( ( c = zdlread() ) & ~0377 )
		return c;

	Rxtype = c;
	crc = updcrc ( c, 0 );

	for ( n = 4; --n >= 0; ++hdr ) {
		if ( ( c = zdlread() ) & ~0377 )
			return c;

		crc = updcrc ( c, crc );
		*hdr = c;
	}

	if ( ( c = zdlread() ) & ~0377 )
		return c;

	crc = updcrc ( c, crc );

	if ( ( c = zdlread() ) & ~0377 )
		return c;

	crc = updcrc ( c, crc );

	if ( crc & 0xFFFF ) {
		zperr ( "Bad Header CRC", TRUE );
		return NERROR;
	}

	Zmodem = 1;

#ifdef DEBUG
	printf ( "\nReceived BINARY header type %d: ", Rxtype );

	for ( n = -4; n < 0; n++ )
		prhex ( * ( hdr + n ) );

	printf ( "\n" );
#endif

	return Rxtype;
}

/* Receive a binary style header (type and position) with 32 bit FCS */
zrb32hdr ( hdr )
char *hdr;
{
	static int c, n;
	static long crc;

	if ( ( c = zdlread() ) & ~0377 )
		return c;

	Rxtype = c;
	crc = 0xFFFFFFFFL;
	crc = updc32 ( c, crc );
#ifdef DEBUGZ
#endif

	for ( n = 4; --n >= 0; ++hdr ) {
		if ( ( c = zdlread() ) & ~0377 )
			return c;

		crc = updc32 ( c, crc );
		*hdr = c;
#ifdef DEBUGZ
#endif
	}

	for ( n = 4; --n >= 0; ) {
		if ( ( c = zdlread() ) & ~0377 )
			return c;

		crc = updc32 ( c, crc );
#ifdef DEBUGZ
#endif
	}

	if ( crc != 0xDEBB20E3 ) {
		zperr ( "Bad Header CRC", TRUE );
		return NERROR;
	}

	Zmodem = 1;

#ifdef DEBUG
	printf ( "\nReceived 32-bit FCS BINARY header type %d: ", Rxtype );

	for ( n = -4; n < 0; n++ )
		prhex ( * ( hdr + n ) );

	printf ( "\n" );
#endif

	return Rxtype;
}


/* Receive a hex style header (type and position) */
zrhhdr ( hdr )
char *hdr;
{
	static int c;
	static unsigned crc;
	static int n;

	if ( ( c = zgethex() ) < 0 )
		return c;

	Rxtype = c;
	crc = updcrc ( c, 0 );

	for ( n = 4; --n >= 0; ++hdr ) {
		if ( ( c = zgethex() ) < 0 )
			return c;

		crc = updcrc ( c, crc );
		*hdr = c;
	}

	if ( ( c = zgethex() ) < 0 )
		return c;

	crc = updcrc ( c, crc );

	if ( ( c = zgethex() ) < 0 )
		return c;

	crc = updcrc ( c, crc );

	if ( crc & 0xFFFF ) {
		zperr ( "Bad Header CRC", TRUE );
		return NERROR;
	}

	if ( readline ( INTRATIME ) == '\r' )	/* Throw away possible cr/lf */
		readline ( INTRATIME );

	Zmodem = 1;

#ifdef DEBUG
	printf ( "\nReceived HEX header type %d: ", Rxtype );

	for ( n = -4; n < 0; n++ )
		prhex ( * ( hdr + n ) );

	printf ( "\n" );
#endif

	return Rxtype;
}

/* Send a byte as two hex digits */
zputhex ( c )
int c;
{
	static char	digits[]	= "0123456789abcdef";

	xmchout ( digits[ ( c & 0xF0 ) >> 4] );
	xmchout ( digits[ ( c ) & 0xF] );
}

/*
 * Send character c with ZMODEM escape sequence encoding.
 *  Escape XON, XOFF. Escape CR following @ (Telenet net escape)
 */
zsendline ( c )
int c;
{
	static lastsent;

	switch ( c &= 0377 ) {
		case ZDLE:
			xmchout ( ZDLE );
			xmchout ( lastsent = ( c ^= 0100 ) );
			break;

		case 015:
		case 0215:
			if ( !Zctlesc && ( lastsent & 0177 ) != '@' )
				goto sendit;

		/* **** FALL THRU TO **** */
		case 020:
		case 021:
		case 023:
		case 0220:
		case 0221:
		case 0223:
			xmchout ( ZDLE );
			c ^= 0100;
sendit:
			xmchout ( lastsent = c );
			break;

		default:
			if ( Zctlesc && ! ( c & 0140 ) ) {
				xmchout ( ZDLE );
				c ^= 0100;
			}

			xmchout ( lastsent = c );
	}
}

/* Decode two lower case hex digits into an 8 bit byte value */
zgethex()
{
	int c;

	c = zgeth1();
	return c;
}
zgeth1()
{
	static int c, n;

	if ( ( c = noxrd7() ) < 0 )
		return c;

	n = c - '0';

	if ( n > 9 )
		n -= ( 'a' - ':' );

	if ( n & ~0xF )
		return NERROR;

	if ( ( c = noxrd7() ) < 0 )
		return c;

	c -= '0';

	if ( c > 9 )
		c -= ( 'a' - ':' );

	if ( c & ~0xF )
		return NERROR;

	c += ( n << 4 );
	return c;
}

/*
 * Read a byte, checking for ZMODEM escape encoding
 *  including CAN*5 which represents a quick abort
 */

zdlread()
{
	static int c;

again:

	switch ( c = readline ( Rxtimeout ) ) {
		case ZDLE:
			break;

		case 023:
		case 0223:
		case 021:
		case 0221:
			goto again;

		default:
			if ( Zctlesc && ! ( c & 0140 ) ) {
				goto again;
			}

			return c;
	}

again2:

	if ( ( c = readline ( Rxtimeout ) ) < 0 )
		return c;

	if ( c == CAN && ( c = readline ( Rxtimeout ) ) < 0 )
		return c;

	if ( c == CAN && ( c = readline ( Rxtimeout ) ) < 0 )
		return c;

	if ( c == CAN && ( c = readline ( Rxtimeout ) ) < 0 )
		return c;

	switch ( c ) {
		case CAN:
			return GOTCAN;

		case ZCRCE:
		case ZCRCG:
		case ZCRCQ:
		case ZCRCW:
			return ( c | GOTOR );

		case ZRUB0:
			return 0177;

		case ZRUB1:
			return 0377;

		case 023:
		case 0223:
		case 021:
		case 0221:
			goto again2;

		default:
			if ( Zctlesc && ! ( c & 0140 ) ) {
				goto again2;
			}

			if ( ( c & 0140 ) ==  0100 )
				return ( c ^ 0100 );

			break;
	}

	sprintf ( Buf, "Bad escape %x", c );
	zperr ( Buf, TRUE );
	return NERROR;
}

/*
 * Read a character from the modem line with timeout.
 *  Eat parity, XON and XOFF characters.
 */
noxrd7()
{
	static int c;

	for ( ;; ) {
		if ( ( c = readline ( Rxtimeout ) ) < 0 )
			return c;

		switch ( c &= 0177 ) {
			case XON:
			case XOFF:
				continue;

			default:
				if ( Zctlesc && ! ( c & 0140 ) )
					continue;

			case '\r':
			case '\n':
			case ZDLE:
				return c;
		}
	}
}

/* Store long integer pos in Txhdr */
stohdr ( pos )
long pos;
{
	Txhdr[ZP0] = pos;
	Txhdr[ZP1] = ( pos >> 8 );
	Txhdr[ZP2] = ( pos >> 16 );
	Txhdr[ZP3] = ( pos >> 24 );
}

/* Recover a long integer from a header */
long
rclhdr ( hdr )
char *hdr;
{
	static long l;

	l = ( unsigned ) ( hdr[ZP3] & 0377 );
	l = ( l << 8 ) | ( unsigned ) ( hdr[ZP2] & 0377 );
	l = ( l << 8 ) | ( unsigned ) ( hdr[ZP1] & 0377 );
	l = ( l << 8 ) | ( unsigned ) ( hdr[ZP0] & 0377 );
#ifdef DEBUG
	lreport ( FBLOCKS, l );
#endif
	return l;
}

/***************************** End of hzm2.c *********************************/
