#
# cmake for vdsk_server
#
cmake_minimum_required(VERSION 2.8)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../libdsk ${CMAKE_CURRENT_SOURCE_DIR}/../libdmk)
link_directories(${CMAKE_CURRENT_SOURCE_DIR}/../libdsk/build)
link_directories(${CMAKE_CURRENT_SOURCE_DIR}/../libdmk/build)

set (vdsk_server_SRCS
	cpmfs.c
	device_libdsk.c
	vdsk_server.c
	Z80_par_io.c
)

add_executable(vdsk_server ${vdsk_server_SRCS})
add_executable(receive_Z80DS receive_Z80DS.c Z80_par_io.c)
add_executable(send_Z80DS send_Z80DS.c Z80_par_io.c)

target_link_libraries(vdsk_server dsk.a dmk.a)


