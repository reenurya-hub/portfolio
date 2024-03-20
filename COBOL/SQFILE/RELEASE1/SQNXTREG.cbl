       IDENTIFICATION DIVISION.
       PROGRAM-ID. SQNXTREG.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT INVENTARIO ASSIGN TO "INVENT.DAT"
               ORGANIZATION IS SEQUENTIAL.
           SELECT NEXTREG-FILE ASSIGN TO "NEXTFILE.DAT"
               ORGANIZATION IS SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD INVENTARIO.
       01 INVENT-REG.
           02 CODART  PIC 9(5).
           02 DESCART PIC X(60).
           02 UNIDDS  PIC X(60).
      *     02 VRUNIT  PIC 9(12).
      *     02 CANT    PIC 9(12).
       FD NEXTREG-FILE.
       01 NR-INVENT-REG.
           02 NR-CODART  PIC 9(5).
           02 NR-DESCART PIC X(60).
           02 NR-UNIDDS  PIC X(60).
      *     02 NR-VRUNIT  PIC 9(12).
      *     02 NR-CANT    PIC 9(12).

       WORKING-STORAGE SECTION.
           77 WS-CODART PIC 9(5) OCCURS 100 TIMES.
           77 WS-DESCART PIC X(60) OCCURS 100 TIMES.
           77 WS-UNIDDS PIC X(60) OCCURS 100 TIMES.
      *     77 WS-VRUNIT PIC 9(12) OCCURS 100 TIMES.
      *     77 WS-CANT PIC 9(12) OCCURS 100 TIMES.
           77 WS-CODART-SRCH PIC 9(5).
           77 FIN-FICHERO PIC 9 VALUE 0.
           77 WS-KEY PIC X.
           77 X1 PIC 9 value 0.
           77 NEXT-INDEX PIC 9 VALUE 0.
           77 FLAG-ENCONTRADO PIC 9.
           01 EOF-SWITCH PIC X VALUE "N".

       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           DISPLAY "Programa de inventario"
           PERFORM 100-READ-FILE
           DISPLAY "Ingrese el codigo de producto a buscar:"
           ACCEPT WS-CODART-SRCH
           PERFORM 200-SEARCH-REG
           STOP RUN.
       100-READ-FILE.
           SET X1 TO 1
           OPEN INPUT INVENTARIO
           PERFORM VARYING X1 FROM 1 BY 1 UNTIL EOF-SWITCH = "Y"
              READ INVENTARIO
              AT END
                 MOVE "Y" TO EOF-SWITCH
      *            EXIT PERFORM
              NOT AT END
              DISPLAY "X1:"X1
                 IF NOT (CODART = SPACE OR CODART = LOW-VALUE)
                 MOVE CODART TO WS-CODART (X1)
                 DISPLAY "WS-CODART (X1)"WS-CODART (X1)
                 MOVE DESCART TO WS-DESCART (X1)
                 DISPLAY "WS-DESCART (X1)"WS-DESCART (X1)
                 MOVE UNIDDS TO WS-UNIDDS (X1)
                 DISPLAY "WS-UNIDDS (X1)"WS-UNIDDS (X1)
                 END-IF
      *           MOVE VRUNIT TO WS-VRUNIT (X1)
      *           MOVE CANT TO WS-CANT (X1)
           END-PERFORM
           CLOSE INVENTARIO.
       200-SEARCH-REG.
           OPEN OUTPUT NEXTREG-FILE
           DISPLAY "WS-CODART-SRCH:"WS-CODART-SRCH
           SET X1 TO 1
           PERFORM VARYING X1 FROM 1 BY 1 UNTIL X1 > 100
           DISPLAY "X1:"X1
           DISPLAY "WS-CODART (X1):"WS-CODART (X1)
              IF WS-CODART (X1) = WS-CODART-SRCH
                 MOVE X1 TO NEXT-INDEX
                 COMPUTE NEXT-INDEX = NEXT-INDEX + 1
                 DISPLAY "NEXT-INDEX:"NEXT-INDEX
                 EXIT PERFORM
              END-IF
           END-PERFORM
           IF NEXT-INDEX <> 0
              SET X1 TO NEXT-INDEX
              PERFORM VARYING X1 FROM 1 BY 1 UNTIL X1 > 100
                  MOVE WS-CODART (X1) TO NR-CODART
                  MOVE WS-DESCART (X1) TO NR-DESCART
                  MOVE WS-UNIDDS (X1) TO NR-UNIDDS
                  DISPLAY "NR-CODART:"NR-CODART
      *            MOVE WS-VRUNIT (X1) TO NR-VRUNIT
      *            MOVE WS-CANT (X1) TO NR-CANT
                  WRITE NR-INVENT-REG
              END-PERFORM
              DISPLAY "Registros encontrados y guardados en",
                      " NEXTFILE.DAT"
              DISPLAY "Presione cualquier tecla para salir. "
              ACCEPT WS-KEY
           ELSE
              DISPLAY "Registro no encontrado!"
           END-IF
           CLOSE NEXTREG-FILE.
      *
       END PROGRAM SQNXTREG.
