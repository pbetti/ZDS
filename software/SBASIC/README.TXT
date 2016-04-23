S-BASIC is a native-code compiler for a "structured" dialect of 
the BASIC programming language for 8-bit microcomputers having a 
Z80 CPU and running under the CP/M operating system.  S-BASIC 
achieved a reasonably wide distribution as a result of being 
included with the bundled software for the Kaypro II, IV and 10. 
(Its creator, Gilbert Ohnysty, became Kaypro's chief of software 
engineering). However, it never obtained much popularity, due in 
part to its terse and often cryptic reference manual (which 
lacked sufficient tutorial material) but also due, one suspects, 
to the introduction of Turbo Pascal into the market place.  
Nevertheless, S-BASIC remains a neat and elegant experiment in 
programming language design.

The files included with this distribution of S-BASIC are as 
follows:

SBASIC.COM     SBASIC compiler
OVERLAYB.COM   compiler support file
BASICLIB.REL   compiler support file
USERLIB.REL    compiler support file

SBASIC.HLP    a "help" file with information on key words, etc.

Several example programs
    XAMN.BAS        -  Disk editor
    LIBRARY.BAS     -  A collection of useful functions
    MEM.BAS         -  Display CP/M memory map

NOTES.LBR     Explanations and tips
    INTRO.TXT       - Introduction to SBASIC
    EOF.TXT         - How to test for EOF on disk files
    BDOSCALL.TXT    - How to call BDOS and BIOS functions
    STRUCT.TXT      - Writing "structured" programs in SBASIC

The "help" file is a straight ASCII file that is formatted for 
viewing using any of the many CP/M public domain "help" 
utilities.  One of those, HELP.COM,* is included in the event
you don't have one.  Just type:  HELP SBASIC
 
