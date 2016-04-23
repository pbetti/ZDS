#!/bin/sh

name=`basename $1 .asm`

zxcc rmac $* \$PX+S+M >$name.prn
