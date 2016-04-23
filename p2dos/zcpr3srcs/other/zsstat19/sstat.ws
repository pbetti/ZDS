.op
.heSSTAT.WS                    02/06/86                    Page #
-----------------------------------------------------------------
                Information on the SSTAT program
-----------------------------------------------------------------

Description
-----------
SSTAT is a substitute for the program STAT.COM that Digital 
Research supplies with the CP/M operating system.  It does most 
of the things that STAT.COM does and has some additional 
capabilities.  Particularly, SSTAT allows you to:

     - view a disk DIRECTORY in "ring" format and move
       forward or backward, from file to file

     - see the SIZE of each file in Records, Kilobytes, Kilobytes
       allocated (rounded to disk block size), and directory
       extents

     - get disk space information including:

          1) number  of files on the current user area
          2) K bytes occupied on the current user area
          3) K bytes occupied on the current drive
          4) K bytes free on the current drive

     - display disk characteristics (just like STAT DSK:)

     - display the IOBYTE: (like STAT DEV:)

     - show the system memory map

     - change file attributes interactively.  The archive 
       attribute is supported.

Lacking in SSTAT is the capability to change the IOBYTE.  You'll 
need STAT.COM or a system configuration program to do this.


Operation
---------
With SSTAT you "log-on" to a drive and user area, just like you 
do with the popular SWEEP-style utilities.   A drive/user (DU:) 
and file mask can be entered from the system prompt at startup or 
can be entered after the program is running.  Here are some 
command examples:

     A0>sstat //     (prints a short usage message)

     A0>sstat        (no argument, logs all files on A0:)

     A0>sstat B15:   (logs all files on drive B:, user 15:)

     A0>sstat C:*.ASM    (logs all .ASM files on C0:)

     A0>sstat 8:SSTAT.*  (logs all SSTAT files on A8:)Š
Once the program has started you have the following commands at 
your disposal:

            Command Key             Function
         -------------------  ----------------------
	 <Ctrl-E> or <CR>     move forward one file
	 <Ctrl-X> or <B>      move back one file
	 <Ctrl-S> or <Ctrl-H> move the cursor left
	 <Ctrl-D> or <SPACE>  move cursor right
	 <Ctrl-T> or <T>      toggle file attribute
	 <Ctrl-A> or <A>      set file attributes
	             <F>      find a file
	             <I>      print disk information
	             <L>      log new DU:
		     <N>      next line auto-advance on/off
	             <S>      print free space
	             <X>      quit and return to CP/M
	             </>      print this help menu

The first four commands above are self explanatory as are the 'I' 
, 'S' and '?' commands.

The Ctrl-T and 'T' keys allow you to "toggle" the file attri
butes.  This means that each successive use of the command flip-
flops the attribute on/off/on, etc.  This works on all eight 
filename attributes as well as the R/O, System, and Archive 
attributes.  If the program has been properly installed (see 
below) the attributes that are ON will be displayed on your CRT 
with a special video attribute.  Attributes are not actually SET 
until you use the Ctrl-A or 'A' command.  When you do so, all 
changes you have made are written to the disk directory.

The display uses special "attribute strings" to show the status 
of the R/O, SYS, and ARC attributes.  These strings reflect the 
directory status of the attributes, not the tagged status, so 
they will only be updated when you use the Ctrl-A or 'A' 
commands.

The program may auto-advance to the next file after you use the 
toggle command.  You can use the 'N' command to turn this feature 
on or off.

The 'F' key allows you to find a particular file in the 
directory.  This is useful if you have a very big directory.  You 
don't need to enter a complete file name for this to work.  For 
instance you could simply enter the letter 'S' in response to the 
"Enter filespec: " prompt, and SSTAT would move you to the first 
file it finds beginning with the letter 'S.'

The 'L' command allows you to change the logged drive/user/file 
mask.  It works just like the command argument file spec 
described above.  You may enter a drive letter, user number, 
and/or file name (with wild cards), in any combination.  
IMPORTANT:  if you enter a bad DU: or a file mask for which there Šis no match, SSTAT will insist that you enter a good filespec 
before proceeding.   If in doubt, enter *.*.

You may use 'X' to return to CP/M.  No warm boot will occur.  You 
may also use control-C to abort the program at any time.

Installation
------------
SSTAT can be run "right out of the can."  You will find it most 
useful, however, if you take the trouble to install it for your 
terminal.  An overlay file, SS-OVRxx.ASM, has been provided to 
assist you.  Use it as follows:

     1) with a text editor, load SS-OVRxx.ASM.  Find the labels 
ATTON: and ATTOFF: and install the codes necessary to turn your 
terminal's video attributes on and off.  You have four bytes to 
use for each of these strings.  You cannot use more space than 
that.  Fill any unused bytes with zeros.  INVERSE VIDEO is the 
most suitable video function to use.

	While you're at it you can also change:

	MAXDRV:  -- your maximum accessible drive
	MAXUSR:  -- your maximum accessible user
	MAXNARG: -- the maximum number of DIRECTORY EXTENTS
		    that will be loaded.  Each extent takes
		    17 bytes of RAM
        ADVANC:  -- determines the default status of the
                    "auto-advance to next line" feature

     2) assemble the SS-OVR file with M80 or ZAS, etc.

     3) overlay the SSTAT.HEX file with the SS-OVRxx.HEX file.

	For example, using MLOAD:

        A>mload sstat.com=sstat18.hex,ss-ovr14.hex


	Or using DDT:

	A>ddt sstat18.obj<cr> 
	DDT VERS 2.2
	NEXT  PC
	1280 0100
	-iss-ovr14.hex<cr>
	-r<cr>
	NEXT  PC
	1280 0100
	-^C

	A>save 18 sstat.com<cr>

That's all there is to installation!
Š                 Copyright Notice and Disclaimer
-----------------------------------------------------------------
SSTAT is Copyright (C) by David Jewett, III - 1986.  You shall 
not use this program for commercial purposes or for monetary gain 
without written permission from the author.

The author will assume no liability for any loss or damage 
sustained through the use of this program.
-----------------------------------------------------------------
