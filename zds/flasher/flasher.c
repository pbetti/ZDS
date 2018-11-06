/*
  '########'########::'######:::'##::: ##'########'########:'#######:::'#####:::
  ..... ##: ##.... ##'##... ##:: ###:: ## ##.....:..... ##:'##.... ##:'##.. ##::
  :::: ##:: ##:::: ## ##:::..::: ####: ## ##:::::::::: ##:: ##:::: ##'##:::: ##:
  ::: ##::: ##:::: ##. ######::: ## ## ## ######::::: ##:::: #######: ##:::: ##:
  :: ##:::: ##:::: ##:..... ##:: ##. #### ##...::::: ##::::'##.... ## ##:::: ##:
  : ##::::: ##:::: ##'##::: ##:: ##:. ### ##::::::: ##::::: ##:::: ##. ##:: ##::
   ######## ########:. ######::: ##::. ## ######## ########. #######::. #####:::
  ........:........:::......::::..::::..:........:........::.......::::.....::::

  EEPROM Flasher
  P.Betti  <pbetti@lpconsul.eu>

  Module:

  HISTORY:
  -[Date]- -[Who]------------- -[What]---------------------------------------
  14.10.18 Piergiorgio Betti   Creation date

*/

#include <cpm.h>
#include <c_bios.h>
#include <zwins.h>
#include <ctype.h>

#define	my_version_maj			2
#define	my_version_min			0
#define	my_version_sub			0
#define	my_header			"ZDS eeprom flasher"

#define	tmpbuf_size			80
#define	rom_io_buffer_size		4096
#define	rom_index_size			2048
#define	rom_index_page			0xff
#define	rom_max_blk			40
#define	img_namelen			8
#define	img_pagelen			2
#define	img_addrlen			4
#define	img_sizelen			5
#define	img_desclen			20

#define ff_op_none			0
#define ff_op_load			1
#define ff_op_save			2
#define ff_op_add			3

typedef struct {
	char name[img_namelen+1];
	char page_offset[img_pagelen+1];
	char address[img_addrlen+1];
	uint16_t size;
	char description[img_desclen+1];
} ROM_INDEX_BLK;


// Main menu entries
#define	M_FILE				0
#define	M_TOOL				1
#define	M_HELP				2

#define	M_FILE_SAVE_IMAGE		11
#define	M_FILE_SAVE_EEPROM		12
#define	M_FILE_EXIT			13

#define	M_TOOL_BROWSE			21
#define	M_TOOL_ADD_IMAGE		22
#define	M_TOOL_UPDATE_IMAGE		23
#define	M_TOOL_FLASH_EEPROM		24

#define	M_HELP_ABOUT			31

// index view mode
#define	IV_INIT				0
#define	IV_BROWSE			1
#define	IV_SELECT			2

// hstoi
#define DECB				10
#define HEXB				16

static const uint8_t * MIOBYTE = 0x004C;	// MIOBYTE in page 0
static uint8_t tempbuf[tmpbuf_size];		// global temp buffer
static zwWindow * wroot;			// main window ptr
static uint8_t quit_flag = false;
static uint8_t * rom_io_buffer;			// rom page io (4k)
static ROM_INDEX_BLK * rom_io_index;		// rom map (2k)
static uint8_t file_flag = false;
static uint8_t lslot;
static uint8_t bslot;
static char current_filename[8+1+3+1];
static uint8_t prog_safe_mode = false;

static char * msg_op_canc = "Operation Cancelled.";
static char * msg_w_eepr = "whole EEPROM";
static char * msg_f_over = "File %s exists. Overwrite ? [y/n] ";
static char * msg_f_nope = "Can't open '%s'";
static char * msg_o_anyk = "Press any key..";
static char * msg_f_ferr = "File error!";
static char * msg_o_done = "Done.";

// functions
extern void	help_key_main();
extern void	help_key_browse();
extern void	help_about(void *);
extern void	loop_main_menu();
extern void	quit();
extern void	load_rom_page(uint8_t, uint16_t, uint16_t);
extern int8_t	view_index(uint8_t);
extern unsigned int hstoi(const char *, uint8_t);
extern void	vline(uint8_t, uint8_t, uint8_t);
extern void	show_stat();
extern void	show_line(ROM_INDEX_BLK *, uint8_t, uint8_t, uint8_t, uint8_t);
extern int8_t	edit_block(ROM_INDEX_BLK *);
extern int8_t	process_index(uint8_t);
extern int8_t	ask_filename();
extern int8_t	do_image_save(char *, ROM_INDEX_BLK *);
extern int8_t	do_image_load(char *, ROM_INDEX_BLK *);
extern int8_t	file_exists(char *);
extern int8_t	askyn();
extern void	clean_op_pane();
extern void	erase_row(ROM_INDEX_BLK *);



main() {

	// Are we running on serial console?
	if (*MIOBYTE & 0b00100000) {
		fprintf(stderr, "Sorry, run only on CRT.\n");
		exit(1);
	}

	// allocate main buffers first
	rom_io_buffer = (uint8_t *)malloc(rom_io_buffer_size);
	rom_io_index = (ROM_INDEX_BLK *)malloc(rom_max_blk*sizeof(ROM_INDEX_BLK));

	if (!rom_io_buffer || ! rom_io_index) {
		printf("No room.\n");
		exit(1);
	}

	load_rom_page(rom_index_page, (uint16_t)rom_io_index, rom_max_blk*sizeof(ROM_INDEX_BLK));

	// create root win
	sprintf(tempbuf, "%s v%d.%d.%d", my_header, my_version_maj+0, my_version_min+0, my_version_sub+0);
	wroot = zwNewWindow(0, 0, zwsNROWS, zwsNCOLS, 0, tempbuf);

	// and root menu
	zw_addmenu(wroot, " File ", 0);				// File id=0
	zw_addmenuitem(wroot, M_FILE, "Save Image", 0);
	zw_addmenuitem(wroot, M_FILE, "Save EEPROM", 0);
	zw_addmenuitem(wroot, M_FILE, "Exit", 0);

	zw_addmenu(wroot, " Tools ", 0);			// Tools id=1
	zw_addmenuitem(wroot, M_TOOL, "Browse Index", 0);
	zw_addmenuitem(wroot, M_TOOL, "Add Image", 0);
	zw_addmenuitem(wroot, M_TOOL, "Update Image", 0);
	zw_addmenuitem(wroot, M_TOOL, "Flash EEPROM", 0);

	zw_addmenu(wroot, " Help ", 0);				// Help id=2
	zw_addmenuitem(wroot, M_HELP, "About", help_about);

	// view panel
	drawbox(1, 0, 12, zwsNCOLS-2, zSBORD);

	// operation panel
	drawbox(15, 0, 7, zwsNCOLS-2, zDBORD);
	vline(15, 35, 15+8);

	help_key_main();

	zw_showmenu(wroot);

	if (strncmp(rom_io_index[0].name, "SY", 2)) {		// dirty
		memset(rom_io_index, 0, rom_max_blk*sizeof(ROM_INDEX_BLK));
		// slot 0 is SYSBIOS itself. Can't be empty.
		strcpy(rom_io_index[0].name, "SYSBIOS");
		strcpy(rom_io_index[0].page_offset, "C0");
		strcpy(rom_io_index[0].address, "F000");
		rom_io_index[0].size = 16384;
		strcpy(rom_io_index[0].description, "SYSTEM BIOS/MONITOR");
	}

	show_stat();

	// begin process menu
	loop_main_menu();

	zwCloseWindow(wroot);

	exit(0);
	return 0;				// to make sdcc happy
}

// help line on menu mode
void help_key_browse()
{
	setcrs(24,0);
	printf("\x0f  <%c %c PgUp PgDn> Move  <F4> Edit/Select  <F10> Menu", CH_ARRLEFT, CH_ARRRIGHT);
}

// help line on browse mode
void help_key_main()
{
	setcrs(24,0);
	printf("\x0f  <%c %c %c %c> Move  <Ret> Select  <F10> Close", CH_ARRLEFT, CH_ARRRIGHT, CH_ARRUP, CH_ARRDOWN);
}

// about window
void help_about(void * arg)
{
	arg;
	zw_msgbox(zwsINFO, "ZDS flasher utility\nv 2.0.0\n(c) Piergiorgio Betti 2018");
}

int8_t process_index(uint8_t mode)
{
	int8_t rval = -1;
	int8_t rsav;

	help_key_browse();
	while (true) {
		rval = view_index(mode);
		rsav = rval;
		if (rval >= 0 && file_flag != ff_op_save) {
			rval = edit_block(&rom_io_index[rval]);
			if (rval == zwsCANCEL)
				rval = -1;

			if (mode == IV_BROWSE)
				continue;
		}
		break;
	}
	help_key_main();
	return (rval < 0) ? rval : rsav;
}

// main menu looper
void loop_main_menu()
{
	uint8_t sel;
	uint8_t exit_flag = false;
	int8_t rval = -1;

	while (true) {

		view_index(IV_INIT);
		sel = zw_processmenu(wroot);
		rval = -1;
		current_filename[0] = 0;

		switch (sel) {
			case M_FILE_EXIT:
				quit();
				exit_flag = quit_flag;
				break;
			case M_TOOL_BROWSE:
				file_flag = ff_op_none;
				process_index(IV_BROWSE);
				break;
			case M_FILE_SAVE_IMAGE:
				file_flag = ff_op_save;
				if ((rval = process_index(IV_SELECT)) < 0)
					break;
			case M_FILE_SAVE_EEPROM:
				if (ask_filename() == zwsCANCEL) {
					zw_msgbox(zwsINFO, msg_op_canc);
					break;
				}
				do_image_save(current_filename, (rval < 0) ? 0 : &rom_io_index[rval]);
				break;
			case M_TOOL_ADD_IMAGE:
				file_flag = ff_op_add;
				if (edit_block(&rom_io_index[bslot]) == zwsCANCEL) 
					break;
				sprintf (rom_io_index[bslot].page_offset, "%02X", lslot);	// to be sure
				if (ask_filename() == zwsCANCEL) {
					zw_msgbox(zwsINFO, msg_op_canc);
					erase_row(&rom_io_index[bslot]);
					break;
				}
				do_image_load(current_filename, &rom_io_index[bslot]);
				show_stat();
				break;
			case M_TOOL_UPDATE_IMAGE:
				file_flag = ff_op_load;
				if ((rval = process_index(IV_SELECT)) < 0)
					break;
			case M_TOOL_FLASH_EEPROM:
				if (ask_filename() == zwsCANCEL) {
					zw_msgbox(zwsINFO, msg_op_canc);
					break;
				}
				do_image_load(current_filename, (rval < 0) ? 0 : &rom_io_index[rval]);
				break;
		}

		if (exit_flag) break;
	}

}

void erase_row(ROM_INDEX_BLK * row) 
{
	row->name[0] = 0;
	row->page_offset[0] = 0;
	row->address[0] = 0;
	row->size = 0;
	row->description[0] = 0;
}

void quit()
{
	// uint8_t usr;

	// usr = zw_msgbox(zwsINPUT, "Really want to quit?");

	// if (usr == zwsCANCEL) return;
	quit_flag = true;

}

void load_rom_page(uint8_t ep, uint16_t dest, uint16_t size) __naked
{
	ep; dest; size;

	__asm

	.include "darkstar.inc"

	trnpag		.equ	0x0e		; Page used for transient MMU ops

	push	iy
	ld	iy,#4
	add	iy,sp

	di

	ld	b,#trnpag		; transient page in ram
	call	MMGETP
	ld	(00010$),a		; save current
	;
	ld	a, 0 (iy)		; eeprom page #
	ld	b,#trnpag		; transient page
	call	MMPMAP			; mount it
	;
	ld	hl,#(trnpag << 12 )	; source address (t. page)
	ld	e, 1 (iy)		;
	ld	d, 2 (iy)		; DE = dest address
	ld	c, 3 (iy)		;
	ld	b, 4 (iy)		; BC = size
	ldir				; do copy
	;
	ld	a,(00010$)		; restore
	ld	b,#trnpag		; transient page
	call	MMPMAP			; mount it

	ei
	pop	iy

	ret

	00010$:		.ds	1

	__endasm;
}

int8_t view_index(uint8_t mode)
{
	static uint8_t org = 0;
	static uint8_t act = 0;
	uint8_t i, key, l_act = 0;

k_view_draw:
	setcrs(2, 2);
	printf(" Index     Name       Page    Address   Size   Blk   Description");
	for (i = 0; i < 10; i++) {
		show_line(&rom_io_index[i+org], 3+i, 2, i+org, false);
	}

	do {
		if (mode == IV_INIT)
			return -1;
		show_line(&rom_io_index[act+org], 3+act, 2, act+org, true);


k_view_loop:
		key = getch();
		switch (key) {
			case K_UP:
				if (act == 0)
					goto k_view_loop;
				else {
					l_act = act;
					--act;
				}
				break;
			case K_DOWN:
				if (act == 9)
					goto k_view_loop;
				else {
					l_act = act;
					++act;
				}
				break;
			case K_PGUP:
				if (org == 0)
					goto k_view_loop;
				else {
					org -= 10;
					goto k_view_draw;
				}
			case K_PGDN:
				if (org + 10 > 30)
					goto k_view_loop;
				else {
					org += 10;
					goto k_view_draw;
				}
			case K_F4:
				if ((act+org == 0 || rom_io_index[act+org].name[0] == 0) && mode == IV_BROWSE) {
					zw_msgbox(zwsINFO, "SYSBIOS or empty blocks\ncan't be edited.");
					goto k_view_loop;
				}
				if (rom_io_index[act+org].name[0] == 0 && mode == IV_SELECT && file_flag == ff_op_save) {
					zw_msgbox(zwsINFO, "Trying to save empty block.");
					goto k_view_loop;
				}
				return act+org;
			case K_F10:
				return -1;
		}

		show_line(&rom_io_index[l_act+org], 3+l_act, 2, l_act+org, false);

	} while (true);

// 	return -1;
}

void show_line(ROM_INDEX_BLK * ptr, uint8_t r, uint8_t c, uint8_t num, uint8_t selected)
{
	setcrs(r, c);
	if (selected) zvset(zREVERSE, zON);
	printf ("   %-02d  -  %- 8s  -  %- 2s   -  %-04s  -  %5d - %d - %- 20s", num,
					ptr->name, ptr->page_offset,
					ptr->address, ptr->size,
					ptr->size/4096, ptr->description);

	if (selected) zvset(zREVERSE, zOFF);
}

unsigned int hstoi(const char *s, uint8_t base)
{
	unsigned int acc = 0;
	register int c;

	while (c = *s++) {
		if (isdigit(c))
			c -= '0';
		else if (isalpha(c))
			c -= 'A' - 10;
		else
			break;
		acc *= base;
		acc += c;
	}
	return (acc);
}

void vline(uint8_t row, uint8_t col, uint8_t to_row)
{
	setcrs(row, col);
	putch(CH_ATCDDUP);
	while (row < to_row) {
		setcrs(++row, col);
		putch(CH_DVLINE);
	}
	setcrs(row, col);
	putch(CH_ATCDDDN);
}

void show_stat()
{
	int i;

	uint32_t occ = 0;
	unsigned long epsize = 262144L;
	bslot = 0;
	lslot = 0;

	for (i = 0; i < 10; i++) {
		if (rom_io_index[i].name[0]) {
			++bslot;
			lslot = hstoi(rom_io_index[i].page_offset, HEXB) + (rom_io_index[i].size/4096);
			occ += rom_io_index[i].size;
		}
	}

	setcrs(17, 4); printf("Busy slots..: %d", bslot);
	setcrs(18, 4); printf("Free slots..: %d", rom_max_blk - bslot);
	setcrs(19, 4); printf("Last page...: %X", lslot);
	setcrs(20, 4); printf("Used memory.: %lu bytes", (unsigned long)occ);
	setcrs(21, 4); printf("Free memory.: %lu bytes", (unsigned long)epsize-occ);
}

int8_t edit_block(ROM_INDEX_BLK * block)
{
	zwWindow * win;
	zwObj * bok;
	int8_t rof;
	const char * bcaption;
	char nbuf[6];

	ROM_INDEX_BLK * bl_save = (ROM_INDEX_BLK *)malloc(sizeof(ROM_INDEX_BLK));
	memcpy(bl_save, block, sizeof(ROM_INDEX_BLK));

	if (file_flag == ff_op_add) {
		bcaption = "Add Block";
		sprintf (block->page_offset, "%02X", lslot);
		putch(0x01); 					// only uppercase
	}
	else
		bcaption = "Edit Block";

	sprintf(nbuf, "%u", block->size);

	win = zwNewWindow( 15, 10, 10, 45, 1, bcaption);

	zwNewObject(2, 1,  8, zwsALPHA, 0, "Name.......:", block->name, textinput, win, 0);
	zwNewObject(2, 2,  2, zwsHEX,   0, "Page Offset:", block->page_offset, textinput, win, 0);
	zwNewObject(2, 3,  4, zwsHEX,   0, "Address....:", block->address, textinput, win, 0);
	zwNewObject(2, 4,  5, zwsDIGIT, 0, "Size.......:", nbuf, textinput, win, 0);
	zwNewObject(2, 5, 20, zwsALPHA, 0, "Description:", block->description, textinput, win, 0);

	bok = zwNewObject(3, 9, 1, 1, 0, t_OK, "", button, win, 0);
	zwNewObject(13, 9, 1, 1, 0, t_CANCEL, "", button, win, 0);

	zw_showallobjects(win);
edit_block_again:
	zw_processobj(win, win->firstobj);

	block->size = hstoi(nbuf, DECB);
	rof = win->quitflag;
	if (rof == bok->id + 1) {
		if (zw_msgbox(zwsINPUT, "Are you REALLY sure\nof your changes?") == zwsCANCEL)
			goto edit_block_again;
	}
	else {
			memcpy(block, bl_save, sizeof(ROM_INDEX_BLK));
			rof = zwsCANCEL;
	}

	putch(0x02); 					// reset only uppercase
	if (rof != zwsCANCEL) rof = zwsOK;
	free(bl_save);
	zwCloseWindow(win);

	return rof;
}

int8_t ask_filename()
{
	zwWindow * win;
	zwObj * bok;
	int8_t rof;

	win = zwNewWindow( 20, 12, 4, 40, 1, "Enter filename");

	sprintf(tempbuf, "%s filename",
		(file_flag == ff_op_save) ? "Backup" : "Image"
	);

	current_filename[0] = 0;

	zwNewObject(2, 1,  8+1+3, zwsALPHA, 0, tempbuf, current_filename, textinput, win, 0);

	bok = zwNewObject(3, 3, 1, 1, 0, t_OK, "", button, win, 0);
	zwNewObject(13, 3, 1, 1, 0, t_CANCEL, "", button, win, 0);

	zw_showallobjects(win);
	zw_processobj(win, win->firstobj);

	rof = win->quitflag;
	rof = (rof == bok->id + 1) ? zwsOK : zwsCANCEL;

	zwCloseWindow(win);

	return rof;
}

int8_t file_exists(char * file) {
	struct stat buf;
	return (!stat(file, &buf));
}

int8_t askyn()
{
	char ans;

	do {
		ans = toupper(getch());
	} while (ans != 'Y' && ans != 'N');
	putch(ans);

	return ans;
}

#define	runlog_col	38
#define	runlog_row	16

int8_t do_image_save(char *filename, ROM_INDEX_BLK * block)
{
	uint8_t lrow = runlog_row;
	uint32_t size;
	uint16_t npage, offset;
	uint16_t page_count = 0;
	int8_t werr = 0;
	FILE * ofile;

	zvset(zCURSOR, zON);

	zwscrs(runlog_col, lrow++);
	printf("Saving ");
	if (!block) {
		printf(msg_w_eepr);
		size = 262144L;
		npage = 64;
		offset = 0xc0;
	}
	else {
		printf("image %s on '%s'", block->name, filename);
		size = block->size;
		npage = size / 4096;
		offset = hstoi(block->page_offset, HEXB);
	}

	zwscrs(runlog_col, lrow++);
	printf("Image size %lu bytes, %d pages", size, npage);

	if (file_exists(filename)) {
		zwscrs(runlog_col, lrow++);
		printf(msg_f_over, filename);
		if (askyn() == 'N') {
			clean_op_pane();
			return -1;
		}
	}

	if ((ofile = fopen(filename, "wb")) == 0) {
		zwscrs(runlog_col, lrow++);
		printf(msg_f_nope, filename);
		--werr;
		goto rtn_werr;
	}

	do {
		zwscrs(runlog_col, lrow);
		printf("Saving page %X, %lu bytes of %lu", offset+page_count, (uint32_t)(4096L*(page_count+1L)), size);

		load_rom_page(offset+page_count, (uint16_t)rom_io_buffer, 4096);
		if (fwrite(rom_io_buffer, 4096, 1, ofile) < 1) {
			zwscrs(runlog_col, ++lrow);
			printf(msg_f_ferr);
			--werr;
			goto rtn_werr;

		}
		++page_count;
	} while (--npage);

	zwscrs(runlog_col, ++lrow);
	printf(msg_o_done);

rtn_werr:
	fclose(ofile);
	zvset(zCURSOR, zOFF);
	zwscrs(runlog_col, ++lrow);
	printf(msg_o_anyk);
	getch();
	clean_op_pane();
	return werr;
}

void clean_op_pane()
{
	clrvregion(16, 36, 7, 41);
}

void eeprogram(uint8_t page, uint16_t saddr) __naked 
{
	page; saddr;

	__asm


	trnpag		.equ	0x0e			; Page used for transient MMU ops
	eemont		.equ	trnpag << 12
	eepage2		.equ	0x0c2			; page 2 of eeprom
	eepage5		.equ	0x0c5			; page 5 of eeprom
	eaddr0000	.equ	eemont			; 0000
	eaddr0001	.equ	eemont+0x01		; 0001
	eaddr0002	.equ	eemont+0x02		; 0002
	eaddr5555	.equ	eemont+0x0555		; 5555
	eaddr2aaa	.equ	eemont+0x0aaa		; 2AAA
	SI_B2D		.equ	7
	BD_NOZERO	.equ	1

	.include "darkstar.inc"

		push	iy
		ld	iy,#4
		add	iy,sp

		ld	hl,#0
		ld	(#cnvcnt),hl
		call	BBGETCRS
		inc	l
		ld	(#posbuf), hl

		ld	a, 0 (iy)		; programming page
		ld	(#edestpag),a	
		ld	l, 1 (iy)		; source page
		ld	h, 2 (iy)
		ld	(#esourceadr),hl

		call	trnsave
		di				; NO interrupt on eeprom manipulation
		call	eprotoff		; * disable protection *
		ld	a,(#edestpag)		; mount eeprom page
		ld	d,a
		call	trnmount
		ld	hl,(#esourceadr)	; programming parameters
		ld	de,#eemont
		ld	bc,#4096
	eprg0:	ld	a,#0x80			; per page are 128 bytes to load
	
	pradr:	call sprogress

	eprg2:	dec	a
		ldi				; copy source to dest, dec bc
		jp	po,eprg3		; exit if no more bytes are left to load
		jp	nz,eprg2		; loop until page full
		push	de
		ld	de,#30
		call	DELAY			; pause 30 ms when page full
		pop	de
		jp	eprg0
	eprg3:	ld	de,#170
		call	DELAY			; pause 170 ms
		call	eproton			; * enable protection *
		ei
		call	trnrestore

		pop	iy
		ret

	;;
	;; Show progress
	;;

	sprogress:
		push	hl
		push	de
		push	bc
		push	af

		ld	hl,(#posbuf)
		call	BBSETCRS
		
		ld	hl,(#cnvcnt)
		ld	de,#128
		add	hl,de
		ld	(#cnvcnt),hl

	 	ld      c,#SI_B2D
	        ld      e,#BD_NOZERO
        	call    BBSYSINT

		pop	af
		pop	bc
		pop	de
		pop	hl
		ret


	;;
	;; Disable software data protection
	;;
	eprotoff:
		ld	a,(#_prog_safe_mode)		; Do not if safe mode
		or	a
		ret	nz

		call	eprgintro			; start prg mode
		ld	a,#0x80
		ld	(#eaddr5555),a			; 5555H
		call	eprgintro			; start prg mode
		ld	a,#0x20
		ld	(#eaddr5555),a			; 5555H
		ld	de,#70
		call	DELAY				; pause 70 msec
		ret
	;
	;;
	;; Enable software data protection
	;;
	eproton:
		ld	a,(#_prog_safe_mode)		; Do not if safe mode
		or	a
		ret	nz
 
 		call	eprgintro		; start prg mode
		ld	a,#0x0a0
		ld	(#eaddr5555),a		; 5555H
		ld	de,#170
		call	DELAY			; pause 170 msec
		ret


	;;
	;; Send initial initial prg sequence
	;; **** leave transient on page 5 to complete sequence ****
	;;

	eprgintro:
		ld	a,(#_prog_safe_mode)		; Do not if safe mode
		or	a
		ret	nz
 
		ld	d,#eepage5
		call	trnmount
		ld	a,#0x0aa
		ld	(#eaddr5555),a	;5555H
		ld	d,#eepage2
		call	trnmount
		ld	a,#0x055
		ld	(#eaddr2aaa),a	;2AAAH
		ld	d,#eepage5
		call	trnmount
		ret

	;;
	;; Save transient
	;;
	trnsave:
		; Save transient page setup
		ld	b, #trnpag
		call	MMGETP
		ld	(#eetsav), a		; save current
		ret

	;;
	;; Mount transient
	;;
	;;  D = requested page
	trnmount:
		; Mount transient page used for operations
		ld	a,d			; which page
		ld	b,#trnpag		; transient page
		call	MMPMAP			; mount it
		ret

	;;
	;; Umount transient, restoring old
	;;
	trnrestore:
		ld	a,(#eetsav)		; old
		ld	b,#trnpag		; transient page
		call	MMPMAP			; mount it
		ret


	;;
	;; 16 bit compare
	;;
	cphlde:	or	a			; clear carry
		sbc	hl,de			; compare by subtraction
		add	hl,de			; restore
		ret

	eetsav:		.db	0			; page # save
	eprgen:		.db	0			; programming enabled
		; Programming parameters
	esourceadr:	.dw	0			; base address of the image to be burned
	edestpag:	.db	0			; eeprom address on which to start burning
	cnvcnt:		.dw	0
	posbuf:		.dw	0

	__endasm;


}

int8_t do_image_load(char *filename, ROM_INDEX_BLK * block)
{
	uint8_t lrow = runlog_row;
	uint32_t size;
	uint16_t npage, offset;
	uint16_t page_count = 0;
	int8_t rerr = 0;
	FILE * ifile = 0;

	zvset(zCURSOR, zON);

	zwscrs(runlog_col, lrow++);
	printf("Loading ");
	if (!block) {
		printf(msg_w_eepr);
		size = 262144L;
		npage = 64;
		offset = 0xc0;
	}
	else {
		printf("image %s on '%s'", filename, block->name);
		size = block->size;
		npage = size / 4096;
		offset = hstoi(block->page_offset,HEXB);
	}

	if (!file_exists(filename)) {
		zwscrs(runlog_col, lrow++);
		printf("File %s missing!", filename);
		--rerr;
		goto rtn_rerr;
	}

	if ((ifile = fopen(filename, "rb")) == 0) {
		zwscrs(runlog_col, lrow++);
		printf(msg_f_nope, filename);
		--rerr;
		goto rtn_rerr;
	}

	do {
		zwscrs(runlog_col, lrow);
		printf("Loading page %X, %lu bytes of %lu", offset+page_count, (uint32_t)(4096L*(page_count+1L)), size);

		if (fread(rom_io_buffer, 4096, 1, ifile) < 1) {
			zwscrs(runlog_col, ++lrow);
			printf(msg_f_ferr);
			--rerr;
			goto rtn_rerr;

		}

		zwscrs(runlog_col, ++lrow);
		printf("Flashing page");
		eeprogram(offset, (uint16_t)rom_io_buffer);

		--lrow;
		++page_count;
	} while (--npage);
	++lrow;

	if (block) {
		zwscrs(runlog_col, ++lrow);
		printf("Flashing index");
		eeprogram(rom_index_page, (uint16_t)rom_io_index);
	}	

	zwscrs(runlog_col, ++lrow);
	printf(msg_o_done);

rtn_rerr:
	if (ifile) fclose(ifile);

	zvset(zCURSOR, zOFF);
	zwscrs(runlog_col, ++lrow);
	printf(msg_o_anyk);
	getch();

	clean_op_pane();
	if (rerr && block) erase_row(block);

	return rerr;
}



// --- EOF

