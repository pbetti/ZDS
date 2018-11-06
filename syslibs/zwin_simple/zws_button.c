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
#include <ctype.h>

void zw_showbutton(zwObj *obj, int x, int y, int focus)
{
	if (focus)
		zvset(zREVERSE, zON);
	zwSetCrs((zwWindow *)obj->parent, x ,y);
	printf("[%s]", obj->caption);
	zvset(zREVERSE, zOFF);
}

void zw_process_button(zwWindow * win, zwObj * obj)
{
	int x, y;
	char key;

	x = obj->x;
	y = obj->y;
	zw_showbutton(obj, x, y, true);
	zwSetCrs(win, x ,y);
	do {
		key = getch();
		if (key == K_ENTER) {
			if (obj->fp != 0) 
				obj->fp(win);
			else
				win->quitflag = obj->id + 1;
		}
	} while (key != K_F10 && key != K_TAB && key != K_ENTER);

	zw_showbutton(obj, x, y, false);

}
