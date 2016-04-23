
// Delay support routines
//

#ifndef _DELAY_H
#define _DELAY_H

#include <tsmtypes.h>

extern void delay_us(unsigned int us);
extern void delay_ms(unsigned int ms);
extern void set_restart_wdt();
extern void set_clock_speed(Uint32 speed);

#endif
