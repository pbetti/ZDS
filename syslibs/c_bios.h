//
//  '########'########::'######:::'##::: ##'########'########:'#######:::'#####:::
//  ..... ##: ##.... ##'##... ##:: ###:: ## ##.....:..... ##:'##.... ##:'##.. ##::
//  :::: ##:: ##:::: ## ##:::..::: ####: ## ##:::::::::: ##:: ##:::: ##'##:::: ##:
//  ::: ##::: ##:::: ##. ######::: ## ## ## ######::::: ##:::: #######: ##:::: ##:
//  :: ##:::: ##:::: ##:..... ##:: ##. #### ##...::::: ##::::'##.... ## ##:::: ##:
//  : ##::::: ##:::: ##'##::: ##:: ##:. ### ##::::::: ##::::: ##:::: ##. ##:: ##::
//   ######## ########:. ######::: ##::. ## ######## ########. #######::. #####:::
//  ........:........:::......::::..::::..:........:........::.......::::.....::::
//
//  Sysbios C interface library
//  P.Betti  <pbetti@lpconsul.eu>
//
//  Module: c_bios header
//
//  HISTORY:
//  -[Date]- -[Who]------------- -[What]---------------------------------------
//  10.10.18 Piergiorgio Betti   Creation date
//

#ifndef		_C_BIOS_H
#define		_C_BIOS_H

#include <cpm.h>

struct HDGEO_proto {
	unsigned int cylinders;
	unsigned char heads;
	unsigned char sectors;
};

typedef	struct HDGEO_proto 	HDGEO;

#define	TMPBYTE			0x004B;		// TMPBYTE in page 0

#define	zOFF			0
#define	zON			1

#define	zSBORD			0
#define	zDBORD			1


#define	zNORMAL			0b00000000
#define	zREVERSE		0b00000001
#define	zBLINK			0b00000010
#define	zUNDERLINE		0b00000100
#define	zHIGHLIGHT		0b00001000
#define	zRED			0b00010000
#define	zGREEN			0b00100000
#define	zBLU			0b01000000
#define	zCURSOR			0b10000000


extern	int getHDgeo(HDGEO *);
extern	int hdRead(unsigned char *, unsigned int, unsigned int);
extern	int hdWrite(unsigned char *, unsigned int, unsigned int);
extern	void setcrs(uint8_t, uint8_t);
extern	void getcrs(uint8_t *, uint8_t *);
extern	uint16_t _getcrs();
extern	void cls();
extern	void lockHDAccess();
extern	void unlockHDAccess();
extern	void getvregion(uint16_t *, uint8_t, uint8_t, uint8_t, uint8_t);
extern	void putvregion(uint16_t *, uint8_t, uint8_t, uint8_t, uint8_t);
extern	void clrvregion(uint8_t, uint8_t, uint8_t, uint8_t);
extern	uint16_t getvchr();
extern	void putvchr(uint16_t);
extern	void drawbox(uint8_t, uint8_t, uint8_t, uint8_t, uint8_t);
extern	void zvset(uint8_t, uint8_t);
extern	void putchrep(uint8_t, uint8_t);




#endif		// _C_BIOS_H
/* EOF */
