;===================================================
;----- 8-Bit-Zeichen in FIFO schreiben -------------
;===================================================
;
;ENTRY:     HL zeigt auf Beginn des FIFOs,
;           AKKU enthält Zeichen
;EXIT:      CF=0 --> Zeichen in FIFO eingetragen
;           CF=1 --> FIFO ist voll, Zeichen nicht
;           eingetragen
;
;Struktur des FIFOs:
;  1. Byte: FIFO input pointer (0..255)
;  2. Byte: FIFO output pointer (0..255)
;  3.-258.Byte:         FIFO Datenfeld
;  ---> Gesamtlänge: 258 Byte
;
            .GLOBAL WRFIFO
WRFIFO:     PUSH    HL
            PUSH    BC
            PUSH    AF
            LD      C,(HL)      ;Eingangspointer
            INC     HL
            LD      A,(HL)      ;Ausgangspointer
            DEC     A           ;FIFO voll ?
            CP      C
            JR      Z,FIFFUL    ;ja
            POP     AF
            DEC     HL
            INC     (HL)        ;neuer Pointer
            INC     HL
            INC     HL          ;Datenadresse
            LD      B,0         ;  berechnen
            ADD     HL,BC
            LD      (HL),A
            POP     BC
            POP     HL
            OR      A           ;Carry Flag rücksetzen
            RET
;
FIFFUL:     POP     AF          ;FIFO voll
            POP     BC
            POP     HL
            SCF                 ;Carry Flag setzen
            RET
;
;===================================================
;------ 8-Bit-Zeichen von FIFO lesen ---------------
;===================================================
;
;ENTRY:     HL zeigt auf Beginn des FIFOs
;EXIT:      CF=0, Daten in AKKU sind gültig
;           CF=1, FIFO ist leer
;
            .GLOBAL RDFIFO
RDFIFO:     PUSH    HL
            PUSH    BC
            LD      A,(HL)      ;FIFO Eingangspointer
            INC     HL
            LD      C,(HL)      ;FIFO Ausgangspointer
            CP      C           ;FIFO leer ?
            JR      Z,FIFMPT
            INC     (HL)
            INC     HL          ;Datenadresse
            LD      B,0         ;  berechnen
            ADD     HL,BC
            LD      A,(HL)
            POP     BC
            POP     HL
            OR      A           ;CF=0 ---> Daten OK
            RET
;
FIFMPT:     POP     BC
            POP     HL
            SCF                 ;CF=1 ---> Daten
            RET                 ;  ungültig
;
;===================================================
;----- FIFO löschen --------------------------------
;===================================================
;
;ENTRY:     HL zeigt auf Beginn des FIFOs
;EXIT:      FIFO ist gelöscht und leer
;
            .GLOBAL CLRFIF
CLRFIF:     PUSH    AF
            XOR     A
            LD      (HL),A
            INC     HL
            LD      (HL),A
            DEC     HL
            POP     AF
            RET
;
;===================================================
;----- FIFO Status testen --------------------------
;===================================================
;
;ENTRY:     HL zeigt auf Beginn des FIFOs
;EXIT:      CF=1 ---> FIFO voll
;           ZF=1 ---> FIFO leer
;           AKKU enthält Zahl der Zeichen in FIFO
;
            .GLOBAL TSTFIF
TSTFIF:     LD      A,(HL)
            INC     HL
            SUB     (HL)
            JR      Z,TFE       ;FIFO leer
            CP      0FFH
            JR      Z,TFF       ;FIFO voll
            SCF                 ;FIFO weder voll noch
            CCF                 ;  leer
            DEC     HL
            RET
;
TFE:        SCF
            CCF
            DEC     HL          ;CF=0, ZF=1
            RET
;
TFF:        XOR     A
            LD      A,0FFH
            SCF                 ;CF=1, ZF=0
            DEC     HL
            RET
