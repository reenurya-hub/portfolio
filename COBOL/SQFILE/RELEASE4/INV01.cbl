      ******************************************************************
      * Program      : INV01.cbl                                       *
      * Purpose      : Invent main program                             *
      * Date         : 04-apr-2024                                     *
      * Author       : Reinaldo Urquijo                                *
      ******************************************************************
      *    Changes                                                     *
      ******************************************************************
      *    Date        Author          Description                     *
      *----------------------------------------------------------------*
      * 04-apr-2024    R. Urquijo      Creation of program.            *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. INV01.
      *-----------------------------------------------------------------
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
       copy "FILE.cpy".
      *
      *-----------------------------------------------------------------
       DATA DIVISION.
      *-----------------------------------------------------------------
       FILE SECTION.
       copy "FILED.cpy".
      *
       WORKING-STORAGE SECTION.
       copy "WKST.cpy".
      *
      *-----------------------------------------------------------------
       PROCEDURE DIVISION.
      *-----------------------------------------------------------------
      *    0000-MAIN : Main paragraph of the program.
      *-----------------------------------------------------------------
       0000-MAIN.
           CALL 'SYSTEM' USING 'CLS'
           PERFORM 0100-DISP-FEATURE
      * ACCEPT WS-OPTN LINE 23 COL 78 PROMPT
           PERFORM UNTIL (WS-OPTN = 9)
                      OR (WS-OPTN = 0)
              ACCEPT WS-OPTN LINE 23 COL 78 PROMPT
              PERFORM 0100-CLEAR-TXT
              EVALUATE WS-OPTN
      * CREATE FILE
                 WHEN 1
                    DISPLAY WS-ST-CRFL LINE 04 COL 10
                    PERFORM 0100-CREATE-FILE
                    PERFORM 0100-AFT-FUNCT-PARA
      * LIST RECORDS FROM FILE
                 WHEN 2
                    DISPLAY WS-ST-INRC LINE 04 COL 10
                    PERFORM 0100-INS-REC-SEQFILE
                    PERFORM 0100-AFT-FUNCT-PARA
      * INSERT RECORD IN FILE
                 WHEN 3
                    DISPLAY WS-ST-SLRC LINE 04 COL 10
                    PERFORM 0100-CLEAR-TXT
                    PERFORM 0100-LIST-RECS
                    PERFORM 0100-AFT-FUNCT-PARA
      * UPDATE RECORD FROM FILE
                 WHEN 4
                    DISPLAY WS-ST-UPRC LINE 04 COL 10
                    PERFORM 0100-CLEAR-TXT
                    PERFORM 0100-UPD-RECORD
                    PERFORM 0100-AFT-FUNCT-PARA
      * DELETE RECORD FROM FILE
                 WHEN 5
                    DISPLAY WS-ST-DLRC LINE 04 COL 10
                    PERFORM 0100-CLEAR-TXT
                    PERFORM 0100-DEL-REC-FILE
                    PERFORM 0100-AFT-FUNCT-PARA
      * GENERATE REPORT FROM FILE
                 WHEN 6
                    DISPLAY WS-ST-RPRC LINE 04 COL 10
                    PERFORM 0100-CLEAR-TXT
                    PERFORM 0100-CRT-CSV
                    PERFORM 0100-AFT-FUNCT-PARA
      * DISPLAY HELP
                 WHEN 7
                    DISPLAY WS-ST-HLGN LINE 04 COL 10
                    PERFORM 0100-DISP-HELP
                    PERFORM 0100-AFT-FUNCT-PARA
      * RETURN TO MAIN
                 WHEN 8
                    PERFORM 0100-CLEAR-TXT
                    DISPLAY WS-ST-PRPL LINE 04 COL 10
                 WHEN 9
                    SET WS-OPTN TO 9
                    DISPLAY WS-MSG-EXT LINE 24 COL 01
                    ACCEPT WS-OPTX
                 WHEN 0
                    SET WS-OPTN TO 9
                    DISPLAY WS-MSG-EXT LINE 24 COL 01
                    ACCEPT WS-OPTX LINE 24 COL 78 PROMPT
      * EXIT PROGRAM
                 WHEN OTHER
                    SET WS-OPTN TO 9
                    DISPLAY WS-MSG-EXT LINE 24 COL 01
                    ACCEPT WS-OPTX
                 END-EVALUATE
           END-PERFORM
           STOP RUN.
      *
      *-----------------------------------------------------------------
      *    0100-DISP-FEATURE : Displays main presentation of screen.
      *-----------------------------------------------------------------
       0100-DISP-FEATURE.
           PERFORM 0100-GET-CURR-DATE
           DISPLAY WS-BLANK     LINE 01 COL 01 ERASE EOS
              WS-HEAD1          LINE 02 COL 01
              WS-HEAD2          LINE 03 COL 01
              WS-ST-PPL         LINE 04 COL 01
              WS-ST-PRPL        LINE 04 COL 10
              WS-DATEFTD        LINE 04 COL 50
              WS-HYPHNS         LINE 05 COL 01
              WS-HYPHNS         LINE 22 COL 01
              WS-OPTS1          LINE 23 COL 01
           EXIT.
      *
      *-----------------------------------------------------------------
      *    0100-CLEAR-TXT : Clear the text of the screen
      *-----------------------------------------------------------------
       0100-CLEAR-TXT.
           DISPLAY WS-SPC LINE 06 COL 01
              WS-SPC LINE 07 COL 01
              WS-SPC LINE 08 COL 01
              WS-SPC LINE 09 COL 01
              WS-SPC LINE 10 COL 01
              WS-SPC LINE 11 COL 01
              WS-SPC LINE 12 COL 01
              WS-SPC LINE 13 COL 01
              WS-SPC LINE 14 COL 01
              WS-SPC LINE 15 COL 01
              WS-SPC LINE 16 COL 01
              WS-SPC LINE 17 COL 01
              WS-SPC LINE 18 COL 01
              WS-SPC LINE 19 COL 01
              WS-SPC LINE 20 COL 01
              WS-SPC LINE 21 COL 01
              WS-SPC LINE 24 COL 01
           EXIT.
      *
      *-----------------------------------------------------------------
      *    0100-AFT-FUNCT-PARA : Process after a functionality is exec.
      *-----------------------------------------------------------------
       0100-AFT-FUNCT-PARA.
           DISPLAY WS-MSG-AN1 LINE 24 COL 01
           ACCEPT  WS-OPTX LINE 23 COL 78 PROMPT
           PERFORM 0100-CLEAR-TXT
           DISPLAY WS-ST-PRPL LINE 04 COL 10
           EXIT.
      *
      *-----------------------------------------------------------------
      *    0100-DISP-TIT-DATA : Display the titles of the fields.
      *-----------------------------------------------------------------
       0100-DISP-TIT-DATA.
           DISPLAY
              WS-LB-DT1 LINE 06 COL 01
              WS-HYPHNS LINE 07 COL 01
              WS-SPACES LINE 08 COL 01
              WS-BAR    LINE 08 COL 01
              WS-BAR    LINE 08 COL 07
              WS-BAR    LINE 08 COL 44
              WS-BAR    LINE 08 COL 60
              WS-BAR    LINE 08 COL 70
              WS-BAR    LINE 08 COL 80
              WS-HYPHNS LINE 09 COL 01
           EXIT.
      *
      *-----------------------------------------------------------------
      *    0100-DISP-REC-FILE : Displays field to field of seq. file.
      *-----------------------------------------------------------------
       0100-DISP-REC-FILE.
           DISPLAY CODART   LINE WS-ROWCTRL COL 02
           DISPLAY WS-BLANK LINE WS-ROWCTRL COL 07
           DISPLAY DESCART  LINE WS-ROWCTRL COL 08
           DISPLAY WS-BLANK LINE WS-ROWCTRL COL 44
           DISPLAY UNIDDS   LINE WS-ROWCTRL COL 45
           DISPLAY WS-BLANK LINE WS-ROWCTRL COL 60
           DISPLAY VRUNIT   LINE WS-ROWCTRL COL 61
           DISPLAY WS-BLANK LINE WS-ROWCTRL COL 70
           DISPLAY CANT    LINE WS-ROWCTRL COL 71
           ADD 1 TO WS-ROWCTRL
           EXIT.
      *
      *-----------------------------------------------------------------
      *    0100-VAL-FILE-EXIST-RECS : Validates if seq. file exists.
      *-----------------------------------------------------------------
       0100-VAL-FILE-EXIST-RECS.
           OPEN INPUT INVENTARIO
           IF (WS-FILE-STATUS = '35') THEN
              SET WS-FILE-EXTS TO 0
           ELSE
              SET WS-FILE-EXTS TO 1
           END-IF
           READ INVENTARIO
           IF (WS-FILE-STATUS = '10') THEN
              SET WS-FILE-RECS TO 0
           ELSE
              SET WS-FILE-RECS TO 1
           END-IF
           CLOSE INVENTARIO
           EXIT.
      *
      *-----------------------------------------------------------------
      *    0100-CREATE-FILE : Creates sequential file.
      *-----------------------------------------------------------------
       0100-CREATE-FILE.
           PERFORM 0100-VAL-FILE-EXIST-RECS
           IF WS-FILE-EXTS = 0 THEN
              OPEN OUTPUT INVENTARIO
              CLOSE INVENTARIO
              DISPLAY WS-MSG-FLCR LINE 07 COL 01
              SET WS-FILE-EXTS TO 1
           ELSE
              DISPLAY WS-MSG-FLEX LINE 07 COL 01
            END-IF
           EXIT.
      *
      *-----------------------------------------------------------------
      *    0100-INS-REC-SEQFILE : insert new record in seq. file.
      *-----------------------------------------------------------------
       0100-INS-REC-SEQFILE.
           PERFORM 0100-VAL-FILE-EXIST-RECS
           IF WS-FILE-EXTS = 0 THEN
              DISPLAY WS-MSG-FLOB LINE 24 COL 01
           ELSE
              PERFORM 0100-DISP-TIT-DATA
              SET WS-OPTNM TO 1
              PERFORM UNTIL WS-OPTNM = 0
                 PERFORM UNTIL WS-COD-EXIST = 0
                    MOVE 8 TO WS-ROWCTRL
                    MOVE 2 TO WS-COLCTRL
                    PERFORM 0100-VAL-CODART-NULL
                    PERFORM 0100-VAL-CODART-EXISTS
                 END-PERFORM
                 PERFORM 0100-GET-OTHER-DATA
                 PERFORM 0100-SAVE-RECORD
                 DISPLAY WS-MSG-OTRC LINE 21 COL 01
                 ACCEPT WS-OPTX LINE 21 COL 78 PROMPT
                 IF WS-OPTX = 's' OR WS-OPTX = 'S' THEN
                    SET WS-OPTNM TO 1
                    PERFORM 0100-RST-VAL-INS-REC
                 ELSE
                    SET WS-DCA-NULL TO 0
                    SET WS-COD-EXIST TO 1
                    SET WS-END-FILE TO 0
                    SET WS-OPTNM TO 0
                 END-IF
              END-PERFORM
           END-IF
           EXIT.
      *
      *-----------------------------------------------------------------
      *    0100-VAL-CODART-NULL : Validates if code is null.
      *-----------------------------------------------------------------
       0100-VAL-CODART-NULL.
           ACCEPT WS-CODART LINE WS-ROWCTRL COL WS-COLCTRL
           MOVE WS-CODART TO WS-V-CODART
           PERFORM UNTIL WS-DCA-NULL = 1
              IF WS-V-CODART-ZRO
              OR WS-V-CODART = LOW-VALUE THEN
                 DISPLAY WS-MSG-DTOB LINE 24 COL 01
                 ACCEPT WS-OPTX LINE 24 COL 79 PROMPT
                 DISPLAY WS-SPC LINE 24 COL 01
                 SET WS-DCA-NULL TO 0
                 ACCEPT WS-CODART LINE WS-ROWCTRL COL WS-COLCTRL
                 MOVE WS-CODART TO WS-V-CODART
              ELSE
                 SET WS-END-FILE TO 0
                 SET WS-DCA-NULL TO 1
                 MOVE WS-CODART  TO WS-D-WSCODART
                 EXIT PERFORM
              END-IF
           END-PERFORM
           EXIT.
      *
      *-----------------------------------------------------------------
      *    0100-VAL-CODART-EXISTS : Validates if code exists.
      *-----------------------------------------------------------------
       0100-VAL-CODART-EXISTS.
           IF WS-FILE-RECS = 1 THEN
               OPEN INPUT INVENTARIO
               SET WS-COD-EXIST TO 0
               SET WS-END-FILE TO 0
               PERFORM UNTIL WS-END-FILE = 1
                  READ INVENTARIO
                      AT END
                         SET WS-END-FILE TO 1
                         SET WS-COD-EXIST TO 0
                         EXIT PERFORM
                      NOT AT END
                         IF CODART = WS-CODART THEN
                            DISPLAY WS-MSG-CDXT LINE 24 COL 01
                            MOVE CODART  TO WS-UPD-WSCODART
                            MOVE DESCART TO WS-UPD-DESCART
                            MOVE UNIDDS  TO WS-UPD-UNIDDS
                            MOVE VRUNIT  TO WS-UPD-VRUNIT
                            MOVE CANT    TO WS-UPD-CANT
                            SET WS-COD-EXIST TO 1
                            SET WS-END-FILE TO 1
                            SET WS-DCA-NULL TO 0
                         END-IF
               END-PERFORM
               CLOSE INVENTARIO
               IF WS-OPTN = 4 AND WS-COD-EXIST EQUAL 0 THEN
                  DISPLAY WS-MSG-NRC3 LINE 24 COL 01
                  ACCEPT WS-OPTX LINE 23 COL 79
               END-IF
           ELSE
              IF WS-OPTN = 3 THEN
                 SET WS-COD-EXIST TO 0
                 DISPLAY WS-MSG-NRC1 LINE 24 COL 01
                 ACCEPT WS-OPTX LINE 23 COL 79
              ELSE
                 SET WS-COD-EXIST TO 0
                 DISPLAY WS-MSG-NRC2 LINE 24 COL 01
                 ACCEPT WS-OPTX LINE 23 COL 79
              END-IF
           END-IF
           EXIT.
      *
      *-----------------------------------------------------------------
      *    0100-GET-OTHER-DATA : Gets the other data for insert.
      *-----------------------------------------------------------------
       0100-GET-OTHER-DATA.
           ACCEPT WS-DESCART   LINE 08 COL 08
           MOVE WS-DESCART TO WS-V-DESCART
           PERFORM UNTIL NOT WS-V-DESCART-BNK
                          OR WS-V-DESCART = LOW-VALUE
              DISPLAY WS-MSG-NONL LINE 24 COL 01
              ACCEPT WS-DESCART LINE 08 COL 08
              MOVE WS-DESCART TO WS-V-DESCART
           END-PERFORM
      *
           ACCEPT WS-UNIDDS    LINE 08 COL 45
           PERFORM UNTIL NOT WS-UNIDDS-BNK
                          OR WS-UNIDDS = LOW-VALUE
              MOVE WS-UND-GRL TO WS-UNIDDS
           END-PERFORM
      *
           ACCEPT WS-VRUNIT  LINE 08 COL 61
           MOVE WS-VRUNIT TO WS-V-VRUNIT
           PERFORM UNTIL NOT WS-V-VRUNIT-ZRO
                          OR WS-V-VRUNIT = LOW-VALUE
              DISPLAY WS-MSG-NONL LINE 24 COL 01
              ACCEPT WS-VRUNIT LINE 08 COL 61
              MOVE WS-VRUNIT TO WS-V-VRUNIT
           END-PERFORM
      *
           ACCEPT WS-CANT    LINE 08 COL 71
           MOVE WS-CANT TO WS-V-CANT
           PERFORM UNTIL NOT WS-V-CANT-ZRO
                          OR WS-V-CANT = LOW-VALUE
              DISPLAY WS-MSG-NONL LINE 24 COL 01
              ACCEPT WS-CANT   LINE 08 COL 71 PROMPT
              MOVE WS-CANT TO WS-V-CANT
           END-PERFORM
           EXIT.
      *
      *-----------------------------------------------------------------
      *    0100-SAVE-RECORD : Saves the record in the sequential file.
      *-----------------------------------------------------------------
       0100-SAVE-RECORD.
           MOVE WS-CODART  TO WS-D-WSCODART
           MOVE WS-DESCART TO WS-D-DESCART
           MOVE WS-UNIDDS  TO WS-D-UNIDDS
           MOVE WS-VRUNIT  TO WS-D-VRUNIT
           MOVE WS-CANT    TO WS-D-CANT
           MOVE WS-D-INVENT-REG TO INVENT-REG
           IF WS-FILE-RECS = 0 THEN
              OPEN OUTPUT INVENTARIO
           ELSE
              OPEN EXTEND INVENTARIO
           END-IF
           WRITE INVENT-REG
           CLOSE INVENTARIO
           DISPLAY WS-MSG-RCOK LINE 24 COL 01
           EXIT.
      *
      *-----------------------------------------------------------------
      *    0100-LIST-RECS : List records of sequential file.
      *-----------------------------------------------------------------
       0100-LIST-RECS.
           DISPLAY
              WS-LB-DT1 LINE 06 COL 01
              WS-HYPHNS LINE 07 COL 01
           PERFORM 0100-VAL-FILE-EXIST-RECS
           IF WS-FILE-EXTS = 0 THEN
              DISPLAY WS-MSG-FLOB LINE 24 COL 01
           ELSE
              IF WS-FILE-RECS = 1 THEN
                 SET WS-END-FILE TO 0
                 MOVE 8 TO WS-ROWCTRL
                 OPEN INPUT INVENTARIO
                 PERFORM UNTIL WS-END-FILE = 1
                    READ INVENTARIO
                       AT END
                          SET WS-END-FILE TO 1
                       NOT AT END
                          PERFORM 0100-DISP-REC-FILE
                    END-READ
                 END-PERFORM
                 CLOSE INVENTARIO
                 MOVE 8 TO WS-ROWCTRL
              ELSE
                 DISPLAY WS-MSG-NORC LINE 10 COL 01
              END-IF
           END-IF
           EXIT.
      *
      *-----------------------------------------------------------------
      *    0100-DISP-TIT-DAT-MOD : Display titles of data to modify
      *-----------------------------------------------------------------
       0100-DISP-TIT-DAT-MOD.
           IF WS-OPTN = 4 THEN
              DISPLAY WS-LB-DT2   LINE 06 COL 01
           ELSE
              DISPLAY WS-LB-DT3   LINE 06 COL 01
           END-IF
      *
           DISPLAY
              WS-HYPHNS   LINE 07 COL 01
              WS-DDT-CA   LINE 08 COL 01
              WS-DDT-DA   LINE 09 COL 01
              WS-DDT-UA   LINE 10 COL 01
              WS-DDT-VA   LINE 11 COL 01
              WS-DDT-QA   LINE 12 COL 01
           EXIT.
      *
      *-----------------------------------------------------------------
      *    0100-DISP-TIT-DAT-MOD : Display data of record to modify
      *-----------------------------------------------------------------
       0100-DISP-DAT-REC-MOD.
           DISPLAY
              WS-BAR          LINE 08 COL 44
              WS-UPD-DESCART  LINE 09 COL 09
              WS-BAR          LINE 09 COL 44
              WS-UPD-UNIDDS   LINE 10 COL 09
              WS-BAR          LINE 10 COL 44
              WS-UPD-VRUNIT   LINE 11 COL 09
              WS-BAR          LINE 11 COL 44
              WS-UPD-CANT     LINE 12 COL 09
              WS-BAR          LINE 12 COL 44
           IF WS-OPTN = 4 THEN
              DISPLAY WS-CODART   LINE 08 COL 45
           END-IF

           EXIT.
      *
      *-----------------------------------------------------------------
      *    0100-UPD-RECORD : Updates record
      *-----------------------------------------------------------------
       0100-UPD-RECORD.
           PERFORM 0100-RST-VAL-INS-REC
           PERFORM 0100-VAL-FILE-EXIST-RECS
           IF WS-FILE-EXTS = 0 THEN
              DISPLAY WS-MSG-FLOB LINE 24 COL 01
           ELSE
              PERFORM 0100-DISP-TIT-DAT-MOD
              DISPLAY WS-MSG-INUP LINE 21 COL 01
              SET WS-COD-EXIST TO 0
              PERFORM UNTIL WS-COD-EXIST = 1
                 MOVE 8 TO WS-ROWCTRL
                 MOVE 9 TO WS-COLCTRL
                 PERFORM 0100-VAL-CODART-NULL
                 PERFORM 0100-VAL-CODART-EXISTS
              END-PERFORM
              PERFORM 0100-DISP-DAT-REC-MOD
              PERFORM 0100-GET-DATA-UPD
              DISPLAY WS-MSG-CFMD LINE 21 COL 01
              ACCEPT WS-OPTX LINE 21 COL 78 PROMPT
              IF WS-OPTX = 's' OR WS-OPTX = 'S' THEN
                 PERFORM 0100-BUILD-UPDREC
                 PERFORM 0100-OVRWR-ORIG-UPDREC
                 DISPLAY WS-MSG-MDOK LINE 21 COL 01
              ELSE
                 DISPLAY WS-MSG-MDNO LINE 21 COL 01
              END-IF
           END-IF
           EXIT.
      *
      *-----------------------------------------------------------------
      *    0100-GET-DATA-UPD : Gets the fields of record for update.
      *-----------------------------------------------------------------
       0100-GET-DATA-UPD.
           ACCEPT WS-DESCART   LINE 09 COL 45
           MOVE WS-DESCART TO WS-V-DESCART
           IF WS-V-DESCART-BNK
           OR WS-V-DESCART EQUAL LOW-VALUE THEN
              MOVE WS-UPD-DESCART TO WS-DESCART
           ELSE
              MOVE WS-DESCART TO WS-UPD-DESCART
           END-IF
      *
           ACCEPT WS-UNIDDS    LINE 10 COL 45
           IF WS-UNIDDS-BNK
           OR WS-UNIDDS EQUAL LOW-VALUE THEN
              MOVE WS-UPD-UNIDDS TO WS-UNIDDS
           ELSE
              MOVE WS-UNIDDS TO WS-UPD-UNIDDS
           END-IF
      *
           ACCEPT WS-VRUNIT  LINE 11 COL 45
           MOVE WS-VRUNIT TO WS-V-VRUNIT
           IF WS-V-VRUNIT-ZRO
           OR WS-V-VRUNIT EQUAL LOW-VALUE THEN
              MOVE WS-UPD-VRUNIT TO WS-VRUNIT
           ELSE
              MOVE WS-VRUNIT TO WS-UPD-VRUNIT
           END-IF
      *
           ACCEPT WS-CANT    LINE 12 COL 45
           MOVE WS-CANT TO WS-V-CANT
           IF WS-V-CANT-ZRO
           OR WS-V-CANT EQUAL LOW-VALUE THEN
              MOVE WS-UPD-CANT TO WS-CANT
           ELSE
              MOVE WS-CANT TO WS-UPD-CANT
           END-IF
           EXIT.
      *
      *-----------------------------------------------------------------
      *    0100-BUILD-UPDREC : build file with update of record
      *-----------------------------------------------------------------
       0100-BUILD-UPDREC.
           SET WS-END-FILE TO 0
           OPEN INPUT INVENTARIO
           OPEN OUTPUT INVENTUPD
           PERFORM UNTIL WS-END-FILE = 1
              READ INVENTARIO
                 AT END
                    SET WS-END-FILE TO 1
                 NOT AT END
                    IF CODART = WS-CODART THEN
                       MOVE WS-CODART TO UPD-CODART
                       MOVE WS-UPD-DESCART TO UPD-DESCART
                       MOVE WS-UPD-UNIDDS TO UPD-UNIDDS
                       MOVE WS-UPD-VRUNIT TO UPD-VRUNIT
                       MOVE WS-UPD-CANT TO UPD-CANT
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
           CLOSE INVENTARIO
           EXIT.
      *
      *-----------------------------------------------------------------
      *    0100-OVRWR-ORIG-UPDREC : overwrites principal sequential file
      *-----------------------------------------------------------------
       0100-OVRWR-ORIG-UPDREC.
           SET WS-END-FILE TO 0
           OPEN INPUT INVENTUPD
           OPEN OUTPUT INVENTARIO
           PERFORM UNTIL WS-END-FILE = 1
              READ INVENTUPD
                 AT END
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
           CLOSE INVENTUPD
           EXIT.
      *
      *-----------------------------------------------------------------
      *    0100-DEL-REC-FILE : Deletes one record from seq. file.
      *-----------------------------------------------------------------
       0100-DEL-REC-FILE.
           PERFORM 0100-RST-VAL-INS-REC
           PERFORM 0100-VAL-FILE-EXIST-RECS
           IF WS-FILE-EXTS = 0 THEN
              DISPLAY WS-MSG-FLOB LINE 24 COL 01
           ELSE
              PERFORM 0100-DISP-TIT-DAT-MOD
              DISPLAY WS-MSG-INCD LINE 24 COL 01
              SET WS-COD-EXIST TO 0
              PERFORM UNTIL WS-COD-EXIST = 1
                 MOVE 8 TO WS-ROWCTRL
                 MOVE 9 TO WS-COLCTRL
                 PERFORM 0100-VAL-CODART-NULL
                 PERFORM 0100-VAL-CODART-EXISTS
              END-PERFORM
              PERFORM 0100-DISP-DAT-REC-MOD
              DISPLAY WS-MSG-CFMD LINE 20 COL 01
              DISPLAY WS-MSG-CFDL LINE 21 COL 01
              ACCEPT WS-OPTX LINE 21 COL 78 PROMPT
              IF WS-OPTX = 's' OR WS-OPTX = 'S' THEN
                 PERFORM 0100-BUILD-DELREC
                 PERFORM 0100-OVRWR-ORIG-DELREC
                 DISPLAY WS-MSG-DLOK LINE 20 COL 01
              ELSE
                 DISPLAY WS-MSG-DLNO LINE 20 COL 01
              END-IF
           END-IF
           EXIT.
      *
      *-----------------------------------------------------------------
      *    0100-BUILD-DELREC : Build file with recs without the rec del.
      *-----------------------------------------------------------------
       0100-BUILD-DELREC.
           SET WS-END-FILE TO 0
           OPEN INPUT INVENTARIO
           OPEN OUTPUT INVENTDEL
           PERFORM UNTIL WS-END-FILE = 1
              READ INVENTARIO
                 AT END
                    SET WS-END-FILE TO 1
                 NOT AT END
                    IF CODART NOT EQUAL TO WS-UPD-WSCODART THEN
                       MOVE CODART  TO DEL-CODART
                       MOVE DESCART TO DEL-DESCART
                       MOVE UNIDDS  TO DEL-UNIDDS
                       MOVE VRUNIT  TO DEL-VRUNIT
                       MOVE CANT    TO DEL-CANT
                       WRITE DEL-INVENT-REG
                    END-IF
           END-PERFORM
           CLOSE INVENTDEL
           CLOSE INVENTARIO
           EXIT.
      *
      *-----------------------------------------------------------------
      *    0100-OVRWR-ORIG-DELREC : Displays text help of program.
      *-----------------------------------------------------------------
       0100-OVRWR-ORIG-DELREC.
           SET WS-END-FILE TO 0
           OPEN INPUT INVENTDEL
           OPEN OUTPUT INVENTARIO
           PERFORM UNTIL WS-END-FILE = 1
              READ INVENTDEL
                 AT END
      *             END OF FILE
                    SET WS-END-FILE TO 1
                 NOT AT END
                    MOVE DEL-CODART  TO CODART
                        MOVE DEL-DESCART TO DESCART
                        MOVE DEL-UNIDDS  TO UNIDDS
                        MOVE DEL-VRUNIT  TO VRUNIT
                        MOVE DEL-CANT    TO CANT
                        WRITE INVENT-REG
           END-PERFORM
           CLOSE INVENTARIO
           CLOSE INVENTDEL.
           EXIT.
      *
      *-----------------------------------------------------------------
      *    0100-CRT-CSV : Create a CSV file from sequential file.
      *-----------------------------------------------------------------
       0100-CRT-CSV.
           PERFORM 0100-RST-VAL-INS-REC
           PERFORM 0100-VAL-FILE-EXIST-RECS
           IF WS-FILE-EXTS = 0 THEN
              DISPLAY WS-MSG-FLOB LINE 24 COL 01
           ELSE
              DISPLAY WS-MSG-RP01 LINE 10 COL 01
              DISPLAY WS-MSG-CFMD LINE 20 COL 01
              ACCEPT WS-OPTX LINE 21 COL 78 PROMPT
              IF WS-OPTX = 's' OR WS-OPTX = 'S' THEN
                 PERFORM 0100-HEAD-REPORT
                 PERFORM 0100-READ-FILE
                 DISPLAY WS-MSG-RPOK LINE 20 COL 01
              ELSE
                 DISPLAY WS-MSG-RPNO LINE 20 COL 01
              END-IF
           END-IF
           EXIT.
      *
      *-----------------------------------------------------------------
      *    0100-CRT-CSV : Create a CSV file from sequential file.
      *-----------------------------------------------------------------
       0100-HEAD-REPORT.
           OPEN OUTPUT OUT-INFORME
      *
           STRING WS-SPACEZ
           INTO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
      *
           STRING ';;'WS-HEAD-TITLE
           INTO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
      *
           STRING ';;'WS-HEAD-SUBTITLE
           INTO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
      *
           STRING WS-DATEFTD DELIMITED BY SIZE
           INTO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
      *
           STRING WS-SPACEZ2
           INTO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
      *
           STRING 'CODIGO;'
                  'DESCRIPCION;'
                  'UNIDAD DE MEDIDA;'
                  'VALOR UNITARIO;'
                  'CANTIDAD'
           INTO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
      *
           CLOSE OUT-INFORME.
           EXIT.
      *
      *-----------------------------------------------------------------
      *    0100-READ-FILE : Displays text help of program.
      *-----------------------------------------------------------------
       0100-READ-FILE.
           SET WS-END-FILE TO 0
           OPEN INPUT INVENTARIO
           PERFORM UNTIL WS-END-FILE = 1
              READ INVENTARIO
                 AT END
                    SET WS-END-FILE TO 1
                 NOT AT END
                    DISPLAY "."
                    PERFORM 0100-READ-RECORD
                 END-READ
              END-PERFORM
           CLOSE INVENTARIO.
           EXIT.
      *
      *-----------------------------------------------------------------
      *    0100-READ-RECORD : Read record from sequential file.
      *-----------------------------------------------------------------
           0100-READ-RECORD.
           OPEN EXTEND OUT-INFORME
           STRING
              CODART';'
              DESCART';'
              UNIDDS';'
              VRUNIT';'
              CANT
           INTO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           CLOSE OUT-INFORME.
           EXIT.
      *
      *-----------------------------------------------------------------
      *    0100-DISP-HELP : Displays text help of program.
      *-----------------------------------------------------------------
       0100-DISP-HELP.
           DISPLAY
              WS-DHL01 LINE 07 COL 01
              WS-DHL02 LINE 08 COL 01
              WS-DHL03 LINE 09 COL 01
              WS-DHL04 LINE 10 COL 01
              WS-DHL05 LINE 11 COL 01
              WS-DHL06 LINE 12 COL 01
              WS-DHL07 LINE 13 COL 01
              WS-DHL08 LINE 14 COL 01
              WS-DHL09 LINE 15 COL 01
              WS-DHL10 LINE 16 COL 01
              WS-DHL11 LINE 17 COL 01
              WS-DHL12 LINE 18 COL 01
              WS-DHL13 LINE 19 COL 01
              WS-MSG-AN1 LINE 24 COL 01
           EXIT.
      *
      *-----------------------------------------------------------------
      *    0100-RST-VAL-INS-REC : Reset values of some variables.
      *-----------------------------------------------------------------
       0100-RST-VAL-INS-REC.
           MOVE WS-ZERO  TO WS-CODART
           MOVE WS-BLANK TO WS-DESCART
           MOVE WS-BLANK TO WS-UNIDDS
           MOVE WS-ZERO  TO WS-VRUNIT
           MOVE WS-ZERO  TO WS-CANT
           MOVE WS-ZERO  TO WS-V-CODART
           MOVE WS-BLANK TO WS-V-DESCART
           MOVE WS-ZERO  TO WS-V-VRUNIT
           MOVE WS-ZERO  TO WS-V-CANT
           MOVE WS-ZERO  TO WS-D-WSCODART
           MOVE WS-BLANK TO WS-D-DESCART
           MOVE WS-BLANK TO WS-D-UNIDDS
           MOVE WS-ZERO  TO WS-D-VRUNIT
           MOVE WS-ZERO  TO WS-D-CANT
           SET WS-DCA-NULL TO 0
           SET WS-COD-EXIST TO 1
           IF WS-OPTN = 2 THEN
              PERFORM 0100-DISP-TIT-DATA
           END-IF
           EXIT.
      *
      *-----------------------------------------------------------------
      *    0100-GET-CURR-DATE : Get the current date and format it.
      *-----------------------------------------------------------------
       0100-GET-CURR-DATE.
           MOVE FUNCTION CURRENT-DATE TO WS-DATETIME
           MOVE WS-DATETIME(1:4)  TO WS-YEAR.
           MOVE WS-DATETIME(5:2)  TO WS-EVALMNTH.
           MOVE WS-DATETIME(7:2)  TO WS-DAY.
      *
           EVALUATE WS-EVALMNTH
              WHEN 01
                 MOVE WS-MNTH-01 TO WS-MNTH
              WHEN 02
                 MOVE WS-MNTH-02 TO WS-MNTH
              WHEN 03
                 MOVE WS-MNTH-03 TO WS-MNTH
              WHEN 04
                 MOVE WS-MNTH-04 TO WS-MNTH
              WHEN 05
                 MOVE WS-MNTH-05 TO WS-MNTH
              WHEN 06
                 MOVE WS-MNTH-06 TO WS-MNTH
              WHEN 07
                 MOVE WS-MNTH-07 TO WS-MNTH
              WHEN 08
                 MOVE WS-MNTH-08 TO WS-MNTH
              WHEN 09
                 MOVE WS-MNTH-09 TO WS-MNTH
              WHEN 10
                 MOVE WS-MNTH-10 TO WS-MNTH
              WHEN 11
                 MOVE WS-MNTH-11 TO WS-MNTH
              WHEN 12
                 MOVE WS-MNTH-12 TO WS-MNTH
           END-EVALUATE
      *
           MOVE FUNCTION TRIM(WS-MNTH,TRAILING) TO WS-MNTH
           STRING WS-DATES
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
           INTO WS-DATEFTD
           EXIT.
      ******************************************************************
      *    END OF THE PROGRAM
      ******************************************************************
       END PROGRAM INV01.
