
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
	dsktran \
	sysinit"

SRCSN="zrbasic"


	for ut in $SRCS
	do
		echo -e "\t$ut"
		mzmac -m $ut.asm
		mv -f $ut.bin $ut.com
# 		rm -rf $ut.lst
	done

	for ut in $SRCSN
	do
		echo -e "\t$ut"
		mzmac -m $ut.asm
		rm -rf $ut.lst
	done

	/bin/bash -c "cd ../syslibs; make"

	/bin/bash -c "cd fdisk; make"
	cp -f fdisk/fdisk.com .

	/bin/bash -c "cd flasher; make"
	cp -f flasher/flasher.com .

	/bin/bash -c "cd launchers; ./mklaunchers.sh"
	cp -f launchers/*.com .

#
