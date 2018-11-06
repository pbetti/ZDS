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

// #include <zwins.h>
// #include <ctype.h>

// void zw_process_checkbox(zwWindow * win, zwObj * obj)
// {
// 	int x, y;
// 	char key;

// 	x = win->x1 + 1 + obj->x;
// 	y = win->y1 + 2 + obj->y;

// // 	zwscrs(x+1,y);
// // // 	cursor(1);
// // 	zvset(zREVERSE, zON);
// //
// // 	if (obj->state == 0) putch(' ');
// // 	else putch('X');

// 	do {
// 		zwscrs(x+1,y);
// 		zvset(zREVERSE, zON);

// 		if (obj->state == 0) putch(' ');
// 		else putch('X');

// 		zwscrs(x+1, y);
// 		key = getch();

// 		if (key == ' ') {
// 			if(obj->state == 0 ) obj->state = 1;
// 			else obj->state = 0;
// 		}

// 	} while (key != 0x0d && key != K_RIGHT);

// 	zwscrs(x+1,y);
// 	zvset(zREVERSE, zOFF);

// 	if (obj->state == 0) putch(' ');
// 	else putch('X');

// // 	cursor(0);

// }
