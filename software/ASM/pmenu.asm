;----------------------------------------------------------------
;        This is a module in the ASMLIB library
;
; Print a menu. This is complicated in so far as it uses a lot  *
; of cursor positioning codes and assumes that the menu strings * 
; contain cursor position codes. The end of the menu must be    *
; signalled by a double dollar sequence.			*
;								*
;			Written     	R.C.H.     16/8/83	*
;			Last Update	R.C.H.	   22/10/83	*
;----------------------------------------------------------------
;
	name	'pmenu'
;
	public	pmenu
	extrn	xypstring
	maclib	z80
;
pmenu:
	push	d			; save all
	push	psw
pmenu2:
	call	xypstring		; print the string.
	ldax	d			; is the next character a dollar ?
	cpi	0ffh			; end of menu ??
	jrnz	pmenu2
	pop	psw
	pop	d
	ret
;
	end

