#
#++
#
#  MODULE DESCRIPTION:
#  Top level Makefile
#
#  AUTHORS:
#  Piergiorgio Betti <pbetti@lpconsul.net>
#
#  LICENSE: See "License.txt" under top-level source directory
#
#  HISTORY:
#  -[Date]- -[Who]------------- -[What]---------------------------------------
#  24.08.14 P. Betti            Creation date
#--
#

# SDCC commands
CCC = sdcc
CAS = sdasz80
# ZCC commands
# CCC = zcc
# CAS = z80asm


INCLUDE_DIR = -I.

# Compilation / Assembly / Linking flags
#SDCC
CCC_FLAGS = -mz80 -c
CAS_FLAGS = -plo
CLD_FLAGS = -mz80 --no-std-crt0 --code-loc 0x120 --data-loc 0
#ZCC
# CCC_FLAGS = +zds
# CAS_FLAGS =
# CLD_FLAGS =


# all:
# 	$(CCC) $(CCC_FLAGS) $(INCLUDE_DIR) -o fdisk.bin fdisk.c
# 	@rm -f *.asm *.lk *.map *.mem *.noi *.rst *.sym

all: fdisk.com

fdisk.com: darkstar.inc zds0.rel c_bios.rel fdisk.c
	$(CCC) $(CCC_FLAGS) $(INCLUDE_DIR) fdisk.c
	$(CCC) $(CLD_FLAGS) -o fdisk.ihx zds0.rel c_bios.rel fdisk.rel
	hex2bin -p 00 fdisk.ihx
	@mv -f fdisk.bin fdisk.com
	@rm -f *.asm *.lk *.map *.mem *.noi *.rst *.sym

zds0.rel: zds0.s
	$(CAS) $(CAS_FLAGS) zds0.s

c_bios.rel: c_bios.z80 darkstar.inc
	$(CAS) $(CAS_FLAGS) c_bios.z80

darkstar.inc: darkstar.mac
	@rm -f darkstar.inc
	@sed -e "s/EQU/.equ/" darkstar.mac > darkstar.tmp
	sed -e "s/\\$$/0x/" darkstar.tmp > darkstar.inc
	@rm -f darkstar.tmp

clean:
	rm -f *.lst *.ihx *.bin *.hex *.o *.rel darkstar.inc
