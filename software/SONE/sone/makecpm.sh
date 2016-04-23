#!/bin/bash

# This will assemble SONE (CP/M 2.2) for a specific
# memory size.

# 2015-05-05 P. Betti <pbetti@lpconsul.eu>

MSIZ=$1
REV=20
BIOSFILE=bios${REV}h

if [ -z "$MSIZ" ]; then
	echo "Memory size missing..."
	echo
	echo "Usage: $0 <memory size>"
	exit 1
fi

TARGETS="ccpbdos $BIOSFILE"

# prepare size equ
echo -e "msize\tequ\t$MSIZ" > msize.asm

for src in $TARGETS
do
	mzmac --bin --dep -x - $src.asm > $src$MSIZ.lst
done

# extract ipl code

dd bs=1 count=256 if=$BIOSFILE.bin of=ipl.bin

# correct bios size to 1536 bytes skipping ipl
# and post bios buffer space

dd bs=1 skip=256 count=1536 if=$BIOSFILE.bin of=tmp.bin
mv -f tmp.bin $BIOSFILE.bin

# assemble the SONE .sys package

cat ipl.bin ccpbdos.bin $BIOSFILE.bin > sys$MSIZ.ovr

# done! :-)
#
