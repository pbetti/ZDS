#!/bin/sh



LIBNAME=dslib

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
	echo "$f"
	s=`basename $f .z80`
	zxcc $ASMB -$s/m | tee -a $OPLOG | grep Error
done

rm -f $LIBNAME.rel

if [ -f "maklib.link" ]; then
   Z80LNKS=`cat maklib.link`
else
   Z80LNKS=$Z80SRCS
fi

for f in $Z80LNKS
do
	o=`basename $f .z80`
 	zxcc $LNKB $LIBNAME=$o.rel >> $OPLOG
	rm -f $o.rel
done

chmod -f a+r *		# because zxcc create files with 0600 ...

# -- done


