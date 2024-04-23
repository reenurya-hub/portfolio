       FD INVENTARIO.
       01 INVENT-REG.
           02 CODART               PIC ZZZZ9.
           02 DESCART              PIC X(35).
           02 UNIDDS               PIC X(15).
           02 VRUNIT               PIC ZZZZZZZZ9.
           02 CANT                 PIC ZZZZZZZZ9.
      *
       FD INVENTUPD.
       01 UPD-INVENT-REG.
           02 UPD-CODART           PIC ZZZZ9.
           02 UPD-DESCART          PIC X(35).
           02 UPD-UNIDDS           PIC X(15).
           02 UPD-VRUNIT           PIC ZZZZZZZZ9.
           02 UPD-CANT             PIC ZZZZZZZZ9.
      *
       FD INVENTDEL.
       01 DEL-INVENT-REG.
           02 DEL-CODART           PIC ZZZZ9.
           02 DEL-DESCART          PIC X(35).
           02 DEL-UNIDDS           PIC X(15).
           02 DEL-VRUNIT           PIC ZZZZZZZZ9.
           02 DEL-CANT             PIC ZZZZZZZZ9.
      *
       FD OUT-INFORME.
       01 OUTPUT-RECORD PIC X(200).
