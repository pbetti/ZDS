;************************************************************************
;    FIFO BUFFERS FOR CP/M BIOS
;
; The following code by Glenn Ewing and Bob Richardson
; This code Copyright (c) 1981 MicroPro International Corp.
; made available by permission of the authors
;
;	The fifo input and output routines provide no protection
;	from underflow and overflow.  The calling code must use
;	the fstat routine to ensure that these conditions are
;	avoided.  Also, the calling code must enable and disable
;	interupts as appropriate to ensure proper maintainance of
;	the variables.
;
;; FSTAT
;; routine to determine status (fullness) of a buffer.
;; enter with IX = adr of cnt.
;; return Z-flag set if buffer empty, C-flag set if buffer full.
;; note that buffer capacity is actually size-1.
;
fstat:
	ld	a, (ix + 0)		; get cnt
	push	de
	ld	e, (ix + 2)		; get mask
	and	e			; cnt = cnt mod size
	dec	e			; e = size - 2
	cp	e			; test for full
	pop	de
	inc	a			; clear z leaving cy
	dec	a
	ccf
	ret
;
;; FIN
;; routine to enter a character into a buffer.
;; enter with C=chr, IX=.cnt
fin:
	ld	a, (ix + 0)		; compute: (cnt + nout) mod size
	inc	(ix + 0)		; first update cnt
	add	a, (ix + 1)
	and	(ix + 2)
	push	de
	ld	e, a			; compute base + nin
	ld	d, 0
	inc	ix
	inc	ix
	inc	ix
	add	ix, de
	pop	de
	ld	(ix+0), c		; store character
	ret
;
;; FOUT
;; routine to retreve a character from a buffer.
;; enter with IC=.cnt
;; return with C=chr
;
fout:
	dec	(ix + 0)		; update cnt
	ld	a, (ix + 1)		; compute: base + nout
	inc	(ix + 1)
	and	(ix + 2)
	push	de
	ld	e, a
	ld	d, 0
	inc	ix
	inc	ix
	inc	ix
	add	ix, de
	pop	de
	ld	c, (ix + 0)		; get chr
	ret

;************************************************************************

