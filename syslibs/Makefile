#
#++
#
#  MODULE DESCRIPTION:
#  syslibs Makefile
#
#  AUTHORS:
#  Piergiorgio Betti <pbetti@lpconsul.net>
#
#  LICENSE: See "License.txt" under top-level source directory
#
#  HISTORY:
#  -[Date]- -[Who]------------- -[What]---------------------------------------
#  26.09.18 P. Betti            Creation date
#--
#

# SDCC commands
CC = sdcc
AS = sdasz80
AR = sdar


INCLUDE_DIR = -I.
LIB_DIR = -L.

# Compilation / Assembly / Linking flags
#SDCC
CCFLAGS = -mz80 -c
ASFLAGS = -plo -y
# LDFLAGS = -mz80 --no-std-crt0 --code-loc 0x120 --data-loc 0
LDFLAGS = -mz80 --no-std-crt0 --code-loc 0x120 --data-loc 0
ARFLAGS = -rc

CBIOSLIB = c_bios.a
SRC_DIR = ./c_bios
OBJ_DIR = ./obj

CPMLIB = cpm.a
CPM_SRC = ./cpm
CPM_OBJ = ./cpmobj

all: dirmake darkstar.inc $(CBIOSLIB) $(CPMLIB)

# Enumerating of every *.z80/*.c as *.rel and using that as dependency
$(CBIOSLIB): $(patsubst $(SRC_DIR)/%.z80,$(OBJ_DIR)/%.rel,$(wildcard $(SRC_DIR)/*.z80))
	$(AR) $(ARFLAGS) $@ $^


$(CPMLIB): $(patsubst $(CPM_SRC)/%.c,$(CPM_OBJ)/%.rel,$(wildcard $(CPM_SRC)/*.c))
	$(AR) $(ARFLAGS) $@ $^

#Compiling objects
$(OBJ_DIR)/%.rel: $(SRC_DIR)/%.z80
	$(AS) $(ASFLAGS) $@  $<
	@rm -f $(SRC_DIR)/*.lst

$(CPM_OBJ)/%.rel: $(CPM_SRC)/%.c
	$(CC) $(CCFLAGS) $(INCLUDE_DIR) -o $@ $^
	@rm -f $(CPM_SRC)/*.lst $(CPM_SRC)/*.sym $(CPM_SRC)/*.asm

darkstar.inc: darkstar.mac
	@rm -f darkstar.inc
	@sed -e "s/EQU/.equ/" darkstar.mac > darkstar.tmp
	sed -e "s/\\$$/0x/" darkstar.tmp > darkstar.inc
	@rm -f darkstar.tmp

test.com: darkstar.inc cpm0.rel test.c $(CPMLIB) $(CBIOSLIB)
	$(CC) $(CCFLAGS) $(INCLUDE_DIR) test.c
	$(CC) $(LDFLAGS) $(LIB_DIR) -o test.ihx cpm0.rel test.rel -lc_bios.a -lcpm.a
	hex2bin -p 00 test.ihx
	@mv -f test.bin test.com
# 	@rm -f *.lk *.map *.mem *.noi *.rst *.sym

cpm0.rel: darkstar.inc c_bios/cpm0.s
	$(AS) $(ASFLAGS) -o ./cpm0.rel c_bios/cpm0.s


dirmake: .dirmake
	@mkdir -p $(OBJ_DIR)
	@mkdir -p $(CPM_OBJ)

.dirmake:
	@touch .dirmake


clean:
	rm -f $(OBJ_DIR)/*.rel $(CBIOSLIB) Makefile.bak *.lst *.ihx *.bin *.hex *.o *.a *.rel darkstar.inc .dirmake *.lk *.map *.noi *.sym
	rm -f $(CPM_OBJ)/*.lst $(CPM_OBJ)/*.sym $(CPM_OBJ)/*.asm $(CPM_OBJ)/*.rel  $(CPM_OBJ)/*.adb
	rm -f $(OBJ_DIR)/*.lst


rebuild: clean all
