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

	echo "Doing $PRGNAME.rel ..."

# 	zxcc $ASMB -$s/m
	mzmac --rel $PRGNAME.asm

	zxcc $LNKB -$PRGNAME,dslib/,z3lib/,syslib/

# 	chmod -f a+r *		# because zxcc create files with 0600 ...
}


prgmake copy
