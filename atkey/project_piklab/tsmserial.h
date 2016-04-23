/**
 * RS232 communications
 */

#ifndef __TSMSERIAL_H__
#define __TSMSERIAL_H__

#ifndef KHZ
#error "Must define KHZ to calculate baud rate"
#endif

// Twiddle these as you like BUT remember that not all values work right!
// See the datasheet for what values can work with what clock frequencies.
#ifndef BAUD
#define	BAUD	9600
#endif
#ifndef BAUD_HI
#define BAUD_HI	1
#endif

// This section calculates the proper value for SPBRG from the given
// values of BAUD and BAUD_HI.  Derived from Microchip's datasheet.
#if	(BAUD_HI == 1)
#define	BAUD_FACTOR	(16L*BAUD)
#else
#define	BAUD_FACTOR	(64L*BAUD)
#endif
#define SPBRG_VALUE	(unsigned char)(((KHZ*1000L)-BAUD_FACTOR)/BAUD_FACTOR)

// Wait until the PIC is finished transmitting over RS232
#define FLUSH()		while(!TXIF)

// Sends a literal character down the RS232 pipe.  I.E.  SEND('Q');
#define SEND(C)		do {	FLUSH();	TXREG=C;	} while(0)

#define ASYNC_INIT() do	{			\
	SPBRG=SPBRG_VALUE;			\
	BRGH=BAUD_HI;				\
	SYNC=0; /* Disable Synchronous	*/	\
	SPEN=1; /* Enable serial port	*/	\
	TXEN=1; /* Enable transmission	*/	} while(0)

#ifdef INSTANTIATE_SERIAL
const char hex[]={'0','1','2','3','4','5','6','7','8','9',
                        'A','B','C','D','E','F'};
#else
extern const char hex[];
#endif

// Sends two hex chars.  I.E.  SENDHEX(0xab) will send 'A', then 'B'
#define SENDHEX(H)      do {    SEND(hex[(H)>>4]);              \
                                SEND(hex[(H)&0x0f]); } while(0)


#endif
