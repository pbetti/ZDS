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
/* ------------------------------------------------------------------------

vdsk_server

Implement a virtual disk server for an 8 bit (Z80) system linked
through parallel port.
The operation are made reading/writing sectors on an image file at remote
requests.
The image file itself is created and treated like a real cp/m filesystem
image thanks to cpmtools and libdisk.

Include (beatiful) code from:
- cpmtools from Michael Haardt
  http://www.moria.de/~michael/cpmtools/
- libdsk from John Elliott
  http://www.seasip.demon.co.uk/Unix/LibDsk/


/* #includes */ /*{{{C}}}*/ /*{{{*/
#include <ctype.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libdsk.h>
#include <fcntl.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <asm/io.h>
#include "config.h"
#include "cpmfs.h"
#include "Z80_par_io.h"

/* command defines */
#define Z80IO_READ	0
#define	Z80IO_WRITE	1


/* mkfs -- make file system */ /*{{{*/
static int mkfs( struct cpmSuperBlock *drive, const char *name, const char *label, char *bootTracks )
{
	/* variables */ /*{{{*/
	int i;
	char buf[ 128 ];
	char firstbuf[ 128 ];
	int fd;
	int bytes;
	int trkbytes;
	/*}}}*/

	/* open image file */ /*{{{*/
	if ( ( fd = open( name, O_BINARY | O_CREAT | O_WRONLY, 0666 ) ) < 0 )
	{
		boo = strerror( errno );
		return -1;
	}

	/*}}}*/
	/* write system tracks */ /*{{{*/
	/* this initialises only whole tracks, so it skew is not an issue */
	trkbytes = drive->secLength*drive->sectrk;
	for ( i = 0; i < trkbytes*drive->boottrk; i += drive->secLength )
		if ( write( fd, bootTracks + i, drive->secLength ) != drive->secLength ) {
			boo = strerror( errno );
			close( fd );
			return -1;
		}
	/*}}}*/
	/* write directory */ /*{{{*/
	memset( buf, 0xe5, 128 );
	bytes = drive->maxdir*32;
	if ( bytes % trkbytes ) bytes = ( ( bytes + trkbytes ) / trkbytes ) *trkbytes;
	if ( drive->type == CPMFS_P2DOS || drive->type == CPMFS_DR3 ) buf[ 3*32 ] = 0x21;
	memcpy( firstbuf, buf, 128 );
	if ( drive->type == CPMFS_DR3 )
	{
		time_t now;
		struct tm *t;
		int min, hour, days;

		firstbuf[ 0 ] = 0x20;
		for ( i = 0; i < 11 && *label; ++i, ++label ) firstbuf[ 1 + i ] = toupper( *label & 0x7f );
		while ( i < 11 ) firstbuf[ 1 + i++ ] = ' ';
		firstbuf[ 12 ] = 0x11; /* label set and first time stamp is creation date */
		memset( &firstbuf[ 13 ], 0, 1 + 2 + 8 );
		time( &now );
		t = localtime( &now );
		min = ( ( t->tm_min / 10 ) << 4 ) | ( t->tm_min % 10 );
		hour = ( ( t->tm_hour / 10 ) << 4 ) | ( t->tm_hour % 10 );
		for ( i = 1978, days = 0; i < 1900 + t->tm_year; ++i ) {
			days += 365;
			if ( i % 4 == 0 && ( i % 100 != 0 || i % 400 == 0 ) ) ++days;
		}
		days += t->tm_yday + 1;
		firstbuf[ 24 ] = firstbuf[ 28 ] = days & 0xff; firstbuf[ 25 ] = firstbuf[ 29 ] = days >> 8;
		firstbuf[ 26 ] = firstbuf[ 30 ] = hour;
		firstbuf[ 27 ] = firstbuf[ 31 ] = min;
	}
	for ( i = 0; i < bytes; i += 128 ) if ( write( fd, i == 0 ? firstbuf : buf, 128 ) != 128 )
		{
			boo = strerror( errno );
			close( fd );
			return -1;
		}
	/*}}}*/
	/* close image file */ /*{{{*/
	if ( close( fd ) == -1 )
	{
		boo = strerror( errno );
		return -1;
	}
	/*}}}*/
	return 0;
}
/*}}}*/

const char cmd[] = "vdsk_server";

int main( int argc, char *argv[] )       /*{{{*/
{
	char * image;
	char * imageB = 0;
	const char *format = "Z80DarkStar";
	const char *format1 = 0;
	int c, usage = 0;
	struct cpmSuperBlock drive;
	struct cpmInode root;
	struct cpmSuperBlock driveB;
	struct cpmInode rootB;
	const char *label = "unlabeled";
	size_t bootTrackSize, used;
	char *bootTracks;
	const char *boot[ 4 ] = {( const char* ) 0, ( const char* ) 0, ( const char* ) 0, ( const char* ) 0};
	struct stat finfo;
	const char *err;
	const char *devopts = NULL;
	byte * io_sector;
	int ASize = 0;
	int BSize = 0;
	int count = 0, rsec = 1, rtrk = 0, wsec = 1, rtrk = 0;

	while ( ( c = getopt( argc, argv, "b:f:F:L:h?" ) ) != EOF ) switch ( c ) {
				case 'b': {
					if ( boot[ 0 ] == ( const char* ) 0 ) boot[ 0 ] = optarg;
					else if ( boot[ 1 ] == ( const char* ) 0 ) boot[ 1 ] = optarg;
					else if ( boot[ 2 ] == ( const char* ) 0 ) boot[ 2 ] = optarg;
					else if ( boot[ 3 ] == ( const char* ) 0 ) boot[ 3 ] = optarg;
					else usage = 1;
					break;
				}
				case 'f': format = optarg; break;
				case 'F': format1 = optarg; break;
				case 'L': label = optarg; break;
				case 'h':
				case '?': usage = 1; break;
		}

	if ( optind == ( argc - 1 ) || optind == ( argc - 2 ) ) {
		if ( optind == ( argc - 1 ) )
			image = argv[ optind ];
		else {
			image = argv[ optind ];
			imageB = argv[ optind + 1];
		}
	}
	else
		usage = 1;

	if ( usage ) {
		fprintf( stdout, "Usage: %s [-f A:format] [-F B:format] [-b boot] [-L label] image [image2]\n", cmd );
		exit( 1 );
	}

	drive.dev.opened = 0;
	driveB.dev.opened = 0;
	if (format1 == 0)
		format1 = format;

	if ( stat( image, &finfo ) ) {

		cpmReadSuper( &drive, &root, format );

		bootTrackSize = drive.boottrk * drive.secLength * drive.sectrk;
		if ( ( bootTracks = malloc( bootTrackSize ) ) == ( void* ) 0 ) {
			fprintf( stdout, "%s: can not allocate boot track buffer: %s\n", cmd, strerror( errno ) );
			exit( 1 );
		}
		memset( bootTracks, 0xe5, bootTrackSize );
		used = 0;
		for ( c = 0; c < 4 && boot[ c ]; ++c ) {
			int fd;
			size_t size;

			if ( ( fd = open( boot[ c ], O_BINARY | O_RDONLY ) ) == -1 ) {
				fprintf( stdout, "%s: can not open %s: %s\n", cmd, boot[ c ], strerror( errno ) );
				exit( 1 );
			}
			size = read( fd, bootTracks + used, bootTrackSize - used );
#if 0
			fprintf( stdout, "%d %04x %s\n", c, used + 0x800, boot[ c ] );
#endif
			if ( size % drive.secLength ) size = ( size | ( drive.secLength - 1 ) ) + 1;
			used += size;
			close( fd );
		}

		if ( mkfs( &drive, image, label, bootTracks ) == -1 ) {
			fprintf( stdout, "%s: can not make new file system: %s\n", cmd, boo );
			exit( 1 );
		} else {
			fprintf( stdout, "Successfully created new file system: %s\n", image );
			exit( 0 );
		}
	}

	/* open image file */ /*{{{*/
	if ( ( err = Device_open( &drive.dev, image, O_RDWR, devopts ) ) ) {
		fprintf( stdout, "%s: can not open %s (%s)\n", cmd, image, err );
		exit( 1 );
	}
	cpmReadSuper( &drive, &root, format );

	if (imageB) {
		if ( ( err = Device_open( &driveB.dev, imageB, O_RDWR, devopts ) ) ) {
			fprintf( stdout, "%s: can not open %s (%s)\n", cmd, imageB, err );
			exit( 1 );
		}
		cpmReadSuper( &driveB, &rootB, format1 );
	}
	/*}}}*/
	ASize = drive.dev.geom.dg_cylinders * drive.dev.geom.dg_sectors * drive.dev.geom.dg_secsize * drive.dev.geom.dg_heads;
	printf( "\n" );
	printf( "CP/M Disk geometry for disk 1 (%s):\n", image );
	printf( "secLength:   %d\n", drive.dev.secLength );
	printf( "tracks:      %d\n", drive.dev.tracks );
	printf( "sectrk:      %d\n", drive.dev.sectrk );
	printf( "\n" );
	printf( "Translated to:\n" );
	printf( "Heads:       %d\n", drive.dev.geom.dg_heads );
	printf( "Cylinders:   %d\n", drive.dev.geom.dg_cylinders );
	printf( "Sectors:     %d\n", drive.dev.geom.dg_sectors );
	printf( "Sector size: %d\n", drive.dev.geom.dg_secsize );
	printf( "Disk size:   %d bytes (%dkb)\n", ASize, ASize / 1024 );
	printf( "\n" );
	if (imageB) {
		BSize = driveB.dev.geom.dg_cylinders * driveB.dev.geom.dg_sectors * driveB.dev.geom.dg_secsize * driveB.dev.geom.dg_heads;
		printf( "\n" );
		printf( "CP/M Disk geometry for disk 2 (%s):\n", imageB );
		printf( "secLength:   %d\n", driveB.dev.secLength );
		printf( "tracks:      %d\n", driveB.dev.tracks );
		printf( "sectrk:      %d\n", driveB.dev.sectrk );
		printf( "\n" );
		printf( "Translated to:\n" );
		printf( "Heads:       %d\n", driveB.dev.geom.dg_heads );
		printf( "Cylinders:   %d\n", driveB.dev.geom.dg_cylinders );
		printf( "Sectors:     %d\n", driveB.dev.geom.dg_sectors );
		printf( "Sector size: %d\n", driveB.dev.geom.dg_secsize );
		printf( "Disk size:   %d bytes (%dkb)\n", BSize, BSize / 1024 );
		printf( "\n" );
	}

//	io_sector = ( byte * ) malloc( drive.secLength );
	io_sector = ( byte * ) malloc( 4096 );

	count = (ASize > BSize) ? BSize : ASize;
	c = 0;
	while (c < count) {
		printf("reading trk/sec %d/%d, writing trk/sec %d/%d, count=%d\r", rtrk, rsec, wtrk, wsec, c);
		if ( ( err = Device_readSector( &drive->dev, rtrk, rsec, ( char * ) io_sector ) ) ) {
			fprintf( stdout, "%s: can not read sector %d, track %d (%s)\n",
				cmd, rtrk, rsec, err );
			cpmUmount( &drive );
			cpmUmount( &driveB );
			exit( 1 );
		}
		++rsec;
		if (rsec > drive.dev.geom.dg_sectors) {
			rsec = 1;
			++rtrk;
		}
		if ( ( err = Device_writeSector( &driveB->dev, wtrk, wsec, ( const char * ) io_sector ) ) ) {
			fprintf( stdout, "%s: can not write sector %d, track %d (%s)\n",
				cmd, wtrk, wsec, err );
			cpmUmount( &drive );
			cpmUmount( &driveB );
			exit( 1 );
		}
		++wsec;
		if (wsec > driveB.dev.geom.dg_sectors) {
			wsec = 1;
			++wtrk;
		}
	}
	printf( "\n" );

	cpmUmount( &drive );
	cpmUmount( &driveB );
	exit( 0 );
}
