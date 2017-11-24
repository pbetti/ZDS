#!/bin/bash

# rm -f linkistr.lnk

# libx
./zcc getline
./zcc stindex
zxlibr r libx.lib getline.obj stindex.obj

#zmp
./zccs zmp
./zccs zmp2
./zcc ovloader
zxc -c userdef.as
zxc -c ovbgn.as
zxc -fzmp.sym userdef.obj zmp.obj zmp2.obj ovloader.obj ovbgn.obj -lx
rm -rf zmpx.com
mv userdef.com zmpx.com
zxcc symtoas zmp.sym
zxas main.as

OVR_ADR=`grep _ovbgn zmp.sym | cut -c1-4`
USR_ADR=`grep userdef zmp.sym | cut -c1-4`

echo
echo "---------------------------------"
echo "Overlay space address: 0x$OVR_ADR"
echo "Userdef space address: 0x$USR_ADR"
echo "---------------------------------"
echo
echo

#finalize main
sed -i "s/^userdef.*/userdef	equ	${USR_ADR}h/" zmp-zds1.z80
zxcc z80asm.com -zmp-zds1 +-/h
zxcc mload.com zmp.com=zmpx.com,zmp-zds1.hex



#--- overlays

#config
./zcc zmconfig
./zcc zmconf2
zxlink -c${OVR_ADR}h -ptext=${OVR_ADR}h,data -ozmconfig.ovr -mzmconfig.map zmconfig.obj zmconf2.obj main.obj libx.lib libc.lib


#init
./zccs zminit
zxlink -c${OVR_ADR}h -ptext=${OVR_ADR}h,data -ozminit.ovr -mzminit.map zminit.obj main.obj libx.lib libc.lib

#term
./zcc zmterm
./zcc zmterm2
./zcc zmterm3
rm -f zmterm.lib
zxlibr r zmterm.lib zmterm2.obj zmterm3.obj main.obj
zxlink -c${OVR_ADR}h -ptext=${OVR_ADR}h,data -ozmterm.ovr -mzmterm.map zmterm.obj zmterm.lib libx.lib libc.lib
rm -f zmterm.lib

#zmodem
./zcc zmxfer
./zcc zmxfer2
./zcc zmxfer3
./zcc zmxfer4
./zcc zmxfer5
./zcc zzm
./zcc zzm2
rm -f zmxfer.lib
zxlibr r zmxfer.lib zmxfer2.obj zmxfer3.obj zmxfer4.obj zmxfer5.obj zzm.obj zzm2.obj main.obj
zxlink -c${OVR_ADR}h -ptext=${OVR_ADR}h,data -ozmxfer.ovr -mzmxfer.map zmxfer.obj zmxfer.lib libx.lib libc.lib
rm -f zmxfer.lib

rm -f *.obj

echo "Done."
