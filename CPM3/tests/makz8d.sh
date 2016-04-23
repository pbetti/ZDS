#!/bin/bash


ASMB=../../software/slr/z80asm.com
LIBB=../../software/tools/zmlib.com
LNKB=../../software/tools/zml.com
QUIET=no

export ASMB LNKB


prgmake()
{
	PRGNAME=$1

	OPLOG=$PRGNAME.log

	echo "Doing $PRGNAME.com ..."

	mzmac $PRGNAME.asm
	mv -f $PRGNAME.bin $PRGNAME.com

# 	zxcc $LNKB -$PRGNAME,dslib/,z3lib/,syslib/

}


prgmake z8d
