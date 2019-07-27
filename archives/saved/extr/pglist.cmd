@ 15,6  SAY 'E'
   @ 15,50 SAY 'L'
   @ 17,19 SAY 'O'
   @ 17,60 SAY 'F'
   @ 19,17 SAY 'D'
   @ 19,54 SAY 'T'
   POKE 40,255
   @ 20,0  SAY ' '
   ?
   ?
   WAI
DO WHILE !(ANSWER)<>'S'
   @ 6,0 SAY ' '
   ? CODICE,NOME,CITTA
   ?
   ? "E' esatto  (S=si)"
   WAIT TO ANSWER
   IF !(ANSWER)<>'S' .AND. .NOT. EOF
      CONTINUE
      LOOP
   ELSE
      IF !(ANSWER)<>'S' .AND. EOF
         RETURN
      ENDIF
   ENDIF
ENDDO
@ 3,0 SAY Y 'I'
   POKE 40,255
   @ 22,0  SAY LDEMO
   WAIT TO RISP
   STORE !(RISP) TO RISP
   DO CASE
      CASE RISP='A'
         STORE '1' TO FLAG
         DO B:MANIP
      CASE RISP='S'
         STORE '1' TO FLAG
         DO B:CLIFOSTA
      CASE RISP='C'
         STORE '2' TO FLAG
         DO B:MANIP
      CASE RISP='M'
         ERASE
         ? "Per modificare l'intero archivio premi solo RETURN"
         ACCEPT "altrimenti batti il nome del cliente (forn.) >" TO ANOME
         IF ANOME<>' '
            LOCATE FOR NOME=ANOME
            EDIT #
            ? CHR(2)
            LOOP
         ENDIF
         BROWSE
         ? CHR(2)
         LOOP
      CASE RISP='E'
         DO B:CLIFOERA
         LOOP
      CASE RISP='L'
         ERASE
         ? 'CONTENUTO FILE    (codice,nome,citta,telefono,copie)'
         ? LDEMO
         DISPLAY ALL CODICE,NOME,CITTA,TELEFONO,COPIE OFF
         ? LDEMO
         WAIT
         LOOP
      CASE RISP='G'
         DO B:CLIFOORD
      CASE RIS