      ******************************************************************
      * Program: URSQFILE.cbl
      * Author:  Reinaldo Urquijo
      * Purpose: Updates a record in the sequential file.
      * Date:    20-Mar-2024
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. URSQFILE.
      *
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT INVENTARIO ASSIGN TO "INVENTARIO.DAT"
           ORGANIZATION IS SEQUENTIAL
           ACCESS MODE IS SEQUENTIAL
           FILE STATUS  IS QSAM0080-STATUS.
      *
           SELECT INVENTUPD ASSIGN TO "INVENTTEMP.DAT"
           ORGANIZATION IS SEQUENTIAL
           ACCESS MODE IS SEQUENTIAL
           FILE STATUS  IS QSAM0080-STATUS.

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
       FD INVENTUPD.
       01 UPD-INVENT-REG.
           02 UPD-CODART  PIC 9(5).
           02 UPD-DESCART PIC X(60).
           02 UPD-UNIDDS  PIC X(60).
           02 UPD-VRUNIT  PIC 9(12).
           02 UPD-CANT    PIC 9(12).

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
       01  WS-MISC.
           02 WS-MISC2             PIC 9.
      *    WS-CODART-NULL = 1 (CODART IS NULL FOR FIRST TIME)
           77 WS-CODART-NULL       PIC 9(1) VALUE 1.
      *    WS-FILE-EXISTS = 0 (FILE NOT EXISTS FOR FIRST TIME)
           77 WS-FILE-EXISTS       PIC 9(1) VALUE 0.
      *    WS-END-FILE = 0 (FILE NOT END FOR FIRST TIME)
           77 WS-END-FILE          PIC 9 VALUE 0.
      *    WS-COD-EXIST = 1 (COD EXISTS FOR FIRST TIME)
           77 WS-COD-EXIST         PIC 9(1) VALUE 1.
      *    RECORD INDEX
           77 WS-REC-IDX           PIC 9(7) VALUE 1.
      *    GETS AN OPTION FROM SCREEN
           77 WS-OPC               PIC X.
       PROCEDURE DIVISION.
      ******************************************************************
      *MAIN-PROCEDURE
      ******************************************************************
       MAIN-PROCEDURE.
           DISPLAY "Programa de inventario"
           DISPLAY "Actualizacion de datos"
           PERFORM 0100-VAL-FILE-EXISTS
           PERFORM 0200-GET-CODART
           PERFORM 0300-VAL-CODART-NULL
           PERFORM 0400-VAL-CODART-EXISTS
           PERFORM 0500-GETVAL-UPDATE
           PERFORM 0600-BUILD-UPDFILE
      *     DISPLAY "Archivo actualizado en INVENTTEMP.DAT."
      *     DISPLAY "¿Desea sobrescribir el archivo INVENTARIO.DAT?"
      *     DISPLAY "Advertencia: esta acción no se puede deshacer!"
      *     DISPLAY "(S/N):"WITH NO ADVANCING
      *     ACCEPT WS-OPC
      *     IF (WS-OPC = 'S') OR (WS-OPC = 's')
              PERFORM 0700-OVRWR-ORIG-FILE
              DISPLAY "Archivo INVENTARIO.DAT sobrescrito/actualizado"
      *     ELSE
      *        DISPLAY "Archivo INVENTARIO.DAT sobrescrito."
      *     END-IF
           DISPLAY "Presione cualquier tecla para terminar."
                   WITH NO ADVANCING
           ACCEPT WS-OPC
           STOP RUN.
      ******************************************************************
      *END MAIN-PROCEDURE
      ******************************************************************
      *
      ******************************************************************
      *END 0100-VAL-FILE-EXISTS
      ******************************************************************
       0100-VAL-FILE-EXISTS.
           OPEN INPUT INVENTARIO
      *    FILE NOT EXISTS
           IF (QSAM0080-STATUS = "35") THEN
              DISPLAY ".....Archivo no existe"
              SET WS-FILE-EXISTS TO 0
      *    FILE EXISTS
           ELSE
              DISPLAY ".....Archivo INVENTARIO.DAT existe"
              SET WS-FILE-EXISTS TO 1
           END-IF
           CLOSE INVENTARIO.
      *
      ******************************************************************
      *END 0100-VAL-FILE-EXISTS
      ******************************************************************
      *
      ******************************************************************
      *0200-GET-CODART
      *     GETS THE CODE OF THE ARTICLE FOR SEARCH
      ******************************************************************
       0200-GET-CODART.
           DISPLAY "Codigo de articulo VAL-CODART: " WITH NO ADVANCING
           ACCEPT WS-CODART.
      ******************************************************************
      *END 0200-GET-CODART
      ******************************************************************
      *
      ******************************************************************
      *0300-VAL-CODART-NULL
      *    VALIDATE IF CODE OF ARTICLE IS NULL
      ******************************************************************
       0300-VAL-CODART-NULL.
           PERFORM UNTIL WS-CODART-NULL = 0
              IF (WS-CODART = 0) OR (WS-CODART = LOW-VALUE) THEN
                 DISPLAY "Debe ingresar un codigo."
      *          WS-CODART-NULL = 1 (WS-CODART NULL OR 0)
                 SET WS-CODART-NULL TO 1
                 PERFORM 0200-GET-CODART
              ELSE
                 DISPLAY ".....CODART existe"
      *          WS-CODART-NULL = 0 (WS-CODART HAS VALUE)
                 SET WS-CODART-NULL TO 0
              END-IF
           END-PERFORM
      *    SETTING FOR NEXT VALIDATIONS
           SET WS-CODART-NULL TO 1.
      ******************************************************************
      *END 0300-VAL-CODART-NULL
      ******************************************************************
      *
      ******************************************************************
      *0400-VAL-CODART-EXISTS
      ******************************************************************
       0400-VAL-CODART-EXISTS.
      ***  WS-FILE-EXISTS=1 FILE NOT EXISTS FOR VALIDATE
           IF WS-FILE-EXISTS = 1 THEN
               OPEN INPUT INVENTARIO
               PERFORM UNTIL WS-END-FILE = 1
                  READ INVENTARIO
                  AT END
      ***            END OF FILE
                     SET WS-END-FILE TO 1
                        DISPLAY "Codigo no existe!"
      ***            CODART DOES NOT EXISTS
                     SET WS-COD-EXIST TO 0
                  NOT AT END
                     IF CODART = WS-CODART THEN
                        DISPLAY "Codigo        : "CODART
                        DISPLAY "Descripcion   : " DESCART
                        DISPLAY "Unidad medida : "UNIDDS
                        DISPLAY "Valor Unitario: "VRUNIT
                        DISPLAY "Cantidad      : "CANT
      ***               CODART EXISTS
                        SET WS-COD-EXIST TO 1
                        EXIT PERFORM
                     END-IF
               END-PERFORM
               CLOSE INVENTARIO
      ***      SETTING FOR NEXT VALIDATION
      ***      SET WS-END-FILE TO 0
           ELSE
              SET WS-COD-EXIST TO 0
           END-IF.
      ******************************************************************
      *END 0400-VAL-CODART-EXISTS
      ******************************************************************
      *
      ******************************************************************
      *0500-GETVAL-UPDATE
      ******************************************************************
       0500-GETVAL-UPDATE.
           DISPLAY "Ingrese los valores a actualizar para el codigo"
                   "de articulo "WS-CODART" en caso de no requerir"
                   "un cambio presione (Enter)"
           DISPLAY "Descripcion articulo: " WITH NO ADVANCING
           ACCEPT WS-DESCART
           DISPLAY "Unidad de medida    : " WITH NO ADVANCING
           ACCEPT WS-UNIDDS
           DISPLAY "Valor unitario      : " WITH NO ADVANCING
           ACCEPT WS-VRUNIT
           DISPLAY "Cantidad            : " WITH NO ADVANCING
           ACCEPT WS-CANT.
      ******************************************************************
      *END 0500-GETVAL-UPDATE
      ******************************************************************
      *
      ******************************************************************
      *0600-BUILD-UPDFILE
      ******************************************************************
       0600-BUILD-UPDFILE.
           SET WS-END-FILE TO 0
           OPEN INPUT INVENTARIO
           OPEN OUTPUT INVENTUPD
           PERFORM UNTIL WS-END-FILE = 1
              READ INVENTARIO
                 AT END
      *          END OF FILE
                    SET WS-END-FILE TO 1
                  NOT AT END
                     IF CODART = WS-CODART THEN
      *                 SET WS-END-FILE TO 1
      *                 EXIT PERFORM
                        move WS-CODART TO UPD-CODART
                        MOVE WS-DESCART TO UPD-DESCART
                        MOVE WS-UNIDDS TO UPD-UNIDDS
                        MOVE WS-VRUNIT TO UPD-VRUNIT
                        MOVE WS-CANT TO UPD-CANT
                        WRITE UPD-INVENT-REG
                     ELSE
                        MOVE CODART  TO UPD-CODART
                        MOVE DESCART TO UPD-DESCART
                        MOVE UNIDDS  TO UPD-UNIDDS
                        MOVE VRUNIT  TO UPD-VRUNIT
                        MOVE CANT    TO UPD-CANT
                        WRITE UPD-INVENT-REG
                     END-IF
           END-PERFORM
           CLOSE INVENTUPD
           CLOSE INVENTARIO.
      ******************************************************************
      *END 0600-BUILD-UPDFILE
      ******************************************************************
      *
      ******************************************************************
      *0700-OVRWR-ORIG-FILE
      ******************************************************************
       0700-OVRWR-ORIG-FILE.
           SET WS-END-FILE TO 0
           OPEN INPUT INVENTUPD
           OPEN OUTPUT INVENTARIO
           PERFORM UNTIL WS-END-FILE = 1
              READ INVENTUPD
                 AT END
      *             END OF FILE
                    SET WS-END-FILE TO 1
                 NOT AT END
                    MOVE UPD-CODART  TO CODART
                        MOVE UPD-DESCART TO DESCART
                        MOVE UPD-UNIDDS  TO UNIDDS
                        MOVE UPD-VRUNIT  TO VRUNIT
                        MOVE UPD-CANT    TO CANT
                        WRITE INVENT-REG
           END-PERFORM
           CLOSE INVENTARIO
           CLOSE INVENTUPD.
      ******************************************************************
      *END 0700-OVRWR-ORIG-FILE
      ******************************************************************
      *
       END PROGRAM URSQFILE.
