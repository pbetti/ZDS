
2  INTEGER SECT,ADDR,POSIT(20),ERASE(10)
3  INTEGER LEADIN,CLOCK,ROWPOS,COLPOS
4  INTEGER J,ANSI,A,I,OFFSET,DELAY
5  INTEGER T(520)
50  FOR I=1 TO 30: PRINT : NEXT I
100  PRINT "MTBASIC Terminal Installation Program Version 1.1"
101  PRINT 
102  PRINT "You will be asked to enter your terminal's operating parameters."
103  PRINT "The default answers are characteristics of the ADM-3A. You may"
104  PRINT "enter numbers in decimal, or in hex by prefixing the number with"
105  PRINT "a '$'."
110  PRINT 
130  PRINT "Enter your computer's clock frequency in Mhz"
140  PRINT " (e.g., 2) ";
150  INPUT CLOCK
160   IF  CLOCK < 1  OR  CLOCK > 10 THEN  GOTO 130
165  PRINT 
170  PRINT "Enter Ascii value for your terminal's lead-in character"
180  PRINT "The lead in is almost always 27 decimal. ";
190  INPUT LEADIN
200   IF  LEADIN < 0  OR  LEADIN > 127 THEN  GOTO 170
255  PRINT 
260  PRINT "Enter the string to send to your terminal to erase the CRT."
270  PRINT "This string must be entered as a sequence of integers separated"
280  PRINT "by carriage returns. The last number must be a -1. For an"
290  PRINT "ADM-3A, enter": PRINT 26:  PRINT  - 1
295  PRINT : PRINT "Enter string:"
300  FOR I=1 TO 6
310  INPUT ERASE(I)
320   IF  ERASE(I) = -1 THEN  GOTO 331
330  NEXT I
331 PRINT: PRINT "  If your terminal uses an Ascii cursor positioning sequence"
332 PRINT "(i.e., it needs two numeric Ascii characters for both the row"
333 PRINT "and column positions), then enter a 1. Otherwise, as in the case"
334 PRINT "of the ADM-3A, enter a 0."
335 PRINT "Enter a 0 or 1: ";
336 INPUT ANSI
337 IF ANSI>1 OR ANSI <0 THEN 331
338 PRINT
340  PRINT "Enter the string to send to your terminal to position the"
350  PRINT "cursor. This string, as before, must be entered as a sequence"
360  PRINT "of integers separated by carriage returns, the last entry being a -1."
370  PRINT "Typically, several characters are sent followed by the row and"
380  PRINT "column address. For example, the ADM-3A requires 27,61,row,column."
390  PRINT "Enter a zero where the row and where the column would go. In this"
400  PRINT "example, enter": PRINT 27: PRINT 61: PRINT 0: PRINT 0: PRINT  - 1
402 PRINT "If your terminal needs Ascii Cursor position commands, be sure"
403 PRINT "to leave two zeroes for both the row and column."
405  PRINT : PRINT "Enter string:"
410  FOR I=1 TO 10
420  INPUT POSIT(I)
430   IF  POSIT(I) = -1 THEN  GOTO 450
440  NEXT I
450  PRINT 
460  PRINT "Enter the position of the row address in the cursor positioning"
470  PRINT "string you just entered. The row position is where in the string"
480 PRINT "MTBASIC should stick row characters. If your terminal uses an Ascii"
481 PRINT "cursor position sequence, you left two zeroes in the cursor string"
482 PRINT "(above), so enter the position of the first of the two zeroes."
485 PRINT "In the example from above, the"
490  PRINT "row address was the third character (27,61,row,column), so a 3"
500  PRINT "would be entered. ";
510  INPUT ROWPOS
512   IF  ROWPOS < 0  OR  ROWPOS > 10 THEN  GOTO 450
514   ROWPOS=ROWPOS - 1
520  PRINT 
530  PRINT "Now enter the position of the column address. In the example"
540  PRINT "we've been using, that would be a 4. ";
550  INPUT COLPOS
560   IF  COLPOS < 0  OR  COLPOS > 10 THEN  GOTO 520
570   COLPOS=COLPOS - 1
575  PRINT 
580  PRINT "Enter the offset to add to the row and column"
590  PRINT "positions. In the ADM-3A, a 32 would be entered. ";
600  INPUT OFFSET
610   IF  OFFSET < 0  OR  OFFSET > 127 THEN  GOTO 575
620  PRINT 
630  PRINT "Finally, enter the delay in milliseconds required after positioning"
640  PRINT "the cursor (0 to 255). ";
650  INPUT DELAY
660   IF  DELAY < 0  OR  DELAY > 255 THEN  GOTO 620
670   DELAY=DELAY * 1.2 * 2 / CLOCK
900  GOSUB 2000: ! READ INPUT FILE
1000  GOSUB 3000: ! WRITE OUTPUT FILE
1010  PRINT : PRINT : PRINT 
1020  PRINT "MTBASIC installation is now complete."
1030  STOP 
2000  !
2010  ! Find which sector contains the terminal configuration info
2020  ! by reading RRMAX and computing a sector address. Then, read the
2030  ! sectors (get two to be sure) and return.
2040  !
2050  OPEN 0,1,"MTBASIC.COM"
2060   IF  ERR = 0 THEN  GOTO 2100
2070  PRINT "MTBASIC.COM is not on this disk."
2080  STOP 
2100  FILE 1
2220  FOR I=0 TO 256
2230   T(I)=GET
2240  NEXT I
2241  RETURN 
2245  FILE 0
2250  ! FIND POSITION WITHIN BUFFER WHERE GOODIES START
2260   ADDR=$6B
2270  FOR A=ADDR TO 255
2280  FPRINT "H2,X1,Z",T(A)
2290   IF  (A / 16) * 16 = A THEN  PRINT 
2300  NEXT A
2310  RETURN 
3000  !
3010  ! write out sectors
3020  !
3030   T($6B)=LEADIN
3035 T($7E)=ANSI
3040   T($7F)=ROWPOS
3050   T($80)=COLPOS
3060   T($81)=OFFSET
3070   T($82)=DELAY
3080  FOR I=1 TO 6
3090   T($6B + I)=ERASE(I)
3100  NEXT I
3110  FOR I=1 TO 9
3120   T($71 + I)=POSIT(I)
3130  NEXT I
3250  CLOSE 1
3251  FILE 0
3260  OPEN 1,1,"MTBASIC.COM"
3263  FILE 1
3265  SEEK 0
3270  FOR I=0 TO 255
3280  PRINT CHR$(T(I));
3290  NEXT I
3292  SEEK 255: CLOSE 1
3295  FILE 0
3300  RETURN 
END
 Basic program from your machine
language routine, do it thru an intermediate variable, as follows