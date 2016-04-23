	title 'Character I/O handler for the N8VEM SBC'

; Character I/O for the Modular CP/M 3 BIOS
; Updated for the N8VEM SBC by Max Scane AUG 2009
;
; Need to add the Peripherals card here as well as the VDU card
;


	public	?cinit,?ci,?co,?cist,?cost
	public	@ctbl

	maclib Z80	; define Z80 op codes
	; maclib ports	; define port addresses
	maclib modebaud	; define mode bits and baud equates

max$devices	equ 6
uart		equ	68h		; N8VEM 16550 UART
	cseg

?cinit:
	ret			; not supported as yet


?ci:		; character input


	call 	?cist
	jz 		?ci		; wait for character ready
	in		UART

	ani 7Fh				; mask parity
	ret

null$input:
	mvi a,1Ah			; return a ctl-Z for no device
	ret

?cist:		; character input status
	in		UART+05h
	ani		1
    rz
    ori     0ffh
    ret
	

null$status:
	xra a ! ret


	
?co:		; character output
	call	?cost
	jz		?co
	mov		a,c
	out		UART
	ret	


null$output:
	ret


?cost:		; character output status

	in		UART + 05h		; N8VEM UART
	ani		20h
	rz
	mvi		a,0ffh
	ret






@ctbl	db 'CRT   '	; device 0, CRT port 0
	db mb$in$out+mb$serial+mb$softbaud
	db baud$9600
	db	0

	end
