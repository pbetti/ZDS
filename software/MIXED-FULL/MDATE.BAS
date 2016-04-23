100 REM **** ZTIME-I Microsoft Basic Driver routines ****
110 REM 
120 REM Written by: Alan D. Percy
130 REM Date written: 7/28/84
140 REM
150 REM Two routines are provided as follows:
160 REM Line 7000: Get ASCII date string in string variable DATE$
170 REM Line 8000: Get binary date in array BDATE%(1-6)
180 REM
190 REM The mainline of this program (line 1000) will
200 REM call the above routines to print the current
210 REM date and time.
220 REM
230 REM The required variables and arrays are defined at line
240 REM numbers 500 on.  These must also be included with
250 REM any programs that use the ZTIME-I clock board.
260 REM
500 DIM BDATE%(6)     'PLACE TO PUT BINARY DATE AND TIME
510 CBASE%=&HE0      ' address of clock chip
1000 REM **************************************************
1010 REM * Begining of Program Mainline to Display Date   *
1020 REM **************************************************
1030 GOSUB 7000            'get current date and time in ASCII
1040 PRINT "Mdate:   Version 1.0    7/28/84"
1050 PRINT "The current date and time is: ";DATE$
1060 END
7000 REM *************************************************
7010 REM * Get current date and time in ASCII into DATE$ *
7020 REM *************************************************
7030 REM The date and time is returned in the following form:
7040 REM
7050 REM    Mon Jan 23 10:51:32 AM
7060 REM
7070 REM Variables used:
7080 REM    ZZFLAG%
7090 REM *************************************************
7100 DATE$=""           'null out string variable
7110 GOSUB 8000         'get binary date and time
7120 IF BDATE%(3) = 1 THEN DATE$="Sun " : GOTO 7200
7130 IF BDATE%(3) = 2 THEN DATE$="Mon " : GOTO 7200
7140 IF BDATE%(3) = 3 THEN DATE$="Tue " : GOTO 7200
7150 IF BDATE%(3) = 4 THEN DATE$="Wed " : GOTO 7200
7160 IF BDATE%(3) = 5 THEN DATE$="Thu " : GOTO 7200
7170 IF BDATE%(3) = 6 THEN DATE$="Fri " : GOTO 7200
7180 IF BDATE%(3) = 7 THEN DATE$="Sun " : GOTO 7200
7190 DATE$="*** "       'invalid day of the week
7200 IF BDATE%(1) = 1 THEN DATE$=DATE$+"Jan" : GOTO 7340
7210 IF BDATE%(1) = 2 THEN DATE$=DATE$+"Feb" : GOTO 7340
7220 IF BDATE%(1) = 3 THEN DATE$=DATE$+"Mar" : GOTO 7340
7230 IF BDATE%(1) = 4 THEN DATE$=DATE$+"Apr" : GOTO 7340
7240 IF BDATE%(1) = 5 THEN DATE$=DATE$+"May" : GOTO 7340
7250 IF BDATE%(1) = 6 THEN DATE$=DATE$+"Jun" : GOTO 7340
7260 IF BDATE%(1) = 7 THEN DATE$=DATE$+"Jul" : GOTO 7340
7270 IF BDATE%(1) = 8 THEN DATE$=DATE$+"Aug" : GOTO 7340
7280 IF BDATE%(1) = 9 THEN DATE$=DATE$+"Sep" : GOTO 7340
7290 IF BDATE%(1) = 10 THEN DATE$=DATE$+"Oct" : GOTO 7340
7300 IF BDATE%(1) = 11 THEN DATE$=DATE$+"Nov" : GOTO 7340
7310 IF BDATE%(1) = 12 THEN DATE$=DATE$+"Dec" : GOTO 7340
7330 DATE$=DATE$+"***"
7340 IF BDATE%(4) < 12 THEN 7380      'see if AM, jump if so.
7350 ZZFLAG%=-1                       'set pm flag
7360 IF BDATE%(4) > 12 THEN BDATE%(4)=BDATE%(4)-12   'convert to normal time
7370 GOTO 7400                        'skip over else
7380 ZZFLAG%=0                        'it's AM so clear PM flag
7390 IF BDATE%(4) = 0 THEN BDATE%(4)=12 'if 12 midnight make it 12 not 0
7400 DATE$=DATE$+STR$(BDATE%(4))+":"  'add hours to print string
7410 IF BDATE%(5)<10 THEN DATE$=DATE$+"0"  'add leading zero
7420 DATE$=DATE$+MID$(STR$(BDATE%(5)),2)+":"  'put minutes on
7430 IF BDATE%(6)<10 THEN DATE$=DATE$+"0"   'add leading zero if required
7440 DATE$=DATE$+MID$(STR$(BDATE%(6)),2)    'put seconds on
7450 IF ZZFLAG% THEN DATE$=DATE$+" PM"      'if pm put PM on
7460 IF NOT ZZFLAG% THEN DATE$=DATE$+" AM" 'if am put AM on
7470 RETURN
8000 REM **************************************************
8010 REM * Get binary date and time into array BDATE%(1-6) *
8020 REM **************************************************
8030 REM The array BDATE% is returned with the following
8040 REM values in it:
8050 REM     BDATE%(1) = Month number (1-12)
8060 REM     BDATE%(2) = Day of the month (1-31)
8070 REM     BDATE%(3) = Day of the week (1-7)
8080 REM     BDATE%(4) = Hours (0-23)
8090 REM     BDATE%(5) = Minutes (0-59)
8100 REM     BDATE%(6) = Seconds (0-59)
8110 REM
8120 REM Variables used:
8130 REM    YYI%, YYFLAG%, YYTMP%
8140 REM
8150 REM **************************************************
8160 REM First get Date and Time in BCD from chip.
8170 FOR YYI%=1 TO 6
8180 BDATE%(YYI%)=INP(CBASE%+8-YYI%)    'get bcd value
8190 NEXT YYI%
8200 YYFLAG%=0                      'assume date is good and set otherwise
8210 FOR YYI%=1 TO 6                'read it again and make sure the are equal
8220 IF INP(CBASE%+8-YYI%) <> BDATE%(YYI%) THEN YYFLAG% = -1  'if not the same set flag
8230 NEXT YYI%
8240 IF YYFLAG% = -1 THEN 8170      'try it again if two read not the same
8250 FOR YYI%=1 TO 6                 'convert numbers from BCD to binary
8260 YYTMP%=INT(BDATE%(YYI%)/16)       'get left digit
8270 BDATE%(YYI%)=YYTMP%*10+BDATE%(YYI%)-YYTMP%*16 'all converted
8280 NEXT YYI%
8290 RETURN
I%)/16)       'get left digit
8270 BDATE%(YYI%)=YYTMP%*10+BDATE%(YYI%)-YYTMP%*16 'all converted
8280 NEXT YYI%
8290 RETUR