           SELECT INVENTARIO ASSIGN TO "INVENTARIO.DAT"
           ORGANIZATION IS LINE SEQUENTIAL
           ACCESS MODE  IS SEQUENTIAL
           FILE STATUS  IS WS-FILE-STATUS.
      *
           SELECT INVENTUPD ASSIGN TO "INVENTTUPD.DAT"
           ORGANIZATION IS SEQUENTIAL
           ACCESS MODE IS SEQUENTIAL
           FILE STATUS  IS WS-FILE-STATUS.
      *
           SELECT INVENTDEL ASSIGN TO "INVENTTDEL.DAT"
           ORGANIZATION IS SEQUENTIAL
           ACCESS MODE IS SEQUENTIAL
           FILE STATUS  IS WS-FILE-STATUS.
      *
           SELECT OUT-INFORME ASSIGN TO "INFORME.csv"
           ORGANIZATION IS LINE SEQUENTIAL.

