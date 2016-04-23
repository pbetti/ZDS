comment
	LIBRARY.BAS     revised  3/17/92
	Useful routines for inclusion in SBASIC programs.
	Syntax is: $include library_file module_name
	Example:   $include library upcase
end

$module uppercase
rem  Converts character to upper case
function uppercase(ch = char) = char
   if ch >= 'a' and ch <= 'z' then
       ch = ch - 32
end = ch
$end.module

$module allcaps
rem  Converts string to all upper case characters
function allcaps(source = string : 80) = string
   var p = integer
   for p = 1 to len(source) do
       mid(source,p,1) = uppercase(mid(source,p,1))
   next p
end = source
$end.module

$module cls
rem  Clears Kaypro screen
procedure cls
    print #0; chr(26);
end cls
$end.module

$module ClrEol
rem   clear Kaypro screen to end of line
procedure ClrEol
    print #0; chr(24); 
end ClrEol
$end.module

$module cursor
comment
   Position Kaypro cursor at row, column
   Home position = 1,1
end
procedure cursor(row, column = integer)
   print #0; chr(27);'='; chr(row+31); chr(column+31);
end cursor
$end.module

$module beep
rem  makes "beep" sound
procedure beep
   print #0; chr(7);
end beep
$end.module

$module mod
rem  computes p mod q (since SBASIC lacks a mod operator)
function mod(p, q = integer) = integer
end = p - q * (p/q)
$end.module

$module log.10
comment
    computes the base 10 logarithm of its argument;
    provides a working version of the phantom "log10" 
    function mentioned in the SBASIC reference manual 
end
function log.10 (n = real) = real
end = log(n) / 2.30258
$end.module

$module radians
comment
   converts degrees to radians. Necessary because SBASIC's
   trig functions take arguments in radians, not degrees.
end
function radians(degrees = real) = real
end = degrees * .0174533
$end.module

$module degrees
rem  converts radians to degrees
function degrees(radians = real) = real
end = radians * 57.2958
$end.module

$module fac
rem  Computes factorial (n!) of a number 
function fac(n = real) = real
    if n=0 then n=1 else n=fac(n-1)*n
end =n
$end.module

$module bin$
rem  Returns binary representation of byte as string
function bin$(bchar = byte) = string
var i, bint, bmask, shiftmask  = integer
var bstr = string : 8
    bint = bchar	rem promote to integer
    bmask = 128
    shiftmask = 127
    bstr = "00000000"
    for i = 1 to 8
        mid(bstr,i,1) = chr((bint and bmask)/bmask + 48);
	bint = (bint and shiftmask) * 2
    next i
end = bstr
$end.module

$module ipower
comment
	Raise x to the n power, where n is an integer.
	Unlike SBASIC's exponentiation (^) operator,
	this function returns a valid double-precision
	result, but unlike the exponentiation operator,
	is limited to integer powers.
end
function ipower(x = real.double; n = integer) = real.double
var n1 = integer
var y  = real.double
    y = 1.0
    while (n > 0) do
	begin
	    n1 = n/2
	    if (2 * n1) < n then y = y * x
	    n = n1
	    x = x * x
	end
end = y
$end.module

$module setuser
rem  -- Set the CP/M user area (0 to 15)
procedure setuser (user = integer)
   var hl, bc, a_psw = integer
   hl = 0
   bc = 20H
   a_psw = 0
   call (5H,hl,user,bc,a_psw)
end
$end.module

$module setdrive
rem --  Set the logged drive ('A' to 'P')
procedure setdrive (drive = char)
   var hl, de, bc, a_psw = integer
   rem -- make sure drive letter is upper case!
   if drive >= 'a' then drive = drive - 32
   hl = 0
   de = drive - 65
   bc = 0EH
   a_psw = 0
   call (5H,hl,de,bc,a_psw)
end
$end.module

$module getdrive
rem  -- Returns the current logged drive ('A' to 'P')
function getdrive = char
   var hl, de, bc, a_psw = integer
   hl = 0
   de = 0
   bc = 19H
   a_psw = 0
   call (5H,hl,de,bc,a_psw)
   a_psw = (a_psw / 256) + 65
end = a_psw
$end.module

$module getuser
rem -- Return current user area
function getuser = integer
   var hl, de, bc, a_psw = integer
   hl = 0
   de = 0FFH
   bc = 20H
   a_psw = 0
   call (5H,hl,de,bc,a_psw)
end = a_psw / 256
$end.module

$module fsize
comment
    Return size of named file as number of 128-byte records
    Assumes filename is uppercase
end
function fsize(filename = string:20) = integer
    var hl, de, bc, a_psw, p = integer
    based fname = string:20
    based sz = integer
    dim byte workfcb(36)
    location array de = workfcb
    base fname at de
    base sz at de + 33
    fname = fcb$(filename)
    rem  See if drive was specified and set FCB accordingly
    p = instr(1,filename,":")
    if p = 0 then
    	workfcb(0) = 0
    else
        workfcb(0) = asc(mid(filename,p-1,1)) - 64
    bc = 23H			rem  BDOS filesize function
    call (5,hl,de,bc,a_psw)     rem  result stored in sz
end = sz
$end.module
