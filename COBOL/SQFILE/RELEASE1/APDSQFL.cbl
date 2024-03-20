      ******************************************************************
      * Program: APDSQFL.cbl
      * Purpose: append in last record in sequential file
      * Date:    19-Mar-2024
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. APDSQFL.
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
           02 CODART      PIC 9(5).
           02 DESCART     PIC X(60).
           02 UNIDDS      PIC X(60).
           02 VRUNIT      PIC 9(12).
           02 CANT        PIC 9(12).
       WORKING-STORAGE SECTION.
       01 WS-FLAGS  PIC X.
           77 WS-COUNT    PIC 9 VALUE 0.
           77 WS-TIMS     PIC 9(1).
           77 WS-KEY      PIC X(1).
       PROCEDURE DIVISION.
       MAIN.
           OPEN EXTEND INVENTARIO
           DISPLAY "Programa de inventario".
           DISPLAY "Ingrese numero de articulos a agregar:  ".
           ACCEPT WS-TIMS.
           IF WS-TIMS < 1 THEN
              MOVE 1 TO WS-TIMS
              DISPLAY "Numero de registros a ingresar: " WS-TIMS
              ACCEPT WS-KEY
           END-IF.
           PERFORM CLEAR-SCREEN.
           PERFORM  WS-TIMS TIMES
      *     PERFORM VARYING WS-COUNT FROM 1 BY 1 UNTIL WS-COUNT<= WS-TIMS
              COMPUTE WS-COUNT = WS-COUNT + 1
              DISPLAY "Articulo No.:"WS-COUNT " DE " WS-TIMS
              PERFORM AGREGAR
              PERFORM CLEAR-SCREEN
           END-PERFORM.
      *
           DISPLAY "Registros insertados en el archivo INVENT.DAT ".
           DISPLAY "Presione cualquier tecla para salir. ".
           ACCEPT WS-KEY
           PERFORM CLOSE-FILE.
           GO TO END-EXECUTION.
       AGREGAR.
           DISPLAY "Programa de inventario".
           DISPLAY "Codigo de articulo:    " WITH NO ADVANCING.
           ACCEPT CODART.
           DISPLAY "Descripcion articulo:  " WITH NO ADVANCING.
           ACCEPT DESCART.
           DISPLAY "Unidad de medida:      " WITH NO ADVANCING.
           ACCEPT UNIDDS.
           DISPLAY "Cantidad (existencias):" WITH NO ADVANCING.
           ACCEPT CANT.
           WRITE INVENT-REG.
      *
       CLEAR-SCREEN.
           CALL "SYSTEM" USING "CLS".
      *
       CLOSE-FILE.
           CLOSE INVENTARIO.
      *
       END-EXECUTION.
           EXIT PROGRAM.
      *
       END PROGRAM APDSQFL.
