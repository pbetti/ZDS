Msg #8381 posted 12/19/87 at 10:46 am by Jim Thale
To: Rich Jacobson     About: stuff & msg (10 lines)
 
Hi there! Politics is heating up and so was my system 'til the Hard
disk crashed.  Belated thanks for the lecture on the value of Backing-
up early-and-often.  The folks at CompuPro were incredibly helpful with
help requests from a 'lowly CP/M user'. Reformatting and new Z-system
& BYE510 are all in the works now that I can start from scratch....
 
Is NZCOM a salable product yet? Might be worthwhile, so many things don't
work with BG and datestamper installed. Trading off RCP for BG sounds good.
Kevin Parker promises a Z280 S-100 CPU with half-to-two Meg. in the first
quarter of '88, gotta work on the Z80DOS/ZRDOS crowd for multitasking
support, thanks     bye        j.
 
Msg #8395 posted 12/21/87 at  6:45 am by Richard Jacobson
To: ALL USERS     About: NZCOM (14 lines)
 
Have had a number of inquiries about NZCOM, the upcoming replacement
for auto-install ZCPR3/3.  It should be out in first quarter of '88.
I have used it in beta form and it is superb.  Superb is too mundane
a word.  It makes obsolete all manual installs and will  be the
Z-System of choice for all users.  Why?  Taking almost no more space
than an optimized manual install, it will permit you to resize your
system on the fly, from the command line, through an alias.  No more
lock-in as far as TPA goes.  If you need more room for a particular
application, just access it via an alias that removes some of the
system segments and associated buffers, increasing TPA.  The alias
can have an exit command that puts all the segments and buffers back.
In short, maximum control of the operating system will be yours.
Once again, nothing beats working in a mature operating system
environment.
 
Msg #8398 posted 12/21/87 at  5:13 pm by Steve Cohen
To: Richard Jacobson     About: NZCOM (2 lines)
 
ALL users?  Even us XBIOS users?  PULLEEZE don't tell me I need to switch
again?
 
Msg #8427 posted 12/25/87 at  6:49 pm by Steve Cohen
To: Richard Jacobson     About: NZCOM (7 lines)
 
Malcom said that XBIOS lacks one important feature of NZCOM
which he plans to add in the next version.  Actually, it owuld
be nice if the two could be kept as compatible as possible.
NZCOM sounds so nice it will probably sweep the vanilla Z-world
and it would be a drag if things started diverging at this point.
NZCOM might even tempt me to put it on my Kaypro, which in terms
of anything new, has been atrophied in time since I got the SB180.
 
Msg #8441 posted 12/27/87 at  7:10 am by Richard Jacobson
To: Steve Cohen     About: NZCOM (7 lines)
 
Yes, NZCOM allows dynamic modification of system size.  As I
understand, what Malcom plans will cover that in the next release
of XBIOS.  Compatibility is not and never has been an issue.
What you really mean to refer to is the question of whether all
the features of NZCOM will exist in XBIOS.  The answer is obviously
yes, in terms of the only feature that counts - dynamic resizing of
system.
 
Msg #8411 posted 12/23/87 at  3:53 am by Fred Haines
To: Steve Cohen     About: NZCOM and XBIOS (18 lines)
 
Why not both NZCOM and XBIOS? Now that Z system has picked up on the
CONIX idea of a dynamically readjustable system/tpa balance, the next
thing will be to look at the XBIOS idea of using banked memory for the
system. If the BIOS can reside in banked memory, why not the rest of
the system as well? With XBIOS we're already warm booting from banked
memory, and BGii keeps its command line history processor over there
until it reloads on warm boot. Why shouldn't almost all of banked
memory be used for the system? I gather that the idea of the "hyperspace"
Z system for the Deep Thought 42 does something of the kind. Whichever
way this goes, I have the feeling that what Rich calls a "mature
operating system" is going to go on maturing and that we'll be
regenerating our systems a few more times before we all switch over to
the Z280.
 
   Anybody who is particularly interested in the OS Scott Moore is
developing for Zedux can contact him on Glendale Littera RCPM/QBBS at
818/956-6164. You can also call him voice at his office, but I seem to have
misplaced the number. He posted it in a recent message on Littera
though, and you'll easily find it there.
 
Msg #8423 posted 12/25/87 at  6:33 pm by Steve Cohen
To: Fred Haines     About: NZCOM and XBIOS (6 lines)
 
EXACTLY.  When Richard said "mature operating system", plenty of
Humphs went through my head.
 
Amazing, isn't it, that in our "dead" OS, such improvements are
not only contemplated but cranked out.  Whereas Misbegotten-DOS
has 384K of addressable memory hardwired for system uses
and they complain about lack of memory.
