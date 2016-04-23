     After the tremendous effort I put into producing my last column andç
ZCPR33 before leaving on summer vacation, I was really burned out.  Iç
hardly touched the computer or even thought about programming all summer. ç
This was quite remarkable, since for months I had practically lived inç
front of that computer screen and thought I would have severe withdrawalç
symptoms if I didn't get my usual daily fix.  I was glad the last issue ofç
TCJ came out a bit behind schedule, because three weeks ago I reallyç
couldn't think of anything to write about for this column.

     Then the bug struck again, as I knew it would eventually.  My mindç
exploded with ideas, and, as in the past, I again have far more things toç
talk about than I will have the energy or time to get down on paper beforeç
this article has to be sent in.


                               Echelon and I
                               -------------

     I practically fainted when I saw the byline on my last column, and Iç
wonder if both Echelon and my real employer did too!  The byline read:ç
"Jay Sage, Echelon, Inc."  I guess Art Carlson misinterpreted my statementç
that I had joined the Echelon team.  In no way am I an employee orç
official representative of Echelon.  In real life I am still a physicistç
at MIT doing research on special analog(!!) devices and circuits for imageç
processing and neural-like computing.  Digital computing is stillç
essentially a hobby.

     The members of 'The Echelon Team' are independent programmers whoç
cooperate with Echelon and each other to advance 8-bit, CP/M-compatibleç
computing.  Other members of that team, to mention only a few, are Bridgerç
Mitchell, author of DateStamper, BackGrounder, and JetFind; Joe Wright,ç
author of the auto-install Z-System and the BIOSs of most of the recentç
popular 8-bit computers (Ampro, SB-180, On!); and Al Hawley, sysop of Z-Node #2 (the only one to sign up for a node before I did) and author ofç
the REVAS disassembler and the new ZAS.


                   Supporting 8-Bit Software Developers
                   ------------------------------------

     Though team members have no personal stake in Echelon as employees orç
owners, they do benefit to some extent from royalty payments for theirç
software that is sold.  Nevertheless, before turning to the technicalç
material for this issue, I would like to make an unabashed plea to all ofç
you to support Echelon and the small number of other companies stillç
developing 8-bit software by purchasing their products.  They are the onlyç
hope for the sustained vitality of our 8-bit world.  If we don't buy theç
products they offer, the creative programmers who have not already done soç
will have no choice but to abandon Z80 programming in favor of the moreç
lucrative IBM-compatible market.  Check the ads in The Computer Journal,ç
and support the companies that advertise there.  Do not make regular useç
of illegitimate copies of their software; buy your own.

     Unfortunately, no one is getting rich on 8-bit software.  I did notç
keep a record of the time I spent on ZCPR33, so I cannot calculateç
accurately the effective hourly rate, but a rough estimate indicates thatç
babysitting would probably have been a better way to make money.  In fact,ç
my greatest financial reward probably came from the money not spent onç
babysitters as a result of staying home programming instead of going out!

     While reflecting on these issues, I thought I had a brilliant idea --ç
put together a transportable computer and actually hire myself out as aç
babysitter.  That way I could get paid not only for the commercialç
products like ZCPR33 but for all the public-domain programs as well. ç
Unfortunately, on more careful consideration, I noted some serious defectsç
in this scheme.  First of all, how many people would hire me to sit nightç
after night until 2 or 4 in the morning?  And who would want a babysitterç
who wouldn't notice the house burning down until the power went out on hisç
computer screen?

     Basically, I think it is fair to say that all of us (even those, likeç
Joe Wright, who depend on it for their livelihood) are in the 8-bitç
programming business because we love it.  Even for the nonprofessionals,ç
like me, there are reasons why some financial compensation is important. ç
While we may derive enormous enjoyment and excitement from programming,ç
our families do not, but if it brings in a little extra spending moneyç
that the entire family can share, they are much more tolerant of the longç
hours spent in front of the CRT or on the telephone helping users withç
problems.


                     New Commercial Z-System Software
                     --------------------------------

     As a transition from my 'soap box' remarks above, I would like toç
begin the technical discussion with a review of some exciting developmentsç
in commercial Z-System software.


                            WordStar Release 4

     The most exciting development in a long time is the appearance fromç
MicroPro of WordStar Release 4, CP/M Edition.  As far as I can remember,ç
this is the first new CP/M product from a major software house since Turboç
Pascal version 3 came out several years ago, and it is the only productç
ever from a major vendor that supports Z-System.  I am thrilled at theç
official recognition this bestows on Z-System.

     For the season's kickoff meeting of the Boston Computer Society'sç
CP/M Computers Group, we had representatives from MicroPro to introduceç
the new product.  As excited as I was about Release 4, I was sure thatç
this would be the end of the line, so I was quite surprised when theç
representatives talked about a release 5 for CP/M as well as for MS-DOS.

     MicroPro speaks of itself now as the 'New' MicroPro, and, indeed,ç
they sounded like a new MicroPro.  They are extremely solicitous of userç
suggestions.  Their upgrade policy is very generous (they'll happilyç
accept the serial number from any older WordStar or NewWord), and theç
upgrade price of $89 for individuals and $79 for clubs is very attractive. ç
Echelon's special offer at $195 for those who did not own WordStar orç
NewWord before is also quite reasonable for such a high quality product. ç
I personally have not made much use of WordStar in the past, preferring myç
roll-my-own, do-it-my-way PMATE text editor, but I have already placed myç
order for WS4, if for no other reason than to show my support to MicroProç
and to encourage them to stick with us 8-bitters.

     Frankly, I am also quite eager to explore WS4's new Z features. ç
Since my copy has not arrived yet, I cannot give you a first-hand report,ç
but what I have been hearing from others is extremely positive.  Itç
apparently knows about the command search path and named directories ofç
ZCPR3 and can run as a true shell.  The documentation included withç
WordStar 4 is extraordinary, the equivalent at least of the customizationç
package that the 'old' MicroPro used to charge an extra $500 for!  Noç
longer will the hobbyists have to ferret out all the patch points for theç
program (though I am sure there will be plenty of areas, nevertheless, toç
keep us entertained).


                                ZAS/ZLINK

     Another exciting development is release 3 of ZAS/ZLINK, Echelon'sç
assembler/linker (and librarian) package.  As many of you may know, mostç
serious programmers -- Echelon team members included -- have had littleç
but scorn for ZAS in the past.  It was a strange and unreliable assembler.

     But Echelon has now really made good on ZAS.  They did it right thisç
time.  They did not go back to the original author and try once again toç
get him to fix it; instead they brought in the highly competent Al Hawley. ç
Though I am sure it is still not perfect (what program is), it hasç
correctly assembled all correct code that I have fed to it.  And gone areç
its former irritating and unique idiosyncrasies, like square bracketsç
instead of parentheses in arithmetic expressions.  ZAS will now handleç
just about any code written in some semblance of standard assemblyç
language.  It supports a rich set of pseudo-ops, making it tolerant ofç
common variants.

     ZAS and ZLINK are also at long last honest Z-System tools, as befitsç
an Echelon product.  They recognize named-directory references for allç
files, and they communicate with the Z3 environment and message buffers. ç
With an appropriate editor it is possible to build a code developmentç
system like that in Turbo Pascal.  When ZAS encounters errors in assembly,ç
it stores enough information about the first error in the environment thatç
an editor can automatically locate the line with the error.  Thus one canç
make an alias that bounces between the assembler and the editor in veryç
convenient fashion.  As an added bonus, the Echelon version of ZASç
includes, as the one from Mitek always did, the option to generate in-lineç
assembly code for Turbo Pascal.

     If you have an older version of ZAS/ZLINK, you should definitelyç
order the upgrade, priced at just $20 for the software alone or $30 withç
an updated manual.  If for some reason you do not want to do that, youç
should at least destroy any copies of the older versions that you haveç
lying around.

                                 New ZCOM

     Now I would like to move forward in time and talk about a productç
that is in the works (though with the delay between when I write theseç
columns and when they reach readers, it may be on sale by the time youç
read this).  This product is New ZCOM, or NZCOM, Joe Wright's utterlyç
spectacular follow-on to ZCOM.  This product will make manually installedç
Z-Systems obsolete, because manually installed systems will now offer lessç
performance than NZCOM systems.

     First some history.  In the summer of 1984 Joe Wright was reflectingç
on the difficulty of converting stock CP/M2.2 systems to ZCPR3 andç
wondering if an automatic method could not be developed.  Rick Connç
apparently opined that such a thing would not be possible.  Joe did notç
ask me (we did not know each other at the time), but if he had, I wouldç
have told him the same thing -- impossible!  You know the old marines'ç
saying: the difficult we do immediately; the impossible takes a littleç
longer.  Well, Joe didn't even take very long to do the impossible.  In aç
matter of weeks he had a fully working version.

     ZCOM had two drawbacks compared to a manually installed Z-System. ç
First, it required an extra 0.5K of overhead.  Secondly, and ultimatelyç
more seriously, it was not flexible.  One had to accept a standardç
configuration.  There was no choice of command processor options, numberç
of named directories, size of RCP, and so on.  Thus, ZCOM was the Z-Systemç
of choice only when a manual system could not be made, either for lack ofç
skill or lack of BIOS source code.

     Since the new computer I bought at work in 1984, a WaveMate Bullet,ç
to my chagrin did not come with source for the BIOS, I tried briefly toç
figure out how to get ZCPR3 installed without BIOS modifications.  I cameç
up with an approach that might have worked, but before I got very far withç
its development, Echelon announced Z3-DOT-COM and, shortly thereafter,ç
ZCOM.  I bought them right away.  After a short time, I figured out howç
they worked (and was amazed at Joe's cleverness).  Then I began toç
implement the modifications I described in my last two columns, includingç
ways to switch between different auto-install systems from within aliasç
scripts and while inside shells.

     Later, after I became acquainted with Joe, I told him about my ideasç
for an enhanced ZCOM.  It seemed, however, that he was much too busy atç
the time with other products to give any attention to ZCOM, so I decidedç
that my next project after ZCPR33 would be a program that I tentativelyç
called Dyna-Z.  This would be a dynamic Z-System, an operating systemç
whose configuration could be changed on the fly.

     Dyna-Z would be useful in several ways.  One could normally run aç
system with all the standard ZCPR3 modules except an IOP (input/outputç
package), giving one a good set of ZCPR3 features for normal operations. ç
When one wanted to make use of an IOP, like Joe Wright's superb NuKeyç
keyboard redefiner program, a load alias would first check to see if anç
IOP space was available in the system.  If so, NuKey would be loaded.  Ifç
not, the alias would switch the operating system to one that did includeç
an IOP and then load NuKey.  One would sacrifice the 1.5K of TPAç
(transient program area -- the memory available for a program to work in)ç
only while one needed the benefits of NuKey.

     On the other hand, when one invoked a command such as WordStar 4 or aç
spreadsheet that required a large TPA, an alias for that command wouldç
first switch to a Z-System with no IOP or RCP, increasing the TPA by 3.5Kç
compared to the full Z-System.  One could even drop the FCP (0.5K) and/orç
the NDR (0.5K typically).  When the memory-hungry program was finishedç
running, the remainder of the alias script would reload the standardç
version of Z-System.  One would hardly know that the operating system hadç
been different while WordStar or the spreadsheet was running.

     Thus Dyna-Z would not only overcome the major disadvantage of ZCOMç
but would also overcome the only intrinsic disadvantage of ZCPR3 -- theç
loss of TPA space.  A minimum Z-System would use only 0.75K plus theç
autoinstall overhead (reduced to a mere 0.25K), a very small sacrifice forç
all the benefits that Z-System offered.  And in a real pinch for TPA, oneç
could even drop out of Z-System temporarily and run standard CP/M with itsç
maximum possible TPA.  Using SUBMIT, even this could be done with aç
script!

     I was delighted this summer when Joe Wright called on the phone toç
discuss his plans for New ZCOM.  It was the first I knew that he had takenç
up the project, and I found that he had already made great progress.  Manyç
of the features I had planned for Dyna-Z were already implemented, and Joeç
was eager to incorporate the rest.  Our partnership was born!  And it is aç
perfect partnership for me -- Joe is doing all the work.

     I would have been excited enough just to see the Dyna-Z features inç
NZCOM, but Joe has done much more than that.  He has made the process ofç
building a system of your choice about as easy as it could possibly be. ç
You simply edit NZBAS.LIB, a text file describing the system configurationç
you want, and assemble all the individual components (CCP, DOS, RCP, FCP,ç
etc.) to Microsoft-format REL files.  NZCOM.COM then generates a systemç
auto-loader program for you automatically.  It will even allow you toç
clone an existing system, accomplishing automatically all the complexç
processes I described in my last two columns.


                                 JetFind

     Now I would like to switch back in time and describe a program thatç
has been around for a while already but has not had the publicity I thinkç
it deserves.  It suddenly struck me the other day just how often and inç
how many ways I use JetFind yet how few people probably are aware of itsç
existence.

     JetFind, by Bridger Mitchell, is basically a text finding program. ç
It is something like Irv Hoff's publicly released FIND.COM, which canç
search through a file for a specified text pattern.  But it goes orders ofç
magnitude beyond that.

     To begin with, I should explain that JetFind operates in either ofç
two modes: interactive or command mode.  In interactive mode, the programç
is invoked alone, with no command tail.  It will then prompt the userç
sequentially for each piece of information it needs.  The user can thenç
live inside JetFind, performing one search after another until he issuesç
an exit command.  Alternatively, a single search operation can be carriedç
out by including all the necessary information on the command line.

     Now for the capabilities of JetFind.  First of all, JetFind is notç
limited to searching the text for only a single pattern at a time.  It canç
search for multiple patterns, and each one can be either a simple textç
string or a regular expression (a UNIX concept).  Let's take a simple caseç
first.  Suppose you want to find all lines that contain either "Smith" orç
"Jones".  In interactive mode you would enter the patterns one at a timeç
in response to the prompt.  Just hitting carriage return would end patternç
input.  In command mode, you would enter for the search pattern theç
following expression:

                SMITH|JONES

The special character '|' represents 'or'.  From command mode, of course,ç
one cannot distinguish upper and lower case.  To do that you must useç
interactive mode.

     Now let's consider a more complex search that would make use of aç
regular expression.  Suppose we want to find all labels in an assemblyç
language program.  We could use the following regular expression:

                [A-Z][A-Z0-9]*:

The first term in brackets means a character from the set of lettersç
ranging from 'A' to 'Z'.  The second term in brackets is the set includingç
the digits from '0' to '9' also, i.e., an alphanumeric character.  Theç
asterisk means that the previous character specification may occur anyç
number of times, including zero times (a '+' would require at least oneç
occurrence).  Finally the colon on the end represents the ':' character

     If labels have to be at the left margin, we could use the regularç
expression

                ^[A-Z][A-Z0-9]*:

A caret at the beginning of an expression indicates the beginning of aç
line.  A mode control specification (explained later) can tell JetFindç
whether or not to ignore case.  If other characters are allowed in labels,ç
they could be listed inside the brackets as well.

     There is not enough space here to give a complete description ofç
JetFind's regular expression syntax.  Suffice it to say that it canç
perform just about any search you would ever want to do.

     A second major feature of JetFind is that it is not limited toç
searching single files; you can specify whole collections of files toç
search.  You can give a list of ambiguous file specifications both forç
files to include in the search and files to exclude from the search. ç
These files can all come from a single directory, or files from manyç
directories can be included.  For example, the file list

                TEXT:*.D?C ~TEXT:A*.*

indicates all files in the named directory TEXT (yes, JetFind is fullyç
ZCPR3-compatible) with a file type of D?C but not (that is the meaning ofç
the '~' prefix) files whose name begins with 'A'.  Note the '?' in theç
file type.  The intention here is to search all DOC files.  By includingç
the '?' for the middle letter, files of type DQC (squeezed DOC files) andç
DZC (crunched DOC files) will be included as well.  JetFind automaticallyç
uncompresses both squeezed and crunched files as it searches.

     Moreover, JetFind is not limited to searching individual files.  Itç
can even search through members of libraries.  If the first file name inç
the list of files is an LBR file, then the rest of the list is taken as aç
specification of the members of that library to be included in or excludedç
from the search.  As with individual files, these files can be unsqueezedç
or uncrunched on the fly.

     As if this were not enough, JetFind has about a dozen mode controlç
options that define how it performs the search and what it does with theç
text identified by the search.  Here are descriptions of just a few.

C     This option just counts and displays the number of matches without
      showing the matching lines of text.

N     The lines containing matching text will be numbered in the listing
      to make it easy to find them with an editor.

Rmn   This specifies a display region ('m' and 'n' are each digits from 0
      to 9).  For each line containing a match to one of the patterns, the
      previous 'm' lines and following 'n' lines will also be included in
      the display to provide context.

I     Case will be ignored so that 'a' and 'A' will be considered to
      match.

B     Begin displaying the text as soon as the first match has been found.

V     Reverse the test and display only lines that do not match any of the
      specified patterns.

T     Type the file, extracting it from a library and/or uncompressing it
      as required.

With these and other options not listed above, JetFind can be made toç
perform many tasks besides searching, such as typing files, extractingç
files from libraries, splitting off parts of files, and displaying filesç
in a directory or library.

     We're not finished yet!  JetFind also supports full input/outputç
redirection.  The output text that is shown on the screen can additionallyç
be saved to a file, either in a new file or appended to an existing file. ç
The set of patterns to search for can also come from a file.  Thus weç
could have the command

        JETFIND -WN <ASM:LABEL.EXP ZF*.Z80 >LABELS.LST

This would search through all the ZFILER source code (ZF*.Z80) for theç
regular expressions contained in the file LABEL.EXP in directory ASM.  Theç
search would require whole-word matches ('W') and include line numbersç
with the matching lines ('N').  The output would be displayed on theç
screen and written to a new file called LABELS.LST in the currentç
directory.

     One final comment.  JetFind does its work at incredible speed. ç
Bridger Mitchell is an absolute master at wringing performance out of theç
operating system, using all kinds of tricks to speed up file operations. ç
Hence the 'Jet' in the name.  JetFind is available from Echelon or Echelonç
dealers for just $49.



                            New ZSIG Programs
                            -----------------

     Now I would like to turn to some exciting new ZSIG programs that haveç
been released or are under development at this time.


                          LLDR -- Library Loader

     Paul Pomerleau -- already well known to the community as the authorç
of such widely used programs as VERROR (visual error handler), BALIAS (anç
alias editor), AFIND (alias finder), and the commercial LZED (little Zç
editor) -- has released LLDR, a version of LDR with library support.

     This program completely replaces LDR, the standard module loaderç
program used to load new ENV, Z3T, RCP, FCP, NDR, and IOP operating systemç
code segments.  It does everything LDR did but adds one new, veryç
important feature.  It can load the modules from a library.

     ENV and Z3T modules in particular are very short (one or twoç
records), and it was very inefficient use of disk and directory space toç
have them sitting around as individual files.  Now all the system filesç
can be collected together in a single LBR file (or several, if youç
prefer).  LLDR's syntax can be expressed in general form as follows:

        LLDR [library[.LBR],]<list of modules to load>

If the optional library specification is omitted, then it performs justç
like LDR.  If all the system modules are placed in a file called, forç
example, SYS.LBR, then one might invoke LLDR (renamed to LDR) as follows:

        LDR SYS,SYS.ENV,DIMVIDEO.Z3T,DEBUG.RCP,SYS.FCP,NUKEY.IOP

Besides the saving in file space and directory entries, there is anotherç
nice side benefit of using LLDR in this way -- it is much faster.  Sinceç
only one file (SYS.LBR) has to be opened by the operating system, there isç
only one directory search, and loading the entire collection of modulesç
takes little more time than loading a single one did with the old LDRç
program.  Thanks, Paul, for another nice program.


                       SALIAS -- Screen Alias Editor

     When I released VALIAS (visual alias editor) a couple of years ago, Iç
wrote in the documentation that someone should please extend it to full-screen operation (it only supported insertion and deletion of completeç
lines).  Paul Pomerleau's BALIAS allowed full WordStar-like editing ofç
alias scripts, but it treated the entire multiple-command script as aç
single line.  I much preferred the structured presentation of VALIAS, withç
each command on its own line.  I suggested that VALIAS should be extendedç
to automatically indent the lines to show the nesting of flow-controlç
commands.

     It has been a long wait, but finally the wait is over.  Rob Friefeld,ç
from the Los Angeles area (contact him on Al Hawley's Z-Node #2), hasç
released SALIAS (screen alias editor), and what a beauty it is.  You willç
no longer find VALIAS on any of my disks!

     With SALIAS, alias scripts are displayed and edited rather as if theyç
were WordStar text files.  Each individual command is displayed on its ownç
line, except that long lines can be continued on the next line by enteringç
a line-continuation character (control-p followed by '+') at the beginningç
of the continuation line.

     SALIAS works in two basic modes.  One is the command mode, like thatç
in VALIAS.  In command mode, the status line at the bottom of the screenç
displays the following prompt:

        CMD (Clear Edit Format Indent Load Mode Print Rename Save
                Undo eXit)

Entering 'C' will clear the script editing area.  'E' will enter full-screen editing mode.  'F' will reformat the script, converting it to upperç
case and placing each command on its own line, even if the user enteredç
lines containing multiple commands separated by semicolons.  The 'I'ç
command is similar except that it indents the lines by three extra spacesç
for each level of IF nesting.  Thus a script might appear as follows:

        IF EQ $1 //
           OR NU $1
           ECHO SYNTAX IS ...
           ELSE
           IF NU $2
              COMMAND FOR ONE FILE SPEC
              ELSE
              COMMAND FOR TWO FILE SPECS
           FI
        FI

This format makes it very easy to see the relationship between the flowç
tests and to detect missing FIs.

     Entry of complex conditional aliases is greatly facilitated by theç
use of the tab key to indent the script as it is entered.  The 'I' commandç
will reindent the display according to the actual flow levels, even if theç
user made a mistake.  The spaces (tabs) used to format the display are notç
part of the actual alias script.  However, leading spaces entered by theç
user (to invoke extended command processor operation, for example) will beç
included in the script and are displayed in addition to those added by theç
indenter.  The 'F' command will show the real contents of the script,ç
automatically deleting the indentation tabs.

     The 'L'oad command tells SALIAS to clear any existing script and toç
load an alias file for editing.  If such an alias already exists, it willç
be read in.  Otherwise it will be created.  'M' allows one to specifyç
either a normal alias or a VALIAS-style recursive alias, one that clearsç
the entire multiple command line buffer before it is run.  In an earlierç
TCJ column I described how one would use this kind of alias for certainç
kinds of recursion.

     The 'P'rint command will send the screen display of the alias scriptç
to the printer.  'R' will let one change the name assigned to the scriptç
being edited so that a script can be read in from one alias and writtenç
out to a new alias.  'S' saves the current script in a file with theç
current name.  Undo will ignore any editing that has been performed on theç
alias and let the user start over with a fresh copy of what was read inç
from the file originally.  'X' will terminate operation of SALIAS (withoutç
any prompting).

     SALIAS has an alternative mode of operation entirely from within theç
interactive edit mode.  All of the functions that can be performed byç
commands in command mode, and some others as well, can be performed usingç
control-character sequences directly from edit mode.  These commands areç
as follows.  In all cases, the first character (for example, ^K) is aç
control character.  The second character can be a control character or aç
regular character in either upper or lower case.

^KS   Save the alias under the current file name.

^KD   Done editing -- save the file and then clear the edit buffer.

^KX   Exit from SALIAS after saving the file.

^KN   Assign a new name to the script.

^KQ   Quit without saving the script.

^KR   Read in another alias script and append it to the commands
      currently in the edit buffer.  This is very convenient for combining
      scripts from multiple aliases.

^KF   Reformat the alias, listing each command on its own line, removing
      any flow-control indentation, and converting to upper case.

^KI   Indent the alias display to show flow control nesting.

^KU   Undo changes that have been made to the script.

^KP   Print the script.

^KM   Toggle the mode of the alias between normal and recursive.

     The editing commands follow the familiar WordStar pattern.  Even ^QSç
(move to beginning of line), ^QD (move to end of line), and ^QY (delete toç
end of line) are recognized.  The special form ^QZ will zap (clear) theç
entire script so you can start over.  ^R and ^C move to the first and lastç
lines of the script, respectively.  ^QF allows searching for strings, andç
^QA allows search-and-replace.  ^L will repeat the last search or search-and-replace.  ^V toggles between insert and overtype modes.

     SALIAS is available in two versions.  The longer version has imbeddedç
help information that can be called up using ^J.  In the shorter version,ç
the help information has been omitted, and ^J instead is used to toggleç
the cursor between the beginning and the end of the current line.

     I should mention a few other features of SALIAS.  There is anç
additional status line at the top of the screen.  It shows the name andç
version number of the program, the type of alias (normal or recursive),ç
the number of characters free, and the current name for the alias.

     The free-character value is calculated by subtracting the number ofç
characters presently in the script from the number of characters allowedç
in the multiple command line buffer.  This computation is not infallible. ç
There are some parameter expressions, such as $D, that take up less roomç
when expanded, so it is possible that SALIAS will refuse to let you saveç
an alias that it thinks it is too long when in fact it is not.  Moreç
likely, however, is that you will save an alias that has few enoughç
characters for SALIAS to accept it but will become too long when theç
parameters are expanded.  And even if this does not happen, you can runç
into trouble when the alias itself appears in a multiple command lineç
expression, and not-yet-executed commands have to be appended to the aliasç
script.  These subtleties aside, having the display of free characters isç
helpful.

     To summarize, in my opinion SALIAS makes all previous alias editorsç
obsolete.  You should be sure to pick it up from your local neighborhoodç
Z-Node.  If you do not have one, then join NAOG/ZSIG and order a disk fromç
them.


                       VLU -- Visual Library Utility

     VLU is a utility we have all been wishing for -- a screen-orientedç
library management utility.  Its author is Michal Carson of Oklahoma City,ç
OK.  I originally suggested a library shell, like ZFILER but working onç
the contents of a library, but Michal pointed out that there is really noç
need for the visual library utility to be a shell, since shell functionsç
like macros performed on pointed-to files will generally not be applicableç
to library members.  So he built VLU as a non-shell utility thatç
interfaces closely with ZFILER.

     VLU can be invoked in two ways.  Without any file name specified onç
the command line, it tries to open a library whose name is the same as theç
file name stored in the Z3ENV system file 2.  This system file is whereç
ZFILER keeps the name of the file it is currently pointing to.  If one hasç
a ZFILER macro called, for example, 'V' with the simple script 'VLU',ç
invoking this macro while pointing to a library (or to another file withç
the same name as an LBR file in that directory), the library will beç
opened for work by VLU.  Alternatively, one can specify the name of theç
file on the command line, in which case this name takes precedence overç
any name in system file 2.

     Once VLU is running, the display contains two fields.  The upperç
field is like that in ZFILER.  It displays the names of the files in theç
currently logged directory.  The lower field is similar in appearance butç
shows the names of the member files in an open library file.  If noç
library file is currently open, this field is blank.

     As in ZFILER, there is a file pointer that can be moved around usingç
standard control characters or, if defined, cursor keys.  In VLU, theç
escape character toggles the cursor between the upper (file) and lowerç
(LBR member) fields of file names.

     Many operations can be performed on either set of files.  Files canç
be tagged and untagged, and two wildcard tagging functions are provided. ç
'GT' group tags all files, while 'W' allows a wildcard file specificationç
to determine which files get tagged.  Individual files or groups of taggedç
files can be viewed, crunched (but not squeezed), or uncompressed (eitherç
uncrunched or unsqueezed, as appropriate).  The 'F' command will show theç
size of an individual file or library member at the cursor.  For libraryç
members, the size is shown in records as well as kilobytes.  Additionally,ç
tagged individual files can be deleted or renamed, and tagged libraryç
members can be extracted, with or without decompression.

     The special 'GB' or Group-Build function of VLU allows taggedç
individual files to be built into a new library.  As I write this article,ç
the details of this feature have not been fully worked out, but it will beç
possible for the user to indicate which of the tagged files should beç
crunched according to an automatic algorithm (which will crunch them onlyç
if that results in a smaller file) and which should be put into theç
library in their existing form.

     Single individual files will accept the command 'O' to open a libraryç
with that name if it exists and the command 'C' to close the currentlyç
open library.  They can also be renamed using the 'R' command.

     There are several miscellaneous commands.  '/' will toggle between aç
built-in help display and the file name display.  'X' is used to exit fromç
VLU; 'J' is used to jump to a file; '*' is used to retag files that wereç
tagged before some group operation was performed; and 'Q' refreshes theç
screen display.

     Future versions of VLU will include some features not yet in theç
present one.  A printing capability will be added to complement the 'view'ç
functions.  Presently, VLU cannot add files to an already existingç
library, though it allows the user to specify the number of elements toç
accommodate in the library directory so that another tool such as LPUT canç
be used to add more files later.  VLU has an 'L' command to log into a newç
directory.  By opening a library in one directory and then changing toç
another, one can extract files to a directory other than the oneç
containing the library.  At present, however, the 'L' command does notç
recognize a file mask as ZFILER does to restrict the files included in theç
display.  Even in its initial release form VLU is a very welcome additionç
to the toolbox of Z utilities, and I extend thanks from all of us toç
Michal Carson.


                           Subject for Next Time
                           ---------------------


     As I promised last time, this column has taken a less technical tack,ç
though I feel that it has covered important and valuable material.  Forç
next time, however, I expect to return to a more detailed technicalç
discussion.  In the past few weeks, I took up the task of rewriting andç
expanding ZEX, the ZCPR3 in-memory batch execution utility.  This has beenç
my first detailed look at a program of this type -- a resident systemç
extension (RSX), a program that takes over and replaces functions of theç
operating system, in this case the BIOS.  I have learned a great deal andç
have made what I think are some spectacular improvements to the way ZEXç
works and additions to what it can do.  Next time I will share with youç
what I have been doing and what I have learned.

                                        