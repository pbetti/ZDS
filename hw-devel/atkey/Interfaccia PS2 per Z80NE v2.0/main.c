/*
 *	Interfaccia tastiera PS2 per computer Z80NE
 *  
 *	Copyright (C)2014 P.Giaquinto <pino.giaquinto@gmail.com>
 *	Freely distributable.
 *
 *	Release 1.0
 *	  Layout di base previsti: IT e US
 *	  Implementato tasto-interruttore ShiftLock come previsto su LX.387
 *	Release 1.1
 *	  Aggiunto il layout UK (per la mia IBM model M)
 *	  'Evitato' il controllo del BAT code (problematico su alcune tastiere)
 *	  Rimosso il carattere '`' perchè non gestito correttamente dallo Z80NE
 *	  Rimosso il caratere '_' perchè non previsto dal KR2376
 *	Release 2.0
 *	  Alcune 'aggiunte' suggerite da P.Betti (utilizzate nel suo CP/M):
 *		- Controllo tasti Home, Ins, End, PgUp, PgDn, Up, Down, Left e Right
 *		- Controllo su CTRL+ALT+DEL (riavvio Z80)
 *		- Controllo tasti funzione F1-F12
 *	  Implementati ^B, ^C, ^D ed ora anche in NE/DOS se ne 'occupa' il PIC
 *	  'Trasformato' (per motivi 'pratici') lo ShiftLock in CapsLock
 *	  Previsto l'uso del tasto Shift con il CapsLock attivato
 *	  Ripristinati '`' e '_' in previsione della correzione delle mappature
 */

#include <pic.h>
#include <htc.h>
#include <ctype.h>

#include "delay.h"

__CONFIG(UNPROTECT & LVPDIS & BOREN & MCLRDIS & PWRTEN & WDTDIS & INTIO);
// UNPROTECT	-> Program Memory Code and Data Code Protection:	OFF
// LVPDIS		-> Low Voltage Programming:							DISABLED
// BOREN		-> Brown-out Reset:									ENABLED
// MCLRDIS		-> Memory Clear (internally tied to Vdd):			DISABLED
// PWRTEN		-> Power-up Timer:									ENABLED
// WDTDIS		-> Watchdog Timer:									DISABLED
// INTIO		-> Internal Oscillator (4MHz), I/O on RA6 & RA7:	SELECTED

#define lxData PORTB
#define lxStrobe RB7

#define ps2Clock RA0
#define ps2Data RA1
#define z80Break RA2

#define NO_CLRWDT 1			//Forces manual use of Clear Watchdog

#define INPUT_ps2Clock() TRISA0 = 1
#define LOW_ps2Clock() ps2Clock = 0; TRISA0 = 0
#define INPUT_ps2Data() TRISA1 = 1
#define LOW_ps2Data() ps2Data = 0; TRISA1 = 0

// Definire qui il layout utilizzato oppure MULTI_LAYOUT...
#define	MULTI_LAYOUT

// ... e commentare le eventuali definizioni non necessarie
// Ovviamente la definizione di MULTI_LAYOUT ha un senso
// solo se è previsto l'utilizzo di almeno due layout
#ifdef MULTI_LAYOUT

#ifndef LAYOUT_IT
#define LAYOUT_IT
#endif

#ifndef LAYOUT_US
#define LAYOUT_US
#endif

#ifndef LAYOUT_UK
#define LAYOUT_UK
#endif

#endif

///////////////////////////////////////////////////////////////////////////////////////////////////
// Scan-code (CTRL + tasto) compresi tra 0x0D e 0x7D
const unsigned char ctrlAscii[] = {
#ifdef LAYOUT_IT
// Layout IT
																					10,	28,0, // 0x
									 0,  0,  0,  0,  0, 17,  0,0,0,  0, 26, 19,  1, 23,  0,0, // 1x
									 0,  3, 24,  4,  5,  0,  0,0,0,' ', 22,  6, 20, 18,  0,0, // 2x
									 0, 14,  2,  8,  7, 25,  0,0,0,  0, 13, 10, 21,  0,  0,0, // 3x
									 0,  0, 11,  9, 15,  0,  0,0,0,  0,  0, 12,  0, 16,  0,0, // 4x
									 0,  0,  0,  0, 27, 30,  0,0,0,  0, 13, 29,  0,  0,  0,0, // 5x
									 0,  0,  0,  0,  0,  0,  8,0,0,  0,  0,  0,  0,  0,  0,0, // 6x
									 0,  0,  0,  0,  0,  0, 27,0,0,  0,  0,  0,  0,  0		  // 7x
//																								  |
//									 0   1   2   3   4   5   6 7 8   9   A   B   C   D   E F   <--'
#ifdef MULTI_LAYOUT
	,
#else
	};
#endif
#endif

#ifdef LAYOUT_US
// Layout US
																					10,	30,0, // 0x
									 0,  0,  0,  0,  0, 17,  0,0,0,  0, 26, 19,  1, 23,  0,0, // 1x
									 0,  3, 24,  4,  5,  0,  0,0,0,' ', 22,  6, 20, 18,  0,0, // 2x
									 0, 14,  2,  8,  7, 25,  0,0,0,  0, 13, 10, 21,  0,  0,0, // 3x
									 0,  0, 11,  9, 15,  0,  0,0,0,  0,  0, 12,  0, 16,  0,0, // 4x
									 0,  0,  0,  0, 27,  0,  0,0,0,  0, 13, 29,  0, 28,  0,0, // 5x
									 0,  0,  0,  0,  0,  0,  8,0,0,  0,  0,  0,  0,  0,  0,0, // 6x
									 0,  0,  0,  0,  0,  0, 27,0,0,  0,  0,  0,  0,  0		  // 7x
//																								  |
//									 0   1   2   3   4   5   6 7 8   9   A   B   C   D   E F   <--'
#ifdef MULTI_LAYOUT
	,
#else
	};
#endif
#endif

#ifdef LAYOUT_UK
// Layout UK
																					10,	 0,0, // 0x
									 0,  0,  0,  0,  0, 17,  0,0,0,  0, 26, 19,  1, 23,  0,0, // 1x
									 0,  3, 24,  4,  5,  0,  0,0,0,' ', 22,  6, 20, 18,  0,0, // 2x
									 0, 14,  2,  8,  7, 25,  0,0,0,  0, 13, 10, 21,  0,  0,0, // 3x
									 0,  0, 11,  9, 15,  0,  0,0,0,  0,  0, 12,  0, 16,  0,0, // 4x
									 0,  0,  0,  0, 27,  0,  0,0,0,  0, 13, 29,  0, 30,  0,0, // 5x
									 0, 28,  0,  0,  0,  0,  8,0,0,  0,  0,  0,  0,  0,  0,0, // 6x
									 0,  0,  0,  0,  0,  0, 27,0,0,  0,  0,  0,  0,  0};	  // 7x
//																								  |
//									 0   1   2   3   4   5   6 7 8   9   A   B   C   D   E F   <--'
#endif

///////////////////////////////////////////////////////////////////////////////////////////////////
// Scan-code (SHIFT + tasto) compresi tra 0x0D e 0x7D
const unsigned char shiftAscii[] = {
#ifdef LAYOUT_IT
// Layout IT
																					10,'|',0, // 0x
									 0,  0,  0,  0,  0,'Q','!',0,0,  0,'Z','S','A','W','"',0, // 1x
									 0,'C','X','D','E','$','#',0,0,' ','V','F','T','R','%',0, // 2x
									 0,'N','B','H','G','Y','&',0,0,  0,'M','J','U','/','(',0, // 3x
									 0,';','K','I','O','=',')',0,0,':','_','L','`','P','?',0, // 4x
									 0,  0,'*',  0,'{','~',  0,0,0,  0, 13,'}',  0,  0,  0,0, // 5x
									 0,'>',  0,  0,  0,  0,  8,0,0,'1',  0,'4','7',  0,  0,0, // 6x
								   '0','.','2','5','6','8', 27,0,0,'+','3','-','*','9'		  // 7x
//																							      |
//									 0   1   2   3   4   5   6 7 8   9   A   B   C   D   E F   <--'
#ifdef MULTI_LAYOUT
	,
#else
	};
#endif
#endif

#ifdef LAYOUT_US
// Layout US
																					10,'~',0, // 0x
									 0,  0,  0,  0,  0,'Q','!',0,0,  0,'Z','S','A','W','@',0, // 1x
									 0,'C','X','D','E','$','#',0,0,' ','V','F','T','R','%',0, // 2x
									 0,'N','B','H','G','Y','^',0,0,  0,'M','J','U','&','*',0, // 3x
									 0,'<','K','I','O',')','(',0,0,'>','?','L',':','P','_',0, // 4x
									 0,  0,'"',  0,'{','+',  0,0,0,  0, 13,'}',  0,'|',  0,0, // 5x
									 0,  0,  0,  0,  0,  0,  8,0,0,'1',  0,'4','7',  0,  0,0, // 6x
								   '0','.','2','5','6','8', 27,0,0,'+','3','-','*','9'		  // 7x
//																							      |
//									 0   1   2   3   4   5   6 7 8   9   A   B   C   D   E F   <--'
#ifdef MULTI_LAYOUT
	,
#else
	};
#endif
#endif

#ifdef LAYOUT_UK
// Layout UK
																					10,  0,0, // 0x
									 0,  0,  0,  0,  0,'Q','!',0,0,  0,'Z','S','A','W','"',0, // 1x
									 0,'C','X','D','E','$',  0,0,0,' ','V','F','T','R','%',0, // 2x
									 0,'N','B','H','G','Y','^',0,0,  0,'M','J','U','&','*',0, // 3x
									 0,'<','K','I','O',')','(',0,0,'>','?','L',':','P','_',0, // 4x
									 0,  0,'@',  0,'{','+',  0,0,0,  0, 13,'}',  0,'~',  0,0, // 5x
									 0,'|',  0,  0,  0,  0,  8,0,0,'1',  0,'4','7',  0,  0,0, // 6x
								   '0','.','2','5','6','8', 27,0,0,'+','3','-','*','9'};	  // 7x
//																							      |
//									 0   1   2   3   4   5   6 7 8   9   A   B   C   D   E F   <--'
#endif

///////////////////////////////////////////////////////////////////////////////////////////////////
// Scan-code compresi tra 0x0D e 0x7D
const unsigned char normalAscii[] = {
#ifdef LAYOUT_IT
// Layout IT
																					10,	92,0, // 0x
									 0,  0,  0,  0,  0,'q','1',0,0,  0,'z','s','a','w','2',0, // 1x
									 0,'c','x','d','e','4','3',0,0,' ','v','f','t','r','5',0, // 2x
									 0,'n','b','h','g','y','6',0,0,  0,'m','j','u','7','8',0, // 3x
									 0,',','k','i','o','0','9',0,0,'.','-','l','@','p', 39,0, // 4x
									 0,  0,'+',  0,'[','^',  0,0,0,  0, 13,']',  0,  0,  0,0, // 5x
									 0,'<',  0,  0,  0,  0,  8,0,0,'1',  0,'4','7',  0,  0,0, // 6x
								   '0','.','2','5','6','8', 27,0,0,'+','3','-','*','9'		  // 7x
//																								  |
//									 0   1   2   3   4   5   6 7 8   9   A   B   C   D   E F   <--'
#ifdef MULTI_LAYOUT
	,
#else
	};
#endif
#endif

#ifdef LAYOUT_US
// Layout US
																					10,'`',0, // 0x
									 0,  0,  0,  0,  0,'q','1',0,0,  0,'z','s','a','w','2',0, // 1x
									 0,'c','x','d','e','4','3',0,0,' ','v','f','t','r','5',0, // 2x
									 0,'n','b','h','g','y','6',0,0,  0,'m','j','u','7','8',0, // 3x
									 0,',','k','i','o','0','9',0,0,'.','/','l',';','p','-',0, // 4x
									 0,  0, 39,  0,'[','=',  0,0,0,  0, 13,']',  0, 92,  0,0, // 5x
									 0,  0,  0,  0,  0,  0,  8,0,0,'1',  0,'4','7',  0,  0,0, // 6x
								   '0','.','2','5','6','8', 27,0,0,'+','3','-','*','9'		  // 7x
//																							      |
//									 0   1   2   3   4   5   6 7 8   9   A   B   C   D   E F   <--'
#ifdef MULTI_LAYOUT
	,
#else
	};
#endif
#endif

#ifdef LAYOUT_UK
// Layout UK
																					10,'`',0, // 0x
									 0,  0,  0,  0,  0,'q','1',0,0,  0,'z','s','a','w','2',0, // 1x
									 0,'c','x','d','e','4','3',0,0,' ','v','f','t','r','5',0, // 2x
									 0,'n','b','h','g','y','6',0,0,  0,'m','j','u','7','8',0, // 3x
									 0,',','k','i','o','0','9',0,0,'.','/','l',';','p','-',0, // 4x
									 0,  0, 39,  0,'[','=',  0,0,0,  0, 13,']',  0,'#',  0,0, // 5x
									 0, 92,  0,  0,  0,  0,  8,0,0,'1',  0,'4','7',  0,  0,0, // 6x
								   '0','.','2','5','6','8', 27,0,0,'+','3','-','*','9'};	  // 7x
//																							      |
//									 0   1   2   3   4   5   6 7 8   9   A   B   C   D   E F   <--'
#endif

#ifdef MULTI_LAYOUT
eeprom unsigned char ps2Default = 0b00000000;	//Layout di default: IT
#endif

unsigned char commandCode, scanCode = 0;
bit keyUp, extendedKey, shift = 0, ctrl = 0, alt = 0, altGr = 0, shiftLock = 0, capsLock = 0;

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
	DelayUs(100);
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
	while(!ps2Data | !ps2Clock);
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
			if(ps2Data)
				scanCode |= 0b10000000;
		}
		clockCycle();		// Scarta il bit di parità
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

#ifdef MULTI_LAYOUT
//
// I led della tastiera lampeggiano <count+1> volte a intervalli di 100ms
//
void flashPanel(unsigned char count)
{
	do
	{
		setPanel(0b00000111);
		DelayMs(100);
		setPanel(0x00000000);
		DelayMs(100);
	} while(count--);
	
	return;
}
#endif

//
// Funzione principale del programma
//
void main(void)
{
	unsigned char ascii;
	unsigned char functionKey;
#ifdef MULTI_LAYOUT
	unsigned char ps2Config = ps2Default;
#endif
	
	CMCON = 0b00000111;			// ADC disabled
	z80Break = 1; TRISA2 = 0;
	lxData = 0b11111111; TRISB = 0b00000000;

	DelayMs(250);				//
	DelayMs(250);				// In teoria il BAT dovrebbe essere eseguito in 500-750ms
	DelayMs(250);				//
		
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
		ascii = functionKey = 0;

		if(extendedKey)
		{
			switch(scanCode)
			{
				case 0x11:				// R-ALT
					altGr = !keyUp;
					break;
				
				case 0x14:				// R-CTRL
					ctrl = !keyUp;
					break;
			}

			if(!keyUp)
				switch(scanCode)
				{	
					case 0x4A:					// KP-SLASH
						ascii = '/';
						break;
						
					case 0x5A:					// KP-ENTER
						ascii = 0x0D;
						break;
					
					case 0x71:					// KP-DEL
						if(ctrl & alt)			// CTRL+ALT+DEL per riavviare il sistema (Solo CP/M)
							ascii = 0x1F;
						else
							ascii = 0x7F;
						break;
	
					case 0x70:					// INS (Solo CP/M)
						ascii = 0x16;			// CTRL+V (SYN)
						break;
	
					case 0x6C:					// HOME (Solo CP/M)
						ascii = 0x1D;			// CTRL+] (GS)
						break;
	
					case 0x69:					// END (Solo CP/M)
						ascii = 0x14;			// CTRL+T (DC4)
						break;
	
					case 0x7D:					// PGUP (Solo CP/M)
						ascii = 0x13;			// CTRL+S (DC3)
						break;
	
					case 0x7A:					// PGDN (Solo CP/M)
						ascii = 0x07;			// CTRL+G (BEL)
						break;
	
					case 0x75:					// UP (Solo CP/M)
						ascii = 0x15;			// CTRL+U (NAK)
						break;
	
					case 0x72:					// DOWN
						ascii = 0x1A;			// CTRL+Z (SUB)
						break;
	
					case 0x6B:					// LEFT
						ascii = 0x18;			// CTRL+X (CAN)
						break;
	
					case 0x74:					// RIGHT
						ascii = 0x19;			// CTRL+Y (EM)
						break;
				}
		}
		else
		{
			switch(scanCode)
			{
				case 0x11:						// L-ALT
					alt = !keyUp;
					break;
				
				case 0x12:						// L-SHIFT
				case 0x59:						// R-SHIFT
					shift = !keyUp;
					break;
				
				case 0x14:						// L-CTRL
					ctrl = !keyUp;
					break;
			}
			if(!keyUp)
			{
				switch(scanCode)
				{
					case 0x05:
#ifdef MULTI_LAYOUT
						if(alt)					// L-ALT + F1 -> Cambia il layout della tastiera
						{
							// Spegne i led del pannello per 200ms
							setPanel(0b00000000);
							DelayMs(200);
							
							// Cambia il layout della tastiera:
							//  0 => layout IT
							//  1 => layout US
							//  2 => layout UK
							if(++ps2Config > 2)
								ps2Config = 0;
							
							// I led del pannello lampeggiano:
							//  una volta se il layout corrente e' IT
							//  due volte se il layout corrente e' US
							//  tre volte se il layout corrente e' UK
							flashPanel(ps2Config);
							
							// Ripristina lo stato del pannello
							setPanel(capsLock ? 0b00000110 : 0b00000010);
						}
						else					// Tasto funzione F1 (Solo CP/M)
#endif
							functionKey = 'A';
						break;

					case 0x06:					// Tasto funzione F2 (Solo CP/M)
						functionKey = 'B';
						break;
	
					case 0x04:					// Tasto funzione F3 (Solo CP/M)
						functionKey = 'C';
						break;
	
					case 0x0C:					// Tasto funzione F4 (Solo CP/M)
						functionKey = 'D';
						break;
	
					case 0x03:					// Tasto funzione F5 (Solo CP/M)
						functionKey = 'E';
						break;
	
					case 0x0B:					// Tasto funzione F6 (Solo CP/M)
						functionKey = 'F';
						break;
	
					case 0x83:					// Tasto funzione F7 (Solo CP/M)
						functionKey = 'G';
						break;
	
					case 0x0A:					// Tasto funzione F8 (Solo CP/M)
						functionKey = 'H';
						break;
	
					case 0x01:					// Tasto funzione F9 (Solo CP/M)
						functionKey = 'I';
						break;
	
					case 0x09:
#ifdef MULTI_LAYOUT
						if(ctrl & alt)			// CTRL + L-ALT + F10 -> Salva la configurazione della tastiera
						{
							// Spegne i led del pannello per 200ms
							setPanel(0b00000000);
							DelayMs(200);
	
							// Salva la configurazione nella EEPROM
							ps2Default = ps2Config;
							
							// I led del pannello lampeggiano cinque volte
							flashPanel(4);
	
							// Ripristina lo stato del pannello
							setPanel(capsLock ? 0b00000110 : 0b00000010);
						}
						else					// Tasto funzione F10 (Solo CP/M)
#endif
							functionKey = 'J';
						break;
						
					case 0x78:					// Tasto funzione F11 (Solo CP/M)
						functionKey = 'K';
						break;
	
					case 0x07:					// Tasto funzione F12 (Solo CP/M)
						functionKey = 'L';
						break;
					
					case 0x58:					// CAPS
						capsLock = !capsLock;
						setPanel(capsLock ? 0b00000110 : 0b00000010);
						break;
	
					default:
						if(ctrl)
						{
							if(scanCode == 0x32)			// CTRL+B (ShiftLock ON<->OFF)
							{
								shiftLock = !shiftLock;
								capsLock = 0;
								setPanel(0b00000010);
							}	
							else
								if(scanCode == 0x21)		// CTRL+C (ShiftLock ON<->OFF)
								{
									capsLock = !capsLock;
									setPanel(capsLock ? 0b00000110 : 0b00000010);
									shiftLock = 0;
								}
								else
									if(scanCode == 0x23)	// CTRL+D (ShiftLock e CapsLock ->OFF)
									{
										shiftLock = capsLock = 0;
										setPanel(0b00000010);
									}
						}	
						else
							if(scanCode > 0x0C && scanCode < 0x7E)
							{
								scanCode -= 0x0D;
								if(ctrl)
#ifdef MULTI_LAYOUT
									ascii = ctrlAscii[ps2Config * 0x71 + scanCode];
#else
									ascii = ctrlAscii[scanCode];
#endif
								else
									if(shift | shiftLock)
									{
										if(shift & shiftLock)
#ifdef MULTI_LAYOUT
											ascii = normalAscii[ps2Config * 0x71 + scanCode];
#else
											ascii = normalAscii[scanCode];
#endif
										else
										{
#ifdef MULTI_LAYOUT
											ascii = shiftAscii[ps2Config * 0x71 + scanCode];
#else
											ascii = shiftAscii[scanCode];
#endif
											if(capsLock)
												ascii = tolower(ascii);
										}
									}
									else
									{
#ifdef MULTI_LAYOUT
										ascii = normalAscii[ps2Config * 0x71 + scanCode];
#else
										ascii = normalAscii[scanCode];
#endif
										if(capsLock)
											ascii = toupper(ascii);
									}
							}
				}
			}
		}
		if(functionKey)
		{
			lxData = 0xE4;			// Codice ESC (già complementato)
			DelayUs(1500);
			lxStrobe = 0;
			DelayUs(1000);
			lxStrobe = 1;
			ascii = functionKey;	// A->F1, B->F2, ..., L->F12
		}

		// Se l'ASCII code è valido viene complementato e trasferito allo
		// Z80NE e dopo una pausa di 1.5ms viene attivato lo Strobe
		if(ascii)
		{
			lxData = ~ascii;
			DelayUs(1500);
			lxStrobe = 0;
		}
		else
			if(alt & altGr)
				z80Break = 0;
			else
				z80Break = 1;
	}
}
