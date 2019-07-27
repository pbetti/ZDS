;----------------------------------------------------------------
;        This is a module in the ASMLIB library
; This module allows the operator to switch output for the screen 
; to any of the printer/onsole combinations.
;
;			Written     	R.C.H.     16/8/83
;			Last Update	R.C.H.	   31/12/83
;
; Make code non-self-modifying.			  R.C.H.    30/9/83
; Added ? to destbyte				  R.C.H.    31/12/83
;----------------------------------------------------------------
;
	name	'switchio'
;
	public	echolst,listout,consout
	extrn	?destbyte
	maclib	z80
;
;----------------------------------------------------------------
; Enable output to go to the list device as well as the screen
;----------------------------------------------------------------
;
echolst:
	mvi	a,2
	jr	put$dest		; enable list device
;
;----------------------------------------------------------------
; 	Send all output meant for the screen to the printer.
;----------------------------------------------------------------
;
listout:
	mvi	a,1
	jr	put$dest		; enable list driver
;
;----------------------------------------------------------------
;     Re-select output to go to the list device.
;----------------------------------------------------------------
;
consout:
	xra	a
;
; FALL THROUGH to enable the console device driver
; This works by loading the device destination byte (DESTBYTE) with the
; value of the output device required.
;
put$dest:
	sta	?destbyte
	ret
;
	end


