#!/bin/bash


ASMB=../../../software/tools/z80asm.com
LNKB=../../../../software/tools/zmlib.com
QUIET=yes

export ASMB LNKB


libmake()
{
	LIBNAME=$1
	cd $1

	if [ -f maklib.files ]; then
		Z80SRCS=`cat maklib.files`
	else
		Z80SRCS=`ls *.z80`
	fi

	OPLOG=$LIBNAME.log

	echo "Doing $LIBNAME.rel ..."

	for f in $Z80SRCS
	do
		> $OPLOG
		if [ "$QUIET" = "yes" ]; then
			echo -e ".\c"
		else
			echo "ASM $f"
		fi
		s=`basename $f .z80`
# 		err=`zxcc $ASMB -$s/m | tee -a $OPLOG | grep '0\ Error'`
		mzmac --rel -m $f
# 		if [ ! -n "$err" ]; then
# 			echo
# 			cat $OPLOG
# 		fi
	done
	if [ "$QUIET" = "yes" ]; then
		echo
	fi

	rm -f $LIBNAME.rel

	if [ -f "maklib.link" ]; then
		Z80LNKS=`cat maklib.link`
	else
		Z80LNKS=$Z80SRCS
	fi

	> $OPLOG
	for f in $Z80LNKS
	do
		o=`basename $f .z80`
		if [ "$QUIET" = "yes" ]; then
			echo -e ":\c"
		else
			echo "LNK $o"
		fi
		zxcc $LNKB $LIBNAME=$o.rel >> $OPLOG
		rm -f $o.rel $o.lst
	done
	if [ "$QUIET" = "yes" ]; then
		echo
	fi

	chmod -f a+r *		# because zxcc create files with 0600 ...
	mv $LIBNAME.rel ..
	cd ..
}


echo "Creating ZCPR3 libs:"
for d in dslib syslib vlib z3lib
do
	libmake $d
done
