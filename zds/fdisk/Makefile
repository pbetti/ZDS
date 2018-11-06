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

TARGET = fdisk
LIBS = c_bios.a cpm.a

# SDCC commands
CC = sdcc
AS = sdasz80
AR = sdar

# Compilation / Assembly / Linking flags
CCFLAGS = -mz80 -c
ASFLAGS = -plo -y
LDFLAGS = -mz80 --no-std-crt0 --code-loc 0x120 --data-loc 0
ARFLAGS = -rc


SYSLIB_PATH = ../../syslibs
SYS_INCLUDE_PATH = ../../syslibs

INCLUDE_DIR = -I. -I$(SYS_INCLUDE_PATH)
LIB_DIR = -L. -L$(SYSLIB_PATH)
PROLOGUE = $(SYSLIB_PATH)/cpm0.rel
LIB_LINK = $(patsubst %,-l%,$(LIBS))
LIB_DEP = $(patsubst %,$(SYSLIB_PATH)/%,$(LIBS))


all: $(TARGET).com

$(TARGET).com: darkstar.inc $(PROLOGUE) $(TARGET).c $(LIB_DEP)
	$(CC) $(CCFLAGS) $(INCLUDE_DIR) $(TARGET).c
	$(CC) $(LDFLAGS) $(LIB_DIR) -o $(TARGET).ihx $(PROLOGUE) $(TARGET).rel $(LIB_LINK)
	hex2bin -p 00 $(TARGET).ihx
	@mv -f $(TARGET).bin $(TARGET).com
	@rm -f *.asm *.lk *.map *.mem *.noi *.rst *.sym

$(PROLOGUE):
	@sh -c "cd $(SYSLIB_PATH); make"

darkstar.inc: darkstar.mac
	@rm -f darkstar.inc
	@sed -e "s/EQU/.equ/" darkstar.mac > darkstar.tmp
	@sed -e "s/\\$$/0x/" darkstar.tmp > darkstar.inc
	@rm -f darkstar.tmp

clean:
	rm -f *.lst *.ihx *.bin *.hex *.o *.rel darkstar.inc *.lk *.map *.mem *.noi *.rst *.sym
