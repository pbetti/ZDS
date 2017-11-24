#!/bin/bash

mzmac --rel arunz.z80
zxcc ../../software/tools/link.com ARUNZ,Z3LIB[S],DSLIB[S],SYSLIB[S,OP]
zxcc ../../software/tools/mload.com arunz=arunz.prl,t4ldr.hex
