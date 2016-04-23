;
;********************************************************
;*							*
;*	    UNIVERSAL BASIC I/O SYSTEM (BIOS)		*
;*							*
;*           memory size and SONE allocation		*
;*							*
;********************************************************
;
;	Programmers: Martino Stefano & Gallarani Paolo
	; Disassembly/retype Pino Giaquinto & Piergiorgio Betti 2015/04/25
;
;********************************************************
;*		MEMORY SIZING				*
;********************************************************
;
; msize	equ	56			; CP/M memory size in kilobyte
	include	msize.asm		; read in ram size
mres	equ	1			; reserved mem in kilobyte
;
;********************************************************
;*		SYSTEM CONSTANTS			*
;********************************************************
;
cmsize	equ	msize-mres		; cp/m size in kbyte
;
;	bias is address offset from 3400h for memory system
;	than 16k (referred to as "b" throughout the next)
;
bias	equ	(cmsize-20)*1024;
ccp	equ	3400h+bias		; base of ccp
bdose	equ	ccp+800h		; start of bdos
bdos	equ	ccp+806h		; base of bdos
bios	equ	ccp+1600h		; base of bios
ipl	equ	1000h			; ipl origin
;
; EOF
