      ******************************************************************
      *0500-GET-IDX-CODE
      ******************************************************************
       0500-GET-IDX-CODE.
           IF WS-COD-EXIST = 1 THEN
           OPEN INPUT INVENTARIO
           SET WS-REC-IDX TO 1
           PERFORM VARYING WS-REC-IDX FROM 1 BY 1
              UNTIL WS-REC-IDX > 1000000
              IF CODART = WS-CODART
                 DISPLAY "WS-REC-IDX:"WS-REC-IDX
                 EXIT PERFORM
              END-IF
           END-PERFORM
           CLOSE INVENTARIO
           END-IF.
      ******************************************************************
      *END 0500-GET-IDX-CODE
      ******************************************************************
