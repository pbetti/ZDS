#!/bin/bash

PATH=.:$PATH

# modules addresses
MODADDR=F000
COMADDR=FC00

# Compile genequs
gcc -O3 -g -o genequs genequs.c

echo "Doing SysBios1"
mzmac --rel -m SysBios1.asm
echo "Doing SysBios2"
mzmac --rel -m SysBios2.asm
echo "Doing SysBios3"
mzmac --rel -m SysBios3.asm
echo "Doing BootMonitor"
mzmac --rel -m BootMonitor.asm

# SysCommon module needs to know entry point for all modules with
# their final addresses that, unfortunately, are available only AFTER
# linkage.
# We do the trick with genequs that extract entries from .lst files
# and generate final addresses BEFORE linkage... ;-)

genequs -o $MODADDR -e -s -O sysbios.equ SysBios1.lst SysBios2.lst SysBios3.lst BootMonitor.lst

echo "Doing SysCommon"
mzmac --rel -m SysCommon.asm

# Linkage of images
mld80 -m -g -O bin -o BootMonitor.bin -D $MODADDR -P $COMADDR BootMonitor.rel SysCommon.rel
mld80 -m -g -O bin -o SysBios1.bin -D $MODADDR -P $COMADDR SysBios1.rel SysCommon.rel
mld80 -m -g -O bin -o SysBios2.bin -D $MODADDR -P $COMADDR SysBios2.rel SysCommon.rel
mld80 -m -g -O bin -o SysBios3.bin -D $MODADDR -P $COMADDR SysBios3.rel SysCommon.rel

# Export symbols
./genequs -o $COMADDR -e -s -O darkstar.equ SysCommon.lst
./genequs -o $COMADDR -e -s -z -O darkstar.zas SysCommon.lst
./genequs -o $COMADDR -e -s -d -O darkstar.mac SysCommon.lst

# Create BIG image
rm -f bbios.img
cat BootMonitor.bin SysBios3.bin SysBios2.bin SysBios1.bin >> bbios.img

#
