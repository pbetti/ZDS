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

#ifndef	_ZWINS_H
#define	_ZWINS_H

#include <cpm.h>
#include <c_bios.h>

#define t_OK		"  OK  "
#define t_CANCEL	"CANCEL"

	// commons
#define	zwsOK			1
#define	zwsCANCEL		2
#define	zwsNROWS		25
#define	zwsNCOLS		80


	// messagebox type
#define	zwsINFO			0b00000000
#define	zwsALERT		0b00000001
#define	zwsINPUT		0b00000010
#define	zwsREVERSE		0b00000100

	// textinput type
#define zwsALPHA		0
#define zwsDIGIT		1
#define zwsHEX			2

	// semigraphics
#define	CH_HLINE		0xc1
#define	CH_VLINE		0xc0
#define	CH_DHLINE		0xcc
#define	CH_DVLINE		0xcb
#define	CH_ULCORNER		0xc9
#define	CH_URCORNER		0xca
#define	CH_LLCORNER		0xc7
#define	CH_LRCORNER		0xc8
#define	CH_DULCORNER		0xd4
#define	CH_DURCORNER		0xd5
#define	CH_DLLCORNER		0xd2
#define	CH_DLRCORNER		0xd3
#define CH_ARRUP		0xee
#define CH_ARRDOWN		0xe8
#define CH_ARRLEFT		0xef
#define CH_ARRRIGHT		0xe9
#define CH_ATCSSUP		0xc5
#define CH_ATCSSDN		0xc6
#define CH_ATCDDUP		0xd0
#define CH_ATCDDDN		0xd1
#define CH_ATCSDUP		0xe4
#define CH_ATCSDDN		0xe5
#define CH_ATCDSUP		0xd8
#define CH_ATCDSDN		0xd9

#ifndef	true
#define	true	1
#define	false	0
#endif


typedef enum {
	label,
	button,
	checkbox,
	radiobutton,
	textinput,
	listbox,
	rectangle
} zwObject;

typedef struct listitem {

	char * caption;
	int li_id;
	struct listitem *next;
	struct listitem *prev;

} zwListitem;


typedef struct menuitem {

	char * caption;			// text to dispay in submenu for this item
	int menu_item_id;		// auto generated ID to be used in providing a return value on selected menu
	struct menuitem *next;		// auto created pointer to next sub menu item
	struct menuitem *prev;		// auto created pointer to previous sub menu item
	void (*fp) (void*);
}  zwMenuitem;



typedef struct menu {

	char *caption;			// text displayed on the main menu
	int menu_id;			// sequential index auto calculated in order of menu additions
	int mi_maxwidth;		// enternally calculated with each add.
	struct menu *next;		// auto created pointer to next menu in the list
	struct menu *prev;		// auto created pointer to previous menu in the list
	zwMenuitem *firstmi;		// auto created pointer to the first submenu item (NULL if none)
	zwMenuitem *lastmi;		// auto created pointer to the last submenu item (NULL if none)
	void (*fp) (void*);		// pointer to function to run if menu item selected

} zwMenu;



//   zwObj data type
//   this struct defines the parameters needed to create, process and destroy window objects
typedef struct object  {
	void * parent;			// parent window
	int x;				// x position of object relative to x1 of window
	int y;				// y position of object relative to y1 of window
	int width;			// width of object, not used for all object types
	int height;			// height of object, not used for all object types (numbox->max)
	unsigned id;			// auto generated id to object, used in get_objdata to retreive data
	char * caption;			// text to display (not used for all objects)
	char * data;			// data string stored for object
	unsigned state;			// for future use (numbox->min)
	unsigned topid;			// top id in list box
	zwObject objtype;		// defines object type see enum types above
	zwListitem * firstitem;		// used for list box - link to list of items
	zwListitem * lastitem;		// used for list box - link to list of items
	struct object * next;		// auto created pointer to next object in screen, or NULL if none
	void (*fp)(void *);		// pointer to function to execute for this object, not used for all objects
} zwObj;

//   zwWindow data type
//   this struct defines the parameters needed to create, process and close windows

typedef struct {
	int x1;				// x position of top left corner 0 to 34
	int y1;				// y position of the top left corner 0 to 39
	int x2;				// x position of the bottom right corner x1+5 to 39
	int y2;				// y position of the botton left corner y1+4 to 24
	int hsize;			// width of object, not used for all object types
	int vsize;			// height of object, not used for all object types (numbox->max)
	unsigned parent;		// 0=not parent 1=parent - if not parent screen in footprint will be saved in scrnchar, scrncolor
	unsigned quitflag;		// 1=quit 0=do no quit - used by processmenu and processobjects to quit handling loop
	char * title;			// title of window, can be "\0" for no title
	uint16_t * scrnchar;		// pointer to dynamically allocated buffer to hold char screen data when parent =0
	zwObj * firstobj;		// auto created pointer to first object in the window object list
	zwObj * lastobj;		// auto created pointer to last object in the window object list
	zwMenu * firstmenu;		// auto created pointer to the first menu in the window menu (NULL if none)
	zwMenu * lastmenu;		// auto created pointer to the last menu in the window menu (NULL if none)

} zwWindow;



extern	zwWindow * zwNewWindow(int, int, int, int, unsigned, const char *);
extern	void zwSaveUnder(zwWindow *);
extern	void zwDrawWindow(zwWindow *);
extern	void zwSetCrs(zwWindow *, int, int);
extern	void zwCloseWindow(zwWindow *);
extern	void zwCls(zwWindow *);
extern	void zwscrs(int x, int y);


extern	uint8_t zw_msgbox(uint8_t type, char *);
// extern	void zw_inputbox(char *, char *, unsigned);

extern	zwObj * zwNewObject(int, int, int, int, unsigned, char *, char *, zwObject, zwWindow *, void (*fp)(void *) );
extern	void zw_showobj(zwObj *, zwWindow *);
extern	void zw_showallobjects (zwWindow *);
extern	void zw_processobj(zwWindow *, zwObj *);
extern	char * zw_get_objdata(zwWindow *, unsigned);
extern	int zw_get_objstate(zwWindow *, unsigned);
extern	zwObj * zw_get_obj(zwWindow *, unsigned);

extern	void zw_showbutton(zwObj *, int, int, int);
extern	void zw_process_button(zwWindow *, zwObj *);

// extern	void zw_showlistbox(zwObj *, int, int, int);
// extern	void zw_process_listbox(zwWindow *, zwObj *);
// extern	void zw_add_li(zwObj *, char *);

extern	uint8_t zw_process_textinput(zwWindow *, zwObj *);
// extern	void zw_process_checkbox(zwWindow *, zwObj *);

extern	int zw_processmenuitems(zwWindow *, zwMenu *, int, int);
extern	void zw_addmenu(zwWindow *win, char *caption, void (*fp)(void *) );
extern	void zw_showmenu(zwWindow *win);

extern	int zw_processmenu(zwWindow *);
extern	void zw_addmenuitem(zwWindow *win, int menuid, char *caption, void (*fp) (void*));



#endif		// _ZWINS_H
