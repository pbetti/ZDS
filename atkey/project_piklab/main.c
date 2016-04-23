/*
 *	Interfaccia tastiera PS2 per computer Z80NE
 *
 *	Copyright (C)2009 P.Giaquinto
 *	Freely distributable.
 */

// #include <pic.h>
// #include <htc.h>

// #include "delay.h"

#define __16f628

#include <pic16f628.h>
#include "tsmtypes.h"
#include "delay.h"

// Set the __CONFIG word:
Uint16 __at(0x2007)  __CONFIG = (_CPD_OFF & _LVP_OFF & _BOREN_ON & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT);

#define RESTART_WDT
Uint32 CLOCK_SPEED = 4000000;


// __CONFIG(UNPROTECT & LVPDIS & BOREN & MCLRDIS & PWRTEN & WDTDIS & INTIO);
// UNPROTECT	-> Program Memory Code and Data Code Protection:	OFF
// LVPDIS		-> Low Voltage Programming:					DISABLED
// BOREN		-> Brown-out Reset:						ENABLED
// MCLRDIS		-> Memory Clear (internally tied to Vdd):			DISABLED
// PWRTEN		-> Power-up Timer:						ENABLED
// WDTDIS		-> Watchdog Timer:						DISABLED
// INTIO		-> Internal Oscillator (4MHz), I/O on RA6 & RA7:	SELECTED

#define lxData PORTB
#define lxStrobe RB7

#define ps2Clock RA0
#define ps2Data RA1
#define z80Break RA2

#define layoutITA 0b00000000
#define layoutUSA 0b00000001

#define NO_CLRWDT 1			//Forces manual use of Clear Watchdog

#define INPUT_ps2Clock() TRISA0 = 1
#define LOW_ps2Clock() ps2Clock = 0; TRISA0 = 0
#define INPUT_ps2Data() TRISA1 = 1
#define LOW_ps2Data() ps2Data = 0; TRISA1 = 0

///////////////////////////////////////////////////////////////////////////////////////////////////
// Scan-code (CTRL + tasto) compresi tra 0x0D e 0x7D
const unsigned char ctrlAscii[] = {
// Layout ITA
																					10, 28,0, // 0x
									 0,  0,  0,  0,  0, 17,  0,0,0,  0, 26, 19,  1, 23,  0,0, // 1x
									 0,  3, 24,  4,  5,  0,  0,0,0,' ', 22,  6, 20, 18,  0,0, // 2x
									 0, 14,  2,  8,  7, 25,  0,0,0,  0, 13, 10, 21,  0,  0,0, // 3x
									 0,  0, 11,  9, 15,  0,  0,0,0,  0,  0, 12,  0, 16,  0,0, // 4x
									 0,  0,  0,  0, 27, 30,  0,0,0,  0, 13, 29,  0,  0,  0,0, // 5x
									 0,  0,  0,  0,  0,  0,  8,0,0,  0,  0,  0,  0,  0,  0,0, // 6x
									 0,  0,  0,  0,  0,  0, 27,0,0,  0,  0,  0,  0,  0,       // 7x
//																								  |
//									 0   1   2   3   4   5   6 7 8   9   A   B   C   D   E F   <--'
// Layout USA
																					10, 30,0, // 0x
									 0,  0,  0,  0,  0, 17,  0,0,0,  0, 26, 19,  1, 23,  0,0, // 1x
									 0,  3, 24,  4,  5,  0,  0,0,0,' ', 22,  6, 20, 18,  0,0, // 2x
									 0, 14,  2,  8,  7, 25,  0,0,0,  0, 13, 10, 21,  0,  0,0, // 3x
									 0,  0, 11,  9, 15,  0,  0,0,0,  0,  0, 12,  0, 16,  0,0, // 4x
									 0,  0,  0,  0, 27,  0,  0,0,0,  0, 13, 29,  0, 28,  0,0, // 5x
									 0,  0,  0,  0,  0,  0,  8,0,0,  0,  0,  0,  0,  0,  0,0, // 6x
									 0,  0,  0,  0,  0,  0, 27,0,0,  0,  0,  0,  0,  0};	  // 7x
//																								  |
//									 0   1   2   3   4   5   6 7 8   9   A   B   C   D   E F   <--'

///////////////////////////////////////////////////////////////////////////////////////////////////
// Scan-code (SHIFT + tasto) compresi tra 0x0D e 0x7D
const unsigned char shiftAscii[] = {
// Layout ITA
																					10,'|',0, // 0x
									 0,  0,  0,  0,  0,'Q','!',0,0,  0,'Z','S','A','W','"',0, // 1x
									 0,'C','X','D','E','$','#',0,0,' ','V','F','T','R','%',0, // 2x
									 0,'N','B','H','G','Y','&',0,0,  0,'M','J','U','/','(',0, // 3x
									 0,';','K','I','O','=',')',0,0,':','_','L','`','P','?',0, // 4x
									 0,  0,'*',  0,'{','~',  0,0,0,  0, 13,'}',  0,  0,  0,0, // 5x
									 0,'>',  0,  0,  0,  0,  8,0,0,'1',  0,'4','7',  0,  0,0, // 6x
								   '0','.','2','5','6','8', 27,0,0,'+','3','-','*','9',		  // 7x
//																								  |
//									 0   1   2   3   4   5   6 7 8   9   A   B   C   D   E F   <--'
// Layout USA
																					10,'~',0, // 0x
									 0,  0,  0,  0,  0,'Q','!',0,0,  0,'Z','S','A','W','@',0, // 1x
									 0,'C','X','D','E','$','#',0,0,' ','V','F','T','R','%',0, // 2x
									 0,'N','B','H','G','Y','^',0,0,  0,'M','J','U','&','*',0, // 3x
									 0,'<','K','I','O',')','(',0,0,'>','?','L',':','P','_',0, // 4x
									 0,  0,'"',  0,'{','+',  0,0,0,  0, 13,'}',  0,'|',  0,0, // 5x
									 0,  0,  0,  0,  0,  0,  8,0,0,'1',  0,'4','7',  0,  0,0, // 6x
								   '0','.','2','5','6','8', 27,0,0,'+','3','-','*','9'};	  // 7x
//																								  |
//									 0   1   2   3   4   5   6 7 8   9   A   B   C   D   E F   <--'

///////////////////////////////////////////////////////////////////////////////////////////////////
// Scan-code compresi tra 0x0D e 0x7D
const unsigned char normalAscii[] = {
// Layout ITA
																					10, 92,0, // 0x
									 0,  0,  0,  0,  0,'q','1',0,0,  0,'z','s','a','w','2',0, // 1x
									 0,'c','x','d','e','4','3',0,0,' ','v','f','t','r','5',0, // 2x
									 0,'n','b','h','g','y','6',0,0,  0,'m','j','u','7','8',0, // 3x
									 0,',','k','i','o','0','9',0,0,'.','-','l','@','p', 39,0, // 4x
									 0,  0,'+',  0,'[','^',  0,0,0,  0, 13,']',  0,  0,  0,0, // 5x
									 0,'<',  0,  0,  0,  0,  8,0,0,'1',  0,'4','7',  0,  0,0, // 6x
								   '0','.','2','5','6','8', 27,0,0,'+','3','-','*','9',		  // 7x
//																								  |
//									 0   1   2   3   4   5   6 7 8   9   A   B   C   D   E F   <--'
// Layout USA
																					10,'`',0, // 0x
									 0,  0,  0,  0,  0,'q','1',0,0,  0,'z','s','a','w','2',0, // 1x
									 0,'c','x','d','e','4','3',0,0,' ','v','f','t','r','5',0, // 2x
									 0,'n','b','h','g','y','6',0,0,  0,'m','j','u','7','8',0, // 3x
									 0,',','k','i','o','0','9',0,0,'.','/','l',';','p','-',0, // 4x
									 0,  0, 39,  0,'[','=',  0,0,0,  0, 13,']',  0, 92,  0,0, // 5x
									 0,  0,  0,  0,  0,  0,  8,0,0,'1',  0,'4','7',  0,  0,0, // 6x
								   '0','.','2','5','6','8', 27,0,0,'+','3','-','*','9'};	  // 7x
//																								  |
//									 0   1   2   3   4   5   6 7 8   9   A   B   C   D   E F   <--'

__data unsigned char __at(0x2100) ps2Default = 0b00000000;

unsigned char commandCode, scanCode = 0;
unsigned char keyUp, extendedKey, shift = 0, ctrl = 0, alt = 0, altGr = 0, shiftLock = 0;

//
// Scarta un ciclo completo di clock
//
void clockCycle(void)
{
	while(!ps2Clock);	// Attende fronte di salita
	while(ps2Clock);	// Attende fronte di discesa

	return;
}

//
// Invia un comando alla tastiera
//
void sendCommandCode(void)
{
	unsigned char n = 9;
	unsigned char parity = 1;
	
	LOW_ps2Data();
	LOW_ps2Clock();
	delay_us(100);
	INPUT_ps2Clock();
	while(ps2Clock);
	
	while(--n)
	{
		if(commandCode & 0b00000001)
			ps2Data = 1;
		else
			ps2Data = 0;
		clockCycle();
		if(commandCode & 0b00000001)
			++parity;
		commandCode >>= 1;
	}
	
	if(parity & 0b00000001)
		ps2Data = 1;
	else
		ps2Data = 0;
	clockCycle();
	
	INPUT_ps2Data();
	while(ps2Data);
	while(ps2Clock);
	while(!ps2Data || !ps2Clock);
	LOW_ps2Clock();
		
	return;
}

//
// Legge lo scan-code di un eventuale tasto premuto/rilasciato
//
void readScanCode(void)
{
	unsigned char n;

	keyUp = extendedKey = 0;

	do
	{
		n = 9; scanCode = 0;

		INPUT_ps2Clock();
		while(ps2Clock);
		
		while(--n)
		{
			scanCode >>= 1;
			clockCycle();
			if(ps2Data) scanCode |= 0b10000000;
		}
		clockCycle();		// Scarta il bit di parita'
		clockCycle();		// Scarta il bit di stop
		
		while(!ps2Clock);
		LOW_ps2Clock();
		
		if(scanCode == 0xF0)
			keyUp = 1;
		else
			if(scanCode == 0xE0)
				extendedKey = 1;
	} while(scanCode == 0xE0 || scanCode == 0xF0);

	return;
}

//
// Modifica lo stato dei led sulla tastiera
//
void setPanel(unsigned char leds)
{
	commandCode = 0xED;
	do
	{
		sendCommandCode();
		readScanCode();
	} while(scanCode != 0xFA);
	
	commandCode = leds;
	do
	{
		sendCommandCode();
		readScanCode();
	} while(scanCode != 0xFA);

	return;
}

//
// I led della tastiera lampeggiano <count+1> volte a intervalli di 100ms
void flashPanel(unsigned char count)
{
	do
	{
		setPanel(0b00000111);
		delay_ms(100);
		setPanel(0x00000000);
		delay_ms(100);
	} while(count--);
	
	return;
}
	

//
// Funzione principale del programma
//
void main(void)
{
	unsigned char ascii;
	unsigned char ps2Config = ps2Default;
	
	CMCON = 0b00000111;			// ADC disabled
	z80Break = 1; TRISA2 = 0;
	lxData = 0b11111111; TRISB = 0b00000000;

	// Attende il BAT code (Basic Assurance Test)
	while(!scanCode)
		readScanCode();
		
	// NumLock (tastierino numerico) sempre attivo
	setPanel(0b00000010);

	// Interpreta gli scan-code ed invia il corrispondente ASCII-code allo Z80NE
	for(;;)
	{	
		do
		{
			readScanCode();
		} while (!scanCode);
		
		lxStrobe = 1;
		ascii = 0;

		if(extendedKey)
			switch(scanCode)
			{
				case 0x11:				// R-ALT
					altGr = !keyUp;
					break;
				
				case 0x14:				// R-CTRL
					ctrl = !keyUp;
					break;
				
				case 0x4A:				// KP-SLASH
					if(!keyUp)
						ascii = '/';
					break;
					
				case 0x5A:				// KP-ENTER
					if(!keyUp)
						ascii = 0x0D;
					break;
				
				case 0x71:				// KP-DEL
					if(!keyUp)
						ascii = 0x7F;
					break;
			}
		else
			switch(scanCode)
			{
				case 0x05:				// ALT + F1 -> Cambia il layout della tastiera
					if(!keyUp & alt)
					{
						// Spegne i led del pannello per 200ms
						setPanel(0b00000000);
						delay_ms(200);
						
						// Cambia il layout della tastiera (ITA <> USA)
						ps2Config ^= 0b00000001;
						
						// I led del pannello lampeggiano:
						// - una volta se il layout corrente e' ITA
						// - due volte se il layout corrente e' USA
						flashPanel(ps2Config & 0b00000001);
						
						// Ripristina lo stato del pannello
						setPanel(shiftLock ? 0b00000110 : 0b00000010);
					}
					break;
				
				case 0x09:				// ALT + F10 -> Salva la configurazione della tastiera
					if(!keyUp & ctrl & alt)
					{
						// Spegne i led del pannello per 200ms
						setPanel(0b00000000);
						delay_ms(200);

						// Salva la configurazione nella EEPROM
						ps2Default = ps2Config;
						
						// I led del pannello lampeggiano tre volte
						flashPanel(2);

						// Ripristina lo stato del pannello
						setPanel(shiftLock ? 0b00000110 : 0b00000010);
					}
					break;
					
				case 0x11:				// L-ALT
					alt = !keyUp;
					break;
				
				case 0x12:				// L-SHIFT
				case 0x59:				// R-SHIFT
					shift = !keyUp;
					break;
				
				case 0x14:				// L-CTRL
					ctrl = !keyUp;
					break;
				
				case 0x58:				// CAPS
					if(!keyUp)
					{
						shiftLock = !shiftLock;
						setPanel(shiftLock ? 0b00000110 : 0b00000010);
					}
					break;
				
				default:
					if(!keyUp && scanCode > 0x0C && scanCode < 0x7E)
					{
						scanCode -= 0x0D;
						if(ps2Config & layoutUSA)
							scanCode += 0x71;
						
						if(ctrl)				// CTRL + tasto
							ascii = ctrlAscii[scanCode];
						else
							if(shift | shiftLock)	// SHIFT + tasto
								ascii = shiftAscii[scanCode];
							else
								ascii = normalAscii[scanCode];
					}
			}
		
		// Se l'ASCII code e' valido viene complementato e trasferito allo
		// Z80NE e dopo una pausa di 1.5ms viene attivato lo Strobe
		if(ascii)
		{
			lxData = ~ascii;
			delay_us(1500);
			lxStrobe = 0;
		}
		else
			if(alt & altGr)
				z80Break = 0;
			else
				z80Break = 1;
	}
}
