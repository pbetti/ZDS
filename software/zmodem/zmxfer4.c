/********************** START OF XFER MODULE 4 ******************************/

/* rz.c By Chuck Forsberg modified for cp/m by Hal Maney */

#include "zmp.h"
#include "zmodem.h"

#include <stdio.h>

#include <string.h>

#include "zmxfer.h"

extern void * cpm_malloc ( size_t );
extern void cpm_free(void *);
extern int allocerror ( char * );
extern int opabort ( void );
extern int readline(int);
extern int openerror ( int, char *, int );
extern char *grabmem ( unsigned * );

int Tryzhdrtype;	   /* Header type to send corresponding to Last rx close */
char *Rxptr;


int wcreceive ( char * filename )
{
	static int c;
	char fname[20];

	putlabel ( "RECEIVE FILE Mode:  Press ESC to Abort..." ); 
	QuitFlag = FALSE;
	Zctlesc = 0;
	Baudrate = Baudtable[Current.cbaudindex];
	Tryzhdrtype = ZRINIT;
	fname[0] = '\0';
	
	
	Secbuf = cpm_malloc ( KSIZE + 1 );

	if ( allocerror ( Secbuf ) ) {
		return NERROR;
	}

	Cpmbuf = grabmem ( &Cpbufsize );

	if ( allocerror ( Cpmbuf ) ) {
		return NERROR;
	}

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
		strcpy ( fname, filename );
		checkpath ( fname );

		testexist ( fname );

		Fd = creat ( fname, 0 );

		if ( openerror ( Fd, fname, UBIOT ) )

			goto fubar1;

		if ( wcrx() == NERROR )               /* xmodem */
			goto fubar;
	}

good:
	cpm_free ( Cpmbuf );
	cpm_free ( Secbuf );
	showcurs();
	restcurs();
	return OK;

fubar:
	canit();

	if ( Fd >= 0 && fname[0] != 0) {
		close(Fd);
		unlink ( fname );	/* File incomplete: erase it */
	}
		
fubar1:
	cpm_free ( Cpmbuf );
	cpm_free ( Secbuf );
	showcurs();
	restcurs();
	return NERROR;
}

/*
 * Fetch a pathname from the other end as a C ctyle ASCIZ string.
 * Length is indeterminate as long as less than Blklen
 * A null string represents no more files (YMODEM)
 */

int wcrxpn ( char * rpn )
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

int wcrx()
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
	Wcsmask = 0xff;

	for ( ;; ) {
		if ( opabort() )
			return NERROR;

		printf("sendchar=%d %x\n",sendchar,sendchar);
		
		mcharout ( sendchar );	         /* send it now, we're ready! */
		sectcurr = wcgetsec ( Rxptr, Firstsec || ( sectnum & 0177 ) ? 50 : 130 );

		if ( sectcurr == ( sectnum + 1 & Wcsmask ) ) {
			charsgot += Blklen;
			sreport ( ++sectnum, charsgot );
			cblklen = Blklen;
			printf("sectcurr=%d charsgot=%d cblklen=%d\n",sectcurr,charsgot,cblklen);
			
			if ( putsec ( cblklen, FALSE ) == NERROR ) {
				printf("putsec bad\n");
				
				return NERROR;
			}

			sendchar = ACK;
		} else if ( sectcurr == ( sectnum & Wcsmask ) ) {
			zperr ( "Duplicate Sector", TRUE );
			sendchar = ACK;
		} else if ( sectcurr == WCEOT ) {
			printf("EOT\n");
			
			if ( closeit() )
				return NERROR;

			mcharout ( ACK );
			return OK;
		} else if ( sectcurr == NERROR ) {
			printf("NERROR\n");
			return NERROR;
		}
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

int wcgetsec ( char * rxbuf, int maxtime )
{
	static int checksum, wcj, firstch;
	static unsigned oldcrc;
	static char *p;
	static int sectcurr;

	for ( Lastrx = Errors = 0; Errors < RETRYMAX; ) { /* errors incr by zperr */
		if ( opabort() )
			return NERROR;

		firstch = readline ( maxtime );
		
		if ( firstch == STX || firstch == SOH) {

			Blklen = (firstch == STX) ? KSIZE : SECSIZ;
			sectcurr = readline ( INTRATIME );			
			oldcrc = readline ( INTRATIME );
			
			if ( ( sectcurr + oldcrc ) == Wcsmask ) {
				printf("sectcurr = %x %x %x\n", firstch, sectcurr, oldcrc);
				oldcrc = checksum = 0;

				for ( p = rxbuf, wcj = Blklen; --wcj >= 0; ) {
					if ( ( firstch = readline ( INTRATIME ) ) < 0 ) {
						printf("firstch 1 = %d\n", firstch);
						goto bilge;
					}

					oldcrc = updcrc ( firstch, oldcrc );
					checksum += ( *p++ = firstch );
				}

				if ( ( firstch = readline ( INTRATIME ) ) < 0 )
					goto bilge;

				if ( Crcflag ) {
					oldcrc = updcrc ( firstch, oldcrc );

					if ( ( firstch = readline ( INTRATIME ) ) < 0 ) {
						printf("firstch 2 = %d\n", firstch);
						goto bilge;
					}
					
					oldcrc = updcrc ( firstch, oldcrc );

					if ( oldcrc & 0xFFFF )
						zperr ( "CRC Error", TRUE );
					else {
						Firstsec = FALSE;
						printf("first false\n");
						return sectcurr;
					}
				} else if ( ( ( checksum - firstch ) &Wcsmask ) == 0 ) {
					printf("checksum ret\n");
					Firstsec = FALSE;
					return sectcurr;
				} else
					zperr ( "Checksum error", TRUE );
			} else
				zperr ( "Block nr garbled", TRUE );
		}
		/* make sure eot really is eot and not just mixmash */
		else if ( firstch == EOT && readline ( 10 ) == TIMEOUT ) {
			printf("eot\n");
			return WCEOT;
		}
		else if ( firstch == CAN ) {
			printf("firstch 3 = %d\n", firstch);
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
int procheader ( char * name )
{
	long atol();
	static char *p, *ap, c;
	char filename[20];

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

	strcpy ( filename, name );
	checkpath ( filename );

	testexist ( filename );

	Fd = creat ( filename, 0 );

	if ( openerror ( Fd, filename, UBIOT ) )

		return NERROR;

	return OK;
}

/*
 * substr(string, token) searches for token in string s
 * returns pointer to token within string if found, NULL otherwise
 */
char * substr ( char * s, char * t )
{
	static int i;

	if ( ( i = stindex ( s, t ) ) != -1 )
		return s + i;
	else
		return NULL;
}

/* send cancel string to get the other end to shut up */
void canit()
{
	static char canistr[] = {
		24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 0
	};

	mstrout ( canistr, FALSE );
	purgeline();
}

void clrreports()
{
	static int i;

	for ( i = 4; i < 13; i++ )
		clrline ( i );
}
/************************** END OF MODULE 8 *********************************/
