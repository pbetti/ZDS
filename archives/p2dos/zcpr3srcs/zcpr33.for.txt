                                                        September 19, 1987
                        CP/M RoundTable -- GEnie
                            ZCPR Version 3.3

ARUNZ09F.LBR - ZCPR3
   The extended command processor of choice for ZCPR 3.3 installations.
   Version 0.9F of ARUNZ has the following new features: (1) ZEX input
   redirection is normally turned off for input prompts, but a $I
   parameter can be used to turn it on; (2) prompts will now appear
   exactly as in the script text (not always upper case); (3) all
   register references ($R parameter and configuration register) now
   have the range 0..15.

BGQUICK.LBR - ZCPR3
   Included in this library is a utility designed to ease the loading
   process of BackGrounder ii.  To use it, simply load BackGrounder ii
   in the configuration you prefer, named directories, keys and all
   included.  Then type: "BGQUICK".

BGSCRIP1.DZC - ZCPR3
   Some ideas from Jay Sage (with endorsement from Bridger Mitchell) on
   using BackGrounder ii.  Assumes ZCPR3.  BG Load and BG OFF scripts.

CD33.LBR - ZCPR3
   CD is used to log into a new directory by name or DU and to
   automatically run ST once there if it is available.  This version
   fixed a bug in the way CD worked under BackGrounder ii (unlike
   ZCPR33, BGii will not accept a command of the form DIR: to change to
   a passworded directory that is within the allowed DU range).  CD33
   detects this situation and uses a command of the form DU: to change
   directories.  This library contains Z80 assembler source statements
   and COM file.

CLEAND18.LBR - ZCPR3
   CLEANDIR sorts/packs/cleans the directory of a diskette and writes it
   back to disk.  It is for Z80-only CP/M systems.  It checks the
   directory for duplicate entries, more than one file using the same
   allocation block, bad extent numbers, bad user numbers, bad file
   names, and bad record counts and reports zero-length files.  It can
   optionally check only, without writing to the disk.  Version 1.8
   corrects an error that caused the program to crash the system if it
   tried to clean up the directory of a disk that had nothing except
   erased or zero-length entries in the directory.

CMD11.LBR - ZCPR3
   CMD is a ZCPR3 utility that may be used to define and run a command
   line.  It either accepts the command line (including semicolons)
   which follow the verb CMD onto the command line buffer or, if no
   input is provided, it prompts the user for input and then places this
   into the command line buffer.  Version 1.1 adds PUTCST call in order
   to allow shells to be nested when CMD is part of a SHSET sequence.
   SHSET.COM leaves the command status set as a shell, which would
   inhibit other shells such as VFILER from installing themselves as a
   shell.  You will need a Z80 assembler and SYSLIB, Z3LIB, and VLIB for
   macro references, to assemble the included source.

CMDPATCH.LBR - ZCPR3
   A patch file that makes two changes to CMD version 1.0.  The simple
   part is the elimination of a superfluous space after the ">" in the
   command prompt.  The more significant change is turning of the shell
   bit in the command status flag in the Z3 message buffer so that an
   error handler can take care of any bad command entered (shell errors
   always abort, flushing the command and entire shell stack).

COMIF10.LBR - ZCPR3
   COMIF.COM is a transient IF processor designed to replace the
   original IF.COM released with ZCPR3.  COMIF supports a very great
   number of additional test conditions and accepts greatly extended
   syntactic forms.  Two versions of the object file are included in
   this release.  COMIF10.COM can be renamed to IF.COM and used as a
   direct replacement for the original.  COMIF10.CIM has been linked to
   run at 8000H instead of 100H.  It can be renamed to IF.COM and used
   together with a resident FCP assembled from the new FCP10 with the
   high-memory option enabled and set to 8000H.  See the FCP10 release
   package for more information.

DD14.LBR - ZCPR3
   DD is a ZCPR3 everyday-type disk directory utility, designed for
   easiest typing.  Options include displaying all files, system files
   only, sorting by file type/file name, and horizontal file listing.
   New options include sending listing to printer and selecting files by
   file attributes (for use with ACOPY).  The display is paged, with the
   summary line last.  Typing "*.*" isn't required for "all file"
   displays that include options.  See DD14.DZC for more info.

EASE10.LBR - ZCPR3
   EASE is a full featured Z3 command line editor, history shell and
   Error Handler.  The command set (unless configured differently) is
   much like WordStar's.  EASE is meant to be more Flexible, Faster and
   Smaller than any other shell editor.

ERRATA1.Z33 - ZCPR3
   A few minor changes to the Z33FCP10 and Z33RCP07 source files are
   necessary to allow error-free assembly with the ZAS assembler.  These
   changes are described in this file.

ERRORX11.LBR - ZCPR3
   This version of ERRORX, which cancels external error handling, has
   been updated for ZCPR33, which uses the system error flag byte in the
   message buffer differently than Z30 does.  Cancelling error handling
   requires putting a null in the place where the error handler command
   line is stored.  ERRORX11 puts nulls in both places so that it will
   work with Z30 or Z33.

ERRSET13.LBR - ZCPR3
   This program displays, clears, or sets the error handler command
   line.  Error messages are given if there is no message buffer (and
   hence no external error handling) or if an attempt is made to load an
   error command line that is too long.  For the sake of neatness,
   ERRSET clears extraneous bytes in the message buffer beyond the
   terminating null of the new command line.  The built-in help screen
   describes the syntax.  Version 1.3 has been updated to ZCPR33
   compatibility using Z33LIB routines.

ERRUTILS.LBR - ZCPR3
   This library contains special versions of several programs for use
   with ZCPR33.  The COM files have been linked to run at 8000H.  In
   addition relocatable files have been provided in case you want to
   experiment with other load addresses.  The ".SLR" files are
   SLR-format REL files; the ".REL" files are Microsoft-format,
   6-significant-character-label REL files.

FOR-NXT2.LBR - ZCPR3
   The three files FOR.COM, NEXT.COM, and PERFORM.COM provide the
   ability to perform a single command or set of commands repeatedly,
   for a specified list of arguments.  Complete descriptions, including
   invocation syntax and example applications, are in the ZCPR3
   compatible help file FOR-NEXT.HLP.  Version 2 contains a modified
   version of PERFORM in which a previous (severe) defect in the way it
   handled console status.

FOR-SUPP.LBR - ZCPR3
   This collection of files is intended to take file descriptions on
   ZCPR33-based BBS's and personal ZCPR33 systems to new heights.
   Enhanced versions of Irv Hoff's FOR.COM and KFOR.COM for use with
   ZCPR-based systems, plus CLEANFOR, a Turbo utility which removes
   obsolete entries in the FOR file, and an example ZFILER.CMD file
   which simplifies the job of documenting files with KFOR.COM.
   Documentation plus source code for all files is included.

HSH33PAT.LBR - ZCPR3
   This is a patch for HSH15.COM to make it NOT skip leading spaces in
   the user-entered command lines.  This is desirable under ZCPR version
   3.3 because a leading space is a signal that the command should be
   sent directly to the extended command processor without searching for
   the COM file along the path.  The patch consists of replacing a "JP
   Z,JMPADDR" which only continues if the character checked was not a
   space or tab to an unconditional jump.  The patch is applied by
   assembling this file to a HEX file and overlaying the result on
   HSH15.COM using MLOAD.

IOPUG.LBR - ZCPR3
   This file is the ZCPR3 Input/Output Package User's Guide.  It
   explains how the IOP works, how to install it, and has programming
   examples.  An IOP is laid out in a manner similar to a BIOS.  All
   IOPs are divided into a jump table at the front and a set of
   supporting routines after the jump table.  All routines in an IOP are
   defined in terms of their function, input parameters, output
   parameters, and side effects.  The IOP Status and Control routines
   are used to initialize the IOP, determine the type of the IOP, obtain
   names of and comments on devices contained within the IOP, and select
   devices within the IOP.

LBREXT22.LBR - ZCPR3
   This program is something like Richard Conn's LGET.  The main
   difference is that this program will extract "CRUNCHED" and
   "SQUEEZED" files.  It has a brief help display, invoked by typing //
   after the name.  The only option is "U" to unsqueeze or uncrunch a
   file.  Wildcard filename(s) may be specified.  This version made
   buffer sizing automatic at runtime, fixed bug so that files will be
   extracted to current directory if no output DU or DIR is specified.

LDR16.LBR - ZCPR3
   LDR is a general-purpose package loader for ZCPR3.  No default file
   types are assumed on the list of packages, and each specified must be
   unambiguous and have a type of RCP or IOP (for Resident Command
   Package or Input/Output Package).  LDR checks to make sure that the
   files are valid packages and then loads them into memory at the
   correct locations, checking for package boundary overflow.  Version
   1.6 adds the ability to read files from a library to LDR.  This is
   significantly faster than loading them as separate files (especially
   on hard disk systems) and since each package is less than 1k, it
   makes quite a lot of sense to group them in libraries.

LED02.LBR - ZCPR3
   LED is a subset of the EASE editor.  It can be included in any non
   commercial assembly language program, providing features found in the
   Z3 shell program EASE.  LED is now easier to adapt.  Key stroke
   bindings included in the calling program (easier to change).
   Extension Commands allow calling program to react to user's input at
   LED.

LLDR.LBR - ZCPR3
   LLDR adds the ability to read files from a library to LDR.  This is
   significantly faster than loading them as separate files and since
   each package is less than 1k, it makes quite a lot of sense to group
   them in libraries.

LLF11.LBR - ZCPR3
   List Library Files - outputs a list of all files in a library (may
   run under plain CPM).  LLF Version 1.1 corrects a bug in Version 1.0
   that caused sporadic and unpredictable bomb-outs.  The bug manifested
   itself with a "TPA Overflow" error-message, for which nobody had a
   sensible explanation.  The source code for LLF has not been released.
   The modified source code for the LUDIR module, SLUDIR11.Z80 is
   included.

LPUT.LBR - ZCPR3
   The automated ZCPR3 library maker.  Doesn't replace LU and NULU, but
   will do for LBR creation what LGET does for extraction.  Combine with
   LLF or ZLDIR and you can reserve the bigger LBR handlers for times
   when you really need them.  Automatically builds the right size LBR
   for the list of member files requested, which can be a comma
   delimited series of wildcard file specs, including DU: and/or DIR:
   designations, similar to LGET, MCOPY, etc.

LX16.LBR - ZCPR3
   Library eXecute locks onto a library file, searches and extracts the
   COM file into memory at 100H, and sets up the various buffers to look
   like the COM file was executed by the ZCPR3 command processor.  LX
   parses the command line as ZCPR3 itself would.  Named directory
   references are allowed, the External FCB is loaded if available, etc.
   This version adds ZCPR33 error handling support, special syntax for
   chaining from ARUNZ's default alias feature, fixes console output.

MENU41.LBR - ZCPR3
   MENU is the ZCPR3 menu front-end processor.  It is a true ZCPR3 Shell
   which reads a *.MNU file and processes commands from it.  Its
   functions and use are described in the HELP file.  Version 4.1 is an
   update of MENU which works more efficiently under ZCPR 3.3.  Also
   adds the feature of simultaneous command execution/menu change in the
   MENU.MNU script.

MU312.LBR - ZCPR3
   This new version of the MU3 memory utility has the following changes:
   (1) the next screen can be selected with any of the three characters
   ".", ">", or "+" and the previous screen with ",", "<", or "-"; (2)
   several bugs in the screen display were fixed and the display was
   enhanced for use with reverse-video terminals; (3) the program was
   converted to a Z33 type-3 environment.  The library contains MU312 to
   run at 100H and MU312.CIM to run at 8000H.

NDRCHG10.LBR - ZCPR3
   This is an alias and ZEX file that will rename a named directory very
   quickly and neatly.  This is a good illustration of the power
   available in combining different features of Z-System, especially the
   ARUNZ, here combined with ZEX.  You must be situated on the directory
   which you wish to change and you must be running ARUNZ as your
   extended command processor.  If your named directory segment is not
   called SYS.NDR and lie on A15: then simply change the appropriate
   commands in the ZEX file to indicate this.  Insert NDRCHANG.CMD into
   your ALIAS.CMD.

PCPI/Z33.BUG - ZCPR3
   A bug report when dealing with ZCPR33 in a situation where the ZCPR33
   file is relocated during installation.

PTCAP12.LBR - ZCPR3
   PTCAP was designed to completely install a new TCAP without the need
   to manually change the user base.  It will read the new TCAP to be
   installed and the current TCAP into memory and then process the user
   base.  The users record is read in and the old terminal index number
   is used to find the old terminal id string.  The new TCAP file is
   then scanned for a match, when found, the new index number is
   calculated and placed into the user record.  You will have to edit
   the source code to suit your system needs and reassemble using M80 or
   SLR180+.  You will have to LINK with SYSLIB36.REL.

PUBPTZ10.LBR - ZCPR3
   A nice bit of work by Steve Hirsch that allows the Bridger Mitchell
   file attribute style of PUBLIC files to be used with ZRDOS1.7.  ZRDOS
   itself allows PUBLIC via whole user areas.  This method does single
   files ala' SETDRU.  This method is 'safer'.  Included is Bridger's
   original PUBLIC patch for non-ZRDOS owners and completeness.

RCPH-GKT.LIB - ZCPR3
   This command displays a list of all resident commands that are
   supported, including those in the CPR (command processor), RCP, and
   FCP.  This version uses the BIOS warm boot vector at (0001H) to
   calculate the start of CPR, which is always 1600H below BIOS.  The
   modification adds 5 bytes to the code and allows Z33RCP to find the
   CPR command list for any size system.

RENAME32.LBR - ZCPR3
   RENAME is used to change the name of one or more files.  Unlike the
   resident REN function, RENAME permits ambiguous file names and
   supports an Inspect mode that allows the user to confirm each rename
   before it is done.  Additionally, there is a Control Mode which
   allows the user to manually specify the name for each file as it is
   presented to him.  This version has a bug corrected so that a leading
   slash is now allowed before the options.  The syntax screen has been
   updated to reflect this fact and to show the type-3 load address.  The
   COM version runs at 100H; the CIM version (change to COM to use it)
   runs at 8000H.

RLX16.LBR - ZCPR3
   This library utility has been modified for compatibility with ZCPR33
   by using code from LX15.  LX15 has problems if the .LBR file is not
   found, since none of the code from LX13/LX14 was included, the name
   of the wheel protected versions of LXnn has been changed the name to
   RLXnn.  This is to indicate it's usefulness on a remote access
   system.  There is a provision to inhibit the second default library
   search.  Also, included is an equate to allow conditional assembly
   with dseg (usedseg).  Removed the internal COUT routine since it
   crashed both Xerox and Kaypro every time the program was invoked.

SALIAS1G.LBR - ZCPR3
   SALIAS is a screen oriented alias editor.  Version 1.0g fixed several
   bugs.  Also a message is printed if an alias won't fit on the screen.
   Previously, the alias would be chopped without warning.  This could
   occur after switching to a smaller screen or when reading an alias
   created with another program (the alias would need over 20 commands
   with the last ones quite long).  See SALIAS.FOR for more information
   about this release.

SAVE04.LBR - ZCPR3
   This library contains the source code to the ZCPR33 transient SAVE
   command and an object file linked to run at 9800H.  It has been
   linked with a separate data segment and the new Echelon libraries
   (not yet officially released).

SH20.LBR - ZCPR3
   This program illustrates the design of a simple shell under ZCPR3
   using Z3LIB.  The shell allows entry of multiple-command lines and
   expands all shell variable references before passing the line to
   ZCPR3 for processing.  The shell has several internal commands also.
   The library contains full Z80 source.  The principal change of
   version 2.0, is the addition of a 20-line command history capability.
   The up and down arrow keys, as defined in the TCAP, allow you to move
   backward or forward through the history list.  Several other new
   commands were added to the input editor.  A complete list of commands
   appears in the "DOC" file.

SHELLIF.MOD - ZCPR3
   Modifications to the Z3 code done by Royce Shofner that will correct
   the problem of being unable to run an alias containing flow control
   statements inside a SHSET/CMD combination, as in SHSET
   PROGNAM1;PROGRNAM2;CMD where PRONAM1 and PROGNAM2 are both aliases
   condition 'IF' statements.  In all versions of ZCPR that I've used
   from 3.0 to 3.15D SHSET will abort at this point.

SHELLIF.MZD - ZCPR3
   Modification to ZCPR3 CP to allow IF/ELSE statements inside a shell
   CMD.  If you are a heavy user of aliases and ARUNZ ALIAS.CMD files
   which contain flow control statements, and you also use the SHSET
   FNAME1;FNAME2;CMD sequence to create shells from non-shell programs;
   you have probably had problems if FNAME2 or FNAME2 were aliases which
   contained flow control statements.  This modification will greatly
   increase the flexibility of the ZCPR3 system by allowing flow control
   statements to be included inside a shell command.

SHOW11.LBR - ZCPR3
   This updated version of the SHOW utility supports the new features of
   ZCPR33.  New features have been added, and the screen displays have
   been improved.  The memory display function includes column headers
   and a memory poking function.  Resident command displays for the RCP,
   FCP, and CPR indicate by using lower case which commands are wheel
   restricted.  For the FCP all the resident options are listed as well.
   For Z33FCP, information about automatic chaining to IF.COM is also
   presented.  Almost all the configuration options for ZCPR33 are
   displayed in three new screens.

SHOW11-B.LBR - ZCPR3
   Version of SHOW for ZCPR33.  This program shows just about EVERYTHING
   about your system configuration -- what features are turned on and
   turned off, the names and types of files processed.  The displays
   have been greatly enhanced to be more logical, complete, and easy
   to read.  Has most of the features of Z33ERROR included for advanced
   error reporting.

STATPAT.Z80 - ZCPR3
   This patch fixes STAT.COM so that the DSK: USR: DEV, etc.  Options
   work correctly under ZCPR 3.3.

SUB34.LBR - ZCPR3
   SUB is derived from SuperSUB, a replacement for the SUBMIT program
   provided with CP/M.  It provides a different format for the command
   line, a command-search hierarchy like ZCPR3, a resetting of the DMA
   address, and several additional functions.  ZCPR3 specific
   enhancements, such as appending the rest of the multiple command line
   to the command file and allowing multiple commands on a single line,
   are permitted.  Version 3.4 has been modified to take advantage of
   ZCPR33's external running submit flag.  It will set the flag after
   writing the submit file.  If ZCPR33 is resident, SUB will just return
   to system, else, it will do the traditional warm boot.

VALIAS11.LBR - ZCPR3
   VALIAS1 is used to load the Command Line Buffer with a command line
   stored within ALIAS1, extracting parameters using the SUBMIT file
   convention ($n) as they are referenced in the new command line.
   VALIAS1 differs from ALIAS1 in that it contains a flag that selects
   one of two modes.  Normal mode is identical to ALIAS; the alias
   command line is substituted for the alias command, and any tail in
   the command line buffer is appended to it.  In recursive mode, any
   tail in the command line is purged.  This mode, as the name implies,
   is useful when an alias is going to call itself recursively, and the
   command tail could build up to the point of overflowing.

VFILER43.LBR - ZCPR3
   VFILER (for Video FILER) is a screen-oriented ZCPR3 shell used to
   work with individual files or groups of files.  VFILER presents a
   full-screen alphabetized display of the files in a specified
   directory that match a specified file mask.  The user may perform a
   number of operations on the file, such as copying, deleting, or
   viewing.  This version is for use with ZCPR33.  The auto install code
   was deleted.  The code was cleaned up in some relatively minor ways
   so it will assemble in its modular form with ZAS.  For a complete
   description of the operation of VFILER 4.3, see the HLP file.

VIEW40.LBR - ZCPR3
   View 4.0 is a text file viewer and a full Z-System tool.  The library
   also contains Peep 1.1, which is a 1k bare bones version which may
   require screen installation with the included overlay file.  It makes
   no use of Z-System but does understand user areas.  The source code
   for both of these is available on request.  With a few minutes
   practice, VIEW becomes a transparent way to browse files.  Because of
   filtering, noisy BBS session recordings or WordStar files can be
   viewed.  Files too large for a memory resident editor (such as LZED)
   can be broken up or portions extracted.  Small files can be
   concatenated to another file.

VMENU26.LBR - ZCPR3
   VMENU is the ZCPR3 Menu-Oriented Command Preprocessor.  It acts as a
   front-end to ZCPR3, providing a menu-oriented user interface to
   ZCPR3.  The "User Menu Command" is a single character that the user
   strikes which instructs VMENU to perform a function.  Once VMENU
   begins processing this function, it builds a command line for ZCPR3,
   optionally asking the user for further input, such as a file name,
   and then passes the command line to ZCPR3 via the Command Line
   Buffer.  The library includes the executable COM file, Z80 assembler
   language source, and an extensive help file.  Version 2.6 added a
   small change for the enhanced functionality of ZCPR 3.3.

XALIAS11.LBR - ZCPR3
   XALIAS is the front end of Rich Conn's ALIAS program and the alias
   code of VALIAS.  An editor has been added to the ALIAS code, along
   with several changes to make it less cumbersome.  The editor is a
   subset of the one in EASE.  You may change the keystrokes for any
   action with a patch utility or by changing the code and reassembling.
   See LED.Z80 and EASE.DOC for more information about the editor.

XSUBZ14.LBR - ZCPR3
   This program is a replacement for XSUB for use with ZCPR version 3.3.
   Features include always look in A0: for the $$$.SUB file, support for
   environment type 3, test for existence of another memory resident
   program which has modified the BDOS vector, inclusion of BIOS jump
   vectors so that programs that do direct BIOS calls don't go off the
   deep end, and automatic removal of itself when $$$.SUB file is empty.
   Version 1.4 has been converted to ZILOG mnemonics (will assemble with
   Z80ASM and ZAS).  The BIOS vector is no longer modified, the BIOS
   jump table is modified instead, no longer causing problems for
   programs which depend on an address at 0001H.

Z33-M80.LBR - ZCPR3
   This library contains notes on how to convert the latest version of
   ZCPR 3.3 to a form that is digestible by M80.  Also contained is a
   "DIF" file that may be merged into the released ZCPR 3.3 source to
   produce a M80 ZCPR 3.3 source file.  (Documentation and the programs
   DIF2 and SSED are included in this library.)

Z33-TM2.LBR - ZCPR3
   The fact that ZCPR 3.3 puts the ENV address in HL before loading a
   program enables us to be able to create Turbo Modula 2 programs that
   can access the features of the Z-system.  It is still something of a
   kludge, but it is possible at last.  This library contains a skeleton
   module that stores this address away for program use and a test
   module so that you can see it works and a test module which calls on
   the Module InOut to print the ENV in HEX.

Z33-ZASM.LBR - ZCPR3
   These files contain information for converting the released version
   of ZCPR33, the command processor replacement for eight-bit machines,
   so it may be compiled by the Cromemco Macro assembler (ZASM 3.04).
   ZCPR version 3.3 has been attempted to produce code that is not
   compiler specific.  There remain only a few unrecognized pseudo-ops
   and a handful of over-long labels.  A Zex script using FINREP is
   included to change the pseudo-ops and shorten the labels.

Z33ANOTE.0Z1 - ZCPR3
   This is the first in a series of application notes for ZCPR33.  This
   one describes the proper value to use in Z3BASE.LIB for the length of
   the multiple command line buffer so that (1) you get the longest
   command line possible but (2) do not end up overwriting other memory
   modules in the operating system.

Z33ANOTE.0Z2 - ZCPR3
   This is an application note on how to make effective use of the ARUNZ
   extended command processor under ZCPR33.  It applies especially to
   remote access systems (with many examples) but will give some useful
   ideas for personal systems as well.

Z33ERR07.LBR - ZCPR3
   This is a prototype ZCPR33 error handler designed to serve as an
   example of how some ZCPR33 features can be used in an advanced error
   handler.  This code displays the bad command and gives the user the
   option of replacing it, skipping over it, or aborting the entire
   command line.

Z33FCP10.LBR - ZCPR3
   The completely rewritten FCP for use with ZCPR 3.3.  It is an
   adaptation of the FCP10 released through ZSIG.  The main changes are
   that the code determines whether the IF command was invoked with a
   directory prefix in a much more efficient manner using a new Z33
   facility, and that the code loads a transient IF.COM processor with a
   type-3 environment to the correct address.  Both programs have been
   converted to work with the ZAS assembler (or the SLR assemblers).

Z33FIX.001 - ZCPR3
   There is a weakness in the way the command processor handles the
   external program flag bit in the command status flag (CSF).  The
   command processor resets the bit only after the command line buffer
   has become empty.  Otherwise, it relies on error handlers to reset
   the bit.  New error handlers like Z33ERROR could be expected do this,
   but old error handlers, which do not know about this bit in the CSF,
   certainly cannot be expected to reset it.  This file has a fix to
   solve the problem.

Z33GCONF.TZT - ZCPR3
   This is an edited copy of GEnie's CP/M RoundTable Conference which
   was held on June 10, 1987 at 9:30 P.M. EDT.  The subject was the new
   release of ZCPR (Release 3.3), the CCP replacement for CP/M systems.
   The guests were Jay Sage, David McCord, and Bridger Mitchell.

Z33IF.MZG - ZCPR3
   This file is an explanation of the "IF $1-//" verses "IF //=$1"
   mystery that Frank Gaude' pointed out in the latest Z-News.

Z33IF11.LBR - ZCPR3
   One of Jay Sage's ZCPR3.3 transient programs.  Performs advanced IF
   functions over the FCP version. This version of Z33IF has an
   additional equate to allow the extended condition options like ">="
   WITHOUT INCLUDING "=", which can conflict with the older "A=B"
   condition syntax.  When the latter had a null first token, it
   appeared to be an extended test with the option "=B", which was
   generally an illegal form. Z33IF11.COM runs at 100H; Z33IF11.CIM runs
   at 8000H.  Rename your choice to IF.COM.

Z33LIB04.LBR - ZCPR3
   This library consists of two REL files that make up the Z33LIB
   routines.  The documentation is a collection of the module headers
   from the source code (not included).  Z33LIB will probably be
   released as a commercial product at a later date.  This version is
   provided for educational and guidance purposes.  Version 0.3 has four
   new routines: RETCST, RESEPB, SETEPB, and Z33FNAME.  The REPARSE,
   PARSE2, SCAN, and PUTER3 routines have been corrected and/or
   enhanced.  Version 4 corrects a problem with the PUTER3 routine.

Z33PNOTE.001 - ZCPR3
   This programming note for ZCPR 3.3 discusses the command status flag
   and the library routine "QERROR".  The command status flag is a
   control flag stored at offset 3 (i.e., the fourth byte) in the
   message buffer.  In ZCPR30, only two bits of this flag are defined
   and used.  Bits 0 and 1 retain the identical functions in ZCPR33.  In
   addition, two more bits in the command status flag are defined and
   used.

Z33PNOTE.002 - ZCPR3
   This programming note for ZCPR 3.3 discusses the design of shells
   under ZCPR33 The ZCPR33 command processor follows a very clear and
   strict hierarchy for acquiring new commands.  The way this hierarchy
   functions is described in detail in the ZCPR33 Users Guide, this
   discussion will focus the effect this hierarchy has on the design of
   shells.

Z33PNOTE.003 - ZCPR3
   The command processor provides three standard entry points, similar
   to those provided by the BIOS, so that external programs can make use
   of the parsing code inside the command processor.  Also, the result
   of the parsing is designed to provide more information, such as
   whether or not a directory was specified explicitly and, if so,
   whether or not the directory was a valid one.  This programming note
   for ZCPR 3.3 discusses the ZCPR 3.3 file name parser.

Z33RCP02.LBR - ZCPR3
   The interim release of a new Resident Command Package (RCP) for ZCPR
   3.3 systems.  Changes include a correction to the PORT command to
   make it work properly with the HD64180 chip.  The "H" command is
   modified to work with CCP implementations that have FCPENV enabled.
   Previously, the address of the FCP was hard-coded into the RCP.  A
   minor bug in the "WHL" command is fixed.

Z33UPD.DZC - ZCPR3
   An official news release from Jay Sage about the features of ZCPR3.3
   Z3.3 is now in Beta Test (I have a copy) and should be released soon.

Z33UTIL.LBR - ZCPR3
   A selection of error handlers for Z3.3.  Both simple ERROR and video
   VERR types.  Includes .REL files for those that want to take
   advantage of 3.3's type 3 environment feature.  (see Z33UPD.DOC)

Z33VERR.LBR - ZCPR3
   This program combines the ZCPR33 prototype error handler (Z33ERR07)
   with VERR17A to produce an intelligent error handler for systems
   using ZCPR33.  The internal command line modification routines in
   Z33ERR07 have been removed and replaced with the entire VERR17A
   program.  The only other changes made to Z33ERR07 is in the submit
   file delete routine.  A test has been added to inform the user in
   case the submit file could not be deleted (possibly because the
   system vectors had been modified and ZCPR33 couldn't be found).

Z3INS14.LBR - ZCPR3
   The purpose of Z3INS is to install a group of ZCPR3 System Utilities.
   Z3INS reads in an Environment Descriptor and then reads in a file
   containing the names of the utilities to be installed.  It then reads
   in each file named and installs the proper values into it.  This
   version is revised to work properly with type-3 environment programs
   under ZCPR 3.3.

Z3TCAP26.LBR - ZCPR3
   General update of the ZCPR3 terminal emulation program.  Several new
   selections including Commodore C128, Datapoint, IBM, Wyse 100 and
   "none".  Format changes show updates in reverse chronology.  Support
   for IBM color and monochrome added to the ZCPR3 Termcap.

ZAPG.SZ - ZCPR3
   This document is a reference guide to ZCPR3 and Z-System for the
   applications programmer who wishes to take advantage of
   ZCPR3/Z-System features and functions in their applications.  It
   gathers together into one convenient document the information needed
   by the application programmer when developing ZCPR3-oriented
   applications.  This document is intended to be printed with Newword
   2.x or WS 4.

ZBOXWYSE.LBR - ZCPR3
   A Graphic Character Box for the Z System programs MENU, VMENU, and
   VFILER on the Wyse 50 Terminal.  The file ZBOXWYSE.GRF is a simple
   ASCII file that can be viewed with the TYPE command and reworked with
   most word processors that produce ASCII files in nondocument mode.
   You can even check it out with the V(iew) command in the SWEEP mode
   of NULU, though without standout mode on the commands.

ZCPR33.LBR - ZCPR3
   The official release of the ZCPR 3.3 command processor.  Adds many
   new enhancements, fixes several bugs, and allows the user greater
   flexibility in designing his system.  Those who are baffled about how
   to install it are advised to get the book "ZCPR 3.3 User's Guide"
   from Echelon.

ZDDTZ.ZZX - ZCPR3
   This simple patch makes C.B. Falconer's DDTZ respond to DIR as well
   as DU file specifications.  To install, dump any command history
   processor in memory, put copy of DDTZ.COM in same directory with this
   file and issue this command: ZEX ZDDTZ.  That's all there is to it.
   Get DDTZ.COM and it's documentation from DDTZ.LBR, available from
   Z-Nodes.

ZEX32.LBR - ZCPR3
   ZEX is an extension to EX, the submit replacement, to work with ZCPR.
   This version is changed so that the determination of whether an RSX
   is active is a bit more intelligent, and changed the method of
   calculating the CCP address so ZEX will work on both standard (0E00h
   length DOS) and non-standard (less than 0E00h length DOS) systems.
   Also translated the source to Z80 mnemonics - assembles with ZAS 3.0.

ZF10F.AZT - ZCPR3
   These are some informal comments by Rick Charnes regarding the
   release of Jay Sage's ZFILER which has the extraordinary ability to
   run a macro command line upon ALL tagged files.  These notes include
   some suggestions for making the display more anesthetically pleasing,
   and explanations on creating group macros using NULU and GO to add
   files to a library.

ZF10H.LBR - ZCPR3
   ZCPR file maintenance tool.  With SWEEP-like capabilities and much
   more.  This version fixed the bug in the logging in of the displayed
   directory with the "Z" command.  It worked under Z33 but not under
   BackGrounder II or CP/M.  Added options how the ZFILER.CMD file is
   searched for.  ZFILER will now run under GO.  See ZFHIST-H.DOC for
   details.

ZFDOCS.LBR - ZCPR3
   This library contains a compilation of the documentation from
   previous releases of ZFILER.  Also contains a configuration patch
   file.

ZMANG20.LBR - ZCPR3
   ZMANAGER is a ZCPR shell that will display $SYS files, amount of free
   space, size of a program and allow renaming and deleting of files.
   ZMANAGER has gone through many changes since the last released update
   (see ZMANG.HZS and ZMANG20.UZD).  This release incorporates many
   changes to make it more compatible with ZFILER/VFILER.  It also
   allows more characters to be used as menu selections.

ZPATCH11.LBR - ZCPR3
   ZPATCH is a full-featured, screen-oriented file patching editor in
   the genre of PATCH and EDFILE/ZEDFILE.  IT uses the ZCPR3 TCAP
   facility to acquire the necessary terminal characteristics.  It can
   handle files of any size, search for strings in hexadecimal or ASCII
   and is a full ZCPR3 shell for ease of use with debuggers.  Source
   code for the SLR Z80ASM/SLRNK tools is included.

