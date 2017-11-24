
#!/bin/bash

PATH=.:$PATH

# HDFMT=ZDSHD8
# FDFMT=ZDS
# SLROPT="/mfs"
# LOG="log.make"

SRCS="systran \
	fdformat \
	z8e \
	reboot \
	myide3 \
	diskcopy \
	td \
	clock \
	sysinit"


	for ut in $SRCS
	do
		echo -e "\t$ut"
		mzmac -m $ut.asm
		mv -f $ut.bin $ut.com
		rm -rf $ut.lst
	done

	/bin/bash -c "cd ../../MultiF-Board/IDE/fdisk; make"
	cp -f ../../MultiF-Board/IDE/fdisk/fdisk.bin fdisk.com

#
