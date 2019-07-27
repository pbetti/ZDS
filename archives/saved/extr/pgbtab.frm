'
APPEND     
542,04 EKOP         
OMEDL YAS 0,1 @        6  SAY 'EliminaMENU
   ERASE
   @  2,0  SAY LDEMO
   POKE 40,245
   ? CHR(27)+CHR(53)+CHR(35)+' PROGRAMMA GESTIONE CLIENTI/FORNITORI'
   POKE 40,255
   @  4,0 SAY LDEMO
   @  7,12 SAY 'prog. dBASE II by Piergiorgio Betti - VER 6.0   01/11/86'
   @  9,9  SAY 'Aggiungere una scheda'
   @  9,50 SAY 'Stampare etichette'
   @ 11,12 SAY 'Cercare un nome'
   @ 11,50 SAY 'Modificare il file'
   @ 13,6  SAY 'Eliminare le schede marcate'
  AMO             00148320161035/248442                    10VVS FNT 38M28 A794V                                      0       01MD125 MODELLISMO                    Via Marconi, 81 (Staz. FNM)   21033VACITTIGLIO                      0332/603324                    5Di Pasquali Luciano                                      0       01MD208 MODELLISMO BELGRADO           Via Gemona, 70/a              33100UDUDINE               013584103040432/502801                    5di Gianesini Anna                              STORE 'X' TO VARMEN
DO WHILE VARMEN<>'#'
ERASE
? 'GESTIONE ORDINATIVI ------------------------------------------ DATA:'+DATE()
? LDEMO
@ 10,10 SAY '1. Accettazione ordinativi'
@ 12,10 SAY '2. Verifica ordinativi'
@ 14,10 SAY '3. Fine'
@ 20,0  SAY ' '
WAIT TO VAR
DO CASE
CASE VAR='1'
@ 4,0 SAY CHR(14)
ACCEPT 'PER CONTINUARE MI OCCORRE IL NOMINATIVO ---->' TO ANOME
LOCATE FOR @(ANOME,NOME)<>0
STORE 'X' TO ANSWER
DO WHILE !(ANSWER)<>'S'
   @ 6,0 SAY ' '
   ? CODICE,NOME,CITTA
   ?
   ? "E' 