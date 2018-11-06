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

uint8_t zw_process_textinput(zwWindow * win, zwObj * obj)
{

	int8_t x, maxx;
	char * bctr;
	uint8_t ox = obj->x + strlen(obj->caption) + 1;
	uint8_t oy = obj->y;
	uint8_t key;

	char * buf = (char *)malloc(obj->width + 1);

	x = ox;
	maxx = x+obj->width;

	strcpy(buf, obj->data);
	if (obj->height != zwsDIGIT) {
		zwSetCrs(win, x, oy);
	}
	else {
		zwSetCrs(win, x + obj->width - strlen(buf), oy);
	}
	printf("%s", buf);

	zvset(zCURSOR, zON);
	x += strlen(buf);
	bctr = buf + strlen(buf);

	do {
		key = getch();
		if (key == K_LEFT || key == K_DEL || key == K_BKSP) {
			if ( bctr > buf ) {
				*--bctr = '\0';
				--x;
				if (obj->height == zwsDIGIT) {
					zwSetCrs(win, ox, oy);
					putchrep('-', obj->width - strlen(buf));
					printf(buf);
				}
				else {
					putch(0x18);
					putch('-');
					putch(0x18);
				}
			}

		}

		if (obj->height == zwsDIGIT && !isdigit(key))
			continue;
		if (obj->height == zwsHEX) {
			// key = toupper(key);
			if (!isdigit(key) && (key < 'A' || key > 'F'))
				continue;
		} 
	
		if (isalnum(key) || ispunct(key) || key == ' ') {
			if (x < maxx) {
				*bctr++ = key;
				*bctr = '\0';
				++x;
				if (obj->height == zwsDIGIT) {
					zwSetCrs(win, ox, oy);
					putchrep('-', obj->width - strlen(buf));
					printf(buf);
				} else
					putch(key);
			}
		}

	} while (key != K_ENTER && key != K_F10 && key != K_TAB && key != K_ESC); 

	zvset(zCURSOR, zOFF);
	zwSetCrs(win, ox, oy);

	if (key == K_ENTER || key == K_TAB) {
		strcpy(obj->data, buf);
		if (obj->height == zwsDIGIT) 
			putchrep('-', obj->width - strlen(buf));
	}

	if (key == K_F10 || key == K_ESC) {
		zwSetCrs(win, ox, oy);
		if (obj->height == zwsDIGIT) {
			putchrep('-', obj->width - strlen(buf));
		} else
			putchrep('-', obj->width);
	}
	printf(buf);

	cpm_free(buf);
	return key;

}
