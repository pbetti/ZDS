#
# Unix Makefile for CP/M 3.1
#

BDOS = resbdos3.spr bnkbdos3.spr

ZXCC = zxcc

MAC=mac.com
RMAC=rmac.com
LINK=link.com

BINARIES= bnkbdos3.spr resbdos3.spr
SOURCES= resbdos.asm bnkbdos.asm

all:	$(BDOS) cpmldr.rel

############################################################################
#
# Build tools
#
hexcom:		hexcom.c
	${CC} -o hexcom hexcom.c

hexpat:		hexpat.c
	${CC} -o hexpat hexpat.c

##############################################################################

resbdos3.spr:	resbdos.rel
	$(ZXCC) $(LINK) resbdos3 +-= +resbdos +-[os]

# bdos3.spr:	cpmbdosx.rel
# 	$(ZXCC) $(LINK) bdos3 +-= cpmbdosx +-[os]

bnkbdos3.spr:	bnkbdos.rel
	$(ZXCC) $(LINK) bnkbdos3 +-= bnkbdos +-[os]


##############################################################################
#
# Generic build rules
#

%.obj:	%.asm
	$(THAMES) :F2:asm80 $< debug


###########################################################################
#
# COM files from hex files
#
%.com:	%.hex hexcom
	./hexcom $@ < $<

###########################################################################
#
# HEX files from asm source
#
%.hex: %.asm
	$(ZXCC) $(MAC) `basename $< .asm`

###########################################################################
#
# PRL and RSX files from .REL files
#
%.prl:	%.rel
	$(ZXCC) $(LINK) `basename $< .rel` +-[OP]

%.spr:	%.rel loader*.tmp
	$(ZXCC) $(LINK) `basename $< .rel` +-[OS]

%.rsx:	%.rel
	$(ZXCC) $(LINK) `basename $< .rel` +-[OP]
	mv -f `basename $< .rel`.prl `basename $< .rel`.rsx

%.rel:	%.asm
	mzmac --rel -m $<

#
#
#
clean:
	rm -f $(MCOMS) $(HEXS) $(BLKS) *.lst *.rel *.sym *.tra *.rsx *.spr \
	*.mod *.obj loader*.tmp help.hlp *.hex *.prl ccp.com
