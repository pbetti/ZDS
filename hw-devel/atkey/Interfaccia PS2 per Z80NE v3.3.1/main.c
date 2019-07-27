/*
 *	Interfaccia tastiera PS/2 per computer Z80NE/Z80DS
 *  
 *	Copyright (C)2014 P.Giaquinto <pino.giaquinto@gmail.com>
 *	Freely distributable.
 *
 *	Release 1.0.0
 *	  Layout di base previsti: IT e US
 *	  Implementato tasto-interruttore ShiftLock come previsto su LX.387
 *	Release 1.1.0
 *	  Aggiunto il layout UK (per la mia IBM model M).
 *	  'Evitato' il controllo del BAT code (problematico su alcune tastiere).
 *	  Rimosso il carattere '`' perchè non gestito correttamente dallo Z80NE.
 *	  Rimosso il caratere '_' perchè non previsto dal KR2376
 *	Release 2.0.0
 *	  Alcune 'aggiunte' suggerite da P.Betti (utilizzate nel suo CP/M):
 *		- Controllo tasti Home, Ins, End, PgUp, PgDn, Up, Down, Left e Right
 *		- Controllo su CTRL+ALT+DEL (riavvio Z80)
 *		- Controllo tasti funzione F1-F12
 *	  Implementati ^B, ^C, ^D ed ora anche in NE/DOS se ne 'occupa' il PIC.
 *	  'Trasformato' (per motivi 'pratici') lo ShiftLock in CapsLock.
 *	  Previsto l'uso del tasto Shift con il CapsLock attivato.
 *	  Ripristinati '`' e '_' in previsione della correzione delle mappature
 *	Release 2.1.0
 *	  I tasti Home, Ins, End, etc. seguono lo standard di WS (WordStarDiamond).
 *	  Rimossi i tasti dedicati al NE-DOS, questa versione e' specifica per CP/M
 *	Release 2.2.0
 *	  Cambiate per esigenze tecniche le associazioni con Home, End, PgUp e PgDn
 *	  (vedi Quick Menu di WS) ed aggiunte alcune nuove combinazioni CTRL+key che
 *	  ritengo possano essere di frequente utilizzo (^A, ^F, ^W, ^Z e ^T)
 *  Release 2.2.1
 *    Modificate le associazioni con PgUp e PgDn perchè preferisco lo standard
 *    ZDE (ovvero quello di WS) che userò per editare codice in C, Fortran, etc.
 *    Modificata l'associazione con TAB che ora non restituisce più Line Feed
 *    bensì il più utile Horizontal Tabulate, molto utilizzato con WS e ZDE.
 *    Ritardato lo STROBE dopo il ^Q o ESC dei tasti Quick Menu di WS e dei
 *    tasti funzione richiesti da P.Betti. Molto spesso il sistema non riusciva
 *    a individuarli a causa del poco tempo per cui restavano disponibili sulla
 *    porta della tastiera. In particolare ho portato il ritardo da 1.5ms a 3ms
 *    ed ora sembra funzionare tutto perfettamente
 *  Release 3.0.0
 *    Adattato e ricompilato il codice utilizzando il nuovo compilatore XC8 1.45
 *    su MPLAB X IDE 4.10 ottimizzando per ottenere il minimo 'ingombro'.
 *    Per gestire i tre layout ora ho comunque bisogno di più 'spazio' che ho
 *    ottenuto sostituendo il PIC 16F628A con un più 'capiente' 16F648A
 *  Release 3.1.0
 *    Implementata la scelta della modalità della tastiera tra la classica Z80NE
 *    (NEDOS/SONE) e la nuova Z80WS/DS (WORDSTAR/DARKSTAR)
 *  Release 3.2.0
 *    Implementata l'attivazione/disattivazione del pad numerico.
 *    Ripristinato il controllo del BAT code all'avvio
 *  Release 3.2.1
 *    Utilizzata una soluzione alternativa (timer) per i ritardi 'lunghi' in
 *    quanto le funzioni 'delay' del nuovo XC8 risultano essere poco affidabili.
 *    Per lo stesso motivo ho ritardato ulteriormente lo STROBE dopo il ^Q dei
 *    tasti Quick Menu di WS e dopo l'ESC dei tasti funzione portandolo a 4.5ms
 *  Release 3.2.2
 *    La combinazione ^^ non prevista nei layout US e UK (a causa del fatto che
 *    per ottenerla sarebbe stato necessario analizzare contemporaneamente lo
 *    stato dei tasti 6, SHIFT e CTRL) è stata associata alla combinazione ^6
 *    realizzando in tal modo una notevole semplificazione del codice
 *  Release 3.3.0
 *    Implementato il reset HW dello Z80 eseguito utilizzando la combinazione di
 *    tasti CTRL + ALT + DEL che predispongono il pin RA3 del PIC come OUTPUT in
 *    condizione logica ZERO in caso di riavvio, altrimenti predisposto in 'High
 *    Impedance Mode' (INPUT) in normali condizioni di lavoro
 */

// PIC16F648A Configuration Bit Settings
// 'C' source line config statements
// CONFIG
#pragma config FOSC = INTOSCIO  // Oscillator Selection bits (INTOSC oscillator: I/O function on
                                //  RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
#pragma config WDTE = OFF       // Watchdog Timer Enable bit (WDT disabled)
#pragma config PWRTE = ON       // Power-up Timer Enable bit (PWRT enabled)
#pragma config MCLRE = OFF      // RA5/MCLR/VPP Pin Function Select bit (RA5/MCLR/VPP pin function is
                                //  digital input, MCLR internally tied to VDD)
#pragma config BOREN = ON       // Brown-out Detect Enable bit (BOD enabled)
#pragma config LVP = OFF        // Low-Voltage Programming Enable bit (RB4/PGM pin has digital I/O function,
                                //  HV on MCLR must be used for programming)
#pragma config CPD = OFF        // Data EE Memory Code Protection bit (Data memory code protection off)
#pragma config CP = OFF         // Flash Program Memory Code Protection bit (Code protection off)

// #pragma config statements should precede project file includes.
// Use project enums instead of #define for ON and OFF.
#include <xc.h>

#define _XTAL_FREQ 4000000  // FOSC frequency for _delay() library

#include <ctype.h>

#define lxData PORTB
#define lxStrobe RB7

#define ps2Clock RA0        // PS/2 -> CLOCK
#define ps2Data RA1         // PS/2 -> DATA
#define z80Break RA2        // Z80 -> /NMI
#define z80Reset RA3        // Z80 -> /RESET

#define NO_CLRWDT 1         //Forces manual use of Clear Watchdog

#define INPUT_ps2Clock() TRISA0 = 1
#define LOW_ps2Clock() ps2Clock = 0; TRISA0 = 0
#define INPUT_ps2Data() TRISA1 = 1
#define LOW_ps2Data() ps2Data = 0; TRISA1 = 0
#define INPUT_z80Reset() TRISA3 = 1
#define LOW_z80Reset() z80Reset = 0; TRISA3 = 0

// Decommentare la definizione seguente per implementare i tasti speciali
// come Home, End, PgUp, PgDn, etc. secondo lo standard CP/M WordStar...
#define WORDSTAR

// ... e decommentare la definizione seguente per includere le combinazioni
// di tasti previste nel progetto dell'interfaccia MultiFunzione di P.Betti
#ifdef WORDSTAR
#define DARKSTAR
#endif

// Definire qui il layout utilizzato oppure MULTI_LAYOUT...
// #define LAYOUT_IT
// #define LAYOUT_US
// #define LAYOUT_UK
#define	MULTI_LAYOUT

// ... e commentare le eventuali definizioni non necessarie
// Ovviamente la definizione di MULTI_LAYOUT ha un senso
// solo se è previsto l'utilizzo di almeno due layout
#ifdef MULTI_LAYOUT

#define LAYOUTS 3   // Numero layouts

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
// Scan-code (CTRL + tasto) compresi tra 0x0E e 0x7D
const unsigned char ctrlAscii[] = {
#ifdef LAYOUT_IT
// Layout IT
                                                                                        28,0, // 0x
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
                                                                                        30,0, // 0x
									 0,  0,  0,  0,  0, 17,  0,0,0,  0, 26, 19,  1, 23,  0,0, // 1x
									 0,  3, 24,  4,  5,  0,  0,0,0,' ', 22,  6, 20, 18,  0,0, // 2x
									 0, 14,  2,  8,  7, 25, 30,0,0,  0, 13, 10, 21,  0,  0,0, // 3x
									 0,  0, 11,  9, 15,  0,  0,0,0,  0,  0, 12,  0, 16,  0,0, // 4x
									 0,  0,  0,  0, 27,  0,  0,0,0,  0, 13, 29,  0, 28,  0,0, // 5x
									 0,  0,  0,  0,  0,  0,  8,0,0,  0,  0,  0,  0,  0,  0,0, // 6x
									 0,  0,  0,  0,  0,  0, 27,0,0,  0,  0,  0,  0,  0		  // 7x
//																								  |
//									 0   1   2   3   4   5   6 7 8   9   A   B   C   D   E F   <--'
#ifdef MULTI_LAYOUT
#ifdef LAYOUT_UK
	,
#else
	};
#endif
#endif
#endif

#ifdef LAYOUT_UK
// Layout UK
                                                                                         0,0, // 0x
									 0,  0,  0,  0,  0, 17,  0,0,0,  0, 26, 19,  1, 23,  0,0, // 1x
									 0,  3, 24,  4,  5,  0,  0,0,0,' ', 22,  6, 20, 18,  0,0, // 2x
									 0, 14,  2,  8,  7, 25, 30,0,0,  0, 13, 10, 21,  0,  0,0, // 3x
									 0,  0, 11,  9, 15,  0,  0,0,0,  0,  0, 12,  0, 16,  0,0, // 4x
									 0,  0,  0,  0, 27,  0,  0,0,0,  0, 13, 29,  0, 30,  0,0, // 5x
									 0, 28,  0,  0,  0,  0,  8,0,0,  0,  0,  0,  0,  0,  0,0, // 6x
									 0,  0,  0,  0,  0,  0, 27,0,0,  0,  0,  0,  0,  0  	  // 7x
//																								  |
//									 0   1   2   3   4   5   6 7 8   9   A   B   C   D   E F   <--'
};
#endif
///////////////////////////////////////////////////////////////////////////////////////////////////
// Scan-code (SHIFT + tasto) compresi tra 0x0E e 0x7D
const unsigned char shiftAscii[] = {
#ifdef LAYOUT_IT
// Layout IT
                                                                                       '|',0, // 0x
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
                                                                                       '~',0, // 0x
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
#ifdef LAYOUT_UK
	,
#else
	};
#endif
#endif
#endif

#ifdef LAYOUT_UK
// Layout UK
                                                                                         0,0, // 0x
									 0,  0,  0,  0,  0,'Q','!',0,0,  0,'Z','S','A','W','"',0, // 1x
									 0,'C','X','D','E','$',  0,0,0,' ','V','F','T','R','%',0, // 2x
									 0,'N','B','H','G','Y','^',0,0,  0,'M','J','U','&','*',0, // 3x
									 0,'<','K','I','O',')','(',0,0,'>','?','L',':','P','_',0, // 4x
									 0,  0,'@',  0,'{','+',  0,0,0,  0, 13,'}',  0,'~',  0,0, // 5x
									 0,'|',  0,  0,  0,  0,  8,0,0,'1',  0,'4','7',  0,  0,0, // 6x
								   '0','.','2','5','6','8', 27,0,0,'+','3','-','*','9'  	  // 7x
//																							      |
//									 0   1   2   3   4   5   6 7 8   9   A   B   C   D   E F   <--'
};
#endif
///////////////////////////////////////////////////////////////////////////////////////////////////
// Scan-code compresi tra 0x0E e 0x7D
const unsigned char normalAscii[] = {
#ifdef LAYOUT_IT
// Layout IT
                                                                                        92,0, // 0x
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
                                                                                       '`',0, // 0x
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
#ifdef LAYOUT_UK
	,
#else
	};
#endif
#endif
#endif

#ifdef LAYOUT_UK
// Layout UK
                                                                                       '`',0, // 0x
									 0,  0,  0,  0,  0,'q','1',0,0,  0,'z','s','a','w','2',0, // 1x
									 0,'c','x','d','e','4','3',0,0,' ','v','f','t','r','5',0, // 2x
									 0,'n','b','h','g','y','6',0,0,  0,'m','j','u','7','8',0, // 3x
									 0,',','k','i','o','0','9',0,0,'.','/','l',';','p','-',0, // 4x
									 0,  0, 39,  0,'[','=',  0,0,0,  0, 13,']',  0,'#',  0,0, // 5x
									 0, 92,  0,  0,  0,  0,  8,0,0,'1',  0,'4','7',  0,  0,0, // 6x
								   '0','.','2','5','6','8', 27,0,0,'+','3','-','*','9'  	  // 7x
//																							      |
//									 0   1   2   3   4   5   6 7 8   9   A   B   C   D   E F   <--'
};
#endif

eeprom unsigned char ps2Default = 0b00000000;	// b0,b1 -> Layout predefinito: IT
                                                // b2    -> Modalità predefinita: Z80NE
                                                // b3    -> Stato predefinito NumLock: OFF
                                                // b4-b7 -> Inutilizzati

bit keyUp, extendedKey, numLock, shift = 0, ctrl = 0, alt = 0, altGr = 0, capsLock = 0;
#ifdef WORDSTAR
bit wordStar = 0;
#endif

//
// Genera un ritardo di <us> microsecondi
//
void delayUs(unsigned us)
{
      __delay_us(us);
}

//
// Genera un ritardo di <count * 100> millisecondi
//
void delay_100ms(unsigned char count)
{
    T0CS = 0;               // Internal instruction cycle clock
    T0SE = 0;               // Reacting on rising edge
    PSA = 0;                // Prescaler assigned to Timer0 module
    PS0 = PS1 = PS2 = 1;    // Prescaler Rate Select bits, set to divide by 256

    TMR0 = 126;             // TMR0 Initiation for 99.8ms
        for(unsigned char i = 3 * count; i > 0; --i)
        {
            while(!T0IF);
            T0IF = 0;
        }
}

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
void sendCommandCode(unsigned char cmd)
{
	unsigned char n = 9;
	unsigned char parity = 1;

	// To send data, it must first put the Clock and Data lines in a "Request-to-send" state
    LOW_ps2Clock();                 // Inhibit communication by pulling Clock low...
    delayUs(100);                   // ... and do it for at least 100us
	LOW_ps2Data();                  // Apply "Request-to-send" by pulling Data low...
	INPUT_ps2Clock();               // ... then release the Clock line
	while(ps2Clock);                // Wait for the device to bring the Clock line low

	// Set/reset the Data line to send all data bits and parity bit 
    while(--n)
	{
		if(cmd & 0b00000001)
			ps2Data = 1;
		else
			ps2Data = 0;
		clockCycle();
		if(cmd & 0b00000001)
			++parity;
		cmd >>= 1;
	}

	if(parity & 0b00000001)
		ps2Data = 1;
	else
		ps2Data = 0;
	clockCycle();
	
	INPUT_ps2Data();                // Release the Data line
	while(ps2Data);                 // Wait for the device to bring Data low
	while(ps2Clock);                // Wait for the device to bring Clock low
	while(!ps2Data | !ps2Clock);    // Wait for the device to release Data and Clock
	LOW_ps2Clock();

	return;
}

//
// Legge lo scan-code di un eventuale tasto premuto/rilasciato
//
unsigned char readScanCode(void)
{
	unsigned char n, code;

	keyUp = extendedKey = 0;

	do
	{
		n = 9; code = 0;

		INPUT_ps2Clock();
		while(ps2Clock);
		
		while(--n)
		{
			code >>= 1;
			clockCycle();
			if(ps2Data)
				code |= 0b10000000;
		}
		clockCycle();		// Scarta il bit di parità
		clockCycle();		// Scarta il bit di stop
		
		while(!ps2Clock);
		LOW_ps2Clock();
		
		if(code == 0xF0)
			keyUp = 1;
		else
			if(code == 0xE0)
				extendedKey = 1;
	} while(code == 0xE0 || code == 0xF0);

	return code;
}

//
// Modifica lo stato dei led sulla tastiera
//
void setPanel(unsigned char status)
{
    // LEDs status: b0    -> Scroll Lock Led Status
    //              b1    -> Num Lock Led Status
    //              b2    -> Caps Lock Led Status
    //              b3-b7 -> Not Used

    char r = 0xFE;      // Keyboard response code:
                        //  0xFA -> Acknoledge command/data
                        //  0xFE -> Resend (something was wrong)
    
	while(r == 0xFE)
	{
		sendCommandCode(0xED);          // Send 'Set LEDs' command
        while(!(r = readScanCode()));   // Wait for a response from device
	}

	do
	{
		sendCommandCode(status);        // Send 'LEDs status' byte
        while(!(r = readScanCode()));   // Wait for a response from device
	} while(r == 0xFE);

	return;
}

//
// I led della tastiera lampeggiano <count+1> volte a intervalli di 100ms
//
void flashPanel(unsigned char count)
{
	for(unsigned char i = count + 1; i > 0; --i)
	{
		setPanel(0b00000111);
        delay_100ms(1);
		setPanel(0x00000000);
        delay_100ms(1);
	}

	return;
}

//
// Funzione principale del programma
//
void main(void)
{
    numLock = (ps2Default & 0b00001000 ? 1 : 0);
    
	unsigned char scanCode, ascii;
    unsigned char leds = (numLock ? 0b00000010 : 0b00000000);   // b0    -> Scroll Lock
                                                                // b1    -> Num Lock
                                                                // b2    -> Caps Lock
                                                                // b3-b7 -> Inutilizzati
#ifdef WORDSTAR
	unsigned char quickMenuKey;
#ifdef DARKSTAR
	unsigned char functionKey;
#endif

    wordStar = ((ps2Default & 0b00000100) ? 1 : 0);
#endif

#ifdef MULTI_LAYOUT
	unsigned char layout = ps2Default & 0b00000011;
#endif

	CMCON = 0b00000111;			// ADC disabled
	z80Break = 1; TRISA2 = 0;
    INPUT_z80Reset();
	lxData = 0b11111111; TRISB = 0b00000000;

    // Attende (ed ignora) il codice restituito dal BAT (Basic Assurance Test)
	// NOTA: secondo le specifiche il BAT viene eseguito entro 500-750ms dall'accensione
    //       e termina con la restituzione del 'completion code' 0xAA in caso di successo
    //       o con il 'failure code' 0xFC in caso di fallimento
    while(!readScanCode());
	
	// Led NumLock acceso se attivo
    setPanel(leds);

	// Interpreta gli scan-code ed invia il corrispondente ASCII-code allo Z80NE
	for(;;)
	{	
        while(!(scanCode = readScanCode()));

		lxStrobe = 1;
		ascii = 0;
#ifdef WORDSTAR
        quickMenuKey = 0;
#ifdef DARKSTAR
        functionKey = 0;
#endif
#endif

        // Se NumLock non è attivo, l'interpretazione dei tasti del pad numerico
        // cambia, in particolare quella del punto e dei tasti numerici
        if(!numLock)
            switch(scanCode)
            {
                case 0x69:              // Tasto 1 interpretato come END
                case 0x6B:              // Tasto 4 interpretato come LEFT
                case 0x6C:              // Tasto 7 interpretato come HOME
                case 0x70:              // Tasto 0 interpretato come INS
                case 0x71:              // Tasto . interpretato come DEL
                case 0x72:              // Tasto 2 interpretato come DOWN
                case 0x74:              // Tasto 6 interpretato come RIGHT
                case 0x75:              // Tasto 8 interpretato come UP
                case 0x7A:              // Tasto 3 interpretato come PGDN
                case 0x7D:              // Tasto 9 interpretato come PGUP
                    extendedKey = 1;
                case 0x73:              // Tasto 5 ignorato
                    scanCode = 0;
            }

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
                        if(ctrl)
                            if(alt)				// CTRL + ALT + DEL riavvia lo Z80
                                ascii = 0x1F;       // ^_ (ASCII fornito da P.Betti)
#ifdef WORDSTAR
                            else                // CTRL + DEL
                            {
                                if(wordStar)
                                    ascii = 0x14;	// ^T (DC4)
                            }
                        else                    // DEL
                            if(wordStar)
                                ascii = 0x07;		// ^G (BEL)
#endif
						break;

#ifdef WORDSTAR
					case 0x70:					// INS
                        if(wordStar)
                            ascii = 0x16;			// ^V (SYN)
						break;
	
					case 0x6C:					// HOME
                        if(wordStar)
                            quickMenuKey = 'S';
						break;
	
					case 0x69:					// END
                        if(wordStar)
                            quickMenuKey = 'D';
						break;
	
					case 0x7D:					// PGUP
                        if(wordStar)
                            ascii = 0x12;           // ^R (DC2)
						break;
	
					case 0x7A:					// PGDN
                        if(wordStar)
                            ascii = 0x03;           // ^C (ETX)
						break;
	
					case 0x75:					// UP
                        if(wordStar)
                            if(ctrl)
                                ascii = 0x17;		// ^W (ETB)
                            else
                                ascii = 0x05;		// ^E (ENQ)
						break;
	
					case 0x72:					// DOWN
                        if(wordStar)
                            if(ctrl)
                                ascii = 0x1A;		// ^Z (SUB)
                            else
                                ascii = 0x18;		// ^X (CAN)
						break;
	
					case 0x6B:					// LEFT
                        if(wordStar)
                            if(ctrl)
                                ascii = 0x01;		// ^A (SOH)
                            else
                                ascii = 0x13;		// ^S (DC3)
						break;
	
					case 0x74:					// RIGHT
                        if(wordStar)
                            if(ctrl)
                                ascii = 0x06;		// ^F (ACK)
                            else
                                ascii = 0x04;		// ^D (EOT)
						break;
#endif
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
#ifdef MULTI_LAYOUT
					case 0x05:
#else
#ifdef DARKSTAR
                    case 0x05:
#endif
#endif
#ifdef MULTI_LAYOUT
						if(alt)					// L-ALT + F1 -> Cambia il layout della tastiera
						{
							// Spegne i led del pannello per 200ms
							setPanel(0b00000000);
                            delay_100ms(2);
							
							// Cambia il layout della tastiera:
							//  0 => layout IT
							//  1 => layout US
							//  2 => layout UK
							if(++layout == LAYOUTS)
								layout = 0;
							
							// I led del pannello lampeggiano:
							//  una volta se il layout corrente è IT
							//  due volte se il layout corrente è US
							//  tre volte se il layout corrente è UK
							flashPanel(layout);
							
							// Ripristina lo stato del pannello
							setPanel(leds);
						}
#ifdef DARKSTAR
						else					// Tasto funzione F1
#else
                            break;
#endif
#endif
#ifdef DARKSTAR
                            if(wordStar)
                                functionKey = 'A';
						break;
#endif

#ifdef WORDSTAR                        
					case 0x06:					// Tasto funzione F2
						if(alt)					// L-ALT + F2 -> Cambia la modalità della tastiera
						{
							// Spegne i led del pannello per 200ms
							setPanel(0b00000000);
                            delay_100ms(2);
							
							// Cambia la modalità della tastiera:
							//  0 => Z80NE
							//  1 => Z80WS
							wordStar = !wordStar;
							
							// I led del pannello lampeggiano:
							//  una volta se la modalità corrente è Z80NE
							//  due volte se la modalità corrente è Z80DS
							flashPanel(wordStar);
							
							// Ripristina lo stato del pannello
							setPanel(leds);
                        }
#ifdef DARKSTAR
                        else
                            if(wordStar)
                                functionKey = 'B';
#endif
						break;
#endif

#ifdef DARKSTAR
					case 0x04:					// Tasto funzione F3
                        if(wordStar)
                            functionKey = 'C';
						break;
	
					case 0x0C:					// Tasto funzione F4
                        if(wordStar)
                            functionKey = 'D';
						break;
	
					case 0x03:					// Tasto funzione F5
                        if(wordStar)
                            functionKey = 'E';
						break;
	
					case 0x0B:					// Tasto funzione F6
                        if(wordStar)
                            functionKey = 'F';
						break;
	
					case 0x83:					// Tasto funzione F7
                        if(wordStar)
                            functionKey = 'G';
						break;
	
					case 0x0A:					// Tasto funzione F8
                        if(wordStar)
                            functionKey = 'H';
						break;
	
					case 0x01:					// Tasto funzione F9
                        if(wordStar)
                            functionKey = 'I';
						break;
#endif
	
					case 0x09:
						if(ctrl & alt)			// CTRL + L-ALT + F10 -> Salva la configurazione della tastiera
						{
							// Spegne i led del pannello per 200ms
							setPanel(0b00000000);
                            delay_100ms(2);
                            
							// Salva la configurazione nella EEPROM
#ifdef MULTI_LAYOUT
                            ps2Default = layout;
#endif
#ifdef WORDSTAR
							ps2Default = (wordStar ? ps2Default | 0b00000100 : ps2Default & 0b11111011);
#endif
                            ps2Default = (numLock ? ps2Default | 0b00001000 : ps2Default & 0b11110111);
							
							// I led del pannello lampeggiano cinque volte
							flashPanel(4);
	
							// Ripristina lo stato del pannello
							setPanel(leds);
						}
#ifdef DARKSTAR
						else					// Tasto funzione F10
                            if(wordStar)
                                functionKey = 'J';
						break;
						
					case 0x78:					// Tasto funzione F11
                        if(wordStar)
                            functionKey = 'K';
						break;
	
					case 0x07:					// Tasto funzione F12
                        if(wordStar)
                            functionKey = 'L';
#endif
 						break;
                   case 0x0D:
#ifdef WORDSTAR
                        if(wordStar)
                            ascii = 0x09;       // Horizontal Tabulate
                        else
#endif
                            ascii = 0x0A;       // Line Feed
                        break;
					
					case 0x58:					// CAPS
						capsLock = !capsLock;
                        setPanel(capsLock ? leds |= 0b00000100 : leds &= 0b11111011);
						break;
	
					case 0x77:					// NUM
						numLock = !numLock;
                        setPanel(numLock ? leds |= 0b00000010 : leds &= 0b11111101);
						break;
	
					default:
							if(scanCode > 0x0D && scanCode < 0x7E)
							{
								scanCode -= 0x0E;
								if(ctrl)
#ifdef MULTI_LAYOUT
									ascii = ctrlAscii[layout * 0x70 + scanCode];
#else
									ascii = ctrlAscii[scanCode];
#endif
								else
									if(shift)
#ifdef WORDSTAR
                                        if(wordStar)
                                        {
#ifdef MULTI_LAYOUT
                                            ascii = shiftAscii[layout * 0x70 + scanCode];
#else
                                            ascii = shiftAscii[scanCode];
#endif
                                            if(capsLock)
                                                ascii = tolower(ascii);
                                        }
                                        else
#endif
                                            if(capsLock)
#ifdef MULTI_LAYOUT
                                                ascii = normalAscii[layout * 0x70 + scanCode];
#else
        										ascii = normalAscii[scanCode];
#endif
                                            else
#ifdef MULTI_LAYOUT
                                                ascii = shiftAscii[layout * 0x70 + scanCode];
#else
                                                ascii = shiftAscii[scanCode];
#endif
									else
#ifdef WORDSTAR
                                        if(wordStar)
                                        {
#ifdef MULTI_LAYOUT
                                            ascii = normalAscii[layout * 0x70 + scanCode];
#else
                                            ascii = normalAscii[scanCode];
#endif
                                            if(capsLock)
                                                ascii = toupper(ascii);
                                        }
                                        else
#endif
                                            if(capsLock)
#ifdef MULTI_LAYOUT
                                                ascii = shiftAscii[layout * 0x70 + scanCode];
#else
        										ascii = shiftAscii[scanCode];
#endif
                                            else
#ifdef MULTI_LAYOUT
                                                ascii = normalAscii[layout * 0x70 + scanCode];
#else
                                                ascii = normalAscii[scanCode];
#endif
							}
				}
			}
		}
#ifdef WORDSTAR
#ifdef DARKSTAR
        if(functionKey)
        {
            lxData = 0xE4;			// Codice ESC (0x1B) complementato
            delayUs(1500);
            lxStrobe = 0;
            delayUs(4500);
            lxStrobe = 1;
            ascii = functionKey;	// A->F1, B->F2, ..., L->F12
        }
        else
#endif
            if(quickMenuKey)
            {
                lxData = 0xEE;			// Codice ^Q (0x11) già complementato
                delayUs(1500);
                lxStrobe = 0;
                delayUs(4500);
                lxStrobe = 1;
                ascii = quickMenuKey;	// S->Home, D->End
            }
#endif

            if(ascii == 0x1F)       // CTRL + ALT + DEL
            {
                // Riavvia lo Z80 ponendo /RESET a ZERO tramite il pin z80Reset
                LOW_z80Reset();
            }
            else
            {
                // Il pin z80Reset viene posto/riconfermato ad alta impedenza
                INPUT_z80Reset();

                // Se l'ASCII code è valido viene complementato e trasferito allo
                // Z80NE e dopo una pausa di 1.5ms viene attivato lo Strobe
                if(ascii)
                {
                    lxData = ~ascii;
                    delayUs(1500);
                    lxStrobe = 0;
                }
        		else
#ifdef WORDSTAR
                    if(!wordStar)           // Solo in modalità NE-DOS/SONE
#endif
                        // La pressione simultanea dei tasti Alt ed AltGr equivale
                        //  alla pressione simultanea dei due tasti BREAK della
                        //  tastiera originale alfanumerica di Nuova Elettronica
                        if(alt & altGr)
                            z80Break = 0;       // Z80 /NMI -> LOW
                        else
                            z80Break = 1;       // Z80 /NMI -> HIGH
            }
	}
}
