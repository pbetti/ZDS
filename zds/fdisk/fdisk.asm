;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.6.0 #9615 (Linux)
;--------------------------------------------------------
	.module fdisk
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _unlockHDAccess
	.globl _lockHDAccess
	.globl _cls
	.globl _hdWrite
	.globl _hdRead
	.globl _getHDgeo
	.globl _cpm_printf
	.globl _putch
	.globl _getch
	.globl _atoi
	.globl _toupper
	.globl _strlen
	.globl _strncmp
	.globl _clearPartition
	.globl _doFormat
	.globl _editPartition
	.globl _doExit
	.globl _exitPrompt
	.globl _readTable
	.globl _displayTable
	.globl _checkAndInit
	.globl _tab2Buf
	.globl _buf2Tab
	.globl _writeTable
	.globl _uprompt
	.globl _upromptc
	.globl _doHelp
	.globl _gets
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_partition:
	.ds 136
_modified:
	.ds 1
_geometry:
	.ds 4
_hdbuf:
	.ds 512
_ubuf:
	.ds 256
_ltrack:
	.ds 4
_lsects:
	.ds 2
_cview:
	.ds 1
_mbyte:
	.ds 4
_cylsize:
	.ds 4
_msg_partnumber:
	.ds 2
_msg_invinput:
	.ds 2
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area _DABS (ABS)
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area _HOME
	.area _GSINIT
	.area _GSFINAL
	.area _GSINIT
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area _HOME
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
;fdisk.c:82: main()
;	---------------------------------
; Function main
; ---------------------------------
_main::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
;fdisk.c:85: unsigned char loop = true;
	ld	-2 (ix),#0x01
;fdisk.c:88: mbyte = 1024L * 1024L;
	ld	iy,#_mbyte
	ld	0 (iy),#0x00
	ld	1 (iy),#0x00
	ld	2 (iy),#0x10
	ld	3 (iy),#0x00
;fdisk.c:89: cview = 1;
	ld	hl,#_cview + 0
	ld	(hl), #0x01
;fdisk.c:90: ltrack = 0;
	xor	a, a
	ld	iy,#_ltrack
	ld	0 (iy),a
	ld	1 (iy),a
	ld	2 (iy),a
	ld	3 (iy),a
;fdisk.c:91: modified = false;
	ld	hl,#_modified + 0
	ld	(hl), #0x00
;fdisk.c:92: msg_partnumber = "Partition number: ";
	ld	hl,#___str_0+0
	ld	(_msg_partnumber),hl
;fdisk.c:93: msg_invinput = "Invalid input\n";
	ld	hl,#___str_1+0
	ld	(_msg_invinput),hl
;fdisk.c:95: unlockHDAccess();		// enable unpartitioned access to hd
	call	_unlockHDAccess
;fdisk.c:98: cls();
	call	_cls
;fdisk.c:100: printf("\nZ80 Darkstar NEZ80 Partition Manager\n");
	ld	hl,#___str_2
	push	hl
	call	_cpm_printf
;fdisk.c:101: printf("P. Betti, 2014-2018, rev 1.1\n\n");
	ld	hl, #___str_3
	ex	(sp),hl
	call	_cpm_printf
	pop	af
;fdisk.c:104: readTable();
	call	_readTable
;fdisk.c:107: checkAndInit();
	call	_checkAndInit
;fdisk.c:109: displayTable();
	call	_displayTable
;fdisk.c:112: while (loop) {
00119$:
	ld	a,-2 (ix)
	or	a, a
	jp	Z,00121$
;fdisk.c:114: printf("\nEnter command (h = help): ");
	ld	hl,#___str_4
	push	hl
	call	_cpm_printf
	pop	af
;fdisk.c:115: cmd = getch();
	call	_getch
;fdisk.c:116: cmd = toupper(cmd);
	ld	h,#0x00
	push	hl
	call	_toupper
;fdisk.c:117: putch('\n');
	ex	(sp),hl
	ld	a,#0x0a
	push	af
	inc	sp
	call	_putch
	inc	sp
	pop	hl
;fdisk.c:119: switch (cmd) {
	ld	a,l
	cp	a,#0x43
	jp	Z,00117$
	cp	a,#0x45
	jp	Z,00116$
	cp	a,#0x46
	jr	Z,00104$
	cp	a,#0x48
	jr	Z,00101$
	cp	a,#0x4c
	jr	Z,00103$
	sub	a, #0x58
	jr	NZ,00185$
	ld	a,#0x01
	jr	00186$
00185$:
	xor	a,a
00186$:
	ld	-1 (ix),a
	ld	a,l
	cp	a,#0x52
	jr	Z,00106$
	cp	a,#0x53
	jr	Z,00113$
	sub	a, #0x56
	jr	Z,00102$
	ld	a,-1 (ix)
	or	a, a
	jr	NZ,00106$
	jr	00119$
;fdisk.c:120: case 'H':
00101$:
;fdisk.c:121: doHelp();
	call	_doHelp
;fdisk.c:122: break;
	jr	00119$
;fdisk.c:124: case 'V':
00102$:
;fdisk.c:125: cview = ! cview;
	ld	iy,#_cview
	ld	a,0 (iy)
	sub	a,#0x01
	ld	a,#0x00
	rla
	ld	0 (iy), a
;fdisk.c:126: break;
	jr	00119$
;fdisk.c:128: case 'L':
00103$:
;fdisk.c:129: displayTable();
	call	_displayTable
;fdisk.c:130: break;
	jr	00119$
;fdisk.c:132: case 'F':
00104$:
;fdisk.c:133: doFormat();
	call	_doFormat
;fdisk.c:134: break;
	jp	00119$
;fdisk.c:137: case 'R':
00106$:
;fdisk.c:138: if (modified) {
	ld	a,(#_modified + 0)
	or	a, a
	jr	Z,00110$
;fdisk.c:139: printf("Changes pending for save! Reload will discard them.\n");
	ld	hl,#___str_5
	push	hl
	call	_cpm_printf
;fdisk.c:140: printf("Are you shure to proceed ? \n");
	ld	hl, #___str_6
	ex	(sp),hl
	call	_cpm_printf
	pop	af
;fdisk.c:141: answ = getch();
	call	_getch
;fdisk.c:142: answ = toupper(answ);
	ld	h,#0x00
	push	hl
	call	_toupper
	pop	af
;fdisk.c:143: if (answ != 'Y')
	ld	a,l
	sub	a, #0x59
	jp	NZ,00119$
;fdisk.c:144: break;
00110$:
;fdisk.c:146: if (cmd == 'X') {
	ld	a,-1 (ix)
	or	a, a
	jr	Z,00112$
;fdisk.c:147: loop = false;
	ld	-2 (ix),#0x00
;fdisk.c:148: break;
	jp	00119$
00112$:
;fdisk.c:150: readTable();
	call	_readTable
;fdisk.c:151: modified = false;
	ld	hl,#_modified + 0
	ld	(hl), #0x00
;fdisk.c:152: break;
	jp	00119$
;fdisk.c:154: case 'S':
00113$:
;fdisk.c:155: if (! modified) {
	ld	a,(#_modified + 0)
	or	a, a
	jr	NZ,00115$
;fdisk.c:156: printf("Nothing to save.\n");
	ld	hl,#___str_7
	push	hl
	call	_cpm_printf
	pop	af
;fdisk.c:157: break;
	jp	00119$
00115$:
;fdisk.c:159: writeTable();
	call	_writeTable
;fdisk.c:160: modified = false;
	ld	hl,#_modified + 0
	ld	(hl), #0x00
;fdisk.c:161: printf("Saved.\n");
	ld	hl,#___str_8
	push	hl
	call	_cpm_printf
	pop	af
;fdisk.c:162: break;
	jp	00119$
;fdisk.c:164: case 'E':
00116$:
;fdisk.c:165: editPartition();
	call	_editPartition
;fdisk.c:166: break;
	jp	00119$
;fdisk.c:168: case 'C':
00117$:
;fdisk.c:169: clearPartition();
	call	_clearPartition
;fdisk.c:171: }
	jp	00119$
00121$:
;fdisk.c:175: lockHDAccess();
	call	_lockHDAccess
;fdisk.c:176: exitPrompt();
	call	_exitPrompt
;fdisk.c:177: return 0;
	ld	hl,#0x0000
	ld	sp, ix
	pop	ix
	ret
___str_0:
	.ascii "Partition number: "
	.db 0x00
___str_1:
	.ascii "Invalid input"
	.db 0x0a
	.db 0x00
___str_2:
	.db 0x0a
	.ascii "Z80 Darkstar NEZ80 Partition Manager"
	.db 0x0a
	.db 0x00
___str_3:
	.ascii "P. Betti, 2014-2018, rev 1.1"
	.db 0x0a
	.db 0x0a
	.db 0x00
___str_4:
	.db 0x0a
	.ascii "Enter command (h = help): "
	.db 0x00
___str_5:
	.ascii "Changes pending for save! Reload will discard them."
	.db 0x0a
	.db 0x00
___str_6:
	.ascii "Are you shure to proceed ? "
	.db 0x0a
	.db 0x00
___str_7:
	.ascii "Nothing to save."
	.db 0x0a
	.db 0x00
___str_8:
	.ascii "Saved."
	.db 0x0a
	.db 0x00
;fdisk.c:181: void clearPartition()
;	---------------------------------
; Function clearPartition
; ---------------------------------
_clearPartition::
	push	ix
	ld	ix,#0
	add	ix,sp
	dec	sp
;fdisk.c:184: char prm = 'N';
	ld	-1 (ix),#0x4e
;fdisk.c:187: printf(msg_partnumber);
	ld	hl,(_msg_partnumber)
	push	hl
	call	_cpm_printf
;fdisk.c:188: gets(ubuf);
	ld	hl, #_ubuf
	ex	(sp),hl
	call	_gets
;fdisk.c:189: pnum = atoi(ubuf);
	ld	hl, #_ubuf
	ex	(sp),hl
	call	_atoi
	pop	af
	ld	c,l
	ld	b,h
;fdisk.c:191: if (pnum < 1 || pnum > MAX_PARTITIONS ) {
	ld	a,c
	sub	a, #0x01
	ld	a,b
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	C,00101$
	ld	a,#0x10
	cp	a, c
	ld	a,#0x00
	sbc	a, b
	jp	PO, 00116$
	xor	a, #0x80
00116$:
	jp	P,00102$
00101$:
;fdisk.c:192: printf(msg_invinput);
	ld	hl,(_msg_invinput)
	push	hl
	call	_cpm_printf
	pop	af
;fdisk.c:193: return;
	jr	00106$
00102$:
;fdisk.c:195: --pnum;
	dec	bc
;fdisk.c:197: upromptc("Are you shure ?", &prm, "YN");
	ld	hl,#0x0000
	add	hl,sp
	ex	de,hl
	push	bc
	ld	hl,#___str_10
	push	hl
	push	de
	ld	hl,#___str_9
	push	hl
	call	_upromptc
	ld	hl,#6
	add	hl,sp
	ld	sp,hl
	pop	bc
;fdisk.c:199: if (prm == 'Y') {
	ld	a,-1 (ix)
	sub	a, #0x59
	jr	NZ,00106$
;fdisk.c:200: memset((void *) partition.table[pnum], 0, sizeof(PARTINFO) );
	ld	de,#_partition+8
	ld	l, c
	ld	h, b
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	a,e
	add	a, l
	ld	c,a
	ld	a,d
	adc	a, h
	ld	b,a
	push	hl
	ld	l, c
	ld	h, b
	ld	b, #0x08
00119$:
	ld	(hl), #0x00
	inc	hl
	djnz	00119$
	pop	hl
;fdisk.c:201: partition.table[pnum].active = 'N';
	add	hl,de
	ld	c,l
	ld	b,h
	ld	(hl),#0x4e
;fdisk.c:202: partition.table[pnum].letter = ' ';
	ld	l, c
	ld	h, b
	inc	hl
	ld	(hl),#0x20
;fdisk.c:203: partition.table[pnum].ptype = 'X';
	inc	bc
	inc	bc
	ld	h,b
	ld	l, c
	ld	(hl),#0x58
00106$:
	inc	sp
	pop	ix
	ret
___str_9:
	.ascii "Are you shure ?"
	.db 0x00
___str_10:
	.ascii "YN"
	.db 0x00
;fdisk.c:207: void doFormat()
;	---------------------------------
; Function doFormat
; ---------------------------------
_doFormat::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl,#-7
	add	hl,sp
	ld	sp,hl
;fdisk.c:210: char prm = 'N';
	ld	-7 (ix),#0x4e
;fdisk.c:213: printf(msg_partnumber);
	ld	hl,(_msg_partnumber)
	push	hl
	call	_cpm_printf
;fdisk.c:214: gets(ubuf);
	ld	hl, #_ubuf
	ex	(sp),hl
	call	_gets
;fdisk.c:215: pnum = atoi(ubuf);
	ld	hl, #_ubuf
	ex	(sp),hl
	call	_atoi
	pop	af
	ld	c,l
	ld	b,h
;fdisk.c:217: if (pnum < 1 || pnum > MAX_PARTITIONS ) {
	ld	a,c
	sub	a, #0x01
	ld	a,b
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	C,00101$
	ld	a,#0x10
	cp	a, c
	ld	a,#0x00
	sbc	a, b
	jp	PO, 00151$
	xor	a, #0x80
00151$:
	jp	P,00102$
00101$:
;fdisk.c:218: printf(msg_invinput);
	ld	hl,(_msg_invinput)
	push	hl
	call	_cpm_printf
	pop	af
;fdisk.c:219: return;
	jp	00117$
00102$:
;fdisk.c:221: --pnum;
	dec	bc
;fdisk.c:223: printf("This will delete entire volume %c. ", partition.table[pnum].letter);
	ld	de,#_partition+8
	ld	l, c
	ld	h, b
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl,de
	ld	e,l
	ld	d,h
	inc	hl
	ld	c,(hl)
	ld	b,#0x00
	push	de
	push	bc
	ld	hl,#___str_11
	push	hl
	call	_cpm_printf
	pop	af
	pop	af
	pop	de
;fdisk.c:224: upromptc("Confirm ?", &prm, "YN");
	ld	hl,#0x0000
	add	hl,sp
	ld	c,l
	ld	b,h
	ld	-2 (ix),c
	ld	-1 (ix),b
	push	bc
	push	de
	ld	hl,#___str_13
	push	hl
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	push	hl
	ld	hl,#___str_12
	push	hl
	call	_upromptc
	ld	hl,#6
	add	hl,sp
	ld	sp,hl
	pop	de
	pop	bc
;fdisk.c:225: modified = false;
	ld	hl,#_modified + 0
	ld	(hl), #0x00
;fdisk.c:226: if (prm != 'Y')
	ld	a,-7 (ix)
	sub	a, #0x59
;fdisk.c:227: return;
	jp	NZ,00117$
;fdisk.c:229: upromptc("Are you shure ?", &prm, "YN");
	push	de
	ld	hl,#___str_13
	push	hl
	push	bc
	ld	hl,#___str_14
	push	hl
	call	_upromptc
	ld	hl,#6
	add	hl,sp
	ld	sp,hl
	pop	de
;fdisk.c:230: modified = false;
	ld	hl,#_modified + 0
	ld	(hl), #0x00
;fdisk.c:231: if (prm != 'Y')
	ld	a,-7 (ix)
	sub	a, #0x59
;fdisk.c:232: return;
	jp	NZ,00117$
;fdisk.c:235: memset((void *) hdbuf, 0xe5, 512 );
	ld	hl,#_hdbuf
	push	de
	ld	(hl), #0xe5
	ld	e, l
	ld	d, h
	inc	de
	ld	bc, #0x01ff
	ldir
	ld	hl,#___str_15
	push	hl
	call	_cpm_printf
	pop	af
	pop	de
;fdisk.c:240: for (trk = partition.table[pnum].startcyl; trk < partition.table[pnum].endcyl; trk++) {
	ld	hl,#0x0003
	add	hl,de
	ld	-2 (ix),l
	ld	-1 (ix),h
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	-4 (ix),e
	ld	-3 (ix),d
00115$:
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	ld	de, #0x0005
	add	hl, de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	-6 (ix),c
	ld	-5 (ix),b
	ld	a,-6 (ix)
	sub	a, e
	ld	a,-5 (ix)
	sbc	a, d
	jr	NC,00111$
;fdisk.c:242: for (sec = 0; sec < 256; sec++) {
	ld	de,#0x0000
00112$:
;fdisk.c:244: trk - partition.table[pnum].startcyl,
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	ld	a, (hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ld	a,-6 (ix)
	sub	a, l
	ld	l,a
	ld	a,-5 (ix)
	sbc	a, h
	ld	h,a
;fdisk.c:243: printf("Trk: %d, sec: %d     \r",
	push	bc
	push	de
	push	de
	push	hl
	ld	hl,#___str_16
	push	hl
	call	_cpm_printf
	ld	hl,#6
	add	hl,sp
	ld	sp,hl
	pop	de
	pop	bc
;fdisk.c:246: if ( hdWrite(hdbuf, trk, sec) ) {
	push	bc
	push	de
	push	de
	push	bc
	ld	hl,#_hdbuf
	push	hl
	call	_hdWrite
	pop	af
	pop	af
	pop	af
	pop	de
	pop	bc
	ld	a,h
	or	a,l
	jr	Z,00113$
;fdisk.c:247: printf("\nFormat error!\n");
	ld	hl,#___str_17
	push	hl
	call	_cpm_printf
	pop	af
;fdisk.c:248: return;
	jr	00117$
00113$:
;fdisk.c:242: for (sec = 0; sec < 256; sec++) {
	inc	de
	ld	a,d
	xor	a, #0x80
	sub	a, #0x81
	jr	C,00112$
;fdisk.c:240: for (trk = partition.table[pnum].startcyl; trk < partition.table[pnum].endcyl; trk++) {
	inc	bc
	jr	00115$
00111$:
;fdisk.c:252: printf("\nDone.\n");
	ld	hl,#___str_18
	push	hl
	call	_cpm_printf
	pop	af
00117$:
	ld	sp, ix
	pop	ix
	ret
___str_11:
	.ascii "This will delete entire volume %c. "
	.db 0x00
___str_12:
	.ascii "Confirm ?"
	.db 0x00
___str_13:
	.ascii "YN"
	.db 0x00
___str_14:
	.ascii "Are you shure ?"
	.db 0x00
___str_15:
	.ascii "Formatting..."
	.db 0x0a
	.db 0x00
___str_16:
	.ascii "Trk: %d, sec: %d     "
	.db 0x0d
	.db 0x00
___str_17:
	.db 0x0a
	.ascii "Format error!"
	.db 0x0a
	.db 0x00
___str_18:
	.db 0x0a
	.ascii "Done."
	.db 0x0a
	.db 0x00
;fdisk.c:255: void editPartition()
;	---------------------------------
; Function editPartition
; ---------------------------------
_editPartition::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl,#-29
	add	hl,sp
	ld	sp,hl
;fdisk.c:264: printf(msg_partnumber);
	ld	hl,(_msg_partnumber)
	push	hl
	call	_cpm_printf
;fdisk.c:265: gets(ubuf);
	ld	hl, #_ubuf
	ex	(sp),hl
	call	_gets
;fdisk.c:266: pnum = atoi(ubuf);
	ld	hl, #_ubuf
	ex	(sp),hl
	call	_atoi
	pop	af
	ld	-16 (ix),l
	ld	-15 (ix),h
;fdisk.c:268: if (pnum < 1 || pnum > MAX_PARTITIONS ) {
	ld	a,-16 (ix)
	sub	a, #0x01
	ld	a,-15 (ix)
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	C,00101$
	ld	a,#0x10
	cp	a, -16 (ix)
	ld	a,#0x00
	sbc	a, -15 (ix)
	jp	PO, 00195$
	xor	a, #0x80
00195$:
	jp	P,00102$
00101$:
;fdisk.c:269: printf(msg_invinput);
	ld	hl,(_msg_invinput)
	push	hl
	call	_cpm_printf
	pop	af
;fdisk.c:270: return;
	jp	00131$
00102$:
;fdisk.c:272: --pnum;
	ld	a,-16 (ix)
	add	a,#0xff
	ld	-26 (ix),a
	ld	a,-15 (ix)
	adc	a,#0xff
	ld	-25 (ix),a
;fdisk.c:276: scyl = partition.table[pnum].startcyl;
	ld	l,-26 (ix)
	ld	h,-25 (ix)
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	a,#<((_partition + 0x0008))
	add	a, l
	ld	-16 (ix),a
	ld	a,#>((_partition + 0x0008))
	adc	a, h
	ld	-15 (ix),a
	ld	a,-16 (ix)
	add	a, #0x03
	ld	-14 (ix),a
	ld	a,-15 (ix)
	adc	a, #0x00
	ld	-13 (ix),a
	ld	l,-14 (ix)
	ld	h,-13 (ix)
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	-28 (ix),c
	ld	-27 (ix),b
;fdisk.c:277: oscyl = scyl;
	ld	-12 (ix),c
	ld	-11 (ix),b
;fdisk.c:278: if (scyl == 0) {
	ld	a,b
	or	a,c
	jr	NZ,00108$
;fdisk.c:279: for (i = 0; i < MAX_PARTITIONS; i++) {
	ld	bc,#0x0000
00128$:
;fdisk.c:280: if (partition.table[i].endcyl > scyl)
	ld	l, c
	ld	h, b
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	de,#(_partition + 0x0008)
	add	hl,de
	ld	de, #0x0005
	add	hl, de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	a,-28 (ix)
	sub	a, e
	ld	a,-27 (ix)
	sbc	a, d
	jr	NC,00129$
;fdisk.c:281: scyl = partition.table[i].endcyl;
	ld	-28 (ix),e
	ld	-27 (ix),d
00129$:
;fdisk.c:279: for (i = 0; i < MAX_PARTITIONS; i++) {
	inc	bc
	ld	a,c
	sub	a, #0x10
	ld	a,b
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	C,00128$
;fdisk.c:283: ++scyl;
	inc	-28 (ix)
	jr	NZ,00196$
	inc	-27 (ix)
00196$:
;fdisk.c:284: modified = 1;
	ld	hl,#_modified + 0
	ld	(hl), #0x01
00108$:
;fdisk.c:288: uprompt("Starting cylinder", &scyl);
	ld	hl,#0x0001
	add	hl,sp
	ld	bc,#___str_19+0
	push	hl
	push	bc
	call	_uprompt
	pop	af
	pop	af
;fdisk.c:289: if (scyl > ltrack - 3) {
	ld	iy,#_ltrack
	ld	a,0 (iy)
	add	a,#0xfd
	ld	-10 (ix),a
	ld	a,1 (iy)
	adc	a,#0xff
	ld	-9 (ix),a
	ld	a,2 (iy)
	adc	a,#0xff
	ld	-8 (ix),a
	ld	a,3 (iy)
	adc	a,#0xff
	ld	-7 (ix),a
	ld	c,-28 (ix)
	ld	b,-27 (ix)
	ld	de,#0x0000
	ld	a,-10 (ix)
	sub	a, c
	ld	a,-9 (ix)
	sbc	a, b
	ld	a,-8 (ix)
	sbc	a, e
	ld	a,-7 (ix)
	sbc	a, d
	jr	NC,00110$
;fdisk.c:290: printf(msg_invinput);
	ld	hl,(_msg_invinput)
	push	hl
	call	_cpm_printf
	pop	af
;fdisk.c:291: return;
	jp	00131$
00110$:
;fdisk.c:293: partition.table[pnum].startcyl = scyl;
	ld	l,-14 (ix)
	ld	h,-13 (ix)
	ld	a,-28 (ix)
	ld	(hl),a
	inc	hl
	ld	a,-27 (ix)
	ld	(hl),a
;fdisk.c:296: if (scyl > partition.table[pnum].endcyl) {
	ld	a,-16 (ix)
	add	a, #0x05
	ld	-10 (ix),a
	ld	a,-15 (ix)
	adc	a, #0x00
	ld	-9 (ix),a
	ld	l,-10 (ix)
	ld	h,-9 (ix)
	ld	a,(hl)
	ld	-6 (ix),a
	inc	hl
	ld	a,(hl)
	ld	-5 (ix),a
	ld	a,-6 (ix)
	sub	a, -28 (ix)
	ld	a,-5 (ix)
	sbc	a, -27 (ix)
	jr	NC,00112$
;fdisk.c:297: mbsiz = 0;
	ld	-24 (ix),#0x00
	ld	-23 (ix),#0x00
	jp	00113$
00112$:
;fdisk.c:300: psiz = (unsigned long)partition.table[pnum].endcyl - (unsigned long)partition.table[pnum].startcyl;
	ld	a,-6 (ix)
	ld	-20 (ix),a
	ld	a,-5 (ix)
	ld	-19 (ix),a
	ld	-18 (ix),#0x00
	ld	-17 (ix),#0x00
	ld	l,-14 (ix)
	ld	h,-13 (ix)
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	de,#0x0000
	ld	a,-20 (ix)
	sub	a, c
	ld	c,a
	ld	a,-19 (ix)
	sbc	a, b
	ld	b,a
	ld	a,-18 (ix)
	sbc	a, e
	ld	e,a
	ld	a,-17 (ix)
	sbc	a, d
	ld	d,a
;fdisk.c:301: printf("Num cyls: %ld\n",psiz);
	push	de
	push	bc
	ld	hl,#___str_20
	push	hl
	call	_cpm_printf
	ld	hl,#6
	add	hl,sp
	ld	sp,hl
;fdisk.c:303: psiz = (((unsigned long)partition.table[pnum].endcyl - (unsigned long)partition.table[pnum].startcyl) * cylsize);
	ld	l,-10 (ix)
	ld	h,-9 (ix)
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	-20 (ix),c
	ld	-19 (ix),b
	ld	-18 (ix),#0x00
	ld	-17 (ix),#0x00
	ld	l,-14 (ix)
	ld	h,-13 (ix)
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	de,#0x0000
	ld	a,-20 (ix)
	sub	a, c
	ld	c,a
	ld	a,-19 (ix)
	sbc	a, b
	ld	b,a
	ld	a,-18 (ix)
	sbc	a, e
	ld	e,a
	ld	a,-17 (ix)
	sbc	a, d
	ld	d,a
	ld	hl,(_cylsize + 2)
	push	hl
	ld	hl,(_cylsize)
	push	hl
	push	de
	push	bc
	call	__mullong
	pop	af
	pop	af
	pop	af
	pop	af
	ex	de, hl
;fdisk.c:304: printf("Size: %ld\n",psiz);
	ld	bc,#___str_21+0
	push	hl
	push	de
	push	bc
	call	_cpm_printf
	ld	hl,#6
	add	hl,sp
	ld	sp,hl
;fdisk.c:307: psiz = (((unsigned long)partition.table[pnum].endcyl - (unsigned long)partition.table[pnum].startcyl)
	ld	l,-10 (ix)
	ld	h,-9 (ix)
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	-20 (ix),c
	ld	-19 (ix),b
	ld	-18 (ix),#0x00
	ld	-17 (ix),#0x00
	ld	l,-14 (ix)
	ld	h,-13 (ix)
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	de,#0x0000
	ld	a,-20 (ix)
	sub	a, c
	ld	c,a
	ld	a,-19 (ix)
	sbc	a, b
	ld	b,a
	ld	a,-18 (ix)
	sbc	a, e
	ld	e,a
	ld	a,-17 (ix)
	sbc	a, d
	ld	d,a
	ld	hl,(_cylsize + 2)
	push	hl
	ld	hl,(_cylsize)
	push	hl
	push	de
	push	bc
	call	__mullong
	pop	af
	pop	af
	pop	af
	pop	af
	ld	c,l
	ld	b,h
	ld	hl,(_mbyte + 2)
	push	hl
	ld	hl,(_mbyte)
	push	hl
	push	de
	push	bc
	call	__divulong
	pop	af
	pop	af
	pop	af
	pop	af
	ld	c,l
	ld	b,h
;fdisk.c:309: printf("Mb: %ld\n",psiz);
	push	bc
	push	de
	push	de
	push	bc
	ld	hl,#___str_22
	push	hl
	call	_cpm_printf
	ld	hl,#6
	add	hl,sp
	ld	sp,hl
	pop	de
	pop	bc
;fdisk.c:311: mbsiz = (unsigned int)psiz;
	ld	-24 (ix),c
	ld	-23 (ix),b
00113$:
;fdisk.c:313: oecyl = partition.table[pnum].endcyl;
	ld	l,-10 (ix)
	ld	h,-9 (ix)
	ld	a,(hl)
	ld	-22 (ix),a
	inc	hl
	ld	a,(hl)
	ld	-21 (ix),a
;fdisk.c:315: uprompt("Partition size in Mbytes", &mbsiz);
	ld	hl,#0x0005
	add	hl,sp
	ld	bc,#___str_23+0
	push	hl
	push	bc
	call	_uprompt
	pop	af
	pop	af
;fdisk.c:316: psiz = (unsigned long)mbsiz * mbyte;
	ld	c,-24 (ix)
	ld	b,-23 (ix)
	ld	de,#0x0000
	ld	hl,(_mbyte + 2)
	push	hl
	ld	hl,(_mbyte)
	push	hl
	push	de
	push	bc
	call	__mullong
	pop	af
	pop	af
	pop	af
	pop	af
	ld	-20 (ix),l
	ld	-19 (ix),h
	ld	-18 (ix),e
	ld	-17 (ix),d
;fdisk.c:317: mbsiz = (unsigned int)(psiz / cylsize);
	ld	hl,(_cylsize + 2)
	push	hl
	ld	hl,(_cylsize)
	push	hl
	ld	l,-18 (ix)
	ld	h,-17 (ix)
	push	hl
	ld	l,-20 (ix)
	ld	h,-19 (ix)
	push	hl
	call	__divulong
	pop	af
	pop	af
	pop	af
	pop	af
;fdisk.c:319: ajcyl = mbsiz;
	ld	-24 (ix),l
	ld	-23 (ix),h
	ld	c,l
	ld	b,h
	ld	de,#0x0000
;fdisk.c:320: while ( (ajcyl * cylsize) < psiz ) {
00114$:
	push	bc
	push	de
	ld	hl,(_cylsize + 2)
	push	hl
	ld	hl,(_cylsize)
	push	hl
	push	de
	push	bc
	call	__mullong
	pop	af
	pop	af
	pop	af
	pop	af
	ld	-1 (ix),d
	ld	-2 (ix),e
	ld	-3 (ix),h
	ld	-4 (ix),l
	pop	de
	pop	bc
	ld	a,-4 (ix)
	sub	a, -20 (ix)
	ld	a,-3 (ix)
	sbc	a, -19 (ix)
	ld	a,-2 (ix)
	sbc	a, -18 (ix)
	ld	a,-1 (ix)
	sbc	a, -17 (ix)
	jr	NC,00116$
;fdisk.c:321: ++ajcyl;
	inc	c
	jr	NZ,00114$
	inc	b
	jr	NZ,00114$
	inc	e
	jr	NZ,00114$
	inc	d
	jr	00114$
00116$:
;fdisk.c:324: mbsiz = (unsigned int)ajcyl + scyl;
	ld	a,c
	add	a, -28 (ix)
	ld	c,a
	ld	a,b
	adc	a, -27 (ix)
	ld	b,a
	ld	-24 (ix),c
	ld	-23 (ix),b
;fdisk.c:326: if (mbsiz > ltrack - 2) {
	ld	iy,#_ltrack
	ld	a,0 (iy)
	add	a,#0xfe
	ld	-4 (ix),a
	ld	a,1 (iy)
	adc	a,#0xff
	ld	-3 (ix),a
	ld	a,2 (iy)
	adc	a,#0xff
	ld	-2 (ix),a
	ld	a,3 (iy)
	adc	a,#0xff
	ld	-1 (ix),a
	ld	e,c
	ld	d,b
	ld	hl,#0x0000
	ld	a,-4 (ix)
	sub	a, e
	ld	a,-3 (ix)
	sbc	a, d
	ld	a,-2 (ix)
	sbc	a, l
	ld	a,-1 (ix)
	sbc	a, h
	jr	NC,00118$
;fdisk.c:327: printf("Cylinder %d too high!\n", mbsiz);
	push	bc
	ld	hl,#___str_24
	push	hl
	call	_cpm_printf
	pop	af
	pop	af
;fdisk.c:328: return;
	jp	00131$
00118$:
;fdisk.c:330: partition.table[pnum].endcyl = mbsiz;
	ld	l,-10 (ix)
	ld	h,-9 (ix)
	ld	(hl),c
	inc	hl
	ld	(hl),b
;fdisk.c:333: for (i = 0; i < MAX_PARTITIONS; i++) {
	ld	-4 (ix),#0x00
	ld	-3 (ix),#0x00
	ld	bc,#0x0000
00130$:
;fdisk.c:334: if (i == pnum)
	ld	a,-26 (ix)
	sub	a, c
	jr	NZ,00198$
	ld	a,-25 (ix)
	sub	a, b
	jp	Z,00126$
00198$:
;fdisk.c:336: if ( (partition.table[pnum].endcyl >= partition.table[i].startcyl && partition.table[pnum].endcyl <= partition.table[i].endcyl) ||
	ld	l,-10 (ix)
	ld	h,-9 (ix)
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	l, c
	ld	h, b
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	iy,#(_partition + 0x0008)
	push	bc
	ld	c, l
	ld	b, h
	add	iy, bc
	pop	bc
	push	iy
	pop	hl
	inc	hl
	inc	hl
	inc	hl
	ld	a,(hl)
	ld	-20 (ix),a
	inc	hl
	ld	a,(hl)
	ld	-19 (ix),a
	push	bc
	ld	bc,#0x0005
	add	iy, bc
	pop	bc
	ld	a,e
	sub	a, -20 (ix)
	ld	a,d
	sbc	a, -19 (ix)
	jr	C,00125$
	ld	l,0 (iy)
	ld	h,1 (iy)
	cp	a, a
	sbc	hl, de
	jr	NC,00121$
00125$:
;fdisk.c:337: (partition.table[pnum].startcyl >= partition.table[i].startcyl && partition.table[pnum].startcyl <= partition.table[i].endcyl)
	ld	l,-14 (ix)
	ld	h,-13 (ix)
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	a,e
	sub	a, -20 (ix)
	ld	a,d
	sbc	a, -19 (ix)
	jr	C,00126$
	ld	l,0 (iy)
	ld	h,1 (iy)
	cp	a, a
	sbc	hl, de
	jr	C,00126$
00121$:
;fdisk.c:339: printf("Overlapping partions %d!\n", i+1);
	ld	c,-4 (ix)
	ld	b,-3 (ix)
	inc	bc
	push	bc
	ld	hl,#___str_25
	push	hl
	call	_cpm_printf
	pop	af
	pop	af
;fdisk.c:340: partition.table[pnum].startcyl = oscyl;
	ld	l,-14 (ix)
	ld	h,-13 (ix)
	ld	a,-12 (ix)
	ld	(hl),a
	inc	hl
	ld	a,-11 (ix)
	ld	(hl),a
;fdisk.c:341: partition.table[pnum].endcyl = oecyl;
	ld	l,-10 (ix)
	ld	h,-9 (ix)
	ld	a,-22 (ix)
	ld	(hl),a
	inc	hl
	ld	a,-21 (ix)
	ld	(hl),a
;fdisk.c:342: modified = false;
	ld	hl,#_modified + 0
	ld	(hl), #0x00
;fdisk.c:343: return;
	jp	00131$
00126$:
;fdisk.c:333: for (i = 0; i < MAX_PARTITIONS; i++) {
	inc	bc
	ld	-4 (ix),c
	ld	-3 (ix),b
	ld	a,c
	sub	a, #0x10
	ld	a,b
	rla
	ccf
	rra
	sbc	a, #0x80
	jp	C,00130$
;fdisk.c:348: prm = partition.table[pnum].active;
	ld	l,-16 (ix)
	ld	h,-15 (ix)
	ld	a,(hl)
	ld	-29 (ix),a
;fdisk.c:350: upromptc("Activate partition", &prm, "YN");
	ld	hl,#0x0000
	add	hl,sp
	ld	bc,#___str_26+0
	ld	de,#___str_27
	push	de
	push	hl
	push	bc
	call	_upromptc
	ld	hl,#6
	add	hl,sp
	ld	sp,hl
;fdisk.c:351: partition.table[pnum].active = prm;
	ld	l,-16 (ix)
	ld	h,-15 (ix)
	ld	a,-29 (ix)
	ld	(hl),a
;fdisk.c:354: prm = partition.table[pnum].letter;
	ld	c,-16 (ix)
	ld	b,-15 (ix)
	inc	bc
	ld	a,(bc)
	ld	-29 (ix),a
;fdisk.c:356: upromptc("Drive id [A-P,0-9]", &prm, "ABCDEFGHIJKLMNOP0123456789");
	ld	hl,#0x0000
	add	hl,sp
	ex	de,hl
	push	bc
	ld	hl,#___str_29
	push	hl
	push	de
	ld	hl,#___str_28
	push	hl
	call	_upromptc
	ld	hl,#6
	add	hl,sp
	ld	sp,hl
	pop	bc
;fdisk.c:357: partition.table[pnum].letter = prm;
	ld	a,-29 (ix)
	ld	(bc),a
;fdisk.c:360: prm = partition.table[pnum].ptype;
	ld	c,-16 (ix)
	ld	b,-15 (ix)
	inc	bc
	inc	bc
	ld	a,(bc)
	ld	-29 (ix),a
;fdisk.c:362: upromptc("2=CP/M2\n\
	ld	hl,#0x0000
	add	hl,sp
	ex	de,hl
	push	bc
	ld	hl,#___str_31
	push	hl
	push	de
	ld	hl,#___str_30
	push	hl
	call	_upromptc
	ld	hl,#6
	add	hl,sp
	ld	sp,hl
	pop	bc
;fdisk.c:370: partition.table[pnum].ptype = prm;
	ld	a,-29 (ix)
	ld	(bc),a
;fdisk.c:373: displayTable();
	call	_displayTable
00131$:
	ld	sp, ix
	pop	ix
	ret
___str_19:
	.ascii "Starting cylinder"
	.db 0x00
___str_20:
	.ascii "Num cyls: %ld"
	.db 0x0a
	.db 0x00
___str_21:
	.ascii "Size: %ld"
	.db 0x0a
	.db 0x00
___str_22:
	.ascii "Mb: %ld"
	.db 0x0a
	.db 0x00
___str_23:
	.ascii "Partition size in Mbytes"
	.db 0x00
___str_24:
	.ascii "Cylinder %d too high!"
	.db 0x0a
	.db 0x00
___str_25:
	.ascii "Overlapping partions %d!"
	.db 0x0a
	.db 0x00
___str_26:
	.ascii "Activate partition"
	.db 0x00
___str_27:
	.ascii "YN"
	.db 0x00
___str_28:
	.ascii "Drive id [A-P,0-9]"
	.db 0x00
___str_29:
	.ascii "ABCDEFGHIJKLMNOP0123456789"
	.db 0x00
___str_30:
	.ascii "2=CP/M2"
	.db 0x0a
	.ascii "3=CP/M3"
	.db 0x0a
	.ascii "N=NEDOS"
	.db 0x0a
	.ascii "U=UZI/Fuzix"
	.db 0x0a
	.ascii "T=TurboDOS"
	.db 0x0a
	.ascii "C=CPM/ng / CP"
	.ascii "/M4"
	.db 0x0a
	.ascii "O=Others"
	.db 0x0a
	.ascii "Select partition type"
	.db 0x00
___str_31:
	.ascii "23NUTCO"
	.db 0x00
;fdisk.c:376: void doExit()
;	---------------------------------
; Function doExit
; ---------------------------------
_doExit::
;fdisk.c:378: lockHDAccess();
	call	_lockHDAccess
;fdisk.c:379: exitPrompt();
	call	_exitPrompt
;fdisk.c:383: __endasm;
	jp	0
	ret
;fdisk.c:386: void exitPrompt()
;	---------------------------------
; Function exitPrompt
; ---------------------------------
_exitPrompt::
;fdisk.c:389: printf("Terminating...\n");
	ld	hl,#___str_32
	push	hl
	call	_cpm_printf
	pop	af
	ret
___str_32:
	.ascii "Terminating..."
	.db 0x0a
	.db 0x00
;fdisk.c:392: void readTable()
;	---------------------------------
; Function readTable
; ---------------------------------
_readTable::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl,#-6
	add	hl,sp
	ld	sp,hl
;fdisk.c:396: getHDgeo(&geometry);
	ld	hl,#_geometry
	push	hl
	call	_getHDgeo
	pop	af
;fdisk.c:401: geometry.sectors
	ld	hl, #(_geometry + 0x0003) + 0
	ld	e,(hl)
	ld	d,#0x00
;fdisk.c:400: geometry.heads,
	ld	a, (#(_geometry + 0x0002) + 0)
	ld	-6 (ix),a
	ld	-5 (ix),#0x00
;fdisk.c:399: geometry.cylinders,
	ld	hl, (#_geometry + 0)
;fdisk.c:398: printf("Disk is %d cylinders, %d heads, %d sectors.\n",
	ld	bc,#___str_33+0
	push	de
	ld	e,-6 (ix)
	ld	d,-5 (ix)
	push	de
	push	hl
	push	bc
	call	_cpm_printf
	ld	hl,#8
	add	hl,sp
	ld	sp,hl
;fdisk.c:404: tsectors = (unsigned long)geometry.cylinders * (unsigned long)geometry.heads * (unsigned long)geometry.sectors;
	ld	bc, (#_geometry + 0)
	ld	de,#0x0000
	ld	a, (#(_geometry + 0x0002) + 0)
	ld	-4 (ix),a
	ld	-3 (ix),#0x00
	ld	-2 (ix),#0x00
	ld	-1 (ix),#0x00
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	push	hl
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	push	hl
	push	de
	push	bc
	call	__mullong
	pop	af
	pop	af
	pop	af
	pop	af
	ld	c,l
	ld	b,h
	ld	a, (#(_geometry + 0x0003) + 0)
	ld	-4 (ix),a
	ld	-3 (ix),#0x00
	ld	-2 (ix),#0x00
	ld	-1 (ix),#0x00
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	push	hl
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	push	hl
	push	de
	push	bc
	call	__mullong
	pop	af
	pop	af
	pop	af
	pop	af
	ld	c,l
	ld	b,h
;fdisk.c:405: printf("Disk size is %ld sectors.\n", tsectors);
	push	bc
	push	de
	push	de
	push	bc
	ld	hl,#___str_34
	push	hl
	call	_cpm_printf
	ld	hl,#6
	add	hl,sp
	ld	sp,hl
	pop	de
	pop	bc
;fdisk.c:408: lsects = 256;
	ld	hl,#0x0100
	ld	(_lsects),hl
;fdisk.c:409: geometry.cylinders = tsectors / lsects;
	ld	hl,#0x0000
	push	hl
	ld	hl,#0x0100
	push	hl
	push	de
	push	bc
	call	__divulong
	pop	af
	pop	af
	pop	af
	pop	af
	ex	de, hl
	ld	(_geometry), de
;fdisk.c:411: cylsize = (unsigned long)lsects * 512L;
	ld	iy,#_cylsize
	ld	0 (iy),#0x00
	ld	1 (iy),#0x00
	ld	2 (iy),#0x02
	ld	3 (iy),#0x00
;fdisk.c:412: printf("Cylinder size is %ld bytes.\n", cylsize);
	ld	hl,#0x0002
	push	hl
	ld	hl,#0x0000
	push	hl
	ld	hl,#___str_35
	push	hl
	call	_cpm_printf
	ld	hl,#6
	add	hl,sp
	ld	sp,hl
;fdisk.c:414: ltrack = (unsigned long)geometry.cylinders - 1;
	ld	bc, (#_geometry + 0)
	ld	de,#0x0000
	ld	hl,#_ltrack
	ld	a,c
	add	a,#0xff
	ld	(hl),a
	ld	a,b
	adc	a,#0xff
	inc	hl
	ld	(hl),a
	ld	a,e
	adc	a,#0xff
	inc	hl
	ld	(hl),a
	ld	a,d
	adc	a,#0xff
	inc	hl
	ld	(hl),a
;fdisk.c:415: printf("CP/M LBA addressing: %ld tracks, %d sectors (1 track reserved)\n", ltrack, lsects);
	ld	hl,(_lsects)
	push	hl
	ld	hl,(_ltrack + 2)
	push	hl
	ld	hl,(_ltrack)
	push	hl
	ld	hl,#___str_36
	push	hl
	call	_cpm_printf
	ld	hl,#8
	add	hl,sp
	ld	sp,hl
;fdisk.c:419: if ( hdRead(hdbuf, 0, 1) ) {
	ld	hl,#0x0001
	push	hl
	ld	l, #0x00
	push	hl
	ld	hl,#_hdbuf
	push	hl
	call	_hdRead
	pop	af
	pop	af
	pop	af
	ld	a,h
	or	a,l
	jr	Z,00102$
;fdisk.c:420: printf("Error reading table!\n");
	ld	hl,#___str_37
	push	hl
	call	_cpm_printf
	pop	af
;fdisk.c:421: doExit();
	call	_doExit
00102$:
;fdisk.c:423: buf2Tab();
	call	_buf2Tab
	ld	sp, ix
	pop	ix
	ret
___str_33:
	.ascii "Disk is %d cylinders, %d heads, %d sectors."
	.db 0x0a
	.db 0x00
___str_34:
	.ascii "Disk size is %ld sectors."
	.db 0x0a
	.db 0x00
___str_35:
	.ascii "Cylinder size is %ld bytes."
	.db 0x0a
	.db 0x00
___str_36:
	.ascii "CP/M LBA addressing: %ld tracks, %d sectors (1 track reserve"
	.ascii "d)"
	.db 0x0a
	.db 0x00
___str_37:
	.ascii "Error reading table!"
	.db 0x0a
	.db 0x00
;fdisk.c:427: void displayTable()
;	---------------------------------
; Function displayTable
; ---------------------------------
_displayTable::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl,#-18
	add	hl,sp
	ld	sp,hl
;fdisk.c:433: printf("Current disk partition table: ");
	ld	hl,#___str_38
	push	hl
	call	_cpm_printf
	pop	af
;fdisk.c:434: if (cview)
	ld	a,(#_cview + 0)
	or	a, a
	jr	Z,00102$
;fdisk.c:435: printf("[short] ");
	ld	hl,#___str_39
	push	hl
	call	_cpm_printf
	pop	af
00102$:
;fdisk.c:436: if (modified)
	ld	a,(#_modified + 0)
	or	a, a
	jr	Z,00104$
;fdisk.c:437: printf("(unsaved)\n");
	ld	hl,#___str_40
	push	hl
	call	_cpm_printf
	pop	af
	jr	00105$
00104$:
;fdisk.c:439: printf("\n");
	ld	hl,#___str_41
	push	hl
	call	_cpm_printf
	pop	af
00105$:
;fdisk.c:441: printf("No A L Type Start End   Size\n");
	ld	hl,#___str_42
	push	hl
	call	_cpm_printf
;fdisk.c:442: printf("-- - - ---- ----- ----- --------\n");
	ld	hl, #___str_43
	ex	(sp),hl
	call	_cpm_printf
	pop	af
;fdisk.c:445: if (cview)
	ld	a,(#_cview + 0)
	or	a, a
	jr	Z,00107$
;fdisk.c:446: nentry = 8;
	ld	-14 (ix),#0x08
	ld	-13 (ix),#0x00
	jr	00108$
00107$:
;fdisk.c:448: nentry = MAX_PARTITIONS;
	ld	-14 (ix),#0x10
	ld	-13 (ix),#0x00
00108$:
;fdisk.c:450: for (i = 0; i < nentry; i++) {
	ld	de,#0x0000
00113$:
	ld	a,e
	sub	a, -14 (ix)
	ld	a,d
	sbc	a, -13 (ix)
	jp	PO, 00141$
	xor	a, #0x80
00141$:
	jp	P,00111$
;fdisk.c:452: unsigned long psiz = (((unsigned long)partition.table[i].endcyl - (unsigned long)partition.table[i].startcyl)
	ld	l, e
	ld	h, d
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	a,#<((_partition + 0x0008))
	add	a, l
	ld	-2 (ix),a
	ld	a,#>((_partition + 0x0008))
	adc	a, h
	ld	-1 (ix),a
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	ld	bc, #0x0005
	add	hl, bc
	ld	a,(hl)
	ld	-4 (ix),a
	inc	hl
	ld	a,(hl)
	ld	-3 (ix),a
	ld	a,-4 (ix)
	ld	-8 (ix),a
	ld	a,-3 (ix)
	ld	-7 (ix),a
	ld	-6 (ix),#0x00
	ld	-5 (ix),#0x00
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	inc	hl
	inc	hl
	inc	hl
	ld	a,(hl)
	ld	-10 (ix),a
	inc	hl
	ld	a,(hl)
	ld	-9 (ix),a
	ld	c,-10 (ix)
	ld	b,-9 (ix)
	ld	hl,#0x0000
	ld	a,-8 (ix)
	sub	a, c
	ld	-8 (ix),a
	ld	a,-7 (ix)
	sbc	a, b
	ld	-7 (ix),a
	ld	a,-6 (ix)
	sbc	a, l
	ld	-6 (ix),a
	ld	a,-5 (ix)
	sbc	a, h
	ld	-5 (ix),a
	push	de
	ld	hl,(_cylsize + 2)
	push	hl
	ld	hl,(_cylsize)
	push	hl
	ld	l,-6 (ix)
	ld	h,-5 (ix)
	push	hl
	ld	l,-8 (ix)
	ld	h,-7 (ix)
	push	hl
	call	__mullong
	pop	af
	pop	af
	pop	af
	pop	af
	ld	c,e
	ld	b,d
	pop	de
	push	af
	ld	-18 (ix),l
	ld	-17 (ix),h
	ld	-16 (ix),c
	ld	-15 (ix),b
	pop	af
	ld	a,#0x0a
00142$:
	srl	-15 (ix)
	rr	-16 (ix)
	rr	-17 (ix)
	rr	-18 (ix)
	dec	a
	jr	NZ,00142$
;fdisk.c:454: msr = "Kb";
	ld	iy,#___str_44
;fdisk.c:456: if (psiz > 10240) {
	xor	a, a
	cp	a, -18 (ix)
	ld	a,#0x28
	sbc	a, -17 (ix)
	ld	a,#0x00
	sbc	a, -16 (ix)
	ld	a,#0x00
	sbc	a, -15 (ix)
	jr	NC,00110$
;fdisk.c:457: psiz /= 1024;
	push	af
	pop	af
	ld	b,#0x0a
00144$:
	srl	-15 (ix)
	rr	-16 (ix)
	rr	-17 (ix)
	rr	-18 (ix)
	djnz	00144$
;fdisk.c:458: msr = "Mb";
	ld	iy,#___str_45
00110$:
;fdisk.c:466: partition.table[i].ptype,
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	inc	hl
	inc	hl
	ld	c,(hl)
	ld	-8 (ix),c
	ld	-7 (ix),#0x00
;fdisk.c:465: partition.table[i].letter,
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	inc	hl
	ld	c,(hl)
	ld	-12 (ix),c
	ld	-11 (ix),#0x00
;fdisk.c:464: partition.table[i].active,
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	ld	c,(hl)
	ld	b,#0x00
;fdisk.c:463: i+1,
	inc	de
;fdisk.c:462: printf("%02d %c %c %c    %05d %05d %ld%s\n",
	push	de
	push	iy
	ld	l,-16 (ix)
	ld	h,-15 (ix)
	push	hl
	ld	l,-18 (ix)
	ld	h,-17 (ix)
	push	hl
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	push	hl
	ld	l,-10 (ix)
	ld	h,-9 (ix)
	push	hl
	ld	l,-8 (ix)
	ld	h,-7 (ix)
	push	hl
	ld	l,-12 (ix)
	ld	h,-11 (ix)
	push	hl
	push	bc
	push	de
	ld	hl,#___str_46
	push	hl
	call	_cpm_printf
	ld	hl,#20
	add	hl,sp
	ld	sp,hl
	pop	de
;fdisk.c:450: for (i = 0; i < nentry; i++) {
	jp	00113$
00111$:
;fdisk.c:474: return;
	ld	sp, ix
	pop	ix
	ret
___str_38:
	.ascii "Current disk partition table: "
	.db 0x00
___str_39:
	.ascii "[short] "
	.db 0x00
___str_40:
	.ascii "(unsaved)"
	.db 0x0a
	.db 0x00
___str_41:
	.db 0x0a
	.db 0x00
___str_42:
	.ascii "No A L Type Start End   Size"
	.db 0x0a
	.db 0x00
___str_43:
	.ascii "-- - - ---- ----- ----- --------"
	.db 0x0a
	.db 0x00
___str_44:
	.ascii "Kb"
	.db 0x00
___str_45:
	.ascii "Mb"
	.db 0x00
___str_46:
	.ascii "%02d %c %c %c    %05d %05d %ld%s"
	.db 0x0a
	.db 0x00
;fdisk.c:477: int checkAndInit()
;	---------------------------------
; Function checkAndInit
; ---------------------------------
_checkAndInit::
;fdisk.c:481: if (strncmp(partition.signature, SIGNSTRING, SIGNSIZE) == 0)
	ld	hl,#0x0008
	push	hl
	ld	hl,#___str_47
	push	hl
	ld	hl,#_partition
	push	hl
	call	_strncmp
	pop	af
	pop	af
	pop	af
	ld	c,l
	ld	a, h
	or	a,c
	jr	NZ,00102$
;fdisk.c:482: return 0;	// ok
	ld	hl,#0x0000
	ret
00102$:
;fdisk.c:485: strncpy(partition.signature, SIGNSTRING, SIGNSIZE);
	ld	de,#_partition
	ld	hl,#___str_47
	ld	bc,#0x0008
	xor	a, a
00122$:
	cp	a, (hl)
	ldi
	jp	PO, 00121$
	jr	NZ, 00122$
00123$:
	dec	hl
	ldi
	jp	PE, 00123$
00121$:
;fdisk.c:486: memset((void *) partition.table, 0, sizeof(PARTINFO) * MAX_PARTITIONS );
	ld	bc,#_partition+8
	ld	l, c
	ld	h, b
	push	bc
	ld	b, #0x80
00124$:
	ld	(hl), #0x00
	inc	hl
	djnz	00124$
	pop	bc
;fdisk.c:487: for (i = 0; i < MAX_PARTITIONS; i++) {
	ld	de,#0x0000
00104$:
;fdisk.c:488: partition.table[i].active = 'N';
	ld	l, e
	ld	h, d
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl,bc
	ld	(hl),#0x4e
;fdisk.c:489: partition.table[i].letter = ' ';
	push	hl
	pop	iy
	inc	iy
	ld	0 (iy), #0x20
;fdisk.c:490: partition.table[i].ptype = 'X';
	inc	hl
	inc	hl
	ld	(hl),#0x58
;fdisk.c:487: for (i = 0; i < MAX_PARTITIONS; i++) {
	inc	de
	ld	a,e
	sub	a, #0x10
	ld	a,d
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	C,00104$
;fdisk.c:494: modified = 1;		// update upon user action
	ld	hl,#_modified + 0
	ld	(hl), #0x01
;fdisk.c:496: return 1;
	ld	hl,#0x0001
	ret
___str_47:
	.ascii "AUAUUAUA"
	.db 0x00
;fdisk.c:513: void tab2Buf()
;	---------------------------------
; Function tab2Buf
; ---------------------------------
_tab2Buf::
;fdisk.c:516: memset((void *) hdbuf, 0, 512 );
	ld	de,#_hdbuf+0
	ld	l, e
	ld	h, d
	push	de
	ld	(hl), #0x00
	ld	e, l
	ld	d, h
	inc	de
	ld	bc, #0x01ff
	ldir
	pop	de
;fdisk.c:517: memcpy( (void *)hdbuf, (void *)partition, sizeof(PARTTABLE) );
	ld	hl,#_partition+0
	ld	bc,#0x0088
	ldir
	ret
;fdisk.c:520: void buf2Tab()
;	---------------------------------
; Function buf2Tab
; ---------------------------------
_buf2Tab::
;fdisk.c:522: memcpy( (void *)partition, (void *)hdbuf, sizeof(PARTTABLE) );
	ld	de,#_partition+0
	ld	hl,#_hdbuf+0
	ld	bc,#0x0088
	ldir
	ret
;fdisk.c:526: void writeTable()
;	---------------------------------
; Function writeTable
; ---------------------------------
_writeTable::
;fdisk.c:528: tab2Buf();
	call	_tab2Buf
;fdisk.c:529: if ( hdWrite(hdbuf, 0, 1) ) {
	ld	hl,#0x0001
	push	hl
	ld	l, #0x00
	push	hl
	ld	hl,#_hdbuf
	push	hl
	call	_hdWrite
	pop	af
	pop	af
	pop	af
	ld	a,h
	or	a,l
	ret	Z
;fdisk.c:530: printf("Error writing table!\n");
	ld	hl,#___str_48
	push	hl
	call	_cpm_printf
	pop	af
;fdisk.c:531: doExit();
	jp  _doExit
___str_48:
	.ascii "Error writing table!"
	.db 0x0a
	.db 0x00
;fdisk.c:537: void uprompt(const char * msg, unsigned int * n)
;	---------------------------------
; Function uprompt
; ---------------------------------
_uprompt::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
;fdisk.c:539: printf("%s (%d) : ", msg, *n);
	ld	a,6 (ix)
	ld	-2 (ix),a
	ld	a,7 (ix)
	ld	-1 (ix),a
	pop	hl
	push	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	push	bc
	ld	l,4 (ix)
	ld	h,5 (ix)
	push	hl
	ld	hl,#___str_49
	push	hl
	call	_cpm_printf
	ld	hl,#6
	add	hl,sp
	ld	sp,hl
;fdisk.c:540: gets(ubuf);
	ld	bc,#_ubuf+0
	ld	e, c
	ld	d, b
	push	bc
	push	de
	call	_gets
	pop	af
	pop	bc
;fdisk.c:542: if (strlen(ubuf) == 0)
	ld	e, c
	ld	d, b
	push	bc
	push	de
	call	_strlen
	pop	af
	pop	bc
	ld	a,h
	or	a,l
;fdisk.c:543: return;
	jr	Z,00103$
;fdisk.c:545: modified = 1;
	ld	hl,#_modified + 0
	ld	(hl), #0x01
;fdisk.c:546: *n = atoi(ubuf);
	push	bc
	call	_atoi
	pop	af
	ld	c,l
	ld	b,h
	pop	hl
	push	hl
	ld	(hl),c
	inc	hl
	ld	(hl),b
;fdisk.c:547: return;
00103$:
	ld	sp, ix
	pop	ix
	ret
___str_49:
	.ascii "%s (%d) : "
	.db 0x00
;fdisk.c:550: void upromptc(const char * msg, char * c, const char * validate)
;	---------------------------------
; Function upromptc
; ---------------------------------
_upromptc::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	af
	dec	sp
;fdisk.c:553: unsigned char inloop = true;
	ld	-2 (ix),#0x01
;fdisk.c:556: vlen = strlen(validate);
	ld	l,8 (ix)
	ld	h,9 (ix)
	push	hl
	call	_strlen
	pop	af
	inc	sp
	inc	sp
	push	hl
;fdisk.c:558: do {
	ld	c,6 (ix)
	ld	b,7 (ix)
00106$:
;fdisk.c:559: printf("%s (%c) : ", msg, *c);
	ld	a,(bc)
	ld	e,a
	ld	d,#0x00
	push	bc
	push	de
	ld	l,4 (ix)
	ld	h,5 (ix)
	push	hl
	ld	hl,#___str_50
	push	hl
	call	_cpm_printf
	ld	hl,#6
	add	hl,sp
	ld	sp,hl
	call	_getch
	ld	d,l
	push	de
	push	de
	inc	sp
	call	_putch
	inc	sp
	pop	de
	pop	bc
;fdisk.c:563: if (usrch == 0x0d) {
	ld	a,d
	sub	a, #0x0d
	jr	NZ,00102$
;fdisk.c:564: putch('\n');
	ld	a,#0x0a
	push	af
	inc	sp
	call	_putch
	inc	sp
;fdisk.c:565: return;
	jr	00112$
00102$:
;fdisk.c:567: usrch = toupper(usrch);
	ld	e,d
	ld	d,#0x00
	push	bc
	push	de
	call	_toupper
	pop	af
	pop	bc
	ld	-3 (ix),l
;fdisk.c:569: for (i = 0; i < vlen; i++)
	ld	de,#0x0000
00110$:
	ld	a,e
	sub	a, -5 (ix)
	ld	a,d
	sbc	a, -4 (ix)
	jp	PO, 00141$
	xor	a, #0x80
00141$:
	jp	P,00105$
;fdisk.c:570: if (usrch == validate[i])
	ld	l,8 (ix)
	ld	h,9 (ix)
	add	hl,de
	ld	a,(hl)
	ld	-1 (ix),a
	ld	a,-3 (ix)
	sub	a, -1 (ix)
	jr	NZ,00111$
;fdisk.c:571: inloop = false;
	ld	-2 (ix),#0x00
00111$:
;fdisk.c:569: for (i = 0; i < vlen; i++)
	inc	de
	jr	00110$
00105$:
;fdisk.c:573: putch('\n');
	push	bc
	ld	a,#0x0a
	push	af
	inc	sp
	call	_putch
	inc	sp
	pop	bc
;fdisk.c:575: } while (inloop);
	ld	a,-2 (ix)
	or	a, a
	jp	NZ,00106$
;fdisk.c:577: modified = 1;
	ld	hl,#_modified + 0
	ld	(hl), #0x01
;fdisk.c:578: *c = usrch;
	ld	a,-3 (ix)
	ld	(bc),a
;fdisk.c:579: return;
00112$:
	ld	sp, ix
	pop	ix
	ret
___str_50:
	.ascii "%s (%c) : "
	.db 0x00
;fdisk.c:582: void doHelp()
;	---------------------------------
; Function doHelp
; ---------------------------------
_doHelp::
;fdisk.c:584: printf("Command list:\n");
	ld	hl,#___str_51
	push	hl
	call	_cpm_printf
;fdisk.c:585: printf("\
	ld	hl, #___str_52
	ex	(sp),hl
	call	_cpm_printf
	pop	af
	ret
___str_51:
	.ascii "Command list:"
	.db 0x0a
	.db 0x00
___str_52:
	.db 0x09
	.ascii "v - toggle cview/full view"
	.db 0x0a
	.db 0x09
	.ascii "l - show table"
	.db 0x0a
	.db 0x09
	.ascii "f - format part"
	.ascii "ition"
	.db 0x0a
	.db 0x09
	.ascii "e - edit partition"
	.db 0x0a
	.db 0x09
	.ascii "c - clear partition"
	.db 0x0a
	.db 0x09
	.ascii "s - save cha"
	.ascii "nges"
	.db 0x0a
	.db 0x09
	.ascii "r - re-read table"
	.db 0x0a
	.db 0x09
	.ascii "x - exit"
	.db 0x0a
	.db 0x09
	.db 0x00
;fdisk.c:597: char * gets (register char *s)
;	---------------------------------
; Function gets
; ---------------------------------
_gets::
	dec	sp
;fdisk.c:600: unsigned int count = 0;
	ld	bc,#0x0000
;fdisk.c:602: while (1)
00109$:
;fdisk.c:604: c = getch ();
	push	bc
	call	_getch
	pop	bc
	ld	iy,#0
	add	iy,sp
	ld	0 (iy),l
;fdisk.c:605: switch(c)
	ld	a,0 (iy)
	sub	a, #0x08
	jr	Z,00101$
;fdisk.c:622: *s = 0;
	ld	hl, #3
	add	hl, sp
	ld	d, (hl)
	inc	hl
	ld	e, (hl)
;fdisk.c:605: switch(c)
	ld	iy,#0
	add	iy,sp
	ld	a,0 (iy)
	sub	a, #0x0a
	jr	Z,00105$
	ld	a,0 (iy)
	sub	a, #0x0d
	jr	Z,00105$
	jr	00106$
;fdisk.c:607: case '\b': /* backspace */
00101$:
;fdisk.c:608: if (count)
	ld	a,b
	or	a,c
	jr	Z,00109$
;fdisk.c:610: putch ('\b');
	push	bc
	ld	a,#0x08
	push	af
	inc	sp
	call	_putch
	inc	sp
	ld	a,#0x20
	push	af
	inc	sp
	call	_putch
	inc	sp
	ld	a,#0x08
	push	af
	inc	sp
	call	_putch
	inc	sp
	pop	bc
;fdisk.c:613: --s;
	ld	iy,#3
	add	iy,sp
	ld	l,0 (iy)
	ld	h,1 (iy)
	dec	hl
	ld	0 (iy),l
	ld	1 (iy),h
;fdisk.c:614: --count;
	dec	bc
;fdisk.c:616: break;
	jr	00109$
;fdisk.c:619: case '\r': /* CR or LF */
00105$:
;fdisk.c:621: putch ('\n');
	push	de
	ld	a,#0x0a
	push	af
	inc	sp
	call	_putch
	inc	sp
	pop	de
;fdisk.c:622: *s = 0;
	ld	l, d
	ld	h, e
	ld	(hl),#0x00
;fdisk.c:623: return s;
	ld	l, d
	ld	h, e
	jr	00111$
;fdisk.c:625: default:
00106$:
;fdisk.c:626: *s++ = c;
	ld	l, d
	ld	h, e
	ld	iy,#0
	add	iy,sp
	ld	a,0 (iy)
	ld	(hl),a
	ld	a,d
	ld	hl,#3
	add	hl,sp
	add	a, #0x01
	ld	(hl),a
	ld	a,e
	adc	a, #0x00
	inc	hl
	ld	(hl),a
;fdisk.c:627: ++count;
	inc	bc
;fdisk.c:628: putch (c);
	push	bc
	ld	a,0 (iy)
	push	af
	inc	sp
	call	_putch
	inc	sp
	pop	bc
;fdisk.c:630: }
	jp	00109$
00111$:
	inc	sp
	ret
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
