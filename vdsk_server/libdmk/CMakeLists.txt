#
# cmake for libdmk
#

cmake_minimum_required(VERSION 2.8)
INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR})


set(libdmk_SRCS
	libdmk.c
)


add_library(dmk STATIC ${libdmk_SRCS})

# target_link_libraries(libdmk ${QT_LIBRARIES} rt SM ICE m Xext X11)

