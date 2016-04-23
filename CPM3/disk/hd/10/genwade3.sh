#!bin/bash

# ;
# ; Generate (modified) WADE for CP/M 3
# ; Equate CPM3 in MONOPT.LIB must be TRUE
# ;

zxcc z80asm.com -moncpm/m
zxcc z80asm.com -monit/m
zxcc z80asm.com -monbreak/m
zxcc z80asm.com -montab/m
zxcc z80asm.com -mondis/m
zxcc z80asm.com -monsub/m
zxcc z80asm.com -monexpr/m
zxcc z80asm.com -monasm/m
zxcc z80asm.com -monsym/m
zxcc z80asm.com -monpeek/m
zxcc z80asm.com -wade/m
# ;
zxcc link.com -wsid=wade
zxcc link.com -monrsx=moncpm,monit,monbreak,montab,mondis,monsub,monexpr,monasm,monsym,monpeek[op]
# ;
rm -f monrsx.rsx
mv monrsx.prl monrsx.rsx
zxcc gencom -wsid monrsx
