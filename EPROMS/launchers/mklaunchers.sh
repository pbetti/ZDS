#!/bin/bash

echo "Constructing eprom loaders..."


echo "EPROM LX390 4k Dual Boot"
echo "Constructing Core..."
mzmac sysdbg8.asm
mzmac ../Z80-390-2532-DASM.asm

echo "Constructing Loader"
mzmac ml390db4.asm

mv ml390db4.bin ml390db4.com
cat sysdbg8.bin >> ml390db4.com
cat Z80-390-2532-DASM.bin >> ml390db4.com
rm -f *.lst Z80-390-2532-DASM.bin sysdbg8.bin

echo "Done ml390db4.com -> EPROM LX390 4k Dual Boot"

