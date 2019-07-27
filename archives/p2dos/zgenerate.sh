#!/bin/sh

# disk format to use
DFMT="$1"
if [ -z "$DFMT" ]; then
	DFMT="ZDS"
fi

# set to 1 to switch to ZCPR
ZCPR=1
# image name for ZCPR utilities
ZCPRDSK=../zcpr3dsk.img

# Uncomment this for Z80DOS 2.4
#BDOSTYP="Z80DOS"
#BDOSIMG=z80dos24.bin
#BDOSASM="cd z80d24; zmac -o ../z80dos24.bin z80dos24.z80"
# Uncomment this for ZSDOS 1.1
BDOSTYP="ZSDOS"
BDOSIMG=zsdos.bin
BDOSASM="mzmac zsdos.asm"
#
if [ "$ZCPR" = "0" ]; then
	CCP=z80ccp
	CCPASM="mzmac z80ccp.asm"
else
	CCP=zcpr33
	CCPASM="sh zcpr.sh"
fi

ZDSUTILS="systrn.asm \
	format.asm \
	z8d.asm \
	disktest.asm \
	diskcopy.asm \
	rafon.asm \
	rafoff.asm \
	cfu.asm \
	clock.asm \
	td.asm \
"

echo "Using format : $DFMT"
echo "      BDOS   : $BDOSTYP"

HERE=`pwd`

echo "Cleaning..."
rm -f bootload.bin $CCP.bin $BDOSIMG bios.bin
rm -f bootload.sym $CCP.sym bios.sym

echo "Assembling bios"
if [ "$YAZE" = "1" ]; then
	mzmac -o bios.bin bios-yaze.asm
	ODISK=yazecpm.img
else
	mzmac bios.asm
	ODISK=../diskimgs/dsdos.img
fi

echo "Assembling $CCP"
sh -c "$CCPASM"

echo "Assembling $BDOSTYP"
sh -c "$BDOSASM"

echo "Assembling bootload"
mzmac bootload.asm

echo "Generating boot disk and CP/M image..."
if [ "$YAZE" = "1" ]; then
	mkfs.cpm -f $DFMT -b bootload.bin -b $CCP.bin -b $BDOSIMG -b bios.bin $ODISK
else
	mkfs.cpm -f $DFMT -b bootload.bin -b $CCP.bin -b $BDOSIMG -b bios.bin $ODISK
fi

rm -f cpm.bin
dd if=$CCP.bin bs=128 conv=sync >cpm.bin 2>/dev/null
dd if=$BDOSIMG bs=128 conv=sync >>cpm.bin 2>/dev/null
dd if=bios.bin bs=128 conv=sync >>cpm.bin 2>/dev/null

echo "Assembling utilities..."
for ut in $ZDSUTILS
do
	echo -e "$ut \c"
	mzmac $ut
done
echo
# Special cases:
mzmac parload1.asm
mzmac parload.asm
cat parload1.bin >>parload.bin
#

if [ "$ZCPR" = "1" ]; then
	echo "Creating ZCPR3 libs:"
	for d in dslib syslib vlib z3lib
	do
		sh -c "cd z3libs/$d; sh maklib.sh"
		chmod -R a+r z3libs/$d
	done
fi
# if [ "$ZCPR" = "1" ]; then
# 	echo "Creating ZCPR3 utils:"
# 	for d in dslib syslib vlib z3lib
# 	do
# 		sh -c "cd z3libs/$d; sh maklib.sh"
# 	done
# fi
if [ "$ZCPR" = "1" ]; then
	echo "Copying ZCPR3 packages..."
	cpmcp -f $DFMT $ODISK z33rcp/sys.rcp 0:
	cpmcp -f $DFMT $ODISK z33fcp/sys.fcp 0:
	cpmcp -f $DFMT $ODISK z33ndr/sys.ndr 0:
	cpmcp -f $DFMT $ODISK z33env/sys.env 0:
fi
echo "Copying utilities to users 0-15..."
for d in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15
do
	if [ ! -d "$HERE/cpm$d" ]; then
		continue
	fi
	for f in $HERE/cpm$d/*
	do
# 		echo cpmcp -f $DFMT $ODISK $f $d:
		cpmcp -f $DFMT $ODISK $f $d:
	done
done

# Specials
cpmcp -f $DFMT $ODISK ../MultiF-Board/IDE/myide3.bin 1:myide3.com
cpmcp -f $DFMT $ODISK ../MultiF-Board/Serials/srlr0.bin 1:srlr0.com
cpmcp -f $DFMT $ODISK ../MultiF-Board/Serials/srlt0.bin 1:srlt0.com


#	echo "---------------------------------"
#	cpmls -f $DFMT $ODISK
#	echo "---------------------------------"
# echo "Generating ZCPR3 utils disk..."
# mkfs.cpm -f $DFMT $ZCPRDSK
# for file in `pwd`/zcpr3prg/*
# do
# 	cpmcp -f $DFMT $ZCPRDSK $file 0:
# done
