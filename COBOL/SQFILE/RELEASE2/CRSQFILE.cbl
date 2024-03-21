      ******************************************************************
      * Program: CRSQFILE.cbl
      * Author:  Reinaldo Urquijo
      * Purpose: creates sequential file and writes data in it
      * Date:    20-Mar-2024
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CRSQFILE.
      ******************************************************************
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
       SELECT INVENTARIO ASSIGN TO "INVENTARIO.DAT"
       ORGANIZATION IS LINE SEQUENTIAL
       ACCESS MODE  IS SEQUENTIAL
       FILE STATUS  IS QSAM0080-STATUS.
      ******************************************************************
       DATA DIVISION.
       FILE SECTION.
       FD INVENTARIO.
       01 INVENT-REG.
           02 CODART               PIC 9(5).
           02 DESCART              PIC X(60).
           02 UNIDDS               PIC X(60).
           02 VRUNIT               PIC 9(12).
           02 CANT                 PIC 9(12).
      *
       WORKING-STORAGE SECTION.
       01  QSAM0080-STATUS.
           05  QSAM0080-STAT1      PIC X.
           05  QSAM0080-STAT2      PIC X.
      *
       01  WS-INVENT-REG.
           02 WS-CODART            PIC 9(5).
           02 WS-DESCART           PIC X(60).
           02 WS-UNIDDS            PIC X(60).
           02 WS-VRUNIT            PIC 9(12).
           02 WS-CANT              PIC 9(12).
      *    FLAG VALIDATIONS
      *    WS-FILE-EXISTS = 0 (FILE NOT EXISTS FOR FIRST TIME)
           77 WS-FILE-EXISTS     PIC 9(1) VALUE 0.
      *    WS-CODART-NULL = 1 (CODART IS NULL FOR FIRST TIME)
           77 WS-CODART-NULL     PIC 9(1) VALUE 1.
      *    WS-DESCART-NULL = 1 (DESCART IS NULL FOR FIRST TIME)
           77 WS-DESCART-NULL     PIC 9(1) VALUE 1.
      *    WS-END-FILE = 0 (FILE NOT END FOR FIRST TIME)
           77 WS-END-FILE        PIC 9 VALUE 0.
      *    WS-COD-EXIST = 1 (COD EXISTS FOR FIRST TIME)
           77 WS-COD-EXIST    PIC 9(1) VALUE 1.
           77 WS-OPC             PIC X.
      *
      ******************************************************************
       PROCEDURE DIVISION.
      ******************************************************************
      *MAIN-PARAGRAPH
      ******************************************************************
       MAIN.
           DISPLAY "Programa de inventario"
           DISPLAY "Ingreso de registros"
           PERFORM UNTIL WS-OPC = 'N'
      *    FIRST, VALIDATE IF FILE EXISTS OR NOT
              PERFORM 0100-VAL-FILE-EXISTS
              PERFORM UNTIL WS-COD-EXIST = 0
      *    GET CODART.
                 PERFORM 0200-GET-CODART
      *    VALIDATE IF CODART IS NULL
                 PERFORM 0300-VAL-CODART-NULL
      *    VALIDATE COD-ART IF EXISTS IN FILE OR IS NEW
                 PERFORM 0400-VAL-CODART-EXISTS
              END-PERFORM
              PERFORM 0500-GET-DESCART-VAL-NULL
              PERFORM 0600-GET-OTHER-VALUES
      *    WRITE WS RECORD TO FILE
              PERFORM 0700-WRITE-RECORD
              DISPLAY "¿Desea ingresar otro registro (S/N)? "
                  WITH NO ADVANCING
              ACCEPT WS-OPC
              IF (WS-OPC = 'S') OR (WS-OPC = 's')
                 MOVE 'S' TO WS-OPC
                 SET WS-FILE-EXISTS TO 0
                 SET WS-CODART-NULL TO 1
                 SET WS-DESCART-NULL TO 1
                 SET WS-END-FILE TO 0
                 SET WS-COD-EXIST TO 1
              ELSE
                 MOVE 'N' TO WS-OPC
              END-IF
           END-PERFORM
           STOP RUN.
      *----------------------------------------------------------------*
      *
      ******************************************************************
      *0100-VAL-FILE-EXISTS
      ******************************************************************
       0100-VAL-FILE-EXISTS.
           OPEN INPUT INVENTARIO
      *    FILE NOT EXISTS
           IF (QSAM0080-STATUS = "35") THEN
              SET WS-FILE-EXISTS TO 0
      *    FILE EXISTS
           ELSE
              SET WS-FILE-EXISTS TO 1
           END-IF
           CLOSE INVENTARIO
           EXIT.
      *----------------------------------------------------------------*
      ******************************************************************
      *0200-GET-CODART
      ******************************************************************
       0200-GET-CODART.
           DISPLAY "Codigo de articulo VAL-CODART: " WITH NO ADVANCING
           ACCEPT WS-CODART
           EXIT.
      *----------------------------------------------------------------*
      *
      ******************************************************************
      *0300-VAL-CODART-NULL
      ******************************************************************
       0300-VAL-CODART-NULL.
           PERFORM UNTIL WS-CODART-NULL = 0
              IF (WS-CODART = 0) OR (WS-CODART = LOW-VALUE) THEN
                 DISPLAY "Debe ingresar un codigo."
      *          WS-CODART-NULL = 1 (WS-CODART NULL OR 0)
                 SET WS-CODART-NULL TO 1
                 PERFORM 0200-GET-CODART
              ELSE
      *          WS-CODART-NULL = 0 (WS-CODART HAS VALUE)
                 SET WS-CODART-NULL TO 0
              END-IF
           END-PERFORM
      *    SETTING FOR NEXT VALIDATIONS
           SET WS-CODART-NULL TO 1
           EXIT.
      *----------------------------------------------------------------*
      *
      ******************************************************************
      *0400-VAL-CODART-EXISTS
      ******************************************************************
       0400-VAL-CODART-EXISTS.

      *    WS-FILE-EXISTS=1 FILE EXISTS FOR VALIDATE
           IF WS-FILE-EXISTS = 1 THEN
               OPEN INPUT INVENTARIO
               PERFORM UNTIL WS-END-FILE = 1
                  READ INVENTARIO
                  AT END
      *              END OF FILE
                     SET WS-END-FILE TO 1
      *              CODART DOES NOT EXISTS
                     SET WS-COD-EXIST TO 0
                  NOT AT END
                     IF CODART = WS-CODART THEN
                        DISPLAY "Codigo ya existente!"
      *                 CODART EXISTS
                        SET WS-COD-EXIST TO 1
                        EXIT PERFORM
                     END-IF
               END-PERFORM
               CLOSE INVENTARIO
      *        SETTING FOR NEXT VALIDATION
      *         SET WS-END-FILE TO 0
           ELSE
              SET WS-COD-EXIST TO 0
           END-IF
           EXIT.
      *----------------------------------------------------------------*
      *
      ******************************************************************
      *0500-GET-DESCART-VAL-NULL
      ******************************************************************
       0500-GET-DESCART-VAL-NULL.
           PERFORM UNTIL WS-DESCART-NULL = 0
              DISPLAY "Descripcion: " WITH NO ADVANCING
              ACCEPT WS-DESCART
              IF (WS-DESCART = SPACE) OR (WS-DESCART = LOW-VALUE) THEN
                 DISPLAY "Debe ingresar una descripcion de articulo."
      *          WS-CODART-NULL = 1 (WS-CODART NULL OR 0)
                 SET WS-DESCART-NULL TO 1
              ELSE
      *          WS-CODART-NULL = 0 (WS-CODART HAS VALUE)
                 SET WS-DESCART-NULL TO 0
              END-IF
           END-PERFORM
      *    SETTING FOR NEXT VALIDATIONS
           SET WS-DESCART-NULL TO 1
           EXIT.
      *----------------------------------------------------------------*
      *
      *
      ******************************************************************
      *0600-GET-OTHER-VALUES
      ******************************************************************
       0600-GET-OTHER-VALUES.
           DISPLAY "Unid. Medida: " WITH NO ADVANCING
           ACCEPT WS-UNIDDS
           DISPLAY "Vr. Unitario: " WITH NO ADVANCING
           ACCEPT WS-VRUNIT
           DISPLAY "Cantidad    : " WITH NO ADVANCING
           ACCEPT WS-CANT
           EXIT.
      *----------------------------------------------------------------*
      *
      ******************************************************************
      *0700-WRITE-RECORD
      ******************************************************************
       0700-WRITE-RECORD.
      *    WS-FILE-EXISTS=1 FILE EXISTS FOR VALIDATE
           IF WS-FILE-EXISTS = 1 THEN
              OPEN EXTEND INVENTARIO
           ELSE
              OPEN OUTPUT INVENTARIO
           END-IF
           MOVE WS-INVENT-REG TO INVENT-REG
           WRITE INVENT-REG
           SET WS-FILE-EXISTS TO 1
           DISPLAY "Registro insertado."
           CLOSE INVENTARIO.
           EXIT.
      *----------------------------------------------------------------*
      *
       END PROGRAM CRSQFILE.
