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
//  Module: zwin simple header
//
//  HISTORY:
//  -[Date]- -[Who]------------- -[What]---------------------------------------
//  14.10.18 Piergiorgio Betti   Creation date
//

#include <zwins.h>

int zw_processmenuitems(zwWindow * win, zwMenu * menu, int mx, int my)
{

	zwMenuitem * mi;
	zwWindow * miwin;
	int mid, c, y;
	char key;

	mi = menu->firstmi;				// get ptr to first submenu item
	mid = menu->lastmi->menu_item_id;		// get the id of the last menu id (count-1 of items for size)
	zvset(zREVERSE, zOFF);

	miwin = zwNewWindow(mx, my+1, mid+1, menu->mi_maxwidth, 1, 0);

	zvset(zREVERSE, zON);
	y = my+2;					// top item y value
	c = 0;
	zvset(zCURSOR, zOFF);
	// fill menu with items
	do {
		zwscrs(mx+1,y+c);
		printf("%s", mi->caption);
		mi = mi->next;
		c++;
		zvset(zREVERSE, zOFF);

	} while (mi != menu->firstmi);

	do {
		key = getch();

		switch(key) {
			case K_ENTER:
				zwCloseWindow(miwin);
				if (mi->fp != 0) {
					mi->fp(win);
					return -1;
				}

				return(mi->menu_item_id);

			case K_F10:
			case K_ESC:
				zwCloseWindow(miwin);
				return -1;   // escape

			case K_LEFT:
				zwCloseWindow(miwin);
				return -2;   // back

			case K_RIGHT:
				zwCloseWindow(miwin);
				return -3;   // forward

			case K_DOWN:
				zwscrs(mx+1,y);
				printf("%s", mi->caption);

				mi = mi->next;
				if (mi->menu_item_id == 0) { y = my+2; }
				else ++y;

				zvset(zREVERSE, zON);
				zwscrs(mx+1,y);
				printf("%s", mi->caption);

				zvset(zREVERSE, zOFF);
				break;

			case K_UP:
				zwscrs(mx+1,y);
				printf("%s", mi->caption);

				if (mi->menu_item_id == 0) { y = my+2+mid; }
				else --y;

				mi = mi->prev;
				zvset(zREVERSE, zON);
				zwscrs(mx+1,y);
				printf("%s", mi->caption);

				zvset(zREVERSE, zOFF);
				break;

		} // switch
	} while (true);

// 	return 0; /* unreachable */
}




/*
value returns represents an int beween 10 and 99
where the tens value is the main menu item 10 is 1, 20 is 2 etc
where the ones value is the sub menu item number  11, is one, 12, is 2 etc

note: this is offest by the menu_item_id's by one as they start at 0
*/

int zw_processmenu(zwWindow * win)
{
	zwMenu * menu;
	static zwMenu * last_active = 0;
	static uint8_t last_ax = 0;
	int x, y, lastx, retval, myx, myy;
	unsigned int key;
	uint8_t open_flag = 0;

	zvset(zCURSOR, zOFF);
	if (win->firstmenu == 0) return -1;
	if (!win->parent) {
		myx = win->x1 + 1;
		myy = win->y1;
	}
	else {
		myx = win->x1 + 2;
		myy = win->y1 + 1;
	}


	retval = 0;
	key = 0;
	x = myx;
	y = myy;
	lastx = x;

	menu = win->firstmenu;
	do {
		lastx = lastx + strlen(menu->caption) + 1;
		menu = menu->next;
	} while (menu != win->lastmenu);

	if (last_active) {
		menu = last_active;
		x = last_ax;
	}
	else {
		menu = win->firstmenu;
		zwscrs(x,y);
		printf("%s", menu->caption);
	}

	do {
		zwscrs(x + strlen(menu->caption),y);
		zvset(zREVERSE, zON);

		if (open_flag == 0)
			key = getch();
		if (open_flag == 1 && key == 0) {
			open_flag = 0;
			key = K_ENTER;
		}

		switch (key) {
			case K_ENTER:

				if (menu->firstmi != 0) {
					last_active = menu;
					last_ax = x;

					retval = zw_processmenuitems(win, menu, x, y);
					if (retval >= 0){
						return ((menu->menu_id)+1)*10 + retval+1;
					}
					else if (retval == -1) {
						key = 0;
						if (win->quitflag == 1) key = K_ENTER;
					}
					else if (retval == -2) {
						key = K_LEFT;
						open_flag = 1;
					}
					else if (retval == -3) {
						key = K_RIGHT;
						open_flag = 1;
					}
				}
				else if (menu->fp != 0) {

					menu->fp(win);
					key = ' ';
					if (win->quitflag == 1) key = K_ENTER;
				}
				else if (menu->firstmi == 0) return ((menu->menu_id)+1)*10;
				break;

			case K_RIGHT:
			case K_UP:
				zvset(zREVERSE, zON);
				zwscrs(x,y);
				printf("%s", menu->caption);

				x = x + strlen(menu->caption) + 1;
				menu = menu->next;
				if (menu == win->firstmenu) { x = myx; }
				zvset(zREVERSE, zOFF);
				zwscrs(x,y);
				printf("%s", menu->caption);
				key = 0;
				break;

			case K_LEFT:
			case K_DOWN:
				zvset(zREVERSE, zON);
				zwscrs(x,y);
				printf("%s", menu->caption);

				menu = menu->prev;
				if (menu == win->lastmenu)  {
					x = lastx;
				}
				else {
					x = x - strlen(menu->caption) - 1;
				}

				zvset(zREVERSE, zOFF);
				zwscrs(x,y);
				printf("%s", menu->caption);
				key = 0;
				break;
		}

	} while (key != K_ENTER);

	return menu->menu_id;
}



void zw_showmenu(zwWindow * win)
{

	zwMenu * menu;
	unsigned x, y, len;

	if (win->firstmenu == 0) { return; }

		menu = win->firstmenu;

		if (win->parent) {
			x = win->x1 + 1;
			y = win->y1 + 1;
			len = win->x2 - win->x1;
		}
		else {
			x = win->x1;
			y = win->y1;
			len = win->x2 - win->x1 + 2;
		}

		zvset(zREVERSE, zON);
		zwscrs(x,y);
		putchrep(' ', len);
		if (!win->parent) {
			zwscrs(win->x1+win->hsize-strlen(win->title), win->y1);
			printf(" %s ", win->title);
		}

		x = x+1;
		do {
			zwscrs(x,y);
			printf("%s", menu->caption);

			x = x+1+strlen(menu->caption);

			menu = menu->next;
		} while (menu != win->firstmenu);

		zvset(zREVERSE, zOFF);

}



//void addmenu

void zw_addmenu(zwWindow * win, char * caption, void (*fp)(void *) )
{
	zwMenu * newmenu = (zwMenu *)cpm_malloc(sizeof (zwMenu));

	newmenu->caption = caption;
	newmenu->firstmi = 0;
	newmenu->lastmi = 0;
	newmenu->fp = fp;


	if (win->firstmenu != 0) {
		newmenu->next = 	win->firstmenu;
		newmenu->prev = 	win->lastmenu;

		win->lastmenu->next = 	newmenu;
		win->lastmenu = 	newmenu;
		win->firstmenu->prev = 	newmenu;

		newmenu->menu_id = 	newmenu->prev->menu_id + 1;
	}
	else {
		newmenu->next = 	newmenu;
		newmenu->prev = 	newmenu;
		win->firstmenu = 	newmenu;
		win->lastmenu = 	newmenu;
		newmenu->menu_id = 0;
	}

}


void zw_addmenuitem(zwWindow * win, int menuid, char * caption, void (*fp)(void *))
{
	zwMenu * menu;
	zwMenuitem * newitem = (zwMenuitem *)cpm_malloc(sizeof (zwMenuitem));


	menu = win->firstmenu;
	while (menu->menu_id != menuid) {
		menu = menu->next;
	}

	newitem->caption = caption;
	newitem->fp = fp;

	if (menu->firstmi != 0) {
		newitem->next = menu->firstmi;
		newitem->prev = menu->lastmi;

		if (strlen(caption) > menu->mi_maxwidth) menu->mi_maxwidth = strlen(caption);

		menu->lastmi->next = 	newitem;
		menu->lastmi = 		newitem;
		menu->firstmi->prev = 	newitem;

		newitem->menu_item_id = newitem->prev->menu_item_id + 1;
	}
	else {
		newitem->next=newitem;
		newitem->prev=newitem;
		menu->mi_maxwidth = strlen(caption);

		menu->firstmi=	newitem;
		menu->lastmi=	newitem;
		newitem->menu_item_id=0;
	}

}

