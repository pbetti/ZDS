/**
  * Copyright (c) 2004, Telecooperation Office (TecO),
  * Universitaet Karlsruhe (TH), Germany.
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
  * modification, are permitted provided that the following conditions
  * are met:
  *
  *   * Redistributions of source code must retain the above copyright
  *     notice, this list of conditions and the following disclaimer.
  *   * Redistributions in binary form must reproduce the above
  *     copyright notice, this list of conditions and the following
  *     disclaimer in the documentation and/or other materials provided
  *     with the distribution.
  *   * Neither the name of the Universitaet Karlsruhe (TH) nor the names
  *     of its contributors may be used to endorse or promote products
  *     derived from this software without specific prior written
  *     permission.
  *
  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
  * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
  * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
  * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
  * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 **/

#ifndef DELAY_C
#define DELAY_C 1

#include <delay.h>

unsigned char _restart_wdt = 0;
Uint32 _clock_speed = 4000000;

void set_restart_wdt()
{
	_restart_wdt = 1;
}

void delay_us(unsigned int us) //wparam
{
  unsigned char counter = 0;
  unsigned int cycles = 0;

  //unsigned long cycles26 = ((freq >> 8) * us) / (15625 * 26);
  cycles = (unsigned int) (((_clock_speed >> 10) * us) >> 17);

  /*
   * Schleifenl&auml;nge ca. 33,5 Zyklen = 2^17 / (15625/4)
   * 
   */

  if (cycles > 1) cycles -= 1; else return; 

  while (cycles > 0) {
    if (!(++counter)) {
      
      if (_restart_wdt)
        restart_wdt();
      else
       _asm nop _endasm;
      
      delay_cycles(128);
    } else {
      _asm
	nop
	nop
	nop
      _endasm;
    }
    delay_cycles(13);
    cycles --;
  }
return;

}


void delay_ms(unsigned int ms) wparam
{
  unsigned char counter = 0;

  unsigned long cycles = (((_clock_speed >> 10) * ms) >> 14) * 125;

  if (cycles > 2) cycles -= 2; else return; 

  while (cycles > 0) {
    if (!(++counter)) {
      if (_restart_wdt)
        restart_wdt();
      else
       _asm nop _endasm;

      delay_cycles(128);
    } else {
      _asm
	nop
        nop
        nop
      _endasm;
    }
    delay_cycles(4);
    cycles --;
  }
return;

}

#else

#warning delay.c was included more than once! Only the first implementation will be used, speed and wdt behaviour will stay the same

#endif

