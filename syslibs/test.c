


#include <c_bios.h>
#include <cpm.h>
#include <zwins.h>

extern uint8_t * _cpm_sdcc_heap;
extern uint16_t _cpm_sdcc_heap_size;


main()
{
// 	char buf[128];
// 	uint8_t x,y;
	int count, i;
// 	uint16_t vbuf[2000];
	zwWindow * zw = 0;


// 	cls();
// 	count = 33;
// 	for (i = 0; i < (25*80)-1; i++) {
// 		putch(count++);
// 		if (count > 255) count = 33;
// 	}

// 	getvregion(vbuf, 10, 10, 5, 10);
// 	cls();
// 	putvregion(vbuf, 10, 10, 5, 10);
// 	setcrs(22, 0);

// 	drawbox(0,0,5,20,0);
// 	drawbox(1,1,5,20,1);
// 	drawbox(4,4,5,20,0);
// 	drawbox(8,8,5,20,1);

// 	zw = zwNewWindow(3, 5, 5, 20, 0, "Test");
// 	zwCls(zw);
// 	getch();
//
// 	zwCloseWindow(zw);
// 	getch();


// 	do {
// 		x = getch();
// 		printf("k = 0x%x (%d)\n", x, x);
// 	} while (x != '\\');

	zw = zwNewWindow(0, 0, 22, 78, 0, "ZDS eeprom flash utility v2.0");
 	zw_addmenu(zw, " File ", 0);  // id=0
	zw_addmenuitem(zw, 0, "Open Image", 0);  // adds to second main menu
	zw_addmenuitem(zw, 0, "Save Image", 0);  // adds to second main menu
	zw_addmenuitem(zw, 0, "----------", 0);  // adds to second main menu
	zw_addmenuitem(zw, 0, "Exit      ", 0);  // adds to second main menu
	zw_addmenu(zw, " Tools ", 0);  // id=1
	zw_addmenuitem(zw, 1, "Flash Image", 0);  // adds to second main menu
	zw_addmenuitem(zw, 1, "Flash EEPROM", 0);  // adds to second main menu
	zw_showmenu(zw);
	i = zw_processmenu(zw);

	zwCloseWindow(zw);


	cls();
	zvset(zREVERSE, zON);
	printf("\nHello world, i is %d\n", i);
	zvset(zREVERSE, zOFF);

	exit(0);
	return 0;
}

