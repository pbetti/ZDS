#
#++
#  FACILITY:MAKEFILE For vdsk_server
#
#  MODULE DESCRIPTION:
#
#
#  AUTHORS:
#      Piergiorgio Betti
#
#  CREATION DATE:  May 15, 2006
#
#  MODIFICATION HISTORY:
#
#  -[Date]- -[Who]------------- -[What]---------------------------------------
#--
#
DIRNAME	= vdsk_server
SUBDIRS	= libdmk libdsk src
EXES	= vdsk_server receive_Z80DS send_Z80DS
#
#
all:
	@for i in $(SUBDIRS); do \
		cd $$i; \
 		if [ ! -f build/Makefile ]; then \
			mkdir -p build; \
			cd build; \
			cmake -DCMAKE_BUILD_TYPE=Debug ../;\
			cd ..; \
		fi; \
		cd build; make; \
		cd ../..; \
	done
	cp src/build/receive_Z80DS src/build/send_Z80DS src/build/vdsk_server .

clean:
	for i in $(SUBDIRS); do \
		if [ -f $$i/build/Makefile ]; then \
			cd $$i/build; make clean; cd ../..; \
		fi; \
	done
	rm -f $(EXES)

realclean:
	rm -rf src/build
	rm -rf libdsk/build
	rm -f $(EXES)

depend:
	@echo "Depencies are generated at compile time."




