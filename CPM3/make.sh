#!/bin/bash

PATH=.:$PATH

HWFLOPPYDRIVE="A"
HWIDEDRIVE="C"
HODISK=../diskimgs/hdcpm3.img
FODISK=../diskimgs/fdcpm3.img
HDFMT=ZDSHD8
FDFMT=ZDS
SLROPT="/mfs"
LOG="log.make"

CPMSRCS="bioskrnl.asm \
	boot.asm \
	chario.asm \
	media.asm \
	drvtable.asm \
	move.asm \
	time.asm \
	scb.asm"

# Do .rel files

rm -f $LOG
OBJS=

makbios() {

	for f in $CPMSRCS
	do
		echo "+$f"
		fnam=`basename $f .asm`
		mzmac --rel -m $f
		if [ -z "$OBJ" ]; then
			OBJ="$fnam"
		else
			OBJ="$OBJ,$fnam"
		fi
		echo
	done

	echo zxcc link.com bios3[b,q]=$OBJ

}


gencpm() {

	zxcc link.com bnkbios3[b]=$OBJ
	echo
	zxcc link.com bios3[b,q]=$OBJ
	echo
	
	# gencpm.dat manual edit requested ?
	if [ -z "$BANKED" ]; then
		if [ "$DOGENCPM" = "yes" ]; then
			echo "*** Performing interactive GENCPM for a NON BANKED system ***"
			zxcc gencpm.com
			echo
			mv gencpm.dat gencpm.dat.nobank
			rm -f cpm3.sys

		fi
	else
		if [ "$DOGENCPM" = "yes" ]; then
			echo "*** Performing interactive GENCPM for a BANKED system ***"
			zxcc gencpm.com
			echo
			mv gencpm.dat gencpm.dat.bank
			rm -f cpm3.sys

		fi
	fi

	# floppy run...
	
	echo "*** Creating CPM3.SYS for floppy images ***"
	
	if [ -z "$BANKED" ]; then
		echo "     Doing floppy disk NON banked BIOS"
		echo

		echo "* Virtual floppy O: *"
		sed "s/BOOTDRV  = ./BOOTDRV  = O/g" gencpm.dat.nobank > gencpm.dat
		echo
		
		zxcc gencpm.com auto
		echo -e "\r"
		echo "---------------------------------------"
		
		rm -f gencpm.dat
		mv cpm3.sys cpm3.sys.floppy.o
	
		echo "* Virtual floppy $HWFLOPPYDRIVE: *"
		sed "s/BOOTDRV  = ./BOOTDRV  = $HWFLOPPYDRIVE/g" gencpm.dat.nobank > gencpm.dat
		echo
		
		zxcc gencpm.com auto
		echo -e "\r"
		echo "---------------------------------------"
		
		rm -f gencpm.dat
		mv cpm3.sys cpm3.sys.floppy.o

	else
		echo "       Doing floppy disk BANKED BIOS"
		echo

		echo "* Virtual floppy O: *"
		sed "s/BOOTDRV  = ./BOOTDRV  = O/g" gencpm.dat.bank > gencpm.dat
		echo
		
		zxcc gencpm.com auto
		echo -e "\r"
		echo "---------------------------------------"
		
		rm -f gencpm.dat
		mv cpm3.sys cpm3.sys.floppy.o
	
		echo "* Hardware floppy $HWFLOPPYDRIVE: *"
		sed "s/BOOTDRV  = ./BOOTDRV  = $HWFLOPPYDRIVE/g" gencpm.dat.bank > gencpm.dat
		echo
		
		zxcc gencpm.com auto
		echo -e "\r"
		echo "---------------------------------------"
		
		rm -f gencpm.dat
		mv cpm3.sys cpm3.sys.floppy.a

	fi

	# hd run...
	
	echo
	echo "*** Performing GENCPM for Hard Disk image ***"
	
	if [ -z "$BANKED" ]; then
		echo "       Doing hard disk NON banked BIOS"
		echo

		echo "* Virtual HD P: *"
		sed "s/BOOTDRV  = ./BOOTDRV  = P/g" gencpm.dat.nobank > gencpm.dat
		echo
		
		zxcc gencpm.com auto
		echo -e "\r"
		echo "---------------------------------------"
		
		rm -f gencpm.dat
		mv cpm3.sys cpm3.sys.hd.p
	
		echo "* IDE HD $HWIDEDRIVE: *"
		sed "s/BOOTDRV  = ./BOOTDRV  = $HWIDEDRIVE/g" gencpm.dat.nobank > gencpm.dat
		echo
		
		zxcc gencpm.com auto
		echo -e "\r"
		echo "---------------------------------------"
		
		rm -f gencpm.dat
		mv cpm3.sys cpm3.sys.hd.c

	else
		echo "         Doing hard disk BANKED BIOS"
		echo

		echo "* Virtual HD P: *"
		sed "s/BOOTDRV  = ./BOOTDRV  = P/g" gencpm.dat.bank > gencpm.dat
		echo
		
		zxcc gencpm.com auto
		echo -e "\r"
		echo "---------------------------------------"
		
		rm -f gencpm.dat
		mv cpm3.sys cpm3.sys.hd.p
	
		echo "* IDE HD $HWIDEDRIVE: *"
		sed "s/BOOTDRV  = ./BOOTDRV  = $HWIDEDRIVE/g" gencpm.dat.bank > gencpm.dat
		echo
		
		zxcc gencpm.com auto
		echo -e "\r"
		echo "---------------------------------------"
		
		rm -f gencpm.dat
		mv cpm3.sys cpm3.sys.hd.c

	fi

}

makcpmldr() {

	mzmac --rel -m hldrbios.asm
# 	if [ "$FLAVR" = "DRI" ]; then
		zxcc link.com cpmldr[l100]=cpmldr,hldrbios
# 	else
# 		zxcc link.com cpmldr[l100]=zpm3ldr,hldrbios
# 	fi

}

makbldr() {

	mzmac -m bootload.asm

}

maksyst() {

	bash -c "cd ../zds; ./make.sh"

}

makdisk() {

	mkfs.cpm -f $1 -b bootload.bin -b cpmldr.com $2

	if [ "$FLAVR" = "DRI" ]; then
		subd="dri"
		if [ "$1" = "ZDS" ]; then
			imgtype="floppy"
			cpmcp -f $1 $2 cpm3.sys.floppy.o 0:cpm3.sys
			cpmcp -f $1 $2 cpm3.sys.floppy.a 3:cpm3.sys
			cpmcp -f $1 -t $2 profile.sub_o.dri 0:profile.sub
		else
			imgtype="hd"
			cpmcp -f $1 $2 cpm3.sys.hd.p 0:cpm3.sys
			cpmcp -f $1 $2 cpm3.sys.hd.c 3:cpm3.sys
			cpmcp -f $1 -t $2 profile.sub_p.dri 0:profile.sub
		fi
		cpmcp -f $1 $2 ccp.com 0:
	else
		subd="z3p"
		if [ "$1" = "ZDS" ]; then
			imgtype="floppy"
			cpmcp -f $1 $2 cpm3.sys.floppy.o 0:cpm3.sys
			cpmcp -f $1 $2 cpm3.sys.floppy.a 3:cpm3.sys
			cpmcp -f $1 -t $2 profile.sub_o.z3p 0:profile.sub
		else
			imgtype="hd"
			cpmcp -f $1 $2 cpm3.sys.hd.p 0:cpm3.sys
			cpmcp -f $1 $2 cpm3.sys.hd.c 3:cpm3.sys
			cpmcp -f $1 -t $2 profile.sub_p.z3p 0:profile.sub
		fi
# 		cpmcp -f $1 $2 zccp/zccp.com 0:zccp.com
		cpmcp -f $1 $2 ccp.com 0:
	fi
	cpmcp -f $1 $2 ../zds/systran.com 0:
	cpmcp -f $1 $2 ../zds/sysinit.com 1:
	cpmcp -f $1 $2 ../zds/fdformat.com 1:
	cpmcp -f $1 $2 ../zds/diskcopy.com 1:
	cpmcp -f $1 $2 ../zds/myide3.com 1:
	cpmcp -f $1 $2 ../zds/z8e.com 1:
	cpmcp -f $1 $2 ../zds/clock.com 1:
	cpmcp -f $1 $2 ../zds/td.com 1:
	cpmcp -f $1 $2 ../zds/reboot.com 0:
	cpmcp -f $1 $2 ../zds/fdisk.com 1:
	cpmcp -f $1 $2 ../zds/dsktran.com 1:
	cpmcp -f $1 $2 ../EPROMS/launchers/ml390db4.com 1:
	cpmcp -f $1 $2 ../EPROMS/launchers/ml683son.com 1:


	for d in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15
	do
		if [ ! -d "disk/$subd/$imgtype/$d" ]; then
			continue
		fi
		for f in disk/$subd/$imgtype/$d/*
		do
# 			echo cpmcp -f $1 $2 $f $d:
			cpmcp -f $1 $2 $f $d:
		done
	done
}


dodisks() {
	echo "Generating HD disk image..."

	makdisk $HDFMT $HODISK

	echo "Generating FD disk image..."

	makdisk $FDFMT $FODISK
}

BANKED=`cat common.inc | grep BANKED | grep TRUE`
if [ -n "$BANKED" ]; then
	BANKED=yes
fi

if [ "$1" = "disk" ]; then
	dodisks
	exit 0
fi

FLAVR="$1"
# LDR="$2"
DOGENCPM="no"

if [ "$FLAVR" = "-gencpm" ]; then
	DOGENCPM="yes"
	shift
fi

FLAVR="$1"
# if [ -z "$FLAVR" ]; then
# 	FLAVR="DRI"
# fi

# if [ -z "$LDR" ]; then
	LDR="cpm"
# fi

if [ "$FLAVR" = "DRI" ]; then
	sed --in-place 's/^ZPM3\tEQU\tTRUE/\ZPM3\tEQU\tFALSE/' common.inc

	echo "CP/M 3 (Plus) BDOS..."
	cp -f mycpm3/bnkbdos3.spr .
	cp -f mycpm3/resbdos3.spr .
	cp -f mycpm3/cpmldr.rel .

else
	sed --in-place 's/^ZPM3\tEQU\tFALSE/\ZPM3\tEQU\tTRUE/' common.inc

	echo "Z3Plus (zpm3) BDOS..."
	cp -f zsys/zpm3/bnkbdos3.spr .
	cp -f zsys/zpm3/resbdos3.spr .
	cp -f mycpm3/cpmldr.rel .
fi


echo "Generating BIOS..."

makbios
echo


# if [ "$DOGENCPM" = "yes" ]; then
	gencpm
# 	echo
# fi

echo "Generating CPMLDR..."

makcpmldr

echo "Generating bootloader..."

makbldr

echo "Generating ZDS utilities..."

maksyst

dodisks

#
