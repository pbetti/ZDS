/*
 * libdmk - library for accessing DMK format disk images
 *
 * $Id: libdmk.h 41 2003-12-21 23:48:14Z eric $
 *
 * Copyright 2002 Eric Smith.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.  Note that permission is
 * not granted to redistribute this program under the terms of any
 * other version of the General Public License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111  USA
 */


#define DMK_MAX_SECTOR 64


typedef enum
{
  DMK_FM,    /* single-density */
  DMK_MFM,   /* IBM double-density */
  DMK_RX02,  /* DEC double-density */
  DMK_M2FM,  /* Intel double-density */
  MAX_SECTOR_MODE  /* must be last */
} sector_mode_t;

typedef struct
{
  u_int8_t cylinder;
  u_int8_t head;
  u_int8_t sector;
  u_int8_t size_code;
  sector_mode_t mode;
  int write_data;  /* if false, formatting writes
		      only index and address
		      fields */
  u_int8_t data_value;  /* initial data value when
		     formatting, normally 0xe5 */
} sector_info_t;


typedef struct dmk_state *dmk_handle;

typedef struct
{
	dmk_handle h;
	int is_dd;
	int heads;
	int cylinders;
	int sectors;
	int secsize;
	int size_code;
	int skew;
	sector_info_t * sector_info;
	int * sector_index;

} dmk_drive_t;

dmk_handle dmk_create_image (char *fn,
			     int ds,    /* boolean */
			     int cylinders,
			     int dd,    /* boolean */
			     int rpm,   /* 300 or 360 RPM */
			     int rate); /* 125, 250, 300, or 500 Kbps */

/*
 * Set ds true for double-sided disks.
 *
 * Set dd true for double-density disks, or for
 * single density if some sectors may be double
 * density (e.g., DEC RX02 format).
 *
 * If rpm and rate are non-zero, they well be used (together with dd)
 * to set the appropriate track length.
 */


dmk_handle dmk_open_image (char *fn,
			   int write_enable,
			   int *ds,
			   int *cylinders,
			   int *dd);

int dmk_close_image (dmk_handle h);


int dmk_seek (dmk_handle h,
	      int cylinder,
	      int side);


int dmk_format_track (dmk_handle h,
		      sector_mode_t mode,
		      int sector_count,
		      sector_info_t *sector_info);


int dmk_read_id (dmk_handle h,
		 sector_info_t *sector_info);

int dmk_read_sector (dmk_handle h,
		     sector_info_t *sector_info,
		     u_int8_t *data);

int dmk_write_sector (dmk_handle h,
		      sector_info_t *sector_info,
		      u_int8_t *data);

#undef ADDRESS_MARK_DEBUG
#ifdef ADDRESS_MARK_DEBUG
int dmk_check_address_mark (dmk_handle h,
			    sector_info_t *sector_info);
#endif /* ADDRESS_MARK_DEBUG */
