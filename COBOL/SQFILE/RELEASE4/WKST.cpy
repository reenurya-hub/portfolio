      *-----------------------------------------------------------------
      * DATA VARIABLES
      *-----------------------------------------------------------------
       01 WS-CODART          PIC ZZZZ9.
       01 WS-V-CODART        PIC 9(5).
           88 WS-V-CODART-ZRO      VALUE ZEROES.
       01 WS-DESCART        PIC  X(35).
       01 WS-V-DESCART         PIC X(35).
           88 WS-V-DESCART-BNK      VALUE SPACE.
       01 WS-UNIDDS          PIC X(15).
           88 WS-UNIDDS-BNK      VALUE SPACE.
       01 WS-VRUNIT          PIC ZZZZZZZZ9.
       01 WS-V-VRUNIT        PIC 9(9).
           88 WS-V-VRUNIT-ZRO      VALUE ZEROES.
       01 WS-V-CANT        PIC 9(9).
       01 WS-CANT            PIC ZZZZZZZZ9.
           88 WS-V-CANT-ZRO      VALUE ZEROES.
      *
       01 WS-UPD-INVENT-REG.
           02 WS-UPD-WSCODART  PIC ZZZZ9.
           02 WS-UPD-DESCART   PIC X(35).
           02 WS-UPD-UNIDDS    PIC X(15).
           02 WS-UPD-VRUNIT    PIC ZZZZZZZZ9.
           02 WS-UPD-CANT      PIC ZZZZZZZZ9.
      *
       01 WS-D-INVENT-REG.
           02 WS-D-WSCODART  PIC ZZZZ9.
           02 WS-D-DESCART   PIC X(35).
           02 WS-D-UNIDDS    PIC X(15).
           02 WS-D-VRUNIT    PIC ZZZZZZZZ9.
           02 WS-D-CANT      PIC ZZZZZZZZ9.
      *
           77 WS-DCA-NULL    PIC 9     VALUE 0.
           77 WS-COD-EXIST   PIC 9(1)  VALUE 1.
           77 WS-UND-GRL     PIC X(15) VALUE 'UNIDAD         '.
           77 WS-ZERO        PIC 9     VALUE 0.
           77 WS-BLANK       PIC X     VALUE SPACE.
           77 WS-ROWCTRL     PIC 99    VALUE 8.
           77 WS-COLCTRL     PIC 99    VALUE 1.
           77 WS-BAR         PIC X     VALUE '|'.
      *
      *-----------------------------------------------------------------
      * REPORT VARIABLES
      *-----------------------------------------------------------------
      *    HEADER OF REPORT
           77 WS-HEAD-TITLE    PIC X(17)     VALUE 'EMPRESA DE PRUEBA'.
           77 WS-HEAD-SUBTITLE PIC X(21)  VALUE 'INFORME DE INVENTARIO'.
           77 WS-HEAD-COLS     PIC X(200).
           77 WS-WS-BY       PIC X(24) VALUE ';;;Por: Reinaldo Urquijo'.
           77 WS-NEWLINE       PIC X VALUE X'0A'.
           77 WS-NEWLINE2      PIC X VALUE X'0D'.
           77 WS-NULLABLE      PIC X VALUE SPACE.
           77 WS-SPACEZ        PIC X.
           77 WS-SPACEZ2       PIC X(200) VALUE SPACES.
      *
      *-----------------------------------------------------------------
      * DATE VARIABLES
      *-----------------------------------------------------------------
       01 WS-DATETIME        PIC X(21).
       01 WS-DATEFTD         PIC X(30).
       01 WS-YEAR            PIC 9(04).
       01 WS-DAY             PIC 9(02).
       01 WS-EVALMNTH        PIC 9(02).
       01 WS-MNTH            PIC X(10).
       01 WS-CONN            PIC X(02) VALUE 'de'.
       01 WS-SPACE           PIC X(01) VALUE ' '.
       01 WS-DATE            PIC X(06) VALUE 'Fecha:'.
       01 WS-DATES           PIC X(06) VALUE 'Fecha:'.
       01 WS-MNTH-01         PIC X(05) VALUE 'enero'.
       01 WS-MNTH-02         PIC X(07) VALUE 'febrero'.
       01 WS-MNTH-03         PIC X(05) VALUE 'marzo'.
       01 WS-MNTH-04         PIC X(05) VALUE 'abril'.
       01 WS-MNTH-05         PIC X(04) VALUE 'mayo'.
       01 WS-MNTH-06         PIC X(05) VALUE 'junio'.
       01 WS-MNTH-07         PIC X(05) VALUE 'julio'.
       01 WS-MNTH-08         PIC X(06) VALUE 'agosto'.
       01 WS-MNTH-09         PIC X(10) VALUE 'septiembre'.
       01 WS-MNTH-10         PIC X(07) VALUE 'octubre'.
       01 WS-MNTH-11         PIC X(09) VALUE 'noviembre'.
       01 WS-MNTH-12         PIC X(09) VALUE 'diciembre'.
      *-----------------------------------------------------------------
      * FILE VARIABLES
      *-----------------------------------------------------------------
        01  WS-FILE-STATUS.
           05 WS-FILE-STAT1  PIC X.
           05 WS-FILE-STAT2  PIC X.
      *
           77 WS-FILE-EXTS   PIC 9 VALUE 0.
           77 WS-END-FILE    PIC 9 VALUE 0.
           77 WS-FILE-RECS   PIC 9 VALUE 0.
      *
      *-----------------------------------------------------------------
      * TEXT PRESENTATION
      *-----------------------------------------------------------------
           77  WS-HEAD1    PIC X(80) VALUE '                       -='-
       '-I N V E N T / v1.0-=-                                '.
           77  WS-HEAD2    PIC X(80) VALUE 'Programa para manejo de i'-
       'nventarios            Por: Reinaldo Urquijo - v1.0    '.
           77  WS-HYPHNS   PIC X(80) VALUES ALL "-".
           77  WS-HYPHNS2  PIC X(36) VALUES ALL "-".
           77  WS-SPACES   PIC X(80) VALUES ALL SPACE.
           77  WS-OPTS1    PIC X(80) VALUE '1-CREA 2-INS 3-LST 4-MOD '-
       '5-ELM 6-REP 7-AYUDA 9-SALE  Ingrese opcion         [ ]'.
      *
      *-----------------------------------------------------------------
      * OPTION VARIABLES
      *-----------------------------------------------------------------
           77  WS-OPTN     PIC 9 VALUE 8.
           77  WS-OPTX     PIC X.
           77  WS-OPTNM    PIC 9 VALUE 1.
      *
      *-----------------------------------------------------------------
      * SCREEN TITLES
      *-----------------------------------------------------------------
           77  WS-ST-PPL   PIC X(09) VALUE 'Esta en: '.
           77  WS-ST-PRPL  PIC X(25) VALUE 'PRINCIPAL                '.
           77  WS-ST-CRFL  PIC X(25) VALUE 'CREACION DE ARCHIVO      '.
           77  WS-ST-SLRC  PIC X(25) VALUE 'LISTADO DE REGISTROS     '.
           77  WS-ST-INRC  PIC X(25) VALUE 'INSERCION DE REGISTROS   '.
           77  WS-ST-UPRC  PIC X(25) VALUE 'MODIFICACION DE REGISTROS'.
           77  WS-ST-DLRC  PIC X(25) VALUE 'ELIMINACION DE REGISTROS '.
           77  WS-ST-RPRC  PIC X(25) VALUE 'REPORTE DE INVENTARIO    '.
           77  WS-ST-HLGN  PIC X(25) VALUE 'AYUDA GENERAL            '.
      *
      *-----------------------------------------------------------------
      * DISPLAY DATA LABELS
      *-----------------------------------------------------------------
           77  WS-LB-DT1   PIC X(80) VALUE '|COD  |DESCRIPCION       '-
       '                  |UNIDAD MEDIDA  |VRUNIT   |CANTIDAD |'.
           77  WS-LB-DT2   PIC X(80) VALUE 'Columna|Valor actual     '-
       '                  |Valor modificado                   '.
           77  WS-LB-DT3   PIC X(80) VALUE 'Columna|Valor actual     '-
       '                  |'.

      *-----------------------------------------------------------------
      * DISPLAY DATA TITLES
      *-----------------------------------------------------------------
           77  WS-DDT-CA   PIC X(08) VALUE 'Codigo.:'.
           77  WS-DDT-DA   PIC X(08) VALUE 'Descrp.:'.
           77  WS-DDT-UA   PIC X(08) VALUE 'Ud.Med.:'.
           77  WS-DDT-VA   PIC X(08) VALUE 'Vlunit :'.
           77  WS-DDT-QA   PIC X(08) VALUE 'Cantdad:'.
      *
      *-----------------------------------------------------------------
      * HELP MESSAGES
      *-----------------------------------------------------------------
           77  WS-DHL01 PIC X(80) VALUE 'INVENT es un programa creado'-
       'para la gestion de inventarios escrito en COBOL    '.
           77  WS-DHL02 PIC X(80) VALUE 'usando GNUcobol con Opencobo'-
       'lIDE v4.7.6                                        '.
           77  WS-DHL03 PIC X(80) VALUE 'cualquier PQRSF escribir a: '-
       'reinaldo.urquijo@gmail.com                         '.
           77  WS-DHL04 PIC X(80) VALUE SPACES.
           77  WS-DHL05 PIC X(80) VALUE 'OPCIONES: se pueden acceder '-
       ' opciones ingresando el numero correspondiente.    '.
           77  WS-DHL06 PIC X(80) VALUE '1-CREA = permite crear un ar'-
       'hivo de inventarios nuevo.                         '.
           77  WS-DHL07 PIC X(80) VALUE '3-INS = inserta uno o mas re'-
       'istros de articulos de inventario en el archivo    '.
           77  WS-DHL08 PIC X(80) VALUE '2-LST = lista en pantalla lo'-
       ' registros que se encuentren en inventario.        '.
           77  WS-DHL09 PIC X(80) VALUE '4-MOD = modifica uno o mas c'-
       'mpos de un registro de acuerdo al codigo articulo. '.
           77  WS-DHL10 PIC X(80) VALUE '5-ELM = elimina uno o mas re'-
       'istros de acuerdo al codigo de articulo.           '.
           77  WS-DHL11 PIC X(80) VALUE '6-REP = genera un reporte en'-
       'formato CSV con los artículos en inventario.       '.
           77  WS-DHL12 PIC X(80) VALUE '7-AYUDA= muestra esta ayuda.'-
       '                                                   '.
           77  WS-DHL13 PIC X(80) VALUE '9-SALE= sale de este program'-
       'a y retorna al sistema.                            '.
      *
      *-----------------------------------------------------------------
      * GENERAL MESSAGES
      *-----------------------------------------------------------------
           77  WS-MSG-EXT  PIC X(80) VALUE ' Programa terminado. Hast'-
       'a pronto!                                              '.
           77  WS-MSG-AN1  PIC X(80) VALUE ' Presione cualquier tecla'-
       'para volver a la pantalla principal                    '.
           77  WS-MSG-FLCR PIC X(80) VALUE ' El archivo INVENTARIO.da'-
       't ha sido creado                                       '.
           77  WS-MSG-FLEX PIC X(80) VALUE ' El archivo INVENTARIO.da'-
       't ya existe.                                           '.
           77  WS-MSG-DTOB PIC X(80) VALUE ' Debe ingresar un valor p'-
       'ara este campo. Presione Enter para insertar.          '.
           77  WS-MSG-CDXT PIC X(80) VALUE ' El codigo de articulo se'-
       ' encuentra registrado                                  '.
           77  WS-MSG-FLOB PIC X(80) VALUE ' Antes de ingresar datos '-
       'debe crear el archivo con la opcion 1.                 '.
           77  WS-MSG-NONL PIC X(80) VALUE ' El dato es obligatorio. '-
       '                                                       '.
           77  WS-MSG-RCOK PIC X(80) VALUE ' Registro insertado corre'-
       'ctamente.                                              '.
           77  WS-MSG-OTRC PIC X(80) VALUE ' Desea ingresar otro regi'-
       'stro S/N                            Ingrese opcion [  ]'.
           77  WS-MSG-NORC PIC X(80) VALUE ' No hay registros para mo'-
       'strar del archivo.                                     '.
           77  WS-MSG-INUP PIC X(80) VALUE ' Ingrese el campo con el '-
       'nuevo valor modificado, de lo contrario presione Enter.'.
           77  WS-MSG-CFDL PIC X(80) VALUE ' El registro sera elimina'-
       'do al confirmar.                                       '.
           77  WS-MSG-CFMD PIC X(80) VALUE ' Confirma el proceso a re'-
       'alizar S/N                         Ingrese opcion [  ]'.
           77  WS-MSG-MDOK PIC X(80) VALUE ' La actualizacion del reg'-
       'istro fue realizada correctamente.                     '.
           77  WS-MSG-MDNO PIC X(80) VALUE ' La actualizacion del reg'-
       'istro fue cancelada.                                   '.
           77  WS-MSG-DLOK PIC X(80) VALUE ' La eliminacion del reg'-
       'istro fue realizada correctamente.                     '.
           77  WS-MSG-DLNO PIC X(80) VALUE ' La eliminacion del reg'-
       'istro fue cancelada.                                   '.
           77  WS-MSG-NRC1 PIC X(80) VALUE ' El archivo no tiene regi'-
       'stros, se va a tomar el codigo ingresado como nuevo.   '.
           77  WS-MSG-NRC2 PIC X(80) VALUE ' El archivo no tiene regi'-
       'stros, no se puede actualizar con el codigo ingresado. '.
           77  WS-MSG-NRC3 PIC X(80) VALUE ' El registro ingresado no'-
       ' existe, debe ingresar un registro existente.          '.
           77  WS-MSG-INCD PIC X(80) VALUE ' Ingrese el codigo de art'-
       'iculo y luego presione Enter.                          '.
           77  WS-MSG-RP01 PIC X(80) VALUE ' Se generara el reporte d'-
       'e inventario en formato CSV.                          '.
           77  WS-MSG-RPOK PIC X(80) VALUE ' El reporte fue generado '-
       'exitosamente.                                         '.
           77  WS-MSG-RPNO PIC X(80) VALUE ' La generacion del report'-
       'e fue cancelada.                                      '.
           77  WS-SPC PIC X(80) VALUES ALL SPACE.

