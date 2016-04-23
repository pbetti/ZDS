/**
 *	This defines a function and some handy macros for time-delays
 *	The main macros take arguments in cycles, not time, but on a PIC
 *	with a 4MHz clock, one cycle nicely corresponds to one microsecond.
 *
 *	It covers the range from 13 cycles to 190,000 cycles with
 *	rather good accuracy, perhaps within 5% or so.
 *
 *	There are also macros to do so by time period, assuming
 *	KHZ is defined somewhere, but these have limits like
 *	the macros:
 *		Clock	Small Max	Big Max
 *		20MHz	150us		38000us
 *		10MHz	300us		76000us
 *		4MHz	750us		190000us
 *		1MHz	3000us		760000us
 *		100KHz	30000us		7600000us
 *		48KHz	62500us		15833333us
 *		32KHz	93750us		23750000us
 *
 *	If you exceed these, your compiler will likely warn you of an 
 *	overflow.
 *
 *	Also note that, while the internal 4MHz clock is decently 
 *	accurate, the internal 48Khz oscillator is very rough.  :)
 *	Had to dig out a 32.768KHz crystal oscillator to verify this 
 *	worked at low speeds...
 *
 *	If you're linking several C files together that all include
 *	tsmdelay.h, INSTANTIATE_DELAY should only be defined in one of
 *	them, or your compiler will complain of duplicate symbols.
 */
#ifndef __TSMDELAY_H__
#define __TSMDELAY_H__

#include "tsmtypes.h"

#ifndef KHZ
#error "Can't calculate delays when KHZ not defined"
#endif

typedef struct dvars
{
	Uint8 loop_x, loop_b, loop_c;
} dvars;


/**
 *	INSTANTIATE_DELAY tells it to actually define the cycle_eater 
 *	function and the loop variables it needs.  Otherwise, it assumes
 *	that they're externals defined elsewhere.
 */
#ifdef INSTANTIATE_DELAY

dvars dvar;

// We're using precisely timed inline ASM.
// Therefore these variables must all be in the same bank, or
// accessible from all banks.
//volatile Uint8 __at 0x20 loop_x;
//volatile Uint8 __at 0x21 loop_b;
//volatile Uint8 __at 0x22 loop_c;

/**
 *	Fixing x at 191 so b is essentially multiples of cmax
 */
void cycle_eater(void)
{
	__asm	banksel	_dvar	// mumblegrumble
		nop
delay_big:	movlw	191		// Calibrated for b*764 cycles
		movwf	_dvar+0	// Load W into reg
delay_inner:	nop	// To make the inner loop take 4 cycles per
		decfsz	_dvar+0, 1
		goto	delay_inner
		decfsz	_dvar+1, 1
		goto	delay_big
correction:	decfsz	_dvar+2, 1
		goto	correction
	__endasm;
}

#else
/**
 *	Assume loop variables and cycle_eater are declared elsewhere,
 *	make them externals
 */

// We're using precisely timed inline ASM.
// Therefore these variables must all be in the same bank, or
// accessible from all banks.
extern dvars dvar;
//extern volatile Uint8 loop_x;
//extern volatile Uint8 loop_b;
//extern volatile Uint8 loop_c;

/**
 * Delays a given number of cycles based on values in
 * loop_x, loop_b, loop_c.  You'll probably find it way easier to
 * use the macros.
 */
void cycle_eater(void);

#endif

// This is how long cycle_eater takes for values of X, B, and C.
#define LOOP_CYCLES(X, B, C)	((X*B*4)+(C*3)+13)

/**
 * Sets up the values in dvar without actually doing the delay.
 * If these calculations aren't happening at compile-time,
 * they can take way longer than the delay you want, so do them first!
 */
#define SAVE_CYCLES_BIG(Y, X)	do {				\
		(Y).loop_b=((X)-16LU)/764LU;			\
		(Y).loop_c=((((X)-16LU)%764LU)/3LU)+1;		\
	} while(0)

/**
 *	Use this macro for delays over 750 cycles and under
 *	190,000 cycles.
 */
#define CYCLES_BIG(X)	do {					\
		SAVE_CYCLES_BIG(dvar, X);			\
		cycle_eater();					\
	} while(0)

/**
 *	Use this macro to call a big delay previously calculated.
 */
#define CALL_CYCLES_BIG(Y)	do {				\
		dvar.loop_x=(Y).loop_x;				\
		dvar.loop_b=(Y).loop_b;				\
		dvar.loop_c=(Y).loop_c;				\
		cycle_eater();					\
	}	while(0)

/**
 * Sets up the values in dvar without actually doing the delay.
 * If these calculations aren't happening at compile-time,
 * they can take way longer than the delay you want, so do them first!
 */
#define SAVE_CYCLES_SMALL(Y, X) do {				\
		(Y).loop_c=((X)-11LU)/3LU;			\
	} while(0)

#define SAVE_CYCLES_SMALL_U8(Y, X) do {				\
		(Y)=((X)-11LU)/3LU;				\
	} while(0)

/**
 *	Use this macro for delays under 750 cycles and over 13 cycles.
 */
#define CYCLES_SMALL(X) do {					\
		SAVE_CYCLES_SMALL(dvar, X);			\
		__asm	BANKSEL	_dvar		__endasm;	\
		__asm	CALL	correction	__endasm;	\
	} while(0)

/**
 *	Use this macro to call a small delay previously calculated.
 */
#define CALL_CYCLES_SMALL(Y)	do {				\
		dvar.loop_c=(Y).loop_c;				\
		__asm	BANKSEL	_dvar		__endasm;	\
		__asm	CALL	correction	__endasm;	\
	} while(0)

#define CALL_CYCLES_SMALL_U8(Y)	do {				\
		dvar.loop_c=(Y);				\
		__asm	BANKSEL	_dvar		__endasm;	\
		__asm	CALL	correction	__endasm;	\
	} while(0)

/**
 *	Calculates cycles from microseconds based on clock speed relative 
 *	to 4MHz.
 */
#define US_CYCLES(N)		(((N)*(KHZ))/4000LU)
#define DELAY_SMALL_US(X)	CYCLES_SMALL(	US_CYCLES(X)	)
#define DELAY_BIG_US(X)		CYCLES_BIG(	US_CYCLES(X)	)

#define SAVE_SMALL_US(Y,X)	SAVE_CYCLES_SMALL(Y, US_CYCLES(X))
#define SAVE_SMALL_US_U8(Y,X)	SAVE_CYCLES_SMALL_U8(Y, US_CYCLES(X))
#define SAVE_BIG_US(Y, X)	SAVE_CYCLES_BIG(Y, US_CYCLES(X)	)

#define CALL_BIG_US		CALL_CYCLES_BIG
#define CALL_SMALL_US		CALL_CYCLES_SMALL

#define CALL_SMALL_US_U8	CALL_CYCLES_SMALL_U8

//#define DELAY_SMALL_US(X)	CYCLES_SMALL( ((X)*(KHZ))/4000LU )
//#define DELAY_BIG_US(X)		CYCLES_BIG( ((X)*(KHZ))/4000LU	)


#endif/*__TSMDELAY_H__*/
