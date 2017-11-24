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
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>
// #include <asm/io.h>
#include "libdsk.h"
#include "cpmfs.h"
#include "Z80_par_io.h"

/* command defines */
#define Z80IO_READ	0
#define	Z80IO_WRITE	1

#define VERSION		"1.5"

/* i/o command parameters */
typedef struct
{
	byte	header[ 4 ];		/* command packet head (@IO@) */
	byte	instruction;		/* Z80IO_READ or Z80IO_WRITE (for now) */
	byte drive;			/* ! */
	word	sector;			/* ! */
	word	track;			/* ! */
}
Z80_IO_COMMAND;

static const char * cmd_header_string = "@IO@";
static const char * ftr_header_string = "@FT@";
static byte image[ MAX_SIZE ];
static int * unskew0 = 0;
static int * unskew1 = 0;

extern int do_write_sector( struct cpmSuperBlock *, Z80_IO_COMMAND *, byte *, int );
extern int do_read_sector( struct cpmSuperBlock *, Z80_IO_COMMAND *, byte *, int );
extern int do_file_transfer( Z80_IO_COMMAND * io_command );


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
		if ( write( fd, bootTracks + i, drive->secLength ) != drive->secLength )
		{
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
		for ( i = 1978, days = 0; i < 1900 + t->tm_year; ++i )
		{
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

int main( int argc, char *argv[] )        /*{{{*/
{
	char * image;
	char * imageB = 0;
	const char *format = "ZDS";
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
	Z80_IO_COMMAND io_command;
	byte * io_sector;
	char app[ 5 ];
	int ASize = 0;
	int BSize = 0;
	int dbase = 'A';
	int zeroskewA = 0;
	int zeroskewB = 0;

	fprintf( stdout, "ZDS - Z80NE Virtual Disk Server v%s\n\n", VERSION);


	while ( ( c = getopt( argc, argv, "zZb:f:F:L:n:h?" ) ) != EOF ) switch ( c )
		{
			case 'z': zeroskewA++; break;
			case 'Z': zeroskewB++; break;
			case 'b':
				{
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
			case 'n': dbase = optarg[ 0 ]; break;
			case 'h':
			case '?': usage = 1; break;
		}

	if ( optind == ( argc - 1 ) || optind == ( argc - 2 ) )
	{
		if ( optind == ( argc - 1 ) )
			image = argv[ optind ];
		else
		{
			image = argv[ optind ];
			imageB = argv[ optind + 1 ];
		}
	}
	else
		usage = 1;

	if ( usage )
	{
		fprintf( stdout, "Usage: %s [-f A:format] [-F B:format] [-b boot] [-L label] [-n base] image [image2]\n", cmd );
		exit( 1 );
	}

	drive.dev.opened = 0;
	driveB.dev.opened = 0;
	if ( format1 == 0 )
		format1 = format;

	if ( stat( image, &finfo ) )
	{

		cpmReadSuper( &drive, &root, format );

		bootTrackSize = drive.boottrk * drive.secLength * drive.sectrk;
		if ( ( bootTracks = malloc( bootTrackSize ) ) == ( void* ) 0 )
		{
			fprintf( stdout, "%s: can not allocate boot track buffer: %s\n", cmd, strerror( errno ) );
			exit( 1 );
		}
		memset( bootTracks, 0xe5, bootTrackSize );
		used = 0;
		for ( c = 0; c < 4 && boot[ c ]; ++c )
		{
			int fd;
			size_t size;

			if ( ( fd = open( boot[ c ], O_BINARY | O_RDONLY ) ) == -1 )
			{
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

		if ( mkfs( &drive, image, label, bootTracks ) == -1 )
		{
			fprintf( stdout, "%s: can not make new file system: %s\n", cmd, boo );
			exit( 1 );
		}
		else
		{
			fprintf( stdout, "Successfully created new file system: %s\n", image );
			exit( 0 );
		}
	}

	/* open image file */ /*{{{*/
	if ( ( err = Device_open( &drive.dev, image, O_RDWR, devopts ) ) )
	{
		fprintf( stdout, "%s: can not open %s (%s)\n", cmd, image, err );
		exit( 1 );
	}
	cpmReadSuper( &drive, &root, format );

	if ( imageB )
	{
		if ( ( err = Device_open( &driveB.dev, imageB, O_RDWR, devopts ) ) )
		{
			fprintf( stdout, "%s: can not open %s (%s)\n", cmd, imageB, err );
			exit( 1 );
		}
		cpmReadSuper( &driveB, &rootB, format1 );
	}
	/*}}}*/
	if (drive.skew > 0) {
		unskew0 = malloc(drive.sectrk*sizeof(int));
		for (c = 0; c < drive.sectrk; c++) {
			int sec;
			sec = drive.skewtab[c];
			unskew0[sec] = c;
		}
	}

	if (driveB.skew > 0 && imageB) {
		unskew1 = malloc(driveB.sectrk*sizeof(int));
		for (c = 0; c < driveB.sectrk; c++) {
			int sec;
			sec = driveB.skewtab[c];
			unskew1[sec] = c;
		}
	}

	/* give access to parallel port */
	if ( init_port() )
	{
		fprintf( stdout, "%s: can not open parallel port.\n", cmd );
		exit( 1 );
	}

	ASize = drive.dev.geom.dg_cylinders * drive.dev.geom.dg_sectors * drive.dev.geom.dg_secsize * drive.dev.geom.dg_heads;
	printf( "\n" );
	printf( "CP/M Disk geometry for disk %c: (%s):\n", dbase, image );
	printf( "secLength:   %d\n", drive.secLength );
	printf( "tracks:      %d\n", drive.tracks );
	printf( "sectrk:      %d\n", drive.sectrk );
	printf( "skew:        %d\n", drive.skew );
	printf( "boottrk:     %d\n", drive.boottrk);
	printf( "skewtab:    ");
	for (c = 0; c < drive.sectrk; c++) {
		printf(" %d", drive.skewtab[c]);
	}
	printf( "\n" );
	printf( "unskewtab   ");
	for (c = 0; c < drive.sectrk; c++) {
		printf(" %d", unskew0[c]);
	}
	printf( "\n" );
	printf( "Translated to:\n" );
	printf( "Heads:       %d\n", drive.dev.geom.dg_heads );
	printf( "Cylinders:   %d\n", drive.dev.geom.dg_cylinders );
	printf( "Sectors:     %d\n", drive.dev.geom.dg_sectors );
	printf( "Sector size: %d\n", drive.dev.geom.dg_secsize );
	printf( "Disk size:   %d bytes (%dkb)\n", ASize, ASize / 1024 );
	printf( "Options:     ");
	if (zeroskewA)
		printf("* Zero skew * ");
	else
		printf("None");
	printf( "\n" );
	if ( imageB )
	{
		BSize = driveB.dev.geom.dg_cylinders * driveB.dev.geom.dg_sectors * driveB.dev.geom.dg_secsize * driveB.dev.geom.dg_heads;
		printf( "\n" );
		printf( "CP/M Disk geometry for disk %c: (%s):\n", dbase + 1, imageB );
		printf( "secLength:   %d\n", driveB.secLength );
		printf( "tracks:      %d\n", driveB.tracks );
		printf( "sectrk:      %d\n", driveB.sectrk );
		printf( "skew:        %d\n", driveB.skew );
		printf( "boottrk:     %d\n", driveB.boottrk);
		printf( "skewtab:    ");
		for (c = 0; c < driveB.sectrk; c++) {
			printf(" %d", driveB.skewtab[c]);
		}
		printf( "\n" );
		printf( "unskewtab   ");
		for (c = 0; c < driveB.sectrk; c++) {
			printf(" %d", unskew1[c]);
		}
		printf( "\n" );
		printf( "Translated to:\n" );
		printf( "Heads:       %d\n", driveB.dev.geom.dg_heads );
		printf( "Cylinders:   %d\n", driveB.dev.geom.dg_cylinders );
		printf( "Sectors:     %d\n", driveB.dev.geom.dg_sectors );
		printf( "Sector size: %d\n", driveB.dev.geom.dg_secsize );
		printf( "Disk size:   %d bytes (%dkb)\n", BSize, BSize / 1024 );
		printf( "Options:     ");
		if (zeroskewB)
			printf("* Zero skew * ");
		else
			printf("None");
		printf( "\n" );
	}
	printf( "\n" );

	io_sector = ( byte * ) malloc( 4096 );

	/* gets actual status */
	showstat();

	printf( "Listening for i/o requests...\n" );

	io_command.sector = 1;

	while ( 1 )
	{	/* when this loop ends ?? */
		/* wait for command */
		if ( recv_block( ( char * ) & io_command, sizeof( Z80_IO_COMMAND ), 0 ) )
		{
			continue;
		}

		strncpy( app, ( char * ) io_command.header, 4 ); app[ 4 ] = '\0';

		/* is a command block ? */
		if ( ! strncmp( ( char * ) io_command.header, ( char * ) ftr_header_string, 4 ) )
		{		// direct file transfer ?
			do_file_transfer( &io_command );
			continue;
		}
		else if ( strncmp( ( char * ) io_command.header, ( char * ) cmd_header_string, 4 ) ) 		// disk i/o ?
			continue;	/* no */
		/* process request */
		struct cpmSuperBlock * req_drive = ( io_command.drive + 'A' - dbase ) ? &driveB : &drive;
		int * unskewp = ( io_command.drive + 'A' - dbase ) ? unskew1 : unskew0;
		int rwsec;

		if (zeroskewA && ( io_command.drive + 'A' - dbase ) == 0)		// drive A
			rwsec =  io_command.sector;
		else if (zeroskewB && ( io_command.drive + 'A' - dbase ) == 1)		// drive B
			rwsec =  io_command.sector;
		else if (req_drive->skew == 0 || io_command.track >= req_drive->boottrk) {
			rwsec =  io_command.sector;
		}
		else
			rwsec = unskewp[io_command.sector];
//		rwsec = (skewall) ? req_drive->skewtab[io_command.sector] : unskewp[io_command.sector];

		if ( io_command.instruction == Z80IO_WRITE )
		{
			printf( "SECTOR WRITE: %c: sector %d->%d, track %d\n",
					io_command.drive + 'A',
					io_command.sector,
					rwsec,
					io_command.track );
			do_write_sector( req_drive, &io_command, io_sector, rwsec );
		}
		else
		{
			printf( "SECTOR READ : %c: sector %d->%d, track %d\n",
					io_command.drive + 'A',
					io_command.sector,
					rwsec,
					io_command.track );
			do_read_sector( req_drive, &io_command, io_sector, rwsec );
		}

	}

	cpmUmount( &drive );
	exit( 0 );
}
/*}}}*/

int do_file_transfer( Z80_IO_COMMAND * io_command )
{
	char fpathbuf[ 512 ], * fpath = fpathbuf;
	byte *pb;
	int c;
	FILE *rfile;
	unsigned int size;
	int count = 0, recv = 0;
	int written = 0;
	struct stat finfo;

	// wait for file path

	if ( recv_block( fpathbuf, 255, 1 ) )
	{
		fprintf( stdout, "error while getting filename/path...\n" );
		return ( 1 );
	}

	c = *fpath;
	fpathbuf[c+1] = '\0';
	++fpath;

	size = 0;
	if ( io_command->instruction == Z80IO_READ )
	{
		if ( stat( fpath, &finfo ) )
		{
			printf( "Cannot stat %s\n", fpath );
			return ( 1 );
		}
		else
			size = finfo.st_size;
	}


	if ( size > MAX_SIZE )
	{
		printf( "Error: Your file is %d bytes, greater than acceptable: %d\n", size, MAX_SIZE );
		return ( 1 );
	}

	//open file

	if ( ( rfile = fopen( fpath, ( io_command->instruction == Z80IO_READ ) ? "r" : "w" ) ) == ( FILE * ) 0 )
	{
		printf( "Error opening %s\n", fpath );
		return ( 1 );
	}

	printf( "waiting for start...\n" ); fflush( stdout );

	if ( io_command->instruction == Z80IO_READ )
	{
		printf( "Sending %d (%04X) bytes.\n", size, size );
		pb = image;
		while ( !feof( rfile ) )
		{
			c = fgetc( rfile );
			if ( c == EOF )
				break;
			*pb++ = ( byte ) c;
		}

		verbose = 1;

		if ( send_block( image, ( pb - image ) ) )
		{
			printf( "Error transferring data!!\n\n" );
			exit( 1 );
		}

		printf( "Sent %d (%04X) bytes.\n", ( pb - image ), ( pb - image ) );
	}
	else
	{
		if ( ( count = recv_block( image, -1 , 0 ) ) < 0 )
		{
			printf( "Error receiving data!!\n" );
			return ( 1 );
		}
		recv = count;

		pb = image;
		while ( count-- )
		{
			if ( fputc( *pb++, rfile ) != EOF )
			{
				++written;
			}
		}

		printf( "Received %d (%04X) bytes.\n", recv, recv );
		printf( "Written %d (%04X) bytes.\n", written, written );
	}

	return ( 0 );
}

int do_write_sector( struct cpmSuperBlock * drive, Z80_IO_COMMAND * io_command, byte * io_sector, int rwsec )
{
	const char * err;
	int sector;

	/* get sector data from remote */
	if ( recv_block( ( char * ) io_sector, drive->dev.secLength, 1 ) )
	{
		return ( 1 );
	}

// 	sector = (unskewp && io_command->track < drive->boottrk) ? unskewp[io_command->sector] : io_command->sector;

	/* write to disk image */
	if ( ( err = Device_writeSector( &drive->dev, io_command->track, rwsec, ( const char * ) io_sector ) ) )
	{
		fprintf( stdout, "%s: can not write sector %d (%d), track %d (%s)\n",
			 cmd, io_command->sector, rwsec, io_command->track, err );
		return ( 1 );
	}

	return ( 0 );
}

int do_read_sector( struct cpmSuperBlock * drive, Z80_IO_COMMAND * io_command, byte * io_sector, int rwsec )
{
	const char * err;
	int sector;

	/* read sector from disk image */
	if ( ( err = Device_readSector( &drive->dev, io_command->track, rwsec, ( char * ) io_sector ) ) )
	{
		fprintf( stdout, "%s: can not read sector %d (%d), track %d (%s)\n",
			 cmd, io_command->sector, rwsec, io_command->track, err );
		return ( 1 );
	}

	if ( send_block( io_sector, drive->dev.secLength ) )
	{
		printf( "\nBLOCK TX ERROR\n" );
		return ( 1 );
		/* error cond */
	}

	return ( 0 );
}

