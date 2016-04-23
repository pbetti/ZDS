comment
	mem.bas  --  display CP/M memory map
	written for SBASIC compiler
	Addresses for BDOS and CCP are calculated from BIOS base 
	and will reflect actual rather than apparent locations.  
	TPA calculation will therefore correctly reflect reduction 
	in available memory that occurs when a resident system
	extension (RSX) is installed.  
end

var msize, tpa = real
var rsx_installed = string : 5

print "Start of BIOS   : "; hex$(peek(2) * 100H)
print "Start of BDOS   : "; hex$((peek(2) - 0EH) * 100H + peek(6))
print "Start of CCP    : "; hex$((peek(2) - 16H) * 100H)
print

msize = 256 * peek(2) 		rem  BIOS base
msize = msize - 18944		rem  BIOS address in 20K system
msize = (msize / 1024) + 20	rem  adjust and convert to K

rem  Calculate available TPA in K based on apparent BDOS address
tpa = 256 * (peek(7) - 1) / 1024

print "CP/M size       :"; msize; "K"
print "Available TPA   :"; tpa; "K"

rem  check whether actual and apparent BDOS entries differ
if peek(2) - 0EH = peek(7) then 
    rsx_installed = "No" 
else 
    rsx_installed = "Yes"

print "RSX installed   : "; rsx_installed

end
