
DFMT="$1"
if [ -z "$DFMT" ]; then
	DFMT="ibm-3740"
fi

echo "Using format $DFMT ..."

echo "Cleaning..."
rm -f bootload.bin z80ccp.bin p2dos.bin bios.bin
rm -f bootload.sym z80ccp.sym p2dos.sym bios.sym
echo "Assembling z80ccp"
zmac z80ccp.asm
echo "Assembling p2dos"
zmac p2dos.asm
echo "Assembling bios"
zmac bios.asm
echo "Assembling bootload"
zmac bootload.asm
echo "Generating boot disk and CP/M image..."
mkfs.cpm -f $DFMT -b bootload.bin -b z80ccp.bin -b p2dos.bin -b bios.bin ../dsdos.img
rm -f cpm.bin
cat z80ccp.bin p2dos.bin bios.bin >>cpm.bin
echo "Copying utilities..."
for file in `pwd`/cpm/*
do
#	echo `basename $file`
	cpmcp -f $DFMT ../dsdos.img $file 0:
done
#	echo "---------------------------------"
#	cpmls -f $DFMT ../dsdos.img 
#	echo "---------------------------------"
