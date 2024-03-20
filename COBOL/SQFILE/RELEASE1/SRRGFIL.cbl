      ******************************************************************
      * Program: SRRGFIL.cbl
      * Purpose: search article code and display one record
      * in sequential file
      * Date:    19-Mar-2024
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. SRRGFIL.
      *
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
       SELECT INVENTARIO ASSIGN TO "INVENT.DAT"
       ORGANIZATION IS SEQUENTIAL.
      *
       DATA DIVISION.
       FILE SECTION.
       FD INVENTARIO.
       01 INVENT-REG.
           02 CODART  PIC 9(5).
           02 DESCART PIC X(60).
           02 UNIDDS  PIC X(60).
           02 VRUNIT  PIC 9(12).
           02 CANT    PIC 9(12).
       WORKING-STORAGE SECTION.
       01 WS-FLAGS PIC X.
           77 WS-CODART      PIC 9(5) OCCURS 100 TIMES.
           77 WS-DESCART     PIC X(60) OCCURS 100 TIMES.
           77 WS-UNIDDS      PIC X(60) OCCURS 100 TIMES.
           77 WS-VRUNIT      PIC 9(12) OCCURS 100 TIMES.
           77 WS-CANT        PIC 9(12) OCCURS 100 TIMES.
           77 WS-CODART-SRCH PIC 9(5).
           77 WS-KEY         PIC X.
           77 X1             PIC 9.
           01 EOF-SWITCH     PIC X VALUE "N".
       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           OPEN INPUT INVENTARIO
           DISPLAY "Programa de inventario"
           PERFORM 100-READ-FILE
           DISPLAY "Ingrese el codigo de producto a buscar:"
                   WITH NO ADVANCING
           ACCEPT WS-CODART-SRCH
           PERFORM 200-SEARCH-FILE
           CLOSE INVENTARIO
           STOP RUN.
      *
       100-READ-FILE.
           SET X1 TO 1
           PERFORM VARYING X1 FROM 1 BY 1 UNTIL EOF-SWITCH = "Y"
              READ INVENTARIO
              AT END
                 MOVE "Y" TO EOF-SWITCH
              NOT AT END
                 MOVE CODART  TO WS-CODART (X1)
                 MOVE DESCART TO WS-DESCART (X1)
                 MOVE UNIDDS  TO WS-UNIDDS (X1)
                 MOVE VRUNIT  TO WS-VRUNIT (X1)
                 MOVE CANT    TO WS-CANT (X1)
           END-PERFORM.
      *
       200-SEARCH-FILE.
           SET X1 TO 1.
           PERFORM VARYING X1 FROM 1 BY 1 UNTIL X1 > 100
              IF WS-CODART (X1) = WS-CODART-SRCH
                 DISPLAY "Descripcion de articulo: "WS-DESCART (X1)
                 DISPLAY "Unidad de medida       : "WS-UNIDDS (X1)
                 DISPLAY "Valor unitario         : "WS-VRUNIT (X1)
                 DISPLAY "Cantidad               : "WS-CANT (X1)
                 EXIT PERFORM
              END-IF
           END-PERFORM.
           IF X1 > 100
              DISPLAY "Registro no encontrado"
           END-IF.
           DISPLAY "Presione cualquier tecla para salir. ".
           ACCEPT WS-KEY.
      *
       END PROGRAM SRRGFIL.
