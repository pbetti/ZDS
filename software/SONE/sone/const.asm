;
;********************************************************
;*							*
;*	    UNIVERSAL BASIC I/O SYSTEM (BIOS)		*
;*							*
;*                  system constants           		*
;*							*
;********************************************************
;
;	Programmers: Martino Stefano & Gallarani Paolo
	; Disassembly/retype Pino Giaquinto & Piergiorgio Betti 2015/04/25
;
vers	equ	('H'*256)+'S'		; Single side version
rev	equ	20			; CBIOS revision number
;
;
;	Boolean scalar constants
false	equ	0
true	equ	not false
;
;
; ***	I/O Devices	***
TTY	equ	01b			; CON:
RDR	equ	false			; Undefinited
PUN	equ	false			; Undefinited
LST	equ	10b			; LST:
;
;	Default Value for I/O byte
DftI.O	equ	(LST shl 6) or (RDR shl 4) or (PUN shl 2) or (TTY)
;
;
;
;********************************************************
;*							*
;*		ASCII EQUIVALENTS			*
;*							*
;********************************************************
;
bell	equ	'G'+'@'			; ring beeper
backsp	equ	'H'+'@'			; back space char.
tab	equ	'I'+'@'			; tabulation char.
lf	equ	'J'+'@'			; line-feed char.
ffeed	equ	'L'+'@'			; form feed char.
cr	equ	'M'+'@'			; carriage-return char.
pfx	equ	'S'+'@'			; attributes pfx
rever	equ	'H'			; Reverse On	(^SH)
flash	equ	'C'			; Flash On	(^SC)
norm	equ	'@'			; Normal	(^S@)
spc	equ	' '			; space char.
endmsg	equ	'$'			; end of print message
;
;
;
;********************************************************
;*							*
;*		Rom routines address			*
;*							*
;********************************************************
;
rom	equ	0F000h			; <--- rom starting address
cin	equ	rom+3			; console input
cout	equ	rom+6			; console output
csts	equ	rom+9			; console status
lout	equ	rom+12			; printer output
lsts	equ	rom+15			; printer status
fdios	equ	rom+18			; fdd I/O 128 byte
fdiod	equ	rom+21			; fdd I/O 256 byte
wdini	equ	rom+24			; wdd initialization
wdio	equ	rom+27			; wdd I/O 256 byte
strout	equ	rom+30			; print string .DE until $
; print	equ	strout			; sinonime
bootrom	equ	rom+33			; load BIOS and go to wboote
printat	equ	rom+36			; print str. -> DE at -> HL cursor
movcurs	equ	rom+39			; move cursor at -> HL
vidinit	equ	rom+42			; initialize video
CompFlg	equ	rom+45			; Version Number
;
;
;
;********************************************************
;*		SYSTEM CONSTANTS			*
;********************************************************
;
asmcpm	equ	false			; *** include and assemble cp/m ***
;
cpml	equ	bios-ccp		; lenght (in bytes) of cp/m system (ccp + bdos)
biosl	equ	600h			; lenght (in bytes) of standard bios
cpmsiz	equ	16h			; cpml/secsiz = lenght (sector num.) of cp/m (ccp + bdos)
biossiz	equ	06h			; biosl/secsiz = lenght (sector num.) of bios
iobyte	equ	0003h			; intel I/O byte
CurDsk	equ	0004h			; cp/m logical disk number
stack	equ	0080h			; wboot stack pointer
defldma	equ	0080h			; cp/m default dma adrs
stack1	equ	1000h			; ipl stack pointer
;
;
;********************************************************
;*							*
;*		Disk constants				*
;*							*
;********************************************************
;
fddsiz	equ	2			; fdd number on system (10 sec/trk -256 byte-)
wddsiz	equ	2			; wdd number on system (32 sec/trk -256 byte-)
extfds	equ	2			; fds number on system (17 sec/trk -128 byte-)
maxdsk	equ	fddsiz+wddsiz+extfds	; max disk on system
;
fddsec	equ	10			; fdd sec/trk (10)
wddsec	equ	32			; wdd sec/trk (32)
secsiz	equ	256			; byte/sector (256)
;
cpmblk	equ	secsiz/128		; r/w buffer size
secmsk	equ	cpmblk-1		; sector mask
fddspt	equ	fddsec*cpmblk		; cp/m fdd sec/trk (20)
wddspt	equ	wddsec*cpmblk		; cp/m wdd sec/trk (64)
;
;
;
;********************************************************
;*							*
;*	BDOS constants on entry to write		*
;*							*
;********************************************************
;
wrall	equ	0			; write to allocated
wrdir	equ	1			; write to directory
wrual	equ	2			; write to unallocated
;
