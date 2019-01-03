/********************** START OF XFER MODULE 5 ******************************/

#include "zmp.h"
#include "zmodem.h"

#include <stdio.h>

#include <string.h>
#include <ctype.h>

#include "zmxfer.h"

extern int opabort ( void );
extern int readline(int);
extern int roundup ( int, int );

extern int Tryzhdrtype;	   /* Header type to send corresponding to Last rx close */
extern char *Rxptr;		/* Pointer to main Rx buffer */

void zperr ( char * string, int incrflag )
{
	clrline ( MESSAGE );
	report ( MESSAGE, string );

	if ( incrflag )
		dreport ( ERRORS, ++Errors );
}

void dreport ( int row, int value )
{
	static char buf[7];

	report ( row, itoa ( value, buf ) );
}

void lreport ( int row, long value )
{
	static char buf[20];

	report ( row, ltoa ( value, buf ) );
}

void sreport ( int sct, long bytes )
{
	dreport ( BLOCKS, sct );
	lreport ( KBYTES, bytes );
}

void clrline ( int line )
{
	report ( line, "                " );
}

/*
 * Initialize for Zmodem receive attempt, try to activate Zmodem sender
 *  Handles ZSINIT frame
 *  Return ZFILE if Zmodem filename received, -1 on error,
 *   ZCOMPL if transaction finished,  else 0
 */
int tryz()
{
	static int c, n, *ip;
	static int cmdzack1flg;

	if ( Nozmodem )		/* ymodem has been forced */
		return 0;

	for ( n = Zmodem ? 15 : 5; --n >= 0; ) {
		if ( opabort() )
			return NERROR;

		/* Set buffer length (0) and capability flags */
		stohdr ( 0L );
		Txhdr[ZF0] = ( Wantfcs32 ? CANFC32 : 0 ) | CANFDX;

		if ( Zctlesc )
			Txhdr[ZF0] |= TESCCTL;

		ip = ( int * ) &Txhdr[ZP0];
		*ip = Cpbufsize;
		zshhdr ( Tryzhdrtype, Txhdr );

		if ( Tryzhdrtype == ZSKIP )	/* Don't skip too far */
			Tryzhdrtype = ZRINIT;	/* CAF 8-21-87 */

again:

		switch ( zgethdr ( Rxhdr, 0 ) ) {
			case ZRQINIT:
				continue;

			case ZEOF:
				continue;

			case TIMEOUT:
				continue;

			case ZFILE:
				Zconv = Rxhdr[ZF0];
				Zmanag = Rxhdr[ZF1];
				Ztrans = Rxhdr[ZF2];
				Tryzhdrtype = ZRINIT;
				c = zrdata ( Secbuf, KSIZE );

				if ( c == GOTCRCW )
					return ZFILE;

				zshhdr ( ZNAK, Txhdr );
				goto again;

			case ZSINIT:
				Zctlesc = TESCCTL & Rxhdr[ZF0];

				if ( zrdata ( Attn, ZATTNLEN ) == GOTCRCW ) {
					zshhdr ( ZACK, Txhdr );
					goto again;
				}

				zshhdr ( ZNAK, Txhdr );
				goto again;

			case ZFREECNT:
				stohdr ( 0L );
				zshhdr ( ZACK, Txhdr );
				goto again;

			case ZCOMMAND:
				cmdzack1flg = Rxhdr[ZF0];

				if ( zrdata ( Secbuf, KSIZE ) == GOTCRCW ) {
					stohdr ( 0L );
					purgeline();	/* dump impatient questions */

					do {
						zshhdr ( ZCOMPL, Txhdr );
						zperr ( "Waiting for ZFIN", FALSE );

						if ( opabort() )
							return NERROR;
					} while ( ++Errors < 20 && zgethdr ( Rxhdr, 1 ) != ZFIN );

					ackbibi();
					return ZCOMPL;
				}

				zshhdr ( ZNAK, Txhdr );
				goto again;

			case ZCOMPL:
				goto again;

			default:
				continue;

			case ZFIN:
				ackbibi();
				return ZCOMPL;

			case ZCAN:
				return NERROR;
		}
	}

	return 0;
}

/*
 * Receive 1 or more files with ZMODEM protocol
 */

int rzmfile()
{
	static int c;

	for ( ;; ) {
		if ( opabort() )
			return NERROR;

		switch ( c = rzfile() ) {
			case ZEOF:
			case ZSKIP:
				switch ( tryz() ) {
					case ZCOMPL:
						return OK;

					default:
						return NERROR;

					case ZFILE:
						break;
				}

				continue;

			default:
				return c;

			case NERROR:
				return NERROR;
		}
	}
}

/*
 * Receive a file with ZMODEM protocol
 *  Assumes file name frame is in Secbuf
 */
int rzfile()
{
	static int c, n;
	static unsigned bufleft;
	static long rxbytes;

	Eofseen = FALSE;

	if ( procheader ( Secbuf ) == NERROR ) {
		return ( Tryzhdrtype = ZSKIP );
	}

	n = 20;
	rxbytes = 0L;
	Firstsec = TRUE;

	for ( ;; ) {
		if ( opabort() )
			return NERROR;

		stohdr ( rxbytes );
		zshhdr ( ZRPOS, Txhdr );
nxthdr:

		if ( opabort() )
			return NERROR;

		switch ( c = zgethdr ( Rxhdr, 0 ) ) {

			default:
				return NERROR;

			case ZNAK:
			case TIMEOUT:
				if ( --n < 0 ) {
					return NERROR;
				}

			case ZFILE:
				zrdata ( Secbuf, KSIZE );
				continue;

			case ZEOF:
				if ( rclhdr ( Rxhdr ) != rxbytes ) {
					/*
					 * Ignore eof if it's at wrong place - force
					 *  a timeout because the eof might have gone
					 *  out before we sent our zrpos.
					 */
					Errors = 0;
					goto nxthdr;
				}

				if ( closeit() ) {
					Tryzhdrtype = ZFERR;
					return NERROR;
				}

				lreport ( KBYTES, rxbytes );
				crcrept ( Crc32 );
				return c;

			case NERROR:	/* Too much garbage in header search error */
				if ( --n < 0 ) {
					return NERROR;
				}

				zmputs ( Attn );
				continue;

			case ZDATA:
				if ( rclhdr ( Rxhdr ) != rxbytes ) {
					if ( --n < 0 ) {
						return NERROR;
					}

					zmputs ( Attn );
					continue;
				}

moredata:

				if ( opabort() )
					return NERROR;

				bufleft = Cpbufsize - Cpindex;
				c = zrdata ( Rxptr,
					     ( bufleft > KSIZE ) ? KSIZE : bufleft );

				switch ( c ) {

					case ZCAN:
						return NERROR;

					case NERROR:	/* CRC error */
						statrep ( rxbytes );

						if ( --n < 0 ) {
							return NERROR;
						}

						zmputs ( Attn );
						continue;

					case TIMEOUT:
						statrep ( rxbytes );

						if ( --n < 0 ) {
							return NERROR;
						}

						continue;

					case GOTCRCW:
						n = 20;

						if ( putsec ( Rxcount, TRUE ) == NERROR )
							return NERROR; /* Write to disk! */

						rxbytes += Rxcount;
						stohdr ( rxbytes );
						statrep ( rxbytes );
						zshhdr ( ZACK, Txhdr );
						mcharout ( XON );
						goto nxthdr;

					case GOTCRCQ:
						n = 20;

						if ( putsec ( Rxcount, TRUE ) == NERROR )
							return NERROR; /* Write to disk! */

						rxbytes += Rxcount;
						stohdr ( rxbytes );
						zshhdr ( ZACK, Txhdr );
						goto moredata;

					case GOTCRCG:
						n = 20;

						if ( putsec ( Rxcount, FALSE ) == NERROR )
							return NERROR; /* Don't write to disk */

						rxbytes += Rxcount;
						goto moredata;

					case GOTCRCE:
						n = 20;

						if ( putsec ( Rxcount, FALSE ) == NERROR )
							return NERROR; /* Don't write to disk */

						rxbytes += Rxcount;
						goto nxthdr;
				}
		}
	}
}

/* Status report: don't do unless after error or ZCRCW since characters */
/*	will be lost unless rx has interrupt-driven I/O			*/
void statrep ( long rxbytes )
{
	lreport ( KBYTES, rxbytes );
	crcrept ( Crc32 );
}

/* Report CRC mode in use, but only if first sector */
void crcrept ( int flag )
{
	if ( Firstsec )
		report ( BLKCHECK, flag ? "CRC-32" : "CRC-16" );

	Firstsec = FALSE;	/* clear the flag */
}

/* Add a block to the main buffer pointer and write to disk if full */
/* or if flag set */
int putsec ( int count, int flag )
{
	short status;
	unsigned size;

	status = 0;
	Rxptr += count;
	Cpindex += count;

	if ( ( Cpindex >= Cpbufsize ) || flag ) {
		size = ( Cpindex > Cpbufsize ) ? Cpbufsize : Cpindex;

		status = write ( Fd, Cpmbuf, size );

		if ( status != size )
		{
			zperr ( "Disk write error", TRUE );
			status = NERROR;
		}

		Cpindex = 0;
		Rxptr = Cpmbuf;
	}

	return status;
}

/*
 * Send a string to the modem, processing for \336 (sleep 1 sec)
 *   and \335 (break signal)
 */
int zmputs ( char * s )
{
	static int c;

	while ( *s ) {
		if ( opabort() )
			return NERROR;

		switch ( c = *s++ ) {
			case '\336':
				wait ( 1 );
				continue;

			case '\335':
				sendbrk();
				continue;

			default:
				mcharout ( c );
		}
	}
}

/* Test if file exists, rename to .BAK if so */
void testexist ( char * filename )
{
	int fd;
	char *p, newfile[20], *index();

	if ( ( fd = open ( filename, 0 ) ) != UBIOT ) {
		close ( fd );
		strcpy ( newfile, filename );

		if ( p = index ( newfile, '.' ) )
			* p = '\0';	/* stop at dot */

		strcat ( newfile, ".bak" );
		unlink ( newfile );	/* remove any .bak already there */
		rename ( filename, newfile );
	}
}

/*
 * Close the receive dataset, return OK or NERROR
 */
int closeit()
{
	static int status;
	int length;

	status = OK;

	if ( Cpindex ) {
		length = 128 * roundup ( Cpindex, 128 );

		status = ( ( write ( Fd, Cpmbuf, length ) == length ) ? OK : NERROR );

		Cpindex = 0;
		Rxptr = Cpmbuf;
	}

	if ( status == NERROR )
		zperr ( "Disk write error", TRUE );

	if ( close ( Fd ) == NERROR ) {
		Fd = -1;

		zperr ( "File close error", TRUE );
		return NERROR;
	}

	return status;
}

/*
 * Ack a ZFIN packet, let byegones be byegones
 */

void ackbibi()
{
	static int n;

	stohdr ( 0L );

	for ( n = 3; --n >= 0; ) {
		purgeline();
		zshhdr ( ZFIN, Txhdr );

		switch ( readline ( 100 ) ) {
			case 'O':
				readline ( INTRATIME );	/* Discard 2nd 'O' */
				return;

			case RCDO:
				return;

			case TIMEOUT:
			default:
				break;
		}
	}
}

long atol ( char * string )
{
	static long value, lv;
	static char *p;

	value = 0L;
	p = string + strlen ( string );  /* end of string */

	while ( !isdigit ( *p ) )
		p--;

	for ( lv = 1L; isdigit ( *p ) && p >= string; lv *= 10 )
		value += ( ( *p-- ) - '0' ) * lv;

	return value;
}

void rlabel() /*print receive mode labels on the 25th line*/
{
	putlabel ( "RECEIVE FILE Mode:  Press ESC to Abort..." );
}

/************************** END OF MODULE 5 *********************************/
