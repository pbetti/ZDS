
1  INTEGER DELAY,T(1000)
2  INTEGER X,Y,I
10  STRING A$
100  ERASE 
110  GOSUB 2500: ! Print sign on message
120  WSELECT 0
125  ERASE 
130  WINDOW 0,0,22,78
140  WFRAME "_","|"
150  WINDOW 1,1,21,77
170  GOSUB 2000: ! Print Memo
180  GOSUB 2800: ! Explain pop-down menu
190   X=10:  Y=18
195   A$="data"
200  GOSUB 4000: ! Fix "date"
210   X=10:  Y=71
220   A$="rude"
230  GOSUB 4000: ! Fix "nude"
240   X=13:  Y=57
250   A$="Corps "
260  GOSUB 4000: ! Fix "Corpse"
270   X=17:  Y=11
280   A$="fuel"
290  GOSUB 4000: ! Fix "duel"
1000  STOP 
2000  !
2010  ! Memo to edit
2030  !
2033  PRINT 
2034  PRINT 
2035  PRINT " TO: the Boss"
2040  PRINT " FR: the Salesman"
2050  PRINT " RE: Expense Account"
2060  PRINT 
2070  PRINT "     I know my expenses have been high in the past quarter. I did do quite a"
2080  PRINT " bit  of traveling, and a careful review of my itineraries will explain how"
2090  PRINT " many of these charges were incurred."
2100  PRINT "     First,  during the  trip to  Egypt, I  had a misunderstanding with the"
2110  PRINT " Sheikh about my date and the camels. There was no need for him to be nude,"
2120  PRINT " but after our disagreement, I had to find  another  way out of the desert."
2130  PRINT " The Rolls was the only car available."
2140  PRINT "     Then,  in Paris,  there was the  incident with the Corpse de Ballet. I"
2150  PRINT " guess I didn't need to take all the  ladies to  lunch, but I  thought they"
2160  PRINT " would place a large order for shoe laces."
2170  PRINT "     About  the company  plane, there  was just no way I could have forseen"
2180  PRINT " that the duel would be so expensive. How was I to know about the pilot not"
2190  PRINT " speaking  English. So,  he went  to Australia  instead of Austria, I still"
2200  PRINT " sold four widgets there."
2230  RETURN 
2500  PRINT "This program is a demonstration of some of the capabilities"
2510  PRINT "of MTBASIC by Softaid, Inc. It dramatically shows the power"
2520  PRINT "and versitility of MTBASIC's windowing statements."
2530  PRINT 
2540  PRINT "If you didn't install MTBASIC with the INSTALL program supplied"
2550  PRINT "by Softaid, then this program won't run properly. If you did"
2560  PRINT "the installation, then this program is a great test to ensure"
2570  PRINT "that the installation was correct."
2590  PRINT 
2600  PRINT "This is a demonstration of a word processing application. A"
2610  PRINT "page of text will be automatically edited by the simulation,"
2620  PRINT "demonstrating the ease and simplicity of implementing sophisticated"
2630  PRINT "pop-down menu interfaces. Pop-up menus are just as easy to code."
2640  PRINT 
2650  PRINT "Hit any key when you're ready to proceed."
2660   IF  KEY = 0 THEN  GOTO 2660
2670  RETURN 
2800  !
2801  ! Print explanation
2802  !
2805  CURSOR 1,0
2810  PRINT "___________________________________________________________________________________"
2815  CURSOR 0,12
2820  PRINT "Selection"
2830  WSELECT 1
2833  FOR I=1 TO 16
2835  GOSUB 3000: ! Delay
2836  NEXT I
2840  WINDOW 10,6,18,74
2845  WSAVE T(1)
2846  WCLEAR 
2850  WFRAME "_","|"
2860  WINDOW 11,8,17,73
2870  PRINT 
2880  PRINT "   The top line contains 'selection', which allows"
2890  PRINT "the user to get to word processing commands. Assuming a mouse were"
2900  PRINT "connected, the user might click 'selection', causing a menu of"
2910  PRINT "editing options to appear. The desired option would then be "
2920  PRINT "clicked to select it."
2925  FOR I=1 TO 5
2930  GOSUB 3000: ! Delay
2931  NEXT I
2935  WINDOW 10,6,18,74
2940  WUPDATE T(1)
2950  WSELECT 0
2990  RETURN 
3000  !
3010  ! Delay subroutine to make it appear that a slow human is editing
3020  !
3030  FOR DELAY=1 TO 2000
3040  NEXT DELAY
3050  RETURN 
3100  !
3110  ! Display an error window
3120  !
3125  WSELECT 2
3130  WINDOW X,Y,X + 2,Y + 7
3135  WSAVE T(1)
3136  WCLEAR 
3140  WFRAME "_","|"
3145  CURSOR 1,1
3160  PRINT "Error"
3170  GOSUB 3000: ! Delay
3180  WUPDATE T(1)
3190  RETURN 
3300  !
3310  ! Display pop down menu
3320  !
3330  WSELECT 2
3340  WINDOW 2,10,8,24
3350  WSAVE T(1)
3355  WCLEAR 
3360  WFRAME "_","|"
3370  WINDOW 3,14,7,23
3380  PRINT " Change"
3390  PRINT " Search"
3400  PRINT " Load"
3410  PRINT " Save"
3420  PRINT " Quit"
3430  GOSUB 3000: ! Delay
3432  CURSOR 0,0
3433  PRINT "*";
3435  GOSUB 3000
3440  WINDOW 2,10,8,24
3450  WUPDATE T(1)
3455  WSELECT 0
3460  RETURN 
4000  !
4010  ! Flag and fix an error
4020  !
4030  GOSUB 3100: ! Draw an error box
4040  GOSUB 3300: ! Draw pop-down menu
4050   Y=Y - 1
4060  CURSOR X,Y
4070  PRINT A$
4080  RETURN 
END
aw an error box
4040  GOSUB 3300: ! Draw pop-down menu
4050   Y=Y - 1
4060  CURSOR X,Y
4070  PRIT A$
4080  RETURN 
END
aw an error box
4040  GOSUB 3300: ! Draw pop-down menu
4050   Y=Y - 1
4060  CURSOR X,Y
4070  PRI