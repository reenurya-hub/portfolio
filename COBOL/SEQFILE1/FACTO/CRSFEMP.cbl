       IDENTIFICATION DIVISION.
       PROGRAM-ID. CRSFEMP.
      *
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER.
       OBJECT-COMPUTER.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT OPTIONAL EMPRESA ASSIGN TO "EMPRESA.DAT"
           ORGANIZATION IS SEQUENTIAL
           FILE STATUS IS WS-FILE-STATUS.
      *
       DATA DIVISION.
       FILE SECTION.
       FD EMPRESA.
       01 REG-EMPRESA.
           03 EMP-TIP-ID       PIC X(20).
           03 EMP-ID           PIC X(20).
           03 EMP-RSOCIAL      PIC X(30).
           03 EMP-RCCIAL       PIC X(30).
           03 EMP-SIGLA        PIC X(10).
           03 EMP-DIR1         PIC X(30).
           03 EMP-DIR2         PIC X(30).
           03 EMP-DIR3         PIC X(30).
           03 EMP-TEL1         PIC X(20).
           03 EMP-TEL2         PIC X(20).
           03 EMP-TEL3         PIC X(20).
           03 EMP-CIUDAD       PIC X(20).
           03 EMP-DEPTO        PIC X(20).
           03 EMP-EMAIL1       PIC X(30).
           03 EMP-EMAIL2       PIC X(30).
           03 EMP-EMAIL3       PIC X(30).
           03 EMP-WEB1         PIC X(30).
           03 EMP-WEB2         PIC X(30).
           03 EMP-RLEGAL       PIC X(60).
           03 EMP-FCONSTIT.
               05 EMP-FCTT-YYYY  PIC 9(4).
               05 EMP-FCTT-MM  PIC 9(2).
               05 EMP-FCTT-DD  PIC 9(2).
           03 EMP-FREGIST.
               05 EMP-FREG-YYYY  PIC 9(4).
               05 EMP-FREG-MM  PIC 9(2).
               05 EMP-FREG-DD  PIC 9(2).
           03 EMP-FILLER       PIC X(500).
      *
       WORKING-STORAGE SECTION.
      *
       01  ST-FILE                PIC XX.
       01  NUM-DATA            PIC 99.
       01  WS-SWITCH.
               05  WS-FILE-STATUS PIC XX.
                   88      WS-EMP-FILE-OK     VALUE '00'.
                   88      WS-EMPRESA-OPEN   VALUE '41'.
       01 WS-EMPRESA.
           03 WS-EMP-TIP-ID       PIC X(20).
               88 WS-TIP-ID-BLANK     VALUE SPACE.
           03 WS-EMP-ID           PIC X(20).
               88 WS-EMP-ID-BLANK     VALUE SPACE.
           03 WS-EMP-RSOCIAL      PIC X(30).
               88 WS-EMP-RSOC-BNK     VALUE SPACE.
           03 WS-EMP-RCCIAL       PIC X(30).
           03 WS-EMP-SIGLA        PIC X(10).
           03 WS-EMP-DIR1         PIC X(30).
               88 WS-EMP-DIR1-BNK     VALUE SPACE.
           03 WS-EMP-DIR2         PIC X(30).
           03 WS-EMP-DIR3         PIC X(30).
           03 WS-EMP-TEL1         PIC X(20).
               88 WS-EMP-TEL1-BNK     VALUE SPACE.
           03 WS-EMP-TEL2         PIC X(20).
           03 WS-EMP-TEL3         PIC X(20).
           03 WS-EMP-CIU          PIC X(20).
               88 WS-EMP-CIU-BNK      VALUE SPACE.
           03 WS-EMP-DEPTO        PIC X(20).
               88 WS-EMP-DEPTO-BNK    VALUE SPACE.
           03 WS-EMP-EMAIL1       PIC X(30).
               88 WS-EMP-EML1-BNK     VALUE SPACE.
           03 WS-EMP-EMAIL2       PIC X(30).
           03 WS-EMP-EMAIL3       PIC X(30).
           03 WS-EMP-WEB1         PIC X(30).
           03 WS-EMP-WEB2         PIC X(30).
           03 WS-EMP-RLEGAL       PIC X(60).
               88 WS-EMP-RLGL-BNK     VALUE SPACE.
           03 WS-EMP-FCONSTIT.
               05 WS-EMP-FCTT-YYYY   PIC 9(4).
               05 WS-EMP-FCTT-MM     PIC 9(2).
               05 WS-EMP-FCTT-DD     PIC 9(2).

           03 WS-EMP-FREGIST.
               05 WS-EMP-FREG-YYYY   PIC 9(4).
               05 WS-EMP-FREG-MM     PIC 9(2).
               05 WS-EMP-FREG-DD     PIC 9(2).
       01  SCREEN-CHARS.
           03  GUIONES            PIC X(80) VALUES ALL "-".
           03  OPC                PIC 9.
           03  MSG-OPCION         PIC X(18)
           VALUE 'Ingrese opcion [ ]'.
           03  MSG-INS-DAT_CAMB   PIC X(26)
           VALUE 'No. dato a cambiar: [  ]'.
           03  OPCIONES1          PIC X(70)
           VALUE '1-LISTA 2-INSERTA 3-MODIFICA 5-LIMPIA 6-SA'-
           'LE'.
           03  MSG-NO-FILE        PIC X(30)
           VALUE 'NO HAY UNA EMPRESA CREADA.    '.
           03  MSG-EMPTY-FIELD    PIC X(30)
           VALUE 'CAMPO INGRESADO VACIO.        '.
           03  MSG-REG-OK         PIC X(30)
           VALUE 'REGISTROS INSERTADOS.         '.
           03  MSG-DAT-MOD-OK     PIC X(30)
           VALUE 'DATO MODIFICADO EXITOSAMENTE. '.
           03  MSG-GENERICO       PIC X(30).
           03  MSG-ERR-OP-FGEN    PIC X(28)
           VALUE 'ERROR ABRIENDO ARCH EMPRESA '.
           03  MSG-SP             PIC X(30) VALUE SPACES.
           03  HEADER1    PIC X(33)
           VALUE '- = F A C T O - E M P R E S A = -'.
           03  X                  PIC X.
           03  SP                 PIC X(39) VALUE SPACES.
       PROCEDURE DIVISION.
       0100-START.
           PERFORM 0100-SHOW-DISPLAY.
           ACCEPT X.
           STOP RUN.

       0100-SHOW-DISPLAY.
                   DISPLAY " "       LINE 01 COL 01 ERASE EOS
                   HEADER1           LINE 03 COL 30
                   GUIONES           LINE 04 COL 01
                   "1-Tipo Id  :"    LINE 05 COL 03
                   "2-Id Nro.  :"    LINE 05 COL 39
                   "3-R.Social :"    LINE 06 COL 03
                   "4-R.Ccial  :"    LINE 07 COL 03
                   "5-Siglas   :"    LINE 08 COL 03
                   "6-Dir 1    :"    LINE 08 COL 39
                   "7-Dir 2    :"    LINE 09 COL 03
                   "8-Dir 3    :"    LINE 10 COL 03
                   "9-Tel 1    :"    LINE 11 COL 03
                   "10-Tel 2   :"    LINE 11 COL 39
                   "11-Tel 3   :"    LINE 12 COL 03
                   "12-Ciudad  :"    LINE 12 COL 39
                   "13-Depto   :"    LINE 13 COL 03
                   "14-Email 1 :"    LINE 13 COL 39
                   "15-Email 2 :"    LINE 14 COL 03
                   "16-Email 3 :"    LINE 15 COL 03
                   "17-Web 1   :"    LINE 16 COL 03
                   "18-Web 2   :"    LINE 17 COL 03
                   "19-Rep.Leg.:"    LINE 18 COL 03
                   "20-Fecha Constit AAAA: "    LINE 19 COL 03
                   "21-MM: "            LINE 19 COL 32
                   "22-DD: "            LINE 19 COL 42
                   GUIONES               LINE 22 COL 01.
                   PERFORM 0110-OPCIONES.
       0110-OPCIONES.
           DISPLAY MSG-OPCION            LINE 02 COL 01
                   OPCIONES1             LINE 23 COL 03.
           ACCEPT OPC LINE 02 COL 17 PROMPT.
           EVALUATE OPC
      *        1=LISTA
               WHEN 1
                   PERFORM 0120-VAL-FILE-EXISTS
      *        2=INSERTA
               WHEN 2
                   OPEN OUTPUT EMPRESA
                   PERFORM 0130-ENT-WS-TIP-ID
                   THRU    0240-GRAB-FILE
                   CLOSE EMPRESA
                   DISPLAY MSG-REG-OK    LINE 02 COL 41
                   ACCEPT  X             LINE 02 COL 40 PROMPT
                   DISPLAY MSG-SP        LINE 02 COL 41
                   PERFORM 0100-SHOW-DISPLAY
                   GO TO 0110-OPCIONES
      *        3=MODIFICAR
               WHEN 3
                   OPEN I-O EMPRESA
                   IF WS-EMP-FILE-OK
                       PERFORM 0270-UPDATE-EMPRESA
                   ELSE
                       DISPLAY MSG-NO-FILE     LINE 02 COL 41
                       CLOSE EMPRESA
                       ACCEPT X LINE 02 COL 40 PROMPT
                       GO TO 0110-OPCIONES
                   END-IF
      *        5=LIMPIA
               WHEN 5
                   PERFORM 0100-SHOW-DISPLAY
      *        6=SALE
               WHEN 6
                   PERFORM 9990-END-PROGRAM
               WHEN OTHER
                   GO TO 0110-OPCIONES
           END-EVALUATE.
       0120-VAL-FILE-EXISTS.
           OPEN INPUT EMPRESA
               IF WS-EMP-FILE-OK
      *             CONTINUE
                   IF WS-FILE-STATUS > "07"
                       STRING MSG-ERR-OP-FGEN WS-FILE-STATUS
                       DELIMITED BY SIZE
                       INTO MSG-GENERICO
                       DISPLAY MSG-GENERICO LINE 02 COL 41
                       CLOSE EMPRESA
                       ACCEPT X LINE 02 COL 40 PROMPT
                       PERFORM 0110-OPCIONES
                   ELSE
                       PERFORM 0250-READ-FILE
                   END-IF
               ELSE
                  DISPLAY MSG-NO-FILE     LINE 02 COL 41
                  CLOSE EMPRESA
                  ACCEPT X LINE 02 COL 40 PROMPT
                  GO TO 0110-OPCIONES
               END-IF.
       0130-ENT-WS-TIP-ID.
           DISPLAY MSG-SP LINE 02 COL 41
           SET WS-TIP-ID-BLANK TO TRUE
           ACCEPT WS-EMP-TIP-ID LINE 05 COL 15 PROMPT
           IF WS-TIP-ID-BLANK
               DISPLAY MSG-EMPTY-FIELD    LINE 02 COL 41
               ACCEPT X LINE 02 COL 40 PROMPT
               GO TO 0130-ENT-WS-TIP-ID.
       0135-ENT-WS-EMP-ID.
           DISPLAY MSG-SP LINE 02 COL 41
           SET WS-EMP-ID-BLANK TO TRUE
           ACCEPT WS-EMP-ID LINE 05 COL 51 PROMPT
           IF WS-EMP-ID-BLANK
               DISPLAY MSG-EMPTY-FIELD    LINE 02 COL 41
               ACCEPT X LINE 02 COL 40 PROMPT
               GO TO 0135-ENT-WS-EMP-ID.
       0140-ENT-WS-EMP-RSOC.
           DISPLAY MSG-SP LINE 02 COL 41
           SET WS-EMP-RSOC-BNK TO TRUE
           ACCEPT WS-EMP-RSOCIAL LINE 06 COL 15 PROMPT
           IF WS-EMP-RSOC-BNK
               DISPLAY MSG-EMPTY-FIELD    LINE 02 COL 41
               ACCEPT X LINE 02 COL 40 PROMPT
               GO TO 0140-ENT-WS-EMP-RSOC.
       0145-ENT-WS-EMP-RCCIAL.
           ACCEPT WS-EMP-RCCIAL LINE 07 COL 15 PROMPT.
       0150-ENT-WS-EMP-SIGLA.
           ACCEPT WS-EMP-SIGLA LINE 08 COL 15 PROMPT.
       0155-ENT-WS-EMP-DIR1.
           DISPLAY MSG-SP LINE 02 COL 41
           SET WS-EMP-DIR1-BNK TO TRUE
           ACCEPT WS-EMP-DIR1 LINE 08 COL 51 PROMPT
           IF WS-EMP-DIR1-BNK
               DISPLAY MSG-EMPTY-FIELD    LINE 02 COL 41
               ACCEPT X LINE 02 COL 40 PROMPT
               GO TO 0155-ENT-WS-EMP-DIR1.
       0160-ENT-WS-EMP-DIR2.
           ACCEPT WS-EMP-DIR2 LINE 09 COL 15 PROMPT.
       0165-ENT-WS-EMP-DIR3.
           ACCEPT WS-EMP-DIR3 LINE 10 COL 15 PROMPT.
       0165-ENT-WS-EMP-TEL1.
           DISPLAY MSG-SP LINE 02 COL 41
           SET WS-EMP-TEL1-BNK TO TRUE
           ACCEPT WS-EMP-TEL1 LINE 11 COL 15 PROMPT
           IF WS-EMP-TEL1-BNK
               DISPLAY MSG-EMPTY-FIELD    LINE 02 COL 41
               ACCEPT X LINE 02 COL 40 PROMPT
               GO TO 0165-ENT-WS-EMP-TEL1.

       0170-ENT-WS-EMP-TEL2.
           ACCEPT WS-EMP-TEL2 LINE 11 COL 51 PROMPT.
       0175-ENT-WS-EMP-TEL3.
           ACCEPT WS-EMP-TEL3 LINE 12 COL 15 PROMPT.
       0180-ENT-WS-EMP-CIU.
           DISPLAY MSG-SP LINE 02 COL 41
           SET WS-EMP-CIU-BNK TO TRUE
           ACCEPT WS-EMP-CIU  LINE 12 COL 51 PROMPT
           IF WS-EMP-CIU-BNK
               DISPLAY MSG-EMPTY-FIELD    LINE 02 COL 41
               ACCEPT X LINE 02 COL 40 PROMPT
               GO TO 0180-ENT-WS-EMP-CIU.
       0185-ENT-WS-EMP-DEPTO.
           DISPLAY MSG-SP LINE 02 COL 41
           SET WS-EMP-DEPTO-BNK TO TRUE
           ACCEPT WS-EMP-DEPTO  LINE 13 COL 15 PROMPT
           IF WS-EMP-DEPTO-BNK
               DISPLAY MSG-EMPTY-FIELD    LINE 02 COL 41
               ACCEPT X LINE 02 COL 40 PROMPT
               GO TO 0185-ENT-WS-EMP-DEPTO.
       0190-ENT-WS-EMP-EMAIL1.
           DISPLAY MSG-SP LINE 02 COL 41
           SET WS-EMP-EML1-BNK TO TRUE
           ACCEPT WS-EMP-EMAIL1  LINE 13 COL 51 PROMPT
           IF WS-EMP-EML1-BNK
               DISPLAY MSG-EMPTY-FIELD    LINE 02 COL 41
               ACCEPT X LINE 02 COL 40 PROMPT
               GO TO 0190-ENT-WS-EMP-EMAIL1.
       0195-ENT-WS-EMP-EMAIL2.
           ACCEPT WS-EMP-EMAIL2 LINE 14 COL 15 PROMPT.
       0200-ENT-WS-EMP-EMAIL3.
           ACCEPT WS-EMP-EMAIL3 LINE 15 COL 15 PROMPT.
       0205-ENT-WS-EMP-WEB1.
           ACCEPT WS-EMP-WEB1 LINE 16 COL 15 PROMPT.
       0210-ENT-WS-EMP-WEB2.
           ACCEPT WS-EMP-WEB2 LINE 17 COL 15 PROMPT.
       0215-ENT-WS-EMP-RLEGAL.
           DISPLAY MSG-SP LINE 02 COL 41
           SET WS-EMP-RLGL-BNK TO TRUE
           ACCEPT WS-EMP-RLEGAL  LINE 18 COL 15 PROMPT
           IF WS-EMP-RLGL-BNK
               DISPLAY MSG-EMPTY-FIELD    LINE 02 COL 41
               ACCEPT X LINE 02 COL 40 PROMPT
               GO TO 0215-ENT-WS-EMP-RLEGAL.
       0220-ENT-WS-EMP-FCTT-YYYY.
           ACCEPT WS-EMP-FCTT-YYYY  LINE 19 COL 26 PROMPT.
       0225-ENT-WS-EMP-FCTT-MM.
           ACCEPT WS-EMP-FCTT-MM  LINE 19 COL 38 PROMPT.
       0230-ENT-WS-EMP-FCTT-DD.
           ACCEPT WS-EMP-FCTT-DD  LINE 19 COL 50 PROMPT.
       0240-GRAB-FILE.
           ACCEPT WS-EMP-FREGIST FROM DATE.
           MOVE WS-EMPRESA TO REG-EMPRESA.
           WRITE REG-EMPRESA.

       0250-READ-FILE.
           IF WS-EMPRESA-OPEN
               CONTINUE
           ELSE
           OPEN INPUT EMPRESA
           END-IF.
           READ EMPRESA.
           MOVE REG-EMPRESA TO WS-EMPRESA.
           PERFORM 0260-DISPLAY-FIELDS.

       0260-DISPLAY-FIELDS.
           DISPLAY WS-EMP-TIP-ID   LINE 05 COL 15.
           DISPLAY WS-EMP-ID       LINE 05 COL 51.
           DISPLAY WS-EMP-RSOCIAL  LINE 06 COL 15.
           DISPLAY WS-EMP-RCCIAL   LINE 07 COL 15.
           DISPLAY WS-EMP-SIGLA    LINE 08 COL 15.
           DISPLAY WS-EMP-DIR1     LINE 08 COL 51.
           DISPLAY WS-EMP-DIR2     LINE 09 COL 15.
           DISPLAY WS-EMP-DIR3     LINE 10 COL 15.
           DISPLAY WS-EMP-TEL1     LINE 11 COL 15.
           DISPLAY WS-EMP-TEL2     LINE 11 COL 51.
           DISPLAY WS-EMP-TEL3     LINE 12 COL 15.
           DISPLAY WS-EMP-CIU      LINE 12 COL 51.
           DISPLAY WS-EMP-DEPTO    LINE 13 COL 15.
           DISPLAY WS-EMP-EMAIL1   LINE 13 COL 51.
           DISPLAY WS-EMP-EMAIL2   LINE 14 COL 15.
           DISPLAY WS-EMP-EMAIL3   LINE 15 COL 15.
           DISPLAY WS-EMP-WEB1     LINE 16 COL 15.
           DISPLAY WS-EMP-WEB2     LINE 17 COL 15.
           DISPLAY WS-EMP-RLEGAL   LINE 18 COL 15.
           DISPLAY WS-EMP-FCTT-YYYY  LINE 19 COL 26.
           DISPLAY WS-EMP-FCTT-MM  LINE 19 COL 38.
           DISPLAY WS-EMP-FCTT-DD  LINE 19 COL 48.
           CLOSE EMPRESA.
           PERFORM 0110-OPCIONES.
       0270-UPDATE-EMPRESA.

           READ EMPRESA.
           MOVE REG-EMPRESA TO WS-EMPRESA.
           DISPLAY MSG-INS-DAT_CAMB LINE 03 COL 01.
           ACCEPT  NUM-DATA     LINE 03 COL 22 PROMPT.
           EVALUATE NUM-DATA
               WHEN 1
                   PERFORM 0130-ENT-WS-TIP-ID
               WHEN 2
                   PERFORM 0135-ENT-WS-EMP-ID
               WHEN 3
                   PERFORM 0140-ENT-WS-EMP-RSOC
               WHEN 4
                   PERFORM 0145-ENT-WS-EMP-RCCIAL
               WHEN 5
                   PERFORM 0150-ENT-WS-EMP-SIGLA
               WHEN 6
                   PERFORM 0155-ENT-WS-EMP-DIR1
               WHEN 7
                   PERFORM 0160-ENT-WS-EMP-DIR2
               WHEN 8
                   PERFORM 0165-ENT-WS-EMP-DIR3
               WHEN 9
                   PERFORM 0165-ENT-WS-EMP-TEL1
               WHEN 10
                   PERFORM 0170-ENT-WS-EMP-TEL2
               WHEN 11
                   PERFORM 0175-ENT-WS-EMP-TEL3
               WHEN 12
                   PERFORM 0180-ENT-WS-EMP-CIU
               WHEN 13
                   PERFORM 0185-ENT-WS-EMP-DEPTO
               WHEN 14
                   PERFORM 0190-ENT-WS-EMP-EMAIL1
               WHEN 15
                   PERFORM 0195-ENT-WS-EMP-EMAIL2
               WHEN 16
                   PERFORM 0200-ENT-WS-EMP-EMAIL3
               WHEN 17
                   PERFORM 0205-ENT-WS-EMP-WEB1
               WHEN 18
                   PERFORM 0210-ENT-WS-EMP-WEB2
               WHEN 19
                   PERFORM 0215-ENT-WS-EMP-RLEGAL
               WHEN 20
                   PERFORM 0220-ENT-WS-EMP-FCTT-YYYY
               WHEN 21
                   PERFORM 0225-ENT-WS-EMP-FCTT-MM
               WHEN 22
                   PERFORM 0230-ENT-WS-EMP-FCTT-DD
               WHEN OTHER
                   GO TO 0270-UPDATE-EMPRESA
           END-EVALUATE.
           MOVE WS-EMPRESA TO REG-EMPRESA.
           REWRITE REG-EMPRESA.
           CLOSE EMPRESA.
           DISPLAY MSG-DAT-MOD-OK     LINE 02 COL 41
           ACCEPT X LINE 02 COL 40 PROMPT
           PERFORM 0110-OPCIONES.

       9990-END-PROGRAM.
           IF WS-EMPRESA-OPEN
           CLOSE EMPRESA.
           STOP RUN.
       END PROGRAM CRSFEMP.
