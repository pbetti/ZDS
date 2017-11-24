#
# cmake for libdsk
#

cmake_minimum_required(VERSION 2.8)
INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR})


set(libdsk_SRCS
	compbz2.c
	compdskf.c
	compgz.c
	compress.c
	compsq.c
	comptlzh.c
	crc16.c
	crctable.c
	drvadisk.c
	drvcfi.c
	drvcpcem.c
	drvdos16.c
	drvdos32.c
	drvdskf.c
	drvint25.c
	drvlinux.c
	drvlogi.c
	drvmyz80.c
	drvntwdm.c
	drvnwasp.c
	drvposix.c
	drvqm.c
	drvrcpm.c
	drvsimh.c
	drvtele.c
	drvwin16.c
	drvwin32.c
	drvydsk.c
	dskcheck.c
	dskcmt.c
	dskdirty.c
	dskerror.c
	dskfmt.c
	dskgeom.c
	dskjni.c
	dsklphys.c
	dskopen.c
	dskpars.c
	dskread.c
	dskreprt.c
	dskretry.c
	dskrtrd.c
	dsksecid.c
	dskseek.c
	dsksgeom.c
	dskstat.c
	dsktread.c
	dsktrkid.c
	dskwrite.c
	remote.c
	rpccli.c
	rpcfork.c
	rpcfossl.c
	rpcmap.c
	rpcpack.c
	rpcserv.c
	rpctios.c
	rpcwin32.c
)


add_library(dsk STATIC ${libdsk_SRCS})

# target_link_libraries(libdsk ${QT_LIBRARIES} rt SM ICE m Xext X11)

