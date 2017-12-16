/***************************************************************************
*   Copyright (C) 2005 by Piergiorgio Betti   *
*   pbetti@lpconsul.eu   *
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

	1.5	2017/11/20
		Added colored output and rewrite make system for cmake
	1.6	2017/11/29
		Added DMK support

   ---------------------------------------------------------------------- */

/*

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
- libdmk from Eric Smith 2002
  http://dmklib.brouhaha.com/

*/

#define VERSION		"1.6"


#include <ctype.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <assert.h>

// #include <asm/io.h>
#include "libdsk.h"
#include "cpmfs.h"
#include "Z80_par_io.h"
#include "libdmk.h"

/* command defines */
#define Z80IO_READ	0
#define	Z80IO_WRITE	1


// Black       0;30     Dark Gray     1;30
// Blue        0;34     Light Blue    1;34
// Green       0;32     Light Green   1;32
// Cyan        0;36     Light Cyan    1;36
// Red         0;31     Light Red     1;31
// Purple      0;35     Light Purple  1;35
// Brown       0;33     Yellow        1;33
// Light Gray  0;37     White         1;37

#define col_cyan	"\33[0;36m"
#define col_red		"\33[0;31m"
#define col_green	"\33[0;32m"
#define col_rset	"\33[0m"
#define col_purple	"\33[0;35m"
#define col_hred	"\33[1;31m"
#define col_hpurple	"\33[1;35m"
#define col_yellow	"\33[1;33m"


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
static byte transbuf[ MAX_SIZE ];
static int * unskew0 = 0;
static int * unskew1 = 0;
static char * image;
static char * imageB = 0;
static const char *format = "ZDS";
static const char *format1 = 0;
static struct cpmSuperBlock drive;
static struct cpmInode root;
static struct cpmSuperBlock driveB;
static struct cpmInode rootB;
static const char *label = "unlabeled";
static size_t bootTrackSize, used;
static char *bootTracks;
static const char *boot[ 4 ] = {( const char* ) 0, ( const char* ) 0, ( const char* ) 0, ( const char* ) 0};
static struct stat finfo;
static const char *err;
static const char *devopts = NULL;
static Z80_IO_COMMAND io_command;
static byte * io_sector;
static char app[ 5 ];
static int ASize = 0;
static int BSize = 0;
static int dbase = 'A';
static int zeroskewA = 0;
static int zeroskewB = 0;
static int docreate = 0;
static int dmkmode = 0;
static int dumpsec = 0;
static char * dparm = 0;
static dmk_drive_t dmkdrive;

extern int	do_write_sector( struct cpmSuperBlock *, Z80_IO_COMMAND *, byte *, int );
extern int	do_read_sector( struct cpmSuperBlock *, Z80_IO_COMMAND *, byte *, int );
extern int	do_file_transfer( Z80_IO_COMMAND * io_command );
extern void	eprintf(const char* format, ...);
extern int	mkfs( struct cpmSuperBlock *, const char *, const char *, char * );
extern void	cpm_create();
extern void	dmk_create();
extern char **	str_split(char *, const char);
extern void	dparm_error();
extern void	dmk_initialize();
extern void	print_sector_info (sector_info_t *sector_info);
extern void	hex_dump(void *, int);


const char myexe[] = "vdsk_server";

int main( int argc, char *argv[] )
{
	int c, usage = 0;

	printf( "%sZDS - Z80NE Virtual Disk Server v%s%s\n\n", col_cyan, VERSION, col_rset);


	while ( ( c = getopt( argc, argv, "uDczZp:b:f:F:L:n:h?" ) ) != EOF )
		switch ( c )
		{
			case 'u': dumpsec++; break;
			case 'z': zeroskewA++; break;
			case 'Z': zeroskewB++; break;
			case 'c': docreate++; break;
			case 'D': dmkmode++; break;
			case 'h':
			case '?': usage = 1; break;
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
			case 'p': dparm = optarg; break;
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
		printf( "%sUsage: %s [-zZ] [-f A:format] [-F B:format] [-b boot] [-L label] [-n base] image [image2]%s\n\n", col_hpurple, myexe, col_rset );
		printf( "%sOptions:\n", col_purple);
		printf( "-z		No skew for drive A:\n");
		printf( "-Z		No skew for drive B:\n");
		printf( "-c		Create image for for drive A: if not exist\n");
		printf( "-L <label>	Label drive A: if not exist (CP/M only)\n");
		printf( "-b <fname>	Up to four code files to initialize boot tracks (CP/M only)\n");
		printf( "-f <type>	Diskdefs type for drive A:\n");
		printf( "-F <type>	Diskdefs type for drive B:\n");
		printf( "-n <X>		Drive id remap base X: (CP/M only)\n");
		printf( "-h		Usage help (this)\n");
		printf( "-u		Dump sectors during transfer\n");
		printf( "-D		DMK mode for non CP/M images (NE-DOS/TRS-DOS/other)\n");
		printf( "-p <d:h:t:s:z:k>\n");
		printf( "		Disk parameters for DMK create density:heads:tracks:sectors:sec. size:skew factor\n");
		printf( "		where:\n");
		printf( "		d	0 = FM, 1 = MFM\n");
		printf( "		h	1 = SS, 2 = DS\n");
		printf( "		t	# of tracks per side\n");
		printf( "		s	# of sectors per track\n");
		printf( "		z	Sector size in bytes 128/256/512\n");
		printf( "		k	skew factor\n");
		printf( "%s\n\n", col_rset);
		exit( 1 );
	}

	if (dmkmode) {
		printf("%s* DMK mode *%s\n\n", col_purple, col_rset);
		if (imageB) {
			printf("%sOnly image for drive A: handled in DMK mode. Ignoring B:%s\n", col_yellow, col_rset);
		}
		imageB = 0;
	}

	drive.dev.opened = 0;
	driveB.dev.opened = 0;
	if ( format1 == 0 )
		format1 = format;

	if ( stat( image, &finfo ) )
	{
		if ( !docreate ) {
			eprintf( "Disk image: \"%s\" does not exist. Specify -c to create new one.\n\n", image);
			exit(1);
		}

		if (!dmkmode)
			cpm_create();
		else
			dmk_create();
	}
	else if (docreate) {
		eprintf ("Create options specified but image already exists\n\n");
		exit(1);
	}

	/* give access to parallel port */
	if ( init_port() )
	{
		eprintf( "%s: can not open parallel port. You must be root to run vdsk_server...\n", myexe );
		exit( 1 );
	}


	// Open file, init drives

	if (dmkmode) {
		dmk_initialize();
	}
	else {
		/* open image file */
		if ( ( err = Device_open( &drive.dev, image, O_RDWR, devopts ) ) )
		{
			eprintf( "%s: can not open %s (%s)\n", myexe, image, err );
			exit( 1 );
		}
		cpmReadSuper( &drive, &root, format );

		if ( imageB )
		{
			if ( ( err = Device_open( &driveB.dev, imageB, O_RDWR, devopts ) ) )
			{
				eprintf( "%s: can not open %s (%s)\n", myexe, imageB, err );
				exit( 1 );
			}
			cpmReadSuper( &driveB, &rootB, format1 );
		}

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

	}

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
		int * unskewp = ( io_command.drive + 'A' - dbase ) ? unskew1 : unskew0;
		struct cpmSuperBlock * req_drive = ( io_command.drive + 'A' - dbase ) ? &driveB : &drive;
		int rwsec;

		if (dmkmode) {
			if (zeroskewA || dmkdrive.skew == 0 /*|| io_command.track >= req_drive->boottrk*/) {
				rwsec = dmkdrive.sector_index [dmkdrive.sector_info [io_command.sector].sector];
			}
			else
				rwsec = dmkdrive.sector_info[io_command.sector].sector;
		}
		else {
			if (zeroskewA && ( io_command.drive + 'A' - dbase ) == 0)		// drive A
				rwsec =  io_command.sector;
			else if (zeroskewB && ( io_command.drive + 'A' - dbase ) == 1)		// drive B
				rwsec =  io_command.sector;
			else if (req_drive->skew == 0 || io_command.track >= req_drive->boottrk) {
				rwsec =  io_command.sector;
			}
			else
				rwsec = unskewp[io_command.sector];
		}

		if ( io_command.instruction == Z80IO_WRITE ) {
			printf( "%sSECTOR WRITE%s: %c: sector %d->%d, track %d\n",
					col_red,
					col_rset,
					io_command.drive + 'A',
					io_command.sector,
					rwsec,
					io_command.track );
			do_write_sector( req_drive, &io_command, io_sector, rwsec );
		}
		else {
			printf( "%sSECTOR READ%s : %c: sector %d->%d, track %d\n",
					col_green,
					col_rset,
					io_command.drive + 'A',
					io_command.sector,
					rwsec,
					io_command.track );
			do_read_sector( req_drive, &io_command, io_sector, rwsec );
		}
	}

	if (!dmkmode) {
		cpmUmount( &drive );
		if (imageB) cpmUmount( &driveB );
	}
	else
		dmk_close_image (dmkdrive.h);

	// Job Done!!
	exit( 0 );
}

void dmk_initialize()
{
	dmk_handle h;

	int ds, dd;
	int cylinders;
	int sector_count;
	int min_sector, max_sector;

	int cylinder, head, sector;
	sector_info_t * sector_info = 0;
	int * sector_index = 0;
	int fake_mfm = 0;

	byte buf [1024];

	int i;

	sector_info = malloc(DMK_MAX_SECTOR * sizeof(sector_info_t));
	sector_index = malloc(256 * sizeof(int));

	h = dmk_open_image (image, 1, & ds, & cylinders, & dd);
	if (! h) {
		eprintf ("Error opening input DMK file %s\n", image);
		exit (1);
	}

	for (cylinder = 0; cylinder < cylinders; cylinder++)
		for (head = 0; head <= ds; head++) {

			for (i = 0; i < 256; i++)
				sector_index [i] = -1;

			if (! dmk_seek (h, cylinder, head)) {
				eprintf ("Error seeking to cylinder %d\n", cylinder);
				exit (1);
			}

			if (! dmk_read_id (h, & sector_info [0])) {
				eprintf ("Error reading sector info on cylinder %d head %d\n", cylinder, head);
				exit (1);
			}
			sector_index [sector_info [0].sector] = 0;
			min_sector = sector_info [0].sector;
			max_sector = sector_info [0].sector;

			for (i = 1; i < DMK_MAX_SECTOR; i++) {
				if (! dmk_read_id (h, & sector_info [i]))
					break;
				if (sector_info [i].sector == sector_info [0].sector)
					break;
				sector_index [sector_info [i].sector] = i;

				if (sector_info [i].sector < min_sector)
					min_sector = sector_info [i].sector;
				if (sector_info [i].sector > max_sector)
					max_sector = sector_info [i].sector;
			}
			sector_count = i;

			if (sector_count != ((max_sector - min_sector) + 1)) {
				eprintf ("Error: sectors discontigous, count %d (from %d to %d) head:%d cylinder:%d\n",
					 sector_count, min_sector, max_sector, head, cylinder
				);
				exit (1);
			}

		}

	// Verify fake MFM
	if (dd == DMK_MFM) {
		sector_info_t mfm_info;

		if (! dmk_seek (h, 0, 0)) {
			eprintf ("MFM verify: Error seeking to track 0\n");
			exit (1);
		}

		mfm_info.cylinder  = 0;
		mfm_info.head      = 0;
		mfm_info.sector    = 0;
		mfm_info.size_code = sector_info[0].size_code;
		mfm_info.mode      = dd;

		if (! dmk_read_sector (h, & mfm_info, buf)) {
			// Read error in MFM mode, retry FM
			mfm_info.mode      = DMK_FM;
			if (! dmk_read_sector (h, & mfm_info, buf)) {
				eprintf("Cant access disk sectors not in MFM, not in FM...");
			}
			else {
				dd = DMK_FM;
				fake_mfm = 1;
			}
		}
	}


	printf( "\n" );
	if (fake_mfm)
		printf( "DMK Disk geometry for disk %c: (%s) Density MFM (fake forced to FM):\n", dbase, image );
	else
		printf( "DMK Disk geometry for disk %c: (%s) Density %s:\n", dbase, image, (dd) ? "MFM" : "FM" );

	printf( "Heads:       %d\n", ds + 1 );
	printf( "Cylinders:   %d\n", cylinders );
	printf( "Sectors:     %d\n", sector_count );
	printf( "Sector size: %d\n", 128 << sector_info[0].size_code );
	printf( "Skew:        %d\n", sector_info[1].sector - sector_info[0].sector );
	printf( "Options:     ");
	if (zeroskewA)
		printf("* Zero skew * ");
	else
		printf("None");
	printf( "\n" );
	int dsize = (ds + 1) * cylinders * sector_count * (128 << sector_info[0].size_code);
	printf( "Disk size:   %d bytes (%dkb)\n", dsize, dsize / 1024 );
	printf( "skewtab:    ");
	for (i = 0; i < sector_count; i++) {
		printf(" %d", sector_info[i].sector);
	}
	printf( "\n" );
	printf( "unskewtab   ");
	for (i = 0; i < sector_count; i++) {
		printf(" %d", sector_index [sector_info [i].sector]);
	}
	printf( "\n\n" );

	// save into drive info
	dmkdrive.h = h;
	dmkdrive.is_dd = dd;
	dmkdrive.heads = ds;
	dmkdrive.cylinders = cylinders;
	dmkdrive.sectors = sector_count;
	dmkdrive.secsize = 128 << sector_info[0].size_code;
	dmkdrive.size_code = sector_info[0].size_code;
	dmkdrive.skew = sector_info[1].sector - sector_info[0].sector;
	dmkdrive.sector_info = sector_info;
	dmkdrive.sector_index = sector_index;
}

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
		eprintf( "error while getting filename/path...\n" );
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
			eprintf( "Cannot stat %s\n", fpath );
			return ( 1 );
		}
		else
			size = finfo.st_size;
	}


	if ( size > MAX_SIZE )
	{
		eprintf( "Error: Your file is %d bytes, greater than acceptable: %d\n", size, MAX_SIZE );
		return ( 1 );
	}

	//open file

	if ( ( rfile = fopen( fpath, ( io_command->instruction == Z80IO_READ ) ? "r" : "w" ) ) == ( FILE * ) 0 )
	{
		eprintf( "Error opening %s\n", fpath );
		return ( 1 );
	}

	printf( "waiting for start...\n" ); fflush( stdout );

	if ( io_command->instruction == Z80IO_READ )
	{
		printf( "Sending %d (%04X) bytes.\n", size, size );
		pb = transbuf;
		while ( !feof( rfile ) )
		{
			c = fgetc( rfile );
			if ( c == EOF )
				break;
			*pb++ = ( byte ) c;
		}

		verbose = 1;

		if ( send_block( transbuf, ( pb - transbuf ) ) )
		{
			eprintf( "Error transferring data!!\n\n" );
			exit( 1 );
		}

		printf( "Sent %d (%04X) bytes.\n", ( pb - transbuf ), ( pb - transbuf ) );
	}
	else
	{
		if ( ( count = recv_block( transbuf, -1 , 0 ) ) < 0 )
		{
			eprintf( "Error receiving data!!\n" );
			return ( 1 );
		}
		recv = count;

		pb = transbuf;
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
	int tlen = (dmkmode) ? dmkdrive.secsize : drive->dev.secLength;

	/* get sector data from remote */
	if ( recv_block( ( char * ) io_sector, tlen, 1 ) )
	{
		return ( 1 );
	}

// 	sector = (unskewp && io_command->track < drive->boottrk) ? unskewp[io_command->sector] : io_command->sector;

	/* write to disk image */
	if (dmkmode) {

		int ds, dd;
		int cylinders;

		sector_info_t sector_info;
		int head = ((double)io_command->track / (double)dmkdrive.cylinders > 1.0) ? 1 : 0;

		if (! dmk_seek (dmkdrive.h, io_command->track, head)) {
			eprintf ("Error seeking to track %d\n", io_command->track);
			return 1;
		}

		if (dumpsec) hex_dump(io_sector, tlen);

		sector_info.cylinder  = io_command->track;
		sector_info.head      = head;
		sector_info.sector    = rwsec;
		sector_info.size_code = dmkdrive.size_code;
		sector_info.mode      = dmkdrive.is_dd;

		if (! dmk_write_sector (dmkdrive.h, & sector_info, io_sector)) {
			eprintf( "%s: can not write sector %d (%d), track %d, head %d\n",
				 myexe, io_command->sector, rwsec, io_command->track, head );
			return ( 1 );
		}

		dmk_close_image (dmkdrive.h); 			// flush to disk
		dmkdrive.h = dmk_open_image (image, 1, & ds, & cylinders, & dd);
		if (! dmkdrive.h) {
			eprintf ("Error re-opening input DMK file %s\n", image);
			exit (1);
		}

	}
	else {
		if ( ( err = Device_writeSector( &drive->dev, io_command->track, rwsec, ( const char * ) io_sector ) ) )
		{
			eprintf( "%s: can not write sector %d (%d), track %d (%s)\n",
				 myexe, io_command->sector, rwsec, io_command->track, err );
			return ( 1 );
		}
	}

	return ( 0 );
}

int do_read_sector( struct cpmSuperBlock * drive, Z80_IO_COMMAND * io_command, byte * io_sector, int rwsec )
{
	const char * err;
	int sector;
	int tlen = (dmkmode) ? dmkdrive.secsize : drive->dev.secLength;

	/* read sector from disk image */
	if (dmkmode) {
		sector_info_t sector_info;
		int head = ((double)io_command->track / (double)dmkdrive.cylinders > 1.0) ? 1 : 0;

		if (! dmk_seek (dmkdrive.h, io_command->track, head)) {
			eprintf ("Error seeking to track %d\n", io_command->track);
			return 1;
		}

		sector_info.cylinder  = io_command->track;
		sector_info.head      = head;
		sector_info.sector    = rwsec;
		sector_info.size_code = dmkdrive.size_code;
		sector_info.mode      = dmkdrive.is_dd;

		if (! dmk_read_sector (dmkdrive.h, & sector_info, io_sector)) {
			eprintf( "%s: can not read sector %d (%d), track %d, head %d\n",
				 myexe, io_command->sector, rwsec, io_command->track, head );
			return ( 1 );
		}

		if (dumpsec) hex_dump(io_sector, tlen);
// 		getchar();
	}
	else {
		if ( ( err = Device_readSector( &drive->dev, io_command->track, rwsec, ( char * ) io_sector ) ) )
		{
			eprintf( "%s: can not read sector %d (%d), track %d (%s)\n",
				 myexe, io_command->sector, rwsec, io_command->track, err );
			return ( 1 );
		}
	}

	if ( send_block( io_sector, tlen ) )
	{
		eprintf( "\nBLOCK TX ERROR\n" );
		return ( 1 );
		/* error cond */
	}

	return ( 0 );
}

void eprintf(const char* format, ...)
{
	char * cformat = (char *) malloc(strlen(format)+20);
	sprintf(cformat, "%s%s%s", col_hred, format, col_rset);
	va_list argptr;
	va_start(argptr, format);
	vfprintf(stderr, cformat, argptr);
	va_end(argptr);
}

/* mkfs -- make file system */
int mkfs( struct cpmSuperBlock *drive, const char *name, const char *label, char *bootTracks )
{
	/* variables */
	int i;
	char buf[ 128 ];
	char firstbuf[ 128 ];
	int fd;
	int bytes;
	int trkbytes;


	/* open image file */
	if ( ( fd = open( name, O_BINARY | O_CREAT | O_WRONLY, 0666 ) ) < 0 )
	{
		boo = strerror( errno );
		eprintf( "mkfs: error opening %s: %s", name, boo);
		return -1;
	}


	/* write system tracks */
	/* this initialises only whole tracks, so it skew is not an issue */
	trkbytes = drive->secLength*drive->sectrk;
	for ( i = 0; i < trkbytes*drive->boottrk; i += drive->secLength )
		if ( write( fd, bootTracks + i, drive->secLength ) != drive->secLength )
		{
			boo = strerror( errno );
			close( fd );
			return -1;
		}

		/* write directory */
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
		eprintf( "mkfs: error writing %s: %s", name, boo);
		close( fd );
		return -1;
	}

	/* close image file */
	if ( close( fd ) == -1 )
	{
		boo = strerror( errno );
		eprintf( "mkfs: error closing %s: %s", name, boo);
		return -1;
	}

	return 0;
}

void cpm_create()
{
	int c;

	cpmReadSuper( &drive, &root, format );

	bootTrackSize = drive.boottrk * drive.secLength * drive.sectrk;
	if ( ( bootTracks = malloc( bootTrackSize ) ) == ( void* ) 0 )
	{
		eprintf( "%s: can not allocate boot track buffer: %s\n", myexe, strerror( errno ) );
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
			eprintf( "%s: can not open %s: %s\n", myexe, boot[ c ], strerror( errno ) );
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
		eprintf( "%s: can not make new file system: %s\n", myexe, boo );
		exit( 1 );
	}
	else
	{
		printf( "%sSuccessfully created new file system: %s%s (CP/M type)\n\n", col_green, image, col_rset );
		exit( 0 );
	}
}

void dmk_create()
{
	dmk_handle h;
	int cylinder;
	int i;
	sector_info_t sector_info [26];
	int dens, nheads, ntracks, nsectors, sec_size, skew;
	char ** tokens;

	char * str_prm[6];
	int sectran[256];

	if (!dparm) {
		eprintf ("Disk parameters needed for DMK and -c option. Use -p option.\n\n");
		exit(1);
	}


	tokens = str_split(dparm, ':');

	if (tokens) {
		int i;

		for (i = 0; *(tokens + i); i++) {
			if (i > 5)
				dparm_error();
			str_prm[i] = strdup(*(tokens + i));
			free(*(tokens + i));
		}
		free(tokens);

		if (i < 5)
			dparm_error();
	}
	else
		dparm_error();

	dens = atoi(str_prm[0]);
	nheads = atoi(str_prm[1]);
	ntracks = atoi(str_prm[2]);
	nsectors = atoi(str_prm[3]);
	sec_size = atoi(str_prm[4]);
	skew = atoi(str_prm[5]);

	// a bit check
	if (dens > 1 ||
		nheads > 2 ||
		ntracks > 80 ||
		nsectors > 256 ||
		sec_size > 512 ||
		skew > nsectors
	) {
		eprintf("Your disk params %d:%d:%d:%d:%d:%d are wrong. Double check.\n",
			dens,
			nheads,
			ntracks,
			nsectors,
			sec_size,
			skew
		);
		exit(1);
	}

	int sk = 0;
	int skb = 0;
	for (i = 0; i < nsectors; i++) {
		sectran[i] = sk;
		sk += skew;
		if (sk > nsectors - 1) {
			sk = ++skb;
		}
	}

	printf("Creating/formatting disk with density %s, %d heads, %d tracks, %d sectors, %d sector size, skew factor %d\n",
		(dens) ? "MFM" : "FM",
		nheads,
		ntracks,
		nsectors,
		sec_size,
		skew
	);
	printf( "skewtab:    ");
	for (i = 0; i < nsectors; i++) {
		printf(" %d", sectran[i]);
	}
	printf( "\n" );


	h = dmk_create_image (image,
		nheads - 1, 	/* double-sided ? */
		ntracks,
		dens, 		/* density */
		300,		/* RPM */
		250);		/* rate */

	if (! h) {
		eprintf ("error opening output file, check disk params and file permissions\n\n");
		exit (1);
	}

	int head;

	for (head = 0; head < nheads; head++) {
		for (cylinder = 0; cylinder < ntracks; cylinder++) {
			if (! dmk_seek (h, cylinder, 0)) {
				eprintf ("error seeking to cylinder %d\n", cylinder);
				return;
			}

			for (i = 0; i < nsectors; i++) {
				sector_info [i].cylinder   = cylinder;
				sector_info [i].head       = head;
				sector_info [i].sector     = sectran[i];
				sector_info [i].size_code  = (sec_size / 128) - 1;
				sector_info [i].mode       = dens;
				sector_info [i].write_data = 1;
				sector_info [i].data_value = 0xe5;  /* not used */
// 				printf("formatting %d, %d, %d->%d\n",head,cylinder,i,sector_info [i].sector);
			}

			if (! dmk_format_track (h, dens, nsectors, sector_info)) {
				eprintf ( "error formatting cylinder %d\n", cylinder);
				return;
			}
		}
	}


	dmk_close_image (h);

	printf( "%sSuccessfully created new file system: %s%s (DMK type)\n\n", col_green, image, col_rset );
	exit( 0 );

}

void dparm_error()
{
	eprintf("Disk parameters string format error.\n");
	printf("It should be \"density:#heads:#tracks:#sectors:sector_size:skew\"\n\n");

	exit(1);
}

char** str_split(char* a_str, const char a_delim)
{
	char** result    = 0;
	size_t count     = 0;
	char* tmp        = a_str;
	char* last_comma = 0;
	char delim[2];
	delim[0] = a_delim;
	delim[1] = 0;

	/* Count how many elements will be extracted. */
	while (*tmp) {
		if (a_delim == *tmp)
		{
			count++;
			last_comma = tmp;
		}
		tmp++;
	}

	/* Add space for trailing token. */
	count += last_comma < (a_str + strlen(a_str) - 1);

	/* Add space for terminating null string so caller
	knows where the list of returned strings ends. */
	count++;

	result = malloc(sizeof(char*) * count);

	if (result) {
		size_t idx  = 0;
		char* token = strtok(a_str, delim);

		while (token)
		{
			assert(idx < count);
			*(result + idx++) = strdup(token);
			token = strtok(0, delim);
		}
		assert(idx == count - 1);
		*(result + idx) = 0;
	}

	return result;
}

void hex_dump(void *addr, int len)
{
	int i;
	unsigned char buff[17];
	unsigned char *pc = (unsigned char*)addr;

	// Process every byte in the data.
	for (i = 0; i < len; i++) {
		// Multiple of 16 means new line (with line offset).

		if ((i % 16) == 0) {
			// Just don't print ASCII for the zeroth line.
			if (i != 0)
				printf("  %s\n", buff);

			// Output the offset.
			printf("  %04x ", i);
		}

		// Now the hex code for the specific character.
		printf(" %02x", pc[i]);

		// And store a printable ASCII character for later.
		if ((pc[i] < 0x20) || (pc[i] > 0x7e)) {
			buff[i % 16] = '.';
		} else {
			buff[i % 16] = pc[i];
		}

		buff[(i % 16) + 1] = '\0';
	}

	// Pad out last line if not exactly 16 characters.
	while ((i % 16) != 0) {
		printf("   ");
		i++;
	}

	// And print the final ASCII bit.
	printf("  %s\n", buff);
}

void print_sector_info (sector_info_t *sector_info)
{
	printf ("dd %d cyl %d head %d sector %d size %d (%d)\n",
		sector_info->mode,
		sector_info->cylinder,
		sector_info->head,
		sector_info->sector,
		128 << sector_info->size_code,
		sector_info->size_code
       	);
}
