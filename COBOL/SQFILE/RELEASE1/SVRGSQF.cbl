      ******************************************************************
      * Program: SVRGSQF.cbl
      * Purpose: Save a single searched record in another
      *          sequential file.
      * Date:    19-Mar-2024
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. SVRGSQF.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT INVENTARIO ASSIGN TO "INVENT.DAT"
               ORGANIZATION IS SEQUENTIAL.
           SELECT OUTPUT-FILE ASSIGN TO "OUTPUT.DAT"
               ORGANIZATION IS SEQUENTIAL.
       DATA DIVISION.
       FILE SECTION.
       FD INVENTARIO.
       01 INVENT-REG.
           02 CODART  PIC 9(5).
           02 DESCART PIC X(60).
           02 UNIDDS  PIC X(60).
           02 VRUNIT  PIC 9(12).
           02 CANT    PIC 9(12).
       FD OUTPUT-FILE.
       01 OUTPUT-REG.
           02 OR-CODART  PIC 9(5).
           02 OR-DESCART PIC X(60).
           02 OR-UNIDDS  PIC X(60).
           02 OR-VRUNIT  PIC 9(12).
           02 OR-CANT    PIC 9(12).
      *
       WORKING-STORAGE SECTION.
       01 WS-RECORD.
           02 WS-CODART  PIC 9(5).
           02 WS-DESCART PIC X(60).
           02 WS-UNIDDS  PIC X(60).
           02 WS-VRUNIT  PIC 9(12).
           02 WS-CANT    PIC 9(12).
      *
           77 WS-CODART-SRCH  PIC 9(5).
           77 FIN-FICHERO     PIC 9 VALUE 0.
           77 X1              PIC 9.
           77 FLAG-ENCONTRADO PIC 9 VALUE 0.
           77 WS-KEY          PIC X.
       01 EOF-SWITCH PIC X VALUE "N".
       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           DISPLAY "Programa de inventario",
           DISPLAY "Ingrese el codigo de producto a buscar: "
                WITH NO ADVANCING
           ACCEPT WS-CODART-SRCH
           DISPLAY SPACE
           PERFORM 100-RDFL-SRCH
           PERFORM 200-WR-OUTFILE
           STOP RUN.
      *
       100-RDFL-SRCH.
           SET X1 TO 1
           OPEN INPUT INVENTARIO
           PERFORM UNTIL EOF-SWITCH = 'Y'
              READ INVENTARIO
              AT END
                 MOVE "Y" TO EOF-SWITCH
              NOT AT END
                  IF CODART = WS-CODART-SRCH THEN
                    SET FLAG-ENCONTRADO TO 1
                    MOVE CODART  TO WS-CODART
                    MOVE DESCART TO WS-DESCART
                    MOVE UNIDDS  TO WS-UNIDDS
                    MOVE VRUNIT  TO WS-VRUNIT
                    MOVE CANT    TO WS-CANT
                    EXIT PERFORM
                 END-IF
           END-PERFORM
           CLOSE INVENTARIO.
      *
       200-WR-OUTFILE.
           SET X1 TO 1.
           OPEN OUTPUT OUTPUT-FILE
           IF FLAG-ENCONTRADO = 1
              MOVE WS-RECORD TO OUTPUT-REG
              WRITE OUTPUT-REG
              DISPLAY "Se ha encontrado un registro para el codigo",
                      "de articulo y se ha guardado en el archivo",
                      " OUTPUT.DAT"
           ELSE
              DISPLAY "Articulo no encontrado!"
           END-IF
           CLOSE OUTPUT-FILE
           DISPLAY "Presione cualquier tecla para salir. "
           ACCEPT WS-KEY.
       END PROGRAM SVRGSQF.
