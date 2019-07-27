

		Release notes for the KISS/Mini 68000 BIOS ROMs
			version 10.2  of  16-May-2016
			

NEW:
	1.  BIOS command processor for executing stand-alone programs directly
	from the ROM BIOS.  The built-in commands are displayed with the 'help'
	command.  Command (.CMD) files, .coff (.OUT), CP/M format (.68K and 
	.SYS), and .elf (.ELF) format exectuables are supported.  The CP/M
	format files may make BIOS calls only, no CP/M calls.
	
	2.  FAT32 and FAT16 are supported, if they are the first partition on
	the IDE (probably Compact Flash) interface.
	
	3.  Automatic booting may be enabled in the Setup procedure.  If it
	is enabled, then after a timeout the file "BOOT.CMD" in the FAT file-
	system is executed.  Generally this is used to boot 68030 Linux on the 
	KISS board.
	
	4.  P.O.S.T. diagnostics are run every time the system is booted.  For
	both KISS and Mini systems, 32K of SRAM undergoes a test of every bit
	in the chip (lowest chip, for Mini).  The flashing run light is used to
	indicate a specific error condition.

	5.  If P.O.S.T. is passed the entire memory is cleared.  A RESET 
	exception will trap into the extensive memory diagnostic.  This diag-
	nostic tests the entire main memory, and will run until halted
	manually.  The terminal output looks very much like the ROM memory
	tests for KISS:  TEST3.BIN & TEST4.BIN.
	
	6.  CP/M-68 is now part of both the Mini & KISS BIOSs.  The two are
	separate compilations, needed because of instruction set differences,
	primarily supervisor mode.  One of the first uses of CP/M on both
	systems is to access the FDISK utility, for configuring slices and
	FAT filesystems on CF or other IDE devices.  The FDISK manual is on
	the F> file system of the 512K ROMs.
	
	7.  CP/M-68 now supports the 8Mb slice CP/M file systems, which are
	compatible with UNA and RomWBW on the Z80/Z180 systems.  In addition,
	CP/M-68 supports the CP/M partition type 0x52 for filesystems above
	8Mb.  512Mb is the upper limit, but the allocation blocks are so large
	that such a large CP/M drive is not recommended.


	
OLD:
	1.  CP/M-68 on the Mini-M68k board.
	2.  Linux (68030) on the KISS-68030 board.




Installation:
	This ROM image, when booted for the very first time, will require
	that your terminal speed is set to 9600 bps.  You may change this
	speed to anything you wish within the Setup menu.

	
	

P.O.S.T. error codes:
	Flashing RED on KISS, flashing GREEN on Mini.
	
	7-flashes:  The data path to SRAM is compromised.  Probably a solder
		problem, a broken trace, or poorly seated chip.
	6-flashes:  Possible crossed or shorted data lines.  Cause likely
		same as above.
	5-flashes:  Error accessing the UART on the MF/PIC board.  The board
		must be set for address 0x40.  P.O.S.T. will continue, but
		terminal output is in question.
	1-flash:  KISS only.  Informational:  the DRAM is about to be primed
		for access.  This will always be seen on the KISS board.
				


Compilation:

The BIOS and CP/M-68 programs compile using the Linux-64 cross-development 
tools which include GCC 4.1.1 (64-bit).  The cross development tools are 
contained in a separate tarball.


--John Coffman
<johninsd@gmail.com>


