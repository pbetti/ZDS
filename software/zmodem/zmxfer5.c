/********************** START OF XFER MODULE 5 ******************************/

#include "zmp.h"
#include "zmodem.h"

#ifdef   AZTEC_C
#include "libc.h"
#else
#include <stdio.h>
#endif

#include <string.h>
#include <ctype.h>

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

extern int opabort ( void );
extern int readline(int);
extern int roundup ( int, int );

extern int Tryzhdrtype;	   /* Header type to send corresponding to Last rx close */
extern char *Rxptr;		/* Pointer to main Rx buffer */

zperr ( string, incrflag )
char *string;
int incrflag;
{
	clrline ( MESSAGE );
	report ( MESSAGE, string );

	if ( incrflag )
		dreport ( ERRORS, ++Errors );
}

dreport ( row, value )
int row, value;
{
	static char buf[7];

	report ( row, itoa ( value, buf ) );
}

lreport ( row, value )
int row;
long value;
{
	static char buf[20];

	report ( row, ltoa ( value, buf ) );
}

sreport ( sct, bytes )
int sct;
long bytes;
{
	dreport ( BLOCKS, sct );
	lreport ( KBYTES, bytes );
}

clrline ( line )
int line;
{
	report ( line, "                " );
}

/*
 * Initialize for Zmodem receive attempt, try to activate Zmodem sender
 *  Handles ZSINIT frame
 *  Return ZFILE if Zmodem filename received, -1 on error,
 *   ZCOMPL if transaction finished,  else 0
 */
tryz()
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

rzmfile()
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
rzfile()
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
statrep ( rxbytes )
long rxbytes;
{
	lreport ( KBYTES, rxbytes );
	crcrept ( Crc32 );
}

/* Report CRC mode in use, but only if first sector */
crcrept ( flag )
int flag;
{
	if ( Firstsec )
		report ( BLKCHECK, flag ? "CRC-32" : "CRC-16" );

	Firstsec = FALSE;	/* clear the flag */
}

/* Add a block to the main buffer pointer and write to disk if full */
/* or if flag set */
putsec ( count, flag )
int count, flag;
{
	short status;
	unsigned size;

	status = 0;
	Rxptr += count;
	Cpindex += count;

	if ( ( Cpindex >= Cpbufsize ) || flag ) {
		size = ( Cpindex > Cpbufsize ) ? Cpbufsize : Cpindex;

#ifdef AZTEC_C
		status = fwrite ( Cpmbuf, 1, size, Fd );

		if ( status <= 0 )
#else
		status = write ( Fd, Cpmbuf, size );

		if ( status != size )
#endif

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
zmputs ( s )
char *s;
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
testexist ( filename )
char *filename;
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
closeit()
{
	static int status;
	int length;

	status = OK;

	if ( Cpindex ) {
		length = 128 * roundup ( Cpindex, 128 );

#ifdef AZTEC_C
		status = fwrite ( Cpmbuf, length, 1, Fd ) ? OK : NERROR;
#else
		status = ( ( write ( Fd, Cpmbuf, length ) == length ) ? OK : NERROR );
#endif

		Cpindex = 0;
		Rxptr = Cpmbuf;
	}

	if ( status == NERROR )
		zperr ( "Disk write error", TRUE );

	/*#ifdef AZTEC_C
		if (fclose(Fd)==NERROR) {
			Fd = 0;
	#else*/
	if ( close ( Fd ) == NERROR ) {
		Fd = -1;
		/*#endif*/

		zperr ( "File close error", TRUE );
		return NERROR;
	}

	return status;
}

/*
 * Ack a ZFIN packet, let byegones be byegones
 */

ackbibi()
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

long
atol ( string )
char *string;
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

rlabel() /*print receive mode labels on the 25th line*/
{
	putlabel ( "RECEIVE FILE Mode:  Press ESC to Abort..." );
}

/************************** END OF MODULE 5 *********************************/
