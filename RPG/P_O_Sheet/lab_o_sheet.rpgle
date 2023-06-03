HDatedit(*ymd) datfmt(*iso)                                
FLABRFF1   IF   E           K DISK    RENAME(LABRFF1:WLAB) 
FQPRINT    O    F  132        PRINTER OFLIND(*In90)        
C*                                                         
C                   EXCEPT    CABECERA                     
C                   EXCEPT    LINEA                        
C     *LOVAL        SETLL     LABRFF1                      
C                   READ(N)   LABRFF1                      
C                   DOW       NOT           %EOF(LABRFF1)  
C                   IF        *IN90=*ON                    
C                   EXCEPT    CABECERA                     
C                   EXCEPT    LINEA                        
C                   EVAL      *IN90=*OFF                   
C                   ENDIF                                  
C                   EXCEPT    DETALLE                      
C                   READ(N)   LABRFF1                      
C                   ENDDO                                               
C                   EXCEPT    PIE                                       
C                   SETON                                            LR 
C*                                                                      
OQPRINT    E            CABECERA       1                                
O                                            6 'PAGINA'                 
O                       Page                10                          
O                                           47 'LISTA DE MONTOS'        
O                                           65 'FECHA'                  
O                       Udate         y     75                         
O          E            LINEA          1                               
O                                           14 'MONTO1'                
O                                           30 'MONTO2'                
O                                           45 'MONTO3'                
O                                           59 'MONTO4'                
O                                           73 'MONTO5'                
O          E            LINEA          1                               
O                                           26 '--------------------------'
O                                           52 '--------------------------'
O                                           78 '--------------------------'
O          E            DETALLE     1                                  
O                       MONTO1        2     14                         
O                       MONTO2        2     30                         
O                       MONTO3        2     45                         
O                       MONTO4        2     59                         
O                       MONTO5        2     73                         
O          E            PIE         1                                  
O                                           26 '--------------------------'
O                                           52 '--------------------------'
O                                           78 '--------------------------'
