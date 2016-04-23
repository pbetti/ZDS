;----------------------------------------------------------------
;        This is a module in the ASMLIB library
;
; This is the root module for the ASMLIB library and provides storage
; that is used by other modules. The user must call this routine in
; order to gain access to most other modules in ASMLIB. This module
; also contains code to exit to the O.S. 
;
;			Written     	R.C.H.     16/8/83
;			Last Update	R.C.H.	   02/04/84
;
; Added data equates and initialized stack space	    30/9/83
; Added ? to global data bytes				    31/12/83
;----------------------------------------------------------------
;
	name	'prolog'
;
	public	prolog,quit,version	; entry points
; Storage for all....
	public	?blank,?lzbflg,?lzbchr,?result,?binnum
	public	?stack,?ccp$stack,?destbyte
	public	datstart,datend
;
libver	equ	0106h		; Version 1 release 5
bdos	equ	5
;
;----------------------------------------------------------------
; Set up stack and get operating system version.
;----------------------------------------------------------------
;
prolog:
	pop	b			; Fetch return address
	lxi	h,0			
	dad	sp			; GET CP/M stack address
	shld	?ccp$stack		; save the address for later
; Load local internal stack for 64 levels
	lxi	sp,?stack		; simple hey
	push	b			; Save the return address to caller
	ret				; back to the user.
;
;----------------------------------------------------------------
;     Exit from this program back to the operating system.
;----------------------------------------------------------------
;
quit:
	lhld	?ccp$stack
	sphl
	ret				; direct return to CP/M
;
;----------------------------------------------------------------
; Get the internal version number of this library.
;----------------------------------------------------------------
;
version:
	lxi	h,libver
	ret
;
;----------------------------------------------------------------
; 		    Data atorage areas.
;----------------------------------------------------------------
;
	dseg
;
datstart:				; Start of data areas
	db	'SSSSSSSSSSSSSSSS'	; 16 bytes of stack
	db	'SSSSSSSSSSSSSSSS'	; 32 bytes of stack
	db	'SSSSSSSSSSSSSSSS'	; 48 bytes of stack
	db	'SSSSSSSSSSSSSSSS'	; 64 bytes of stack
	db	'SSSSSSSSSSSSSSSS'	; 80 bytes of stack
	db	'SSSSSSSSSSSSSSSS'	; 96 bytes of stack
	db	'SSSSSSSSSSSSSSSS'	; 112 bytes of stack
	db	'SSSSSSSSSSSSSSSS'	; 128 bytes of stack
?stack:
	db	00
?blank:	db	00
osver	db	00,00
?lzbflg	db	00
?lzbchr	db	00
?result	db	00,00,00,00,00,00,00
?binnum	db	00,00
?destbyte	
	db	00			; Selects dispatched output devices
?ccp$stack
	db	00,00
datend:
;
	end




