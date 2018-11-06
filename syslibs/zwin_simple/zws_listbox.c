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

// void zw_showlistbox(zwObj *obj, int x, int y, int startid)
// {
// 	zwListitem * item;
// 	int i;
// 	drawbox(x, y, x+obj->width-2, y + obj->height-2, zSBORD);
// 	item = obj->firstitem;
// 	if(item == 0) return;

// 	i = 0;
// 	obj->topid = startid;


// 	while (item->li_id != startid ) {
// 		item = item-> next;
// 	}


// 	if (startid != 0 ) {
// 		zwscrs(x+obj->width-1, y);
// 		putch('+');
// 	}


// 	if (item != 0 ) {
// 		do {
// 			if (obj->state == item->li_id ) zvset(zREVERSE, zON);

// 			zwscrs(x+1,y+i+1);
// 			printf("%s", item->caption);

// 			zwscrs(x+strlen(item->caption)+1 ,y+i+1);
// 			putchrep(' ', obj->width - strlen(item->caption)-1);

// 			if (obj->state == item->li_id){
// 				zvset(zREVERSE, zOFF);
// 			}
// 			++i;
// 			item = item->next;

// 		} while (item != obj->firstitem && i+1 < obj->height);

// 		if (item != obj->firstitem ) {
// 			zwscrs(x+obj->width-1, y+obj->height);
// 			putch('+');
// 		}
// 		else {
// 			zwscrs(x+obj->width-1, y+obj->height);
// 			putch(CH_HLINE);
// 		}

// 	}

// }

// void zw_process_listbox(zwWindow * win, zwObj * obj)
// {

// 	zwListitem * li;
// 	int i, ox, oy, y, ostate, maxy;
// 	unsigned key;

// 	ox = win->x1 + 2 + obj->x;
// 	oy = win->y1 + 3 + obj->y;
// 	maxy = obj->y + obj->height + 1;

// 	y = oy;
// 	li = obj->firstitem;
// 	ostate = obj->state;


// 	for (i = 0; i < obj->topid; i++ ) {
// 		li = li->next;
// 	}

// 	for (i = obj->topid; i < obj->state; i++) {
// 		li = li->next;
// 		++y;
// 	}

// // 	cursor(1);
// 	zwscrs(ox,y);

// 	do {
// 		key = getch();

// 		switch(key) {
// 			case '0x0d':
// 				//closewindow(miwin);

// 				return;

// 			case K_F1:
// 				//closewindow(miwin);
// 				obj->state = ostate;
// 				// move bar back to orig place
// 				return ;   // escape
// 			case K_LEFT:
// 			case K_DOWN:
// 				if (li->next->li_id == 0) { break; }  //y = oy;
// 				zvset(zREVERSE, zOFF);
// 				zwscrs(ox, y);
// 				printf("%s", li->caption);

// 				zwscrs(ox+strlen(li->caption) ,y);
// 				putchrep(' ', obj->width - strlen(li->caption)-1);

// 				li = li->next;
// 				obj->state = li->li_id;
// 				if (y == maxy ) {
// 					obj->topid = obj->topid+1;
// 					zw_showlistbox(obj, ox-1, oy-1, obj->topid);
// 				}

// 				if (y < maxy) ++y;

// 				if (y == maxy && li->next->li_id == 0) {
// 					zwscrs(obj->x+obj->width+1, obj->y+obj->height+2);
// 					putch(CH_HLINE);
// 				}
// 				else if (y == maxy && li->next->li_id != 0) {
// 					zwscrs(obj->x+obj->width+1, obj->y+obj->height+2);
// 					putch('+');
// 				}

// 				zvset(zREVERSE, zON);
// 				zwscrs(ox, y);
// 				printf("%s", li->caption);

// 				zwscrs(ox+strlen(li->caption) ,y);
// 				putchrep(' ', obj->width - strlen(li->caption)-1);

// 				zwscrs(ox,y);
// 				zvset(zREVERSE, zOFF);

// 				if (y == maxy && li->li_id >= (obj->height+1)) {
// 					zwscrs(obj->x+obj->width, oy-1);
// 					putch('+');
// 				}

// 				break;

// 			case K_RIGHT:
// 			case K_UP:
// 				if (li->li_id == 0) { break; }   // y = my+2+mid;

// 				zvset(zREVERSE, zOFF);
// 				zwscrs(ox, y);
// 				printf("%s", li->caption);

// 				zwscrs(ox+strlen(li->caption) ,y);
// 				putchrep(' ', obj->width - strlen(li->caption)-1);

// 				li = li->prev;
// 				obj->state = li->li_id;
// 				if (y == oy) {
// 					obj->topid = obj->topid-1;
// 					zw_showlistbox(obj, ox-1, oy-1, obj->topid);
// 				}

// 				if (y > oy) --y;

// 				if(y == oy && li->next->li_id != 0){
// 					zwscrs(obj->x+obj->width+1, oy-1);
// 					putch('+');
// 				}

// 				zvset(zREVERSE, zON);
// 				zwscrs(ox, y);
// 				printf("%s", li->caption);

// 				zwscrs(ox+strlen(li->caption) ,y);
// 				putchrep(' ', obj->width - strlen(li->caption)-1);

// 				zwscrs(ox,y);
// 				zvset(zREVERSE, zOFF);

// 				if ( y == oy && li->li_id == 0) {
// 					zwscrs(obj->x+obj->width+1, oy-1);
// 					putch(CH_HLINE);
// 				}

// 				if (y == oy && (li->li_id+((obj->height)-1) - 1 < obj->lastitem->li_id ) ) {
// 					zwscrs(obj->x+obj->width+1, oy+obj->height-1);
// 					putch('+');
// 				}

// 				break;

// 		}
// 		zwscrs(ox,y);
// 	} while (1);

// }

// void zw_add_li(zwObj * obj, char * caption)
// {

// 	zwListitem * new;
// 	new = (zwListitem *)cpm_malloc(sizeof(zwListitem));

// 	new->caption = caption;

// 	if (obj->firstitem == 0) {
// 		obj->firstitem = new;
// 		obj->lastitem = new;
// 		new->next = new;
// 		new->prev = new;
// 		new->li_id = 0;
// 	}
// 	else {
// 		new->prev = obj->lastitem;
// 		new->next = obj->firstitem;
// 		obj->lastitem->next = new;
// 		obj->lastitem = new;
// 		new->li_id = new->prev->li_id+1;
// 	}
// }


