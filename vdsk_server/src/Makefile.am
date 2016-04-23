bin_PROGRAMS = vdsk_server send_Z80DS receive_Z80DS
vdsk_server_SOURCES = vdsk_server.c cpmfs.c cpmfs.h device.h device_libdsk.c \
		cpmdir.h Z80_par_io.c

# set the include path found by configure
INCLUDES = -I$(HOME)/vdsk/include $(all_includes)

# the library search path.
vdsk_server_LDFLAGS = $(all_libraries) 
#AM_CFLAGS = -DDISKDEFS=\"/home/pbetti/vdsk/share/diskdefs\" -DFORMAT=\"myz80\" -DHAVE_LIBDSK_H
AM_CFLAGS = -DDISKDEFS=\"/usr/local/share/diskdefs\" -DFORMAT=\"myz80\" -DHAVE_LIBDSK_H
vdsk_server_LDADD = -ldsk
noinst_HEADERS = Z80_par_io.h
send_Z80DS_LDFLAGS = $(all_libraries)

send_Z80DS_SOURCES = send_Z80DS.c Z80_par_io.c
receive_Z80DS_SOURCES = receive_Z80DS.c Z80_par_io.c
