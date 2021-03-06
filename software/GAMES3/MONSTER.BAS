10 '                ****  MONSTER COMBAT ****
20 '    Written by Lee Chapel 6/15/80  ( BYTE DEC.,1980 Pp.288-290 )
30 '    Entered, Converted to Mbasic and Enhanced By Steven C. Rich
40 '                                                 (313)358-3494
50 '
60 '    NOTE: The Graphics used are for use on a Heath H-19 terminal. I
70 '          have broken out the commands so that they can you can convert
80 '          this program for other terminals. I suggest strongly that anyone
90 '          using graphics in their programs do the same.
100 '
110 RANDOMIZE:'  REMOVE OR CHANGE IF USING MBASIC VERSION BEFORE 5.0
120 ' ********************* H-19 TERMINAL COMMANDS *************************
130 E$=CHR$(27):'                ESCAPE CHARACTER (Used for alaphics in their programs do the same.
100 '
110 RANDOMIZE:'  REMOVE OR CHANGE IF USING MBASIC VERSION BEFORE 5.0
120 ' ********************* H-19 TERMINAL COMMANDS *************************
130 E$=CHR$(27):'                ESCAPE CHARACTER (Used for alHOME
190 EP$=E$+"J":'                 ERASE TO END OF PAGE
200 'NOTE:  The H-19 uses the following scheme for direct cursor addressing:
210 '       Location= (CHR$(Line number+31));(CHR$(Column number+31))
220 ' **********************************************************************
230 PRINT CLS$;"NOTE:The instructions for this game are in MONSTER.DOC."
240 FOR I=1 TO 2000:NEXT I
250 DIM A(10,10):PRINT CLS$;:PRINT TAB(20);"MONSTER COMBAT"
260 '**************************************************************
270 ' NOTE: THE FOLLOWING DEFINE GRAPHICS CHARACTERS OF THE H-19.
280 '       CHANGE THEM FOR YOUR TERMINAL
290 ' CH$(0) & CH$(1)= Grass        CH$(2)= Tree   CH$(5)= You
300 CH$(0)="ii":CH$(1)="ii":CH$(2)="r_":CH$(5)="}|"
310 '**************************************************************
320 FOR I=1 TO 9:FOR J=1 TO 9:A(I,J)=1:IF RND(1)>.75 THEN A(I,J)=2
330 NEXT J,I
340 X=INT(RND(1)*6+2):Y=INT(RND(1)*6+2)
350 A(X,Y)=5:C=INT(RND(1)*1501+500)
360 GOSUB 1270
370 PRINT "YOUR COMBAT STRENGTH IS ";C:GOSUB 620:IF I>11 THEN 370
380 IF M=0 THEN PRINT "YOU GET THE TREASURE FREE":GOTO 860
390 IF M=100 AND N=1 THEN 1260
400 PRINT "DO YOU WANT TO (F)IGHT, (R)UN, OR (B)RIBE ? "
410 Z9$=INPUT$(1):IF Z9$<>"F"AND Z9$<>"R" AND Z9$<>"B" GOTO 410
420 IF Z9$="F" GOTO 430 ELSE IF Z9$="R" GOTO 530 ELSE IF Z9$="B" GOTO 1000 ELSE GOTO 400
430 INPUT"HOW MANY COMBAT POINTS DO YOU WISH TO USE";K
440 IF K>C THEN GOSUB 990:PRINT C;"COMBAT POINTS":GOTO 430
450 I=INT(RND(1)*1001):L=2:C=C-K:K=K-.01*Q
460 FOR H=1000 TO 0 STEP-50:IF L*M<=K AND H>=I THEN 840
470 L=L-.1:NEXT
480 PRINT "THE MONSTER KILLED YOU.";
490 PRINT "YOU LOSE EVERYTHING":PRINT "DO YOU WISH TO TRY AGAIN";
500 'If using MBASIC Version before 5.0 remove 'RANDOMIZE' in following line
510 Z$=INPUT$(1):IF Z$="Y" THEN RANDOMIZE C:C=0:Q=0:GOTO 270
520 PRINT :PRINT "SO LONG. BETTER LUCK NEXT TIME":END
530 I=INT(RND(1)*12):IF I=11 THEN 480
540 FOR H=0 TO 10:IF H*10>M AND H<=I THEN 560
550 NEXT:GOTO 1070
560 A=X:B=Y
570 X=INT(RND(1)*3-1)+A: Y=INT(RND(1)*3-1)+B
580 IF A(X,Y)>1 THEN 570
590 IF A(X,Y)=0 THEN 1320
600 A(A,B)=1:A(X,Y)=5:IF I<>12 THEN 360
610 RETURN
620 I=INT(RND(1)*18+1):M=I*10:IF I<11 THEN PRINT  "A ";
630 ON I GOTO 640,650,660,670,680,690,700,710,720,730,740,1130,1080,1300,1340,1340,1340,1340
640 PRINT "MINOTAUR";:GOTO 750
650 PRINT "CYCLOPS";:GOTO 750
660 PRINT "ZOMBIE";:GOTO 750
670 PRINT "GIANT";:GOTO 750
680 PRINT "HARPY";:GOTO 750
690 PRINT "GRIFFIN";:GOTO 750
700 PRINT "CHIMERA";:GOTO 750
710 PRINT "DRAGON";:GOTO 750
720 PRINT "WYVERN";:GOTO 750
730 PRINT "BASLISK";:GOTO 750
740 PRINT "NOTHING";:M=0
750 PRINT " IS GUARDING ";:I=INT(RND(1)*7+1)
760 ON I GOTO 770,780,790,800,810,820,830
770 PRINT "10 SILVER SPOONS":P=10:RETURN
780 PRINT "A JEWELED SWORD":P=30:RETURN
790 PRINT "A JAR OF RUBIES":P=50:RETURN
800 PRINT "A TREASURE CHEST":P=200:RETURN
810 PRINT "50 SILVER COINS":P=50:RETURN
820 PRINT "100 GOLD PIECES":P=100:RETURN
830 PRINT "A BOX OF JEWELS":P=75:RETURN
840 PRINT "YOU BEAT THE MONSTER"
850 S=S+1
860 Q=Q+P
870 IF P=30 THEN GOSUB 1170
880 IF P=200 THEN GOSUB 1200:GOSUB 1230
890 PRINT "YOU HAVE ";Q;" TREASURE POINTS"
900 X$="":A=X:B=Y:INPUT"WHAT DIRECTION (HIT 1 TO RESET DISPLAY)";X$:IF X$=""GOTO 900
910 IF X$="1" THEN PRINT CLS$;TAB(20);"MONSTER COMBAT":GOSUB 1270:GOTO 900
920 IF RIGHT$(X$,1)="W" THEN X=X-1
930 IF RIGHT$(X$,1)="E" THEN X=X+1
940 IF LEFT$(X$,1) ="N" THEN Y=Y-1
950 IF LEFT$(X$,1) ="S" THEN Y=Y+1
960 IF A(X,Y)=0 THEN 1320
970 IF A(X,Y)=2 THEN PRINT CHR$(7);"YOU RAN INTO A TREE":X=A:Y=B:GOTO 900
980 A(A,B)=1:A(X,Y)=5:GOTO 360
990 PRINT "YOU ONLY HAVE";:RETURN
1000 INPUT"HOW MUCH DO YOU WISH TO PAY";K
1010 IF K>Q THEN GOSUB 990:PRINT Q;" TREASURE POINTS":GOTO 1000
1020 I=INT(RND(1)*22):L=0:IF I=21 OR K<1 THEN 480
1030 FOR H=0 TO 20:IF K<=L*P AND I>=H THEN 1060
1040 L=L+.1:NEXT
1050 PRINT "YOUR BRIBE WAS ACCEPTED.";:Q=Q-K:GOTO 890
1060 PRINT "YOUR BRIBE WAS NOT ACCEPTED.";
1070 PRINT "YOU MUST FIGHT":GOTO 430
1080 PRINT CHR$(7);"THE GUARDIAN OF THE FOREST CAPTURED YOU, TOOK HALF YOUR"
1090 PRINT "TREASURE, AND TOOK YOU TO A NEW SPOT IN THE FOREST"
1100 Q=Q/2:A=X:B=Y:FOR I9=1 TO 4000:NEXT
1110 X=INT(RND(1)*7+2):Y=INT(RND(1)*7+2):IF A(X,Y)<>1 THEN 1110
1120 A(A,B)=1:A(X,Y)=5:GOSUB 1270:I=13:RETURN
1130 J=INT(RND(1)*20+1):C=C-J
1140 PRINT "YOU FELL INTO A PIT AND USED ";J;" COMBAT POINTS TO CLIMB OUT"
1150 IF C<0 THEN PRINT	"YOU DIED WHILE CLIMBING OUT":GOTO 490
1160 GOTO 560
1170 IF RND(1)<.5 OR C>3000 THEN RETURN
1180 PRINT "THE SWORD WAS ENCHANTED AND DOUBLES YOUR STRENGTH"
1190 C=C*2:RETURN
1200 I=INT(RND(1)*10):IF I<>7 THEN RETURN
1210 PRINT "THE CHEST WAS A TRAP. YOU WERE KILLED WHEN YOU OPENED IT."
1220 GOTO 490
1230 I=INT(RND(1)*10):IF I<>3 THEN RETURN
1240 PRINT "A MIRROR WAS IN THE CHEST.";
1250 PRINT " IT WILL KILL ANY BASILISKS YOU MEET":N=1:RETURN
1260 PRINT "YOUR MIRROR KILLED THE BASILISK":GOTO 850
1270 PRINT GY$:GOSUB 1390:PRINT HO$:FOR I=0 TO 10:PRINT TAB(15);:FOR J=0 TO 10
1280 PRINT CH$(A(J,I));
1290 NEXT J:PRINT:NEXT I:PRINT EP$;GN$:RETURN
1300 IF S<5 THEN 620
1310 PRINT "A GIANT EAGLE CARRIED YOU TO SAFETY"
1320 PRINT :PRINT "YOU SURVIVED THE FOREST"
1330 PRINT "YOU WON A TREASURE TOTAL OF ";Q:PRINT "CONGRADULATIONS"
:PRINT "DO YOU WISH TO TRY AGAIN ? ";:GOTO 510
1340 PRINT "THERE IS NOTHING TO BE FOUND HERE":GOTO 890
1350 END
1360 '***********************************************************
1370 ' THIS ROUTINE PRINTS BRIEF INSTRUCTIONS AND A COMPASS ROSE ON THE SCREEN.
1380 ' IT CAN BE REMOVED IF CONVERSION IS DIFFICULT, BUT LEAVE 'RETURN' IN.
1390 PRINT DC$;"!H";CH$(5);" = YOUR POSITION"
1400 PRINT DC$;"#H";CH$(2);" = TREE (YOU MUST GO AROUND THEM)"
1410 PRINT DC$;"%H";CH$(0);" = FIELD"
1420 PRINT DC$;"'U";"NW N NE"
1430 PRINT DC$;"(W";"y`x"
1440 PRINT DC$;")U";"W a^a E"
1450 PRINT DC$;"*W";"x`y"
1460 PRINT DC$;"+U";"SW S SE"
1470 RETURN
30 PRINT DC$;"(W";"y`x"
1440 PRINT DC$;")U";"W a^a