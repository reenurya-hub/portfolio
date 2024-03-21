       IDENTIFICATION DIVISION.
       PROGRAM-ID. TSTWRTFILREG.
      *
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
       SELECT INVENTARIO ASSIGN TO "INVENTARIO.DAT"
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
           77 WS-F-VRUNIT PIC Z(11)9.
           77 WS-F-CANT   PIC Z(11)9.
           77 WS-FOUND    PIC 9 VALUE 0.
      *
           77 WS-END-FILE        PIC 9 VALUE 0.
           77 WS-CODART PIC 9(5) OCCURS 100 TIMES.
           77 WS-DESCART PIC X(60) OCCURS 100 TIMES.
           77 WS-CODART-SRCH PIC 9(5).
           77 FIN-FICHERO PIC 9 VALUE 0.
           77 WS-KEY PIC X.
           77 X1 PIC 9.
           01 EOF-SWITCH PIC X VALUE "N".
       PROCEDURE DIVISION.
      ******************************************************************
      *MAIN-PROCEDURE
      ******************************************************************
       MAIN-PROCEDURE.
           DISPLAY "Programa de inventario"
           DISPLAY "Busqueda de articulo por codigo"
           DISPLAY "Ingrese el codigo de producto a buscar:"
                   WITH NO ADVANCING
           ACCEPT WS-CODART-SRCH
           PERFORM 100-SEARCH-RECORD
      *     CLOSE INVENTARIO
           STOP RUN.
      ******************************************************************
      *END MAIN-PROCEDURE
      ******************************************************************
      *
      ******************************************************************
      *100-SEARCH-RECORD
      ******************************************************************
       100-SEARCH-RECORD.
           OPEN INPUT INVENTARIO
           PERFORM UNTIL WS-END-FILE = 1
              READ INVENTARIO
                 AT END
      *          END OF FILE
                    SET WS-END-FILE TO 1
                    IF WS-FOUND = 0 THEN
                       DISPLAY "No se encontro un registro que coicida",
                               " con su criterio de busqueda."
                    END-IF
      *          CODART DOES NOT EXISTS
                  NOT AT END
                     IF CODART = WS-CODART-SRCH THEN
                        SET WS-FOUND TO 1
                        SET WS-END-FILE TO 1
                        EXIT PERFORM
                     ELSE
                        DISPLAY "CODIGO   : "CODART
                        DISPLAY "Descripcion   : "DESCART
      *                 CODART EXISTS
                        DISPLAY "Unidad Medida : "UNIDDS
                        DISPLAY "Valor Unitario: "
                           WITH NO ADVANCING
                        MOVE FUNCTION NUMVAL(VRUNIT) TO WS-F-VRUNIT
                        DISPLAY function trim(WS-F-VRUNIT,LEADING)
                        DISPLAY "Cantidad      : "
                           WITH NO ADVANCING
                        MOVE FUNCTION NUMVAL(CANT) TO WS-F-CANT
                        DISPLAY FUNCTION TRIM(WS-F-CANT,LEADING)

                     END-IF
               END-PERFORM
           CLOSE INVENTARIO.
           DISPLAY "Presione cualquier tecla para salir. "
           ACCEPT WS-KEY.
      ******************************************************************
      *END 100-SEARCH-RECORD
      ******************************************************************
      *
       END PROGRAM TSTWRTFILREG.
