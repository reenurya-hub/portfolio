      ******************************************************************
      * Program: RDSEQFIL.cbl
      * Purpose: reads data in sequential file
      * Date:    19-Mar-2024
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. RDSEQFIL.
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
      *
       WORKING-STORAGE SECTION.
           77 FIN-FICHERO PIC 9 VALUE 0.
           77 WS-KEY PIC X.
       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           DISPLAY "Programa de inventario",
           OPEN INPUT INVENTARIO
           PERFORM LEER-INVENT
           DISPLAY "Presione cualquier tecla para salir. ".
           ACCEPT WS-KEY
            STOP RUN.
      * Reads from file
       LEER-INVENT.
            MOVE 0 TO FIN-FICHERO
            CLOSE INVENTARIO
      *     Open as input for read.
            OPEN INPUT INVENTARIO
      *    Perform and reads record by record until flag sets to 1.
            PERFORM UNTIL FIN-FICHERO = 1
                READ INVENTARIO
                   AT END
      *                MOVE 1 TO FIN-FICHERO
                      SET FIN-FICHERO TO 1
                   NOT AT END
                      PERFORM LEER-REGISTRO
                END-READ
            END-PERFORM.
      * Display record on screen
       LEER-REGISTRO.
            DISPLAY "Codigo articulo:" CODART
            DISPLAY "Descripcion    :" DESCART
            DISPLAY "Unidades       :" UNIDDS
            DISPLAY "Valor unitario :" VRUNIT.
      *
       END PROGRAM RDSEQFIL.
