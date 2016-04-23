cmake_minimum_required(VERSION 2.6)
project(trs2bin)

set(trs2bin_SRCS
    trs2bin.c
 )

add_executable(trs2bin ${trs2bin_SRCS})

install(TARGETS trs2bin RUNTIME DESTINATION bin)
