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

#define ZPORT		unsigned long

#define BASEP		0x378
#define DATAP		BASEP
#define STATP		BASEP+1
#define CNTRP		BASEP+2
#define NUMPORTS	3
#define TIMEP		0x80

#define BIT_BDIR	0x20		/* I/O parallel port mode */
#define BIT_BUSY	0x80		/* input bit on status port */
#define BIT_ACK		0x40		/* input bit on status port */
#define BIT_STRB	0x01		/* output bit on control port */
#define BIT_INIT	0x04		/* output bit on control port */

#define PAR_OUTPUT	0x0		/* parallel as output port */
#define PAR_INPUT	0x1		/* parallel as input port */
#ifndef O_BINARY
#define O_BINARY 	0
#endif
#define WAITLIMIT	1000000
#define STAB_COUNT	20

#define	MAX_SIZE	65536		/* max image size for Z80 memory */

/* 8 bit unsigned integer */
typedef unsigned char byte;
/* 16 bit unsigned integer */
typedef unsigned short word;

/* protos */
extern char *optarg;
extern int optind, opterr, optopt;
extern char * pbyte( byte );
extern void makebdir( byte );
extern void showstat( void );
extern void setbit( ZPORT, byte, byte );
extern byte testbit( ZPORT, byte );
extern int test2bit( ZPORT, byte, byte, byte, byte );
extern int send_byte( byte );
extern int init_port();
extern int getopt( int argc, char * const *argv, const char *optstring );
extern int recv_block( char *, int, byte );
extern int send_block( byte *, int);
extern void putbyte( byte );
extern byte getbyte();

extern int timeout;
extern int verbose;
