
-- 1. View the version of Oracle that is installed
SELECT * FROM PRODUCT_COMPONENT_VERSION;


PRODUCT                                                                                                                                                                                                                                                                                                                          VERSION                                                                                                                                                                                                                                                                                                                          STATUS                                                                                                                                                                                                                                                                                                                          
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
NLSRTL                                                                                                                                                                                                                                                                                                                           11.2.0.2.0                                                                                                                                                                                                                                                                                                                       Production                                                                                                                                                                                                                                                                                                                      
Oracle Database 11g Express Edition                                                                                                                                                                                                                                                                                              11.2.0.2.0                                                                                                                                                                                                                                                                                                                       64bit Production                                                                                                                                                                                                                                                                                                                
PL/SQL                                                                                                                                                                                                                                                                                                                           11.2.0.2.0                                                                                                                                                                                                                                                                                                                       Production                                                                                                                                                                                                                                                                                                                      
TNS for 64-bit Windows:   



SELECT * FROM V$VERSION;


BANNER                                                                          
--------------------------------------------------------------------------------
Oracle Database 11g Express Edition Release 11.2.0.2.0 - 64bit Production
PL/SQL Release 11.2.0.2.0 - Production
CORE	11.2.0.2.0	Production  
TNS for 64-bit Windows: Version 11.2.0.2.0 - Production
NLSRTL Version 11.2.0.2.0 - Production


/******************************************************************************/

-- 2. View database name:
SELECT NAME FROM V$DATABASE;

NAME     
---------
XE

SELECT * FROM GLOBAL_NAME;

GLOBAL_NAME                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
XE

/******************************************************************************/

-- 3. View NLS (National Language Support) Parameters

SELECT * FROM NLS_DATABASE_PARAMETERS;

PARAMETER                      VALUE                                   
------------------------------ ----------------------------------------
NLS_LANGUAGE                   AMERICAN                                
NLS_TERRITORY                  AMERICA                                 
NLS_CURRENCY                   $                                       
NLS_ISO_CURRENCY               AMERICA                                 
NLS_NUMERIC_CHARACTERS         .,                                      
NLS_CHARACTERSET               AL32UTF8                                
NLS_CALENDAR                   GREGORIAN                               
NLS_DATE_FORMAT                DD-MON-RR                               
NLS_DATE_LANGUAGE              AMERICAN                                
NLS_SORT                       BINARY                                  
NLS_TIME_FORMAT                HH.MI.SSXFF AM                          

PARAMETER                      VALUE                                   
------------------------------ ----------------------------------------
NLS_TIMESTAMP_FORMAT           DD-MON-RR HH.MI.SSXFF AM                
NLS_TIME_TZ_FORMAT             HH.MI.SSXFF AM TZR                      
NLS_TIMESTAMP_TZ_FORMAT        DD-MON-RR HH.MI.SSXFF AM TZR            
NLS_DUAL_CURRENCY              $                                       
NLS_COMP                       BINARY                                  
NLS_LENGTH_SEMANTICS           BYTE                                    
NLS_NCHAR_CONV_EXCP            FALSE                                   
NLS_NCHAR_CHARACTERSET         AL16UTF16                               
NLS_RDBMS_VERSION              11.2.0.2.0                              

20 filas seleccionadas. 

/******************************************************************************/

-- 4. View sessions

SELECT SCHEMANAME, OSUSER, MACHINE, PROGRAM, STATE FROM SYS.V$SESSION;


SCHEMANAME                     OSUSER                         MACHINE                                                          PROGRAM                                                          STATE              
------------------------------ ------------------------------ ---------------------------------------------------------------- ---------------------------------------------------------------- -------------------
SYS                            SYSTEM                         DESKTOP-T08FBE0                                                  ORACLE.EXE (PMON)                                                WAITING            
SYS                            SYSTEM                         DESKTOP-T08FBE0                                                  ORACLE.EXE (VKTM)                                                WAITING            
SYS                            SYSTEM                         DESKTOP-T08FBE0                                                  ORACLE.EXE (DIAG)                                                WAITING            
SYS                            SYSTEM                         DESKTOP-T08FBE0                                                  ORACLE.EXE (DBW0)                                                WAITING            
SYS                            SYSTEM                         DESKTOP-T08FBE0                                                  ORACLE.EXE (CKPT)                                                WAITING            
SYS                            SYSTEM                         DESKTOP-T08FBE0                                                  ORACLE.EXE (RECO)                                                WAITING            
SYS                            SYSTEM                         DESKTOP-T08FBE0                                                  ORACLE.EXE (MMNL)                                                WAITING            
SYS                            SYSTEM                         DESKTOP-T08FBE0                                                  ORACLE.EXE (DIA0)                                                WAITING            
SYS                            SYSTEM                         DESKTOP-T08FBE0                                                  ORACLE.EXE (QMNC)                                                WAITING            
SYS                            SYSTEM                         DESKTOP-T08FBE0                                                  ORACLE.EXE (Q001)                                                WAITING            
SYS                            SYSTEM                         DESKTOP-T08FBE0                                                  ORACLE.EXE (SMCO)                                                WAITING            

SCHEMANAME                     OSUSER                         MACHINE                                                          PROGRAM                                                          STATE              
------------------------------ ------------------------------ ---------------------------------------------------------------- ---------------------------------------------------------------- -------------------
HR                             usuario                        DESKTOP-T08FBE0                                                  SQL Developer                                                    WAITING            
SYS                            SYSTEM                         DESKTOP-T08FBE0                                                  ORACLE.EXE (PSP0)                                                WAITING            
SYS                            SYSTEM                         DESKTOP-T08FBE0                                                  ORACLE.EXE (GEN0)                                                WAITING            
SYS                            SYSTEM                         DESKTOP-T08FBE0                                                  ORACLE.EXE (DBRM)                                                WAITING            
SYS                            SYSTEM                         DESKTOP-T08FBE0                                                  ORACLE.EXE (MMAN)                                                WAITING            
SYS                            SYSTEM                         DESKTOP-T08FBE0                                                  ORACLE.EXE (LGWR)                                                WAITING            
SYS                            SYSTEM                         DESKTOP-T08FBE0                                                  ORACLE.EXE (SMON)                                                WAITING            
SYS                            SYSTEM                         DESKTOP-T08FBE0                                                  ORACLE.EXE (MMON)                                                WAITING            
SYS                            SYSTEM                         DESKTOP-T08FBE0                                                  ORACLE.EXE (VKRM)                                                WAITING            
SYS                            SYSTEM                         DESKTOP-T08FBE0                                                  ORACLE.EXE (W000)                                                WAITING            
SYS                            SYSTEM                         DESKTOP-T08FBE0                                                  ORACLE.EXE (Q002)                                                WAITING            

SCHEMANAME                     OSUSER                         MACHINE                                                          PROGRAM                                                          STATE              
------------------------------ ------------------------------ ---------------------------------------------------------------- ---------------------------------------------------------------- -------------------
SYS                            SYSTEM                         DESKTOP-T08FBE0                                                  ORACLE.EXE (CJQ0)                                                WAITING            
SYS                            usuario                        DESKTOP-T08FBE0                                                  SQL Developer                                                    WAITED SHORT TIME  

24 filas seleccionadas. 


/******************************************************************************/

-- 5. View services

SELECT SERVICE_ID, NAME, NETWORK_NAME FROM DBA_SERVICES;


SERVICE_ID NAME                                                             NETWORK_NAME                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
---------- ---------------------------------------------------------------- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
         1 SYS$BACKGROUND                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
         2 SYS$USERS                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
         3 XEXDB                                                            XEXDB                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
         4 XE                                                               XE                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              


/******************************************************************************/

-- 6. View current database instance details.

SELECT INSTANCE_NAME, HOST_NAME, VERSION, STARTUP_TIME, STATUS FROM V$INSTANCE;


INSTANCE_NAME    HOST_NAME                                                        VERSION           STARTUP_ STATUS      
---------------- ---------------------------------------------------------------- ----------------- -------- ------------
xe               DESKTOP-T08FBE0                                                  11.2.0.2.0        04/04/23 OPEN        


/******************************************************************************/
            Managing tablespaces and data files
-- 1.  List tablespaces, statu and type

SELECT TABLESPACE_NAME, STATUS, CONTENTS FROM DBA_TABLESPACES;



TABLESPACE_NAME                STATUS    CONTENTS 
------------------------------ --------- ---------
SYSTEM                         ONLINE    PERMANENT
SYSAUX                         ONLINE    PERMANENT
UNDOTBS1                       ONLINE    UNDO     
TEMP                           ONLINE    TEMPORARY
USERS                          ONLINE    PERMANENT


/******************************************************************************/

-- 3. List Datafiles, tablespaces and status

SELECT FILE_NAME, TABLESPACE_NAME, STATUS FROM DBA_DATA_FILES;


FILE_NAME                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         TABLESPACE_NAME                STATUS   
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ------------------------------ ---------
C:\ORACLEXE\APP\ORACLE\ORADATA\XE\USERS.DBF                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       USERS                          AVAILABLE
C:\ORACLEXE\APP\ORACLE\ORADATA\XE\SYSAUX.DBF                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      SYSAUX                         AVAILABLE
C:\ORACLEXE\APP\ORACLE\ORADATA\XE\UNDOTBS1.DBF                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    UNDOTBS1                       AVAILABLE
C:\ORACLEXE\APP\ORACLE\ORADATA\XE\SYSTEM.DBF  

/******************************************************************************/

-- 4. To check the current size of a tablespace

SELECT SUM(BYTES/1024/1024/1024) "Size in GB" FROM DBA_DATA_FILES WHERE TABLESPACE_NAME = 'SYSTEM';


Size in GB
----------
,3515625  


/******************************************************************************/

-- List datafiles, tablespaces and status

SELECT FILE_NAME, TABLESPACE_NAME, STATUS FROM DBA_DATA_FILES;

FILE_NAME                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         TABLESPACE_NAME                STATUS   
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ------------------------------ ---------
C:\ORACLEXE\APP\ORACLE\ORADATA\XE\USERS.DBF                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       USERS                          AVAILABLE
C:\ORACLEXE\APP\ORACLE\ORADATA\XE\SYSAUX.DBF                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      SYSAUX                         AVAILABLE
C:\ORACLEXE\APP\ORACLE\ORADATA\XE\UNDOTBS1.DBF                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    UNDOTBS1                       AVAILABLE
C:\ORACLEXE\APP\ORACLE\ORADATA\XE\SYSTEM.DBF 

/******************************************************************************/

-- 5. Check the size of a database

Size of an Oracle Database is the sum of the size of its Data Files, Temporary Files, Redo Logs and Control Files.

SELECT ROUND(
    SUM(Q1."Data Files" +
        Q2."Temp Files" +
        Q3."Redo Logs"  +
        Q4."Control Files"
        )/1024/1024/1024, 2)
    AS "Total Size (GB)"
FROM
    (Select sum(bytes) "Data Files" FROM DBA_DATA_FILES) Q1,
    (Select sum(bytes) "Temp Files" FROM DBA_TEMP_FILES) Q2,
    (Select sum(bytes) "Redo Logs" FROM V_$LOG) Q3,
    (Select sum(BLOCK_SIZE * FILE_SIZE_BLKS) "Control Files" FROM V$CONTROLFILE) Q4;

Total Size (GB)
---------------
            1,6

/******************************************************************************/

               Managing Users and Security

-- List all users, account status and profile

SELECT USERNAME, ACCOUNT_STATUS, PROFILE FROM DBA_USERS;

USERNAME                       ACCOUNT_STATUS                   PROFILE                       
------------------------------ -------------------------------- ------------------------------
ANONYMOUS                      OPEN                             DEFAULT                       
HR                             OPEN                             DEFAULT                       
SYS                            OPEN                             DEFAULT                       
SYSTEM                         OPEN                             DEFAULT                       
FLOWS_FILES                    LOCKED                           DEFAULT                       
APEX_PUBLIC_USER               LOCKED                           DEFAULT                       
APEX_040000                    LOCKED                           DEFAULT                       
MDSYS                          EXPIRED & LOCKED                 DEFAULT                       
CTXSYS                         EXPIRED & LOCKED                 DEFAULT                       
OUTLN                          EXPIRED & LOCKED                 DEFAULT                       
DIP                            EXPIRED & LOCKED                 DEFAULT                       

USERNAME                       ACCOUNT_STATUS                   PROFILE                       
------------------------------ -------------------------------- ------------------------------
DBSNMP                         EXPIRED & LOCKED                 DEFAULT                       
XDB                            EXPIRED & LOCKED                 DEFAULT                       
ORACLE_OCM                     EXPIRED & LOCKED                 DEFAULT                       
APPQOSSYS                      EXPIRED & LOCKED                 DEFAULT                       
XS$NULL                        EXPIRED & LOCKED                 DEFAULT                       

16 filas seleccionadas. 


/******************************************************************************/
-- 2. List all roles

SELECT * FROM DBA_ROLES;


ROLE                           PASSWORD AUTHENTICAT
------------------------------ -------- -----------
CONNECT                        NO       NONE       
RESOURCE                       NO       NONE       
DBA                            NO       NONE       
SELECT_CATALOG_ROLE            NO       NONE       
EXECUTE_CATALOG_ROLE           NO       NONE       
DELETE_CATALOG_ROLE            NO       NONE       
EXP_FULL_DATABASE              NO       NONE       
IMP_FULL_DATABASE              NO       NONE       
LOGSTDBY_ADMINISTRATOR         NO       NONE       
DBFS_ROLE                      NO       NONE       
AQ_ADMINISTRATOR_ROLE          NO       NONE       

ROLE                           PASSWORD AUTHENTICAT
------------------------------ -------- -----------
AQ_USER_ROLE                   NO       NONE       
DATAPUMP_EXP_FULL_DATABASE     NO       NONE       
DATAPUMP_IMP_FULL_DATABASE     NO       NONE       
ADM_PARALLEL_EXECUTE_TASK      NO       NONE       
GATHER_SYSTEM_STATISTICS       NO       NONE       
XDB_WEBSERVICES_OVER_HTTP      NO       NONE       
RECOVERY_CATALOG_OWNER         NO       NONE       
SCHEDULER_ADMIN                NO       NONE       
HS_ADMIN_SELECT_ROLE           NO       NONE       
HS_ADMIN_EXECUTE_ROLE          NO       NONE       
HS_ADMIN_ROLE                  NO       NONE       

ROLE                           PASSWORD AUTHENTICAT
------------------------------ -------- -----------
OEM_ADVISOR                    NO       NONE       
OEM_MONITOR                    NO       NONE       
PLUSTRACE                      NO       NONE       
CTXAPP                         NO       NONE       
XDBADMIN                       NO       NONE       
XDB_SET_INVOKER                NO       NONE       
AUTHENTICATEDUSER              NO       NONE       
XDB_WEBSERVICES                NO       NONE       
XDB_WEBSERVICES_WITH_PUBLIC    NO       NONE       
APEX_ADMINISTRATOR_ROLE        NO       NONE       

32 filas seleccionadas.

/******************************************************************************/

-- CREATE USER

CREATE USER CHARLIE IDENTIFIED BY CHARLIE;

User CHARLIE creado.

/******************************************************************************/

-- Change user password

ALTER USER CHARLIE IDENTIFIED BY 12345;

User CHARLIE alterado.

/******************************************************************************/

-- CREATE user profile (WITH ALL DEFAULT LIMITS)

CREATE PROFILE MY_PROFILE LIMIT;

Profile MY_PROFILE creado.


/******************************************************************************/

-- View all user profiles and limits

SELECT * FROM DBA_PROFILES;


PROFILE                        RESOURCE_NAME                    RESOURCE LIMIT                                   
------------------------------ -------------------------------- -------- ----------------------------------------
MY_PROFILE                     COMPOSITE_LIMIT                  KERNEL   DEFAULT                                 
DEFAULT                        COMPOSITE_LIMIT                  KERNEL   UNLIMITED                               
MY_PROFILE                     SESSIONS_PER_USER                KERNEL   DEFAULT                                 
DEFAULT                        SESSIONS_PER_USER                KERNEL   UNLIMITED                               
MY_PROFILE                     CPU_PER_SESSION                  KERNEL   DEFAULT                                 
DEFAULT                        CPU_PER_SESSION                  KERNEL   UNLIMITED                               
MY_PROFILE                     CPU_PER_CALL                     KERNEL   DEFAULT                                 
DEFAULT                        CPU_PER_CALL                     KERNEL   UNLIMITED                               
MY_PROFILE                     LOGICAL_READS_PER_SESSION        KERNEL   DEFAULT                                 
DEFAULT                        LOGICAL_READS_PER_SESSION        KERNEL   UNLIMITED                               
MY_PROFILE                     LOGICAL_READS_PER_CALL           KERNEL   DEFAULT                                 

PROFILE                        RESOURCE_NAME                    RESOURCE LIMIT                                   
------------------------------ -------------------------------- -------- ----------------------------------------
DEFAULT                        LOGICAL_READS_PER_CALL           KERNEL   UNLIMITED                               
MY_PROFILE                     IDLE_TIME                        KERNEL   DEFAULT                                 
DEFAULT                        IDLE_TIME                        KERNEL   UNLIMITED                               
MY_PROFILE                     CONNECT_TIME                     KERNEL   DEFAULT                                 
DEFAULT                        CONNECT_TIME                     KERNEL   UNLIMITED                               
MY_PROFILE                     PRIVATE_SGA                      KERNEL   DEFAULT                                 
DEFAULT                        PRIVATE_SGA                      KERNEL   UNLIMITED                               
MY_PROFILE                     FAILED_LOGIN_ATTEMPTS            PASSWORD DEFAULT                                 
DEFAULT                        FAILED_LOGIN_ATTEMPTS            PASSWORD 10                                      
MY_PROFILE                     PASSWORD_LIFE_TIME               PASSWORD DEFAULT                                 
DEFAULT                        PASSWORD_LIFE_TIME               PASSWORD 180                                     

PROFILE                        RESOURCE_NAME                    RESOURCE LIMIT                                   
------------------------------ -------------------------------- -------- ----------------------------------------
MY_PROFILE                     PASSWORD_REUSE_TIME              PASSWORD DEFAULT                                 
DEFAULT                        PASSWORD_REUSE_TIME              PASSWORD UNLIMITED                               
MY_PROFILE                     PASSWORD_REUSE_MAX               PASSWORD DEFAULT                                 
DEFAULT                        PASSWORD_REUSE_MAX               PASSWORD UNLIMITED                               
MY_PROFILE                     PASSWORD_VERIFY_FUNCTION         PASSWORD DEFAULT                                 
DEFAULT                        PASSWORD_VERIFY_FUNCTION         PASSWORD NULL                                    
MY_PROFILE                     PASSWORD_LOCK_TIME               PASSWORD DEFAULT                                 
DEFAULT                        PASSWORD_LOCK_TIME               PASSWORD 1                                       
MY_PROFILE                     PASSWORD_GRACE_TIME              PASSWORD DEFAULT                                 
DEFAULT                        PASSWORD_GRACE_TIME              PASSWORD 7                                       

32 filas seleccionadas. 

/******************************************************************************/

-- CHANGE PASSWORD LIFETIME, REUSE TIME, FAILED LOGIN ATTEMPTS

SELECT * FROM DBA_PROFILES WHERE PROFILE = 'MY_PROFILE' AND RESOURCE_NAME = 'PASSWORD_LIFE_TIME';



PROFILE                        RESOURCE_NAME                    RESOURCE LIMIT                                   
------------------------------ -------------------------------- -------- ----------------------------------------
MY_PROFILE                     PASSWORD_LIFE_TIME               PASSWORD DEFAULT                                 

/******************************************************************************/

-- SET PASSWORD EXPIRY

ALTER PROFILE MY_PROFILE LIMIT PASSWORD_LIFE_TIME 60;

Profile MY_PROFILE alterado.


-- TO SET PASSWORD TO NEVER EXPIRE:

ALTER PROFILE MY_PROFILE LIMIT PASSWORD_LIFE_TIME UNLIMITED;

Profile MY_PROFILE alterado.


/******************************************************************************/

-- View privileges granted to a user on other users tables

SELECT * FROM DBA_TAB_PRIVS WHERE GRANTEE='USERNAME';
no se ha seleccionado ninguna fila

/******************************************************************************/

-- View all user privileges including the privileges that are indirectly granted through roles

SELECT * from DBA_SYS_PRIVS WHERE GRANTEE = 'USERNAME' OR 'GRANTEE' IN (SELECT GRANTED_ROLE FROM DBA_ROLE_PRIVS WHERE GRANTEE = 'USERNAME');

no se ha seleccionado ninguna fila
