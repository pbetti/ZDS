/**
 * Implements a CRC16 algorithm.
 *
 * How to use:
 * 1) Declare a crc16 variable somewhere.
 *
 *	crc16 crc;
 *
 * 2) Initialize it.
 *
 *	CRC16_INIT(crc);
 *
 * 3) For each byte, do this:
 *
 *	CRC16_NEXT(crc, byte);
 *
 * 4) When you're done:
 *
 *	CRC16_FINISH(crc);
 *
 * 5) The finished checksum is available in crc.bcchi and crc.bcclo.
 *	You can also access them as an array, crc.bytes[n], or
 *	a 16-bit unsigned integer, crc.word.
 *
 */
#ifndef __TSM_CRC16_H__
#define __TSM_CRC16_H__

typedef union crc16 {
	// Many modes of access, same data.
	struct 	{	unsigned char bcclo, bcchi;	};
	unsigned char bytes[2];
	unsigned short word;
} crc16;

// We start at 0xff,0xff.  Some methods/devices start at 0x00,0x00 instead.
#define CRC16_INIT(X)	do { (X).bcclo=0xff; (X).bcchi=0xff; } while(0)

#define CRC16_NEXT(X,C)	do {			\
		unsigned char _new=(C),_tmp;	\
		_new^=(X).bcclo;		\
		_tmp=_new<<4;			\
		_new=_tmp^_new;			\
		_tmp=_new>>5;			\
		(X).bcclo=(X).bcchi;		\
		(X).bcchi=_new^_tmp;		\
		_tmp=_new<<3;			\
		(X).bcclo=(X).bcclo^_tmp;	\
		_tmp=_new>>4;			\
		(X).bcclo=(X).bcclo^_tmp;	\
	} while(0)

#define CRC16_FINISH(X)	do { (X).bcclo^=0xff; (X).bcchi^=0xff;}while(0)

#endif/*__TSM_CRC16_H__*/
