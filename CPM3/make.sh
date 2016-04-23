#!/bin/bash

PATH=.:$PATH

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

	# floppy run...
	
	echo "*** Performing GENCPM for floppy image ***"
	
	if [ -z "$BANKED" ]; then
		cp -f gencpm.dat.nobank.floppy gencpm.dat
		zxcc link.com bios3[b,q]=$OBJ
		echo
		echo "Doing floppy disk NON banked BIOS"
		zxcc gencpm.com
		cp -f gencpm.dat gencpm.dat.nobank.floppy
		cp -f cpm3.sys cpm3.sys.floppy
	else
		cp -f gencpm.dat.bank.floppy gencpm.dat
		zxcc link.com bnkbios3[b]=$OBJ
		echo
		echo "Doing floppy disk banked BIOS"
		zxcc gencpm.com
		cp -f gencpm.dat gencpm.dat.bank.floppy
		cp -f cpm3.sys cpm3.sys.floppy
	fi

	# hd run...
	
	echo
	echo "*** Performing GENCPM for HD image ***"
	
	if [ -z "$BANKED" ]; then
		cp -f gencpm.dat.nobank.hd gencpm.dat
		zxcc link.com bios3[b,q]=$OBJ
		echo
		echo "Doing hard disk NON banked BIOS"
		zxcc gencpm.com
		cp -f gencpm.dat gencpm.dat.nobank.hd
		cp -f cpm3.sys cpm3.sys.hd
	else
		cp -f gencpm.dat.bank.hd gencpm.dat
		zxcc link.com bnkbios3[b]=$OBJ
		echo
		echo "Doing hard disk banked BIOS"
		zxcc gencpm.com
		cp -f gencpm.dat gencpm.dat.bank.hd
		cp -f cpm3.sys cpm3.sys.hd
	fi

}

makcpmldr() {

	mzmac --rel -m hldrbios.asm
# 	if [ -z "$FLAVR" ]; then
		zxcc link.com cpmldr[l100]=cpmldr,hldrbios
# 	else
# 		zxcc link.com cpmldr[l100]=zpm3ldr,hldrbios
# 	fi

}

makbldr() {

	mzmac -m bootload.asm

}

maksyst() {

	bash -c "cd zds; ./make.sh"

}

makdisk() {

	mkfs.cpm -f $1 -b bootload.bin -b cpmldr.com $2

	if [ "$FLAVR" = "DRI" ]; then
		if [ "$1" = "ZDS" ]; then
			cpmcp -f $1 -t $2 profile.sub_o 0:profile.sub
		else
			cpmcp -f $1 -t $2 profile.sub_p 0:profile.sub
		fi
		cpmcp -f $1 $2 ccp.com 0:
	else
# 		cpmcp -f $1 $2 zccp/zccp.com 0:ccp.com
		cpmcp -f $1 $2 ccp.com 0:
	fi
	cpmcp -f $1 $2 zds/systran.com 0:
	cpmcp -f $1 $2 zds/sysinit.com 1:
	cpmcp -f $1 $2 zds/fdformat.com 1:
	cpmcp -f $1 $2 zds/diskcopy.com 1:
	cpmcp -f $1 $2 zds/myide3.com 1:
	cpmcp -f $1 $2 zds/z8d.com 1:
	cpmcp -f $1 $2 zds/clock.com 1:
	cpmcp -f $1 $2 zds/td.com 1:
	cpmcp -f $1 $2 zds/reboot.com 0:
	cpmcp -f $1 $2 zds/fdisk.com 1:


	if [ "$1" = "ZDS" ]; then
		imgtype="floppy"
		cpmcp -f $1 $2 cpm3.sys.floppy 0:cpm3.sys
	else
		imgtype="hd"
		cpmcp -f $1 $2 cpm3.sys.hd 0:cpm3.sys
	fi
	for d in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15
	do
		if [ ! -d "disk/$imgtype/$d" ]; then
			continue
		fi
		for f in disk/$imgtype/$d/*
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
LDR="$2"
DOGENCPM="no"

if [ "$FLAVR" = "-gencpm" ]; then
	DOGENCPM="yes"
	shift
fi

if [ -z "$FLAVR" ]; then
	FLAVR="DRI"
fi

if [ -z "$LDR" ]; then
	LDR="cpm"
fi

if [ "$FLAVR" = "DRI" ]; then
	echo "CP/M 3 (Plus) BDOS..."
	cp -f mycpm3/bnkbdos3.spr .
	cp -f mycpm3/resbdos3.spr .
	cp -f mycpm3/cpmldr.rel .

	sed --in-place 's/^ZPM3\tEQU\tTRUE/\ZPM3\tEQU\tFALSE/' common.inc
else
	echo "CP/M 3 (Plus) BDOS..."
	cp -f zsys/zpm3/bnkbdos3.spr .
	cp -f zsys/zpm3/resbdos3.spr .
	cp -f mycpm3/cpmldr.rel .

	sed --in-place 's/^ZPM3\tEQU\tFALSE/\ZPM3\tEQU\tTRUE/' common.inc
fi


echo "Generating BIOS..."

makbios
echo


if [ "$DOGENCPM" = "yes" ]; then
	gencpm
	echo
fi

echo "Generating CPMLDR..."

makcpmldr

echo "Generating bootloader..."

makbldr

echo "Generating ZDS utilities..."

maksyst

dodisks

#
