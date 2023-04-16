d $empcod         S             30s 0                                   
d $empnom         S             40a                                     
d $empsue         S             11s 2                                   
  /free                                                                  
   //Set SQL options                                                     
   exec sql                                                              
    SET OPTION                                                           
        commit = *none,                                                  
        datfmt = *iso;                                                   
   //Insert data from fields ino SQL table                               
     $empcod     = 93137848;                                             
     $empnom     = 'Reinaldo';                                           
     $empsue     = 2500.50;                                              
   exec sql                                                              
     INSERT INTO REUY851/EMPLEADO VALUES(                                
        :$empcod,                                                        
        :$empnom,                                                        
        :$empsue);            */                                         
   *inlr = *on;                                                          
  /end-free                                                              
                                                                               
