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

ZWSLIB = zwins.a
ZWS_SRC = ./zwin_simple
ZWS_OBJ = ./zwsobj

OBJ_SUBDIRS = $(OBJ_DIR) $(CPM_OBJ) $(ZWS_OBJ)

all: dirmake darkstar.inc cpm0.rel $(CBIOSLIB) $(CPMLIB)  $(ZWSLIB) c_bios.h cpm.h zwins.h

# Enumerating of every *.z80/*.c as *.rel and using that as dependency
$(CBIOSLIB): $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.rel,$(wildcard $(SRC_DIR)/*.c))
	$(AR) $(ARFLAGS) $@ $^


$(CPMLIB): $(patsubst $(CPM_SRC)/%.c,$(CPM_OBJ)/%.rel,$(wildcard $(CPM_SRC)/*.c))
	$(AR) $(ARFLAGS) $@ $^

$(ZWSLIB): $(patsubst $(ZWS_SRC)/%.c,$(ZWS_OBJ)/%.rel,$(wildcard $(ZWS_SRC)/*.c))
	$(AR) $(ARFLAGS) $@ $^

#Compiling objects
$(OBJ_DIR)/%.rel: $(SRC_DIR)/%.c
	$(CC) $(CCFLAGS) $(INCLUDE_DIR) -o $@ $^
	@rm -f $(SRC_DIR)/*.lst $(SRC_DIR)/*.sym $(SRC_DIR)/*.asm
# 	$(AS) $(ASFLAGS) $@  $<
# 	@rm -f $(SRC_DIR)/*.lst

$(CPM_OBJ)/%.rel: $(CPM_SRC)/%.c
	$(CC) $(CCFLAGS) $(INCLUDE_DIR) -o $@ $^
	@rm -f $(CPM_SRC)/*.lst $(CPM_SRC)/*.sym $(CPM_SRC)/*.asm

$(ZWS_OBJ)/%.rel: $(ZWS_SRC)/%.c
	$(CC) $(CCFLAGS) $(INCLUDE_DIR) -o $@ $^
	@rm -f $(ZWS_SRC)/*.lst $(ZWS_SRC)/*.sym $(ZWS_SRC)/*.asm

darkstar.inc: darkstar.mac
	@rm -f darkstar.inc
	@sed -e "s/EQU/.equ/" darkstar.mac > darkstar.tmp
	sed -e "s/\\$$/0x/" darkstar.tmp > darkstar.inc
	@rm -f darkstar.tmp

test.com: darkstar.inc cpm0.rel test.c $(CPMLIB) $(CBIOSLIB) $(ZWSLIB)
	$(CC) $(CCFLAGS) $(INCLUDE_DIR) test.c
	$(CC) $(LDFLAGS) $(LIB_DIR) -o test.ihx cpm0.rel test.rel -lc_bios.a -lcpm.a -lzwins.a
	hex2bin -p 00 test.ihx
	@mv -f test.bin test.com
# 	@rm -f *.lk *.map *.mem *.noi *.rst *.sym

cpm0.rel: darkstar.inc c_bios/cpm0.s
	$(AS) $(ASFLAGS) -o ./cpm0.rel c_bios/cpm0.s
	@rm -f ./cpm0.lst


dirmake: .dirmake
	@for i in $(OBJ_SUBDIRS); do \
		mkdir -p $$i; \
	done

.dirmake:
	@touch .dirmake

distclean: clean
	rm -f *.com *.rel *.o *.a
	for i in $(OBJ_SUBDIRS); do \
		rm -rf $$i; \
	done

clean:
	rm -f $(OBJ_DIR)/*.lst
	for i in $(OBJ_SUBDIRS); do \
		cd $$i; \
		rm -f *.lst *.sym *.asm *.adb; \
		cd ..; \
	done
	rm -f Makefile.bak *.lst *.ihx *.bin *.hex *.o darkstar.inc .dirmake *.lk *.map *.mem *.noi *.rst *.sym
	rm -f test.asm test.cdb test.adb


rebuild: distclean all
