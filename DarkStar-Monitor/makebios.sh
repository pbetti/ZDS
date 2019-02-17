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
echo "Doing SysBios4"
mzmac --rel -m SysBios4.asm
echo "Doing SysBios5"
mzmac --rel -m SysBios5.asm
echo "Doing SysBios6"
mzmac --rel -m SysBios6.asm
echo "Doing SysBios7"
mzmac --rel -m SysBios7.asm
echo "Doing BootMonitor"
mzmac --rel -m BootMonitor.asm

# SysCommon module needs to know entry point for all modules with
# their final addresses that, unfortunately, are available only AFTER
# linkage.
# We do the trick with genequs that extract entries from .lst files
# and generate final addresses BEFORE linkage... ;-)

genequs -o $MODADDR -e -s -O sysbios.equ SysBios?.lst BootMonitor.lst

echo "Doing SysCommon"
mzmac --rel -m SysCommon.asm

# Linkage of images
mld80 -m -g -O bin -o BootMonitor.bin -D $MODADDR -P $COMADDR BootMonitor.rel SysCommon.rel
mld80 -m -g -O bin -o SysBios1.bin -D $MODADDR -P $COMADDR SysBios1.rel SysCommon.rel
mld80 -m -g -O bin -o SysBios2.bin -D $MODADDR -P $COMADDR SysBios2.rel SysCommon.rel
mld80 -m -g -O bin -o SysBios3.bin -D $MODADDR -P $COMADDR SysBios3.rel SysCommon.rel
mld80 -m -g -O bin -o SysBios4.bin -D $MODADDR -P $COMADDR SysBios4.rel SysCommon.rel
mld80 -m -g -O bin -o SysBios5.bin -D $MODADDR -P $COMADDR SysBios5.rel SysCommon.rel
mld80 -m -g -O bin -o SysBios6.bin -D $MODADDR -P $COMADDR SysBios6.rel SysCommon.rel
mld80 -m -g -O bin -o SysBios7.bin -D $MODADDR -P $COMADDR SysBios7.rel SysCommon.rel

# Export symbols
./genequs -o $COMADDR -e -s -O darkstar.equ SysCommon.lst
./genequs -o $COMADDR -e -s -z -O darkstar.zas SysCommon.lst
./genequs -o $COMADDR -e -s -d -O darkstar.mac SysCommon.lst

# Create BIG image
rm -f bbios.img
cat BootMonitor.bin SysBios7.bin SysBios6.bin SysBios5.bin SysBios4.bin SysBios3.bin SysBios2.bin SysBios1.bin >> bbios.img

# ...and sysdebug
mzmac sysdebug/sysdbg8.asm

