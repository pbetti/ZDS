;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.3.0 #8604 (May 17 2014) (Linux)
; This file was generated Sat May 24 19:48:09 2014
;--------------------------------------------------------
; PIC port for the 14-bit core
;--------------------------------------------------------
	.file	"main.c"
	list	p=16f628
	radix dec
	include "p16f628.inc"
;--------------------------------------------------------
; config word(s)
;--------------------------------------------------------
	__config 0x3f70
;--------------------------------------------------------
; external declarations
;--------------------------------------------------------
	extern	_delay_us
	extern	_delay_ms
	extern	_set_restart_wdt
	extern	_set_clock_speed
	extern	_STATUSbits
	extern	_PORTAbits
	extern	_PORTBbits
	extern	_INTCONbits
	extern	_PIR1bits
	extern	_T1CONbits
	extern	_T2CONbits
	extern	_CCP1CONbits
	extern	_RCSTAbits
	extern	_CMCONbits
	extern	_OPTION_REGbits
	extern	_TRISAbits
	extern	_TRISBbits
	extern	_PIE1bits
	extern	_PCONbits
	extern	_TXSTAbits
	extern	_EECON1bits
	extern	_VRCONbits
	extern	_INDF
	extern	_TMR0
	extern	_PCL
	extern	_STATUS
	extern	_FSR
	extern	_PORTA
	extern	_PORTB
	extern	_PCLATH
	extern	_INTCON
	extern	_PIR1
	extern	_TMR1
	extern	_TMR1L
	extern	_TMR1H
	extern	_T1CON
	extern	_TMR2
	extern	_T2CON
	extern	_CCPR1
	extern	_CCPR1L
	extern	_CCPR1H
	extern	_CCP1CON
	extern	_RCSTA
	extern	_TXREG
	extern	_RCREG
	extern	_CMCON
	extern	_OPTION_REG
	extern	_TRISA
	extern	_TRISB
	extern	_PIE1
	extern	_PCON
	extern	_PR2
	extern	_TXSTA
	extern	_SPBRG
	extern	_EEDATA
	extern	_EEADR
	extern	_EECON1
	extern	_EECON2
	extern	_VRCON
	extern	__gptrget1
	extern	__sdcc_gsinit_startup
;--------------------------------------------------------
; global declarations
;--------------------------------------------------------
	global	_clockCycle
	global	_sendCommandCode
	global	_readScanCode
	global	_setPanel
	global	_flashPanel
	global	_main
	global	_CLOCK_SPEED
	global	_commandCode
	global	_scanCode
	global	_keyUp
	global	_extendedKey
	global	_shift
	global	_ctrl
	global	_alt
	global	_altGr
	global	_shiftLock
	global	_ctrlAscii
	global	_shiftAscii
	global	_normalAscii
	global	_ps2Default

	global PSAVE
	global SSAVE
	global WSAVE
	global STK12
	global STK11
	global STK10
	global STK09
	global STK08
	global STK07
	global STK06
	global STK05
	global STK04
	global STK03
	global STK02
	global STK01
	global STK00

sharebank udata_ovr 0x0070
PSAVE	res 1
SSAVE	res 1
WSAVE	res 1
STK12	res 1
STK11	res 1
STK10	res 1
STK09	res 1
STK08	res 1
STK07	res 1
STK06	res 1
STK05	res 1
STK04	res 1
STK03	res 1
STK02	res 1
STK01	res 1
STK00	res 1

;--------------------------------------------------------
; global definitions
;--------------------------------------------------------
UD_main_0	udata
_commandCode	res	1

UD_main_1	udata
_keyUp	res	1

UD_main_2	udata
_extendedKey	res	1

;--------------------------------------------------------
; absolute symbol definitions
;--------------------------------------------------------
;--------------------------------------------------------
; compiler-defined variables
;--------------------------------------------------------
UDL_main_0	udata
r0x1009	res	1
r0x100A	res	1
r0x100B	res	1
r0x100C	res	1
r0x100D	res	1
r0x100E	res	1
r0x100F	res	1
r0x1010	res	1
r0x1011	res	1
;--------------------------------------------------------
; initialized data
;--------------------------------------------------------

ID_main_0	idata
_CLOCK_SPEED
	db	0x00, 0x09, 0x3d, 0x00


ID_main_1	idata
_scanCode
	db	0x00


ID_main_2	idata
_shift
	db	0x00


ID_main_3	idata
_ctrl
	db	0x00


ID_main_4	idata
_alt
	db	0x00


ID_main_5	idata
_altGr
	db	0x00


ID_main_6	idata
_shiftLock
	db	0x00


ID_main_7	code
_ctrlAscii
	retlw 0x0a
	retlw 0x1c
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x11
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x1a
	retlw 0x13
	retlw 0x01
	retlw 0x17
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x03
	retlw 0x18
	retlw 0x04
	retlw 0x05
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x20
	retlw 0x16
	retlw 0x06
	retlw 0x14
	retlw 0x12
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x0e
	retlw 0x02
	retlw 0x08
	retlw 0x07
	retlw 0x19
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x0d
	retlw 0x0a
	retlw 0x15
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x0b
	retlw 0x09
	retlw 0x0f
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x0c
	retlw 0x00
	retlw 0x10
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x1b
	retlw 0x1e
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x0d
	retlw 0x1d
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x08
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x1b
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x0a
	retlw 0x1e
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x11
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x1a
	retlw 0x13
	retlw 0x01
	retlw 0x17
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x03
	retlw 0x18
	retlw 0x04
	retlw 0x05
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x20
	retlw 0x16
	retlw 0x06
	retlw 0x14
	retlw 0x12
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x0e
	retlw 0x02
	retlw 0x08
	retlw 0x07
	retlw 0x19
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x0d
	retlw 0x0a
	retlw 0x15
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x0b
	retlw 0x09
	retlw 0x0f
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x0c
	retlw 0x00
	retlw 0x10
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x1b
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x0d
	retlw 0x1d
	retlw 0x00
	retlw 0x1c
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x08
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x1b
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00


ID_main_8	code
_shiftAscii
	retlw 0x0a
	retlw 0x7c
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x51
	retlw 0x21
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x5a
	retlw 0x53
	retlw 0x41
	retlw 0x57
	retlw 0x22
	retlw 0x00
	retlw 0x00
	retlw 0x43
	retlw 0x58
	retlw 0x44
	retlw 0x45
	retlw 0x24
	retlw 0x23
	retlw 0x00
	retlw 0x00
	retlw 0x20
	retlw 0x56
	retlw 0x46
	retlw 0x54
	retlw 0x52
	retlw 0x25
	retlw 0x00
	retlw 0x00
	retlw 0x4e
	retlw 0x42
	retlw 0x48
	retlw 0x47
	retlw 0x59
	retlw 0x26
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x4d
	retlw 0x4a
	retlw 0x55
	retlw 0x2f
	retlw 0x28
	retlw 0x00
	retlw 0x00
	retlw 0x3b
	retlw 0x4b
	retlw 0x49
	retlw 0x4f
	retlw 0x3d
	retlw 0x29
	retlw 0x00
	retlw 0x00
	retlw 0x3a
	retlw 0x5f
	retlw 0x4c
	retlw 0x60
	retlw 0x50
	retlw 0x3f
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x2a
	retlw 0x00
	retlw 0x7b
	retlw 0x7e
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x0d
	retlw 0x7d
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x3e
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x08
	retlw 0x00
	retlw 0x00
	retlw 0x31
	retlw 0x00
	retlw 0x34
	retlw 0x37
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x30
	retlw 0x2e
	retlw 0x32
	retlw 0x35
	retlw 0x36
	retlw 0x38
	retlw 0x1b
	retlw 0x00
	retlw 0x00
	retlw 0x2b
	retlw 0x33
	retlw 0x2d
	retlw 0x2a
	retlw 0x39
	retlw 0x0a
	retlw 0x7e
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x51
	retlw 0x21
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x5a
	retlw 0x53
	retlw 0x41
	retlw 0x57
	retlw 0x40
	retlw 0x00
	retlw 0x00
	retlw 0x43
	retlw 0x58
	retlw 0x44
	retlw 0x45
	retlw 0x24
	retlw 0x23
	retlw 0x00
	retlw 0x00
	retlw 0x20
	retlw 0x56
	retlw 0x46
	retlw 0x54
	retlw 0x52
	retlw 0x25
	retlw 0x00
	retlw 0x00
	retlw 0x4e
	retlw 0x42
	retlw 0x48
	retlw 0x47
	retlw 0x59
	retlw 0x5e
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x4d
	retlw 0x4a
	retlw 0x55
	retlw 0x26
	retlw 0x2a
	retlw 0x00
	retlw 0x00
	retlw 0x3c
	retlw 0x4b
	retlw 0x49
	retlw 0x4f
	retlw 0x29
	retlw 0x28
	retlw 0x00
	retlw 0x00
	retlw 0x3e
	retlw 0x3f
	retlw 0x4c
	retlw 0x3a
	retlw 0x50
	retlw 0x5f
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x22
	retlw 0x00
	retlw 0x7b
	retlw 0x2b
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x0d
	retlw 0x7d
	retlw 0x00
	retlw 0x7c
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x08
	retlw 0x00
	retlw 0x00
	retlw 0x31
	retlw 0x00
	retlw 0x34
	retlw 0x37
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x30
	retlw 0x2e
	retlw 0x32
	retlw 0x35
	retlw 0x36
	retlw 0x38
	retlw 0x1b
	retlw 0x00
	retlw 0x00
	retlw 0x2b
	retlw 0x33
	retlw 0x2d
	retlw 0x2a
	retlw 0x39


ID_main_9	code
_normalAscii
	retlw 0x0a
	retlw 0x5c
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x71
	retlw 0x31
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x7a
	retlw 0x73
	retlw 0x61
	retlw 0x77
	retlw 0x32
	retlw 0x00
	retlw 0x00
	retlw 0x63
	retlw 0x78
	retlw 0x64
	retlw 0x65
	retlw 0x34
	retlw 0x33
	retlw 0x00
	retlw 0x00
	retlw 0x20
	retlw 0x76
	retlw 0x66
	retlw 0x74
	retlw 0x72
	retlw 0x35
	retlw 0x00
	retlw 0x00
	retlw 0x6e
	retlw 0x62
	retlw 0x68
	retlw 0x67
	retlw 0x79
	retlw 0x36
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x6d
	retlw 0x6a
	retlw 0x75
	retlw 0x37
	retlw 0x38
	retlw 0x00
	retlw 0x00
	retlw 0x2c
	retlw 0x6b
	retlw 0x69
	retlw 0x6f
	retlw 0x30
	retlw 0x39
	retlw 0x00
	retlw 0x00
	retlw 0x2e
	retlw 0x2d
	retlw 0x6c
	retlw 0x40
	retlw 0x70
	retlw 0x27
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x2b
	retlw 0x00
	retlw 0x5b
	retlw 0x5e
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x0d
	retlw 0x5d
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x3c
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x08
	retlw 0x00
	retlw 0x00
	retlw 0x31
	retlw 0x00
	retlw 0x34
	retlw 0x37
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x30
	retlw 0x2e
	retlw 0x32
	retlw 0x35
	retlw 0x36
	retlw 0x38
	retlw 0x1b
	retlw 0x00
	retlw 0x00
	retlw 0x2b
	retlw 0x33
	retlw 0x2d
	retlw 0x2a
	retlw 0x39
	retlw 0x0a
	retlw 0x60
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x71
	retlw 0x31
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x7a
	retlw 0x73
	retlw 0x61
	retlw 0x77
	retlw 0x32
	retlw 0x00
	retlw 0x00
	retlw 0x63
	retlw 0x78
	retlw 0x64
	retlw 0x65
	retlw 0x34
	retlw 0x33
	retlw 0x00
	retlw 0x00
	retlw 0x20
	retlw 0x76
	retlw 0x66
	retlw 0x74
	retlw 0x72
	retlw 0x35
	retlw 0x00
	retlw 0x00
	retlw 0x6e
	retlw 0x62
	retlw 0x68
	retlw 0x67
	retlw 0x79
	retlw 0x36
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x6d
	retlw 0x6a
	retlw 0x75
	retlw 0x37
	retlw 0x38
	retlw 0x00
	retlw 0x00
	retlw 0x2c
	retlw 0x6b
	retlw 0x69
	retlw 0x6f
	retlw 0x30
	retlw 0x39
	retlw 0x00
	retlw 0x00
	retlw 0x2e
	retlw 0x2f
	retlw 0x6c
	retlw 0x3b
	retlw 0x70
	retlw 0x2d
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x27
	retlw 0x00
	retlw 0x5b
	retlw 0x3d
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x0d
	retlw 0x5d
	retlw 0x00
	retlw 0x5c
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x08
	retlw 0x00
	retlw 0x00
	retlw 0x31
	retlw 0x00
	retlw 0x34
	retlw 0x37
	retlw 0x00
	retlw 0x00
	retlw 0x00
	retlw 0x30
	retlw 0x2e
	retlw 0x32
	retlw 0x35
	retlw 0x36
	retlw 0x38
	retlw 0x1b
	retlw 0x00
	retlw 0x00
	retlw 0x2b
	retlw 0x33
	retlw 0x2d
	retlw 0x2a
	retlw 0x39


ID_main_10	idata	0x2100
_ps2Default
	db	0x00

;--------------------------------------------------------
; overlayable items in internal ram 
;--------------------------------------------------------
;	udata_ovr
;--------------------------------------------------------
; reset vector 
;--------------------------------------------------------
STARTUP	code 0x0000
	nop
	pagesel __sdcc_gsinit_startup
	goto	__sdcc_gsinit_startup
;--------------------------------------------------------
; code
;--------------------------------------------------------
code_main	code
;***
;  pBlock Stats: dbName = M
;***
;entry:  _main	;Function start
; 2 exit points
;has an exit
;functions called:
;   _readScanCode
;   _setPanel
;   _readScanCode
;   _setPanel
;   _delay_ms
;   _flashPanel
;   _setPanel
;   _setPanel
;   _delay_ms
;   _flashPanel
;   _setPanel
;   _setPanel
;   __gptrget1
;   __gptrget1
;   __gptrget1
;   _delay_us
;   _readScanCode
;   _setPanel
;   _readScanCode
;   _setPanel
;   _delay_ms
;   _flashPanel
;   _setPanel
;   _setPanel
;   _delay_ms
;   _flashPanel
;   _setPanel
;   _setPanel
;   __gptrget1
;   __gptrget1
;   __gptrget1
;   _delay_us
;6 compiler assigned registers:
;   r0x100E
;   r0x100F
;   r0x1010
;   r0x1011
;   STK00
;   STK01
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
	BANKSEL	_ps2Default
	MOVF	_ps2Default,W
;; >>> gen.c:7033:genAssign
;;	1109 rIdx = r0x1059 
	BANKSEL	r0x100E
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
	BANKSEL	_CMCON
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
	BANKSEL	_TRISAbits
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
	BANKSEL	_PORTB
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
	BANKSEL	_TRISB
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
	BANKSEL	_scanCode
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
	BANKSEL	_scanCode
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
	BANKSEL	_PORTBbits
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
	BANKSEL	r0x100F
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
	BANKSEL	_extendedKey
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
	BANKSEL	_scanCode
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
	BANKSEL	_keyUp
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
	BANKSEL	_altGr
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
	BANKSEL	_keyUp
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
	BANKSEL	_ctrl
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
	BANKSEL	_keyUp
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
	BANKSEL	r0x100F
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
	BANKSEL	_keyUp
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
	BANKSEL	r0x100F
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
	BANKSEL	_keyUp
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
	BANKSEL	r0x100F
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
	BANKSEL	_scanCode
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
	BANKSEL	_keyUp
	MOVF	_keyUp,W
;; >>> gen.c:1582:genNot
	MOVLW	0x00
;; >>> gen.c:1583:genNot
	BTFSC	STATUS,2
;; >>> gen.c:1584:genNot
	MOVLW	0x01
;; >>> gen.c:1393:movwf
;;	1109 rIdx = r0x105B 
	BANKSEL	r0x1010
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
	BANKSEL	_alt
	MOVF	_alt,W
;; >>> gen.c:7261:genCast
;;	1109 rIdx = r0x105C 
	BANKSEL	r0x1011
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
	BANKSEL	r0x100E
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
	BANKSEL	_shiftLock
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
	BANKSEL	r0x1010
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
	BANKSEL	r0x1010
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
	BANKSEL	r0x1010
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
	BANKSEL	_keyUp
	MOVF	_keyUp,W
;; >>> gen.c:1582:genNot
	MOVLW	0x00
;; >>> gen.c:1583:genNot
	BTFSC	STATUS,2
;; >>> gen.c:1584:genNot
	MOVLW	0x01
;; >>> gen.c:1393:movwf
;;	1109 rIdx = r0x105B 
	BANKSEL	r0x1010
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
	BANKSEL	_ctrl
	MOVF	_ctrl,W
;; >>> gen.c:7261:genCast
;;	1109 rIdx = r0x105C 
	BANKSEL	r0x1011
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
	BANKSEL	_alt
	MOVF	_alt,W
;; >>> gen.c:7261:genCast
;;	1109 rIdx = r0x105C 
	BANKSEL	r0x1011
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
	BANKSEL	r0x100E
	MOVF	r0x100E,W
;; >>> gen.c:7033:genAssign
;;	1009
;;	1028  _ps2Default   offset=0
	BANKSEL	_ps2Default
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
	BANKSEL	_shiftLock
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
	BANKSEL	r0x1010
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
	BANKSEL	r0x1010
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
	BANKSEL	r0x1010
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
	BANKSEL	_keyUp
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
	BANKSEL	_alt
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
	BANKSEL	_keyUp
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
	BANKSEL	_shift
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
	BANKSEL	_keyUp
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
	BANKSEL	_ctrl
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
	BANKSEL	_keyUp
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
	BANKSEL	_shiftLock
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
	BANKSEL	r0x1010
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
	BANKSEL	r0x1010
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
	BANKSEL	r0x1010
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
	BANKSEL	_keyUp
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
	BANKSEL	_scanCode
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
	BANKSEL	r0x100E
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
	BANKSEL	_scanCode
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
	BANKSEL	_ctrl
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
	BANKSEL	_scanCode
	MOVF	_scanCode,W
;; >>> genarith.c:735:genPlus
	ADDLW	(_ctrlAscii + 0)
;; >>> genarith.c:736:genPlus
;;	1109 rIdx = r0x105B 
	BANKSEL	r0x1010
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
	BANKSEL	r0x100F
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
	BANKSEL	_shiftLock
	MOVF	_shiftLock,W
;; >>> gen.c:4480:genOr
;;	1009
;;	1028  _shift   offset=0
	BANKSEL	_shift
	IORWF	_shift,W
;; >>> gen.c:4481:genOr
;;	1109 rIdx = r0x105B 
	BANKSEL	r0x1010
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
	BANKSEL	_scanCode
	MOVF	_scanCode,W
;; >>> genarith.c:735:genPlus
	ADDLW	(_shiftAscii + 0)
;; >>> genarith.c:736:genPlus
;;	1109 rIdx = r0x105B 
	BANKSEL	r0x1010
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
	BANKSEL	r0x100F
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
	BANKSEL	_scanCode
	MOVF	_scanCode,W
;; >>> genarith.c:735:genPlus
	ADDLW	(_normalAscii + 0)
;; >>> genarith.c:736:genPlus
;;	1109 rIdx = r0x105B 
	BANKSEL	r0x1010
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
	BANKSEL	r0x100F
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
	BANKSEL	r0x100F
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
	BANKSEL	_PORTB
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
	BANKSEL	_PORTBbits
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
	BANKSEL	_altGr
	MOVF	_altGr,W
;; >>> gen.c:4198:genAnd
;;	1009
;;	1028  _alt   offset=0
	BANKSEL	_alt
	ANDWF	_alt,W
;; >>> gen.c:4199:genAnd
;;	1109 rIdx = r0x105A 
	BANKSEL	r0x100F
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
	BANKSEL	_PORTAbits
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
	BANKSEL	_PORTAbits
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

;***
;  pBlock Stats: dbName = C
;***
;entry:  _flashPanel	;Function start
; 2 exit points
;has an exit
;functions called:
;   _setPanel
;   _delay_ms
;   _setPanel
;   _delay_ms
;   _setPanel
;   _delay_ms
;   _setPanel
;   _delay_ms
;3 compiler assigned registers:
;   r0x100C
;   STK00
;   r0x100D
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
	BANKSEL	r0x100C
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
	BANKSEL	r0x100C
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

;***
;  pBlock Stats: dbName = C
;***
;entry:  _setPanel	;Function start
; 2 exit points
;has an exit
;functions called:
;   _sendCommandCode
;   _readScanCode
;   _sendCommandCode
;   _readScanCode
;   _sendCommandCode
;   _readScanCode
;   _sendCommandCode
;   _readScanCode
;1 compiler assigned register :
;   r0x100B
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
	BANKSEL	r0x100B
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
	BANKSEL	_commandCode
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
	BANKSEL	_scanCode
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
	BANKSEL	r0x100B
	MOVF	r0x100B,W
;; >>> gen.c:7033:genAssign
;;	1009
;;	1028  _commandCode   offset=0
	BANKSEL	_commandCode
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
	BANKSEL	_scanCode
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

;***
;  pBlock Stats: dbName = C
;***
;entry:  _readScanCode	;Function start
; 2 exit points
;has an exit
;functions called:
;   _clockCycle
;   _clockCycle
;   _clockCycle
;   _clockCycle
;   _clockCycle
;   _clockCycle
;1 compiler assigned register :
;   r0x1009
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
	BANKSEL	_extendedKey
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
	BANKSEL	_keyUp
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
	BANKSEL	_scanCode
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
	BANKSEL	_TRISAbits
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
	BANKSEL	_PORTAbits
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
	BANKSEL	r0x1009
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
	BANKSEL	r0x1009
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
	BANKSEL	_scanCode
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
	BANKSEL	_PORTAbits
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
	BANKSEL	_scanCode
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
	BANKSEL	_PORTAbits
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
	BANKSEL	_TRISAbits
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
	BANKSEL	r0x1009
	CLRF	r0x1009
;; ***	mov2w  1381  offset=0
;; >>> gen.c:1386:mov2w
;;	1009
;;	1028  _scanCode   offset=0
	BANKSEL	_scanCode
	MOVF	_scanCode,W
;; >>> gen.c:3685:genCmpEq
	XORLW	0xf0
	BTFSS	STATUS,2
	GOTO	_00001_DS_
	BANKSEL	r0x1009
	INCF	r0x1009,F
_00001_DS_
	BANKSEL	r0x1009
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
	BANKSEL	_keyUp
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
	BANKSEL	_scanCode
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
	BANKSEL	_extendedKey
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
	BANKSEL	_scanCode
	MOVF	_scanCode,W
;; >>> gen.c:3685:genCmpEq
	XORLW	0xe0
	BTFSC	STATUS,2
	GOTO	_00156_DS_
	BANKSEL	r0x1009
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

;***
;  pBlock Stats: dbName = C
;***
;entry:  _sendCommandCode	;Function start
; 2 exit points
;has an exit
;functions called:
;   _delay_us
;   _clockCycle
;   _clockCycle
;   _delay_us
;   _clockCycle
;   _clockCycle
;3 compiler assigned registers:
;   STK00
;   r0x1009
;   r0x100A
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
	BANKSEL	_PORTAbits
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
	BANKSEL	_TRISAbits
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
	BANKSEL	_PORTAbits
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
	BANKSEL	_TRISAbits
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
	BANKSEL	_TRISAbits
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
	BANKSEL	_PORTAbits
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
	BANKSEL	r0x1009
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
	BANKSEL	r0x100A
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
	BANKSEL	_commandCode
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
	BANKSEL	_PORTAbits
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
	BANKSEL	_PORTAbits
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
	BANKSEL	_commandCode
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
	BANKSEL	r0x1009
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
	BANKSEL	_commandCode
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
	BANKSEL	r0x1009
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
	BANKSEL	_PORTAbits
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
	BANKSEL	_PORTAbits
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
	BANKSEL	_TRISAbits
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
	BANKSEL	_PORTAbits
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
	BANKSEL	_PORTAbits
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
	BANKSEL	_PORTAbits
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
	BANKSEL	_TRISAbits
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

;***
;  pBlock Stats: dbName = C
;***
;entry:  _clockCycle	;Function start
; 2 exit points
;has an exit
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
	BANKSEL	_PORTAbits
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
	BANKSEL	_PORTAbits
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


;	code size estimation:
;	  459+  151 =   610 instructions ( 1522 byte)

	end
