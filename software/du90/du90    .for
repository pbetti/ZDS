DU v. 9.0 is a further development of Ward Christensen's DU program.
This version is specific to CP/M+ and takes advantage of this to
use BDOS 10 for the creation of the command buffer which can
therefore be repeated by the use of Ctrl-W.  A 'Handler' module has
been added to take care of buffering from 128 byte sectors to
physical sector sizes, so that disk access is reduced.  The disk
mapping routine has been substantially revised, and the 'K' function
now has the option to add to existing files.
