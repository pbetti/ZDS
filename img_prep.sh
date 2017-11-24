#!/bin/sh

DDIR=$1


if [ -z "$DDIR" ]; then
	echo "Usage: $0 dirname [diskformat]"
	exit 1
fi

DNAME=`basename $DDIR`.img
DFMT="$2"

if [ ! -d "$DDIR" ]; then
	echo "Non existent image dir."
	exit 1
fi

if [ -z "$DFMT" ]; then
        DFMT="ZDS"
fi

echo "Using format $DFMT ..."

mkfs.cpm -f $DFMT /tmp/$DNAME

if [ -d "$DDIR" ]; then
	for f in $DDIR/*
	do
		cpmcp -f $DFMT /tmp/$DNAME $f 0:
	done
fi

mv -f /tmp/$DNAME $HOME/elettronica/Z80-CPM/hardware/Z80DarkStar/diskimgs

#ln -sf `pwd`/$DNAME vdsk_server/debug/src/$DNAME
#cd $HOME/elettronica/Z80-CPM/hardware/Z80DarkStar/vdsk_server/debug/src/
#ln -sf ../../../diskimgs/$DNAME

exit 0

