title	BOOTSYS	- CPM3.SYS 1.12
	subttl	Copyright (C) 2000 Andreas Gerlich
	page	70,132
;
; BOOTSYS relocates and places the resident and banked (if presend) part
; of a CPM3.SYS to their right places into memory and starts CP/M 3.1.
; You generate a cpm3.com for starting CP/M 3.1 with:
;	pip cpm3.com=bootsys.com,cpm3.sys
;
; Copyright © 2000 Andreas Gerlich (agl @ IRCNet)
;
; BOOTSYS is free software; you can redistribute it and/or modify it under
; the terms of the GNU General Public License as published by the Free
; Software Foundation; either version 2 of the License, or (at your
; option) any later version.
;
; This program is distributed in the hope that it will be useful, but
; WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
; General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
;

	; BOOTSYS WILL NOT WORK ON ALL CP/M 3.1 SYSTEMS. WHY ?
	; If the MOVE, XMOVE are placed in the banked part of the bios
	; then it can be that this parts will be superscribed when
	; bootsys+cpm3.sys are transfered to bank 0.
	; Try it if this utility works under your CP/M 3 system.
	; If it works you can start a new version of your
	; bios (if you develop one) direct under CP/M 3.1 .
	;
	; Bootsys works always under CP/M 2.2 to relocate a nonbanked or a
	; banked system in CPM3.SYS and to start CP/M 3.1 !!!
	;
	; You generate a cpm3.com for starting CP/M 3.1 with:
	;	pip cpm3.com=bootsys.com,cpm3.sys
	;

	if0
	.printx	'BOOTSYS - CPM3.SYS 1.12'
	endif

	.z80	; Code uses Z80 instructions

	aseg
	org	100h

;---------------------------------------------------------------------------
; 8086 Prefix by Andreas Gerlich. Necessary if bootsys.com/cpm3.com is
; running on a MS-DOS/Windows system. On a MS-DOS/Windows system this
; prefix prints a message and exits.
;
	;
	db	0ebh	  ; -*----  ex de,hl   (Z80)
			  ;   \
			  ;    +--  jmp 011ah  (8086)
			  ;   /
	db	018h	  ; ==
			  ;   \
	db	begin-$-1 ; ---+--  jr begin   (Z80)
	; please test if the relativpoint ist less then 80h far away.

	; Von Adresse 103 bis 11a ist Raum frei. Die Anzahl der nachfolgenden
	; Bytes sollte nicht erhoeht werden!
	;	|                       |
	;
	db	'8086 prefix by agl ;-) ' ; room for a little Message ;-)
	;
	;
;	org	 011ah	 ; must begin at this address

	db	0bah		; move dx,DOS_Txt (8086)
	dw	DOS_Txt
	db	0b4h,09h	; mov ah,09h	(8086, print string)
	db	0cdh,021h	; int 21	(8086, MSDOS)
	db	0b4h,01h	; mov ah,01h	(8086, input one character)
	db	0cdh,021h	; int 21	(8086, MSDOS)
	db	0cdh,020h	; int 20	(8086, Ende Programm)

begin:	jp	main

DOS_Txt:db	13,10,'Z80 or CP/M Emulator Required !',13,10,10

	db	'BOOTSYS is a new loader for a CPM3.SYS to load and run'
	db	13,10
	db	'CP/M 3.1 in an Z80-Emulator or on a real CP/M-Z80 system.'
	db	13,10,10
	db	022H,'Yet Another Z80 Emulator by AG',022h,' is a Z80 '
	db	'Emulator.',13,10
	db	'It is designed to provide an exact simulation of the',13,10
	db	'Z80 microprocessor on a UNIX / Linux system.',13,10,10
	db	'You find yaze-ag under',13,10,10
	db	9,'http://www.mathematik.uni-ulm.de/users/ag/yaze-ag/',13,10
	db	'     or',13,10
	db	9,'ftp://ag-yaze:yaze@xylopia-upload.mathematik.uni-ulm.de'
	db	13,10,10
	db	'Press any key to continue ...'
	db	'$'


;---------------------------------------------------------------------------
; TODO:
;
; 0. ERLEDIGT und getestet
;    Wenn CP/M 3 laeuft!
;    Bootsys+cpm3.sys mit Interbankmove alles nach Bank 0 transferieren
;    (source und dest beides 0100H) dort ausfuehren (durch wechsel nach
;    bank 0).  (BIOS Funktion xmove ueberpruefen ob vorhanden)
;	Die funktion conout und conin sollten alle direkt ueber das
;	Bios gehen und die Adresse von wboot sollte am Anfang abgesichert
;	werden und nur diese fuer alle spaeteren Operationen benutzt werden.
;	Warum? Nach dem Wechsel von bank 1 nach 0 werden noch Ausgaben
;	und Eingaben getaetigt (diese duerfen (nach page 67/68 System Guide)
;	direkt im bios aufgerufen werden), die CP/M Vektoren sind aber nicht
;	mehr vorhanden.
;
;
; 1. ERLEDIGT und getestet
;    Nachsehen ob die Vektoren bei 0 und 5 da sind (C3H nachsehen und ob
;    die zwei Adressen plausibel sind (wboot > bdos)).
;	Nein --> Auf jedenfall Booten und fuer die Ein-/Ausgaben direkt YAZE
;		 benutzen (Ein anderes System wird bei Halt entsprechen
;						nicht mehr reagieren ;-))
;	JA   --> Fuer die Ausgaben CP/M benutzen (conout/-in ueber bios).
;		 Parameter nachpruefen (wenn gegeben nur Copyright ausgeben).
;
; 2. ERLEDIGT und getestet bzw. siehe 0.
;    CP/M Version ueberpruefen (nur wenn Vektoren da sind).
;	Wenn Version 3 dann Meldung ausgeben (Bitte unter 2.2 ausfuehren).
;
;	ODER siehe 0 (Diese Funktion sollte nach der ueberpruefung der
;	Copyright Message erfolgen.)
;
; 3. ERLEDIGT und getestet
;    Ueberpruefen ob eine CPM3.SYS angehaengt ist. (ueber Copyright Message)
;
; 4. VERWORFEN
;    Zwischenpuffer auf printrecord (wieder verworfen und absolute auf 0080H
;    gesetzt. Diese File wird immer auf 0100H geladen)
;
; 5. ERLEDIGT und getestet
;    Nonbanked Sytem booten
;---------------------------------------------------------------------------
;
Copyright_message::
	db	0DH,0AH
	db	' BOOTSYS - CPM3.SYS, V '
	;
	db	'1.12 29.09.2002'	;<--- VERSION
	;
	db	' Copyright (c) 2000,2002 by'
	db	' A.Gerlich',0DH,0AH
Dollar::db	'$'

; Message die ausgegeben wird wenn bootsys ohne vorhandenem CP/M booten will
; (hierzu wird das Dollar 3 Zeilen weiter oben ersetzt)

	db	 'No CP/M vektors found, try to boot CP/M 3.1'
	db	' in cooperation with yaze-ag ...',0DH,0AH,'$'
;
;---------------------------------------------------------------------------

wboot::		equ	0
wbootvek::	equ	wboot+1
bdos::		equ	5
bdosvek::	equ	bdos+1
parameter::	equ	wboot+80h


	; MAIN
	;
main::	ld	sp,lstack	; Stack setzten

	; CP/M Vektoren ueberpruefen
	;

	ld	a,0c3H		; OP-Code fuer JP
	ld	ix,0
	cp	a,(ix+wboot)	; Ist an der Stelle von WBOOT ein JP-Opcode
	jp	nz,nocpmvektoren; nein --> direkt CPM booten mit YAZE

	cp	a,(ix+bdos)	; Ist an der Stelle von BDOS ein JP-Opcode
	jp	nz,nocpmvektoren; nein --> direkt CPM booten mit YAZE

	; JP-opcodes vorhanden
	; ueberpruefen ob BDOS-Adresse kleiner als die WBOOT-Adresse ist
	;
	ld	hl,(wboot + 1)
	ld	de,(bdos + 1)
	or	a,a
	sbc	hl,de		; HL = wboot - bdos
	jp	c,nocpmvektoren	; Carry flag: bdos-addresse ist groesser als
				;	      die warmboot-adresse
				;     (bdos muss immer kleiner als wboot sein)
	jp	z,nocpmvektoren	; Zero Flag: beide Adressen sind gleich
				; (Duerfte praktisch nie vorkommen, aber
				;  man weis ja nie (Murphy laesst gruessen :-))

	; CP/M Vektoren sind vorhanden
	;
	ld	(cpmvek),a	; Boolsche Variable "CP/M Vektoren" setzen.
				; (Ab jetzt werden Ein-/Ausgaben ueber das
				; BIOS getaetigt.)
	ld	hl,(wboot + 1)	; Warmbootvektor absichern (wird ab jetzt
	ld	(wbvektor),hl	;	   bei Character in/out verwendet !)

	; CP/M Vektoren sind vorhanden
	; `--> ueberpruefen ob ein Parameter gegeben wurde

	ld	hl,Copyright_message	; Copyright message ausgeben
	call	PRSTRfunc

	ld	a,(parameter)
	or	a,a		; Ist irgend ein Parameter vorhanden?
	jr	z,testcopyright	; nein --> go on

	jp	wboot			; und beenden


	; Copyright Message von Digital Research in CPM3.SYS ueberpruefen
	;
testcopyright::
	;
	; Testet ob eine Copyright message vorliegt. Im anderen Fall
	; ist sehr wahrscheinlich noch kein CPM3.SYS angehaengt worden.
	; CPM3.COM wird mit PIP cpm3.com=bootsys.com,cpm3.sys erzeugt.
	;
	ld	hl,CPM3SYS+copyrmsg
	ld	de,CopyDRI
	ld	bc,CDRIlen - CopyDRI
	;
cloop::	ld	a,(de)
	cpi			; vergleich A mit (HL) (A-[HL], HL++, BC--)
	jr	nz,nocopyright	; ungleich (nicht null) --> nocopyright
	jp	po,testecpmversion; p=odd (gesetzt)? --> BC=0 --> Alle
	;			; character sind identisch --> go on
	inc	de
	jr	cloop


nocopyright::
	;
	ld	hl,m_nocopyright
	call	PRSTRfunc

exit::
	ld	a,(cpmvek)
	or	a,a		; sind CP/M Vektoren vorhanden ?
	jp	nz,wboot	; ja --> Warm boot
	;
	halt
	db 0ffH			; exit yaze

nocpmvektoren::
	; Sind keine CP/M Vektoeren vorhanden wird davon ausgegangen
	; Yaze laeuft.
	;
	ld	a,095h		; I/O-Byte setzen fuer yaze. Ist notwendig wenn
	ld	(3),a		; bootsys+cpm3.sys beim Start von yaze von der
				; Unix-file yaze-cpm3.boot gebootet wird.

	ld	hl,Dollar	; Dollarzeichen ersetzen
	ld	(hl),' '	; new line
	ld	hl,Copyright_message
	call	PRSTRfunc
	jp	testcopyright

testecpmversion::
	;
	ld	a,(cpmvek)	; Sind CP/M Vektoren vorhanden?
	or	a,a
	jr	z,loadcpm3	; NEIN --> gleich CP/M 3 laden

	; CP/M Version testen
	;
	ld	c,12		; Versionsnummer von CP/M holen
	call	bdos
	;
	ld	a,l
	and	a,030H		; nur oberer Teil beruecksichtigen
	cp	a,030H
	jr	nz,loadcpm3	; ungleich Version 3x --> CPM3.SYS sofort laden

	; wenn CP/M 3.1 bereits laeuft
	; XMOVE ueberpruefen
	;
	ld	de,(29-1)*3	; -1 wegen Warmboot, 29 ist Position von XMOVE
	ld	hl,(1)		; hole Adresse von Warmboot
	add	hl,de		; hl points to the xmove-jmp in bios-table
	inc	hl		; points to jmp addresse
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a		; hl points to the xmove routine itself
	;
	; now test if RET instruction is available for xmove-routine
	;
	ld	a,0C9H		; RET-Opcode
	cp	(hl)
	jp	nz,MoveToBank0	; NO RET --> xmove vorhanden --> ales nach bnk0
	;
	ld	hl,no_xmove_message
	call	PRSTRfunc
	jp	exit

	; XMOVE seems to be implement
	; --> try to move all to bank 0
	;
MoveToBank0:
	ld	hl,bank1_message
	call	PRSTRfunc
	;
	; Die folgenden Returnadressen muessen vor dem interbank Move auf
	; den (lokalen) Stack liegen, damit sie auch in bank 0 existieren !!!
	ld	hl,RET3
	push	hl		; Returnadresse RET3 on stack
	ld	hl,RET2
	push	hl		; Returnadresse RET2 on stack
	ld	hl,RET1
	push	hl		; Returnaddress RET1 on stack

	; I don't use the bdos func 50. I test it and it does not work.
	; I think that the banked part of the bdos are used when bdos func 50
	; is called. But when bootsys.com+cpm3.sys are moved from bank 1 to
	; bank 0 the banked part will be overwrite. So I use the bios function
	; XMOVE, MOVE and SELMEM direkt over the bios to transfere
	; bootsys+cpm3.sys to bank 0 and to switch to bank 0!
	; In the yaze bios the interbank transfer is realized in C outside the
	; Z80 memory and the short routines (HALT, funcno in yaze bios and ret)
	; are in the resident part of the bios, so all does work in yaze.
	;
	ld	de,(29-1)*3	; -1 wegen Warmboot, 29 ist Position von XMOVE
	ld	hl,(1)		; hole Adresse von Warmboot
	add	hl,de		; hl points to the xmove-routine in bios

	ld	bc,0001H	; B=bank 0 (dest),  C=bank 1 (source)
	jp	(hl)		; call XMOVE, return address (RET1) is on stack


RET1::	ld	de,(25-1)*3	; 25 is the position of MOVE
	ld	hl,(1)
	add	hl,de		; hl points to the move routine in bios
	push	hl		; --> to stack (will be called with ret)

	ld	ix,CPM3SYS	; dort beginnt CPM3.SYS
	ld	a,(ix+reslen)
	add	a,(ix+bnklen)	; Gesamtlaenge <reslen> + <bnklen> berechnen

	ld	bc,CPM3SYS	; dort beginnt CPM3.SYS
	add	a,b		; += Offset vom CPM3.SYS Binary
	ld	b,a		; BC = <reslen> + <bnklen> + Offset CPM3.SYS

	ld	hl,0100H	; destination (bank 0) fuer move
	ld	de,0100H	; source (bank 1)
	ret			; call MOVE in bios (address on stack)

RET2::	; now all is transfered to bank 0; now switch to bank 0
	; this must be do directly because the bdos func 50 does not allow
	; to use bios func 27. See page 3-72 BDOS function "direct bios calls"

	; ld	hl,RET3 	; siehe oben
	; push	hl

	ld	de,(27-1)*3	; offset fuer SELMEM
	ld	hl,(1)
	add	hl,de		; hl points to SELMEM

	xor	a,a		; a <- 0 (bank 0)
	jp	(hl)		; call SELMEM

RET3::	nop	; now this instruction will be executed in bank 0

	ld	hl,bank0_message
	call	PRSTRfunc

;---------------------------------------------------------------------------
; Hier beginnt der eigentliche Lader fuer CPM3.SYS.
;---------------------------------------------------------------------------
;
; The following information are from page 115 Appendix D of the System Guide
;

;
; CPM3.SYS File Format:
;
;	0	Header Record (128 bytes)
;	1	Print Record (128 bytes)
;	2-n	CP/M 3 operating System in reserved order, top down.
;

;
; Header Record Definitions:
;
; CPM3SYS (see at the end) ; Begin of CPM3.SYS
;
restop	equ	0	; Top page plus one, at which the resident partion
;			; of CP/M 3 is to be loaded top down.
;
reslen	equ	1	; Length in pages (256 bytes) of the resident
;			; portion of CP/M 3.
;
bnktop	equ	2	; Top page plus one, at wich the banked portion
;			; of CP/M 3 is to be loaded top down.
;
bnklen	equ	3	; Length in pages (256 bytes) of the banked
;			; portion of CP/M 3.
;
coldboot equ	4	; Address of CP/M 3 Cold Boot entry point
;
copyrmsg equ	16	; Copyright Message
;

;
; Print Record:
;
; The Print Rekord in the CP/M 3 Load Table is ASCII,
; terminated by a dollar sign ($).
;
prrecord equ	128	; position of the Print Record
;
;---------------------------------------------------------------------------
;
zwsp::		equ	80H
zwsptop::	equ	zwsp+127; letztes Byte in Zwischenspeicher
;
; Kleiner Hinweis:	Wenn ich von "oberen Bereich" spreche, so ist damit
;			der Teil gemeint der adressmaessig weiter oben liegt
;			Dasselbe analog bei der Bezeichnung "unterer Teil"
;
;
loadcpm3::
	ld	hl,loadmsg	; Text "Loading ..." ausgeben
	call	PRSTRfunc
	;
	ld	hl,CPM3SYS+prrecord	; Printrekord ausgeben
	call	PRSTRfunc

	; Zuerst den residenten Teil kopieren.
	; Im SPR-Format sind alle Sektoren Seiten-Buendig in 128 Byte
	; Bloecken (log Sektor) abgelegt. Die Ablage erfolgte jedoch
	; upside-down, d.H. der letzte Sektor wird zuerst gelesen.
	;

	ld	ix,CPM3SYS	; dort beginnt CPM3.SYS
	ld	d,(ix+restop)
	ld	e,0		; DE <- top of resident part (<restop>)
	ld	a,(ix+reslen)	; LEN of resident part (256 Byte Pages !!!)
	add	a,a		; *2 = Anzahl der log Sektoren (128 Byte)
				; Muss mal 2 genommen werden da in <reslen>
				; die Anzahl von 256 Byte Pages abgelegt ist.
	ld	hl,CPM3SYS+0100H ; Zeiger auf 2. Record (1. Binary of CP/M 3)

	call	transfer	; A=Bloecke von HL-->DE (upside down)


	; HL zeigt nun auf den Begin des banked Teils und somit
	; auf den erster log. Sektor des unteren Bereichs


	push	hl		; Fuer Berechnung auf Stack

	exx			; 2 Registersatz fuer oberen Bereich

	pop	hl		; HL <- zeiger auf banked part

	ld	a,(ix+bnklen)	; LEN of banked part (<bnklen>)
	or	a,a		; Ist die Laenge fuer banked part 0
	jr	z,bootcpm3	; ja --> nonbanked System sofort booten

	; Wenn nein, banked part laden
	;
	add	a,h		; oberste page berechnen
	ld	h,a		; HL zeigt genau hinter den obersten
	;			; Sektor (banked part)
	dec	hl		; hl zeigt auf das letzte Byte des
				; des obersten log. Sektors

	ld	a,(ix+bnklen)	; LEN of banked part (<bnklen> 256 Byte pages)
	;			; (zum zaehlen)
	;
	; Dieser Zaehler darf NICHT *2 genommen werden so wie oben.
	; Folgende Grafik verdeutlicht den Vorgang:
	;
	;
	;				+----------+<----<<--+
	;				| zwsp	   |-->>+    |
	;				+----------+	|    |
	;					     (3)|    |
	;						|    |
	;						|    |
	; Begin banked Bereich -------> +----------+<-<<+    |
	;  (unterer Bereich)	  ^	| page 0   |->>-+    |
	;			 256	+----------+	|    |(1)
	;			  |	| page 1   |	|    |
	;			-----	+----------+	|    |
	;				    ... 	|    |
	;				    ...      (2)|    |
	;				    ... 	|    |
	;				    ... 	|    |
	;				+----------+	|    |
	;				| page n-1 |	|    |
	;				+----------+<-<<+    |
	;  (oberer Bereich)		| page n   |----->>--+
	; End banked Bereich ---------> +----------+
	;
	;
	; Ein Austauschzyklus besteht aus den Schritten:
	;
	; (1) 128 Bytes vom oberen Bereich in den Zwischenspeicher
	; (2) 128 Bytes vom unteren Bereich in den oberen Bereich
	; (3) 128 Bytes vom Zwischenspeicher in den unteren Bereich
	; (4) Pointer unterer Bereich um +128 erhoehen
	;     Pointer oberer Bereich um -128 erniedrigen
	;     (Der Vorgang des Pointerverschiebens erfolgt automatisch
	;      ueber die Pointer der Befehle lddr und ldir.)
	;
	; Es werden also n/2 Vertauschungen gemacht und die Pointer treffen
	; sich genau in der Mitte (oberer Bereich wird mit dem unteren
	; Bereich spiegelverkehrt ausgetauscht). Wobei gilt <bnklen> = n/2.
	; Der Wert aus <bnklen> darf fuer den Austauschvorgang also
	; unveraendert benutzt werden, da hier genau die obere Haelfte mit
	; der unteren Haelfte spiegelverkehrt ausgetauscht wird.

;--------------

loop::
	; HL zeigt auf das letzte Byte des oberen Teils (updown)
	; oberen Teil in den scratch Bereich
	;
	ld	de,zwsptop	; letztes Byte des Zwischenspeichers
	ld	bc,128		; 128 Bytes
	lddr			; transferiere nach zwsp 128 Bytes rueckwaerts

	; hl zeigt auf letztes Byte des vorherigen Sektors

	push	hl		; fuer den naechsten move als zieladresse
				; absichern
	exx

	; HL zeigt auf die source vom unteren Teil (lowup)
	; unteren Bereich in den oberen Bereich verschieben
	;
	push	hl		; wird gleich nochmal benoetigt
	pop	iy		; ins IY
	;
	pop	de
	inc	de		; de zeigt auf ziel
	;
	ld	bc,128		; 128 Bytes
	ldir			; vorwaerts transferieren


	; vom scratchbereich transferieren

	push	iy		; hole pointer auf unteren Bereich (lowup)
	pop	de		; als destination

	ld	hl,zwsp		; scratch Bereich
	ld	bc,128		; 128 Bytes
	ldir

	; DE steht auf naechstem Sektor vom unteren Teil (lowup)

	ex	de,hl		; HL steht auf dem naechsten Sektor.
				; Wird fuer den naechsten move in HL
				; erwartet
	exx

	; Nun sind beide Sektoren vertauscht.
	; HL und HL' stehen jeweils auf den naechsten log Sektor:
	; HL' (um 128 Bytes hoeher)
	; HL  (um 128 Bytes niedriger)

	dec	a		; a--, ist letzter Sektor vertauscht?
	jr	nz,loop		; nein --> loop

;
; Damit liegt der code in der richtigen Reihenfolge vor. Jetzt muss er
; nur noch an die richtige Stelle transferiert werden und ins Bios
; eingesprungen werden.
;

	ld	hl,CPM3SYS+0100h ; Beginn vom CPM3 binary

	ld	a,(ix+reslen)
	add	a,(ix+bnklen)	; Gesammtlaenge <reslen> + <bnklen> berechnen

	add	a,h		; += Offset vom CPM3 Binary
	ld	h,a
	dec	hl		; HL steht auf dem letzten Byte des
				; banked Parts
	ld	d,(ix+bnktop)
	ld	e,0
	dec	de		; DE zeigt auf (<bnktop>*256)-1, also ein
				; Byte vor COMMON Memory

	ld	b,(ix+bnklen)
	ld	c,0		; BC beinhaltet die Laenge vom banked Bereich

	lddr			; und transferieren von oben her


; Damit sollte der Code in der richtigen Reihenfolge an der richtigen
; Position stehen.
; Jetzt CP/M 3 booten (BIOS einspringen):

bootcpm3::
	ld	l,(ix+coldboot)
	ld	h,(ix+coldboot+1)

	jp	(hl)		; und CP/M 3.1 starten


;--------------------------------------------------------------------------
; subroutines
;
; transfere: transferiert up side down den residenten Bereich
transfer::

	;
	; Uebertragen von <A> log. Sektoren (128 Byte Bloecken) von
	; HL-->DE. (upside down)
	;

	ex	de,hl		; Ziel nach HL
	ld	bc,-80H
	add	hl,bc		;
	ex	de,hl		; erster Block
trans1::ld	bc,80H		;  Laenge
	ldir			; uebertragen von HL-->DE
	dec	d		;  Ziel - 100H
	dec	a		; Zaehler
	jr	nz,trans1
	ret

.comment #
callbios::
	ld	(func),a	; bios function number
	;
	ex	af,af'
	ld	(Areg),a
	ld	(BCref),bc
	ld	(DEreg),de
	ld	(HLreg),hl
	;
	ld	de,biospb
	ld	c,50		; Bios func
	call	bdos		; return Address on Stack
	ret

biospb::
func::	db	0
Areg::	db	0
BCref::	dw	0
DEreg::	dw	0
HLreg::	dw	0

;#

PRSTRfunc::
	ld	a,(HL)
	cp	a,'$'
	ret	z		; if ch='$' --> return
	;
	push	hl		; HL wird von conout veraendert
	ld	c,a
	call	conout		; call conout in CP/M-bios or yaze-bios direkt
	pop	hl
	;
	inc	hl		; pointer to the next char
	jr	PRSTRfunc

conout::
	ld	a,(cpmvek)
	or	a,a		; existieren CP/M Vektoren
	jr	z,yaze_conout	; NEIN --> direkt Yaze-conout benutzen

	; conout im Bios aufrufen
	;
	ld	hl,(wbvektor)
	ld	de,3*3		; ab wboot der 3. Vektor
	add	hl,de
	jp	(hl)		; Returnadresse ist auf dem Stack

yaze_conout::
	halt
	db 04			; call conout im yaze-bios
	ret

;--------------------------------------------------------------------------

	; Die folgende Zeile darf nicht veraendert werden, denn
	; dieser wird zum Ueberpruefen der Copyright Message in CPM3.SYS
	; verwendet
CopyDRI::db	'Copyright (C) 1982, Digital Research'
CDRIlen	equ	$

no_xmove_message::
	db	0DH,0AH,' Your CP/M 3.1 bios does not support XMOVE'
	db	' (xmove is not implement) !'
	db	0DH,0AH,0AH
	db	' CP/M 3.1 is running.',0dh,0ah
	db	' To load and start CP/M 3.1 from this file'
	db	' you must run CP/M 2.2 before.',0dh,0ah,0ah
	db	'$'

loadmsg::db	0DH,0AH,' Loading CP/M 3.1 ...',0DH,0AH,'$'

bank1_message::
	db	0dh,0ah
	db	' CP/M 3.1 is already running and bank 1 is selected!'
	db	' Now move all to bank 0 ...',0dh,0ah
	db	'$'

bank0_message::
	db	0dh,0ah
	db	' Now all is transfered and bank 0 is selected'
	db	' -> CPM3.SYS will be loaded. :-)'
	db	0dh,0ah
	db	' (this message comes after a switch from bank 1 to bank 0)'
	db	0dh,0ah
	db	'$'

m_nocopyright::
	db	0DH,0AH
	db	' NO signature found. It seems there is no CPM3.SYS attached.'
	db	13,10
	db	' Use  PIP cpm3.com=bootsys.com,CPM3.SYS  to attach a'
	db	' CPM3.SYS.',0dh,0ah,0ah
	db	'$'

cpmvek::	db	0	; Muss 0 sein, wird so erwartet !!!
wbvektor::	dw	0	; Adresse des Warmboots

	ds	10,0AAH		; initialized is better
lstack:: equ	$		; for the next instruction


CPM3SYS::	equ	($ AND 0FF80H) + 0080H
	; damit faengt CPM3.SYS auf einer 80H Pagegrenze an


	end
