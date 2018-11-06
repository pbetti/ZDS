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


zwObj * zw_get_obj(zwWindow * w, unsigned id)
{
	zwObj * obj;

	obj = w->firstobj;
	while (id != obj->id) { obj = obj->next; }
	return obj;

}




int zw_get_objstate(zwWindow * w, unsigned id)
{
	zwObj * obj = zw_get_obj(w, id);

	return obj->state;

}




char * zw_get_objdata(zwWindow * w, unsigned id)
{
	zwObj * obj = zw_get_obj(w, id);

	return obj->data;

}

void zw_processobj(zwWindow * win, zwObj * obj)
{
	win->quitflag = 0;

	do {
		switch (obj->objtype) {

			case label :
				break;
			case button:
				zw_process_button(win, obj);
				break;
			case textinput :
				zw_process_textinput(win, obj);
				break;
			// case checkbox:
			// 	zw_process_checkbox(win, obj);
			// 	break;
			// case listbox:
			// 	zw_process_listbox(win, obj);
			// 	break;

			default :
				break;
		}

		obj = obj->next;
		if ( obj == 0) obj = win->firstobj;

	} while (win->quitflag == 0);

}


zwObj * zwNewObject(int x, int y, int width, int height, unsigned state, char * caption, char * data,
	       zwObject type, zwWindow * win, void (*fp)(void *)){

	zwObj * newobj = (zwObj *)cpm_malloc(sizeof (zwObj));

	newobj->parent = (void *)win;
	newobj->x = x;
	newobj->y = y;
	newobj->width = width;
	newobj->height = height;
	newobj->caption = caption;
	newobj->data = data;
	newobj->objtype = type;
	newobj->state = state;
	newobj->topid = 0;
	newobj->next = 0;
	newobj->fp = fp;

	newobj->firstitem = 0;

	if (win->firstobj == 0) {
		win->firstobj = newobj;
		newobj->id = 0;
	}
	if (win->lastobj != 0) {
		win->lastobj->next = newobj;
		newobj->id = win->lastobj->id + 1;
	}

	win->lastobj = newobj;
	return newobj;

}

void zw_showobj(zwObj * obj, zwWindow * win)
{
	int x = obj->x;
	int y = obj->y;

	if (obj->objtype == label) {
		zwSetCrs(win, x, y);
		printf("%s", obj->caption);
	}
	else if (obj->objtype == rectangle) {
		drawbox(x, y, x+obj->width-2, y+obj->height-2, zSBORD);

	}
	// else if (obj->objtype == checkbox) {

	// 	zwSetCrs(win, x ,y);
	// 	putch('(');
	// 	if (obj->state == 0)
	// 		putch(' ');
	// 	else
	// 		putch('X');
	// 	putch(')'); putch(' ');
	// 	printf("%s", obj->caption);


	// }
	else if (obj-> objtype == textinput) {
		zwSetCrs(win, x ,y);
		printf("%s ", obj->caption);
		x += strlen(obj->caption) + 1;
		putchrep('-', obj->width);
		if (obj->height == zwsDIGIT)
			zwSetCrs(win, x + obj->width - strlen(obj->data), y);
		else
			zwSetCrs(win, x ,y);
		printf(obj->data);
	}
	else if (obj->objtype == button) {
		zw_showbutton(obj, x, y, false);
	}
	// else if(obj->objtype == listbox) {
	// 	zw_showlistbox(obj, x, y, 0);

	// }

}

void zw_showallobjects (zwWindow * win)
{
	zwObj * ptr;

	ptr = win->firstobj;

	while (ptr != 0) {
		zw_showobj(ptr, win);
		ptr = ptr->next;
	}
}








