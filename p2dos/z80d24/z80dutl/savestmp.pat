SAVESTMP.PAT
Rick Charnes, 10/26/87, San Francisco

I've patched SAVESTMP.COM slightly to create two different versions of 
the program that display status reporting messages more reflective of my 
most frequent use of the program.  Since I use it mostly to "store" and 
then "restore" the date of my current working file, I didn't care to see 
on the screen:

        Altering creation date of [DESTINATION FILENAME] ... 

each time it ran.  This will alternately display 'DATEHOLD' and the name 
of our current working file.  I would rather see:

             Storing creation date of WORKFILE . . .

when it was doing exactly that, and then

             Restoring creation date of WORKFILE . . .

upon exit.  (1) I didn't feel the word 'altering' accurately described 
what I was doing, and (2) I wanted the message to always display the 
name of my working file, rather than 'DATEHOLD' the first time, and then 
my working file the second time through.  The unpatched SAVESTMP always 
displays the name of the destination file.  My two new versions allow it 
to display according to the above scheme.

The alias I now use with my two patched versions is:

VDE=NW=LZED $d1$u1:;if ex $1;app:svstmp-s app:datehold=$1   <<
app:r$0 $:1.$.1 $-1;app:svstmp-d $1=app:datehold;l          <<
app:r$0 $:1.$.1 $-1;fi;$d0$u0:

I use four different editors at various times, and this alias can be 
used with three of them.  (Because the Z version of WordStar 4 was coded 
as a true ZCPR3 shell it cannot be loaded from a normal alias; there 
must be a command in the alias to eliminate the shell stack first.)  I 
have renamed VDE.COM, NW.COM and LZED.COM to RVDE.COM, RNW.COM and 
RLZED.COM respectively, to indicate that these are the 'REAL vde', 'REAL 
nw', and 'REAL lzed'.  The 'r' in 'app:r$0' reflects this, as 'r$0' will 
expand to 'rvde' when 'vde' is used to execute the alias, etc.

The two versions are named SVSTMP-S and SVSTMP-D, with the 'S' and 'D' 
indicating 'source' and 'destination' respectively.  As above, SVSTMP-S 
is used when the workfile is the source (storing its date of creation) 
which is the case BEFORE the editor is actually loaded, and SVSTMP-D 
when the workfile is the destination (restoring its date of creation), 
AFTER the editor exits.  Both versions will always display in their 
status reporting the name of our workfile, whether it is the source or 
destination in the equation.

In the above alias APP: (for APPlications) is the name of my directory, 
and 'l' (at the end of the second line) is ELSE renamed.  I long ago 
renamed my FCP 'ELSE' command to L to save command line buffer space.

One very nice side effect of this alias is that VDE, my favorite editor, 
is now a pseudo-ZCPR3 program --- it accepts named directories!  This is 
done by first logging on to the DIR: specified on the command line, then 
returning to the logged directory upon exit.

The '$-1' will pull from the command line ALL commands entered after our 
first parameter.  A simple '$2' would only transfer the second 
parameter.  Though I couldn't really think of any instances where there 
could be a third or fourth parameter I felt it was good programming 
practice to allow for the possibility.  A possible second parameter 
would be with VDE:

              VDE FILENAME [W

to enter VDE's WordStar mode.
sibility.  A possible second parameter 
would be with VDE