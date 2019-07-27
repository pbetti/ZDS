; The following is from the first part of TCSELE30 - it is provided to allow
; patching of the TCSELE30 options.  Full source and CFG file will be released
; in the next few weeks.
;
; TCSELCECT - Display a menu of available extended TCAPs, allowing the user
;  to choose the appropriate one to be loaded to the ENV.  Will also allow
;  "testing" of an installed TCAP on the user's terminal, as well as installing
;  the TCAP into a .Z3T file or . . . a program supporting Jay Sage's proposed
;  TCAP header.
;
; Credit for the concept behind this program goes to Chris McEwen, Jay Sage, 
; and Ian Cottrell.
;
; Since I make no claim to the concept behind this program, I can't very well
; claim a copyright on it, can I?  Therefore, this is released into the public
; domain.  I will ask that if you choose to modify and re-release it that you
; check with one of the above first.  If something is done one way, there is
; probably a good reason.  (At least, there should be.)  See the explanation
; down-code as to why I can't clear the screen on startup -- even if a TCAP is
; present.
;
; Usage:
;   TCSELECT                   menu-driven TCap selection/installation
;   TCSELECT -filename         menu-driven selection, install into filename.COM
;*  TCSELECT 12                load terminal #12's definition into ENV
;*  TCSELECT TVI914            load TVI914.Z3T into ENV
;   TCSELECT -filename 12      load terminal #12's definition into filename.COM
;   TCSELECT -filename TVI914  load TVI914.Z3T into filename.COM
;   TCSELECT //                display this message
;
; *'d items require ZCPR3, others will work under CP/M 2.2, 3.0 and ZCPR3
; options to install .COM files will only work under Z3 if the wheel byte is
; set.  They will ALWAYS work under CP/M (though I may change this).
;
; On ZCPR3 systems, the terminal selected is returned in Register 0,
;  (configurable).
;
; Version 3.0c  bem Added confirmation for terminal selection per Ian's request.
;
; Version 3.0b  bem Fixed some odd bugs
;
; Version 3.0a  Brian Moore   Rewrite from scratch of Richard Conn's
;    original program.
;
; Misc ASCII equates
cr		equ	'M'-40h
lf		equ	'J'-40h

		.z80
		cseg

		jp	start
envstring:	db	'Z3ENV'		; Look for this in other programs.
		db	1		;  this, too
env:		dw	0		;
		dw	100h		; for type-3 compatibility
		db	'TCSELE30'	; ZCNFG filename
		db	0		; null for end of string
;----------------------------------------
; The following will be installable via ZCNFG when I get a round tuit.
;----------------------------------------
TermReg:	db	0		; Register for returning term number
TCAPpath:	db	1		; use path for library if Z3
Z3Ttype:	db	'Z3T'		; file type for tcaps
COMtype:	db	'COM'		; (may be a weirdo...)
TCAPLBRUser:	db	4		;  user/ for TCAP library
TCAPLBRDrive:	db	1		;    drive
TCAPLIBNAME:	db	'Z3TCAP  LBR'	; <--- name of TCAP file
TCAPmenu:	db	'TCAPMENUTXT'	; <--- name of menu within file
ConfirmFlag:	db	1		; confirm TCAP choice
;----------------------------------------
