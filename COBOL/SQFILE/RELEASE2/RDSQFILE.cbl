      ******************************************************************
      * Program: RDSQFILE.cbl
      * Author:  Reinaldo Urquijo
      * Purpose: Read all records from sequential file and displays on
      *          the screen.
      * Date:    20-Mar-2024
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. RDSQFILE.
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
      *
       WORKING-STORAGE SECTION.
           77 WS-F-CODART PIC Z(4)9.
           77 WS-F-VRUNIT PIC Z(11)9.
           77 WS-F-CANT   PIC Z(11)9.
       01 I PIC 9(2).
           77 FIN-FICHERO PIC 9 VALUE 0.
           77 WS-KEY PIC X.
      *
       01  SCREEN-CHARS.
           03  WS-TIT-CODART    PIC X(7)  VALUE 'CODIGO '.
           03  WS-TIT-DESCART   PIC X(60) VALUE 'DESCRIPCION'.
           03  WS-TIT-UNIDDS    PIC X(60) VALUE 'UNIDAD DE MEDIDA '.
           03  WS-TIT-VRUNIT    PIC X(12) VALUE '   VL. UNIT.'.
           03  WS-TIT-CANT      PIC X(12) VALUE '    CANTIDAD'.
      *
       PROCEDURE DIVISION.
      ******************************************************************
      *MAIN-PROCEDURE
      ******************************************************************
       MAIN-PROCEDURE.
           DISPLAY "Programa de inventario"
           DISPLAY "Informe de inventario"
      *     OPEN INPUT INVENTARIO
           PERFORM HEADER
           PERFORM READ-FILE
           DISPLAY "Presione cualquier tecla para salir. ".
           ACCEPT WS-KEY
           STOP RUN.
      *----------------------------------------------------------------*
      *
      ******************************************************************
      *HEADER
      ******************************************************************
       HEADER.
           DISPLAY WS-TIT-CODART   WITH NO ADVANCING
           DISPLAY WS-TIT-DESCART
           DISPLAY WS-TIT-UNIDDS   WITH NO ADVANCING
           DISPLAY WS-TIT-VRUNIT   WITH NO ADVANCING
           DISPLAY WS-TIT-CANT
           EXIT.
      *----------------------------------------------------------------*
      *
      ******************************************************************
      *READ-FILE
      ******************************************************************
       READ-FILE.
           MOVE 0 TO FIN-FICHERO
      *     CLOSE INVENTARIO
           OPEN INPUT INVENTARIO
           PERFORM UNTIL FIN-FICHERO = 1
              READ INVENTARIO
                 AT END
                    MOVE 1 TO FIN-FICHERO
                 NOT AT END
                    PERFORM DISPLAY-RECORD
                 END-READ
            END-PERFORM
           CLOSE INVENTARIO
           EXIT.
      *----------------------------------------------------------------*
      *
      ******************************************************************
      *DISPLAY-RECORD
      ******************************************************************
       DISPLAY-RECORD.
           MOVE FUNCTION NUMVAL(CODART) TO WS-F-CODART
           DISPLAY WS-F-CODART WITH NO ADVANCING
           DISPLAY ' ' WITH NO ADVANCING
           DISPLAY DESCART
           DISPLAY UNIDDS WITH NO ADVANCING
           DISPLAY ' ' WITH NO ADVANCING
           MOVE FUNCTION NUMVAL(VRUNIT) TO WS-F-VRUNIT
           DISPLAY WS-F-VRUNIT WITH NO ADVANCING
           DISPLAY ' ' WITH NO ADVANCING
           MOVE FUNCTION NUMVAL(CANT) TO WS-F-CANT
           DISPLAY WS-F-CANT
           DISPLAY X"0A"
           EXIT.
      *----------------------------------------------------------------*
      *
       END PROGRAM RDSQFILE.
