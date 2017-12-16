/*
 * DMK disk image format definitions
 *
 * $Id: dmk.h 41 2003-12-21 23:48:14Z eric $
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


#define DMK_HEADER_LENGTH 16

typedef struct
{
  u_int8_t write_protect;  /* 0xff for protected, 0x00 for unprotected */
  u_int8_t track_count;
  uint16_t track_length;  /* little endian */
  u_int8_t flags;
  u_int8_t fill [7];
  uint32_t real;          /* little endian */
} dmk_disk_header_t;


#define DMK_WRITE_ENABLE  0x00
#define DMK_WRITE_PROTECT 0xff

#define DMK_TRACK_LENGTH_8I_SD 5208
#define DMK_TRACK_LENGTH_8I_DD 10416

#define DMK_FLAG_NO_DENSITY 7  /* obsolete */
#define DMK_FLAG_SD_BIT     6
#define DMK_FLAG_RX02_BIT   5  /* extension defined by Tim Mann,
				  note that PC floppy controllers can't
			          read or write RX02 format */
#define DMK_FLAG_SS_BIT     4

#define DMK_FLAG_SS_MASK         (1 << DMK_FLAG_SS_BIT)
#define DMK_FLAG_RX02_MASK       (1 << DMK_FLAG_RX02_BIT)
#define DMK_FLAG_SD_MASK         (1 << DMK_FLAG_SD_BIT)
#define DMK_FLAG_NO_DENSITY_MASK (1 << DMK_FLAG_NO_DENSITY)

#define DMK_REAL_DISK 0x12345678



#define DMK_IDAM_POINTER_MFM_BIT  15
#define DMK_IDAM_POINTER_MFM_MASK (1 << DMK_IDAM_POINTER_MFM_BIT)

#define DMK_IDAM_POINTER_RSV_BIT  14
#define DMK_IDAM_POINTER_RSV_MASK (1 << DMK_IDAM_POINTER_RSV_BIT)

#define DMK_IDAM_POINTER_FLAGS_MASK (DMK_IDAM_POINTER_MFM_MASK | \
				     DMK_IDAM_POINTER_RSV_MASK)
