      ******************************************************************
      * Program: CRSQCSV.cbl
      * Purpose: Reads data in sequential file
      *          and creates another file with csv format
      * Date:    20-Mar-2024
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CRSQCSV.
      *
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
       SELECT INVENTARIO ASSIGN TO "INVENTARIO.DAT"
       ORGANIZATION IS LINE SEQUENTIAL.
       SELECT OUT-INFORME ASSIGN TO "INFORME.csv"
       ORGANIZATION IS LINE SEQUENTIAL.

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
       FD OUT-INFORME.
       01 OUTPUT-RECORD PIC X(200).
      * 01 OUTPUT-RECORD PIC X(80).
      * 01 OI-SEPARATOR PIC X.
      * 01 OIH-TIT.
      *     02 OIH-TITLE PIC X(17).

      * 01 OIH-SUBTIT.
      *     02 OIH-SUBTITLE PIC X(21).
      * 01 OI-SEP.
      *     02 OI-SEPARATOR PIC X VALUE ';'.
      * 01 OI-REG.
      *     02 OIR-CODART  PIC 9(5).
      *     02 OIR-DESCART PIC X(60).
      *     02 OIR-UNIDDS  PIC X(60).
      *     02 OIR-VRUNIT  PIC 9(12).
      *     02 OIR-CANT    PIC 9(12).
      *
       WORKING-STORAGE SECTION.
       01 WS-DATETIME              PIC X(21).
       01 WS-DATEFTD               PIC X(200).
       01 WS-YEAR                  PIC  9(4).
       01 WS-DAY                   PIC  9(2).

       01 WS-EVALMNTH              PIC 9(2).
       01 WS-MNTH                  PIC X(10).

      *    HEADER OF REPORT
           77 HEAD-TITLE PIC X(17)     VALUE 'EMPRESA DE PRUEBA'.
           77 HEAD-SUBTITLE PIC X(21)  VALUE 'INFORME DE INVENTARIO'.
           77 HEAD-COLS pic x(200).
           77 WS-CONN PIC X(2) VALUE 'de'.
           77 WS-SPACE PIC X(1) VALUE ' '.
           77 WS-DATE PIC X(6) VALUE 'Fecha:'.
           77 WS-BY PIC X(24) VALUE ';;;Por: Reinaldo Urquijo'.
           77 NEWLINE PIC X VALUE X'0A'.
           77 NEWLINE2 PIC X VALUE X'0D'.
           77 NULLABLE PIC X VALUE SPACE.
           77 SPACEZ PIC X.
           77 SPACEZ2 PIC X(200) VALUE SPACES.


           77 SEPARATOR PIC X VALUE ';'.

           77 FIN-FICHERO PIC 9 VALUE 0.
           77 WS-KEY PIC X.
       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           DISPLAY "Programa de inventario"
           DISPLAY "Generacion informe archivo csv"
           PERFORM GET-CURR-DATETIME
           PERFORM ESCRIBIR-ENCABEZADO
           PERFORM LEER-INVENT
           DISPLAY "Presione cualquier tecla para salir. ".
           ACCEPT WS-KEY
            STOP RUN.


       GET-CURR-DATETIME.
           MOVE FUNCTION CURRENT-DATE TO WS-DATETIME
           MOVE WS-DATETIME(1:4)  TO WS-YEAR.
           MOVE WS-DATETIME(5:2)  TO WS-EVALMNTH.
           MOVE WS-DATETIME(7:2)  TO WS-DAY.
           EVALUATE WS-EVALMNTH
              WHEN 01
              MOVE 'enero' TO WS-MNTH
              WHEN 02
              MOVE 'febrero' TO WS-MNTH
              WHEN 03
              MOVE 'marzo' TO WS-MNTH
              WHEN 04
              MOVE 'abril' TO WS-MNTH
              WHEN 05
              MOVE 'abril' TO WS-MNTH
              WHEN 06
              MOVE 'junio' TO WS-MNTH
              WHEN 07
              MOVE 'julio' TO WS-MNTH
              WHEN 08
              MOVE 'agosto' TO WS-MNTH
              WHEN 09
              MOVE 'septiembre' TO WS-MNTH
              WHEN 10
              MOVE 'octubre' TO WS-MNTH
              WHEN 11
              MOVE 'noviembre' TO WS-MNTH
              WHEN 12
              MOVE 'diciembre' TO WS-MNTH
           END-EVALUATE
           move function TRIM(WS-MNTH,TRAILING) TO WS-MNTH
      *    20 de marzo de 2024
           STRING WS-DATE
                  WS-SPACE
                  WS-DAY
                  WS-SPACE
                  WS-CONN
                  WS-SPACE
                  FUNCTION TRIM(WS-MNTH,TRAILING)
                  WS-SPACE
                  WS-CONN
                  WS-SPACE
                  WS-YEAR
                  WS-BY
           INTO WS-DATEFTD
           EXIT.
      * Reads from file
       LEER-INVENT.
      *     Open as input for read.
            OPEN INPUT INVENTARIO
      *    Perform and reads record by record until flag sets to 1.
            PERFORM UNTIL FIN-FICHERO = 1
                READ INVENTARIO
                   AT END
      *                MOVE 1 TO FIN-FICHERO
                      SET FIN-FICHERO TO 1
                   NOT AT END
                   DISPLAY "."
      *                MOVE INVENT-REG TO OI-REG
                      PERFORM LEER-REGISTRO
                END-READ
            END-PERFORM
           CLOSE INVENTARIO.
      * Display record on screen
       ESCRIBIR-ENCABEZADO.
      *     MOVE 'EMPRESA DE PRUEBA' TO OIH-TITLE
      *     MOVE 'INFORME DE INVENTARIO' TO OIH-SUBTITLE
      *     MOVE ';' TO OI-SEPARATOR
           OPEN OUTPUT OUT-INFORME

           STRING SPACEZ
           INTO OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           STRING ';;'HEAD-TITLE
           INTO OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           STRING ';;'HEAD-SUBTITLE
           INTO OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           STRING WS-DATEFTD DELIMITED BY SIZE
           INTO OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           STRING SPACEZ2
           INTO OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           STRING 'CODIGO;'
                  'DESCRIPCION;'
                  'UNIDAD DE MEDIDA;'
                  'VALOR UNITARIO;'
                  'CANTIDAD'
           INTO OUTPUT-RECORD
           WRITE OUTPUT-RECORD

      *     WRITE OIH-TIT
      *     WRITE OI-SEPARATOR
      *     WRITE OI-SEPARATOR
      *     WRITE OUTPUT-RECORD FROM SPACES
      *     WRITE OIH-SUBTIT
      *     WRITE OI-SEPARATOR
           CLOSE OUT-INFORME.
       LEER-REGISTRO.
      *     display OIR-CODART
           OPEN EXTEND OUT-INFORME
      *     WRITE OIR-CODART
      *     WRITE OI-SEP
      *     WRITE OIR-DESCART
      *     WRITE OI-SEP
      *     WRITE OIR-UNIDDS
      *     WRITE OI-SEP
      *     WRITE OIR-VRUNIT
      *     WRITE OI-SEP
      *     WRITE OIR-CANT
      *     WRITE OI-SEP
           STRING
              CODART';'
              DESCART';'
              UNIDDS';'
              VRUNIT';'
              CANT
           INTO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           CLOSE OUT-INFORME.
      *
       END PROGRAM CRSQCSV.
