HDatedit(*ymd) datfmt(*iso)                          
FQPRINT    O    F  132        PRINTER OFLIND(*INOV)  
DWCLICLA          S              5  0                
DWCLINOM          S             45                   
DWCLICEL          S             15                   
DWCLISEX          S              1                   
DWCLIEMAIL        S             30                   
DWCLIESTD         S              1                   
DWCLIDEP          S              2  0                
C*                                                   
C                   EXCEPT    CABECERA               
C                   EXCEPT    linea                  
C*                                                   
C/EXEC SQL                                           
C+  DECLARE C1 CURSOR FOR                            
C+    SELECT CLICLA, CLINOM, CLICEL, CLISEX, CLIEMAIL
C+     FROM CLIENTES                      
C+      ORDER BY CLICLA                   
C/END-EXEC                                
C*                                        
C/EXEC SQL                                
C+ OPEN C1                                
C/END-EXEC                                
C*                                        
C*/EXEC SQL WHENEVER NOT FOUND GO TO DONE1
C*/END-EXEC                                                     
C     SQLCOD        DOWEQ     0                                 
C/EXEC SQL                                                      
C+    FETCH C1                                                  
C+       INTO :WCLICLA, :WCLINOM, :WCLICEL, :WCLISEX, :WCLIEMAIL
C/END-EXEC                                                      
C                   EXSR      SRGRABA                           
C                   ENDDO                                       
C*          DONE1     TAG                                       
C/EXEC SQL                                                             
C+  CLOSE C1                                                           
C/END-EXEC                                                             
C*                                                                     
C*                                                                     
C                   SETON                                            LR
C     SRGRABA       BEGSR                                              
C                   EXCEPT    DETALLE                                  
C                   ENDSR                                              
OQPRINT    E            CABECERA       1                           
O                                            6 'PAGINA'            
O                       Page                10                     
O                                           40 'LISTA DE CLIENTES' 
O                                           65 'FECHA'             
O                       Udate         Y     75                     
O          E            LINEA          1                           
O                                           +1 '------------------'
O                                           +1 '------------------'
O                                           +1 '------------------'
O                                           +1 '-----------------' 
O                                           +1 '-----------------' 
O                                           +1 '-----------------' 
O                                           +1 '-----------------' 
O          E            DETALLE        1                           
O                       WCLICLA       Z     06                     
O                       WCLINOM             59                     
O                       WCLICEL             79                     
O                       WCLISEX             83
O                       WCLIEMAIL          120
