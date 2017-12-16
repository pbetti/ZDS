/*
 * libdmk - library for accessing DMK format disk images
 *
 * $Id: libdmk.c 41 2003-12-21 23:48:14Z eric $
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


#define DEBUG_CRC 0
#undef DEBUG_GAP


#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "dmk.h"
#include "libdmk.h"


typedef struct
{
  int count;
  uint8_t data;
} count_data_t;

typedef struct
{
  int count;
  uint8_t data;
  uint8_t clock;
} count_data_clock_t;

typedef struct
{
  count_data_t pre_index_gap           [2];  /* between lead edge of index
						sense and index mark (part of
						gap 4) */
  count_data_clock_t index_mark        [2];
  count_data_t pre_sector_gap          [2];  /* part of gap 1 or gap 3 */
  count_data_t min_pre_sector_gap      [2];  /* min for non-std format */
  count_data_clock_t id_address_mark   [2];
  int address_field_length;                  /* includes mark, CRC */
  count_data_t id_gap                  [2];  /* gap 2 */
  count_data_clock_t data_mark         [2];
  count_data_clock_t deleted_data_mark [2];
  int data_field_overhead;                   /* mark, CRC */
  count_data_t post_data_gap           [2];  /* note - only part of gap 3,
						joins with pre_sector_gap,
						used for write splice -
					        element 0 is always written
					        when the data field is written */
  uint8_t gap_4_data;
} track_format_t;


track_format_t track_format [MAX_SECTOR_MODE] =
{
  { /* FM */
    /* pre_index_gap */         {{ 40, 0xff },       {  6, 0x00 }},
    /* index_mark */            {{  0, 0x00, 0x00 }, {  1, 0xfc, 0xd7 }},
    /* pre_sector_gap */        {{ 26, 0xff },       {  6, 0x00 }},
    /* min_pre_sector_gap */    {{ 10, 0xff },       {  4, 0x00 }},
    /* id_address_mark */       {{  0, 0x00 },       {  1, 0xfe }},
    /* address_field_length */  7,
    /* id_gap */                {{ 11, 0xff },       {  6, 0x00 }},
    /* data_mark */             {{  1, 0xfb, 0xc7 }, {  0, 0x00, 0x00 }},
    /* deleted_data_mark */     {{  1, 0xf8, 0xc7 }, {  0, 0x00, 0x00 }},
    /* data_field_overhead */   3,
    /* post_data_gap */         {{  1, 0xff },       {  0, 0x00 }},
    /* gap_4_data */            0xff
  },
  { /* MFM */
    /* pre_index_gap */         {{ 80, 0x4e },       { 12, 0x00 }},
    /* index_mark */            {{  3, 0xc2, 0x28 }, {  1, 0xfc, 0x02 }},
    /* pre_sector_gap */        {{ 50, 0x4e },       { 12, 0x00 }},
    /* min_pre_sector_gap */    {{ 24, 0x4e },       {  8, 0x00 }},
    /* ID_address_mark */       {{  3, 0xa1, 0x14 }, {  1, 0xfe, 0x00 }},
    /* address_field_length */  10,
    /* id_gap */                {{ 22, 0x4e },       { 12, 0x00 }},
    /* data_mark */             {{  3, 0xa1, 0x14 }, {  1, 0xfb, 0x00 }},
    /* deleted_data_mark */     {{  3, 0xa1, 0x14 }, {  1, 0xf8, 0x06 }},
    /* data_ field_overhead */  6,
    /* post_data_gap */         {{  1, 0x4e },       {  3, 0x4e }},
    /* gap_4_data */            0x4e
  },
  { /* RX02 */
    /* pre_index_gap */         {{ 40, 0xff },       {  6, 0x00 }},
    /* index_mark */            {{  1, 0xfc, 0xd7 }, {  0, 0x00, 0x00 }},
    /* pre_sector_gap */        {{ 26, 0xff },       {  6, 0x00 }},
    /* min_pre_sector_gap */    {{ 10, 0xff },       {  4, 0x00 }},
    /* id_address_mark */       {{  1, 0xfe },       {  0, 0x00 }},
    /* address_field_length */  7,
    /* id_gap */                {{ 11, 0xff },       {  6, 0x00 }},
    /* data_mark */             {{  1, 0xfb, 0xc7 }, {  0, 0x00, 0x00 }},
    /* deleted_data_mark */     {{  1, 0xf8, 0xc7 }, {  0, 0x00, 0x00 }},
    /* data_field_overhead */   3,
    /* post_data_gap */         {{  1, 0xff },       {  0, 0x00 }},
    /* gap_4_data */            0xff
  },
  { /* Intel M2FM */
    /* pre_index_gap */         {{ 46, 0xff },       {  0, 0x00 }},  /* or 0x00? */
    /* index_mark */            {{  1, 0x0c, 0x71 }, {  0, 0x00, 0x00 }},
    /* pre_sector_gap */        {{ 18, 0x00 },       { 10, 0xff }},
    /* min_pre_sector_gap */    {{ 18, 0x00 },       { 10, 0xff }},
    /* id_address_mark */       {{  1, 0x0e, 0x70 }, {  0, 0x00, 0x00 }},
    /* address_field_length */  7,
    /* id_gap */                {{ 18, 0x00 },       { 10, 0xff }},
    /* data_mark */             {{  1, 0x0b, 0x70 }, {  0, 0x00, 0x00 }},
    /* deleted_data_mark */     {{  1, 0x08, 0x72 }, {  0, 0x00, 0x00 }},
    /* data_field_overhead */   3,
    /* post_data_gap */         {{  1, 0xff },       {  0, 0x00 }},
    /* gap_4_data */            0xff  /* or 0x00? */
  }
};


typedef struct
{
  int resident;  /* boolean */
  int dirty;     /* boolean */
  uint8_t  mfm_sector   [DMK_MAX_SECTOR];
  uint16_t idam_pointer [DMK_MAX_SECTOR];
  uint8_t *buf;
} track_state_t;

struct dmk_state
{
  FILE *f;

  int new_image;  /* boolean */
  int writable;   /* boolean */

  /* parameters specified by user */
  int ds;    /* disk is double sided */
  int cylinders;
  int dd;    /* disk is double density */
  int rpm;   /* 300 or 360 RPM */
  int rate;  /* 125, 250, 300, or 500 Kbps */

  /* computed parameters */
  int track_length;  /* length of a track buffer, not including IDAM
			pointers -- raw data only */

  /* track information */
  track_state_t *track;  /* index by 2 * cylinder + head */

  /* current status */
  int cur_cylinder;
  int cur_head;
  sector_mode_t cur_mode;  /* current transfer mode */
  track_state_t *cur_track;

  uint16_t crc;
  int p;  /* index into buf */

  int read_id_index;
};



static void init_crc (dmk_handle h)
{
  h->crc = 0xffff;
}


static void compute_crc (dmk_handle h, uint8_t data)
{
  int i;
  uint16_t d2 = data << 8;
  for (i = 0; i < 8; i++)
    {
      h->crc = (h->crc << 1) ^ ((((h->crc ^ d2) & 0x8000) ? 0x1021 : 0));
      d2 <<= 1;
    }
}


/* should never happen!  sectors aren't allowed to wrap around. */
static void wrap_p (dmk_handle h)
{
  h->p = -1;
}


static inline void inc_p (dmk_handle h)
{
  h->p++;
  if (h->p >= h->track_length)
    wrap_p (h);
}

static inline void advance_p (dmk_handle h, int count)
{
  /* not very efficient, but we're never going to advance by more
     than about 22 bytes */
  while (count--)
    inc_p (h);
}

static void read_buf (dmk_handle h,
		      int len,
		      uint8_t *data)
{
  uint8_t b;

  assert (h->p >= 0);
  while (len--)
    {
      b = h->cur_track->buf [h->p];
      inc_p (h);
      if (h->dd && (h->cur_mode == DMK_FM))
	inc_p (h);
      compute_crc (h, b);
      *(data++) = b;
    }
}


static uint8_t read_buf_byte (dmk_handle h)
{
  uint8_t b;

  read_buf (h, 1, & b);
  return (b);
}


static int check_crc (dmk_handle h)
{
  uint8_t d [2];
  uint16_t actual_crc;
  uint16_t expected_crc = h->crc;

  read_buf (h, 2, d);
  actual_crc = (d [0] << 8) | d [1];
  if (actual_crc == expected_crc)
    return (1);

#if DEBUG_CRC
  fprintf (stderr, "CRC == %04x, should be %04x\n",
	   actual_crc,
	   expected_crc);
#endif

  return (0);
}


static void write_buf (dmk_handle h,
		       int len,
		       uint8_t *data)
{
  if (! h->writable)
    return;  /* ideally we wouldn't get this far */

  assert (h->p >= 0);

  h->cur_track->dirty = 1;
  while (len--)
    {
      compute_crc (h, *data);
      h->cur_track->buf [h->p] = *data;
      inc_p (h);
      if (h->dd && (h->cur_mode == DMK_FM))
	{
	  h->cur_track->buf [h->p] = *data;
	  inc_p (h);
	}
      data++;
    }
}


static void write_buf_const (dmk_handle h,
			     int count,
			     uint8_t val)
{
  while (count--)
    write_buf (h, 1, & val);
}


static void write_buf_count_data (dmk_handle h, count_data_t *cd)
{
  write_buf_const (h, cd->count, cd->data);
}


static void write_buf_count_data_clock (dmk_handle h, count_data_clock_t *cd)
{
  write_buf_const (h, cd->count, cd->data);
}


static void write_crc (dmk_handle h)
{
  uint8_t d [2];
  /* $$$ byte order? */
  d [0] = h->crc >> 8;
  d [1] = h->crc & 0xff;
  write_buf (h, 2, d);
}


dmk_handle dmk_open_image (char *fn,
			   int write_enable,
			   int *ds,
			   int *cylinders,
			   int *dd)
{
  dmk_handle h;
  uint8_t dmk_header [DMK_HEADER_LENGTH];

  h = calloc (1, sizeof (struct dmk_state));
  if (! h)
    goto fail;

  h->f = fopen (fn, write_enable ? "r+" : "rb");
  if (! h->f)
    goto fail;

  if (1 != fread (dmk_header, sizeof (dmk_header), 1, h->f))
    {
      fprintf (stderr, "error reading DMK header\n");
      goto fail;
    }

  /* if write requested, make sure the file isn't locked */
  if (write_enable && dmk_header [0])
    {
      fprintf (stderr, "write-locked DMK file\n");
      goto fail;
    }

  h->writable = write_enable;

  h->cylinders = dmk_header [1];
  h->track_length = ((dmk_header [3] << 8) | dmk_header [2]) - 2 * DMK_MAX_SECTOR;
  h->dd = ! (dmk_header [4] & DMK_FLAG_SD_MASK);
  h->ds = ! (dmk_header [4] & DMK_FLAG_SS_MASK);

  *ds = h->ds;
  *cylinders = h->cylinders;
  *dd = h->dd;

#if 0
  /* could guess, but why bother */
  h->rpm = rpm;
  h->rate = rate;
#endif

  h->track = calloc (h->cylinders * (h->ds + 1), sizeof (track_state_t));
  if (! h->track)
    goto fail;

  /*
   * Make sure the first seek will do the right thing, by setting
   * the current position to a non-existent track
   */
  h->cur_cylinder = -1;
  h->cur_head = -1;

  return (h);

 fail:
  if (h)
    free (h);
  return (NULL);
}


dmk_handle dmk_create_image (char *fn,
			     int ds,    /* boolean */
			     int cylinders,
			     int dd,    /* boolean */
			     int rpm,   /* 300 or 360 RPM */
			     int rate)  /* 125, 250, 300, or 500 Kbps */
{
  dmk_handle h;

  h = calloc (1, sizeof (struct dmk_state));
  if (! h)
    goto fail;

  umask(~(S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH));
  h->f = fopen (fn, "wb");
  if (! h->f)
    goto fail;

  h->new_image = 1;
  h->writable = 1;

  h->ds = ds;
  h->cylinders = cylinders;
  h->dd = dd;
  h->rpm = rpm;
  h->rate = rate;

  if ((rpm == 360) && (rate == 500) && dd)
    h->track_length = 0x2900;  /* 8-inch DD, defined in DMK spec
				  (doesn't include IDAM pointers */
  else if ((rpm == 360) && (rate == 250) && ! dd)
    h->track_length = 0x14a0;  /* 8-inch SD, defined in DMK spec
				  (doesn't include IDAM pointers */
  else
    {
      h->track_length = (rate * 7500L) / rpm;
      if (h->track_length > 0x2900)
	fprintf (stderr, "warning: track length %d exceeds maximum DMK spec\n",
		 h->track_length);
    }

  h->track = calloc (cylinders * (ds + 1), sizeof (track_state_t));
  if (! h->track)
    goto fail;

  /*
   * Make sure the first seek will do the right thing, by setting
   * the current position to a non-existent track
   */
  h->cur_cylinder = -1;
  h->cur_head = -1;

  return (h);

 fail:
  if (h)
    free (h);
  return (NULL);
}


int dmk_image_file_seek_track (dmk_handle h, int cylinder, int head)
{
  int pos = DMK_HEADER_LENGTH + (((h->ds + 1) * cylinder + head) *
				 ((2 * DMK_MAX_SECTOR) + h->track_length));
  return (0 <= fseek (h->f, pos, SEEK_SET));
}


int dmk_close_image (dmk_handle h)
{
  int cylinder, head, sector;
  track_state_t *track;
  uint8_t b;

  if (! h->writable)
    goto done;

  if (h->new_image)
    {
      uint8_t dmk_header [DMK_HEADER_LENGTH];

      memset (dmk_header, 0, DMK_HEADER_LENGTH);
      dmk_header [0] = 0x00;  /* unprotected */
      dmk_header [1] = h->cylinders;
      dmk_header [2] = (h->track_length + 2 * DMK_MAX_SECTOR) & 0xff;
      dmk_header [3] = (h->track_length + 2 * DMK_MAX_SECTOR) >> 8;
      dmk_header [4] = 0x00;  /* flags */
      if (! h->ds)
	dmk_header [4] |= DMK_FLAG_SS_MASK;
      if (! h->dd)
	dmk_header [4] |= DMK_FLAG_SD_MASK;

      /* note that we should still be positioned to the start of the file */
      if (1 != fwrite (dmk_header, sizeof (dmk_header), 1, h->f))
	{
	  fprintf (stderr, "error writing DMK header\n");
	  return (0);
	}
    }

  for (cylinder = 0; cylinder < h->cylinders; cylinder++)
    for (head = 0; head <= h->ds; head++)
      {
	track = & h->track [(h->ds + 1) * cylinder + head];

	if (track->buf && track->dirty)
	  {
	    if (! dmk_image_file_seek_track (h, cylinder, head))
	      {
		fprintf (stderr, "error seeking image file\n");
		return (0);
	      }
	    /* write IDAM offsets */
	    for (sector = 0; sector < DMK_MAX_SECTOR; sector++)
	      {
		int idam_ptr = track->idam_pointer [sector];
		idam_ptr += 2 * DMK_MAX_SECTOR;
		if (track->mfm_sector [sector])
		  idam_ptr |= DMK_IDAM_POINTER_MFM_MASK;
		b = idam_ptr & 0xff;
		if (1 != fwrite (& b, 1, 1, h->f))
		  {
		    fprintf (stderr, "error writing IDAM offset low to image file\n");
		    return (0);
		  }
		b = idam_ptr >> 8;
		if (1 != fwrite (& b, 1, 1, h->f))
		  {
		    fprintf (stderr, "error writing IDAM offset high to image file\n");
		    return (0);
		  }
	      }

	    /* write track data */
	    if (1 != fwrite (track->buf, h->track_length, 1, h->f))
	      {
		if (ferror (h->f))
		  fprintf (stderr, "error writing track data to image file\n");
		else
		  fprintf (stderr, "fwrite failed writing track data to image file\n");
		return (0);
	      }
	    track->dirty = 0;
	  }
	if (track->buf)
	  free (track->buf);
      }

 done:
  fclose (h->f);
  free (h);
  return (1);
}


int dmk_seek (dmk_handle h,
	      int cylinder,
	      int head)
{
  track_state_t *new_track;
  int i;

  if (cylinder > h->cylinders)
    return (0);

  if (head && ! h->ds)
    return (0);

  if ((cylinder == h->cur_cylinder) &&
      (head == h->cur_head))
    {
      /* already there */
      h->read_id_index = 0;
      return (1);
    }

  new_track = & h->track [(h->ds + 1) * cylinder + head];

  if (! new_track->buf)
    {
      new_track->buf = calloc (1, h->track_length);
      if (! new_track->buf)
	return (0);
      if (h->new_image)
	{
	  /* virgin image: fill the new track with FFs */
	  for (i = 0; i < h->track_length; i++)
	    new_track->buf [i] = 0xff;
	}
      else
	{
	  /* existing image: read the track from the image file */
	  if (! dmk_image_file_seek_track (h, cylinder, head))
	    {
	      fprintf (stderr, "error seeking image file\n");
	      exit (2);
	    }
	  for (i = 0; i < DMK_MAX_SECTOR; i++)
	    {
	      uint8_t d [2];
	      uint16_t idam_ptr;
	      if (1 != fread (d, 2, 1, h->f))
		{
		  fprintf (stderr, "error reading image file\n");
		  exit (2);
		}
	      idam_ptr = d [1] << 8 | d [0];
	      if (idam_ptr == 0)
		continue;
	      if (idam_ptr < (2 * DMK_MAX_SECTOR))
		{
		  fprintf (stderr, "IDAM pointer out of range\n");
		  exit (2);
		}
	      idam_ptr -= 2 * DMK_MAX_SECTOR;
	      if (idam_ptr & DMK_IDAM_POINTER_MFM_MASK)
		{
		  new_track->mfm_sector [i] = 1;
		  idam_ptr &= ~ DMK_IDAM_POINTER_FLAGS_MASK;
		}
	      else
		new_track->mfm_sector [i] = 0;
	      new_track->idam_pointer [i] = idam_ptr;
	    }
	  if (1 != fread (new_track->buf, h->track_length, 1, h->f))
	    {
	      fprintf (stderr, "error reading image file\n");
	      exit (2);
	    }
	}
    }

  h->cur_cylinder = cylinder;
  h->cur_head = head;
  h->cur_track = new_track;

  h->read_id_index = 0;

  return (1);
}


static int write_data_field (dmk_handle h,
			     sector_info_t *sector_info,
			     int single_value,  /* boolean */
			     uint8_t *data)
{
  track_format_t *fmt;

  fmt = & track_format [sector_info->mode];

  write_buf_count_data (h, & fmt->id_gap [1]);
  init_crc (h);
  write_buf_count_data_clock (h, & fmt->data_mark [0]);
  write_buf_count_data_clock (h, & fmt->data_mark [1]);
  if (single_value)
    write_buf_const (h, 128 << sector_info->size_code, *data);
  else
    write_buf       (h, 128 << sector_info->size_code, data);
  write_crc (h);
  write_buf_count_data (h, & fmt->post_data_gap [0]);

  return (1);
}


#define MAX_ID_GAP 50  /* shouldn't ever be more than 17 for FM, 34 for MFM */

static int read_data_field (dmk_handle h,
			    sector_info_t *sector_info,
			    uint8_t *data)
{
  int i;
  uint8_t b;

  for (i = 0; i < MAX_ID_GAP; i++)
    {
      b = read_buf_byte (h);
      if ((b >= 0xf8) && (b <= 0xfb))
	break;
    }
  if (i >= MAX_ID_GAP)
    return (0);

  init_crc (h);
  if (sector_info->mode == DMK_MFM)
    {
      /* In MFM, the three A1 bytes are included in the CRC */
      compute_crc (h, 0xa1);
      compute_crc (h, 0xa1);
      compute_crc (h, 0xa1);
    }
  compute_crc (h, b);  /* the data mark is included in the CRC */
  read_buf (h, 128 << sector_info->size_code, data);
  return (check_crc (h));
}


static int compute_gap (dmk_handle h,
			sector_mode_t mode,
			int sector_count,
			sector_info_t *sector_info,
			count_data_t *pre_sector_gap)
{
  track_format_t *fmt;
  int room;
  int gap;
  int sector;

  int track_overhead;
  int sector_overhead;
  int data_length;

  fmt = & track_format [mode];

  track_overhead = (fmt->pre_index_gap [0].count +
		    fmt->pre_index_gap [1].count +
		    fmt->index_mark [0].count +
		    fmt->index_mark [1].count);

  sector_overhead = (fmt->id_address_mark [0].count +
		     fmt->id_address_mark [1].count +
		     fmt->address_field_length +
		     fmt->id_gap [0].count +
		     fmt->id_gap [1].count +
		     fmt->data_field_overhead +
		     fmt->post_data_gap [0].count +
		     fmt->post_data_gap [1].count);

  data_length = 0;
  for (sector = 0; sector < sector_count; sector++)
    data_length += (128 << sector_info [sector].size_code);

  room = h->track_length - (track_overhead +
			    (sector_count * sector_overhead) +
			    data_length);

  /* what's left needs to be divided up for the gap */
  gap = room / sector_count;

#ifdef DEBUG_GAP
  fprintf (stderr, "track_length: %d\n", h->track_length);
  fprintf (stderr, "track_overhead: %d\n", track_overhead);
  fprintf (stderr, "sector_overhead: %d per sector\n", sector_overhead);
  fprintf (stderr, "data_length: %d\n", data_length);
  fprintf (stderr, "room: %d\n", room);
  fprintf (stderr, "gap: %d\n", gap);
#endif /* GAP_DEBUG */

  /* if there's enough space, use the standard gap */
  if (gap >= (fmt->pre_sector_gap [0].count + fmt->pre_sector_gap [1].count))
    {
      pre_sector_gap [0].count = fmt->pre_sector_gap [0].count;
      pre_sector_gap [0].data  = fmt->pre_sector_gap [0].data;
      pre_sector_gap [1].count = fmt->pre_sector_gap [1].count;
      pre_sector_gap [1].data  = fmt->pre_sector_gap [1].data;
#ifdef DEBUG_GAP
      fprintf (stderr, "standard");
#endif
      goto success;
    }

  /* if possible, shrink only first part of gap */
  if (gap >= (fmt->min_pre_sector_gap [0].count + fmt->pre_sector_gap [1].count))
    {
      pre_sector_gap [0].count = gap - fmt->pre_sector_gap [1].count;
      pre_sector_gap [0].data  = fmt->pre_sector_gap [0].data;
      pre_sector_gap [1].count = fmt->pre_sector_gap [1].count;
      pre_sector_gap [1].data  = fmt->pre_sector_gap [1].data;
#ifdef DEBUG_GAP
      fprintf (stderr, "short");
#endif
      goto success;
    }

  if (gap >= (fmt->min_pre_sector_gap [0].count + fmt->min_pre_sector_gap [1].count))
    {
      pre_sector_gap [0].count = gap - fmt->min_pre_sector_gap [1].count;
      pre_sector_gap [0].data  = fmt->pre_sector_gap [0].data;
      pre_sector_gap [1].count = fmt->min_pre_sector_gap [1].count;
      pre_sector_gap [1].data  = fmt->min_pre_sector_gap [1].data;
#ifdef DEBUG_GAP
      fprintf (stderr, "very short");
#endif
      goto success;
    }

  /* not enough room! */
#ifdef DEBUG_GAP
  fprintf (stderr, "insufficient space for minimum gap\n");
#endif
  return (0);

 success:
#ifdef DEBUG_GAP
  fprintf (stderr, " gap:  %d*0x%02x, %d*0x%02x\n",
	   pre_sector_gap [0].count,
	   pre_sector_gap [0].data,
	   pre_sector_gap [1].count,
	   pre_sector_gap [1].data);
#endif
  return (1);
}


int dmk_format_track (dmk_handle h,
		      sector_mode_t mode,
		      int sector_count,
		      sector_info_t *sector_info)
{
  int sector;
  int gap4_len;
  track_format_t *fmt;
  count_data_t pre_sector_gap [2];

  /* make sure we have a physical position */
  if (h->cur_cylinder < 0)
    return (0);

  /* can't write double-density track to a
     single-density image */
  if (mode & ! h->dd)
    return (0);

  h->cur_mode = mode;
  fmt = & track_format [mode];

  /* compute gap length, may be shorter than standard if there are more
     and/or larger sectors */
  if (! compute_gap (h, mode, sector_count, sector_info, pre_sector_gap))
    return (0);

  memset (h->cur_track->idam_pointer, 0, sizeof (h->cur_track->idam_pointer));

  h->p = 0;

  write_buf_count_data (h, & fmt->pre_index_gap [0]);
  write_buf_count_data (h, & fmt->pre_index_gap [1]);
  write_buf_count_data_clock (h, & fmt->index_mark [0]);
  write_buf_count_data_clock (h, & fmt->index_mark [1]);

  for (sector = 0; sector < sector_count; sector++)
    {
      write_buf_count_data (h, & pre_sector_gap [0]);
      write_buf_count_data (h, & pre_sector_gap [1]);

      /* ID address mark */
      init_crc (h);
#if (DEBUG_CRC >= 2)
      fprintf (stderr, "initial crc: %04x\n", h->crc);
#endif /* DEBUG_CRC */

      write_buf_count_data_clock (h, & fmt->id_address_mark [0]);

      h->cur_track->idam_pointer [sector] = h->p;
#if 0
      fprintf (stderr, "sector %d IDAM pointer %d\n", sector, h->p);
#endif
      h->cur_track->mfm_sector [sector] = (mode == DMK_MFM);

      write_buf_count_data_clock (h, & fmt->id_address_mark [1]);
#if (DEBUG_CRC >= 2)
      fprintf (stderr, "after AM: %04x\n", h->crc);
#endif /* DEBUG_CRC */

      write_buf_const (h, 1, sector_info [sector].cylinder);
#if (DEBUG_CRC >= 2)
      fprintf (stderr, "after cyl %02x: %04x\n", sector_info [sector].cylinder, h->crc);
#endif /* DEBUG_CRC */
      write_buf_const (h, 1, sector_info [sector].head);
#if (DEBUG_CRC >= 2)
      fprintf (stderr, "after head %02x: %04x\n", sector_info [sector].head, h->crc);
#endif /* DEBUG_CRC */
      write_buf_const (h, 1, sector_info [sector].sector);
#if (DEBUG_CRC >= 2)
      fprintf (stderr, "after sector %02x: %04x\n", sector_info [sector].sector, h->crc);
#endif /* DEBUG_CRC */
      write_buf_const (h, 1, sector_info [sector].size_code);
#if (DEBUG_CRC >= 2)
      fprintf (stderr, "after size code %02x: %04x\n", sector_info [sector].size_code, h->crc);
#endif /* DEBUG_CRC */
#if (DEBUG_CRC == 1)
      fprintf (stderr, "%02d/%d/%02d size %d AM CRC %04x\n",
	       sector_info [sector].cylinder,
	       sector_info [sector].head,
	       sector_info [sector].sector,
	       sector_info [sector].size_code,
	       h->crc);
#endif
      write_crc (h);

      if (sector_info [sector].write_data)
	{
	  write_buf_count_data (h, & fmt->id_gap [0]);
	  write_buf_count_data (h, & fmt->id_gap [1]);

	  if (! write_data_field (h, & sector_info [sector], 1,
				  & sector_info [sector].data_value))
	    {
	      return (0);
	    }
	  write_buf_count_data (h, & fmt->post_data_gap [1]);
	}
      else
	write_buf_const (h,
			 (fmt->id_gap [0].count +
			  fmt->id_gap [1].count +
			  fmt->id_address_mark [0].count +
			  fmt->id_address_mark [1].count +
			  (128 << sector_info [sector].size_code) +
			  2 + /* CRC */
			  fmt->post_data_gap [0].count +
			  fmt->post_data_gap [1].count),
			 fmt->id_gap [0].data);
    }

  /* fill rest of track (gap 4) */
  gap4_len = h->track_length - h->p;
  if (h->dd && (h->cur_mode == DMK_FM))
    gap4_len /= 2;
  write_buf_const (h, gap4_len, fmt->gap_4_data);

  return (1);
}


static int find_address_mark (dmk_handle h,
			      sector_info_t *req_sector)
{
  int i, j;
  uint8_t mark;
  uint8_t *buf;
  sector_info_t sector_info;
  track_format_t *fmt;

  h->cur_mode = req_sector->mode;
  fmt = & track_format [req_sector->mode];

  /* make sure we have a physical position */
  if (h->cur_cylinder < 0)
    {
      fprintf (stderr, "find_address_mark: no physical location\n");
      return (0);
    }

  buf = h->cur_track->buf;

  for (i = 0; i < DMK_MAX_SECTOR; i++)
    {
      h->p = h->cur_track->idam_pointer [i];
      if (h->p == 0)
	break;  /* sectors must be in consecutive slots, no zero entries
		   in IDAM pointer table until end. */

      /* is there room in the track for a complete address mark? */
      if ((h->p + 7) > h->track_length)
	{
	  fprintf (stderr, "find_address_mark: address mark too close to end of track\n");
	  continue;
	}

      init_crc (h);

      /* for MFM, CRC includes the three A1 bytes */
      for (j = 0; j < fmt->id_address_mark [0].count; j++)
	compute_crc (h, fmt->id_address_mark [0].data);

      /* is it actually an address mark? */
      mark = read_buf_byte (h);
      if (mark != fmt->id_address_mark [1].data)
	{
	  fprintf (stderr, "find_address_mark: address mark byte is %02x, should be %02x\n",
		   mark, fmt->id_address_mark [1].data);
	  continue;
	}
      sector_info.cylinder  = read_buf_byte (h);
      sector_info.head      = read_buf_byte (h);
      sector_info.sector    = read_buf_byte (h);
      sector_info.size_code = read_buf_byte (h);
      if (! check_crc (h))
	{
// 	  fprintf (stderr, "find_address_mark: address mark CRC bad\n");
	  continue;
	}

      if ((req_sector->cylinder  != sector_info.cylinder) ||
	  (req_sector->head      != sector_info.head) ||
	  (req_sector->sector    != sector_info.sector) ||
	  (req_sector->size_code != sector_info.size_code))
	continue;

      return (1);
    }

  fprintf (stderr, "find_address_mark: no address mark matches\n");
  return (0);
}


int dmk_read_id (dmk_handle h,
		 sector_info_t *sector_info)
{
  int j;
  uint8_t mark;
  track_format_t *fmt;

  /* make sure we have a physical position */
  if (h->cur_cylinder < 0)
    {
      fprintf (stderr, "dmk_read_id: no physical location\n");
      return (0);
    }

  if (h->read_id_index >= DMK_MAX_SECTOR)
    return (0);

  h->cur_mode = h->cur_track->mfm_sector [h->read_id_index];
  h->p = h->cur_track->idam_pointer [h->read_id_index++];

  if (h->p == 0)
    return (0);

  fmt = & track_format [h->cur_mode];

  /* is there room in the track for a complete address mark? */
  if ((h->p + 7) > h->track_length)
    {
      fprintf (stderr, "dmk_read_id: address mark too close to end of track\n");
      return (0);
    }

  init_crc (h);

  /* for MFM, CRC includes the three A1 bytes */
  for (j = 0; j < fmt->id_address_mark [0].count; j++)
    compute_crc (h, fmt->id_address_mark [0].data);

  /* is it actually an address mark? */
  mark = read_buf_byte (h);
  if (mark != fmt->id_address_mark [1].data)
    {
      fprintf (stderr, "dmk_read_id: address mark byte is %02x, should be %02x\n",
	       mark, fmt->id_address_mark [1].data);
      return (0);
    }

  sector_info->cylinder  = read_buf_byte (h);
  sector_info->head      = read_buf_byte (h);
  sector_info->sector    = read_buf_byte (h);
  sector_info->size_code = read_buf_byte (h);
  sector_info->mode      = h->cur_mode;

  if (! check_crc (h))
    {
      fprintf (stderr, "dmk_read_id: address mark CRC bad\n");
      fprintf (stderr, "mode: %s\n", sector_info->mode == DMK_FM ? "FM" : "MFM");
      fprintf (stderr, "cylinder %d, head %d, sector %d, size code %d\n",
	       sector_info->cylinder, sector_info->head,
	       sector_info->sector, sector_info->size_code);
      return (0);
    }

  return (1);
}


int dmk_read_sector (dmk_handle h,
		     sector_info_t *sector_info,
		     uint8_t *data)
{
  /* find address mark */
  if (! find_address_mark (h, sector_info))
    return (0);

  return (read_data_field (h, sector_info, data));
}


int dmk_write_sector (dmk_handle h,
		      sector_info_t *sector_info,
		      uint8_t *data)
{
  int count;

  /* find address mark */
  if (! find_address_mark (h, sector_info))
    {
      fprintf (stderr, "dmk_write_sector: can't find address mark\n");
      return (0);
    }

  /* skip first part of ID gap before commencing write */
  count = track_format [h->cur_mode].id_gap [0].count;
  if (h->dd & (h->cur_mode == DMK_FM))
    count *= 2;
  advance_p (h, count);

  if (! write_data_field (h, sector_info, 0, data))
    {
      fprintf (stderr, "dmk_write_sector: can't write data field\n");
      return (0);
    }

  return (1);
}


#ifdef ADDRESS_MARK_DEBUG
int dmk_check_address_mark (dmk_handle h,
			    sector_info_t *sector_info)
{
  /* find address mark */
  if (! find_address_mark (h, sector_info))
    return (0);

  return (1);
}
#endif /* ADDRESS_MARK_DEBUG */
