pcode dump


	New pBlock

internal pblock, dbName =M
;; Starting pCode block
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2340:genFunction *{*
;; ***	genFunction  2342 curr label offset=110previous max_key=1 
_main	;Function start
; 2 exit points
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6910:genAssign *{*
;; ***	genAssign  6911
;; ***	aopForSym 315
;;	327 sym->rname = _ps2Default, size = 1
;;	694 register type nRegs=1
;; 	line = 6920 result AOP_REG=r0x1059, size=1, left -=-, size=0, right AOP_DIR=_ps2Default, size=1
;; ***	genAssign  6990
;; WARNING	genAssign  6999 ignoring register storage
;; ***	genAssign  7006
;;; gen.c:1343:mov2w_op *{*
;; ***	mov2w  1381  offset=0
;; >>> gen.c:1386:mov2w
;;	1009
;;	1028  _ps2Default   offset=0
	.line	269; "main.c"	unsigned char ps2Config = ps2Default;
	MOVF	_ps2Default,W
;; >>> gen.c:7033:genAssign
;;	1109 rIdx = r0x1059 
	MOVWF	r0x100E
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6910:genAssign *{*
;; ***	genAssign  6911
;; ***	aopForSym 315
;;	327 sym->rname = _CMCON, size = 1
;; 	line = 6920 result AOP_DIR=_CMCON, size=1, left -=-, size=0, right AOP_LIT=0x07, size=1
;; ***	genAssign  7006
;; >>> gen.c:7013:genAssign
	.line	271; "main.c"	CMCON = 0b00000111;			// ADC disabled
	MOVLW	0x07
;; >>> gen.c:7015:genAssign
;;	1009
;;	1028  _CMCON   offset=0
	MOVWF	_CMCON
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6669:genPointerSet *{*
;; ***	genPointerSet  6670
;;; gen.c:6488:genNearPointerSet *{*
;; ***	genNearPointerSet  6489
;;	613
;;	aopForRemat 392
;;	418: rname _PORTAbits, val 0, const = 0
;; ***	genNearPointerSet  6504
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_PORTAbits
;; 	line = 6506 result AOP_PCODE=_PORTAbits, size=2, left -=-, size=0, right AOP_LIT=0x01, size=1
;;; gen.c:6232:genPackBits *{*
;; ***	genPackBits  6233
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_PORTAbits
;; >>> gen.c:6258:genPackBits
	.line	272; "main.c"	z80Break = 1; TRISA2 = 0;
	BSF	_PORTAbits,2
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6669:genPointerSet *{*
;; ***	genPointerSet  6670
;;; gen.c:6488:genNearPointerSet *{*
;; ***	genNearPointerSet  6489
;;	613
;;	aopForRemat 392
;;	418: rname _TRISAbits, val 0, const = 0
;; ***	genNearPointerSet  6504
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_TRISAbits
;; 	line = 6506 result AOP_PCODE=_TRISAbits, size=2, left -=-, size=0, right AOP_LIT=0x00, size=1
;;; gen.c:6232:genPackBits *{*
;; ***	genPackBits  6233
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_TRISAbits
;; >>> gen.c:6258:genPackBits
	BCF	_TRISAbits,2
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6910:genAssign *{*
;; ***	genAssign  6911
;; ***	aopForSym 315
;;	327 sym->rname = _PORTB, size = 1
;; 	line = 6920 result AOP_DIR=_PORTB, size=1, left -=-, size=0, right AOP_LIT=0xff, size=1
;; ***	genAssign  7006
;; >>> gen.c:7013:genAssign
	.line	273; "main.c"	lxData = 0b11111111; TRISB = 0b00000000;
	MOVLW	0xff
;; >>> gen.c:7015:genAssign
;;	1009
;;	1028  _PORTB   offset=0
	MOVWF	_PORTB
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6910:genAssign *{*
;; ***	genAssign  6911
;; ***	aopForSym 315
;;	327 sym->rname = _TRISB, size = 1
;; 	line = 6920 result AOP_DIR=_TRISB, size=1, left -=-, size=0, right AOP_LIT=0x00, size=1
;; ***	genAssign  7006
;; >>> gen.c:7018:genAssign
;;	1009
;;	1028  _TRISB   offset=0
	CLRF	_TRISB
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6742:genIfx *{*
;; ***	genIfx  6743
;; ***	aopForSym 315
;;	327 sym->rname = _scanCode, size = 1
;; ***	pic14_toBoolean  1515
;; >>> gen.c:1522:pic14_toBoolean
_00216_DS_
	.line	276; "main.c"	while(!scanCode)
	MOVLW	0x00
;; >>> gen.c:1533:pic14_toBoolean
;;	1009
;;	1028  _scanCode   offset=0
	IORWF	_scanCode,W
;; >>> gen.c:6791:genIfx
	BTFSS	STATUS,2
;; >>> gen.c:6792:genIfx
;; ***	popGetLabel  key=3, label offset 115
	GOTO	_00218_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2086:genCall *{*
;; ***	genCall  2088
;;; gen.c:1801:saveRegisters *{*
;; ***	saveRegisters  1803
;; >>> gen.c:2175:genCall
	.line	277; "main.c"	readScanCode();
	CALL	_readScanCode
;;; gen.c:1845:unsaveRegisters *{*
;; ***	unsaveRegisters  1847
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2778:genGoto *{*
;; >>> gen.c:2780:genGoto
;; ***	popGetLabel  key=1, label offset 115
	GOTO	_00216_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2086:genCall *{*
;; ***	genCall  2088
;;; gen.c:1801:saveRegisters *{*
;; ***	saveRegisters  1803
;; 	2135 left AOP_LIT
;;; gen.c:1343:mov2w_op *{*
;; >>> gen.c:1361:mov2w_op
_00218_DS_
	.line	280; "main.c"	setPanel(0b00000010);
	MOVLW	0x02
;; >>> gen.c:2175:genCall
	CALL	_setPanel
;;; gen.c:1845:unsaveRegisters *{*
;; ***	unsaveRegisters  1847
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2086:genCall *{*
;; ***	genCall  2088
;;; gen.c:1801:saveRegisters *{*
;; ***	saveRegisters  1803
;; >>> gen.c:2175:genCall
_00219_DS_
	.line	287; "main.c"	readScanCode();
	CALL	_readScanCode
;;; gen.c:1845:unsaveRegisters *{*
;; ***	unsaveRegisters  1847
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6742:genIfx *{*
;; ***	genIfx  6743
;; ***	aopForSym 315
;;	327 sym->rname = _scanCode, size = 1
;; ***	pic14_toBoolean  1515
;; >>> gen.c:1522:pic14_toBoolean
	.line	288; "main.c"	} while (!scanCode);
	MOVLW	0x00
;; >>> gen.c:1533:pic14_toBoolean
;;	1009
;;	1028  _scanCode   offset=0
	IORWF	_scanCode,W
;; >>> gen.c:6796:genIfx
	BTFSC	STATUS,2
;; >>> gen.c:6797:genIfx
;; ***	popGetLabel  key=4, label offset 115
	GOTO	_00219_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6669:genPointerSet *{*
;; ***	genPointerSet  6670
;;; gen.c:6488:genNearPointerSet *{*
;; ***	genNearPointerSet  6489
;;	613
;;	aopForRemat 392
;;	418: rname _PORTBbits, val 0, const = 0
;; ***	genNearPointerSet  6504
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_PORTBbits
;; 	line = 6506 result AOP_PCODE=_PORTBbits, size=2, left -=-, size=0, right AOP_LIT=0x01, size=1
;;; gen.c:6232:genPackBits *{*
;; ***	genPackBits  6233
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_PORTBbits
;; >>> gen.c:6258:genPackBits
	.line	290; "main.c"	lxStrobe = 1;
	BSF	_PORTBbits,7
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6910:genAssign *{*
;; ***	genAssign  6911
;;	694 register type nRegs=1
;; 	line = 6920 result AOP_REG=r0x105A, size=1, left -=-, size=0, right AOP_LIT=0x00, size=1
;; ***	genAssign  7006
;; >>> gen.c:7018:genAssign
;;	1109 rIdx = r0x105A 
	.line	291; "main.c"	ascii = 0;
	CLRF	r0x100F
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6742:genIfx *{*
;; ***	genIfx  6743
;; ***	aopForSym 315
;;	327 sym->rname = _extendedKey, size = 1
;; ***	pic14_toBoolean  1515
;; >>> gen.c:1522:pic14_toBoolean
	.line	293; "main.c"	if(extendedKey)
	MOVLW	0x00
;; >>> gen.c:1533:pic14_toBoolean
;;	1009
;;	1028  _extendedKey   offset=0
	IORWF	_extendedKey,W
;; >>> gen.c:6796:genIfx
	BTFSC	STATUS,2
;; >>> gen.c:6797:genIfx
;; ***	popGetLabel  key=47, label offset 115
	GOTO	_00262_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:3619:genCmpEq *{*
;; ***	genCmpEq  3620
;; ifx is non-null
;; ***	aopForSym 315
;;	327 sym->rname = _scanCode, size = 1
;; 	line = 3631 result AOP_CRY=0x00, size=0, left AOP_DIR=_scanCode, size=1, right AOP_LIT=0x11, size=1
;; ***	mov2w  1381  offset=0
;; >>> gen.c:1386:mov2w
;;	1009
;;	1028  _scanCode   offset=0
	.line	294; "main.c"	switch(scanCode)
	MOVF	_scanCode,W
;; >>> gen.c:3685:genCmpEq
	XORLW	0x11
	BTFSC	STATUS,2
	GOTO	_00222_DS_
	MOVF	_scanCode,W
	XORLW	0x14
	BTFSC	STATUS,2
	GOTO	_00223_DS_
	MOVF	_scanCode,W
	XORLW	0x4a
	BTFSC	STATUS,2
	GOTO	_00224_DS_
	MOVF	_scanCode,W
	XORLW	0x5a
	BTFSC	STATUS,2
	GOTO	_00227_DS_
	MOVF	_scanCode,W
	XORLW	0x71
	BTFSC	STATUS,2
	GOTO	_00230_DS_
	GOTO	_00263_DS_
_00222_DS_
	.line	297; "main.c"	altGr = !keyUp;
	MOVF	_keyUp,W
;; >>> gen.c:1582:genNot
	MOVLW	0x00
;; >>> gen.c:1583:genNot
	BTFSC	STATUS,2
;; >>> gen.c:1584:genNot
	MOVLW	0x01
;; >>> gen.c:1393:movwf
;;	1009
;;	1028  _altGr   offset=0
	MOVWF	_altGr
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2778:genGoto *{*
;; >>> gen.c:2780:genGoto
;; ***	popGetLabel  key=48, label offset 115
	.line	298; "main.c"	break;
	GOTO	_00263_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:1548:genNot *{*
;; ***	genNot  1550
;; ***	aopForSym 315
;;	327 sym->rname = _keyUp, size = 1
;; ***	aopForSym 315
;;	327 sym->rname = _ctrl, size = 1
;; 	line = 1555 result AOP_DIR=_ctrl, size=1, left AOP_DIR=_keyUp, size=1, right -=-, size=0
;; ***	mov2w  1381  offset=0
;; >>> gen.c:1386:mov2w
;;	1009
;;	1028  _keyUp   offset=0
_00223_DS_
	.line	301; "main.c"	ctrl = !keyUp;
	MOVF	_keyUp,W
;; >>> gen.c:1582:genNot
	MOVLW	0x00
;; >>> gen.c:1583:genNot
	BTFSC	STATUS,2
;; >>> gen.c:1584:genNot
	MOVLW	0x01
;; >>> gen.c:1393:movwf
;;	1009
;;	1028  _ctrl   offset=0
	MOVWF	_ctrl
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2778:genGoto *{*
;; >>> gen.c:2780:genGoto
;; ***	popGetLabel  key=48, label offset 115
	.line	302; "main.c"	break;
	GOTO	_00263_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6742:genIfx *{*
;; ***	genIfx  6743
;; ***	aopForSym 315
;;	327 sym->rname = _keyUp, size = 1
;; ***	pic14_toBoolean  1515
;; >>> gen.c:1522:pic14_toBoolean
_00224_DS_
	.line	305; "main.c"	if(!keyUp)
	MOVLW	0x00
;; >>> gen.c:1533:pic14_toBoolean
;;	1009
;;	1028  _keyUp   offset=0
	IORWF	_keyUp,W
;; >>> gen.c:6791:genIfx
	BTFSS	STATUS,2
;; >>> gen.c:6792:genIfx
;; ***	popGetLabel  key=48, label offset 115
	GOTO	_00263_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6910:genAssign *{*
;; ***	genAssign  6911
;;	694 register type nRegs=1
;; 	line = 6920 result AOP_REG=r0x105A, size=1, left -=-, size=0, right AOP_LIT=0x2f, size=1
;; ***	genAssign  7006
;; >>> gen.c:7013:genAssign
	.line	306; "main.c"	ascii = '/';
	MOVLW	0x2f
;; >>> gen.c:7015:genAssign
;;	1109 rIdx = r0x105A 
	MOVWF	r0x100F
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2778:genGoto *{*
;; >>> gen.c:2780:genGoto
;; ***	popGetLabel  key=48, label offset 115
	.line	307; "main.c"	break;
	GOTO	_00263_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6742:genIfx *{*
;; ***	genIfx  6743
;; ***	aopForSym 315
;;	327 sym->rname = _keyUp, size = 1
;; ***	pic14_toBoolean  1515
;; >>> gen.c:1522:pic14_toBoolean
_00227_DS_
	.line	310; "main.c"	if(!keyUp)
	MOVLW	0x00
;; >>> gen.c:1533:pic14_toBoolean
;;	1009
;;	1028  _keyUp   offset=0
	IORWF	_keyUp,W
;; >>> gen.c:6791:genIfx
	BTFSS	STATUS,2
;; >>> gen.c:6792:genIfx
;; ***	popGetLabel  key=48, label offset 115
	GOTO	_00263_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6910:genAssign *{*
;; ***	genAssign  6911
;;	694 register type nRegs=1
;; 	line = 6920 result AOP_REG=r0x105A, size=1, left -=-, size=0, right AOP_LIT=0x0d, size=1
;; ***	genAssign  7006
;; >>> gen.c:7013:genAssign
	.line	311; "main.c"	ascii = 0x0D;
	MOVLW	0x0d
;; >>> gen.c:7015:genAssign
;;	1109 rIdx = r0x105A 
	MOVWF	r0x100F
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2778:genGoto *{*
;; >>> gen.c:2780:genGoto
;; ***	popGetLabel  key=48, label offset 115
	.line	312; "main.c"	break;
	GOTO	_00263_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6742:genIfx *{*
;; ***	genIfx  6743
;; ***	aopForSym 315
;;	327 sym->rname = _keyUp, size = 1
;; ***	pic14_toBoolean  1515
;; >>> gen.c:1522:pic14_toBoolean
_00230_DS_
	.line	315; "main.c"	if(!keyUp)
	MOVLW	0x00
;; >>> gen.c:1533:pic14_toBoolean
;;	1009
;;	1028  _keyUp   offset=0
	IORWF	_keyUp,W
;; >>> gen.c:6791:genIfx
	BTFSS	STATUS,2
;; >>> gen.c:6792:genIfx
;; ***	popGetLabel  key=48, label offset 115
	GOTO	_00263_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6910:genAssign *{*
;; ***	genAssign  6911
;;	694 register type nRegs=1
;; 	line = 6920 result AOP_REG=r0x105A, size=1, left -=-, size=0, right AOP_LIT=0x7f, size=1
;; ***	genAssign  7006
;; >>> gen.c:7013:genAssign
	.line	316; "main.c"	ascii = 0x7F;
	MOVLW	0x7f
;; >>> gen.c:7015:genAssign
;;	1109 rIdx = r0x105A 
	MOVWF	r0x100F
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2778:genGoto *{*
;; >>> gen.c:2780:genGoto
;; ***	popGetLabel  key=48, label offset 115
	.line	318; "main.c"	}
	GOTO	_00263_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:3619:genCmpEq *{*
;; ***	genCmpEq  3620
;; ifx is non-null
;; ***	aopForSym 315
;;	327 sym->rname = _scanCode, size = 1
;; 	line = 3631 result AOP_CRY=0x00, size=0, left AOP_DIR=_scanCode, size=1, right AOP_LIT=0x05, size=1
;; ***	mov2w  1381  offset=0
;; >>> gen.c:1386:mov2w
;;	1009
;;	1028  _scanCode   offset=0
_00262_DS_
	.line	320; "main.c"	switch(scanCode)
	MOVF	_scanCode,W
;; >>> gen.c:3685:genCmpEq
	XORLW	0x05
	BTFSC	STATUS,2
	GOTO	_00234_DS_
	MOVF	_scanCode,W
	XORLW	0x09
	BTFSC	STATUS,2
	GOTO	_00237_DS_
	MOVF	_scanCode,W
	XORLW	0x11
	BTFSC	STATUS,2
	GOTO	_00240_DS_
	MOVF	_scanCode,W
	XORLW	0x12
	BTFSC	STATUS,2
	GOTO	_00242_DS_
	MOVF	_scanCode,W
	XORLW	0x14
	BTFSC	STATUS,2
	GOTO	_00243_DS_
	MOVF	_scanCode,W
	XORLW	0x58
	BTFSC	STATUS,2
	GOTO	_00244_DS_
	MOVF	_scanCode,W
	XORLW	0x59
	BTFSC	STATUS,2
	GOTO	_00242_DS_
	GOTO	_00247_DS_
_00234_DS_
	.line	323; "main.c"	if(!keyUp & alt)
	MOVF	_keyUp,W
;; >>> gen.c:1582:genNot
	MOVLW	0x00
;; >>> gen.c:1583:genNot
	BTFSC	STATUS,2
;; >>> gen.c:1584:genNot
	MOVLW	0x01
;; >>> gen.c:1393:movwf
;;	1109 rIdx = r0x105B 
	MOVWF	r0x1010
;;; gen.c:2316:resultRemat *{*
;;; gen.c:7103:genCast *{*
;; ***	genCast  7104
;; ***	aopForSym 315
;;	327 sym->rname = _alt, size = 1
;;	694 register type nRegs=1
;; 	line = 7112 result AOP_REG=r0x105C, size=1, left -=-, size=0, right AOP_DIR=_alt, size=1
;; ***	genCast  7236
;; >>> gen.c:7260:genCast
;;	1009
;;	1028  _alt   offset=0
	MOVF	_alt,W
;; >>> gen.c:7261:genCast
;;	1109 rIdx = r0x105C 
	MOVWF	r0x1011
	ANDWF	r0x1010,F
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6742:genIfx *{*
;; ***	genIfx  6743
;;	694 register type nRegs=1
;; ***	pic14_toBoolean  1515
;; >>> gen.c:1522:pic14_toBoolean
	MOVF	r0x1010,W
	BTFSC	STATUS,2
;; >>> gen.c:6797:genIfx
;; ***	popGetLabel  key=48, label offset 115
	GOTO	_00263_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2086:genCall *{*
;; ***	genCall  2088
;;; gen.c:1801:saveRegisters *{*
;; ***	saveRegisters  1803
;; 	2135 left AOP_LIT
;;; gen.c:1343:mov2w_op *{*
;; >>> gen.c:1361:mov2w_op
	.line	326; "main.c"	setPanel(0b00000000);
	MOVLW	0x00
;; >>> gen.c:2175:genCall
	CALL	_setPanel
;;; gen.c:1845:unsaveRegisters *{*
;; ***	unsaveRegisters  1847
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2086:genCall *{*
;; ***	genCall  2088
;;; gen.c:1801:saveRegisters *{*
;; ***	saveRegisters  1803
;; 	2135 left AOP_LIT
;;; gen.c:1343:mov2w_op *{*
;; >>> gen.c:1361:mov2w_op
	.line	327; "main.c"	delay_ms(200);
	MOVLW	0xc8
;; 	2135 left AOP_LIT
;; >>> gen.c:2143:genCall
;; ***	popRegFromIdx,1042  , rIdx=0x7f
	MOVWF	STK00
;;; gen.c:1343:mov2w_op *{*
;; >>> gen.c:1361:mov2w_op
	MOVLW	0x00
;; >>> gen.c:2173:genCall
	PAGESEL	_delay_ms
;; >>> gen.c:2175:genCall
	CALL	_delay_ms
;; >>> gen.c:2181:genCall
	PAGESEL	$
;;; gen.c:1845:unsaveRegisters *{*
;; ***	unsaveRegisters  1847
;;; gen.c:2316:resultRemat *{*
;;; gen.c:4501:genXor *{*
;; ***	genXor  4502
;;	694 register type nRegs=1
;;	575
;; >>> gen.c:4643:genXor
	.line	330; "main.c"	ps2Config ^= 0b00000001;
	MOVLW	0x01
;; >>> gen.c:4644:genXor
;;	1109 rIdx = r0x1059 
	XORWF	r0x100E,F
;;; gen.c:2316:resultRemat *{*
;;; gen.c:3919:genAnd *{*
;; ***	genAnd  3920
;;	694 register type nRegs=1
;;	694 register type nRegs=1
;; 	line = 3955 result AOP_REG=r0x105B, size=1, left AOP_REG=r0x1059, size=1, right AOP_LIT=0x01, size=1
;; >>> gen.c:4190:genAnd
	.line	335; "main.c"	flashPanel(ps2Config & 0b00000001);
	MOVLW	0x01
;; >>> gen.c:4191:genAnd
;;	1109 rIdx = r0x1059 
	ANDWF	r0x100E,W
;; >>> gen.c:4192:genAnd
;;	1109 rIdx = r0x105B 
	MOVWF	r0x1010
	CALL	_flashPanel
;;; gen.c:1845:unsaveRegisters *{*
;; ***	unsaveRegisters  1847
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6742:genIfx *{*
;; ***	genIfx  6743
;; ***	aopForSym 315
;;	327 sym->rname = _shiftLock, size = 1
;; ***	pic14_toBoolean  1515
;; >>> gen.c:1522:pic14_toBoolean
	.line	338; "main.c"	setPanel(shiftLock ? 0b00000110 : 0b00000010);
	MOVLW	0x00
;; >>> gen.c:1533:pic14_toBoolean
;;	1009
;;	1028  _shiftLock   offset=0
	IORWF	_shiftLock,W
;; >>> gen.c:6796:genIfx
	BTFSC	STATUS,2
;; >>> gen.c:6797:genIfx
;; ***	popGetLabel  key=60, label offset 115
	GOTO	_00275_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6910:genAssign *{*
;; ***	genAssign  6911
;;	694 register type nRegs=1
;; 	line = 6920 result AOP_REG=r0x105B, size=1, left -=-, size=0, right AOP_LIT=0x06, size=1
;; ***	genAssign  7006
;; >>> gen.c:7013:genAssign
	MOVLW	0x06
;; >>> gen.c:7015:genAssign
;;	1109 rIdx = r0x105B 
	MOVWF	r0x1010
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2778:genGoto *{*
;; >>> gen.c:2780:genGoto
;; ***	popGetLabel  key=61, label offset 115
	GOTO	_00276_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6910:genAssign *{*
;; ***	genAssign  6911
;;	694 register type nRegs=1
;; 	line = 6920 result AOP_REG=r0x105B, size=1, left -=-, size=0, right AOP_LIT=0x02, size=1
;; ***	genAssign  7006
;; >>> gen.c:7013:genAssign
_00275_DS_
	MOVLW	0x02
;; >>> gen.c:7015:genAssign
;;	1109 rIdx = r0x105B 
	MOVWF	r0x1010
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2086:genCall *{*
;; ***	genCall  2088
;;; gen.c:1801:saveRegisters *{*
;; ***	saveRegisters  1803
;;	694 register type nRegs=1
;;	694 register type nRegs=1
;; 	2135 left AOP_REG
;;; gen.c:1343:mov2w_op *{*
;; ***	mov2w  1381  offset=0
;; >>> gen.c:1386:mov2w
;;	1109 rIdx = r0x105B 
_00276_DS_
	MOVF	r0x1010,W
;; >>> gen.c:2175:genCall
	CALL	_setPanel
;;; gen.c:1845:unsaveRegisters *{*
;; ***	unsaveRegisters  1847
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2778:genGoto *{*
;; >>> gen.c:2780:genGoto
;; ***	popGetLabel  key=48, label offset 115
	.line	340; "main.c"	break;
	GOTO	_00263_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:1548:genNot *{*
;; ***	genNot  1550
;; ***	aopForSym 315
;;	327 sym->rname = _keyUp, size = 1
;;	694 register type nRegs=1
;; 	line = 1555 result AOP_REG=r0x105B, size=1, left AOP_DIR=_keyUp, size=1, right -=-, size=0
;; ***	mov2w  1381  offset=0
;; >>> gen.c:1386:mov2w
;;	1009
;;	1028  _keyUp   offset=0
_00237_DS_
	.line	343; "main.c"	if(!keyUp & ctrl & alt)
	MOVF	_keyUp,W
;; >>> gen.c:1582:genNot
	MOVLW	0x00
;; >>> gen.c:1583:genNot
	BTFSC	STATUS,2
;; >>> gen.c:1584:genNot
	MOVLW	0x01
;; >>> gen.c:1393:movwf
;;	1109 rIdx = r0x105B 
	MOVWF	r0x1010
;;; gen.c:2316:resultRemat *{*
;;; gen.c:7103:genCast *{*
;; ***	genCast  7104
;; ***	aopForSym 315
;;	327 sym->rname = _ctrl, size = 1
;;	694 register type nRegs=1
;; 	line = 7112 result AOP_REG=r0x105C, size=1, left -=-, size=0, right AOP_DIR=_ctrl, size=1
;; ***	genCast  7236
;; >>> gen.c:7260:genCast
;;	1009
;;	1028  _ctrl   offset=0
	MOVF	_ctrl,W
;; >>> gen.c:7261:genCast
;;	1109 rIdx = r0x105C 
	MOVWF	r0x1011
	ANDWF	r0x1010,F
;;; gen.c:2316:resultRemat *{*
;;; gen.c:7103:genCast *{*
;; ***	genCast  7104
;; ***	aopForSym 315
;;	327 sym->rname = _alt, size = 1
;;	694 register type nRegs=1
;; 	line = 7112 result AOP_REG=r0x105C, size=1, left -=-, size=0, right AOP_DIR=_alt, size=1
;; ***	genCast  7236
;; >>> gen.c:7260:genCast
;;	1009
;;	1028  _alt   offset=0
	MOVF	_alt,W
;; >>> gen.c:7261:genCast
;;	1109 rIdx = r0x105C 
	MOVWF	r0x1011
	ANDWF	r0x1010,F
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6742:genIfx *{*
;; ***	genIfx  6743
;;	694 register type nRegs=1
;; ***	pic14_toBoolean  1515
;; >>> gen.c:1522:pic14_toBoolean
	MOVF	r0x1010,W
	BTFSC	STATUS,2
;; >>> gen.c:6797:genIfx
;; ***	popGetLabel  key=48, label offset 115
	GOTO	_00263_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2086:genCall *{*
;; ***	genCall  2088
;;; gen.c:1801:saveRegisters *{*
;; ***	saveRegisters  1803
;; 	2135 left AOP_LIT
;;; gen.c:1343:mov2w_op *{*
;; >>> gen.c:1361:mov2w_op
	.line	346; "main.c"	setPanel(0b00000000);
	MOVLW	0x00
;; >>> gen.c:2175:genCall
	CALL	_setPanel
;;; gen.c:1845:unsaveRegisters *{*
;; ***	unsaveRegisters  1847
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2086:genCall *{*
;; ***	genCall  2088
;;; gen.c:1801:saveRegisters *{*
;; ***	saveRegisters  1803
;; 	2135 left AOP_LIT
;;; gen.c:1343:mov2w_op *{*
;; >>> gen.c:1361:mov2w_op
	.line	347; "main.c"	delay_ms(200);
	MOVLW	0xc8
;; 	2135 left AOP_LIT
;; >>> gen.c:2143:genCall
;; ***	popRegFromIdx,1042  , rIdx=0x7f
	MOVWF	STK00
;;; gen.c:1343:mov2w_op *{*
;; >>> gen.c:1361:mov2w_op
	MOVLW	0x00
;; >>> gen.c:2173:genCall
	PAGESEL	_delay_ms
;; >>> gen.c:2175:genCall
	CALL	_delay_ms
;; >>> gen.c:2181:genCall
	PAGESEL	$
;;; gen.c:1845:unsaveRegisters *{*
;; ***	unsaveRegisters  1847
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6910:genAssign *{*
;; ***	genAssign  6911
;;	694 register type nRegs=1
;; ***	aopForSym 315
;;	327 sym->rname = _ps2Default, size = 1
;; 	line = 6920 result AOP_DIR=_ps2Default, size=1, left -=-, size=0, right AOP_REG=r0x1059, size=1
;; ***	genAssign  7006
;;; gen.c:1343:mov2w_op *{*
;; ***	mov2w  1381  offset=0
;; >>> gen.c:1386:mov2w
;;	1109 rIdx = r0x1059 
	.line	350; "main.c"	ps2Default = ps2Config;
	MOVF	r0x100E,W
;; >>> gen.c:7033:genAssign
;;	1009
;;	1028  _ps2Default   offset=0
	MOVWF	_ps2Default
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2086:genCall *{*
;; ***	genCall  2088
;;; gen.c:1801:saveRegisters *{*
;; ***	saveRegisters  1803
;; 	2135 left AOP_LIT
;;; gen.c:1343:mov2w_op *{*
;; >>> gen.c:1361:mov2w_op
	.line	353; "main.c"	flashPanel(2);
	MOVLW	0x02
;; >>> gen.c:2175:genCall
	CALL	_flashPanel
;;; gen.c:1845:unsaveRegisters *{*
;; ***	unsaveRegisters  1847
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6742:genIfx *{*
;; ***	genIfx  6743
;; ***	aopForSym 315
;;	327 sym->rname = _shiftLock, size = 1
;; ***	pic14_toBoolean  1515
;; >>> gen.c:1522:pic14_toBoolean
	.line	356; "main.c"	setPanel(shiftLock ? 0b00000110 : 0b00000010);
	MOVLW	0x00
;; >>> gen.c:1533:pic14_toBoolean
;;	1009
;;	1028  _shiftLock   offset=0
	IORWF	_shiftLock,W
;; >>> gen.c:6796:genIfx
	BTFSC	STATUS,2
;; >>> gen.c:6797:genIfx
;; ***	popGetLabel  key=62, label offset 115
	GOTO	_00277_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6910:genAssign *{*
;; ***	genAssign  6911
;;	694 register type nRegs=1
;; 	line = 6920 result AOP_REG=r0x105B, size=1, left -=-, size=0, right AOP_LIT=0x06, size=1
;; ***	genAssign  7006
;; >>> gen.c:7013:genAssign
	MOVLW	0x06
;; >>> gen.c:7015:genAssign
;;	1109 rIdx = r0x105B 
	MOVWF	r0x1010
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2778:genGoto *{*
;; >>> gen.c:2780:genGoto
;; ***	popGetLabel  key=63, label offset 115
	GOTO	_00278_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6910:genAssign *{*
;; ***	genAssign  6911
;;	694 register type nRegs=1
;; 	line = 6920 result AOP_REG=r0x105B, size=1, left -=-, size=0, right AOP_LIT=0x02, size=1
;; ***	genAssign  7006
;; >>> gen.c:7013:genAssign
_00277_DS_
	MOVLW	0x02
;; >>> gen.c:7015:genAssign
;;	1109 rIdx = r0x105B 
	MOVWF	r0x1010
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2086:genCall *{*
;; ***	genCall  2088
;;; gen.c:1801:saveRegisters *{*
;; ***	saveRegisters  1803
;;	694 register type nRegs=1
;;	694 register type nRegs=1
;; 	2135 left AOP_REG
;;; gen.c:1343:mov2w_op *{*
;; ***	mov2w  1381  offset=0
;; >>> gen.c:1386:mov2w
;;	1109 rIdx = r0x105B 
_00278_DS_
	MOVF	r0x1010,W
;; >>> gen.c:2175:genCall
	CALL	_setPanel
;;; gen.c:1845:unsaveRegisters *{*
;; ***	unsaveRegisters  1847
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2778:genGoto *{*
;; >>> gen.c:2780:genGoto
;; ***	popGetLabel  key=48, label offset 115
	.line	358; "main.c"	break;
	GOTO	_00263_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:1548:genNot *{*
;; ***	genNot  1550
;; ***	aopForSym 315
;;	327 sym->rname = _keyUp, size = 1
;; ***	aopForSym 315
;;	327 sym->rname = _alt, size = 1
;; 	line = 1555 result AOP_DIR=_alt, size=1, left AOP_DIR=_keyUp, size=1, right -=-, size=0
;; ***	mov2w  1381  offset=0
;; >>> gen.c:1386:mov2w
;;	1009
;;	1028  _keyUp   offset=0
_00240_DS_
	.line	361; "main.c"	alt = !keyUp;
	MOVF	_keyUp,W
;; >>> gen.c:1582:genNot
	MOVLW	0x00
;; >>> gen.c:1583:genNot
	BTFSC	STATUS,2
;; >>> gen.c:1584:genNot
	MOVLW	0x01
;; >>> gen.c:1393:movwf
;;	1009
;;	1028  _alt   offset=0
	MOVWF	_alt
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2778:genGoto *{*
;; >>> gen.c:2780:genGoto
;; ***	popGetLabel  key=48, label offset 115
	.line	362; "main.c"	break;
	GOTO	_00263_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:1548:genNot *{*
;; ***	genNot  1550
;; ***	aopForSym 315
;;	327 sym->rname = _keyUp, size = 1
;; ***	aopForSym 315
;;	327 sym->rname = _shift, size = 1
;; 	line = 1555 result AOP_DIR=_shift, size=1, left AOP_DIR=_keyUp, size=1, right -=-, size=0
;; ***	mov2w  1381  offset=0
;; >>> gen.c:1386:mov2w
;;	1009
;;	1028  _keyUp   offset=0
_00242_DS_
	.line	366; "main.c"	shift = !keyUp;
	MOVF	_keyUp,W
;; >>> gen.c:1582:genNot
	MOVLW	0x00
;; >>> gen.c:1583:genNot
	BTFSC	STATUS,2
;; >>> gen.c:1584:genNot
	MOVLW	0x01
;; >>> gen.c:1393:movwf
;;	1009
;;	1028  _shift   offset=0
	MOVWF	_shift
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2778:genGoto *{*
;; >>> gen.c:2780:genGoto
;; ***	popGetLabel  key=48, label offset 115
	.line	367; "main.c"	break;
	GOTO	_00263_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:1548:genNot *{*
;; ***	genNot  1550
;; ***	aopForSym 315
;;	327 sym->rname = _keyUp, size = 1
;; ***	aopForSym 315
;;	327 sym->rname = _ctrl, size = 1
;; 	line = 1555 result AOP_DIR=_ctrl, size=1, left AOP_DIR=_keyUp, size=1, right -=-, size=0
;; ***	mov2w  1381  offset=0
;; >>> gen.c:1386:mov2w
;;	1009
;;	1028  _keyUp   offset=0
_00243_DS_
	.line	370; "main.c"	ctrl = !keyUp;
	MOVF	_keyUp,W
;; >>> gen.c:1582:genNot
	MOVLW	0x00
;; >>> gen.c:1583:genNot
	BTFSC	STATUS,2
;; >>> gen.c:1584:genNot
	MOVLW	0x01
;; >>> gen.c:1393:movwf
;;	1009
;;	1028  _ctrl   offset=0
	MOVWF	_ctrl
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2778:genGoto *{*
;; >>> gen.c:2780:genGoto
;; ***	popGetLabel  key=48, label offset 115
	.line	371; "main.c"	break;
	GOTO	_00263_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6742:genIfx *{*
;; ***	genIfx  6743
;; ***	aopForSym 315
;;	327 sym->rname = _keyUp, size = 1
;; ***	pic14_toBoolean  1515
;; >>> gen.c:1522:pic14_toBoolean
_00244_DS_
	.line	374; "main.c"	if(!keyUp)
	MOVLW	0x00
;; >>> gen.c:1533:pic14_toBoolean
;;	1009
;;	1028  _keyUp   offset=0
	IORWF	_keyUp,W
;; >>> gen.c:6791:genIfx
	BTFSS	STATUS,2
;; >>> gen.c:6792:genIfx
;; ***	popGetLabel  key=48, label offset 115
	GOTO	_00263_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:1548:genNot *{*
;; ***	genNot  1550
;; ***	aopForSym 315
;;	327 sym->rname = _shiftLock, size = 1
;;	575
;; 	line = 1555 result AOP_DIR=_shiftLock, size=1, left AOP_DIR=_shiftLock, size=1, right -=-, size=0
;; ***	mov2w  1381  offset=0
;; >>> gen.c:1386:mov2w
;;	1009
;;	1028  _shiftLock   offset=0
	.line	376; "main.c"	shiftLock = !shiftLock;
	MOVF	_shiftLock,W
;; >>> gen.c:1582:genNot
	MOVLW	0x00
;; >>> gen.c:1583:genNot
	BTFSC	STATUS,2
;; >>> gen.c:1584:genNot
	MOVLW	0x01
;; >>> gen.c:1393:movwf
;;	1009
;;	1028  _shiftLock   offset=0
	MOVWF	_shiftLock
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6742:genIfx *{*
;; ***	genIfx  6743
;; ***	aopForSym 315
;;	327 sym->rname = _shiftLock, size = 1
;; ***	pic14_toBoolean  1515
;; >>> gen.c:1522:pic14_toBoolean
	.line	377; "main.c"	setPanel(shiftLock ? 0b00000110 : 0b00000010);
	MOVLW	0x00
;; >>> gen.c:1533:pic14_toBoolean
;;	1009
;;	1028  _shiftLock   offset=0
	IORWF	_shiftLock,W
;; >>> gen.c:6796:genIfx
	BTFSC	STATUS,2
;; >>> gen.c:6797:genIfx
;; ***	popGetLabel  key=64, label offset 115
	GOTO	_00279_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6910:genAssign *{*
;; ***	genAssign  6911
;;	694 register type nRegs=1
;; 	line = 6920 result AOP_REG=r0x105B, size=1, left -=-, size=0, right AOP_LIT=0x06, size=1
;; ***	genAssign  7006
;; >>> gen.c:7013:genAssign
	MOVLW	0x06
;; >>> gen.c:7015:genAssign
;;	1109 rIdx = r0x105B 
	MOVWF	r0x1010
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2778:genGoto *{*
;; >>> gen.c:2780:genGoto
;; ***	popGetLabel  key=65, label offset 115
	GOTO	_00280_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6910:genAssign *{*
;; ***	genAssign  6911
;;	694 register type nRegs=1
;; 	line = 6920 result AOP_REG=r0x105B, size=1, left -=-, size=0, right AOP_LIT=0x02, size=1
;; ***	genAssign  7006
;; >>> gen.c:7013:genAssign
_00279_DS_
	MOVLW	0x02
;; >>> gen.c:7015:genAssign
;;	1109 rIdx = r0x105B 
	MOVWF	r0x1010
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2086:genCall *{*
;; ***	genCall  2088
;;; gen.c:1801:saveRegisters *{*
;; ***	saveRegisters  1803
;;	694 register type nRegs=1
;;	694 register type nRegs=1
;; 	2135 left AOP_REG
;;; gen.c:1343:mov2w_op *{*
;; ***	mov2w  1381  offset=0
;; >>> gen.c:1386:mov2w
;;	1109 rIdx = r0x105B 
_00280_DS_
	MOVF	r0x1010,W
;; >>> gen.c:2175:genCall
	CALL	_setPanel
;;; gen.c:1845:unsaveRegisters *{*
;; ***	unsaveRegisters  1847
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2778:genGoto *{*
;; >>> gen.c:2780:genGoto
;; ***	popGetLabel  key=48, label offset 115
	.line	379; "main.c"	break;
	GOTO	_00263_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6742:genIfx *{*
;; ***	genIfx  6743
;; ***	aopForSym 315
;;	327 sym->rname = _keyUp, size = 1
;; ***	pic14_toBoolean  1515
;; >>> gen.c:1522:pic14_toBoolean
_00247_DS_
	.line	382; "main.c"	if(!keyUp && scanCode > 0x0C && scanCode < 0x7E)
	MOVLW	0x00
;; >>> gen.c:1533:pic14_toBoolean
;;	1009
;;	1028  _keyUp   offset=0
	IORWF	_keyUp,W
;; >>> gen.c:6791:genIfx
	BTFSS	STATUS,2
;; >>> gen.c:6792:genIfx
;; ***	popGetLabel  key=48, label offset 115
	GOTO	_00263_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:3547:genCmpGt *{*
;; ***	genCmpGt  3548
;; ***	aopForSym 315
;;	327 sym->rname = _scanCode, size = 1
;;; gen.c:3294:genCmp *{*
;;swapping arguments (AOP_TYPEs 1/3)
;;unsigned compare: left >= lit(0xD=13), size=1
;; >>> gen.c:3265:pic14_mov2w_regOrLit
	MOVLW	0x0d
;; >>> gen.c:3432:genCmp
;;	1009
;;	1028  _scanCode   offset=0
	SUBWF	_scanCode,W
;;; gen.c:3237:genSkipc *{*
;; >>> gen.c:3244:genSkipc
	BTFSS	STATUS,0
;; >>> gen.c:3246:genSkipc
;; ***	popGetLabel  key=48, label offset 115
	GOTO	_00263_DS_
;;genSkipc:3247: created from rifx:0x7fff91f84700
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:3583:genCmpLt *{*
;; ***	genCmpLt  3584
;; ***	aopForSym 315
;;	327 sym->rname = _scanCode, size = 1
;;; gen.c:3294:genCmp *{*
;;unsigned compare: left < lit(0x7E=126), size=1
;; >>> gen.c:3265:pic14_mov2w_regOrLit
	MOVLW	0x7e
;; >>> gen.c:3432:genCmp
;;	1009
;;	1028  _scanCode   offset=0
	SUBWF	_scanCode,W
;;; gen.c:3237:genSkipc *{*
;; >>> gen.c:3242:genSkipc
	BTFSC	STATUS,0
;; >>> gen.c:3246:genSkipc
;; ***	popGetLabel  key=48, label offset 115
	GOTO	_00263_DS_
;;genSkipc:3247: created from rifx:0x7fff91f84700
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:7300:genDjnz *{*
;; ***	genDjnz  7301
;;; genarith.c:896:genMinus *{*
;; ***	genMinus  897
;; ***	aopForSym 315
;;	327 sym->rname = _scanCode, size = 1
;;	575
;; 	result AOP_DIR, left AOP_DIR, right AOP_LIT
;;; genarith.c:269:genAddLit *{*
;; ***	genAddLit  270
;;; genarith.c:233:genAddLit2byte *{*
;; >>> genarith.c:245:genAddLit2byte
	.line	384; "main.c"	scanCode -= 0x0D;
	MOVLW	0xf3
;; >>> genarith.c:246:genAddLit2byte
;;	1009
;;	1028  _scanCode   offset=0
	ADDWF	_scanCode,F
;; ***	addSign  861
;;; genarith.c:862:addSign *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:3919:genAnd *{*
;; ***	genAnd  3920
;;	694 register type nRegs=1
;; 	line = 3955 result AOP_CRY=0x00, size=0, left AOP_REG=r0x1059, size=1, right AOP_LIT=0x01, size=1
;;; gen.c:3842:isLiteralBit *{*
;; ***	isLiteralBit  3843
;; >>> gen.c:4039:genAnd
	.line	385; "main.c"	if(ps2Config & layoutUSA)
	BTFSS	r0x100E,0
;; >>> gen.c:4040:genAnd
;; ***	popGetLabel  key=34, label offset 115
	GOTO	_00249_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;; ***	genPlus  611
;;; genarith.c:612:genPlus *{*
;; ***	aopForSym 315
;;	327 sym->rname = _scanCode, size = 1
;;	575
;; 	line = 618 result AOP_DIR=_scanCode, size=1, left AOP_DIR=_scanCode, size=1, right AOP_LIT=0x71, size=1
;;; genarith.c:142:genPlusIncr *{*
;; ***	genPlusIncr  144
;; 	result AOP_DIR, left AOP_DIR, right AOP_LIT
;; 	genPlusIncr  156
;;	adding lit to something. size 1
;;; genarith.c:269:genAddLit *{*
;; ***	genAddLit  270
;;; genarith.c:233:genAddLit2byte *{*
;; >>> genarith.c:245:genAddLit2byte
	.line	386; "main.c"	scanCode += 0x71;
	MOVLW	0x71
;; >>> genarith.c:246:genAddLit2byte
;;	1009
;;	1028  _scanCode   offset=0
	ADDWF	_scanCode,F
;; ***	addSign  861
;;; genarith.c:862:addSign *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6742:genIfx *{*
;; ***	genIfx  6743
;; ***	aopForSym 315
;;	327 sym->rname = _ctrl, size = 1
;; ***	pic14_toBoolean  1515
;; >>> gen.c:1522:pic14_toBoolean
_00249_DS_
	.line	388; "main.c"	if(ctrl)				// CTRL + tasto
	MOVLW	0x00
;; >>> gen.c:1533:pic14_toBoolean
;;	1009
;;	1028  _ctrl   offset=0
	IORWF	_ctrl,W
;; >>> gen.c:6796:genIfx
	BTFSC	STATUS,2
;; >>> gen.c:6797:genIfx
;; ***	popGetLabel  key=39, label offset 115
	GOTO	_00254_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;; ***	genPlus  611
;;; genarith.c:612:genPlus *{*
;;	613
;;	aopForRemat 392
;;	418: rname _ctrlAscii, val 0, const = 0
;; ***	aopForSym 315
;;	327 sym->rname = _scanCode, size = 1
;;	694 register type nRegs=2
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_ctrlAscii
;; 	line = 618 result AOP_REG=r0x105B, size=2, left AOP_PCODE=_ctrlAscii, size=2, right AOP_DIR=_scanCode, size=1
;;; genarith.c:142:genPlusIncr *{*
;; ***	genPlusIncr  144
;; 	result AOP_REG, left AOP_PCODE, right AOP_DIR
;; ***	genPlus  717
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_ctrlAscii
;; >>> genarith.c:726:genPlus
;;	1009
;;	1028  _scanCode   offset=0
	.line	389; "main.c"	ascii = ctrlAscii[scanCode];
	MOVF	_scanCode,W
;; >>> genarith.c:735:genPlus
	ADDLW	(_ctrlAscii + 0)
;; >>> genarith.c:736:genPlus
;;	1109 rIdx = r0x105B 
	MOVWF	r0x1010
;; >>> genarith.c:799:genPlus
	MOVLW	high (_ctrlAscii + 0)
;; >>> genarith.c:800:genPlus
	BTFSC	STATUS,0
;; >>> genarith.c:801:genPlus
	ADDLW	0x01
;; >>> genarith.c:802:genPlus
;;	1109 rIdx = r0x105C 
	MOVWF	r0x1011
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6145:genPointerGet *{*
;; ***	genPointerGet  6146
;;; gen.c:6092:genConstPointerGet *{*
;; ***	genConstPointerGet  6093
;;	694 register type nRegs=2
;;	694 register type nRegs=1
;; 	line = 6097 result AOP_REG=r0x105A, size=1, left AOP_REG=r0x105B, size=2, right -=-, size=0
;; 	 6099 getting const pointer
;;; gen.c:1343:mov2w_op *{*
;; ***	mov2w  1381  offset=0
;; >>> gen.c:1386:mov2w
;;	1109 rIdx = r0x105B 
	MOVF	r0x1010,W
;; >>> gen.c:6115:genConstPointerGet
;; ***	popRegFromIdx,1042  , rIdx=0x7e
	MOVWF	STK01
;;; gen.c:1343:mov2w_op *{*
;; ***	mov2w  1381  offset=1
;; >>> gen.c:1386:mov2w
;;	1109 rIdx = r0x105C 
	MOVF	r0x1011,W
;; >>> gen.c:6117:genConstPointerGet
;; ***	popRegFromIdx,1042  , rIdx=0x7f
	MOVWF	STK00
;; >>> gen.c:6118:genConstPointerGet
	MOVLW	0x80
;; >>> gen.c:1433:call_libraryfunc
	PAGESEL	__gptrget1
;; >>> gen.c:1435:call_libraryfunc
	CALL	__gptrget1
;; >>> gen.c:1437:call_libraryfunc
	PAGESEL	$
;; >>> gen.c:1393:movwf
;;	1109 rIdx = r0x105A 
	MOVWF	r0x100F
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2778:genGoto *{*
;; >>> gen.c:2780:genGoto
;; ***	popGetLabel  key=48, label offset 115
	GOTO	_00263_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:4220:genOr *{*
;; ***	genOr  4221
;; ***	aopForSym 315
;;	327 sym->rname = _shift, size = 1
;; ***	aopForSym 315
;;	327 sym->rname = _shiftLock, size = 1
;;	694 register type nRegs=1
;; 	line = 4227 result AOP_REG=r0x105B, size=1, left AOP_DIR=_shift, size=1, right AOP_DIR=_shiftLock, size=1
;; 	line = 4253 result AOP_REG=r0x105B, size=1, left AOP_DIR=_shift, size=1, right AOP_DIR=_shiftLock, size=1
;; >>> gen.c:4479:genOr
;;	1009
;;	1028  _shiftLock   offset=0
_00254_DS_
	.line	391; "main.c"	if(shift | shiftLock)	// SHIFT + tasto
	MOVF	_shiftLock,W
;; >>> gen.c:4480:genOr
;;	1009
;;	1028  _shift   offset=0
	IORWF	_shift,W
;; >>> gen.c:4481:genOr
;;	1109 rIdx = r0x105B 
	MOVWF	r0x1010
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6742:genIfx *{*
;; ***	genIfx  6743
;;	694 register type nRegs=1
;; ***	pic14_toBoolean  1515
;; >>> gen.c:1522:pic14_toBoolean
	MOVF	r0x1010,W
	BTFSC	STATUS,2
;; >>> gen.c:6797:genIfx
;; ***	popGetLabel  key=36, label offset 115
	GOTO	_00251_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;; ***	genPlus  611
;;; genarith.c:612:genPlus *{*
;;	613
;;	aopForRemat 392
;;	418: rname _shiftAscii, val 0, const = 0
;; ***	aopForSym 315
;;	327 sym->rname = _scanCode, size = 1
;;	694 register type nRegs=2
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_shiftAscii
;; 	line = 618 result AOP_REG=r0x105B, size=2, left AOP_PCODE=_shiftAscii, size=2, right AOP_DIR=_scanCode, size=1
;;; genarith.c:142:genPlusIncr *{*
;; ***	genPlusIncr  144
;; 	result AOP_REG, left AOP_PCODE, right AOP_DIR
;; ***	genPlus  717
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_shiftAscii
;; >>> genarith.c:726:genPlus
;;	1009
;;	1028  _scanCode   offset=0
	.line	392; "main.c"	ascii = shiftAscii[scanCode];
	MOVF	_scanCode,W
;; >>> genarith.c:735:genPlus
	ADDLW	(_shiftAscii + 0)
;; >>> genarith.c:736:genPlus
;;	1109 rIdx = r0x105B 
	MOVWF	r0x1010
;; >>> genarith.c:799:genPlus
	MOVLW	high (_shiftAscii + 0)
;; >>> genarith.c:800:genPlus
	BTFSC	STATUS,0
;; >>> genarith.c:801:genPlus
	ADDLW	0x01
;; >>> genarith.c:802:genPlus
;;	1109 rIdx = r0x105C 
	MOVWF	r0x1011
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6145:genPointerGet *{*
;; ***	genPointerGet  6146
;;; gen.c:6092:genConstPointerGet *{*
;; ***	genConstPointerGet  6093
;;	694 register type nRegs=2
;;	694 register type nRegs=1
;; 	line = 6097 result AOP_REG=r0x105A, size=1, left AOP_REG=r0x105B, size=2, right -=-, size=0
;; 	 6099 getting const pointer
;;; gen.c:1343:mov2w_op *{*
;; ***	mov2w  1381  offset=0
;; >>> gen.c:1386:mov2w
;;	1109 rIdx = r0x105B 
	MOVF	r0x1010,W
;; >>> gen.c:6115:genConstPointerGet
;; ***	popRegFromIdx,1042  , rIdx=0x7e
	MOVWF	STK01
;;; gen.c:1343:mov2w_op *{*
;; ***	mov2w  1381  offset=1
;; >>> gen.c:1386:mov2w
;;	1109 rIdx = r0x105C 
	MOVF	r0x1011,W
;; >>> gen.c:6117:genConstPointerGet
;; ***	popRegFromIdx,1042  , rIdx=0x7f
	MOVWF	STK00
;; >>> gen.c:6118:genConstPointerGet
	MOVLW	0x80
;; >>> gen.c:1433:call_libraryfunc
	PAGESEL	__gptrget1
;; >>> gen.c:1435:call_libraryfunc
	CALL	__gptrget1
;; >>> gen.c:1437:call_libraryfunc
	PAGESEL	$
;; >>> gen.c:1393:movwf
;;	1109 rIdx = r0x105A 
	MOVWF	r0x100F
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2778:genGoto *{*
;; >>> gen.c:2780:genGoto
;; ***	popGetLabel  key=48, label offset 115
	GOTO	_00263_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;; ***	genPlus  611
;;; genarith.c:612:genPlus *{*
;;	613
;;	aopForRemat 392
;;	418: rname _normalAscii, val 0, const = 0
;; ***	aopForSym 315
;;	327 sym->rname = _scanCode, size = 1
;;	694 register type nRegs=2
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_normalAscii
;; 	line = 618 result AOP_REG=r0x105B, size=2, left AOP_PCODE=_normalAscii, size=2, right AOP_DIR=_scanCode, size=1
;;; genarith.c:142:genPlusIncr *{*
;; ***	genPlusIncr  144
;; 	result AOP_REG, left AOP_PCODE, right AOP_DIR
;; ***	genPlus  717
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_normalAscii
;; >>> genarith.c:726:genPlus
;;	1009
;;	1028  _scanCode   offset=0
_00251_DS_
	.line	394; "main.c"	ascii = normalAscii[scanCode];
	MOVF	_scanCode,W
;; >>> genarith.c:735:genPlus
	ADDLW	(_normalAscii + 0)
;; >>> genarith.c:736:genPlus
;;	1109 rIdx = r0x105B 
	MOVWF	r0x1010
;; >>> genarith.c:799:genPlus
	MOVLW	high (_normalAscii + 0)
;; >>> genarith.c:800:genPlus
	BTFSC	STATUS,0
;; >>> genarith.c:801:genPlus
	ADDLW	0x01
;; >>> genarith.c:802:genPlus
;;	1109 rIdx = r0x105C 
	MOVWF	r0x1011
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6145:genPointerGet *{*
;; ***	genPointerGet  6146
;;; gen.c:6092:genConstPointerGet *{*
;; ***	genConstPointerGet  6093
;;	694 register type nRegs=2
;;	694 register type nRegs=1
;; 	line = 6097 result AOP_REG=r0x105A, size=1, left AOP_REG=r0x105B, size=2, right -=-, size=0
;; 	 6099 getting const pointer
;;; gen.c:1343:mov2w_op *{*
;; ***	mov2w  1381  offset=0
;; >>> gen.c:1386:mov2w
;;	1109 rIdx = r0x105B 
	MOVF	r0x1010,W
;; >>> gen.c:6115:genConstPointerGet
;; ***	popRegFromIdx,1042  , rIdx=0x7e
	MOVWF	STK01
;;; gen.c:1343:mov2w_op *{*
;; ***	mov2w  1381  offset=1
;; >>> gen.c:1386:mov2w
;;	1109 rIdx = r0x105C 
	MOVF	r0x1011,W
;; >>> gen.c:6117:genConstPointerGet
;; ***	popRegFromIdx,1042  , rIdx=0x7f
	MOVWF	STK00
;; >>> gen.c:6118:genConstPointerGet
	MOVLW	0x80
;; >>> gen.c:1433:call_libraryfunc
	PAGESEL	__gptrget1
;; >>> gen.c:1435:call_libraryfunc
	CALL	__gptrget1
;; >>> gen.c:1437:call_libraryfunc
	PAGESEL	$
;; >>> gen.c:1393:movwf
;;	1109 rIdx = r0x105A 
	MOVWF	r0x100F
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6742:genIfx *{*
;; ***	genIfx  6743
;;	694 register type nRegs=1
;; ***	pic14_toBoolean  1515
;; >>> gen.c:1522:pic14_toBoolean
_00263_DS_
	.line	400; "main.c"	if(ascii)
	MOVLW	0x00
;; >>> gen.c:1533:pic14_toBoolean
;;	1109 rIdx = r0x105A 
	IORWF	r0x100F,W
;; >>> gen.c:6796:genIfx
	BTFSC	STATUS,2
;; >>> gen.c:6797:genIfx
;; ***	popGetLabel  key=53, label offset 115
	GOTO	_00268_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:1609:genCpl *{*
;; ***	genCpl  1611
;;	694 register type nRegs=1
;; ***	aopForSym 315
;;	327 sym->rname = _PORTB, size = 1
;; >>> gen.c:1631:genCpl
;;	1109 rIdx = r0x105A 
	.line	402; "main.c"	lxData = ~ascii;
	COMF	r0x100F,W
;; >>> gen.c:1632:genCpl
;;	1009
;;	1028  _PORTB   offset=0
	MOVWF	_PORTB
;; ***	addSign  861
;;; genarith.c:862:addSign *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2086:genCall *{*
;; ***	genCall  2088
;;; gen.c:1801:saveRegisters *{*
;; ***	saveRegisters  1803
;; 	2135 left AOP_LIT
;;; gen.c:1343:mov2w_op *{*
;; >>> gen.c:1361:mov2w_op
	.line	403; "main.c"	delay_us(1500);
	MOVLW	0xdc
;; 	2135 left AOP_LIT
;; >>> gen.c:2143:genCall
;; ***	popRegFromIdx,1042  , rIdx=0x7f
	MOVWF	STK00
;;; gen.c:1343:mov2w_op *{*
;; >>> gen.c:1361:mov2w_op
	MOVLW	0x05
;; >>> gen.c:2173:genCall
	PAGESEL	_delay_us
;; >>> gen.c:2175:genCall
	CALL	_delay_us
;; >>> gen.c:2181:genCall
	PAGESEL	$
;;; gen.c:1845:unsaveRegisters *{*
;; ***	unsaveRegisters  1847
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6669:genPointerSet *{*
;; ***	genPointerSet  6670
;;; gen.c:6488:genNearPointerSet *{*
;; ***	genNearPointerSet  6489
;;	613
;;	aopForRemat 392
;;	418: rname _PORTBbits, val 0, const = 0
;; ***	genNearPointerSet  6504
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_PORTBbits
;; 	line = 6506 result AOP_PCODE=_PORTBbits, size=2, left -=-, size=0, right AOP_LIT=0x00, size=1
;;; gen.c:6232:genPackBits *{*
;; ***	genPackBits  6233
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_PORTBbits
;; >>> gen.c:6258:genPackBits
	.line	404; "main.c"	lxStrobe = 0;
	BCF	_PORTBbits,7
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2778:genGoto *{*
;; >>> gen.c:2780:genGoto
;; ***	popGetLabel  key=4, label offset 115
	GOTO	_00219_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:3919:genAnd *{*
;; ***	genAnd  3920
;; ***	aopForSym 315
;;	327 sym->rname = _alt, size = 1
;; ***	aopForSym 315
;;	327 sym->rname = _altGr, size = 1
;;	694 register type nRegs=1
;; 	line = 3955 result AOP_REG=r0x105A, size=1, left AOP_DIR=_alt, size=1, right AOP_DIR=_altGr, size=1
;; >>> gen.c:4197:genAnd
;;	1009
;;	1028  _altGr   offset=0
_00268_DS_
	.line	407; "main.c"	if(alt & altGr)
	MOVF	_altGr,W
;; >>> gen.c:4198:genAnd
;;	1009
;;	1028  _alt   offset=0
	ANDWF	_alt,W
;; >>> gen.c:4199:genAnd
;;	1109 rIdx = r0x105A 
	MOVWF	r0x100F
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6742:genIfx *{*
;; ***	genIfx  6743
;;	694 register type nRegs=1
;; ***	pic14_toBoolean  1515
;; >>> gen.c:1522:pic14_toBoolean
	MOVF	r0x100F,W
	BTFSC	STATUS,2
;; >>> gen.c:6797:genIfx
;; ***	popGetLabel  key=50, label offset 115
	GOTO	_00265_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6669:genPointerSet *{*
;; ***	genPointerSet  6670
;;; gen.c:6488:genNearPointerSet *{*
;; ***	genNearPointerSet  6489
;;	613
;;	aopForRemat 392
;;	418: rname _PORTAbits, val 0, const = 0
;; ***	genNearPointerSet  6504
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_PORTAbits
;; 	line = 6506 result AOP_PCODE=_PORTAbits, size=2, left -=-, size=0, right AOP_LIT=0x00, size=1
;;; gen.c:6232:genPackBits *{*
;; ***	genPackBits  6233
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_PORTAbits
;; >>> gen.c:6258:genPackBits
	.line	408; "main.c"	z80Break = 0;
	BCF	_PORTAbits,2
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2778:genGoto *{*
;; >>> gen.c:2780:genGoto
;; ***	popGetLabel  key=4, label offset 115
	GOTO	_00219_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6669:genPointerSet *{*
;; ***	genPointerSet  6670
;;; gen.c:6488:genNearPointerSet *{*
;; ***	genNearPointerSet  6489
;;	613
;;	aopForRemat 392
;;	418: rname _PORTAbits, val 0, const = 0
;; ***	genNearPointerSet  6504
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_PORTAbits
;; 	line = 6506 result AOP_PCODE=_PORTAbits, size=2, left -=-, size=0, right AOP_LIT=0x01, size=1
;;; gen.c:6232:genPackBits *{*
;; ***	genPackBits  6233
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_PORTAbits
;; >>> gen.c:6258:genPackBits
_00265_DS_
	.line	410; "main.c"	z80Break = 1;
	BSF	_PORTAbits,2
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2778:genGoto *{*
;; >>> gen.c:2780:genGoto
;; ***	popGetLabel  key=4, label offset 115
	GOTO	_00219_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2528:genEndFunction *{*
;; ***	genEndFunction  2530
	RETURN	
; exit point of _main

	New pBlock

code, dbName =C
;; Starting pCode block
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2340:genFunction *{*
;; ***	genFunction  2342 curr label offset=102previous max_key=4 
_flashPanel	;Function start
; 2 exit points
;;; gen.c:2316:resultRemat *{*
;;; gen.c:7341:genReceive *{*
;; ***	genReceive  7342
;;	694 register type nRegs=1
;;; gen.c:1907:assignResultValue *{*
;; ***	assignResultValue  1909
;; 	line = 1911 result -=-, size=0, left AOP_REG=r0x1052, size=1, right -=-, size=0
;; >>> gen.c:1393:movwf
;;	1109 rIdx = r0x1052 
	.line	249; "main.c"	void flashPanel(unsigned char count)
	MOVWF	r0x100C
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2086:genCall *{*
;; ***	genCall  2088
;;; gen.c:1801:saveRegisters *{*
;; ***	saveRegisters  1803
;; 	2135 left AOP_LIT
;;; gen.c:1343:mov2w_op *{*
;; >>> gen.c:1361:mov2w_op
_00211_DS_
	.line	253; "main.c"	setPanel(0b00000111);
	MOVLW	0x07
;; >>> gen.c:2175:genCall
	CALL	_setPanel
;;; gen.c:1845:unsaveRegisters *{*
;; ***	unsaveRegisters  1847
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2086:genCall *{*
;; ***	genCall  2088
;;; gen.c:1801:saveRegisters *{*
;; ***	saveRegisters  1803
;; 	2135 left AOP_LIT
;;; gen.c:1343:mov2w_op *{*
;; >>> gen.c:1361:mov2w_op
	.line	254; "main.c"	delay_ms(100);
	MOVLW	0x64
;; 	2135 left AOP_LIT
;; >>> gen.c:2143:genCall
;; ***	popRegFromIdx,1042  , rIdx=0x7f
	MOVWF	STK00
;;; gen.c:1343:mov2w_op *{*
;; >>> gen.c:1361:mov2w_op
	MOVLW	0x00
;; >>> gen.c:2173:genCall
	PAGESEL	_delay_ms
;; >>> gen.c:2175:genCall
	CALL	_delay_ms
;; >>> gen.c:2181:genCall
	PAGESEL	$
;;; gen.c:1845:unsaveRegisters *{*
;; ***	unsaveRegisters  1847
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2086:genCall *{*
;; ***	genCall  2088
;;; gen.c:1801:saveRegisters *{*
;; ***	saveRegisters  1803
;; 	2135 left AOP_LIT
;;; gen.c:1343:mov2w_op *{*
;; >>> gen.c:1361:mov2w_op
	.line	255; "main.c"	setPanel(0x00000000);
	MOVLW	0x00
;; >>> gen.c:2175:genCall
	CALL	_setPanel
;;; gen.c:1845:unsaveRegisters *{*
;; ***	unsaveRegisters  1847
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2086:genCall *{*
;; ***	genCall  2088
;;; gen.c:1801:saveRegisters *{*
;; ***	saveRegisters  1803
;; 	2135 left AOP_LIT
;;; gen.c:1343:mov2w_op *{*
;; >>> gen.c:1361:mov2w_op
	.line	256; "main.c"	delay_ms(100);
	MOVLW	0x64
;; 	2135 left AOP_LIT
;; >>> gen.c:2143:genCall
;; ***	popRegFromIdx,1042  , rIdx=0x7f
	MOVWF	STK00
;;; gen.c:1343:mov2w_op *{*
;; >>> gen.c:1361:mov2w_op
	MOVLW	0x00
;; >>> gen.c:2173:genCall
	PAGESEL	_delay_ms
;; >>> gen.c:2175:genCall
	CALL	_delay_ms
;; >>> gen.c:2181:genCall
	PAGESEL	$
;;; gen.c:1845:unsaveRegisters *{*
;; ***	unsaveRegisters  1847
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6910:genAssign *{*
;; ***	genAssign  6911
;;	694 register type nRegs=1
;;	694 register type nRegs=1
;; 	line = 6920 result AOP_REG=r0x1053, size=1, left -=-, size=0, right AOP_REG=r0x1052, size=1
;; ***	genAssign  7006
;;; gen.c:1343:mov2w_op *{*
;; ***	mov2w  1381  offset=0
;; >>> gen.c:1386:mov2w
;;	1109 rIdx = r0x1052 
	.line	257; "main.c"	} while(count--);
	MOVF	r0x100C,W
;; >>> gen.c:7033:genAssign
;;	1109 rIdx = r0x1053 
	MOVWF	r0x100D
;;; gen.c:2316:resultRemat *{*
;;; gen.c:7300:genDjnz *{*
;; ***	genDjnz  7301
;;; genarith.c:896:genMinus *{*
;; ***	genMinus  897
;;	694 register type nRegs=1
;;	575
;; 	result AOP_REG, left AOP_REG, right AOP_LIT
;;; genarith.c:269:genAddLit *{*
;; ***	genAddLit  270
;;; genarith.c:233:genAddLit2byte *{*
;; >>> genarith.c:242:genAddLit2byte
;;	1109 rIdx = r0x1052 
	DECF	r0x100C,F
;; ***	addSign  861
;;; genarith.c:862:addSign *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6742:genIfx *{*
;; ***	genIfx  6743
;;	694 register type nRegs=1
;; ***	pic14_toBoolean  1515
;; >>> gen.c:1522:pic14_toBoolean
	MOVF	r0x100D,W
	BTFSS	STATUS,2
;; >>> gen.c:6792:genIfx
;; ***	popGetLabel  key=1, label offset 110
	GOTO	_00211_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2683:genRet *{*
;; ***	genRet  2685
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2528:genEndFunction *{*
;; ***	genEndFunction  2530
	.line	259; "main.c"	return;
	RETURN	
; exit point of _flashPanel
;;; gen.c:7409:genpic14Code *{*

	New pBlock

code, dbName =C
;; Starting pCode block
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2340:genFunction *{*
;; ***	genFunction  2342 curr label offset=38previous max_key=60 
_setPanel	;Function start
; 2 exit points
;;; gen.c:2316:resultRemat *{*
;;; gen.c:7341:genReceive *{*
;; ***	genReceive  7342
;;	694 register type nRegs=1
;;; gen.c:1907:assignResultValue *{*
;; ***	assignResultValue  1909
;; 	line = 1911 result -=-, size=0, left AOP_REG=r0x1051, size=1, right -=-, size=0
;; >>> gen.c:1393:movwf
;;	1109 rIdx = r0x1051 
	.line	228; "main.c"	void setPanel(unsigned char leds)
	MOVWF	r0x100B
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6910:genAssign *{*
;; ***	genAssign  6911
;;	575
;; 	line = 6920 result AOP_DIR=_commandCode, size=1, left -=-, size=0, right AOP_LIT=0xed, size=1
;; ***	genAssign  7006
;; >>> gen.c:7013:genAssign
	.line	230; "main.c"	commandCode = 0xED;
	MOVLW	0xed
;; >>> gen.c:7015:genAssign
;;	1009
;;	1028  _commandCode   offset=0
	MOVWF	_commandCode
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2086:genCall *{*
;; ***	genCall  2088
;;; gen.c:1801:saveRegisters *{*
;; ***	saveRegisters  1803
;; >>> gen.c:2175:genCall
_00203_DS_
	.line	233; "main.c"	sendCommandCode();
	CALL	_sendCommandCode
;;; gen.c:1845:unsaveRegisters *{*
;; ***	unsaveRegisters  1847
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2086:genCall *{*
;; ***	genCall  2088
;;; gen.c:1801:saveRegisters *{*
;; ***	saveRegisters  1803
;; >>> gen.c:2175:genCall
	.line	234; "main.c"	readScanCode();
	CALL	_readScanCode
;;; gen.c:1845:unsaveRegisters *{*
;; ***	unsaveRegisters  1847
;;; gen.c:2316:resultRemat *{*
;;; gen.c:3619:genCmpEq *{*
;; ***	genCmpEq  3620
;; ifx is non-null
;; ***	aopForSym 315
;;	327 sym->rname = _scanCode, size = 1
;; 	line = 3631 result AOP_CRY=0x00, size=0, left AOP_DIR=_scanCode, size=1, right AOP_LIT=0xfa, size=1
;; ***	mov2w  1381  offset=0
;; >>> gen.c:1386:mov2w
;;	1009
;;	1028  _scanCode   offset=0
	.line	235; "main.c"	} while(scanCode != 0xFA);
	MOVF	_scanCode,W
;; >>> gen.c:3685:genCmpEq
	XORLW	0xfa
;; >>> gen.c:3687:genCmpEq
	BTFSS	STATUS,2
;; >>> gen.c:3690:genCmpEq
;; ***	popGetLabel  key=1, label offset 102
	GOTO	_00203_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6910:genAssign *{*
;; ***	genAssign  6911
;;	694 register type nRegs=1
;; ***	aopForSym 315
;;	327 sym->rname = _commandCode, size = 1
;; 	line = 6920 result AOP_DIR=_commandCode, size=1, left -=-, size=0, right AOP_REG=r0x1051, size=1
;; ***	genAssign  7006
;;; gen.c:1343:mov2w_op *{*
;; ***	mov2w  1381  offset=0
;; >>> gen.c:1386:mov2w
;;	1109 rIdx = r0x1051 
	.line	237; "main.c"	commandCode = leds;
	MOVF	r0x100B,W
;; >>> gen.c:7033:genAssign
;;	1009
;;	1028  _commandCode   offset=0
	MOVWF	_commandCode
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2086:genCall *{*
;; ***	genCall  2088
;;; gen.c:1801:saveRegisters *{*
;; ***	saveRegisters  1803
;; >>> gen.c:2175:genCall
_00206_DS_
	.line	240; "main.c"	sendCommandCode();
	CALL	_sendCommandCode
;;; gen.c:1845:unsaveRegisters *{*
;; ***	unsaveRegisters  1847
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2086:genCall *{*
;; ***	genCall  2088
;;; gen.c:1801:saveRegisters *{*
;; ***	saveRegisters  1803
;; >>> gen.c:2175:genCall
	.line	241; "main.c"	readScanCode();
	CALL	_readScanCode
;;; gen.c:1845:unsaveRegisters *{*
;; ***	unsaveRegisters  1847
;;; gen.c:2316:resultRemat *{*
;;; gen.c:3619:genCmpEq *{*
;; ***	genCmpEq  3620
;; ifx is non-null
;; ***	aopForSym 315
;;	327 sym->rname = _scanCode, size = 1
;; 	line = 3631 result AOP_CRY=0x00, size=0, left AOP_DIR=_scanCode, size=1, right AOP_LIT=0xfa, size=1
;; ***	mov2w  1381  offset=0
;; >>> gen.c:1386:mov2w
;;	1009
;;	1028  _scanCode   offset=0
	.line	242; "main.c"	} while(scanCode != 0xFA);
	MOVF	_scanCode,W
;; >>> gen.c:3685:genCmpEq
	XORLW	0xfa
;; >>> gen.c:3687:genCmpEq
	BTFSS	STATUS,2
;; >>> gen.c:3690:genCmpEq
;; ***	popGetLabel  key=4, label offset 102
	GOTO	_00206_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2683:genRet *{*
;; ***	genRet  2685
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2528:genEndFunction *{*
;; ***	genEndFunction  2530
	.line	244; "main.c"	return;
	RETURN	
; exit point of _setPanel
;;; gen.c:7409:genpic14Code *{*

	New pBlock

code, dbName =C
;; Starting pCode block
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2340:genFunction *{*
;; ***	genFunction  2342 curr label offset=12previous max_key=22 
_readScanCode	;Function start
; 2 exit points
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6910:genAssign *{*
;; ***	genAssign  6911
;; ***	aopForSym 315
;;	327 sym->rname = _extendedKey, size = 1
;; 	line = 6920 result AOP_DIR=_extendedKey, size=1, left -=-, size=0, right AOP_LIT=0x00, size=1
;; ***	genAssign  7006
;; >>> gen.c:7018:genAssign
;;	1009
;;	1028  _extendedKey   offset=0
	.line	194; "main.c"	keyUp = extendedKey = 0;
	CLRF	_extendedKey
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6910:genAssign *{*
;; ***	genAssign  6911
;; ***	aopForSym 315
;;	327 sym->rname = _keyUp, size = 1
;; 	line = 6920 result AOP_DIR=_keyUp, size=1, left -=-, size=0, right AOP_LIT=0x00, size=1
;; ***	genAssign  7006
;; >>> gen.c:7018:genAssign
;;	1009
;;	1028  _keyUp   offset=0
	CLRF	_keyUp
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6910:genAssign *{*
;; ***	genAssign  6911
;; ***	aopForSym 315
;;	327 sym->rname = _scanCode, size = 1
;; 	line = 6920 result AOP_DIR=_scanCode, size=1, left -=-, size=0, right AOP_LIT=0x00, size=1
;; ***	genAssign  7006
;; >>> gen.c:7018:genAssign
;;	1009
;;	1028  _scanCode   offset=0
_00156_DS_
	.line	198; "main.c"	n = 9; scanCode = 0;
	CLRF	_scanCode
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6669:genPointerSet *{*
;; ***	genPointerSet  6670
;;; gen.c:6488:genNearPointerSet *{*
;; ***	genNearPointerSet  6489
;;	613
;;	aopForRemat 392
;;	418: rname _TRISAbits, val 0, const = 0
;; ***	genNearPointerSet  6504
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_TRISAbits
;; 	line = 6506 result AOP_PCODE=_TRISAbits, size=2, left -=-, size=0, right AOP_LIT=0x01, size=1
;;; gen.c:6232:genPackBits *{*
;; ***	genPackBits  6233
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_TRISAbits
;; >>> gen.c:6258:genPackBits
	.line	200; "main.c"	INPUT_ps2Clock();
	BSF	_TRISAbits,0
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6145:genPointerGet *{*
;; ***	genPointerGet  6146
;;; gen.c:5927:genNearPointerGet *{*
;; ***	genNearPointerGet  5928
;;	613
;;	aopForRemat 392
;;	418: rname _PORTAbits, val 0, const = 0
;; ***	genNearPointerGet  5944
;;	694 register type nRegs=1
;;; gen.c:5743:genUnpackBits *{*
;; ***	genUnpackBits  5744
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_PORTAbits
;; >>> gen.c:5766:genUnpackBits
_00139_DS_
	.line	201; "main.c"	while(ps2Clock);
	BTFSC	_PORTAbits,0
;; >>> gen.c:5767:genUnpackBits
;; ***	popGetLabel  key=1, label offset 38
	GOTO	_00139_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6910:genAssign *{*
;; ***	genAssign  6911
;;	694 register type nRegs=1
;; 	line = 6920 result AOP_REG=r0x104F, size=1, left -=-, size=0, right AOP_LIT=0x09, size=1
;; ***	genAssign  7006
;; >>> gen.c:7013:genAssign
	.line	203; "main.c"	while(--n)
	MOVLW	0x09
;; >>> gen.c:7015:genAssign
;;	1109 rIdx = r0x104F 
	MOVWF	r0x1009
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:7300:genDjnz *{*
;; ***	genDjnz  7301
;;; genarith.c:896:genMinus *{*
;; ***	genMinus  897
;;	694 register type nRegs=1
;;	575
;; 	result AOP_REG, left AOP_REG, right AOP_LIT
;;; genarith.c:269:genAddLit *{*
;; ***	genAddLit  270
;;; genarith.c:233:genAddLit2byte *{*
;; >>> genarith.c:242:genAddLit2byte
;;	1109 rIdx = r0x104F 
_00144_DS_
	DECF	r0x1009,F
;; ***	addSign  861
;;; genarith.c:862:addSign *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6742:genIfx *{*
;; ***	genIfx  6743
;;	694 register type nRegs=1
;; ***	pic14_toBoolean  1515
;; >>> gen.c:1522:pic14_toBoolean
	MOVF	r0x1009,W
	BTFSC	STATUS,2
;; >>> gen.c:6797:genIfx
;; ***	popGetLabel  key=8, label offset 38
	GOTO	_00146_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:5418:genGenericShift *{*
;; ***	genGenericShift  5421
;; ***	aopForSym 315
;;	327 sym->rname = _scanCode, size = 1
;;	575
;;shiftRight_Left2ResultLit:5273: shCount=1, size=1, sign=0, same=1, offr=0
;; >>> gen.c:5283:shiftRight_Left2ResultLit
	.line	205; "main.c"	scanCode >>= 1;
	BCF	STATUS,0
;; >>> gen.c:5293:shiftRight_Left2ResultLit
;;	1009
;;	1028  _scanCode   offset=0
	RRF	_scanCode,F
;; ***	addSign  861
;;; genarith.c:862:addSign *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2086:genCall *{*
;; ***	genCall  2088
;;; gen.c:1801:saveRegisters *{*
;; ***	saveRegisters  1803
;; >>> gen.c:2175:genCall
	.line	206; "main.c"	clockCycle();
	CALL	_clockCycle
;;; gen.c:1845:unsaveRegisters *{*
;; ***	unsaveRegisters  1847
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6145:genPointerGet *{*
;; ***	genPointerGet  6146
;;; gen.c:5927:genNearPointerGet *{*
;; ***	genNearPointerGet  5928
;;	613
;;	aopForRemat 392
;;	418: rname _PORTAbits, val 0, const = 0
;; ***	genNearPointerGet  5944
;;	694 register type nRegs=1
;;; gen.c:5743:genUnpackBits *{*
;; ***	genUnpackBits  5744
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_PORTAbits
;; >>> gen.c:5766:genUnpackBits
	.line	207; "main.c"	if(ps2Data) scanCode |= 0b10000000;
	BTFSS	_PORTAbits,1
;; >>> gen.c:5767:genUnpackBits
;; ***	popGetLabel  key=6, label offset 38
	GOTO	_00144_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:4220:genOr *{*
;; ***	genOr  4221
;;	575
;;	575
;; 	line = 4227 result AOP_DIR=_scanCode, size=1, left AOP_DIR=_scanCode, size=1, right AOP_LIT=0x80, size=1
;; 	line = 4253 result AOP_DIR=_scanCode, size=1, left AOP_DIR=_scanCode, size=1, right AOP_LIT=0x80, size=1
;; >>> gen.c:4404:genOr
	BSF	_scanCode,7
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2778:genGoto *{*
;; >>> gen.c:2780:genGoto
;; ***	popGetLabel  key=6, label offset 38
	GOTO	_00144_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2086:genCall *{*
;; ***	genCall  2088
;;; gen.c:1801:saveRegisters *{*
;; ***	saveRegisters  1803
;; >>> gen.c:2175:genCall
_00146_DS_
	.line	209; "main.c"	clockCycle();		// Scarta il bit di parita'
	CALL	_clockCycle
;;; gen.c:1845:unsaveRegisters *{*
;; ***	unsaveRegisters  1847
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2086:genCall *{*
;; ***	genCall  2088
;;; gen.c:1801:saveRegisters *{*
;; ***	saveRegisters  1803
;; >>> gen.c:2175:genCall
	.line	210; "main.c"	clockCycle();		// Scarta il bit di stop
	CALL	_clockCycle
;;; gen.c:1845:unsaveRegisters *{*
;; ***	unsaveRegisters  1847
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6145:genPointerGet *{*
;; ***	genPointerGet  6146
;;; gen.c:5927:genNearPointerGet *{*
;; ***	genNearPointerGet  5928
;;	613
;;	aopForRemat 392
;;	418: rname _PORTAbits, val 0, const = 0
;; ***	genNearPointerGet  5944
;;	694 register type nRegs=1
;;; gen.c:5743:genUnpackBits *{*
;; ***	genUnpackBits  5744
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_PORTAbits
;; >>> gen.c:5766:genUnpackBits
_00147_DS_
	.line	212; "main.c"	while(!ps2Clock);
	BTFSS	_PORTAbits,0
;; >>> gen.c:5767:genUnpackBits
;; ***	popGetLabel  key=9, label offset 38
	GOTO	_00147_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6669:genPointerSet *{*
;; ***	genPointerSet  6670
;;; gen.c:6488:genNearPointerSet *{*
;; ***	genNearPointerSet  6489
;;	613
;;	aopForRemat 392
;;	418: rname _PORTAbits, val 0, const = 0
;; ***	genNearPointerSet  6504
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_PORTAbits
;; 	line = 6506 result AOP_PCODE=_PORTAbits, size=2, left -=-, size=0, right AOP_LIT=0x00, size=1
;;; gen.c:6232:genPackBits *{*
;; ***	genPackBits  6233
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_PORTAbits
;; >>> gen.c:6258:genPackBits
	.line	213; "main.c"	LOW_ps2Clock();
	BCF	_PORTAbits,0
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6669:genPointerSet *{*
;; ***	genPointerSet  6670
;;; gen.c:6488:genNearPointerSet *{*
;; ***	genNearPointerSet  6489
;;	613
;;	aopForRemat 392
;;	418: rname _TRISAbits, val 0, const = 0
;; ***	genNearPointerSet  6504
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_TRISAbits
;; 	line = 6506 result AOP_PCODE=_TRISAbits, size=2, left -=-, size=0, right AOP_LIT=0x00, size=1
;;; gen.c:6232:genPackBits *{*
;; ***	genPackBits  6233
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_TRISAbits
;; >>> gen.c:6258:genPackBits
	BCF	_TRISAbits,0
;;; gen.c:2316:resultRemat *{*
;;; gen.c:3619:genCmpEq *{*
;; ***	genCmpEq  3620
;; ifx is null
;; ***	aopForSym 315
;;	327 sym->rname = _scanCode, size = 1
;;	694 register type nRegs=1
;; 	line = 3631 result AOP_REG=r0x104F, size=1, left AOP_DIR=_scanCode, size=1, right AOP_LIT=0xf0, size=1
;; >>> gen.c:3657:genCmpEq
;;	1109 rIdx = r0x104F 
	.line	215; "main.c"	if(scanCode == 0xF0)
	CLRF	r0x1009
;; ***	mov2w  1381  offset=0
;; >>> gen.c:1386:mov2w
;;	1009
;;	1028  _scanCode   offset=0
	MOVF	_scanCode,W
;; >>> gen.c:3685:genCmpEq
	XORLW	0xf0
	BTFSC	STATUS,2
	INCF	r0x1009,F
	MOVF	r0x1009,W
	BTFSC	STATUS,2
;; >>> gen.c:6797:genIfx
;; ***	popGetLabel  key=15, label offset 38
	GOTO	_00153_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6910:genAssign *{*
;; ***	genAssign  6911
;; ***	aopForSym 315
;;	327 sym->rname = _keyUp, size = 1
;; 	line = 6920 result AOP_DIR=_keyUp, size=1, left -=-, size=0, right AOP_LIT=0x01, size=1
;; ***	genAssign  7006
;; >>> gen.c:7013:genAssign
	.line	216; "main.c"	keyUp = 1;
	MOVLW	0x01
;; >>> gen.c:7015:genAssign
;;	1009
;;	1028  _keyUp   offset=0
	MOVWF	_keyUp
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2778:genGoto *{*
;; >>> gen.c:2780:genGoto
;; ***	popGetLabel  key=19, label offset 38
	GOTO	_00157_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:3619:genCmpEq *{*
;; ***	genCmpEq  3620
;; ifx is non-null
;; ***	aopForSym 315
;;	327 sym->rname = _scanCode, size = 1
;; 	line = 3631 result AOP_CRY=0x00, size=0, left AOP_DIR=_scanCode, size=1, right AOP_LIT=0xe0, size=1
;; ***	mov2w  1381  offset=0
;; >>> gen.c:1386:mov2w
;;	1009
;;	1028  _scanCode   offset=0
_00153_DS_
	.line	218; "main.c"	if(scanCode == 0xE0)
	MOVF	_scanCode,W
;; >>> gen.c:3685:genCmpEq
	XORLW	0xe0
;; >>> gen.c:3687:genCmpEq
	BTFSS	STATUS,2
;; >>> gen.c:3690:genCmpEq
;; ***	popGetLabel  key=19, label offset 38
	GOTO	_00157_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6910:genAssign *{*
;; ***	genAssign  6911
;; ***	aopForSym 315
;;	327 sym->rname = _extendedKey, size = 1
;; 	line = 6920 result AOP_DIR=_extendedKey, size=1, left -=-, size=0, right AOP_LIT=0x01, size=1
;; ***	genAssign  7006
;; >>> gen.c:7013:genAssign
	.line	219; "main.c"	extendedKey = 1;
	MOVLW	0x01
;; >>> gen.c:7015:genAssign
;;	1009
;;	1028  _extendedKey   offset=0
	MOVWF	_extendedKey
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:3619:genCmpEq *{*
;; ***	genCmpEq  3620
;; ifx is non-null
;; ***	aopForSym 315
;;	327 sym->rname = _scanCode, size = 1
;; 	line = 3631 result AOP_CRY=0x00, size=0, left AOP_DIR=_scanCode, size=1, right AOP_LIT=0xe0, size=1
;; ***	mov2w  1381  offset=0
;; >>> gen.c:1386:mov2w
;;	1009
;;	1028  _scanCode   offset=0
_00157_DS_
	.line	220; "main.c"	} while(scanCode == 0xE0 || scanCode == 0xF0);
	MOVF	_scanCode,W
;; >>> gen.c:3685:genCmpEq
	XORLW	0xe0
	BTFSC	STATUS,2
	GOTO	_00156_DS_
	MOVF	r0x1009,W
	BTFSS	STATUS,2
;; >>> gen.c:6792:genIfx
;; ***	popGetLabel  key=18, label offset 38
	GOTO	_00156_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2683:genRet *{*
;; ***	genRet  2685
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2528:genEndFunction *{*
;; ***	genEndFunction  2530
	.line	222; "main.c"	return;
	RETURN	
; exit point of _readScanCode
;;; gen.c:7409:genpic14Code *{*

	New pBlock

code, dbName =C
;; Starting pCode block
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2340:genFunction *{*
;; ***	genFunction  2342 curr label offset=4previous max_key=4 
_sendCommandCode	;Function start
; 2 exit points
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6669:genPointerSet *{*
;; ***	genPointerSet  6670
;;; gen.c:6488:genNearPointerSet *{*
;; ***	genNearPointerSet  6489
;;	613
;;	aopForRemat 392
;;	418: rname _PORTAbits, val 0, const = 0
;; ***	genNearPointerSet  6504
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_PORTAbits
;; 	line = 6506 result AOP_PCODE=_PORTAbits, size=2, left -=-, size=0, right AOP_LIT=0x00, size=1
;;; gen.c:6232:genPackBits *{*
;; ***	genPackBits  6233
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_PORTAbits
;; >>> gen.c:6258:genPackBits
	.line	154; "main.c"	LOW_ps2Data();
	BCF	_PORTAbits,1
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6669:genPointerSet *{*
;; ***	genPointerSet  6670
;;; gen.c:6488:genNearPointerSet *{*
;; ***	genNearPointerSet  6489
;;	613
;;	aopForRemat 392
;;	418: rname _TRISAbits, val 0, const = 0
;; ***	genNearPointerSet  6504
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_TRISAbits
;; 	line = 6506 result AOP_PCODE=_TRISAbits, size=2, left -=-, size=0, right AOP_LIT=0x00, size=1
;;; gen.c:6232:genPackBits *{*
;; ***	genPackBits  6233
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_TRISAbits
;; >>> gen.c:6258:genPackBits
	BCF	_TRISAbits,1
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6669:genPointerSet *{*
;; ***	genPointerSet  6670
;;; gen.c:6488:genNearPointerSet *{*
;; ***	genNearPointerSet  6489
;;	613
;;	aopForRemat 392
;;	418: rname _PORTAbits, val 0, const = 0
;; ***	genNearPointerSet  6504
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_PORTAbits
;; 	line = 6506 result AOP_PCODE=_PORTAbits, size=2, left -=-, size=0, right AOP_LIT=0x00, size=1
;;; gen.c:6232:genPackBits *{*
;; ***	genPackBits  6233
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_PORTAbits
;; >>> gen.c:6258:genPackBits
	.line	155; "main.c"	LOW_ps2Clock();
	BCF	_PORTAbits,0
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6669:genPointerSet *{*
;; ***	genPointerSet  6670
;;; gen.c:6488:genNearPointerSet *{*
;; ***	genNearPointerSet  6489
;;	613
;;	aopForRemat 392
;;	418: rname _TRISAbits, val 0, const = 0
;; ***	genNearPointerSet  6504
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_TRISAbits
;; 	line = 6506 result AOP_PCODE=_TRISAbits, size=2, left -=-, size=0, right AOP_LIT=0x00, size=1
;;; gen.c:6232:genPackBits *{*
;; ***	genPackBits  6233
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_TRISAbits
;; >>> gen.c:6258:genPackBits
	BCF	_TRISAbits,0
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2086:genCall *{*
;; ***	genCall  2088
;;; gen.c:1801:saveRegisters *{*
;; ***	saveRegisters  1803
;; 	2135 left AOP_LIT
;;; gen.c:1343:mov2w_op *{*
;; >>> gen.c:1361:mov2w_op
	.line	156; "main.c"	delay_us(100);
	MOVLW	0x64
;; 	2135 left AOP_LIT
;; >>> gen.c:2143:genCall
;; ***	popRegFromIdx,1042  , rIdx=0x7f
	MOVWF	STK00
;;; gen.c:1343:mov2w_op *{*
;; >>> gen.c:1361:mov2w_op
	MOVLW	0x00
;; >>> gen.c:2173:genCall
	PAGESEL	_delay_us
;; >>> gen.c:2175:genCall
	CALL	_delay_us
;; >>> gen.c:2181:genCall
	PAGESEL	$
;;; gen.c:1845:unsaveRegisters *{*
;; ***	unsaveRegisters  1847
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6669:genPointerSet *{*
;; ***	genPointerSet  6670
;;; gen.c:6488:genNearPointerSet *{*
;; ***	genNearPointerSet  6489
;;	613
;;	aopForRemat 392
;;	418: rname _TRISAbits, val 0, const = 0
;; ***	genNearPointerSet  6504
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_TRISAbits
;; 	line = 6506 result AOP_PCODE=_TRISAbits, size=2, left -=-, size=0, right AOP_LIT=0x01, size=1
;;; gen.c:6232:genPackBits *{*
;; ***	genPackBits  6233
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_TRISAbits
;; >>> gen.c:6258:genPackBits
	.line	157; "main.c"	INPUT_ps2Clock();
	BSF	_TRISAbits,0
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6145:genPointerGet *{*
;; ***	genPointerGet  6146
;;; gen.c:5927:genNearPointerGet *{*
;; ***	genNearPointerGet  5928
;;	613
;;	aopForRemat 392
;;	418: rname _PORTAbits, val 0, const = 0
;; ***	genNearPointerGet  5944
;;	694 register type nRegs=1
;;; gen.c:5743:genUnpackBits *{*
;; ***	genUnpackBits  5744
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_PORTAbits
;; >>> gen.c:5766:genUnpackBits
_00113_DS_
	.line	158; "main.c"	while(ps2Clock);
	BTFSC	_PORTAbits,0
;; >>> gen.c:5767:genUnpackBits
;; ***	popGetLabel  key=1, label offset 12
	GOTO	_00113_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6910:genAssign *{*
;; ***	genAssign  6911
;;	694 register type nRegs=1
;; 	line = 6920 result AOP_REG=r0x104A, size=1, left -=-, size=0, right AOP_LIT=0x01, size=1
;; ***	genAssign  7006
;; >>> gen.c:7013:genAssign
	.line	160; "main.c"	while(--n)
	MOVLW	0x01
;; >>> gen.c:7015:genAssign
;;	1109 rIdx = r0x104A 
	MOVWF	r0x1009
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6910:genAssign *{*
;; ***	genAssign  6911
;;	694 register type nRegs=1
;; 	line = 6920 result AOP_REG=r0x104B, size=1, left -=-, size=0, right AOP_LIT=0x09, size=1
;; ***	genAssign  7006
;; >>> gen.c:7013:genAssign
	MOVLW	0x09
;; >>> gen.c:7015:genAssign
;;	1109 rIdx = r0x104B 
	MOVWF	r0x100A
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:7300:genDjnz *{*
;; ***	genDjnz  7301
;;; genarith.c:896:genMinus *{*
;; ***	genMinus  897
;;	694 register type nRegs=1
;;	575
;; 	result AOP_REG, left AOP_REG, right AOP_LIT
;;; genarith.c:269:genAddLit *{*
;; ***	genAddLit  270
;;; genarith.c:233:genAddLit2byte *{*
;; >>> genarith.c:242:genAddLit2byte
;;	1109 rIdx = r0x104B 
_00121_DS_
	DECF	r0x100A,F
;; ***	addSign  861
;;; genarith.c:862:addSign *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6742:genIfx *{*
;; ***	genIfx  6743
;;	694 register type nRegs=1
;; ***	pic14_toBoolean  1515
;; >>> gen.c:1522:pic14_toBoolean
	MOVF	r0x100A,W
	BTFSC	STATUS,2
;; >>> gen.c:6797:genIfx
;; ***	popGetLabel  key=11, label offset 12
	GOTO	_00123_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:3919:genAnd *{*
;; ***	genAnd  3920
;; ***	aopForSym 315
;;	327 sym->rname = _commandCode, size = 1
;; 	line = 3955 result AOP_CRY=0x00, size=0, left AOP_DIR=_commandCode, size=1, right AOP_LIT=0x01, size=1
;;; gen.c:3842:isLiteralBit *{*
;; ***	isLiteralBit  3843
;; >>> gen.c:4039:genAnd
	.line	162; "main.c"	if(commandCode & 0b00000001)
	BTFSS	_commandCode,0
;; >>> gen.c:4040:genAnd
;; ***	popGetLabel  key=5, label offset 12
	GOTO	_00117_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6669:genPointerSet *{*
;; ***	genPointerSet  6670
;;; gen.c:6488:genNearPointerSet *{*
;; ***	genNearPointerSet  6489
;;	613
;;	aopForRemat 392
;;	418: rname _PORTAbits, val 0, const = 0
;; ***	genNearPointerSet  6504
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_PORTAbits
;; 	line = 6506 result AOP_PCODE=_PORTAbits, size=2, left -=-, size=0, right AOP_LIT=0x01, size=1
;;; gen.c:6232:genPackBits *{*
;; ***	genPackBits  6233
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_PORTAbits
;; >>> gen.c:6258:genPackBits
	.line	163; "main.c"	ps2Data = 1;
	BSF	_PORTAbits,1
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2778:genGoto *{*
;; >>> gen.c:2780:genGoto
;; ***	popGetLabel  key=6, label offset 12
	GOTO	_00118_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6669:genPointerSet *{*
;; ***	genPointerSet  6670
;;; gen.c:6488:genNearPointerSet *{*
;; ***	genNearPointerSet  6489
;;	613
;;	aopForRemat 392
;;	418: rname _PORTAbits, val 0, const = 0
;; ***	genNearPointerSet  6504
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_PORTAbits
;; 	line = 6506 result AOP_PCODE=_PORTAbits, size=2, left -=-, size=0, right AOP_LIT=0x00, size=1
;;; gen.c:6232:genPackBits *{*
;; ***	genPackBits  6233
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_PORTAbits
;; >>> gen.c:6258:genPackBits
_00117_DS_
	.line	165; "main.c"	ps2Data = 0;
	BCF	_PORTAbits,1
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2086:genCall *{*
;; ***	genCall  2088
;;; gen.c:1801:saveRegisters *{*
;; ***	saveRegisters  1803
;; >>> gen.c:2175:genCall
_00118_DS_
	.line	166; "main.c"	clockCycle();
	CALL	_clockCycle
;;; gen.c:1845:unsaveRegisters *{*
;; ***	unsaveRegisters  1847
;;; gen.c:2316:resultRemat *{*
;;; gen.c:3919:genAnd *{*
;; ***	genAnd  3920
;; ***	aopForSym 315
;;	327 sym->rname = _commandCode, size = 1
;; 	line = 3955 result AOP_CRY=0x00, size=0, left AOP_DIR=_commandCode, size=1, right AOP_LIT=0x01, size=1
;;; gen.c:3842:isLiteralBit *{*
;; ***	isLiteralBit  3843
;; >>> gen.c:4039:genAnd
	.line	167; "main.c"	if(commandCode & 0b00000001)
	BTFSS	_commandCode,0
;; >>> gen.c:4040:genAnd
;; ***	popGetLabel  key=8, label offset 12
	GOTO	_00120_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;; ***	genPlus  611
;;; genarith.c:612:genPlus *{*
;;	694 register type nRegs=1
;;	575
;; 	line = 618 result AOP_REG=r0x104A, size=1, left AOP_REG=r0x104A, size=1, right AOP_LIT=0x01, size=1
;;; genarith.c:142:genPlusIncr *{*
;; ***	genPlusIncr  144
;; 	result AOP_REG, left AOP_REG, right AOP_LIT
;; 	genPlusIncr  156
;; >>> genarith.c:168:genPlusIncr
;;	1109 rIdx = r0x104A 
	.line	168; "main.c"	++parity;
	INCF	r0x1009,F
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:5418:genGenericShift *{*
;; ***	genGenericShift  5421
;; ***	aopForSym 315
;;	327 sym->rname = _commandCode, size = 1
;;	575
;;shiftRight_Left2ResultLit:5273: shCount=1, size=1, sign=0, same=1, offr=0
;; >>> gen.c:5283:shiftRight_Left2ResultLit
_00120_DS_
	.line	169; "main.c"	commandCode >>= 1;
	BCF	STATUS,0
;; >>> gen.c:5293:shiftRight_Left2ResultLit
;;	1009
;;	1028  _commandCode   offset=0
	RRF	_commandCode,F
;; ***	addSign  861
;;; genarith.c:862:addSign *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2778:genGoto *{*
;; >>> gen.c:2780:genGoto
;; ***	popGetLabel  key=9, label offset 12
	GOTO	_00121_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:3919:genAnd *{*
;; ***	genAnd  3920
;;	694 register type nRegs=1
;; 	line = 3955 result AOP_CRY=0x00, size=0, left AOP_REG=r0x104A, size=1, right AOP_LIT=0x01, size=1
;;; gen.c:3842:isLiteralBit *{*
;; ***	isLiteralBit  3843
;; >>> gen.c:4039:genAnd
_00123_DS_
	.line	172; "main.c"	if(parity & 0b00000001)
	BTFSS	r0x1009,0
;; >>> gen.c:4040:genAnd
;; ***	popGetLabel  key=13, label offset 12
	GOTO	_00125_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6669:genPointerSet *{*
;; ***	genPointerSet  6670
;;; gen.c:6488:genNearPointerSet *{*
;; ***	genNearPointerSet  6489
;;	613
;;	aopForRemat 392
;;	418: rname _PORTAbits, val 0, const = 0
;; ***	genNearPointerSet  6504
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_PORTAbits
;; 	line = 6506 result AOP_PCODE=_PORTAbits, size=2, left -=-, size=0, right AOP_LIT=0x01, size=1
;;; gen.c:6232:genPackBits *{*
;; ***	genPackBits  6233
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_PORTAbits
;; >>> gen.c:6258:genPackBits
	.line	173; "main.c"	ps2Data = 1;
	BSF	_PORTAbits,1
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2778:genGoto *{*
;; >>> gen.c:2780:genGoto
;; ***	popGetLabel  key=14, label offset 12
	GOTO	_00126_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6669:genPointerSet *{*
;; ***	genPointerSet  6670
;;; gen.c:6488:genNearPointerSet *{*
;; ***	genNearPointerSet  6489
;;	613
;;	aopForRemat 392
;;	418: rname _PORTAbits, val 0, const = 0
;; ***	genNearPointerSet  6504
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_PORTAbits
;; 	line = 6506 result AOP_PCODE=_PORTAbits, size=2, left -=-, size=0, right AOP_LIT=0x00, size=1
;;; gen.c:6232:genPackBits *{*
;; ***	genPackBits  6233
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_PORTAbits
;; >>> gen.c:6258:genPackBits
_00125_DS_
	.line	175; "main.c"	ps2Data = 0;
	BCF	_PORTAbits,1
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2086:genCall *{*
;; ***	genCall  2088
;;; gen.c:1801:saveRegisters *{*
;; ***	saveRegisters  1803
;; >>> gen.c:2175:genCall
_00126_DS_
	.line	176; "main.c"	clockCycle();
	CALL	_clockCycle
;;; gen.c:1845:unsaveRegisters *{*
;; ***	unsaveRegisters  1847
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6669:genPointerSet *{*
;; ***	genPointerSet  6670
;;; gen.c:6488:genNearPointerSet *{*
;; ***	genNearPointerSet  6489
;;	613
;;	aopForRemat 392
;;	418: rname _TRISAbits, val 0, const = 0
;; ***	genNearPointerSet  6504
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_TRISAbits
;; 	line = 6506 result AOP_PCODE=_TRISAbits, size=2, left -=-, size=0, right AOP_LIT=0x01, size=1
;;; gen.c:6232:genPackBits *{*
;; ***	genPackBits  6233
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_TRISAbits
;; >>> gen.c:6258:genPackBits
	.line	178; "main.c"	INPUT_ps2Data();
	BSF	_TRISAbits,1
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6145:genPointerGet *{*
;; ***	genPointerGet  6146
;;; gen.c:5927:genNearPointerGet *{*
;; ***	genNearPointerGet  5928
;;	613
;;	aopForRemat 392
;;	418: rname _PORTAbits, val 0, const = 0
;; ***	genNearPointerGet  5944
;;	694 register type nRegs=1
;;; gen.c:5743:genUnpackBits *{*
;; ***	genUnpackBits  5744
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_PORTAbits
;; >>> gen.c:5766:genUnpackBits
_00127_DS_
	.line	179; "main.c"	while(ps2Data);
	BTFSC	_PORTAbits,1
;; >>> gen.c:5767:genUnpackBits
;; ***	popGetLabel  key=15, label offset 12
	GOTO	_00127_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6145:genPointerGet *{*
;; ***	genPointerGet  6146
;;; gen.c:5927:genNearPointerGet *{*
;; ***	genNearPointerGet  5928
;;	613
;;	aopForRemat 392
;;	418: rname _PORTAbits, val 0, const = 0
;; ***	genNearPointerGet  5944
;;	694 register type nRegs=1
;;; gen.c:5743:genUnpackBits *{*
;; ***	genUnpackBits  5744
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_PORTAbits
;; >>> gen.c:5766:genUnpackBits
_00130_DS_
	.line	180; "main.c"	while(ps2Clock);
	BTFSC	_PORTAbits,0
;; >>> gen.c:5767:genUnpackBits
;; ***	popGetLabel  key=18, label offset 12
	GOTO	_00130_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6145:genPointerGet *{*
;; ***	genPointerGet  6146
;;; gen.c:5927:genNearPointerGet *{*
;; ***	genNearPointerGet  5928
;;	613
;;	aopForRemat 392
;;	418: rname _PORTAbits, val 0, const = 0
;; ***	genNearPointerGet  5944
;;	694 register type nRegs=1
;;; gen.c:5743:genUnpackBits *{*
;; ***	genUnpackBits  5744
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_PORTAbits
;; >>> gen.c:5766:genUnpackBits
_00134_DS_
	.line	181; "main.c"	while(!ps2Data || !ps2Clock);
	BTFSS	_PORTAbits,1
;; >>> gen.c:5767:genUnpackBits
;; ***	popGetLabel  key=22, label offset 12
	GOTO	_00134_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6145:genPointerGet *{*
;; ***	genPointerGet  6146
;;; gen.c:5927:genNearPointerGet *{*
;; ***	genNearPointerGet  5928
;;	613
;;	aopForRemat 392
;;	418: rname _PORTAbits, val 0, const = 0
;; ***	genNearPointerGet  5944
;;	694 register type nRegs=1
;;; gen.c:5743:genUnpackBits *{*
;; ***	genUnpackBits  5744
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_PORTAbits
;; >>> gen.c:5766:genUnpackBits
	BTFSS	_PORTAbits,0
;; >>> gen.c:5767:genUnpackBits
;; ***	popGetLabel  key=22, label offset 12
	GOTO	_00134_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6669:genPointerSet *{*
;; ***	genPointerSet  6670
;;; gen.c:6488:genNearPointerSet *{*
;; ***	genNearPointerSet  6489
;;	613
;;	aopForRemat 392
;;	418: rname _PORTAbits, val 0, const = 0
;; ***	genNearPointerSet  6504
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_PORTAbits
;; 	line = 6506 result AOP_PCODE=_PORTAbits, size=2, left -=-, size=0, right AOP_LIT=0x00, size=1
;;; gen.c:6232:genPackBits *{*
;; ***	genPackBits  6233
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_PORTAbits
;; >>> gen.c:6258:genPackBits
	.line	182; "main.c"	LOW_ps2Clock();
	BCF	_PORTAbits,0
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6669:genPointerSet *{*
;; ***	genPointerSet  6670
;;; gen.c:6488:genNearPointerSet *{*
;; ***	genNearPointerSet  6489
;;	613
;;	aopForRemat 392
;;	418: rname _TRISAbits, val 0, const = 0
;; ***	genNearPointerSet  6504
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_TRISAbits
;; 	line = 6506 result AOP_PCODE=_TRISAbits, size=2, left -=-, size=0, right AOP_LIT=0x00, size=1
;;; gen.c:6232:genPackBits *{*
;; ***	genPackBits  6233
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_TRISAbits
;; >>> gen.c:6258:genPackBits
	BCF	_TRISAbits,0
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2683:genRet *{*
;; ***	genRet  2685
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2528:genEndFunction *{*
;; ***	genEndFunction  2530
	.line	184; "main.c"	return;
	RETURN	
; exit point of _sendCommandCode
;;; gen.c:7409:genpic14Code *{*

	New pBlock

code, dbName =C
;; Starting pCode block
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2340:genFunction *{*
;; ***	genFunction  2342 curr label offset=0previous max_key=0 
_clockCycle	;Function start
; 2 exit points
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6145:genPointerGet *{*
;; ***	genPointerGet  6146
;;; gen.c:5927:genNearPointerGet *{*
;; ***	genNearPointerGet  5928
;;	613
;;	aopForRemat 392
;;	418: rname _PORTAbits, val 0, const = 0
;; ***	genNearPointerGet  5944
;;	694 register type nRegs=1
;;; gen.c:5743:genUnpackBits *{*
;; ***	genUnpackBits  5744
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_PORTAbits
;; >>> gen.c:5766:genUnpackBits
_00105_DS_
	.line	140; "main.c"	while(!ps2Clock);	// Attende fronte di salita
	BTFSS	_PORTAbits,0
;; >>> gen.c:5767:genUnpackBits
;; ***	popGetLabel  key=1, label offset 4
	GOTO	_00105_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:6145:genPointerGet *{*
;; ***	genPointerGet  6146
;;; gen.c:5927:genNearPointerGet *{*
;; ***	genNearPointerGet  5928
;;	613
;;	aopForRemat 392
;;	418: rname _PORTAbits, val 0, const = 0
;; ***	genNearPointerGet  5944
;;	694 register type nRegs=1
;;; gen.c:5743:genUnpackBits *{*
;; ***	genUnpackBits  5744
;;	833: aopGet AOP_PCODE type PO_IMMEDIATE
;;	_PORTAbits
;; >>> gen.c:5766:genUnpackBits
_00108_DS_
	.line	141; "main.c"	while(ps2Clock);	// Attende fronte di discesa
	BTFSC	_PORTAbits,0
;; >>> gen.c:5767:genUnpackBits
;; ***	popGetLabel  key=4, label offset 4
	GOTO	_00108_DS_
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2683:genRet *{*
;; ***	genRet  2685
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2760:genLabel *{*
;; ***	genLabel  2763
;;; gen.c:2316:resultRemat *{*
;;; gen.c:2528:genEndFunction *{*
;; ***	genEndFunction  2530
	.line	143; "main.c"	return;
	RETURN	
; exit point of _clockCycle
;;; gen.c:7409:genpic14Code *{*
