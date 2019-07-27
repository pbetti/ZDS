#!/bin/bash

MODS="	bintrp.rel \
	f4.rel \
	biptrg.rel \
	biedit.rel \
	biprtu.rel \
	bio.rel \
	bimisc.rel \
	bistrs.rel \
	binlin.rel \
	fiveo.rel \
	dskcom.rel \
	dcpm.rel \
	fivdsk.rel \
	init.rel"
	
mode="z80asm"

rm -f *.lst *.rel *.bin *.z80

case $mode in

zmac)
	if [ "$1" = "alt" ]; then

		rm -f mbasic.com mbasic.asm
		for m in $MODS
		do
			echo -e ";\tModule name: " ${m/\.rel/\.asm} >> mbasic.asm
			cat ${m/\.rel/\.asm} >> mbasic.asm
		done
		mzmac --bin mbasic.asm

	else

		for m in $MODS
		do
			mzmac --rel ${m/\.rel/\.asm}
		done

		mld80 -m -g -O bin -P0100 -o mbasic.com $MODS

	fi
	;;

z80asm)
	for m in $MODS
	do
		sfile=${m/\.rel/\.asm}
		zfile=${m/\.rel/\.z80}
		afile=`basename $m .rel`
		cp -f $sfile $zfile
		zxcc z80asm -$afile/mf
		rm -f $zfile
	done

	mld80 -m -g -O bin -P0100 -o mbasic.com $MODS
	;;
esac

	
	
	
	
