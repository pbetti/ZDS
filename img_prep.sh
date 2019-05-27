#!/bin/sh

VERBOSE=
DDIR=$1
USAGE="Usage: $0 [-v] dirname [diskformat]"

if [ -z "$DDIR" ]; then
	echo $USAGE
	exit 1
fi

if [ "$DDIR" = "-v" ]; then
	VERBOSE="true"
	shift
	DDIR=$1
fi

if [ -z "$DDIR" ]; then
	echo $USAGE
	exit 1
else
	shift
fi

DNAME=`basename $DDIR`.img
DFMT="$2"

if [ ! -d "$DDIR" ]; then
	echo "Non existent image dir \"$DDIR\"."
	exit 1
fi

if [ -z "$DFMT" ]; then
        DFMT="ZDS"
fi

echo "Using format $DFMT ..."

echo "Creating filesystem for \"$DNAME\"."
mkfs.cpm -f $DFMT /tmp/$DNAME


if [ -d "$DDIR" ]; then
	if [ -z "$*" ]; then
		for f in $DDIR/*
		do
			if [ -n "$VERBOSE" ]; then
				echo $f
			fi
			cpmcp -f $DFMT /tmp/$DNAME $f 0:
		done
	else
		for f in "$*"
		do
			if [ -n "$VERBOSE" ]; then
				echo $f
			fi
			cpmcp -f $DFMT /tmp/$DNAME $DDIR/$f 0:
		done
	fi
fi

mv -f /tmp/$DNAME $HOME/elettronica/Z80-CPM/hardware/Z80DarkStar/diskimgs


exit 0

