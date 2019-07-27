#!/bin/sh

LIBNAME=vlib

if [ -f maklib.files ]; then
   Z80SRCS=`cat maklib.files`
else
   Z80SRCS=`ls *.z80`
fi

OPLOG=$LIBNAME.log

echo "Doing $LIBNAME.rel ..."

> $OPLOG
for f in $Z80SRCS
do
	echo "assembling $f" >> $OPLOG
	zxcc ../../m80.com -=$f/z >> $OPLOG
done

rm -f $LIBNAME.rel

if [ -f "maklib.link" ]; then
   Z80LNKS=`cat maklib.link`
else
   Z80LNKS=$Z80SRCS
fi

for f in $Z80LNKS
do
	obj=`basename $f .z80`
 	zxcc ../../zmlib.com $LIBNAME=$obj.rel >> $OPLOG
	rm -f $obj.rel >> $OPLOG
done

chmod -f a+r *		# because zxcc create files with 0600 ...

# -- done


