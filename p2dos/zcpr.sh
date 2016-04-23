#!/bin/sh

# assemble ZCPR

SRCS="z33defn.lib z33hdr.lib z33mac.lib z3base.lib zcpr33.asm common.asm"
TDIR=`pwd`/tmp

if [ ! -d "$TDIR" ]; then
	mkdir $TDIR
fi

for f in $SRCS
do
	unix2dos -n $f $TDIR/$f &> /dev/null
	chmod a+r $TDIR/$f
done

cd $TDIR
zxcc ../zas.com zcpr33.asm H PP
dos2unix -f -q zcpr33.prn
mv zcpr33.prn ../zcpr33.lst
cat zcpr33.hex | ../hexcom > ../zcpr33.bin
chmod a+r ../zcpr33.lst ../zcpr33.bin zcpr33.hex

# the RCP package

cd ../z33rcp
zxcc ../zas.com z33rcp.z80 H PP
dos2unix -f -q z33rcp.prn
mv z33rcp.prn z33rcp.lst
cat z33rcp.hex | ../hexcom > sys.rcp
chmod a+r z33rcp.lst z33rcp.hex

# the FCP package

cd ../z33fcp
zxcc ../zas.com z33fcp.z80 H PP
dos2unix -f -q -q z33fcp.prn
mv z33fcp.prn z33fcp.lst
cat z33fcp.hex | ../hexcom > sys.fcp
chmod a+r z33fcp.lst z33fcp.hex

# the NDR package

cd ../z33ndr
zxcc ../zas.com sysndr.asm H PP
dos2unix -f -q sysndr.prn
mv sysndr.prn sysndr.lst
cat sysndr.hex | ../hexcom > sys.ndr
chmod a+r sysndr.lst sysndr.hex

# the ENV package

cd ../z33env
zxcc ../zas.com sysenv.asm H PP
dos2unix -f -q sysenv.prn
mv sysenv.prn sysenv.lst
cat sysenv.hex | ../hexcom > sys.env
chmod a+r sysenv.lst sysenv.hex

