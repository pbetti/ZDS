/***************************************************************************
 *   Copyright (C) 2005 by Piergiorgio Betti   *
 *   pbetti@lpconsul.net   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/

#include <ctype.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// #include <libdsk.h>
#include <fcntl.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/io.h>
// #include "config.h"

#include "Z80_par_io.h"

int timeout = 0;
int verbose = 0;

/* send a block of block_size chars */

int send_block( byte * buffer, int block_size )
{
	int transferred = 0;
	byte * c = (byte *) buffer;
	byte b;
	byte csum = 0;
	struct timespec ts;

//	printf("[TX START]"); if (verbose) printf("\n");

	makebdir(PAR_OUTPUT);
	setbit(CNTRP, BIT_STRB, 0);
	setbit(CNTRP, BIT_INIT, 0);

//	if (testbit(STATP, BIT_BUSY) == 1 && testbit(STATP, BIT_ACK) == 0)  {
//		printf("WARNING: Z80 ALREADY STARTED\n");
//	}
		/* send block size */
	b = (block_size & 0xff);
	if (send_byte(b)) {			/* lsb */
		return (1);
	}
	b = (block_size & 0xff00) >> 8;
	if (send_byte(b)) {			/* msb */
		return (1);
	}
	while (transferred++ < block_size ) {
		csum += *c;		/* checksum */
		if (send_byte(*c++)) {	/* tx error ? */
			return (1);
		}
		if (verbose) printf("%d\r", transferred);
	}
					/* send final checksum byte */
	csum = 0x0100 - csum;
	if (send_byte(csum)) {	/* tx error ? */
		return (1);
	}

	setbit(CNTRP, BIT_INIT, 1);	/* send EOT to Z80 */
	/* Delay for a bit */
        ts.tv_sec = 0;
        ts.tv_nsec = 50000000L;		/* 50 msec. */
        nanosleep (&ts, NULL);
		/* clean handshake */
	setbit(CNTRP, BIT_STRB, 0);
	setbit(CNTRP, BIT_INIT, 0);

//	if (verbose) printf("\n"); printf("[TX END]"); if (verbose) printf("\n");

	return(0);
}

int send_byte( byte b )
{
	int err = 0;
//	printf("clearing strobe...\n"); fflush(stdout);
	setbit( CNTRP, BIT_STRB, 1 );

	timeout = 0;
	while ( !(err = test2bit( STATP, BIT_BUSY, 1, BIT_ACK, 0 ) ) ) {	/* ready ? */
		if ( err = test2bit( STATP, BIT_BUSY, 1, BIT_ACK, 1 ) ) {	/* check for nak here */
			return (1);
		}
		++timeout;
	}
	if (err < 0) {		/* timed out */
		printf("Z80 locked on TX\n");
		return (err);
	}

	outb( b, DATAP );
	setbit( CNTRP, BIT_STRB, 0 );

	timeout = 0;
	while ( !(err = test2bit( STATP, BIT_BUSY, 0, BIT_ACK, 1 ) ) ) { /* okgo ? */
		if ( err = test2bit( STATP, BIT_BUSY, 1, BIT_ACK, 1 ) ) {	/* check for nak here */
			return (1);
		}
		++timeout;
	}
	if (err < 0) {		/* timed out */
		printf("Z80 locked on TX (2)\n");
		return (err);
	}

	return ( 0 );
}


/* receive a block of max block_size chars */

int recv_block( char * buffer, int block_size, byte tout )
{
	int started = 0, err = 0, err1 = 0;
	byte *c, rb;
	int count = 0;
	word rcv_size = 0;
	byte csum = 0;
	struct timespec ts;
	int exp_size;

	exp_size = (block_size < 0) ? MAX_SIZE : block_size;

//	printf("[RX START]"); if (verbose) printf("\n");

	exp_size += 2;	/* to get initial 2 bytes of size */

	makebdir( PAR_INPUT );
	setbit( CNTRP, BIT_STRB, 0 );
	setbit( CNTRP, BIT_INIT, 0 );

	c = ( byte * ) buffer;

	timeout = 0;
	while (err = test2bit( STATP, BIT_BUSY, 1, BIT_ACK, 1 )) {
		if (err < 0)
			return (err );
		++timeout;
	}
	err = 0;
	while ( 1 ) {
		setbit( CNTRP, BIT_STRB, 1 );

		timeout = 0;
		while ( !test2bit( STATP, BIT_BUSY, 1, BIT_ACK, 0 ) ) {
			/* TODO: need an idle management here */
			if ( err = test2bit( STATP, BIT_BUSY, 1, BIT_ACK, 1 ) ) {	/* check for stop here */
//				printf("\nrecv_block: %d bytes.\n", count);
				if (err < 0) {
					started = -1;
					break;
				}
				err = 0;

				csum = 0x0100 - csum;
				if (csum != rb) {					/* checksum error ? */
					printf("** RBLOCK: Checksum error, calc(%d), got(%d)\n", csum, rb);
					err = 1;
				}
				if (count - 3 != rcv_size && block_size >= 0) {		/* size error ? */
					printf("** RBLOCK: Block size error, recv(%d), got(%d)\n", rcv_size, count - 3 );
					err = 1;
				}
				if ( started ) {
					started = -1;
					break;
				}
			}
			if (tout) ++timeout;
		}

		if ( started < 0 )
			break;
		started = 1;

		rb = inb( DATAP );	/* get data */

		if ( count++ < exp_size ) {
			if (count == 1) {
				rcv_size = rb;
			}
			else if (count == 2) {
				rcv_size += (rb << 8) & 0xff00;
				if (block_size < 0) exp_size = rcv_size + 2;
			}
			else {
				*c++ = inb( DATAP );
				csum += rb;
			}
//			printf("I");
			if (verbose) printf("%d\r", count - 2);
		}


		setbit( CNTRP, BIT_STRB, 0 );	/* reset strobe */
		setbit( CNTRP, BIT_INIT, 1 );	/* ack to z80 */

		timeout = 0;
		while ( !(err = test2bit( STATP, BIT_BUSY, 0, BIT_ACK, 1 )) ) {
			++timeout;	/* wait for OKGO */
		}
		if (err < 0) {
			printf("RX Timeout in OKGO\n");
			started = -1;
			break;
		}
		err = 0;


		setbit( CNTRP, BIT_INIT, 0 );	/* reset ack */
	}

	makebdir(PAR_OUTPUT);		/* send result byte */
	timeout = 0;
	while (err1 = test2bit( STATP, BIT_BUSY, 1, BIT_ACK, 1 )) {
		if (err1 < 0) {
			printf("ERROR: remote locked before EOT\n");
			break;
		}
		++timeout;	/* stop clearing */
	}

//	setbit(CNTRP, BIT_STRB, 0);
//	setbit(CNTRP, BIT_INIT, 0);
// 	printf("[tx res %d]",err);
	if (err) {
		setbit(CNTRP, BIT_STRB, 1);
		setbit(CNTRP, BIT_INIT, 1);	/* send ERR to Z80 */
	}
	else {
		setbit(CNTRP, BIT_STRB, 0);
		setbit(CNTRP, BIT_INIT, 0);
	}
		/* Delay for a bit */
	ts.tv_sec = 0;
	ts.tv_nsec = 100000000L;		/* 50 msec. to aknwoledge */
	nanosleep (&ts, NULL);
//	err = send_byte(err ? 1 : 0);
//	printf("[end tx]");

	/* clean handshake */
	setbit( CNTRP, BIT_STRB, 0 );
	setbit( CNTRP, BIT_INIT, 0 );

//	 if (verbose) printf("\n"); printf("[RX END]"); if (verbose) printf("\n");

	if (block_size < 0) {
		if (err)
			return (-1);
		else
			return (count - 3);
	}
	else
		return ( err );
}

int init_port()
{
	/* give access to requested ports */
	if ( ioperm( TIMEP, 1, 1 ) < 0 ) {
		printf( "Access denied to port 0x%X\n", TIMEP );
		return ( 1 );
	}
	if ( ioperm( BASEP, 3, 1 ) < 0 ) {
		printf( "Access denied to port 0x%X (+3)\n", BASEP );
		return ( 1 );
	}
	return ( 0 );
}

void showstat()
{
	byte b;

	b = inb( DATAP );
	printf( "Data port: 0x%X (%s)\n", b, pbyte( b ) );
	b = inb( STATP );
	printf( "Status port: 0x%X (%s)\n", b, pbyte( b ) );
	b = inb( CNTRP );
	printf( "Control port: 0x%X (%s)\n", b, pbyte( b ) );
}

char * pbyte( byte b )
{
	static char mybuf[ 9 ];
	byte a;
	int i = 0;

	for ( i = 0; i < 8; i++ ) {
		a = b;
		b >>= 1;
		a &= 0x01;
		if ( a )
			mybuf[ 7 - i ] = '1';
		else
			mybuf[ 7 - i ] = '0';
	}
	mybuf[ 9 ] = '\0';

	return mybuf;
}

void makebdir( byte m )
{
	byte buf;

	if ( m ) {
		buf = inb( CNTRP );
		buf |= BIT_BDIR;	/* high bit 5 */
		outb( buf, CNTRP );
	} else {
		buf = inb( CNTRP );
		buf &= ~BIT_BDIR;	/* low bit 5 */
		outb( buf, CNTRP );
	}
}

void setbit( ZPORT port, byte bit, byte s )
{
	byte b;

	b = inb( port );
	if ( s )
		b |= bit;
	else
		b &= ~bit;
	outb( b, port );
}

byte testbit( ZPORT port, byte bit )
{
	byte b, rb;

	b = inb( port );
	rb = ( ( b & bit ) == 0 ) ? 0 : 1;
	if ( bit == BIT_BUSY && port == STATP )
		return ( !rb );
	else
		return ( rb );
}

int test2bit( ZPORT port, byte bit1, byte val1, byte bit2, byte val2 )
{
	byte b, rb1, rb2;
	int retry = STAB_COUNT;

	while (retry--) {
		b = inb( port );
		rb1 = ( ( b & bit1 ) == 0 ) ? 0 : 1;
		if ( bit1 == BIT_BUSY && port == STATP )
			rb1 = !rb1 ;
		rb2 = ( ( b & bit2 ) == 0 ) ? 0 : 1;
		if ( bit2 == BIT_BUSY && port == STATP )
			rb2 = !rb2 ;
		if (timeout > WAITLIMIT) {
			printf("\nZ80:%s bit1:%d-exp:%d, bit2:%d-exp:%d ok:%d\n",
			       pbyte(b),rb1,val1,rb2,val2,(rb1 == val1 && rb2 == val2));
			printf("TIMEOUT!!\n");
			fflush(stdout);
			return(-1);
		}
		if (!(rb1 == val1 && rb2 == val2))
			return (0);
	}

	return (1);
}

void putbyte( byte b )
{
	outb( b, DATAP );
}

byte getbyte()
{
	return (inb( DATAP ));
}
