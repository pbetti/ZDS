/**
 * Allows you to define, label, read, and write EEPROM data to a
 * pic16 or pic18 chip in SDCC in C.
 *
 * For example:
 *   // Must be a global variable
 *   const char at PIC14_EEPROM+16 str[]={'S','D','C','C','\0'};
 *
 * would put the bytes S, D, C, C, NULL into EEPROM memory at offset
 * 16.  You can declare more than one as long as they don't overlap.
 *
 * You can read the example with READ_EEPROM_ADDRESS(16) through 20.
 *
 * If you want to write the example to EEPROM at runtime, you could
 * do:
 *
 *   EEPROM_WRITE_ADDR(16, 'S')
 *   EEPROM_WRITE_ADDR(17, 'D')
 *   EEPROM_WRITE_ADDR(18, 'C')
 *   EEPROM_WRITE_ADDR(19, 'C')
 *   EEPROM_WRITE_ADDR(20, 0)
 * 
 */
#ifndef __TSMEE_H__
#define __TSMEE_H__

/**
 *  Note that we are referring to bits here, not pic16f628a.
 *  PIC14_EEPROM is for 14-bit pics like the pic16f series.
 *  PIC16_EEPROM is for the 16-bit pic18f series.
 */
#define PIC14_EEPROM    0x2100		// 14-bit PIC EEPROM offset
#define PIC16_EEPROM    0xf00000	// 16-bit PIC EEPROM offset

/**
 * Correct sequence for reading the EEPROM is:
 * @ Set address
 * @ Set RD bit
 * @ Read value from EEDATA
 *
 * This expression does exactly that, first setting EEADR and RD
 * before returning the value of EEDATA.
 *
 * Subsequent reads from EEDATA will return the same value, so
 * if you're using the same value repeatedly, you can just use
 * EEPROM_READ_ADDRESS once and refer to EEDATA directly thereafter.
 */
#define EEPROM_READ_ADDRESS(ADDR) (EEADR=ADDR,RD=1,EEDATA)

/** This EXACT SEQUENCE of instructions is needed, any deviation will
 *  cause the write to FAIL!  The PIC even counts the number of
 *  instructions to check if you did this right!  This means we need
 *  inline ASM, C isn't going to get it Just Right(tm).
 */
#define EEPROM_WRITE_ADDR(ADDR,DATA)	do {		\
	EEADR=ADDR;	/* Set address		*/	\
	EEDATA=DATA;	/* Set data		*/	\
	EECON2=0x00;	/* Get in right bank	*/	\
	__asm	MOVLW	0x55		__endasm;	\
	__asm	MOVWF	EECON2		__endasm;	\
	__asm	MOVLW	0xaa		__endasm;	\
	__asm	MOVWF	EECON2		__endasm;	\
	__asm	BSF	EECON1,1	__endasm;	\
	} while(0)

#endif/*__TSMEE_H__*/
