
	.Z80
	ASEG

;*****************************************************
;*                                                   *
;*      Sector Deblocking Algorithms for CP/M 2.0    *
;*                                                   *
;*****************************************************
;
;	utility macro to compute sector mask
SMASK	MACRO	HBLK
;;	compute log2(hblk), return @x as result
;;	(2 ** @x = hblk on return)
@Y	DEFL	HBLK
@X	DEFL	0
;;	count right shifts of @y until = 1
	REPT	8
	IF	@Y = 1
	EXITM	
	ENDIF	
;;	@y is not 1, shift right one position
@Y	DEFL	@Y SHR 1
@X	DEFL	@X + 1
	ENDM	
	ENDM	
;
;*****************************************************
;*                                                   *
;*         CP/M to host disk constants               *
;*                                                   *
;*****************************************************
BLKSIZ	EQU	2048		;CP/M allocation size
HSTSIZ	EQU	512		;host disk sector size
HSTSPT	EQU	20		;host disk sectors/trk
HSTBLK	EQU	HSTSIZ/128	;CP/M sects/host buff
CPMSPT	EQU	HSTBLK * HSTSPT	;CP/M sectors/track
SECMSK	EQU	HSTBLK-1	;sector mask
	SMASK	HSTBLK		;compute sector mask
SECSHF	EQU	@X		;log2(hstblk)
;
;*****************************************************
;*                                                   *
;*        BDOS constants on entry to write           *
;*                                                   *
;*****************************************************
WRALL	EQU	0		;write to allocated
WRDIR	EQU	1		;write to directory
WRUAL	EQU	2		;write to unallocated
;
;*****************************************************
;*                                                   *
;*	The BDOS entry points given below show the   *
;*      code which is relevant to deblocking only.   *
;*                                                   *
;*****************************************************
;
;	DISKDEF macro, or hand coded tables go here
DPBASE	EQU	$		;disk param block base
;
BOOT:
WBOOT:
	;enter here on system boot to initialize
	XOR	A		;0 to accumulator
	LD	(HSTACT),A	;host buffer inactive
	LD	(UNACNT),A	;clear unalloc count
	RET	
;
HOME:
	;home the selected disk
HOME:
	LD	A,(HSTWRT)	;check for pending write
	OR	A
	JP	NZ,HOMED
	LD	(HSTACT),A	;clear host active flag
HOMED:
	RET	
;
SELDSK:
	;select disk
	LD	A,C		;selected disk number
	LD	(SEKDSK),A	;seek disk number
	LD	L,A		;disk number to HL
	LD	H,0
	REPT	4		;multiply by 16
	ADD	HL,HL
	ENDM	
	LD	DE,DPBASE	;base of parm block
	ADD	HL,DE		;hl=.dpb(curdsk)
	RET	
;
SETTRK:
	;set track given by registers BC
	LD	H,B
	LD	L,C
	LD	(SEKTRK),HL	;track to seek
	RET	
;
SETSEC:
	;set sector given by register c
	LD	A,C
	LD	(SEKSEC),A	;sector to seek
	RET	
;
SETDMA:
	;set dma address given by BC
	LD	H,B
	LD	L,C
	LD	(DMAADR),HL
	RET	
;
SECTRAN:
	;translate sector number BC
	LD	H,B
	LD	L,C
	RET	
;
;*****************************************************
;*                                                   *
;*	The READ entry point takes the place of      *
;*	the previous BIOS defintion for READ.        *
;*                                                   *
;*****************************************************
READ:
	;read the selected CP/M sector
	XOR	A
	LD	(UNACNT),A
	LD	A,1
	LD	(READOP),A	;read operation
	LD	(RSFLAG),A	;must read data
	LD	A,WRUAL
	LD	(WRTYPE),A	;treat as unalloc
	JP	RWOPER		;to perform the read
;
;*****************************************************
;*                                                   *
;*	The WRITE entry point takes the place of     *
;*	the previous BIOS defintion for WRITE.       *
;*                                                   *
;*****************************************************
WRITE:
	;write the selected CP/M sector
	XOR	A		;0 to accumulator
	LD	(READOP),A	;not a read operation
	LD	A,C		;write type in c
	LD	(WRTYPE),A
	CP	WRUAL		;write unallocated?
	JP	NZ,CHKUNA	;check for unalloc
;
;	write to unallocated, set parameters
	LD	A,BLKSIZ/128	;next unalloc recs
	LD	(UNACNT),A
	LD	A,(SEKDSK)	;disk to seek
	LD	(UNADSK),A	;unadsk = sekdsk
	LD	HL,(SEKTRK)
	LD	(UNATRK),HL	;unatrk = sectrk
	LD	A,(SEKSEC)
	LD	(UNASEC),A	;unasec = seksec
;
CHKUNA:
	;check for write to unallocated sector
	LD	A,(UNACNT)	;any unalloc remain?
	OR	A
	JP	Z,ALLOC		;skip if not
;
;	more unallocated records remain
	DEC	A		;unacnt = unacnt-1
	LD	(UNACNT),A
	LD	A,(SEKDSK)	;same disk?
	LD	HL,UNADSK
	CP	(HL)		;sekdsk = unadsk?
	JP	NZ,ALLOC	;skip if not
;
;	disks are the same
	LD	HL,UNATRK
	CALL	SEKTRKCMP	;sektrk = unatrk?
	JP	NZ,ALLOC	;skip if not
;
;	tracks are the same
	LD	A,(SEKSEC)	;same sector?
	LD	HL,UNASEC
	CP	(HL)		;seksec = unasec?
	JP	NZ,ALLOC	;skip if not
;
;	match, move to next sector for future ref
	INC	(HL)		;unasec = unasec+1
	LD	A,(HL)		;end of track?
	CP	CPMSPT		;count CP/M sectors
	JP	C,NOOVF		;skip if no overflow
;
;	overflow to next track
	LD	(HL),0		;unasec = 0
	LD	HL,(UNATRK)
	INC	HL
	LD	(UNATRK),HL	;unatrk = unatrk+1
;
NOOVF:
	;match found, mark as unnecessary read
	XOR	A		;0 to accumulator
	LD	(RSFLAG),A	;rsflag = 0
	JP	RWOPER		;to perform the write
;
ALLOC:
	;not an unallocated record, requires pre-read
	XOR	A		;0 to accum
	LD	(UNACNT),A	;unacnt = 0
	INC	A		;1 to accum
	LD	(RSFLAG),A	;rsflag = 1
;
;*****************************************************
;*                                                   *
;*	Common code for READ and WRITE follows       *
;*                                                   *
;*****************************************************
RWOPER:
	;enter here to perform the read/write
	XOR	A		;zero to accum
	LD	(ERFLAG),A	;no errors (yet)
	LD	A,(SEKSEC)	;compute host sector
	REPT	SECSHF
	OR	A		;carry = 0
	RRA			;shift right
	ENDM	
	LD	(SEKHST),A	;host sector to seek
;
;	active host sector?
	LD	HL,HSTACT	;host active flag
	LD	A,(HL)
	LD	(HL),1		;always becomes 1
	OR	A		;was it already?
	JP	Z,FILHST	;fill host if not
;
;	host buffer active, same as seek buffer?
	LD	A,(SEKDSK)
	LD	HL,HSTDSK	;same disk?
	CP	(HL)		;sekdsk = hstdsk?
	JP	NZ,NOMATCH
;
;	same disk, same track?
	LD	HL,HSTTRK
	CALL	SEKTRKCMP	;sektrk = hsttrk?
	JP	NZ,NOMATCH
;
;	same disk, same track, same buffer?
	LD	A,(SEKHST)
	LD	HL,HSTSEC	;sekhst = hstsec?
	CP	(HL)
	JP	Z,MATCH		;skip if match
;
NOMATCH:
	;proper disk, but not correct sector
	LD	A,(HSTWRT)	;host written?
	OR	A
	CALL	NZ,WRITEHST	;clear host buff
;
FILHST:
	;may have to fill the host buffer
	LD	A,(SEKDSK)
	LD	(HSTDSK),A
	LD	HL,(SEKTRK)
	LD	(HSTTRK),HL
	LD	A,(SEKHST)
	LD	(HSTSEC),A
	LD	A,(RSFLAG)	;need to read?
	OR	A
	CALL	NZ,READHST	;yes, if 1
	XOR	A		;0 to accum
	LD	(HSTWRT),A	;no pending write
;
MATCH:
	;copy data to or from buffer
	LD	A,(SEKSEC)	;mask buffer number
	AND	SECMSK		;least signif bits
	LD	L,A		;ready to shift
	LD	H,0		;double count
	REPT	7		;shift left 7
	ADD	HL,HL
	ENDM	
;	hl has relative host buffer address
	LD	DE,HSTBUF
	ADD	HL,DE		;hl = host address
	EX	DE,HL		;now in DE
	LD	HL,(DMAADR)	;get/put CP/M data
	LD	C,128		;length of move
	LD	A,(READOP)	;which way?
	OR	A
	JP	NZ,RWMOVE	;skip if read
;
;	write operation, mark and switch direction
	LD	A,1
	LD	(HSTWRT),A	;hstwrt = 1
	EX	DE,HL		;source/dest swap
;
RWMOVE:
	;C initially 128, DE is source, HL is dest
	LD	A,(DE)		;source character
	INC	DE
	LD	(HL),A		;to dest
	INC	HL
	DEC	C		;loop 128 times
	JP	NZ,RWMOVE
;
;	data has been moved to/from host buffer
	LD	A,(WRTYPE)	;write type
	CP	WRDIR		;to directory?
	LD	A,(ERFLAG)	;in case of errors
	RET	NZ		;no further processing
;
;	clear host buffer for directory write
	OR	A		;errors?
	RET	NZ		;skip if so
	XOR	A		;0 to accum
	LD	(HSTWRT),A	;buffer written
	CALL	WRITEHST
	LD	A,(ERFLAG)
	RET	
;
;*****************************************************
;*                                                   *
;*	Utility subroutine for 16-bit compare        *
;*                                                   *
;*****************************************************
SEKTRKCMP:
	;HL = .unatrk or .hsttrk, compare with sektrk
	EX	DE,HL
	LD	HL,SEKTRK
	LD	A,(DE)		;low byte compare
	CP	(HL)		;same?
	RET	NZ		;return if not
;	low bytes equal, test high 1s
	INC	DE
	INC	HL
	LD	A,(DE)
	CP	(HL)		;sets flags
	RET	
;
;*****************************************************
;*                                                   *
;*	WRITEHST performs the physical write to      *
;*	the host disk, READHST reads the physical    *
;*	disk.					     *
;*                                                   *
;*****************************************************
WRITEHST:
	;hstdsk = host disk #, hsttrk = host track #,
	;hstsec = host sect #. write "hstsiz" bytes
	;from hstbuf and return error flag in erflag.
	;return erflag non-zero if error
	RET	
;
READHST:
	;hstdsk = host disk #, hsttrk = host track #,
	;hstsec = host sect #. read "hstsiz" bytes
	;into hstbuf and return error flag in erflag.
	RET	
;
;*****************************************************
;*                                                   *
;*	Unitialized RAM data areas		     *
;*                                                   *
;*****************************************************
;
SEKDSK:	DEFS	1		;seek disk number
SEKTRK:	DEFS	2		;seek track number
SEKSEC:	DEFS	1		;seek sector number
;
HSTDSK:	DEFS	1		;host disk number
HSTTRK:	DEFS	2		;host track number
HSTSEC:	DEFS	1		;host sector number
;
SEKHST:	DEFS	1		;seek shr secshf
HSTACT:	DEFS	1		;host active flag
HSTWRT:	DEFS	1		;host written flag
;
UNACNT:	DEFS	1		;unalloc rec cnt
UNADSK:	DEFS	1		;last unalloc disk
UNATRK:	DEFS	2		;last unalloc track
UNASEC:	DEFS	1		;last unalloc sector
;
ERFLAG:	DEFS	1		;error reporting
RSFLAG:	DEFS	1		;read sector flag
READOP:	DEFS	1		;1 if read operation
WRTYPE:	DEFS	1		;write operation type
DMAADR:	DEFS	2		;last dma address
HSTBUF:	DEFS	HSTSIZ		;host buffer
;
;*****************************************************
;*                                                   *
;*	The ENDEF macro invocation goes here	     *
;*                                                   *
;*********