MAIN PROGRAM
============
* IM01.cbl   = INVENT Main program

VARIABLES AND RECORDS
=====================
* IGM01.cbl  = Variable messages in console interface
* IGRI01.cbl   = Record insert 

DISPLAY PROGRAMS AND FILES
==========================
* IGD01.cbl  = Display General console interface and options
* IGDH01.cbl (COMPILABLE) = Display help text in console interface

FILE MANAGEMENT
===============
* IFC01.cbl  = Create sequential file
* IFDS01.cbl = Declare sequential file
* IFV01.cbl  = Validates if sequential file exists



cd C:\Users\User\Documents\PROYECTOS\COBOL\AAA_SEQUENTIAL\SEQFILE3\RELEASE3_1
cobc -x -o INV01.exe -debug INV01.cbl



C:\Program Files (x86)\OpenCobolIDE\GnuCOBOL
set_env.cmd




C:\Users\User\Documents\PROYECTOS\COBOL\AAA_SEQUENTIAL\SEQFILE3\RELEASE3

to compile use:
run set_env.cmd and enter in project folder in same console session
cd C:\Users\User\Documents\PROYECTOS\COBOL\AAA_SEQUENTIAL\SEQFILE3\RELEASE3
cobc -x -o IFC01.exe -debug IFC01.cbl
cobc -x -o IM01.exe -debug IM01.cbl IGDH01.cbl IGRI01.cbl IFC01.cbl
cobc -x -o IM01.exe -debug IM01.cbl IGDH01.cbl IGRI01.cbl IFV01.cbl
