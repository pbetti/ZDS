;
; ZDB23.D - Data Module
;
srtfnm:	dc	'SORTED.$$$'	; Temporary file name for sort file
bakfil:	dc	'BACKUP.DTA'	; Backup file name
defft:	db	'DTA'		; Default datafile filetype
adrtyp:	db	'ADR'		; ASCII Address filetype
cdftyp:	db	'CDF'		; Comma-delimited filetype
wstyp:	db	'WSF'		; WordStar filetype
ziptyp:	db	'ZIP Code '	; Zip code index message
lntyp:	db	'Last Name'	; Last name index message
kamsg:	dc	' K=Key S=Skip A=All'
;
; Field title panel
;
panel:	db	15		; Number of elements
	db	01,01,1,'ZDB vers ',vers/10+ '0','.',vers mod 10 +'0'
	db	suffix
	db	2,0
	db	01,22,1
datafil:db	'                ',2,0
inxmsg:	db	03,15,'Index >',1
inxtyp:	db	'Last Name ',2,0 ; Default index is last name
	dc	03,49,'Last modified >'
	dc	06,10,'First Name >'
	dc	07,11,'Last Name >'
	dc	08,11,'Address 1 >'
	dc	09,11,'Address 2 >'
	dc	10,16,'City >'
	dc	11,15,'State >'
	dc	12,17,'Zip >'
	dc	13,13,'Country >'
	dc	15,15,'Phone >'
	dc	17,10,'Comments 1 >'
	dc	18,10,'Comments 2 >'
;
; Cursor positions for record display fields
;
pospanel:
	db	11		; Number of fields
	db	06,22,fslen	; Fstnm
	db	07,22,lnlen	; Lname
	db	08,22,a1len	; Addr1
	db	09,22,a2len	; Addr2
	db	10,22,cilen	; City
	db	11,22,stlen	; State
	db	12,22,zilen	; Zip
	db	13,22,ctlen	; Ctry
	db	15,22,phlen	; Phon
	db	17,22,c1len	; Cmnts1
	db	18,22,c2len	; Cmnts2
;
; Addresses of record buffer fields
;
afpnl:	dw	fstnm
	dw	lname
	dw	addr1
	dw	addr2
	dw	city
	dw	state
	dw	zip
	dw	ctry
	dw	phon
	dw	cmnts1
	dw	cmnts2
	dw	datmod
;
; Termination table for address fields
;
patbl:	dw	dospace		; First name
	dw	nline		; Last name
	dw	neline		; Address1
	dw	neline		; Address2
	dw	dospace		; City
	dw	dospace		; State
	dw	nline		; Zip
	dw	neline		; Country
;
; Addresses of return address record buffer fields
;
rafpnl:	dw	rafn
	dw	raln
	dw	radr1
	dw	radr2
	dw	racty
	dw	rast
	dw	razip
	dw	ractry
;
; Termination table for return address fields
;
rapatbl:dw	dospace		; First name
	dw	lcrlf		; Last name
	dw	docmasp		; Address1
	dw	lcrlf		; Address2
	dw	dospace		; City
	dw	dospace		; State
	dw	dospace		; Zip
	dw	lcrlf		; Country
;
; Sort Specification Block for use with SORT
;
ssb:
first:	dw	0		; Address of the first record
n:	dw	0		; Number of records
size:	dw	16		; Length of each record
comp:	dw	compv		; Address of our compare routine
order:	dw	0		; Address of the order table
point:	db	on		; On to use pointers
norec:	db	0		; On to only sort pointers
;
; Uninitialized data area
;
	dseg
;
; Zip barcode buffer
;
barcod:	ds	buflen		; Barcode buffer
chksum:	ds	1		; Checksum digit
;
; Initialize the following data area at startup
;
data:				; Start of data area
;
; Output file pointers
;
bufadr:	ds	2		; Address of output file buffer
mem:	ds	2		; Address of top of file output buffer
bytenxt:ds	2		; Pointer to next byte in buffer
outfcb:	ds	9		; FCB for output file
outftyp:ds	3		; Filetype
	ds	24
;
; Record fields and field lengths
;
; Each of these fields must be null-terminated so actual field length
; is one less
;
edblk:				; Start of first record
edblk1	equ	$+128		; Start of second record
fstnm:	ds	21
fslen	equ	$-fstnm
lname:	ds	21
lnlen	equ	$-lname
addr1:	ds	24
a1len	equ	$-addr1
addr2:	ds	24
a2len	equ	$-addr2
city:	ds	18
cilen	equ	$-city
state:	ds	3		; Only 2-letter codes allowed
stlen	equ	$-state
zip:	ds	11
zilen	equ	$-zip
ctry:	ds	14
ctlen	equ	$-ctry
phon:	ds	39
phlen	equ	$-phon
cmnts1:	ds	39
c1len	equ	$-cmnts1
cmnts2:	ds	39
c2len	equ	$-cmnts2
datmod:	ds	3		; BCD last-modified date
;
; Return address buffer
;
rabuf:
rabuf1	equ	$+128
rafn:	ds	21
raln:	ds	21
radr1:	ds	24
radr2:	ds	24
racty:	ds	18
rast:	ds	3
razip:	ds	11
ractry:	ds	14
	ds	rabuf+256-$
;
cpybfr:	ds	256		; Copy buffer for ditto feature
;
stype:	ds	2		; Search type
srchlen:ds	1		; Length of search string 1
srch:	ds	11		; Search string 1
	ds	1		; Length of search string 2
srch2:	ds	11		; Search string 2
	ds	1		; Filename buffer length
fnbuf:	ds	22		; Filename buffer
;
tcap:	ds	2		; Address of arrow keys in tcap
cpos:	ds	1		; Cursor position (column and line)
lpos:	ds	1
;
xcopy:	ds	4		; Input buffer for number of copies
copies:	ds	1		; Copies to print
envflg:	ds	1		; Envelope flag
eflag:	ds	1		; Print flag for empty field
fflag:	ds	1		; WS/ASCII file flag
insflg:	ds	1		; ON for character insert mode
prkey:	ds	2		; Address of key to search
fndflg:	ds	1		; Found flag for selection key
gkflg:	ds	1		; One/two string flag
keyflg:	ds	1		; Flag for output by key
xclflg:	ds	1		; Exclusion flag
keylen:	ds	2		; Length of search key for prdir & dfile
;
capflag:ds	1		; Edloop flag for state caps input
datbuf:	ds	3		; Temporary date buffer
today:	ds	6		; Current date and time (bcd)
wsdatbf:ds	19
;
recs:	ds	2		; Number of records in file
fptr:	ds	2		; File record number
cfptr:	ds	2		; Current record number
xfptr:	ds	2		; Last record read during indexing
ofptr:	ds	2		; Old record number
rafptr:	ds	2		; Return address record pointer
drafptr:ds	2		; Default return address record pointer
lra:	ds	1		; Use return address on labels
era:	ds	1		; Use return address on envelopes
newflg:	ds	1		; New flag (used with add/edit)
;
count:	ds	2		; Counter for sort loop
xcount:	ds	2		; Counter for express search, print loop
recptr:	ds	2		; Record pointer for sorted file
xrecptr:ds	2		; Last record pointer for sorted file
srttyp:	ds	1		; 0=last/first names, nz=zip index
srtfcb:	ds	36		; Sort file control block
sfdrv:	ds	1		; Sort file drive
sfusr:	ds	1		; Sort file user area
bakfcb:	ds	36		; Backup file control block
defd:	ds	1		; Original drive
fdrv:	ds	1		; File drive
fusr:	ds	1		; File user area
inxptr:	ds	2		; Index record pointer for qfind
datalen	equ	$-data
;
	ds	80		; Stack space
stack:	ds	2		; System stack location
;
; End of ZDB.D
;
