	psect	data


	global	_Chardelay

_Chardelay	defl	02ABDh

	global	_Linedelay

_Linedelay	defl	02ABFh

	global	_Phonefile

_Phonefile	defl	0288Dh

	global	_killlabel

_killlabel	defl	00D2Ch

	global	__cpm_sdcc_heap_free

__cpm_sdcc_heap_free	defl	02CF9h

	global	_Currdrive

_Currdrive	defl	03013h

	global	_Overdrive

_Overdrive	defl	03025h

	global	_Invokuser

_Invokuser	defl	03027h

	global	_Prtbottom

_Prtbottom	defl	02F50h

	global	_purgeline

_purgeline	defl	008E3h

	global	__cpm_sdcc_heap_size

__cpm_sdcc_heap_size	defl	02CF7h

	global	_openerror

_openerror	defl	008F0h

	global	_MainBuffer

_MainBuffer	defl	02F4Ch

	global	__cpm_clean

__cpm_clean	defl	02341h

	global	_ParityMask

_ParityMask	defl	02877h

	global	__init_heap

__init_heap	defl	010A1h

	global	_cpm_malloc

_cpm_malloc	defl	010D7h

	global	_Configovly

_Configovly	defl	028C9h

	global	_Invokdrive

_Invokdrive	defl	02F91h

	global	_filelength

_filelength	defl	00B36h

	global	_allocerror

_allocerror	defl	0094Fh

	global	csv

csv	defl	02824h

	global	_FDx

_FDx	defl	0286Fh

	global	_Mci

_Mci	defl	02A93h

	global	_Buf

_Buf	defl	02F93h

	global	_dio

_dio	defl	00899h

	global	_brk

_brk	defl	027A6h

	global	_cls

_cls	defl	00155h

	global	_mrd

_mrd	defl	00140h

	global	amod

amod	defl	02481h

	global	adiv

adiv	defl	02490h

	global	_max

_max	defl	02473h

	global	_box

_box	defl	00D6Fh

	global	_ctr

_ctr	defl	00C17h

	global	lmod

lmod	defl	02486h

	global	cret

cret	defl	02830h

	global	amul

amul	defl	02773h

	global	ldiv

ldiv	defl	0248Bh

	global	ncsv

ncsv	defl	02838h

	global	lmul

lmul	defl	02773h

	global	rcsv

rcsv	defl	0284Ch

	global	_Line

_Line	defl	02A86h

	global	__fcb

__fcb	defl	02D53h

	global	_Book

_Book	defl	03021h

	global	aladd

aladd	defl	02442h

	global	__iob

__iob	defl	02D02h

	global	_read

_read	defl	01A44h

	global	_addu

_addu	defl	0086Ah

	global	lladd

lladd	defl	02442h

	global	_main

_main	defl	0053Dh

	global	_bdos

_bdos	defl	022E2h

	global	_bios

_bios	defl	02316h

	global	_atoi

_atoi	defl	023BFh

	global	almod

almod	defl	026B6h

	global	aldiv

aldiv	defl	0268Fh

	global	_open

_open	defl	01986h

	global	_isin

_isin	defl	00A37h

	global	_sbrk

_sbrk	defl	027AEh

	global	_wait

_wait	defl	0017Fh

	global	__cpm_sdcc_heap

__cpm_sdcc_heap	defl	02CF5h

	global	_hwio

_hwio	defl	00191h

	global	indir

indir	defl	02837h

	global	llmod

llmod	defl	026D0h

	global	_exit

_exit	defl	01922h

	global	alrsh

alrsh	defl	02792h

	global	_BFlag

_BFlag	defl	0286Bh

	global	lldiv

lldiv	defl	026A2h

	global	_PFlag

_PFlag	defl	0286Dh

	global	start

start	defl	00100h

	global	__Hbss

__Hbss	defl	08243h

	global	_Modem

_Modem	defl	029C9h

	global	__Lbss

__Lbss	defl	02F35h

	global	_putc8

_putc8	defl	00194h

	global	_Wheel

_Wheel	defl	02AFDh

	global	_mread

_mread	defl	00EF6h

	global	_mchin

_mchin	defl	00143h

	global	_chrin

_chrin	defl	008A2h

	global	_close

_close	defl	01EC8h

	global	_index

_index	defl	02407h

	global	__exit

__exit	defl	023A4h

	global	_bmove

_bmove	defl	02763h

	global	_ovbgn

_ovbgn	defl	03036h

	global	__pnum

__pnum	defl	024E9h

	global	_fputc

_fputc	defl	016D1h

	global	_flush

_flush	defl	008C1h

	global	asamul

asamul	defl	023F8h

	global	_mirdy

_mirdy	defl	0014Ch

	global	_reset

_reset	defl	007EEh

	global	_dtron

_dtron	defl	00176h

	global	_fstat

_fstat	defl	00AF5h

	global	brelop

brelop	defl	02450h

	global	_initv

_initv	defl	0016Dh

	global	_write

_write	defl	01CACh

	global	aslmul

aslmul	defl	023F8h

	global	wrelop

wrelop	defl	02464h

	global	__Hdata

__Hdata	defl	02F35h

	global	__Ldata

__Ldata	defl	0286Ah

	global	_Thefcb

_Thefcb	defl	02F66h

	global	_Blklen

_Blklen	defl	02AEFh

	global	__argc_

__argc_	defl	0823Dh

	global	_Mspeed

_Mspeed	defl	02AFBh

	global	_Online

_Online	defl	02873h

	global	_Filter

_Filter	defl	02875h

	global	_Xmodem

_Xmodem	defl	02AF1h

	global	_getfcb

_getfcb	defl	01F60h

	global	_Userid

_Userid	defl	0301Fh

	global	_Zmodem

_Zmodem	defl	02AEBh

	global	asaladd

asaladd	defl	023AFh

	global	__Htext

__Htext	defl	0286Ah

	global	_Buftop

_Buftop	defl	03015h

	global	__Ltext

__Ltext	defl	00000h

	global	_Prtbuf

_Prtbuf	defl	02F46h

	global	_getchi

_getchi	defl	008AFh

	global	_Inhost

_Inhost	defl	02A91h

	global	_TxtPtr

_TxtPtr	defl	02AF7h

	global	_setfcb

_setfcb	defl	01FB2h

	global	_locate

_locate	defl	00152h

	global	__sibuf

__sibuf	defl	0803Bh

	global	aslladd

aslladd	defl	023AFh

	global	_fclose

_fclose	defl	017F5h

	global	_bdoshl

_bdoshl	defl	02300h

	global	_signal

_signal	defl	02249h

	global	_Sprint

_Sprint	defl	02AA8h

	global	_getuid

_getuid	defl	022BCh

	global	_kbwait

_kbwait	defl	0098Fh

	global	_putfcb

_putfcb	defl	01F9Fh

	global	_dtroff

_dtroff	defl	00179h

	global	asaldiv

asaldiv	defl	0267Ah

	global	asalmod

asalmod	defl	026C8h

	global	_fflush

_fflush	defl	0185Ch

	global	_Prttop

_Prttop	defl	03019h

	global	_clrbox

_clrbox	defl	00EB2h

	global	asllmod

asllmod	defl	026DBh

	global	_setuid

_setuid	defl	022D0h

	global	userdef

userdef	defl	0013Dh

	global	_mchout

_mchout	defl	00146h

	global	_strcat

_strcat	defl	027E9h

	global	aslldiv

aslldiv	defl	026AEh

	global	_printf

_printf	defl	013BFh

	global	iregset

iregset	defl	0241Ch

	global	_mswait

_mswait	defl	00182h

	global	_userin

_userin	defl	00185h

	global	_movmem

_movmem	defl	02763h

	global	_strlen

_strlen	defl	02816h

	global	_perror

_perror	defl	00973h

	global	_report

_report	defl	00A5Dh

	global	_KbMacro

_KbMacro	defl	028EDh

	global	_ovsize

_ovsize	defl	0131Ch

	global	_RemEcho

_RemEcho	defl	02871h

	global	_strcpy

_strcpy	defl	02804h

	global	_Cfgfile

_Cfgfile	defl	028B5h

	global	_Crcflag

_Crcflag	defl	02AE3h

	global	startup

startup	defl	01935h

	global	_Dialing

_Dialing	defl	02F48h

	global	_Logfile

_Logfile	defl	028A1h

	global	_Msgfile

_Msgfile	defl	02879h

	global	_Prthead

_Prthead	defl	0301Bh

	global	_Sending

_Sending	defl	02AE9h

	global	_XonXoff

_XonXoff	defl	02AE5h

	global	_Lastlog

_Lastlog	defl	02F52h

	global	_Bufsize

_Bufsize	defl	02AF5h

	global	_readock

_readock	defl	00C7Ch

	global	__sigchk

__sigchk	defl	0227Ch

	global	_grabmem

_grabmem	defl	0077Fh

	global	_initace

_initace	defl	0017Ch

	global	_Lastkey

_Lastkey	defl	02F4Eh

	global	_Stopped

_Stopped	defl	02AF9h

	global	_Prttail

_Prttail	defl	0301Dh

	global	__flsbuf

__flsbuf	defl	01729h

	global	_checksp

_checksp	defl	027DAh

	global	__ctype_

__ctype_	defl	02EA3h

	global	_Current

_Current	defl	02F8Ah

	global	_Pbufsiz

_Pbufsiz	defl	02A8Dh

	global	_sendbrk

_sendbrk	defl	0014Fh

	global	_stndend

_stndend	defl	0015Bh

	global	_deinitv

_deinitv	defl	00170h

	global	_readstr

_readstr	defl	009D6h

	global	__doprnt

__doprnt	defl	0141Fh

	global	_opabort

_opabort	defl	00C3Dh

	global	_getvars

_getvars	defl	0018Bh

	global	_stindex

_stindex	defl	01320h

	global	_getnext

_getnext	defl	00BF9h

	global	_minprdy

_minprdy	defl	00F6Ch

	global	__putrno

__putrno	defl	02363h

	global	_roundup

_roundup	defl	00B94h

	global	_setport

_setport	defl	0018Eh

	global	_stndout

_stndout	defl	00158h

	global	_wrerror

_wrerror	defl	00933h

	global	_moutrdy

_moutrdy	defl	00149h

	global	_ovstart

_ovstart	defl	0131Eh

	global	_userout

_userout	defl	00188h

	global	_QuitFlag

_QuitFlag	defl	02ADFh

	global	_mstrout

_mstrout	defl	00A7Ch

	global	_StopFlag

_StopFlag	defl	02AE1h

	global	_FirsTerm

_FirsTerm	defl	02AC1h

	global	_Wantfcs32

_Wantfcs32	defl	02AFFh

	global	__buffree

__buffree	defl	01906h

	global	_Maxdrive

_Maxdrive	defl	02A8Fh

	global	_cpm_free

_cpm_free	defl	01201h

	global	_fc_parse

_fc_parse	defl	02042h

	global	_readline

_readline	defl	00CE1h

	global	__bufallo

__bufallo	defl	018DCh

	global	__cleanup

__cleanup	defl	017D0h

	global	_Nozmodem

_Nozmodem	defl	02AEDh

	global	_mgetchar

_mgetchar	defl	00D2Fh

	global	__getargs

__getargs	defl	01938h

	global	_deldrive

_deldrive	defl	0086Bh

	global	_mcharinp

_mcharinp	defl	00F54h

	global	_hidecurs

_hidecurs	defl	0015Eh

	global	_putlabel

_putlabel	defl	00CF7h

	global	_Curruser

_Curruser	defl	03023h

	global	_ovloader

_ovloader	defl	00F82h

	global	_Overuser

_Overuser	defl	03017h

	global	_Initovly

_Initovly	defl	028D2h

	global	_Userover

_Userover	defl	02F4Ah

	global	_Xferovly

_Xferovly	defl	028E4h

	global	_screenpr

_screenpr	defl	0013Dh

	global	_mcharout

_mcharout	defl	00F5Bh

	global	_Termovly

_Termovly	defl	028DBh

	global	_Zrwindow

_Zrwindow	defl	02AF3h

	global	_mdmerror

_mdmerror	defl	00173h

	global	_getfirst

_getfirst	defl	00BC7h

	global	_savecurs

_savecurs	defl	00164h

	global	_getvarsr

_getvarsr	defl	0013Dh

	global	iregstore

iregstore	defl	02436h

	global	_minterru

_minterru	defl	0016Ah

	global	_restcurs

_restcurs	defl	00167h

	global	_showcurs

_showcurs	defl	00161h

	global	_XonXoffOk

_XonXoffOk	defl	02AE7h

	global	_Baudtable

_Baudtable	defl	02AC3h

	global	nularg

nularg	defl	0286Ah

	global	abort

abort	defl	001A0h

	global	bdos

bdos	defl	00005h

	global	cout

cout	defl	00206h

	global	cr

cr	defl	0000Dh

	global	lf

lf	defl	0000Ah

	global	print

print	defl	001F9h

	global	print1

print1	defl	001FAh

	global	print2

print2	defl	00201h

	global	size

size	defl	05000h

	global	nularg

nularg	defl	02D42h

	global	arg

arg	defl	00006h

	global	entry

entry	defl	00005h

	global	sguid

sguid	defl	00020h

	global	arg

arg	defl	00008h

	global	entry

entry	defl	00005h

	global	func

func	defl	00006h

	global	arg

arg	defl	00008h

	global	entry

entry	defl	00005h

	global	func

func	defl	00006h

	global	arg

arg	defl	00006h

	global	EXITSTS

EXITSTS	defl	00080h

	end

al	func

func	defl	00006h

	global	arg

arg	defl	00006h

	global	EXITSTS

EXITSTS	defl	00080h

	end

obal	entry

entry	defl	00005h

	global	sguid

sguid	defl	00020h

	global	arg

arg	defl	00008h

	global	entry

entry	defl	00005h

	global	func

func	defl	00006h

	global	arg

arg	defl	00008h

	global	entry

entry	defl	00005h

	global	func

func	defl	00006h

	global	arg

arg	defl	00006h

	global	EXITSTS

EXITSTS	defl	00080h

	end



EXITSTS	defl	00080h

	end

