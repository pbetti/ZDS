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
//  11.10.18 Piergiorgio Betti   Creation date
//

#include <string.h>
#include <zwins.h>

// create new window

zwWindow * zwNewWindow(int x1, int y1, int vsize, int hsize, unsigned parent, const char * title)
{

	zwWindow * zw = (zwWindow *)cpm_malloc(sizeof (zwWindow));

	if (vsize > zwsNROWS - 3) vsize = zwsNROWS - 3;	// 3 because of bug. Temporary
	if (hsize > zwsNCOLS - 2) hsize = zwsNCOLS - 2;

	if (parent) {
		unsigned bufsize = (hsize + 2) * (vsize + 2);		// save under mem
		zw->scrnchar = (uint16_t *)cpm_malloc( sizeof(uint16_t)*bufsize);

		if (!zw->scrnchar) {
			printf("No memory!\n");
			exit(1);
		}
	}

	zw->x1 = x1;
	zw->y1 = y1;
	zw->x2 = x1+hsize;
	zw->y2 = y1+vsize;
	zw->hsize = hsize;
	zw->vsize = vsize;
	zw->title = (title) ? strdup(title): 0;
	zw->parent = parent;
	zw->quitflag = 0;
	zw->firstobj = 0;
	zw->lastobj = 0;
	zw->firstmenu = 0;
	zw->lastmenu = 0;

	zwSaveUnder(zw);
	zwDrawWindow(zw);
// 	zwSetCrs(zw, 0, 0);

	return zw;
}

// save under

void zwSaveUnder(zwWindow * win)
{
	if (win->parent)
		getvregion(win->scrnchar, win->y1, win->x1, win->vsize+2, win->hsize+2);
}

// draw window

void zwDrawWindow(zwWindow * win)
{
	if (win->parent)
		drawbox(win->y1, win->x1, win->vsize, win->hsize, 0);
	else
		cls();

	if (win->title) {
		if (win->parent)
			zwscrs(win->x1+1, win->y1);
		else
			zwscrs(win->x1+win->hsize-strlen(win->title), win->y1);

		printf(" %s ", win->title);
	}
}

// close window

void zwCloseWindow(zwWindow * win)
{

	zwObj * ptr, * nptr;
	zwMenu * mptr, * nmptr;

	// restore under
	if (win->parent)
		putvregion(win->scrnchar, win->y1, win->x1, win->vsize+2, win->hsize+2);
	else {
		cls();
		zvset(zCURSOR, zON);
	}

	// menus
	mptr = win->firstmenu;
	if (mptr != 0) {
		do {
			nmptr = mptr->next;
			cpm_free(mptr);
			if (nmptr == win->firstmenu)
				mptr = 0;
			else
				mptr = nmptr;

		} while (mptr != 0);

	}

	// free objects
	ptr = win->firstobj;

	while (ptr != 0) {
		nptr = ptr->next;
		// cpm_free(ptr->data);  // free data buffer for each obj

		// add code to free a listbox list

		cpm_free(ptr);        // free memory for object
		ptr = nptr;
	};

	if (win->title) cpm_free(win->title);
	if (win->parent) cpm_free(win->scrnchar);
	cpm_free(win);

}

// set cursor in window coord
void zwSetCrs(zwWindow * w, int x, int y)
{
	zwscrs(w->x1+x+1, w->y1+y+1);
}


// clear window
void zwCls(zwWindow * win)
{
	clrvregion(win->y1+1, win->x1+1, win->vsize, win->hsize);
}

void zwscrs(int x, int y)
{
	setcrs(y,x);
}
