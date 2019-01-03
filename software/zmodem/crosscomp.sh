#!/bin/bash

rm -f log

# libx
./zcc getline
./zcc stindex
./zcc fakemall
zxlibr r libx.lib getline.obj stindex.obj fakemall.obj

#zmp
./zccs zmp
./zccs zmp2
./zcc ovloader
./zcc zmmem
echo -e "userdef.as\c"
zxc -c userdef.as  | sed 1,2d
echo -e "ovbgn.as\c"
zxc -c ovbgn.as  | sed 1,2d
echo -e "userdef\c"
zxc -fzmp.sym userdef.obj zmp.obj zmp2.obj ovloader.obj zmmem.obj ovbgn.obj -lx  | sed 1,2d
rm -rf zmpx.com
mv userdef.com zmpx.com
echo -e "zxcc symtoas zmp.sym\c"
zxcc symtoas zmp.sym | sed 1,2d
echo -e "zxas main.as\c"
zxas main.as  | sed 1,2d

OVR_ADR=`grep _ovbgn zmp.sym | cut -c1-4`
USR_ADR=`grep userdef zmp.sym | cut -c1-4`

echo
echo "---------------------------------"
echo "Overlay space address: 0x$OVR_ADR"
echo "Userdef space address: 0x$USR_ADR"
echo "---------------------------------"
echo

#finalize main
sed -i "s/^userdef.*/userdef	equ	${USR_ADR}h/" zmp-zds1.z80
echo zxcc z80asm.com -zmp-zds1 +-/h
zxcc z80asm.com -zmp-zds1 +-/h | sed 1,2d
echo zxcc mload.com zmp.com=zmpx.com,zmp-zds1.hex
zxcc mload.com zmp.com=zmpx.com,zmp-zds1.hex | sed 1,2d



#--- overlays

#config
./zcc zmconfig
./zcc zmconf2
echo "Linking zmconfig.ovr"
zxlink -c${OVR_ADR}h -ptext=${OVR_ADR}h,data -ozmconfig.ovr -mzmconfig.map zmconfig.obj zmconf2.obj main.obj libx.lib libc.lib


#init
./zccs zminit
echo "Linking zminit.ovr"
zxlink -c${OVR_ADR}h -ptext=${OVR_ADR}h,data -ozminit.ovr -mzminit.map zminit.obj main.obj libx.lib libc.lib

#term
./zcc zmterm
./zcc zmterm2
./zcc zmterm3
rm -f zmterm.lib
zxlibr r zmterm.lib zmterm2.obj zmterm3.obj main.obj
echo "Linking zmterm.ovr"
zxlink -c${OVR_ADR}h -ptext=${OVR_ADR}h,data -ozmterm.ovr -mzmterm.map zmterm.obj zmterm.lib libx.lib libc.lib libx.lib
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
echo "Linking zmxfer.ovr"
zxlink -c${OVR_ADR}h -ptext=${OVR_ADR}h,data -ozmxfer.ovr -mzmxfer.map zmxfer.obj zmxfer.lib libx.lib libc.lib
rm -f zmxfer.lib

rm -f *.obj

echo "Done."
