/*
 *   Z M . C
 *    ZMODEM protocol primitives
 *    07-28-87  Chuck Forsberg Omen Technology Inc
 *
 * Entry point Functions:
 *	zsbhdr(type, hdr) send binary header
 *	zshhdr(type, hdr) send hex header
 *	zgethdr(hdr, eflag) receive header - binary or hex
 *	zsdata(buf, len, frameend) send data
 *	zrdata(buf, len) receive data
 *	stohdr(pos) store position data in Txhdr
 *	long rclhdr(hdr) recover position offset from header
 */

#ifndef CANFDX
#include "zmodem.h"
int Rxtimeout = 100;		/* Tenths of seconds to wait for something */
#endif

#ifndef UNSL
#define UNSL
#endif


/* Globals used by ZMODEM functions */
int Rxframeind;		/* ZBIN ZBIN32, or ZHEX type of frame received */
int Rxtype;		/* Type of header received */
int Rxcount;		/* Count of data bytes received */
char Rxhdr[4];		/* Received header */
char Txhdr[4];		/* Transmitted header */
long Rxpos;		/* Received file position */
long Txpos;		/* Transmitted file position */
int Txfcs32;		/* TURE means send binary frames with 32 bit FCS */
int Crc32t;		/* Display flag indicating 32 bit CRC being sent */
int Crc32;		/* Display flag indicating 32 bit CRC being received */
int Znulls;		/* Number of nulls to send at beginning of ZDATA hdr */
char Attn[ZATTNLEN + 1];	/* Attention string rx sends to tx on err */


static char *frametypes[] = {
	"Carrier Lost",		/* -3 */
	"TIMEOUT",		/* -2 */
	"ERROR",		/* -1 */
#define FTOFFSET 3
	"ZRQINIT",
	"ZRINIT",
	"ZSINIT",
	"ZACK",
	"ZFILE",
	"ZSKIP",
	"ZNAK",
	"ZABORT",
	"ZFIN",
	"ZRPOS",
	"ZDATA",
	"ZEOF",
	"ZFERR",
	"ZCRC",
	"ZCHALLENGE",
	"ZCOMPL",
	"ZCAN",
	"ZFREECNT",
	"ZCOMMAND",
	"ZSTDERR",
	"xxxxx"
#define FRTYPES 22	/* Total number of frame types in this array */
	/*  not including psuedo negative entries */
};

/* Send ZMODEM binary header hdr of type type */
zsbhdr ( type, hdr )
register char *hdr;
{
	register n;
	register unsigned short crc;

	vfile ( "zsbhdr: %s %lx", frametypes[type + FTOFFSET], rclhdr ( hdr ) );

	if ( type == ZDATA )
		for ( n = Znulls; --n >= 0; )
			zsendline ( 0 );

	xsendline ( ZPAD );
	xsendline ( ZDLE );

	if ( Crc32t = Txfcs32 )
		zsbh32 ( hdr, type );
	else {
		xsendline ( ZBIN );
		zsendline ( type );
		crc = updcrc ( type, 0 );

		for ( n = 4; --n >= 0; ++hdr ) {
			zsendline ( *hdr );
			crc = updcrc ( ( 0377 & *hdr ), crc );
		}

		crc = updcrc ( 0, updcrc ( 0, crc ) );
		zsendline ( crc >> 8 );
		zsendline ( crc );
	}

	if ( type != ZDATA )
		flushmo();
}


/* Send ZMODEM binary header hdr of type type */
zsbh32 ( hdr, type )
register char *hdr;
{
	register n;
	register UNSL long crc;

	xsendline ( ZBIN32 );
	zsendline ( type );
	crc = 0xFFFFFFFFL;
	crc = UPDC32 ( type, crc );

	for ( n = 4; --n >= 0; ++hdr ) {
		crc = UPDC32 ( ( 0377 & *hdr ), crc );
		zsendline ( *hdr );
	}

	crc = ~crc;

	for ( n = 4; --n >= 0; ) {
		zsendline ( ( int ) crc );
		crc >>= 8;
	}
}

/* Send ZMODEM HEX header hdr of type type */
zshhdr ( type, hdr )
register char *hdr;
{
	register n;
	register unsigned short crc;

	vfile ( "zshhdr: %s %lx", frametypes[type + FTOFFSET], rclhdr ( hdr ) );
	sendline ( ZPAD );
	sendline ( ZPAD );
	sendline ( ZDLE );
	sendline ( ZHEX );
	zputhex ( type );
	Crc32t = 0;

	crc = updcrc ( type, 0 );

	for ( n = 4; --n >= 0; ++hdr ) {
		zputhex ( *hdr );
		crc = updcrc ( ( 0377 & *hdr ), crc );
	}

	crc = updcrc ( 0, updcrc ( 0, crc ) );
	zputhex ( crc >> 8 );
	zputhex ( crc );

	/* Make it printable on remote machine */
	sendline ( 015 );
	sendline ( 012 );

	/*
	 * Uncork the remote in case a fake XOFF has stopped data flow
	 */
	if ( type != ZFIN && type != ZACK )
		sendline ( 021 );

	flushmo();
}

/*
 * Send binary array buf of length length, with ending ZDLE sequence frameend
 */
zsdata ( buf, length, frameend )
register char *buf;
{
	register unsigned short crc;

	vfile ( "zsdata: length=%d end=%x", length, frameend );

	if ( Crc32t )
		zsda32 ( buf, length, frameend );
	else {
		crc = 0;

		for ( ; --length >= 0; ++buf ) {
			zsendline ( *buf );
			crc = updcrc ( ( 0377 & *buf ), crc );
		}

		xsendline ( ZDLE );
		xsendline ( frameend );
		crc = updcrc ( frameend, crc );

		crc = updcrc ( 0, updcrc ( 0, crc ) );
		zsendline ( crc >> 8 );
		zsendline ( crc );
	}

	if ( frameend == ZCRCW ) {
		xsendline ( XON );
		flushmo();
	}
}

zsda32 ( buf, length, frameend )
register char *buf;
{
	register UNSL long crc;

	crc = 0xFFFFFFFFL;

	for ( ; --length >= 0; ++buf ) {
		crc = UPDC32 ( ( 0377 & *buf ), crc );
		zsendline ( *buf );
	}

	xsendline ( ZDLE );
	xsendline ( frameend );
	crc = UPDC32 ( frameend, crc );

	crc = ~crc;

	for ( length = 4; --length >= 0; ) {
		zsendline ( ( int ) crc );
		crc >>= 8;
	}
}

/*
 * Receive array buf of max length with ending ZDLE sequence
 *  and CRC.  Returns the ending character or error code.
 *  NB: On errors may store length+1 bytes!
 */
zrdata ( buf, length )
register char *buf;
{
	register c;
	register unsigned short crc;
	register char *end;
	register d;

	if ( Rxframeind == ZBIN32 )
		return zrdat32 ( buf, length );

	crc = Rxcount = 0;
	end = buf + length;

	while ( buf <= end ) {
		if ( ( c = zdlread() ) & ~0377 ) {
		crcfoo:

			switch ( c ) {
				case GOTCRCE:
				case GOTCRCG:
				case GOTCRCQ:
				case GOTCRCW:
					crc = updcrc ( ( d = c ) & 0377, crc );

					if ( ( c = zdlread() ) & ~0377 )
						goto crcfoo;

					crc = updcrc ( c, crc );

					if ( ( c = zdlread() ) & ~0377 )
						goto crcfoo;

					crc = updcrc ( c, crc );

					if ( crc & 0xFFFF ) {
						zperr ( "Bad data CRC" );
						return ERROR;
					}

					Rxcount = length - ( end - buf );
					vfile ( "zrdata: cnt = %d ret = %x", Rxcount, d );
					return d;

				case GOTCAN:
					zperr ( "Sender Canceled" );
					return ZCAN;

				case TIMEOUT:
					zperr ( "TIMEOUT" );
					return c;

				default:
					zperr ( "Bad data subpacket" );
					return c;
			}
		}

		*buf++ = c;
		crc = updcrc ( c, crc );
	}

	zperr ( "Data subpacket too long" );
	return ERROR;
}

zrdat32 ( buf, length )
register char *buf;
{
	register c;
	register UNSL long crc;
	register char *end;
	register d;

	crc = 0xFFFFFFFFL;
	Rxcount = 0;
	end = buf + length;

	while ( buf <= end ) {
		if ( ( c = zdlread() ) & ~0377 ) {
		crcfoo:

			switch ( c ) {
				case GOTCRCE:
				case GOTCRCG:
				case GOTCRCQ:
				case GOTCRCW:
					d = c;
					c &= 0377;
					crc = UPDC32 ( c, crc );

					if ( ( c = zdlread() ) & ~0377 )
						goto crcfoo;

					crc = UPDC32 ( c, crc );

					if ( ( c = zdlread() ) & ~0377 )
						goto crcfoo;

					crc = UPDC32 ( c, crc );

					if ( ( c = zdlread() ) & ~0377 )
						goto crcfoo;

					crc = UPDC32 ( c, crc );

					if ( ( c = zdlread() ) & ~0377 )
						goto crcfoo;

					crc = UPDC32 ( c, crc );

					if ( crc != 0xDEBB20E3 ) {
						zperr ( "Bad data CRC" );
						return ERROR;
					}

					Rxcount = length - ( end - buf );
					vfile ( "zrdat32: cnt = %d ret = %x", Rxcount, d );
					return d;

				case GOTCAN:
					zperr ( "Sender Canceled" );
					return ZCAN;

				case TIMEOUT:
					zperr ( "TIMEOUT" );
					return c;

				default:
					zperr ( "Bad data subpacket" );
					return c;
			}
		}

		*buf++ = c;
		crc = UPDC32 ( c, crc );
	}

	zperr ( "Data subpacket too long" );
	return ERROR;
}


/*
 * Read a ZMODEM header to hdr, either binary or hex.
 *  eflag controls local display of non zmodem characters:
 *	0:  no display
 *	1:  display printing characters only
 *	2:  display all non ZMODEM characters
 *  On success, set Zmodem to 1, set Rxpos and return type of header.
 *   Otherwise return negative on error.
 *   Return ERROR instantly if ZCRCW sequence, for fast error recovery.
 */
zgethdr ( hdr, eflag )
char *hdr;
{
	register c, n, cancount;

	n = Zrwindow + Baudrate;	/* Max bytes before start of frame */
	Rxframeind = Rxtype = 0;

startover:
	cancount = 5;
again:

	/* Return immediate ERROR if ZCRCW sequence seen */
	switch ( c = readline ( Rxtimeout ) ) {
		case RCDO:
		case TIMEOUT:
			goto fifi;

		case CAN:
		gotcan:
			if ( --cancount <= 0 ) {
				c = ZCAN;
				goto fifi;
			}

			switch ( c = readline ( 1 ) ) {
				case TIMEOUT:
					goto again;

				case ZCRCW:
					c = ERROR;

				/* **** FALL THRU TO **** */
				case RCDO:
					goto fifi;

				default:
					break;

				case CAN:
					if ( --cancount <= 0 ) {
						c = ZCAN;
						goto fifi;
					}

					goto again;
			}

		/* **** FALL THRU TO **** */
		default:
		agn2:
			if ( --n == 0 ) {
				zperr ( "Garbage count exceeded" );
				return ( ERROR );
			}

			if ( eflag && ( ( c &= 0177 ) & 0140 ) )
				bttyout ( c );
			else if ( eflag > 1 )
				bttyout ( c );

			goto startover;

		case ZPAD|0200:		/* This is what we want. */
		case ZPAD:		/* This is what we want. */
			break;
	}

	cancount = 5;
splat:

	switch ( c = noxrd7() ) {
		case ZPAD:
			goto splat;

		case RCDO:
		case TIMEOUT:
			goto fifi;

		default:
			goto agn2;

		case ZDLE:		/* This is what we want. */
			break;
	}

	switch ( c = noxrd7() ) {
		case RCDO:
		case TIMEOUT:
			goto fifi;

		case ZBIN:
			Rxframeind = ZBIN;
			Crc32 = FALSE;
			c =  zrbhdr ( hdr );
			break;

		case ZBIN32:
			Crc32 = Rxframeind = ZBIN32;
			c =  zrbhdr32 ( hdr );
			break;

		case ZHEX:
			Rxframeind = ZHEX;
			Crc32 = FALSE;
			c =  zrhhdr ( hdr );
			break;

		case CAN:
			goto gotcan;

		default:
			goto agn2;
	}

	Rxpos = hdr[ZP3] & 0377;
	Rxpos = ( Rxpos << 8 ) + ( hdr[ZP2] & 0377 );
	Rxpos = ( Rxpos << 8 ) + ( hdr[ZP1] & 0377 );
	Rxpos = ( Rxpos << 8 ) + ( hdr[ZP0] & 0377 );
fifi:

	switch ( c ) {
		case GOTCAN:
			c = ZCAN;

		/* **** FALL THRU TO **** */
		case ZNAK:
		case ZCAN:
		case ERROR:
		case TIMEOUT:
		case RCDO:
			zperr ( "Got %s", frametypes[c + FTOFFSET] );

		/* **** FALL THRU TO **** */
		default:
			if ( c >= -3 && c <= FRTYPES )
				vfile ( "zgethdr: %s %lx", frametypes[c + FTOFFSET], Rxpos );
			else
				vfile ( "zgethdr: %d %lx", c, Rxpos );
	}

	return c;
}

/* Receive a binary style header (type and position) */
zrbhdr ( hdr )
register char *hdr;
{
	register c, n;
	register unsigned short crc;

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
		zperr ( "Bad Header CRC" );
		return ERROR;
	}

	Zmodem = 1;
	return Rxtype;
}

/* Receive a binary style header (type and position) with 32 bit FCS */
zrbhdr32 ( hdr )
register char *hdr;
{
	register c, n;
	register UNSL long crc;

	if ( ( c = zdlread() ) & ~0377 )
		return c;

	Rxtype = c;
	crc = 0xFFFFFFFFL;
	crc = UPDC32 ( c, crc );
#ifdef DEBUGZ
	vfile ( "zrbhdr32 c=%X  crc=%lX", c, crc );
#endif

	for ( n = 4; --n >= 0; ++hdr ) {
		if ( ( c = zdlread() ) & ~0377 )
			return c;

		crc = UPDC32 ( c, crc );
		*hdr = c;
#ifdef DEBUGZ
		vfile ( "zrbhdr32 c=%X  crc=%lX", c, crc );
#endif
	}

	for ( n = 4; --n >= 0; ) {
		if ( ( c = zdlread() ) & ~0377 )
			return c;

		crc = UPDC32 ( c, crc );
#ifdef DEBUGZ
		vfile ( "zrbhdr32 c=%X  crc=%lX", c, crc );
#endif
	}

	if ( crc != 0xDEBB20E3 ) {
		zperr ( "Bad Header CRC" );
		return ERROR;
	}

	Zmodem = 1;
	return Rxtype;
}


/* Receive a hex style header (type and position) */
zrhhdr ( hdr )
char *hdr;
{
	register c;
	register unsigned short crc;
	register n;

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
		zperr ( "Bad Header CRC" );
		return ERROR;
	}

	if ( readline ( 1 ) == '\r' )	/* Throw away possible cr/lf */
		readline ( 1 );

	Zmodem = 1;
	return Rxtype;
}

/* Send a byte as two hex digits */
zputhex ( c )
register c;
{
	static char	digits[]	= "0123456789abcdef";

	if ( Verbose > 8 )
		vfile ( "zputhex: %02X", c );

	sendline ( digits[ ( c & 0xF0 ) >> 4] );
	sendline ( digits[ ( c ) & 0xF] );
}

/*
 * Send character c with ZMODEM escape sequence encoding.
 *  Escape XON, XOFF. Escape CR following @ (Telenet net escape)
 */
zsendline ( c )
register c;
{
	static lastsent;

	switch ( c &= 0377 ) {
		case ZDLE:
			xsendline ( ZDLE );
			xsendline ( lastsent = ( c ^= 0100 ) );
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
			xsendline ( ZDLE );
			c ^= 0100;
		sendit:
			xsendline ( lastsent = c );
			break;

		default:
			if ( Zctlesc && ! ( c & 0140 ) ) {
				xsendline ( ZDLE );
				c ^= 0100;
			}

			xsendline ( lastsent = c );
	}
}

/* Decode two lower case hex digits into an 8 bit byte value */
zgethex() {
	register c;

	c = zgeth1();

	if ( Verbose > 8 )
		vfile ( "zgethex: %02X", c );

	return c;
}
zgeth1() {
	register c, n;

	if ( ( c = noxrd7() ) < 0 )
		return c;

	n = c - '0';

	if ( n > 9 )
		n -= ( 'a' - ':' );

	if ( n & ~0xF )
		return ERROR;

	if ( ( c = noxrd7() ) < 0 )
		return c;

	c -= '0';

	if ( c > 9 )
		c -= ( 'a' - ':' );

	if ( c & ~0xF )
		return ERROR;

	c += ( n << 4 );
	return c;
}

/*
 * Read a byte, checking for ZMODEM escape encoding
 *  including CAN*5 which represents a quick abort
 */
zdlread() {
	register c;

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

	zperr ( "Bad escape sequence %x", c );
	return ERROR;
}

/*
 * Read a character from the modem line with timeout.
 *  Eat parity, XON and XOFF characters.
 */
noxrd7() {
	register c;

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
	Txhdr[ZP1] = pos >> 8;
	Txhdr[ZP2] = pos >> 16;
	Txhdr[ZP3] = pos >> 24;
}

/* Recover a long integer from a header */
long
rclhdr ( hdr )
register char *hdr;
{
	register long l;

	l = ( hdr[ZP3] & 0377 );
	l = ( l << 8 ) | ( hdr[ZP2] & 0377 );
	l = ( l << 8 ) | ( hdr[ZP1] & 0377 );
	l = ( l << 8 ) | ( hdr[ZP0] & 0377 );
	return l;
}

/* End of zm.c */
