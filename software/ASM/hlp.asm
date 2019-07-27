;----------------------------------------------------------------
; This is a program to display help files on the screen in an
; orderly manner.
; The user is able to specify a section number which will be
; indexed to and the text at that place in the help file will
; be displayed.
; The user is also to move up and down the help levels so that
; different messages are displayed. A global belp display of all
; the index sections is displayed is also available.
;
; In the index file the following codes are used.
; ::    is a section start
; :P    is a page end
; :N    is a page end and continue to next section
; :L    is a page end and proceed to last section
;
;                                 Written       R.C.H.   02/11/83
;				  Last Update	R.C.H.	 05/11/83
;----------------------------------------------------------------
;
	org	0100h
	maclib	z80
;
; operating system equates.
;
bdos	equ	05
open	equ	15		; open file
sread	equ	20		; sequential file read
rread	equ	33		; random file read
sdma	equ	26		; set dma address
srrec	equ	36		; set random record
buffin	equ	10		; read console buffer
pstring	equ	09		; print a string till a $
buffer	equ	01000h		; start of disk buffer
bufsiz	equ	128		; size of the file text buffer
stack	equ	0fffh		; stack space
;
; Help file equates
;
section	equ	':'		; section start
;
	lxi	sp,stack	; set up
	lxi	d,signon
	call	print
;
; Here we initialize the help FCB for sequential reading to extract the 
; keys to be saved in the table
;
	lxi	d,buffer
	sded	curdma
	mvi	c,sdma
	call	bdos		; set up dma buffer
	lxi	d,fcb		; point to it
	mvi	c,open		; open the file
	call	bdos		; do it
	cpi	255		; failed
	jz	not$found
;
; Here and the files' sector should be in the current dma area
; Now we run through the file and extract all the section start
; codes.
;
key$start:
	call	getchr		; get a character
	jz	key$end		; end of key extraction = end of file
	cpi	section		; is it a section start ??
	jnz	key$start	; keep on then
;
; Here we use the section counter to save the sector number and character
; index of the section start in the table of keys.
;
	lda	curcol		; get current column number
	cpi	1		; are we in column 1 ?
	jrnz	key$start	; if not in col 1 then ignore
;
; Since a start of section begins with '::' we must read the next file
; character to make sure wo where we are
;
	call	getchr		; get the character
	jz	key$end		; exit if end of file
	cpi	section		; is it a second ':' ??
	jrnz	key$start
;
; If we are here then we are at a new section signalled by a '::' pair of 
; characters.
;
	lda	cursct		; get current section number
	mov	e,a		; save in an indexing register
	inr	a
	sta	cursct
	lxi	h,keytab	; point to start of key table
	mvi	d,00		; clear offset
	dad	d
	dad	d
	dad	d		; add 3 times the section number
; Here HL -> to the start of the 3 byte table entry
	lded	cursec		; get the current sector number
	mov	m,e		; save low byte first
	inx	h
	mov	m,d		; save high byte next
; Lastly we save the offset into the sector of the start of the section
	inx	h
	lda	chrcnt		; get character count as an offset
	mov	m,a		; save it, this is the offset into the buffer
;
; Now we may return to the reading and checking loop
	jmp	key$start
;
;
; Here is jumped to when the end of file is reached. We assume that all 
; the sections have been found and their indicies have been loaded into 
; the key table. Now we can use the number that the user has entered to 
; index into the table and then to index into the help file.
;
;
key$end:
	mvi	a,1
	sta	reqinx		; save for now
	lda	reqinx		; get requested index number
; check if index number too low
	ora	a		; is it 00 ?
	jz	low$inx		; index 0 not allowed
; check if index number too large
	mov	e,a		; save index #
	lda	cursct		; get the last index section number
	cmp	e		; carry if request > current index
	jc	hi$inx
	mov	a,e		; restore
; All is well. We may use the table data to index into the file
; to read the data as requested by the user.
;
; Here A = the index number.
	call	getinx
; Now the sector buffer should be filled with the data from disk
; and the character pointers corrected to index into the data immediately
; after the index marker.
;
lp2:
	call	getchr
	jz	finish		; end on file end
; display the data
	mov	e,a
	mvi	c,2		; display code
	call	bdos
	jmp	lp2
;
;----------------------------------------------------------------
; This is a central routine that returns either the next character from 
; the text file or a zero flag if end of file. If the sector buffer is 
; empty then the next sector must be read, ad infinitum.
;----------------------------------------------------------------
;
getchr:
	lda	chrcnt		; get a count of character left in the buffer
	ora	a
	jz	fill$buff	; buffer is empty if none left
; Here and we can decrement the counter, restore it, get a character etc.
	dcr	a
	sta	chrcnt		; restore
	lhld	curchr		; get character pointer
	mov	a,m
	inx	h		; point to next character
	shld	curchr		; save 
	cpi	01ah		; end of text file ??
	jrnz	up$col		; if not the update the column number
	xra	a		; clear accumulator if end of file
	ret
;
; This routine must save the character in the accumulator and return it to
; the user after updating the column number.
;
up$col:
	push	psw		; save the character
	cpi	0dh
	jrz	new$lin
	cpi	0ah
	jrz	new$lin
	lda	curcol		; get current column
	inr	a
up$col2:
	sta	curcol
	pop	psw
	ret
;
; If a new line the clear the character counter
new$lin:
	xra	a
	jr	up$col2
;
; here must read the next sector into the sector buffer, update 
; pointers and counters then return to read another character
;
fill$buff:
; Bump the sector counter before anything else
	lhld	cursec
	inx	h
	shld	cursec
; set up dma address
	lded	curdma		; set up DMA address
	mvi	c,sdma
	call	bdos
; read file next
	lxi	d,fcb
	mvi	c,sread		; sequential read operation required
	call	bdos		; read the sector
	ora	a		
	jnz	fill$end	; if not zero then end of file
; Here and we restore the counters and pointers then return
fill$buff2:
	mvi	a,bufsiz	; 1 sector loaded
	sta	chrcnt		; save the counter
	lhld	curdma
	shld	curchr		; point to first character
	jmp	getchr   	; return to get a character from the start
;
; Here and the end of the file was encountered.
;
fill$end:	; fill the sector with eof characters
	lhld	curdma
	mvi	m,01ah
	lded	curdma
	inx	d
	lxi	b,127		; clear the rest of the buffer
	ldir			; shift the end of file character along
	jmp	fill$buff2	; restore pointers and return
;
; This routine must use the index number that points into the table to
; read the help file and then position the character pointer immediately after
; the start of index character.
; The index number is assumed to be contained in A
;
getinx:
	lxi	h,keytab	; point to the table
	dcr	a		; normalize the index value
	mov	e,a
	mvi	d,00		; load the offset
	dad	d
	dad	d
	dad	d		; point into the table
; Extract the sector number
	mov	e,m
	inx	h
	mov	d,m		
; Now we need to save the offset to the index start for later use
	inx	h
	mov	a,m
	sta	chrcnt		; Save the offset as a pointer
; We need to also update the character pointer
	lhld	curdma
	mov	c,a
	mvi	b,00
	dad	b
	shld	curchr
; Now we seek to the sector and read it into the buffer
	call	seek		; Go to the sector
	ret
;
; This routine must seek the head to a sector number contained in DE
; and must read data into the sector buffer.
;
seek:
	lxi	h,fcb+33	; sector number field
	mov	m,e		; set up low sector number
	inx	h
	mov	m,d		; set up high byte
; Set up DMA
	lded	curdma
	mvi	c,sdma
	call	bdos		; set up 
; Random read the sector
	mvi	c,rread		; do a random read
	lxi	d,fcb
	call	bdos
; Test error values of return code
	ora	a
	rz			; success
	jz	rr$error
;
;----------------------------------------------------------------
; Display a signoff message and go back to o.s.
;----------------------------------------------------------------
;
finish:
	lxi	d,signoff
	call	print
	jmp	quit
;
;----------------------------------------------------------------
;             Error routines for all occurrences
;----------------------------------------------------------------
;
not$found:
	lxi	d,err2
	call	print
	jmp	quit		; abort 
;
low$inx:
	lxi	d,err3
	call	print
	jmp	quit
;
hi$inx:
	lxi	d,err4
	call	print
	jmp	quit
;
rr$error:
	lxi	d,err5
	call	print
	jmp	quit
;
;
quit:
	jmp	0h
;
; error messages as per p-coded listing
;
err1:	db	'Non initialized help system$'
err2:	db	'File not found$'
err3:	db	'Index 00 not allowed$'
err4:	db	'Index too large$'
err5:	db	'Random record seek error$'
;
; Simple screen messages
;
signon:
	db	'Help file reader starting$'
signoff:
	db	'Help file reader terminating$'
;
;
print:	; Print a string till a $
	push	d
	push	b
	push	h
	mvi	c,pstring
	call	bdos
	pop	h
	pop	b
	pop	d
	ret
;
;
fcb	db	00,'HELP    HLP',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	00
;
; The following are variables used to read the file and keep
; track of data.
;
reqinx	db	00		; requested index or current index no
beginx	db	00		; Beginning index offset from sector start
cursct	db	00		; current section number
curdma	db	00,00		; current DMA address
cursec	db	00,00		; current sector number
curchr	db	00,00		; current character address
curcol	db	00		; current column number
chrcnt	db	00		; count to 00 of sectors in the buffer
;
; The following is a table of keys which are the sector
; numbers where a section of the help file was found.
; This is enough for 32 3 byte keys to be saved.
;
; Format is 2 bytes = sector number
;           1 byte  = offset into sector for section start
;
keytab:
	db	00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
	db	00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
	db	00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
	db	00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
	db	00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
	db	00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
;
	end



