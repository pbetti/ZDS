#!/bin/bash

echo "Constructing eprom loaders..."


echo "EPROM LX390 4k Dual Boot"
echo "Constructing Core..."
mzmac sysdbg8.asm
mzmac ../ep390-2532.asm

echo "Constructing Loader"
mzmac ml390db4.asm

mv ml390db4.bin ml390db4.com
cat sysdbg8.bin >> ml390db4.com
cat ep390-2532.bin >> ml390db4.com
rm -f *.lst ep390-2532.bin sysdbg8.bin

echo "Done ml390db4.com -> EPROM LX390 4k Dual Boot"

echo "EPROM LX683 2k SONE"
echo "Constructing Core..."
mzmac sysdbg8.asm
# mzmac ../ep683.z80

echo "Constructing Loader"
mzmac ml683son.asm

mv ml683son.bin ml683son.com
cat sysdbg8.bin >> ml683son.com
cat ../ep683.bin >> ml683son.com
rm -f *.lst ep683.bin sysdbg8.bin

echo "Done ml683son.com -> EPROM LX683 2k SONE"

