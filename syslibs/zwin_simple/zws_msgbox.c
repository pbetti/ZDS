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

#define	m_cols		30
#define	m_rows_msg	5
#define	m_rows_inp	7

static void ib_cancel(void * ptr)
{
	zwWindow * win = ptr;
	win->quitflag = zwsCANCEL;
}


static void ib_ok(void * ptr)
{
	zwWindow * win = ptr;
	win->quitflag = zwsOK;
}


// message box
uint8_t zw_msgbox(uint8_t type, char * msg)
{
	zwWindow * mwin;
	const char * wtitle = (type & zwsALERT) ? " Warning " : 0;
	register uint8_t * ptr;
	uint8_t row_num = 1, rof = 0;
	uint8_t m_rows = (type & zwsINPUT) ? m_rows_inp : m_rows_msg;

	uint8_t * buf = (uint8_t *)strdup(msg);
	if (!buf) return 0;
	ptr = buf;

	while (*ptr++) {
		if (*ptr == '\n') {
			*ptr++ = '\0';
			++row_num;
		}
	}
	ptr = buf;

	if (type & zwsALERT) zvset(zREVERSE, zON);

	mwin = zwNewWindow( (zwsNCOLS-m_cols-1)/2, (zwsNROWS-m_rows-1)/2, m_rows, m_cols, 1, wtitle);

	rof = (m_rows-row_num)/2;
	while (row_num--) {
		zwSetCrs(mwin, (m_cols-strlen(ptr))/2, rof++);
		while (*ptr) putch(*ptr++);
		++ptr;
	}

	if (type & zwsINPUT) {

		zwNewObject(2, m_rows-1, 1, 1, 0, t_OK, "", button, mwin, ib_ok);
		zwNewObject(12, m_rows-1, 1, 1, 0, t_CANCEL, "", button, mwin, ib_cancel);

		zw_showallobjects(mwin);
		zw_processobj(mwin, mwin->firstobj);

	}
	else
		getch();

	if (type & zwsALERT) zvset(zREVERSE, zOFF);

	rof = mwin->quitflag;
	zwCloseWindow(mwin);

	cpm_free(buf);
	return rof;
}

