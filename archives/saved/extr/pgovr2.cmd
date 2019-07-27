STORE 20 TO CICLO2
DO WHILE CICLO2<24
@ CICLO2,0 SAY GABBIA
STORE CICLO2+1 TO CICLO2
ENDDO
RETURN
















LDEMO,1,78)+CHR(202)
@  2,0  SAY GABBIA
@  3,0  SAY GABBIA
@  4,0  SAY GABBIA
@  5,0  SAY CHR(195)+$(LDEMO,1,78)+CHR(196)
@  6,0  SAY GABBIA
@  7,0  SAY GABBIA
@  8,0  SAY GABBIA
@  9,0  SAY GABBIA
@ 10,0  SAY GABBIA
@ 11,0  SAY GABBIA
@ 12,0  SAY GABBIA
@ 13,0  SAY GABBIA
@ 14,0  SAY GABBIA
@ 15,0  SAY GABBIA
@ 16,0  SAY GABBIA
@ 17,0  SAY GABBIA
@ 18,0 AY GABBIA
@ 19,0  SAY GABBIA
@ 20,0  SAY CHR(195)+$(LDEMO,1,78)+CHR(196)
@ 21,0  SAY GABBIA
@ 22,0  SAY GABBIA
@ 23,0  SAY GABBIA
@ 24,0  SAY CHR(199)+$(LDEMO,1,78)+CHR(200)
? CHR(23)
@  0,0  SAY " "
@  1,0  SAY CHR(201)
@  2,65 SAY "DATA:"+DATE()
@  2,1  SAY " VERSIONE 1.03   AUTORE: PIERGIORGIO BETTI  (C) 21/04/86"
POKE 40,245
@  3,31 SAY "ARCHIVIO PROGRAMMI"
POKE 40,255
@  0,13 SAY "MODO:"
@  0,28 SAY "REC:"
@  4,2  SAY "MS-DOS  CP/M 80-86  NE-DOS"
@  4,57 SAY "* PGB SOFTWARE SYS. *"